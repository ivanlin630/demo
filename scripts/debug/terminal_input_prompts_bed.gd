extends SceneTree
# @bed-kind: acceptance
# slice: 終端輸入提示上終端＋頂列威脅句不截＋派遣目標格判斷（spec 2026-10-13-terminal-input-prompts-and-threat-clip-HOW 兩刀）
# 輸入模式提示上終端＋頂列威脅句不截（spec 2026-10-13-terminal-input-prompts-and-threat-clip-HOW 第一刀：改法 1＋3）
#   送鍵走 PlayerRepl.press_on（跟玩家 REPL 同一條路）；終端畫面讀 node._view_dict()（終端那一份 view）
#   P1   子隊面板按 N ⇒ 終端結果列是「輸入：選隊長 (1~N): _」
#   P2   入口普查：裸 `_open_input(` 呼叫點用 grep 數（不手抄）；每一處的型別是字面 "numeric"／"string"
#        ★誠實限：不逐一走到每個入口——入口只傳 prompt／型別／callback，按鍵處置只依型別 ⇒ P1c 按型別逐鍵驗
#   P2b  全檔（去註解）裸寫 `_input_mode = true` ＝ 1；`_open_input("")` 與沒 callback 都不開模式
#   P1b  子隊面板按 N 之後按字母 ⇒ 有回句、面板仍在畫面上；Esc ⇒ 回子隊面板
#   P1b2 主畫面 G 起手 Esc ⇒ 回主畫面；勢力面板起手 Esc ⇒ 回勢力面板
#   P1c  每型送「另一型的合法鍵」＋「兩型都不綁的鍵」⇒ 都有回句（只送符號會綠而病還在）
#   P1d  緩衝滿／Enter 空緩衝／Backspace 空緩衝 ⇒ 各有回句（無 callback 那一格結構上已不存在：_open_input 拒）
#   P1e  輸入期間鍵列是輸入模式鍵表，不是 main
#   P1f  管道餵 `u n 1 enter 2 enter 1 enter 9 enter 1 enter`（舊五步）⇒ 出「派出子隊 TeamN」且世界 tick 不動
#   P1g  下令子隊三步鏈（a q r 任務）走到底 ⇒ 世界 tick 不動、命令生效
#   P1h  勢力目標／下令成員隊任務／顧問情境三處是數字選單；送數字生效、送字母回句；顧問每個選項都不是預設句
#   P3   頂列滿寬（營地欄、長隊名、長家名致預算 ≤ 0）＋敵對隊 ⇒ 威脅句整句 ∈ 模板 render 結果，單列
# 跑法：.\tools\godot.ps1 --headless --script scripts/debug/terminal_input_prompts_bed.gd

const SEED: int = 1337
const REFUSE_TOKEN: String = "此鍵在此模式無作用"

var _errors: int = 0


func _check(label: String, ok: bool) -> void:
	if ok:
		print("  PASS: " + label)
	else:
		_errors += 1
		push_error("[FAIL] " + label)


func _initialize() -> void:
	print("=== terminal_input_prompts：輸入提示上終端、吃鍵必回句、Esc 回起點、威脅句不截 ===")
	_p2_census()
	await _p2b_gate()
	await _p1_p1b_p1e_dispatch()
	await _p1b2_origins()
	await _p1c_p1d_types()
	await _p1f_dispatch_chain()
	await _p1g_order_chain()
	await _p1h_menus()
	await _p3_threat()
	await _p4_p5_dispatch_to_cursor()
	await _p6_targets()
	print("=== terminal_input_prompts DONE === errors: %d" % _errors)
	quit(1 if _errors > 0 else 0)


# ── 共用 ────────────────────────────────────────────────────────────────────
func _build() -> Node:
	seed(SEED)
	var node: Node = load("res://scenes/TextUI.tscn").instantiate()
	get_root().add_child(node)
	await process_frame
	await process_frame
	node.suppress_quit = true
	node._refresh()
	return node


func _drop(node: Node) -> void:
	node.queue_free()
	await process_frame


func _press(node: Node, token: String) -> void:
	await PlayerRepl.press_on(node, PlayerRepl.keycode_for(token))


func _press_all(node: Node, tokens: Array) -> void:
	for t in tokens:
		await _press(node, String(t))


func _view(node: Node) -> Dictionary:
	return node.build_regions("待執行 0 道")


func _tick(node: Node) -> int:
	return node._bridge.get_state().world.current_tick


func _code_lines(path: String) -> Array:
	var out: Array = []
	for l in FileAccess.get_file_as_string(path).split("\n"):
		if l.strip_edges().begins_with("#"):
			continue
		out.append(l)
	return out


# ── P2／P2b ────────────────────────────────────────────────────────────────
func _p2_census() -> void:
	print("\n── P2 入口普查（grep 數 `_open_input(`）──")
	var calls: Array = []
	for l in _code_lines("res://scripts/ui/text_ui_main.gd"):
		var t: String = String(l).strip_edges()
		if t.contains("_open_input(") and not t.begins_with("func _open_input"):
			calls.append(t)
	var typed: int = 0
	for c in calls:
		if String(c).contains("\"numeric\"") or String(c).contains("\"string\""):
			typed += 1
	print("   入口 %d 處；型別寫成字面的 %d 處" % [calls.size(), typed])
	_check("★母體地板：入口數 > 0（數字由 grep 得，不手抄；第一刀 20、第二刀派遣五步併成三步後 18；繞過咽喉由 P2b 抓）", calls.size() > 0)
	_check("P2 每一處入口的型別都是字面 numeric／string（按鍵處置只依型別 ⇒ P1c 覆蓋它們）", typed == calls.size())


func _p2b_gate() -> void:
	print("\n── P2b 咽喉：裸寫 `_input_mode = true` ＝ 1；空 prompt／沒 callback 不開 ──")
	var n: int = 0
	for l in _code_lines("res://scripts/ui/text_ui_main.gd"):
		if String(l).strip_edges() == "_input_mode = true":
			n += 1
	_check("P2b 全檔（去註解）裸寫 `_input_mode = true` ＝ 1（實得 %d）" % n, n == 1)
	var node: Node = await _build()
	var ok1: bool = node._open_input("", "numeric", func(_b): pass)
	var ok2: bool = node._open_input("x: ", "numeric", Callable())
	_check("P2b `_open_input(\"\")` 與沒 callback 都不開模式", not ok1 and not ok2 and not bool(node._input_mode))
	await _drop(node)


# ── P1／P1b／P1e（子隊面板按 N）──────────────────────────────────────────────
func _p1_p1b_p1e_dispatch() -> void:
	print("\n── P1／P1b／P1e 子隊面板按 N：提示上終端、字母有回句、面板留著、Esc 回面板、鍵列是輸入表 ──")
	var node: Node = await _build()
	await _press_all(node, ["u", "n"])
	var v: Dictionary = _view(node)
	var res: String = String(v.get("result", ""))
	var panel0: String = String(v.get("panel", ""))
	print("   結果列「%s」｜鍵列「%s」" % [res, String(v.get("keymap", "")).substr(0, 50)])
	_check("★母體地板：真的進了輸入模式", bool(node._input_mode))
	_check("P1 終端結果列含「輸入：」與提示", res.begins_with("輸入：") and res.contains("選隊長"))
	_check("P1e 輸入期間鍵列是輸入模式鍵表（不是 main）", String(v.get("keymap", "")).contains("[Enter]確定") and not String(v.get("keymap", "")).contains("[T]互動"))
	await _press(node, "k")
	v = _view(node)
	print("   按 k 後結果列「%s」｜面板非空=%s" % [String(v.get("result", "")), str(String(v.get("panel", "")) != "")])
	_check("P1b 輸入中按字母 ⇒ 結果列有回句", String(v.get("result", "")).contains("只收數字"))
	_check("P1b 輸入中面板仍在畫面上（子隊面板）", String(v.get("panel", "")) != "" and String(v.get("panel", "")).contains("子隊"))
	await _press(node, "esc")
	_check("P1b Esc ⇒ 離開輸入、回到子隊面板", not bool(node._input_mode) and bool(node._subteam_mode))
	_check("★面板在輸入前後是同一個（輸入前非空）", panel0 != "")
	await _drop(node)


func _p1b2_origins() -> void:
	print("\n── P1b2 Esc 回起點：主畫面 G ⇒ 主畫面；勢力面板 ⇒ 勢力面板 ──")
	var node: Node = await _build()
	await _press(node, "g")
	var in_g: bool = bool(node._input_mode)
	await _press(node, "esc")
	_check("P1b2 主畫面 G 起手 Esc ⇒ 回主畫面", in_g and not bool(node._input_mode) and node._panel_mode_name() == "main")
	# 勢力面板起手：直接用咽喉（勢力面板的輸入入口要勢力領袖，這一格只驗 origin 機制）
	node._faction_mode = true
	node._open_input("x: ", "numeric", func(_b): pass)
	node._faction_mode = false   # 模擬鏈中途面板被關掉
	await _press(node, "esc")
	_check("P1b2 勢力面板起手 Esc ⇒ 回勢力面板（中途被關也回得去）", not bool(node._input_mode) and bool(node._faction_mode))
	await _drop(node)


# ── P1c／P1d（依型別逐鍵）──────────────────────────────────────────────────
func _p1c_p1d_types() -> void:
	print("\n── P1c 每型送另一型的合法鍵＋兩型都不綁的鍵；P1d 緩衝滿／空 Enter／空 Backspace ──")
	var node: Node = await _build()
	var cases: Array = [["numeric", ["a", "q", "z"]], ["string", ["1", "5", "0"]]]
	for c in cases:
		for k in c[1] + [","]:
			node._open_input("t: ", String(c[0]), func(_b): pass)
			node._feedback_line.text = ""
			await _press(node, String(k))
			var r: String = String(_view(node).get("result", ""))
			_check("P1c %s 模式按 %s ⇒ 有回句（「%s」）" % [c[0], k, r], node._input_reply != "" and node._feedback_line.text.contains(REFUSE_TOKEN))
			node._close_input()
	node._open_input("n: ", "numeric", func(_b): pass)
	await _press_all(node, ["1", "2", "3", "4", "5", "6", "7"])
	_check("P1d 數字緩衝滿（6 位）再按 ⇒ 回句、緩衝不變（%s）" % node._input_buffer, node._input_reply.contains("最多") and node._input_buffer.length() == 6)
	node._close_input()
	node._open_input("s: ", "string", func(_b): pass)
	for i in range(31):
		await _press(node, "a")
	_check("P1d 文字緩衝滿（30 字）再按 ⇒ 回句", node._input_reply.contains("最多") and node._input_buffer.length() == 30)
	node._close_input()
	node._open_input("n: ", "numeric", func(_b): pass)
	await _press(node, "enter")
	_check("P1d Enter 空緩衝 ⇒ 回句、仍在輸入", bool(node._input_mode) and node._input_reply != "")
	await _press(node, "backspace")
	_check("P1d Backspace 空緩衝 ⇒ 回句", node._input_reply != "")
	node._close_input()
	await _drop(node)


# ── P1f／P1g 鏈走到底、時間不動 ──────────────────────────────────────────────
func _p1f_dispatch_chain() -> void:
	print("\n── P1f 派遣五步鏈：派出子隊、世界 tick 不動 ──")
	var node: Node = await _build()
	var t0: int = _tick(node)
	var subs0: int = node._bridge.get_state().teams.size()
	await _press_all(node, ["u", "n", "1", "enter", "2", "enter", "1"])   # 第二刀起三步：隊長、人數、任務（目標＝游標格）
	var t_before_last: int = _tick(node)
	await _press(node, "enter")
	var fb: String = String(node._feedback_line.text)
	print("   結果列「%s」｜tick 鏈前 %d／最後一步前 %d／之後 %d｜隊數 %d→%d" % [fb, t0, t_before_last, _tick(node), subs0, node._bridge.get_state().teams.size()])
	_check("P1f 出「派出子隊 TeamN」", fb.contains("派出子隊"))
	_check("P1f 世界 tick 在鏈中不動（舊版第二步就落到「跳 n 顆 tick」；最後那道令照『按了就做』推一顆）", t_before_last == t0 and _tick(node) <= t0 + 1)
	_check("P1f 鏈走完就離開輸入模式", not bool(node._input_mode))
	await _drop(node)


func _p1g_order_chain() -> void:
	print("\n── P1g 下令子隊三步鏈（a q r 任務）：命令生效、tick 不動 ──")
	var node: Node = await _build()
	await _press_all(node, ["u", "n", "1", "enter", "2", "enter", "1", "enter"])
	var t0: int = _tick(node)
	await _press(node, "1")   # 選第一支子隊
	var sel: int = int(node._subteam_selection)
	await _press_all(node, ["a", "8", "enter", "2", "enter", "2"])
	var t_before_last: int = _tick(node)
	await _press(node, "enter")
	var fb: String = String(node._feedback_line.text)
	print("   選中子隊 %d｜結果列「%s」｜tick 鏈前 %d／最後一步前 %d／之後 %d" % [sel, fb, t0, t_before_last, _tick(node)])
	_check("★母體地板：真的選到一支子隊", sel >= 0)
	_check("P1g 三步鏈走到底 ⇒ 下令命令有結果句、離開輸入", fb.contains("已下令") and not bool(node._input_mode))
	_check("P1g 世界 tick 在鏈中不動（最後那道令推一顆）", t_before_last == t0 and _tick(node) <= t0 + 1)
	await _drop(node)


# ── P1h 三個數字選單 ────────────────────────────────────────────────────────
func _p1h_menus() -> void:
	print("\n── P1h 勢力目標／下令成員隊任務／顧問情境：數字選單 ──")
	var node: Node = await _build()
	var st: WorldState = node._bridge.get_state()
	var ptid: int = st.get_player_team_id()
	var pt: TeamData = st.teams[ptid]
	# 佈置：玩家當一個勢力的領袖、勢力裡有另一支成員隊
	var fid: int = int(st.factions.keys()[0])
	var f: FactionData = st.factions[fid]
	pt.faction_id = fid
	f.leader_team_id = ptid
	if not f.member_team_ids.has(ptid):
		f.member_team_ids.append(ptid)
	var mate: TeamData = null
	for tid in f.member_team_ids:
		if int(tid) != ptid and st.teams.has(tid):
			mate = st.teams[tid]
			break
	# 勢力目標
	await _press(node, "f")
	await _press(node, "a")
	var v: Dictionary = _view(node)
	_check("★勢力目標：開了數字輸入、選單印在面板上", bool(node._input_mode) and node._input_mode_type == "numeric" and String(v.get("panel", "")).contains("[1] 擴張"))
	await _press(node, "x")
	_check("P1h 勢力目標送字母 ⇒ 回句", node._input_reply != "")
	await _press_all(node, ["2", "enter"])
	print("   勢力目標 ⇒ player_goal_override=%s｜結果列「%s」" % [f.player_goal_override, node._feedback_line.text])
	_check("P1h 勢力目標送數字 ⇒ 生效（防守）", f.player_goal_override == "defend")
	# 下令成員隊任務
	if mate != null:
		await _press(node, "1")
		var v2: Dictionary = _view(node)
		_check("★下令成員隊：數字選單印在面板上（含清除命令）", bool(node._input_mode) and String(v2.get("panel", "")).contains("清除命令"))
		await _press(node, "q")
		_check("P1h 下令成員隊送字母 ⇒ 回句", node._input_reply != "")
		await _press_all(node, ["2", "enter"])
		var pend: Dictionary = st.player_pending_orders.get(str(mate.team_id), {})
		print("   下令 Team%d ⇒ pending %s｜結果列「%s」" % [mate.team_id, str(pend), node._feedback_line.text])
		_check("P1h 下令成員隊送數字 ⇒ 生效（覓食）或說出原因", String(pend.get("task", "")) == TeamData.TASK_FORAGE or node._feedback_line.text != "")
	else:
		_check("★母體地板：勢力裡有另一支成員隊（下令成員隊那一格要它）", false)
	await _press(node, "esc")
	# sim 側拒絕未知任務
	st.player_state["order_member_id"] = mate.team_id if mate != null else -1
	st.player_state["member_task"] = "fly_to_moon"
	var rr: Dictionary = PlayerCommandSystem.new().execute_action(st, -1, "order_faction_member")
	_check("P1h sim 側拒絕不在 ORDERABLE_TASKS 的任務", not bool(rr.get("ok", true)) and String(rr.get("msg", "")).contains("不能下令"))
	# 顧問
	await _press(node, "v")
	await _press(node, "1")
	var v3: Dictionary = _view(node)
	var sits: Array = AdvisorSystem.menu_situations()
	_check("★顧問：數字選單、項目＝AdvisorSystem 鍵 ∩ TextBank 模板（%s）" % str(sits), bool(node._input_mode) and sits.size() == 3 and String(v3.get("panel", "")).contains("[1] "))
	await _press(node, "esc")
	var fallback: String = TextBank.fmt("advisor_no_such_situation", "x")
	var bad: Array = []
	for i in range(sits.size()):
		await _press(node, "1")
		await _press_all(node, [str(i + 1), "enter"])
		var fbk: String = String(node._feedback_line.text)
		if not fbk.begins_with("✓ 顧問：") or fbk.contains(fallback) or fbk.contains("有動靜"):
			bad.append("%s ⇒ %s" % [sits[i], fbk])
	print("   顧問各選項：預設句 %d 個 %s" % [bad.size(), str(bad)])
	_check("P1h 顧問每個選項的輸出都不是預設句", bad.is_empty())
	await _drop(node)


# ── P3 頂列威脅句不截 ────────────────────────────────────────────────────────
func _p3_threat() -> void:
	print("\n── P3 頂列滿寬：威脅句整句 ∈ 模板，單列 ──")
	var node: Node = await _build()
	var real: Dictionary = (node.build_regions("待執行 0 道")["top"] as Dictionary)
	var real_row: String = TextUiView.top_row(real)
	print("   真實開局頂列（%d 欄）：%s" % [TextUiLayout.display_width(real_row), real_row])
	print("   真實欄位：%s" % str(real))
	await _drop(node)
	var long_name: String = "很長很長很長很長很長很長的隊伍名字很長很長很長很長很長"
	var long_home: String = "很長很長很長很長很長很長的家名很長很長很長很長很長很長"
	var enemy: String = PlayerApiMapper.THREAT_ENEMY % [12345, 7]
	var v: Dictionary = {"clock": "1 天 08:00", "team_name": long_name, "pop": "143", "home": long_home,
		"camp": "(12,34) 離 9", "food": "12 天", "threat": enemy, "pending": "3 道"}
	var row: String = TextUiView.top_row(v)
	print("   頂列：%s" % row)
	print("   寬度 %d／%d｜威脅預留 %d" % [TextUiLayout.display_width(row), TextUiLayout.COLS, TextUiView.threat_reserve()])
	_check("P3 威脅句整句出現（不以半句結尾）", row.contains("威脅：" + enemy))
	_check("P3 單列、不超過 %d 欄" % TextUiLayout.COLS, not row.contains("\n") and TextUiLayout.display_width(row) <= TextUiLayout.COLS)
	_check("P3 長隊名／長家名用「…」截", row.contains("…"))
	_check("P3 真實開局頂列：隊名沒被截（威脅句短時名字放得下）", real_row.contains(String(real.get("team_name", "?"))) and TextUiLayout.display_width(real_row) <= TextUiLayout.COLS)
	_check("P3 最長的威脅句（%d 欄）也放得進一列" % TextUiView.threat_reserve(), TextUiView.threat_reserve() < TextUiLayout.COLS / 2)
	# budget ≤ 0 那一格：營地欄超長
	v["camp"] = "很長很長很長很長很長很長很長很長很長很長很長很長很長很長很長很長很長很長很長很長"
	var row2: String = TextUiView.top_row(v)
	print("   預算 ≤ 0：%s" % row2)
	_check("P3 預算 ≤ 0 時威脅句仍整句（舊版威脅欄整個變空）", row2.contains("威脅：" + enemy))
	for t in [PlayerApiMapper.THREAT_ENGAGED % "Team12345", PlayerApiMapper.THREAT_BEAST % ["西北", "狼群"], PlayerApiMapper.THREAT_NONE]:
		v["camp"] = "(12,34) 離 9"
		v["threat"] = t
		var r3: String = TextUiView.top_row(v)
		_check("P3 模板「%s」整句、單列不超寬" % t, r3.contains("威脅：" + t) and TextUiLayout.display_width(r3) <= TextUiLayout.COLS)


# ══ 第二刀：派遣按即做 ═══════════════════════════════════════════════════════
#   P4  主畫面游標移到可達格、U N 隊長 人數 任務 ⇒ 子隊出發、目標＝游標格；全程不打座標
#   P5  派遣模態中，面板上帶 [n] 的只有那一組選單（子隊列表不帶號）
#   P6  已知但到不了的格（手造地圖洞）⇒ N 直接回原因、不開模態
#   P6b 游標在腳下按 N ⇒ 進流程
#   P6c 沒去過的格：N 不拒；選安頓／建設 ⇒ 拒並說原因；選偵查 ⇒ 出發；判斷沒呼叫 find_path；不在地圖上 ⇒ 回原因
#   P6e Esc 任一步 ⇒ 清掉已寫的派遣殘值、回子隊面板
func _subteams_of(st: WorldState, ptid: int) -> Array:
	var out: Array = []
	for tid in st.teams:
		if int((st.teams[tid] as TeamData).parent_team_id) == ptid:
			out.append(int(tid))
	return out


func _p4_p5_dispatch_to_cursor() -> void:
	print("\n── P4／P5 主畫面游標＝目標；派遣三步不打座標；同屏只有一組數字 ──")
	var node: Node = await _build()
	var st: WorldState = node._bridge.get_state()
	var ptid: int = st.get_player_team_id()
	await _press_all(node, ["d", "d"])
	var tgt: Vector2i = node._cursor
	var before: Array = _subteams_of(st, ptid)
	await _press_all(node, ["u", "n"])
	var panel: String = String(_view(node).get("panel", ""))
	var numbered: int = panel.count("[1]")
	print("   目標 %s｜模態中面板 [1] 出現 %d 次" % [str(tgt), numbered])
	_check("P5 派遣模態中同屏只有一組帶號的選單", numbered == 1)
	_check("P4 每一步提示印凍結的目標", String(_view(node).get("result", "")).contains("目標＝(%d,%d)" % [tgt.x, tgt.y]))
	await _press_all(node, ["1", "enter", "2", "enter", "2", "enter"])
	var after: Array = _subteams_of(st, ptid).filter(func(t): return not before.has(t))
	var mt: Vector2i = (st.teams[after[0]] as TeamData).move_target if not after.is_empty() else Vector2i(-9, -9)
	print("   新子隊 %s｜move_target %s｜結果列「%s」" % [str(after), str(mt), node._feedback_line.text])
	_check("P4 子隊出發、目標＝游標格（全程沒打座標）", after.size() == 1 and mt == tgt)
	await _drop(node)


func _p6_targets() -> void:
	print("\n── P6 目標格判斷：不可達／腳下／沒去過／不在地圖上；Esc 清殘值 ──")
	var node: Node = await _build()
	var st: WorldState = node._bridge.get_state()
	var pt: TeamData = st.teams[st.get_player_team_id()]
	# P6：已知但到不了（目標的六鄰格移出地圖）
	var hole: Vector2i = pt.tile_pos + Vector2i(3, 0)
	for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1), Vector2i(1, -1), Vector2i(-1, 1)]:
		st.world.tiles.erase((hole + d).x * 1000 + (hole + d).y)
	var known: Dictionary = st.team_tile_known.get(pt.team_id, {})
	known[hole.x * 1000 + hole.y] = true
	st.team_tile_known[pt.team_id] = known
	node._cursor = hole
	await _press_all(node, ["u", "n"])
	print("   不可達 %s ⇒ 結果列「%s」｜輸入模式 %s" % [str(hole), node._feedback_line.text, str(node._input_mode)])
	_check("P6 已知不可達 ⇒ N 回「沒有路」、不開模態", node._feedback_line.text.contains("沒有路") and not bool(node._input_mode))
	await _press(node, "esc")
	# P6b：腳下
	node._cursor = pt.tile_pos
	await _press_all(node, ["u", "n"])
	_check("P6b 游標在腳下按 N ⇒ 進流程", bool(node._input_mode))
	# P6e：Esc 中途 ⇒ 清殘值、回子隊面板
	await _press_all(node, ["1", "enter"])
	var had: bool = st.player_state.has("sub_leader_id")
	await _press(node, "esc")
	_check("P6e Esc 中途 ⇒ 清掉已寫的派遣殘值、回子隊面板", had and not st.player_state.has("sub_leader_id") and bool(node._subteam_mode) and not bool(node._input_mode))
	await _press(node, "esc")
	# P6c：沒去過的格
	var far: Vector2i = pt.tile_pos + Vector2i(-9, 0)
	if not st.world.tiles.has(far.x * 1000 + far.y):
		far = pt.tile_pos + Vector2i(0, 9)
	var status: String = String(PlayerQueryApi.tile_knowledge(st, far).get("status", ""))
	Probe.enabled = true
	var p0: int = int(Probe.counts.get("path.cache_hit", 0)) + int(Probe.counts.get("path.cache_miss", 0))
	var chk: Dictionary = node._bridge.check_target(far.x, far.y)
	var p1: int = int(Probe.counts.get("path.cache_hit", 0)) + int(Probe.counts.get("path.cache_miss", 0))
	Probe.enabled = false
	print("   沒去過 %s（%s）⇒ %s｜find_path 呼叫 %d 次" % [str(far), status, str(chk), p1 - p0])
	_check("★母體地板：那一格對玩家是沒去過", status == "unvisited")
	_check("P6c 沒去過 ⇒ 判斷回「還沒去過」且沒呼叫 find_path（不洩露真地形）", String(chk.get("reason", "")).contains("還沒去過") and p1 == p0)
	node._cursor = far
	await _press_all(node, ["u", "n"])
	_check("P6c 沒去過的格 N 不拒、進流程", bool(node._input_mode))
	var build_idx: int = 0
	var scout_idx: int = 0
	# ★派遣選單＝子隊那一份（spec 2026-10-13-player-subteams 三：建設改派 TASK_CONSTRUCT；成員隊另用 ORDERABLE_TASKS）
	for i in range(TextUiMain.SUBTEAM_TASK_CHOICES.size()):
		if String(TextUiMain.SUBTEAM_TASK_CHOICES[i][0]) == TeamData.TASK_CONSTRUCT: build_idx = i + 1
		if String(TextUiMain.SUBTEAM_TASK_CHOICES[i][0]) == TeamData.TASK_SCOUT: scout_idx = i + 1
	await _press_all(node, ["1", "enter", "2", "enter", str(build_idx), "enter"])
	var fb_b: String = node._feedback_line.text
	_check("P6c 沒去過的格選建設 ⇒ 拒並說原因（要先知道地形）、留在任務那一步", fb_b.contains("要先知道") and bool(node._input_mode))
	await _press_all(node, [str(scout_idx), "enter"])
	print("   建設「%s」｜偵查「%s」" % [fb_b, node._feedback_line.text])
	_check("P6c 沒去過的格選偵查 ⇒ 出發", node._feedback_line.text.contains("派出子隊"))
	var off: Dictionary = node._bridge.check_target(-50, -50)
	_check("P6c 不在地圖上 ⇒ 回原因", not bool(off.get("ok", true)) and String(off.get("reason", "")).contains("不在地圖上"))
	await _drop(node)
