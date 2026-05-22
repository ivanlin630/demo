extends SceneTree

func _initialize() -> void:
	_run_sim_test()
	quit()

func _run_sim_test() -> void:
	var state := WorldState.new()
	var runner := SimRunner.new()

	for i in range(3):
		var tile := HexTileData.new()
		var tid: int = i * 1000
		tile.tile_id = tid
		tile.resources = { "food": 200, "wood": 50, "ore": 20, "special": 0 }
		tile.productivity = 1.0
		tile.has_outpost = true
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

		for p in range(3):
			var person := PersonData.new()
			person.id = t * 3 + p
			person.person_name = "P%d_%d" % [t, p]
			person.role = "leader" if p == 0 else "civilian"
			person.team_id = t
			person.age = 25
			person.loyalty = 0.8
			person.stress = 0.0

			if t == 0 and p == 0:
				# 高野心領袖：期望在 10 Tick 後自動生成「建立勢力」目標
				person.values["野心"] = 0.9
				person.attributes["魅力"] = 0.8
				person.goals = ["擴張"]
			elif t == 0 and p == 1:
				# 高智力文職：生產技能成長比其他人快
				person.values["慎重"] = 0.7
				person.attributes["智力"] = 0.9
				person.goals = ["繁榮"]
			elif t == 1 and p == 0:
				person.goals = ["擴張", "繁榮"]
			elif t == 1 and p == 1:
				# 高求生欲 + 衝突目標 + 低義氣 → 飢餓時逃跑，義氣<0.4 會觸發分裂
				person.goals = ["逃離", "求生"]
				person.values["求生欲"] = 0.8
				person.values["義氣"] = 0.3
				person.skills["統領"] = 0.5
			elif t == 1 and p == 2:
				# 高義氣 + 衝突目標 → 義氣>=0.4 不觸發分裂，驗證義氣抑制效果
				person.goals = ["逃離", "求生"]
				person.values["義氣"] = 0.8
				person.values["求生欲"] = 0.3
			elif t == 2:
				# 高貪婪 → 期望自動生成「發財」目標
				person.values["貪婪"] = 0.8
				person.goals = ["發財", "擴張"]
			else:
				person.goals = ["擴張", "繁榮"]

			state.persons[person.id] = person
			if p == 0:
				team.leader_id = person.id
			else:
				team.members.append(person.id)

	(state.world.tiles[1000] as HexTileData).resources["food"] = 0

	print("=== Sim Test: 200 Ticks ===")
	var player_pos := Vector2i(0, 0)

	for tick in range(200):
		runner.advance_tick(state, player_pos)
		if (tick + 1) % 20 == 0:
			print("\n--- Tick %d ---" % state.world.current_tick)
			for tid in state.teams:
				var t: TeamData = state.teams[tid]
				print("  Team%d food=%.1f pop=%d unrest=%d" % [
					t.team_id, float(t.resources.get("food", 0)), t.population, t.unrest_turns
				])
			# 技能成長快照：P0_1(高智力), P1_0(Team1領袖), P1_1(高求生欲)
			for check_id in [1, 3, 4]:
				if state.persons.has(check_id):
					var p: PersonData = state.persons[check_id]
					print("  Person%d(%s) 生產=%.3f 統領=%.3f 求生=%.3f 計謀=%.3f | goals=%s" % [
						p.id, p.person_name,
						float(p.skills.get("生產", 0)), float(p.skills.get("統領", 0)),
						float(p.skills.get("求生", 0)), float(p.skills.get("計謀", 0)),
						str(p.goals)
					])

	print("\nglobal_messages: %d" % state.global_messages.size())
	print("=== DONE ===")
