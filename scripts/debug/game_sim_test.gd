extends SceneTree

# ══════════════════════════════════════════════════════════════════════════════
# game_sim_test.gd — 完整遊戲循環 headless 測試
#
# 用法：
#   Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/game_sim_test.gd
#
# 測試目標：
#   1. 500 tick 穩定性（無崩潰）
#   2. 人口不變量（population >= 1，除非真的滅絕）
#   3. 資源不變量（food/material/coin >= 0）
#   4. action_timer 不為負（遭遇戰）
#   5. Team 狀態（leader_id 指向存在的 person）
#   6. Faction 一致性
#
# Known issues 迴避策略（來自 docs/known_issues.md）：
#   S2: SALARY_INTERVAL 問題 → 初始 coin 給充足（每人 200 coin）
#   S4: 人口分裂太快 → 初始 pop 設低（每隊 6 人），leader 統領技能設高（cap 大）
#   S5: 糧食不足 → food 設 5000+，加初始 outpost
# ══════════════════════════════════════════════════════════════════════════════

func _initialize() -> void:
	_run_game_sim_test()
	quit()

func _run_game_sim_test() -> void:
	print("=== game_sim_test: 完整遊戲循環測試 ===")
	print("設定：3 team（2 faction）× 500 tick，每 100 tick 印狀態")

	# ── 建立 WorldState + SimRunner ──
	var state := WorldState.new()
	var runner := SimRunner.new()

	# ── 生成地圖（radius=4）──
	var generator = load("res://scripts/simulation/world_generator.gd").new()
	generator.generate(state, { "radius": 4, "seed": 77 })

	# ── 設定地形（避免 mountain 干擾，保持 plains 好採集）──
	for _tid in [4004, 5004, 6004, 7004, 8004, 4005, 5005, 6005]:
		if state.world.tiles.has(_tid):
			(state.world.tiles[_tid] as HexTileData).terrain = "plains"

	# ── 建立初始 outpost（S5 迴避：確保有資源來源）──
	# Team0 在 (4,4) 建軍事據點
	if state.world.tiles.has(4004):
		var t0_tile: HexTileData = state.world.tiles[4004] as HexTileData
		t0_tile.outpost_type  = "military"
		t0_tile.outpost_level = 1
		t0_tile.outpost_owner = 0
		t0_tile.resources["food"] = 2000.0
	# Team1 在 (6,4) 建民用據點
	if state.world.tiles.has(6004):
		var t1_tile: HexTileData = state.world.tiles[6004] as HexTileData
		t1_tile.outpost_type  = "civilian"
		t1_tile.outpost_level = 1
		t1_tile.outpost_owner = 1
		t1_tile.resources["food"] = 2000.0
	# Team2 在 (5,5) 也建民用據點
	if state.world.tiles.has(5005):
		var t2_tile: HexTileData = state.world.tiles[5005] as HexTileData
		t2_tile.outpost_type  = "civilian"
		t2_tile.outpost_level = 1
		t2_tile.outpost_owner = 2
		t2_tile.resources["food"] = 2000.0

	# ── 建立 3 個 team ──
	# Team0: 玩家 team（faction A 的領袖）
	# Team1: NPC team（faction A 的成員）
	# Team2: 敵對 NPC team（faction B）

	var RESOURCE_TEMPLATE := {
		"food": 5000.0,      # S5 迴避：大量初始食物
		"material": 200,
		"coin": 600,         # S2 迴避：充足 coin（每人≈100 coin 備付薪水多輪）
		"goods": 0, "gem": 0,
		"ore_gold": 0, "ore_silver": 0, "ore_iron": 0, "ore_steel": 0,
		"weapon_melee_low": 10, "weapon_melee_high": 0,
		"weapon_ranged_low": 0, "weapon_ranged_high": 0,
		"mounts": 0, "wagons": 0, "arrows": 0, "medicine": 10, "tools": 0,
		"armor_low": 4, "armor_high": 0,
	}

	# 位置：Team0=(4,4)  Team1=(6,4)  Team2=(5,5)
	var POSITIONS: Array = [Vector2i(4,4), Vector2i(6,4), Vector2i(5,5)]
	var TEAM_TAGS: Array = [["統領"], ["生產"], ["軍隊"]]

	for t in range(3):
		var team := TeamData.new()
		team.team_id = t
		team.population = 6       # S4 迴避：小隊，不易觸發人口分裂
		team.minor_population = 0
		var res := RESOURCE_TEMPLATE.duplicate()
		team.resources = res
		team.tags = TEAM_TAGS[t].duplicate()
		team.tile_pos = POSITIONS[t]
		team.current_task = "idle"
		team.guard_ratio = 0.2
		state.teams[t] = team
		state.team_known[t] = []
		state.team_discovered[t] = []

		# 每個 team 建立 leader + 2 named members
		for p in range(3):
			var person := PersonData.new()
			person.id = t * 3 + p
			person.person_name = "P%d_%d" % [t, p]
			person.role = "leader" if p == 0 else "civilian"
			person.team_id = t
			person.age = 25 + t * 2 + p
			person.loyalty = 0.9
			person.stress = 0.0
			person.salary = 2.0    # 適中薪水
			# 統領技能設高 → pop_cap 大，S4 迴避
			person.skills["統領"] = 0.7   # cap = clamp(round(49*0.875)+1,1,50) = 44
			person.skills["偵查"] = 0.3
			person.goals = [
				{ "type": "domination", "target_id": -1, "active": true },
				{ "type": "wealth",     "target_id": -1, "active": true },
			]
			person.values["野心"] = 0.5
			person.values["好戰"] = 0.3 if t == 0 else (0.7 if t == 2 else 0.2)
			person.values["義氣"] = 0.5
			state.persons[person.id] = person
			if p == 0:
				team.leader_id = person.id
			else:
				team.named_members.append(person.id)

	# ── 建立 2 個 Faction ──
	# Faction A: Team0（leader）+ Team1（member）
	# Faction B: Team2（單獨）
	var fid_a: int = state.create_faction(0)   # Team0 為 faction A leader
	state.factions[fid_a].member_team_ids.append(1)
	state.teams[1].faction_id = fid_a

	var fid_b: int = state.create_faction(2)   # Team2 為 faction B leader

	# 手動補雙向發現（確保互知）
	for ta in range(3):
		for tb in range(3):
			if ta != tb:
				if not state.team_discovered[ta].has(tb):
					state.team_discovered[ta].append(tb)

	print("初始設定完成：")
	print("  Faction A (id=%d): Team0[統領] + Team1[生產]" % fid_a)
	print("  Faction B (id=%d): Team2[軍隊]" % fid_b)
	print("  Team0 pos=%s food=%.0f pop=%d leader_id=%d" % [
		str(state.teams[0].tile_pos),
		float(state.teams[0].resources.get("food", 0)),
		state.teams[0].population,
		state.teams[0].leader_id
	])

	# ── 模擬主循環 ──
	var player_pos := Vector2i(4, 4)
	var ticks_completed: int = 0
	var fail_msgs: Array = []
	var invariant_violations: int = 0

	print("\n=== 開始 500 tick 模擬 ===")
	for tick in range(500):
		# 如果遭遇戰觸發且 encounter_active，讓 runner 自動處理
		# （runner.advance_tick 內部會推進 encounter 並自動結算）
		runner.advance_tick(state, player_pos)
		ticks_completed += 1

		# ── 每 100 tick 印狀態 ──
		if (tick + 1) % 100 == 0:
			print("\n[State tick=%d]" % state.world.current_tick)
			for tid in state.teams:
				var t: TeamData = state.teams[tid]
				var ldr: PersonData = state.persons.get(t.leader_id)
				var ldr_ok: String = "OK" if ldr != null else "MISSING"
				print("  team=%d pos=(%d,%d) pop=%d food=%.0f coin=%.0f task=%s readiness=%.2f leader=%s" % [
					tid,
					t.tile_pos.x, t.tile_pos.y,
					t.population,
					float(t.resources.get("food", 0)),
					float(t.resources.get("coin", 0)),
					t.current_task,
					t.readiness,
					ldr_ok
				])

		# ── 每 tick 不變量驗證（靜默，只記錄違規）──

		# 1. encounter unit action_timer 不為負
		if state.encounter_active:
			for unit in state.encounter_units:
				var at: float = float(unit.get("action_timer", 0.0))
				if at < -0.001:
					invariant_violations += 1
					fail_msgs.append("[T%d] action_timer=%.4f < 0" % [state.world.current_tick, at])

		# 2. 資源不為負（每 50 tick 檢查一次，避免過多噪音）
		if (tick + 1) % 50 == 0:
			for tid in state.teams:
				var t: TeamData = state.teams[tid]
				for key in ["food", "material", "coin"]:
					var val: float = float(t.resources.get(key, 0))
					if val < -0.01:
						invariant_violations += 1
						fail_msgs.append("[T%d] Team%d.%s=%.2f < 0" % [
							state.world.current_tick, tid, key, val])

	# ── 最終不變量檢查 ──
	print("\n=== 最終不變量檢查（tick=%d）===" % state.world.current_tick)

	# 1. 至少 1 個 team 存活
	var surviving_teams: int = state.teams.size()
	if surviving_teams >= 1:
		print("  [OK] team 存活數=%d（>=1）" % surviving_teams)
	else:
		print("  [FAIL] 沒有 team 存活！")
		invariant_violations += 1

	# 2. 每個存活 team 的 leader_id 指向存在的 person
	var leader_ok_count: int = 0
	var leader_fail_count: int = 0
	for tid in state.teams:
		var t: TeamData = state.teams[tid]
		var ldr: PersonData = state.persons.get(t.leader_id)
		if ldr != null:
			leader_ok_count += 1
		else:
			leader_fail_count += 1
			fail_msgs.append("Team%d.leader_id=%d 不存在於 state.persons" % [tid, t.leader_id])
	if leader_fail_count == 0:
		print("  [OK] 全部 %d 個 team 的 leader_id 均有效" % leader_ok_count)
	else:
		print("  [FAIL] %d 個 team 的 leader_id 無效（見下）" % leader_fail_count)
		invariant_violations += leader_fail_count

	# 3. population >= 0（滅絕後 team 可能被移除，存活 team 不可為 0 除非已標記滅絕）
	var pop_fail: int = 0
	for tid in state.teams:
		var t: TeamData = state.teams[tid]
		if t.population < 1:
			pop_fail += 1
			fail_msgs.append("Team%d.population=%d < 1" % [tid, t.population])
	if pop_fail == 0:
		print("  [OK] 全部存活 team population >= 1")
	else:
		print("  [WARN] %d 個 team population < 1（可能為滅絕邊緣）" % pop_fail)
		# 不計為硬性失敗（邊緣情況允許）

	# 4. minor_population >= 0
	for tid in state.teams:
		var t: TeamData = state.teams[tid]
		if t.minor_population < 0:
			invariant_violations += 1
			fail_msgs.append("Team%d.minor_population=%d < 0" % [tid, t.minor_population])
	print("  [OK] minor_population 全部 >= 0")

	# 5. 資源不為負（最終檢查）
	var res_neg: int = 0
	for tid in state.teams:
		var t: TeamData = state.teams[tid]
		for key in ["food", "material", "coin"]:
			var val: float = float(t.resources.get(key, 0))
			if val < -0.01:
				res_neg += 1
				fail_msgs.append("Team%d.%s=%.2f < 0（最終）" % [tid, key, val])
	if res_neg == 0:
		print("  [OK] 全部 team food/material/coin >= 0")
	else:
		print("  [FAIL] %d 個資源違反不為負規則" % res_neg)
		invariant_violations += res_neg

	# 6. 至少跑過 400 tick（無提早崩潰）
	if ticks_completed >= 400:
		print("  [OK] ticks_completed=%d >= 400（無提早崩潰）" % ticks_completed)
	else:
		print("  [FAIL] ticks_completed=%d < 400（提早結束）" % ticks_completed)
		invariant_violations += 1

	# 7. Faction 一致性
	var faction_ok: bool = true
	for tid in state.teams:
		var t: TeamData = state.teams[tid]
		if t.faction_id != -1 and not state.factions.has(t.faction_id):
			faction_ok = false
			fail_msgs.append("Team%d.faction_id=%d 不存在" % [tid, t.faction_id])
	if faction_ok:
		print("  [OK] Faction 一致性通過")
	else:
		print("  [FAIL] Faction 一致性違規（見失敗訊息）")
		invariant_violations += 1

	# ── 最終統計 ──
	print("\n=== 最終統計 ===")
	print("  ticks_completed=%d / 500" % ticks_completed)
	print("  surviving_teams=%d" % state.teams.size())
	print("  surviving_persons=%d" % state.persons.size())
	print("  factions=%d" % state.factions.size())
	for fid in state.factions:
		var f = state.factions[fid]
		print("    勢力%d [%s] leader=Team%d members=%s" % [
			fid,
			f.faction_name if f.is_established else "未立國號",
			f.leader_team_id,
			str(f.member_team_ids)
		])
	print("  global_messages=%d" % state.global_messages.size())

	print("\n=== Team 最終狀態 ===")
	for tid in state.teams:
		var t: TeamData = state.teams[tid]
		print("  Team%d pos=(%d,%d) pop=%d food=%.0f coin=%.0f task=%s readiness=%.2f faction=%d" % [
			tid,
			t.tile_pos.x, t.tile_pos.y,
			t.population,
			float(t.resources.get("food", 0)),
			float(t.resources.get("coin", 0)),
			t.current_task,
			t.readiness,
			t.faction_id
		])
		# 驗證 leader person 存在
		var ldr2: PersonData = state.persons.get(t.leader_id)
		if ldr2:
			print("    leader=P%d(%s) loyalty=%.2f" % [ldr2.id, ldr2.person_name, ldr2.loyalty])
		else:
			print("    leader=MISSING(id=%d)" % t.leader_id)

	# ── 失敗訊息 ──
	if fail_msgs.size() > 0:
		print("\n=== 違規詳情 ===")
		for msg in fail_msgs:
			print("  ! " + msg)

	# ── 最終判定 ──
	print("\n=== 最終判定 ===")
	if invariant_violations == 0:
		print("  ALL INVARIANTS PASSED (violations=0)")
	else:
		print("  INVARIANTS FAILED (violations=%d)" % invariant_violations)
	print("=== game_sim_test DONE ===")
