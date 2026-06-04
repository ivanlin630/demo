class_name PlayerApiMapper

# ── Equippable slot lookup (compile-time const) ────────────────────────────────
const EQUIPPABLE_SLOTS: Dictionary = {
	"weapon_melee_low":   ["hand_1", "hand_2"],
	"weapon_melee_high":  ["hand_1", "hand_2"],
	"weapon_ranged_low":  ["hand_1"],
	"weapon_ranged_high": ["hand_1"],
	"armor_low":          ["head", "torso", "hand_1"],
	"armor_high":         ["head", "torso"],
}

# ── Envelope builders ──────────────────────────────────────────────────────────

static func map_query_envelope(ok: bool, code: String, message: String, data: Dictionary) -> Dictionary:
	return {"ok": ok, "code": code, "message": message, "data": data}

static func map_command_result(ok: bool, code: String, message: String, payload: Dictionary) -> Dictionary:
	return {"ok": ok, "code": code, "message": message, "payload": payload}

# ── Player summary ─────────────────────────────────────────────────────────────

static func map_player_summary(state: WorldState) -> Dictionary:
	var pid: int = state.player_id
	if pid == -1:
		return {
			"player_exists": false, "player_person_id": -1, "player_name": "",
			"controlled_team_id": -1, "controlled_team_name": "",
			"position": {"q": -1, "r": -1}, "encounter_active": false,
			"has_pending_targets": false, "has_forced_interaction": false
		}
	var p: PersonData = state.persons.get(pid)
	if p == null:
		return {
			"player_exists": false, "player_person_id": pid, "player_name": "",
			"controlled_team_id": -1, "controlled_team_name": "",
			"position": {"q": -1, "r": -1}, "encounter_active": false,
			"has_pending_targets": false, "has_forced_interaction": false
		}
	var tid: int = p.team_id
	var t: TeamData = state.teams.get(tid) if tid != -1 else null
	var _skills: Dictionary = {}
	for k in p.skills:
		if float(p.skills[k]) > 0.01:
			_skills[k] = float(p.skills[k])
	return {
		"player_exists": true,
		"player_person_id": pid,
		"player_name": p.person_name,
		"controlled_team_id": tid,
		"controlled_team_name": "Team%d" % tid if tid != -1 else "",
		"position": {"q": t.tile_pos.x, "r": t.tile_pos.y} if t != null else {"q": -1, "r": -1},
		"encounter_active": state.encounter_active,
		"has_pending_targets": not state.player_pending_targets.is_empty(),
		"has_forced_interaction": not state.player_forced_event.is_empty(),
		"hp_status": _hp_status(p),
		"skills": _skills,
	}

# ── Controlled team ────────────────────────────────────────────────────────────

static func map_controlled_team(state: WorldState) -> Dictionary:
	var pid: int = state.player_id
	var p: PersonData = state.persons.get(pid) if pid != -1 else null
	var tid: int = p.team_id if p != null else -1
	var t: TeamData = state.teams.get(tid) if tid != -1 else null
	if t == null:
		return {}
	var members: Array = []
	var member_ids: Array = []
	if t.leader_id != -1:
		member_ids.append(t.leader_id)
	for mid in t.named_members:
		if mid != -1 and not member_ids.has(mid):
			member_ids.append(mid)
	for mid in member_ids:
		var m: PersonData = state.persons.get(mid)
		if m != null:
			members.append({
				"id": m.id,
				"name": m.person_name,
				"role": m.role,
				"hp_status": _hp_status(m),
				"equipment": {
					"hand_1": m.equipment.get("hand_1", {}).get("grade", ""),
					"torso":  m.equipment.get("torso",  {}).get("grade", ""),
				}
			})
	var mv: Vector2i = t.move_target
	return {
		"id": tid,
		"name": "Team%d" % tid,
		"faction": str(t.faction_id) if t.faction_id != -1 else "",
		"faction_display": ("勢力%d" % t.faction_id) if t.faction_id >= 0 else "獨立",
		"position": {"q": t.tile_pos.x, "r": t.tile_pos.y},
		"members": members,
		"resources": {
			"food":               int(t.resources.get("food", 0)),
			"coin":               int(t.resources.get("coin", 0)),
			"material":           int(t.resources.get("material", 0)),
			"weapon_melee_low":   int(t.resources.get("weapon_melee_low", 0)),
			"weapon_melee_high":  int(t.resources.get("weapon_melee_high", 0)),
			"weapon_ranged_low":  int(t.resources.get("weapon_ranged_low", 0)),
			"weapon_ranged_high": int(t.resources.get("weapon_ranged_high", 0)),
			"armor_low":          int(t.resources.get("armor_low", 0)),
			"armor_high":         int(t.resources.get("armor_high", 0)),
			"medicine":           int(t.resources.get("medicine", 0)),
			"tools":              int(t.resources.get("tools", 0)),
		},
		"movement": {
			"has_target": mv != Vector2i(-1, -1),
			"target_q": mv.x,
			"target_r": mv.y
		},
		"fatigue_pct":      int(t.fatigue * 100),
		"population":       t.population,
		"minor_population": t.minor_population,
		"faction_id":       t.faction_id,
		"task_summary": t.current_task
	}

# ── Visible teams ──────────────────────────────────────────────────────────────

static func map_visible_teams(state: WorldState) -> Array:
	var pid: int = state.player_id
	var p: PersonData = state.persons.get(pid) if pid != -1 else null
	var tid: int = p.team_id if p != null else -1
	if tid == -1:
		return []
	var discovered: Array = state.team_discovered.get(tid, [])
	var result: Array = []
	for dtid in discovered:
		var dt: TeamData = state.teams.get(dtid)
		if dt == null:
			continue
		result.append({
			"id": dtid,
			"name": "Team%d" % dtid,
			"relation": "unknown",
			"position": {"q": dt.tile_pos.x, "r": dt.tile_pos.y},
			"faction_display": ("勢力%d" % dt.faction_id) if dt.faction_id >= 0 else "獨立",
			"population": dt.population,
			"can_interact": not state.player_pending_targets.has(dtid),
			"can_inspect": true,
			"can_target": true
		})
	return result

# ── Focused member ─────────────────────────────────────────────────────────────

static func map_focused_member(state: WorldState, focus_team_id: int, focus_member_id: int) -> Dictionary:
	var sentinel: Dictionary = {
		"id": -1, "name": "", "team_id": -1, "team_name": "", "role": "",
		"status": {"health": "", "stress": 0.0, "loyalty": 0.0},
		"available_actions": []
	}
	if focus_team_id == -1 or focus_member_id == -1:
		return sentinel
	var t: TeamData = state.teams.get(focus_team_id)
	var mp: PersonData = state.persons.get(focus_member_id)
	if t == null or mp == null or mp.team_id != focus_team_id:
		return sentinel
	return {
		"id": focus_member_id,
		"name": mp.person_name,
		"team_id": focus_team_id,
		"team_name": "Team%d" % focus_team_id,
		"role": mp.role,
		"status": {"health": "healthy", "stress": mp.stress, "loyalty": mp.loyalty},
		"available_actions": []
	}

# ── Pending targets ────────────────────────────────────────────────────────────

static func map_pending_targets(state: WorldState) -> Array:
	var result: Array = []
	for tid in state.player_pending_targets:
		var t: TeamData = state.teams.get(tid)
		result.append({
			"target_type": "team",
			"target_id": int(tid),
			"display_name": "Team%d" % tid,
			"is_valid": t != null
		})
	return result

static func map_willing_members(state: WorldState, person_ids: Array) -> Array:
	var result: Array = []
	for pid in person_ids:
		var p: PersonData = state.persons.get(pid)
		if p == null: continue
		var best_sk: String = "—"; var best_v: float = 0.0
		for sk in p.skills:
			var v: float = float(p.skills[sk])
			if v > best_v: best_v = v; best_sk = "%s:%.2f" % [sk, v]
		result.append({
			"person_id": pid,
			"name": p.person_name if p.person_name != "" else "P%d" % pid,
			"team_id": p.team_id,
			"loyalty": p.loyalty,
			"top_skill": best_sk,
			"recruit_cost": PlayerCommandSystem.RECRUIT_COST_NAMED
		})
	return result

# ── Forced interaction ─────────────────────────────────────────────────────────

static func map_forced_interaction(state: WorldState) -> Dictionary:
	var empty_result: Dictionary = {
		"interaction_id": "",
		"interaction_type": "",
		"source": {"team_id": -1, "team_name": "", "member_id": -1, "member_name": ""},
		"message": "",
		"responses": []
	}
	var evt: Dictionary = state.player_forced_event
	if evt.is_empty():
		return empty_result
	var iid: String = state.player_forced_event_id
	var from_id: int = evt.get("from_id", -1)
	var action: String = evt.get("action", "")
	var proposal: String = evt.get("proposal", "")
	var msg: String = ""
	var responses: Array = []
	match action:
		"diplomacy":
			msg = "Team%d 提議 %s" % [from_id, proposal]
			var from_team: TeamData = state.teams.get(from_id) if state.teams.has(from_id) else null
			var player_pid: int = state.player_id
			var pp: PersonData = state.persons.get(player_pid) if state.persons.has(player_pid) else null
			var player_team: TeamData = state.teams.get(pp.team_id if pp != null else -1) if pp != null else null
			var both_independent: bool = from_team != null and player_team != null \
				and from_team.faction_id == -1 and player_team.faction_id == -1 \
				and evt.get("proposal", "") in ["alliance", "surrender"]

			if both_independent:
				responses = [
					{ "response_id": "accept_join",  "label": "加入對方勢力（對方為主）",
					  "command_args": {"interaction_id": iid, "response_id": "accept_join"} },
					{ "response_id": "accept_lead",  "label": "自立後接納對方（我為主）",
					  "command_args": {"interaction_id": iid, "response_id": "accept_lead"} },
					{ "response_id": "refuse",       "label": "✗ 拒絕",
					  "command_args": {"interaction_id": iid, "response_id": "refuse"} }
				]
			else:
				responses = [
					{"response_id": "accept", "label": "✓ 接受",
					 "command_args": {"interaction_id": iid, "response_id": "accept"}},
					{"response_id": "refuse", "label": "✗ 拒絕",
					 "command_args": {"interaction_id": iid, "response_id": "refuse"}}
				]
		"extort":
			msg = "Team%d 勒索你" % from_id
			responses = [
				{"response_id": "pay", "label": "付錢", "command_args": {"interaction_id": iid, "response_id": "pay"}},
				{"response_id": "refuse", "label": "拒絕", "command_args": {"interaction_id": iid, "response_id": "refuse"}}
			]
		_:
			msg = "Team%d 強制事件" % from_id
			responses = [
				{"response_id": "refuse", "label": "拒絕", "command_args": {"interaction_id": iid, "response_id": "refuse"}}
			]
	return {
		"interaction_id": iid,
		"interaction_type": action,
		"source": {
			"team_id": from_id,
			"team_name": "Team%d" % from_id if from_id != -1 else "",
			"member_id": -1,
			"member_name": ""
		},
		"message": msg,
		"responses": responses
	}

# ── Location context ───────────────────────────────────────────────────────────

static func map_location_context(state: WorldState, tile_q: int, tile_r: int) -> Dictionary:
	var not_visible: Dictionary = {
		"tile": {"q": tile_q, "r": tile_r},
		"visibility_state": "hidden",
		"terrain": null,
		"settlement": null,
		"occupants": [],
		"is_player_here": false,
		"hints": []
	}
	if tile_q == -1 or tile_r == -1:
		not_visible["tile"] = {"q": -1, "r": -1}
		return not_visible
	var tile_key: int = tile_q * 1000 + tile_r
	if not state.world.tiles.has(tile_key):
		return not_visible
	var pid: int = state.player_id
	var p: PersonData = state.persons.get(pid) if pid != -1 else null
	var ptid: int = p.team_id if p != null else -1
	var tile: HexTileData = state.world.tiles[tile_key] as HexTileData
	var pt: TeamData = state.teams.get(ptid) if ptid != -1 else null
	var is_here: bool = pt != null and pt.tile_pos == Vector2i(tile_q, tile_r)
	var occupants: Array = []
	for oid in state.teams:
		if oid == ptid:
			continue
		var ot: TeamData = state.teams[oid]
		if ot.tile_pos == Vector2i(tile_q, tile_r):
			occupants.append({"team_id": oid, "team_name": "Team%d" % oid, "relation": "unknown"})
	var settlement = null
	if tile.outpost_type != "" and tile.outpost_owner != -1:
		settlement = {
			"id": tile.outpost_owner,
			"name": "%s Lv%d" % [tile.outpost_type, tile.outpost_level],
			"owner_faction": ""
		}
	return {
		"tile": {"q": tile_q, "r": tile_r},
		"visibility_state": "visible",
		"terrain": tile.terrain,
		"settlement": settlement,
		"occupants": occupants,
		"is_player_here": is_here,
		"hints": []
	}

# ── Inventory state ────────────────────────────────────────────────────────────

static func _get_equip_slots(grade: String) -> PackedStringArray:
	var slots: Array = EQUIPPABLE_SLOTS.get(grade, [])
	return PackedStringArray(slots)

static func _make_item_action(action_id: String, label: String, enabled: bool,
		disabled_reason: String, command_name: String, command_args: Dictionary) -> Dictionary:
	return {
		"action_id": action_id, "label": label, "enabled": enabled,
		"disabled_reason": disabled_reason,
		"target_requirements": {
			"allowed_kinds": PackedStringArray(["none"]),
			"requires_visible_target": false,
			"requires_forced_interaction": false,
			"allows_self_target": false
		},
		"command_name": command_name, "command_args": command_args
	}

static func map_inventory_state(state: WorldState) -> Dictionary:
	var pid: int = state.player_id
	var p: PersonData = state.persons.get(pid) if pid != -1 else null
	var tid: int = p.team_id if p != null else -1
	var t: TeamData = state.teams.get(tid) if tid != -1 else null
	var raw_inv: Array = state.player_state.get("inventory", []) if not state.player_state.is_empty() else []

	var inv_items: Array = []
	for item in raw_inv:
		var grade: String = item.get("grade", "")
		var qty: int = item.get("qty", 1)
		var slots: PackedStringArray = _get_equip_slots(grade)
		var row_actions: Array = []
		for slot in slots:
			row_actions.append(_make_item_action(
				"equip_%s_%s" % [grade, slot],
				"裝備 %s → %s" % [grade, slot],
				true, "",
				"equip_item", {"slot_id": slot, "item_grade": grade}
			))
		row_actions.append(_make_item_action(
			"deposit_%s" % grade, "存入隊伍",
			t != null, "" if t != null else "無受控隊伍",
			"deposit_item", {"item_grade": grade, "qty": qty}
		))
		inv_items.append({"row_id": grade, "grade": grade, "qty": qty, "equip_slots": slots, "available_actions": row_actions})

	var take_items: Array = []
	if t != null:
		for res_key in t.resources:
			var qty: int = int(t.resources[res_key])
			if qty > 0:
				take_items.append({
					"row_id": res_key, "grade": res_key, "qty": qty,
					"available_actions": [
						_make_item_action("take_%s" % res_key, "取出 %s" % res_key, true, "",
							"take_team_item", {"item_grade": res_key, "qty": 1})
					]
				})

	var equipped: Dictionary = {"head": "", "torso": "", "hand_1": "", "hand_2": ""}
	if p != null:
		for slot in ["head", "torso", "hand_1", "hand_2"]:
			equipped[slot] = p.equipment.get(slot, {}).get("grade", "")

	var unequip_actions: Array = []
	for slot in ["head", "torso", "hand_1", "hand_2"]:
		if equipped[slot] != "":
			unequip_actions.append(_make_item_action(
				"unequip_%s" % slot,
				"卸下 %s (%s)" % [slot, equipped[slot]],
				true, "",
				"unequip_item", {"slot_id": slot}
			))

	return {
		"inventory_items": inv_items,
		"team_takeable_items": take_items,
		"equipped_items": equipped,
		"available_actions": unequip_actions
	}

# ── Available action builder ───────────────────────────────────────────────────

static func map_available_action(action_id: String, label: String, enabled: bool,
		disabled_reason: String, target_requirements: Dictionary,
		command_name: String, command_args: Dictionary) -> Dictionary:
	return {
		"action_id": action_id, "label": label, "enabled": enabled,
		"disabled_reason": disabled_reason,
		"target_requirements": target_requirements,
		"command_name": command_name, "command_args": command_args
	}

# ── Private helpers ───────────────────────────────────────────────────────────

static func _hp_status(p: PersonData) -> String:
	if p == null: return ""
	var has_severe := false
	var has_wound  := false
	for part in p.body_parts.values():
		var s: String = part.get("status", "healthy")
		if s == "severed" or s == "critical": has_severe = true
		elif s == "wounded": has_wound = true
	if has_severe: return "重傷"
	if has_wound:  return "輕傷"
	return "正常"

# ── Snapshot meta ──────────────────────────────────────────────────────────────

static func map_snapshot_meta(focus_valid: bool, cursor_valid: bool) -> Dictionary:
	return {"focus_valid": focus_valid, "cursor_valid": cursor_valid}

# ── Full player snapshot ───────────────────────────────────────────────────────

static func map_members_detail(state: WorldState) -> Array:
	var pid: int = state.player_id
	var p: PersonData = state.persons.get(pid) if pid != -1 else null
	var tid: int = p.team_id if p != null else -1
	var t: TeamData = state.teams.get(tid) if tid != -1 else null
	if t == null:
		return []
	var member_ids: Array = []
	if t.leader_id != -1:
		member_ids.append(t.leader_id)
	for mid in t.named_members:
		if mid != -1 and not member_ids.has(mid):
			member_ids.append(mid)
	var result: Array = []
	for mid in member_ids:
		var m: PersonData = state.persons.get(mid)
		if m == null:
			continue
		var hp_current: float = 0.0
		var hp_max_total: float = 0.0
		for part_data in m.body_parts.values():
			hp_current += float(part_data.get("hp", 0.0))
			hp_max_total += float(part_data.get("max_hp", 0.0))
		var inventory: Array = []
		if mid == pid:
			inventory = state.player_state.get("inventory", []).duplicate()
		result.append({
			"id":         mid,
			"name":       m.person_name,
			"role":       "leader" if mid == t.leader_id else "member",
			"stress":     m.stress,
			"fear":       m.fear,
			"loyalty":    m.loyalty,
			"hp_current": hp_current,
			"hp_max":     hp_max_total,
			"attributes": m.attributes.duplicate(),
			"values":     m.values.duplicate(),
			"skills":     m.skills.duplicate(),
			"body_parts": m.body_parts.duplicate(true),
			"equipped":   m.equipment.duplicate(true),
			"inventory":  inventory,
		})
	return result

static func map_team_stats(state: WorldState) -> Dictionary:
	var pid: int = state.player_id
	var p: PersonData = state.persons.get(pid) if pid != -1 else null
	var tid: int = p.team_id if p != null else -1
	var t: TeamData = state.teams.get(tid) if tid != -1 else null
	if t == null:
		return {}
	var ms := MovementSystem.new()
	return {
		"food_qty":       int(t.resources.get("food", 0.0)),
		"carry_weight":   ms.calc_total_weight(t),
		"carry_capacity": ms.get_carry_capacity(t),
		"member_count":   (1 if t.leader_id != -1 else 0) + t.named_members.size(),
	}

static func map_player_snapshot(state: WorldState, focus_team_id: int, focus_member_id: int,
		cursor_q: int, cursor_r: int, actions: Array) -> Dictionary:
	var focus_valid: bool = focus_team_id != -1 and focus_member_id != -1 \
		and state.teams.has(focus_team_id) and state.persons.has(focus_member_id)
	var cursor_valid: bool = cursor_q != -1 and cursor_r != -1 \
		and state.world.tiles.has(cursor_q * 1000 + cursor_r)
	return {
		"player_summary":     map_player_summary(state),
		"controlled_team":    map_controlled_team(state),
		"visible_teams":      map_visible_teams(state),
		"focused_member":     map_focused_member(state, focus_team_id, focus_member_id),
		"pending_targets":    map_pending_targets(state),
		"forced_interaction": map_forced_interaction(state),
		"location_context":   map_location_context(state, cursor_q, cursor_r),
		"available_actions":  actions,
		"inventory_state":    map_inventory_state(state),
		"snapshot_meta":      map_snapshot_meta(focus_valid, cursor_valid),
		"members_detail":     map_members_detail(state),
		"team_stats":         map_team_stats(state),
	}

# ── Faction panel ──────────────────────────────────────────────────────────────

static func map_faction_panel(state: WorldState) -> Dictionary:
	var pid: int = state.player_id
	if pid == -1:
		return {"in_faction": false, "faction_id": -1, "is_leader": false,
			"faction_goal": "", "player_goal_override": "", "tribute_rate": 0.0,
			"member_orders": [], "actions": []}
	var p: PersonData = state.persons.get(pid)
	if p == null:
		return {"in_faction": false, "faction_id": -1, "is_leader": false,
			"faction_goal": "", "player_goal_override": "", "tribute_rate": 0.0,
			"member_orders": [], "actions": []}
	var pt: TeamData = state.teams.get(p.team_id)
	if pt == null or pt.faction_id == -1:
		return {"in_faction": false, "faction_id": -1, "is_leader": false,
			"faction_goal": "", "player_goal_override": "", "tribute_rate": 0.0,
			"member_orders": [], "actions": []}
	var f = state.factions.get(pt.faction_id)
	if f == null:
		return {"in_faction": false, "faction_id": -1, "is_leader": false,
			"faction_goal": "", "player_goal_override": "", "tribute_rate": 0.0,
			"member_orders": [], "actions": []}
	var is_leader: bool = f.leader_team_id == pt.team_id
	var pending_orders: Dictionary = {}  # Plan 3 Task 1 will add player_pending_orders to WorldState; change to state.player_pending_orders then
	var member_orders: Array = []
	for mid in f.member_team_ids:
		var mt: TeamData = state.teams.get(mid)
		if mt == null: continue
		var ml: PersonData = state.persons.get(mt.leader_id)
		var name_str: String = ml.person_name if ml else "Team%d" % mid
		var pending: Dictionary = pending_orders.get(mid, {})
		member_orders.append({
			"team_id": mid,
			"name": name_str,
			"tile_pos": mt.tile_pos,
			"commanded_task": mt.player_commanded_task,
			"pending_task": pending.get("task", ""),
			"herald_id": pending.get("herald_id", -1),
		})
	var actions: Array = ["order_faction_member", "clear_member_order"]
	if is_leader:
		actions.append_array(["set_faction_goal", "set_tribute_rate",
			"leave_faction", "betray_faction", "disband_faction"])
	else:
		actions.append("leave_faction")
	return {
		"in_faction": true,
		"faction_id": pt.faction_id,
		"is_leader": is_leader,
		"faction_goal": ", ".join(f.goals) if f.goals.size() > 0 else "",
		"player_goal_override": f.player_goal_override,
		"tribute_rate": f.tribute_rate,
		"member_orders": member_orders,
		"actions": actions,
	}

# ── Outpost panel ──────────────────────────────────────────────────────────────

static func map_outpost_panel(state: WorldState) -> Dictionary:
	var pid: int = state.player_id
	if pid == -1:
		return {"tile_pos": Vector2i(-1, -1), "outpost_type": "", "outpost_level": 0,
			"outpost_owner": -1, "has_control": false,
			"construction_in_progress": false, "ticks_left": 0, "actions": []}
	var p: PersonData = state.persons.get(pid)
	if p == null:
		return {"tile_pos": Vector2i(-1, -1), "outpost_type": "", "outpost_level": 0,
			"outpost_owner": -1, "has_control": false,
			"construction_in_progress": false, "ticks_left": 0, "actions": []}
	var pt: TeamData = state.teams.get(p.team_id)
	if pt == null:
		return {"tile_pos": Vector2i(-1, -1), "outpost_type": "", "outpost_level": 0,
			"outpost_owner": -1, "has_control": false,
			"construction_in_progress": false, "ticks_left": 0, "actions": []}
	var key: int = pt.tile_pos.x * 1000 + pt.tile_pos.y
	var tile = state.world.tiles.get(key)
	if tile == null:
		return {"tile_pos": pt.tile_pos, "outpost_type": "", "outpost_level": 0,
			"outpost_owner": -1, "has_control": false,
			"construction_in_progress": false, "ticks_left": 0, "actions": []}
	var has_ctrl: bool = tile.outpost_owner == -1 or tile.outpost_owner == pt.team_id
	var in_progress: bool = tile.construction_team_id != -1
	var actions: Array = []
	if has_ctrl:
		if tile.outpost_type == "" and not in_progress:
			actions.append("build_outpost")
		elif tile.outpost_type != "" and not in_progress:
			actions.append_array(["upgrade_outpost", "upgrade_farming",
				"upgrade_manufacturing", "demolish_outpost"])
	return {
		"tile_pos": pt.tile_pos,
		"outpost_type": tile.outpost_type,
		"outpost_level": tile.outpost_level,
		"outpost_owner": tile.outpost_owner,
		"has_control": has_ctrl,
		"construction_in_progress": in_progress,
		"ticks_left": tile.construction_ticks_left,
		"actions": actions,
	}

# ── Subteam panel ──────────────────────────────────────────────────────────────

static func map_subteam_panel(state: WorldState) -> Dictionary:
	var pid: int = state.player_id
	if pid == -1:
		return {"subteams": [], "actions_per_subteam": {}}
	var p: PersonData = state.persons.get(pid)
	if p == null:
		return {"subteams": [], "actions_per_subteam": {}}
	var ptid: int = p.team_id
	var subteams: Array = []
	var actions_per: Dictionary = {}
	for tid in state.teams:
		var t: TeamData = state.teams[tid]
		if t.parent_team_id != ptid: continue
		subteams.append({
			"team_id": tid,
			"tile_pos": t.tile_pos,
			"current_task": t.current_task,
			"order_task": t.order_task,
			"population": t.population,
			"player_commanded_task": t.player_commanded_task,
		})
		actions_per[str(tid)] = ["order_subteam", "recall_subteam"]
	return {"subteams": subteams, "actions_per_subteam": actions_per}
