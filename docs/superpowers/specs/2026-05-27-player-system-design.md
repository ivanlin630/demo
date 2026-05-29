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

**雙重限制**：格子數 **AND** 重量，任一超出即無法新增。

```gdscript
const PLAYER_INVENTORY_MAX_SLOTS: int   = 6      # TEST VALUE — 最多 6 格（每格一種物品）
const PLAYER_INVENTORY_MAX_WEIGHT: float = 30.0  # TEST VALUE — 最大總重量

func _can_add_item(state: WorldState, grade: String, qty: int = 1) -> bool:
    var inv: Array = state.player_state.get("inventory", [])
    # 格子檢查：新 grade 需佔新格；已有 grade 不佔格
    var already_has := inv.any(func(x): return x["grade"] == grade)
    if not already_has and inv.size() >= PLAYER_INVENTORY_MAX_SLOTS:
        return false
    # 重量檢查（查 ItemAttributes）
    if _calc_inventory_weight(state) + ItemAttributes.get_weight(grade, qty) > PLAYER_INVENTORY_MAX_WEIGHT:
        return false
    return true

func _calc_inventory_weight(state: WorldState) -> float:
    var total: float = 0.0
    for item in state.player_state.get("inventory", []):
        total += ItemAttributes.get_weight(item["grade"], item.get("qty", 1))
    return total
# 重量數值見 item-attributes-design.md（ItemAttributes.ITEM_WEIGHT）

# 完整物品清單（inventory grade → 中文顯示名 / 用途）
# "weapon_melee_low"   短劍    → hand_1/hand_2（單手）
# "weapon_melee_high"  長劍    → hand_1/hand_2（單手）
# "weapon_ranged_low"  短弓    → hand_1+hand_2（雙手）
# "weapon_ranged_high" 長弓    → hand_1+hand_2（雙手）
# "armor_low"          皮甲/皮盾 → 護甲槽=減傷；手槽=格擋
# "armor_high"         鐵甲/鐵盾 → 同上
# "food"               乾糧    → 使用消耗，回復飢餓
# "medicine"           藥品    → 草藥(×1清小出血)/繃帶(×2清大出血)/解毒劑(×3清中毒)
# "tools"              工具包  → 夾板(×1清骨折)；生產/修繕用
# "arrows"             箭矢    → 弓類武器彈藥
```

---

## 3. 玩家裝備欄

玩家使用 `PersonData.equipment` 8 槽（與 NPC 相同結構）：

```
hand_1:     主手（無左右區分，可持武器或盾牌）
hand_2:     副手（同上；2h 武器時與 hand_1 同時佔用）
head:       頭部護甲
torso:      軀幹護甲
right_arm / left_arm / right_leg / left_leg: 肢體護甲
```

**槽位規則：**
- `armor_*` 裝在 head/torso/arm/leg → 提供該部位減傷
- `armor_*` 裝在 hand_1 或 hand_2 → 視為盾牌，提供 `block_chance`
- `weapon_ranged_*` 裝備時佔 hand_1 + hand_2（`is_2h = true`，副手不可另放物品）

### 裝備/卸下

```gdscript
const WEAPON_2H: Array = ["weapon_ranged_low", "weapon_ranged_high"]

func equip_item(state: WorldState, slot: String, item_grade: String) -> bool:
    var inv: Array = state.player_state.get("inventory", [])
    for i in range(inv.size()):
        if inv[i]["grade"] != item_grade: continue
        var player: PersonData = state.persons.get(state.player_id)
        if player == null: return false
        # 2h 武器：佔 hand_1 + hand_2
        if item_grade in WEAPON_2H:
            _unequip_slot(state, player, "hand_1")
            _unequip_slot(state, player, "hand_2")
            player.equipment["hand_1"] = { "type": "pool", "grade": item_grade, "is_2h": true }
            player.equipment["hand_2"] = { "type": "2h_ref" }  # 佔位，不可單獨裝備
        else:
            _unequip_slot(state, player, slot)
            player.equipment[slot] = { "type": "pool", "grade": item_grade }
        inv[i]["qty"] -= 1
        if inv[i]["qty"] <= 0: inv.remove_at(i)
        return true
    return false

func _unequip_slot(state: WorldState, player: PersonData, slot: String) -> void:
    var old = player.equipment.get(slot, {})
    if old.get("type", "none") in ["none", "2h_ref"]: return
    _add_to_inventory(state, old["grade"])

func _add_to_inventory(state: WorldState, grade: String, qty: int = 1) -> bool:
    if not _can_add_item(state, grade, qty): return false
    var inv: Array = state.player_state.get("inventory", [])
    for item in inv:
        if item["grade"] == grade and item["type"] == "pool":
            item["qty"] += qty
            return true
    inv.append({ "grade": grade, "type": "pool", "qty": qty })
    return true
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
    if not _can_add_item(state, grade, qty): return false   # 格子/重量不足
    team.resources[grade] = cur - qty
    _add_to_inventory(state, grade, qty)
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
- `take_from_team` 第 7 格物品 → 返回 false（格子上限）
- `take_from_team` 超重 → 返回 false（重量上限）
- `equip_item` 後 `person.equipment[slot]` 更新，inventory 減少
- `get_visible_teams` 僅返回 team_discovered 範圍
