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
	# ★完成標記：沒有它，閘的 Q1 只能答「不知道跑了多少」——
	#   而「不知道」與「跑完且沒紅」在輸出上長得一樣。
	print("[TEST-SUITE-COMPLETE]")
	quit()

func _ok(cond: bool, msg: String) -> void:
	if cond:
		print("  [PASS] %s" % msg)
	else:
		_fail += 1
		# ★★走【引擎 severity 通道】(2026-08-26)：`test-ran-floor.sh` 的列舉軸是 Godot 自己的
		#   severity 前綴，只用 `print` 的失敗它一條都看不見 ⇒ 對這張床生出來的 baseline 會是
		#   【0 條】，而 0 條讀起來像綠。★這是「儀器沒開，0 被當成沒發生」那一型。
		# ★失敗處置兩軸：`push_error` ＝【會叫、不會停】——正是這裡要的（可數不致命）；
		#   `assert` 會停，撞第一條之後的都不跑。
		push_error("[FAIL] %s" % msg)
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
	# ★★★手抄真值的斷言【已拆】(2026-08-26)：舊版斷言 `armorsmith == 80`，
	#   而它後來被【授權】改成 70（`outpost_system.gd:93`「mil-facility-cost70：仿 weaponsmith，同族，balance」）
	#   ⇒ 測試沒跟。★★改成 70 只是把手抄的舊值換成手抄的新值，下次 balance 再動一次又爛。
	#   ⇒ 改成斷言【同族同價】這個【關係】：成本表怎麼調都成立，★只有「同族卻不同價」才紅。
	# ★「同族」有真相源，不是我造的表：`FACILITY_DEF[f].allowed_outpost == ["military"]`。
	var mil_family: Array = []
	for f in OutpostSystem.FACILITY_DEF:
		var allowed: Array = (OutpostSystem.FACILITY_DEF[f] as Dictionary).get("allowed_outpost", [])
		if allowed.size() == 1 and String(allowed[0]) == "military":
			mil_family.append(String(f))
	mil_family.sort()
	# ★母體先驗（防恆真式）：家族少於 2 個成員時，「全部相等」是空真的
	_ok(mil_family.size() >= 2, "軍用專屬設施家族 ≥2 個成員（母體非空真，got %s）" % str(mil_family))
	var costs: Array = []
	for f in mil_family:
		costs.append(float(OutpostSystem.upgrade_cost(String(f), 1).get("material", 0)))
	var all_same: bool = true
	for c in costs:
		if not is_equal_approx(float(c), float(costs[0])):
			all_same = false
	_ok(all_same, "同族同價：軍用專屬設施 %s 的 material 成本一致（%s）" % [str(mil_family), str(costs)])
	# ★weaponsmith 也在那個家族裡 —— 上面那條 70 的斷言與這條的關係要顯式，不靠讀者自己連
	_ok("weaponsmith" in mil_family, "weaponsmith 屬於軍用專屬家族（上一條的 70 就是家族價）")
