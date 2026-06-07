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
const TRADEABLE_RES: Array = [
	"food", "material", "goods", "gem",
	"ore_gold", "ore_silver", "ore_iron", "ore_steel",
	"weapon_melee_low", "weapon_melee_high",
	"weapon_ranged_low", "weapon_ranged_high",
]

func evaluate_all(state: WorldState, _team_ids: Array) -> void:
	for fid in state.factions:
		var f = state.factions[fid]
		for mid in f.member_team_ids:
			var snap: Dictionary = state.team_intel.get(f.leader_team_id, {}).get(mid, {})
			if not snap.is_empty():
				f.known_member_states[mid] = snap
		_update_goals(state, f)
		_assign_tasks(state, f)
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
			sub.current_task = TeamData.TASK_IDLE
			if parent != null:
				sub.move_target = parent.tile_pos

	for tid in state.teams:
		if not state.teams.has(tid):
			continue
		var team: TeamData = state.teams[tid]
		# S11: leader 死亡自動繼承（無 leader 但有 named members）
		if team.leader_id == -1 and not team.named_members.is_empty():
			_promote_successor(state, team)
		_update_equip_order(state, team)
		_update_anon_combat_skill(team)
		_update_anon_wage(team)
		_update_armor_config(team)
		_update_guard_ratio(team, state)

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

	# G-09：檢查 player_commanded_task（loyalty 門檻）
	for tid_cmd in f.member_team_ids:
		var t_cmd: TeamData = state.teams.get(tid_cmd)
		if t_cmd == null or t_cmd.player_commanded_task.is_empty(): continue
		var leader_cmd: PersonData = state.persons.get(t_cmd.leader_id)
		var loyalty_cmd: float = leader_cmd.loyalty if leader_cmd else 0.5
		if loyalty_cmd >= 0.4:
			t_cmd.current_task = t_cmd.player_commanded_task
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
				leader_team.current_task = "徵收"
				leader_team.move_target  = target_pos
	if "立國" in f.goals:
		_declare_established(state, f, leader_team)
	if "外交" in f.goals and leader_team.current_task not in ["徵收", "外交", "攻擊"]:
		var target_id: int = _nearest_independent(state, leader_team)
		if target_id != -1:
			leader_team.current_task = "外交"
			leader_team.move_target  = state.teams[target_id].tile_pos
	if "攻擊" in f.goals and leader_team.current_task not in ["徵收", "外交", "攻擊"]:
		var target_id: int = _nearest_independent(state, leader_team)
		if target_id != -1:
			leader_team.current_task = "攻擊"
			leader_team.move_target  = state.teams[target_id].tile_pos
			print("[FactionAI] Team%d 主動攻擊 Team%d" % [f.leader_team_id, target_id])
	if "掠奪" in f.goals and leader_team.current_task not in ["徵收", "外交", "攻擊", "掠奪"]:
		var target_id: int = _nearest_independent(state, leader_team)
		if target_id != -1:
			leader_team.current_task = "掠奪"
			leader_team.move_target  = state.teams[target_id].tile_pos
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
		var absorber_id: int = _find_absorber(state, mt, f)
		if absorber_id != -1:
			var mt_leader = state.persons.get(mt.leader_id)
			var mt_cmd: float = float(mt_leader.skills.get("統領", 0.0)) if mt_leader else 0.0
			var mt_cap: int = TeamData.pop_cap_from_leadership(mt_cmd)
			var small_b: bool = mt.population < int(float(mt_cap) * SMALL_TEAM_RATIO)
			var small_c: bool = float(mt.population) < float(state.teams[absorber_id].population) * SMALL_VS_LARGE
			if small_b and small_c:
				mt.current_task    = TeamData.TASK_MERGE
				mt.order_target_id = absorber_id
				mt.move_target     = state.teams[absorber_id].tile_pos
				continue
		if "攻擊" in f.goals and leader_team != null:
			var dist_to_leader: int = _hex_dist(mt.tile_pos, leader_team.tile_pos)
			if dist_to_leader > 1 and dist_to_leader <= CONSOLIDATE_MAX_DIST:
				var ldr_leader = state.persons.get(leader_team.leader_id)
				var ldr_cmd: float = float(ldr_leader.skills.get("統領", 0.0)) if ldr_leader else 0.0
				var ldr_cap: int = TeamData.pop_cap_from_leadership(ldr_cmd) - leader_team.population
				if ldr_cap > 0:
					mt.current_task    = TeamData.TASK_MERGE
					mt.order_target_id = f.leader_team_id
					mt.move_target     = leader_team.tile_pos
					continue
		if "徵收" in f.goals and _tag_weight(mt, "徵收") > 0.0:
			var best_tid: int = _richest_member(state, f)
			if best_tid != -1 and best_tid != mid:
				mt.current_task = "徵收"
				mt.move_target  = state.teams[best_tid].tile_pos
		elif "外交" in f.goals and _tag_weight(mt, "外交") > 0.0:
			var target_id: int = _nearest_independent(state, mt)
			if target_id != -1:
				mt.current_task = "外交"
				mt.move_target  = state.teams[target_id].tile_pos
		elif "攻擊" in f.goals and _tag_weight(mt, "攻擊") > 0.0:
			var target_id: int = _nearest_independent(state, mt)
			if target_id != -1:
				mt.current_task = "攻擊"
				mt.move_target  = state.teams[target_id].tile_pos
		elif _can_manufacture(state, mt):
			mt.current_task = TeamData.TASK_MANUFACTURE
		elif _can_trade(state, mt):
			var pid: int = _find_trade_target(state, mt)
			if pid != -1:
				mt.current_task = TeamData.TASK_TRADE
				mt.move_target  = state.teams[pid].tile_pos

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
		team.current_task    = TeamData.TASK_IDLE
		team.move_target     = Vector2i(-1, -1)
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
		sub.current_task   = TeamData.TASK_IDLE
		sub.move_target    = Vector2i(-1, -1)
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
			sub.current_task = TeamData.TASK_LOOT
			sub.move_target  = state.teams[loot_target].tile_pos
			print("[SubAI] Team%d 偏離掠奪 Team%d" % [sub.team_id, loot_target])
			return true
		sub.current_task = TeamData.TASK_IDLE
		sub.move_target  = Vector2i(-1, -1)
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
			sub.current_task = best_task
			sub.move_target  = state.teams[tid].tile_pos
			print("[SubAI] Team%d idle→%s (Team%d)" % [sub.team_id, best_task, tid])
		else:
			sub.move_target = parent.tile_pos

# ──────── 獨立 Team 自主 AI ────────

func _evaluate_solo(state: WorldState, team: TeamData) -> void:
	if team.leader_id == state.player_id: return   # 玩家隊不受 SoloAI 控制
	if team.combat_target != -1 or team.current_task != "idle": return
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
	team.current_task = best_task
	match best_task:
		"攻擊", "掠奪", "外交":
			var tid: int = _nearest_independent(state, team)
			if tid != -1: team.move_target = state.teams[tid].tile_pos
		"逃跑":
			team.move_target = Vector2i(-1, -1)
		"製造":
			pass  # 製造在原地進行
		"貿易":
			var pid: int = _find_trade_target(state, team)
			if pid != -1:
				team.move_target = state.teams[pid].tile_pos
			else:
				team.current_task = TeamData.TASK_IDLE
	print("[SoloAI] Team%d → %s" % [team.team_id, best_task])

func _update_equip_order(state: WorldState, team: TeamData) -> void:
	var total_weapons: int = 0
	for wtype in ["melee_low", "melee_high", "ranged_low", "ranged_high"]:
		total_weapons += int(team.resources.get("weapon_" + wtype, 0))
	if total_weapons <= 0:
		return
	team.equip_order = { "melee_low": 0, "melee_high": 0, "ranged_low": 0, "ranged_high": 0 }
	var can_equip: int = total_weapons / 2
	if team.tags.has(TeamData.TAG_MILITARY) or team.current_task == TeamData.TASK_LOOT \
			or team.current_task == TeamData.TASK_ATTACK:
		var pool_mh: int = int(team.resources.get("weapon_melee_high", 0)) / 2
		var pool_rh: int = int(team.resources.get("weapon_ranged_high", 0)) / 2
		var pool_ml: int = int(team.resources.get("weapon_melee_low", 0)) / 2
		var pool_rl: int = int(team.resources.get("weapon_ranged_low", 0)) / 2
		team.equip_order["melee_high"]  = mini(pool_mh, can_equip)
		can_equip -= team.equip_order["melee_high"]
		team.equip_order["ranged_high"] = mini(pool_rh, can_equip)
		can_equip -= team.equip_order["ranged_high"]
		team.equip_order["melee_low"]   = mini(pool_ml, can_equip)
		can_equip -= team.equip_order["melee_low"]
		team.equip_order["ranged_low"]  = mini(pool_rl, can_equip)
	elif team.tags.has(TeamData.TAG_MERCHANT):
		var guard_count: int = mini(team.population * 3 / 10, can_equip)
		team.equip_order["melee_low"] = mini(int(team.resources.get("weapon_melee_low", 0)) / 2, guard_count)
	else:
		var guard_count: int = mini(team.population / 2, can_equip)
		team.equip_order["melee_low"] = mini(int(team.resources.get("weapon_melee_low", 0)) / 2, guard_count)

func _promote_successor(state: WorldState, team: TeamData) -> void:
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

func _update_anon_combat_skill(team: TeamData) -> void:
	var best: float = 0.25  # default
	for tag in team.tags:
		match tag:
			TeamData.TAG_MILITARY: best = maxf(best, 0.5)
			TeamData.TAG_MERCHANT: best = maxf(best, 0.2)
			TeamData.TAG_PRODUCE:  best = maxf(best, 0.15)
			TeamData.TAG_RELIGION: best = maxf(best, 0.2)
			TeamData.TAG_EXILE:    best = maxf(best, 0.3)
	team.anon_combat_skill = clampf(best, 0.1, 0.8)

func _update_anon_wage(team: TeamData) -> void:
	# 雙 accumulator：避免單 best 受 tag 順序影響
	var bonus:   float = 1.0   # 拉高項 max (MILITARY/MERCHANT)
	var penalty: float = 1.0   # 壓低項 min (PRODUCE/RELIGION/EXILE)
	for tag in team.tags:
		match tag:
			TeamData.TAG_MILITARY: bonus   = maxf(bonus,   1.5)
			TeamData.TAG_MERCHANT: bonus   = maxf(bonus,   1.2)
			TeamData.TAG_PRODUCE:  penalty = minf(penalty, 0.7)
			TeamData.TAG_RELIGION: penalty = minf(penalty, 0.5)
			TeamData.TAG_EXILE:    penalty = minf(penalty, 0.3)
	team.anon_wage = clampf(bonus * penalty, 0.0, 2.0)

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

func _find_trade_target(state: WorldState, merchant: TeamData) -> int:
	var best_id: int = -1
	var best_d:  int = 999
	for tid in state.team_discovered.get(merchant.team_id, []):
		if tid == merchant.team_id or not state.teams.has(tid): continue
		var snap: Dictionary = state.team_intel.get(merchant.team_id, {}).get(tid, {})
		var coin_est: float  = float(snap.get("coin_est", 0.0))
		if coin_est < TRADE_MIN_COIN: continue
		var d: int = _hex_dist(merchant.tile_pos, state.teams[tid].tile_pos)
		if d < best_d:
			best_d  = d
			best_id = tid
	return best_id

func _can_manufacture(state: WorldState, team: TeamData) -> bool:
	var tile_id: int      = team.tile_pos.x * 1000 + team.tile_pos.y
	var tile: HexTileData = state.world.tiles.get(tile_id)
	if tile == null or tile.outpost_type != "civilian" \
			or tile.manufacturing_level == 0 \
			or tile.outpost_owner != team.team_id:
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
