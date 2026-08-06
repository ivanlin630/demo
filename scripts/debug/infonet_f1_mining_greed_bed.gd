extends SceneTree

# [measurer persist fixture 2026-08-07] F1死常數人格化靶B測床(MINING_GREED連續性)。
# 工單:2026-08-07-systems-to-measurer-F1-measure.md
# Tier1控制場景直呼(同consolidation_decision_trace.gd模式)：手構最小WorldState(1 lord+
#   own outpost+鄰近ore mountain空格dist=2),呼叫_evaluate_new_outpost_location(state,lord)
#   對密集ga(貪婪+野心)sweep,驗證舊硬gate(1.1)附近無懸崖跳變、連續遞增。
#   獨立驗證(非重用implementer framework_f1_test.gd,自建控制場景交叉核對)。

func _initialize() -> void:
	print("=== F1靶B mining_greed連續性測床(Tier1控制場景直呼) ===")
	var fai := FactionAISystem.new()
	var sweep: Array = [0.2, 0.4, 0.6, 0.8, 0.9, 1.0, 1.05, 1.08, 1.09, 1.10, 1.11, 1.15, 1.2, 1.5, 1.8, 2.0]
	var results: Array = []
	for ga in sweep:
		var s := WorldState.new(); s.world = WorldData.new(); s.world.current_tick = 100
		var lord := TeamData.new(); lord.team_id = 1; lord.faction_id = 0; lord.tile_pos = Vector2i(10, 10)
		var ll := PersonData.new(); ll.id = 11; ll.values = {"貪婪": ga / 2.0, "野心": ga / 2.0}
		s.persons[11] = ll; lord.leader_id = 11
		s.teams[1] = lord
		var ho := HexTileData.new(); ho.tile_pos = Vector2i(10, 10); ho.terrain = "plains"
		ho.outpost_level = 1; ho.outpost_owner = 1; ho.outpost_type = "civilian"
		s.world.tiles[10010] = ho
		var om := HexTileData.new(); om.tile_pos = Vector2i(12, 10); om.terrain = "mountain"
		om.outpost_level = 0; om.outpost_owner = -1
		om.resource_cap = {"ore_gold": 50.0}; om.productivity = 0.3
		s.world.tiles[12010] = om
		var res: Dictionary = fai._evaluate_new_outpost_location(s, lord)
		var picked_mountain: bool = (not res.is_empty()) and res.get("pos") == Vector2i(12, 10)
		results.append({"ga": ga, "picked_mountain": picked_mountain})
		print("  ga=%.2f picked_mountain=%s" % [ga, str(picked_mountain)])

	print("\n───── F1靶B 摘要 ─────")
	# 找crossover點(第一個從false轉true的ga),確認非精準卡在舊gate=1.1(連續非硬gate證據)。
	var crossover: float = -1.0
	var prev_picked: bool = false
	for r in results:
		if bool(r["picked_mountain"]) and not prev_picked:
			crossover = float(r["ga"])
			break
		prev_picked = bool(r["picked_mountain"])
	print("crossover_ga=%.2f (若非精準等於1.10=非硬gate行為佐證;若>1.10附近平滑過渡亦可)" % crossover)
	print("完整sweep結果: %s" % str(results))

	var dump: Dictionary = {
		"diagnostic": "F1靶B mining_greed連續性(Tier1控制場景直呼,獨立於framework_f1_test.gd)",
		"sweep_results": results, "crossover_ga": crossover,
	}
	var f := FileAccess.open("res://docs/measurements/2026-08-07-infonet-f1-mining-greed.json", FileAccess.WRITE)
	if f != null:
		f.store_string(JSON.stringify(dump, "  ")); f.close()
		print("\n[dump] → res://docs/measurements/2026-08-07-infonet-f1-mining-greed.json")
	print("=== DONE ===")
	quit()
