extends SceneTree

# perf slice A TDD：_nearest_market_outpost/_with skip_refresh=true 讀既有 cache 回同值（vs refresh 版同結果=byte-identical）。

var _fail: int = 0
func _ok(c: bool, m: String) -> void:
	if c: print("  [PASS] %s" % m)
	else: _fail += 1; print("  [FAIL] %s" % m)

func _initialize() -> void:
	var state := WorldState.new(); state.world = WorldData.new(); state.world.current_tick = 1000
	var team := TeamData.new(); team.team_id = 1; team.faction_id = 0; team.tile_pos = Vector2i(5,5); state.teams[1] = team
	# 一個他隊市集 outpost（有貨），塞進 team_market_known cache。
	var mkt := HexTileData.new(); mkt.tile_pos = Vector2i(8,5); mkt.outpost_level = 1; mkt.outpost_owner = 2
	mkt.public_storage = {"food": 50.0, "material": 30.0}
	state.world.tiles[8005] = mkt
	state.team_market_known[1] = {8005: true}
	var fai := FactionAISystem.new()
	# refresh 一次(caller 側)。
	fai._harvest_market_known(state, team)

	var a_skip: Vector2i = fai._nearest_market_outpost(state, team, true)    # skip refresh、讀 cache
	var a_ref: Vector2i = fai._nearest_market_outpost(state, team, false)    # refresh + 讀
	_ok(a_skip == a_ref, "★_nearest_market_outpost skip_refresh=true 回同值 %s == refresh 版 %s（byte-identical、去冗餘二刷）" % [str(a_skip), str(a_ref)])

	var m_skip: Vector2i = fai._nearest_market_outpost_with(state, team, "material", true)
	var m_ref: Vector2i = fai._nearest_market_outpost_with(state, team, "material", false)
	_ok(m_skip == m_ref, "★_nearest_market_outpost_with skip_refresh=true 回同值 %s == refresh 版 %s" % [str(m_skip), str(m_ref)])
	_ok(a_skip != Vector2i(-1,-1), "market finder 真回市集位（非空、確有 exercise）")

	if _fail == 0: print("=== DONE === ALL PASS")
	else: print("=== DONE === %d FAIL" % _fail)
	quit()
