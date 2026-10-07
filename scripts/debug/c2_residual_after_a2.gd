extends SceneTree
# @bed-kind: diagnostic
# ★量測員派工（systems 2026-10-07）：A2 merge 後 C2 殘留 21 隊·日逐筆分類。
# C2 定義照既有床(window_timing_ticketA_ratios.gd)：at_market(outpost_level>0 on 腳下tile)
# 且 current_option=="貿易" 的隊·日，當日 coin 淨額==0。
#
# 對每一筆殘留，判準五類（互斥，以下皆非兜底）：
#   a 只換了貨沒動錢：當日有 trade_goods_in/out(非coin資源)真實流動
#   b 等單中：市集tile.pending_claims 裡有這隊的待領條目，且無a
#   c 路過市集：當日結束時 move_target != (-1,-1)（還在往別處走，不是以這裡為終點），且無a/b
#   d 承諾貿易但卡在別處：current_task 當日序列裡出現跟貿易不相關的任務(表示被仲裁/移動層岔開)，且無a/b/c
#   e 以上皆非
#
# 跑法：.\tools\godot.ps1 --headless --script scripts/debug/c2_residual_after_a2.gd

const SEED: int = 1337
const TOTAL_DAYS: int = 30


func _initialize() -> void:
	var tree_sha: String = _git_head_sha()
	print("[TREE] HEAD=%s" % tree_sha)
	print("[SEED] %d｜殺玩家=否" % SEED)

	seed(SEED)
	var ws: WorldState = MeasureBedHelper.arm_and_setup("res://config/default.json", false)
	var runner := SimRunner.new()
	var no_player := Vector2i(-1, -1)
	WorldState.driver_ledger_enabled = true
	WorldState.clear_driver_ledger()

	var day_len: int = WorldState.TICKS_PER_DAY
	var residuals: Array = []

	for day in range(TOTAL_DAYS):
		var flagged_today: Dictionary = {}       # team_id → true（今天出現過 at_market+貿易）
		var task_seq_today: Dictionary = {}       # team_id → Dictionary(set) of current_task
		var goods_delta_today: Dictionary = {}    # team_id → {res: net_delta}（非coin）
		var coin_start: Dictionary = {}
		for tid0 in ws.teams.keys():
			coin_start[int(tid0)] = float(ws.teams[tid0].resources.get("coin", 0.0))

		for _i in range(day_len):
			runner.advance_tick(ws, no_player)
			for tid in ws.teams.keys():
				var t: TeamData = ws.teams[tid]
				var mtile: HexTileData = ws.world.tiles.get(t.tile_pos.x * 1000 + t.tile_pos.y)
				var at_market: bool = mtile != null and mtile.outpost_level > 0
				if at_market and String(t.current_option) == "貿易":
					flagged_today[int(tid)] = true
				var tset: Dictionary = task_seq_today.get(int(tid), {})
				tset[String(t.current_task)] = true
				task_seq_today[int(tid)] = tset
			for entry in WorldState.driver_ledger:
				var ent = entry["entity"]
				if not (ent is TeamData):
					continue
				var field: String = String(entry["field"])
				if field == "coin":
					continue
				var reason: String = String(entry["reason"])
				if reason != "trade_goods_in" and reason != "trade_goods_out":
					continue
				var etid: int = int(ent.team_id)
				var gd: Dictionary = goods_delta_today.get(etid, {})
				gd[field] = float(gd.get(field, 0.0)) + float(entry["delta"])
				goods_delta_today[etid] = gd
			WorldState.clear_driver_ledger()

		# 日界結算
		for tid2 in flagged_today.keys():
			if not ws.teams.has(tid2):
				continue
			var t2: TeamData = ws.teams[tid2]
			var coin_end: float = float(t2.resources.get("coin", 0.0))
			var coin_net: float = coin_end - float(coin_start.get(tid2, coin_end))
			if not is_zero_approx(coin_net):
				continue
			# 這是一筆 C2 殘留，分類
			var gd2: Dictionary = goods_delta_today.get(tid2, {})
			var has_goods_trade: bool = false
			for res in gd2.keys():
				if not is_zero_approx(float(gd2[res])):
					has_goods_trade = true
					break
			var mtile2: HexTileData = ws.world.tiles.get(t2.tile_pos.x * 1000 + t2.tile_pos.y)
			var market_owner: int = int(mtile2.outpost_owner) if mtile2 != null else -999
			var has_pending_claim: bool = false
			if mtile2 != null:
				for c in mtile2.pending_claims:
					if int(c.get("owner_team", -1)) == int(tid2):
						has_pending_claim = true
						break
			var moving_away: bool = t2.move_target != Vector2i(-1, -1)
			var tasks_today: Array = task_seq_today.get(tid2, {}).keys()
			var non_trade_task: bool = false
			for tk in tasks_today:
				if String(tk) != TeamData.TASK_TRADE:
					non_trade_task = true
					break

			var cls: String = "e_以上皆非"
			if has_goods_trade:
				cls = "a_只換貨沒動錢"
			elif has_pending_claim:
				cls = "b_等單中"
			elif moving_away:
				cls = "c_路過市集"
			elif non_trade_task:
				cls = "d_卡在別處"

			residuals.append({"day": day, "team": tid2, "market_owner": market_owner,
				"tasks_today": tasks_today, "has_goods_trade": has_goods_trade,
				"goods_delta": gd2, "has_pending_claim": has_pending_claim,
				"moving_away": moving_away, "cls": cls})

	print("\n========== C2 殘留分類（共 %d 筆） ==========" % residuals.size())
	var by_cls: Dictionary = {}
	for r in residuals:
		var c: String = String(r["cls"])
		var arr: Array = by_cls.get(c, [])
		arr.append(r)
		by_cls[c] = arr
	var ckeys: Array = by_cls.keys()
	ckeys.sort()
	for ck in ckeys:
		var arr2: Array = by_cls[ck]
		print("\n--- %s（%d 筆） ---" % [ck, arr2.size()])
		for i in range(min(3, arr2.size())):
			var r2 = arr2[i]
			print("  day=%d｜team=%d｜市集主人=team%d｜當日task集合=%s｜有貨交易=%s(%s)｜有待領=%s｜仍在移動=%s" \
				% [int(r2["day"]), int(r2["team"]), int(r2["market_owner"]), str(r2["tasks_today"]),
				str(r2["has_goods_trade"]), str(r2["goods_delta"]), str(r2["has_pending_claim"]), str(r2["moving_away"])])

	print("\n[判讀提示] a類筆數=%d ⇒ %s" % [by_cls.get("a_只換貨沒動錢", []).size(),
		("C2判準把「只換貨沒動錢」誤算進去了，建議普查床排除has_goods_trade=true的情況" \
			if by_cls.get("a_只換貨沒動錢", []).size() > 0 else "C2判準在這個樣本裡沒有誤算a類")])

	var out_path: String = "docs/measurements/c2-residual-after-a2.jsonl"
	var f: FileAccess = FileAccess.open(out_path, FileAccess.WRITE)
	f.store_line(JSON.stringify({"kind": "meta", "tree": tree_sha, "seed": SEED, "total": residuals.size()}))
	for r3 in residuals:
		f.store_line(JSON.stringify(r3))
	f.close()
	print("\n[DUMP-PATH] %s" % out_path)
	print("=== c2_residual_after_a2 DONE ===")
	quit(0)


func _git_head_sha() -> String:
	var out: Array = []
	OS.execute("git", ["rev-parse", "--short=9", "HEAD"], out, true)
	if out.size() > 0:
		return String(out[0]).strip_edges()
	return "UNKNOWN"
