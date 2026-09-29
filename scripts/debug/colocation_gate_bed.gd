extends SceneTree
# @bed-kind: acceptance
# slice: 同格檢查屬於 handler，不屬於畫面（spec 2026-09-30）
#
# ★★★這支床要證明的那一句：那條不變量原本只有【兩處】執法 ——
#   NPC 側 `diplomatic_ai_system.gd:138`、玩家【畫面】側 `refresh_colocation_targets`
#   ⇒ 而第三條管道（直呼 API／agent）**一處都沒有**。
#   ★而那不是「畫面守得不夠嚴」，是【守在錯的層】：畫面是一條管道，
#     而不變量是世界的性質 ⇒ 守畫面等於只對我們自己走的那條路執法，
#     ★★而缺陷從來躲在我們不走的管道。
#
# ★★判準錨在【動作的契約】不是【傳進來的數字】（systems 訂正）：
#   我第一版寫「`teams.get(target_id)` 非 null 就要同格」⇒ `execute_action(state, 5, "hunt")`
#   會把 hunt 誤判成「對方不在你的格上」⇒ ★誤判方向是【擋掉合法動作】，
#   症狀是「某些自家隊動作偶爾莫名被拒」—— 比洞更難查。
#   ⇒ P4 就是那個反例的守衛。
#
# ★誠實限：
#   1. 本床走 `PlayerCommandSystem` 直呼（＝第三條管道本身），不經 UI。
#      畫面側那一處【不拆】（它的工作是「選單要列誰」不是執法）⇒ 兩層一致性是 P3。
#   2. `execute_action_with_target`（吃 Dictionary 的那條）不在本閘的爆炸半徑內
#      —— 它的 target 是 member 不是 team（systems 核過）⇒ 本床不驗它。

var _errors: int = 0
var _cells_ran: Array = []

# ★spec §3 的母體地板：需要同格的動詞有幾個／例外有幾個，相加要等於【團體目標動詞總數】。
#   ★★而這三個數【不是我手抄的】：P2 從 `get_available_actions` 的 append 字面機械導出，
#     再與 `TEAM_TARGET_ACTIONS` 做集合比對。這裡的常數只是「spec 說幾個」那一半。
const SPEC_TEAM_TARGET_TOTAL: int = 11    # ignore attack trade propose_alliance demand_tribute
                                          # extort recruit recruit_anon invite_settle
                                          # gather_intel beg
const SPEC_EARLY_RETURN_EXEMPT: Array = ["ignore"]   # ★在 execute_action 更上面就 return，走不到閘
# ★動工時量到的現況：11 個裡有幾個【自己】本來就查同格（本閘之前）
const MEASURED_SELF_CHECKING: Array = ["invite_settle", "beg"]

const EXPECTED_CELLS: Array = [
	"_test_p1_remote_is_refused_with_human_words",
	"_test_p2_verb_set_is_cross_checked",
	"_test_p3_menu_and_handler_do_not_contradict",
	"_test_p4_self_actions_are_not_blocked_by_a_stray_target_id",
	"_test_p5_colocated_behaviour_unchanged",
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
	seed(20260930)
	var st := WorldState.new()
	GameSetup.setup(st, GameSetup.load_config("res://config/warring_states.json"))
	return [st, PlayerCommandSystem.new()]

# 只看程式碼（剝整行註解）★另剝行尾註解 —— 理由見 `_strip_trailing_comment` 的檔頭
func _code_only(src: String) -> String:
	var out: String = ""
	for l in src.split("\n"):
		if l.strip_edges().begins_with("#"):
			continue
		out += l + "\n"
	return out

# 剝行尾註解。★`#` 只在【引號外】才算註解起點（引號計數奇偶），否則字串裡的 `#` 會切斷該行。
# ★★★這一支取代的是【兩處已經被咬過的地方】（systems 要求寫明，否則下一個人寫第三個）：
#   ·`ui_flow_test` 的 P9：檔頭早就寫著「行尾註解仍然騙得過它」——而那個洞留在原地
#   ·`forced_event_panel_bed` 的 P9（B 集合抽取）：`"tribute", "demand_tribute":   # …`
#     行尾有註解 ⇒ `ends_with(":")` 不成立 ⇒ B 少一個 ⇒ 差集多一個（母體地板 B2 抓到）
#   ⇒ ★【寫下來的已知洞不會自己修好】：登記只是把它從「會咬人」改成
#     「會咬人而且我們知道」，數量一個都沒少 —— 而「知道」在下一個人身上不成立。
func _strip_trailing_comment(line: String) -> String:
	var q: int = 0
	for i in range(line.length()):
		var ch: String = line[i]
		if ch == "\"":
			q += 1
		elif ch == "#" and q % 2 == 0:
			return line.substr(0, i)
	return line

# 是不是識別字形狀（小寫字母與底線）。★用它過濾 `split("\"")` 吐出來的分隔符碎片。
func _is_identifier(v: String) -> bool:
	if v == "":
		return false
	for i in range(v.length()):
		var c: String = v[i]
		if not ((c >= "a" and c <= "z") or c == "_"):
			return false
	return true

# 把一支別隊搬到（或搬離）玩家格上。★佈置樣本，不走指令路徑。
func _place(st: WorldState, tid: int, same_tile: bool) -> TeamData:
	var pt: TeamData = st.teams.get(st.get_player_team_id())
	var t: TeamData = st.teams.get(tid)
	if t == null:
		return null
	t.tile_pos = pt.tile_pos if same_tile else (pt.tile_pos + Vector2i(3, 2))
	return t

func _other_team_id(st: WorldState) -> int:
	var ptid: int = st.get_player_team_id()
	for tid in st.teams:
		var t: TeamData = st.teams[tid]
		if int(tid) != ptid and t.beast_kind == "" and t.parent_team_id == -1:
			return int(tid)
	return -1


func _initialize() -> void:
	print("=== 同格檢查屬於 handler（spec 2026-09-30）===")
	_test_p1_remote_is_refused_with_human_words()
	_test_p2_verb_set_is_cross_checked()
	_test_p3_menu_and_handler_do_not_contradict()
	_test_p4_self_actions_are_not_blocked_by_a_stray_target_id()
	_test_p5_colocated_behaviour_unchanged()
	var miss: Array = []
	for c in EXPECTED_CELLS:
		if not _cells_ran.has(c): miss.append(c)
	if not miss.is_empty():
		_errors += 1
		push_error("[FAIL] 到場點名少了：%s" % str(miss))
	print("=== colocation_gate DONE === errors: %d｜到場點名 %d／%d" % [
		_errors, _cells_ran.size(), EXPECTED_CELLS.size()])
	quit(1 if _errors > 0 else 0)


# ══ P1：直呼 API 對【不同格】的隊索貢 ⇒ ok=false 且訊息是人話 ════════════
# ★母體地板兩道：①目標真的存在且真的【不同格】②對方真的有東西可以被拿走
#   —— 否則「coin 沒少」會在一個【本來就沒有 coin】的世界裡恆綠。
# ★★而本格【逐一指名】那 8 個原本零檢查的動詞（spec §3 要求），不是只驗一個。
# 負對照：把 `_colocation_gate` 的呼叫拿掉 ⇒ ★★★實測【7 個動詞在隔空成立】（＝這個洞原本的大小） ⇒ 已於 feat/colocation-in-handler（2026-09-30 這一輪） 實測紅
func _test_p1_remote_is_refused_with_human_words() -> void:
	print("\n── P1 隔空 ⇒ 人話拒絕 ──")
	var pair: Array = _fresh()
	var st: WorldState = pair[0]
	var cmd: PlayerCommandSystem = pair[1]
	var tid: int = _other_team_id(st)
	_check("母體地板 A：找得到一支真的別隊（tid=%d）" % tid, tid != -1)
	if tid == -1:
		_cell("_test_p1_remote_is_refused_with_human_words")
		return
	var tgt: TeamData = _place(st, tid, false)
	var pt: TeamData = st.teams.get(st.get_player_team_id())
	print("   玩家 @%s／目標 Team%d @%s" % [str(pt.tile_pos), tid, str(tgt.tile_pos)])
	_check("★母體地板 B：真的不同格（同格的話整格恆綠）", pt.tile_pos != tgt.tile_pos)
	# ★★★`population` 是【計算屬性】（getter-only）⇒ 直接賦值是【靜默 no-op】：
	#   我第一版寫 `pt.population = maxi(pt.population, 1)` ——不報錯、也不生效。
	#   ★抓到它的是 `computed-prop` 那支閘（直寫站 baseline 1 → 3）
	#     ⇒ 而那支閘的存在理由逐字寫著「拿掉 setter 不會變 parse error ——
	#       引擎不給這個保護，所以靜態閘是唯一的預防線」。
	#   ⇒ ★★這一行本來就不需要：玩家隊的人口由 fixture 給，本格不靠它。
	tgt.resources["coin"] = 200.0
	tgt.resources["food"] = 200.0
	_check("★母體地板 C：對方真的有東西可被拿走（coin %.0f）" % float(tgt.resources["coin"]),
		float(tgt.resources.get("coin", 0)) > 0.0)
	# ★★逐一指名：那 11 個團體目標動詞，隔空一個都不准成立（`ignore` 例外，見常數檔頭）
	var before_coin: float = float(tgt.resources.get("coin", 0))
	var before_food: float = float(tgt.resources.get("food", 0))
	var bad: Array = []
	for act in PlayerCommandSystem.TEAM_TARGET_ACTIONS:
		var a: String = String(act)
		if SPEC_EARLY_RETURN_EXEMPT.has(a):
			print("   %-18s（early-return 例外：在閘之前就 return，見常數檔頭）" % a)
			continue
		var r: Dictionary = cmd.execute_action(st, tid, a)
		var ok: bool = bool(r.get("ok", false))
		var msg: String = String(r.get("msg", r.get("message", "")))
		print("   %-18s ok=%-5s msg=%s" % [a, str(ok), msg])
		if ok:
			bad.append(a)
	if not bad.is_empty():
		print("   ★隔空竟然成立的動詞：%s" % str(bad))
	_check("★★★隔空時那些動詞【一個都沒有成立】（%d 個成立）" % bad.size(), bad.is_empty())
	_check("★對方的 coin 沒有被拿走（%.1f → %.1f）" % [before_coin, float(tgt.resources.get("coin", 0))],
		is_equal_approx(float(tgt.resources.get("coin", 0)), before_coin))
	_check("★對方的 food 沒有被拿走（%.1f → %.1f）" % [before_food, float(tgt.resources.get("food", 0))],
		is_equal_approx(float(tgt.resources.get("food", 0)), before_food))
	_check("★★訊息是人話（含「格」字，不是錯碼）—— 沿用 `_action_beg` 的措辭形狀",
		String(cmd.execute_action(st, tid, "demand_tribute").get("msg", "")).contains("格"))
	_cell("_test_p1_remote_is_refused_with_human_words")


# ══ P2：動詞集合的【異源比對】═════════════════════════════════════════════
# ★★★閘讀的是 `TEAM_TARGET_ACTIONS`，而語意的單一來源是 `get_available_actions`
#   ⇒ 這一格斷言兩者【集合相等】：有人往那支函式加一個新團體動詞而忘了常數 ⇒ 紅。
# ★★而它是真比較不是一句話講兩次：兩邊能各自獨立改變（一邊是常數、一邊是函式體的 append）。
# ★母體地板：抽出來的 append 集合非空，且與 spec 的總數相符（抽取壞了會回空集合）。
# 負對照：從 `get_available_actions` 拿掉一個 append（gather_intel）⇒ 集合差一個 ⇒ 已於 feat/colocation-in-handler（2026-09-30 這一輪） 實測紅
func _test_p2_verb_set_is_cross_checked() -> void:
	print("\n── P2 動詞集合異源比對 ──")
	var src: String = FileAccess.get_file_as_string(
		"res://scripts/simulation/player_command_system.gd")
	var at: int = src.find("func get_available_actions")
	_check("母體地板 A：找得到 `get_available_actions`", at != -1)
	var body: String = src.substr(at, 1800) if at != -1 else ""
	var from_func: Array = []
	for l in _code_only(body).split("\n"):
		var t: String = _strip_trailing_comment(l).strip_edges()
		if t.begins_with("func ") and not t.begins_with("func get_available_actions"):
			break
		# `var actions: Array[String] = ["ignore", "attack"]` 與 `actions.append("x")` 兩種形狀
		if t.contains("actions.append(\"") or t.contains("actions: Array[String] = ["):
			for tok in t.split("\""):
				var v: String = String(tok).strip_edges()
				# ★★★只收【識別字形狀】的 token：`split("\"")` 會把引號之間的東西也吐出來
				#   （`, `／`)`／`]`）⇒ 第一版把 `")" "," "]"` 算進集合 ⇒ 14 而不是 11。
				#   ★抓到它的是母體地板 C（導出數要與 spec 總數相符）——
				#     而【集合相等】那一條當然也紅了，但它說不出「多的是什麼」。
				#   ⇒ ★★這一族：分隔符切出來的碎片長得跟資料一樣。
				if _is_identifier(v) and not from_func.has(v):
					from_func.append(v)
	from_func.sort()
	var from_const: Array = PlayerCommandSystem.TEAM_TARGET_ACTIONS.duplicate()
	from_const.sort()
	print("   函式體導出 = %s" % str(from_func))
	print("   常數       = %s" % str(from_const))
	_check("★母體地板 B：函式體導出非空（抽取壞了會回空集合）", not from_func.is_empty())
	_check("★★母體地板 C：導出數與 spec 的總數相符（%d／%d）" % [
		from_func.size(), SPEC_TEAM_TARGET_TOTAL], from_func.size() == SPEC_TEAM_TARGET_TOTAL)
	_check("★★★兩邊集合相等（閘讀的常數 ≡ 語意的單一來源）", from_func == from_const)
	# ★spec §3 的那條加法：需同格的 ＋ 例外的 ＝ 總數
	var exempt: int = SPEC_EARLY_RETURN_EXEMPT.size()
	print("   需同格 %d ＋ early-return 例外 %d ＝ %d（總數 %d）" % [
		from_const.size() - exempt, exempt, from_const.size(), SPEC_TEAM_TARGET_TOTAL])
	_check("★spec §3 的加法成立（否則分類法漏了一格）",
		(from_const.size() - exempt) + exempt == SPEC_TEAM_TARGET_TOTAL)
	# ★★動工時量到的現況：哪幾個【自己】本來就查同格（本閘之前）
	print("   ★動工時現況：11 個裡只有 %s 自己查同格 ⇒ 其餘 %d 個【零檢查】"
		% [str(MEASURED_SELF_CHECKING), from_const.size() - exempt - MEASURED_SELF_CHECKING.size()])
	for sc in MEASURED_SELF_CHECKING:
		var fn_at: int = src.find("func _action_" + String(sc))
		var fn_body: String = src.substr(fn_at, 900) if fn_at != -1 else ""
		_check("`%s` 自己那處檢查還在（拆掉它會讓措辭變成本閘的話）" % String(sc),
			fn_body.contains("tile_pos"))
	_cell("_test_p2_verb_set_is_cross_checked")


# ══ P3：畫面與 handler 不得矛盾（spec §3 P3）═══════════════════════════════
# ★★★兩邊是【異源】：一邊是 `refresh_colocation_targets` 的過濾，一邊是 handler 的閘
#   ⇒ 它們可以各自改而不影響對方 ⇒ 這是真比較。
# ★而矛盾的症狀比沒有選項更壞：玩家看到一個【按不動】的選項。
# ★母體地板：畫面真的列出了至少一個 target（列 0 個的話這一格恆綠）。
# 負對照：把畫面側的同格過濾拿掉 ⇒ ★實測【47 個被閘擋掉】＝47 個按不動的選項 ⇒ 已於 feat/colocation-in-handler（2026-09-30 這一輪） 實測紅
func _test_p3_menu_and_handler_do_not_contradict() -> void:
	print("\n── P3 畫面與 handler 不矛盾 ──")
	var pair: Array = _fresh()
	var st: WorldState = pair[0]
	var cmd: PlayerCommandSystem = pair[1]
	var near_id: int = _other_team_id(st)
	if near_id == -1:
		_cell("_test_p3_menu_and_handler_do_not_contradict")
		return
	_place(st, near_id, true)     # 同格一支
	# 再擺一支遠的（★它【不該】出現在選單裡）
	var far_id: int = -1
	for tid in st.teams:
		var t: TeamData = st.teams[tid]
		if int(tid) != st.get_player_team_id() and int(tid) != near_id \
				and t.beast_kind == "" and t.parent_team_id == -1:
			far_id = int(tid)
			break
	if far_id != -1:
		_place(st, far_id, false)
	cmd.refresh_colocation_targets(st)
	var listed: Array = st.player_pending_targets.duplicate()
	print("   畫面列出的 target = %s（同格擺了 Team%d／遠的擺了 Team%d）" % [
		str(listed), near_id, far_id])
	_check("★母體地板：畫面真的列出至少一個（列 0 個的話恆綠）", not listed.is_empty())
	_check("★同格那支在清單裡", listed.has(near_id))
	if far_id != -1:
		_check("★★遠的那支【不在】清單裡", not listed.has(far_id))
	# ★★★每一個列出來的 target 送進 handler 都必須過閘
	var blocked: Array = []
	for t2 in listed:
		var r: Dictionary = cmd.execute_action(st, int(t2), "demand_tribute")
		var msg: String = String(r.get("msg", ""))
		if msg.contains("不在你的格上"):
			blocked.append(int(t2))
	if not blocked.is_empty():
		print("   ★畫面列了卻被閘擋掉的：%s ⇒ 那是【按不動的選項】" % str(blocked))
	_check("★★★畫面列出的每一個 target 都過得了閘（%d 個被擋）" % blocked.size(),
		blocked.is_empty())
	# ★★★本格【只驗單向】：「畫面列出的都過得了閘」。
	#   反向（過得了閘的都必須被畫面列出）**刻意不加**，而理由是它需要先定一個 WHAT：
	#   ★**畫面該不該列交戰中的隊**（`refresh_colocation_targets` 目前用
	#     `other.combat_target != -1` 把它們濾掉）⇒ 反向會把那個【故意不列】算成矛盾。
	#   ⇒ systems 2026-09-30 裁：不加，而把這句寫在這裡 ——
	#     ★★讓這個空白【有主詞、有下一步】，而不是一個沒人知道存在的盲區
	#     （他會把那個 WHAT 問題帶給藍圖）。
	print("   ★邊界：本格只驗單向。反向（過得了閘的都必須被列出）需先定 WHAT：")
	print("     【畫面該不該列交戰中的隊】—— 目前 `combat_target != -1` 被濾掉，")
	print("     而反向會把那個故意不列算成矛盾 ⇒ 已呈報藍圖，不在本票。")
	_cell("_test_p3_menu_and_handler_do_not_contradict")


# ══ P4：自家隊動作【不得】因為一個亂傳的 target_id 被擋 ════════════════════
# ★★★這一格守的是 systems 訂正我的那個洞：判準錨在【動作的契約】不是【引數的值】。
#   我第一版寫「`teams.get(target_id)` 非 null 就要同格」
#   ⇒ `execute_action(state, <一支遠的別隊 id>, "hunt")` 會把 hunt 誤判成隔空
#   ⇒ ★誤判方向是【擋掉合法動作】，症狀是「某些自家隊動作偶爾莫名被拒」—— 比洞更難查。
# ★母體地板：那個 target_id 真的對應一支【存在且不同格】的隊（否則這一格證不了東西）。
# 負對照：把閘的第一個條件（`TEAM_TARGET_ACTIONS.has(action)`）拿掉 ⇒ hunt 被擋（★＝我第一版那個洞：判準錨在引數的值） ⇒ 已於 feat/colocation-in-handler（2026-09-30 這一輪） 實測紅
func _test_p4_self_actions_are_not_blocked_by_a_stray_target_id() -> void:
	print("\n── P4 自家隊動作不被亂傳的 target 擋掉 ──")
	var pair: Array = _fresh()
	var st: WorldState = pair[0]
	var cmd: PlayerCommandSystem = pair[1]
	var far_id: int = _other_team_id(st)
	if far_id == -1:
		_cell("_test_p4_self_actions_are_not_blocked_by_a_stray_target_id")
		return
	var tgt: TeamData = _place(st, far_id, false)
	var pt: TeamData = st.teams.get(st.get_player_team_id())
	_check("★母體地板：那個 id 真的是一支存在且不同格的隊（Team%d）" % far_id,
		tgt != null and pt.tile_pos != tgt.tile_pos)
	# 讓 hunt 有意義（同格 tile 上放獵物）—— ★但這一格關心的是【有沒有被閘擋】，不是成功
	var key: int = pt.tile_pos.x * 1000 + pt.tile_pos.y
	var tile: HexTileData = st.world.tiles.get(key)
	if tile != null:
		tile.resources["wild_game"] = 10
	for act in ["hunt", "train", "camp", "establish_faction"]:
		var r: Dictionary = cmd.execute_action(st, far_id, String(act))
		var msg: String = String(r.get("msg", r.get("message", "")))
		print("   %-18s（帶一個遠隊 id）ok=%-5s msg=%s" % [String(act), str(r.get("ok", "?")), msg])
		_check("★★★`%s` 沒有被同格閘擋掉（訊息不含「不在你的格上」）" % String(act),
			not msg.contains("不在你的格上"))
	_cell("_test_p4_self_actions_are_not_blocked_by_a_stray_target_id")


# ══ P5：同格時行為完全不變（spec §3 P2「我沒把功能門死」）═══════════════════
# ★母體地板：先斷言真的同格，並印出索貢前後的 coin —— 否則「行為不變」可以靠
#   「什麼都沒發生」滿足。
# 負對照：把閘改成【無條件擋】⇒ 同格索貢也被拒（＝把功能門死） ⇒ 已於 feat/colocation-in-handler（2026-09-30 這一輪） 實測紅
func _test_p5_colocated_behaviour_unchanged() -> void:
	print("\n── P5 同格時行為不變 ──")
	var pair: Array = _fresh()
	var st: WorldState = pair[0]
	var cmd: PlayerCommandSystem = pair[1]
	var tid: int = _other_team_id(st)
	if tid == -1:
		_cell("_test_p5_colocated_behaviour_unchanged")
		return
	var tgt: TeamData = _place(st, tid, true)
	var pt: TeamData = st.teams.get(st.get_player_team_id())
	_check("★母體地板 A：真的同格", pt.tile_pos == tgt.tile_pos)
	tgt.resources["coin"] = 300.0
	# ★索貢的前提是【玩家人口 > 對方 ×1.5】，而 `population` 是計算屬性不能直寫
	#   ⇒ 走合法路徑：把【對方】的匿名人口搬掉，而不是假裝把自己變大。
	#   ★★我第一版寫 `pt.population = …` ⇒ 靜默 no-op ⇒ 這一格當時是靠
	#     【fixture 剛好滿足前提】過的，而那是運氣不是佈置（`computed-prop` 閘抓到）。
	while tgt.population > 1 and float(pt.population) <= float(tgt.population) * 1.5:
		var moved: int = AnonTierSystem.remove_anon(tgt, AnonCohort.TIER_PLEB, 1)
		if moved <= 0:
			break
	print("   佈置：玩家 pop=%d／對方 pop=%d（索貢前提：玩家 > 對方 ×1.5 ＝ %s）" % [
		pt.population, tgt.population,
		str(float(pt.population) > float(tgt.population) * 1.5)])
	_check("★母體地板 B：索貢的前提真的成立（不成立的話 ok=false 不代表閘擋了它）",
		float(pt.population) > float(tgt.population) * 1.5)
	var before: float = float(tgt.resources.get("coin", 0))
	var r: Dictionary = cmd.execute_action(st, tid, "demand_tribute")
	print("   同格索貢：ok=%s msg=%s｜對方 coin %.1f → %.1f" % [
		str(r.get("ok", "?")), String(r.get("msg", "")), before,
		float(tgt.resources.get("coin", 0))])
	_check("★★同格索貢【沒有】被閘擋掉（訊息不含「不在你的格上」）",
		not String(r.get("msg", "")).contains("不在你的格上"))
	_check("★★★功能沒有被門死：同格索貢成立（ok=true）", bool(r.get("ok", false)))
	print("   ★邊界：本格【不】斷言拿到多少 —— 那是索貢機制自己的事（D1 已登 defer）")
	_cell("_test_p5_colocated_behaviour_unchanged")
