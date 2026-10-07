extends SceneTree
# @bed-kind: diagnostic
# A2b 前置量測（systems 派工 2026-10-07，純讀不改世界）：
#   docs/superpowers/handbacks/2026-10-07-systems-to-measurer-DISPATCH-a2b-recollision-rate.md
# 問題：貿易到場零成交之後，同一隊、同一 option、同一市集在 7 天內再撞的比例，按 option 分組；
#   三個 seed 各 30 天；附 failure.unmapped.* 的 distinct key（母體多大）。純聚合，不下因果結論。
#
# ★事件判法（照派工信「判法照 C2′ 那支床」＝ c2_residual_after_a2.gd 的方法，延伸成多 option）：
#   ①識別「到場」：重用 production 自己的判法 `SimRunner.trade_arrived(t)`（sim_runner.gd:901，
#     `current_task==TASK_TRADE and (move_target==(-1,-1) or tile_pos==move_target)`）——
#     ★★這個條件在抵達之後【會連續多拍為真】直到隊被派新單，不能逐拍都算一次「到場」事件，
#     ⇒ 用邊緣偵測（上一拍非到場→這一拍到場）取事件發生的那一拍，事件身分＝(day, team, option, market_tile)。
#   ②識別「零成交」：沿用 C2′ 的日粒度（當日 coin 淨額==0）——這是派工信字面「當日零成交」，
#     與 A2 production 自己的單拍 `_dealt` 旗標是【兩個粒度】，此處誠實選日粒度（派工信明寫，不是我選的）。
#   ③「option」：options.gd 裡設 task=TASK_TRADE 的有 4 個（貿易／領取／買糧／囤貨）——
#     抵達那一拍讀 team.current_option 即為分組鍵。
#   ④重撞：同一(team,option,market) 的下一次到場零成交事件，與上一次事件相差天數 ≤7。
#   ⑤換地方了：同一 team 之後（不限 7 天內）在【不同 market】、同日 coin 淨額≠0（當天真的有成交）。
#
# 跑法：.\tools\godot.ps1 --headless --script scripts/debug/a2b_recollision_rate.gd

const SEEDS: Array = [1337, 2024, 7]
const TOTAL_DAYS: int = 30
const RECOLLISION_WINDOW_DAYS: int = 7
const TRADE_OPTIONS: Array = ["貿易", "領取", "買糧", "囤貨"]   # options.gd 裡 to_task 設 TASK_TRADE 的全部


func _initialize() -> void:
	for sd in SEEDS:
		_run_one_seed(int(sd))
	print("\n=== a2b_recollision_rate DONE（%d 個 seed）===" % SEEDS.size())
	quit(0)


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
	var events: Array = []          # {day, team, option, market}（到場零成交，已過濾）
	var all_arrivals: int = 0       # 母體地板：TASK_TRADE 到場總數（不管零不零成交）
	var success_by_team: Array = []  # {day, team, market}（當日有真的成交，任何 option）
	var was_arrived: Dictionary = {}  # team_id → bool（上一拍是否 trade_arrived，做邊緣偵測）

	for day in range(TOTAL_DAYS):
		var coin_start: Dictionary = {}
		for tid0 in ws.teams.keys():
			coin_start[int(tid0)] = float(ws.teams[tid0].resources.get("coin", 0.0))
		var arrivals_today: Array = []   # {team, option, market}（這一天邊緣觸發的到場）

		for _i in range(day_len):
			runner.advance_tick(ws, no_player)
			for tid in ws.teams.keys():
				var t: TeamData = ws.teams[tid]
				var arrived_now: bool = t.current_task == TeamData.TASK_TRADE and SimRunner.trade_arrived(t)
				var prev: bool = bool(was_arrived.get(int(tid), false))
				if arrived_now and not prev:
					all_arrivals += 1
					arrivals_today.append({"team": int(tid), "option": String(t.current_option),
						"market": int(t.tile_pos.x * 1000 + t.tile_pos.y)})
				was_arrived[int(tid)] = arrived_now
			WorldState.clear_driver_ledger()   # 本床不用 ledger 細節，C2′沿用的欄位已夠；保持 bounded

		# 日界：對今天邊緣觸發的每一筆到場，查「當日 coin 淨額」判零不零成交
		for a in arrivals_today:
			var tid2: int = int(a["team"])
			if not ws.teams.has(tid2):
				continue
			var coin_end: float = float(ws.teams[tid2].resources.get("coin", 0.0))
			var coin_net: float = coin_end - float(coin_start.get(tid2, coin_end))
			if is_zero_approx(coin_net):
				events.append({"day": day, "team": tid2, "option": String(a["option"]), "market": int(a["market"])})
			else:
				success_by_team.append({"day": day, "team": tid2, "market": int(a["market"])})

	# ── ①逐筆（每 option 最多印 3 筆示例，全量進落地檔）──────────────────────
	print("\n========== ①到場零成交事件（共 %d 筆｜母體地板 TASK_TRADE 到場總數=%d）==========" \
		% [events.size(), all_arrivals])
	if all_arrivals == 0:
		print("★★★母體地板=0 ⇒ 這個 seed 不能判（世界裡沒有一次 TASK_TRADE 到場）")

	var by_opt: Dictionary = {}
	for e in events:
		var arr: Array = by_opt.get(String(e["option"]), [])
		arr.append(e)
		by_opt[String(e["option"])] = arr
	# ★★★母體不手抄——用【實際出現過的 option 字串】分組，不是靠 options.gd 裡
	#   TASK_TRADE 的 4 個手列（TRADE_OPTIONS）。第一輪拿 TRADE_OPTIONS 當分組清單，
	#   三個 seed 的事件數加總都兜不起來（seed1337 的 43 筆只對到 19 筆）——
	#   漏的那批是 `goal_resolver.gd` means-end 路徑生出的 TASK_TRADE 候選
	#   （:971/:981/:1086，「穿著別的 goal 名字」，current_option 不是那 4 個字串之一）。
	#   ⇒ 改成【這裡印什麼分組，就是資料裡真的有什麼】，TRADE_OPTIONS 只留著當旁證對照。
	var opt_keys: Array = by_opt.keys()
	opt_keys.sort()
	var _known_sum: int = 0
	for _k in TRADE_OPTIONS:
		_known_sum += int(by_opt.get(_k, []).size())
	print("   ★母體對帳：options.gd 手列 4 個 option 共 %d 筆｜實際發生 %d 個不同 option 共 %d 筆" \
		% [_known_sum, opt_keys.size(), events.size()])

	# ── ②按 option 分組：事件數／重撞數／重撞率 ──────────────────────────────
	print("\n========== ②按 option 分組：重撞率（7天內同隊同option同市集再撞）==========")
	for opt in opt_keys:
		var arr2: Array = by_opt.get(opt, [])
		var recollide: int = 0
		for idx in range(arr2.size()):
			var e1 = arr2[idx]
			for idx2 in range(arr2.size()):
				if idx2 == idx: continue
				var e2 = arr2[idx2]
				if int(e2["team"]) == int(e1["team"]) and int(e2["market"]) == int(e1["market"]) \
						and int(e2["day"]) > int(e1["day"]) \
						and int(e2["day"]) - int(e1["day"]) <= RECOLLISION_WINDOW_DAYS:
					recollide += 1
					break
		var rate: float = (100.0 * recollide / arr2.size()) if arr2.size() > 0 else 0.0
		print("  option=%-4s｜事件數=%-4d｜重撞數=%-4d｜重撞率=%.1f%%" % [opt, arr2.size(), recollide, rate])
		for i in range(min(3, arr2.size())):
			print("    例｜day=%d｜team=%d｜market=%d" % [int(arr2[i]["day"]), int(arr2[i]["team"]), int(arr2[i]["market"])])

	# ── ③按 option 分組：同隊之後換地方且成交 ────────────────────────────────
	print("\n========== ③按 option 分組：同隊之後換了別的市集且成交的筆數 ==========")
	for opt in opt_keys:
		var arr3: Array = by_opt.get(opt, [])
		var switched: int = 0
		for e3 in arr3:
			for s in success_by_team:
				if int(s["team"]) == int(e3["team"]) and int(s["day"]) > int(e3["day"]) \
						and int(s["market"]) != int(e3["market"]):
					switched += 1
					break
		print("  option=%-4s｜事件數=%-4d｜之後換地方成交=%-4d" % [opt, arr3.size(), switched])

	# ── ④failure.unmapped.* distinct key 與次數（母體多大）────────────────────
	print("\n========== ④failure.unmapped.* distinct key（母體地板：決策引擎評估過幾種「無折價接線」的 option）==========")
	var unmapped_keys: Array = []
	for k in Probe.counts.keys():
		if String(k).begins_with("failure.unmapped."):
			unmapped_keys.append(k)
	unmapped_keys.sort()
	if unmapped_keys.is_empty():
		print("  ★0 個 distinct key（Probe.enabled=%s；若 enabled 仍 0，代表這個 seed 30 天內沒有任何一次決策評估踩到未接線的 option）" % str(Probe.enabled))
	for k2 in unmapped_keys:
		print("  %s ＝ %d 次" % [String(k2), int(Probe.counts[k2])])

	var out_path: String = "docs/measurements/a2b-recollision-seed%d.jsonl" % seed_val
	var f: FileAccess = FileAccess.open(out_path, FileAccess.WRITE)
	f.store_line(JSON.stringify({"kind": "meta", "tree": _git_head_sha(), "seed": seed_val,
		"total_days": TOTAL_DAYS, "all_arrivals": all_arrivals, "events": events.size()}))
	for e4 in events:
		f.store_line(JSON.stringify(e4))
	for k3 in unmapped_keys:
		f.store_line(JSON.stringify({"kind": "failure.unmapped", "key": String(k3), "count": int(Probe.counts[k3])}))
	f.close()
	print("\n[DUMP-PATH] %s" % out_path)


func _git_head_sha() -> String:
	var out: Array = []
	OS.execute("git", ["rev-parse", "--short=9", "HEAD"], out, true)
	if out.size() > 0:
		return String(out[0]).strip_edges()
	return "UNKNOWN"
