# NPC 自主行為救活（Wakeup Fixes）— Design

> 日期：2026-06-10
> 議題：4 config × 90 天 multi 跑出 0 Combat / 0 Trade / 0 Promotion。子 session 追根：StrategicAI 派 off-map target → stuck → AI gate 全鎖死 → team zombie 化。需 7 個小修救活。

## 背景

子 session 投資結果（`godot_multi.log` ~21600 tick × 4 config）：

- 全 sim「抵達」訊息 **1 次**
- 4 個 ProsperityAttack 排程，無 follow-up（attacker 第一次評估後永遠不再評）
- StrategicAI 4620 次 plan → 多數 stuck
- Team2 (game_sim_test) 整 90 天只試動 1 次 → stuck → zombie

### 根因鏈

```
StrategicAI 派 dir×5 off-map target
  → A* find_path 回 empty
  → movement._step_team stuck，清 move_target
  → current_task 仍 = "攻擊" / "expand" 等
  → 所有 AI gate 看 current_task != IDLE → 拒絕重評
  → strategic_assignments 仍指 off-map → 下 tick 重派同樣 → 無限循環
```

## 目標

7 個 surgical fix：
1. StrategicAI 派 target 加 in-map check
2. AI gate 加「stuck 視為 idle 重評」邏輯（保留 task 意圖）
3. _assign_breakout 距離 guard（鄰敵 > 3 hex 不觸發）
4. _assign_breakout / _assign_encirclement 縮 dir 倍率
5. Survival TASK_LOOT 從 SURVIVAL_TASKS 排除（允許重評換 prey）
6. StrategicAI 加 `trade_net` handler
7. stuck log 加「誰派的座標」

## 不在範圍

- 加新 task type
- 改互動規則（仍嚴禁非同格互動）
- 改戰鬥規則
- 改地圖大小 / 地形生成
- NPC 主動 train / promote 邏輯（另 spec）

## Fix 細節

### Fix 1: StrategicAI 派 target in-map check

`strategic_ai_system.gd:114` `_assign_encirclement`：

```gdscript
var sa_pos: Vector2i = target_pos + dir * 2
if not _is_valid_tile(state, sa_pos):
    sa_pos = _nearest_valid_tile(state, sa_pos, target_pos)
team.strategic_assignments[target_id] = sa_pos
```

`strategic_ai_system.gd:131` `_assign_breakout`：

```gdscript
var sa_pos: Vector2i = self_team.tile_pos + best_dir * BREAKOUT_DIST
if not _is_valid_tile(state, sa_pos):
    sa_pos = _nearest_valid_tile(state, sa_pos, self_team.tile_pos)
self_team.strategic_assignments[-1] = sa_pos
```

Helpers：

```gdscript
static func _is_valid_tile(state: WorldState, pos: Vector2i) -> bool:
    return state.world.tiles.has(pos.x * 1000 + pos.y)

static func _nearest_valid_tile(state: WorldState, target: Vector2i, fallback: Vector2i) -> Vector2i:
    if _is_valid_tile(state, target): return target
    # 從 target 往 fallback 方向找最近 in-map tile
    var dir: Vector2i = fallback - target
    var step: Vector2i = Vector2i(sign(dir.x), sign(dir.y))
    var cur: Vector2i = target
    for _i in range(10):
        cur = cur + step
        if _is_valid_tile(state, cur): return cur
    return fallback
```

### Fix 2: AI gate 加「stuck 視為 idle 重評」

`faction_ai_system._evaluate_prosperity_attack` 開頭：

```gdscript
# stuck: task 仍 "攻擊" 但 move_target 已清 → 視為 idle 允許重評
var is_stuck: bool = (team.current_task == TeamData.TASK_ATTACK
    and team.move_target == Vector2i(-1, -1))
if team.current_task != TeamData.TASK_IDLE and not is_stuck: return
```

類似改其他 gate（`_assign_tasks` 攻擊 branch、`_trigger_survival` 內等），規則：
- task = 攻擊/掠奪/expand 且 move_target = (-1, -1) → 視為 idle

### Fix 3: _assign_breakout 距離 guard

`strategic_ai_system.gd:127`：

```gdscript
if enemy_teams.size() < 2: return
# 加：鄰敵 > 3 hex 不觸發（看到遠敵不必恐慌）
var nearest_dist: int = 9999
for e in enemy_teams:
    var d: int = _hex_dist(self_team.tile_pos, e.tile_pos)
    if d < nearest_dist: nearest_dist = d
if nearest_dist > 3: return
```

### Fix 4: breakout / encirclement 縮 dir 倍率

```gdscript
const BREAKOUT_DIST: int = 2     # 原 5 → 2 (radius 4 map 友善)
const ENCIRCLE_DIST: int = 1     # 原 2 → 1
```

或：依 map radius 算 `min(原值, map_radius)`，但需傳 state。先用常數簡單。

### Fix 5: Survival TASK_LOOT 從 SURVIVAL_TASKS 排除

`faction_ai_system.gd:27`：

```gdscript
# 舊
const SURVIVAL_TASKS: Array = ["return_home", "乞食", TeamData.TASK_LOOT, "投靠"]
# 新（移除 TASK_LOOT，允許 loot 中重評換 prey）
const SURVIVAL_TASKS: Array = ["return_home", "乞食", "投靠"]
```

注意：可能其他用 SURVIVAL_TASKS 處需 audit（grep）。

### Fix 6: StrategicAI 加 `trade_net` handler

`strategic_ai_system.gd` `tick` 內 `match top["type"]:` 加：

```gdscript
"trade_net":
    _dispatch_trade_net(state, faction, leader_team, top)
```

`_dispatch_trade_net`：找 faction 內最近商隊 + 鄰商隊 prey → 派 trade task。

實作參考 `_assign_tasks` 內 trade 派發邏輯（如已有），或新加：

```gdscript
func _dispatch_trade_net(state, faction, leader_team, goal):
    # 找 faction 商隊 team
    var traders: Array = []
    for tid in faction.team_ids:
        var t = state.teams.get(tid)
        if t != null and "商隊" in t.tags:
            traders.append(t)
    if traders.is_empty(): return
    # 對每個 trader 派 trade target
    for trader in traders:
        if trader.current_task != "idle": continue
        var target: int = _find_trade_partner(state, trader)
        if target == -1: continue
        var p = state.teams[target]
        trader.current_task = TeamData.TASK_TRADE
        trader.move_target = p.tile_pos
        trader.combat_target = target
```

### Fix 7: stuck log 加 source

`movement_system.gd:170`：

```gdscript
# 舊
print("[Move] Team %d stuck at (%d,%d), clearing move_target" % [...])
# 新
print("[Move] Team %d stuck at (%d,%d) target=(%d,%d), clearing move_target (task=%s, sa=%s)" % [
    team.team_id, team.tile_pos.x, team.tile_pos.y,
    team.move_target.x, team.move_target.y,
    team.current_task, str(team.strategic_assignments)])
```

= 看出 stuck 是 prosperity 派的還是 strategic 派的還是其他。

## 不變量保留

- **嚴禁非同格互動**：本 spec 不碰 interaction_system，所有交易/戰鬥/外交仍同格觸發
- 玩家命令 task 不受影響（Fix 2 只看 NPC 派的 task）
- 居民鎖規則不動（PRODUCE + outpost 限制保留）

## 測試

1. **off-map sa_pos → 改 in-map**：radius 4 map，team @ (0,0) 設 sa_pos (5,5) → 改 nearest valid
2. **stuck 視為 idle 重評**：team task=攻擊 move_target=(-1,-1) → _evaluate_prosperity_attack 跑
3. **breakout 鄰敵 > 3 hex 不觸發**：enemy_teams 全在距離 5 → 不 breakout
4. **breakout dist 改 2**：team @ (4,4) dir=(1,0) → sa_pos (6,4) in-map
5. **Survival 在 TASK_LOOT 仍可重評**：team task=掠奪 → _evaluate_survival 跑（不 early-return）
6. **trade_net dispatch**：faction goal=trade_net + 有商隊 → 商隊 task=貿易
7. **stuck log 多 source**：grep log 有 "task=" 訊息
8. **multi 4 config × 90 天**：encounter > 0 / promote > 0 / trade > 0（驗證救活）

## 風險

- **Fix 2 改 AI gate 多處**：需確保所有 task type 都覆蓋（攻擊/掠奪/expand）
- **Fix 4 縮 dir 倍率**：可能讓 breakout 「逃」太短不夠遠
- **Fix 5 SURVIVAL_TASKS 移除 TASK_LOOT**：可能讓 team 在 loot 中又被 survival 改 task，需測
- **Fix 6 trade_net dispatch**：trade_system 邏輯尚未完整（baseline Trade=0）— 此修可能僅排程不成交
- **整體性能**：fix 後 movers 增加 → process_on_move 工作量增

## 解決

- StrategicAI 派 in-map target → stuck 大降
- stuck 時 AI 重評 → zombie 解除
- breakout 不再隨便觸發 → 商隊不再無故 stuck
- Survival loot 可重評換 prey
- Trade 任務有派發 channel
- log 可追根

## 後續（另 spec）

- 居民鎖白名單擴張（攻擊/掠奪也可破鎖？）
- NPC AI promote/train 主動評估
- 防守方 active 行為（prey 看到 attacker 來逃跑/迎戰）
- 戰俘處置
- tag drift
