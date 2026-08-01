extends SceneTree

# starvation_desperation_trace_bed：blueprint 重判準診斷——餓死滅團隊死前有沒有嘗試絕境階梯
# (SURVIVAL_OPTION_SET=返家補給/覓食/掠奪/佔村/併入/紮營/乞食/買糧/遷移找糧 + survival/FLEE task)？
# 還是卡在非-survival task 傻站死？全隊皆 specimen（每 tick 同步 state.specimen_team_ids）→
# SpecimenTracer 捕完整決策 timeline（含死隊最後決策，archive 涵蓋）→ write_jsonl 供 post-process。
# 新檔，純觀測 debug 工具，不改任何 production 邏輯。
# 用法：SPECIMEN_SEED（default 42）SPECIMEN_MONTHS（default 6）SPECIMEN_JSONL（輸出路徑）

func _initialize() -> void:
	_run(); quit()

func _run() -> void:
	var seed_val: int = int(OS.get_environment("SPECIMEN_SEED")) if OS.has_environment("SPECIMEN_SEED") else 42
	var months: int = int(OS.get_environment("SPECIMEN_MONTHS")) if OS.has_environment("SPECIMEN_MONTHS") else 6
	var out_path: String = OS.get_environment("SPECIMEN_JSONL") if OS.has_environment("SPECIMEN_JSONL") else "res://specimen_trace.jsonl"
	seed(seed_val)
	SimRunner.force_full_hd = true
	Probe.enabled = true
	SpecimenTracer.reset()
	SpecimenTracer.enabled = true
	var state := WorldState.new()
	var runner := SimRunner.new()
	var config: Dictionary = GameSetup.load_config("res://config/default.json")
	config["seed"] = seed_val
	GameSetup.setup(state, config)

	# 全隊皆 specimen（初始 + 動態補新建隊，spawn/split 產生的新 team_id 也要捕）
	var known_ids: Dictionary = {}
	var ids: Array[int] = []
	for tid in state.teams:
		known_ids[tid] = true
		ids.append(tid)
	state.specimen_team_ids = ids
	print("=== starvation_desperation_trace_bed: seed=%d months=%d 初始隊數=%d ===" % [seed_val, months, ids.size()])

	var total_ticks: int = months * WorldState.TICKS_PER_MONTH
	var no_player := Vector2i(-1, -1)
	for tick in range(total_ticks):
		runner.advance_tick(state, no_player)
		for tid in state.teams:
			if not known_ids.has(tid):
				known_ids[tid] = true
				state.specimen_team_ids.append(tid)
		if tick % 2000 == 0:
			print("[progress] tick=%d teams=%d specimens=%d archive=%d" % [
				tick, state.teams.size(), state.specimen_team_ids.size(), SpecimenTracer._archive.size()])
		if state.teams.is_empty():
			break

	print("[bed] final teams=%d known_ids=%d archive_entries=%d" % [
		state.teams.size(), known_ids.size(), SpecimenTracer._archive.size()])
	SpecimenTracer.write_jsonl(out_path)
	print("=== DONE ===")
