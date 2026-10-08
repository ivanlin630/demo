extends SceneTree
# @bed-kind: invariant
# slice: 票 #9 地圖記憶＋地圖上的 god-view 漏（spec 2026-09-29-map-memory-and-godview-leak-HOW）
#
# ★派工：先跑 P3【全程移動不停】的走法 —— 紅 ⇒ 停手回報（harvest 搬層是 systems 改 spec 的事）
# P3 玩家一路移動（到了就換下一個遠目標、從不停下）⇒ 走過再離開的每一格都在 team_tile_known[玩家] 裡
#    ★母體地板：先印 team_tile_known[玩家].size()（0 ⇒ 不是記憶沒生效，是段 1 前提不成立，分開講）
#    ★走法照真玩家那條路：PlayerCommandSystem.move_to（同 M 鍵），不佈置抵達
# 跑法：.\tools\godot.ps1 --headless --script scripts/debug/map_memory_bed.gd

var _errors: int = 0
const DAYS: int = 6


func _check(msg: String, cond: bool) -> void:
	if cond:
		print("  PASS: " + msg)
	else:
		_errors += 1
		push_error("[FAIL] " + msg)


func _initialize() -> void:
	print("=== #9 地圖記憶 ===")
	_p3_full_movement()
	print("\n=== map_memory DONE === errors: %d" % _errors)
	quit(1 if _errors > 0 else 0)


static func _hex(a: Vector2i, b: Vector2i) -> int:
	var dx: int = b.x - a.x
	var dy: int = b.y - a.y
	return (absi(dx) + absi(dx + dy) + absi(dy)) / 2


func _p3_full_movement() -> void:
	print("\n── P3 全程移動不停：走過再離開的格都記得 ──")
	seed(20261008)
	var st: WorldState = MeasureBedHelper.arm_and_new()
	GameSetup.setup(st, GameSetup.load_config("res://config/warring_states.json"))
	var runner := SimRunner.new()
	var cs := PlayerCommandSystem.new()
	var ptid: int = st.get_player_team_id()
	var pt: TeamData = st.teams[ptid]
	# 目標序列：地圖上離目前最遠的那幾格輪流去（確定性：依 tile 鍵排序）
	var keys: Array = st.world.tiles.keys()
	keys.sort()
	var visited: Dictionary = {}   # tile_key → 第一次站上去的 tick
	var last_pos: Vector2i = pt.tile_pos
	var legs: int = 0
	var idle_ticks: int = 0
	for _i in range(DAYS * WorldState.TICKS_PER_DAY):
		if pt.move_target == Vector2i(-1, -1) or pt.move_target == pt.tile_pos:
			var best: Vector2i = pt.tile_pos
			var bd: int = -1
			for k in keys:
				var p := Vector2i(int(k) / 1000, int(k) % 1000)
				var d: int = _hex(p, pt.tile_pos)
				if d > bd and not visited.has(int(k)):
					bd = d
					best = p
			cs.move_to(st, best)
			legs += 1
		if pt.move_target == Vector2i(-1, -1):
			idle_ticks += 1
		runner.advance_tick(st, pt.tile_pos)
		if not st.teams.has(ptid):
			break
		if pt.tile_pos != last_pos:
			visited[last_pos.x * 1000 + last_pos.y] = true
			last_pos = pt.tile_pos
	var known: Dictionary = st.team_tile_known.get(ptid, {})
	var left: Array = visited.keys()
	var miss: Array = []
	for k2 in left:
		if not known.has(k2):
			miss.append(Vector2i(int(k2) / 1000, int(k2) % 1000))
	print("   %d 天、%d 段路、沒有目標的 tick %d｜走過再離開的格 %d｜team_tile_known[玩家] %d 格｜走過卻沒記得 %d：%s" % [
		DAYS, legs, idle_ticks, left.size(), known.size(), miss.size(), str(miss.slice(0, 10))])
	_check("★P3 母體地板：玩家真的一路在走（走過再離開的格 ≥ 10）", left.size() >= 10)
	_check("★P3 段 1 前提：team_tile_known[玩家] 非空（%d）" % known.size(), known.size() > 0)
	_check("P3 全程移動：走過再離開的每一格都記得（漏 %d）" % miss.size(), miss.is_empty() and left.size() >= 10)
