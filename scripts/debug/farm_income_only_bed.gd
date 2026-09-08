extends SceneTree
# farm_income_only_bed：④農隊收入專用小床(economic_window_4cell_bed的④格因drain間隔2000導致
# driver_ledger溢出21次，數字不可信，已作廢重測)。drain間隔改50(同member_tax血教訓)。
# 用法：BED_CONFIG(default res://config/warring_states.json) BED_DAYS(default 30) BED_SEED(default 1337)

func _initialize() -> void:
	_run(); quit()

func _run() -> void:
	var days: int = int(OS.get_environment("BED_DAYS")) if OS.has_environment("BED_DAYS") else 30
	var cfg: String = OS.get_environment("BED_CONFIG") if OS.has_environment("BED_CONFIG") else "res://config/warring_states.json"
	var seed_val: int = int(OS.get_environment("BED_SEED")) if OS.has_environment("BED_SEED") else 1337
	seed(seed_val)
	WorldState.driver_ledger_enabled = true
	WorldState.clear_driver_ledger()
	var state: WorldState = MeasureBedHelper.arm_and_setup(cfg, true)
	var runner := SimRunner.new()
	var ticks: int = days * WorldState.TICKS_PER_DAY
	var no_player := Vector2i(-1, -1)

	print("=== farm_income_only_bed: config=%s days=%d ticks=%d seed=%d ===" % [cfg, days, ticks, seed_val])

	var farm_income_total: float = 0.0
	var farm_income_count: int = 0
	var farm_income_by_team: Dictionary = {}
	var overflow_hits: int = 0
	var ledger_seen: int = 0

	for tick in range(ticks):
		runner.advance_tick(state, no_player)
		if tick % 50 == 0 and tick > 0:
			if WorldState.driver_ledger.size() >= WorldState.driver_ledger_cap:
				overflow_hits += 1
			for e in WorldState.driver_ledger:
				ledger_seen += 1
				if String(e.get("reason", "")) == "market_sell_coin_in":
					var ent = e.get("entity")
					if ent is TeamData and ent.tags.has(TeamData.TAG_PRODUCE):
						var delta: float = float(e.get("delta", 0.0))
						if delta > 0.0:
							farm_income_total += delta
							farm_income_count += 1
							var tid_e: int = ent.team_id
							farm_income_by_team[tid_e] = float(farm_income_by_team.get(tid_e, 0.0)) + delta
			WorldState.clear_driver_ledger()
		if tick % 10000 == 0 and tick > 0:
			print("[CHECKPOINT] tick=%d farm_income累計=%.2f(%d筆) ledger_seen=%d overflow_hits=%d" % [
				tick, farm_income_total, farm_income_count, ledger_seen, overflow_hits])

	print("\n=== 結果 ===")
	print("[OK] 陽性對照：ledger_seen=%d" % ledger_seen)
	print("[OVERFLOW-CHECK] overflow_hits=%d（0=未溢出，直接量證）" % overflow_hits)
	print("④農隊收入(⑨世界market_sell_coin_in，PRODUCE隊)：總額=%.2f 筆數=%d 涉及隊數=%d" % [
		farm_income_total, farm_income_count, farm_income_by_team.size()])
	if farm_income_count == 0:
		print("  ★★零筆——PRODUCE隊母體是否存在需另查（若為0則不可判非結論0）")
	else:
		for tid2 in farm_income_by_team.keys():
			print("  team=%d 收入=%.2f" % [tid2, farm_income_by_team[tid2]])
	print("★世界誠實限：貨幣量未過校驗（±14×待判）")
	print("=== farm_income_only_bed DONE ===")
