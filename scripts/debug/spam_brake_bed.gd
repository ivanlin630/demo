extends SceneTree
# @bed-kind: acceptance
# slice: 濫按索貢的煞車 ＝ 好感層（兩層關係帳版，spec 2026-09-30 §9／§10／§11）
#
# ★★★用戶裁的那一句（逐字）：「小恩小怨的直接在好感做加減 不入記憶 大恩大怨才入記憶」
#   ⇒ 兩層：【好感】p.relations（有號標量、小事、線性、不記原因）
#           【記憶】typed 邊（過 FEUD_MIN 才寫、帶原因、可被復仇消費）
#   ⇒ 本票把 "tributed" 這個新名字【同時接上兩層】，而索貢的嚴重度
#     （遠程 0.1／同格 0.25）× 人格乘子幾乎一定不過門檻 ⇒ **不寫邊是正確行為**。
#
# ★★這支床最容易自己騙自己的地方，是 P2 那一格【第幾次翻】：
#   ·門檻比的是【累計好感】不是【單次 delta】⇒ 床要印序列，不要只印最後一個值
#   ·而「20 次裡至少一次拒絕」在一個 score 太高的世界裡永遠不會發生
#     ⇒ ★★★所以 P2 的母體地板有三道：coin_before 每次 > 0／印 score_no_edge（帶除數）／
#       ★領袖人格【釘死】＋床自己算出理論上第幾次翻再跟實測序列對一次。
#     ⇒ 兩行自相矛盾就是紅燈。
#
# ★誠實限：
#   1. P2 走 PlayerCommandSystem.execute_action（第三條管道本身），不經 UI、不推 tick
#      ⇒ 它量的是【那條路的決策與寫入】，不是「玩家按 20 次的畫面」。
#   2. 好感衰減（會回中）**本票不做**（藍圖裁另票）⇒ P3b 是【兩向格】：
#      衰減落地時**改斷言不要刪格**。
#   3. 理論次數用的常數是從 code 讀的（RELATION_W_AFFINITY／TRIBUTE_ACCEPT_THRESHOLD），
#      而 base 與每次 delta 是【量出來的】—— ★不手抄物理。

var _errors: int = 0
var _cells_ran: Array = []

# ★spec §11c 要求印在卷面上的那兩句（分開講：在清單裡／在清單裡的理由）
const SPEC_FP_FIELD: String = "relations"
const SPEC_DIRECT_READERS: Array = [
	["res://scripts/simulation/npc_ai_system.gd", "p.relations.get(subject_id"],
	["res://scripts/simulation/diplomatic_ai_system.gd", "leader.relations.get(other_leader_id"],
]
# ★釘死的領袖人格（母體地板 c）：不允許用預設／「典型」值 —— 那會讓第幾次翻無主詞。
const PINNED: Dictionary = {"慎重": 0.6, "義氣": 0.3, "求生欲": 0.3, "好戰": 0.2}
const PINNED_FEAR: float = 0.05
const SPAM_PRESSES: int = 20

const EXPECTED_CELLS: Array = [
	"_test_p0_affinity_is_already_in_the_ruler",
	"_test_p1_small_tribute_moves_affinity_not_memory",
	"_test_p2_spam_sequence_flips_to_refuse",
	"_test_p3b_no_decay_yet",
	"_test_p4_npc_vs_npc_walks_the_same_path",
	"_test_p5_two_tiers_do_not_cross",
	"_test_p7_affinity_has_its_own_population",
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

# ★★★世界一律走 `MeasureBedHelper.arm_and_new()`（bed-arm 閘）：
#   ★閘的母體就是【`WorldState.new()` 的呼叫檔】⇒ 自己 new 會讓「未涵蓋」+1，
#     而我第一版就是這樣寫的 ⇒ 電池那一格 ✗，且它指名了是我這支床。
#   ★★白名單不是出路（那份檔的檔頭逐字寫「新增床不得加進來」）。
#   ★★★而 arm 必須在 setup 【之前】—— 它就是這支閘在守的事：
#     setup 之後才 arm ⇒ 那段世界的 tap 是盲的（而卷面上看不出來）。
func _fresh() -> Array:
	seed(20260930)
	var st: WorldState = MeasureBedHelper.arm_and_new()
	GameSetup.setup(st, GameSetup.load_config("res://config/warring_states.json"))
	return [st, PlayerCommandSystem.new()]

# 佈置一個【同格、人口夠、有 coin、領袖人格釘死】的索貢目標。回 [target_id, tgt, leader]
func _prep_target(st: WorldState, pt: TeamData, coin: float) -> Array:
	var tid: int = -1
	for k in st.teams.keys():
		if int(k) != pt.team_id and st.teams[k].leader_id != -1:
			tid = int(k)
			break
	var tgt: TeamData = st.teams[tid]
	tgt.tile_pos = pt.tile_pos          # ★同格（同格閘 2026-09-30 之後這是前提）
	tgt.resources["coin"] = coin
	# ★索貢的前提是【玩家人口 > 對方 ×1.5】，而 population 是計算屬性不能直寫
	#   ⇒ 走合法路徑：把對方的匿名人口搬掉（★假裝把自己變大會被靜默吞掉）
	while tgt.population > 1 and float(pt.population) <= float(tgt.population) * 1.5:
		if AnonTierSystem.remove_anon(tgt, AnonCohort.TIER_PLEB, 1) <= 0:
			break
	var leader: PersonData = st.persons.get(tgt.leader_id)
	for k in PINNED.keys():
		leader.values[k] = float(PINNED[k])
	leader.fear = PINNED_FEAR
	return [tid, tgt, leader]

func _affinity(leader: PersonData, toward_id: int) -> float:
	return float(leader.relations.get(toward_id, 0.0))

func _feud_to(leader: PersonData, toward_id: int) -> float:
	return RelationGraph.intensity_to(leader.relation_edges, "feud", toward_id)


# ══ P0：好感【已經在尺裡】—— spec §11c 的那兩句要分開講 ════════════════════
# ★★★systems 原本的 §9b⑤ 要我把 person.relations 接進 fingerprint，而 R² 二輪推翻它：
#   那個欄位已經被【機器維護的全集】收進去了（手寫骸架那一條只有 faction 的）
#   ⇒ 再接一次會讓同一個欄位在 fp 字串裡出現兩次、而且兩次格式不同 ＝ **弄壞尺**。
# ★而這一格把那條推理鏈釘成一行實測，並且【把兩句話分開】：
#   ①relations 在清單裡（實測）
#   ②它在清單裡的【理由】是兩個直接讀取點，★不是 in_ruler 那條子字串規則
#     —— 那條規則是 src.contains("." + n)，它會多報（.foo_cache 也算），
#        而工具檔頭自己登記了這件事（「代理是超集 ⇒ 多守不是錯守」）。
#     ⇒ ★★★不分開講的話，下一個人會以為【子字串規則本身】可以當證據用。
func _test_p0_affinity_is_already_in_the_ruler() -> void:
	print("\n── P0 好感已經在尺裡（spec §11c 的兩句）──")
	var fields: Array = FpCoverage.fields_for("PersonData")
	print("   FpCoverage.fields_for(PersonData) 共 %d 欄" % fields.size())
	print("   ①【%s 在清單裡】＝ %s" % [SPEC_FP_FIELD, str(fields.has(SPEC_FP_FIELD))])
	_check("★①relations 真的在 fp 的欄位清單裡（不在 ⇒ 回報，不要自己加 tap）",
		fields.has(SPEC_FP_FIELD))
	var direct: int = 0
	for row in SPEC_DIRECT_READERS:
		var src: String = FileAccess.get_file_as_string(String(row[0]))
		var hit: bool = src.contains(String(row[1]))
		print("   ②直接讀取點 %s ⇒ `%s` %s" % [
			String(row[0]).get_file(), String(row[1]), "在" if hit else "★不在"])
		if hit:
			direct += 1
	_check("★★②【它在清單裡的理由是直接讀取點】：%d／%d 個決策層讀取點逐字在位" % [
		direct, SPEC_DIRECT_READERS.size()], direct == SPEC_DIRECT_READERS.size())
	print("   ★★★而這兩句刻意分開：in_ruler 的判準是 src.contains(\".\" + n)（子字串）")
	print("     ⇒ 它會【多報】（某處寫 .relations_cache 也算）⇒ 方向安全但不是證據；")
	print("     撐②的是上面那兩個【真的把值讀進決策】的點。")
	_cell("_test_p0_affinity_is_already_in_the_ruler")


# ══ P1′：小索貢 ⇒ 好感動、記憶【不動】════════════════════════════════════
# ★印【實際進公式的 severity】而不是我以為的那個：它＝(coin_before − coin_after)／coin_before
#   —— 量出來的，不是抄 * 0.1 那一行（抄的那份會與世界漂開）。
# 負對照：拿掉 _update_relations 的 "tributed" 那一列（delta = 0）⇒ 本格 9 處紅 ⇒ 已於 feat/spam-brake（2026-09-30 這一輪） 實測紅
# 負對照：把 "tributed": 0.30 加進 FEUD_SEVERITY ⇒ 本檔 P1 的表格斷言＋P5′ 小事那一格紅 ⇒ 已於 feat/spam-brake（2026-09-30 這一輪） 實測紅
#   （它守的是【誰的值被讀】：.get(type, intensity) 讓「把名字加進表」同時打破
#     「拿走幾成」與「兩層分界」，而卷面上沒有其他差別。）
func _test_p1_small_tribute_moves_affinity_not_memory() -> void:
	print("\n── P1′ 小索貢：好感動、feud 邊不動 ──")
	var arr: Array = _fresh()
	var st: WorldState = arr[0]
	var cmd: PlayerCommandSystem = arr[1]
	var pt: TeamData = st.teams.get(st.get_player_team_id())
	var prep: Array = _prep_target(st, pt, 500.0)
	var tid: int = prep[0]
	var tgt: TeamData = prep[1]
	var leader: PersonData = prep[2]
	_check("★母體地板 A：真的同格（不同格的話拒絕來自同格閘不是好感）", pt.tile_pos == tgt.tile_pos)
	_check("★母體地板 B：索貢前提真的成立（玩家 pop > 對方 ×1.5）",
		float(pt.population) > float(tgt.population) * 1.5)
	var honor: float = float(leader.values.get("義氣", 0.5))
	var bell: float = float(leader.values.get("好戰", 0.5))
	var factor: float = NpcAiSystem.FEUD_BASE_FACTOR + honor * NpcAiSystem.FEUD_HONOR_W \
		+ bell * NpcAiSystem.FEUD_BELLIGERENCE_W
	var coin_before: float = float(tgt.resources.get("coin", 0))
	var aff_before: float = _affinity(leader, pt.leader_id)
	var feud_before: float = _feud_to(leader, pt.leader_id)
	var r: Dictionary = cmd.execute_action(st, tid, "demand_tribute")
	var coin_after: float = float(tgt.resources.get("coin", 0))
	var sev: float = (coin_before - coin_after) / maxf(coin_before, 0.0001)
	var aff_after: float = _affinity(leader, pt.leader_id)
	var feud_after: float = _feud_to(leader, pt.leader_id)
	print("   ok=%s msg=%s" % [str(r.get("ok", "?")), String(r.get("msg", ""))])
	print("   coin %.1f → %.1f｜★實際進公式的 severity ＝ %.4f（量出來的比例，不是抄的）" % [
		coin_before, coin_after, sev])
	print("   領袖人格：義氣 %.2f／好戰 %.2f ⇒ factor %.3f ⇒ 記憶層 intensity %.4f（門檻 %.2f）" % [
		honor, bell, factor, sev * factor, NpcAiSystem.FEUD_MIN])
	print("   好感 %.4f → %.4f｜feud 邊 %.4f → %.4f" % [
		aff_before, aff_after, feud_before, feud_after])
	_check("★母體地板 C：索貢真的成功了（失敗的話好感沒動是因為什麼都沒發生）",
		bool(r.get("ok", false)) and coin_after < coin_before)
	_check("★★★好感【下降】（小事直接在好感做加減）", aff_after < aff_before)
	_check("★★★feud 邊【仍然是 0】（小事不入記憶＝用戶逐字）", feud_after == 0.0)
	_check("★而它不過門檻是【算得出來的】：severity×factor %.4f < FEUD_MIN %.2f" % [
		sev * factor, NpcAiSystem.FEUD_MIN], sev * factor < NpcAiSystem.FEUD_MIN)
	# ★★★這一格是【負對照 b 教我加的】：把 "tributed" 加進 FEUD_SEVERITY 之後，
	#   本格的其他斷言【全部照舊綠】—— 因為這個領袖太溫和（factor 0.490）：
	#   0.30 × 0.490 ＝ 0.147 仍然不過門檻 ⇒ 邊還是 0。
	#   ⇒ 真的接住那個擾動的是 P5′（義氣/好戰 0.9 ⇒ factor 1.19 ⇒ 0.357 過門檻）。
	#   ★而「拿走幾成到不到得了記憶層」這件事本身應該在【這裡】有一格，
	#     因為它是 P1′ 的主題（severity ＝ 比例，不是表裡的固定值）：
	print("   ★FEUD_SEVERITY 裡有沒有 tributed ＝ %s（表裡有 ⇒ `.get(type, intensity)` 會把比例換成固定值）"
		% str(NpcAiSystem.FEUD_SEVERITY.has("tributed")))
	_check("★★★`tributed` 不在 FEUD_SEVERITY 表裡 ⇒ 進 form_feud 的 severity 是【這一次拿走幾成】"
		+ "（進表的話十次小索貢與一次大索貢會同值，而卷面上沒有其他差別）",
		not NpcAiSystem.FEUD_SEVERITY.has("tributed"))
	_cell("_test_p1_small_tribute_moves_affinity_not_memory")


# ══ P2′：連索 20 次 ⇒ 某一次開始被拒（★不釘第幾次，印序列）═════════════════
# ★★★母體地板三道（審查裁定：這一格在賭，而賭得比想的兇）：
#   (a) coin_before 每一次都 > 0（否則 refuse 是「沒錢可拿」不是「結怨」）
#   (b) 印 score_no_edge，★而且印【除數】—— 門檻要比每次的平均值，不是比累計
#       （這是「112 個 tick 累計 56 秒直接跟 1000ms 比」那個誤判的形狀）
#   (c) ★領袖人格釘死 ＋ 床自己算出【理論上第幾次翻】再跟實測序列對一次
# 負對照：拿掉 tribute_accept 的好感項（score += 0.0）⇒ 20／20 全 accept、4 處紅 ⇒ 已於 feat/spam-brake（2026-09-30 這一輪） 實測紅
func _test_p2_spam_sequence_flips_to_refuse() -> void:
	print("\n── P2′ 連索 %d 次的序列 ──" % SPAM_PRESSES)
	var arr: Array = _fresh()
	var st: WorldState = arr[0]
	var cmd: PlayerCommandSystem = arr[1]
	var pt: TeamData = st.teams.get(st.get_player_team_id())
	var prep: Array = _prep_target(st, pt, 5000.0)
	var tid: int = prep[0]
	var tgt: TeamData = prep[1]
	var leader: PersonData = prep[2]
	var pinned_ok: bool = true
	for k in PINNED.keys():
		if absf(float(leader.values.get(k, -9.0)) - float(PINNED[k])) > 0.0001:
			pinned_ok = false
	print("   ★釘死的領袖人格：%s｜fear %.2f" % [str(PINNED), leader.fear])
	_check("★★母體地板 (c)：領袖人格真的被釘住（用預設值 ⇒ 第幾次翻沒有主詞）", pinned_ok)
	var accepts: Array = []
	var refuses: Array = []
	var first_refuse: int = -1
	var aff_seq: Array = []
	var feud_seq: Array = []
	var base_score: float = 0.0
	var per_press_delta: float = 0.0
	var coin_floor_ok: bool = true
	var monotone_ok: bool = true
	var prev_aff: float = _affinity(leader, pt.leader_id)
	var prev_sum: float = Probe.amount("tribute.score_no_edge_sum")
	var prev_n: int = int(Probe.counts.get("rel.tribute_eval", 0))
	for i in range(SPAM_PRESSES):
		var coin_before: float = float(tgt.resources.get("coin", 0))
		if coin_before <= 0.0:
			coin_floor_ok = false
		var r: Dictionary = cmd.execute_action(st, tid, "demand_tribute")
		var ok: bool = bool(r.get("ok", false))
		var aff: float = _affinity(leader, pt.leader_id)
		var feud_i: float = _feud_to(leader, pt.leader_id)
		var sum_now: float = Probe.amount("tribute.score_no_edge_sum")
		var n_now: int = int(Probe.counts.get("rel.tribute_eval", 0))
		var evals: int = n_now - prev_n
		var sne: float = (sum_now - prev_sum) / maxf(float(evals), 1.0)
		print("   #%2d %s｜好感 %+.4f｜feud_i %.4f｜coin_before %7.1f｜score_no_edge %+.4f（除數 %d 次評估）" % [
			i + 1, "accept" if ok else "REFUSE", aff, feud_i, coin_before, sne, evals])
		if aff > prev_aff + 0.0001:
			monotone_ok = false
		if i == 0:
			base_score = sne
			per_press_delta = aff - prev_aff
		if ok:
			accepts.append(i + 1)
		else:
			refuses.append(i + 1)
			if first_refuse == -1:
				first_refuse = i + 1
		aff_seq.append(aff)
		feud_seq.append(feud_i)
		prev_aff = aff
		prev_sum = sum_now
		prev_n = n_now
	# ★理論上第幾次翻：常數從 code 讀、base 與 delta 是量出來的（★不手抄物理）
	var w: float = DiplomaticAiSystem.RELATION_W_AFFINITY
	var thresh: float = DiplomaticAiSystem.TRIBUTE_ACCEPT_THRESHOLD
	# ★XB §2（2026-10-07，藍圖 324b9041f 怨要累積）：同一施加者一季內的 tributed 加總過門檻 ⇒ 結成 feud 邊，
	#   而 tribute_accept 會扣 feud_i × TRIBUTE_W_FEUD ⇒ 理論式要把【量到的】feud 強度一起算進來
	#   （第 k 次評估時讀到的 feud ＝ 第 k−1 次之後量到的那個值）；權重照舊從 code 讀，不手抄
	var w_feud: float = DiplomaticAiSystem.TRIBUTE_W_FEUD
	var theory: int = -1
	for k in range(1, SPAM_PRESSES + 1):
		var f_k: float = float(feud_seq[k - 2]) if k >= 2 else 0.0
		if base_score + per_press_delta * float(k - 1) * w - f_k * w_feud <= thresh:
			theory = k
			break
	print("   ★★理論：base %+.4f（第 1 次量到的 score_no_edge）／每次好感 delta %+.4f" % [
		base_score, per_press_delta])
	print("     ／權重 %.3f（code 常數）／怨邊權重 %.3f（code 常數，乘量到的 feud_i）／門檻 %.3f（code 常數）⇒ 理論上第 %s 次翻" % [
		w, w_feud, thresh, str(theory)])
	print("   實測：accept %d 次、refuse %d 次｜第一次 refuse ＝ %s" % [
		accepts.size(), refuses.size(), str(first_refuse)])
	_check("★母體地板 (a)：coin_before 每一次都 > 0（拒絕不是因為沒錢可拿）", coin_floor_ok)
	_check("★★★①第 1 次是 accept（煞車不能一開始就踩死）",
		accepts.size() > 0 and int(accepts[0]) == 1)
	_check("★★★②好感單調不增（%d 個值）" % aff_seq.size(), monotone_ok)
	_check("★★★③%d 次裡至少出現一次 refuse（0 次 ⇒ 煞車沒接上，或 score 太高）" % SPAM_PRESSES,
		refuses.size() > 0)
	var sticky: bool = true
	if first_refuse != -1:
		for k in range(first_refuse, SPAM_PRESSES + 1):
			if accepts.has(k):
				sticky = false
	_check("★★★④第一次 refuse 之後【不再】accept（沒有衰減 ⇒ 永久）", sticky)
	_check("★★母體地板 (c) 的第二半：理論次數 %s 與實測第一次 refuse %s 一致（★兩行自相矛盾＝紅燈）" % [
		str(theory), str(first_refuse)], theory == first_refuse)
	print("   ★這條序列本身是【衰減那張票的基線】⇒ 它進卷面，而第幾次翻不釘成斷言。")
	_cell("_test_p2_spam_sequence_flips_to_refuse")


# ══ P3b：拒絕之後推三天 ⇒ 仍然拒絕（沒有衰減＝永久）═══════════════════════
# ★這是【兩向格】：衰減那張票落地時**改斷言不要刪格** —— 刪掉的話
#   「永久」與「衰減」之間的那一刀就沒有任何一格在守。
func _test_p3b_no_decay_yet() -> void:
	print("\n── P3b 三天之後仍然拒絕（本票沒有衰減）──")
	var arr: Array = _fresh()
	var st: WorldState = arr[0]
	var cmd: PlayerCommandSystem = arr[1]
	var pt: TeamData = st.teams.get(st.get_player_team_id())
	var prep: Array = _prep_target(st, pt, 5000.0)
	var tid: int = prep[0]
	var leader: PersonData = prep[2]
	var first_refuse: int = -1
	for i in range(SPAM_PRESSES):
		var r: Dictionary = cmd.execute_action(st, tid, "demand_tribute")
		if not bool(r.get("ok", false)):
			first_refuse = i + 1
			break
	print("   第一次 refuse 在第 %s 次｜好感 %+.4f" % [
		str(first_refuse), _affinity(leader, pt.leader_id)])
	_check("★母體地板：真的先拒絕過一次（沒拒絕過的話這一格什麼都沒驗）", first_refuse != -1)
	var aff_at_refuse: float = _affinity(leader, pt.leader_id)
	st.world.current_tick += WorldState.TICKS_PER_DAY * 3
	var r2: Dictionary = cmd.execute_action(st, tid, "demand_tribute")
	print("   推 3 天（tick %d）之後再索：ok=%s｜好感 %+.4f" % [
		st.world.current_tick, str(r2.get("ok", "?")), _affinity(leader, pt.leader_id)])
	_check("★★★仍然拒絕（★兩向格：衰減落地時改這一句，不要刪這一格）",
		not bool(r2.get("ok", false)))
	_check("★好感沒有自己回中（本票不做衰減）",
		absf(_affinity(leader, pt.leader_id) - aff_at_refuse) < 0.0001)
	_cell("_test_p3b_no_decay_yet")


# ══ P4：NPC↔NPC 同格勒索也走同一條路（玩家零特殊物理）═══════════════════
# 負對照：把寫入只掛在玩家那一支（同格勒索那半拿掉）⇒ 本格紅 ⇒ 已於 feat/spam-brake（2026-09-30 這一輪） 實測紅
func _test_p4_npc_vs_npc_walks_the_same_path() -> void:
	print("\n── P4 NPC↔NPC 同格勒索走同一條路 ──")
	var arr: Array = _fresh()
	var st: WorldState = arr[0]
	var pt_id: int = st.get_player_team_id()
	var ids: Array = []
	for k in st.teams.keys():
		if int(k) != pt_id and st.teams[k].leader_id != -1:
			ids.append(int(k))
		if ids.size() >= 2:
			break
	var atk: TeamData = st.teams[ids[0]]
	var def: TeamData = st.teams[ids[1]]
	def.tile_pos = atk.tile_pos
	def.resources["coin"] = 400.0
	var def_leader: PersonData = st.persons.get(def.leader_id)
	print("   Team%d 勒索 Team%d（玩家 Team%d 不在場）" % [ids[0], ids[1], pt_id])
	_check("★母體地板：這兩隊都不是玩家隊（玩家在場的話這一格測的是另一條路）",
		int(ids[0]) != pt_id and int(ids[1]) != pt_id)
	var aff_before: float = _affinity(def_leader, atk.leader_id)
	var inter := InteractionSystem.new()
	inter.call("_resolve_extortion", st, int(ids[0]), int(ids[1]))
	var aff_after: float = _affinity(def_leader, atk.leader_id)
	print("   被勒索方領袖對勒索方的好感 %+.4f → %+.4f｜feud 邊 %.4f" % [
		aff_before, aff_after, _feud_to(def_leader, atk.leader_id)])
	_check("★★★NPC↔NPC 也寫好感（玩家零特殊物理：兩邊走同一支 _resolve_extortion）",
		aff_after < aff_before)
	_cell("_test_p4_npc_vs_npc_walks_the_same_path")


# ══ P5′：兩層不串 ═════════════════════════════════════════════════════════
# 大事（severity 0.9）⇒ 邊有了【且】好感也動；小事（0.1）⇒ 只有好感動、邊仍 0
# 負對照：把 _update_relations 搬到門檻後面（只有寫得出邊才寫好感）⇒ 7 處紅 ⇒ 已於 feat/spam-brake（2026-09-30 這一輪） 實測紅
#   （★這就是「門檻下零丟棄」的守衛。）
func _test_p5_two_tiers_do_not_cross() -> void:
	print("\n── P5′ 兩層不串（大事進記憶、小事只進好感）──")
	var ai := NpcAiSystem.new()
	var big := PersonData.new()
	big.id = 9001
	big.values = {"義氣": 0.9, "好戰": 0.9}
	ai.write_memory(big, "tributed", 55, 0, 0.9)
	var big_aff: float = _affinity(big, 55)
	var big_edge: float = _feud_to(big, 55)
	print("   大事 severity 0.9 ⇒ 好感 %+.4f／feud 邊 %.4f" % [big_aff, big_edge])
	_check("★★★大事：feud 邊【有了】（過得了門檻的才入記憶）", big_edge > 0.0)
	_check("★★★大事：好感【也】動了（門檻之上兩層都動，不是二選一）", big_aff < 0.0)
	var small := PersonData.new()
	small.id = 9002
	small.values = {"義氣": 0.9, "好戰": 0.9}   # ★人格與大事那顆相同 ⇒ 差別只剩 severity
	ai.write_memory(small, "tributed", 55, 0, 0.1)
	var small_aff: float = _affinity(small, 55)
	var small_edge: float = _feud_to(small, 55)
	print("   小事 severity 0.1 ⇒ 好感 %+.4f／feud 邊 %.4f（同一個人格）" % [small_aff, small_edge])
	_check("★★★小事：好感動了（門檻下【零丟棄】）", small_aff < 0.0)
	_check("★★★小事：feud 邊仍然 0（小事不入記憶）", small_edge == 0.0)
	_check("★兩層的量級不同：大事好感 %.4f【比】小事 %.4f 更深（比例進得去公式）" % [
		big_aff, small_aff], big_aff < small_aff)
	_cell("_test_p5_two_tiers_do_not_cross")


# ══ P7′：好感層自己的母體 ═════════════════════════════════════════════════
# ★★★好感一直有人在寫，而它【從來沒有任何 tap】⇒ 這不是本票製造的盲點，是本票照到的。
#   ⇒ 沒有這個計數，「改進好感的那些事」在量測上完全不存在（全量暫態可觀測性）。
# 負對照：把 Probe.bump("affinity.delta." + type) 拿掉 ⇒ 本格紅 ⇒ 已於 feat/spam-brake（2026-09-30 這一輪） 實測紅
func _test_p7_affinity_has_its_own_population() -> void:
	print("\n── P7′ 好感層有自己的母體（affinity.delta.<type>）──")
	var ai := NpcAiSystem.new()
	var p := PersonData.new()
	p.id = 9101
	var before: int = int(Probe.counts.get("affinity.delta.tributed", 0))
	ai.write_memory(p, "tributed", 77, 0, 0.2)
	var after: int = int(Probe.counts.get("affinity.delta.tributed", 0))
	print("   Probe.enabled=%s｜affinity.delta.tributed %d → %d" % [str(Probe.enabled), before, after])
	_check("★母體地板：Probe 真的開著（沒開的話這一格量的是 0 vs 0）", Probe.enabled)
	_check("★★★好感的改動【被數到了】（這一族原本一個 tap 都沒有）", after > before)
	var zero := PersonData.new()
	zero.id = 9102
	var z_before: int = int(Probe.counts.get("affinity.delta.unknown_type_xyz", 0))
	ai.write_memory(zero, "unknown_type_xyz", 77, 0, 0.2)
	var z_after: int = int(Probe.counts.get("affinity.delta.unknown_type_xyz", 0))
	print("   ★零值不計：不認得的名字 delta＝0 ⇒ 計數 %d → %d" % [z_before, z_after])
	_check("★★零 delta 不進母體（否則 _ 那一支會把母體灌滿，而母體就不再是【好感真的動了幾次】）",
		z_after == z_before)
	_cell("_test_p7_affinity_has_its_own_population")


func _initialize() -> void:
	# ★這一支 arm 是給【不建世界】的那幾格用的（P5′／P7′ 直接呼 write_memory）——
	#   建世界的格走 `_fresh()` ⇒ `MeasureBedHelper.arm_and_new()`（arm 在 setup 之前）。
	Probe.arm()
	print("=== spam_brake bed ===")
	_test_p0_affinity_is_already_in_the_ruler()
	_test_p1_small_tribute_moves_affinity_not_memory()
	_test_p2_spam_sequence_flips_to_refuse()
	_test_p3b_no_decay_yet()
	_test_p4_npc_vs_npc_walks_the_same_path()
	_test_p5_two_tiers_do_not_cross()
	_test_p7_affinity_has_its_own_population()
	var miss: Array = []
	for c in EXPECTED_CELLS:
		if not _cells_ran.has(c):
			miss.append(c)
	if not miss.is_empty():
		_errors += miss.size()
		push_error("[FAIL] 缺席的格：%s" % str(miss))
	print("\n=== spam_brake DONE === errors: %d｜到場點名 %d／%d" % [
		_errors, _cells_ran.size(), EXPECTED_CELLS.size()])
	quit(1 if _errors > 0 else 0)
