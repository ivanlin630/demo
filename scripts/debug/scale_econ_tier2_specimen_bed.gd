extends SceneTree

# [measurer持久fixture 2026-08-08] 規模經濟力底查 Tier2：3seed+specimen 追 dispersed 死亡(famine)因果鏈。
# ticket:docs/superpowers/handbacks/2026-08-08-systems-to-measurer-tier2-specimen.md
# 目的:①3個不同seed確認concentrated_fair vs dispersed attrition split非單seed運氣
#      ②specimen追Team2(dispersed famine受害隊)因果鏈:lord有無派relief convoy給Team2?
#        convoy是否sell_ownerless/其他bail失敗?Team2死因=no-supply-arrived(convoy斷)
#        還是supply-arrived-still-insufficient/never-attempted(小隊自產不足=genuine labor-survival)?
#        同時解 check(2):convoy bug是不是death driver。
# ③determinism:seed8181 dispersed重跑一次比對聚合數字byte-identical。
# 純觀測:inline SimRunner、state.specimen_team_ids動態追加convoy porter、Probe全量、零code改零額外RNG。

const CONC_CONFIG := "res://config/infonet_scale_econ_concentrated_fair.json"
const DISP_CONFIG := "res://config/infonet_scale_econ_dispersed.json"
const ORIG_TIDS: Array = [0, 1, 2, 3]
const RELIEF_TARGET_TID: int = 2   # DISPERSED SW=Team2，首輪triage確認famine受害隊
var months: int = 3   # env TIER2_MONTHS 可縮短避免慢seed逾工具timeout（famine故事在seed8181驗證day70前已完整浮現）

# ★單run容量限制(工具10分鐘硬蓋)→拆單seed跑,env TIER2_SEED 指定；TIER2_DETERMINISM_ONLY=1 只跑determinism二跑。
func _initialize() -> void:
	var months_env: String = OS.get_environment("TIER2_MONTHS")
	if months_env != "" and months_env.is_valid_int(): months = int(months_env)
	var determinism_only: bool = OS.get_environment("TIER2_DETERMINISM_ONLY") == "1"
	var seed_env: String = OS.get_environment("TIER2_SEED")
	if determinism_only:
		print("=== 規模經濟力底查 Tier2 determinism 二跑(seed8181 dispersed) ===")
		var rd_2: Dictionary = _run("DISPERSED_determinism_check", DISP_CONFIG, 8181, false)
		var out_path: String = "res://docs/measurements/2026-08-08-scale-econ-tier2-determinism-rerun.json"
		var f2 := FileAccess.open(out_path, FileAccess.WRITE)
		if f2 != null:
			f2.store_string(JSON.stringify(rd_2, "  ")); f2.close()
			print("\n[dump] → %s" % out_path)
		print("=== DONE ===")
		quit(); return

	var s: int = int(seed_env) if seed_env != "" else 8181
	print("=== 規模經濟力底查 Tier2 單seed(seed=%d) ===" % s)
	var rc: Dictionary = _run("CONCENTRATED_fair", CONC_CONFIG, s, false)
	var rd: Dictionary = _run("DISPERSED", DISP_CONFIG, s, true)
	print("  seed%d: concentrated attrition=%.1f%% dispersed attrition=%.1f%%" % [
		s, float(rc.get("attrition_pct", 0)), float(rd.get("attrition_pct", 0))])
	print("  relief_dispatched_to_T2=%s relief_outcome=%s T2_famine_days=%d" % [
		str(rd.get("relief_dispatched_to_t2")), str(rd.get("relief_outcome")), int(rd.get("t2_famine_days", 0))])

	var dump: Dictionary = {"seed": s, "concentrated": rc, "dispersed": rd}
	var out_path2: String = "res://docs/measurements/2026-08-08-scale-econ-tier2-seed%d-summary.json" % s
	var f := FileAccess.open(out_path2, FileAccess.WRITE)
	if f != null:
		f.store_string(JSON.stringify(dump, "  ")); f.close()
		print("\n[dump] → %s" % out_path2)
	print("=== DONE ===")
	quit()

func _run(label: String, config_path: String, world_seed: int, trace_t2: bool) -> Dictionary:
	print("\n########## %s seed=%d ##########" % [label, world_seed])
	seed(world_seed)
	FactionAISystem._a2b_remote_tribute_payers.clear()
	Probe.reset(); Probe.enabled = true
	var state := WorldState.new()
	var runner := SimRunner.new()
	var config: Dictionary = GameSetup.load_config(config_path)
	config["seed"] = world_seed
	GameSetup.setup(state, config)
	var no_player := Vector2i(-1, -1)
	var ticks: int = WorldState.TICKS_PER_MONTH * months
	var start_pop: int = _total_pop(state)

	if trace_t2:
		state.specimen_team_ids = [0, 1, 2, 3]
		SpecimenTracer.reset(); SpecimenTracer.enabled = true

	var t2_pop_daily: Array = []
	var t2_famine_days: int = 0
	var t2_last_pop: int = -1
	var relief_dispatched_to_t2: bool = false
	var relief_outcome: String = "never_attempted"
	var seen_convoy_ids: Dictionary = {}

	for tick in range(ticks):
		runner.advance_tick(state, no_player)
		if state.encounter_active and state.encounter_tick > 800:
			runner._encounter_system.resolve_encounter_end(state, "draw")

		if trace_t2 and state.world.current_tick % WorldState.TICKS_PER_DAY == 0:
			# 動態追加 convoy porter 進 specimen（涵蓋 dispatch 後才誕生的子隊，daily cadence 免每tick全隊掃效能負擔）
			for tid in state.teams:
				var t: TeamData = state.teams[tid]
				if t.current_task == TeamData.TASK_CONVOY and not int(tid) in state.specimen_team_ids:
					state.specimen_team_ids.append(int(tid))

			var day: int = state.world.current_tick / WorldState.TICKS_PER_DAY
			if state.teams.has(RELIEF_TARGET_TID):
				var t2: TeamData = state.teams[RELIEF_TARGET_TID]
				var pop: int = t2.population
				t2_pop_daily.append({"day": day, "pop": pop, "food": snappedf(float(t2.resources.get("food", 0)), 0.1), "task": t2.current_task})
				if t2_last_pop != -1 and pop < t2_last_pop: t2_famine_days += 1
				t2_last_pop = pop
				var t2_tile: Vector2i = t2.tile_pos
				# 掃全體 convoy 子隊：market_pos == T2 tile_pos → 這是「派給 T2 的救濟/貿易」
				for tid in state.teams:
					if int(tid) in seen_convoy_ids: continue
					var ct: TeamData = state.teams[tid]
					if ct.current_task != TeamData.TASK_CONVOY: continue
					var mp: Vector2i = ct.task_extra_data.get("market_pos", Vector2i(-1, -1))
					if mp == t2_tile:
						seen_convoy_ids[int(tid)] = true
						relief_dispatched_to_t2 = true

	var end_pop: int = _total_pop(state)
	var bail_keys: Dictionary = {}
	for k in Probe.counts:
		if String(k).begins_with("convoy.deliver_bail_"): bail_keys[k] = int(Probe.counts[k])
	if trace_t2:
		if not relief_dispatched_to_t2:
			relief_outcome = "never_attempted"
		elif int(Probe.counts.get("convoy.deliver_settled", 0)) > 0:
			relief_outcome = "some_settled(見bail細分是否含T2)"
		elif not bail_keys.is_empty():
			relief_outcome = "dispatched_but_bailed(%s)" % str(bail_keys)
		else:
			relief_outcome = "dispatched_but_never_arrived"

	print("final: pop=%d attrition=%.1f%% convoy.dispatch=%d deliver_settled=%d bail=%s" % [
		end_pop, 0.0 if start_pop == 0 else 100.0 * (start_pop - end_pop) / float(start_pop),
		int(Probe.counts.get("convoy.dispatch", 0)), int(Probe.counts.get("convoy.deliver_settled", 0)), str(bail_keys)])
	if trace_t2:
		print("T2: relief_dispatched=%s outcome=%s famine_days=%d pop_daily(last10)=%s" % [
			str(relief_dispatched_to_t2), relief_outcome, t2_famine_days,
			str(t2_pop_daily.slice(max(0, t2_pop_daily.size() - 10)))])
		SpecimenTracer.flush()
		var spec_path: String = "docs/measurements/2026-08-08-scale-econ-tier2-seed%d.specimen.jsonl" % world_seed
		SpecimenDumpHelper.dump(state, spec_path)
		SpecimenTracer.reset()

	Probe.enabled = false
	var out: Dictionary = {
		"seed": world_seed, "start_pop": start_pop, "end_pop": end_pop,
		"attrition_pct": 0.0 if start_pop == 0 else 100.0 * (start_pop - end_pop) / float(start_pop),
		"convoy.dispatch": int(Probe.counts.get("convoy.dispatch", 0)),
		"convoy.deliver": int(Probe.counts.get("convoy.deliver", 0)),
		"convoy.deliver_settled": int(Probe.counts.get("convoy.deliver_settled", 0)),
		"bail_reasons": bail_keys,
		"manufacture.fired": int(Probe.counts.get("manufacture.fired", 0)),
	}
	if trace_t2:
		out["relief_dispatched_to_t2"] = relief_dispatched_to_t2
		out["relief_outcome"] = relief_outcome
		out["t2_famine_days"] = t2_famine_days
		out["t2_pop_daily"] = t2_pop_daily
	return out

func _total_pop(state: WorldState) -> int:
	var total: int = 0
	for tid in state.teams:
		total += state.teams[tid].population
	return total
