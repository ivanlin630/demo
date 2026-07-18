extends SceneTree

# slice2 感知鐵律一致 TDD（spec 2026-07-18-consistency-application-invite-buyfood Part A）。
# 3 fix 皆 god-view→belief：A1 threat-move→belief_pos / A2 absorb→belief-gate / A3 invite 距離用 belief_pos。

var _fail: int = 0

func _initialize() -> void:
	_test_a1_threat_pos_belief()
	_test_a2_absorb_belief_gate()
	_test_a3_invite_belief_distance()
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

func _mk_leader(state: WorldState, team: TeamData, lid: int) -> void:
	var ldr := PersonData.new(); ldr.id = lid; state.persons[lid] = ldr; team.leader_id = lid

# ── A1：threat DEFEND/求和 move target = belief last-seen（非 live 瞬鎖）──
func _test_a1_threat_pos_belief() -> void:
	print("--- A1：threat_pos = belief last-seen（非 live）---")
	var state := WorldState.new(); state.world = WorldData.new(); state.world.current_tick = 100000
	var f5 := FactionData.new(); f5.faction_id = 5; state.factions[5] = f5
	var f6 := FactionData.new(); f6.faction_id = 6; state.factions[6] = f6
	var obs := TeamData.new(); obs.team_id = 1; obs.faction_id = 5; obs.tile_pos = Vector2i(0, 0)
	AnonCohort.add(obs.anon_cohorts, "平民", "healthy", 5); state.teams[1] = obs; _mk_leader(state, obs, 10)
	# 敵 live @(3,0)（dist 3<5 → threat 有分），belief last-seen @(1,1)（不同）
	var tgt := TeamData.new(); tgt.team_id = 2; tgt.faction_id = 6; tgt.tile_pos = Vector2i(3, 0)
	AnonCohort.add(tgt.anon_cohorts, "平民", "healthy", 8); state.teams[2] = tgt
	state.team_discovered[1] = [2]
	obs.known_reputations[2] = 0.0   # 敵意（hostility=1）→ threat 有分
	state.team_intel[1] = {2: {"population_est": 8.0, "tile_pos": Vector2i(1, 1), "last_tick": 100000}}
	var c := DecisionContext.gather(state, obs)
	_ok(c.threat_id == 2, "threat 登記 team2（前提，threat_id=%d）" % c.threat_id)
	_ok(c.threat_pos == Vector2i(1, 1), "threat_pos = belief last-seen(1,1) 非 live(3,0)，實際=%s" % str(c.threat_pos))

# ── A2：absorb → belief-gate（無 belief→yield 0，不 god-view 直讀）──
func _test_a2_absorb_belief_gate() -> void:
	print("--- A2：absorb_yield belief-gate（無 belief→0，有→pop_est proxy）---")
	# 無 belief：absorb_target 有 cache 但 obs 無 team_intel → has_belief false → yield 0（不 god-view 直讀 effective_food）
	var s1 := WorldState.new(); s1.world = WorldData.new(); s1.world.current_tick = 100000
	var f5 := FactionData.new(); f5.faction_id = 5; s1.factions[5] = f5
	var a := TeamData.new(); a.team_id = 1; a.faction_id = 5; a.tile_pos = Vector2i(0, 0); a.parent_team_id = -1
	AnonCohort.add(a.anon_cohorts, "平民", "healthy", 10); s1.teams[1] = a; _mk_leader(s1, a, 10)
	a.absorb_target_cache = 2; a.consolidate_eval_next_tick = 999999   # 用 cache 不重算
	var wk := TeamData.new(); wk.team_id = 2; wk.faction_id = 6; wk.tile_pos = Vector2i(2, 0)
	AnonCohort.add(wk.anon_cohorts, "平民", "healthy", 6)
	wk.resources["food"] = 500.0   # god-view 若直讀 effective_food 會給正 yield（RED 對照）
	s1.teams[2] = wk; s1.team_discovered[1] = [2]
	var c1 := DecisionContext.gather(s1, a)
	_ok(c1.absorb_target_id == 2, "absorb_target=2（前提）")
	_ok(is_equal_approx(c1.absorb_yield, 0.0), "無 belief → absorb_yield=0（不 god-view 直讀 effective_food），實際=%.2f" % c1.absorb_yield)
	# 有 belief：team_intel 給 population_est → yield 從 pop_est proxy（>0，仍 fire）
	s1.team_intel[1] = {2: {"population_est": 10.0, "tile_pos": Vector2i(2, 0), "last_tick": 100000}}
	var c2 := DecisionContext.gather(s1, a)
	_ok(c2.absorb_yield > 0.0, "有 belief → absorb_yield>0（pop_est proxy，併入仍 fire），實際=%.2f" % c2.absorb_yield)

# ── A3：invite 距離 gate 用 belief_pos（跨圖 belief→擋，不邀）──
func _test_a3_invite_belief_distance() -> void:
	print("--- A3：invite 距離 gate 用 belief_pos（遠 belief→擋，近→處理）---")
	var state := WorldState.new(); state.world = WorldData.new(); state.world.current_tick = 100000
	# tile world 供 hex/path
	for x in range(-1, 30):
		for y in range(-3, 3):
			var tl := HexTileData.new(); tl.tile_pos = Vector2i(x, y); tl.terrain = "plains"
			state.world.tiles[x * 1000 + y] = tl
	var f5 := FactionData.new(); f5.faction_id = 5; state.factions[5] = f5
	var owner := TeamData.new(); owner.team_id = 1; owner.faction_id = 5; owner.tile_pos = Vector2i(0, 0)
	AnonCohort.add(owner.anon_cohorts, "平民", "healthy", 10); state.teams[1] = owner; _mk_leader(state, owner, 10)
	# exile 遠(2)：belief last-seen @(25,0)（跨圖 > INVITE_RANGE）；exile 近(3)：belief @(2,0)
	var ex_far := TeamData.new(); ex_far.team_id = 2; ex_far.faction_id = 6; ex_far.tile_pos = Vector2i(25, 0)
	ex_far.tags = ["流亡"]; AnonCohort.add(ex_far.anon_cohorts, "平民", "healthy", 4); state.teams[2] = ex_far; _mk_leader(state, ex_far, 20)
	var ex_near := TeamData.new(); ex_near.team_id = 3; ex_near.faction_id = 7; ex_near.tile_pos = Vector2i(2, 0)
	ex_near.tags = ["流亡"]; AnonCohort.add(ex_near.anon_cohorts, "平民", "healthy", 4); state.teams[3] = ex_near; _mk_leader(state, ex_near, 30)
	var f6 := FactionData.new(); f6.faction_id = 6; state.factions[6] = f6
	var f7 := FactionData.new(); f7.faction_id = 7; state.factions[7] = f7
	state.team_discovered[1] = [2, 3]
	state.team_intel[1] = {
		2: {"population_est": 4.0, "tile_pos": Vector2i(25, 0), "last_tick": 100000},
		3: {"population_est": 4.0, "tile_pos": Vector2i(2, 0), "last_tick": 100000}}
	var tile: HexTileData = state.world.tiles[0]   # (0,0) outpost tile placeholder
	FactionAISystem.new()._try_invite_nearby_exile(state, owner, tile)
	# 遠 belief → gate 擋（continue before diplomacy/cooldown-write）→ 無 cooldown entry
	_ok(not owner.invite_cooldown.has(2), "遠 belief(25,0)>INVITE_RANGE → 擋（未達 cooldown-write），cooldown.has(2)=%s" % str(owner.invite_cooldown.has(2)))
	# 近 belief → 處理（達 diplomacy → 寫 cooldown，不論 accept/reject）
	_ok(owner.invite_cooldown.has(3), "近 belief(2,0) → 處理達 diplomacy（寫 cooldown），cooldown.has(3)=%s" % str(owner.invite_cooldown.has(3)))
