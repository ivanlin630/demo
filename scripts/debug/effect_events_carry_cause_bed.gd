extends SceneTree
# @bed-kind: acceptance
# slice: 果事件帶因（ticker 一跳到因）
#
# 驗收（spec §4）：①逐 emit 點對帳表落地，「無因」要分【產生端沒有】與【有但沒印】
#   ②代表案例＝replace（因現成）★求和/派工失敗不在本票（走裸 print，不碰 global_messages）
#   ④fp 不變 ⑤逐 type 計數不變（★總數不變擋不住「刪一則、別處加一則」的淨零）

const LEDGER: String = "res://docs/process/event-cause-ledger.tsv"

var _fails: int = 0
var _sections: int = 0
const EXPECT_SECTIONS: int = 3

func _initialize() -> void:
	print("=== EFFECT EVENTS CARRY CAUSE ===")
	_test_replace_cause()
	_test_combat_start_cause()
	_test_ledger()
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

func _mk() -> WorldState:
	var st := WorldState.new()
	st.world = WorldData.new()
	st.world.current_tick = 6000
	return st

func _mk_team(st: WorldState, tid: int) -> TeamData:
	var t := TeamData.new()
	t.team_id = tid
	t.tile_pos = Vector2i(1, 1)
	AnonTierSystem.add_anon(t, "平民", 10)
	var p := PersonData.new()
	p.id = 700 + tid
	p.team_id = tid
	p.loyalty = 0.1                    # ★異議者：忠誠低於 LOYALTY_LEAVE_THRESHOLD
	p.skills = { "統領": 0.9 }
	st.persons[p.id] = p
	t.named_members = [p.id]
	var ldr := PersonData.new()
	ldr.id = 800 + tid
	ldr.team_id = tid
	st.persons[ldr.id] = ldr
	t.leader_id = ldr.id
	st.teams[tid] = t
	return t

func _test_replace_cause() -> void:
	print("-- ② 代表案例 replace：因【現成】--")
	var st := _mk()
	var t := _mk_team(st, 1)
	t.unrest_turns = 25            # ★過 UNREST_REPLACE_THRESHOLD(20)
	var ev = load("res://scripts/simulation/events/event_unrest_replace.gd").new()
	var before: int = st.global_messages.size()
	if ev.check(st, t):
		ev.execute(st, t)
	print("    global_messages %d → %d" % [before, st.global_messages.size()])
	var found: Dictionary = {}
	for m in st.global_messages:
		if m is Dictionary and String(m.get("type", "")) == "replace":
			found = m
		elif m is MessageData and m.type == "replace":
			found = { "type": m.type, "description": m.description, "params": m.params }
	print("    replace 訊息：%s" % str(found.get("description", "（無）")))
	_ok(not found.is_empty(), "②replace 事件有發出（前置：unrest 25 ≥ 20 且有異議者）")
	var desc: String = String(found.get("description", ""))
	_ok(desc.contains("25") and desc.contains("異議者"),
		"②★因【真的來自 state】：訊息裡有 unrest 回合數與異議者人數（不是固定文案）")
	var params: Dictionary = found.get("params", {})
	_ok(params.has("cause") and String(params["cause"]) != "",
		"②cause 也進了 params（★約定欄位，不是新事件族）")
	_sections += 1

func _test_combat_start_cause() -> void:
	print("-- 宣戰帶因（★只印產生端已讀到的量）--")
	var st := _mk()
	var a := _mk_team(st, 2)
	var b := _mk_team(st, 3)
	a.current_task = TeamData.TASK_ATTACK
	a.task_reason = "掠奪：糧不足"
	a.readiness = 0.8
	b.readiness = 0.4
	NpcCombatSystem.new().start_combat(st, 2, 3)
	var desc: String = ""
	var cause: String = ""
	for m in st.global_messages:
		var ty: String = String(m.get("type", "")) if m is Dictionary else (m.type if m is MessageData else "")
		if ty == "combat_start":
			desc = String(m.get("description", "")) if m is Dictionary else m.description
			var pr: Dictionary = (m.get("params", {}) if m is Dictionary else m.params)
			cause = String(pr.get("cause", ""))
	print("    combat_start：%s" % desc)
	_ok(desc.contains("掠奪：糧不足"), "宣戰的因來自 task_reason（★產生端已經讀到的東西）")
	_ok(cause.contains("0.80") and cause.contains("0.40"), "雙方 readiness 也在因裡（%s）" % cause)
	# ★成對對照：把 task_reason 清空 ⇒ 因要顯示「（無）」而不是消失
	var st2 := _mk()
	var c := _mk_team(st2, 4)
	var d := _mk_team(st2, 5)
	c.current_task = TeamData.TASK_ATTACK
	NpcCombatSystem.new().start_combat(st2, 4, 5)
	var desc2: String = ""
	for m in st2.global_messages:
		var ty2: String = String(m.get("type", "")) if m is Dictionary else (m.type if m is MessageData else "")
		if ty2 == "combat_start":
			desc2 = String(m.get("description", "")) if m is Dictionary else m.description
	print("    無 task_reason 時：%s" % desc2)
	_ok(desc2.contains("（無）"),
		"★成對對照：沒有 reason 時印【（無）】而不是靜默省略 —— 讀的人分得出「沒有因」與「沒印因」")
	_sections += 1

func _test_ledger() -> void:
	print("-- ① 逐 emit 點對帳表 --")
	var f := FileAccess.open(LEDGER, FileAccess.READ)
	if f == null:
		_fails += 1
		push_error("[FAIL] 對帳表不存在：%s" % LEDGER)
		_sections += 1
		return
	var rows: Array = []
	for line in f.get_as_text().split("\n"):
		var l: String = String(line)
		if l == "" or l.begins_with("#") or l.begins_with("type\t"):
			continue
		rows.append(l.split("\t"))
	f.close()
	var yes: int = 0
	var no_note: int = 0
	var tmpl: int = 0
	for r in rows:
		if (r as Array).size() < 5:
			continue
		if String(r[2]) == "yes":
			yes += 1
		if String(r[3]) == "template":
			tmpl += 1
		if String(r[4]).strip_edges() == "":
			no_note += 1
	print("    emit 點 %d 列｜帶因 %d｜template 型 %d｜沒有 note 的列 %d" % [rows.size(), yes, tmpl, no_note])
	_ok(rows.size() >= 23, "①母體 ≥ 23（★含 events/ 子目錄——原清單漏掉整個目錄）")
	_ok(yes >= 2, "①本票帶因的兩則在表上（replace／combat_start）")
	_ok(no_note == 0, "①每一列都有 note（無因的要說是【產生端沒有】還是【有但沒印】）")
	# ★成對對照：表【不是全 yes】——否則它沒有在區分任何東西
	_ok(yes < rows.size(), "①★對照：表上仍有 %d 列【沒有因】⇒ 這張表真的在分辨，不是全部打勾" % (rows.size() - yes))
	_sections += 1
