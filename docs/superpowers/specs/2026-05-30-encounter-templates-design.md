# 遭遇戰物品模板 Design

## 依賴

- `2026-05-27-encounter-system-design.md`（EncounterUnit 結構、inventory 格式）
- `2026-05-29-item-attributes-design.md`（ITEM_REGISTRY、grade 名稱）

以下系統使用本 spec：
- `encounter-system-design.md`（`_init_named_unit` / `_init_anon_unit` 呼叫 `EncounterTemplates.fill_inventory`）

---

## Goal

定義遭遇戰進場時各類型 unit 的物品欄填充規則（箭矢、藥品、工具）。
**模板獨立於裝備分配邏輯**，專注於消耗品填充。
新增模板 = 在 `TEMPLATES` 新增一個 entry，不需修改其他檔案。

---

## 1. 模板定義

```gdscript
# scripts/data/encounter_templates.gd
class_name EncounterTemplates

# 每個模板：fill = 按順序嘗試填充的消耗品清單
# qty 為最大嘗試領取量，受 team.resources 實際數量限制
const TEMPLATES: Dictionary = {

    "archer": {
        "fill": [
            { "grade": "arrows",   "qty": 20 },   # TEST VALUE
            { "grade": "medicine", "qty": 2  },   # TEST VALUE
        ],
    },
    "melee": {
        "fill": [
            { "grade": "medicine", "qty": 3  },   # TEST VALUE
        ],
    },
    "medic": {
        "fill": [
            { "grade": "medicine", "qty": 6  },   # TEST VALUE
        ],
    },
    "default": {
        "fill": [
            { "grade": "medicine", "qty": 2  },   # TEST VALUE
        ],
    },
}
```

---

## 2. 模板選擇邏輯

優先序：醫療技能 → 裝備武器類型 → 預設

```gdscript
static func select_template(unit: Dictionary, state: WorldState) -> String:
    # 醫療技能優先（具名 NPC 才有個體技能）
    if unit.get("person_id", -1) != -1:
        var p: PersonData = state.persons.get(unit["person_id"])
        if p and float(p.skills.get("醫療", 0.0)) > 0.5:
            return "medic"

    var equip: Dictionary = unit.get("equipment", {})
    var h1_grade: String  = equip.get("hand_1", {}).get("grade", "")

    # 遠程武器 → 弓手
    if h1_grade.contains("ranged"): return "archer"

    # 手持盾牌 → 近戰（盾兵優先拿藥）
    for hand in ["hand_1", "hand_2"]:
        if equip.get(hand, {}).get("grade", "").begins_with("armor_"):
            return "melee"

    # 近戰武器（含徒手）→ 近戰
    if h1_grade.contains("melee") or h1_grade == "unarmed":
        return "melee"

    return "default"
```

---

## 3. 填充執行

從 team.resources 扣除，填入 `unit["inventory"]`：

```gdscript
static func fill_inventory(unit: Dictionary, team: TeamData,
        state: WorldState) -> void:
    var tmpl_name: String = select_template(unit, state)
    var tmpl: Dictionary  = TEMPLATES.get(tmpl_name, TEMPLATES["default"])
    var inv: Array        = unit.get("inventory", [])

    for entry in tmpl["fill"]:
        var grade: String = entry["grade"]
        var want: int     = entry["qty"]
        var avail: int    = int(team.resources.get(grade, 0))
        var give: int     = mini(want, avail)
        if give <= 0: continue
        inv.append({ "grade": grade, "type": "pool", "qty": give })
        team.resources[grade] = avail - give

    unit["inventory"] = inv
```

---

## 4. 新增模板方法

在 `TEMPLATES` 末端加入新 entry：

```gdscript
# 範例：投石兵（未來）
"slinger": {
    "fill": [
        { "grade": "stones",   "qty": 30 },
        { "grade": "medicine", "qty": 2  },
    ],
},
```

同時在 `select_template` 加入對應條件即可；不需修改其他 spec 或系統。

---

## 修改檔案

| 檔案 | 動作 |
|---|---|
| `scripts/data/encounter_templates.gd` | **新建**：TEMPLATES + select_template + fill_inventory |
| `scripts/simulation/encounter_system.gd` | `_init_named_unit` / `_init_anon_unit` 呼叫 `EncounterTemplates.fill_inventory` |

---

## 驗證標準

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

預期：
- 弓手 unit `inventory` 含 `arrows` ×≤20、`medicine` ×≤2
- 近戰 unit `inventory` 含 `medicine` ×≤3
- 醫療技能 > 0.5 的具名 NPC 分配 `medicine` ×≤6
- team.resources["arrows"] / ["medicine"] 相應減少
- 遭遇戰結束後剩餘消耗品歸還 team.resources

---

## ⚠️ TEST VALUES

| 模板 | 物品 | 數量 |
|---|---|---|
| archer | arrows | 20 |
| archer | medicine | 2 |
| melee | medicine | 3 |
| medic | medicine | 6 |
| default | medicine | 2 |
