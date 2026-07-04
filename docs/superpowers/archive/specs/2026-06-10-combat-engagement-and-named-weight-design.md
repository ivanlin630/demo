# NPC 戰鬥成形（同格 scan + named 加權）— Design

> 日期：2026-06-10
> 議題：prosperity_attack 排程 OK 但 encounter=0。引擎 arrived-only 觸發不夠（兩 mobile team 同速擦肩永不同時 arrived）。+ team speed 幾乎等速（unnamed 1.0 + named 0.75 平均吃掉差異）

## 背景

當前狀態：
- `process_on_arrival` 只對「該 tick 真正 arrived 的 team」掃同格 try_interact
- 兩 mobile team 同速永遠差 ≥ 1 hex，prey 走開 attacker 永遠抓不到 arrived 同格的瞬間
- `_compute_team_speed`：named 跟 unnamed 1:1 平均 → 大多 team unnamed pop 多 → speed 接近 unnamed 預設 1.0
- 結果：team speed 幾乎統一 → 追擊無法收斂

需求：
1. 寬版同格 scan：每 tick 對「移動過的 team」掃同格 try_interact（不限 arrived）
2. named 影響加權 K=3（leader 個性差異真正能改 team speed）
3. mounts/wagons 速度 bonus 未實作 → known_issues
4. anon 質量系統 → 另開 brainstorm spec（Q1+Q2+Q6）

## 目標

1. 擴展 `movement_system.process` 回傳 → 加 `moved_ids`（該 tick tile_pos 改變者）
2. `interaction_system.process_on_arrival` 改 `process_on_move`：收 moved_ids，對全 team 同格 try_interact
3. `_compute_team_speed` named 權重 ×3
4. known_issues.md 加「mounts/wagons 速度 bonus 未實作」

## 不在範圍

- anon 質量系統（另開 brainstorm）
- 騎兵 / 馱獸速度 bonus 實作
- 偵察 / 傳聞（NPC 出視野資訊）
- 戰爭階段化（B 構想）
- 防守方 awareness 預警（C 構想）

## Change 1：寬版同格 scan

### movement_system

`process` 改回傳兩個 array：

```gdscript
func process(state: WorldState, team_ids: Array, time_mult: float = 1.0) -> Dictionary:
    var arrived: Array = []
    var moved: Array = []
    for tid in team_ids:
        # ... 既有邏輯
        if _step_team(state, team):
            arrived.append(tid)
            moved.append(tid)
        elif team.tile_pos != old_pos_snapshot:
            moved.append(tid)
    return { "arrived": arrived, "moved": moved }
```

實際上 `_step_team` 結尾 `team.tile_pos != old_pos` 已判定 moved，可在裡面記。

最小改：

```gdscript
func _step_team(state: WorldState, team: TeamData) -> bool:
    var old_pos: Vector2i = team.tile_pos
    # ... 既有邏輯
    return team.tile_pos != old_pos   # 既有：moved
```

外層分 arrived（額外 condition: tile_pos == 原 move_target）vs moved（只要 tile_pos 變）。

### interaction_system

新函數 `process_on_move(state, moved_ids, all_team_ids)`：

```gdscript
func process_on_move(state: WorldState, moved_ids: Array, all_team_ids: Array) -> void:
    for moved_id in moved_ids:
        if not state.teams.has(moved_id): continue
        if _sub.try_merge_back(state, moved_id): continue
        var moved: TeamData = state.teams[moved_id]
        if moved.current_task == "護衛": continue
        for other_id in all_team_ids:
            if other_id == moved_id: continue
            var other: TeamData = state.teams.get(other_id)
            if other == null: continue
            if other.tile_pos != moved.tile_pos: continue
            _try_interact(state, moved_id, other_id)
```

= 既有 `process_on_arrival` 的擴展，差別只在收 moved 不是 arrived。

`sim_runner` call 點改：
```gdscript
var move_result: Dictionary = _movement_system.process(state, team_ids, time_mult)
_interaction_system.process_on_move(state, move_result["moved"], team_ids)
# 既有 process_on_arrival 由 process_on_move 取代
```

注意：`message_system.propagate_on_arrival` / `exchange_intel_on_arrival` 是否也改 moved？
- 訊息傳播/intel 交換 用 arrived 還是 moved？arrived 表示「停下不動了」，intel 交換比較合理。**保留 arrived，不改。**

### 影響

- 兩 mobile team 同格 → 任一方 step 完即可觸發
- 同格 try_interact 既有所有 path 都會跑（trade / diplomacy / merge / extort / combat...）
- 性能：moved_ids 通常 < arrived_ids + (路過數)，每 tick × 全 team 掃 N²（N <20 → 400 ops/tick，OK）

## Change 2：named 加權 K=3

### `_compute_team_speed`

```gdscript
const NAMED_WEIGHT: int = 3

func _compute_team_speed(state: WorldState, team: TeamData) -> float:
    var total_speed: float = 0.0
    var total_count: int = 0
    var named_ids: Array = team.named_members.duplicate()
    if team.leader_id != -1:
        named_ids.append(team.leader_id)
    for pid in named_ids:
        var p = state.persons.get(pid)
        if p != null:
            total_speed += p.get_effective_speed() * NAMED_WEIGHT
            total_count += NAMED_WEIGHT
    var unnamed_healthy: int = maxi(team.population - named_ids.size() - team.wounded, 0)
    total_speed += float(unnamed_healthy) * 1.0
    total_count += unnamed_healthy
    total_speed += float(team.wounded) * 0.5
    total_count += team.wounded
    if total_count == 0:
        return 1.0
    return total_speed / float(total_count)
```

### 影響

- leader 體力高（0.9）→ named speed 0.95 × 3 = 2.85 加權
- 10 人 team（2 named + 8 unnamed）：
  - 舊：(2*0.75 + 8*1.0) / 10 = 0.95
  - 新：(2*0.75*3 + 8*1.0) / (2*3 + 8) = 12.5/14 = 0.893
- leader 體力 0.9 同團：
  - 新：(2*0.95*3 + 8*1.0) / 14 = 13.7/14 = 0.979
- leader 體力 0.3：
  - 新：(2*0.65*3 + 8*1.0) / 14 = 11.9/14 = 0.85

= leader 個性差異現在 ±10% 速度差，舊只 ±3%。

### NAMED_WEIGHT 為何 3

- K=1 既有，差異被吃
- K=2 改善有限
- K=3 leader 個性真實影響 ±10%（測試值，後續可 tune）
- K>5 反成 leader 一人決定（unnamed 無意義）

## Change 3：mounts/wagons known_issue

`docs/known_issues.md` 加：

```markdown
## Movement
- **mounts/wagons 沒加速度**：`_compute_team_speed` 只算個人速度 + status；mounts 只加 carry capacity。
  待 spec：speed_class（步兵/騎兵/輜重）+ mount 速度 bonus + wagon 拖速 penalty。
```

## 不變量

- moved_ids ⊇ arrived_ids（arrived 一定 moved）
- moved team 對全 team 掃同格的成本 O(N²)
- NAMED_WEIGHT > 0
- named 0 人 team 不分母 0（既有 total_count==0 守備）
- 既有 trade / diplomacy / merge 邏輯在 process_on_move 也會觸發（不只戰鬥）

## 測試

1. **moved 但不 arrived 同格 → 戰鬥觸發**：A 攻擊 P，A 移到 P 格但 move_target=遠處
2. **arrived 仍正常**：A move_target==tile_pos，arrived=true，moved=true，照樣 try_interact
3. **既有路徑保留**：玩家 attack indep（process_on_move 觸發 player path 不誤觸）
4. **K=3 named speed 加權**：leader 體力 0.9 vs 0.3 team speed 差 ±10%
5. **K=3 named 0 人 fallback**：team named=0 → 純 unnamed 平均
6. **process_on_move 性能**：30 team × 30 tick 不卡
7. **message intel 不誤觸**：propagate_on_arrival 保留 arrived（不收 moved）
8. **game_sim_multi 4 config × 90 天 encounter > 0**

## 風險

- **寬版同格 scan 可能誤觸 trade/diplomacy**：兩商隊 idle 路過同格本來不交易，現在會被 process_on_move 觸發 _try_interact → trade 路徑。**需驗證既有同格邏輯都能處理「moved 而非 arrived」狀況。**
- **subteam try_merge_back**：原本 arrived 才嘗試合併回母隊；改 moved 後每路過就試一次，可能頻繁。要確認 try_merge_back 自帶防呆。
- **player_pending_targets / forced_event** 多次塞同 npc_id：既有檢查 `not in pending_targets` 防呆，OK。
- **process_on_arrival 還有沒有其他 caller**：sim_runner 外應無
- **NAMED_WEIGHT=3 副作用**：team speed 變動 → ETA 變動 → AI cadence 變動 → 整體節奏改

## 解決

- 兩 mobile team 同格即觸發 → ProsperityAttack 真正進入戰鬥
- leader 體力差異真實反映在 team speed → 追擊有勝算
- 不破壞既有 arrived-only intel/訊息傳播語意

## 後續（另 spec）

- anon 質量系統（Q1+Q2+Q6）
- mounts/wagons speed bonus + speed_class
- 偵察 + 傳聞（出視野資訊）
- 戰爭階段化（B 構想）
- 防守方 awareness 預警（C 構想）
