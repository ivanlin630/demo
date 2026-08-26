extends SceneTree

# ★★★S2 重寫：凍的從【tick 數】改成【時長】。
#   ★舊版寫死 `INDEP_STRATEGY_CADENCE == 720`，而 720 是【舊根下的 tick 數】
#     ⇒ 每重錨一次就要改一次這份檔 ⇒ ★★它凍的不是意圖，是【当時的實作】。
#   ★★★改凍【小時】：根旋鈕怎麼變，「備戰評估每 3 天一次」這件事都不該變。
#     ⇒ 重錨後本檔【一行都不用改】，而它仍然抳得住。
#
# ★★★★另加 LOCKED §1 明令的【下限守衛】：遭遇動作 tick 數 >= 10。
#   ★理由：動作粒度是【速度差檔位的解析度地板】—— < 10 tick 就分不出快慢。
#   ★★它是【日後】的守衛：有人把根旋鈕調小時，這條先紅。

func _initialize() -> void:
	var fails: int = 0
	var tph: int = WorldState.TICKS_PER_HOUR
	print("[time-const] 根旋鈕 TICKS_PER_HOUR = %d（1 tick = %.2f 分鐘）" % [tph, 60.0 / float(tph)])

	# ── ①下限守衛（LOCKED §1）──
	var act: int = EncounterSystem.BASE_ACTION_TICKS
	if act < 10:
		print("[FAIL] 遭遇動作 = %d tick < 10 ⇒ 速度差檔位失去解析度（根旋鈕 %d 太小，需 >= 60）" % [act, tph])
		fails += 1
	else:
		print("[OK] 遭遇動作 = %d tick = %d 分鐘（>= 10 tick 地板）" % [act, act * 60 / tph])

	# ── ①b 【根值凍結哨兵】（systems 裁定 2026-08-27）──
	#   ★這是【該手抄的那個數字】—— 其他地方一律禁手抄根值，而這一格的內容
	#     就是「根變了就要紅」。舊本該職責在 headless 的 `ticks_per_day == 240`，
	#     而我把那條降級成【接線檢查】（== WorldState.TICKS_PER_DAY）⇒ 【失去覆蓋】。
	#   ★★紅了要怎麼辦：【確認這次改根是有意的，然後更新這一格】——
	#     ★★★不是【拿掉這一格】。根旋鈕日後可再改（LOCKED §1），
	#     所以它【本來就會】在未來某天紅一次 —— 而那正是它存在的目的。
	const ROOT_FROZEN: int = 60   # ★S2 重錨後的根值
	if tph != ROOT_FROZEN:
		print("[FAIL] ★根旋鈕變了：TICKS_PER_HOUR = %d，本檔凍的是 %d" % [tph, ROOT_FROZEN])
		print("       ⇒ 若這是【有意的】：更新本檔 ROOT_FROZEN＋重跑統計等價床；★不要直接刪這條。")
		fails += 1
	else:
		print("[OK] 根旋鈕 = %d（值凍結哨兵）" % tph)

	# ── ②時長凍結（★單位是【小時】，不是 tick）──
	var checks := [
		["INDEP_STRATEGY_CADENCE", FactionAISystem.INDEP_STRATEGY_CADENCE, 72],
		["FLEE_TIMEOUT", FactionAISystem.FLEE_TIMEOUT, 120],
		["PROSPERITY_CADENCE", FactionAISystem.PROSPERITY_CADENCE, 72],
		["PROSPERITY_CADENCE_MILITARY", FactionAISystem.PROSPERITY_CADENCE_MILITARY, 36],
		["THREAT_CADENCE", FactionAISystem.THREAT_CADENCE, 24],
		["TRADE_TIMEOUT", FactionAISystem.TRADE_TIMEOUT, 144],
		["TRADE_TIMEOUT_PER_HEX", FactionAISystem.TRADE_TIMEOUT_PER_HEX, 12],
		["RESIDENCY_CADENCE", FactionAISystem.RESIDENCY_CADENCE, 72],
		["RESIDENCY_COOLDOWN", FactionAISystem.RESIDENCY_COOLDOWN, 168],
		["OCCUPY_ETA_MAX", FactionAISystem.OCCUPY_ETA_MAX, 72],
	]
	for c in checks:
		var name_s: String = c[0]; var got_ticks: int = c[1]; var want_h: int = c[2]
		var got_h: float = float(got_ticks) / float(tph)
		if absf(got_h - float(want_h)) > 0.001:
			print("[FAIL] %s = %.2f 小時 (%d tick), want %d 小時" % [name_s, got_h, got_ticks, want_h]); fails += 1
		else:
			print("[OK] %s = %d 小時 (%d tick)" % [name_s, want_h, got_ticks])

	# ── ③intended-change（★不是不變項，是【故意改】，分開列避免混進凍結區）──
	var coll_h: float = float(FactionAISystem.COLLECT_INTERVAL) / float(tph)
	if absf(coll_h - 24.0) > 0.001:
		print("[FAIL] COLLECT_INTERVAL = %.2f 小時, S2 intended = 24 小時（T2 一天）" % coll_h); fails += 1
	else:
		print("[OK] COLLECT_INTERVAL = 24 小時（S2 intended：30h → T2 1 天）")

	# ── ④錨①：世界格移動 = 動作 × 格數（無係數）──
	var move_h: float = float(TimeScale.MOVE_TICKS_PER_HEX) / float(tph)
	if absf(move_h - 4.0) > 0.001:
		print("[FAIL] 世界格移動 = %.2f 小時, S2 intended = 4 小時" % move_h); fails += 1
	else:
		print("[OK] 世界格移動 = 4 小時（S2 intended：4.8h → 4h）")

	print("=== time_const_check: %s (fails=%d) ===" % ["PASS" if fails == 0 else "FAIL", fails])
	quit()
