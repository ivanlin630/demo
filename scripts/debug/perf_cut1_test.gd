extends SceneTree
# perf cut1 TDD — A:_hex_dist static、B:find_nearest_terrain_tile call-scoped memo。
# 全安全道 byte-identical：static==instance 同值、memo==無memo 同結果、memo 命中不重掃。

var _fail := 0
func _ok(c: bool, m: String) -> void:
	if c: print("  PASS ", m)
	else: _fail += 1; print("  FAIL ", m)

func _init() -> void:
	print("=== perf cut1 test (刀A only, 刀B memo stripped) ===")
	_t_hexdist_static()
	_t_find_terrain()
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

# find_nearest_terrain_tile 純掃正確（刀B memo stripped=純掃回歸、刀A _hex_dist static 保留）
func _t_find_terrain() -> void:
	print("--- find_nearest_terrain_tile 純掃（memo stripped） ---")
	var state := _mk_state_with_forest([Vector2i(2,2), Vector2i(9,9)])
	var team := TeamData.new(); team.team_id = 0; team.tile_pos = Vector2i(1,1)
	_ok(GoalResolver.find_nearest_terrain_tile(state, team, "forest", 30) == Vector2i(2,2), "找最近 forest=(2,2)（純掃、刀A static _hex_dist）")
	# 見當下 state（移除 forest → 重掃回 (-1,-1)、無 stale cache）
	state.world.tiles[2002].terrain = "plains"; state.world.tiles[9009].terrain = "plains"
	_ok(GoalResolver.find_nearest_terrain_tile(state, team, "forest", 30) == Vector2i(-1,-1), "移除 forest→重掃見當下 state（無 stale memo）")
	# max_range 界
	var s2 := _mk_state_with_forest([Vector2i(10,10)])
	var t2 := TeamData.new(); t2.team_id = 1; t2.tile_pos = Vector2i(0,0)
	_ok(GoalResolver.find_nearest_terrain_tile(s2, t2, "forest", 3) == Vector2i(-1,-1), "max_range 界內無 forest→(-1,-1)")
