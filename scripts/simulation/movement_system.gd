class_name MovementSystem

const BASE_MOVE_TICKS: int = 10
const MIN_MOVE_TICKS: int = 3
const MAX_MOVE_TICKS: int = 30

func process(state: WorldState, team_ids: Array) -> Array:
	var arrived: Array = []
	for tid in team_ids:
		var team: TeamData = state.teams[tid]
		if team.combat_target != -1:
			continue
		if team.move_target == Vector2i(-1, -1):
			continue
		var cost: int = _move_cost(team)
		team.move_tick_acc += 1
		if team.move_tick_acc < cost:
			continue
		team.move_tick_acc = 0
		if _step_team(state, team):
			arrived.append(tid)
	return arrived

func _move_cost(team: TeamData) -> int:
	return clamp(int(round(float(BASE_MOVE_TICKS) / team.move_speed)), MIN_MOVE_TICKS, MAX_MOVE_TICKS)

# 未來替換此函數實作 A* 路徑，_on_arrival 介面不變
func _step_team(state: WorldState, team: TeamData) -> bool:
	var old_pos: Vector2i = team.tile_pos
	if team.tile_pos == team.move_target:
		team.move_target = Vector2i(-1, -1)
		_on_arrival(state, team)
		return false
	var best_pos: Vector2i = team.tile_pos
	var best_dist: int = _hex_dist(team.tile_pos, team.move_target)
	for neighbor in _get_neighbors(team.tile_pos):
		var d: int = _hex_dist(neighbor, team.move_target)
		if d < best_dist:
			best_dist = d
			best_pos = neighbor
	team.tile_pos = best_pos
	if team.tile_pos == team.move_target:
		team.move_target = Vector2i(-1, -1)
		_on_arrival(state, team)
	return team.tile_pos != old_pos

# 抵達只更新占用，不自動建立據點（據點建立為獨立 NPC 決策）
func _on_arrival(state: WorldState, team: TeamData) -> void:
	var tile_id: int = team.tile_pos.x * 1000 + team.tile_pos.y
	if state.world.tiles.has(tile_id):
		var tile: HexTileData = state.world.tiles[tile_id]
		tile.occupied_by = team.team_id
	print("[Move] Team %d 抵達 (%d,%d)" % [team.team_id, team.tile_pos.x, team.tile_pos.y])

func _get_neighbors(pos: Vector2i) -> Array:
	return [
		pos + Vector2i(1, 0),  pos + Vector2i(-1, 0),
		pos + Vector2i(0, 1),  pos + Vector2i(0, -1),
		pos + Vector2i(1, -1), pos + Vector2i(-1, 1),
	]

func _hex_dist(a: Vector2i, b: Vector2i) -> int:
	var dx := b.x - a.x
	var dy := b.y - a.y
	return (abs(dx) + abs(dx + dy) + abs(dy)) / 2
