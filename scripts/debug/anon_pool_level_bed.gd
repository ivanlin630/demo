extends SceneTree
# anon_pool_level_bed：B議程第四件展品（2026-09-05，systems派，blueprint要）
# 目的：匿名池(team.anon_treasury)【活著但有沒有錢】——流量非零不代表水位有錢（進了馬上被extract走）。
# 零新tap：AnonTreasuryBank五個寫入路徑(deposit/withdraw/transfer/transfer_all/reset)全走
# WorldState.record_driver(kind="treasury")，已由systems驗過（anon_treasury_bank.gd:6/11/17/24/31）。
# ★水位不能用ledger總額反推——直接讀team.anon_treasury本身，periodic snapshot。
# ★consider_extraction實際fire數：grep原始log的「[Extract] TeamN 徵用」print行（coin_treasury.gd:34無條件印）。
# 用法：BED_CONFIG(default res://config/peaceful_economy.json) BED_DAYS(default 90) BED_SEED(default 1337)

func _initialize() -> void:
	_run(); quit()

func _drain(acc: Dictionary) -> void:
	var inflow_by_reason: Dictionary = acc["inflow_by_reason"]
	var outflow_by_reason: Dictionary = acc["outflow_by_reason"]
	if WorldState.driver_ledger.size() >= WorldState.driver_ledger_cap:
		acc["overflow_hits"] = int(acc.get("overflow_hits", 0)) + 1
	for e in WorldState.driver_ledger:
		if String(e.get("kind", "")) != "treasury":
			continue
		acc["treasury_rows"] = int(acc["treasury_rows"]) + 1
		var reason: String = String(e.get("reason", ""))   # ★空reason照系統要求單獨列一欄，不併「其他」
		var delta: float = float(e.get("delta", 0.0))
		if delta > 0.0:
			inflow_by_reason[reason] = float(inflow_by_reason.get(reason, 0.0)) + delta
		elif delta < 0.0:
			outflow_by_reason[reason] = float(outflow_by_reason.get(reason, 0.0)) + (-delta)
		else:
			acc["zero_delta_events"] = int(acc.get("zero_delta_events", 0)) + 1   # ★補先前honest_limit提過的落差：delta恰好=0的事件單獨計數，不消失
	WorldState.clear_driver_ledger()

func _percentile(sorted_arr: Array, p: float) -> float:
	if sorted_arr.is_empty():
		return 0.0
	var idx: float = p * (sorted_arr.size() - 1)
	var lo: int = int(floor(idx))
	var hi: int = int(ceil(idx))
	if lo == hi:
		return sorted_arr[lo]
	return sorted_arr[lo] + (sorted_arr[hi] - sorted_arr[lo]) * (idx - lo)

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
		"treasury_rows": 0, "inflow_by_reason": {}, "outflow_by_reason": {},
		"overflow_hits": 0, "zero_delta_events": 0,
	}
	var level_samples: Array = []   # ★水位樣本池：每次checkpoint把所有現存隊的anon_treasury丟進來
	var known_ids: Dictionary = {}

	print("=== anon_pool_level_bed: config=%s days=%d ticks=%d seed=%d ===" % [cfg, days, ticks, seed_val])

	for tick in range(ticks):
		runner.advance_tick(state, no_player)
		for tid in state.teams:
			known_ids[tid] = true
		if tick % 50 == 0 and tick > 0:   # ★間隔從2000→50（2026-09-05血教訓：2000tick窗恰好卡滿ring-buffer cap=4096,更早entry被靜默丟棄，實測rate~2/tick，50tick遠低於cap留足安全邊際）
			_drain(acc)
			var cur_max: float = 0.0
			for tid2 in state.teams:
				var t2: TeamData = state.teams[tid2]
				level_samples.append(t2.anon_treasury)
				cur_max = maxf(cur_max, t2.anon_treasury)
			print("[CHECKPOINT] tick=%d treasury_rows累計=%d 現存最高水位=%.1f teams=%d" % [
				tick, int(acc["treasury_rows"]), cur_max, state.teams.size()])
	_drain(acc)
	for tid3 in state.teams:
		level_samples.append(state.teams[tid3].anon_treasury)

	print("\n=== 結果 ===")
	var treasury_rows: int = int(acc["treasury_rows"])
	if treasury_rows <= 0:
		print("[FAIL] ★★★母體=0：record_driver kind=treasury 一列都沒有——儀器沒開或沒抽到，本輪數字全部作廢")
		print("=== anon_pool_level_bed DONE ===")
		return
	print("[OK] ①母體：record_driver treasury類總列數=%d（非零，ledger真的在記）" % treasury_rows)
	print("[OVERFLOW-CHECK] drain前摸到cap次數=%d（0=每次drain前size都<cap=4096，本輪未溢出，非推論是直接量）" % int(acc.get("overflow_hits", 0)))
	print("[ZERO-DELTA] delta恰好=0的treasury事件數=%d（不進inflow/outflow任一桶，但仍被計數，不消失）" % int(acc.get("zero_delta_events", 0)))

	print("②入金 by reason：")
	var inflow_by_reason: Dictionary = acc["inflow_by_reason"]
	for r in inflow_by_reason:
		var label: String = r if r != "" else "★空reason"
		print("  %s: %.2f" % [label, inflow_by_reason[r]])
	if inflow_by_reason.is_empty():
		print("  （完全沒有入金）")

	print("③出金 by reason：")
	var outflow_by_reason: Dictionary = acc["outflow_by_reason"]
	for r2 in outflow_by_reason:
		var label2: String = r2 if r2 != "" else "★空reason"
		print("  %s: %.2f" % [label2, outflow_by_reason[r2]])
	if outflow_by_reason.is_empty():
		print("  （完全沒有出金）")

	print("④水位（不從ledger反推，直接讀team.anon_treasury）：")
	var sorted_levels: Array = level_samples.duplicate()
	sorted_levels.sort()
	var lvl_max: float = sorted_levels[-1] if not sorted_levels.is_empty() else 0.0
	var lvl_median: float = _percentile(sorted_levels, 0.5)
	print("  全程樣本數=%d 全程最高=%.2f 全程中位=%.2f" % [level_samples.size(), lvl_max, lvl_median])
	print("  期末per-team水位（已知隊名冊=%d隊，現存=%d隊）：" % [known_ids.size(), state.teams.size()])
	var known_sorted: Array = known_ids.keys()
	known_sorted.sort()
	for tid4 in known_sorted:
		if state.teams.has(tid4):
			print("    team=%d anon_treasury=%.2f" % [tid4, state.teams[tid4].anon_treasury])
		else:
			print("    team=%d ★已消失（不在期末roster，非留白）" % tid4)

	print("⑤consider_extraction實際fire：★需另外grep原始log「[Extract] TeamN 徵用」print行計數（coin_treasury.gd:34無條件印，本床沒有內建計數器，避免跟print重複維護兩套真相源）")
	print("=== anon_pool_level_bed DONE ===")
