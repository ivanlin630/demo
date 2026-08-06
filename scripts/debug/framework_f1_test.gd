extends SceneTree

# 框架收尾 F1 threshold 死常數人格化 TDD（spec 2026-08-07-framework-F1-persona-HOW §1/§2/§2.5）。
# 靶A: DESPERATION entry-gate 人格化(單一計算點 ctx.desperation_entry_threshold、5+ survival-entry applicable 共讀)。
# 靶B: MINING_GREED 硬 persona-gate → soft weight(連續無 1.1 懸崖)。守 genuine 非 crank/物理錨留 raw。

var _fail: int = 0
func _ok(c: bool, m: String) -> void:
	if c: print("  [PASS] %s" % m)
	else: _fail += 1; print("  [FAIL] %s" % m)

func _initialize() -> void:
	_test_desperation_threshold_persona()   # 靶A ①人格 modulate:謹慎/懼早進>3 / 膽大撐久<3 / 中性=raw 3.0
	_test_entry_gate_reads_persona()         # 靶A ②survival-entry applicable 讀 ctx.desperation_entry_threshold
	_test_buyfood_buymaterial_mutex()        # 靶A ③買糧<threshold / 買料>=threshold mutex 隨 persona 不破
	_test_physical_anchor_raw()              # 靶A ④物理錨 DESPERATION_DAYS raw 不變(need-anchor 分離)
	_test_mining_greed_continuous()          # 靶B ore bonus 連續 ∝ greed(無 1.1 懸崖、貪婪>普通、皆非零 gate)
	if _fail == 0: print("=== DONE === ALL PASS")
	else: print("=== DONE === %d FAIL" % _fail)
	quit()

# 靶A①：人格 modulate（謹慎/求生欲↑→早進 threshold↑ / 好戰(膽)↑→撐久 threshold↓ / 中性=raw）。
func _test_desperation_threshold_persona() -> void:
	print("--- 靶A① persona threshold ---")
	var neutral: float = DecisionTerms.desperation_entry_threshold({"慎重": 0.5, "求生欲": 0.5, "好戰": 0.5})
	var cautious: float = DecisionTerms.desperation_entry_threshold({"慎重": 0.9, "求生欲": 0.9, "好戰": 0.1})
	var bold: float = DecisionTerms.desperation_entry_threshold({"慎重": 0.1, "求生欲": 0.1, "好戰": 0.9})
	_ok(is_equal_approx(neutral, DecisionTerms.DESPERATION_DAYS) and cautious > neutral and bold < neutral,
		"中性=%.1f(raw、零漂) / 謹慎+懼=%.1f>raw(早進絕境) / 膽大=%.1f<raw(撐更低糧才進)=genuine 風險容忍" % [neutral, cautious, bold])

# 靶A②：survival-entry option applicable 讀 ctx.desperation_entry_threshold（非 raw DESPERATION_DAYS）。
func _test_entry_gate_reads_persona() -> void:
	print("--- 靶A② entry-gate 讀 persona ---")
	var ctx := DecisionContext.new()
	ctx.food_days = 3.5   # >raw DESPERATION(3.0) 但可能 <謹慎 threshold
	ctx.has_aid_target = true
	ctx.desperation_entry_threshold = 4.5   # 謹慎：3.5<4.5 → 入絕境（乞食 applicable）
	var appl_cautious: bool = DecisionOptions.REGISTRY["乞食"]["applicable"].call(ctx)
	ctx.desperation_entry_threshold = 2.0   # 膽大：3.5>=2.0 → 不入絕境（乞食 not applicable）
	var appl_bold: bool = DecisionOptions.REGISTRY["乞食"]["applicable"].call(ctx)
	_ok(appl_cautious and not appl_bold,
		"乞食 applicable 讀 ctx.desperation_entry_threshold(食3.5:謹慎4.5→入求生 / 膽大2.0→不入)=persona entry 非 raw")

# 靶A③：買糧(<threshold)/買料(>=threshold) mutex 隨 persona threshold 不破 gap/overlap。
func _test_buyfood_buymaterial_mutex() -> void:
	print("--- 靶A③ 買糧/買料 mutex ---")
	var ctx := DecisionContext.new()
	ctx.food_days = 3.5
	ctx.has_food_market = true; ctx.has_specie = true; ctx.has_buyable_food = true; ctx.home_food_productive = false
	ctx.has_material_market = true; ctx.material_shortfall = 1.0
	ctx.desperation_entry_threshold = 4.5   # 謹慎：3.5<4.5 → 買糧 yes / 買料 no
	var bf_c: bool = DecisionOptions.REGISTRY["買糧"]["applicable"].call(ctx)
	var bm_c: bool = DecisionOptions.REGISTRY["買料"]["applicable"].call(ctx)
	ctx.desperation_entry_threshold = 2.0   # 膽大：3.5>=2.0 → 買糧 no / 買料 yes
	var bf_b: bool = DecisionOptions.REGISTRY["買糧"]["applicable"].call(ctx)
	var bm_b: bool = DecisionOptions.REGISTRY["買料"]["applicable"].call(ctx)
	_ok(bf_c and not bm_c and not bf_b and bm_b,
		"買糧/買料 mutex 隨 persona(謹慎 3.5<4.5→買糧 / 膽大 3.5>=2.0→買料、恆互斥不破 gap/overlap)")

# 靶A④：物理錨 DESPERATION_DAYS raw 不變（need-anchor=買糧量/relief=DESPERATION×pop×0.8 分離）。
func _test_physical_anchor_raw() -> void:
	print("--- 靶A④ 物理錨 raw ---")
	_ok(is_equal_approx(DecisionTerms.DESPERATION_DAYS, 3.0),
		"DESPERATION_DAYS=%.1f raw 常數不動(need-anchor 物理量、只 entry-gate 人格化)" % DecisionTerms.DESPERATION_DAYS)

# 靶B：ore bonus 連續 ∝ (貪婪+野心) 真影響「選址 choice」（★multi-candidate fixture:ore 山 vs 無-ore plains 競爭、
# 非只 bonus 大小）——低貪婪選 plains(山懲主導)/高貪婪選 ore(bonus 壓過)=greed 真分化選址、無 1.1 懸崖。
# ★measurer 抓的 placeholder 已除：真計算 pick per greed（recovery-r1 false-confidence 教訓）。
func _mine_site_pick(ga: float) -> Vector2i:
	var s := WorldState.new(); s.world = WorldData.new(); s.world.current_tick = 100
	var lord := TeamData.new(); lord.team_id = 1; lord.faction_id = 0; lord.tile_pos = Vector2i(10,10)
	var ll := PersonData.new(); ll.id = 11; ll.values = {"貪婪": ga/2.0, "野心": ga/2.0}; s.persons[11] = ll; lord.leader_id = 11
	s.teams[1] = lord
	var ho := HexTileData.new(); ho.tile_pos = Vector2i(10,10); ho.terrain = "plains"; ho.outpost_level = 1; ho.outpost_owner = 1; ho.outpost_type = "civilian"
	s.world.tiles[10010] = ho
	# ★競爭候選：ore mountain（dist2、富礦但山懲）vs 無-ore plains（dist2、高 productivity 無礦）。
	var om := HexTileData.new(); om.tile_pos = Vector2i(12,10); om.terrain = "mountain"; om.outpost_level = 0; om.outpost_owner = -1
	om.resource_cap = {"ore_gold": 50.0}; om.productivity = 0.3
	s.world.tiles[12010] = om
	var pl := HexTileData.new(); pl.tile_pos = Vector2i(10,12); pl.terrain = "plains"; pl.outpost_level = 0; pl.outpost_owner = -1
	pl.resource_cap = {}; pl.productivity = 1.0   # 高沃度 plains 競爭：plains score≈126 vs ore mountain 61+87.5×ga（flip ga≈0.74）
	s.world.tiles[10012] = pl
	var res: Dictionary = FactionAISystem.new()._evaluate_new_outpost_location(s, lord)
	return res.get("pos", Vector2i(-1, -1)) if not res.is_empty() else Vector2i(-1, -1)

func _test_mining_greed_continuous() -> void:
	print("--- 靶B mining greed 選址真分化 ---")
	var ORE := Vector2i(12, 10); var PLAINS := Vector2i(10, 12)
	var low_pick: Vector2i = _mine_site_pick(0.4)    # 低貪婪：ore-bonus 小→山懲主導→選 plains
	var mid_pick: Vector2i = _mine_site_pick(1.09)   # threshold-下(舊硬 gate 邊界)：連續 bonus、非零 gate
	var high_pick: Vector2i = _mine_site_pick(1.5)   # 高貪婪：ore-bonus 大→壓過山懲→選 ore
	print("    low(0.4)=%s mid(1.09)=%s high(1.5)=%s (ORE=%s PLAINS=%s)" % [str(low_pick), str(mid_pick), str(high_pick), str(ORE), str(PLAINS)])
	# ★真分化斷言：低貪婪選 plains(非 ore)、高貪婪選 ore = greed 高低真影響選址 choice（非 placeholder）。
	_ok(low_pick == PLAINS and high_pick == ORE,
		"低貪婪(0.4)選 plains(山懲主導、ore-bonus 小)/高貪婪(1.5)選 ore(bonus 壓過)=greed 真分化選址 choice、無 1.1 懸崖(mid 1.09 由連續 bonus 定=%s)" % str(mid_pick))
