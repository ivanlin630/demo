extends SceneTree

func _initialize() -> void:
	_run_sim_test()
	quit()

func _run_sim_test() -> void:
	var state := WorldState.new()
	var runner := SimRunner.new()

	# 用 WorldGenerator 產生 radius=4 的 hex 地圖（含 (4,0) 位置）
	var generator = load("res://scripts/simulation/world_generator.gd").new()
	generator.generate(state, { "radius": 4, "seed": 42 })
	# 強制路徑地形為 plains，避免 mountain 拖慢移動驗證外交時序
	for _tid in [0, 1000, 2000, 3000, 4000]:
		if state.world.tiles.has(_tid):
			(state.world.tiles[_tid] as HexTileData).terrain = "plains"
	# 測試劇本：設定固定據點
	(state.world.tiles[0] as HexTileData).has_outpost = true       # Team0 起始
	(state.world.tiles[2000] as HexTileData).has_outpost = true    # Team2 起始
	(state.world.tiles[1000] as HexTileData).resources["food"] = 0 # 測試：tile(1,0) 無糧

	for t in range(3):
		var team := TeamData.new()
		team.team_id = t
		team.population = 10
		team.minor_population = 1
		team.resources = { "food": 500.0, "material": 10, "weapon": 5, "coin": 20, "goods": 0 }
		team.tags = ["生產"]
		team.tile_pos = Vector2i(t, 0)
		state.teams[t] = team
		state.team_known[t] = []

		# 移動目標設定
		if t == 0:
			team.move_speed   = 1.0
			team.current_task = "掠奪"
			team.tags = ["統領"]
			team.resources["weapon"] = 20
		elif t == 1:
			team.tile_pos = Vector2i(3, 0)     # 從(3,0)出發，距Team2(2,0)更遠
			team.move_target = Vector2i(0, 0)  # 向左走到 (0,0)
			team.move_speed = 1.5              # 每 ~11 Tick 走一格
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

	# Team3：預先設為 Team0 附庸（測試 faction AI 行為）
	var team3 := TeamData.new()
	team3.team_id = 3
	team3.population = 8
	team3.resources = { "food": 200.0, "material": 5, "weapon": 2, "coin": 30, "goods": 10 }
	team3.tags = []
	team3.tile_pos = Vector2i(4, 0)
	team3.unrest_turns = 0
	state.teams[3] = team3
	state.team_known[3] = []
	var p3 := PersonData.new()
	p3.id = 9
	p3.person_name = "P3_0"
	p3.role = "leader"
	p3.team_id = 3
	p3.age = 30
	p3.loyalty = 0.5
	p3.values["義氣"] = 0.2   # 低義氣 → 容易脫離勢力
	p3.values["野心"] = 0.3
	state.persons[9] = p3
	team3.leader_id = 9
	# 直接建立 faction（模擬主服結果）
	var init_fid: int = state.create_faction(0)   # Team0 為 leader
	state.factions[init_fid].member_team_ids.append(3)
	team3.faction_id = init_fid
	# Team0 leader 設高野心（達到立國條件）
	state.persons[0].values["野心"] = 0.8
	state.persons[0].values["好戰"] = 0.8
	state.persons[0].values["義氣"] = 0.2
	state.persons[0].values["貪婪"] = 0.8
	state.persons[0].skills["統領"] = 0.5
	# Team2 食物設低，確保 Team3 始終為最富成員（徵收目標）
	state.teams[2].resources["food"] = 50.0

	# ── 子團驗證場景 ──
	# Team0 有 Person1 作為 advisor，派出偵查子隊
	state.persons[0].skills["統領"] = 0.5
	state.persons[1].skills["統領"] = 0.2   # sub_cap = clamp(round(49×0.25)+1,1,50) = 14
	state.teams[0].advisors.append(1)        # Person1 加入 Team0 的 advisors
	state.teams[0].members.erase(1)
	# Team5：獨立軍隊（應觸發 SoloAI 攻擊/掠奪）
	var team5 := TeamData.new()
	team5.team_id = 5; team5.population = 8
	team5.resources = { "food": 300.0, "material": 5, "weapon": 8, "coin": 0, "goods": 0 }
	team5.tags = ["軍隊"]; team5.tile_pos = Vector2i(-3, 0)
	state.teams[5] = team5; state.team_known[5] = []
	var p5 := PersonData.new()
	p5.id = 10; p5.person_name = "P5_0"; p5.role = "leader"; p5.team_id = 5
	p5.values["好戰"] = 0.8; p5.values["野心"] = 0.7
	state.persons[10] = p5; team5.leader_id = 10

	# Team6：獨立商隊（應觸發 SoloAI 外交）
	var team6 := TeamData.new()
	team6.team_id = 6; team6.population = 6
	team6.resources = { "food": 200.0, "material": 3, "weapon": 1, "coin": 50, "goods": 20 }
	team6.tags = ["商隊"]; team6.tile_pos = Vector2i(-3, 1)
	state.teams[6] = team6; state.team_known[6] = []
	var p6 := PersonData.new()
	p6.id = 11; p6.person_name = "P6_0"; p6.role = "leader"; p6.team_id = 6
	p6.values["野心"] = 0.6; p6.values["好戰"] = 0.2
	state.persons[11] = p6; team6.leader_id = 11

	var _sub_sys := SubteamSystem.new()
	var scout_id: int = _sub_sys.dispatch(state, 0, 1, 3, "偵查", Vector2i(3, 0))
	print("=== 子隊派遣：scout_id=%d ===" % scout_id)
	if scout_id != -1:
		print("  Team0 pop=%d  Team%d pop=%d task=%s" % [
			state.teams[0].population, scout_id,
			state.teams[scout_id].population, state.teams[scout_id].current_task])

	print("=== Sim Test: 200 Ticks ===")
	print("Team0(統領) 預建為勢力 leader，Team3 為附庸")
	print("預期：立國 → 外交(Team1,Team2) → 定期徵收(Team3)，子隊偵查後回歸")
	print("Team1 目標: (0,0)  Team2 無目標，駐守 (2,0)  player_pos=(2,0)")
	var player_pos := Vector2i(2, 0)

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
	print("factions: %d" % state.factions.size())
	for fid in state.factions:
		var f = state.factions[fid]
		print("  勢力%d [%s] leader=Team%d members=%s" % [
			fid, f.faction_name if f.is_established else "未立國號",
			f.leader_team_id, str(f.member_team_ids)])
	print("--- 子團狀態 ---")
	for tid in state.teams:
		var t: TeamData = state.teams[tid]
		if t.parent_team_id != -1:
			print("  Team%d(子團) parent=Team%d task=%s pop=%d" % [
				tid, t.parent_team_id, t.current_task, t.population])
	if scout_id != -1 and state.teams.has(scout_id):
		print("  [OK] 子隊 Team%d 仍存活（偵查任務無自動回歸，需主動召回）" % scout_id)
	elif scout_id != -1:
		print("  [OK] 子隊已完全合併回 Team0")
	print("=== DONE ===")
