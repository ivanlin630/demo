extends SceneTree

# ④ 完整食物收支 bed（time-scale wave A2 前置，純唯讀 measure，零 production 侵入）。
# 藍圖 a2-food-recalib-amendment：×5→1 前量清食物收支,揪手校值,據表裁補給/承載力。
# 現行 A1=×5（MOVE=48）→ 本 bed 量 ×5 觀測值 + ×1 投影（食物 per-day 率速度無關,只旅途天數×5）。
#
# 量三塊（藍圖）：
#   ① 駐紮隊 生產/消耗/淨值 → 承載力（餓死潮? 爆倉?）——net=food_flow_avg,速度無關=×1 同值
#   ② 行軍隊 旅途糧耗/carry/淨值 → 走遠路撐幾格——journey dist×pop×0.8,×1=5× ×5
#   ③ 手校值清單 → 哪些 ×1 假設錯
#
# 用法（env）：FL_SEEDS(default "1337,2674") / FL_MONTHS(6)

const FOOD_PER_PERSON_PER_DAY: float = 0.8   # 鏡 resource_system:3（消耗率,per-day 速度無關）
const PROVISION_DAYS: int = 10               # 鏡 resource_system:9（乾糧 buffer 天數）

func _initialize() -> void:
	_run(); quit()

func _run() -> void:
	var seeds: Array = _parse_seeds()
	var months: int = int(OS.get_environment("FL_MONTHS")) if OS.has_environment("FL_MONTHS") else 6
	var total_ticks: int = maxi(months, 1) * WorldState.TICKS_PER_MONTH
	print("=== food_ledger_bed：seeds=%s months=%d（A1 ×5 觀測 + ×1 投影）===" % [str(seeds), months])
	print("手校值清單（×1 下疑假設錯）：FOOD_PER_PERSON_PER_DAY=0.8(÷24痕) / FATIGUE_*_PER_DAY(×24痕) / PROVISION_DAYS=10(乾糧) / FORAGE_FLOOR_DAYS=1.5 / tile regen·harvest(生產①)")

	for world_seed in seeds:
		_run_one(world_seed, total_ticks)

func _run_one(world_seed: int, total_ticks: int) -> void:
	seed(world_seed)
	var state := WorldState.new()
	var runner := SimRunner.new()
	var config: Dictionary = GameSetup.load_config("res://config/warring_states.json")
	if config.is_empty():
		print("[FAIL] config"); return
	config["seed"] = world_seed
	GameSetup.setup(state, config)
	state.player_id = -1
	var no_player := Vector2i(-1, -1)

	# 月末取樣累積
	var settled_net: Array = []      # 駐紮隊 food_flow_avg（淨值/天）
	var settled_famine: Array = []   # 駐紮隊 famine_days
	var march_dist: Array = []       # 行軍隊 旅途 hex 距（pos→move_target）
	var march_carry_days: Array = [] # 行軍隊 carry 食可撐幾天（food / (pop×0.8)）
	var months_sampled: int = 0

	for tick in range(total_ticks):
		runner.advance_tick(state, no_player)
		if state.encounter_active and state.encounter_tick > 800:
			runner._encounter_system.resolve_encounter_end(state, "draw")
		if (tick + 1) % WorldState.TICKS_PER_MONTH == 0:
			months_sampled += 1
			for tid in state.teams:
				var t: TeamData = state.teams[tid]
				var pop: int = t.population
				if pop <= 0: continue
				var moving: bool = t.move_target != Vector2i(-1, -1) and t.move_target != t.tile_pos
				if moving:
					var d: int = _hex_dist(t.tile_pos, t.move_target)
					march_dist.append(d)
					var food: float = float(t.resources.get("food", 0))
					march_carry_days.append(food / maxf(pop * FOOD_PER_PERSON_PER_DAY, 0.01))
				else:
					settled_net.append(t.food_flow_avg)
					settled_famine.append(t.famine_days)
		if state.teams.is_empty(): break

	_report(world_seed, months_sampled, settled_net, settled_famine, march_dist, march_carry_days)

func _report(s: int, mo: int, s_net: Array, s_fam: Array, m_dist: Array, m_carry: Array) -> void:
	print("\n────────── [食物收支] seed=%d（%d 月取樣）──────────" % [s, mo])
	# ① 駐紮隊 承載力
	if s_net.is_empty():
		print("① 駐紮隊：無取樣")
	else:
		var neg: int = 0
		for v in s_net: if float(v) < 0.0: neg += 1
		var fam: int = 0
		for v in s_fam: if float(v) > 0.0: fam += 1
		print("① 駐紮隊 承載力（net=生產−消耗,速度無關=×1 同值）：樣本=%d 負流=%.0f%% 中位net=%.2f/天 斷糧中=%.0f%%" % [
			s_net.size(), 100.0 * neg / s_net.size(), _median(s_net), 100.0 * fam / s_fam.size()])
		print("   → 承載力判讀：負流高=餓死潮風險 / net 遠>0=爆倉風險（駐紮側 A2 gen 承載力校對象）")
	# ② 行軍隊 旅途
	if m_dist.is_empty():
		print("② 行軍隊：無取樣（=移動癱? far 稀釋令隊幾乎不動→B 修後重量）")
	else:
		var over_carry: int = 0
		# ×1 下：旅途 d 格 = d 天糧耗；carry 撐 c 天 → d>c 斷糧
		for i in range(m_dist.size()):
			var d_x1: float = float(m_dist[i])   # ×1：1 天/格
			if d_x1 > float(m_carry[i]): over_carry += 1
		print("② 行軍隊 旅途（×1 投影：1天/格）：樣本=%d 中位距=%.0f格 中位carry=%.1f天 ×1斷糧率=%.0f%%（旅途>carry）" % [
			m_dist.size(), _median(m_dist), _median(m_carry), 100.0 * over_carry / m_dist.size()])
		print("   → ×1 每格糧耗 5× ×5;乾糧 PROVISION_DAYS=10=10格;>10格founding/trade斷糧（=A2沿途補給對象）")
	print("   ★caveat：A1=×5 下 far 移速稀釋(B未修)→行軍樣本可能偏少/偏近;B merge 後重量更準。")

func _parse_seeds() -> Array:
	var raw: String = OS.get_environment("FL_SEEDS") if OS.has_environment("FL_SEEDS") else "1337,2674"
	var out: Array = []
	for t in raw.split(",", false):
		if t.strip_edges().is_valid_int(): out.append(int(t.strip_edges()))
	return out

func _hex_dist(a: Vector2i, b: Vector2i) -> int:
	var dx: int = b.x - a.x
	var dy: int = b.y - a.y
	return (abs(dx) + abs(dx + dy) + abs(dy)) / 2

func _median(arr: Array) -> float:
	if arr.is_empty(): return 0.0
	var s: Array = arr.duplicate(); s.sort()
	return float(s[s.size() / 2])
