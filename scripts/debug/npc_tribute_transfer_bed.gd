extends SceneTree
# @bed-kind: invariant
# slice: NPC↔NPC 索貢談成 ⇒ 錢要真的動（spec 2026-09-30，權威＝§6 裁定落地 ＋ §9 R² 加固）
#
# ★★★病灶的形狀：同一個分岔的兩側嚴重不對稱 —— 拒絕那半做了三件事（記憶／雙向名聲／print），
#   而接受那半**什麼都沒有**（只有一句 print）⇒ 錢一毛都沒動。
#   ⇒ 那種不對稱通常是「有人只寫了他當時在想的那一半」。
#
# ★★藍圖裁 (a)：金額 ＝ 與玩家遠程索貢**同一支算式**；★★★而恩怨那一段也要走**同一段** ——
#   逐字：「缺這段 ＝ NPC 之間濫索無煞車（只有玩家有）」。
#
# ★誠實限（逐條，不默默帶過）：
#   1. P6a 的斷言讀的是 `DiplomaticAiSystem.TRIBUTE_TAKE_RATIO`（class 常數）
#      ⇒ 係數被擾動時兩邊一起動 ⇒ 那一格仍綠。★真正擋「複製了一份係數」的是
#        P6b 的靜態證 ＋ 驅動器那道「讓 NPC 路自己寫一份」的負對照（兩證缺一不可）。
#   2. ★★以現行 TEST VALUE（ratio 0.1）這條路【永遠到不了 FEUD_MIN 0.30】
#      （0.1 × 人格上界 1.3 ＝ 0.13）⇒ P8b【大額】不是走這條路的 amount，
#      而是對**同一支寫入者**餵一個大 severity，證明門檻在這條路上是活的。
#      ⇒ 這一句是誠實限不是藉口：ratio 哪天調大，這條路自己就會踩到那個門檻。
#   3. 本床不動 `TRIBUTE_TAKE_RATIO`（藍圖明文留給平衡階段）。

var _errors: int = 0
var _cells_ran: Array = []

# ★spec 指名的符號（★來自 spec 不是從輸出抄回來的 —— 靜態證要釘的就是這個名字）
const SPEC_SHARED_FN: String = "apply_tribute_accept"
const SPEC_RATIO_SYMBOL: String = "TRIBUTE_TAKE_RATIO"
const SPEC_TAG_OUT: String = "demand_tribute_out"
const SPEC_TAG_IN: String = "demand_tribute_in"
const SPEC_SEQUENCE_N: int = 20
# ★被索方領袖的人格（釘死；★與 spam-brake 那支床同一組，不是這裡另挑的）
const PINNED_LEADER: Dictionary = {"慎重": 0.6, "義氣": 0.3, "求生欲": 0.3, "好戰": 0.2}
const PINNED_FEAR: float = 0.05

const EXPECTED_CELLS: Array = [
	"_test_p6a_amount_is_the_shared_formula",
	"_test_p6b_static_cross_evidence",
	"_test_p7_conservation_with_tags",
	"_test_p8a_small_moves_affinity_not_memory",
	"_test_p8b_large_moves_both_layers",
	"_test_p9_sequence_starts_refusing",
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

func _fresh() -> WorldState:
	seed(20260930)
	var st: WorldState = MeasureBedHelper.arm_and_new()
	GameSetup.setup(st, GameSetup.load_config("res://config/warring_states.json"))
	return st

func _code_only(src: String) -> String:
	var out: String = ""
	for l in src.split("\n"):
		if l.strip_edges().begins_with("#"):
			continue
		out += l + "\n"
	return out

# 找兩支【不是玩家】的隊（本票驗的是 NPC↔NPC；玩家在場與否不該改變它）
func _two_npcs(st: WorldState) -> Array:
	var ids: Array = []
	var pt_id: int = st.get_player_team_id()
	for k in st.teams.keys():
		if int(k) == pt_id:
			continue
		var t: TeamData = st.teams[k]
		if t.leader_id != -1 and st.persons.has(t.leader_id):
			ids.append(int(k))
		if ids.size() >= 2:
			break
	return ids

func _affinity(p: PersonData, toward: int) -> float:
	return float(p.relations.get(toward, 0.0))

func _feud(p: PersonData, toward: int) -> float:
	return RelationGraph.intensity_to(p.relation_edges, "feud", toward)


# ══ P6a：金額 ＝ 共用算式的【精確值】（§9① 行為證，斷言不是「有變」）═══════════
func _test_p6a_amount_is_the_shared_formula() -> void:
	print("\n── P6a 金額是共用算式的精確值 ──")
	var st: WorldState = _fresh()
	var ids: Array = _two_npcs(st)
	var taker: TeamData = st.teams[ids[0]]
	var payer: TeamData = st.teams[ids[1]]
	ResourceBank.set_amt(payer, "coin", 500.0, "bed_fixture")
	var coin_before: float = float(payer.resources.get("coin", 0))
	var ratio: float = DiplomaticAiSystem.TRIBUTE_TAKE_RATIO
	var expected: float = coin_before * ratio
	print("   母體地板：payer=Team%d coin %.3f｜taker=Team%d｜ratio（讀 class 常數）＝ %.4f" % [
		payer.team_id, coin_before, taker.team_id, ratio])
	_check("★母體地板：payer 真的有錢（coin > 0，否則共用解算點會直接回 0）", coin_before > 0.0)
	var amount: float = DiplomaticAiSystem.apply_tribute_accept(st, payer, taker)
	print("   實得 amount ＝ %.6f｜預期 coin_before × ratio ＝ %.6f（差 %.9f）" % [
		amount, expected, absf(amount - expected)])
	_check("★★★amount ＝ coin_before × ratio 的【精確值】（不是「有變」—— 有變會被無關擾動騙過）",
		absf(amount - expected) < 0.000001)
	_check("★而它不是 0（0 的話下面每一格都恆綠）", amount > 0.0)
	_cell("_test_p6a_amount_is_the_shared_formula")


# ══ P6b：靜態互證 —— 兩條路【呼同一支函式】、而玩家端不得再有係數字面 ═══════════
# ★★★§9① 逐字：兩證缺一不可 —— 行為證擋「複製了常數」，靜態證擋「行為上剛好同值」。
func _test_p6b_static_cross_evidence() -> void:
	print("\n── P6b 靜態互證（印原文，斷言釘 spec 的符號名）──")
	var dip_raw: String = FileAccess.get_file_as_string(
		"res://scripts/simulation/diplomatic_ai_system.gd")
	var pcs_raw: String = FileAccess.get_file_as_string(
		"res://scripts/simulation/player_command_system.gd")
	var pcs_code: String = _code_only(pcs_raw)
	# 印出【那一行的原文】（§7 P6b 要求）
	var npc_line: String = ""
	var player_line: String = ""
	for l in dip_raw.split("\n"):
		if l.contains(SPEC_SHARED_FN + "(") and l.contains("amount") and not l.strip_edges().begins_with("#"):
			npc_line = l.strip_edges()
			break
	for l in pcs_raw.split("\n"):
		if l.contains(SPEC_SHARED_FN + "(") and not l.strip_edges().begins_with("#"):
			player_line = l.strip_edges()
			break
	print("   NPC 那一行原文   ：%s" % npc_line)
	print("   玩家那一行原文   ：%s" % player_line)
	_check("★★NPC 那條路呼的是共用函式 `%s`" % SPEC_SHARED_FN,
		npc_line.contains(SPEC_SHARED_FN + "("))
	_check("★★玩家那條路呼的是【同一支】共用函式", player_line.contains(SPEC_SHARED_FN + "("))
	_check("★★★玩家端不得再有係數的字面（`* 0.1`）—— 有的話就是兩份各自等於 0.1",
		not pcs_code.contains("coin_before * 0.1"))
	var ratio_decl: int = _code_only(dip_raw).count("const " + SPEC_RATIO_SYMBOL)
	print("   `%s` 的宣告數 ＝ %d（要恰好 1：一個真相只存一份）" % [SPEC_RATIO_SYMBOL, ratio_decl])
	_check("★係數的宣告恰好一處（%d）" % ratio_decl, ratio_decl == 1)
	_cell("_test_p6b_static_cross_evidence")


# ══ P7：守恆 ＋ 兩個 tag（§7 P7）════════════════════════════════════════════
func _test_p7_conservation_with_tags() -> void:
	print("\n── P7 守恆與 tag ──")
	var st: WorldState = _fresh()
	var ids: Array = _two_npcs(st)
	var taker: TeamData = st.teams[ids[0]]
	var payer: TeamData = st.teams[ids[1]]
	ResourceBank.set_amt(payer, "coin", 400.0, "bed_fixture")
	ResourceBank.set_amt(taker, "coin", 100.0, "bed_fixture")
	var total_before: float = CoinAudit.total(st)
	var payer_before: float = float(payer.resources.get("coin", 0))
	var taker_before: float = float(taker.resources.get("coin", 0))
	var amount: float = DiplomaticAiSystem.apply_tribute_accept(st, payer, taker)
	var payer_after: float = float(payer.resources.get("coin", 0))
	var taker_after: float = float(taker.resources.get("coin", 0))
	print("   payer %.3f → %.3f（-%.3f）｜taker %.3f → %.3f（+%.3f）｜amount %.3f" % [
		payer_before, payer_after, payer_before - payer_after,
		taker_before, taker_after, taker_after - taker_before, amount])
	print("   全域 coin 總量 %.3f → %.3f" % [total_before, CoinAudit.total(st)])
	_check("★★拿走 ＝ 給出（%.6f vs %.6f）" % [payer_before - payer_after, taker_after - taker_before],
		absf((payer_before - payer_after) - (taker_after - taker_before)) < 0.000001)
	_check("★★★全域總量不變（只是搬動）", absf(CoinAudit.total(st) - total_before) < 0.000001)
	# tag 的靜態證（兩個 tag 都要出現在共用解算點裡）
	var dip_code: String = _code_only(FileAccess.get_file_as_string(
		"res://scripts/simulation/diplomatic_ai_system.gd"))
	_check("★兩個 tag 都在共用解算點裡（`%s`／`%s`）" % [SPEC_TAG_OUT, SPEC_TAG_IN],
		dip_code.contains(SPEC_TAG_OUT) and dip_code.contains(SPEC_TAG_IN))
	_cell("_test_p7_conservation_with_tags")


# ══ P8a：小額 ⇒ 好感動、feud 邊仍然 0（§9③ 拆開的那一半）═══════════════════════
# ★★★逐欄印 aff_before／aff_after ＋ 斷言降幅 ≥ 由 severity 算出的預期下限
#   （§9②：好感可能已經很負而降幅趨近 0，只斷言「有降」會誤判通過）。
func _test_p8a_small_moves_affinity_not_memory() -> void:
	print("\n── P8a 小額（這條路的真實 severity）⇒ 好感動、記憶不動 ──")
	var st: WorldState = _fresh()
	var ids: Array = _two_npcs(st)
	var taker: TeamData = st.teams[ids[0]]
	var payer: TeamData = st.teams[ids[1]]
	ResourceBank.set_amt(payer, "coin", 500.0, "bed_fixture")
	var payer_leader: PersonData = st.persons.get(payer.leader_id)
	var coin_before: float = float(payer.resources.get("coin", 0))
	var aff_before: float = _affinity(payer_leader, taker.leader_id)
	var feud_before: float = _feud(payer_leader, taker.leader_id)
	var amount: float = DiplomaticAiSystem.apply_tribute_accept(st, payer, taker)
	var severity: float = amount / coin_before
	var aff_after: float = _affinity(payer_leader, taker.leader_id)
	var feud_after: float = _feud(payer_leader, taker.leader_id)
	# 預期下限：好感層的係數是 -intensity × 0.5（`_update_relations` 的 "tributed" 那一列）
	var expect_drop: float = severity * 0.5
	print("   ★實際進公式的 severity ＝ amount/coin_before ＝ %.4f（量出來的，不是抄的）" % severity)
	print("   aff_before ＝ %+.4f｜aff_after ＝ %+.4f｜降幅 %.4f（預期下限 %.4f）" % [
		aff_before, aff_after, aff_before - aff_after, expect_drop])
	print("   feud 邊 %.4f → %.4f｜FEUD_MIN ＝ %.2f（severity×人格上界 1.3 ＝ %.4f）" % [
		feud_before, feud_after, NpcAiSystem.FEUD_MIN, severity * 1.3])
	_check("★母體地板：severity 真的是那條路的比例（> 0）", severity > 0.0)
	_check("★★★好感下降【且】降幅 ≥ 由 severity 算出的預期下限（不是只看「有降」）",
		aff_after < aff_before and (aff_before - aff_after) >= expect_drop - 0.000001)
	_check("★★★feud 邊仍然是 0（小事不入記憶；這條路的 %.4f < FEUD_MIN %.2f）" % [
		severity * 1.3, NpcAiSystem.FEUD_MIN], feud_after == 0.0)
	_cell("_test_p8a_small_moves_affinity_not_memory")


# ══ P8b：大額 ⇒ 兩層都動（§9③ 的另一半，證門檻在這條路上是活的）═══════════════
# ★誠實限：現行 ratio 0.1 這條路到不了門檻 ⇒ 本格對**同一支寫入者**餵大 severity。
#   ⇒ 它證的是「門檻與兩層在這個寫入者上都是活的」，不是「這條路今天會寫邊」。
func _test_p8b_large_moves_both_layers() -> void:
	print("\n── P8b 大額 ⇒ 兩層都動（同一支寫入者，餵大 severity）──")
	var ai := NpcAiSystem.new()
	var victim := PersonData.new()
	victim.id = 8801
	victim.values = {"義氣": 0.9, "好戰": 0.9}
	var aff0: float = _affinity(victim, 55)
	var feud0: float = _feud(victim, 55)
	ai.write_memory(victim, "tributed", 55, 0, 0.9)   # ★大 severity
	print("   餵 severity 0.9｜好感 %+.4f → %+.4f｜feud 邊 %.4f → %.4f" % [
		aff0, _affinity(victim, 55), feud0, _feud(victim, 55)])
	_check("★★★大額：好感動了", _affinity(victim, 55) < aff0)
	_check("★★★大額：feud 邊出現了（門檻在這個寫入者上是活的）", _feud(victim, 55) > 0.0)
	print("   ★而這條路今天的 severity 是 %.2f（ratio）⇒ ×人格上界 1.3 ＝ %.3f < FEUD_MIN %.2f" % [
		DiplomaticAiSystem.TRIBUTE_TAKE_RATIO,
		DiplomaticAiSystem.TRIBUTE_TAKE_RATIO * 1.3, NpcAiSystem.FEUD_MIN])
	print("     ⇒ 所以 P8a 的「邊仍然 0」是**正確行為**，不是門檻沒接上。")
	_cell("_test_p8b_large_moves_both_layers")


# ══ P9：連索序列 ⇒ 某一次開始拒絕（★不釘第幾次，序列進卷面）═════════════════════
func _test_p9_sequence_starts_refusing() -> void:
	print("\n── P9 連索 %d 次的序列 ──" % SPEC_SEQUENCE_N)
	var st: WorldState = _fresh()
	var ids: Array = _two_npcs(st)
	var taker: TeamData = st.teams[ids[0]]
	var payer: TeamData = st.teams[ids[1]]
	taker.tile_pos = payer.tile_pos   # ★同格（NPC 側外交的不變量：嚴禁非同格）
	ResourceBank.set_amt(payer, "coin", 5000.0, "bed_fixture")
	var payer_leader: PersonData = st.persons.get(payer.leader_id)
	# ★★★人格要【釘死】（同 spam-brake 已 CLEAN 的 P2′ 那一格的理由）：
	#   第一版沒釘 ⇒ 20 次【全部 refuse】⇒ 母體地板紅，而那不是煞車生效，
	#   是這個被索方本來就不屈服（屈服公式的 base 太低）⇒ 序列什麼都沒證。
	#   ⇒ 釘死之後第一次 accept，而後面的拒絕才是【好感被扣出來的】。
	#   ★這一組值與 spam-brake 那支床同一組（不是我這裡另挑的）。
	for k2 in PINNED_LEADER.keys():
		payer_leader.values[k2] = float(PINNED_LEADER[k2])
	payer_leader.fear = PINNED_FEAR
	print("   ★釘死被索方領袖人格：%s｜fear %.2f" % [str(PINNED_LEADER), payer_leader.fear])
	var dip := DiplomaticAiSystem.new()
	var accepts: int = 0
	var refuses: int = 0
	var first_refuse: int = -1
	for i in range(SPEC_SEQUENCE_N):
		var coin_before: float = float(payer.resources.get("coin", 0))
		var resp: String = dip.handle_diplomacy_message(st, payer, taker, "demand_tribute")
		var took: float = 0.0
		if resp == "accept":
			took = DiplomaticAiSystem.apply_tribute_accept(st, payer, taker)
			accepts += 1
		else:
			refuses += 1
			if first_refuse == -1:
				first_refuse = i + 1
		print("   #%2d %-7s｜coin_before %8.1f｜拿走 %6.2f｜好感 %+.4f" % [
			i + 1, resp, coin_before, took, _affinity(payer_leader, taker.leader_id)])
	print("   accept %d 次／refuse %d 次｜第一次 refuse ＝ %s" % [
		accepts, refuses, str(first_refuse)])
	_check("★母體地板：第一次是 accept（一開始就拒絕的話這條序列什麼都沒證）", accepts > 0)
	_check("★★★連索之後開始拒絕（★不釘第幾次 —— 序列在上面）", refuses > 0)
	print("   ★而煞車的載體是好感：它每一次都往下 ⇒ `tribute_accept` 讀它（濫按煞車那票接的電）。")
	_cell("_test_p9_sequence_starts_refusing")


func _initialize() -> void:
	print("=== npc_tribute_transfer bed ===")
	_test_p6a_amount_is_the_shared_formula()
	_test_p6b_static_cross_evidence()
	_test_p7_conservation_with_tags()
	_test_p8a_small_moves_affinity_not_memory()
	_test_p8b_large_moves_both_layers()
	_test_p9_sequence_starts_refusing()
	var miss: Array = []
	for c in EXPECTED_CELLS:
		if not _cells_ran.has(c):
			miss.append(c)
	if not miss.is_empty():
		_errors += miss.size()
		push_error("[FAIL] 缺席的格：%s" % str(miss))
	print("\n=== npc_tribute_transfer DONE === errors: %d｜到場點名 %d／%d" % [
		_errors, _cells_ran.size(), EXPECTED_CELLS.size()])
	quit(1 if _errors > 0 else 0)
