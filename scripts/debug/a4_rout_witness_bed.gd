extends SceneTree
# a4_rout_witness_bed：T-A4潰逃目擊——上游有發(conq.combat_retreat+俘獲廣播)已對帳確認，
# 問題收斂成【下游同格/鄰格目擊隊有沒有讀】：threat_react在潰逃事件當下有沒有比平常高。
# ★判準成對：①事件tick鄰隊threat_react（有潰逃） ②隨機對照tick同批鄰隊threat_react（沒潰逃）
#   —— 事件當下即時snapshot，非跑完後回頭分析（避開「世界只剩最終快照讀不到過去」的陷阱）。
# 零新tap，用既有 conq.combat_retreat 計數增量偵測事件tick；事件位置用啟發式：
#   該tick剛進入TASK_FLEE(task_start_tick==current_tick)的隊視為retreater候選，取其tile_pos。
#   ★如實聲明：此為啟發式非精確tap，可能漏抓/誤抓部分事件。
# threat_react讀法：DecisionContext.gather(state,team).threat_react（純讀，不改sim state）。
# 用法：BED_CONFIG(default res://config/warring_states.json) BED_DAYS(default 30) BED_SEED(default 1337)

const WITNESS_RADIUS: float = 3.0   # 同格/鄰格半徑（六角格距離近似，用歐氏距離）

func _initialize() -> void:
	_run(); quit()

func _snap_witnesses(state: WorldState, center: Vector2i, exclude_tid: int) -> Array:
	var out: Array = []
	for tid in state.teams:
		if tid == exclude_tid: continue
		var t: TeamData = state.teams[tid]
		var dist: float = Vector2(t.tile_pos.x - center.x, t.tile_pos.y - center.y).length()
		if dist <= WITNESS_RADIUS:
			var ctx: DecisionContext = DecisionContext.gather(state, t)
			out.append(ctx.threat_react)
	return out

func _run() -> void:
	var days: int = int(OS.get_environment("BED_DAYS")) if OS.has_environment("BED_DAYS") else 30
	var cfg: String = OS.get_environment("BED_CONFIG") if OS.has_environment("BED_CONFIG") else "res://config/warring_states.json"
	var seed_val: int = int(OS.get_environment("BED_SEED")) if OS.has_environment("BED_SEED") else 1337
	seed(seed_val)
	Probe.arm()
	var state: WorldState = MeasureBedHelper.arm_and_setup(cfg, true)
	var runner := SimRunner.new()
	var ticks: int = days * WorldState.TICKS_PER_DAY
	var no_player := Vector2i(-1, -1)

	print("=== a4_rout_witness_bed: config=%s days=%d ticks=%d seed=%d witness_radius=%.1f ===" % [
		cfg, days, ticks, seed_val, WITNESS_RADIUS])

	var event_samples: Array = []    # 有潰逃時鄰隊threat_react（攤平成單一array）
	var control_samples: Array = []  # 對照期（每5000tick固定取樣一次，同半徑邏輯，中心用世界重心）
	var event_count: int = 0
	var prev_retreat_count: int = 0

	for tick in range(ticks):
		runner.advance_tick(state, no_player)
		var cur_retreat: int = int(Probe.counts.get("conq.combat_retreat", 0))
		if cur_retreat > prev_retreat_count:
			for tid in state.teams:
				var t: TeamData = state.teams[tid]
				if t.current_task == TeamData.TASK_FLEE and t.task_start_tick == state.world.current_tick:
					event_count += 1
					var w: Array = _snap_witnesses(state, t.tile_pos, tid)
					event_samples.append_array(w)
		prev_retreat_count = cur_retreat
		# 對照期：固定間隔（跟事件無關）取樣，中心用當時隨機挑一隊的位置（模擬「隨便一個位置附近」）
		if tick % 3000 == 1500 and state.teams.size() > 0:
			var ids: Array = state.teams.keys()
			var pick_tid: int = ids[tick % ids.size()]
			var center: Vector2i = state.teams[pick_tid].tile_pos
			var w2: Array = _snap_witnesses(state, center, pick_tid)
			control_samples.append_array(w2)
		if tick % 5000 == 0 and tick > 0:
			print("[CHECKPOINT] tick=%d 累計事件(啟發式)=%d event樣本=%d control樣本=%d teams=%d" % [
				tick, event_count, event_samples.size(), control_samples.size(), state.teams.size()])

	print("\n=== 結果 ===")
	print("潰逃事件母體(啟發式偵測)=%d（對照：conq.combat_retreat總計=%d，兩者差距=漏抓/誤抓程度）" % [
		event_count, int(Probe.counts.get("conq.combat_retreat", 0))])

	if event_samples.is_empty():
		print("★event樣本=0⇒不可判，非結論0")
		print("=== a4_rout_witness_bed DONE ===")
		return

	var event_sum: float = 0.0
	for v in event_samples: event_sum += v
	var event_avg: float = event_sum / event_samples.size()

	var control_avg: float = -1.0
	if not control_samples.is_empty():
		var control_sum: float = 0.0
		for v2 in control_samples: control_sum += v2
		control_avg = control_sum / control_samples.size()

	print("①有潰逃時鄰隊threat_react：樣本數=%d 平均=%.4f" % [event_samples.size(), event_avg])
	print("②對照期(無潰逃鎖定)鄰隊threat_react：樣本數=%d 平均=%.4f" % [control_samples.size(), control_avg])
	if control_avg > 0.0:
		print("比值(①/②)=%.3f　%s" % [event_avg / control_avg,
			"★①明顯高於②⇒目擊者真的對潰逃有反應" if event_avg / control_avg > 1.2 else
			("★①②接近⇒沒有明顯的『目擊反應』" if abs(event_avg / control_avg - 1.0) < 0.2 else "★方向不明確，需人工複核")])

	print("=== a4_rout_witness_bed DONE ===")
