extends SceneTree

# [measurer persist fixture 2026-08-06] recovery-path Slice R1 移民三態湧現分化床。
# 工單:2026-08-06-systems-to-measurer-recovery-r1-measure.md
# ex-ante formula驗證(見config._doc):migrant_marginal(pop2,k=3) plains=+0.54(正)/
#   forest=−1.30(負)/mountain=−2.22(負)——完全對齊三態預期,非事後調到剛好。
# 1領主(faction leader,pop15足anon池)+3村(plains/forest/mountain各pop2,own outpost)。

const CONFIG_PATH := "res://config/infonet_recovery_r1_migrant.json"
const SEED: int = 9090
const DAYS: int = 22
const OUT_PATH := "res://docs/measurements/2026-08-06-infonet-recovery-r1-migrant.json"

func _initialize() -> void:
	print("=== recovery-path R1 移民三態湧現分化床（seed=%d %d天）===" % [SEED, DAYS])
	seed(SEED)
	FactionAISystem._a2b_remote_tribute_payers.clear()
	Probe.reset(); Probe.enabled = true
	var state := WorldState.new()
	var runner := SimRunner.new()
	var config: Dictionary = GameSetup.load_config(CONFIG_PATH)
	config["seed"] = SEED
	GameSetup.setup(state, config)
	SpecimenDumpHelper.setup_from_env(state)

	# ★systems fix(2026-08-06-systems-to-measurer-recovery-r1-fixture-fix.md)：no_player=(-1,-1)→
	#   全隊落far LOD bucket→vision只每FAR_ZONE_INTERVAL=100tick跑一次→belief population_est沒機會populate。
	#   量測harness修正(非code改)：傳lord位置當player_pos anchor→lord+3村(距≤3)全落near bucket→快cadence vision。
	var cluster_pos: Vector2i = state.teams[0].tile_pos
	var ticks: int = WorldState.TICKS_PER_DAY * DAYS
	var marginal_samples: Dictionary = {1: [], 2: [], 3: []}   # village_id → [marginal values seen]
	var labels: Dictionary = {1: "plains", 2: "forest", 3: "mountain"}

	for tick in range(ticks):
		runner.advance_tick(state, cluster_pos)

	print("\n───── recovery-r1 摘要(%d天) ─────" % DAYS)
	print("final teams=%d factions=%d" % [state.teams.size(), state.factions.size()])
	for vid in [1, 2, 3]:
		print("  %s(T%d): alive=%s pop=%s faction=%s" % [
			String(labels[vid]), vid, str(state.teams.has(vid)),
			str(state.teams[vid].population if state.teams.has(vid) else "N/A"),
			str(state.teams[vid].faction_id if state.teams.has(vid) else "N/A")])

	print("\n★migrant鏈計數：migrant.dispatched=%d migrant.arrived=%d" % [
		int(Probe.counts.get("migrant.dispatched", 0)), int(Probe.counts.get("migrant.arrived", 0))])
	print("migrant.marginal(peak)=%.4f migrant.mini_util(peak)=%.4f" % [
		float(Probe.peaks.get("migrant.marginal", 0.0)), float(Probe.peaks.get("migrant.mini_util", 0.0))])

	print("\n★per-target migrant.marginal真值(判三態sign):")
	var per_village: Dictionary = {}
	for s in Probe.samples.get("migrant.marginal_sample", []):
		var vid: int = int(s.get("village", -1))
		if not per_village.has(vid): per_village[vid] = []
		(per_village[vid] as Array).append({"terrain": s.get("terrain", ""), "marginal": s.get("marginal", 0.0)})
	for vid in [1, 2, 3]:
		var arr: Array = per_village.get(vid, [])
		print("  %s(T%d): n=%d first=%s" % [String(labels[vid]), vid, arr.size(), str(arr[0] if not arr.is_empty() else {})])
	print("\n★migrant.dispatched_sample(哪村真收到派遣):")
	for s in Probe.samples.get("migrant.dispatched_sample", []):
		print("  target_village=%s marginal=%s" % [str(s.get("target_village", -1)), str(s.get("marginal", 0.0))])

	var dump: Dictionary = {
		"diagnostic": "recovery-path R1 移民三態湧現分化床(ex-ante formula見config._doc)",
		"final": {"teams": state.teams.size(), "factions": state.factions.size()},
		"villages": {
			"1_plains": {"alive": state.teams.has(1), "pop": state.teams[1].population if state.teams.has(1) else null},
			"2_forest": {"alive": state.teams.has(2), "pop": state.teams[2].population if state.teams.has(2) else null},
			"3_mountain": {"alive": state.teams.has(3), "pop": state.teams[3].population if state.teams.has(3) else null},
		},
		"probe": {"migrant.dispatched": Probe.counts.get("migrant.dispatched", 0),
			"migrant.arrived": Probe.counts.get("migrant.arrived", 0),
			"migrant.marginal_peak": Probe.peaks.get("migrant.marginal", 0.0),
			"migrant.mini_util_peak": Probe.peaks.get("migrant.mini_util", 0.0)},
		"per_village_marginal_sample": per_village,
	}
	var f := FileAccess.open(OUT_PATH, FileAccess.WRITE)
	if f != null:
		f.store_string(JSON.stringify(dump, "  ")); f.close()
		print("\n[dump] → %s" % OUT_PATH)
	SpecimenDumpHelper.dump(state, "res://docs/measurements/2026-08-06-infonet-recovery-r1-migrant.specimen.jsonl")
	print("=== DONE ===")
	Probe.enabled = false
	quit()
