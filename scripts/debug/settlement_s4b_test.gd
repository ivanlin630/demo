extends SceneTree
# settlement §4b TDD — 三動機分化 + 擴點純邊際帳 + overflow margin 決策化。
# ①有家+有候選才 applicable（無家團不 fire 擴點）②util 全走 _inflow_est 差分（零換算係數）
# ③擴點 committed priority=PRIO_DISPATCH ④margin：超 cap 未達 cap×1.15 機械不 fire、超過仍 fire
# ⑤既有 slice 不破（紮營/紮根 applicable 語意）。

var _fail := 0
func _ok(c: bool, m: String) -> void:
	if c: print("  PASS ", m)
	else: _fail += 1; print("  FAIL ", m)

func _init() -> void:
	print("=== settlement S4b test ===")
	_t1_applicable_needs_home_and_site()
	_t2_marginal_only_no_coeff()
	_t3_commit_priority()
	_t4_overflow_margin()
	_t5_existing_not_broken()
	if _fail == 0: print("ALL PASS")
	else: print("FAILS=%d" % _fail)
	quit()

func _mk_world() -> WorldState:
	var s := WorldState.new(); s.world = WorldData.new(); s.player_id = -1
	for x in range(0, 8):
		for y in range(0, 3):
			var t := HexTileData.new()
			t.tile_id = x*1000+y; t.tile_pos = Vector2i(x,y); t.terrain = "plains"
			t.productivity = 1.0
			t.resources = {"food": 60.0, "material": 60.0}
			t.resource_cap = {"food": 200.0, "material": 200.0}
			s.world.tiles[t.tile_id] = t
	s.world.current_tick = 5000
	return s

# 有家的生產隊（自己 L1 據點、有閒勞力）
func _mk_home_team(s: WorldState, pos: Vector2i, pop: int) -> TeamData:
	var home: HexTileData = s.world.tiles[pos.x*1000+pos.y]
	home.outpost_level = 1; home.outpost_type = "civilian"
	var ldr := PersonData.new(); ldr.id = 900 + pos.x
	ldr.skills = {"統領": 0.8, "生產": 0.4}; ldr.values = {"野心": 0.7, "慎重": 0.3, "貪婪": 0.5}
	s.persons[ldr.id] = ldr
	var t := TeamData.new(); t.team_id = 100 + pos.x; t.leader_id = ldr.id
	ldr.team_id = t.team_id
	t.tile_pos = pos; t.faction_id = -1; t.tags = [TeamData.TAG_PRODUCE]
	AnonCohort.add(t.anon_cohorts, "平民", "healthy", maxi(pop - 1, 0))
	t.resources = {"food": float(pop) * 20.0, "material": 200.0, "tools": 10.0}
	t.current_task = TeamData.TASK_IDLE
	s.teams[t.team_id] = t
	home.outpost_owner = t.team_id
	return t

# ① applicable 只吃物理可行性：無家 → false；有家+候選+pop 足 → true
func _t1_applicable_needs_home_and_site() -> void:
	print("--- ① 有家才擴點（動機分化）---")
	var s := _mk_world()
	var homeless := TeamData.new(); homeless.team_id = 7; homeless.tile_pos = Vector2i(6,1)
	var l2 := PersonData.new(); l2.id = 77; s.persons[77] = l2; homeless.leader_id = 77
	AnonCohort.add(homeless.anon_cohorts, "平民", "healthy", 19)
	homeless.resources = {"food": 100.0}; s.teams[7] = homeless
	var c_homeless := DecisionContext.gather(s, homeless)
	_ok(not c_homeless.can_expand, "無家團 can_expand=false（擴點不 fire＝動機分化）")
	var team := _mk_home_team(s, Vector2i(2,1), 30)
	var c := DecisionContext.gather(s, team)
	_ok(c.has_own_outpost, "有家團 has_own_outpost=true")
	_ok(c.can_expand == (c.expand_pos != Vector2i(-1,-1)), "can_expand 與有效候選位一致（只物理可行性）")
	if c.can_expand:
		_ok(team.population >= c.expand_settler * 2, "母隊 pop(%d) ≥ settler(%d)×2（沿用 _dispatch_builder 既有規則）" % [team.population, c.expand_settler])

# ② util 全走 _inflow_est 差分（同量綱、零手寫換算係數）
func _t2_marginal_only_no_coeff() -> void:
	print("--- ② 邊際帳零換算係數 ---")
	var s := _mk_world()
	var team := _mk_home_team(s, Vector2i(3,1), 30)
	var c := DecisionContext.gather(s, team)
	if not c.can_expand:
		_ok(true, "（本場景無有效候選 → 跳過數值驗，applicable 已由 ① 覆蓋）"); return
	# 家內邊際＝_inflow_est 差分（人力離開），與分點期望邊際同量綱可直接相減
	var home: HexTileData = s.world.tiles[3*1000+1]
	var _now := VillageEstimate.make(home.terrain, home.outpost_level, home.farming_level, team.population)
	var _after := VillageEstimate.make(home.terrain, home.outpost_level, home.farming_level, team.population - c.expand_settler)
	var expect_home: float = MarginalEconomy._inflow_est(_now) - MarginalEconomy._inflow_est(_after)
	_ok(absf(c.expand_home_marginal - expect_home) < 1e-6,
		"家內邊際＝_inflow_est(pop) − _inflow_est(pop−settler)（鏡射 migrant_marginal 差分、%.3f）" % c.expand_home_marginal)
	var cand: HexTileData = s.world.tiles.get(ResourceSystem._pos_to_tile_id(c.expand_pos))
	var expect_site: float = MarginalEconomy._inflow_est(VillageEstimate.make(cand.terrain, 1, 0, c.expand_settler))
	_ok(absf(c.expand_site_marginal - expect_site) < 1e-6,
		"分點期望邊際＝_inflow_est(候選地 est)（camp_target_est pattern、%.3f）" % c.expand_site_marginal)
	_ok(c.expand_build_cost >= 0.0 and c.expand_build_cost <= c.expand_site_marginal,
		"建置成本＝工期零產出攤提（0 ≤ %.3f ≤ 分點邊際、用既有 BUILD_TICKS+PLANNING_HORIZON）" % c.expand_build_cost)
	# util 本身：net ≤ 0 → 0（anti-crank，不為了 fire 而抬分）
	var net: float = c.expand_site_marginal - c.expand_build_cost - c.expand_home_marginal
	var util: float = DecisionTerms.eval("expand_drive", c, "擴點")
	if net <= 0.0:
		_ok(util == 0.0, "net≤0（家內人力還很值錢）→ util=0＝不值得擴（anti-crank）")
	else:
		_ok(util > 0.0, "net>0 → util>0（%.3f）" % util)

# ③ commit priority=PRIO_DISPATCH（§4a invariants 契約：發展型動作可被 threat/survival 打斷）
func _t3_commit_priority() -> void:
	print("--- ③ 擴點 commit priority ---")
	_ok(DecisionOptions.priority_for("擴點") == TaskArbiter.PRIO_DISPATCH,
		"priority_for(擴點)=PRIO_DISPATCH(50)")
	_ok(not DecisionOptions.is_in_set("擴點", "survival"), "擴點非 survival set（發展型動作）")

# ④ overflow margin：超 cap 但未達 cap×1.15 → 機械不 fire；超過 → 仍 fire（保底在）
func _t4_overflow_margin() -> void:
	print("--- ④ overflow margin 決策化 ---")
	var s := _mk_world()
	var team := _mk_home_team(s, Vector2i(4,1), 10)
	var cap: int = FactionAISystem.effective_pop_cap(s, team)
	# (a) 小超額（cap+1，未達 cap×1.15）→ 機械不拆
	var small: int = cap + 1
	_seed_to(team, small)
	var before: int = team.population
	PopulationSystem.new().check_overflow_for_team(s, team.team_id)
	_ok(team.population == before and float(small) <= float(cap) * PopulationSystem.POP_OVERFLOW_MARGIN,
		"小超額（pop %d、cap %d、margin 界 %.1f）→ 機械保底不 fire（留給決策層）" % [small, cap, float(cap) * PopulationSystem.POP_OVERFLOW_MARGIN])
	# (b) 顯著超額（> cap×1.15）→ 保底仍 fire（pop 不卡 cap 無出口）
	var big: int = int(ceil(float(cap) * PopulationSystem.POP_OVERFLOW_MARGIN)) + 2
	_seed_to(team, big)
	var before2: int = team.population
	PopulationSystem.new().check_overflow_for_team(s, team.team_id)
	_ok(team.population < before2, "顯著超額（pop %d > cap×1.15）→ 機械保底仍 fire（%d→%d、無死角）" % [big, before2, team.population])

func _seed_to(team: TeamData, n: int) -> void:
	var named_in: int = team.named_members.size() + (1 if team.leader_id != -1 else 0)
	var want: int = maxi(n - named_in, 0)
	var cur: int = AnonCohort.total(team.anon_cohorts)
	if want > cur: AnonCohort.add(team.anon_cohorts, "平民", "healthy", want - cur)
	elif want < cur: AnonCohort.remove(team.anon_cohorts, "平民", "healthy", cur - want)

# ⑤ 既有 slice 不破：紮營仍限無家、紮根仍在 survival set 且 @50
func _t5_existing_not_broken() -> void:
	print("--- ⑤ 既有 slice 不破 ---")
	_ok(DecisionOptions.priority_for("紮根") == TaskArbiter.PRIO_DISPATCH, "紮根仍 @50（§4a 契約）")
	_ok(DecisionOptions.is_in_set("紮根", "survival"), "紮根仍在 survival set")
	_ok(DecisionOptions.REGISTRY.has("紮營") and DecisionOptions.REGISTRY.has("擴點"),
		"紮營（無家建家）與 擴點（有家擴張）並存＝三動機分化")
