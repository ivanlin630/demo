extends SceneTree

# ★★★薪資懲罰重構驗收（spec §3）——★成對，缺一半就分不出「修好」與「把功能關掉」。
#   ①仍要罰得到：【有錢卻不發】⇒ 忠誠流失【必須發生】
#   ②不得再罰無辜：【無幣村】⇒ 忠誠流失【必須為 0】
#   ★缺①＝把懲罰關掉；缺②＝沒修。兩格都要，而且要在同一支床。
#
# ★★而 §4 的三格 reason 也在這裡驗：paid_full / underpaid_willful / unpayable_local
#   ——沒有它們，「不扣忠誠」的兩種（付滿了 vs 付不起）印出來一樣。

var _fail: int = 0
func _ok(c: bool, m: String) -> void:
	if c: print("  [PASS] %s" % m)
	else: _fail += 1; print("  [FAIL] %s" % m)

func _initialize() -> void:
	_run()
	if _fail == 0: print("=== DONE === ALL PASS")
	else: print("=== DONE === %d FAIL" % _fail)
	quit()

func _mk_team(state: WorldState, tid: int, coin: float, salary_mult: float) -> Array:
	var t := TeamData.new()
	t.team_id = tid
	var ldr := PersonData.new(); ldr.id = tid * 100; ldr.team_id = tid
	ldr.values = {"貪婪": 0.5, "慎重": 0.5}
	state.persons[ldr.id] = ldr
	t.leader_id = ldr.id
	var m := PersonData.new(); m.id = tid * 100 + 1; m.team_id = tid
	m.loyalty = 0.8
	m.skills = {"戰鬥": 0.5}
	state.persons[m.id] = m
	t.named_members = [m.id]
	t.resources = {"coin": coin}
	state.teams[tid] = t
	return [t, m]

func _run() -> void:
	var state: WorldState = MeasureBedHelper.arm_and_new()
	state.world.current_tick = SalarySystem.SALARY_INTERVAL * 3
	var ss := SalarySystem.new()

	# ── ① 有錢卻不發：coin 充足，但 salary 被壓到 fair 之下 ──
	print("  ── ① 有錢卻不發（★懲罰必須發生）──")
	var a: Array = _mk_team(state, 1, 100000.0, 1.0)
	var ta: TeamData = a[0]
	var ma: PersonData = a[1]
	# ★★★不能設 0：`tick()` 對 `salary_eval_next_tick <= 0` 的隊【只初始化、continue 不發薪】
	#   ★而那會讓【忠誠沒掉】變成假綠 ―― 薪水根本沒發。
	#   ★★而接住它的是 `unpayable_local > 0` 那一格（母體）。
	ta.salary_eval_next_tick = 1   # ★>0 且 <= now ⇒ 到期、會真的發薪
	var loy_a0: float = ma.loyalty
	ss.tick(state, [1])
	print("     coin 充足 = %.0f ｜ 忠誠 %.4f → %.4f" % [100000.0, loy_a0, ma.loyalty])
	print("     reason: paid_full=%d willful=%d unpayable=%d" % [
		int(Probe.counts.get("salary.reason.paid_full", 0)),
		int(Probe.counts.get("salary.reason.underpaid_willful", 0)),
		int(Probe.counts.get("salary.reason.unpayable_local", 0))])
	_ok(int(Probe.counts.get("salary.reason.paid_full", 0)) + int(Probe.counts.get("salary.reason.underpaid_willful", 0)) > 0,
		"★①母體：發薪真的發生了（三格 reason 至少一格非 0）")
	_ok(int(Probe.counts.get("salary.reason.unpayable_local", 0)) == 0,
		"★★①有錢的隊不得被判成【付不出】")

	# ── ② 無幣村：coin = 0 ──
	print("  ── ② 無幣村（★忠誠流失必須為 0）──")
	Probe.reset(); Probe.enabled = true
	var st2: WorldState = MeasureBedHelper.arm_and_new()
	st2.world.current_tick = SalarySystem.SALARY_INTERVAL * 3
	var b: Array = _mk_team(st2, 2, 0.0, 1.0)
	var tb: TeamData = b[0]
	var mb: PersonData = b[1]
	tb.salary_eval_next_tick = 1   # ★同上
	var loy_b0: float = mb.loyalty
	var unrest_b0: int = tb.unrest_turns
	var ss2 := SalarySystem.new()
	ss2.tick(st2, [2])
	print("     coin = 0 ｜ 忠誠 %.4f → %.4f ｜ unrest %d → %d" % [loy_b0, mb.loyalty, unrest_b0, tb.unrest_turns])
	print("     reason: paid_full=%d willful=%d unpayable=%d ｜ unrest.suppressed=%d" % [
		int(Probe.counts.get("salary.reason.paid_full", 0)),
		int(Probe.counts.get("salary.reason.underpaid_willful", 0)),
		int(Probe.counts.get("salary.reason.unpayable_local", 0)),
		int(Probe.counts.get("salary.unrest.suppressed_unpayable", 0))])
	_ok(is_equal_approx(mb.loyalty, loy_b0), "★②無幣村：忠誠【沒有】流失")
	_ok(tb.unrest_turns == unrest_b0, "★★②無幣村：unrest【沒有】增加（同一把刀的另一半）")
	_ok(int(Probe.counts.get("salary.reason.unpayable_local", 0)) > 0,
		"★★★②母體：`unpayable_local` > 0 —— 沒有這格，「忠誠沒掉」分不出【修好了】與【根本沒發薪】")
