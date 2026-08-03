extends SceneTree

# B idle-labor→建設 genuine 激勵 TDD（spec 2026-08-03-idle-labor-build-incentive-HOW）。
# 治 §8 領導軸 size-matter：大隊 idle PRODUCE 勞力（pool−Σ設施 demand-cap）=真浪費 → 建產能雇用=genuine 期望產出。
# ★anti-crank（乙教訓）：idle_employ_value 全因子從 manufacturing 真 worker_rate 反推、禁 flat boost。
# ★guardrail：idle-labor term 只加建設；只 PRODUCE-idle（軍隊 TAG_MILITARY 天然不在 pool_of）。
# 純算術/讀 belief 零 RNG（determinism 保）。

var _fail: int = 0

func _initialize() -> void:
	_test_idle_labor_computed()          # ①idle_labor = pool − Σ workstation demand
	_test_idle_drives_build_value()      # ②idle>0 + 真需求可建 → idle_employ_value>0 → 建設 util 升
	_test_idle_zero_no_value()           # ③idle=0（非擁地 / pool≤demand）→ idle_employ_value=0
	_test_genuine_need_weighted()        # ④genuine 非 flat：需求大→value 大（need-weighted 非常數 boost）
	_test_no_buildable_no_value()        # ⑤idle>0 但無可建 mfg 設施 → 0（不亂建）
	_test_guardrail_build_only()         # ★⑥guardrail：term 只在建設非 0，combat/survival/trade/move/social=0
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

# 建 producer state：tile@(5,5) outpost（owner=1 若 own 否則 99）、PRODUCE 隊 pop、mfg_levels/resources 依參。
func _mk(pop: int, otype: String, mfg_levels: Dictionary, resources: Dictionary, own: bool = true) -> Array:
	var state := WorldState.new(); state.world = WorldData.new(); state.world.current_tick = 1000
	var tile := HexTileData.new(); tile.tile_pos = Vector2i(5, 5); tile.terrain = "plains"
	tile.outpost_owner = (1 if own else 99); tile.outpost_type = otype; tile.outpost_level = 1
	for r in resources: tile.resources[r] = float(resources[r])
	for lk in mfg_levels: tile.set(lk, int(mfg_levels[lk]))
	state.world.tiles[5 * 1000 + 5] = tile
	var team := TeamData.new(); team.team_id = 1; team.tile_pos = Vector2i(5, 5); team.faction_id = 5
	team.tags = [TeamData.TAG_PRODUCE]   # ★入勞力池（pool_of 只算 PRODUCE）
	AnonCohort.add(team.anon_cohorts, "平民", "healthy", pop)
	team.resources["food"] = 5000.0   # 不餓（避 survival 干擾）
	var l := PersonData.new(); l.id = 10; l.values = {"好戰": 0.5, "貪婪": 0.5, "野心": 0.5, "慎重": 0.5}; l.skills = {}
	state.persons[10] = l; team.leader_id = 10
	state.teams[1] = team
	return [state, team, tile]

func _heard_buy(state: WorldState, hearer: int, res: String, qty: int) -> void:
	var m := MessageData.new(); m.type = "order_buy"
	m.params = {"res": res, "origin_team": 99, "expire_tick": 99999, "qty": qty}
	state.team_known[hearer] = state.team_known.get(hearer, []) + [m]

# ① idle_labor = pool − Σ active workstation demand
func _test_idle_labor_computed() -> void:
	print("--- ①idle_labor = pool − Σ demand ---")
	# 無資源無 mfg → Σdemand=0 → idle=pool（pool=anon+leader）。用真 pool_of 對照（免 hardcode pop 語意）。
	var a: Array = _mk(10, "military", {}, {})
	var pool_a: float = LaborSystem.pool_of(a[0], a[2])
	var ca: DecisionContext = DecisionContext.gather(a[0], a[1])
	_ok(absf(ca.idle_labor - pool_a) < 0.01, "無工位：idle_labor=pool %.0f（got %.2f）" % [pool_a, ca.idle_labor])
	# + food 資源（1 gather 工位 demand K_GATHER=5）→ idle=pool−5。
	var b: Array = _mk(10, "military", {}, {"food": 100.0})
	var pool_b: float = LaborSystem.pool_of(b[0], b[2])
	var cb: DecisionContext = DecisionContext.gather(b[0], b[1])
	_ok(absf(cb.idle_labor - (pool_b - LaborSystem.K_GATHER)) < 0.01,
		"1 gather 工位：idle_labor=pool−demand=%.0f−%.0f=%.0f（got %.2f）" % [pool_b, LaborSystem.K_GATHER, pool_b - LaborSystem.K_GATHER, cb.idle_labor])

# ② idle>0 + 真需求可建 mfg 設施 → idle_employ_value>0 → 建設 util 含此項升
func _test_idle_drives_build_value() -> void:
	print("--- ②idle→build 因果 ---")
	# military outpost、無資源 → idle 10；weaponsmith 可建（out weapon 有 self_use need）→ value>0。
	var a: Array = _mk(10, "military", {}, {})
	var c: DecisionContext = DecisionContext.gather(a[0], a[1])
	_ok(c.idle_employ_value > 0.0, "idle>0+可建有需求 mfg → idle_employ_value>0（got %.3f）" % c.idle_employ_value)
	# 建設 util 含此項（term eval 建設>0）；idle=0 ctx 則此項=0（因果對照）。
	var build_term: float = DecisionTerms.eval("idle_employ_value", c, "建設")
	_ok(build_term > 0.0, "建設 util idle_employ_value 項>0（got %.3f）" % build_term)
	var c0 := DecisionContext.new()   # idle=0 baseline
	_ok(DecisionTerms.eval("idle_employ_value", c0, "建設") == 0.0, "idle=0 → 建設此項=0（因果：升自 idle）")

# ③ idle=0 → idle_employ_value=0
func _test_idle_zero_no_value() -> void:
	print("--- ③idle=0 → value=0 ---")
	# (a) 非擁地（owner=99）→ guard → idle_labor=0。
	var a: Array = _mk(10, "military", {}, {}, false)
	var ca: DecisionContext = DecisionContext.gather(a[0], a[1])
	_ok(ca.idle_labor == 0.0 and ca.idle_employ_value == 0.0, "非擁地 → idle_labor=0 & value=0（got idle=%.2f val=%.3f）" % [ca.idle_labor, ca.idle_employ_value])
	# (b) pool≤Σdemand：pop2 + 3 gather 資源（demand 15）→ idle=max(2−15,0)=0。
	var b: Array = _mk(2, "military", {}, {"food": 100.0, "material": 100.0, "gem": 100.0})
	var cb: DecisionContext = DecisionContext.gather(b[0], b[1])
	_ok(cb.idle_labor == 0.0 and cb.idle_employ_value == 0.0, "pool≤demand → idle=0 & value=0（got idle=%.2f val=%.3f）" % [cb.idle_labor, cb.idle_employ_value])

# ④ genuine 非 flat：需求大 → value 大（need-weighted，非常數 boost）
func _test_genuine_need_weighted() -> void:
	print("--- ④genuine need-weighted 非 flat ---")
	# 同 idle、同可建 facility；一組加親聞 weapon 買單（demand↑→need_weight↑）→ value 更大。
	var base: Array = _mk(10, "military", {}, {})
	var cbase: DecisionContext = DecisionContext.gather(base[0], base[1])
	var more: Array = _mk(10, "military", {}, {})
	_heard_buy(more[0], 1, "weapon_melee_low", 50)   # 親聞 weapon 買單 → demand(weapon)>0 → need_weight↑
	var cmore: DecisionContext = DecisionContext.gather(more[0], more[1])
	_ok(cmore.idle_employ_value > cbase.idle_employ_value + 1e-6,
		"需求大→value 大（need-weighted 非 flat；base %.3f < +demand %.3f）" % [cbase.idle_employ_value, cmore.idle_employ_value])

# ⑤ idle>0 但無可建 mfg 設施 → value=0（不亂建、anti-crank）
func _test_no_buildable_no_value() -> void:
	print("--- ⑤無可建 mfg → value=0 ---")
	# civilian outpost、workshop+apothecary 皆滿級(3)、其餘 mfg 設施 military-only → 無 civilian mfg 可建。
	# pop20 > Σdemand(9+9=18) → idle=2>0，但無可建 → value=0（隔離「idle>0 但無 candidate」）。
	var a: Array = _mk(20, "civilian", {"manufacturing_level": 3, "apothecary_level": 3}, {})
	var c: DecisionContext = DecisionContext.gather(a[0], a[1])
	_ok(c.idle_labor > 0.0 and c.idle_employ_value == 0.0, "idle>0 但無可建 mfg → value=0（idle=%.2f 仍不亂建）" % c.idle_labor)

# ★⑥ guardrail：term 只加建設，combat/survival/trade/move/social=0
func _test_guardrail_build_only() -> void:
	print("--- ★⑥guardrail build-only ---")
	var ctx := DecisionContext.new(); ctx.idle_employ_value = 5.0
	_ok(is_equal_approx(DecisionTerms.eval("idle_employ_value", ctx, "建設"), 5.0), "建設 → 5.0（ctx.idle_employ_value）")
	var others: Array = ["攻擊", "覓食", "掠奪", "併入", "貿易", "遷移找糧", "紮營", "佔村", "訓練", "外交"]
	var all_zero: bool = true
	for o in others:
		if DecisionTerms.eval("idle_employ_value", ctx, o) != 0.0:
			all_zero = false
			print("    漏進 %s = %.2f" % [o, DecisionTerms.eval("idle_employ_value", ctx, o)])
	_ok(all_zero, "combat/survival/trade/move/social 全 0（guardrail 無漏；10 非建設 opt）")
