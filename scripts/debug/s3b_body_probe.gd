extends SceneTree
func _initialize() -> void:
	var days: int = int(OS.get_environment("BED_DAYS")) if OS.has_environment("BED_DAYS") else 12
	seed(1337)
	var state := WorldState.new()
	GameSetup.setup(state, GameSetup.load_config("res://config/warring_states.json"))
	# ★★拆玩家（照 exam_12mo_bed 的既有慣例）：warring_states.json 帶 player 區塊，
	#   而那支【沒人操作的】玩家隊 leader 一死且無 named 繼承人 ⇒ game_over ⇒ 世界凍結。
	#   ★★★我先前三張床全都沒拆 ⇒ 量到的是【凍結後的死 tick】。
	if state.player_id != -1:
		print("[strip] player_id %d → -1（無人值守世界模擬）" % state.player_id)
		state.player_id = -1
		state.player_forced_event = {}
		state.player_forced_event_id = ""
		state.player_pending_targets = []
		state.player_hostile_teams = []
		state.player_pre_encounter = {}
		state.player_state = {}
	Probe.reset(); Probe.enabled = true
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
