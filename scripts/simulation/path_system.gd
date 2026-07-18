class_name PathSystem

# 觀測儀器旗標（純診斷）：true 時 observe_velocity 略過 randf 速度噪 → 該路徑零 RNG 消耗。
# sim 常態恆 false → 行為 bit-identical（唯 hand_obeys_brain_bed 采樣期間暫開，采完復原）。
# 存在理由：手聽腦儀器每 cadence 對每隊多算一次 rank（需 gather→ThreatAssessment/estimate_catch_up
# →observe_velocity），若消耗 global RNG 會擾動 sim 軌跡。此旗標保證觀測非擾動。
static var suppress_observe_noise: bool = false

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

# ── estimate_catch_up 加速：per-source SSSP（Dijkstra）永續 cache ──
# terrain 只在 world gen / game_setup 寫，runtime 永不變 → cost 圖靜態 → 單源最短路
# 算一次永續有效。estimate_catch_up 消費端只讀 reachable/eta（.path 無 consumer）→
# 以 SSSP cost 取代 per-pair A*：最優 cost = 同一 float path-sum 集合的 min（Dijkstra 與
# A* 沿 path 同序累加）→ bit-exact 等值；randf（observe_velocity）呼叫條件不動
# （SSSP 可達 ⟺ A* path 非空 = 同 component）→ 行為逐點不變。
# movement 等其他 find_path 呼叫者不走此（A* tie-order 影響實際走位，勿混）。
# cache 以 world instance id 分層（headless 測試多世界同座標互不污染）。
# 若未來 runtime 改地形，須呼 clear_sssp()。
static var _sssp_cache: Dictionary = {}   # world_iid → { from_key → { to_key → cost } }

static func clear_sssp() -> void:
	_sssp_cache.clear()

# from→to 最短 cost；INF = 不可達（同 A* path empty 條件）。
static func catch_cost(state: WorldState, from: Vector2i, to: Vector2i) -> float:
	if from == to:
		return 0.0   # 對齊 _astar from==to 短路（不查圖）
	var wid: int = state.world.get_instance_id()
	var per_world: Dictionary = _sssp_cache.get(wid, {})
	if per_world.is_empty():
		_sssp_cache[wid] = per_world
	var fk: int = from.x * 1000 + from.y
	var dist: Dictionary = per_world.get(fk, {})
	if dist.is_empty():
		dist = _dijkstra(state, from)
		per_world[fk] = dist
	return float(dist.get(to.x * 1000 + to.y, INF))

# 單源 Dijkstra（binary heap，lazy deletion）→ {tile_key: 最短 cost}（不可達不含鍵）。
static func _dijkstra(state: WorldState, from: Vector2i) -> Dictionary:
	var fk: int = from.x * 1000 + from.y
	var best: Dictionary = { fk: 0.0 }
	var settled: Dictionary = {}
	var heap: Array = [[0.0, fk, from]]   # [cost, key, pos]
	while not heap.is_empty():
		# pop 最小（sift-down）
		var top: Array = heap[0]
		var last: Array = heap.pop_back()
		if not heap.is_empty():
			heap[0] = last
			var i: int = 0
			var n: int = heap.size()
			while true:
				var l: int = i * 2 + 1
				var r: int = l + 1
				var m: int = i
				if l < n and float(heap[l][0]) < float(heap[m][0]): m = l
				if r < n and float(heap[r][0]) < float(heap[m][0]): m = r
				if m == i: break
				var tmp: Array = heap[i]; heap[i] = heap[m]; heap[m] = tmp
				i = m
		var ck: int = int(top[1])
		if settled.has(ck): continue
		settled[ck] = true
		var cc: float = float(top[0])
		var cpos: Vector2i = top[2]
		for d in HEX_DIRS:
			var npos: Vector2i = cpos + d
			var nk: int = npos.x * 1000 + npos.y
			if settled.has(nk): continue
			var tile: HexTileData = state.world.tiles.get(nk)
			if tile == null: continue
			var nc: float = cc + TERRAIN_COST.get(tile.terrain, 1.0)
			if nc < float(best.get(nk, INF)):
				best[nk] = nc
				# push（sift-up）
				heap.append([nc, nk, npos])
				var j: int = heap.size() - 1
				while j > 0:
					var p: int = (j - 1) / 2
					if float(heap[p][0]) <= float(heap[j][0]): break
					var tmp2: Array = heap[j]; heap[j] = heap[p]; heap[p] = tmp2
					j = p
	return best

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

# trusted=true：caller 已保證 target 在 observer 的 team_discovered（finder 迴圈迭代同一 array）
# → 跳 O(n) Array.has（O(n²) fan-out 根之一）。回傳值恆等（檢查恆真）、randf 流不動。
# ★god-view landmine（勿復活作決策/nearby-scan：讀 live target.tile_pos，非 belief last-seen。復活前須 belief-gate，
#   見 invariants.md 感知鐵律 nearby-scan landmine）。零 production caller（test-only + founding_path_measure.gd:31）。
static func observe_velocity(state: WorldState, observer: TeamData, target: TeamData,
		trusted: bool = false) -> Dictionary:
	if not trusted and not state.team_discovered.get(observer.team_id, []).has(target.team_id):
		return { "visible": false }
	var dist: int = _hex_dist(observer.tile_pos, target.tile_pos)
	var noise_factor: float = clampf(float(dist) / float(VisionSystem.VISION_RADIUS), 0.0, 1.0)
	# 真實 velocity（從 last_tile_pos → tile_pos）
	var actual_velocity: Vector2i = Vector2i(0, 0)
	if target.last_tile_pos != Vector2i(-999, -999):
		actual_velocity = target.tile_pos - target.last_tile_pos
	var actual_speed: float = float(_hex_dist(Vector2i.ZERO, actual_velocity))
	# 雜訊：距離越遠 speed 估越粗（觀測儀器采樣期間 suppress → 零 RNG，非擾動）
	var observed_speed: float = actual_speed
	if not suppress_observe_noise:
		observed_speed = actual_speed * (1.0 + (randf() - 0.5) * noise_factor)
	return {
		"visible": true,
		"speed": observed_speed,
		"direction": actual_velocity,
		"noise_factor": noise_factor,
	}

# ────────── catch-up ──────────

# ★god-view landmine（勿復活作決策/nearby-scan：讀 live target.tile_pos，非 belief last-seen。復活前須 belief-gate，
#   見 invariants.md 感知鐵律 nearby-scan landmine）。零 production caller（test-only）。
static func estimate_catch_up(state: WorldState, self_team: TeamData, target_id: int,
		trusted: bool = false) -> Dictionary:
	if not trusted and not state.team_discovered.get(self_team.team_id, []).has(target_id):
		return { "reachable": false, "reason": "out_of_sight" }
	var target_team: TeamData = state.teams.get(target_id)
	if target_team == null:
		return { "reachable": false, "reason": "team_missing" }
	# SSSP cost（bit-exact 同 A* 最優 cost；.path 無 consumer → 不再回傳）
	var cost: float = catch_cost(state, self_team.tile_pos, target_team.tile_pos)
	if cost == INF:
		return { "reachable": false, "reason": "no_path" }
	var obs: Dictionary = observe_velocity(state, self_team, target_team, trusted)
	var self_speed: float = _team_speed_mult(self_team)
	var target_speed: float = float(obs.get("speed", 0.0))
	var direction: Vector2i = obs.get("direction", Vector2i.ZERO)
	var moving_away: bool = _is_moving_away_observed(self_team, target_team, direction)
	if moving_away and target_speed >= self_speed:
		return { "reachable": false, "reason": "too_fast" }
	var relative_speed: float = (self_speed - target_speed) if moving_away else self_speed
	var eta: int = int(cost * float(MovementSystem.BASE_MOVE_TICKS) / maxf(relative_speed, 0.1))
	if eta > AI_ETA_LIMIT:
		return { "reachable": false, "reason": "too_far", "eta": eta }
	return { "reachable": true, "eta": eta }

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
# ★god-view landmine（勿復活作決策/nearby-scan：讀 live target.tile_pos，非 belief last-seen。復活前須 belief-gate，
#   見 invariants.md 感知鐵律 nearby-scan landmine）。零 production caller（test-only）。
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
