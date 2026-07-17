extends SceneTree

# seam#3 S1 sim_runner SYSTEMS registry characterization + 擴充 proof（byte-identical）
# spec: docs/superpowers/specs/2026-07-17-seam3-sim-runner-systems-registry.md
#
# _advance_tick_body near+far 雙分支 → SYSTEMS registry 統一 loop。
# ★byte-identical 硬要求：phase_timing label 序（觀測）+ near/far step 序 + team set + cadence。
# 本 char bed 釘 phase_timing label 序（結構性、RNG-無關）——觀測 byte-identical 主證。
# near+far step 序 byte-identical 由 seeded warring/game_sim total_diffs=0 硬證（tick loop=全 sim）。
# 擴充 proof（加 dummy BOTH 系統=1 entry，near+far 皆執行）refactor 前 RED、後 GREEN。

var _fail: int = 0

func _initialize() -> void:
	_test_phase_timing_label_sequence()
	_test_extensibility_dummy_both()
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

# ── phase_timing label 序（near+far tick，觀測 byte-identical）──
func _test_phase_timing_label_sequence() -> void:
	print("--- phase_timing label 序（near+far tick）---")
	seed(42)
	var state := WorldState.new()
	var runner := SimRunner.new()
	var config: Dictionary = GameSetup.load_config("res://config/default.json")
	config["seed"] = 42
	GameSetup.setup(state, config)
	SimRunner.phase_timing = true
	var no_player := Vector2i(-1, -1)
	var labels: Array = []
	# 推進到「完整 near+far」tick（tick%FAR==0 且 near 全跑完=有 near.events_emit，無 encounter 早退）
	while state.world.current_tick < 2000:
		runner.advance_tick(state, no_player)
		if state.world.current_tick % SimRunner.FAR_ZONE_INTERVAL == 0 \
				and ("near.events_emit" in runner._ph):
			labels = runner._ph.keys()
			break
	SimRunner.phase_timing = false
	var expected: Array = [
		"day_boundary", "near.forced_event", "near.vision", "near.equip", "near.move",
		"near.messages", "near.interact", "near.outpost_ambush", "near.economy", "near.consume",
		"near.faction_ai", "near.strategic_ai", "near.reactions", "near.events_emit",
		"harvest", "far.total", "captives_cleanup",
	]
	_ok(labels == expected, "phase_timing label 序 byte-identical\n    got=%s\n    exp=%s" % [str(labels), str(expected)])

# ── 擴充 proof：加 1 個 BOTH 系統 entry = near+far 皆自動執行（不改 loop 本體）──
func _test_extensibility_dummy_both() -> void:
	print("--- 擴充 proof：加 BOTH 系統 registry 1 entry ---")
	SimRunner.SYSTEMS.append({
		"name": "__dummy_both__", "fn": "_seam3_dummy_step", "lod": SimRunner.LOD_BOTH,
		"shape": "state", "tl": "",
	})
	Probe.reset(); Probe.enabled = true
	seed(7)
	var state := WorldState.new()
	var runner := SimRunner.new()
	var config: Dictionary = GameSetup.load_config("res://config/default.json")
	config["seed"] = 7
	GameSetup.setup(state, config)
	var no_player := Vector2i(-1, -1)
	var ran_far := false
	while state.world.current_tick < 2000:
		runner.advance_tick(state, no_player)
		if state.world.current_tick % SimRunner.FAR_ZONE_INTERVAL == 0:
			ran_far = true
			break
	Probe.enabled = false
	_ok(ran_far, "跑到 near+far tick")
	_ok(int(Probe.counts.get("seam3.dummy", 0)) >= 2, "dummy BOTH 系統 near+far 皆執行（calls=%d≥2）" % int(Probe.counts.get("seam3.dummy", 0)))
	SimRunner.SYSTEMS.pop_back()
