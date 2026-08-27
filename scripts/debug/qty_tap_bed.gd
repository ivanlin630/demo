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
	# ★【移動格/日】是七項裡唯一沒有 production tap 的 —— 而它不需要：
	#   位置是世界狀態，床自己逐 tick 比對就量得到，不必為了量測去改 production。
	var prev_pos: Dictionary = {}
	var hex_moves: int = 0
	var team_tick_samples: int = 0
	for tid0 in state.teams:
		prev_pos[tid0] = (state.teams[tid0] as TeamData).tile_pos
	for _t in range(ticks):
		runner.advance_tick(state, Vector2i(-1, -1))
		for tid in state.teams:
			var tm: TeamData = state.teams[tid]
			team_tick_samples += 1
			if prev_pos.has(tid) and prev_pos[tid] != tm.tile_pos:
				hex_moves += 1
			prev_pos[tid] = tm.tile_pos

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
── 其餘五項不變項/遊戲日（★均帶分母）──")
	# ★key 可能帶 .day.NNN / .team.N 後綴 ⇒ 【用前綴加總】，不可讀裸 key。
	#   血證：讀裸 key 永遠是 0，而那看起來跟【事情沒發生】一模一樣。
	var tap_hex: float = Probe.amount("qty.move_hex")
	var tap_n: int = int(Probe.counts.get("qty.move_n", 0))
	print("  移動格(tap)   %.2f/日  ｜分母(移動事件次數)=%d" % [tap_hex / dayf, tap_n])
	print("  移動格(床側) %.2f/日  ｜分母(team×tick 樣本)=%d" % [float(hex_moves) / dayf, team_tick_samples])
	if tap_n > 0 and hex_moves != int(tap_hex):
		# ★兩個獨立數字不合 ＝ 訊號，不是噪音：
		#   床側逐 tick 比位置會把 spawn/合併的位置跡象算成移動，tap 不會。
		print("  ★兩者差 %d 步 ⇒ 差額極可能是 spawn/合併造成的位置跡象（tap 為準）" % (hex_moves - int(tap_hex)))
	var rows: Array = [
		["決策次數", "unified.rank.calls"],
		["製造產出", "manufacture.fired"],
		["訊息發出", "msg.sent"],
		["訊息送達", "msg.delivered"],
		["餓死(named)", "death.starve_named_hunger"],
		["餓死(minor)", "death.starve_minor"],
		["餓死(anon)", "death.starve_anon"],
		["擮合嘗試(buy)", "mkfill.attempt.buy"],
		["擮合嘗試(sell)", "mkfill.attempt.sell"],
	]
	for row in rows:
		var total: int = 0
		var nkeys: int = 0
		for kk in Probe.counts:
			var kss: String = String(kk)
			if kss == String(row[1]) or kss.begins_with(String(row[1]) + "."):
				total += int(Probe.counts[kk]); nkeys += 1
		if nkeys == 0:
			# ★★這裡的語意跟 qty.* 【相反】，別搞混：
			#   qty.* 是我這輪新掛的 ⇒ PROBE_OFF 對照證明「key 不存在＝儀器沒開」。
		#   ★而這幾顆是【既有的 production tap】，Probe 現在是 ON
		#     ⇒ key 不存在只能是【這件事從未發生】，不是「沒有儀器」。
			print("  %-14s ★key 不存在，而 Probe 是 ON ⇒ 【這件事從未發生】（tap 在，只是沒 fire）" % row[0])
		else:
			print("  %-14s %.2f/日  ｜總數=%d（累加了 %d 條 key）" % [row[0], float(total) / dayf, total, nkeys])
	# ── ★傳播節律（S3 前置）：單位是【每遊戲小時】，不是每 tick ──
	#   ★因為要回答的問題是「它是不是 1 小時心跳」—— 比 per-tick 永遠看不出來。
	var hours: float = float(ticks) / float(WorldState.TICKS_PER_HOUR)
	var p_call: int = int(Probe.counts.get("prop.call", 0))
	var p_arr: int = int(Probe.counts.get("prop.arrivals", 0))
	var p_pair: int = int(Probe.counts.get("prop.colocated_pair", 0))
	print("
── 傳播節律/遊戲小時（★S3 前置）──")
	if p_call == 0:
		print("  ★prop.* key 不存在或為 0（Probe 是 ON）⇒ 【這件事從未發生】")
	else:
		print("  呼叫次數      %.2f/小時  ｜總 %d（★若掛每 tick ⇒ 此值應 = TICKS_PER_HOUR = %d）"
			% [float(p_call) / hours, p_call, WorldState.TICKS_PER_HOUR])
		print("  arrival 事件  %.2f/小時  ｜總 %d（分母）" % [float(p_arr) / hours, p_arr])
		print("  同格對數      %.2f/小時  ｜總 %d（真的有機會交換的）" % [float(p_pair) / hours, p_pair])
	print("
── 原始總量（★先看未除以天數的值，別讓 %.2f 把小數字吐成 0）──")
	for k9 in Probe.amounts:
		if String(k9).begins_with("qty."):
			print("  %-34s = %.6f" % [String(k9), float(Probe.amounts[k9])])
	print("=== qty_tap_bed DONE ===")
	quit()
