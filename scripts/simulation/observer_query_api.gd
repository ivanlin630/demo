class_name ObserverQueryApi

# 觀測 god-view read-only DTO 層（pattern 沿 PlayerQueryApi，不碰玩家耦合欄）。
# 全 static、對 WorldState 零寫入。觀測=無迷霧（spec 裁），不經 belief。

static func team_label(state: WorldState, tid: int) -> String:
	var t: TeamData = state.teams.get(tid)
	if t == null:
		return "隊%d(已滅)" % tid
	if t.beast_kind != "":
		return "%s(獸)" % t.beast_kind
	var leader: PersonData = state.persons.get(t.leader_id)
	if leader != null and leader.person_name != "":
		return "%s隊(%d)" % [leader.person_name, tid]
	return "隊%d" % tid

static func faction_label(state: WorldState, fid: int) -> String:
	if fid == -1:
		return ""
	var f: FactionData = state.factions.get(fid)
	if f == null:
		return "勢力%d" % fid
	return f.faction_name if f.faction_name != "" else "勢力%d" % fid

static func query_all_teams(state: WorldState) -> Array:
	var out: Array = []
	var ids: Array = state.teams.keys()
	ids.sort()
	for tid in ids:
		var t: TeamData = state.teams[tid]
		out.append({
			"id": tid, "label": team_label(state, tid),
			"pop": t.population, "rung": t.ambition_rung,
			"archetype": t.ambition_archetype, "task": t.current_task,
			"faction_id": t.faction_id, "tile_pos": t.tile_pos,
			"is_beast": t.beast_kind != "",
		})
	return out

static func query_team(state: WorldState, tid: int) -> Dictionary:
	var t: TeamData = state.teams.get(tid)
	if t == null:
		return {}
	var leader: PersonData = state.persons.get(t.leader_id)
	return {
		"id": tid,
		"label": team_label(state, tid),
		"leader_name": leader.person_name if leader != null else "(無)",
		"pop": t.population,
		"pop_named": t.named_members.size() + (1 if t.leader_id != -1 else 0),
		"pop_anon": AnonTierSystem.total_pop(t),
		"pop_minor": t.minor_population,
		"pop_captive": AnonTierSystem.total_captives(t),
		"food": float(t.resources.get("food", 0.0)),
		"food_flow": t.food_flow_avg,
		"coin": int(t.resources.get("coin", 0)),
		"rung": t.ambition_rung, "rung_cap": t.ambition_cap,
		"archetype": t.ambition_archetype,
		"faction_id": t.faction_id,
		"faction": faction_label(state, t.faction_id),
		"task": t.current_task,
		"task_reason": t.task_reason,
		"solo_intent": String(t.solo_intent.get("type", "")) if t.solo_intent is Dictionary else "",
		"readiness": t.readiness,
		"fatigue": t.fatigue,
		"wounded": t.wounded,
		"tile_pos": t.tile_pos,
		"tags": t.tags.duplicate(),
		"is_beast": t.beast_kind != "",
	}

# 地圖渲染 DTO：全隊真位（god-view）
static func query_map_teams(state: WorldState) -> Array:
	var out: Array = []
	var ids: Array = state.teams.keys()
	ids.sort()
	for tid in ids:
		var t: TeamData = state.teams[tid]
		out.append({"id": tid, "tile_pos": t.tile_pos, "faction_id": t.faction_id,
			"archetype": t.ambition_archetype, "is_beast": t.beast_kind != "",
			"pop": t.population})
	return out

# shape 對齊 sim_bridge.query_world_tiles（world_map_view 吃同型）
static func query_map_tiles(state: WorldState) -> Dictionary:
	var result: Dictionary = {}
	for key in state.world.tiles:
		var tile: HexTileData = state.world.tiles[key]
		result[key] = {
			"tile_pos":       tile.tile_pos,
			"terrain":        tile.terrain,
			"harvest_factor": tile.harvest_factor,
			"outpost_type":   tile.outpost_type,
			"outpost_level":  tile.outpost_level,
			"outpost_owner":  tile.outpost_owner,
		}
	return result
