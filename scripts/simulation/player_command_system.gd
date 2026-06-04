# scripts/simulation/player_command_system.gd
class_name PlayerCommandSystem

var _interaction: InteractionSystem = InteractionSystem.new()
var _diplomatic:  DiplomaticAiSystem = DiplomaticAiSystem.new()
var _subteam: SubteamSystem = SubteamSystem.new()

# ── 主動互動 ────────────────────────────────────────────────

# 查詢對 target_id 可用的行動（已過濾條件）
# 返回 Array[String]，子集合自：
#   "ignore"           → 永遠可選
#   "attack"           → 永遠可選
#   "trade"            → target 有 coin OR 玩家有 coin
#   "propose_alliance" → target 非同勢力
#   "demand_tribute"   → 玩家 population > target.population × 1.5
#   "extort"           → 玩家 readiness >= 0.7
#   "recruit"          → 永遠可選（STUB — 招募邏輯尚未實裝）
func get_available_actions(state: WorldState, target_id: int) -> Array[String]:
	var actions: Array[String] = ["ignore", "attack"]
	var pt: TeamData  = _get_player_team(state)
	var tgt: TeamData = state.teams.get(target_id)
	if pt == null or tgt == null:
		return actions
	if _can_trade(state, pt, tgt):
		actions.append("trade")
	if tgt.faction_id != pt.faction_id:
		actions.append("propose_alliance")
	if pt.population > int(tgt.population * 1.5):
		actions.append("demand_tribute")
	if pt.readiness >= 0.7:
		actions.append("extort")
	actions.append("recruit")   # STUB
	return actions

# 執行玩家主動行動
# 返回 { "ok": bool, "msg": String }
func execute_action(state: WorldState, target_id: int, action: String) -> Dictionary:
	var pt: TeamData = _get_player_team(state)
	var pt_id: int   = _get_player_team_id(state)
	if pt == null:
		return { "ok": false, "msg": "找不到玩家 team" }
	match action:
		"trade":
			var result := _interaction.resolve_trade_direct(state, pt_id, target_id)
			state.player_pending_targets.erase(target_id)
			return result
		"propose_alliance":
			var tgt: TeamData = state.teams.get(target_id)
			if tgt == null:
				return { "ok": false, "msg": "目標不存在" }
			var resp: String = _diplomatic.handle_diplomacy_message(
				state, tgt, pt, "propose_alliance")
			state.player_pending_targets.erase(target_id)
			return { "ok": resp == "accept", "msg": "外交結果: %s" % resp }
		"demand_tribute":
			var tgt: TeamData = state.teams.get(target_id)
			if tgt == null:
				return { "ok": false, "msg": "目標不存在" }
			var resp: String = _diplomatic.handle_diplomacy_message(
				state, tgt, pt, "demand_tribute")
			state.player_pending_targets.erase(target_id)
			return { "ok": resp == "accept", "msg": "納貢結果: %s" % resp }
		"attack":
			var tgt: TeamData = state.teams.get(target_id)
			if tgt == null:
				return { "ok": false, "msg": "目標不存在" }
			state.encounter_attacker_id = pt_id
			state.encounter_defender_id = target_id
			state.encounter_active      = true
			if not state.player_hostile_teams.has(target_id):
				state.player_hostile_teams.append(target_id)
			state.player_pending_targets.erase(target_id)
			print("[PlayerCmd] 玩家發起攻擊 Team%d → Team%d" % [pt_id, target_id])
			return { "ok": true, "msg": "發起攻擊" }
		"extort":
			var result := _interaction.resolve_extortion_direct(state, pt_id, target_id)
			state.player_pending_targets.erase(target_id)
			return result
		"recruit":
			# STUB — 招募邏輯尚未實裝（說服/付費/目標成員選擇）
			state.player_pending_targets.erase(target_id)
			return { "ok": false, "msg": "招募功能尚未實裝" }
		"ignore":
			state.player_pending_targets.erase(target_id)
			return { "ok": true, "msg": "忽略" }
		"order_faction_member":
			return _action_order_faction_member(state, target_id, pt, pt_id)
	return { "ok": false, "msg": "未知行動: %s" % action }

# ── 被動回應（NPC 強制非戰互動）────────────────────────────

# 查詢 forced_event 的回應選項
# "diplomacy" → ["accept", "refuse"]
# "extort"    → ["pay", "refuse"]
func get_forced_response_options(state: WorldState) -> Array[String]:
	match state.player_forced_event.get("action", ""):
		"diplomacy": return ["accept", "refuse"]
		"extort":    return ["pay", "refuse"]
	return []

# 回應強制互動，清除 forced_event
# 返回 { "ok": bool, "msg": String }
func respond_to_forced(state: WorldState, response: String) -> Dictionary:
	var fe: Dictionary = state.player_forced_event
	if fe.is_empty():
		return { "ok": false, "msg": "無待處理強制事件" }
	var result: Dictionary
	match fe.get("action", ""):
		"diplomacy":
			if response == "accept":
				result = _accept_diplomacy(state,
					fe.get("from_id", -1), fe.get("proposal", "alliance"))
			else:
				result = { "ok": true, "msg": "拒絕外交提案" }
		"extort":
			if response == "pay":
				result = _pay_extortion(state, fe.get("from_id", -1))
			else:
				result = { "ok": true, "msg": "拒絕勒索" }
		_:
			result = { "ok": false, "msg": "未知強制事件類型" }
	state.player_forced_event = {}
	state.player_forced_event_id = ""
	return result

func resolve_forced_response(state: WorldState, interaction_id: String, response_id: String) -> Dictionary:
	if state.player_forced_event.is_empty():
		return {"ok": false, "code": "forced_response_missing", "msg": "no active forced interaction"}
	if interaction_id != "" and interaction_id != state.player_forced_event_id:
		return {"ok": false, "code": "forced_response_missing", "msg": "interaction expired or wrong id"}
	var valid: Array[String] = get_forced_response_options(state)
	if not valid.has(response_id):
		return {"ok": false, "code": "forced_response_invalid", "msg": "invalid response_id: %s" % response_id}
	return respond_to_forced(state, response_id)

# ── 清除 pending ─────────────────────────────────────────────

# 玩家 team 格子改變時呼叫（SimRunner 負責呼叫）
# player_forced_event 不清除（NPC 外交/勒索不因移動取消）
func clear_pending_targets(state: WorldState) -> void:
	state.player_pending_targets.clear()

# 玩家主動按下互動鍵（T）時呼叫：掃描同格 NPC，加入 pending_targets
# 讓 ignore 後仍可再次主動觸發互動
func refresh_colocation_targets(state: WorldState) -> void:
	var pt: TeamData = _get_player_team(state)
	if pt == null:
		return
	for other_id in state.teams:
		if other_id == pt.team_id:
			continue
		var other: TeamData = state.teams[other_id]
		if other.tile_pos != pt.tile_pos:
			continue
		if state.player_hostile_teams.has(other_id):
			continue
		if other.combat_target != -1:
			continue
		if not state.player_pending_targets.has(other_id):
			state.player_pending_targets.append(other_id)

# ── 內部 helper ──────────────────────────────────────────────

func _get_player_team(state: WorldState) -> TeamData:
	var p: PersonData = state.persons.get(state.player_id)
	if p == null:
		return null
	return state.teams.get(p.team_id)

func _get_player_team_id(state: WorldState) -> int:
	var p: PersonData = state.persons.get(state.player_id)
	return p.team_id if p != null else -1

func _can_trade(state: WorldState, pt: TeamData, tgt: TeamData) -> bool:
	# 雙方任一有 coin 即可嘗試貿易（細節由 resolve_trade_direct 判定）
	return float(pt.resources.get("coin", 0)) > 0.0 \
		or float(tgt.resources.get("coin", 0)) > 0.0

func _accept_diplomacy(state: WorldState, from_id: int, proposal: String) -> Dictionary:
	var from_team: TeamData = state.teams.get(from_id)
	var pt: TeamData = _get_player_team(state)
	if from_team == null or pt == null:
		return { "ok": false, "msg": "隊伍不存在" }
	match proposal:
		"alliance", "surrender":
			# 雙方皆獨立時 _form_alliance 無效，需先建立勢力
			if from_team.faction_id == -1 and pt.faction_id == -1:
				state.create_faction(from_id)   # NPC 為領袖
			_diplomatic._form_alliance(state, from_team, pt)
			return { "ok": true, "msg": "接受同盟，加入勢力%d" % from_team.faction_id }
		"tribute":
			return _pay_extortion(state, from_id)
	return { "ok": false, "msg": "未知提案類型：%s" % proposal }

func _pay_extortion(state: WorldState, from_id: int) -> Dictionary:
	# 轉移資源給 from_id（金額由 _resolve_extortion 計算）
	var pt_id: int = _get_player_team_id(state)
	if pt_id == -1:
		return { "ok": false, "msg": "找不到玩家 team" }
	_interaction.resolve_extortion_direct(state, from_id, pt_id)
	return { "ok": true, "msg": "支付勒索" }

# ── 查詢 API（Phase 1 新增） ─────────────────────────

func get_player_team(state: WorldState) -> TeamData:
	var p: PersonData = state.persons.get(state.player_id)
	if p == null: return null
	return state.teams.get(p.team_id)

func get_player_person(state: WorldState) -> PersonData:
	return state.persons.get(state.player_id)

func inspect_team(state: WorldState, team_id: int) -> Dictionary:
	var t: TeamData = state.teams.get(team_id)
	if t == null: return {}
	var leader: PersonData = state.persons.get(t.leader_id)
	var members: Array = []
	for pid in t.named_members:
		var p: PersonData = state.persons.get(pid)
		if p:
			members.append({
				"id": p.id, "name": p.person_name, "role": p.role,
				"loyalty": p.loyalty, "fatigue": p.stress
			})
	var leader_info: Dictionary = {}
	if leader:
		leader_info = { "id": leader.id, "name": leader.person_name }
	return {
		"team_id": t.team_id, "tile_pos": t.tile_pos, "population": t.population,
		"fatigue": t.fatigue, "current_task": t.current_task,
		"faction_id": t.faction_id, "tags": t.tags,
		"leader": leader_info, "named_members": members,
		"resources": t.resources
	}

func inspect_member(state: WorldState, person_id: int) -> Dictionary:
	var p: PersonData = state.persons.get(person_id)
	if p == null: return {}
	return {
		"id": p.id, "name": p.person_name, "role": p.role,
		"team_id": p.team_id, "age": p.age,
		"loyalty": p.loyalty, "stress": p.stress, "fear": p.fear,
		"values": p.values, "attributes": p.attributes, "skills": p.skills,
		"equipment": p.equipment
	}

func move_to(state: WorldState, target_pos: Vector2i) -> Dictionary:
	var pt: TeamData = get_player_team(state)
	if pt == null:
		return { "ok": false, "msg": "玩家 team 不存在" }
	var key: int = target_pos.x * 1000 + target_pos.y
	if not state.world.tiles.has(key):
		return { "ok": false, "msg": "目標格不在地圖內" }
	if pt.tile_pos == target_pos:
		return { "ok": true, "msg": "已在目標格" }
	pt.move_target = target_pos
	return { "ok": true, "msg": "設定目標 (%d,%d)" % [target_pos.x, target_pos.y] }

func cancel_move(state: WorldState) -> Dictionary:
	var pt: TeamData = get_player_team(state)
	if pt == null:
		return { "ok": false, "msg": "玩家 team 不存在" }
	pt.move_target = Vector2i(-1, -1)
	return { "ok": true, "msg": "取消移動" }

func _action_order_faction_member(state: WorldState, _target_id: int, pt: TeamData, pt_id: int) -> Dictionary:
	var member_team_id: int = int(state.player_state.get("order_member_id", -1))
	var m_task: String    = str(state.player_state.get("member_task", ""))
	var member_team: TeamData = state.teams.get(member_team_id)
	if member_team == null:
		return { "ok": false, "msg": "目標成員不存在" }
	if m_task.is_empty():
		return { "ok": false, "msg": "未指定任務" }
	if pt.population < 2:
		return { "ok": false, "msg": "人數不足以派信使" }
	# 從 named_members 選一非 leader 的成員當信使
	var herald_leader_id: int = -1
	for pid in pt.named_members:
		if pid != pt.leader_id:
			herald_leader_id = pid
			break
	if herald_leader_id == -1:
		return { "ok": false, "msg": "無可用的信使人選（需至少一名非隊長的記名成員）" }
	var herald_id: int = _subteam.dispatch(
		state, pt_id, herald_leader_id, 1, TeamData.TASK_HERALD,
		member_team.tile_pos, member_team_id, m_task)
	if herald_id == -1:
		return { "ok": false, "msg": "派信使失敗" }
	# 寫入 player_pending_orders 供 UI 顯示「傳達中」狀態
	state.player_pending_orders[str(member_team_id)] = {"task": m_task, "herald_id": herald_id}
	print("[PlayerCmd] order_faction_member Team%d → herald Team%d 傳達任務: %s" % [member_team_id, herald_id, m_task])
	return { "ok": true, "msg": "信使 Team%d 已出發至 Team%d" % [herald_id, member_team_id] }
