# scripts/ui/text_map_renderer.gd
class_name TextMapRenderer

const VISION_RADIUS: int = VisionSystem.VISION_RADIUS   # 引用 sim 權威源（單一真值）
const TERRAIN_CHAR: Dictionary = { "plains": "P", "forest": "F", "mountain": "M" }

# ★F10（spec 2026-10-07 round5-friendliness §F10，用戶裁 藍圖 4d70c8aad②）：視窗＝整張地圖
#   ⇒ 視窗中心＝地圖中心、半徑＝地圖半徑，兩者都從 state.world.tiles 的座標範圍算（儲存座標中心在 (N,N) 不是 (0,0)；
#     world_generator 的 radius 是 config、生成後沒存進 state ⇒ 不寫死）
#   ⇒ @ 畫在玩家實際位置（舊 U16「@ 永遠在正中、地圖在底下捲」那條由這一條取代）
# axial 投影:列 dr 的水平位移 = dq + dr/2 → 用累進切變（每列右移半格 = 2 字元）。
#   寬度：r=8 ⇒ 每列 17 格 × 4 字＝68，加最末列切變縮排 2 × 2r＝32 ⇒ 最寬 100 欄
static func map_extent(state: WorldState) -> Dictionary:
	var qmin: int = 1 << 30
	var qmax: int = -(1 << 30)
	var rmin: int = 1 << 30
	var rmax: int = -(1 << 30)
	for k in state.world.tiles.keys():
		var q: int = int(k) / 1000
		var r: int = int(k) % 1000
		qmin = mini(qmin, q); qmax = maxi(qmax, q)
		rmin = mini(rmin, r); rmax = maxi(rmax, r)
	if qmin > qmax:
		return {"center": Vector2i.ZERO, "radius": 0}
	var c := Vector2i((qmin + qmax) / 2, (rmin + rmax) / 2)
	var rad: int = 0
	for k2 in state.world.tiles.keys():
		rad = maxi(rad, _hex_dist(c, Vector2i(int(k2) / 1000, int(k2) % 1000)))
	return {"center": c, "radius": rad}


static func render(state: WorldState, player_tid: int, cursor: Vector2i) -> String:
	var player_team: TeamData = state.teams.get(player_tid)
	var player_pos: Vector2i  = player_team.tile_pos if player_team else Vector2i(4, 4)
	var discovered: Array     = state.team_discovered.get(player_tid, [])

	# team 位置查詢表（tile_key → team_id list）
	var team_at: Dictionary = {}
	for tid in state.teams:
		var t: TeamData = state.teams[tid]
		var k: int = t.tile_pos.x * 1000 + t.tile_pos.y
		if not team_at.has(k): team_at[k] = []
		(team_at[k] as Array).append(tid)

	# 以地圖中心為中心的整張視窗:dr/dq ∈ [-R, R]，hex 距離內才畫。
	# 每列累進切變 indent = (dr + R) * 2（dr 由上到下遞增 → 右移）。
	var ext: Dictionary = map_extent(state)
	var center: Vector2i = ext["center"]
	var view_r: int = int(ext["radius"])
	var lines: Array = []
	for dr in range(-view_r, view_r + 1):
		var indent: String = "  ".repeat(dr + view_r)
		var line: String = indent
		for dq in range(-view_r, view_r + 1):
			if _hex_dist(Vector2i(dq, dr), Vector2i.ZERO) > view_r:
				line += "    "   # 視窗外（菱形外緣）留白,維持對齊
				continue
			var pos: Vector2i = center + Vector2i(dq, dr)
			line += _cell(state, pos, player_pos, player_tid, cursor, discovered, team_at)
		lines.append(line)
	return "\n".join(lines)

static func _cell(state: WorldState, pos: Vector2i, player_pos: Vector2i,
		player_tid: int, cursor: Vector2i,
		discovered: Array, team_at: Dictionary) -> String:
	# 玩家標記恆畫（即使腳下 tile 資料缺也畫 @）
	if pos == player_pos:
		return "[@] " if pos == cursor else "@   "
	var tile_key: int = pos.x * 1000 + pos.y
	var tile = state.world.tiles.get(tile_key)
	if tile == null:
		# 不在地圖（4 chars）
		var content := "    "
		if pos == cursor: content = "[ ] "
		return content

	var dist: int = _hex_dist(player_pos, pos)
	var in_vision: bool = dist <= VISION_RADIUS
	var explored: bool = in_vision  # TODO: 可加 WorldState 已探索 tile 清單

	var ch: String
	if pos == player_pos:
		ch = "@"
	else:
		var known_tid: int = _visible_team(team_at, tile_key, discovered, player_tid)
		if known_tid >= 0:
			ch = str(known_tid % 10)
		elif in_vision:
			ch = TERRAIN_CHAR.get(tile.terrain, "P")
		elif explored:
			ch = TERRAIN_CHAR.get(tile.terrain, "P").to_lower()
		else:
			ch = "?"

	var cell: String
	if pos == cursor:
		cell = "[%s] " % ch   # 4 chars
	else:
		cell = "%s   " % ch   # 4 chars
	return cell

static func _visible_team(team_at: Dictionary, key: int, discovered: Array, player_tid: int) -> int:
	if not team_at.has(key): return -1
	for tid in (team_at[key] as Array):
		if tid == player_tid: continue
		if discovered.has(tid): return tid
	return -1

static func _hex_dist(a: Vector2i, b: Vector2i) -> int:
	var dx := b.x - a.x; var dy := b.y - a.y
	return (abs(dx) + abs(dx + dy) + abs(dy)) / 2
