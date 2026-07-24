extends SceneTree

# means-end S5 委派 peer option TDD（HOW spec §10 S5+§5）。build/settle action 產「派子隊做」變體
# 進 rank 池跟「自己做」並列競 util。★gate② 正解:委派 applicable=真 viability(pop−settler≥MIN_PARENT
# _POP=10,attempt=dispatch 同源→無 pop 8-12 浪費帶)。★whole-system-first:S5 只委派+gate②+餘力。

var _fail: int = 0

func _initialize() -> void:
	_test_delegate_variant_appears()  # ①build/settle+夠 pop→delegate 變體出現(並列自己做)
	_test_gate2_correct()             # ★②gate② 正解(pop 8-12 not applicable/pop≥13 applicable)
	_test_capacity_gate()             # ③餘力 gate(pop 不夠→無委派變體)
	_test_delegate_to_task()          # ④委派 to_task 帶 delegate/settler(派子隊接 SubteamSystem.dispatch)
	_test_util_guardrail_regression() # ⑤must-fix① range 斷言 regression(委派變體 util 同 clamp<survival)
	_test_nondelegate_task()          # 非 build/settle action 不產委派變體
	if _fail == 0:
		print("=== DONE === ALL PASS")
	else:
		print("=== DONE === %d FAIL" % _fail)
	quit()

func _ok(cond: bool, msg: String) -> void:
	if cond:
		print("  [PASS] %s" % msg)
	else:
		_fail += 1
		print("  [FAIL] %s" % msg)

func _team(pop: int) -> TeamData:
	var t := TeamData.new(); t.team_id = 1
	AnonCohort.add(t.anon_cohorts, "平民", "healthy", pop)
	return t

func _self_cand(task: String) -> Dictionary:
	return {"util": 1.0, "to_task": {"task": task, "target": Vector2i(5, 5)},
		"source_goal": {}, "label": "build_workshop:facility"}

# ① build action + pop 夠 → delegate 變體出現
func _test_delegate_variant_appears() -> void:
	print("--- ①delegate 變體出現 ---")
	var t: TeamData = _team(15)   # pop 15, settler=clampi(3,2,5)=3, 15-3=12≥10 viable
	var dv: Dictionary = GoalResolver._delegate_variant(null, t, null, _self_cand(TeamData.TASK_BUILD))
	_ok(not dv.is_empty() and dv.get("delegate") == true, "pop 15 build action → delegate 變體出現（跟自己做並列 rank 池）")
	_ok(String(dv.get("label", "")).ends_with(":delegate"), "label ...:delegate（有界，防抖）")

# ★② gate② 正解：pop 8-12 not applicable（viability 不足）/ pop≥13 applicable
func _test_gate2_correct() -> void:
	print("--- ★②gate② 正解 ---")
	# pop 12: settler=clampi(3,2,5)=3, 12-3=9<10 → not applicable
	var d12: Dictionary = GoalResolver._delegate_variant(null, _team(12), null, _self_cand(TeamData.TASK_BUILD))
	_ok(d12.is_empty(), "pop 12 → 委派變體 not applicable（12-3=9<10 viability 不足，無 8-12 浪費帶）")
	# pop 8: settler=clampi(2,2,5)=2, 8-2=6<10 → not applicable
	var d8: Dictionary = GoalResolver._delegate_variant(null, _team(8), null, _self_cand(TeamData.TASK_BUILD))
	_ok(d8.is_empty(), "pop 8 → not applicable（8-2=6<10）")
	# pop 13: settler=clampi(3,2,5)=3, 13-3=10≥10 → applicable（attempt=dispatch 同源）
	var d13: Dictionary = GoalResolver._delegate_variant(null, _team(13), null, _self_cand(TeamData.TASK_BUILD))
	_ok(not d13.is_empty(), "pop 13 → applicable（13-3=10≥MIN_PARENT_POP，attempt=dispatch 同源無浪費）")

# ③ 餘力 gate：pop 太小 → 無委派變體（只自己做，多線無委派恆贏）
func _test_capacity_gate() -> void:
	print("--- ③餘力 gate ---")
	var d: Dictionary = GoalResolver._delegate_variant(null, _team(5), null, _self_cand(TeamData.TASK_BUILD))
	_ok(d.is_empty(), "pop 5 窮隊 → 無委派變體（餘力 gate 擋，只自己做）")

# ④ 委派 to_task 帶 delegate/settler（consumer 接 SubteamSystem.dispatch）
func _test_delegate_to_task() -> void:
	print("--- ④委派 to_task 派子隊 ---")
	var dv: Dictionary = GoalResolver._delegate_variant(null, _team(20), null, _self_cand(TeamData.TASK_BUILD))
	var td: Dictionary = dv.get("to_task", {})
	_ok(td.get("delegate") == true and td.has("settler") and td["task"] == TeamData.TASK_BUILD,
		"to_task 帶 delegate=true + settler pop + action task（consumer 接 SubteamSystem.dispatch 派子隊）")

# ⑤ must-fix① range 斷言 regression：委派變體 util 同 clamp<survival
func _test_util_guardrail_regression() -> void:
	print("--- ⑤must-fix① regression ---")
	var big := {"util": 1.0e9, "to_task": {"task": TeamData.TASK_BUILD, "target": Vector2i(5, 5)}, "source_goal": {}, "label": "x:facility"}
	var dv: Dictionary = GoalResolver._delegate_variant(null, _team(20), null, big)
	_ok(float(dv.get("util", 0.0)) <= GoalResolver.GOAL_UTIL_CAP + 0.01, "委派變體 util(%.2f) ≤ GOAL_UTIL_CAP %.1f（must-fix① clamp 沿用，委派不蓋活命）" % [float(dv.get("util", 0.0)), GoalResolver.GOAL_UTIL_CAP])

# 非 build/settle action → 不產委派變體（S5 只委派 build/settle 型）
func _test_nondelegate_task() -> void:
	print("--- 非 build/settle 不委派 ---")
	var dv: Dictionary = GoalResolver._delegate_variant(null, _team(20), null, _self_cand(TeamData.TASK_TRADE))
	_ok(dv.is_empty(), "TASK_TRADE action → 無委派變體（S5 只 build/settle 型委派）")
