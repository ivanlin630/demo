extends SceneTree
# terrain_density_distance_bed：地形密度/資源分布——「這個世界存不存在值得跨越的距離」
# (systems 2026-09-09派票，blueprint裁地基題)。★tick-0快照,不跑模擬。
#
# ①terrain直方圖(組成，背景) ②到最近各terrain的距離分布(排列，真答案)——
#   兩種母體分開報：(a)每一格起算=世界結構性質 (b)每支隊當下位置起算=決策實際面對的東西
# ③逐資源拆(食物/材料/礦)：食物=最近plains(REGEN_RATE食物最高地形,resource_system.gd:56)、
#   材料=最近forest(REGEN_RATE材料最高地形,resource_system.gd:57)、
#   礦=最近【真的帶ore_gold】的tile(非全部mountain——只有mountain且擲中ORE_GOLD_CHANCE=0.12才有,
#   world_generator.gd:92-94)——★食物/材料在RESOURCE_PROFILE三地形下限皆>0(world_generator.gd:8-12)
#   ⇒ 每格initial stock都>0，「到最近產地」對食物/材料會是平凡的0，這本身就是要報的發現。
# ④對照：同一份格子跑在3個radius>=16的config(16/24/40)+warring_states(14)當基準點，
#   看密度隨圖變大：同密度鋪更大(距離不變) vs 同數量攤更開(距離變遠)。
#
# 距離計算：多源BFS(O(N)非O(N²))，非逐對窮舉——radius=40約4921格，窮舉會是24M次比對，
#   BFS用HEX_DIRS(resource_system.gd:62-65)鄰居展開，一次算出全圖到某集合的最短距離。
# seed：worldgen有隨機性，每個config跑2個seed(1337/2026)，非單seed碰運氣。
#
# 誠實限（照票面）：①不下設計結論(該不該讓距離變遠=用戶fork,blueprint呈不預裁)
#   ②">5格"是操作定義非世界性質——原始分布一併給出，下游可另切門檻
#   ③礦terrain綁定=world_generator.gd:92-94(mountain+ORE_GOLD_CHANCE)，查得到，非「查不到」

const MAIN_CONFIG: String = "res://config/warring_states.json"
const SIZE_CONFIGS: Array = [
	"res://config/warring_states.json",                # radius=14，基準點
	"res://config/infonet_established_fragility.json", # radius=16
	"res://config/perf_scale.json",                     # radius=24
	"res://config/infonet_recovery_r2_invest.json",     # radius=40
]
const SEEDS: Array = [1337, 2026]
const HEX_DIRS: Array = [
	Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1),
	Vector2i(0, -1), Vector2i(1, -1), Vector2i(-1, 1),
]
const FAR_THRESHOLD: int = 5   # ★操作定義（systems給），非世界性質——原始分布另附

func _initialize() -> void:
	_run(); quit()

func _run() -> void:
	print("=== terrain_density_distance_bed (tick-0 快照，非模擬窗) ===\n")

	print("############ ①②③ 本體：%s ############" % MAIN_CONFIG)
	for seed_val in SEEDS:
		_analyze_one(MAIN_CONFIG, seed_val, true)

	print("\n############ ④對照：密度隨圖變大怎麼變 ############")
	for cfg in SIZE_CONFIGS:
		for seed_val in SEEDS:
			_analyze_one(cfg, seed_val, false)

	print("\n=== terrain_density_distance_bed DONE ===")

func _analyze_one(cfg_path: String, seed_val: int, full_detail: bool) -> void:
	var t0: int = Time.get_ticks_msec()
	var conf: Dictionary = GameSetup.load_config(cfg_path)
	conf["seed"] = seed_val
	var state: WorldState = MeasureBedHelper.arm_and_setup(conf, true)
	var radius: int = int((conf.get("map", {}) as Dictionary).get("radius", -1))
	var tiles: Dictionary = state.world.tiles
	var n: int = tiles.size()
	var elapsed_ms: int = Time.get_ticks_msec() - t0
	print("\n--- config=%s radius=%d seed=%d tiles=%d (耗時%dms) ---" % [cfg_path, radius, seed_val, n, elapsed_ms])
	if elapsed_ms > 5000:
		print("  ★★成本超過秒級(>5000ms)——按票面規則先報這個訊號，非默默吞")

	# ①terrain直方圖
	var terrain_count: Dictionary = {}
	for tid in tiles:
		var tr: String = (tiles[tid] as HexTileData).terrain
		terrain_count[tr] = int(terrain_count.get(tr, 0)) + 1
	print("①terrain直方圖(組成，背景)：")
	for tr in terrain_count:
		print("  %s: %d格 (%.1f%%)" % [tr, terrain_count[tr], 100.0 * float(terrain_count[tr]) / float(n)])

	# BFS: 到每個terrain最近距離（全圖，一次性）
	var dist_by_terrain: Dictionary = {}   # terrain -> {tile_id:dist}
	for tr2 in terrain_count:
		dist_by_terrain[tr2] = _bfs_multi_source(state, _tiles_of_terrain(tiles, tr2))

	if full_detail:
		print("②到最近各terrain的距離分布(排列，真答案)：")
		for tr3 in dist_by_terrain:
			_report_dist("  (a)每一格起算→最近[%s]" % tr3, dist_by_terrain[tr3].values())

		# (b) 從每支隊當下位置起算
		var team_dists: Dictionary = {}   # terrain -> Array[dist at team positions]
		for tr4 in dist_by_terrain: team_dists[tr4] = []
		for tid2 in state.teams:
			var team: TeamData = state.teams[tid2]
			var tile_id: int = team.tile_pos.x * 1000 + team.tile_pos.y
			for tr5 in dist_by_terrain:
				var dmap: Dictionary = dist_by_terrain[tr5]
				if dmap.has(tile_id):
					(team_dists[tr5] as Array).append(int(dmap[tile_id]))
		for tr6 in team_dists:
			_report_dist("  (b)每支隊當下位置起算→最近[%s](母體=%d隊)" % [tr6, state.teams.size()], team_dists[tr6])

		# ③逐資源拆
		print("③逐資源拆(真相源見檔頭註解)：")
		if dist_by_terrain.has("plains"):
			_report_dist("  食物(REGEN_RATE最高地形=plains, resource_system.gd:56)→", dist_by_terrain["plains"].values())
		else:
			print("  食物：★本圖無plains——不可判")
		if dist_by_terrain.has("forest"):
			_report_dist("  材料(REGEN_RATE最高地形=forest, resource_system.gd:57)→", dist_by_terrain["forest"].values())
		else:
			print("  材料：★本圖無forest——不可判")
		var ore_tiles: Array = []
		for tid3 in tiles:
			var t3: HexTileData = tiles[tid3]
			if float(t3.resources.get("ore_gold", 0)) > 0.0: ore_tiles.append(tid3)
		print("  礦(ore_gold真實帶量的tile，非全部mountain——world_generator.gd:92-94 mountain×12%%機率)：")
		print("    帶ore_gold的tile數=%d/%d(%.2f%%)" % [ore_tiles.size(), n, 100.0 * float(ore_tiles.size()) / float(n)])
		if ore_tiles.is_empty():
			print("    ★本圖零ore_gold tile——距離不可判(母體=0)")
		else:
			var ore_dist: Dictionary = _bfs_multi_source(state, ore_tiles)
			_report_dist("    到最近ore_gold→", ore_dist.values())
			var mountain_pct: float = 100.0 * float(terrain_count.get("mountain", 0)) / float(n)
			var ore_pct: float = 100.0 * float(ore_tiles.size()) / float(n)
			print("    ★礦是否最稀：mountain佔%.1f%% vs 帶ore_gold佔%.2f%% ⇒ %s" % [
				mountain_pct, ore_pct,
				"礦確實比其所在地形本身稀得多(符合預期)" if ore_pct < mountain_pct else "★發現：礦不比mountain本身稀，值得標出"])
	else:
		# ④對照只要精簡：各terrain (a)母體的 p50/p90 + >5格比例
		for tr7 in dist_by_terrain:
			var vals: Array = dist_by_terrain[tr7].values()
			vals.sort()
			var nv: int = vals.size()
			if nv == 0: continue
			var over: int = 0
			for v in vals:
				if int(v) > FAR_THRESHOLD: over += 1
			print("  [%s] 母體=%d p50=%d p90=%d max=%d >%d格比例=%.2f%%" % [
				tr7, nv, vals[nv / 2], vals[int(float(nv) * 0.9)], vals[nv - 1], FAR_THRESHOLD,
				100.0 * float(over) / float(nv)])

func _tiles_of_terrain(tiles: Dictionary, terrain: String) -> Array:
	var out: Array = []
	for tid in tiles:
		if (tiles[tid] as HexTileData).terrain == terrain: out.append(tid)
	return out

# 多源BFS：從seed_ids集合同時展開，回傳 {tile_id: 最短hex距離}。O(N)。
func _bfs_multi_source(state: WorldState, seed_ids: Array) -> Dictionary:
	var dist: Dictionary = {}
	var queue: Array = []
	for sid in seed_ids:
		dist[sid] = 0
		queue.append(sid)
	var head: int = 0
	while head < queue.size():
		var cur_id = queue[head]; head += 1
		var cur_tile: HexTileData = state.world.tiles[cur_id]
		var cur_d: int = dist[cur_id]
		for dir in HEX_DIRS:
			var npos: Vector2i = cur_tile.tile_pos + dir
			var nid: int = npos.x * 1000 + npos.y
			if not state.world.tiles.has(nid): continue
			if dist.has(nid): continue
			dist[nid] = cur_d + 1
			queue.append(nid)
	return dist

func _report_dist(label: String, vals_in: Array) -> void:
	var vals: Array = vals_in.duplicate()
	if vals.is_empty():
		print("%s ★母體=0——不可判" % label)
		return
	vals.sort()
	var n: int = vals.size()
	var over: int = 0
	for v in vals:
		if int(v) > FAR_THRESHOLD: over += 1
	print("%s 母體=%d min=%d p50=%d p90=%d max=%d　>%d格比例=%.2f%%(★操作定義非世界性質)" % [
		label, n, vals[0], vals[n / 2], vals[int(float(n) * 0.9)], vals[n - 1], FAR_THRESHOLD,
		100.0 * float(over) / float(n)])
