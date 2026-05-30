extends SceneTree

var _errors: int = 0

func _initialize() -> void:
	_test_constants()
	_test_setup_sanity()
	_test_vision_threshold()
	print("\n=== UI Logic Test DONE === errors: %d" % _errors)
	quit()

func _check(label: String, ok: bool) -> void:
	if ok:
		print("  PASS: %s" % label)
	else:
		print("  FAIL: %s" % label)
		_errors += 1

# ── Task 1: Simulation 常數 ──────────────────────────────────────────────────

func _test_constants() -> void:
	print("\n── Task1. Simulation 常數 ──")
	_check("SALARY_INTERVAL >= 720", SalarySystem.SALARY_INTERVAL >= 720)
	_check("SEASON_LENGTH >= 240", HarvestSystem.SEASON_LENGTH >= 240)
	print("  ℹ salary_system.gd SALARY_INTERVAL = %d" % SalarySystem.SALARY_INTERVAL)
	print("  ℹ harvest_system.gd SEASON_LENGTH  = %d" % HarvestSystem.SEASON_LENGTH)

# ── Task 2: Test Setup ────────────────────────────────────────────────────────

func _test_setup_sanity() -> void:
	print("\n── Task2. Test Setup ──")
	const FOOD_START := 5000.0
	const POP := 10
	const TICKS_PER_DAY := 24.0
	var days: float = FOOD_START / (float(POP) * 0.1 * TICKS_PER_DAY)
	_check("初始食物撐 > 30 天 (%.1f天)" % days, days > 30.0)
	var cap: int = TeamData.pop_cap_from_leadership(0.5)
	_check("統領=0.5 → cap=%d > 10 → 不分裂" % cap, cap > 10)

# ── Task 3: 視野門檻 + 移動邊界 ──────────────────────────────────────────────

func _test_vision_threshold() -> void:
	print("\n── Task3. 視野門檻 + 移動邊界 ──")
	var state := WorldState.new()
	var gen = load("res://scripts/simulation/world_generator.gd").new()
	gen.generate(state, {"radius": 4, "seed": 42})
	for t in range(3):
		var team := TeamData.new()
		team.team_id = t; team.population = 10
		team.tile_pos = Vector2i(t, 0)
		team.resources = {
			"food": 5000.0, "material": 10, "coin": 200, "goods": 0, "gem": 0,
			"ore_gold": 0, "ore_silver": 0, "ore_iron": 0, "ore_steel": 0,
			"weapon_melee_low": 0, "weapon_melee_high": 0,
			"weapon_ranged_low": 0, "weapon_ranged_high": 0,
			"mounts": 0, "wagons": 0, "arrows": 0,
			"medicine": 0, "tools": 0, "armor_low": 0, "armor_high": 0,
		}
		state.teams[t] = team
		state.team_known[t] = []; state.team_discovered[t] = []
		for p in range(2):
			var person := PersonData.new()
			person.id = t * 2 + p; person.person_name = "P%d_%d" % [t, p]
			person.role = "leader" if p == 0 else "civilian"
			person.team_id = t; person.age = 25; person.loyalty = 0.9
			person.skills["統領"] = 0.5
			state.persons[person.id] = person
			if p == 0: team.leader_id = person.id
			else: team.named_members.append(person.id)
	PlayerSystem.new().init_player(state, 0, 0)
	var vis := VisionSystem.new()
	vis.tick_discovery(state, [0, 1, 2])
	var disc0: Array = state.team_discovered.get(0, [])
	_check("team0 看到 team1（dist=1）", disc0.has(1))
	_check("team0 看到 team2（dist=2）", disc0.has(2))
	var out := Vector2i(10, 10)
	_check("(10,10) 不在地圖（邊界驗證依據）",
		not state.world.tiles.has(out.x * 1000 + out.y))
