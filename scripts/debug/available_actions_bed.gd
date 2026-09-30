extends SceneTree
# @bed-kind: invariant
# slice: 動作全列 ＋ 原因（spec 2026-09-30；權威＝§5 普查／§6 R² 加固／§7 母體邊界）
#
# ★★★這張票治的病：`map_available_action(…, enabled, disabled_reason, …)` 那兩個欄位
#   **存在於信封的型別裡而從來沒有被餵過非預設值** —— `player_query_api.gd:296` 硬寫 `true, ""`
#   ⇒ 恆 true／恆空，正是我們自己有守衛在抓的那一族。
#
# ★★而本票真正的重心有兩個，而它們不是同一件事：
#   ·P1／P1c 守【名字】（母體 ＝ `TEAM_TARGET_ACTIONS`，而且要逐字引用那個常數）
#   ·P7 守【條件】（pop 1.5 倍／readiness 0.7／coin 只准有一份）
#   ⇒ P7 更接近「一個真相一份」的本體：名字漂開看得出來，條件漂開只會讓
#     「選單說可以、handler 說不行」，而那在卷面上是沉默的。
#
# ★誠實限（逐條）：
#   1. ★spec P4 寫「舊介面回逐字相同的陣列」，而藍圖④要求 STUB 的 `recruit` **不列**
#      ⇒ 兩者在字面上衝突。我照藍圖做（不列），而 P4 改成
#      【只差那個具名排除】並把差集印出來 —— ★不是把 P4 放寬，是把它的主詞講準。
#   2. 本床的靜態格（P1c／P7／P8）不需要 Godot 的世界，而行為格需要。
#   3. 本票不改庫存那四處（`_make_item_action`）；P8 會把 22 個呼叫點的分佈印出來，
#      並說清楚本票涵蓋的是哪幾個 —— 否則「全列」這個詞沒有母體。

var _errors: int = 0
var _cells_ran: Array = []

const SPEC_TEAM_TARGET_TOTAL: int = 11      # `TEAM_TARGET_ACTIONS` 的大小（spec §7）
const SPEC_STUB_EXCLUDED: int = 1           # 具名排除：recruit（尚未實裝此機制）
const SPEC_STUB_WORDING: String = "尚未實裝"  # ★reviewer 要求的措辭（不要讓人讀成「停用」）
const SPEC_CONSTANT_SYMBOL: String = "TEAM_TARGET_ACTIONS"
# ★P7 要數的三個條件字面（來自 spec §6④，不是我從輸出抄回來的）
const SPEC_CONDITION_LITERALS: Array = ["1.5", "0.7", "RECRUIT_COST_ANON"]
# ★§7：兩份同形信封的呼叫點總數（普查的數字，寫進 spec）
const SPEC_ENVELOPE_SITES_QUERY: int = 15   # 本票刪掉三處停用列之後（原 18）
const SPEC_ENVELOPE_SITES_ITEM: int = 4     # `_make_item_action`（庫存，不在本票）

const EXPECTED_CELLS: Array = [
	"_test_p1_full_list_both_directions",
	"_test_p1c_static_cross_evidence",
	"_test_p2_every_false_has_a_reason",
	"_test_p4_old_view_differs_only_by_the_named_exclusion",
	"_test_p5_stub_not_listed",
	"_test_p7_conditions_have_a_single_holder",
	"_test_p8_envelope_boundary",
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
	var st: WorldState = MeasureBedHelper.arm_and_new()
	GameSetup.setup(st, GameSetup.load_config("res://config/warring_states.json"))
	return [st, PlayerCommandSystem.new()]

func _code_only(src: String) -> String:
	var out: String = ""
	for l in src.split("\n"):
		if l.strip_edges().begins_with("#"):
			continue
		out += l + "\n"
	return out

# 取某一支函式的【函式體】原始碼（到下一個頂層 `func ` 為止）
func _func_body(src: String, sig: String) -> String:
	var i: int = src.find(sig)
	if i < 0:
		return ""
	var rest: String = src.substr(i + sig.length())
	var j: int = rest.find("\nfunc ")
	return rest if j < 0 else rest.substr(0, j)

# 找一個同格的目標隊（團隊目標動作的前提）
func _target(st: WorldState, pt: TeamData) -> int:
	for k in st.teams.keys():
		if int(k) != pt.team_id and st.teams[k].leader_id != -1:
			st.teams[k].tile_pos = pt.tile_pos
			return int(k)
	return -1


# ══ P1：全列 —— ★雙向（spec §3 P1 改雙向）═══════════════════════════════════
# ★這是少數「數數」合法的場合：那個數來自**外部常數**，不是自己算給自己看。
# ★★而雙向的理由：只驗「常數的每個名字都在列裡」擋不住列裡多出一個名字；
#   只驗「列裡的名字都在常數裡」擋不住少一個 ⇒ 兩個方向都要。
func _test_p1_full_list_both_directions() -> void:
	print("\n── P1 全列（雙向）──")
	var arr: Array = _fresh()
	var st: WorldState = arr[0]
	var cs: PlayerCommandSystem = arr[1]
	var pt: TeamData = st.teams.get(st.get_player_team_id())
	var tid: int = _target(st, pt)
	_check("★母體地板：找到同格目標（-1 的話每一列都會是「沒有目標」）", tid != -1)
	var rows: Array = cs.get_action_availability(st, tid)
	var expect_n: int = PlayerCommandSystem.TEAM_TARGET_ACTIONS.size() \
		- PlayerCommandSystem.STUB_NOT_IMPLEMENTED.size()
	print("   常數 %d 個 − 具名排除 %d 個 ＝ 預期 %d 列｜實得 %d 列" % [
		PlayerCommandSystem.TEAM_TARGET_ACTIONS.size(),
		PlayerCommandSystem.STUB_NOT_IMPLEMENTED.size(), expect_n, rows.size()])
	_check("★常數大小 ＝ spec 的 %d（對不上 ⇒ 母體變了，要回報不是改這裡）" % SPEC_TEAM_TARGET_TOTAL,
		PlayerCommandSystem.TEAM_TARGET_ACTIONS.size() == SPEC_TEAM_TARGET_TOTAL)
	_check("★★列數 ＝ 常數 − 具名排除（%d／%d）" % [rows.size(), expect_n], rows.size() == expect_n)
	var seen: Dictionary = {}
	var extra: Array = []
	for r in rows:
		var id: String = String(r.get("action_id", ""))
		seen[id] = int(seen.get(id, 0)) + 1
		if not PlayerCommandSystem.TEAM_TARGET_ACTIONS.has(id):
			extra.append(id)
	var missing: Array = []
	for n in PlayerCommandSystem.TEAM_TARGET_ACTIONS:
		if PlayerCommandSystem.STUB_NOT_IMPLEMENTED.has(String(n)):
			continue
		if not seen.has(String(n)):
			missing.append(String(n))
	var dup: Array = []
	for k2 in seen.keys():
		if int(seen[k2]) != 1:
			dup.append("%s×%d" % [String(k2), int(seen[k2])])
	print("   方向①列裡多出來的：%s｜方向②常數裡缺的：%s｜重複出現的：%s" % [
		str(extra), str(missing), str(dup)])
	_check("★★★雙向一致：列裡沒有多的（%s）" % str(extra), extra.is_empty())
	_check("★★★雙向一致：常數裡沒有缺的（%s）" % str(missing), missing.is_empty())
	_check("★每個名字剛好出現一次（%s）" % str(dup), dup.is_empty())
	_cell("_test_p1_full_list_both_directions")


# ══ P1c：★靜態互證（§6①，reviewer 想到的第三種騙法）═══════════════════════════
# ★★★他推演的第三種：**兩份手抄名字剛好逐字同步**（靠人力維護）——
#   兩道動態擾動都測不出來（計數與集合都會對）。
#   ⇒ 所以要 grep 全列版那段 code：它必須**逐字呼 `TEAM_TARGET_ACTIONS`**，
#     而不是另一個字面陣列。
func _test_p1c_static_cross_evidence() -> void:
	print("\n── P1c 靜態互證（全列版必須逐字引用那個常數）──")
	var src: String = FileAccess.get_file_as_string(
		"res://scripts/simulation/player_command_system.gd")
	var body: String = _code_only(_func_body(src,
		"func get_action_availability(state: WorldState, target_id: int) -> Array:"))
	_check("★母體地板：真的抓到全列版的函式體（抓不到 ⇒ 下面兩條恆綠）", body.length() > 0)
	var refs: int = body.count(SPEC_CONSTANT_SYMBOL)
	print("   全列版函式體裡 `%s` 出現 %d 次" % [SPEC_CONSTANT_SYMBOL, refs])
	_check("★★★它逐字引用 `%s`（不是另一個字面陣列）" % SPEC_CONSTANT_SYMBOL, refs >= 1)
	# ★另一半：函式體裡不得自己寫一個動作名字的字面陣列
	var suspicious: int = 0
	for line in body.split("\n"):
		var t: String = line.strip_edges()
		if t.contains("[\"ignore\"") or t.contains("[\"attack\"") \
				or (t.begins_with("var ") and t.contains("\"trade\"") and t.contains("\"extort\"")):
			suspicious += 1
	print("   函式體裡看起來像「另一份名字陣列」的行數 ＝ %d" % suspicious)
	_check("★★沒有第二份名字陣列（%d 行可疑）" % suspicious, suspicious == 0)
	_cell("_test_p1c_static_cross_evidence")


# ══ P2：enabled=false 的每一列都要有原因 ═════════════════════════════════════
# ★母體地板：印出【這一輪有幾列 false】—— 0 的話這一格會在「什麼都能做」的世界裡恆綠。
func _test_p2_every_false_has_a_reason() -> void:
	print("\n── P2 每一列 false 都有原因 ──")
	var arr: Array = _fresh()
	var st: WorldState = arr[0]
	var cs: PlayerCommandSystem = arr[1]
	var pt: TeamData = st.teams.get(st.get_player_team_id())
	var tid: int = _target(st, pt)
	# 造一個「幾乎每一條都不可做」的狀態：沒錢、準備值低、同勢力、對方人多
	ResourceBank.set_amt(pt, "coin", 0.0, "bed_fixture")
	pt.readiness = 0.0
	var tgt: TeamData = st.teams.get(tid)
	tgt.faction_id = pt.faction_id
	AnonTierSystem.add_anon(tgt, AnonCohort.TIER_PLEB, 30)
	var rows: Array = cs.get_action_availability(st, tid)
	var n_false: int = 0
	var empty_reason: Array = []
	for r in rows:
		if not bool(r.get("enabled", true)):
			n_false += 1
			if String(r.get("disabled_reason", "")).strip_edges() == "":
				empty_reason.append(String(r.get("action_id", "")))
		print("   %-18s enabled=%-5s｜%s" % [String(r.get("action_id", "")),
			str(r.get("enabled", "?")), String(r.get("disabled_reason", ""))])
	print("   ★本輪 false ＝ %d 列（0 的話本格恆綠）" % n_false)
	_check("★母體地板：本輪真的有 false 的列（%d）" % n_false, n_false > 0)
	_check("★★★每一列 false 的 `disabled_reason` 都非空（空的：%s）" % str(empty_reason),
		empty_reason.is_empty())
	_cell("_test_p2_every_false_has_a_reason")


# ══ P4：舊介面 ★只差那個具名排除（誠實限 1）══════════════════════════════════
# ★spec 的字面是「逐字相同」，而藍圖④要求 STUB 不列 ⇒ 兩者衝突。
#   本格照藍圖做並把**差集印出來**：差集只准是那個具名排除。
func _test_p4_old_view_differs_only_by_the_named_exclusion() -> void:
	print("\n── P4 舊介面只差具名排除 ──")
	var arr: Array = _fresh()
	var st: WorldState = arr[0]
	var cs: PlayerCommandSystem = arr[1]
	var pt: TeamData = st.teams.get(st.get_player_team_id())
	var tid: int = _target(st, pt)
	ResourceBank.set_amt(pt, "coin", 9999.0, "bed_fixture")   # ★讓 coin 條件過（否則差集恆空）
	pt.readiness = 1.0
	var derived: Array = cs.get_available_actions(st, tid)
	var enabled_from_rows: Array = []
	for r in cs.get_action_availability(st, tid):
		if bool(r.get("enabled", false)):
			enabled_from_rows.append(String(r.get("action_id", "")))
	print("   衍生檢視 ＝ %s" % str(derived))
	print("   全列版 enabled ＝ %s" % str(enabled_from_rows))
	_check("★★衍生檢視逐字等於全列版的 enabled 那些（含順序）",
		str(derived) == str(enabled_from_rows))
	var missing_vs_const: Array = []
	for n in PlayerCommandSystem.TEAM_TARGET_ACTIONS:
		if not derived.has(String(n)):
			missing_vs_const.append(String(n))
	print("   ★與常數的差集 ＝ %s（★這一輪的條件都過了 ⇒ 差集應該只有具名排除）" % str(missing_vs_const))
	_check("★★★差集只有具名排除（%s vs %s）" % [
		str(missing_vs_const), str(PlayerCommandSystem.STUB_NOT_IMPLEMENTED)],
		str(missing_vs_const) == str(PlayerCommandSystem.STUB_NOT_IMPLEMENTED))
	print("   ★★而 spec P4 的字面是「逐字相同」⇒ 本格把它講準成【只差具名排除】並印差集，")
	print("     不是把 P4 放寬：差集多一個名字就紅。")
	_cell("_test_p4_old_view_differs_only_by_the_named_exclusion")


# ══ P5：★STUB 不在列，而排除【就地具名寫了理由】＋措辭不得讓人讀成「停用」═══════
func _test_p5_stub_not_listed() -> void:
	print("\n── P5 STUB 不在列 ──")
	var arr: Array = _fresh()
	var st: WorldState = arr[0]
	var cs: PlayerCommandSystem = arr[1]
	var pt: TeamData = st.teams.get(st.get_player_team_id())
	ResourceBank.set_amt(pt, "coin", 9999.0, "bed_fixture")   # ★錢夠 ⇒ 舊版本來會列 recruit
	var tid: int = _target(st, pt)
	var ids: Array = []
	for r in cs.get_action_availability(st, tid):
		ids.append(String(r.get("action_id", "")))
	print("   全列版的名字：%s" % str(ids))
	_check("★母體地板：錢是夠的（否則「不列」可能只是條件沒過）",
		float(pt.resources.get("coin", 0)) >= PlayerCommandSystem.RECRUIT_COST_ANON)
	_check("★★★`recruit`（STUB）不在列", not ids.has("recruit"))
	var src: String = FileAccess.get_file_as_string(
		"res://scripts/simulation/player_command_system.gd")
	var near: bool = false
	var lines: PackedStringArray = src.split("\n")
	for i in range(lines.size()):
		if lines[i].contains("STUB_NOT_IMPLEMENTED") and lines[i].contains("const"):
			for k in range(maxi(0, i - 12), i + 2):
				if lines[k].contains(SPEC_STUB_WORDING):
					near = true
	print("   排除的理由裡有「%s」這個措辭 ＝ %s" % [SPEC_STUB_WORDING, str(near)])
	_check("★★措辭是「%s」而不是模糊語（★reviewer：別讓人讀成「停用／暫停」）" % SPEC_STUB_WORDING,
		near)
	_cell("_test_p5_stub_not_listed")


# ══ P7：★★★條件只有一份（spec §6④；P1 守名字，本格守條件）═══════════════════
# 那三個條件的字面在【查詢面】必須 0 次、在全列版必須各 1 次。
func _test_p7_conditions_have_a_single_holder() -> void:
	print("\n── P7 條件只有一份 ──")
	var q: String = _code_only(FileAccess.get_file_as_string(
		"res://scripts/simulation/player_query_api.gd"))
	var pcs: String = FileAccess.get_file_as_string(
		"res://scripts/simulation/player_command_system.gd")
	var body: String = _code_only(_func_body(pcs,
		"func get_action_availability(state: WorldState, target_id: int) -> Array:"))
	_check("★母體地板：抓到全列版的函式體", body.length() > 0)
	for lit in SPEC_CONDITION_LITERALS:
		var in_q: int = q.count(String(lit))
		var in_body: int = body.count(String(lit))
		print("   條件字面 `%s`：查詢面 %d 次｜全列版 %d 次" % [String(lit), in_q, in_body])
		_check("★★★`%s` 在查詢面 0 次（它是第二份的入口）" % String(lit), in_q == 0)
		_check("★`%s` 在全列版至少 1 次（唯一持有者）" % String(lit), in_body >= 1)
	print("   ★而本格比 P1 更接近「一個真相一份」的本體：名字漂開看得出來，")
	print("     條件漂開只會讓【選單說可以而 handler 說不行】，那在卷面上是沉默的。")
	_cell("_test_p7_conditions_have_a_single_holder")


# ══ P8：★母體邊界 —— 說得出本票涵蓋 22 個呼叫點裡的哪幾個（§7）═══════════════
func _test_p8_envelope_boundary() -> void:
	print("\n── P8 母體邊界（兩份同形信封）──")
	var q_raw: String = FileAccess.get_file_as_string(
		"res://scripts/simulation/player_query_api.gd")
	var m_raw: String = FileAccess.get_file_as_string(
		"res://scripts/simulation/player_api_mapper.gd")
	var q_sites: int = _code_only(q_raw).count("map_available_action(")
	var m_sites: int = 0
	for l in _code_only(m_raw).split("\n"):
		if l.contains("_make_item_action(") and not l.contains("static func"):
			m_sites += 1
	print("   `map_available_action` 呼叫點（查詢面）＝ %d｜`_make_item_action`（庫存）＝ %d" % [
		q_sites, m_sites])
	print("   ★本票涵蓋的是【團隊目標動作】那一條路：原本 4 處（1 啟用 ＋ 3 停用）")
	print("     ⇒ 現在收成 1 個迴圈（可做與不可做都由全列版產生）")
	print("   ★★不在本票：庫存那 %d 處（另一個信封）／自家隊 11 個／格動作（界線不可機械讀）" % m_sites)
	print("     ⇒ 後兩者已就地具名標記並登 defer（no-source-constant／unreadable-boundary）")
	_check("★查詢面的呼叫點數 ＝ spec 記的 %d（刪掉三處停用列之後）" % SPEC_ENVELOPE_SITES_QUERY,
		q_sites == SPEC_ENVELOPE_SITES_QUERY)
	_check("★★庫存那個信封的呼叫點數 ＝ %d（不在本票，但母體要數得到它）" % SPEC_ENVELOPE_SITES_ITEM,
		m_sites == SPEC_ENVELOPE_SITES_ITEM)
	var marks: int = 0
	for mark in ["no-source-constant: own-team-actions", "unreadable-boundary: tile-actions"]:
		if q_raw.contains(mark):
			marks += 1
	print("   兩個具名標記都在 ＝ %s（defer 的 met_check 錨在它們上面）" % str(marks == 2))
	_check("★★★兩個 defer 的錨（就地具名標記）都在（%d／2）" % marks, marks == 2)
	_cell("_test_p8_envelope_boundary")


func _initialize() -> void:
	print("=== available_actions bed ===")
	_test_p1_full_list_both_directions()
	_test_p1c_static_cross_evidence()
	_test_p2_every_false_has_a_reason()
	_test_p4_old_view_differs_only_by_the_named_exclusion()
	_test_p5_stub_not_listed()
	_test_p7_conditions_have_a_single_holder()
	_test_p8_envelope_boundary()
	var miss: Array = []
	for c in EXPECTED_CELLS:
		if not _cells_ran.has(c):
			miss.append(c)
	if not miss.is_empty():
		_errors += miss.size()
		push_error("[FAIL] 缺席的格：%s" % str(miss))
	print("\n=== available_actions DONE === errors: %d｜到場點名 %d／%d" % [
		_errors, _cells_ran.size(), EXPECTED_CELLS.size()])
	quit(1 if _errors > 0 else 0)
