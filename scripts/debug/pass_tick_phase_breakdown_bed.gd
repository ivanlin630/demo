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
	var other_dts: Array = []   # ★B3 需要【全體 tick】的分位數,不只總和
	# ★裁定(A)天花板派工(2026-09-23,systems)：母體只取 dt>2s 的 pass tick,獨立第二份聚合
	var pass_sr_over2s: Dictionary = {}
	var pass_dt_over2s: int = 0
	var pass_n_over2s: int = 0
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
			if dt > 2000000:
				pass_n_over2s += 1
				pass_dt_over2s += dt
				for k2sr2 in runner._ph:
					pass_sr_over2s[k2sr2] = int(pass_sr_over2s.get(k2sr2, 0)) + int(runner._ph[k2sr2])
		else:
			other_n += 1
			other_dt += dt
			other_dts.append(dt)

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
	# ── ★★★B3 玩家尺（systems 派：要量的只有這一格）──
	#   ★終線是【計數歸零】：`>2s` 幀數 ＝ 0（用戶包絡）;★★而 median／p99 一起印,
	#     因為「幀數 0」與「p99 很糟但剛好在線下」在單一個數字上長得一樣。
	#   ★★★母體 ＝ **全部 tick**（pass ＋ 非 pass）—— 玩家感受到的是幀,不是 pass。
	var all_dts: Array = []
	for _d1 in pass_dts: all_dts.append(_d1)
	for _d2 in other_dts: all_dts.append(_d2)
	all_dts.sort()
	var over2s: int = 0
	for _v in all_dts:
		if int(_v) > 2000000: over2s += 1
	print("\n[PP] ★★★B3 玩家尺（母體＝全部 %d 個 tick）：>2s 幀數=%d｜median=%d us｜p99=%d us｜max=%d us" % [
		all_dts.size(), over2s, _q(all_dts, 0.5), _q(all_dts, 0.99), int(all_dts[all_dts.size() - 1])])
	print("[PP]   ★終線是【>2s 幀數 ＝ 0】;★★p99／median 一起印 —— 幀數 0 與「p99 剛好在線下」單看一個數字一樣")
	if all_dts.size() != pass_n + other_n:
		push_error("[PP][FAIL] B3 母體 %d ≠ pass %d + 非pass %d ⇒ 有 tick 沒被收進來" % [
			all_dts.size(), pass_n, other_n])
		fail += 1
	cells += 1
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
	# ★★★膠水佔比單獨一欄（systems 裁）：外層減內層 ＝ 沒掛 label 的膠水碼。
	#   ★不單獨印的話，膠水長大時會被帶寬【安靜吸收】—— 而那正是帶寬存在的副作用。
	var glue_fai: float = 100.0 * float(sr_fai - rest_sub) / maxf(float(sr_fai), 1.0)
	var glue_solo: float = 100.0 * float(sr_solo - solo_sub) / maxf(float(sr_solo), 1.0)
	print("[PP]   ★膠水佔比（外層 − 內層 ÷ 外層）：near.faction_ai = %.2f%%｜solo_think = %.2f%%" % [
		glue_fai, glue_solo])
	print("[PP]   ★★門檻（systems 定）＝ [0.85, 1.05]：上界 1.05 是【構造推導】——",
		"內層 ⊆ 外層 ⇒ 比值 > 1 在構造上不可能，那是重複計數，不是品味問題")
	var r1: float = float(solo_sub) / maxf(float(sr_solo), 1.0)
	var r2: float = float(rest_sub) / maxf(float(sr_fai), 1.0)
	if sr_solo == 0 or sr_fai == 0:
		push_error("[PP][不可判] 第二本缺 solo_think／near.faction_ai ⇒ 互驗沒有對象")
		fail += 1
	elif r1 < 0.85 or r1 > 1.05 or r2 < 0.85 or r2 > 1.05:
		push_error("[PP][需人看] 互驗比值 %.3f／%.3f 落在 [0.85,1.05] 之外 ⇒ ★兩本帳其中一本在說謊" % [r1, r2])
		fail += 1
	# ── ★★★陽性對照：證明這個互驗【真的會紅】（★一次就過的檢查沒有鑑別力）──
	#   ★做法：把 `loop2.solo` 子樹【故意錯歸】到另一邊（＝「有人把 solo 登記成 faction_ai 的兒子」）
	#   ⇒ 比值必須因此跑出 [0.5, 1.5]。★★用的是【同一份真實資料】,不是我捏的數字。
	var r2_bad: float = float(rest_sub + solo_sub) / maxf(float(sr_fai), 1.0)
	var ctrl_fires: bool = (r2_bad < 0.85 or r2_bad > 1.05)
	print("[PP]   ★陽性對照（把 solo 子樹錯歸給 near.faction_ai）：比值 = %.3f ⇒ %s" % [
		r2_bad, "會紅 ✔（互驗有鑑別力）" if ctrl_fires else "★不會紅 ✘（互驗對這種錯歸不敏感）"])
	print("[PP]   ★★它贏了 %.3f（上界 1.05）—— ★舊帶寬 [0.5,1.5] 只贏 0.03 ＝ 幾乎沒有鑑別力。" % absf(r2_bad - 1.05))
	print("[PP]   ★★★而上界 1.05 同時是【重複計數偵測器】：比值 > 1.05 就是內層大於外層。")
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

	# ★★★裁定(A)天花板(systems 2026-09-23派)：母體只取 dt>2s 的 pass tick，
	#   問「必須留在整點那7格合計」是否 < 1000ms。
	#   ★7格與 SimRunner.SYSTEMS 的 tl 對照(sim_runner.gd:205-217)：
	#     vision→near.vision(乾淨) move→near.move(含strategic_move)
	#     propagate/intel→無tl,時間灌進【market】的 near.messages(3格黏一起,分不開)
	#     market→near.messages(同上) interactions→near.interact(乾淨)
	#     faction_snapshot→無tl,時間灌進【ambush】的 near.outpost_ambush(與outpost_tick一起,分不開)
	print("\n[PP] ══════ ★★★裁定(A)天花板：母體=dt>2s 的 pass tick(%d 個，占全部 pass tick %d 個中的子集) ══════" % [
		pass_n_over2s, pass_n])
	if pass_n_over2s == 0:
		print("[PP][不可判-丙類母體] 這一輪(seed=%d)窗內沒有 dt>2s 的 pass tick ⇒ 這格量不到，不是「很便宜」" % sd)
		print("[PP] ★★★【已退役】(systems 裁 2026-09-23，同 blueprint 退役 P7 的那一條)：")
		print("[PP]   ★這一段的母體(dt>2s 的 pass tick)在【世代 8 起絕跡】——實測尖峰 242ms ＝ 門檻的 12%")
		print("[PP]   ★★它不是量測壞了，是散相位把凍結修掉了(P2 兩 seed 皆 PASS)⇒ 母體消失是【預期的好事】")
		print("[PP]   ★★★而【恆不可判】跟【恆綠】一樣沒有資訊，且更難抓——恆綠至少有人會問「它真的會紅嗎」，")
		print("[PP]     恆不可判長得像【謹慎】⇒ 所以這裡要逐字寫「已退役」，不要讓它靜靜地印不可判")
		print("[PP]   ★不採【降門檻】：那會換掉母體定義而床名／格名沒換 ⇒ 下一個人會把兩個不同的東西擺在一起比")
		print("[PP]   ⇒ 回訪掛鉤 defers.tsv `pass-dt-over-2s-population-extinct`（凍結回來的那天它會叫醒人）")
		print("[PP]   ⇒ ★★底下那段三格分帳的 code 【留著沒刪】：它是對的，只是現在沒有母體餵它")
	else:
		var ceil_labels: Dictionary = {
			"vision": "near.vision", "move": "near.move",
			"market/propagate/intel(黏一起,分不開)": "near.messages",
			"interactions": "near.interact",
			"faction_snapshot(與outpost_tick/ambush黏一起,分不開)": "near.outpost_ambush",
		}
		var ceil_sum: int = 0
		var ceil_missing: Array = []
		print("[PP] 逐格(母體=%d 個>2s pass tick 的累計)：" % pass_n_over2s)
		for label in ceil_labels:
			var tag: String = String(ceil_labels[label])
			if pass_sr_over2s.has(tag):
				var v3: int = int(pass_sr_over2s[tag])
				ceil_sum += v3
				print("[PP]   %-46s [%s] = %d us（每 pass 平均 %d us）" % [
					label, tag, v3, int(v3 / maxi(pass_n_over2s, 1))])
			else:
				ceil_missing.append(label)
				print("[PP]   %-46s [%s] = ★找不到（丙：不可判，未量到）" % [label, tag])
		var ceil_ms_total: float = float(ceil_sum) / 1000.0   # ★跨 pass_n_over2s 個tick的累計,不是判準用的那個數
		var ceil_ms_per_pass: float = ceil_ms_total / float(pass_n_over2s)   # ★★判準比的是這個(單一pass tick該花多少)
		print("[PP] ★7格對應的5個可量標籤累計(跨%d個>2s pass tick) = %d us（%.1f ms），★判準用【每 pass 平均】= %.1f ms" % [
			pass_n_over2s, ceil_sum, ceil_ms_total, ceil_ms_per_pass])
		print("[PP]   ★誠實限：每 pass 平均是【超集】(含 strategic_move/outpost_tick/ambush 三個非目標格的時間)，")
		print("[PP]     ⇒ 若超集 < 1000ms，真正7格子集必然也 < 1000ms(甲成立更穩)；")
		print("[PP]     ⇒ 若超集 ≥ 1000ms，不能反推子集也 ≥（丙的訊息還在：propagate/intel/faction_snapshot本身不可判）")
		if ceil_missing.is_empty() and ceil_ms_per_pass < 1000.0:
			print("[PP] ★★★判準(甲)：每pass平均 < 1000ms ⇒ (A) 的天花板【夠】，p99<1s 摸得到")
		elif ceil_ms_per_pass >= 1000.0:
			print("[PP] ★★★判準(乙)：每pass平均 ≥ 1000ms ⇒ (A) 也摸不到門檻")

		# ★★★讀數規則（systems 裁 2026-09-23 第二封）：這裡要【三格】不是兩格。
		#   ★世界原本被分成①必須整點②可按【隊】錯開，而世代 8 之後多了第三種：
		#     ③按【勢力】錯開 —— `faction_ai`(shape=factions) 現在在這一格。
		#   ★★把它塞①會【高估 S_fixed】(它其實已經散開了)；塞②會【說謊】(它不是按隊散的,
		#     而「按隊」正是上一輪的病根) ⇒ 二分法的 else 吞掉第三格。
		#   ★★★所以 S_fixed 的定義同步收窄成【對所有隊在同一顆 tick 上跑】,
		#     而 faction_ai 不再符合 ⇒ ★它【退出】S_fixed。
		#   ⇒ ★★與世代 7 的 S_fixed【不可直接比】：★★★單位換了而名字沒換（同 Probe 鍵那顆的形狀）。
		#
		# ★涵蓋範圍另記：sim_runner 的 `tl` 是【群組邊界】不是逐列標籤
		#   (sim_runner.gd:465-467 `if phase_timing and tl != "": _pht(tl, _t)`)
		#   ⇒ fai_loop2／fai_loop3 的 tl 雖為空,它們的時間由下一個 `near.faction_ai` 標記
		#     (info_dispatch 那一列)一併收走 ⇒ near.faction_ai 仍含 loop1+loop2+loop3。
		#   ★★28 列裡有 15 列 tl 為空 ⇒ 空是【常態】,不是拆三份造成的異常。
		var fai_v: int = int(pass_sr_over2s.get("near.faction_ai", 0))
		var has_fai: bool = pass_sr_over2s.has("near.faction_ai")
		print("[PP] ── ★★★三格分帳（★S_fixed 的定義在世代 8 換過，見上註解）──")
		if not has_fai:
			print("[PP]   ③勢力相位 near.faction_ai = ★找不到（丙：不可判）")
		else:
			var tot_over2s: int = maxi(pass_dt_over2s, 1)
			var rest_v: int = pass_dt_over2s - ceil_sum - fai_v
			var p1: float = 100.0 * float(ceil_sum) / float(tot_over2s)
			var p3: float = 100.0 * float(fai_v) / float(tot_over2s)
			var p2: float = 100.0 * float(rest_v) / float(tot_over2s)
			print("[PP]   ①必須整點 S_fixed(7格/5標籤，★已不含 faction_ai) = %d us（%.1f%%，每 pass 平均 %d us）" % [
				ceil_sum, p1, int(ceil_sum / maxi(pass_n_over2s, 1))])
			print("[PP]   ③按【勢力】錯開 near.faction_ai(含 loop1+loop2+loop3) = %d us（%.1f%%，每 pass 平均 %d us）" % [
				fai_v, p3, int(fai_v / maxi(pass_n_over2s, 1))])
			print("[PP]   ②按【隊】錯開＋未貼標籤 = %d us（%.1f%%）★★這一格是【殘差】不是量到的：" % [rest_v, p2])
			print("[PP]     ⇒ 它＝總 dt 減掉①③,所以它同時吃下【沒有 tl 的那些段落】⇒ ★不可當成「按隊錯開的成本」")
			# ★★★不要在這裡印「①+②+③ = 總量」：②是用【總量減①③】算出來的
			#   ⇒ 那條等式【恆真】，它不是判準是複述。恆真項紅不起來，等於沒有守衛。
			# ★真正會紅的是這一條：①與③都是【量到的】，它們的和不得超過母體總 dt。
			#   超過 ⇒ 標籤重複計數／母體對不上 ⇒ 分帳自己壞了（不是世界的問題）。
			print("[PP]   ★貼到標籤的份額 = %.1f%%（①%.1f%% + ③%.1f%%）｜殘差②%.1f%% 內含所有【沒有 tl】的段落" % [
				p1 + p3, p1, p3, p2])
			if ceil_sum + fai_v > pass_dt_over2s:
				push_error("[PP][FAIL] ①+③ = %d us > 母體總 dt %d us ⇒ ★標籤重複計數或母體對不上" % [
					ceil_sum + fai_v, pass_dt_over2s])
				fail += 1
			if rest_v < 0:
				push_error("[PP][FAIL] 殘差②為負(%d us) ⇒ ★同上，分帳壞了" % rest_v)
				fail += 1
			# ★★★母體地板（systems 補的鏡子）：上面兩條只在【多算】那一側會紅。
			#   ★少算那一側 —— 某個標籤不再送達 ⇒ ceil_sum 或 fai_v 變小
			#     ⇒ 殘差②【默默變大】把它吃掉 ⇒ ★★上面兩條都不會紅。
			#   ★★★殘差桶天生會吸收少算：【量到 0】與【沒量到】在殘差制度下長得一模一樣。
			# ⇒ 而這一格的陽性對照不用另外造：faction_ai 每小時都跑、那 7 格也是
			#   ⇒ ★它們【本來就必然非零】⇒ 變 0 只可能是儀器，不是世界。
			if ceil_sum <= 0 or fai_v <= 0:
				print("[PP] ★★★【不可判】(不是紅也不是綠)：ceil_sum=%d fai_v=%d 有一邊是 0" % [ceil_sum, fai_v])
				print("[PP]   ⇒ ★這兩個量【必然非零】(faction_ai 每小時跑、那 7 格也是)")
				print("[PP]   ⇒ ★★所以 0 的意思是【標籤沒有送達】，不是【那些系統不花時間】")
				print("[PP]   ⇒ ★★★而三格的百分比在這種情況下【不可引用】——殘差已經把缺口吃掉了")
			if p1 <= 40.0:
				print("[PP] ★★★子判準(甲)：S_fixed %.1f%% ≤ 40%% ⇒ 夠" % p1)
			elif p3 >= 15.0:
				print("[PP] ★★★子判準(乙)：S_fixed > 40%% 且勢力相位 ≥ 15%% ⇒ 成為【前置票】")
				print("[PP]   ★而它原本寫的處方(『先讓 _evaluate_all_body 真的吃 team_ids』)【已經做完了】(16c5e0409+世代 8 拆三份)")
				print("[PP]   ⇒ ★★所以這一格若現在點火,它指的是【一個新的、還沒被診斷的成因】,不是那張舊前置票")
			else:
				print("[PP] ★★★子判準：S_fixed > 40%% 但勢力相位 < 15%% ⇒ 照原本三格判準另議")
		print("[PP]   ★丙類(找不到對應標籤)：%d 格：%s" % [
			ceil_missing.size(), ", ".join(ceil_missing) if not ceil_missing.is_empty() else "（無，本次全部找到，但2組各3/3格黏一起不可拆）"])
	# ★不計入 cells／9 到場點名(那組是既有9格的自檢基準,本區塊是額外派工,不動原有計數)

	print("\n[誠實限] ①`phase_timing` 開著 ⇒ production 對 >100ms 的 tick 會印 [FaiPhase]／[PhaseSpike]，")
	print("[誠實限]   那個 I/O 在 dt 量完【之後】發生,但會壓到【下一個 tick】的量測")
	print("[誠實限] ②相位只涵蓋有掛 label 的段落 ⇒ 見涵蓋率那一格,不可當成 100%%")
	print("[誠實限] ③時間數字只能跟【同一顆 CPU】的數字比（見卷首 [HW] 行）")
	print("=== pass_tick_phase_breakdown DONE（fail=%d｜到場點名 %d／9）===" % [fail, cells])
	if cells != 9:
		push_error("[FAIL] 到場點名 %d／9 ⇒ 有格沒跑到" % cells)
		fail += 1
	quit(1 if fail > 0 else 0)

func _q(sorted_arr: Array, q: float) -> int:
	var idx: int = int(floor(q * float(sorted_arr.size() - 1)))
	return int(sorted_arr[clampi(idx, 0, sorted_arr.size() - 1)])
