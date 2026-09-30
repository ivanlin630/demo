extends SceneTree
# @bed-kind: invariant
# slice: `leader_id` 的 chokepoint 被繞過 5 次（spec 2026-09-30）
#
# ★★★來源不是有人讀 code 讀出來的：是**死輸入探索床**報的那一筆 `InvariantAudit` 紅
#   （`L3:choose_heir` ⇒ `roster 反向破 P127 team_id=48 但不在該隊 roster`）。
#   真因＝`choose_heir` 手寫了一份 `set_leader`，而漏掉最關鍵的那一件：
#   `p.team_id = team.team_id`（強制回指本隊）。
#
# ★★而本床真正的價值在 P3：那 5 處裡【只有①有血證】，②③④⑤**沒有人測過** ——
#   它們是同一類（手寫一份 chokepoint 而各漏不同的一件）。
#   ⇒ 對每一處構造一次【那個人原本不在該隊】的情境並跑稽核，
#     ★而不論綠紅都要印出【我構造的情境長什麼樣】——
#     否則「綠」可能只是情境沒建起來（我今天已經在另一張票上踩了三次那一族）。
#
# ★誠實限：
#   1. P1 是把那一步【重放】，不是跑整支死輸入床（那支在另一個 branch，還沒 merge）。
#      ⇒ 重放的路徑與它相同：`resolve_forced_response("choose_heir")` 那一支。
#   2. ⑤ subteam 是【具名不改】，而本床仍然驗它三件效果都在（不改 ≠ 不驗）。
#   3. 8 處 `leader_id = -1` 不在本票；本床把它們的【數】印出來並說明為何不動。

var _errors: int = 0
var _cells_ran: Array = []

const SPEC_REAL_ASSIGN_SITES: int = 5      # 指派真人的直寫處（spec §2 指名）
const SPEC_ROUTED: int = 4                 # 本票改走 chokepoint 的
const SPEC_NAMED_EXEMPT: int = 1           # 就地具名不改的（subteam）
const SPEC_CLEAR_SITES_MIN: int = 8        # `= -1` 清空（chokepoint 明文允許）⇒ 不在本票

const ROUTED_FILES: Array = [
	"res://scripts/simulation/player_command_system.gd",
	"res://scripts/simulation/population_system.gd",
	"res://scripts/simulation/reaction_system.gd",
	"res://scripts/simulation/recruit_tutorial.gd",
]
const EXEMPT_FILE: String = "res://scripts/simulation/subteam_system.gd"

const EXPECTED_CELLS: Array = [
	"_test_p1_heir_replay",
	"_test_p1b_stale_heir_team_id",
	"_test_p2_site_accounting",
	"_test_p3_other_four_sites",
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

# 稽核一次，回 [違反數, 第一條]
func _audit(st: WorldState) -> Array:
	var v: Array = InvariantAudit.check(st)
	return [v.size(), String(v[0]) if not v.is_empty() else ""]


# ══ P1：重放 choose_heir ═════════════════════════════════════════════════════
# ★★★【訂正上游的前提】：那一筆稽核紅**不是產品缺陷的血證，是我自己床的佈置造成的**。
#   `InvariantAudit` 的 reverse 檢查逐字寫著「dead 留屍跳過」（invariant_audit.gd:94：
#   `if p.team_id == -1 or p.is_dead: continue`）。
#   而 `choose_heir` 在 production 只會在【leader 死了】之後 fire ⇒ 舊 leader 是 `is_dead`
#   ⇒ 稽核本來就不會看他。
#   ★我那支死輸入床是【合成】一個 choose_heir 事件，而沒有把舊 leader 標死
#     ⇒ 他變成「team_id=48、不在 roster、而且活著」⇒ 稽核當然紅。
#   ⇒ ★★所以「①有血證」這句要劃掉：改走 chokepoint 仍然值得做（它把手抄的那一份收掉），
#     但它的理由是【衛生】不是【修一個已發生的 bug】。
#   ⇒ ★★★而真正能讓第三件事（`p.team_id` 回指）產生差別的形狀，是 P1b 那一個
#     （繼承人的 team_id 本來就 stale）—— 那一格才有負對照可以紅。
func _test_p1_heir_replay() -> void:
	print("
── P1 重放 choose_heir（production 形狀：舊 leader 真的死了）──")
	var st: WorldState = _fresh()
	var cs := PlayerCommandSystem.new()
	var pt: TeamData = st.teams.get(st.get_player_team_id())
	var old_leader: PersonData = st.persons.get(pt.leader_id)
	var heir_id: int = int(pt.named_members[0]) if not pt.named_members.is_empty() else -1
	var heir: PersonData = st.persons.get(heir_id)
	print("   舊 leader P%d（標死 ＝ production 的前提）｜繼承人 P%d 的 team_id = %d｜事件 team_id = %d" % [
		old_leader.id, heir_id, heir.team_id if heir != null else -999, pt.team_id])
	_check("★母體地板：繼承人存在且是那一隊的 named（候選集就是從 named 來的）",
		heir != null and pt.named_members.has(heir_id))
	old_leader.is_dead = true   # ★production 的前提：這個事件只在 leader 死後 fire
	var before: Array = _audit(st)
	print("   佈置後、繼任前的稽核：%d 條違反（★這一行就是「合成事件而沒標死」會紅的地方）" % int(before[0]))
	st.set_player_forced_event({
		"action": "choose_heir", "team_id": pt.team_id, "candidates": [heir_id],
	}, "bed_heir")
	var r: Dictionary = cs.resolve_forced_response(st, "bed_heir", "heir_%d" % heir_id)
	print("   繼任結果：ok=%s msg=%s" % [str(r.get("ok", false)), String(r.get("msg", ""))])
	_check("★母體地板：繼任真的成功了（失敗的話稽核乾淨是因為什麼都沒發生）",
		bool(r.get("ok", false)))
	print("   繼任後：P%d 的 team_id = %d｜Team%d 的 leader_id = %d｜named 含他 = %s" % [
		heir_id, heir.team_id, pt.team_id, pt.leader_id, str(pt.named_members.has(heir_id))])
	var after: Array = _audit(st)
	print("   繼任後稽核：%d 條違反%s" % [int(after[0]),
		"" if int(after[0]) == 0 else "（第一條：%s）" % String(after[1])])
	_check("★★★production 形狀下稽核零違反", int(after[0]) == 0)
	_check("★三件事都做到了：leader_id 指他、team_id 回指本隊、他不在 named（leader 與 named 分職）",
		pt.leader_id == heir_id and heir.team_id == pt.team_id
			and not pt.named_members.has(heir_id))
	_cell("_test_p1_heir_replay")


# ══ P1b：★第三件事（team_id 回指）真的有差別的那個形狀 ═══════════════════════
# 繼承人的 `team_id` 本來就 stale（指向別隊）⇒ 走 chokepoint 會被強制回指；
# 直寫版不會 ⇒ 稽核紅。★這一格才是「漏掉第三件」的可判形狀。
# 負對照：把 `set_leader(team, heir_id)` 換回原本那三行直寫 ⇒ 本格必紅（實測記錄在交件信）
func _test_p1b_stale_heir_team_id() -> void:
	print("
── P1b 繼承人的 team_id 本來就 stale ──")
	var st: WorldState = _fresh()
	var cs := PlayerCommandSystem.new()
	var pt: TeamData = st.teams.get(st.get_player_team_id())
	var old_leader: PersonData = st.persons.get(pt.leader_id)
	old_leader.is_dead = true
	var heir_id: int = int(pt.named_members[0]) if not pt.named_members.is_empty() else -1
	var heir: PersonData = st.persons.get(heir_id)
	# ★造 stale：他在 Team48 的 named 裡，而 team_id 指向另一隊（真實世界會這樣發生的來源：
	#   任何一處「搬人而只改一半」的手抄 —— 那正是本票在收的那一族）
	var other_id: int = -1
	for k in st.teams.keys():
		if int(k) != pt.team_id:
			other_id = int(k)
			break
	heir.team_id = other_id
	print("   繼承人 P%d：在 Team%d 的 named 裡，而 team_id 指向 Team%d（stale）" % [
		heir_id, pt.team_id, heir.team_id])
	_check("★★母體地板：stale 真的建起來了（team_id != 事件的 team_id）", heir.team_id != pt.team_id)
	st.set_player_forced_event({
		"action": "choose_heir", "team_id": pt.team_id, "candidates": [heir_id],
	}, "bed_heir_stale")
	var r: Dictionary = cs.resolve_forced_response(st, "bed_heir_stale", "heir_%d" % heir_id)
	_check("★母體地板：繼任真的成功了", bool(r.get("ok", false)))
	print("   繼任後：P%d 的 team_id = %d（★走 chokepoint 會強制回指 %d）" % [
		heir_id, heir.team_id, pt.team_id])
	_check("★★★第三件事真的發生了：繼承人的 team_id 被強制回指本隊",
		heir.team_id == pt.team_id)
	var after: Array = _audit(st)
	print("   繼任後稽核：%d 條違反%s" % [int(after[0]),
		"" if int(after[0]) == 0 else "（第一條：%s）" % String(after[1])])
	_check("★稽核零違反", int(after[0]) == 0)
	_cell("_test_p1b_stale_heir_team_id")


# ══ P2：五處的對帳（已改 ＋ 具名不改 ＝ 5）══════════════════════════════════
# ★數字不是我手抄的：從原始碼機械抽 —— 已改的那四檔要出現 `set_leader(`，
#   而具名不改的那一檔要【同時】有直寫與具名理由。
func _test_p2_site_accounting() -> void:
	print("\n── P2 五處對帳 ──")
	var routed: int = 0
	for f in ROUTED_FILES:
		var src: String = _code_only(FileAccess.get_file_as_string(String(f)))
		var has_call: bool = src.contains("set_leader(")
		print("   %-34s set_leader( ＝ %s" % [String(f).get_file(), str(has_call)])
		if has_call:
			routed += 1
	var ex_src_raw: String = FileAccess.get_file_as_string(EXEMPT_FILE)
	var ex_src: String = _code_only(ex_src_raw)
	var still_direct: bool = ex_src.contains("sub.leader_id        = sub_leader_id")
	var has_reason: bool = ex_src_raw.contains("具名例外") and ex_src_raw.contains("role 語意")
	print("   %-34s 直寫仍在 ＝ %s｜就地具名理由 ＝ %s" % [
		EXEMPT_FILE.get_file(), str(still_direct), str(has_reason)])
	_check("★已改走 chokepoint 的 ＝ %d／%d" % [routed, SPEC_ROUTED], routed == SPEC_ROUTED)
	_check("★★具名不改的那一處：直寫仍在【且】理由就地寫著（只有其中一個 ⇒ 紅）",
		still_direct and has_reason)
	_check("★★★三數相加：已改 %d ＋ 具名不改 %d ＝ 指派真人的處數 %d" % [
		routed, SPEC_NAMED_EXEMPT, SPEC_REAL_ASSIGN_SITES],
		routed + SPEC_NAMED_EXEMPT == SPEC_REAL_ASSIGN_SITES)
	# `= -1` 那一族：印數並說明為何不動（spec §3②）
	# ★母體邊界：不要手寫檔清單（我第一版寫了 8 個檔名 ⇒ 只數到 3 處，而那是
	#   【我的清單漏檔】不是「產品只有 3 處」）⇒ 機械掃整個 scripts/ 的非 debug 檔。
	var clear_hits: int = 0
	var scanned: int = 0
	var dirs: Array = ["res://scripts/simulation", "res://scripts/data",
		"res://scripts/simulation/events", "res://scripts/ui"]
	for d in dirs:
		var da := DirAccess.open(String(d))
		if da == null:
			continue
		for fn in da.get_files():
			if not String(fn).ends_with(".gd"):
				continue
			scanned += 1
			var s2: String = _code_only(FileAccess.get_file_as_string(String(d) + "/" + String(fn)))
			for line in s2.split("
"):
				if line.contains("leader_id = -1") and not line.contains("=="):
					clear_hits += 1
	print("   掃過 %d 支非 debug .gd" % scanned)
	print("   `leader_id = -1`（清空）命中 %d 處｜spec 說 >= %d" % [clear_hits, SPEC_CLEAR_SITES_MIN])
	print("   ★為何不動：chokepoint 檔頭明文「pid=-1 允許（清空 leader，transient；不設 role/team_id）」")
	print("     ⇒ 清空不需要 team_id 回指 ⇒ 它們不是繞過，而不是「還沒改」。")
	# ★★★我量到 6，spec 說 8 ⇒ **兩個數都留在卷面上，我不自動採用任何一邊**
	#   （同死輸入床那張的 51／55：spec 與我的量法不同時，印差異而不猜）。
	#   我的量法（寫出來才能被反駁）：scripts/{simulation,data,simulation/events,ui} 底下
	#   的非 debug .gd、剝掉整行註解、字面含 `leader_id = -1` 且不含 `==`。
	#   ⇒ 差 2 的可能來源：他把 debug 床也算進去／或把不同寫法（例如換行、`sub.leader_id= -1`）算進去。
	print("   ★逐處列出我數到的那 %d 處（讓差異可被指名，不是只看總數）：" % clear_hits)
	for d2 in dirs:
		var da2 := DirAccess.open(String(d2))
		if da2 == null:
			continue
		for fn2 in da2.get_files():
			if not String(fn2).ends_with(".gd"):
				continue
			var s3: String = _code_only(FileAccess.get_file_as_string(
				String(d2) + "/" + String(fn2)))
			var ln: int = 0
			for line2 in s3.split("
"):
				ln += 1
				if line2.contains("leader_id = -1") and not line2.contains("=="):
					print("     · %s ⇒ %s" % [String(fn2), line2.strip_edges().substr(0, 60)])
	_check("★清空那一族至少數到 1 處（0 ⇒ 我的母體抽壞了）；★而 6 vs spec 的 8 的差異已列名交給 systems",
		clear_hits >= 1)
	_cell("_test_p2_site_accounting")


# ══ P3：★另外四處各構造一次「人原本不在該隊」的情境並跑稽核 ═══════════════════
# ★★不論綠紅都印出【情境長什麼樣】：綠可能只是情境沒建起來。
func _test_p3_other_four_sites() -> void:
	print("\n── P3 另外四處（②③④⑤）各構造一次情境 ──")
	# ② population_system：超額分隊 ⇒ 新隊的 leader 是現生的人
	var st2: WorldState = _fresh()
	var ps := PopulationSystem.new()
	var origin: TeamData = null
	for k in st2.teams.keys():
		if st2.teams[k].population >= 6:
			origin = st2.teams[k]
			break
	print("   ②情境：Team%d 人口 %d ⇒ 呼 _create_overflow_team（新隊 leader 現生）" % [
		origin.team_id if origin != null else -1, origin.population if origin != null else -1])
	_check("★②母體地板：找到人口足夠的母隊（找不到 ⇒ 這一格什麼都沒驗）", origin != null)
	var t2_before: int = st2.teams.size()
	ps.call("_create_overflow_team", st2, origin, 3)
	var a2: Array = _audit(st2)
	print("   ②結果：隊數 %d → %d｜稽核 %d 條違反%s" % [t2_before, st2.teams.size(), int(a2[0]),
		"" if int(a2[0]) == 0 else "（%s）" % String(a2[1])])
	_check("★★②稽核零違反（紅 ⇒ 本票找到第二個，照樣修）", int(a2[0]) == 0)

	# ③ reaction_system：離團自立流亡
	#   ★★★第一版我挑了【舊隊的 leader】去流亡 ⇒ 稽核紅一條，而那是**假紅**：
	#     production 的呼叫端（`:419`）只在 `team.named_members.has(person.id)` 時才呼它，
	#     而 leader 走的是另一支（「leader 留下，實際走的是 anon」）⇒ **leader 永遠不流亡**。
	#   ⇒ ★我的佈置比產品到得了的狀態【更寬】⇒ 假紅。而這是同一族的反方向：
	#     母體太窄 ⇒ 假綠（缺陷走不到）；母體太寬 ⇒ 假紅（產品到不了那個狀態）。
	#   ⇒ 改成 production 形狀：挑 named（非 leader）＋先 `remove_member`（呼叫端就是這樣做的）。
	var st3: WorldState = _fresh()
	var rs := ReactionSystem.new()
	var exile: PersonData = null
	var old_team: TeamData = null
	for k3 in st3.teams.keys():
		var t3: TeamData = st3.teams[k3]
		for pid3 in t3.named_members:
			var cand3: PersonData = st3.persons.get(pid3)
			if cand3 != null and not cand3.is_dead and int(pid3) != t3.leader_id:
				exile = cand3
				old_team = t3
				break
		if exile != null:
			break
	print("   [3] 情境：P%d 是 Team%d 的 named（非 leader）⇒ 照呼叫端：先 remove_member 再自立" % [
		exile.id if exile != null else -1, old_team.team_id if old_team != null else -1])
	_check("★[3] 母體地板：那個人是 named 而【不是】leader（leader 走的是另一支，永遠不流亡）",
		exile != null and old_team != null and exile.id != old_team.leader_id)
	var old_tid3: int = old_team.team_id
	st3.remove_member(old_team, exile.id)   # ★production 的呼叫端就是先做這一件（erase + team_id=-1）
	rs.call("_spawn_exile_or_join", st3, exile, Vector2i(3, 3))
	var a3: Array = _audit(st3)
	print("   [3] 結果：P%d 現在的 team_id = %d（原 %d）｜稽核 %d 條違反%s" % [
		exile.id, exile.team_id, old_tid3, int(a3[0]),
		"" if int(a3[0]) == 0 else "（%s）" % String(a3[1])])
	print("     ★舊隊 roster 還留著他嗎 ＝ %s（呼叫端負責移出，chokepoint 只管目標隊）" % str(
		st3.teams[old_tid3].named_members.has(exile.id)))
	_check("★★[3] 稽核零違反（紅 ⇒ 本票找到第二個）", int(a3[0]) == 0)

	# ④ recruit_tutorial：現造一支流民團 ＋ 現造 leader
	var st4: WorldState = _fresh()
	var rt := RecruitTutorial.new()
	st4.player_forced_event = {}
	st4.player_state.erase("recruit_tutorial_fired")
	# ★前提是【玩家食物盈餘 >= FOOD_THRESHOLD】（recruit_tutorial.gd:11）——
	#   我第一版沒佈置它 ⇒ `check()` 直接 return ⇒ 隊數沒變、稽核當然零違反
	#   ＝ 又一次「情境沒建起來而卷面看起來乾淨」⇒ 母體地板就是為了接住這個。
	var pt4: TeamData = st4.teams.get(st4.get_player_team_id())
	ResourceBank.set_amt(pt4, "food", RecruitTutorial.FOOD_THRESHOLD + 10.0, "bed_fixture_tutorial")
	print("   [4] 佈置：玩家隊食物 ＝ %.0f（門檻 %.0f）" % [
		float(pt4.resources.get("food", 0)), RecruitTutorial.FOOD_THRESHOLD])
	var t4_before: int = st4.teams.size()
	rt.check(st4)
	var a4: Array = _audit(st4)
	print("   ④情境：清掉 forced_event 與 fired 旗 ⇒ 呼 check()｜隊數 %d → %d" % [
		t4_before, st4.teams.size()])
	print("   ④結果：稽核 %d 條違反%s" % [int(a4[0]),
		"" if int(a4[0]) == 0 else "（%s）" % String(a4[1])])
	_check("★④母體地板：真的生了一支隊（沒生 ⇒ 這一格什麼都沒驗）",
		st4.teams.size() > t4_before)
	_check("★★④稽核零違反（紅 ⇒ 本票找到第二個）", int(a4[0]) == 0)

	# ⑤ subteam_system：★具名不改的那一處 —— 不改 ≠ 不驗
	var st5: WorldState = _fresh()
	var ss := SubteamSystem.new()
	var parent: TeamData = null
	for k in st5.teams.keys():
		var t: TeamData = st5.teams[k]
		if t.named_members.size() >= 1 and t.population >= 4:
			parent = t
			break
	var sub_leader_id: int = int(parent.named_members[0]) if parent != null else -1
	var sl: PersonData = st5.persons.get(sub_leader_id)
	print("   ⑤情境：母隊 Team%d（人口 %d）派子隊，子隊 leader ＝ P%d（原 team_id %d）" % [
		parent.team_id if parent != null else -1, parent.population if parent != null else -1,
		sub_leader_id, sl.team_id if sl != null else -1])
	_check("★⑤母體地板：找到可派子隊的母隊與 named 成員", parent != null and sl != null)
	var sub_id: int = ss.dispatch(st5, parent.team_id, sub_leader_id, 2,
		TeamData.TASK_IDLE, Vector2i(-1, -1), -1, "", [])
	var sub: TeamData = st5.teams.get(sub_id)
	var a5: Array = _audit(st5)
	print("   ⑤結果：子隊 Team%d｜leader_id = %d｜P%d 的 team_id = %d｜母隊 roster 還留他 = %s" % [
		sub_id, sub.leader_id if sub != null else -1, sub_leader_id,
		sl.team_id, str(parent.named_members.has(sub_leader_id))])
	print("   ⑤稽核 %d 條違反%s" % [int(a5[0]),
		"" if int(a5[0]) == 0 else "（%s）" % String(a5[1])])
	_check("★★★⑤三件效果都在（leader_id 指他、team_id 指子隊、母隊 roster 不再有他）"
		+ "—— ★這一格就是「具名不改」的那一處要付的代價：它必須被驗",
		sub != null and sub.leader_id == sub_leader_id and sl.team_id == sub_id
			and not parent.named_members.has(sub_leader_id))
	_check("★★⑤稽核零違反", int(a5[0]) == 0)
	print("   ★★★本格的四個情境都印在上面 —— 綠的那些要看得到【情境真的建起來了】，")
	print("     否則「稽核零違反」可能只是那一步根本沒發生（今天已經踩過三次那一族）。")
	_cell("_test_p3_other_four_sites")


func _initialize() -> void:
	print("=== leader_chokepoint bed ===")
	_test_p1_heir_replay()
	_test_p1b_stale_heir_team_id()
	_test_p2_site_accounting()
	_test_p3_other_four_sites()
	var miss: Array = []
	for c in EXPECTED_CELLS:
		if not _cells_ran.has(c):
			miss.append(c)
	if not miss.is_empty():
		_errors += miss.size()
		push_error("[FAIL] 缺席的格：%s" % str(miss))
	print("\n=== leader_chokepoint DONE === errors: %d｜到場點名 %d／%d" % [
		_errors, _cells_ran.size(), EXPECTED_CELLS.size()])
	quit(1 if _errors > 0 else 0)
