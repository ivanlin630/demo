extends SceneTree

# 驗：faction_ai 的時間常數導出後值等於原硬編值（現根 240）。零行為變閘。
func _initialize() -> void:
	var fails: int = 0
	var checks := [
		["INDEP_STRATEGY_CADENCE", FactionAISystem.INDEP_STRATEGY_CADENCE, 720],
		["FLEE_TIMEOUT", FactionAISystem.FLEE_TIMEOUT, 1200],
		["PROSPERITY_CADENCE", FactionAISystem.PROSPERITY_CADENCE, 720],
		["PROSPERITY_CADENCE_MILITARY", FactionAISystem.PROSPERITY_CADENCE_MILITARY, 360],
		["THREAT_CADENCE", FactionAISystem.THREAT_CADENCE, 240],
		["TRADE_TIMEOUT", FactionAISystem.TRADE_TIMEOUT, 1440],
		["TRADE_TIMEOUT_PER_HEX", FactionAISystem.TRADE_TIMEOUT_PER_HEX, 120],
		["RESIDENCY_CADENCE", FactionAISystem.RESIDENCY_CADENCE, 720],
		["RESIDENCY_COOLDOWN", FactionAISystem.RESIDENCY_COOLDOWN, 1680],
		["OCCUPY_ETA_MAX", FactionAISystem.OCCUPY_ETA_MAX, 720],
	]
	for c in checks:
		var name_s: String = c[0]; var got: int = c[1]; var want: int = c[2]
		if got != want:
			print("[FAIL] %s = %d, want %d" % [name_s, got, want]); fails += 1
		else:
			print("[OK] %s = %d" % [name_s, got])
	print("=== time_const_check: %s (fails=%d) ===" % ["PASS" if fails == 0 else "FAIL", fails])
	quit()
