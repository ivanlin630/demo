extends SceneTree

# 經濟食物統一 — 乾淨 bed 驗整環（econ-food-unify Task 2）。
# 隔離 fixture：
#   Team0 林業村(forest, food窮/material富, 生產) — 該累積食物(覓食/交易)→effective_food↑→生育→pop 長
#   Team1 平原糧鎮(plains, 糧倉滿溢) — 對照原生糧興旺
#   Team2 中立商隊(coin/goods 充) — 運糧中介
#   Team9 觀測錨點(player) — near-zone 錨：advance_tick(state, anchor_pos) 用此算 near/far，
#         否則傳 (-1,-1) → 全隊 far → 人物反應(生育)被跳過(LOD 跳遠區反應)。
# 低野心/無好戰 → 隔離 prosperity-attack 戰鬥噪音。
# 量整環：forest 隊月軌跡 pop / effective_food / granary / coin / material / task / food_buy。
# 純量測，不改邏輯。守恆/regen 不碰。

func _initialize() -> void:
	_run(); quit()

func _line(state: WorldState, tid: int) -> String:
	var t: TeamData = state.teams.get(tid)
	if t == null:
		return "T%d: 死/併" % tid
	var priv: float = float(t.resources.get("food", 0))
	var eff: float = ResourceSystem.effective_food(state, t)
	var gran: float = eff - priv
	var burn: float = maxf(float(t.population) * ResourceSystem.FOOD_PER_PERSON_PER_DAY, 0.001)
	var days: float = eff / burn
	var has_buy: bool = false
	for o in t.active_orders:
		if String(o.get("res", "")) == "food" and String(o.get("kind", "")) == "buy":
			has_buy = true
	var tile: HexTileData = state.world.tiles.get(t.tile_pos.x * 1000 + t.tile_pos.y)
	var terr: String = tile.terrain if tile != null else "?"
	return "T%d[%s] pop=%d minor=%d eff_food=%.0f(priv=%.0f+gran=%.0f) days=%.1f coin=%.0f mat=%.0f task=%s food_buy=%s" % [
		tid, terr, t.population, t.minor_population, eff, priv, gran, days,
		float(t.resources.get("coin", 0)), float(t.resources.get("material", 0)),
		t.current_task, "Y" if has_buy else "-"]

func _run() -> void:
	print("=== econ bed diagnose: 特化→累積→長 pop 整環 (econ-food-unify) ===")
	Probe.enabled = true; Probe.reset()   # BEG/JOIN 死路探針 host（純觀測）
	var state := WorldState.new()
	var runner := SimRunner.new()
	var config := GameSetup.load_config("res://config/econ_bed.json")
	if config.is_empty():
		print("[FAIL] config 載入失敗"); return
	GameSetup.setup(state, config)
	# near-zone 錨：advance_tick 用傳入 player_pos 算 near/far（非自算）。
	# 傳 anchor(5,5) → forest(5,5)/plains(6,5)/caravan(6,5) 全入近區 → 跑人物反應(生育)。
	var anchor_pos := Vector2i(5, 5)
	var tracked: Array = [0, 1, 2]
	var pop0: Dictionary = {}
	for tid in tracked:
		if state.teams.has(tid):
			pop0[tid] = state.teams[tid].population

	print("--- t0 ---")
	for tid in tracked: print("  " + _line(state, tid))

	var trade_fired := {0: false, 1: false}
	for month in range(6):
		for _t in range(240 * 30):
			runner.advance_tick(state, anchor_pos)
			for tid in [0, 1]:
				var t: TeamData = state.teams.get(tid)
				if t != null and t.current_task == TeamData.TASK_TRADE:
					trade_fired[tid] = true
			if state.encounter_active and state.encounter_tick > 800:
				runner._encounter_system.resolve_encounter_end(state, "draw")
		print("--- 月%d ---" % (month + 1))
		for tid in tracked: print("  " + _line(state, tid))

	# 驗收摘要
	print("\n=== 驗收 ===")
	for tid in [0, 1]:
		var t: TeamData = state.teams.get(tid)
		if t == null:
			print("[bed] T%d 死/併" % tid); continue
		var grew: bool = t.population > int(pop0.get(tid, 0))
		var label: String = "forest林業村" if tid == 0 else "plains平原糧鎮"
		print("[bed] T%d(%s) pop %d→%d 長=%s TASK_TRADE曾fire=%s" % [
			tid, label, int(pop0.get(tid, 0)), t.population,
			"Y" if grew else "N", "Y" if trade_fired.get(tid, false) else "N"])
	print("[bed] 整環判讀：forest 累積食物(覓食/交易→effective_food)→生育→pop 長 = 看 T0 pop 漲")
	print("[bed] REGEN_RATE 未動：forest food=%.1f material=%.1f plains food=%.1f (應 3/12/8)" % [
		float(ResourceSystem.REGEN_RATE["forest"]["food"]),
		float(ResourceSystem.REGEN_RATE["forest"]["material"]),
		float(ResourceSystem.REGEN_RATE["plains"]["food"])])
	# BEG/JOIN 死路探針（F-I3）
	for k in ["beg.dispatch", "beg.early_return_197", "beg.resolve",
			"join.dispatch", "join.arrived_no_handler", "join.resolve"]:
		print("[bed] probe %s=%d" % [k, int(Probe.counts.get(k, 0))])
	Probe.enabled = false
	print("=== econ bed diagnose DONE ===")
