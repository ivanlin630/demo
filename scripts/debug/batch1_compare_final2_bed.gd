extends SceneTree
# batch1_compare_final2_bed：batch1-compare最後兩格——①try_set擋因分布(④票)②JOIN true<belief(③票已否證)
# 零新tap：
#   ①arbiter.deny.*(task_arbiter.gd::try_set，戰鬥鎖/crisis免疫窗/持守擋班/優先序不足四大類+opt細分)
#   ②freshness.firsthand_no_tile_pos(belief_system.gd，③票的反向斷言計數，等式斷掉才非0)
# ★誠實限：try_set沒有「總呼叫次數(含success)」的既有tap，只能報deny側四類的相對分布+deny總數，
#   母體(含成功)量不到，不用總額反推。
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

	print("=== batch1_compare_final2_bed: config=%s days=%d ticks=%d seed=%d ===" % [cfg, days, ticks, seed_val])

	for tick in range(ticks):
		runner.advance_tick(state, no_player)
		if tick % 20000 == 0 and tick > 0:
			print("[CHECKPOINT] tick=%d teams=%d" % [tick, state.teams.size()])

	print("\n=== ① try_set擋因分布(④票) ===")
	var deny_reasons: Array = ["戰鬥鎖", "crisis免疫窗", "持守擋班", "優先序不足"]
	var has_any_arbiter: bool = false
	var deny_total: int = 0
	var deny_by_reason: Dictionary = {}
	for r in deny_reasons:
		var n: int = int(Probe.counts.get("arbiter.deny." + r, 0))
		deny_by_reason[r] = n
		deny_total += n
		if n > 0: has_any_arbiter = true
	if not has_any_arbiter:
		print("★arbiter.deny.*不存在或全0(批前世界無此tap分類，量不到，非0)")
	else:
		print("★母體(含成功)量不到——try_set無總呼叫次數tap，以下只是deny側相對分布")
		print("deny總數=%d" % deny_total)
		for r2 in deny_reasons:
			var n2: int = deny_by_reason[r2]
			var pct: float = (float(n2) / float(deny_total) * 100.0) if deny_total > 0 else 0.0
			print("  %s: %d (%.1f%%)" % [r2, n2, pct])
		# opt細分：持守擋班.opt.*（規格特別點名的是「徵收吃掉幾成引擎路被擋」，持守擋班最相關）
		print("  持守擋班 by opt(哪個option被擋最多，前10)：")
		var opt_counts: Dictionary = {}
		for k in Probe.counts.keys():
			if String(k).begins_with("arbiter.deny.持守擋班.opt."):
				var opt_name: String = String(k).trim_prefix("arbiter.deny.持守擋班.opt.")
				opt_counts[opt_name] = int(Probe.counts[k])
		var opt_sorted: Array = opt_counts.keys()
		opt_sorted.sort_custom(func(a, b): return opt_counts[a] > opt_counts[b])
		for i in range(mini(10, opt_sorted.size())):
			print("    %s: %d" % [opt_sorted[i], opt_counts[opt_sorted[i]]])
		if opt_sorted.is_empty():
			print("    (無opt細分紀錄)")

	print("\n=== ② JOIN true<belief(③票，已否證，看有沒有變) ===")
	var no_tile_pos: int = int(Probe.counts.get("freshness.firsthand_no_tile_pos", 0))
	if not Probe.counts.has("freshness.firsthand_no_tile_pos"):
		print("★key從未出現——可能是①批前世界無此tap(結構性)，也可能是③世界tap存在但90天內從未觸發過(真0)")
		print("  （本床無法純靠key存在與否分辨這兩者，需搭配production code grep或其他母體tap佐證）")
	else:
		print("freshness.firsthand_no_tile_pos=%d（③票已否證，預期恆0；此輪確認有沒有變）" % no_tile_pos)
		if no_tile_pos == 0:
			print("  ★仍是0，跟③票原本否證結論一致，沒有變")
		else:
			print("  ★★非0！跟③票原本否證結論不一致，需要重新檢視")
	var never: int = int(Probe.counts.get("appearance.never", 0))
	var stale: int = int(Probe.counts.get("appearance.stale", 0))
	print("對照(appearance.never/stale，母體活動量參考)：never=%d stale=%d" % [never, stale])

	print("=== batch1_compare_final2_bed DONE ===")
