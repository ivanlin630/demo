extends SceneTree
# batch1_compare_d45_bed：batch1-compare規格D(clamp命中率)+④(_pay_salary entry次數per team)+⑤(發薪unrest)
# ★誠實限先講：D/④/⑤這三格的tap(valuation.clamp_*/salary.pay_entry/salary.byteam.*/salary.payday.*)
#   全部是⑥⑦⑧這批才加的——①世界(daaabc46)完全沒有這些tap(已grep驗證：salary_system.gd零Probe，
#   trade_valuation.gd只有local_value.calls)。所以①世界這三格【不是0，是量不到】(批前無儀器覆蓋)，
#   只有local_value.calls(呼叫次數)可以兩世界對照當活動量參考。
# 用法：BED_CONFIG(default res://config/peaceful_economy.json) BED_DAYS(default 90) BED_SEED(default 1337)

func _initialize() -> void:
	_run(); quit()

func _run() -> void:
	var days: int = int(OS.get_environment("BED_DAYS")) if OS.has_environment("BED_DAYS") else 90
	var cfg: String = OS.get_environment("BED_CONFIG") if OS.has_environment("BED_CONFIG") else "res://config/peaceful_economy.json"
	var seed_val: int = int(OS.get_environment("BED_SEED")) if OS.has_environment("BED_SEED") else 1337
	seed(seed_val)
	Probe.arm()
	var state: WorldState = MeasureBedHelper.arm_and_setup(cfg, true)
	var runner := SimRunner.new()
	var ticks: int = days * WorldState.TICKS_PER_DAY
	var no_player := Vector2i(-1, -1)

	print("=== batch1_compare_d45_bed: config=%s days=%d ticks=%d seed=%d ===" % [cfg, days, ticks, seed_val])

	for tick in range(ticks):
		runner.advance_tick(state, no_player)
		if tick % 20000 == 0 and tick > 0:
			print("[CHECKPOINT] tick=%d teams=%d" % [tick, state.teams.size()])

	print("\n=== D 物價clamp命中率 ===")
	var calls: int = int(Probe.counts.get("local_value.calls", 0))
	var lo: int = int(Probe.counts.get("valuation.clamp_lo", 0))
	var hi: int = int(Probe.counts.get("valuation.clamp_hi", 0))
	var none: int = int(Probe.counts.get("valuation.clamp_none", 0))
	print("local_value.calls(母體)=%d" % calls)
	if lo == 0 and hi == 0 and none == 0:
		print("★valuation.clamp_*三桶不存在(批前世界無此tap，量不到，非0)")
	else:
		print("撞下界(clamp_lo)=%d 撞上界(clamp_hi)=%d 未撞(clamp_none)=%d 三桶加總=%d(應等於母體%d)" % [
			lo, hi, none, lo + hi + none, calls])

	print("\n=== ④ _pay_salary entry次數(每隊) ===")
	var pay_entry_total: int = int(Probe.counts.get("salary.pay_entry", 0))
	print("salary.pay_entry(全域)=%d" % pay_entry_total)
	if pay_entry_total == 0 and not _has_any_key("salary.byteam."):
		print("★salary.pay_entry/byteam不存在(批前世界無此tap，量不到，非0)")
	else:
		var zero_teams: Array = []
		var entry_counts: Array = []
		for tid in state.teams:
			var k: String = "salary.byteam.%04d" % tid
			var n: int = int(Probe.counts.get(k, 0))
			entry_counts.append(n)
			if n == 0:
				zero_teams.append(tid)
		entry_counts.sort()
		var mode_hint: String = str(entry_counts) if entry_counts.size() < 30 else "(隊數多，見下方分佈)"
		print("per-team entry次數列表=%s" % mode_hint)
		print("★entry=0的隊數=%d（規格要求：沒有一隊是0）%s" % [
			zero_teams.size(), (" ⇒ 命中隊=%s" % str(zero_teams)) if not zero_teams.is_empty() else ""])

	print("\n=== ⑤ 發薪unrest(reason=salary的driver流量，逐發薪日) ===")
	var payday_unrest_keys: Array = []
	for k2 in Probe.amounts.keys():
		if String(k2).begins_with("salary.payday.") and String(k2).ends_with(".unrest"):
			payday_unrest_keys.append(String(k2))
	if payday_unrest_keys.is_empty():
		print("★salary.payday.*.unrest不存在(批前世界無此tap，量不到，非0)")
	else:
		payday_unrest_keys.sort()
		for k3 in payday_unrest_keys:
			print("  %s = %.2f" % [k3, Probe.amounts[k3]])
		var cut_total: int = 0
		for k4 in Probe.counts.keys():
			if String(k4).begins_with("salary.payday.") and String(k4).ends_with(".cut"):
				cut_total += int(Probe.counts[k4])
		print("累計減薪次數(salary.payday.*.cut加總)=%d" % cut_total)

	print("=== batch1_compare_d45_bed DONE ===")

func _has_any_key(prefix: String) -> bool:
	for k in Probe.counts.keys():
		if String(k).begins_with(prefix):
			return true
	return false
