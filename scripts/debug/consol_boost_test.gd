extends SceneTree

# 乙 整併 util boost dev-verify（HOW spec 2026-08-01 §3）。
# ★連續 weigh 非硬 gate（reviewer ② 硬檢）+ 人格分化（野心高→吸/擴、低→stay/join）。純算術零 RNG。
# 機制驗（unit）；小併大真 fire + 保守未塌 → warring 3-seed 合量(seeded_warring_bed)。

var _fail: int = 0

func _initialize() -> void:
	_test_absorb_drive_continuous_ambition()
	_test_absorb_drive_ambition_differentiates()
	_test_join_drive_continuous_ambition()
	_test_join_protection_non_desperate()
	if _fail == 0:
		print("=== DONE === ALL PASS")
	else:
		print("=== DONE === %d FAIL" % _fail)
	quit()

func _mk_ctx(amb_gap: int, ambition: float, survival: float, rep: float) -> DecisionContext:
	var c := DecisionContext.new()
	c.leader_values = {"野心": ambition, "求生欲": survival, "貪婪": 0.5, "義氣": 0.5}
	c.ambition_gap = amb_gap
	c.absorb_target_id = 1
	c.resource_slack = 1.0
	c.absorb_yield = 1.0
	c.best_protector_rep = rep
	return c

# ★absorb_drive 掃 ambition_gap 0→5 連續（無階梯跳=WEIGH 非 GATE）+ 單調↑。
func _test_absorb_drive_continuous_ambition() -> void:
	var prev: float = -1.0
	var max_step: float = 0.0
	var mono: bool = true
	for g in range(6):
		var c := _mk_ctx(g, 0.5, 0.5, 0.5)
		var d: float = DecisionTerms.eval("absorb_drive", c, "吸納")
		if prev >= 0.0:
			max_step = maxf(max_step, absf(d - prev))
			if d < prev - 0.001: mono = false
		prev = d
	# 連續:step 有界（非硬 gate 跳）+ 單調↑（野心 gap↑→吸納 drive↑）。
	if max_step < 1.0 and mono:
		_ok("absorb_drive 掃 ambition_gap 0→5 連續(max step=%.3f)+單調↑=WEIGH 非 GATE" % max_step)
	else:
		_bad("absorb_drive 非連續/非單調 max_step=%.3f mono=%s" % [max_step, str(mono)])

# ★人格分化:高野心 absorb_drive > 低野心（有大有小湧現自人格）。
func _test_absorb_drive_ambition_differentiates() -> void:
	var lo: float = DecisionTerms.eval("absorb_drive", _mk_ctx(0, 0.5, 0.5, 0.5), "吸納")   # content
	var hi: float = DecisionTerms.eval("absorb_drive", _mk_ctx(5, 0.5, 0.5, 0.5), "吸納")   # 野心 gap 滿
	if hi > lo * 1.5:
		_ok("人格分化:高野心 absorb_drive=%.3f > 低野心=%.3f(有大有小)" % [hi, lo])
	else:
		_bad("野心未分化 absorb_drive:高=%.3f 低=%.3f" % [hi, lo])

# ★join_drive 掃野心 0→1 連續（無階梯）+ 單調↓（野心↑→low_amb↓→protection↓→stay 獨立）。
func _test_join_drive_continuous_ambition() -> void:
	var prev: float = -1.0
	var max_step: float = 0.0
	var mono_down: bool = true
	for i in range(11):
		var amb: float = float(i) / 10.0
		var c := _mk_ctx(0, amb, 0.7, 0.8)   # near 好 protector(rep 0.8)、求生欲 0.7
		var d: float = DecisionTerms.eval("join_drive", c, "併入")
		if prev >= 0.0:
			max_step = maxf(max_step, absf(d - prev))
			if d > prev + 0.001: mono_down = false
		prev = d
	if max_step < 0.5 and mono_down:
		_ok("join_drive 掃野心 0→1 連續(max step=%.3f)+單調↓(野心↑→stay)=WEIGH 非 GATE" % max_step)
	else:
		_bad("join_drive 非連續/非單調↓ max_step=%.3f mono=%s" % [max_step, str(mono_down)])

# ★理性 protection:非絕境(健康)弱隊 near 強 protector → join_drive 顯著>base 0.5(不再只絕境)。
func _test_join_protection_non_desperate() -> void:
	var no_prot: float = DecisionTerms.eval("join_drive", _mk_ctx(0, 0.2, 0.8, 0.0), "併入")   # 無 protector
	var near_prot: float = DecisionTerms.eval("join_drive", _mk_ctx(0, 0.2, 0.8, 1.0), "併入")  # near 強 protector(rep 1)
	if near_prot > no_prot + 0.2:
		_ok("理性 protection:低野心高求生 near 強 protector join_drive=%.3f > 無 protector=%.3f(非絕境理性投靠)" % [near_prot, no_prot])
	else:
		_bad("protection urgency 無效:near=%.3f no=%.3f" % [near_prot, no_prot])

func _ok(m: String) -> void: print("  [PASS] " + m)
func _bad(m: String) -> void:
	_fail += 1
	print("  [FAIL] " + m)
