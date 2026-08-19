extends SceneTree
# settlement S2b TDD — L0→L1 紮根工期（複用 construction spine）。
# ①站自己 L0 viable→設 construction_target level:1+ticks+TASK_BUILD ②非站 L0/瀕餓不啟
# ③工期 tick 推 ticks 遞減 ④完工→outpost_level=1+owner+camp_level 清0+居民 tag+fp 反映
# ⑤工期中斷=busy-preemptible（TASK_BUILD 可壓境打斷）⑥瀕餓不啟（viability 決策閘）。

# ★§4a 更新：L0→L1 紮根已入引擎（options.gd「紮根」option + commit-after-success hook），
#   原 standalone _evaluate_l0_settle 已刪 → 本測改走真引擎決策路徑（_evaluate_solo → rank_scored）。
#   ②「瀕餓不啟」改驗 util 過濾（有替代選項時引擎選別的），非硬門檻；另加 ⑧ zombie-race 驗
#   （try_set 失敗 → tile 零殘留）。

var _fail := 0
func _ok(c: bool, m: String) -> void:
	if c: print("  PASS ", m)
	else: _fail += 1; print("  FAIL ", m)

# 走真引擎決策（solo 路：非 unified tag 的流亡隊）。IDLE→_should_reeval 立即評估。
func _engine_decide(state: WorldState, team: TeamData) -> void:
	FactionAISystem.new()._evaluate_solo(state, team)

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
	_t6_abandoned_recovery()
	_t7_orphan_cleanup()
	_t8_no_zombie_on_try_set_fail()
	if _fail == 0: print("ALL PASS")
	else: print("FAILS=%d" % _fail)
	quit()

# ① 站自己 L0 + viable → 設 construction_target + TASK_BUILD
func _t1_viable_starts_corvee() -> void:
	print("--- ① viable L0 隊起工期 ---")
	var state := WorldState.new(); state.world = WorldData.new()
	var team := _mk_l0_team(state, Vector2i(5,5), 100.0, 5)   # food_days=100/(5*0.8)=25≥CORVEE
	_engine_decide(state, team)
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
	_engine_decide(s1, t1)
	# ★engine 化後只斷言「沒起工期」（隊可能被引擎派去做別的，那是同秤競爭的正常結果）。
	_ok(s1.world.tiles[6006].construction_target.is_empty() and s1.world.tiles[6006].construction_team_id == -1,
		"非站 L0（applicable 物理條件不成立）→ 不啟工期")
	# (b) 瀕餓 + 有替代選項（鄰格獵場）→ 可行性帳把紮根 util 壓到近 0，引擎選覓食＝util 過濾非硬門檻
	var s2 := WorldState.new(); s2.world = WorldData.new()
	var t2 := _mk_l0_team(s2, Vector2i(7,7), 2.0, 5)   # food_days=2/4=0.5 ≪ ETA(3 天)
	var _hunt := HexTileData.new()
	_hunt.tile_id = 8007; _hunt.tile_pos = Vector2i(8,7); _hunt.terrain = "plains"
	_hunt.resources = {"wild_game": 40.0}; _hunt.resource_cap = {"wild_game": 40.0}
	s2.world.tiles[_hunt.tile_id] = _hunt
	_engine_decide(s2, t2)
	_ok(s2.world.tiles[7007].construction_target.is_empty() and s2.world.tiles[7007].construction_team_id == -1,
		"瀕餓（runway ≪ 工期 ETA）→ 可行性帳壓低 util → 不開工（無硬門檻，選了覓食：task=%s）" % t2.current_task)

# ③ 工期 tick 推進 → ticks_left 遞減（複用 _tick_construction）
func _t3_tick_progresses() -> void:
	print("--- ③ 工期推進 ---")
	var state := WorldState.new(); state.world = WorldData.new()
	var team := _mk_l0_team(state, Vector2i(8,8), 100.0, 5)
	_engine_decide(state, team)
	var tile: HexTileData = state.world.tiles[8008]
	var before: int = tile.construction_ticks_left
	OutpostSystem.new()._tick_construction(state, tile)
	_ok(tile.construction_ticks_left == before - maxi(team.population, 1), "_tick_construction ticks_left -= pop（複用 spine）")

# ④ 完工 → L1（outpost_level=1+owner+camp_level 清0+居民 tag+fp 反映）
func _t4_complete_to_l1() -> void:
	print("--- ④ 完工晉 L1 ---")
	var state := WorldState.new(); state.world = WorldData.new()
	var team := _mk_l0_team(state, Vector2i(9,9), 100.0, 5, 0.2)   # civilian leader
	_engine_decide(state, team)
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

# ⑥ ★REDO 根修：abandoned-corvee recovery（團離開工地覓食後回頭續建、進度保留、非永久卡死）
func _t6_abandoned_recovery() -> void:
	print("--- ⑥ abandoned-corvee recovery ---")
	var state := WorldState.new(); state.world = WorldData.new()
	var fai := FactionAISystem.new()
	var team := _mk_l0_team(state, Vector2i(11,11), 100.0, 5)
	_engine_decide(state, team)
	var tile: HexTileData = state.world.tiles[11011]
	_ok(team.corvee_site == Vector2i(11,11), "起工期→記工地 corvee_site=(11,11)")
	# 模擬做一段後離開覓食（survival）：推一 tick 進度、team 離工地變 idle（他處）
	OutpostSystem.new()._tick_construction(state, tile)
	var progressed: int = tile.construction_ticks_left
	_ok(progressed < FactionAISystem.L0_TO_L1_CORVEE_DAYS * WorldState.TICKS_PER_DAY, "工期有推進")
	team.current_task = TeamData.TASK_IDLE   # 覓食完 release→idle
	team.tile_pos = Vector2i(13,13)          # 已離工地（覓食走遠）
	team.move_target = Vector2i(-1,-1)
	# recovery：idle + 有未完 corvee + viable → 回頭續建
	_engine_decide(state, team)
	_ok(team.current_task == TeamData.TASK_BUILD, "recovery→回 TASK_BUILD（非永久卡死）")
	_ok(team.move_target == Vector2i(11,11), "move_target=工地（走回續建）")
	_ok(tile.construction_ticks_left == progressed, "進度保留（未 reset、續建非重頭）")
	_ok(tile.construction_team_id == team.team_id, "construction_team_id 仍為起者")

# ⑦ orphan cleanup：施工隊已亡 → _tick_construction 清 zombie construction（非永卡）
func _t7_orphan_cleanup() -> void:
	print("--- ⑦ orphan cleanup ---")
	var state := WorldState.new(); state.world = WorldData.new()
	var fai := FactionAISystem.new()
	var team := _mk_l0_team(state, Vector2i(14,14), 100.0, 5)
	_engine_decide(state, team)
	var tile: HexTileData = state.world.tiles[14014]
	_ok(tile.construction_team_id == team.team_id, "corvee 起（ct_id=team）")
	state.teams.erase(team.team_id)   # 施工隊亡（pop=1 餓死 viability 過濾）
	OutpostSystem.new()._tick_construction(state, tile)
	_ok(tile.construction_team_id == -1 and tile.construction_ticks_left == 0 and tile.construction_target.is_empty(),
		"施工隊亡 → 清 orphan construction（防 zombie 永卡）")

# ⑧ ★zombie-race 根治驗（R² 必查項）：非 idle 隊（committed progressive task + persist 高）站自己 L0，
#   紮根即使進 ranked、try_set 也會被 progressive-hold 擋 → 世界寫入必須一個都沒落地
#   （tile construction_target 空 / construction_team_id 仍 -1 / corvee_site 未被寫）。
func _t8_no_zombie_on_try_set_fail() -> void:
	print("--- ⑧ try_set 失敗 → 零 zombie 殘留 ---")
	var state := WorldState.new(); state.world = WorldData.new()
	var team := _mk_l0_team(state, Vector2i(15,15), 100.0, 5)
	# ★用真的會擋住紮根的路徑：crisis-override 免疫窗（剛被 crisis 釋放 TASK_BUILD → 窗內禁重委派同 task）。
	#   （progressive-hold 那條擋不到紮根：紮根屬 survival@80、hold 只作用於 <PRIO_THREAT 的搶班。）
	state.world.current_tick = 1000
	team.crisis_released_task = TeamData.TASK_BUILD
	team.crisis_released_until = state.world.current_tick + FactionAISystem.CRISIS_IMMUNITY
	var before_task: String = team.current_task
	_engine_decide(state, team)
	var tile: HexTileData = state.world.tiles[15015]
	_ok(team.current_task != TeamData.TASK_BUILD, "crisis 免疫窗擋住紮根 try_set（task=%s、非 BUILD；起始 %s）" % [team.current_task, before_task])
	_ok(tile.construction_target.is_empty(), "★tile construction_target 仍空（to_task 零世界寫入）")
	_ok(tile.construction_team_id == -1, "★tile construction_team_id 仍 -1（無 zombie 工地）")
	_ok(tile.construction_ticks_left == 0, "★tile construction_ticks_left 仍 0")
	_ok(team.corvee_site == Vector2i(-1, -1), "★corvee_site 未被寫（commit-hook 只在 try_set 成功後）")
