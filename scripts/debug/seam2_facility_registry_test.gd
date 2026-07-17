extends SceneTree

# seam#2 S1 _facility_deficit registry 化 characterization + 擴充 proof（byte-identical）
# spec: docs/superpowers/specs/2026-07-17-seam2-facility-deficit-registry.md
#
# 逐 facility case 對照原 _facility_deficit(:3061-3116)：byte-identical 硬要求。
# 關鍵 R② 缺口：apothecary ×0.5、workshop min_per_res ≠ armorsmith pooled_sum、smeltery gating。
# 用 relationship-assertion（用同 NeedOracle/team 讀獨立算 expected → 釘住 evaluator 結構），
# 非 magic-number golden。baseline 綠=公式理解對；refactor 後仍綠=byte-identical。
# 擴充 proof（加 A 類 dummy=1 entry）refactor 前 RED（無 registry），後 GREEN。

var _fail: int = 0
var fai: FactionAISystem = FactionAISystem.new()

func _initialize() -> void:
	_test_apothecary_half_scale()
	_test_workshop_min_per_res()
	_test_armorsmith_pooled_militancy()
	_test_smeltery_gating()
	_test_stable_pooled_single()
	_test_weaponsmith_special()
	_test_mint_special()
	_test_farming_special()
	_test_unknown_facility()
	#_test_extensibility_dummy_a()   # RED on baseline: 無 FACILITY_DEFICIT_DEF（parse error）→ refactor 後啟用
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

func _feq(a: float, b: float, msg: String) -> void:
	_ok(absf(a - b) < 1e-9, "%s (a=%.9f b=%.9f)" % [msg, a, b])

func _mk(pop: int, level_key: String, level: int) -> Array:
	var s := WorldState.new(); s.world = WorldData.new(); s.world.current_tick = 100
	var t := TeamData.new(); t.team_id = 1; t.leader_id = 100
	var ldr := PersonData.new(); ldr.id = 100; ldr.values = {"慎重": 0.5, "好戰": 0.5, "野心": 0.5}
	s.persons[100] = ldr
	for i in range(pop - 1): t.named_members.append(200 + i)
	t.tile_pos = Vector2i(0, 0)
	var tile := HexTileData.new(); tile.tile_pos = Vector2i(0, 0)
	tile.outpost_level = 1; tile.outpost_owner = 1
	if level > 0: tile.set(level_key, level)
	s.world.tiles[0] = tile
	s.teams[1] = t
	return [s, t, tile]

func _lv(s: WorldState, t: TeamData) -> Dictionary:
	return TradeValuation.leader_vals(s, t)

# ── apothecary：deficit = clampf((med_tgt-hold)/med_tgt,0,1) × 0.5（★R² 缺口）──
func _test_apothecary_half_scale() -> void:
	print("--- apothecary ×0.5 尾乘 ---")
	var f := _mk(10, "apothecary_level", 1)
	f[1].resources = {"medicine": 0.0}
	var lv := _lv(f[0], f[1])
	var med_tgt: float = NeedOracle.need_keep(f[0], f[1], "medicine", lv)
	var got: float = fai._facility_deficit(f[0], f[1], "apothecary", f[2])
	if med_tgt <= 0.001:
		_feq(got, 0.0, "apothecary med_tgt≈0 → deficit 0")
	else:
		var expected: float = clampf((med_tgt - 0.0) / med_tgt, 0.0, 1.0) * 0.5
		_feq(got, expected, "apothecary deficit = (tgt-hold)/tgt ×0.5")
		_ok(got <= 0.5 + 1e-9, "apothecary deficit ≤0.5（×0.5 尾乘生效）")

# ── workshop：min_per_res（worst bottleneck，use_demand=true）──
func _test_workshop_min_per_res() -> void:
	print("--- workshop min_per_res（worst bottleneck）---")
	var f := _mk(10, "manufacturing_level", 1)
	# tools 缺、goods/arrows 充裕 → worst 由 tools 驅
	f[1].resources = {"goods": 9999.0, "tools": 1.0, "arrows": 9999.0}
	var lv := _lv(f[0], f[1])
	var worst: float = 1.0
	for res in ["goods", "tools", "arrows"]:
		var tgt: float = NeedOracle.need_keep(f[0], f[1], res, lv) + NeedOracle.demand(f[0], f[1], res, lv)
		if tgt <= 0.001: continue
		worst = minf(worst, float(f[1].resources.get(res, 0)) / tgt)
	var expected: float = clampf(1.0 - worst, 0.0, 1.0)
	var got: float = fai._facility_deficit(f[0], f[1], "workshop", f[2])
	_feq(got, expected, "workshop deficit = 1 - min_per_res(worst)")

# ── armorsmith：pooled_sum（armor_low+high 加總）× militancy ──
func _test_armorsmith_pooled_militancy() -> void:
	print("--- armorsmith pooled_sum × militancy ---")
	var f := _mk(10, "armorsmith_level", 1)
	f[1].resources = {"armor_low": 2.0, "armor_high": 1.0}
	var lv := _lv(f[0], f[1])
	var armor: float = 3.0
	var a_tgt: float = NeedOracle.need_keep(f[0], f[1], "armor_low", lv) + NeedOracle.need_keep(f[0], f[1], "armor_high", lv)
	var got: float = fai._facility_deficit(f[0], f[1], "armorsmith", f[2])
	if a_tgt <= 0.001:
		_feq(got, 0.0, "armorsmith a_tgt≈0 → deficit 0")
	else:
		var expected: float = clampf((a_tgt - armor) / a_tgt, 0.0, 1.0) * fai._militancy(f[1], lv)
		_feq(got, expected, "armorsmith deficit = pooled_sum((tgt-armor)/tgt) × militancy")

# ── smeltery：gating（無 weapon/armorsmith 存在 → 0）──
func _test_smeltery_gating() -> void:
	print("--- smeltery gating（weapon/armorsmith 存在）---")
	var n := _mk(10, "outpost_level", 0)   # 無 weaponsmith/armorsmith level
	n[2].weaponsmith_level = 0; n[2].armorsmith_level = 0
	var got_gated: float = fai._facility_deficit(n[0], n[1], "smeltery", n[2])
	_feq(got_gated, 0.0, "無 weapon/armorsmith → smeltery deficit 0（gating）")
	var f := _mk(10, "weaponsmith_level", 1)
	f[1].resources = {"ore_steel": 0.0}
	var lv := _lv(f[0], f[1])
	var s_tgt: float = NeedOracle.need_keep(f[0], f[1], "ore_steel", lv)
	var got: float = fai._facility_deficit(f[0], f[1], "smeltery", f[2])
	if s_tgt <= 0.001:
		_feq(got, 0.0, "smeltery s_tgt≈0 → deficit 0")
	else:
		_feq(got, clampf((s_tgt - 0.0) / s_tgt, 0.0, 1.0), "smeltery deficit = (tgt-hold)/tgt（gate 通過）")

# ── stable：pooled_sum 單資源 ──
func _test_stable_pooled_single() -> void:
	print("--- stable pooled_sum 單資源 ---")
	var f := _mk(10, "stable_level", 1)
	f[1].resources = {"mounts": 0.0}
	var lv := _lv(f[0], f[1])
	var m_tgt: float = NeedOracle.need_keep(f[0], f[1], "mounts", lv)
	var got: float = fai._facility_deficit(f[0], f[1], "stable", f[2])
	if m_tgt <= 0.001:
		_feq(got, 0.0, "stable m_tgt≈0 → deficit 0")
	else:
		_feq(got, clampf((m_tgt - 0.0) / m_tgt, 0.0, 1.0), "stable deficit = (tgt-hold)/tgt")

# ── weaponsmith：C 特殊（0.6 - armed_anon_ratio）× militancy ──
func _test_weaponsmith_special() -> void:
	print("--- weaponsmith C-special ---")
	var f := _mk(10, "weaponsmith_level", 1)
	f[1].armed_anon_ratio = 0.1
	var lv := _lv(f[0], f[1])
	var expected: float = clampf(0.6 - 0.1, 0.0, 1.0) * fai._militancy(f[1], lv)
	var got: float = fai._facility_deficit(f[0], f[1], "weaponsmith", f[2])
	_feq(got, expected, "weaponsmith deficit = (0.6-armed_ratio) × militancy")

# ── mint：C 特殊（tile ore 二元 1.0 if ore>10 else 0）──
func _test_mint_special() -> void:
	print("--- mint C-special（tile ore 二元）---")
	var f := _mk(10, "mint_level", 1)
	f[2].resource_cap = {"ore_gold": 30.0}   # cap×0.5=15 > 10 → 1.0
	var got_hi: float = fai._facility_deficit(f[0], f[1], "mint", f[2])
	_feq(got_hi, 1.0, "mint ore>10 → 1.0")
	var g := _mk(10, "mint_level", 1)
	g[2].resource_cap = {"ore_gold": 4.0}    # cap×0.5=2 ≤10, pub=0 → 0
	var got_lo: float = fai._facility_deficit(g[0], g[1], "mint", g[2])
	_feq(got_lo, 0.0, "mint ore≤10 → 0.0")

# ── farming：C 特殊（granary local food）──
func _test_farming_special() -> void:
	print("--- farming C-special（granary local food）---")
	var f := _mk(10, "outpost_level", 1)
	f[2].public_storage = {"food": 0.0}
	f[1].resources = {"food": 0.0}
	var pop: float = maxf(float(f[1].population), 1.0)
	var target: float = pop * ResourceSystem.FOOD_PER_PERSON_PER_DAY * 14.0
	var expected: float = clampf((target - 0.0) / target, 0.0, 1.0)
	var got: float = fai._facility_deficit(f[0], f[1], "farming", f[2])
	_feq(got, expected, "farming deficit = (target - local_food)/target")

func _test_unknown_facility() -> void:
	print("--- 未知 facility → 0 ---")
	var f := _mk(10, "outpost_level", 1)
	_feq(fai._facility_deficit(f[0], f[1], "__nonexistent__", f[2]), 0.0, "未知 facility → 0.0")

# ── 擴充 proof：加 1 個 A 類 dummy entry = 泛型 evaluator 自動處理（不改 _facility_deficit 本體）──
func _test_extensibility_dummy_a() -> void:
	print("--- 擴充 proof：加 A 類 registry 1 entry ---")
	# NOTE: refactor 前 FACILITY_DEFICIT_DEF 不存在（parse error）=RED。refactor 後解除下方註解。
	pass
	#FactionAISystem.FACILITY_DEFICIT_DEF["__dummy_a__"] = {
	#	"outputs": ["medicine"], "use_demand": false, "agg_mode": "pooled_sum",
	#	"output_scale": 1.0, "militancy_scaled": false,
	#}
	#var f := _mk(10, "apothecary_level", 1)
	#f[1].resources = {"medicine": 0.0}
	#var lv := _lv(f[0], f[1])
	#var med_tgt: float = NeedOracle.need_keep(f[0], f[1], "medicine", lv)
	#var got: float = fai._facility_deficit(f[0], f[1], "__dummy_a__", f[2])
	#if med_tgt <= 0.001:
	#	_feq(got, 0.0, "dummy med_tgt≈0 → 0")
	#else:
	#	_feq(got, clampf((med_tgt - 0.0) / med_tgt, 0.0, 1.0), "dummy A 類 entry 自動走泛型 evaluator（scale=1.0）")
	#FactionAISystem.FACILITY_DEFICIT_DEF.erase("__dummy_a__")
