extends SceneTree

func _initialize() -> void:
	_run_sim_test()
	quit()

func _run_sim_test() -> void:
	var state := WorldState.new()
	var runner := SimRunner.new()

	# 建立 0~4 格的 tile（Team0 要走到 (3,0)，需要中間格存在）
	for i in range(5):
		var tile := HexTileData.new()
		var tid: int = i * 1000
		tile.tile_id = tid
		tile.resources = { "food": 200, "wood": 50, "ore": 20, "special": 0 }
		tile.productivity = 1.0
		tile.has_outpost = (i == 0 or i == 2)  # tile 0,2 有據點（Team0/2 起始位置）
		state.world.tiles[tid] = tile

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

		# 移動目標設定
		if t == 0:
			team.move_target  = Vector2i(3, 0)
			team.move_speed   = 1.0
			team.current_task = "掠奪"
			team.resources["weapon"] = 20
		elif t == 1:
			team.move_target = Vector2i(0, 0)  # 向左走到 (0,0)
			team.move_speed = 1.5              # 每 ~7 Tick 走一格
			team.unrest_turns = 22             # Tick 1 觸發替換事件，emit message
		# t == 2: 無目標，駐守

		for p in range(3):
			var person := PersonData.new()
			person.id = t * 3 + p
			person.person_name = "P%d_%d" % [t, p]
			person.role = "leader" if p == 0 else "civilian"
			person.team_id = t
			person.age = 25
			person.loyalty = 0.8
			person.stress = 0.0

			if t == 1 and p > 0:
				person.goals = ["逃離", "求生"]
				person.values["義氣"] = 0.3
				person.skills["統領"] = 0.5
				person.loyalty = 0.2  # 低忠誠度 → 成為異見者，觸發替換事件
			else:
				person.goals = ["擴張", "繁榮"]

			state.persons[person.id] = person
			if p == 0:
				team.leader_id = person.id
			else:
				team.members.append(person.id)

	(state.world.tiles[1000] as HexTileData).resources["food"] = 0

	print("=== Sim Test: 200 Ticks ===")
	print("Team0 目標: (3,0)  speed=1.0  預期每 10 Tick 走一格")
	print("Team1 目標: (0,0)  speed=1.5  預期每 7 Tick 走一格")
	print("Team2 無目標，駐守 (2,0)")
	var player_pos := Vector2i(0, 0)

	for tick in range(200):
		runner.advance_tick(state, player_pos)
		if (tick + 1) % 20 == 0:
			print("\n--- Tick %d ---" % state.world.current_tick)
			for tid in state.teams:
				var t: TeamData = state.teams[tid]
				var known_count: int = state.team_known[tid].size() if state.team_known.has(tid) else 0
				print("  Team%d pos=(%d,%d) food=%.1f pop=%d wnd=%d ct=%d rd=%.2f" % [
					t.team_id,
					t.tile_pos.x, t.tile_pos.y,
					float(t.resources.get("food", 0)),
					t.population,
					t.wounded,
					t.combat_target,
					t.readiness
				])

	print("\nglobal_messages: %d" % state.global_messages.size())
	for tid in state.team_known:
		print("  team_known[%d]: %d 條" % [tid, state.team_known[tid].size()])
	print("=== DONE ===")
