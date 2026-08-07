extends SceneTree

# [measurer持久fixture 2026-08-08] care-loop de-patch(feat/careloop-scout-depatch)death-spiral驗收。
# ticket:docs/superpowers/handbacks/2026-08-08-systems-to-measurer-careloop-deathspiral.md
# 目的:量care.scout_dispatched破silent-return否+scout抵達後relief/distribute有無接上+
#      ★★核心:Team2(famine受害隊)在day25脫離勢力前有無得救(死亡螺旋破否)+dispersed attrition降否(前33.3%)。
# 附SpecimenDumpHelper(motive→action→outcome)送QA故事稽核。
# 純觀測:inline SimRunner、既有Probe tap讀值(零production code改)、
#         同fixture(infonet_scale_econ_dispersed.json)+同seed可對main baseline / worktree fix branch跑同腳本比較。
# 用法:env DS_SEED(預設8181) DS_DAYS(預設45)。--path .worktrees/careloop-scout-depatch 跑fix branch,main dir跑baseline對照。

const DISP_CONFIG := "res://config/infonet_scale_econ_dispersed.json"
const T2: int = 2
const ORIG_TIDS: Array = [0, 1, 2, 3]

func _initialize() -> void:
	var seed_env: String = OS.get_environment("DS_SEED")
	var days_env: String = OS.get_environment("DS_DAYS")
	var s: int = int(seed_env) if seed_env != "" else 8181
	var days: int = int(days_env) if days_env != "" else 45
	print("=== care-loop de-patch death-spiral驗收(seed=%d %d天,Team2focus) ===" % [s, days])

	seed(s)
	FactionAISystem._a2b_remote_tribute_payers.clear()
	Probe.reset(); Probe.enabled = true
	var state := WorldState.new()
	var runner := SimRunner.new()
	var config: Dictionary = GameSetup.load_config(DISP_CONFIG)
	config["seed"] = s
	GameSetup.setup(state, config)
	var no_player := Vector2i(-1, -1)
	var ticks: int = WorldState.TICKS_PER_DAY * days
	var start_pop: int = _total_pop(state)

	state.specimen_team_ids = [0, 1, 2, 3]
	SpecimenTracer.reset(); SpecimenTracer.enabled = true

	var watch_keys: Array = ["care.scout_dispatched", "care.firsthand_distress", "distribute.dispatch",
		"contact.overdue", "contact.care_check", "contact.care_ignore", "help.letter_dispatched",
		"convoy.deliver_settled", "convoy.dispatch"]
	var prev_counts: Dictionary = {}
	for k in watch_keys: prev_counts[k] = 0
	var totals: Dictionary = {}
	for k in watch_keys: totals[k] = 0

	var defect_day: int = -1
	var t2_alive_at_defect: bool = true
	var t2_pop_at_defect: int = -1
	var daily_log: Array = []

	for tick in range(ticks):
		runner.advance_tick(state, no_player)
		if state.encounter_active and state.encounter_tick > 800:
			runner._encounter_system.resolve_encounter_end(state, "draw")
		# 動態追加 scout/convoy 子隊進 specimen（daily cadence 免每tick全隊掃效能負擔）
		if state.world.current_tick % WorldState.TICKS_PER_DAY == 0:
			for tid in state.teams:
				var t: TeamData = state.teams[tid]
				if (t.current_task == TeamData.TASK_SCOUT or t.current_task == TeamData.TASK_CONVOY) and not int(tid) in state.specimen_team_ids:
					state.specimen_team_ids.append(int(tid))
			var day: int = state.world.current_tick / WorldState.TICKS_PER_DAY
			var entry: Dictionary = {"day": day}
			for k in watch_keys:
				var cur: int = int(Probe.counts.get(k, 0))
				var delta: int = cur - int(prev_counts[k])
				entry[k] = delta; prev_counts[k] = cur; totals[k] = int(totals[k]) + delta
			if state.teams.has(T2) and state.teams.has(0):
				# 純讀複製 _faction_roster_pos 判斷式(零 production 改)：查 fix 的 roster fallback 對 T2 實際解出什麼
				var roster_pos: Vector2i = FactionAISystem._faction_roster_pos(state, state.teams[0], T2)
				entry["t2_roster_pos_probe"] = str(roster_pos)
				entry["lord_anon_pool"] = AnonTierSystem.total_pop(state.teams[0])   # 純讀:dispatch_anon_messenger自己的gate,零production改
			if state.teams.has(T2):
				var t2: TeamData = state.teams[T2]
				entry["t2_faction_id"] = t2.faction_id
				entry["t2_pop"] = t2.population
				entry["t2_task"] = t2.current_task
				if defect_day == -1 and t2.faction_id == -1:
					defect_day = day
					t2_pop_at_defect = t2.population
					t2_alive_at_defect = t2.population > 0
			else:
				entry["t2_faction_id"] = null; entry["t2_pop"] = 0
				if defect_day == -1: defect_day = day; t2_alive_at_defect = false; t2_pop_at_defect = 0
			daily_log.append(entry)
			if day <= 30 or int(entry.get("care.scout_dispatched", 0)) > 0 or int(entry.get("care.firsthand_distress", 0)) > 0 or int(entry.get("distribute.dispatch", 0)) > 0:
				print("  day%d: t2_faction=%s t2_pop=%s t2_task=%s roster_probe=%s lord_anon=%s | scout_dispatch+=%d firsthand+=%d distribute+=%d overdue+=%d care_check+=%d care_ignore+=%d" % [
					day, str(entry.get("t2_faction_id")), str(entry.get("t2_pop")), str(entry.get("t2_task")), str(entry.get("t2_roster_pos_probe")), str(entry.get("lord_anon_pool")),
					int(entry.get("care.scout_dispatched", 0)), int(entry.get("care.firsthand_distress", 0)),
					int(entry.get("distribute.dispatch", 0)), int(entry.get("contact.overdue", 0)),
					int(entry.get("contact.care_check", 0)), int(entry.get("contact.care_ignore", 0))])

	var end_pop: int = _total_pop(state)
	var t2_final_pop: int = int(state.teams[T2].population) if state.teams.has(T2) else 0
	var attrition_pct: float = 0.0 if start_pop == 0 else 100.0 * (start_pop - end_pop) / float(start_pop)

	print("\n───── 死亡螺旋破否核心判準 ─────")
	print("  defect_day=%d t2_pop_at_defect=%d t2_alive_at_defect=%s" % [defect_day, t2_pop_at_defect, str(t2_alive_at_defect)])
	print("  end(day%d): pop=%d attrition=%.1f%% t2_final_pop=%d t2_final_alive=%s" % [days, end_pop, attrition_pct, t2_final_pop, str(t2_final_pop > 0)])
	print("  ★watch_key totals(整窗口): %s" % str(totals))

	SpecimenTracer.flush()
	var spec_path: String = "docs/measurements/2026-08-08-scale-econ-deathspiral-seed%d.specimen.jsonl" % s
	SpecimenDumpHelper.dump(state, spec_path)
	SpecimenTracer.reset()
	Probe.enabled = false

	var dump: Dictionary = {"seed": s, "days": days, "start_pop": start_pop, "end_pop": end_pop,
		"attrition_pct": attrition_pct, "defect_day": defect_day, "t2_pop_at_defect": t2_pop_at_defect,
		"t2_alive_at_defect": t2_alive_at_defect, "t2_final_pop": t2_final_pop,
		"watch_totals": totals, "daily_log": daily_log}
	var out_path: String = "docs/measurements/2026-08-08-scale-econ-deathspiral-seed%d.json" % s
	var f := FileAccess.open("res://" + out_path, FileAccess.WRITE)
	if f != null:
		f.store_string(JSON.stringify(dump, "  ")); f.close()
		print("\n[dump] → res://%s" % out_path)
	print("=== DONE ===")
	quit()

func _total_pop(state: WorldState) -> int:
	var total: int = 0
	for tid in state.teams:
		total += state.teams[tid].population
	return total
