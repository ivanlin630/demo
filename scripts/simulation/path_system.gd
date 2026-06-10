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

# ────────── catch-up ──────────

static func estimate_catch_up(state: WorldState, self_team: TeamData, target_id: int) -> Dictionary:
	if not state.team_discovered.get(self_team.team_id, []).has(target_id):
		return { "reachable": false, "reason": "out_of_sight" }
	var target_team: TeamData = state.teams.get(target_id)
	if target_team == null:
		return { "reachable": false, "reason": "team_missing" }
	var path: Dictionary = find_path(state, self_team.tile_pos, target_team.tile_pos)
	if path.path.is_empty():
		return { "reachable": false, "reason": "no_path" }
	var obs: Dictionary = observe_velocity(state, self_team, target_team)
	var self_speed: float = _team_speed_mult(self_team)
	var target_speed: float = float(obs.get("speed", 0.0))
	var direction: Vector2i = obs.get("direction", Vector2i.ZERO)
	var moving_away: bool = _is_moving_away_observed(self_team, target_team, direction)
	if moving_away and target_speed >= self_speed:
		return { "reachable": false, "reason": "too_fast" }
	var relative_speed: float = (self_speed - target_speed) if moving_away else self_speed
	var eta: int = int(float(path.cost) * float(MovementSystem.BASE_MOVE_TICKS) / maxf(relative_speed, 0.1))
	if eta > AI_ETA_LIMIT:
		return { "reachable": false, "reason": "too_far", "eta": eta }
	return { "reachable": true, "eta": eta, "path": path.path }

static func _is_moving_away_observed(self_team: TeamData, target_team: TeamData,
		observed_direction: Vector2i) -> bool:
	if observed_direction == Vector2i.ZERO: return false   # target 不動
	var current_dist: int = _hex_dist(self_team.tile_pos, target_team.tile_pos)
	var future_pos: Vector2i = target_team.tile_pos + observed_direction
	var future_dist: int = _hex_dist(self_team.tile_pos, future_pos)
	return future_dist > current_dist

# ────────── 攔截預測 ──────────

# 依觀察到的速度自適應 N 步預測 target 未來位置。N = 到 target 的路徑成本（越遠預測越多步）。
# 視野外 / 不動 / 預測落在地圖外 → fallback 回 target 當前位置。
static func predict_intercept(state: WorldState, attacker: TeamData,
		target: TeamData) -> Vector2i:
	var obs: Dictionary = observe_velocity(state, attacker, target)
	if not obs.get("visible", false):
		return target.tile_pos
	var direction: Vector2i = obs.get("direction", Vector2i.ZERO)
	var target_speed: float = float(obs.get("speed", 0.0))
	if direction == Vector2i.ZERO or target_speed < 0.1:
		return target.tile_pos
	var path: Dictionary = find_path(state, attacker.tile_pos, target.tile_pos)
	var n: int = maxi(1, int(path.cost))
	var predicted: Vector2i = target.tile_pos + direction * n
	if not state.world.tiles.has(predicted.x * 1000 + predicted.y):
		return target.tile_pos
	return predicted
