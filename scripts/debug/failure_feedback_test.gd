extends SceneTree
# 執行失敗反饋機制 Phase 0 TDD（slice: failure-feedback）。
# ①同因第二次真的降分（單調下降）②count_factor 觸頂後不再加深
# ③★FLOOR 生效：連撞很多次仍 >= FLOOR，且絕境加法 boost 仍能壓過折價（不得絕對否決）
# ④TTL 過期 → 恢復原值（非永久黑名單）⑤bounded：過期項被 prune
# ⑥失效升 T0：record_invalidation → 該隊當 tick pending_rethink
# ⑦可觀測：failure.recorded.<reason> / failure.suppressed.<option> 有值
# ⑧未接線 option 零折價（對其餘 option 零行為）

var _fail := 0
func _ok(c: bool, m: String) -> void:
	if c: print("  PASS ", m)
	else: _fail += 1; print("  FAIL ", m)

func _initialize() -> void:
	_run(); quit()

func _mk() -> Array:
	var s := WorldState.new(); s.world = WorldData.new(); s.player_id = -1
	s.world.current_tick = 10000
	var t := TeamData.new(); t.team_id = 4; t.tile_pos = Vector2i(0, 0)
	AnonCohort.add(t.anon_cohorts, "平民", "healthy", 6)
	s.teams[4] = t
	return [s, t]

func _run() -> void:
	print("=== failure feedback Phase 0 test ===")
	var TTL: int = OrderSystem.ORDER_LIFETIME
	Probe.enabled = true; Probe.reset()

	# ① 同因第二次降分（單調）
	var w := _mk(); var s: WorldState = w[0]; var t: TeamData = w[1]
	_ok(is_equal_approx(FailureMemory.mult_for_option(s, t, "買糧"), 1.0), "①無記憶 → 乘數 1.0（零行為）")
	FailureMemory.record(s, t, "買單", "food", TTL, "order_abandoned_buy")
	var m1: float = FailureMemory.mult_for_option(s, t, "買糧")
	FailureMemory.record(s, t, "買單", "food", TTL, "order_abandoned_buy")
	var m2: float = FailureMemory.mult_for_option(s, t, "買糧")
	FailureMemory.record(s, t, "買單", "food", TTL, "order_abandoned_buy")
	var m3: float = FailureMemory.mult_for_option(s, t, "買糧")
	_ok(m1 < 1.0 and m2 < m1 and m3 < m2, "★①同因連撞單調降分（%.3f > %.3f > %.3f）" % [m1, m2, m3])

	# ② count 觸頂後不再加深
	for i in range(5):
		FailureMemory.record(s, t, "買單", "food", TTL, "order_abandoned_buy")
	var m_cap: float = FailureMemory.mult_for_option(s, t, "買糧")
	_ok(is_equal_approx(m_cap, m3), "★②count_factor 觸頂（第 3 次後不再加深：%.3f == %.3f）" % [m_cap, m3])

	# ③ FLOOR + 絕境仍可翻盤
	_ok(m_cap >= FailureMemory.FLOOR - 0.0001, "★③折價不低於 FLOOR %.2f（實測 %.3f）" % [FailureMemory.FLOOR, m_cap])
	var base_u: float = 1.0
	var discounted: float = base_u * m_cap
	var desperate: float = discounted + DecisionEngine.SURVIVAL_BOOST_MAX * 0.5   # 絕境加法 boost（乘法之後）
	_ok(desperate > base_u, "★③絕境加法 boost 壓得過折價（%.2f > %.2f）＝不得絕對否決" % [desperate, base_u])

	# ⑦ 可觀測
	_ok(int(Probe.counts.get("failure.recorded.order_abandoned_buy", 0)) == 8, "⑦failure.recorded 有值（8 次）")
	_ok(int(Probe.counts.get("failure.suppressed.買單", 0)) > 0, "★⑦failure.suppressed 有值（放棄可觀測）")

	# ⑧ 未接線 option 零折價
	_ok(is_equal_approx(FailureMemory.mult_for_option(s, t, "生產"), 1.0), "⑧未接線 option 恆 1.0")

	# ④ TTL 過期恢復
	s.world.current_tick += TTL + 1
	_ok(is_equal_approx(FailureMemory.mult_for_option(s, t, "買糧"), 1.0), "★④TTL 過期 → 回原值（非永久黑名單）")

	# ⑤ bounded：prune 清掉過期項
	FailureMemory.prune(s, t)
	_ok(t.recent_failures.is_empty(), "⑤過期項被 prune（bounded）")

	# ⑥ 失效升 T0
	var w6 := _mk(); var s6: WorldState = w6[0]; var t6: TeamData = w6[1]
	Probe.reset()
	FailureMemory.record_invalidation(s6, t6, "歸建", "-", 2400, "arbiter_rejected_commitment")
	_ok(WorldEvents.is_pending(s6, 4), "★⑥失效 → 該隊當 tick 被喚醒（T0 pending）")
	_ok(int(Probe.counts.get("failure.invalidated.arbiter_rejected_commitment", 0)) == 1, "⑥失效有專屬 tap")
	_ok("plan_invalidated" in WorldEvents.all_kinds(), "★⑥新事件 kind 已在 world_events 登記（T0 對帳守衛看得到）")

	# ⑨ 記憶入 fingerprint（直接因果態）
	var w9 := _mk(); var s9: WorldState = w9[0]; var t9: TeamData = w9[1]
	var fp_before: String = StateFingerprint.compute(s9)
	FailureMemory.record(s9, t9, "買單", "food", TTL, "order_abandoned_buy")
	_ok(StateFingerprint.compute(s9) != fp_before, "★⑨失敗記憶入 state_fingerprint（fp 真的變）")

	Probe.enabled = false
	print("=== %s（fail=%d）===" % ["ALL PASS" if _fail == 0 else "HAS FAILURE", _fail])
