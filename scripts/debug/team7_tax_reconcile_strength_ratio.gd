extends SceneTree
# @bed-kind: diagnostic
# ★量測員派工（systems 2026-10-06，藍圖收窄成兩錨點）：
# docs/superpowers/handbacks/2026-10-06-systems-to-measurer-team7-tax-reconcile-and-strength-ratio.md
#
# 對帳：Team7 coin/food 在 tick 25260、25320（各±1 tick）的【state 差】vs【帳本重建值】。
# ★先處理 set_amt 缺陷（resource_bank.gd:53 記新值不記delta）：本床【逐 entry 重建】——
#   對每一 tick，從【上一 tick 的真實 state】出發，依 ledger entry 的原始順序逐條套用：
#     add/remove 來源 reason → entry 的 delta 就是真delta，直接加
#     set_amt 來源 reason（名單見 SET_AMT_REASONS，窮舉自全庫 grep "ResourceBank.set_amt("）
#       → entry 記的是【新絕對值】，重建值＝該值；套用後「這條 entry 的真delta」＝新值−套用前的running值
#   套到最後，重建出的最終值要【跟當 tick 真實 state 一致】——不一致＝有不經 ResourceBank 的寫入
#   （★這就是不用等 set_amt 票 merge 也能對的帳：本床不信任 ledger 的 delta 欄位字面值，
#   只信任【真delta來源】與【重建後跟真相的落差】）。
#
# ＋T：11 筆空轉徵收（Team5×9／Team39×1／Team36×1，payer=Team7）各自當下的
#   str_ratio = team_strength(payer)/max(team_strength(collector),0.01)（複製 interaction_system.gd:766）。
#
# 跑法：.\tools\godot.ps1 --headless --script scripts/debug/team7_tax_reconcile_strength_ratio.gd

const SEED: int = 1337
const TOTAL_TICKS: int = 30 * 1440
const TEAM7: int = 7
const ANCHOR_TICKS: Array = [25260, 25320]
const DRY_TRIBUTE_EVENTS: Array = [
	{"tick": 18420, "collector": 5}, {"tick": 20160, "collector": 5}, {"tick": 20220, "collector": 5},
	{"tick": 25260, "collector": 5}, {"tick": 25320, "collector": 5}, {"tick": 26640, "collector": 39},
	{"tick": 27360, "collector": 36}, {"tick": 27660, "collector": 5}, {"tick": 31200, "collector": 5},
	{"tick": 31680, "collector": 5}, {"tick": 31800, "collector": 5},
]
const SET_AMT_REASONS: Array = [
	"loot_mounts_out", "loot_horses_out", "equip_named", "unequip_named", "weapon_recover_anon",
	"auto_withdraw_mounts", "npc_withdraw_vault", "npc_deposit_vault", "init_starting", "init_preset",
	"readiness_food", "raid_out", "aid_out", "deposit_storage", "recruit_anon_pay", "recruit_named_pay",
	"player_take", "overflow_split", "eat_team", "eat_depleted", "provision_carry",
	"spend_holding_team", "subteam_split_in", "merge_absorb_out",
]


func _initialize() -> void:
	var tree_sha: String = _git_head_sha()
	print("[TREE] HEAD=%s" % tree_sha)
	print("[SEED] %d" % SEED)
	print("[SET_AMT_REASONS] 窮舉自 grep \"ResourceBank.set_amt(\" 全庫（%d 個）：%s" \
		% [SET_AMT_REASONS.size(), str(SET_AMT_REASONS)])

	seed(SEED)
	var ws: WorldState = MeasureBedHelper.arm_and_setup("res://config/default.json", false)
	var runner := SimRunner.new()
	var no_player := Vector2i(-1, -1)
	var combat := NpcCombatSystem.new()

	WorldState.driver_ledger_enabled = true
	WorldState.clear_driver_ledger()

	var anchor_ticks_watch: Dictionary = {}   # tick → true（要印詳情的 tick：錨點±1，★擴到全部11筆乾空事件
	for at in ANCHOR_TICKS:                   #  重新核——tick25260/25320 已發現真因是raid_out不是空轉，
		for d in [-1, 0, 1]:                   #  懷疑其餘9筆也是同一個遺漏，擴大檢查範圍一次驗完）
			anchor_ticks_watch[int(at) + d] = true
	for ev3 in DRY_TRIBUTE_EVENTS:
		for d in [-1, 0, 1]:
			anchor_ticks_watch[int(ev3["tick"]) + d] = true
	var dry_event_by_tick: Dictionary = {}
	for ev in DRY_TRIBUTE_EVENTS:
		dry_event_by_tick[int(ev["tick"])] = ev

	var prev_food: float = -1.0
	var prev_coin: float = -1.0
	var reconcile_rows: Array = []     # 每 tick：{tick, coin: {state_delta, rebuilt_delta, match}, food: {...}}
	var mismatch_n: int = 0
	var earliest_tick: int = -1
	var detail_rows: Array = []        # 錨點±1 的逐 entry 明細
	var strength_rows: Array = []

	for _i in range(TOTAL_TICKS):
		runner.advance_tick(ws, no_player)
		var cur_tick: int = ws.world.current_tick

		if not ws.teams.has(TEAM7):
			WorldState.clear_driver_ledger()
			continue
		var t7: TeamData = ws.teams[TEAM7]
		var food_now: float = float(t7.resources.get("food", 0.0))
		var coin_now: float = float(t7.resources.get("coin", 0.0))

		var coin_entries: Array = []
		var food_entries: Array = []
		for entry in WorldState.driver_ledger:
			var ent = entry["entity"]
			if not (ent is TeamData) or int(ent.team_id) != TEAM7:
				continue
			if earliest_tick == -1: earliest_tick = int(entry["tick"])
			var field: String = String(entry["field"])
			if field == "coin": coin_entries.append(entry)
			elif field == "food": food_entries.append(entry)
		WorldState.clear_driver_ledger()

		if prev_coin >= 0.0:
			var coin_res: Dictionary = _reconcile(prev_coin, coin_now, coin_entries)
			var food_res: Dictionary = _reconcile(prev_food, food_now, food_entries)
			if not bool(coin_res["match"]) or not bool(food_res["match"]):
				mismatch_n += 1
			reconcile_rows.append({"tick": cur_tick, "coin": coin_res, "food": food_res})
			if anchor_ticks_watch.has(cur_tick):
				detail_rows.append({"tick": cur_tick, "coin": coin_res, "food": food_res,
					"coin_entries": _entries_to_plain(coin_entries, prev_coin), "food_entries": _entries_to_plain(food_entries, prev_food)})

		prev_food = food_now
		prev_coin = coin_now

		if dry_event_by_tick.has(cur_tick):
			var ev2: Dictionary = dry_event_by_tick[cur_tick]
			var collector_id: int = int(ev2["collector"])
			var s7: float = combat.team_strength(ws, TEAM7)
			var sc: float = combat.team_strength(ws, collector_id)
			var ratio: float = s7 / maxf(sc, 0.01)
			strength_rows.append({"tick": cur_tick, "collector": collector_id, "payer": TEAM7,
				"str_payer": snappedf(s7, 0.01), "str_collector": snappedf(sc, 0.01), "str_ratio": snappedf(ratio, 0.01)})

	print("\n[窗口完整性] Team7 帳本最早一筆 tick=%d（逐tick drain+clear，結構上不會被環形緩衝丟棄）" % earliest_tick)

	print("\n========== 對帳總表（全程 30 天，每 tick 比對） ==========")
	print("[對帳] 可比對 tick 數=%d｜不吻合 tick 數=%d（★set_amt 已逐 entry 重建校正，\
不吻合代表重建值跟真實 state 仍對不上，才是真的盲區訊號）" % [reconcile_rows.size(), mismatch_n])

	print("\n========== 錨點詳情（tick %s，各±1） ==========" % str(ANCHOR_TICKS))
	for row in detail_rows:
		print("--- tick=%d ---" % int(row["tick"]))
		print("  coin: state_delta=%.2f｜重建delta=%.2f｜match=%s" % [
			float(row["coin"]["state_delta"]), float(row["coin"]["rebuilt_delta"]), str(row["coin"]["match"])])
		for e in row["coin_entries"]:
			print("    coin entry｜reason=%-20s｜raw_delta=%.2f｜是否set_amt重建=%s｜重建後真delta=%.2f" % [
				String(e["reason"]), float(e["raw_delta"]), str(e["is_set_amt"]), float(e["rebuilt_delta"])])
		print("  food: state_delta=%.2f｜重建delta=%.2f｜match=%s" % [
			float(row["food"]["state_delta"]), float(row["food"]["rebuilt_delta"]), str(row["food"]["match"])])
		for e in row["food_entries"]:
			print("    food entry｜reason=%-20s｜raw_delta=%.2f｜是否set_amt重建=%s｜重建後真delta=%.2f" % [
				String(e["reason"]), float(e["raw_delta"]), str(e["is_set_amt"]), float(e["rebuilt_delta"])])

	print("\n========== 判讀（藍圖四格） ==========")
	for row in detail_rows:
		if int(row["tick"]) not in ANCHOR_TICKS:
			continue
		var verdict: String = ""
		var ce: Array = row["coin_entries"]
		if ce.is_empty():
			verdict = "(c) 零條目而 state 掉了 ⇒ 不經 ResourceBank 的寫入點（盲區）"
		else:
			var has_tribute_out: bool = false
			var has_non_set_amt_other: bool = false
			for e in ce:
				if String(e["reason"]) == "tribute_out": has_tribute_out = true
				elif not bool(e["is_set_amt"]): has_non_set_amt_other = true
			if has_tribute_out:
				verdict = "(b) 有 tribute_out 條目 ⇒ T 的配對法漏了它"
			elif has_non_set_amt_other:
				verdict = "(a) 有條目、reason 不是 tribute_out（且非 set_amt）⇒ QA 歸因錯"
			else:
				verdict = "(d) 有條目但全部走 set_amt ⇒ 已重建校正，見上面重建後真delta是否吻合 state_delta"
		print("  tick=%d ｜ coin 判讀 = %s" % [int(row["tick"]), verdict])

	print("\n========== ★重新核：11 筆「空轉」徵收，逐筆查 raid_out 是否其實有真轉移 ==========")
	print("（上面兩個錨點已發現真因是 raid_out，不是空轉——懷疑我前一輪 T 分析漏掃 raid_out/raid_in，\
這裡把全部 11 筆都查一次定案）")
	var dry_ticks_set: Dictionary = {}
	for ev4 in DRY_TRIBUTE_EVENTS:
		dry_ticks_set[int(ev4["tick"])] = ev4
	var real_transfer_n: int = 0
	var truly_dry_n: int = 0
	for row2 in detail_rows:
		var tk2: int = int(row2["tick"])
		if not dry_ticks_set.has(tk2):
			continue
		var has_any_entry: bool = not (row2["coin_entries"] as Array).is_empty() \
			or not (row2["food_entries"] as Array).is_empty()
		if has_any_entry:
			real_transfer_n += 1
			var reasons3: Array = []
			for e3 in row2["coin_entries"]: reasons3.append(String(e3["reason"]))
			for e3 in row2["food_entries"]: reasons3.append(String(e3["reason"]))
			print("  tick=%d｜collector=%d｜★有條目(reason=%s)⇒ 不是空轉，QA/T 都要重判" \
				% [tk2, int(dry_ticks_set[tk2]["collector"]), str(reasons3)])
		else:
			truly_dry_n += 1
			print("  tick=%d｜collector=%d｜零條目 ⇒ 真的空轉" % [tk2, int(dry_ticks_set[tk2]["collector"])])
	print("[重新核結論] 11 筆裡：%d 筆其實有真轉移（原「配對器漏了 raid_out/raid_in」）｜%d 筆確認真空轉" \
		% [real_transfer_n, truly_dry_n])

	print("\n========== T：11 筆空轉徵收的兵力比 ==========")
	print("[假設] str_ratio = team_strength(Team7) / max(team_strength(collector),0.01)｜≥3 ⇒ collector 判定\
有效率0（走 `if str_ratio>1.2: base_rate *= ...` 那條，str_ratio越大base_rate被打越低，★但這份只量\
str_ratio不重算base_rate本身，base_rate的真因可能是rate本身而非str_ratio，見下逐行）：")
	for row in strength_rows:
		print("  tick=%d｜collector=%d｜Team7戰力=%.2f｜collector戰力=%.2f｜str_ratio=%.2f%s" % [
			int(row["tick"]), int(row["collector"]), float(row["str_payer"]), float(row["str_collector"]),
			float(row["str_ratio"]), ("｜≥3" if float(row["str_ratio"]) >= 3.0 else "")])

	var out_path: String = "docs/measurements/team7-tax-reconcile-strength-ratio.jsonl"
	var f: FileAccess = FileAccess.open(out_path, FileAccess.WRITE)
	f.store_line(JSON.stringify({"kind": "meta", "tree": tree_sha, "seed": SEED,
		"earliest_tick": earliest_tick, "mismatch_n": mismatch_n, "total_compared": reconcile_rows.size()}))
	for row in detail_rows:
		f.store_line(JSON.stringify({"kind": "anchor_detail", "tick": row["tick"], "coin": row["coin"],
			"food": row["food"], "coin_entries": row["coin_entries"], "food_entries": row["food_entries"]}))
	for row in strength_rows:
		f.store_line(JSON.stringify({"kind": "strength_ratio", "row": row}))
	f.close()
	print("\n[DUMP-PATH] %s" % out_path)
	print("=== team7_tax_reconcile_strength_ratio DONE ===")
	quit(0)


# 逐 entry 重建：從 prev_val 出發，依序套用這一 tick 的 entries，回傳
# {state_delta, rebuilt_delta, match}（rebuilt_delta = 重建出的總變化量）。
func _reconcile(prev_val: float, cur_val: float, entries: Array) -> Dictionary:
	var running: float = prev_val
	for entry in entries:
		var reason: String = String(entry["reason"])
		if SET_AMT_REASONS.has(reason):
			running = float(entry["delta"])   # set_amt 記的是新絕對值
		else:
			running += float(entry["delta"])  # add/remove：真delta
	var state_delta: float = cur_val - prev_val
	var rebuilt_delta: float = running - prev_val
	return {"state_delta": snappedf(state_delta, 0.01), "rebuilt_delta": snappedf(rebuilt_delta, 0.01),
		"match": is_equal_approx(running, cur_val)}


func _entries_to_plain(entries: Array, prev_val: float) -> Array:
	var out: Array = []
	var running: float = prev_val
	for entry in entries:
		var reason: String = String(entry["reason"])
		var is_sa: bool = SET_AMT_REASONS.has(reason)
		var before: float = running
		if is_sa:
			running = float(entry["delta"])
		else:
			running += float(entry["delta"])
		out.append({"reason": reason, "raw_delta": snappedf(float(entry["delta"]), 2),
			"is_set_amt": is_sa, "rebuilt_delta": snappedf(running - before, 2)})
	return out


func _git_head_sha() -> String:
	var out: Array = []
	OS.execute("git", ["rev-parse", "--short=9", "HEAD"], out, true)
	if out.size() > 0:
		return String(out[0]).strip_edges()
	return "UNKNOWN"
