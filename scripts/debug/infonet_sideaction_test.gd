extends SceneTree

# 資訊網 Part2 (a) side-action TDD（spec 2026-08-04-infonet-part2-side-action-HOW）。
# 求援/偵察 脫主 argmax→平行 side-dispatch（mini-util cost-benefit、人格 MODULATE）。
# 守:主 argmax 零改（REGISTRY 無求援/偵察）/mini-util genuine 非 crank（RELIEF_EXPECT·ANON_COST 錨食物常數）/
#   anon 零特權/throttle 一隊一/零新 randf。

var _fail: int = 0

func _initialize() -> void:
	seed(1337)
	_test_argmax_neutral()          # ①主 argmax 零改:求援/偵察 不在 REGISTRY 主池
	_test_miniutil_pragmatic_fires() # ②深餓務實→mini-util>0 派 herald
	_test_miniutil_proud_holds()    # ③深餓傲慢→mini-util<0 不派（傲慢撐死 emergent、genuine 分化）
	_test_miniutil_mild_hunger_no() # ④輕度餓→mini-util<0 不派（cost-benefit 不值 1 anon）
	_test_throttle_one_inflight()   # ⑤已 in-flight herald→不重派（throttle）
	_test_scout_side_anon()         # ⑥領主子民陳舊→anon scout side-dispatch
	if _fail == 0: print("=== DONE === ALL PASS")
	else: print("=== DONE === %d FAIL" % _fail)
	quit()

func _ok(c: bool, m: String) -> void:
	if c: print("  [PASS] %s" % m)
	else: _fail += 1; print("  [FAIL] %s" % m)

# 建 faction 0:領主固定 outpost@(9,9) + resident@(5,5) food/人格 依參。
func _mk(res_food: float, vals: Dictionary) -> Array:
	var state := WorldState.new(); state.world = WorldData.new(); state.world.current_tick = 1000
	var fac := FactionData.new(); fac.faction_id = 0; fac.leader_team_id = 1; state.factions[0] = fac
	var lt := HexTileData.new(); lt.tile_pos = Vector2i(9,9); lt.outpost_level = 1; lt.outpost_owner = 1
	state.world.tiles[9*1000+9] = lt
	var lord := TeamData.new(); lord.team_id = 1; lord.faction_id = 0; lord.tile_pos = Vector2i(9,9)
	AnonCohort.add(lord.anon_cohorts, "平民", "healthy", 20); state.teams[1] = lord
	var r := TeamData.new(); r.team_id = 2; r.faction_id = 0; r.tile_pos = Vector2i(5,5); r.tags = [TeamData.TAG_PRODUCE]
	AnonCohort.add(r.anon_cohorts, "平民", "healthy", 5); r.resources = {"food": res_food}
	var lr := PersonData.new(); lr.id = 12; lr.values = vals; state.persons[12] = lr; r.leader_id = 12
	state.teams[2] = r
	return [state, r]

func _herald_fired(state: WorldState, r: TeamData) -> int:
	Probe.reset(); Probe.enabled = true
	FactionAISystem.new()._try_herald_side(state, r)
	Probe.enabled = false
	return int(Probe.counts.get("help.herald_dispatched", 0))

# ① 主 argmax 零改：求援/偵察 不再在 REGISTRY 主池（determinism-neutral 移除 loser）。
func _test_argmax_neutral() -> void:
	print("--- ①主 argmax 零改（REGISTRY 無求援/偵察）---")
	_ok(not DecisionOptions.REGISTRY.has("求援") and not DecisionOptions.REGISTRY.has("偵察"),
		"REGISTRY 移除求援/偵察（脫主 argmax→side-action；主 winner 不變）")

# ② 深餓 + 務實(求生欲1/野心0) → mini-util>0 派 herald。
func _test_miniutil_pragmatic_fires() -> void:
	print("--- ②深餓務實→派 herald ---")
	var a := _mk(0.2, {"求生欲": 1.0, "野心": 0.0, "義氣": 0.6})   # food_days≈0.05 深餓
	_ok(_herald_fired(a[0], a[1]) == 1, "深餓務實 → mini-util>0 派 anon herald（平行 side-action、不佔主任務）")

# ③ 深餓 + 傲慢(野心1/求生欲0) → mini-util<0 不派（傲慢撐、genuine 人格分化）。
func _test_miniutil_proud_holds() -> void:
	print("--- ③深餓傲慢→不派（傲慢撐）---")
	var a := _mk(0.2, {"求生欲": 0.0, "野心": 1.0, "義氣": 0.6})
	_ok(_herald_fired(a[0], a[1]) == 0, "深餓傲慢 → mini-util<0 不開口求（傲慢撐死 emergent、genuine 非 crank）")

# ④ 輕度餓(food_days≈2.5) → mini-util<0 不派（cost-benefit 不值 1 anon）。
func _test_miniutil_mild_hunger_no() -> void:
	print("--- ④輕度餓→不派 ---")
	var a := _mk(2.5 * 5.0 * ResourceSystem.FOOD_PER_PERSON_PER_DAY, {"求生欲": 1.0, "野心": 0.0, "義氣": 0.6})  # food_days≈2.5
	_ok(_herald_fired(a[0], a[1]) == 0, "輕度餓(severity 低) → mini-util<0 不派（cost-benefit、不絕境不值送 anon）")

# ⑤ throttle：已有 in-flight help_call 子隊 → 不重派。
func _test_throttle_one_inflight() -> void:
	print("--- ⑤throttle 一隊一 in-flight ---")
	var a := _mk(0.2, {"求生欲": 1.0, "野心": 0.0, "義氣": 0.6}); var state: WorldState = a[0]; var r: TeamData = a[1]
	FactionAISystem.new()._try_herald_side(state, r)   # 第一次派出
	var fired2: int = _herald_fired(state, r)   # 第二次（已 in-flight）
	_ok(fired2 == 0, "已 in-flight herald → 不重派（throttle 一隊一、鏡射 convoy；second dispatched=%d）" % fired2)

# ⑥ scout side-dispatch：領主對子民 belief 陳舊 → anon scout 派出。
func _test_scout_side_anon() -> void:
	print("--- ⑥scout side-dispatch anon ---")
	var state := WorldState.new(); state.world = WorldData.new(); state.world.current_tick = 100000
	var fac := FactionData.new(); fac.faction_id = 0; fac.leader_team_id = 1; state.factions[0] = fac
	var lord := TeamData.new(); lord.team_id = 1; lord.faction_id = 0; lord.tile_pos = Vector2i(5,5)
	AnonCohort.add(lord.anon_cohorts, "平民", "healthy", 20)
	var ll := PersonData.new(); ll.id = 11; ll.values = {"統領": 1.0, "野心": 0.0}; state.persons[11] = ll; lord.leader_id = 11
	state.teams[1] = lord
	var st := HexTileData.new(); st.tile_pos = Vector2i(8,8); st.outpost_level = 1; st.outpost_owner = 2
	state.world.tiles[8*1000+8] = st
	var sub := TeamData.new(); sub.team_id = 2; sub.faction_id = 0; sub.tile_pos = Vector2i(8,8)
	AnonCohort.add(sub.anon_cohorts, "平民", "healthy", 10); state.teams[2] = sub
	Probe.reset(); Probe.enabled = true
	FactionAISystem.new()._try_scout_side(state, lord)
	Probe.enabled = false
	_ok(int(Probe.counts.get("scout.dispatched", 0)) == 1, "領主子民 belief 陳舊(名冊)→ anon scout side-dispatch（dispatched=%d）" % int(Probe.counts.get("scout.dispatched",0)))
