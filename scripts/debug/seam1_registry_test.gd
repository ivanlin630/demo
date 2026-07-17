extends SceneTree

# seam#1 S1 registry 化 characterization + 擴充 proof（byte-identical 純重構）
# spec: docs/superpowers/specs/2026-07-17-seam1-control-flow-convergence.md §S1
#
# 目標：applicable()/to_task() 的 per-option match → REGISTRY data entry。
# 本測固定 golden：
#   1. applicable() 池順序（REGISTRY 插入序，byte-identical）
#   2. caveat②：subteam 共用前置閘（STRATEGIC_SELFINIT_SET 排除 + 歸建納入）
#   3. caveat①：Probe.bump 副作用逐條精確保留（produce/occupy 分支）
#   4. to_task() 純分支對映（備戰/生產/建設/駐守/訓練/歸建/未知）
#   5. 擴充 proof：加 REGISTRY 1 entry = option 自動納入 applicable/to_task/terms_of
#      （不改 applicable()/to_task() 本體）—— 此段 refactor 前 RED、後 GREEN。

var _fail: int = 0

func _initialize() -> void:
	_test_applicable_pool_order()
	_test_subteam_shared_gate()
	_test_probe_produce_nofacility()
	_test_probe_occupy_branches()
	_test_to_task_pure_branches()
	#_test_extensibility_single_entry()   # RED on baseline: const REGISTRY 無法加 entry（parse error）→ refactor 後啟用
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

# 乾淨可預測 ctx：applicable = [貿易, 建設, survival, 掠奪, 備戰, 迎戰, 求和]（REGISTRY 序）
func _mk_ctx_order() -> DecisionContext:
	var c := DecisionContext.new()
	c.has_goods = true              # 貿易
	c.has_own_outpost = false       # 排除 生產/駐守
	c.has_manufacturing_facility = false
	c.has_home_outpost = false      # 排除 返家補給
	c.has_forage_tile = false       # 排除 覓食
	c.has_weak_prey = true          # 掠奪
	c.food_days = 10.0              # 排除 紮營/乞食/買糧/遷移找糧
	c.population = 10
	c.threat_react = 1.0; c.threat_threshold = 0.5   # 備戰/迎戰/求和
	c.is_resident = false
	c.pacify_target_on_cooldown = false
	c.archetype = ""; c.intent = ""; c.is_subteam = false
	c.has_strong_neighbor = false; c.consolidate_target_id = -1; c.absorb_target_id = -1
	c.has_occupy_target = false; c.faction_stakes = []
	c.has_food_market = false; c.has_specie = false; c.has_buyable_food = false
	return c

func _test_applicable_pool_order() -> void:
	print("--- 1. applicable() 池順序（byte-identical REGISTRY 插入序）---")
	Probe.enabled = false
	var got: Array = DecisionOptions.applicable(_mk_ctx_order())
	var want: Array = ["貿易", "建設", "survival", "掠奪", "備戰", "迎戰", "求和"]
	_ok(got == want, "applicable 順序 = %s（got=%s）" % [str(want), str(got)])

func _test_subteam_shared_gate() -> void:
	print("--- 2. caveat②：subteam 共用前置閘（戰略排除 + 歸建納入）---")
	Probe.enabled = false
	var c := _mk_ctx_order()
	c.is_subteam = true    # 建設(戰略)排除、歸建納入
	var got: Array = DecisionOptions.applicable(c)
	var want: Array = ["貿易", "survival", "掠奪", "備戰", "迎戰", "求和", "歸建"]
	_ok(got == want, "subteam applicable = %s（got=%s）" % [str(want), str(got)])
	_ok(not ("建設" in got), "建設(STRATEGIC_SELFINIT)被子隊前置閘排除")
	_ok("歸建" in got, "歸建 子隊納入")

func _test_probe_produce_nofacility() -> void:
	print("--- 3a. caveat①：生產 no-facility Probe 副作用 ---")
	var c := DecisionContext.new()
	c.has_own_outpost = true          # 生產 precondition 前半
	c.has_manufacturing_facility = false   # 無設施 → 濾 + bump
	c.has_home_outpost = false; c.food_days = 10.0; c.population = 10
	c.threat_react = 0.0; c.threat_threshold = 0.5   # 排除 threat
	c.has_forage_tile = false; c.has_occupy_target = false
	Probe.reset(); Probe.enabled = true
	var got: Array = DecisionOptions.applicable(c)
	_ok(not ("生產" in got), "無設施 → 生產不 applicable")
	_ok(int(Probe.counts.get("produce.appl_kill_nofacility", 0)) == 1,
		"produce.appl_kill_nofacility bump=1（got=%d）" % int(Probe.counts.get("produce.appl_kill_nofacility", 0)))
	Probe.enabled = false

func _test_probe_occupy_branches() -> void:
	print("--- 3b. caveat①：佔村 Probe 分支（pop-kill / hasbase-kill / applicable）---")
	# (i) pop < OCCUPY_MIN_POP → ctx_hastarget + appl_kill_pop
	var c1 := DecisionContext.new()
	c1.has_occupy_target = true; c1.population = 3
	c1.has_own_outpost = false; c1.has_forage_tile = false; c1.food_days = 10.0
	c1.threat_react = 0.0; c1.threat_threshold = 0.5
	Probe.reset(); Probe.enabled = true
	var g1: Array = DecisionOptions.applicable(c1)
	_ok(not ("佔村" in g1), "pop<6 → 佔村不 applicable")
	_ok(int(Probe.counts.get("occupy.ctx_hastarget", 0)) == 1, "occupy.ctx_hastarget bump=1")
	_ok(int(Probe.counts.get("occupy.appl_kill_pop", 0)) == 1, "occupy.appl_kill_pop bump=1")

	# (ii) pop ok + has_own_outpost + intent!=征服 → ctx_hastarget + appl_kill_hasbase
	var c2 := DecisionContext.new()
	c2.has_occupy_target = true; c2.population = 10
	c2.has_own_outpost = true; c2.has_manufacturing_facility = true  # 讓生產不 bump
	c2.intent = ""; c2.has_forage_tile = false; c2.food_days = 10.0
	c2.threat_react = 0.0; c2.threat_threshold = 0.5
	Probe.reset(); Probe.enabled = true
	var g2: Array = DecisionOptions.applicable(c2)
	_ok(not ("佔村" in g2), "有據點+非征服 → 佔村不 applicable")
	_ok(int(Probe.counts.get("occupy.ctx_hastarget", 0)) == 1, "occupy.ctx_hastarget bump=1 (ii)")
	_ok(int(Probe.counts.get("occupy.appl_kill_hasbase", 0)) == 1, "occupy.appl_kill_hasbase bump=1")

	# (iii) pop ok + 無據點 → ctx_hastarget + applicable，佔村 in out
	var c3 := DecisionContext.new()
	c3.has_occupy_target = true; c3.population = 10
	c3.has_own_outpost = false; c3.has_forage_tile = false; c3.food_days = 10.0
	c3.threat_react = 0.0; c3.threat_threshold = 0.5
	Probe.reset(); Probe.enabled = true
	var g3: Array = DecisionOptions.applicable(c3)
	_ok("佔村" in g3, "無據點+pop夠 → 佔村 applicable")
	_ok(int(Probe.counts.get("occupy.ctx_hastarget", 0)) == 1, "occupy.ctx_hastarget bump=1 (iii)")
	_ok(int(Probe.counts.get("occupy.applicable", 0)) == 1, "occupy.applicable bump=1")
	Probe.enabled = false

func _test_to_task_pure_branches() -> void:
	print("--- 4. to_task() 純分支對映 ---")
	var s := WorldState.new()
	var t := TeamData.new()
	t.tile_pos = Vector2i(4, 5)
	_ok(DecisionOptions.to_task(s, t, "備戰") == {"task": TeamData.TASK_PREPARE, "target": Vector2i(-1, -1)},
		"備戰 → TASK_PREPARE / (-1,-1)")
	_ok(DecisionOptions.to_task(s, t, "生產") == {"task": TeamData.TASK_MANUFACTURE, "target": Vector2i(4, 5)},
		"生產 → TASK_MANUFACTURE / tile_pos")
	_ok(DecisionOptions.to_task(s, t, "建設") == {"task": TeamData.TASK_BUILD, "target": Vector2i(4, 5)},
		"建設 → TASK_BUILD / tile_pos")
	_ok(DecisionOptions.to_task(s, t, "駐守") == {"task": TeamData.TASK_GOVERN, "target": Vector2i(4, 5)},
		"駐守 → TASK_GOVERN / tile_pos")
	_ok(DecisionOptions.to_task(s, t, "訓練") == {"task": TeamData.TASK_TRAIN, "target": Vector2i(4, 5)},
		"訓練 → TASK_TRAIN / tile_pos")
	_ok(DecisionOptions.to_task(s, t, "歸建") == {"task": TeamData.TASK_IDLE, "target": Vector2i(-1, -1)},
		"歸建 → TASK_IDLE / (-1,-1)")
	_ok(DecisionOptions.to_task(s, t, "__unknown__") == {"task": TeamData.TASK_IDLE, "target": Vector2i(-1, -1)},
		"未知 opt → TASK_IDLE / (-1,-1)")

func _test_extensibility_single_entry() -> void:
	print("--- 5. 擴充 proof：加 registry 1 entry = 自動納入（不改 applicable/to_task 本體）---")
	# NOTE: refactor 前此段對 const REGISTRY 造成 parse error（= RED，擴充能力不存在）。
	# refactor（const→static var）後解除下方註解啟用。
	pass
	#DecisionOptions.REGISTRY["__seam1_dummy__"] = {
	#	"terms": [["intent_fit", "intent_fit"]],
	#	"applicable": func(ctx: DecisionContext) -> bool: return ctx.food_days > 999.0,
	#	"to_task": func(_state: WorldState, _team: TeamData) -> Dictionary:
	#		return {"task": TeamData.TASK_IDLE, "target": Vector2i(7, 7)},
	#}
	#Probe.enabled = false
	#var c := _mk_ctx_order(); c.food_days = 1000.0
	#_ok("__seam1_dummy__" in DecisionOptions.applicable(c),
	#	"dummy entry 自動入 applicable（pred 真）")
	#_ok(DecisionOptions.terms_of("__seam1_dummy__") == [["intent_fit", "intent_fit"]],
	#	"dummy terms_of 讀 registry entry")
	#var td: Dictionary = DecisionOptions.to_task(WorldState.new(), TeamData.new(), "__seam1_dummy__")
	#_ok(td.get("target") == Vector2i(7, 7), "dummy to_task 讀 registry entry")
	#DecisionOptions.REGISTRY.erase("__seam1_dummy__")
