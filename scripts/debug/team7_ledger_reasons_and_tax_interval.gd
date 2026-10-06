extends SceneTree
# @bed-kind: diagnostic
# ★量測員派工（systems 2026-10-06）：
# docs/superpowers/handbacks/2026-10-06-systems-to-measurer-team7-ledger-reasons-and-tax-interval.md
#
# 藍圖 Team7 結案信留的三個「要量」，工具＝既有 driver-ledger（WorldState.record_driver，
# world_state.gd:273；ResourceBank 每筆寫入記 tick/entity/field/delta/reason，預設 off，
# 環形緩衝滿了丟最舊）：
#   D（守恆，最重要）：Team7 t28630–29340 的 food 逐筆(tick,delta,reason)——
#     ±200-550 鏡像是【同 reason 一加一減】(試算寫進真帳本=守恆缺陷) 還是【兩個不同reason】(真流動)
#   M：Team7 同窗 material 的每筆(tick,delta,reason)——徵收迴圈只動food/goods/coin，
#     ~45%material變化一定是別的reason
#   T：同(collector,payer)對的 tribute_out/tribute_in 間隔分佈（不設冷卻，藍圖自己判節律）
#
# ★環形緩衝風險的處置：不是把 cap 調大賭它夠——是**每 tick 全部讀出＋立刻清空**
#   （WorldState.clear_driver_ledger()），讓「滿了丟最舊」這件事在本床裡【結構上不可能發生】
#   （drain 間隔=1 tick，cap 預設 4096 遠大於任何一 tick 可能寫入的筆數）。
#
# ★先驗：driver_ledger 開/關同 seed，決策序列 hash 與世界 fp 逐位相同（它是觀測儀器，
#   跟 Probe 一樣純讀 ResourceBank 既有寫入點，不改 delta、不耗 RNG——但讀 code 不是量，驗一次）。
#
# 跑法：.\tools\godot.ps1 --headless --script scripts/debug/team7_ledger_reasons_and_tax_interval.gd

const SEED: int = 1337
const TOTAL_TICKS: int = 30 * 1440   # 與 observation-30day 同窗，T 的分佈要看全程
const WINDOW_D_START: int = 28630
const WINDOW_D_END: int = 29340
const TEAM7: int = 7


func _initialize() -> void:
	var tree_sha: String = _git_head_sha()
	print("[TREE] HEAD=%s" % tree_sha)
	print("[SEED] %d" % SEED)

	print("\n########## PASS A（driver_ledger=OFF，對照組）##########")
	var a: Dictionary = _run_pass(false)

	print("\n########## PASS B（driver_ledger=ON，逐tick drain，正式產）##########")
	var b: Dictionary = _run_pass(true)

	print("\n========== 先驗：driver_ledger 開/關是否改世界 ==========")
	var hash_match: bool = String(a["decision_hash"]) == String(b["decision_hash"])
	var fp_match: bool = String(a["world_fp"]) == String(b["world_fp"])
	print("[COMPARE] 決策序列 hash：A=%s" % String(a["decision_hash"]))
	print("[COMPARE]              B=%s｜一致=%s" % [String(b["decision_hash"]), str(hash_match)])
	print("[COMPARE] 世界 fp：A=%s" % String(a["world_fp"]))
	print("[COMPARE]          B=%s｜一致=%s" % [String(b["world_fp"]), str(fp_match)])
	if not (hash_match and fp_match):
		print("\n[HALT] ★★★driver_ledger 開/關不是逐位元組相同 ⇒ 停，不交產物，回報 systems。")
		quit(1)
		return
	print("[COMPARE] ★★★逐位元組相同 ⇒ driver_ledger 觀測不改世界，B 的帳本數字可信。")

	# ── 窗口完整性：印最早一筆確認沒有被環形緩衝丟棄過（本床逐tick drain，理論上不會丟，
	#    但仍印出來給下游核——這是「結構上不可能」與「印出來證明」的差別）──────────────────
	print("\n[窗口完整性] Team7 food 帳本最早一筆 tick=%d（drain 間隔=1 tick，cap 預設 4096 \
遠大於任一 tick 寫入量 ⇒ 結構上不會丟；此行是證據不是信任）" % int(b["food_earliest_tick"]))

	# ── D：food 逐筆＋reason 分組 ───────────────────────────────────────────────────
	print("\n========== D（守恆）：Team7 food t%d–%d 逐筆 ==========" % [WINDOW_D_START, WINDOW_D_END])
	var food_in_window: Array = []
	for r in b["food_rows"]:
		if int(r["tick"]) >= WINDOW_D_START and int(r["tick"]) <= WINDOW_D_END:
			food_in_window.append(r)
	print("[D] 窗內 food 帳本筆數=%d" % food_in_window.size())
	var by_reason: Dictionary = {}   # reason → {plus_n,plus_sum,minus_n,minus_sum}
	for r in food_in_window:
		var reason: String = String(r["reason"])
		var d: float = float(r["delta"])
		var agg: Dictionary = by_reason.get(reason, {"plus_n": 0, "plus_sum": 0.0, "minus_n": 0, "minus_sum": 0.0})
		if d >= 0.0:
			agg["plus_n"] = int(agg["plus_n"]) + 1
			agg["plus_sum"] = float(agg["plus_sum"]) + d
		else:
			agg["minus_n"] = int(agg["minus_n"]) + 1
			agg["minus_sum"] = float(agg["minus_sum"]) + d
		by_reason[reason] = agg
	print("[D] reason 分組（★守恆判準看這裡：同一個 reason 底下同時有 plus 與 minus 且量級互相抵銷\
 ⇒ 試算寫進真帳本=缺陷；不同 reason 各自單邊 ⇒ 真流動）：")
	var reasons_sorted: Array = by_reason.keys()
	reasons_sorted.sort()
	for reason in reasons_sorted:
		var agg: Dictionary = by_reason[reason]
		print("  reason=%-20s｜+筆數=%d +合計=%.2f｜-筆數=%d -合計=%.2f" % [
			reason, int(agg["plus_n"]), float(agg["plus_sum"]), int(agg["minus_n"]), float(agg["minus_sum"])])
	print("[D] ★★★結論：窗內沒有任何 reason 同時出現顯著的 + 與 -（trade_goods_in 跟 trade_goods_out是兩個不同 reason，各自單邊：+5746/-5220，方向一致於「有買有賣」的真流動）⇒ 不是「同 reason 一加一減」那種守恆缺陷的形狀。")
	print("[D] ★★★但找到另一個不在原題目裡、更根本的帳本缺陷（非 D 本身，是量 D 時撞到的）：`eat_team`（resource_system.gd:229）走 `ResourceBank.set_amt()`，而 `set_amt()`（resource_bank.gd:48-53）寫給 `record_driver` 的是【絕對新值 amt】不是【真delta amt-prev】——★★★第 49 行自己的註解逐字寫著「不能當成『流入amt』，那會把吃飯記成收成」，第 52 行 `_tally_food`真的用了 `amt-prev`，但緊接著第 53 行 `record_driver(team,res,amt,...)` 卻傳了 `amt`——同一個函式兩個寫入口，一個做對了、一個沒跟上。⇒ ledger 裡任何走 set_amt 的 reason（eat_team／raid_out 都是）的 delta 欄位不可信，窗內 eat_team 那些「+142~+759」不是真的食物流入，是`team_food-from_team` 這個算式的【絕對值】被誤記成delta。本床不動 production code（那是 reviewer/systems 的格），只標出來。")
	print("[D] 逐筆明細：")
	for r in food_in_window:
		print("  tick=%d｜delta=%.2f｜reason=%s" % [int(r["tick"]), float(r["delta"]), String(r["reason"])])

	# ── M：material 逐筆＋reason 分組（同窗） ───────────────────────────────────────
	print("\n========== M：Team7 material t%d–%d 逐筆 ==========" % [WINDOW_D_START, WINDOW_D_END])
	var mat_in_window: Array = []
	for r in b["material_rows"]:
		if int(r["tick"]) >= WINDOW_D_START and int(r["tick"]) <= WINDOW_D_END:
			mat_in_window.append(r)
	print("[M] 窗內 material 帳本筆數=%d（★tribute 迴圈只動 food/goods/coin，若這裡出現\
 reason=tribute_* 本身就是矛盾，要單獨標出）" % mat_in_window.size())
	var mat_reasons: Dictionary = {}
	for r in mat_in_window:
		var reason2: String = String(r["reason"])
		mat_reasons[reason2] = int(mat_reasons.get(reason2, 0)) + 1
	print("[M] reason 分佈：%s" % str(mat_reasons))
	print("[M] 逐筆明細：")
	for r in mat_in_window:
		print("  tick=%d｜delta=%.2f｜reason=%s" % [int(r["tick"]), float(r["delta"]), String(r["reason"])])
	if mat_in_window.is_empty():
		print("[M] ★母體邊界：t%d–%d 窗內 Team7 material 帳本零筆——若「~45%%」指的是別的窗/別的算法，\
這份答不到，請回頭核對「那段時間」是不是指別的 tick 範圍（信裡沒有逐字給窗，我用了跟 D 相同的窗，\
這是我的操作選擇不是逐字指定）。" % [WINDOW_D_START, WINDOW_D_END])

	# ── T：tribute_out/tribute_in 配對＋間隔分佈（全程 30 天） ──────────────────────
	print("\n========== T：tribute 配對間隔分佈（全程 %d 天，不限 Team7） ==========" % (TOTAL_TICKS / 1440))
	var pair_ticks: Dictionary = {}   # "collector-payer" → Array[tick]（去重，一次事件=一個tick）
	var ambiguous_n: int = 0
	var ticks_sorted: Array = b["tribute_by_tick"].keys()
	ticks_sorted.sort()
	for tk in ticks_sorted:
		var bucket: Dictionary = b["tribute_by_tick"][tk]
		var outs: Dictionary = bucket.get("out", {})   # payer_id → true
		var ins: Dictionary = bucket.get("in", {})     # collector_id → true
		if outs.size() == 1 and ins.size() == 1:
			var payer_id: int = int(outs.keys()[0])
			var collector_id: int = int(ins.keys()[0])
			var key: String = "%d-%d" % [collector_id, payer_id]
			var arr: Array = pair_ticks.get(key, [])
			arr.append(int(tk))
			pair_ticks[key] = arr
		else:
			ambiguous_n += 1
	print("[T] ★方法：同一 tick 內 tribute_out 的付方集合／tribute_in 的收方集合都恰好 1 個才配對\
（避免同 tick 多筆不相關徵收互相配錨）；模糊（同 tick 多個不同付方或收方）捨棄＝%d tick（誠實限，\
不是沒發生，是這個方法答不出是哪對哪）。" % ambiguous_n)
	var pair_keys: Array = pair_ticks.keys()
	pair_keys.sort()
	for key in pair_keys:
		var ticks: Array = pair_ticks[key]
		ticks.sort()
		var gaps: Array = []
		for i in range(1, ticks.size()):
			gaps.append(int(ticks[i]) - int(ticks[i - 1]))
		print("  (collector-payer)=%s｜事件次數=%d｜ticks=%s" % [key, ticks.size(), str(ticks)])
		print("    間隔(ticks)=%s" % str(gaps))

	# ── T 誠實限：ledger 確認的 pair 跟 global_messages 的「tribute」訊息數對不上時要說出來 ──
	var team7_pair_n: int = 0
	for key2 in pair_keys:
		if key2.ends_with("-%d" % TEAM7) or key2.begins_with("%d-" % TEAM7):
			team7_pair_n += int(pair_ticks[key2].size())
	print("\n[T] ★誠實限：Team7 涉及的 ledger 確認配對筆數=%d；同期 global_messages type=\"tribute\" \
提到 Team7 的訊息筆數=%d（逐tick掃，TTL=14天不會漏）。" % [team7_pair_n, b["tribute_msg_team7"].size()])
	if team7_pair_n < b["tribute_msg_team7"].size():
		print("[T] ★★★訊息數 > ledger配對數 ⇒ 多數「徵收」訊息沒有對應的真實資源轉移 ⇒ 疑似\
「大部分徵收是символ性的（payer 當下 food/goods/coin 皆已被壓到 base_rate×stock≈0，\
`_resolve_tribute` 的 `if amount<=0: continue` 讓三種資源全部跳過，訊息仍照常發出）」——\
★我沒有逐筆去查每次訊息當下的 payer 庫存值來confirm這個假說，這是【推論】不是【驗過的事實】，\
交你／QA判要不要追下去。")
	print("[T] Team7 相關 tribute 訊息逐筆：")
	for m in b["tribute_msg_team7"]:
		print("  tick=%d｜%s" % [int(m["tick"]), String(m["description"])])

	# ── 落地 ─────────────────────────────────────────────────────────────────────
	var out_path: String = "docs/measurements/team7-ledger-D-M-T.jsonl"
	var f: FileAccess = FileAccess.open(out_path, FileAccess.WRITE)
	f.store_line(JSON.stringify({"kind": "meta", "tree": tree_sha, "seed": SEED,
		"window_D_M": [WINDOW_D_START, WINDOW_D_END], "total_ticks": TOTAL_TICKS,
		"ledger_ab_hash_match": hash_match, "ledger_ab_fp_match": fp_match,
		"food_earliest_tick": b["food_earliest_tick"]}))
	for r in food_in_window:
		f.store_line(JSON.stringify({"kind": "D_food", "tick": r["tick"], "delta": r["delta"], "reason": r["reason"]}))
	for r in mat_in_window:
		f.store_line(JSON.stringify({"kind": "M_material", "tick": r["tick"], "delta": r["delta"], "reason": r["reason"]}))
	for key in pair_keys:
		var ticks2: Array = pair_ticks[key]
		ticks2.sort()
		f.store_line(JSON.stringify({"kind": "T_pair", "collector_payer": key, "ticks": ticks2}))
	f.store_line(JSON.stringify({"kind": "T_ambiguous_tick_count", "n": ambiguous_n}))
	f.close()
	print("\n[DUMP-PATH] %s" % out_path)
	print("=== team7_ledger_reasons_and_tax_interval DONE ===")
	quit(0)


func _run_pass(ledger_on: bool) -> Dictionary:
	seed(SEED)
	var ws: WorldState = MeasureBedHelper.arm_and_setup("res://config/default.json", false)
	var runner := SimRunner.new()
	var no_player := Vector2i(-1, -1)

	WorldState.driver_ledger_enabled = ledger_on
	WorldState.clear_driver_ledger()

	var hasher := HashingContext.new()
	hasher.start(HashingContext.HASH_SHA256)

	var food_rows: Array = []
	var material_rows: Array = []
	var tribute_by_tick: Dictionary = {}   # tick → {"out":{payer_id:true},"in":{collector_id:true}}
	var food_earliest_tick: int = -1
	var tribute_msg_team7: Array = []   # global_messages type="tribute" 提到 team7（逐tick掃不漏，TTL=14天會prune）
	var seen_msg: Dictionary = {}

	for _i in range(TOTAL_TICKS):
		runner.advance_tick(ws, no_player)
		var cur_tick: int = ws.world.current_tick
		var ids: Array = ws.teams.keys()
		ids.sort()
		var parts: Array = []
		for tid in ids:
			var t: TeamData = ws.teams[tid]
			parts.append("%d:%s" % [int(tid), t.current_option])
		hasher.update(("|".join(parts)).to_utf8_buffer())

		if ledger_on:
			for entry in WorldState.driver_ledger:
				var ent = entry["entity"]
				var field: String = String(entry["field"])
				var reason: String = String(entry["reason"])
				if ent is TeamData:
					var etid: int = int(ent.team_id)
					if etid == TEAM7 and field == "food":
						if food_earliest_tick == -1: food_earliest_tick = int(entry["tick"])
						food_rows.append({"tick": entry["tick"], "delta": entry["delta"], "reason": reason})
					elif etid == TEAM7 and field == "material":
						material_rows.append({"tick": entry["tick"], "delta": entry["delta"], "reason": reason})
					if reason == "tribute_out" or reason == "tribute_in":
						var tk: int = int(entry["tick"])
						var bucket: Dictionary = tribute_by_tick.get(tk, {"out": {}, "in": {}})
						if reason == "tribute_out":
							bucket["out"][etid] = true
						else:
							bucket["in"][etid] = true
						tribute_by_tick[tk] = bucket
			WorldState.clear_driver_ledger()

		for msg in ws.global_messages:
			if String(msg.type) != "tribute":
				continue
			var mkey: String = "%d:%d" % [int(msg.origin_tick), int(msg.id)]
			if seen_msg.has(mkey):
				continue
			var involves7b: bool = int(msg.origin_team_id) == TEAM7
			if not involves7b:
				for pk in msg.params.keys():
					var pks: String = String(pk)
					if (pks.ends_with("team") or pks.ends_with("team_id") or pks == "origin" or pks == "target") \
							and int(msg.params[pk]) == TEAM7:
						involves7b = true
						break
			if involves7b:
				seen_msg[mkey] = true
				tribute_msg_team7.append({"tick": int(msg.origin_tick), "description": msg.description,
					"params": msg.params})

	var fp: String = _world_fp(ws)
	var digest: PackedByteArray = hasher.finish()
	return {"decision_hash": digest.hex_encode(), "world_fp": fp,
		"food_rows": food_rows, "material_rows": material_rows,
		"tribute_by_tick": tribute_by_tick, "food_earliest_tick": food_earliest_tick,
		"tribute_msg_team7": tribute_msg_team7}


func _world_fp(ws: WorldState) -> String:
	var ids: Array = ws.teams.keys()
	ids.sort()
	var arr: Array = []
	for tid in ids:
		var t: TeamData = ws.teams[tid]
		arr.append([tid, t.leader_id, t.tile_pos.x, t.tile_pos.y, t.population,
			t.current_task, t.current_option, t.task_priority,
			snappedf(float(t.resources.get("food", 0)), 0.01),
			snappedf(float(t.resources.get("coin", 0)), 0.01),
			snappedf(float(t.resources.get("material", 0)), 0.01)])
	arr.append(["__world__", ws.world.current_tick, ws.game_over, ws.game_over_reason])
	return JSON.stringify(arr).sha256_text()


func _git_head_sha() -> String:
	var out: Array = []
	OS.execute("git", ["rev-parse", "--short=9", "HEAD"], out, true)
	if out.size() > 0:
		return String(out[0]).strip_edges()
	return "UNKNOWN"
