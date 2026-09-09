class_name PlayerCommandApi

var _cmd_sys: PlayerCommandSystem = PlayerCommandSystem.new()
var _ps: PlayerSystem = PlayerSystem.new()

# ── Guard helpers ──────────────────────────────────────────────────────────────
# Returns empty dict on success; returns error map_command_result on failure.
# Callers: if not pre.is_empty(): return pre

func _check_player(state: WorldState) -> Dictionary:
	if state.player_id == -1 or not state.persons.has(state.player_id):
		return PlayerApiMapper.map_command_result(false, "no_player", "no player", {})
	return {}

func _check_controlled_team(state: WorldState) -> Dictionary:
	var pre := _check_player(state)
	if not pre.is_empty():
		return pre
	var p: PersonData = state.persons[state.player_id]
	if not state.teams.has(p.team_id):
		return PlayerApiMapper.map_command_result(false, "no_controlled_team", "no controlled team", {})
	return {}

# ── Commands ───────────────────────────────────────────────────────────────────

func move_to(state: WorldState, tile_q: int, tile_r: int) -> Dictionary:
	var pre := _check_controlled_team(state)
	if not pre.is_empty(): return pre
	var result := _cmd_sys.move_to(state, Vector2i(tile_q, tile_r))
	if result.get("ok", false):
		return PlayerApiMapper.map_command_result(true, "ok", result.get("msg", ""),
			{"move_target": {"q": tile_q, "r": tile_r}, "refresh_required": true})
	var code: String = "invalid_tile" if "格" in result.get("msg", "") else "move_unavailable"
	return PlayerApiMapper.map_command_result(false, code, result.get("msg", ""), {})

func cancel_move(state: WorldState) -> Dictionary:
	var pre := _check_controlled_team(state)
	if not pre.is_empty(): return pre
	var result := _cmd_sys.cancel_move(state)
	if result.get("ok", false):
		return PlayerApiMapper.map_command_result(true, "ok", result.get("msg", ""),
			{"move_cancelled": true, "refresh_required": true})
	return PlayerApiMapper.map_command_result(false, "move_unavailable", result.get("msg", ""), {})

func execute_action(state: WorldState, action_id: String, target: Dictionary) -> Dictionary:
	var pre := _check_controlled_team(state)
	if not pre.is_empty(): return pre
	if action_id == "":
		return PlayerApiMapper.map_command_result(false, "invalid_request", "action_id required", {})
	var kind: String = target.get("kind", "none")
	var target_team_id: int = target.get("team_id", -1)
	var result: Dictionary
	match kind:
		"team":
			if not state.teams.has(target_team_id):
				return PlayerApiMapper.map_command_result(false, "invalid_target", "target team not found", {})
			result = _cmd_sys.execute_action(state, target_team_id, action_id)
		"none":
			result = _cmd_sys.execute_action(state, -1, action_id)
		"member":
			var member_id: int = target.get("member_id", -1)
			if member_id == -1:
				return PlayerApiMapper.map_command_result(false, "invalid_target", "member_id required", {})
			if target_team_id == -1 or not state.teams.has(target_team_id):
				return PlayerApiMapper.map_command_result(false, "invalid_target", "team_id required for member target", {})
			# Pass full target dict to cmd_sys; cmd_sys reads member_id from request
			result = _cmd_sys.execute_action_with_target(state, action_id, target)
		_:
			return PlayerApiMapper.map_command_result(false, "invalid_target", "unsupported target kind: %s" % kind, {})
	if result.get("ok", false):
		var payload: Dictionary = {"action_id": action_id, "result_summary": result.get("msg", ""), "refresh_required": true}
		payload.merge(result.get("payload", {}))   # forward inner payload (inquiry_options etc.)
		if result.has("requires_preview"):
			payload["requires_preview"] = result["requires_preview"]
		if result.has("preview_target_id"):
			payload["preview_target_id"] = result["preview_target_id"]
		return PlayerApiMapper.map_command_result(true, "ok", result.get("msg", ""), payload)
	return PlayerApiMapper.map_command_result(false, "action_unavailable", result.get("msg", ""), {})

func respond_to_forced(state: WorldState, interaction_id: String, response_id: String) -> Dictionary:
	var pre := _check_player(state)
	if not pre.is_empty(): return pre
	var result := _cmd_sys.resolve_forced_response(state, interaction_id, response_id)
	if not result.get("ok", false):
		return PlayerApiMapper.map_command_result(false, result.get("code", "action_unavailable"), result.get("msg", ""), {})
	if result.get("ok", false):
		return PlayerApiMapper.map_command_result(true, "ok", result.get("msg", ""),
			{"forced_interaction_resolved": true, "refresh_required": true})
	return PlayerApiMapper.map_command_result(false, "action_unavailable", result.get("msg", ""), {})

func equip_item(state: WorldState, slot_id: String, item_grade: String) -> Dictionary:
	var pre := _check_player(state)
	if not pre.is_empty(): return pre
	if slot_id == "" or item_grade == "":
		return PlayerApiMapper.map_command_result(false, "invalid_request", "slot_id and item_grade required", {})
	var ok: bool = _ps.equip_item(state, slot_id, item_grade)
	if ok:
		return PlayerApiMapper.map_command_result(true, "ok", "裝備 %s → %s" % [item_grade, slot_id],
			{"equipped_slot": slot_id, "item_grade": item_grade, "refresh_required": true})
	return PlayerApiMapper.map_command_result(false, "equip_unavailable", "無法裝備", {})

func unequip_item(state: WorldState, slot_id: String) -> Dictionary:
	var pre := _check_player(state)
	if not pre.is_empty(): return pre
	if slot_id == "":
		return PlayerApiMapper.map_command_result(false, "invalid_request", "slot_id required", {})
	var ok: bool = _ps.unequip_item(state, slot_id)
	if ok:
		return PlayerApiMapper.map_command_result(true, "ok", "卸下 %s" % slot_id,
			{"unequipped_slot": slot_id, "refresh_required": true})
	return PlayerApiMapper.map_command_result(false, "equip_unavailable", "無法卸裝", {})

func deposit_item(state: WorldState, item_grade: String, qty: int) -> Dictionary:
	var pre := _check_controlled_team(state)
	if not pre.is_empty(): return pre
	if item_grade == "":
		return PlayerApiMapper.map_command_result(false, "invalid_request", "item_grade required", {})
	if qty <= 0:
		return PlayerApiMapper.map_command_result(false, "invalid_request", "qty must be > 0", {})
	var ok: bool = _ps.deposit_to_team(state, item_grade, qty)
	if ok:
		return PlayerApiMapper.map_command_result(true, "ok", "存入 %s×%d" % [item_grade, qty],
			{"item_grade": item_grade, "qty": qty, "refresh_required": true})
	return PlayerApiMapper.map_command_result(false, "deposit_unavailable", "無法存入", {})

func take_team_item(state: WorldState, item_grade: String, qty: int) -> Dictionary:
	var pre := _check_controlled_team(state)
	if not pre.is_empty(): return pre
	if item_grade == "":
		return PlayerApiMapper.map_command_result(false, "invalid_request", "item_grade required", {})
	if qty <= 0:
		return PlayerApiMapper.map_command_result(false, "invalid_request", "qty must be > 0", {})
	var ok: bool = _ps.take_from_team(state, item_grade, qty)
	if ok:
		return PlayerApiMapper.map_command_result(true, "ok", "取出 %s×%d" % [item_grade, qty],
			{"item_grade": item_grade, "qty": qty, "refresh_required": true})
	return PlayerApiMapper.map_command_result(false, "take_unavailable", "無法取出", {})

# ── Dispatch ───────────────────────────────────────────────────────────────────

# ── 市場四件套（C1 票①）：★接既有 order_system，不新寫市場邏輯 ──────────────
# ★「板上掛單／撮合」與既有 execute_action("trade") 的【隊對隊直接交易】是兩回事，
#   而玩家層原本【只有後者】—— 世界有市場而玩家碰不到它。

func post_buy_order(state: WorldState, res: String, qty: int) -> Dictionary:
	return _post_order(state, "buy", res, qty)

func post_sell_order(state: WorldState, res: String, qty: int) -> Dictionary:
	return _post_order(state, "sell", res, qty)

func _post_order(state: WorldState, kind: String, res: String, qty: int) -> Dictionary:
	var check := _check_controlled_team(state)
	if not check.is_empty():
		return check
	var team: TeamData = state.teams[state.persons[state.player_id].team_id]
	var oid: int = OrderSystem.new().post_order(state, team, kind, res, qty)
	if oid < 0:
		return PlayerApiMapper.map_command_result(false, "invalid_request",
			"post_order rejected (qty<=0 或掛單條件不符)", { "kind": kind, "res": res, "qty": qty })
	return PlayerApiMapper.map_command_result(true, "ok", "",
		{ "order_id": oid, "kind": kind, "res": res, "qty": qty })

func cancel_order(state: WorldState, order_id: int) -> Dictionary:
	var check := _check_controlled_team(state)
	if not check.is_empty():
		return check
	var team: TeamData = state.teams[state.persons[state.player_id].team_id]
	# ★走 order_system 的唯一入口：它共用 escrow 釋放（守恆），★而【不】記失敗記憶
	var ok: bool = OrderSystem.new().cancel_order(state, team, order_id)
	if not ok:
		return PlayerApiMapper.map_command_result(false, "not_found",
			"no such active order: %d" % order_id, { "order_id": order_id })
	return PlayerApiMapper.map_command_result(true, "ok", "", { "order_id": order_id })

# ── 附身／離身（C1 票①）：★語意 = state.player_id 是唯一開關（world_state.gd:101/752）──
# ★離身要還原成【附身前那個 id】⇒ 需要一個地方記住它。
#   ★★記在 WorldState（`player_possess_prev`）而不是 API 實例：
#   API 是每次呼叫 new 出來的（見 sim_bridge），實例欄位活不過一次呼叫。
#   ★★★而它【不進 fingerprint】（StateFingerprint 只 emit teams/persons/world/factions/belief）
#   ⇒ 加這個欄位不改世界。

func possess(state: WorldState, person_id: int) -> Dictionary:
	if not state.persons.has(person_id):
		return PlayerApiMapper.map_command_result(false, "not_found",
			"no such person: %d" % person_id, {})
	var prev: int = state.player_id
	state.player_possess_prev = prev
	state.player_id = person_id
	return PlayerApiMapper.map_command_result(true, "ok", "",
		{ "player_id": person_id, "prev_player_id": prev })

func unpossess(state: WorldState) -> Dictionary:
	var prev: int = state.player_possess_prev
	var cur: int = state.player_id
	state.player_id = prev
	state.player_possess_prev = -1
	return PlayerApiMapper.map_command_result(true, "ok", "",
		{ "player_id": prev, "left_person_id": cur })

# ── 時間控制（C1 票①）：★不在 sim_runner 加狀態 ────────────────────────────
# ★「推進幾步」留在呼叫端（REPL 傳 runner 進來）—— 否則會多出一個「誰在控制時間」的第二真相源。
# ★★暫停 ＝ 呼叫端不呼叫它（不是引擎裡的一個旗標）。
func advance_ticks(state: WorldState, runner: SimRunner, n: int) -> Dictionary:
	if runner == null or n <= 0:
		return PlayerApiMapper.map_command_result(false, "invalid_request",
			"advance_ticks needs runner and n>0", { "n": n })
	var before: int = state.world.current_tick
	var stalled_at: int = -1
	var stall_reason: String = ""
	for i in n:
		var r: String = runner.advance_tick(state, Vector2i(-1, -1))
		if r != "" and stalled_at == -1:
			stalled_at = state.world.current_tick
			stall_reason = r
	# ★回傳【真的推進了幾 tick】而不是「呼叫成功」——game_over/等待繼承人會凍結世界
	return PlayerApiMapper.map_command_result(true, "ok", "", {
		"advanced": state.world.current_tick - before, "requested": n,
		"first_stall_tick": stalled_at, "stall_reason": stall_reason,
	})

func dispatch(state: WorldState, name: String, args: Dictionary) -> Dictionary:
	match name:
		"move_to":
			return move_to(state, args.get("tile_q", -1), args.get("tile_r", -1))
		"cancel_move":
			return cancel_move(state)
		"execute_action":
			return execute_action(state, args.get("action_id", ""), args.get("target", {}))
		"respond_to_forced":
			return respond_to_forced(state, args.get("interaction_id", ""), args.get("response_id", ""))
		"equip_item":
			return equip_item(state, args.get("slot_id", ""), args.get("item_grade", ""))
		"unequip_item":
			return unequip_item(state, args.get("slot_id", ""))
		"deposit_item":
			return deposit_item(state, args.get("item_grade", ""), args.get("qty", 0))
		"take_team_item":
			return take_team_item(state, args.get("item_grade", ""), args.get("qty", 0))
		"post_buy_order":
			return post_buy_order(state, args.get("res", ""), args.get("qty", 0))
		"post_sell_order":
			return post_sell_order(state, args.get("res", ""), args.get("qty", 0))
		"cancel_order":
			return cancel_order(state, args.get("order_id", -1))
		"possess":
			return possess(state, args.get("person_id", -1))
		"unpossess":
			return unpossess(state)
	return PlayerApiMapper.map_command_result(false, "invalid_request", "unknown command: %s" % name, {})
