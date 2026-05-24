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
	var _t0: HexTileData = state.world.tiles[0] as HexTileData
	_t0.outpost_type  = "military"
	_t0.outpost_level = 1
	_t0.outpost_owner = 0                                          # Team0 起始軍事據點（營寨）
	(state.world.tiles[1000] as HexTileData).resources["food"] = 0 # 測試：tile(1,0) 無糧

	for t in range(3):
		var team := TeamData.new()
		team.team_id = t
		team.population = 10
		team.minor_population = 1
		var _mat: int = 100 if t == 2 else 10
		team.resources = {
			"food": 500.0, "material": _mat, "coin": 20, "goods": 0, "gem": 0,
			"ore_gold": 0, "ore_silver": 0, "ore_iron": 0, "ore_steel": 0,
			"weapon_melee_low": 0, "weapon_melee_high": 0,
			"weapon_ranged_low": 0, "weapon_ranged_high": 0,
		}
		team.tags = ["生產"]
		team.tile_pos = Vector2i(t, 0)
		state.teams[t] = team
		state.team_known[t] = []
		state.team_discovered[t] = []

		# 移動目標設定
		if t == 0:
			team.move_speed   = 1.0
			team.current_task = "掠奪"
			team.tags = ["統領"]
			team.resources["weapon_melee_low"] = 40
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

	# Team2 建設測試：在 (2,0) 建造村落（civilian Lv1）
	# Team0 營寨在 (0,0)，距離 2（不同類型，無同類限制）
	var _outpost_sys := OutpostSystem.new()
	var _build_ok := _outpost_sys.start_build(state, state.teams[2], "civilian", 1)
	print("=== 據點建設測試：Team2 建村落 start_build=%s ===" % str(_build_ok))

	# Team3：預先設為 Team0 附庸（測試 faction AI 行為）
	var team3 := TeamData.new()
	team3.team_id = 3
	team3.population = 8
	team3.resources = {
		"food": 200.0, "material": 5, "coin": 30, "goods": 10, "gem": 0,
		"ore_gold": 0, "ore_silver": 0, "ore_iron": 0, "ore_steel": 0,
		"weapon_melee_low": 4, "weapon_melee_high": 0,
		"weapon_ranged_low": 0, "weapon_ranged_high": 0,
	}
	team3.tags = []
	team3.tile_pos = Vector2i(4, 0)
	team3.unrest_turns = 0
	state.teams[3] = team3
	state.team_known[3] = []
	state.team_discovered[3] = []
	var p3 := PersonData.new()
	p3.id = 9
	p3.person_name = "P3_0"
	p3.role = "leader"
	p3.team_id = 3
	p3.age = 30
	p3.loyalty = 0.5
	p3.values["義氣"] = 0.2   # 低義氣 → 容易脫離勢力
	p3.values["信義"] = 0.2   # 低信義 → 叛離觸發更容易
	p3.values["野心"] = 0.3
	state.persons[9] = p3
	team3.leader_id = 9
	# 直接建立 faction（模擬主服結果）
	var init_fid: int = state.create_faction(0)   # Team0 為 leader
	state.factions[init_fid].member_team_ids.append(3)
	team3.faction_id = init_fid
	# 手動補雙向發現（繞過正常外交流程）
	state.team_discovered[0].append(3)
	state.team_discovered[3].append(0)
	# Team0 leader 設高野心（達到立國條件）
	state.persons[0].values["野心"] = 0.8
	state.persons[0].values["好戰"] = 0.8
	state.persons[0].values["義氣"] = 0.2
	state.persons[0].values["貪婪"] = 0.8
	state.persons[0].values["殘忍"] = 0.9   # 高殘忍 → 戰後多掠奪 + 傷兵惡化
	state.persons[0].skills["統領"] = 0.5
	# Team2 食物設低，確保 Team3 始終為最富成員（徵收目標）
	state.teams[2].resources["food"] = 50.0

	# ── 子團驗證場景 ──
	# Team0 有 Person1 作為 advisor，派出偵查子隊
	state.persons[0].skills["統領"] = 0.5
	state.persons[1].skills["統領"] = 0.2   # sub_cap = clamp(round(49×0.25)+1,1,50) = 14
	state.persons[1].skills["偵查"] = 0.4   # 高偵查：子隊視野更廣
	state.persons[1].values["貪婪"] = 0.8   # 高貪婪 → idle 子團有機會觸發 mini-loop（掠奪/攻擊）
	state.persons[1].values["好戰"] = 0.7
	state.persons[1].loyalty       = 0.4    # 低忠誠 → deviation_chance 更高
	state.teams[0].advisors.append(1)        # Person1 加入 Team0 的 advisors
	state.teams[0].members.erase(1)
	# Person2 也移到 advisors（用於驗證多 NPC 派遣）
	state.teams[0].advisors.append(2)
	state.teams[0].members.erase(2)
	# Team5：獨立軍隊（應觸發 SoloAI 攻擊/掠奪）
	var team5 := TeamData.new()
	team5.team_id = 5; team5.population = 8
	team5.resources = {
		"food": 300.0, "material": 5, "coin": 0, "goods": 0, "gem": 0,
		"ore_gold": 0, "ore_silver": 0, "ore_iron": 0, "ore_steel": 0,
		"weapon_melee_low": 16, "weapon_melee_high": 0,
		"weapon_ranged_low": 0, "weapon_ranged_high": 0,
	}
	team5.tags = ["軍隊"]; team5.tile_pos = Vector2i(-3, 0)
	state.teams[5] = team5; state.team_known[5] = []; state.team_discovered[5] = []
	var p5 := PersonData.new()
	p5.id = 10; p5.person_name = "P5_0"; p5.role = "leader"; p5.team_id = 5
	p5.values["好戰"] = 0.8; p5.values["野心"] = 0.7
	p5.skills["潛行"] = 0.5   # 高潛行：軍隊仍能隱蔽
	state.persons[10] = p5; team5.leader_id = 10

	# Team6：獨立商隊（應觸發 SoloAI 外交）
	var team6 := TeamData.new()
	team6.team_id = 6; team6.population = 6
	team6.resources = {
		"food": 200.0, "material": 3, "coin": 50, "goods": 20, "gem": 0,
		"ore_gold": 0, "ore_silver": 0, "ore_iron": 0, "ore_steel": 0,
		"weapon_melee_low": 2, "weapon_melee_high": 0,
		"weapon_ranged_low": 0, "weapon_ranged_high": 0,
	}
	team6.tags = ["商隊"]; team6.tile_pos = Vector2i(-3, 1)
	state.teams[6] = team6; state.team_known[6] = []; state.team_discovered[6] = []
	var p6 := PersonData.new()
	p6.id = 11; p6.person_name = "P6_0"; p6.role = "leader"; p6.team_id = 6
	p6.values["野心"] = 0.6; p6.values["好戰"] = 0.2
	p6.skills["潛行"] = 0.3   # 中等潛行
	state.persons[11] = p6; team6.leader_id = 11

	var _sub_sys := SubteamSystem.new()
	var scout_id: int = _sub_sys.dispatch(state, 0, 1, 3, "偵查", Vector2i(3, 0),
		-1, "", [2])  # Person2 作為 extra advisor
	print("=== 子隊派遣：scout_id=%d ===" % scout_id)
	if scout_id != -1:
		print("  Team0 pop=%d  Team%d pop=%d task=%s" % [
			state.teams[0].population, scout_id,
			state.teams[scout_id].population, state.teams[scout_id].current_task])

	# ── Team8 製造測試 ──
	# Tile (3,1)：civilian Lv2，manufacturing_level=1
	var _tile31_id: int = 3 * 1000 + 1
	if state.world.tiles.has(_tile31_id):
		var _t31: HexTileData = state.world.tiles[_tile31_id] as HexTileData
		_t31.outpost_type         = "civilian"
		_t31.outpost_level        = 2
		_t31.manufacturing_level  = 1
		_t31.outpost_owner        = 8
		_t31.terrain              = "plains"
	var team8 := TeamData.new()
	team8.team_id    = 8
	team8.population = 10
	team8.resources  = {
		"food": 500.0, "material": 500.0, "coin": 0, "goods": 0, "gem": 5,
		"ore_gold": 0, "ore_silver": 100, "ore_iron": 80, "ore_steel": 0,
		"weapon_melee_low": 0, "weapon_melee_high": 0,
		"weapon_ranged_low": 0, "weapon_ranged_high": 0,
	}
	team8.tags         = ["生產"]
	team8.tile_pos     = Vector2i(3, 1)
	team8.current_task = TeamData.TASK_MANUFACTURE
	state.teams[8]     = team8
	state.team_known[8] = []
	state.team_discovered[8] = []
	var p8 := PersonData.new()
	p8.id = 20; p8.person_name = "P8_0"; p8.role = "leader"; p8.team_id = 8
	p8.loyalty = 0.9; p8.skills["製造"] = 0.2
	state.persons[20] = p8
	team8.leader_id = 20
	print("=== 製造測試：Team8 tile(3,1) civilian Lv2, mfg_level=1, gem=5, ore_silver=100 ===")

	# ── Team9 商隊測試 ──
	# Tile (1,1)：plains（world gen 已有）
	var team9 := TeamData.new()
	team9.team_id    = 9
	team9.population = 5
	team9.resources  = {
		"food": 300.0, "material": 0, "coin": 0, "goods": 100.0, "gem": 3,
		"ore_gold": 0, "ore_silver": 0, "ore_iron": 0, "ore_steel": 0,
		"weapon_melee_low": 0, "weapon_melee_high": 0,
		"weapon_ranged_low": 0, "weapon_ranged_high": 0,
	}
	team9.tags       = ["商隊"]
	team9.tile_pos   = Vector2i(1, 1)
	state.teams[9]   = team9
	state.team_known[9] = []
	state.team_discovered[9] = []
	var p9 := PersonData.new()
	p9.id = 21; p9.person_name = "P9_0"; p9.role = "leader"; p9.team_id = 9
	p9.loyalty = 0.9; p9.skills["商業"] = 0.1
	p9.values["貪婪"] = 0.6
	state.persons[21] = p9
	team9.leader_id = 21
	print("=== 商隊測試：Team9 tile(1,1) 商隊，goods=100, gem=3, coin=0 ===")

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

	# Team9 商隊結果
	if state.teams.has(9):
		var t9: TeamData = state.teams[9]
		print("\n=== Team9 商隊結果 ===")
		print("  coin=%.0f  goods=%.1f  gem=%.0f  food=%.0f" % [
			float(t9.resources.get("coin", 0)),
			float(t9.resources.get("goods", 0)),
			float(t9.resources.get("gem", 0)),
			float(t9.resources.get("food", 0))
		])
		print("  Person21 商業=%.4f" % float(state.persons[21].skills.get("商業", 0)))

	# Team8 製造結果
	if state.teams.has(8):
		var t8: TeamData = state.teams[8]
		print("\n=== Team8 製造結果 ===")
		print("  goods=%.2f  melee_low=%.2f  melee_high=%.2f  steel=%.2f  material=%.1f" % [
			float(t8.resources.get("goods", 0)),
			float(t8.resources.get("weapon_melee_low", 0)),
			float(t8.resources.get("weapon_melee_high", 0)),
			float(t8.resources.get("ore_steel", 0)),
			float(t8.resources.get("material", 0))
		])
		print("  Person20 製造技能=%.4f" % float(state.persons[20].skills.get("製造", 0)))

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
	print("--- 視野 ---")
	for tid in state.team_discovered:
		print("  Team%d 已發現: %s" % [tid, str(state.team_discovered[tid])])
	print("--- 裝備統計 ---")
	for tid in state.teams:
		var t: TeamData = state.teams[tid]
		var equip_counts: Dictionary = { "melee_low": 0, "melee_high": 0, "ranged_low": 0, "ranged_high": 0, "none": 0 }
		for pid in ([t.leader_id] as Array) + t.advisors + t.members:
			var p: PersonData = state.persons.get(pid)
			if p == null: continue
			var wt: String = p.equipment.get("weapon", "")
			if wt in equip_counts: equip_counts[wt] += 1
			else: equip_counts["none"] += 1
		print("  Team%d pool_ml=%d mh=%d rl=%d rh=%d | armed_anon=%.2f | named:%s" % [
			tid,
			int(t.resources.get("weapon_melee_low", 0)),
			int(t.resources.get("weapon_melee_high", 0)),
			int(t.resources.get("weapon_ranged_low", 0)),
			int(t.resources.get("weapon_ranged_high", 0)),
			t.armed_anon_ratio,
			str(equip_counts)
		])
	print("--- 戰鬥技能 ---")
	for pid in state.persons:
		var p: PersonData = state.persons.get(pid)
		if p == null: continue
		var bat: float = float(p.skills.get("戰鬥", 0))
		var bow: float = float(p.skills.get("弓箭", 0))
		var tac: float = float(p.skills.get("戰術", 0))
		if bat > 0.001 or bow > 0.001 or tac > 0.001:
			print("  Person%d 戰鬥=%.4f 弓箭=%.4f 戰術=%.4f" % [p.id, bat, bow, tac])
	print("--- 偵查/潛行技能 ---")
	for pid in [1, 10, 11]:
		var _sp: PersonData = state.persons.get(pid)
		if _sp: print("  Person%d 偵查=%.4f 潛行=%.4f" % [
			pid, float(_sp.skills.get("偵查", 0)), float(_sp.skills.get("潛行", 0))])
	print("=== DONE ===")
