# scripts/ui/text_map_renderer.gd
class_name TextMapRenderer

const VISION_RADIUS: int = 3   # 與 VisionSystem 一致（TEST VALUE）
const VIEW_RADIUS: int = 5     # 視窗半徑（以玩家為中心顯示的範圍,> VISION_RADIUS 留霧邊）
const TERRAIN_CHAR: Dictionary = { "plains": "P", "forest": "F", "mountain": "M" }

# U16: 以玩家所在格為中心的視窗（@ 永遠在正中,地圖在底下捲）。
# axial 投影:列 dr 的水平位移 = dq + dr/2 → 用累進切變（每列右移半格 = 2 字元）。
# 舊版渲染整張地圖絕對座標 + @ 放玩家絕對位置 → 玩家偏離地圖中心時 @ 不在視窗中央（U16 真因）。
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

	# 以玩家為中心的視窗:dr/dq ∈ [-VIEW_RADIUS, VIEW_RADIUS]，hex 距離內才畫。
	# 每列累進切變 indent = (dr + VIEW_RADIUS) * 2（dr 由上到下遞增 → 右移）。
	var lines: Array = []
	for dr in range(-VIEW_RADIUS, VIEW_RADIUS + 1):
		var indent: String = "  ".repeat(dr + VIEW_RADIUS)
		var line: String = indent
		for dq in range(-VIEW_RADIUS, VIEW_RADIUS + 1):
			if _hex_dist(Vector2i(dq, dr), Vector2i.ZERO) > VIEW_RADIUS:
				line += "    "   # 視窗外（菱形外緣）留白,維持對齊
				continue
			var pos: Vector2i = player_pos + Vector2i(dq, dr)
			line += _cell(state, pos, player_pos, player_tid, cursor, discovered, team_at)
		lines.append(line)
	return "\n".join(lines)

static func _cell(state: WorldState, pos: Vector2i, player_pos: Vector2i,
		player_tid: int, cursor: Vector2i,
		discovered: Array, team_at: Dictionary) -> String:
	# 玩家標記恆畫（即使腳下 tile 資料缺,@ 也要在視窗正中顯示）
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
