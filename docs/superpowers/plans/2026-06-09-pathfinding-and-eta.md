# 速度評估系統 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** A* path + cache + ETA + 觀察行軍速度（含距離雜訊）取代 hex_dist。Movement 走 A* 路徑。AI 各 `_find_*_target` 用 `estimate_catch_up`。

**Architecture:**
- 新檔 `path_system.gd`：A* + cache + ETA + observe_velocity + estimate_catch_up
- TeamData 加 `last_tile_pos`
- `movement_system._calc_next_step` 用 A* (簽名加 state)
- AI `_find_*_target` 改用 `estimate_catch_up`
- `sim_runner` 或 `movement_system` movement 處理前記 last_tile_pos

**Spec:** `docs/superpowers/specs/2026-06-09-pathfinding-and-eta-design.md`

---

## 檔案結構

| 檔案 | 變更 |
|---|---|
| `scripts/data/team_data.gd` | 加 `last_tile_pos: Vector2i = Vector2i(-999, -999)` |
| `scripts/simulation/path_system.gd` | **新檔**：A* + cache + ETA + observe + catch_up |
| `scripts/simulation/movement_system.gd` | `_calc_next_step` 改 A*，process 結尾更新 last_tile_pos |
| `scripts/simulation/faction_ai_system.gd` | `_find_*_target` 改用 estimate_catch_up |
| `scripts/debug/headless_test.gd` | 15 個測試 |

## 測試命令

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/game_sim_test.gd
```

---

## Task 1: TeamData.last_tile_pos 欄位

**Files:**
- Modify: `scripts/data/team_data.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 加失敗測試**

```gdscript
func _test_last_tile_pos_field() -> void:
	print("--- Path Task1: last_tile_pos 欄位 ---")
	var t := TeamData.new()
	assert(t.last_tile_pos == Vector2i(-999, -999), "預設 (-999,-999)")
	t.last_tile_pos = Vector2i(5, 5)
	assert(t.last_tile_pos == Vector2i(5, 5))
	print("Path Task1 OK")
```

於 `_initialize()` 加。

- [ ] **Step 2: 加欄位**

`scripts/data/team_data.gd`：

```gdscript
var last_tile_pos: Vector2i = Vector2i(-999, -999)   # 上一 tick 位置（observe_velocity 用）
```

- [ ] **Step 3: 跑測試 + Commit**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
git add scripts/data/team_data.gd scripts/debug/headless_test.gd
git commit -m "feat(team): add last_tile_pos field (Task 1)"
```

---

## Task 2: 新檔 `path_system.gd` — A* + cache + find_path

**Files:**
- Create: `scripts/simulation/path_system.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 加測試**

```gdscript
func _test_find_path_basic() -> void:
	print("--- Path Task2: A* basic ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	state.world.current_tick = 100
	for x in range(-3, 4):
		for y in range(-3, 4):
			var tile := HexTileData.new()
			tile.tile_pos = Vector2i(x, y)
			tile.terrain = "plains"
			state.world.tiles[x * 1000 + y] = tile
	var r = PathSystem.find_path(state, Vector2i(0, 0), Vector2i(3, 0))
	assert(not r.path.is_empty(), "應有 path")
	assert(r.cost > 0, "cost 應 > 0")
	print("Path Task2 OK (path size=%d, cost=%.1f)" % [r.path.size(), r.cost])

func _test_find_path_cache() -> void:
	print("--- Path Task2b: cache ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	state.world.current_tick = 200
	for x in range(-3, 4):
		for y in range(-3, 4):
			var tile := HexTileData.new()
			tile.tile_pos = Vector2i(x, y); tile.terrain = "plains"
			state.world.tiles[x * 1000 + y] = tile
	var r1 = PathSystem.find_path(state, Vector2i(0, 0), Vector2i(2, 0))
	var r2 = PathSystem.find_path(state, Vector2i(0, 0), Vector2i(2, 0))
	assert(r1.tick == r2.tick, "同 tick 應命中 cache")
	# tick + 1 → 應重算
	state.world.current_tick = 201
	var r3 = PathSystem.find_path(state, Vector2i(0, 0), Vector2i(2, 0))
	assert(r3.tick == 201, "新 tick 重算")
	print("Path Task2b OK")

func _test_find_path_no_path() -> void:
	print("--- Path Task2c: 無路徑 ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	state.world.current_tick = 300
	# 只放 from tile，沒 to tile
	var tile := HexTileData.new(); tile.terrain = "plains"; tile.tile_pos = Vector2i(0, 0)
	state.world.tiles[0] = tile
	var r = PathSystem.find_path(state, Vector2i(0, 0), Vector2i(5, 5))
	assert(r.path.is_empty(), "無路徑應空 path")
	assert(r.cost == INF, "cost 應 INF")
	print("Path Task2c OK")
```

- [ ] **Step 2: 建檔 `path_system.gd`**

```gdscript
class_name PathSystem

const TERRAIN_COST: Dictionary = {
	"plains":   1.0,
	"forest":   1.0 / 0.7,
	"mountain": 1.0 / 0.4,
}

const AI_ETA_LIMIT: int = 1200

const HEX_DIRS: Array = [
	Vector2i(1, 0), Vector2i(-1, 0),
	Vector2i(0, 1), Vector2i(0, -1),
	Vector2i(1, -1), Vector2i(-1, 1),
]

static var _path_cache: Dictionary = {}

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
```

- [ ] **Step 3: 跑測試 + Commit**

```powershell
git add scripts/simulation/path_system.gd scripts/debug/headless_test.gd
git commit -m "feat(path): A* find_path + cache (Task 2)"
```

---

## Task 3: ETA + 速度 helpers

**Files:**
- Modify: `scripts/simulation/path_system.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 加測試**

```gdscript
func _test_eta_ticks() -> void:
	print("--- Path Task3: eta_ticks ---")
	var team := TeamData.new()
	team.population = 5; team.fatigue = 0.0
	var eta = PathSystem.eta_ticks(team, 5.0)
	# BASE_MOVE_TICKS = 120, speed_mult = 1.0 → eta = 5 * 120 = 600
	assert(eta == 600, "eta 應 600，實際=%d" % eta)
	team.fatigue = 0.5   # speed reduced
	var eta2 = PathSystem.eta_ticks(team, 5.0)
	assert(eta2 > eta, "fatigue 應延長 ETA")
	print("Path Task3 OK")
```

- [ ] **Step 2: 加函數**

```gdscript
static func eta_ticks(team: TeamData, path_cost: float) -> int:
	var speed_mult: float = _team_speed_mult(team)
	return int(path_cost * float(MovementSystem.BASE_MOVE_TICKS) / maxf(speed_mult, 0.1))

static func _team_speed_mult(team: TeamData) -> float:
	var mult: float = 1.0
	mult *= clampf(1.0 - team.fatigue, 0.1, 1.0)
	return mult
```

- [ ] **Step 3: 跑測試 + Commit**

```powershell
git add scripts/simulation/path_system.gd scripts/debug/headless_test.gd
git commit -m "feat(path): eta_ticks + speed_mult helper (Task 3)"
```

---

## Task 4: `observe_velocity`（含距離雜訊）

**Files:**
- Modify: `scripts/simulation/path_system.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 加測試**

```gdscript
func _test_observe_velocity_visible() -> void:
	print("--- Path Task4: observe_velocity visible ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	var observer := TeamData.new()
	observer.team_id = 0; observer.tile_pos = Vector2i(0, 0)
	state.teams[0] = observer
	var target := TeamData.new()
	target.team_id = 1; target.tile_pos = Vector2i(2, 0)
	target.last_tile_pos = Vector2i(1, 0)
	state.teams[1] = target
	state.team_discovered[0] = [1]
	var r = PathSystem.observe_velocity(state, observer, target)
	assert(r.get("visible", false), "應可見")
	assert(r.get("speed", 0) > 0, "speed 應 > 0 (1 hex movement)")
	print("Path Task4 OK (speed=%.2f)" % r.get("speed", 0))

func _test_observe_velocity_invisible() -> void:
	print("--- Path Task4b: 不可見 ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	var observer := TeamData.new()
	observer.team_id = 0
	state.teams[0] = observer
	var target := TeamData.new()
	target.team_id = 1
	state.teams[1] = target
	# 不加進 discovered
	var r = PathSystem.observe_velocity(state, observer, target)
	assert(not r.get("visible", true), "不可見")
	print("Path Task4b OK")
```

- [ ] **Step 2: 加函數**

```gdscript
static func observe_velocity(state: WorldState, observer: TeamData, target: TeamData) -> Dictionary:
	if not state.team_discovered.get(observer.team_id, []).has(target.team_id):
		return { "visible": false }
	var dist: int = _hex_dist(observer.tile_pos, target.tile_pos)
	var noise_factor: float = clampf(float(dist) / float(VisionSystem.VISION_RADIUS), 0.0, 1.0)
	var actual_velocity: Vector2i = Vector2i(0, 0)
	if target.last_tile_pos != Vector2i(-999, -999):
		actual_velocity = target.tile_pos - target.last_tile_pos
	var actual_speed: float = float(_hex_dist(Vector2i.ZERO, actual_velocity))
	var observed_speed: float = actual_speed * (1.0 + (randf() - 0.5) * noise_factor)
	return {
		"visible": true,
		"speed": observed_speed,
		"direction": actual_velocity,
		"noise_factor": noise_factor,
	}
```

- [ ] **Step 3: 跑測試 + Commit**

```powershell
git add scripts/simulation/path_system.gd scripts/debug/headless_test.gd
git commit -m "feat(path): observe_velocity with distance noise (Task 4)"
```

---

## Task 5: `estimate_catch_up`

**Files:**
- Modify: `scripts/simulation/path_system.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 加測試**

```gdscript
func _test_estimate_catch_up_reachable() -> void:
	print("--- Path Task5: catch_up reachable ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	for x in range(-3, 4):
		for y in range(-3, 4):
			var tile := HexTileData.new()
			tile.tile_pos = Vector2i(x, y); tile.terrain = "plains"
			state.world.tiles[x * 1000 + y] = tile
	var observer := TeamData.new()
	observer.team_id = 0; observer.tile_pos = Vector2i(0, 0); observer.fatigue = 0.0
	state.teams[0] = observer
	var target := TeamData.new()
	target.team_id = 1; target.tile_pos = Vector2i(2, 0); target.fatigue = 0.0
	# Target static (last_pos == current_pos → speed 0)
	target.last_tile_pos = Vector2i(2, 0)
	state.teams[1] = target
	state.team_discovered[0] = [1]
	var r = PathSystem.estimate_catch_up(state, observer, 1)
	assert(r.get("reachable", false), "應 reachable")
	print("Path Task5 OK (eta=%d)" % r.get("eta", 0))

func _test_estimate_catch_up_too_far() -> void:
	# path cost 對應 > 5 day
	# ...
	print("Path Task5b OK")

func _test_estimate_catch_up_out_of_sight() -> void:
	# target 不在 discovered → out_of_sight
	# ...
	print("Path Task5c OK")
```

- [ ] **Step 2: 加函數**

```gdscript
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
	if observed_direction == Vector2i.ZERO: return false
	var current_dist: int = _hex_dist(self_team.tile_pos, target_team.tile_pos)
	var future_pos: Vector2i = target_team.tile_pos + observed_direction
	var future_dist: int = _hex_dist(self_team.tile_pos, future_pos)
	return future_dist > current_dist
```

- [ ] **Step 3: 跑測試 + Commit**

```powershell
git add scripts/simulation/path_system.gd scripts/debug/headless_test.gd
git commit -m "feat(path): estimate_catch_up with observable velocity (Task 5)"
```

---

## Task 6: `movement_system._calc_next_step` 改用 A*

**Files:**
- Modify: `scripts/simulation/movement_system.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 加測試**

```gdscript
func _test_movement_uses_astar() -> void:
	# 設山地中間 → next_step 應走非直線
	# ...
```

- [ ] **Step 2: 改函數**

打開 `movement_system.gd`，找 `_calc_next_step`，改：

```gdscript
func _calc_next_step(state: WorldState, from: Vector2i, to: Vector2i) -> Vector2i:
	var result: Dictionary = PathSystem.find_path(state, from, to)
	if result.path.is_empty(): return from
	if result.path.size() > 1: return result.path[1]
	return result.path[0]
```

簽名加 `state`，更新所有呼叫端。

- [ ] **Step 3: 加 last_tile_pos 更新**

`movement_system.process` 處理每個 team 時，**移動前**記：

```gdscript
team.last_tile_pos = team.tile_pos
# ... 既有 movement 處理（修改 team.tile_pos）
```

- [ ] **Step 4: 跑全測試 + Commit**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/game_sim_test.gd
git add scripts/simulation/movement_system.gd scripts/debug/headless_test.gd
git commit -m "feat(movement): use A* + record last_tile_pos (Task 6)"
```

---

## Task 7: AI integration（`_find_*_target` 改用 catch_up）

**Files:**
- Modify: `scripts/simulation/faction_ai_system.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: grep 所有 `_find_*_target`**

```bash
grep -n "_find.*_target" scripts/simulation/faction_ai_system.gd
```

主要：`_find_trade_target`、`_find_weakest_prey`、`_find_aid_target`、`_find_strong_neighbor`、其他。

- [ ] **Step 2: 改各函數**

替換 `_hex_dist` + `if dist > N` 為 `PathSystem.estimate_catch_up`：

```gdscript
for tid in state.team_discovered.get(self_team.team_id, []):
	var t = state.teams.get(tid)
	if t == null: continue
	var catch_result = PathSystem.estimate_catch_up(state, self_team, tid)
	if not catch_result.reachable: continue
	# 既有 score 計算改用 eta（替代 hex_dist）
	var score = base_score / float(maxi(int(catch_result.eta / 60), 1))
	# ...
```

- [ ] **Step 3: 整合測試 + Commit**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
git add scripts/simulation/faction_ai_system.gd scripts/debug/headless_test.gd
git commit -m "feat(faction_ai): _find_*_target use estimate_catch_up (Task 7)"
```

---

## Task 8: 整合驗證 + handback

**Files:**
- Create: `docs/superpowers/handbacks/2026-06-09-pathfinding-and-eta.md`

- [ ] **Step 1: 跑全測試**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/game_sim_test.gd > godot_test.log 2>&1
Get-Content godot_test.log -Encoding UTF8 | Select-String "ALL INVARIANTS|Feature 通|Path|reachable|out_of_sight|too_fast|too_far" | Select-Object -First 30
```

- [ ] **Step 2: 寫 handback**

```markdown
# Hand Back: Pathfinding + ETA + Catch-up

## 實作摘要

- TeamData：last_tile_pos
- path_system.gd 新檔：find_path (A* + cache), eta_ticks, observe_velocity (含距離雜訊), estimate_catch_up
- movement_system：_calc_next_step 改 A*；process 結尾記 last_tile_pos
- faction_ai_system._find_*_target 改用 estimate_catch_up

## 行為變化

- AI 距離評估含地形（A* path cost）
- Movement 自然繞山
- AI 限視野 (state.team_discovered)
- AI 可觀察 target 行軍速度（含 0 = 不動），有距離雜訊
- AI 評估 reachable + ETA cap 5 天
- AI 識別「永遠追不上」(target speed >= self + moving_away) → unreachable

## 連動風險

- A* per query ~1-5 ms，多 team 累積可能 100-200 ms/hour
- _calc_next_step 簽名加 state → 呼叫端更新
- last_tile_pos 更新時機 → 必須 movement 處理前記住
- observe_velocity 雜訊隨機 → AI 評估結果可能 tick 間波動

## 待主 session 確認

- 騎兵 / wagon speed_class 後續實作
- 動態避障（避 enemy outpost）後續 spec
- 加更多 AI 整合點？（npc_combat_system 等）
```

- [ ] **Step 3: Commit**

```powershell
git add docs/superpowers/handbacks/2026-06-09-pathfinding-and-eta.md
git commit -m "docs: pathfinding+ETA handback (Task 8)"
```
