extends SceneTree
func _initialize() -> void:
	var days: int = int(OS.get_environment("BED_DAYS")) if OS.has_environment("BED_DAYS") else 12
	seed(1337)
	var state := WorldState.new()
	GameSetup.setup(state, GameSetup.load_config("res://config/warring_states.json"))
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
	print("★不受 cap 的總數：body.count=%d｜落在 %% T3 == 0 的=%d"
		% [int(Probe.counts.get("body.count", 0)), int(Probe.counts.get("body.aligned", 0))])
	print("★★而先前那個「144」是 bump_sample 的【首 N 樣本】——first-N 天生停在早期，不是母體")
	var ks: Array = []
	for k in Probe.counts:
		if String(k).begins_with("body.day."): ks.append(String(k))
	ks.sort()
	print("── 逐遊戲日呼叫次數（★看它是不是真的停了）──")
	for k2 in ks:
		print("  %s = %d" % [k2, int(Probe.counts[k2])])
	print("  ★共 %d 個有呼叫的日子 / %d 天窗" % [ks.size(), days])
	print("=== s3b_body_probe DONE ===")
	quit()
