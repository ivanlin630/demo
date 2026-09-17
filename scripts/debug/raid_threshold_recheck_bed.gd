extends SceneTree
# @bed-kind: acceptance
# slice: 掠奪門檻複查(defer raid-threshold-recheck-after-grudge 到期，DISPATCH 2026-09-17)
#
# ★★★同一組 fixture 不要換：世界構造逐字照 headless_test.gd `_test_solo_seek_home`
#   （常態、鄰居 pop 2、raider 好戰/貪婪 動機軸、raider 自己不餓）——只換 prey_food 與人格兩個旋鈕。
# ★問法：恩怨帳 Slice A 把「名聲/記恨」接進 trade_valuation 之後，
#   f=1500 尾部(好戰.9/貪婪.9)的掠奪 util，相對紮營，有沒有動？
#   同一組情境只差人格，f=1500 中庸(.5/.5)必須仍不搶、f=8000 尾部必須仍會搶(不准退步)。

func _initialize() -> void:
	_run(); quit(0)

func _world(prey_food: float) -> Dictionary:
	# ★逐字照headless_test.gd _test_solo_seek_home的世界構造(只換 arm_and_new 入口，
	#   理由=新床受bed-arm閘管，見raid_expected_value_bed.gd同款註解；功能等價，Probe.arm()是pure)——
	#   ★★連「prey自己的家格不設resource_cap」這個細節都照抄，不隨手補齊。
	var state := MeasureBedHelper.arm_and_new()
	for p in [Vector2i(4, 4), Vector2i(5, 4)]:
		var tile := HexTileData.new()
		tile.tile_id = p.x * 1000 + p.y; tile.tile_pos = p; tile.terrain = "plains"
		tile.outpost_owner = -1; tile.outpost_level = 0; tile.resource_cap = {"food": 50.0}
		state.world.tiles[tile.tile_id] = tile
	var ptile := HexTileData.new()
	ptile.tile_id = 3 * 1000 + 4; ptile.tile_pos = Vector2i(3, 4); ptile.terrain = "plains"
	state.world.tiles[ptile.tile_id] = ptile
	var prey := TeamData.new(); prey.team_id = 9; prey.tile_pos = Vector2i(3, 4)
	_seed_pop(prey, 2); prey.faction_id = -1; prey.resources = {"food": prey_food}
	state.teams[9] = prey
	var t1 := TeamData.new(); t1.team_id = 1; t1.tile_pos = Vector2i(4, 4)
	_seed_pop(t1, 10); t1.tags = ["軍隊"]; t1.current_task = TeamData.TASK_IDLE
	t1.resources = {"food": 100.0}; t1.armed_anon_ratio = 1.0   # 常態：food_days≈12.5，遠高於絕境線
	state.teams[1] = t1
	state.team_discovered[1] = [9]
	BeliefSystem.record_claim(state, 1, 9, 1, "親見", {"population_est": 2, "armed_est": 1,
		"food_est": prey_food, "tile_pos": Vector2i(3, 4), "last_tick": state.world.current_tick}, 1.0, false)
	return {"state": state, "team": t1}

func _seed_pop(t: TeamData, n: int) -> void:
	var cur: int = AnonCohort.total(t.anon_cohorts)
	if n - cur > 0: AnonCohort.add(t.anon_cohorts, "平民", "healthy", n - cur)

func _cell(label: String, prey_food: float, fierce: float) -> Dictionary:
	var w: Dictionary = _world(prey_food)
	var state: WorldState = w["state"]; var t1: TeamData = w["team"]
	var ldr := PersonData.new(); ldr.id = 1000; ldr.team_id = 1
	ldr.values = {"好戰": fierce, "貪婪": fierce, "野心": 0.5, "求生欲": 0.5}   # 逐字照原fixture(缺鍵預設0.5,不多不少)
	state.persons[1000] = ldr; t1.leader_id = 1000
	var ctx: DecisionContext = DecisionContext.gather(state, t1)
	var rows: Array = []
	var loot_u: float = -1.0; var camp_u: float = -1.0; var top_opt: String = ""; var top_u: float = -1.0
	for e in DecisionEngine.rank_scored(state, t1, "raid_recheck"):
		var opt: String = String(e["opt"]); var u: float = float(e["u"])
		rows.append("%s=%.4f" % [opt, u])
		if top_opt == "": top_opt = opt; top_u = u
		if opt == "掠奪": loot_u = u
		if opt == "紮營": camp_u = u
	print("★%s：food_days=%.1f(門檻%.1f，常態) 掠奪=%.4f 紮營=%.4f 首選=%s(%.4f)" % [
		label, ctx.food_days, ctx.desperation_entry_threshold, loot_u, camp_u, top_opt, top_u])
	print("   完整表：%s" % " ".join(rows))
	return {"loot": loot_u, "camp": camp_u, "top": top_opt, "raid": top_opt == "掠奪"}

func _run() -> void:
	print("=== 掠奪門檻複查：恩怨帳Slice A merge後，同一組fixture三格 ===")
	var c1500_fierce: Dictionary = _cell("f=1500 尾部(好戰/貪婪.9)", 1500.0, 0.9)
	var c1500_mid: Dictionary = _cell("f=1500 中庸(.5/.5)", 1500.0, 0.5)
	var c8000_fierce: Dictionary = _cell("f=8000 尾部(好戰/貪婪.9)", 8000.0, 0.9)
	print("")
	print("-- 三種預寫結果對號 --")
	if c1500_fierce["raid"] and not c1500_mid["raid"]:
		print("★判：尾部在1500翻成會搶、中庸仍不搶 ⇒ 缺項補上了 ⇒ 這條線收案")
	elif (not c1500_fierce["raid"]) and absf(float(c1500_fierce["loot"]) - 0.0833) > 0.0001:
		print("★判：尾部在1500仍不搶、但差距有變 ⇒ 方向對量級不夠 ⇒ 交新gap表，不准調係數")
	elif (not c1500_fierce["raid"]) and is_equal_approx(float(c1500_fierce["loot"]), 0.0833):
		print("★判：完全沒動(util逐字=0.0833舊值) ⇒ 恩怨帳的讀者沒有走到掠奪這條路 ⇒ 回報systems，接上了但沒通電")
	else:
		print("★判：不在三種預寫之內，如實報數字不硬套")
	if not c8000_fierce["raid"]:
		push_error("[FAIL] f=8000尾部退步成不搶了——不准退步")
	print("-- 完成 --")
