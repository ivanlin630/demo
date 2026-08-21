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
