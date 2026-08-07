extends SceneTree

# [measurer持久fixture 2026-08-07] convoy bail-reason triage(systems dispatch 2026-08-07 convoy-bail-triage)。
# 目的:定 DISPERSED convoy.deliver_settled=0(cargo_out88.4/delivered0)是bug還是genuine分散摩擦。
# 純觀測:inline SimRunner(同 convoy_t1_diag_bed pattern)、讀 Probe.counts/samples 全量(不經 WarringHarness 固定 key 子集,
# 因 convoy.deliver_bail_<reason> 是動態 suffix key、convoy.deliver_traj 不在 WarringHarness CONSTRUCT_SAMPLE_KEYS 白名單)。
# 零 code 改、零額外 RNG 消耗(只讀)。
# spec:docs/superpowers/specs/2026-08-07-scale-economy-baseline-measure-HOW.md
# ticket:docs/superpowers/handbacks/2026-08-07-systems-to-measurer-convoy-bail-triage.md

const SEED: int = 8181
const MONTHS: int = 3
const DISPERSED_CONFIG := "res://config/infonet_scale_econ_dispersed.json"
const OUT_PATH := "res://docs/measurements/2026-08-07-scale-econ-convoy-bail-triage.json"

func _initialize() -> void:
	print("=== DISPERSED convoy bail-reason triage(seed=%d %d月) ===" % [SEED, MONTHS])
	seed(SEED)
	FactionAISystem._a2b_remote_tribute_payers.clear()
	Probe.reset(); Probe.enabled = true
	var state := WorldState.new()
	var runner := SimRunner.new()
	var config: Dictionary = GameSetup.load_config(DISPERSED_CONFIG)
	config["seed"] = SEED
	GameSetup.setup(state, config)
	var no_player := Vector2i(-1, -1)
	var ticks: int = WorldState.TICKS_PER_MONTH * MONTHS

	var pop_daily: Array = []
	var start_pop: int = _total_pop(state)

	for tick in range(ticks):
		runner.advance_tick(state, no_player)
		if state.encounter_active and state.encounter_tick > 800:
			runner._encounter_system.resolve_encounter_end(state, "draw")
		if state.world.current_tick % WorldState.TICKS_PER_DAY == 0:
			pop_daily.append({"day": state.world.current_tick / WorldState.TICKS_PER_DAY, "pop": _total_pop(state)})
		if state.teams.is_empty(): break

	var end_pop: int = _total_pop(state)

	print("\n───── pop: start=%d end=%d attrition=%.1f%% ─────" % [
		start_pop, end_pop, 0.0 if start_pop == 0 else 100.0 * (start_pop - end_pop) / float(start_pop)])

	print("\n───── convoy deliver-attempt outcome ─────")
	print("  convoy.dispatch=%d convoy.deliver(arrive)=%d convoy.deliver_settled=%d" % [
		int(Probe.counts.get("convoy.dispatch", 0)), int(Probe.counts.get("convoy.deliver", 0)),
		int(Probe.counts.get("convoy.deliver_settled", 0))])
	var bail_keys: Array = []
	for k in Probe.counts:
		if String(k).begins_with("convoy.deliver_bail_"): bail_keys.append(k)
	bail_keys.sort()
	if bail_keys.is_empty():
		print("  (無 convoy.deliver_bail_* key —— deliver 嘗試可能連 arrive 都沒到，非 bail 分因範圍)")
	for k in bail_keys:
		print("  %s=%d" % [k, int(Probe.counts[k])])

	print("\n───── convoy.deliver_traj sample(每趟 porter/res/loaded/material_at_deliver/sold/result/bail_delta) ─────")
	var traj: Array = Probe.samples.get("convoy.deliver_traj", [])
	for s in traj:
		print("  %s" % str(s))
	if traj.is_empty():
		print("  (空 —— 連一趟 deliver 事件都沒發生過，代表 dispatch 後從未抵達 market 觸發 _resolve_market_at_outpost)")

	print("\n───── pop 逐日(對 convoy fail timing 相關性 hint，非因果判定) ─────")
	for e in pop_daily:
		print("  day%d pop=%d" % [int(e["day"]), int(e["pop"])])

	var dump: Dictionary = {
		"diagnostic": "DISPERSED convoy deliver=0 bail-reason triage",
		"start_pop": start_pop, "end_pop": end_pop,
		"convoy_dispatch": int(Probe.counts.get("convoy.dispatch", 0)),
		"convoy_deliver_arrive": int(Probe.counts.get("convoy.deliver", 0)),
		"convoy_deliver_settled": int(Probe.counts.get("convoy.deliver_settled", 0)),
		"bail_reasons": (func():
			var d := {}
			for k in bail_keys: d[k] = int(Probe.counts[k])
			return d).call(),
		"deliver_traj": traj,
		"pop_daily": pop_daily,
	}
	var f := FileAccess.open(OUT_PATH, FileAccess.WRITE)
	if f != null:
		f.store_string(JSON.stringify(dump, "  ")); f.close()
		print("\n[dump] → %s" % OUT_PATH)
	print("=== DONE ===")
	quit()

func _total_pop(state: WorldState) -> int:
	var total: int = 0
	for tid in state.teams:
		total += state.teams[tid].population
	return total
