extends SceneTree
# workshop follow-through 診斷床（★診斷票：只出分佈，不修東西）。
#
# ★唯一要答（systems 2026-08-25）：`build_workshop` 贏了 45 次之後，**有沒有真執行、真完工？**
# ★判讀規則【跑之前就寫死】，免得看到數字才編故事：
#   ①贏了卻不完工、然後又重贏  ⇒ 失敗反饋律該咬未咬（律已立 ⇒ 查接線）或死水
#   ②真完工 45 個 workshop      ⇒ 另一回事：世界真的在蓋工坊，不是排不上隊
#   ③genuine 同類排序需求        ⇒ 走脊椎 means-end「拆得開」磚（★排序＝折現值比較的自然輸出，禁新增排序常數）
#
# ★母體語意先講：`build_workshop:resource` 的 `:resource` ＝ **前置是「去弄到材料」**，
#   不是「蓋工坊」本身。所以「贏 45 次」問的第一個問題是：**那 45 次是同一個前置一直補不滿嗎？**
#
# env：PERF_SEED(1337)、ADHOC_DAYS(90)、LW_CONFIG(peaceful_economy)、PERF_OUT、SPECIMEN_OUT

func _initialize() -> void:
	_run(); quit()

func _c(k: String) -> int:
	return int(Probe.counts.get(k, 0))

func _rows(prefix: String) -> Array:
	var out: Array = []
	for k in Probe.counts.keys():
		if String(k).begins_with(prefix):
			out.append({"k": String(k), "n": _c(String(k))})
	out.sort_custom(func(a, b): return int(a["n"]) > int(b["n"]))
	return out

func _run() -> void:
	var cfg: String = OS.get_environment("LW_CONFIG") if OS.get_environment("LW_CONFIG") != "" else "peaceful_economy"
	var days: int = int(OS.get_environment("ADHOC_DAYS")) if OS.get_environment("ADHOC_DAYS") != "" else 90
	var sd: int = int(OS.get_environment("PERF_SEED")) if OS.get_environment("PERF_SEED") != "" else 1337
	var out_path: String = OS.get_environment("PERF_OUT")
	print("=== workshop follow-through 診斷：config=%s days=%d seed=%d ===" % [cfg, days, sd])
	seed(sd)
	Probe.enabled = true; Probe.reset()
	FactionAISystem._a2b_remote_tribute_payers.clear()
	var state := WorldState.new()
	var runner := SimRunner.new()
	var config: Dictionary = GameSetup.load_config("res://config/%s.json" % cfg)
	if config.is_empty(): print("[FAIL] config 載入失敗"); Probe.enabled = false; return
	config["seed"] = sd
	GameSetup.setup(state, config)
	SpecimenDumpHelper.setup_from_env(state)
	var no_player := Vector2i(-1, -1)
	for tick in range(days * WorldState.TICKS_PER_DAY):
		runner.advance_tick(state, no_player)
		if state.encounter_active and state.encounter_tick > 800:
			runner._encounter_system.resolve_encounter_end(state, "draw")
		if state.teams.is_empty():
			print("[bed] 全滅 @tick=%d" % tick); break

	var lines: Array = []
	lines.append("[%s day %d seed %d] teams=%d" % [cfg, days, sd, state.teams.size()])

	# ── 全鏈（同 A1 漏斗形狀）
	lines.append("--- 全鏈 cand → won → dispatch（goal candidate）---")
	for pre in ["goal.cand.", "goal.won.", "goal.dispatch."]:
		var rs: Array = _rows(pre)
		if rs.is_empty():
			lines.append("  （%s* 無）" % pre)
		for r in rs:
			lines.append("  %-46s = %d" % [r["k"], int(r["n"])])

	# ── ★那 45 次是「45 個不同工坊」還是「同一個一直重贏」
	lines.append("--- ★逐隊：誰在贏（plain counter，母體完整）---")
	for r in _rows("goal.won_pair."):
		lines.append("  %-46s = %d" % [r["k"], int(r["n"])])

	# ── ★死水兩欄：前置的兩個輸入到底有沒有在動
	lines.append("--- ★★死水兩欄（前置 holding / need_keep 有沒有變）---")
	for r in _rows("goal.res_prereq."):
		lines.append("  %-46s = %d" % [r["k"], int(r["n"])])
	if Probe.samples.has("goal.res_prereq"):
		var smp: Array = Probe.samples["goal.res_prereq"]
		lines.append("  樣本 %d 筆（cap 200；★滿 200 ＝ 被截斷，變異性判讀要小心）" % smp.size())
		var holds: Dictionary = {}      # team|res → 出現過的 holding 值集合
		for e in smp:
			var key: String = "%s|%s" % [str(e.get("team", -1)), str(e.get("res", ""))]
			var arr: Array = holds.get(key, [])
			if not arr.has(e.get("holding", -1.0)):
				arr.append(e.get("holding", -1.0))
			holds[key] = arr
		for key2 in holds:
			var vals: Array = holds[key2]
			lines.append("    %-16s 出現過 %d 種 holding 值 %s%s" % [key2, vals.size(), str(vals.slice(0, 6)),
				"   ★死水（值從沒變過）" if vals.size() <= 1 else ""])
		for i in range(mini(16, smp.size())):
			lines.append("    %s" % str(smp[i]))

	# ── ★失敗反饋律有沒有咬（分清「律沒咬」與「律沒被執行到」）
	lines.append("--- ★失敗反饋律（律沒咬 vs 律沒被執行到）---")
	var frows: Array = _rows("failure.")
	if frows.is_empty():
		lines.append("  ★`failure.*` 全部 0 ⇒ 律【沒被執行到】（record 從沒被呼叫），不是「咬了但沒效」")
	else:
		for r in frows:
			lines.append("  %-46s = %d" % [r["k"], int(r["n"])])
	if Probe.samples.has("failure.recorded"):
		for e2 in (Probe.samples["failure.recorded"] as Array):
			lines.append("    %s" % str(e2))

	# ── 真完工了嗎
	lines.append("--- 真完工（construct 全鏈）---")
	for k in ["construct.start", "construct.start_task_not_build", "construct.progress", "construct.stall", "construct.timeout_cancel"]:
		lines.append("  %-46s = %d" % [k, _c(k)])
	for r in _rows("construct.complete"):
		lines.append("  %-46s = %d" % [r["k"], int(r["n"])])
	# ★存量（≠ 事件計數）：世界上現在真的有幾座 workshop
	var ws: int = 0
	var ws_lv: int = 0
	for tid in state.world.tiles:
		var t: HexTileData = state.world.tiles[tid]
		var lv2: int = int(t.get("manufacturing_level"))
		if lv2 > 0:
			ws += 1; ws_lv += lv2
	lines.append("  %-46s = %d（等級合計 %d）  ★存量" % ["day%d 有 manufacturing 的 tile 數" % days, ws, ws_lv])

	var text: String = "\n".join(PackedStringArray(lines))
	print("\n" + text)
	if out_path != "":
		var f := FileAccess.open(out_path, FileAccess.WRITE)
		if f != null: f.store_string(text + "\n"); f.close()
	var spec_path: String = OS.get_environment("SPECIMEN_OUT")
	if spec_path != "":
		SpecimenDumpHelper.dump(state, spec_path)
	Probe.enabled = false
	print("\n=== workshop 診斷床 DONE ===")
