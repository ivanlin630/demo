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

func _mk_team(state: WorldState, tid: int, coin: float, greed_v: float, honor_v: float) -> Array:
	var t := TeamData.new()
	t.team_id = tid
	var ldr := PersonData.new(); ldr.id = tid * 100; ldr.team_id = tid
	# ★★★人格決定 `npc_salary_mult = clampf(1 + (義氣 − 貪婪×0.5)×0.4, 0.7, 1.3)`
	#   ⇒ ★【付得起卻不肯付】這個情境【機制本來就有】，我只要把它造出來：
	#     貪婪 1.0 / 義氣信義 0.0 ⇒ mult = 1 + (0 − 0.5)×0.4 = 0.8 ⇒ salary = fair×0.8
	#   ★★而我第一版用 0.5/0.5 ⇒ mult = 1.1 ⇒ 【付满還超付】，
	#     於是①那組斷言全部通過而情境根本沒造出來。
	ldr.values = {"貪婪": greed_v, "義氣": honor_v, "信義": honor_v, "慎重": 0.5}
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
	var a: Array = _mk_team(state, 1, 100000.0, 1.0, 0.0)   # ★貪婪領主：mult 0.8 ⇒ 付得起卻定低薪
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
	# ★★★舊斷言是 `paid_full + willful > 0` ―― 它在【全額付清】時也成立
	#   ⇒ ★判準①被寫成了「發薪日有跑過」，而不是「懲罰有發生」
	#   ★★一個斷言被【它本該排除的那個情形】滿足 ⇒ 它永遠不會紅。
	_ok(int(Probe.counts.get("salary.reason.underpaid_willful", 0)) > 0,
		"★①情境真的造出來了：`underpaid_willful` > 0（不是付滿）")
	_ok(int(Probe.counts.get("salary.reason.paid_full", 0)) == 0,
		"★★①且【沒有人被付滿】――否則情境是混的")
	# ★★★而這才是 spec §3① 要的那一句：【懲罰必須發生】。
	#   前兩格只確認【情境造對了】，而它確認【機制真的罰下去】。
	_ok(ma.loyalty < loy_a0, "★★★①懲罰真的發生：忠誠 %.4f → %.4f（必須下降）" % [loy_a0, ma.loyalty])
	_ok(int(Probe.counts.get("salary.reason.unpayable_local", 0)) == 0,
		"★★①有錢的隊不得被判成【付不出】")

	# ── ② 無幣村：coin = 0 ──
	print("  ── ② 無幣村（★忠誠流失必須為 0）──")
	Probe.reset(); Probe.enabled = true
	var st2: WorldState = MeasureBedHelper.arm_and_new()
	st2.world.current_tick = SalarySystem.SALARY_INTERVAL * 3
	var b: Array = _mk_team(st2, 2, 0.0, 0.5, 0.5)   # ★無幣村：人格中性，卡點只在「沒錢」
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

	# ── ③ 玩家領主定低薪──
	#   ★★★【訂正】它【不是】換軸的陽性對照―― systems 點出、我自己驗過：
	#     這格的 `budget_ratio == 1` ⇒ 改前改後都走同一分支，【改前也會綠】。
	#     它真正守的是另一件事（見下），而換軸的陽性對照在④。
	#   ★而它守的那件事仍然是真洞：NPC 的 `p.salary` 由 `fair × mult` 寫入，
	#     而玩家隊的不經過 mult ⇒ 若軸鍵在 mult，玩家【故意定零薪】會被靕默豁免。
	print("  ── ③ 玩家領主定零薪（★不得被豁免）──")
	Probe.reset(); Probe.enabled = true
	var st3: WorldState = MeasureBedHelper.arm_and_new()
	st3.world.current_tick = SalarySystem.SALARY_INTERVAL * 3
	var c3: Array = _mk_team(st3, 3, 100000.0, 0.5, 0.5)   # ★人格中性：mult=1.1（若鍵 mult 會判「慢態度好」）
	var t3: TeamData = c3[0]
	var m3: PersonData = c3[1]
	st3.player_id = t3.leader_id            # ★這一行讓它成為【玩家隊】：p.salary 不再被 mult 覆寫
	m3.salary = 0.0                          # ★★玩家故意定零薪，而團庫有錢
	t3.salary_eval_next_tick = 1
	var loy_c0: float = m3.loyalty
	SalarySystem.new().tick(st3, [3])
	print("     coin 充足 = 100000 ｜ salary=0 ｜ 忠誠 %.4f → %.4f" % [loy_c0, m3.loyalty])
	print("     reason: paid_full=%d willful=%d unpayable=%d" % [
		int(Probe.counts.get("salary.reason.paid_full", 0)),
		int(Probe.counts.get("salary.reason.underpaid_willful", 0)),
		int(Probe.counts.get("salary.reason.unpayable_local", 0))])
	_ok(int(Probe.counts.get("salary.reason.underpaid_willful", 0)) > 0,
		"★③玩家領主定零薪 ⇒ 判【不肯付】（★★若軸鍵在 npc_salary_mult，這格會紅）")
	_ok(m3.loyalty < loy_c0, "★★★③懲罰真的落在玩家領主身上：忠誠 %.4f → %.4f" % [loy_c0, m3.loyalty])
	_ok(int(Probe.counts.get("salary.reason.unpayable_local", 0)) == 0,
		"★③團庫有錢 ⇒ 不得被判成【付不出】")

	# ── ④ ★★★【真陽性對照】貪婪領主 ＋ 窮村 ──
	#   ★兩個軸【同時】成立：wage_ratio 0.8 < 1（故意定低薪）
	#     且 budget_ratio ≪ 1（團庫真的沒錢）。
	#   ★★改前：`_can_pay == false` ⇒ 直接掉進 else ⇒ 判 unpayable ⇒ 【免罰】。
	#     ―― 這就是 systems 說的【貪婪領主＋窮村照樣免罰】。
	#   ★★★改後：兩個判斷獨立 ⇒ 工資軸罰、預算軸不罰，而兩個 tap 【同時】>0。
	#   ★★★鑑別力實測（我把 HEAD 版 salary_system 換回去跑過）：
	#     舊 code ⇒ ④ 兩紅（忠誠沒掉 / willful=0），而 ①②③ 全綠――
	#     ⇒ ★【只有④有鑑別力】，這是 systems 點的那件事的實測版。
	#   ★★而【兩個 tap 同時 >0】本身【不】是獨立性的證明：
	#     互斥是 per-person-per-tick 的，而計數器是跨-tick 累加的
	#     ⇒ 舊版只要不同 tick 走不同分支，兩個也會同時 >0。真正的鑑別格是 `w4 > 0`。
	print("  ── ④ 貪婪領主＋窮村（★換軸的真陽性對照）──")
	Probe.reset(); Probe.enabled = true
	var st4: WorldState = MeasureBedHelper.arm_and_new()
	st4.world.current_tick = SalarySystem.SALARY_INTERVAL * 3
	# ★★★coin 必須是 0，不是【一點點】：tick() 一次追 3 個結算期，
	#   而 coin=1 在前兩期是【付得出】的 ⇒ 舊 code 也會在那兩期判 willful
	#   ⇒ ★★【忠誠下降】跟【兩個 tap 都 >0】舊版照樣綠 ⇒ 斷言不可能變紅。
	#   ★★★三個 tick 不是一個事件：互斥是 per-tick 的，而計數器是跨-tick 累加的。
	var c4: Array = _mk_team(st4, 4, 0.0, 1.0, 0.0)   # ★貪婪（mult 0.8）＋庫房全空
	var t4: TeamData = c4[0]
	var m4: PersonData = c4[1]
	t4.salary_eval_next_tick = 1
	var loy_d0: float = m4.loyalty
	SalarySystem.new().tick(st4, [4])
	var w4: int = int(Probe.counts.get("salary.reason.underpaid_willful", 0))
	var u4: int = int(Probe.counts.get("salary.reason.unpayable_local", 0))
	print("     coin = 0 （→ budget_ratio = 0 【每一期】）｜mult 0.8 （→ wage_ratio 0.8）")
	print("     忠誠 %.4f → %.4f ｜ willful=%d unpayable=%d" % [loy_d0, m4.loyalty, w4, u4])
	_ok(m4.loyalty < loy_d0,
		"★④貪婪領主在窮村【仍然要罰】――沒錢不是定低薪的免死金牌（改前這格必紅）")
	_ok(w4 > 0, "★★④工資軸 tap 點了：underpaid_willful > 0")
	_ok(u4 > 0, "★★★④母體：unpayable_local > 0 ⇒ 預算軸真的卡了（★這格舊版也綠，它不是鑑別格）")
