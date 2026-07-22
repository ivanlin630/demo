extends SceneTree

# material means-end buy v2a TDD（spec 2026-07-23-material-buy-v2a-full-need-utility）。
# v1(ca199844) QA 半破:want 接上但 buy-to-80 未達。3 fix 疊 v1:
#   ① need_oracle full build-need（desire=gate 非 multiplier；過閘=全 cost 80 非稀釋 24=白買）
#   ② terms buymaterial_drive 繫建設迫切（shortfall/CAP × max _facility_deficit，競建設非墊底 1.7%）
#   ③ ★food-ok gate（買料 applicable +food_days>=DESPERATION，鏡射買糧互斥=結構防餓死）
# ★循環守衛結構(v1):build-cost res(material)∩facility-output res=∅→無遞迴。cap 防疊爆。

var _fail: int = 0

func _initialize() -> void:
	_test_full_build_need()        # ①想建 weaponsmith(單一)→_construction_facility_need=full 80(非×desire 稀釋)
	_test_cap_clamps()             # ②多 material-facility→total clamp 到 CAP 100
	_test_drive_rises_with_urgency() # ③buymaterial_drive 隨 construction 迫切升
	_test_food_ok_gate()           # ★④food-ok gate:food<DESP→買料 not applicable;food>=DESP→applicable
	_test_cycle_guard_terminates() # 循環守衛:need_keep(material) 一次完成不遞迴爆
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

# mil 隊 + military outpost。armed_ratio 低+好戰高→weaponsmith desire 高(self_defense 路)。
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
		tile.set("smelter_level", 0); tile.set("stable_level", 0)
	return [state, team]

func _lv(team: TeamData, state: WorldState) -> Dictionary:
	return state.persons[team.leader_id].values

# ① full build-need：單一 material-facility（其餘 maxed L3 skip）→ _construction_facility_need = 全 cost 80（非 ×desire）
func _test_full_build_need() -> void:
	print("--- ①full build-need（desire=gate 非稀釋）---")
	var w: Array = _mk(true, 0.0, 0.9)
	var tile: HexTileData = w[0].world.tiles[5 * 1000 + 5]
	# 隔離 weaponsmith：其餘 material-facility(smeltery/armorsmith/stable) maxed L3 → cur>=3 skip。
	tile.set("armorsmith_level", 3); tile.set("smelter_level", 3); tile.set("stable_level", 3)
	var cn: float = NeedOracle._construction_facility_need(w[0], w[1], "material", _lv(w[1], w[0]))
	# 過 desire gate → 全 weaponsmith cost 80（v1 舊碼 ×desire 會 <80=白買=半破根）。
	_ok(is_equal_approx(cn, 80.0), "單一想建 weaponsmith → construction need=full 80（非 ×desire 稀釋，got %.1f）" % cn)

# ② cap：多 material-facility → total clamp 到 CONSTRUCTION_MATERIAL_NEED_CAP
func _test_cap_clamps() -> void:
	print("--- ②cap 防疊爆 ---")
	# military 全 material-facility L0（weaponsmith/armorsmith/smeltery 各 80 + stable 40 = 280）→ clamp 100。
	var w: Array = _mk(true, 0.0, 0.9)
	var cn: float = NeedOracle._construction_facility_need(w[0], w[1], "material", _lv(w[1], w[0]))
	_ok(is_equal_approx(cn, NeedOracle.CONSTRUCTION_MATERIAL_NEED_CAP), "多 facility(full-cost 疊)→ total=CAP %.0f（防 over-buy，got %.1f）" % [NeedOracle.CONSTRUCTION_MATERIAL_NEED_CAP, cn])

# ③ buymaterial_drive 隨 construction 迫切（material_build_urgency）升
func _test_drive_rises_with_urgency() -> void:
	print("--- ③buymaterial_drive 繫建設迫切 ---")
	var lo := DecisionContext.new()
	lo.material_shortfall = 80.0; lo.has_material_market = true; lo.has_specie = true; lo.material_build_urgency = 0.3
	var hi := DecisionContext.new()
	hi.material_shortfall = 80.0; hi.has_material_market = true; hi.has_specie = true; hi.material_build_urgency = 0.9
	var d_lo: float = DecisionTerms.eval("buymaterial_drive", lo, "買料")
	var d_hi: float = DecisionTerms.eval("buymaterial_drive", hi, "買料")
	_ok(d_hi > d_lo, "建設迫切高(0.9) drive > 低(0.3)（買料繫建設前置，got hi=%.2f lo=%.2f）" % [d_hi, d_lo])
	# 無市場/無籌碼 → 0（既有 guard 保留）
	var no_mkt := DecisionContext.new()
	no_mkt.material_shortfall = 80.0; no_mkt.has_material_market = false; no_mkt.has_specie = true; no_mkt.material_build_urgency = 0.9
	_ok(DecisionTerms.eval("buymaterial_drive", no_mkt, "買料") == 0.0, "無 material 市場 → drive=0")

# ★④ food-ok gate：餓隊(food<DESPERATION)買料 not applicable；食足(>=DESPERATION)applicable
func _test_food_ok_gate() -> void:
	print("--- ★④food-ok gate（防餓隊買料餓死）---")
	var appl: Callable = DecisionOptions.REGISTRY["買料"]["applicable"]
	var hungry := DecisionContext.new()
	hungry.food_days = DecisionTerms.DESPERATION_DAYS - 0.5   # 餓
	hungry.material_shortfall = 50.0; hungry.has_material_market = true; hungry.has_specie = true
	_ok(not appl.call(hungry), "餓隊(food<DESPERATION) → 買料 not applicable（鏡射買糧互斥，餓時只買糧=防餓死）")
	var fed := DecisionContext.new()
	fed.food_days = DecisionTerms.DESPERATION_DAYS + 2.0   # 食足
	fed.material_shortfall = 50.0; fed.has_material_market = true; fed.has_specie = true
	_ok(appl.call(fed), "食足(food>=DESPERATION)+缺料+市場+籌碼 → 買料 applicable")
	# 食足但不缺料 → 仍 not applicable
	var fed_nofit := DecisionContext.new()
	fed_nofit.food_days = DecisionTerms.DESPERATION_DAYS + 2.0
	fed_nofit.material_shortfall = 0.0; fed_nofit.has_material_market = true; fed_nofit.has_specie = true
	_ok(not appl.call(fed_nofit), "食足但不缺料 → not applicable（不亂買）")

# 循環守衛：need_keep(material) 一次完成不無限遞迴（結構驗；build-cost∩output=∅）
func _test_cycle_guard_terminates() -> void:
	print("--- 循環守衛 need_keep(material) 不遞迴爆 ---")
	var w: Array = _mk(true, 0.0, 0.9)
	var need: float = NeedOracle.need_keep(w[0], w[1], "material", _lv(w[1], w[0]))
	_ok(need >= 0.0 and need < 1e9, "need_keep(material) 一次完成回有限值（cost-guard 前置=無遞迴，got %.1f）" % need)
