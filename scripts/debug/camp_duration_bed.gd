extends SceneTree
# camp 工期票：「開工 → 完工」之間人跑去哪了。
#
# ★兩趟法（spec §D，開票就指定）：
#   **第一趟（本床預設）**：跑完印出「**開工但未完工的 tile 與其 `construction_team_id`**」
#     ⇒ 那份 team id 清單就是第二趟要盯的隊。
#   **第二趟**：`SPECIMEN_TEAM_ID=<那幾隊>` 重跑同 seed ⇒ QA 直接讀得到棄工當下那幾隊在想什麼。
#   ★理由：棄工的隊幾乎一定不在等距抽樣裡（已四次同款）。
#
# ★本床純觀測。要回答的三題（spec §3）：
#   ①施工中隊被【什麼選項】叫走（`build.preempted_by.*`，含雙方 priority ⇒ 分得出 routine 搶贏 vs 合法搶）
#   ②持守 floor 有沒有覆蓋到（`build.floor_applied` vs `floor_skipped.task_not_build` vs `floor_absent.*`）
#   ③`construct.stall` 的 **per-action** 分佈（跨工程總計不能套到紮根身上）
#
# env：PERF_SEED(1337)、ADHOC_DAYS(90)、LW_CONFIG(peaceful_economy)、PERF_OUT、SPECIMEN_OUT

func _initialize() -> void:
	_run(); quit()

func _c(k: String) -> int:
	return int(Probe.counts.get(k, 0))

func _prefix_rows(prefix: String) -> Array:
	var rows: Array = []
	for k in Probe.counts.keys():
		if String(k).begins_with(prefix):
			rows.append("  %-46s = %d" % [String(k), _c(String(k))])
	rows.sort()
	return rows

func _run() -> void:
	var cfg: String = OS.get_environment("LW_CONFIG") if OS.get_environment("LW_CONFIG") != "" else "peaceful_economy"
	var days: int = int(OS.get_environment("ADHOC_DAYS")) if OS.get_environment("ADHOC_DAYS") != "" else 90
	var sd: int = int(OS.get_environment("PERF_SEED")) if OS.get_environment("PERF_SEED") != "" else 1337
	var out_path: String = OS.get_environment("PERF_OUT")
	print("=== camp 工期床（第一趟）：config=%s days=%d seed=%d ===" % [cfg, days, sd])
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

	# ── ★第一趟的產出：第二趟要盯誰
	lines.append("--- ★★第二趟的 SPECIMEN_TEAM_ID 清單（開工但未完工的工地）---")
	var unfinished: Array = []
	for tid in state.world.tiles:
		var t: HexTileData = state.world.tiles[tid]
		if t.construction_ticks_left > 0:
			var total: int = OutpostSystem.construction_ticks_total(t)
			var done: float = 0.0 if total <= 0 else float(total - t.construction_ticks_left) / float(total)
			var owner: TeamData = state.teams.get(t.construction_team_id)
			unfinished.append({
				"pos": [t.tile_pos.x, t.tile_pos.y],
				"action": String(t.construction_target.get("action", "unknown")),
				"ct_id": t.construction_team_id,
				"ct_alive": owner != null,
				"ct_task": owner.current_task if owner != null else "gone",
				"ticks_left": t.construction_ticks_left,
				"progress": snappedf(done, 0.01),
				"eta_days_if_resumed": snappedf(
					OutpostSystem.build_eta_days(t.construction_ticks_left,
						owner.population if owner != null else 1), 0.01),
			})
	if unfinished.is_empty():
		lines.append("  （無未完工地 —— 要嘛都蓋完了，要嘛根本沒開工；看站④數字）")
	else:
		var ids: Array = []
		for u in unfinished:
			lines.append("  %s" % str(u))
			if not ids.has(u["ct_id"]) and int(u["ct_id"]) != -1:
				ids.append(u["ct_id"])
		lines.append("  ⇒ SPECIMEN_TEAM_ID=%s" % ",".join(PackedStringArray(ids.map(func(i): return str(i)))))

	# ── ①施工中隊被誰叫走
	lines.append("--- ①施工中隊【被什麼叫走】---")
	var pre: Array = _prefix_rows("build.preempted_by.")
	if pre.is_empty():
		lines.append("  （零次 —— 施工中的隊從沒被換過 task；那麼停工的原因不在搶班）")
	else:
		for l in pre: lines.append(l)
	# ★另外兩條寫 current_task 的路（結構列舉：`try_set` 不是唯一收口）
	lines.append("  %-46s = %d   ★release()：旁路所有 guard，59 個 caller" % ["build.released", _c("build.released")])
	for l in _prefix_rows("build.transitioned_to."): lines.append(l)
	if Probe.samples.has("build.released"):
		lines.append("  released 樣本（reason ＝ 誰派的那個 task，非誰 release 的）：")
		for smp2 in (Probe.samples["build.released"] as Array):
			lines.append("    %s" % str(smp2))
	if Probe.samples.has("build.preempted"):
		lines.append("  樣本（含雙方 priority ⇒ 分得出 routine 搶贏 vs THREAT/SURVIVAL 合法搶）：")
		for smp in (Probe.samples["build.preempted"] as Array):
			lines.append("    %s" % str(smp))

	# ── ②持守 floor 覆蓋
	lines.append("--- ②持守 active-construction floor 覆蓋 ---")
	lines.append("  %-46s = %d" % ["build.floor_applied（真的套到了）", _c("build.floor_applied")])
	lines.append("  %-46s = %d   ★結構洞：還有未完工地，但 task 已不是 BUILD ⇒ 整段保護跳過"
		% ["build.floor_skipped.task_not_build", _c("build.floor_skipped.task_not_build")])
	for l in _prefix_rows("build.floor_absent."): lines.append(l)
	if Probe.samples.has("build.floor_skipped"):
		for smp in (Probe.samples["build.floor_skipped"] as Array):
			lines.append("    %s" % str(smp))

	# ── ③per-action stall/progress
	lines.append("--- ③construct stall/progress（★per-action，總計不可套到單一 action）---")
	lines.append("  %-46s = %d" % ["construct.progress（總計）", _c("construct.progress")])
	lines.append("  %-46s = %d" % ["construct.stall（總計）", _c("construct.stall")])
	for l in _prefix_rows("construct.progress."): lines.append(l)
	for l in _prefix_rows("construct.stall."): lines.append(l)
	var cp: int = _c("construct.progress.crude_camp")
	var cs: int = _c("construct.stall.crude_camp")
	if cp + cs > 0:
		lines.append("  ⇒ crude_camp 停滯率 = %.1f%%（%d stall / %d 次 tick）" % [100.0 * cs / float(cp + cs), cs, cp + cs])
	else:
		lines.append("  ⇒ crude_camp 這輪沒有任何 construction tick（母體塌陷，不是答案）")

	# ── ★§E：紮根 lost_to 的【集中度】（team22 案例：連續 7 次全輸給買糧）
	lines.append("--- ★§E 紮根 lost_to 集中度（plain counter，母體完整、不受 first-N 截斷）---")
	var by_team: Array = []
	var lost_total: int = 0
	for k in Probe.counts.keys():
		var ks: String = String(k)
		if ks.begins_with("root.lost_by_team."):
			by_team.append({"team": ks.substr(18), "n": _c(ks)})
			lost_total += _c(ks)
	by_team.sort_custom(func(a, b): return int(a["n"]) > int(b["n"]))
	lines.append("  輸掉總數 = %d，分佈在 %d 支隊" % [lost_total, by_team.size()])
	for row in by_team:
		lines.append("    team %-6s 輸 %4d 次（%.1f%%）" % [row["team"], int(row["n"]),
			100.0 * float(row["n"]) / maxf(float(lost_total), 1.0)])
	var pairs: Array = []
	for k2 in Probe.counts.keys():
		if String(k2).begins_with("root.lost_pair."):
			pairs.append({"k": String(k2).substr(15), "n": _c(String(k2))})
	pairs.sort_custom(func(a, b): return int(a["n"]) > int(b["n"]))
	lines.append("  ★最集中的 team|對手 配對（前 12）：")
	for i in range(mini(12, pairs.size())):
		lines.append("    %-22s = %d" % [pairs[i]["k"], int(pairs[i]["n"])])
	if by_team.size() > 0:
		lines.append("  ⇒ 判讀：最大單隊佔比 %.1f%%；★若少數隊×少數對手吃掉大半 ⇒ 是【排不上隊】不是【蓋不完】"
			% (100.0 * float(by_team[0]["n"]) / maxf(float(lost_total), 1.0)))
	lines.append("  （連續性請讀 root.lost_seq 樣本 —— ★那是 first-N 樣本，不是母體）")
	if Probe.samples.has("root.lost_seq"):
		var seq: Array = Probe.samples["root.lost_seq"]
		lines.append("  root.lost_seq 樣本 %d 筆（cap 200；滿 200 = 被截斷，連續性判讀要小心）" % seq.size())
		for i2 in range(mini(24, seq.size())):
			lines.append("    %s" % str(seq[i2]))
	var won_rows: Array = _prefix_rows("root.won_by_team.")
	for l3 in won_rows: lines.append(l3)

	# ── 對照組
	lines.append("--- 對照（與 camp-access／A1 同名量）---")
	for k in ["camp.built", "camp.abandoned", "settlement.l0_to_l1_start",
			"settlement.l0_to_l1_resume", "construct.complete_crude_camp", "outpost.l0_to_l1",
			"root.won_argmax", "construct.timeout_cancel"]:
		lines.append("  %-46s = %d" % [k, _c(k)])
	# ★systems 通則：事件計數 ≠ 存量結果 —— 分開列
	var outposts_now: int = 0
	for tid2 in state.world.tiles:
		if (state.world.tiles[tid2] as HexTileData).outpost_level > 0:
			outposts_now += 1
	lines.append("  %-46s = %d   ★存量（≠ 上面的事件計數）" % ["day%d outpost 存量" % days, outposts_now])

	var text: String = "\n".join(PackedStringArray(lines))
	print("\n" + text)
	if out_path != "":
		var f := FileAccess.open(out_path, FileAccess.WRITE)
		if f != null: f.store_string(text + "\n"); f.close()
	var spec_path: String = OS.get_environment("SPECIMEN_OUT")
	if spec_path != "":
		SpecimenDumpHelper.dump(state, spec_path)
	Probe.enabled = false
	print("\n=== camp 工期床 DONE ===")
