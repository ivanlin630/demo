extends SceneTree
# batch1_compare_c1c2_bed：batch1-compare規格C-1(設施升級真發生次數)+C-2(大團vs小隊人均產出比)
# C-1零新tap：既有 upg.eval_entry(per-day per-team)+ infra.stop.1_upgrade + 直讀state.world.tiles算有據點的隊
# C-2零新tap：team.food_produce_avg已是per-team EWMA，直接周期snapshot按population分級距
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

	# C-2：級距分桶樣本（population分級距：1-5/6-15/16-30/31+，可調）
	var tier_samples: Dictionary = {}   # tier_label -> Array[per-person food_produce_avg]

	print("=== batch1_compare_c1c2_bed: config=%s days=%d ticks=%d seed=%d ===" % [cfg, days, ticks, seed_val])

	for tick in range(ticks):
		runner.advance_tick(state, no_player)
		if tick % 2000 == 0 and tick > 0:
			for tid in state.teams:
				var t: TeamData = state.teams[tid]
				if t.population <= 0: continue
				var tier: String = ""
				if t.population <= 5: tier = "1-5"
				elif t.population <= 15: tier = "6-15"
				elif t.population <= 30: tier = "16-30"
				else: tier = "31+"
				if not tier_samples.has(tier):
					tier_samples[tier] = []
				(tier_samples[tier] as Array).append(t.food_produce_avg / float(t.population))
			print("[CHECKPOINT] tick=%d teams=%d" % [tick, state.teams.size()])

	print("\n=== C-1 設施升級真發生次數 ===")
	var has_outpost_teams: Dictionary = {}   # 分母②：有據點的隊
	for tile_id in state.world.tiles:
		var tile: HexTileData = state.world.tiles[tile_id]
		if tile.outpost_level > 0 and tile.outpost_owner != -1:
			has_outpost_teams[tile.outpost_owner] = true
	print("分母②有據點的隊數=%d" % has_outpost_teams.size())
	var eval_entry_total: int = 0
	for k in Probe.counts.keys():
		if String(k).begins_with("upg.eval_entry.day."):
			eval_entry_total += int(Probe.counts[k])
	print("分母①本函式(升級評估)被走到總次數(跨全部team*day累計)=%d" % eval_entry_total)
	print("③真的發生(evaluate_upgrade成功dispatch)=%d" % int(Probe.counts.get("infra.stop.1_upgrade", 0)))
	if has_outpost_teams.size() == 0:
		print("★母體=0（沒有隊有據點）⇒ 本格【不可判】不是0")
	elif eval_entry_total == 0:
		print("★分母①=0 ⇒ 升級評估這一步【path根本沒被走到】，不是「沒人想升級」")

	print("\n=== C-2 大團vs小隊人均產出比 ===")
	for tier2 in ["1-5", "6-15", "16-30", "31+"]:
		if not tier_samples.has(tier2):
			print("級距=%s ★該級距沒有隊出現過樣本 ⇒ 【不可判】不是0" % tier2)
			continue
		var arr: Array = tier_samples[tier2]
		var sum: float = 0.0
		for v in arr: sum += v
		print("級距=%s 樣本數=%d 人均產出平均=%.4f" % [tier2, arr.size(), sum / arr.size()])

	print("=== batch1_compare_c1c2_bed DONE ===")
