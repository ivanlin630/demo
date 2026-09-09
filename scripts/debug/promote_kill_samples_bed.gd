extends SceneTree
# @bed-kind: acceptance
# slice: promote.kill.* 的 bounded 樣本（聚合必附樣本，不變量合規）
#
# 驗收：①三個 kill 分支各有 bump_sample 且【有界】
#   ②★成對對照：exp 差 5 與差 45 在樣本裡【可分辨】（只印分支名＝白做）
#   ③零行為改動（fp 比對在兩棵樹之間做，本床只印）

var _fails: int = 0
var _sections: int = 0
const EXPECT_SECTIONS: int = 3

func _initialize() -> void:
	print("=== PROMOTE KILL SAMPLES ===")
	_test_three_branches()
	_test_short_is_distinguishable()
	_test_bounded()
	if _sections != EXPECT_SECTIONS:
		_fails += 1
		push_error("[FAIL] 只跑完 %d/%d 段 —— 中途崩掉" % [_sections, EXPECT_SECTIONS])
	print("=== DONE === SECTIONS=%d/%d FAILS=%d" % [_sections, EXPECT_SECTIONS, _fails])
	quit()

func _ok(cond: bool, msg: String) -> void:
	if cond:
		print("  PASS: " + msg)
	else:
		_fails += 1
		push_error("[FAIL] " + msg)

func _mk(exp_val: float, bodies: int) -> Array:
	var st := WorldState.new()
	st.world = WorldData.new()
	st.world.current_tick = 500
	var t := TeamData.new()
	t.team_id = 5
	AnonTierSystem.add_anon(t, "平民", bodies)
	t.anon_exp["平民"] = exp_val
	t.resources = { "food": 0.0 }
	st.teams[5] = t
	return [st, t]

func _samples(key: String) -> Array:
	var arr = Probe.samples.get(key, [])
	return arr if arr is Array else []

func _test_three_branches() -> void:
	print("-- ① 三個分支各有 bounded 樣本 --")
	Probe.reset()
	Probe.enabled = true
	# bodies 不足
	var w1: Array = _mk(9999.0, 1)
	AnonTierSystem.try_promote(w1[0], w1[1], "平民", 5)
	# exp 不足
	var w2: Array = _mk(0.0, 10)
	AnonTierSystem.try_promote(w2[0], w2[1], "平民", 5)
	# res 不足（exp 給足、人夠，卡在物資）
	var w3: Array = _mk(99999.0, 10)
	AnonTierSystem.try_promote(w3[0], w3[1], "平民", 5)
	for k in ["promote.kill.not_enough_bodies", "promote.kill.not_enough_exp", "promote.kill.not_enough_res"]:
		var n: int = _samples(k).size()
		print("    %-34s 計數 %d｜樣本 %d" % [k, int(Probe.counts.get(k, 0)), n])
		_ok(n > 0, "①%s 有 bounded 樣本（不是只有 bump）" % k)
	_sections += 1

func _test_short_is_distinguishable() -> void:
	print("-- ② 成對對照：差 5 與差 45 要分得出來 --")
	Probe.reset()
	Probe.enabled = true
	# 平民 threshold=50；want=1 ⇒ need=50。have=45 ⇒ short 5；have=5 ⇒ short 45
	var a: Array = _mk(45.0, 10)
	AnonTierSystem.try_promote(a[0], a[1], "平民", 1)
	var b: Array = _mk(5.0, 10)
	AnonTierSystem.try_promote(b[0], b[1], "平民", 1)
	var ss: Array = _samples("promote.kill.not_enough_exp")
	var shorts: Array = []
	for e in ss:
		shorts.append(snappedf(float((e as Dictionary).get("short", -1.0)), 0.01))
	print("    樣本 %d 筆｜short 值：%s" % [ss.size(), str(shorts)])
	_ok(5.0 in shorts and 45.0 in shorts,
		"②差 5 與差 45 在樣本裡可分辨（實得 %s）—— 只印分支名的話這格白做" % str(shorts))
	_sections += 1

func _test_bounded() -> void:
	print("-- ①b 有界：撞 200 次不得無界累積 --")
	Probe.reset()
	Probe.enabled = true
	for i in 200:
		var w: Array = _mk(0.0, 10)
		AnonTierSystem.try_promote(w[0], w[1], "平民", 5)
	var n: int = _samples("promote.kill.not_enough_exp").size()
	print("    撞 200 次 ⇒ 計數 %d｜樣本 %d（上限 64）" % [int(Probe.counts.get("promote.kill.not_enough_exp", 0)), n])
	_ok(n <= 64, "①b 樣本有界（%d ≤ 64）" % n)
	_ok(int(Probe.counts.get("promote.kill.not_enough_exp", 0)) == 200, "①b 計數照樣是全量 200（樣本有界≠計數截斷）")
	Probe.enabled = false
	_sections += 1
