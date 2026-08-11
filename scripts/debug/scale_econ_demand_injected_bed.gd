extends SceneTree

# [measurer持久fixture 2026-08-11] demand-injected measure probe(用戶拍A,size-production conditional)。
# ticket:docs/superpowers/handbacks/2026-08-11-systems-to-measurer-demand-injected-probe.md
# ★probe非shipped機制:test-only harness每cadence注入synthetic製造品買單(goods/tools)進核心村team_known
# (感知鐵律-honest:格式逐項比照order_system.gd:249真實order_buy message,只是origin_team=外部虛擬買家id,
# 非呼叫任何production下單函式,純state append)——解no_facility precondition,答『若製造真happen,
# concentration vs dispersion有無genuine長期生產優勢』。
# 拆單scenario跑(env RM_SEED/RM_SCENARIO)避timeout,4mo(established安全窗)。附specimen送QA。

const CONC_CONFIG := "res://config/infonet_scale_econ_concentrated_fair.json"
const DISP_CONFIG := "res://config/infonet_scale_econ_dispersed.json"
const MONTHS: int = 4
const ORIG_TIDS: Array = [0, 1, 2, 3]
const INJECT_RES: Array = ["goods", "tools", "weapon_melee_low"]
const INJECT_QTY: float = 30.0
const FAKE_BUYER_ID: int = -2   # 虛擬外部買家(非任何真team_id,純demand來源,非我自己真下單)

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
	print("=== demand-injected probe(seed=%d %d月 scenario=%s) ===" % [s, MONTHS, label])

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

	var order_id_counter: int = 900000000   # 避撞真order_id(同session慣例base offset)
	var monthly_log: Array = []

	for tick in range(ticks):
		runner.advance_tick(state, no_player)
		if state.encounter_active and state.encounter_tick > 800:
			runner._encounter_system.resolve_encounter_end(state, "draw")
		# ★demand注入:每日對每個原始核心村team(0-3,存在者)注入synthetic order_buy(感知鐵律-honest格式)
		if state.world.current_tick % WorldState.TICKS_PER_DAY == 0:
			for tid in ORIG_TIDS:
				if not state.teams.has(tid): continue
				var t: TeamData = state.teams[tid]
				for res in INJECT_RES:
					var msg := MessageData.new()
					msg.id = state.global_messages.size()
					msg.type = "order_buy"
					msg.description = "[DemandProbe-inject] 外部買家 %s ×%.0f" % [res, INJECT_QTY]
					msg.source_pos = t.tile_pos
					msg.origin_team_id = FAKE_BUYER_ID
					msg.origin_tick = state.world.current_tick
					msg.strength = 1.0
					msg.is_distorted = false
					order_id_counter += 1
					msg.params = {"order_id": order_id_counter, "res": res, "qty": int(INJECT_QTY),
						"origin_team": FAKE_BUYER_ID, "origin_pos": t.tile_pos,
						"expire_tick": state.world.current_tick + WorldState.TICKS_PER_MONTH}
					state.global_messages.append(msg)
					if not state.team_known.has(tid): state.team_known[tid] = []
					state.team_known[tid].append(msg)
			for tid in state.teams:
				var t: TeamData = state.teams[tid]
				if (t.current_task == TeamData.TASK_SCOUT or t.current_task == TeamData.TASK_CONVOY) and not int(tid) in state.specimen_team_ids:
					state.specimen_team_ids.append(int(tid))
		if state.world.current_tick % WorldState.TICKS_PER_MONTH == 0:
			var month: int = state.world.current_tick / WorldState.TICKS_PER_MONTH
			var entry: Dictionary = {"month": month, "pop_core": _core_pop(state)}
			if state.teams.has(0):
				var tile: HexTileData = state.world.tiles.get(state.teams[0].tile_pos.x * 1000 + state.teams[0].tile_pos.y)
				if tile != null:
					entry["labor_pool"] = LaborSystem.pool_of(state, tile)
					entry["outpost_level"] = tile.outpost_level
					entry["manufacturing_level"] = tile.manufacturing_level
			entry["manufacture_fired_total"] = int(Probe.counts.get("manufacture.fired", 0))
			entry["noop_no_facility_total"] = int(Probe.counts.get("manufacture.noop_no_facility", 0))
			entry["construct_upgrade_total"] = int(Probe.counts.get("construct.complete_upgrade_facility", 0))
			monthly_log.append(entry)
			print("  month%d: %s" % [month, str(entry)])

	var end_pop: int = _total_pop(state)
	var core_pop: int = _core_pop(state)
	var manufacture_output: Dictionary = {}
	for k in Probe.amounts:
		if String(k).begins_with("manufacture.output."):
			manufacture_output[k] = Probe.amounts[k]
	var manufacture_noop: Dictionary = {
		"noop_no_outpost": int(Probe.counts.get("manufacture.noop_no_outpost", 0)),
		"noop_no_worker": int(Probe.counts.get("manufacture.noop_no_worker", 0)),
		"noop_no_facility": int(Probe.counts.get("manufacture.noop_no_facility", 0)),
		"noop_no_material": int(Probe.counts.get("manufacture.noop_no_material", 0)),
	}

	print("\n───── demand注入後生產淨值帳總結 ─────")
	print("  end_pop(全)=%d end_pop(核心)=%d" % [end_pop, core_pop])
	print("  ★manufacture.fired=%d(注入前=0) manufacture.output=%s" % [int(Probe.counts.get("manufacture.fired", 0)), str(manufacture_output)])
	print("  manufacture_noop=%s" % str(manufacture_noop))
	print("  construct.complete_upgrade_facility=%d convoy.deliver_settled=%d" % [
		int(Probe.counts.get("construct.complete_upgrade_facility", 0)), int(Probe.counts.get("convoy.deliver_settled", 0))])

	SpecimenTracer.flush()
	var spec_path: String = "docs/measurements/2026-08-11-scale-econ-demand-injected-seed%d-%s.specimen.jsonl" % [s, label]
	SpecimenDumpHelper.dump(state, spec_path)
	SpecimenTracer.reset()
	Probe.enabled = false

	var dump: Dictionary = {"seed": s, "months": MONTHS, "scenario": label,
		"start_pop": start_pop, "end_pop": end_pop, "core_pop": core_pop,
		"monthly_log": monthly_log, "manufacture_output": manufacture_output, "manufacture_noop": manufacture_noop,
		"manufacture_fired_total": int(Probe.counts.get("manufacture.fired", 0)),
		"construct_upgrade_total": int(Probe.counts.get("construct.complete_upgrade_facility", 0)),
		"convoy_deliver_settled_total": int(Probe.counts.get("convoy.deliver_settled", 0))}
	var f := FileAccess.open("res://docs/measurements/2026-08-11-scale-econ-demand-injected-seed%d-%s.json" % [s, label], FileAccess.WRITE)
	if f != null:
		f.store_string(JSON.stringify(dump, "  ")); f.close()
		print("\n[dump] → res://docs/measurements/2026-08-11-scale-econ-demand-injected-seed%d-%s.json" % [s, label])
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
