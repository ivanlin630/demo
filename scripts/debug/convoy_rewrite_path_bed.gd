extends SceneTree
# convoy-return-task-authority 第一趟：**RETURN 期間 `current_task` 被改寫時走哪一條路**。
#
# ★systems 明示：**這一格定了，原本那兩個假說才輪得到。**
# ★母體完整性（窮盡確認，見 `task_arbiter._note_convoy_rewrite` 註解）：
#   對一支【已存在】的 porter，寫 `current_task` 的路只有 `try_set` / `release` / `transition` 三條
#   ⇒ 三顆掛滿就沒有「其他」那一格。若三者相加 ≠ 觀測到的改寫，才是有沒列到的出口。
#
# ★另一個關鍵量（systems 新立的 acceptance 規則）：
#   **後果計數（stranded 次數）分不出「機制修好」vs「容忍度變寬」**；
#   ★**「RETURN 期間 task 是不是運輸」轉不動 —— margin 再大也改不了它。**
#
# env：PERF_SEED(1337)、ADHOC_DAYS(30)、LW_CONFIG(warring_states)、PERF_OUT、SPECIMEN_OUT

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
	var cfg: String = OS.get_environment("LW_CONFIG") if OS.get_environment("LW_CONFIG") != "" else "warring_states"
	var days: int = int(OS.get_environment("ADHOC_DAYS")) if OS.get_environment("ADHOC_DAYS") != "" else 30
	var sd: int = int(OS.get_environment("PERF_SEED")) if OS.get_environment("PERF_SEED") != "" else 1337
	var out_path: String = OS.get_environment("PERF_OUT")
	print("=== convoy RETURN task 改寫路徑：config=%s days=%d seed=%d ===" % [cfg, days, sd])
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
		# ★sidecar（warring 很重，30 天曾撞 900s timeout）：每 5 日覆寫一份快照
		#   ⇒ 被 reap 也讀得到 partial，且 partial 明白標示跑到第幾天（不得當完整輪讀）。
		if out_path != "" and (tick + 1) % (WorldState.TICKS_PER_DAY * 5) == 0:
			_dump(out_path, int((tick + 1) / WorldState.TICKS_PER_DAY), days, sd, cfg, state, false)

	_dump(out_path, days, days, sd, cfg, state, true)

func _dump(out_path: String, day_now: int, days: int, sd: int, cfg: String, state: WorldState, final: bool) -> void:
	var lines: Array = []
	lines.append("[%s day %d/%d seed %d] teams=%d%s" % [cfg, day_now, days, sd, state.teams.size(),
		"" if final else "   ★PARTIAL（尚未跑完，不得當完整輪讀）"])

	# ── ★那一格：改寫走哪條路
	lines.append("--- ★★RETURN 期間 current_task 改寫路徑（母體＝三條，無「其他」格）---")
	var by_path: Dictionary = {}
	for pth in ["try_set", "try_set_defy", "release", "transition"]:
		by_path[pth] = _c("convoy.rewrite." + pth)
		lines.append("  %-40s = %d" % ["convoy.rewrite." + pth, by_path[pth]])
	var total: int = 0
	for pth2 in by_path: total += int(by_path[pth2])
	lines.append("  %-40s = %d" % ["改寫總數", total])
	if total > 0:
		for pth3 in by_path:
			if int(by_path[pth3]) > 0:
				lines.append("    %s 佔 %.1f%%" % [pth3, 100.0 * float(by_path[pth3]) / float(total)])
	else:
		lines.append("  ★零改寫 —— 那 RETURN 期間 task 就沒被動過；下面那格會說明它本來是不是運輸")

	lines.append("  改寫去哪（逐 task）：")
	for r in _rows("convoy.rewrite."):
		if String(r["k"]).count(".") >= 3:   # convoy.rewrite.<path>.<task>
			lines.append("    %-44s = %d" % [r["k"], int(r["n"])])
	if Probe.samples.has("convoy.rewrite"):
		lines.append("  樣本（≤40）：")
		for smp in (Probe.samples["convoy.rewrite"] as Array):
			lines.append("    %s" % str(smp))

	# ── ★margin 影響不到的量
	lines.append("--- ★★RETURN 期間 task 是不是運輸（★margin 轉不動這一格）---")
	var rt: int = _c("convoy.return_tick")
	var ok: int = _c("convoy.return_task_is_convoy")
	lines.append("  %-40s = %d" % ["convoy.return_tick（分母）", rt])
	lines.append("  %-40s = %d" % ["convoy.return_task_is_convoy", ok])
	if rt > 0:
		lines.append("  ⇒ ★RETURN 期間 task=運輸 佔比 = %.1f%%" % (100.0 * float(ok) / float(rt)))
	else:
		lines.append("  ⇒ 這輪沒有任何 RETURN cadence（母體塌陷，不是答案）")
	for r2 in _rows("convoy.return_task_other."):
		lines.append("  %-44s = %d" % [r2["k"], int(r2["n"])])

	# ── 對照：既有 convoy 全鏈
	lines.append("--- 對照（既有 convoy 鏈）---")
	for k in ["convoy.dispatch", "convoy.deliver", "convoy.deliver_settled", "convoy.return",
			"convoy.stranded", "convoy.eta_vs_actual_n"]:
		lines.append("  %-40s = %d" % [k, _c(k)])
	for r3 in _rows("convoy.stranded."):
		lines.append("  %-44s = %d" % [r3["k"], int(r3["n"])])
	var eta_n: int = _c("convoy.eta_vs_actual_n")
	if eta_n > 0:
		lines.append("  convoy.eta_vs_actual 平均 = %.3f（sum/n；1.0=兩模型同步）"
			% (Probe.amount("convoy.eta_vs_actual_sum") / float(eta_n)))

	lines.append("--- ★★§N 兩欄（必須分開報：只看總數的話，誤擋正當退場會長得跟成功一樣）---")
	var rc: int = _c("commit.release_clean")
	var rw: int = _c("commit.release_with_commitment")
	lines.append("  ①合法退場 commit.release_clean            = %d   ★【不該】下降（掉＝正當退場被誤擋＝回歸）" % rc)
	lines.append("  ①帶著未完成承諾被卸 release_with_commitment = %d" % rw)
	for km in Probe.counts.keys():
		if String(km).begins_with("commit.release_with."):
			lines.append("      %-42s = %d" % [String(km), _c(String(km))])
	lines.append("  ②被 hold 擋下 commit.hold_blocked          = %d   ★【該】上升" % _c("commit.hold_blocked"))
	for kh in Probe.counts.keys():
		if String(kh).begins_with("commit.hold_blocked."):
			lines.append("    %-44s = %d" % [String(kh), _c(String(kh))])
	lines.append("--- ★latch 解藥在不在跑（假設不靜默）---")
	lines.append("  commit.stall_fire = %d" % _c("commit.stall_fire"))
	for ks in Probe.counts.keys():
		if String(ks).begins_with("commit.stall_fire."):
			lines.append("    %-44s = %d" % [String(ks), _c(String(ks))])
	if Probe.samples.has("commit.stall_fire"):
		for es in (Probe.samples["commit.stall_fire"] as Array).slice(0, 10):
			lines.append("    %s" % str(es))
	if _c("commit.stall_fire") == 0 and rc == 0:
		lines.append("  ★★紅燈判準：解藥零觸發 ＋ ①合法退場也是 0 ⇒ latch 已發生而沒人知道")
	lines.append("  construction_abandoned 事件（紮根執行型失敗進料口）= %d" % _c("commit.stall_fire.construction"))

	var text: String = "\n".join(PackedStringArray(lines))
	if out_path != "":
		var f := FileAccess.open(out_path, FileAccess.WRITE)   # 覆寫＝最新快照
		if f != null: f.store_string(text + "\n"); f.close()
	# ★只有最後一趟才印全文、才 dump specimen、才關 Probe ——
	#   sidecar 若也關 Probe，後面的 tick 就全部量不到（那會是儀器自己毀掉量測）。
	if final:
		print("\n" + text)
		var spec_path: String = OS.get_environment("SPECIMEN_OUT")
		if spec_path != "":
			SpecimenDumpHelper.dump(state, spec_path)
		Probe.enabled = false
		print("=== convoy 改寫路徑床 DONE ===")
