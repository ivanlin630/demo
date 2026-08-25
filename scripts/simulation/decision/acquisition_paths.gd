class_name AcquisitionPaths

# ★脊椎第二磚：means-end「拆得開」——【目標 → 前置依賴 → 行動】。
#   本檔【只產生候選路徑，不做決定】：誰划算由折現磚比，argmax 由決策層選。
#
# ★★三條紀律（systems 裁 2026-08-25）：
#   ①「誰產 X」一律查【真相源】`ManufacturingSystem.RECIPE_GROUPS`，⛔不建「資源→生產者」對照表
#     （那正是 A 型手抄表的病）。反查索引【即時建】，不落成第二份真相。
#   ②遞迴【沒有深度常數】：每多一層就多一段 delay，折現 δ^delay 讓超出視野的路徑自然趨零。
#     ⇒ 停止條件是「值低到不值得再想」，不是我拍的層數。
#   ③★「無手段可取得」【不得靜默終止】——必發 tap 且帶【是哪個資源】。
#     理由：那是最容易誤判的分支，而它的症狀是「什麼都沒發生」⇒ 沒 tap ＝ 製造量測盲點。
#
# ★★★形狀 ≠ 手段（systems 裁）：別列舉手段（列舉又是一張手工表），要問【形狀】。
#   rate（流）  ⇒ 「量 ÷ 率 ＝ 多久湊到」
#   stock（存量）⇒ 「存量比較，且採完就沒」
#   ⛔ `DiscountedFlow.flow_utility` 叫 flow —— **存量不是 flow**，拿流的尺量 stock 會系統性算錯，
#      而且錯成一個【看起來正常的數字】。⇒ 本檔把 stock 標出來走不同分支，flow_utility 的 stock 語意另票。
#
# ⏸ 手段模型（總共幾條、怎麼分類）**尚未定案**：systems 正送 reviewer delta R²。
#    本檔先實作【製造】這一條（配方真相源已在手），其餘手段的接線待該裁定。

# ★反查索引：out → [{ facility_key, inputs, rate_const }]。★即時由真相源建，不快取成第二份表。
static func producers_of(res: String) -> Array:
	var out: Array = []
	for facility_key in ManufacturingSystem.RECIPE_GROUPS:
		for recipe in (ManufacturingSystem.RECIPE_GROUPS[facility_key] as Array):
			if String(recipe.get("out", "")) == res:
				out.append({
					"facility_key": String(facility_key),
					"inputs": (recipe.get("in", {}) as Dictionary),
					"rate_const": String(recipe.get("rate_const", "")),
				})
	return out

# ★★資源的【形狀】—— 決定「夠不夠」要怎麼問（systems 裁 2026-08-25）。
#   rate（流）   ⇒ 量 ÷ 率 ＝ 多久湊到
#   stock（存量）⇒ 存量比較，且【採完就沒】
#   ⛔ 拿流的尺量存量 ＝ 系統性【高估】且不對稱（只會高估或打平，不會低估）
#      ⇒ 本磚對 stock【不做價值比較】，只回報「有此手段 + 形狀 + tap」。
#      ★寧可缺一個數字，不要一個錯的數字 —— 錯的會被下游當真，缺的不會。
#
# ★三段判定，能導的先導、導不出來的才查表：
#   ①`RECIPE_GROUPS` 的 out  ⇒ manufactured（真相源導出）
#   ②`REGEN_RATE` 有正產出   ⇒ rate（真相源導出）
#   ③其餘 ⇒ 查下表。★這張表【准留】的唯一理由是它配了機械 falsifier
#     （`resource_shape_falsifier.gd`：掃 driver_ledger 裡所有 delta>0 的 (資源,reason)，
#      出現未分類組合就紅）——★判準是「這張表變錯的時候，誰會發現？」有機械答案才准留表。
const SHAPE_TABLE: Dictionary = {
	"ore_iron":  "stock",         # world_generator 初始鋪設；resource_system:347 明寫「ore/gem 有限」
	"ore_gold":  "stock",
	"ore_silver": "stock",
	"gem":       "stock",
	"herb":        "capped_regen",  # harvest_system:_regen_herb，受 resource_cap 限（★不在 REGEN_RATE）
	"wild_game":   "capped_regen",  # harvest_system:_regen_wild_game
	"wild_horses": "capped_regen",  # harvest_system:_regen_wild_horses
	"horses":    "loot_or_collect", # harvest_horse_store + encounter loot_horses_out（★存 public_storage 不是 resources）
	"mounts":    "loot_or_collect",
	"coin":      "trade_only",      # 鑄幣/交易，不從地裡長
	# ★falsifier 第一次跑就拓到這顆（未分類）——它走 TileBank 所以 kind=resource，
	#   但它【不是可取得物】而是地格上的猛獸數。明寫出來，不靠「沒人會想去採它」這種默認。
	"predator_density": "not_acquirable",   # 地格威脅計數（regen_predator），靜待量非取得目標
}

static func shape_of(res: String) -> String:
	if not producers_of(res).is_empty():
		return "manufactured"
	for tn in ResourceSystem.REGEN_RATE:
		if float((ResourceSystem.REGEN_RATE[tn] as Dictionary).get(res, 0.0)) > 0.0:
			return "rate"
	return String(SHAPE_TABLE.get(res, "unknown"))

# ★stock 形狀的資源：回報【有這條手段】與【形狀】，但不算價值。
static func stock_sources(state: WorldState, team: TeamData, res: String) -> Array:
	var out: Array = []
	if state == null or team == null:
		return out
	for tid in state.world.tiles:   # gate-ok: 地理/礦脈=公共知識（同 find_nearest_terrain_tile 先例）
		var t: HexTileData = state.world.tiles[tid]
		if t == null:
			continue
		# ★兩個位置都要看：`horses` 在 public_storage 不在 resources
		#   ⇒ 只查 resources 的 means-end 會對它永遠回「無手段」而靜默終止。
		var amt: float = float(t.resources.get(res, 0)) + float(t.public_storage.get(res, 0))
		if amt <= 0.0:
			continue
		out.append({"means": "harvest_stock", "res": res, "shape": "stock",
			"pos": t.tile_pos, "amount": amt,
			"blocked_on": "", "kind": "stock_site",
			"value_compared": false})   # ★明示：本票不對 stock 做價值比較
	return out

# ★「製造」這條手段的候選路徑：回傳每條路徑【卡在哪一格】（blocked_on）。
#   ★缺設施 與 缺原料 必須分得開 —— 兩者的解法相反（蓋工坊 vs 去採料）。
#   `blocked_on` == "" ⇒ 前置全滿，可以直接產。
static func for_resource(state: WorldState, team: TeamData, res: String,
		_visited: Dictionary = {}) -> Array:
	if state == null or team == null or res == "":
		return []
	# ★環偵測：A 需要 B、B 需要 A ⇒ 必須終止，且【不得靜默】。
	if _visited.has(res):
		if Probe.enabled:
			Probe.bump("means_end.cycle_detected")
			Probe.bump_sample("means_end.cycle_detected", {"res": res,
				"chain": str(_visited.keys()), "team": team.team_id}, 20)
		return []
	_visited[res] = true

	var paths: Array = []
	var tile: HexTileData = state.world.tiles.get(team.tile_pos.x * 1000 + team.tile_pos.y)
	for prod in producers_of(res):
		var fk: String = String(prod["facility_key"])
		var lvl: int = int(tile.get(fk)) if tile != null else 0
		if lvl <= 0:
			# ★缺【設施】：下一步是蓋它，不是去採料。
			paths.append({"means": "manufacture", "res": res, "blocked_on": fk,
				"kind": "facility", "depth": _visited.size()})
			continue
		# 有設施 ⇒ 逐項原料檢查（缺哪一項就指向哪一項，並可再往下遞迴）
		var lacking: Array = []
		for inp in (prod["inputs"] as Dictionary):
			var need: float = float(prod["inputs"][inp])
			if float(team.resources.get(inp, 0)) < need:
				lacking.append(String(inp))
		if lacking.is_empty():
			# ★【多久湊得到】問產線自己（`ManufacturingSystem.daily_output`），
			#   ⛔不在這裡寫 `var rate := 3.0  # GOODS_RATE` —— 那是手抄物理。
			#   ★這是 rate（流）形狀：量 ÷ 率 ＝ 多久，與 stock 形狀走不同分支。
			paths.append({"means": "manufacture", "res": res, "blocked_on": "",
				"kind": "ready", "shape": "rate", "depth": _visited.size(),
				"gain_daily": ManufacturingSystem.daily_output(state, team, tile, fk, res),
				"value_compared": true})
			continue
		for miss in lacking:
			paths.append({"means": "manufacture", "res": res, "blocked_on": miss,
				"kind": "material", "depth": _visited.size()})
			# ★遞迴：缺的原料本身也可能是可製造的（`ore_steel` 同時是 out 與 in ⇒ 鏈深 ≥3 是資料逼出來的）
			for sub in for_resource(state, team, miss, _visited):
				paths.append(sub)
	if paths.is_empty() and Probe.enabled:
		# ★★「無手段可取得」不得靜默（invariants 2026-08-25）
		Probe.bump("means_end.no_means")
		Probe.bump("means_end.no_means." + res)
	return paths
