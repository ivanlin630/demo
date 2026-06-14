class_name PlayerQueryApi

func get_player_snapshot(state: WorldState, request: Dictionary) -> Dictionary:
	var player_check := _check_player_with_team(state)
	if player_check["code"] != "ok":
		return PlayerApiMapper.map_query_envelope(false, player_check["code"], player_check["msg"], {})

	var focus_team_id: int   = request.get("focus_team_id",   -1)
	var focus_member_id: int = request.get("focus_member_id", -1)
	var cursor_q: int        = request.get("cursor_tile_q",   -1)
	var cursor_r: int        = request.get("cursor_tile_r",   -1)

	if focus_member_id != -1 and focus_team_id == -1:
		return PlayerApiMapper.map_query_envelope(false, "invalid_focus",
			"focus_member_id requires focus_team_id", {})
	if (cursor_q == -1) != (cursor_r == -1):
		return PlayerApiMapper.map_query_envelope(false, "invalid_request",
			"cursor_tile_q and cursor_tile_r must both be set or both be -1", {})

	var cmd_sys := PlayerCommandSystem.new()
	var actions := _build_available_actions(state, cmd_sys, focus_team_id, focus_member_id, cursor_q, cursor_r)
	var snapshot := PlayerApiMapper.map_player_snapshot(
		state, focus_team_id, focus_member_id, cursor_q, cursor_r, actions)
	return PlayerApiMapper.map_query_envelope(true, "ok", "", {"snapshot": snapshot})

func get_team_details(state: WorldState, team_id: int) -> Dictionary:
	var check := _check_player(state)
	if check["code"] != "ok":
		return PlayerApiMapper.map_query_envelope(false, check["code"], check["msg"], {})
	if not state.teams.has(team_id):
		return PlayerApiMapper.map_query_envelope(false, "invalid_team", "team not found", {})
	var p: PersonData = state.persons[state.player_id]
	var discovered: Array = state.team_discovered.get(p.team_id, [])
	if team_id != p.team_id and not discovered.has(team_id):
		return PlayerApiMapper.map_query_envelope(false, "not_visible", "team not visible", {})
	var t: TeamData = state.teams[team_id]
	var members: Array = []
	for mid in ([t.leader_id] + t.named_members):
		var m: PersonData = state.persons.get(mid)
		if m != null:
			members.append({"id": m.id, "name": m.person_name, "role": m.role})
	var team_data: Dictionary = {
		"id": team_id,
		"name": "Team%d" % team_id,
		"faction": str(t.faction_id) if t.faction_id != -1 else "",
		"position": {"q": t.tile_pos.x, "r": t.tile_pos.y},
		"members": members,
		"resources": {
			"food":     int(t.resources.get("food", 0)),
			"coin":     int(t.resources.get("coin", 0)),
			"material": int(t.resources.get("material", 0))
		},
		"interaction_options": []
	}
	return PlayerApiMapper.map_query_envelope(true, "ok", "", {"team": team_data})

func get_member_details(state: WorldState, team_id: int, member_id: int) -> Dictionary:
	var check := _check_player(state)
	if check["code"] != "ok":
		return PlayerApiMapper.map_query_envelope(false, check["code"], check["msg"], {})
	if not state.teams.has(team_id):
		return PlayerApiMapper.map_query_envelope(false, "invalid_team", "team not found", {})
	var p: PersonData = state.persons[state.player_id]
	var discovered: Array = state.team_discovered.get(p.team_id, [])
	if team_id != p.team_id and not discovered.has(team_id):
		return PlayerApiMapper.map_query_envelope(false, "not_visible", "team not visible", {})
	var mp: PersonData = state.persons.get(member_id)
	if mp == null or mp.team_id != team_id:
		return PlayerApiMapper.map_query_envelope(false, "invalid_member", "member not found in team", {})
	var member_data: Dictionary = {
		"id": member_id,
		"name": mp.person_name,
		"team_id": team_id,
		"team_name": "Team%d" % team_id,
		"role": mp.role,
		"status": {"health": "healthy", "stress": mp.stress, "loyalty": mp.loyalty},
		"available_actions": []
	}
	return PlayerApiMapper.map_query_envelope(true, "ok", "", {"member": member_data})

func get_location_context(state: WorldState, tile_q: int, tile_r: int) -> Dictionary:
	if state.player_id == -1:
		return PlayerApiMapper.map_query_envelope(false, "no_player", "no player", {})
	if tile_q == -1 or tile_r == -1:
		return PlayerApiMapper.map_query_envelope(false, "invalid_tile", "invalid tile coordinates", {})
	if not state.world.tiles.has(tile_q * 1000 + tile_r):
		return PlayerApiMapper.map_query_envelope(false, "invalid_tile", "tile not found", {})
	var location := PlayerApiMapper.map_location_context(state, tile_q, tile_r)
	return PlayerApiMapper.map_query_envelope(true, "ok", "", {"location": location})

func get_trade_preview(state: WorldState, target_team_id: int) -> Dictionary:
	var check := _check_player_with_team(state)
	if check["code"] != "ok":
		return PlayerApiMapper.map_query_envelope(false, check["code"], check["msg"], {})
	var p: PersonData  = state.persons[state.player_id]
	var pt_id: int     = p.team_id
	if not state.teams.has(target_team_id):
		return PlayerApiMapper.map_query_envelope(false, "invalid_team", "team not found", {})
	var discovered: Array = state.team_discovered.get(pt_id, [])
	if target_team_id != pt_id and not discovered.has(target_team_id):
		return PlayerApiMapper.map_query_envelope(false, "not_visible", "team not visible", {})
	var trade          := PlayerTradeSystem.new()
	var resources      := trade.get_tradeable_resources(state, pt_id, target_team_id)
	var offer: Dictionary = state.player_state.get("trade_offer", {})
	var preview: Dictionary = {}
	if not offer.is_empty():
		preview = trade.preview_offer(state, pt_id, target_team_id, offer)
	return PlayerApiMapper.map_query_envelope(true, "ok", "", {
		"resources":    resources,
		"offer_preview": preview,
	})

# U12: 直接互動交易（resolve_trade_direct）的預覽 — 回 {feasible, player_gives, player_gets}
# text UI confirm_trade 流程走此 auto-trade，非 offer-based get_trade_preview
func get_trade_direct_preview(state: WorldState, target_team_id: int) -> Dictionary:
	var check := _check_player_with_team(state)
	if check["code"] != "ok":
		return PlayerApiMapper.map_query_envelope(false, check["code"], check["msg"], {})
	var p: PersonData = state.persons[state.player_id]
	var pt_id: int    = p.team_id
	if not state.teams.has(target_team_id):
		return PlayerApiMapper.map_query_envelope(false, "invalid_team", "team not found", {})
	var discovered: Array = state.team_discovered.get(pt_id, [])
	if target_team_id != pt_id and not discovered.has(target_team_id):
		return PlayerApiMapper.map_query_envelope(false, "not_visible", "team not visible", {})
	var preview: Dictionary = InteractionSystem.new().preview_trade(state, pt_id, target_team_id)
	return PlayerApiMapper.map_query_envelope(true, "ok", "", { "preview": preview })

func get_available_actions(state: WorldState, request: Dictionary) -> Dictionary:
	var check := _check_player_with_team(state)
	if check["code"] != "ok":
		return PlayerApiMapper.map_query_envelope(false, check["code"], check["msg"], {})

	var team_id: int    = request.get("team_id",              -1)
	var member_id: int  = request.get("member_id",            -1)
	var tile_q: int     = request.get("tile_q",               -1)
	var tile_r: int     = request.get("tile_r",               -1)
	var fi_id: String   = request.get("forced_interaction_id", "")

	if member_id != -1 and team_id == -1:
		return PlayerApiMapper.map_query_envelope(false, "invalid_focus",
			"member_id requires team_id", {})
	if (tile_q == -1) != (tile_r == -1):
		return PlayerApiMapper.map_query_envelope(false, "invalid_request",
			"tile_q and tile_r must both be set or both be -1", {})
	if fi_id != "" and fi_id != state.player_forced_event_id:
		return PlayerApiMapper.map_query_envelope(false, "forced_response_missing",
			"forced interaction expired", {})
	if team_id != -1 and not state.teams.has(team_id):
		return PlayerApiMapper.map_query_envelope(false, "invalid_team", "team not found", {})
	if member_id != -1 and not state.persons.has(member_id):
		return PlayerApiMapper.map_query_envelope(false, "invalid_member", "member not found", {})
	if tile_q != -1 and not state.world.tiles.has(tile_q * 1000 + tile_r):
		return PlayerApiMapper.map_query_envelope(false, "invalid_tile", "tile not found", {})

	var cmd_sys := PlayerCommandSystem.new()
	var actions := _build_available_actions(state, cmd_sys, team_id, member_id, tile_q, tile_r)
	return PlayerApiMapper.map_query_envelope(true, "ok", "", {"actions": actions})

# ── Private helpers ────────────────────────────────────────────────────────────

func _check_player(state: WorldState) -> Dictionary:
	if state.player_id == -1 or not state.persons.has(state.player_id):
		return {"code": "no_player", "msg": "no player"}
	return {"code": "ok", "msg": ""}

func _check_player_with_team(state: WorldState) -> Dictionary:
	var check := _check_player(state)
	if check["code"] != "ok":
		return check
	var p: PersonData = state.persons[state.player_id]
	if not state.teams.has(p.team_id):
		return {"code": "no_controlled_team", "msg": "no controlled team"}
	return {"code": "ok", "msg": ""}

func _build_available_actions(state: WorldState, cmd_sys: PlayerCommandSystem,
		focus_team_id: int, focus_member_id: int, cursor_q: int, cursor_r: int) -> Array:
	var actions: Array = []
	# Layer 1: forced interaction responses
	var fi := PlayerApiMapper.map_forced_interaction(state)
	for resp in fi.get("responses", []):
		actions.append(PlayerApiMapper.map_available_action(
			"forced_%s" % resp["response_id"],
			resp["label"],
			true, "",
			{
				"allowed_kinds": PackedStringArray(["none"]),
				"requires_visible_target": false,
				"requires_forced_interaction": true,
				"allows_self_target": false
			},
			"respond_to_forced", resp["command_args"]
		))

	# Layer 2 & 3: focused member / tile context (Phase 1: empty — spec allows this)

	# Layer 4: team-level actions against focused team
	var p: PersonData = state.persons.get(state.player_id)
	var ptid: int = p.team_id if p != null else -1
	if focus_team_id != -1 and focus_team_id != ptid and state.teams.has(focus_team_id):
		var team_actions: Array[String] = cmd_sys.get_available_actions(state, focus_team_id)
		for act in team_actions:
			actions.append(PlayerApiMapper.map_available_action(
				act, _action_label(act), true, "",
				{
					"allowed_kinds": PackedStringArray(["team"]),
					"requires_visible_target": true,
					"requires_forced_interaction": false,
					"allows_self_target": false
				},
				"execute_action",
				{
					"action_id": act,
					"target": {"kind": "team", "team_id": focus_team_id, "member_id": -1, "tile_q": -1, "tile_r": -1}
				}
			))

		# Disabled actions (shown in menu with reason)
		var tgt_team: TeamData = state.teams.get(focus_team_id)
		var pt_team: TeamData  = state.teams.get(ptid) if ptid != -1 else null
		if pt_team != null and tgt_team != null:
			# demand_tribute: disabled when population condition not met
			if not team_actions.has("demand_tribute"):
				var tribute_ok: bool = pt_team.population > int(tgt_team.population * 1.5)
				if not tribute_ok:
					actions.append(PlayerApiMapper.map_available_action(
						"demand_tribute", "索貢", false,
						"人口不足（需超過對方 1.5 倍）",
						{
							"allowed_kinds": PackedStringArray(["team"]),
							"requires_visible_target": true,
							"requires_forced_interaction": false,
							"allows_self_target": false
						},
						"execute_action",
						{
							"action_id": "demand_tribute",
							"target": {"kind": "team", "team_id": focus_team_id, "member_id": -1, "tile_q": -1, "tile_r": -1}
						}
					))
			# extort: disabled when readiness < 0.7
			if not team_actions.has("extort"):
				actions.append(PlayerApiMapper.map_available_action(
					"extort", "勒索", false,
					"準備值不足（需 ≥ 0.7，現為%.1f）" % pt_team.readiness,
					{
						"allowed_kinds": PackedStringArray(["team"]),
						"requires_visible_target": true,
						"requires_forced_interaction": false,
						"allows_self_target": false
					},
					"execute_action",
					{
						"action_id": "extort",
						"target": {"kind": "team", "team_id": focus_team_id, "member_id": -1, "tile_q": -1, "tile_r": -1}
					}
				))
			# recruit: disabled when coin < RECRUIT_COST_ANON
			if not team_actions.has("recruit"):
				var pt_coin: float = float(pt_team.resources.get("coin", 0))
				if pt_coin < PlayerCommandSystem.RECRUIT_COST_ANON:
					actions.append(PlayerApiMapper.map_available_action(
						"recruit", "招募", false,
						"金幣不足（需%d，現%d）" % [int(PlayerCommandSystem.RECRUIT_COST_ANON), int(pt_coin)],
						{
							"allowed_kinds": PackedStringArray(["team"]),
							"requires_visible_target": true,
							"requires_forced_interaction": false,
							"allows_self_target": false
						},
						"execute_action",
						{
							"action_id": "recruit",
							"target": {"kind": "team", "team_id": focus_team_id, "member_id": -1, "tile_q": -1, "tile_r": -1}
						}
					))

	# move_to (cursor set)
	if cursor_q != -1 and cursor_r != -1:
		actions.append(PlayerApiMapper.map_available_action(
			"move_to", "移動到 (%d,%d)" % [cursor_q, cursor_r], true, "",
			{
				"allowed_kinds": PackedStringArray(["tile"]),
				"requires_visible_target": false,
				"requires_forced_interaction": false,
				"allows_self_target": false
			},
			"move_to", {"tile_q": cursor_q, "tile_r": cursor_r}
		))

	# cancel_move (team has a move target)
	var pt: TeamData = state.teams.get(ptid) if ptid != -1 else null
	if pt != null and pt.move_target != Vector2i(-1, -1):
		actions.append(PlayerApiMapper.map_available_action(
			"cancel_move", "取消移動", true, "",
			{
				"allowed_kinds": PackedStringArray(["none"]),
				"requires_visible_target": false,
				"requires_forced_interaction": false,
				"allows_self_target": false
			},
			"cancel_move", {}
		))

	# Layer 5: player-team global actions (no target required)
	var pt_data: TeamData = state.teams.get(ptid) if ptid != -1 else null
	if pt_data != null and pt_data.faction_id == -1:
		actions.append(PlayerApiMapper.map_available_action(
			"establish_faction", "建立勢力", true, "",
			{
				"allowed_kinds": PackedStringArray(["none"]),
				"requires_visible_target": false,
				"requires_forced_interaction": false,
				"allows_self_target": false
			},
			"execute_action",
			{
				"action_id": "establish_faction",
				"target": {"kind": "none", "team_id": -1, "member_id": -1, "tile_q": -1, "tile_r": -1}
			}
		))

	# take_loot / leave_loot when player won last encounter
	if not state.last_encounter_result.is_empty():
		var ler: Dictionary = state.last_encounter_result
		if ler.get("winner_id", -1) == ptid:
			var loot_preview: Dictionary = ler.get("loot_pool", {})
			actions.append(PlayerApiMapper.map_available_action(
				"take_loot", "收取戰利品", true, "",
				{
					"allowed_kinds": PackedStringArray(["none"]),
					"requires_visible_target": false,
					"requires_forced_interaction": false,
					"allows_self_target": false
				},
				"execute_action",
				{
					"action_id": "take_loot",
					"target": {"kind": "none", "team_id": -1, "member_id": -1, "tile_q": -1, "tile_r": -1},
					"loot_preview": loot_preview
				}
			))
			actions.append(PlayerApiMapper.map_available_action(
				"leave_loot", "放棄戰利品", true, "",
				{
					"allowed_kinds": PackedStringArray(["none"]),
					"requires_visible_target": false,
					"requires_forced_interaction": false,
					"allows_self_target": false
				},
				"execute_action",
				{
					"action_id": "leave_loot",
					"target": {"kind": "none", "team_id": -1, "member_id": -1, "tile_q": -1, "tile_r": -1}
				}
			))

	# subjugate_enemy（戰後可收編）
	if state.last_encounter_result.get("can_subjugate", false):
		actions.append(PlayerApiMapper.map_available_action(
			"subjugate_enemy", "收編敗者", true, "",
			{
				"allowed_kinds": PackedStringArray(["none"]),
				"requires_visible_target": false,
				"requires_forced_interaction": false,
				"allows_self_target": false
			},
			"execute_action",
			{"action_id": "subjugate_enemy",
			 "target": {"kind": "none", "team_id": -1, "member_id": -1, "tile_q": -1, "tile_r": -1}}
		))

	# confirm_gather_intel（等待選題）
	if state.player_state.has("pending_intel_target"):
		actions.append(PlayerApiMapper.map_available_action(
			"confirm_gather_intel", "確認打聽", true, "",
			{
				"allowed_kinds": PackedStringArray(["none"]),
				"requires_visible_target": false,
				"requires_forced_interaction": false,
				"allows_self_target": false
			},
			"execute_action",
			{"action_id": "confirm_gather_intel",
			 "target": {"kind": "none", "team_id": -1, "member_id": -1, "tile_q": -1, "tile_r": -1}}
		))

	# offer_surrender（戰鬥中對目標提出投降）
	if state.encounter_active and focus_team_id != -1:
		actions.append(PlayerApiMapper.map_available_action(
			"offer_surrender", "投降請和", true, "",
			{
				"allowed_kinds": PackedStringArray(["team"]),
				"requires_visible_target": true,
				"requires_forced_interaction": false,
				"allows_self_target": false
			},
			"execute_action",
			{"action_id": "offer_surrender",
			 "target": {"kind": "team", "team_id": focus_team_id, "member_id": -1, "tile_q": -1, "tile_r": -1}}
		))

	# Layer 6: 玩家隊 self/tile 動作（hunt/hunt_beast，依腳下 tile）
	var self_tile: HexTileData = pt_tile_self(state, ptid)
	if self_tile != null:
		if int(self_tile.resources.get("wild_game", 0)) > 0:
			actions.append(PlayerApiMapper.map_available_action(
				"hunt", _action_label("hunt"), true, "",
				{ "allowed_kinds": PackedStringArray(["none"]),
				  "requires_visible_target": false, "requires_forced_interaction": false,
				  "allows_self_target": false },
				"execute_action",
				{ "action_id": "hunt", "target": {"kind": "none", "team_id": -1, "member_id": -1, "tile_q": -1, "tile_r": -1} }))
		if int(self_tile.resources.get("predator_density", 0)) > 0:
			actions.append(PlayerApiMapper.map_available_action(
				"hunt_beast", _action_label("hunt_beast"), true, "",
				{ "allowed_kinds": PackedStringArray(["none"]),
				  "requires_visible_target": false, "requires_forced_interaction": false,
				  "allows_self_target": false },
				"execute_action",
				{ "action_id": "hunt_beast", "target": {"kind": "none", "team_id": -1, "member_id": -1, "tile_q": -1, "tile_r": -1} }))

	return actions

func pt_tile_self(state: WorldState, ptid: int) -> HexTileData:
	if ptid == -1 or not state.teams.has(ptid): return null
	var pt: TeamData = state.teams[ptid]
	return state.world.tiles.get(pt.tile_pos.x * 1000 + pt.tile_pos.y)

func get_and_clear_alerts(state: WorldState) -> Array:
	var alerts: Array = state.player_alerts.duplicate()
	state.player_alerts.clear()
	return alerts

func query_faction_panel(state: WorldState) -> Dictionary:
	var check := _check_player(state)
	if check["code"] != "ok":
		return PlayerApiMapper.map_query_envelope(false, check["code"], check["msg"], {})
	return PlayerApiMapper.map_query_envelope(true, "ok", "",
		{"faction_panel": PlayerApiMapper.map_faction_panel(state)})

func query_outpost_panel(state: WorldState) -> Dictionary:
	var check := _check_player(state)
	if check["code"] != "ok":
		return PlayerApiMapper.map_query_envelope(false, check["code"], check["msg"], {})
	return PlayerApiMapper.map_query_envelope(true, "ok", "",
		{"outpost_panel": PlayerApiMapper.map_outpost_panel(state)})

func query_subteam_panel(state: WorldState) -> Dictionary:
	var check := _check_player(state)
	if check["code"] != "ok":
		return PlayerApiMapper.map_query_envelope(false, check["code"], check["msg"], {})
	return PlayerApiMapper.map_query_envelope(true, "ok", "",
		{"subteam_panel": PlayerApiMapper.map_subteam_panel(state)})

func _action_label(action_id: String) -> String:
	match action_id:
		"ignore":           return "忽略"
		"attack":           return "攻擊"
		"trade":            return "貿易"
		"propose_alliance": return "提議同盟"
		"demand_tribute":        return "要求納貢"
		"extort":                return "勒索"
		"recruit":               return "招募"
		"establish_faction":     return "建立勢力"
		"hunt":                  return "狩獵"
		"hunt_beast":            return "獵猛獸"
		"take_loot":             return "收割戰利品"
		"leave_loot":            return "放棄戰利品"
		"recruit_anon":          return "招募匿名"
		"recruit_named":         return "招募成員"
		"confirm_trade":         return "確認貿易"
		"cancel_trade":          return "取消貿易"
		"gather_intel":           return "打聽情報"
		"confirm_gather_intel":   return "確認打聽"
		"subjugate_enemy":        return "收編敗者"
		"offer_surrender":        return "投降請和"
		"surrender_in_encounter": return "戰中投降"
		"leave_faction":          return "退出勢力"
		"betray_faction":         return "背叛勢力"
		"disband_faction":        return "解散勢力"
		"set_faction_goal":       return "設定勢力目標"
		"order_faction_member":   return "下令成員"
		"clear_member_order":     return "清除指令"
		"set_tribute_rate":       return "調整徵收率"
		"build_outpost":          return "建設前哨站"
		"upgrade_outpost":        return "升級等級"
		"upgrade_farming":        return "升級農作"
		"upgrade_manufacturing":  return "升級製造"
		"demolish_outpost":       return "拆除前哨站"
		"dispatch_subteam":       return "派遣子隊"
		"order_subteam":          return "下令子隊"
		"recall_subteam":         return "召回子隊"
	return action_id
