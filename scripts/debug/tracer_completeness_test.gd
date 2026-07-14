extends SceneTree

# SpecimenTracer 完整性 TDD（slice: tracer-completeness，第三觀測洞根治）
# spec: docs/superpowers/specs/2026-07-15-tracer-completeness.md
#
# Fix 1 路徑維 attempt-tap：capture_decision 加 result（committed/finder_miss/try_set_noop）→ churn 現形。
# Fix 2 時間維 heartbeat：evaluate_all 末尾 sweep，specimen 無決策超 HEARTBEAT_CADENCE→補心跳→timeline 無洞。
# Fix 3 盲點閘：churn 床斷言 timeline gap≤CADENCE + result!=committed≥1；tracer on/off byte-identical。

var _fail: int = 0
const CFG := "res://config/warring_states.json"

func _initialize() -> void:
	_test_attempt_tap_result()
	_test_heartbeat_fills_gap()
	_test_churn_gate_and_gapless()
	_test_tracer_onoff_byte_identical()
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

# ── Fix 1：capture_decision result 參數 → entry.做什麼.result ──
func _test_attempt_tap_result() -> void:
	print("--- Fix 1：attempt-tap result（committed/finder_miss/try_set_noop）---")
	SpecimenTracer.reset(); SpecimenTracer.enabled = true
	var state := WorldState.new(); state.world = WorldData.new(); state.world.current_tick = 100
	var t := TeamData.new(); t.team_id = 1
	AnonCohort.add(t.anon_cohorts, "平民", "healthy", 5); state.teams[1] = t
	state.specimen_team_ids = [1]
	SpecimenTracer.capture_decision(state, t, "掠奪", TeamData.TASK_LOOT, Vector2i(-1, -1), "finder_miss")
	SpecimenTracer.capture_decision(state, t, "併入", TeamData.TASK_JOIN, Vector2i(3, 3), "try_set_noop")
	SpecimenTracer.capture_decision(state, t, "覓食", TeamData.TASK_FORAGE, Vector2i(2, 2))   # 預設 committed
	var arch: Array = SpecimenTracer._archive
	_ok(arch.size() == 3, "3 attempt entries（含 fail 路徑），實際=%d" % arch.size())
	_ok(arch[0]["做什麼"]["result"] == "finder_miss", "finder_miss entry result")
	_ok(arch[1]["做什麼"]["result"] == "try_set_noop", "try_set_noop entry result")
	_ok(arch[2]["做什麼"]["result"] == "committed", "預設 result=committed（既有 call 不破）")
	SpecimenTracer.reset()

# ── Fix 2：heartbeat_sweep 填洞（無洞、不膨脹）──
func _test_heartbeat_fills_gap() -> void:
	print("--- Fix 2：heartbeat 填洞（timeline 無 >CADENCE 洞、不膨脹）---")
	SpecimenTracer.reset(); SpecimenTracer.enabled = true
	var state := WorldState.new(); state.world = WorldData.new(); state.world.current_tick = 100000
	var t := TeamData.new(); t.team_id = 1; t.leader_id = -1
	AnonCohort.add(t.anon_cohorts, "平民", "healthy", 5); state.teams[1] = t
	state.specimen_team_ids = [1]
	SpecimenTracer.heartbeat_sweep(state)
	_ok(SpecimenTracer._archive.size() == 1 and SpecimenTracer._archive[0].get("phase") == "heartbeat",
		"首次(無 entry)→補 heartbeat")
	SpecimenTracer.heartbeat_sweep(state)
	_ok(SpecimenTracer._archive.size() == 1, "gap<CADENCE→不重複膨脹")
	state.world.current_tick += SpecimenTracer.HEARTBEAT_CADENCE
	SpecimenTracer.heartbeat_sweep(state)
	_ok(SpecimenTracer._archive.size() == 2, "超 CADENCE→再補心跳")
	# 決策 entry 更新 _last_entry_tick → gap 內不補
	SpecimenTracer.capture_decision(state, t, "覓食", TeamData.TASK_FORAGE, Vector2i(2, 2))
	SpecimenTracer.heartbeat_sweep(state)
	_ok(SpecimenTracer._archive.size() == 3, "決策後 gap 內不補心跳（decision 覆蓋 tick）")
	SpecimenTracer.reset()

# ── warring 世界 runner（specimen on/off）──
func _run_warring(seed_val: int, ticks: int, specimen: Array, tracer_on: bool) -> Dictionary:
	seed(seed_val)
	var state := WorldState.new()
	var runner := SimRunner.new()
	var cfg: Dictionary = GameSetup.load_config(CFG); cfg["seed"] = seed_val
	GameSetup.setup(state, cfg)
	SimRunner.force_full_hd = true
	SpecimenTracer.reset()
	if tracer_on:
		state.specimen_team_ids.assign(specimen)
		SpecimenTracer.enabled = true
	var no_player := Vector2i(-1, -1)
	for _i in range(ticks):
		runner.advance_tick(state, no_player)
		if state.encounter_active and state.encounter_tick > 800:
			runner._encounter_system.resolve_encounter_end(state, "draw")
	var arch: Array = SpecimenTracer._archive.duplicate(true)
	SpecimenTracer.enabled = false
	SimRunner.force_full_hd = false
	return {"sig": _world_sig(state), "archive": arch}

func _world_sig(state: WorldState) -> String:
	var ids: Array = state.teams.keys(); ids.sort()
	var arr: Array = []
	for tid in ids:
		var t: TeamData = state.teams[tid]
		arr.append([tid, t.tile_pos.x, t.tile_pos.y, t.population, t.current_task, t.task_priority,
			snappedf(float(t.resources.get("food", 0)), 0.01)])
	return JSON.stringify(arr)

# ── Fix 3 盲點閘：churn 床（timeline gap≤CADENCE + result!=committed≥1）──
func _test_churn_gate_and_gapless() -> void:
	print("--- Fix 3 盲點閘：churn 床（timeline 無洞 + commit-fail 現形）---")
	var r: Dictionary = _run_warring(1337, 400, [7], true)   # Team7 specimen
	var arch: Array = r["archive"]
	_ok(arch.size() > 0, "specimen 有 entry（%d）" % arch.size())
	# ① 時間維：相鄰 entry 最大 gap ≤ HEARTBEAT_CADENCE（heartbeat 保無洞）
	var ticks_seen: Array = []
	for e in arch:
		if int(e.get("team_id", -1)) == 7: ticks_seen.append(int(e["tick"]))
	ticks_seen.sort()
	var max_gap: int = 0
	for i in range(1, ticks_seen.size()):
		max_gap = maxi(max_gap, ticks_seen[i] - ticks_seen[i - 1])
	_ok(ticks_seen.size() > 0 and max_gap <= SpecimenTracer.HEARTBEAT_CADENCE,
		"①timeline 最大 gap(%d) ≤ HEARTBEAT_CADENCE(%d)（無時間洞）" % [max_gap, SpecimenTracer.HEARTBEAT_CADENCE])
	# ② 路徑維：commit-fail（result!=committed，含 heartbeat/finder_miss/try_set_noop）現形 ≥1
	var non_committed: int = 0
	for e in arch:
		var r2: String = String(e.get("做什麼", {}).get("result", "")) if e.has("做什麼") else ""
		if e.get("phase") == "heartbeat" or (r2 != "" and r2 != "committed"):
			non_committed += 1
	_ok(non_committed >= 1, "②commit-fail/heartbeat entry ≥1（churn/空檔現形），實際=%d" % non_committed)

# ── 核心驗收：tracer on/off → 世界 byte-identical（觀測非侵入硬證）──
func _test_tracer_onoff_byte_identical() -> void:
	print("--- ★核心：tracer on/off 世界 byte-identical（觀測禁改世界）---")
	var on: Dictionary = _run_warring(1337, 300, [7], true)
	var off: Dictionary = _run_warring(1337, 300, [], false)
	_ok(on["sig"] == off["sig"], "tracer on vs off → 世界 byte-identical（觀測非侵入）")
	if on["sig"] != off["sig"]:
		print("    on =%s" % on["sig"].substr(0, 180))
		print("    off=%s" % off["sig"].substr(0, 180))
