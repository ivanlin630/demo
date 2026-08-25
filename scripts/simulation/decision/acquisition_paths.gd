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
			paths.append({"means": "manufacture", "res": res, "blocked_on": "",
				"kind": "ready", "depth": _visited.size()})
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
