extends SceneTree
# 農業b TDD — ⑥ 據點結構放大器 pop-cap（乘法）。
# ①據點 level↑→effective_pop_cap↑ ②領導基數為底(無據點/L0=領導帽×1) ③overflow 走 check_overflow_for_team
# ④基數×放大器合理量級。

var _fail := 0
func _ok(c: bool, m: String) -> void:
	if c: print("  PASS ", m)
	else: _fail += 1; print("  FAIL ", m)

func _mk(state: WorldState, tid: int, pos: Vector2i, cmd: float, level: int, ftype: String = "civilian", fac: Dictionary = {}) -> TeamData:
	var ldr := PersonData.new(); ldr.id = tid*10+1; ldr.skills = {"統領": cmd}; state.persons[ldr.id] = ldr
	var team := TeamData.new(); team.team_id = tid; team.leader_id = ldr.id; team.tile_pos = pos
	team.tags = [TeamData.TAG_PRODUCE]
	state.teams[tid] = team
	if level > 0 or fac.size() > 0:
		var t := HexTileData.new()
		t.tile_id = pos.x*1000+pos.y; t.tile_pos = pos; t.terrain = "plains"
		t.outpost_owner = tid; t.outpost_level = level; t.outpost_type = ftype
		for k in fac: t.set(k, fac[k])
		state.world.tiles[t.tile_id] = t
	return team

func _init() -> void:
	print("=== 農業b test ===")
	_t1_level_amplifies()
	_t2_leader_base_L0_hat()
	_t3_facility_bonus()
	_t4_overflow_uses_effective()
	if _fail == 0: print("ALL PASS")
	else: print("FAILS=%d" % _fail)
	quit()

# ① 據點 level↑ → effective_pop_cap↑（放大器生效、乘法）
func _t1_level_amplifies() -> void:
	print("--- ① level↑→cap↑ ---")
	var state := WorldState.new(); state.world = WorldData.new()
	var base := TeamData.pop_cap_from_leadership(0.5)
	var t0 := _mk(state, 0, Vector2i(0,0), 0.5, 0)   # 無據點
	var t1 := _mk(state, 1, Vector2i(1,1), 0.5, 1)
	var t2 := _mk(state, 2, Vector2i(2,2), 0.5, 2)
	var t3 := _mk(state, 3, Vector2i(3,3), 0.5, 3)
	var c0 := FactionAISystem.effective_pop_cap(state, t0)
	var c1 := FactionAISystem.effective_pop_cap(state, t1)
	var c2 := FactionAISystem.effective_pop_cap(state, t2)
	var c3 := FactionAISystem.effective_pop_cap(state, t3)
	_ok(c0 == base, "無據點→effective==領導基數(%d)" % base)
	_ok(c1 > c0 and c2 > c1 and c3 > c2, "level 1<2<3 遞增放大(%d<%d<%d<%d)" % [c0,c1,c2,c3])
	_ok(c1 == int(round(float(base) * (1.0 + 1.0 * FactionAISystem.POP_CAP_AMP_PER_LEVEL))), "L1=base×(1+level×AMP)(乘法)")

# ② 領導基數為底 + L0 不放大（×1 守 S2a 界線）
func _t2_leader_base_L0_hat() -> void:
	print("--- ② 領導基數底 + L0 不放大 ---")
	var state := WorldState.new(); state.world = WorldData.new()
	# 強領導 vs 弱領導（無據點）→ effective 跟基數
	var strong := _mk(state, 0, Vector2i(0,0), 0.8, 0)
	var weak := _mk(state, 1, Vector2i(1,1), 0.15, 0)
	_ok(FactionAISystem.effective_pop_cap(state, strong) == TeamData.pop_cap_from_leadership(0.8), "強領導無據點→領導基數")
	_ok(FactionAISystem.effective_pop_cap(state, weak) == TeamData.pop_cap_from_leadership(0.15), "弱領導無據點→領導基數(領導帽)")
	# L0 camp（camp_level=1、outpost_level=0）→ 放大器×1（守 S2a 界線）
	var l0 := _mk(state, 2, Vector2i(2,2), 0.5, 0)
	var l0tile := HexTileData.new(); l0tile.tile_id = 2002; l0tile.tile_pos = Vector2i(2,2)
	l0tile.outpost_owner = -1; l0tile.outpost_level = 0; l0tile.camp_level = 1
	state.world.tiles[2002] = l0tile
	_ok(FactionAISystem.effective_pop_cap(state, l0) == TeamData.pop_cap_from_leadership(0.5), "★L0(outpost_level=0)→放大器×1=領導帽(S2a 界線守)")

# ③ 設施發展加成（結構函數非死曲線）
func _t3_facility_bonus() -> void:
	print("--- ③ 設施加成 ---")
	var state := WorldState.new(); state.world = WorldData.new()
	var bare := _mk(state, 0, Vector2i(0,0), 0.5, 2)                                   # L2 無設施
	var developed := _mk(state, 1, Vector2i(1,1), 0.5, 2, "civilian", {"farming_level": 3, "manufacturing_level": 2})  # L2 + 設施
	_ok(FactionAISystem.effective_pop_cap(state, developed) > FactionAISystem.effective_pop_cap(state, bare),
		"設施發展→放大器更大(投資回報、%d>%d)" % [FactionAISystem.effective_pop_cap(state, developed), FactionAISystem.effective_pop_cap(state, bare)])

# ④ overflow 走 check_overflow_for_team 用 effective（大據點→cap 高→少 overflow）
func _t4_overflow_uses_effective() -> void:
	print("--- ④ overflow 用 effective ---")
	var state := WorldState.new(); state.world = WorldData.new()
	var team := _mk(state, 0, Vector2i(0,0), 0.5, 3)   # L3 大據點→高 cap
	AnonCohort.add(team.anon_cohorts, "平民", "healthy", 5)   # pop 小
	var cap := FactionAISystem.effective_pop_cap(state, team)
	_ok(cap > 0 and team.population <= cap, "pop(%d) <= effective_cap(%d)（大據點承載）" % [team.population, cap])
	# check_overflow_for_team 不崩、用 effective（pop<cap→無 overflow spinoff）
	var teams_before := state.teams.size()
	PopulationSystem.new().check_overflow_for_team(state, 0)
	_ok(state.teams.size() == teams_before, "pop<=effective_cap→無 overflow 分村（check_overflow 用 effective）")
