extends SceneTree
# 失敗記憶結構身分磚：**覆蓋率 ＋ 死水兩欄**（spec §5.1 / §5.5）。
#
# ★要答的：
#   ①**覆蓋率** —— 接線面積從「2 個 option」變成實際涵蓋的 `(結構 id, target)` 對數
#     （`00_roles §覆蓋欄`：**記 done 必同記覆蓋率**）
#   ②★**死水兩欄** —— 新 key 的【呼叫頻率】與【輸入變異性】：
#     ★**別做出第三個「恆 1.0」的機制**（前兩隻：`OPTION_FAIL_KEY` 只接 2 個、exact-pair 命中率）
#   ③**過渡窗**（reviewer 建議、systems 採納）：新 key 空間的條目數與**首次命中 tick**
#     —— 我們接受「舊 key 記憶斷代」的理由是「一輪就換完」，★那是假設，讓它自己喊
#
# env：PERF_SEED(1337)、ADHOC_DAYS(90)、LW_CONFIG(peaceful_economy)、PERF_OUT

func _initialize() -> void:
	_run(); quit()

func _c(k: String) -> int:
	return int(Probe.counts.get(k, 0))

func _run() -> void:
	var cfg: String = OS.get_environment("LW_CONFIG") if OS.get_environment("LW_CONFIG") != "" else "peaceful_economy"
	var days: int = int(OS.get_environment("ADHOC_DAYS")) if OS.get_environment("ADHOC_DAYS") != "" else 90
	var sd: int = int(OS.get_environment("PERF_SEED")) if OS.get_environment("PERF_SEED") != "" else 1337
	var out_path: String = OS.get_environment("PERF_OUT")
	print("=== 失敗記憶結構身分：覆蓋率+死水：config=%s days=%d seed=%d ===" % [cfg, days, sd])
	seed(sd)
	Probe.enabled = true; Probe.reset()
	FactionAISystem._a2b_remote_tribute_payers.clear()
	var state := WorldState.new()
	var runner := SimRunner.new()
	var config: Dictionary = GameSetup.load_config("res://config/%s.json" % cfg)
	if config.is_empty(): print("[FAIL] config 載入失敗"); Probe.enabled = false; return
	config["seed"] = sd
	GameSetup.setup(state, config)
	var no_player := Vector2i(-1, -1)
	# ★逐日採樣「活著的 key 條目數」——過渡窗要看的是【趨勢】不是終值
	var live_by_day: Array = []
	for tick in range(days * WorldState.TICKS_PER_DAY):
		runner.advance_tick(state, no_player)
		if state.encounter_active and state.encounter_tick > 800:
			runner._encounter_system.resolve_encounter_end(state, "draw")
		if (tick + 1) % WorldState.TICKS_PER_DAY == 0:
			var n: int = 0
			for tid in state.teams:
				n += (state.teams[tid] as TeamData).recent_failures.size()
			live_by_day.append(n)
		if state.teams.is_empty():
			print("[bed] 全滅 @tick=%d" % tick); break

	var lines: Array = []
	lines.append("[%s day %d seed %d] teams=%d" % [cfg, days, sd, state.teams.size()])

	# ── ①覆蓋率：實際被寫過的 (結構 id, target) 對
	lines.append("--- ①覆蓋率（接線面積：舊制＝2 個 option 寫死在表裡）---")
	var ids: Dictionary = {}       # 結構 id → 出現次數
	var pairs: Dictionary = {}     # 完整 key → 次數
	if Probe.samples.has("failure.structural_key"):
		for e in (Probe.samples["failure.structural_key"] as Array):
			var idk: String = String(e.get("id", ""))
			ids[idk] = int(ids.get(idk, 0)) + 1
			var pk: String = "%s|%s" % [idk, String(e.get("target", ""))]
			pairs[pk] = int(pairs.get(pk, 0)) + 1
	lines.append("  %-46s = %d" % ["失敗記錄總筆數 failure.entries_written", _c("failure.entries_written")])
	lines.append("  %-46s = %d" % ["用到【結構身分】的記錄 structural_key_used", _c("failure.structural_key_used")])
	lines.append("  %-46s = %d   ★退回舊語彙（單子沒帶到身分）" % ["key_fallback_no_dispatch_id", _c("failure.key_fallback_no_dispatch_id")])
	lines.append("  ★樣本內 distinct 結構 id = %d，distinct (id,target) 對 = %d（★樣本 cap 40，非母體）"
		% [ids.size(), pairs.size()])
	for k in ids:
		lines.append("    id  %-28s ×%d" % [k, int(ids[k])])
	for k2 in pairs:
		lines.append("    pair %-28s ×%d" % [k2, int(pairs[k2])])

	# ── ②死水兩欄
	lines.append("--- ②★死水兩欄（呼叫頻率 / 輸入變異性）---")
	lines.append("  呼叫頻率：failure.entries_written = %d" % _c("failure.entries_written"))
	var supp: int = 0
	for k3 in Probe.counts.keys():
		if String(k3).begins_with("failure.suppressed."):
			supp += _c(String(k3))
			lines.append("  %-46s = %d" % [String(k3), _c(String(k3))])
	lines.append("  折價真的生效總次數 = %d %s" % [supp,
		"   ★★零 ⇒ 這就是第三個「恆 1.0」的機制，必須回報不得放行" if supp == 0 else ""])
	lines.append("  輸入變異性：entries_max（本輪單隊最大條目數）= %s"
		% str(Probe.peaks.get("failure.entries_max", 0.0)))

	# ── ③過渡窗
	lines.append("--- ③過渡窗（斷代自癒？「一輪就換完」是假設，讓它自己喊）---")
	if Probe.samples.has("failure.first_hit"):
		for e2 in (Probe.samples["failure.first_hit"] as Array):
			lines.append("  ★首次命中：%s" % str(e2))
	else:
		lines.append("  ★★沒有任何首次命中 ⇒ 新 key 空間【從未被寫入】⇒ 恆 1.0 機制警報")
	lines.append("  逐日活條目數（前 30 日）：%s" % str(live_by_day.slice(0, 30)))
	if live_by_day.size() > 30:
		lines.append("  逐日活條目數（後 10 日）：%s" % str(live_by_day.slice(live_by_day.size() - 10)))

	lines.append("--- ④★三分類兩面分開驗（防修回頭）---")
	lines.append("  A面 文明化：outpost.l0_to_l1 = %d / start = %d / complete_crude_camp = %d"
		% [_c("outpost.l0_to_l1"), _c("settlement.l0_to_l1_start"), _c("construct.complete_crude_camp")])
	lines.append("  B面 徒勞折價仍咬：failure.suppressed.買糧 = %d   ★零⇒折價被關掉了(修回頭)"
		% _c("failure.suppressed.買糧"))
	lines.append("  failure.blocked_total(前提型：不折價) = %d" % _c("failure.blocked_total"))
	for kb in Probe.counts.keys():
		if String(kb).begins_with("failure.blocked."):
			lines.append("  %-46s = %d" % [String(kb), _c(String(kb))])
	lines.append("--- ⑤★折價前/後 util 對比(分開「本來就該輸」與「被磚壓低」) ---")
	if Probe.samples.has("failure.penalty_delta"):
		var ds: Array = Probe.samples["failure.penalty_delta"]
		lines.append("  樣本 %d 筆(cap 40)" % ds.size())
		for e4 in ds.slice(0, 14):
			var raw: float = float(e4.get("u_raw", 0.0))
			var aft: float = float(e4.get("u_after", 0.0))
			lines.append("    %-30s u_raw=%.4f -> %.4f (折掉 %.1f%%)"
				% [String(e4.get("opt", "")), raw, aft, 100.0 * (1.0 - aft / maxf(raw, 0.0001))])
	else:
		lines.append("  (無樣本 ⇒ 這輪沒有任何 util 被折價壓低過)")

	var text: String = "\n".join(PackedStringArray(lines))
	print("\n" + text)
	if out_path != "":
		var f := FileAccess.open(out_path, FileAccess.WRITE)
		if f != null: f.store_string(text + "\n"); f.close()
	Probe.enabled = false
	print("=== 覆蓋率床 DONE ===")
