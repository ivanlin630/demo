extends SceneTree

# starvation_util_escalation_trace_bed：坐實②(team14/27型)——util有沒有隨famine惡化escalation
# 每 SAMPLE_INTERVAL tick(非每tick,避免log爆量)對瀕死隊(food_days<閾值)唯讀re-query
# DecisionContext.gather+DecisionEngine.rank_scored_ctx，記錄SURVIVAL_OPTION_SET全員util
# +top3 overall，看隨food_days/famine_days惡化，argmax有無换、各option util走勢。
# 純觀測（suppress RNG/Probe同observer模式），不改production邏輯。
# 用法：SPECIMEN_SEED(default 1337) SPECIMEN_MONTHS(default 8) FOOD_DAYS_THRESHOLD(default 3.0)
# SAMPLE_INTERVAL(default 50)

func _initialize() -> void:
	_run(); quit()

const SURVIVAL_SET: Array = ["返家補給", "覓食", "掠奪", "佔村", "併入", "紮營", "乞食", "買糧", "遷移找糧"]

func _run() -> void:
	var seed_val: int = int(OS.get_environment("SPECIMEN_SEED")) if OS.has_environment("SPECIMEN_SEED") else 1337
	var months: int = int(OS.get_environment("SPECIMEN_MONTHS")) if OS.has_environment("SPECIMEN_MONTHS") else 8
	var threshold: float = float(OS.get_environment("FOOD_DAYS_THRESHOLD")) if OS.has_environment("FOOD_DAYS_THRESHOLD") else 3.0
	var sample_interval: int = int(OS.get_environment("SAMPLE_INTERVAL")) if OS.has_environment("SAMPLE_INTERVAL") else 50
	seed(seed_val)
	SimRunner.force_full_hd = true
	Probe.enabled = true
	var state := WorldState.new()
	var runner := SimRunner.new()
	var config: Dictionary = GameSetup.load_config("res://config/default.json")
	config["seed"] = seed_val
	GameSetup.setup(state, config)

	var known_ids: Dictionary = {}
	for tid in state.teams:
		known_ids[tid] = true
	var history: Dictionary = {}   # team_id -> Array[snapshot]（不設上限,稀疏取樣控量）
	var last_sampled_tick: Dictionary = {}   # team_id -> 上次取樣tick（sample_interval節流）

	var total_ticks: int = months * WorldState.TICKS_PER_MONTH
	var no_player := Vector2i(-1, -1)
	print("=== starvation_util_escalation_trace_bed: seed=%d months=%d threshold=%.1f天 interval=%d ===" % [seed_val, months, threshold, sample_interval])
	for tick in range(total_ticks):
		runner.advance_tick(state, no_player)
		for tid in state.teams:
			var t: TeamData = state.teams[tid]
			known_ids[tid] = true
			var consume: float = float(t.population) * ResourceSystem.FOOD_PER_PERSON_PER_DAY
			var eff_food: float = ResourceSystem.effective_food(state, t)
			var food_days: float = eff_food / maxf(consume, 0.001)
			if food_days >= threshold:
				continue
			var last_tick: int = int(last_sampled_tick.get(tid, -999999))
			if tick - last_tick < sample_interval:
				continue
			last_sampled_tick[tid] = tick
			# 唯讀 re-query（observer_no_global_rng 家族：suppress RNG/Probe）
			var saved_probe: bool = Probe.enabled
			var saved_suppress: bool = PathSystem.suppress_observe_noise
			Probe.enabled = false
			PathSystem.suppress_observe_noise = true
			var ctx: DecisionContext = DecisionContext.gather(state, t)
			var scored: Array = DecisionEngine.rank_scored_ctx(ctx, t.current_option)
			Probe.enabled = saved_probe
			PathSystem.suppress_observe_noise = saved_suppress
			var surv_utils: Dictionary = {}
			var top3: Array = []
			for i in range(scored.size()):
				var e: Dictionary = scored[i]
				var opt: String = String(e["opt"])
				if opt in SURVIVAL_SET:
					surv_utils[opt] = float(e["u"])
				if i < 3:
					top3.append("%s=%.3f" % [opt, float(e["u"])])
			var snap: Dictionary = {
				"tick": tick, "task": t.current_task, "task_reason": t.task_reason,
				"current_option": t.current_option, "food_days": food_days, "famine_days": t.famine_days,
				"surv_utils": surv_utils, "top3": top3,
			}
			if not history.has(tid):
				history[tid] = []
			history[tid].append(snap)
		if tick % 5000 == 0:
			print("[progress] tick=%d teams=%d tracked=%d" % [tick, state.teams.size(), history.size()])
		if state.teams.is_empty():
			break

	print("\n=== 消失隊清單 ===")
	var vanished: Array = []
	for tid in known_ids.keys():
		if not state.teams.has(tid):
			vanished.append(tid)
	vanished.sort()
	print("消失隊數=%d：%s" % [vanished.size(), str(vanished)])

	print("\n=== util escalation 軌跡（消失且曾瀕死的隊，全歷程稀疏取樣） ===")
	for tid in vanished:
		if not history.has(tid):
			continue
		print("--- team=%d（%d 筆取樣） ---" % [tid, history[tid].size()])
		for snap in history[tid]:
			print("  tick=%d task=%s(%s) option=%s food_days=%.2f famine=%.1f | top3=%s | SURVIVAL_SET utils=%s" % [
				snap["tick"], String(snap["task"]), String(snap["task_reason"]), String(snap["current_option"]),
				snap["food_days"], snap["famine_days"], str(snap["top3"]), str(snap["surv_utils"])])
	print("=== DONE ===")
