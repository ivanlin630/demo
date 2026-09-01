extends SceneTree

# ★★★盈餘vs生育床(measurer側,純觀測,零新tap)。
#   per-team逐日:①rel_surplus=team.food_flow_avg/(population×FOOD_PER_PERSON_PER_DAY)
#     ——直接讀遊戲繁殖機制自己用的同一個量(reaction_system.gd:breed_rel_surplus)，不是自己發明的近似
#   ②該隊當日minor_population有無增加(=生育事件)
#   交叉：盈餘天數分佈 vs 隊級生育總數,附陽性對照(已知born事件是否落在有盈餘的隊)
#
# 用法：BED_CONFIG=peaceful_economy BED_DAYS=90 godot --script scripts/debug/s7_surplus_births_bed.gd

func _initialize() -> void:
	var days: int = int(OS.get_environment("BED_DAYS")) if OS.has_environment("BED_DAYS") else 90
	var cfg: String = OS.get_environment("BED_CONFIG") if OS.has_environment("BED_CONFIG") else "peaceful_economy"
	seed(1337)
	var state: WorldState = MeasureBedHelper.arm_and_setup("res://config/%s.json" % cfg, true)
	var runner := SimRunner.new()

	var surplus_days: Dictionary = {}     # team_id -> 盈餘天數(rel_surplus>0)
	var total_days: Dictionary = {}       # team_id -> 有效天數(該隊仍存在)
	var births: Dictionary = {}           # team_id -> 生育次數(minor_population增量加總)
	var birth_events: Array = []          # [{team, day, rel_surplus_that_day}]
	var prev_minor: Dictionary = {}
	for tid0 in state.teams:
		prev_minor[tid0] = (state.teams[tid0] as TeamData).minor_population

	for d in range(days):
		for _t in range(WorldState.TICKS_PER_DAY):
			runner.advance_tick(state, Vector2i(-1, -1))
		var day_no: int = d + 1
		for tid in state.teams:
			var team: TeamData = state.teams[tid]
			total_days[tid] = int(total_days.get(tid, 0)) + 1
			var need: float = maxf(float(team.population) * ResourceSystem.FOOD_PER_PERSON_PER_DAY, 0.001)
			var rel: float = team.food_flow_avg / need
			if rel > 0.0:
				surplus_days[tid] = int(surplus_days.get(tid, 0)) + 1
			var prev: int = int(prev_minor.get(tid, team.minor_population))
			var delta: int = team.minor_population - prev
			if delta > 0:
				births[tid] = int(births.get(tid, 0)) + delta
				birth_events.append({"team": tid, "day": day_no, "rel_surplus": rel})
			prev_minor[tid] = team.minor_population
		if day_no % 10 == 0:
			var b_so_far: int = 0
			for bv in births.values(): b_so_far += int(bv)
			print("[CHECKPOINT] day=%d teams=%d births_so_far=%d" % [day_no, state.teams.size(), b_so_far])

	print("=== s7_surplus_births_bed === config=%s days=%d" % [cfg, days])
	print("母體：結束時隊數=%d" % state.teams.size())

	# 盈餘天數分佈(逐隊，用該隊實際有效天數算比例)
	var ratios: Array = []
	for tid2 in total_days:
		var td: int = int(total_days[tid2])
		if td <= 0: continue
		ratios.append(float(surplus_days.get(tid2, 0)) / float(td))
	ratios.sort()
	print("── 盈餘天數佔比分佈(逐隊，%d隊) ──" % ratios.size())
	if ratios.is_empty():
		print("  ★母體空")
	else:
		var s: float = 0.0
		for r in ratios: s += r
		var mid: int = ratios.size() / 2
		var median: float = ratios[mid] if ratios.size() % 2 == 1 else (ratios[mid - 1] + ratios[mid]) / 2.0
		var q1: float = ratios[int(ratios.size() * 0.25)]
		var q3: float = ratios[int(ratios.size() * 0.75)]
		print("  mean=%.4f median=%.4f Q1=%.4f Q3=%.4f min=%.4f max=%.4f"
			% [s / float(ratios.size()), median, q1, q3, ratios[0], ratios[ratios.size() - 1]])

	print("── 總生育次數：%d 次（%d隊有生育） ──" % [births.values().reduce(func(a, b): return a + b, 0), births.size()])
	print("── 陽性對照：每一次生育事件當時，該隊rel_surplus是多少 ──")
	if birth_events.is_empty():
		print("  ★本輪窗口內無生育事件")
	for ev in birth_events:
		print("  team=%s day=%s rel_surplus=%.4f（%s）"
			% [str(ev["team"]), str(ev["day"]), ev["rel_surplus"],
			   "有盈餘" if ev["rel_surplus"] > 0.0 else "★無盈餘(異常，量法或定義可能有問題)"])

	print("── 隊級對照表(盈餘天數 vs 生育次數，前20隊或全部) ──")
	var ids: Array = total_days.keys()
	ids.sort()
	var shown: int = 0
	for tid3 in ids:
		if shown >= 20: break
		print("  team=%s 盈餘天數=%d/%d 生育次數=%d"
			% [str(tid3), int(surplus_days.get(tid3, 0)), int(total_days[tid3]), int(births.get(tid3, 0))])
		shown += 1
	print("=== s7_surplus_births_bed DONE ===")
	quit()
