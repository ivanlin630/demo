extends SceneTree
# @bed-kind: acceptance
# slice: GATE-A 二刀（home gate／productive／granary 主導）
#   ★沒有接上任何閘（接不接電是 systems 的裁量，見 2026-09-09 handback）。

# GATE-A 認自家食物源 TDD（spec 2026-07-23-gateA-recognize-productive-home）。
# 根:harvest positional(採站的 tile),離 food-rich home 買糧→home regen 沒人採→餓死在 surplus 平原;
# 返家補給 applicable+restock_need 都綁 granary stock→離家空 granary→回不去 trap。
# 4 touch(同 home_food_productive 信號):①decision_context 算式②返家補給 applicable +OR productive
#   ③restock_need +productive floor④買糧 applicable +not productive(閉商隊 toss-up trap)。

var _fail: int = 0
const EXPECTED_CELLS: Array = ["_test_plains_restock_applicable", "_test_forest_buyfood", "_test_granary_stock_drives", "_test_productive_formula", "_test_no_home_false", "_test_buyfood_gate"]

# ★★★【到場點名 ＋ 陽性對照】（systems 派工；樣板同 `constitution_gate` 第一批）——
#   ★病：GDScript 的執行期錯誤**只中止那一支 func**（coroutine 也一樣，`await` 不保護）⇒
#     床照樣跑到最後、照樣印通過橫幅，而 runner 只看 exit code 與 expect ⇒ **兩者都通過**。
#   ★★修法：每一格【自己的最後一行】打卡，末尾對名單，**少一格就把橫幅變成 FAIL**。
#   ★★★用法必須是 `_selftest_gate("格名").noop()` —— 死亡要發生在【那一格自己的 frame】裡
#     （★血證：放進被呼叫的 helper 裡 ⇒ 中止的是 helper、那一格照樣跑完 ⇒ 會誤判成「這裡沒有洞」）。
var _cells_ran: Array = []

func _cell(name: String) -> void:
	if not _cells_ran.has(name):
		_cells_ran.append(name)

func noop() -> void:
	pass

func _selftest_gate(cell: String) -> Object:
	if OS.get_environment("BED_SELFTEST_DIE") != cell:
		return self
	print("[SELFTEST] ★故意讓 `%s` 這一格在中途死掉" % cell)
	return null

func _roll_call_missing() -> Array:
	var missing: Array = []
	for c in EXPECTED_CELLS:
		if not _cells_ran.has(c): missing.append(c)
	if not missing.is_empty():
		print("[roll-call] ❌ ★**有格沒有跑完**：%s —— 執行期錯誤會靜默中止一支 func，而那看起來像綠" % str(missing))
	return missing

func _initialize() -> void:
	_test_plains_restock_applicable()   # ①plains 產糧家+空 granary+食低→返家補給 applicable + restock_need=1.0
	_test_forest_buyfood()              # ②forest 家+空 granary→返家補給 applicable=false + 買糧 applicable=true
	_test_granary_stock_drives()        # ③granary 有量+非產糧→restock_need granary_q 主導
	_test_productive_formula()          # ④home_food_productive 算式(plains 產糧/forest 不)
	_test_no_home_false()               # ⑤無 home outpost→productive=false
	_test_buyfood_gate()                # ★⑥買糧 gate:plains(productive)→not applicable;forest→applicable
	var _miss: Array = _roll_call_missing()
	var _suffix: String = "｜到場點名 %d／%d" % [_cells_ran.size(), EXPECTED_CELLS.size()]
	if _fail == 0 and _miss.is_empty():
		print("=== DONE === ALL PASS%s" % _suffix)
	elif not _miss.is_empty():
		print("=== DONE === %d FAIL（★其中有格沒有執行）%s" % [_fail + _miss.size(), _suffix])
	else:
		print("=== DONE === %d FAIL%s" % [_fail, _suffix])
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
	# ★③票：門檻＝該隊 N 天口糧（pop 5 對齊 _mk_gather 的隊）——不是全域 10.0
	c.home_restock_min = DecisionTerms.RETURN_HYSTERESIS_DAYS * 5.0 * ResourceSystem.FOOD_PER_PERSON_PER_DAY
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
	_selftest_gate("_test_plains_restock_applicable").noop()
	print("--- ①plains 產糧家 空 granary → 返家補給 ---")
	var appl: Callable = DecisionOptions.REGISTRY["返家補給"]["applicable"]
	var c: DecisionContext = _ctx(true, 0.0, 2.0)   # productive + 空 granary + 食低
	_ok(appl.call(c), "plains 產糧家+空 granary+食低 → 返家補給 applicable（非空-granary trap）")
	_ok(is_equal_approx(DecisionTerms.eval("restock_need", c, "返家補給"), 1.0), "restock_need=1.0（產糧家 drive 滿，回去採飽）")

# ② forest 家 + 空 granary → 返家補給 applicable=false + 買糧 applicable=true（forest 正確離家買）
	_cell("_test_plains_restock_applicable")
func _test_forest_buyfood() -> void:
	_selftest_gate("_test_forest_buyfood").noop()
	print("--- ②forest 空 granary → 買糧 ---")
	var restock: Callable = DecisionOptions.REGISTRY["返家補給"]["applicable"]
	var buyfood: Callable = DecisionOptions.REGISTRY["買糧"]["applicable"]
	var c: DecisionContext = _ctx(false, 0.0, 2.0)   # 非產糧 + 空 granary
	_ok(not restock.call(c), "forest 非產糧家+空 granary → 返家補給 not applicable（空家不返）")
	_ok(buyfood.call(c), "forest 非產糧家 → 買糧 applicable（正確離家買=多樣性）")

# ③ granary 有量 + 非產糧 → restock_need granary_q 主導（非 productive floor）
	_cell("_test_forest_buyfood")
func _test_granary_stock_drives() -> void:
	_selftest_gate("_test_granary_stock_drives").noop()
	print("--- ③granary stock 主導 ---")
	var c: DecisionContext = _ctx(false, 5.0, 2.0)   # home_food 5、非產糧
	var _want: float = 5.0 / maxf(c.home_restock_min, 0.01)   # 測試自己算（同公式，不抄 code 的值）
	_ok(is_equal_approx(DecisionTerms.eval("restock_need", c, "返家補給"), _want),
		"granary 5/%.1f=%.3f granary_q 主導（非產糧無 floor，got %.3f）" % [c.home_restock_min, _want, DecisionTerms.eval("restock_need", c, "返家補給")])

# ④ home_food_productive 算式（gather：plains 產糧 / forest 不產）
	_cell("_test_granary_stock_drives")
func _test_productive_formula() -> void:
	_selftest_gate("_test_productive_formula").noop()
	print("--- ④productive 算式 ---")
	var wp: Array = _mk_gather("plains", true)
	var cp: DecisionContext = DecisionContext.gather(wp[0], wp[1])
	_ok(cp.home_food_productive, "plains 家(food 8×1.0=8 ≥ burn 4)→ home_food_productive=true")
	var wf: Array = _mk_gather("forest", true)
	var cf: DecisionContext = DecisionContext.gather(wf[0], wf[1])
	_ok(not cf.home_food_productive, "forest 家(food 3×1.0=3 < burn 4)→ home_food_productive=false")

# ⑤ 無 home outpost → productive=false
	_cell("_test_productive_formula")
func _test_no_home_false() -> void:
	_selftest_gate("_test_no_home_false").noop()
	print("--- ⑤無 home outpost→false ---")
	var w: Array = _mk_gather("plains", false)   # 無 outpost
	var c: DecisionContext = DecisionContext.gather(w[0], w[1])
	_ok(not c.home_food_productive, "無 home outpost → home_food_productive=false（無家不判產糧）")

# ★⑥ 買糧 gate：plains(productive)→買糧 not applicable；forest(非)→applicable
	_cell("_test_no_home_false")
func _test_buyfood_gate() -> void:
	_selftest_gate("_test_buyfood_gate").noop()
	print("--- ★⑥買糧 gate（productive 偏好返家）---")
	var buyfood: Callable = DecisionOptions.REGISTRY["買糧"]["applicable"]
	var cp: DecisionContext = _ctx(true, 0.0, 2.0)   # plains productive
	_ok(not buyfood.call(cp), "plains 產糧家 → 買糧 not applicable（結構偏好返家採飽，閉商隊 toss-up trap）")
	var cf: DecisionContext = _ctx(false, 0.0, 2.0)   # forest 非產糧
	_ok(buyfood.call(cf), "forest 非產糧家 → 買糧 applicable（仍離家買=多樣性不誤鎖）")
	_cell("_test_buyfood_gate")
