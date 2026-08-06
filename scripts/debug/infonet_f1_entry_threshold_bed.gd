extends SceneTree

# [measurer persist fixture 2026-08-07] F1死常數人格化靶A測床(desperation_entry_threshold)。
# 工單:2026-08-07-systems-to-measurer-F1-measure.md
# ex-ante formula預算(見config._doc):neutral threshold=3.0/cautious threshold=5.1(封頂)/
#   bold threshold=1.5(封底)。3隊獨立無faction,同起始food/pop/terrain,純消耗觀察逐日
#   food_days何時跌破各自threshold——同機制人格不同命(cautious最早"進絕境"、bold最晚)。
# 無需cluster_pos/vision(純自讀leader_values,零跨隊belief依賴,同R1-R3學到的教訓後這次選了
#   完全不需要belief的機制,規避整條LOD/vision坑)。

const CONFIG_PATH := "res://config/infonet_f1_entry_threshold.json"
const SEED: int = 7171
const DAYS: int = 10
const OUT_PATH := "res://docs/measurements/2026-08-07-infonet-f1-entry-threshold.json"

func _initialize() -> void:
	print("=== F1靶A desperation_entry_threshold測床（seed=%d %d天）===" % [SEED, DAYS])
	seed(SEED)
	FactionAISystem._a2b_remote_tribute_payers.clear()
	Probe.reset(); Probe.enabled = true
	var state := WorldState.new()
	var runner := SimRunner.new()
	var config: Dictionary = GameSetup.load_config(CONFIG_PATH)
	config["seed"] = SEED
	GameSetup.setup(state, config)
	SpecimenDumpHelper.setup_from_env(state)

	var no_player := Vector2i(-1, -1)
	var ticks: int = WorldState.TICKS_PER_DAY * DAYS
	var labels: Dictionary = {0: "neutral", 1: "cautious", 2: "bold"}
	var lv_traits: Dictionary = {}
	for tid in [0, 1, 2]:
		var leader: PersonData = state.persons.get(state.teams[tid].leader_id)
		lv_traits[tid] = {"慎重": leader.values.get("慎重", 0.5), "求生欲": leader.values.get("求生欲", 0.5), "好戰": leader.values.get("好戰", 0.5)}

	# ex-ante formula預算(鏡射DecisionTerms.desperation_entry_threshold,純算術非呼production函式,
	#   避免worktree class載入順序問題;數值與production公式應完全一致,量測後可交叉核對)。
	var pred_threshold: Dictionary = {}
	for tid in [0, 1, 2]:
		var t: Dictionary = lv_traits[tid]
		var mult: float = clampf(1.0 + (float(t["慎重"]) - 0.5) * 0.6 + (float(t["求生欲"]) - 0.5) * 0.6 - (float(t["好戰"]) - 0.5) * 0.6, 0.5, 1.7)
		pred_threshold[tid] = 3.0 * mult

	print("[setup] ex-ante預算threshold: neutral=%.2f cautious=%.2f bold=%.2f" % [pred_threshold[0], pred_threshold[1], pred_threshold[2]])

	var daily: Dictionary = {0: [], 1: [], 2: []}
	var cross_day: Dictionary = {0: -1, 1: -1, 2: -1}

	for tick in range(ticks):
		runner.advance_tick(state, no_player)
		var cur_tick: int = state.world.current_tick
		if cur_tick % WorldState.TICKS_PER_DAY == 0:
			var day: int = cur_tick / WorldState.TICKS_PER_DAY
			for tid in [0, 1, 2]:
				if not state.teams.has(tid): continue
				var t: TeamData = state.teams[tid]
				var pop: int = t.population + t.minor_population
				var burn: float = maxf(float(pop) * ResourceSystem.FOOD_PER_PERSON_PER_DAY, 0.001)
				var food_days: float = ResourceSystem.effective_food(state, t) / burn
				(daily[tid] as Array).append({"day": day, "pop": t.population, "food_days": snappedf(food_days, 0.01)})
				if cross_day[tid] == -1 and food_days < float(pred_threshold[tid]):
					cross_day[tid] = day

	print("\n───── F1靶A 摘要(%d天) ─────" % DAYS)
	for tid in [0, 1, 2]:
		print("  %s(T%d): pred_threshold=%.2f cross_day=%d final_daily=%s" % [
			String(labels[tid]), tid, pred_threshold[tid], cross_day[tid],
			str((daily[tid] as Array).back() if not (daily[tid] as Array).is_empty() else {})])

	print("\n★物理錨驗證(買糧量/relief target應=DESPERATION_DAYS(3.0)×pop×0.8,不隨人格變):")
	for tid in [0, 1, 2]:
		if state.teams.has(tid):
			var t: TeamData = state.teams[tid]
			var raw_anchor: float = 3.0 * float(t.population) * ResourceSystem.FOOD_PER_PERSON_PER_DAY
			print("  %s(T%d): pop=%d raw_anchor(DESPERATION_DAYS×pop×0.8)=%.2f" % [String(labels[tid]), tid, t.population, raw_anchor])

	var dump: Dictionary = {
		"diagnostic": "F1靶A desperation_entry_threshold測床(ex-ante formula見config._doc)",
		"pred_threshold": pred_threshold, "cross_day": cross_day, "daily": daily,
		"leader_traits": lv_traits,
	}
	var f := FileAccess.open(OUT_PATH, FileAccess.WRITE)
	if f != null:
		f.store_string(JSON.stringify(dump, "  ")); f.close()
		print("\n[dump] → %s" % OUT_PATH)
	SpecimenDumpHelper.dump(state, "res://docs/measurements/2026-08-07-infonet-f1-entry-threshold.specimen.jsonl")
	print("=== DONE ===")
	Probe.enabled = false
	quit()
