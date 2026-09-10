extends SceneTree
# away_distance_task_bed：「不在家」是不是只是【在田裡】(blueprint加問+systems訂正票)。
# ★上一卷(resident-identity-vs-position)量到不在家隊數day60=13,但沒有補離家距離+當下task。
#   blueprint指出：這張圖最近目標2-3格(terrain-density-distance卷已量到p50=0-1 max=2-4)，
#   生產隊在快照時刻落在田間半徑內採集＝健康村莊日常，不是問題。
# ★兩欄：離家距離(hex_dist到_find_own_outpost) + 當下task
#   分「田間半徑內(≤2-3格)＝非問題」vs「遠派(>2-3格)＝才進決策層查」
# ★沿用上一卷60天/5快照窗以便可比。
# 用法：BED_CONFIG BED_SEED(default 1337)

const SNAPSHOT_DAYS: Array = [10, 20, 30, 45, 60]
const FIELD_RADIUS: int = 3   # ★操作定義(沿用terrain-density-distance卷同款門檻)，非世界性質

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

	print("=== away_distance_task_bed: config=%s seed=%d field_radius(操作定義)=%d ===" % [cfg, seed_val, FIELD_RADIUS])

	var si: int = 0
	for tick in range(max_tick + 1):
		if si < snapshot_ticks.size() and tick == snapshot_ticks[si]:
			_snapshot(state, int(SNAPSHOT_DAYS[si]), tick, fa)
			si += 1
		runner.advance_tick(state, no_player)

	print("\n=== away_distance_task_bed DONE ===")

func _snapshot(state: WorldState, day: int, tick: int, fa: FactionAISystem) -> void:
	var away_rows: Array = []
	var field_n: int = 0
	var far_n: int = 0
	var no_home_n: int = 0
	for tid in state.teams:
		var t: TeamData = state.teams[tid]
		if not t.tags.has(TeamData.TAG_PRODUCE): continue
		if FactionAISystem.is_resident_static(state, t): continue   # 只看不在家的
		var home: Vector2i = fa._find_own_outpost(state, t)
		if home == Vector2i(-1, -1):
			no_home_n += 1
			away_rows.append({"team": t.team_id, "dist": -1, "task": t.current_task, "note": "無自家outpost可比"})
			continue
		var dist: int = PathSystem._hex_dist(t.tile_pos, home)
		if dist <= FIELD_RADIUS: field_n += 1
		else: far_n += 1
		away_rows.append({"team": t.team_id, "dist": dist, "task": t.current_task})

	print("\n--- [SNAPSHOT day=%d tick=%d] ---" % [day, tick])
	print("不在家隊數=%d　田間半徑內(≤%d格)=%d　遠派(>%d格)=%d　無自家outpost可比=%d" % [
		away_rows.size(), FIELD_RADIUS, field_n, FIELD_RADIUS, far_n, no_home_n])
	for r in away_rows:
		print("  %s" % str(r))
	if away_rows.size() > 0:
		print("  ⇒ %s" % (
			"★★★全數落在田間半徑內——『不在家』確實只是【在田裡】，非問題，上一卷的憂慮可撤回"
			if far_n == 0 and no_home_n == 0 else
			("★遠派佔多數(%d/%d)——決策層問題成立，值得繼續查" % [far_n, away_rows.size()] if far_n > field_n else
			"★混合：部分在田間半徑內(非問題)、部分遠派(決策層問題)——不是單一答案")))
