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

	var farm_income_total: float = 0.0     # Σdelta，含delta==0(2026-09-08修正:去掉delta>0.0過濾,同主床同一bug)
	var farm_entry_count: int = 0          # 所有市場賣糧entry數，含delta==0
	var farm_zero_price_count: int = 0     # 其中delta==0的筆數(=賣了但零價)
	var farm_income_by_team: Dictionary = {}  # 只收非零delta
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
						farm_entry_count += 1
						farm_income_total += delta
						if is_equal_approx(delta, 0.0):
							farm_zero_price_count += 1
						else:
							var tid_e: int = ent.team_id
							farm_income_by_team[tid_e] = float(farm_income_by_team.get(tid_e, 0.0)) + delta
			WorldState.clear_driver_ledger()
		if tick % 10000 == 0 and tick > 0:
			print("[CHECKPOINT] tick=%d farm_income累計=%.2f(entry=%d,零價=%d) ledger_seen=%d overflow_hits=%d" % [
				tick, farm_income_total, farm_entry_count, farm_zero_price_count, ledger_seen, overflow_hits])

	var produce_team_count: int = 0
	for tid3 in state.teams:
		var t3 = state.teams[tid3]
		if t3 is TeamData and t3.tags.has(TeamData.TAG_PRODUCE):
			produce_team_count += 1

	print("\n=== 結果 ===")
	print("[OK] 陽性對照：ledger_seen=%d" % ledger_seen)
	print("[OVERFLOW-CHECK] overflow_hits=%d（0=未溢出，直接量證）" % overflow_hits)
	print("④農隊收入(⑨世界market_sell_coin_in，PRODUCE隊，2026-09-08修正:不再濾delta>0.0)：")
	print("  entry筆數(含零價)=%d｜其中零價筆數=%d｜非零總額=%.2f｜非零涉及隊數=%d" % [
		farm_entry_count, farm_zero_price_count, farm_income_total, farm_income_by_team.size()])
	print("  PRODUCE隊母體(末tick快照)=%d" % produce_team_count)
	if farm_entry_count == 0:
		if produce_team_count == 0:
			print("  ★(a)不可判——PRODUCE隊母體末tick=0")
		else:
			print("  ★(b)真0——有PRODUCE隊(%d)但整輪零賣出entry" % produce_team_count)
	elif is_equal_approx(farm_income_total, 0.0):
		print("  ★★★(c)賣了但零價——entry筆數=%d全部delta==0⇒零價機制成立(⑩後果格答案成立)" % farm_entry_count)
	else:
		print("  ★正常有非零收入(非零entry=%d)：" % (farm_entry_count - farm_zero_price_count))
		for tid2 in farm_income_by_team.keys():
			print("  team=%d 收入=%.2f" % [tid2, farm_income_by_team[tid2]])
	print("★世界誠實限：貨幣量未過校驗（±14×待判）")
	print("=== farm_income_only_bed DONE ===")
