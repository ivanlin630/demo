extends SceneTree
# @bed-kind: acceptance
# slice: B1 —— ctx 生存/經濟兩頁端到查詢面
#
# 驗收（spec §②）：①該頁欄位 status=exposed 且 who 寫【哪支動詞】②覆蓋率閘 PASS
#   ③★★★該頁欄位【真的能從 agent 層拿到】—— 不是「函式存在」，是【呼叫它拿得到值】
#     （C1 血證：map_global_messages 早就存在，卻只接了 GUI）

var _fails: int = 0
var _sections: int = 0
const EXPECT_SECTIONS: int = 4

func _initialize() -> void:
	print("=== CTX EXPOSE B1（生存＋經濟）===")
	var st := _run_world()
	_test_snapshot_reachable(st)
	_test_pages_covered(st)
	_test_observe_path_clean(st)
	_test_snapshot_not_in_fp(st)
	if _sections != EXPECT_SECTIONS:
		_fails += 1
		push_error("[FAIL] 只跑完 %d/%d 段 —— 中途崩掉" % [_sections, EXPECT_SECTIONS])
	print("=== DONE === SECTIONS=%d/%d FAILS=%d" % [_sections, EXPECT_SECTIONS, _fails])
	quit()

func _ok(cond: bool, msg: String) -> void:
	if cond:
		print("  PASS: " + msg)
	else:
		_fails += 1
		push_error("[FAIL] " + msg)

func _run_world() -> WorldState:
	seed(1337)
	Probe.arm()
	var st: WorldState = MeasureBedHelper.arm_and_setup("res://config/warring_states.json", false)
	# 附身到某支有 leader 的隊 ⇒ 引擎下一次 gather 才會替它存快照
	for tid in st.teams:
		var t: TeamData = st.teams[tid]
		if t.leader_id != -1 and st.persons.has(t.leader_id):
			st.player_id = t.leader_id
			break
	var runner := SimRunner.new()
	for _t in range(WorldState.TICKS_PER_DAY):
		runner.advance_tick(st, Vector2i(-1, -1))
	return st

func _pages_of(field: String) -> String:
	var f := FileAccess.open("res://docs/process/ctx-exposure.tsv", FileAccess.READ)
	if f == null:
		return ""
	var out: String = ""
	for line in f.get_as_text().split("\n"):
		var l: String = String(line)
		if l.begins_with("#") or l == "":
			continue
		var cols: PackedStringArray = l.split("\t")
		if cols.size() >= 3 and String(cols[0]) == field:
			out = String(cols[2])
	f.close()
	return out

func _test_snapshot_reachable(st: WorldState) -> void:
	print("-- ③ agent 層【真的拿得到】（不是「函式存在」）--")
	var q := PlayerQueryApi.new()
	var r: Dictionary = q.get_decision_snapshot(st)
	var d: Dictionary = r.get("data", {})
	var fields: Dictionary = d.get("fields", {})
	print("    ok=%s snapshot=%s tick=%s age=%s｜欄位數 %d" % [
		str(r.get("ok", false)), str(d.get("snapshot", false)),
		str(d.get("snapshot_tick", -1)), str(d.get("age_ticks", -1)), fields.size()])
	_ok(bool(r.get("ok", false)) and bool(d.get("snapshot", false)),
		"③呼叫 get_decision_snapshot 真的拿到快照（不是 note）")
	_ok(fields.size() >= 100, "③快照涵蓋 %d 個欄位（★用 get_property_list 抽，新欄位會自己進來）" % fields.size())
	_ok(int(d.get("age_ticks", -1)) >= 0, "③快照有【年紀】欄 ⇒ 讀的人看得到它多舊")
	# ★成對對照：沒附身的世界 ⇒ 必須回 note 而不是空 fields 假裝有
	var st2 := WorldState.new()
	st2.world = WorldData.new()
	var p := PersonData.new()
	p.id = 1
	p.team_id = 9
	st2.persons[1] = p
	st2.player_id = 1
	var t9 := TeamData.new()
	t9.team_id = 9
	st2.teams[9] = t9
	var r2: Dictionary = q.get_decision_snapshot(st2)
	_ok(not bool((r2.get("data", {}) as Dictionary).get("snapshot", true)),
		"★成對對照：還沒跑過決策 ⇒ 明說【尚無快照】，不是回一堆 0 假裝有")
	_sections += 1

func _test_pages_covered(st: WorldState) -> void:
	print("-- ①② 生存/經濟兩頁：表上 exposed 且值真的在快照裡 --")
	var q := PlayerQueryApi.new()
	var fields: Dictionary = (q.get_decision_snapshot(st).get("data", {}) as Dictionary).get("fields", {})
	var f := FileAccess.open("res://docs/process/ctx-exposure.tsv", FileAccess.READ)
	var missing: Array = []
	var b1_total: int = 0
	var not_exposed: Array = []
	if f != null:
		for line in f.get_as_text().split("\n"):
			var l: String = String(line)
			if l.begins_with("#") or l == "" or l.begins_with("field\t"):
				continue
			var c: PackedStringArray = l.split("\t")
			if c.size() < 4:
				continue
			var name: String = String(c[0])
			var status: String = String(c[1])
			var pages: String = String(c[2])
			if not (pages.contains("生存") or pages.contains("經濟")):
				continue
			b1_total += 1
			if not fields.has(name):
				missing.append(name)
			if status != "exposed":
				not_exposed.append(name)
		f.close()
	print("    B1（生存＋經濟）欄位 %d｜快照裡缺 %d｜表上還不是 exposed 的 %d" % [
		b1_total, missing.size(), not_exposed.size()])
	if missing.size() > 0:
		print("    缺：%s" % [", ".join(missing.slice(0, mini(8, missing.size())))])
	_ok(b1_total > 0, "①B1 母體非空（%d 欄）" % b1_total)
	_ok(missing.is_empty(), "③B1 每一欄都在快照裡拿得到（缺 %d）" % missing.size())
	_ok(not_exposed.is_empty(), "①表上 B1 全部標 exposed（還沒改的 %d）" % not_exposed.size())
	_sections += 1

func _test_observe_path_clean(st: WorldState) -> void:
	print("-- ★observe 路徑不得寫快照（純讀路徑的鐵律）--")
	var t: TeamData = st.teams[(st.persons[st.player_id] as PersonData).team_id]
	var before_tick: int = t.ctx_snapshot_tick
	st.world.current_tick += 1
	DecisionContext.gather(st, t, false)   # ★observe（advance=false）
	print("    observe 一次：snapshot_tick %d → %d" % [before_tick, t.ctx_snapshot_tick])
	_ok(t.ctx_snapshot_tick == before_tick,
		"★observe 路徑【沒有】更新快照 —— 快照只在引擎 advance 那條路寫（purity 床守的同一條）")
	_sections += 1

func _test_snapshot_not_in_fp(st: WorldState) -> void:
	print("-- ★寫快照【不動 fp】：直接量，不是宣稱 --")
	var t: TeamData = st.teams[(st.persons[st.player_id] as PersonData).team_id]
	var fp_before: String = StateFingerprint.compute(st)
	# ★直接動快照欄位（模擬引擎又寫了一次，且內容不同）
	t.ctx_snapshot = { "fake": 12345 }
	t.ctx_snapshot_tick = st.world.current_tick + 999
	var fp_after: String = StateFingerprint.compute(st)
	print("    fp 改快照前 %s ／ 後 %s" % [fp_before.substr(0, 12), fp_after.substr(0, 12)])
	_ok(fp_before == fp_after,
		"★快照欄位不進 fp（_emit_teams 是逐欄白名單）⇒ 加這兩欄不改世界")
	# ★成對對照：動一個【真的在 fp 裡】的欄位 ⇒ fp 必須變（否則上面那格是恆真）
	t.unrest_turns += 1
	_ok(StateFingerprint.compute(st) != fp_after,
		"★成對對照：動 unrest_turns（在 fp 白名單裡）⇒ fp 真的變了")
	_sections += 1
