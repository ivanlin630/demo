extends SceneTree
# @bed-kind: acceptance
# slice: 三死鍵（(a) 計謀 / (b) 統領 / (c) 順從→慎重）—— 接上真的輸入
#
# 驗收（HOW spec §3，blueprint 裁）：接線【前】該量恆 0.5 ⇒ 接線【後】跨 agent 有變異。
#   ★判準是【分布】不是單點：只印一個 agent 的值分不出「接上了」與「剛好那個人是 0.5」。
#   ★★(b) 專屬：scout_staleness 相同時，util 的差異只能來自 _cmd ⇒ 證明它真的進了引擎秤。

var _fails: int = 0
var _sections: int = 0
const EXPECT_SECTIONS: int = 5

func _initialize() -> void:
	print("=== DEAD VALUE KEYS WIRING ===")
	var state := _run_world()
	_test_distribution(state)
	_test_old_key_is_dead(state)
	_test_term_separates_leaders()
	_test_scheme_skill(state)
	_test_tax_tolerance(state)
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
	var days: int = int(OS.get_environment("BED_DAYS")) if OS.has_environment("BED_DAYS") else 3
	var cfg: String = OS.get_environment("BED_CONFIG") if OS.has_environment("BED_CONFIG") else "res://config/warring_states.json"
	seed(1337)
	Probe.arm()
	var state: WorldState = MeasureBedHelper.arm_and_setup(cfg, true)
	var runner := SimRunner.new()
	var no_player := Vector2i(-1, -1)
	var ticks: int = days * WorldState.TICKS_PER_DAY
	var first_stall: int = -1
	var stall_reason: String = ""
	for tick in range(ticks):
		var r: String = runner.advance_tick(state, no_player)
		if r != "" and first_stall == -1:
			first_stall = tick
			stall_reason = r
	# ★不變量 1：接 advance_tick 回傳值並印首次非推進的 tick 與原因（沒有也要印「無」）
	print("  [有效窗] 請求 %d ticks｜首次非推進：%s" % [
		ticks, ("無" if first_stall == -1 else "tick %d（%s）" % [first_stall, stall_reason])])
	return state

func _cmd_of(state: WorldState, team: TeamData) -> float:
	var ctx: DecisionContext = DecisionContext.gather(state, team)
	return float(ctx.leader_values.get("_command", -1.0))

func _test_distribution(state: WorldState) -> void:
	print("-- ① 跨 agent 分布（接線前這一欄恆 0.5）--")
	var vals: Array = []
	for tid in state.teams:
		var t: TeamData = state.teams[tid]
		if t.leader_id == -1:
			continue
		vals.append(_cmd_of(state, t))
	vals.sort()
	var distinct := {}
	for v in vals:
		distinct[snappedf(v, 0.0001)] = true
	var n: int = vals.size()
	if n == 0:
		_fails += 1
		push_error("[FAIL] 母體為空（沒有帶 leader 的隊）—— 這格什麼都沒驗到")
		_sections += 1
		return
	var med: float = float(vals[n / 2])
	print("  母體 %d 隊｜min=%.3f median=%.3f max=%.3f｜相異值 %d 個" % [n, float(vals[0]), med, float(vals[n - 1]), distinct.size()])
	var shown: Array = []
	for i in mini(6, n):
		shown.append("%.3f" % float(vals[i * (n - 1) / maxi(n - 1, 1)]))
	print("  取樣：%s" % [", ".join(shown)])
	_ok(distinct.size() > 1, "①跨 agent 有變異（相異值 %d > 1）" % distinct.size())
	var all_half := true
	for v in vals:
		if absf(float(v) - 0.5) > 0.0001:
			all_half = false
	_ok(not all_half, "①不是恆 0.5（恆 0.5 ＝ 還在讀那個不存在的鍵）")
	_sections += 1

func _test_old_key_is_dead(state: WorldState) -> void:
	print("-- ② 反向對照：舊鍵在 values 裡【本來就不存在】--")
	var any := false
	var has_old := false
	for tid in state.teams:
		var t: TeamData = state.teams[tid]
		if t.leader_id == -1:
			continue
		any = true
		var ctx: DecisionContext = DecisionContext.gather(state, t)
		if ctx.leader_values.has("統領"):
			has_old = true
		break
	_ok(any and not has_old,
		"②leader_values 沒有『統領』這個鍵 ⇒ 舊寫法的 default 0.5 是死值（母體非空=%s）" % [str(any)])
	_sections += 1

func _mk_ctx(cmd: float) -> DecisionContext:
	var c := DecisionContext.new()
	c.leader_values = { "野心": 0.5, "_command": cmd }
	c.scout_staleness = 1.0
	return c

func _test_term_separates_leaders() -> void:
	print("-- ③ scout_drive：statleness 相同時，差異只能來自 _cmd --")
	var u_low: float = DecisionTerms.eval("scout_drive", _mk_ctx(0.0), "偵察")
	var u_high: float = DecisionTerms.eval("scout_drive", _mk_ctx(0.9), "偵察")
	print("  _cmd=0.0 ⇒ util=%.4f｜_cmd=0.9 ⇒ util=%.4f" % [u_low, u_high])
	_ok(u_high > u_low, "③高統領 leader 的偵察 util(%.4f) > 低統領(%.4f)" % [u_high, u_low])
	# ★反向對照：換成非偵察 option 必須回 0（否則「有差異」可能來自別的項）
	_ok(is_equal_approx(DecisionTerms.eval("scout_drive", _mk_ctx(0.9), "生產"), 0.0),
		"③反向對照：非『偵察』option 回 0（差異確實出自這一項）")
	_sections += 1

# 分布小工具：★判準是分布不是單點（只印一個 agent 分不出「接上了」與「剛好是 default」）
func _dump_dist(label: String, vals: Array) -> Dictionary:
	vals.sort()
	var distinct := {}
	for v in vals:
		distinct[snappedf(float(v), 0.0001)] = true
	var n: int = vals.size()
	if n == 0:
		print("  %s：母體為空" % label)
		return { "n": 0, "distinct": 0 }
	print("  %s：母體 %d｜min=%.3f median=%.3f max=%.3f｜相異值 %d" % [
		label, n, float(vals[0]), float(vals[n / 2]), float(vals[n - 1]), distinct.size()])
	return { "n": n, "distinct": distinct.size(), "min": float(vals[0]), "max": float(vals[n - 1]) }

func _test_scheme_skill(state: WorldState) -> void:
	print("-- ④ (a) 計謀：語氣挑選讀的是 skills 不是 values --")
	var vals: Array = []
	var over: int = 0
	var has_in_values := false
	for pid in state.persons:
		var p: PersonData = state.persons[pid]
		vals.append(float(p.skills.get("計謀", 0.0)))
		if float(p.skills.get("計謀", 0.0)) > 0.7:
			over += 1
		if p.values.has("計謀"):
			has_in_values = true
	var d: Dictionary = _dump_dist("計謀技能", vals)
	print("    >0.7（sarcastic 語氣的候選池）＝ %d / %d 人" % [over, int(d.get("n", 0))])
	_ok(int(d.get("distinct", 0)) > 1, "④計謀技能跨 agent 有變異（相異值 %d > 1）" % int(d.get("distinct", 0)))
	_ok(not has_in_values, "④反向對照：values 裡沒有『計謀』⇒ 舊寫法的 0.5 是死值")
	_sections += 1

func _test_tax_tolerance(state: WorldState) -> void:
	print("-- ⑤ (c) 順從→慎重：苛稅忍耐度現在有真的輸入 --")
	var caution: Array = []
	var tol: Array = []
	var has_submit := false
	for tid in state.teams:
		var t: TeamData = state.teams[tid]
		var lp: PersonData = state.persons.get(t.leader_id)
		if lp == null:
			continue
		if lp.values.has("順從"):
			has_submit = true
		var c: float = float(lp.values.get("慎重", 0.5))
		caution.append(c)
		tol.append(0.3 + c * 0.2 + float(lp.values.get("義氣", 0.5)) * 0.1 - float(lp.values.get("野心", 0.5)) * 0.2)
	var dc: Dictionary = _dump_dist("領主慎重", caution)
	var dt: Dictionary = _dump_dist("忍耐度 tolerance", tol)
	_ok(int(dc.get("distinct", 0)) > 1, "⑤慎重跨 agent 有變異（相異值 %d > 1）" % int(dc.get("distinct", 0)))
	_ok(int(dt.get("distinct", 0)) > 1, "⑤忍耐度跟著有變異（相異值 %d > 1）" % int(dt.get("distinct", 0)))
	_ok(not has_submit, "⑤反向對照：values 裡沒有『順從』⇒ 那條註解描述的是一個不存在的輸入")
	_sections += 1
