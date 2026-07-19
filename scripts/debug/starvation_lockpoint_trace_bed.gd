extends SceneTree

# starvation_lockpoint_trace_bed：坐實死隊/逃隊的確切鎖點
# 直接讀 team state（非經 SpecimenTracer）：瀕死隊(food_days<閾值) OR 逃跑隊(TASK_FLEE，
# 不論 food 狀態，捕戰鬥驅動的逃跑動機→行動→結局) 每次取樣記錄
# current_task/combat_target/current_option/food_days/flee_from_pos，抓死亡/消失前軌跡。
# ★QA seed4201 regression 判準要（2026-07-18）：加收 survival_committed_option/
# survival_stall_cooldown，逐 tick 比對偵測「新排除進 cooldown」= stall_exclude fire 事件，
# 印 fire 前後 option + food_days 走勢（判 mis-fire 誤排除正在起作用的 option vs 窮死換無效格）。
# ★blueprint 當前世界故事審（2026-07-19）：加 TASK_FLEE 觸發(不限 food_days)+flee_from_pos，
# 捕「逃跑主導/人口重摔」是否 coherent（真威脅觸發+真逃離某位置）vs broken（對空氣逃）。
# 純觀測，不改 production 邏輯。用法：SPECIMEN_SEED(default 1337) SPECIMEN_MONTHS(default 8)
# FOOD_DAYS_THRESHOLD(default 3.0，低於此才記錄，省開銷)

func _initialize() -> void:
	_run(); quit()

func _run() -> void:
	var seed_val: int = int(OS.get_environment("SPECIMEN_SEED")) if OS.has_environment("SPECIMEN_SEED") else 1337
	var months: int = int(OS.get_environment("SPECIMEN_MONTHS")) if OS.has_environment("SPECIMEN_MONTHS") else 8
	var threshold: float = float(OS.get_environment("FOOD_DAYS_THRESHOLD")) if OS.has_environment("FOOD_DAYS_THRESHOLD") else 3.0
	# ★對齊 WarringHarness.run()（seeded_warring_bed.gd 用的同一條 setup 序列）——
	# 之前誤用 res://config/default.json + force_full_hd=true，跟 aggregate 量測用的
	# warring_states.json（無 force_full_hd）是完全不同世界，seed 一樣也對不上（血教訓已修）。
	seed(seed_val)
	Probe.enabled = true
	Probe.reset()
	FactionAISystem._a2b_remote_tribute_payers.clear()
	var state := WorldState.new()
	var runner := SimRunner.new()
	var config_path: String = OS.get_environment("WARRING_CONFIG") if OS.get_environment("WARRING_CONFIG") != "" else "res://config/warring_states.json"
	var config: Dictionary = GameSetup.load_config(config_path)
	config["seed"] = seed_val
	GameSetup.setup(state, config)

	var known_ids: Dictionary = {}
	for tid in state.teams:
		known_ids[tid] = true
	var last_seen: Dictionary = {}   # team_id -> last near-death snapshot (Dictionary) before it vanished
	var history: Dictionary = {}     # team_id -> Array[snapshot]（最近 300 筆，看軌跡非只最後一刻）
	var fire_events: Dictionary = {}    # team_id -> Array[fire event dict]（stall_exclude 新排除偵測）
	var prev_cooldown_keys: Dictionary = {}   # team_id -> Array[option 字串]（上次看到的 cooldown key 集合，比對增量）

	var total_ticks: int = months * WorldState.TICKS_PER_MONTH
	var no_player := Vector2i(-1, -1)
	print("=== starvation_lockpoint_trace_bed: seed=%d months=%d threshold=%.1f天 ===" % [seed_val, months, threshold])
	for tick in range(total_ticks):
		runner.advance_tick(state, no_player)
		for tid in state.teams:
			var t: TeamData = state.teams[tid]
			known_ids[tid] = true
			var consume: float = float(t.population) * ResourceSystem.FOOD_PER_PERSON_PER_DAY
			var eff_food: float = ResourceSystem.effective_food(state, t)
			var food_days: float = eff_food / maxf(consume, 0.001)
			# stall_exclude fire 偵測：不限 food_days<threshold（fire 當下可能 food_days 剛好在門檻邊緣或稍高），
			# 只要曾進過瀕死追蹤（history 已有記錄）的隊，全程比對 cooldown key 增量。
			var cur_cooldown_keys: Array = t.survival_stall_cooldown.keys()
			if prev_cooldown_keys.has(tid):
				var prev_keys: Array = prev_cooldown_keys[tid]
				for k in cur_cooldown_keys:
					if k not in prev_keys:
						if not fire_events.has(tid):
							fire_events[tid] = []
						fire_events[tid].append({
							"tick": tick, "excluded_option": k, "food_days_at_fire": food_days,
							"committed_option_before": t.survival_committed_option,
							"famine_days": t.famine_days,
						})
			prev_cooldown_keys[tid] = cur_cooldown_keys
			if food_days < threshold or t.current_task == TeamData.TASK_FLEE:
				var reason_stripped: String = t.task_reason.trim_prefix("defy_")
				var self_replace_would_work: bool = (t.combat_target == -1) and (
					t.current_task == TeamData.TASK_IDLE or TaskArbiter.PRIO_SURVIVAL > t.task_priority or (
						t.task_priority == TaskArbiter.PRIO_SURVIVAL and "survival" in TaskArbiter.ENGINE_SOURCES
						and reason_stripped in TaskArbiter.ENGINE_SOURCES))
				var snap: Dictionary = {
					"tick": tick, "team_id": tid, "task": t.current_task,
					"combat_target": t.combat_target, "current_option": t.current_option,
					"food_days": food_days, "pop": t.population, "famine_days": t.famine_days,
					"task_priority": t.task_priority, "task_reason": t.task_reason,
					"would_survival_dispatch_succeed": self_replace_would_work,
					"survival_committed_option": t.survival_committed_option,
					"survival_stall_cooldown_keys": str(cur_cooldown_keys),
					"tile_pos": t.tile_pos, "move_target": t.move_target,
					"flee_from_pos": t.flee_from_pos,
				}
				# ★slice2-perception QA要：belief-vs-live 落差（併入/absorb target 用 belief_pos 導航，
				# 對照 target 真 live tile_pos，看是否『信念位置跟真實位置不同→走錯路』新模式）。
				if t.absorb_target_cache != -1 and state.teams.has(t.absorb_target_cache):
					var tgt_team: TeamData = state.teams[t.absorb_target_cache]
					var bp: Vector2i = BeliefSystem.belief_pos(state, tid, t.absorb_target_cache)
					snap["absorb_target_id"] = t.absorb_target_cache
					snap["absorb_target_belief_pos"] = bp
					snap["absorb_target_live_pos"] = tgt_team.tile_pos
					snap["belief_vs_live_gap"] = (bp - tgt_team.tile_pos).length() if bp != Vector2i(-1, -1) else -1.0
				last_seen[tid] = snap
				if not history.has(tid):
					history[tid] = []
				var h: Array = history[tid]
				h.append(snap)
				if h.size() > 300:
					h.pop_front()
		if tick % 5000 == 0:
			print("[progress] tick=%d teams=%d near_death_tracked=%d" % [tick, state.teams.size(), last_seen.size()])
		if state.teams.is_empty():
			break

	# 找出消失的隊（known 但現在 state.teams 沒有）= 已滅團（餓死或其他因）
	print("\n=== 消失隊清單（known_ids 有、現 state.teams 無）===")
	var vanished: Array = []
	for tid in known_ids.keys():
		if not state.teams.has(tid):
			vanished.append(tid)
	vanished.sort()
	print("消失隊數=%d：%s" % [vanished.size(), str(vanished)])

	print("\n=== 消失隊死前鎖點（僅印曾被記錄=曾瀕死的） ===")
	for tid in vanished:
		if not last_seen.has(tid):
			print("--- team=%d：從未進入瀕死追蹤(food_days<%.1f)——非本輪diagnostic對象(可能戰死/其他) ---" % [tid, threshold])
			continue
		print("--- team=%d 死前軌跡（最近 %d 筆瀕死快照） ---" % [tid, history[tid].size()])
		for snap in history[tid]:
			var extra: String = ""
			if snap.has("belief_vs_live_gap"):
				extra = " absorb_target=%d belief_pos=%s live_pos=%s gap=%.1f" % [
					snap["absorb_target_id"], str(snap["absorb_target_belief_pos"]),
					str(snap["absorb_target_live_pos"]), snap["belief_vs_live_gap"]]
			print("    tick=%d task=%s prio=%d reason=%s combat_target=%d option=%s food_days=%.2f pop=%d famine_days=%.1f tile=%s move_target=%s flee_from=%s committed=%s cooldown=%s survival_dispatch_would_succeed=%s%s" % [
				snap["tick"], String(snap["task"]), snap["task_priority"], String(snap["task_reason"]),
				snap["combat_target"], String(snap["current_option"]),
				snap["food_days"], snap["pop"], snap["famine_days"],
				str(snap["tile_pos"]), str(snap["move_target"]), str(snap["flee_from_pos"]),
				String(snap["survival_committed_option"]), String(snap["survival_stall_cooldown_keys"]),
				str(snap["would_survival_dispatch_succeed"]), extra])
		if fire_events.has(tid):
			print("    ★★ stall_exclude FIRE 事件（%d 次）：" % fire_events[tid].size())
			for ev in fire_events[tid]:
				print("      tick=%d 排除=%s (排除前承諾option=%s) food_days_at_fire=%.2f famine_days=%.1f" % [
					ev["tick"], String(ev["excluded_option"]), String(ev["committed_option_before"]),
					ev["food_days_at_fire"], ev["famine_days"]])
		else:
			print("    （此隊死前無 stall_exclude fire 事件——純窮死，非 exclusion 誤排除路徑）")
	print("=== DONE ===")
