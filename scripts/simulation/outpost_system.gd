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

# ★★★工期單一真值（S6 phase2，2026-09-01）——★一顆錨 ＋ 一張倍數表，★★沒有第二個絕對值。
#   錨 = 紮根 L0→L1 的工量，blueprint 2026-09-01 正式簽署；倍數＝WHAT §3c 設計（不動）。
# ★★★被禁止的形狀（寫在這裡，因為它是最誘人的那個）：
#   保留另一張工期表、然後在某處「讓它等於這裡」——
#   ★那是【同步兩張表】，而同步關係沒有人維護，它只在寫下的那一天成立。
#   ★★用戶原話：把 2 改成 5，三個月後又爛。修法形狀＝改接線，不是改數值。
# ★本檔改制前有四種來源（據點表／設施表／紮營常數／CORVEE 天數×根），
#   ★★而三個決策端讀的是其中【另一張】⇒ 只推一張＝世界變慢而 NPC 不知道（腦不知手）。
const SETTLE_PERSON_HOURS: int = 720

# 倍數＝設計（WHAT §3c，用戶核可）。★這裡只有比例，絕對值只有錨那一顆。
const BUILD_MULT_FACILITY: Dictionary = {
	"farming": 0.5,
	"workshop": 1.0, "apothecary": 1.0,
	"stable": 2.0, "smeltery": 2.0, "weaponsmith": 2.0, "armorsmith": 2.0,
	"mint": 4.0,
}
const BUILD_MULT_CAMP: float = 1.0 / 3.0                   # 紮營
const BUILD_MULT_OUTPOST_LEVEL: Array = [1.0, 3.0, 6.0]    # 據點 L1/L2/L3（★L1 ＝ 紮根 ＝ 錨本身）

# ★★★工期【唯一入口】：四種來源（據點／紮營／紮根／設施）全部走這一個查詢。
#   ★kind 不認得就【爆】（fail loud，systems 裁定④）——
#     ★★靜默 fallback 會給出一個「看起來合理的錯數字」，而沒有人在看它。
static func build_person_hours(kind: String, level: int = 1) -> int:
	if kind == "civilian" or kind == "military":
		var li: int = clampi(level, 1, BUILD_MULT_OUTPOST_LEVEL.size()) - 1
		return int(round(float(SETTLE_PERSON_HOURS) * float(BUILD_MULT_OUTPOST_LEVEL[li])))
	if kind == "settle":
		return SETTLE_PERSON_HOURS                              # L0→L1 紮根 ＝ 錨
	if kind == "camp":
		return int(round(float(SETTLE_PERSON_HOURS) * BUILD_MULT_CAMP))
	# ★設施：未登記 kind 在下一行直接爆（Dictionary 缺鍵 = runtime error），assert 只是先給人話
	assert(BUILD_MULT_FACILITY.has(kind), "build_person_hours: 未登記的 kind=%s ★新增設施必須登記倍數" % kind)
	return int(round(float(SETTLE_PERSON_HOURS) * float(BUILD_MULT_FACILITY[kind]) * float(clampi(level, 1, 3))))

# ★★★工地取消 ＝ k × 預期工期（相對錨定，S6 phase2 §5）——不再是絕對 30 天。
# TIER: n/a — 語意時長非節律（某事多久算過期，不是多久評一次）
# ★動機：錨一改，世界工期跟著變，而絕對 30 天不會跟 ⇒ 大工地會被守衛誤殺。
# ★★而這裡有一個會把守衛變成廢物的陷阱，寫死在這：
#   若用【即時 pop】算預期工期 ⇒ pop 掉到 0 ⇒ 預期工期 → ∞ ⇒ timeout 永不觸發
#   ⇒ ★★★而本守衛的職責自述就是「防永久卡死黑洞」—— 黑洞會原樣回來。
#   ⇒ 硬條款：pop 取【動工當下】並凍結（存在 construction_target.start_pop）。
# ★CEIL 必要（上界不得因工期變大而無限延後）；FLOOR 防短工地被秒取消。
const CONSTRUCTION_TIMEOUT_K: float = 3.0            # 取消門檻 ＝ 3× 預期工期
const CONSTRUCTION_TIMEOUT_FLOOR_DAYS: float = 5.0   # 下限：短工地也給 5 天停工寬限
const CONSTRUCTION_TIMEOUT_CEIL_DAYS: float = 30.0   # ★上限 ＝ 改制前的絕對值（上界刻意不放寬）

# 停工多久算逾時（天）。★pop 讀【動工當下凍結值】，不讀即時 pop（見上方陷阱）。
static func construction_timeout_days(tile: HexTileData) -> float:
	var pop0: int = int(tile.construction_target.get("start_pop", 0))
	if pop0 <= 0:
		# ★從來沒有工人上過工 ⇒ 算不出預期工期 ⇒ 用 CEIL（有界，不製造黑洞）
		return CONSTRUCTION_TIMEOUT_CEIL_DAYS
	var expected: float = build_eta_days(construction_ticks_total(tile), pop0)
	return clampf(CONSTRUCTION_TIMEOUT_K * expected,
		CONSTRUCTION_TIMEOUT_FLOOR_DAYS, CONSTRUCTION_TIMEOUT_CEIL_DAYS)

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
# person_hours：每小時扣 maxi(pop,1) ⇒ pop=1 時 farming 72 ＝ 72 小時 ＝ ★3.0 遊戲日
#   （★實測非推導：docs/measurements/2026-09-01-s6-build-days-truth.txt，pop 與每窗 delta 都是讀來的）
const FACILITY_DEF: Dictionary = {
	"farming": {
		"cost": { "material": 30, "tools": 0 },
		"allowed_outpost": ["civilian"],
		"current_level_key": "farming_level",
		"leader_pref": { "慎重": 0.3 },
	},
	"workshop": {
		"cost": { "material": 60, "tools": 0 },
		"allowed_outpost": ["civilian"],
		"current_level_key": "manufacturing_level",
		"leader_pref": { "貪婪": 0.2 },
	},
	"apothecary": {
		"cost": { "material": 50, "tools": 2 },
		"allowed_outpost": ["civilian"],
		"current_level_key": "apothecary_level",
		"leader_pref": { "慎重": 0.2 },
	},
	"mint": {
		"cost": { "material": 100, "tools": 5 },
		"allowed_outpost": ["civilian"],
		"current_level_key": "mint_level",
		"leader_pref": { "貪婪": 0.4, "野心": 0.2 },
	},
	"stable": {
		"cost": { "material": 40, "tools": 0 },
		"allowed_outpost": ["civilian", "military"],
		"current_level_key": "stable_level",
		"required_terrain": "plains",
		"leader_pref": { "野心": 0.2, "好戰": 0.3 },
	},
	"smeltery": {
		"cost": { "material": 70, "tools": 3 },   # ★mil-facility-cost70:material 80→70(仿 weaponsmith,同族,balance):afford margin。★trace 坐實 largely ineffective——真 afford root=reserve_factor urgency 非 cost,經食安化解;keep=無害。詳 known_issues cost70-trace
		"allowed_outpost": ["military"],
		"current_level_key": "smelter_level",
		"leader_pref": { "好戰": 0.2 },
	},
	"weaponsmith": {
		"cost": { "material": 70, "tools": 3 },   # material 80→70(blueprint balance 裁②):afford margin(cost×1.5 120→105)。★trace 坐實 largely ineffective——真 afford root=reserve_factor urgency-suppression(隊食/coin 壓賣掉 material)非 cost/cap/「117」,經食安化解;keep=無害 balance 值。詳 known_issues cost70-trace
		"allowed_outpost": ["military"],
		"current_level_key": "weaponsmith_level",
		"leader_pref": { "好戰": 0.4 },
	},
	"armorsmith": {
		"cost": { "material": 70, "tools": 3 },   # ★mil-facility-cost70:material 80→70(仿 weaponsmith,同族,balance):afford margin。★trace 坐實 largely ineffective——真 afford root=reserve_factor urgency 非 cost,經食安化解;keep=無害。詳 known_issues cost70-trace
		"allowed_outpost": ["military"],
		"current_level_key": "armorsmith_level",
		"leader_pref": { "慎重": 0.3, "好戰": 0.2 },
	},
}

# ────────── 工期單一真相源（build-eta-single-source 2026-08-25）──────────
# ★病：全樹六份獨立公式、三種答案、極端差 240 倍（見 `docs/estimator-ledger.md §E`）。
#   #3/#4 漏掉「一天推進幾次」⇒ 高估 24×；#5/#6 除了 TICKS_PER_DAY(240) ⇒ 低估 10×。
#   ★修法是【改接線】不是【改數值】——把 2 改成 5，三個月後又爛。
#
# 真值只有一處：`_tick_construction` 每執行一次扣 `maxi(pop, 1)` person-ticks（本檔 `:311`），
# 而它掛在 `SimRunner.SYSTEMS` 的 `outpost_tick` 上（`lod = LOD_NEAR`）
# ⇒ **一天執行幾次 ＝ 一天有幾個 near cadence 窗**。
# ★分母因此【由 cadence 同源推導】，禁手抄 `24`：
#   `TICKS_PER_DAY / NEAR_CADENCE`（目前 240/10 ＝ 24）——兩顆都動到就自動跟著改。
static func build_ticks_per_day() -> float:
	# ★假設：`outpost_tick` 跑在 near pass。它是 `LOD_NEAR`，所以成立；
	#   但這是【假設】不是恆真 ⇒ 留一顆告警，別靜默照算（同「觀測要看得見」那條）。
	if Probe.enabled and not _outpost_tick_runs_in_near_pass():
		Probe.bump("build_eta.cadence_assumption_stale")
	return float(WorldState.TICKS_PER_DAY) / maxf(float(SimRunner.NEAR_CADENCE), 1.0)

# `outpost_tick` 是否仍在 near pass 跑（讀 registry，不手抄）。
static func _outpost_tick_runs_in_near_pass() -> bool:
	for e in SimRunner.SYSTEMS:
		if String(e.get("name", "")) == "outpost_tick":
			return int(e.get("lod", SimRunner.LOD_NEAR)) in [SimRunner.LOD_NEAR, SimRunner.LOD_BOTH]
	return false   # 表裡找不到 ⇒ 假設已失效

# ★六個估值點的【唯一】入口：剩餘 person-hours + 施工人力 → 還要幾天。
#   `pop` ＝ 實際推進工程的人數（真值那行用 `maxi(pop, 1)`，此處同源夾同一個下限）。
static func build_eta_days(person_hours_left: int, pop: int) -> float:
	if person_hours_left <= 0:
		return 0.0
	var per_tick_progress: float = maxf(float(pop), 1.0)   # 同 `_tick_construction` 的 maxi(pop, 1)
	return float(person_hours_left) / (per_tick_progress * maxf(build_ticks_per_day(), 0.001))

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
	# ★工期【不在 cost 表裡】了（S6 phase2）：它由唯一入口算，入口自己吃 level 倍數
	#   ⇒ ★★不能再走上面那個 for（那會把工期當成又一顆料，且需要表裡先有一份副本）
	out["person_hours"] = build_person_hours(facility, target_level)
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
		TileBank.set_amt(tile, "ore_gold", gold_qty - convert, "mint_consume_gold")
		TileBank.set_amt(tile, "coin", cur_coin + coin_added, "mint")   # coin 唯一來源，room-cap 前已限量→不燒 ore
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
		TileBank.set_amt(tile, "ore_silver", silver_qty - convert, "mint_consume_silver")
		TileBank.set_amt(tile, "coin", cur_coin + coin_added, "mint")
		if coin_added > 0.0:
			print("[Mint] tile(%d,%d) silver→coin +%.1f (mint_lv=%d)" % [
				tile.tile_pos.x, tile.tile_pos.y, coin_added, tile.mint_level])
			Probe.bump("g1.mint")
			Probe.add_amount("mint_coin", coin_added)   # 鑄幣 ledger

# ★construction 可觀測性 tap（純觀測，禁耗 RNG；spec 2026-07-25-construction-pipeline-observability）：
# build/facility start transition 後捕捉實際 current_task/priority——坐實 transition 是否真讓 task→TASK_BUILD
# （一階#2 最強候選：若被 task_arbiter guard 攔→task 留 TASK_CONSTRUCT→_tick_construction 找不到→永不倒數）。
func _tap_build_start(state: WorldState, team: TeamData, tile: HexTileData, action: String) -> void:
	if not Probe.enabled: return
	Probe.bump("construct.start")
	if team.current_task != TeamData.TASK_BUILD:
		Probe.bump("construct.start_task_not_build")   # ★transition 被攔=stall 一階#2 坐實
	Probe.bump_sample("construct.start", {
		"tick": state.world.current_tick, "tile": [tile.tile_pos.x, tile.tile_pos.y],
		"ct_id": tile.construction_team_id, "team": team.team_id, "action": action,
		"task_after": team.current_task, "prio_after": team.task_priority,
	})

func _tick_construction(state: WorldState, tile: HexTileData) -> void:
	# 找同格上所有 current_task == "建設" 的 team（接手機制）
	var active_team: TeamData = null
	for tid in state.teams:
		var t: TeamData = state.teams[tid]
		if t.tile_pos == tile.tile_pos and t.current_task == TeamData.TASK_BUILD:
			active_team = t
			break
	if active_team == null:
		# ★stall tap（關鍵一階根）：施工隊去向——construction_team_id 那隊現 task/pos/reason，揭它跑哪被啥改。
		if Probe.enabled:
			Probe.bump("construct.stall")
			var ct: TeamData = state.teams.get(tile.construction_team_id)
			Probe.bump_sample("construct.stall", {
				"tick": state.world.current_tick, "tile": [tile.tile_pos.x, tile.tile_pos.y],
				"ct_id": tile.construction_team_id,
				"ct_task": ct.current_task if ct != null else "gone",
				"ct_pos": ([ct.tile_pos.x, ct.tile_pos.y] if ct != null else [-1, -1]),
				"ct_reason": ct.task_reason if ct != null else "",
				"ticks_left": tile.construction_ticks_left,
			})
		if state.teams.get(tile.construction_team_id) == null:   # ★S2b: 施工隊已亡→清 orphan construction(防 zombie 永卡)
			tile.construction_team_id = -1
			tile.construction_ticks_left = 0
			tile.construction_target = {}
		return  # 無施工隊在格，暫停（faction_ai._try_resume_construction 負責召回復工）
	# ★progress tap（進度真動否）
	if Probe.enabled:
		Probe.bump("construct.progress")
		Probe.bump_sample("construct.progress", {
			"tick": state.world.current_tick, "tile": [tile.tile_pos.x, tile.tile_pos.y],
			"ticks_left": tile.construction_ticks_left, "active": active_team.team_id,
			"pop": active_team.population,
		})
	# 更新施工 team（接手：任何在格上建設的 team 都可繼續）
	tile.construction_team_id = active_team.team_id
	if tile.construction_started_tick == -1:
		tile.construction_started_tick = state.world.current_tick
	tile.construction_last_progress_tick = state.world.current_tick
	# ★★★動工當下 pop 凍結（S6 phase2 §5 硬條款）：timeout 用它算預期工期。
	#   ★取【真的有工人推進的第一個 tick】而不是 dispatch 當下 —— 派工的隊未必是施工的隊。
	if not tile.construction_target.has("start_pop"):
		tile.construction_target["start_pop"] = maxi(active_team.population, 1)
	tile.construction_ticks_left -= maxi(active_team.population, 1)
	# ★持守統一 Slice 2 新鮮度：construction 進度變 → 即重算施工隊 persist_strength（sunk 升），
	# 執行層(Slice 3)讀時是當下進度值（非決策 cadence 舊值）。純算術零 RNG。
	if tile.construction_ticks_left > 0:
		PersistStrength.compute(state, active_team)
	if tile.construction_ticks_left <= 0:
		_complete_construction(state, tile, active_team)

func _complete_construction(state: WorldState, tile: HexTileData, team: TeamData) -> void:
	var action: String = tile.construction_target.get("action", "")
	# ★complete tap（純觀測）：completion 事件（A1 measure=0 的正向對照）。
	if Probe.enabled:
		Probe.bump("construct.complete")
		# ★持守統一 Slice 4：per-action-type completion 計數（A1 閉環硬確認：'build'=新 outpost founding vs upgrade_*）。
		Probe.bump("construct.complete_" + str(action))
		Probe.bump_sample("construct.complete", {
			"tick": state.world.current_tick, "tile": [tile.tile_pos.x, tile.tile_pos.y],
			"action": action, "team": team.team_id,
		})
	match action:
		"build":
			tile.outpost_type  = tile.construction_target["type"]
			tile.outpost_level = tile.construction_target["level"]
			state.outpost_epoch += 1   # ★market-known 快取失效鍵（世界 tile 的 outpost_level 變了）
			OwnerOutpostIndex.invalidate()   # ★效能 arc B chokepoint②：outpost_level 跨 0（完工 0→>0；set_owner 可能因 owner 未變而 early-return，不能依賴它）
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
			state.outpost_epoch += 1   # ★market-known 快取失效鍵（世界 tile 的 outpost_level 變了）
			# ★§4c 反饋（成功掛點）：據點升級完工＝這塊地養得起發展 → 寫該 tile owner 隊 leader 的選址記憶。
			var _owner_team: TeamData = state.teams.get(tile.outpost_owner) if tile.outpost_owner != -1 else null
			if _owner_team != null:
				SettlementMemory.record_site_outcome(state, _owner_team, tile, SettlementMemory.SITE_THRIVED)
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
			state.outpost_epoch += 1   # ★market-known 快取失效鍵（世界 tile 的 outpost_level 變了）
			OwnerOutpostIndex.invalidate()   # ★效能 arc B chokepoint②：outpost_level 跨 0（紮營完工 0→1）
			OutpostOwnerBank.set_owner(tile, int(tile.construction_target.get("owner", team.team_id)), "construct")
			tile.resource_cap["food"] = maxf(float(tile.resource_cap.get("food", 0)), 40.0)   # = PlayerCommandSystem.CAMP_FOOD_CAP
			tile.camp_level = 0        # ★S2b：L0 消融進 L1（完工清 camp flag、L1 outpost_level 接手）
			if Probe.enabled: Probe.bump("outpost.l0_to_l1")   # ★gate3：晉級率（真的長成村，不是蓋了就丟）
			tile.camp_team_id = -1     # ★§4c：L0 生命週期結束（升 L1）→ 清起建隊欄
			tile.camp_ticks_left = 0
			team.corvee_site = Vector2i(-1, -1)   # ★S2b：工程完成→清工地記憶
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
			state.outpost_epoch += 1   # ★market-known 快取失效鍵（世界 tile 的 outpost_level 變了）
			OwnerOutpostIndex.invalidate()   # ★效能 arc B chokepoint②：outpost_level 跨 0（拆除 >0→0）
			OutpostOwnerBank.set_owner(tile, -1, "demolish")
			# ★god-view Slice C：市集拆了(outpost_level→0，唯一真消失路)→清所有隊 team_market_known 對此 tile 的
			# 條目（tile 級：知此市集的隊都該忘）。★只 demolish 清；capture/set_owner 不清（市集還在=known 位置仍有效，
			# 習得後穩定；換老闆的 stale 賣單由 order staleness + harvest 濾 outpost_level>0 處理，非清 known）。
			var demo_tid: int = tile.tile_pos.x * 1000 + tile.tile_pos.y
			for tmk in state.team_market_known.values():
				(tmk as Dictionary).erase(demo_tid)
			for fac_name in FACILITY_DEF:
				tile.set(FACILITY_DEF[fac_name]["current_level_key"], 0)
			tile.stable_progress = 0.0
			tile.garrison.clear()
			tile.prisoners.clear()
			# ★★★市集看板隨宿主一起消失（族④ #6，2026-09-02）：
			#   ★病：outpost 拆掉了而 `tile.market_orders` 還留著 ⇒ 隊站上去 `read_market_board`
			#     （order_system:238）會讀到【一個不存在的市集】的單 ＝ dangling state
			#   ★★這不是設計選擇，是結構問題：宿主沒了，看板不該還在
			#   ★★★而【易主】那一半（capture）★不在本票：看板是隨 outpost 轉手的設施、
			#     還是舊主該清的私產 ＝ WHAT，systems 已去問 blueprint ⇒ 這裡不替它選。
			# ★entry counter：沒有它，「dangling = 0」與「根本沒拆過」長得一模一樣（母體塌陷）
			if Probe.enabled:
				Probe.bump("demolish.completed")
				Probe.add_amount("demolish.market_orders_cleared", float(tile.market_orders.size()))
			tile.market_orders.clear()
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
	if not _can_afford(team, tile, cost, "start_build"):
		push_warning("[Outpost] start_build: 資源不足")
		return false
	_deduct_cost(team, tile, cost)
	tile.construction_team_id   = team.team_id
	tile.construction_ticks_left = build_person_hours(type, level)
	tile.construction_target    = { "action": "build", "type": type, "level": level }
	tile.construction_started_tick = state.world.current_tick
	tile.construction_last_progress_tick = state.world.current_tick
	TaskArbiter.transition(state, team, "建設", TaskArbiter.PRIO_DISPATCH)
	_tap_build_start(state, team, tile, "build")
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
	if not _can_afford(team, tile, cost, "upgrade_level"):
		return false
	_deduct_cost(team, tile, cost)
	tile.construction_team_id   = team.team_id
	tile.construction_ticks_left = build_person_hours(tile.outpost_type, new_level)
	tile.construction_target    = { "action": "upgrade_level", "level": new_level }
	tile.construction_started_tick = state.world.current_tick
	tile.construction_last_progress_tick = state.world.current_tick
	TaskArbiter.transition(state, team, "建設", TaskArbiter.PRIO_DISPATCH)
	_tap_build_start(state, team, tile, "upgrade_level")
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
	return _begin_facility_construction(state, team, tile, facility)

func start_upgrade_farming(state: WorldState, team: TeamData) -> bool:
	return start_upgrade_facility(state, team, "farming")

func start_upgrade_manufacturing(state: WorldState, team: TeamData) -> bool:
	return start_upgrade_facility(state, team, "workshop")

# 共用 gate + 扣款 + 排程（呼叫端先驗 owner/faction 與 construction 空檔）
func _begin_facility_construction(state: WorldState, team: TeamData, tile: HexTileData, facility: String) -> bool:
	# ★同上：六條拒絕逐一具名 ＋ 標【物理 vs 判斷】（★這一層才是真正的拒絕大宗）
	var _wday2: String = ".day.%03d" % int(state.world.current_tick / WorldState.TICKS_PER_DAY)
	if Probe.enabled: Probe.bump_pt("wall.begin_entry", _wday2, team.team_id)
	if not FACILITY_DEF.has(facility):
		if Probe.enabled: Probe.bump_pt("wall.reject_no_def", _wday2, team.team_id)            # 物理：沒這種設施
		return false
	var def: Dictionary = FACILITY_DEF[facility]
	if not (tile.outpost_type in def["allowed_outpost"]):
		if Probe.enabled: Probe.bump_pt("wall.reject_outpost_type", _wday2, team.team_id)      # 物理：據點型別不合
		return false
	if def.has("required_terrain") and tile.terrain != def["required_terrain"]:
		if Probe.enabled: Probe.bump_pt("wall.reject_terrain", _wday2, team.team_id)           # 物理：地形不合
		return false
	var cur: int = int(tile.get(def["current_level_key"]))
	if cur >= 3:
		if Probe.enabled: Probe.bump_pt("wall.reject_max_level", _wday2, team.team_id)         # 物理：已滿級
		return false
	if cur == 0 and slots_used(tile) >= slot_cap(tile):
		if Probe.enabled:
			Probe.bump_pt("wall.reject_no_slot", _wday2, team.team_id)                         # ★★物理？還是判斷？slot_cap 是設計上限
			Probe.bump("wall.reject_no_slot.used_%d_cap_%d" % [slots_used(tile), slot_cap(tile)])
		return false   # 新設施要空 slot；升級不佔
	var cost: Dictionary = upgrade_cost(facility, cur + 1)
	if not _can_afford(team, tile, cost, "wall"):
		if Probe.enabled:
			Probe.bump_pt("wall.reject_cannot_afford", _wday2, team.team_id)                   # 物理：付不起（1.0×，非緩衝）
			for _ck in cost:
				if String(_ck) != "person_hours":
					Probe.bump("wall.reject_cannot_afford.res." + String(_ck))
		return false
	_deduct_cost(team, tile, cost)
	tile.construction_team_id   = team.team_id
	# ★寫入點直接讀入口（常駐閘要求）：走 cost["person_hours"] 雖然也同源（upgrade_cost 呼叫入口），
	#   ★★但那是【間接】——閘看不見，而下一個人也看不見。寫入點自己說出來源，才守得住。
	tile.construction_ticks_left = build_person_hours(facility, cur + 1)
	tile.construction_target    = { "action": "upgrade_facility", "facility": facility }
	TaskArbiter.transition(state, team, TeamData.TASK_BUILD, TaskArbiter.PRIO_DISPATCH)
	_tap_build_start(state, team, tile, "upgrade_facility")
	if Probe.enabled:
		Probe.bump("village.build_fired")   # ★復甦 R2 §6 tap（驗執行端：村端建設真 fire、料到→蓋）
		Probe.bump_pt("wall.accepted", _wday2, team.team_id)   # ★成功端：沒有它，九條拒絕加不回 begin_entry
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
	tile.construction_ticks_left = build_person_hours(tile.outpost_type, tile.outpost_level) / 2
	tile.construction_target    = { "action": "demolish" }
	TaskArbiter.transition(state, team, "建設", TaskArbiter.PRIO_DISPATCH)
	_tap_build_start(state, team, tile, "demolish")
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

# ★持守統一 Slice 2：工地總 person-ticks（重建自 construction_target，鏡射 construction_cost_of）。
# persist_strength 真 construction-tick progress 用（sunk = (total-left)/total）。純讀零 mutation。
static func construction_ticks_total(tile: HexTileData) -> int:
	var action: String = str(tile.construction_target.get("action", ""))
	match action:
		"build":
			return build_person_hours(str(tile.construction_target["type"]), int(tile.construction_target["level"]))
		"upgrade_level":
			return build_person_hours(tile.outpost_type, int(tile.construction_target["level"]))
		"upgrade_facility":
			var fac: String = str(tile.construction_target.get("facility", ""))
			if FACILITY_DEF.has(fac):
				var c: Dictionary = upgrade_cost(fac, int(tile.get(FACILITY_DEF[fac]["current_level_key"])) + 1)
				return int(c.get("person_hours", 0))
		"demolish":
			if tile.outpost_level > 0:
				return build_person_hours(tile.outpost_type, tile.outpost_level) / 2
		"crude_camp":
			# ★紮根(faction_ai)與玩家紮營都叫 crude_camp 但工期不同 ⇒ 讀起工時記下的實付工量。
			#   ★★改制前這裡沒有分支 ⇒ 兩者都回 0 ⇒ persist_strength/commitment 的 sunk 恆 0（既有 bug）。
			return int(tile.construction_target.get("person_hours", 0))
	return 0

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
	var _timeout_ticks: int = int(round(construction_timeout_days(tile) * float(WorldState.TICKS_PER_DAY)))
	if state.world.current_tick - tile.construction_last_progress_tick <= _timeout_ticks:
		return false
	# ★timeout cancel tap（純觀測）：工地逾時取消（stall 未被召回→逾時=一階/二階失效證）。
	if Probe.enabled:
		Probe.bump("construct.timeout_cancel")
		Probe.bump_sample("construct.timeout_cancel", {
			"tick": state.world.current_tick, "tile": [tile.tile_pos.x, tile.tile_pos.y],
			"ct_id": tile.construction_team_id,
			"stall_ticks": state.world.current_tick - tile.construction_last_progress_tick,
		})
	var ct: TeamData = state.teams.get(tile.construction_team_id)
	var cost: Dictionary = construction_cost_of(tile)
	if ct != null:
		for k in cost:
			if k == "person_hours": continue
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
	if not _can_afford(team, tile, cost, "subteam_upgrade"):
		return false
	_deduct_cost(team, tile, cost)
	tile.construction_team_id   = team.team_id
	tile.construction_ticks_left = build_person_hours(tile.outpost_type, target_level)
	tile.construction_target    = { "action": "upgrade_level", "level": target_level }
	tile.construction_started_tick = state.world.current_tick
	tile.construction_last_progress_tick = state.world.current_tick
	TaskArbiter.transition(state, team, TeamData.TASK_BUILD, TaskArbiter.PRIO_DISPATCH)
	_tap_build_start(state, team, tile, "upgrade_level")
	print("[Outpost] 子隊 Team%d 開始升級 → Lv%d at (%d,%d)" % [
		team.team_id, target_level, tile.tile_pos.x, tile.tile_pos.y])
	return true

func _subteam_upgrade_facility(state: WorldState, team: TeamData, tile: HexTileData, facility: String) -> bool:
	# ★★★這面牆的拒絕理由（systems 派 2026-08-26，第七顆）：
	#   infra path 每輪選好設施、去就地開工，而【180/336（53.6%）被這裡拒絕】，
	#   ★而整段原本是裸 `return false`，零 counter ⇒ 讀 code 時看起來像交接，量出來是牆。
	#   ★★每一條都標【物理 vs 判斷】：物理＝真的做不到（沒地方、沒料、型別不合）；
	#     ★★★判斷＝「覺得不划算／時機不對」⇒ 那是決策，不該藏在裸 return false 裡（照妖鏡判準）。
	#   ★壞掉會長什麼樣：只數「被拒幾次」而不分類 ⇒ 一個【該由人格秤的決策】會被當成物理限制接受，
	#     而它會永遠擋著同一批隊（latch），沒有人會去看它。
	var _wday: String = ".day.%03d" % int(state.world.current_tick / WorldState.TICKS_PER_DAY)
	if Probe.enabled: Probe.bump_pt("wall.entry", _wday, team.team_id)
	if tile.outpost_level == 0:
		if Probe.enabled: Probe.bump_pt("wall.reject_outpost_level0", _wday, team.team_id)   # 物理：沒有據點可擴建
		return false
	if not _faction_owns(state, team, tile):
		if Probe.enabled: Probe.bump_pt("wall.reject_not_owner", _wday, team.team_id)        # 物理：不是自己的地
		return false
	if tile.construction_team_id != -1:
		if Probe.enabled: Probe.bump_pt("wall.reject_busy_construction", _wday, team.team_id)  # 物理：一格一次只能蓋一件
		return false
	return _begin_facility_construction(state, team, tile, facility)

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
	tile.construction_ticks_left = build_person_hours(tile.outpost_type, tile.outpost_level) / 2
	tile.construction_target    = { "action": "demolish" }
	TaskArbiter.transition(state, team, TeamData.TASK_BUILD, TaskArbiter.PRIO_DISPATCH)
	_tap_build_start(state, team, tile, "demolish")
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
# ★★★`afford.short.<site>.<res>` tap（systems 派 2026-08-26 / slice afford-short-res）：
#   ★問題：`wall.reject_cannot_afford` 降到 64 了，但我們不知道那 64 次【缺的是什麼】。
#     舊欄位 `wall.reject_cannot_afford.res.*` 對該次 cost 的【每一個】res 都 bump
#     ⇒ 它記的是「這次成本包含哪些資源」，不是「缺哪一個」（material 180／tools 180 同數就是證據）。
#   ★修：在【失敗分支之內】bump —— 那是 `return false` 之前的最後一個判斷
#     ⇒ 記到的必然是【真正讓這次失敗的那一個】。
#
# ★★★壞掉會長什麼樣（★這段是本 tap 的護欄，別刪）：
#   ①若有人把 bump 挪到迴圈外、或改成對每個 res 都 bump ⇒ 它退回成「cost 含哪些 res」，
#     ★而數字看起來一樣合理（每格都有值、總和也像樣）——沒有任何症狀會提醒你它壞了。
#   ②若有人拿掉 `site` 只留 `afford.short.<res>` ⇒ ★★五個呼叫點的數字會被混在一起
#     （start_build／start_upgrade_level／_begin_facility_construction／_subteam_upgrade_level／
#      faction_ai_system:4705 的 self-rescue 候選檢查）
#     ⇒ ★★★`afford.short.wall.* 加總 == wall.reject_cannot_afford` 這條對帳式當場變假，
#       而它是這顆 tap 唯一的驗收判準。★能對帳的是 `wall` 那一族，不是全部。
func _can_afford(team: TeamData, tile: HexTileData, cost: Dictionary, site: String = "other") -> bool:
	for res in cost:
		if res == "person_hours":
			continue
		var avail: float = float(tile.public_storage.get(res, 0)) \
			+ float(team.resources.get(res, 0))
		if avail < float(cost.get(res, 0)):
			# ★就在這裡、就是這個 res —— 迴圈內、return 前，一次失敗只記一顆。
			if Probe.enabled: Probe.bump("afford.short.%s.%s" % [site, String(res)])
			return false
	return true

func _deduct_cost(team: TeamData, tile: HexTileData, cost: Dictionary) -> void:
	for res in cost:
		if res == "person_hours":
			continue
		var need: float = float(cost.get(res, 0))
		if need <= 0.0:
			continue
		var from_vault: float = TileBank.withdraw(tile, res, need, "construction_pay_vault")
		var rem: float = need - from_vault
		if rem > 0.0:
			ResourceBank.remove(team, res, rem, "construction_pay")
