extends SceneTree
# c1a_decision_density_bed：T-C1a決策密度——每隊每日有幾個decision-worthy事件（答「隨機附身一個隊，
# 玩家有事可做嗎」）。specimen法（讀motive→action→outcome，非aggregate）：用既有SpecimenDumpHelper
# 抽樣N隊掛SpecimenTracer，capture_decision每次呼叫=一次真正的決策贏家確立事件（非「一天20次覓食
# 數成20個決策」），逐隊逐日算次數分布。零新tap，走既有specimen機制。
# 用法：BED_CONFIG(default res://config/warring_states.json) BED_DAYS(default 30) BED_SEED(default 1337)
#   SAMPLE_N(default 5，隨機附身隊數)

func _initialize() -> void:
	_run(); quit()

func _run() -> void:
	var days: int = int(OS.get_environment("BED_DAYS")) if OS.has_environment("BED_DAYS") else 30
	var cfg: String = OS.get_environment("BED_CONFIG") if OS.has_environment("BED_CONFIG") else "res://config/warring_states.json"
	var seed_val: int = int(OS.get_environment("BED_SEED")) if OS.has_environment("BED_SEED") else 1337
	var sample_n: int = int(OS.get_environment("SAMPLE_N")) if OS.has_environment("SAMPLE_N") else 5
	seed(seed_val)
	Probe.arm()
	var state: WorldState = MeasureBedHelper.arm_and_setup(cfg, true)
	OS.set_environment("SPECIMEN_SAMPLE_N", str(sample_n))
	SpecimenDumpHelper.setup_from_env(state)
	var runner := SimRunner.new()
	var ticks: int = days * WorldState.TICKS_PER_DAY
	var no_player := Vector2i(-1, -1)

	print("=== c1a_decision_density_bed: config=%s days=%d ticks=%d seed=%d sample_n=%d ===" % [
		cfg, days, ticks, seed_val, sample_n])

	for tick in range(ticks):
		runner.advance_tick(state, no_player)
		if tick % 5000 == 0 and tick > 0:
			print("[CHECKPOINT] tick=%d decision_count累計=%d teams=%d" % [
				tick, SpecimenTracer.decision_count, state.teams.size()])

	SpecimenTracer.flush()
	var out_path: String = "docs/measurements/2026-09-07-c1a-decision-density.specimen.jsonl"
	SpecimenTracer.write_jsonl(out_path)

	print("\n=== 結果 ===")
	print("specimen隊=%s" % str(state.specimen_team_ids))
	print("decision_count(全specimen累計，SpecimenTracer既有計數器)=%d" % SpecimenTracer.decision_count)
	print("落地：%s" % out_path)

	# 逐隊逐日統計：讀_archive(entries已flush清空但_archive保留全量)
	var archive: Array = SpecimenTracer._archive
	if archive.is_empty():
		print("★archive=0⇒不可判，非結論0（可能specimen隊全數早死或母體塌陷）")
		print("=== c1a_decision_density_bed DONE ===")
		return

	var per_team_per_day: Dictionary = {}   # team_id -> {day: count}
	for e in archive:
		var tid: int = int(e.get("team_id", -1))
		var tick_v: int = int(e.get("tick", 0))
		var day: int = int(tick_v / WorldState.TICKS_PER_DAY)
		if not per_team_per_day.has(tid):
			per_team_per_day[tid] = {}
		var dd: Dictionary = per_team_per_day[tid]
		dd[day] = int(dd.get(day, 0)) + 1

	print("\n逐隊每日決策數分布：")
	for tid2 in per_team_per_day.keys():
		var dd2: Dictionary = per_team_per_day[tid2]
		var counts: Array = dd2.values()
		counts.sort()
		var sum: float = 0.0
		for c in counts: sum += c
		var avg: float = sum / counts.size() if not counts.is_empty() else 0.0
		print("  team=%d 出現天數=%d 每日決策數(min/avg/max)=%d/%.2f/%d 全部=%s" % [
			tid2, counts.size(),
			(counts[0] if not counts.is_empty() else 0), avg, (counts[-1] if not counts.is_empty() else 0),
			str(counts) if counts.size() < 40 else "(略，%d天)" % counts.size()])

	print("\n=== c1a_decision_density_bed DONE ===")
