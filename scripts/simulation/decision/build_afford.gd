class_name BuildAfford

# ★建造前的【付得起嗎】判斷 —— 三處同形碼收斂成這一個（systems 裁 2026-08-26）。
#   收斂前：`_dispatch_builder:3823`／`_dispatch_upgrader:3941`／`_dispatch_facility_builder:4249`
#   各自寫 `avail < cost[k] * 1.5`，★三份會各自漂移，而漏斗量到 39/39 全卡在其中一道。
#
# ★★人格化的是【緩衝】不是【成本】：`1.5` 原本是全域死常數 —— 一個「要留多少餘量才敢動工」的
#   判斷，那本來就是人格的事（慎重的領袖厚、大膽的薄），不該是所有領袖共用一個數。
#   ⇒ 形狀照既有照妖鏡家族（`DiscountedFlow.delta_of`／`TradeValuation._reserve_factor`）：
#     **連續調變 ＋ 少量具名 TEST VALUE 常數 ＋ clamp 上下界**，★不是零常數、也不是裸魔數。
#
# ★★★anti-crank 鐵律（systems 寫死）：**中性人格必須拿到【剛好 1.5】，零漂。**
#   中性一旦不是 1.5，這票就從「人格化」變成「偷偷調數值」，而後者要走 blueprint。
#   ⇒ 下面的式子以 1.5 為【中性點】，人格只在它兩側移動。

const MARGIN_NEUTRAL: float = 1.5   # TEST VALUE — 中性領袖的建造緩衝（★＝收斂前的全域值，零漂錨點）
const MARGIN_CAUTION_K: float = 0.6 # TEST VALUE — 慎重斜率（慎重 1.0 → 緩衝厚；鏡射 RESERVE_HOARD_K 的角色）
const MARGIN_DARING_K: float = 0.4  # TEST VALUE — 膽大斜率（好戰/野心 → 敢用薄緩衝動工）
const MARGIN_MIN: float = 1.0       # TEST VALUE — 下界＝剛好付得起（★再低就是舉債動工，本票不開那條路）
const MARGIN_MAX: float = 2.0       # TEST VALUE — 上界＝最保守領袖的緩衝

# ★緩衝倍率：中性 0.5/0.5 → 逐位元 1.5。
#   慎重↑ → 厚（撐更久才敢動工）；好戰/野心↑ → 薄（敢賭）。★兩邊都是連續的，沒有門檻跳變。
static func margin_of(leader_values: Dictionary) -> float:
	var caution: float = float(leader_values.get("慎重", 0.5))
	var daring: float = maxf(float(leader_values.get("好戰", 0.5)), float(leader_values.get("野心", 0.5)))
	var m: float = MARGIN_NEUTRAL \
		+ (caution - 0.5) * MARGIN_CAUTION_K \
		- (daring - 0.5) * MARGIN_DARING_K
	return clampf(m, MARGIN_MIN, MARGIN_MAX)

# ★★★三處共用的那道閘本體。★測試必須呼叫【這一支】——
#   在測試裡自己重寫 `avail < cost * margin` 再斷言，驗的是測試抄的公式、不是這道閘。
#   pools ＝ 依序疊加的可用池（公庫、私產…），★由呼叫端決定有哪些池，本函式不猜。
static func can_afford(cost: Dictionary, pools: Array, leader_values: Dictionary) -> bool:
	var margin: float = margin_of(leader_values)
	for k in cost:
		if k == "ticks":
			continue
		var avail: float = 0.0
		for p in pools:
			avail += float((p as Dictionary).get(k, 0))
		if avail < float(cost[k]) * margin:
			return false
	return true

# ★短缺明細（給既有的 depletion tap 用；★純讀，不做判斷）：回第一個不足的資源與數字。
static func shortfall(cost: Dictionary, pools: Array, leader_values: Dictionary) -> Dictionary:
	var margin: float = margin_of(leader_values)
	for k in cost:
		if k == "ticks":
			continue
		var avail: float = 0.0
		for p in pools:
			avail += float((p as Dictionary).get(k, 0))
		if avail < float(cost[k]) * margin:
			return {"res": String(k), "need": float(cost[k]) * margin, "avail": avail, "margin": margin}
	return {}
