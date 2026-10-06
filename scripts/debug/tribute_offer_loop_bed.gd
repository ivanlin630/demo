extends SceneTree
# @bed-kind: invariant
# ══ 進貢提案：接受收得到貢，而三個出口都不再重提 ═════════════════════════════════
# spec：`docs/superpowers/specs/2026-10-01-tribute-offer-loop-and-the-unconsumed-result-HOW.md`
# 用戶實測（第三輪玩測）：19:00 Team11「要向你進貢」→ 按接受 →
#   「**未知提案類型：tribute_offer**」→ 21:00 再來一次；
#   ★**而接受或拒絕都一樣重提**（用戶自己補的，這一句決定了修的重心）。
#
# ★★★真因（spec §1）：**同一個狀態機有兩條出口，而玩家那一條沒有收尾** ——
#   NPC↔NPC 那條本來就做了三件（release／cooldown／清 `order_task`）；
#   玩家那條只寫一個 forced_event 面板就回去了 ⇒ 任務還在 ⇒ 下一輪再提。
#
# ★★而本床的每一格除了「零再到達」還斷言**收尾機制真的被武裝**
#   （`order_task` 清掉 ＋ cooldown 真的寫進去）——
#   ★理由逐字來自 spec P3：**「零再到達」在一個「對方根本沒機會再提」的世界裡恆真**
#   ⇒ 所以要**印到達序列**，而且要有一條說「那三件真的發生了」。

const SPEC_SETTLE_FN: String = "settle_tribute_offer"
const SPEC_TRANSFER_FN: String = "apply_tribute_transfer"
# ★收尾的呼叫點數：spec §3③ 寫 3 個（接受／拒絕／逾時），★而實際是 **4** ——
#   第四個是 `interaction_system` 那條 NPC↔NPC 出口，它**本來就手抄同樣三行**
#   ⇒ 一起接上去是**少一份會漂的複本**，不是多一個消費者。
#   ★★而這個數字**釘住**：有人再手抄一份三件 ⇒ 反向掃會紅（見 P6）。
const SPEC_SETTLE_CALLERS: int = 4
# 24h 窗（spec P3）—— ★而 cooldown 本身是 7 天，所以 24h 是一個**保守**的窗
const WINDOW_TICKS: int = WorldState.TICKS_PER_DAY

var _errors: int = 0
var _cells_ran: Array = []

const EXPECTED_CELLS: Array = [
	"_test_p1_accept_collects_the_tribute",
	"_test_p1b_accept_writes_no_relation",
	"_test_p3a_accept_exit_no_rearrival",
	"_test_p3b_refuse_exit_no_rearrival",
	"_test_p3c_timeout_exit_no_rearrival",
	"_test_p4_every_exit_says_something",
	"_test_p6_settle_has_one_definition",
]


func _init() -> void:
	print("=== tribute_offer_loop：進貢提案的三個出口 ===")
	_run()

func _run() -> void:
	_test_p1_accept_collects_the_tribute()
	_test_p1b_accept_writes_no_relation()
	_test_p3a_accept_exit_no_rearrival()
	_test_p3b_refuse_exit_no_rearrival()
	_test_p3c_timeout_exit_no_rearrival()
	_test_p4_every_exit_says_something()
	_test_p6_settle_has_one_definition()
	var missing: Array = []
	for c in EXPECTED_CELLS:
		if not _cells_ran.has(String(c)):
			missing.append(String(c))
	if not missing.is_empty():
		_errors += 1
		push_error("[FAIL] ★到場點名缺：%s" % str(missing))
	print("\n=== tribute_offer_loop DONE === errors: %d｜到場點名 %d／%d" % [
		_errors, _cells_ran.size(), EXPECTED_CELLS.size()])
	quit(1 if _errors > 0 else 0)


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
	seed(20261001)
	var st := WorldState.new()
	GameSetup.setup(st, GameSetup.load_config("res://config/warring_states.json"))
	return [st, SimRunner.new()]


# 在玩家隊同格擺一支【來進貢】的 NPC 隊
# ★佈置的是**世界樣本**（隊伍、領袖、錢、任務），不走指令路徑 —— 它要造的是
#   `interaction_system` 寫 forced_event 時的那個狀態（`order_task == TASK_TRIBUTE_OFFER`）。
func _tribute_npc(st: WorldState, tid: int, coin: float) -> TeamData:
	var ptid: int = st.get_player_team_id()
	var t := TeamData.new()
	t.team_id = tid
	t.faction_id = -1
	if ptid != -1 and st.teams.has(ptid):
		t.tile_pos = st.teams[ptid].tile_pos
	AnonTierSystem.add_anon(t, AnonCohort.TIER_PLEB, 4)
	var l := PersonData.new()
	l.id = tid * 10 + 1
	l.team_id = tid
	l.person_name = "首領%d" % tid
	st.persons[l.id] = l
	t.leader_id = l.id
	st.teams[tid] = t
	ResourceBank.set_amt(t, "coin", coin, "bed_fixture")
	# ★這兩個就是「它正在來進貢」的狀態（`interaction_system` 讀的就是這兩個）
	t.current_task = TeamData.TASK_DIPLOMACY
	t.order_task = TeamData.TASK_TRIBUTE_OFFER
	return t


func _arm_offer(st: WorldState, tid: int, fe_id: String) -> void:
	st.set_player_forced_event({"action": "diplomacy", "from_id": tid,
		"proposal": TeamData.TASK_TRIBUTE_OFFER}, fe_id)


# 走一個 24h 窗，把【每一次到達】印出來（tick ＋ 提案類型 ＋ from_id）
# ★★★spec P3 逐字要求這個：**「零再到達」在一個「對方根本沒機會再提」的世界裡恆真**
#   ⇒ 所以把序列印出來，讓讀的人看見那個窗裡到底發生了什麼。
func _arrivals_in_window(st: WorldState, runner: SimRunner) -> Array:
	var seen: Array = []
	var last_id: String = st.player_forced_event_id
	var ppos: Vector2i = Vector2i.ZERO
	var ptid: int = st.get_player_team_id()
	if ptid != -1 and st.teams.has(ptid):
		ppos = st.teams[ptid].tile_pos
	for i in range(WINDOW_TICKS):
		runner.advance_tick(st, ppos)
		var fid: String = st.player_forced_event_id
		if fid != "" and fid != last_id:
			var fe: Dictionary = st.player_forced_event
			seen.append({"tick": st.world.current_tick,
				"action": String(fe.get("action", "")),
				"proposal": String(fe.get("proposal", "")),
				"from_id": int(fe.get("from_id", -1))})
			last_id = fid
			# ★把它清掉再繼續走：不清的話「不覆蓋現有強制事件」那條會讓後面的到達看不見
			#   ⇒ 而那會讓本格把「被擋住」誤讀成「沒有再提」。
			st.player_forced_event = {}
			st.player_forced_event_id = ""
	return seen


# ★★★★★【誠實限：「窗內零到達」在【這一格裡】並不自證那個窗是活的】（2026-10-01 實測）
#   ·P3a（接受）的窗內**有兩次到達**（同一支 NPC，`action=extort`，tick 780／900）
#     ⇒ ★它證明了**那個窗是活的**：對方有機會，而它把機會用在別的動作上。
#   ·★★而 P3b（拒絕）／P3c（逾時）那兩格的窗**整個零到達** ——
#     它們**在格內**沒有「對方本來可以再來」的證據，而那個證據**在 P3a 那一格裡**。
#   ⇒ ★★★所以這一條寫在這裡而不是寫在報告裡：**只讀 P3b 那一格的人會推論出
#     「零到達 ＝ 收尾有效」，而那一格自己說不出「窗是活的」** ——
#     而三格合起來才說得出（P3a 提供活性、三格各自提供「那一條出口清了」）。
#   ⇒ ★而正解不是把三格併成一格（spec 明寫不准）：是把這一條限制寫下來，
#     並且**三格都印序列** —— 讀的人看得見哪一格有到達、哪一格沒有。
func _print_arrivals(tag: String, seen: Array) -> void:
	print("   ── 到達序列（%s，窗長 %d tick ＝ 24h）──" % [tag, WINDOW_TICKS])
	if seen.is_empty():
		print("     （窗內零到達）")
	for a in seen:
		var d: Dictionary = a as Dictionary
		print("     tick=%d｜action=%s｜proposal=%s｜from=%d" % [
			int(d.get("tick", 0)), String(d.get("action", "")),
			String(d.get("proposal", "")), int(d.get("from_id", -1))])


func _tribute_arrivals(seen: Array) -> int:
	var n: int = 0
	for a in seen:
		if String((a as Dictionary).get("proposal", "")) == TeamData.TASK_TRIBUTE_OFFER:
			n += 1
	return n


# ══ P1：接受 ＝ 收貢（玩家 coin 增加、對方減少，而金額 ＝ 轉帳那一半的回傳）═══════
# ★母體地板（spec P1 逐字）：對方 `coin_before > 0` —— 否則 `apply_tribute_transfer` 回 0
#   ⇒ 這一格會在「什麼都沒發生」的世界裡恆綠。
# 負對照：接受那一支額外走 `_pay_extortion`（＝併成索貢語意）⇒ 本格紅 2 條，而方向逐字相反：玩家 2110.1 → **1685.3**、對方 500 → **924.8** ⇒ 已於 feat/text-ui-layout-v2（2026-10-06 這一輪） 實測紅
# ★★而**同一個擾動也讓既有那個倒付守衛紅**（`forced_event_panel_bed`：玩家 coin 500.0 → 387.5）
#   ⇒ spec P2「既有那一格不得弱化」**有實證**，不是一句話。
func _test_p1_accept_collects_the_tribute() -> void:
	print("\n── P1 接受 ＝ 收貢 ──")
	var pair: Array = _fresh()
	var st: WorldState = pair[0]
	var runner: SimRunner = pair[1]
	var bridge := SimBridge.new(runner, st)
	var npc: TeamData = _tribute_npc(st, 7410, 500.0)
	var pt: TeamData = st.teams.get(st.get_player_team_id())
	_check("★母體地板 A：找得到玩家隊", pt != null)
	var npc_before: float = float(npc.resources.get("coin", 0))
	var pt_before: float = float(pt.resources.get("coin", 0))
	_check("★★母體地板 B：對方身上真的有錢（%.0f；0 ⇒ 轉帳回 0 ⇒ 本格恆綠）" % npc_before,
		npc_before > 0.0)
	_arm_offer(st, 7410, "fe_trib_p1")
	var r: Dictionary = bridge.command_player("respond_to_forced",
		{"interaction_id": "fe_trib_p1", "response_id": "accept"})
	bridge.tick_step()
	var npc_after: float = float(npc.resources.get("coin", 0))
	var pt_after: float = float(pt.resources.get("coin", 0))
	print("   對方 coin %.1f → %.1f（差 %.1f）｜玩家 coin %.1f → %.1f（差 %.1f）" % [
		npc_before, npc_after, npc_after - npc_before,
		pt_before, pt_after, pt_after - pt_before])
	print("   ── 結果句（逐字）──")
	for i in range(st.command_results.size()):
		var e: Dictionary = st.command_results[i]
		print("     ok=%-5s %s" % [str(e.get("ok", "?")), String(e.get("text", ""))])
	_check("★★★★★P1-a：玩家 coin **增加**（%.1f → %.1f）" % [pt_before, pt_after],
		pt_after > pt_before)
	_check("★★★★★P1-b：對方 coin **減少**（%.1f → %.1f）" % [npc_before, npc_after],
		npc_after < npc_before)
	# ★★★★而「金額是同一筆」要斷言：兩邊的差必須相等（否則錢從別處來／漏到別處去）
	var taken: float = pt_after - pt_before
	var paid: float = npc_before - npc_after
	_check("★★★★★★P1-c：玩家收到的 ＝ 對方付出的（%.4f vs %.4f）—— 同一筆錢" % [taken, paid],
		absf(taken - paid) < 0.001)
	_check("★入列有回傳（ok=%s）" % str(r.get("ok", "?")), r.has("ok"))
	_cell("_test_p1_accept_collects_the_tribute")


# ══ P1b ＝ spec ⑥【兩個方向】：accept **不寫關係**，而索貢那條**必須寫得出來**═══════
# ★藍圖那句最短：**「0 才有意義」** —— 一個永遠寫不出那筆記憶的世界裡，
#   「accept 後 ＝ 0」什麼都沒說（它與「這個機制根本不存在」在卷面上一模一樣）。
# 負對照：把 accept arm 改回呼 `apply_tribute_accept`（連帶寫記憶）⇒ 第一條紅
func _test_p1b_accept_writes_no_relation() -> void:
	print("\n── P1b 兩個方向：accept 不寫關係／索貢那條寫得出來 ──")
	# 方向①：accept ⇒ `"tributed"` 類記憶 ＝ 0
	var pair: Array = _fresh()
	var st: WorldState = pair[0]
	var bridge := SimBridge.new(pair[1] as SimRunner, st)
	var npc: TeamData = _tribute_npc(st, 7420, 500.0)
	var leader: PersonData = st.persons.get(npc.leader_id)
	_check("★母體地板：對方有領袖（沒有 ⇒ 記憶寫不進去 ⇒ 方向①恆綠）", leader != null)
	var before_n: int = _tributed_memories(leader)
	_arm_offer(st, 7420, "fe_trib_p1b")
	bridge.command_player("respond_to_forced",
		{"interaction_id": "fe_trib_p1b", "response_id": "accept"})
	bridge.tick_step()
	var after_n: int = _tributed_memories(leader)
	print("   方向①（accept）：`tributed` 記憶 %d → %d" % [before_n, after_n])
	_check("★★★★★★方向①：accept 之後對方**沒有**多一筆 `tributed` 記憶（%d → %d）"
		% [before_n, after_n], after_n == before_n)
	# 方向②：索貢那條（強制情境）**必須**寫得出來 —— ★否則方向① 的 0 什麼都沒說
	var pair2: Array = _fresh()
	var st2: WorldState = pair2[0]
	var npc2: TeamData = _tribute_npc(st2, 7421, 500.0)
	var pt2: TeamData = st2.teams.get(st2.get_player_team_id())
	var leader2: PersonData = st2.persons.get(npc2.leader_id)
	var b2: int = _tributed_memories(leader2)
	var amt: float = DiplomaticAiSystem.apply_tribute_accept(st2, npc2, pt2)
	var a2: int = _tributed_memories(leader2)
	print("   方向②（索貢／強制）：轉了 %.1f｜`tributed` 記憶 %d → %d" % [amt, b2, a2])
	_check("★母體地板：索貢那一支真的轉了錢（%.1f；0 ⇒ 它不會寫記憶 ⇒ 方向②恆紅而理由是錯的）"
		% amt, amt > 0.0)
	_check("★★★★★★方向②：索貢那條**寫得出**那筆記憶（%d → %d）⇒ 所以方向①的 0 才有意義"
		% [b2, a2], a2 > b2)
	_cell("_test_p1b_accept_writes_no_relation")


# ★★★★★★【這支抽取式第一版讀錯兩個名字，而它恆回 0】（實測訂正，2026-10-01）
#   我寫 `p.memories` 與 `"kind"`，而真實是 **`p.memory`** 與 **`"type"`**
#   （`npc_ai_system.gd:88-91` 逐字：`p.memory.append({"type": type, "subject_id": …})`）
#   ⇒ ★它**恆回 0** ⇒ 方向①（accept 後 ＝ 0）是**恆真**，什麼都沒驗。
#   ⇒ ★★而**抓到它的是方向②**（索貢那條必須寫得出來）——
#     那正是 spec ⑥ 要求兩個方向的理由，而它**當場就付清了成本**：
#     單獨一個「＝ 0」的斷言與「這個機制根本不存在」在卷面上一模一樣。
#   ⇒ ★★★判準（今天第三次）：**任何回 0 的量，要在印出那個 0 的同一行問
#     「有沒有可能是我沒看到，而不是它不存在」** —— 而這一次問它的是另一個方向。
func _tributed_memories(p: PersonData) -> int:
	if p == null:
		return 0
	var n: int = 0
	for m in p.memory:
		if String((m as Dictionary).get("type", "")) == "tributed":
			n += 1
	return n


# ══ P3a／b／c：三個出口**各自**一格（spec 明寫不准用一格覆蓋三件）═════════════════
# ★而每一格都斷言兩件事，缺一件那一格就沒有主詞：
#   ①**收尾真的做了**（`order_task` 清掉 ＋ cooldown 真的寫進去 ＋ task 被 release）
#   ②**24h 窗內零再到達**（而到達序列印出來）
# ★★只有 ② ⇒ 它在「對方根本沒機會再提」的世界裡恆真（spec P3 逐字）
# ★★只有 ① ⇒ 它不保證玩家不會再被打斷（而那是用戶抱怨的那件事）
func _settle_assertions(tag: String, npc: TeamData, st: WorldState, ptid: int) -> void:
	print("   ── 收尾三件（%s）──" % tag)
	print("     order_task ＝ %s（要空）" % ("（空）" if npc.order_task == "" else npc.order_task))
	var has_cd: bool = npc.diplomacy_reject_cooldown.has(ptid)
	var cd: int = int(npc.diplomacy_reject_cooldown.get(ptid, -1))
	print("     cooldown[玩家隊] ＝ %d（現在 tick ＝ %d）" % [cd, st.world.current_tick])
	print("     current_task ＝ %s" % npc.current_task)
	_check("★★★%s：`order_task` 被清掉（它是「任務還在 ⇒ 下一輪再提」的那個欄位）" % tag,
		npc.order_task == "")
	_check("★★★%s：cooldown 真的寫進去了（有鍵＝%s）" % [tag, str(has_cd)], has_cd)
	_check("★★%s：cooldown 指向未來（%d > %d）" % [tag, cd, st.world.current_tick],
		cd > st.world.current_tick)
	_check("★%s：task 不再是進貢那一件（current_task ＝ %s）" % [tag, npc.current_task],
		npc.current_task != TeamData.TASK_TRIBUTE_OFFER)


# 負對照：把接受那一支的 `settle_tribute_offer` 刪掉 ⇒ 本格紅 4 條（order_task 沒清／cooldown 無鍵／cooldown ＝ -1／★**24h 窗內再到達 1 次**） ⇒ 已於 feat/text-ui-layout-v2（2026-10-06 這一輪） 實測紅
# ★★★那個「實得 1 次」就是用戶那句「**接受或拒絕都一樣重提**」被機械重現的樣子。
func _test_p3a_accept_exit_no_rearrival() -> void:
	print("\n── P3a 出口①接受：收尾 ＋ 24h 零再到達 ──")
	var pair: Array = _fresh()
	var st: WorldState = pair[0]
	var runner: SimRunner = pair[1]
	var bridge := SimBridge.new(runner, st)
	var npc: TeamData = _tribute_npc(st, 7430, 500.0)
	var ptid: int = st.get_player_team_id()
	_arm_offer(st, 7430, "fe_trib_p3a")
	bridge.command_player("respond_to_forced",
		{"interaction_id": "fe_trib_p3a", "response_id": "accept"})
	bridge.tick_step()
	_settle_assertions("P3a 接受", npc, st, ptid)
	var seen: Array = _arrivals_in_window(st, runner)
	_print_arrivals("接受之後", seen)
	_check("★★★★★★P3a：24h 窗內**零**進貢再到達（實得 %d 次）" % _tribute_arrivals(seen),
		_tribute_arrivals(seen) == 0)
	_cell("_test_p3a_accept_exit_no_rearrival")


# 負對照：把拒絕那一支的 `settle_tribute_offer` 刪掉 ⇒ 本格紅 4 條，含**24h 窗內再到達 1 次** ⇒ 已於 feat/text-ui-layout-v2（2026-10-06 這一輪） 實測紅
func _test_p3b_refuse_exit_no_rearrival() -> void:
	print("\n── P3b 出口②拒絕：收尾 ＋ 24h 零再到達 ──")
	var pair: Array = _fresh()
	var st: WorldState = pair[0]
	var runner: SimRunner = pair[1]
	var bridge := SimBridge.new(runner, st)
	var npc: TeamData = _tribute_npc(st, 7440, 500.0)
	var ptid: int = st.get_player_team_id()
	_arm_offer(st, 7440, "fe_trib_p3b")
	bridge.command_player("respond_to_forced",
		{"interaction_id": "fe_trib_p3b", "response_id": "refuse"})
	bridge.tick_step()
	_settle_assertions("P3b 拒絕", npc, st, ptid)
	var seen: Array = _arrivals_in_window(st, runner)
	_print_arrivals("拒絕之後", seen)
	_check("★★★★★★P3b：24h 窗內**零**進貢再到達（實得 %d 次）" % _tribute_arrivals(seen),
		_tribute_arrivals(seen) == 0)
	_cell("_test_p3b_refuse_exit_no_rearrival")


# 負對照：把 `sim_runner` 那個專屬分支刪掉 ⇒ 本格紅（含母體地板「面板真的被逾時清掉」—— ★**沒收尾的話對方在同一個窗裡又擺了一個面板**，而那正是迴圈本身） ⇒ 已於 feat/text-ui-layout-v2（2026-10-06 這一輪） 實測紅
# ★而這一格**不按任何鍵** —— 它是「玩家沒回應」那條路（用戶也會遇到：他可能就是沒按）
func _test_p3c_timeout_exit_no_rearrival() -> void:
	print("\n── P3c 出口③逾時（不按任何鍵）：收尾 ＋ 24h 零再到達 ──")
	var pair: Array = _fresh()
	var st: WorldState = pair[0]
	var runner: SimRunner = pair[1]
	var npc: TeamData = _tribute_npc(st, 7450, 500.0)
	var ptid: int = st.get_player_team_id()
	_arm_offer(st, 7450, "fe_trib_p3c")
	_check("★母體地板：到達真的發生（forced_event 非空）",
		not st.player_forced_event.is_empty())
	# 推到逾時（`sim_runner` 在下一個 hour-tick 清面板）
	var ppos: Vector2i = st.teams[ptid].tile_pos if ptid != -1 and st.teams.has(ptid) \
		else Vector2i.ZERO
	for i in range(WorldState.TICKS_PER_HOUR + 2):
		runner.advance_tick(st, ppos)
	print("   逾時之後 forced_event 是不是空的 ＝ %s" % str(st.player_forced_event.is_empty()))
	_check("★★母體地板：面板真的被逾時清掉了（沒清 ⇒ 下面的收尾斷言在錯的時點問）",
		st.player_forced_event.is_empty())
	_settle_assertions("P3c 逾時", npc, st, ptid)
	var seen: Array = _arrivals_in_window(st, runner)
	_print_arrivals("逾時之後", seen)
	_check("★★★★★★P3c：24h 窗內**零**進貢再到達（實得 %d 次）" % _tribute_arrivals(seen),
		_tribute_arrivals(seen) == 0)
	_cell("_test_p3c_timeout_exit_no_rearrival")


# ══ P4：三個出口的結果句都非空，且**不含內部識別字**═══════════════════════════════
# ★反例樣本逐字就是用戶看到的那一句：「**未知提案類型：tribute_offer**」
#   ⇒ 它同時犯兩件：那是一句內部錯誤、而且它把 `action_id` 印給玩家看。
const SPEC_INTERNAL_TOKENS: Array = ["tribute_offer", "未知提案類型", "order_task", "null"]

func _test_p4_every_exit_says_something() -> void:
	print("\n── P4 三個出口都有一句人話，且不含內部識別字 ──")
	print("   內部識別字（指名）＝ %s" % str(SPEC_INTERNAL_TOKENS))
	var sentences: Array = []
	for resp in ["accept", "refuse"]:
		var pair: Array = _fresh()
		var st: WorldState = pair[0]
		var bridge := SimBridge.new(pair[1] as SimRunner, st)
		_tribute_npc(st, 7460, 500.0)
		_arm_offer(st, 7460, "fe_trib_p4_" + String(resp))
		bridge.command_player("respond_to_forced",
			{"interaction_id": "fe_trib_p4_" + String(resp), "response_id": String(resp)})
		bridge.tick_step()
		for i in range(st.command_results.size()):
			var e: Dictionary = st.command_results[i]
			sentences.append({"exit": String(resp), "text": String(e.get("text", ""))})
	print("   ── 結果句（逐字）──")
	for s in sentences:
		print("     [%s] %s" % [String((s as Dictionary).get("exit", "")),
			String((s as Dictionary).get("text", ""))])
	_check("★母體地板：真的收集到結果句（%d 句；0 ⇒ 下面兩條恆綠）" % sentences.size(),
		sentences.size() > 0)
	var empty_ones: Array = []
	var leaky: Array = []
	for s2 in sentences:
		var d: Dictionary = s2 as Dictionary
		var txt: String = String(d.get("text", ""))
		if txt.strip_edges() == "":
			empty_ones.append(String(d.get("exit", "")))
		for tok in SPEC_INTERNAL_TOKENS:
			if txt.contains(String(tok)):
				leaky.append("%s｜%s" % [String(d.get("exit", "")), String(tok)])
	_check("★★★★★P4-a：每一句都非空（空的出口：%s）" % str(empty_ones), empty_ones.is_empty())
	_check("★★★★★★P4-b：沒有一句含內部識別字（命中：%s）" % str(leaky), leaky.is_empty())
	# ★反向對照：同一個判準在**刻意塞一個**的句子上必須命中（否則它可能恆綠）
	var probe: String = "未知提案類型：tribute_offer"
	var probe_hits: int = 0
	for tok2 in SPEC_INTERNAL_TOKENS:
		if probe.contains(String(tok2)):
			probe_hits += 1
	_check("★★【反向對照】用戶看到的那一句（逐字）必須被這個判準命中（%d 個 token）" % probe_hits,
		probe_hits > 0)
	_cell("_test_p4_every_exit_says_something")


# ══ P6：收尾**只有一處定義**、**4 個呼叫點**，而反向掃無第五處自己手抄的三件═══════
# ★★而「4」是從 spec 的 3 改上來的，理由寫在 `SPEC_SETTLE_CALLERS` 旁邊。
# 負對照：在任何一處再手抄一次那三行（release ＋ cooldown ＋ 清 order_task）⇒ 反向掃紅
func _test_p6_settle_has_one_definition() -> void:
	print("\n── P6 收尾單一定義 ＋ 反向掃 ──")
	var files: Array = []
	_collect_gd("res://scripts/simulation", files)
	_check("★母體地板 A：掃到的 `.gd` > 0（%d）" % files.size(), files.size() > 0)
	var defs: Array = []
	var callers: Array = []
	var handwritten: Array = []
	for f in files:
		var raw: String = FileAccess.get_file_as_string(String(f))
		var ls: Array = raw.split("\n")
		for i in range(ls.size()):
			var line: String = String(ls[i])
			var t: String = line.strip_edges()
			if t.begins_with("#"):
				continue
			var code: String = line
			var h: int = code.find("#")
			if h != -1:
				code = code.substr(0, h)
			if code.contains("static func " + SPEC_SETTLE_FN):
				defs.append("%s:%d" % [String(f), i + 1])
			elif code.contains(SPEC_SETTLE_FN + "("):
				callers.append("%s:%d" % [String(f), i + 1])
			# ★反向掃：自己手抄那三件的人（清 `order_task` ＋ 寫 cooldown 在同一段裡）
			if code.contains("order_task = \"\""):
				handwritten.append("%s:%d ⇒ %s" % [String(f), i + 1, t])
	print("   定義 ＝ %s" % str(defs))
	print("   呼叫點 ＝ %s" % str(callers))
	print("   ★反向掃（自己清 `order_task` 的地方）＝ %s" % str(handwritten))
	_check("★★★★★P6-a：收尾**只有一處定義**（%d）" % defs.size(), defs.size() == 1)
	_check("★★★★★P6-b：呼叫點 ＝ %d（實得 %d；spec 寫 3，而第四個是少一份手抄 —— 理由在常數旁邊）"
		% [SPEC_SETTLE_CALLERS, callers.size()], callers.size() == SPEC_SETTLE_CALLERS)
	_check("★★★★★★P6-c：沒有第五處自己手抄的收尾（清 `order_task` 的只准在那一支定義裡；實得 %s）"
		% str(handwritten), handwritten.size() == 1)
	# ★轉帳那一支也要只有一處定義（它是本票拆出來的那一半）
	var tdefs: int = 0
	for f2 in files:
		if FileAccess.get_file_as_string(String(f2)).contains("static func " + SPEC_TRANSFER_FN):
			tdefs += 1
	_check("★★P6-d：`%s` 只有一處定義（%d）" % [SPEC_TRANSFER_FN, tdefs], tdefs == 1)
	_cell("_test_p6_settle_has_one_definition")


func _collect_gd(dir_path: String, out: Array) -> void:
	var d: DirAccess = DirAccess.open(dir_path)
	if d == null:
		return
	d.list_dir_begin()
	var n: String = d.get_next()
	while n != "":
		if d.current_is_dir():
			if not n.begins_with("."):
				_collect_gd(dir_path + "/" + n, out)
		elif n.ends_with(".gd"):
			out.append(dir_path + "/" + n)
		n = d.get_next()
	d.list_dir_end()
