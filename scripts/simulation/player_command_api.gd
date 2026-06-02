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
	return PlayerApiMapper.map_command_result(false, "invalid_request", "unknown command: %s" % name, {})
