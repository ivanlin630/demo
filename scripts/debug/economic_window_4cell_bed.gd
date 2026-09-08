extends SceneTree
# economic_window_4cell_bed：經濟窗四格(systems 2026-09-08票，同一輪跑完)
# ①板厚：market_orders深度(全tile vs 有市場的tile分開報)
# ②成交量：嘗試(trade.meet)vs成交(trade.deal系)
# ③價差：buy/sell訂單各自origin_team的local_value(res)分布(非單一bid/ask，本遊戲設計是
#   每隊各自估值，spread=買方組估值vs賣方組估值的差距分布)
# ④農隊收入：PRODUCE隊reason=market_sell_coin_in的coin收入(⑨世界農隊賣糧後果實測)
# +arb_kill_zero_gain：既有tap直讀
# 零新tap，全部讀既有tile.market_orders/driver_ledger/Probe.counts。
# ★跑法紀律(systems 2026-09-08)：卷面第一行標HEAD sha+樹乾淨與否+實際跑到第幾天。
# 用法：BED_CONFIG(default res://config/warring_states.json) BED_DAYS(default 30) BED_SEED(default 1337)

func _initialize() -> void:
	_run(); quit()

func _run() -> void:
	var days: int = int(OS.get_environment("BED_DAYS")) if OS.has_environment("BED_DAYS") else 30
	var cfg: String = OS.get_environment("BED_CONFIG") if OS.has_environment("BED_CONFIG") else "res://config/warring_states.json"
	var seed_val: int = int(OS.get_environment("BED_SEED")) if OS.has_environment("BED_SEED") else 1337
	seed(seed_val)
	WorldState.driver_ledger_enabled = true
	WorldState.clear_driver_ledger()
	var state: WorldState = MeasureBedHelper.arm_and_setup(cfg, true)
	var runner := SimRunner.new()
	var ticks: int = days * WorldState.TICKS_PER_DAY
	var no_player := Vector2i(-1, -1)

	print("=== economic_window_4cell_bed: config=%s days=%d ticks=%d seed=%d ===" % [cfg, days, ticks, seed_val])

	# ①板厚樣本
	var depth_all_tiles: Array = []       # 全世界所有tile的market_orders.size()
	var depth_market_tiles: Array = []    # 只算market_orders非空的tile
	# ③價差樣本：{res: [spread值...]}
	var spread_by_res: Dictionary = {}
	# ④農隊收入
	var farm_income_total: float = 0.0
	var farm_income_count: int = 0
	var farm_income_by_team: Dictionary = {}

	var actual_days_completed: int = 0

	for tick in range(ticks):
		runner.advance_tick(state, no_player)
		if tick % 1440 == 0:
			actual_days_completed = int(tick / WorldState.TICKS_PER_DAY)
		if tick % 2000 == 0 and tick > 0:
			# ④農隊收入 drain（同member_tax血教訓，間隔50不夠這裡用2000但配合overflow check）
			var overflow_hit: bool = WorldState.driver_ledger.size() >= WorldState.driver_ledger_cap
			for e in WorldState.driver_ledger:
				if String(e.get("reason", "")) == "market_sell_coin_in":
					var ent = e.get("entity")
					if ent is TeamData and ent.tags.has(TeamData.TAG_PRODUCE):
						var delta: float = float(e.get("delta", 0.0))
						if delta > 0.0:
							farm_income_total += delta
							farm_income_count += 1
							var tid_e: int = ent.team_id
							farm_income_by_team[tid_e] = float(farm_income_by_team.get(tid_e, 0.0)) + delta
			WorldState.clear_driver_ledger()
			if overflow_hit:
				print("[OVERFLOW-WARN] tick=%d drain前已達cap，農隊收入可能低估" % tick)
		if tick % 3000 == 0:   # ★間隔500→3000(2026-09-08修正)：原500tick對world.tiles全掃+O(buy×sell)配對太重,30天窗5400s跑不到10000tick就耗盡
			# ①③ snapshot
			var all_d: int = 0; var market_d: int = 0; var market_n: int = 0
			for tile_id in state.world.tiles:
				var tile: HexTileData = state.world.tiles[tile_id]
				var n: int = tile.market_orders.size()
				all_d += n
				if n > 0:
					market_d += n; market_n += 1
					var buy_prices: Array = []
					var sell_prices: Array = []
					for o in tile.market_orders:
						var od: Dictionary = o
						var res: String = String(od.get("res", ""))
						var otid: int = int(od.get("origin_team", -1))
						if not state.teams.has(otid): continue
						var ot: TeamData = state.teams[otid]
						var lv: float = TradeValuation.local_value(ot, res, state)
						if String(od.get("kind", "")) == "buy":
							buy_prices.append([res, lv])
						else:
							sell_prices.append([res, lv])
					for bp in buy_prices:
						for sp in sell_prices:
							if bp[0] == sp[0]:
								var r: String = bp[0]
								if not spread_by_res.has(r): spread_by_res[r] = []
								(spread_by_res[r] as Array).append(bp[1] - sp[1])
			depth_all_tiles.append(float(all_d) / maxf(float(state.world.tiles.size()), 1.0))
			if market_n > 0:
				depth_market_tiles.append(float(market_d) / float(market_n))
		if tick % 10000 == 0 and tick > 0:
			print("[CHECKPOINT] tick=%d day=%d teams=%d farm_income累計=%.1f(%d筆)" % [
				tick, actual_days_completed, state.teams.size(), farm_income_total, farm_income_count])

	print("\n=== 結果 ===")
	print("★卷面首行：HEAD需另外git log查｜實際跑到day=%d / 目標%d天(%.1f%%)" % [
		actual_days_completed, days, float(actual_days_completed) / float(days) * 100.0])

	print("\n①板厚：")
	if depth_all_tiles.is_empty():
		print("  ★無樣本，不可判")
	else:
		var s1: float = 0.0
		for v in depth_all_tiles: s1 += v
		print("  全世界所有tile平均板厚=%.4f（樣本數=%d，含零市場tile被稀釋）" % [s1 / depth_all_tiles.size(), depth_all_tiles.size()])
	if depth_market_tiles.is_empty():
		print("  有市場的tile：★無樣本，不可判")
	else:
		var s2: float = 0.0
		for v2 in depth_market_tiles: s2 += v2
		print("  只算有市場的tile平均板厚=%.4f（樣本數=%d）" % [s2 / depth_market_tiles.size(), depth_market_tiles.size()])

	print("\n②成交量：")
	print("  嘗試(trade.meet)=%d｜成交(trade.deal)=%d｜market撮合(trade.deal_market)=%d｜零撮合(trade.meet_nodeal)=%d" % [
		int(Probe.counts.get("trade.meet", 0)), int(Probe.counts.get("trade.deal", 0)),
		int(Probe.counts.get("trade.deal_market", 0)), int(Probe.counts.get("trade.meet_nodeal", 0))])

	print("\n③價差(buy估值-sell估值，正=買方願付比賣方要價高)：")
	if spread_by_res.is_empty():
		print("  ★無配對樣本(可能板上從未同時有同res的buy+sell)，不可判")
	else:
		for res2 in spread_by_res.keys():
			var arr: Array = spread_by_res[res2]
			arr.sort()
			var sum3: float = 0.0
			for v3 in arr: sum3 += v3
			print("  %s: 樣本數=%d 平均=%.3f min=%.3f p50=%.3f max=%.3f" % [
				res2, arr.size(), sum3 / arr.size(), arr[0], arr[int(arr.size() / 2)], arr[-1]])

	print("\n④農隊收入(⑨世界market_sell_coin_in，PRODUCE隊)：")
	print("  總額=%.2f 筆數=%d 涉及隊數=%d" % [farm_income_total, farm_income_count, farm_income_by_team.size()])
	if farm_income_count == 0:
		print("  ★★零筆——需分辨:PRODUCE隊母體是否存在（若為0則不可判非結論0）")

	print("\n★arb_kill_zero_gain：")
	print("  總次數=%d" % int(Probe.counts.get("trade.arb_kill_zero_gain", 0)))
	var by_res_kill: Dictionary = {}
	for k in Probe.counts.keys():
		if String(k).begins_with("trade.arb_kill_zero_gain."):
			by_res_kill[String(k).trim_prefix("trade.arb_kill_zero_gain.")] = int(Probe.counts[k])
	for r3 in by_res_kill.keys():
		print("    %s: %d" % [r3, by_res_kill[r3]])

	print("\n★⑨世界誠實限：貨幣量未過校驗（±14×待判）")
	print("=== economic_window_4cell_bed DONE ===")
