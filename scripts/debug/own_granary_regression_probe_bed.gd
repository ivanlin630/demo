extends SceneTree
# own_granary_regression_probe_bed：#29 own-granary-pin 長跑回歸檢查（2026-09-02）
# 目的：own_granary_tile(state=Nil) SCRIPT ERROR 在長跑期間有沒有再發生 + 機會母體。
# own_granary_tile 本身無 Probe tap（不加新tap，遵守「零新tap優先用既有」；生產碼也不歸measurer動）。
# 用「trade.meet」當機會母體 proxy：_attempt_barter（reserve→own_granary_tile 呼點）只在
# trade.meet 之後才會被呼（interaction_system.gd:709/820 皆在 meet 分支內），故 trade.meet
# 計數是「有機會走到 own_granary_tile 那條呼叫鏈」的上界代理，非精確呼叫次數。
# SCRIPT ERROR 本身無法從 GDScript 內捕捉，需外部 grep 這份 log 的 stdout。
# 用法：BED_CONFIG(default warring_states) BED_DAYS(default 90)

func _initialize() -> void:
	_run(); quit()

func _run() -> void:
	var days: int = int(OS.get_environment("BED_DAYS")) if OS.has_environment("BED_DAYS") else 90
	var cfg: String = OS.get_environment("BED_CONFIG") if OS.has_environment("BED_CONFIG") else "res://config/warring_states.json"
	var state: WorldState = MeasureBedHelper.arm_and_setup(cfg, true)
	var runner := SimRunner.new()
	var ticks: int = days * WorldState.TICKS_PER_DAY
	var no_player := Vector2i(-1, -1)
	print("=== own_granary_regression_probe_bed: config=%s days=%d ticks=%d ===" % [cfg, days, ticks])
	for tick in range(ticks):
		runner.advance_tick(state, no_player)
		if tick % 20000 == 0 and tick > 0:
			print("[CHECKPOINT] tick=%d trade.meet累計=%d teams=%d" % [
				tick, int(Probe.counts.get("trade.meet", 0)), state.teams.size()])
	print("[FINAL] trade.meet累計(機會母體proxy)=%d" % int(Probe.counts.get("trade.meet", 0)))
	print("[FINAL] trade.barter_deal累計=%d" % int(Probe.counts.get("trade.barter_deal", 0)))
	print("=== own_granary_regression_probe_bed DONE ===")
