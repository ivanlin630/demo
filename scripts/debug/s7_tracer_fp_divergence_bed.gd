extends SceneTree

# ★★★S7 specimen tracer侵入性驗證床(measurer側,純觀測)。
#   同seed同config跑兩次:①不開tracer②開tracer，逐日比對state_fingerprint找第一個分岔日。
#
# 用法：TRACER_MODE=off|on BED_CONFIG=warring_states BED_DAYS=15 godot --script scripts/debug/s7_tracer_fp_divergence_bed.gd

func _initialize() -> void:
	var days: int = int(OS.get_environment("BED_DAYS")) if OS.has_environment("BED_DAYS") else 15
	var cfg: String = OS.get_environment("BED_CONFIG") if OS.has_environment("BED_CONFIG") else "warring_states"
	var mode: String = OS.get_environment("TRACER_MODE") if OS.has_environment("TRACER_MODE") else "off"
	seed(1337)
	var state: WorldState = MeasureBedHelper.arm_and_setup("res://config/%s.json" % cfg, true)

	if mode == "on":
		# ★確定性strided取樣(照SpecimenDumpHelper同手法,零RNG)——固定抓5隊(或全部,取小者)
		var all_ids: Array = state.teams.keys()
		all_ids.sort()
		var sample_n: int = mini(5, all_ids.size())
		var step: float = float(all_ids.size()) / float(sample_n)
		var ids: Array[int] = []
		for i in range(sample_n):
			ids.append(all_ids[int(i * step)])
		state.specimen_team_ids = ids
		SpecimenTracer.reset()
		SpecimenTracer.enabled = true
		print("[TracerFP] mode=on specimen_team_ids=%s" % str(ids))
	else:
		print("[TracerFP] mode=off（SpecimenTracer.enabled維持false）")

	var runner := SimRunner.new()
	var ticks_per_day: int = WorldState.TICKS_PER_DAY
	print("=== s7_tracer_fp_divergence_bed === mode=%s config=%s days=%d TICKS_PER_DAY=%d" % [mode, cfg, days, ticks_per_day])
	for d in range(days):
		for _t in range(ticks_per_day):
			runner.advance_tick(state, Vector2i(-1, -1))
		if mode == "on":
			SpecimenTracer.flush()   # ★日邊界flush,同sim_runner.gd:244既有慣例
		var fp: String = StateFingerprint.compute(state)
		print("[FP] day=%d fp=%s" % [d + 1, fp])
	print("=== s7_tracer_fp_divergence_bed DONE ===")
	quit()
