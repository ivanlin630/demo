extends SceneTree
# @bed-kind: diagnostic
# homeless_producer_bed：「有生產身分而無自家據點」的隊——出現率/壽命/怎麼活(systems票)。
# ★謂詞逐字(票面硬要求，不用別的寫法)：
#   TAG_PRODUCE in team.tags  且  state.own_outpost_tile(team.team_id) == null
# ①出現率：逐快照(day10/20/30/45/60)報符合隊數
# ②壽命：逐日(非只5次快照)追蹤每個team_id首次/最後符合謂詞的tick(近似，非逐tick)
# ③現在怎麼活：符合隊的task分布/food資源/food_days runway
# ★窗：warring_states/seed=1337/60天(同resident-identity-vs-position卷可比)
# 用法：BED_CONFIG BED_SEED(default 1337)

const SNAPSHOT_DAYS: Array = [10, 20, 30, 45, 60]

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
	var days: int = SNAPSHOT_DAYS[SNAPSHOT_DAYS.size() - 1]
	var ticks: int = days * WorldState.TICKS_PER_DAY

	print("=== homeless_producer_bed: config=%s seed=%d days=%d ===" % [cfg, seed_val, days])
	print("★謂詞逐字：TAG_PRODUCE in team.tags 且 state.own_outpost_tile(team.team_id)==null")

	var snapshot_ticks: Array = []
	for d in SNAPSHOT_DAYS: snapshot_ticks.append(int(d) * WorldState.TICKS_PER_DAY)

	var first_seen: Dictionary = {}   # team_id -> tick 首次符合
	var last_seen: Dictionary = {}    # team_id -> tick 最後符合(逐日更新)

	var si: int = 0
	for tick in range(ticks + 1):
		# ②逐日(非逐tick)追蹤首次/最後見到
		if tick % WorldState.TICKS_PER_DAY == 0:
			for tid in state.teams:
				var t: TeamData = state.teams[tid]
				if _matches(state, t):
					if not first_seen.has(tid): first_seen[tid] = tick
					last_seen[tid] = tick
		if si < snapshot_ticks.size() and tick == snapshot_ticks[si]:
			_snapshot(state, int(SNAPSHOT_DAYS[si]), tick)
			si += 1
		if tick < ticks:
			runner.advance_tick(state, no_player)

	print("\n=== ②壽命(近似:逐日追蹤首次/最後符合謂詞的tick，非逐tick精確) ===")
	print("★這是近似——某隊若在兩次逐日檢查之間短暫符合又消失，本床量不到")
	if first_seen.is_empty():
		print("★★★母體=0——全程60天沒有任何隊符合過這個謂詞，這本身是設計缺口的第一手證據")
	else:
		var lifespans: Array = []
		for tid2 in first_seen:
			var span: int = int(last_seen[tid2]) - int(first_seen[tid2])
			lifespans.append(span)
			if lifespans.size() <= 30:
				print("  team=%s 首次tick=%d(day%.1f) 最後tick=%d(day%.1f) 跨度=%d ticks(%.1f天)" % [
					str(tid2), int(first_seen[tid2]), float(first_seen[tid2]) / float(WorldState.TICKS_PER_DAY),
					int(last_seen[tid2]), float(last_seen[tid2]) / float(WorldState.TICKS_PER_DAY),
					span, float(span) / float(WorldState.TICKS_PER_DAY)])
		lifespans.sort()
		var n: int = lifespans.size()
		print("  母體=%d隊　跨度(天)：min=%.1f p50=%.1f max=%.1f" % [
			n, float(lifespans[0]) / float(WorldState.TICKS_PER_DAY),
			float(lifespans[n / 2]) / float(WorldState.TICKS_PER_DAY),
			float(lifespans[n - 1]) / float(WorldState.TICKS_PER_DAY)])

	print("\n=== homeless_producer_bed DONE ===")

func _matches(state: WorldState, t: TeamData) -> bool:
	if not t.tags.has(TeamData.TAG_PRODUCE): return false
	var tile: HexTileData = state.own_outpost_tile(t.team_id)
	return tile == null

func _snapshot(state: WorldState, day: int, tick: int) -> void:
	var matched: Array = []
	for tid in state.teams:
		var t: TeamData = state.teams[tid]
		if _matches(state, t): matched.append(t)

	print("\n--- [SNAPSHOT day=%d tick=%d] ---" % [day, tick])
	print("①出現率：符合『生產身分+無自家據點』的隊數=%d / 全隊總數=%d" % [matched.size(), state.teams.size()])
	if matched.is_empty():
		print("  ★母體=0(這個快照時刻)")
		return

	print("③現在怎麼活(task分布/food資源/food_days runway)：")
	var task_count: Dictionary = {}
	var food_days_vals: Array = []
	for t2 in matched:
		var tk: String = t2.current_task
		task_count[tk] = int(task_count.get(tk, 0)) + 1
		var food: float = float(t2.resources.get("food", 0.0))
		var burn: float = float(t2.population) * ResourceSystem.FOOD_PER_PERSON_PER_DAY
		var fd: float = (food / burn) if burn > 0.0 else -1.0
		food_days_vals.append(fd)
		if matched.size() <= 30:
			print("  team=%d task=%s food=%.1f pop=%d food_days=%.1f" % [t2.team_id, tk, food, t2.population, fd])
	print("  task分布：%s" % str(task_count))
	food_days_vals.sort()
	var nf: int = food_days_vals.size()
	var starving: int = 0
	for v in food_days_vals:
		if v >= 0.0 and v < 3.0: starving += 1
	print("  food_days：min=%.1f p50=%.1f max=%.1f　★<3天(接近餓)的隊數=%d(%.1f%%)" % [
		food_days_vals[0], food_days_vals[nf / 2], food_days_vals[nf - 1], starving, 100.0 * float(starving) / float(nf)])
