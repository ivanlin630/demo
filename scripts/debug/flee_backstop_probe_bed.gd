extends SceneTree
# flee_backstop_probe_bed：族⑤#5 null-belief-flee backstop recheck（2026-09-02）
# movement_system.gd:85-90「修B」：task=FLEE 且 flee_from_pos=(-1,-1)(無座標)→TaskArbiter.release()+continue，
# 同tick收尾避免 continue-freeze。此處無 Probe tap（不加新tap，用行為推斷代替）。
# 推斷法：release() 若真同tick生效，下個snapshot該隊 task 應已非 FLEE；若某隊連續2+ tick
# 仍是「task=FLEE 且 flee_from_pos=(-1,-1)」＝backstop沒把它收掉＝真凍結（signature複現）。
# 母體＝本窗任何時刻進入過 TASK_FLEE 的隊數（行為病判準⑨統一版：機會母體非窗長）。
# 用法：BED_CONFIG(default res://config/warring_states.json) BED_DAYS(default 30)

func _initialize() -> void:
	_run(); quit()

func _run() -> void:
	var days: int = int(OS.get_environment("BED_DAYS")) if OS.has_environment("BED_DAYS") else 30
	var cfg: String = OS.get_environment("BED_CONFIG") if OS.has_environment("BED_CONFIG") else "res://config/warring_states.json"
	var state: WorldState = MeasureBedHelper.arm_and_setup(cfg, true)
	var runner := SimRunner.new()
	var ticks: int = days * WorldState.TICKS_PER_DAY
	var no_player := Vector2i(-1, -1)

	var flee_ever: Dictionary = {}          # tid -> true：本窗曾進 TASK_FLEE 的隊（機會母體）
	var positionless_last_tick: Dictionary = {}   # tid -> true：上個snapshot是 FLEE+positionless
	var stuck_events: int = 0               # 連續2+tick仍是FLEE+positionless 的「續卡」事件次數
	var stuck_teams: Dictionary = {}        # tid -> true：曾經連續卡住過的隊（去重）
	var backstop_worked_teams: Dictionary = {}  # tid -> true：曾在1tick內從FLEE+positionless脫離

	print("=== flee_backstop_probe_bed: config=%s days=%d ticks=%d ===" % [cfg, days, ticks])
	for tick in range(ticks):
		runner.advance_tick(state, no_player)
		var seen_positionless_this_tick: Dictionary = {}
		for tid in state.teams:
			var t: TeamData = state.teams[tid]
			if t.current_task == TeamData.TASK_FLEE:
				flee_ever[tid] = true
				if t.flee_from_pos == Vector2i(-1, -1):
					seen_positionless_this_tick[tid] = true
					if positionless_last_tick.has(tid):
						stuck_events += 1
						stuck_teams[tid] = true
		# 上一輪是 positionless、這輪已不在 seen_positionless_this_tick(不論是脫離FLEE或flee_from_pos補上)
		for tid in positionless_last_tick.keys():
			if not seen_positionless_this_tick.has(tid):
				backstop_worked_teams[tid] = true
		positionless_last_tick = seen_positionless_this_tick
		if tick % 20000 == 0 and tick > 0:
			print("[CHECKPOINT] tick=%d flee機會母體=%d 續卡事件累計=%d 續卡隊數=%d backstop生效隊數=%d" % [
				tick, flee_ever.size(), stuck_events, stuck_teams.size(), backstop_worked_teams.size()])
	print("[FINAL] flee機會母體(曾進TASK_FLEE的隊數)=%d" % flee_ever.size())
	print("[FINAL] 續卡事件累計(FLEE+positionless連續2+tick)=%d" % stuck_events)
	print("[FINAL] 續卡隊數(去重,即signature複現的隊)=%d" % stuck_teams.size())
	print("[FINAL] backstop生效隊數(曾在1tick內從FLEE+positionless脫離=release真的fire)=%d" % backstop_worked_teams.size())
	print("=== flee_backstop_probe_bed DONE ===")
