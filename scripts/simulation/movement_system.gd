class_name MovementSystem

const BASE_MOVE_TICKS: int = 10
const MIN_MOVE_TICKS: int = 3
const MAX_MOVE_TICKS: int = 30

const TERRAIN_SPEED_MULT: Dictionary = {
	"plains":   1.0,
	"forest":   0.7,
	"mountain": 0.4,
}

func process(state: WorldState, team_ids: Array) -> Array:
	# 護衛：每 tick 追蹤目標位置
	for tid in team_ids:
		if not state.teams.has(tid):
			continue
		var team: TeamData = state.teams[tid]
		if team.current_task != "護衛" or team.order_target_id == -1:
			continue
		var target: TeamData = state.teams.get(team.order_target_id)
		if target == null:
			team.current_task    = "idle"
			team.order_target_id = -1
		else:
			team.move_target = target.tile_pos
	var arrived: Array = []
	for tid in team_ids:
		if not state.teams.has(tid):
			continue
		var team: TeamData = state.teams[tid]
		if team.combat_target != -1:
			continue
		if team.move_target == Vector2i(-1, -1):
			continue
		var cost: int = _move_cost(state, team)
		team.move_tick_acc += 1
		if team.move_tick_acc < cost:
			continue
		team.move_tick_acc = 0
		if _step_team(state, team):
			arrived.append(tid)
	return arrived

func _move_cost(state: WorldState, team: TeamData) -> int:
	var speed: float = _compute_team_speed(state, team)
	var tile_id: int = team.tile_pos.x * 1000 + team.tile_pos.y
	if state.world.tiles.has(tile_id):
		var terrain: String = (state.world.tiles[tile_id] as HexTileData).terrain
		speed *= TERRAIN_SPEED_MULT.get(terrain, 1.0)
	return clamp(int(round(float(BASE_MOVE_TICKS) / maxf(speed, 0.01))), MIN_MOVE_TICKS, MAX_MOVE_TICKS)

func _compute_team_speed(state: WorldState, team: TeamData) -> float:
	var total_speed: float = 0.0
	var total_count: int = 0
	var named_ids: Array = team.named_members
	if team.leader_id != -1:
		named_ids.append(team.leader_id)
	for pid in named_ids:
		var p = state.persons.get(pid)
		if p != null:
			total_speed += p.get_effective_speed()
			total_count += 1
	var unnamed_healthy: int = maxi(team.population - total_count - team.wounded, 0)
	total_speed += float(unnamed_healthy) * 1.0
	total_count += unnamed_healthy
	total_speed += float(team.wounded) * 0.5
	total_count += team.wounded
	if total_count == 0:
		return 1.0
	return total_speed / float(total_count)

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
