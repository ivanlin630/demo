extends SceneTree
# ★★★問產生器，不問人（systems 派 2026-08-26）：床要加 forest 據點，而【改幾座】不由人挑。
#   ★理由（他寫的，我照抄進註解免得下一個人以為這是我隨手決定的）：
#     **手挑一張床，跟手抄一個常數，在「它憑什麼是這個數字」這件事上是一樣的。**
#   ⇒ 本檔只做一件事：跑 `WorldGenerator.scored_positions_pure`，報【前 N 名的地形分布】。
#   ★★純讀零改：不呼叫 generate、不動 state、不落任何決策；只算分數並排序。
#   ★★★壞掉會長什麼樣：若只報「前 11 名有幾座 forest」而不報【母體地形分布】，
#     那個數字讀不出「產生器偏好 forest」還是「這張圖本來就一堆 forest」——兩者結論相反。
# env：LW_CONFIG（預設 peaceful_economy＝要改的那張床）、TOP_N（預設 11＝該床現有據點數）、PERF_OUT

func _initialize() -> void:
	_run(); quit()

func _run() -> void:
	var cfg: String = _env("LW_CONFIG", "peaceful_economy")
	var top_n: int = int(_env("TOP_N", "11"))
	var out_path: String = _env("PERF_OUT", "")
	print("=== 產生器排名地形分布：config=%s top_n=%d ===" % [cfg, top_n])
	seed(int(_env("PERF_SEED", "1337")))
	var state := WorldState.new()
	var config: Dictionary = GameSetup.load_config("res://config/%s.json" % cfg)
	if config.is_empty():
		print("[FAIL] config 載入失敗"); return
	GameSetup.setup(state, config)
	var wg = load("res://scripts/simulation/world_generator.gd").new()   # ★無 class_name，照既有 caller 的載法（game_setup:93）
	# ★★★用【真正的放置路徑】(systems 訂正 2026-08-26)：`scored_positions_pure` 檔頭自己寫著
	#   「§3 fallback 用：純評分（無 rng 噪聲）」⇒ 它不是世界實際怎麼擺的那條。
	#   真路徑 `pick_start_positions` 多兩件【會改變答案】的東西：
	#     ①`score × (1 ± SCATTER_NOISE)` 的位置熵 ②`min_sep` 硬間距排除
	#   ★★兩者都會把「前 N 名全是同一種地形」打散 —— ★所以純評分那版的 100% 是【上界】不是實況。
	#   ★引數照真 caller 取（`game_setup:121/142`）：`min_spacing` 讀 config、rng 用同一顆 seed。
	var ocfg: Dictionary = config.get("outposts", {})
	var min_sp: int = int(ocfg.get("min_spacing", 2))
	var rng := RandomNumberGenerator.new()
	rng.seed = int(config.get("seed", 42))
	var ranked: Array = wg.pick_start_positions(state, top_n, min_sp, rng)
	# ★對照組保留：純評分版（無噪聲、無間距）—— ★兩版並排才看得出噪聲與間距改變了多少
	var ranked_pure: Array = wg.scored_positions_pure(state)
	var lines: Array = []
	lines.append("[%s] tiles=%d，★真路徑 pick_start_positions 回 %d 個（min_spacing=%d、含 scatter 噪聲）" % [
		cfg, state.world.tiles.size(), ranked.size(), min_sp])
	# ★母體：整張圖的地形分布（★沒有它，前 N 的分布讀不出是偏好還是母體本來的比例）
	var all_terr: Dictionary = {}
	for tid in state.world.tiles:
		var t: HexTileData = state.world.tiles[tid]
		all_terr[t.terrain] = int(all_terr.get(t.terrain, 0)) + 1
	lines.append("--- ★母體：全圖地形分布 ---")
	var akeys: Array = all_terr.keys(); akeys.sort()
	for k in akeys:
		lines.append("  %-10s = %3d（%.1f%%）" % [String(k), int(all_terr[k]),
			100.0 * float(all_terr[k]) / maxf(float(state.world.tiles.size()), 1.0)])
	# ★前 N 名的地形分布
	var top_terr: Dictionary = {}
	var n: int = mini(top_n, ranked.size())
	for i in range(n):
		var p: Vector2i = ranked[i]
		var tt: HexTileData = state.world.tiles.get(p.x * 1000 + p.y)
		if tt == null: continue
		top_terr[tt.terrain] = int(top_terr.get(tt.terrain, 0)) + 1
	lines.append("--- ★★產生器【前 %d 名】的地形分布（★這才是「產生器會選什麼」）---" % n)
	var tkeys: Array = top_terr.keys(); tkeys.sort()
	for k2 in tkeys:
		var cnt: int = int(top_terr[k2])
		var base_pct: float = 100.0 * float(all_terr.get(k2, 0)) / maxf(float(state.world.tiles.size()), 1.0)
		var top_pct: float = 100.0 * float(cnt) / maxf(float(n), 1.0)
		lines.append("  %-10s = %2d（前 N 佔 %.1f%%｜全圖佔 %.1f%%｜★偏好倍數 %.2f×）" % [
			String(k2), cnt, top_pct, base_pct, top_pct / maxf(base_pct, 0.001)])
	lines.append("--- ★前 %d 名逐格（座標／地形／分數序）---" % n)
	for i2 in range(n):
		var p2: Vector2i = ranked[i2]
		var t2: HexTileData = state.world.tiles.get(p2.x * 1000 + p2.y)
		lines.append("  #%2d (%2d,%2d) %-10s" % [i2 + 1, p2.x, p2.y, (t2.terrain if t2 != null else "?")])
	# ★對照組：純評分版（無噪聲無間距）——★標明它是【上界】，不是世界實況
	var pure_terr: Dictionary = {}
	for i3 in range(mini(top_n, ranked_pure.size())):
		var p3: Vector2i = ranked_pure[i3]
		var t4: HexTileData = state.world.tiles.get(p3.x * 1000 + p3.y)
		if t4 != null:
			pure_terr[t4.terrain] = int(pure_terr.get(t4.terrain, 0)) + 1
	lines.append("--- ★對照組：純評分版 scored_positions_pure（★無噪聲無間距＝上界，非實況）---")
	var pkeys: Array = pure_terr.keys(); pkeys.sort()
	for k4 in pkeys:
		lines.append("      %-10s = %d" % [String(k4), int(pure_terr[k4])])
	lines.append("--- ★對照：這張床現有據點的地形分布 ---")
	var have: Dictionary = {}
	var n_op: int = 0
	for tid2 in state.world.tiles:
		var t3: HexTileData = state.world.tiles[tid2]
		if t3.outpost_level > 0:
			n_op += 1
			have[t3.terrain] = int(have.get(t3.terrain, 0)) + 1
	lines.append("  現有據點 %d 座：" % n_op)
	var hkeys: Array = have.keys(); hkeys.sort()
	for k3 in hkeys:
		lines.append("      %-10s = %d" % [String(k3), int(have[k3])])
	lines.append("  ★★兩表並排＝【產生器會選的】vs【手寫床實際擺的】—— ★差異多大由你判，我不挑數字。")
	var text: String = "\n".join(PackedStringArray(lines))
	print("\n" + text)
	if out_path != "":
		var f := FileAccess.open(out_path, FileAccess.WRITE)
		if f != null:
			f.store_string(text + "\n"); f.close()
	print("=== 產生器排名地形分布 DONE ===")

func _env(key: String, dflt: String) -> String:
	var v: String = OS.get_environment(key)
	return v if v != "" else dflt
