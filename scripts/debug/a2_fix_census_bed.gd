extends SceneTree
# @bed-kind: invariant
# A2 修「先查」（spec 2026-10-07-a2-fix-failure-mark-never-written-HOW，唯讀、不改世界）
#
# 問題：option＝貿易、到場、當日零成交的事件，同拍寫進 recent_failures「貿易|市集」的幾乎是 0。
# 本床把那些事件逐筆歸到六類，印分佈：
#   ①不在 market 步（_step3c_read_market_board）的 arrived_ids 名單裡（整段到場期間一次都沒有）
#       ①a 到場那一拍人沒動（派出時目標就是腳下那格）｜①b 其他
#   ②在名單裡，但那一次呼叫時 trade_arrived 為假
#   ③在名單裡，那一次呼叫當中帳本有成交（_dealt 為真，但當日帳本判準說沒有——判準落差）
#   ④在名單裡，那一次呼叫時 current_task 已不是 TRADE
#   ⑤在名單裡，task 仍是 TRADE，但 current_option 已不是「貿易」
#   ⑥以上皆非（並數它多大）
#
# ★事件判法逐字照量測員 a2b_recollision_rate.gd（同一份母體）：
#   到場＝邊緣偵測（上一拍非 trade_arrived → 這一拍 trade_arrived，且 task＝TRADE），option 取到場那一拍
#   零成交＝當日帳本上這一隊沒有任何 reason 以 market_／trade_goods_ 開頭、delta≠0 的紀錄
# ★名單怎麼拿：SimRunner 子類別覆寫 _step3c_read_market_board，記下【它實際收到的】arrived_ids 與呼叫當下的狀態，
#   再呼 super（世界照原樣跑；不耗 RNG、不寫 state）
# ★誠實限：③ 的「這一次呼叫當中有成交」讀的是呼叫前後帳本長度之間、這一隊名下的 market_／trade_goods_ 條目
#
# ★輸出標籤用 1a／1b／2…6（圈號字在 godot.ps1 輸出會被吃掉，2026-10-08 實測）
# 跑法：.\tools\godot.ps1 --headless --script scripts/debug/a2_fix_census_bed.gd

const SEEDS: Array = [1337, 7, 2024]
const TOTAL_DAYS: int = 30
const WRITTEN_RATIO_MIN: float = 0.9   # spec P2：分母＝人在市集格的那部分（systems 裁甲 2026-10-08）
var _written_m: int = 0
var _pop_m: int = 0


class SpyRunner extends SimRunner:
	var calls: Array = []   # 每一次 step3c 呼叫裡、每一個 arrived 隊一筆
	func _step3c_read_market_board(state: WorldState, arrived_ids: Array) -> void:
		var pre: Dictionary = {}
		for tid in arrived_ids:
			if not state.teams.has(tid):
				continue
			var t: TeamData = state.teams[tid]
			pre[int(tid)] = {"task": String(t.current_task), "option": String(t.current_option),
				"trade_arrived": SimRunner.trade_arrived(t)}
		var n0: int = WorldState.driver_ledger.size()
		super(state, arrived_ids)
		var dealt: Dictionary = {}
		for i in range(n0, WorldState.driver_ledger.size()):
			var e: Dictionary = WorldState.driver_ledger[i]
			var ent = e["entity"]
			if not (ent is TeamData):
				continue
			var r: String = String(e["reason"])
			if (r.begins_with("market_") or r.begins_with("trade_goods_")) and not is_zero_approx(float(e["delta"])):
				dealt[int((ent as TeamData).team_id)] = true
		for tid2 in pre.keys():
			var row: Dictionary = pre[tid2]
			row["team"] = int(tid2)
			row["tick"] = state.world.current_tick
			row["dealt"] = bool(dealt.get(int(tid2), false))
			calls.append(row)


func _initialize() -> void:
	print("[TREE] HEAD=%s" % _git_head_sha())
	for sd in SEEDS:
		_run(int(sd))
	var ratio: float = float(_written_m) / float(maxi(1, _pop_m))
	var ok: bool = _pop_m > 0 and ratio >= WRITTEN_RATIO_MIN
	print("\n[A2FIX] 判決：人在市集格的「貿易」到場零成交，失敗記號寫進去 %d／%d ＝ %.2f（門檻 %.2f）⇒ %s" % [
		_written_m, _pop_m, ratio, WRITTEN_RATIO_MIN, "綠" if ok else "★紅"])
	print("\n=== a2_fix_census DONE === errors: %d" % (0 if ok else 1))
	quit(0 if ok else 1)


func _run(seed_val: int) -> void:
	print("\n########## SEED=%d ##########" % seed_val)
	seed(seed_val)
	var ws: WorldState = MeasureBedHelper.arm_and_setup("res://config/default.json", false)
	var runner := SpyRunner.new()
	WorldState.driver_ledger_enabled = true
	WorldState.clear_driver_ledger()
	var was: Dictionary = {}
	var prev_tile: Dictionary = {}
	var open_ep: Dictionary = {}      # team → 事件（到場期間還沒結束）
	var events: Array = []
	var settled_today: Dictionary = {}
	var today_events: Array = []
	for day in range(TOTAL_DAYS):
		settled_today.clear()
		today_events.clear()
		for _i in range(WorldState.TICKS_PER_DAY):
			for tid0 in ws.teams.keys():
				prev_tile[int(tid0)] = ws.teams[tid0].tile_pos
			runner.calls.clear()
			runner.advance_tick(ws, Vector2i(-1, -1))
			var now: int = ws.world.current_tick
			for entry in WorldState.driver_ledger:
				var ent = entry["entity"]
				if not (ent is TeamData):
					continue
				var reason: String = String(entry["reason"])
				if (reason.begins_with("market_") or reason.begins_with("trade_goods_")) and not is_zero_approx(float(entry["delta"])):
					settled_today[int(ent.team_id)] = true
			WorldState.clear_driver_ledger()
			# 這一拍 step3c 收到的名單 ⇒ 掛到還開著的事件上（第一次出現那一筆）
			for c in runner.calls:
				var ev = open_ep.get(int(c["team"]))
				if ev != null and (ev as Dictionary).get("call", {}).is_empty():
					(ev as Dictionary)["call"] = c
			# ★判決格（spec P2，走真世界）：還開著的事件 ⇒ 這一拍有沒有寫進「貿易|<那一格>」
			for evw in open_ep.values():
				_mark_written(ws, evw)
			for tid in ws.teams.keys():
				var t: TeamData = ws.teams[tid]
				var now_arr: bool = t.current_task == TeamData.TASK_TRADE and SimRunner.trade_arrived(t)
				var prev: bool = bool(was.get(int(tid), false))
				if now_arr and not prev:
					var mt: HexTileData = ws.world.tiles.get(t.tile_pos.x * 1000 + t.tile_pos.y)
					var ev2: Dictionary = {"day": day, "tick": now, "team": int(tid), "option": String(t.current_option),
						"market": int(t.tile_pos.x * 1000 + t.tile_pos.y), "at_market": mt != null and mt.outpost_level > 0,
						"stood_still": prev_tile.get(int(tid), t.tile_pos) == t.tile_pos, "call": {},
						"mt_cleared": t.move_target == Vector2i(-1, -1)}
					# 同一拍 step3c 已經跑過 ⇒ 這一拍的名單也算
					for c2 in runner.calls:
						if int(c2["team"]) == int(tid):
							ev2["call"] = c2
							break
					ev2["written"] = false
					_mark_written(ws, ev2)
					open_ep[int(tid)] = ev2
					today_events.append(ev2)
				elif not now_arr and prev:
					open_ep.erase(int(tid))
				was[int(tid)] = now_arr
		for ev3 in today_events:
			ev3["zero"] = not bool(settled_today.get(int(ev3["team"]), false))
			events.append(ev3)
	WorldState.driver_ledger_enabled = false
	WorldState.clear_driver_ledger()
	_report(events)


# 那一格的「貿易」失敗記號，tick 不早於事件那一拍 ⇒ 寫進去了
static func _mark_written(ws: WorldState, ev: Dictionary) -> void:
	if bool(ev.get("written", false)):
		return
	var t: TeamData = ws.teams.get(int(ev["team"]))
	if t == null:
		return
	var en: Dictionary = t.recent_failures.get("貿易|%d" % int(ev["market"]), {})
	if not en.is_empty() and int(en.get("tick", -1)) >= int(ev["tick"]):
		ev["written"] = true


static func classify(ev: Dictionary) -> String:
	var c: Dictionary = ev.get("call", {})
	if c.is_empty():
		return "1a" if bool(ev["stood_still"]) else "1b"
	if not bool(c["trade_arrived"]):
		return "2"
	if bool(c["dealt"]):
		return "3"
	if String(c["task"]) != TeamData.TASK_TRADE:
		return "4"
	if String(c["option"]) != "貿易":
		return "5"
	return "6"


func _report(events: Array) -> void:
	var pop: Array = events.filter(func(e): return String(e["option"]) == "貿易" and bool(e["zero"]))
	var dist: Dictionary = {"1a": 0, "1b": 0, "2": 0, "3": 0, "4": 0, "5": 0, "6": 0}
	var samples: Dictionary = {}
	var not_market: int = 0
	for e in pop:
		var k: String = classify(e)
		dist[k] = int(dist[k]) + 1
		if not bool(e["at_market"]):
			not_market += 1
		var s: Array = samples.get(k, [])
		if s.size() < 5:
			s.append("day=%d tick=%d T%d tile=%d%s" % [int(e["day"]), int(e["tick"]), int(e["team"]), int(e["market"]),
				"" if bool(e["at_market"]) else "（非市集格）"])
		samples[k] = s
	var total: int = 0
	for k2 in dist:
		total += int(dist[k2])
	print("  母體：option＝貿易、到場、當日零成交 ＝ %d 筆（全部到場事件 %d；其中不在市集格 %d）" % [pop.size(), events.size(), not_market])
	for k3 in ["1a", "1b", "2", "3", "4", "5", "6"]:
		print("  %s ＝ %d｜%s" % [k3, int(dist[k3]), "；".join(PackedStringArray(samples.get(k3, [])))])
	var nm_cleared: int = 0
	for e2 in pop:
		if not bool(e2["at_market"]) and bool(e2["mt_cleared"]):
			nm_cleared += 1
	var at_m: Array = pop.filter(func(e): return bool(e["at_market"]))
	var w_all: int = pop.filter(func(e): return bool(e.get("written", false))).size()
	var w_m: int = at_m.filter(func(e): return bool(e.get("written", false))).size()
	print("  [A2FIX] 失敗記號真的寫進去：全母體 %d／%d｜人在市集格 %d／%d｜非市集格（供 A2c）%d 筆" % [w_all, pop.size(), w_m, at_m.size(), pop.size() - at_m.size()])
	_written_m += w_m
	_pop_m += at_m.size()
	print("  不在市集格的 %d 筆裡，到場那一拍 move_target＝(-1,-1)（trade_arrived 的「目標已清」那一支）＝ %d 筆" % [not_market, nm_cleared])
	print("  ★三數相加：%d ＝ 母體 %d ⇒ %s" % [total, pop.size(), "對" if total == pop.size() else "★不對"])


func _git_head_sha() -> String:
	var out: Array = []
	OS.execute("git", ["rev-parse", "--short", "HEAD"], out)
	return String(out[0]).strip_edges() if not out.is_empty() else "?"
