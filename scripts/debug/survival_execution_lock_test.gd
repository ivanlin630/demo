extends SceneTree

# 求生執行鎖 thrash-fix 單元測試（TDD）
# spec: docs/superpowers/specs/2026-07-14-survival-execution-lock-thrash-fix.md
#
# 根因：legacy _evaluate_survival 的 survival recognizer 白名單 SURVIVAL_TASKS 缺
#   TASK_TRADE(買糧)/TASK_ATTACK(掠奪/佔村)，故不認自己派的買糧 survival →
#   每 tick 把 in-flight 買糧 dispatch(TASK_TRADE@PRIO_SURVIVAL) 當「沒在求生」重觸
#   → 貿易↔idle thrash 餓死（Team14 血證）。
# Fix A：recognizer 改 priority-based（_in_survival helper：白名單 ∪ PRIO_SURVIVAL）
#   → 買糧 survival 命中執行鎖入口 → HOLD 到 cadence/crisis，不再每 tick 重觸。
# Fix B：SpecimenTracer.capture_decision 補接 _decide_subteam（子隊決策路徑 tap-gap）。

var _fail: int = 0

func _initialize() -> void:
	_test_execution_lock_hold()      # 行為：買糧 survival HOLD 不被 legacy 重觸打回
	_test_in_survival_recognizer()   # 白盒：recognizer priority-based 正確性
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

# 構造 Team14 型餓子隊：非-unified（無 MERCHANT/PRODUCE tag）+ parent!=-1 → 走 legacy body。
# current=買糧 in-flight(TASK_TRADE@PRIO_SURVIVAL)、餓(food=0→days_left=0<WARNING)、
# cadence 未到（decision_eval_next_tick 遠期）、非 crisis（food_flow_avg=0）。
func _mk_hungry_subteam() -> TeamData:
	var t := TeamData.new()
	t.team_id = 14
	t.faction_id = -1               # 無 faction
	t.parent_team_id = 99           # ★子隊（!=-1）→ 不在 Fix1 退役範圍，走 legacy _evaluate_survival body
	t.leader_id = 100               # leader 存在（_trigger_survival leader==null 會提前 return，破壞 red 觀測）
	AnonCohort.add(t.anon_cohorts, "平民", "healthy", 10)   # pop_eff > 0
	t.current_task = TeamData.TASK_TRADE                    # 買糧 in-flight
	t.task_priority = TaskArbiter.PRIO_SURVIVAL             # ★求生控制器派的 marker
	t.move_target = Vector2i(5, 5)  # 往市集途中（非 STUCK：TASK_TRADE 不在 STUCK_TASKS）
	t.previous_task = ""            # 乾淨基準：_trigger_survival 若被重觸會污染成 TASK_TRADE
	t.decision_eval_next_tick = 999999   # cadence 遠期 → relatch 不 fire → HOLD 路徑
	t.food_flow_avg = 0.0           # 非 crisis（不觸 relatch）
	t.crisis_latched = false
	t.rung_pop_last = 0
	# food 空 → effective_food=0 → days_left=0 < WARNING(3) → 餓
	return t

func _test_execution_lock_hold() -> void:
	print("--- Fix A 執行鎖 HOLD：買糧 survival 不被 legacy 每-tick 重觸 ---")
	var ai := FactionAISystem.new()
	var state := WorldState.new()
	state.world = WorldData.new()
	state.world.current_tick = 100
	var t := _mk_hungry_subteam()
	state.persons[100] = PersonData.new()   # leader

	ai._evaluate_survival(state, t)

	# 執行鎖生效：買糧 dispatch HOLD（current_task 保持 TASK_TRADE@PRIO_SURVIVAL，不被 release 回 idle）
	_ok(t.current_task == TeamData.TASK_TRADE, "current_task HOLD 貿易（不回 idle），實際=%s" % t.current_task)
	_ok(t.task_priority == TaskArbiter.PRIO_SURVIVAL, "task_priority 保持 PRIO_SURVIVAL，實際=%d" % t.task_priority)
	# 主 red 信號：cadence 未到 → 執行鎖 HOLD → 不呼 _trigger_survival。
	# 修前 recognizer miss → 落 :3112 重觸 _trigger_survival → previous_task 被污染成 TASK_TRADE。
	_ok(t.previous_task == "", "未被 legacy 重觸（previous_task 乾淨），實際=%s" % t.previous_task)

func _test_in_survival_recognizer() -> void:
	print("--- Fix A recognizer priority-based 正確性 ---")
	var ai := FactionAISystem.new()
	# 買糧/掠奪 survival（@PRIO_SURVIVAL）→ 認得（新增覆蓋）
	var t_buy := TeamData.new()
	t_buy.current_task = TeamData.TASK_TRADE; t_buy.task_priority = TaskArbiter.PRIO_SURVIVAL
	_ok(ai._in_survival(t_buy), "買糧 TASK_TRADE@PRIO_SURVIVAL → in_survival=true")
	var t_loot := TeamData.new()
	t_loot.current_task = TeamData.TASK_ATTACK; t_loot.task_priority = TaskArbiter.PRIO_SURVIVAL
	_ok(ai._in_survival(t_loot), "掠奪 TASK_ATTACK@PRIO_SURVIVAL → in_survival=true")
	# 白名單 survival task（如覓食）不論 priority → 仍認（proactive-camp @PRIO_DISPATCH 保命）
	var t_forage := TeamData.new()
	t_forage.current_task = TeamData.TASK_FORAGE; t_forage.task_priority = TaskArbiter.PRIO_DISPATCH
	_ok(ai._in_survival(t_forage), "覓食 TASK_FORAGE@PRIO_DISPATCH → in_survival=true（白名單）")
	# ★精準性：正常貿易/攻擊（@PRIO_DISPATCH，非 survival 派）不誤判 → 不誤 skip uprising/誤 sticky
	var t_norm_trade := TeamData.new()
	t_norm_trade.current_task = TeamData.TASK_TRADE; t_norm_trade.task_priority = TaskArbiter.PRIO_DISPATCH
	_ok(not ai._in_survival(t_norm_trade), "正常貿易 TASK_TRADE@PRIO_DISPATCH → in_survival=false（不誤傷）")
	var t_norm_atk := TeamData.new()
	t_norm_atk.current_task = TeamData.TASK_ATTACK; t_norm_atk.task_priority = TaskArbiter.PRIO_DISPATCH
	_ok(not ai._in_survival(t_norm_atk), "正常攻擊 TASK_ATTACK@PRIO_DISPATCH → in_survival=false（不誤傷）")
