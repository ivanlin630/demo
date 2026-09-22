extends SceneTree
# @bed-kind: diagnostic
# slice: 每小時全世界 pass —— ★pass tick 的 dt 按【相位】拆解（★純量測，不改 production code）
#
# ★★★這一床要回答的只有一件事：**那 1.2 秒花在哪裡**。
#   ★systems 的三格判準（他寫的，我不改）：
#     ①單一大頭 ⇒ 修那一個，架構不用動
#     ②幾個中等的頭 ⇒ 修 2~3 處，仍不必架構
#     ③真的攤平 ⇒ 才是結構問題
#   ⇒ ★我印【份額】,三格怎麼判是 systems 的欄。
# ★★★承重的對照格 ＝ **涵蓋率 Σphase ÷ dt**：
#   相位表只蓋住 30% 的話，「top-1 佔 60%」講的是【被蓋住那部分】的 60%，不是那 1.2 秒的 60%
#   ⇒ ★沒有這一格，整張拆解表可以在不知情下把人指向錯的地方。
# ★量具是既有的（`SimRunner.phase_timing` ＋ `FactionAISystem._fai_ph`）——我只打開它、自己累加。
# ★★dt 我自己在床裡量（`Time.get_ticks_usec()` 包住 `advance_tick`）⇒ 不需要 production 有取樣欄位。
# ★★誠實限：`phase_timing` 開著時 production 會對 >100ms 的 tick 印 `[FaiPhase]`／`[PhaseSpike]`
#   ⇒ 那個 I/O 發生在 dt 量完【之後】，但它會壓到【下一個 tick】的量測 ⇒ 標在卷面上。
#
# env：PP_DAYS（預設 12）／PP_SEED（預設 1337）／PP_CONFIG（預設 warring_states）

const PASS: int = 60   # ★sim_runner 的 NEAR_CADENCE；★★床這邊用字面值,並在下面跟真常數對一次

func _initialize() -> void:
	var days: int = int(OS.get_environment("PP_DAYS")) if OS.has_environment("PP_DAYS") else 12
	var sd: int = int(OS.get_environment("PP_SEED")) if OS.has_environment("PP_SEED") else 1337
	var cfg: String = OS.get_environment("PP_CONFIG") if OS.has_environment("PP_CONFIG") else "warring_states"
	print("=== pass tick 相位拆解（days=%d seed=%d config=%s）===" % [days, sd, cfg])
	var fail: int = 0
	var cells: int = 0

	# ★前提驗證放在【解讀輸出之前】：床用的 60 必須等於 production 的 NEAR_CADENCE
	print("[PP] ★前提：床用的 pass 週期 = %d｜SimRunner.NEAR_CADENCE = %d" % [PASS, SimRunner.NEAR_CADENCE])
	if PASS != SimRunner.NEAR_CADENCE:
		push_error("[PP][不可判] 床的 pass 週期 %d ≠ NEAR_CADENCE %d ⇒ 我量的不是那個 pass" % [
			PASS, SimRunner.NEAR_CADENCE])
		quit(2)
		return
	cells += 1

	seed(sd)
	SimRunner.phase_timing = true
	var st: WorldState = MeasureBedHelper.arm_and_setup("res://config/%s.json" % cfg)
	var runner := SimRunner.new()
	var n_ticks: int = days * WorldState.TICKS_PER_DAY

	var pass_ph: Dictionary = {}
	var pass_dt: int = 0
	var pass_n: int = 0
	var pass_cov_num: int = 0
	var other_dt: int = 0
	var other_n: int = 0
	var pass_dts: Array = []
	for _t in range(n_ticks):
		var t0: int = Time.get_ticks_usec()
		runner.advance_tick(st, Vector2i(-1, -1))
		var dt: int = Time.get_ticks_usec() - t0
		if st.world.current_tick % PASS == 0:
			pass_n += 1
			pass_dt += dt
			pass_dts.append(dt)
			var sub: int = 0
			for k in FactionAISystem._fai_ph:
				var v: int = int(FactionAISystem._fai_ph[k])
				pass_ph[k] = int(pass_ph.get(k, 0)) + v
				sub += v
			pass_cov_num += sub
		else:
			other_n += 1
			other_dt += dt

	print("\n[PP] ★母體：pass tick %d 個（期望 %d）｜非 pass tick %d 個｜共 %d tick（%d 天）" % [
		pass_n, int(n_ticks / PASS), other_n, n_ticks, days])
	if pass_n < 30:
		push_error("[PP][不可判] pass tick 只有 %d 個 ⇒ 母體塌陷" % pass_n)
		quit(2)
		return
	pass_dts.sort()
	print("[PP] pass tick dt：median=%d us（%.3f 秒）｜max=%d us｜合計=%d us" % [
		_q(pass_dts, 0.5), float(_q(pass_dts, 0.5)) / 1000000.0, int(pass_dts[pass_dts.size() - 1]), pass_dt])
	print("[PP] 非 pass tick：平均=%d us｜合計=%d us" % [int(other_dt / maxi(other_n, 1)), other_dt])
	print("[PP] ★pass ÷ 非pass（平均）= %.0f×" % [
		float(pass_dt) / float(maxi(pass_n, 1)) / maxf(float(other_dt) / float(maxi(other_n, 1)), 1.0)])
	cells += 1

	# ── ★★★self 化（★用 production 自己的 `PHASE_PARENT`，不自己發明巢狀表）──
	#   ★我第一版直接加總原始 tot ⇒ 涵蓋率 **255.7%** ——【父子都算了一遍】。
	#   ★★>100% 是母體不同源的指紋，而那一格就是為了這個存在的（它咬住了）。
	#   ★★★而 `phase_report()` 早就在做這件事 ⇒ 我改成餵它，不自己造第二份巢狀表
	#     （第二份從出生就開始 drift，而 drift 不會紅）。
	var selfus: Dictionary = {}
	var unreg: Array = []
	for nm in pass_ph:
		selfus[nm] = int(pass_ph[nm])
		if not FactionAISystem.PHASE_PARENT.has(nm): unreg.append(String(nm))
	for nm2 in pass_ph:
		var par: String = String(FactionAISystem.PHASE_PARENT.get(nm2, ""))
		if par == "" or par == "*multi": continue
		if selfus.has(par): selfus[par] = int(selfus[par]) - int(pass_ph[nm2])
	# ★★★`"*multi"` 的相位【不可相加】：它被多個外層呼叫 ⇒ 時間【已經算在父親裡】，
	#   而 PHASE_PARENT 登記它為 *multi 正是為了「不參與減法」。
	#   ⇒ ★把它算進涵蓋率 ＝ 第二次重複計數（我第二版的 115.9% 就是它）。
	#   ★★所以它另立一欄印出來 ——「不可相加」不等於「不重要」。
	var self_sum: int = 0
	var neg: Array = []
	var multi: Array = []
	for nm3 in selfus:
		if String(FactionAISystem.PHASE_PARENT.get(nm3, "")) == "*multi":
			multi.append(String(nm3))
			continue
		self_sum += int(selfus[nm3])
		if int(selfus[nm3]) < 0: neg.append("%s=%d" % [String(nm3), int(selfus[nm3])])
	var cov: float = 100.0 * float(self_sum) / float(maxi(pass_dt, 1))
	print("\n[PP] ★★★涵蓋率 = Σ【self】相位 %d us ÷ pass 總 dt %d us = **%.1f%%**" % [self_sum, pass_dt, cov])
	print("[PP]   ★未登記在 PHASE_PARENT 的相位 %d 個%s" % [unreg.size(), ("：" + ", ".join(unreg)) if unreg.size() > 0 else ""])
	print("[PP]   ★★self 為負的相位 %d 個%s（負 ＝ 兒子比父親大 ⇒ 登記錯，不是世界的事）" % [
		neg.size(), ("：" + ", ".join(neg)) if neg.size() > 0 else ""])
	if cov > 105.0:
		push_error("[PP][FAIL] 涵蓋率 %.1f%% > 105%% ⇒ ★仍在重複計數（巢狀沒扣乾淨）" % cov)
		fail += 1
	if cov < 50.0:
		push_error("[PP][警示] 涵蓋率 %.1f%% < 50%% ⇒ ★超過一半的時間【不在相位表裡】⇒ 這張表指不出真凶" % cov)
		fail += 1
	cells += 1

	print("[PP]   ★★★跨父桶（*multi，★不可相加，已排除在涵蓋率之外）%d 個：%s" % [
		multi.size(), ", ".join(multi)])
	var keys: Array = []
	for kk in selfus.keys():
		if String(FactionAISystem.PHASE_PARENT.get(kk, "")) != "*multi": keys.append(kk)
	keys.sort_custom(func(a, b): return int(selfus[a]) > int(selfus[b]))
	print("\n[PP] pass tick 相位排名（★按 self 排，不按 tot；相異相位 %d 個）" % keys.size())
	print("[PP] %-38s %14s %14s %9s %12s" % ["相位", "self us", "tot us", "佔dt", "每 pass us"])
	for i3 in range(mini(20, keys.size())):
		var k2: String = String(keys[i3])
		print("[PP] %-38s %14d %14d %8.2f%% %12d" % [k2, int(selfus[k2]), int(pass_ph[k2]),
			100.0 * float(selfus[k2]) / float(maxi(pass_dt, 1)), int(int(selfus[k2]) / maxi(pass_n, 1))])
	cells += 1

	var top1: float = 100.0 * float(selfus[keys[0]]) / float(maxi(pass_dt, 1))
	var top3: float = 0.0
	for i4 in range(mini(3, keys.size())):
		top3 += 100.0 * float(selfus[keys[i4]]) / float(maxi(pass_dt, 1))
	print("\n[PP] ★三格判準的輸入（★判準與門檻是 systems 的欄，我不判）：")
	print("[PP]   ★佔的是【整個 pass tick 的 dt】不是佔 Σ相位：top-1 = %.2f%%｜top-3 = %.2f%%" % [top1, top3])
	print("[PP]   ★★相異相位 %d 個｜涵蓋率 %.1f%%（沒被相位蓋住的 %.1f%% 本身也是一格答案）" % [
		keys.size(), cov, 100.0 - cov])
	print("[PP]   ★★★①單一大頭 ②幾個中等的頭 ③攤平 —— 三格，而【中間那格】最容易被漏掉")
	cells += 1

	print("[PP] ── ★★跨父桶另表（*multi：時間已含在父親裡，★只能單獨看不能加進上表）──")
	var mk: Array = multi.duplicate()
	mk.sort_custom(func(a, b): return int(pass_ph[a]) > int(pass_ph[b]))
	for mm in mk:
		print("[PP]   %-36s tot=%12d us｜每 pass %10d us｜佔 dt %.2f%%" % [
			String(mm), int(pass_ph[mm]), int(int(pass_ph[mm]) / maxi(pass_n, 1)),
			100.0 * float(pass_ph[mm]) / float(maxi(pass_dt, 1))])

	print("\n[PP] ── production 自己的 phase_report（同一份資料，另一支既有的眼睛）──")
	print(FactionAISystem.phase_report(pass_ph, pass_dt))
	cells += 1   # ★跨父桶另表 ＋ production 自己的 phase_report

	print("\n[誠實限] ①`phase_timing` 開著 ⇒ production 對 >100ms 的 tick 會印 [FaiPhase]／[PhaseSpike]，")
	print("[誠實限]   那個 I/O 在 dt 量完【之後】發生,但會壓到【下一個 tick】的量測")
	print("[誠實限] ②相位只涵蓋有掛 label 的段落 ⇒ 見涵蓋率那一格,不可當成 100%%")
	print("[誠實限] ③時間數字只能跟【同一顆 CPU】的數字比（見卷首 [HW] 行）")
	print("=== pass_tick_phase_breakdown DONE（fail=%d｜到場點名 %d／6）===" % [fail, cells])
	if cells != 6:
		push_error("[FAIL] 到場點名 %d／6 ⇒ 有格沒跑到" % cells)
		fail += 1
	quit(1 if fail > 0 else 0)

func _q(sorted_arr: Array, q: float) -> int:
	var idx: int = int(floor(q * float(sorted_arr.size() - 1)))
	return int(sorted_arr[clampi(idx, 0, sorted_arr.size() - 1)])
