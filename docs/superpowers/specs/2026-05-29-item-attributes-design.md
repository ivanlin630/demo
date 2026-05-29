# 物品屬性 Design

## 依賴

無上游依賴。以下系統查詢此 spec（不逆向依賴）：
- `player-system-design.md`（背包重量）
- `encounter-system-design.md`（箭矢消耗）
- `encounter-combat-design.md`（傷害/格擋/架擋）
- `health-system-design.md`（receive_damage 前的傷害計算）

---

## Goal

集中定義所有物品的戰鬥與功能屬性。**健康系統、遭遇戰系統只查詢此處，不自行定義數值。**

---

## 1. 武器屬性

```gdscript
# scripts/data/item_attributes.gd
class_name ItemAttributes

const WEAPON_DAMAGE: Dictionary = {
    "weapon_melee_low":   10.0,   # TEST VALUE
    "weapon_melee_high":  15.0,   # TEST VALUE
    "weapon_ranged_low":   8.0,   # TEST VALUE（短弓）
    "weapon_ranged_high": 12.0,   # TEST VALUE（長弓）
    "unarmed":             5.0,   # TEST VALUE
}

const WEAPON_RANGE: Dictionary = {
    # 遭遇戰 hex 攻擊距離
    "weapon_melee_low":   1,
    "weapon_melee_high":  1,
    "weapon_ranged_low":  4,   # TEST VALUE
    "weapon_ranged_high": 6,   # TEST VALUE
    "unarmed":            1,
}

const WEAPON_IS_2H: Array = [
    "weapon_ranged_low",
    "weapon_ranged_high",
]

static func get_damage(grade: String) -> float:
    return float(WEAPON_DAMAGE.get(grade, WEAPON_DAMAGE["unarmed"]))

static func get_range(grade: String) -> int:
    return int(WEAPON_RANGE.get(grade, 1))

static func is_2h(grade: String) -> bool:
    return grade in WEAPON_IS_2H
```

---

## 2. 護甲屬性

```gdscript
const ARMOR_DAMAGE_REDUCTION: Dictionary = {
    # 命中部位有此護甲 → 傷害 × (1 - reduction)
    "armor_low":  0.4,   # TEST VALUE — 皮甲，傷害剩 60%
    "armor_high": 0.6,   # TEST VALUE — 鐵甲，傷害剩 40%
}

static func get_damage_reduction(grade: String) -> float:
    return float(ARMOR_DAMAGE_REDUCTION.get(grade, 0.0))
```

**護甲槽對應：**
- `armor_*` 裝在護甲槽（head/torso/arm/leg）→ 該部位命中時套用減傷
- 護甲只保護自己對應的部位槽（head 護甲不保護 torso）

---

## 3. 盾牌屬性

```gdscript
const SHIELD_BLOCK_CHANCE: Dictionary = {
    # armor_* 裝在 hand 槽時作為盾牌
    "armor_low":  0.30,   # TEST VALUE — 皮盾格擋機率
    "armor_high": 0.50,   # TEST VALUE — 鐵盾格擋機率
}

static func get_block_chance(grade: String) -> float:
    return float(SHIELD_BLOCK_CHANCE.get(grade, 0.0))

const WEAPON_PARRY_CHANCE: Dictionary = {
    # 近戰武器架擋基礎機率（技能可加成，見 encounter-combat-design）
    "weapon_melee_low":  0.10,   # TEST VALUE
    "weapon_melee_high": 0.20,   # TEST VALUE
    "unarmed":           0.05,   # TEST VALUE
}

static func get_parry_chance(grade: String) -> float:
    return float(WEAPON_PARRY_CHANCE.get(grade, 0.05))
```

**格擋邏輯：**
- 格擋成功 → 完全無傷害（不觸發部位傷害計算）
- 格擋只在有命中時判定（不影響 miss）
- hand_1 或 hand_2 有 armor_* → 視為盾牌，觸發格擋判定

---

## 4. 物品重量

```gdscript
const ITEM_WEIGHT: Dictionary = {
    # 玩家背包重量計算用（TEST VALUE）
    "weapon_melee_low":   2.5,
    "weapon_melee_high":  4.0,
    "weapon_ranged_low":  2.0,   # 短弓（2h）
    "weapon_ranged_high": 3.0,   # 長弓（2h）
    "armor_low":          4.0,   # 皮甲/皮盾（依槽位效果不同）
    "armor_high":         7.0,   # 鐵甲/鐵盾
    "food":               0.5,   # per unit
    "medicine":           0.3,   # per unit
    "tools":              2.0,
    "arrows":             0.05,  # per unit
}

static func get_weight(grade: String, qty: int = 1) -> float:
    return float(ITEM_WEIGHT.get(grade, 1.0)) * qty
```

---

## 5. 消耗品屬性

```gdscript
const MEDICINE_COST: Dictionary = {
    # 使用動作 → 消耗 medicine 數量
    "草藥":   1,   # 清除 bleeding_minor
    "繃帶":   2,   # 清除 bleeding_major
    "解毒劑": 3,   # 清除 poisoned
}

const TOOLS_COST: Dictionary = {
    "夾板": 1,   # 清除 fracture（消耗 tools）
}

const ARROW_COST_PER_SHOT: int = 1   # 每次射擊消耗箭矢數（TEST VALUE）

static func get_medicine_cost(action: String) -> int:
    return int(MEDICINE_COST.get(action, 0))

static func get_tools_cost(action: String) -> int:
    return int(TOOLS_COST.get(action, 0))
```

---

## 6. 查詢接口彙整

健康系統和遭遇戰系統統一透過以下 static 函數查詢：

```gdscript
# 武器
var dmg: float        = ItemAttributes.get_damage(weapon_grade)
var range: int        = ItemAttributes.get_range(weapon_grade)
var is_2h: bool       = ItemAttributes.is_2h(weapon_grade)
var parry: float      = ItemAttributes.get_parry_chance(weapon_grade)

# 護甲 / 盾牌
var reduction: float  = ItemAttributes.get_damage_reduction(armor_grade)
var block: float      = ItemAttributes.get_block_chance(shield_grade)

# 重量
var w: float          = ItemAttributes.get_weight(grade, qty)

# 消耗品
var med_cost: int     = ItemAttributes.get_medicine_cost("草藥")   # 1
var tool_cost: int    = ItemAttributes.get_tools_cost("夾板")      # 1
var arrow_cost: int   = ItemAttributes.ARROW_COST_PER_SHOT         # 1
```

---

## 修改檔案

| 檔案 | 動作 |
|---|---|
| `scripts/data/item_attributes.gd` | **新建** — 所有物品戰鬥屬性常數 + static 查詢函數 |
| `scripts/simulation/encounter_system.gd` | 移除自定義傷害常數，改用 `ItemAttributes.*` |
| `scripts/simulation/health_system.gd`（新）| 同上 |
| `scripts/debug/headless_test.gd` | 驗證 ItemAttributes 查詢回傳正確值 |

---

## 驗證標準

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

預期：
- `ItemAttributes.get_damage("weapon_melee_low")` = 10.0
- `ItemAttributes.get_block_chance("armor_high")` = 0.50
- `ItemAttributes.is_2h("weapon_ranged_low")` = true
- `ItemAttributes.is_2h("weapon_melee_high")` = false

---

## ⚠️ TEST VALUES

| 屬性 | 值 | 備註 |
|---|---|---|
| weapon_melee_low damage | 10.0 | 平衡期調整 |
| weapon_melee_high damage | 15.0 | |
| weapon_ranged_low damage | 8.0 | 短弓 |
| weapon_ranged_high damage | 12.0 | 長弓 |
| unarmed damage | 5.0 | |
| weapon_ranged_low range | 4 hex | |
| weapon_ranged_high range | 6 hex | |
| armor_low reduction | 0.40 | 40% 減傷 |
| armor_high reduction | 0.60 | 60% 減傷 |
| armor_low block | 0.30 | 30% 盾牌格擋基礎 |
| armor_high block | 0.50 | 50% 盾牌格擋基礎 |
| weapon_melee_low parry | 0.10 | 10% 架擋基礎 |
| weapon_melee_high parry | 0.20 | 20% 架擋基礎 |
| unarmed parry | 0.05 | 5% 架擋基礎 |
| weapon_melee_low 重量 | 2.5 | |
| weapon_melee_high 重量 | 4.0 | |
| weapon_ranged_low 重量 | 2.0 | |
| weapon_ranged_high 重量 | 3.0 | |
| armor_low 重量 | 4.0 | |
| armor_high 重量 | 7.0 | |
| food 重量 | 0.5/unit | |
| medicine 重量 | 0.3/unit | |
| tools 重量 | 2.0 | |
| arrows 重量 | 0.05/unit | |
| ARROW_COST_PER_SHOT | 1 | |
