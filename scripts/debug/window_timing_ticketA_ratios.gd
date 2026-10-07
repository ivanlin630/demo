extends SceneTree
# @bed-kind: diagnostic
# ★量測員派工（systems 2026-10-06）②：
# docs/superpowers/handbacks/2026-10-06-systems-to-measurer-team7-combat-trace-and-30day-cost.md ②
#
# 量：seed 1337 跑 7/10/15/30 天各耗幾秒（同機、跑前已確認 Godot 進程數=0）。
# 順手在每個窗印票 A 三格的分子/分母：
#   C1：宣稱建設/紮根的隊數中，material 全程零進出 且 建物欄全程零變化 的隊數
#       （分母=宣稱過的隊數，分子=宣稱且兩者都零效果的隊數）
#   ~~C2：at_market 且 current_option=="貿易" 的 隊·日，其中當日 coin 淨額==0 的比例~~
#       ~~（分母=這樣的隊·日數，分子=其中 coin_net==0 的）~~ —— 舊判準，樹 713c86bd6 seed 1337 30 天＝21
#       ★為何改（spec 2026-10-07-census-c2-counts-the-real-stall，量測員殘量分類）：21 筆裡 a 只換貨沒動錢 3、c 路過 9 是【判準誤算】，
#         b 待領未結清 1、d 混了非貿易任務 6 不是這一格的病；真正想抓的「宣稱貿易而什麼都沒發生」（e）只有 2
#   C2′：隊·日，當日 task 全是貿易 ＋ 某一刻在市集且已抵達（SimRunner.trade_arrived，A2 的抵達判法）
#       ＋ 當日零成交（團隊帳 12 個 reason，見 C2P_DEAL_REASONS）＋ 零待領結清（claim_coin／claim_goods）
#       ★範圍＝task（systems 裁 2026-10-07 甲，RULING-c2prime-task-scope-41）：派出貿易 task 的 option 不只「貿易」
#         （maintain_*:resource／build_workshop／囤貨／買糧 也派 TASK_TRADE）—— 人到市集承諾貿易而什麼都沒發生就是那個病，不因 option 不同而不算
#       ★基準：樹 713c86bd6、seed 1337、30 天 ＝ 41 ＝ option 只有「貿易」10 ＋ 其他 option 派出貿易 task 31（逐筆帶 option 印）
#       ★spec 原寫「應給 2（量測員 e 類）」＝預測不是授權：那 2 是量測員分類床兩條定義的產物——
#         路過＝日終 move_target≠(-1,-1)（A2 判法把 move_target＝所在格算抵達）、換貨＝貨物淨額≠0（帳本 in/out 相抵就看不到）
#         ⇒ 量測員 e 的 day=9 Team20 帳本上有 trade_goods_*／trade_coin_*（與 Team7 對手成交、淨額 0）⇒ C2′ 正確不計
#       ★舊 C2 照印（棘輪讀的仍是它）；C2′ 印在旁邊
#   C3："領取" 剛被 commit（current_option 從別的值變成"領取"）的次數，其中那一 tick coin
#       瞬時無變化的次數（分母=commit 次數，分子=瞬時 coin 不動的次數）
# ★操作定義是我自己訂的（信裡沒逐字給判準），寫清楚讓 systems 核對是否是他要的那個意思。
#
# 跑法：.\tools\godot.ps1 --headless --script scripts/debug/window_timing_ticketA_ratios.gd

const SEED: int = 1337
# ★C2′「零成交」讀【團隊帳】（ResourceBank → driver_ledger，entity 是那支隊）的這 12 個 reason（R² 列全）
#   ★只讀 entity 是 TeamData 且就是那一隊的條目：market_buy_in 同字串也出現在地格帳（TileBank）⇒ 不做全局字串比對
#   ★market_owner_coin_in 記在駐站 owner 那一方 ⇒ 判那一隊時照實（它是 owner 才會有）
const C2P_DEAL_REASONS: Array = [
	"market_buy_coin_out", "market_sell_coin_in", "market_sell_coin_out", "market_inv_coin_in",
	"market_inv_coin_out", "market_owner_coin_in", "trade_coin_in", "trade_coin_out",
	"market_buy_in", "market_inv_in", "trade_goods_in", "trade_goods_out"]
const C2P_CLAIM_REASONS: Array = ["claim_coin", "claim_goods"]
const C2P_BASELINE_30D: int = 41   # 樹 713c86bd6（spec 指定的修前樹）量得：option＝貿易 10＋其他 option 31
const WINDOWS_DAYS: Array = [7, 10, 15, 30]
const CLAIM_BUILDING_OPTS: Array = ["建設", "紮根"]
const FACILITY_LEVEL_FIELDS: Array = ["outpost_level", "camp_level", "farming_level",
	"manufacturing_level", "stable_level", "apothecary_level", "smelter_level",
	"weaponsmith_level", "armorsmith_level", "mint_level"]


func _initialize() -> void:
	var tree_sha: String = _git_head_sha()
	print("[TREE] HEAD=%s" % tree_sha)
	print("[SEED] %d" % SEED)

	_c2p_selftest()
	var results: Array = []
	for n in WINDOWS_DAYS:
		print("\n########## N=%d 天 ##########" % n)
		var r: Dictionary = _run_window(int(n))
		results.append(r)
		print("[N=%d] 耗時=%.2fs｜C1=%d/%d｜C2=%d/%d｜C3=%d/%d｜C2′=%d" % [
			int(n), float(r["seconds"]), int(r["c1_num"]), int(r["c1_den"]),
			int(r["c2_num"]), int(r["c2_den"]), int(r["c3_num"]), int(r["c3_den"]), int(r["c2p"])])
		# ★C2′ 拆兩行（systems 裁甲：母體＝task；拆行＝option 的資訊不丟），逐筆帶 option
		for want_trade in [true, false]:
			var part: Array = []
			for row in r["c2p_rows"]:
				if bool(row["trade_option_only"]) == want_trade:
					part.append("day=%d team=%d %s" % [int(row["day"]), int(row["team"]), str(row["options"])])
			print("[N=%d] C2′ %s＝%d：%s" % [int(n), "option 只有「貿易」" if want_trade else "其他 option 派出貿易 task",
				part.size(), "｜".join(PackedStringArray(part))])
		if int(n) == 30:
			print("[N=30] C2′＝%d｜基準（樹 713c86bd6）＝%d｜%s" % [int(r["c2p"]), C2P_BASELINE_30D,
				"同" if int(r["c2p"]) == C2P_BASELINE_30D else "★不同"])

	print("\n========== 彙總（seed 1337，同機） ==========")
	print("N天｜耗時(s)｜C1分子/分母｜C2分子/分母｜C3分子/分母")
	for r in results:
		print("%2d｜%7.2f｜%d/%d｜%d/%d｜%d/%d" % [
			int(r["days"]), float(r["seconds"]), int(r["c1_num"]), int(r["c1_den"]),
			int(r["c2_num"]), int(r["c2_den"]), int(r["c3_num"]), int(r["c3_den"])])

	var out_path: String = "docs/measurements/window-timing-ticketA-ratios.jsonl"
	var f: FileAccess = FileAccess.open(out_path, FileAccess.WRITE)
	f.store_line(JSON.stringify({"kind": "meta", "tree": tree_sha, "seed": SEED}))
	for r in results:
		f.store_line(JSON.stringify(r))
	f.close()
	print("\n[DUMP-PATH] %s" % out_path)
	print("=== window_timing_ticketA_ratios DONE ===")
	quit(0)


func _run_window(days: int) -> Dictionary:
	var t_start: int = Time.get_ticks_msec()
	seed(SEED)
	var ws: WorldState = MeasureBedHelper.arm_and_setup("res://config/default.json", false)
	var runner := SimRunner.new()
	var no_player := Vector2i(-1, -1)
	var day_len: int = WorldState.TICKS_PER_DAY

	var claimed_building: Dictionary = {}
	var material_prev: Dictionary = {}
	var material_moved: Dictionary = {}
	var building_sig_prev: Dictionary = {}
	var building_changed: Dictionary = {}

	var c2_num: int = 0; var c2_den: int = 0
	var c3_num: int = 0; var c3_den: int = 0
	var coin_prev_day: Dictionary = {}       # team_id → 上一日期末 coin
	var flagged_today: Dictionary = {}       # team_id → bool（今天有沒有出現 at_market+貿易）
	var coin_at_day_start: Dictionary = {}   # team_id → 今天開始時的 coin（給 C2 用，等同上一日期末）
	var prev_option: Dictionary = {}         # team_id → 上一 tick 的 current_option
	var prev_coin_tick: Dictionary = {}      # team_id → 上一 tick 的 coin（給 C3 瞬時比較）
	# ── C2′ ──
	var c2p_rows: Array = []
	var c2p_tasks: Dictionary = {}           # team_id → {task: true}（今天出現過的 task）
	var c2p_arrived: Dictionary = {}         # team_id → 今天某一刻在市集且已抵達
	var c2p_reasons: Dictionary = {}         # team_id → [今天團隊帳上的 reason]
	var c2p_opts: Dictionary = {}            # team_id → {current_option: true}（今天出現過的 option；逐筆印、拆兩行用）
	WorldState.driver_ledger_enabled = true
	WorldState.clear_driver_ledger()

	for day in range(days):
		for _i in range(day_len):
			runner.advance_tick(ws, no_player)
			for tid in ws.teams.keys():
				var t: TeamData = ws.teams[tid]
				if CLAIM_BUILDING_OPTS.has(String(t.current_option)):
					claimed_building[int(tid)] = true
				var coin_now: float = float(t.resources.get("coin", 0.0))

				# C2：at_market + 貿易 當日旗標
				var mtile: HexTileData = ws.world.tiles.get(t.tile_pos.x * 1000 + t.tile_pos.y)
				var at_market: bool = mtile != null and mtile.outpost_level > 0
				if at_market and String(t.current_option) == "貿易":
					flagged_today[int(tid)] = true
				# C2′
				var ts: Dictionary = c2p_tasks.get(int(tid), {})
				ts[String(t.current_task)] = true
				c2p_tasks[int(tid)] = ts
				var os_: Dictionary = c2p_opts.get(int(tid), {})
				os_[String(t.current_option)] = true
				c2p_opts[int(tid)] = os_
				if at_market and SimRunner.trade_arrived(t):
					c2p_arrived[int(tid)] = true

				# C3：「領取」剛被 commit（上一tick不是,這一tick是）
				var popt: String = String(prev_option.get(tid, ""))
				if String(t.current_option) == "領取" and popt != "領取":
					c3_den += 1
					var pcoin: float = float(prev_coin_tick.get(tid, coin_now))
					if is_equal_approx(pcoin, coin_now):
						c3_num += 1
				prev_option[tid] = t.current_option
				prev_coin_tick[tid] = coin_now
			# C2′：只讀團隊帳（entity 是 TeamData）—— 同一個 reason 字串也出現在地格帳，不做全局比對
			for entry in WorldState.driver_ledger:
				var ent = entry["entity"]
				if not (ent is TeamData):
					continue
				var etid: int = int((ent as TeamData).team_id)
				var rs: Array = c2p_reasons.get(etid, [])
				rs.append(String(entry["reason"]))
				c2p_reasons[etid] = rs
			WorldState.clear_driver_ledger()

		# 日界：Q-material 累計
		for tid2 in ws.teams.keys():
			var t2: TeamData = ws.teams[tid2]
			var mat: float = float(t2.resources.get("material", 0.0))
			if material_prev.has(tid2) and not is_equal_approx(float(material_prev[tid2]), mat):
				material_moved[int(tid2)] = true
			material_prev[tid2] = mat
			var sig: int = _building_signature(ws, tid2)
			if building_sig_prev.has(tid2) and int(building_sig_prev[tid2]) != sig:
				building_changed[int(tid2)] = true
			building_sig_prev[tid2] = sig

		# 日界：C2 結算（今天有旗標的隊，比對今天期末 coin vs 昨天期末 coin）
		for tid3 in ws.teams.keys():
			var t3: TeamData = ws.teams[tid3]
			var coin_end: float = float(t3.resources.get("coin", 0.0))
			if bool(flagged_today.get(tid3, false)) and coin_prev_day.has(tid3):
				c2_den += 1
				if is_equal_approx(float(coin_prev_day[tid3]), coin_end):
					c2_num += 1
			coin_prev_day[tid3] = coin_end
		flagged_today.clear()
		# C2′ 日界結算
		var c2p_ids: Array = c2p_tasks.keys()
		c2p_ids.sort()
		for tid5 in c2p_ids:
			if c2p_is_stall(c2p_tasks[tid5], bool(c2p_arrived.get(tid5, false)), c2p_reasons.get(tid5, [])):
				var ok5: Array = (c2p_opts.get(tid5, {}) as Dictionary).keys()
				ok5.sort()
				c2p_rows.append({"day": day, "team": int(tid5), "options": ok5,
					"trade_option_only": ok5 == ["貿易"]})
		c2p_tasks.clear()
		c2p_opts.clear()
		c2p_arrived.clear()
		c2p_reasons.clear()

	var claimed_n: int = 0; var c1_num: int = 0
	for tid4 in ws.teams.keys():
		if bool(claimed_building.get(tid4, false)):
			claimed_n += 1
			if not bool(material_moved.get(tid4, false)) and not bool(building_changed.get(tid4, false)):
				c1_num += 1

	WorldState.driver_ledger_enabled = false   # ★靜態開關：跑完關掉、清掉（跨 run 不得殘留）
	WorldState.clear_driver_ledger()
	var elapsed_s: float = float(Time.get_ticks_msec() - t_start) / 1000.0
	return {"days": days, "seconds": elapsed_s, "final_tick": ws.world.current_tick,
		"c1_num": c1_num, "c1_den": claimed_n, "c2_num": c2_num, "c2_den": c2_den,
		"c3_num": c3_num, "c3_den": c3_den, "c2p": c2p_rows.size(), "c2p_rows": c2p_rows}


# ══ C2′ 的判定（唯一一份；實跑與反向自測都呼它）════════════════════════════════════════════════════
static func c2p_is_stall(tasks_today: Dictionary, arrived_at_market: bool, reasons_today: Array) -> bool:
	if tasks_today.size() != 1 or not tasks_today.has(TeamData.TASK_TRADE):
		return false
	if not arrived_at_market:
		return false
	for r in reasons_today:
		if C2P_DEAL_REASONS.has(String(r)) or C2P_CLAIM_REASONS.has(String(r)):
			return false
	return true


# ★反向（spec P2）：只換貨（food 成交、coin 不動）不計；路過不計；★正對照：全天貿易、抵達、零成交零待領 ⇒ 計
func _c2p_selftest() -> void:
	var trade_only: Dictionary = {TeamData.TASK_TRADE: true}
	var rows: Array = [
		["只換貨（trade_goods_in，coin 不動）", c2p_is_stall(trade_only, true, ["trade_goods_in"]), false],
		["路過（沒有抵達市集）", c2p_is_stall(trade_only, false, []), false],
		["混了非貿易任務", c2p_is_stall({TeamData.TASK_TRADE: true, TeamData.TASK_IDLE: true}, true, []), false],
		["待領結清（claim_goods）", c2p_is_stall(trade_only, true, ["claim_goods"]), false],
		["全天貿易、抵達、零成交零待領", c2p_is_stall(trade_only, true, ["fatigue_whatever"]), true],
	]
	var bad: int = 0
	for r in rows:
		var ok: bool = bool(r[1]) == bool(r[2])
		if not ok:
			bad += 1
		print("[C2′ 自測] %s ⇒ 計入 %s（應 %s）%s" % [r[0], str(r[1]), str(r[2]), "" if ok else "  ✗"])
	print("[C2′ 自測] %s" % ("全對" if bad == 0 else "錯 %d" % bad))


func _building_signature(ws: WorldState, team_id: int) -> int:
	var sig: int = 0
	for tid in ws.world.tiles:
		var t: HexTileData = ws.world.tiles[tid]
		if int(t.outpost_owner) != int(team_id):
			continue
		for f in FACILITY_LEVEL_FIELDS:
			sig += int(t.get(f))
	return sig


func _git_head_sha() -> String:
	var out: Array = []
	OS.execute("git", ["rev-parse", "--short=9", "HEAD"], out, true)
	if out.size() > 0:
		return String(out[0]).strip_edges()
	return "UNKNOWN"
