extends SceneTree
# @bed-kind: invariant
# ══ 故事結束 ≠ 世界停止（票 #2 刀 1）══════════════════════════════════════════════════
# spec：`docs/superpowers/specs/2026-09-24-game-over-is-a-story-end-not-world-physics-HOW.md` §5
#   意圖帳 #43：`game_over` ＝【UI 層的故事結束】、可續觀沙盒、**非世界物理**
#   意圖帳 #44：**世界的存在不綁玩家**
#
# 四格（★每一條「＝ 0」都配【同一個抽取器在另一個輸入上必須 > 0】）：
#   P1  造出 game_over（★由**真的寫入者** `EventSystem.handle_player_succession` 寫）⇒ 推 N tick
#       ⇒ `current_tick` 真的 +N（★母體地板：旗標真的為真）
#   P2  [產線側] `sim_runner.gd` 的 `game_over` **非註解**命中 ＝ 0（★註解裡允許：「為什麼不讀它」
#       正該寫在不讀它的那個位置）
#   P2′ [床側] `scripts/debug/*.gd` 裡**字串比較** `== "game_over"`／`!= "game_over"` 非註解命中 ＝ 0
#       ⇒ ★它是 §4③ 那份普查**不會過期**的形式：普查點名檔案，這一格數母體
#       ⇒ ★★只數【比較】：`"game_over": state.game_over` 那種 dict 鍵**不算**（它不是在等回傳值）
#   P7  等待繼承人時 `SimBridge.advance_ticks(n)` ⇒ `advanced == 0` 而且 `stall_reason` 說出原因
#       ⇒ ★★判準比對 `PlayerCommandApi.advance_ticks` **已有的那組鍵**（兩邊能各自改 ⇒ 是真的比較）

const N_TICKS: int = 24
var _errors: int = 0
var _cells_ran: Array = []
const EXPECTED_CELLS: Array = ["P1", "P2", "P2prime", "P7"]


func _initialize() -> void:
	print("=== story_end_not_physics：故事結束 ≠ 世界停止 ===")
	_p1_world_keeps_running()
	_p2_runner_does_not_read_flag()
	_p2prime_beds_do_not_wait_for_it()
	_p7_bridge_says_why_it_stalled()
	var missing: Array = []
	for c in EXPECTED_CELLS:
		if not _cells_ran.has(String(c)):
			missing.append(String(c))
	_check("★到場點名：%d／%d（缺：%s）" % [_cells_ran.size(), EXPECTED_CELLS.size(), str(missing)],
		missing.is_empty())
	print("\n=== story_end_not_physics DONE === errors: %d" % _errors)
	quit(1 if _errors > 0 else 0)


func _check(msg: String, cond: bool) -> void:
	if cond:
		print("  PASS: " + msg)
	else:
		_errors += 1
		push_error("[FAIL] " + msg)


func _mk_world() -> WorldState:
	seed(1337)
	var ws := WorldState.new()
	GameSetup.setup(ws, GameSetup.load_config("res://config/default.json"))
	return ws


# ══ P1 世界不停 ═══════════════════════════════════════════════════════════════════
func _p1_world_keeps_running() -> void:
	print("\n── P1 game_over 之後世界照跑 ──")
	var ws: WorldState = _mk_world()
	var ptid: int = ws.get_player_team_id()
	var pt: TeamData = ws.teams.get(ptid)
	_check("★母體地板：開場有玩家隊（Team%d）" % ptid, pt != null)
	if pt == null:
		_cells_ran.append("P1")
		return
	# ★照戰死那條的兩步讓玩家消失，再把其餘 named 清掉 ⇒ 交給**真的寫入者**判絕後
	#   （`on_leader_death` 在玩家已被抹掉時查不到玩家隊 ⇒ 呼叫端都直呼 `handle_player_succession`）
	var pid: int = ws.player_id
	for m in pt.named_members.duplicate():
		ws.remove_member(pt, int(m), false)
		if int(m) == pid:
			ws.persons.erase(pid)
	EventSystem.new().handle_player_succession(ws, pt)
	print("   game_over=%s｜原因「%s」" % [str(ws.game_over), ws.game_over_reason])
	_check("★★母體地板：旗標**由真的寫入者**設成真（否則這一格在一個沒死的世界上恆綠）",
		ws.game_over)
	var runner := SimRunner.new()
	var before: int = ws.world.current_tick
	var rs: Dictionary = {}
	for _i in range(N_TICKS):
		var r: String = runner.advance_tick(ws, Vector2i(-1, -1))
		rs[r] = int(rs.get(r, 0)) + 1
	var after: int = ws.world.current_tick
	print("   current_tick %d → %d（推 %d 次；回傳分佈 %s）" % [before, after, N_TICKS, str(rs)])
	_check("★★★★★P1：game_over 之後 `current_tick` 真的 +%d（%d）" % [N_TICKS, after - before],
		after - before == N_TICKS)
	_check("★P1：旗標推完之後**仍為真**（世界照跑 ≠ 故事復活）", ws.game_over)
	_cells_ran.append("P1")


# ══ 共用：一行的【程式碼部分】（剝掉 `#` 之後的註解；引號裡的 `#` 不算）══════════════════
static func _code_part(line: String) -> String:
	var in_q: String = ""
	var i: int = 0
	while i < line.length():
		var c: String = line[i]
		if in_q != "":
			if c == "\\":
				i += 2   # ★跳脫：連同下一個字元一起跳（`\"` 不結束字串）
				continue
			if c == in_q:
				in_q = ""
		elif c == "\"" or c == "'":
			in_q = c
		elif c == "#":
			return line.substr(0, i)
		i += 1
	return line


static func _count_flag_reads(text: String) -> Array:
	var out: Array = []
	var ls: PackedStringArray = text.split("\n")
	for i in range(ls.size()):
		if _code_part(ls[i]).contains("game_over"):
			out.append("%d: %s" % [i + 1, ls[i].strip_edges()])
	return out


# ══ P2 產線不讀它 ═════════════════════════════════════════════════════════════════
func _p2_runner_does_not_read_flag() -> void:
	print("\n── P2 sim_runner.gd 不讀 game_over（註解除外）──")
	var text: String = FileAccess.get_file_as_string("res://scripts/simulation/sim_runner.gd")
	var n_lines: int = text.split("\n").size()
	_check("★母體地板：真的讀到 sim_runner.gd（%d 行）" % n_lines, n_lines > 100)
	var hits: Array = _count_flag_reads(text)
	var in_comment: int = 0
	for l in text.split("\n"):
		if l.contains("game_over") and not _code_part(l).contains("game_over"):
			in_comment += 1
	print("   非註解命中 %d｜註解裡 %d（允許）%s" % [hits.size(), in_comment,
		("：" + str(hits)) if not hits.is_empty() else ""])
	_check("★★★★★P2：sim_runner.gd 的 `game_over` 非註解命中 ＝ 0（%d）" % hits.size(),
		hits.is_empty())
	# ★反向對照：同一個抽取器在合成輸入上 —— 程式碼裡的要算、註解裡的不算
	var probe: String = "\tif state.game_over:\n\t# game_over 是 UI 旗標\n\tvar s := \"#\" # game_over"
	var ph: Array = _count_flag_reads(probe)
	_check("★★【反向對照】合成三行（1 行程式碼／2 行只在註解）⇒ 抽取器必須回 1（%d）" % ph.size(),
		ph.size() == 1)
	_cells_ran.append("P2")


# ══ P2′ 床不等它 ═════════════════════════════════════════════════════════════════
static func _count_string_compares(text: String, re: RegEx) -> Array:
	var out: Array = []
	var ls: PackedStringArray = text.split("\n")
	for i in range(ls.size()):
		if re.search(_code_part(ls[i])) != null:
			out.append(i + 1)
	return out


func _p2prime_beds_do_not_wait_for_it() -> void:
	print("\n── P2′ scripts/debug/*.gd 不再拿 \"game_over\" 當回傳值比較 ──")
	var q: String = char(34)
	# ★regex 用拼的：這支床自己的原始碼裡不能出現它要抓的形狀（否則它抓到自己）
	var re := RegEx.new()
	re.compile("[=!]=\\s*" + q + "game" + "_over" + q + "|" + q + "game" + "_over" + q + "\\s*[=!]=")
	var dir := DirAccess.open("res://scripts/debug")
	var files: Array = []
	for f in dir.get_files():
		if String(f).ends_with(".gd"):
			files.append(String(f))
	_check("★母體地板：掃到的床檔數 %d（> 100）" % files.size(), files.size() > 100)
	var hits: Array = []
	for f in files:
		var text: String = FileAccess.get_file_as_string("res://scripts/debug/" + String(f))
		for ln in _count_string_compares(text, re):
			hits.append("%s:%d" % [f, ln])
	print("   命中 %d%s" % [hits.size(), ("：" + str(hits)) if not hits.is_empty() else ""])
	_check("★★★★★P2′：床裡字串比較 game_over 回傳值的非註解命中 ＝ 0（%d）" % hits.size(),
		hits.is_empty())
	# ★反向對照：比較要算／dict 鍵不算／註解不算
	var probe: String = "\tif r == " + q + "game" + "_over" + q + ":\n" \
		+ "\t\t" + q + "game" + "_over" + q + ": state.game_over,\n" \
		+ "\t# ~~if r == " + q + "game" + "_over" + q + "~~ 劃掉"
	var ph: Array = _count_string_compares(probe, re)
	_check("★★【反向對照】合成三行（比較／dict 鍵／註解）⇒ 抽取器必須只回第 1 行（%s）" % str(ph),
		ph == [1])
	_cells_ran.append("P2prime")


# ══ P7 推不動要說為什麼 ══════════════════════════════════════════════════════════
func _p7_bridge_says_why_it_stalled() -> void:
	print("\n── P7 等待繼承人時 SimBridge.advance_ticks 說出它沒推 ──")
	var ws: WorldState = _mk_world()
	var runner := SimRunner.new()
	var bridge := SimBridge.new(runner, ws)
	# ★對照組先跑：推得動的世界 ⇒ advanced == n、stall_reason 空
	var free_run: Dictionary = bridge.advance_ticks(3)
	print("   推得動：%s" % str(_no_events(free_run)))
	# ★事件會提前 break ⇒ 推得動那一支只要求 > 0（不要求 == 3）
	_check("★★【對照】推得動的世界 ⇒ advanced > 0 而 stall_reason 空（%d／「%s」）"
		% [int(free_run.get("advanced", -1)), String(free_run.get("stall_reason", "?"))],
		int(free_run.get("advanced", -1)) > 0 and String(free_run.get("stall_reason", "?")) == "")
	var ptid: int = ws.get_player_team_id()
	var pt: TeamData = ws.teams.get(ptid)
	ws.set_player_forced_event({"action": "choose_heir", "team_id": ptid,
		"candidates": pt.named_members.duplicate() if pt != null else []}, "bed_heir")
	_check("★★母體地板：真的處在等待繼承人（%s）" % String(ws.player_forced_event.get("action", "")),
		String(ws.player_forced_event.get("action", "")) == "choose_heir")
	var before: int = ws.world.current_tick
	var stuck: Dictionary = bridge.advance_ticks(5)
	print("   卡住：%s｜current_tick %d → %d" % [str(_no_events(stuck)), before, ws.world.current_tick])
	_check("★★★★★P7：回傳分得出【一 tick 都沒推】（advanced ＝ %d）"
		% int(stuck.get("advanced", -1)), int(stuck.get("advanced", -1)) == 0)
	_check("★★★★★P7：而且說出為什麼（stall_reason ＝「%s」）"
		% String(stuck.get("stall_reason", "")), String(stuck.get("stall_reason", "")) == "awaiting_heir")
	_check("★P7：first_stall_tick 有值（%d）" % int(stuck.get("first_stall_tick", -1)),
		int(stuck.get("first_stall_tick", -1)) != -1)
	# ★★★兩條推進路徑不准分岔：鍵集比對（`events` 是本路徑特有）
	var api: Dictionary = PlayerCommandApi.new().advance_ticks(ws, runner, 2)
	var api_keys: Array = (api.get("payload", {}) as Dictionary).keys()
	var br_keys: Array = stuck.keys()
	br_keys.erase("events")
	api_keys.sort()
	br_keys.sort()
	print("   PlayerCommandApi 鍵 ＝ %s｜SimBridge 鍵（去 events）＝ %s" % [str(api_keys), str(br_keys)])
	_check("★母體地板：PlayerCommandApi 那一側真的有鍵（%d）" % api_keys.size(), api_keys.size() >= 4)
	_check("★★★★P7：兩條推進路徑回同一組鍵", api_keys == br_keys)
	_check("★★P7：兩邊在同一個卡住的世界上給同一個原因（api「%s」）"
		% String((api.get("payload", {}) as Dictionary).get("stall_reason", "")),
		String((api.get("payload", {}) as Dictionary).get("stall_reason", "")) == String(stuck.get("stall_reason", "")))
	_cells_ran.append("P7")


static func _no_events(d: Dictionary) -> Dictionary:
	var o: Dictionary = d.duplicate()
	o["events"] = "%d 筆" % (d.get("events", []) as Array).size()
	return o
