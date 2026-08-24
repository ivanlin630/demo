extends SceneTree
# 執行失敗反饋機制 Phase 0 TDD（slice: failure-feedback）。
# ①同因第二次真的降分（單調下降）②count_factor 觸頂後不再加深
# ③★FLOOR 生效：連撞很多次仍 >= FLOOR，且絕境加法 boost 仍能壓過折價（不得絕對否決）
# ④TTL 過期 → 恢復原值（非永久黑名單）⑤bounded：過期項被 prune
# ⑥失效升 T0：record_invalidation → 該隊當 tick pending_rethink
# ⑦可觀測：failure.recorded.<reason> / failure.suppressed.<結構身分 id> 有值
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
	_ok(is_equal_approx(FailureMemory.mult_for(s, t, "買糧"), 1.0), "①無記憶 → 乘數 1.0（零行為）")
	FailureMemory.record(s, t, "買糧", "", TTL, "order_abandoned_buy")
	var m1: float = FailureMemory.mult_for(s, t, "買糧")
	FailureMemory.record(s, t, "買糧", "", TTL, "order_abandoned_buy")
	var m2: float = FailureMemory.mult_for(s, t, "買糧")
	FailureMemory.record(s, t, "買糧", "", TTL, "order_abandoned_buy")
	var m3: float = FailureMemory.mult_for(s, t, "買糧")
	_ok(m1 < 1.0 and m2 < m1 and m3 < m2, "★①同因連撞單調降分（%.3f > %.3f > %.3f）" % [m1, m2, m3])

	# ② count 觸頂後不再加深
	for i in range(5):
		FailureMemory.record(s, t, "買糧", "", TTL, "order_abandoned_buy")
	var m_cap: float = FailureMemory.mult_for(s, t, "買糧")
	_ok(is_equal_approx(m_cap, m3), "★②count_factor 觸頂（第 3 次後不再加深：%.3f == %.3f）" % [m_cap, m3])

	# ③ FLOOR + 絕境仍可翻盤
	_ok(m_cap >= FailureMemory.FLOOR - 0.0001, "★③折價不低於 FLOOR %.2f（實測 %.3f）" % [FailureMemory.FLOOR, m_cap])
	var base_u: float = 1.0
	var discounted: float = base_u * m_cap
	var desperate: float = discounted + DecisionEngine.SURVIVAL_BOOST_MAX * 0.5   # 絕境加法 boost（乘法之後）
	_ok(desperate > base_u, "★③絕境加法 boost 壓得過折價（%.2f > %.2f）＝不得絕對否決" % [desperate, base_u])

	# ⑦ 可觀測
	_ok(int(Probe.counts.get("failure.recorded.order_abandoned_buy", 0)) == 8, "⑦failure.recorded 有值（8 次）")
	# ★key 空間改成【結構身分】後，suppressed 的後綴是【下令者 id】（買糧），
	#   不再是它依賴的那件事（買單）。這是 intended-change，不是斷言弱化：
	#   斷言的仍是「折價真的生效且看得見」，只是問對了名字。
	_ok(int(Probe.counts.get("failure.suppressed.買糧", 0)) > 0, "★⑦failure.suppressed 有值（折價可觀測）")

	# ⑧ 未接線 option 零折價
	_ok(is_equal_approx(FailureMemory.mult_for(s, t, "生產"), 1.0), "⑧無記憶的 id 恆 1.0（結構身分下不再有「未接線」，只有「沒失敗過」）")

	# ④ TTL 過期恢復
	s.world.current_tick += TTL + 1
	_ok(is_equal_approx(FailureMemory.mult_for(s, t, "買糧"), 1.0), "★④TTL 過期 → 回原值（非永久黑名單）")

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

	# ══════ 結構身分磚（2026-08-25）：★測【規律】不測結果 ══════
	# 規律：同一 (動作, 目標) 連續失敗 N 次 ⇒ 第 N+1 次的乘數【嚴格小於】第 1 次。
	#   ★用相對比較寫，不抄任何折價常數（INTENSITY/COUNT_CAP 改值時本測不該壞）。
	var wA := _mk(); var sA: WorldState = wA[0]; var tA: TeamData = wA[1]
	var first: float = FailureMemory.mult_for(sA, tA, "build_workshop:resource", "10,8")
	for _i in range(3):
		FailureMemory.record(sA, tA, "build_workshop:resource", "10,8", TTL, "order_abandoned_buy")
	var after: float = FailureMemory.mult_for(sA, tA, "build_workshop:resource", "10,8")
	_ok(after < first, "★磚①同一(動作,目標)連撞後乘數嚴格下降（%.3f < %.3f）" % [after, first])
	# ★反面：不同 target 的【同類】動作不受影響 ⇒ 證明沒有偷做類級泛化
	var other: float = FailureMemory.mult_for(sA, tA, "build_workshop:resource", "13,6")
	_ok(is_equal_approx(other, 1.0), "★★磚②不同 target 的同類動作不受影響（沒偷做類級泛化）＝%.3f" % other)
	# ★★靜態 option 與 candidate 共用【同一個查詢入口、同一個 key 空間】（§4：不得有兩套）
	var wB := _mk(); var sB: WorldState = wB[0]; var tB: TeamData = wB[1]
	FailureMemory.record(sB, tB, "買糧", "", TTL, "order_abandoned_buy")
	_ok(FailureMemory.mult_for(sB, tB, "買糧") < 1.0, "★磚③靜態 option 走同一入口（(id, ∅) 退化）")
	_ok(is_equal_approx(FailureMemory.mult_for(sB, tB, "買料"), 1.0), "磚③b 另一個靜態 id 不受影響")
	# ★磚④：key 由結構身分組出——同 id 不同 target ⇒ 兩筆獨立記憶（不是一筆）
	_ok(tA.recent_failures.size() == 1, "磚④exact-pair：只寫了一筆記憶（同 id 不同 target 不合併）")

	# ══════ 失敗三分類（blueprint 裁 2026-08-25）：前提型【不折價】但要留鉤子 ══════
	# ★法理：折價的語意是「這條路我試過、失敗了」的真實資訊；
	#   缺料的真實教訓是「先去解決料」，不是「這裡不好」⇒ 折價它就是把假教訓寫進記憶。
	var wC := _mk(); var sC: WorldState = wC[0]; var tC: TeamData = wC[1]
	var before_c: float = FailureMemory.mult_for(sC, tC, "build_workshop:resource", "9,9")
	for _j in range(3):
		FailureMemory.record_blocked(sC, tC, "build_workshop:resource", "9,9", "material_material")
	var after_c: float = FailureMemory.mult_for(sC, tC, "build_workshop:resource", "9,9")
	_ok(is_equal_approx(after_c, before_c), "★三分①前提型【不折價】（%.3f == %.3f）" % [after_c, before_c])
	_ok(tC.recent_failures.is_empty(), "★三分①前提型不寫 recent_failures（不污染折價記憶）")
	_ok(tC.blocked_by.has(FailureMemory.key("build_workshop:resource", "9,9")),
		"★★三分①blocked_by 有記（means-end 磚的鉤子，不得丟掉）")
	_ok(String((tC.blocked_by[FailureMemory.key("build_workshop:resource", "9,9")] as Dictionary).get("blocker", "")) == "material_material",
		"三分①blocked_by 記得【被什麼擋住】而不只是「失敗了」")
	# ★對照：同一個 id+target 走【執行型】仍然照折（證明不是把折價整個關掉）
	FailureMemory.record(sC, tC, "build_workshop:resource", "9,9", TTL, "order_abandoned_buy")
	_ok(FailureMemory.mult_for(sC, tC, "build_workshop:resource", "9,9") < before_c,
		"★★三分②執行型仍然折價（兩面分開驗：不是把折價關掉）")

	Probe.enabled = false
	print("=== %s（fail=%d）===" % ["ALL PASS" if _fail == 0 else "HAS FAILURE", _fail])
