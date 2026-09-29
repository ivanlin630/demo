extends SceneTree
# @bed-kind: acceptance
# slice: 按一下＝做一顆 tick（spec 2026-09-29 #8）＋ 濫按母體
#
# ★★★這支床要證明的那一句：玩家按下去的東西【同一幀就結算】——
#   在本票之前，每道令入列後要等玩家再做一件別的事（按 Space／X／移動）才生效，
#   ⇒ 用戶逐字：「玩家的介面就是按啥做啥」。
#
# ★★掛鉤位置是 systems 寫死的：`SimBridge.command_player()` 這一個咽喉，
#   不在 UI 的呼叫點上。★而本床的 P4 把【那個咽喉涵蓋幾個呼叫點】印成母體 ——
#   理由是 spec §1① 的數字（36）低估了它自己：活的呼叫點是 45 個。
#
# ★誠實限：
#   1. 吸附（X／Space 停在整點／隔日）在 `text_ui_main._snap_to()` ⇒ 需要 UI 節點
#      ⇒ 那兩格在 `ui_flow_test`（P8 ＋ P21 兩向），不在這裡。
#   2. P5 濫按【只印母體不下判斷】：「20 次之後對方該怎樣算合理」是 WHAT
#      ⇒ 卷面交 blueprint 判（spec §5③ 逐字）。

var _errors: int = 0
var _cells_ran: Array = []

# ★來自 spec §1① 的數字 ——★★而它是【被我訂正過】的：spec 寫 36，實際活的是 45。
#   欄目逐檔寫出來，這樣下一個人看得到 36 是從哪裡來的、少算了什麼。
const SPEC_CALLSITES_TEXT_UI: int = 36      # spec §1① 逐字那一個
const SPEC_CALLSITES_ENCOUNTER: int = 5     # ★text_ui_main:156 動態 new 的活 overlay
const SPEC_CALLSITES_POPUP: int = 4         # ★同上（裝備／取存物品）
const SPEC_CALLSITES_DEAD_MAIN: int = 10    # ☠Main.tscn 死樹（不算在活母體裡）
const SPEC_LIVE_CALLSITES: int = SPEC_CALLSITES_TEXT_UI + SPEC_CALLSITES_ENCOUNTER \
	+ SPEC_CALLSITES_POPUP
const ABUSE_N: int = 20                     # spec §4 P3：同一分鐘內連發幾次

const EXPECTED_CELLS: Array = [
	"_test_p1_one_press_one_tick",
	"_test_p2_unknown_command_does_not_advance",
	"_test_p3_advancing_is_the_exception",
	"_test_p4_one_chokepoint_covers_all_callsites",
	"_test_p5_abuse_population",
]


func _cell(name: String) -> void:
	if not _cells_ran.has(name):
		_cells_ran.append(name)

func _check(msg: String, cond: bool) -> void:
	if cond:
		print("  PASS: " + msg)
	else:
		_errors += 1
		push_error("[FAIL] " + msg)

func _fresh() -> Array:
	seed(20260929)
	var st := WorldState.new()
	GameSetup.setup(st, GameSetup.load_config("res://config/warring_states.json"))
	var runner := SimRunner.new()
	return [st, runner, SimBridge.new(runner, st)]

# 玩家看到的那一句。★★★不在 `command_log` 裡：它只有 tick/seq/name/args/ok
#   （`sim_runner.gd:559`），★人話在 `command_results.text`（`:576`，2026-09-28 那張票做的）。
#   ⇒ 我第一版讀 `command_log` 的 `msg` ⇒ **20 列母體的 msg 欄全空**，
#     而 spec §4 P3 要的正是「20 次各自的回傳（ok／msg）」⇒ 少了一半而卷面看起來還很完整。
#   ★★這一族＝【讀了一個不存在的欄位】：`Dictionary.get` 給預設值，所以它不會噴錯。
func _last_sentence(st: WorldState) -> String:
	if st.command_results.is_empty():
		return "（command_results 是空的）"
	return String(st.command_results[st.command_results.size() - 1].get("text", ""))

func _code_only(src: String) -> String:
	var out: String = ""
	for l in src.split("\n"):
		if l.strip_edges().begins_with("#"):
			continue
		out += l + "\n"
	return out


func _initialize() -> void:
	print("=== 按一下＝做一顆 tick（#8）===")
	_test_p1_one_press_one_tick()
	_test_p2_unknown_command_does_not_advance()
	_test_p3_advancing_is_the_exception()
	_test_p4_one_chokepoint_covers_all_callsites()
	_test_p5_abuse_population()
	var miss: Array = []
	for c in EXPECTED_CELLS:
		if not _cells_ran.has(c): miss.append(c)
	if not miss.is_empty():
		_errors += 1
		push_error("[FAIL] 到場點名少了：%s" % str(miss))
	print("=== press_is_one_tick DONE === errors: %d｜到場點名 %d／%d" % [
		_errors, _cells_ran.size(), EXPECTED_CELLS.size()])
	quit(1 if _errors > 0 else 0)


# ══ P1：按一道【會成功】的令 ⇒ 請求量 1、消費後 tick 恰 +1 ════════════════
# ★★★母體地板（spec §4 P1 逐字）：先斷言那道令【真的成功】——
#   ★失敗的令也會 +1，而「+1」在兩種情形下長得【一模一樣】
#   ⇒ 所以這一格同時跑一道【會被消費點拒絕】的令，把兩者並排印出來：
#     那兩行的 tick 增量相同、而 ok 欄不同 ⇒ 卷面自己證明「+1」不足以當判準。
# 負對照：把咽喉那一行 `request_advance(1)` 關掉（`if false`）⇒ 請求量 0｜★blueprint 指定的陽性對照 ⇒ 已於 feat/press-is-one-tick（2026-09-29 這一輪） 實測紅
func _test_p1_one_press_one_tick() -> void:
	print("\n── P1 按一下＝一顆 ──")
	var tri: Array = _fresh()
	var st: WorldState = tri[0]
	var bridge: SimBridge = tri[2]
	var pt: TeamData = st.teams.get(st.get_player_team_id())
	_check("母體地板 A：造得出玩家隊", pt != null)
	if pt == null:
		_cell("_test_p1_one_press_one_tick")
		return
	# ── 會成功的令：移動到鄰格
	var t0: int = st.world.current_tick
	var dst: Vector2i = pt.tile_pos + Vector2i(1, 0)
	var r: Dictionary = bridge.command_player("move_to", {"tile_q": dst.x, "tile_r": dst.y})
	var asked: int = bridge.ticks_remaining()
	print("   入列回傳 queued=%s｜請求量=%d" % [str(r.get("queued", false)), asked])
	_check("入列成功", bool(r.get("queued", false)))
	_check("★★咽喉自動請求【正好一顆】（實測 %d）" % asked, asked == 1)
	var before_n: int = st.command_log.size()
	bridge.tick_step()
	var t1: int = st.world.current_tick
	var ok1: bool = false
	var msg1: String = ""
	if st.command_log.size() > before_n:
		ok1 = bool(st.command_log[st.command_log.size() - 1].get("ok", false))
		msg1 = _last_sentence(st)
	print("   成功令：tick %d → %d（+%d）｜消費點 ok=%s msg=%s" % [t0, t1, t1 - t0, str(ok1), msg1])
	_check("★母體地板 B：那道令【真的成功】（ok=true）—— 失敗的令也會 +1", ok1)
	_check("★★★tick 恰 +1（%d）" % (t1 - t0), t1 - t0 == 1)
	_check("消費完頁腳歸零（pending=%d）" % bridge.pending_command_count(),
		bridge.pending_command_count() == 0)

	# ── 並排：會被【消費點】拒絕的令（合法 verb、非法目標）
	var t2: int = st.world.current_tick
	bridge.command_player("move_to", {"tile_q": -999, "tile_r": -999})
	var asked2: int = bridge.ticks_remaining()
	var before_n2: int = st.command_log.size()
	bridge.tick_step()
	var ok2: bool = true
	var msg2: String = ""
	if st.command_log.size() > before_n2:
		ok2 = bool(st.command_log[st.command_log.size() - 1].get("ok", true))
		msg2 = _last_sentence(st)
	print("   失敗令：tick %d → %d（+%d）｜請求量=%d｜消費點 ok=%s msg=%s" % [
		t2, st.world.current_tick, st.world.current_tick - t2, asked2, str(ok2), msg2])
	_check("★★★被拒絕的令【也】+1（＝「+1」本身不足以證明成功；這一行是母體地板的理由）",
		st.world.current_tick - t2 == 1)
	_check("★而它的 ok 欄是 false ⇒ 兩者在卷面上分得開", not ok2)
	_cell("_test_p1_one_press_one_tick")


# ══ P2：`unknown_command` 那一支【不推進】════════════════════════════════
# ★這是我在 HOW 內自己定的微決定（已寫 handback 給 systems 覆核）：
#   什麼都沒入列 ⇒ 不是「一道令」⇒ 打錯字不該走掉世界的時間。
# 負對照：把咽喉的條件從 `queued` 改成無條件 ⇒ 未知指令也推一顆 ⇒ 已於 feat/press-is-one-tick（2026-09-29 這一輪） 實測紅
func _test_p2_unknown_command_does_not_advance() -> void:
	print("\n── P2 未知指令不推進 ──")
	var tri: Array = _fresh()
	var st: WorldState = tri[0]
	var bridge: SimBridge = tri[2]
	var r: Dictionary = bridge.command_player("no_such_verb_xyz", {})
	print("   回傳 ok=%s code=%s queued=%s｜請求量=%d" % [
		str(r.get("ok", "?")), String(r.get("code", "")), str(r.get("queued", false)),
		bridge.ticks_remaining()])
	_check("母體地板：它真的被擋在入列之前（code=unknown_command）",
		String(r.get("code", "")) == "unknown_command")
	_check("★未知指令【沒有】請求推進（請求量 %d）" % bridge.ticks_remaining(),
		bridge.ticks_remaining() == 0)
	_check("★★世界沒有動（tick %d）" % st.world.current_tick, st.world.current_tick == 0)
	_cell("_test_p2_unknown_command_does_not_advance")


# ══ P3：自動推進中按令 ⇒ 不額外推進（spec §4 P4）═══════════════════════
# ★★★這一格守的是【例外】：Space／X 正在跑時按的令照舊入列，不把長程推進【踩成 1】。
#   ★母體地板：先斷言它真的在推進中（否則「沒有被踩掉」在一個沒有推進的世界裡恆綠）。
# 負對照：把咽喉的 `not is_advancing()` 判斷拿掉 ⇒ 長程請求被踩成 1（實測 1／期望 60） ⇒ 已於 feat/press-is-one-tick（2026-09-29 這一輪） 實測紅
func _test_p3_advancing_is_the_exception() -> void:
	print("\n── P3 推進中是例外 ──")
	var tri: Array = _fresh()
	var st: WorldState = tri[0]
	var bridge: SimBridge = tri[2]
	var pt: TeamData = st.teams.get(st.get_player_team_id())
	bridge.request_advance(WorldState.TICKS_PER_HOUR)
	_check("★母體地板：真的在推進中（請求量 %d）" % bridge.ticks_remaining(),
		bridge.is_advancing() and bridge.ticks_remaining() == WorldState.TICKS_PER_HOUR)
	var dst: Vector2i = pt.tile_pos + Vector2i(1, 0)
	var r: Dictionary = bridge.command_player("move_to", {"tile_q": dst.x, "tile_r": dst.y})
	print("   推進中入列：queued=%s｜請求量 %d（期望仍是 TICKS_PER_HOUR=%d）" % [
		str(r.get("queued", false)), bridge.ticks_remaining(), WorldState.TICKS_PER_HOUR])
	_check("推進中的令照舊入列", bool(r.get("queued", false)))
	_check("★★★長程請求【沒有被踩成 1】（實測 %d／期望 %d）" % [
		bridge.ticks_remaining(), WorldState.TICKS_PER_HOUR],
		bridge.ticks_remaining() == WorldState.TICKS_PER_HOUR)
	_cell("_test_p3_advancing_is_the_exception")


# ══ P4：一個咽喉涵蓋幾個呼叫點（母體，★含我對 spec 的訂正）═══════════════
# ★★★為什麼要有這一格：spec §1① 寫「36 個呼叫點 ⇒ 一個位置涵蓋 36 個」，
#   而實際【活著的】是 45 個（encounter_view 5 ＋ popup_layer 4 也是活 overlay，
#   由 `text_ui_main:156` 動態 new）。
#   ⇒ ★那個低估【不改變做法】（掛咽喉仍然對），但它會讓下一個人以為母體只有一個檔
#   ⇒ 所以把逐檔欄位印出來，讓數字自己講。
# ★★同時斷言【咽喉只有一處】：`sim_bridge.gd` 裡 `request_advance(1)` 只出現一次。
#   ⇒ 第二處出現＝有人又貼了一次，而那是「兩條推進路徑」那個舊病的復發形狀。
# 負對照：把 `popup_layer.gd` 的一個呼叫點換成 `pass` ⇒ 4 → 3 ⇒ 已於 feat/press-is-one-tick（2026-09-29 這一輪） 實測紅
func _test_p4_one_chokepoint_covers_all_callsites() -> void:
	print("\n── P4 咽喉母體 ──")
	var files: Dictionary = {
		"res://scripts/ui/text_ui_main.gd": SPEC_CALLSITES_TEXT_UI,
		"res://scripts/ui/encounter_view.gd": SPEC_CALLSITES_ENCOUNTER,
		"res://scripts/ui/popup_layer.gd": SPEC_CALLSITES_POPUP,
		"res://scripts/ui/main.gd": SPEC_CALLSITES_DEAD_MAIN,
	}
	var live_total: int = 0
	for path in files:
		var src: String = _code_only(FileAccess.get_file_as_string(path))
		var n: int = 0
		for l in src.split("\n"):
			if l.contains("command_player(") and not l.strip_edges().begins_with("func "):
				n += 1
		var want: int = int(files[path])
		# ★★★子字串誤中：`path.ends_with("main.gd")` 【也吃到 text_ui_main.gd】
		#   ⇒ 36 被當死樹排掉、活母體變成 9 ⇒ 抓到它的是下面那個與常數比的地板。
		#   ★修法＝比【檔名全等】不是比結尾（同 systems 今天 defer-gate 那個 `*scrip*` glob 的病）。
		var is_dead_tree: bool = path.get_file() == "main.gd"
		var tag: String = "死樹" if is_dead_tree else "活"
		print("   %-40s %s 呼叫點 %d（期望 %d）" % [path.get_file(), tag, n, want])
		_check("%s 的呼叫點數與常數相符（%d／%d）" % [path.get_file(), n, want], n == want)
		if not is_dead_tree:
			live_total += n
	print("   ★活的呼叫點合計 = %d（spec §1 只提了 text_ui_main 的 %d）" % [
		live_total, SPEC_CALLSITES_TEXT_UI])
	_check("★★★活母體合計與常數相符（%d／%d）" % [live_total, SPEC_LIVE_CALLSITES],
		live_total == SPEC_LIVE_CALLSITES)
	# ── 咽喉只有一處
	var sb: String = _code_only(FileAccess.get_file_as_string("res://scripts/ui/sim_bridge.gd"))
	var hooks: int = sb.count("request_advance(1)")
	print("   sim_bridge 裡 request_advance(1) 出現 %d 次" % hooks)
	_check("★咽喉只有一處（%d 次）—— 第二處＝有人又貼了一次" % hooks, hooks == 1)
	# ── 而 UI 端【不得】自己各貼一份
	var tu: String = _code_only(FileAccess.get_file_as_string("res://scripts/ui/text_ui_main.gd"))
	print("   ★邊界：本格數的是【呼叫點】不是【按鍵】—— 一個按鍵可能下多道令，")
	print("     而反過來 36 個呼叫點裡有幾個共用同一個鍵；要問「涵蓋率」時數的是這一欄。")
	_check("★★UI 端沒有自己貼一份 request_advance(1)",
		not tu.contains("request_advance(1)"))
	_cell("_test_p4_one_chokepoint_covers_all_callsites")


# ══ P5：濫按母體（★只印，不判 —— 「合理」是 WHAT）═════════════════════
# ★★★spec §5③ 逐字：「床印母體，而『20 次之後對方該怎樣』若卷面看起來不合理，
#   那是 WHAT 不是 HOW」⇒ 本格【沒有】對「合理」下任何斷言。
# ★它斷言的只有三件【機械】的事：①20 次真的都送出去了（母體非空）
#   ②世界沒有崩（tick 走得動、守恆欄位還在）③冷卻欄位的值印出來了。
# 負對照：★尚未點火（ABUSE_N 改 0 ⇒ 母體地板紅；本輪沒點，因為它擾動的是床自己的常數不是產品）
func _test_p5_abuse_population() -> void:
	print("\n── P5 濫按母體（20 次連發；只印不判）──")
	var tri: Array = _fresh()
	var st: WorldState = tri[0]
	var bridge: SimBridge = tri[2]
	var pt: TeamData = st.teams.get(st.get_player_team_id())
	# 找一支【同格】的 NPC 隊當靶（★不是憑空造：外交動作需要可見／同格）
	var target_id: int = -1
	for tid in st.teams:
		var t: TeamData = st.teams[tid]
		if int(tid) != pt.team_id and t.tile_pos == pt.tile_pos:
			target_id = int(tid)
			break
	if target_id == -1:
		# 同格沒有就搬一支過來（★佈置樣本，不走指令路徑）
		for tid in st.teams:
			if int(tid) != pt.team_id:
				st.teams[tid].tile_pos = pt.tile_pos
				target_id = int(tid)
				break
	print("   靶 = Team%d（與玩家同格 %s）" % [target_id, str(pt.tile_pos)])
	_check("母體地板 A：找得到靶", target_id != -1)
	_check("★母體地板 B：真的要按 %d 次（0 次的話下面全是恆綠）" % ABUSE_N, ABUSE_N > 0)
	var t_start: int = st.world.current_tick
	for action_id in ["demand_tribute", "propose_alliance", "recruit_anon"]:
		print("   ── %s ×%d ──" % [action_id, ABUSE_N])
		var oks: int = 0
		for i in range(ABUSE_N):
			bridge.command_player("execute_action", {"action_id": action_id,
				"target": {"kind": "team", "team_id": target_id, "member_id": -1,
					"tile_q": -1, "tile_r": -1}})
			bridge.tick_step()
			var ok: bool = false
			var msg: String = ""
			if not st.command_log.is_empty():
				ok = bool(st.command_log[st.command_log.size() - 1].get("ok", false))
				msg = _last_sentence(st)
			if ok: oks += 1
			# ★全印：第幾次、ok、handler 自己的話（★不分類 —— 由讀的人判合不合理）
			print("     #%02d ok=%-5s %s" % [i + 1, str(ok), msg])
		print("     小計 ok=%d／%d" % [oks, ABUSE_N])
		var cd: Dictionary = pt.diplomacy_reject_cooldown
		print("     ★冷卻欄位 diplomacy_reject_cooldown（玩家隊）= %s" % str(cd))
		var tcd: Dictionary = st.teams[target_id].diplomacy_reject_cooldown if st.teams.has(target_id) else {}
		print("     ★冷卻欄位 diplomacy_reject_cooldown（靶隊）= %s｜現在 tick=%d" % [
			str(tcd), st.world.current_tick])
	print("   ★★世界走了 %d tick（%d → %d）" % [
		st.world.current_tick - t_start, t_start, st.world.current_tick])
	_check("★★★世界沒有崩：tick 真的往前走了", st.world.current_tick > t_start)
	_check("玩家隊還在", st.teams.has(pt.team_id))
	print("   ★★★本格【不判】「20 次之後對方該怎樣算合理」—— 那是 WHAT（spec §5③）。")
	print("     ⇒ 上面三張表交 blueprint 讀；若看起來不合理，那是設計題不是本票的紅燈。")
	_cell("_test_p5_abuse_population")
