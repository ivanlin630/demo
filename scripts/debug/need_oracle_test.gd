extends SceneTree

# Arc1 統一 need oracle TDD（feat/need-oracle）
# spec: docs/superpowers/specs/2026-07-16-arc1-unified-need-oracle.md
# S1：NeedOracle 骨架 + food 自用真推導；供應鏈(S2)/貿易(S3) fallback 舊常數。

var _fail: int = 0

func _initialize() -> void:
	_test_s1_food_self_use()
	_test_s1_fallback_and_demand()
	if _fail == 0:
		print("=== DONE === ALL PASS")
	else:
		print("=== DONE === %d FAIL" % _fail)
	quit()

func _ok(cond: bool, msg: String) -> void:
	if cond: print("  [PASS] %s" % msg)
	else: _fail += 1; print("  [FAIL] %s" % msg)

func _mk_team(pop: int) -> TeamData:
	var t := TeamData.new(); t.team_id = 1; t.leader_id = 100
	for i in range(pop - 1): t.named_members.append(200 + i)
	return t

# ── S1：food 自用真推導（日耗×pop×人格安全天）──
func _test_s1_food_self_use() -> void:
	print("--- S1：food 自用推導（消耗率×pop×人格 buffer 天）---")
	var team := _mk_team(10)   # pop 10
	var neutral := {"慎重": 0.5, "野心": 0.5}
	var expected: float = ResourceSystem.FOOD_PER_PERSON_PER_DAY * 10.0 * DecisionTerms.food_security_target(neutral)
	var got: float = NeedOracle.need_keep(null, team, "food", neutral)
	_ok(absf(got - expected) < 0.001, "food need_keep(%.1f) = 日耗×pop×安全天(%.1f)" % [got, expected])
	# 人格化：慎重領袖 buffer 大 → food need_keep 高（存久）
	var cautious := {"慎重": 1.0, "野心": 0.0}
	var greedy := {"慎重": 0.0, "野心": 1.0}
	var nk_caution: float = NeedOracle.need_keep(null, team, "food", cautious)
	var nk_greedy: float = NeedOracle.need_keep(null, team, "food", greedy)
	_ok(nk_caution > nk_greedy, "★人格化：慎重領袖 food need_keep(%.1f) > 大膽領袖(%.1f)（buffer 大）" % [nk_caution, nk_greedy])

# ── S1：非 food 供應鏈 fallback 舊常數 + demand S3 前 fallback ──
func _test_s1_fallback_and_demand() -> void:
	print("--- S1：非 food 供應鏈 fallback + demand fallback ---")
	var team := _mk_team(10)
	var lv := {"慎重": 0.5}
	# 非 food（goods）need_keep = 供應鏈 fallback = pop × TARGET_PER_POP[goods]（S2 未實作）
	var expected_goods: float = 10.0 * float(TradeValuation.TARGET_PER_POP.get("goods", 0.0))
	var got_goods: float = NeedOracle.need_keep(null, team, "goods", lv)
	_ok(absf(got_goods - expected_goods) < 0.001, "goods need_keep(%.1f) = 供應鏈 fallback TARGET_PER_POP(%.1f)（S2 前）" % [got_goods, expected_goods])
	# demand S3 前 fallback 0（reader 尚未切）
	_ok(NeedOracle.demand(null, team, "goods", lv) == 0.0, "demand(goods)=0（S3 前 fallback，reader 未切）")
	_ok(NeedOracle.demand(null, team, "food", lv) == 0.0, "demand(food)=0（S3 前 fallback）")
