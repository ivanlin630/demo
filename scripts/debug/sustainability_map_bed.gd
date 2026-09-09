extends SceneTree
# sustainability_map_bed：養活力地圖(上一卷「存在性距離」的量綱修正，systems 2026-09-09票)。
# ★predicate不發明，用code既有的GATE-A：decision_context.gd:641-655
#   regen = ResourceSystem.REGEN_RATE[terrain]["food"] × tile.harvest_factor
#   burn  = pop × ResourceSystem.FOOD_PER_PERSON_PER_DAY (decision_context.gd:268)
#   productive = regen >= burn
# ★tick-0快照：harvest_factor在tick-0是預設1.0(tile_data.gd:8，HarvestSystem要跑模擬才會改)，
#   所以「養不養得活」在tick-0純粹是terrain×pop的函數，不需per-tile個別算。
# ①②養活力距離：(a)每支隊當下位置起算 (b)每一格起算(用中位數隊規模當burn)
# ②規模相依：同一張圖，burn換成pop=3/10/30各跑一次——核心格。
# ③對照：radius 14/24/40看圖變大會不會讓養活力變稀(區別於上一卷「存在性不隨圖變」)。
# ④材料：查過scripts/simulation全庫，沒有material的per-person-per-day消耗率
#   (無MATERIAL_PER_PERSON/material_burn/材料日耗類常數)——如實聲明沒有，不硬造。
# ★誠實限：①不下設計結論②regen>=burn是【自給自足】定義,不涵蓋貿易/convoy/糧倉存量——
#   本卷量「這塊地自己養不養得活」,不是「這隊會不會餓死」③秒級,不是秒級先報。

const MAIN_CONFIG: String = "res://config/warring_states.json"
const SIZE_CONFIGS: Array = [
	"res://config/warring_states.json",
	"res://config/infonet_established_fragility.json",  # radius=16
	"res://config/perf_scale.json",                       # radius=24
	"res://config/infonet_recovery_r2_invest.json",       # radius=40
]
const SEEDS: Array = [1337, 2026]
const POP_SWEEP: Array = [3, 10, 30]
const FAR_THRESHOLD: int = 5
const HEX_DIRS: Array = [
	Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1),
	Vector2i(0, -1), Vector2i(1, -1), Vector2i(-1, 1),
]

func _initialize() -> void:
	_run(); quit()

func _run() -> void:
	print("=== sustainability_map_bed (tick-0 快照，GATE-A predicate: regen>=burn) ===")
	print("★材料：全庫查無per-person-per-day消耗率常數，本卷不跑材料sub-question（如實聲明，非硬造）\n")

	print("############ ①②本體+規模相依：%s ############" % MAIN_CONFIG)
	for seed_val in SEEDS:
		_analyze_one(MAIN_CONFIG, seed_val, true)

	print("\n############ ③對照：圖變大養活力會不會變稀 ############")
	for cfg in SIZE_CONFIGS:
		for seed_val in SEEDS:
			_analyze_one(cfg, seed_val, false)

	print("\n=== sustainability_map_bed DONE ===")

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
		print("  ★★成本超過秒級(>5000ms)——先報這個訊號")

	var pops_to_run: Array = POP_SWEEP.duplicate()
	# 中位數隊規模（世界結構性質那個母體用）
	var team_pops: Array = []
	for tid in state.teams: team_pops.append(int((state.teams[tid] as TeamData).population))
	team_pops.sort()
	var median_pop: int = team_pops[team_pops.size() / 2] if not team_pops.is_empty() else 0
	if full_detail and not pops_to_run.has(median_pop): pops_to_run.append(median_pop)

	for pop in pops_to_run:
		var productive_terrains: Array = []
		for tr in ["plains", "forest", "mountain"]:
			var regen: float = float(ResourceSystem.REGEN_RATE.get(tr, {}).get("food", 0.0))  # harvest_factor=1.0 at tick-0
			var burn: float = float(pop) * ResourceSystem.FOOD_PER_PERSON_PER_DAY
			if regen >= burn: productive_terrains.append(tr)
		var tag: String = " (=中位數隊規模)" if full_detail and pop == median_pop and not POP_SWEEP.has(pop) else ""
		print("  pop=%d%s：能自給自足的terrain=%s（burn=%.2f, regen[plains/forest/mountain]=%.1f/%.1f/%.1f）" % [
			pop, tag, str(productive_terrains), float(pop) * ResourceSystem.FOOD_PER_PERSON_PER_DAY,
			ResourceSystem.REGEN_RATE["plains"]["food"], ResourceSystem.REGEN_RATE["forest"]["food"], ResourceSystem.REGEN_RATE["mountain"]["food"]])

		if productive_terrains.is_empty():
			print("    ★★★無解——這張圖上沒有任何一格自己養得活pop=%d的隊，距離undefined(∞)，無解隊比例=100%%" % pop)
			continue

		var seed_ids: Array = []
		for tid2 in tiles:
			if productive_terrains.has((tiles[tid2] as HexTileData).terrain): seed_ids.append(tid2)
		var dist_map: Dictionary = _bfs_multi_source(state, seed_ids)

		if full_detail:
			# (a) 每支隊當下位置起算
			var team_dists: Array = []
			for tid3 in state.teams:
				var team: TeamData = state.teams[tid3]
				var tile_id: int = team.tile_pos.x * 1000 + team.tile_pos.y
				if dist_map.has(tile_id): team_dists.append(int(dist_map[tile_id]))
			_report_dist("    (a)每支隊當下位置起算→最近養活力(pop=%d)" % pop, team_dists, state.teams.size())
			# (b) 每一格起算
			_report_dist("    (b)每一格起算→最近養活力(pop=%d)" % pop, dist_map.values(), n)
		else:
			var vals: Array = dist_map.values()
			vals.sort()
			var nv: int = vals.size()
			if nv > 0:
				var over: int = 0
				for v in vals:
					if int(v) > FAR_THRESHOLD: over += 1
				print("    [每格起算] 有解母體=%d/%d p50=%d p90=%d max=%d >%d格比例=%.2f%%" % [
					nv, n, vals[nv / 2], vals[int(float(nv) * 0.9)], vals[nv - 1], FAR_THRESHOLD, 100.0 * float(over) / float(nv)])

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

func _report_dist(label: String, vals_in: Array, total_population: int) -> void:
	var vals: Array = vals_in.duplicate()
	if vals.is_empty():
		print("%s ★母體=0(無解，見上一行)——不可判" % label)
		return
	vals.sort()
	var n: int = vals.size()
	var over: int = 0
	for v in vals:
		if int(v) > FAR_THRESHOLD: over += 1
	var unreachable: int = total_population - n
	print("%s 有解母體=%d/%d(無解比例=%.2f%%) min=%d p50=%d p90=%d max=%d >%d格比例=%.2f%%" % [
		label, n, total_population, 100.0 * float(unreachable) / float(total_population),
		vals[0], vals[n / 2], vals[int(float(n) * 0.9)], vals[n - 1], FAR_THRESHOLD,
		100.0 * float(over) / float(n)])
