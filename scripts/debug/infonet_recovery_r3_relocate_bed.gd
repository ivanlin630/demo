extends SceneTree

# [measurer persist fixture 2026-08-06] recovery-path Slice R3 遷村令測床(復甦arc收官)。
# 工單:2026-08-06-systems-to-measurer-recovery-r3-measure.md
# 沿用recovery_r3_test.gd驗證過參數(lord pop16/village pop5/distance=2,比R2教訓更保守)。
# anchor=lord自身tile_pos(同r3_test手法)。3組獨立faction pair:
#   pairA=mountain忠村(obey=1.25從令)/pairB=mountain傲村(obey=-0.85抗命)/pairC=plains盈餘村(不該收令)。

const CONFIG_PATH := "res://config/infonet_recovery_r3_relocate.json"
const SEED: int = 6262
const DAYS: int = 10
const OUT_PATH := "res://docs/measurements/2026-08-06-infonet-recovery-r3-relocate.json"

func _initialize() -> void:
	var anchor_lord: int = int(OS.get_environment("ANCHOR_LORD")) if OS.get_environment("ANCHOR_LORD") != "" else 0
	print("=== recovery-path R3 遷村令測床（seed=%d %d天, ANCHOR_LORD=%d）===" % [SEED, DAYS, anchor_lord])
	seed(SEED)
	FactionAISystem._a2b_remote_tribute_payers.clear()
	Probe.reset(); Probe.enabled = true
	var state := WorldState.new()
	var runner := SimRunner.new()
	var config: Dictionary = GameSetup.load_config(CONFIG_PATH)
	config["seed"] = SEED
	GameSetup.setup(state, config)
	SpecimenDumpHelper.setup_from_env(state)

	var cluster_pos: Vector2i = state.teams[anchor_lord].tile_pos
	var ticks: int = WorldState.TICKS_PER_DAY * DAYS
	var labels: Dictionary = {0: "LordA", 1: "VillageA_Mtn_Compliant", 2: "LordB",
		3: "VillageB_Mtn_Resistant", 4: "LordC", 5: "VillageC_Plains_Surplus"}

	for tick in range(ticks):
		runner.advance_tick(state, cluster_pos)

	print("\n───── recovery-r3 摘要(%d天, anchor=%s) ─────" % [DAYS, String(labels[anchor_lord])])
	print("final teams=%d factions=%d" % [state.teams.size(), state.factions.size()])
	for vid in [0, 1, 2, 3, 4, 5]:
		if state.teams.has(vid):
			var t: TeamData = state.teams[vid]
			var tile: HexTileData = state.world.tiles.get(t.tile_pos.x * 1000 + t.tile_pos.y)
			print("  %s(T%d): alive=true pop=%d faction=%d tile_pos=%s terrain=%s unrest=%d" % [
				String(labels[vid]), vid, t.population, t.faction_id, str(t.tile_pos),
				str(tile.terrain) if tile else "N/A", t.unrest_turns])
		else:
			print("  %s(T%d): DEAD/滅團" % [String(labels[vid]), vid])

	print("\n★relocate鏈計數：relocate.ordered=%d relocate.delivered=%d relocate.comply=%d relocate.resist=%d relocate.unrest_added=%d" % [
		int(Probe.counts.get("relocate.ordered", 0)), int(Probe.counts.get("relocate.delivered", 0)),
		int(Probe.counts.get("relocate.comply", 0)), int(Probe.counts.get("relocate.resist", 0)),
		int(Probe.counts.get("relocate.unrest_added", 0))])
	print("relocate.started=%d relocate.abandoned=%d relocate.arrived=%d relocate.resettled=%d" % [
		int(Probe.counts.get("relocate.started", 0)), int(Probe.counts.get("relocate.abandoned", 0)),
		int(Probe.counts.get("relocate.arrived", 0)), int(Probe.counts.get("relocate.resettled", 0))])
	print("relocate.value(peak)=%.4f" % float(Probe.peaks.get("relocate.value", 0.0)))

	print("\n★per-target relocate.value真值:")
	var per_village: Dictionary = {}
	for s in Probe.samples.get("relocate.value_sample", []):
		var vid: int = int(s.get("village", -1))
		if not per_village.has(vid): per_village[vid] = []
		(per_village[vid] as Array).append({"terrain": s.get("terrain", ""), "value": s.get("value", 0.0)})
	for vid in [1, 3, 5]:
		var arr: Array = per_village.get(vid, [])
		print("  %s(T%d): n=%d first=%s" % [String(labels[vid]), vid, arr.size(), str(arr[0] if not arr.is_empty() else {})])

	var dump: Dictionary = {
		"diagnostic": "recovery-path R3 遷村令測床(ex-ante formula見config._doc), anchor=%d" % anchor_lord,
		"final": {"teams": state.teams.size(), "factions": state.factions.size()},
		"probe": {"relocate.ordered": Probe.counts.get("relocate.ordered", 0),
			"relocate.delivered": Probe.counts.get("relocate.delivered", 0),
			"relocate.comply": Probe.counts.get("relocate.comply", 0),
			"relocate.resist": Probe.counts.get("relocate.resist", 0),
			"relocate.unrest_added": Probe.counts.get("relocate.unrest_added", 0),
			"relocate.started": Probe.counts.get("relocate.started", 0),
			"relocate.abandoned": Probe.counts.get("relocate.abandoned", 0),
			"relocate.arrived": Probe.counts.get("relocate.arrived", 0),
			"relocate.resettled": Probe.counts.get("relocate.resettled", 0),
			"relocate.value_peak": Probe.peaks.get("relocate.value", 0.0)},
		"per_village_value_sample": per_village,
	}
	var f := FileAccess.open(OUT_PATH.replace(".json", "-anchor%d.json" % anchor_lord), FileAccess.WRITE)
	if f != null:
		f.store_string(JSON.stringify(dump, "  ")); f.close()
		print("\n[dump] → %s" % OUT_PATH.replace(".json", "-anchor%d.json" % anchor_lord))
	SpecimenDumpHelper.dump(state, "res://docs/measurements/2026-08-06-infonet-recovery-r3-relocate-anchor%d.specimen.jsonl" % anchor_lord)
	print("=== DONE ===")
	Probe.enabled = false
	quit()
