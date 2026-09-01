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
	print("[CONTROL-RAN] s7_tracer_fp_divergence_bed 已執行到主迴圈前（★對照組自證已跑）")
	print(StateFingerprint.blind_note())      # ★盲區印在使用它的當下
	print(EphemeralStateHash.note())          # ★★而被排除的那半由這把尺量，它的邊界也一起印
	# ★★★labor_crisis emit 計數（驗收②：觀測下必須 = 0，★直接數，不靠任何 hash）
	print("=== s7_tracer_fp_divergence_bed === mode=%s config=%s days=%d TICKS_PER_DAY=%d" % [mode, cfg, days, ticks_per_day])
	for d in range(days):
		for _t in range(ticks_per_day):
			runner.advance_tick(state, Vector2i(-1, -1))
		if mode == "on":
			SpecimenTracer.flush()   # ★日邊界flush,同sim_runner.gd:244既有慣例
		var fp: String = StateFingerprint.compute(state)
		var eh: String = EphemeralStateHash.compute(state)
		print("[FP] day=%d fp=%s eph=%s" % [d + 1, fp, eh])
	# ★★★驗收②：直接數 emit，★不靠任何 hash（tap key 見 world_events.gd:74 `t0.emit.<kind>`）
	print("[EMIT] t0.emit.labor_crisis = %d｜t0.emit 總 = %d"
		% [int(Probe.counts.get("t0.emit.labor_crisis", 0)), int(Probe.counts.get("t0.emit", 0))])
	print("[EMIT] ★判準：tracer on 與 off 兩跑的 labor_crisis 必須【相同】——")
	print("       ★★不是「= 0」（世界自己也會發），是【觀測沒有多發】。")
	print("=== s7_tracer_fp_divergence_bed DONE ===")
	quit()
