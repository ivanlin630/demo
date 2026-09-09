extends SceneTree
# @bed-kind: acceptance
# slice: 失敗反饋 階段 2 第一批（乞食接線；外交/求和 blocked 見 handback）
#
# 驗收（HOW spec §6）：①join 表 28 列全印（含成對對照：判準不成立的 option 不得進候選）
#   ②三題答案在 code 裡看得到（target 粒度／TTL 來源）
#   ③折價真的生效（連撞→乘數下降＋failure.suppressed 非零；成對對照：沒 record ⇒ 1.0）
#   ④已接的 買糧/買料 曲線不變
#   ⑤咬不咬人：raw/eff/gate（★短窗下 eff/gate 只能回答「沒翻轉」）

var _fails: int = 0
var _sections: int = 0
const EXPECT_SECTIONS: int = 5

func _initialize() -> void:
	print("=== FAILURE FEEDBACK STAGE 2 ===")
	_test_join_table()
	_test_three_questions()
	_test_discount_bites()
	_test_existing_unchanged()
	_test_world_raw_eff_gate()
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

func _bucket(opt: String) -> String:
	if FailureMemory.OPTION_FAIL_KEY.has(opt):
		return "已接"
	var why: String = String(FailureMemory.NO_FAILURE_FEEDBACK.get(opt, ""))
	if why.begins_with("TODO:"):
		return "待接"
	if why.begins_with("已有等價機制:"):
		return "已有等價"
	if why == "":
		return "★未分類"
	return "判準不成立"

# 候選過濾器（★真檢查與成對對照走同一個函式）
func _candidates(opts: Array) -> Array:
	var out: Array = []
	for o in opts:
		if _bucket(o) == "待接":
			out.append(o)
	return out

func _test_join_table() -> void:
	print("-- ① join 表（28 列全印；★unmapped 次數不能單獨當排序鍵）--")
	var opts: Array = DecisionOptions.REGISTRY.keys()
	opts.sort()
	print("  %-10s %-10s %s" % ["option", "桶", "理由/接線"])
	for o in opts:
		var b: String = _bucket(o)
		var detail: String = ""
		if b == "已接":
			detail = "key=%s target=%s" % [String(FailureMemory.OPTION_FAIL_KEY[o][0]), String(FailureMemory.OPTION_FAIL_KEY[o][1])]
		else:
			detail = String(FailureMemory.NO_FAILURE_FEEDBACK.get(o, "")).substr(0, 64)
		print("  %-10s %-10s %s" % [o, b, detail])
	var cands: Array = _candidates(opts)
	print("  候選（只從【待接】桶取）：%d 條" % cands.size())
	_ok(opts.size() == 28, "①28 列全在（實得 %d）" % opts.size())
	var bad: Array = []
	for c in cands:
		if _bucket(c) != "待接":
			bad.append(c)
	_ok(bad.is_empty(), "①候選全部來自【待接】桶")
	# ★成對對照：把一個【判準不成立】的 option 塞進來 ⇒ 過濾器必須擋掉
	var polluted: Array = opts.duplicate()
	polluted.append("迎戰")   # 判準不成立
	var c2: Array = _candidates(polluted)
	_ok(not ("迎戰" in c2), "①對照：判準不成立的『迎戰』被擋在候選外（它 unmapped 排第 2）")
	_sections += 1

func _test_three_questions() -> void:
	print("-- ② 三題答案在 code 裡看得到 --")
	var e = FailureMemory.OPTION_FAIL_KEY.get("乞食")
	_ok(e != null, "②乞食已進 OPTION_FAIL_KEY")
	if e != null:
		print("    ①失敗＝乞食被拒（aid_refused）｜②target=%s｜③TTL=BELIEF_STALE_TICKS(%d tick=%d 天)" % [
			String(e[1]), BeliefSystem.BELIEF_STALE_TICKS, BeliefSystem.BELIEF_STALE_TICKS / WorldState.TICKS_PER_DAY])
		_ok(String(e[1]).begins_with("ctx:"),
			"②target 是【逐次目標】不是寫死字串（接太粗＝一次失敗對所有施主折價）")
	# TTL 不是憑空數字：三個 record 點都用同一個既有週期常數
	var n_sites: int = 0
	for f in ["res://scripts/simulation/interaction_system.gd",
			"res://scripts/simulation/player_command_system.gd",
			"res://scripts/simulation/sim_runner.gd"]:
		var fa := FileAccess.open(f, FileAccess.READ)
		if fa == null:
			continue
		var src: String = fa.get_as_text()
		fa.close()
		if src.contains('FailureMemory.record(state,') and src.contains("BeliefSystem.BELIEF_STALE_TICKS"):
			n_sites += 1
	_ok(n_sites == 3, "②三個拒絕入口都記了同一個事件（實得 %d/3）—— 被誰拒不該決定有沒有學到" % n_sites)
	_sections += 1

func _mk_ctx(aid: int) -> DecisionContext:
	var c := DecisionContext.new()
	c.aid_target_id = aid
	return c

func _test_discount_bites() -> void:
	print("-- ③ 折價真的生效（連撞→下降）--")
	var st := WorldState.new()
	st.world = WorldData.new()
	st.world.current_tick = 1000
	var t := TeamData.new()
	t.team_id = 7
	st.teams[7] = t
	var before_sup: int = int(Probe.counts.get("failure.suppressed.乞食", 0))
	# ★成對對照（先跑）：沒有 record ⇒ 必須是 1.0
	_ok(is_equal_approx(FailureMemory.mult_for_option(st, t, "乞食", _mk_ctx(3)), 1.0),
		"③對照：沒有失敗記憶 ⇒ 乘數 1.0（零行為）")
	Probe.enabled = true
	var seq: Array = []
	for i in 3:
		FailureMemory.record(st, t, "乞食", "3", BeliefSystem.BELIEF_STALE_TICKS, "aid_refused")
		seq.append(FailureMemory.mult_for_option(st, t, "乞食", _mk_ctx(3)))
	print("    對施主 3 連撞三次：%.3f → %.3f → %.3f" % [float(seq[0]), float(seq[1]), float(seq[2])])
	_ok(float(seq[0]) < 1.0 and float(seq[1]) < float(seq[0]) and float(seq[2]) < float(seq[1]),
		"③連撞同一個施主 ⇒ 乘數逐次下降")
	_ok(int(Probe.counts.get("failure.suppressed.乞食", 0)) > before_sup,
		"③failure.suppressed.乞食 有非零計數")
	# ★★另一個施主【不受影響】—— 這格證明 target 粒度真的生效（接太粗會一起被折）
	_ok(is_equal_approx(FailureMemory.mult_for_option(st, t, "乞食", _mk_ctx(9)), 1.0),
		"③換一個施主(9) ⇒ 乘數回 1.0（折價沒有波及無辜目標）")
	# ★★★不知道對誰（-1）⇒ 不折價
	_ok(is_equal_approx(FailureMemory.mult_for_option(st, t, "乞食", _mk_ctx(-1)), 1.0),
		"③目標未知(-1) ⇒ 不折價（「不知道對誰」≠「對誰都一樣」）")
	Probe.enabled = false
	_sections += 1

func _test_existing_unchanged() -> void:
	print("-- ④ 已接的 買糧/買料 曲線不變 --")
	var st := WorldState.new()
	st.world = WorldData.new()
	st.world.current_tick = 1000
	var t := TeamData.new()
	t.team_id = 8
	st.teams[8] = t
	var got: Array = []
	for i in 3:
		FailureMemory.record(st, t, "買單", "food", WorldState.TICKS_PER_DAY * 5, "order_expired")
		got.append(FailureMemory.mult_for_option(st, t, "買糧"))
	# 期望值由公式重算（★不抄 code 算好的值）：freshness=1（同 tick）⇒ 1 − INTENSITY×count
	var want: Array = []
	for i in 3:
		want.append(clampf(1.0 - FailureMemory.INTENSITY * float(mini(i + 1, FailureMemory.COUNT_CAP)), FailureMemory.FLOOR, 1.0))
	print("    買糧 三次：實得 %.3f/%.3f/%.3f｜公式重算 %.3f/%.3f/%.3f" % [
		float(got[0]), float(got[1]), float(got[2]), float(want[0]), float(want[1]), float(want[2])])
	var same: bool = true
	for i in 3:
		if absf(float(got[i]) - float(want[i])) > 0.001:
			same = false
	_ok(same, "④買糧曲線與公式一致（本票沒動折價公式，只餵它）")
	_ok(is_equal_approx(FailureMemory.mult_for_option(st, t, "乞食", _mk_ctx(3)), 1.0),
		"④對照：買單失敗【不會】波及乞食（不同 key）")
	_sections += 1

func _test_world_raw_eff_gate() -> void:
	print("-- ⑤ 咬不咬人：raw / eff / gate --")
	var days: int = int(OS.get_environment("BED_DAYS")) if OS.has_environment("BED_DAYS") else 1
	seed(1337)
	Probe.arm()
	var state: WorldState = MeasureBedHelper.arm_and_setup("res://config/warring_states.json", true)
	var runner := SimRunner.new()
	var first_stall: int = -1
	var reason: String = ""
	for tick in range(days * WorldState.TICKS_PER_DAY):
		var r: String = runner.advance_tick(state, Vector2i(-1, -1))
		if r != "" and first_stall == -1:
			first_stall = tick
			reason = r
	print("  [有效窗] 請求 %d ticks｜首次非推進：%s" % [days * WorldState.TICKS_PER_DAY,
		("無" if first_stall == -1 else "tick %d（%s）" % [first_stall, reason])])
	var rec: int = int(Probe.counts.get("failure.recorded.aid_refused", 0)) \
		+ int(Probe.counts.get("failure.recorded.aid_refused_player", 0)) \
		+ int(Probe.counts.get("failure.recorded.aid_refused_timeout", 0))
	var sup: int = int(Probe.counts.get("failure.suppressed.乞食", 0))
	var unmapped_beg: int = int(Probe.counts.get("failure.unmapped.乞食", 0))
	print("  raw（記下的乞食失敗事件）%d｜eff（折價真的乘進 util 的次數）%d｜gate（本票沒有動任何 applicable 閘）n/a" % [rec, sup])
	# ★★★raw=0 有兩種意思，而它們長得一樣：①乞食根本沒被嘗試 ②嘗試了但沒被拒。
	#   ⇒ 印出上游計數，讓那個 0 可以被分解（同「catch-all 分類必須可分解」那條）。
	var desperate: int = 0
	for tid in state.teams:
		var c: DecisionContext = DecisionContext.gather(state, state.teams[tid])
		if c.food_days < c.desperation_entry_threshold:
			desperate += 1
	print("  ★raw=0 的分解：入絕境的隊 %d｜aid.calls %d（找施主被呼叫幾次）｜beg 任務指派 %d" % [
		desperate, int(Probe.counts.get("aid.calls", 0)), int(Probe.counts.get("task.乞食", 0))])
	print("  ★短窗誠實限：eff=0 只能讀成【這個窗裡沒有翻轉】，不能讀成【不咬人】——"
		+ "乞食要先有隊餓到 desperation 且找得到施主，%d 天窗未必產生得出來。" % days)
	_ok(unmapped_beg == 0, "⑤乞食不再出現在 failure.unmapped（它已經走 OPTION_FAIL_KEY 那條路，實得 %d）" % unmapped_beg)
	_sections += 1
