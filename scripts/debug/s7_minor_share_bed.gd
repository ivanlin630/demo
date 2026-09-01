extends SceneTree

# ★★★minor_population佔比量測床(measurer側,純觀測,零新tap——直讀TeamData既有欄位)。
#   量 minor_population/(population+minor_population)：分佈(中位數/四分位)+隨時間變化+隊間差異。
#
# 用法：BED_CONFIG=warring_states BED_DAYS=30 godot --script scripts/debug/s7_minor_share_bed.gd

static func _percentile(sorted_arr: Array, p: float) -> float:
	if sorted_arr.is_empty(): return 0.0
	var idx: float = p * float(sorted_arr.size() - 1)
	var lo: int = int(floor(idx)); var hi: int = int(ceil(idx))
	if lo == hi: return float(sorted_arr[lo])
	var frac: float = idx - float(lo)
	return float(sorted_arr[lo]) * (1.0 - frac) + float(sorted_arr[hi]) * frac

func _initialize() -> void:
	var days: int = int(OS.get_environment("BED_DAYS")) if OS.has_environment("BED_DAYS") else 30
	var cfg: String = OS.get_environment("BED_CONFIG") if OS.has_environment("BED_CONFIG") else "warring_states"
	seed(1337)
	var state: WorldState = MeasureBedHelper.arm_and_setup("res://config/%s.json" % cfg, true)
	var runner := SimRunner.new()
	var ticks: int = days * WorldState.TICKS_PER_DAY

	var all_ratios: Array = []          # 所有team-day樣本(pooled)，denom>0才收
	var early_ratios: Array = []        # day1~10
	var late_ratios: Array = []         # day21~30(若days<30則用後1/3)
	var zero_denom_samples: int = 0     # population+minor皆0的樣本數(母體空，非佔比0%)
	var late_start_day: int = maxi(1, int(round(float(days) * 2.0 / 3.0)))

	for d in range(days):
		for _t in range(WorldState.TICKS_PER_DAY):
			runner.advance_tick(state, Vector2i(-1, -1))
		var day_no: int = d + 1
		for tid in state.teams:
			var team: TeamData = state.teams[tid]
			var denom: int = team.population + team.minor_population
			if denom <= 0:
				zero_denom_samples += 1
				continue
			var ratio: float = float(team.minor_population) / float(denom)
			all_ratios.append(ratio)
			if day_no <= 10: early_ratios.append(ratio)
			if day_no > late_start_day: late_ratios.append(ratio)

	# 期末逐隊分布(隊間差異)
	var final_ratios: Array = []
	var final_zero_denom: int = 0
	for tid2 in state.teams:
		var team2: TeamData = state.teams[tid2]
		var denom2: int = team2.population + team2.minor_population
		if denom2 <= 0: final_zero_denom += 1; continue
		final_ratios.append(float(team2.minor_population) / float(denom2))

	print("=== s7_minor_share_bed === config=%s days=%d ticks=%d" % [cfg, days, ticks])
	print("母體：結束時隊數=%d｜pooled樣本數(team-day)=%d｜denom恆0樣本數=%d"
		% [state.teams.size(), all_ratios.size(), zero_denom_samples])

	if all_ratios.is_empty():
		print("★所有team-day樣本denom皆0(population+minor恆0)⇒【母體空】，不是『佔比0%』——沒有東西可以算比例")
	else:
		all_ratios.sort()
		var sum_r: float = 0.0
		for r in all_ratios: sum_r += r
		print("── pooled(全部team-day樣本，%d筆)分佈 ──" % all_ratios.size())
		print("  mean=%.4f  median=%.4f  Q1=%.4f  Q3=%.4f  min=%.4f  max=%.4f"
			% [sum_r / float(all_ratios.size()), _percentile(all_ratios, 0.5),
			   _percentile(all_ratios, 0.25), _percentile(all_ratios, 0.75),
			   all_ratios[0], all_ratios[all_ratios.size() - 1]])

	if not early_ratios.is_empty() and not late_ratios.is_empty():
		early_ratios.sort(); late_ratios.sort()
		var se: float = 0.0; for r in early_ratios: se += r
		var sl: float = 0.0; for r in late_ratios: sl += r
		print("── 隨時間變化 ──")
		print("  day1~10   mean=%.4f median=%.4f (n=%d)" % [se / float(early_ratios.size()), _percentile(early_ratios, 0.5), early_ratios.size()])
		print("  day%d~%d mean=%.4f median=%.4f (n=%d)" % [late_start_day + 1, days, sl / float(late_ratios.size()), _percentile(late_ratios, 0.5), late_ratios.size()])
	else:
		print("── 隨時間變化：early或late樣本為空，不比 ──")

	print("── 期末(day%d)逐隊分佈(隊間差異，%d隊，denom恆0=%d隊) ──" % [days, final_ratios.size(), final_zero_denom])
	if final_ratios.is_empty():
		print("  ★期末全隊denom皆0⇒母體空")
	else:
		final_ratios.sort()
		var sf: float = 0.0; for r in final_ratios: sf += r
		print("  mean=%.4f  median=%.4f  Q1=%.4f  Q3=%.4f  min=%.4f  max=%.4f"
			% [sf / float(final_ratios.size()), _percentile(final_ratios, 0.5),
			   _percentile(final_ratios, 0.25), _percentile(final_ratios, 0.75),
			   final_ratios[0], final_ratios[final_ratios.size() - 1]])
	print("=== s7_minor_share_bed DONE ===")
	quit()
