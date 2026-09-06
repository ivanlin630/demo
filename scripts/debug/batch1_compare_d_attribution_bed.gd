extends SceneTree
# batch1_compare_d_attribution_bed：D歸因格——那2792次撞下界(過剩側)是哪些res/哪些隊
# ★零新tap，但也非精確重建8771次呼叫的逐次分類（那需要在trade_valuation.gd加per-res tap，
#   跨production scope，本床沒做）——改用periodic snapshot複用TradeValuation同源真值計算
#   （ResourceSystem.effective_holding + TARGET_PER_POP + SURVIVAL_GOODS×6放大，跟local_value()
#   一字不差同一套公式），回答的是【世界任一時刻glut分佈的結構】，非「哪8771次各自是誰」。
#   如實聲明此近似邊界，不假裝精確對應母體8771。
# 四桶：撞下界(shortage<-0.5)/深度過剩(shortage<-1，白送區證據)/撞上界(shortage>hi，構造性恆0)/未撞
# 用法：BED_CONFIG(default res://config/peaceful_economy.json) BED_DAYS(default 90) BED_SEED(default 1337)

const SURVIVAL_GOODS: Array = ["food", "medicine"]

func _initialize() -> void:
	_run(); quit()

func _shortage_for(state: WorldState, team: TeamData, res: String) -> float:
	var stock: float = ResourceSystem.effective_holding(state, team, res)
	var pop: int = team.population
	var target: float = pop * float(TradeValuation.TARGET_PER_POP.get(res, 1.0))
	var shortage: float = (target - stock) / maxf(target, 1.0)
	if res in SURVIVAL_GOODS and shortage > 0.5:
		shortage = 1.0 + (shortage - 0.5) * 6.0
	return shortage

func _run() -> void:
	var days: int = int(OS.get_environment("BED_DAYS")) if OS.has_environment("BED_DAYS") else 90
	var cfg: String = OS.get_environment("BED_CONFIG") if OS.has_environment("BED_CONFIG") else "res://config/peaceful_economy.json"
	var seed_val: int = int(OS.get_environment("BED_SEED")) if OS.has_environment("BED_SEED") else 1337
	seed(seed_val)
	var state: WorldState = MeasureBedHelper.arm_and_setup(cfg, true)
	var runner := SimRunner.new()
	var ticks: int = days * WorldState.TICKS_PER_DAY
	var no_player := Vector2i(-1, -1)

	var acc: Dictionary = {
		"by_res": {}, "by_team": {}, "deep_glut_by_res": {}, "total_samples": 0, "total_lo": 0, "total_deep": 0,
	}
	var res_list: Array = TradeValuation.TARGET_PER_POP.keys()

	print("=== batch1_compare_d_attribution_bed: config=%s days=%d ticks=%d seed=%d ===" % [cfg, days, ticks, seed_val])

	for tick in range(ticks):
		runner.advance_tick(state, no_player)
		if tick % 2000 == 0 and tick > 0:
			for tid in state.teams:
				var t: TeamData = state.teams[tid]
				if t.population <= 0: continue
				for res in res_list:
					var sr: float = _shortage_for(state, t, res)
					acc["total_samples"] = int(acc["total_samples"]) + 1
					if sr < -0.5:
						acc["total_lo"] = int(acc["total_lo"]) + 1
						acc["by_res"][res] = int(acc["by_res"].get(res, 0)) + 1
						acc["by_team"][tid] = int(acc["by_team"].get(tid, 0)) + 1
						if sr < -1.0:
							acc["total_deep"] = int(acc["total_deep"]) + 1
							acc["deep_glut_by_res"][res] = int(acc["deep_glut_by_res"].get(res, 0)) + 1
			print("[CHECKPOINT] tick=%d 累計樣本=%d 累計撞下界=%d" % [tick, int(acc["total_samples"]), int(acc["total_lo"])])

	print("\n=== D歸因結果（periodic snapshot近似，非精確母體8771對帳） ===")
	print("總樣本數=%d 撞下界(過剩)樣本數=%d(%.2f%%)" % [
		int(acc["total_samples"]), int(acc["total_lo"]),
		(float(acc["total_lo"]) / float(acc["total_samples"]) * 100.0) if int(acc["total_samples"]) > 0 else 0.0])

	print("\n①by res（撞下界佔比，food是否過半）：")
	var by_res: Dictionary = acc["by_res"]
	var res_sorted: Array = by_res.keys()
	res_sorted.sort_custom(func(a, b): return by_res[a] > by_res[b])
	for r in res_sorted:
		var pct: float = float(by_res[r]) / maxf(float(acc["total_lo"]), 1.0) * 100.0
		print("  %s: %d次 (%.1f%%)" % [r, by_res[r], pct])
	if not by_res.has("food"):
		print("  ★food完全沒出現在撞下界名單裡")

	print("\n②by team（集中少數 vs 普遍現象）：")
	var by_team: Dictionary = acc["by_team"]
	var team_sorted: Array = by_team.keys()
	team_sorted.sort_custom(func(a, b): return by_team[a] > by_team[b])
	for tid2 in team_sorted:
		print("  team=%d: %d次" % [tid2, by_team[tid2]])
	print("  撞下界事件涉及隊數=%d / 現存隊數=%d" % [team_sorted.size(), state.teams.size()])

	print("\n④深度過剩(shortage<-1，白送區證據)：")
	print("深度過剩總樣本數=%d(%.2f%% of 撞下界)" % [
		int(acc["total_deep"]),
		(float(acc["total_deep"]) / float(acc["total_lo"]) * 100.0) if int(acc["total_lo"]) > 0 else 0.0])
	var deep_by_res: Dictionary = acc["deep_glut_by_res"]
	var deep_sorted: Array = deep_by_res.keys()
	deep_sorted.sort_custom(func(a, b): return deep_by_res[a] > deep_by_res[b])
	for r2 in deep_sorted:
		print("  %s: %d次" % [r2, deep_by_res[r2]])

	print("\n③情境：本床未實作(需per-隊在撞界當下的task/糧倉狀態，如實聲明未做，非漏做)")
	print("=== batch1_compare_d_attribution_bed DONE ===")
