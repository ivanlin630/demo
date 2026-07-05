extends SceneTree

# ★ 序2 solo 融合驗（核心交付）。融合非刪 + 反向（capability-grounded）。鏡射 threat_dissolution_check 風格。
#   6a repertoire：9 反應（攻擊/掠奪/外交/survival/生產/貿易/駐守/紮營/投靠）各由對應人格×情境原型達成。
#   6b 反向（capability grounding，藍圖核心）：
#      - 無牙商隊（無 armed）+ 弱prey → 攻擊/掠奪 不在 rank[0]（capability≈0 壓平，非 tag-label 禁）。
#      - 重甲商隊（有 armed）+ 絕境 + 弱prey → 掠奪 可進前列（鎖來自戰力非 label）。
#      - 軍隊（好戰高+有 armed）→ 攻擊傾向在，非誤貿易。
#   Task4 補：unified 守恆（有牙 unified 商隊不被 grounding 誤癱瘓）。
# 任一破 = 融合失敗。

var _fails: int = 0

func _initialize() -> void:
	_check_repertoire()
	_check_reverse()
	_check_unified_conservation()
	if _fails == 0:
		print("[solo-dissolution] ALL PASS")
	else:
		print("[solo-dissolution] FAIL count=%d" % _fails)
	quit()

# ── 手構 ctx（deterministic，繞世界 setup）。leader_values + 情境欄位直填 ──
func _ctx(vals: Dictionary) -> DecisionContext:
	var c := DecisionContext.new()
	c.leader_values = vals
	c.food_days = 14.0        # 預設吃飽（survival_pressure=0，不誤壓）
	c.population = 20         # > FORAGE_VIABLE_POP(15) → 覓食預設不 applicable（除非測試改小）
	c.threat_threshold = 999.0  # 預設無威脅：threat_react(0) < threshold → 備戰/迎戰/求和 不 applicable
	return c                    #   （threat repertoire 由 threat_dissolution_check 專驗；此處驗 solo 主 menu）

func _first(c: DecisionContext) -> String:
	var r: Array = DecisionEngine.rank_scored_ctx(c)
	return r[0]["opt"] if not r.is_empty() else "<空>"

func _opts(c: DecisionContext) -> Array:
	var out: Array = []
	for e in DecisionEngine.rank_scored_ctx(c): out.append(e["opt"])
	return out

func _expect(label: String, c: DecisionContext, expected: String) -> void:
	var got: String = _first(c)
	if got != expected:
		_fails += 1
		print("[FAIL] repertoire 原型%s 預期 %s 得 %s (ranked=%s)" % [label, expected, got, str(_opts(c))])
	else:
		print("[repertoire] 原型%s → %s OK" % [label, got])

# ── 6a repertoire：9 反應各可達 ──
func _check_repertoire() -> void:
	print("--- 6a repertoire (9 反應) ---")

	# 1) 攻擊：好戰野心高 + 有戰兵 + 弱prey + 征服 intent
	var c1 := _ctx({"好戰": 0.9, "野心": 0.9, "貪婪": 0.5})
	c1.self_armed_ratio = 0.5; c1.has_weak_prey = true
	c1.intent = "征服"; c1.intent_target = 1
	_expect("攻擊", c1, "攻擊")

	# 2) 掠奪：貪婪高 + 弱prey + 有戰兵（無征服 intent → 攻擊 不 applicable）
	var c2 := _ctx({"貪婪": 0.9, "好戰": 0.5, "殘忍": 0.5})
	c2.self_armed_ratio = 0.5; c2.has_weak_prey = true
	_expect("掠奪", c2, "掠奪")

	# 3) 貿易：貪婪高 + 市場（有貨+套利+商隊）
	var c3 := _ctx({"貪婪": 0.9})
	c3.has_goods = true; c3.has_arb = true; c3.is_merchant = true
	_expect("貿易", c3, "貿易")

	# 4) 駐守：慎重高 + own outpost（有貨→produce 低，駐守勝生產）
	var c4 := _ctx({"慎重": 0.9, "野心": 0.2, "貪婪": 0.3})
	c4.has_own_outpost = true; c4.has_goods = true
	_expect("駐守", c4, "駐守")

	# 5) 生產：野心高 + own outpost + 階梯缺口（ambition_drive 推生產過建設/駐守）
	var c5 := _ctx({"野心": 0.9, "慎重": 0.5})
	c5.has_own_outpost = true; c5.ambition_gap = 3
	_expect("生產", c5, "生產")

	# 6) 紮營：求生欲高 + 無own + farmable + 絕境（pop 大→覓食不 applicable）
	var c6 := _ctx({"求生欲": 0.9, "野心": 0.3})
	c6.food_days = 1.0; c6.has_farmable_tile = true
	_expect("紮營", c6, "紮營")

	# 7) 投靠：義氣高 + strong neighbor + 絕境
	var c7 := _ctx({"義氣": 0.9, "求生欲": 0.5, "信義": 0.5})
	c7.food_days = 1.0; c7.has_strong_neighbor = true
	_expect("投靠", c7, "投靠")

	# 8) survival(FLEE)：求生欲高 + 威脅逼近（ctx.threat 高，threat_react 低不觸 備戰/迎戰）
	var c8 := _ctx({"求生欲": 0.9})
	c8.threat = 0.9
	_expect("survival", c8, "survival")

	# 9) 外交：派系 directive=外交 + 有 target（faction member 語意）
	var c9 := _ctx({"義氣": 0.7, "計謀": 0.6, "_loyalty": 0.9, "野心": 0.3})
	c9.faction_stakes = ["外交"]; c9.faction_diplo_target = 1
	_expect("外交", c9, "外交")

# ── 6b 反向（capability grounding，藍圖核心）──
func _check_reverse() -> void:
	print("--- 6b 反向 (capability grounding) ---")

	# 無牙商隊：好戰低 + 無 armed（self_armed_ratio=0）+ 弱prey 在場 → 攻擊/掠奪 不在 rank[0]。
	# capability≈0 壓平 loot/attack eval；常態選貿易/其他（非被 tag 禁）。
	var cm := _ctx({"好戰": 0.2, "貪婪": 0.7, "殘忍": 0.5})
	cm.self_armed_ratio = 0.0; cm.has_weak_prey = true
	cm.is_merchant = true; cm.has_goods = true
	var top_m: String = _first(cm)
	if top_m == "攻擊" or top_m == "掠奪":
		_fails += 1
		print("[FAIL] 無牙商隊劫匪化：rank[0]=%s（capability grounding 未壓平；ranked=%s）" \
			% [top_m, str(_opts(cm))])
	else:
		print("[反向] 無牙商隊不劫匪化 → rank[0]=%s OK（攻擊/掠奪 被 capability≈0 壓平）" % top_m)

	# 重甲商隊絕境可揮刀：有 armed + 絕境（food<3）+ 弱prey → 掠奪 進前列（top2）。
	# 證「鎖來自戰力非 label」——同商隊人格，只差 armed 與匱乏，就能揮刀。
	var ca := _ctx({"好戰": 0.3, "貪婪": 0.7, "野心": 0.6, "殘忍": 0.5})
	ca.self_armed_ratio = 0.5; ca.has_weak_prey = true
	ca.food_days = 1.0        # 絕境 → intent_fit 匱乏→搶
	var opts_a: Array = _opts(ca)
	var top2_a: Array = opts_a.slice(0, 2)
	if "掠奪" in top2_a:
		print("[反向] 重甲商隊絕境可揮刀 → 掠奪 進前列 OK (top2=%s)" % str(top2_a))
	else:
		_fails += 1
		print("[FAIL] 重甲商隊絕境無法揮刀：掠奪 不在前列（ranked=%s）" % str(opts_a))

	# 軍隊不變雜貨商：好戰高 + 有 armed + 征服 intent + 弱prey → 攻擊傾向在（rank[0]=攻擊，非誤貿易）。
	var cs := _ctx({"好戰": 0.9, "野心": 0.7, "貪婪": 0.5})
	cs.self_armed_ratio = 0.6; cs.has_weak_prey = true
	cs.intent = "征服"; cs.intent_target = 1
	var top_s: String = _first(cs)
	if top_s == "貿易":
		_fails += 1
		print("[FAIL] 軍隊變雜貨商：rank[0]=貿易（ranked=%s）" % str(_opts(cs)))
	elif top_s == "攻擊" or top_s == "掠奪":
		print("[反向] 軍隊不變雜貨商 → rank[0]=%s OK" % top_s)
	else:
		_fails += 1
		print("[FAIL] 軍隊反應異常：rank[0]=%s 非攻擊/掠奪（ranked=%s）" % [top_s, str(_opts(cs))])

# ── Task4：unified 守恆（有牙 unified 商隊不被 capability grounding 誤癱瘓）──
# 佔位（Task4 Step1 填實）：先宣告，Task1 red 階段 no-op。
func _check_unified_conservation() -> void:
	pass
