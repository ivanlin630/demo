# NPC 會合機制（Encounter Engagement）— Design

> 日期：2026-06-10
> 議題：multi 4 config × 90 天 = 0 Combat / 0 Trade 成交。NPC wakeup fixes 後 team 會動且抵達，但兩 mobile team 同速擦肩永遠差 1 hex → 不會合 → 不互動。

## 背景

當前狀態（wakeup merge 後）：
- ProsperityAttack 5 次排程，attacker 真會移動（Team5 流亡狼軍 50 moves）
- trade_net 派發 433 次（W2 channel 已活）
- 但 `[Encounter]` / `[Hit]` / `[Market]` = 0
- 根因：attacker 追 mobile prey 同速永遠差 1 hex；trader 追 mobile partner 同理

## 不變量

- **嚴禁非同格互動**：戰鬥 / 貿易 / 外交 全需 `team.tile_pos == other.tile_pos`
- **NPC 不全知**：prey awareness 只用 `observe_velocity` / `known_reputations` / `team_intel`（皆 observable），不讀對方 `current_task`

## 目標

兩條子系統並行解 W1（combat）+ W2（trade）：

### W1：B + C + D 三方向組合
- **B Prey Awareness**：threat_score 評估（朝我來 + reputation + 實力比）
- **C Attacker Predict**：用 observe_velocity 自適應 N 步攔截預測
- **D Prey Active Reaction**：依個性選 逃跑/迎戰/備戰/求和（4 種）

### W2：trader target 限定 outpost
- trade_net dispatch 改為「找有 outpost 的 team」（靜止目標必到）
- 不需 trader 預測 partner

## 不在範圍

- 求援 / 信使類 task → 等 mounts/wagons speed_class spec
- 攔截方反追（C 的反向：prey 預測 attacker）→ 後續
- 戰報廣播（戰勝者 reputation 跨 faction 傳播）→ 後續
- 玩家版本反應 UI → 另 spec

## W1-C：Attacker 自適應預測

### `path_system.gd` 加 helper

```gdscript
static func predict_intercept(state: WorldState, attacker: TeamData,
        target: TeamData) -> Vector2i:
    var obs: Dictionary = observe_velocity(state, attacker, target)
    if not obs.get("visible", false):
        return target.tile_pos   # fallback: 當前位置（出視野）
    var direction: Vector2i = obs.get("direction", Vector2i.ZERO)
    var target_speed: float = float(obs.get("speed", 0.0))
    if direction == Vector2i.ZERO or target_speed < 0.1:
        return target.tile_pos   # 不動 prey → 直接朝當前位置
    var self_speed: float = _team_speed_mult(attacker)
    # 自適應 N：估幾步後能追上
    # 簡化：N = max(1, 自身path cost到對方當前位置)
    var path: Dictionary = find_path(state, attacker.tile_pos, target.tile_pos)
    var n: int = maxi(1, int(path.cost))
    # 預測點 = target 走 N 步後位置
    var predicted: Vector2i = target.tile_pos + direction * n
    return predicted
```

### 套到 `faction_ai_system._refresh_attack_pursuit`

既有刷新 move_target 用 prey 當前位置，改用 `predict_intercept`：

```gdscript
team.move_target = PathSystem.predict_intercept(state, team, prey)
```

= attacker 每 tick 用最新觀察更新預測攔截點。

## W1-B：Prey Threat Assessment

### 新檔 `scripts/simulation/threat_assessment.gd`

```gdscript
class_name ThreatAssessment

const THREAT_BASE_THRESHOLD: float = 0.3
const REPUTATION_NEUTRAL: float = 0.5
const POWER_BASELINE: float = 1.0

# threat_score：對單一觀察 team 評估威脅程度 [0, 1+]
static func score(state: WorldState, self_team: TeamData,
        other: TeamData) -> float:
    # 視野限制
    if not state.team_discovered.get(self_team.team_id, []).has(other.team_id):
        return 0.0
    # 朝我移動 [-1, 1]：1 = 全速朝我；-1 = 全速離開
    var approach: float = _approach_score(state, self_team, other)
    # 對方信譽（越低越敵）：(1 - rep) 範圍 [0, 1]
    var rep: float = float(self_team.known_reputations.get(other.team_id,
        REPUTATION_NEUTRAL))
    var hostility: float = clampf(1.0 - rep, 0.0, 1.0)
    # 實力比 (對方 / 我)，含 team_intel 已知資訊
    var power_ratio: float = _power_ratio(state, self_team, other)
    # 加權：朝我來 1.0 + 敵意 1.0 + 實力差 0.5
    var raw: float = approach * 1.0 + hostility * 1.0 + (power_ratio - 1.0) * 0.5
    # 距離衰減：越近越威脅
    var dist: int = _hex_dist(self_team.tile_pos, other.tile_pos)
    var dist_factor: float = clampf(1.0 - float(dist) / 5.0, 0.1, 1.0)
    return maxf(raw * dist_factor, 0.0)

# 對方 velocity 朝我來程度
static func _approach_score(state: WorldState, self_team: TeamData,
        other: TeamData) -> float:
    var obs: Dictionary = PathSystem.observe_velocity(state, self_team, other)
    if not obs.get("visible", false): return 0.0
    var dir: Vector2i = obs.get("direction", Vector2i.ZERO)
    if dir == Vector2i.ZERO: return 0.0
    # 向我 = (other.tile_pos + dir) 比 other.tile_pos 更靠近我
    var current_dist: int = _hex_dist(self_team.tile_pos, other.tile_pos)
    var future_pos: Vector2i = other.tile_pos + dir
    var future_dist: int = _hex_dist(self_team.tile_pos, future_pos)
    if current_dist == future_dist: return 0.0
    return clampf(float(current_dist - future_dist), -1.0, 1.0)

# 實力比 (other.power / self.power)
static func _power_ratio(state: WorldState, self_team: TeamData,
        other: TeamData) -> float:
    # 自身：實際資料
    var self_power: float = _team_power(self_team)
    # 對方：用 team_intel snapshot（NPC 不全知 — 用最後已知）
    var intel: Dictionary = state.team_intel.get(self_team.team_id,
        {}).get(other.team_id, {})
    var other_power: float = float(intel.get("power", _team_power(other)))
    return other_power / maxf(self_power, 0.1)

static func _team_power(team: TeamData) -> float:
    # 簡化：pop × avg_combat_skill + weapon * 0.3
    var combat: float = AnonTierSystem.avg_combat_skill(team)
    var weapon: float = float(team.resources.get("weapon_melee_low", 0)
        + team.resources.get("weapon_melee_high", 0) * 2)
    return float(team.population) * combat + weapon * 0.3

static func _hex_dist(a: Vector2i, b: Vector2i) -> int:
    var dx: int = b.x - a.x; var dy: int = b.y - a.y
    return (abs(dx) + abs(dx + dy) + abs(dy)) / 2
```

### Cadence 評估

`faction_ai_system._evaluate_threat`：

```gdscript
const THREAT_CADENCE: int = 240   # 1 日

func _evaluate_threat(state: WorldState, team: TeamData) -> void:
    if state.world.current_tick < team.threat_eval_next_tick: return
    team.threat_eval_next_tick = state.world.current_tick + THREAT_CADENCE
    # 戰鬥中不評
    if team.combat_target != -1: return
    # 已在反應 task 不重評
    if team.current_task in ["逃跑", "迎戰", "備戰"]: return
    var leader: PersonData = state.persons.get(team.leader_id)
    if leader == null: return
    var caution: float = float(leader.values.get("慎重", 0.5))
    var threshold: float = ThreatAssessment.THREAT_BASE_THRESHOLD + caution * 0.3
    # 找視野內 threat 最高
    var best_threat: float = 0.0
    var best_id: int = -1
    for tid in state.team_discovered.get(team.team_id, []):
        if tid == team.team_id: continue
        var other: TeamData = state.teams.get(tid)
        if other == null: continue
        var t: float = ThreatAssessment.score(state, team, other)
        if t > best_threat:
            best_threat = t
            best_id = tid
    if best_threat < threshold: return
    # 觸發 D 反應
    _dispatch_threat_response(state, team, best_id, best_threat)
```

事件觸發重評（同 prosperity）：
- 新發現 hostile team
- reputation 變動
- 自身受傷 / pop 暴跌

## W1-D：Prey Reaction Dispatch

### `faction_ai_system._dispatch_threat_response`

```gdscript
func _dispatch_threat_response(state: WorldState, team: TeamData,
        threat_id: int, threat_score: float) -> void:
    var leader: PersonData = state.persons.get(team.leader_id)
    if leader == null: return
    var survival: float = float(leader.values.get("求生欲", 0.5))
    var martial: float = float(leader.values.get("好戰", 0.5))
    var caution: float = float(leader.values.get("慎重", 0.5))
    var greed: float = float(leader.values.get("貪婪", 0.5))
    var honor: float = float(leader.values.get("信義", 0.5))
    var is_resident: bool = _is_resident_team(state, team)
    # 4 個反應評分
    var scores: Dictionary = {
        "逃跑": survival * 0.8 + (threat_score - 0.5) * 0.3,
        "備戰": caution * 0.6 + martial * 0.3,
        "求和": greed * 0.5 + honor * 0.3 - martial * 0.3,
    }
    if not is_resident:
        scores["迎戰"] = martial * 0.7 + (1.0 - threat_score) * 0.2
    # 選最高分
    var best: String = ""
    var best_score: float = -INF
    for action in scores:
        if scores[action] > best_score:
            best_score = scores[action]
            best = action
    # 派 task
    var other: TeamData = state.teams.get(threat_id)
    if other == null: return
    match best:
        "逃跑":
            team.current_task = "逃跑"
            team.move_target = _flee_target(state, team, other)
        "迎戰":
            team.current_task = "迎戰"
            team.move_target = other.tile_pos   # 預測也可，先簡化
            team.prosperity_target_id = threat_id
        "備戰":
            team.current_task = "備戰"
            team.move_target = Vector2i(-1, -1)   # 停留
        "求和":
            team.current_task = "外交"
            team.move_target = other.tile_pos
            team.order_target_id = threat_id
            team.order_task = "tribute_offer"
    print("[ThreatResponse] Team%d → %s (threat=Team%d, score=%.2f)" % [
        team.team_id, best, threat_id, best_score])
```

### 新 task constants

`team_data.gd`：

```gdscript
const TASK_DEFEND  := "迎戰"
const TASK_PREPARE := "備戰"
```

新 fields：

```gdscript
var threat_eval_next_tick: int = 0
```

### 反應 task handler

**迎戰**：
- 行為：朝 attacker 走（move_target 已設）
- 加成：morale_bonus（readiness × 1.2）+ 起始 stress 低
- 結束：同格 → start_combat / threat_score 降回 < threshold → idle
- 居民鎖白名單**不加**（不可離家）

**備戰**：
- 行為：停留（move_target = -1）
- 加成：readiness 慢漲（+0.01/tick）+ training_system 自動為 anon tier 加 exp
- 結束：threat 消失 → idle
- 居民鎖白名單**加**（在家停留 OK）

### 反應自動結束

`_evaluate_threat` 內，若 team 已在反應 task → check 是否仍有 threat：

```gdscript
if team.current_task in ["逃跑", "迎戰", "備戰"]:
    # 重評：threat 還在嗎？
    var still_threat: bool = _has_active_threat(state, team)
    if not still_threat:
        team.current_task = TeamData.TASK_IDLE
        team.move_target = Vector2i(-1, -1)
    return
```

## W2：Trade Target 限定 Outpost

### `strategic_ai_system._find_trade_partner` 改

```gdscript
func _find_trade_partner(state: WorldState, trader: TeamData) -> int:
    for tid in state.team_discovered.get(trader.team_id, []):
        var t: TeamData = state.teams.get(tid)
        if t == null: continue
        if t.faction_id != -1 and t.faction_id == trader.faction_id: continue
        # **新**：必須有 outpost（站點）才當 trade target
        var has_outpost: bool = false
        for tile_id in state.world.tiles:
            var tile: HexTileData = state.world.tiles[tile_id]
            if tile.outpost_owner == tid:
                has_outpost = true
                break
        if not has_outpost: continue
        if float(t.resources.get("goods", 0)) > 0 \
                or float(t.resources.get("coin", 0)) > 50:
            return tid
    return -1
```

= trader 只追靜止對象（outpost owner），必到。

### trade task timeout

防新形態 zombie：

```gdscript
const TRADE_TIMEOUT: int = 1440   # 6 日

# 在 trader 派 trade 時記錄
team.trade_task_start_tick = state.world.current_tick

# faction_ai 每 cadence check
if team.current_task == TeamData.TASK_TRADE:
    if state.world.current_tick - team.trade_task_start_tick > TRADE_TIMEOUT:
        team.current_task = TeamData.TASK_IDLE
        team.move_target = Vector2i(-1, -1)
```

## 衝突處理（task override 規則）

| 觸發 | 既有 task = | 行為 |
|---|---|---|
| 反應 dispatch | 戰鬥中 (`combat_target != -1`) | 不打斷 |
| 反應 dispatch | 攻擊/掠奪 | override（存亡優先）|
| 反應 dispatch | 訓練/生產/外交 | override |
| 反應 dispatch | 護衛 | 不打斷（任務絕對）|
| 反應 dispatch | 已在 逃跑/迎戰/備戰 | 不打斷 + 重評 threat |
| 居民團 | 任何反應 | 跳過 迎戰 選項 |

## 居民鎖白名單擴張

`movement_system.gd:47-52`：

```gdscript
if team.current_task not in ["逃跑", "投靠", "起義", "遷徙", "備戰"]:
    continue
```

= 加 `備戰`（停留在家，不真的離開，技術上需在白名單避免被誤鎖移動 = 0）。

不加 `迎戰`（居民團不該離家衝鋒）。

## 測試

1. **C predict_intercept basic**：prey 動向 (1,0)，predict 回 future_pos
2. **C predict_intercept 出視野**：fallback current
3. **C predict_intercept prey 不動**：回 current
4. **B threat_score 視野外**：0
5. **B threat_score 朝我來高 rep**：score 高
6. **B threat_score 敵意 + 強 + 接近**：score > 1
7. **D 反應評分：求生欲 0.9 → 逃跑**
8. **D 反應評分：好戰 0.9 + 非居民 → 迎戰**
9. **D 反應評分：好戰 0.9 + 居民 → 備戰**（不可迎戰）
10. **D 反應評分：商業/貪婪 → 求和（外交）**
11. **反應 task 自動結束**：threat < threshold → idle
12. **trade target outpost-only**：trader 不選 mobile partner
13. **trade timeout**：超 1440 tick → idle
14. **居民鎖白名單 備戰**：可停留（不被誤鎖）
15. **整合：multi 4 config × 90 天 Combat > 0 + Trade > 0**

## 風險

- **threat_score 公式 magic 數**：playtest tune
- **反應 task spam**：若 threat 一直在 threshold 邊緣，task 反覆切換 → 加 hysteresis（觸發 0.3、結束 0.2）
- **求和外交 spam**：tribute_offer 反覆 → 加 cooldown
- **C predict 偏差大**：prey 突然轉向 → attacker 撲空，每 tick refresh 緩解
- **居民團求生欲高 leader 全跑 → outpost 空城**：可能但合理
- **trader outpost-only 找不到合適**：rare（multi 有 outpost team），fallback 退回 mobile partner？暫不
- **整體性能**：threat cadence 每日 + 視野內 team 數 × score，可接受

## 解決

- W1：attacker 預測攔截 + prey awareness 反應 → 兩者朝對方走或反應 → 同格機率大增
- W2：trader 追靜止 outpost → 必到 → 同格交易
- 不破壞同格互動 invariant
- prey 有戲（逃 / 迎 / 守 / 和 4 種反應）
