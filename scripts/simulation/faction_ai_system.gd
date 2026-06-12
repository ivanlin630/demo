class_name FactionAISystem

const COLLECT_INTERVAL:        int = 30 * WorldState.TICKS_PER_HOUR  # 每 30 小時
const FACTION_UPDATE_INTERVAL: int = 20 * WorldState.TICKS_PER_HOUR  # 每 20 小時
const DISPATCH_DIST_THRESHOLD: int   = 2
const FOOD_EMERGENCY: float          = 3.0
const ESTABLISH_COMMAND: float       = 0.4
const ESTABLISH_AMBITION: float      = 0.7
const ESTABLISH_READINESS: float     = 0.7
const DIPLOMACY_READINESS_MIN: float = 0.6
const DISCIPLINE_FAIL_BASE: float    = 0.15
const MANUFACTURE_MATERIAL_MIN: float = 30.0
const TRADE_MIN_STOCK: float          = 10.0   # 商隊最低持貨（有貨才出門）
const TRADE_MIN_COIN: float           = 5.0    # 買方最低 coin 門檻
const HONOR_INTERVAL_MULT: float  = 0.5   # honor=1.0 → 徵收週期 ×1.5（義氣高 → 少收稅）
const HONOR_EMERGENCY_DISC: float = 0.3   # honor=1.0 → emergency 門檻 ×0.7（義氣高 → 緊急門檻降低）
const LOOT_SCORE_THRESHOLD: float = 0.35  # TEST VALUE — 掠奪 goal 分數門檻
const LOOT_READINESS_MIN: float   = 0.6   # TEST VALUE — 掠奪需要的最低 readiness
const DEVIATION_RATE: float       = 0.05  # TEST VALUE — 子團偏離基礎概率
const SMALL_TEAM_RATIO: float     = 0.3   # TEST VALUE — pop < cap×0.3 視為小隊
const SMALL_VS_LARGE: float       = 0.33  # TEST VALUE — pop < absorber.pop×0.33 才觸發合併
const CONSOLIDATE_MAX_DIST: int   = 3     # TEST VALUE — 戰前集結距離上限（hex）
const ATTACK_SCORE_THRESHOLD:  float = 0.3   # minimum attack_score to pursue 攻擊 goal
const ATTACK_READINESS_MIN:    float = 0.75  # readiness required for attack goal
const ATTACK_STRENGTH_RATIO:   float = 0.8   # own_armed must be >= enemy_armed * this
const DIPLOMACY_AMBITION_DISC: float = 0.2   # how much ambition shifts diplomacy readiness req
const SURVIVAL_TASKS: Array = ["return_home", "乞食", "投靠"]
# stuck: task 仍是進攻型但 move_target 已被 movement 清掉（off-map / 無路徑）→ 視為 idle 允許重評
const STUCK_TASKS: Array = [TeamData.TASK_ATTACK, TeamData.TASK_LOOT]

static func _is_stuck(team: TeamData) -> bool:
	return team.current_task in STUCK_TASKS and team.move_target == Vector2i(-1, -1)
const CONTACT_TIMEOUT_DAYS: int = 30
const OWNER_CHANGE_BUFFER_DAYS: int = 7
const FOOD_PER_PERSON_PER_DAY_SURVIVAL: float = 2.4
const URGENCY_DAYS: float = 1.0
const WARNING_DAYS: float = 3.0

# ── Prosperity attack（野心驅動主動征服）──
const PROSPERITY_CADENCE: int = 720           # 3 天 評估一次
const PROSPERITY_CADENCE_MILITARY: int = 360  # 軍隊 tag 1.5 天
const ANON_TREASURY_BONUS_THRESHOLD: float = 200.0  # 公庫滿 → attack_score +0.1

# ── Threat response（被動威脅反應）──
const THREAT_CADENCE: int = 240   # 1 日 評估一次威脅
const TRADE_TIMEOUT: int = 1440   # 貿易 task 6 日未成交 → 放棄（防 zombie）

# ── Outpost 居民派駐 AI ──
const RESIDENCY_CADENCE: int = 720    # 3 天 評估一次 outpost 居民派駐
const RESIDENCY_COOLDOWN: int = 1680  # 7 天 邀請被拒後冷卻
const MIN_PARENT_POP_AFTER_DISPATCH: int = 10

const TRADEABLE_RES: Array = [
	"food", "material", "goods", "gem",
	"ore_gold", "ore_silver", "ore_iron", "ore_steel",
	"weapon_melee_low", "weapon_melee_high",
	"weapon_ranged_low", "weapon_ranged_high",
]

const OUTPOST_POP_CAP: Dictionary = {
	"civilian": [20, 50, 100],   # L1, L2, L3
	"military": [15, 35, 70],
}

# ── Prosperity helpers（static，純函數，可單測）──
static func calc_readiness_threshold(team: TeamData, leader: PersonData) -> float:
	var ferocity: float = maxf(
		float(leader.values.get("殘忍", 0.5)),
		float(leader.values.get("好戰", 0.5))
	)
	var caution: float = float(leader.values.get("慎重", 0.5))
	var threshold: float = 0.55 - ferocity * 0.15 + caution * 0.15
	if "軍隊" in team.tags:
		threshold -= 0.1
	return clampf(threshold, 0.3, 0.85)

static func calc_readiness(team: TeamData) -> float:
	var pop_factor: float = clampf(float(team.population) / 10.0, 0.0, 1.0)
	var skill: float = team.anon_combat_skill
	var food_days: float = float(team.resources.get("food", 0)) \
		/ maxf(float(team.population) * FOOD_PER_PERSON_PER_DAY_SURVIVAL, 0.001)
	var food_factor: float = clampf(food_days / 14.0, 0.0, 1.0)
	var weapon: float = float(team.resources.get("weapon_melee_low", 0))
	var weapon_factor: float = clampf(weapon / maxf(float(team.population), 1.0), 0.0, 1.0)
	return (pop_factor + skill + food_factor + weapon_factor) / 4.0

static func calc_attack_score(team: TeamData, leader: PersonData) -> float:
	var ambition: float = float(leader.values.get("野心", 0.5))
	var martial: float = float(leader.values.get("好戰", 0.5))
	var honor: float = float(leader.values.get("信義", 0.5))
	var base: float = ambition * 0.4 + martial * 0.4 - honor * 0.4
	if team.anon_treasury > ANON_TREASURY_BONUS_THRESHOLD:
		base += 0.1
	return base

static func find_prosperity_prey(state: WorldState, team: TeamData, leader: PersonData) -> int:
	var greed: float = float(leader.values.get("貪婪", 0.5))
	var cruelty: float = float(leader.values.get("殘忍", 0.5))
	var ambition: float = float(leader.values.get("野心", 0.5))
	var best_id: int = -1
	var best_score: float = 0.0
	for tid in state.team_discovered.get(team.team_id, []):
		if tid == team.team_id: continue
		var prey: TeamData = state.teams.get(tid)
		if prey == null: continue
		if prey.faction_id != -1 and prey.faction_id == team.faction_id: continue
		var catch_result: Dictionary = PathSystem.estimate_catch_up(state, team, tid)
		if not catch_result.reachable: continue
		var richness: float = (float(prey.resources.get("coin", 0))
			+ float(prey.resources.get("food", 0))
			+ float(prey.resources.get("material", 0))) / 100.0
		var weakness: float = clampf(
			1.0 - float(prey.population) / maxf(float(team.population), 1.0),
			0.0, 1.0)
		var border: float = 1.0 if _is_border_adjacent(team, prey) else 0.3
		var eta_days: float = maxf(float(catch_result.eta) / 240.0, 1.0)
		var score: float = (richness * greed + weakness * cruelty + border * ambition) / eta_days
		if score > best_score:
			best_score = score
			best_id = tid
	return best_id

static func _is_border_adjacent(attacker: TeamData, prey: TeamData) -> bool:
	var dx: int = prey.tile_pos.x - attacker.tile_pos.x
	var dy: int = prey.tile_pos.y - attacker.tile_pos.y
	return (abs(dx) + abs(dx + dy) + abs(dy)) / 2 <= 2

func _evaluate_prosperity_attack(state: WorldState, team: TeamData) -> void:
	if team.leader_id == state.player_id and state.player_id != -1: return
	if team.combat_target != -1: return
	# stuck（task=攻擊/掠奪 但 move_target 已清）視為 idle，允許重評換目標
	if team.current_task != TeamData.TASK_IDLE and not _is_stuck(team): return
	if team.current_task in SURVIVAL_TASKS: return
	var leader: PersonData = state.persons.get(team.leader_id)
	if leader == null: return

	var score: float = calc_attack_score(team, leader)
	if score < ATTACK_SCORE_THRESHOLD: return

	var threshold: float = calc_readiness_threshold(team, leader)
	var readiness: float = calc_readiness(team)
	if readiness < threshold: return

	var prey_id: int = find_prosperity_prey(state, team, leader)
	if prey_id == -1: return

	# combat_target 不預設：移動凍結 + interaction 早退會擋住交戰；
	# 由 interaction_system 到達時 start_combat 設定。只給 task + move_target + 追擊目標。
	if _is_stuck(team):
		TaskArbiter.release(team)   # stuck 釋放讓位，同層才能重評換目標
	if TaskArbiter.try_set(state, team, TeamData.TASK_ATTACK,
			state.teams[prey_id].tile_pos, TaskArbiter.PRIO_DISPATCH, "prosperity"):
		team.prosperity_target_id = prey_id
		print("[ProsperityAttack] attacker=Team%d prey=Team%d score=%.2f" % [
			team.team_id, prey_id, score])

# 追擊：攻擊/掠奪 中每 tick 依 intel 最後已知位置刷新 move_target（移動目標會跑）
# 與 strategic_ai 的 team_intel 追蹤同模式（strategic_ai_system.gd:107）
func _refresh_attack_pursuit(state: WorldState, team: TeamData) -> void:
	if team.combat_target != -1: return
	if team.current_task != TeamData.TASK_ATTACK and team.current_task != TeamData.TASK_LOOT:
		team.prosperity_target_id = -1
		return
	if team.prosperity_target_id == -1: return
	var prey: TeamData = state.teams.get(team.prosperity_target_id)
	if prey == null:   # 目標已滅 → 收手
		team.prosperity_target_id = -1
		TaskArbiter.release(team)
		return
	# C: 攻擊追擊用攔截預測（朝 prey 移動方向提前 N 步），視野外/不動 fallback intel 最後已知
	var last_pos: Vector2i = state.team_intel.get(team.team_id, {}).get(
		team.prosperity_target_id, {}).get("tile_pos", prey.tile_pos)
	var predicted: Vector2i = PathSystem.predict_intercept(state, team, prey)
	team.move_target = predicted if predicted != prey.tile_pos else last_pos

# ──────── D: 被動威脅反應 ────────

# 威脅評估（cadence）：找視野內最高 threat，超門檻 → dispatch 反應。
# 已在反應 task 中則重評威脅是否仍在，無則回 idle。
func _evaluate_threat(state: WorldState, team: TeamData) -> void:
	if state.world.current_tick < team.threat_eval_next_tick: return
	team.threat_eval_next_tick = state.world.current_tick + THREAT_CADENCE
	if team.combat_target != -1: return
	if team.current_task == "起義":
		# 起義（流亡路徑）是瞬時事件，結算已完成 → 釋放回常規 AI
		#（若有追兵，下次 cadence threat 評估會派逃跑）
		TaskArbiter.release(team)
		return
	if team.current_task in [TeamData.TASK_DEFEND, TeamData.TASK_PREPARE, TeamData.TASK_FLEE, "守城"]:
		if not _has_active_threat(state, team):
			TaskArbiter.release(team)
		return
	# 不打斷其他進行中 task（只有 idle 才主動評威脅）
	if team.current_task != TeamData.TASK_IDLE: return
	var leader: PersonData = state.persons.get(team.leader_id)
	if leader == null: return
	var caution: float = float(leader.values.get("慎重", 0.5))
	var threshold: float = ThreatAssessment.THREAT_BASE_THRESHOLD + caution * 0.3
	var best_threat: float = 0.0
	var best_id: int = -1
	for tid in state.team_discovered.get(team.team_id, []):
		if tid == team.team_id: continue
		var other: TeamData = state.teams.get(tid)
		if other == null: continue
		var t: float = ThreatAssessment.score(state, team, other)
		if t > best_threat:
			best_threat = t
			best_id = tid
	if best_threat < threshold: return
	_dispatch_threat_response(state, team, best_id, best_threat)

func _has_active_threat(state: WorldState, team: TeamData) -> bool:
	for tid in state.team_discovered.get(team.team_id, []):
		var other: TeamData = state.teams.get(tid)
		if other == null: continue
		var t: float = ThreatAssessment.score(state, team, other)
		if t > ThreatAssessment.THREAT_BASE_THRESHOLD:
			return true
	return false

# 依 leader 性格評 4 反應（逃跑/備戰/求和/迎戰），居民團不可迎戰。
func _dispatch_threat_response(state: WorldState, team: TeamData,
		threat_id: int, threat_score: float) -> void:
	var leader: PersonData = state.persons.get(team.leader_id)
	if leader == null: return
	var survival: float = float(leader.values.get("求生欲", 0.5))
	var martial: float = float(leader.values.get("好戰", 0.5))
	var caution: float = float(leader.values.get("慎重", 0.5))
	var greed: float = float(leader.values.get("貪婪", 0.5))
	var honor: float = float(leader.values.get("信義", 0.5))
	var is_resident: bool = _is_resident_team(state, team)
	var scores: Dictionary = {
		TeamData.TASK_FLEE: survival * 0.8 + (threat_score - 0.5) * 0.3,
		TeamData.TASK_PREPARE: caution * 0.6 + martial * 0.3,
		"求和": greed * 0.5 + honor * 0.3 - martial * 0.3,
	}
	if not is_resident:
		scores[TeamData.TASK_DEFEND] = martial * 0.7 + (1.0 - threat_score) * 0.2
	var best: String = ""
	var best_score: float = -INF
	for action in scores:
		if scores[action] > best_score:
			best_score = scores[action]
			best = action
	var other: TeamData = state.teams.get(threat_id)
	if other == null: return
	match best:
		TeamData.TASK_FLEE:
			if not TaskArbiter.try_set(state, team, TeamData.TASK_FLEE,
					_flee_target(state, team, other), TaskArbiter.PRIO_THREAT, "threat"):
				return
		TeamData.TASK_DEFEND:
			if not TaskArbiter.try_set(state, team, TeamData.TASK_DEFEND,
					other.tile_pos, TaskArbiter.PRIO_THREAT, "threat"):
				return
			team.prosperity_target_id = threat_id
		TeamData.TASK_PREPARE:
			if not TaskArbiter.try_set(state, team, TeamData.TASK_PREPARE,
					Vector2i(-1, -1), TaskArbiter.PRIO_THREAT, "threat"):
				return
		"求和":
			if not TaskArbiter.try_set(state, team, TeamData.TASK_DIPLOMACY,
					other.tile_pos, TaskArbiter.PRIO_THREAT, "threat"):
				return
			team.order_target_id = threat_id
			team.order_task = "tribute_offer"
	print("[ThreatResponse] Team%d → %s (threat=Team%d, score=%.2f)" % [
		team.team_id, best, threat_id, best_score])

func _flee_target(state: WorldState, team: TeamData, threat: TeamData) -> Vector2i:
	# 朝反方向走 3 hex
	var dir: Vector2i = team.tile_pos - threat.tile_pos
	var pos: Vector2i = team.tile_pos + Vector2i(sign(dir.x), sign(dir.y)) * 3
	if state.world.tiles.has(pos.x * 1000 + pos.y):
		return pos
	return team.tile_pos

func _is_prosperity_candidate(state: WorldState, team: TeamData) -> bool:
	if team.parent_team_id != -1: return false   # 子隊不主動發動
	if team.faction_id == -1: return true          # 獨立團
	var f = state.factions.get(team.faction_id)
	return f != null and f.leader_team_id == team.team_id

# 事件觸發立即重評（新發現 / pop 暴跌 / 性格改變）
static func mark_prosperity_recheck(state: WorldState, observer_team_id: int) -> void:
	var t: TeamData = state.teams.get(observer_team_id)
	if t != null:
		t.prosperity_eval_next_tick = state.world.current_tick

func _outpost_pop_cap(state: WorldState, pos: Vector2i) -> int:
	var tile: HexTileData = state.world.tiles.get(pos.x * 1000 + pos.y)
	if tile == null or tile.outpost_level == 0: return 0
	var arr: Array = OUTPOST_POP_CAP.get(tile.outpost_type, [10, 20, 40])
	return int(arr[clampi(tile.outpost_level - 1, 0, 2)])

func _is_resident_team(state: WorldState, team: TeamData) -> bool:
	if not team.tags.has(TeamData.TAG_PRODUCE):
		return false
	var tile: HexTileData = state.world.tiles.get(team.tile_pos.x * 1000 + team.tile_pos.y)
	if tile == null or tile.outpost_level == 0:
		return false
	var owner_id: int = tile.outpost_owner
	if owner_id == team.team_id:
		return true
	if owner_id == -1:
		return false
	var owner: TeamData = state.teams.get(owner_id)
	if owner == null:
		return false
	return owner.faction_id == team.faction_id and team.faction_id != -1

# ──────── Outpost 居民派駐 AI ────────

# tile 上是否已有 PRODUCE（居民）team（任一 faction）
func _has_resident_team_on_tile(state: WorldState, tile: HexTileData) -> bool:
	for tid in state.teams:
		var t: TeamData = state.teams[tid]
		if t.tile_pos != tile.tile_pos: continue
		if "生產" in t.tags: return true
	return false

# 是否已有 in-flight 子隊朝該 outpost 安頓中（避免重派 spam）
func _has_inflight_settler(state: WorldState, owner: TeamData, tile: HexTileData) -> bool:
	for tid in state.teams:
		var t: TeamData = state.teams[tid]
		if t.team_id == owner.team_id: continue
		if t.faction_id != owner.faction_id: continue
		if not ("子團" in t.tags): continue
		if t.current_task != "安頓": continue
		if t.move_target != tile.tile_pos: continue
		return true
	return false

# cadence 評估：掃自家無居民 outpost，依個性派子隊或邀流亡
func _evaluate_outpost_residency(state: WorldState, team: TeamData) -> void:
	if state.world.current_tick < team.residency_eval_next_tick: return
	team.residency_eval_next_tick = state.world.current_tick + RESIDENCY_CADENCE
	var leader: PersonData = state.persons.get(team.leader_id)
	if leader == null: return
	for tile_id in state.world.tiles:
		var tile: HexTileData = state.world.tiles[tile_id]
		if tile.outpost_owner != team.team_id: continue
		if _has_resident_team_on_tile(state, tile): continue
		if _has_inflight_settler(state, team, tile): continue   # 新增
		_try_dispatch_or_invite(state, team, tile, leader)

# 個性決定管道：野心/好戰 → 派子隊；商業/慎重 → 邀流亡
func _try_dispatch_or_invite(state: WorldState, team: TeamData,
		tile: HexTileData, leader: PersonData) -> void:
	var ambition: float = float(leader.values.get("野心", 0.5))
	var military: float = float(leader.values.get("好戰", 0.5))
	var commerce: float = float(leader.skills.get("商業", 0.0))
	var caution: float = float(leader.values.get("慎重", 0.5))
	var dispatch_score: float = ambition * 0.5 + military * 0.3
	var invite_score: float = commerce * 0.4 + caution * 0.3
	if tile.outpost_type == "military":
		# 軍屯：只信任自己人（軍火庫不交給流民），無 invite fallback
		if dispatch_score > invite_score and team.population >= 8:
			_dispatch_subteam_settle(state, team, tile)
		return
	if dispatch_score > invite_score and team.population >= 8:
		_dispatch_subteam_settle(state, team, tile)
	else:
		_try_invite_nearby_exile(state, team, tile)

# 派子隊安頓：抵達 outpost → interaction "安頓" handler → _convert_to_resident
func _dispatch_subteam_settle(state: WorldState, owner: TeamData, tile: HexTileData) -> void:
	var settler_count: int = clampi(owner.population / 4, 2, 5)
	if owner.population - settler_count < MIN_PARENT_POP_AFTER_DISPATCH: return
	var sub_leader_id: int = -1
	if owner.named_members.size() > 2:
		sub_leader_id = int(owner.named_members[0])
	else:
		# 無多餘 named → 升一名 anon 為 sub leader（dispatch 要求 leader ∈ named_members）
		var new_leader: PersonData = PersonGenerator.generate_for_team(
			state, owner, "member")
		if new_leader != null:
			owner.named_members.append(new_leader.id)
			sub_leader_id = new_leader.id
	if sub_leader_id == -1: return
	var subteam_id: int = SubteamSystem.new().dispatch(
		state, owner.team_id, sub_leader_id, settler_count, "安頓", tile.tile_pos)
	if subteam_id == -1: return
	print("[Residency] Team%d 派子隊 Team%d 安頓 outpost (%d,%d) pop=%d" % [
		owner.team_id, subteam_id, tile.tile_pos.x, tile.tile_pos.y, settler_count])

# 邀視野內流亡團安頓；個性接受 → task=安頓 + 長 cooldown，拒絕 → 7 天 cooldown
func _try_invite_nearby_exile(state: WorldState, team: TeamData, tile: HexTileData) -> void:
	for tid in state.team_discovered.get(team.team_id, []):
		var t: TeamData = state.teams.get(tid)
		if t == null: continue
		if not ("流亡" in t.tags): continue
		if t.current_task == "安頓": continue   # 已在路上，不重邀
		if state.world.current_tick < int(team.invite_cooldown.get(tid, 0)): continue
		var dipl := DiplomaticAiSystem.new()
		var resp: String = dipl.handle_diplomacy_message(
			state, t, team, "invite_settle")
		if resp == "accept" and TaskArbiter.try_set(state, t, "安頓",
				tile.tile_pos, TaskArbiter.PRIO_DISPATCH, "invite_settle"):
			team.invite_cooldown[tid] = state.world.current_tick + RESIDENCY_COOLDOWN * 4   # 等 settle 流程
			print("[Residency] Team%d 邀請 Team%d 安頓 outpost (%d,%d)" % [
				team.team_id, tid, tile.tile_pos.x, tile.tile_pos.y])
			return
		team.invite_cooldown[tid] = state.world.current_tick + RESIDENCY_COOLDOWN

const MOUNT_TARGET_RATIO: float = 0.5

# NPC 出征前自動從自家 outpost 公庫拉 mount 至 population × ratio
# 註：spec 原列 TASK_PREPARE，但 TeamData 無此 task，改以 idle 為唯一不出征狀態
func _auto_withdraw_mounts(state: WorldState, team: TeamData) -> void:
	if team.current_task == TeamData.TASK_IDLE:
		return
	var tile: HexTileData = state.world.tiles.get(
		team.tile_pos.x * 1000 + team.tile_pos.y)
	if tile == null or tile.outpost_owner != team.team_id:
		return
	var available: int = int(tile.public_storage.get("mounts", 0))
	if available <= 0:
		return
	var current: int = int(team.resources.get("mounts", 0))
	var target: int = int(float(team.population) * MOUNT_TARGET_RATIO)
	var need: int = maxi(target - current, 0)
	var take: int = mini(need, available)
	if take > 0:
		tile.public_storage["mounts"] = available - take
		team.resources["mounts"] = current + take
		print("[Mount] Team%d auto-withdraw %d mounts" % [team.team_id, take])

func evaluate_all(state: WorldState, _team_ids: Array) -> void:
	for fid in state.factions:
		var f = state.factions[fid]
		for mid in f.member_team_ids:
			var snap: Dictionary = state.team_intel.get(f.leader_team_id, {}).get(mid, {})
			if not snap.is_empty():
				f.known_member_states[mid] = snap
		_update_goals(state, f)
		_assign_tasks(state, f)
		# C: 每 INFRA_INTERVAL 評估一次基建（蓋/升級/擴建）
		if state.world.current_tick % INFRA_INTERVAL == 0:
			_evaluate_infrastructure(state, f)
		# 每 20 小時評估一次主動外交
		if state.world.current_tick % FACTION_UPDATE_INTERVAL == 0:
			var _leader_team: TeamData = state.teams.get(f.leader_team_id)
			if _leader_team != null:
				DiplomaticAiSystem.new().try_proactive_diplomacy(state, _leader_team)
		# 每 BETRAY_CHECK_INTERVAL tick 評估結盟 team 背叛
		if state.world.current_tick % DiplomaticAiSystem.BETRAY_CHECK_INTERVAL == 0:
			var leader_team_b: TeamData = state.teams.get(f.leader_team_id)
			if leader_team_b == null: continue
			for tid in f.member_team_ids.duplicate():  # duplicate: _execute_betrayal may erase during iteration
				if tid == f.leader_team_id: continue
				var member_team: TeamData = state.teams.get(tid)
				if member_team:
					DiplomaticAiSystem.new().consider_betrayal(state, member_team, leader_team_b)

	var merge_queue: Array = []
	for tid in state.teams:
		var team: TeamData = state.teams[tid]
		if team.parent_team_id != -1:
			_evaluate_subteam(state, team, merge_queue)
		elif team.faction_id == -1:
			_evaluate_solo(state, team)

	var sub_sys := SubteamSystem.new()
	for sub_id in merge_queue:
		if not state.teams.has(sub_id):
			continue
		var sub: TeamData = state.teams[sub_id]
		if sub.parent_team_id == -1:
			continue
		var parent: TeamData = state.teams.get(sub.parent_team_id)
		if parent != null and parent.tile_pos == sub.tile_pos:
			sub_sys.try_merge_back(state, sub_id)
		else:
			TaskArbiter.release(sub)
			if parent != null:
				sub.move_target = parent.tile_pos

	for tid in state.teams:
		if not state.teams.has(tid):
			continue
		var team: TeamData = state.teams[tid]
		# 滅團遺財：population<=0 且仍有資產 → 轉公庫 / abandoned_coin（idempotent）
		if team.population <= 0 and (team.anon_treasury > 0.0 or not team.resources.is_empty()):
			_on_team_extinct(state, team)
			continue
		# S11: leader 死亡自動繼承（無 leader 但有 named members）
		if team.leader_id == -1 and not team.named_members.is_empty():
			_promote_successor(state, team)
		# B: 生存決策（在其他 update 前評估，task 改完後 strategic_ai 看到 sticky 不蓋）
		_evaluate_survival(state, team)
		# A: prosperity attack（野心驅動主動征服，cadence + 軍隊加速）
		if _is_prosperity_candidate(state, team) \
				and state.world.current_tick >= team.prosperity_eval_next_tick:
			_evaluate_prosperity_attack(state, team)
			var cad: int = PROSPERITY_CADENCE_MILITARY if "軍隊" in team.tags else PROSPERITY_CADENCE
			team.prosperity_eval_next_tick = state.world.current_tick + cad
		# 追擊刷新（攻擊/掠奪 中移動目標會跑，每 tick 對齊 intel）
		_refresh_attack_pursuit(state, team)
		# D: 被動威脅評估（cadence 內部控管）
		_evaluate_threat(state, team)
		# W2: 貿易 task timeout 防 zombie（追不到 / 對方消失）
		if team.current_task == TeamData.TASK_TRADE \
				and state.world.current_tick - team.trade_task_start_tick > TRADE_TIMEOUT:
			TaskArbiter.release(team)
		# 公庫徵用：每月一次依 leader 貪婪評估
		if state.world.current_tick % WorldState.TICKS_PER_MONTH == 0:
			_consider_extraction(state, team)
		# D B2: 無人 outpost 駐留接管
		_evaluate_outpost_takeover(state, team)
		# 居民派駐：自家無居民 outpost → 派子隊/邀流亡（cadence 內控）
		_evaluate_outpost_residency(state, team)
		if _is_resident_team(state, team):
			_evaluate_uprising(state, team)
			_evaluate_owner_contact(state, team)
		_update_equip_order(state, team)
		# anon_combat_skill / anon_wage 改 computed（AnonTierSystem），不再主動更新
		_update_armor_config(team)
		_update_guard_ratio(team, state)
		# 出征前自動從自家 outpost 公庫拉 mount
		_auto_withdraw_mounts(state, team)

# ──────── Tag 權限 ────────

func _tag_weight(team: TeamData, task: String) -> float:
	if task in ["idle", "逃跑"]: return 1.0
	if team.tags.has("統領") or team.tags.has("子團"): return 1.0
	if team.tags.has("流亡"): return 0.0
	var task_tags: Dictionary = {
		"攻擊":  ["軍隊"],
		"掠奪":  ["軍隊"],
		"徵收":  ["軍隊", "統領"],
		"護衛":  ["軍隊", "商隊"],
		"偵查":  ["軍隊", "商隊"],
		"外交":  ["商隊", "宗教"],
		"信使":  ["軍隊", "商隊", "生產", "宗教"],
		"生產":  ["生產"],
		"製造":  ["生產"],
		"貿易":  ["商隊"],
		"巡邏":  ["軍隊", "統領"],
	}
	var required: Array = task_tags.get(task, [])
	if required.is_empty(): return 1.0
	for tag in required:
		if team.tags.has(tag): return 1.0
	return 0.0 if team.tags.size() > 0 else 0.5

# ──────── 目標評估 ────────

func _update_goals(state: WorldState, f) -> void:
	f.goals.clear()
	var leader_team: TeamData = state.teams.get(f.leader_team_id)
	if leader_team == null:
		return

	# G-09：玩家設定 override → 跳過自動計算，直接套用
	if not f.player_goal_override.is_empty():
		f.goals.append(f.player_goal_override)
		return

	var leader_p = state.persons.get(leader_team.leader_id)
	var ambition: float = float(leader_p.values.get("野心",   0.5)) if leader_p else 0.5
	var greed:    float = float(leader_p.values.get("貪婪",   0.5)) if leader_p else 0.5
	var survival: float = float(leader_p.values.get("求生欲", 0.5)) if leader_p else 0.5
	var honor:    float = float(leader_p.values.get("義氣",   0.5)) if leader_p else 0.5
	var martial:  float = float(leader_p.values.get("好戰",   0.5)) if leader_p else 0.5

	var food_per_cap: float = float(leader_team.resources.get("food", 0)) / maxf(leader_team.population, 1)
	var effective_emergency: float = FOOD_EMERGENCY * (0.7 + survival * 0.6) \
		* clampf(1.0 - honor * HONOR_EMERGENCY_DISC, 0.5, 1.0)
	var effective_interval:  int   = maxi(
		int(COLLECT_INTERVAL * (1.5 - greed) * (1.0 + honor * HONOR_INTERVAL_MULT)), 10)

	if food_per_cap < effective_emergency:
		f.goals.append("徵收")
		f.strategy = "緊急徵收"
	elif state.world.current_tick % effective_interval == 0:
		f.goals.append("徵收")
		f.strategy = "定期徵收"
	else:
		f.strategy = "idle"

	if not f.is_established and f.member_team_ids.size() >= 2:
		if leader_p != null:
			var cmd: float = float(leader_p.skills.get("統領", 0.0))
			var ambition_discount: float = (ambition - 0.5) * 0.2
			if cmd >= ESTABLISH_COMMAND - ambition_discount \
					and ambition >= ESTABLISH_AMBITION - 0.1 \
					and leader_team.readiness >= ESTABLISH_READINESS:
				f.goals.append("立國")

	var diplomacy_readiness: float = clampf(
		DIPLOMACY_READINESS_MIN - (ambition - 0.5) * DIPLOMACY_AMBITION_DISC, 0.3, 0.9)
	if f.is_established and leader_team.readiness >= diplomacy_readiness:
		if _has_independent(state, f.leader_team_id):
			f.goals.append("外交")

	var attack_score: float = ambition * 0.4 + martial * 0.4 - honor * 0.4
	if f.is_established and attack_score > ATTACK_SCORE_THRESHOLD \
			and leader_team.readiness >= ATTACK_READINESS_MIN \
			and _has_independent(state, f.leader_team_id) \
			and _tag_weight(leader_team, "攻擊") > 0.0:
		var target_id: int = _nearest_independent(state, leader_team)
		if target_id != -1:
			var tgt_snap: Dictionary = state.team_intel.get(f.leader_team_id, {}).get(target_id, {})
			var tgt_armed: int = int(tgt_snap.get("armed_est", 999))  # 未知視為強敵
			var own_armed: int = _calc_own_armed(state, leader_team)
			for mid in f.known_member_states:
				if mid == f.leader_team_id: continue
				var ms: Dictionary = f.known_member_states[mid]
				if ms.get("current_task", "") == "攻擊":
					own_armed += int(ms.get("armed_est", 0))
			if float(own_armed) >= float(tgt_armed) * ATTACK_STRENGTH_RATIO:
				f.goals.append("攻擊")
		else:
			f.goals.append("攻擊")

	var loot_score: float = greed * 0.5 + martial * 0.3 - honor * 0.3
	if f.is_established and loot_score > LOOT_SCORE_THRESHOLD \
			and leader_team.readiness >= LOOT_READINESS_MIN \
			and _has_independent(state, f.leader_team_id) \
			and _tag_weight(leader_team, "掠奪") > 0.0:
		f.goals.append("掠奪")
	# TODO: "合併" goal — 由 leader 手動指派 order_target_id，FactionAI 目前不自動觸發

# ──────── 任務指派 ────────

func _assign_tasks(state: WorldState, f) -> void:
	var leader_team: TeamData = state.teams.get(f.leader_team_id)
	if leader_team == null or leader_team.combat_target != -1:
		return
	# 生存 sticky：leader 在 survival task 中不蓋過（仍跑 member 指派）
	if leader_team.current_task in SURVIVAL_TASKS:
		_assign_member_tasks(state, f)
		return

	# G-09：檢查 player_commanded_task（loyalty 門檻）
	for tid_cmd in f.member_team_ids:
		var t_cmd: TeamData = state.teams.get(tid_cmd)
		if t_cmd == null or t_cmd.player_commanded_task.is_empty(): continue
		var leader_cmd: PersonData = state.persons.get(t_cmd.leader_id)
		var loyalty_cmd: float = leader_cmd.loyalty if leader_cmd else 0.5
		if loyalty_cmd >= 0.4:
			TaskArbiter.try_set(state, t_cmd, t_cmd.player_commanded_task,
				t_cmd.move_target, TaskArbiter.PRIO_PLAYER, "player_command")
		else:
			t_cmd.unrest_turns += 1
			print("[FactionAI] Team%d 抗拒玩家指令（loyalty=%.2f）" % [tid_cmd, loyalty_cmd])

	if "徵收" in f.goals and leader_team.current_task != "徵收":
		var best_tid: int = _richest_member(state, f)
		if best_tid != -1:
			var target_pos: Vector2i = state.teams[best_tid].tile_pos
			var dist: int = _hex_dist(leader_team.tile_pos, target_pos)
			if dist > DISPATCH_DIST_THRESHOLD and leader_team.population >= 4 \
					and leader_team.named_members.size() > 0:
				var _sub_sys_pick := SubteamSystem.new()
				var sub_leader_id: int = _sub_sys_pick._pick_subteam_leader(state, leader_team, "徵收")
				if sub_leader_id == -1: sub_leader_id = leader_team.named_members[0]
				var pop_count: int = maxi(leader_team.population / 4, 2)
				_sub_sys_pick.dispatch(state, f.leader_team_id, sub_leader_id,
					pop_count, "徵收", target_pos)
			else:
				TaskArbiter.try_set(state, leader_team, "徵收", target_pos,
					TaskArbiter.PRIO_DISPATCH, "faction_tribute")
	if "立國" in f.goals:
		_declare_established(state, f, leader_team)
	if "外交" in f.goals and leader_team.current_task not in ["徵收", "外交", "攻擊"]:
		var target_id: int = _nearest_independent(state, leader_team)
		if target_id != -1:
			TaskArbiter.try_set(state, leader_team, "外交",
				state.teams[target_id].tile_pos, TaskArbiter.PRIO_DISPATCH, "faction_diplomacy")
	if "攻擊" in f.goals and leader_team.current_task not in ["徵收", "外交", "攻擊"]:
		var target_id: int = _nearest_independent(state, leader_team)
		if target_id != -1 and TaskArbiter.try_set(state, leader_team, "攻擊",
				state.teams[target_id].tile_pos, TaskArbiter.PRIO_FACTION, "faction_goal"):
			print("[FactionAI] Team%d 主動攻擊 Team%d" % [f.leader_team_id, target_id])
	if "掠奪" in f.goals and leader_team.current_task not in ["徵收", "外交", "攻擊", "掠奪"]:
		var target_id: int = _nearest_independent(state, leader_team)
		if target_id != -1 and TaskArbiter.try_set(state, leader_team, "掠奪",
				state.teams[target_id].tile_pos, TaskArbiter.PRIO_FACTION, "faction_goal"):
			print("[FactionAI] Team%d 主動掠奪 Team%d" % [f.leader_team_id, target_id])
	_assign_member_tasks(state, f)

func _assign_member_tasks(state: WorldState, f) -> void:
	var leader_team: TeamData = state.teams.get(f.leader_team_id)
	for mid in f.member_team_ids:
		if mid == f.leader_team_id: continue
		var mt: TeamData = state.teams.get(mid)
		var snap: Dictionary = f.known_member_states.get(mid, {})
		var known_task: String = snap.get("current_task", "idle")
		if mt == null or mt.combat_target != -1 or known_task != "idle":
			continue
		if not mt.player_commanded_task.is_empty():
			continue  # don't override player-commanded task
		if mt.current_task in SURVIVAL_TASKS:
			continue  # 生存 sticky：不蓋過 survival task
		var absorber_id: int = _find_absorber(state, mt, f)
		if absorber_id != -1:
			var mt_leader = state.persons.get(mt.leader_id)
			var mt_cmd: float = float(mt_leader.skills.get("統領", 0.0)) if mt_leader else 0.0
			var mt_cap: int = TeamData.pop_cap_from_leadership(mt_cmd)
			var small_b: bool = mt.population < int(float(mt_cap) * SMALL_TEAM_RATIO)
			var small_c: bool = float(mt.population) < float(state.teams[absorber_id].population) * SMALL_VS_LARGE
			if small_b and small_c:
				if TaskArbiter.try_set(state, mt, TeamData.TASK_MERGE,
						state.teams[absorber_id].tile_pos, TaskArbiter.PRIO_DISPATCH, "consolidate"):
					mt.order_target_id = absorber_id
				continue
		if "攻擊" in f.goals and leader_team != null:
			var dist_to_leader: int = _hex_dist(mt.tile_pos, leader_team.tile_pos)
			if dist_to_leader > 1 and dist_to_leader <= CONSOLIDATE_MAX_DIST:
				var ldr_leader = state.persons.get(leader_team.leader_id)
				var ldr_cmd: float = float(ldr_leader.skills.get("統領", 0.0)) if ldr_leader else 0.0
				var ldr_cap: int = TeamData.pop_cap_from_leadership(ldr_cmd) - leader_team.population
				if ldr_cap > 0:
					if TaskArbiter.try_set(state, mt, TeamData.TASK_MERGE,
							leader_team.tile_pos, TaskArbiter.PRIO_DISPATCH, "consolidate"):
						mt.order_target_id = f.leader_team_id
					continue
		if "徵收" in f.goals and _tag_weight(mt, "徵收") > 0.0:
			var best_tid: int = _richest_member(state, f)
			if best_tid != -1 and best_tid != mid:
				TaskArbiter.try_set(state, mt, "徵收",
					state.teams[best_tid].tile_pos, TaskArbiter.PRIO_DISPATCH, "member_tribute")
		elif "外交" in f.goals and _tag_weight(mt, "外交") > 0.0:
			var target_id: int = _nearest_independent(state, mt)
			if target_id != -1:
				TaskArbiter.try_set(state, mt, "外交",
					state.teams[target_id].tile_pos, TaskArbiter.PRIO_DISPATCH, "member_diplomacy")
		elif "攻擊" in f.goals and _tag_weight(mt, "攻擊") > 0.0:
			var target_id: int = _nearest_independent(state, mt)
			if target_id != -1:
				TaskArbiter.try_set(state, mt, "攻擊",
					state.teams[target_id].tile_pos, TaskArbiter.PRIO_FACTION, "faction_goal")
		elif _can_manufacture(state, mt):
			TaskArbiter.try_set(state, mt, TeamData.TASK_MANUFACTURE,
				mt.move_target, TaskArbiter.PRIO_DISPATCH, "member_manufacture")
		elif _can_trade(state, mt):
			var pid: int = _find_trade_target(state, mt)
			if pid != -1:
				if TaskArbiter.try_set(state, mt, TeamData.TASK_TRADE,
						state.teams[pid].tile_pos, TaskArbiter.PRIO_DISPATCH, "member_trade"):
					mt.trade_task_start_tick = state.world.current_tick

func _find_absorber(state: WorldState, mt: TeamData, f) -> int:
	var best_id: int = -1
	var best_d: int  = 999
	for tid in f.member_team_ids:
		if tid == mt.team_id:
			continue
		var t: TeamData = state.teams.get(tid)
		if t == null or t.combat_target != -1:
			continue
		var t_leader = state.persons.get(t.leader_id)
		var t_cmd: float = float(t_leader.skills.get("統領", 0.0)) if t_leader else 0.0
		var t_cap: int = TeamData.pop_cap_from_leadership(t_cmd) - t.population
		if t_cap <= 0:
			continue
		var d: int = _hex_dist(mt.tile_pos, t.tile_pos)
		if d <= 1 or d > CONSOLIDATE_MAX_DIST:
			continue
		if d < best_d:
			best_d = d
			best_id = tid
	return best_id

# ──────── 子團自主 AI ────────

func _evaluate_subteam(state: WorldState, sub: TeamData, merge_queue: Array) -> void:
	if sub.current_task == TeamData.TASK_BUILD:
		return  # C: 施工中（建設），不打斷、不召回
	if sub.current_task == "安頓":
		# 抵達自家 faction outpost → 就地安頓（無需 co-located team；獨自抵達即轉居民）
		# 未到則保持 移動/安頓 task，不進 merge_queue（避免被召回母團）
		var settle_tile: HexTileData = state.world.tiles.get(
			sub.tile_pos.x * 1000 + sub.tile_pos.y)
		if settle_tile != null and settle_tile.outpost_owner != -1:
			var o: TeamData = state.teams.get(settle_tile.outpost_owner)
			if o != null and o.faction_id == sub.faction_id:
				InteractionSystem.new()._convert_to_resident(state, sub)
		return
	if sub.current_task == TeamData.TASK_ESCORT:
		_update_escort(state, sub)
		_check_discipline(state, sub)
		return
	if _check_discipline(state, sub):
		return
	if sub.current_task != TeamData.TASK_IDLE and sub.move_target != Vector2i(-1, -1):
		if _check_deviation(state, sub):
			return
	if sub.move_target == Vector2i(-1, -1) and sub.current_task != TeamData.TASK_IDLE:
		merge_queue.append(sub.team_id)
	elif sub.current_task == TeamData.TASK_IDLE:
		_evaluate_idle_subteam(state, sub, merge_queue)

func _update_escort(state: WorldState, team: TeamData) -> void:
	if team.order_target_id == -1:
		return
	var target: TeamData = state.teams.get(team.order_target_id)
	if target == null:
		TaskArbiter.release(team)   # 護衛對象消失 → 任務結束
		team.order_target_id = -1
		return
	team.move_target = target.tile_pos

func _check_discipline(state: WorldState, sub: TeamData) -> bool:
	var leader = state.persons.get(sub.leader_id)
	if leader == null:
		return false
	var total_loyalty: float = leader.loyalty
	var total_stress: float  = leader.stress
	var count: int = 1
	for aid in sub.named_members:
		var a = state.persons.get(aid)
		if a != null:
			total_loyalty += a.loyalty
			total_stress  += a.stress
			count         += 1
	var fail_chance: float = (1.0 - total_loyalty / count) * (total_stress / count) * DISCIPLINE_FAIL_BASE
	if randf() < fail_chance:
		var parent: TeamData = state.teams.get(sub.parent_team_id)
		if parent != null:
			parent.subteam_ids.erase(sub.team_id)
		sub.parent_team_id = -1
		sub.tags.erase(TeamData.TAG_SUBTEAM)
		TaskArbiter.release(sub)
		print("[SubAI] Team%d 紀律失效，脫離成獨立" % sub.team_id)
		return true
	return false

func _check_deviation(state: WorldState, sub: TeamData) -> bool:
	var leader = state.persons.get(sub.leader_id)
	if leader == null:
		return false
	var greed: float   = float(leader.values.get("貪婪", 0.5))
	var loyalty: float = leader.loyalty
	var deviation_chance: float = greed * (1.0 - loyalty) * DEVIATION_RATE
	if randf() < deviation_chance:
		var loot_target: int = _nearest_independent(state, sub)
		if loot_target != -1:
			if TaskArbiter.try_set(state, sub, TeamData.TASK_LOOT,
					state.teams[loot_target].tile_pos, TaskArbiter.PRIO_DISPATCH, "deviation"):
				print("[SubAI] Team%d 偏離掠奪 Team%d" % [sub.team_id, loot_target])
				return true
			return false
		TaskArbiter.release(sub)
	return false

func _evaluate_idle_subteam(state: WorldState, sub: TeamData, merge_queue: Array) -> void:
	var parent: TeamData = state.teams.get(sub.parent_team_id)
	if parent == null:
		return
	if parent.tile_pos == sub.tile_pos:
		merge_queue.append(sub.team_id)
		return
	var leader_p = state.persons.get(sub.leader_id)
	if leader_p == null:
		sub.move_target = parent.tile_pos
		return
	var greed:   float = float(leader_p.values.get("貪婪", 0.5))
	var martial: float = float(leader_p.values.get("好戰", 0.5))
	var scores: Dictionary = { "回歸": 0.3 }
	scores["掠奪"] = (greed * 0.5 + martial * 0.2) * _tag_weight(sub, "掠奪")
	scores["攻擊"] = (martial * 0.4 + greed * 0.2) * _tag_weight(sub, "攻擊")
	var best_task := "回歸"
	var best_score: float = 0.0
	for t in scores:
		if float(scores[t]) > best_score:
			best_score = float(scores[t])
			best_task  = t
	if best_task == "回歸":
		sub.move_target = parent.tile_pos
	else:
		var tid: int = _nearest_independent(state, sub)
		if tid != -1:
			if TaskArbiter.try_set(state, sub, best_task,
					state.teams[tid].tile_pos, TaskArbiter.PRIO_DISPATCH, "subteam_idle"):
				print("[SubAI] Team%d idle→%s (Team%d)" % [sub.team_id, best_task, tid])
		else:
			sub.move_target = parent.tile_pos

# ──────── 獨立 Team 自主 AI ────────

func _evaluate_solo(state: WorldState, team: TeamData) -> void:
	if team.leader_id == state.player_id: return   # 玩家隊不受 SoloAI 控制
	if team.combat_target != -1: return
	# stuck 視為 idle，允許重評（task 保留意圖直到重新派發）
	if team.current_task != "idle" and not _is_stuck(team): return
	var leader_p = state.persons.get(team.leader_id)
	if leader_p == null: return

	var martial:  float = float(leader_p.values.get("好戰",   0.5))
	var greed:    float = float(leader_p.values.get("貪婪",   0.5))
	var ambition: float = float(leader_p.values.get("野心",   0.5))
	var survival: float = float(leader_p.values.get("求生欲", 0.5))

	var scores: Dictionary = { "idle": 0.1 }
	scores["攻擊"] = (ambition * 0.4 + martial * 0.4) * _tag_weight(team, "攻擊")
	scores["掠奪"] = (greed * 0.5 + martial * 0.3)    * _tag_weight(team, "掠奪")
	scores["外交"] = maxf(ambition * 0.4 - martial * 0.2, 0.0) * _tag_weight(team, "外交")
	var food_pc: float = float(team.resources.get("food", 0)) / maxf(team.population, 1)
	if food_pc < 2.0:
		scores["逃跑"] = survival * 0.8
	if _can_manufacture(state, team):
		scores["製造"] = (greed * 0.4 + 0.2) * _tag_weight(team, "製造")
	if _can_trade(state, team):
		scores["貿易"] = (greed * 0.5 + 0.3) * _tag_weight(team, "貿易")

	var best_task := "idle"
	var best_score: float = 0.0
	for t in scores:
		if float(scores[t]) > best_score:
			best_score = float(scores[t])
			best_task = t

	if best_task == "idle": return
	var solo_target: Vector2i = team.move_target
	match best_task:
		"攻擊", "掠奪", "外交":
			var tid: int = _nearest_independent(state, team)
			if tid == -1: return
			solo_target = state.teams[tid].tile_pos
		"逃跑":
			solo_target = Vector2i(-1, -1)
		"製造":
			pass  # 製造在原地進行
		"貿易":
			var pid: int = _find_trade_target(state, team)
			if pid == -1: return
			solo_target = state.teams[pid].tile_pos
	if _is_stuck(team):
		TaskArbiter.release(team)   # stuck 釋放讓位，同層才能重評
	if not TaskArbiter.try_set(state, team, best_task, solo_target,
			TaskArbiter.PRIO_DISPATCH, "solo"):
		return
	if best_task == "貿易":
		team.trade_task_start_tick = state.world.current_tick
	print("[SoloAI] Team%d → %s" % [team.team_id, best_task])

func _update_equip_order(state: WorldState, team: TeamData) -> void:
	# 已裝備武器離開 storage pool；target 若只看 storage 會隨裝備行為縮放
	# → equip/unequip 每 tick 振盪（[Equip] spam 根因），故計入已裝備量
	var equipped_units: Dictionary = {
		"melee_low": 0, "melee_high": 0, "ranged_low": 0, "ranged_high": 0
	}
	var named_ids: Array = team.named_members.duplicate()
	if team.leader_id != -1:
		named_ids.append(team.leader_id)
	for pid in named_ids:
		var p: PersonData = state.persons.get(pid)
		if p == null: continue
		var grade: String = p.equipment["hand_1"].get("grade", "")
		if grade.begins_with("weapon_"):
			var wtype: String = grade.replace("weapon_", "")
			if equipped_units.has(wtype):
				equipped_units[wtype] += EquipmentSystem.UNITS_PER_EQUIP
	var total_weapons: int = 0
	for wtype in ["melee_low", "melee_high", "ranged_low", "ranged_high"]:
		total_weapons += int(team.resources.get("weapon_" + wtype, 0)) + int(equipped_units[wtype])
	if total_weapons <= 0:
		return
	team.equip_order = { "melee_low": 0, "melee_high": 0, "ranged_low": 0, "ranged_high": 0 }
	var can_equip: int = total_weapons / 2
	if team.tags.has(TeamData.TAG_MILITARY) or team.current_task == TeamData.TASK_LOOT \
			or team.current_task == TeamData.TASK_ATTACK:
		var pool_mh: int = (int(team.resources.get("weapon_melee_high", 0)) + int(equipped_units["melee_high"])) / 2
		var pool_rh: int = (int(team.resources.get("weapon_ranged_high", 0)) + int(equipped_units["ranged_high"])) / 2
		var pool_ml: int = (int(team.resources.get("weapon_melee_low", 0)) + int(equipped_units["melee_low"])) / 2
		var pool_rl: int = (int(team.resources.get("weapon_ranged_low", 0)) + int(equipped_units["ranged_low"])) / 2
		team.equip_order["melee_high"]  = mini(pool_mh, can_equip)
		can_equip -= team.equip_order["melee_high"]
		team.equip_order["ranged_high"] = mini(pool_rh, can_equip)
		can_equip -= team.equip_order["ranged_high"]
		team.equip_order["melee_low"]   = mini(pool_ml, can_equip)
		can_equip -= team.equip_order["melee_low"]
		team.equip_order["ranged_low"]  = mini(pool_rl, can_equip)
	elif team.tags.has(TeamData.TAG_MERCHANT):
		var guard_count: int = mini(team.population * 3 / 10, can_equip)
		team.equip_order["melee_low"] = mini(
			(int(team.resources.get("weapon_melee_low", 0)) + int(equipped_units["melee_low"])) / 2, guard_count)
	else:
		var guard_count: int = mini(team.population / 2, can_equip)
		team.equip_order["melee_low"] = mini(
			(int(team.resources.get("weapon_melee_low", 0)) + int(equipped_units["melee_low"])) / 2, guard_count)

func _get_player_team_id(state: WorldState) -> int:
	if state.player_id == -1: return -1
	var p: PersonData = state.persons.get(state.player_id)
	if p == null:
		# 玩家已死，找 leader_id == player_id 或 player_id in named_members 的 team
		for tid in state.teams:
			var t: TeamData = state.teams[tid]
			if t.leader_id == state.player_id or state.player_id in t.named_members:
				return tid
		return -1
	return p.team_id

func _handle_player_leader_death(state: WorldState, team: TeamData) -> void:
	team.leader_id = -1
	if team.named_members.is_empty():
		state.game_over = true
		state.game_over_reason = "玩家絕後（Team%d 無繼承人）" % team.team_id
		print("[GameOver] %s" % state.game_over_reason)
		return
	state.player_forced_event = {
		"action": "choose_heir",
		"team_id": team.team_id,
		"candidates": team.named_members.duplicate(),
	}
	state.player_forced_event_id = "heir_%d" % state.world.current_tick
	print("[Heir] 玩家 leader 死亡，等待選繼承人 (Team%d, %d 候選)" % [
		team.team_id, team.named_members.size()])

func _promote_successor(state: WorldState, team: TeamData) -> void:
	# H: 玩家 team 走 _handle_player_leader_death
	var player_team_id: int = _get_player_team_id(state)
	if state.player_id != -1 and team.team_id == player_team_id:
		_handle_player_leader_death(state, team)
		return
	# 從 named_members 選統領技能最高者升任 leader（S11 fix）
	var best_pid: int = -1
	var best_cmd: float = -1.0
	for pid in team.named_members:
		var p: PersonData = state.persons.get(pid)
		if p == null: continue
		var cmd: float = float(p.skills.get("統領", 0.0))
		if cmd > best_cmd:
			best_cmd = cmd
			best_pid = pid
	if best_pid == -1:
		return
	var new_leader: PersonData = state.persons[best_pid]
	new_leader.role = "leader"
	team.leader_id = best_pid
	team.named_members.erase(best_pid)
	print("[Succession] Team%d 新 leader: P%d (%s) 統領=%.2f" % [
		team.team_id, best_pid, new_leader.person_name, best_cmd])
	# 若是玩家 team 且玩家死亡，state.player_id 同步轉移（D2 連動緩解）
	if state.player_id == -1 or state.persons.get(state.player_id) == null:
		# 不主動轉移玩家身分，D2 屬獨立議題
		pass

func _update_armor_config(team: TeamData) -> void:
	var pop_threshold: float = maxf(team.population * 0.3, 1.0)
	var has_high: bool = int(team.resources.get("armor_high", 0)) >= pop_threshold
	var has_low:  bool = int(team.resources.get("armor_low", 0))  >= pop_threshold
	# 重設全 none，再依條件填值
	team.armor_config = {
		"head": "none", "torso": "none",
		"right_arm": "none", "left_arm": "none",
		"right_leg": "none", "left_leg": "none",
	}
	var is_mil: bool = team.tags.has(TeamData.TAG_MILITARY)
	var is_mer: bool = team.tags.has(TeamData.TAG_MERCHANT)
	if is_mil and has_high:
		team.armor_config["torso"]     = "high"
		team.armor_config["head"]      = "low"
		team.armor_config["right_arm"] = "low"
		team.armor_config["left_arm"]  = "low"
		team.armor_config["right_leg"] = "low"
		team.armor_config["left_leg"]  = "low"
	elif is_mil and has_low:
		team.armor_config["torso"] = "low"
		team.armor_config["head"]  = "low"
	elif is_mer and has_low:
		team.armor_config["torso"] = "low"
	elif has_low:
		team.armor_config["torso"] = "low"

func _has_hostile_within(state: WorldState, team: TeamData, range_hex: int) -> bool:
	for tid in state.teams:
		if tid == team.team_id: continue
		var other: TeamData = state.teams[tid]
		if other.faction_id == team.faction_id and team.faction_id != -1: continue
		# 高聲望盟友過濾（rep >= 0.7 視為友軍，預設 0.5；結盟後 +0.2 → 達標）
		var rep: float = float(team.known_reputations.get(other.team_id, 0.5))
		if rep >= 0.7: continue
		var d: int = _hex_dist(team.tile_pos, other.tile_pos)
		if d <= range_hex:
			return true
	return false

func _update_guard_ratio(team: TeamData, state: WorldState) -> void:
	var ratio: float = 0.2  # default
	if team.current_task == TeamData.TASK_ATTACK or team.current_task == TeamData.TASK_LOOT:
		ratio = 0.1
	else:
		var threat: bool = _has_hostile_within(state, team, 3)
		if team.tags.has(TeamData.TAG_MILITARY) and threat:
			ratio = 0.4
		elif threat:
			ratio = 0.35
		elif team.tags.has(TeamData.TAG_PRODUCE):
			ratio = 0.15
	team.guard_ratio = clampf(ratio, 0.05, 0.5)

# ──────── 輔助函數 ────────

func _can_trade(state: WorldState, team: TeamData) -> bool:
	if _tag_weight(team, "貿易") == 0.0:
		return false
	for res in TRADEABLE_RES:
		var stock: float = float(team.resources.get(res, 0))
		if res == "food":
			stock = maxf(stock - float(team.population) * 0.1 \
				* InteractionSystem.FOOD_RESERVE_TICKS, 0.0)
		if stock >= TRADE_MIN_STOCK:
			return true
	return false

const MERCHANT_MAX_RANGE: int = 20

func _find_trade_target(state: WorldState, merchant: TeamData) -> int:
	var best_id: int = -1
	var best_score: float = -1e9
	var inter := InteractionSystem.new()
	for tid in state.team_discovered.get(merchant.team_id, []):
		if tid == merchant.team_id: continue
		if not state.teams.has(tid): continue
		var t: TeamData = state.teams[tid]
		var catch_result: Dictionary = PathSystem.estimate_catch_up(state, merchant, tid)
		if not catch_result.reachable: continue
		var snap: Dictionary = state.team_intel.get(merchant.team_id, {}).get(tid, {})
		var max_gap: float = 0.0
		for res in InteractionSystem.BASE_PRICE:
			var my_val: float = inter._local_value(merchant, res)
			var their_val_est: float = my_val
			if snap.has(res) and res in ["food", "material"]:
				var pop: int = int(snap.get("population", 10))
				var stk: float = float(snap.get(res, 0))
				var target: float = float(pop) * float(InteractionSystem.TARGET_PER_POP.get(res, 1.0))
				var sr: float = clampf((target - stk) / maxf(target, 1.0), -0.5, 1.0)
				their_val_est = float(InteractionSystem.BASE_PRICE[res]) * (1.0 + sr)
			var gap: float = absf(their_val_est - my_val)
			if gap > max_gap: max_gap = gap
		var score: float = max_gap / float(maxi(int(catch_result.eta) / 60, 1))
		if score > best_score:
			best_score = score
			best_id = tid
	return best_id

func _can_manufacture(state: WorldState, team: TeamData) -> bool:
	var tile_id: int      = team.tile_pos.x * 1000 + team.tile_pos.y
	var tile: HexTileData = state.world.tiles.get(tile_id)
	if tile == null or tile.outpost_level == 0:
		return false
	# 任一製造類設施（工坊/冶煉/武器/護甲）才可開工
	var has_facility: bool = false
	for level_key in ManufacturingSystem.RECIPE_GROUPS:
		if int(tile.get(level_key)) > 0:
			has_facility = true
			break
	if not has_facility:
		return false
	# 生產權：owner 本人或同 faction 居民團
	if tile.outpost_owner != team.team_id:
		var owner: TeamData = state.teams.get(tile.outpost_owner)
		if owner == null or owner.faction_id != team.faction_id or team.faction_id == -1:
			return false
	return float(team.resources.get("material", 0)) >= MANUFACTURE_MATERIAL_MIN

func _is_known(state: WorldState, from_id: int, target_id: int) -> bool:
	return state.team_discovered.get(from_id, []).has(target_id)

func _has_independent(state: WorldState, from_team_id: int) -> bool:
	for tid in state.team_discovered.get(from_team_id, []):
		if state.teams.has(tid) and state.teams[tid].faction_id == -1:
			return true
	return false

func _nearest_independent(state: WorldState, from_team: TeamData) -> int:
	var best_id: int = -1
	var best_d: int  = 999
	for tid in state.team_discovered.get(from_team.team_id, []):
		if not state.teams.has(tid): continue
		var t: TeamData = state.teams[tid]
		if t.faction_id != -1 or t.team_id == from_team.team_id:
			continue
		var d: int = _hex_dist(from_team.tile_pos, t.tile_pos)
		if d < best_d:
			best_d  = d
			best_id = tid
	return best_id

func _calc_own_armed(state: WorldState, team: TeamData) -> int:
	var named_armed: int = 0
	for pid in ([team.leader_id] as Array) + team.named_members:
		var p: PersonData = state.persons.get(pid) as PersonData
		if p and p.equipment["hand_1"].get("type", "none") != "none":
			named_armed += 1
	var named_count: int = 1 + team.named_members.size()
	var anon_pop: int    = maxi(team.population - named_count, 0)
	return named_armed + roundi(float(anon_pop) * team.armed_anon_ratio)

func _hex_dist(a: Vector2i, b: Vector2i) -> int:
	var dx := b.x - a.x
	var dy := b.y - a.y
	return (abs(dx) + abs(dx + dy) + abs(dy)) / 2

# ──────── 基建設施需求評估（FACILITY_DEF.trigger_check 指向）────────

func _check_food_shortage(state: WorldState, faction) -> float:
	var total_food: float = 0.0
	var total_pop: int = 0
	for tid in faction.member_team_ids:
		var t: TeamData = state.teams.get(tid)
		if t == null: continue
		total_food += float(t.resources.get("food", 0))
		total_pop += t.population
	var per_capita: float = total_food / maxf(total_pop, 1)
	# 缺糧（< 10 天份）→ 高 priority
	return clampf((10.0 - per_capita) / 10.0, 0.0, 1.0) * 100.0

func _check_goods_shortage(state: WorldState, faction) -> float:
	var total_goods: float = 0.0
	for tid in faction.member_team_ids:
		var t: TeamData = state.teams.get(tid)
		if t == null: continue
		total_goods += float(t.resources.get("goods", 0))
	# goods < 100 → 觸發
	return clampf((100.0 - total_goods) / 100.0, 0.0, 1.0) * 50.0

func _check_mount_demand(state: WorldState, faction) -> float:
	# 軍隊/商隊團多 + mount/pop 比偏低 → 高 priority 蓋馬廄
	var total_pop: int = 0
	var total_mounts: int = 0
	var has_demand_tag: bool = false
	for tid in faction.member_team_ids:
		var t: TeamData = state.teams.get(tid)
		if t == null: continue
		total_pop += t.population
		total_mounts += int(t.resources.get("mounts", 0))
		if "軍隊" in t.tags or "商隊" in t.tags:
			has_demand_tag = true
	if not has_demand_tag: return 0.0
	var ratio: float = float(total_mounts) / maxf(float(total_pop), 1.0)
	return clampf((0.5 - ratio) / 0.5, 0.0, 1.0) * 60.0

func _check_ore_surplus(state: WorldState, faction) -> float:
	var total: float = 0.0
	for tid in faction.member_team_ids:
		for tile_id in state.world.tiles:
			var tile: HexTileData = state.world.tiles[tile_id]
			if tile.outpost_owner != tid: continue
			total += float(tile.public_storage.get("ore_gold", 0)) * 5.0
			total += float(tile.public_storage.get("ore_silver", 0))
	return 80.0 if total > 50.0 else 0.0

# ──────── 公庫徵用 ────────

func _extract_treasury(state: WorldState, team: TeamData, ratio: float, reason: String) -> void:
	if team.anon_treasury <= 0.0 or ratio <= 0.0: return
	ratio = clampf(ratio, 0.0, 1.0)
	var amt: float = team.anon_treasury * ratio
	if amt < 1.0: return   # 忽略可忽略額度，避免空徵用噪音 + 虛增 unrest
	team.anon_treasury -= amt
	team.resources["coin"] = float(team.resources.get("coin", 0)) + amt
	var is_emergency: bool = (reason == "飢餓緊急")
	var stress_pen: float = (0.05 if is_emergency else 0.15) * ratio
	var loyalty_pen: float = (0.02 if is_emergency else 0.08) * ratio
	for pid in ([team.leader_id] as Array) + team.named_members:
		var p: PersonData = state.persons.get(pid)
		if p == null: continue
		p.stress = minf(p.stress + stress_pen, 1.0)
		p.loyalty = maxf(p.loyalty - loyalty_pen, 0.0)
	if not is_emergency:
		team.unrest_turns += 1
	print("[Extract] Team%d 徵用 %.0f coin (%s)" % [team.team_id, amt, reason])

func _consider_extraction(state: WorldState, team: TeamData) -> void:
	if team.anon_treasury <= 0.0: return
	if team.leader_id == state.player_id: return   # 玩家手動
	var leader: PersonData = state.persons.get(team.leader_id)
	if leader == null: return
	var greed: float = float(leader.values.get("貪婪", 0.5))
	var prudence: float = float(leader.values.get("慎重", 0.5))
	var extract_score: float = greed - prudence * 0.5
	if extract_score > 0.4:
		var ratio: float = greed * 0.3
		_extract_treasury(state, team, ratio, "貪婪驅動")

# 滅團遺財處理：有 outpost → 全資源 + treasury 進公庫；無 outpost → coin 變 abandoned_coin
func _on_team_extinct(state: WorldState, team: TeamData) -> void:
	var tile: HexTileData = state.world.tiles.get(team.tile_pos.x * 1000 + team.tile_pos.y)
	if tile == null:
		team.anon_treasury = 0.0
		team.resources.clear()
		return
	if tile.outpost_level > 0:
		var os := OutpostSystem.new()
		for res in team.resources:
			var amt: float = float(team.resources[res])
			if amt <= 0.0: continue
			var cap: float = os._get_storage_cap(tile, res)
			var stored: float = float(tile.public_storage.get(res, 0))
			tile.public_storage[res] = minf(stored + amt, cap)
		var coin_cap: float = os._get_storage_cap(tile, "coin")
		var cur_coin: float = float(tile.public_storage.get("coin", 0))
		tile.public_storage["coin"] = minf(cur_coin + team.anon_treasury, coin_cap)
	else:
		# 無 outpost → 僅 coin/treasury 留地，其他資源消失（無容器）
		tile.abandoned_coin += team.anon_treasury
	team.anon_treasury = 0.0
	team.resources.clear()
	print("[Extinct] Team%d 滅團遺財處理 at (%d,%d)" % [team.team_id, team.tile_pos.x, team.tile_pos.y])

# ──────── NPC 自動領存公庫 ────────

func _calc_team_need(team: TeamData, res: String) -> float:
	match res:
		"food": return float(team.population) * 14.0
		"material": return 50.0 + float(team.population) * 2.0
		"coin": return float(team.population) * 10.0
		"weapon_melee_low", "weapon_melee_high", "weapon_ranged_low", "weapon_ranged_high":
			return float(team.named_members.size()) * 2.0
		"armor_low", "armor_high":
			return float(team.named_members.size())
		_:
			return 0.0

func _evaluate_storage_visit(state: WorldState, team: TeamData, tile: HexTileData) -> void:
	if tile.outpost_owner != team.team_id: return
	if tile.public_storage.is_empty(): return
	var os := OutpostSystem.new()
	for res in tile.public_storage.keys():
		var stored: float = float(tile.public_storage[res])
		var team_have: float = float(team.resources.get(res, 0))
		var needed: float = _calc_team_need(team, res)
		if team_have < needed:
			var take: float = minf(stored, needed - team_have)
			if take > 0.0:
				tile.public_storage[res] = stored - take
				team.resources[res] = team_have + take
		elif team_have > needed * 2.0:
			var cap: float = os._get_storage_cap(tile, res)
			var deposit_max: float = cap - stored
			var deposit: float = minf(team_have - needed, deposit_max)
			if deposit > 0.0:
				tile.public_storage[res] = stored + deposit
				team.resources[res] = team_have - deposit

# ──────── 基建 dispatch ────────

# 選一名非 leader 的記名成員當子隊 leader（建造/升級/擴建 crew）
func _pick_advisor(team: TeamData) -> int:
	for pid in team.named_members:
		if pid != team.leader_id:
			return pid
	return -1

# 派建造子隊前往 target_pos，task="建造"，附 build_type/level。
# 資源以 1.5x 安全餘量檢查（子隊抵達後 start_build 才實際扣款）。
func _dispatch_builder(state: WorldState, leader_team: TeamData, target_pos: Vector2i,
		outpost_type: String, level: int) -> bool:
	var cost: Dictionary = OutpostSystem.OUTPOST_COST[outpost_type][level - 1]
	for k in cost:
		if k == "ticks": continue
		if float(leader_team.resources.get(k, 0)) < float(cost[k]) * 1.5:
			return false
	var advisor_id: int = _pick_or_promote_advisor(state, leader_team)
	if advisor_id == -1: return false
	var pop: int = maxi(10, level * 5)
	if leader_team.population < pop * 2: return false
	var sub_id: int = SubteamSystem.new().dispatch(
		state, leader_team.team_id, advisor_id, pop, "建造", target_pos)
	if sub_id == -1: return false
	_fund_subteam_cost(leader_team, state.teams[sub_id], cost)
	state.teams[sub_id].task_extra_data = {
		"build_type": outpost_type, "level": level
	}
	print("[Infra] Team%d 派建造子隊 Team%d → (%d,%d) %s Lv%d" % [
		leader_team.team_id, sub_id, target_pos.x, target_pos.y, outpost_type, level])
	return true

# 派升級子隊（task="升級"，附 target_level）
func _dispatch_upgrader(state: WorldState, owner_team: TeamData, outpost_pos: Vector2i,
		target_level: int) -> bool:
	var tile: HexTileData = state.world.tiles.get(outpost_pos.x * 1000 + outpost_pos.y)
	if tile == null or tile.outpost_owner != owner_team.team_id: return false
	if target_level <= tile.outpost_level or target_level > 3: return false
	if tile.construction_team_id != -1: return false
	var cost: Dictionary = OutpostSystem.OUTPOST_COST[tile.outpost_type][target_level - 1]
	for k in cost:
		if k == "ticks": continue
		if float(owner_team.resources.get(k, 0)) < float(cost[k]) * 1.5: return false
	var advisor_id: int = _pick_or_promote_advisor(state, owner_team)
	if advisor_id == -1: return false
	if owner_team.population < 10: return false
	var sub_id: int = SubteamSystem.new().dispatch(
		state, owner_team.team_id, advisor_id, 5, "升級", outpost_pos)
	if sub_id == -1: return false
	_fund_subteam_cost(owner_team, state.teams[sub_id], cost)
	state.teams[sub_id].task_extra_data = { "target_level": target_level }
	print("[Infra] Team%d 派升級子隊 Team%d → (%d,%d) Lv%d" % [
		owner_team.team_id, sub_id, outpost_pos.x, outpost_pos.y, target_level])
	return true

# 施工中斷（survival 等劫持後未復工）→ 在場居民復工，否則召回 owner 回工地
func _try_resume_construction(state: WorldState, tile: HexTileData, leader_team: TeamData) -> void:
	for tid in state.teams:
		var t: TeamData = state.teams[tid]
		if t.tile_pos == tile.tile_pos and t.current_task == TeamData.TASK_BUILD:
			return   # 已有人施工
	var interruptible: Array = [TeamData.TASK_IDLE, TeamData.TASK_PRODUCE,
		TeamData.TASK_MANUFACTURE, TeamData.TASK_TRADE]
	var candidates: Array = []
	for tid in state.teams:
		var t: TeamData = state.teams[tid]
		if t.combat_target != -1: continue
		if t.leader_id == state.player_id and state.player_id != -1: continue
		var is_owner: bool = t.team_id == tile.outpost_owner
		var resident_here: bool = t.tile_pos == tile.tile_pos \
			and t.faction_id == leader_team.faction_id and t.faction_id != -1 \
			and TeamData.TAG_PRODUCE in t.tags
		if not (is_owner or resident_here): continue
		# 已在工地的 return_home 殭屍態（到家但飢餓 sticky）也可復工
		var at_site_stuck: bool = t.tile_pos == tile.tile_pos \
			and t.current_task == "return_home"
		if not (t.current_task in interruptible or at_site_stuck): continue
		if t.tile_pos == tile.tile_pos:
			candidates.push_front(t)   # 在場優先
		else:
			candidates.append(t)
	if candidates.is_empty(): return
	var worker: TeamData = candidates[0]
	TaskArbiter.transition(worker, TeamData.TASK_BUILD, TaskArbiter.PRIO_DISPATCH)
	worker.move_target = tile.tile_pos
	print("[Infra] Team%d 復工 at (%d,%d)%s" % [worker.team_id,
		tile.tile_pos.x, tile.tile_pos.y,
		"" if worker.tile_pos == tile.tile_pos else "（趕路中）"])

# tile 上可施工的居民團（PRODUCE、閒置非戰鬥；擁有權由 _subteam_upgrade_facility 驗證）
func _resident_team_for_construction(state: WorldState, tile: HexTileData) -> TeamData:
	for tid in state.teams:
		var t: TeamData = state.teams[tid]
		if t.tile_pos != tile.tile_pos: continue
		if not (TeamData.TAG_PRODUCE in t.tags): continue
		if t.combat_target != -1: continue
		if t.current_task == TeamData.TASK_BUILD: continue
		return t
	return null

# 無多餘 named → 升一名 anon 為工頭（同 residency dispatch 機制）
func _pick_or_promote_advisor(state: WorldState, team: TeamData) -> int:
	var advisor_id: int = _pick_advisor(team)
	if advisor_id != -1:
		return advisor_id
	var new_advisor: PersonData = PersonGenerator.generate_for_team(state, team, "member")
	if new_advisor == null:
		return -1
	team.named_members.append(new_advisor.id)
	return new_advisor.id

# 撥付建造款：dispatch 比例分資源不足以付建造費 → 從 owner 補足至 cost（守恆：純轉移）
func _fund_subteam_cost(owner_team: TeamData, sub: TeamData, cost: Dictionary) -> void:
	for k in cost:
		if k == "ticks": continue
		var need: float = maxf(float(cost[k]) - float(sub.resources.get(k, 0)), 0.0)
		if need <= 0.0: continue
		var transfer: float = minf(need, float(owner_team.resources.get(k, 0)))
		sub.resources[k] = float(sub.resources.get(k, 0)) + transfer
		owner_team.resources[k] = float(owner_team.resources.get(k, 0)) - transfer

# 派擴建子隊（task="擴建"，附 facility_type）
func _dispatch_facility_builder(state: WorldState, owner_team: TeamData, outpost_pos: Vector2i,
		facility_type: String) -> bool:
	var tile: HexTileData = state.world.tiles.get(outpost_pos.x * 1000 + outpost_pos.y)
	if tile == null or tile.outpost_owner != owner_team.team_id: return false
	if tile.construction_team_id != -1: return false
	var def: Dictionary = OutpostSystem.FACILITY_DEF[facility_type]
	var cur_lvl: int = int(tile.get(def["current_level_key"]))
	var cost: Dictionary = OutpostSystem.upgrade_cost(facility_type, cur_lvl + 1)
	for k in cost:
		if k == "ticks": continue
		if float(owner_team.resources.get(k, 0)) < float(cost[k]) * 1.5: return false
	var advisor_id: int = _pick_or_promote_advisor(state, owner_team)
	if advisor_id == -1: return false
	if owner_team.population < 6: return false
	var sub_id: int = SubteamSystem.new().dispatch(
		state, owner_team.team_id, advisor_id, 3, "擴建", outpost_pos)
	if sub_id == -1: return false
	_fund_subteam_cost(owner_team, state.teams[sub_id], cost)
	state.teams[sub_id].task_extra_data = { "facility_type": facility_type }
	print("[Infra] Team%d 派擴建子隊 Team%d → (%d,%d) %s" % [
		owner_team.team_id, sub_id, outpost_pos.x, outpost_pos.y, facility_type])
	return true

# ──────── 新據點選址評分 ────────

const MIN_BUILD_SCORE: float = 50.0

const TERRAIN_BUILD_BONUS: Dictionary = {
	"plains": 20.0, "forest": 10.0, "mountain": -10.0,
}

# 選址資源權重（候選格本格 + 鄰 6 格，每點資源出現一次加一次）TEST VALUES
const SITE_RES_BONUS: Dictionary = {
	"herb": 30.0, "wild_horses": 25.0, "ore_iron": 20.0,
	"ore_gold": 35.0, "ore_silver": 35.0,
}

# 回傳最佳候選 { "pos": Vector2i, "score": float, "tile": HexTileData }，無則 {}。
# 多中心滾動拓殖：候選 = 任一 center（leader 所在 + faction 所有 outpost）dist 2-5。
func _evaluate_new_outpost_location(state: WorldState, leader_team: TeamData) -> Dictionary:
	var candidates: Array = []
	var centers: Array = [leader_team.tile_pos]
	for tile_id in state.world.tiles:
		var t: HexTileData = state.world.tiles[tile_id]
		if t.outpost_owner == -1 or t.outpost_level == 0: continue
		var o: TeamData = state.teams.get(t.outpost_owner)
		if o != null and o.faction_id == leader_team.faction_id and leader_team.faction_id != -1:
			if not centers.has(t.tile_pos):
				centers.append(t.tile_pos)
	for tile_id in state.world.tiles:
		var tile: HexTileData = state.world.tiles[tile_id]
		if tile.outpost_level > 0: continue
		var dist: int = 9999
		for c in centers:
			var d: int = _hex_dist(c, tile.tile_pos)
			if d < dist: dist = d
		if dist > 5 or dist < 2: continue   # 太近不行
		var score: float = float(tile.productivity) * 100.0
		score += float(TERRAIN_BUILD_BONUS.get(tile.terrain, 0))
		score -= float(dist) * 5.0
		score += clampf(10.0 - float(dist), 0.0, 10.0) * 2.0
		score += _site_resource_bonus(state, tile.tile_pos)
		var min_enemy_dist: int = _min_dist_to_enemy_outpost(state, leader_team, tile.tile_pos)
		if min_enemy_dist < 5: score -= float(5 - min_enemy_dist) * 10.0
		if score >= MIN_BUILD_SCORE:
			candidates.append({ "pos": tile.tile_pos, "score": score, "tile": tile })
	if candidates.is_empty(): return {}
	candidates.sort_custom(func(a, b): return a.score > b.score)
	var best: Dictionary = candidates[0]
	print("[Site] 選址 %s score=%.0f 周邊資源=%s" % [
		str(best.pos), best.score, str(_site_resources_nearby(state, best.pos))])
	return best

func _site_resource_bonus(state: WorldState, pos: Vector2i) -> float:
	var bonus: float = 0.0
	for d in ([Vector2i.ZERO] as Array) + PathSystem.HEX_DIRS:
		var npos: Vector2i = pos + d
		var ntile: HexTileData = state.world.tiles.get(npos.x * 1000 + npos.y)
		if ntile == null: continue
		for res in SITE_RES_BONUS:
			if float(ntile.resources.get(res, 0)) > 0:
				bonus += float(SITE_RES_BONUS[res])
	return bonus

# 選址 log 用：本格+鄰 6 格的權重資源彙總
func _site_resources_nearby(state: WorldState, pos: Vector2i) -> Dictionary:
	var found: Dictionary = {}
	for d in ([Vector2i.ZERO] as Array) + PathSystem.HEX_DIRS:
		var npos: Vector2i = pos + d
		var ntile: HexTileData = state.world.tiles.get(npos.x * 1000 + npos.y)
		if ntile == null: continue
		for res in SITE_RES_BONUS:
			var amt: float = float(ntile.resources.get(res, 0))
			if amt > 0:
				found[res] = float(found.get(res, 0)) + amt
	return found

func _min_dist_to_enemy_outpost(state: WorldState, leader_team: TeamData, pos: Vector2i) -> int:
	var min_dist: int = 9999
	for tile_id in state.world.tiles:
		var tile: HexTileData = state.world.tiles[tile_id]
		if tile.outpost_level == 0: continue
		var owner: TeamData = state.teams.get(tile.outpost_owner)
		if owner == null: continue
		if owner.faction_id == leader_team.faction_id and owner.faction_id != -1: continue
		var d: int = _hex_dist(pos, tile.tile_pos)
		if d < min_dist: min_dist = d
	return min_dist

# ──────── 基建主決策 ────────

const INFRA_INTERVAL: int = 50 * WorldState.TICKS_PER_HOUR  # 每 50 小時評估一次

# leader values 決定新據點傾向（軍用 vs 民用）
func _pick_outpost_type(leader: PersonData) -> String:
	var military: float = float(leader.values.get("好戰", 0.5)) + float(leader.values.get("野心", 0.5))
	var civilian: float = float(leader.values.get("慎重", 0.5)) + float(leader.values.get("貪婪", 0.5))
	return "military" if military > civilian else "civilian"

func _evaluate_infrastructure(state: WorldState, faction) -> void:
	var leader_team: TeamData = state.teams.get(faction.leader_team_id)
	if leader_team == null: return
	if leader_team.combat_target != -1: return
	var leader: PersonData = state.persons.get(leader_team.leader_id)
	if leader == null: return
	# 玩家 leader → 不自動決策（後續用 AdvisorSystem.push_outpost_advice）
	if leader_team.leader_id == state.player_id and state.player_id != -1:
		return
	# (1) 升級既有 outpost
	for tile_id in state.world.tiles:
		var tile: HexTileData = state.world.tiles[tile_id]
		if tile.outpost_owner != leader_team.team_id: continue
		if tile.outpost_level >= 3 or tile.construction_team_id != -1: continue
		if _dispatch_upgrader(state, leader_team, tile.tile_pos, tile.outpost_level + 1):
			return
	# (2) 擴建設施（faction 內所有 outpost；owner 以自身 local 資料評估，
	#     就地施工優先：owner 在場 > 居民團 > 派擴建子隊）
	for tile_id in state.world.tiles:
		var tile: HexTileData = state.world.tiles[tile_id]
		if tile.outpost_level == 0: continue
		if tile.construction_team_id != -1:
			_try_resume_construction(state, tile, leader_team)
			continue
		var owner_team: TeamData = state.teams.get(tile.outpost_owner)
		if owner_team == null: continue
		if owner_team.team_id != leader_team.team_id \
				and (owner_team.faction_id != leader_team.faction_id or owner_team.faction_id == -1):
			continue
		# 玩家 team 不自動決策
		if owner_team.leader_id == state.player_id and state.player_id != -1: continue
		var owner_leader: PersonData = state.persons.get(owner_team.leader_id)
		if owner_leader == null: continue
		var pick: Dictionary = _pick_facility(state, owner_team, tile, owner_leader)
		if pick.is_empty(): continue
		if pick.has("demolish_first"):
			OutpostSystem.new().demolish_facility(state, tile, pick["demolish_first"])
		# owner 在場 → 就地開工（居民村長 / 領主駐地）
		if owner_team.tile_pos == tile.tile_pos and owner_team.combat_target == -1 \
				and owner_team.current_task != TeamData.TASK_BUILD:
			if OutpostSystem.new()._subteam_upgrade_facility(state, owner_team, tile, pick["facility"]):
				return
		# tile 上同 faction 居民團出工出料
		var resident: TeamData = _resident_team_for_construction(state, tile)
		if resident != null:
			if OutpostSystem.new()._subteam_upgrade_facility(state, resident, tile, pick["facility"]):
				print("[Infra] Team%d 令居民 Team%d 就地擴建 %s at (%d,%d)" % [
					owner_team.team_id, resident.team_id, pick["facility"],
					tile.tile_pos.x, tile.tile_pos.y])
				return
		if _dispatch_facility_builder(state, owner_team, tile.tile_pos, pick["facility"]):
			return
	# (3) 蓋新 outpost
	var loc: Dictionary = _evaluate_new_outpost_location(state, leader_team)
	if loc.is_empty(): return
	var outpost_type: String = _pick_outpost_type(leader)
	_dispatch_builder(state, leader_team, loc.pos, outpost_type, 1)

# ──────── 設施需求迴路（score = 地利 × (1+缺口) × 個性）────────

# 回傳 { "facility": name, "demolish_first"?: name }；{} = 不蓋
func _pick_facility(state: WorldState, team: TeamData, tile: HexTileData,
		leader: PersonData) -> Dictionary:
	var slot_full: bool = OutpostSystem.slots_used(tile) >= OutpostSystem.slot_cap(tile)
	var hungry: bool = float(team.resources.get("food", 0)) \
		< float(team.population) * 2.4 * 7.0
	# 飢餓 override：缺糧 → 農田最優先（slot 滿可拆遷搶 slot）
	if hungry and tile.outpost_type == "civilian" \
			and int(tile.farming_level) == 0:
		if not slot_full:
			return { "facility": "farming" }
		var lowest: String = _lowest_score_facility(state, team, tile, leader)
		if lowest != "":
			return { "facility": "farming", "demolish_first": lowest }
		return {}
	var best: String = ""
	var best_score: float = 0.05   # 門檻：score 太低不蓋（TEST VALUE）
	for f in OutpostSystem.FACILITY_DEF:
		var def: Dictionary = OutpostSystem.FACILITY_DEF[f]
		if not (tile.outpost_type in def["allowed_outpost"]): continue
		if def.has("required_terrain") and tile.terrain != def["required_terrain"]: continue
		var current: int = int(tile.get(def["current_level_key"]))
		if current > 0: continue          # 已有 → 升級走另一路徑
		if slot_full: continue
		var s: float = _facility_score(state, team, tile, leader, f)
		if s > best_score:
			best_score = s
			best = f
	if best == "": return {}
	return { "facility": best }

func _facility_score(state: WorldState, team: TeamData, tile: HexTileData,
		leader: PersonData, facility: String) -> float:
	return _facility_terrain_fit(state, facility, tile) \
		* (1.0 + _facility_deficit(state, team, facility, tile)) \
		* _facility_personality(leader, OutpostSystem.FACILITY_DEF[facility])

# 拆遷候選：已建設施中 score 最低者（農田不拆）
func _lowest_score_facility(state: WorldState, team: TeamData, tile: HexTileData,
		leader: PersonData) -> String:
	var lowest: String = ""
	var lowest_score: float = INF
	for f in OutpostSystem.FACILITY_DEF:
		if f == "farming": continue
		var def: Dictionary = OutpostSystem.FACILITY_DEF[f]
		if int(tile.get(def["current_level_key"])) == 0: continue
		var s: float = _facility_score(state, team, tile, leader, f)
		if s < lowest_score:
			lowest_score = s
			lowest = f
	return lowest

# 地利（本格+鄰 6 格觀察，不全知）。TEST VALUES
func _facility_terrain_fit(state: WorldState, facility: String, tile: HexTileData) -> float:
	match facility:
		"farming":
			return clampf(tile.harvest_factor, 0.1, 2.0)
		"workshop":
			return 2.0 if _nearby_has_terrain(state, tile, "forest") else 1.0
		"apothecary":
			return 3.0 if _nearby_resource(state, tile, ["herb"]) > 0.0 else 0.0
		"smeltery", "weaponsmith", "armorsmith":
			return 3.0 if _nearby_resource(state, tile, ["ore_iron"]) > 0.0 else 0.5
		"mint":
			return 3.0 if _nearby_resource(state, tile, ["ore_gold", "ore_silver"]) > 0.0 else 0.3
		"stable":
			# required_terrain=plains 已 gate；鄰格野馬 → ×3
			return 3.0 if _nearby_resource(state, tile, ["wild_horses"]) > 0.0 else 1.0
	return 1.0

# 缺口（自身庫存 threshold，0–1）。TEST VALUES
func _facility_deficit(state: WorldState, team: TeamData, facility: String,
		tile: HexTileData) -> float:
	var pop: float = maxf(float(team.population), 1.0)
	match facility:
		"farming":
			var target: float = pop * 2.4 * 14.0
			return clampf((target - float(team.resources.get("food", 0))) / target, 0.0, 1.0)
		"workshop":
			var worst: float = 1.0
			for res in ["goods", "tools", "arrows"]:
				var tgt: float = float(InteractionSystem.TARGET_PER_POP.get(res, 1.0)) * pop
				worst = minf(worst, float(team.resources.get(res, 0)) / maxf(tgt, 0.001))
			return clampf(1.0 - worst, 0.0, 1.0)
		"apothecary":
			var med_tgt: float = pop * 0.2
			return clampf((med_tgt - float(team.resources.get("medicine", 0))) \
				/ maxf(med_tgt, 0.001), 0.0, 1.0) * 0.5
		"weaponsmith":
			if not _threat_recent(state, team): return 0.0
			return clampf(0.6 - team.armed_anon_ratio, 0.0, 1.0)
		"armorsmith":
			if not _threat_recent(state, team): return 0.0
			var armor: float = float(team.resources.get("armor_low", 0)) \
				+ float(team.resources.get("armor_high", 0))
			var a_tgt: float = pop * 0.3
			return clampf((a_tgt - armor) / maxf(a_tgt, 0.001), 0.0, 1.0)
		"smeltery":
			# 武器/護甲坊存在且 steel 缺
			if tile.weaponsmith_level == 0 and tile.armorsmith_level == 0: return 0.0
			var s_tgt: float = pop * 0.75
			return clampf((s_tgt - float(team.resources.get("ore_steel", 0))) \
				/ maxf(s_tgt, 0.001), 0.0, 1.0)
		"mint":
			var ore: float = float(tile.public_storage.get("ore_gold", 0)) \
				+ float(tile.public_storage.get("ore_silver", 0))
			return 1.0 if ore > 10.0 else 0.0
		"stable":
			var m_tgt: float = pop * MOUNT_TARGET_RATIO
			return clampf((m_tgt - float(team.resources.get("mounts", 0))) \
				/ maxf(m_tgt, 0.001), 0.0, 1.0)
	return 0.0

# 個性：1.0 + Σ values × pref
func _facility_personality(leader: PersonData, def: Dictionary) -> float:
	var mult: float = 1.0
	var pref: Dictionary = def.get("leader_pref", {})
	for k in pref:
		mult += float(leader.values.get(k, 0.5)) * float(pref[k])
	return mult

# 近期威脅：戰鬥中 / 有攻擊意圖 / 已知低評價 team
func _threat_recent(state: WorldState, team: TeamData) -> bool:
	if team.combat_target != -1 or team.prosperity_target_id != -1:
		return true
	for tid in team.known_reputations:
		if float(team.known_reputations[tid]) < 0.3 and state.teams.has(tid):
			return true
	return false

func _nearby_resource(state: WorldState, tile: HexTileData, keys: Array) -> float:
	var total: float = 0.0
	var positions: Array = [tile.tile_pos]
	for d in PathSystem.HEX_DIRS:
		positions.append(tile.tile_pos + d)
	for pos in positions:
		var t: HexTileData = state.world.tiles.get(pos.x * 1000 + pos.y)
		if t == null: continue
		for k in keys:
			total += float(t.resources.get(k, 0))
	return total

func _nearby_has_terrain(state: WorldState, tile: HexTileData, terrain: String) -> bool:
	for d in PathSystem.HEX_DIRS:
		var pos: Vector2i = tile.tile_pos + d
		var t: HexTileData = state.world.tiles.get(pos.x * 1000 + pos.y)
		if t != null and t.terrain == terrain:
			return true
	return false

func _richest_member(state: WorldState, f) -> int:
	var best_tid: int    = -1
	var best_food: float = 0.0
	for mid in f.member_team_ids:
		if mid == f.leader_team_id or not state.teams.has(mid):
			continue
		var snap: Dictionary = f.known_member_states.get(mid, {})
		var mfood: float = float(snap.get("food_est", 0.0))
		if mfood > best_food:
			best_food = mfood
			best_tid  = mid
	return best_tid

func _evaluate_survival(state: WorldState, team: TeamData) -> void:
	if team.leader_id == state.player_id and state.player_id != -1:
		return
	if team.current_task in SURVIVAL_TASKS:
		return
	var pop_eff: int = team.population
	if pop_eff <= 0: return
	var food: float = float(team.resources.get("food", 0))
	var food_per_day: float = float(pop_eff) * FOOD_PER_PERSON_PER_DAY_SURVIVAL
	var days_left: float = food / maxf(food_per_day, 0.001)
	if days_left < URGENCY_DAYS or days_left < WARNING_DAYS:
		var severity: String = "urgent" if days_left < URGENCY_DAYS else "warning"
		var prev_task: String = team.current_task
		_trigger_survival(state, team, severity)
		if team.current_task != prev_task:
			print("[Survival] Team%d %s days_left=%.1f %s→%s" % [
				team.team_id, severity, days_left, prev_task, team.current_task])

func _trigger_survival(state: WorldState, team: TeamData, severity: String) -> void:
	var leader: PersonData = state.persons.get(team.leader_id)
	if leader == null: return

	team.previous_task = team.current_task

	# 正在腳下工地蓋「農田」→ 建設即自救，不中斷（農田完工才是糧食出路，工期僅 3 天）
	# 其他設施（鑄幣廠 30 天等）照常被飢餓中斷 — 不會蓋到餓死
	if team.current_task == TeamData.TASK_BUILD:
		var cur_tile: HexTileData = state.world.tiles.get(
			team.tile_pos.x * 1000 + team.tile_pos.y)
		if cur_tile != null and cur_tile.construction_team_id == team.team_id \
				and str(cur_tile.construction_target.get("facility", "")) == "farming":
			team.previous_task = ""
			return

	# Path 1: 有 own outpost → 回家（B 分支：遠 outpost + 殘忍/好戰 → 就近掠）
	var own_pos: Vector2i = _find_own_outpost(state, team)
	if own_pos != Vector2i(-1, -1):
		var own_eta_days: float = float(_estimate_eta_to(state, team, own_pos)) / 240.0
		var ferocity_ok: bool = (
			float(leader.values.get("殘忍", 0.5)) > 0.5
			or float(leader.values.get("好戰", 0.5)) > 0.6
		)
		if own_eta_days > 5.0 and ferocity_ok:
			var prey_id: int = _find_weakest_prey(state, team)
			if prey_id != -1:
				# 同上：combat_target 不預設，到達由 interaction 起戰
				if TaskArbiter.try_set(state, team, TeamData.TASK_LOOT,
						state.teams[prey_id].tile_pos, TaskArbiter.PRIO_SURVIVAL, "survival"):
					team.prosperity_target_id = prey_id
					print("[SurvivalLoot] team=Team%d 遠 outpost(%.1f日) → 掠 Team%d" % [
						team.team_id, own_eta_days, prey_id])
				return
		if severity == "warning" and not _should_abandon_current_task(team, own_pos):
			team.previous_task = ""
			return
		TaskArbiter.try_set(state, team, "return_home", own_pos,
			TaskArbiter.PRIO_SURVIVAL, "survival")
		return

	# Path 2: 殘忍/好戰 + 有獵物 → 掠奪
	if float(leader.values.get("殘忍", 0.5)) > 0.5 \
			or float(leader.values.get("好戰", 0.5)) > 0.6:
		var prey_id: int = _find_weakest_prey(state, team)
		if prey_id != -1:
			if TaskArbiter.try_set(state, team, TeamData.TASK_LOOT,
					state.teams[prey_id].tile_pos, TaskArbiter.PRIO_SURVIVAL, "survival"):
				team.combat_target = prey_id
			return

	# Path 3: 義氣 + 信義 → 投靠
	var honor_sum: float = float(leader.values.get("義氣", 0.5)) \
		+ float(leader.values.get("信義", 0.5))
	if honor_sum > 1.2:
		var ally_id: int = _find_strong_neighbor(state, team)
		if ally_id != -1:
			if TaskArbiter.try_set(state, team, "投靠",
					state.teams[ally_id].tile_pos, TaskArbiter.PRIO_SURVIVAL, "survival"):
				team.combat_target = ally_id
			return

	# Path 4: 默認 → 乞食
	var aid_target: int = _find_aid_target(state, team)
	if aid_target != -1:
		if TaskArbiter.try_set(state, team, "乞食",
				state.teams[aid_target].tile_pos, TaskArbiter.PRIO_SURVIVAL, "survival"):
			team.combat_target = aid_target
		return
	# 全失敗 → 就地乞食（無具體目標，move_target 保留原值）
	TaskArbiter.try_set(state, team, "乞食", team.move_target,
		TaskArbiter.PRIO_SURVIVAL, "survival")

func _should_abandon_current_task(team: TeamData, survival_target: Vector2i) -> bool:
	if team.move_target == Vector2i(-1, -1):
		return true
	var cur_dist: int = _hex_dist(team.tile_pos, team.move_target)
	var surv_dist: int = _hex_dist(team.tile_pos, survival_target)
	return surv_dist <= cur_dist + 2

func _find_own_outpost(state: WorldState, team: TeamData) -> Vector2i:
	for tile_id in state.world.tiles:
		var tile: HexTileData = state.world.tiles[tile_id]
		if tile.outpost_level > 0 and tile.outpost_owner == team.team_id:
			return tile.tile_pos
	return Vector2i(-1, -1)

func _estimate_eta_to(state: WorldState, team: TeamData, target: Vector2i) -> int:
	var path: Dictionary = PathSystem.find_path(state, team.tile_pos, target)
	if path.path.is_empty(): return 9999999
	return PathSystem.eta_ticks(team, path.cost)

func _find_weakest_prey(state: WorldState, team: TeamData) -> int:
	var best_id: int = -1
	var best_pop: int = 999999
	for tid in state.team_discovered.get(team.team_id, []):
		if tid == team.team_id: continue
		var t: TeamData = state.teams.get(tid)
		if t == null: continue
		if not PathSystem.estimate_catch_up(state, team, tid).reachable: continue
		if t.population >= int(float(team.population) * 0.7): continue
		if float(t.resources.get("food", 0)) < 20.0: continue
		if t.population < best_pop:
			best_pop = t.population
			best_id = tid
	return best_id

func _find_strong_neighbor(state: WorldState, team: TeamData) -> int:
	var best_id: int = -1
	var best_pop: int = 0
	for tid in state.team_discovered.get(team.team_id, []):
		if tid == team.team_id: continue
		var t: TeamData = state.teams.get(tid)
		if t == null: continue
		if not PathSystem.estimate_catch_up(state, team, tid).reachable: continue
		if t.faction_id != -1 and t.faction_id == team.faction_id: continue
		var rep: float = float(team.known_reputations.get(tid, 0.5))
		if rep <= 0.3: continue
		if t.population <= int(float(team.population) * 1.5): continue
		if t.population > best_pop:
			best_pop = t.population
			best_id = tid
	return best_id

func _find_aid_target(state: WorldState, team: TeamData) -> int:
	var candidates: Array = []
	for tid in state.team_discovered.get(team.team_id, []):
		if tid == team.team_id: continue
		var t: TeamData = state.teams.get(tid)
		if t == null: continue
		var reserve: float = float(t.population) * 14.0
		if float(t.resources.get("food", 0)) <= reserve: continue
		var catch_result: Dictionary = PathSystem.estimate_catch_up(state, team, tid)
		if not catch_result.reachable: continue
		var same_faction: bool = (t.faction_id != -1 and t.faction_id == team.faction_id)
		var rep: float = float(team.known_reputations.get(tid, 0.5))
		var score: float = 0.0
		if same_faction: score += 1000.0
		if rep >= 0.5: score += 100.0
		score -= float(int(catch_result.eta) / 60)
		candidates.append({ "tid": tid, "score": score })
	if candidates.is_empty():
		return -1
	candidates.sort_custom(func(a, b): return a["score"] > b["score"])
	return int(candidates[0]["tid"])

func _declare_established(state: WorldState, f, leader_team: TeamData) -> void:
	f.is_established = true
	f.faction_name   = "勢力%d" % f.faction_id
	f.goals.erase("立國")
	SimMessageSystem.new().emit_message(state, "faction_establish",
		TextBank.fmt("faction_establish", "honest", {
			"origin": str(f.leader_team_id), "name": f.faction_name
		}),
		leader_team,
		{ "origin": str(f.leader_team_id), "name": f.faction_name })
	print("[Faction] 立國：%s（leader=Team%d，%d teams）" % [
		f.faction_name, f.leader_team_id, f.member_team_ids.size()])

const OUTPOST_TAKEOVER_DAYS: int = 3

# D B2: 任何 team 駐留無人 outpost 滿 3 天 → 自動接管
func _evaluate_outpost_takeover(state: WorldState, team: TeamData) -> void:
	var tile: HexTileData = state.world.tiles.get(team.tile_pos.x * 1000 + team.tile_pos.y)
	if tile == null or tile.outpost_level == 0:
		team.occupying_outpost_since = -1
		return
	if tile.outpost_owner == team.team_id:
		team.occupying_outpost_since = -1
		return
	if tile.outpost_owner != -1:
		team.occupying_outpost_since = -1
		return
	if team.occupying_outpost_since == -1:
		team.occupying_outpost_since = state.world.current_tick
		return
	if state.world.current_tick - team.occupying_outpost_since >= OUTPOST_TAKEOVER_DAYS * WorldState.TICKS_PER_DAY:
		tile.outpost_owner = team.team_id
		team.occupying_outpost_since = -1
		print("[Takeover] Team%d 接管無人 outpost (%d,%d)" % [
			team.team_id, team.tile_pos.x, team.tile_pos.y])

func _evaluate_uprising(state: WorldState, team: TeamData) -> void:
	if not _is_resident_team(state, team): return
	if team.current_task in ["起義", "守城"]: return
	if team.current_task in SURVIVAL_TASKS: return
	var avg_loy: float = _avg_named_loyalty(state, team)
	if avg_loy >= 0.2: return
	if team.unrest_turns < 60: return
	if _count_stress_sources(state, team) < 2: return
	var leader: PersonData = state.persons.get(team.leader_id)
	if leader == null: return
	var tile: HexTileData = state.world.tiles.get(team.tile_pos.x * 1000 + team.tile_pos.y)
	var old_owner_id: int = tile.outpost_owner if tile else -1
	var ambition: float = float(leader.values.get("野心", 0.5))
	var prudence: float = float(leader.values.get("慎重", 0.5))
	var honor: float    = float(leader.values.get("義氣", 0.5))
	var survival: float = float(leader.values.get("求生欲", 0.5))
	var stand_score: float = ambition * 0.5 + prudence * 0.3 + honor * 0.2
	var flee_score: float  = survival * 0.5 + (1.0 - honor) * 0.3
	var stand: bool = stand_score > flee_score
	# 起義 = PRIO_THREAT (70)：反抗行為，玩家命令 (60) 壓不住；被擋（combat lock）→ 不執行後續副作用
	if stand:
		if not TaskArbiter.try_set(state, team, "守城", team.move_target,
				TaskArbiter.PRIO_THREAT, "uprising"):
			return
	else:
		if not TaskArbiter.try_set(state, team, "起義", Vector2i(-1, -1),
				TaskArbiter.PRIO_THREAT, "uprising"):
			return
	# C: 起義 → 取消進行中施工（無論守城/流亡路徑）
	if tile and tile.construction_team_id != -1:
		tile.construction_team_id    = -1
		tile.construction_ticks_left = 0
		tile.construction_target     = {}
		print("[Uprising] cancel construction at (%d,%d)" % [team.tile_pos.x, team.tile_pos.y])
	if stand:
		# Path A 守城：奪取 outpost、自立（保留 PRODUCE 身分）
		team.faction_id = -1
		if tile: tile.outpost_owner = team.team_id
		print("[Uprising A] Team%d 守城（野心=%.2f，old owner=Team%d）" % [
			team.team_id, ambition, old_owner_id])
	else:
		# Path B 流亡（原 spec E 邏輯）
		team.faction_id = -1
		team.tags.erase(TeamData.TAG_PRODUCE)
		team.tags.append("流亡")
		print("[Uprising B] Team%d 流亡（求生=%.2f，old owner=Team%d）" % [
			team.team_id, survival, old_owner_id])
	if old_owner_id != -1:
		NpcAiSystem.new().write_memory(leader, "enemy", old_owner_id,
			state.world.current_tick, 1.0)
	# 鄰格 PRODUCE team cascade fear
	for tid in state.teams:
		var t: TeamData = state.teams[tid]
		if not t.tags.has(TeamData.TAG_PRODUCE): continue
		if _hex_dist(team.tile_pos, t.tile_pos) > 2: continue
		for pid in ([t.leader_id] as Array) + t.named_members:
			var p = state.persons.get(pid)
			if p: p.fear = minf(p.fear + 0.1, 1.0)
	# 玩家是 owner → forced event
	if old_owner_id != -1 and state.teams.has(old_owner_id):
		var oid_team: TeamData = state.teams[old_owner_id]
		if oid_team.leader_id == state.player_id and state.player_id != -1:
			state.player_forced_event = {
				"from_id": team.team_id, "action": "uprising_alert",
				"outpost_pos": team.tile_pos,
			}

func _avg_named_loyalty(state: WorldState, team: TeamData) -> float:
	var sum: float = 0.0
	var cnt: int = 0
	for pid in ([team.leader_id] as Array) + team.named_members:
		var p = state.persons.get(pid)
		if p:
			sum += p.loyalty
			cnt += 1
	return sum / maxf(cnt, 1)

func _count_stress_sources(state: WorldState, team: TeamData) -> int:
	var sources: int = 0
	if team.tax_rate > 0.5: sources += 1
	if float(team.resources.get("food", 0)) < float(team.population) * 7.0: sources += 1
	if team.unrest_turns > 40: sources += 1
	return sources

func _trigger_defection_evaluation(state: WorldState, team: TeamData, reason: String) -> void:
	var leader = state.persons.get(team.leader_id)
	if leader == null: return
	var honor: float = float(leader.values.get("義氣", 0.5))
	var prudence: float = float(leader.values.get("慎重", 0.5))
	var ambition: float = float(leader.values.get("野心", 0.5))
	var has_benefactor_memory: float = 0.3 if _has_memory_type(leader, "benefactor") else 0.0
	var a_score: float = honor + has_benefactor_memory
	var b_score: float = prudence
	var c_score: float = ambition - honor * 0.3
	if a_score >= b_score and a_score >= c_score:
		print("[Defection] Team%d path A: 留 faction (原因=%s)" % [team.team_id, reason])
		# faction_id 不變，task=待命新領主（隨時可被高層蓋 → AMBIENT 就地轉換）
		TaskArbiter.transition(team, "等待新領主", TaskArbiter.PRIO_AMBIENT)
	elif b_score >= c_score:
		print("[Defection] Team%d path B: 投降強鄰" % team.team_id)
		var strong_id: int = _find_strong_neighbor(state, team)
		if strong_id != -1:
			team.faction_id = state.teams[strong_id].faction_id
		else:
			team.faction_id = -1
	else:
		print("[Defection] Team%d path C: 獨立" % team.team_id)
		team.faction_id = -1

func _has_memory_type(person: PersonData, type: String) -> bool:
	for m in person.memory:
		if m is Dictionary and m.get("type") == type:
			return true
	return false

func _evaluate_owner_contact(state: WorldState, team: TeamData) -> void:
	if not _is_resident_team(state, team): return
	var tile: HexTileData = state.world.tiles.get(team.tile_pos.x * 1000 + team.tile_pos.y)
	var owner_id: int = tile.outpost_owner if tile else -1
	if owner_id == -1 or not state.teams.has(owner_id):
		_trigger_defection_evaluation(state, team, "owner_gone")
		return
	var intel: Dictionary = state.team_intel.get(team.team_id, {})
	var snap: Dictionary = intel.get(owner_id, {})
	var last_tick: int = int(snap.get("last_tick", -1))
	if last_tick == -1:
		return   # 從未接觸（剛建立可能）
	var days_since: int = (state.world.current_tick - last_tick) / WorldState.TICKS_PER_DAY
	if days_since > CONTACT_TIMEOUT_DAYS:
		_trigger_defection_evaluation(state, team, "no_contact")
		return
	# owner leader 異動 → 7 天緩衝
	var owner_leader_now: int = int(snap.get("leader_id", -1))
	var cached_key: String = "_cached_owner_leader_%d" % owner_id
	var cached_owner_leader: int = int(team.known_reputations.get(cached_key, -2))
	if cached_owner_leader != -2 and cached_owner_leader != owner_leader_now:
		if team.pending_owner_change_tick == -1:
			team.pending_owner_change_tick = state.world.current_tick + OWNER_CHANGE_BUFFER_DAYS * WorldState.TICKS_PER_DAY
		elif state.world.current_tick >= team.pending_owner_change_tick:
			_trigger_defection_evaluation(state, team, "owner_changed")
			team.pending_owner_change_tick = -1
	elif team.pending_owner_change_tick != -1:
		team.pending_owner_change_tick = -1
	team.known_reputations[cached_key] = owner_leader_now
