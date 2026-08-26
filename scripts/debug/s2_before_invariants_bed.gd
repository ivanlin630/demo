extends SceneTree
# S2 statistical-equivalence「before」快照床（systems急件2026-08-27，slice=S2-statistical-equivalence-before）。
# ★時序關鍵：S2落地(implementer merge)前抓,之後這批before數字永遠拿不到。
# 量LOCKED§3不變項清單的【每遊戲日】事件率(不是per-tick):
#   採集量/日｜消耗/日｜製造產出/日｜移動格/日｜決策次數/日｜訊息量/日｜starve/日
#   （交易成交/日 照印但不列入裁決——4床唯一有成交的只12筆,無解析度,blueprint已同意）
# ★逐項誠實標：有既有tap讀tap,沒有的用WorldState直接讀能讀到什麼算什麼,讀不到的明講缺口不硬湊。
#
# env: LW_CONFIG / PERF_SEED / ADHOC_DAYS(default 30) / PERF_OUT

func _initialize() -> void:
	_run(); quit()

func _run() -> void:
	var cfg: String = OS.get_environment("LW_CONFIG") if OS.get_environment("LW_CONFIG") != "" else "peaceful_economy"
	var days: int = int(OS.get_environment("ADHOC_DAYS")) if OS.get_environment("ADHOC_DAYS") != "" else 30
	var sd: int = int(OS.get_environment("PERF_SEED")) if OS.get_environment("PERF_SEED") != "" else 1337
	var out_path: String = OS.get_environment("PERF_OUT")
	print("=== S2-before：config=%s days=%d seed=%d ===" % [cfg, days, sd])
	seed(sd)
	Probe.enabled = true
	Probe.reset()
	var state := WorldState.new()
	var runner := SimRunner.new()
	var config: Dictionary = GameSetup.load_config("res://config/%s.json" % cfg)
	if config.is_empty():
		print("[FAIL] config 載入失敗"); return
	config["seed"] = sd
	GameSetup.setup(state, config)
	state.player_id = -1
	var teams_start: int = state.teams.size()

	# ★移動格/日代理：day boundary 位置快照，算Σhex距離（低估多跳移動，明講caveat）
	var prev_pos: Dictionary = {}
	for tid in state.teams:
		prev_pos[tid] = state.teams[tid].tile_pos
	var move_tiles_total: int = 0

	var no_player := Vector2i(-1, -1)
	var wall_t0: int = Time.get_ticks_usec()
	for tick in range(days * WorldState.TICKS_PER_DAY):
		runner.advance_tick(state, no_player)
		if state.encounter_active and state.encounter_tick > 800:
			runner._encounter_system.resolve_encounter_end(state, "draw")
		if state.teams.is_empty(): break
		if (tick + 1) % WorldState.TICKS_PER_DAY == 0:
			var day_move: int = 0
			for tid2 in state.teams:
				var t2: TeamData = state.teams[tid2]
				if prev_pos.has(tid2):
					day_move += _hex_dist(prev_pos[tid2], t2.tile_pos)
				prev_pos[tid2] = t2.tile_pos
			move_tiles_total += day_move
	var wall_total: int = Time.get_ticks_usec() - wall_t0

	var lines: Array = []
	lines.append("=== S2-before dump ===")
	lines.append("★配對頭(after那輪必須完全照抄才能比)：config=%s seed=%d days=%d teams_start=%d wall_s=%.1f" % [
		cfg, sd, days, teams_start, float(wall_total) / 1e6])
	lines.append("teams_end=%d" % state.teams.size())
	lines.append("")
	lines.append("--- ①決策次數/日(有tap,但只涵蓋unified.rank/rank_scored那條路徑,不含rank_survival) ---")
	var rank_calls: int = int(Probe.counts.get("unified.rank.calls", 0))
	lines.append("  unified.rank.calls(母體=whole window) = %d ⇒ /日 = %.2f" % [rank_calls, float(rank_calls) / float(days)])

	lines.append("--- ②starve/日(有tap) ---")
	var starve_minor: int = int(Probe.counts.get("death.starve_minor", 0))
	var starve_anon: int = int(Probe.counts.get("death.starve_anon", 0))
	lines.append("  death.starve_minor = %d ⇒ /日 = %.3f" % [starve_minor, float(starve_minor) / float(days)])
	lines.append("  death.starve_anon  = %d ⇒ /日 = %.3f" % [starve_anon, float(starve_anon) / float(days)])

	lines.append("--- ③製造產出/日(有tap,add_amount每種resource分開,這裡加總) ---")
	var mfg_total: float = 0.0
	var mfg_detail: Array = []
	for k in Probe.amounts.keys():
		if String(k).begins_with("manufacture.output."):
			var v: float = float(Probe.amounts[k])
			mfg_total += v
			mfg_detail.append("%s=%.1f" % [String(k).substr(19), v])
	lines.append("  manufacture.output.*加總 = %.1f ⇒ /日 = %.2f　明細=%s" % [mfg_total, mfg_total / float(days), str(mfg_detail)])

	lines.append("--- ④訊息量/日(讀state.global_messages.size(),非tap,WorldState直讀) ---")
	lines.append("  global_messages總量(累計非清空) = %d ⇒ /日 = %.2f　★caveat:若訊息會被prune清除,這是『累計產生量』非『存量』" % [
		state.global_messages.size(), float(state.global_messages.size()) / float(days)])

	lines.append("--- ⑤移動格/日(WorldState day-boundary位置快照代理,非精確tap) ---")
	lines.append("  Σhex距離(day-boundary快照法) = %d ⇒ /日 = %.2f　★★caveat:低估——同一天內移動又折返的距離不會被day-boundary快照法算到，這是下限不是真值" % [
		move_tiles_total, float(move_tiles_total) / float(days)])

	lines.append("--- ⑥採集量/日：★缺口，沒有既有quantity tap ---")
	lines.append("  collect.gather_ran/collect.l0_forage_ran 只是【事件次數】(有沒有跑gather迴圈)，不是【採集數量】")
	lines.append("  現有code沒有Probe.add_amount記錄實際採集到的資源量——這格答不出來，需要implementer在resource_system.gd的_collect_from_tile加tap才能量")

	lines.append("--- ⑦消耗/日：★缺口，沒有既有quantity tap ---")
	lines.append("  resolve_consumption(resource_system.gd)扣糧邏輯沒有掛Probe.add_amount記錄總消耗量")
	lines.append("  這格答不出來，需要implementer加tap才能量")

	lines.append("--- ⑧交易成交/日(照印,不列入裁決——4床只12筆,無解析度) ---")
	var mk_orders: Array = Probe.samples.get("mkfill.order", []) as Array
	lines.append("  mkfill.order樣本數(cap受限,非真count) = %d　★不列入S2裁決" % mk_orders.size())

	var text: String = "\n".join(PackedStringArray(lines))
	print(text)
	if out_path != "":
		var f := FileAccess.open(out_path, FileAccess.WRITE)
		if f != null:
			f.store_string(text + "\n"); f.close()
	print("=== S2-before DONE ===")

func _hex_dist(a: Vector2i, b: Vector2i) -> int:
	var dx := b.x - a.x
	var dy := b.y - a.y
	if (dx >= 0) == (dy >= 0):
		return maxi(absi(dx), absi(dy))
	return absi(dx) + absi(dy)
