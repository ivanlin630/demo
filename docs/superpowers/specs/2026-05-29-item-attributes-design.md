# 物品屬性 Design

## 依賴

無上游依賴。以下系統查詢此 spec（不逆向依賴）：
- `player-system-design.md`（背包重量）
- `encounter-system-design.md`（箭矢消耗）
- `encounter-combat-design.md`（傷害/格擋/架擋）
- `health-system-design.md`（receive_damage 前的傷害計算）

---

## Goal

集中定義所有物品的**戰鬥屬性、功能屬性、顯示名稱**。**所有系統只查詢此處，不自行定義數值。**

新增物品 = 在 `ITEM_REGISTRY` 新增一個 entry，不需修改其他任何檔案。

---

## 1. 物品登記表（ITEM_REGISTRY）

```gdscript
# scripts/data/item_attributes.gd
class_name ItemAttributes

const ITEM_REGISTRY: Dictionary = {

    # ── 武器 ──────────────────────────────────────────────
    "weapon_melee_low": {
        "display_name":   "短劍",
        "category":       "weapon",
        "damage":         10.0,    # TEST VALUE
        "range":          1,
        "is_2h":          false,
        "parry_chance":   0.10,    # TEST VALUE
        "weight":         2.5,     # TEST VALUE
    },
    "weapon_melee_high": {
        "display_name":   "長劍",
        "category":       "weapon",
        "damage":         15.0,    # TEST VALUE
        "range":          1,
        "is_2h":          false,
        "parry_chance":   0.20,    # TEST VALUE
        "weight":         4.0,     # TEST VALUE
    },
    "weapon_ranged_low": {
        "display_name":   "短弓",
        "category":       "weapon",
        "damage":         8.0,     # TEST VALUE
        "range":          4,       # TEST VALUE
        "is_2h":          true,
        "parry_chance":   0.0,     # 弓無法架擋
        "weight":         2.0,     # TEST VALUE
    },
    "weapon_ranged_high": {
        "display_name":   "長弓",
        "category":       "weapon",
        "damage":         12.0,    # TEST VALUE
        "range":          6,       # TEST VALUE
        "is_2h":          true,
        "parry_chance":   0.0,
        "weight":         3.0,     # TEST VALUE
    },
    "unarmed": {
        "display_name":   "徒手",
        "category":       "weapon",
        "damage":         5.0,     # TEST VALUE
        "range":          1,
        "is_2h":          false,
        "parry_chance":   0.05,    # TEST VALUE
        "weight":         0.0,
    },

    # ── 護甲 / 盾牌 ────────────────────────────────────────
    # armor_* 裝在護甲槽（head/torso/arm/leg）→ damage_reduction
    # armor_* 裝在手槽（hand_1/hand_2）        → block_chance（顯示名改為 display_name_shield）
    "armor_low": {
        "display_name":        "皮甲",
        "display_name_shield": "皮盾",
        "category":            "armor",
        "damage_reduction":    0.4,    # TEST VALUE — 傷害剩 60%
        "block_chance":        0.30,   # TEST VALUE
        "weight":              4.0,    # TEST VALUE
    },
    "armor_high": {
        "display_name":        "鐵甲",
        "display_name_shield": "鐵盾",
        "category":            "armor",
        "damage_reduction":    0.6,    # TEST VALUE — 傷害剩 40%
        "block_chance":        0.50,   # TEST VALUE
        "weight":              7.0,    # TEST VALUE
    },

    # ── 消耗品 ─────────────────────────────────────────────
    "food": {
        "display_name": "乾糧",
        "category":     "consumable",
        "weight":       0.5,    # TEST VALUE per unit
    },
    "medicine": {
        "display_name": "藥品",
        "category":     "consumable",
        "weight":       0.3,    # TEST VALUE per unit
        # 各治療動作消耗 medicine 數量
        "use_cost": {
            "草藥":   1,   # 清除 bleeding_minor
            "繃帶":   2,   # 清除 bleeding_major
            "解毒劑": 3,   # 清除 poisoned
        },
    },
    "tools": {
        "display_name": "工具包",
        "category":     "consumable",
        "weight":       2.0,    # TEST VALUE
        "use_cost": {
            "夾板": 1,    # 清除 fracture
        },
    },
    "arrows": {
        "display_name":    "箭矢",
        "category":        "consumable",
        "weight":          0.05,   # TEST VALUE per unit
        "cost_per_shot":   1,      # TEST VALUE
    },
}
```

---

## 2. Static 查詢函數

```gdscript
static func _get(grade: String) -> Dictionary:
    return ITEM_REGISTRY.get(grade, {})

# 武器
static func get_damage(grade: String) -> float:
    return float(_get(grade).get("damage", _get("unarmed").get("damage", 5.0)))

static func get_range(grade: String) -> int:
    return int(_get(grade).get("range", 1))

static func is_2h(grade: String) -> bool:
    return bool(_get(grade).get("is_2h", false))

static func get_parry_chance(grade: String) -> float:
    return float(_get(grade).get("parry_chance", 0.05))

# 護甲 / 盾牌
static func get_damage_reduction(grade: String) -> float:
    return float(_get(grade).get("damage_reduction", 0.0))

static func get_block_chance(grade: String) -> float:
    return float(_get(grade).get("block_chance", 0.0))

# 重量
static func get_weight(grade: String, qty: int = 1) -> float:
    return float(_get(grade).get("weight", 1.0)) * qty

# 消耗品
static func get_medicine_cost(action: String) -> int:
    return int(_get("medicine").get("use_cost", {}).get(action, 0))

static func get_tools_cost(action: String) -> int:
    return int(_get("tools").get("use_cost", {}).get(action, 0))

const ARROW_COST_PER_SHOT: int = 1   # 快捷存取（等同 _get("arrows")["cost_per_shot"]）

# 顯示名稱（手槽 armor 自動返回盾牌名）
static func get_display_name(grade: String, slot: String = "") -> String:
    var item: Dictionary = _get(grade)
    if slot in ["hand_1", "hand_2"] and item.has("display_name_shield"):
        return item["display_name_shield"]
    return item.get("display_name", grade)

# 分類查詢（UI 過濾用）
static func get_category(grade: String) -> String:
    return _get(grade).get("category", "")

static func is_weapon(grade: String) -> bool:
    return get_category(grade) == "weapon"

static func is_armor(grade: String) -> bool:
    return get_category(grade) == "armor"
```

---

## 3. 新增物品方法

只需在 `ITEM_REGISTRY` 末端加入新 entry，填入適用欄位：

```gdscript
# 範例：加入長矛
"weapon_spear": {
    "display_name":  "長矛",
    "category":      "weapon",
    "damage":        13.0,
    "range":         2,        # 比近戰多 1 格
    "is_2h":         true,
    "parry_chance":  0.15,
    "weight":        3.5,
},
```

不需修改任何其他 spec 或系統檔案。

---

## 4. 查詢接口彙整

```gdscript
# 武器
ItemAttributes.get_damage(weapon_grade)
ItemAttributes.get_range(weapon_grade)
ItemAttributes.is_2h(weapon_grade)
ItemAttributes.get_parry_chance(weapon_grade)

# 護甲 / 盾牌
ItemAttributes.get_damage_reduction(armor_grade)
ItemAttributes.get_block_chance(shield_grade)

# 重量
ItemAttributes.get_weight(grade, qty)

# 消耗品
ItemAttributes.get_medicine_cost("草藥")    # → 1
ItemAttributes.get_tools_cost("夾板")       # → 1
ItemAttributes.ARROW_COST_PER_SHOT         # → 1

# 顯示
ItemAttributes.get_display_name(grade, slot)
ItemAttributes.get_category(grade)
ItemAttributes.is_weapon(grade)
ItemAttributes.is_armor(grade)
```

---

## 修改檔案

| 檔案 | 動作 |
|---|---|
| `scripts/data/item_attributes.gd` | **新建** — ITEM_REGISTRY + static 查詢函數 |
| `scripts/simulation/encounter_system.gd` | 移除自定義傷害常數，改用 `ItemAttributes.*` |
| `scripts/simulation/encounter_combat.gd`（新）| 使用 `ItemAttributes.*` 計算格擋/傷害 |
| `scripts/debug/headless_test.gd` | 驗證 ItemAttributes 查詢回傳正確值 |

---

## 驗證標準

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

預期：
- `ItemAttributes.get_damage("weapon_melee_low")` = 10.0
- `ItemAttributes.get_block_chance("armor_high")` = 0.50
- `ItemAttributes.get_parry_chance("weapon_melee_high")` = 0.20
- `ItemAttributes.is_2h("weapon_ranged_low")` = true
- `ItemAttributes.is_2h("weapon_melee_high")` = false
- `ItemAttributes.get_weight("armor_high", 1)` = 7.0
- `ItemAttributes.get_medicine_cost("繃帶")` = 2
- `ItemAttributes.get_display_name("armor_low", "hand_1")` = "皮盾"

---

## ⚠️ TEST VALUES

| grade | 屬性 | 值 |
|---|---|---|
| weapon_melee_low | damage | 10.0 |
| weapon_melee_high | damage | 15.0 |
| weapon_ranged_low | damage / range | 8.0 / 4 hex |
| weapon_ranged_high | damage / range | 12.0 / 6 hex |
| unarmed | damage | 5.0 |
| weapon_melee_low | parry_chance | 0.10 |
| weapon_melee_high | parry_chance | 0.20 |
| unarmed | parry_chance | 0.05 |
| armor_low | damage_reduction | 0.40 |
| armor_high | damage_reduction | 0.60 |
| armor_low | block_chance | 0.30 |
| armor_high | block_chance | 0.50 |
| weapon_melee_low | weight | 2.5 |
| weapon_melee_high | weight | 4.0 |
| weapon_ranged_low | weight | 2.0 |
| weapon_ranged_high | weight | 3.0 |
| armor_low | weight | 4.0 |
| armor_high | weight | 7.0 |
| food | weight | 0.5/unit |
| medicine | weight | 0.3/unit |
| tools | weight | 2.0 |
| arrows | weight / cost_per_shot | 0.05/unit / 1 |
