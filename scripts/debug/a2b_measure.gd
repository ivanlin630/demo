extends SceneTree

# A2b 守衛 A/B probe 專用量測機
# 用法：godot --headless --script a2b_measure.gd
# 環境變數：
#   A2B_SEED：seed（default 1337）
#   A2B_MONTHS：月數（default 12）

func _initialize() -> void:
	_run()
	quit()

func _run() -> void:
	var seed: int = int(OS.get_environment("A2B_SEED")) if OS.has_environment("A2B_SEED") else 1337
	var months: int = int(OS.get_environment("A2B_MONTHS")) if OS.has_environment("A2B_MONTHS") else 12
	var ticks: int = months * WorldState.TICKS_PER_MONTH

	print("=== A2b Probe Measurer ===")
	print("seed=%d months=%d (ticks=%d)" % [seed, months, ticks])

	var result: Dictionary = WarringHarness.run(seed, ticks)
	if result.is_empty():
		print("[FAIL] warring harness 空")
		return

	# 直接讀 Probe.counts 取 a2b.* 三數
	var leader_attack: int = int(Probe.counts.get("a2b.leader_attack", 0))
	var dispatch: int = int(Probe.counts.get("a2b.remote_tribute_dispatch", 0))
	var settle: int = int(Probe.counts.get("a2b.remote_tribute_settle", 0))

	print("\n[a2b] leader_attack=%d dispatch=%d settle=%d" % [leader_attack, dispatch, settle])
	print("[a2b] 守衛 A(leader_attack>0): %s" % ("PASS" if leader_attack > 0 else "FAIL"))
	print("[a2b] 守衛 B(settle>0): %s" % ("PASS" if settle > 0 else "FAIL"))
	if dispatch > 0 and settle == 0:
		print("[a2b] ⚠ dispatch 有但 settle 為 0（派了收不到）")

	# dump JSON
	var out: Dictionary = {
		"seed": seed,
		"months": months,
		"ticks": ticks,
		"a2b": {
			"leader_attack": leader_attack,
			"remote_tribute_dispatch": dispatch,
			"remote_tribute_settle": settle,
		},
		"final_teams": result["final"]["teams"],
		"final_pop": result["final"]["pop"],
	}

	print("\n[json] " + JSON.stringify(out, "  "))
	print("=== A2b Probe Measurer DONE ===")
