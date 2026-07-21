extends SceneTree

# market-seek stickiness Gate A TDD（spec 2026-07-22-market-seek-stickiness-gateA）。
# 根:market-seek(TASK_TRADE 在途)cadence re-eval 被機會性選項搶走→64% 到不了市場。
# 修:_should_reeval 加 sticky(TASK_TRADE 未抵達 move_target set + 非 crisis→return false,不 divert)。
# ★crisis/IDLE/stuck/directive escape 全保;resident 擺攤(move_target=-1)不受影響。

var _fail: int = 0

func _initialize() -> void:
	_test_transit_noncrisis_sticky()   # ①在途非 crisis→sticky false（★cadence DUE 仍擋=discriminating）
	_test_transit_crisis_cadence()     # ②在途+crisis→落 cadence（survival escape 可 re-eval）
	_test_arrived_normal_reeval()      # ③已抵達(move_target=-1)→正常 re-eval
	_test_nontrade_unaffected()        # ④非 TASK_TRADE→不受 sticky 影響
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

# 隊：cadence DUE(next_tick=0,tick=100)以隔離 sticky vs cadence。faction=-1 免 directive。
func _mk(task: String, move_target: Vector2i, crisis: bool) -> Array:
	var state := WorldState.new(); state.world = WorldData.new(); state.world.current_tick = 100
	var t := TeamData.new(); t.team_id = 1; t.faction_id = -1
	t.current_task = task; t.move_target = move_target
	t.rung_pop_last = 0
	t.food_flow_avg = -100.0 if crisis else 1.0   # crisis=深負 flow / 非-crisis=正 flow
	t.crisis_latched = crisis   # 持續 crisis(latched)→落 cadence 非 edge
	t.decision_eval_next_tick = 0   # cadence DUE（100>=0）
	AnonCohort.add(t.anon_cohorts, "平民", "healthy", 10)
	state.teams[1] = t
	return [state, t]

# ① 在途 market-seek 非 crisis → false（★cadence DUE 但 sticky 先擋=不 divert）
func _test_transit_noncrisis_sticky() -> void:
	print("--- ①在途非 crisis→sticky false ---")
	var w: Array = _mk(TeamData.TASK_TRADE, Vector2i(5, 5), false)
	var r: bool = FactionAISystem.new()._should_reeval(w[0], w[1])
	_ok(not r, "在途 market-seek 非 crisis → _should_reeval false（cadence DUE 仍 sticky 不 divert）")

# ② 在途 + crisis → 落 cadence（可 re-eval 求生，不餓死買路）
func _test_transit_crisis_cadence() -> void:
	print("--- ②在途+crisis→落 cadence ---")
	var w: Array = _mk(TeamData.TASK_TRADE, Vector2i(5, 5), true)
	var r: bool = FactionAISystem.new()._should_reeval(w[0], w[1])
	_ok(r, "在途 market-seek + crisis → 落 cadence return true（survival escape，可 divert 求生）")

# ③ 已抵達（move_target=-1）→ 正常 re-eval（非在途，不 sticky）
func _test_arrived_normal_reeval() -> void:
	print("--- ③已抵達→正常 re-eval ---")
	var w: Array = _mk(TeamData.TASK_TRADE, Vector2i(-1, -1), false)
	var r: bool = FactionAISystem.new()._should_reeval(w[0], w[1])
	_ok(r, "已抵達(move_target=-1)→正常 re-eval true（resident 擺攤同理不受 sticky）")

# ④ 非 TASK_TRADE（FORAGE 在途）→ 不受 sticky 影響（正常 cadence）
func _test_nontrade_unaffected() -> void:
	print("--- ④非 TASK_TRADE 不受影響 ---")
	var w: Array = _mk(TeamData.TASK_FORAGE, Vector2i(5, 5), false)
	var r: bool = FactionAISystem.new()._should_reeval(w[0], w[1])
	_ok(r, "非 TASK_TRADE 在途→不 sticky，正常 cadence re-eval true")
