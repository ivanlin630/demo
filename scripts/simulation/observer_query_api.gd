class_name ObserverQueryApi

# 觀測 god-view read-only DTO 層（pattern 沿 PlayerQueryApi，不碰玩家耦合欄）。
# 全 static、對 WorldState 零寫入。觀測=無迷霧（spec 裁），不經 belief。

# 資源 key→中文標籤（god-view 人看得懂；無既有映射 → 此處立，觀測專用）。
const RES_LABEL: Dictionary = {
	"food": "糧食", "material": "材料", "coin": "錢", "goods": "貨物", "gem": "寶石",
	"ore_gold": "金礦", "ore_silver": "銀礦", "ore_iron": "鐵礦", "ore_steel": "鋼",
	"weapon_melee_low": "近戰武器(低)", "weapon_melee_high": "近戰武器(高)",
	"weapon_ranged_low": "遠程武器(低)", "weapon_ranged_high": "遠程武器(高)",
	"mounts": "馬匹", "wagons": "馬車", "arrows": "箭矢", "medicine": "藥品",
	"tools": "工具", "armor_low": "護甲(低)", "armor_high": "護甲(高)",
}

static func res_label(key: String) -> String:
	return RES_LABEL.get(key, key)   # 未知 key 原樣（人看得懂優先，缺映射不炸）

# 設施 key→中文（權威=OutpostSystem.FACILITY_DEF；未來加設施補此映射即可）。
const FACILITY_LABEL: Dictionary = {
	"farming": "農場", "workshop": "工坊", "apothecary": "藥坊", "mint": "鑄幣坊",
	"stable": "馬廄", "smeltery": "冶煉廠", "weaponsmith": "武器坊", "armorsmith": "護甲坊",
}

static func facility_label(key: String) -> String:
	return FACILITY_LABEL.get(key, key)

# tile 非零設施（DRY：以 FACILITY_DEF 為權威 iterate；facility_key→level，>0 才收）。
static func _facilities_nonzero(tile: HexTileData) -> Dictionary:
	var out: Dictionary = {}
	for f in OutpostSystem.FACILITY_DEF:
		var lv: int = int(tile.get(OutpostSystem.FACILITY_DEF[f]["current_level_key"]))
		if lv > 0:
			out[f] = lv
	return out

# 非零資源濾（god-view 全露；空 dict 亦合法）
static func _nonzero_resources(res: Dictionary) -> Dictionary:
	var out: Dictionary = {}
	for k in res:
		if abs(float(res[k])) > 0.0001:
			out[k] = res[k]
	return out

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
		"resources_nonzero": _nonzero_resources(t.resources),
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

# 單據點 inspect（god-view read-only）。非據點格 → {}（panel 印「此格無據點」）。
# tiles 以 tile_id(=x*1000+y) 為 key（全庫慣例，非 Vector2i）→ pos 需轉。
static func query_outpost(state: WorldState, tpos: Vector2i) -> Dictionary:
	var tile: HexTileData = state.world.tiles.get(tpos.x * 1000 + tpos.y)
	if tile == null or tile.outpost_type == "" or tile.outpost_level <= 0:
		return {}
	return {
		"tile_pos": tpos,
		"outpost_type": tile.outpost_type,          # civilian | military
		"outpost_level": tile.outpost_level,
		"owner_team_id": tile.outpost_owner,
		"owner_team": team_label(state, tile.outpost_owner) if tile.outpost_owner != -1 else "（無主）",
		"owner_faction": faction_label(state, _owner_faction_of(state, tile.outpost_owner)),
		"facilities_nonzero": _facilities_nonzero(tile),   # 全 8 設施非零（DRY via FACILITY_DEF）
		"garrison": tile.garrison.size(),
		"resources_nonzero": _nonzero_resources(tile.resources),
		"resource_cap": tile.resource_cap.duplicate(),
	}

# 全據點列表 DTO（god-view；免逐隊翻找）。sort by tile_id 穩定。
static func query_all_outposts(state: WorldState) -> Array:
	var ids: Array = state.world.tiles.keys()
	ids.sort()
	var out: Array = []
	for tid in ids:
		var tile: HexTileData = state.world.tiles[tid]
		if tile.outpost_type == "" or tile.outpost_level <= 0:
			continue
		out.append({
			"tile_pos": tile.tile_pos,
			"outpost_type": tile.outpost_type,
			"outpost_level": tile.outpost_level,
			"owner_team": team_label(state, tile.outpost_owner) if tile.outpost_owner != -1 else "（無主）",
			"owner_faction": faction_label(state, _owner_faction_of(state, tile.outpost_owner)),
			"facility_count": _facilities_nonzero(tile).size(),
		})
	return out

# 雙 null guard：無主(-1) + 已滅 team 兩來源都接（state.teams.get(-1)=null → null.faction_id 必炸）。
static func _owner_faction_of(state: WorldState, owner: int) -> int:
	if owner == -1:
		return -1
	var ot: TeamData = state.teams.get(owner)
	return ot.faction_id if ot != null else -1
