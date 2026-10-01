extends SceneTree
# @bed-kind: diagnostic
# slice: 互動子模式重複選項普查（派工 2026-10-01-systems-to-measurer-REPRODUCE-the-duplicate-options-named-hypothesis.md）
#
# ★用戶第三輪玩測逐字抱怨「重複選項」⇒ 先重現再寫斷言（藍圖要求）。
# ★走真的UI節點：`ui_flow_test.gd::_make_ui()`那段構造法(同U21/P4-2-recruit那兩格)，
#   讀`node._screen_label.text`(= P33已經在讀的東西)，零另湊regions、零起transport、零截圖。

func _initialize() -> void:
	var tree_sha := OS.get_environment("DUP_SHA") if OS.has_environment("DUP_SHA") else "?"
	print("=== 互動子模式重複選項普查（tree=%s）===" % tree_sha)

	seed(1337)   # 與 ui_flow_test.gd::_make_ui() 同值
	var node = load("res://scenes/TextUI.tscn").instantiate()
	get_root().add_child(node)
	await process_frame
	await process_frame

	var st = node._bridge.get_state()
	var pid: int = st.player_id
	var ptid: int = st.persons[pid].team_id
	var ppos: Vector2i = st.teams[ptid].tile_pos

	# ── 逐字複現 ui_flow_test.gd 的「聚焦同格NPC」那段構造法（P4-2-recruit同款）──
	var npc := TeamData.new(); npc.team_id = 4321; npc.tile_pos = ppos
	AnonTierSystem.add_anon(npc, "平民", 1)
	npc.faction_id = -1
	st.teams[4321] = npc
	var lead := PersonData.new(); lead.id = 43210; lead.team_id = 4321; lead.loyalty = 0.9
	st.persons[43210] = lead; npc.leader_id = 43210; npc.named_members.append(43210)
	var disloyal := PersonData.new(); disloyal.id = 43211; disloyal.team_id = 4321
	disloyal.loyalty = 0.2; disloyal.person_name = "叛徒"; disloyal.skills = {"戰鬥": 0.5}
	st.persons[43211] = disloyal; npc.named_members.append(43211)
	st.team_discovered[ptid] = st.team_discovered.get(ptid, [])
	if not st.team_discovered[ptid].has(4321): st.team_discovered[ptid].append(4321)
	st.player_pending_targets.append(4321)

	print("[入口] 按鍵：無（直接set _interact_mode/_interact_target,同U21/P4-2-recruit既有做法,未按任何字母/數字鍵）")
	node._interact_mode = true
	node._interact_page = 0
	node._interact_target = 4321
	node._refresh()
	print("[入口] _interact_mode=%s｜_interact_target=%d（已聚焦team4321,尚未進任何更深子選單）" % [
		str(node._interact_mode), node._interact_target])

	var screen: String = String(node._screen_label.text) if node._screen_label != null else ""
	print("[母體] `_screen_label.text` 長度 = %d 字" % screen.length())
	print("\n──────── 那一屏原文（逐字，整份compose輸出）────────")
	print(screen)
	print("──────── 原文結束 ────────\n")

	if screen.strip_edges() == "":
		print("[判讀] ⇒ 【不可判】_screen_label為空,沒重現到任何畫面")
		await node.queue_free(); await process_frame
		quit(2); return

	# ── 用產品自己的權威來源取得「應該有哪些動作標籤」(不另湊regions) ──
	var team_acts: Array = node._interact_action_split()["team"]
	var labels: Array = []
	for a in team_acts:
		var lbl: String = String(a.get("label", a.get("action_id", "")))
		if lbl != "" and not labels.has(lbl):
			labels.append(lbl)
	print("[母體] `_interact_action_split()[\"team\"]` 的標籤（權威來源,去重）＝ %d 個：%s" % [
		labels.size(), str(labels)])

	# ── 按區塊標頭切出 panel 段與 action 段（文字上的物理分界,非猜） ──
	var A_PANEL_MARK: String = "─ 面板（"
	var A_ACTION_MARK: String = "─ 動作（"
	var panel_start: int = screen.find(A_PANEL_MARK)
	var action_start: int = screen.find(A_ACTION_MARK)
	print("[區塊] 面板標頭位置=%d｜動作標頭位置=%d（-1=該屏沒有這一區）" % [panel_start, action_start])

	var panel_text: String = ""
	var action_text: String = ""
	if panel_start != -1 and action_start != -1 and action_start > panel_start:
		panel_text = screen.substr(panel_start, action_start - panel_start)
		action_text = screen.substr(action_start)
	elif action_start != -1:
		action_text = screen.substr(action_start)
		panel_text = screen.substr(0, action_start)
	else:
		panel_text = screen

	# ── 逐標籤核對出現在哪個區塊、各幾次（子字串比對,逐一列名） ──
	var dup_labels: Array = []
	print("\n[普查] 逐標籤出現次數（panel區／action區，子字串比對）：")
	for l in labels:
		var in_panel: int = 0
		var in_action: int = 0
		var idx: int = -1
		while true:
			idx = panel_text.find(String(l), idx + 1)
			if idx == -1: break
			in_panel += 1
		idx = -1
		while true:
			idx = action_text.find(String(l), idx + 1)
			if idx == -1: break
			in_action += 1
		var total: int = in_panel + in_action
		print("   「%s」｜panel=%d｜action=%d｜合計=%d%s" % [
			String(l), in_panel, in_action, total,
			"  ← ★★★重複(panel與action都有)" if (in_panel > 0 and in_action > 0) else ""])
		if in_panel > 0 and in_action > 0:
			dup_labels.append(String(l))

	print("\n[判讀] 重複標籤(同時出現在panel區與action區) = %d 個：%s" % [
		dup_labels.size(), str(dup_labels)])
	if dup_labels.is_empty():
		print("[判讀] ⇒ ★假設被推翻：這一屏看不到同一批選項印兩次")
	else:
		print("[判讀] ⇒ ★★★假設證實：panel區(_build_interact_str,text_ui_main.gd:1899-1910)與"
			+ "action區(action_block(regions.action),text_ui_view.gd:170-190)印了同一批標籤")

	await node.queue_free()
	await process_frame
	print("=== 互動子模式重複選項普查 DONE ===")
	quit(0)
