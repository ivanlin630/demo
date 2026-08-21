extends SceneTree
# gate1/2/7 量測床：生育是否從「結構性零」變成有；名額是否 per-capita（大村不得壟斷）；三個 tap 是否有值。
# ★新生兒是 anon minor，不是 named ⇒ 看 pop_total / minor_population / breed.born，不是 n_persons。
# env：PERF_SEED(1337)、ADHOC_DAYS(90)、LW_CONFIG(peaceful_economy)、PERF_OUT

func _initialize() -> void:
	_run(); quit()

func _run() -> void:
	var cfg: String = OS.get_environment("LW_CONFIG") if OS.get_environment("LW_CONFIG") != "" else "peaceful_economy"
	var days: int = int(OS.get_environment("ADHOC_DAYS")) if OS.get_environment("ADHOC_DAYS") != "" else 90
	var sd: int = int(OS.get_environment("PERF_SEED")) if OS.get_environment("PERF_SEED") != "" else 1337
	var out_path: String = OS.get_environment("PERF_OUT")
	print("=== breed-anon 量測：config=%s days=%d seed=%d ===" % [cfg, days, sd])
	seed(sd)
	Probe.enabled = true; Probe.reset()
	FactionAISystem._a2b_remote_tribute_payers.clear()
	var state := WorldState.new()
	var runner := SimRunner.new()
	var config: Dictionary = GameSetup.load_config("res://config/%s.json" % cfg)
	if config.is_empty(): print("[FAIL] config"); return
	config["seed"] = sd
	GameSetup.setup(state, config)
	var pop0: int = _pop_total(state)
	var no_player := Vector2i(-1, -1)
	for tick in range(days * WorldState.TICKS_PER_DAY):
		runner.advance_tick(state, no_player)
		if state.encounter_active and state.encounter_tick > 800:
			runner._encounter_system.resolve_encounter_end(state, "draw")
		if state.teams.is_empty(): break
	var lines: Array = []
	lines.append("[%s day %d seed %d] teams=%d" % [cfg, days, sd, state.teams.size()])
	lines.append("  pop_total %d → %d｜named %d｜minors %d" % [
		pop0, _pop_total(state), state.persons.size(), _minors(state)])
	for k in ["breed.born", "breed.eligible_named", "breed.eligible_anon"]:
		lines.append("  %-24s = %d" % [k, int(Probe.counts.get(k, 0))])
	if Probe.peaks.has("breed.safety_proxy"):
		lines.append("  breed.safety_proxy(peak) = %.3f" % float(Probe.peaks["breed.safety_proxy"]))
	# gate2：名額分佈（大村不得壟斷）——per-team minors 對 pop
	var rows: Array = []
	for tid in state.teams:
		var t: TeamData = state.teams[tid]
		if t.beast_kind != "" or t.parent_team_id != -1: continue
		if t.minor_population > 0 or t.population >= 2:
			rows.append("    team=%d pop=%d minors=%d progress=%.2f" % [
				t.team_id, t.population, t.minor_population, t.breed_progress])
	lines.append("  ★per-team 名額（gate2 看有沒有壟斷）：")
	for r in rows: lines.append(r)
	var text: String = "\n".join(PackedStringArray(lines))
	print("\n" + text)
	if out_path != "":
		var f := FileAccess.open(out_path, FileAccess.WRITE)
		if f != null: f.store_string(text + "\n"); f.close()
	Probe.enabled = false

func _pop_total(state: WorldState) -> int:
	var n: int = 0
	for tid in state.teams: n += (state.teams[tid] as TeamData).population
	return n

func _minors(state: WorldState) -> int:
	var n: int = 0
	for tid in state.teams: n += (state.teams[tid] as TeamData).minor_population
	return n
