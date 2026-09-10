class_name FacilityExistenceIndex

# ★★★「這支隊【有沒有】某個製造設施」的聚合索引（HOW spec 2026-09-10）。
#
# ★病（量出來的，不是推論）：`NeedOracle._team_has_facility` 每次都 `for tid in state.world.tiles`
#   ⇒ 194190 次 × 平均 631 格 ≈ **1.23 億次 tile 訪問** ＝ 牆鐘的 83% 那一塊的 99.4%，
#   而它答的是一個**只跟自家據點有關**的問題。
#
# ★★語意（為什麼聚合是精確的）：這支謂詞是**存在量詞**——
#   「有沒有【任何一個】自家據點的該設施 > 0」⇒ ★聚合 owner → {level_key: true} **逐字相同**，
#   ★★即使一隊有多個據點也一樣（★★★這正好是它與 `own_outpost_tile` 的差別：
#     那支要回「哪一個 tile」⇒ 依賴迭代序；本支只回 true/false ⇒ 不依賴）。
#
# ★★★失效（照 R² 的裁定：**接既有的，不自己列一份**）：
#   共用 `OwnerOutpostIndex.epoch` —— 它的三個 chokepoint 已涵蓋
#     ①owner 真變 ②`outpost_level` 跨 0（含 demolish）③`erase_teams` 死亡釋放（繞過 bank 的那條）
#   ★而本索引【只加一條】：**設施子欄位的寫入點**（設施 0→1 不動 owner、也不讓 outpost_level 跨 0）
#     ⇒ 裸掃列出的 production 寫入點只有三處，全部呼 `invalidate()`：
#       `outpost_system.gd:467`（設施完工 +1）／`:507`（拆除據點時各設施歸零）／`:763`（拆單一設施）
#     ⇒ ★★漏一個，索引會**安靜地給舊答案** —— 所以 shadow 對照是本票的驗收第一格。
#   ★debug/床若直寫 `tile.farming_level = N` 而不 invalidate ⇒ 同樣會 stale
#     ⇒ ★★★而那不是「小心一點」能解決的 ⇒ 由 `shadow` 對照在床上把它抓出來。
static var epoch: int = 1

static var shadow: bool = false        # 影子對照（debug 用；production 恆 false ＝ 一個 bool 判斷）
static var shadow_checks: int = 0
static var shadow_fails: int = 0
static var legacy_visits: int = 0      # 舊全圖掃的 tile 訪問次數（只在 shadow 路徑累加）
static var short_circuit: bool = true  # ★成對對照用：關掉它 ⇒ 成本必須回到現況量級

static func invalidate() -> void:
	epoch += 1

static func shadow_reset() -> void:
	shadow_checks = 0
	shadow_fails = 0
	legacy_visits = 0

static func _reset_cross_run() -> Dictionary:
	var cleared: Dictionary = {}
	if shadow_checks != 0 or shadow_fails != 0 or legacy_visits != 0:
		cleared["FacilityExistenceIndex.counters"] = "%d/%d/%d" % [shadow_checks, shadow_fails, legacy_visits]
	shadow_reset()
	invalidate()   # ★推版號而非歸零（同 OwnerOutpostIndex 的理由：單調性保住，新舊 state 都必重建）
	return {"checked": 3, "cleared": cleared}

# 舊實作（★保留為【具名對照】：沒有名字的舊判定會被下一個人當重複邏輯刪掉，而對照消失不會有任何一格紅）
static func legacy_has(state: WorldState, team_id: int, level_key: String) -> bool:
	for tid in state.world.tiles:
		var tile: HexTileData = state.world.tiles[tid]
		legacy_visits += 1
		if tile.outpost_owner == team_id and tile.outpost_level > 0 and int(tile.get(level_key)) > 0:
			return true
	return false
