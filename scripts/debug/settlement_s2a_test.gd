extends SceneTree
# settlement S2a TDD — L0 營地階梯。
# ①camp_level 欄 + 顯式納 state_fingerprint ②紮營設 camp_level 不設 outpost_level（既有 guard 不誤判）
# ③L0 採腳下 food 池（低倍率、池竭遞減）④棄置 L0_DECAY_DAYS→camp_level=0 無廢墟
# ⑤L0 不入勞力池（無 TAG_PRODUCE）⑥回歸：L0 不被 outpost_system 升級鏈/own_granary 誤觸。

var _fail := 0
func _ok(c: bool, m: String) -> void:
	if c: print("  PASS ", m)
	else: _fail += 1; print("  FAIL ", m)

func _mk_tile(state: WorldState, p: Vector2i, terrain: String = "plains") -> HexTileData:
	var t := HexTileData.new()
	t.tile_id = p.x*1000+p.y; t.tile_pos = p; t.terrain = terrain
	t.outpost_owner = -1; t.outpost_level = 0
	state.world.tiles[t.tile_id] = t
	return t

func _init() -> void:
	print("=== settlement S2a test ===")
	_t1_fp_includes_camp()
	_t2_camp_sets_camp_level_not_outpost()
	_t3_l0_forage_foot_pool()
	_t4_decay_no_ruins()
	_t5_l0_not_in_labor_pool()
	_t6_regression_l0_not_misread()
	if _fail == 0: print("ALL PASS")
	else: print("FAILS=%d" % _fail)
	quit()

# ① camp_level 顯式納 state_fingerprint（L0 變化 fp 可見；純野格仍跳過）
func _t1_fp_includes_camp() -> void:
	print("--- ① camp_level 納 fp ---")
	var state := WorldState.new(); state.world = WorldData.new()
	var t := _mk_tile(state, Vector2i(3,3))
	state.world.current_tick = 100
	var fp0: String = StateFingerprint.compute(state)   # 純野格(level0/無camp/無construction)→跳過
	t.camp_level = 1; t.camp_ticks_left = 720
	var fp1: String = StateFingerprint.compute(state)   # L0→入 fp
	_ok(fp0 != fp1, "camp_level 變化 → fingerprint 變（L0 納 fp、非 determinism 盲點）")
	t.camp_level = 0; t.camp_ticks_left = 0
	var fp2: String = StateFingerprint.compute(state)
	_ok(fp2 == fp0, "camp_level→0 → fp 回純野格（拔營無痕）")

# ② 紮營設 camp_level=1、不設 outpost_level/owner（既有 level==0 guard 不誤判）
func _t2_camp_sets_camp_level_not_outpost() -> void:
	print("--- ② 紮營設 camp_level 不設 level ---")
	var fai := FactionAISystem.new()
	var state := WorldState.new(); state.world = WorldData.new()
	_mk_tile(state, Vector2i(4,4))
	var team := TeamData.new(); team.team_id = 0; team.tile_pos = Vector2i(4,4); team.tags = ["流亡"]
	state.teams[0] = team
	var ok: bool = fai.establish_crude_camp(state, team)
	var tile: HexTileData = state.world.tiles[4004]
	_ok(ok and tile.camp_level == 1, "紮營 → camp_level=1")
	_ok(tile.outpost_level == 0 and tile.outpost_owner == -1, "不設 outpost_level/owner（L0 非據點）")
	_ok(team.tags.has("流亡") and not team.tags.has("生產"), "L0 不清流亡/不升居民 tag")

# ③ L0 採腳下 food 池（低倍率、池竭遞減、走 bank 守恆）
func _t3_l0_forage_foot_pool() -> void:
	print("--- ③ L0 採腳下池 ---")
	var state := WorldState.new(); state.world = WorldData.new()
	var t := _mk_tile(state, Vector2i(5,5))
	t.camp_level = 1; t.camp_ticks_left = 240
	t.resources = {"food": 100.0}; t.resource_cap = {"food": 200.0}
	var ldr := PersonData.new(); ldr.id = 9; ldr.skills = {"生產": 0.0}
	state.persons[9] = ldr
	var team := TeamData.new(); team.team_id = 0; team.leader_id = 9; team.tile_pos = Vector2i(5,5)
	team.population = 5; team.work_morale = 1.0; team.resources = {"food": 0.0}
	state.teams[0] = team
	ResourceSystem.new().collect_resources(state, [0], WorldState.TICKS_PER_DAY)
	var got: float = float(team.resources.get("food", 0))
	var expect: float = 100.0 * ResourceSystem.L0_FORAGE_MULT   # day_fraction=1
	_ok(abs(got - expect) < 1e-3, "L0 採腳下池現量×L0_FORAGE_MULT=%.2f（got=%.2f、無 pop-curve）" % [expect, got])
	_ok(abs(float(t.resources.get("food", 0)) - (100.0 - expect)) < 1e-3, "腳下池守恆遞減（池竭→採量降→遊牧移動湧現）")
	_ok(t.camp_ticks_left == ResourceSystem.L0_DECAY_DAYS * WorldState.TICKS_PER_DAY, "有人 forage → 衰敗計時 reset")

# ④ 棄置 L0_DECAY_DAYS → camp_level=0 無廢墟
func _t4_decay_no_ruins() -> void:
	print("--- ④ 棄置 decay 無廢墟 ---")
	var state := WorldState.new(); state.world = WorldData.new()
	var t := _mk_tile(state, Vector2i(6,6))
	t.camp_level = 1; t.camp_ticks_left = WorldState.TICKS_PER_DAY   # 剩 1 天
	state.world.current_tick = WorldState.TICKS_PER_DAY   # 日邊界（_decay 只在日界跑，但直呼 _decay_l0_camps 無此限）
	var hs := HarvestSystem.new()
	hs._decay_l0_camps(state)   # 無人 forage（未經 collect reset）→ 遞減一天 → <=0
	_ok(t.camp_level == 0, "棄置滿 L0_DECAY_DAYS → camp_level=0")
	_ok(t.outpost_owner == -1 and t.outpost_level == 0 and t.public_storage.is_empty(), "無廢墟（無 owner/outpost/公庫殘留、地圖自清）")

# ⑤ L0 不入勞力池（無 TAG_PRODUCE）
func _t5_l0_not_in_labor_pool() -> void:
	print("--- ⑤ L0 不入勞力池 ---")
	var state := WorldState.new(); state.world = WorldData.new()
	var t := _mk_tile(state, Vector2i(7,7))
	t.camp_level = 1
	# L0 隊（population getter=cohort 派生，此處給 10 平民但無 TAG_PRODUCE → 不入池）
	var l0 := TeamData.new(); l0.team_id = 0; l0.tile_pos = Vector2i(7,7); l0.tags = ["流亡"]
	AnonCohort.add(l0.anon_cohorts, "平民", "healthy", 10)
	state.teams[0] = l0
	_ok(abs(LaborSystem.pool_of(state, t) - 1.0) < 1e-6, "L0 隊(pop10 無 TAG_PRODUCE)不入勞力池（pool=floor 1.0、非 pop10）")
	# 對照：TAG_PRODUCE 隊入池（population 派生自 anon cohort）
	var prod := TeamData.new(); prod.team_id = 1; prod.tile_pos = Vector2i(7,7); prod.tags = [TeamData.TAG_PRODUCE]
	AnonCohort.add(prod.anon_cohorts, "平民", "healthy", 8)
	state.teams[1] = prod
	var pool_with_prod: float = LaborSystem.pool_of(state, t)
	_ok(pool_with_prod >= 8.0, "TAG_PRODUCE 隊入池（對照、pool=%.2f≥8）" % pool_with_prod)

# ⑥ 回歸：L0 不被 outpost_system 升級鏈/own_granary 誤觸（outpost_level==0 哨兵正確擋 L0）
func _t6_regression_l0_not_misread() -> void:
	print("--- ⑥ 回歸 L0 不誤觸 ---")
	var state := WorldState.new(); state.world = WorldData.new()
	var t := _mk_tile(state, Vector2i(8,8))
	t.camp_level = 1
	var team := TeamData.new(); team.team_id = 0; team.tile_pos = Vector2i(8,8)
	state.teams[0] = team
	var os := OutpostSystem.new()
	_ok(not os.start_upgrade_level(state, team), "L0(level0) 不被當可升級 outpost（start_upgrade_level=false）")
	_ok(not os.start_upgrade_facility(state, team, "granary"), "L0 不被當可建設施 outpost")
	_ok(ResourceSystem.own_granary_tile(state, team) == null, "L0 非糧倉（own_granary_tile=null、effective_food 不誤含）")