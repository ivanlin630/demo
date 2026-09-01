extends SceneTree
func _initialize() -> void:
	var days: int = int(OS.get_environment("BED_DAYS")) if OS.has_environment("BED_DAYS") else 12
	seed(1337)
	# ★★★腿A 修存量（2026-09-01）：本床原本是【先建世界、後 arm】——
	#   `WorldState.new()` + `GameSetup.setup()` 在 `Probe.reset(); Probe.enabled = true` 【之前】
	#   ⇒ 世界生成那一段的 tap 全部是盲的，★而它不會報錯、只會少一段數字，
	#     ★★而「少一段」與「那一段沒發生」在輸出上長得一模一樣。
	#   ⇒ 改用 helper：順序寫死（arm → new → setup），★★★沒得選錯。
	#   ★拆玩家由 helper 統一做（warring_states.json 帶 player 區塊，
	#     而那支沒人操作的玩家隊 leader 一死無繼承人 ⇒ game_over ⇒ 世界凍結 ⇒ 量到死 tick）。
	var state := MeasureBedHelper.arm_and_setup("res://config/warring_states.json")
	print(MeasureBedHelper.arm_order_report())
	var ticks: int = days * WorldState.TICKS_PER_DAY
	var runner := SimRunner.new()
	var stopped_at: int = -1
	var stop_reason: String = ""
	for _t in range(ticks):
		var r: String = runner.advance_tick(state, Vector2i(-1, -1))
		if r != "" and r != "ok" and stopped_at == -1 and (r == "game_over" or r == "awaiting_heir"):
			stopped_at = state.world.current_tick
			stop_reason = r
	print("★advance_tick 首次回傳非推進值：tick=%d reason=%s（-1 = 從未）" % [stopped_at, stop_reason])
	print("★★結束時：game_over=%s｜teams=%d｜factions=%d" % [str(state.game_over), state.teams.size(), state.factions.size()])
	print("=== s3b_body_probe === days=%d ticks=%d T3=%d" % [days, ticks, DecisionTier.T3_STRATEGIC])
	var bc: int = int(Probe.counts.get("body.count", -1))
	if not Probe.counts.has("body.count"):
		print("★body.count key 【不存在】⇒ 這是【臨時 tap 已撤】不是【沒被呼叫】——兩者別混")
	else:
		print("★不受 cap 的總數：body.count=%d｜落在 %% T3 == 0 的=%d" % [bc, int(Probe.counts.get("body.aligned", 0))])
	print("★★而先前那個「144」是 bump_sample 的【首 N 樣本】——first-N 天生停在早期，不是母體")
	var ks: Array = []
	for k in Probe.counts:
		if String(k).begins_with("body.day."): ks.append(String(k))
	ks.sort()
	print("── 逐遊戲日呼叫次數（★看它是不是真的停了）──")
	for k2 in ks:
		print("  %s = %d" % [k2, int(Probe.counts[k2])])
	print("  ★共 %d 個有呼叫的日子 / %d 天窗" % [ks.size(), days])
	print("
── ★GOAL near/far 分欄（驗整除推論）──")
	for gk in ["goal.pass.near", "goal.pass.far", "goal.teams.near", "goal.teams.far", "goal.fire.near", "goal.fire.far"]:
		print("  %-18s %s" % [gk, (str(int(Probe.counts[gk])) if Probe.counts.has(gk) else "★key 不存在")])
	print("  ★判準：far 欄非零 ⇒ 整除推論錯｜far 恆 0 且 near 非零 ⇒ 整除成立")
	print("  T3=%d｜FAR_ZONE_INTERVAL=%d｜T3 mod FAR = %d｜NEAR_CADENCE=%d｜T3 mod NEAR = %d"
		% [DecisionTier.T3_STRATEGIC, SimRunner.FAR_ZONE_INTERVAL,
		   DecisionTier.T3_STRATEGIC % SimRunner.FAR_ZONE_INTERVAL,
		   SimRunner.NEAR_CADENCE, DecisionTier.T3_STRATEGIC % SimRunner.NEAR_CADENCE])
	print("[BedSelfCheck] observer_guard=%s  first_nonadvance=%s  effective_window=%d/%d ticks"
		% ["stripped" if state.player_id == -1 else "none",
		   ("%d(%s)" % [stopped_at, stop_reason]) if stopped_at != -1 else "none",
		   (stopped_at if stopped_at != -1 else ticks), ticks])
	print("=== s3b_body_probe DONE ===")
	quit()
