class_name DiscountedFlow

# ★決策模型 v2 §4【延遲價值折現原語】——脊椎第一磚（用戶兩輪深化裁定、2026-08-21）。
#
# ★病（實測）：舊 `camp_marginal` 拿「假想覓食吃得飽」當替代方案（`forage_floor 4.80 == daily_need 4.80`）
#   ⇒ 紮營的邊際被整份口糧吃掉、`camp_u` 天花板 0.826，永遠打不過帶 survival boost 的覓食/買糧（3.2+）。
#   更深一層：模型比的是【兩個今天的流量】，未來完全不在秤上 ⇒「一直覓食」被當成免費替代 ⇒ 數學上永遠選「苟」。
#
# ★本磚的語彙【要能被後面的磚繼承】（means-end 依賴圖／承諾泛化都會疊上來）：
#   value(option) = Σ_{t=1..H_eff} flow(t)·δ^t − cost      （PV：折現未來收益流）
#   baseline      = 【真實現狀】的同式折現（★真實被動所得，不是假想的覓食餬口）
#   utility      ∝ value − baseline
#   ⇒ 禁為單一 option 造一次性公式。
#
# ★★兩條蟑螂地板（用戶定、不可妥協；缺一不可）：
#   ①`δ ≥ DELTA_FLOOR`：防人格把視野折成 0。
#   ②`H_eff` 對「會改善被動收入的 option」★不得由【執行前】存糧決定——否則同一個 catch-22 換一層：
#     沒紮營→沒被動收入→存糧低→H_eff 小→紮營不划算→沒紮營。
#     （R² 必查項；★gate 3a 的人格極端測試抓不到它，因為它不是人格驅動的。）

const HORIZON_DAYS: float = MarginalEconomy.PLANNING_HORIZON_DAYS   # 90，沿用既驗常數（不新增）
const DELTA_FLOOR: float = 0.90     # TEST VALUE — 蟑螂地板①：最短視人格也不得低於此
const DELTA_CAP: float = 0.99       # TEST VALUE — 最有耐性人格的上限（避免 1.0 的無窮視野）
# ★δ ＝【耐性／慎重】族，★不是貪婪（用戶明確修正：貪婪≠短視；貪婪調的是「在意哪種明天」）。
static func delta_of(values: Dictionary) -> float:
	var patience: float = clampf(float(values.get("慎重", 0.5)), 0.0, 1.0)
	return clampf(DELTA_FLOOR + (DELTA_CAP - DELTA_FLOOR) * patience, DELTA_FLOOR, DELTA_CAP)

# ★w_k ＝「在意哪種明天」：人格對【流的種類】加權，不對「有沒有明天」動手。
static func flow_weight(kind: String, values: Dictionary) -> float:
	match kind:
		"food":   return 1.0                                                    # 活命流：不受人格折扣
		"wealth": return 0.5 + float(values.get("貪婪", 0.5))                    # 財流：貪婪愛錢 → 折得少
		"power":  return 0.5 + float(values.get("野心", 0.5))                    # 權勢流
		"might":  return 0.5 + float(values.get("好戰", 0.5))                    # 軍力流
		_:        return 1.0

# ★H_eff：survival-bounded 有效視野。沿用 facility_roi 的既驗形狀（赤字→殘存活窗、轉正→full horizon），
# ★但用【執行後】的淨流算殘存活窗（R² 必查項）：這個動作把流血速度變慢，本身就延長了視野。
#   例：淨流 −4.8/日 → −0.8/日 ⇒ runway 6 倍 ⇒ H_eff 跟著 6 倍（而不是仍舊 ≈0）。
static func horizon_eff(post_action_net_flow: float, food_stock: float) -> float:
	if post_action_net_flow >= 0.0:
		return HORIZON_DAYS
	var runway: float = food_stock / maxf(-post_action_net_flow, 0.001)
	return clampf(runway, 0.0, HORIZON_DAYS)

# PV：Σ_{t=1..H} flow·δ^t ＝ flow·δ(1−δ^H)/(1−δ)。flow 為日流量、H 為天數。
static func pv(daily_flow: float, delta: float, horizon: float) -> float:
	if horizon <= 0.0 or daily_flow == 0.0:
		return 0.0
	var d: float = clampf(delta, DELTA_FLOOR, DELTA_CAP)
	return daily_flow * d * (1.0 - pow(d, horizon)) / maxf(1.0 - d, 0.0001)

# ★option 的折現淨值：未來流現值 − 現狀基準線現值 − 成本。
# baseline_daily ＝【真實】被動所得（無據點無營地 ⇒ 0），★不是假想的覓食餬口。
static func option_value(gain_daily: float, baseline_daily: float, cost: float,
		delta: float, horizon: float) -> float:
	return pv(gain_daily, delta, horizon) - pv(baseline_daily, delta, horizon) - cost

# ★四選項同尺的【唯一】入口（撿／投／紮／覓食-遷移都呼這個；禁各自再造一份正規化）。
# 問的是同一件事：「選它之後我未來拿得到多少食物流」。
#   gain_daily     ＝ 選了它之後的【真實】被動/採集日流
#   baseline_daily ＝ 不選它的現狀真實所得（無據點無營地 ⇒ 0）
#   delay_days     ＝ 這個流要等多久才接上（投靠/佔村＝現成 0；紮營/建設＝工期）——折現天然懲罰等待
# ★正規化＝【同一段視野、同一個 δ】的口糧現值（實測病修正 2026-08-21）：
#   value 是整段視野的現值（PV，最長 90 天 ⇒ δ-sum ≈17 天份），若拿固定「N 天口糧」當分母，
#   任何 gain ≥ need 的 option 都會衝破 cap ⇒ 四選項並列封頂、順序資訊全毀（實測 紮營/併入 同時 1.5）。
#   分母改用 pv(daily_need,…) ⇒ utility ＝「這個選項相當於幾倍餬口」，δ/H 在分子分母相消，
#   而 delay（wait_mult）與 cost 仍留在分子 ⇒ 等待與前期投入照樣被折價（人格 δ 在此才有意義）。
static func flow_utility(gain_daily: float, baseline_daily: float, daily_need: float,
		values: Dictionary, net_flow: float, food_stock: float,
		cost: float = 0.0, delay_days: float = 0.0) -> float:
	var d: float = delta_of(values)
	var post_net: float = net_flow + (gain_daily - baseline_daily)
	var h: float = horizon_eff(post_net, food_stock)
	return _utility_over(gain_daily, baseline_daily, daily_need, d, h, cost, delay_days)

# ★★★存量（stock）用的入口：**有限存量，`source_stock` 必填**（spec 2026-08-25）。
#   ★病：`flow_utility` 假設 `gain_daily` 在整段 `h` 天【都持續】—— 對再生資源成立，
#     ★對 `ore_iron`/`gem` 這種【採完就沒】的不成立 ⇒ 系統性高估，且不對稱（只會高估或打平）。
#   ★修：有效天數多一個上界 —— **這個礦還能挖多久**。
#         H_stock = min(H_eff, S / maxf(gain_daily, 0.001))
#   ★★與既有 `horizon_eff`（「我還能活多久」＝ food_stock / drain）**完全同構**：不是新公式，
#     是同一個形狀用在另一端。★★★連它的 epsilon guard 一起抄 —— 那不是防呆，是同構的一部分：
#     `gain_daily = 0` ⇒ `S/0.0 = inf` ⇒ 上界消失 ⇒ **病原封不動、只換了個入口**。
#   ★★為什麼是【兩個入口】而不是 `flow_utility(..., source_stock := INF)`：
#     **忘記傳 ⇒ 存量被當流 ⇒ 靜默高估。** 用【入口】區分，不用【參數值】區分
#     ——★忘記選的話，根本沒有函式可以呼叫。
static func stock_utility(gain_daily: float, baseline_daily: float, daily_need: float,
		values: Dictionary, net_flow: float, food_stock: float, source_stock: float,
		cost: float = 0.0, delay_days: float = 0.0) -> float:
	var d: float = delta_of(values)
	var post_net: float = net_flow + (gain_daily - baseline_daily)
	var h_eff: float = horizon_eff(post_net, food_stock)
	var h_stock: float = minf(h_eff, maxf(source_stock, 0.0) / maxf(gain_daily, 0.001))   # ★同構：S / 消耗率
	# ★★★兩段視野【不對稱】——這是本票的關鍵，也是我與 spec 字面寫法的差異（已回報 systems）：
	#   ★spec 寫 `H_stock = min(H_eff, S/gain)` 然後【整條算式都用 H_stock】。
	#     照字面做 ＝ **no-op**：`flow_utility` 的分母是 `pv(daily_need, d, h)` ——
	#     ★同一個 h 在分子分母相消（那正是 gate6 立的性質「視野長短不改變倍數」）
	#     ⇒ 兩邊一起縮 ⇒ 比值不動 ⇒ **存量與流分不出來，病原封不動。**
	#   ★★正確的不對稱在世界本身：**礦會挖完（分子的流在 H_stock 就斷），
	#     但【人還是要繼續吃】（分母的需求延續整個 H_eff）。**
	#   ⇒ 分子用 `h_stock`、分母用 `h_eff`。★這也是唯一能同時滿足 spec 自己驗收 ②③ 的形狀：
	#     S 撐滿視野 ⇒ h_stock == h_eff ⇒ 與 flow_utility 逐位相同（③）；
	#     S 撐不滿   ⇒ 分子縮、分母不縮 ⇒ 嚴格低於流（②「只會高估或打平」的另一面）。
	if h_eff <= 0.0:
		return 0.0
	var wait_mult: float = pow(clampf(d, DELTA_FLOOR, DELTA_CAP), maxf(delay_days, 0.0))
	var value: float = pv(gain_daily, d, h_stock) * wait_mult - pv(baseline_daily, d, h_eff) - cost
	return value / maxf(pv(daily_need, d, h_eff), 0.001)

# 兩個入口共用的算式（★同一把尺：只有【視野怎麼算】不同，值怎麼算完全一樣）。
static func _utility_over(gain_daily: float, baseline_daily: float, daily_need: float,
		d: float, h: float, cost: float, delay_days: float) -> float:
	if h <= 0.0:
		return 0.0
	# 等待期折現：delay 天後才開始領 → 整段流乘 δ^delay（現成的流天然贏要等的流）
	var wait_mult: float = pow(clampf(d, DELTA_FLOOR, DELTA_CAP), maxf(delay_days, 0.0))
	var value: float = pv(gain_daily, d, h) * wait_mult - pv(baseline_daily, d, h) - cost
	return value / maxf(pv(daily_need, d, h), 0.001)
