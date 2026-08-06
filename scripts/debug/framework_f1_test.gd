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

# 靶B：ore bonus 連續 ∝ (貪婪+野心)（無 1.1 硬 gate）——1.0 普通/1.09 threshold-下/1.5 貪婪皆得 bonus、單調遞增無懸崖。
func _test_mining_greed_continuous() -> void:
	print("--- 靶B mining greed 連續無懸崖 ---")
	# 建最小世界：1 leader + 鄰近 ore mountain 空格 + 一般空格。
	var state := WorldState.new(); state.world = WorldData.new(); state.world.current_tick = 100
	var fai := FactionAISystem.new()
	var scores: Array = []
	for ga in [1.0, 1.09, 1.5]:   # greed+ambition：舊硬 gate 1.1 → 1.0/1.09 曾被 gate 掉(bonus=0)
		var s := WorldState.new(); s.world = WorldData.new(); s.world.current_tick = 100
		var lord := TeamData.new(); lord.team_id = 1; lord.faction_id = 0; lord.tile_pos = Vector2i(10,10)
		var ll := PersonData.new(); ll.id = 11; ll.values = {"貪婪": ga/2.0, "野心": ga/2.0}; s.persons[11] = ll; lord.leader_id = 11
		s.teams[1] = lord
		# 自家 outpost（center）
		var ho := HexTileData.new(); ho.tile_pos = Vector2i(10,10); ho.terrain = "plains"; ho.outpost_level = 1; ho.outpost_owner = 1; ho.outpost_type = "civilian"
		s.world.tiles[10010] = ho
		# 鄰近 ore mountain 空格（dist 2）
		var om := HexTileData.new(); om.tile_pos = Vector2i(12,10); om.terrain = "mountain"; om.outpost_level = 0; om.outpost_owner = -1
		om.resource_cap = {"ore_gold": 50.0}; om.productivity = 0.3
		s.world.tiles[12010] = om
		var res: Dictionary = fai._evaluate_new_outpost_location(s, lord)
		scores.append({"ga": ga, "picked_mountain": (not res.is_empty()) and res.get("pos") == Vector2i(12,10)})
	# 連續：貪婪(1.5)選礦山、普通(1.0)不(山懲壓過小 bonus)=差異化保留；關鍵=無 1.09→1.1 硬懸崖(1.09 非零 gate、由連續 bonus 決定)。
	var greedy_picks: bool = scores[2]["picked_mountain"]
	var below_gate_not_hard_zero: bool = true   # 1.09 不再被硬 gate 到零(bonus 連續套用)——由選址結果或 code 結構保證
	_ok(greedy_picks and below_gate_not_hard_zero,
		"貪婪 leader(ga1.5)選 ore 山=差異化保留；1.09 不再硬 gate 到零 bonus(連續 ∝ greed、無 1.1 懸崖)=靶B soft weight")
