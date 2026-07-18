extends SceneTree

# 絕境經濟 ① survival 保序單一源：DecisionOptions.priority_for(opt) 一處定 priority，
# 全 dispatch 路(_decide_unified/_evaluate_solo/_trigger_survival/_decide_subteam/_try_join_target)一律讀。
# 不變量:survival 保序=命運不看走哪 dispatch 路。

var _fail: int = 0

func _initialize() -> void:
	_test_priority_for_source()
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

func _test_priority_for_source() -> void:
	print("--- priority_for 單一源：survival-class→80 / threat→70 / else→50 ---")
	# survival-class（SURVIVAL_OPTION_SET + FLEE）→ PRIO_SURVIVAL 80
	for opt in ["覓食", "買糧", "併入", "掠奪", "返家補給", "紮營", "乞食", "遷移找糧", "survival"]:
		_ok(DecisionOptions.priority_for(opt) == TaskArbiter.PRIO_SURVIVAL,
			"survival-class '%s' → PRIO_SURVIVAL 80（got %d）" % [opt, DecisionOptions.priority_for(opt)])
	# threat-class → PRIO_THREAT 70
	for opt in ["備戰", "迎戰", "求和"]:
		_ok(DecisionOptions.priority_for(opt) == TaskArbiter.PRIO_THREAT,
			"threat-class '%s' → PRIO_THREAT 70" % opt)
	# else（經濟/發展/攻擊）→ PRIO_DISPATCH 50
	for opt in ["貿易", "生產", "建設", "攻擊", "外交", "訓練", "囤貨", "吸納"]:
		_ok(DecisionOptions.priority_for(opt) == TaskArbiter.PRIO_DISPATCH,
			"else '%s' → PRIO_DISPATCH 50" % opt)
	# 階層 80>70>50
	_ok(TaskArbiter.PRIO_SURVIVAL > TaskArbiter.PRIO_THREAT and TaskArbiter.PRIO_THREAT > TaskArbiter.PRIO_DISPATCH,
		"階層 80>70>50 保持")
