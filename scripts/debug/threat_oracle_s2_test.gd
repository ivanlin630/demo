extends SceneTree

# threat-oracle S2 util severity-scaled 重設計（行為變大）char bed
# spec: threat-oracle §S2。手構 ctx（deterministic，繞世界 setup）→ rank_scored_ctx（統一路,含 boost）
# 驗:零 fall-through 四象限主導 + severity-scaled + winnable-modulate + FLEE 讀 winnable(finding5) + severity capped。

var _fail: int = 0

func _initialize() -> void:
	_test_zero_fall_through_quadrants()
	_test_severity_scaling()
	_test_winnable_modulate()
	_test_flee_references_winnable()
	_test_severity_capped()
	_test_r2_boost_not_disguised_hardgate()
	_test_r2_zero_fallthrough_extreme_vector()
	if _fail == 0:
		print("=== DONE === ALL PASS")
	else:
		print("=== DONE === %d FAIL" % _fail)
	quit()

func _ok(cond: bool, msg: String) -> void:
	if cond:
		print("  [PASS] %s" % msg)
	else:
		_fail += 1
		print("  [FAIL] %s" % msg)

# 手構 ctx：threat applicable(threat_react≥threshold) + FLEE gate(threat>0) + winnable 直設。
func _mk_ctx(vals: Dictionary, threat_react: float, winnable: float) -> DecisionContext:
	var c := DecisionContext.new()
	c.leader_values = vals
	c.threat = 0.8                      # >0 → FLEE gate 開
	c.threat_react = threat_react
	c.threat_threshold = 0.3            # 低 → 備戰/迎戰/求和 applicable
	c.threat_id = 1; c.threat_pos = Vector2i(2, 0)
	c.is_resident = false; c.is_subteam = false
	c.winnable = winnable
	c.team_panic = 0.0
	var u := PackedFloat32Array(); u.resize(NeedHierarchy.N_LAYERS); c.need_urgency = u
	return c

func _top(ctx: DecisionContext) -> String:
	var scored: Array = DecisionEngine.rank_scored_ctx(ctx, "")
	return String(scored[0]["opt"]) if not scored.is_empty() else "<空>"

func _util(ctx: DecisionContext, opt: String) -> float:
	for e in DecisionEngine.rank_scored_ctx(ctx, ""):
		if e["opt"] == opt: return float(e["u"])
	return -999.0

# ── 零 fall-through：四象限各有主導 threat response（非落穿到非-threat）──
func _test_zero_fall_through_quadrants() -> void:
	print("--- 零 fall-through 四象限主導 ---")
	# proud-doomed：好戰高慎重低·不可勝(winnable低) → 迎戰(reckless override 死戰)
	var pd := _mk_ctx({"好戰": 0.9, "慎重": 0.1, "求生欲": 0.3, "貪婪": 0.3, "信義": 0.3}, 1.0, 0.1)
	_ok(_top(pd) == "迎戰", "proud-doomed → 迎戰(死戰，got=%s)" % _top(pd))
	# cautious-hawk：好戰高慎重高·不可勝 → 備戰(respect winnable，迎戰低)
	var ch := _mk_ctx({"好戰": 0.9, "慎重": 0.9, "求生欲": 0.3, "貪婪": 0.3, "信義": 0.3}, 1.0, 0.1)
	_ok(_top(ch) == "備戰", "cautious-hawk → 備戰(got=%s)" % _top(ch))
	# coward：好戰低·求生欲高 → FLEE(survival，膽量秤)
	var cw := _mk_ctx({"好戰": 0.1, "慎重": 0.5, "求生欲": 0.9, "貪婪": 0.3, "信義": 0.3}, 1.0, 0.3)
	_ok(_top(cw) == "survival", "coward → survival/FLEE(got=%s)" % _top(cw))
	# weak-pragmatic：低好戰·低求生欲·貪婪/信義高 → 求和(outlet)
	var wp := _mk_ctx({"好戰": 0.1, "慎重": 0.3, "求生欲": 0.2, "貪婪": 0.7, "信義": 0.6}, 1.0, 0.3)
	_ok(_top(wp) == "求和", "weak-pragmatic → 求和(got=%s)" % _top(wp))

# ── severity-scaled：備戰隨 severity 普遍升 ──
func _test_severity_scaling() -> void:
	print("--- severity-scaled：備戰隨威脅升 ---")
	var vals := {"好戰": 0.5, "慎重": 0.7, "求生欲": 0.3, "貪婪": 0.3, "信義": 0.3}
	var lo := _util(_mk_ctx(vals, 0.4, 0.5), "備戰")
	var hi := _util(_mk_ctx(vals, 1.3, 0.5), "備戰")
	_ok(hi > lo, "備戰 util 隨 severity 升（hi=%.3f > lo=%.3f）" % [hi, lo])

# ── winnable-modulate：cautious 迎戰隨 winnable 升；reckless override 不甩 winnable ──
func _test_winnable_modulate() -> void:
	print("--- winnable-modulate：迎戰 ---")
	var cautious := {"好戰": 0.8, "慎重": 0.9, "求生欲": 0.3, "貪婪": 0.3, "信義": 0.3}
	var c_lowin := _util(_mk_ctx(cautious, 1.0, 0.1), "迎戰")
	var c_hiwin := _util(_mk_ctx(cautious, 1.0, 0.9), "迎戰")
	_ok(c_hiwin > c_lowin, "cautious 迎戰隨 winnable 升(respect;hi=%.3f>lo=%.3f)" % [c_hiwin, c_lowin])
	# ★defiance：狂徒(reckless) 迎戰 不可勝時 SPIKE(defiant last-stand)——與 cautious 反向(cautious 可勝才戰)
	var reckless := {"好戰": 0.9, "慎重": 0.1, "求生欲": 0.3, "貪婪": 0.3, "信義": 0.3}
	var r_lowin := _util(_mk_ctx(reckless, 1.0, 0.1), "迎戰")
	var r_hiwin := _util(_mk_ctx(reckless, 1.0, 0.9), "迎戰")
	_ok(r_lowin > r_hiwin, "狂徒 迎戰 不可勝>可勝(defiance last-stand;%.3f>%.3f)" % [r_lowin, r_hiwin])
	_ok(r_lowin > c_lowin, "狂徒 不可勝迎戰 > cautious 不可勝迎戰(defiance spike 只狂徒;%.3f>%.3f)" % [r_lowin, c_lowin])

# ── FLEE(threat_pressure) 讀 winnable（finding5）──
func _test_flee_references_winnable() -> void:
	print("--- FLEE threat_pressure 讀 winnable(finding5) ---")
	var vals := {"好戰": 0.2, "慎重": 0.5, "求生欲": 0.8, "貪婪": 0.3, "信義": 0.3}
	var f_lowin: float = DecisionTerms.eval("threat_pressure", _mk_ctx(vals, 1.0, 0.1), "survival")
	var f_hiwin: float = DecisionTerms.eval("threat_pressure", _mk_ctx(vals, 1.0, 0.9), "survival")
	_ok(f_lowin > f_hiwin, "不可勝(winnable低)→FLEE eval 高(%.3f>%.3f，讀 winnable)" % [f_lowin, f_hiwin])

# ── severity capped：極高 threat_react → 備戰不無限爆(capped SEVERITY_MAX)──
func _test_severity_capped() -> void:
	print("--- severity capped ---")
	var vals := {"好戰": 0.5, "慎重": 0.7, "求生欲": 0.3, "貪婪": 0.3, "信義": 0.3}
	var at_max := _util(_mk_ctx(vals, DecisionTerms.SEVERITY_MAX, 0.5), "備戰")
	var way_over := _util(_mk_ctx(vals, 10.0, 0.5), "備戰")
	_ok(absf(at_max - way_over) < 1e-4, "severity capped：threat_react=10 與 =MAX 備戰同(capped;%.3f==%.3f)" % [at_max, way_over])

# ── ★R² 場景(1)：boost≠偽裝硬閘——中等 severity + 決定性非-threat 機會 → 非-threat 偶爾仍勝 ──
func _test_r2_boost_not_disguised_hardgate() -> void:
	print("--- ★R²(1) boost≠偽裝硬閘 ---")
	# 中等 severity（略高於 THREAT_BOOST_FLOOR，boost 小）+ 加高值貿易機會(有貨+arb+商隊)→ 貿易 stack 應能勝
	var vals := {"好戰": 0.4, "慎重": 0.4, "求生欲": 0.3, "貪婪": 0.6, "信義": 0.4}
	var c := _mk_ctx(vals, 0.65, 0.5)   # severity 剛過 floor 0.6 → boost 小(≈THREAT_BOOST_MAX×0.65/1.5≈0.52)
	c.has_goods = true; c.has_arb = true
	c.leader_values["_is_merchant"] = true
	# 商隊角色：economic_opp 需 is_merchant
	var c2 := c
	c2.is_merchant = true
	var top: String = _top(c2)
	_ok(top == "貿易", "中 severity + 決定性貿易機會 → 貿易勝(threat 非恆勝;got=%s)" % top)

# ── ★R² 場景(2)：真零 fall-through——極端全低人格向量壓力測試（架構性有主導）──
func _test_r2_zero_fallthrough_extreme_vector() -> void:
	print("--- ★R²(2) 真零 fall-through 極端全低向量 ---")
	var extreme := {"好戰": 0.0, "慎重": 0.0, "求生欲": 0.0, "貪婪": 0.0, "信義": 0.0}
	var c := _mk_ctx(extreme, 1.0, 0.1)
	var top: String = _top(c)
	# 全低向量仍有主導 threat response（非落穿到非-threat option/空）——備戰 base(1+severity·k)恆>0 保底
	_ok(top in ["備戰", "迎戰", "求和", "survival"], "極端全低向量仍主導 threat response(非 fall-through;got=%s)" % top)
