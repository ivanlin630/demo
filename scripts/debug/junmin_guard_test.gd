extends SceneTree

# 军民混编 Slice A TDD（spec v2 §2）：guard_ratio 照妖鏡 de-patch（連續人格化）+ belief-threat（去 god-view）。
# 核：①連續人格分化(慎重/好戰、非離散 5 值)②belief-threat 升守+god-view 除(未 discovered 敵→零感知)③attack 降④bounded[0.05,0.5]。

var _fail: int = 0
func _ok(c: bool, m: String) -> void:
	if c: print("  [PASS] %s" % m)
	else: _fail += 1; print("  [FAIL] %s" % m)

# 建 team + leader 人格；可選 discovered+belief 敵（belief-threat）。回 team。
func _mk(caution: float, martial: float, task: String, with_threat: bool) -> Array:
	var state := WorldState.new(); state.world = WorldData.new(); state.world.current_tick = 1000
	var t := TeamData.new(); t.team_id = 1; t.faction_id = 10; t.tile_pos = Vector2i(5,5); t.current_task = task
	AnonCohort.add(t.anon_cohorts, "平民", "healthy", 8)
	var lp := PersonData.new(); lp.id = 11; lp.values = {"慎重": caution, "好戰": martial}; state.persons[11] = lp; t.leader_id = 11
	state.teams[1] = t
	if with_threat:
		var e := TeamData.new(); e.team_id = 2; e.faction_id = 20; e.tile_pos = Vector2i(6,5)   # 鄰格敵、不同 faction
		AnonCohort.add(e.anon_cohorts, "平民", "healthy", 8); state.teams[2] = e
		state.team_discovered[1] = [2]   # ★self 已發現敵（belief gate）
		BeliefSystem.record_claim(state, 1, 2, 1, "親見", {"tile_pos": Vector2i(6,5)}, 1.0, false)   # 當 tick belief pos
	return [state, t]

func _guard(caution: float, martial: float, task: String = "", with_threat: bool = false) -> float:
	var a := _mk(caution, martial, task, with_threat)
	FactionAISystem.new()._update_guard_ratio(a[1], a[0])
	return a[1].guard_ratio

func _initialize() -> void:
	print("=== ①連續人格分化（慎重/好戰 modulate、非離散 5 值跳）machine-demonstrate ===")
	print("  --- guard_ratio vs 慎重（好戰0.5、無威脅、非攻擊）---")
	var prev := -1.0; var mono := true; var vals: Array = []
	for i in range(6):
		var c: float = float(i) / 5.0
		var g: float = _guard(c, 0.5)
		print("    慎重=%.1f  guard_ratio=%.4f" % [c, g])
		if g < prev - 1e-9: mono = false
		prev = g; vals.append(g)
	_ok(mono, "guard_ratio 對慎重單調遞增（連續人格、非離散跳）")
	_ok(vals[5] - vals[0] > 0.05 and vals.size() == 6, "慎重 0→1 guard 連續變化（非死值）")
	_ok(_guard(0.9, 0.5) > _guard(0.1, 0.5), "高慎重 %.3f > 低慎重 %.3f（守衛保守分化）" % [_guard(0.9, 0.5), _guard(0.1, 0.5)])
	_ok(_guard(0.5, 0.9) > _guard(0.5, 0.1), "高好戰 %.3f > 低好戰 %.3f（責任/尚武分化）" % [_guard(0.5, 0.9), _guard(0.5, 0.1)])

	print("=== ②belief-threat 升守 + god-view 除 ===")
	var no_threat: float = _guard(0.5, 0.5, "", false)
	var with_threat: float = _guard(0.5, 0.5, "", true)
	print("  無威脅 guard=%.4f  belief-threat guard=%.4f" % [no_threat, with_threat])
	_ok(with_threat > no_threat, "belief-threat（discovered+belief 敵）→ guard 升 %.3f>%.3f（感知威脅多守）" % [with_threat, no_threat])
	# ★god-view 除：敵在鄰格但 self 未 discovered（team_discovered 空）→ belief-threat 0 → guard=無威脅值（不偷看真位置）。
	var s := WorldState.new(); s.world = WorldData.new(); s.world.current_tick = 1000
	var t := TeamData.new(); t.team_id = 1; t.faction_id = 10; t.tile_pos = Vector2i(5,5)
	var lp := PersonData.new(); lp.id = 11; lp.values = {"慎重": 0.5, "好戰": 0.5}; s.persons[11] = lp; t.leader_id = 11
	s.teams[1] = t
	var e := TeamData.new(); e.team_id = 2; e.faction_id = 20; e.tile_pos = Vector2i(6,5); s.teams[2] = e   # 鄰格敵、但未 discovered
	FactionAISystem.new()._update_guard_ratio(t, s)
	_ok(abs(t.guard_ratio - no_threat) < 1e-6, "★未 discovered 敵在鄰格→guard=無威脅值 %.4f（god-view _has_hostile_within 除、不偷看真位置）" % t.guard_ratio)

	print("=== ③攻擊/掠奪 → 前線投入留守少 ===")
	_ok(_guard(0.5, 0.5, TeamData.TASK_ATTACK) < _guard(0.5, 0.5, ""), "攻擊中 guard %.3f < 非攻擊 %.3f（前線投入）" % [_guard(0.5, 0.5, TeamData.TASK_ATTACK), _guard(0.5, 0.5, "")])

	print("=== ④bounded [0.05,0.5] ===")
	_ok(_guard(1.0, 1.0, "", true) <= 0.5 + 1e-9 and _guard(1.0, 1.0, "", true) >= 0.5 - 1e-6,
		"極端(慎重1好戰1威脅) → clamp ≤0.5（%.4f、非崩上限）" % _guard(1.0, 1.0, "", true))
	_ok(_guard(0.0, 0.0, TeamData.TASK_ATTACK) >= 0.05, "極端低(慎重0好戰0攻擊) → ≥0.05 floor（%.4f、夜襲免疫不裸奔）" % _guard(0.0, 0.0, TeamData.TASK_ATTACK))

	if _fail == 0: print("=== DONE === ALL PASS")
	else: print("=== DONE === %d FAIL" % _fail)
	quit()
