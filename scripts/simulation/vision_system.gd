class_name VisionSystem

const VISION_RADIUS: int  = 3    # TEST VALUE
const SCOUT_BONUS: float  = 2.0  # TEST VALUE — 偵查=1.0 最多 +2 hex

const TERRAIN_VISION_MULT: Dictionary   = { "plains": 1.0, "forest": 0.6, "mountain": 0.8 }
const TERRAIN_EXPOSURE_MULT: Dictionary = { "plains": 1.0, "forest": 0.5, "mountain": 0.7 }

# 單一權威：team 當前視野半徑（= tick_discovery vrange 同式，鏡射不 drift）。
# 供 decision finder 導出「隊看得到多遠」——守感知鐵律：只找視野內糧源，非 god-view/自由常數。
# time_vision_mult 預設 1.0（decision finder 用 base 視野；day/night 由 sim 傳入才計）。
static func vision_range(state: WorldState, team: TeamData, time_vision_mult: float = 1.0) -> int:
	var total: float = 0.0
	var count: int = 0
	for pid in ([team.leader_id] as Array) + team.named_members:
		var p: PersonData = state.persons.get(pid)
		if p: total += float(p.skills.get("偵查", 0.0)); count += 1
	var scout: float = total / maxf(float(count), 1.0)
	var obs_tile: HexTileData = state.world.tiles.get(team.tile_pos.x * 1000 + team.tile_pos.y)
	var obs_terrain: String = obs_tile.terrain if obs_tile != null else "plains"
	var vmult: float = float(TERRAIN_VISION_MULT.get(obs_terrain, 1.0))
	return roundi((VISION_RADIUS + scout * SCOUT_BONUS) * vmult * time_vision_mult)

func tick_discovery(state: WorldState, team_ids: Array,
		time_vision_mult: float = 1.0) -> void:
	for tid in team_ids:
		if not state.teams.has(tid):
			continue   # 本 tick 內滅團/解散 → id 仍留在傳入 team_ids 快照
		if not state.team_discovered.has(tid):
			state.team_discovered[tid] = []
		var obs: TeamData = state.teams[tid]
		var scout: float  = _avg_skill(state, obs, "偵查")
		var obs_tile      = _get_tile(state, obs.tile_pos)
		var obs_terrain   = obs_tile.terrain if obs_tile else "plains"
		var vmult: float  = float(TERRAIN_VISION_MULT.get(obs_terrain, 1.0))
		var vrange: int   = roundi((VISION_RADIUS + scout * SCOUT_BONUS) * vmult * time_vision_mult)
		for other_id in state.teams:
			if other_id == tid: continue
			var other: TeamData = state.teams[other_id]
			var dist: int = _hex_dist(obs.tile_pos, other.tile_pos)
			# ★★★共位偵測 tap（systems 2026-09-04 問「共位時有沒有產生 sighting」）——
			#   ★這裡分【被視野擋掉】與【進了視野但沒偵測到】兩格：兩者都會讓 belief 停在舊位置，
			#     ★★但處置完全相反（前者是 vrange，後者是 _can_detect 的門檻）。
			#   ★★★而「同格 pairs」這一格必須先非 0，否則下面兩格的 0 是【儀器沒跑到】不是【沒發生】。
			if Probe.enabled and dist == 0:
				Probe.bump("vis.colo.pairs")
			if dist > vrange:
				if Probe.enabled and dist == 0: Probe.bump("vis.colo.out_of_vrange_IMPOSSIBLE")
				continue
			var exposure: float = _get_exposure(state, other)
			var dist_f: float   = 1.0 - (float(dist) / float(vrange + 1)) * 0.5  # TEST VALUE
			var eff_exp: float  = exposure * dist_f
			if Probe.enabled and dist == 0:
				Probe.bump("vis.colo.detect" if _can_detect(scout, eff_exp) else "vis.colo.nodetect")
				if not _can_detect(scout, eff_exp):
					# ★逐筆：沒偵測到的時候，是哪一項不夠 —— 潛行/地形/人口/偵查各自的值都帶上，
					#   ★★否則只會知道「門檻沒過」而不知道【是誰把它壓下去的】。
					var _ot = _get_tile(state, other.tile_pos)
					Probe.bump_sample("vis.colo.nodetect.row", {
						"obs": tid, "tgt": other_id, "obs_pop": obs.population, "tgt_pop": other.population,
						"scout": scout, "exposure": exposure, "eff_exp": eff_exp,
						"分數": eff_exp + scout * 0.3, "terrain": (_ot.terrain if _ot else "?"),
						"stealth": _avg_skill(state, other, "潛行")}, 24)
			if _can_detect(scout, eff_exp):
				var is_new: bool = not state.team_discovered[tid].has(other_id)
				_mark(state, tid, other_id)
				_write_tier01(state, tid, other_id, other, dist, dist_f)
				if is_new:
					_grow_skill(state, obs, "偵查", "智力", "體力")
					FactionAISystem.mark_prosperity_recheck(state, tid)   # 新發現 → prosperity 立即重評
			else:
				_grow_skill(state, other, "潛行", "體力", "毅力")

func reveal_encounter(state: WorldState, id_a: int, id_b: int) -> void:
	_mark(state, id_a, id_b)
	_mark(state, id_b, id_a)

func _can_detect(scout: float, eff_exposure: float) -> bool:
	return eff_exposure + scout * 0.3 > 0.3

func _get_exposure(state: WorldState, team: TeamData) -> float:
	var base: float    = clampf(0.2 + team.population * 0.04, 0.2, 0.9)  # TEST VALUE
	var stealth: float = _avg_skill(state, team, "潛行")
	var tgt_tile       = _get_tile(state, team.tile_pos)
	var terrain: String = tgt_tile.terrain if tgt_tile else "plains"
	var emult: float   = float(TERRAIN_EXPOSURE_MULT.get(terrain, 1.0))
	return base * (1.0 - stealth * 0.6) * emult

func _get_tile(state: WorldState, pos: Vector2i):
	return state.world.tiles.get(pos.x * 1000 + pos.y)

func _avg_skill(state: WorldState, team: TeamData, skill: String) -> float:
	var total: float = 0.0; var count: int = 0
	for pid in ([team.leader_id] as Array) + team.named_members:
		var p: PersonData = state.persons.get(pid)
		if p: total += float(p.skills.get(skill, 0.0)); count += 1
	return total / maxf(float(count), 1.0)

func _grow_skill(state: WorldState, team: TeamData,
		skill: String, attr1: String, attr2: String) -> void:
	for pid in ([team.leader_id] as Array) + team.named_members:
		var p: PersonData = state.persons.get(pid)
		if p == null: continue
		var a1: float = float(p.attributes.get(attr1, 0.5)) * p.get_attribute_mult(attr1)
		var a2: float = float(p.attributes.get(attr2, 0.5)) * p.get_attribute_mult(attr2)
		var growth: float = 0.001 * a1 * (0.5 + a2 * 0.5) * p.get_skill_mult(skill)  # TEST VALUE
		SkillSystem.cap_add(p, skill, growth)

func _mark(state: WorldState, obs_id: int, tgt_id: int) -> void:
	if not state.team_discovered.has(obs_id):
		state.team_discovered[obs_id] = []
	if not state.team_discovered[obs_id].has(tgt_id):
		state.team_discovered[obs_id].append(tgt_id)

func _hex_dist(a: Vector2i, b: Vector2i) -> int:
	var dx := b.x - a.x; var dy := b.y - a.y
	return (abs(dx) + abs(dx + dy) + abs(dy)) / 2

func _write_tier01(state: WorldState, obs_id: int, tgt_id: int,
		tgt: TeamData, dist: int, dist_f: float) -> void:
	# G3c-2 觀察吃技能：距離噪疊觀察者偵查殘留噪（低偵查 → 親見也誤判，cred 仍 1.0）
	var obs_team: TeamData = state.teams.get(obs_id)
	var scout_skill: float = 0.0
	if obs_team:
		var obs_leader: PersonData = state.persons.get(obs_team.leader_id)
		if obs_leader: scout_skill = float(obs_leader.skills.get("偵查", 0.0))
	var noise: float = BeliefSystem.observation_noise(1.0 - dist_f, scout_skill)
	var pop_est: int = maxi(1, roundi(
		tgt.population * randf_range(1.0 - noise, 1.0 + noise)))
	var snap: Dictionary = BeliefSystem.best_estimate(state, obs_id, tgt_id).duplicate()
	snap["population_est"] = pop_est
	snap["tile_pos"]       = tgt.tile_pos
	snap["last_tick"]      = state.world.current_tick
	# ★★★外觀層（感知兩層，2026-09-02）：★不加雜訊 ⇒ 零額外 RNG 消耗
	#   （★理由：旗號/隊形要嘛看到要嘛沒看到，不是「看錯」；★★而這個寫入點【已經在耗兩顆 RNG】
	#     ——:110 randf_range(population_est) 與 :127 randi_range(resource_scale)——
	#     ★★★新欄位若帶雜訊會多耗 ⇒ 全世界 fp 位移，且「fp 為什麼變」就不再是單一原因）
	#   ★`activity` 讀的是【真發生才會變的底層信號】，不是 current_task（見 BeliefSystem.observed_activity）
	snap["tags_seen"]      = tgt.tags.duplicate()
	snap["activity"]       = BeliefSystem.observed_activity(state, tgt)
	# ★★★恆 0 桶（systems 2026-09-02）：寫入端【不該】出現 unknown ——
	#   ★非 0 ＝ 分類表又缺一格 ⇒ ★★報 systems，【不要自己補一個預設值把它蓋掉】
	if Probe.enabled and String(snap["activity"]) == BeliefSystem.ACT_UNKNOWN:
		Probe.bump("appearance.write_unknown_BUG")
	snap["in_combat"]      = tgt.combat_target != -1
	# ★「看得到在打」與「看得出打誰」是兩件事（R² 確認拆兩欄，不合併）：
	#   ★★對手也要在【觀察者自己的視野】內，才記得下「打誰」；否則只記「在打」。
	if tgt.combat_target != -1 and obs_team != null and state.teams.has(tgt.combat_target):
		var _foe: TeamData = state.teams[tgt.combat_target]
		if _hex_dist(obs_team.tile_pos, _foe.tile_pos) <= VISION_RADIUS:
			snap["combat_target_est"] = tgt.combat_target
	if not snap.has("tier"):
		snap["tier"] = 0
	if dist <= 1:
		if int(snap["tier"]) < 1:
			snap["tier"] = 1
		var total_res: float = 0.0
		for rk in tgt.resources:
			total_res += float(tgt.resources[rk])
		var scale: int = 0
		if   total_res >= 600.0: scale = 3
		elif total_res >= 200.0: scale = 2
		elif total_res >= 50.0:  scale = 1
		scale = clampi(scale + randi_range(-1, 1), 0, 3)
		snap["resource_scale"] = scale
	var cred: float = BeliefSystem.source_credibility(state, obs_id, "親見", obs_id, 0)
	BeliefSystem.record_claim(state, obs_id, tgt_id, obs_id, "親見", snap, cred, false)
