# 速度評估系統（A* Pathfinding + ETA + 觀察行軍速度）— Design

> 日期：2026-06-09
> 議題：當前 AI 用 `hex_dist`（直線距離）忽略地形，無法判定「追永遠追不上的目標」，需 A* path + ETA + 視野內觀察行軍速度

## 背景

當前狀態：
- `movement_system._calc_next_step` 用 greedy 步進
- AI 找目標用 `_hex_dist`，忽略地形（山地視同平原）
- 無 catch-up 機制 → AI 死命追快速移動的目標
- 既有視野系統（`state.team_discovered`）只判定能否看到，無「觀察速度」概念

需求：
1. A* path cost 取代 hex_dist 給 AI 評估
2. ETA threshold 限 5 天
3. 限視野內目標
4. **觀察行軍速度（受距離雜訊）**，避免追永遠追不上的目標
5. Movement 走 A* 路徑（不繞錯山）

## 目標

1. 新檔 `scripts/simulation/path_system.gd`：A* + cache + ETA + 觀察函數
2. TeamData 加 `last_tile_pos` 欄位（每 tick 更新前一格）
3. `path_system.observe_velocity(observer, target)`：視野內可看 target 行軍速度（含 0），有距離雜訊
4. `path_system.estimate_catch_up(state, self_team, target_id)`：限視野 + 用觀察速度 + path cost 算 reachable / ETA
5. `movement_system._calc_next_step` 改用 A*
6. AI（`faction_ai`、`strategic_ai`）所有 `_find_*_target` 改用 `estimate_catch_up`

## 不在範圍

- 動態避障（避 enemy outpost）→ 後續
- 騎兵 / wagon 速度差實作（hook 預留）
- 戰場 encounter pathing（不同尺度）
- 觀察 target 「未來方向」（move_target 內部資訊）

## 新檔 `scripts/simulation/path_system.gd`

```gdscript
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
            var cur: Dictionary = node
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

# ────────── ETA ──────────

static func eta_ticks(team: TeamData, path_cost: float) -> int:
    var speed_mult: float = _team_speed_mult(team)
    return int(path_cost * MovementSystem.BASE_MOVE_TICKS / maxf(speed_mult, 0.1))

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
    var eta: int = int(float(path.cost) * MovementSystem.BASE_MOVE_TICKS / maxf(relative_speed, 0.1))
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

static func _hex_dist(a: Vector2i, b: Vector2i) -> int:
    var dx: int = b.x - a.x; var dy: int = b.y - a.y
    return (abs(dx) + abs(dx + dy) + abs(dy)) / 2
```

## TeamData 新欄位

```gdscript
var last_tile_pos: Vector2i = Vector2i(-999, -999)   # 上一 tick 位置（觀察速度用）
```

每 tick movement 後更新（`sim_runner` 或 `movement_system` 結尾）：

```gdscript
for tid in active_teams:
    var t = state.teams[tid]
    t.last_tile_pos = t.tile_pos   # （在新 tile_pos 寫入前記）
    # ... movement 處理 ...
```

注意：邏輯順序需確保 last 是上一 tick，current 是本 tick 新位置。

## Movement 整合

`movement_system._calc_next_step` 改：

```gdscript
func _calc_next_step(state: WorldState, from: Vector2i, to: Vector2i) -> Vector2i:
    var result: Dictionary = PathSystem.find_path(state, from, to)
    if result.path.is_empty(): return from
    if result.path.size() > 1: return result.path[1]
    return result.path[0]
```

簽名加 `state`，需更新所有呼叫端。

## AI 整合

各 `_find_*_target` 改用 `estimate_catch_up`：

- `faction_ai_system._find_trade_target`
- `_find_weakest_prey`
- `_find_aid_target`
- `_find_strong_neighbor`
- 其他類似

```gdscript
for tid in state.team_discovered.get(self_team.team_id, []):
    var catch_result = PathSystem.estimate_catch_up(state, self_team, tid)
    if not catch_result.reachable: continue
    # score 改用 eta 而非 hex_dist
    var score = base_score / float(maxi(catch_result.eta / 60, 1))
    # ...
```

## 不變量

- `find_path` 同 tick 同 (from, to) 命中 cache
- `from == to` → cost=0、path=[from]
- 隔絕 tile → path=[]、cost=INF、reachable=false
- ETA > AI_ETA_LIMIT → unreachable
- observed_speed >= self_speed 且 moving_away → unreachable
- `last_tile_pos == (-999, -999)` 表「剛建 team 無 history」→ observed velocity = 0

## 測試

1. **find_path basic plains**
2. **find_path 繞山**（cost 比 greedy 高）
3. **find_path 無解**（隔絕）→ path=[]
4. **cache hit 同 tick**
5. **cache miss 新 tick**
6. **eta_ticks** 計算正確
7. **observe_velocity 可見**：target in discovered + 有 last_pos → 回 speed/direction
8. **observe_velocity 不可見**：target 不在 discovered → visible=false
9. **observe_velocity 雜訊**：距離越遠 noise_factor 越高
10. **estimate_catch_up reachable**：static target + ETA 在 limit 內
11. **estimate_catch_up too_far**：path cost 對應 > 5 天
12. **estimate_catch_up too_fast**：observed speed >= self + moving_away
13. **estimate_catch_up out_of_sight**：target 不在 discovered
14. **estimate_catch_up no_path**：path=[]
15. **movement next_step 用 A***：path 繞山

## 風險

- **A* 性能**：100 tile 每 query ~1-5 ms，多 team 累積 100-200 ms / hour，可接受
- **`_calc_next_step` 簽名加 state**：所有呼叫端要更新
- **AI 多處 `_find_*_target`**：需逐一改，易漏
- **`last_tile_pos` 更新時機**：要在 movement 處理前記住舊位置
- **觀察速度雜訊隨機**：可能造成 AI 行為不穩定（同樣 target 評估結果差異）
- **`Vision_System.VISION_RADIUS` 依賴**：path_system 需 reference VisionSystem 常數

## 解決

- AI 死追永遠追不上的目標（observed too_fast）
- 距離評估忽略地形（A* path 含 terrain cost）
- Movement greedy 繞錯山（A* 自然繞）

## 後續

- 動態避障
- 騎兵 / wagon speed_class
- Multi-team 路徑競爭
- 戰場 encounter pathing
- 加 noise_factor 顯示給玩家（UI 提示「不確定」）
