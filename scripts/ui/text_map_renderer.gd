# scripts/ui/text_map_renderer.gd
class_name TextMapRenderer

const VISION_RADIUS: int = 3   # 與 VisionSystem 一致（TEST VALUE）
const TERRAIN_CHAR: Dictionary = { "plains": "P", "forest": "F", "mountain": "M" }

static func render(state: WorldState, player_tid: int, cursor: Vector2i) -> String:
	var player_team: TeamData = state.teams.get(player_tid)
	var player_pos: Vector2i  = player_team.tile_pos if player_team else Vector2i(4, 4)
	var discovered: Array     = state.team_discovered.get(player_tid, [])

	# 找地圖邊界
	var xs: Array = []; var ys: Array = []
	for tile in state.world.tiles.values():
		xs.append(tile.tile_pos.x); ys.append(tile.tile_pos.y)
	if xs.is_empty(): return "（無地圖）"
	var xmin: int = xs.min(); var xmax: int = xs.max()
	var ymin: int = ys.min(); var ymax: int = ys.max()
	var mid_y: int = (ymin + ymax) / 2

	# 建 team 位置查詢表（tile_key → team_id list）
	var team_at: Dictionary = {}
	for tid in state.teams:
		var t: TeamData = state.teams[tid]
		var k: int = t.tile_pos.x * 1000 + t.tile_pos.y
		if not team_at.has(k): team_at[k] = []
		(team_at[k] as Array).append(tid)

	# 計算 display_col 範圍
	# display_col = tile_pos.x + int(floor(float(tile_pos.y - mid_y) / 2.0))
	var dcol_min: int = 9999; var dcol_max: int = -9999
	for tile in state.world.tiles.values():
		var dcol: int = tile.tile_pos.x + int(floor(float(tile.tile_pos.y - mid_y) / 2.0))
		if dcol < dcol_min: dcol_min = dcol
		if dcol > dcol_max: dcol_max = dcol

	# Render: 每個 display_row 輸出兩個子行
	# 偶數 dcol（相對 dcol_min）→ even_line；奇數 → odd_line（縮排 1 空格）
	var lines: Array = []
	for drow in range(ymin, ymax + 1):
		var even_line: String = ""
		var odd_line:  String = " "
		for dcol in range(dcol_min, dcol_max + 1):
			# 反推 tile_pos：tile_pos.x = dcol - int(floor(float(drow - mid_y) / 2.0))
			var tx: int = dcol - int(floor(float(drow - mid_y) / 2.0))
			var pos := Vector2i(tx, drow)
			var cell := _cell(state, pos, player_pos, player_tid, cursor, discovered, team_at)
			if (dcol - dcol_min) % 2 == 0:
				even_line += cell
			else:
				odd_line += cell
		lines.append(even_line)
		lines.append(odd_line)
	return "\n".join(lines)

static func _cell(state: WorldState, pos: Vector2i, player_pos: Vector2i,
		player_tid: int, cursor: Vector2i,
		discovered: Array, team_at: Dictionary) -> String:
	var tile_key: int = pos.x * 1000 + pos.y
	var tile = state.world.tiles.get(tile_key)
	if tile == null:
		# 不在地圖
		var content := "   "
		if pos == cursor: content = "[ ]"
		return content

	# 決定格子基本符號
	var dist: int = _hex_dist(player_pos, pos)
	var in_vision: bool = dist <= VISION_RADIUS

	# 確認是否已探索（視野內 → 自動已探索；暫以 in_vision 代替 explored 追蹤）
	var explored: bool = in_vision  # TODO: 可加 WorldState 已探索 tile 清單

	var ch: String
	# 玩家位置
	if pos == player_pos:
		ch = "@"
	else:
		# 已發現的 team 在此格
		var known_tid: int = _visible_team(team_at, tile_key, discovered, player_tid)
		if known_tid >= 0:
			ch = str(known_tid % 10)
		elif in_vision:
			ch = TERRAIN_CHAR.get(tile.terrain, "P")
		elif explored:
			ch = TERRAIN_CHAR.get(tile.terrain, "P").to_lower()
		else:
			ch = "?"

	# 游標包圍
	var cell: String
	if pos == cursor:
		cell = "[%s]" % ch
	else:
		cell = "%s  " % ch   # 3 chars: symbol + 2 spaces

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
