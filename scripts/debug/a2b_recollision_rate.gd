extends SceneTree
# @bed-kind: diagnostic
# A2b 前置量測（systems 派工 2026-10-07，純讀不改世界）：
#   docs/superpowers/handbacks/2026-10-07-systems-to-measurer-DISPATCH-a2b-recollision-rate.md
#   追量（systems 2026-10-07，7e45f8539）：
#   docs/superpowers/handbacks/2026-10-07-systems-to-measurer-DISPATCH-a2b-followup-a2-firing.md
# 問題：第一輪「貿易」重撞率 75~80%，與 A2 已 merge 的預期衝突。拆兩個可能：
#   (i) 判法：舊版「零成交」＝當日 coin 淨額==0——C2′ 已證這會把以貨易貨算成零成交；
#       改用 C2′ 的帳本判準（reason market_*／trade_goods_*，coin 與貨物都沒動）重算，兩表並排。
#   (ii) A2 觸發：每筆零成交事件同拍 team.recent_failures 裡「貿易|<市集tile_id>」有沒有真的被寫入
#       （tick 對得上這一拍）；重撞那一次，用【上一拍】的 recent_failures 重算 FailureMemory.mult
#       的值（折價在重撞發生前有沒有已經生效）。
#   另：兩次重撞之間，該隊有沒有在【別的市集】成交過（商人巡迴，不是卡住）。
#
# ★事件判法：
#   ①到場：重用 production 的 `SimRunner.trade_arrived(t)`（sim_runner.gd:901），邊緣偵測
#     （上一拍非到場→這一拍到場）取事件發生的那一拍，身分＝(day, tick, team, option, market_tile)。
#   ②零成交——兩種判法並列（本輪追量的核心）：
#     舊：當日（team）coin 淨額==0。
#     新(C2′)：當日 driver_ledger 裡，這個 team 名下沒有任何一筆 reason 以 "market_" 或
#       "trade_goods_" 開頭、delta≠0 的紀錄（不分 coin 或貨物欄位——★★只要帳本上有一筆真動過，
#       不管動的是 coin 還是貨，都不算零成交；這正是 C2′ 抓到「以貨易貨被算成零成交」的那個修法）。
#   ③「option」：母體不手抄，用資料裡實際出現過的 current_option 字串分組（上一輪已改掉手列清單）。
#   ④重撞：同一(team,option,market)的下一次零成交事件，與上一次事件相差天數 ≤7（兩表各自算）。
#   ⑤換地方了：同隊之後在【不同market】的真實成交（兩表各自的「不是零成交」定義）。
#   ⑥A2記號：option=="貿易"時，查 team.recent_failures.get("貿易|"+市集tile_id) 的 tick 是否==本拍。
#   ⑦重撞前折價：用【上一拍】snapshot 的 recent_failures 重算 FailureMemory.mult 公式（唯讀重建，
#     不呼叫 production 的 mult()，因為那時 state 已經被本拍的 record() 蓋過——見 _recompute_mult()）。
#   ⑧巡迴：同一對重撞(e1→e2)之間，該隊是否在別的市集有一筆「新判法＝有成交」的事件。
#
# 跑法：.\tools\godot.ps1 --headless --script scripts/debug/a2b_recollision_rate.gd

const SEEDS: Array = [1337, 2024, 7]
const TOTAL_DAYS: int = 30
const RECOLLISION_WINDOW_DAYS: int = 7
const TRADE_OPTIONS: Array = ["貿易", "領取", "買糧", "囤貨"]   # 旁證對照用，分組不靠它


func _initialize() -> void:
	for sd in SEEDS:
		_run_one_seed(int(sd))
	print("\n=== a2b_recollision_rate DONE（%d 個 seed）===" % SEEDS.size())
	quit(0)


# 唯讀重建 FailureMemory.mult() 的公式（逐字抄 failure_memory.gd:154-172）——
# ★為什麼不直接呼叫 production 的 mult()：到這裡時 state 已經被「這一拍」的 record()
#   蓋過（record 在同一 tick 的 sim_runner._step3c_read_market_board 裡先發生），
#   直接呼叫只會拿到「這次失敗之後」的值，答不出「這次重撞發生前，折價是不是已經在生效」。
#   ⇒ 用【上一拍】snapshot 的 entry + 這一拍的 tick，手動重算同一條公式。
#   ★★只唯讀重建，不改動 FailureMemory 本體；公式若將來改了，這裡會漂——已知風險，寫在這裡。
func _recompute_mult(entry: Dictionary, now: int) -> float:
	if entry.is_empty():
		return 1.0
	var ttl: int = int(entry.get("ttl", 0))
	if ttl <= 0:
		return 1.0
	var age: int = now - int(entry.get("tick", 0))
	var freshness: float = clampf(1.0 - float(age) / float(ttl), 0.0, 1.0)
	if freshness <= 0.0:
		return 1.0
	var count_factor: float = float(mini(int(entry.get("count", 1)), FailureMemory.COUNT_CAP))
	return clampf(1.0 - FailureMemory.INTENSITY * count_factor * freshness, FailureMemory.FLOOR, 1.0)


func _run_one_seed(seed_val: int) -> void:
	print("\n########## SEED=%d ##########" % seed_val)
	print("[TREE] HEAD=%s" % _git_head_sha())
	seed(seed_val)
	var ws: WorldState = MeasureBedHelper.arm_and_setup("res://config/default.json", false)
	var runner := SimRunner.new()
	var no_player := Vector2i(-1, -1)
	WorldState.driver_ledger_enabled = true
	WorldState.clear_driver_ledger()

	var day_len: int = WorldState.TICKS_PER_DAY
	var all_arrivals: int = 0
	var was_arrived: Dictionary = {}       # team_id → bool（邊緣偵測）
	# 事件（統一一份，帶兩種零成交判法的旗標 + A2 旁證）：
	#   {day, tick, team, option, market, old_zero, new_zero, a2_recorded, mult_before}
	var all_events: Array = []
	var settled_today_new: Dictionary = {}  # team_id → true（今天 ledger 有 market_*/trade_goods_* 真動過）

	for day in range(TOTAL_DAYS):
		var coin_start: Dictionary = {}
		for tid0 in ws.teams.keys():
			coin_start[int(tid0)] = float(ws.teams[tid0].resources.get("coin", 0.0))
		settled_today_new.clear()
		var arrivals_today: Array = []

		for _i in range(day_len):
			# ★上一拍 snapshot（給⑦重算用；只存輕量 Dictionary，不是整個 team）——
			#   只需要「貿易|<tile>」這個 key 家族，到場時才查，這裡先存一份淺拷貝供查。
			var pre_tick_failures: Dictionary = {}
			for tid_p in ws.teams.keys():
				pre_tick_failures[int(tid_p)] = ws.teams[tid_p].recent_failures.duplicate(true)

			runner.advance_tick(ws, no_player)
			var now_tick: int = ws.world.current_tick

			for entry in WorldState.driver_ledger:
				var ent = entry["entity"]
				if not (ent is TeamData):
					continue
				var reason: String = String(entry["reason"])
				if not (reason.begins_with("market_") or reason.begins_with("trade_goods_")):
					continue
				if is_zero_approx(float(entry["delta"])):
					continue
				settled_today_new[int(ent.team_id)] = true
			WorldState.clear_driver_ledger()

			for tid in ws.teams.keys():
				var t: TeamData = ws.teams[tid]
				var arrived_now: bool = t.current_task == TeamData.TASK_TRADE and SimRunner.trade_arrived(t)
				var prev: bool = bool(was_arrived.get(int(tid), false))
				if arrived_now and not prev:
					all_arrivals += 1
					var market_id: int = int(t.tile_pos.x * 1000 + t.tile_pos.y)
					var fkey: String = "貿易|%d" % market_id
					var post_entry: Dictionary = t.recent_failures.get(fkey, {})
					var a2_recorded: bool = not post_entry.is_empty() and int(post_entry.get("tick", -1)) == now_tick
					var pre_entry: Dictionary = pre_tick_failures.get(int(tid), {}).get(fkey, {})
					var mult_before: float = _recompute_mult(pre_entry, now_tick)
					arrivals_today.append({"team": int(tid), "option": String(t.current_option),
						"market": market_id, "tick": now_tick, "a2_recorded": a2_recorded,
						"mult_before": mult_before})
				was_arrived[int(tid)] = arrived_now

		for a in arrivals_today:
			var tid2: int = int(a["team"])
			if not ws.teams.has(tid2):
				continue
			var coin_end: float = float(ws.teams[tid2].resources.get("coin", 0.0))
			var coin_net: float = coin_end - float(coin_start.get(tid2, coin_end))
			var old_zero: bool = is_zero_approx(coin_net)
			var new_zero: bool = not bool(settled_today_new.get(tid2, false))
			all_events.append({"day": day, "tick": int(a["tick"]), "team": tid2,
				"option": String(a["option"]), "market": int(a["market"]),
				"old_zero": old_zero, "new_zero": new_zero,
				"a2_recorded": bool(a["a2_recorded"]), "mult_before": float(a["mult_before"])})

	print("\n★母體地板：TASK_TRADE 到場總數=%d（為0⇒這個seed不能判）" % all_arrivals)
	if all_arrivals == 0:
		print("[DUMP-PATH] (skipped — empty population)")
		return

	_report_table(all_events, "old_zero", "舊判法（coin淨額==0）")
	_report_table(all_events, "new_zero", "C2′判法（market_*/trade_goods_* 當日無真實流動）")

	# ★(ii) A2 記號有沒有真的寫進去——只對 option=="貿易" 有意義（其它 option 的 FailureMemory
	#   key 標籤不是「貿易」，見 failure_memory.gd:43-56 的 OPTION_FAIL_KEY）
	print("\n========== (ii) 「貿易」零成交事件，A2 記號有沒有真的寫進去（新判法事件）==========")
	var trade_new: Array = []
	for e in all_events:
		if String(e["option"]) == "貿易" and bool(e["new_zero"]):
			trade_new.append(e)
	var a2_yes: int = 0
	for e2 in trade_new:
		if bool(e2["a2_recorded"]):
			a2_yes += 1
	print("  貿易零成交(新判法)事件數=%d｜其中 recent_failures 同拍真的寫進「貿易|市集」的筆數=%d" \
		% [trade_new.size(), a2_yes])

	# ★重撞對 + 折價值 + 巡迴（用新判法的事件序列，同 option="貿易"）
	print("\n========== 「貿易」重撞配對：重撞前折價值 ＋ 兩次之間是否巡迴過別處 ==========")
	_report_recollision_pairs_with_mult(trade_new, all_events)

	# ★★★0 筆記號會不會是本床自己的 key 對不上——用 production 自己的 Probe 計數器交叉驗證
	#   （這兩個 bump 跟 FailureMemory.record 寫在 sim_runner.gd 同一行，不經過本床任何重建）。
	print("\n========== 交叉驗證：production 自己的計數器（不經本床任何key重建）==========")
	print("  Probe trade.arrived_no_deal（同拍會呼 FailureMemory.record 的那個條件）＝ %d 次" \
		% int(Probe.counts.get("trade.arrived_no_deal", 0)))
	print("  Probe trade.meet_nodeal（_resolve_market_at_outpost 回 dealt=false 的通用計數）＝ %d 次" \
		% int(Probe.counts.get("trade.meet_nodeal", 0)))
	print("  Probe trade.deal_market ＋ trade.deal_resident（dealt=true 的兩類）＝ %d ＋ %d" \
		% [int(Probe.counts.get("trade.deal_market", 0)), int(Probe.counts.get("trade.deal_resident", 0))])
	print("  Probe trade.release_at_dest（到場即釋放，母體地板，應≈到場總數）＝ %d" \
		% int(Probe.counts.get("trade.release_at_dest", 0)))

	var out_path: String = "docs/measurements/a2b-recollision-seed%d.jsonl" % seed_val
	var f: FileAccess = FileAccess.open(out_path, FileAccess.WRITE)
	f.store_line(JSON.stringify({"kind": "meta", "tree": _git_head_sha(), "seed": seed_val,
		"total_days": TOTAL_DAYS, "all_arrivals": all_arrivals, "events": all_events.size()}))
	for e4 in all_events:
		f.store_line(JSON.stringify(e4))
	var unmapped_keys: Array = []
	for k in Probe.counts.keys():
		if String(k).begins_with("failure.unmapped."):
			unmapped_keys.append(k)
	unmapped_keys.sort()
	for k3 in unmapped_keys:
		f.store_line(JSON.stringify({"kind": "failure.unmapped", "key": String(k3), "count": int(Probe.counts[k3])}))
	f.close()
	print("\n[DUMP-PATH] %s" % out_path)


func _report_table(events: Array, zero_field: String, label: String) -> void:
	print("\n========== 【%s】②按option分組重撞率／③換地方 ==========" % label)
	var filtered: Array = []
	for e in events:
		if bool(e[zero_field]):
			filtered.append(e)
	var success: Array = []
	for e5 in events:
		if not bool(e5[zero_field]):
			success.append(e5)
	var by_opt: Dictionary = {}
	for e2 in filtered:
		var arr: Array = by_opt.get(String(e2["option"]), [])
		arr.append(e2)
		by_opt[String(e2["option"])] = arr
	var opt_keys: Array = by_opt.keys()
	opt_keys.sort()
	print("  （零成交事件共 %d 筆｜%d 個不同 option）" % [filtered.size(), opt_keys.size()])
	for opt in opt_keys:
		var arr2: Array = by_opt[opt]
		var recollide: int = 0
		var switched: int = 0
		for idx in range(arr2.size()):
			var e1 = arr2[idx]
			for idx2 in range(arr2.size()):
				if idx2 == idx: continue
				var e3 = arr2[idx2]
				if int(e3["team"]) == int(e1["team"]) and int(e3["market"]) == int(e1["market"]) \
						and int(e3["day"]) > int(e1["day"]) \
						and int(e3["day"]) - int(e1["day"]) <= RECOLLISION_WINDOW_DAYS:
					recollide += 1
					break
			for s in success:
				if int(s["team"]) == int(e1["team"]) and int(s["day"]) > int(e1["day"]) \
						and int(s["market"]) != int(e1["market"]):
					switched += 1
					break
		var rate: float = (100.0 * recollide / arr2.size()) if arr2.size() > 0 else 0.0
		print("  option=%-24s｜事件數=%-4d｜重撞數=%-4d｜重撞率=%6.1f%%｜之後換地方成交=%-4d" \
			% [opt, arr2.size(), recollide, rate, switched])


# 把每一筆「貿易」零成交事件配對到它的【下一次】同隊同市集事件（若在7天內），
# 印重撞前（用上一拍snapshot重算）的折價值，並查兩次之間有沒有在別處成交過。
func _report_recollision_pairs_with_mult(trade_new: Array, all_events: Array) -> void:
	var printed: int = 0
	for idx in range(trade_new.size()):
		var e1 = trade_new[idx]
		var best_next = null
		for idx2 in range(trade_new.size()):
			if idx2 == idx: continue
			var e2 = trade_new[idx2]
			if int(e2["team"]) == int(e1["team"]) and int(e2["market"]) == int(e1["market"]) \
					and int(e2["day"]) > int(e1["day"]) \
					and int(e2["day"]) - int(e1["day"]) <= RECOLLISION_WINDOW_DAYS:
				if best_next == null or int(e2["day"]) < int(best_next["day"]):
					best_next = e2
		if best_next == null:
			continue
		var toured: bool = false
		for e3 in all_events:
			if int(e3["team"]) == int(e1["team"]) and not bool(e3["new_zero"]) \
					and int(e3["day"]) > int(e1["day"]) and int(e3["day"]) < int(best_next["day"]) \
					and int(e3["market"]) != int(e1["market"]):
				toured = true
				break
		if printed < 15:
			print("  team=%-3d｜market=%-6d｜day%d→day%d｜重撞前折價(用day%d上一拍snapshot重算)=%.3f｜兩次間巡迴過別處=%s" \
				% [int(e1["team"]), int(e1["market"]), int(e1["day"]), int(best_next["day"]),
					int(best_next["day"]), float(best_next["mult_before"]), str(toured)])
		printed += 1
	print("  （共 %d 對重撞；上面最多印15對，全量在落地檔）" % printed)


func _git_head_sha() -> String:
	var out: Array = []
	OS.execute("git", ["rev-parse", "--short=9", "HEAD"], out, true)
	if out.size() > 0:
		return String(out[0]).strip_edges()
	return "UNKNOWN"
