extends SceneTree
# @bed-kind: acceptance
# slice: 按一下＝做一顆 tick（spec 2026-09-29 #8）＋ 濫按母體
#
# ★★★這支床要證明的那一句：玩家按下去的東西【同一幀就結算】——
#   在本票之前，每道令入列後要等玩家再做一件別的事（按 Space／X／移動）才生效，
#   ⇒ 用戶逐字：「玩家的介面就是按啥做啥」。
#
# ★★掛鉤位置是 systems 寫死的：`SimBridge.command_player()` 這一個咽喉，
#   不在 UI 的呼叫點上。★而本床的 P4 把【那個咽喉涵蓋幾個呼叫點】印成母體。
# ★★★母體 ＝【從主場景可達的 UI 檔】，而它是**掃出來的**不是我分類的。
#   ★這一欄訂正過【兩次】，而第二次錯的是我自己：
#     ·systems 的 spec 寫 36（只數了 text_ui_main 一個檔）
#     ·我回報 45（36＋encounter_view 5＋popup_layer 4）——★而 popup_layer **不是活的**：
#       它只被那棵死樹（Main 場景）實例化、`main.gd:13` 引用，
#       ★★這句刻意【不寫那個完整路徑字串】：`defer-open` 的 `dead-scene-tree-cleanup`
#         那一列用 `git grep "scenes/Main\.tscn"` 當解除條件 ⇒ 它分不出【引用】與【提及】，
#         而我第一版在註解裡寫了它 ⇒ 整支閘紅。缺陷已回報 owner（defers.tsv 是 systems 的）。
#       `text_ui_main` 一次都沒有碰它。
#     ·真值 ＝ **41**（text_ui_main 36 ＋ encounter_view 5）
#   ⇒ ★★我的錯法：拿「`text_ui_main:156` 動態 new」當活性判準，而那條我【只對
#     encounter_view 查過】，popup_layer 我寫「同上」**沒有實際查**
#     ⇒ 一張填滿的表不代表分類法對，只代表每列都找到了一個格子。
#   ⇒ ★★★所以本格不再吃我寫的分類：它從 `project.godot` 的 `run/main_scene` 出發做
#     可達性閉包，而斷言是【指名】不是【數數】（數數那次 77 就騙過一支閘）。
#
# ★誠實限：
#   1. 吸附（X／Space 停在整點／隔日）在 `text_ui_main._snap_to()` ⇒ 需要 UI 節點
#      ⇒ 那兩格在 `ui_flow_test`（P8 ＋ P21 兩向），不在這裡。
#   2. P5 濫按【只印母體不下判斷】：「20 次之後對方該怎樣算合理」是 WHAT
#      ⇒ 卷面交 blueprint 判（spec §5③ 逐字）。
#   3. ★那 9 個（encounter_view 5 ＋ popup_layer 4）的【新行為】不在本床：
#      P4 只數它們的存在。encounter_view 那 5 個的行為格在 `ui_flow_test`（P22），
#      而 popup_layer 那 4 個【沒有格也不該有】—— 它們不可達，按不到。

var _errors: int = 0
var _cells_ran: Array = []


# ★★★指名：從主場景可達的 UI 檔 —— 一支都不多不少。
#   ★每一支的【活著的理由】逐支獨立核過（file:line），而不是把掃描結果抄進來：
#     ·`text_ui_main.gd`      ＝ `TextUI.tscn` 的腳本（project.godot 的 run/main_scene）
#     ·`encounter_view.gd`    ＝ `text_ui_main.gd:156` 動態 `load()`
#     ·`sim_bridge.gd`        ＝ `class_name SimBridge`，text_ui_main 整支在用
#     ·`team_ui_helper.gd`    ＝ `TeamUiHelper` 在 text_ui_main 有 5 處非註解命中
#     ·`ui_pages.gd`          ＝ `UiPages` 在 text_ui_main 有 5 處非註解命中
#     ·`text_map_renderer.gd` ＝ `sim_bridge.gd:182` 呼 `TextMapRenderer.render()`
#       ★★它在 text_ui_main 裡【0 命中】—— 經第二層才到 ⇒ 這正是要做閉包不做單層的理由
#   ★★後四支的 `command_player` 呼叫點都是 0；`sim_bridge` 那 1 個是
#     `refresh_interaction_targets()` 的內部自呼（R² 核過 route 進咽喉、不是繞過）
#     ⇒ 玩家按得到的母體 ＝ 36 ＋ 5 ＝ 41。
#   ★★★【基準更新 2026-10-01】加入 `text_ui_layout.gd`／`text_ui_view.gd` ——
#     理由：版面 v2 把畫面收成一個合成 Label，`_render_screen()` 呼 `TextUiView.compose()`
#     （它再呼 `TextUiLayout`）⇒ 這兩支**從休眠 code 變成主場景可達**。
#     ★那不是誤報：這一格守的就是「活的 UI 面有沒有長大」⇒ 它做對了事，
#       而基準要跟著那個改動【原子】落地（不是先放基準等世界追上）。
#     ★★而它們的 `command_player` 呼叫點是 **0** ⇒ 三條呼叫點斷言一個都不動
#       （合計仍 41）—— ★**「活的」與「有呼叫點」是兩個不同的活**：
#       這兩支是被 `_render_screen` 餵進去的**資料流**，不是被按鍵呼叫的動作。
const SPEC_LIVE_UI_FILES: Array = ["encounter_view.gd", "sim_bridge.gd", "team_ui_helper.gd",
	"text_map_renderer.gd", "text_ui_layout.gd", "text_ui_main.gd", "text_ui_view.gd",
	"ui_model.gd",   # ★友善度 F6（2026-10-08）：區塊資料層，text_ui_main／text_ui_view 都讀它
	"ui_pages.gd"]
const SPEC_CALLSITES_BRIDGE_SELF: int = 1   # ★sim_bridge 內部自呼（不是玩家按得到的呼叫點）
const SPEC_CALLSITES_TEXT_UI: int = 36      # spec §1① 逐字那一個
const SPEC_CALLSITES_ENCOUNTER: int = 5     # ★text_ui_main:156 動態 load 的活 overlay
# ★玩家按得到的呼叫點 ＝ 活集合的呼叫點 − bridge 自呼那一個
const SPEC_LIVE_CALLSITES: int = SPEC_CALLSITES_TEXT_UI + SPEC_CALLSITES_ENCOUNTER
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


# ══ P4：咽喉涵蓋幾個呼叫點（母體＝【掃出來的可達集合】）═══════════════════
# ★★★本格的形狀是被兩次錯誤逼出來的（見檔頭那段）：數字訂正了兩次，
#   而兩次的錯法一樣 —— **用眼睛分類，然後把分類寫成常數**。
#   ⇒ 所以活性在這裡是【掃出來的】：從 `project.godot` 的 `run/main_scene` 做可達性閉包。
# ★★斷言是【指名】不是【數數】：集合雙向相等（多一支／少一支都紅）。
#   數數那種判準 2026-09-23 被「行數 77」騙過一次（兩邊數字相等而集合不同）。
# ★★★而死樹那一欄【必印】：它是「為什麼 45 是錯的」的唯一證據 ——
#   只看到 41 的人會以為那些呼叫點不存在，而它們存在、只是沒有人能按到。
# 負對照：在 `text_ui_main._snap_to` 裡 load 一支死樹 UI（popup_layer）⇒ 活集合多一支（少 0／多 1） ⇒ 已於 feat/press-is-one-tick（2026-09-30 這一輪） 實測紅
func _test_p4_one_chokepoint_covers_all_callsites() -> void:
	print("\n── P4 咽喉母體（可達性掃描）──")
	var proj: String = FileAccess.get_file_as_string("res://project.godot")
	var root: String = ""
	for l in proj.split("\n"):
		if l.strip_edges().begins_with("run/main_scene="):
			root = l.split("=")[1].strip_edges().replace('"', "")
	print("   主場景（project.godot run/main_scene）= %s" % root)
	_check("★母體地板：讀得到主場景（空的話整格不可判）", root != "")
	if root == "":
		_cell("_test_p4_one_chokepoint_covers_all_callsites")
		return
	var live_ui: Array = _reachable_ui(root)
	print("   ★從主場景可達的 UI 檔（掃出來的）= %s" % str(live_ui))
	var want: Array = SPEC_LIVE_UI_FILES.duplicate()
	want.sort()
	var missing: Array = []
	var extra: Array = []
	for w in want:
		if not live_ui.has(w): missing.append(w)
	for g in live_ui:
		if not want.has(g): extra.append(g)
	print("   指名比對：少了 %s｜多了 %s" % [str(missing), str(extra)])
	_check("★★★活的 UI 檔集合與【指名】相符（少 %d／多 %d）" % [missing.size(), extra.size()],
		missing.is_empty() and extra.is_empty())
	var live_total: int = 0
	for fname in live_ui:
		var n: int = _count_callsites("res://scripts/ui/" + String(fname))
		var note: String = ""
		# closure-exception: sim_bridge.gd —— ★這一行【比檔名】的 if 是可達性閉包的唯一例外，
		#   而它刻意留著（systems 裁 2026-09-30）：機械化它要靠【呼叫者身分】，
		#   ★★而「呼叫者身分」正是今天錯三次的那一維 ⇒ 為一個成員建同族的新判準，期望值是負的。
		#   ★★★這個 `closure-exception:` 字面是 defers.tsv 那一列的【可 grep 錨】：
		#     它讓那條 defer 有東西可以錨，而不是錨在一句散文上。
		if String(fname) == "sim_bridge.gd":
			# ★咽喉自己那一個不算「玩家按得到的呼叫點」：它是 refresh_interaction_targets
			#   的內部自呼。★★它仍然要被【列在活集合裡】—— 遺漏它就是上一版的盲點。
			note = "（★咽喉自呼，不計入玩家按得到的母體）"
		else:
			live_total += n
		print("   活 %-22s 呼叫點 %d %s" % [String(fname), n, note])
	print("   ★活的呼叫點合計 = %d（spec §1 原本寫 36；我回報過 45，而 45 是錯的）" % live_total)
	_check("★★活母體合計與常數相符（%d／%d）" % [live_total, SPEC_LIVE_CALLSITES],
		live_total == SPEC_LIVE_CALLSITES)
	_check("text_ui_main 的呼叫點數（%d／%d）" % [
		_count_callsites("res://scripts/ui/text_ui_main.gd"), SPEC_CALLSITES_TEXT_UI],
		_count_callsites("res://scripts/ui/text_ui_main.gd") == SPEC_CALLSITES_TEXT_UI)
	_check("encounter_view 的呼叫點數（%d／%d）" % [
		_count_callsites("res://scripts/ui/encounter_view.gd"), SPEC_CALLSITES_ENCOUNTER],
		_count_callsites("res://scripts/ui/encounter_view.gd") == SPEC_CALLSITES_ENCOUNTER)
	print("   ── 不在可達閉包裡（死樹）而仍有呼叫點的 UI 檔 ──")
	print("     ★判準含【路徑引用】與【class_name 全域】兩輪 —— 少了第二輪的話")
	print("       `sim_bridge.gd` 會被誤判成死樹（第一版就是，而它顯然活著）。")
	var dead_total: int = 0
	var da := DirAccess.open("res://scripts/ui")
	if da != null:
		da.list_dir_begin()
		var nm: String = da.get_next()
		while nm != "":
			if nm.ends_with(".gd") and not live_ui.has(nm):
				var dn: int = _count_callsites("res://scripts/ui/" + nm)
				if dn > 0:
					dead_total += dn
					print("     %-22s 呼叫點 %d" % [nm, dn])
			nm = da.get_next()
		da.list_dir_end()
	print("     死樹呼叫點合計 = %d ⇒ ★這一欄就是「為什麼 45 是錯的」的證據" % dead_total)
	_check("★母體地板：死樹那一欄真的非空（空的話它證明不了任何事）", dead_total > 0)
	var sb: String = _code_only(FileAccess.get_file_as_string("res://scripts/ui/sim_bridge.gd"))
	var hooks: int = sb.count("request_advance(1)")
	print("   sim_bridge 裡 request_advance(1) 出現 %d 次" % hooks)
	_check("★咽喉只有一處（%d 次）—— 第二處＝有人又貼了一次" % hooks, hooks == 1)
	var tu: String = _code_only(FileAccess.get_file_as_string("res://scripts/ui/text_ui_main.gd"))
	_check("★★UI 端沒有自己貼一份 request_advance(1)", not tu.contains("request_advance(1)"))
	print("   ★邊界：本格數的是【呼叫點】不是【按鍵】—— 一個按鍵可能下多道令，")
	print("     而反過來多個呼叫點可能共用同一個鍵；問「涵蓋率」時數的是這一欄。")
	_cell("_test_p4_one_chokepoint_covers_all_callsites")

# 從一個場景／腳本出發的 res:// 可達性閉包 ⇒ 回傳可達的 scripts/ui/*.gd 檔名（排序）。
# ★.gd 先剝整行註解（否則註解裡提到的路徑會被當成引用）；.tscn 不剝（它沒有 # 註解語法）。
func _reachable_ui(root: String) -> Array:
	var seen: Array = []
	var queue: Array = [root]
	while not queue.is_empty():
		var cur: String = String(queue.pop_front())
		if seen.has(cur):
			continue
		seen.append(cur)
		var src: String = FileAccess.get_file_as_string(cur)
		if src == "":
			continue
		var body: String = src if cur.ends_with(".tscn") else _code_only(src)
		for line in body.split("\n"):
			var a: int = line.find("res://")
			while a != -1:
				var rest: String = line.substr(a)
				var bg: int = rest.find(".gd")
				var bt: int = rest.find(".tscn")
				var cut: int = -1
				if bg != -1 and (bt == -1 or bg < bt): cut = bg + 3
				elif bt != -1: cut = bt + 5
				if cut == -1:
					break
				var path: String = rest.substr(0, cut)
				if not seen.has(path) and not queue.has(path):
					queue.append(path)
				a = line.find("res://", a + cut)
	# ★★★第二輪：`class_name` 全域 —— 它們【沒有任何 res:// 路徑】就能被抵達。
	#   ★這個盲點是卷面自己抓到的：第一版把 `sim_bridge.gd` 印進死樹欄，
	#     而它顯然活著（`text_ui_main` 整支都在用 `SimBridge`）——
	#     它只是經 `class_name SimBridge` 進來的，不經路徑。
	#   ⇒ ★★所以「掃 res:// 就等於掃可達性」在 GDScript 裡【不成立】，
	#     而不補這一輪的話，本格的綠會【建立在掃描器的盲目上】：
	#     一支只經 class_name 被用到的新 UI 檔會被判成死樹而沒有人知道。
	var grew: bool = true
	while grew:
		grew = false
		# ★★★剝註解：第一版用原始文字 ⇒ `sim_bridge.gd` 一行**註解**裡提到
		#   `ObserverBridge` ⇒ `observer_bridge.gd` 被算成可達。
		#   ⇒ 這與 P9／P2 那兩格同一條教訓：**判準要讀程式碼，不要讀我們談論它的字。**
		var reached_text: String = ""
		for p2 in seen:
			if p2.ends_with(".gd"):
				reached_text += _code_only(FileAccess.get_file_as_string(p2))
			elif p2.ends_with(".tscn"):
				reached_text += FileAccess.get_file_as_string(p2)
		var da2 := DirAccess.open("res://scripts/ui")
		if da2 != null:
			da2.list_dir_begin()
			var nm2: String = da2.get_next()
			while nm2 != "":
				var path2: String = "res://scripts/ui/" + nm2
				if nm2.ends_with(".gd") and not seen.has(path2):
					var cn: String = _class_name_of(path2)
					if cn != "" and reached_text.contains(cn):
						seen.append(path2)
						grew = true
				nm2 = da2.get_next()
			da2.list_dir_end()
	var out: Array = []
	for p in seen:
		if p.begins_with("res://scripts/ui/") and p.ends_with(".gd"):
			out.append(String(p).get_file())
	out.sort()
	return out

# 這支 .gd 宣告的 class_name（沒有就回空字串）。★只看【非註解】的宣告行。
func _class_name_of(path: String) -> String:
	for l in _code_only(FileAccess.get_file_as_string(path)).split("
"):
		var t: String = l.strip_edges()
		if t.begins_with("class_name "):
			return t.substr(11).strip_edges()
	return ""

func _count_callsites(path: String) -> int:
	var src: String = _code_only(FileAccess.get_file_as_string(path))
	var n: int = 0
	for l in src.split("\n"):
		if l.contains("command_player(") and not l.strip_edges().begins_with("func "):
			n += 1
	return n


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
