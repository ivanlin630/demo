extends SceneTree

# 糧流 Slice B1 TDD（HOW spec 2026-07-29 §2）：糧橋 go/no-go + 通用 food top-up（解 A1 子隊餓死）。

var _fail: int = 0

func _initialize() -> void:
	_test_no_go_when_starved()   # 母隊 food 不足 → no-go（別派餓死）
	_test_go_and_topup()         # 母隊 food 足 → go + 子隊 topped up 到 need（sub.resources.food）
	_test_carry_not_food()       # ★測 sub.resources.food（非 carry_capacity 空放行）
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

# 母隊在自家 outpost、pop 足(≥12)、material/tools 足；food 由參數。target 遠(forest)。
func _mk(food: float) -> Array:
	var state := WorldState.new(); state.world = WorldData.new(); state.world.current_tick = 1000
	for x in range(0, 12):
		for y in range(0, 12):
			var tl := HexTileData.new(); tl.tile_pos = Vector2i(x, y); tl.terrain = "plains"
			state.world.tiles[x * 1000 + y] = tl
	var home: HexTileData = state.world.tiles[0]
	home.outpost_owner = 0; home.outpost_type = "civilian"; home.outpost_level = 1
	var team := TeamData.new(); team.team_id = 0; team.tile_pos = Vector2i(0, 0); team.faction_id = 10
	AnonCohort.add(team.anon_cohorts, "平民", "healthy", 30); team.armed_anon_ratio = 0.0
	team.resources["material"] = 300.0; team.resources["tools"] = 20.0; team.resources["food"] = food
	var l := PersonData.new(); l.id = 100; l.skills = {"統領": 0.5}; l.values = {}
	state.persons[100] = l; team.leader_id = 100; team.named_members = [100]
	var adv := PersonData.new(); adv.id = 101; state.persons[101] = adv
	state.teams[0] = team
	return [state, team]

func _test_no_go_when_starved() -> void:
	print("--- ①no-go when 母隊 food 不足 ---")
	var w: Array = _mk(5.0)   # food 5 << need(burn×ETA~130)
	var fai := FactionAISystem.new()
	var ok: bool = fai._dispatch_builder(w[0], w[1], Vector2i(8, 4), "civilian", 1)
	_ok(not ok, "母隊 food 5 < 需糧 → no-go（別派餓死途中 dissolve=A1 victim 防）")

func _test_go_and_topup() -> void:
	print("--- ②go + 子隊 top-up ---")
	var w: Array = _mk(500.0); var state: WorldState = w[0]
	var fai := FactionAISystem.new()
	var ok: bool = fai._dispatch_builder(state, w[1], Vector2i(8, 4), "civilian", 1)
	_ok(ok, "母隊 food 500 足 → go（派建造子隊）")
	# 找子隊，驗 food topped up 到 need（burn×ETA，遠超 frac-split）
	var sub: TeamData = null
	for tid in state.teams:
		if state.teams[tid].parent_team_id == 0: sub = state.teams[tid]
	if sub == null:
		_ok(false, "子隊建立"); return
	var burn: float = float(sub.population) * ResourceSystem.FOOD_PER_PERSON_PER_DAY
	_ok(sub.resources.get("food", 0) >= burn * 5.0,
		"★子隊 sub.resources.food=%.0f topped up 到夠 burn×ETA（撐得到抵達+建成不餓死）" % float(sub.resources.get("food", 0)))

func _test_carry_not_food() -> void:
	print("--- ③測 sub.resources.food 非 carry_capacity ---")
	# food 剛好在「carry_capacity 遠超但實際 food 不足」區：food 20（carry 上限 pop×10=120≫20）
	# 若 gate 用 carry 空放行→會 go；用 sub.resources.food→need~130>可撥(20+母隊少)→no-go。
	var w: Array = _mk(20.0); var state: WorldState = w[0]
	var fai := FactionAISystem.new()
	var ok: bool = fai._dispatch_builder(state, w[1], Vector2i(8, 4), "civilian", 1)
	_ok(not ok, "母隊實際 food 20(carry 上限≫此)→用 sub.resources.food 判 no-go（非 carry 空放行假陰性）")
