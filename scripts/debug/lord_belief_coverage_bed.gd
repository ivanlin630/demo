extends SceneTree
# lord_belief_coverage_bed：領主對自家居民的 belief 覆蓋率（systems 2026-09-09 派票）。
# ★母體＝配對(領主隊,自家居民隊)，不是隊數：
#   領主 = team.parent_team_id==-1 且 faction_id!=-1 且該faction.leader_team_id==自己
#   （leader_team_id 只在 game_setup.gd:506 賦值一次，全程不重派——領主結構從tick0就穩，
#     真正需要時間長出來的是【居民】：outpost 要蓋出來 is_resident_static 才會=true）
#   居民 = FactionAISystem.is_resident_static(state, resident) 且 resident.faction_id==領主的faction_id
# ★狀態量，不猜單一「穩定點」——多時間點快照(10/20/30/45/60天)讓趨勢自己說話：
#   若60天仍在漲，代表居民結構還沒真的穩，讀者自己判要不要信最後一點。
# 覆蓋率＝有 belief 記錄(該配對任一 claim 帶 population_est 欄)的配對數 / 配對總數。
# 新鮮度用「帶 population_est 那筆 claim 的 tick」(非 value.last_tick，那個是位置專用時戳)。
# 偏差＝population_est vs resident.population 真值——★量測讀真值可以，但決策端不准這樣讀
#   （見 goal_resolver.gd:321-327：DISTRIB_RELIEF_REF_POP=5.0 就是因為決策端被禁止讀真值）。
# 用法：BED_CONFIG(default warring_states.json) BED_SEED(default 1337)

const SNAPSHOT_DAYS: Array = [10, 20, 30, 45, 60]

func _initialize() -> void:
	_run(); quit()

func _run() -> void:
	var cfg: String = OS.get_environment("BED_CONFIG") if OS.has_environment("BED_CONFIG") else "res://config/warring_states.json"
	var seed_val: int = int(OS.get_environment("BED_SEED")) if OS.has_environment("BED_SEED") else 1337
	seed(seed_val)
	Probe.arm()
	var state: WorldState = MeasureBedHelper.arm_and_setup(cfg, true)
	var runner := SimRunner.new()
	var no_player := Vector2i(-1, -1)

	var snapshot_ticks: Array = []
	for d in SNAPSHOT_DAYS: snapshot_ticks.append(int(d) * WorldState.TICKS_PER_DAY)
	var max_tick: int = snapshot_ticks[snapshot_ticks.size() - 1]

	print("=== lord_belief_coverage_bed: config=%s seed=%d snapshot_days=%s ===" % [cfg, seed_val, str(SNAPSHOT_DAYS)])

	var si: int = 0
	for tick in range(max_tick + 1):
		if si < snapshot_ticks.size() and tick == snapshot_ticks[si]:
			_snapshot(state, int(SNAPSHOT_DAYS[si]), tick)
			si += 1
		runner.advance_tick(state, no_player)
		if tick % 10000 == 0 and tick > 0:
			print("[CHECKPOINT] tick=%d teams=%d" % [tick, state.teams.size()])

	print("=== lord_belief_coverage_bed DONE ===")

func _snapshot(state: WorldState, day: int, tick: int) -> void:
	# ★母體先報：逐 faction 蒐集領主/居民，配對＝分子分母的真正單位。
	var lords: Array = []
	for tid in state.teams:
		var t: TeamData = state.teams[tid]
		if t.parent_team_id != -1 or t.faction_id == -1: continue
		var f = state.factions.get(t.faction_id)
		if f == null or f.leader_team_id != t.team_id: continue
		lords.append(t)

	print("\n--- [SNAPSHOT day=%d tick=%d] ---" % [day, tick])
	print("母體：領主(faction leader)隊數=%d" % lords.size())
	if lords.is_empty():
		print("  ★母體=0——這個時間點還沒有任何領主結構可量(不應發生，leader_team_id於game_setup即賦值)")
		return

	var total_pairs: int = 0
	var total_covered: int = 0
	var age_days: Array = []      # 有記錄的那些，population_est 那筆 claim 的新鮮度(天)
	var rel_errs: Array = []      # population_est vs 真值 相對誤差
	var per_faction: Dictionary = {}   # faction_id -> {pairs, covered}

	for lord in lords:
		var residents: Array = []
		for tid2 in state.teams:
			var r: TeamData = state.teams[tid2]
			if r.team_id == lord.team_id: continue
			if r.faction_id != lord.faction_id: continue
			if FactionAISystem.is_resident_static(state, r): residents.append(r)

		if not per_faction.has(lord.faction_id):
			per_faction[lord.faction_id] = {"pairs": 0, "covered": 0, "lord_id": lord.team_id}
		var pf: Dictionary = per_faction[lord.faction_id]

		for resident in residents:
			total_pairs += 1
			pf["pairs"] = int(pf["pairs"]) + 1
			var claims_arr: Array = BeliefSystem.claims(state, lord.team_id, resident.team_id)
			var freshest_tick: int = -1
			var freshest_pop_est: float = 0.0
			for c in claims_arr:
				var v: Dictionary = c["value"]
				if v.has("population_est") and int(c["tick"]) > freshest_tick:
					freshest_tick = int(c["tick"])
					freshest_pop_est = float(v["population_est"])
			if freshest_tick >= 0:
				total_covered += 1
				pf["covered"] = int(pf["covered"]) + 1
				var age: float = float(tick - freshest_tick) / float(WorldState.TICKS_PER_DAY)
				age_days.append(age)
				var truth: float = float(resident.population)
				rel_errs.append((freshest_pop_est - truth) / maxf(truth, 1.0))

	print("母體：配對(領主×自家居民)總數=%d" % total_pairs)
	if total_pairs == 0:
		print("  ★母體=0——這個時間點還沒有任何『居民』出現(outpost 還沒蓋出來)，不可判覆蓋率")
		return

	print("①覆蓋率＝%d / %d = %.1f%%" % [total_covered, total_pairs, 100.0 * float(total_covered) / float(total_pairs)])

	if age_days.is_empty():
		print("②新鮮度：★不可判——0筆有記錄")
	else:
		age_days.sort()
		var na: int = age_days.size()
		print("②新鮮度(天，越小越新)：min=%.2f p50=%.2f max=%.2f" % [age_days[0], age_days[na / 2], age_days[na - 1]])

	if rel_errs.is_empty():
		print("③偏差：★不可判——0筆有記錄　　★★以下讀真值只為量測對帳，決策端禁止這樣讀")
	else:
		rel_errs.sort()
		var ne: int = rel_errs.size()
		print("③偏差(population_est vs 真population，相對誤差)：min=%.2f p50=%.2f max=%.2f　　★★以下讀真值只為量測對帳，決策端禁止這樣讀" % [
			rel_errs[0], rel_errs[ne / 2], rel_errs[ne - 1]])

	print("④逐 faction 分布(覆蓋率不是單一數字，一個100%%+四個0%%平均會騙人)：")
	for fid in per_faction:
		var pf2: Dictionary = per_faction[fid]
		var p: int = int(pf2["pairs"])
		var c2: int = int(pf2["covered"])
		var pct: float = 100.0 * float(c2) / float(p) if p > 0 else -1.0
		if p > 0:
			print("  faction=%s lord=Team%d 配對=%d 覆蓋=%d(%.1f%%)" % [str(fid), int(pf2["lord_id"]), p, c2, pct])
		else:
			print("  faction=%s lord=Team%d 配對=0(該faction目前無居民)" % [str(fid), int(pf2["lord_id"])])

	# ⑤一魚兩吃判別：低覆蓋是「沒接到」還是「接了被清掉」——看新鮮度分布。
	if total_covered < total_pairs and not age_days.is_empty():
		var na2: int = age_days.size()
		var p50: float = age_days[na2 / 2]
		if p50 < 3.0:
			print("⑤判別：有記錄的普遍很新(p50<3天) ⇒ 比較像【只有少數配對曾經產生過belief】(缺產生路徑)")
		else:
			print("⑤判別：有記錄的普遍偏舊(p50>=3天) ⇒ 比較像【prune沒發生但也沒更新】(非TTL過兇，是沒有新事件觸發重寫)")
