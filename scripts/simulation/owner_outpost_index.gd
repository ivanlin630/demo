class_name OwnerOutpostIndex

# ★效能 arc B（重定靶縮小版）：owner → 自家據點 tile 的索引，用來取代 `for tile_id in state.world.tiles`
# 全圖掃（`_find_own_outpost` 12 個 production 呼點 + `_faction_roster_pos` 的 inline 第二處）。
#
# ★等價語意（HOW spec §3，byte-identical 硬要求）：
#   現行語意 = 「state.world.tiles 迭代順序中的第一個 outpost_level>0 且 outpost_owner==X 的 tile」。
#   一隊多據點時回哪個 **取決於 tiles 的插入序**，索引必須重現同一個選擇：
#   → 表由 WorldState._rebuild_owner_outpost() **依 world.tiles 迭代序**整表重建、每個 owner 只留第一個命中。
#   → 禁「最近設定的 / 距離最近的」這類更聰明但不同的語意（那是行為改動，要另開 intended-change slice）。
#
# ★失效策略 = epoch 版號 + lazy 整表重建（不做增量 patch）：
#   增量 patch 的風險正是 spec §3 點名的「後設 owner 蓋掉迭代序更前者」；整表重建天然免疫，
#   且重建成本 O(tiles) 只在「所有權/等級跨 0 真的變了之後的第一次查詢」付一次，
#   而非每個呼點每次都掃。WorldState 各自記 _oo_epoch，多 state 並存也各自正確（最壞只是多重建）。
#
# chokepoint（呼 invalidate()）：
#   ① OutpostOwnerBank.set_owner（owner 真的變了才呼）
#   ② outpost_level 跨 0：完工 build / crude_camp（0→>0）、demolish（>0→0）、GameSetup 初始佈點
#   ③ WorldState.erase_teams 的死亡釋放（直接寫 outpost_owner=-1，繞過 bank）
static var epoch: int = 1

# 影子對照開關（gate①）：debug bed 開啟後，每次查詢都同時跑舊全圖掃並 assert 相等。
# production 預設 false＝單一 static bool 判斷，零行為零 RNG。
static var shadow: bool = false
static var shadow_checks: int = 0
static var shadow_fails: int = 0
# 舊掃的 tile 訪問次數（只在 legacy 基準掃裡累加＝debug 路徑；用來把「省下的工」量成真實 visits 而非猜滿掃）
static var legacy_visits: int = 0

static func invalidate() -> void:
	epoch += 1

static func shadow_reset() -> void:
	shadow_checks = 0
	shadow_fails = 0
	legacy_visits = 0

# 影子對照：expect（舊全圖掃結果）vs got（索引結果）不等即印 team/tile 並記 FAIL。
static func shadow_check(tag: String, team_id: int, expect: Vector2i, got: Vector2i) -> void:
	shadow_checks += 1
	if expect != got:
		shadow_fails += 1
		print("[ShadowFAIL] %s team=%d legacy=(%d,%d) index=(%d,%d)" % [
			tag, team_id, expect.x, expect.y, got.x, got.y])
