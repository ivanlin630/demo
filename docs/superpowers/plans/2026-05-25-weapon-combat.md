# 武器裝備 + 戰鬥強化 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 將武器從抽象數量 pool 改為個人裝備欄位，新增 ore_iron/ore_steel 資源鏈，強化抽象戰鬥系統（地形、包圍、士氣、齊射、追擊），並掛勾弓箭/戰術技能成長。

**Architecture:** PersonData 加裝備欄位；TeamData 替換 weapon 為 4 種武器 key 並加 equip_order；新增 EquipmentSystem 負責每 Tick 裝備結算；InteractionSystem 戰鬥函數全面重寫；SkillSystem 加戰鬥技能成長。

**Tech Stack:** Godot 4.2.2 GDScript headless 模擬，無 UI。

**Spec:** `docs/superpowers/specs/2026-05-25-weapon-combat-design.md`

**驗證指令：**
```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --import
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

---

## 檔案結構

| 檔案 | 動作 |
|---|---|
| `scripts/data/person_data.gd` | 加 `equipment` 欄位，skills 加偵查/潛行 |
| `scripts/data/team_data.gd` | 替換 `weapon` → 4 武器 key，加 `equip_order`、`armed_anon_ratio` |
| `scripts/simulation/world_generator.gd` | 加 ore_iron 礦源 |
| `scripts/simulation/manufacturing_system.gd` | 重寫 `_run_recipes`：5 種新配方 |
| `scripts/simulation/equipment_system.gd` | **新建**：裝備結算、死亡回收 |
| `scripts/simulation/sim_runner.gd` | 加 `_equipment_system`，加步驟 |
| `scripts/simulation/interaction_system.gd` | 重寫戰力公式、加 Round 0、地形、包圍、士氣、追擊、loot 更新 |
| `scripts/simulation/skill_system.gd` | 加 `on_combat_round` / `on_combat_end` |
| `scripts/simulation/faction_ai_system.gd` | 加 `_update_equip_order`，更新 TRADEABLE_RES |
| `scripts/simulation/events/event_unrest_split.gd` | 更新 resources dict |
| `scripts/debug/headless_test.gd` | 全面更新資源 dict、加 equip_order、ore_iron、武器統計輸出 |

---

## Task 1：PersonData + TeamData 資料層

**Files:**
- Modify: `scripts/data/person_data.gd`
- Modify: `scripts/data/team_data.gd`

- [ ] **Step 1：更新 person_data.gd**

在 `skills` dict 末尾加 `偵查`/`潛行`（若尚未加），並加 `equipment` 欄位：

```gdscript
# scripts/data/person_data.gd
# skills dict 改為 14 項：
var skills: Dictionary = {
    "統領": 0.0, "戰鬥": 0.0, "弓箭": 0.0, "求生": 0.0,
    "生產": 0.0, "製造": 0.0, "工程": 0.0, "醫療": 0.0,
    "戰術": 0.0, "計謀": 0.0, "交涉": 0.0, "商業": 0.0,
    "偵查": 0.0, "潛行": 0.0,
}

# 在 values 之後、memory 之前加：
var equipment: Dictionary = { "weapon": "" }
# "" = 未武裝；"melee_low" / "melee_high" / "ranged_low" / "ranged_high"
```

- [ ] **Step 2：更新 team_data.gd**

替換 `resources` 中的 `"weapon"` 為 4 個武器 key，並加 `equip_order` 和 `armed_anon_ratio`：

```gdscript
# scripts/data/team_data.gd
# resources 替換：
var resources: Dictionary = {
    "food": 0.0, "material": 0, "coin": 0, "goods": 0, "gem": 0,
    "ore_gold": 0, "ore_silver": 0, "ore_iron": 0, "ore_steel": 0,
    "weapon_melee_low": 0, "weapon_melee_high": 0,
    "weapon_ranged_low": 0, "weapon_ranged_high": 0,
}

# 在 wounded 之後、parent_team_id 之前加：
var equip_order: Dictionary = {
    "melee_low": 0, "melee_high": 0,
    "ranged_low": 0, "ranged_high": 0,
}
var armed_anon_ratio: float = 0.0
```

- [ ] **Step 3：執行 headless import 確認無語法錯誤**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --import
```

預期：無 SCRIPT ERROR。

- [ ] **Step 4：Commit**

```powershell
git add scripts/data/person_data.gd scripts/data/team_data.gd
git commit -m "feat(data): add equipment slot to PersonData, replace weapon with 4 types in TeamData"
```

---

## Task 2：WorldGenerator 加 ore_iron

**Files:**
- Modify: `scripts/simulation/world_generator.gd`

- [ ] **Step 1：加常數和 ore_iron 生成邏輯**

在 `world_generator.gd` 現有常數之後加：

```gdscript
const ORE_IRON_MOUNTAIN_CHANCE: float = 0.30
const ORE_IRON_PLAINS_CHANCE: float   = 0.05
```

在 `_apply_resources` 函數的 `if tile.terrain == "mountain":` 區塊末尾（`tile.resource_cap = ...` 之前）加：

```gdscript
    # ore_iron：mountain 主要，plains 少量（Task 2 新增）
    if tile.terrain == "mountain":
        if rng.randf() < ORE_IRON_MOUNTAIN_CHANCE:
            tile.resources["ore_iron"] = rng.randi_range(50, 150)
    elif tile.terrain == "plains":
        if rng.randf() < ORE_IRON_PLAINS_CHANCE:
            tile.resources["ore_iron"] = rng.randi_range(20, 60)
```

- [ ] **Step 2：確認 resource_system 能收集 ore_iron**

`resource_system.gd` 的 `_collect_from_tile` 用 `for res in src_tile.resources.keys()` 迭代，ore_iron 自動包含。確認 `REGEN_RATE` 不包含 ore_iron（它不再生，與 ore_gold 同邏輯）。

開啟 `scripts/simulation/resource_system.gd`，確認 `REGEN_RATE` dict 只有 `food` 和 `material`（不含 ore_iron）。若已正確則無需修改。

- [ ] **Step 3：import 確認**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --import
```

預期：無 SCRIPT ERROR。

- [ ] **Step 4：Commit**

```powershell
git add scripts/simulation/world_generator.gd
git commit -m "feat(world): add ore_iron spawning (mountain 30%, plains 5%)"
```

---

## Task 3：ManufacturingSystem 新配方

**Files:**
- Modify: `scripts/simulation/manufacturing_system.gd`

- [ ] **Step 1：更新常數**

移除舊的 `WEAPON_RATE`，加新常數：

```gdscript
# scripts/simulation/manufacturing_system.gd 頂部常數區（替換 WEAPON_RATE）：
const GOODS_RATE:         float = 0.10
const CRAFT_RATE:         float = 0.20
const SMELT_RATE:         float = 0.50   # TEST VALUE
const MELEE_LOW_RATE:     float = 0.05   # TEST VALUE
const RANGED_LOW_RATE:    float = 0.04   # TEST VALUE
const MELEE_HIGH_RATE:    float = 0.03   # TEST VALUE
const RANGED_HIGH_RATE:   float = 0.025  # TEST VALUE
const SKILL_GROWTH: float = 0.003
```

- [ ] **Step 2：重寫 `_run_recipes`**

完整替換 `_run_recipes` 函數（移除舊武器配方，加 5 種新配方）：

```gdscript
func _run_recipes(team: TeamData, worker_rate: float) -> String:
    var mat: float   = float(team.resources.get("material", 0))
    var gem: float   = float(team.resources.get("gem", 0))
    var iron: float  = float(team.resources.get("ore_iron", 0))
    var steel: float = float(team.resources.get("ore_steel", 0))

    # 工藝品優先（有 gem）
    if gem >= 1.0 and mat >= 4.0:
        team.resources["gem"]      = gem - 1.0
        team.resources["material"] = mat - 4.0
        team.resources["goods"]    = float(team.resources.get("goods", 0)) + worker_rate * CRAFT_RATE
        return "工藝品"

    # 高階近戰武器（steel）
    if steel >= 2.0 and mat >= 3.0:
        team.resources["ore_steel"] = steel - 2.0
        team.resources["material"]  = mat - 3.0
        team.resources["weapon_melee_high"] = float(team.resources.get("weapon_melee_high", 0)) \
            + worker_rate * MELEE_HIGH_RATE
        return "高階近戰武器"

    # 高階遠程武器（steel）
    if steel >= 2.0 and mat >= 4.0:
        team.resources["ore_steel"] = steel - 2.0
        team.resources["material"]  = mat - 4.0
        team.resources["weapon_ranged_high"] = float(team.resources.get("weapon_ranged_high", 0)) \
            + worker_rate * RANGED_HIGH_RATE
        return "高階遠程武器"

    # 冶煉（iron → steel）
    if iron >= 2.0 and mat >= 1.0:
        team.resources["ore_iron"]  = iron - 2.0
        team.resources["material"]  = mat - 1.0
        team.resources["ore_steel"] = float(team.resources.get("ore_steel", 0)) \
            + worker_rate * SMELT_RATE
        return "冶煉"

    # 低階近戰武器（iron）
    if iron >= 2.0 and mat >= 3.0:
        team.resources["ore_iron"]  = iron - 2.0
        team.resources["material"]  = mat - 3.0
        team.resources["weapon_melee_low"] = float(team.resources.get("weapon_melee_low", 0)) \
            + worker_rate * MELEE_LOW_RATE
        return "低階近戰武器"

    # 低階遠程武器（iron）
    if iron >= 2.0 and mat >= 4.0:
        team.resources["ore_iron"]  = iron - 2.0
        team.resources["material"]  = mat - 4.0
        team.resources["weapon_ranged_low"] = float(team.resources.get("weapon_ranged_low", 0)) \
            + worker_rate * RANGED_LOW_RATE
        return "低階遠程武器"

    # 一般製造（無礦時 fallback）
    if mat >= 3.0:
        team.resources["material"] = mat - 3.0
        team.resources["goods"]    = float(team.resources.get("goods", 0)) + worker_rate * GOODS_RATE
        return "一般製造"

    return ""
```

- [ ] **Step 3：import 確認**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --import
```

預期：無 SCRIPT ERROR。

- [ ] **Step 4：Commit**

```powershell
git add scripts/simulation/manufacturing_system.gd
git commit -m "feat(manufacturing): add ore_iron/steel chain and 4 weapon type recipes"
```

---

## Task 4：EquipmentSystem（新建）

**Files:**
- Create: `scripts/simulation/equipment_system.gd`

- [ ] **Step 1：建立檔案**

```gdscript
# scripts/simulation/equipment_system.gd
class_name EquipmentSystem

const WEAPON_TYPES: Array = ["melee_low", "melee_high", "ranged_low", "ranged_high"]
const UNITS_PER_EQUIP: int = 2     # 每人裝備消耗 2 單位
const DEATH_RECOVERY_RATE: int = 2  # 死亡：每 2 人回收 1 人裝備（即 50%）

func tick_all(state: WorldState, team_ids: Array) -> void:
    for tid in team_ids:
        if not state.teams.has(tid):
            continue
        var team: TeamData = state.teams[tid]
        _update_equipment(state, team)
        _update_anon_ratio(state, team)

func _update_equipment(state: WorldState, team: TeamData) -> void:
    # 統計目前已裝備的各類型人數
    var equipped: Dictionary = { "melee_low": 0, "melee_high": 0, "ranged_low": 0, "ranged_high": 0 }
    var named_ids: Array = _get_named_ids(team)
    for pid in named_ids:
        var p: PersonData = state.persons.get(pid)
        if p == null:
            continue
        var wtype: String = p.equipment.get("weapon", "")
        if wtype in equipped:
            equipped[wtype] += 1

    # 對每種武器類型調整裝備
    for wtype in WEAPON_TYPES:
        var pool_key: String = "weapon_" + wtype
        var target: int = team.equip_order.get(wtype, 0)
        var current: int = equipped[wtype]
        var deficit: int = target - current

        if deficit > 0:
            # 裝備：從 pool 取出（每人 2 單位）
            var pool: int = int(team.resources.get(pool_key, 0))
            var can_equip: int = pool / UNITS_PER_EQUIP
            var to_equip: int = mini(deficit, can_equip)
            var equipped_count: int = 0
            for pid in named_ids:
                if equipped_count >= to_equip:
                    break
                var p: PersonData = state.persons.get(pid)
                if p == null:
                    continue
                if p.equipment.get("weapon", "") == "":
                    p.equipment["weapon"] = wtype
                    equipped_count += 1
            team.resources[pool_key] = pool - equipped_count * UNITS_PER_EQUIP
            if equipped_count > 0:
                print("[Equip] Team%d 裝備 %s ×%d" % [team.team_id, wtype, equipped_count])

        elif deficit < 0:
            # 卸裝：歸還 pool
            var to_unequip: int = -deficit
            var unequipped_count: int = 0
            for pid in named_ids:
                if unequipped_count >= to_unequip:
                    break
                var p: PersonData = state.persons.get(pid)
                if p == null:
                    continue
                if p.equipment.get("weapon", "") == wtype:
                    p.equipment["weapon"] = ""
                    unequipped_count += 1
            var pool: int = int(team.resources.get(pool_key, 0))
            team.resources[pool_key] = pool + unequipped_count * UNITS_PER_EQUIP

func _update_anon_ratio(state: WorldState, team: TeamData) -> void:
    var named_ids: Array = _get_named_ids(team)
    var named_count: int = named_ids.size()
    var anon_pop: int = maxi(team.population - named_count, 0)
    if anon_pop <= 0:
        team.armed_anon_ratio = 0.0
        return
    # 已在 equip_order 登記的武器給 named NPC；剩餘給匿名人口
    var pool_remaining: int = 0
    for wtype in WEAPON_TYPES:
        var pool_key: String = "weapon_" + wtype
        pool_remaining += int(team.resources.get(pool_key, 0))
    var armed_anon: int = mini(anon_pop, pool_remaining / UNITS_PER_EQUIP)
    team.armed_anon_ratio = float(armed_anon) / float(anon_pop)

# 記名 NPC 死亡時呼叫（從 interaction_system._kill_named_npc 呼叫）
func on_named_death(team: TeamData, wtype: String) -> void:
    if wtype == "":
        return
    # 50% 回收（整除，不出現小數）
    # 2 單位 × 50% = 1 單位回收（每人固定）
    var pool_key: String = "weapon_" + wtype
    team.resources[pool_key] = int(team.resources.get(pool_key, 0)) + 1  # 50% of 2 units = 1

# 匿名人口傷亡時呼叫（從 interaction_system._apply_casualties 呼叫）
func on_anon_casualties(team: TeamData, anon_casualties: int) -> void:
    var armed_dead: int = int(float(anon_casualties) * team.armed_anon_ratio)
    var recovered_persons: int = armed_dead / 2   # 50% 整除
    var recovered_units: int   = recovered_persons * UNITS_PER_EQUIP
    if recovered_units <= 0:
        return
    var pool_total: int = _weapon_pool_total(team)
    if pool_total <= 0:
        return
    for wtype in WEAPON_TYPES:
        var pool_key: String = "weapon_" + wtype
        var cur: int = int(team.resources.get(pool_key, 0))
        if cur <= 0:
            continue
        var share: int = cur * recovered_units / pool_total
        team.resources[pool_key] = cur + share

func _weapon_pool_total(team: TeamData) -> int:
    var total: int = 0
    for wtype in WEAPON_TYPES:
        total += int(team.resources.get("weapon_" + wtype, 0))
    return total

func _get_named_ids(team: TeamData) -> Array:
    var ids: Array = team.advisors + team.members
    if team.leader_id != -1:
        ids.append(team.leader_id)
    return ids
```

- [ ] **Step 2：import 確認**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --import
```

預期：無 SCRIPT ERROR，`class_name EquipmentSystem` 被識別。

- [ ] **Step 3：Commit**

```powershell
git add scripts/simulation/equipment_system.gd
git commit -m "feat(equipment): add EquipmentSystem with tick equip/unequip and death recovery"
```

---

## Task 5：SimRunner 整合 EquipmentSystem

**Files:**
- Modify: `scripts/simulation/sim_runner.gd`

- [ ] **Step 1：加 member 和 init**

在 `var _vision_system: VisionSystem` 下方加：

```gdscript
var _equipment_system: EquipmentSystem
```

在 `_init()` 的 `_vision_system = VisionSystem.new()` 下方加：

```gdscript
_equipment_system = EquipmentSystem.new()
```

- [ ] **Step 2：加步驟呼叫**

在 `advance_tick` 近區區塊中，`_step1b_update_vision(state, near_teams)` 之後、`var arrived_near := _step2_move_teams(...)` 之前加：

```gdscript
_step1c_update_equipment(state, near_teams)
```

在遠區 `if state.world.current_tick % FAR_ZONE_INTERVAL == 0:` 區塊中，`_step1b_update_vision(state, far_teams)` 之後加：

```gdscript
_step1c_update_equipment(state, far_teams)
```

加新函數：

```gdscript
func _step1c_update_equipment(state: WorldState, team_ids: Array) -> void:
    _equipment_system.tick_all(state, team_ids)
```

- [ ] **Step 3：import + 初跑確認**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --import
```

預期：無 SCRIPT ERROR。

- [ ] **Step 4：Commit**

```powershell
git add scripts/simulation/sim_runner.gd
git commit -m "feat(runner): integrate EquipmentSystem into tick loop (step1c)"
```

---

## Task 6：InteractionSystem — 戰力公式 + Round 0

**Files:**
- Modify: `scripts/simulation/interaction_system.gd`

- [ ] **Step 1：加新常數**

在常數區（`READINESS_FOOD_COST` 之後）加：

```gdscript
const VOLLEY_CASUALTY_RATE: float = 0.05   # TEST VALUE
const PURSUIT_RATE: float         = 0.05   # TEST VALUE
const FLANKING_MULT: float        = 1.3    # TEST VALUE
const MORALE_CASCADE_THRESHOLD: float = 0.3  # TEST VALUE
```

- [ ] **Step 2：加 EquipmentSystem member**

在 `var _vision: VisionSystem` 下方加：

```gdscript
var _equip: EquipmentSystem
```

在 `_init()` 中加：

```gdscript
_equip = EquipmentSystem.new()
```

- [ ] **Step 3：更新 TRADEABLE_RES 和 BASE_PRICE**

把舊的 `"weapon": 15.0` 從 `BASE_PRICE` 移除，加：

```gdscript
# BASE_PRICE 新增（在 "ore_silver" 之後）：
"ore_iron":          8.0,
"ore_steel":        12.0,
"weapon_melee_low":  8.0,
"weapon_melee_high": 18.0,
"weapon_ranged_low": 9.0,
"weapon_ranged_high": 20.0,
```

`TARGET_PER_POP` 移除 `"weapon": 2.0`，加：

```gdscript
"ore_iron":           3.0,
"ore_steel":          1.5,
"weapon_melee_low":   1.0,
"weapon_melee_high":  0.5,
"weapon_ranged_low":  0.8,
"weapon_ranged_high": 0.4,
```

- [ ] **Step 4：加地形防禦 helper**

在 `_strength_raw` 之前加：

```gdscript
func _terrain_defense_mult(state: WorldState, team: TeamData) -> float:
    var tile_id: int = team.tile_pos.x * 1000 + team.tile_pos.y
    var tile: HexTileData = state.world.tiles.get(tile_id)
    if tile == null:
        return 1.0
    match tile.terrain:
        "forest":   return 1.2
        "mountain": return 1.15
    return 1.0
```

- [ ] **Step 5：重寫 `_strength_raw`**

完整替換現有 `_strength_raw` 函數：

```gdscript
func _strength_raw(state: WorldState, team_id: int) -> float:
    var team: TeamData = state.teams.get(team_id)
    if team == null:
        return 0.0
    var leader: PersonData = state.persons.get(team.leader_id)

    # 統領加成（現有）
    var cmd: float = float(leader.skills.get("統領", 0.0)) if leader else 0.0
    var excess: float = clampf((cmd - 0.8) / 0.2, 0.0, 1.0)
    var leadership_mult: float = 1.0 + excess * 0.5

    # 戰術加成（新）
    var tactics: float = float(leader.skills.get("戰術", 0.0)) if leader else 0.0
    var tactics_mult: float = 1.0 + tactics * 0.3   # TEST VALUE

    # 記名 NPC 統計（melee_str / ranged_str）
    var melee_str:  float = 0.0
    var ranged_str: float = 0.0
    var named_ids: Array = ([team.leader_id] as Array) + team.advisors + team.members
    for pid in named_ids:
        var p: PersonData = state.persons.get(pid)
        if p == null:
            continue
        var wtype: String = p.equipment.get("weapon", "")
        match wtype:
            "melee_low":
                melee_str  += (0.5 + float(p.skills.get("戰鬥", 0.0)) * 0.5) * 0.8
            "melee_high":
                melee_str  += (0.5 + float(p.skills.get("戰鬥", 0.0)) * 0.5) * 1.2
            "ranged_low":
                ranged_str += (0.5 + float(p.skills.get("弓箭", 0.0)) * 0.5) * 0.8
            "ranged_high":
                ranged_str += (0.5 + float(p.skills.get("弓箭", 0.0)) * 0.5) * 1.2
            _:
                melee_str  += 0.3   # 徒手基礎值

    # 匿名人口（使用 armed_anon_ratio）
    var named_count: int = named_ids.size()
    var anon_pop: int    = maxi(team.population - team.wounded - named_count, 0)
    melee_str += float(anon_pop) * team.armed_anon_ratio * 0.5

    return (melee_str + ranged_str) * leadership_mult * tactics_mult
```

- [ ] **Step 6：加 `_ranged_strength` helper**

（供 Round 0 使用，只計算 ranged 部分）

```gdscript
func _ranged_strength(state: WorldState, team_id: int) -> float:
    var team: TeamData = state.teams.get(team_id)
    if team == null:
        return 0.0
    var ranged_str: float = 0.0
    var named_ids: Array = ([team.leader_id] as Array) + team.advisors + team.members
    for pid in named_ids:
        var p: PersonData = state.persons.get(pid)
        if p == null:
            continue
        match p.equipment.get("weapon", ""):
            "ranged_low":
                ranged_str += (0.5 + float(p.skills.get("弓箭", 0.0)) * 0.5) * 0.8
            "ranged_high":
                ranged_str += (0.5 + float(p.skills.get("弓箭", 0.0)) * 0.5) * 1.2
    return ranged_str
```

- [ ] **Step 7：加 `_resolve_volley`（Round 0）**

在 `_resolve_combat_round` 之前加：

```gdscript
func _resolve_volley(state: WorldState, id_a: int, id_b: int) -> void:
    var volley_a: float = _ranged_strength(state, id_a)
    var volley_b: float = _ranged_strength(state, id_b)
    var total: float = volley_a + volley_b
    if total <= 0.0:
        return
    var a: TeamData = state.teams[id_a]
    var b: TeamData = state.teams[id_b]
    var eff_a: int  = maxi(a.population - a.wounded, 1)
    var eff_b: int  = maxi(b.population - b.wounded, 1)
    var loss_a: int = maxi(int(float(eff_a) * volley_b / total * VOLLEY_CASUALTY_RATE), 0)
    var loss_b: int = maxi(int(float(eff_b) * volley_a / total * VOLLEY_CASUALTY_RATE), 0)
    _apply_casualties(state, id_a, loss_a)
    _apply_casualties(state, id_b, loss_b)
    print("[Volley] Team%d→%d  Team%d→%d" % [id_a, loss_a, id_b, loss_b])
```

- [ ] **Step 8：在 `_start_combat` 中加入 Round 0**

找到 `_start_combat` 末尾的 `print("[Combat Start] ...")` 之後，插入：

```gdscript
    _resolve_volley(state, atk_id, def_id)
```

- [ ] **Step 9：import 確認**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --import
```

預期：無 SCRIPT ERROR。

- [ ] **Step 10：Commit**

```powershell
git add scripts/simulation/interaction_system.gd
git commit -m "feat(combat): rewrite _strength_raw with 4 weapon types, add Round 0 volley"
```

---

## Task 7：InteractionSystem — 地形、包圍、士氣、追擊、Loot

**Files:**
- Modify: `scripts/simulation/interaction_system.gd`

- [ ] **Step 1：更新 `_resolve_combat_round` — 加地形 + 包圍 + 士氣崩潰**

完整替換 `_resolve_combat_round`：

```gdscript
func _resolve_combat_round(state: WorldState, id_a: int, id_b: int) -> void:
    var a: TeamData  = state.teams[id_a]
    var b: TeamData  = state.teams[id_b]

    # 地形防禦（防守方加成）
    # id_a 是攻方（combat_target 指向 id_b），id_b 是守方
    var terrain_b: float = _terrain_defense_mult(state, b)
    var terrain_a: float = _terrain_defense_mult(state, a)

    var str_a: float = _team_strength(state, id_a) * a.readiness
    var str_b: float = _team_strength(state, id_b) * b.readiness * terrain_b
    var total: float = str_a + str_b
    var eff_a: int   = maxi(a.population - a.wounded, 1)
    var eff_b: int   = maxi(b.population - b.wounded, 1)

    var loss_a: int = max(int(round(eff_a * str_b / total * ROUND_CASUALTY_RATE)), 0)
    var loss_b: int = max(int(round(eff_b * str_a / total * ROUND_CASUALTY_RATE)), 0)

    # 數量包圍（攻方人數 ≥ 3× 守方）
    if eff_a >= eff_b * 3:
        var tactics_b: float = 0.0
        var leader_b: PersonData = state.persons.get(b.leader_id)
        if leader_b != null:
            tactics_b = float(leader_b.skills.get("戰術", 0.0))
        var flank_mult: float = FLANKING_MULT - tactics_b * 0.3
        loss_b = int(round(float(loss_b) * flank_mult))
    if eff_b >= eff_a * 3:
        var tactics_a: float = 0.0
        var leader_a: PersonData = state.persons.get(a.leader_id)
        if leader_a != null:
            tactics_a = float(leader_a.skills.get("戰術", 0.0))
        var flank_mult: float = FLANKING_MULT - tactics_a * 0.3
        loss_a = int(round(float(loss_a) * flank_mult))

    _apply_casualties(state, id_a, loss_a)
    _apply_casualties(state, id_b, loss_b)

    # 士氣崩潰：傷亡比例 > 30% → readiness 掉速 ×2
    var wnd_ratio_a: float = float(a.wounded) / float(maxi(a.population, 1))
    var wnd_ratio_b: float = float(b.wounded) / float(maxi(b.population, 1))
    var drain_a: float = ROUND_READINESS_DRAIN * (2.0 if wnd_ratio_a > MORALE_CASCADE_THRESHOLD else 1.0)
    var drain_b: float = ROUND_READINESS_DRAIN * (2.0 if wnd_ratio_b > MORALE_CASCADE_THRESHOLD else 1.0)
    a.readiness = maxf(a.readiness - drain_a, 0.0)
    b.readiness = maxf(b.readiness - drain_b, 0.0)

    print("[Round] Team%d(rd=%.2f,terrain=%.2f) vs Team%d(rd=%.2f,terrain=%.2f)  wnd+%d/%d  eff=%d/%d" % [
        id_a, a.readiness, terrain_a, id_b, b.readiness, terrain_b, loss_a, loss_b,
        maxi(a.population - a.wounded, 1), maxi(b.population - b.wounded, 1)])

    if maxi(a.population - a.wounded, 1) <= 1:
        _end_combat(state, id_b, id_a)
        return
    if maxi(b.population - b.wounded, 1) <= 1:
        _end_combat(state, id_a, id_b)
        return
    if a.readiness <= COMBAT_ABANDON_THRESHOLD:
        _force_retreat(state, id_a, id_b)
        return
    if b.readiness <= COMBAT_ABANDON_THRESHOLD:
        _force_retreat(state, id_b, id_a)
        return
    _try_retreat(state, id_a, id_b)
    if a.combat_target != -1:
        _try_retreat(state, id_b, id_a)
```

- [ ] **Step 2：更新 loot list 在 `_end_combat`**

找到：
```gdscript
    for res in ["food", "material", "weapon", "coin", "goods"]:
```
替換為：
```gdscript
    for res in ["food", "material", "coin", "goods",
                "weapon_melee_low", "weapon_melee_high",
                "weapon_ranged_low", "weapon_ranged_high"]:
```

- [ ] **Step 3：加追擊邏輯**

在 `_end_combat` 的 `_try_subjugate(...)` 之前加：

```gdscript
    _apply_pursuit(state, winner_id, loser_id)
```

在 `_force_retreat` 函數末尾加：

```gdscript
    _apply_pursuit(state, pursuer_id, retreater_id)
```

加新函數 `_apply_pursuit`（放在 `_force_retreat` 之後）：

```gdscript
func _apply_pursuit(state: WorldState, winner_id: int, loser_id: int) -> void:
    if not state.teams.has(winner_id) or not state.teams.has(loser_id):
        return
    var winner: TeamData = state.teams[winner_id]
    var loser:  TeamData = state.teams[loser_id]
    if winner.population < loser.population * 2:
        return
    var pursuit_loss: int = maxi(int(float(loser.population) * PURSUIT_RATE), 0)
    if pursuit_loss <= 0:
        return
    _apply_casualties(state, loser_id, pursuit_loss)
    print("[Pursuit] Team%d 追擊 Team%d +%d傷亡" % [winner_id, loser_id, pursuit_loss])
```

- [ ] **Step 4：在 `_apply_casualties` 加匿名人口武器回收**

找到 `_apply_casualties` 函數，在 `for i in range(count):` 迴圈結束後加：

```gdscript
    # 匿名人口死亡武器回收
    var anon_total: int = count  # 簡化：全部視為匿名（named 比例低，影響小）
    _equip.on_anon_casualties(team, anon_total)
```

- [ ] **Step 5：在 `_kill_named_npc` 加記名死亡武器回收**

找到 `_kill_named_npc` 函數，在 `state.persons.erase(p.id)` 之前加：

```gdscript
    # 記名 NPC 死亡武器回收（50%）
    _equip.on_named_death(team, p.equipment.get("weapon", ""))
    p.equipment["weapon"] = ""
```

- [ ] **Step 6：import + headless 初跑**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --import
```

預期：無 SCRIPT ERROR。

- [ ] **Step 7：Commit**

```powershell
git add scripts/simulation/interaction_system.gd
git commit -m "feat(combat): add terrain defense, flanking, morale cascade, pursuit, 4-type loot"
```

---

## Task 8：SkillSystem — 戰鬥技能成長

**Files:**
- Modify: `scripts/simulation/skill_system.gd`
- Modify: `scripts/simulation/interaction_system.gd`（呼叫 hook）

- [ ] **Step 1：在 `skill_system.gd` 加兩個方法**

在 `on_reaction` 之後加：

```gdscript
# 每個戰鬥回合呼叫：melee 武裝者成長戰鬥，ranged 武裝者成長弓箭
func on_combat_round(state: WorldState, team: TeamData) -> void:
    var named_ids: Array = ([team.leader_id] as Array) + team.advisors + team.members
    for pid in named_ids:
        var p: PersonData = state.persons.get(pid)
        if p == null:
            continue
        var wtype: String = p.equipment.get("weapon", "")
        if wtype in ["melee_low", "melee_high"]:
            _grow(p, "戰鬥", "體力")
        elif wtype in ["ranged_low", "ranged_high"]:
            _grow(p, "弓箭", "智力")

# 戰鬥結束時呼叫：leader 成長戰術
func on_combat_end(state: WorldState, team: TeamData) -> void:
    var leader: PersonData = state.persons.get(team.leader_id)
    if leader == null:
        return
    _grow(leader, "戰術", "智力")

func _grow(p: PersonData, skill: String, attr: String) -> void:
    var attr_val: float  = float(p.attributes.get(attr, 0.5)) * p.get_attribute_mult(attr)
    var endurance: float = float(p.attributes.get("毅力", 0.5)) * p.get_attribute_mult("毅力")
    var growth: float    = BASE_GROWTH * attr_val * (0.5 + endurance * 0.5) * p.get_skill_mult(skill)
    p.skills[skill] = minf(float(p.skills.get(skill, 0.0)) + growth, MAX_SKILL)
```

- [ ] **Step 2：在 `interaction_system.gd` 加 `_skill_sys` member**

在 `var _equip: EquipmentSystem` 下方加：

```gdscript
var _skill_sys: SkillSystem
```

在 `_init()` 中加：

```gdscript
_skill_sys = SkillSystem.new()
```

- [ ] **Step 3：在 `_resolve_combat_round` 末尾（print 之後）加技能成長呼叫**

在 `_resolve_combat_round` 的最後一行 `_try_retreat(...)` 之前插入：

```gdscript
    _skill_sys.on_combat_round(state, a)
    _skill_sys.on_combat_round(state, b)
```

- [ ] **Step 4：在 `_end_combat` 和 `_force_retreat` 加戰術成長**

在 `_end_combat` 中 `_apply_pursuit(...)` 之前插入：

```gdscript
    _skill_sys.on_combat_end(state, winner)
    _skill_sys.on_combat_end(state, loser)
```

在 `_force_retreat` 中 `_apply_pursuit(...)` 之前插入：

```gdscript
    _skill_sys.on_combat_end(state, retreater)
    _skill_sys.on_combat_end(state, pursuer)
```

- [ ] **Step 5：import 確認**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --import
```

預期：無 SCRIPT ERROR。

- [ ] **Step 6：Commit**

```powershell
git add scripts/simulation/skill_system.gd scripts/simulation/interaction_system.gd
git commit -m "feat(skill): add on_combat_round/on_combat_end for 戰鬥/弓箭/戰術 growth"
```

---

## Task 9：FactionAI 裝備決策 + TRADEABLE_RES

**Files:**
- Modify: `scripts/simulation/faction_ai_system.gd`

- [ ] **Step 1：更新 TRADEABLE_RES**

找到：
```gdscript
const TRADEABLE_RES: Array = ["food", "material", "goods", "weapon", "gem", "ore_gold", "ore_silver"]
```
替換為：
```gdscript
const TRADEABLE_RES: Array = [
    "food", "material", "goods", "gem",
    "ore_gold", "ore_silver", "ore_iron", "ore_steel",
    "weapon_melee_low", "weapon_melee_high",
    "weapon_ranged_low", "weapon_ranged_high",
]
```

- [ ] **Step 2：加 `_update_equip_order` 函數**

在 `_evaluate_solo` 之後加：

```gdscript
func _update_equip_order(state: WorldState, team: TeamData) -> void:
    var total_weapons: int = 0
    for wtype in ["melee_low", "melee_high", "ranged_low", "ranged_high"]:
        total_weapons += int(team.resources.get("weapon_" + wtype, 0))
    if total_weapons <= 0:
        return
    # 重置 equip_order
    team.equip_order = { "melee_low": 0, "melee_high": 0, "ranged_low": 0, "ranged_high": 0 }

    var can_equip: int = total_weapons / 2   # 每人 2 單位
    if team.tags.has(TeamData.TAG_MILITARY) or team.current_task == TeamData.TASK_LOOT \
            or team.current_task == TeamData.TASK_ATTACK:
        # 軍隊/掠奪：優先裝備高階近戰，其次遠程
        var pool_mh: int = int(team.resources.get("weapon_melee_high", 0)) / 2
        var pool_rh: int = int(team.resources.get("weapon_ranged_high", 0)) / 2
        var pool_ml: int = int(team.resources.get("weapon_melee_low", 0)) / 2
        var pool_rl: int = int(team.resources.get("weapon_ranged_low", 0)) / 2
        team.equip_order["melee_high"]  = mini(pool_mh, can_equip)
        can_equip -= team.equip_order["melee_high"]
        team.equip_order["ranged_high"] = mini(pool_rh, can_equip)
        can_equip -= team.equip_order["ranged_high"]
        team.equip_order["melee_low"]   = mini(pool_ml, can_equip)
        can_equip -= team.equip_order["melee_low"]
        team.equip_order["ranged_low"]  = mini(pool_rl, can_equip)
    elif team.tags.has(TeamData.TAG_MERCHANT):
        # 商隊：最多裝備 30% 人口的 melee_low 自衛
        var guard_count: int = mini(team.population * 3 / 10, can_equip)
        team.equip_order["melee_low"] = mini(int(team.resources.get("weapon_melee_low", 0)) / 2, guard_count)
    else:
        # 一般：50% 人口 melee_low
        var guard_count: int = mini(team.population / 2, can_equip)
        team.equip_order["melee_low"] = mini(int(team.resources.get("weapon_melee_low", 0)) / 2, guard_count)
```

- [ ] **Step 3：在 `evaluate_all` 中呼叫 `_update_equip_order`**

在 `evaluate_all` 的 `for tid in state.teams:` 迴圈（`_evaluate_subteam` / `_evaluate_solo` 那段）之後加：

```gdscript
    # 更新各 team 裝備配置
    for tid in state.teams:
        if not state.teams.has(tid):
            continue
        _update_equip_order(state, state.teams[tid])
```

- [ ] **Step 4：import 確認**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --import
```

預期：無 SCRIPT ERROR。

- [ ] **Step 5：Commit**

```powershell
git add scripts/simulation/faction_ai_system.gd
git commit -m "feat(ai): add _update_equip_order and update TRADEABLE_RES for weapon types"
```

---

## Task 10：修復依賴檔案

**Files:**
- Modify: `scripts/simulation/events/event_unrest_split.gd`

- [ ] **Step 1：更新 `event_unrest_split.gd` 資源 dict**

找到：
```gdscript
    new_team.resources = { "food": 0.0, "material": 0, "weapon": 0, "coin": 0, "goods": 0 }
```
替換為：
```gdscript
    new_team.resources = {
        "food": 0.0, "material": 0, "coin": 0, "goods": 0, "gem": 0,
        "ore_gold": 0, "ore_silver": 0, "ore_iron": 0, "ore_steel": 0,
        "weapon_melee_low": 0, "weapon_melee_high": 0,
        "weapon_ranged_low": 0, "weapon_ranged_high": 0,
    }
```

- [ ] **Step 2：import 確認**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --import
```

預期：無 SCRIPT ERROR。

- [ ] **Step 3：Commit**

```powershell
git add scripts/simulation/events/event_unrest_split.gd
git commit -m "fix(event): update split team resources dict to include 4 weapon types"
```

---

## Task 11：headless_test.gd 全面更新 + 驗證

**Files:**
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1：替換所有 `"weapon"` key**

全文搜尋 `"weapon":`，替換每處舊 resources dict 為新格式。

每個 team 的 `team.resources = { ... }` 都需要更新。格式：

```gdscript
# Team0, 1, 2（原本 weapon=5/20）
team.resources = {
    "food": 500.0, "material": _mat, "coin": 20, "goods": 0, "gem": 0,
    "ore_gold": 0, "ore_silver": 0, "ore_iron": 0, "ore_steel": 0,
    "weapon_melee_low": 0, "weapon_melee_high": 0,
    "weapon_ranged_low": 0, "weapon_ranged_high": 0,
}
# Team0 額外：weapon_melee_low = 40（原 weapon=20，×2 單位）
state.teams[0].resources["weapon_melee_low"] = 40

# Team3
team3.resources = {
    "food": 200.0, "material": 5, "coin": 30, "goods": 10, "gem": 0,
    "ore_gold": 0, "ore_silver": 0, "ore_iron": 0, "ore_steel": 0,
    "weapon_melee_low": 4, "weapon_melee_high": 0,
    "weapon_ranged_low": 0, "weapon_ranged_high": 0,
}

# Team5（軍隊，原 weapon=8）
team5.resources = {
    "food": 300.0, "material": 5, "coin": 0, "goods": 0, "gem": 0,
    "ore_gold": 0, "ore_silver": 0, "ore_iron": 0, "ore_steel": 0,
    "weapon_melee_low": 16, "weapon_melee_high": 0,   # 原 8 × 2 單位
    "weapon_ranged_low": 0, "weapon_ranged_high": 0,
}

# Team6（商隊，原 weapon=1）
team6.resources = {
    "food": 200.0, "material": 3, "coin": 50, "goods": 20, "gem": 0,
    "ore_gold": 0, "ore_silver": 0, "ore_iron": 0, "ore_steel": 0,
    "weapon_melee_low": 2, "weapon_melee_high": 0,   # 原 1 × 2
    "weapon_ranged_low": 0, "weapon_ranged_high": 0,
}

# Team8（製造，原 weapon=0）
team8.resources = {
    "food": 500.0, "material": 500.0, "coin": 0, "goods": 0, "gem": 5,
    "ore_silver": 100, "ore_gold": 0, "ore_iron": 80, "ore_steel": 0,   # 加 ore_iron 測試製造
    "weapon_melee_low": 0, "weapon_melee_high": 0,
    "weapon_ranged_low": 0, "weapon_ranged_high": 0,
}

# Team9（商隊，原 weapon=0）
team9.resources = {
    "food": 300.0, "material": 0, "coin": 0, "goods": 100.0, "gem": 3,
    "ore_silver": 0, "ore_gold": 0, "ore_iron": 0, "ore_steel": 0,
    "weapon_melee_low": 0, "weapon_melee_high": 0,
    "weapon_ranged_low": 0, "weapon_ranged_high": 0,
}
```

- [ ] **Step 2：更新 Team8 製造測試輸出**

找到：
```gdscript
    print("  goods=%.2f  weapon=%.2f  material=%.1f  gem=%.0f  ore_silver=%.0f" % [
        float(t8.resources.get("goods", 0)),
        float(t8.resources.get("weapon", 0)),
```
替換為：
```gdscript
    print("  goods=%.2f  melee_low=%.2f  melee_high=%.2f  steel=%.2f  material=%.1f" % [
        float(t8.resources.get("goods", 0)),
        float(t8.resources.get("weapon_melee_low", 0)),
        float(t8.resources.get("weapon_melee_high", 0)),
        float(t8.resources.get("ore_steel", 0)),
        float(t8.resources.get("material", 0))
    ])
```

- [ ] **Step 3：加武器裝備統計輸出**

在 200 Tick 後的輸出區加：

```gdscript
    print("\n--- 裝備統計 ---")
    for tid in state.teams:
        var t: TeamData = state.teams[tid]
        var equip_counts: Dictionary = { "melee_low": 0, "melee_high": 0, "ranged_low": 0, "ranged_high": 0, "none": 0 }
        for pid in ([t.leader_id] as Array) + t.advisors + t.members:
            var p: PersonData = state.persons.get(pid)
            if p == null: continue
            var wt: String = p.equipment.get("weapon", "")
            if wt in equip_counts: equip_counts[wt] += 1
            else: equip_counts["none"] += 1
        print("  Team%d pool_ml=%d mh=%d rl=%d rh=%d | armed_anon=%.2f | named:%s" % [
            tid,
            int(t.resources.get("weapon_melee_low", 0)),
            int(t.resources.get("weapon_melee_high", 0)),
            int(t.resources.get("weapon_ranged_low", 0)),
            int(t.resources.get("weapon_ranged_high", 0)),
            t.armed_anon_ratio,
            str(equip_counts)
        ])
    print("--- 戰鬥技能 ---")
    for pid in state.persons:
        var p: PersonData = state.persons.get(pid)
        if p == null: continue
        var bat: float = float(p.skills.get("戰鬥", 0))
        var bow: float = float(p.skills.get("弓箭", 0))
        var tac: float = float(p.skills.get("戰術", 0))
        if bat > 0.001 or bow > 0.001 or tac > 0.001:
            print("  Person%d 戰鬥=%.4f 弓箭=%.4f 戰術=%.4f" % [p.id, bat, bow, tac])
```

- [ ] **Step 4：完整執行驗證**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --import
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd 2>&1 | Select-String -Pattern "ERROR|DONE|Equip|Volley|Pursuit|製造|--- 裝備"
```

預期：
- 無 `SCRIPT ERROR`
- `=== DONE ===`
- `[Equip]` 出現（Team0/Team5 裝備 melee_low）
- `[Volley]` 出現（有 ranged 才出現，初始沒有 ranged，Team8 製造後才有）
- `[Manufacture] Team8 冶煉/低階近戰武器` 出現
- `--- 裝備統計 ---` 各 team 顯示
- 戰鬥後 Person 戰鬥/戰術技能 > 0

- [ ] **Step 5：Commit**

```powershell
git add scripts/debug/headless_test.gd
git commit -m "test: update headless_test for 4 weapon types, add equipment/combat skill stats output"
```

---

## Self-Review

**Spec coverage check:**
- ✅ PersonData equipment 欄位（Task 1）
- ✅ TeamData 4 武器 key + equip_order + armed_anon_ratio（Task 1）
- ✅ ore_iron 世界生成（Task 2）
- ✅ ore_steel 只能製造，5 種新配方（Task 3）
- ✅ EquipmentSystem tick 裝備結算，2 單位/人（Task 4）
- ✅ 死亡回收：記名 50%（1 單位），匿名比例回收（Task 4 + Task 7）
- ✅ SimRunner 整合（Task 5）
- ✅ 戰力公式重寫（Task 6）
- ✅ Round 0 齊射（Task 6）
- ✅ 地形防禦（Task 7）
- ✅ 數量包圍（Task 7）
- ✅ 士氣崩潰（Task 7）
- ✅ 追擊（Task 7）
- ✅ Loot 更新（Task 7）
- ✅ 弓箭/戰鬥/戰術技能成長（Task 8）
- ✅ FactionAI equip_order 決策（Task 9）
- ✅ TRADEABLE_RES 更新（Task 9）
- ✅ event_unrest_split.gd 修復（Task 10）
- ✅ headless_test 全面更新（Task 11）
