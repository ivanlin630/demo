extends SceneTree
# salary_flow_baseline_bed：income-tax-split 前置量測【追加格】（2026-09-05，systems第⑤票followup）
# 目的：⑤票要抽的是「發薪流量」——若發薪額本身也接近0，新制一樣收0（廢一個收0機制換另一個）。
# 量 reason="salary_named"（總額/per-team/發生次數）+ reason="salary_anon"（對照組，anon不課稅）。
# 零production改動：走既有 WorldState.record_driver。同 member_tax_baseline_bed 陽性對照法。
# ★salary_named：team-side ResourceBank.remove(負delta) + person-side adjust_person_coin(正delta)成對
#   （salary_system.gd:66-67），跟member_tax一樣只算正delta那半避免double count。
# ★salary_anon：只有 team-side ResourceBank.remove(負delta，reason="salary_anon")；anon_treasury
#   credit那半用的是另一個reason="salary"（不同字串，本票不量），故salary_anon只能取負delta絕對值。
# 用法：BED_CONFIG(default res://config/peaceful_economy.json) BED_DAYS(default 90) BED_SEED(default 1337)

func _initialize() -> void:
	_run(); quit()

func _drain(state: WorldState, acc: Dictionary) -> void:
	if WorldState.driver_ledger.size() >= WorldState.driver_ledger_cap:
		acc["overflow_hits"] = int(acc.get("overflow_hits", 0)) + 1
	for e in WorldState.driver_ledger:
		acc["ledger_seen"] = int(acc["ledger_seen"]) + 1
		var reason: String = String(e.get("reason", ""))
		var delta: float = float(e.get("delta", 0.0))
		var ent = e.get("entity")
		if reason == "salary_named":
			if delta <= 0.0:
				continue   # 只算 person側正delta，跟team側負delta對稱算一次即可
			if not (ent is PersonData):
				continue
			acc["named_total"] = float(acc["named_total"]) + delta
			acc["named_count"] = int(acc["named_count"]) + 1
			# per-team 用不到 person 本身的 team_id（PersonData沒存team_id）——改記次數/總額，不強求per-team
		elif reason == "salary_anon":
			if delta >= 0.0:
				continue   # 只有team側負delta，取絕對值
			if not (ent is TeamData):
				continue
			var tid: int = ent.team_id
			var amt: float = -delta
			acc["anon_total"] = float(acc["anon_total"]) + amt
			acc["anon_count"] = int(acc["anon_count"]) + 1
			var per_team_anon: Dictionary = acc["per_team_anon"]
			per_team_anon[tid] = float(per_team_anon.get(tid, 0.0)) + amt
	WorldState.clear_driver_ledger()

func _run() -> void:
	var days: int = int(OS.get_environment("BED_DAYS")) if OS.has_environment("BED_DAYS") else 90
	var cfg: String = OS.get_environment("BED_CONFIG") if OS.has_environment("BED_CONFIG") else "res://config/peaceful_economy.json"
	var seed_val: int = int(OS.get_environment("BED_SEED")) if OS.has_environment("BED_SEED") else 1337
	seed(seed_val)
	WorldState.driver_ledger_enabled = true
	WorldState.clear_driver_ledger()
	var state: WorldState = MeasureBedHelper.arm_and_setup(cfg, true)
	var runner := SimRunner.new()
	var ticks: int = days * WorldState.TICKS_PER_DAY
	var no_player := Vector2i(-1, -1)

	var acc: Dictionary = {
		"ledger_seen": 0, "named_total": 0.0, "named_count": 0,
		"anon_total": 0.0, "anon_count": 0, "per_team_anon": {}, "overflow_hits": 0,
	}

	print("=== salary_flow_baseline_bed: config=%s days=%d ticks=%d seed=%d ===" % [cfg, days, ticks, seed_val])

	for tick in range(ticks):
		runner.advance_tick(state, no_player)
		if tick % 50 == 0 and tick > 0:   # ★間隔從2000→50（2026-09-05血教訓：2000tick窗恰好卡滿ring-buffer cap=4096,更早entry被靜默丟棄，實測rate~2/tick，50tick遠低於cap留足安全邊際）
			_drain(state, acc)
			print("[CHECKPOINT] tick=%d ledger_seen累計=%d named_total累計=%.1f anon_total累計=%.1f teams=%d" % [
				tick, int(acc["ledger_seen"]), float(acc["named_total"]), float(acc["anon_total"]), state.teams.size()])
	_drain(state, acc)
	WorldState.driver_ledger_enabled = false

	print("\n=== 結果 ===")
	var _ledger_seen: int = int(acc["ledger_seen"])
	if _ledger_seen <= 0:
		print("[FAIL] ★★★儀器對照失效：_ledger_seen=0，本輪數字【全部作廢】")
		print("=== salary_flow_baseline_bed DONE ===")
		return
	print("[OK] 陽性對照：_ledger_seen=%d（非零，ledger 真的在記）" % _ledger_seen)
	print("[OVERFLOW-CHECK] drain前摸到cap次數=%d（0=每次drain前size都<cap=4096，本輪未溢出，非推論是直接量）" % int(acc.get("overflow_hits", 0)))
	print("①salary_named總額=%.2f 發生次數=%d" % [float(acc["named_total"]), int(acc["named_count"])])
	print("②salary_anon總額=%.2f 發生次數=%d（對照組，anon不課稅）" % [float(acc["anon_total"]), int(acc["anon_count"])])
	print("②per-team(salary_anon)明細（team_id: 累計，按總額降冪）：")
	var per_team_anon: Dictionary = acc["per_team_anon"]
	var ids_sorted: Array = per_team_anon.keys()
	ids_sorted.sort_custom(func(a, b): return per_team_anon[a] > per_team_anon[b])
	for tid in ids_sorted:
		print("  team=%d salary_anon累計=%.2f" % [tid, per_team_anon[tid]])
	print("=== salary_flow_baseline_bed DONE ===")
