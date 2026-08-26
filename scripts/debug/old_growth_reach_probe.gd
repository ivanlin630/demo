extends SceneTree
# ★老熟林的【死水兩欄】：機制活著 ≠ 有人碰得到。
#   ①★世界上生成了幾座老熟林？（機制有沒有 fire）
#   ②★★30 天後【有沒有人碰到】？—— 用 material 的變化量判，不用推論判。
#
# ★★★曝光母體的真相（我第一版的註解寫錯了，坐實後訂正）：
#   `resource_system.gd:95-100` —— **鄰格採集【只在 outpost_level == 3】發生**；
#   L1／L2 只採【腳下那一格】(`:101-103`)。而這張床 11 座據點【全部 level 1】。
#   `:65-77` L0 營地 forage **只採 food，不採 material**。
#   ⇒ ★★材料只從「自己有據點的那一格」進帳 ⇒ **老熟林要有用，得先有人在它上面蓋據點。**
#   ⇒ ★★★而蓋據點正是這條 arc 卡住的那件事 ⇒ **這是個迴圈，不是一條供給。**
#   ★本床把「迴圈」這個判斷交給數字：若 30 天後每一座 material 都一動不動，迴圈成立。
#
# ★壞掉會長什麼樣：只報「reject_cannot_afford 沒下降」⇒ 會被讀成「老熟林這招沒用」，
#   而真正的形狀是「老熟林生出來了、就是沒有任何一隊碰得到」——兩者的下一步完全不同。
# env：LW_CONFIG / PERF_SEED / ADHOC_DAYS / PERF_OUT

func _initialize() -> void:
	_run(); quit()

func _run() -> void:
	var cfg: String = _env("LW_CONFIG", "peaceful_economy")
	var days: int = int(_env("ADHOC_DAYS", "30"))
	var out_path: String = _env("PERF_OUT", "")
	var sd: int = int(_env("PERF_SEED", "1337"))
	seed(sd)
	var state := WorldState.new()
	var runner := SimRunner.new()
	var config: Dictionary = GameSetup.load_config("res://config/%s.json" % cfg)
	if config.is_empty():
		print("[FAIL] config"); return
	config["seed"] = sd
	GameSetup.setup(state, config)
	var wg = load("res://scripts/simulation/world_generator.gd").new()
	var lines: Array = []

	# ===== ① 生成期：老熟林幾座、在哪、離據點多遠 =====
	var og_ids: Array = []
	var og_init: Dictionary = {}     # tile_id -> 初始 material
	var forest_n: int = 0
	for tid in state.world.tiles:
		var t: HexTileData = state.world.tiles[tid]
		if t.terrain != "forest":
			continue
		forest_n += 1
		if float(t.resources.get("material", 0)) >= float(wg.OLD_GROWTH_MATERIAL_MIN):
			og_ids.append(tid)
			og_init[tid] = float(t.resources.get("material", 0))
	lines.append("[%s seed %d days %d] forest tiles = %d，★老熟林 = %d（期望 ≈ %d × %.2f = %.1f）" % [
		cfg, sd, days, forest_n, og_ids.size(), forest_n, wg.OLD_GROWTH_CHANCE,
		float(forest_n) * wg.OLD_GROWTH_CHANCE])

	# ★據點：座數 + 等級分布（★★等級決定曝光母體，不是可有可無的一欄）
	var ops: Array = []
	var lvl: Dictionary = {}
	for tid2 in state.world.tiles:
		var t2: HexTileData = state.world.tiles[tid2]
		if t2.outpost_level > 0:
			ops.append(t2)
			lvl[t2.outpost_level] = int(lvl.get(t2.outpost_level, 0)) + 1
	var lk: Array = lvl.keys(); lk.sort()
	var lvl_s: Array = []
	for L in lk: lvl_s.append("L%d×%d" % [int(L), int(lvl[L])])
	lines.append("  據點 %d 座（開場等級：%s）" % [ops.size(), " ".join(PackedStringArray(lvl_s))])

	var dist0: Dictionary = {}   # tile_id -> 開場時到最近據點的距離
	for oid in og_ids:
		var t3: HexTileData = state.world.tiles[oid]
		var best: int = 9999
		for o in ops:
			var d: int = FactionAISystem._hex_dist(t3.tile_pos, o.tile_pos)
			if d < best: best = d
		dist0[oid] = best

	# ===== ② 跑 N 天，再看那幾格 =====
	var no_player := Vector2i(-1, -1)
	for _t in range(days * WorldState.TICKS_PER_DAY):
		runner.advance_tick(state, no_player)
		if state.encounter_active and state.encounter_tick > 800:
			runner._encounter_system.resolve_encounter_end(state, "draw")
		if state.teams.is_empty(): break

	if og_ids.is_empty():
		lines.append("  ★★零座老熟林 ⇒ 機制【這個 seed 沒 fire】—— 不是「沒用」，是【沒出現】")
	else:
		lines.append("--- ★★老熟林逐座：開場 → %d 天後 ---" % days)
		var touched: int = 0
		var became_outpost: int = 0
		for oid2 in og_ids:
			var tt: HexTileData = state.world.tiles[oid2]
			var m0: float = float(og_init[oid2])
			var m1: float = float(tt.resources.get("material", 0))
			var delta: float = m1 - m0
			if absf(delta) > 0.001: touched += 1
			if tt.outpost_level > 0: became_outpost += 1
			lines.append("  (%2d,%2d) material %4.0f → %4.0f（Δ %+.0f）｜開場離最近據點 %d｜%d 天後 outpost_level=%d camp_level=%d" % [
				tt.tile_pos.x, tt.tile_pos.y, m0, m1, delta, int(dist0[oid2]),
				days, tt.outpost_level, tt.camp_level])
		lines.append("  ⇒ ★material 有變動的 = %d / %d 座｜★★上面長出據點的 = %d 座" % [
			touched, og_ids.size(), became_outpost])
		# ★收尾等級分布：有沒有人升到 L3（★L3 才吃得到鄰格）
		var lvl2: Dictionary = {}
		for tid3 in state.world.tiles:
			var t4: HexTileData = state.world.tiles[tid3]
			if t4.outpost_level > 0:
				lvl2[t4.outpost_level] = int(lvl2.get(t4.outpost_level, 0)) + 1
		var lk2: Array = lvl2.keys(); lk2.sort()
		var l2s: Array = []
		for L2 in lk2: l2s.append("L%d×%d" % [int(L2), int(lvl2[L2])])
		lines.append("  ★收尾據點等級：%s ——【L3 是鄰格採集的唯一開關】(resource_system:95-100)" % " ".join(PackedStringArray(l2s)))
		if touched == 0:
			lines.append("  ★★★全部一動不動 ⇒ **老熟林生出來了、沒有任何一隊碰得到** ——")
			lines.append("     這不是量級不夠（660 材料就擺在那），是【接不上】。")

	var text: String = "\n".join(PackedStringArray(lines))
	print("\n" + text)
	if out_path != "":
		var f := FileAccess.open(out_path, FileAccess.WRITE)
		if f != null:
			f.store_string(text + "\n"); f.close()
	print("=== old_growth_reach DONE ===")

func _env(key: String, dflt: String) -> String:
	var v: String = OS.get_environment(key)
	return v if v != "" else dflt
