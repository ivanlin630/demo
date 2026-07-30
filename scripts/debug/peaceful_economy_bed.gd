extends SceneTree

# ──────────────────────────────────────────────────────────────────────────
# 和平經濟觀測床（measure-first Step0，HOW spec 2026-07-30）。
# 目的：seeded/和平/有缺口驅動的床，看得見經濟行為（warring 床被戰爭吃掉立國/發展時間）。
# 量 4 問（founding / develop / trade / runway 是否 fire）→ 資料回 blueprint 裁分支。
# ★零 sim-code 改（純讀+print）。★非 @observe-pure：bed 是 runner，呼 seed() 跑自己的世界（合法世界設置，
#   非觀測擾動）→ determinism 由 seeded 保證（非零 RNG）。observability_gate ③ 只納嵌入式觀測 helper
#   （specimen_dump_helper/tracer），bed 不加 marker（seed() 會被 ③ 正確 FAIL；[[feedback_observer_no_global_rng]]）。
#
# 流程：
#   1. t0 fixture-liveness 斷言（每 ①/③料窮側 need_keep(material)>0 + ①有 forest 靶）→ 死路則拒開工。
#   2. WarringHarness.run(SEED, 6mo, config) → 權威 4 問 probe dump（reuse PROBE_KEYS tap）。
#   3. 第二次 seeded inline run（同世界）→ 逐隊月故事（task/resources/gap-status，模 econ_bed_diagnose）。

const CONFIG_PATH := "res://config/peaceful_economy.json"
const SEED: int = 70730
const MONTHS: int = 6
const MATERIAL_LIVE_TEAMS: Array = [0, 1, 2, 6]   # ①founding + ③料窮側
const FOUNDING_TEAMS: Array = [0, 1, 2]

func _initialize() -> void:
	print("=== 和平經濟觀測床（measure-first Step0）seed=%d %d月 ===" % [SEED, MONTHS])
	if not _liveness_ok():
		print("=== ABORT：fixture 死路，拒開工（修 config 使 need_keep(material)>0 + forest 靶存在）===")
		quit(); return

	var ticks: int = WorldState.TICKS_PER_MONTH * MONTHS
	# ── 權威 4 問 dump（reuse WarringHarness runner + PROBE_KEYS tap）──
	var result: Dictionary = WarringHarness.run(SEED, ticks, CONFIG_PATH)
	if result.is_empty():
		print("[FAIL] WarringHarness.run 回空（config 載入失敗）"); quit(); return
	_print_four_questions(result)

	# ── 逐隊月故事（同 seed inline run，QA 稽核用）──
	_print_team_stories(ticks)

	# ── ★T0 fed 隊 per-option util 明細（instrumented dump，定 economy 決策真 binding）──
	_dump_peroption_util()

	print("=== 和平經濟觀測床 DONE ===")
	quit()

# ★一次性 per-option util dump（純觀測零行為變零 RNG）：選 fed 隊 T0(runway=9999,material 缺)在幾個 decide tick，
# 印 DecisionEngine.rank_scored 全 option util 排序（靜態 23 + goal frontier candidates）+ 標 winner
# + goal candidate 分項(payoff/dev_coeff/discount，goal_resolver:354-360)——看哪項壓下 economy goal util。
# 分項用 bed-side 重建（呼可 call 的 static GoalResolver._discount_rate/_estimate_delay_days + ctx），零 sim 改。
func _dump_peroption_util() -> void:
	print("\n───────── ★T0 fed 隊 per-option util 明細（economy 決策真 binding）─────────")
	seed(SEED)
	FactionAISystem._a2b_remote_tribute_payers.clear()
	var state := WorldState.new()
	var runner := SimRunner.new()
	var config: Dictionary = GameSetup.load_config(CONFIG_PATH)
	config["seed"] = SEED
	GameSetup.setup(state, config)
	var no_player := Vector2i(-1, -1)
	var sample_ticks: Array = [500, 3600, 7200]   # 早/半月/月1（fed 隊穩態、material need 仍>0）
	var si: int = 0
	# ★賣方 delivery 追蹤（Team3 material=400 surplus 掛 sell material×335）：
	#   跨全 run 追 task=TASK_TRADE 是否 fire、tile_pos 是否離家去市場、material 是否離 inventory（賣掉/deposit）。
	var t3_start: TeamData = state.teams.get(3)
	var t3_start_pos: Vector2i = t3_start.tile_pos if t3_start != null else Vector2i(-999, -999)
	var t3_start_mat: float = float(t3_start.resources.get("material", 0)) if t3_start != null else 0.0
	var t3_ever_trade: bool = false
	var t3_ever_moved: bool = false
	var t3_min_mat: float = t3_start_mat
	for tick in range(7201):
		runner.advance_tick(state, no_player)
		if state.encounter_active and state.encounter_tick > 800:
			runner._encounter_system.resolve_encounter_end(state, "draw")
		var t3: TeamData = state.teams.get(3)
		if t3 != null:
			if t3.current_task == TeamData.TASK_TRADE: t3_ever_trade = true
			if t3.tile_pos != t3_start_pos: t3_ever_moved = true
			t3_min_mat = minf(t3_min_mat, float(t3.resources.get("material", 0)))
		if si < sample_ticks.size() and (tick + 1) == int(sample_ticks[si]):
			_dump_team_at(state, 0, tick + 1)   # 買方
			_dump_team_at(state, 3, tick + 1)   # 賣方
			si += 1
	# ★賣方 delivery 行為總結（定 GATE-B gap:(a)不 decide 去賣 vs (b)decide 了空間到不了）
	var t3e: TeamData = state.teams.get(3)
	print("\n  ── ★Team3 賣方 delivery 行為（全 run 追蹤）──")
	if t3e != null:
		print("    起 pos=%s 終 pos=%s ever_moved=%s | ever_TASK_TRADE=%s | material 起=%.0f 終=%.0f 最低=%.0f(離 inventory?%s)" % [
			str(t3_start_pos), str(t3e.tile_pos), str(t3_ever_moved), str(t3_ever_trade),
			t3_start_mat, float(t3e.resources.get("material", 0)), t3_min_mat,
			"是" if t3_min_mat < t3_start_mat - 1.0 else "否(留家)"])
		var otile: HexTileData = state.world.tiles.get(t3e.tile_pos.x * 1000 + t3e.tile_pos.y)
		if otile != null:
			print("    Team3 tile public_storage material=%.0f（賣單 material 有無 deposit 到市場 granary）" % float(otile.public_storage.get("material", 0)))
	else:
		print("    Team3 死/併")

func _dump_team_at(state: WorldState, tid: int, tick: int) -> void:
	var t0: TeamData = state.teams.get(tid)
	if t0 == null:
		print("  tick %d: T%d 死/併" % [tick, tid]); return
	var ctx: DecisionContext = DecisionContext.gather(state, t0)
	var scored: Array = DecisionEngine.rank_scored(state, t0)
	var lv: Dictionary = TradeValuation.leader_vals(state, t0)
	var need_mat: float = NeedOracle.need_keep(state, t0, "material", lv)
	print("  === tick %d T%d[%s] task=%s pos=%s move_tgt=%s food=%.0f mat=%.0f coin=%.0f runway=%.1f food_days=%.2f need_mat=%.0f ===" % [
		tick, tid, _terr(state, t0), t0.current_task, str(t0.tile_pos), str(t0.move_target),
		float(t0.resources.get("food", 0)),
		float(t0.resources.get("material", 0)), float(t0.resources.get("coin", 0)),
		t0.food_runway, ctx.food_days, need_mat])
	# 全 option util 排序（標 winner + static/goal）
	for i in range(scored.size()):
		var e: Dictionary = scored[i]
		var tag: String = "[goal]  " if e.has("cand") else "[static]"
		var mark: String = "  <=WIN" if i == 0 else ""
		print("    %s u=%+.4f  %s%s" % [tag, float(e["u"]), String(e["opt"]), mark])
	# goal candidate 分項（哪項壓 economy util）
	var dev_coeff: float = clampf(ctx.food_days / DecisionTerms.DESPERATION_DAYS, 0.0, 1.0)
	var rate: float = GoalResolver._discount_rate(ctx)
	for e in scored:
		if not e.has("cand"):
			continue
		var cand: Dictionary = e["cand"]
		var delay: float = GoalResolver._estimate_delay_days(t0, cand.get("to_task", {}))
		var discount: float = 1.0 / (1.0 + rate * maxf(delay, 0.0))
		var denom: float = dev_coeff * discount
		var u: float = float(e["u"])
		var clamped: bool = u >= GoalResolver.GOAL_UTIL_CAP - 0.0001
		var implied_payoff: float = (u / denom) if denom > 0.0 else -1.0
		print("      分項 [%s]: util=%.4f = payoff≈%.3f × dev_coeff=%.3f × discount=%.3f (rate=%.3f delay=%.1fd) cap=%.2f%s" % [
			String(e["opt"]), u, implied_payoff, dev_coeff, discount, rate, delay,
			GoalResolver.GOAL_UTIL_CAP, "  ★CLAMPED(payoff≥推算)" if clamped else ""])

func _terr(state: WorldState, t: TeamData) -> String:
	var tile: HexTileData = state.world.tiles.get(t.tile_pos.x * 1000 + t.tile_pos.y)
	return tile.terrain if tile != null else "?"

# ── t0 fixture-liveness（機械防死 fixture）──
func _liveness_ok() -> bool:
	var state := WorldState.new()
	var config: Dictionary = GameSetup.load_config(CONFIG_PATH)
	if config.is_empty():
		return false
	config["seed"] = SEED
	GameSetup.setup(state, config)
	var ok: bool = true
	var fai := FactionAISystem.new()
	for tid in MATERIAL_LIVE_TEAMS:
		var team: TeamData = state.teams.get(tid)
		if team == null:
			print("[liveness] FAIL T%d 不存在" % tid); ok = false; continue
		var lv: Dictionary = TradeValuation.leader_vals(state, team)
		if NeedOracle.need_keep(state, team, "material", lv) <= 0.0:
			print("[liveness] FAIL T%d need_keep(material)=0=因果死路" % tid); ok = false
	for tid in FOUNDING_TEAMS:
		var team2: TeamData = state.teams.get(tid)
		if team2 == null: continue
		if not _has_unowned_forest_in_seek(state, team2, fai):
			print("[liveness] FAIL T%d 無 unowned forest 靶在 seek 內" % tid); ok = false
	if ok:
		print("[liveness] PASS：①/③料窮側 need_keep(material)>0 + ①有 forest 靶（fixture LIVE）")
	return ok

func _has_unowned_forest_in_seek(state: WorldState, team: TeamData, fai: FactionAISystem) -> bool:
	for wtid in state.world.tiles:
		var t: HexTileData = state.world.tiles[wtid]
		if t.terrain != "forest" or t.outpost_owner != -1 or t.tile_pos == team.tile_pos:
			continue
		if fai._hex_dist(team.tile_pos, t.tile_pos) <= GoalResolver.SEEK_TILE_RANGE:
			return true
	return false

# ── 4 問報告（從 harness probe subset）──
func _print_four_questions(result: Dictionary) -> void:
	var p: Dictionary = result.get("probe", {})
	print("\n───────── 4 問報告（%d tick, end_pop=%d, attrition=%.1f%%, teams=%d）─────────" % [
		int(result.get("total_ticks", 0)), int(result.get("end_pop", 0)),
		float(result.get("attrition_pct", 0.0)),
		int(result.get("final", {}).get("teams", 0))])

	print("【Q1 founding dispatch 嗎】（gate funnel 分：動機無 vs 卡 gate）")
	_pl(p, ["indep.found_ally", "indep.found_subjugate", "indep.found_timeout"])
	_pl(p, ["indep.gate_ambitious", "indep.gate_path_ok"])
	_pl(p, ["indep.gate_fail_pop", "indep.gate_fail_food", "indep.gate_fail_busy", "indep.gate_fail_nopath"])
	_pl(p, ["construct.start", "construct.start_task_not_build", "construct.complete_build", "worldgen.build_outpost"])
	# ★construction pipeline 拉走機制（complete_build=0 vs upgrade_facility>0：remote founding 子隊完工前被拉走）
	_pl(p, ["construct.progress", "construct.stall", "construct.timeout_cancel", "construct.complete"])
	_pl(p, ["resume.attempt", "resume.success", "resume.reject_combat", "resume.reject_starving", "resume.reject_busy"])

	print("【Q2 develop（升級）嗎】")
	_pl(p, ["construct.complete_upgrade_facility", "construct.complete_upgrade_level"])

	print("【Q3 貿易/對缺口反應嗎】")
	_pl(p, ["trade.deal", "trade.deal_market", "trade.deal_merchant", "trade.barter_deal"])
	_pl(p, ["g1.order_placed", "g1.order_fulfilled", "g1.shortage_buy", "g1.food_buy"])
	# seek→arrive→fill funnel（三段落差看卡哪層）
	_pl(p, ["g1.seek_market", "g1.market_arrive", "trade.arrive", "trade.meet", "trade.timeout"])
	# ★market_bail 分因（pin GATE-B co-location 失敗 sub-gap：賣方不去賣 vs 買方抵達空 granary）——讀 Probe.counts
	#   （多數 bail key 不在 PROBE_KEYS subset；run() 後 Probe.counts 未 reset=本 run 數完整）。
	print("  --market_bail 賣方端--")
	_plc(["trade.market_bail.sell_no_surplus", "trade.market_bail.sell_ownerless",
		"trade.market_bail.sell_no_price", "trade.market_bail.sell_zero_qty",
		"trade.market_bail.sell_storage_full", "trade.market_bail.sell_owner_no_coin",
		"trade.market_bail.sell_owner_cant_afford", "trade.market_bail.no_board_order"])
	print("  --market_bail 買方端--")
	_plc(["trade.market_bail.buy_no_stock", "trade.market_bail.buy_no_want",
		"trade.market_bail.buy_cant_afford", "trade.market_bail.buy_carry_full",
		"trade.market_bail.buy_no_coin", "trade.market_bail.buy_no_price",
		"trade.market_bail.buy_withdraw_empty"])

	print("【Q4 runway 機制 fire 嗎】")
	_pl(p, ["foodflow.update", "bridge.no_go_food", "bridge.topup", "persist.hold"])

	print("【★後勤 SLICE A：convoy delivery（GATE-B 撮合物理送貨）】")
	_pl(p, ["convoy.dispatch", "convoy.fetch", "convoy.deliver", "convoy.return"])
	print("  cargo_out=%.0f cargo_delivered=%.0f | ★order_fulfilled=%d(驗收②) trade.deal=%d" % [
		result.get("probe_amounts", {}).get("convoy.cargo_out", 0.0),
		result.get("probe_amounts", {}).get("convoy.cargo_delivered", 0.0),
		int(p.get("g1.order_fulfilled", 0)), int(p.get("trade.deal", 0))])

	# ★construct pipeline sample payload（why 欄：施工隊被搶時 current_task 變啥 ct_task + 誰搶 ct_reason）
	_print_construct_samples(result)

# construct.* sample payload dump（result["probe_samples"] 已含 CONSTRUCT_SAMPLE_KEYS；純多印既有 data）
func _print_construct_samples(result: Dictionary) -> void:
	var samples: Dictionary = result.get("probe_samples", {})
	print("\n───────── construct sample payload（pin 拉走機制：ct_task/ct_reason）─────────")
	if samples.is_empty():
		print("  （無 sample；construct pipeline 未觸發）"); return
	for key in ["construct.start", "construct.stall", "construct.progress",
			"construct.complete", "construct.timeout_cancel", "resume.attempt", "resume.success"]:
		var arr: Array = samples.get(key, [])
		if arr.is_empty():
			continue
		print("  [%s] n=%d（前 12 筆）:" % [key, arr.size()])
		var lim: int = mini(arr.size(), 12)
		for i in range(lim):
			print("    " + _fmt_sample(arr[i]))

func _fmt_sample(s: Dictionary) -> String:
	var parts: Array = []
	# 依序印關鍵 why 欄（存在才印）
	for k in ["tick", "tile", "team", "ct_id", "action", "task_after", "prio_after",
			"ct_task", "ct_reason", "ct_pos", "ticks_left", "active", "pop"]:
		if s.has(k):
			parts.append("%s=%s" % [k, str(s[k])])
	return " ".join(parts)

# print 一行 probe key 值
func _pl(p: Dictionary, keys: Array) -> void:
	var parts: Array = []
	for k in keys:
		parts.append("%s=%d" % [k, int(p.get(k, 0))])
	print("  " + " | ".join(parts))

# print 一行 Probe.counts key 值（PROBE_KEYS subset 外的 key；run() 後 counts 未 reset=本 run 完整）
func _plc(keys: Array) -> void:
	var parts: Array = []
	for k in keys:
		parts.append("%s=%d" % [k, int(Probe.counts.get(k, 0))])
	print("  " + " | ".join(parts))

# ── 逐隊月故事（同 seed inline run）──
func _print_team_stories(ticks: int) -> void:
	print("\n───────── 逐隊月故事（同 seed inline run）─────────")
	seed(SEED)
	FactionAISystem._a2b_remote_tribute_payers.clear()   # ★R²:對齊 WarringHarness.run:119(A2b 貢賦 ledger 每 run 重置)——雙 run 防跨 run 殘留污染
	var state := WorldState.new()
	var runner := SimRunner.new()
	var config: Dictionary = GameSetup.load_config(CONFIG_PATH)
	config["seed"] = SEED
	GameSetup.setup(state, config)
	var tracked: Array = state.teams.keys()
	tracked.sort()
	var no_player := Vector2i(-1, -1)   # all-far（match harness LOD：team-strategic 照跑）

	print("--- t0 ---")
	for tid in tracked: print("  " + _line(state, tid))

	var per_month: int = WorldState.TICKS_PER_MONTH
	var month: int = 0
	for tick in range(ticks):
		runner.advance_tick(state, no_player)
		if state.encounter_active and state.encounter_tick > 800:
			runner._encounter_system.resolve_encounter_end(state, "draw")
		if (tick + 1) % per_month == 0:
			month += 1
			print("--- 月%d ---" % month)
			for tid in tracked:
				if state.teams.has(tid): print("  " + _line(state, tid))

func _line(state: WorldState, tid: int) -> String:
	var t: TeamData = state.teams.get(tid)
	if t == null:
		return "T%d: 死/併" % tid
	var tile: HexTileData = state.world.tiles.get(t.tile_pos.x * 1000 + t.tile_pos.y)
	var terr: String = tile.terrain if tile != null else "?"
	var food: float = float(t.resources.get("food", 0))
	var mat: float = float(t.resources.get("material", 0))
	var coin: float = float(t.resources.get("coin", 0))
	var lv: Dictionary = TradeValuation.leader_vals(state, t)
	var need_mat: float = NeedOracle.need_keep(state, t, "material", lv)
	return "T%d[%s] pop=%d task=%s food=%.0f mat=%.0f coin=%.0f need_mat=%.0f runway=%.1f" % [
		tid, terr, t.population, t.current_task, food, mat, coin, need_mat, t.food_runway]
