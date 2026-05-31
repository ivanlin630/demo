extends SceneTree

func _initialize() -> void:
	var state := WorldState.new()
	var gen = load("res://scripts/simulation/world_generator.gd").new()
	gen.generate(state, { "radius": 4, "seed": 42 })

	# 建玩家 team 在中心
	var team := TeamData.new()
	team.team_id = 0
	team.population = 10
	team.tile_pos = Vector2i(4, 4)
	team.tags = ["統領"]
	team.resources = { "food": 500.0, "material": 50.0, "coin": 50,
		"goods": 0, "gem": 0, "ore_gold": 0, "ore_silver": 0, "ore_iron": 0,
		"ore_steel": 0, "weapon_melee_low": 5, "weapon_melee_high": 0,
		"weapon_ranged_low": 0, "weapon_ranged_high": 0, "mounts": 0, "wagons": 0,
		"arrows": 0, "medicine": 0, "tools": 0, "armor_low": 0, "armor_high": 0 }
	state.teams[0] = team
	state.team_known[0] = []
	state.team_discovered[0] = []

	# 建另一個 team 讓玩家發現（tile 7,5）
	var team2 := TeamData.new()
	team2.team_id = 1
	team2.population = 8
	team2.tile_pos = Vector2i(7, 5)
	state.teams[1] = team2
	state.team_discovered[0].append(1)

	var leader := PersonData.new()
	leader.id = 0; leader.person_name = "玩家"; leader.role = "leader"
	leader.team_id = 0; leader.loyalty = 1.0
	state.persons[0] = leader
	team.leader_id = 0
	state.player_id = 0

	var cursor := Vector2i(6, 4)
	var map_str := TextMapRenderer.render(state, 0, cursor)
	print("=== MAP RENDER (cursor at 6,4) ===")
	print(map_str)
	print("=== END MAP ===")
	print("length=%d" % map_str.length())

	# 驗證：radius=4 → ymin=0, ymax=8 → 9 rows × 2 sub-lines = 18 lines
	var lines_arr := map_str.split("\n")
	assert(lines_arr.size() == 18, "地圖應有 18 行，實際: %d" % lines_arr.size())
	# 玩家在 (4,4) = display_row 4 = 第 9 行（index 8），even sub-line
	var center_line: String = lines_arr[8]
	assert(center_line.contains("@"), "中間行應含 '@'，實際: '%s'" % center_line)
	print("=== ASSERTIONS PASSED ===")
	quit()
