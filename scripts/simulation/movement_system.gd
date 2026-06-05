class_name MovementSystem

# world-hex 移動成本 = encounter-hex 動作時間 × 地圖直徑 / 世界速度倍率
const WORLD_SPEED_MULT: int = 2    # TEST VALUE — 倍率=2 → 0.5天/hex（normal speed, plains, daytime）
const BASE_MOVE_TICKS: int = EncounterSystem.BASE_ACTION_TICKS * EncounterSystem.MAP_DIAMETER / WORLD_SPEED_MULT
const MIN_MOVE_TICKS: int  = BASE_MOVE_TICKS / 3
const MAX_MOVE_TICKS: int  = BASE_MOVE_TICKS * 3

const TERRAIN_SPEED_MULT: Dictionary = {
	"plains":   1.0,
	"forest":   0.7,
	"mountain": 0.4,
}

const BASE_CARRY: float   = 10.0   # TEST VALUE
const MOUNT_BONUS: float  = 15.0   # TEST VALUE
const WAGON_BONUS: float  = 40.0   # TEST VALUE
const STRAY_RATE: float   = 0.1    # TEST VALUE 超額馱獸流失率

const WAGON_TERRAIN_MULT: Dictionary = {
	"plains": 0.9, "forest": 0.4, "mountain": 0.2
}

func process(state: WorldState, team_ids: Array,
		time_mult: float = 1.0) -> Array:
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
		_tick_stray_mounts(team)
		if team.combat_target != -1:
			continue
		# strategic_assignments 優先（-1 key = 突圍；正整數 key = 包圍目標）
		if team.strategic_assignments.size() > 0 and team.current_task != "逃跑":
			var sa_target: Vector2i
			if team.strategic_assignments.has(-1):
				sa_target = team.strategic_assignments[-1]
			else:
				sa_target = team.strategic_assignments.values()[0]
			if team.move_target == Vector2i(-1, -1) or team.move_target == team.tile_pos:
				team.move_target = sa_target
		if team.move_target == Vector2i(-1, -1):
			continue
		var cost: int = _move_cost(state, team, time_mult)
		team.move_tick_acc += WorldState.TICKS_PER_HOUR
		if team.move_tick_acc < cost:
			continue
		team.move_tick_acc = 0
		if _step_team(state, team):
			arrived.append(tid)
	return arrived

func get_effective_mounts(team: TeamData) -> int:
	return mini(int(team.resources.get("mounts", 0)), team.population)

func get_effective_wagons(team: TeamData) -> int:
	return mini(int(team.resources.get("wagons", 0)), team.population)

func get_carry_capacity(team: TeamData) -> float:
	return team.population * BASE_CARRY \
		+ get_effective_mounts(team) * MOUNT_BONUS \
		+ get_effective_wagons(team) * WAGON_BONUS

func calc_total_weight(team: TeamData) -> float:
	var total: float = 0.0
	for key in team.resources:
		total += maxf(float(team.resources[key]), 0.0) * _resource_weight(key)
	return total

func _resource_weight(key: String) -> float:
	match key:
		"food":              return 0.1
		"weapon_melee_low":  return 2.0
		"weapon_melee_high": return 3.0
		"armor_low":         return 4.0
		"armor_high":        return 7.0
		"mounts", "wagons":  return 0.0  # 搬運工具本身不計重
		_:                   return 1.0

func _tick_stray_mounts(team: TeamData) -> void:
	var excess: int = int(team.resources.get("mounts", 0)) - team.population
	if excess > 0:
		team.resources["mounts"] = int(team.resources["mounts"]) - ceili(excess * STRAY_RATE)

func _move_cost(state: WorldState, team: TeamData, time_mult: float = 1.0) -> int:
	var speed: float = _compute_team_speed(state, team) * time_mult
	var tile_id: int = team.tile_pos.x * 1000 + team.tile_pos.y
	if state.world.tiles.has(tile_id):
		var terrain: String = (state.world.tiles[tile_id] as HexTileData).terrain
		speed *= TERRAIN_SPEED_MULT.get(terrain, 1.0)
	# 疲勞懲罰
	if team.fatigue >= 1.0:
		speed *= 0.3
	elif team.fatigue > 0.5:
		speed *= (1.0 - team.fatigue * 0.4)
	# 超載懲罰
	var cap: float = get_carry_capacity(team)
	var weight: float = calc_total_weight(team)
	if weight > cap:
		speed *= (cap / weight)
	# 車輛地形懲罰
	var wagons: int = get_effective_wagons(team)
	if wagons > 0:
		var tile_id2: int = team.tile_pos.x * 1000 + team.tile_pos.y
		var tile2 = state.world.tiles.get(tile_id2)
		var terrain2: String = tile2.terrain if tile2 else "plains"
		speed *= WAGON_TERRAIN_MULT.get(terrain2, 1.0)
	return clamp(int(round(float(BASE_MOVE_TICKS) / maxf(speed, 0.01))), MIN_MOVE_TICKS, MAX_MOVE_TICKS)

func _compute_team_speed(state: WorldState, team: TeamData) -> float:
	var total_speed: float = 0.0
	var total_count: int = 0
	var named_ids: Array = team.named_members.duplicate()  # duplicate() — 避免直接修改 team.named_members
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
		var nid: int = neighbor.x * 1000 + neighbor.y
		if not state.world.tiles.has(nid):
			continue   # never step off-map
		var d: int = _hex_dist(neighbor, team.move_target)
		if d < best_dist:
			best_dist = d
			best_pos  = neighbor
	# If no on-map neighbour improves distance, team is stuck — cancel target
	if best_pos == team.tile_pos and team.tile_pos != team.move_target:
		print("[Move] Team %d stuck at (%d,%d), clearing move_target" % [
			team.team_id, team.tile_pos.x, team.tile_pos.y])
		team.move_target = Vector2i(-1, -1)
		return false
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
