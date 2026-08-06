extends SceneTree

# [measurer persist fixture 2026-08-06] recovery-path Slice R2 投資測床。
# 工單:2026-08-06-systems-to-measurer-recovery-r2-measure.md
# ex-ante formula驗證(見config._doc):facility_roi forest pop5=+25.4(正)/mountain遠負。
# 3組獨立faction pair(彼此遠隔避免交叉污染)：pair1=早投成功案/pair2=anti-crank晚投案/
#   pair3=mountain負ROI案。★VISION LOD_NEAR_RADIUS=3很窄,無法多pair共享anchor(R1教訓)——
#   用ANCHOR_LORD env var切換cluster_pos指向哪個lord,同config同seed分開跑3次。

const CONFIG_PATH := "res://config/infonet_recovery_r2_invest.json"
const SEED: int = 5252
const DAYS: int = 8
const OUT_PATH := "res://docs/measurements/2026-08-06-infonet-recovery-r2-invest.json"

func _initialize() -> void:
	var anchor_lord: int = int(OS.get_environment("ANCHOR_LORD")) if OS.get_environment("ANCHOR_LORD") != "" else 0
	print("=== recovery-path R2 投資測床（seed=%d %d天, ANCHOR_LORD=%d）===" % [SEED, DAYS, anchor_lord])
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
	var labels: Dictionary = {0: "Lord1", 1: "Village1_ForestEarly", 2: "Lord2",
		3: "Village2_ForestLate(anti-crank)", 4: "Lord3", 5: "Village3_Mountain"}

	for tick in range(ticks):
		runner.advance_tick(state, cluster_pos)

	print("\n───── recovery-r2 摘要(%d天, anchor=%s) ─────" % [DAYS, String(labels[anchor_lord])])
	print("final teams=%d factions=%d" % [state.teams.size(), state.factions.size()])
	for vid in [0, 1, 2, 3, 4, 5]:
		if state.teams.has(vid):
			var t: TeamData = state.teams[vid]
			var tile: HexTileData = state.world.tiles.get(t.tile_pos.x * 1000 + t.tile_pos.y)
			print("  %s(T%d): alive=true pop=%d faction=%d farming_level=%s food=%.1f" % [
				String(labels[vid]), vid, t.population, t.faction_id,
				str(tile.farming_level) if tile else "N/A", ResourceSystem.effective_food(state, t)])
		else:
			print("  %s(T%d): DEAD/滅團" % [String(labels[vid]), vid])

	print("\n★invest鏈計數：invest.dispatched=%d invest.material_delivered=%.1f village.build_fired=%d survival.rescue_build=%d" % [
		int(Probe.counts.get("invest.dispatched", 0)), float(Probe.amounts.get("invest.material_delivered", 0.0)),
		int(Probe.counts.get("village.build_fired", 0)), int(Probe.counts.get("survival.rescue_build", 0))])
	print("invest.roi(peak)=%.4f" % float(Probe.peaks.get("invest.roi", 0.0)))

	print("\n★per-target invest.roi真值:")
	var per_village: Dictionary = {}
	for s in Probe.samples.get("invest.roi_sample", []):
		var vid: int = int(s.get("village", -1))
		if not per_village.has(vid): per_village[vid] = []
		(per_village[vid] as Array).append({"terrain": s.get("terrain", ""), "roi": s.get("roi", 0.0)})
	for vid in [1, 3, 5]:
		var arr: Array = per_village.get(vid, [])
		print("  %s(T%d): n=%d first=%s" % [String(labels[vid]), vid, arr.size(), str(arr[0] if not arr.is_empty() else {})])

	var dump: Dictionary = {
		"diagnostic": "recovery-path R2 投資測床(ex-ante formula見config._doc), anchor=%d" % anchor_lord,
		"final": {"teams": state.teams.size(), "factions": state.factions.size()},
		"probe": {"invest.dispatched": Probe.counts.get("invest.dispatched", 0),
			"invest.material_delivered": Probe.amounts.get("invest.material_delivered", 0.0),
			"village.build_fired": Probe.counts.get("village.build_fired", 0),
			"survival.rescue_build": Probe.counts.get("survival.rescue_build", 0),
			"invest.roi_peak": Probe.peaks.get("invest.roi", 0.0)},
		"per_village_roi_sample": per_village,
	}
	var f := FileAccess.open(OUT_PATH.replace(".json", "-anchor%d.json" % anchor_lord), FileAccess.WRITE)
	if f != null:
		f.store_string(JSON.stringify(dump, "  ")); f.close()
		print("\n[dump] → %s" % OUT_PATH.replace(".json", "-anchor%d.json" % anchor_lord))
	SpecimenDumpHelper.dump(state, "res://docs/measurements/2026-08-06-infonet-recovery-r2-invest-anchor%d.specimen.jsonl" % anchor_lord)
	print("=== DONE ===")
	Probe.enabled = false
	quit()
