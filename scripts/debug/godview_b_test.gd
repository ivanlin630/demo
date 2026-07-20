extends SceneTree

# god-view Slice B TDD（spec 2026-07-20-godview-slice-B）。
# 創世全知(all-pairs discovered)=bug → ②+③ 創世知識 + relay-discovery。
# ② 同 faction 互 discovered / ③ 本地鄰居(proximity≤CREATION_KNOW_RADIUS) / 淵源(parent) / omniscient flag(default false)。
# relay-discovery：message _exchange_intel 告知未識隊 → 連帶 discover + belief entry（含 distorted）。

var _fail: int = 0

func _initialize() -> void:
	_test_same_faction_discovered()    # ①② 同 faction 創世 discovered
	_test_local_neighbor_discovered()  # ②③ 本地鄰居 discovered、遠隊不
	_test_omniscient_flag_all_pairs()  # ③ omniscient=true 保 all-pairs
	_test_default_not_omniscient()     # ④ default(無 flag)=②③ 非全知
	_test_relay_discovery()            # ⑤ relay 告知未識 → discover + belief
	_test_relay_distorted_discovery()  # ⑥ distorted relay 也 discover
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

# config：t0(fac0 @0,0)/t1(fac0 @10,10 遠)/t2(fac1 @1,0 近 t0)
func _mk_config(omniscient: bool) -> Dictionary:
	var cfg: Dictionary = {
		"teams": [
			{"id": 0, "tile_pos": [0, 0], "faction_id": 0, "is_faction_leader": true},
			{"id": 1, "tile_pos": [10, 10], "faction_id": 0},
			{"id": 2, "tile_pos": [1, 0], "faction_id": 1, "is_faction_leader": true},
		]
	}
	if omniscient: cfg["omniscient_discovery"] = true
	return cfg

func _run_setup(omniscient: bool) -> WorldState:
	var state := WorldState.new(); state.world = WorldData.new()
	GameSetup._setup_explicit_teams(state, _mk_config(omniscient))
	return state

# ①② 同 faction：t0-t1 同 faction 0 → 互 discovered（即使 t1 遠 @10,10）
func _test_same_faction_discovered() -> void:
	print("--- ①② 同 faction 創世 discovered ---")
	var s := _run_setup(false)
	_ok(s.team_discovered.get(0, []).has(1), "t0 discover t1（同 faction 0，即使遠）")
	_ok(s.team_discovered.get(1, []).has(0), "t1 discover t0（同 faction，雙向）")

# ②③ 本地鄰居：t0-t2 近(dist 1≤3)→discovered（diff faction）；t1-t2 遠 diff faction→不
func _test_local_neighbor_discovered() -> void:
	print("--- ②③ 本地鄰居 discovered、遠隊不 ---")
	var s := _run_setup(false)
	_ok(s.team_discovered.get(0, []).has(2), "t0 discover t2（本地鄰居 dist1≤3，diff faction）")
	_ok(s.team_discovered.get(2, []).has(0), "t2 discover t0（本地鄰居雙向）")
	_ok(not s.team_discovered.get(1, []).has(2), "t1 NOT discover t2（遠 dist>3 + diff faction → 非全知）")
	_ok(not s.team_discovered.get(2, []).has(1), "t2 NOT discover t1（同上）")

# ③ omniscient_discovery=true → 保 all-pairs
func _test_omniscient_flag_all_pairs() -> void:
	print("--- ③ omniscient flag 保 all-pairs ---")
	var s := _run_setup(true)
	_ok(s.team_discovered.get(1, []).has(2), "omniscient=true → t1 discover t2（全知 all-pairs）")
	_ok(s.team_discovered.get(2, []).has(1), "omniscient=true → t2 discover t1")

# ④ default（無 flag）= ②③ 非全知（t1-t2 遠 diff faction 不互見）
func _test_default_not_omniscient() -> void:
	print("--- ④ default 非全知 ---")
	var s := _run_setup(false)
	_ok(not s.team_discovered.get(1, []).has(2) and not s.team_discovered.get(2, []).has(1),
		"default(無 flag) → 遠 diff-faction 不互見（非開局全知）")

# ── relay-discovery ──
func _mk_relay_state() -> Array:   # [state, giver=1, receiver=2, tgt=3]
	var state := WorldState.new(); state.world = WorldData.new(); state.world.current_tick = 1000
	for tid in [1, 2, 3]:
		var t := TeamData.new(); t.team_id = tid; t.tile_pos = Vector2i(tid, 0)
		var l := PersonData.new(); l.id = 100 + tid; state.persons[100 + tid] = l; t.leader_id = 100 + tid
		AnonCohort.add(t.anon_cohorts, "平民", "healthy", 5); state.teams[tid] = t
	# giver(1) 認識 tgt(3)（有 belief）；receiver(2) 未識 tgt(3)
	state.team_discovered[1] = [3]
	state.team_discovered[2] = []
	return [state]

# ⑤ relay：giver 告知 receiver 關於未識 tgt → receiver discover tgt + belief entry
func _test_relay_discovery() -> void:
	print("--- ⑤ relay-discovery ---")
	var w: Array = _mk_relay_state()
	var state: WorldState = w[0]
	BeliefSystem.record_claim(state, 1, 3, 1, "親見", {"population_est": 5, "tile_pos": Vector2i(3, 0)}, 1.0, false)   # giver 親見 tgt
	SimMessageSystem.new()._exchange_intel(state, 1, 2)   # giver=1 告知 receiver=2
	_ok(state.team_discovered.get(2, []).has(3), "receiver(2) 經 relay discover tgt(3)（未識→聽說→識）")
	_ok(not BeliefSystem.best_estimate(state, 2, 3).is_empty(), "receiver 對 tgt 建 belief entry（record_claim）")

# ⑥ distorted relay 也 discover（team 真存在，只 details 失真）
func _test_relay_distorted_discovery() -> void:
	print("--- ⑥ distorted relay 也 discover ---")
	var w: Array = _mk_relay_state()
	var state: WorldState = w[0]
	# giver 對 tgt 的 belief 標 distorted（lie claim）
	BeliefSystem.record_claim(state, 1, 3, 1, "親見", {"population_est": 5, "tile_pos": Vector2i(3, 0)}, 1.0, true)
	SimMessageSystem.new()._exchange_intel(state, 1, 2)
	_ok(state.team_discovered.get(2, []).has(3), "distorted relay → receiver 仍 discover tgt（存在為真，details 可假）")
