extends SceneTree
# @bed-kind: diagnostic
# ★量測員（systems 2026-10-06，更正我上一輪兩個錯）：
#   (a) 不是 LOD——sim_runner 的 move 每個整點對全部隊伍跑，elapsed=60，far-pass 已退場
#   (b) 我對照的「意圖 48-144」出自過期的 docs/tick_parameters.md；code 現值是
#       BASE_MOVE_TICKS=240（TimeScale.MOVE_TICKS_PER_HEX，平原4小時）／MIN=80／MAX=720
# 本床對每一次「移動一格」印【夾前成本】(240/speed，不 clamp) ＋ speed 的每個乘數
# （隊速／地形／疲勞／超載／車輛），乘數【只讀】movement_system.gd 既有 pure 函式
# （team_speed_pure／get_carry_capacity_pure／calc_total_weight_pure／get_effective_wagons_pure／
# TERRAIN_SPEED_MULT／WAGON_TERRAIN_MULT），逐步複製 move_cost_pure（:241-264）的計算順序，
# 不另算一套公式。
#
# 跑法：.\tools\godot.ps1 --headless --script scripts/debug/pre_clamp_move_cost.gd

const SEED: int = 1337
const TOTAL_TICKS: int = 30 * 1440


func _initialize() -> void:
	var tree_sha: String = _git_head_sha()
	print("[TREE] HEAD=%s" % tree_sha)
	print("[SEED] %d｜殺玩家=否" % SEED)
	print("[常數校正] BASE_MOVE_TICKS=%d｜MIN_MOVE_TICKS=%d｜MAX_MOVE_TICKS=%d（★code現值，\
docs/tick_parameters.md 那張表的 48/16/144 是過期值——這是我上一輪的錯，這裡訂正）" \
		% [MovementSystem.BASE_MOVE_TICKS, MovementSystem.MIN_MOVE_TICKS, MovementSystem.MAX_MOVE_TICKS])

	seed(SEED)
	var ws: WorldState = MeasureBedHelper.arm_and_setup("res://config/default.json", false)
	var runner := SimRunner.new()
	var no_player := Vector2i(-1, -1)
	var day_night := DayNightSystem.new()

	var prev_pos: Dictionary = {}
	var step_rows: Array = []
	var hit_max_n: int = 0
	var hit_min_n: int = 0

	for _i in range(TOTAL_TICKS):
		runner.advance_tick(ws, no_player)
		var cur_tick: int = ws.world.current_tick
		var time_mult: float = day_night.get_speed_mult(ws)
		var period: String = day_night.get_time_period(ws)
		for tid in ws.teams.keys():
			var t: TeamData = ws.teams[tid]
			if not prev_pos.has(tid):
				prev_pos[tid] = t.tile_pos
				continue
			var pp: Vector2i = prev_pos[tid]
			if t.tile_pos != pp:
				# ★複製 move_cost_pure 順序：用 pp（出發格）算地形（這一步移動發生前 team.tile_pos
				#   就是 pp，跟真實計算時一致），其餘讀當下 team 欄位（fatigue/wagons/carry 在步進瞬間
				#   變化不大，這裡取偵測到變化那一刻的值，跟真實呼叫時間差 ≤ 1 tick）。
				var base_speed: float = MovementSystem.team_speed_pure(ws, t, null)
				var speed: float = base_speed * time_mult
				var terrain: String = _terrain_at(ws, pp)
				var terrain_mult: float = MovementSystem.TERRAIN_SPEED_MULT.get(terrain, 1.0)
				speed *= terrain_mult
				var fatigue_mult: float = 1.0
				if t.fatigue >= 1.0: fatigue_mult = 0.3
				elif t.fatigue > 0.5: fatigue_mult = 1.0 - t.fatigue * 0.4
				speed *= fatigue_mult
				var cap: float = MovementSystem.get_carry_capacity_pure(t)
				var weight: float = MovementSystem.calc_total_weight_pure(t)
				var overload_mult: float = 1.0
				if weight > cap and cap > 0.0: overload_mult = cap / weight
				speed *= overload_mult
				var wagons: int = MovementSystem.get_effective_wagons_pure(t)
				var wagon_mult: float = 1.0
				if wagons > 0:
					wagon_mult = MovementSystem.WAGON_TERRAIN_MULT.get(terrain, 1.0)
					speed *= wagon_mult
				var pre_clamp: float = float(MovementSystem.BASE_MOVE_TICKS) / maxf(speed, 0.01)
				var final_cost: int = clampi(int(round(pre_clamp)), MovementSystem.MIN_MOVE_TICKS, MovementSystem.MAX_MOVE_TICKS)
				var hit_max: bool = pre_clamp > float(MovementSystem.MAX_MOVE_TICKS)
				var hit_min: bool = pre_clamp < float(MovementSystem.MIN_MOVE_TICKS)
				if hit_max: hit_max_n += 1
				if hit_min: hit_min_n += 1
				step_rows.append({"tick": cur_tick, "team": int(tid), "terrain": terrain, "period": period,
					"base_speed": snappedf(base_speed, 0.001), "time_mult": time_mult, "terrain_mult": terrain_mult,
					"fatigue_mult": snappedf(fatigue_mult, 0.001), "overload_mult": snappedf(overload_mult, 0.001),
					"wagon_mult": snappedf(wagon_mult, 0.001), "pre_clamp_cost": snappedf(pre_clamp, 0.01),
					"final_cost": final_cost, "hit_max": hit_max, "hit_min": hit_min})
				prev_pos[tid] = t.tile_pos

	print("\n========== 逐次移動一格：夾前成本＋各乘數（共 %d 次） ==========" % step_rows.size())
	print("[撞界] 撞 MAX(%d)｜pre_clamp>MAX 的次數=%d（%.1f%%）｜撞 MIN(%d)｜pre_clamp<MIN 的次數=%d（%.1f%%）" % [
		MovementSystem.MAX_MOVE_TICKS, hit_max_n, (100.0 * hit_max_n / max(step_rows.size(), 1)),
		MovementSystem.MIN_MOVE_TICKS, hit_min_n, (100.0 * hit_min_n / max(step_rows.size(), 1))])
	for row in step_rows:
		print("  tick=%-6d｜team=%-3d｜terrain=%-8s｜period=%-5s｜base_speed=%.3f｜time_mult=%.2f｜\
terrain_mult=%.2f｜fatigue_mult=%.3f｜overload_mult=%.3f｜wagon_mult=%.3f｜夾前cost=%.1f｜\
最終cost=%d｜撞MAX=%s｜撞MIN=%s" % [
			int(row["tick"]), int(row["team"]), String(row["terrain"]), String(row["period"]),
			float(row["base_speed"]), float(row["time_mult"]), float(row["terrain_mult"]),
			float(row["fatigue_mult"]), float(row["overload_mult"]), float(row["wagon_mult"]),
			float(row["pre_clamp_cost"]), int(row["final_cost"]), str(row["hit_max"]), str(row["hit_min"])])

	var out_path: String = "docs/measurements/pre-clamp-move-cost.jsonl"
	var f: FileAccess = FileAccess.open(out_path, FileAccess.WRITE)
	f.store_line(JSON.stringify({"kind": "meta", "tree": tree_sha, "seed": SEED,
		"BASE_MOVE_TICKS": MovementSystem.BASE_MOVE_TICKS, "MIN_MOVE_TICKS": MovementSystem.MIN_MOVE_TICKS,
		"MAX_MOVE_TICKS": MovementSystem.MAX_MOVE_TICKS, "total_steps": step_rows.size(),
		"hit_max_n": hit_max_n, "hit_min_n": hit_min_n}))
	for row in step_rows:
		f.store_line(JSON.stringify(row))
	f.close()
	print("\n[DUMP-PATH] %s" % out_path)
	print("=== pre_clamp_move_cost DONE ===")
	quit(0)


func _terrain_at(ws: WorldState, pos: Vector2i) -> String:
	var tile_id: int = pos.x * 1000 + pos.y
	var t: HexTileData = ws.world.tiles.get(tile_id)
	if t == null:
		return "unknown"
	return t.terrain


func _git_head_sha() -> String:
	var out: Array = []
	OS.execute("git", ["rev-parse", "--short=9", "HEAD"], out, true)
	if out.size() > 0:
		return String(out[0]).strip_edges()
	return "UNKNOWN"
