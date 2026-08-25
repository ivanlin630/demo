extends SceneTree
# ★施工漏斗 ①②段的【非零證據 + 對帳】床（systems 派 2026-08-26）。
#   ★判準三條（他寫死的）：①每段都要有分母 ②`fp` 不變 ③每顆 counter 至少非零過一次，
#     ★恆 0 的要講明是【掛錯位置】還是【那條路不可達】——本床把兩者分開印，不替它選。
#   ★★對帳式：`四個分支相加 == delegate.entry`（★分支計數自帶稽核，不必人眼相信）。
# env：LW_CONFIG / PERF_SEED / ADHOC_DAYS / PERF_OUT

const STAGE1: Array = ["funnel.cand.emitted", "funnel.decide.total",
	"funnel.decide.winner_cand", "funnel.decide.winner_static"]
const RANK_BUCKETS: Array = ["funnel.cand.best_rank.0_won", "funnel.cand.best_rank.1_2",
	"funnel.cand.best_rank.3_5", "funnel.cand.best_rank.6plus"]
const BRANCHES: Array = ["funnel.delegate.branch_convoy", "funnel.delegate.branch_build",
	"funnel.delegate.branch_facility", "funnel.delegate.branch_generic"]
const GATES: Array = ["funnel.build_gate.busy_subteam", "funnel.build_gate.tile_occupied",
	"funnel.build_gate.cost", "funnel.build_gate.no_advisor", "funnel.build_gate.pop",
	"funnel.build_gate.food_bridge", "funnel.build_gate.subteam_dispatch",
	"funnel.build_gate.dispatched"]
const STAGE2_OUTCOME: Array = ["delegate.build_ok", "delegate.build_fail",
	"funnel.delegate.facility_ok", "funnel.delegate.facility_fail",
	"funnel.delegate.generic_ok", "funnel.delegate.generic_fail",
	"funnel.delegate.generic_drop_no_advisor"]

func _initialize() -> void:
	_run(); quit()

func _run() -> void:
	var cfg: String = _env("LW_CONFIG", "peaceful_economy")
	var days: int = int(_env("ADHOC_DAYS", "30"))
	var sd: int = int(_env("PERF_SEED", "1337"))
	var out_path: String = _env("PERF_OUT", "")
	print("=== 施工漏斗 ①② 非零證據：config=%s days=%d seed=%d ===" % [cfg, days, sd])
	seed(sd)
	Probe.enabled = true
	Probe.reset()
	FactionAISystem._a2b_remote_tribute_payers.clear()
	var state := WorldState.new()
	var runner := SimRunner.new()
	var config: Dictionary = GameSetup.load_config("res://config/%s.json" % cfg)
	if config.is_empty():
		print("[FAIL] config"); return
	config["seed"] = sd
	GameSetup.setup(state, config)
	var no_player := Vector2i(-1, -1)
	for _t in range(days * WorldState.TICKS_PER_DAY):
		runner.advance_tick(state, no_player)
		if state.encounter_active and state.encounter_tick > 800:
			runner._encounter_system.resolve_encounter_end(state, "draw")
		if state.teams.is_empty(): break
	var lines: Array = []
	lines.append("[%s day %d seed %d] teams=%d" % [cfg, days, sd, state.teams.size()])
	lines.append("--- ①段 candidate → winner（★每格都有分母）---")
	for k in STAGE1:
		lines.append("  %-34s = %d" % [String(k), _c(String(k))])
	var _tot: int = _c("funnel.decide.total")
	var _wc: int = _c("funnel.decide.winner_cand")
	if _tot > 0:
		lines.append("  ⇒ candidate 贏得 argmax 的比例 = %.1f%%（%d / %d）" % [100.0 * _wc / _tot, _wc, _tot])
	lines.append("  ★贏不了時排第幾（bucket）：")
	var _rank_sum: int = 0
	for k2 in RANK_BUCKETS:
		var v: int = _c(String(k2))
		_rank_sum += v
		lines.append("      %-38s = %d" % [String(k2), v])
	lines.append("      （四桶合計 = %d ＝ 有 candidate 參與的決策次數）" % _rank_sum)
	for k3 in Probe.counts.keys():
		if String(k3).begins_with("funnel.cand.by_goal."):
			lines.append("      %-38s = %d" % [String(k3), int(Probe.counts[k3])])
	lines.append("--- ②段 delegate 路由（★對帳：四分支相加 == entry）---")
	var entry: int = _c("delegate.entry")
	var bsum: int = 0
	for k4 in BRANCHES:
		var v4: int = _c(String(k4))
		bsum += v4
		lines.append("  %-34s = %d" % [String(k4), v4])
	lines.append("  %-34s = %d" % ["delegate.entry（分母）", entry])
	lines.append("  ⇒ ★對帳：四分支合計 %d vs entry %d ⇒ %s" % [bsum, entry,
		"✅一致" if bsum == entry else "❌不一致（有分支沒被計到，或有 early-return 在分支之前）"])
	lines.append("  各分支結果：")
	for k5 in STAGE2_OUTCOME:
		lines.append("      %-38s = %d" % [String(k5), _c(String(k5))])
	# ★★非零證據判讀（★恆 0 的兩種可能【不替它選】）
	lines.append("--- ★非零證據（判準③）---")
	var zeros: Array = []
	for k6 in (STAGE1 + RANK_BUCKETS + BRANCHES + STAGE2_OUTCOME + GATES):
		if _c(String(k6)) == 0:
			zeros.append(String(k6))
	if zeros.is_empty():
		lines.append("  ★全部 counter 皆非零 ⇒ 每一顆都至少被走到一次")
	else:
		lines.append("  ★以下 counter 在本輪為 0（%d 顆）——★兩種可能，這裡不替它選：" % zeros.size())
		for z in zeros:
			lines.append("      %s" % String(z))
		lines.append("  (a) 掛錯位置（那段 code 有跑但 counter 沒接到）")
		lines.append("  (b) 那條路在這張床上不可達（例：無 convoy 需求／無 facility 委派）")
		lines.append("  ★分辨法：看它【同段的分母】—— 分母非零而它為 0 ⇒ 偏向 (b)；分母也是 0 ⇒ 先查 (a)")
	# ★③④段：dispatch 前掉在【哪一道閘】——★七道閘 ＋ 成功端，相加必須 == attempt。
	#   ★★這一段的價值不是「失敗幾次」（那本來就有），是【失敗在哪裡】：
	#     「已經有子隊在蓋」與「資源不夠」在外面長得一樣（都是 return false），處置卻完全相反。
	lines.append("--- ③④段 build dispatch 的七道閘（★對帳：七閘＋成功 == attempt）---")
	var att: int = _c("dispatch_builder.attempt")
	var gsum: int = 0
	for kg in GATES:
		var vg: int = _c(String(kg))
		gsum += vg
		lines.append("  %-40s = %d" % [String(kg), vg])
	for kg2 in Probe.counts.keys():
		if String(kg2).begins_with("funnel.build_gate.cost."):
			lines.append("      %-36s = %d" % [String(kg2), int(Probe.counts[kg2])])
	lines.append("  %-40s = %d" % ["dispatch_builder.attempt（分母）", att])
	lines.append("  ⇒ ★對帳：七閘＋成功 %d vs attempt %d ⇒ %s" % [gsum, att,
		"✅一致" if gsum == att else "❌不一致（有 return 路徑沒被計到）"])
	# ★★★死水兩欄的最小形式（systems 2026-08-26）：為了回答問題而加的欄位，
	#   要證明它【問得出】那個問題——不是「加了欄位但永遠只有一筆」。
	lines.append("--- ★`tick`/`team` 欄位的實例證明（同 tick 同 team 多 candidate）---")
	var ids: Array = Probe.samples.get("funnel.cand.identity", []) as Array
	var by_key: Dictionary = {}
	for smp in ids:
		var kk: String = "%d|%d" % [int(smp.get("tick", -1)), int(smp.get("team", -1))]
		if not by_key.has(kk): by_key[kk] = []
		(by_key[kk] as Array).append(smp)
	var multi: int = 0
	var example: Array = []
	for k7 in by_key:
		if (by_key[k7] as Array).size() > 1:
			multi += 1
			if example.is_empty(): example = by_key[k7] as Array
	lines.append("  樣本 %d 筆 → (tick,team) 組合 %d 個，其中【同組多 candidate】= %d 組" % [ids.size(), by_key.size(), multi])
	if example.is_empty():
		lines.append("  ★★零實例 ⇒ 這兩欄在本輪【回答不了它們被加進來要回答的問題】（照原樣報，不美化）")
	else:
		lines.append("  ★實例（原始樣本，未加工）：")
		for e in example:
			lines.append("      %s" % str(e))
	# ★★★「誰在嘗試」vs「誰有料」（systems 2026-08-26：這決定 arc 的方向）
	#   ★三種可能的處置完全不同：沒料的隊在嘗試＝分配／輸送問題；有料的隊也過不了＝閘或位置的問題；
	#     混合＝兩件事同時發生要分開處理。★本床只把兩邊【並排】，不替它選。
	lines.append("--- ★誰在嘗試 vs 誰有料（★並排，不下結論）---")
	var atts: Array = Probe.samples.get("dispatch_builder.attempt", []) as Array
	var per_team: Dictionary = {}
	var ticks_seen: Dictionary = {}
	for a in atts:
		var tid: int = int(a.get("team", -1))
		per_team[tid] = int(per_team.get(tid, 0)) + 1
		ticks_seen[int(a.get("tick", -1))] = true
	lines.append("  attempt 樣本 %d 筆（cap 100，母體 counter = %d）★涵蓋 %d 個不同 tick" % [
		atts.size(), _c("dispatch_builder.attempt"), ticks_seen.size()])
	if ticks_seen.size() <= 1:
		lines.append("  ★★★只有 1 個 tick ⇒ 這批樣本【不能】當成整段時間的分布（上一輪就是這樣誤讀的）")
	var tkeys: Array = per_team.keys(); tkeys.sort()
	for tk in tkeys:
		var hi_avail: float = -1.0
		var lo_avail: float = -1.0
		for a2 in atts:
			if int(a2.get("team", -1)) != int(tk): continue
			var av: float = float(a2.get("mat_avail", 0.0))
			if lo_avail < 0.0 or av < lo_avail: lo_avail = av
			if av > hi_avail: hi_avail = av
		lines.append("      Team%-3d 嘗試 %2d 次｜★嘗試【當下】material avail %.0f–%.0f" % [
			int(tk), int(per_team[tk]), lo_avail, hi_avail])
	lines.append("  ★★右欄是【嘗試當下】的公庫＋私產，不是期末存量 —— 兩者不可互換。")
	# ★★★沉默從哪一段開始（systems 2026-08-26）：總數說不出時間軸。
	#   ★四條並排看同一天：候選生不生 → 有沒有 build 類 → winner 是不是 candidate → 進不進 build 分支。
	#   ★★哪一欄先變 0，沉默就是從那一段開始的。
	lines.append("--- ★時間軸：沉默從哪一段開始（逐日，四欄並排）---")
	lines.append("  day |  cand  build |  decide  win_cand |  deleg  br_build")
	var maxd: int = 0
	for kd in Probe.counts.keys():
		var kds: String = String(kd)
		if kds.begins_with("funnel.decide.day."):
			maxd = maxi(maxd, int(kds.substr(kds.length() - 3)))
	for d in range(maxd + 1):
		var sfx: String = ".day.%03d" % d
		var c_all: int = _c("funnel.cand" + sfx)
		var c_bld: int = _c("funnel.cand.build" + sfx)
		var d_all: int = _c("funnel.decide" + sfx)
		var d_cand: int = _c("funnel.decide.winner_cand" + sfx)
		var g_ent: int = _c("funnel.delegate.entry" + sfx)
		var g_bld: int = _c("funnel.delegate.branch_build" + sfx)
		if c_all + d_all + g_ent == 0:
			continue   # ★整天完全沒有決策 → 不印（省版面，非隱藏：下面有總計對帳）
		lines.append("  %3d | %5d %5d | %6d %8d | %5d %8d" % [d, c_all, c_bld, d_all, d_cand, g_ent, g_bld])
	lines.append("  ★★對帳：逐日 decide 合計 %d vs funnel.decide.total %d ⇒ %s" % [
		_sum_days("funnel.decide.day."), _c("funnel.decide.total"),
		"✅一致" if _sum_days("funnel.decide.day.") == _c("funnel.decide.total") else "❌不一致（有日桶漏記）"])
	# ★★★被跳過的 goal：原因逐日（systems 判準：互斥且窮盡，加總 == 該日 seen）
	#   ★六類：not_active／no_def／facility_resolve_empty／prereq_all_empty／emitted_facility／emitted_prereq
	#   ★★加不回去 ⇒ 有一條 skip 路徑沒被列舉，而那條大概率就是答案。
	lines.append("--- ★goal 為什麼沒生候選（逐日，★互斥且窮盡對帳）---")
	lines.append("  day | seen | notAct noDef facEmpty preqEmpty | emitFac emitPreq | 對帳")
	var kinds: Array = ["not_active", "no_def", "facility_resolve_empty", "prereq_all_empty",
		"emitted_facility", "emitted_prereq"]
	var bad_days: int = 0
	for d2 in range(31):
		var sfx2: String = ".day.%03d" % d2
		var seen: int = _c("goal.skip.seen" + sfx2)
		if seen == 0: continue
		var vals: Array = []
		var sum2: int = 0
		for kd2 in kinds:
			var v2: int = _c("goal.skip." + String(kd2) + sfx2)
			vals.append(v2)
			sum2 += v2
		var okmark: String = "✅" if sum2 == seen else "❌差 %d" % (seen - sum2)
		if sum2 != seen: bad_days += 1
		lines.append("  %3d | %4d | %6d %5d %8d %9d | %7d %8d | %s" % [d2, seen,
			int(vals[0]), int(vals[1]), int(vals[2]), int(vals[3]), int(vals[4]), int(vals[5]), okmark])
	if bad_days > 0:
		lines.append("  ★★★%d 天對不起來 ⇒ 【有一條 skip 路徑沒被列舉】——那條大概率就是答案" % bad_days)
	else:
		lines.append("  ★★六類互斥且窮盡：每一天都加得回 seen")
	# ★status 與 goal_type 的細分（★不分桶逐日，避免 key 爆；只看總分佈）
	for k9 in Probe.counts.keys():
		var ks9: String = String(k9)
		if ks9.begins_with("goal.skip.not_active.status.") or ks9.begins_with("goal.skip.facility_resolve_empty.gt."):
			lines.append("      %-46s = %d" % [ks9, int(Probe.counts[k9])])
	# ★★★build goal 的歸宿（★母體＝BUILD_FACILITY_GOALS 常數全集，不是 goal_state）
	#   ★上一顆的盲點就是母體被削：被移除的 goal 不在 goal_state 裡 ⇒ 永遠數不到。
	#   ★★這裡八類加總必須 == seen(= 8 × 檢視輪數)。
	lines.append("--- ★build goal 的歸宿（逐日，★母體是常數全集）---")
	var fates: Array = ["kept", "readded",
		"removed_no_otile", "removed_wrong_outpost_type", "removed_already_built", "removed_desire_below_min",
		"readd_blocked_no_otile", "readd_wrong_outpost_type", "readd_already_built", "readd_desire_below_min"]
	lines.append("  day | seen | kept readd | rm:noOp rm:type rm:built rm:desire | ra:noOp ra:type ra:built ra:desire | 對帳")
	var bad2: int = 0
	for d3 in range(31):
		var sf: String = ".day.%03d" % d3
		var seen2: int = _c("goal.build_fate.seen" + sf)
		if seen2 == 0: continue
		var vs: Array = []
		var sm: int = 0
		for fk in fates:
			var vv: int = _c("goal.build_fate." + String(fk) + sf)
			vs.append(vv); sm += vv
		if sm != seen2: bad2 += 1
		lines.append("  %3d | %4d | %4d %5d | %6d %7d %8d %9d | %7d %7d %8d %9d | %s" % [d3, seen2,
			int(vs[0]), int(vs[1]), int(vs[2]), int(vs[3]), int(vs[4]), int(vs[5]),
			int(vs[6]), int(vs[7]), int(vs[8]), int(vs[9]),
			"✅" if sm == seen2 else "❌差 %d" % (seen2 - sm)])
	if bad2 > 0:
		lines.append("  ★★★%d 天對不起來 ⇒ 還有一條歸宿沒被列舉" % bad2)
	else:
		lines.append("  ★★十類互斥且窮盡：每天都加得回 seen（母體＝常數全集，不會被削）")
	for kf in Probe.counts.keys():
		if String(kf).begins_with("goal.build_fate.removed_") and String(kf).find(".gt.") > 0:
			lines.append("      %-52s = %d" % [String(kf), int(Probe.counts[kf])])
	# ★★★_resolve_build_facility 的三種歸宿（★不是「空的各種原因」）
	#   ①build_candidate＝唯一算成功　②resource_candidate＝非空但【不是 build】（穿著 facility 名字的買料）
	#   ③empty_*＝各種回空。★三者加總必須 == entry（分母＝進入函式次數）。
	lines.append("--- ★_resolve_build_facility 三種歸宿（逐日，★分母=entry）---")
	var ex: Array = ["build_candidate", "resource_candidate",
		"empty_no_fdef", "empty_already_built", "empty_wrong_outpost_type",
		"empty_pop_below_min", "empty_defer_infra"]
	lines.append("  day | entry | ★build ★res | noFdef built wrongType popLow deferInfra | 對帳")
	var bad3: int = 0
	for d4 in range(31):
		var sf4: String = ".day.%03d" % d4
		var ent: int = _c("resolver.entry" + sf4)
		if ent == 0: continue
		var vv4: Array = []
		var sm4: int = 0
		for ek in ex:
			var q: int = _c("resolver." + String(ek) + sf4)
			vv4.append(q); sm4 += q
		if sm4 != ent: bad3 += 1
		lines.append("  %3d | %5d | %6d %5d | %6d %5d %9d %6d %10d | %s" % [d4, ent,
			int(vv4[0]), int(vv4[1]), int(vv4[2]), int(vv4[3]), int(vv4[4]), int(vv4[5]), int(vv4[6]),
			"✅" if sm4 == ent else "❌差 %d" % (ent - sm4)])
	lines.append("  ★★★%s" % ("三種歸宿互斥且窮盡：每天都加得回 entry" if bad3 == 0 else "%d 天對不起來 ⇒ 還有一條出口沒被列舉" % bad3))
	for kr in Probe.counts.keys():
		var krs: String = String(kr)
		if krs.begins_with("resolver.resource_candidate.res.") or krs.begins_with("resolver.resource_candidate.task."):
			lines.append("      %-50s = %d" % [krs, int(Probe.counts[kr])])
	var text: String = "\n".join(PackedStringArray(lines))
	print("\n" + text)
	if out_path != "":
		var f := FileAccess.open(out_path, FileAccess.WRITE)
		if f != null:
			f.store_string(text + "\n"); f.close()
	print("=== 施工漏斗 ①② DONE ===")

func _c(k: String) -> int:
	return int(Probe.counts.get(k, 0))

func _env(key: String, dflt: String) -> String:
	var v: String = OS.get_environment(key)
	return v if v != "" else dflt


func _sum_days(prefix: String) -> int:
	var t: int = 0
	for k in Probe.counts.keys():
		if String(k).begins_with(prefix): t += int(Probe.counts[k])
	return t