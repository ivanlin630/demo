extends SceneTree

# 絕境經濟 S2 famine-amplifier TDD（乞食/併入 clean gap；掠奪支已 escalate systems 待裁）。
# 真根:乞食/併入 drive 平(beg=BEG_FLOOR const, join=0.5+rep)→餓深不升級→慎重/低野心 starving 隊傻站死。
# 修:famine_severity=clampf((FAMINE_FLOOR-food_days)/FAMINE_FLOOR,0,1) × 對應人格 × K → 餓深自然升級,cap 禁無界。
# 覓食=baseline 不 amplify(floor;絕境 option amplify 過它=升級)。

var _fail: int = 0

func _initialize() -> void:
	_test_beg_famine()
	_test_join_famine()
	_test_camp_famine()
	_test_no_amplify_when_fed()
	_test_cap_no_unbounded()
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

func _mk_ctx(food_days: float, vals: Dictionary) -> DecisionContext:
	var c := DecisionContext.new()
	c.food_days = food_days
	c.leader_values = vals
	c.has_aid_target = true
	return c

func _test_beg_famine() -> void:
	print("--- 乞食 famine-amplifier：慎重/榮譽(信義)→餓深升級 ---")
	var vals := {"慎重": 0.9, "信義": 0.9}
	var starving := DecisionTerms.eval("beg_famine", _mk_ctx(0.0, vals), "乞食")
	var hungry := DecisionTerms.eval("beg_famine", _mk_ctx(2.0, vals), "乞食")
	var fed := DecisionTerms.eval("beg_famine", _mk_ctx(3.0, vals), "乞食")
	_ok(starving > hungry and hungry > fed, "餓深→乞食升級（食0 %.2f > 食2 %.2f > 食3 %.2f）" % [starving, hungry, fed])
	_ok(fed == 0.0, "食足(≥FAMINE_FLOOR) → 乞食 famine 不 amplify（=0）")
	# 人格方向：高慎重/信義 > 低慎重/信義
	var cautious := DecisionTerms.eval("beg_famine", _mk_ctx(0.0, {"慎重": 0.9, "信義": 0.9}), "乞食")
	var reckless := DecisionTerms.eval("beg_famine", _mk_ctx(0.0, {"慎重": 0.1, "信義": 0.1}), "乞食")
	_ok(cautious > reckless, "慎重/榮譽高者更升級乞食（%.2f > %.2f）" % [cautious, reckless])
	# 只 for 乞食
	_ok(DecisionTerms.eval("beg_famine", _mk_ctx(0.0, vals), "掠奪") == 0.0, "beg_famine 只染乞食（他 opt=0）")
	# 無 aid target → 0（乞無門）
	var c_noaid := _mk_ctx(0.0, vals); c_noaid.has_aid_target = false
	_ok(DecisionTerms.eval("beg_famine", c_noaid, "乞食") == 0.0, "無 aid target → 乞食 famine=0（乞無門）")

func _test_join_famine() -> void:
	print("--- 併入 famine-amplifier：低野心/高求生欲→餓深升級 ---")
	var vals := {"野心": 0.1, "求生欲": 0.9}
	var starving := DecisionTerms.eval("join_famine", _mk_ctx(0.0, vals), "併入")
	var hungry := DecisionTerms.eval("join_famine", _mk_ctx(2.0, vals), "併入")
	var fed := DecisionTerms.eval("join_famine", _mk_ctx(3.0, vals), "併入")
	_ok(starving > hungry and hungry > fed, "餓深→併入升級（食0 %.2f > 食2 %.2f > 食3 %.2f）" % [starving, hungry, fed])
	_ok(fed == 0.0, "食足 → 併入 famine 不 amplify（=0）")
	# 人格方向：低野心+高求生 > 高野心+低求生
	var lowamb := DecisionTerms.eval("join_famine", _mk_ctx(0.0, {"野心": 0.1, "求生欲": 0.9}), "併入")
	var highamb := DecisionTerms.eval("join_famine", _mk_ctx(0.0, {"野心": 0.9, "求生欲": 0.1}), "併入")
	_ok(lowamb > highamb, "低野心高求生更升級併入（%.2f > %.2f）" % [lowamb, highamb])
	_ok(DecisionTerms.eval("join_famine", _mk_ctx(0.0, vals), "乞食") == 0.0, "join_famine 只染併入（他 opt=0）")

func _mk_camp_ctx(food_days: float, vals: Dictionary) -> DecisionContext:
	var c := DecisionContext.new()
	c.food_days = food_days
	c.leader_values = vals
	c.has_farmable_tile = true
	return c

func _test_camp_famine() -> void:
	print("--- 紮營 famine-amplifier：高野心/求生欲→餓深自立紮營(不投靠)（systems 裁 A 加第三支）---")
	var vals := {"野心": 0.9, "求生欲": 0.9}
	var starving := DecisionTerms.eval("camp_famine", _mk_camp_ctx(0.0, vals), "紮營")
	var hungry := DecisionTerms.eval("camp_famine", _mk_camp_ctx(2.0, vals), "紮營")
	var fed := DecisionTerms.eval("camp_famine", _mk_camp_ctx(3.0, vals), "紮營")
	_ok(starving > hungry and hungry > fed, "餓深→紮營升級（食0 %.2f > 食2 %.2f > 食3 %.2f）" % [starving, hungry, fed])
	_ok(fed == 0.0, "食足 → 紮營 famine 不 amplify（=0）")
	# 人格方向：高野心+高求生(自立) > 低野心+低求生
	var selfreliant := DecisionTerms.eval("camp_famine", _mk_camp_ctx(0.0, {"野心": 0.9, "求生欲": 0.9}), "紮營")
	var submissive := DecisionTerms.eval("camp_famine", _mk_camp_ctx(0.0, {"野心": 0.1, "求生欲": 0.1}), "紮營")
	_ok(selfreliant > submissive, "高野心自立者更升級紮營（%.2f > %.2f，vs 低野心走併入）" % [selfreliant, submissive])
	_ok(DecisionTerms.eval("camp_famine", _mk_camp_ctx(0.0, vals), "乞食") == 0.0, "camp_famine 只染紮營（他 opt=0）")
	# 無可耕地 → 0（紮營無處紮）
	var c_notile := _mk_camp_ctx(0.0, vals); c_notile.has_farmable_tile = false
	_ok(DecisionTerms.eval("camp_famine", c_notile, "紮營") == 0.0, "無可耕地 → 紮營 famine=0（無處紮）")

func _test_no_amplify_when_fed() -> void:
	print("--- 覓食 baseline 不 amplify（絕境 option amplify 過它=升級）---")
	# 覓食走 survival_pressure=1.0 常數；famine 不加它 → 餓深時絕境 option 能蓋過覓食
	var forage := DecisionTerms.eval("survival_pressure", _mk_ctx(0.0, {}), "覓食")
	_ok(forage == 1.0, "覓食=baseline 1.0 恆定（無 famine amplify）")

func _test_cap_no_unbounded() -> void:
	print("--- cap 禁無界：food_days 負(深餓)不超 food=0 值 ---")
	var vals := {"慎重": 0.9, "信義": 0.9}
	var at_zero := DecisionTerms.eval("beg_famine", _mk_ctx(0.0, vals), "乞食")
	var below_zero := DecisionTerms.eval("beg_famine", _mk_ctx(-5.0, vals), "乞食")
	_ok(is_equal_approx(at_zero, below_zero), "food<0 不再放大（famine_severity capped @1）：食0 %.2f == 食-5 %.2f" % [at_zero, below_zero])
