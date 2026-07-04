extends SceneTree

# trade_funnel_bed：貿易環六站漏斗 measure harness（純 debug/infra，零 sim 邏輯變）。
# 六站：張貼→收到→選中→dispatch/被誰打斷→到場→成交（spec 2026-07-04-trade-loop-ignition）。
# 探針全 Probe counter（無 randf、無 state 寫）→ 與無探針跑 RNG 流逐點同。
#
# ★常駐機器（QA 反轉三層之①②，spec Task 3）：本 bed 非一次性探針——
#   ① 矛盾率 assert：「有效想要（買單存在+供給在+對象可達）而長期未成交」比率
#      ≤ TRADE_CONTRADICTION_MAX（TEST VALUE）。非量地板：世界真無稀缺（den=0）=健康 PASS。
#   ② 常駐漏斗：六站率鏈（分子/分母=率）每跑必出——之後任何軌動到經濟，率變化回歸可見。
#   收尾印 [PASS]/[FAIL]，QA gate grep 用。
#
# 用法（env）：
#   TF_SEED    world seed（default 1337；exam2 對照另跑 2674）
#   TF_MONTHS  跑幾月（default 6）
#   TF_CONFIG  config 名（default "default" = 真產品世界）
#   TF_DIAG    =1 開商業隊 util 排名 top3（rank_scored 建 ctx 內含 randf → 擾 RNG 流，勿混 baseline）

# ①矛盾率門檻 = 常駐「回歸」baseline（非健康證書）。TEST VALUE。
# 語意兩層，別混：
#   絕對矛盾率（output 印出真值）= 病的量度：0=無矛盾健康，趨 1=有效想要全落空=貿易環死。
#   本閾 = 回歸地板：≤ 此 = 「未比今日 in-scope-maxed 狀態更壞」→ gate 綠、armed；
#          貿易環再死（timeout 秒殺回潮 → 矛盾率趨 0.95+）→ 破閾 RED。
# 2026-07-04 兩 seed 6 月實測 0.758(1337)/0.708(2674)——**現值本身仍是病**（deal_merchant=0，
# 商隊 funnel 零成交，殘因=域外 LOD 移速稀釋 + carrier 存在性，見 handback 已上交裁權）。
# 閾設 0.85 = 現值上方 → gate 現綠（防秒殺回歸），但絕對率 0.7+ 仍印出示病未清。
# 「現綠是否等於 done」= QA 判決題（絕對率健康 vs 回歸未惡化，系統/QA 裁），實作不自判。
const TRADE_CONTRADICTION_MAX: float = 0.85
# 「長期」= 買單齡 ≥ 壽命×此比例仍未滿足（壽命 ORDER_LIFETIME=5 天 → 齡 ≥4 天 = 壽終前最後一天）
const CONTRA_AGE_RATIO: float = 0.8

var _diag_on: bool = false
var _prev: Dictionary = {}   # 月 delta 用 probe 快照
var _order_sys := OrderSystem.new()   # 借 _market_pos/_hex_dist（read-only，零 RNG）
var _contra_num: int = 0   # 矛盾樣本：有效想要 且 長期未成交
var _contra_den: int = 0   # 有效想要樣本（買單存在+供給在+可達）

func _initialize() -> void:
	_run(); quit()

func _run() -> void:
	var world_seed: int = int(OS.get_environment("TF_SEED")) if OS.has_environment("TF_SEED") else 1337
	var months: int = int(OS.get_environment("TF_MONTHS")) if OS.has_environment("TF_MONTHS") else 6
	var cfg_name: String = OS.get_environment("TF_CONFIG") if OS.has_environment("TF_CONFIG") else "default"
	_diag_on = OS.get_environment("TF_DIAG") == "1"
	var total_ticks: int = maxi(months, 1) * WorldState.TICKS_PER_MONTH
	print("=== trade_funnel_bed: seed=%d months=%d (ticks=%d) config=%s diag=%s ===" % [
		world_seed, months, total_ticks, cfg_name, str(_diag_on)])

	seed(world_seed)   # 同 longwindow_bed：播 global RNG → 逐 tick 確定
	Probe.enabled = true
	Probe.reset()
	var state := WorldState.new()
	var runner := SimRunner.new()
	var config: Dictionary = GameSetup.load_config("res://config/%s.json" % cfg_name)
	if config.is_empty():
		print("[FAIL] config %s 載入失敗" % cfg_name); Probe.enabled = false; return
	config["seed"] = world_seed
	GameSetup.setup(state, config)

	var no_player := Vector2i(-1, -1)
	for tick in range(total_ticks):
		runner.advance_tick(state, no_player)
		if state.encounter_active and state.encounter_tick > 800:
			runner._encounter_system.resolve_encounter_end(state, "draw")
		if (tick + 1) % WorldState.TICKS_PER_MONTH == 0:
			var month: int = (tick + 1) / WorldState.TICKS_PER_MONTH
			_print_month(state, month)
		if state.teams.is_empty():
			print("[bed] tick=%d 全滅，提早結束" % tick)
			break

	_print_funnel(state, months)
	print("\n=== trade_funnel_bed DONE ===")
	Probe.enabled = false

# ────────── 月報：probe delta + 商業隊普查（read-only，零 RNG）──────────
func _print_month(state: WorldState, month: int) -> void:
	var cur: Dictionary = _trade_counts()
	var delta: Dictionary = {}
	for k in cur:
		var d: int = int(cur[k]) - int(_prev.get(k, 0))
		if d != 0:
			delta[k] = d
	_prev = cur
	# 商業隊普查：TAG_MERCHANT 隊數 + 其 team_known 內 order message 數（站2 收到）
	var merchants: int = 0
	var trade_arche: int = 0
	var known_orders: int = 0
	var trade_task_now: int = 0
	for tid in state.teams:
		var t: TeamData = state.teams[tid]
		if t.current_task == TeamData.TASK_TRADE:
			trade_task_now += 1
		if t.ambition_archetype == AmbitionLadder.ARCHETYPE_TRADE:
			trade_arche += 1
		if not t.tags.has(TeamData.TAG_MERCHANT):
			continue
		merchants += 1
		for m in state.team_known.get(tid, []):
			if m.type == "order_buy" or m.type == "order_sell":
				known_orders += 1
	print("[bed] 月%d teams=%d pop=%d 商隊tag=%d 商archetype=%d 站2known_orders=%d(均%.1f/商隊) TRADE中=%d" % [
		month, state.teams.size(), _total_pop(state), merchants, trade_arche, known_orders,
		float(known_orders) / maxf(float(merchants), 1.0), trade_task_now])
	print("[bed] 月%d Δ %s" % [month, str(delta)])
	_scan_contradictions(state, month)
	if _diag_on:
		_print_merchant_utils(state, month)

# ────────── ①矛盾偵測（月邊界 read-only 取樣，零 RNG 零 state 寫）──────────
# 對每張 active 買單：有效想要 = 供給在（他隊有貨或他村糧倉有貨）+ 對象可達（供給點到
# 會合市集 ≤ MERCHANT_MAX_RANGE）。矛盾 = 有效想要 且 齡 ≥ 壽命×CONTRA_AGE_RATIO 仍掛著
# （壽終前最後取樣窗未滿足 ≈ 到期未成交；部分成交偵不到=已知限制，spec 允）。
# 非量地板：無有效想要（den=0）→ n/a=健康，不逼表演。
func _scan_contradictions(state: WorldState, month: int) -> void:
	var age_min: int = int(float(OrderSystem.ORDER_LIFETIME) * CONTRA_AGE_RATIO)
	var m_num: int = 0
	var m_den: int = 0
	for tid in state.teams:
		var team: TeamData = state.teams[tid]
		for o in team.active_orders:
			if String(o["kind"]) != "buy":
				continue
			var res: String = String(o["res"])
			var meet: Vector2i = _order_sys._market_pos(state, team)
			if not _supply_reachable(state, tid, res, meet):
				continue   # 供給不在/不可達 → 非有效想要，不入分母
			m_den += 1
			var age: int = state.world.current_tick - (int(o["expire_tick"]) - OrderSystem.ORDER_LIFETIME)
			if age >= age_min:
				m_num += 1
	_contra_num += m_num
	_contra_den += m_den
	print("[bed] 月%d 矛盾取樣 %d/%d（長期未成交/有效想要）" % [month, m_num, m_den])

# 供給在+可達：任一他隊私產有貨、或任一他隊據點糧倉（public_storage）有貨，
# 且該供給點到買單會合市集 ≤ MERCHANT_MAX_RANGE。
func _supply_reachable(state: WorldState, buyer_tid: int, res: String, meet: Vector2i) -> bool:
	for tid in state.teams:
		if tid == buyer_tid:
			continue
		var t: TeamData = state.teams[tid]
		if float(t.resources.get(res, 0)) > 0.0 \
				and _order_sys._hex_dist(t.tile_pos, meet) <= OrderSystem.MERCHANT_MAX_RANGE:
			return true
	for tile_id in state.world.tiles:
		var tile: HexTileData = state.world.tiles[tile_id]
		if tile.outpost_level <= 0 or tile.outpost_owner == buyer_tid or tile.outpost_owner < 0:
			continue
		if float(tile.public_storage.get(res, 0)) > 0.0 \
				and _order_sys._hex_dist(tile.tile_pos, meet) <= OrderSystem.MERCHANT_MAX_RANGE:
			return true
	return false

# TF_DIAG：商業隊 util 排名 top3（rank_scored 建 DecisionContext 有 randf → 擾流，專跑）
func _print_merchant_utils(state: WorldState, month: int) -> void:
	for tid in state.teams:
		var t: TeamData = state.teams[tid]
		if not t.tags.has(TeamData.TAG_MERCHANT):
			continue
		var ranked: Array = DecisionEngine.rank_scored(state, t)
		var tops: Array = []
		for i in range(mini(3, ranked.size())):
			tops.append("%s=%.2f" % [ranked[i]["opt"], float(ranked[i]["u"])])
		print("[bedDiag] 月%d T%d(task=%s) util前三: %s" % [month, tid, t.current_task, " > ".join(tops)])

# ────────── 收尾：六站漏斗表 ──────────
func _print_funnel(state: WorldState, months: int) -> void:
	var post: int = _c("trade.post_buy") + _c("trade.post_sell")
	var dispatch: int = _dispatch_total()
	var deal_all: int = _c("trade.deal") + _c("trade.barter_deal")
	print("\n========== 貿易環六站漏斗表（%d 月總量）==========" % months)
	print("[funnel] 站1 張貼        = %d (buy=%d sell=%d)" % [post, _c("trade.post_buy"), _c("trade.post_sell")])
	print("[funnel] 站2 收到        = board_read=%d market_arrive=%d（known 存量見月報）" % [
		_c("g1.board_read"), _c("g1.market_arrive")])
	print("[funnel] 站3 選中        = arb_pick=%d / arb_call=%d (%s)；濾鏈: sell_seen=%d buy_seen=%d range殺=%d 無貨殺=%d" % [
		_c("trade.arb_pick"), _c("trade.arb_call"), _rate(_c("trade.arb_pick"), _c("trade.arb_call")),
		_c("trade.arb_sell_seen"), _c("trade.arb_buy_seen"),
		_c("trade.arb_kill_range"), _c("trade.arb_kill_nostock")])
	print("[funnel] 站4 dispatch    = %d（%s）" % [dispatch, _dispatch_breakdown()])
	print("[funnel] 站4 被誰打斷    : %s" % _preempt_breakdown())
	print("[funnel] 站5 到場        = arrive=%d (%s of dispatch)；夭折: timeout=%d 途中被截release=%d" % [
		_c("trade.arrive"), _rate(_c("trade.arrive"), dispatch),
		_c("trade.timeout"), _c("trade.release_midroute")])
	print("[funnel] 站6 成交        = deal=%d (coin=%d barter=%d)；會合=%d 途中會合=%d 撲空nodeal=%d" % [
		deal_all, _c("trade.deal"), _c("trade.barter_deal"),
		_c("trade.meet"), _c("trade.meet_midroute"), _c("trade.meet_nodeal")])
	print("[funnel] 站6 成交主體    : 商隊跑單=%d vs resident互售=%d" % [
		_c("trade.deal_merchant"), _c("trade.deal_resident")])
	print("[funnel] 履約: order_fulfilled=%d arb_hit=%d" % [_c("g1.order_fulfilled"), _c("g1.arb_hit")])
	# ②常駐漏斗率鏈（spec R3：每站 分子/分母=率，裸計數不收）——經濟軌回歸盯這串。
	# 商隊 funnel 全鏈同分母遞減（選中/呼叫→dispatch/選中→到場→成交_merchant）；
	# resident 互售不走旅途 funnel（在家村攤成交）→ 另列，不混入商隊率（避免 >100% 假象）。
	var arb_call: int = _c("trade.arb_call")
	var arb_pick: int = _c("trade.arb_pick")
	var arrive: int = _c("trade.arrive")
	var deal_m: int = _c("trade.deal_merchant")
	print("[rate] 商隊 funnel: 選中/呼叫=%s dispatch/選中=%s 到場/dispatch=%s 成交/到場=%s（deal_merchant=%d）" % [
		_rate(arb_pick, arb_call), _rate(dispatch, arb_pick),
		_rate(arrive, dispatch), _rate(deal_m, arrive), deal_m])
	print("[rate] resident 互售（非旅途）: deal_resident=%d；張貼→board_read=%s" % [
		_c("trade.deal_resident"), _rate(_c("g1.board_read"), post)])
	print("[rate] 成交/月=%.2f 成交/月/村對=%.4f（deal_all=%d months=%d 村對=%d）" % [
		float(deal_all) / maxf(float(months), 1.0),
		float(deal_all) / maxf(float(months) * _pair_count(state), 1.0),
		deal_all, months, int(_pair_count(state))])
	# 不塌房哨（驗收3）：pop / faction / 狼鏈 probe
	print("[sanity] 期末 teams=%d pop=%d factions=%d capture.total=%d g2.faction_found=%d" % [
		state.teams.size(), _total_pop(state), state.factions.size(),
		_c("capture.total"), _c("g2.faction_found")])
	# ①矛盾率 assert（回歸 gate；絕對率印真值示病，閾=回歸地板非健康證書，見 const 註）
	# 無有效想要 den=0 → 世界真無稀缺=健康 PASS，不逼表演（可解釋性非量級）。
	if _contra_den == 0:
		print("[PASS] ①矛盾率 n/a（無有效想要樣本＝世界無稀缺，健康非病）")
	else:
		var contra_rate: float = float(_contra_num) / float(_contra_den)
		var verdict: String = "PASS" if contra_rate <= TRADE_CONTRADICTION_MAX else "FAIL"
		var health: String = "低=健康" if contra_rate < 0.4 else ("中" if contra_rate < 0.7 else "高=貿易環仍病(域外殘因)")
		print("[%s] ①矛盾率(回歸gate) = %d/%d = %.3f （回歸閾 ≤ %.2f）；絕對健康讀數: %.3f %s" % [
			verdict, _contra_num, _contra_den, contra_rate, TRADE_CONTRADICTION_MAX, contra_rate, health])
	print("====================================================")

# 村對數（成交/月/村對 分母）：定居隊（有自家 outpost）兩兩配對 ≈ C(n,2)，下限 1。
func _pair_count(state: WorldState) -> float:
	var settled: int = 0
	var seen: Dictionary = {}
	for tile_id in state.world.tiles:
		var tile: HexTileData = state.world.tiles[tile_id]
		if tile.outpost_level > 0 and tile.outpost_owner >= 0 and not seen.has(tile.outpost_owner):
			seen[tile.outpost_owner] = true
			settled += 1
	return maxf(float(settled * (settled - 1)) / 2.0, 1.0)

# ────────── helpers ──────────
func _trade_counts() -> Dictionary:
	var out: Dictionary = {}
	for k in Probe.counts:
		if String(k).begins_with("trade.") or String(k).begins_with("g1."):
			out[k] = int(Probe.counts[k])
	return out

func _dispatch_total() -> int:
	var n: int = 0
	for k in Probe.counts:
		if String(k).begins_with("trade.dispatch."):
			n += int(Probe.counts[k])
	return n

func _dispatch_breakdown() -> String:
	var parts: Array = []
	var keys: Array = Probe.counts.keys().filter(func(k): return String(k).begins_with("trade.dispatch."))
	keys.sort()
	for k in keys:
		parts.append("%s=%d" % [String(k).trim_prefix("trade.dispatch."), int(Probe.counts[k])])
	return " ".join(parts) if not parts.is_empty() else "零 dispatch"

func _preempt_breakdown() -> String:
	var parts: Array = []
	var keys: Array = Probe.counts.keys().filter(func(k): return String(k).begins_with("trade.preempt."))
	keys.sort_custom(func(a, b): return int(Probe.counts[a]) > int(Probe.counts[b]))
	for k in keys:
		parts.append("%s=%d" % [String(k).trim_prefix("trade.preempt."), int(Probe.counts[k])])
	return " ".join(parts) if not parts.is_empty() else "無打斷"

func _c(key: String) -> int:
	return int(Probe.counts.get(key, 0))

func _rate(num: int, den: int) -> String:
	if den <= 0:
		return "n/a"
	return "%.1f%%" % (100.0 * float(num) / float(den))

func _total_pop(state: WorldState) -> int:
	var n: int = 0
	for tid in state.teams:
		n += state.teams[tid].population
	return n
