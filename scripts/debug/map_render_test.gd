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

	# 驗證：radius=4 → y 0..8 → 9 行（每 y 一行；axial 累進切變投影 U16）
	var lines_arr := map_str.split("\n")
	assert(lines_arr.size() == 9, "地圖應有 9 行，實際: %d" % lines_arr.size())
	# @ 在 y=4（player (4,4)）→ 第 5 行（index 4）
	var center_line: String = lines_arr[4]
	assert(center_line.contains("@"), "@ 應在第 5 行，實際: '%s'" % center_line)
	# U16 回歸：axial 累進切變（indent=q+r/2）下，各列前導空白序列須對稱（V 形，
	# 中心 @ 列最短），= 視野圈正確繞 @。舊奇偶交替 stagger 會破壞對稱（非回文）。
	var lead: Array = []
	for ln in lines_arr:
		lead.append(ln.length() - ln.lstrip(" ").length())
	var n: int = lead.size()
	for i in range(n):
		assert(lead[i] == lead[n - 1 - i],
			"前導空白應對稱（U16 axial 投影），實際 lead=%s" % str(lead))
	print("=== ASSERTIONS PASSED === lead=%s" % str(lead))
	quit()
