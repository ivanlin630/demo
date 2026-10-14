extends SceneTree
# @bed-kind: diagnostic
# 附身隊後續三件 乙「先量」（spec 2026-10-13-possessed-team-followups-HOW §乙）：
#   附身 30 天真世界，玩家隊 famine_crossed 次數／天的逐日直方。兩種世界：
#     idle  ＝玩家不下令（#12 之後的常態：AI 不替他覓食）
#     hunt  ＝玩家每天下一次「狩獵」（玩家唯一的取糧動作；有零星進項的情形）
#             ★腳下沒獵物就先走到最近一格有獵物的格（move_to），到了再獵；★誠實限：挑格讀格子真值（床扮玩家，不是決策層）
#             ★第一版只在原地獵 ⇒ 開局格無獵物 ⇒ 30／30 失敗、對照世界零進項（2026-10-14 實測）⇒ 不可判
#   判準：兩世界都 ≤1 次／天 ⇒ 停點不節流；任一 >1 ⇒ 停手交 systems
#   ★計數兩路互證：①玩家事件匯流排 kind=famine_crossed 且主體含玩家隊 ②逐 tick 看 famine_days 由 ≤0 轉正（emit 的條件本身）
#   ★誠實限：遭遇一律以 draw 結束（同 multi_hop_move_bed 30 天格，讓世界跑得完）⇒ 印次數；玩家戰死凍結 ⇒ 印凍結 tick
# 跑法：.\tools\godot.ps1 --headless --script scripts/debug/possessed_famine_rate_census.gd
#   env PFR_SEEDS（預設 "1337"，逗號分隔）／PFR_DAYS（預設 30）

func _initialize() -> void:
	var seeds: Array = []
	for s in OS.get_environment("PFR_SEEDS").split(",", false):
		seeds.append(int(s))
	if seeds.is_empty():
		seeds = [1337]
	var days: int = int(OS.get_environment("PFR_DAYS")) if OS.get_environment("PFR_DAYS") != "" else 30
	print("=== possessed_famine_rate_census：附身 %d 天、玩家隊 famine_crossed 次數／天 ===" % days)
	var worst: int = 0
	for sd in seeds:
		for mode in ["idle", "hunt"]:
			worst = maxi(worst, _run(int(sd), mode, days))
	print("=== possessed_famine_rate_census DONE === 全部世界單日最多 %d 次（判準 ≤1 ⇒ 不節流）" % worst)
	quit(0)


func _run(sd: int, mode: String, days: int) -> int:
	seed(sd)
	var st := WorldState.new()
	GameSetup.setup(st, GameSetup.load_config("res://config/default.json"))
	var runner := SimRunner.new()
	var cs := PlayerCommandSystem.new()
	var ptid0: int = st.get_player_team_id()
	var per_day_ev: Dictionary = {}
	var per_day_poll: Dictionary = {}
	var last_seq: int = st.player_event_seq
	var prev_fd: float = 0.0
	var enc: int = 0
	var froze: int = -1
	var hunts_ok: int = 0
	var hunts_try: int = 0
	var hunt_food: float = 0.0
	var moves: int = 0
	var famine_ticks: int = 0
	var food_samples: Array = []
	var start_tick: int = st.world.current_tick
	var ticks: int = days * WorldState.TICKS_PER_DAY
	for i in range(ticks):
		var day: int = (st.world.current_tick - start_tick) / WorldState.TICKS_PER_DAY
		var pt: TeamData = st.teams.get(st.get_player_team_id())
		if mode == "hunt" and (st.world.current_tick - start_tick) % WorldState.TICKS_PER_DAY == 0 and pt != null:
			hunts_try += 1
			var f0: float = float(pt.resources.get("food", 0.0))
			var r: Dictionary = cs.execute_action(st, -1, "hunt")
			if bool(r.get("ok", false)):
				hunts_ok += 1
				hunt_food += maxf(0.0, float(pt.resources.get("food", 0.0)) - f0)
			elif pt.move_target == Vector2i(-1, -1):
				var g: Vector2i = _nearest_game(st, pt.tile_pos)
				if g != Vector2i(-1, -1) and bool(cs.move_to(st, g).get("ok", false)):
					moves += 1
		var res: String = runner.advance_tick(st, pt.tile_pos if pt != null else Vector2i(-1, -1))
		if st.encounter_active:
			enc += 1
			runner._encounter_system.resolve_encounter_end(st, "draw")
		if res == "awaiting_heir":
			froze = st.world.current_tick
			break
		var ptid: int = st.get_player_team_id()
		for e in st.player_events:
			var d: Dictionary = e
			if int(d.get("seq", 0)) <= last_seq:
				continue
			if String(d.get("kind", "")) == "famine_crossed" and (d.get("subjects", []) as Array).has(ptid):
				per_day_ev[day] = int(per_day_ev.get(day, 0)) + 1
		last_seq = st.player_event_seq
		pt = st.teams.get(ptid)
		if pt != null:
			if prev_fd <= 0.0 and pt.famine_days > 0.0:
				per_day_poll[day] = int(per_day_poll.get(day, 0)) + 1
			if pt.famine_days > 0.0:
				famine_ticks += 1
			prev_fd = pt.famine_days
			if (st.world.current_tick - start_tick) % WorldState.TICKS_PER_DAY == 0:
				food_samples.append(snappedf(float(pt.resources.get("food", 0.0)), 0.1))
	var tot_ev: int = 0
	var tot_poll: int = 0
	var over1: int = 0
	var mx: int = 0
	for d in per_day_ev:
		tot_ev += int(per_day_ev[d])
		mx = maxi(mx, int(per_day_ev[d]))
		if int(per_day_ev[d]) > 1:
			over1 += 1
	for d in per_day_poll:
		tot_poll += int(per_day_poll[d])
		mx = maxi(mx, int(per_day_poll[d]))
	var hist: Array = []
	for d in range(days):
		hist.append(int(per_day_ev.get(d, 0)))
	var hist_poll: Array = []
	for d in range(days):
		hist_poll.append(int(per_day_poll.get(d, 0)))
	print("\n── seed %d｜%s｜tick %d→%d（%.1f 天）｜玩家隊起始 %d ──" % [sd, mode, start_tick, st.world.current_tick,
		float(st.world.current_tick - start_tick) / WorldState.TICKS_PER_DAY, ptid0])
	print("   逐日 famine_crossed（事件匯流排）：%s" % str(hist))
	print("   逐日 famine_days 0→正（逐 tick 輪詢）：%s" % str(hist_poll))
	print("   總數 事件 %d／輪詢 %d｜>1 次的天數 %d｜單日最多 %d｜最多那天占總數 %s" % [tot_ev, tot_poll, over1, mx,
		("%.0f%%" % (100.0 * mx / tot_ev)) if tot_ev > 0 else "—"])
	print("   挨餓中的 tick %d（%.1f 天）｜遭遇強制 draw %d 次｜凍結 tick %d｜狩獵 %d／%d 成功（入帳糧 %.1f）｜走去獵場 %d 次" % [famine_ticks,
		float(famine_ticks) / WorldState.TICKS_PER_DAY, enc, froze, hunts_ok, hunts_try, hunt_food, moves])
	if mode == "hunt" and hunts_ok == 0:
		print("   ★對照世界零進項（狩獵 0 次成功）⇒ 這一列【不可判】")
	print("   隊上糧（每日開頭）：%s" % str(food_samples))
	if tot_ev != tot_poll:
		print("   ★兩路計數不一致 ⇒ 這一列【不可判】（事件 %d／輪詢 %d）" % [tot_ev, tot_poll])
	return mx


func _nearest_game(st: WorldState, from: Vector2i) -> Vector2i:
	var best: Vector2i = Vector2i(-1, -1)
	var bd: int = 1 << 30
	for k in st.world.tiles:
		var t: HexTileData = st.world.tiles[k]
		if int(t.resources.get("wild_game", 0)) <= 0 or t.tile_pos == from:
			continue
		var dq: int = t.tile_pos.x - from.x
		var dr: int = t.tile_pos.y - from.y
		var d: int = (absi(dq) + absi(dq + dr) + absi(dr)) / 2   # 同 encounter_system.hex_dist
		if d < bd:
			bd = d
			best = t.tile_pos
	return best
