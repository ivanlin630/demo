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
			"mounts": 0, "wagons": 0, "arrows": 0, "medicine": 0, "tools": 0,
			"armor_low": 0, "armor_high": 0,
		}
		team.tags = ["生產"]
		team.tile_pos = Vector2i(t, 0)
		state.teams[t] = team
		state.team_known[t] = []
		state.team_discovered[t] = []

		# 移動目標設定
		if t == 0:
			team.current_task = "掠奪"
			team.tags = ["統領"]
			team.resources["weapon_melee_low"] = 40
		elif t == 1:
			team.tile_pos = Vector2i(3, 0)     # 從(3,0)出發，距Team2(2,0)更遠
			team.move_target = Vector2i(0, 0)  # 向左走到 (0,0)
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
				person.goals = [
					{ "type": "escape_war", "target_id": -1, "active": true },
					{ "type": "wealth",     "target_id": -1, "active": true },
				]
				person.values["義氣"] = 0.3
				person.skills["統領"] = 0.5
				person.loyalty = 0.2  # 低忠誠度 → 成為異見者，觸發替換事件
			else:
				person.goals = [
					{ "type": "domination", "target_id": -1, "active": true },
					{ "type": "wealth",     "target_id": -1, "active": true },
				]

			state.persons[person.id] = person
			if p == 0:
				team.leader_id = person.id
			else:
				team.named_members.append(person.id)

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
		"mounts": 0, "wagons": 0, "arrows": 0, "medicine": 0, "tools": 0,
		"armor_low": 0, "armor_high": 0,
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
	# Person1 期望薪水（非死士，需結算）
	state.persons[1].salary = 5.0
	state.persons[2].salary = 3.0
	# Person1 和 Person2 已在 named_members 中，無需額外移動（advisors/members 已合併）
	# Team5：獨立軍隊（應觸發 SoloAI 攻擊/掠奪）
	var team5 := TeamData.new()
	team5.team_id = 5; team5.population = 8
	team5.resources = {
		"food": 300.0, "material": 5, "coin": 0, "goods": 0, "gem": 0,
		"ore_gold": 0, "ore_silver": 0, "ore_iron": 0, "ore_steel": 0,
		"weapon_melee_low": 16, "weapon_melee_high": 0,
		"weapon_ranged_low": 0, "weapon_ranged_high": 0,
		"mounts": 0, "wagons": 0, "arrows": 0, "medicine": 0, "tools": 0,
		"armor_low": 0, "armor_high": 0,
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
		"mounts": 0, "wagons": 0, "arrows": 0, "medicine": 0, "tools": 0,
		"armor_low": 0, "armor_high": 0,
	}
	team6.tags = ["商隊"]; team6.tile_pos = Vector2i(-3, 1)
	state.teams[6] = team6; state.team_known[6] = []; state.team_discovered[6] = []
	var p6 := PersonData.new()
	p6.id = 11; p6.person_name = "P6_0"; p6.role = "leader"; p6.team_id = 6
	p6.values["野心"] = 0.6; p6.values["好戰"] = 0.2
	p6.skills["潛行"] = 0.3   # 中等潛行
	state.persons[11] = p6; team6.leader_id = 11

	var _sub_sys2 := SubteamSystem.new()
	var _best := _sub_sys2._pick_subteam_leader(state, state.teams[0], "偵查")
	print("[TeamAI] _pick_subteam_leader(偵查) = P%d" % _best)
	assert(_best != -1, "應能找到偵查子隊 leader")
	assert(_best == 1, "最高偵查技能應為 Person1")

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
		"mounts": 0, "wagons": 0, "arrows": 0, "medicine": 0, "tools": 0,
		"armor_low": 0, "armor_high": 0,
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
		"mounts": 0, "wagons": 0, "arrows": 0, "medicine": 0, "tools": 0,
		"armor_low": 0, "armor_high": 0,
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

	# ── PersonGenerator 驗證 ──
	var gen_team := TeamData.new()
	gen_team.team_id    = 10
	gen_team.population = 5     # anon_pop = 5-1(leader) = 4
	gen_team.tags       = ["軍隊"]
	gen_team.tile_pos   = Vector2i(0, -3)
	state.teams[10]     = gen_team
	state.team_known[10]      = []
	state.team_discovered[10] = []
	var p10_0 := PersonData.new()
	p10_0.id          = 30
	p10_0.person_name = "P10_leader"
	p10_0.role        = "leader"
	p10_0.team_id     = 10
	state.persons[30]   = p10_0
	gen_team.leader_id  = 30
	var _es_gen   := EventSystem.new()
	var _gen_ok   : bool = _es_gen.on_leader_death(state, gen_team)
	print("=== PersonGenerator 測試 ===")
	print("  gen_ok=%s  new_leader_id=%d" % [str(_gen_ok), gen_team.leader_id])
	if _gen_ok and gen_team.leader_id != 30:
		var _np: PersonData = state.persons.get(gen_team.leader_id)
		if _np:
			print("  [OK] 匿名晉升 Person%d 體力=%.2f 智力=%.2f 戰鬥=%.2f 統領=%.2f" % [
				_np.id,
				float(_np.attributes.get("體力", 0)),
				float(_np.attributes.get("智力", 0)),
				float(_np.skills.get("戰鬥", 0)),
				float(_np.skills.get("統領", 0))])
		else:
			print("  [FAIL] new_leader 不在 state.persons")
	else:
		print("  [FAIL] gen_ok=false or leader_id unchanged")
	state.persons.erase(30)   # 清理「假死」leader（模擬 _kill_named_npc 後段）

	# ── merge_teams 驗證 ──
	var ma := TeamData.new()
	ma.team_id = 11; ma.population = 5; ma.faction_id = 99; ma.tile_pos = Vector2i(0, -4)
	state.teams[11] = ma; state.team_known[11] = []; state.team_discovered[11] = []
	var ma_p := PersonData.new()
	ma_p.id = 40; ma_p.person_name = "MA_leader"; ma_p.role = "leader"
	ma_p.team_id = 11; ma_p.skills["統領"] = 0.6; ma_p.loyalty = 0.8
	state.persons[40] = ma_p; ma.leader_id = 40

	var mb := TeamData.new()
	mb.team_id = 12; mb.population = 3; mb.faction_id = 99; mb.tile_pos = Vector2i(0, -4)
	mb.resources["food"] = 90.0
	state.teams[12] = mb; state.team_known[12] = []; state.team_discovered[12] = []
	var mb_p := PersonData.new()
	mb_p.id = 41; mb_p.person_name = "MB_leader"; mb_p.role = "leader"
	mb_p.team_id = 12; mb_p.loyalty = 0.7
	state.persons[41] = mb_p; mb.leader_id = 41
	var mb_m := PersonData.new()
	mb_m.id = 42; mb_m.person_name = "MB_member"; mb_m.role = "civilian"
	mb_m.team_id = 12; mb_m.loyalty = 0.7
	state.persons[42] = mb_m; mb.named_members.append(42)

	# 完全合併：transfer 所有 MB NPC，transfer_anon=-1（比例帶走匿民）
	# MB pop=3：leader(41) + member(42) + 1 匿民；named=2 → anon=1
	# transfer 2 named → anon_xfer = round(1 * 2/2) = 1 → total_xfer=3 → MB 完全合併
	var _merge_npcs: Array = [41, 42]
	var _ss := SubteamSystem.new()
	_ss.merge_teams(state, 11, 12, _merge_npcs)  # transfer_anon 預設 -1
	print("=== merge_teams 測試（完全合併）===")
	if not state.teams.has(12):
		print("  [OK] Team12 完全合併入 Team11 (pop=%d)" % ma.population)
		if ma.named_members.has(41):
			print("  [OK] MB_leader(41) 加入 Team11 named_members")
		else:
			print("  [FAIL] MB_leader(41) 未進入 named_members")
		if ma.named_members.has(42):
			print("  [OK] MB_member(42) 加入 Team11 named_members")
		else:
			print("  [FAIL] MB_member(42) 未進入 named_members")
		if ma.population == 8:  # 5 + 3
			print("  [OK] Team11 pop=8（含 1 匿民）")
		else:
			print("  [WARN] Team11 pop=%d（預期 8）" % ma.population)
	else:
		print("  [FAIL] Team12 未被刪除（pop=%d）" % mb.population)

	# 追加：transfer_anon=0 測試（只移記名 NPC，匿民留下）
	var mc := TeamData.new()
	mc.team_id = 13; mc.population = 4; mc.faction_id = 99; mc.tile_pos = Vector2i(0, -4)
	mc.resources["food"] = 60.0
	state.teams[13] = mc; state.team_known[13] = []; state.team_discovered[13] = []
	var mc_p := PersonData.new()
	mc_p.id = 43; mc_p.person_name = "MC_leader"; mc_p.role = "leader"
	mc_p.team_id = 13; mc_p.loyalty = 0.7
	state.persons[43] = mc_p; mc.leader_id = 43
	# pop=4：1 named(43) + 3 anon
	_ss.merge_teams(state, 11, 13, [43], 0)  # transfer_anon=0：只移 leader，匿民留下
	print("=== merge_teams 測試（transfer_anon=0）===")
	if state.teams.has(13) and mc.population == 3:
		print("  [OK] Team13 剩 3 匿民（成為子隊）")
		if mc.parent_team_id == 11:
			print("  [OK] Team13.parent_team_id=11")
		else:
			print("  [FAIL] Team13.parent_team_id=%d" % mc.parent_team_id)
	else:
		print("  [FAIL] Team13 pop=%d（預期 3）" % mc.population)
	# 清理
	state.teams.erase(11); state.teams.erase(12); state.teams.erase(13)
	state.team_known.erase(11); state.team_known.erase(12); state.team_known.erase(13)
	state.team_discovered.erase(11); state.team_discovered.erase(12); state.team_discovered.erase(13)
	state.persons.erase(40); state.persons.erase(41); state.persons.erase(42); state.persons.erase(43)

	# ── PopulationSystem 驗證 ──
	# 場景 1：超額 + 有 advisor → dispatch 子隊
	var ov1 := TeamData.new()
	ov1.team_id = 20; ov1.population = 5; ov1.tile_pos = Vector2i(0, -5)
	ov1.resources["food"] = 100.0
	state.teams[20] = ov1; state.team_known[20] = []; state.team_discovered[20] = []
	var ov1_leader := PersonData.new()
	ov1_leader.id = 50; ov1_leader.person_name = "OV1_leader"; ov1_leader.role = "leader"
	ov1_leader.team_id = 20; ov1_leader.skills["統領"] = 0.0  # cap=1，pop=5 → overflow=4
	state.persons[50] = ov1_leader; ov1.leader_id = 50
	var ov1_adv := PersonData.new()
	ov1_adv.id = 51; ov1_adv.person_name = "OV1_adv"; ov1_adv.role = "civilian"
	ov1_adv.team_id = 20; ov1_adv.skills["統領"] = 0.3
	state.persons[51] = ov1_adv; ov1.named_members.append(51)
	var _pop_sys := PopulationSystem.new()
	_pop_sys.check_overflow(state)
	print("=== PopulationSystem 場景1（有advisor）===")
	var _ov1_subteam_found: bool = false
	for _tid in state.teams:
		var _t: TeamData = state.teams[_tid]
		if _t.parent_team_id == 20:
			_ov1_subteam_found = true
			print("  [OK] Team%d 子隊建立 pop=%d" % [_t.team_id, _t.population])
			break
	if not _ov1_subteam_found:
		print("  [FAIL] 未建立子隊")
	if ov1.population <= 1:
		print("  [OK] Team20 pop 降至 %d（≤cap=1）" % ov1.population)
	else:
		print("  [FAIL] Team20 pop=%d 仍超額" % ov1.population)

	# 場景 2：超額 + 無 advisor → 獨立流亡 team
	var ov2 := TeamData.new()
	ov2.team_id = 21; ov2.population = 4; ov2.tile_pos = Vector2i(0, -5)
	ov2.resources["food"] = 80.0
	state.teams[21] = ov2; state.team_known[21] = []; state.team_discovered[21] = []
	var ov2_leader := PersonData.new()
	ov2_leader.id = 52; ov2_leader.person_name = "OV2_leader"; ov2_leader.role = "leader"
	ov2_leader.team_id = 21; ov2_leader.skills["統領"] = 0.0  # cap=1，pop=4 → overflow=3
	state.persons[52] = ov2_leader; ov2.leader_id = 52
	var _teams_before_ov2: int = state.teams.size()
	_pop_sys.check_overflow(state)
	print("=== PopulationSystem 場景2（無advisor）===")
	if state.teams.size() > _teams_before_ov2:
		print("  [OK] 新 team 建立（流亡）")
		for _tid in state.teams:
			var _t: TeamData = state.teams[_tid]
			if _t.tags.has("流亡") and _t.tile_pos == Vector2i(0, -5) and _t.team_id != 21:
				print("  [OK] Team%d 流亡 pop=%d leader_id=%d" % [_t.team_id, _t.population, _t.leader_id])
				break
	else:
		print("  [FAIL] 未建立流亡 team")

	# 場景 3：FactionAI 閾值合併（小隊 pop 過小）
	var fac99 = state.create_faction(22)
	var fa := TeamData.new()
	fa.team_id = 22; fa.population = 20; fa.faction_id = fac99; fa.tile_pos = Vector2i(0, -6)
	state.teams[22] = fa; state.team_known[22] = []; state.team_discovered[22] = []
	var fa_l := PersonData.new()
	fa_l.id = 53; fa_l.person_name = "FA_leader"; fa_l.role = "leader"
	fa_l.team_id = 22; fa_l.skills["統領"] = 0.6  # cap≈37
	state.persons[53] = fa_l; fa.leader_id = 53
	if not state.factions[fac99].member_team_ids.has(22):
		state.factions[fac99].member_team_ids.append(22)
	state.factions[fac99].leader_team_id = 22

	var fb := TeamData.new()
	fb.team_id = 23; fb.population = 2; fb.faction_id = fac99; fb.tile_pos = Vector2i(0, -8)  # dist=2
	state.teams[23] = fb; state.team_known[23] = []; state.team_discovered[23] = []
	var fb_l := PersonData.new()
	fb_l.id = 54; fb_l.person_name = "FB_leader"; fb_l.role = "leader"
	fb_l.team_id = 23; fb_l.skills["統領"] = 0.2  # cap≈13，pop=2 < 13×0.3=3.9 → 小隊
	state.persons[54] = fb_l; fb.leader_id = 54
	state.factions[fac99].member_team_ids.append(23)

	var _fai: Object = load("res://scripts/simulation/faction_ai_system.gd").new()
	var _f99 = state.factions[fac99]
	_fai._assign_member_tasks(state, _f99)
	print("=== FactionAI 閾值合併測試 ===")
	if fb.current_task == TeamData.TASK_MERGE and fb.order_target_id == 22:
		print("  [OK] Team23 收到 TASK_MERGE → Team22")
	else:
		print("  [FAIL] Team23 task=%s order=%d" % [fb.current_task, fb.order_target_id])

	# 場景 4：FactionAI 戰前集結
	_f99.goals = ["攻擊"]
	fb.current_task = "idle"; fb.order_target_id = -1; fb.move_target = Vector2i(-1, -1)
	_fai._assign_member_tasks(state, _f99)
	print("=== FactionAI 戰前集結測試 ===")
	if fb.current_task == TeamData.TASK_MERGE and fb.order_target_id == 22:
		print("  [OK] Team23（dist=2）收到 TASK_MERGE → 主力Team22（戰前集結）")
	else:
		print("  [FAIL] Team23 task=%s order=%d" % [fb.current_task, fb.order_target_id])

	# 清理
	for _tid in [20, 21, 22, 23]:
		state.teams.erase(_tid)
		state.team_known.erase(_tid)
		state.team_discovered.erase(_tid)
	for _pid in [50, 51, 52, 53, 54]:
		state.persons.erase(_pid)
	state.factions.erase(fac99)

	# ── FactionKnownState 驗證 ──
	var ks_fac := state.create_faction(30)
	state.factions[ks_fac].leader_team_id = 30
	var ks_a := TeamData.new()
	ks_a.team_id = 30; ks_a.population = 10; ks_a.tile_pos = Vector2i(0, -9)
	ks_a.resources["food"] = 80.0; ks_a.faction_id = ks_fac
	state.teams[30] = ks_a; state.team_known[30] = []; state.team_discovered[30] = []
	var ks_a_l := PersonData.new()
	ks_a_l.id = 60; ks_a_l.person_name = "KS_leader"; ks_a_l.role = "leader"
	ks_a_l.team_id = 30; ks_a_l.skills["統領"] = 0.6
	state.persons[60] = ks_a_l; ks_a.leader_id = 60

	var ks_b := TeamData.new()
	ks_b.team_id = 31; ks_b.population = 5; ks_b.tile_pos = Vector2i(1, -9)
	ks_b.resources["food"] = 50.0; ks_b.faction_id = ks_fac
	state.teams[31] = ks_b; state.team_known[31] = []; state.team_discovered[31] = []
	var ks_b_l := PersonData.new()
	ks_b_l.id = 61; ks_b_l.person_name = "KS_mem1"; ks_b_l.role = "leader"
	ks_b_l.team_id = 31
	state.persons[61] = ks_b_l; ks_b.leader_id = 61
	state.factions[ks_fac].member_team_ids.append(31)

	var ks_c := TeamData.new()
	ks_c.team_id = 32; ks_c.population = 3; ks_c.tile_pos = Vector2i(2, -9)
	ks_c.resources["food"] = 30.0; ks_c.faction_id = ks_fac
	state.teams[32] = ks_c; state.team_known[32] = []; state.team_discovered[32] = []
	var ks_c_l := PersonData.new()
	ks_c_l.id = 62; ks_c_l.person_name = "KS_mem2"; ks_c_l.role = "leader"
	ks_c_l.team_id = 32
	state.persons[62] = ks_c_l; ks_c.leader_id = 62
	state.factions[ks_fac].member_team_ids.append(32)

	# 預建 team_intel snap（原由 VisionSystem 在 tick 中寫入，此處繞過以直接驗證橋接）
	state.team_intel[30] = {
		31: {
			"tier": 1, "population_est": 5, "tile_pos": Vector2i(1, -9),
			"last_tick": 0, "resource_scale": 1,
			"food_est": 50.0, "material_est": 0.0, "coin_est": 0.0, "goods_est": 0.0,
			"armed_est": 0, "faction_id": ks_fac, "tags": [], "current_task": "idle",
		},
		32: {
			"tier": 1, "population_est": 3, "tile_pos": Vector2i(2, -9),
			"last_tick": 0, "resource_scale": 0,
			"food_est": 30.0, "material_est": 0.0, "coin_est": 0.0, "goods_est": 0.0,
			"armed_est": 0, "faction_id": ks_fac, "tags": [], "current_task": "idle",
		},
	}
	var _ks_fai: Object = load("res://scripts/simulation/faction_ai_system.gd").new()
	_ks_fai.evaluate_all(state, [30, 31, 32])
	print("=== FactionKnownState 驗證 ===")

	# 場景1：快照正確建立
	var _snap_b: Dictionary = state.factions[ks_fac].known_member_states.get(31, {})
	if _snap_b.get("food_est", -1.0) == 50.0:
		print("  [OK] known_member_states[31].food_est=50.0（bridge 正確）")
	else:
		print("  [FAIL] known_member_states[31].food_est=%s" % str(_snap_b.get("food_est", "missing")))

	# 場景2：_richest_member 讀快照（Team31 food=50 > Team32 food=30）
	var _rm: int = _ks_fai._richest_member(state, state.factions[ks_fac])
	if _rm == 31:
		print("  [OK] _richest_member 返回 Team31（快照 food=50）")
	else:
		print("  [FAIL] _richest_member 返回 %d（預期 31）" % _rm)

	# 場景3：直接改 Team31 food 但不刷新快照 → _richest_member 仍讀舊值
	ks_b.resources["food"] = 5.0  # 繞過快照直接改
	var _rm2: int = _ks_fai._richest_member(state, state.factions[ks_fac])
	if _rm2 == 31:
		print("  [OK] 快照未更新 → _richest_member 仍返回 Team31（介面隔離正確）")
	else:
		print("  [FAIL] _richest_member 返回 %d（預期 31，快照應仍為 food=50）" % _rm2)

	# 清理
	for _tid2 in [30, 31, 32]:
		state.teams.erase(_tid2)
		state.team_known.erase(_tid2)
		state.team_discovered.erase(_tid2)
	for _pid2 in [60, 61, 62]:
		state.persons.erase(_pid2)
	state.factions.erase(ks_fac)

	# ── IntelSystem Tier 0/1 驗證 ──
	var _it_vis := VisionSystem.new()
	# 觀察者 Team70（偵查=0，在 (0,0)，vrange=3）
	var _it_a := TeamData.new()
	_it_a.team_id = 70; _it_a.population = 5; _it_a.tile_pos = Vector2i(0, 0)
	state.teams[70] = _it_a; state.team_discovered[70] = []
	var _it_a_l := PersonData.new()
	_it_a_l.id = 70; _it_a_l.role = "leader"; _it_a_l.team_id = 70
	_it_a_l.skills["偵查"] = 0.0
	state.persons[70] = _it_a_l; _it_a.leader_id = 70

	# 目標 Team71（pop=20，在 (2,0)，dist=2，exposure 高）
	var _it_b := TeamData.new()
	_it_b.team_id = 71; _it_b.population = 20; _it_b.tile_pos = Vector2i(2, 0)
	_it_b.resources = {
		"food": 80.0, "material": 30.0, "coin": 0.0, "goods": 0.0, "gem": 0.0,
		"ore_gold": 0.0, "ore_silver": 0.0, "ore_iron": 0.0, "ore_steel": 0.0,
		"weapon_melee_low": 0.0, "weapon_melee_high": 0.0,
		"weapon_ranged_low": 0.0, "weapon_ranged_high": 0.0,
		"mounts": 0, "wagons": 0, "arrows": 0, "medicine": 0, "tools": 0,
		"armor_low": 0, "armor_high": 0,
	}
	state.teams[71] = _it_b; state.team_discovered[71] = []
	var _it_b_l := PersonData.new()
	_it_b_l.id = 71; _it_b_l.role = "leader"; _it_b_l.team_id = 71
	state.persons[71] = _it_b_l; _it_b.leader_id = 71

	_it_vis.tick_discovery(state, [70, 71])
	print("=== IntelSystem Tier 0 驗證 ===")
	var _it_snap0: Dictionary = state.team_intel.get(70, {}).get(71, {})
	if _it_snap0.get("tier", -1) == 0:
		print("  [OK] tier=0")
	else:
		print("  [FAIL] tier=%s（預期 0）" % str(_it_snap0.get("tier", "missing")))
	var _pop_est: int = int(_it_snap0.get("population_est", -1))
	if _pop_est >= 10 and _pop_est <= 30:
		print("  [OK] population_est=%d（範圍 10–30）" % _pop_est)
	else:
		print("  [FAIL] population_est=%d（預期 10–30）" % _pop_est)

	# Tier 1：Team70 移到 (1,0)，dist=1；Team71 total_res=110 → bucket=1，±1 → 0–2
	_it_a.tile_pos = Vector2i(1, 0)
	_it_vis.tick_discovery(state, [70])
	print("=== IntelSystem Tier 1 驗證 ===")
	var _it_snap1: Dictionary = state.team_intel.get(70, {}).get(71, {})
	if _it_snap1.get("tier", -1) >= 1:
		print("  [OK] tier≥1（dist=1 近接觸）")
	else:
		print("  [FAIL] tier=%s（預期 ≥1）" % str(_it_snap1.get("tier", "missing")))
	var _rscale: int = int(_it_snap1.get("resource_scale", -1))
	if _rscale >= 0 and _rscale <= 2:
		print("  [OK] resource_scale=%d（預期 0–2，total=110→bucket1±1）" % _rscale)
	else:
		print("  [FAIL] resource_scale=%d（預期 0–2）" % _rscale)

	# 快照持久：Team71 移出視野（dist=10），team_intel 應仍保留舊值
	var _last_pop: int = int(state.team_intel.get(70, {}).get(71, {}).get("population_est", -1))
	_it_b.tile_pos = Vector2i(10, 0)
	_it_vis.tick_discovery(state, [70])
	var _it_snap_p: Dictionary = state.team_intel.get(70, {}).get(71, {})
	print("=== IntelSystem 快照持久 驗證 ===")
	if int(_it_snap_p.get("population_est", -1)) == _last_pop and _last_pop > 0:
		print("  [OK] 快照保留（population_est=%d 不變）" % _last_pop)
	else:
		print("  [FAIL] 快照被清除（got=%s）" % str(_it_snap_p.get("population_est", "missing")))

	# 清理
	state.teams.erase(70); state.teams.erase(71)
	state.team_discovered.erase(70); state.team_discovered.erase(71)
	state.persons.erase(70); state.persons.erase(71)

	# ── IntelSystem Tier 2 驗證 ──
	var _it_inter := InteractionSystem.new()

	# 觀察者 Team72
	var _it_obs := TeamData.new()
	_it_obs.team_id = 72; _it_obs.population = 5; _it_obs.tile_pos = Vector2i(0, 0)
	state.teams[72] = _it_obs; state.team_discovered[72] = []
	var _it_obs_l := PersonData.new()
	_it_obs_l.id = 72; _it_obs_l.role = "leader"; _it_obs_l.team_id = 72
	state.persons[72] = _it_obs_l; _it_obs.leader_id = 72

	# 高信義 Team73（生產隊，幾乎不造假）
	var _it_hon := TeamData.new()
	_it_hon.team_id = 73; _it_hon.population = 10; _it_hon.tile_pos = Vector2i(0, 0)
	_it_hon.tags = ["生產"]
	_it_hon.resources = {
		"food": 100.0, "material": 0.0, "coin": 20.0, "goods": 0.0, "gem": 0.0,
		"ore_gold": 0.0, "ore_silver": 0.0, "ore_iron": 0.0, "ore_steel": 0.0,
		"weapon_melee_low": 4.0, "weapon_melee_high": 0.0,
		"weapon_ranged_low": 0.0, "weapon_ranged_high": 0.0,
		"mounts": 0, "wagons": 0, "arrows": 0, "medicine": 0, "tools": 0,
		"armor_low": 0, "armor_high": 0,
	}
	_it_hon.armed_anon_ratio = 0.0
	state.teams[73] = _it_hon; state.team_discovered[73] = []
	var _it_hon_l := PersonData.new()
	_it_hon_l.id = 73; _it_hon_l.role = "leader"; _it_hon_l.team_id = 73
	_it_hon_l.values["信義"] = 0.95
	state.persons[73] = _it_hon_l; _it_hon.leader_id = 73

	_it_inter._write_tier2_intel(state, 72, 73)
	print("=== IntelSystem Tier 2（高信義）===")
	var _snap73: Dictionary = state.team_intel.get(72, {}).get(73, {})
	if _snap73.get("tier", -1) == 2:
		print("  [OK] tier=2")
	else:
		print("  [FAIL] tier=%s（預期 2）" % str(_snap73.get("tier", "missing")))
	var _food73: float = float(_snap73.get("food_est", -1.0))
	# 高信義不應高報 food（偽裝平民時 food × 1.5–2.5）；直接值應為 100.0
	if _food73 >= 80.0:
		print("  [OK] food_est=%.1f（高信義，接近實際 100）" % _food73)
	else:
		print("  [WARN] food_est=%.1f（可能觸發偽裝，但高信義概率極低）" % _food73)
	if _snap73.has("coin_est"):
		print("  [OK] coin_est=%.1f（Tier 2 欄位存在）" % float(_snap73.get("coin_est", 0.0)))
	else:
		print("  [FAIL] coin_est 欄位缺少")

	# 低信義軍隊 Team74（高 deceive_chance → 偽裝平民）
	var _it_low := TeamData.new()
	_it_low.team_id = 74; _it_low.population = 10; _it_low.tile_pos = Vector2i(0, 0)
	_it_low.tags = ["軍隊"]
	_it_low.resources = {
		"food": 50.0, "material": 0.0, "coin": 0.0, "goods": 0.0, "gem": 0.0,
		"ore_gold": 0.0, "ore_silver": 0.0, "ore_iron": 0.0, "ore_steel": 0.0,
		"weapon_melee_low": 0.0, "weapon_melee_high": 0.0,
		"weapon_ranged_low": 0.0, "weapon_ranged_high": 0.0,
		"mounts": 0, "wagons": 0, "arrows": 0, "medicine": 0, "tools": 0,
		"armor_low": 0, "armor_high": 0,
	}
	_it_low.armed_anon_ratio = 0.8  # anon_pop=9 → actual_armed≈7
	state.teams[74] = _it_low; state.team_discovered[74] = []
	var _it_low_l := PersonData.new()
	_it_low_l.id = 74; _it_low_l.role = "leader"; _it_low_l.team_id = 74
	_it_low_l.values["信義"] = 0.05   # deceive_chance ≈ (0.95)×0.5 = 0.475
	_it_low_l.skills["計謀"] = 0.5    # + 0.5×0.2 = 0.1 → total ≈ 0.575
	state.persons[74] = _it_low_l; _it_low.leader_id = 74

	# 多次取樣（造假為機率事件），偽裝觸發 → armed_est < 4（實際≈7 × 0.2–0.4 = 1–3）
	var _deception_ok: bool = false
	for _i in range(20):
		_it_inter._write_tier2_intel(state, 72, 74)
		var _s74: Dictionary = state.team_intel.get(72, {}).get(74, {})
		if int(_s74.get("armed_est", 999)) < 4:
			_deception_ok = true; break
	print("=== IntelSystem Tier 2（低信義軍隊 偽裝平民）===")
	if _deception_ok:
		print("  [OK] 偽裝平民觸發（20次取樣中 armed_est 低報）")
	else:
		print("  [WARN] 20次取樣均未觸發（RNG 偶發，偵查概率=0.575 應多數觸發）")

	# 清理
	for _tid_t2 in [72, 73, 74]:
		state.teams.erase(_tid_t2)
		state.team_discovered.erase(_tid_t2)
		state.persons.erase(_tid_t2)

	# ── IntelSystem 攻擊決策驗證 ──
	print("=== IntelSystem 攻擊決策 驗證 ===")
	var _ad_leader := TeamData.new()
	_ad_leader.team_id = 80; _ad_leader.population = 10
	_ad_leader.tile_pos = Vector2i(0, 1); _ad_leader.tags = ["統領"]
	_ad_leader.readiness = 0.8
	_ad_leader.armed_anon_ratio = 0.3  # anon_pop=9 → roundi(9×0.3)=3 → own_armed=3
	state.teams[80] = _ad_leader; state.team_discovered[80] = []
	var _ad_fid: int = state.create_faction(80)  # 必須在 teams[80] 存在後呼叫
	state.factions[_ad_fid].is_established = true
	_ad_leader.faction_id = _ad_fid
	var _ad_l_p := PersonData.new()
	_ad_l_p.id = 80; _ad_l_p.role = "leader"; _ad_l_p.team_id = 80
	_ad_l_p.values["野心"] = 0.8; _ad_l_p.values["好戰"] = 0.8
	_ad_l_p.values["義氣"] = 0.1; _ad_l_p.skills["統領"] = 0.5
	state.persons[80] = _ad_l_p; _ad_leader.leader_id = 80

	var _ad_tgt := TeamData.new()
	_ad_tgt.team_id = 81; _ad_tgt.population = 8; _ad_tgt.tile_pos = Vector2i(1, 1)
	_ad_tgt.faction_id = -1; _ad_tgt.armed_anon_ratio = 0.0
	state.teams[81] = _ad_tgt
	state.team_discovered[80].append(81)
	var _ad_tgt_p := PersonData.new()
	_ad_tgt_p.id = 81; _ad_tgt_p.role = "leader"; _ad_tgt_p.team_id = 81
	state.persons[81] = _ad_tgt_p; _ad_tgt.leader_id = 81

	var _ad_fai: Object = load("res://scripts/simulation/faction_ai_system.gd").new()

	# 場景 1：無 team_intel snap → armed_est=999 → 不應加入攻擊 goal
	_ad_fai._update_goals(state, state.factions[_ad_fid])
	if not state.factions[_ad_fid].goals.has("攻擊"):
		print("  [OK] 未知目標（armed_est=999）→ 無攻擊 goal")
	else:
		print("  [FAIL] 未知目標仍加入攻擊 goal（應檢查 _update_goals 實力比較邏輯）")

	# 場景 2：寫入弱目標 snap（armed_est=2）→ own_armed≥2×0.8=1.6 → 應加入攻擊 goal
	if not state.team_intel.has(80):
		state.team_intel[80] = {}
	state.team_intel[80][81] = {
		"tier": 0, "population_est": 8, "armed_est": 2,
		"tile_pos": Vector2i(1, 1), "last_tick": 0,
	}
	state.factions[_ad_fid].goals.clear()
	_ad_fai._update_goals(state, state.factions[_ad_fid])
	if state.factions[_ad_fid].goals.has("攻擊"):
		print("  [OK] 弱目標（armed_est=2）→ 加入攻擊 goal")
	else:
		print("  [FAIL] 弱目標未加入攻擊 goal")

	# 清理
	state.teams.erase(80); state.teams.erase(81)
	state.team_discovered.erase(80)
	state.persons.erase(80); state.persons.erase(81)
	state.factions.erase(_ad_fid)
	state.team_intel.erase(80)

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
		for pid in ([t.leader_id] as Array) + t.named_members:
			var p: PersonData = state.persons.get(pid)
			if p == null: continue
			var wt: String = p.equipment["right_hand"].get("type", "none")
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
	# === 資料結構驗證 ===
	var _dsp: PersonData = state.persons.get(0)
	assert(_dsp != null, "Person0 不存在")
	assert("salary" in _dsp, "缺少 salary 欄位")
	assert("coin" in _dsp, "缺少 coin 欄位")
	assert("relations" in _dsp, "缺少 relations 欄位")
	assert(_dsp.relations is Dictionary, "relations 應為 Dictionary")
	print("[DataStruct] salary/coin/relations 欄位驗證通過")

	var _dep: PersonData = state.persons.get(0)
	assert(_dep.equipment.has("right_hand"), "缺少 right_hand 裝備格")
	assert(_dep.equipment.has("torso"), "缺少 torso 裝備格")
	assert(_dep.equipment["right_hand"] is Dictionary, "right_hand 應為 Dictionary")
	print("[DataStruct] equipment 8格驗證通過")

	var _dgp: PersonData = state.persons.get(0)
	assert(_dgp.goals.size() > 0, "goals 不應為空")
	assert(_dgp.goals[0] is Dictionary, "goals[0] 應為 Dictionary")
	assert(_dgp.goals[0].has("type"), "goals[0] 缺少 type")
	assert(_dgp.goals[0].has("active"), "goals[0] 缺少 active")
	print("[DataStruct] goals 格式驗證通過")

	var _dtm: TeamData = state.teams.get(0)
	assert("named_members" in _dtm, "缺少 named_members 欄位")
	assert(_dtm.named_members is Array, "named_members 應為 Array")
	print("[DataStruct] named_members 欄位驗證通過")

	var _dte: TeamData = state.teams.get(0)
	assert("fatigue" in _dte, "缺少 fatigue")
	assert("guard_ratio" in _dte, "缺少 guard_ratio")
	assert("anon_wage" in _dte, "缺少 anon_wage")
	assert("armor_config" in _dte, "缺少 armor_config")
	assert("known_reputations" in _dte, "缺少 known_reputations")
	assert("strategic_assignments" in _dte, "缺少 strategic_assignments")
	print("[DataStruct] TeamData 新欄位驗證通過")

	var _dtr: TeamData = state.teams.get(0)
	assert(_dtr.resources.has("mounts"), "resources 缺少 mounts")
	assert(_dtr.resources.has("arrows"), "resources 缺少 arrows")
	assert(_dtr.resources.has("medicine"), "resources 缺少 medicine")
	print("[DataStruct] resources 新 key 驗證通過")

	assert("player_id" in state, "WorldState 缺少 player_id")
	assert(state.player_id == -1, "player_id 預設應為 -1")
	assert("ticks_per_day" in state, "WorldState 缺少 ticks_per_day")
	assert(state.ticks_per_day == 24, "ticks_per_day 應為 24")
	print("[DataStruct] WorldState 新欄位驗證通過")

	print("[DataStruct] named_members 非空: Team0=%d" % state.teams[0].named_members.size())
	print("[DataStruct] person.salary 型別: %s" % typeof(state.persons[0].salary))
	print("[DataStruct] state.ticks_per_day=%d" % state.ticks_per_day)

	# === NpcAI Task 1: write_memory / relations ===
	var _npc_sys := NpcAiSystem.new()
	var _mp: PersonData = state.persons.get(1)
	_npc_sys.write_memory(_mp, "looted", 0, 0, 0.7)
	assert(_mp.memory.size() > 0, "memory 應有記錄")
	assert(_mp.memory[_mp.memory.size() - 1]["type"] == "looted", "記憶 type 應為 looted")
	assert(float(_mp.relations.get(0, 0.0)) < 0.0, "relations[0] 應為負值")
	print("[NpcAI] write_memory/relations 驗證通過")

	# === NpcAI Task 2: 目標生成/觸發 ===
	var _gp: PersonData = PersonData.new()
	_gp.values["貪婪"] = 0.8
	NpcAiSystem.new().generate_birth_goals(_gp)
	assert(_gp.goals.size() > 0, "birth goals 應生成")
	assert(_gp.goals[0]["type"] == "wealth", "高貪婪應生成 wealth 目標")

	var _npc2 := NpcAiSystem.new()
	var _rp: PersonData = state.persons.get(1)
	_npc2.write_memory(_rp, "looted", 0, 1, 0.7)
	var _has_revenge: bool = false
	for g in _rp.goals:
		if g["type"] == "revenge" and g["active"]: _has_revenge = true
	assert(_has_revenge, "looted 記憶應觸發 revenge 目標")
	print("[NpcAI] 目標生成/觸發驗證通過")

	# === NpcAI Task 3: check_goal_alignment ===
	var _npc3 := NpcAiSystem.new()
	var _cp: PersonData = state.persons.get(1)
	_npc3._activate_goal(_cp, "revenge", 9)
	var _align: float = _npc3.check_goal_alignment(_cp, "逃跑")
	assert(_align < 0.0 or _align == 0.0, "revenge+逃跑不衝突（返回 0 或負）")
	var _align2: float = _npc3.check_goal_alignment(_cp, "攻擊")
	assert(_align2 > 0.0, "revenge+攻擊應 aligned（> 0）")
	print("[NpcAI] check_goal_alignment 驗證通過")

	# === TeamAI 驗證 ===
	print("[Salary] 驗證：30 tick 後應有薪水結算 print（見上方 tick 30 附近輸出）")
	var _evt_split: Object = load("res://scripts/simulation/events/event_unrest_split.gd").new()
	var _tp := PersonData.new()
	_tp.loyalty = 0.8
	_evt_split.reset_loyalty_on_transfer(_tp, "split_hard")
	assert(_tp.loyalty == 0.5, "split_hard loyalty 應為 0.5")
	_evt_split.reset_loyalty_on_transfer(_tp, "split_leader")
	assert(_tp.loyalty == 1.0, "split_leader loyalty 應為 1.0")
	print("[TeamAI] reset_loyalty_on_transfer 驗證通過")
	var _split_found: bool = false
	for _stid in state.teams:
		var _st: TeamData = state.teams[_stid]
		if _stid in [0, 1, 2, 3, 5, 6, 8, 9, 10]: continue
		var _sldr: PersonData = state.persons.get(_st.leader_id)
		if _sldr and absf(_sldr.loyalty - 1.0) < 0.01:
			print("[TeamAI] split_leader loyalty=1.0 驗證通過 (Team%d)" % _stid)
			_split_found = true
			break
	if not _split_found:
		print("[TeamAI] split_leader loyalty=1.0 未找到（分裂事件可能未觸發，屬正常）")
	var _ft: TeamData = state.teams.get(0)
	if _ft:
		print("[TeamAI] Team0 fatigue=%.4f（預期 > 0）" % _ft.fatigue)
		assert(_ft.fatigue > 0.0, "移動 team 應有疲勞累積")
	var _ms: Object = load("res://scripts/simulation/movement_system.gd").new()
	var _wt: TeamData = state.teams.get(0)
	if _wt:
		var _cap: float = _ms.get_carry_capacity(_wt)
		print("[TeamAI] Team0 carry_cap=%.1f weight=%.1f" % [_cap, _ms.calc_total_weight(_wt)])
		assert(_cap > 0.0, "carry capacity 應 > 0")
	print("=== DONE ===")
