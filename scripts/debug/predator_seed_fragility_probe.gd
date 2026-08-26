extends SceneTree
# ★headless 閘新冒出來的那一項（`應有 tile 帶 predator_density`）到底是什麼：
#   ①我的改動【直接】拿掉了猛獸？——不可能：老熟林只寫 `tile.resources["material"]`。
#   ②還是【RNG 序列平移】撞上小圖槓龜？——本檔用數字判，不用我推。
# ★判準：跑 `_test_predator_seeded` 那個世界（radius 4／seed 11），數【多少格帶猛獸】，
#   並掃一排 seed 看【多少個 seed 會槓龜】——★槓龜率就是這個 assert 的脆弱度。
# ★★這支不改任何 production code；要不要動那個 assert 是 systems 的裁決，不是我的。
# ★注意：`world_generator.gd:134` 已經有【礦脈保證】專治「小圖 RNG 槓龜」——猛獸沒有同款保證。

func _initialize() -> void:
	_run(); quit()

func _run() -> void:
	var lines: Array = []
	var wg = load("res://scripts/simulation/world_generator.gd").new()
	lines.append("OLD_GROWTH_CHANCE = %.2f（本 branch 現值）" % wg.OLD_GROWTH_CHANCE)
	lines.append("PREDATOR_FOREST_CHANCE = %.2f｜PREDATOR_MOUNTAIN_CHANCE = %.2f" % [
		wg.PREDATOR_FOREST_CHANCE, wg.PREDATOR_MOUNTAIN_CHANCE])
	var dry: int = 0
	var total: int = 0
	for sd in range(1, 41):
		var state := WorldState.new()
		state.world = WorldData.new()
		var gen = load("res://scripts/simulation/world_generator.gd").new()
		gen.generate(state, {"radius": 4, "seed": sd, "resource_multiplier": 1.0})
		var n_pred: int = 0
		var n_forest: int = 0
		var n_mount: int = 0
		for tid in state.world.tiles:
			var t: HexTileData = state.world.tiles[tid]
			if t.terrain == "forest": n_forest += 1
			elif t.terrain == "mountain": n_mount += 1
			if int(t.resources.get("predator_density", 0)) > 0: n_pred += 1
		total += 1
		if n_pred == 0: dry += 1
		if sd == 11 or n_pred == 0:
			lines.append("  seed %2d：tiles=%d forest=%d mountain=%d ★帶猛獸的格=%d%s" % [
				sd, state.world.tiles.size(), n_forest, n_mount, n_pred,
				"   ←★★槓龜（assert 會 FAIL）" if n_pred == 0 else ("   ←★測試用的那個 seed" if sd == 11 else "")])
	lines.append("⇒ ★40 個 seed 裡【整圖零猛獸】= %d 個（%.1f%%）" % [dry, 100.0 * dry / maxf(total, 1)])
	lines.append("★★這個 assert 斷的是一件【機率事件】，母體只有 61 格 ——")
	lines.append("   我的改動沒有動猛獸任何一行，只是把 rng 序列往後推了（每個 forest 格一次 randf）。")
	lines.append("★★★`world_generator.gd:134` 對礦脈已經有【小圖槓龜保證】；猛獸沒有。改法是 systems 的裁決。")
	var text: String = "\n".join(PackedStringArray(lines))
	print("\n" + text)
	var out_path: String = OS.get_environment("PERF_OUT")
	if out_path != "":
		var f := FileAccess.open(out_path, FileAccess.WRITE)
		if f != null:
			f.store_string(text + "\n"); f.close()
	print("=== predator_seed_fragility DONE ===")
