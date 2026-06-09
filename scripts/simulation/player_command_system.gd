# scripts/simulation/player_command_system.gd
class_name PlayerCommandSystem

const RECRUIT_COST_ANON:  float = 50.0   # TEST VALUE
const RECRUIT_COST_NAMED: float = 150.0  # TEST VALUE

var _interaction: InteractionSystem = InteractionSystem.new()
var _diplomatic:  DiplomaticAiSystem = DiplomaticAiSystem.new()
var _encounter:   EncounterSystem    = EncounterSystem.new()
var _subteam:     SubteamSystem      = SubteamSystem.new()
var _action_registry: Dictionary = {}

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
	var coin: float = float(pt.resources.get("coin", 0))
	if coin >= RECRUIT_COST_ANON:
		actions.append("recruit")
	actions.append("gather_intel")
	return actions

# ── Registry 初始化 ───────────────────────────────────────────

func _setup_registry() -> void:
	_action_registry = {
		"trade":                  _action_trade,
		"propose_alliance":       _action_propose_alliance,
		"demand_tribute":         _action_demand_tribute,
		"attack":                 _action_attack,
		"extort":                 _action_extort,
		"recruit":                _action_recruit,
		"recruit_anon":           _action_recruit_anon,
		"take_loot":              _action_take_loot,
		"leave_loot":             _action_leave_loot,
		"establish_faction":      _action_establish_faction_cmd,
		"refresh_targets":        _action_refresh_targets,
		"confirm_trade":          _action_confirm_trade,
		"submit_trade_offer":     _action_submit_trade_offer,
		"cancel_trade":           _action_cancel_trade,
		"set_tribute_rate":       _action_set_tribute_rate,
		"build_outpost":          _action_build_outpost,
		"upgrade_outpost":        _action_upgrade_outpost,
		"upgrade_farming":        _action_upgrade_farming,
		"upgrade_manufacturing":  _action_upgrade_manufacturing,
		"build_facility":         _action_build_facility,
		"demolish_outpost":       _action_demolish_outpost,
		"abandon_outpost":        _action_abandon_outpost,
		"dispatch_subteam":       _action_dispatch_subteam,
		"order_subteam":          _action_order_subteam,
		"recall_subteam":         _action_recall_subteam,
		"subjugate_enemy":        _action_subjugate_enemy,
		"leave_faction":          _action_leave_faction,
		"betray_faction":         _action_betray_faction,
		"disband_faction":        _action_disband_faction,
		"offer_surrender":        _action_offer_surrender,
		"surrender_in_encounter": _action_surrender_in_encounter,
		"accept_encounter":        _action_accept_encounter,
		"surrender_pre_encounter": _action_surrender_pre_encounter,
		"set_faction_goal":       _action_set_faction_goal,
		"order_faction_member":   _action_order_faction_member,
		"clear_member_order":     _action_clear_member_order,
		"gather_intel":           _action_gather_intel,
		"confirm_gather_intel":   _action_confirm_gather_intel,
		"respond_aid_request":    _action_respond_aid_request,
		"invite_settle":          _action_invite_settle,
		"choose_heir":            _action_choose_heir,
		"extract_treasury":       _action_extract_treasury,
		"withdraw_from_storage":  _action_withdraw_from_storage,
		"deposit_to_storage":     _action_deposit_to_storage,
	}

# 執行玩家主動行動
# 返回 { "ok": bool, "msg": String }
func execute_action(state: WorldState, target_id: int, action: String) -> Dictionary:
	var pt: TeamData = _get_player_team(state)
	var pt_id: int   = _get_player_team_id(state)
	# H: choose_heir 在玩家 person 已死時觸發，pt 必為 null，需在 null 守衛前處理
	if action == "choose_heir":
		if _action_registry.is_empty():
			_setup_registry()
		return _action_registry["choose_heir"].call(state, target_id, pt, pt_id)
	if pt == null:
		return { "ok": false, "msg": "找不到玩家 team" }
	if action == "ignore":
		state.player_pending_targets.erase(target_id)
		return { "ok": true, "msg": "忽略" }
	if _action_registry.is_empty():
		_setup_registry()
	if not _action_registry.has(action):
		return { "ok": false, "msg": "未知行動: %s" % action }
	return _action_registry[action].call(state, target_id, pt, pt_id)

# ── Action Handlers ───────────────────────────────────────────

func _action_extract_treasury(state: WorldState, _target: int, pt: TeamData, _pt_id: int) -> Dictionary:
	var ratio: float = float(state.player_state.get("extract_ratio", 0.0))
	if ratio <= 0.0 or ratio > 1.0:
		return { "ok": false, "msg": "extract_ratio 必須 (0, 1]" }
	FactionAISystem.new()._extract_treasury(state, pt, ratio, "玩家主動")
	return { "ok": true, "msg": "徵用 %.0f%%" % (ratio * 100) }

func _action_withdraw_from_storage(state: WorldState, _target: int, pt: TeamData, pt_id: int) -> Dictionary:
	var res: String = state.player_state.get("storage_res", "")
	var amount: float = float(state.player_state.get("storage_amount", 0.0))
	if res == "" or amount <= 0: return { "ok": false, "msg": "未指定 res/amount" }
	var tile: HexTileData = state.world.tiles.get(pt.tile_pos.x * 1000 + pt.tile_pos.y)
	if tile == null or tile.outpost_owner != pt_id: return { "ok": false, "msg": "非自家 outpost" }
	var stored: float = float(tile.public_storage.get(res, 0))
	if stored < amount: return { "ok": false, "msg": "公庫不足" }
	tile.public_storage[res] = stored - amount
	pt.resources[res] = float(pt.resources.get(res, 0)) + amount
	return { "ok": true, "msg": "取 %s × %.0f" % [res, amount] }

func _action_deposit_to_storage(state: WorldState, _target: int, pt: TeamData, pt_id: int) -> Dictionary:
	var res: String = state.player_state.get("storage_res", "")
	var amount: float = float(state.player_state.get("storage_amount", 0.0))
	if res == "" or amount <= 0: return { "ok": false, "msg": "未指定 res/amount" }
	var tile: HexTileData = state.world.tiles.get(pt.tile_pos.x * 1000 + pt.tile_pos.y)
	if tile == null or tile.outpost_owner != pt_id: return { "ok": false, "msg": "非自家 outpost" }
	var have: float = float(pt.resources.get(res, 0))
	if have < amount: return { "ok": false, "msg": "team 資源不足" }
	var cap: float = OutpostSystem.new()._get_storage_cap(tile, res)
	var stored: float = float(tile.public_storage.get(res, 0))
	if stored + amount > cap: return { "ok": false, "msg": "公庫已滿" }
	tile.public_storage[res] = stored + amount
	pt.resources[res] = have - amount
	return { "ok": true, "msg": "存 %s × %.0f" % [res, amount] }

func _action_trade(state: WorldState, target_id: int, _pt: TeamData, _pt_id: int) -> Dictionary:
	var tgt: TeamData = state.teams.get(target_id)
	if tgt == null:
		state.player_pending_targets.erase(target_id)
		return { "ok": false, "msg": "目標不存在" }
	state.player_state["pending_trade_target"] = target_id
	return { "ok": true, "msg": "等待確認",
			 "requires_preview": true, "preview_target_id": target_id }

func _action_propose_alliance(state: WorldState, target_id: int, pt: TeamData, pt_id: int) -> Dictionary:
	var tgt: TeamData = state.teams.get(target_id)
	if tgt == null:
		return { "ok": false, "msg": "目標不存在" }
	var resp: String = _diplomatic.handle_diplomacy_message(state, tgt, pt, "propose_alliance")
	if resp == "accept":
		if pt.faction_id == -1 and tgt.faction_id == -1:
			state.create_faction(pt_id)
		_diplomatic._form_alliance(state, pt, tgt)
		print("[PlayerCmd] 同盟成立，勢力%d" % pt.faction_id)
	state.player_pending_targets.erase(target_id)
	return { "ok": resp == "accept", "msg": "外交結果: %s" % resp }

func _action_demand_tribute(state: WorldState, target_id: int, pt: TeamData, _pt_id: int) -> Dictionary:
	var tgt: TeamData = state.teams.get(target_id)
	if tgt == null:
		return { "ok": false, "msg": "目標不存在" }
	var resp: String = _diplomatic.handle_diplomacy_message(state, tgt, pt, "demand_tribute")
	state.player_pending_targets.erase(target_id)
	if resp == "accept":
		var amount: float = float(tgt.resources.get("coin", 0)) * 0.1  # TEST VALUE
		tgt.resources["coin"] = float(tgt.resources.get("coin", 0)) - amount
		pt.resources["coin"]  = float(pt.resources.get("coin", 0)) + amount
		print("[PlayerCmd] 索貢成功 Team%d→玩家 %.0f coin" % [target_id, amount])
		return { "ok": true, "msg": "索貢成功（獲得%.0f coin）" % amount }
	else:
		tgt.unrest_turns += 2
		var leader_p: PersonData = state.persons.get(tgt.leader_id)
		if leader_p:
			leader_p.memory.append({
				"event_id": state.world.current_tick,
				"intensity": "significant",
				"reaction": "tribute_refused"
			})
		print("[PlayerCmd] 索貢遭拒 Team%d unrest+2" % target_id)
		return { "ok": false, "msg": "索貢遭拒，關係惡化" }

func _action_attack(state: WorldState, target_id: int, _pt: TeamData, pt_id: int) -> Dictionary:
	var tgt: TeamData = state.teams.get(target_id)
	if tgt == null:
		return { "ok": false, "msg": "目標不存在" }
	_encounter.init_encounter(state, pt_id, target_id, "normal")
	if not state.player_hostile_teams.has(target_id):
		state.player_hostile_teams.append(target_id)
	state.player_pending_targets.erase(target_id)
	print("[PlayerCmd] 玩家發起攻擊 Team%d → Team%d" % [pt_id, target_id])
	return { "ok": true, "msg": "發起攻擊" }

func _action_extort(state: WorldState, target_id: int, _pt: TeamData, pt_id: int) -> Dictionary:
	var extort_result := _interaction.resolve_extortion_direct(state, pt_id, target_id)
	state.player_pending_targets.erase(target_id)
	if not extort_result.get("accepted", true):
		var tgt2: TeamData = state.teams.get(target_id)
		if tgt2:
			tgt2.unrest_turns += 1
		print("[PlayerCmd] 勒索遭拒 Team%d unrest+1" % target_id)
	return { "ok": extort_result.get("ok", false), "msg": extort_result.get("msg", "") }

func _action_recruit(state: WorldState, target_id: int, pt: TeamData, _pt_id: int) -> Dictionary:
	# Always return a menu — never auto-execute. Player must call recruit_anon or recruit_named.
	var tgt: TeamData = state.teams.get(target_id)
	if tgt == null:
		state.player_pending_targets.erase(target_id)
		return { "ok": false, "msg": "目標不存在" }
	var willing: Array = []
	for pid in tgt.named_members:
		if pid == tgt.leader_id: continue
		var person: PersonData = state.persons.get(pid)
		if person and person.loyalty < 0.4:
			willing.append(pid)
	var coin: float      = float(pt.resources.get("coin", 0))
	var anon_ok: bool    = coin >= RECRUIT_COST_ANON and tgt.population > 1
	var willing_dto: Array = []
	if not willing.is_empty():
		willing_dto = PlayerApiMapper.map_willing_members(state, willing)
	return { "ok": true, "msg": "選擇招募方式",
			 "payload": {
				 "has_willing_named":   not willing.is_empty(),
				 "willing_members":     willing_dto,
				 "anon_available":      anon_ok,
				 "anon_cost":           int(RECRUIT_COST_ANON),
				 "named_cost":          int(RECRUIT_COST_NAMED),
				 "target_team_id":      target_id
			 }}


func _action_recruit_anon(state: WorldState, target_id: int, pt: TeamData, _pt_id: int) -> Dictionary:
	var tgt3: TeamData = state.teams.get(target_id)
	if tgt3 == null:
		return { "ok": false, "msg": "目標不存在" }
	return _recruit_anon_internal(state, pt, tgt3, target_id)

func _action_take_loot(state: WorldState, _target_id: int, pt: TeamData, pt_id: int) -> Dictionary:
	var res: Dictionary = state.last_encounter_result
	if res.is_empty() or res.get("winner_id", -1) != pt_id:
		return { "ok": false, "msg": "無可收取戰利品" }
	var loot: Dictionary = res.get("loot_pool", {})
	var loser_team: TeamData = state.teams.get(res.get("loser_id", -1))
	for rk in loot:
		var amount: float = float(loot[rk])
		if loser_team != null:
			loser_team.resources[rk] = maxf(float(loser_team.resources.get(rk, 0)) - amount, 0)
		pt.resources[rk] = float(pt.resources.get(rk, 0)) + amount
	state.last_encounter_result = {}
	print("[PlayerCmd] 收取戰利品: %s" % str(loot))
	return { "ok": true, "msg": "收取戰利品成功",
			 "payload": {"refresh_required": true} }

func _action_leave_loot(state: WorldState, _target_id: int, _pt: TeamData, _pt_id: int) -> Dictionary:
	state.last_encounter_result = {}
	return { "ok": true, "msg": "放棄戰利品" }

func _action_establish_faction_cmd(state: WorldState, _target_id: int, _pt: TeamData, _pt_id: int) -> Dictionary:
	return establish_faction(state)

func _action_refresh_targets(state: WorldState, _target_id: int, _pt: TeamData, _pt_id: int) -> Dictionary:
	refresh_colocation_targets(state)
	return { "ok": true, "msg": "互動目標已更新" }

func _action_confirm_trade(state: WorldState, target_id: int, pt: TeamData, pt_id: int) -> Dictionary:
	# If a structured trade_offer is present, delegate to the new offer system
	if state.player_state.has("trade_offer"):
		return _action_submit_trade_offer(state, target_id, pt, pt_id)
	# Legacy fallback: NPC-initiated trade confirmation
	var tid2: int = int(state.player_state.get("pending_trade_target", -1))
	if tid2 < 0 or not state.teams.has(tid2):
		return { "ok": false, "msg": "無待確認貿易" }
	var result2 := _interaction.resolve_trade_direct(state, pt_id, tid2)
	state.player_pending_targets.erase(tid2)
	state.player_state.erase("pending_trade_target")
	return result2

func _action_submit_trade_offer(state: WorldState, _target_id: int, _pt: TeamData, pt_id: int) -> Dictionary:
	var tid: int          = int(state.player_state.get("pending_trade_target", -1))
	var offer: Dictionary = state.player_state.get("trade_offer", {})
	if tid < 0 or offer.is_empty():
		return { "ok": false, "msg": "無待送出的出價" }
	if not state.teams.has(tid):
		return { "ok": false, "msg": "目標隊伍不存在" }
	var result := PlayerTradeSystem.new().execute_offer(state, pt_id, tid, offer)
	if result.get("ok", false):
		state.player_pending_targets.erase(tid)
		state.player_state.erase("pending_trade_target")
		state.player_state.erase("trade_offer")
	return result

func _action_cancel_trade(state: WorldState, _target_id: int, _pt: TeamData, _pt_id: int) -> Dictionary:
	var tid3: int = int(state.player_state.get("pending_trade_target", -1))
	if tid3 >= 0:
		state.player_pending_targets.erase(tid3)
	state.player_state.erase("pending_trade_target")
	return { "ok": true, "msg": "取消貿易" }

func _action_set_tribute_rate(state: WorldState, _target_id: int, pt: TeamData, pt_id: int) -> Dictionary:
	var rate: float = float(state.player_state.get("tribute_rate_input", 0.1))
	rate = clampf(rate, 0.0, 1.0)
	if pt.faction_id == -1:
		return { "ok": false, "msg": "玩家不在勢力中" }
	var f_tr: FactionData = state.factions.get(pt.faction_id)
	if f_tr == null:
		return { "ok": false, "msg": "勢力不存在" }
	if f_tr.leader_team_id != pt_id:
		return { "ok": false, "msg": "只有 leader 可設定徵收率" }
	f_tr.tribute_rate = rate
	print("[PlayerCmd] set_tribute_rate → %.2f" % rate)
	return { "ok": true, "msg": "徵收率設為 %.0f%%" % (rate * 100) }

func _action_build_outpost(state: WorldState, _target_id: int, pt: TeamData, _pt_id: int) -> Dictionary:
	var outpost_type: String = str(state.player_state.get("build_type", "civilian"))
	if outpost_type not in ["civilian", "military"]:
		return { "ok": false, "msg": "無效據點類型" }
	var _os := OutpostSystem.new()
	var ok: bool = _os.start_build(state, pt, outpost_type, 1)
	if not ok:
		return { "ok": false, "msg": "無法建造（資源不足或距離限制）" }
	print("[PlayerCmd] build_outpost type=%s" % outpost_type)
	return { "ok": true, "msg": "開始建造 %s" % outpost_type }

func _action_upgrade_outpost(state: WorldState, _target_id: int, pt: TeamData, _pt_id: int) -> Dictionary:
	var _os2 := OutpostSystem.new()
	var ok2: bool = _os2.start_upgrade_level(state, pt)
	if not ok2:
		return { "ok": false, "msg": "無法升級（非 owner 或已滿級）" }
	return { "ok": true, "msg": "開始升級據點" }

func _action_upgrade_farming(state: WorldState, _target_id: int, pt: TeamData, _pt_id: int) -> Dictionary:
	var _os3 := OutpostSystem.new()
	var ok3: bool = _os3.start_upgrade_farming(state, pt)
	if not ok3:
		return { "ok": false, "msg": "無法升級農業（非 civilian 或已滿）" }
	return { "ok": true, "msg": "開始升級農業" }

func _action_upgrade_manufacturing(state: WorldState, _target_id: int, pt: TeamData, _pt_id: int) -> Dictionary:
	var _os4 := OutpostSystem.new()
	var ok4: bool = _os4.start_upgrade_manufacturing(state, pt)
	if not ok4:
		return { "ok": false, "msg": "無法升級製造（條件不符）" }
	return { "ok": true, "msg": "開始升級製造" }

# 統一設施擴建入口：依 player_state["facility_type"] 分派至對應 start_upgrade_*
func _action_build_facility(state: WorldState, _target_id: int, pt: TeamData, _pt_id: int) -> Dictionary:
	var facility: String = str(state.player_state.get("facility_type", "farming"))
	if not OutpostSystem.FACILITY_DEF.has(facility):
		return { "ok": false, "msg": "未知 facility: %s" % facility }
	var _os := OutpostSystem.new()
	var ok: bool = false
	match facility:
		"farming":       ok = _os.start_upgrade_farming(state, pt)
		"manufacturing": ok = _os.start_upgrade_manufacturing(state, pt)
	if not ok:
		return { "ok": false, "msg": "無法擴建 %s（條件不符）" % facility }
	return { "ok": true, "msg": "開始擴建 %s" % facility }

func _action_demolish_outpost(state: WorldState, _target_id: int, pt: TeamData, pt_id: int) -> Dictionary:
	var _os5 := OutpostSystem.new()
	var tile_id5: int = pt.tile_pos.x * 1000 + pt.tile_pos.y
	var tile5: HexTileData = state.world.tiles.get(tile_id5)
	if tile5 == null:
		return { "ok": false, "msg": "格子不存在" }
	if tile5.construction_ticks_left > 0 and tile5.outpost_level == 0:
		tile5.construction_team_id   = -1
		tile5.construction_ticks_left = 0
		tile5.construction_target     = {}
		pt.current_task = TeamData.TASK_IDLE
		return { "ok": true, "msg": "取消施工" }
	if not _os5._has_control(state, pt_id, tile5):
		return { "ok": false, "msg": "無支配權，無法拆除" }
	var ok5: bool = _os5.demolish_with_control(state, pt)
	if not ok5:
		return { "ok": false, "msg": "無法拆除" }
	return { "ok": true, "msg": "開始拆除據點" }

func _action_abandon_outpost(state: WorldState, _target_id: int, _pt: TeamData, pt_id: int) -> Dictionary:
	var pos_arr: Array = state.player_state.get("abandon_pos", [-1, -1])
	var pos := Vector2i(int(pos_arr[0]), int(pos_arr[1]))
	if pos.x < 0:
		return { "ok": false, "msg": "未指定 outpost 位置" }
	var tile: HexTileData = state.world.tiles.get(pos.x * 1000 + pos.y)
	if tile == null or tile.outpost_level == 0:
		return { "ok": false, "msg": "目標無 outpost" }
	if tile.outpost_owner != pt_id:
		return { "ok": false, "msg": "非自家 outpost" }
	tile.outpost_owner = -1
	return { "ok": true, "msg": "已棄置 outpost (%d,%d)" % [pos.x, pos.y] }

func _action_dispatch_subteam(state: WorldState, _target_id: int, pt: TeamData, pt_id: int) -> Dictionary:
	var sub_leader_id: int = int(state.player_state.get("sub_leader_id", -1))
	var pop_count: int     = int(state.player_state.get("sub_pop_count", 1))
	var task: String       = str(state.player_state.get("sub_task", TeamData.TASK_IDLE))
	var tq: int = int(state.player_state.get("sub_move_q", -1))
	var tr: int = int(state.player_state.get("sub_move_r", -1))
	var move_tgt: Vector2i = Vector2i(tq, tr)
	if sub_leader_id == -1 or not state.persons.has(sub_leader_id):
		return { "ok": false, "msg": "未指定子隊 leader" }
	if pop_count < 1 or pop_count >= pt.population:
		return { "ok": false, "msg": "人數不合法（1 ~ population-1）" }
	var sub_id: int = SubteamSystem.new().dispatch(state, pt_id, sub_leader_id, pop_count, task, move_tgt)
	if sub_id == -1:
		return { "ok": false, "msg": "派遣失敗" }
	return { "ok": true, "msg": "派出子隊 Team%d" % sub_id, "sub_id": sub_id }

func _action_order_subteam(state: WorldState, _target_id: int, _pt: TeamData, pt_id: int) -> Dictionary:
	var sub_id2: int   = int(state.player_state.get("order_sub_id", -1))
	var new_task: String = str(state.player_state.get("sub_new_task", TeamData.TASK_IDLE))
	var nq: int = int(state.player_state.get("sub_new_move_q", -1))
	var nr: int = int(state.player_state.get("sub_new_move_r", -1))
	var sub2: TeamData = state.teams.get(sub_id2)
	if sub2 == null or sub2.parent_team_id != pt_id:
		return { "ok": false, "msg": "目標不是玩家子隊" }
	sub2.current_task = new_task
	sub2.move_target  = Vector2i(nq, nr)
	print("[PlayerCmd] order_subteam Team%d → task=%s move=(%d,%d)" % [sub_id2, new_task, nq, nr])
	return { "ok": true, "msg": "已下令 Team%d" % sub_id2 }

func _action_recall_subteam(state: WorldState, _target_id: int, pt: TeamData, pt_id: int) -> Dictionary:
	var recall_sub_id: int = int(state.player_state.get("recall_sub_id", -1))
	var recall_sub: TeamData = state.teams.get(recall_sub_id)
	if recall_sub == null or recall_sub.parent_team_id != pt_id:
		return { "ok": false, "msg": "目標不是玩家子隊" }
	if pt.population < 2:
		return { "ok": false, "msg": "人數不足以派信使" }
	var herald_leader_id: int = -1
	for pid in pt.named_members:
		if pid != pt.leader_id:
			herald_leader_id = pid
			break
	if herald_leader_id == -1:
		return { "ok": false, "msg": "無可用的信使人選" }
	var herald_id: int = SubteamSystem.new().dispatch(
		state, pt_id, herald_leader_id, 1, TeamData.TASK_HERALD,
		recall_sub.tile_pos, recall_sub_id, TeamData.TASK_MERGE)
	if herald_id == -1:
		return { "ok": false, "msg": "派信使失敗" }
	return { "ok": true, "msg": "信使已出發至 Team%d" % recall_sub_id }

func _action_subjugate_enemy(state: WorldState, _target_id: int, _pt: TeamData, pt_id: int) -> Dictionary:
	var result: Dictionary = state.last_encounter_result
	if result.is_empty() or not result.get("can_subjugate", false):
		return { "ok": false, "msg": "無可收編的敗者" }
	var loser_id: int = int(result.get("loser_id", -1))
	var loser: TeamData = state.teams.get(loser_id)
	if loser == null:
		return { "ok": false, "msg": "敗者已消滅" }
	_interaction.subjugate_team(state, pt_id, loser_id)
	state.last_encounter_result["can_subjugate"] = false
	return { "ok": true, "msg": "收編 Team%d" % loser_id }

func _action_leave_faction(state: WorldState, _target_id: int, pt: TeamData, pt_id: int) -> Dictionary:
	if pt.faction_id == -1:
		return { "ok": false, "msg": "玩家不在勢力中" }
	var fid3: int = pt.faction_id
	var f3: FactionData = state.factions.get(fid3)
	if f3 == null:
		return { "ok": false, "msg": "勢力不存在" }
	if f3.leader_team_id == pt_id:
		return { "ok": false, "msg": "請使用 disband_faction（leader 不能普通離開）" }
	pt.faction_id = -1
	f3.member_team_ids.erase(pt_id)
	var leader_team3: TeamData = state.teams.get(f3.leader_team_id)
	if leader_team3 != null:
		var leader_p3: PersonData = state.persons.get(leader_team3.leader_id)
		if leader_p3:
			leader_p3.loyalty = maxf(leader_p3.loyalty - 0.15, 0.0)
	print("[PlayerCmd] 玩家離開勢力%d" % fid3)
	return { "ok": true, "msg": "已離開勢力" }

func _action_betray_faction(state: WorldState, _target_id: int, pt: TeamData, pt_id: int) -> Dictionary:
	if pt.faction_id == -1:
		return { "ok": false, "msg": "玩家不在勢力中" }
	var fid4: int = pt.faction_id
	var f4: FactionData = state.factions.get(fid4)
	if f4 == null:
		return { "ok": false, "msg": "勢力不存在" }
	for tid4 in f4.member_team_ids:
		if tid4 == pt_id: continue
		if not state.player_hostile_teams.has(tid4):
			state.player_hostile_teams.append(tid4)
	pt.faction_id = -1
	f4.member_team_ids.erase(pt_id)
	state.player_state["betrayal_count"] = int(state.player_state.get("betrayal_count", 0)) + 1
	var leader_team4: TeamData = state.teams.get(f4.leader_team_id)
	if leader_team4 != null:
		var leader_p4: PersonData = state.persons.get(leader_team4.leader_id)
		if leader_p4:
			leader_p4.memory.append({
				"type": "betrayal", "subject_id": pt.leader_id,
				"tick": state.world.current_tick, "intensity": 0.9
			})
	print("[PlayerCmd] 玩家背叛勢力%d（betrayal_count=%d）" % [
		fid4, state.player_state["betrayal_count"]])
	return { "ok": true, "msg": "背叛勢力，原成員已敵對" }

func _action_disband_faction(state: WorldState, _target_id: int, pt: TeamData, pt_id: int) -> Dictionary:
	if pt.faction_id == -1:
		return { "ok": false, "msg": "玩家不在勢力中" }
	var fid5: int = pt.faction_id
	var f5: FactionData = state.factions.get(fid5)
	if f5 == null:
		return { "ok": false, "msg": "勢力不存在" }
	if f5.leader_team_id != pt_id:
		return { "ok": false, "msg": "只有 leader 可解散勢力" }
	for tid5 in f5.member_team_ids:
		if tid5 == pt_id: continue
		var mt5: TeamData = state.teams.get(tid5)
		if mt5 == null: continue
		var lp5: PersonData = state.persons.get(mt5.leader_id)
		if lp5:
			lp5.loyalty = maxf(lp5.loyalty - 0.3, 0.0)
	state.disband_faction(fid5)
	return { "ok": true, "msg": "勢力已解散" }

func _action_offer_surrender(state: WorldState, target_id: int, pt: TeamData, pt_id: int) -> Dictionary:
	var tgt6: TeamData = state.teams.get(target_id)
	if tgt6 == null:
		return { "ok": false, "msg": "目標不存在" }
	var resp6: String = _diplomatic.handle_diplomacy_message(state, tgt6, pt, "offer_surrender")
	state.player_pending_targets.erase(target_id)
	if resp6 == "accept":
		for res6 in ["food", "coin", "goods"]:
			var amount6: float = float(pt.resources.get(res6, 0)) * 0.3
			pt.resources[res6]   = float(pt.resources.get(res6, 0)) - amount6
			tgt6.resources[res6] = float(tgt6.resources.get(res6, 0)) + amount6
		_interaction.subjugate_team(state, target_id, pt_id)
		print("[PlayerCmd] 玩家投降 Team%d 接受" % target_id)
		return { "ok": true, "msg": "投降被接受，已被收編" }
	else:
		return { "ok": false, "msg": "對方拒絕接受投降" }

func _action_surrender_in_encounter(state: WorldState, _target_id: int, pt: TeamData, pt_id: int) -> Dictionary:
	if not state.encounter_active:
		return { "ok": false, "msg": "非戰鬥中" }
	var enemy_id6: int = state.encounter_defender_id if state.encounter_attacker_id == pt_id \
		else state.encounter_attacker_id
	var enemy6: TeamData = state.teams.get(enemy_id6)
	if enemy6 == null:
		return { "ok": false, "msg": "找不到對手" }
	var resp6b: String = _diplomatic.handle_diplomacy_message(state, enemy6, pt, "offer_surrender")
	if resp6b == "accept":
		for res6b in ["food", "coin", "goods"]:
			var amt6b: float = float(pt.resources.get(res6b, 0)) * 0.3
			pt.resources[res6b]    = float(pt.resources.get(res6b, 0)) - amt6b
			enemy6.resources[res6b] = float(enemy6.resources.get(res6b, 0)) + amt6b
		_interaction.subjugate_team(state, enemy_id6, pt_id)
		_encounter.cleanup_encounter(state)
		print("[PlayerCmd] 玩家戰中投降，Team%d 接受" % enemy_id6)
		return { "ok": true, "msg": "投降被接受" }
	else:
		return { "ok": false, "msg": "對方拒絕" }

func _action_accept_encounter(state: WorldState, _target_id: int, _pt: TeamData, _pt_id: int) -> Dictionary:
	var pre: Dictionary = state.player_pre_encounter
	if pre.is_empty():
		return { "ok": false, "msg": "無待處理預備遭遇戰" }
	var atk_id: int = int(pre.get("attacker_id", -1))
	var def_id: int = int(pre.get("defender_id", -1))
	state.player_pre_encounter = {}
	_encounter.init_encounter(state, atk_id, def_id, "normal")
	print("[PlayerCmd] 玩家選擇迎擊，遭遇戰開始 Team%d vs Team%d" % [atk_id, def_id])
	return { "ok": true, "msg": "迎擊！遭遇戰開始" }

func _action_surrender_pre_encounter(state: WorldState, _target_id: int, pt: TeamData, pt_id: int) -> Dictionary:
	var pre: Dictionary = state.player_pre_encounter
	if pre.is_empty():
		return { "ok": false, "msg": "無待處理預備遭遇戰" }
	var atk_id: int = int(pre.get("attacker_id", -1))
	var attacker: TeamData = state.teams.get(atk_id)
	if attacker == null:
		state.player_pre_encounter = {}
		return { "ok": false, "msg": "攻擊者不存在" }
	var resp: String = _diplomatic.handle_diplomacy_message(state, attacker, pt, "offer_surrender")
	state.player_pre_encounter = {}
	if resp == "accept":
		for res_sp in ["food", "coin", "goods"]:
			var amt_sp: float = float(pt.resources.get(res_sp, 0)) * 0.3
			pt.resources[res_sp]       = float(pt.resources.get(res_sp, 0)) - amt_sp
			attacker.resources[res_sp] = float(attacker.resources.get(res_sp, 0)) + amt_sp
		_interaction.subjugate_team(state, atk_id, pt_id)
		print("[PlayerCmd] 玩家預備投降，Team%d 接受" % atk_id)
		return { "ok": true, "msg": "投降被接受，已被收編" }
	else:
		# 對方拒絕投降 → 強迫開戰
		_encounter.init_encounter(state, atk_id, pt_id, "normal")
		print("[PlayerCmd] 玩家預備投降遭拒，強制遭遇戰 Team%d vs Team%d" % [atk_id, pt_id])
		return { "ok": false, "msg": "對方拒絕投降，遭遇戰強制開始" }

func _action_set_faction_goal(state: WorldState, _target_id: int, pt: TeamData, pt_id: int) -> Dictionary:
	if pt.faction_id == -1:
		return { "ok": false, "msg": "玩家不在勢力中" }
	var goal9: String = str(state.player_state.get("faction_goal_input", ""))
	if goal9 not in ["expand", "defend", "trade_net", ""]:
		return { "ok": false, "msg": "無效目標（expand/defend/trade_net/空字串清除）" }
	var f9: FactionData = state.factions.get(pt.faction_id)
	if f9 == null:
		return { "ok": false, "msg": "勢力不存在" }
	if f9.leader_team_id != pt_id:
		return { "ok": false, "msg": "只有 leader 可設定勢力目標" }
	f9.player_goal_override = goal9
	var msg9: String = "清除 override" if goal9.is_empty() else "勢力目標設為 %s" % goal9
	print("[PlayerCmd] set_faction_goal → %s" % goal9)
	return { "ok": true, "msg": msg9 }

func _action_order_faction_member(state: WorldState, _target_id: int, pt: TeamData, pt_id: int) -> Dictionary:
	var member_team_id: int   = int(state.player_state.get("order_member_id", -1))
	var m_task: String        = str(state.player_state.get("member_task", ""))
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
	state.player_pending_orders[str(member_team_id)] = {"task": m_task, "herald_id": herald_id}
	print("[PlayerCmd] order_faction_member Team%d → herald Team%d 傳達任務: %s" % [member_team_id, herald_id, m_task])
	return { "ok": true, "msg": "信使 Team%d 已出發至 Team%d" % [herald_id, member_team_id] }

func _action_gather_intel(state: WorldState, target_id: int, pt: TeamData, _pt_id: int) -> Dictionary:
	var tgt_gi: TeamData = state.teams.get(target_id)
	if tgt_gi == null:
		return { "ok": false, "msg": "目標不存在" }
	var options: Array = InquirySystem.new().get_options(state, pt, tgt_gi)
	if options.is_empty():
		return { "ok": false, "msg": "無可打聽的情報" }
	return {
		"ok": true,
		"msg": "選擇要打聽的情報",
		"payload": { "inquiry_options": options, "npc_id": target_id }
	}

func _action_confirm_gather_intel(state: WorldState, _target_id: int, pt: TeamData, _pt_id: int) -> Dictionary:
	var npc_id_gi: int     = int(state.player_state.get("gather_intel_npc_id", -1))
	var choice_gi: String  = str(state.player_state.get("gather_intel_choice", ""))
	var npc_gi: TeamData   = state.teams.get(npc_id_gi)
	if npc_gi == null or choice_gi.is_empty():
		return { "ok": false, "msg": "參數遺漏" }
	var result_gi: Dictionary = InquirySystem.new().resolve_inquiry(state, pt, npc_gi, choice_gi)
	print("[PlayerCmd] gather_intel choice=%s 結果筆數=%d" % [choice_gi, result_gi.size()])
	return { "ok": true, "msg": "情報獲取", "payload": result_gi }

func _action_clear_member_order(state: WorldState, _target_id: int, pt: TeamData, _pt_id: int) -> Dictionary:
	# player_state 需設定：order_member_id（目標 team）
	var member_id: int = int(state.player_state.get("order_member_id", -1))
	var mt: TeamData = state.teams.get(member_id)
	if mt == null or mt.faction_id != pt.faction_id:
		return { "ok": false, "msg": "目標不是同勢力成員" }
	mt.player_commanded_task = ""
	print("[PlayerCmd] clear_member_order Team%d" % member_id)
	return { "ok": true, "msg": "已清除 Team%d 的直接指令" % member_id }

# ── 被動回應（NPC 強制非戰互動）────────────────────────────

# 查詢 forced_event 的回應選項
# "diplomacy" → ["accept", "refuse"]
# "extort"    → ["pay", "refuse"]
func get_forced_response_options(state: WorldState) -> Array[String]:
	match state.player_forced_event.get("action", ""):
		"diplomacy":
			return ["accept", "accept_join", "accept_lead", "refuse"]
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
			match response:
				"accept", "accept_join":
					result = _accept_diplomacy(state,
						fe.get("from_id", -1), fe.get("proposal", "alliance"))
				"accept_lead":
					result = _accept_diplomacy_as_leader(state, fe.get("from_id", -1))
				"refuse":
					result = { "ok": true, "msg": "拒絕外交提案" }
				_:
					result = { "ok": false, "msg": "未知回應: %s" % response }
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
	state.player_state.erase("pending_trade_target")

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
		if other.combat_target != -1:
			continue
		if not state.player_pending_targets.has(other_id):
			state.player_pending_targets.append(other_id)

func _action_respond_aid_request(state: WorldState, _target_id: int, pt: TeamData, pt_id: int) -> Dictionary:
	var fe: Dictionary = state.player_forced_event
	if fe.is_empty() or fe.get("action", "") != "aid_request":
		return { "ok": false, "msg": "無待回應 aid event" }
	var beggar_id: int = int(fe.get("from_id", -1))
	var beggar: TeamData = state.teams.get(beggar_id)
	if beggar == null:
		state.player_forced_event = {}
		state.player_forced_event_id = ""
		return { "ok": false, "msg": "beggar 不存在" }
	var b_leader: PersonData = state.persons.get(beggar.leader_id)
	var response: Dictionary = state.player_state.get("aid_response", {})
	var msg_sys := SimMessageSystem.new()
	var npc_ai  := NpcAiSystem.new()
	if response.get("refuse", false):
		msg_sys.emit_message(state, "aid_refused",
			"玩家拒絕援助 Team%d" % beggar_id, pt,
			{ "origin": str(pt_id), "target": str(beggar_id) })
		_update_rep(beggar, pt_id, -0.1)
		if b_leader: npc_ai.write_memory(b_leader, "rejected_aid", pt_id,
			state.world.current_tick, 0.5)
	else:
		var amt: float = float(response.get("give_amount", 0.0))
		var actual: float = minf(amt, float(pt.resources.get("food", 0)))
		if actual <= 0.0:
			msg_sys.emit_message(state, "aid_refused",
				"玩家無餘糧援助 Team%d" % beggar_id, pt,
				{ "origin": str(pt_id), "target": str(beggar_id) })
		else:
			pt.resources["food"] = float(pt.resources.get("food", 0)) - actual
			beggar.resources["food"] = float(beggar.resources.get("food", 0)) + actual
			msg_sys.emit_message(state, "aid_given",
				"玩家援助 Team%d %.0f 食物" % [beggar_id, actual], pt,
				{ "origin": str(pt_id), "target": str(beggar_id),
				  "amount": "%.0f" % actual })
			_update_rep(beggar, pt_id, 0.15)
			if b_leader: npc_ai.write_memory(b_leader, "benefactor", pt_id,
				state.world.current_tick, clampf(actual / 50.0, 0.1, 1.0))
	beggar.current_task = beggar.previous_task if beggar.previous_task != "" else TeamData.TASK_IDLE
	beggar.previous_task = ""
	beggar.combat_target = -1
	state.player_forced_event = {}
	state.player_forced_event_id = ""
	state.player_state.erase("aid_response")
	return { "ok": true, "msg": "已處理" }

func _action_choose_heir(state: WorldState, _target: int, _pt: TeamData, _pt_id: int) -> Dictionary:
	var fe: Dictionary = state.player_forced_event
	if fe.get("action", "") != "choose_heir":
		return { "ok": false, "msg": "無待選繼承人事件" }
	var heir_id: int = int(state.player_state.get("heir_id", -1))
	if heir_id == -1:
		return { "ok": false, "msg": "未選繼承人" }
	if not fe.get("candidates", []).has(heir_id):
		return { "ok": false, "msg": "非合法候選" }
	var team_id: int = int(fe.get("team_id", -1))
	var team: TeamData = state.teams.get(team_id)
	var heir: PersonData = state.persons.get(heir_id)
	if team == null or heir == null:
		return { "ok": false, "msg": "team/person 失效" }
	team.leader_id = heir_id
	team.named_members.erase(heir_id)
	heir.role = "leader"
	state.player_id = heir_id
	state.player_forced_event = {}
	state.player_forced_event_id = ""
	state.player_state.erase("heir_id")
	print("[Heir] %s 繼任玩家 (Team%d)" % [heir.person_name, team_id])
	return { "ok": true, "msg": "%s 繼任" % heir.person_name }

func _action_invite_settle(state: WorldState, target_id: int, pt: TeamData, pt_id: int) -> Dictionary:
	var tgt: TeamData = state.teams.get(target_id)
	if tgt == null: return { "ok": false, "msg": "目標不存在" }
	var pos_arr: Array = state.player_state.get("settle_pos", [-1, -1])
	var target_pos: Vector2i = Vector2i(int(pos_arr[0]), int(pos_arr[1]))
	if target_pos == Vector2i(-1, -1):
		return { "ok": false, "msg": "未指定 outpost 位置" }
	var tile: HexTileData = state.world.tiles.get(target_pos.x * 1000 + target_pos.y)
	if tile == null or tile.outpost_level == 0 or tile.outpost_owner != pt_id:
		return { "ok": false, "msg": "目標非自家 outpost" }
	# 評估接受
	var resp: String = _diplomatic.handle_diplomacy_message(state, tgt, pt, "invite_settle")
	if resp == "accept":
		_interaction._execute_settlement(state, target_id, target_pos, pt.faction_id)
		return { "ok": true, "msg": "Team%d 接受邀請" % target_id }
	return { "ok": true, "msg": "Team%d 拒絕邀請" % target_id, "accepted": false }

func _update_rep(team: TeamData, other_id: int, delta: float) -> void:
	var cur: float = float(team.known_reputations.get(other_id, 0.5))
	team.known_reputations[other_id] = clampf(cur + delta, 0.0, 1.0)

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

func _accept_diplomacy_as_leader(state: WorldState, from_id: int) -> Dictionary:
	var from_team: TeamData = state.teams.get(from_id)
	var pt: TeamData = _get_player_team(state)
	var pt_id: int   = _get_player_team_id(state)
	if from_team == null or pt == null:
		return { "ok": false, "msg": "隊伍不存在" }
	if pt.faction_id == -1:
		state.create_faction(pt_id)
	_diplomatic._form_alliance(state, pt, from_team)
	return { "ok": true, "msg": "自立後接納 Team%d，勢力%d" % [from_id, pt.faction_id] }

func _pay_extortion(state: WorldState, from_id: int) -> Dictionary:
	# 轉移資源給 from_id（金額由 _resolve_extortion 計算）
	var pt_id: int = _get_player_team_id(state)
	if pt_id == -1:
		return { "ok": false, "msg": "找不到玩家 team" }
	_interaction.resolve_extortion_direct(state, from_id, pt_id)
	return { "ok": true, "msg": "支付勒索" }

func _recruit_anon_internal(state: WorldState, pt: TeamData,
		tgt: TeamData, target_id: int) -> Dictionary:
	var pt_id: int  = _get_player_team_id(state)
	var coin: float = float(pt.resources.get("coin", 0))
	if coin < RECRUIT_COST_ANON:
		state.player_pending_targets.erase(target_id)
		return { "ok": false, "msg": "金幣不足（需%d）" % int(RECRUIT_COST_ANON) }
	if tgt.population <= 1:
		state.player_pending_targets.erase(target_id)
		return { "ok": false, "msg": "目標人口不足" }
	pt.resources["coin"] = coin - RECRUIT_COST_ANON
	# 被招募 anon 帶走在原團的 treasury 份額
	var tgt_named: int = tgt.named_members.size() + (1 if tgt.leader_id != -1 else 0)
	var tgt_anon: int = maxi(tgt.population - tgt_named, 1)
	var share: float = minf(tgt.anon_treasury / float(tgt_anon), tgt.anon_treasury)
	tgt.anon_treasury -= share
	pt.anon_treasury += share
	tgt.population = maxi(tgt.population - 1, 1)
	pt.population += 1
	state.player_pending_targets.erase(target_id)
	print("[Recruit] 匿名 Team%d←%d, 花%.0f coin, 新人口=%d" % [
		pt_id, target_id, RECRUIT_COST_ANON, pt.population])
	return { "ok": true, "msg": "招募成功（花費%d coin，新人口%d）" % [
		int(RECRUIT_COST_ANON), pt.population],
		"payload": {"has_willing_named": false, "refresh_required": true} }

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
	state.player_state.erase("pending_trade_target")
	return { "ok": true, "msg": "取消移動" }

func establish_faction(state: WorldState) -> Dictionary:
	var pt: TeamData = _get_player_team(state)
	var pt_id: int   = _get_player_team_id(state)
	if pt == null:
		return { "ok": false, "code": "no_controlled_team",
				 "message": "找不到玩家隊伍", "payload": {} }
	if pt.faction_id != -1:
		return { "ok": false, "code": "action_unavailable",
				 "message": "已屬勢力%d" % pt.faction_id, "payload": {} }
	state.create_faction(pt_id)
	print("[PlayerCmd] 玩家建立勢力%d" % pt.faction_id)
	return { "ok": true, "code": "ok",
			 "message": "建立勢力%d" % pt.faction_id,
			 "payload": {"action_id": "establish_faction", "refresh_required": true} }

# execute_action variant that passes full target dict (for "member" kind actions)
func execute_action_with_target(state: WorldState, action: String, target: Dictionary) -> Dictionary:
	var pt: TeamData = _get_player_team(state)
	var pt_id: int   = _get_player_team_id(state)
	if pt == null:
		return { "ok": false, "msg": "找不到玩家 team" }
	match action:
		"recruit_named":
			var from_team_id: int = target.get("team_id", -1)
			var person_id: int    = target.get("member_id", -1)
			return _recruit_named_internal(state, pt, from_team_id, person_id)
	return { "ok": false, "msg": "不支援 member 目標的行動: %s" % action }

func _recruit_named_internal(state: WorldState, pt: TeamData,
		from_team_id: int, person_id: int) -> Dictionary:
	var tgt4: TeamData    = state.teams.get(from_team_id)
	var p: PersonData     = state.persons.get(person_id)
	if tgt4 == null or p == null or p.team_id != from_team_id:
		return { "ok": false, "msg": "成員不存在或已離隊" }
	var coin: float = float(pt.resources.get("coin", 0))
	if coin < RECRUIT_COST_NAMED:
		return { "ok": false, "msg": "金幣不足（named 需%d）" % int(RECRUIT_COST_NAMED) }
	# 轉移
	var pt_id: int = _get_player_team_id(state)
	pt.resources["coin"] = coin - RECRUIT_COST_NAMED
	tgt4.named_members.erase(person_id)
	tgt4.population = maxi(tgt4.population - 1, 1)
	p.team_id = pt_id
	p.loyalty  = 0.5
	pt.named_members.append(person_id)
	pt.population += 1
	state.player_pending_targets.erase(from_team_id)
	print("[Recruit] Named P%d (%s) Team%d→%d" % [
		person_id, p.person_name, from_team_id, pt_id])
	return { "ok": true, "msg": "招募 %s 成功（花費%d coin）" % [
		p.person_name, int(RECRUIT_COST_NAMED)],
		"payload": {"refresh_required": true} }
