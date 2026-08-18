extends SceneTree
# settlement S2b TDD — L0→L1 紮根工期（複用 construction spine）。
# ①站自己 L0 viable→設 construction_target level:1+ticks+TASK_BUILD ②非站 L0/瀕餓不啟
# ③工期 tick 推 ticks 遞減 ④完工→outpost_level=1+owner+camp_level 清0+居民 tag+fp 反映
# ⑤工期中斷=busy-preemptible（TASK_BUILD 可壓境打斷）⑥瀕餓不啟（viability 決策閘）。

var _fail := 0
func _ok(c: bool, m: String) -> void:
	if c: print("  PASS ", m)
	else: _fail += 1; print("  FAIL ", m)

func _mk_l0_team(state: WorldState, pos: Vector2i, food: float, pop: int, martial: float = 0.2) -> TeamData:
	var t := HexTileData.new()
	t.tile_id = pos.x*1000+pos.y; t.tile_pos = pos; t.terrain = "plains"
	t.outpost_owner = -1; t.outpost_level = 0; t.camp_level = 1
	t.camp_ticks_left = ResourceSystem.L0_DECAY_DAYS * WorldState.TICKS_PER_DAY
	state.world.tiles[t.tile_id] = t
	var ldr := PersonData.new(); ldr.id = pos.x*100+pos.y
	ldr.values = {"好戰": martial, "野心": 0.4}
	state.persons[ldr.id] = ldr
	var team := TeamData.new(); team.team_id = pos.x; team.leader_id = ldr.id
	team.tile_pos = pos; team.current_task = TeamData.TASK_IDLE; team.tags = ["流亡"]
	AnonCohort.add(team.anon_cohorts, "平民", "healthy", maxi(pop - 1, 0))
	team.resources = {"food": food}
	state.teams[team.team_id] = team
	return team

func _init() -> void:
	print("=== settlement S2b test ===")
	_t1_viable_starts_corvee()
	_t2_not_started()
	_t3_tick_progresses()
	_t4_complete_to_l1()
	_t5_preemptible()
	if _fail == 0: print("ALL PASS")
	else: print("FAILS=%d" % _fail)
	quit()

# ① 站自己 L0 + viable → 設 construction_target + TASK_BUILD
func _t1_viable_starts_corvee() -> void:
	print("--- ① viable L0 隊起工期 ---")
	var state := WorldState.new(); state.world = WorldData.new()
	var team := _mk_l0_team(state, Vector2i(5,5), 100.0, 5)   # food_days=100/(5*0.8)=25≥CORVEE
	FactionAISystem.new()._evaluate_l0_settle(state, team)
	var tile: HexTileData = state.world.tiles[5005]
	_ok(tile.construction_target.get("action", "") == "crude_camp", "設 construction_target action=crude_camp")
	_ok(int(tile.construction_target.get("level", 0)) == 1 and int(tile.construction_target.get("owner", -1)) == team.team_id, "target level:1 + owner=team")
	_ok(tile.construction_ticks_left == FactionAISystem.L0_TO_L1_CORVEE_DAYS * WorldState.TICKS_PER_DAY, "ticks_left=CORVEE×TICKS")
	_ok(team.current_task == TeamData.TASK_BUILD, "current_task=建設（in-place 自己施工）")
	_ok(tile.camp_level == 1 and tile.outpost_level == 0, "工期中 camp_level 仍 1、outpost_level 仍 0（未完工）")

# ② 非站 L0（camp_level=0）/ 瀕餓 → 不啟
func _t2_not_started() -> void:
	print("--- ② 非 L0 / 瀕餓不啟 ---")
	# (a) 非站 L0：camp_level=0
	var s1 := WorldState.new(); s1.world = WorldData.new()
	var t1 := _mk_l0_team(s1, Vector2i(6,6), 100.0, 5)
	s1.world.tiles[6006].camp_level = 0   # 非 L0（純野格）
	FactionAISystem.new()._evaluate_l0_settle(s1, t1)
	_ok(t1.current_task == TeamData.TASK_IDLE and s1.world.tiles[6006].construction_target.is_empty(), "非站 L0 → 不啟工期")
	# (b) 瀕餓：food_days < CORVEE
	var s2 := WorldState.new(); s2.world = WorldData.new()
	var t2 := _mk_l0_team(s2, Vector2i(7,7), 4.0, 5)   # food_days=4/4=1 < CORVEE=3
	FactionAISystem.new()._evaluate_l0_settle(s2, t2)
	_ok(t2.current_task == TeamData.TASK_IDLE and s2.world.tiles[7007].construction_target.is_empty(), "瀕餓(food_days<CORVEE)→不啟（付不起工期、續遊牧）")

# ③ 工期 tick 推進 → ticks_left 遞減（複用 _tick_construction）
func _t3_tick_progresses() -> void:
	print("--- ③ 工期推進 ---")
	var state := WorldState.new(); state.world = WorldData.new()
	var team := _mk_l0_team(state, Vector2i(8,8), 100.0, 5)
	FactionAISystem.new()._evaluate_l0_settle(state, team)
	var tile: HexTileData = state.world.tiles[8008]
	var before: int = tile.construction_ticks_left
	OutpostSystem.new()._tick_construction(state, tile)
	_ok(tile.construction_ticks_left == before - maxi(team.population, 1), "_tick_construction ticks_left -= pop（複用 spine）")

# ④ 完工 → L1（outpost_level=1+owner+camp_level 清0+居民 tag+fp 反映）
func _t4_complete_to_l1() -> void:
	print("--- ④ 完工晉 L1 ---")
	var state := WorldState.new(); state.world = WorldData.new()
	var team := _mk_l0_team(state, Vector2i(9,9), 100.0, 5, 0.2)   # civilian leader
	FactionAISystem.new()._evaluate_l0_settle(state, team)
	var tile: HexTileData = state.world.tiles[9009]
	var fp_before: String = StateFingerprint.compute(state)
	tile.construction_ticks_left = maxi(team.population, 1)   # 一 tick 即完工
	OutpostSystem.new()._tick_construction(state, tile)
	_ok(tile.outpost_level == 1, "完工 → outpost_level=1")
	_ok(tile.outpost_owner == team.team_id, "set_owner=team（真領土宣稱從 L1 起）")
	_ok(tile.camp_level == 0 and tile.camp_ticks_left == 0, "★L0 消融進 L1（camp_level/ticks 清0、無殘留雙態）")
	_ok(team.tags.has(TeamData.TAG_PRODUCE) and not team.tags.has("流亡"), "升居民 tag（勞力池從 L1 起）+清流亡")
	_ok(StateFingerprint.compute(state) != fp_before, "fp 反映 L0→L1（determinism 可見）")

# ⑤ 工期中斷=busy-preemptible（TASK_BUILD 可壓境打斷 = viability 中斷路）
func _t5_preemptible() -> void:
	print("--- ⑤ 工期可 busy-preempt ---")
	_ok(TeamData.TASK_BUILD in FactionAISystem.PREEMPTIBLE_TASKS, "TASK_BUILD ∈ PREEMPTIBLE_TASKS（壓境威脅可打斷 L0→L1 工期、既有機制）")
