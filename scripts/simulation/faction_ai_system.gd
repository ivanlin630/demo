class_name FactionAISystem

const COLLECT_INTERVAL: int          = 30
const DISPATCH_DIST_THRESHOLD: int   = 2
const FOOD_EMERGENCY: float          = 3.0
const ESTABLISH_COMMAND: float       = 0.4
const ESTABLISH_AMBITION: float      = 0.7
const ESTABLISH_READINESS: float     = 0.7
const DIPLOMACY_READINESS_MIN: float = 0.6
const DISCIPLINE_FAIL_BASE: float    = 0.15

func evaluate_all(state: WorldState, _team_ids: Array) -> void:
	for fid in state.factions:
		var f = state.factions[fid]
		_update_goals(state, f)
		_assign_tasks(state, f)

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

	var leader_p = state.persons.get(leader_team.leader_id)
	var ambition: float = float(leader_p.values.get("野心",   0.5)) if leader_p else 0.5
	var greed:    float = float(leader_p.values.get("貪婪",   0.5)) if leader_p else 0.5
	var survival: float = float(leader_p.values.get("求生欲", 0.5)) if leader_p else 0.5
	var honor:    float = float(leader_p.values.get("義氣",   0.5)) if leader_p else 0.5
	var martial:  float = float(leader_p.values.get("好戰",   0.5)) if leader_p else 0.5

	var food_per_cap: float = float(leader_team.resources.get("food", 0)) / maxf(leader_team.population, 1)
	var effective_emergency: float = FOOD_EMERGENCY * (0.7 + survival * 0.6)
	var effective_interval:  int   = maxi(int(COLLECT_INTERVAL * (1.5 - greed)), 10)

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
		DIPLOMACY_READINESS_MIN - (ambition - 0.5) * 0.2, 0.3, 0.9)
	if f.is_established and leader_team.readiness >= diplomacy_readiness:
		if _has_independent(state):
			f.goals.append("外交")

	var attack_score: float = ambition * 0.4 + martial * 0.4 - honor * 0.4
	if f.is_established and attack_score > 0.3 \
			and leader_team.readiness >= 0.75 \
			and _has_independent(state) \
			and _tag_weight(leader_team, "攻擊") > 0.0:
		f.goals.append("攻擊")

# ──────── 任務指派 ────────

func _assign_tasks(state: WorldState, f) -> void:
	var leader_team: TeamData = state.teams.get(f.leader_team_id)
	if leader_team == null or leader_team.combat_target != -1:
		return
	if "徵收" in f.goals and leader_team.current_task != "徵收":
		var best_tid: int = _richest_member(state, f)
		if best_tid != -1:
			var target_pos: Vector2i = state.teams[best_tid].tile_pos
			var dist: int = _hex_dist(leader_team.tile_pos, target_pos)
			if dist > DISPATCH_DIST_THRESHOLD and leader_team.population >= 4 \
					and leader_team.advisors.size() > 0:
				var sub_leader_id: int = leader_team.advisors[0]
				var pop_count: int = maxi(leader_team.population / 4, 2)
				SubteamSystem.new().dispatch(state, f.leader_team_id, sub_leader_id,
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
	_assign_member_tasks(state, f)

func _assign_member_tasks(state: WorldState, f) -> void:
	for mid in f.member_team_ids:
		if mid == f.leader_team_id: continue
		var mt: TeamData = state.teams.get(mid)
		if mt == null or mt.combat_target != -1 or mt.current_task != "idle":
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

# ──────── 子團自主 AI ────────

func _evaluate_subteam(state: WorldState, sub: TeamData, merge_queue: Array) -> void:
	if sub.current_task == TeamData.TASK_ESCORT:
		_update_escort(state, sub)
		_check_discipline(state, sub)
		return
	if _check_discipline(state, sub):
		return
	# movement_system 到達時清 move_target；無目標且非 idle = 任務完成
	if sub.move_target == Vector2i(-1, -1) and sub.current_task != TeamData.TASK_IDLE:
		merge_queue.append(sub.team_id)
	elif sub.current_task == TeamData.TASK_IDLE:
		var parent: TeamData = state.teams.get(sub.parent_team_id)
		if parent == null:
			return
		if parent.tile_pos == sub.tile_pos:
			merge_queue.append(sub.team_id)
		else:
			sub.move_target = parent.tile_pos

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
	for aid in sub.advisors:
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

# ──────── 獨立 Team 自主 AI ────────

func _evaluate_solo(state: WorldState, team: TeamData) -> void:
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
	print("[SoloAI] Team%d → %s" % [team.team_id, best_task])

# ──────── 輔助函數 ────────

func _has_independent(state: WorldState) -> bool:
	for tid in state.teams:
		if state.teams[tid].faction_id == -1:
			return true
	return false

func _nearest_independent(state: WorldState, from_team: TeamData) -> int:
	var best_id: int = -1
	var best_d: int  = 999
	for tid in state.teams:
		var t: TeamData = state.teams[tid]
		if t.faction_id != -1 or t.team_id == from_team.team_id:
			continue
		var d: int = _hex_dist(from_team.tile_pos, t.tile_pos)
		if d < best_d:
			best_d  = d
			best_id = tid
	return best_id

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
		var mfood: float = float(state.teams[mid].resources.get("food", 0))
		if mfood > best_food:
			best_food = mfood
			best_tid  = mid
	return best_tid

func _declare_established(state: WorldState, f, leader_team: TeamData) -> void:
	f.is_established = true
	f.faction_name   = "勢力%d" % f.faction_id
	f.goals.erase("立國")
	SimMessageSystem.new().emit_message(state, "faction_establish",
		"%s 正式立國（leader=Team%d，%d teams）" % [
			f.faction_name, f.leader_team_id, f.member_team_ids.size()],
		leader_team)
	print("[Faction] 立國：%s（leader=Team%d，%d teams）" % [
		f.faction_name, f.leader_team_id, f.member_team_ids.size()])
