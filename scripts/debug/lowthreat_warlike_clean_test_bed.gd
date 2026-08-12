extends SceneTree

# [measurer持久fixture 2026-08-12] 低威脅+好戰對照床(禁預設,硬跑驗兩清sub-case)。
# ticket:docs/superpowers/handbacks/2026-08-12-systems-to-measurer-lowthreat-warlike-clean-test.md
# T0=NORMAL人格lord(好戰0.0/野心0.4,weight_train預期低)測①低威脅一般lord@need>0是否fire→整鏈+終止。
# T2=HIGH好戰/野心warlord(weight_train預期高~0.84)測②人格差異化+train util理論值≈1.17是否決定性贏。
# 純觀測,零production tap,既有Probe key+state直讀,追蹤task/officer_need/tiers/exp/threat_react。

const CONFIG := "res://config/lowthreat_warlike_clean_test.json"
const SEED: int = 8181
const DAYS: int = 30
const T0: int = 0
const T2: int = 2

func _tier_snapshot(t: TeamData) -> Dictionary:
	var d: Dictionary = {}
	for tier in AnonTierSystem.TIER_ORDER:
		d[tier] = AnonTierSystem.tier_count(t, tier)
	return d

func _initialize() -> void:
	print("=== 低威脅+好戰對照床(seed=%d %d天) ===" % [SEED, DAYS])
	seed(SEED)
	FactionAISystem._a2b_remote_tribute_payers.clear()
	Probe.reset(); Probe.enabled = true
	var state := WorldState.new()
	var runner := SimRunner.new()
	var config: Dictionary = GameSetup.load_config(CONFIG)
	config["seed"] = SEED
	GameSetup.setup(state, config)
	var no_player := Vector2i(-1, -1)
	var ticks: int = WorldState.TICKS_PER_DAY * DAYS
	var fai := FactionAISystem.new()

	state.specimen_team_ids = [0, 1, 2, 3]
	SpecimenTracer.reset(); SpecimenTracer.enabled = true

	var watch_keys: Array = ["promote.fired", "promote.field_desperate"]
	var daily_log: Array = []

	print("\nday | T0 task | T0 need | T0 named | T0 tiers | promote累計 || T2 task | T2 need | T2 named | T2 tiers")
	print("----|---------|---------|----------|----------|-------------||---------|---------|----------|----------")

	for tick in range(ticks):
		runner.advance_tick(state, no_player)
		if state.encounter_active and state.encounter_tick > 800:
			runner._encounter_system.resolve_encounter_end(state, "draw")
		if state.world.current_tick % WorldState.TICKS_PER_DAY == 0:
			var day: int = state.world.current_tick / WorldState.TICKS_PER_DAY
			var t0: TeamData = state.teams.get(T0)
			var t2: TeamData = state.teams.get(T2)
			var entry: Dictionary = {"day": day}
			if t0 != null:
				entry["t0_task"] = t0.current_task
				entry["t0_need"] = fai.officer_need(state, t0)
				entry["t0_named"] = t0.named_members.size()
				entry["t0_tiers"] = _tier_snapshot(t0)
			if t2 != null:
				entry["t2_task"] = t2.current_task
				entry["t2_need"] = fai.officer_need(state, t2)
				entry["t2_named"] = t2.named_members.size()
				entry["t2_tiers"] = _tier_snapshot(t2)
			entry["promote_fired_total"] = int(Probe.counts.get("promote.fired", 0))
			entry["promote_desperate_total"] = int(Probe.counts.get("promote.field_desperate", 0))
			daily_log.append(entry)
			print("%3d | %7s | %7.3f | %8d | %s | %11d || %7s | %7.3f | %8d | %s" % [
				day, str(entry.get("t0_task","-")), entry.get("t0_need",-1.0), entry.get("t0_named",-1),
				str(entry.get("t0_tiers",{})), entry["promote_fired_total"],
				str(entry.get("t2_task","-")), entry.get("t2_need",-1.0), entry.get("t2_named",-1),
				str(entry.get("t2_tiers",{}))])

	print("\n───── 終態總結 ─────")
	print("  promote.fired累計=%d promote.field_desperate累計=%d" % [
		int(Probe.counts.get("promote.fired", 0)), int(Probe.counts.get("promote.field_desperate", 0))])
	if state.teams.has(T0):
		print("  T0終態: task=%d need=%.3f named=%d tiers=%s" % [
			state.teams[T0].current_task, fai.officer_need(state, state.teams[T0]),
			state.teams[T0].named_members.size(), str(_tier_snapshot(state.teams[T0]))])
	if state.teams.has(T2):
		print("  T2終態: task=%d need=%.3f named=%d tiers=%s" % [
			state.teams[T2].current_task, fai.officer_need(state, state.teams[T2]),
			state.teams[T2].named_members.size(), str(_tier_snapshot(state.teams[T2]))])

	SpecimenTracer.flush()
	var spec_path: String = "docs/measurements/2026-08-12-lowthreat-warlike-seed%d.specimen.jsonl" % SEED
	SpecimenDumpHelper.dump(state, spec_path)
	SpecimenTracer.reset()
	Probe.enabled = false

	var dump: Dictionary = {"seed": SEED, "days": DAYS, "daily_log": daily_log,
		"promote_fired_total": int(Probe.counts.get("promote.fired", 0)),
		"promote_desperate_total": int(Probe.counts.get("promote.field_desperate", 0))}
	var f := FileAccess.open("res://docs/measurements/2026-08-12-lowthreat-warlike-seed%d.json" % SEED, FileAccess.WRITE)
	if f != null:
		f.store_string(JSON.stringify(dump, "  ")); f.close()
		print("\n[dump] → res://docs/measurements/2026-08-12-lowthreat-warlike-seed%d.json" % SEED)
	print("=== DONE ===")
	quit()
