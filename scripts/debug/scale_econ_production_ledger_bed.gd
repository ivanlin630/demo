extends SceneTree

# [measurer持久fixture 2026-08-11] re-measure scale v2:核心村生產淨值帳長期(size長期生產優勢?非attrition)。
# ticket:docs/superpowers/handbacks/2026-08-11-systems-to-measurer-remeasure-v2-production.md
# ★核心村focus(濾spinoff單人隊噪)+spinoff率對稱control+relief殘餘confound分清。
# 拆單scenario跑(env RM_SEED/RM_SCENARIO)避10分鐘工具timeout。附specimen送QA。

const CONC_CONFIG := "res://config/infonet_scale_econ_concentrated_fair.json"
const DISP_CONFIG := "res://config/infonet_scale_econ_dispersed.json"
const MONTHS: int = 4   # ★6mo跑到超過工具10分鐘硬蓋(timeout),縮到4mo(比3mo established安全窗再長一點,兼顧"更長窗"要求)
const ORIG_TIDS: Array = [0, 1, 2, 3]

func _initialize() -> void:
	var seed_env: String = OS.get_environment("RM_SEED")
	var s: int = int(seed_env) if seed_env != "" else 8181
	var scenario: String = OS.get_environment("RM_SCENARIO")
	var label: String
	var config_path: String
	if scenario == "concentrated":
		label = "CONCENTRATED_fair"; config_path = CONC_CONFIG
	else:
		label = "DISPERSED"; config_path = DISP_CONFIG
	print("=== re-measure scale v2 生產淨值帳(seed=%d %d月 scenario=%s) ===" % [s, MONTHS, label])

	seed(s)
	FactionAISystem._a2b_remote_tribute_payers.clear()
	Probe.reset(); Probe.enabled = true
	var state := WorldState.new()
	var runner := SimRunner.new()
	var config: Dictionary = GameSetup.load_config(config_path)
	config["seed"] = s
	GameSetup.setup(state, config)
	var no_player := Vector2i(-1, -1)
	var ticks: int = WorldState.TICKS_PER_MONTH * MONTHS
	var start_pop: int = _total_pop(state)

	state.specimen_team_ids = [0, 1, 2, 3]
	SpecimenTracer.reset(); SpecimenTracer.enabled = true

	var monthly_log: Array = []
	var succession_count: int = 0   # spinoff 生成率（[Succession] print 本身無 Probe tap，改由已知機制直接偵測新 team_id 出現)
	var seen_tids: Dictionary = {}
	for tid in state.teams: seen_tids[tid] = true
	var extinct_count: int = 0

	for tick in range(ticks):
		var pre_tids: Dictionary = {}
		if tick == 0:
			for tid in state.teams: pre_tids[tid] = true
		runner.advance_tick(state, no_player)
		if state.encounter_active and state.encounter_tick > 800:
			runner._encounter_system.resolve_encounter_end(state, "draw")
		for tid in state.teams:
			if not seen_tids.has(tid):
				seen_tids[tid] = true
				if not (tid in ORIG_TIDS):
					succession_count += 1   # 新增非原始4隊 team_id = spinoff/promoted 生成
		if state.world.current_tick % WorldState.TICKS_PER_DAY == 0:
			for tid in state.teams:
				var t: TeamData = state.teams[tid]
				if (t.current_task == TeamData.TASK_SCOUT or t.current_task == TeamData.TASK_CONVOY) and not int(tid) in state.specimen_team_ids:
					state.specimen_team_ids.append(int(tid))
		if state.world.current_tick % WorldState.TICKS_PER_MONTH == 0:
			var month: int = state.world.current_tick / WorldState.TICKS_PER_MONTH
			var entry: Dictionary = {"month": month, "pop_total": _total_pop(state), "pop_core": _core_pop(state)}
			if state.teams.has(0):
				var tile: HexTileData = state.world.tiles.get(state.teams[0].tile_pos.x * 1000 + state.teams[0].tile_pos.y)
				if tile != null:
					entry["labor_pool"] = LaborSystem.pool_of(state, tile)
					entry["outpost_level"] = tile.outpost_level
					entry["labor_mult_gather_food"] = LaborSystem.labor_mult(tile, "gather:food")
			entry["manufacture_fired_total"] = int(Probe.counts.get("manufacture.fired", 0))
			entry["construct_upgrade_total"] = int(Probe.counts.get("construct.complete_upgrade_facility", 0))
			entry["convoy_deliver_settled_total"] = int(Probe.counts.get("convoy.deliver_settled", 0))
			monthly_log.append(entry)
			print("  month%d: %s" % [month, str(entry)])

	var end_pop: int = _total_pop(state)
	var core_pop: int = _core_pop(state)
	var manufacture_output: Dictionary = {}
	for k in Probe.amounts:
		if String(k).begins_with("manufacture.output."):
			manufacture_output[k] = Probe.amounts[k]
	# ★systems ticket:manufacture noop 主因(既有tap純讀,零新production改動)
	var manufacture_noop: Dictionary = {
		"noop_no_outpost": int(Probe.counts.get("manufacture.noop_no_outpost", 0)),
		"noop_no_worker": int(Probe.counts.get("manufacture.noop_no_worker", 0)),
		"noop_no_facility": int(Probe.counts.get("manufacture.noop_no_facility", 0)),
		"noop_no_material": int(Probe.counts.get("manufacture.noop_no_material", 0)),
	}
	print("  ★manufacture noop breakdown: %s" % str(manufacture_noop))

	print("\n───── 生產淨值帳總結 ─────")
	print("  end_pop(全)=%d end_pop(核心0-3)=%d" % [end_pop, core_pop])
	print("  manufacture.fired=%d manufacture.output=%s" % [int(Probe.counts.get("manufacture.fired", 0)), str(manufacture_output)])
	print("  construct.complete_upgrade_facility=%d convoy.deliver_settled=%d" % [
		int(Probe.counts.get("construct.complete_upgrade_facility", 0)), int(Probe.counts.get("convoy.deliver_settled", 0))])
	print("  spinoff生成數(非原始4隊新team_id)=%d" % succession_count)

	SpecimenTracer.flush()
	var spec_path: String = "docs/measurements/2026-08-11-scale-econ-production-ledger-seed%d-%s.specimen.jsonl" % [s, label]
	SpecimenDumpHelper.dump(state, spec_path)
	SpecimenTracer.reset()
	Probe.enabled = false

	var dump: Dictionary = {"seed": s, "months": MONTHS, "scenario": label,
		"start_pop": start_pop, "end_pop": end_pop, "core_pop": core_pop,
		"monthly_log": monthly_log, "manufacture_output": manufacture_output,
		"manufacture_fired_total": int(Probe.counts.get("manufacture.fired", 0)),
		"construct_upgrade_total": int(Probe.counts.get("construct.complete_upgrade_facility", 0)),
		"convoy_deliver_settled_total": int(Probe.counts.get("convoy.deliver_settled", 0)),
		"manufacture_noop": manufacture_noop,
		"spinoff_creation_count": succession_count}
	var f := FileAccess.open("res://docs/measurements/2026-08-11-scale-econ-production-ledger-seed%d-%s.json" % [s, label], FileAccess.WRITE)
	if f != null:
		f.store_string(JSON.stringify(dump, "  ")); f.close()
		print("\n[dump] → res://docs/measurements/2026-08-11-scale-econ-production-ledger-seed%d-%s.json" % [s, label])
	print("=== DONE ===")
	quit()

func _total_pop(state: WorldState) -> int:
	var total: int = 0
	for tid in state.teams: total += state.teams[tid].population
	return total

func _core_pop(state: WorldState) -> int:
	var total: int = 0
	for tid in ORIG_TIDS:
		if state.teams.has(tid): total += state.teams[tid].population
	return total
