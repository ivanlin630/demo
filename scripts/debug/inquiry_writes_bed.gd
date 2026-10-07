extends SceneTree
# @bed-kind: invariant
# ══ 打聽：說了什麼就記下什麼，記下幾筆就說幾筆 ══════════════════════════════════════════════════════
# spec：`docs/superpowers/specs/2026-10-07-inquiry-writes-what-it-says-HOW.md` §2
# 格：P1 近期事件：結果句的「記下 N 筆」＝ 真的新增進你情報的訊息數（逐筆對）
#     P2 他說了而你全都知道 ⇒「他說的你早就知道了」；★反向：有新的 ⇒「他說了些事情（記下 N 筆）」N > 0
#     P4 問糧源：選題清單上灰掉並帶原因（引擎給的原因）；按它 ⇒ 結果行印原因、零寫入
#     （P3 偽造訊息那一條路在探索床 P7[4]：它的「無 SCRIPT ERROR」靠 runner 的偵測）

const CFG: String = "res://config/default.json"
const SEED: int = 1337
const NPC_ID: int = 7320

var _errors: int = 0
var _cells_ran: Array = []
const EXPECTED_CELLS: Array = ["P1P2", "P4"]


func _initialize() -> void:
	print("=== inquiry_writes：說了什麼就記下什麼 ===")
	_p1_p2_recent_events()
	await _p4_food_source_disabled()
	var missing: Array = []
	for c in EXPECTED_CELLS:
		if not _cells_ran.has(String(c)):
			missing.append(String(c))
	_check("★到場點名：%d／%d（缺：%s）" % [_cells_ran.size(), EXPECTED_CELLS.size(), str(missing)], missing.is_empty())
	print("\n=== inquiry_writes DONE === errors: %d" % _errors)
	quit(1 if _errors > 0 else 0)


func _check(msg: String, cond: bool) -> void:
	if cond:
		print("  PASS: " + msg)
	else:
		_errors += 1
		push_error("[FAIL] " + msg)


static func _msg(id: int, giver: int) -> MessageData:
	var m := MessageData.new()
	m.id = id
	m.type = "battle"
	m.description = "佈置的近期事件 %d" % id
	m.origin_team_id = giver
	return m


# ══ P1／P2：問近期事件（誠實：兩隊同勢力 ⇒ _decide_exchange_mode 回 honest，不靠擲骰）══════════════════
func _p1_p2_recent_events() -> void:
	print("\n── P1／P2 近期事件：記下幾筆就說幾筆；全都知道 ⇒ 早就知道了 ──")
	var rows: Array = []
	for already_known in [false, true]:
		seed(SEED)
		var st: WorldState = MeasureBedHelper.arm_and_setup(CFG, false)
		var ptid: int = st.get_player_team_id()
		var pt: TeamData = st.teams[ptid]
		var ids: Array = st.teams.keys()
		ids.sort()
		var npc: TeamData = null
		for k in ids:
			if int(k) != ptid and st.teams[k].leader_id != -1:
				npc = st.teams[k]
				break
		var fid: int = int(st.factions.keys()[0])
		pt.faction_id = fid
		npc.faction_id = fid
		st.team_known[npc.team_id] = [_msg(880001, npc.team_id), _msg(880002, npc.team_id)]
		if not st.team_known.has(ptid):
			st.team_known[ptid] = []
		if already_known:
			for m in st.team_known[npc.team_id]:
				st.team_known[ptid].append(MessageData.copy_of(m))
		var before: int = (st.team_known[ptid] as Array).size()
		st.player_state["gather_intel_npc_id"] = npc.team_id
		st.player_state["gather_intel_choice"] = "ask_recent_events"
		var res: Dictionary = PlayerCommandSystem.new()._action_confirm_gather_intel(st, npc.team_id, pt, ptid)
		var added: int = (st.team_known[ptid] as Array).size() - before
		var msg: String = String(res.get("msg", ""))
		var re := RegEx.new()
		re.compile("記下 (\\d+) 筆")
		var m2 := re.search(msg)
		var said_n: int = int(m2.get_string(1)) if m2 != null else -1
		rows.append({"known": already_known, "msg": msg, "added": added, "said": said_n})
		print("   %s：結果句「%s」｜真的新增 %d 則｜句子說 %d 筆" % ["你已全知道" if already_known else "你都不知道", msg, added, said_n])
	_check("P1 都不知道 ⇒ 句子說的筆數 ＝ 真的新增的訊息數（%d ＝ %d），且 > 0" % [int(rows[0]["said"]), int(rows[0]["added"])],
		int(rows[0]["said"]) == int(rows[0]["added"]) and int(rows[0]["added"]) > 0)
	_check("P2 全都知道 ⇒「他說的你早就知道了」、新增 0（%s）" % String(rows[1]["msg"]),
		String(rows[1]["msg"]) == "他說的你早就知道了" and int(rows[1]["added"]) == 0)
	_cells_ran.append("P1P2")


# ══ P4：問糧源灰掉帶原因；按它 ⇒ 印原因、零寫入（走玩家那條路：TextUI＋PlayerRepl.press_on）═══════════════
func _p4_food_source_disabled() -> void:
	print("\\n── P4 問糧源：灰掉帶原因、按了零寫入 ──".replace("\\n", "\n"))
	seed(SEED)
	var node: Node = load("res://scenes/TextUI.tscn").instantiate()
	get_root().add_child(node)
	await process_frame
	await process_frame
	var st: WorldState = node._bridge._state
	var ptid: int = st.get_player_team_id()
	var t := TeamData.new()
	t.team_id = NPC_ID
	t.faction_id = -1
	t.tile_pos = st.teams[ptid].tile_pos
	AnonTierSystem.add_anon(t, AnonCohort.TIER_PLEB, 4)
	var l := PersonData.new()
	l.id = NPC_ID * 10 + 1
	l.team_id = NPC_ID
	st.persons[l.id] = l
	t.leader_id = l.id
	st.teams[NPC_ID] = t
	node._refresh()
	for k in ["t", "tab", "1"]:
		await PlayerRepl.press_on(node, PlayerRepl.keycode_for(k))
	# 目標動作區裡「打聽情報」那一鍵（畫面印的）
	var gi_key: String = ""
	var re_a := RegEx.new()
	re_a.compile("^ \\[(\\d)\\] " + PlayerApiMapper.action_label("gather_intel"))
	for line in String(node._screen_label.text).split("\n"):
		var m := re_a.search(line)
		if m != null:
			gi_key = m.get_string(1)
	await PlayerRepl.press_on(node, PlayerRepl.keycode_for(gi_key))
	var scr: String = String(node._screen_label.text)
	var food_label: String = TextBank.fmt("ui_inquiry_ask_food_source", "label", {})
	var reason: String = String(InquirySystem.DISABLED_REASON["ask_food_source"])
	var food_key: String = ""
	var re_o := RegEx.new()
	re_o.compile("^\\[(\\d)\\] (.+)$")
	for line in scr.split("\n"):
		var m := re_o.search(line)
		if m != null and m.get_string(2).begins_with(food_label):
			food_key = m.get_string(1)
			print("   選題清單那一行：%s" % line)
			_check("P4 問糧源列出、印成不可並帶原因「%s」" % reason, line.contains("（不可：" + reason + "）"))
	_check("★P4 母體地板：選題清單裡有問糧源（鍵 %s）" % food_key, food_key != "")
	if food_key != "":
		var known_before: int = (st.team_known.get(ptid, []) as Array).size()
		var mem_before: String = JSON.stringify(node._bridge.query_memory_panel())
		var tick_before: int = node._bridge.get_current_tick()
		await PlayerRepl.press_on(node, PlayerRepl.keycode_for(food_key))
		var res_line: String = ""
		for line in String(node._screen_label.text).split("\n"):
			if line.begins_with(" 結果："):
				res_line = line
		var known_after: int = (st.team_known.get(ptid, []) as Array).size()
		var mem_after: String = JSON.stringify(node._bridge.query_memory_panel())
		print("   按它 ⇒ %s｜情報訊息 %d → %d｜記憶頁變了 %s｜世界 tick %d → %d" % [res_line, known_before, known_after,
			str(mem_before != mem_after), tick_before, node._bridge.get_current_tick()])
		_check("P4 按問糧源 ⇒ 結果行印原因、零寫入（訊息數與記憶頁都沒變）",
			res_line.contains(reason) and known_after == known_before and mem_after == mem_before)
	node.queue_free()
	await process_frame
	_cells_ran.append("P4")
