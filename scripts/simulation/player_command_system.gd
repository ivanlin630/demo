# scripts/simulation/player_command_system.gd
class_name PlayerCommandSystem

var _interaction: InteractionSystem = InteractionSystem.new()
var _diplomatic:  DiplomaticAiSystem = DiplomaticAiSystem.new()

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
	return result

# ── 清除 pending ─────────────────────────────────────────────

# 玩家 team 格子改變時呼叫（SimRunner 負責呼叫）
# player_forced_event 不清除（NPC 外交/勒索不因移動取消）
func clear_pending_targets(state: WorldState) -> void:
	state.player_pending_targets.clear()

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
	# STUB — 接受 NPC 外交提案，具體邏輯留後續實裝
	# 完整實裝應依 proposal 類型呼叫 DiplomaticAiSystem 對應方法
	var pt: TeamData  = _get_player_team(state)
	var npc: TeamData = state.teams.get(from_id)
	if pt == null or npc == null:
		return { "ok": false, "msg": "隊伍不存在" }
	print("[PlayerCmd] 玩家接受 Team%d 的 %s 提案（STUB）" % [from_id, proposal])
	return { "ok": true, "msg": "接受：%s" % proposal }

func _pay_extortion(state: WorldState, from_id: int) -> Dictionary:
	# 轉移資源給 from_id（金額由 _resolve_extortion 計算）
	var pt_id: int = _get_player_team_id(state)
	if pt_id == -1:
		return { "ok": false, "msg": "找不到玩家 team" }
	_interaction.resolve_extortion_direct(state, from_id, pt_id)
	return { "ok": true, "msg": "支付勒索" }
