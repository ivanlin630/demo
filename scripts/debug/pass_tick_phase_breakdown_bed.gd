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

	# ★★★第二本相位帳：`SimRunner._ph`（encounter／day_boundary／harvest／solo_think…）
	#   ★它是【SimRunner 層】的標籤，而 `_fai_ph` 是【FactionAISystem 內部】的
	#   ⇒ ★★兩本【不可相加】（solo_think 這類會同時出現在兩邊）⇒ 各印各的佔比。
	#   ★★★「無主詞的 24%」的候選名字很可能就在這一本 —— 我先前只讀了一本。
	var pass_sr: Dictionary = {}
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
			for k2sr in runner._ph:
				pass_sr[k2sr] = int(pass_sr.get(k2sr, 0)) + int(runner._ph[k2sr])
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
	# ★★★「沒被相位蓋住的時間」＝ 一列【沒有主詞的時間】,systems 裁它是候選答案不是誤差
	#   ⇒ 讓它進排名跟其他相位競爭：★若它排第一,那就是「最大的一塊還沒有名字」。
	var unnamed: int = pass_dt - self_sum
	var rows: Array = []
	for kk2 in keys: rows.append({"n": String(kk2), "v": int(selfus[kk2]), "tot": int(pass_ph[kk2])})
	rows.append({"n": "★(無主詞：未被相位蓋住)", "v": unnamed, "tot": unnamed})
	rows.sort_custom(func(a, b): return int(a["v"]) > int(b["v"]))
	print("[PP] %-38s %14s %14s %9s %12s" % ["相位", "self us", "tot us", "佔dt", "每 pass us"])
	for i3 in range(mini(21, rows.size())):
		var r3: Dictionary = rows[i3]
		print("[PP] %-38s %14d %14d %8.2f%% %12d" % [String(r3["n"]), int(r3["v"]), int(r3["tot"]),
			100.0 * float(r3["v"]) / float(maxi(pass_dt, 1)), int(int(r3["v"]) / maxi(pass_n, 1))])
	cells += 1

	# ★三格的輸入也含【無主詞】那一列 —— 否則它永遠不會被選中,而它可能就是最大的一塊
	var top1: float = 100.0 * float(rows[0]["v"]) / float(maxi(pass_dt, 1))
	var top3: float = 0.0
	for i4 in range(mini(3, rows.size())):
		top3 += 100.0 * float(rows[i4]["v"]) / float(maxi(pass_dt, 1))
	print("[PP]   ★top-1 是【%s】" % String(rows[0]["n"]))
	print("\n[PP] ★三格判準的輸入（★判準與門檻是 systems 的欄，我不判）：")
	print("[PP]   ★佔的是【整個 pass tick 的 dt】不是佔 Σ相位：top-1 = %.2f%%｜top-3 = %.2f%%" % [top1, top3])
	print("[PP]   ★★相異相位 %d 個｜涵蓋率 %.1f%%（沒被相位蓋住的 %.1f%% 本身也是一格答案）" % [
		keys.size(), cov, 100.0 - cov])
	# ★★★主表是【第二本帳】：它涵蓋 99%+ ⇒ 三格要用它判，第一本是鑽進 near.faction_ai 裡面的。
	#   ★我先前只讀第一本 ⇒ 那張表的「無主詞 24%」其實在第二本裡【有名字】。
	var srk0: Array = pass_sr.keys()
	srk0.sort_custom(func(a, b): return int(pass_sr[a]) > int(pass_sr[b]))
	var sr_tot: int = 0
	for vv in pass_sr.values(): sr_tot += int(vv)
	if srk0.is_empty():
		push_error("[PP][不可判] 第二本帳空 ⇒ 三格沒有主表可判")
		fail += 1
	else:
		var s1: float = 100.0 * float(pass_sr[srk0[0]]) / float(maxi(pass_dt, 1))
		var s3: float = 0.0
		for i6 in range(mini(3, srk0.size())):
			s3 += 100.0 * float(pass_sr[srk0[i6]]) / float(maxi(pass_dt, 1))
		print("[PP]   ★★★【主表＝第二本帳，涵蓋 %.1f%%】top-1 = %s %.2f%%｜top-3 = %.2f%%｜標籤 %d 個" % [
			100.0 * float(sr_tot) / float(maxi(pass_dt, 1)), String(srk0[0]), s1, s3, srk0.size()])
	print("[PP]   ★★★①單一大頭 ②幾個中等的頭 ③攤平 —— 三格，而【中間那格】最容易被漏掉")
	cells += 1

	print("[PP] ── ★★跨父桶另表（*multi：時間已含在父親裡，★只能單獨看不能加進上表）──")
	var mk: Array = multi.duplicate()
	mk.sort_custom(func(a, b): return int(pass_ph[a]) > int(pass_ph[b]))
	for mm in mk:
		print("[PP]   %-36s tot=%12d us｜每 pass %10d us｜佔 dt %.2f%%" % [
			String(mm), int(pass_ph[mm]), int(int(pass_ph[mm]) / maxi(pass_n, 1)),
			100.0 * float(pass_ph[mm]) / float(maxi(pass_dt, 1))])

	# ── ★★★兩本帳互驗（systems 裁）：不可相加 ≠ 不可互驗 ──
	#   ★把第一本的 self 沿 PHASE_PARENT 歸到【根】,則：
	#     根 `loop2.solo` 的子樹  應 ≈ 第二本的 `solo_think`
	#     其餘所有根的總和        應 ≈ 第二本的 `near.faction_ai`
	#   ★★不一致 ⇒ ★★★**其中一本在對讀它的人說謊** —— 而那本身就是要回報的發現。
	#   ★這一格不用多跑一次：兩個數字同一輪都在手上。
	var by_root: Dictionary = {}
	for nm4 in selfus:
		if String(FactionAISystem.PHASE_PARENT.get(nm4, "")) == "*multi": continue
		var cur: String = String(nm4)
		var hops: int = 0
		while hops < 12:
			var pp: String = String(FactionAISystem.PHASE_PARENT.get(cur, ""))
			if pp == "" or pp == "*multi": break
			cur = pp
			hops += 1
		by_root[cur] = int(by_root.get(cur, 0)) + int(selfus[nm4])
	var solo_sub: int = int(by_root.get("loop2.solo", 0))
	var rest_sub: int = 0
	for rk in by_root:
		if String(rk) != "loop2.solo": rest_sub += int(by_root[rk])
	var sr_solo: int = int(pass_sr.get("solo_think", 0))
	var sr_fai: int = int(pass_sr.get("near.faction_ai", 0))
	print("[PP] ── ★★★兩本帳互驗（★不用多跑一輪）──")
	print("[PP]   loop2.solo 子樹 = %d us ｜ 第二本 solo_think = %d us ｜ 比值 = %.3f" % [
		solo_sub, sr_solo, float(solo_sub) / maxf(float(sr_solo), 1.0)])
	print("[PP]   其餘根總和      = %d us ｜ 第二本 near.faction_ai = %d us ｜ 比值 = %.3f" % [
		rest_sub, sr_fai, float(rest_sub) / maxf(float(sr_fai), 1.0)])
	print("[PP]   ★門檻是 systems 的欄；我只在比值落在 [0.5, 1.5] 之外時標【需人看】")
	var r1: float = float(solo_sub) / maxf(float(sr_solo), 1.0)
	var r2: float = float(rest_sub) / maxf(float(sr_fai), 1.0)
	if sr_solo == 0 or sr_fai == 0:
		push_error("[PP][不可判] 第二本缺 solo_think／near.faction_ai ⇒ 互驗沒有對象")
		fail += 1
	elif r1 < 0.5 or r1 > 1.5 or r2 < 0.5 or r2 > 1.5:
		push_error("[PP][需人看] 互驗比值 %.3f／%.3f 落在 [0.5,1.5] 之外 ⇒ ★兩本帳其中一本在說謊" % [r1, r2])
		fail += 1
	# ── ★★★陽性對照：證明這個互驗【真的會紅】（★一次就過的檢查沒有鑑別力）──
	#   ★做法：把 `loop2.solo` 子樹【故意錯歸】到另一邊（＝「有人把 solo 登記成 faction_ai 的兒子」）
	#   ⇒ 比值必須因此跑出 [0.5, 1.5]。★★用的是【同一份真實資料】,不是我捏的數字。
	var r2_bad: float = float(rest_sub + solo_sub) / maxf(float(sr_fai), 1.0)
	var ctrl_fires: bool = (r2_bad < 0.5 or r2_bad > 1.5)
	print("[PP]   ★陽性對照（把 solo 子樹錯歸給 near.faction_ai）：比值 = %.3f ⇒ %s" % [
		r2_bad, "會紅 ✔（互驗有鑑別力）" if ctrl_fires else "★不會紅 ✘（互驗對這種錯歸不敏感）"])
	print("[PP]   ★★而它【只贏 %.3f】—— 這個帶寬對【這一種】錯歸幾乎不敏感。" % absf(r2_bad - 1.5))
	print("[PP]   ★★★門檻是 systems 的欄；我只回報：現在的 [0.5,1.5] 是【勉強】點火，不是穩穩點火。")
	if not ctrl_fires:
		push_error("[PP][FAIL] 陽性對照沒點火 ⇒ ★這個互驗對【歸錯父親】不敏感,綠了也不代表兩本一致")
		fail += 1
	cells += 1

	print("[PP] ── ★★★第二本帳：`SimRunner._ph`（★不與上表相加：兩層標籤會互相包含）──")
	var srk: Array = pass_sr.keys()
	srk.sort_custom(func(a, b): return int(pass_sr[a]) > int(pass_sr[b]))
	var sr_sum: int = 0
	for v5 in pass_sr.values(): sr_sum += int(v5)
	print("[PP]   相異標籤 %d 個｜Σ = %d us ＝ pass 總 dt 的 %.1f%%" % [
		srk.size(), sr_sum, 100.0 * float(sr_sum) / float(maxi(pass_dt, 1))])
	for s5 in srk:
		print("[PP]   [SR] %-28s %14d us｜每 pass %10d us｜佔 dt %6.2f%%" % [
			String(s5), int(pass_sr[s5]), int(int(pass_sr[s5]) / maxi(pass_n, 1)),
			100.0 * float(pass_sr[s5]) / float(maxi(pass_dt, 1))])
	if srk.is_empty():
		push_error("[PP][不可判] 第二本帳是空的 ⇒ `_ph` 沒接上（不是它沒花時間）")
		fail += 1
	cells += 1

	print("\n[PP] ── production 自己的 phase_report（同一份資料，另一支既有的眼睛）──")
	print(FactionAISystem.phase_report(pass_ph, pass_dt))
	cells += 1   # ★跨父桶另表 ＋ production 自己的 phase_report

	print("\n[誠實限] ①`phase_timing` 開著 ⇒ production 對 >100ms 的 tick 會印 [FaiPhase]／[PhaseSpike]，")
	print("[誠實限]   那個 I/O 在 dt 量完【之後】發生,但會壓到【下一個 tick】的量測")
	print("[誠實限] ②相位只涵蓋有掛 label 的段落 ⇒ 見涵蓋率那一格,不可當成 100%%")
	print("[誠實限] ③時間數字只能跟【同一顆 CPU】的數字比（見卷首 [HW] 行）")
	print("=== pass_tick_phase_breakdown DONE（fail=%d｜到場點名 %d／8）===" % [fail, cells])
	if cells != 8:
		push_error("[FAIL] 到場點名 %d／8 ⇒ 有格沒跑到" % cells)
		fail += 1
	quit(1 if fail > 0 else 0)

func _q(sorted_arr: Array, q: float) -> int:
	var idx: int = int(floor(q * float(sorted_arr.size() - 1)))
	return int(sorted_arr[clampi(idx, 0, sorted_arr.size() - 1)])
