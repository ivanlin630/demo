extends SceneTree

# 求和/外交 grounded TDD（slice: diplomacy-grounded）
# spec: docs/superpowers/specs/2026-07-15-diplomacy-grounded.md
#
# Fix1 look-before-leap：求和(threat_id)/外交(faction_diplo_target) target 在 reject_cooldown 內 → applicable 不入。
# Fix2 求和 seam：_try_diplomacy 偵 order_task==TASK_TRIBUTE_OFFER → release+cooldown+清 order_task，★不呼 propose_alliance。

var _fail: int = 0

func _initialize() -> void:
	_test_cooldown_gate()
	_test_pacify_seam()
	_test_diplomacy_not_harmed()
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

func _mk_ctx_diplo() -> DecisionContext:
	var c := DecisionContext.new()
	c.threat_react = 1.0; c.threat_threshold = 0.5    # 求和 threat 過門檻
	c.faction_stakes = ["外交"]; c.faction_diplo_target = 5   # 外交 有 target
	c.leader_values = {}
	var u := PackedFloat32Array(); u.resize(NeedHierarchy.N_LAYERS); c.need_urgency = u
	return c

func _test_cooldown_gate() -> void:
	print("--- Fix1：求和/外交 look-before-leap cooldown gate ---")
	var c1 := _mk_ctx_diplo()   # 未 cooldown
	var a1: Array = DecisionOptions.applicable(c1)
	_ok("求和" in a1, "求和 target 未 cooldown → 入候選")
	_ok("外交" in a1, "外交 target 未 cooldown → 入候選")
	var c2 := _mk_ctx_diplo()
	c2.pacify_target_on_cooldown = true; c2.diplo_target_on_cooldown = true
	var a2: Array = DecisionOptions.applicable(c2)
	_ok(not ("求和" in a2), "求和 target cooldown 內 → 不入候選（不纏 loop）")
	_ok(not ("外交" in a2), "外交 target cooldown 內 → 不入候選（不纏 loop）")

func _mk_diplo_world(initiator_order: String) -> Array:   # → [isys, state, ini]
	var state := WorldState.new(); state.world = WorldData.new(); state.world.current_tick = 1000
	var isys := InteractionSystem.new()
	var ini := TeamData.new(); ini.team_id = 1; ini.faction_id = -1
	ini.current_task = TeamData.TASK_DIPLOMACY; ini.order_task = initiator_order
	AnonCohort.add(ini.anon_cohorts, "平民", "healthy", 5); state.teams[1] = ini
	var tgt := TeamData.new(); tgt.team_id = 2; tgt.faction_id = -1
	var tl := PersonData.new(); tl.id = 20; state.persons[20] = tl; tgt.leader_id = 20
	AnonCohort.add(tgt.anon_cohorts, "平民", "healthy", 5); state.teams[2] = tgt
	return [isys, state, ini]

func _test_pacify_seam() -> void:
	print("--- Fix2：求和 seam（TRIBUTE_OFFER → release+cooldown，不觸發 propose_alliance）---")
	var w: Array = _mk_diplo_world(TeamData.TASK_TRIBUTE_OFFER)   # 求和
	var isys: InteractionSystem = w[0]; var state: WorldState = w[1]; var ini: TeamData = w[2]
	isys._try_diplomacy(state, 1, 2)
	_ok(ini.current_task == TeamData.TASK_IDLE, "求和 fire → initiator released(IDLE)，實際=%s" % ini.current_task)
	_ok(int(ini.diplomacy_reject_cooldown.get(2, 0)) > 1000, "求和 fire → reject_cooldown 設（不再纏）")
	_ok(ini.order_task == "", "求和 fire → order_task 清（防殘留誤路由）")
	_ok(ini.faction_id == -1, "求和 fire → 不成盟（faction 不變＝不誤觸發 propose_alliance）")

func _test_diplomacy_not_harmed() -> void:
	print("--- Fix2：外交/結盟不誤傷（order_task=\"\" → 走 propose_alliance 非 seam）---")
	var w: Array = _mk_diplo_world("")   # 外交（無 order_task）
	var isys: InteractionSystem = w[0]; var state: WorldState = w[1]; var ini: TeamData = w[2]
	isys._try_diplomacy(state, 1, 2)
	# 外交 order_task="" → 不入求和 seam。seam 會清 order_task+無條件 release；外交走 propose_alliance
	# （reject→cooldown 但不 release / accept→成盟）。無論如何未被 seam 無條件 release 掉 current_task。
	_ok(ini.order_task == "", "外交 order_task 保持空（未入求和 seam 的清理）")
	# 求和 seam 無條件 release(→IDLE)；外交走 propose_alliance(reject 不 release)→current_task 仍 DIPLOMACY
	# ＝證外交路由到 propose_alliance 非 seam（不誤傷）。
	_ok(ini.current_task == TeamData.TASK_DIPLOMACY,
		"外交未被求和 seam release（current_task=%s 仍 DIPLOMACY→走 propose_alliance）" % ini.current_task)
