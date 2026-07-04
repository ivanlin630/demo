# Mounts / Wagons 速度系統 — Design

> 日期：2026-06-11
> 議題：mounts/wagons 既有只加 carry capacity，無速度影響 → 騎兵跟步兵同速。需把速度差異化加進大地圖移動。戰場 mount unit-level 留後續 spec。

## 背景

當前狀態：
- `team.resources["mounts"]` 用於 `get_carry_capacity`（+ MOUNT_BONUS=15）
- `team.resources["wagons"]` carry + `WAGON_TERRAIN_MULT` 地形 penalty
- `_compute_team_speed` 不算 mount/wagon
- 無 mount 取得機制（只能 config 預設）
- 無 mount 損耗機制
- `_tick_stray_mounts`：超量 mount 慢慢流失

## 不變量

- 1 人控 1 生物（mount 或 wagon 二選一，effective_mounts + effective_wagons ≤ pop）
- mount/wagon 速度只影響大地圖，戰場單位級另 spec
- mount/wagon 仍維持既有 carry capacity 機制

## 目標

1. `_compute_team_speed` 加 mount bonus + wagon penalty
2. 1 人 1 獸限制：effective_mounts + effective_wagons ≤ pop
3. 新 facility「馬廄」眷養：food → mounts
4. 野外採集：tile.resources["wild_horses"] 少量
5. mount 吃糧（0.5 food/day per mount）
6. 移除 `_tick_stray_mounts`（mount 不流失）
7. 戰利品 loot 公式：勝方 loot = prey_mounts × kill_ratio

## 速度公式

### Mount bonus

```gdscript
effective_mounts = min(mounts, pop)
mount_ratio = effective_mounts / pop

# size penalty：大團騎兵協調混亂
size_penalty = 1.0 - clampf(float(effective_mounts) / 50.0, 0.0, 1.0) * 0.2

mount_speed_bonus = (1.0 + mount_ratio * 2.0) * size_penalty
```

| 騎兵 | mount_ratio | size_penalty | bonus |
|---|---|---|---|
| 0 | 0 | 1.0 | 1.0 |
| 1 (1 人) | 1.0 | 0.996 | 2.99 |
| 5 (10 人) | 0.5 | 0.98 | 1.96 |
| 25 (25 人) | 1.0 | 0.9 | 2.7 |
| 50 (50 人) | 1.0 | 0.8 | **2.4** |

### Wagon penalty

```gdscript
remaining_pop = pop - effective_mounts
effective_wagons = min(wagons, remaining_pop)
wagon_ratio = effective_wagons / pop

wagon_speed_penalty = 1.0 - wagon_ratio * 0.3
```

| 輜重 ratio | penalty |
|---|---|
| 0 | 1.0 |
| 0.5 | 0.85 |
| 1.0 | 0.7 |

無 wagon size penalty。

### 結合到 `_compute_team_speed`

```gdscript
func _compute_team_speed(state: WorldState, team: TeamData) -> float:
    var base_speed: float = _compute_base_team_speed(state, team)   # 既有 + tier
    var mount_bonus: float = _compute_mount_bonus(team)
    var wagon_penalty: float = _compute_wagon_penalty(team)
    return base_speed * mount_bonus * wagon_penalty

func _compute_mount_bonus(team: TeamData) -> float:
    if team.population <= 0: return 1.0
    var em: int = get_effective_mounts(team)
    if em == 0: return 1.0
    var ratio: float = float(em) / float(team.population)
    var size_penalty: float = 1.0 - clampf(float(em) / 50.0, 0.0, 1.0) * 0.2
    return (1.0 + ratio * 2.0) * size_penalty

func _compute_wagon_penalty(team: TeamData) -> float:
    if team.population <= 0: return 1.0
    var ew: int = get_effective_wagons(team)
    if ew == 0: return 1.0
    var ratio: float = float(ew) / float(team.population)
    return 1.0 - ratio * 0.3
```

### `get_effective_mounts/wagons` 更新

```gdscript
func get_effective_mounts(team: TeamData) -> int:
    return mini(int(team.resources.get("mounts", 0)), team.population)

func get_effective_wagons(team: TeamData) -> int:
    var rem: int = team.population - get_effective_mounts(team)
    return mini(int(team.resources.get("wagons", 0)), maxi(rem, 0))
```

= 1 人 1 獸限制（mount 跟 wagon 不能同人）。

## 新 Facility「馬廄」（眷養）

於 NPC infrastructure spec 既有 `FACILITY_DEF` registry 加：

```gdscript
FACILITY_DEF["stable"] = {
    "name": "馬廄",
    "cost": { "material": 30, "coin": 50 },
    "build_ticks": 7200,           # 1 個月建造
    "consumes": { "food": 5.0 },   # per day, 草料
    "produces": { "mounts": 0.3 }, # per day（slow）
    "tile_terrain": ["plains"],    # 只能蓋平原
    "level_cap": 3,                # 升級加產率
}
```

- Tier 1：5 food/day → 0.3 mounts/day
- Tier 2：10 food/day → 0.7 mounts/day
- Tier 3：15 food/day → 1.0 mounts/day（每天 1 馬）

NPC AI 評估蓋馬廄條件（自 facility AI 既有邏輯）：
- food 充足 + 軍隊/商隊 tag + 鄰平原

## 野外採集（極少）

`world_generator` 在 tile 生成時，極低機率加 wild_horses：

```gdscript
# plains: 1% 機率 1-2 隻 wild_horse
# forest: 0.5% 機率 1 隻
# mountain: 0
```

`harvest_system` 採集：team 站 wild_horse tile + task = 採集 → consume tile.wild_horses → 加 team.mounts。

每月再生：5% chance +1 per tile（極慢）。

= 早期沒設施時可從野外取得，但稀缺。

## Mount 吃糧

`resource_system._tick_team_resources` 加：

```gdscript
# mount 消耗 food 0.5/day per mount
var em: int = MovementSystem.get_effective_mounts(team)
var mount_food: float = float(em) * 0.5 / float(WorldState.TICKS_PER_DAY)
team.resources["food"] = maxf(0.0, float(team.resources.get("food", 0)) - mount_food)
```

= 大隊騎兵 food consumption 顯著增加。50 mounts = 25 food/day = 額外 10 人份。

無 food 時 mount 不直接死，但 team food < 0 觸發既有 food crisis 邏輯（survival）。

## 移除 `_tick_stray_mounts`

`movement_system.gd:_tick_stray_mounts` 直接刪。多餘 mount（> pop）只浪費 carry cap，不流失。

```gdscript
# 既有
func _tick_stray_mounts(team: TeamData) -> void:
    ...

# 刪除整函數 + 所有 call site
```

## 戰利品 Loot 公式

`encounter_system._resolve_encounter_end` 既有勝方 loot 邏輯擴展：

```gdscript
# 計算 mount loot（不含 wagons，wagons 屬於物資）
var prey_initial_pop: int = prey.encounter_initial_pop   # 既有快照欄位
var prey_dead: int = prey_initial_pop - prey.population
var prey_pop_kill_ratio: float = float(prey_dead) / maxf(float(prey_initial_pop), 1.0)
var prey_mounts: int = int(prey.resources.get("mounts", 0))
var mount_loot: int = roundi(float(prey_mounts) * prey_pop_kill_ratio)
prey.resources["mounts"] = prey_mounts - mount_loot
winner.resources["mounts"] = int(winner.resources.get("mounts", 0)) + mount_loot
```

| 戰況 | kill_ratio | mount_loot |
|---|---|---|
| 全滅 | 1.0 | prey 全部 |
| 死 60% | 0.6 | 60% |
| 死 30% | 0.3 | 30% |

wagons 不算 mount，視為「物資」走既有 loot 公式。

## 測試

1. **mount_ratio basic**：5 mounts / 10 pop = 0.5 ratio → bonus 1.96
2. **size_penalty**：50 mounts → 0.8
3. **1 人 1 獸**：5 mount + 8 wagon + 10 pop → effective wagon = 5（剩 5 人）
4. **mount + wagon 結合**：half cavalry + half wagon team speed 計算
5. **stable 建造 + 產 mount**：1 月後 +9 mounts
6. **wild_horse 採集**：team 在有 wild_horse tile + task 採集 → mounts +N
7. **mount 吃 food**：50 mounts/day = -25 food
8. **stray 移除**：超量 mount 不流失
9. **loot 全滅**：prey 5 mounts → winner +5
10. **loot 半勝**：prey 死 60% → winner +3
11. **整合：multi 4 config × 90 天 mount 進出 + 速度差異**

## 風險

- **size_penalty 對騎兵團懲罰**：50 騎兵 only 2.4X 可能仍不夠快追慢 prey → tune
- **mount food consumption 拖 food 經濟**：大騎兵團食物消耗加倍 → balance issue
- **stable food cost 30/month 過重**：影響 facility 經濟，需 tune
- **wild_horse 1% 機率**：極稀，後續可能 NPC 永遠採不到 → 觀察
- **移除 stray 後 mount > pop 不限**：超量 mount 仍計算 carry capacity bonus，可能 exploit（買大量馬不騎只當 carry）
  - 修：carry capacity 也用 effective_mounts 計算（已是 min）
- **encounter_initial_pop 欄位**：需確認 encounter_system 已記錄勝負前 prey pop，沒就加

## 解決

- 騎兵 vs 步兵速度差 → attacker（騎兵）追上 prey（步兵）→ 部分解 W1
- 商隊有馬 → 更快到 outpost → 部分解 W2
- 馬廄眷養 → 玩家 / NPC 有 mount 取得 channel
- 野外採集 → 早期 mount 來源（極稀）
- 戰利品 → 滅敵 reward 含 mount
