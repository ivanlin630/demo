extends SceneTree
# perf cut1 TDD — A:_hex_dist static、B:find_nearest_terrain_tile call-scoped memo。
# 全安全道 byte-identical：static==instance 同值、memo==無memo 同結果、memo 命中不重掃。

var _fail := 0
func _ok(c: bool, m: String) -> void:
	if c: print("  PASS ", m)
	else: _fail += 1; print("  FAIL ", m)

func _init() -> void:
	print("=== perf cut1 test ===")
	_t_hexdist_static()
	_t_memo()
	if _fail == 0: print("ALL PASS")
	else: print("FAILS=%d" % _fail)
	quit()

# A：static _hex_dist 值正確 + == instance 呼（byte-identical）
func _t_hexdist_static() -> void:
	print("--- A: _hex_dist static ---")
	var cases := [
		[Vector2i(0,0), Vector2i(0,0), 0],
		[Vector2i(0,0), Vector2i(3,0), 3],
		[Vector2i(0,0), Vector2i(0,3), 3],
		[Vector2i(0,0), Vector2i(3,-3), 3],   # hex axial
		[Vector2i(2,2), Vector2i(-1,-1), 6],
		[Vector2i(5,5), Vector2i(8,1), 4],
	]
	var fai := FactionAISystem.new()
	for c in cases:
		var s: int = FactionAISystem._hex_dist(c[0], c[1])   # static
		var i: int = fai._hex_dist(c[0], c[1])               # instance (static via instance)
		_ok(s == c[2] and s == i, "hex_dist(%s,%s)=%d static==instance==expected" % [str(c[0]), str(c[1]), s])

func _mk_state_with_forest(fpos: Array) -> WorldState:
	var state := WorldState.new(); state.world = WorldData.new()
	# 底 plains 大格 + 指定 forest 位
	for x in range(0, 12):
		for y in range(0, 12):
			var t := HexTileData.new()
			t.tile_id = x*1000+y; t.tile_pos = Vector2i(x,y); t.terrain = "plains"
			state.world.tiles[t.tile_id] = t
	for p in fpos:
		state.world.tiles[p.x*1000+p.y].terrain = "forest"
	return state

# B：call-scoped memo == 無 memo（byte-identical）+ 命中不重掃（memo hit 回 cached）
func _t_memo() -> void:
	print("--- B: find_nearest_terrain_tile memo ---")
	var state := _mk_state_with_forest([Vector2i(2,2), Vector2i(9,9)])
	var team := TeamData.new(); team.team_id = 0; team.tile_pos = Vector2i(1,1)
	# 無 memo（default {}）
	var no_memo: Vector2i = GoalResolver.find_nearest_terrain_tile(state, team, "forest", 30)
	# 有 memo
	var memo: Dictionary = {}
	var with_memo: Vector2i = GoalResolver.find_nearest_terrain_tile(state, team, "forest", 30, memo)
	_ok(no_memo == with_memo, "memo==無 memo 同結果（byte-identical、nearest forest=%s）" % str(with_memo))
	_ok(memo.has("forest:30") and memo["forest:30"] == with_memo, "memo 填入 key=forest:30")
	# 命中不重掃：改 state（移除 forest）但用同 memo → 回 cached（證 memo hit、非重掃）
	state.world.tiles[2002].terrain = "plains"; state.world.tiles[9009].terrain = "plains"
	var cached: Vector2i = GoalResolver.find_nearest_terrain_tile(state, team, "forest", 30, memo)
	_ok(cached == with_memo, "同 memo 二呼→回 cached（命中不重掃、call-scoped 首掃後複用）")
	# 新 memo（模擬下一 frontier call）→ 重掃見新 state（無 forest → (-1,-1)）=無跨 tick leak
	var fresh: Vector2i = GoalResolver.find_nearest_terrain_tile(state, team, "forest", 30, {})
	_ok(fresh == Vector2i(-1, -1), "新 memo（新 frontier call）→ 重掃見當下 state（無跨 tick leak）")
	# max_range 界：forest 遠於 range → 不選
	var s2 := _mk_state_with_forest([Vector2i(10,10)])
	var t2 := TeamData.new(); t2.team_id = 1; t2.tile_pos = Vector2i(0,0)
	_ok(GoalResolver.find_nearest_terrain_tile(s2, t2, "forest", 3, {}) == Vector2i(-1,-1), "max_range 界內無 forest→(-1,-1)")
