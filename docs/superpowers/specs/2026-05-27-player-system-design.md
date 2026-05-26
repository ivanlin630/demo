# 玩家系統 Design

## 依賴

本 spec 依賴：
- `2026-05-27-data-structure-update-design.md`（player_id、player_state、equipment 8 格）
- `2026-05-27-encounter-system-design.md`（玩家遭遇戰裝備）

---

## Goal

定義玩家在世界模擬器中的接口：玩家永遠是 team leader、物品欄系統、裝備系統、與 team 資源的互動關係。**玩家使用 NPC 的 PersonData 結構**，不另建獨立求生數值。

---

## 1. 玩家身份

- `WorldState.player_id: int`：指向玩家的 person_id（-1 = 純模擬模式）
- 玩家永遠是所在 team 的 leader（`p.role == "leader"`）
- 玩家死亡 → game over（或轉至 ghost 觀察模式，後續 spec 定義）

---

## 2. 玩家物品欄

玩家在 `WorldState.player_state` 內維護個人物品欄（與 team resources 分開）：

```gdscript
# WorldState.player_state 結構
player_state = {
    "inventory": Array,    # Array[Dictionary] 個人攜帶物品
    "coin": float,         # 個人金幣（獨立於 team）
}

# inventory item 格式
{
    "grade": String,       # "weapon_melee_low" / "armor_high" / "food" / "medicine" / "tools" / 或 unique item id
    "type": String,        # "pool" / "unique"
    "qty": int,            # pool 物品數量；unique 永遠 1
}
```

### 物品欄上限

```gdscript
const PLAYER_INVENTORY_MAX_WEIGHT: float = 30.0   # TEST VALUE

func _calc_inventory_weight(state: WorldState) -> float:
    var total: float = 0.0
    for item in state.player_state.get("inventory", []):
        total += ITEM_WEIGHT.get(item["grade"], 1.0) * item.get("qty", 1)
    return total

# ITEM_WEIGHT TEST VALUES
const ITEM_WEIGHT: Dictionary = {
    "weapon_melee_low":  3.0,
    "weapon_melee_high": 4.0,
    "weapon_ranged_low": 2.5,
    "weapon_ranged_high": 3.0,
    "armor_low":         5.0,
    "armor_high":        8.0,
    "food":              0.5,   # per unit
    "medicine":          0.3,   # per unit
    "tools":             2.0,   # per unit
}
```

---

## 3. 玩家裝備欄

玩家使用 `PersonData.equipment` 8 格（與 NPC 相同結構）：

```
right_hand: 主武器
left_hand:  副武器/盾/火把
head:       頭部護甲
torso:      軀幹護甲
right_arm / left_arm / right_leg / left_leg: 肢體護甲
```

### 裝備/卸下

- 裝備：從物品欄取 pool 物品 → 放入對應 equipment 格
- 卸下：從 equipment 格取出 → 放回物品欄

```gdscript
func equip_item(state: WorldState, slot: String, item_grade: String) -> bool:
    var inv: Array = state.player_state.get("inventory", [])
    # 找物品欄中對應物品
    for i in range(inv.size()):
        if inv[i]["grade"] == item_grade:
            var player: PersonData = state.persons.get(state.player_id)
            if player == null: return false
            # 卸下舊裝備（若有）
            var old := player.equipment.get(slot, {})
            if old.get("type", "none") != "none":
                _add_to_inventory(state, old["grade"])
            player.equipment[slot] = { "type": "pool", "grade": item_grade }
            inv[i]["qty"] -= 1
            if inv[i]["qty"] <= 0: inv.remove_at(i)
            return true
    return false

func _add_to_inventory(state: WorldState, grade: String) -> void:
    var inv: Array = state.player_state.get("inventory", [])
    for item in inv:
        if item["grade"] == grade and item["type"] == "pool":
            item["qty"] += 1
            return
    inv.append({ "grade": grade, "type": "pool", "qty": 1 })
```

---

## 4. 玩家與 Team 資源互動

### 從 team 取物（放入個人物品欄）

```gdscript
func take_from_team(state: WorldState, grade: String, qty: int) -> bool:
    var team: TeamData = _get_player_team(state)
    if team == null: return false
    var cur: int = int(team.resources.get(grade, 0))
    if cur < qty: return false
    team.resources[grade] = cur - qty
    for i in range(qty):
        _add_to_inventory(state, grade)
    return true
```

### 存入 team（從個人物品欄）

```gdscript
func deposit_to_team(state: WorldState, grade: String, qty: int) -> bool:
    var inv: Array = state.player_state.get("inventory", [])
    for item in inv:
        if item["grade"] == grade and item.get("qty", 0) >= qty:
            item["qty"] -= qty
            if item["qty"] <= 0: inv.erase(item)
            var team: TeamData = _get_player_team(state)
            if team: team.resources[grade] = int(team.resources.get(grade, 0)) + qty
            return true
    return false
```

### 食物消耗

玩家個人不單獨消耗食物——玩家作為 team leader，food 由 team 統一結算（ResourceSystem 現有邏輯）。

---

## 5. 玩家視野限制

- 玩家只能看到 `state.team_discovered[player_team_id]` 內的 team
- UI 顯示地圖時使用迷霧遮罩（見 VisionSystem）
- 玩家不可存取全知 `state.teams`（僅 AI 模擬用）

```gdscript
func get_visible_teams(state: WorldState) -> Array:
    var player_team_id: int = _get_player_team_id(state)
    return state.team_discovered.get(player_team_id, [])
```

---

## 6. 玩家 NPC 求生屬性

玩家複用 PersonData：
- `p.stress`：壓力（同 NPC）
- `p.loyalty`：對自己 team 不需要（leader 固定 1.0）
- `p.needs`（體力/飢餓/口渴）：同 NPC 使用 ResourceSystem 結算

玩家個人需求比 NPC 更細緻的差異**留至後續 spec 定義**，目前統一使用 NPC 模型。

---

## 7. WorldState 玩家初始化

```gdscript
func init_player(state: WorldState, person_id: int,
        team_id: int) -> void:
    state.player_id = person_id
    state.player_state = {
        "inventory": [],
        "coin": 50.0,   # TEST VALUE 初始金幣
    }
    var p: PersonData = state.persons.get(person_id)
    if p:
        p.role = "leader"
        p.team_id = team_id
```

---

## 驗證標準

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

預期：
- `state.player_id` 非 -1（初始化後）
- `take_from_team` 成功後 team.resources 減少，inventory 增加
- `equip_item` 後 `person.equipment[slot]` 更新，inventory 減少
- `get_visible_teams` 僅返回 team_discovered 範圍
