extends SceneTree

# spawn-offmap-guard 守衛：開局全隊初始 tile_pos 皆 in-map（0 越界）。
# 跑數 seed × 小半徑（逼邊緣觸發原 _random_near bug）。

var _pass: int = 0
var _fail: int = 0

func _check(cond: bool, msg: String) -> void:
	if cond:
		_pass += 1
	else:
		_fail += 1
		print("  [FAIL] ", msg)

func _initialize() -> void:
	print("=== spawn_offmap_guard_test ===")
	# 小半徑 = 邊緣格佔比高 → 原 _random_near origin+dir 易越界。
	var radii: Array = [2, 3, 4]
	var seeds: Array = [1, 7, 13, 42, 99, 137, 256, 512, 1024, 2048]
	var total_teams: int = 0
	var offmap: int = 0
	for radius in radii:
		for seed in seeds:
			var state := WorldState.new()
			GameSetup.setup(state, {
				"seed": seed,
				"map": {"radius": radius, "resource_richness": 5},
			})
			for tid in state.teams:
				total_teams += 1
				var pos: Vector2i = state.teams[tid].tile_pos
				var key: int = pos.x * 1000 + pos.y
				if not state.world.tiles.has(key):
					offmap += 1
					if offmap <= 5:
						print("  [OFFMAP] radius=%d seed=%d team=%d pos=(%d,%d)" % [
							radius, seed, tid, pos.x, pos.y])

	_check(total_teams > 0, "生成隊數 >0 (setup 有跑)")
	_check(offmap == 0, "0 越界 (掃 %d 隊,%d 越界)" % [total_teams, offmap])
	print("=== spawn_offmap_guard_test: 隊=%d 越界=%d PASS=%d FAIL=%d ===" % [total_teams, offmap, _pass, _fail])
	if _fail == 0:
		print("[SPAWN-OFFMAP-GUARD] ALL PASS")
	else:
		print("[SPAWN-OFFMAP-GUARD] FAILED")
	quit()
