class_name OutpostSystem

const OUTPOST_NAMES: Dictionary = {
	"civilian": ["村落", "城鎮", "都市"],
	"military": ["營寨", "城堡", "堡壘"],
}

# 建造費（index = level-1）
const BUILD_COST: Dictionary = {
	"civilian": [
		{ "material": 50,  "coin": 10, "weapon": 0  },
		{ "material": 150, "coin": 30, "weapon": 0  },
		{ "material": 400, "coin": 80, "weapon": 0  },
	],
	"military": [
		{ "material": 80,  "coin": 10, "weapon": 10 },
		{ "material": 200, "coin": 20, "weapon": 30 },
		{ "material": 500, "coin": 40, "weapon": 80 },
	],
}

# 建造所需 person-ticks（除以 team.population = 實際 ticks）
const BUILD_TICKS: Dictionary = {
	"civilian": [100, 300, 600],
	"military": [100, 300, 600],
}

const UPGRADE_COST: Dictionary = {
	"farming":       { "material": 30, "coin": 0,  "ticks": 50  },
	"manufacturing": { "material": 60, "coin": 20, "ticks": 100 },
}

# 設施註冊表（data-driven）：NPC AI 評估擴建時讀取。
# cost 與 UPGRADE_COST 一致；cap_by_outpost 與 FARMING_CAP/MANUFACTURING_CAP 一致。
const FACILITY_DEF: Dictionary = {
	"farming": {
		"cost":              { "material": 30, "coin": 0, "ticks": 50 },
		"cap_by_outpost":    { "civilian": [1, 2, 3], "military": [0, 0, 0] },
		"category":          "生產",
		"trigger_check":     "_check_food_shortage",
		"leader_pref":       { "慎重": 0.3, "野心": -0.1 },
		"current_level_key": "farming_level",
	},
	"manufacturing": {
		"cost":              { "material": 60, "coin": 20, "ticks": 100 },
		"cap_by_outpost":    { "civilian": [0, 1, 3], "military": [0, 0, 0] },
		"category":          "經濟",
		"trigger_check":     "_check_goods_shortage",
		"leader_pref":       { "野心": 0.2, "貪婪": 0.3 },
		"current_level_key": "manufacturing_level",
	},
}

# 農作/製造設施上限（index = level-1）；軍用不允許
const FARMING_CAP: Dictionary = {
	"civilian": [1, 2, 3],
	"military": [0, 0, 0],
}

const MANUFACTURING_CAP: Dictionary = {
	"civilian": [0, 1, 3],
	"military": [0, 0, 0],
}

const GARRISON_CAP: Dictionary = {
	"civilian": [5,  15,  30 ],
	"military": [20, 60,  150],
}

const PRISONER_CAP: Dictionary = {
	"civilian": [2,  5,   10 ],
	"military": [10, 30,  80 ],
}

const MIN_DIST_ANY:  int = 2    # 任意兩據點最小 hex 距離
const MIN_DIST_SAME: int = 11   # 同類型最小 hex 距離

# ──────── Tick 驅動 ────────

func tick_all(state: WorldState) -> void:
	for tile_id in state.world.tiles:
		var tile: HexTileData = state.world.tiles[tile_id]
		if tile.construction_team_id == -1:
			continue
		_tick_construction(state, tile)

func _tick_construction(state: WorldState, tile: HexTileData) -> void:
	# 找同格上所有 current_task == "建設" 的 team（接手機制）
	var active_team: TeamData = null
	for tid in state.teams:
		var t: TeamData = state.teams[tid]
		if t.tile_pos == tile.tile_pos and t.current_task == TeamData.TASK_BUILD:
			active_team = t
			break
	if active_team == null:
		return  # 無施工隊在格，暫停
	# 更新施工 team（接手：任何在格上建設的 team 都可繼續）
	tile.construction_team_id = active_team.team_id
	tile.construction_ticks_left -= maxi(active_team.population, 1)
	if tile.construction_ticks_left <= 0:
		_complete_construction(state, tile, active_team)

func _complete_construction(state: WorldState, tile: HexTileData, team: TeamData) -> void:
	var action: String = tile.construction_target.get("action", "")
	match action:
		"build":
			tile.outpost_type  = tile.construction_target["type"]
			tile.outpost_level = tile.construction_target["level"]
			tile.outpost_owner = tile.construction_team_id
			var n: String = get_outpost_name(tile.outpost_type, tile.outpost_level)
			SimMessageSystem.new().emit_message(state, "outpost_built",
				TextBank.fmt("outpost_built", "honest", {
					"origin": str(team.team_id), "name": n,
					"x": str(tile.tile_pos.x), "y": str(tile.tile_pos.y)
				}),
				team,
				{ "origin": str(team.team_id), "name": n,
				  "x": str(tile.tile_pos.x), "y": str(tile.tile_pos.y) })
			print("[Outpost] Team%d 建成 %s（Lv%d）at (%d,%d)" % [
				team.team_id, n, tile.outpost_level, tile.tile_pos.x, tile.tile_pos.y])
		"upgrade_level":
			tile.outpost_level = tile.construction_target["level"]
			print("[Outpost] Team%d 升級 → %s Lv%d" % [
				team.team_id, tile.outpost_type, tile.outpost_level])
		"upgrade_farming":
			tile.farming_level = mini(tile.farming_level + 1, 3)
			print("[Outpost] 農作升級 Lv%d at (%d,%d)" % [tile.farming_level, tile.tile_pos.x, tile.tile_pos.y])
		"upgrade_manufacturing":
			tile.manufacturing_level = mini(tile.manufacturing_level + 1, 3)
			print("[Outpost] 製造升級 Lv%d at (%d,%d)" % [tile.manufacturing_level, tile.tile_pos.x, tile.tile_pos.y])
		"demolish":
			print("[Outpost] Team%d 拆除 %s at (%d,%d)" % [
				team.team_id, get_outpost_name(tile.outpost_type, tile.outpost_level),
				tile.tile_pos.x, tile.tile_pos.y])
			tile.outpost_type  = ""
			tile.outpost_level = 0
			tile.outpost_owner = -1
			tile.farming_level = 0
			tile.manufacturing_level = 0
			tile.garrison.clear()
			tile.prisoners.clear()
	tile.construction_ticks_left = 0
	tile.construction_team_id   = -1
	tile.construction_target     = {}
	team.current_task = TeamData.TASK_IDLE

# ──────── 公開操作 ────────

func start_build(state: WorldState, team: TeamData, type: String, level: int) -> bool:
	var tile := _get_team_tile(state, team)
	if tile == null:
		return false
	if tile.outpost_level > 0:
		push_warning("[Outpost] start_build: 目標格已有據點")
		return false
	if tile.construction_team_id != -1:
		push_warning("[Outpost] start_build: 目標格建設中")
		return false
	if not _check_distance(state, tile.tile_pos, type):
		push_warning("[Outpost] start_build: 距離限制違規")
		return false
	var cost: Dictionary = BUILD_COST[type][level - 1]
	if not _can_afford(team, cost):
		push_warning("[Outpost] start_build: 資源不足")
		return false
	_deduct_cost(team, cost)
	tile.construction_team_id   = team.team_id
	tile.construction_ticks_left = BUILD_TICKS[type][level - 1]
	tile.construction_target    = { "action": "build", "type": type, "level": level }
	team.current_task = "建設"
	print("[Outpost] Team%d 開始建 %s Lv%d at (%d,%d)（需 %d person-ticks）" % [
		team.team_id, type, level, tile.tile_pos.x, tile.tile_pos.y,
		tile.construction_ticks_left])
	return true

func start_upgrade_level(state: WorldState, team: TeamData) -> bool:
	var tile := _get_team_tile(state, team)
	if tile == null or tile.outpost_level == 0 or tile.outpost_level >= 3:
		return false
	if tile.outpost_owner != team.team_id or tile.construction_team_id != -1:
		return false
	var new_level: int = tile.outpost_level + 1
	var cost: Dictionary = BUILD_COST[tile.outpost_type][new_level - 1]
	if not _can_afford(team, cost):
		return false
	_deduct_cost(team, cost)
	tile.construction_team_id   = team.team_id
	tile.construction_ticks_left = BUILD_TICKS[tile.outpost_type][new_level - 1]
	tile.construction_target    = { "action": "upgrade_level", "level": new_level }
	team.current_task = "建設"
	print("[Outpost] Team%d 升級 → Lv%d at (%d,%d)" % [
		team.team_id, new_level, tile.tile_pos.x, tile.tile_pos.y])
	return true

func start_upgrade_farming(state: WorldState, team: TeamData) -> bool:
	var tile := _get_team_tile(state, team)
	if tile == null or tile.outpost_type != "civilian" or tile.outpost_level == 0:
		return false
	var farming_max: int = FARMING_CAP[tile.outpost_type][tile.outpost_level - 1]
	if tile.outpost_owner != team.team_id or tile.farming_level >= farming_max:
		return false
	if tile.construction_team_id != -1:
		return false
	var cost: Dictionary = UPGRADE_COST["farming"]
	if not _can_afford(team, cost):
		return false
	_deduct_cost(team, cost)
	tile.construction_team_id   = team.team_id
	tile.construction_ticks_left = cost["ticks"]
	tile.construction_target    = { "action": "upgrade_farming" }
	team.current_task = "建設"
	print("[Outpost] Team%d 農作升級 at (%d,%d)" % [team.team_id, tile.tile_pos.x, tile.tile_pos.y])
	return true

func start_upgrade_manufacturing(state: WorldState, team: TeamData) -> bool:
	var tile := _get_team_tile(state, team)
	if tile == null or tile.outpost_type != "civilian" or tile.outpost_level == 0:
		return false
	var mfg_max: int = MANUFACTURING_CAP[tile.outpost_type][tile.outpost_level - 1]
	if tile.outpost_owner != team.team_id or tile.manufacturing_level >= mfg_max:
		return false
	if tile.construction_team_id != -1:
		return false
	var cost: Dictionary = UPGRADE_COST["manufacturing"]
	if not _can_afford(team, cost):
		return false
	_deduct_cost(team, cost)
	tile.construction_team_id   = team.team_id
	tile.construction_ticks_left = cost["ticks"]
	tile.construction_target    = { "action": "upgrade_manufacturing" }
	team.current_task = "建設"
	print("[Outpost] Team%d 製造升級 at (%d,%d)" % [team.team_id, tile.tile_pos.x, tile.tile_pos.y])
	return true

func start_demolish(state: WorldState, team: TeamData) -> bool:
	var tile := _get_team_tile(state, team)
	if tile == null or tile.outpost_level == 0:
		return false
	if tile.outpost_owner != team.team_id or tile.construction_team_id != -1:
		return false
	tile.construction_team_id   = team.team_id
	tile.construction_ticks_left = BUILD_TICKS[tile.outpost_type][tile.outpost_level - 1] / 2
	tile.construction_target    = { "action": "demolish" }
	team.current_task = "建設"
	print("[Outpost] Team%d 拆除 at (%d,%d)" % [team.team_id, tile.tile_pos.x, tile.tile_pos.y])
	return true

func _has_control(state: WorldState, team_id: int, tile: HexTileData) -> bool:
	if tile.outpost_owner == team_id: return true
	var team: TeamData = state.teams.get(team_id)
	if team == null: return false
	var owner: TeamData = state.teams.get(tile.outpost_owner)
	if owner == null: return true
	if team.faction_id != -1 and team.faction_id == owner.faction_id: return true
	var owner_faction_present: bool = false
	for tid in state.teams:
		var t: TeamData = state.teams[tid]
		if t.tile_pos == tile.tile_pos and t.faction_id == owner.faction_id:
			owner_faction_present = true
			break
	return not owner_faction_present

func demolish_with_control(state: WorldState, team: TeamData) -> bool:
	var tile := _get_team_tile(state, team)
	if tile == null or tile.outpost_level == 0:
		return false
	if tile.construction_team_id != -1:
		return false
	tile.construction_team_id   = team.team_id
	tile.construction_ticks_left = BUILD_TICKS[tile.outpost_type][tile.outpost_level - 1] / 2
	tile.construction_target    = { "action": "demolish" }
	team.current_task = TeamData.TASK_BUILD
	print("[Outpost] Team%d 拆除（control）at (%d,%d)" % [team.team_id, tile.tile_pos.x, tile.tile_pos.y])
	return true

func capture(state: WorldState, winner_id: int, tile: HexTileData) -> void:
	if tile.outpost_level > 0 and tile.outpost_owner != winner_id:
		var old_owner: int = tile.outpost_owner
		tile.outpost_owner = winner_id
		print("[Outpost] Team%d 佔領 %s（原 Team%d）at (%d,%d)" % [
			winner_id, get_outpost_name(tile.outpost_type, tile.outpost_level),
			old_owner, tile.tile_pos.x, tile.tile_pos.y])

func get_outpost_name(type: String, level: int) -> String:
	var names: Array = OUTPOST_NAMES.get(type, [])
	if level >= 1 and level <= names.size():
		return names[level - 1]
	return "未知據點"

# ──────── 輔助 ────────

func _check_distance(state: WorldState, pos: Vector2i, type: String) -> bool:
	for tile_id in state.world.tiles:
		var t: HexTileData = state.world.tiles[tile_id]
		if t.outpost_level == 0:
			continue
		var d: int = _hex_dist(pos, t.tile_pos)
		if d < MIN_DIST_ANY:
			return false
		if t.outpost_type == type and d < MIN_DIST_SAME:
			return false
	return true

func _hex_dist(a: Vector2i, b: Vector2i) -> int:
	var dx := b.x - a.x
	var dy := b.y - a.y
	return (abs(dx) + abs(dx + dy) + abs(dy)) / 2

func _get_team_tile(state: WorldState, team: TeamData) -> HexTileData:
	var tid: int = team.tile_pos.x * 1000 + team.tile_pos.y
	return state.world.tiles.get(tid)

func _can_afford(team: TeamData, cost: Dictionary) -> bool:
	for res in cost:
		if res == "ticks":
			continue
		if float(team.resources.get(res, 0)) < float(cost.get(res, 0)):
			return false
	return true

func _deduct_cost(team: TeamData, cost: Dictionary) -> void:
	for res in cost:
		if res == "ticks":
			continue
		var amount: float = float(cost.get(res, 0))
		if amount > 0.0:
			team.resources[res] = maxf(float(team.resources.get(res, 0)) - amount, 0.0)
