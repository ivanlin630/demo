extends SceneTree
# @bed-kind: acceptance
# 客戶端不解釋遊戲鍵＋離開不綁 Q＋情報帶內容（spec 2026-10-13-play-client-no-key-interpretation-HOW）
#   送鍵走 PlayerRepl.press_on（跟玩家 REPL 同一條路）；離開以 text_ui_main.quit_requests 計（床設 suppress_quit，不真的收掉）
#   Q1  進遭遇戰後送 q ⇒ 程式仍在、仍在戰鬥畫面、沒有要求離開
#   Q2  主畫面送 q ⇒ 沒有要求離開、游標／tick 不變
#   Q3  主畫面 Esc 一次 ⇒ 不離開＋結果行「再按一次 Esc 離開」；再一次 ⇒ 要求離開
#   Q3b Esc→w→Esc ⇒ 不離開；w 之後結果行不再是提示
#   Q3c Esc 上膛→進遭遇戰→Esc ⇒ 不離開
#   Q4  面板開著時 Esc ⇒ 只關面板（不上膛）；面板開著連按 Esc×3 ⇒ 離開
#   Q6  戰後「按任意鍵離開」那一鍵只被派一次：(i) PlayerRepl.press_on（終端）(ii) Viewport.push_input（引擎廣播，GUI）
#   Q7  自家隊 intel_arrived 句子含對象與座標：親見「你看到…」、轉述「你得知…（…前的消息）」
#   Q7b 友軍隊的 intel_arrived 不含對象與座標
#   （Q3 的客戶端那一半——play.py 退出碼 0、印「遊戲已結束」——在 tools/play_selfcheck.py；Q5 在 play.py --selfcheck）
# 跑法：.\tools\godot.ps1 --headless --script scripts/debug/play_client_keys_bed.gd

const SEED: int = 1337
const NPC_ID: int = 7320
const HINT: String = "再按一次 Esc 離開"

var _errors: int = 0


func _check(label: String, ok: bool) -> void:
	if ok:
		print("  PASS: " + label)
	else:
		_errors += 1
		push_error("[FAIL] " + label)


func _initialize() -> void:
	print("=== play_client_keys：遊戲鍵原樣進遊戲；離開＝Esc 兩段；戰後一鍵一派；情報帶內容 ===")
	await _q1_q_in_battle()
	await _q2_q_on_main()
	await _q3_esc_twice()
	await _q3b_disarm()
	await _q3c_armed_then_battle()
	await _q4_panel()
	await _q6_post_battle_terminal()
	await _q6_post_battle_engine()
	await _q7_intel()
	print("=== play_client_keys DONE === errors: %d" % _errors)
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


func _result(node: Node) -> String:
	return String(node._feedback_line.text)


func _in_battle(node: Node) -> bool:
	return node._encounter_view != null and node._encounter_view.visible


# 一支 NPC 隊站在玩家格上 ⇒ 伏擊玩家 ⇒ 推一步進戰鬥（同 terminal_e2e_bed 的佈置）
func _enter_battle(node: Node) -> void:
	var st: WorldState = node._bridge._state
	var ptid: int = st.get_player_team_id()
	if not st.teams.has(NPC_ID):
		var t := TeamData.new()
		t.team_id = NPC_ID
		t.faction_id = -1
		t.tile_pos = st.teams[ptid].tile_pos
		AnonTierSystem.add_anon(t, AnonCohort.TIER_PLEB, 4)
		var l := PersonData.new()
		l.id = NPC_ID * 10 + 1
		l.team_id = NPC_ID
		l.person_name = "首領%d" % NPC_ID
		st.persons[l.id] = l
		t.leader_id = l.id
		st.teams[NPC_ID] = t
	EncounterSystem.new().init_encounter(st, NPC_ID, ptid, "ambush")
	await _press(node, "x")


# 把仗結束、停在戰後「按任意鍵離開」那一拍
func _to_post_battle(node: Node) -> bool:
	await _enter_battle(node)
	if not _in_battle(node):
		return false
	var st: WorldState = node._bridge._state
	EncounterSystem.new().resolve_encounter_end(st, "draw")
	for i in range(4):
		node._encounter_view.sync_with_world()
		await process_frame
	return _in_battle(node) and bool(node._encounter_view._post_combat)


# ── Q1／Q2 ──────────────────────────────────────────────────────────────────
func _q1_q_in_battle() -> void:
	print("\n── Q1 戰鬥中送 q ⇒ 不離開、仍在戰鬥 ──")
	var node: Node = await _build()
	await _enter_battle(node)
	var in0: bool = _in_battle(node)
	await _press(node, "q")
	print("   進戰鬥=%s｜送 q 後 仍在戰鬥=%s｜要求離開 %d｜戰鬥回覆：%s" % [str(in0), str(_in_battle(node)),
		node.quit_requests, String(node._encounter_view.key_reply()).substr(0, 60)])
	_check("★母體地板：真的進了戰鬥", in0)
	_check("Q1 戰鬥中 q ⇒ 沒有要求離開、仍在戰鬥畫面", node.quit_requests == 0 and _in_battle(node))
	await _drop(node)


func _q2_q_on_main() -> void:
	print("\n── Q2 主畫面送 q ⇒ 靜默、狀態不變 ──")
	var node: Node = await _build()
	var c0: Vector2i = node._cursor
	var t0: int = node._bridge._state.world.current_tick
	await _press(node, "q")
	print("   要求離開 %d｜游標 %s→%s｜tick %d→%d" % [node.quit_requests, str(c0), str(node._cursor), t0, node._bridge._state.world.current_tick])
	_check("Q2 主畫面 q ⇒ 沒有要求離開、游標與 tick 不變", node.quit_requests == 0 and node._cursor == c0
		and node._bridge._state.world.current_tick == t0)
	await _drop(node)


# ── Q3 系列 ────────────────────────────────────────────────────────────────
func _q3_esc_twice() -> void:
	print("\n── Q3 主畫面 Esc 兩段 ──")
	var node: Node = await _build()
	await _press(node, "esc")
	var r1: String = _result(node)
	var q1: int = node.quit_requests
	await _press(node, "esc")
	print("   第一次 Esc：要求離開 %d｜結果行「%s」｜第二次後 要求離開 %d" % [q1, r1, node.quit_requests])
	_check("Q3 Esc 一次 ⇒ 不離開＋提示", q1 == 0 and r1.contains(HINT))
	_check("Q3 Esc 兩次 ⇒ 要求離開", node.quit_requests == 1)
	await _drop(node)


func _q3b_disarm() -> void:
	print("\n── Q3b Esc→w→Esc ⇒ 不離開；w 之後提示撤掉 ──")
	var node: Node = await _build()
	await _press(node, "esc")
	await _press(node, "w")
	var r_after_w: String = _result(node)
	await _press(node, "esc")
	print("   w 之後結果行「%s」｜要求離開 %d" % [r_after_w, node.quit_requests])
	_check("Q3b w 之後結果行不再是「%s」" % HINT, not r_after_w.contains(HINT))
	_check("Q3b Esc→w→Esc ⇒ 不離開", node.quit_requests == 0)
	await _drop(node)


func _q3c_armed_then_battle() -> void:
	print("\n── Q3c Esc 上膛→進戰鬥→Esc ⇒ 不離開 ──")
	var node: Node = await _build()
	await _press(node, "esc")
	await _enter_battle(node)
	var inb: bool = _in_battle(node)
	await _press(node, "esc")
	print("   進戰鬥=%s｜要求離開 %d" % [str(inb), node.quit_requests])
	_check("★母體地板：上膛之後真的進了戰鬥", inb)
	_check("Q3c 上膛→進戰鬥→Esc ⇒ 不離開", node.quit_requests == 0)
	await _drop(node)


func _q4_panel() -> void:
	print("\n── Q4 面板開著：Esc 只關面板；Esc×3 才離開 ──")
	var node: Node = await _build()
	await _press(node, "i")
	var open0: bool = bool(node._inv_mode)
	await _press(node, "esc")
	var closed: bool = not bool(node._inv_mode)
	var r1: String = _result(node)
	var q1: int = node.quit_requests
	await _press(node, "esc")
	var q2: int = node.quit_requests
	await _press(node, "esc")
	print("   開面板=%s｜第一次 Esc 關了=%s 結果行「%s」｜要求離開 %d→%d→%d" % [str(open0), str(closed), r1, q1, q2, node.quit_requests])
	_check("★母體地板：I 真的開了物品面板", open0)
	_check("Q4 面板開著 Esc ⇒ 只關面板、不上膛", closed and q1 == 0 and not r1.contains(HINT))
	_check("Q4 面板開著連按 Esc×3 ⇒ 第二次不離開、第三次離開", q2 == 0 and node.quit_requests == 1)
	await _drop(node)


# ── Q6 戰後那一拍 ───────────────────────────────────────────────────────────
func _q6_post_battle_terminal() -> void:
	print("\n── Q6(i) 戰後一鍵（終端 PlayerRepl.press_on）⇒ 只派一次 ──")
	var node: Node = await _build()
	var ok: bool = await _to_post_battle(node)
	var c0: Vector2i = node._cursor
	await _press(node, "w")
	print("   到戰後畫面=%s｜按 w 後 戰鬥畫面=%s｜游標 %s→%s" % [str(ok), str(_in_battle(node)), str(c0), str(node._cursor)])
	_check("★母體地板：停在戰後「按任意鍵離開」", ok)
	_check("Q6(i) 戰後那一鍵：關掉戰鬥畫面、主畫面游標沒被同一鍵移動", not _in_battle(node) and node._cursor == c0)
	await _drop(node)


func _q6_post_battle_engine() -> void:
	print("\n── Q6(ii) 戰後一鍵（引擎 Viewport.push_input，GUI 廣播）⇒ 只派一次 ──")
	var node: Node = await _build()
	var ok: bool = await _to_post_battle(node)
	var c0: Vector2i = node._cursor
	var ev := InputEventKey.new()
	ev.keycode = KEY_W
	ev.physical_keycode = KEY_W
	ev.pressed = true
	# ★headless 下 Input.parse_input_event 不會派到節點（實測：戰鬥畫面沒被關＝鍵沒送到）
	#   ⇒ 改用 Viewport.push_input：引擎把同一個事件依序廣播給 viewport 裡每個節點的 _input（GUI 那條路）
	get_root().push_input(ev)
	await process_frame
	await process_frame
	print("   到戰後畫面=%s｜送 W 後 戰鬥畫面=%s｜游標 %s→%s" % [str(ok), str(_in_battle(node)), str(c0), str(node._cursor)])
	_check("★母體地板：停在戰後「按任意鍵離開」", ok)
	_check("★母體地板：引擎注入的鍵真的送到了（戰鬥畫面被關掉）", not _in_battle(node))
	_check("Q6(ii) 戰後那一鍵：主畫面游標沒被同一鍵移動", node._cursor == c0)
	await _drop(node)


# ── Q7 情報 ─────────────────────────────────────────────────────────────────
func _last_intel(st: WorldState, seq0: int) -> String:
	var out: String = ""
	for e in st.player_events:
		var d: Dictionary = e
		if int(d.get("seq", 0)) > seq0 and String(d.get("kind", "")) == "intel_arrived":
			out = String(d.get("text", ""))
	return out


func _fresh_target(st: WorldState, obs: int, avoid: Array) -> int:
	var ids: Array = st.teams.keys()
	ids.sort()
	for tid in ids:
		if int(tid) in avoid or int(tid) == obs:
			continue
		if not BeliefSystem.claims(st, obs, int(tid)).is_empty():
			continue
		return int(tid)
	return -1


func _q7_intel() -> void:
	print("\n── Q7 情報帶內容（自家）／Q7b 友軍不帶 ──")
	seed(SEED)
	var st := WorldState.new()
	GameSetup.setup(st, GameSetup.load_config("res://config/default.json"))
	var ptid: int = st.get_player_team_id()
	# 親見
	var t1: int = _fresh_target(st, ptid, [])
	var seq: int = st.player_event_seq
	BeliefSystem.record_claim(st, ptid, t1, ptid, "親見", {"tile_pos": Vector2i(3, 4)}, 1.0, false)
	var s1: String = _last_intel(st, seq)
	# 轉述（給情報的那隊 30 分鐘前親見）
	var giver: int = _fresh_target(st, ptid, [t1])
	var t2: int = _fresh_target(st, ptid, [t1, giver])
	seq = st.player_event_seq
	var seen_at: int = st.world.current_tick - 30 * WorldState.TICKS_PER_HOUR / 60
	BeliefSystem.record_claim(st, ptid, t2, giver, "轉述", {"tile_pos": Vector2i(5, 6), "last_tick": seen_at}, 0.6, false)
	var s2: String = _last_intel(st, seq)
	print("   親見：「%s」｜轉述：「%s」" % [s1, s2])
	_check("★母體地板：兩則都真的進了玩家事件流", s1 != "" and s2 != "")
	_check("Q7 親見句含「你看到」、對象與座標", s1.begins_with("你看到") and s1.contains("Team%d" % t1) and s1.contains("(3,4)"))
	_check("Q7 轉述句含「你得知」、對象、座標與幾分鐘前", s2.begins_with("你得知") and s2.contains("Team%d" % t2)
		and s2.contains("(5,6)") and s2.contains("30 分鐘前"))
	# Q7b：友軍（同勢力、非自家）收到情報
	var ally: TeamData = null
	var ids: Array = st.teams.keys()
	ids.sort()
	for tid in ids:
		var t: TeamData = st.teams[tid]
		if int(tid) != ptid and t.beast_kind == "" and t.leader_id != -1:
			ally = t
			break
	var fid: int = int(st.teams[ptid].faction_id)
	if fid == -1:
		fid = int(st.factions.keys()[0]) if not st.factions.is_empty() else 0
		st.teams[ptid].faction_id = fid
	ally.faction_id = fid
	var t3: int = _fresh_target(st, ally.team_id, [ptid])
	seq = st.player_event_seq
	BeliefSystem.record_claim(st, ally.team_id, t3, ally.team_id, "親見", {"tile_pos": Vector2i(7, 8)}, 1.0, false)
	var s3: String = _last_intel(st, seq)
	print("   友軍 Team%d 的情報：「%s」" % [ally.team_id, s3])
	_check("★母體地板：友軍那則真的進了玩家事件流（同勢力放行）", s3 != "")
	_check("Q7b 友軍那則不含對象與座標", not s3.contains("Team%d" % t3) and not s3.contains("(7,8)"))
