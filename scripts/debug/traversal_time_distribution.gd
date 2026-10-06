extends SceneTree
# @bed-kind: diagnostic
# ★量測員派工（systems/藍圖 2026-10-06）：相鄰一格【實際通過時長】分佈（中位／p90，
# 按地形×日夜），對照 docs/tick_parameters.md 的意圖值——218 段卡住裡 197 段是
# insufficient_time_budget，藍圖要判這個尺度是正常還是離題。
#
# 做法：全世界普查，逐隊逐tick watch tile_pos，一旦變化就記一次「通過事件」：
#   duration = 這次變化tick − 上次變化tick（這一格真正花的時間，非理論值）
#   terrain  = 出發那格的地形（我方自己記的 prev_tile_pos，不是team.tile_pos已經變了之後的）
#   period   = 到達那一刻的日夜 period（DayNightSystem.get_time_period）
# 按 (terrain, period) 分桶，算中位數／p90。
# ★對照表：docs/tick_parameters.md 的純常數意圖值（零疲勞/零超載/零馬車/zero team-specific
# 修飾，speed_mult=1.0 起點）——實際觀測值通常會比這張表高（真隊伍有疲勞/超載/日夜複合），
# 這不是缺陷是正常，藍圖要看的是【差多少】不是【有沒有差】。
#
# 跑法：.\tools\godot.ps1 --headless --script scripts/debug/traversal_time_distribution.gd

const SEED: int = 1337
const TOTAL_TICKS: int = 30 * 1440
const BASE_MOVE_TICKS: int = 48    # movement_system.gd:5（TimeScale.MOVE_TICKS_PER_HEX）
const MIN_MOVE_TICKS: int = 16
const MAX_MOVE_TICKS: int = 144
const TERRAIN_MULT: Dictionary = {"plains": 1.0, "forest": 0.7, "mountain": 0.4}
const DAYNIGHT_MULT: Dictionary = {"day": 1.0, "dawn": 0.8, "dusk": 0.8, "night": 0.5}


func _initialize() -> void:
	var tree_sha: String = _git_head_sha()
	print("[TREE] HEAD=%s" % tree_sha)
	print("[SEED] %d｜殺玩家=否（活世界，同 observation-30day）" % SEED)

	print("\n========== 意圖值對照表（純常數，零team修飾，見 docs/tick_parameters.md） ==========")
	var intent_rows: Array = []
	for terrain in TERRAIN_MULT.keys():
		for period in DAYNIGHT_MULT.keys():
			var speed: float = float(TERRAIN_MULT[terrain]) * float(DAYNIGHT_MULT[period])
			var cost: int = clampi(int(round(float(BASE_MOVE_TICKS) / maxf(speed, 0.01))), MIN_MOVE_TICKS, MAX_MOVE_TICKS)
			intent_rows.append({"terrain": terrain, "period": period, "intent_cost": cost})
			print("  terrain=%-8s｜period=%-5s｜意圖cost=%d tick（%.2f 小時）" % [terrain, period, cost, float(cost) / 60.0])

	seed(SEED)
	var ws: WorldState = MeasureBedHelper.arm_and_setup("res://config/default.json", false)
	var runner := SimRunner.new()
	var no_player := Vector2i(-1, -1)
	var day_night := DayNightSystem.new()

	var prev_pos: Dictionary = {}          # team_id → Vector2i
	var last_change_tick: Dictionary = {}  # team_id → int
	var durations_by_bucket: Dictionary = {}   # "terrain|period" → Array[int]
	var total_steps: int = 0

	for _i in range(TOTAL_TICKS):
		runner.advance_tick(ws, no_player)
		var cur_tick: int = ws.world.current_tick
		var period: String = day_night.get_time_period(ws)
		for tid in ws.teams.keys():
			var t: TeamData = ws.teams[tid]
			if not prev_pos.has(tid):
				prev_pos[tid] = t.tile_pos
				last_change_tick[tid] = cur_tick
				continue
			var pp: Vector2i = prev_pos[tid]
			if t.tile_pos != pp:
				var duration: int = cur_tick - int(last_change_tick[tid])
				var terrain: String = _terrain_at(ws, pp)
				var key: String = "%s|%s" % [terrain, period]
				var arr: Array = durations_by_bucket.get(key, [])
				arr.append(duration)
				durations_by_bucket[key] = arr
				total_steps += 1
				prev_pos[tid] = t.tile_pos
				last_change_tick[tid] = cur_tick

	print("\n========== 實際觀測分佈（全世界 30 天，共 %d 次移動一格） ==========" % total_steps)
	var bucket_keys: Array = durations_by_bucket.keys()
	bucket_keys.sort()
	var out_rows: Array = []
	for key in bucket_keys:
		var arr: Array = durations_by_bucket[key]
		arr.sort()
		var n: int = arr.size()
		var median: float = _percentile(arr, 0.5)
		var p90: float = _percentile(arr, 0.9)
		var parts: Array = key.split("|")
		var terrain2: String = parts[0]
		var period2: String = parts[1]
		var intent: int = -1
		for ir in intent_rows:
			if ir["terrain"] == terrain2 and ir["period"] == period2:
				intent = int(ir["intent_cost"])
				break
		print("  terrain=%-8s｜period=%-5s｜n=%-5d｜中位=%-6.1f｜p90=%-6.1f｜意圖值=%d｜中位/意圖=%.2fx" \
			% [terrain2, period2, n, median, p90, intent, (median / float(intent) if intent > 0 else -1.0)])
		out_rows.append({"terrain": terrain2, "period": period2, "n": n, "median": median, "p90": p90, "intent": intent})

	var out_path: String = "docs/measurements/traversal-time-distribution.jsonl"
	var f: FileAccess = FileAccess.open(out_path, FileAccess.WRITE)
	f.store_line(JSON.stringify({"kind": "meta", "tree": tree_sha, "seed": SEED, "total_steps": total_steps}))
	for ir in intent_rows:
		f.store_line(JSON.stringify({"kind": "intent", "row": ir}))
	for row in out_rows:
		f.store_line(JSON.stringify({"kind": "observed", "row": row}))
	f.close()
	print("\n[DUMP-PATH] %s" % out_path)
	print("=== traversal_time_distribution DONE ===")
	quit(0)


func _terrain_at(ws: WorldState, pos: Vector2i) -> String:
	var tile_id: int = pos.x * 1000 + pos.y
	var t: HexTileData = ws.world.tiles.get(tile_id)
	if t == null:
		return "unknown"
	return t.terrain


func _percentile(sorted_arr: Array, p: float) -> float:
	if sorted_arr.is_empty():
		return -1.0
	var idx: float = p * float(sorted_arr.size() - 1)
	var lo: int = int(floor(idx))
	var hi: int = int(ceil(idx))
	if lo == hi:
		return float(sorted_arr[lo])
	var frac: float = idx - float(lo)
	return float(sorted_arr[lo]) * (1.0 - frac) + float(sorted_arr[hi]) * frac


func _git_head_sha() -> String:
	var out: Array = []
	OS.execute("git", ["rev-parse", "--short=9", "HEAD"], out, true)
	if out.size() > 0:
		return String(out[0]).strip_edges()
	return "UNKNOWN"
