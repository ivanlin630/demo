extends SceneTree

# material means-end need + 買料 action TDD（spec 2026-07-22-material-means-end-buy）。
# root chicken-egg:material need gated on 已有 facility→builder 不帶 need→買不到→建不了。
# 修 3 部閉環:①need_oracle _construction_facility_need(means-end,cost-guard 前置+cap)②DecisionContext
#   has_material_market/material_shortfall ③options「買料」+DecisionTerms buymaterial_drive。
# ★循環守衛結構:build-cost res(material)∩facility-output res=∅→無遞迴。cap 防疊爆。

var _fail: int = 0

func _initialize() -> void:
	_test_means_end_fires()        # ①想建 weaponsmith 的 mil 隊→need_keep(material)>0
	_test_no_outpost_zero()        # ②無 outpost→construction need 0(不亂囤)
	_test_buymaterial_applicable() # ③買料 applicable=缺料+市場+coin
	_test_cycle_guard_terminates() # ④循環守衛:need_keep(material) 一次完成不遞迴爆(結構驗)
	_test_cap_clamps()             # ⑤多 material-facility→total clamp 到 CAP
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

# mil 隊 + military outpost(weaponsmith 未建)。armed_ratio 低+好戰高→weaponsmith desire 高(self_defense 路)。
func _mk(with_outpost: bool, armed: float, martial: float) -> Array:
	var state := WorldState.new(); state.world = WorldData.new(); state.world.current_tick = 1000
	for x in range(3, 8):
		for y in range(3, 8):
			var tl := HexTileData.new(); tl.tile_pos = Vector2i(x, y); tl.terrain = "plains"
			state.world.tiles[x * 1000 + y] = tl
	var team := TeamData.new(); team.team_id = 1; team.tile_pos = Vector2i(5, 5); team.faction_id = 5
	AnonCohort.add(team.anon_cohorts, "平民", "healthy", 15)
	team.armed_anon_ratio = armed
	var l := PersonData.new(); l.id = 10; l.values = {"好戰": martial, "貪婪": 0.5}; l.skills = {}
	state.persons[10] = l; team.leader_id = 10
	state.teams[1] = team
	if with_outpost:
		var tile: HexTileData = state.world.tiles[5 * 1000 + 5]
		tile.outpost_owner = 1; tile.outpost_type = "military"; tile.outpost_level = 1
		tile.set("weaponsmith_level", 0); tile.set("armorsmith_level", 0)
	return [state, team]

func _lv(team: TeamData, state: WorldState) -> Dictionary:
	return state.persons[team.leader_id].values

# ① mil 隊想建 weaponsmith → need_keep(material)>0（means-end fire，破 chicken-egg）
func _test_means_end_fires() -> void:
	print("--- ①means-end material need fire ---")
	var w: Array = _mk(true, 0.0, 0.9)   # military outpost + 未武裝 + 好戰→weaponsmith desire 高
	var need: float = NeedOracle.need_keep(w[0], w[1], "material", _lv(w[1], w[0]))
	_ok(need > 0.0, "想建 weaponsmith 的 mil 隊 → need_keep(material)>0（means-end，破 chicken-egg，got %.1f）" % need)

# ② 無 outpost → construction need 0（不亂囤）
func _test_no_outpost_zero() -> void:
	print("--- ②無 outpost→0 ---")
	var w: Array = _mk(false, 0.0, 0.9)   # 無 outpost
	var cn: float = NeedOracle._construction_facility_need(w[0], w[1], "material", _lv(w[1], w[0]))
	_ok(cn == 0.0, "無 outpost → _construction_facility_need=0（不亂囤料，got %.1f）" % cn)

# ③ 買料 applicable=缺料+有 material 市場+有籌碼
func _test_buymaterial_applicable() -> void:
	print("--- ③買料 applicable ---")
	var appl: Callable = DecisionOptions.REGISTRY["買料"]["applicable"]
	var ctx := DecisionContext.new()
	ctx.material_shortfall = 50.0; ctx.has_material_market = true; ctx.has_specie = true
	_ok(appl.call(ctx), "缺料+市場+籌碼 → 買料 applicable")
	var ctx2 := DecisionContext.new()
	ctx2.material_shortfall = 0.0; ctx2.has_material_market = true; ctx2.has_specie = true
	_ok(not appl.call(ctx2), "不缺料 → 買料 not applicable（不亂買）")
	var ctx3 := DecisionContext.new()
	ctx3.material_shortfall = 50.0; ctx3.has_material_market = false; ctx3.has_specie = true
	_ok(not appl.call(ctx3), "無 material 市場 → not applicable")

# ④ 循環守衛：need_keep(material) 一次完成不無限遞迴（結構驗；build-cost∩output=∅）
func _test_cycle_guard_terminates() -> void:
	print("--- ④循環守衛 need_keep(material) 不遞迴爆 ---")
	var w: Array = _mk(true, 0.0, 0.9)
	# 若循環守衛破（facility deficit 回呼 need_keep(material)）→ stack overflow 崩。能回傳有限值=結構安全。
	var need: float = NeedOracle.need_keep(w[0], w[1], "material", _lv(w[1], w[0]))
	_ok(need >= 0.0 and need < 1e9, "need_keep(material) 一次完成回有限值（cost-guard 在 deficit-call 前=無遞迴，got %.1f）" % need)

# ⑤ cap：多 material-facility 想 → total clamp 到 CONSTRUCTION_MATERIAL_NEED_CAP
func _test_cap_clamps() -> void:
	print("--- ⑤cap 防疊爆 ---")
	# military outpost:weaponsmith(80)+armorsmith(80)... 皆未武裝高好戰→desire 高→sum>CAP(100)→clamp
	var w: Array = _mk(true, 0.0, 0.9)
	var cn: float = NeedOracle._construction_facility_need(w[0], w[1], "material", _lv(w[1], w[0]))
	_ok(cn <= NeedOracle.CONSTRUCTION_MATERIAL_NEED_CAP + 0.01, "多 facility 想 → total≤CAP(%.0f)（防 over-buy 囤積，got %.1f）" % [NeedOracle.CONSTRUCTION_MATERIAL_NEED_CAP, cn])
