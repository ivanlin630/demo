class_name PathSystem

const TERRAIN_COST: Dictionary = {
	"plains":   1.0,
	"forest":   1.0 / 0.7,
	"mountain": 1.0 / 0.4,
}

const AI_ETA_LIMIT: int = 1200   # 5 day plains 等量 (5 × 240)

const HEX_DIRS: Array = [
	Vector2i(1, 0), Vector2i(-1, 0),
	Vector2i(0, 1), Vector2i(0, -1),
	Vector2i(1, -1), Vector2i(-1, 1),
]

static var _path_cache: Dictionary = {}

# ────────── A* ──────────

static func find_path(state: WorldState, from: Vector2i, to: Vector2i) -> Dictionary:
	var key: String = "%d_%d_%d_%d" % [from.x, from.y, to.x, to.y]
	var cached: Dictionary = _path_cache.get(key, {})
	if cached and int(cached.get("tick", -1)) == state.world.current_tick:
		return cached
	var result: Dictionary = _astar(state, from, to)
	result["tick"] = state.world.current_tick
	_path_cache[key] = result
	return result

static func _astar(state: WorldState, from: Vector2i, to: Vector2i) -> Dictionary:
	if from == to:
		return { "path": [from], "cost": 0.0 }
	var open: Array = [{ "pos": from, "g": 0.0, "h": _heuristic(from, to), "from": null }]
	var closed: Dictionary = {}
	while not open.is_empty():
		open.sort_custom(func(a, b): return (a.g + a.h) < (b.g + b.h))
		var node: Dictionary = open.pop_front()
		var pos: Vector2i = node["pos"]
		var pk: int = pos.x * 1000 + pos.y
		if closed.has(pk): continue
		closed[pk] = node
		if pos == to:
			var path: Array = []
			var cur = node
			while cur != null:
				path.append(cur["pos"])
				cur = cur.get("from")
			path.reverse()
			return { "path": path, "cost": node["g"] }
		for d in HEX_DIRS:
			var npos: Vector2i = pos + d
			var nk: int = npos.x * 1000 + npos.y
			if closed.has(nk): continue
			var tile: HexTileData = state.world.tiles.get(nk)
			if tile == null: continue
			var cost: float = TERRAIN_COST.get(tile.terrain, 1.0)
			open.append({
				"pos": npos,
				"g": node["g"] + cost,
				"h": _heuristic(npos, to),
				"from": node,
			})
	return { "path": [], "cost": INF }

static func _heuristic(a: Vector2i, b: Vector2i) -> float:
	var dx: int = b.x - a.x; var dy: int = b.y - a.y
	return float((abs(dx) + abs(dx + dy) + abs(dy)) / 2)

static func _hex_dist(a: Vector2i, b: Vector2i) -> int:
	var dx: int = b.x - a.x; var dy: int = b.y - a.y
	return (abs(dx) + abs(dx + dy) + abs(dy)) / 2

# ────────── ETA ──────────

static func eta_ticks(team: TeamData, path_cost: float) -> int:
	var speed_mult: float = _team_speed_mult(team)
	return int(path_cost * float(MovementSystem.BASE_MOVE_TICKS) / maxf(speed_mult, 0.1))

static func _team_speed_mult(team: TeamData) -> float:
	var mult: float = 1.0
	mult *= clampf(1.0 - team.fatigue, 0.1, 1.0)
	# Hook 預留 speed_class（未實作）
	return mult

# ────────── 觀察行軍速度 ──────────

static func observe_velocity(state: WorldState, observer: TeamData, target: TeamData) -> Dictionary:
	if not state.team_discovered.get(observer.team_id, []).has(target.team_id):
		return { "visible": false }
	var dist: int = _hex_dist(observer.tile_pos, target.tile_pos)
	var noise_factor: float = clampf(float(dist) / float(VisionSystem.VISION_RADIUS), 0.0, 1.0)
	# 真實 velocity（從 last_tile_pos → tile_pos）
	var actual_velocity: Vector2i = Vector2i(0, 0)
	if target.last_tile_pos != Vector2i(-999, -999):
		actual_velocity = target.tile_pos - target.last_tile_pos
	var actual_speed: float = float(_hex_dist(Vector2i.ZERO, actual_velocity))
	# 雜訊：距離越遠 speed 估越粗
	var observed_speed: float = actual_speed * (1.0 + (randf() - 0.5) * noise_factor)
	return {
		"visible": true,
		"speed": observed_speed,
		"direction": actual_velocity,
		"noise_factor": noise_factor,
	}
