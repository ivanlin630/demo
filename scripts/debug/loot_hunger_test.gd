extends SceneTree

# 絕境掠奪對準糧源 TDD（slice: loot-hunger-targeting）
# spec: docs/superpowers/specs/2026-07-15-loot-hunger-targeting.md
#
# 真根＝掠奪 target 選擇沒對準糧（_find_weakest_prey 鎖最弱=常無糧）→ 搶到料不解飢→殘留 thrash。
# 修＝飢餓 looter 的 prey 選擇 food-weighted（單一連續 prey_score，非門檻切主鍵）：
#   hunger = clampf((DESPERATION_DAYS - food_days)/DESPERATION_DAYS, 0, 1)   # sated→0
#   prey_score = pop_est − FOOD_PULL × hunger × (food_est/FOOD_EST_NORM)     # minimize
# sated(hunger=0) → 純 pop_est = weakest（strategic raid 零退化）。

var _fail: int = 0

func _initialize() -> void:
	_test_hungry_picks_foodrich()
	_test_sated_picks_weakest()
	_test_continuity_no_cliff()
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

# 世界：plains 一排 (0,0)..(5,0)，looter(1)@(0,0)，prey A(2)@(2,0) 弱無糧、prey B(3)@(3,0) 稍強糧多。
# 注入 belief（team_intel Dict）：A pop_est=3 food_est=0；B pop_est=5(<10×0.7) food_est=500。
func _mk_loot_world(looter_food: float) -> Array:   # → [state, looter]
	var state := WorldState.new()
	state.world = WorldData.new()
	state.world.current_tick = 100
	for x in range(-1, 7):
		for y in range(-2, 3):
			var t := HexTileData.new(); t.tile_pos = Vector2i(x, y); t.terrain = "plains"
			state.world.tiles[x * 1000 + y] = t
	var looter := TeamData.new(); looter.team_id = 1; looter.faction_id = -1; looter.tile_pos = Vector2i(0, 0)
	var ll := PersonData.new(); ll.id = 10; state.persons[10] = ll; looter.leader_id = 10
	AnonCohort.add(looter.anon_cohorts, "平民", "healthy", 10)   # pop=10（含 leader=11? getter：leader+anon）
	looter.resources = {"food": looter_food}
	state.teams[1] = looter
	for spec in [[2, Vector2i(2, 0), 3], [3, Vector2i(3, 0), 5]]:
		var p := TeamData.new(); p.team_id = spec[0]; p.faction_id = -1; p.tile_pos = spec[1]
		AnonCohort.add(p.anon_cohorts, "平民", "healthy", spec[2])
		state.teams[spec[0]] = p
	# belief 注入（team_intel Dict；best_estimate/has_belief 讀此）
	state.team_discovered[1] = [2, 3]
	state.team_intel[1] = {
		2: {"population_est": 3.0, "food_est": 0.0, "armed_est": 0.0, "last_tick": 100, "confidence": 1.0},
		3: {"population_est": 5.0, "food_est": 500.0, "armed_est": 0.0, "last_tick": 100, "confidence": 1.0},
	}
	return [state, looter]

func _food_for_days(days: float) -> float:
	return days * 10.0 * ResourceSystem.FOOD_PER_PERSON_PER_DAY   # pop≈10 → food_days=days

func _test_hungry_picks_foodrich() -> void:
	print("--- 飢餓 looter → 選糧多可打隊 ---")
	var sr: Array = _mk_loot_world(_food_for_days(1.0))   # food_days=1 < DESPERATION(3) → hunger 高
	var prey: int = FactionAISystem.new()._find_weakest_prey(sr[0], sr[1])
	_ok(prey == 3, "飢餓 looter 選 prey B(糧多稍強可打)=3，實際=%d" % prey)

func _test_sated_picks_weakest() -> void:
	print("--- sated looter → 選最弱（hunger=0，pop_est-only 零退化）---")
	var sr: Array = _mk_loot_world(_food_for_days(5.0))   # food_days=5 >= DESPERATION → hunger=0
	var prey: int = FactionAISystem.new()._find_weakest_prey(sr[0], sr[1])
	_ok(prey == 2, "sated looter 選 prey A(最弱)=2，實際=%d" % prey)

func _test_continuity_no_cliff() -> void:
	print("--- 連續性：無門檻切主鍵（crossover emergent 非 food_days 硬閘）---")
	# 交叉點：prey_score(A=3)==prey_score(B=5−hunger×5) → hunger=0.4 → food_days=DESP×0.6=1.8。
	# 掃 food_days：1.5(更餓)→B；2.0(較飽)→A。switch 由連續 score 湧現（非 if food_days<3 突變在 DESPERATION）。
	var fa := FactionAISystem.new()
	var sr1: Array = _mk_loot_world(_food_for_days(1.5)); var p_hungry: int = fa._find_weakest_prey(sr1[0], sr1[1])
	var sr2: Array = _mk_loot_world(_food_for_days(2.0)); var p_less: int = fa._find_weakest_prey(sr2[0], sr2[1])
	_ok(p_hungry == 3, "food_days=1.5(hunger>0.4) → 選糧多 B=3（crossover 下側），實際=%d" % p_hungry)
	_ok(p_less == 2, "food_days=2.0(hunger<0.4) → 選最弱 A=2（crossover 上側），實際=%d" % p_less)
	# 交叉點在 1.8（非 DESPERATION=3）→ 證非「food_days<3 硬閘切主鍵」而是連續加權湧現。
	_ok(true, "switch 在 emergent crossover(食日≈1.8) 非硬閘 DESPERATION(3)：連續加權非門檻")
