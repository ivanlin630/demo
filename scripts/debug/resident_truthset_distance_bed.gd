extends SceneTree
# resident_truthset_distance_bed：不在家是不是只是在田裡(第二刀，systems裁定精確版)。
# ★systems裁：is_resident_static沒有「家」欄位，是位置謂詞不是團屬性——正確參照是
#   【謂詞自己的真值集合】，不是另找一個像家的欄位。
#   合格格(逐字同is_resident_static，faction_ai_system.gd:600-613)：
#     tile.outpost_level>0 且 (tile.outpost_owner==team.team_id
#       或 (owner存在 且 owner.faction_id==team.faction_id 且 team.faction_id!=-1))
#   報 dist_to_nearest_resident_tile(★不叫home/離家距離——它不是家，是最近可居格)
# ★第三類(你我都沒列的)：合格格集合為空⇒距離【不可判】，單獨一欄，不塞進distribution
# ★順帶保留_find_own_outpost有沒有值：「借來的居民身分」vs「自己有據點」是兩種隊。
# ★同faction的隊(faction_id!=-1)共享同一組合格格(owner.faction_id==team.faction_id那條)
#   ⇒ 按faction預先算好，效能上不用逐隊重掃全圖。
# ★沿用60天/5快照窗以便跟前兩卷可比。
# 用法：BED_CONFIG BED_SEED(default 1337)

const SNAPSHOT_DAYS: Array = [10, 20, 30, 45, 60]
const FIELD_RADIUS: int = 3   # ★操作定義沿用前兩卷

func _initialize() -> void:
	_run(); quit()

func _run() -> void:
	var cfg: String = OS.get_environment("BED_CONFIG") if OS.has_environment("BED_CONFIG") else "res://config/warring_states.json"
	var seed_val: int = int(OS.get_environment("BED_SEED")) if OS.has_environment("BED_SEED") else 1337
	seed(seed_val)
	Probe.arm()
	var state: WorldState = MeasureBedHelper.arm_and_setup(cfg, true)
	var runner := SimRunner.new()
	var no_player := Vector2i(-1, -1)
	var fa := FactionAISystem.new()

	var snapshot_ticks: Array = []
	for d in SNAPSHOT_DAYS: snapshot_ticks.append(int(d) * WorldState.TICKS_PER_DAY)
	var max_tick: int = snapshot_ticks[snapshot_ticks.size() - 1]

	print("=== resident_truthset_distance_bed: config=%s seed=%d field_radius=%d ===" % [cfg, seed_val, FIELD_RADIUS])

	var si: int = 0
	for tick in range(max_tick + 1):
		if si < snapshot_ticks.size() and tick == snapshot_ticks[si]:
			_snapshot(state, int(SNAPSHOT_DAYS[si]), tick, fa)
			si += 1
		runner.advance_tick(state, no_player)

	print("\n=== resident_truthset_distance_bed DONE ===")

func _snapshot(state: WorldState, day: int, tick: int, fa: FactionAISystem) -> void:
	# 逐字同is_resident_static：先按faction分組所有outpost_level>0且owner的faction符合的tile
	var faction_qualified: Dictionary = {}   # faction_id(owner的) -> Array[tile_pos]
	for tid in state.world.tiles:
		var tile: HexTileData = state.world.tiles[tid]
		if tile.outpost_level <= 0: continue
		var owner: TeamData = state.teams.get(tile.outpost_owner)
		if owner == null: continue
		if owner.faction_id == -1: continue
		if not faction_qualified.has(owner.faction_id): faction_qualified[owner.faction_id] = []
		(faction_qualified[owner.faction_id] as Array).append(tile.tile_pos)

	var away_rows: Array = []
	var dist_vals: Array = []
	var unjudgeable_n: int = 0
	for tid2 in state.teams:
		var t: TeamData = state.teams[tid2]
		if not t.tags.has(TeamData.TAG_PRODUCE): continue
		if FactionAISystem.is_resident_static(state, t): continue

		var candidates: Array = []
		if t.faction_id != -1 and faction_qualified.has(t.faction_id):
			candidates = faction_qualified[t.faction_id]
		elif t.faction_id == -1:
			# 無faction：只有自己擁有的outpost算合格格(逐字同謂詞的第一分支)
			var own_tile: HexTileData = state.own_outpost_tile(t.team_id)
			if own_tile != null and own_tile.outpost_level > 0: candidates = [own_tile.tile_pos]

		var own_outpost_exists: bool = fa._find_own_outpost(state, t) != Vector2i(-1, -1)

		if candidates.is_empty():
			unjudgeable_n += 1
			away_rows.append({"team": t.team_id, "dist": "不可判(真值集合空)", "task": t.current_task,
				"自己有據點": own_outpost_exists})
			continue

		var best_dist: int = 999999
		for cpos in candidates:
			var d: int = PathSystem._hex_dist(t.tile_pos, cpos)
			if d < best_dist: best_dist = d
		dist_vals.append(best_dist)
		away_rows.append({"team": t.team_id, "dist": best_dist, "task": t.current_task,
			"自己有據點": own_outpost_exists})

	print("\n--- [SNAPSHOT day=%d tick=%d] ---" % [day, tick])
	print("不在家隊數=%d　有解(可算dist_to_nearest_resident_tile)=%d　不可判(真值集合空)=%d" % [
		away_rows.size(), dist_vals.size(), unjudgeable_n])
	for r in away_rows:
		print("  %s" % str(r))
	if not dist_vals.is_empty():
		dist_vals.sort()
		var n: int = dist_vals.size()
		var field_n: int = 0
		for v in dist_vals:
			if int(v) <= FIELD_RADIUS: field_n += 1
		print("  有解母體=%d：min=%d p50=%d max=%d　田間半徑內(≤%d格)=%d(%.1f%%)　遠派=%d(%.1f%%)" % [
			n, dist_vals[0], dist_vals[n / 2], dist_vals[n - 1], FIELD_RADIUS, field_n,
			100.0 * float(field_n) / float(n), n - field_n, 100.0 * float(n - field_n) / float(n)])
	if unjudgeable_n > 0:
		print("  ★★★不可判%d隊——這些隊所屬faction(或自己)在這一刻沒有任何一格能讓is_resident_static成立，距離不是遠，是沒有指涉對象" % unjudgeable_n)
