extends SceneTree

# beast-decision-leak + id-collision TDD（spec 2026-07-19-beast-decision-leak-and-id-collision）。
# 兩 root：
#   ① id 碰撞——_next_beast_id 舊為 BeastSystem instance var → 每 new() 重置 -1000000 → 全 beast 撞同 id
#      （create_team 靜默覆寫）。修 = counter 移 WorldState.next_beast_id（per-world fresh，禁 static）。
#   ② 決策洩漏——beast(faction_id=-1)落 evaluate_all loop2/loop3 → succession 晉升領袖 + ambition + survival。
#      修 = 兩 loop body 頂 `if team.beast_kind != "": continue`。beast 生命週期全在 combat/encounter/beast_system。

var _fail: int = 0

func _initialize() -> void:
	_test_id_unique()
	_test_counter_per_world_fresh()
	_test_beast_not_in_decision_loop()
	_test_real_team_still_promotes()
	if _fail == 0:
		print("=== DONE === ALL PASS")
	else:
		print("=== DONE === %d FAIL" % _fail)
	quit()

func _ok(cond: bool, msg: String) -> void:
	if cond:
		print("  [PASS] %s" % msg)
	else:
		_fail += 1
		print("  [FAIL] %s" % msg)

# ── Root 1：id 唯一（3 beast → 3 相異 id，非全 -1000000 互相覆寫）──
func _test_id_unique() -> void:
	print("--- Root1: beast id 唯一 ---")
	var state := WorldState.new(); state.world = WorldData.new()
	# ★每 spawn 用 fresh BeastSystem.new()——鏡射生產（faction_ai:3314/encounter:1232/ambush:57/
	# player_command:177 皆每次 new()）。instance-var counter 在此撞同 id；WorldState counter 才唯一。
	var id1: int = BeastSystem.new().build_beast_team(state, "deer", Vector2i(1, 1))
	var id2: int = BeastSystem.new().build_beast_team(state, "boar", Vector2i(2, 2))
	var id3: int = BeastSystem.new().build_beast_team(state, "bear", Vector2i(3, 3))
	_ok(id1 != id2 and id2 != id3 and id1 != id3, "3 beast 3 相異 id（got %d/%d/%d）" % [id1, id2, id3])
	_ok(state.teams.size() == 3, "3 beast 全存活於 state.teams（無覆寫，got %d）" % state.teams.size())
	_ok(id1 < 0 and id2 < 0 and id3 < 0, "全為負區段 id（避開正常 team id）")
	_ok(state.next_beast_id == -1000003, "counter 遞減至 -1000003（got %d）" % state.next_beast_id)

# ── Root 1：counter 每 world fresh（禁 static var——static 跨 run 不 reset=非決定）──
func _test_counter_per_world_fresh() -> void:
	print("--- Root1: counter per-world fresh（禁 static）---")
	var s1 := WorldState.new(); s1.world = WorldData.new()
	var _a: int = BeastSystem.new().build_beast_team(s1, "deer", Vector2i(1, 1))
	var s2 := WorldState.new(); s2.world = WorldData.new()
	var b: int = BeastSystem.new().build_beast_team(s2, "deer", Vector2i(1, 1))
	# fresh world → 第一隻 beast 恆拿 -1000000（static var 會續 s1 的 -1000001 = 非決定）
	_ok(b == -1000000, "新 world 首 beast id=-1000000（per-seed 決定；static 會=-1000001，got %d）" % b)

# ── Root 2：beast 不進決策迴圈（spawn 跑 evaluate_all → 不晉升領袖 / 不派 task / 無 ambition）──
func _test_beast_not_in_decision_loop() -> void:
	print("--- Root2: beast 不進決策迴圈 ---")
	var state := WorldState.new(); state.world = WorldData.new()
	# beast 所在 tile（避 survival/pathfinding 讀空崩）
	var tile := HexTileData.new()
	tile.tile_id = 1 * 1000 + 1; tile.tile_pos = Vector2i(1, 1); tile.terrain = "plains"
	state.world.tiles[tile.tile_id] = tile
	var bid: int = BeastSystem.new().build_beast_team(state, "deer", Vector2i(1, 1))
	var beast: TeamData = state.teams[bid]
	var fai := FactionAISystem.new()
	# 跑數 tick evaluate_all（無 faction → loop1 空；beast 走 loop2/loop3）
	for i in range(8):
		state.world.current_tick = i * 10
		fai.evaluate_all(state, state.teams.keys())
	_ok(state.teams.has(bid), "beast 未被 evaluate_all 誤清")
	_ok(beast.leader_id == -1, "beast 未被 succession 晉升領袖（leader_id 仍 -1，got %d）" % beast.leader_id)
	_ok(beast.current_task == TeamData.TASK_IDLE, "beast 未被派 task（current_task 仍 idle，got '%s')" % beast.current_task)
	_ok(beast.task_reason != "ambition" and beast.task_reason != "prosperity", "beast 無 ambition/prosperity intent（task_reason='%s')" % beast.task_reason)
	_ok(beast.faction_id == -1, "beast 仍無 faction（未建國）")

# ── 對照：真隊（beast_kind="" + 有 pop）仍正常走 succession（fix 不誤傷真隊）──
func _test_real_team_still_promotes() -> void:
	print("--- 對照: 真隊仍正常晉升（fix 不誤傷）---")
	var state := WorldState.new(); state.world = WorldData.new()
	var tile := HexTileData.new()
	tile.tile_id = 5 * 1000 + 5; tile.tile_pos = Vector2i(5, 5); tile.terrain = "plains"
	state.world.tiles[tile.tile_id] = tile
	var t := TeamData.new()
	t.team_id = 1; t.tile_pos = Vector2i(5, 5); t.leader_id = -1   # 無領袖 → 應被 succession 晉升
	AnonCohort.add(t.anon_cohorts, AnonCohort.TIER_PLEB, "healthy", 6)
	state.create_team(t)
	var fai := FactionAISystem.new()
	state.world.current_tick = 10
	fai.evaluate_all(state, state.teams.keys())
	# 真隊 beast_kind="" → 不被 continue skip → succession 應晉升一名 anon 領袖
	_ok(t.leader_id != -1, "真隊(beast_kind='')被 succession 晉升領袖（got leader_id=%d）" % t.leader_id)
