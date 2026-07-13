extends SceneTree

# 求生層統一 4-fix + v2 單元測試（TDD）：
#   Fix2 crisis edge-trigger（進 crisis fire 一次→latch→持續期落 cadence→離開解 latch）
#   Fix2-v2 漸進滑坡：慢性糧損(輕負 flow)也 trip crisis（安全網）
#   Fix3-v2 esteem_food_ref 人格化：謹慎↑→ref↑存久；野心↑→ref↓薄糧搏
# Fix1(override 退役)/Fix4 行為在 integration bed + headless 微測驗。

var _fail: int = 0

func _initialize() -> void:
	_test_fix2_crisis_edge()
	_test_fix2_gradual_decline()
	_test_fix3_esteem_ref_personalize()
	_test_fix3_food_ready_via_leader()
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

func _mk_team() -> TeamData:
	var t := TeamData.new()
	t.team_id = 1
	t.faction_id = -1          # 無 faction → directive_fresh=false，belonging/actual 走 solo 分支
	t.parent_team_id = -1
	t.current_task = TeamData.TASK_PRODUCE   # 非 IDLE、非 STUCK(ATTACK/LOOT)、非 survival
	t.move_target = Vector2i(0, 0)
	t.population = 10
	t.crisis_latched = false
	t.decision_eval_next_tick = 999999       # cadence 遠期 → 不干擾 crisis edge 判定
	t.rung_pop_last = 0                       # 不觸發 pop-drop crisis 分支
	return t

func _test_fix2_crisis_edge() -> void:
	print("--- Fix2 crisis edge-trigger ---")
	var ai := FactionAISystem.new()
	var state := WorldState.new()
	state.world = WorldData.new()
	state.world.current_tick = 0
	var t := _mk_team()

	# 進入 crisis（food_flow 深負 < RUNG_CRASH_FOOD_DEEP=-2.0）
	t.food_flow_avg = -999.0
	_ok(ai._should_reeval(state, t) == true, "進 crisis 首次 → fire(edge)")
	_ok(t.crisis_latched == true, "首次 fire 後 crisis_latched=true")
	# 持續 crisis、cadence 未到 → 不再每 tick fire
	_ok(ai._should_reeval(state, t) == false, "持續 crisis + cadence 遠期 → 不 fire(落 cadence 閘)")
	_ok(ai._should_reeval(state, t) == false, "持續 crisis 再 tick → 仍不 fire")
	# 離開 crisis → 解 latch
	t.food_flow_avg = 10.0
	_ok(ai._should_reeval(state, t) == false, "離開 crisis + 無其他觸發 → 不 fire")
	_ok(t.crisis_latched == false, "離開 crisis → latch 解除")
	# 再進 crisis → edge 再 fire（證明 latch 可重置）
	t.food_flow_avg = -999.0
	_ok(ai._should_reeval(state, t) == true, "再進 crisis → edge 再 fire")

func _test_fix2_gradual_decline() -> void:
	print("--- Fix2-v2 漸進滑坡安全網 ---")
	var ai := FactionAISystem.new()
	var state := WorldState.new(); state.world = WorldData.new(); state.world.current_tick = 0
	# 慢性糧損：flow 輕負(介於 DEEP -2.0 與 GRADUAL -0.5 間更負側) → 應 trip crisis(edge fire 一次)
	var t := _mk_team(); t.food_flow_avg = -0.8   # < GRADUAL_DECLINE_FLOW(-0.5)、> DEEP(-2.0)
	_ok(ai._decision_crisis(state, t) == true, "慢性糧損(flow=-0.8)→ 漸進 crisis 成立")
	_ok(ai._should_reeval(state, t) == true, "漸進 crisis → edge fire(拉回重評補糧)")
	_ok(t.crisis_latched == true, "漸進 crisis 也 latch(持續期落 /4,非每 tick)")
	# 糧損很輕(> -0.5)→ 不算 crisis(安全網不誤觸發健康隊)
	var t2 := _mk_team(); t2.food_flow_avg = -0.3   # > GRADUAL_DECLINE_FLOW(-0.5)
	_ok(ai._decision_crisis(state, t2) == false, "極輕糧損(flow=-0.3)→ 非 crisis(不誤觸發)")

func _test_fix3_esteem_ref_personalize() -> void:
	print("--- Fix3-v2 esteem_food_ref 人格化 ---")
	# 中性領袖(慎重=野心=0.5)→ BASE=4
	_ok(absf(NeedHierarchy.esteem_food_ref({}) - 4.0) < 0.01, "中性領袖 → ref=BASE 4")
	_ok(absf(NeedHierarchy.esteem_food_ref({"慎重": 0.5, "野心": 0.5}) - 4.0) < 0.01, "顯式中性 → ref=4")
	# 謹慎狂(慎重=1,野心=0)→ 4+2+2=8 → clamp MAX 8（存久才發展）
	var ref_caution: float = NeedHierarchy.esteem_food_ref({"慎重": 1.0, "野心": 0.0})
	_ok(ref_caution >= 7.9, "謹慎狂(慎重1/野心0)→ ref 高(%.1f，存久)" % ref_caution)
	# 賭徒(慎重=0,野心=1)→ 4-2-2=0 → clamp MIN 2（薄糧搏發展）
	var ref_gambler: float = NeedHierarchy.esteem_food_ref({"慎重": 0.0, "野心": 1.0})
	_ok(ref_gambler <= 2.1, "賭徒(慎重0/野心1)→ ref 低(%.1f，薄糧搏)" % ref_gambler)
	_ok(ref_caution > ref_gambler, "謹慎領袖 ref > 賭徒 ref(人格分化)")

func _test_fix3_food_ready_via_leader() -> void:
	print("--- Fix3-v2 food_ready 讀領袖人格 ---")
	var state := WorldState.new()
	var t := TeamData.new()
	t.team_id = 2; t.faction_id = -1; t.population = 10
	t.ambition_cap = 2; t.ambition_rung = 0   # ambition_gap = 1.0
	t.food_flow_avg = 0.0; t.leader_id = 100
	# 賭徒領袖：ref≈2 → food_days=3 時 food_ready=min(3/2,1)=1.0 → esteem 近滿(薄糧就搏發展)
	var gambler := PersonData.new(); gambler.id = 100; gambler.values = {"慎重": 0.0, "野心": 1.0}
	state.persons[100] = gambler
	var raw_g := NeedHierarchy.compute_raw(state, t, 3.0, 0.0)
	_ok(raw_g[NeedHierarchy.L_ESTEEM] >= 0.99, "賭徒領袖 food_days=3 → esteem 近滿(%.2f，薄糧搏)" % raw_g[NeedHierarchy.L_ESTEEM])
	# 謹慎狂領袖：ref≈8 → food_days=3 時 food_ready=3/8=0.375 → esteem 低(存久才發展)
	var cautious := PersonData.new(); cautious.id = 100; cautious.values = {"慎重": 1.0, "野心": 0.0}
	state.persons[100] = cautious
	var raw_c := NeedHierarchy.compute_raw(state, t, 3.0, 0.0)
	_ok(raw_c[NeedHierarchy.L_ESTEEM] < 0.5, "謹慎狂領袖 food_days=3 → esteem 低(%.2f，存久)" % raw_c[NeedHierarchy.L_ESTEEM])
	_ok(raw_g[NeedHierarchy.L_ESTEEM] > raw_c[NeedHierarchy.L_ESTEEM], "同糧態：賭徒 esteem > 謹慎 esteem(餓死行為分化)")
	# null leader → 預設 ref=BASE 4（不崩）
	var t2 := TeamData.new(); t2.team_id = 3; t2.faction_id = -1; t2.population = 10
	t2.ambition_cap = 2; t2.ambition_rung = 0; t2.leader_id = -1
	var raw_n := NeedHierarchy.compute_raw(state, t2, 4.0, 0.0)
	_ok(absf(raw_n[NeedHierarchy.L_ESTEEM] - 1.0) < 0.01, "null leader food_days=4 → ref=4→food_ready=1.0(不崩)")
