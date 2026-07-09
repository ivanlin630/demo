class_name NpcCombatSystem

const ROUND_CASUALTY_RATE: float      = 0.1
const VOLLEY_CASUALTY_RATE: float     = 0.05
const PURSUIT_RATE: float             = 0.05
const FLANKING_MULT: float            = 1.3
const MORALE_CASCADE_THRESHOLD: float = 0.3
# 照妖鏡#1：flat 潰退門檻 → 膽量人格化（spread 非 shift，均值保 0.2）。
const ABANDON_THRESHOLD_BASE: float  = 0.2    # 均值（保 aggregate 潰退傾向）
const ABANDON_COURAGE_SPREAD: float  = 0.16   # TEST VALUE：膽量調幅（勇 0.12→怯 0.28）
const ROUND_READINESS_DRAIN: float    = 0.08
const LOOT_RATE: float                = 0.3
const LOSER_CASUALTY_RATE: float      = 0.2   # TEST VALUE：敗方 pop 損耗比例（複用 force_occupy 量級）
const ARMED_RATIO_FLOOR: float        = 0.1   # TEST VALUE：最低參戰比，堵 0 武裝免疫（同 encounter）
const GOVERN_SURVIVE_MIN: int         = 3     # TEST VALUE：翻旗後敗方村隊存活 pop 下限，達此→治權隨旗；不足→鬼村（僅翻旗）

const HIT_WEIGHTS: Dictionary = {
	"head": 0.10, "torso": 0.40,
	"right_arm": 0.10, "left_arm": 0.10,
	"right_leg": 0.15, "left_leg": 0.15,
}
const STATUS_ORDER: Array = ["healthy", "wounded", "critical", "severed"]
const CRITICAL_DEATH_CHANCE_BASE: float  = 0.10
const CRITICAL_RECOVER_CHANCE_BASE: float = 0.40

var _msg:       SimMessageSystem
var _skill_sys: SkillSystem
var _equip:     EquipmentSystem

func _init() -> void:
	_msg       = SimMessageSystem.new()
	_skill_sys = load("res://scripts/simulation/skill_system.gd").new()
	_equip     = EquipmentSystem.new()

# ──────── Public API ────────

func process_ongoing_combat(state: WorldState, all_team_ids: Array) -> void:
	var processed: Dictionary = {}
	for tid in all_team_ids:
		if processed.has(tid) or not state.teams.has(tid):
			continue
		var team: TeamData = state.teams[tid]
		var enemy_id: int = team.combat_target
		if enemy_id == -1 or not state.teams.has(enemy_id):
			if enemy_id != -1:
				state.clear_combat_target(team)
			continue
		var enemy: TeamData = state.teams[enemy_id]
		if enemy.combat_target != tid:
			state.clear_combat_target(team)
			continue
		processed[tid]      = true
		processed[enemy_id] = true
		_resolve_combat_round(state, tid, enemy_id)

func tick_critical_npcs(state: WorldState, all_team_ids: Array) -> void:
	for tid in all_team_ids:
		if not state.teams.has(tid):
			continue
		var team: TeamData = state.teams[tid]
		var medicine: float = _best_medicine(state, team)
		var named_ids: Array = team.named_members.duplicate()   # MUST duplicate (Array by ref)
		if team.leader_id != -1:
			named_ids.append(team.leader_id)
		for pid in named_ids:
			var p = state.persons.get(pid)
			if p == null:
				continue
			var has_critical: bool = false
			for part in ["head", "torso"]:
				if p.body_parts[part]["status"] == "critical":
					has_critical = true
					break
			if not has_critical:
				continue
			var death_chance: float = CRITICAL_DEATH_CHANCE_BASE * (1.0 - medicine * 0.5)
			if randf() < death_chance:
				_kill_named_npc(state, tid, p)
				continue
			var recover_chance: float = CRITICAL_RECOVER_CHANCE_BASE * medicine
			if randf() < recover_chance:
				for part in ["head", "torso"]:
					if p.body_parts[part]["status"] == "critical":
						p.body_parts[part]["status"] = "wounded"
						print("[Recover] Person%d %s: critical → wounded" % [p.id, part])

func start_combat(state: WorldState, atk_id: int, def_id: int) -> void:
	var atk: TeamData = state.teams[atk_id]
	var def: TeamData = state.teams[def_id]
	state.set_combat_target(atk, def_id)
	state.set_combat_target(def, atk_id)
	_msg.emit_message(state, "combat_start",
		"Team %d 對 Team %d 宣戰" % [atk_id, def_id], atk,
		{ "origin": str(atk_id), "target": str(def_id) })
	print("[Combat Start] Team%d vs Team%d" % [atk_id, def_id])
	if Probe.enabled: Probe.bump("conq.combat_entered")
	_resolve_volley(state, atk_id, def_id)

func team_strength(state: WorldState, team_id: int) -> float:
	var team: TeamData = state.teams.get(team_id)
	if team != null and team.beast_kind != "":
		return team.beast_strength
	var base: float = _strength_raw(state, team_id)
	if team == null:
		return base
	for tid in state.teams:
		if tid == team_id:
			continue
		var t: TeamData = state.teams[tid]
		if t.current_task == TeamData.TASK_ESCORT and t.order_target_id == team_id \
				and t.tile_pos == team.tile_pos:
			base += _strength_raw(state, tid)
	return base

func calc_armed(state: WorldState, team: TeamData) -> int:
	var named_armed: int = 0
	for pid in ([team.leader_id] as Array) + team.named_members:
		var p: PersonData = state.persons.get(pid) as PersonData
		if p and p.equipment["hand_1"].get("type", "none") != "none":
			named_armed += 1
	var named_count: int = 1 + team.named_members.size()
	var anon_pop: int    = maxi(team.population - named_count, 0)
	return named_armed + roundi(float(anon_pop) * team.armed_anon_ratio)

func subjugate_team(state: WorldState, winner_id: int, loser_id: int) -> void:
	_try_subjugate(state, winner_id, loser_id)

# ──────── Private helpers ────────

func _resolve_volley(state: WorldState, id_a: int, id_b: int) -> void:
	var volley_a: float = _ranged_strength(state, id_a)
	var volley_b: float = _ranged_strength(state, id_b)
	var total: float = volley_a + volley_b
	if total <= 0.0:
		return
	var a: TeamData = state.teams[id_a]
	var b: TeamData = state.teams[id_b]
	var eff_a: int  = maxi(a.population - a.wounded, 1)
	var eff_b: int  = maxi(b.population - b.wounded, 1)
	var loss_a: int = maxi(int(float(eff_a) * volley_b / total * VOLLEY_CASUALTY_RATE), 0)
	var loss_b: int = maxi(int(float(eff_b) * volley_a / total * VOLLEY_CASUALTY_RATE), 0)
	_apply_casualties(state, id_a, loss_a)
	_apply_casualties(state, id_b, loss_b)
	print("[Volley] Team%d→%d  Team%d→%d" % [id_a, loss_a, id_b, loss_b])
	_skill_sys.on_volley(state, state.teams[id_a])
	_skill_sys.on_volley(state, state.teams[id_b])

func _resolve_combat_round(state: WorldState, id_a: int, id_b: int) -> void:
	var a: TeamData  = state.teams[id_a]
	var b: TeamData  = state.teams[id_b]

	var terrain_b: float = _terrain_defense_mult(state, b)
	var terrain_a: float = _terrain_defense_mult(state, a)

	var str_a: float = team_strength(state, id_a) * a.readiness
	var str_b: float = team_strength(state, id_b) * b.readiness * terrain_b
	var total: float = str_a + str_b
	var eff_a: int   = maxi(a.population - a.wounded, 1)
	var eff_b: int   = maxi(b.population - b.wounded, 1)

	var loss_a: int = max(int(round(eff_a * str_b / total * ROUND_CASUALTY_RATE)), 0)
	var loss_b: int = max(int(round(eff_b * str_a / total * ROUND_CASUALTY_RATE)), 0)

	if eff_a >= eff_b * 3:
		var tactics_b: float = 0.0
		var leader_b: PersonData = state.persons.get(b.leader_id)
		if leader_b != null:
			tactics_b = float(leader_b.skills.get("戰術", 0.0))
		var flank_mult: float = FLANKING_MULT - tactics_b * 0.3
		loss_b = int(round(float(loss_b) * flank_mult))
	if eff_b >= eff_a * 3:
		var tactics_a: float = 0.0
		var leader_a: PersonData = state.persons.get(a.leader_id)
		if leader_a != null:
			tactics_a = float(leader_a.skills.get("戰術", 0.0))
		var flank_mult: float = FLANKING_MULT - tactics_a * 0.3
		loss_a = int(round(float(loss_a) * flank_mult))

	_apply_casualties(state, id_a, loss_a)
	_apply_casualties(state, id_b, loss_b)

	var wnd_ratio_a: float = float(a.wounded) / float(maxi(a.population, 1))
	var wnd_ratio_b: float = float(b.wounded) / float(maxi(b.population, 1))
	var drain_a: float = ROUND_READINESS_DRAIN * (2.0 if wnd_ratio_a > MORALE_CASCADE_THRESHOLD else 1.0)
	var drain_b: float = ROUND_READINESS_DRAIN * (2.0 if wnd_ratio_b > MORALE_CASCADE_THRESHOLD else 1.0)
	a.readiness = maxf(a.readiness - drain_a, 0.0)
	b.readiness = maxf(b.readiness - drain_b, 0.0)

	print("[Round] Team%d(rd=%.2f,terrain=%.2f) vs Team%d(rd=%.2f,terrain=%.2f)  wnd+%d/%d  eff=%d/%d" % [
		id_a, a.readiness, terrain_a, id_b, b.readiness, terrain_b, loss_a, loss_b,
		maxi(a.population - a.wounded, 1), maxi(b.population - b.wounded, 1)])

	if maxi(a.population - a.wounded, 1) <= 1:
		_end_combat(state, id_b, id_a)
		return
	if maxi(b.population - b.wounded, 1) <= 1:
		_end_combat(state, id_a, id_b)
		return
	if a.readiness <= _abandon_threshold(state, a):
		_probe_retreat(state, a)
		_force_retreat(state, id_a, id_b)
		return
	if b.readiness <= _abandon_threshold(state, b):
		_probe_retreat(state, b)
		_force_retreat(state, id_b, id_a)
		return
	_skill_sys.on_combat_round(state, a)
	_skill_sys.on_combat_round(state, b)
	_try_retreat(state, id_a, id_b)
	if a.combat_target != -1:
		_try_retreat(state, id_b, id_a)

func _end_combat(state: WorldState, winner_id: int, loser_id: int) -> void:
	var winner: TeamData = state.teams[winner_id]
	var loser: TeamData  = state.teams[loser_id]
	state.clear_combat_target(winner)
	state.clear_combat_target(loser)
	# 野獸結算：不走人類 loot/subjugate/capture/pursuit
	if loser.beast_kind != "" or winner.beast_kind != "":
		if loser.beast_kind != "" and winner.beast_kind == "":
			BeastSystem.new().reward_and_cleanup(state, winner_id, loser_id)   # 獵勝得肉
		elif winner.beast_kind != "":
			AmbushSystem.new().record_infamy(state, winner.tile_pos)           # 獸致死 → tile infamy
			BeastSystem.new()._cleanup(state, winner_id)                       # 獸贏，不擄掠
		else:
			BeastSystem.new()._cleanup(state, loser_id)                        # 雙獸（不會發生）
		return
	var winner_p = state.persons.get(winner.leader_id)
	var cruelty: float = float(winner_p.values.get("殘忍", 0.5)) if winner_p else 0.5
	_loot_resources(winner, loser, cruelty)
	# 戰敗 looted 記憶：敗方全員記住勝方 leader
	var _npc_ai_loot := NpcAiSystem.new()
	for pid in ([loser.leader_id] as Array) + loser.named_members:
		var vp: PersonData = state.persons.get(pid)
		if vp:
			_npc_ai_loot.write_memory(vp, "looted", winner.leader_id,
				state.world.current_tick, 0.7)
	# A feud：戰敗 faction 餘部繼承（滅團=massacre 級，倖存=looted 級）
	var sev_key: String = "massacre" if maxi(loser.population - loser.wounded, 0) <= 1 else "looted"
	NpcAiSystem.spread_feud(state, loser, winner.leader_id,
		NpcAiSystem.FEUD_SEVERITY[sev_key], state.world.current_tick)
	# 勝方 aided_in_battle 記憶：支援護衛 team 全員
	var _npc_ai_aid := NpcAiSystem.new()
	for escort_id in state.teams:
		var escort: TeamData = state.teams[escort_id]
		if escort.current_task == TeamData.TASK_ESCORT and escort.order_target_id == winner_id \
				and escort.tile_pos == winner.tile_pos:
			for pid in ([winner.leader_id] as Array) + winner.named_members:
				var sp: PersonData = state.persons.get(pid)
				if sp:
					_npc_ai_aid.write_memory(sp, "aided_in_battle", escort.leader_id,
						state.world.current_tick, 0.5)
	if cruelty > 0.6:
		var worsen_chance: float = (cruelty - 0.6) * 0.5
		for pid in state.persons:
			var p: PersonData = state.persons[pid]
			if p.team_id != loser_id: continue
			for part in p.body_parts:
				if p.body_parts[part]["status"] == "wounded" and randf() < worsen_chance:
					p.body_parts[part]["status"] = "critical"
	# loot 結算後，全 named_members loyalty 懲罰（依義氣）
	for pid in winner.named_members:
		var p: PersonData = state.persons.get(pid)
		if p == null: continue
		var yi_qi: float = float(p.values.get("義氣", 0.5))
		LoyaltyBank.adjust(p, -(1.0 - yi_qi) * 0.05, "betrayal")
	_msg.emit_message(state, "combat_end",
		"Team %d 擊潰 Team %d" % [winner_id, loser_id], winner,
		{ "origin": str(winner_id), "loser": str(loser_id),
		  "x": str(winner.tile_pos.x), "y": str(winner.tile_pos.y) })
	print("[Combat End] Team%d 勝 Team%d (rd=%.2f/%.2f wnd=%d/%d)" % [
		winner_id, loser_id, winner.readiness, loser.readiness,
		winner.wounded, loser.wounded])
	var _tile_id: int = winner.tile_pos.x * 1000 + winner.tile_pos.y
	var _tile: HexTileData = state.world.tiles.get(_tile_id)
	var _pre_owner: int = _tile.outpost_owner if _tile != null else -1
	if _tile != null:
		OutpostSystem.new().capture(state, winner_id, _tile)
	# Task1 A：此 tile 原 resident=loser 且已翻旗給 winner → 決勝於村（治權隨旗判定於 subjugate 呼叫處）
	var _flip_on_loser_village: bool = _tile != null and _pre_owner == loser_id \
		and _tile.outpost_owner == winner_id
	_skill_sys.on_combat_end(state, winner)
	_skill_sys.on_combat_end(state, loser)
	# E-1：敗方 pop 損耗（對稱 encounter；tier 加權存活）
	var loser_anon: int = AnonCohort.total(loser.anon_cohorts)
	var loser_dead: int = roundi(float(loser_anon) * LOSER_CASUALTY_RATE)
	if loser_dead > 0:
		AnonTierSystem.kill_random(loser, loser_dead, "combat_defeat", AnonTierSystem.SURVIVAL_KILL_WEIGHT)
		if Probe.enabled: Probe.bump("death.combat_pop", loser_dead)
		print("[E1Defeat] Team%d 敗方 pop 損耗 -%d" % [loser_id, loser_dead])
	# 受控人力 P1：征服吸收敗方殘餘 anon → 勝方 captive_group（守恆：loser anon→holder captive；隔離非戰力）
	# Task0 漏斗：決勝戰（殲滅）記 decisive；absorb 成敗 + no_absorb 原因（敗方殘 anon 打光）
	var _loser_anon_pre_absorb: int = AnonCohort.total(loser.anon_cohorts)
	var _captured: int = AnonTierSystem.absorb_as_captive(state, winner, loser, AnonTierSystem.CAPTURE_RATE)
	if Probe.enabled:
		Probe.bump("conq.combat_decisive")
		if _captured > 0:
			Probe.bump("conq.win_absorbed")
		elif _loser_anon_pre_absorb <= 0:
			Probe.bump("conq.win_no_absorb")
			Probe.bump("conq.no_absorb_no_anon")   # 原因：敗方 anon 已 casualty 打光，沒得吸
		else:
			Probe.bump("conq.win_no_absorb")
			Probe.bump("conq.no_absorb_rate_floor")   # 原因：有殘 anon 但 rate*avail floor→0
	if _captured > 0:
		print("[P1Absorb] Team%d 吸收 Team%d 殘餘 anon → captive +%d" % [winner_id, loser_id, _captured])
		_msg.emit_ambient(state, "captives_taken",
			"Team%d 俘獲 Team%d %d人" % [winner_id, loser_id, _captured], winner,
			{"origin": str(winner_id), "loser": str(loser_id), "count": _captured})
		_probe_capture_by_task(winner)   # 征服名實：掠奪隊 vs 攻擊隊 誰達成 capture
	_apply_pursuit(state, winner_id, loser_id)
	var _pp_end: PersonData = state.persons.get(state.player_id)
	var _ptid_end: int = _pp_end.team_id if _pp_end else -1
	if _ptid_end == -1 or winner_id != _ptid_end:
		# Task1 A：決勝於村且敗方村隊存活 → 治權隨旗；滅/走光 → 鬼村（僅翻旗，residency 接手）
		var _village_survives: bool = _flip_on_loser_village \
			and state.teams.has(loser_id) \
			and state.teams[loser_id].population >= GOVERN_SURVIVE_MIN
		if _flip_on_loser_village and not _village_survives and Probe.enabled:
			Probe.bump("yield.flip_ghost")
		_try_subjugate(state, winner_id, loser_id, _village_survives)

# 照妖鏡#1：膽量導出（連續 term，零新 classifier）。好戰高/慎重低→勇；反之→怯。
static func _courage_of(state: WorldState, team: TeamData) -> float:
	var ldr = state.persons.get(team.leader_id)
	if ldr == null: return 0.5
	var martial: float = float(ldr.values.get("好戰", 0.5))
	var caution: float = float(ldr.values.get("慎重", 0.5))
	return clampf(0.5 + (martial - caution) * 0.5, 0.0, 1.0)

# per-team 潰退門檻：勇(courage→1)→門檻低(晚逃血戰)；怯(→0)→門檻高(早逃)。均值(0.5)=BASE。
static func _abandon_threshold(state: WorldState, team: TeamData) -> float:
	if state.persons.get(team.leader_id) == null: return ABANDON_THRESHOLD_BASE
	return ABANDON_THRESHOLD_BASE + (0.5 - _courage_of(state, team)) * ABANDON_COURAGE_SPREAD

# D0 探針：潰退命中瞬間記 readiness，依 courage 分高/中/低三桶（勇者應集中低 readiness=撐到快死才退）。
static func _probe_retreat(state: WorldState, team: TeamData) -> void:
	if not Probe.enabled: return
	Probe.bump("rout.total")
	var c: float = _courage_of(state, team)
	var bucket: String = "high" if c > 0.66 else ("low" if c < 0.34 else "mid")
	Probe.bump("rout.n_" + bucket)
	Probe.add_amount("rout.ready_sum_" + bucket, team.readiness)

func _force_retreat(state: WorldState, retreater_id: int, pursuer_id: int) -> void:
	var retreater: TeamData = state.teams[retreater_id]
	var pursuer: TeamData   = state.teams[pursuer_id]
	state.clear_combat_target(retreater)
	state.clear_combat_target(pursuer)
	# 野獸退場：不走人類 capture/subjugate/pursuit，僅清除參戰獸隊
	if retreater.beast_kind != "" or pursuer.beast_kind != "":
		if retreater.beast_kind != "": BeastSystem.new()._cleanup(state, retreater_id)
		if pursuer.beast_kind != "": BeastSystem.new()._cleanup(state, pursuer_id)
		return
	print("[Exhaust] Team%d 力竭撤退 (rd=%.2f wnd=%d)" % [
		retreater_id, retreater.readiness, retreater.wounded])
	var _tile_id: int = pursuer.tile_pos.x * 1000 + pursuer.tile_pos.y
	var _tile: HexTileData = state.world.tiles.get(_tile_id)
	var _pre_owner_fr: int = _tile.outpost_owner if _tile != null else -1
	if _tile != null:
		OutpostSystem.new().capture(state, pursuer_id, _tile)
	# Task1 A：此 tile 原 resident=retreater 且已翻旗給 pursuer → 決勝於村
	var _flip_on_retreater_village: bool = _tile != null and _pre_owner_fr == retreater_id \
		and _tile.outpost_owner == pursuer_id
	_skill_sys.on_combat_end(state, retreater)
	_skill_sys.on_combat_end(state, pursuer)
	_apply_pursuit(state, pursuer_id, retreater_id)
	# 以戰養戰 PAY（下燒）：潰逃=控地勝方掃過戰場 → loot 撤退者補給（食+資源，rout drop）。
	# 前僅 _end_combat(殲滅) loot；但潰逃佔多數戰局 → 不 loot = 主流戰果零 PAY = 以戰養戰崩。控地即得補給。
	var pursuer_p = state.persons.get(pursuer.leader_id)
	var pursuer_cruelty: float = float(pursuer_p.values.get("殘忍", 0.5)) if pursuer_p else 0.5
	_loot_resources(pursuer, retreater, pursuer_cruelty)
	# 潰逃-capture（spec 下燒：潰逃俘擴）：潰逃殘部（wounded 丟下 + healthy 落單）→ 控地勝方俘一比例。
	# 決勝在潰逃非對撞：潰得越慘(低 readiness)、控地越徹底、俘越多。確定性、守恆（anon→captive 轉移）。
	if state.teams.has(pursuer_id) and state.teams.has(retreater_id):
		var _cap: int = AnonTierSystem.capture_routed_as_captive(state, state.teams[pursuer_id], retreater)
		if Probe.enabled:
			Probe.bump("conq.combat_retreat")   # Task0 漏斗：戰不決勝（潰逃）非殲滅
			Probe.bump("conq.retreat_captured" if _cap > 0 else "conq.retreat_no_capture")
		if _cap > 0:
			print("[Capture] Team%d 控地俘 Team%d 潰逃殘部 +%d (rd=%.2f)" % [
				pursuer_id, retreater_id, _cap, retreater.readiness])
			_msg.emit_ambient(state, "captives_taken",
				"Team%d 俘獲 Team%d 潰逃殘部 %d人" % [pursuer_id, retreater_id, _cap],
				state.teams[pursuer_id],
				{"origin": str(pursuer_id), "loser": str(retreater_id), "count": _cap})
			_probe_capture_by_task(state.teams[pursuer_id])   # 征服名實：掠奪 vs 攻擊 capture 歸因
	var _pp_fr: PersonData = state.persons.get(state.player_id)
	var _ptid_fr: int = _pp_fr.team_id if _pp_fr else -1
	if _ptid_fr == -1 or pursuer_id != _ptid_fr:
		# Task1 A：決勝於村且敗方村隊存活 → 治權隨旗；滅/走光 → 鬼村（僅翻旗，residency 接手）
		var _village_survives_fr: bool = _flip_on_retreater_village \
			and state.teams.has(retreater_id) \
			and state.teams[retreater_id].population >= GOVERN_SURVIVE_MIN
		if _flip_on_retreater_village and not _village_survives_fr and Probe.enabled:
			Probe.bump("yield.flip_ghost")
		_try_subjugate(state, pursuer_id, retreater_id, _village_survives_fr)

# 征服名實探針（純觀測）：capture 事件按勝方 task 歸因。掠奪(TASK_LOOT)達 capture 預期 ~0
# （掠奪=機會搶資源、不奪地俘虜）；真 capture 應來自 prosperity-attack(TASK_ATTACK)。
func _probe_capture_by_task(capturer: TeamData) -> void:
	if not Probe.enabled or capturer == null: return
	Probe.bump("capture.total")
	match capturer.current_task:
		TeamData.TASK_LOOT:   Probe.bump("loot.achieved_capture")
		TeamData.TASK_ATTACK: Probe.bump("capture.by_attack")
		_:                    Probe.bump("capture.by_other")

# 戰場 loot（以戰養戰 PAY）：勝方按 effective_loot 比例奪敗方資源（食+材+幣+貨+武）。守恆走 ResourceBank（in/out 對稱）。
# 殲滅(_end_combat)與潰逃控地(_force_retreat)共用（潰逃佔多數戰局，兩路皆 PAY 才閉以戰養戰環）。
func _loot_resources(winner: TeamData, loser: TeamData, cruelty: float) -> void:
	var effective_loot: float = LOOT_RATE * (1.0 + cruelty * 0.7)
	for res in ["food", "material", "coin", "goods",
				"weapon_melee_low", "weapon_melee_high",
				"weapon_ranged_low", "weapon_ranged_high"]:
		var taken: float = float(loser.resources.get(res, 0)) * effective_loot
		if taken <= 0.0:
			continue
		ResourceBank.add(winner, res, taken, "npc_loot_in")
		ResourceBank.add(loser, res, -taken, "npc_loot_out")

func _apply_pursuit(state: WorldState, winner_id: int, loser_id: int) -> void:
	if not state.teams.has(winner_id) or not state.teams.has(loser_id):
		return
	var winner: TeamData = state.teams[winner_id]
	var loser:  TeamData = state.teams[loser_id]
	if winner.population < loser.population * 2:
		return
	var pursuit_loss: int = maxi(int(float(loser.population) * PURSUIT_RATE), 0)
	if pursuit_loss <= 0:
		return
	_apply_casualties(state, loser_id, pursuit_loss)
	print("[Pursuit] Team%d 追擊 Team%d +%d傷亡" % [winner_id, loser_id, pursuit_loss])

func _try_retreat(state: WorldState, team_id: int, enemy_id: int) -> void:
	var team: TeamData = state.teams[team_id]
	if team.combat_target == -1 or team.current_task != TeamData.TASK_FLEE:
		return
	var leader: PersonData = state.persons.get(team.leader_id)
	var survival: float = 0.5
	if leader != null:
		survival = float(leader.values.get("求生欲", 0.5))
	var str_ratio: float = team_strength(state, team_id) / maxf(team_strength(state, enemy_id), 0.01)
	var retreat_chance: float = survival * 0.5 + (1.0 - minf(str_ratio, 1.0)) * 0.3
	if randf() < retreat_chance:
		var enemy: TeamData = state.teams[enemy_id]
		state.clear_combat_target(team)
		state.clear_combat_target(enemy)
		print("[Retreat] Team%d 成功撤退 (rd=%.2f wnd=%d)" % [team_id, team.readiness, team.wounded])

func _terrain_defense_mult(state: WorldState, team: TeamData) -> float:
	var tile_id: int = team.tile_pos.x * 1000 + team.tile_pos.y
	var tile: HexTileData = state.world.tiles.get(tile_id)
	if tile == null:
		return 1.0
	match tile.terrain:
		"forest":   return 1.2
		"mountain": return 1.15
	return 1.0

func _strength_raw(state: WorldState, team_id: int) -> float:
	var team: TeamData = state.teams.get(team_id)
	if team == null:
		return 0.0
	var leader: PersonData = state.persons.get(team.leader_id)

	var cmd: float = float(leader.skills.get("統領", 0.0)) if leader else 0.0
	var excess: float = clampf((cmd - 0.8) / 0.2, 0.0, 1.0)
	var leadership_mult: float = 1.0 + excess * 0.5

	var tactics: float = float(leader.skills.get("戰術", 0.0)) if leader else 0.0
	var tactics_mult: float = 1.0 + tactics * 0.3

	var melee_str:  float = 0.0
	var ranged_str: float = 0.0
	var named_ids: Array = ([team.leader_id] as Array) + team.named_members
	for pid in named_ids:
		var p: PersonData = state.persons.get(pid)
		if p == null:
			continue
		var grade: String = p.equipment["hand_1"].get("grade", "")
		var wtype: String = grade.replace("weapon_", "") if grade.begins_with("weapon_") else "none"
		match wtype:
			"melee_low":
				melee_str  += (0.5 + float(p.skills.get("戰鬥", 0.0)) * 0.5) * 0.8
			"melee_high":
				melee_str  += (0.5 + float(p.skills.get("戰鬥", 0.0)) * 0.5) * 1.2
			"ranged_low":
				ranged_str += (0.5 + float(p.skills.get("弓箭", 0.0)) * 0.5) * 0.8
			"ranged_high":
				ranged_str += (0.5 + float(p.skills.get("弓箭", 0.0)) * 0.5) * 1.2
			_:
				melee_str  += 0.3

	var named_count: int = named_ids.size()
	var anon_pop: int    = maxi(team.population - team.wounded - named_count, 0)
	# tier-aware：avg_combat_skill 0.1~0.7 → 係數 0.34~0.58（avg 0.5 ≈ 舊 0.5）
	var tier_mult: float = 0.3 + AnonTierSystem.avg_combat_skill(team) * 0.4
	var floored_ratio: float = maxf(team.armed_anon_ratio, ARMED_RATIO_FLOOR)
	melee_str += float(anon_pop) * floored_ratio * tier_mult

	return (melee_str + ranged_str) * leadership_mult * tactics_mult

func _ranged_strength(state: WorldState, team_id: int) -> float:
	var team: TeamData = state.teams.get(team_id)
	if team == null:
		return 0.0
	var ranged_str: float = 0.0
	var named_ids: Array = ([team.leader_id] as Array) + team.named_members
	for pid in named_ids:
		var p: PersonData = state.persons.get(pid)
		if p == null:
			continue
		var grade: String = p.equipment["hand_1"].get("grade", "")
		var wtype: String = grade.replace("weapon_", "") if grade.begins_with("weapon_") else "none"
		match wtype:
			"ranged_low":
				ranged_str += (0.5 + float(p.skills.get("弓箭", 0.0)) * 0.5) * 0.8
			"ranged_high":
				ranged_str += (0.5 + float(p.skills.get("弓箭", 0.0)) * 0.5) * 1.2
	return ranged_str

func _apply_casualties(state: WorldState, team_id: int, count: int) -> void:
	if count <= 0:
		return
	var team: TeamData = state.teams[team_id]
	var named_ids: Array = team.named_members.duplicate()   # MUST duplicate (Array by ref)
	if team.leader_id != -1:
		named_ids.append(team.leader_id)
	var anon_wounded: int = 0
	for i in range(count):
		if not named_ids.is_empty() and randf() < float(named_ids.size()) / maxf(float(team.population), 1.0):
			var idx: int = randi() % named_ids.size()
			var pid: int = named_ids[idx]
			var p = state.persons.get(pid)
			if p != null:
				_hit_person(state, team_id, p)
		else:
			anon_wounded += 1
	AnonTierSystem.wound_random(team, anon_wounded)
	_equip.on_anon_casualties(team, count)

func _hit_person(state: WorldState, team_id: int, p) -> void:
	var part: String = _random_part()
	var cur_idx: int = STATUS_ORDER.find(p.body_parts[part]["status"])
	if cur_idx < 0:
		return
	var vital: bool = part == "head" or part == "torso"
	if cur_idx >= STATUS_ORDER.size() - 1:
		if vital:
			_kill_named_npc(state, team_id, p)
		return
	var new_status: String = STATUS_ORDER[cur_idx + 1]
	p.body_parts[part]["status"] = new_status
	print("[Hit] Person%d %s: %s → %s" % [p.id, part, STATUS_ORDER[cur_idx], new_status])
	if vital and new_status == "critical":
		print("[Critical] Person%d %s 瀕死" % [p.id, part])
	elif not vital and new_status == "severed":
		_kill_named_npc(state, team_id, p)

func _random_part() -> String:
	var roll: float = randf()
	var acc: float = 0.0
	for part in HIT_WEIGHTS:
		acc += HIT_WEIGHTS[part]
		if roll < acc:
			return part
	return "torso"

func _kill_named_npc(state: WorldState, team_id: int, p) -> void:
	var team: TeamData = state.teams[team_id]
	if Probe.enabled: Probe.bump("death.combat_named")
	print("[Death] Person%d (%s) 死亡 (Team%d)" % [p.id, p.person_name, team_id])
	if team.leader_id == p.id:
		var event_system = load("res://scripts/simulation/event_system.gd").new()
		var succeeded: bool = event_system.on_leader_death(state, team)
		if not succeeded and team.faction_id != -1 and state.factions.has(team.faction_id):
			var f = state.factions[team.faction_id]
			if f.leader_team_id == team.team_id:
				state.disband_faction(team.faction_id)
	state.remove_member(team, p.id, false)   # 戰死：出 named（隨後 persons.erase，team_id 免清）
	if team.leader_id == p.id:
		team.leader_id = -1
	var _death_grade: String = p.equipment["hand_1"].get("grade", "")
	var _death_wtype: String = _death_grade.replace("weapon_", "") if _death_grade.begins_with("weapon_") else "none"
	_equip.on_named_death(team, _death_wtype)
	p.equipment["hand_1"] = { "type": "none", "grade": "" }
	# 守恆：死者隨身 coin 退回團（否則 persons.erase 連 coin 一起銷毀）
	if p.coin > 0.0:
		ResourceBank.add(team, "coin", p.coin, "death_coin_return")
		ResourceBank.adjust_person_coin(p, -p.coin, "death_coin_return")
	state.persons.erase(p.id)

func _best_medicine(state: WorldState, team: TeamData) -> float:
	var best: float = 0.0
	var named_ids: Array = team.named_members.duplicate()   # MUST duplicate (Array by ref)
	if team.leader_id != -1:
		named_ids.append(team.leader_id)
	for pid in named_ids:
		var p = state.persons.get(pid)
		if p != null:
			best = maxf(best, float(p.skills.get("醫療", 0.0)))
	return best

# 夜間突襲判定：防守方紮營且無崗哨 → 突襲成功
# TODO: 接入 _try_interact，返回 true 時設 combat_type = "pursuit"
func _check_night_raid(state: WorldState, attacker: TeamData, defender: TeamData) -> bool:
	var dns := DayNightSystem.new()
	if defender.current_task != TeamData.TASK_REST: return false
	if dns.get_camp_vision_range(state, defender) > 0: return false
	return true

func _try_subjugate(state: WorldState, winner_id: int, loser_id: int, on_captured_tile: bool = false) -> void:
	var winner: TeamData = state.teams[winner_id]
	var loser:  TeamData = state.teams[loser_id]
	# Task1 A：翻旗接治權——決勝於村（on_captured_tile）治權隨旗：勝方獨立→以戰立國（授統領 tag），
	# 敗方村隊跨 faction 亦轉入勝方（set_team_faction bidir-safe 退舊入新）→ 同 faction 後 works_tile 放行。
	# 一般吞併（非佔村）維持原 gate：只吞獨立敗方且勝方為統領。
	if on_captured_tile:
		if not winner.tags.has("統領"):
			winner.tags.append("統領")
	elif loser.faction_id != -1 or not winner.tags.has("統領"):
		return
	var fid: int = winner.faction_id
	if fid == -1:
		fid = state.create_faction(winner_id)
	if fid == -1 or loser.faction_id == fid:
		return   # 立國失敗 / 已同 faction（與翻旗接治權去重，勿雙 subjugate）
	# A feud：吞併 → loser leader 結仇 + 原 faction 餘部繼承。
	# 必在 set_team_faction 前（否則 loser 已入勝方 faction，抓錯餘部）。
	var loser_leader: PersonData = state.persons.get(loser.leader_id)
	NpcAiSystem.form_feud(loser_leader, winner.leader_id,
		NpcAiSystem.FEUD_SEVERITY["subjugated"], state.world.current_tick)
	NpcAiSystem.spread_feud(state, loser, winner.leader_id,
		NpcAiSystem.FEUD_SEVERITY["subjugated"], state.world.current_tick)
	state.set_team_faction(loser, fid)   # 敗方入勝方 faction（雙向同步）
	state.snapshot_faction_member(loser_id, state.world.current_tick)
	if Probe.enabled and on_captured_tile:
		Probe.bump("yield.flip_with_rule")   # 翻旗+治權接上（同 faction → 村民代 owner 生產）
	_msg.emit_message(state, "subjugate",
		TextBank.fmt("subjugate", "honest", {
			"origin": str(winner_id), "loser": str(loser_id), "faction": str(fid)
		}),
		winner,
		{ "origin": str(winner_id), "loser": str(loser_id), "faction": str(fid) })
	print("[Faction] Team%d 主服 Team%d → 勢力%d%s" % [
		winner_id, loser_id, fid, "（佔村立治）" if on_captured_tile else ""])
