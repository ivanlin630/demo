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
	"stable":        { "material": 30, "coin": 50, "ticks": 7200 },
}

# 馬廄各等級每日產出 mounts / 消耗 food（index = level-1）
const STABLE_PRODUCE_PER_DAY: Array = [0.3, 0.7, 1.0]
const STABLE_FOOD_PER_DAY: Array    = [5.0, 10.0, 15.0]
const STABLE_CAP: Dictionary = {
	"civilian": [1, 2, 3],
	"military":  [0, 0, 0],
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
	"mint": {
		"cost":              { "material": 100, "coin": 50, "ticks": 200 },
		"cap_by_outpost":    { "civilian": [0, 1, 2], "military": [0, 0, 0] },
		"category":          "經濟",
		"trigger_check":     "_check_ore_surplus",
		"leader_pref":       { "貪婪": 0.4, "野心": 0.2 },
		"current_level_key": "mint_level",
	},
	"stable": {
		"cost":              { "material": 30, "coin": 50, "ticks": 7200 },
		"cap_by_outpost":    { "civilian": [1, 2, 3], "military": [0, 0, 0] },
		"category":          "軍事",
		"trigger_check":     "_check_mount_demand",
		"leader_pref":       { "野心": 0.2, "好戰": 0.3 },
		"current_level_key": "stable_level",
		"required_terrain":  "plains",
	},
}

const MINT_BASE_RATE: float = 10.0
const GOLD_TO_COIN_RATIO: float = 20.0
const SILVER_TO_COIN_RATIO: float = 5.0

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

# 公庫容量（index = level-1）
const OUTPOST_STORAGE_CAP: Dictionary = {
	"civilian": [200.0, 500.0, 1500.0],
	"military": [300.0, 800.0, 2500.0],
}

# mount 公庫專屬容量（index = level-1）
const MOUNT_STORAGE_CAP: Array = [10.0, 30.0, 80.0]

func _get_storage_cap(tile: HexTileData, res: String) -> float:
	if res == "mounts":
		return MOUNT_STORAGE_CAP[clampi(tile.outpost_level - 1, 0, 2)]
	var arr: Array = OUTPOST_STORAGE_CAP.get(tile.outpost_type, [100.0, 300.0, 800.0])
	return float(arr[clampi(tile.outpost_level - 1, 0, 2)])

# ──────── Tick 驅動 ────────

func tick_all(state: WorldState) -> void:
	# outpost tick 在近區每小時跑一次 → day_fraction = 1 小時/天
	var day_fraction: float = float(WorldState.TICKS_PER_HOUR) / float(WorldState.TICKS_PER_DAY)
	for tile_id in state.world.tiles:
		var tile: HexTileData = state.world.tiles[tile_id]
		if tile.mint_level > 0:
			_tick_mint(state, tile, state.teams.get(tile.outpost_owner))
		if tile.stable_level > 0:
			produce_stable_day(state, tile, day_fraction)
		if tile.construction_team_id == -1:
			continue
		_tick_construction(state, tile)

# 馬廄：消耗 owner team food → 累積 mounts；day_fraction = 本次 tick 佔一天的比例。
# 測試可直接以 day_fraction=1.0 模擬整天。
func produce_stable_day(state: WorldState, tile: HexTileData, day_fraction: float) -> void:
	if tile.stable_level <= 0: return
	var owner: TeamData = state.teams.get(tile.outpost_owner)
	if owner == null: return
	var lvl_idx: int = clampi(tile.stable_level - 1, 0, 2)
	var food_cost: float = STABLE_FOOD_PER_DAY[lvl_idx] * day_fraction
	if float(owner.resources.get("food", 0)) < food_cost:
		return   # 草料不足，本次不產
	owner.resources["food"] = float(owner.resources.get("food", 0)) - food_cost
	tile.stable_progress += STABLE_PRODUCE_PER_DAY[lvl_idx] * day_fraction
	# epsilon 吸收浮點累加誤差（30×0.3 = 8.999… → 9）
	if tile.stable_progress >= 1.0 - 1e-9:
		var produced: int = int(tile.stable_progress + 1e-9)
		tile.stable_progress -= float(produced)
		# 改進公庫（受 cap 限制）而非 owner team
		var cap: float = _get_storage_cap(tile, "mounts")
		var stored: float = float(tile.public_storage.get("mounts", 0))
		var space: float = maxf(cap - stored, 0.0)
		var actual: float = minf(float(produced), space)
		tile.public_storage["mounts"] = stored + actual

func _tick_mint(_state: WorldState, tile: HexTileData, _team: TeamData) -> void:
	if tile.mint_level == 0: return
	var rate: float = float(tile.mint_level) * MINT_BASE_RATE
	var gold_qty: float = float(tile.public_storage.get("ore_gold", 0))
	if gold_qty > 0.0:
		var convert: float = minf(gold_qty, rate / GOLD_TO_COIN_RATIO)
		tile.public_storage["ore_gold"] = gold_qty - convert
		var coin_added: float = convert * GOLD_TO_COIN_RATIO
		var cap: float = _get_storage_cap(tile, "coin")
		var cur_coin: float = float(tile.public_storage.get("coin", 0))
		tile.public_storage["coin"] = minf(cur_coin + coin_added, cap)
		return
	var silver_qty: float = float(tile.public_storage.get("ore_silver", 0))
	if silver_qty > 0.0:
		var convert: float = minf(silver_qty, rate / SILVER_TO_COIN_RATIO)
		tile.public_storage["ore_silver"] = silver_qty - convert
		var coin_added: float = convert * SILVER_TO_COIN_RATIO
		var cap: float = _get_storage_cap(tile, "coin")
		var cur_coin: float = float(tile.public_storage.get("coin", 0))
		tile.public_storage["coin"] = minf(cur_coin + coin_added, cap)

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
			# C: NPC 建造子隊完工 → 就地安頓（脫離母團、加駐留 tag），outpost 持續存在
			if team.parent_team_id != -1:
				_auto_settle_builder(state, team, tile)
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
		"upgrade_stable":
			tile.stable_level = mini(tile.stable_level + 1, 3)
			print("[Outpost] 馬廄升級 Lv%d at (%d,%d)" % [tile.stable_level, tile.tile_pos.x, tile.tile_pos.y])
		"demolish":
			print("[Outpost] Team%d 拆除 %s at (%d,%d)" % [
				team.team_id, get_outpost_name(tile.outpost_type, tile.outpost_level),
				tile.tile_pos.x, tile.tile_pos.y])
			tile.outpost_type  = ""
			tile.outpost_level = 0
			tile.outpost_owner = -1
			tile.farming_level = 0
			tile.manufacturing_level = 0
			tile.stable_level = 0
			tile.stable_progress = 0.0
			tile.garrison.clear()
			tile.prisoners.clear()
	tile.construction_ticks_left = 0
	tile.construction_team_id   = -1
	tile.construction_target     = {}
	TaskArbiter.release(team)

# C: 建造子隊完工後就地安頓為駐留 team（owner 已設為自己，加 tag、脫離母團）
func _auto_settle_builder(state: WorldState, team: TeamData, tile: HexTileData) -> void:
	var parent: TeamData = state.teams.get(team.parent_team_id)
	if parent != null:
		parent.subteam_ids.erase(team.team_id)
	team.parent_team_id = -1
	team.tags.erase(TeamData.TAG_SUBTEAM)
	if tile.outpost_type == "civilian":
		if not team.tags.has(TeamData.TAG_PRODUCE):
			team.tags.append(TeamData.TAG_PRODUCE)
	else:
		if not team.tags.has(TeamData.TAG_MILITARY):
			team.tags.append(TeamData.TAG_MILITARY)
	print("[Outpost] Team%d 完工後就地安頓 (%d,%d)（%s）" % [
		team.team_id, tile.tile_pos.x, tile.tile_pos.y, tile.outpost_type])

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
	TaskArbiter.transition(team, "建設", TaskArbiter.PRIO_DISPATCH)
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
	TaskArbiter.transition(team, "建設", TaskArbiter.PRIO_DISPATCH)
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
	TaskArbiter.transition(team, "建設", TaskArbiter.PRIO_DISPATCH)
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
	TaskArbiter.transition(team, "建設", TaskArbiter.PRIO_DISPATCH)
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
	TaskArbiter.transition(team, "建設", TaskArbiter.PRIO_DISPATCH)
	print("[Outpost] Team%d 拆除 at (%d,%d)" % [team.team_id, tile.tile_pos.x, tile.tile_pos.y])
	return true

# ──────── 子隊抵達後啟動施工（NPC 基建）────────

# 子隊抵達 outpost tile 後依 current_task 啟動施工。
# 建造：start_build（子隊自身成為 owner，完工後由 faction_ai 安頓）。
# 升級/擴建：faction 擁有權檢查（owner 同 faction）→ 就地推進 construction。
func begin_subteam_construction(state: WorldState, team: TeamData) -> bool:
	var tile := _get_team_tile(state, team)
	if tile == null:
		return false
	var extra: Dictionary = team.task_extra_data
	match team.current_task:
		"建造":
			var btype: String = str(extra.get("build_type", "civilian"))
			var lvl: int = int(extra.get("level", 1))
			return start_build(state, team, btype, lvl)
		"升級":
			var tgt_lvl: int = int(extra.get("target_level", tile.outpost_level + 1))
			return _subteam_upgrade_level(state, team, tile, tgt_lvl)
		"擴建":
			var fac: String = str(extra.get("facility_type", "farming"))
			return _subteam_upgrade_facility(state, team, tile, fac)
	return false

func _faction_owns(state: WorldState, team: TeamData, tile: HexTileData) -> bool:
	if tile.outpost_owner == team.team_id:
		return true
	if tile.outpost_owner == team.parent_team_id and team.parent_team_id != -1:
		return true
	var owner: TeamData = state.teams.get(tile.outpost_owner)
	if owner == null:
		return false
	return owner.faction_id == team.faction_id and team.faction_id != -1

func _subteam_upgrade_level(state: WorldState, team: TeamData, tile: HexTileData, target_level: int) -> bool:
	if tile.outpost_level == 0 or target_level <= tile.outpost_level or target_level > 3:
		return false
	if not _faction_owns(state, team, tile) or tile.construction_team_id != -1:
		return false
	var cost: Dictionary = BUILD_COST[tile.outpost_type][target_level - 1]
	if not _can_afford(team, cost):
		return false
	_deduct_cost(team, cost)
	tile.construction_team_id   = team.team_id
	tile.construction_ticks_left = BUILD_TICKS[tile.outpost_type][target_level - 1]
	tile.construction_target    = { "action": "upgrade_level", "level": target_level }
	TaskArbiter.transition(team, TeamData.TASK_BUILD, TaskArbiter.PRIO_DISPATCH)
	print("[Outpost] 子隊 Team%d 開始升級 → Lv%d at (%d,%d)" % [
		team.team_id, target_level, tile.tile_pos.x, tile.tile_pos.y])
	return true

func _subteam_upgrade_facility(state: WorldState, team: TeamData, tile: HexTileData, facility: String) -> bool:
	if tile.outpost_type != "civilian" or tile.outpost_level == 0:
		return false
	if not _faction_owns(state, team, tile) or tile.construction_team_id != -1:
		return false
	var action: String = ""
	var cur: int = 0
	var cap: int = 0
	match facility:
		"farming":
			cap = FARMING_CAP[tile.outpost_type][tile.outpost_level - 1]
			cur = tile.farming_level
			action = "upgrade_farming"
		"manufacturing":
			cap = MANUFACTURING_CAP[tile.outpost_type][tile.outpost_level - 1]
			cur = tile.manufacturing_level
			action = "upgrade_manufacturing"
		"stable":
			if tile.terrain != "plains":
				return false   # 馬廄限平原
			cap = STABLE_CAP[tile.outpost_type][tile.outpost_level - 1]
			cur = tile.stable_level
			action = "upgrade_stable"
		_:
			return false
	if cur >= cap:
		return false
	var cost: Dictionary = UPGRADE_COST[facility]
	if not _can_afford(team, cost):
		return false
	_deduct_cost(team, cost)
	tile.construction_team_id   = team.team_id
	tile.construction_ticks_left = cost["ticks"]
	tile.construction_target    = { "action": action }
	TaskArbiter.transition(team, TeamData.TASK_BUILD, TaskArbiter.PRIO_DISPATCH)
	print("[Outpost] 子隊 Team%d 開始擴建 %s at (%d,%d)" % [
		team.team_id, facility, tile.tile_pos.x, tile.tile_pos.y])
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
	TaskArbiter.transition(team, TeamData.TASK_BUILD, TaskArbiter.PRIO_DISPATCH)
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
