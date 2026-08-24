extends SceneTree
# 接入 arc §3 三分流診斷床（★診斷先行、只產分流證據）。
# 報：零採集總數（母/子）、三分流計數、★逐隊歸格（不得只給總數）、camp.applicable_but_idle、
#     pop=1 村數、紮營/L0→L1/L0 廢棄 相關 tap（供後續 gate3 對照）。
# env：PERF_SEED(1337)、ADHOC_DAYS(90)、LW_CONFIG(peaceful_economy)、PERF_OUT

func _initialize() -> void:
	_run(); quit()

func _run() -> void:
	var cfg: String = OS.get_environment("LW_CONFIG") if OS.get_environment("LW_CONFIG") != "" else "peaceful_economy"
	var days: int = int(OS.get_environment("ADHOC_DAYS")) if OS.get_environment("ADHOC_DAYS") != "" else 90
	var sd: int = int(OS.get_environment("PERF_SEED")) if OS.get_environment("PERF_SEED") != "" else 1337
	var out_path: String = OS.get_environment("PERF_OUT")
	print("=== camp-access 三分流診斷：config=%s days=%d seed=%d ===" % [cfg, days, sd])
	seed(sd)
	Probe.enabled = true; Probe.reset()
	FactionAISystem._a2b_remote_tribute_payers.clear()
	var state := WorldState.new()
	var runner := SimRunner.new()
	var config: Dictionary = GameSetup.load_config("res://config/%s.json" % cfg)
	if config.is_empty(): print("[FAIL] config"); return
	config["seed"] = sd
	GameSetup.setup(state, config)
	SpecimenDumpHelper.setup_from_env(state)
	# ★systems重量令(2026-08-25,camp-access@e927be2f)：day0 owned outpost普查
	var owned_day0: Array = []
	for tid0 in state.world.tiles:
		var tt0: HexTileData = state.world.tiles[tid0]
		if tt0.outpost_level > 0 and tt0.outpost_owner != -1:
			owned_day0.append({"tile_id": tid0, "pos": [tt0.tile_pos.x, tt0.tile_pos.y], "owner": tt0.outpost_owner, "level": tt0.outpost_level})
	var no_player := Vector2i(-1, -1)
	for tick in range(days * WorldState.TICKS_PER_DAY):
		runner.advance_tick(state, no_player)
		if state.encounter_active and state.encounter_tick > 800:
			runner._encounter_system.resolve_encounter_end(state, "draw")
		if state.teams.is_empty(): break
	var lines: Array = []
	lines.append("[%s day %d seed %d] teams=%d" % [cfg, days, sd, state.teams.size()])
	lines.append("--- 零採集（病） ---")
	for k in ["collect.no_outpost_no_camp_zero_food", "collect.no_outpost_no_camp_zero_food.parent",
			"collect.no_outpost_no_camp_zero_food.subteam", "collect.l0_forage_ran"]:
		lines.append("  %-46s = %d" % [k, int(Probe.counts.get(k, 0))])
	# ★三分流的 tap 是 temp（逐 cadence 掃可耕地太貴），證據已入 handback；此處保留欄位讓重跑時看得出「已撤」。
	lines.append("--- 三分流（temp tap 已撤；證據見 2026-08-21 交件） ---")
	var tot: int = 0
	for k in ["camp.diag.i_above_desperation", "camp.diag.ii_no_farmable",
			"camp.diag.iii_applicable_but_not_chosen", "camp.diag.has_outpost_already"]:
		var v: int = int(Probe.counts.get(k, 0)); tot += v
		lines.append("  %-46s = %d" % [k, v])
	for k in ["camp.applicable_but_idle"]:
		lines.append("  %-46s = %d" % [k, int(Probe.counts.get(k, 0))])
	lines.append("--- ★逐隊歸格（不得只給總數） ---")
	var per: Dictionary = {}
	for k in Probe.counts.keys():
		var ks: String = String(k)
		if ks.begins_with("camp.diag.team"):
			var rest: String = ks.substr("camp.diag.team".length())
			var parts: PackedStringArray = rest.split(".")
			if parts.size() == 2:
				var tid: String = parts[0]
				var d: Dictionary = per.get(tid, {})
				d[parts[1]] = int(Probe.counts[k])
				per[tid] = d
	var tids: Array = per.keys(); tids.sort()
	for tid in tids:
		lines.append("    team=%s %s" % [tid, str(per[tid])])
	lines.append("--- ★分流(iii) 輸給誰 ---")
	var lost: Array = []
	for k in Probe.counts.keys():
		var ks: String = String(k)
		if ks.begins_with("camp.lost_to."):
			lost.append("  %-46s = %d" % [ks, int(Probe.counts[k])])
	lost.sort()
	for l in lost: lines.append(l)
	lines.append("  %-46s = %d" % ["camp.won_argmax", int(Probe.counts.get("camp.won_argmax", 0))])
	lines.append("--- ★紮根 funnel（驗收#1 的解釋層）---")
	lines.append("  %-46s = %d" % ["root.won_argmax", int(Probe.counts.get("root.won_argmax", 0))])
	var rl: Array = []
	for k in Probe.counts.keys():
		if String(k).begins_with("root.lost_to."): rl.append("  %-46s = %d" % [String(k), int(Probe.counts[k])])
	rl.sort()
	for l in rl: lines.append(l)
	if rl.is_empty() and int(Probe.counts.get("root.won_argmax", 0)) == 0:
		lines.append("  ★紮根從未進入候選（applicable 都沒過）")
	if Probe.samples.has("camp.lost"):
		for smp in Probe.samples["camp.lost"].slice(0, 10):
			lines.append("    [camp.lost] %s" % str(smp))
	if Probe.samples.has("camp.drive_parts"):
		lines.append("--- ★camp_drive 零件（分流 iii 第三層） ---")
		for smp in Probe.samples["camp.drive_parts"].slice(0, 10):
			lines.append("    %s" % str(smp))
	for k in Probe.counts.keys():
		var kr: String = String(k)
		if kr.begins_with("root.commit_drop.") or kr.begins_with("settlement.l0_to_l1") or kr.begins_with("construct.complete"):
			lines.append("  %-46s = %d" % [kr, int(Probe.counts[k])])
	lines.append("--- 世界狀態（gate1/6 用） ---")
	var pop1: int = 0
	var pop_total: int = 0
	for t2 in state.teams:
		var t: TeamData = state.teams[t2]
		if t.beast_kind != "" or t.parent_team_id != -1: continue
		pop_total += t.population
		if t.population <= 1: pop1 += 1
	lines.append("  pop=1 村數 = %d｜母隊人口合計 = %d" % [pop1, pop_total])
	for k in ["breed.born", "camp.built", "outpost.l0_to_l1", "camp.abandoned"]:
		if Probe.counts.has(k): lines.append("  %-46s = %d" % [k, int(Probe.counts[k])])
	if Probe.samples.has("camp.diag"):
		lines.append("--- 樣本（前 12） ---")
		for smp in Probe.samples["camp.diag"].slice(0, 12):
			lines.append("    %s" % str(smp))
	# ★systems重量令(2026-08-25)：day90 owned outpost普查+對照day0
	var owned_day90: Array = []
	for tid9 in state.world.tiles:
		var tt9: HexTileData = state.world.tiles[tid9]
		if tt9.outpost_level > 0 and tt9.outpost_owner != -1:
			owned_day90.append({"tile_id": tid9, "pos": [tt9.tile_pos.x, tt9.tile_pos.y], "owner": tt9.outpost_owner, "level": tt9.outpost_level})
	lines.append("★★★outpost普查(重量令)：")
	lines.append("  day0 owned outpost數 = %d" % owned_day0.size())
	lines.append("  day90 owned outpost數 = %d" % owned_day90.size())
	var day0_ids2: Dictionary = {}
	for o in owned_day0: day0_ids2[int(o["tile_id"])] = true
	var new_since2: Array = []
	for o in owned_day90:
		if not day0_ids2.has(int(o["tile_id"])): new_since2.append(o)
	lines.append("  ★遊戲中途新增的outpost數 = %d (%s)" % [new_since2.size(), str(new_since2)])
	# ★systems重量令：四tap(標籤更正=本輪最大值,非最後一次;Probe.note存的是peak)
	lines.append("★★CAMP_MARGINAL_CAP saturation率：")
	var dce2: int = int(Probe.counts.get("discount.camp_evaluated", 0))
	var dcc2: int = int(Probe.counts.get("discount.camp_capped", 0))
	lines.append("  discount.camp_evaluated = %d" % dce2)
	lines.append("  discount.camp_capped    = %d (%.1f%%)" % [dcc2, 100.0*dcc2/maxf(dce2,1)])
	lines.append("  discount.camp_raw_u(本輪最大值,Probe.note=peak非最後一次) = %s" % str(Probe.peaks.get("discount.camp_raw_u", "無")))
	lines.append("  discount.horizon_eff(本輪最大值)                        = %s" % str(Probe.peaks.get("discount.horizon_eff", "無")))
	lines.append("  discount.flow_food(本輪最大值)                          = %s" % str(Probe.peaks.get("discount.flow_food", "無")))
	lines.append("--- ★join母體+QA指路dump：join.accept_check逐筆(cap=40) ---")
	var ja2: int = int(Probe.counts.get("accept.join_accept", 0))
	var jr2: int = int(Probe.counts.get("accept.join_reject", 0))
	lines.append("  accept.join_accept+reject = %d (accept=%d reject=%d)" % [ja2+jr2, ja2, jr2])
	if Probe.samples.has("join.accept_check"):
		var jc: Array = Probe.samples["join.accept_check"]
		lines.append("  ★join.accept_check樣本數=%d，cap=40，%s ⇒ 完整母體" % [
			jc.size(), ("樣本數<cap" if jc.size() < 40 else "樣本數=cap需查是否截斷")])
		for jsmp in jc:
			lines.append("    %s" % str(jsmp))
	# ★systems票(build-eta-single-source世界層)：五處已預測會變的實測
	lines.append("★★★build-eta-single-source 五處預測對照：")
	lines.append("  #3持守 persist.hold(觸發率,分子;預測變寬鬆=值該降) = %d" % int(Probe.counts.get("persist.hold", 0)))
	lines.append("  #4糧橋 dispatch_fail.糧橋不足(先前0,預測仍0或更寬鬆) = %d" % int(Probe.counts.get("dispatch_fail.糧橋不足", 0)))
	lines.append("  #4糧橋對照 dispatch_fail.資源不足(先前28次全是這個) = %d" % int(Probe.counts.get("dispatch_fail.資源不足", 0)))
	var fre: int = int(Probe.counts.get("food_rescue.entry", 0))
	lines.append("  #5求生蓋田閘 food_rescue.entry(呼叫頻率) = %d" % fre)
	if Probe.samples.has("food_rescue.gate_check"):
		var fp: int = 0
		var fc: Array = Probe.samples["food_rescue.gate_check"]
		for smpf in fc:
			if bool(smpf.get("passed", false)): fp += 1
			lines.append("    %s" % str(smpf))
		lines.append("  #5求生蓋田閘 pass=%d/%d(樣本,預測變嚴=pass率該降,非死水閘沒執行) reject=%d" % [fp, fc.size(), fc.size()-fp])
	else:
		lines.append("  #5求生蓋田閘：本輪無sample(閘完全沒執行到,非『擋住』)")
	lines.append("  #1/#2/#6紮根funnel：root.won_argmax=%d settlement.l0_to_l1_start=%d construct.complete_crude_camp=%d" % [
		int(Probe.counts.get("root.won_argmax", 0)), int(Probe.counts.get("settlement.l0_to_l1_start", 0)),
		int(Probe.counts.get("construct.complete_crude_camp", 0))])
	# ★systems票(exact-pair-hitrate)：root.lost_to逐筆(team,winner,target)，算distinct-target數(母體vs樣本分開報)
	lines.append("★★★exact-pair命中率：root.lost_to逐筆(team,winner,target)：")
	if Probe.samples.has("root.lost_to.pair"):
		var pairs: Array = Probe.samples["root.lost_to.pair"]
		var per_team_winner: Dictionary = {}   # "team|winner" → Dictionary(target→count)
		for p in pairs:
			var key: String = "%s|%s" % [str(p.get("team", -1)), str(p.get("winner", "?"))]
			var d: Dictionary = per_team_winner.get(key, {})
			var tgt: String = str(p.get("target", "無"))
			d[tgt] = int(d.get(tgt, 0)) + 1
			per_team_winner[key] = d
		lines.append("  母體=root.lost_to.*計數器總和(不受first-N影響)，樣本=%d筆(cap=200,%s)" % [
			pairs.size(), ("樣本數<cap⇒完整母體" if pairs.size() < 200 else "樣本數=cap需注意截斷")])
		var keys2: Array = per_team_winner.keys(); keys2.sort()
		for key2 in keys2:
			var d2: Dictionary = per_team_winner[key2]
			var total_n: int = 0
			for v in d2.values(): total_n += int(v)
			lines.append("    (team,winner)=%s 總次數=%d distinct_target數=%d 分佈=%s" % [
				key2, total_n, d2.size(), str(d2)])
	else:
		lines.append("  (無sample)")
	# ★systems票(brick-acceptance)：失敗記憶磚驗收——覆蓋率+suppressed分佈+過渡窗tap(禁用fp,spec那條預測錯了)
	lines.append("★★★失敗記憶磚驗收：")
	lines.append("  failure.entries_written(record()被呼叫總次數) = %d" % int(Probe.counts.get("failure.entries_written", 0)))
	lines.append("  failure.entries_max(Probe.note=最後一次呼叫時那隊的recent_failures.size()，非全局peak) = %s" % str(Probe.peaks.get("failure.entries_max", "無")))
	if Probe.samples.has("failure.first_hit"):
		lines.append("  ★過渡窗首次命中：%s" % str(Probe.samples["failure.first_hit"]))
	else:
		lines.append("  ★過渡窗首次命中：無sample(新key空間90天內從未寫入過一次⇒第三隻恆1.0機制，紅燈)")
	lines.append("  ★★覆蓋率(獨立掃state.teams.recent_failures，非sample非counter，真母體)：")
	var distinct_keys: Dictionary = {}
	var total_count_sum: int = 0
	for tid_f in state.teams:
		var t_f: TeamData = state.teams[tid_f]
		for k_f in t_f.recent_failures:
			var e_f: Dictionary = t_f.recent_failures[k_f]
			distinct_keys[String(k_f)] = true
			total_count_sum += int(e_f.get("count", 0))
	lines.append("    day90當下仍存活(未過期)的distinct(結構id,target) key數 = %d" % distinct_keys.size())
	lines.append("    這些key的count總和(連續失敗次數加總) = %d" % total_count_sum)
	lines.append("    覆蓋率(distinct key數) = %d ★注意:這只是day90快照(未過期項)，非90天內出現過的全部distinct key，過期已被prune掉的key不計入" % distinct_keys.size())
	lines.append("  ★★suppressed分佈(failure.suppressed.<structural_id>累計，聚合層級=option/goal_type:frontier_kind，非細到target)：")
	var supp_tally: Dictionary = {}
	for k_s in Probe.counts.keys():
		var ks_s: String = String(k_s)
		if ks_s.begins_with("failure.suppressed."):
			supp_tally[ks_s.substr("failure.suppressed.".length())] = int(Probe.counts[k_s])
	var supp_keys: Array = supp_tally.keys(); supp_keys.sort()
	for sk in supp_keys:
		lines.append("    %-40s = %d" % [sk, int(supp_tally[sk])])
	lines.append("  ★build_workshop:resource特別確認 = %d" % int(Probe.counts.get("failure.suppressed.build_workshop:resource", 0)))
	lines.append("  failure.suppressed_depth(Probe.note=最後一次觸發時的折價深度1-m，非峰值) = %s" % str(Probe.peaks.get("failure.suppressed_depth", "無")))
	lines.append("  failure.invalidated.* / failure.pruned：")
	for k_i in Probe.counts.keys():
		var ks_i: String = String(k_i)
		if ks_i.begins_with("failure.invalidated.") or ks_i == "failure.pruned":
			lines.append("    %-40s = %d" % [ks_i, int(Probe.counts[k_i])])
	if Probe.samples.has("failure.recorded"):
		lines.append("  failure.recorded樣本(cap=16，非母體，供逐筆檢視)：")
		for smp_r in (Probe.samples["failure.recorded"] as Array):
			lines.append("    %s" % str(smp_r))
	var text: String = "\n".join(PackedStringArray(lines))
	print("\n" + text)
	if out_path != "":
		var f := FileAccess.open(out_path, FileAccess.WRITE)
		if f != null: f.store_string(text + "\n"); f.close()
	var spec_path2: String = OS.get_environment("SPECIMEN_OUT")
	if spec_path2 != "":
		SpecimenDumpHelper.dump(state, spec_path2)
	Probe.enabled = false
