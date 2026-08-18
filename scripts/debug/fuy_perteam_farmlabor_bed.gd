extends SceneTree

# L3 temp measurement-only bed（measurer、用完即刪，非 production）。
# ticket:docs/superpowers/handbacks/2026-08-18-systems-to-measurer-FUY-perteam-farmlabor.md
# 消歧 farm labor 21%飽和是 team-size emergence(guns-vs-butter 大團養得起farm)還是結構墊底
# (gather:food demand小恆先cap、farm demand=level×K_FARM大恆填不滿)。
# per-team farm labor_mult 飽和度 vs pop/farming_level。同 seed/config/months 比照原 FUY 輪。

const WORLD_SEED: int = 1337

func _initialize() -> void:
	var months: int = int(OS.get_environment("LW_MONTHS")) if OS.has_environment("LW_MONTHS") else 6
	var total_ticks: int = months * WorldState.TICKS_PER_MONTH
	print("=== fuy_perteam_farmlabor_bed(seed=%d %d月 ticks=%d) ===" % [WORLD_SEED, months, total_ticks])

	seed(WORLD_SEED)
	Probe.enabled = true
	Probe.reset()
	var state := WorldState.new()
	var runner := SimRunner.new()
	GameSetup.setup(state, GameSetup.load_config("res://config/peaceful_economy.json"))
	state.player_id = -1

	var no_player := Vector2i(-1, -1)
	for tick in range(total_ticks):
		runner.advance_tick(state, no_player)
		if state.teams.is_empty():
			print("[EXTINCT] tick=%d" % tick)
			break

	print("\n───── per-team farm labor 飽和度 vs pop/farming_level ─────")
	var team_ids: Array = []
	for k in Probe.counts.keys():
		if k.begins_with("diag.pt_flabor_n."):
			team_ids.append(int(k.substr("diag.pt_flabor_n.".length())))
	team_ids.sort()
	print("  team_id | pop(終態) | farming_level | flabor_avg | n_samples")
	for tid in team_ids:
		var sum_f: float = Probe.amount("diag.pt_flabor_sum." + str(tid))
		var n: int = int(Probe.counts.get("diag.pt_flabor_n." + str(tid), 0))
		var avg_f: float = sum_f / maxf(float(n), 1.0)
		var pop: float = float(Probe.peaks.get("diag.pt_pop." + str(tid), -1.0))
		var lvl: float = float(Probe.peaks.get("diag.pt_level." + str(tid), -1.0))
		print("  team%d | pop=%.0f | level=%.0f | flabor_avg=%.3f | n=%d" % [tid, pop, lvl, avg_f, n])

	print("\n=== fuy_perteam_farmlabor_bed DONE ===")
	Probe.enabled = false
	quit()
