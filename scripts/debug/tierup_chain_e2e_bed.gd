extends SceneTree

# [measurer持久fixture 2026-08-12] anon tier-up→主動提拔鏈端到端(禁憑grep/code-read斷言,硬跑驗)。
# ticket:docs/superpowers/handbacks/2026-08-12-systems-to-measurer-tierup-chain-e2e.md
# T0=FORCE-archetype lord(好戰0.8/野心0.7/義氣0.1→derive_archetype應='武力',戰術0.6給訓練速率,
# 只1記名named-scarcity demand>0)——測鏈連:TASK_TRAIN fire→exp累積→try_promote平民升新兵→
# quality過0.3→_try_promote_advisor真fire?
# T2=non-FORCE lord(野心0.4慎重0.6,同T12複製,戰術=0預設)——測breakpoint②:即使named-scarce
# (只1記名)也不會train(archetype-gated非scarcity-connected)控制組。
# 純觀測,零production tap(除promote.util_dist既有tap模式重用),既有Probe key+state直讀。

const CONFIG := "res://config/tierup_chain_e2e_bed.json"
const SEED: int = 8181
const DAYS: int = 20
const T0: int = 0
const T2: int = 2

func _tier_snapshot(t: TeamData) -> Dictionary:
	var d: Dictionary = {}
	for tier in AnonTierSystem.TIER_ORDER:
		d[tier] = AnonTierSystem.tier_count(t, tier)
	return d

func _initialize() -> void:
	print("=== anon tier-up→主動提拔鏈端到端(seed=%d %d天) ===" % [SEED, DAYS])
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

	state.specimen_team_ids = [0, 1, 2, 3]
	SpecimenTracer.reset(); SpecimenTracer.enabled = true

	var watch_keys: Array = ["promote.fired"]
	var daily_log: Array = []

	print("\nday | T0 task | T0 archetype | T0 tiers | T0 exp(平民) | T0 named | T0 promote.fired累計 | T2 task | T2 archetype | T2 tiers | T2 named")
	print("----|---------|-------------|----------|-------------|----------|----------------------|---------|-------------|----------|----------")

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
				entry["t0_archetype"] = t0.ambition_archetype
				entry["t0_tiers"] = _tier_snapshot(t0)
				entry["t0_exp_peasant"] = float(t0.anon_exp.get("平民", 0.0))
				entry["t0_named"] = t0.named_members.size()
			if t2 != null:
				entry["t2_task"] = t2.current_task
				entry["t2_archetype"] = t2.ambition_archetype
				entry["t2_tiers"] = _tier_snapshot(t2)
				entry["t2_named"] = t2.named_members.size()
			entry["promote_fired_total"] = int(Probe.counts.get("promote.fired", 0))
			daily_log.append(entry)
			print("%3d | %7s | %11s | %s | %11.1f | %8d | %20d | %7s | %11s | %s | %8d" % [
				day, str(entry.get("t0_task","-")), str(entry.get("t0_archetype","-")), str(entry.get("t0_tiers",{})),
				entry.get("t0_exp_peasant", -1.0), entry.get("t0_named", -1), entry["promote_fired_total"],
				str(entry.get("t2_task","-")), str(entry.get("t2_archetype","-")), str(entry.get("t2_tiers",{})), entry.get("t2_named", -1)])

	print("\n───── 終態總結 ─────")
	print("  promote.fired累計=%d" % int(Probe.counts.get("promote.fired", 0)))
	if state.teams.has(T0):
		print("  T0終態: task=%d archetype=%s tiers=%s named=%d exp平民=%.1f" % [
			state.teams[T0].current_task, state.teams[T0].ambition_archetype,
			str(_tier_snapshot(state.teams[T0])), state.teams[T0].named_members.size(),
			float(state.teams[T0].anon_exp.get("平民", 0.0))])
	if state.teams.has(T2):
		print("  T2終態: task=%d archetype=%s tiers=%s named=%d" % [
			state.teams[T2].current_task, state.teams[T2].ambition_archetype,
			str(_tier_snapshot(state.teams[T2])), state.teams[T2].named_members.size()])

	SpecimenTracer.flush()
	var spec_path: String = "docs/measurements/2026-08-12-tierup-chain-e2e-seed%d.specimen.jsonl" % SEED
	SpecimenDumpHelper.dump(state, spec_path)
	SpecimenTracer.reset()
	Probe.enabled = false

	var dump: Dictionary = {"seed": SEED, "days": DAYS, "daily_log": daily_log,
		"promote_fired_total": int(Probe.counts.get("promote.fired", 0))}
	var f := FileAccess.open("res://docs/measurements/2026-08-12-tierup-chain-e2e-seed%d.json" % SEED, FileAccess.WRITE)
	if f != null:
		f.store_string(JSON.stringify(dump, "  ")); f.close()
		print("\n[dump] → res://docs/measurements/2026-08-12-tierup-chain-e2e-seed%d.json" % SEED)
	print("=== DONE ===")
	quit()
