extends SceneTree

# slice A1 TDD：紮營價值=MarginalEconomy 真帳（camp_drive term）。bounded 四象限 + anti-crank marginal 路徑。

var _fail: int = 0
func _ok(c: bool, m: String) -> void:
	if c: print("  [PASS] %s" % m)
	else: _fail += 1; print("  [FAIL] %s" % m)

func _ctx(has_farm: bool, terrain: String, pop: int, food_days: float) -> DecisionContext:
	var c := DecisionContext.new()
	c.has_farmable_tile = has_farm
	c.population = pop
	c.food_days = food_days
	c.camp_forage_floor = float(pop) * ResourceSystem.FOOD_PER_PERSON_PER_DAY   # 日產同源
	if has_farm:
		c.camp_target_est = VillageEstimate.make(terrain, 1, 0, pop)
	return c

func _drive(has_farm: bool, terrain: String, pop: int, food_days: float) -> float:
	return DecisionTerms.eval("camp_drive", _ctx(has_farm, terrain, pop, food_days), "紮營")

func _initialize() -> void:
	print("=== A1 camp_drive bounded 四象限 ===")
	# ①無可耕地(純山地被 _find_unowned_farmable_tile 排除→has_farmable=false)→gate→0。
	_ok(_drive(false, "plains", 5, 0.0) == 0.0, "①無可耕地(gate、含純山地排除)→ camp_drive=0")
	# ②富流浪(food_days≥URGENCY_DAYS 10)→urgency=0→0（即使肥沃平原）。
	_ok(_drive(true, "plains", 5, 12.0) == 0.0, "②富流浪(food_days=12≥10)→ urgency=0→ camp_drive=0")
	# ③瀕餓+肥沃平原→marg 高×urgency 高=高。
	var q3: float = _drive(true, "plains", 5, 0.0)
	print("  ③瀕餓+平原 camp_drive=%.3f (marg=%.2f floor=%.2f)" % [q3, MarginalEconomy.camp_marginal(VillageEstimate.make("plains",1,0,5), 4.0), 4.0])
	_ok(q3 > 0.5, "③瀕餓+肥沃平原→ camp_drive=%.3f 高（marg 高×urgency 高）" % q3)
	# ④瀕餓+低產 farmable(森林高 pop→_inflow_est 邊際→forage_floor 之下→maxf(0)=0)→不紮（anti-crank marginal 路徑）。
	_ok(_drive(true, "forest", 20, 0.0) == 0.0, "④瀕餓+低產 farmable(森林高 pop marg→0)→ maxf(0)=0→ camp_drive=0 不紮（anti-crank）")

	print("=== bounded / camp_marginal 直測 ===")
	# camp_marginal maxf(0) 防線：森林高 pop inflow < forage_floor → 0。
	var forest_marg: float = MarginalEconomy.camp_marginal(VillageEstimate.make("forest", 1, 0, 20), 16.0)
	_ok(forest_marg == 0.0, "camp_marginal 森林高 pop=%.2f → maxf(0)=0（低產不值紮）" % forest_marg)
	var plains_marg: float = MarginalEconomy.camp_marginal(VillageEstimate.make("plains", 1, 0, 5), 4.0)
	_ok(plains_marg > 0.0, "camp_marginal 肥沃平原=%.2f>0（超覓食餬口的真增量）" % plains_marg)
	# CAP bound：極肥沃 tile camp_drive ≤ CAMP_CAP。
	_ok(_drive(true, "plains", 5, 0.0) <= DecisionTerms.CAMP_MARGINAL_CAP + 1e-9, "camp_drive ≤ CAMP_CAP %.1f（bound 非 inflate）" % DecisionTerms.CAMP_MARGINAL_CAP)

	if _fail == 0: print("=== DONE === ALL PASS")
	else: print("=== DONE === %d FAIL" % _fail)
	quit()
