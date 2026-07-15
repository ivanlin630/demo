extends SceneTree

# supply_wall_bed：生產arc供給牆首測——sell_no_surplus 51.7%根查。
# 3疑：①非糧surplus存不存在(逐隊逐res effective_holding-reserve) ②manufacture產能/是否選中 ③reserve gate高低。
# 純觀測：只讀TradeValuation/ResourceSystem唯讀calc,不寫state,主線真實advance_tick跑。
# 用法：SW_SEED（default 1337）SW_MONTHS（default 6）

const NON_FOOD_RES: Array = [
	"material", "goods", "gem", "ore_gold", "ore_silver", "ore_iron", "ore_steel",
	"weapon_melee_low", "weapon_melee_high", "weapon_ranged_low", "weapon_ranged_high",
	"tools", "arrows", "armor_low", "armor_high", "horses", "mounts", "wagons", "herb",
]

func _initialize() -> void:
	_run(); quit()

var _manufacture_prints: int = 0

func _run() -> void:
	var world_seed: int = int(OS.get_environment("SW_SEED")) if OS.has_environment("SW_SEED") else 1337
	var months: int = int(OS.get_environment("SW_MONTHS")) if OS.has_environment("SW_MONTHS") else 6
	var total_ticks: int = months * WorldState.TICKS_PER_MONTH
	print("=== supply_wall_bed: seed=%d months=%d ===" % [world_seed, months])
	seed(world_seed)
	SimRunner.force_full_hd = true
	Probe.enabled = true
	Probe.reset()
	var state := WorldState.new()
	var runner := SimRunner.new()
	var config: Dictionary = GameSetup.load_config("res://config/default.json")
	config["seed"] = world_seed
	GameSetup.setup(state, config)
	var no_player := Vector2i(-1, -1)
	for tick in range(total_ticks):
		runner.advance_tick(state, no_player)
		if (tick + 1) % WorldState.TICKS_PER_MONTH == 0:
			_print_month(state, (tick + 1) / WorldState.TICKS_PER_MONTH)
		if state.teams.is_empty():
			break
	print("[SW-final] yield.works_tile_pass=%d" % int(Probe.counts.get("yield.works_tile_pass", 0)))
	SimRunner.force_full_hd = false
	Probe.enabled = false
	print("=== DONE ===")

func _print_month(state: WorldState, month: int) -> void:
	# ①surplus 存在性：逐隊逐非糧res算 effective_holding - reserve
	var teams_with_any_surplus: int = 0
	var surplus_by_res: Dictionary = {}   # res -> 累加正surplus
	var teams_total: int = 0
	var manufacture_task_n: int = 0
	var can_manufacture_n: int = 0
	var material_ge_min_n: int = 0
	var has_facility_n: int = 0
	var reserve_sample: Array = []
	for tid in state.teams:
		var t: TeamData = state.teams[tid]
		teams_total += 1
		var any_pos: bool = false
		for res in NON_FOOD_RES:
			var holding: float = ResourceSystem.effective_holding(state, t, res)
			var lv: Dictionary = TradeValuation.leader_vals(state, t)
			var rsv: float = TradeValuation.reserve(t, res, lv, state)
			var surplus: float = holding - rsv
			if surplus > 0.0:
				any_pos = true
				surplus_by_res[res] = float(surplus_by_res.get(res, 0.0)) + surplus
			if reserve_sample.size() < 8 and (res == "material" or res == "goods"):
				reserve_sample.append({"team": tid, "res": res, "holding": holding, "reserve": rsv, "surplus": surplus})
		if any_pos:
			teams_with_any_surplus += 1
		if t.current_task == TeamData.TASK_MANUFACTURE:
			manufacture_task_n += 1
		# ②manufacture 產能 gate 逐項
		var tile_id: int = t.tile_pos.x * 1000 + t.tile_pos.y
		var tile: HexTileData = state.world.tiles.get(tile_id)
		var has_facility: bool = false
		if tile != null and tile.outpost_level > 0:
			for level_key in ManufacturingSystem.RECIPE_GROUPS:
				if int(tile.get(level_key)) > 0:
					has_facility = true
					break
		if has_facility:
			has_facility_n += 1
		if float(t.resources.get("material", 0)) >= FactionAISystem.MANUFACTURE_MATERIAL_MIN:
			material_ge_min_n += 1
		# _can_manufacture 私法但無真state寫,唯讀call安全
		if FactionAISystem.new()._can_manufacture(state, t):
			can_manufacture_n += 1
	print("[月%d ①surplus] teams=%d 有正surplus隊數=%d(%.1f%%) surplus總量by_res(前5大)=%s" % [
		month, teams_total, teams_with_any_surplus,
		100.0 * float(teams_with_any_surplus) / maxf(float(teams_total), 1.0),
		str(_top5(surplus_by_res))])
	print("[月%d ②manufacture] TASK_MANUFACTURE中隊數=%d(%.1f%%) has_facility隊數=%d material>=%d隊數=%d _can_manufacture通過隊數=%d（實際[Manufacture]執行次數見log grep）" % [
		month, manufacture_task_n, 100.0 * float(manufacture_task_n) / maxf(float(teams_total), 1.0),
		has_facility_n, int(FactionAISystem.MANUFACTURE_MATERIAL_MIN), material_ge_min_n, can_manufacture_n])
	print("[月%d ③reserve樣本(material/goods前8)] %s" % [month, str(reserve_sample)])

func _top5(d: Dictionary) -> Dictionary:
	var keys: Array = d.keys()
	keys.sort_custom(func(a, b): return float(d[a]) > float(d[b]))
	var out: Dictionary = {}
	for i in range(mini(5, keys.size())):
		out[keys[i]] = d[keys[i]]
	return out
