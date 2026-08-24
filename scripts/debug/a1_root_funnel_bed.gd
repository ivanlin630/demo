extends SceneTree
# A1 建設族：「紮根 argmax 贏 → 真開工」之間的 drop 分佈床。
#
# ★方法（spec §1 硬性）：**結構列舉，不逐隻抓**。
#   argmax 贏 → ①to_task → ②try_set（四道拒絕各自留名）→ ③commit-hook（四個 early-return）→ ④真開工
#   每一格都有 tap，一輪跑完看分佈。
#
# ★母體語意先講（spec §4 特別點名）：`start` 與 `resume` 不是同一件事 ——
#   resume ＝ 認回自己既有工地，不是一次新的紮根機會。
#   ⇒ 報表把「獨立機會母體」與「總 commit 次數」分開列，避免用 resume 灌大分母。
#
# env：PERF_SEED(1337)、ADHOC_DAYS(90)、LW_CONFIG(peaceful_economy)、PERF_OUT、SPECIMEN_OUT

func _initialize() -> void:
	_run(); quit()

func _c(k: String) -> int:
	return int(Probe.counts.get(k, 0))

func _run() -> void:
	var cfg: String = OS.get_environment("LW_CONFIG") if OS.get_environment("LW_CONFIG") != "" else "peaceful_economy"
	var days: int = int(OS.get_environment("ADHOC_DAYS")) if OS.get_environment("ADHOC_DAYS") != "" else 90
	var sd: int = int(OS.get_environment("PERF_SEED")) if OS.get_environment("PERF_SEED") != "" else 1337
	var out_path: String = OS.get_environment("PERF_OUT")
	print("=== A1 紮根 funnel drop 分佈：config=%s days=%d seed=%d ===" % [cfg, days, sd])
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

	# ── 站 0：argmax
	var won: int = _c("root.won_argmax")
	lines.append("--- 站0 argmax ---")
	lines.append("  %-44s = %d" % ["root.won_argmax", won])
	var lost: Array = []
	for k in Probe.counts.keys():
		if String(k).begins_with("root.lost_to."):
			lost.append("  %-44s = %d" % [String(k), _c(String(k))])
	lost.sort()
	if lost.is_empty():
		lines.append("  （root.lost_to.* 無 —— 紮根沒有輸給任何人；若 won 也是 0 ＝ 根本沒進候選）")
	else:
		lines.append("  紮根 applicable 卻沒贏，輸給誰：")
		for l in lost: lines.append(l)

	# ── 站①：to_task
	lines.append("--- 站① to_task（結構上不可能回空；不等於分母＝有人加了早退） ---")
	lines.append("  %-44s = %d" % ["root.funnel.to_task", _c("root.funnel.to_task")])

	# ── 站②：try_set
	var ok2: int = _c("root.funnel.try_set_ok")
	var pre: Array = []
	var pre_total: int = 0
	for k in Probe.counts.keys():
		if String(k).begins_with("root.funnel.pre_try_set_drop."):
			pre.append("  %-44s = %d" % [String(k), _c(String(k))])
			pre_total += _c(String(k))
	pre.sort()
	lines.append("--- 站①→② 守衛（結構列舉：殘差必須為 0，否則有沒列到的出口） ---")
	if pre.is_empty():
		lines.append("  （無 —— 紮根沒有落在 no_target / idle_task 任何一格）")
	else:
		for l in pre: lines.append(l)
	lines.append("  %-44s = %d" % ["站①→②drop 小計", pre_total])
	lines.append("--- 站② try_set（四道拒絕各自留名） ---")
	lines.append("  %-44s = %d" % ["root.funnel.try_set_ok", ok2])
	var fails: Array = []
	var fail_total: int = 0
	for k in Probe.counts.keys():
		if String(k).begins_with("root.funnel.try_set_fail."):
			fails.append("  %-44s = %d" % [String(k), _c(String(k))])
			fail_total += _c(String(k))
	fails.sort()
	if fails.is_empty():
		lines.append("  （try_set 一次都沒擋下紮根）")
	else:
		for l in fails: lines.append(l)
	lines.append("  %-44s = %d" % ["站②drop 小計", fail_total])
	var residual: int = _c("root.funnel.to_task") - pre_total - ok2 - fail_total
	lines.append("  ★殘差稽核：站①(%d) − 守衛(%d) − try_set(%d ok + %d fail) = %d %s"
		% [_c("root.funnel.to_task"), pre_total, ok2, fail_total, residual,
			"✅列舉完整" if residual == 0 else "⚠ 有沒列到的出口"])

	# ── 站③：commit-hook
	var entered: int = _c("root.commit.entered")
	var resume: int = _c("settlement.l0_to_l1_resume")
	var started: int = _c("settlement.l0_to_l1_start")
	lines.append("--- 站③ commit-hook（try_set 成功【之後】仍可能不落地） ---")
	lines.append("  %-44s = %d" % ["root.commit.entered（分母）", entered])
	var drop_keys: Array = ["root.commit_drop.no_settle_site", "root.commit_drop.tile_null",
		"root.commit_drop.no_camp", "root.commit_drop.already_outpost", "root.commit_drop.occupied_by_other"]
	var drop_total: int = 0
	for k in drop_keys:
		lines.append("  %-44s = %d" % [k, _c(k)])
		drop_total += _c(k)
	lines.append("  %-44s = %d   ★不是 drop，是認回自己的工地" % ["settlement.l0_to_l1_resume", resume])
	lines.append("  %-44s = %d" % ["站③drop 小計", drop_total])

	# ── 站④：真開工 → 完工 → 晉升
	lines.append("--- 站④ 真開工之後 ---")
	for k in ["settlement.l0_to_l1_start", "construct.complete_crude_camp", "outpost.l0_to_l1"]:
		lines.append("  %-44s = %d" % [k, _c(k)])

	# ── ★母體語意（spec §4：先報母體再談 drop 率）
	lines.append("--- ★母體語意 ---")
	lines.append("  獨立紮根機會（commit.entered − resume） = %d" % (entered - resume))
	lines.append("  其中真開工 start                      = %d" % started)
	lines.append("  其中被 ③ 擋掉                          = %d" % drop_total)
	if entered - resume > 0:
		lines.append("  ⇒ 站③ drop 率 = %.1f%%（分母已扣掉 resume，不用 resume 灌大分母）"
			% (100.0 * float(drop_total) / float(entered - resume)))
	else:
		lines.append("  ⇒ 獨立機會為 0：drop 率無意義（母體塌陷，不是答案）")

	# ── §3 高嫌疑假說的對照組（★待驗、不得當結論）
	lines.append("--- §3 假說對照：③no_camp 與「蓋了就丟」是否同源（待驗，非結論） ---")
	for k in ["camp.built", "camp.abandoned"]:
		lines.append("  %-44s = %d" % [k, _c(k)])
	lines.append("  %-44s = %d" % ["root.commit_drop.no_camp", _c("root.commit_drop.no_camp")])

	# ── 工期端（本刀不修，但要看得見；spec §5）
	lines.append("--- 工期端（不在本刀，僅對照） ---")
	for k in ["construct.start", "construct.start_task_not_build", "construct.progress", "construct.stall", "construct.timeout_cancel"]:
		lines.append("  %-44s = %d" % [k, _c(k)])

	var text: String = "\n".join(PackedStringArray(lines))
	print("\n" + text)
	if out_path != "":
		var f := FileAccess.open(out_path, FileAccess.WRITE)
		if f != null: f.store_string(text + "\n"); f.close()
	var spec_path: String = OS.get_environment("SPECIMEN_OUT")
	if spec_path != "":
		SpecimenDumpHelper.dump(state, spec_path)
	Probe.enabled = false
	print("\n=== A1 funnel bed DONE ===")
