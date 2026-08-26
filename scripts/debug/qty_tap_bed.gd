extends SceneTree

# ★★★S2 前置：quantity tap 的量測床（純觀測）。
#   ★它回答的是【量】不是【次數】，且每一項都帶【分母】——
#     沒有分母的量跟沒有分母的率一樣不可信。
#   ★★單位是【每遊戲日】不是每 tick —— S2 會改變 tick 的定義，
#     比 per-tick 就是自欺（同一件事的 per-tick 值會因為 tick 變小而自動變小）。
#
# 用法：BED_CONFIG=warring_states BED_DAYS=30 [PROBE_OFF=1] godot --script …
#   ★PROBE_OFF=1 ＝陽性對照：【key 不存在】而不是【值為 0】。
#     兩者差別是真的：前者證明儀器沒開，後者可能是【事情沒發生】。

func _initialize() -> void:
	var days: int = int(OS.get_environment("BED_DAYS")) if OS.has_environment("BED_DAYS") else 30
	var cfg: String = OS.get_environment("BED_CONFIG") if OS.has_environment("BED_CONFIG") else "warring_states"
	var probe_off: bool = OS.has_environment("PROBE_OFF")
	seed(1337)
	var state := WorldState.new()
	GameSetup.setup(state, GameSetup.load_config("res://config/%s.json" % cfg))
	Probe.reset()
	Probe.enabled = not probe_off
	var ticks: int = days * WorldState.TICKS_PER_DAY
	var runner := SimRunner.new()
	for _t in range(ticks):
		runner.advance_tick(state, Vector2i(-1, -1))

	print("=== qty_tap_bed === config=%s days=%d ticks=%d TICKS_PER_DAY=%d probe=%s"
		% [cfg, days, ticks, WorldState.TICKS_PER_DAY, "OFF" if probe_off else "ON"])
	print("母體：結束時隊數=%d｜結束時人口(named)=%d" % [state.teams.size(), state.persons.size()])

	if probe_off:
		# ★陽性對照：要的是【key 不存在】
		var leaked: Array = []
		for k in Probe.amounts:
			if String(k).begins_with("qty."): leaked.append(String(k))
		for k2 in Probe.counts:
			if String(k2).begins_with("qty."): leaked.append(String(k2))
		if leaked.is_empty():
			print("[OK] PROBE_OFF：qty.* key 【完全不存在】(0 條) ⇒ tap 真的受 Probe.enabled 閘住")
		else:
			print("[FAIL] PROBE_OFF 卻有 %d 條 qty.* key：%s" % [leaked.size(), str(leaked.slice(0, 8))])
		print("=== qty_tap_bed DONE ===")
		quit(); return

	var dayf: float = float(days)
	print("
── 採集量/遊戲日（★taken=從池子取出｜credited=真的入帳，差額=倉滿溢出 sink）──")
	var res_keys: Array = []
	for k3 in Probe.amounts:
		var ks: String = String(k3)
		if ks.begins_with("qty.harvest_taken."):
			res_keys.append(ks.substr("qty.harvest_taken.".length()))
	res_keys.sort()
	if res_keys.is_empty():
		print("  (無任何採集入帳 —— ★這是【事情沒發生】，不是儀器沒開；儀器沒開時 key 不存在，見 PROBE_OFF 對照)")
	for r in res_keys:
		var tk: float = Probe.amount("qty.harvest_taken." + r)
		var cr: float = Probe.amount("qty.harvest_credited." + r)
		var n: int = int(Probe.counts.get("qty.harvest_n." + r, 0))
		print("  %-10s taken=%.2f/日  credited=%.2f/日  溢出=%.2f/日  ｜分母(入帳次數)=%d（%.1f 次/日）"
			% [r, tk / dayf, cr / dayf, (tk - cr) / dayf, n, float(n) / dayf])

	print("
── 消耗量/遊戲日（★實扣非應扣）──")
	var c_keys: Array = []
	for k4 in Probe.amounts:
		var ks2: String = String(k4)
		if ks2.begins_with("qty.consume."):
			c_keys.append(ks2.substr("qty.consume.".length()))
	c_keys.sort()
	if c_keys.is_empty():
		print("  (無任何消耗 —— 同上：這是【事情沒發生】)")
	for r2 in c_keys:
		var amt: float = Probe.amount("qty.consume." + r2)
		var n2: int = int(Probe.counts.get("qty.consume_n." + r2, 0))
		print("  %-10s %.2f/日  ｜分母(扣款次數)=%d（%.1f 次/日）" % [r2, amt / dayf, n2, float(n2) / dayf])

	print("
── 原始總量（★先看未除以天數的值，別讓 %.2f 把小數字吐成 0）──")
	for k9 in Probe.amounts:
		if String(k9).begins_with("qty."):
			print("  %-34s = %.6f" % [String(k9), float(Probe.amounts[k9])])
	print("=== qty_tap_bed DONE ===")
	quit()
