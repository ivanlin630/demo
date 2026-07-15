extends SceneTree

# trade_bail_probe_bed：死法②診斷——貿易co-located pair為何nodeal，逐候選bail因歸類。
# 純觀測：不呼叫 _execute_transfer/_attempt_trade_direction 等會寫 state 的函式，只複刻同公式唯讀計算。
# 用法：TB_SEED（default 1337）TB_MONTHS（default 6）

func _initialize() -> void:
	_run(); quit()

var _reasons: Dictionary = {}   # reason -> count（跨兩方向、跨pair）
var _pair_reason_sample: Array = []   # 前N筆樣本供人工核對
var _lv_samples: Array = []   # local_value hypothesis 抽驗樣本（ask>=bid 時賣方 local_value 明細）

func _run() -> void:
	var world_seed: int = int(OS.get_environment("TB_SEED")) if OS.has_environment("TB_SEED") else 1337
	var months: int = int(OS.get_environment("TB_MONTHS")) if OS.has_environment("TB_MONTHS") else 6
	var total_ticks: int = months * WorldState.TICKS_PER_MONTH
	print("=== trade_bail_probe_bed: seed=%d months=%d ===" % [world_seed, months])
	seed(world_seed)
	SimRunner.force_full_hd = true
	Probe.enabled = true
	Probe.reset()
	var state := WorldState.new()
	var runner := SimRunner.new()
	var config: Dictionary = GameSetup.load_config("res://config/default.json")
	config["seed"] = world_seed
	GameSetup.setup(state, config)
	var no_player := Vector2i(-1, -1)
	var checked: int = 0
	for tick in range(total_ticks):
		runner.advance_tick(state, no_player)
		checked += _scan_colocated(state, tick)
		if state.teams.is_empty():
			break
	print("[DIAG] 總co-located且至少一方TASK_TRADE的pair-direction檢查數=%d" % checked)
	print("[DIAG] bail 原因分布: %s" % JSON.stringify(_reasons))
	print("[DIAG] 樣本(前20):")
	for s in _pair_reason_sample.slice(0, 20):
		print("  " + str(s))
	print("[LV_HYPOTHESIS] ask>=bid 樣本 local_value(absorb已含糧倉) 明細(前30):")
	for s in _lv_samples:
		print("  " + str(s))
	SimRunner.force_full_hd = false
	Probe.enabled = false
	print("=== DONE ===")

func _scan_colocated(state: WorldState, tick: int) -> int:
	var by_tile: Dictionary = {}
	for tid in state.teams:
		var t: TeamData = state.teams[tid]
		var key: int = t.tile_pos.x * 100000 + t.tile_pos.y
		if not by_tile.has(key):
			by_tile[key] = []
		by_tile[key].append(tid)
	var n: int = 0
	for key in by_tile:
		var ids: Array = by_tile[key]
		if ids.size() < 2:
			continue
		for i in range(ids.size()):
			for j in range(i + 1, ids.size()):
				var a: TeamData = state.teams[ids[i]]
				var b: TeamData = state.teams[ids[j]]
				if a.current_task != TeamData.TASK_TRADE and b.current_task != TeamData.TASK_TRADE:
					continue
				n += 2
				# 同真實 _resolve_market：交易窗內先 absorb 雙方 public_storage → 診斷用同狀態 → spill_back 還原（不留痕）。
				var a_orig: Dictionary = InteractionSystem._absorb_public_storage(state, a)
				var b_orig: Dictionary = InteractionSystem._absorb_public_storage(state, b)
				_diag_direction(state, a, b, tick)
				_diag_direction(state, b, a, tick)
				InteractionSystem._spill_back_public_storage(state, a, a_orig)
				InteractionSystem._spill_back_public_storage(state, b, b_orig)
	return n

# 複刻 _attempt_trade_direction(seller, buyer) 唯讀版：只算會 bail 在哪，不執行轉移。
# ★local_value hypothesis 抽驗：ask>=bid 時同時印 absorb 前後 local_value 差異，坐實/排除「糧倉盲=誤判短缺」。
func _diag_direction(state: WorldState, seller: TeamData, buyer: TeamData, tick: int) -> void:
	var buyer_coin: float = float(buyer.resources.get("coin", 0))
	if buyer_coin <= 0.0:
		_bump("no_coin")
		return
	var s_leader = state.persons.get(seller.leader_id)
	var commerce: float = float(s_leader.skills.get("商業", 0.0)) if s_leader else 0.0
	var any_surplus: bool = false
	var any_price_ok: bool = false
	var any_qty_ok: bool = false
	var ms := MovementSystem.new()
	for res in TradeValuation.BASE_PRICE.keys():
		var stock: float = float(seller.resources.get(res, 0))   # 已 absorb（呼叫端先做）
		var reserve: float = TradeValuation.reserve(seller, res, TradeValuation.leader_vals(state, seller))
		var surplus: float = maxf(stock - reserve, 0.0)
		if surplus <= 0.0:
			continue
		any_surplus = true
		var ask: float = TradeValuation.local_value(seller, res) * (1.0 - commerce * 0.1)
		var bid: float = TradeValuation.local_value(buyer, res)
		if ask <= 0.0 or ask >= bid:
			continue
		any_price_ok = true
		var qty: int = mini(int(surplus), int(buyer_coin / ask))
		qty = mini(qty, ms.carry_space_for_res(buyer, res))
		if qty <= 0:
			continue
		any_qty_ok = true
		_bump("WOULD_TRADE(%s)" % res)
		if _pair_reason_sample.size() < 40:
			_pair_reason_sample.append({"tick": tick, "seller": seller.team_id, "buyer": buyer.team_id,
				"res": res, "surplus": surplus, "ask": ask, "bid": bid, "qty": qty, "reason": "WOULD_TRADE"})
		return   # 找到一個能成的就算這方向沒 bail（同真實函式邏輯：找到就轉移，非窮盡全list才判)
	if not any_surplus:
		_bump("no_surplus_any_res")
		if _pair_reason_sample.size() < 40:
			_pair_reason_sample.append({"tick": tick, "seller": seller.team_id, "buyer": buyer.team_id, "reason": "no_surplus_any_res"})
	elif not any_price_ok:
		_bump("price_mismatch_ask_ge_bid")
		# ★hypothesis 抽驗：找出 ask>=bid 的那個 res，印 absorb-已含 vs 純team.resources(未absorb基線,借stock推回) local_value 差異
		for res in TradeValuation.BASE_PRICE.keys():
			var stock2: float = float(seller.resources.get(res, 0))
			var reserve2: float = TradeValuation.reserve(seller, res, TradeValuation.leader_vals(state, seller))
			var surplus2: float = maxf(stock2 - reserve2, 0.0)
			if surplus2 <= 0.0:
				continue
			var ask2: float = TradeValuation.local_value(seller, res) * (1.0 - commerce * 0.1)
			var bid2: float = TradeValuation.local_value(buyer, res)
			if ask2 > 0.0 and ask2 >= bid2:
				if _lv_samples.size() < 30:
					_lv_samples.append({"tick": tick, "seller": seller.team_id, "buyer": buyer.team_id, "res": res,
						"seller_resources_stock_absorbed": stock2, "local_value_seller_absorbed": TradeValuation.local_value(seller, res),
						"ask": ask2, "bid": bid2})
				break
		if _pair_reason_sample.size() < 40:
			_pair_reason_sample.append({"tick": tick, "seller": seller.team_id, "buyer": buyer.team_id, "reason": "price_mismatch_ask_ge_bid"})
	elif not any_qty_ok:
		_bump("qty_zero_carry_or_coin")
		if _pair_reason_sample.size() < 40:
			_pair_reason_sample.append({"tick": tick, "seller": seller.team_id, "buyer": buyer.team_id, "reason": "qty_zero_carry_or_coin"})

func _bump(k: String) -> void:
	_reasons[k] = int(_reasons.get(k, 0)) + 1
