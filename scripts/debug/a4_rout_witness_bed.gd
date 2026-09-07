extends SceneTree
# a4_rout_witness_bed：T-A4潰逃目擊——v2（2026-09-07修正：v1啟發式漏抓88.5%，
# 漏掉的123/139件很可能混進了control組，導致「沒有差異」是漏抓的必然結果非真結論。已作廢。）
# ★★新偵測法：combat_target同tick從有效值→-1的成對transition（retreat/pursuer在同一段
#   code同時被clear_combat_target），取readiness較低者=retreater——比「剛進TASK_FLEE」更貼近
#   事件本身（task指派可能延遲/被覆蓋，combat_target清除是事件當下唯一動作）。
#   同時要求Probe.counts["conq.combat_retreat"]本tick確實增量，排除殲滅(_end_combat)等其他
#   combat_target清除路徑混入。
# ★control組改進：只在「全世界目前無任何隊combat_target!=-1」的窗口取樣，確保乾淨不受潰逃殘留污染。
# threat_react讀法：DecisionContext.gather(state,team).threat_react（純讀，不改sim state）。
# 用法：BED_CONFIG(default res://config/warring_states.json) BED_DAYS(default 30) BED_SEED(default 1337)

const WITNESS_RADIUS: float = 3.0

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

	print("=== a4_rout_witness_bed v2: config=%s days=%d ticks=%d seed=%d witness_radius=%.1f ===" % [
		cfg, days, ticks, seed_val, WITNESS_RADIUS])

	var event_samples: Array = []
	var control_samples: Array = []
	var event_count: int = 0
	var matched_count: int = 0   # 真的配成pursuer/retreater對的次數（更嚴格母體）
	var prev_retreat_count: int = 0
	var prev_combat_target: Dictionary = {}   # tid -> 上tick的combat_target

	for tick in range(ticks):
		# 上tick快照（advance_tick前）
		var cur_combat_target: Dictionary = {}
		for tid0 in state.teams:
			cur_combat_target[tid0] = state.teams[tid0].combat_target
		runner.advance_tick(state, no_player)

		var cur_retreat: int = int(Probe.counts.get("conq.combat_retreat", 0))
		if cur_retreat > prev_retreat_count:
			event_count += 1
			# 找同tick combat_target從有效值→-1的隊（用advance_tick前的快照對比現在）
			var exited: Array = []   # [team_id, readiness]
			for tid in state.teams:
				var t: TeamData = state.teams[tid]
				var prev_ct = cur_combat_target.get(tid, -1)
				if prev_ct != -1 and t.combat_target == -1:
					exited.append([tid, t.readiness])
			if exited.size() >= 2:
				exited.sort_custom(func(a, b): return a[1] < b[1])   # readiness低者=retreater
				var retreater_id: int = exited[0][0]
				matched_count += 1
				var t2: TeamData = state.teams[retreater_id]
				var w: Array = _snap_witnesses(state, t2.tile_pos, retreater_id)
				event_samples.append_array(w)
		prev_retreat_count = cur_retreat

		# control：全世界目前無任何隊在combat中才取樣（乾淨窗口）
		if tick % 500 == 0:
			var any_combat: bool = false
			for tid3 in state.teams:
				if state.teams[tid3].combat_target != -1:
					any_combat = true; break
			if not any_combat and state.teams.size() > 0:
				var ids: Array = state.teams.keys()
				var pick_tid: int = ids[tick % ids.size()]
				var center: Vector2i = state.teams[pick_tid].tile_pos
				var w2: Array = _snap_witnesses(state, center, pick_tid)
				control_samples.append_array(w2)

		if tick % 5000 == 0 and tick > 0:
			print("[CHECKPOINT] tick=%d 事件累計=%d 成功配對=%d event樣本=%d control樣本=%d teams=%d" % [
				tick, event_count, matched_count, event_samples.size(), control_samples.size(), state.teams.size()])

	print("\n=== 結果 ===")
	print("潰逃事件母體(conq.combat_retreat)=%d｜成功配對(combat_target transition偵測到)=%d(%.1f%%)" % [
		event_count, matched_count, (float(matched_count) / float(event_count) * 100.0) if event_count > 0 else 0.0])

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
	print("②乾淨對照期(全世界無戰鬥時)鄰隊threat_react：樣本數=%d 平均=%.4f" % [control_samples.size(), control_avg])
	if control_avg > 0.0:
		print("比值(①/②)=%.3f　%s" % [event_avg / control_avg,
			"★①明顯高於②⇒目擊者真的對潰逃有反應" if event_avg / control_avg > 1.2 else
			("★①②接近⇒沒有明顯的『目擊反應』" if abs(event_avg / control_avg - 1.0) < 0.2 else "★方向不明確，需人工複核")])

	print("=== a4_rout_witness_bed DONE ===")
