extends SceneTree
# @bed-kind: acceptance
# slice: 情報面板（spec 2026-10-13-intel-panel-HOW：記憶頁擴成情報頁＋直達鍵＋打聽回答逐筆列）
# ★格：
#   I1  直達鍵一按 ⇒ 畫面在情報頁；鍵列上有它（修前紅：主畫面沒有這個鍵）
#   I2  打聽得知某隊位置 ⇒ 情報頁「TeamX (q,r)｜聽說，來自 TeamN｜位置是 N 分鐘前的」；payload 只有絕對 tick
#   I2b 只有人口估、沒有位置 ⇒「位置不明」
#   I2c 關係未知 ⇒「不明」（不是中立值）；有 known_reputations ⇒ 印那個數
#   I3  親見的隊 ⇒ 標「親見」
#   I4  真值移動後（目標走了、玩家沒看到）⇒ 情報頁仍印舊位置（零真值）｜負對照：查詢改讀真值 ⇒ I4 紅
#   I5  據點類有已知據點；沒有時「尚無」
#   I6  糧源「尚無（還沒有這種情報）」
#   I7  與游標處一致：未過期 ⇒ 游標處明細列同一隊；過期 ⇒ 不在游標處母體、情報頁標「（太久，視同不知）」
#   I8  同一 tick 兩次查詢 JSON 相同；隔 tick 而 belief 不變 ⇒ JSON 仍相同（純函數）
#   I9  打聽得 4 筆（2 新、1 已知、1 衝突）⇒ 回答逐筆 4 行各自三態；列表筆數＝寫進接收方的筆數，與給方 known_targets 數無關
#       （修前紅：沒有逐筆列）
#   C   普查那一格：給方只知道「你自己」⇒ 結果句不是「他說的你早就知道了」（修前紅）
#   CAP 每類最多 UiPages.INTEL_ROWS_PER_KIND 列，多的印「另有 M 筆」

const EXPECTED: Array = ["I1", "I2", "I2b", "I2c", "I3", "I4", "I5", "I6", "I7", "I8", "I9", "C", "CAP"]
var _errors: int = 0
var _present: Dictionary = {}

func _initialize() -> void:
	print("=== intel_panel：情報頁＋打聽逐筆列 ===")
	await _i1()
	_i2_i3_i4()
	_i5_i6()
	_i7()
	_i8()
	_i9()
	_c()
	_cap()
	var miss: Array = []
	for c in EXPECTED:
		if not _present.has(c):
			miss.append(c)
	if not miss.is_empty():
		_check("到場點名缺 %s" % str(miss), false)
	print("=== intel_panel DONE === 到場 %d／%d errors: %d" % [_present.size(), EXPECTED.size(), _errors])
	quit(1 if _errors > 0 else 0)

func _check(msg: String, cond: bool) -> void:
	if cond:
		print("  PASS: " + msg)
	else:
		_errors += 1
		push_error("[FAIL] " + msg)

func _world() -> WorldState:
	seed(20261015)
	var st: WorldState = MeasureBedHelper.arm_and_setup("res://config/default.json", false)
	Probe.enabled = false
	return st

func _npcs(st: WorldState) -> Array:
	var ptid: int = st.get_player_team_id()
	var out: Array = []
	for tid in st.teams:
		if int(tid) != ptid and st.is_live_team(int(tid)):
			out.append(int(tid))
	out.sort()
	return out

# 玩家視野外、地圖上存在的一格（相對玩家隊往 +q 走）
func _far_tile(st: WorldState, extra: int) -> Vector2i:
	var pt: TeamData = st.teams[st.get_player_team_id()]
	var vr: int = VisionSystem.vision_range(st, pt)
	for dq in range(vr + extra, vr + extra + 20):
		for sgn in [1, -1]:
			var p: Vector2i = pt.tile_pos + Vector2i(dq * sgn, 0)
			if st.world.tiles.has(p.x * 1000 + p.y):
				return p
	return Vector2i(-1, -1)

func _panel(st: WorldState) -> Dictionary:
	return PlayerQueryApi.new().query_memory_panel(st).get("data", {})

func _row(data: Dictionary, tid: int) -> Dictionary:
	for r in data.get("memory", []):
		if int(r["target_id"]) == tid:
			return r
	return {}

func _lines(st: WorldState) -> Array:
	return TextUiMain.intel_lines(_panel(st), st.world.current_tick, st)

func _line_of(lines: Array, tid: int) -> String:
	for l in lines:
		if String(l).strip_edges().begins_with("Team%d " % tid):
			return String(l)
	return ""

# 讓 giver 誠實地說（同 _decide_exchange_mode：口碑 1.0、領袖慎重 0 ⇒ eff_rep 1.0 > 0.6 ⇒ honest）
func _make_honest(st: WorldState, giver: int) -> void:
	var ptid: int = st.get_player_team_id()
	var g: TeamData = st.teams[giver]
	g.known_reputations[ptid] = 1.0
	var gl: PersonData = st.persons.get(g.leader_id)
	if gl != null:
		gl.values["慎重"] = 0.0
		gl.skills["計謀"] = 0.0
	st.player_hostile_teams.erase(giver)

func _ask(st: WorldState, giver: int, topic: String) -> Dictionary:
	var ptid: int = st.get_player_team_id()
	st.player_state["gather_intel_npc_id"] = giver
	st.player_state["gather_intel_choice"] = topic
	return PlayerCommandSystem.new()._action_confirm_gather_intel(st, giver, st.teams[ptid], ptid)


# ── I1 ───────────────────────────────────────────────────────────────────────
func _i1() -> void:
	print("\n── I1 直達鍵 ──")
	seed(20261015)
	var scene: PackedScene = load("res://scenes/TextUI.tscn")
	var node = scene.instantiate()
	get_root().add_child(node)
	await process_frame
	await process_frame
	var want: int = UiPages.PAGE_ORDER.find(UiPages.INTEL_PAGE)
	node._page_idx = 0
	var ev := InputEventKey.new()
	ev.keycode = TextUiMain.INTEL_KEY
	ev.pressed = true
	node._input(ev)
	await process_frame
	var keys: String = node._keymap_now("main")
	print("   鍵 %s｜按後分頁 %d（情報＝%d）｜鍵列含「[J]情報」＝%s" % [OS.get_keycode_string(TextUiMain.INTEL_KEY),
		node._page_idx, want, str(keys.contains("[J]情報"))])
	_check("I1 按直達鍵 ⇒ 分頁在情報頁", want >= 0 and node._page_idx == want)
	_check("I1 頁首印「%s」" % UiPages.header(want), String(node._state_label.text).contains(UiPages.header(want)))
	_check("I1 鍵列上有「[J]情報」", keys.contains("[J]情報"))
	get_root().remove_child(node)
	node.free()
	await process_frame
	_present["I1"] = true


# ── I2／I2b／I2c／I3／I4 ─────────────────────────────────────────────────────
func _i2_i3_i4() -> void:
	print("\n── I2 聽說的位置／I2b 只有人口／I2c 關係／I3 親見／I4 零真值 ──")
	var st: WorldState = _world()
	var ptid: int = st.get_player_team_id()
	var pt: TeamData = st.teams[ptid]
	var ns: Array = _npcs(st)
	var giver: int = ns[0]
	var heard_t: int = ns[1]
	var pop_t: int = ns[2]
	var seen_t: int = ns[3]
	st.team_intel[ptid] = {}
	pt.known_reputations.erase(heard_t)
	var far: Vector2i = _far_tile(st, 3)
	var t0: int = st.world.current_tick
	# giver 親見 heard_t 在 far；玩家問 giver ⇒ 寫進玩家 belief（真的那條 relay）
	_make_honest(st, giver)
	BeliefSystem.record_claim(st, giver, heard_t, giver, "親見", {"tile_pos": far, "population_est": 0, "last_tick": t0}, 1.0, false)
	st.world.current_tick += 90   # 讓「N 分鐘前」不是 0（只動時鐘，不跑系統 ⇒ belief 不變）
	var res: Dictionary = _ask(st, giver, "ask_team_location")
	print("   打聽結果「%s」" % String(res.get("msg", "")))
	var data: Dictionary = _panel(st)
	var r: Dictionary = _row(data, heard_t)
	var lines: Array = TextUiMain.intel_lines(data, st.world.current_tick, st)
	var ln: String = _line_of(lines, heard_t)
	print("   payload 列 %s" % str(r))
	print("   畫面「%s」" % ln)
	var age: int = st.world.current_tick - int(r.get("pos_tick", -1))
	_check("I2 payload 位置＝giver 說的 %s" % str(far), r.get("pos") == far)
	_check("I2 payload 位置 tick 是絕對的（＝giver 那筆的 last_tick %d）" % t0, int(r.get("pos_tick", -1)) == t0)
	_check("I2 payload 沒有相對現在的欄", not (r.has("age") or r.has("ago") or r.has("minutes_ago") or r.has("stale")))
	_check("I2 畫面「Team%d (%d,%d)｜聽說，來自 Team%d｜位置是 %d 分鐘前的」" % [heard_t, far.x, far.y, giver, age],
		ln.contains("Team%d (%d,%d)｜聽說，來自 Team%d｜位置是 %d 分鐘前的" % [heard_t, far.x, far.y, giver, age]) and age == 90)
	_check("I2c 關係未知 ⇒「關係 不明」", ln.contains("關係 不明") and not r.has("relation"))
	pt.known_reputations[heard_t] = 0.62
	var ln_rel: String = _line_of(_lines(st), heard_t)
	_check("I2c 有 known_reputations ⇒ 印那個數（關係 0.62）", ln_rel.contains("關係 0.62"))
	_present["I2"] = true
	_present["I2c"] = true
	# I2b：只有人口估
	BeliefSystem.record_claim(st, ptid, pop_t, giver, "流民", {"population_est": 7, "last_tick": st.world.current_tick}, 0.3, false)
	var ln_b: String = _line_of(_lines(st), pop_t)
	print("   I2b 畫面「%s」" % ln_b)
	_check("I2b 只有人口估 ⇒「位置不明」且印人口", ln_b.contains("Team%d 位置不明" % pop_t) and ln_b.contains("人口約 7"))
	_present["I2b"] = true
	# I3：親見
	BeliefSystem.record_claim(st, ptid, seen_t, ptid, "親見", {"tile_pos": far + Vector2i(0, 1), "last_tick": st.world.current_tick}, 1.0, false)
	var ln3: String = _line_of(_lines(st), seen_t)
	print("   I3 畫面「%s」" % ln3)
	_check("I3 親見的隊 ⇒ 標「親見」、不標聽說", ln3.contains("｜親見") and not ln3.contains("聽說"))
	_present["I3"] = true
	# I4：真值移走（玩家沒看到）⇒ 仍是舊位置
	var ht: TeamData = st.teams[heard_t]
	var old_true: Vector2i = ht.tile_pos
	ht.tile_pos = far + Vector2i(5, -2)
	var r4: Dictionary = _row(_panel(st), heard_t)
	print("   I4 目標真位置 %s → %s｜情報頁位置 %s" % [str(old_true), str(ht.tile_pos), str(r4.get("pos"))])
	_check("I4 真值移動後情報頁仍印 belief 那一格 %s（不是真位置 %s）" % [str(far), str(ht.tile_pos)],
		r4.get("pos") == far and r4.get("pos") != ht.tile_pos)
	ht.tile_pos = old_true
	_present["I4"] = true


# ── I5／I6 ───────────────────────────────────────────────────────────────────
func _i5_i6() -> void:
	print("\n── I5 據點／I6 糧源 ──")
	var st: WorldState = _world()
	var ptid: int = st.get_player_team_id()
	var ns: Array = _npcs(st)
	var known: Dictionary = st.team_tile_known.get(ptid, {})
	# 先清掉玩家帳上的據點記錄 ⇒「尚無」
	for k in known.keys():
		if known[k] is Dictionary and (known[k] as Dictionary).has("outpost"):
			known[k] = true
	st.team_tile_known[ptid] = known
	var l0: Array = _lines(st)
	var i0: int = l0.find("── 據點與市集（關係＝你隊伍領袖的看法）──")
	print("   沒有據點時：%s" % (str(l0[i0 + 1]) if i0 >= 0 and i0 + 1 < l0.size() else "（找不到類別）"))
	_check("I5 沒有已知據點 ⇒「尚無」", i0 >= 0 and String(l0[i0 + 1]).strip_edges() == "尚無")
	var p: Vector2i = _far_tile(st, 2)
	var owner: int = ns[0]
	known[p.x * 1000 + p.y] = {"outpost": {"owner_id": owner, "level": 2, "type": "civilian", "last_tick": st.world.current_tick}}
	var l1: Array = _lines(st)
	var i1: int = l1.find("── 據點與市集（關係＝你隊伍領袖的看法）──")
	var row: String = String(l1[i1 + 1]) if i1 >= 0 and i1 + 1 < l1.size() else ""
	print("   有一筆時：%s" % row)
	_check("I5 據點類列出已知據點 (%d,%d) Team%d" % [p.x, p.y, owner], row.contains("(%d,%d) Team%d 的民用據點（等級 2）" % [p.x, p.y, owner]))
	_check("I5 類別標頭寫「關係＝你隊伍領袖的看法」", i1 >= 0)
	_present["I5"] = true
	var i6: int = l1.find("── 糧源 ──")
	_check("I6 糧源「尚無（還沒有這種情報）」", i6 >= 0 and String(l1[i6 + 1]).strip_edges() == "尚無（還沒有這種情報）")
	_present["I6"] = true


# ── I7 ───────────────────────────────────────────────────────────────────────
func _i7() -> void:
	print("\n── I7 與游標處一致（含過期）──")
	var st: WorldState = _world()
	var ptid: int = st.get_player_team_id()
	var ns: Array = _npcs(st)
	var fresh_t: int = ns[0]
	var stale_t: int = ns[1]
	st.team_intel[ptid] = {}
	var pf: Vector2i = _far_tile(st, 3)
	var ps: Vector2i = pf + Vector2i(0, 2) if st.world.tiles.has(pf.x * 1000 + pf.y + 2) else pf + Vector2i(0, -2)
	# 兩隊真位置搬離那兩格（游標處「看得到的」那一半不會碰到它們）
	BeliefSystem.record_claim(st, ptid, fresh_t, ns[2], "流民", {"tile_pos": pf, "last_tick": st.world.current_tick}, 0.3, false)
	BeliefSystem.record_claim(st, ptid, stale_t, ns[2], "流民", {"tile_pos": ps, "last_tick": st.world.current_tick}, 0.3, false)
	# 過期那一筆：位置 tick 比過期線還舊 1
	for c in BeliefSystem.claims(st, ptid, stale_t):
		(c["value"] as Dictionary)["last_tick"] = st.world.current_tick - BeliefSystem.BELIEF_STALE_TICKS - 1
	var lines: Array = _lines(st)
	var lf: String = _line_of(lines, fresh_t)
	var ls: String = _line_of(lines, stale_t)
	var kf: Array = PlayerQueryApi.tile_knowledge(st, pf).get("teams", [])
	var ks: Array = PlayerQueryApi.tile_knowledge(st, ps).get("teams", [])
	var ids_f: Array = kf.map(func(t): return int(t["id"]))
	var ids_s: Array = ks.map(func(t): return int(t["id"]))
	print("   未過期 Team%d：情報頁「%s」｜游標處 %s 的隊 %s" % [fresh_t, lf, str(pf), str(ids_f)])
	print("   過期   Team%d：情報頁「%s」｜游標處 %s 的隊 %s" % [stale_t, ls, str(ps), str(ids_s)])
	_check("I7 未過期：情報頁列的那一格，游標處也列同一隊", lf.contains("(%d,%d)｜" % [pf.x, pf.y]) and ids_f.has(fresh_t))
	_check("I7 過期：情報頁標「（太久，視同不知）」", ls.contains("(%d,%d)（太久，視同不知）" % [ps.x, ps.y]))
	_check("I7 過期：游標處那一格不列它（不在母體）", not ids_s.has(stale_t))
	_present["I7"] = true


# ── I8 ───────────────────────────────────────────────────────────────────────
func _i8() -> void:
	print("\n── I8 純函數 ──")
	var st: WorldState = _world()
	var ptid: int = st.get_player_team_id()
	var ns: Array = _npcs(st)
	BeliefSystem.record_claim(st, ptid, ns[0], ns[1], "流民", {"tile_pos": _far_tile(st, 3), "population_est": 4,
		"last_tick": st.world.current_tick}, 0.3, false)
	var a: String = JSON.stringify(PlayerQueryApi.new().query_memory_panel(st))
	var b: String = JSON.stringify(PlayerQueryApi.new().query_memory_panel(st))
	st.world.current_tick += 1   # 隔 tick、不跑系統 ⇒ belief 不變
	var c: String = JSON.stringify(PlayerQueryApi.new().query_memory_panel(st))
	print("   JSON 長 %d｜同 tick 相同=%s｜隔 tick 相同=%s" % [a.length(), str(a == b), str(a == c)])
	_check("I8 母體地板：payload 有隊伍列（空的話相同恆真）", (_panel(st).get("memory", []) as Array).size() > 0)
	_check("I8 同一 tick 兩次查詢 JSON 相同", a == b)
	_check("I8 隔 tick 而 belief 不變 ⇒ JSON 仍相同", a == c)
	_present["I8"] = true


# ── I9 ───────────────────────────────────────────────────────────────────────
func _i9() -> void:
	print("\n── I9 打聽得 4 筆：2 新／1 已知／1 衝突 ──")
	var st: WorldState = _world()
	var ptid: int = st.get_player_team_id()
	var ns: Array = _npcs(st)
	var giver: int = ns[0]
	var n1: int = ns[1]
	var n2: int = ns[2]
	var kn: int = ns[3]
	var cf: int = ns[4]
	st.team_intel[ptid] = {}
	st.team_intel[giver] = {}
	_make_honest(st, giver)
	var now: int = st.world.current_tick
	var p: Vector2i = _far_tile(st, 3)
	var spots: Dictionary = {n1: p, n2: p + Vector2i(0, 1), kn: p + Vector2i(0, 2), cf: p + Vector2i(0, 3)}
	for t in spots:
		BeliefSystem.record_claim(st, giver, t, giver, "親見", {"tile_pos": spots[t], "population_est": 0, "last_tick": now - 30}, 1.0, false)
	# ★給方還知道你自己在哪 ⇒ 給方 known_targets 5 筆，而回答只該列 4 筆
	BeliefSystem.record_claim(st, giver, ptid, giver, "親見", {"tile_pos": st.teams[ptid].tile_pos, "population_est": 0,
		"last_tick": now}, 1.0, false)
	# 玩家已親見 kn（同一格）與 cf（另一格）
	BeliefSystem.record_claim(st, ptid, kn, ptid, "親見", {"tile_pos": spots[kn], "population_est": 0, "last_tick": now}, 1.0, false)
	BeliefSystem.record_claim(st, ptid, cf, ptid, "親見", {"tile_pos": spots[cf] + Vector2i(4, 0), "population_est": 0,
		"last_tick": now}, 1.0, false)
	# ★親見寫入會把 value.last_tick 改成當下（belief_system 裁A）⇒ 先記下 giver 那筆的 tick，再撥鐘 30 分 ⇒ 消息年齡非 0
	var g_tick: int = int(BeliefSystem.best_value_quiet(st, giver, n1).get("last_tick", -1))
	st.world.current_tick += 30
	# 走真的指令路徑（佇列 → sim_runner 消化 → command_results）⇒ 逐筆列從 handler 一路帶到結果
	_make_honest(st, giver)
	st.player_state["gather_intel_npc_id"] = giver
	st.player_state["gather_intel_choice"] = "ask_team_location"
	st.command_seq += 1
	var seq: int = st.command_seq
	st.pending_commands.append({"name": "execute_action", "args": {"action_id": "confirm_gather_intel",
		"target": {"kind": "none", "team_id": giver, "member_id": -1, "tile_q": -1, "tile_r": -1}}, "seq": seq})
	var runner := SimRunner.new()
	runner.advance_tick(st, st.teams[ptid].tile_pos)
	var cr: Dictionary = {}
	for r in st.command_results:
		if int(r.get("seq", -1)) == seq:
			cr = r
	var items: Array = cr.get("items", [])
	var lines: Array = TextUiMain.inquiry_item_lines(items, int(cr.get("tick", 0)))
	print("   結果句「%s」" % String(cr.get("text", "")))
	for l in lines:
		print("   " + String(l))
	var by: Dictionary = {}
	for it in items:
		by[int(it["target_id"])] = String(it["state"])
	print("   給方 known_targets %d 筆｜逐筆 %d 筆 %s" % [BeliefSystem.known_targets(st, giver).size(), items.size(), str(by)])
	_check("I9 母體地板：給方知道得比說的多（known_targets %d > 4）" % BeliefSystem.known_targets(st, giver).size(),
		BeliefSystem.known_targets(st, giver).size() > 4)
	_check("I9 回答逐筆 4 筆（＝寫進你 belief 的筆數，不是給方知道的筆數）", items.size() == 4 and lines.size() == 4)
	_check("I9 兩筆新", by.get(n1) == "written" and by.get(n2) == "written")
	_check("I9 已知那筆＝早就知道", by.get(kn) == "refreshed")
	_check("I9 衝突那筆＝沒採信（不併進新或早知道）", by.get(cf) == "conflicted")
	var cnt: Dictionary = {"新": 0, "你早就知道了": 0, "他說的跟你知道的不一樣，你沒採信": 0}
	for l in lines:
		for w in cnt:
			if String(l).ends_with("｜" + String(w)):
				cnt[w] = int(cnt[w]) + 1
	_check("I9 畫面四行：新 2、早就知道 1、沒採信 1 %s" % str(cnt),
		int(cnt["新"]) == 2 and int(cnt["你早就知道了"]) == 1 and int(cnt["他說的跟你知道的不一樣，你沒採信"]) == 1)
	var l_n1: String = ""
	var it_n1: Dictionary = {}
	for l in lines:
		if String(l).contains("Team%d " % n1):
			l_n1 = String(l)
	for it in items:
		if int(it["target_id"]) == n1:
			it_n1 = it
	var age: int = int(cr.get("tick", 0)) - g_tick
	_check("I9 那一筆的 last_tick＝給方那筆的（%d；轉述繼承 giver 的位置年齡）" % g_tick, int(it_n1.get("last_tick", -9)) == g_tick)
	_check("I9 每行有哪隊、在哪、消息幾分鐘前（Team%d 在 (%d,%d)（消息是 %d 分鐘前的））" % [n1, p.x, p.y, age],
		age >= 30 and l_n1.contains("Team%d 在 (%d,%d)（消息是 %d 分鐘前的）" % [n1, p.x, p.y, age]))
	_present["I9"] = true


# ── C：給方只知道你自己 ─────────────────────────────────────────────────────────
func _c() -> void:
	print("\n── C 給方只知道你自己（打聽三態普查那一格）──")
	var st: WorldState = _world()
	var ptid: int = st.get_player_team_id()
	var giver: int = _npcs(st)[0]
	st.team_intel[giver] = {}
	_make_honest(st, giver)
	BeliefSystem.record_claim(st, giver, ptid, giver, "親見", {"tile_pos": st.teams[ptid].tile_pos, "population_est": 0,
		"last_tick": st.world.current_tick}, 1.0, false)
	var res: Dictionary = _ask(st, giver, "ask_team_location")
	var msg: String = String(res.get("msg", ""))
	var locs: Array = res.get("payload", {}).get("locations", [])
	print("   給方 known_targets %s｜回答 locations %d 筆｜結果句「%s」" % [str(BeliefSystem.known_targets(st, giver)), locs.size(), msg])
	_check("C 母體地板：回答裡真的有那一筆（說的是你自己）", locs.size() == 1 and int(locs[0]["team_id"]) == ptid)
	_check("C 結果句不是「他說的你早就知道了」", not msg.begins_with("他說的你早就知道了"))
	_check("C 結果句＝「他也不知道」", msg == "他也不知道")
	_present["C"] = true


# ── CAP ──────────────────────────────────────────────────────────────────────
func _cap() -> void:
	print("\n── CAP 每類最多 %d 列 ──" % UiPages.INTEL_ROWS_PER_KIND)
	var st: WorldState = _world()
	var ptid: int = st.get_player_team_id()
	var ns: Array = _npcs(st)
	st.team_intel[ptid] = {}
	var n: int = mini(ns.size(), UiPages.INTEL_ROWS_PER_KIND + 3)
	var p: Vector2i = _far_tile(st, 3)
	for i in range(n):
		BeliefSystem.record_claim(st, ptid, ns[i], ns[0] if i > 0 else ns[1], "流民",
			{"tile_pos": p, "last_tick": st.world.current_tick - i}, 0.3, false)
	var lines: Array = _lines(st)
	var a: int = lines.find("── 隊伍 ──")
	var b: int = lines.find("── 據點與市集（關係＝你隊伍領袖的看法）──")
	var body: Array = lines.slice(a + 1, b)
	print("   %d 隊 ⇒ 隊伍類 %d 行，末行「%s」" % [n, body.size(), str(body.back()) if not body.is_empty() else ""])
	_check("CAP 母體地板：隊數 %d > 上限 %d" % [n, UiPages.INTEL_ROWS_PER_KIND], n > UiPages.INTEL_ROWS_PER_KIND)
	_check("CAP 隊伍類＝上限列＋「另有 M 筆」",
		body.size() == UiPages.INTEL_ROWS_PER_KIND + 1 and String(body.back()).strip_edges() == "另有 %d 筆" % (n - UiPages.INTEL_ROWS_PER_KIND))
	_check("CAP 排序：位置 tick 新的在前（第一列是 Team%d）" % ns[0], String(body[0]).strip_edges().begins_with("Team%d " % ns[0]))
	_present["CAP"] = true
