extends SceneTree
# @bed-kind: acceptance
# slice: 失敗反饋 階段 1（結構列舉）
#
# 驗收（HOW spec §4，四格）：①涵蓋（成對對照：假 option 必須被具名）
#   ②缺席可見（failure.unmapped.* 可排序；★成對對照：已 mapped 的買糧不得出現）
#   ③不改行為（本票零行為改動 ⇒ fingerprint 不變；★本床印出 fp，比對在兩棵樹之間做）
#   ④理由不是空話（每條含 ①②③／已有等價機制／TODO:，且 TODO 的票要存在）

var _fails: int = 0
var _sections: int = 0
const EXPECT_SECTIONS: int = 4

func _initialize() -> void:
	print("=== FAILURE FEEDBACK COVERAGE ===")
	_test_coverage()
	_test_reasons()
	var state := _run_world()
	_test_unmapped_visible(state)
	_test_fingerprint(state)
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

# 分類器：回 {"missing":[...], "both":[...]}（★真檢查與陽性對照走【同一個函式】）
func _classify(opt_names: Array) -> Dictionary:
	var missing: Array = []
	var both: Array = []
	for o in opt_names:
		var in_m: bool = FailureMemory.OPTION_FAIL_KEY.has(o)
		var in_n: bool = FailureMemory.NO_FAILURE_FEEDBACK.has(o)
		if not in_m and not in_n:
			missing.append(o)
		elif in_m and in_n:
			both.append(o)
	return { "missing": missing, "both": both }

func _test_coverage() -> void:
	print("-- ① 涵蓋：28 個 option 全部剛好在一份表裡 --")
	var opts: Array = DecisionOptions.REGISTRY.keys()
	var r: Dictionary = _classify(opts)
	print("  option %d｜有失敗反饋 %d｜已決定不需要/待接 %d" % [
		opts.size(), FailureMemory.OPTION_FAIL_KEY.size(), FailureMemory.NO_FAILURE_FEEDBACK.size()])
	_ok((r["missing"] as Array).is_empty(), "①沒有 option 落在兩份表之外（缺 %s）" % [str(r["missing"])])
	_ok((r["both"] as Array).is_empty(), "①沒有 option 同時在兩份表（重 %s）" % [str(r["both"])])
	# ★成對對照：故意餵一個假 option ⇒ 分類器必須具名它（否則「沒有缺」是恆真）
	var fake: Array = opts.duplicate()
	fake.append("假選項ZZ")
	var rf: Dictionary = _classify(fake)
	_ok("假選項ZZ" in (rf["missing"] as Array), "①對照：假 option 被具名為缺（實得 %s）" % [str(rf["missing"])])
	_sections += 1

func _test_reasons() -> void:
	print("-- ④ 理由不是空話 --")
	var bad: Array = []
	var todo_n: int = 0
	var equiv_n: int = 0
	var decided_n: int = 0
	for o in FailureMemory.NO_FAILURE_FEEDBACK:
		var why: String = String(FailureMemory.NO_FAILURE_FEEDBACK[o])
		if why.begins_with("TODO:"):
			todo_n += 1
		elif why.begins_with("已有等價機制:"):
			equiv_n += 1
		elif why.begins_with("①") or why.begins_with("②") or why.begins_with("③"):
			decided_n += 1
		else:
			bad.append(o)
	print("  待接(TODO) %d｜已有等價機制 %d｜判準不成立 %d｜說不清 %d" % [todo_n, equiv_n, decided_n, bad.size()])
	_ok(bad.is_empty(), "④每條理由都指名判準或票（說不清的：%s）" % [str(bad)])
	# ★TODO 指的票必須存在（born-with 過期紅）
	var ticket: String = FailureMemory.TODO_TICKET
	_ok(FileAccess.file_exists("res://" + ticket), "④TODO 指的票存在：%s" % ticket)
	_sections += 1

func _run_world() -> WorldState:
	var days: int = int(OS.get_environment("BED_DAYS")) if OS.has_environment("BED_DAYS") else 2
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
	return state

func _test_unmapped_visible(_state: WorldState) -> void:
	print("-- ② 缺席可見（★數的是【決策次數】不是失敗次數）--")
	var rows: Array = []
	for k in Probe.counts:
		var ks: String = String(k)
		if ks.begins_with("failure.unmapped."):
			rows.append({ "opt": ks.substr("failure.unmapped.".length()), "n": int(Probe.counts[k]) })
	rows.sort_custom(func(a, b): return int(a["n"]) > int(b["n"]))
	print("  unmapped 種類 %d｜前 5 名：" % rows.size())
	for i in mini(5, rows.size()):
		print("    %-10s %d" % [String(rows[i]["opt"]), int(rows[i]["n"])])
	_ok(rows.size() > 0, "②有非零的 unmapped 計數（可排序＝可決定先接哪幾個）")
	# ★成對對照：已 mapped 的「買糧」不得出現在 unmapped 裡（否則這個計數器在數錯東西）
	var has_mapped: bool = false
	for r in rows:
		if FailureMemory.OPTION_FAIL_KEY.has(String(r["opt"])):
			has_mapped = true
	_ok(not has_mapped, "②對照：已 mapped 的 option（買糧/買料）不出現在 unmapped 裡")
	_sections += 1

func _test_fingerprint(state: WorldState) -> void:
	print("-- ③ 不改行為：fingerprint（★比對在兩棵樹之間做，本床只負責印）--")
	var fp: String = StateFingerprint.compute(state)
	print("  WORLD-FP %s" % fp)
	_ok(fp != "", "③fingerprint 算得出來（實際比對＝同 seed 同窗，改動前後兩棵樹要相同）")
	_sections += 1
