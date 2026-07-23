extends SceneTree

# GATE-A 認自家食物源 TDD（spec 2026-07-23-gateA-recognize-productive-home）。
# 根:harvest positional(採站的 tile),離 food-rich home 買糧→home regen 沒人採→餓死在 surplus 平原;
# 返家補給 applicable+restock_need 都綁 granary stock→離家空 granary→回不去 trap。
# 4 touch(同 home_food_productive 信號):①decision_context 算式②返家補給 applicable +OR productive
#   ③restock_need +productive floor④買糧 applicable +not productive(閉商隊 toss-up trap)。

var _fail: int = 0

func _initialize() -> void:
	_test_plains_restock_applicable()   # ①plains 產糧家+空 granary+食低→返家補給 applicable + restock_need=1.0
	_test_forest_buyfood()              # ②forest 家+空 granary→返家補給 applicable=false + 買糧 applicable=true
	_test_granary_stock_drives()        # ③granary 有量+非產糧→restock_need granary_q 主導
	_test_productive_formula()          # ④home_food_productive 算式(plains 產糧/forest 不)
	_test_no_home_false()               # ⑤無 home outpost→productive=false
	_test_buyfood_gate()                # ★⑥買糧 gate:plains(productive)→not applicable;forest→applicable
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

# 構造 ctx（測 applicable/term 邏輯，直設欄位）
func _ctx(productive: bool, home_food: float, food_days: float) -> DecisionContext:
	var c := DecisionContext.new()
	c.has_home_outpost = true
	c.home_food_productive = productive
	c.home_food = home_food
	c.food_days = food_days
	c.has_food_market = true; c.has_specie = true; c.has_buyable_food = true
	c.is_merchant = false
	return c

# gather-based（測算式）：pop 5 → burn=5×0.8=4；plains food 8≥4 產糧、forest 3<4 不產。
func _mk_gather(terrain: String, with_outpost: bool) -> Array:
	var state := WorldState.new(); state.world = WorldData.new(); state.world.current_tick = 1000
	for x in range(3, 8):
		for y in range(3, 8):
			var tl := HexTileData.new(); tl.tile_pos = Vector2i(x, y); tl.terrain = "plains"
			state.world.tiles[x * 1000 + y] = tl
	var team := TeamData.new(); team.team_id = 1; team.tile_pos = Vector2i(5, 5); team.faction_id = 5
	AnonCohort.add(team.anon_cohorts, "平民", "healthy", 5)   # pop 5 → burn 4
	var l := PersonData.new(); l.id = 10; l.values = {"好戰": 0.5, "貪婪": 0.5, "野心": 0.5, "慎重": 0.5}; l.skills = {}
	state.persons[10] = l; team.leader_id = 10
	team.resources["food"] = 100.0
	state.teams[1] = team
	if with_outpost:
		var tile: HexTileData = state.world.tiles[5 * 1000 + 5]
		tile.outpost_owner = 1; tile.outpost_type = "civilian"; tile.outpost_level = 1
		tile.terrain = terrain; tile.harvest_factor = 1.0
	return [state, team]

# ① plains 產糧家 + 空 granary + 食低 → 返家補給 applicable=true、restock_need=1.0（脫空-granary trap）
func _test_plains_restock_applicable() -> void:
	print("--- ①plains 產糧家 空 granary → 返家補給 ---")
	var appl: Callable = DecisionOptions.REGISTRY["返家補給"]["applicable"]
	var c: DecisionContext = _ctx(true, 0.0, 2.0)   # productive + 空 granary + 食低
	_ok(appl.call(c), "plains 產糧家+空 granary+食低 → 返家補給 applicable（非空-granary trap）")
	_ok(is_equal_approx(DecisionTerms.eval("restock_need", c, "返家補給"), 1.0), "restock_need=1.0（產糧家 drive 滿，回去採飽）")

# ② forest 家 + 空 granary → 返家補給 applicable=false + 買糧 applicable=true（forest 正確離家買）
func _test_forest_buyfood() -> void:
	print("--- ②forest 空 granary → 買糧 ---")
	var restock: Callable = DecisionOptions.REGISTRY["返家補給"]["applicable"]
	var buyfood: Callable = DecisionOptions.REGISTRY["買糧"]["applicable"]
	var c: DecisionContext = _ctx(false, 0.0, 2.0)   # 非產糧 + 空 granary
	_ok(not restock.call(c), "forest 非產糧家+空 granary → 返家補給 not applicable（空家不返）")
	_ok(buyfood.call(c), "forest 非產糧家 → 買糧 applicable（正確離家買=多樣性）")

# ③ granary 有量 + 非產糧 → restock_need granary_q 主導（非 productive floor）
func _test_granary_stock_drives() -> void:
	print("--- ③granary stock 主導 ---")
	var c: DecisionContext = _ctx(false, 5.0, 2.0)   # home_food 5 = 半 RESTOCK_MIN、非產糧
	_ok(is_equal_approx(DecisionTerms.eval("restock_need", c, "返家補給"), 0.5), "granary 5/10=0.5 granary_q 主導（非產糧無 floor，got %.2f）" % DecisionTerms.eval("restock_need", c, "返家補給"))

# ④ home_food_productive 算式（gather：plains 產糧 / forest 不產）
func _test_productive_formula() -> void:
	print("--- ④productive 算式 ---")
	var wp: Array = _mk_gather("plains", true)
	var cp: DecisionContext = DecisionContext.gather(wp[0], wp[1])
	_ok(cp.home_food_productive, "plains 家(food 8×1.0=8 ≥ burn 4)→ home_food_productive=true")
	var wf: Array = _mk_gather("forest", true)
	var cf: DecisionContext = DecisionContext.gather(wf[0], wf[1])
	_ok(not cf.home_food_productive, "forest 家(food 3×1.0=3 < burn 4)→ home_food_productive=false")

# ⑤ 無 home outpost → productive=false
func _test_no_home_false() -> void:
	print("--- ⑤無 home outpost→false ---")
	var w: Array = _mk_gather("plains", false)   # 無 outpost
	var c: DecisionContext = DecisionContext.gather(w[0], w[1])
	_ok(not c.home_food_productive, "無 home outpost → home_food_productive=false（無家不判產糧）")

# ★⑥ 買糧 gate：plains(productive)→買糧 not applicable；forest(非)→applicable
func _test_buyfood_gate() -> void:
	print("--- ★⑥買糧 gate（productive 偏好返家）---")
	var buyfood: Callable = DecisionOptions.REGISTRY["買糧"]["applicable"]
	var cp: DecisionContext = _ctx(true, 0.0, 2.0)   # plains productive
	_ok(not buyfood.call(cp), "plains 產糧家 → 買糧 not applicable（結構偏好返家採飽，閉商隊 toss-up trap）")
	var cf: DecisionContext = _ctx(false, 0.0, 2.0)   # forest 非產糧
	_ok(buyfood.call(cf), "forest 非產糧家 → 買糧 applicable（仍離家買=多樣性不誤鎖）")
