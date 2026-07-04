extends SceneTree

# trade_funnel_bed：貿易環六站漏斗 measure harness（純 debug/infra，零 sim 邏輯變）。
# 六站：張貼→收到→選中→dispatch/被誰打斷→到場→成交（spec 2026-07-04-trade-loop-ignition）。
# 探針全 Probe counter（無 randf、無 state 寫）→ 與無探針跑 RNG 流逐點同。
#
# 用法（env）：
#   TF_SEED    world seed（default 1337；exam2 對照另跑 2674）
#   TF_MONTHS  跑幾月（default 6）
#   TF_CONFIG  config 名（default "default" = 真產品世界）
#   TF_DIAG    =1 開商業隊 util 排名 top3（rank_scored 建 ctx 內含 randf → 擾 RNG 流，勿混 baseline）

var _diag_on: bool = false
var _prev: Dictionary = {}   # 月 delta 用 probe 快照

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
	if _diag_on:
		_print_merchant_utils(state, month)

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
	print("[funnel] 轉化率: 張貼→dispatch=%s dispatch→到場=%s 到場→成交=%s" % [
		_rate(dispatch, post), _rate(_c("trade.arrive"), dispatch), _rate(deal_all, _c("trade.arrive"))])
	# 不塌房哨（驗收3）：pop / faction / 狼鏈 probe
	print("[sanity] 期末 teams=%d pop=%d factions=%d capture.total=%d g2.faction_found=%d" % [
		state.teams.size(), _total_pop(state), state.factions.size(),
		_c("capture.total"), _c("g2.faction_found")])
	print("====================================================")

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
