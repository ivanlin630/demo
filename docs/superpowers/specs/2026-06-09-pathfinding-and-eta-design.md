# 速度評估系統（A* Pathfinding + ETA + 追速）— Design

> 日期：2026-06-09
> 議題：當前所有 AI 用 `hex_dist`（直線距離）找目標，忽略地形與目標速度，導致 AI 追永遠追不上的目標、繞錯山等。需 A* path + ETA + 相對追速。

## 背景

當前狀態：
- `movement_system._calc_next_step` 用 greedy（朝目標一步走，遇障礙繞單格）
- AI（`faction_ai`、`strategic_ai`）找目標時用 `_hex_dist`（六角距離），忽略地形
- 結果：
  - 距離 2 hex 山地 vs 2 hex 平原視同等近 → 選錯目標
  - 商隊 trade target、軍隊 prey target、生存決策 aid target 全有此問題
  - 目標若快速移動且方向相反 → AI 死命追永遠追不到，浪費 tick + 卡死

需求：
1. AI 評估距離用 path cost（含地形）
2. 評估「追得上嗎」（相對追速）
3. 太遠的目標放棄（ETA cap）
4. Movement 走 A* 路徑（不繞錯山）
5. 統一 cache 避免重複計算

## 目標

1. `path_system.gd` 新檔，提供 A* + cache + ETA + 追速判定
2. `movement_system._calc_next_step` 改用 A* 的下一格
3. AI 評估目標時用 `path_system.find_path` 取代 `hex_dist`
4. ETA threshold = 5 天（1200 tick）→ 超過 unreachable
5. 相對追速 ≤ 0 + target 朝相反方向 → unreachable
6. Hook 預留 team 速度 class（infantry/cavalry/wagon）

## 不在範圍

- 動態避障（避 enemy outpost / 戰場）→ 後續 spec
- 多 team 路徑競爭（誰先到）→ 後續
- 騎兵/wagon 速度差實作（hook 預留，後續 spec）
- 戰場內 encounter pathing（不同尺度）

## 新檔案 `scripts/simulation/path_system.gd`

```gdscript
class_name PathSystem

const TERRAIN_COST: Dictionary = {
    "plains":   1.0,
    "forest":   1.0 / 0.7,    # 既有 TERRAIN_SPEED_MULT 倒數
    "mountain": 1.0 / 0.4,
}

const AI_ETA_LIMIT: int = 1200   # 5 day plains 等量 (5 × 240)

# Cache: key = "fx_fy_tx_ty", value = { path: Array[Vector2i], cost: float, tick: int }
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
    var closed: Dictionary = {}   # pos_key → node
    while not open.is_empty():
        # 取 f 最小
        open.sort_custom(func(a, b): return (a.g + a.h) < (b.g + b.h))
        var node: Dictionary = open.pop_front()
        var pos: Vector2i = node["pos"]
        var pk: int = pos.x * 1000 + pos.y
        if closed.has(pk): continue
        closed[pk] = node
        if pos == to:
            # 重建 path
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
            if tile == null: continue   # 地圖外
            var cost: float = TERRAIN_COST.get(tile.terrain, 1.0)
            open.append({
                "pos": npos,
                "g": node["g"] + cost,
                "h": _heuristic(npos, to),
                "from": node,
            })
    return { "path": [], "cost": INF }

static func _heuristic(a: Vector2i, b: Vector2i) -> float:
    # Hex distance（admissible）
    var dx: int = b.x - a.x; var dy: int = b.y - a.y
    return float((abs(dx) + abs(dx + dy) + abs(dy)) / 2)

const HEX_DIRS: Array = [
    Vector2i(1, 0), Vector2i(-1, 0),
    Vector2i(0, 1), Vector2i(0, -1),
    Vector2i(1, -1), Vector2i(-1, 1),
]
```

## ETA 計算

```gdscript
static func eta_ticks(team: TeamData, path_cost: float) -> int:
    # 既有 movement_system 公式：cost × BASE_MOVE_TICKS / speed_mult
    var speed_mult: float = _team_speed_mult(team)
    return int(path_cost * MovementSystem.BASE_MOVE_TICKS / maxf(speed_mult, 0.1))

static func _team_speed_mult(team: TeamData) -> float:
    var mult: float = 1.0
    mult *= clampf(1.0 - team.fatigue, 0.1, 1.0)
    # Hook 預留：speed_class
    # mult *= SPEED_CLASS_MULT.get(team.speed_class, 1.0)
    return mult
```

## 相對追速判定

```gdscript
static func estimate_catch_up(state: WorldState, self_team: TeamData, target_team: TeamData) -> Dictionary:
    var self_speed: float = _team_speed_mult(self_team)
    var target_speed: float = 0.0
    var target_moving: bool = (target_team.move_target != Vector2i(-1, -1) \
                              and target_team.move_target != target_team.tile_pos)
    if target_moving:
        target_speed = _team_speed_mult(target_team)
    var path_result: Dictionary = find_path(state, self_team.tile_pos, target_team.tile_pos)
    if path_result.path.is_empty():
        return { "reachable": false, "reason": "no_path", "eta": -1 }
    var gap_cost: float = float(path_result.cost)
    if not target_moving:
        var eta: int = eta_ticks(self_team, gap_cost)
        if eta > AI_ETA_LIMIT:
            return { "reachable": false, "reason": "too_far", "eta": eta }
        return { "reachable": true, "reason": "static", "eta": eta, "path": path_result.path }
    # Target 移動
    var moving_away: bool = _is_moving_away(self_team, target_team)
    if moving_away and target_speed >= self_speed:
        return { "reachable": false, "reason": "too_fast", "eta": -1 }
    var relative_speed: float
    if moving_away:
        relative_speed = self_speed - target_speed
    else:
        # Target 朝我來
        relative_speed = self_speed + target_speed
    var catch_up_ticks: int = int(gap_cost * MovementSystem.BASE_MOVE_TICKS / maxf(relative_speed, 0.05))
    if catch_up_ticks > AI_ETA_LIMIT:
        return { "reachable": false, "reason": "too_far", "eta": catch_up_ticks }
    return { "reachable": true, "reason": "intercept", "eta": catch_up_ticks, "path": path_result.path }

static func _is_moving_away(self_team: TeamData, target_team: TeamData) -> bool:
    var current_dist: int = _hex_dist(self_team.tile_pos, target_team.tile_pos)
    var future_dist: int = _hex_dist(self_team.tile_pos, target_team.move_target)
    return future_dist > current_dist

static func _hex_dist(a: Vector2i, b: Vector2i) -> int:
    var dx: int = b.x - a.x; var dy: int = b.y - a.y
    return (abs(dx) + abs(dx + dy) + abs(dy)) / 2
```

## TeamData 新欄位（預留 hook）

```gdscript
var speed_class: String = "infantry"   # 預留：infantry / cavalry / wagon
```

本 spec 不實作差異化 mult，後續 spec 處理。

## Movement 整合

`movement_system._calc_next_step` 改用 A*：

```gdscript
func _calc_next_step(state: WorldState, from: Vector2i, to: Vector2i) -> Vector2i:
    var result: Dictionary = PathSystem.find_path(state, from, to)
    if result.path.is_empty(): return from
    if result.path.size() > 1: return result.path[1]
    return result.path[0]
```

注意：簽名加 `state` 參數，需更新所有呼叫端。

## AI 整合（取代 hex_dist 評估）

各 `_find_*_target` 函數改用 `estimate_catch_up`：

### `faction_ai_system._find_trade_target`

```gdscript
for tid in state.team_discovered.get(merchant.team_id, []):
    var t = state.teams.get(tid)
    if t == null: continue
    var catch_result = PathSystem.estimate_catch_up(state, merchant, t)
    if not catch_result.reachable: continue
    # score 改用 eta 而非 hex_dist
    var score = max_gap / float(maxi(catch_result.eta / 60, 1))   # eta hour 數
```

類似改：
- `_find_weakest_prey`（survival）
- `_find_aid_target`（survival）
- `_find_strong_neighbor`（survival）
- `_evaluate_new_outpost_location`（NPC 基建）

### `encounter_system` 攻擊指令

玩家 / NPC 設 attack target 時，呼叫 `estimate_catch_up`，若 unreachable → 拒絕指令（forced event 提示或 NPC 自動換目標）。

## 不變量

- `find_path` 同 tick 同 (from, to) 命中 cache
- `from == to` → cost=0、path=[from]
- 隔絕 tile（地圖外 / 海洋）→ path=[]、cost=INF、unreachable
- ETA > AI_ETA_LIMIT 一律 unreachable
- 相對追速 ≤ 0 且 target 朝相反方向 → unreachable

## 測試

`headless_test.gd`：

1. **find_path basic**：plains → plains，直線 path 長度正確
2. **find_path 繞山**：mountain 在中間 → A* 繞道，cost > greedy direct
3. **find_path 無解**：隔絕 tile → path=[]，cost=INF
4. **cache hit**：同 tick 同 (from, to) → 第二次呼叫 cached
5. **cache miss after tick**：tick + 1 → 重算
6. **eta_ticks**：cost=10、team 無 fatigue → eta 正確
7. **estimate_catch_up 靜止 target**：target idle → reachable + eta = path eta
8. **estimate_catch_up 朝相反方向**：target.move_target 遠離 self → moving_away=true → 相對追速負 → unreachable
9. **estimate_catch_up 朝來向**：target.move_target 朝 self → moving_away=false → 加速碰面
10. **太遠 unreachable**：path cost 對應 > 5 天 → unreachable
11. **movement next_step 用 A***：team.tile_pos=(0,0), move_target=(5,0), 中間山 → 走 A* 路徑（繞山）

## 風險

- **A* 性能**：100 tile 地圖 per query ~1-5 ms，多 team query 累積 100-200 ms/hour，可接受。若地圖變大需 cache 策略加強
- **`_calc_next_step` 簽名加 state**：影響 movement_system 所有呼叫端，需逐一更新
- **AI 改用 estimate_catch_up**：多處 _find_*_target，需確認全改不漏
- **Cache key collision**：大地圖 x 可能負數，key 字串組合需正確
- **path_system 依賴 movement_system constants**：BASE_MOVE_TICKS 等需要 cross-class access

## 解決的 known_issues

- AI 追永遠追不上的目標（targets moving away faster）
- 距離評估忽略地形（山地視同平原）
- Movement greedy step 可能繞錯山

## 後續延伸

- 動態避障（避 enemy outpost、戰場）
- 騎兵/wagon 速度差實作（speed_class mult）
- Multi-team 路徑競爭（誰先到）
- 戰場內 encounter pathing
- 路徑 long-range cache（spanning multiple tick）
