extends SceneTree

# ★★★陽性對照（`feedback_instrument_lies_three_forms` ①「儀器沒開，0 被當成沒發生」）：
#   接線後世界層仍量到 `means_end.stock_seen.* = 0`。★那有兩種完全不同的意思：
#     (a) **接線壞了／分支仍不可達** —— 是我的 bug
#     (b) **世界真的走不到礦** —— 是世界事實（systems 說：照原樣回報，不補床逼它 fire）
#   ★單看那個 0 分不出來 ⇒ 本檔用【定向 fixture】直接餵一個有礦的世界給那條路徑，
#     ★若這裡也是 0 ⇒ (a) 我的 bug；★★若這裡出得來 ⇒ (b) 世界事實，那個 0 可以照原樣報。

var _fail: int = 0

func _initialize() -> void:
	_test_shape_of_ore()
	_test_for_resource_returns_stock_path()
	_test_stock_candidate_priced()
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

func _mk() -> Array:
	var state := WorldState.new(); state.world = WorldData.new(); state.world.current_tick = 1000
	for x in range(0, 12):
		for y in range(0, 12):
			var tl := HexTileData.new(); tl.tile_pos = Vector2i(x, y); tl.terrain = "plains"
			tl.productivity = 1.0
			state.world.tiles[x * 1000 + y] = tl
	var team := TeamData.new(); team.team_id = 1; team.tile_pos = Vector2i(5, 5); team.faction_id = 5
	AnonCohort.add(team.anon_cohorts, "平民", "healthy", 20); team.armed_anon_ratio = 0.0
	var l := PersonData.new(); l.id = 10
	l.values = {"好戰": 0.5, "貪婪": 0.5, "慎重": 0.5, "野心": 0.5, "求生欲": 0.5}
	l.skills = {"統領": 0.5}
	state.persons[10] = l; team.leader_id = 10; team.named_members = [10]
	state.teams[1] = team
	return [state, team]

# ①形狀判定：`ore_iron` 必須是 stock（★靜態 SHAPE_TABLE，不是 runtime 觀測）
func _test_shape_of_ore() -> void:
	print("--- ①shape_of ---")
	for res in ["ore_iron", "ore_gold", "ore_silver", "gem"]:
		var sh: String = AcquisitionPaths.shape_of(String(res))
		_ok(sh == "stock", "%s 形狀 = stock（實得 %s）" % [res, sh])

# ②★接線本體：世界上有礦 ⇒ `for_resource` 必須回得出 shape:"stock" 的 path（接線前這裡是空的）
func _test_for_resource_returns_stock_path() -> void:
	print("--- ②for_resource 回得出 stock path（★接線的陽性對照）---")
	var w: Array = _mk(); var state: WorldState = w[0]; var team: TeamData = w[1]
	var t: HexTileData = state.world.tiles[7 * 1000 + 5]
	t.resources["ore_iron"] = 300.0        # 一格有礦
	var paths: Array = AcquisitionPaths.for_resource(state, team, "ore_iron")
	var stock_paths: Array = []
	for p in paths:
		if String((p as Dictionary).get("shape", "")) == "stock":
			stock_paths.append(p)
	_ok(not stock_paths.is_empty(), "有礦的世界 → for_resource 回得出 stock path（%d 條）" % stock_paths.size())
	if not stock_paths.is_empty():
		var sp: Dictionary = stock_paths[0]
		_ok(sp.get("pos") == Vector2i(7, 5), "path 指到那格礦（實得 %s）" % str(sp.get("pos")))
		_ok(float(sp.get("amount", 0.0)) == 300.0, "amount = 現量 300（實得 %.1f）" % float(sp.get("amount", 0.0)))
		# gain_daily = productivity × current × COLLECT_RATE（★物理同源，非手抄）
		var expect: float = 1.0 * 300.0 * ResourceSystem.COLLECT_RATE
		_ok(is_equal_approx(float(sp.get("gain_daily", 0.0)), expect),
			"gain_daily 由真相源導出 = %.3f（實得 %.3f）" % [expect, float(sp.get("gain_daily", 0.0))])
		_ok(bool(sp.get("value_compared", false)), "value_compared = true（尺已存在，出口解封）")

# ③★定價：同一格礦，存量少 ⇒ util 必須被壓低（有限存量真的乘進去了）
func _test_stock_candidate_priced() -> void:
	print("--- ③stock candidate 真的被 stock_utility 壓過 ---")
	var vals: Dictionary = {"慎重": 0.5}
	var need: float = 8.0
	var gain: float = 8.0
	var flow_v: float = DiscountedFlow.flow_utility(gain, 0.0, need, vals, 0.0, 100.0)
	var rich: float = DiscountedFlow.stock_utility(gain, 0.0, need, vals, 0.0, 100.0, gain * 400.0)
	var poor: float = DiscountedFlow.stock_utility(gain, 0.0, need, vals, 0.0, 100.0, gain * 2.0)
	_ok(is_equal_approx(rich, flow_v), "存量大 → 與流打平（%.4f vs %.4f）" % [rich, flow_v])
	_ok(poor < flow_v * 0.5, "存量只夠 2 天 → 遠低於流（%.4f << %.4f）" % [poor, flow_v])
	# ★比值 ∈(0,1] ＝ goal_resolver 乘進 candidate util 的那個因子
	var ratio: float = poor / maxf(flow_v, 0.0001)
	_ok(ratio > 0.0 and ratio < 1.0, "finite_ratio ∈(0,1)（實得 %.4f）" % ratio)
