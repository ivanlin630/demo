extends SceneTree
# @bed-kind: invariant
# 賣方 coin 急迫度接到【真實 payroll】——三格驗收（systems spec 2026-09-08）
#
# ★病：`_urgency` 的 coin 項用 `pop × URGENCY_COIN_COMFORT(10.0, TEST VALUE)`，
#   而世界有真實義務 payroll ⇒【領主要付薪水所以需要 coin】賣貨決策看不見。
# ★★而第③格是 R² 加的，理由我採納並在這裡寫死：
#   ①②只抓得住【方向錯】；【方向對、公式錯】（漏 anon_total、或稅率算兩次）
#   ★★★那兩格會【全綠】—— 所以必須有一格逐位元比對值本身。

var _fail: int = 0

func _ok(c: bool, m: String) -> void:
	if c: print("  [PASS] %s" % m)
	else:
		print("  [FAIL] %s" % m)
		_fail += 1

# 造一支【已知】的隊：2 名 named（技能總和已知）+ anon cohorts（已知數量）
func _mk(state: WorldState, tid: int, coin: float, skill_each: float = 1.5) -> TeamData:
	var t := TeamData.new()
	t.team_id = tid
	var ldr := PersonData.new(); ldr.id = tid * 100; ldr.team_id = tid
	# 人格全部釘死 ⇒ mult 與稅率都可以獨立手算
	ldr.values = {"貪婪": 0.5, "義氣": 0.5, "信義": 0.5, "慎重": 0.5}
	state.persons[ldr.id] = ldr
	t.leader_id = ldr.id
	for k in range(2):
		var m := PersonData.new(); m.id = tid * 100 + 1 + k; m.team_id = tid
		m.skills = {"戰鬥": skill_each}     # 技能總和 = skill_each
		state.persons[m.id] = m
		t.named_members.append(m.id)
	AnonCohort.add(t.anon_cohorts, "平民", "健康", 4)
	# ★★★給糒：`_urgency` 回 max(食物急迫, coin 急迫)。
	#   我第一版在床裡寫【食物項在此 fixture 下也是 0】―― 而那是【沒量就斷言】：
	#   隊沒糒 ⇒ food_days=0 ⇒ 食物急迫=1.0 ⇒ ②那格被食物項染紅。
	#   ★★而抳到它的是床自己 ―― 這就是那一格存在的理由。
	t.resources = {"coin": coin, "food": 100000.0}
	t.tile_pos = Vector2i(3, 3)
	state.teams[tid] = t
	return t

func _initialize() -> void:
	print("=== payroll_urgency: 三格 ===")
	var state: WorldState = MeasureBedHelper.arm_and_new()
	state.world.current_tick = 100

	# ── ③ 先跑【值對】：它是另外兩格的前提 ─────────────────────
	#   ★獨立重算：不呼叫 SalarySystem 的任何 helper，直接用常數算。
	print("  ── ③ 值對（★逐位元；①②抓不到「方向對、公式錯」）──")
	var t3: TeamData = _mk(state, 3, 0.0)
	var honor: float = (0.5 + 0.5) / 2.0
	var mult: float = clampf(1.0 + (honor - 0.5 * 0.5) * 0.4, 0.7, 1.3)
	var named_gross: float = 2.0 * (1.5 * SalarySystem.SALARY_PER_SKILL_POINT) * mult   # skill_each 預設 1.5
	var rate: float = clampf(0.5 * CoinTreasury.INCOME_TAX_K - 0.5 * CoinTreasury.INCOME_TAX_K2,
		0.0, CoinTreasury.INCOME_TAX_MAX)
	var anon: float = 4.0 * float(AnonTierSystem.TIER_STATS["平民"]["base_wage"])
	var expected: float = named_gross * (1.0 - rate) + anon
	var got: float = SalarySystem.estimated_payroll(state, t3)
	print("     獨立重算=%.10f｜estimated_payroll=%.10f（named_gross=%.4f rate=%.4f anon=%.4f）"
		% [expected, got, named_gross, rate, anon])
	_ok(is_equal_approx(expected, got), "★estimated_payroll 與獨立重算相等")
	_ok(anon > 0.0, "★★母體：anon 那半不是 0 —— 否則「漏了 anon_total」這個錯法不會被抓到")

	# ── ① 缺口大的隊：coin < payroll ⇒ coin_urg 顯著升高 ─────────
	print("  ── ① payroll 缺口大（coin < payroll）──")
	# ★要看得出【升高】，真 payroll 必須 > 舊代理 pop×10：高技能 named ⇒ payroll ≫ 60
	var t1: TeamData = _mk(state, 1, 50.0, 30.0)
	var pay1: float = SalarySystem.estimated_payroll(state, t1)
	var new1: float = TradeValuation._urgency(t1, state)
	# ★舊公式（已刪的常數）就地重算當對照：pop × 10.0
	var old1: float = clampf(1.0 - 50.0 / (maxf(float(t1.population), 1.0) * 10.0), 0.0, 1.0)
	print("     payroll=%.4f coin=50｜pop×10=%.1f｜舊式 coin_urg=%.4f → 新 urgency=%.4f" % [pay1, maxf(float(t1.population), 1.0) * 10.0, old1, new1])
	_ok(pay1 > 50.0, "★母體：這支隊真的有缺口（payroll > coin）")
	_ok(new1 > old1, "★接線後急迫度升高（%.4f → %.4f）" % [old1, new1])

	# ── ② coin 充足：coin ≥ payroll ⇒ coin_urg 必須是 0 ──────────
	print("  ── ② coin 充足（coin ≥ payroll）──")
	var t2: TeamData = _mk(state, 2, 100000.0)
	var pay2: float = SalarySystem.estimated_payroll(state, t2)
	var u2: float = TradeValuation._urgency(t2, state)
	var old2: float = clampf(1.0 - 100000.0 / (maxf(float(t2.population), 1.0) * 10.0), 0.0, 1.0)
	print("     payroll=%.4f coin=100000｜舊式=%.4f 新=%.4f" % [pay2, old2, u2])
	_ok(u2 == 0.0, "★不亂動：coin 充足 ⇒ urgency 為 0（★食物項在此床為 0，見下）")

	# ── 誠實限：食物項 ─────────────────────────────────────
	#   `_urgency` 回 max(食物急迫, coin急迫)。本床的隊沒有食物 ⇒ 食物項若非 0
	#   會把②那格染綠/染紅而與 coin 無關 ⇒ 必須把它印出來。
	print("  ── 誠實限：食物急迫項 ──")
	print("     ★三支隊都給了 food=100000 ⇒ 食物急迫項為 0，這三格量的才是 coin 項。")
	print("     ★★而我第一版沒給糒却寫【食物項也是 0】―― 沒量就斷言，被②那格抳住。")

	# ── 誠實限②的【量】（systems 要求進卷面）────────────
	#   payroll=0 的隊接線後 coin_urg=0 是【行為改變】，而【哪些隊會受影響】必須量。
	#   ★R² 訂正過 systems：不得用「純匿名村」代替 ―― anon 也有工資，
	#     只要 anon_cohorts 非空 payroll 就 > 0 ⇒ 那個代理是錯的。這裡量真值。
	print("  ── 誠實限②：estimated_payroll == 0 的隊佔比（真世界）──")
	var w: WorldState = MeasureBedHelper.arm_and_setup("res://config/warring_states.json")
	var zero: int = 0
	var tot: int = 0
	for tid in w.teams:
		tot += 1
		if SalarySystem.estimated_payroll(w, w.teams[tid]) <= 0.0:
			zero += 1
	if tot == 0:
		print("     ★母體為空（世界裡 0 支隊）⇒ 不可判，不是【0%%】")
		_ok(false, "誠實限②的母體必須存在")
	else:
		print("     %d / %d 支隊 payroll == 0（%.1f%%）⇒ 接線後這些隊 coin_urg 恆為 0"
			% [zero, tot, float(zero) / float(tot) * 100.0])
		print("     ★這是【誠實】不是【遺漏】：沒有薪資義務就沒有薪資壓力。")

	if _fail == 0: print("=== DONE === ALL PASS")
	else: print("=== DONE === %d FAIL" % _fail)
	quit()
