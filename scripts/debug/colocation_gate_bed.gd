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
#   2. ~~`execute_action_with_target`（吃 Dictionary 的那條）不在本閘的爆炸半徑內~~
#      ★★★這句是 systems 說錯的，而【P6 就是推翻它的那一格】：
#      `recruit_named` 走那條入口、跨隊搬人＋搬 coin、原本零同格檢查。
#      ★錯法＝用【哪一個入口】代替【母體】，而母體的定義是【跟別隊發生作用的動作】
#        —— 「它吃 Dictionary」是真的，但與這個問題無關。
#      ⇒ 本閘現在涵蓋兩個入口：`execute_action`（10／11 需同格）
#        ＋ `execute_action_with_target` 的 `recruit_named`（契約靜態已知，不必問動詞）。
#      ★★留著劃掉的這一行比刪掉有用：下一個人會看到「這裡曾經有人用入口代替母體」。

var _errors: int = 0
var _cells_ran: Array = []

# ★spec §3 的母體地板：需要同格的動詞有幾個／例外有幾個，相加要等於【團體目標動詞總數】。
#   ★★而這三個數【不是我手抄的】：P2 從 `get_available_actions` 的 append 字面機械導出，
#     再與 `TEAM_TARGET_ACTIONS` 做集合比對。這裡的常數只是「spec 說幾個」那一半。
const SPEC_TEAM_TARGET_TOTAL: int = 12    # ignore attack trade propose_alliance demand_tribute
                                          # extort recruit recruit_anon invite_settle
                                          # gather_intel beg offer_surrender
# ★★★11 → 12（`offer_surrender` 進母體，2026-10-01）—— ★而上面那份**手抄的名字清單**
#   也要跟著補：它是一份長度 12 的手抄名單，而手抄名單漏一個是**靜默的**
#   ⇒ 所以 P12b 把【行為上真的被這一閘擋住的那些】逐一列出來與常數比對（指名，不數數）。
# ★★而 `offer_surrender` 落在**需同格**那一半（不是例外）：藍圖的意圖帳逐字寫
#   「遠程求和不該存在」，而進母體就是讓這一閘管它。
# ★★★【例外的上限】—— P12c：例外只准變少不准變多。
#   ★方向寫在這裡：這個數是**天花板**（`<=`），不是地板。拿它當地板會讓守衛閉嘴。
const SPEC_EXEMPT_MAX: int = 1            # 今天 ＝ ["ignore"]；要加第二個 ⇒ 必須有人改這一行並說明理由
const SPEC_EARLY_RETURN_EXEMPT: Array = ["ignore"]   # ★在 execute_action 更上面就 return，走不到閘
# ★動工時量到的現況：11 個裡有幾個【自己】本來就查同格（本閘之前）
#   ★★這個 11 是【歷史量測】不是現況（同格閘那一票動工時母體是 11；
#     `offer_surrender` 進母體之後是 12）⇒ **刻意不改**：
#     它記的是「那一天量到什麼」，改它會把一次量測改寫成一個永遠正確的句子。
#   ⇒ ★★★判準：一個數字是【歷史】還是【現況】，要寫在它旁邊 ——
#     否則下一個人會把歷史當成過期的現況去「修」它。
const MEASURED_SELF_CHECKING: Array = ["invite_settle", "beg"]

const EXPECTED_CELLS: Array = [
	"_test_p1_remote_is_refused_with_human_words",
	"_test_p2_verb_set_is_cross_checked",
	"_test_p3_menu_and_handler_do_not_contradict",
	"_test_p4_self_actions_are_not_blocked_by_a_stray_target_id",
	"_test_p5_colocated_behaviour_unchanged",
	"_test_p6_recruit_named_is_the_third_channel",
	"_test_p7_offer_surrender_is_gated_by_name",
	"_test_p8_gate_partition_is_proven_by_behaviour",
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

# ══ P6：第三個管道 —— `recruit_named` 跨隊搬人＋搬 coin ═══════════════════
# ★★★R² 擋件抓到的（systems 裁 2026-09-30 納入本票，不登 defer）：那條路的
#   `from_team_id` 直接來自 target dict（任意值）⇒ 走程式介面可以
#   【隔空向任意隊買走一個記名成員】—— 而它比隔空索貢更重。
# ★★★而本格要印的是【人與 coin 兩邊都沒動】，不是只印 ok=false：
#   那條路有**四個寫入**（玩家付錢／對方收錢／人離原隊／人入玩家隊）
#   ⇒ **半途擋下來比沒擋更糟**（人離了原隊而沒入玩家隊＝憑空消失）
#   ⇒ 所以四個欄位逐一斷言，而不是相信「ok=false 就代表什麼都沒發生」。
# ★母體地板三道：①目標真的不同格 ②那個人真的在對方隊上（不然「沒被搬走」恆真）
#   ③玩家真的付得起（付不起的話 ok=false 可能是金幣不足而不是閘）
# 負對照：把 `refuse_if_not_colocated` 那一行拿掉 ⇒ ★實測玩家 coin 真的少了（人被買走） ⇒ 已於 feat/colocation-in-handler（2026-09-30 這一輪） 實測紅
# == P7 = 本票 spec P3 [★★★同格閘真的管到 `offer_surrender`] ==================
# ★這一格存在的理由是一個【現存的洞】，不是分類學：
#   進母體**之前**，`_colocation_gate` 的第一條件
#     `if not TEAM_TARGET_ACTIONS.has(action): return {}`（★回空字典 ＝ **放行**）
#   對它放行 ⇒ `execute_action(state, 任意 target_id, "offer_surrender")`
#   對一支**不同格**的隊打得通，而 accept 會轉移資產並把玩家隊收編。
# ★★為什麼要一個【指名】的格，而不是靠 P1 的迴圈：P1 迭代 `TEAM_TARGET_ACTIONS`
#   ⇒ 把這個名字從常數拿掉的話，P1 的**母體跟著縮小** ⇒ 它會**綠著**放過這個洞。
#   ⇒ ★判準：當一個守衛的母體來自「被守的那張清單」本身，
#     「從清單拿掉」這個擾動對它沒有鑑別力 ⇒ 要有一格**指名**它。
# 負對照：把 `offer_surrender` 從 `TEAM_TARGET_ACTIONS` 拿掉 ⇒ 遠程呼它又打得通 ⇒ 本格必紅 ⇒ 待實測
func _test_p7_offer_surrender_is_gated_by_name() -> void:
	print("\n── P7（本票 spec P3）同格閘真的管到 `offer_surrender` ──")
	var arr: Array = _fresh()
	var st: WorldState = arr[0]
	var cmd: PlayerCommandSystem = arr[1]
	var ptid: int = st.get_player_team_id()
	var pt: TeamData = st.teams.get(ptid)
	# ★找一支【不同格】的隊
	var far_id: int = -1
	for k in st.teams.keys():
		var t: TeamData = st.teams[k]
		if int(k) != ptid and t.tile_pos != pt.tile_pos:
			far_id = int(k)
			break
	_check("★母體地板 A：找到一支不同格的隊（-1 ⇒ 本格沒有主詞）", far_id != -1)
	if far_id == -1:
		_cell("_test_p7_offer_surrender_is_gated_by_name")
		return
	var far: TeamData = st.teams.get(far_id)
	var dq: int = absi(int(far.tile_pos.x) - int(pt.tile_pos.x))
	var dr: int = absi(int(far.tile_pos.y) - int(pt.tile_pos.y))
	print("   玩家隊 %s｜目標隊 %s｜座標差 (%d, %d)" % [
		str(pt.tile_pos), str(far.tile_pos), dq, dr])
	_check("★★母體地板 B：真的不同格（同格的話這一格會在「大家都同格」的世界裡恆綠）",
		pt.tile_pos != far.tile_pos)
	_check("★★★母體地板 C：`offer_surrender` 真的在母體裡（不在 ⇒ 下面測的是另一件事）",
		PlayerCommandSystem.TEAM_TARGET_ACTIONS.has("offer_surrender"))
	# ★★★先印【同格閘自己回了什麼】—— 空字典 ＝ 放行 ⇒ 這一格的證據是那句人話本身
	var gate_r: Dictionary = cmd.refuse_if_not_colocated(st, far_id, pt)
	print("   同格閘回傳 ＝ %s（★空字典 ＝ 放行）" % str(gate_r))
	_check("★★★★同格閘對它【不放行】（回空字典就是放行）", not gate_r.is_empty())
	# ★★而真正要守的是**走完整條路**的結果（閘有沒有被接上）
	var coin_before: float = float(far.resources.get("coin", 0))
	var r: Dictionary = cmd.execute_action(st, far_id, "offer_surrender")
	var m: String = String(r.get("msg", r.get("message", "")))
	print("   `execute_action` ⇒ ok=%s｜msg「%s」" % [str(r.get("ok", false)), m])
	_check("★★★★★遠程求和【被拒絕】（它曾經打得通，而 accept 會轉移資產＋收編玩家隊）",
		not bool(r.get("ok", false)))
	_check("★原因就是同格閘那句人話（實測「%s」）" % m, m == String(gate_r.get("msg", "")))
	_check("★★對方的錢沒有被動（%.0f ⇒ %.0f）" % [coin_before, float(far.resources.get("coin", 0))],
		is_equal_approx(coin_before, float(far.resources.get("coin", 0))))
	_cell("_test_p7_offer_surrender_is_gated_by_name")


# == P8 = P12b [行為證：真的被這一閘擋住的那些，逐一列名] =======================
# ★取代那個【恆真加法】的承重格：它不比數字，它比**集合**，而兩邊異源 ——
#   一邊是「行為上真的被擋住的」（跑出來的），一邊是「母體 − 例外」（宣告的）。
#   ⇒ ★兩邊可以各自獨立改變 ⇒ 它不是「一句話講兩次」。
# ★★而差集要**指名**不是數數：計數是有損投影，缺陷活在它丟掉的那一維
#   （三個集合可以大小相同而成員不同）。
# 負對照：把一個動詞從 `SPEC_EARLY_RETURN_EXEMPT` 拿掉 ⇒ 它會出現在「宣告說該被擋而行為上沒被擋」那一邊 ⇒ 必紅並指名 ⇒ 待實測
func _test_p8_gate_partition_is_proven_by_behaviour() -> void:
	print("\n── P8（P12b）行為上真的被同格閘擋住的那些 ──")
	var arr: Array = _fresh()
	var st: WorldState = arr[0]
	var cmd: PlayerCommandSystem = arr[1]
	var ptid: int = st.get_player_team_id()
	var pt: TeamData = st.teams.get(ptid)
	var far_id: int = -1
	for k in st.teams.keys():
		var t: TeamData = st.teams[k]
		if int(k) != ptid and t.tile_pos != pt.tile_pos:
			far_id = int(k)
			break
	_check("★母體地板 A：找到一支不同格的隊", far_id != -1)
	if far_id == -1:
		_cell("_test_p8_gate_partition_is_proven_by_behaviour")
		return
	# ★那句人話從閘自己拿（不手抄一份字面）
	var words: String = String(cmd.refuse_if_not_colocated(st, far_id, pt).get("msg", ""))
	print("   同格閘的那句人話 ＝「%s」（★從閘自己拿，不手抄）" % words)
	_check("★★母體地板 B：那句人話非空（空的話下面每一條都分不出來）", words.strip_edges() != "")
	var blocked: Array = []
	var not_blocked: Array = []
	for act in PlayerCommandSystem.TEAM_TARGET_ACTIONS:
		var a: String = String(act)
		var arr2: Array = _fresh()          # ★每一個動詞一個乾淨世界（上一個可能改了狀態）
		var st2: WorldState = arr2[0]
		var cmd2: PlayerCommandSystem = arr2[1]
		var pt2: TeamData = st2.teams.get(st2.get_player_team_id())
		var far2: int = -1
		for k2 in st2.teams.keys():
			var t2: TeamData = st2.teams[k2]
			if int(k2) != st2.get_player_team_id() and t2.tile_pos != pt2.tile_pos:
				far2 = int(k2)
				break
		if far2 == -1:
			not_blocked.append("%s（這一輪找不到不同格的隊）" % a)
			continue
		var r2: Dictionary = cmd2.execute_action(st2, far2, a)
		var m2: String = String(r2.get("msg", r2.get("message", "")))
		if m2 == words:
			blocked.append(a)
		else:
			not_blocked.append(a)
	blocked.sort()
	var declared: Array = []
	for act3 in PlayerCommandSystem.TEAM_TARGET_ACTIONS:
		if not SPEC_EARLY_RETURN_EXEMPT.has(String(act3)):
			declared.append(String(act3))
	declared.sort()
	print("   行為上被擋住的 %d 個：%s" % [blocked.size(), str(blocked)])
	print("   宣告上該被擋的 %d 個（母體 − 例外）：%s" % [declared.size(), str(declared)])
	print("   沒被擋的 %d 個：%s" % [not_blocked.size(), str(not_blocked)])
	_check("★★母體地板：行為上真的擋住了一些（0 ⇒ 下面那條會在一個什麼都沒跑的世界裡比空集合）",
		blocked.size() > 0)
	var miss: Array = []
	var extra: Array = []
	for d in declared:
		if not blocked.has(String(d)):
			miss.append(String(d))
	for b in blocked:
		if not declared.has(String(b)):
			extra.append(String(b))
	_check("★★★★★兩邊【逐一指名】相等：宣告說該擋而行為上沒擋的 ＝ %s｜行為上擋了而宣告沒說的 ＝ %s"
		% [str(miss), str(extra)], miss.is_empty() and extra.is_empty())
	print("   ★★而這一格取代的是一個【恆真加法】（`(n−e)+e == n`）——")
	print("     那個式子裡 `exempt` 被代數消掉，所以它寫幾個例外都綠。")
	_cell("_test_p8_gate_partition_is_proven_by_behaviour")


func _test_p6_recruit_named_is_the_third_channel() -> void:
	print("\n── P6 第三個管道：recruit_named ──")
	var pair: Array = _fresh()
	var st: WorldState = pair[0]
	var cmd: PlayerCommandSystem = pair[1]
	var tid: int = _other_team_id(st)
	if tid == -1:
		_cell("_test_p6_recruit_named_is_the_third_channel")
		return
	var tgt: TeamData = _place(st, tid, false)
	var pt: TeamData = st.teams.get(st.get_player_team_id())
	_check("★母體地板 A：目標真的不同格", pt.tile_pos != tgt.tile_pos)
	var pid: int = -1
	for m in tgt.named_members:
		if st.persons.has(int(m)):
			pid = int(m)
			break
	print("   對方 Team%d 的記名成員 = %s ⇒ 取 P%d" % [tid, str(tgt.named_members), pid])
	_check("★母體地板 B：那個人真的在對方隊上（不然「沒被搬走」恆真）",
		pid != -1 and st.persons.has(pid) and st.persons[pid].team_id == tid)
	if pid == -1:
		_cell("_test_p6_recruit_named_is_the_third_channel")
		return
	pt.resources["coin"] = 1000.0
	_check("★母體地板 C：玩家真的付得起（%.0f coin）" % float(pt.resources["coin"]),
		float(pt.resources.get("coin", 0)) >= PlayerCommandSystem.RECRUIT_COST_NAMED)
	var before_player_coin: float = float(pt.resources.get("coin", 0))
	var before_target_coin: float = float(tgt.resources.get("coin", 0))
	var before_owner: int = st.persons[pid].team_id
	var before_in_target: bool = tgt.named_members.has(pid)
	var before_in_player: bool = pt.named_members.has(pid)
	var r: Dictionary = cmd.execute_action_with_target(st, "recruit_named",
		{"team_id": tid, "member_id": pid, "tile_q": -1, "tile_r": -1})
	print("   隔空 recruit_named ⇒ ok=%s msg=%s" % [str(r.get("ok", "?")), String(r.get("msg", ""))])
	_check("★隔空被拒（ok=false）", not bool(r.get("ok", true)))
	_check("★★訊息是人話（含「格」字）", String(r.get("msg", "")).contains("格"))
	print("   玩家 coin %.1f → %.1f｜對方 coin %.1f → %.1f｜P%d 的隊 %d → %d" % [
		before_player_coin, float(pt.resources.get("coin", 0)),
		before_target_coin, float(tgt.resources.get("coin", 0)),
		pid, before_owner, st.persons[pid].team_id])
	_check("★★★一：玩家 coin 沒少",
		is_equal_approx(float(pt.resources.get("coin", 0)), before_player_coin))
	_check("★★★二：對方 coin 沒多",
		is_equal_approx(float(tgt.resources.get("coin", 0)), before_target_coin))
	_check("★★★三：那個人還在對方隊的 roster 上（%s → %s）" % [
		str(before_in_target), str(tgt.named_members.has(pid))],
		tgt.named_members.has(pid) == before_in_target)
	_check("★★★四：那個人沒有進玩家隊的 roster（%s → %s）" % [
		str(before_in_player), str(pt.named_members.has(pid))],
		pt.named_members.has(pid) == before_in_player)
	_check("★★★五：那個人的 team_id 沒變（%d → %d）" % [before_owner, st.persons[pid].team_id],
		st.persons[pid].team_id == before_owner)
	print("   ★為什麼要五條而不是一條 ok=false：這條路有四個寫入 ⇒")
	print("     半途擋下來比沒擋更糟（人離了原隊而沒入玩家隊＝憑空消失）")
	print("     ⇒ 「ok=false」答不出「世界有沒有被動過一半」。")
	_place(st, tid, true)
	var r2: Dictionary = cmd.execute_action_with_target(st, "recruit_named",
		{"team_id": tid, "member_id": pid, "tile_q": -1, "tile_r": -1})
	print("   同格 recruit_named ⇒ ok=%s msg=%s" % [str(r2.get("ok", "?")), String(r2.get("msg", ""))])
	_check("★同格時仍然買得到（功能沒被門死）", bool(r2.get("ok", false)))
	_cell("_test_p6_recruit_named_is_the_third_channel")


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
	_test_p6_recruit_named_is_the_third_channel()
	_test_p7_offer_surrender_is_gated_by_name()
	_test_p8_gate_partition_is_proven_by_behaviour()
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
# ★★★【2026-10-01 systems 改判：從「兩邊相等」改成「第二份不存在」】
#   ★動作全列那張票把 `get_available_actions` 改成**衍生檢視**
#     （`get_action_availability(...).filter(enabled).map(action_id)`）
#     ⇒ 函式體裡**一個字面動詞名都沒有了** ⇒ 舊抽取式回**空集合**
#     ⇒ 三道地板（非空／數相符 0／11／集合相等）當場全紅 —— ★★而它們**紅得對**：
#       那一族地板寫的就是「抽取壞了會回空集合」，而這次壞掉的原因是【被重構抽空】。
#   ★★★而修法**不是換一個抽取式**：重構之後兩邊**同源**了（常數是唯一來源、
#     函式體只是它的衍生）⇒ 照原樣修好它，這一格會變成**一句話講兩次（恆真）**
#     —— 那正是「同源比較恆真」，而這是它第一次在【重構之後】真實發生。
#   ⇒ 斷言**翻面**：不問「兩邊相等嗎」，改問「**第二份還存不存在**」。
# ~~舊：閘讀的是 `TEAM_TARGET_ACTIONS`，而語意的單一來源是 `get_available_actions`~~
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
	# ★★★2026-10-01 翻面：`from_func` 現在收的是【殘留的字面動詞名】—— 它應該是空的。
	var from_func: Array = []
	var cites_derived: bool = _code_only(body).contains("get_action_availability")
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
	# ★母體地板（翻面版）：抽取式自己要先證明它抽得到東西 ——
	#   否則「沒有殘留字面」會在一個【什麼都抽不到】的世界裡恆真。
	_check("★母體地板 B：函式體真的抽到了內容（非空）", not _code_only(body).strip_edges().is_empty())
	_check("★★母體地板 C：函式體【逐字引用】`get_action_availability`（＝它真的是衍生檢視）", cites_derived)
	_check("★★★函式體裡沒有殘留的字面動詞名（有 ⇒ 有人又長了第二份）%s" % str(from_func), from_func.is_empty())
	# ~~舊斷言：導出數與 spec 總數相符／兩邊集合相等~~ ⇒ 重構後兩邊同源 ⇒ 會恆真 ⇒ 劃掉留理由（見檔頭）。
	#   ★而 `from_const` 仍被下面那條加法用到（需同格 ＋ 例外 ＝ 總數）⇒ 不動它。
	# ~~★spec §3 的那條加法：`(from_const.size() - exempt) + exempt == SPEC_TEAM_TARGET_TOTAL`~~
	#   ★★★★★【拿掉，理由留著】（systems 裁 2026-10-01，我自己抓到）——
	#   那個式子**代數上等於** `from_const.size() == SPEC_TEAM_TARGET_TOTAL`：
	#   `exempt` 被消掉了 ⇒ 不管 `SPEC_EARLY_RETURN_EXEMPT` 是空的、1 個還是 99 個，
	#   **這一格都不可能紅**。而它的標題寫著「否則分類法漏了一格」
	#   ⇒ ★它**宣稱驗分割，實際只驗總數**。
	#   ★★而最毒的是它上面三行（也是我寫的）：我劃掉了一個同源恆真，
	#     然後在它**正下方**留了第二個同族的，並寫了一句話解釋它可以不動
	#     —— 「說服我它安全的那句話就是它恆真的證明」逐字重演。
	#   ⇒ ★★★修法是**窄化不是刪除**：分割要跟【外部】比。接手的是三格：
	#     ·P12a 成員檢查（例外的每一個都真的在母體裡 —— 成員，不是算術）
	#     ·P12b 行為證（**真的被這一閘擋住的那些**逐一列出來與「母體 − 例外」比，指名）
	#     ·P12c 棘輪（例外只准變少：`<= SPEC_EXEMPT_MAX`）
	# ★★★而「總數」那一半沒有不見：它由 P2 的集合比對與 available_actions_bed 的
	#   `SPEC_TEAM_TARGET_TOTAL` 那一條守著（兩邊各自獨立改變 ⇒ 不是同源）。
	var exempt: int = SPEC_EARLY_RETURN_EXEMPT.size()
	print("   母體 %d（本床的 `SPEC_TEAM_TARGET_TOTAL` ＝ %d）｜early-return 例外 %d（上限 %d）⇒ 需同格的應該是 %d 個" % [
		from_const.size(), SPEC_TEAM_TARGET_TOTAL, exempt, SPEC_EXEMPT_MAX,
		from_const.size() - exempt])
	# ★★★★★【P1：兩支床各自斷言自己那個常數】（spec §3 P1 逐字）——
	#   ★而這一條是我**差點弄掉的**：我拿掉那個恆真加法時，
	#     那個式子代數上**就是**這一條（`(n−e)+e == C` ⇒ `n == C`）
	#     ⇒ 拿掉它 ＝ 把本床【唯一】比總數的地方一起拿掉了。
	#   ★★而我當時在註解裡寫「總數那一半由 available_actions_bed 那一條守著」
	#     —— 那是**把守衛推給另一支床**，而 spec 要的是**兩支床各自印、各自斷言**
	#     （理由：兩支床不一定在同一輪跑，而「同一顆 commit」的證據是同一輪的兩份輸出）。
	#   ⇒ ★★★判準：**把一個恆真式子拿掉的時候，要先問它【退化之後等於什麼】——
	#     那個東西可能是唯一還有用的那一半。**
	_check("★★★★★P1：母體大小 ＝ 本床的 `SPEC_TEAM_TARGET_TOTAL`（%d／%d；對不上 ⇒ 母體變了，要回報不是改這裡）"
		% [from_const.size(), SPEC_TEAM_TARGET_TOTAL],
		from_const.size() == SPEC_TEAM_TARGET_TOTAL)
	# ── P12a：例外的每一個都真的在母體裡（成員檢查，不是算術）──
	var exempt_orphan: Array = []
	for ex in SPEC_EARLY_RETURN_EXEMPT:
		if not from_const.has(String(ex)):
			exempt_orphan.append(String(ex))
	_check("★★P12a：例外清單的每一個都真的在 `TEAM_TARGET_ACTIONS` 裡（不在的：%s）"
		% str(exempt_orphan), exempt_orphan.is_empty())
	# ── P12c：例外只准變少（★天花板不是地板）──
	_check("★★P12c 棘輪：例外不得增加（%d <= %d；要加第二個 ⇒ 改常數並寫理由）" % [
		exempt, SPEC_EXEMPT_MAX], exempt <= SPEC_EXEMPT_MAX)
	# ★★動工時量到的現況：哪幾個【自己】本來就查同格（本閘之前）
	# ★★★口徑（systems 2026-09-30 統一）：兩個數都對，而【分母不同】⇒ 一律連分母寫。
	#   需同格的動詞 ＝ 11 − early-return 的 `ignore` ＝ **10**
	#   原本零檢查     ＝ 10 − 已有檢查的 `invite_settle`／`beg` ＝ **8**
	#   ⇒ 只寫「8」會讓讀的人以為母體是 8。
	print("   ★口徑：需同格 %d／%d（減 early-return %d）｜原本零檢查 %d／%d（減已有檢查的 %s）"
		% [from_const.size() - exempt, from_const.size(), exempt,
			from_const.size() - exempt - MEASURED_SELF_CHECKING.size(),
			from_const.size() - exempt, str(MEASURED_SELF_CHECKING)])
	print("   ★★而本闘的母體【不是】這份動詞清單而已：`recruit_named` 走另一個入口")
	# ★★這一句原本寫死「這 11 個」⇒ 母體變 12 之後它是假的，而它是 print 不會紅
	#   ⇒ 導出那個數（同 text_ui_layout_bed:451 那一處的修法）。
	print("     （`execute_action_with_target`）⇒ 它不在這 %d 個裡，而它也要同格 ⇒ 見 P6。"
		% PlayerCommandSystem.TEAM_TARGET_ACTIONS.size())
	print("     ⇒ 母體的定義是【跟別隊發生作用的動作】，不是【某一份動詞清單】。")
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
