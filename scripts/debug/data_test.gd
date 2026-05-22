extends Node

func _ready() -> void:
	_run_sim_test()

func _run_sim_test() -> void:
	var state := WorldState.new()
	var runner := SimRunner.new()

	# 建 3 個 Tile（含據點）
	for i in range(3):
		var tile := HexTileData.new()
		tile.tile_id = i
		tile.resources = { "food": 200, "wood": 50, "ore": 20, "special": 0 }
		tile.productivity = 1.0
		tile.has_outpost = true
		state.world.tiles[i] = tile

	# 建 3 個 Team，每個 Team 3 個 Person
	for t in range(3):
		var team := TeamData.new()
		team.team_id = t
		team.population = 10
		team.minor_population = 1
		team.resources = { "food": 5.0, "material": 10, "weapon": 5, "money": 20, "goods": 0 }
		team.tags = ["生產"]
		team.tile_pos = Vector2i(t, 0)
		state.teams[t] = team
		state.team_known[t] = []

		for p in range(3):
			var person := PersonData.new()
			person.id = t * 3 + p
			person.person_name = "P%d_%d" % [t, p]
			person.role = "leader" if p == 0 else "civilian"
			person.team_id = t
			person.age = 25
			person.loyalty = 0.8
			person.stress = 0.0
			state.persons[person.id] = person
			if p == 0:
				team.leader_id = person.id
			else:
				team.members.append(person.id)

	# Team 0 的 Tile 有食物，Team 1 的沒有（測試壓力）
	(state.world.tiles[1] as HexTileData).resources["food"] = 0

	print("=== Simulation Test: 100 Ticks ===")
	var player_pos := Vector2i(0, 0)

	for tick in range(100):
		runner.advance_tick(state, player_pos)

		# 每 10 Tick 印一次摘要
		if (tick + 1) % 10 == 0:
			print("\n--- Tick %d Summary ---" % state.world.current_tick)
			for tid in state.teams:
				var t: TeamData = state.teams[tid]
				print("  Team %d | food=%.1f | pop=%d | unrest=%d" % [
					t.team_id,
					t.resources.get("food", 0),
					t.population,
					t.unrest_turns
				])
			for pid in state.persons:
				var p: PersonData = state.persons[pid]
				print("  Person %d [team %d] stress=%.2f loyalty=%.2f memory=%d" % [
					p.id, p.team_id, p.stress, p.loyalty, p.memory.size()
				])

	print("\n=== global_messages count: %d ===" % state.global_messages.size())
	print("=== Test COMPLETE ===")
