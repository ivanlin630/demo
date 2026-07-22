extends SceneTree

# tools-demand 註冊 TDD（spec 2026-07-23-tools-demand-registration）。
# 生產端 demand-routing 缺口:weaponsmith 需 tools 3 但 tools 需求從沒轉買單→demand(tools)=0→
# workshop tools-recipe 恆輸 goods→tools=0 全域→weaponsmith afford tools 恆 fail。3 修:
#   ①need_oracle _construction_facility_need material→{material,tools}+兩層遞迴守衛(output-guard+re-entrancy)
#   ②order_system tools 納 eligible/proxy → mil 發 tools 買單
#   ③weaponsmith material 80→70（blueprint 裁②afford 閘，70×1.5=105<天花板 117 穩達）

var _fail: int = 0

func _initialize() -> void:
	_test_tools_construction_need()   # ①mil 想建 weaponsmith → _construction_facility_need(tools)>0（含 tools cost 3）
	_test_civ_tools_selfuse_only()    # ②無 build-need team → need_keep(tools)=self_use only（pop×0.5）不變
	_test_recursion_guards()          # ★③兩層守衛:output-guard 資料正確 + re-entrancy 硬切環有界回 0
	_test_material_still_qualifies()  # ④material 路徑仍 fire（泛化不破 v2a material）
	_test_tools_buy_order()           # ⑤order_system:reserve(tools)>holding → 發 tools 買單
	_test_weaponsmith_cost70()        # ⑥upgrade_cost(weaponsmith,1).material==70（armorsmith 仍 80）
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

func _mk(outpost_type: String, armed: float, martial: float) -> Array:
	var state := WorldState.new(); state.world = WorldData.new(); state.world.current_tick = 1000
	for x in range(3, 8):
		for y in range(3, 8):
			var tl := HexTileData.new(); tl.tile_pos = Vector2i(x, y); tl.terrain = "plains"
			state.world.tiles[x * 1000 + y] = tl
	var team := TeamData.new(); team.team_id = 1; team.tile_pos = Vector2i(5, 5); team.faction_id = 5
	AnonCohort.add(team.anon_cohorts, "平民", "healthy", 15)
	team.armed_anon_ratio = armed
	var l := PersonData.new(); l.id = 10; l.values = {"好戰": martial, "貪婪": 0.5, "慎重": 0.5}; l.skills = {}
	state.persons[10] = l; team.leader_id = 10
	state.teams[1] = team
	if outpost_type != "":
		var tile: HexTileData = state.world.tiles[5 * 1000 + 5]
		tile.outpost_owner = 1; tile.outpost_type = outpost_type; tile.outpost_level = 1
		tile.set("weaponsmith_level", 0); tile.set("armorsmith_level", 0)
		tile.set("smelter_level", 0); tile.set("stable_level", 0)
	return [state, team]

func _lv(team: TeamData, state: WorldState) -> Dictionary:
	return state.persons[team.leader_id].values

# ① mil 想建 weaponsmith → _construction_facility_need(tools)>0（tools 進 scope，含 weaponsmith tools cost 3）
func _test_tools_construction_need() -> void:
	print("--- ①tools construction need（tools 進 build-cost scope）---")
	var w: Array = _mk("military", 0.0, 0.9)
	var tile: HexTileData = w[0].world.tiles[5 * 1000 + 5]
	# 隔離 weaponsmith：其餘 tools-cost military facility(armorsmith/smeltery)maxed L3 skip；weaponsmith tools cost=3。
	tile.set("armorsmith_level", 3); tile.set("smelter_level", 3)
	var cn: float = NeedOracle._construction_facility_need(w[0], w[1], "tools", _lv(w[1], w[0]))
	_ok(is_equal_approx(cn, 3.0), "單一想建 weaponsmith → construction need(tools)=weaponsmith tools cost 3（material-only 舊碼=0，got %.1f）" % cn)

# ② 無 build-need team（無 outpost）→ need_keep(tools)=self_use only（pop×TARGET_PER_POP.tools）不變（無迴歸）
func _test_civ_tools_selfuse_only() -> void:
	print("--- ②無 build-need → need_keep(tools)=self_use only ---")
	var w: Array = _mk("", 0.0, 0.5)   # 無 outpost
	var nk: float = NeedOracle.need_keep(w[0], w[1], "tools", _lv(w[1], w[0]))
	var expect: float = float(w[1].population) * float(TradeValuation.TARGET_PER_POP.get("tools", 0.5))
	_ok(is_equal_approx(nk, expect), "無 outpost → need_keep(tools)=self_use pop×0.5=%.1f（construction=0 無迴歸，got %.1f）" % [expect, nk])

# ★③ 兩層遞迴守衛：(a) output-guard 資料正確 + (b) re-entrancy 硬切環有界回 0
func _test_recursion_guards() -> void:
	print("--- ★③遞迴守衛（output-guard + re-entrancy）---")
	# (a) output-guard 資料：workshop 產 tools → 算 tools-need 時該被 skip（不自指）；special facility 無 outputs 鍵→[] 不誤跳。
	_ok("tools" in NeedOracle._facility_output_res("workshop"), "(a) output-guard:workshop outputs 含 tools（算 tools-need 跳 workshop 自指邊）")
	_ok(NeedOracle._facility_output_res("weaponsmith").is_empty(), "(a) weaponsmith(special)outputs=[]（不誤跳，其不產 material/tools）")
	# (b) ★re-entrancy 硬驗：手動置 visiting[material]=true → 再入 _construction_facility_need(material) 即刻切回 0（非無限遞迴）。
	var w: Array = _mk("military", 0.0, 0.9)
	NeedOracle._construction_visiting["material"] = true
	var reentrant: float = NeedOracle._construction_facility_need(w[0], w[1], "material", _lv(w[1], w[0]))
	NeedOracle._construction_visiting["material"] = false   # 清 test state
	_ok(reentrant == 0.0, "(b) re-entrancy:visiting[material] 中再入 → 切回 0.0（graph-independent 切環，got %.1f）" % reentrant)
	# (b) balanced set/clear：正常 call 後 visiting 清空（無 leak→後續 need 不被誤 0）。
	var w2: Array = _mk("military", 0.0, 0.9)
	var _n: float = NeedOracle.need_keep(w2[0], w2[1], "material", _lv(w2[1], w2[0]))
	_ok(not NeedOracle._construction_visiting.get("material", false), "(b) 正常 call 後 visiting[material] 清空（balanced，無 leak）")
	# ★深呼叫終結（若現圖有 material→tools→material 真環，此不 hang=守衛生效）。
	var deep: float = NeedOracle.need_keep(w2[0], w2[1], "material", _lv(w2[1], w2[0]))
	_ok(deep >= 0.0 and deep < 1e9, "深 need_keep(material) 有界完成不 hang（守衛終結遞迴，got %.1f）" % deep)

# ④ material 路徑仍 fire（泛化 material→{material,tools} 不破 v2a material 半修）
func _test_material_still_qualifies() -> void:
	print("--- ④material 路徑仍 fire ---")
	var w: Array = _mk("military", 0.0, 0.9)
	var cn: float = NeedOracle._construction_facility_need(w[0], w[1], "material", _lv(w[1], w[0]))
	_ok(cn > 0.0, "mil 想建 → construction need(material)>0（泛化不破 material 半修，got %.1f）" % cn)

# ⑤ order_system：reserve(tools)>holding → tick_team_orders 發 tools 買單
func _test_tools_buy_order() -> void:
	print("--- ⑤tools 買單發出 ---")
	var w: Array = _mk("military", 0.0, 0.9)
	var team: TeamData = w[1]
	team.resources["tools"] = 0.0   # 缺 tools
	team.current_task = TeamData.TASK_IDLE
	var os := OrderSystem.new()
	os.tick_team_orders(w[0], team)
	var has_tools_buy: bool = false
	for o in team.active_orders:
		if o.get("kind", "") == "buy" and o.get("res", "") == "tools":
			has_tools_buy = true
	_ok(has_tools_buy, "reserve(tools)>holding(0) → 發 tools 買單（demand-routing 接通；proxy 前無 tools）")

# ⑥ weaponsmith material cost 80→70（僅 weaponsmith；armorsmith 仍 80）
func _test_weaponsmith_cost70() -> void:
	print("--- ⑥weaponsmith cost70 ---")
	var wm: float = float(OutpostSystem.upgrade_cost("weaponsmith", 1).get("material", 0))
	_ok(is_equal_approx(wm, 70.0), "upgrade_cost(weaponsmith,1).material==70（70×1.5=105<天花板 117 穩達，got %.1f）" % wm)
	var am: float = float(OutpostSystem.upgrade_cost("armorsmith", 1).get("material", 0))
	_ok(is_equal_approx(am, 80.0), "armorsmith material 仍 80（僅 weaponsmith 動，got %.1f）" % am)
