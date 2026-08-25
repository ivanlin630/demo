extends SceneTree
# ★材料閘人格化的兩條 fixture 驗收（systems 寫死理由，2026-08-26）：
#   ①★中性零漂：`{"慎重": 0.5}` 最小 dict ⇒ margin 逐位元 == 1.5
#     ★為什麼是 fixture 不是 organic：`person_generator` 用 `randf_range(0.35,0.65)`
#       ⇒ organic 世界【不會出現】中性人格，拿 organic 驗＝驗空母體。
#   ②★★分化真的改變結果：`avail` 擺進 `[cost, 1.5·cost)` ⇒ 慎重擋下、大膽放行（同 cost 同池，只換人格）
#     ★為什麼是 fixture：那個帶是 `[50,75)`，而世界層的 `avail` 從未進入（實測 0 或 20）。
#   ★★★兩條都呼叫【真正的 production 函式】`BuildAfford.can_afford/margin_of` ——
#     在測試裡自己重寫 `avail < cost * margin` 再斷言，驗的是測試抄的公式，不是那道閘。

var _fail: int = 0

func _initialize() -> void:
	_test_neutral_zero_drift()
	_test_persona_changes_outcome()
	_test_monotonic_and_bounded()
	if _fail == 0:
		print("=== DONE === ALL PASS")
	else:
		print("=== DONE === %d FAIL" % _fail)
	print("[TEST-SUITE-COMPLETE]")   # ★閘型床要件①（03_implementer）
	quit()

func _ok(c: bool, m: String) -> void:
	if c:
		print("  [PASS] %s" % m)
	else:
		_fail += 1
		push_error("[FAIL] %s" % m)   # ★閘型床要件②：走引擎 severity 通道（叫、不停）
		print("  [FAIL] %s" % m)

# ①★anti-crank：中性必須拿到剛好 1.5
func _test_neutral_zero_drift() -> void:
	print("--- ①中性零漂 ---")
	var m_min: float = BuildAfford.margin_of({"慎重": 0.5})
	_ok(m_min == 1.5, "最小 dict {慎重:0.5} ⇒ margin 逐位元 1.5（實得 %.17f）" % m_min)
	var m_full: float = BuildAfford.margin_of({"慎重": 0.5, "好戰": 0.5, "野心": 0.5, "貪婪": 0.5})
	_ok(m_full == 1.5, "全中性 dict ⇒ 仍逐位元 1.5（實得 %.17f）" % m_full)
	var m_empty: float = BuildAfford.margin_of({})
	_ok(m_empty == 1.5, "空 dict（全走 default 0.5）⇒ 1.5（實得 %.17f）" % m_empty)

# ②★★同 cost、同池，只換人格 ⇒ 結果必須不同
func _test_persona_changes_outcome() -> void:
	print("--- ②分化真的改變結果 ---")
	var cost: Dictionary = {"material": 50.0, "ticks": 336}
	var caut: Dictionary = {"慎重": 1.0, "好戰": 0.0, "野心": 0.0}
	var bold: Dictionary = {"慎重": 0.0, "好戰": 1.0, "野心": 1.0}
	var m_c: float = BuildAfford.margin_of(caut)
	var m_b: float = BuildAfford.margin_of(bold)
	_ok(m_c > 1.5 and m_b < 1.5, "慎重 margin %.3f > 1.5 > 大膽 margin %.3f" % [m_c, m_b])
	# ★把 avail 擺進兩者之間：大膽過得了、慎重過不了
	var mid: float = 50.0 * (m_b + m_c) * 0.5   # 兩個門檻的中間值（★由 margin 導出，非手抄）
	var pool: Array = [{"material": mid}]
	_ok(BuildAfford.can_afford(cost, pool, bold), "avail=%.1f ⇒ 大膽【放行】" % mid)
	_ok(not BuildAfford.can_afford(cost, pool, caut), "avail=%.1f ⇒ 慎重【擋下】" % mid)
	# ★陽性對照：低到誰都過不了 / 高到誰都過得了（★否則上面兩條可能只是「恆真/恆假」）
	_ok(not BuildAfford.can_afford(cost, [{"material": 0.0}], bold), "陽性對照：avail=0 ⇒ 連大膽也擋下")
	_ok(BuildAfford.can_afford(cost, [{"material": 9999.0}], caut), "陽性對照：avail 充足 ⇒ 連慎重也放行")

# ③★單調 + 有界（★形狀驗收：連續調變、不是門檻跳變）
func _test_monotonic_and_bounded() -> void:
	print("--- ③單調且有界 ---")
	var prev: float = -1.0
	var mono: bool = true
	for i in range(11):
		var c: float = float(i) / 10.0
		var m: float = BuildAfford.margin_of({"慎重": c})
		if m < prev: mono = false
		prev = m
	_ok(mono, "慎重 0→1 單調不遞減（連續調變，非門檻跳變）")
	var hi: float = BuildAfford.margin_of({"慎重": 1.0})
	var lo: float = BuildAfford.margin_of({"好戰": 1.0, "野心": 1.0, "慎重": 0.0})
	_ok(hi <= BuildAfford.MARGIN_MAX and lo >= BuildAfford.MARGIN_MIN,
		"clamp 有界：%.3f ≤ MAX %.2f、%.3f ≥ MIN %.2f" % [hi, BuildAfford.MARGIN_MAX, lo, BuildAfford.MARGIN_MIN])
	# ★★★clamp pin（reviewer 2026-08-26）：四個常數只有三個自由度——
	#   公式的自然值域 `NEUTRAL ± (K_c+K_d)/2` 現在【剛好】等於 clamp 兩端，
	#   ⇒ clamp 是防禦性 no-op。★而那是巧合不是推導：只調斜率不動上下界，
	#     clamp 會開始【靜默削平極端人格】——不紅、不報，只是極端值被壓成同一個數。
	#   ⇒ 把這個關係釘成斷言：只在「有人改了斜率沒改上下界」時才紅，平常零成本。
	var _span: float = (BuildAfford.MARGIN_CAUTION_K + BuildAfford.MARGIN_DARING_K) * 0.5
	_ok(is_equal_approx(BuildAfford.MARGIN_NEUTRAL + _span, BuildAfford.MARGIN_MAX),
		"pin：NEUTRAL + (K_c+K_d)/2 == MARGIN_MAX（%.3f vs %.3f）" % [BuildAfford.MARGIN_NEUTRAL + _span, BuildAfford.MARGIN_MAX])
	_ok(is_equal_approx(BuildAfford.MARGIN_NEUTRAL - _span, BuildAfford.MARGIN_MIN),
		"pin：NEUTRAL − (K_c+K_d)/2 == MARGIN_MIN（%.3f vs %.3f）" % [BuildAfford.MARGIN_NEUTRAL - _span, BuildAfford.MARGIN_MIN])
	# ★送料量必須 ≥ 任何領袖的閘（INVEST_SAFETY 改讀上界的理由）
	_ok(FactionAISystem.INVEST_SAFETY >= hi,
		"INVEST_SAFETY %.2f ≥ 最保守領袖的 margin %.3f（送料永遠夠）" % [FactionAISystem.INVEST_SAFETY, hi])
