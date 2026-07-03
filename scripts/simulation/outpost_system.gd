class_name OutpostSystem

const OUTPOST_NAMES: Dictionary = {
	"civilian": ["村落", "城鎮", "都市"],
	"military": ["營寨", "城堡", "堡壘"],
}

# 據點本體建造費（index = level-1）。建造守恆：civilian 純 mat / military mat+tools，
# 無 coin/weapon（有限資源永不入建造）。TEST VALUES
const OUTPOST_COST: Dictionary = {
	"civilian": [
		{ "material": 50,  "tools": 0 },
		{ "material": 150, "tools": 0 },
		{ "material": 400, "tools": 0 },
	],
	"military": [
		{ "material": 80,  "tools": 3 },
		{ "material": 200, "tools": 6 },
		{ "material": 500, "tools": 10 },
	],
}

# 建造所需 person-ticks（除以 team.population = 實際 ticks）
const BUILD_TICKS: Dictionary = {
	"civilian": [100, 300, 600],
	"military": [100, 300, 600],
}

# 工地無實際進度逾此時長 → 取消退料（防永久卡死黑洞）
const CONSTRUCTION_TIMEOUT: int = 30 * WorldState.TICKS_PER_DAY

# 馬廄各等級每日產出 mounts / 消耗 food（index = level-1）
const STABLE_PRODUCE_PER_DAY: Array = [0.3, 0.7, 1.0]
const STABLE_FOOD_PER_DAY: Array    = [5.0, 10.0, 15.0]
# 產馬帶育馬：resource_cap["mounts"]>0 的良質牧地上，stable 直接繁育戰馬（不需捕獲 horses）。
# 比訓練快（專業牧地），仍耗草料（守恆錨；mounts=非守恆採集產出,同 ore/food farm 語意）。TEST VALUE。
const STABLE_BREED_PER_DAY: Array   = [0.5, 1.1, 2.2]

# slot 制：每設施類型佔 1 slot（level 深度不佔額外）；index = outpost_level-1。TEST VALUES
const FACILITY_SLOTS: Dictionary = {
	"civilian": [2, 3, 5],
	"military": [1, 2, 3],
}

# 設施註冊表 v2（data-driven）：NPC AI 需求迴路讀取。
# 三級建造成本：低級純 mat / 中級 mat+tools。建造守恆：無 coin、無有限資源。TEST VALUES
# ticks = person-ticks（pop=1 時 ×10 = world ticks：farming 72 ≈ 3 天）
const FACILITY_DEF: Dictionary = {
	"farming": {
		"cost": { "material": 30, "tools": 0, "ticks": 72 },
		"allowed_outpost": ["civilian"],
		"current_level_key": "farming_level",
		"leader_pref": { "慎重": 0.3 },
	},
	"workshop": {
		"cost": { "material": 60, "tools": 0, "ticks": 168 },
		"allowed_outpost": ["civilian"],
		"current_level_key": "manufacturing_level",
		"leader_pref": { "貪婪": 0.2 },
	},
	"apothecary": {
		"cost": { "material": 50, "tools": 2, "ticks": 168 },
		"allowed_outpost": ["civilian"],
		"current_level_key": "apothecary_level",
		"leader_pref": { "慎重": 0.2 },
	},
	"mint": {
		"cost": { "material": 100, "tools": 5, "ticks": 720 },
		"allowed_outpost": ["civilian"],
		"current_level_key": "mint_level",
		"leader_pref": { "貪婪": 0.4, "野心": 0.2 },
	},
	"stable": {
		"cost": { "material": 40, "tools": 0, "ticks": 336 },
		"allowed_outpost": ["civilian", "military"],
		"current_level_key": "stable_level",
		"required_terrain": "plains",
		"leader_pref": { "野心": 0.2, "好戰": 0.3 },
	},
	"smeltery": {
		"cost": { "material": 80, "tools": 3, "ticks": 336 },
		"allowed_outpost": ["military"],
		"current_level_key": "smelter_level",
		"leader_pref": { "好戰": 0.2 },
	},
	"weaponsmith": {
		"cost": { "material": 80, "tools": 3, "ticks": 336 },
		"allowed_outpost": ["military"],
		"current_level_key": "weaponsmith_level",
		"leader_pref": { "好戰": 0.4 },
	},
	"armorsmith": {
		"cost": { "material": 80, "tools": 3, "ticks": 336 },
		"allowed_outpost": ["military"],
		"current_level_key": "armorsmith_level",
		"leader_pref": { "慎重": 0.3, "好戰": 0.2 },
	},
}

static func slot_cap(tile: HexTileData) -> int:
	var arr: Array = FACILITY_SLOTS.get(tile.outpost_type, [0, 0, 0])
	return int(arr[clampi(tile.outpost_level - 1, 0, 2)])

static func slots_used(tile: HexTileData) -> int:
	var n: int = 0
	for f in FACILITY_DEF:
		if int(tile.get(FACILITY_DEF[f]["current_level_key"])) > 0:
			n += 1
	return n

# 升級成本 = 基準 cost × target_level（Lv1=×1 / Lv2=×2 / Lv3=×3），含 ticks
static func upgrade_cost(facility: String, target_level: int) -> Dictionary:
	var base: Dictionary = FACILITY_DEF[facility]["cost"]
	var mult: int = clampi(target_level, 1, 3)
	var out: Dictionary = {}
	for k in base:
		out[k] = int(base[k]) * mult
	return out

const MINT_BASE_RATE: float = 10.0
const GOLD_TO_COIN_RATIO: float = 20.0
const SILVER_TO_COIN_RATIO: float = 5.0

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

# 公庫容量常數 + 計算已搬入 TileBank（單點）。以下委派保留既有呼叫端（os._get_storage_cap / storage_cap）不動。

# 公開 wrapper：UI/查詢層讀公庫容量（不直呼私有 _get_storage_cap）
func storage_cap(tile: HexTileData, res: String) -> float:
	return TileBank.cap(tile, res)

func _get_storage_cap(tile: HexTileData, res: String) -> float:
	return TileBank.cap(tile, res)

# ──────── Tick 驅動 ────────

func tick_all(state: WorldState) -> void:
	# outpost tick 在近區每小時跑一次 → day_fraction = 1 小時/天
	var day_fraction: float = float(WorldState.TICKS_PER_HOUR) / float(WorldState.TICKS_PER_DAY)
	for tile_id in state.world.tiles:
		var tile: HexTileData = state.world.tiles[tile_id]
		# 生產人力 gate：tile 上有居民團（PRODUCE tag）才生產（無人 = 停產）
		if tile.mint_level > 0 or tile.stable_level > 0:
			if _has_resident_on_tile(state, tile):
				if tile.mint_level > 0:
					_tick_mint(state, tile, state.teams.get(tile.outpost_owner))
				if tile.stable_level > 0:
					produce_stable_day(state, tile, day_fraction)
		if tile.construction_team_id == -1:
			continue
		_tick_construction(state, tile)


# tile 上是否有 PRODUCE（居民）team（軍屯子隊同 tag）
func _has_resident_on_tile(state: WorldState, tile: HexTileData) -> bool:
	for tid in state.teams:
		var t: TeamData = state.teams[tid]
		if t.tile_pos != tile.tile_pos: continue
		if TeamData.TAG_PRODUCE in t.tags: return true
	return false

# 馬廄產出：兩路互斥（by tile）——
#   產馬帶（resource_cap["mounts"]>0）= 良質牧地,直接繁育（不需捕獲 horses,含 civilian ranch）。
#   否則 military = 訓練（公庫 horses + owner 草料 → 公庫 mounts）。B 期廢 food→mounts 魔法。
# 兩路皆用 tile.stable_progress（互斥,不雙記）;皆入 public_storage（owner 公庫,非 owner.resources）。
# day_fraction = 本次 tick 佔一天的比例；測試可直接以 day_fraction=1.0 模擬整天。
func produce_stable_day(state: WorldState, tile: HexTileData, day_fraction: float) -> void:
	if tile.stable_level <= 0: return
	var owner: TeamData = state.teams.get(tile.outpost_owner)
	if owner == null: return
	var lvl_idx: int = clampi(tile.stable_level - 1, 0, 2)
	if float(tile.resource_cap.get("mounts", 0)) > 0.0:
		_breed_stable_mounts(tile, owner, lvl_idx, day_fraction)
	elif tile.outpost_type == "military":
		_train_stable_mounts(tile, owner, lvl_idx, day_fraction)

# 產馬帶育馬：牧地 + 草料 → 公庫 mounts（不消耗 horses；resource_cap 為良質牧地標記,永在）。
func _breed_stable_mounts(tile: HexTileData, owner: TeamData, lvl_idx: int, day_fraction: float) -> void:
	var cap: float = _get_storage_cap(tile, "mounts")
	var stored: float = float(tile.public_storage.get("mounts", 0))
	if stored >= cap: return   # 滿廄 → 不再耗草料育馬
	var food_cost: float = STABLE_FOOD_PER_DAY[lvl_idx] * day_fraction
	if float(owner.resources.get("food", 0)) < food_cost:
		return   # 草料不足，本次不育
	ResourceBank.add(owner, "food", -food_cost, "stable_breed_feed")
	tile.stable_progress += STABLE_BREED_PER_DAY[lvl_idx] * day_fraction
	if tile.stable_progress >= 1.0 - 1e-9:
		var bred: int = int(tile.stable_progress + 1e-9)
		tile.stable_progress -= float(bred)
		TileBank.set_amt(tile, "mounts", minf(stored + float(bred), cap), "stable_breed")
		if bred > 0:
			print("[Stable] 產馬帶 %s 繁育戰馬 +%d" % [str(tile.tile_pos), bred])

# military 訓練：公庫 horses + owner 草料 → 公庫 mounts。
func _train_stable_mounts(tile: HexTileData, owner: TeamData, lvl_idx: int, day_fraction: float) -> void:
	var horses_avail: float = float(tile.public_storage.get("horses", 0))
	if horses_avail < 1.0: return   # 無馴馬可訓
	var food_cost: float = STABLE_FOOD_PER_DAY[lvl_idx] * day_fraction
	if float(owner.resources.get("food", 0)) < food_cost:
		return   # 草料不足，本次不訓
	ResourceBank.add(owner, "food", -food_cost, "stable_feed")
	tile.stable_progress += STABLE_PRODUCE_PER_DAY[lvl_idx] * day_fraction
	# epsilon 吸收浮點累加誤差（30×0.3 = 8.999… → 9）
	if tile.stable_progress >= 1.0 - 1e-9:
		var trained: int = int(tile.stable_progress + 1e-9)
		trained = mini(trained, int(horses_avail))
		tile.stable_progress -= float(trained)
		TileBank.set_amt(tile, "horses", horses_avail - float(trained), "stable_train_horse_out")
		var cap: float = _get_storage_cap(tile, "mounts")
		var stored: float = float(tile.public_storage.get("mounts", 0))
		TileBank.set_amt(tile, "mounts", minf(stored + float(trained), cap), "stable_train_mount")
		if trained > 0:
			print("[Stable] Outpost %s 訓練戰馬 +%d" % [str(tile.tile_pos), trained])

func _tick_mint(_state: WorldState, tile: HexTileData, _team: TeamData) -> void:
	if tile.mint_level == 0: return
	var rate: float = float(tile.mint_level) * MINT_BASE_RATE
	# coin 容量餘裕：只鑄能容下的量 → 不燒 ore（守恆，修 known_issues「mint coin-cap 燒 ore off-ledger」）
	var cap: float = _get_storage_cap(tile, "coin")
	var cur_coin: float = float(tile.public_storage.get("coin", 0))
	var room: float = maxf(cap - cur_coin, 0.0)
	if room <= 0.0: return
	var gold_qty: float = float(tile.public_storage.get("ore_gold", 0))
	if gold_qty > 0.0:
		var convert: float = minf(gold_qty, minf(rate, room) / GOLD_TO_COIN_RATIO)
		var coin_added: float = convert * GOLD_TO_COIN_RATIO
		tile.public_storage["ore_gold"] = gold_qty - convert
		tile.public_storage["coin"] = cur_coin + coin_added
		if coin_added > 0.0:
			print("[Mint] tile(%d,%d) gold→coin +%.1f (mint_lv=%d)" % [
				tile.tile_pos.x, tile.tile_pos.y, coin_added, tile.mint_level])
			Probe.bump("g1.mint")
			Probe.add_amount("mint_coin", coin_added)   # 鑄幣 ledger（coin 唯一來源，供 CoinAudit 認得增發）
		return
	var silver_qty: float = float(tile.public_storage.get("ore_silver", 0))
	if silver_qty > 0.0:
		var convert: float = minf(silver_qty, minf(rate, room) / SILVER_TO_COIN_RATIO)
		var coin_added: float = convert * SILVER_TO_COIN_RATIO
		tile.public_storage["ore_silver"] = silver_qty - convert
		tile.public_storage["coin"] = cur_coin + coin_added
		if coin_added > 0.0:
			print("[Mint] tile(%d,%d) silver→coin +%.1f (mint_lv=%d)" % [
				tile.tile_pos.x, tile.tile_pos.y, coin_added, tile.mint_level])
			Probe.bump("g1.mint")
			Probe.add_amount("mint_coin", coin_added)   # 鑄幣 ledger

func _tick_construction(state: WorldState, tile: HexTileData) -> void:
	# 找同格上所有 current_task == "建設" 的 team（接手機制）
	var active_team: TeamData = null
	for tid in state.teams:
		var t: TeamData = state.teams[tid]
		if t.tile_pos == tile.tile_pos and t.current_task == TeamData.TASK_BUILD:
			active_team = t
			break
	if active_team == null:
		return  # 無施工隊在格，暫停（faction_ai._try_resume_construction 負責召回復工）
	# 更新施工 team（接手：任何在格上建設的 team 都可繼續）
	tile.construction_team_id = active_team.team_id
	if tile.construction_started_tick == -1:
		tile.construction_started_tick = state.world.current_tick
	tile.construction_last_progress_tick = state.world.current_tick
	tile.construction_ticks_left -= maxi(active_team.population, 1)
	if tile.construction_ticks_left <= 0:
		_complete_construction(state, tile, active_team)

func _complete_construction(state: WorldState, tile: HexTileData, team: TeamData) -> void:
	var action: String = tile.construction_target.get("action", "")
	match action:
		"build":
			tile.outpost_type  = tile.construction_target["type"]
			tile.outpost_level = tile.construction_target["level"]
			OutpostOwnerBank.set_owner(tile, tile.construction_team_id, "construct")
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
			# G1a 探針：含礦山地 outpost 建成 → mine_founded（gold 或 silver）
			# resource_cap 記初始礦量（永不清零），比 resources 更可靠（施工期已被採集可能 =0）
			if tile.terrain == "mountain" and (float(tile.resource_cap.get("ore_gold", 0)) > 0.0 \
					or float(tile.resource_cap.get("ore_silver", 0)) > 0.0):
				Probe.bump("g1.mine_founded")
			# C: NPC 建造子隊完工 → 就地安頓（脫離母團、加駐留 tag），outpost 持續存在
			if team.parent_team_id != -1:
				_auto_settle_builder(state, team, tile)
		"upgrade_level":
			tile.outpost_level = tile.construction_target["level"]
			print("[Outpost] Team%d 升級 → %s Lv%d" % [
				team.team_id, tile.outpost_type, tile.outpost_level])
		"upgrade_facility":
			var fac: String = str(tile.construction_target.get("facility", ""))
			if FACILITY_DEF.has(fac):
				var key: String = FACILITY_DEF[fac]["current_level_key"]
				tile.set(key, mini(int(tile.get(key)) + 1, 3))
				print("[Outpost] 設施完工 %s Lv%d at (%d,%d)" % [
					fac, int(tile.get(key)), tile.tile_pos.x, tile.tile_pos.y])
		"crude_camp":
			# 玩家紮營完工（Y 版）：免材料,只抬 food cap（regen 才產糧）,絕不送即時糧（去剝削）
			tile.outpost_type  = str(tile.construction_target.get("type", "civilian"))
			tile.outpost_level = 1
			OutpostOwnerBank.set_owner(tile, int(tile.construction_target.get("owner", team.team_id)), "construct")
			tile.resource_cap["food"] = maxf(float(tile.resource_cap.get("food", 0)), 40.0)   # = PlayerCommandSystem.CAMP_FOOD_CAP
			var camp_tag: String = TeamData.TAG_MILITARY if tile.outpost_type == "military" else TeamData.TAG_PRODUCE
			if not team.tags.has(camp_tag):
				team.tags.append(camp_tag)
			team.tags.erase("流亡")
			TaskArbiter.release(team)   # 紮營完工 → 釋放玩家隊回 idle（否則永卡 task=建設）
			print("[CrudeCamp] Team%d 玩家紮營完工 @(%d,%d) → %s" % [
				team.team_id, tile.tile_pos.x, tile.tile_pos.y, tile.outpost_type])
		"demolish":
			print("[Outpost] Team%d 拆除 %s at (%d,%d)" % [
				team.team_id, get_outpost_name(tile.outpost_type, tile.outpost_level),
				tile.tile_pos.x, tile.tile_pos.y])
			tile.outpost_type  = ""
			tile.outpost_level = 0
			OutpostOwnerBank.set_owner(tile, -1, "demolish")
			for fac_name in FACILITY_DEF:
				tile.set(FACILITY_DEF[fac_name]["current_level_key"], 0)
			tile.stable_progress = 0.0
			tile.garrison.clear()
			tile.prisoners.clear()
	tile.construction_ticks_left = 0
	tile.construction_team_id   = -1
	tile.construction_target     = {}
	tile.construction_started_tick = -1
	tile.construction_last_progress_tick = -1
	TaskArbiter.release(team)

# C: 建造子隊完工後就地安頓為駐留 team（owner 已設為自己，加 tag、脫離母團）
func _auto_settle_builder(state: WorldState, team: TeamData, tile: HexTileData) -> void:
	state.detach_subteam(team)   # 完工安頓脫離母團（雙向同步）
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
	var cost: Dictionary = OUTPOST_COST[type][level - 1]
	if not _can_afford(team, tile, cost):
		push_warning("[Outpost] start_build: 資源不足")
		return false
	_deduct_cost(team, tile, cost)
	tile.construction_team_id   = team.team_id
	tile.construction_ticks_left = BUILD_TICKS[type][level - 1]
	tile.construction_target    = { "action": "build", "type": type, "level": level }
	tile.construction_started_tick = state.world.current_tick
	tile.construction_last_progress_tick = state.world.current_tick
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
	var cost: Dictionary = OUTPOST_COST[tile.outpost_type][new_level - 1]
	if not _can_afford(team, tile, cost):
		return false
	_deduct_cost(team, tile, cost)
	tile.construction_team_id   = team.team_id
	tile.construction_ticks_left = BUILD_TICKS[tile.outpost_type][new_level - 1]
	tile.construction_target    = { "action": "upgrade_level", "level": new_level }
	tile.construction_started_tick = state.world.current_tick
	tile.construction_last_progress_tick = state.world.current_tick
	TaskArbiter.transition(team, "建設", TaskArbiter.PRIO_DISPATCH)
	print("[Outpost] Team%d 升級 → Lv%d at (%d,%d)" % [
		team.team_id, new_level, tile.tile_pos.x, tile.tile_pos.y])
	return true

# 通用設施 建造/升級（玩家路徑）：slot 制 + allowed_outpost gate
func start_upgrade_facility(state: WorldState, team: TeamData, facility: String) -> bool:
	var tile := _get_team_tile(state, team)
	if tile == null or tile.outpost_level == 0:
		return false
	if tile.outpost_owner != team.team_id or tile.construction_team_id != -1:
		return false
	return _begin_facility_construction(team, tile, facility)

func start_upgrade_farming(state: WorldState, team: TeamData) -> bool:
	return start_upgrade_facility(state, team, "farming")

func start_upgrade_manufacturing(state: WorldState, team: TeamData) -> bool:
	return start_upgrade_facility(state, team, "workshop")

# 共用 gate + 扣款 + 排程（呼叫端先驗 owner/faction 與 construction 空檔）
func _begin_facility_construction(team: TeamData, tile: HexTileData, facility: String) -> bool:
	if not FACILITY_DEF.has(facility):
		return false
	var def: Dictionary = FACILITY_DEF[facility]
	if not (tile.outpost_type in def["allowed_outpost"]):
		return false
	if def.has("required_terrain") and tile.terrain != def["required_terrain"]:
		return false
	var cur: int = int(tile.get(def["current_level_key"]))
	if cur >= 3:
		return false
	if cur == 0 and slots_used(tile) >= slot_cap(tile):
		return false   # 新設施要空 slot；升級不佔
	var cost: Dictionary = upgrade_cost(facility, cur + 1)
	if not _can_afford(team, tile, cost):
		return false
	_deduct_cost(team, tile, cost)
	tile.construction_team_id   = team.team_id
	tile.construction_ticks_left = int(cost["ticks"])
	tile.construction_target    = { "action": "upgrade_facility", "facility": facility }
	TaskArbiter.transition(team, TeamData.TASK_BUILD, TaskArbiter.PRIO_DISPATCH)
	print("[Outpost] Team%d 設施施工 %s → Lv%d at (%d,%d)" % [
		team.team_id, facility, cur + 1, tile.tile_pos.x, tile.tile_pos.y])
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

# 依 construction_target 查當前工地已付成本（timeout 退料用）
static func construction_cost_of(tile: HexTileData) -> Dictionary:
	var action: String = str(tile.construction_target.get("action", ""))
	match action:
		"build":
			return OUTPOST_COST[str(tile.construction_target["type"])] \
				[int(tile.construction_target["level"]) - 1]
		"upgrade_level":
			return OUTPOST_COST[tile.outpost_type][int(tile.construction_target["level"]) - 1]
		"upgrade_facility":
			var fac: String = str(tile.construction_target.get("facility", ""))
			if FACILITY_DEF.has(fac):
				var cur: int = int(tile.get(FACILITY_DEF[fac]["current_level_key"]))
				return upgrade_cost(fac, cur + 1)
	return {}   # demolish 無付款

# 工地 30 天無實際進度 → 取消、退 50% 料給施工團、tile 釋放。回傳 true = 已取消。
func check_construction_timeout(state: WorldState, tile: HexTileData) -> bool:
	if tile.construction_team_id == -1:
		return false
	# 時鐘未起算（開工後尚無進度 tick）→ 從本次掃描起算
	if tile.construction_last_progress_tick == -1:
		tile.construction_last_progress_tick = state.world.current_tick
		if tile.construction_started_tick == -1:
			tile.construction_started_tick = state.world.current_tick
		return false
	if state.world.current_tick - tile.construction_last_progress_tick <= CONSTRUCTION_TIMEOUT:
		return false
	var ct: TeamData = state.teams.get(tile.construction_team_id)
	var cost: Dictionary = construction_cost_of(tile)
	if ct != null:
		for k in cost:
			if k == "ticks": continue
			ResourceBank.add(ct, k, float(cost[k]) * 0.5, "construction_refund")
	tile.construction_team_id = -1
	tile.construction_ticks_left = 0
	tile.construction_target = {}
	tile.construction_started_tick = -1
	tile.construction_last_progress_tick = -1
	print("[Infra] 工地逾時取消 at (%d,%d) 退料 50%%" % [tile.tile_pos.x, tile.tile_pos.y])
	return true

# 拆除單一設施（騰 slot；需求迴路拆遷用）
func demolish_facility(_state: WorldState, tile: HexTileData, facility: String) -> void:
	if not FACILITY_DEF.has(facility):
		return
	var key: String = FACILITY_DEF[facility]["current_level_key"]
	if int(tile.get(key)) <= 0:
		return
	tile.set(key, 0)
	if facility == "stable":
		tile.stable_progress = 0.0
	print("[Outpost] 拆除設施 %s at (%d,%d)" % [facility, tile.tile_pos.x, tile.tile_pos.y])

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
		TeamData.TASK_CONSTRUCT:
			var btype: String = str(extra.get("build_type", "civilian"))
			var lvl: int = int(extra.get("level", 1))
			return start_build(state, team, btype, lvl)
		TeamData.TASK_UPGRADE:
			var tgt_lvl: int = int(extra.get("target_level", tile.outpost_level + 1))
			return _subteam_upgrade_level(state, team, tile, tgt_lvl)
		TeamData.TASK_EXPAND:
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
	var cost: Dictionary = OUTPOST_COST[tile.outpost_type][target_level - 1]
	if not _can_afford(team, tile, cost):
		return false
	_deduct_cost(team, tile, cost)
	tile.construction_team_id   = team.team_id
	tile.construction_ticks_left = BUILD_TICKS[tile.outpost_type][target_level - 1]
	tile.construction_target    = { "action": "upgrade_level", "level": target_level }
	tile.construction_started_tick = state.world.current_tick
	tile.construction_last_progress_tick = state.world.current_tick
	TaskArbiter.transition(team, TeamData.TASK_BUILD, TaskArbiter.PRIO_DISPATCH)
	print("[Outpost] 子隊 Team%d 開始升級 → Lv%d at (%d,%d)" % [
		team.team_id, target_level, tile.tile_pos.x, tile.tile_pos.y])
	return true

func _subteam_upgrade_facility(state: WorldState, team: TeamData, tile: HexTileData, facility: String) -> bool:
	if tile.outpost_level == 0:
		return false
	if not _faction_owns(state, team, tile) or tile.construction_team_id != -1:
		return false
	return _begin_facility_construction(team, tile, facility)

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
		if Probe.enabled:
			_probe_capture_flip(state, winner_id, tile)   # 掃須在 set_owner 前（讀翻旗前狀態）
		OutpostOwnerBank.set_owner(tile, winner_id, "capture")
		print("[Outpost] Team%d 佔領 %s（原 Team%d）at (%d,%d)" % [
			winner_id, get_outpost_name(tile.outpost_type, tile.outpost_level),
			old_owner, tile.tile_pos.x, tile.tile_pos.y])

# Task1 measure（純觀測，佔村 spec）：capture 真翻旗分佈。須在 set_owner 前呼（讀翻旗前狀態）。
# by_loot（掠奪狼翻旗）/ civilian（村格）/ wolf_firstbase（流浪狼奪首據點=雙引擎咬合點）。
func _probe_capture_flip(state: WorldState, winner_id: int, tile: HexTileData) -> void:
	Probe.bump("raid.capture_flip")
	var w: TeamData = state.teams.get(winner_id)
	if w == null: return
	if w.current_task == TeamData.TASK_LOOT:
		Probe.bump("raid.capture_flip_by_loot")
	if w.current_option == "佔村":
		Probe.bump("occupy.capture_flip")   # 佔村 option 驅動的翻旗（雙引擎咬合證據）
	if tile.outpost_type == "civilian":
		Probe.bump("raid.capture_flip_civilian")
	if w.faction_id == -1:
		var had_base: bool = false
		for tid in state.world.tiles:
			var t: HexTileData = state.world.tiles[tid]
			if t.outpost_level > 0 and t.outpost_owner == winner_id:
				had_base = true; break
		if not had_base:
			Probe.bump("raid.capture_flip_wolf_firstbase")

func get_outpost_name(type: String, level: int) -> String:
	var names: Array = OUTPOST_NAMES.get(type, [])
	if level >= 1 and level <= names.size():
		return names[level - 1]
	return "未知據點"

# ──────── 輔助 ────────

func _check_distance(state: WorldState, pos: Vector2i, type: String) -> bool:
	# S2 礦村：civilian 且目標格 resource_cap 有礦 → 距離免疫（礦山位置不可選擇）。
	# 條件限 type=="civilian" 防軍事 outpost / 玩家紮營繞過距離限制；
	# 用 resource_cap（永不耗盡）而非 resources（採集後可能 =0）判礦脈存在。
	if type == "civilian":
		var target_tile: HexTileData = state.world.tiles.get(pos.x * 1000 + pos.y)
		var is_ore_mountain: bool = target_tile != null and target_tile.terrain == "mountain" \
			and (float(target_tile.resource_cap.get("ore_gold", 0)) > 0.0 \
				or float(target_tile.resource_cap.get("ore_silver", 0)) > 0.0)
		if is_ore_mountain:
			return true   # 礦村 tile：跳過距離限制（礦山位置不可選擇，強制允建）
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

# 建造付款：腳下 tile 公庫 + 施工團私產 合併池，優先扣公庫（本地）。
func _can_afford(team: TeamData, tile: HexTileData, cost: Dictionary) -> bool:
	for res in cost:
		if res == "ticks":
			continue
		var avail: float = float(tile.public_storage.get(res, 0)) \
			+ float(team.resources.get(res, 0))
		if avail < float(cost.get(res, 0)):
			return false
	return true

func _deduct_cost(team: TeamData, tile: HexTileData, cost: Dictionary) -> void:
	for res in cost:
		if res == "ticks":
			continue
		var need: float = float(cost.get(res, 0))
		if need <= 0.0:
			continue
		var from_vault: float = TileBank.withdraw(tile, res, need, "construction_pay_vault")
		var rem: float = need - from_vault
		if rem > 0.0:
			ResourceBank.remove(team, res, rem, "construction_pay")
