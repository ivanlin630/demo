# S7 faction_ai 動態初始化 TeamData 戰鬥參數 — Design

> 日期：2026-06-07
> 議題：S7a–S7d（known_issues.md）— TeamData 戰鬥/經濟欄位有設計、有讀取，但 faction_ai 從未寫入

## 背景

`TeamData` 有 4 個欄位定義完整，simulation 系統有讀取，但 `faction_ai_system`、`world_generator`、`game_setup` 從未寫入。所有隊伍走預設值，與勢力類型無關。

| 欄位 | 預設 | 讀取位置 | 影響 |
|---|---|---|---|
| `resources["anon_combat_skill"]` | `0.2`（fallback） | `encounter_system._create_anon_unit` line 152 | 所有匿名單位戰鬥技能固定 0.2 |
| `armor_config` | `{torso:low, 其他:none}` | `encounter_system._init_anon_unit` line 862/871 | 所有隊伍只穿 torso low |
| `guard_ratio` | `0.2` | `day_night_system._guard_count` line 40；`sim_runner` 疲勞回復 line 215 | 警戒比例固定，疲勞回復固定 |
| `anon_wage` | `1.0` | `salary_system` line 45 | 薪資結構無勢力差異 |

## 目標

`faction_ai_system.run()` 每輪迭代 team 時，依 `team.tags` + `team.current_task` + 鄰近威脅，動態計算這 4 個欄位。

## 不在範圍

- 動態升級（訓練軍隊提升 combat_skill）
- 玩家手動設定這些參數的 UI
- world_generator 設定靜態初值（讓 faction_ai 首輪即計算）

## 架構

跟隨 `_update_equip_order` 模式（`faction_ai_system.gd` line 479-505）：

- 4 個新私有函數 `_update_anon_combat_skill`、`_update_armor_config`、`_update_guard_ratio`、`_update_anon_wage`
- 在 `run()` 末尾的 team 迴圈中呼叫（line 81-84 同位置）

## 資料結構變更

### `scripts/data/team_data.gd`

`anon_combat_skill` 從 `resources` dict 移出為獨立欄位（`resources` 應只放物資量）：

```gdscript
# 移除：resources["anon_combat_skill"]
# 新增：
var anon_combat_skill: float = 0.2
```

### `scripts/simulation/encounter_system.gd:152`

```gdscript
# 舊：
"skills": { "戰鬥": float(team.resources.get("anon_combat_skill", 0.2)) },
# 新：
"skills": { "戰鬥": team.anon_combat_skill },
```

## 更新邏輯

### 1. `_update_anon_combat_skill(team: TeamData)`

驅動：`team.tags`

| Tag | 值 |
|---|---|
| `TAG_MILITARY` | 0.5 |
| `TAG_MERCHANT` | 0.2 |
| `TAG_PRODUCE` | 0.15 |
| `TAG_RELIGION` | 0.2 |
| `TAG_EXILE` | 0.3 |
| default | 0.25 |

Tag 多重時取最高值。結果 clamp 到 `[0.1, 0.8]`。

### 2. `_update_armor_config(team: TeamData)`

驅動：`team.tags` + `team.resources` 護甲庫存

```gdscript
var has_high: bool = int(team.resources.get("armor_high", 0)) >= team.population * 0.3
var has_low:  bool = int(team.resources.get("armor_low", 0))  >= team.population * 0.3
```

| 條件 | armor_config |
|---|---|
| `TAG_MILITARY` + has_high | `{torso:high, head:low, right_arm:low, left_arm:low, right_leg:low, left_leg:low}` |
| `TAG_MILITARY` + 僅 has_low | `{torso:low, head:low, 其餘:none}` |
| `TAG_MERCHANT` + has_low | `{torso:low, 其餘:none}` |
| 其他 + has_low | `{torso:low, 其餘:none}` |
| 任何 + 無護甲 | `{全部:none}` |

護甲庫存閾值 `0.3 × population` 為「能裝備 30% 的兵」，避免少量護甲也設定 config 結果分不到。

### 3. `_update_guard_ratio(team: TeamData, state: WorldState)`

驅動：`current_task` + 鄰近敵對 team

```gdscript
# 計算鄰近威脅：distance <= 3 的 hex 內有敵對 team
var threat_nearby: bool = _has_hostile_within(state, team, 3)
```

| 條件 | guard_ratio |
|---|---|
| `current_task` in [攻擊, 掠奪] | 0.1 |
| `TAG_MILITARY` + threat_nearby | 0.4 |
| threat_nearby | 0.35 |
| `TAG_PRODUCE` | 0.15 |
| default | 0.2 |

結果 clamp 到 `[0.05, 0.5]`。

`_has_hostile_within(state, team, range)` 新增輔助函數：掃描 `state.teams` 找 `faction_id` 不同且 `hex_dist <= range` 的 team。

### 4. `_update_anon_wage(team: TeamData)`

驅動：`team.tags`

| Tag | 值 |
|---|---|
| `TAG_MILITARY` | 1.5 |
| `TAG_MERCHANT` | 1.2 |
| `TAG_PRODUCE` | 0.7 |
| `TAG_RELIGION` | 0.5 |
| `TAG_EXILE` | 0.3 |
| default | 1.0 |

Tag 多重時取最高值。結果 clamp 到 `[0.0, 2.0]`。

## 呼叫順序

`faction_ai_system.gd:run()` 末尾迴圈擴充：

```gdscript
for tid in state.teams:
    if not state.teams.has(tid):
        continue
    var team: TeamData = state.teams[tid]
    _update_equip_order(state, team)
    _update_anon_combat_skill(team)
    _update_armor_config(team)
    _update_guard_ratio(team, state)
    _update_anon_wage(team)
```

順序：先 `_update_equip_order`（既有），再 4 個新函數。彼此無依賴關係，順序可調整。

## 測試

`headless_test.gd` 新增 test case：

1. **MILITARY 高戰技**：建 `tags=[TAG_MILITARY]` team → 跑 `faction_ai.run()` → `anon_combat_skill >= 0.4`
2. **PRODUCE 低薪資**：建 `tags=[TAG_PRODUCE]` team → `anon_wage <= 0.8`
3. **威脅高警戒**：建 2 teams（不同 faction，距離 2）→ 兩者 `guard_ratio >= 0.3`
4. **MILITARY 高甲**：建 `tags=[TAG_MILITARY]` + `armor_high=20`, `population=10` → `armor_config["torso"] == "high"`
5. **無護甲全 none**：建 `armor_low=0, armor_high=0` team → `armor_config` 全為 `"none"`
6. **資料遷移**：`team.anon_combat_skill` 欄位存在；`team.resources` 不含 `"anon_combat_skill"` key

## 不變量

- 4 個欄位每輪重算，覆寫前一輪值（無累積）
- clamp 範圍：`combat_skill ∈ [0.1, 0.8]`，`guard_ratio ∈ [0.05, 0.5]`，`anon_wage ∈ [0.0, 2.0]`
- `team.armor_config` 預設值保留為 fallback（給尚未跑過 faction_ai 的新建 team）
- 既有 `_update_equip_order` 邏輯不動

## 風險

- **欄位遷移破壞性**：`anon_combat_skill` 從 resources 搬出，需確認沒有其他系統讀 `team.resources["anon_combat_skill"]`（grep 確認後僅 encounter_system 一處）
- **存檔相容性**：若有 save/load 系統會受影響（目前無 save/load，可忽略）
- **跨 team 掃描成本**：`_has_hostile_within` 需迭代 `state.teams`，O(n)；team 數通常 <50，可接受

## 解決的 known_issues

- S7a — `anon_combat_skill`
- S7b — `armor_config`
- S7c — `guard_ratio`
- S7d — `anon_wage`
