# 武器裝備 + 戰鬥強化 設計規格

**日期**：2026-05-25
**範圍**：武器裝備系統、資源鏈擴充、戰鬥機制強化、技能掛勾

---

## 目標

1. 武器從抽象 pool 改為個人裝備欄位（記名 NPC）
2. 4 種武器類型（melee/ranged × low/high），影響戰鬥計算
3. 新資源鏈：ore_iron → ore_steel → 高階武器
4. 戰鬥強化：齊射回合、地形、包圍、士氣崩潰、追擊
5. 掛勾現有未使用技能：弓箭、戰術

---

## 資源層變更

### 移除 / 替換

| 舊 key | 新 key |
|---|---|
| `weapon` | `weapon_melee_low` / `weapon_melee_high` / `weapon_ranged_low` / `weapon_ranged_high` |

### 新增資源

| key | 說明 | 來源 |
|---|---|---|
| `ore_iron` | 鐵礦，有限礦源 | 世界採集（mountain 主要，plains 少量） |
| `ore_steel` | 精煉鋼，無法採集 | 製造（冶煉 ore_iron） |

### 世界生成（world_generator.gd）

- mountain tile：30% 機率有 ore_iron（初始量 50–150）
- plains tile：5% 機率有 ore_iron（初始量 20–60）
- ore_iron 不再生（有限資源，同 ore_gold/ore_silver）

---

## 製造配方（manufacturing_system.gd）

優先序由高至低：

| 配方 | 消耗 | 產出 | 輸出率 |
|---|---|---|---|
| 冶煉 | ore_iron×2 + material×1 | ore_steel×1 | worker_rate × 0.5 |
| 高階近戰武器 | ore_steel×2 + material×3 | weapon_melee_high | worker_rate × 0.03 |
| 高階遠程武器 | ore_steel×2 + material×4 | weapon_ranged_high | worker_rate × 0.025 |
| 低階近戰武器 | ore_iron×2 + material×3 | weapon_melee_low | worker_rate × 0.05 |
| 低階遠程武器 | ore_iron×2 + material×4 | weapon_ranged_low | worker_rate × 0.04 |

> 所有率值為 TEST VALUE，平衡期調整。

---

## PersonData 變更

```gdscript
# 新增欄位
var equipment: Dictionary = { "weapon": "" }
# "" = 未武裝
# "melee_low" / "melee_high" / "ranged_low" / "ranged_high"
```

---

## TeamData 變更

```gdscript
# 新增欄位（commander 設定裝備配置目標）
var equip_order: Dictionary = {
    "melee_low":   0,
    "melee_high":  0,
    "ranged_low":  0,
    "ranged_high": 0,
}

# resources 更新（移除 weapon，加 4 鍵）
var resources: Dictionary = {
    "food": 0.0, "material": 0, "coin": 0, "goods": 0,
    "gem": 0, "ore_gold": 0, "ore_silver": 0,
    "ore_iron": 0, "ore_steel": 0,
    "weapon_melee_low": 0, "weapon_melee_high": 0,
    "weapon_ranged_low": 0, "weapon_ranged_high": 0,
}
```

---

## EquipmentSystem（新建）

`scripts/simulation/equipment_system.gd`

### 每 Tick 裝備結算

每人裝備消耗 **2 單位**，卸裝歸還 2 單位。

```
for each team:
  target = team.equip_order
  currently_equipped = count persons by equipment type
  for each weapon_type in target:
    deficit = target[type] - currently_equipped[type]
    if deficit > 0:
      can_equip = pool[type] / 2          # 整除，不出現小數
      equip min(deficit, can_equip) 人
      pool[type] -= equipped_count * 2
    elif deficit < 0:
      unequip abs(deficit) 人（逆序）
      pool[type] += unequipped_count * 2
```

### 匿名人口武裝比例

```gdscript
var anon_pop: int = team.population - named_count
var pool_remaining: int = sum(weapon_melee_low + weapon_melee_high + ...)
                          - sum(equip_order.values())
var armed_anon: int = mini(anon_pop, maxi(pool_remaining, 0))
var armed_anon_ratio: float = float(armed_anon) / float(maxi(anon_pop, 1))
```

### 死亡武器處理

**記名 NPC 死亡：**
- 武器 50% 回 pool（原類型）× 2 單位，50% 損毀
- 整數計算：`recovered_units = (1 if randf() < 0.5 else 0) * 2`

**匿名人口死亡（`_apply_casualties` 內）：**
```gdscript
var armed_dead: int = int(float(anon_casualties) * team.armed_anon_ratio)  # 無 round，截斷
var recovered_persons: int = armed_dead / 2   # 50%，整除
var recovered_units: int   = recovered_persons * 2   # 每人 2 單位
# 按現有 pool 各類型比例分配回收（整數）
var pool_total: int = _weapon_pool_total(team)
if pool_total > 0 and recovered_units > 0:
    for wkey in ["weapon_melee_low","weapon_melee_high","weapon_ranged_low","weapon_ranged_high"]:
        var share: int = team.resources.get(wkey, 0) * recovered_units / pool_total
        team.resources[wkey] = int(team.resources.get(wkey, 0)) + share
```

**掠奪時：** loot 擴充至 4 種武器 key（現有 loot rate 適用）

---

## 戰鬥系統強化（interaction_system.gd）

### 戰力公式重構

```gdscript
func _team_strength(state: WorldState, team_id: int) -> float:
    var team: TeamData = state.teams[team_id]
    var leader = state.persons.get(team.leader_id)

    # 統領加成（現有）
    var cmd: float = float(leader.skills.get("統領", 0.0)) if leader else 0.0
    var excess: float = clampf((cmd - 0.8) / 0.2, 0.0, 1.0)
    var leadership_mult: float = 1.0 + excess * 0.5

    # 戰術加成（新）
    var tactics: float = float(leader.skills.get("戰術", 0.0)) if leader else 0.0
    var tactics_mult: float = 1.0 + tactics * 0.3   # TEST VALUE

    # 記名 NPC 武裝統計
    var melee_str: float = 0.0
    var ranged_str: float = 0.0
    for pid in ([team.leader_id] as Array) + team.advisors + team.members:
        var p: PersonData = state.persons.get(pid)
        if p == null: continue
        var wtype: String = p.equipment.get("weapon", "")
        match wtype:
            "melee_low":
                melee_str += (0.5 + float(p.skills.get("戰鬥", 0.0)) * 0.5) * 0.8
            "melee_high":
                melee_str += (0.5 + float(p.skills.get("戰鬥", 0.0)) * 0.5) * 1.2
            "ranged_low":
                ranged_str += (0.5 + float(p.skills.get("弓箭", 0.0)) * 0.5) * 0.8
            "ranged_high":
                ranged_str += (0.5 + float(p.skills.get("弓箭", 0.0)) * 0.5) * 1.2
            _:  # 未武裝
                melee_str += 0.3   # 徒手基礎值

    # 匿名人口
    var anon_pop: int = maxi(team.population - team.wounded
                             - ([team.leader_id] as Array + team.advisors + team.members).size(), 0)
    melee_str += float(anon_pop) * armed_anon_ratio * 0.5   # armed_anon_ratio 來自 EquipmentSystem

    return (melee_str + ranged_str) * leadership_mult * tactics_mult
```

> `armed_anon_ratio` 由 EquipmentSystem 計算後存入 TeamData（新欄位 `armed_anon_ratio: float`）。

### Round 0：齊射

`_resolve_combat_round` 呼叫前，第一回合插入：

```gdscript
func _resolve_volley(state: WorldState, id_a: int, id_b: int) -> void:
    # 雙方 ranged 同時射擊
    var volley_a: float = _ranged_strength(state, id_a)
    var volley_b: float = _ranged_strength(state, id_b)
    var total: float = volley_a + volley_b
    if total <= 0.0: return
    var eff_a: int = maxi(state.teams[id_a].population - state.teams[id_a].wounded, 1)
    var eff_b: int = maxi(state.teams[id_b].population - state.teams[id_b].wounded, 1)
    var loss_a: int = max(int(round(eff_a * volley_b / total * VOLLEY_CASUALTY_RATE)), 0)
    var loss_b: int = max(int(round(eff_b * volley_a / total * VOLLEY_CASUALTY_RATE)), 0)
    _apply_casualties(state, id_a, loss_a)
    _apply_casualties(state, id_b, loss_b)
    print("[Volley] A+%d B+%d" % [loss_a, loss_b])
```

> `VOLLEY_CASUALTY_RATE`：TEST VALUE（建議 0.05，低於 ROUND_CASUALTY_RATE）。

### 地形防禦

```gdscript
func _terrain_defense_mult(state: WorldState, team: TeamData) -> float:
    var tile = state.world.tiles.get(team.tile_pos.x * 1000 + team.tile_pos.y)
    if tile == null: return 1.0
    match tile.terrain:
        "forest":   return 1.2
        "mountain": return 1.15
    return 1.0
```

防守方 strength × `_terrain_defense_mult`。

### 數量包圍

```gdscript
# 在 _resolve_combat_round 內
var ratio: float = float(eff_a) / float(maxi(eff_b, 1))
var flank_mult: float = 1.0
if ratio >= 3.0:
    var tactics_b: float = float(state.persons.get(b.leader_id).skills.get("戰術", 0.0)) \
                           if state.persons.get(b.leader_id) else 0.0
    flank_mult = 1.3 - tactics_b * 0.3   # TEST VALUE：戰術最高可抵消全部包圍加成
loss_b = int(round(loss_b * flank_mult))
```

（攻守互換同理）

### 士氣崩潰

```gdscript
# _apply_casualties 後判斷
var casualty_ratio: float = float(team.wounded) / float(maxi(team.population, 1))
if casualty_ratio > 0.3:
    team.readiness = maxf(team.readiness - ROUND_READINESS_DRAIN * 2.0, 0.0)
```

### 追擊

```gdscript
# _force_retreat / _end_combat 時
func _apply_pursuit(state: WorldState, winner_id: int, loser_id: int) -> void:
    var winner: TeamData = state.teams[winner_id]
    var loser: TeamData  = state.teams[loser_id]
    if winner.population < loser.population * 2:
        return
    var pursuit_loss: int = max(int(round(loser.population * PURSUIT_RATE)), 0)
    _apply_casualties(state, loser_id, pursuit_loss)
    print("[Pursuit] Team%d 追擊，Team%d 額外傷亡 %d" % [winner_id, loser_id, pursuit_loss])
```

> `PURSUIT_RATE`：TEST VALUE（建議 0.05）。

---

## 技能成長掛勾（skill_system.gd / interaction_system.gd）

| 技能 | 觸發時機 | 成長對象 |
|---|---|---|
| 戰鬥 | 每個戰鬥回合（melee 武裝者） | 各 melee 裝備 NPC |
| 弓箭 | Round 0 齊射（ranged 武裝者） | 各 ranged 裝備 NPC |
| 戰術 | 戰鬥結束（win 或 lose） | leader |

成長公式沿用 SkillSystem 現有：`BASE_GROWTH × attr × 毅力修正 × part_mult`
- 戰鬥：依賴 體力
- 弓箭：依賴 智力 + 體力
- 戰術：依賴 智力

---

## FactionAI 裝備決策

`faction_ai_system.gd` — `_assign_member_tasks` 或新 `_update_equip_order`：

```
if team.tags has "軍隊" or "掠奪":
    equip_order["melee_high"] = pool 的 melee_high 數量（全裝）
    equip_order["ranged_high"] = pool 的 ranged_high 數量
    填滿剩餘用 melee_low / ranged_low
elif team.tags has "商隊":
    equip_order["melee_low"] = mini(population * 0.3, pool total)
else:
    equip_order["melee_low"] = mini(population * 0.5, pool total)
```

---

## SimRunner 整合

`sim_runner.gd` — 在 step2 資源收集後、step4 人物反應前加：

```gdscript
_step2b_update_equipment(state, near_teams)

func _step2b_update_equipment(state: WorldState, team_ids: Array) -> void:
    _equipment_system.tick_all(state, team_ids)
```

---

## 影響的既有系統

| 系統 | 變更 |
|---|---|
| `resource_system.gd` | `collect_resources` 加 ore_iron 收集（同 ore_gold 邏輯） |
| `interaction_system.gd` | loot 擴充 4 種武器 key；_team_strength 重寫 |
| `event_unrest_split.gd` | new_team.resources 加 4 武器 key，初始 0 |
| `subteam_system.gd` | dispatch 按比例分配 4 武器 key |
| `headless_test.gd` | 初始資源改 4 鍵；加 ore_iron；設 equip_order；加裝備統計輸出 |
| `docs/person.md` | 弓箭技能說明補充：智力+體力，由 interaction_system 成長 |

---

## 驗證

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --import
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

預期：
- 無 SCRIPT ERROR，`=== DONE ===`
- `[Equip]` 出現（NPC 裝備武器）
- `[Volley]` 出現（齊射回合）
- `[Pursuit]` 出現（追擊）
- melee_high / ranged_high 武器出現在軍隊 team
- Person 弓箭/戰鬥/戰術技能有成長

---

## ⚠️ TEST VALUE 清單

| 常數 | 值 | 位置 |
|---|---|---|
| `VOLLEY_CASUALTY_RATE` | 0.05 | interaction_system |
| `PURSUIT_RATE` | 0.05 | interaction_system |
| 武器死亡回收率 | 50%（整數，每人2單位） | equipment_system |
| 戰術抵消包圍 | `tactics × 0.3` | interaction_system |
| 地形防禦 forest | ×1.2 | interaction_system |
| 地形防禦 mountain | ×1.15 | interaction_system |
| 士氣崩潰門檻 | 30% 傷亡 | interaction_system |
| ore_iron 產出率（冶煉） | ×0.5 | manufacturing_system |
| 各武器輸出率 | 見配方表 | manufacturing_system |
