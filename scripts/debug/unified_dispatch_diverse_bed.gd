extends SceneTree

# [measurer持久fixture 2026-08-11] 統一派遣模型大多樣床(攻上輪3個UNTESTABLE題+O(N²) at scale)。
# ticket:docs/superpowers/handbacks/2026-08-11-systems-to-measurer-diverse-bed.md
# spec:docs/superpowers/specs/2026-08-11-unified-dispatch-diverse-bed-measure-HOW.md
# ★16隊4faction,pop混4/8/12/20,記名數混1/2/3/4(關鍵維度),4隊distress(低食runway)。
# 同bed跑main(before)+branch feat/unified-dispatch(after)兩次,seed8181,直接比對。
# ★命門(4×over-claim血淚):禁預設payoff、硬數字、RNG-confound誠實標、UNTESTABLE照實報。
# ★herald(_try_herald_side)本輪unified-dispatch未觸及(只改scout/care/rescue)、仍用_detach_one_anon
# 抽真anon——distress隊求援若fire,anon池『穩無drain』這題在distress隊身上不該預設仍成立,如實記錄。
# 純觀測,零production tap,既有Probe key+state直讀,dump完整per-team daily供後製分析(composition-pick驗證)。

const CONFIG := "res://config/unified_dispatch_diverse_bed.json"
const SEED: int = 8181
const DAYS: int = 15
const TEAM_IDS: Array[int] = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15]
const DISTRESS_TIDS: Array[int] = [2, 5, 10, 15]

func _initialize() -> void:
	print("=== 統一派遣大多樣床(seed=%d %d天 16隊) ===" % [SEED, DAYS])
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

	state.specimen_team_ids = TEAM_IDS.duplicate()
	SpecimenTracer.reset(); SpecimenTracer.enabled = true

	var watch_keys: Array = ["scout.dispatched", "care.scout_dispatched", "contact.react_rescue",
		"help.letter_dispatched", "help.severity_positive", "help.target_resolved", "help.delivered",
		"manufacture.fired", "manufacture.noop_no_facility", "construct.complete_upgrade_facility",
		"death.starve_anon", "death.starve_minor"]

	var daily_log: Array = []
	var initial_named_count: Dictionary = {}
	for tid in TEAM_IDS:
		if state.teams.has(tid):
			initial_named_count[tid] = state.teams[tid].named_members.size()

	print("\nday | team數 | scout累計 | care累計 | rescue累計 | herald累計(help.letter_dispatched) | manu.fired累計 | construct累計 | starve_anon累計")
	print("----|--------|----------|----------|-----------|-----------------------------------|----------------|---------------|----------------")

	for tick in range(ticks):
		runner.advance_tick(state, no_player)
		if state.encounter_active and state.encounter_tick > 800:
			runner._encounter_system.resolve_encounter_end(state, "draw")
		if state.world.current_tick % WorldState.TICKS_PER_DAY == 0:
			var day: int = state.world.current_tick / WorldState.TICKS_PER_DAY
			var counts_now: Dictionary = {}
			for k in watch_keys: counts_now[k] = int(Probe.counts.get(k, 0))

			var per_team: Dictionary = {}
			for tid in TEAM_IDS:
				if not state.teams.has(tid):
					per_team[str(tid)] = {"alive": false}
					continue
				var t: TeamData = state.teams[tid]
				var cmds: Array = []
				for nid in t.named_members:
					var p = state.persons.get(nid)
					if p != null: cmds.append(float(p.skills.get("統領", 0.0)))
				per_team[str(tid)] = {"alive": true, "anon": AnonTierSystem.total_pop(t),
					"named_size": t.named_members.size(), "named_cmds": cmds, "pop": t.population,
					"food_eff": ResourceSystem.effective_food(state, t)}
			daily_log.append({"day": day, "team_count": state.teams.size(), "counts": counts_now, "per_team": per_team})
			print("%3d | %6d | %8d | %8d | %9d | %35d | %14d | %13d | %14d" % [
				day, state.teams.size(), counts_now["scout.dispatched"], counts_now["care.scout_dispatched"],
				counts_now["contact.react_rescue"], counts_now["help.letter_dispatched"],
				counts_now["manufacture.fired"], counts_now["construct.complete_upgrade_facility"],
				counts_now["death.starve_anon"]])

	var facility_log: Dictionary = {}
	for tid in TEAM_IDS:
		if not state.teams.has(tid): continue
		var t: TeamData = state.teams[tid]
		var tile: HexTileData = state.world.tiles.get(t.tile_pos.x * 1000 + t.tile_pos.y)
		if tile != null:
			facility_log["team%d" % tid] = {"outpost_level": tile.outpost_level, "manufacturing_level": tile.manufacturing_level}

	print("\n───── 終態總結 ─────")
	print("  team數: 起始16 → 終end=%d" % state.teams.size())
	for k in watch_keys:
		print("  %s 累計=%d" % [k, int(Probe.counts.get(k, 0))])
	print("  facility終態: %s" % str(facility_log))
	print("  initial_named_count: %s" % str(initial_named_count))

	SpecimenTracer.flush()
	var spec_path: String = "docs/measurements/2026-08-11-unified-dispatch-diverse-seed%d.specimen.jsonl" % SEED
	SpecimenDumpHelper.dump(state, spec_path)
	SpecimenTracer.reset()
	Probe.enabled = false

	var totals: Dictionary = {}
	for k in watch_keys: totals[k] = int(Probe.counts.get(k, 0))
	var dump: Dictionary = {"seed": SEED, "days": DAYS, "daily_log": daily_log,
		"final_team_count": state.teams.size(), "facility_log": facility_log,
		"initial_named_count": initial_named_count, "distress_tids": DISTRESS_TIDS, "totals": totals}
	var f := FileAccess.open("res://docs/measurements/2026-08-11-unified-dispatch-diverse-seed%d.json" % SEED, FileAccess.WRITE)
	if f != null:
		f.store_string(JSON.stringify(dump, "  ")); f.close()
		print("\n[dump] → res://docs/measurements/2026-08-11-unified-dispatch-diverse-seed%d.json" % SEED)
	print("=== DONE ===")
	quit()
