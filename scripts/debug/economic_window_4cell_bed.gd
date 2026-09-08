extends SceneTree
# economic_window_4cell_bed：經濟窗四格(systems 2026-09-08票，同一輪跑完)
# ①板厚：market_orders深度(全tile vs 有市場的tile分開報)
# ②成交量：嘗試(trade.meet)vs成交(trade.deal系)
# ③價差：buy/sell訂單各自origin_team的local_value(res)分布(非單一bid/ask，本遊戲設計是
#   每隊各自估值，spread=買方組估值vs賣方組估值的差距分布)
# ④農隊收入：PRODUCE隊reason=market_sell_coin_in的coin收入(⑨世界農隊賣糧後果實測)
# +buyer_reject_priced_too_high：既有tap直讀
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
	# ②零價佔比：{res: 總筆數}/{res: price==0筆數}(2026-09-08加)
	var zero_price_total_by_res: Dictionary = {}
	var zero_price_zero_by_res: Dictionary = {}
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
						# ★2026-09-08加②零價佔比by res：price==0.0明確視為「價就是零」(order_system.gd:426註解)，
						#   排除-1.0(未帶價)。零新tap，讀既有market_orders.price欄位。
						var declared_price: float = float(od.get("price", -1.0))
						if declared_price >= 0.0:
							if not zero_price_total_by_res.has(res): zero_price_total_by_res[res] = 0
							if not zero_price_zero_by_res.has(res): zero_price_zero_by_res[res] = 0
							zero_price_total_by_res[res] = int(zero_price_total_by_res[res]) + 1
							if is_equal_approx(declared_price, 0.0):
								zero_price_zero_by_res[res] = int(zero_price_zero_by_res[res]) + 1
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

	print("\n③價差(buy估值-sell估值，正=買方願付比賣方要價高)：★含分位數+≤0佔比(2026-09-08補)")
	if spread_by_res.is_empty():
		print("  ★無配對樣本(可能板上從未同時有同res的buy+sell)，不可判")
	else:
		for res2 in spread_by_res.keys():
			var arr: Array = spread_by_res[res2]
			arr.sort()
			var sum3: float = 0.0
			var le0: int = 0
			for v3 in arr:
				sum3 += v3
				if v3 <= 0.0: le0 += 1
			var n_arr: int = arr.size()
			print("  %s: 樣本數=%d 平均=%.3f ≤0佔比=%.1f%%(%d/%d) p10=%.3f p25=%.3f p50=%.3f p75=%.3f p90=%.3f min=%.3f max=%.3f" % [
				res2, n_arr, sum3 / n_arr, float(le0) / float(n_arr) * 100.0, le0, n_arr,
				arr[int(n_arr * 0.10)], arr[int(n_arr * 0.25)], arr[int(n_arr * 0.50)],
				arr[int(n_arr * 0.75)], arr[mini(int(n_arr * 0.90), n_arr - 1)], arr[0], arr[-1]])

	print("\n②零價佔比by res(2026-09-08補，price==0.0視為「價就是零」，排除-1.0未帶價，order_system.gd:426)：")
	if zero_price_total_by_res.is_empty():
		print("  ★無樣本(order從未帶price欄位)，不可判")
	else:
		for res4 in zero_price_total_by_res.keys():
			var tot: int = int(zero_price_total_by_res[res4])
			var zc: int = int(zero_price_zero_by_res.get(res4, 0))
			print("  %s: 零價佔比=%.1f%%(%d/%d)" % [res4, float(zc) / float(tot) * 100.0, zc, tot])

	print("\n④農隊收入(⑨世界market_sell_coin_in，PRODUCE隊)：")
	print("  總額=%.2f 筆數=%d 涉及隊數=%d" % [farm_income_total, farm_income_count, farm_income_by_team.size()])
	if farm_income_count == 0:
		print("  ★★零筆——需分辨:PRODUCE隊母體是否存在（若為0則不可判非結論0）")

	print("\n★trade.buyer_reject_priced_too_high（舊名，implementer另案改名為trade.buyer_reject_priced_too_high；")
	print("  ★★★真實語意：某個【路過的潛在買方】認為【賣單自標price】高於自己對該資源的local_value估值")
	print("  ★★★=拒買次數，不是「board上buy訂單vs sell訂單的配對價差≤0」——這是與③格不同維度的東西，見systems裁決）：")
	print("  總次數=%d" % int(Probe.counts.get("trade.buyer_reject_priced_too_high", 0)))
	var by_res_kill: Dictionary = {}
	for k in Probe.counts.keys():
		if String(k).begins_with("trade.buyer_reject_priced_too_high."):
			by_res_kill[String(k).trim_prefix("trade.buyer_reject_priced_too_high.")] = int(Probe.counts[k])
	for r3 in by_res_kill.keys():
		print("    %s: %d" % [r3, by_res_kill[r3]])
	# ★★★五個純量的判別（systems 裁 2026-09-08）―― 刻意不做分布：
	#   Probe 的 instance 是 first-N cap（取樣有偏），而分布最不能忍受取樣偏差。
	var _n: int = int(Probe.counts.get("trade.buyer_reject_priced_too_high", 0))
	if _n <= 0:
		print("  ★母體為空（n=0）⇒ 【不可判】，不是【兩邊都不趨 0】")
	else:
		var _ask_avg: float = float(Probe.amounts.get("trade.buyer_reject.ask_sum", 0.0)) / float(_n)
		var _mine_avg: float = float(Probe.amounts.get("trade.buyer_reject.mine_sum", 0.0)) / float(_n)
		var _mz: int = int(Probe.counts.get("trade.buyer_reject.mine_zero", 0))
		var _az: int = int(Probe.counts.get("trade.buyer_reject.ask_zero", 0))
		var _mzs: float = float(_mz) / float(_n)
		var _azs: float = float(_az) / float(_n)
		print("  ── 判別（n=%d）──" % _n)
		print("     平均 ask =%.4f｜平均 mine=%.4f" % [_ask_avg, _mine_avg])
		print("     mine_zero=%d (%.1f%%)｜ask_zero=%d (%.1f%%)" % [_mz, _mzs * 100.0, _az, _azs * 100.0])
		if _mzs >= 0.7 and _azs >= 0.7:
			print("     ⇒ ★兩邊都趨 0 ⇒「全員過剩、誰都不要」讀法站得住")
		elif _mzs >= 0.7 and _azs <= 0.3 and _ask_avg > _mine_avg:
			print("     ⇒ ★★「賣家開價脫離行情」―― 另一種病，下一刀完全不同")
		else:
			print("     ⇒ ★★★【不可判】兩個 share 都在中間 ⇒ 這時才需要分布（而那時我們會知道為什麼需要）")
		# ★per-res 拆開：聚合判【不可判】時，先看是不是【兩個母體被掺在一起】。
		for r4 in by_res_kill.keys():
			var _rn: int = int(by_res_kill[r4])
			if _rn <= 0: continue
			var _rm: int = int(Probe.counts.get("trade.buyer_reject.mine_zero." + String(r4), 0))
			var _ra: int = int(Probe.counts.get("trade.buyer_reject.ask_zero." + String(r4), 0))
			var _rasum: float = float(Probe.amounts.get("trade.buyer_reject.ask_sum." + String(r4), 0.0))
			var _rmsum: float = float(Probe.amounts.get("trade.buyer_reject.mine_sum." + String(r4), 0.0))
			print("     [%s] n=%d｜mine_zero=%.1f%%｜ask_zero=%.1f%%｜平均 ask=%.4f｜平均 mine=%.4f"
				% [r4, _rn, float(_rm) / float(_rn) * 100.0, float(_ra) / float(_rn) * 100.0,
				   _rasum / float(_rn), _rmsum / float(_rn)])

	print("\n★否證③：「三症一根」的價差倒掛→殺單那一節目前沒有橋(見systems裁決，殺單是不同維度的拒買次數)")
	print("★⑨世界誠實限：貨幣量未過校驗（±14×待判）")
	print("=== economic_window_4cell_bed DONE ===")
