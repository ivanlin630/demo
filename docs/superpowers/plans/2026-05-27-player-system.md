# 玩家系統 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 實裝玩家接口：init_player、個人物品欄（take/deposit/equip）、視野限制、WorldState.player_id 整合。

**Architecture:** 新建 `PlayerSystem` 集中所有玩家相關操作；玩家使用 PersonData 結構（複用 NPC 模型）；物品欄存於 `WorldState.player_state`。

**Tech Stack:** Godot 4.2.2 GDScript

**依賴：** `2026-05-27-data-structure-update.md`（player_id、player_state、equipment 8 格）。

---

## File Structure

| 動作 | 檔案 |
|---|---|
| Create | `scripts/simulation/player_system.gd` |
| Modify | `scripts/debug/headless_test.gd` |

---

### Task 1: PlayerSystem — init_player 與物品欄

**Files:**
- Create: `scripts/simulation/player_system.gd`

- [ ] **Step 1: 建立 player_system.gd**

```gdscript
# scripts/simulation/player_system.gd
class_name PlayerSystem

const ITEM_WEIGHT: Dictionary = {
    "weapon_melee_low":   3.0, "weapon_melee_high":  4.0,
    "weapon_ranged_low":  2.5, "weapon_ranged_high": 3.0,
    "armor_low":          5.0, "armor_high":         8.0,
    "food":               0.5, "medicine":           0.3,
    "tools":              2.0,
}
const PLAYER_MAX_WEIGHT: float = 30.0   # TEST VALUE

func init_player(state: WorldState, person_id: int, team_id: int) -> void:
    state.player_id = person_id
    state.player_state = {
        "inventory": [],
        "coin": 50.0,
    }
    var p: PersonData = state.persons.get(person_id)
    if p:
        p.role = "leader"
        p.team_id = team_id

func calc_inventory_weight(state: WorldState) -> float:
    var total: float = 0.0
    for item in state.player_state.get("inventory", []):
        total += ITEM_WEIGHT.get(item.get("grade", ""), 1.0) * item.get("qty", 1)
    return total

func add_to_inventory(state: WorldState, grade: String, qty: int = 1) -> void:
    var inv: Array = state.player_state.get("inventory", [])
    for item in inv:
        if item["grade"] == grade and item.get("type", "pool") == "pool":
            item["qty"] += qty
            return
    inv.append({ "grade": grade, "type": "pool", "qty": qty })

func take_from_team(state: WorldState, grade: String, qty: int) -> bool:
    var team: TeamData = _get_player_team(state)
    if team == null: return false
    var cur: int = int(team.resources.get(grade, 0))
    if cur < qty: return false
    team.resources[grade] = cur - qty
    for i in range(qty):
        add_to_inventory(state, grade, 1)
    return true

func deposit_to_team(state: WorldState, grade: String, qty: int) -> bool:
    var inv: Array = state.player_state.get("inventory", [])
    for item in inv:
        if item["grade"] == grade and item.get("qty", 0) >= qty:
            item["qty"] -= qty
            if item["qty"] <= 0: inv.erase(item)
            var team: TeamData = _get_player_team(state)
            if team:
                team.resources[grade] = int(team.resources.get(grade, 0)) + qty
            return true
    return false

func _get_player_team(state: WorldState) -> TeamData:
    var p: PersonData = state.persons.get(state.player_id)
    if p == null: return null
    return state.teams.get(p.team_id)

func get_visible_teams(state: WorldState) -> Array:
    var p: PersonData = state.persons.get(state.player_id)
    if p == null: return []
    return state.team_discovered.get(p.team_id, [])
```

- [ ] **Step 2: headless_test.gd 加驗證**

```gdscript
var _ps := PlayerSystem.new()
_ps.init_player(state, 0, 0)   # Person0 = 玩家，Team0
assert(state.player_id == 0, "player_id 應為 0")
assert(state.player_state.has("inventory"), "player_state 應有 inventory")
assert(float(state.player_state.get("coin", 0)) == 50.0, "初始金幣應為 50")
print("[Player] init_player 驗證通過")

# take_from_team 測試
state.teams[0].resources["medicine"] = 5
var _took: bool = _ps.take_from_team(state, "medicine", 2)
assert(_took, "take_from_team 應成功")
assert(int(state.teams[0].resources.get("medicine", 0)) == 3, "team medicine 應剩 3")
var _inv: Array = state.player_state.get("inventory", [])
var _has_med: bool = false
for item in _inv:
    if item["grade"] == "medicine": _has_med = true
assert(_has_med, "inventory 應有 medicine")
print("[Player] take_from_team 驗證通過")

# deposit_to_team 測試
var _dep: bool = _ps.deposit_to_team(state, "medicine", 1)
assert(_dep, "deposit_to_team 應成功")
assert(int(state.teams[0].resources.get("medicine", 0)) == 4, "team medicine 應為 4")
print("[Player] deposit_to_team 驗證通過")
```

- [ ] **Step 3: 執行測試**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd 2>&1 | Select-String "Player|SCRIPT ERROR|DONE"
```

- [ ] **Step 4: Commit**

```powershell
git add scripts/simulation/player_system.gd scripts/debug/headless_test.gd
git commit -m "feat(player): add PlayerSystem with init, inventory, take/deposit"
```

---

### Task 2: PlayerSystem — 裝備欄操作

**Files:**
- Modify: `scripts/simulation/player_system.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 加入 equip_item / unequip_item**

```gdscript
func equip_item(state: WorldState, slot: String, grade: String) -> bool:
    var inv: Array = state.player_state.get("inventory", [])
    var player: PersonData = state.persons.get(state.player_id)
    if player == null: return false
    for i in range(inv.size()):
        if inv[i]["grade"] == grade and inv[i].get("type", "pool") == "pool":
            # 卸下舊裝備
            var old: Dictionary = player.equipment.get(slot, {})
            if old.get("type", "none") != "none":
                add_to_inventory(state, old["grade"])
            player.equipment[slot] = { "type": "pool", "grade": grade }
            inv[i]["qty"] -= 1
            if inv[i]["qty"] <= 0: inv.remove_at(i)
            return true
    return false

func unequip_item(state: WorldState, slot: String) -> bool:
    var player: PersonData = state.persons.get(state.player_id)
    if player == null: return false
    var cur: Dictionary = player.equipment.get(slot, {})
    if cur.get("type", "none") == "none": return false
    add_to_inventory(state, cur["grade"])
    player.equipment[slot] = { "type": "none", "grade": "" }
    return true
```

- [ ] **Step 2: headless_test.gd 加驗證**

```gdscript
# 先給 inventory 一把武器
_ps.add_to_inventory(state, "weapon_melee_low", 1)
var _eq: bool = _ps.equip_item(state, "right_hand", "weapon_melee_low")
assert(_eq, "equip_item 應成功")
var _player: PersonData = state.persons.get(0)
assert(_player.equipment["right_hand"]["grade"] == "weapon_melee_low",
    "right_hand 應裝備 weapon_melee_low")
# inventory 中武器應減少
var _weapon_in_inv: bool = false
for item in state.player_state["inventory"]:
    if item["grade"] == "weapon_melee_low": _weapon_in_inv = true
assert(not _weapon_in_inv, "裝備後 inventory 不應有武器")
print("[Player] equip_item 驗證通過")
```

- [ ] **Step 3: 執行測試**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd 2>&1 | Select-String "Player|SCRIPT ERROR|DONE"
```

- [ ] **Step 4: Commit**

```powershell
git add scripts/simulation/player_system.gd scripts/debug/headless_test.gd
git commit -m "feat(player): add equip/unequip item with inventory sync"
```

---

### Task 3: 視野限制與重量驗證

**Files:**
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: headless_test.gd 加視野與重量驗證**

```gdscript
# get_visible_teams
var _visible: Array = _ps.get_visible_teams(state)
print("[Player] 玩家可見 team 數=%d" % _visible.size())
# 玩家在 Team0，Team0 discovered Team3 → visible 應包含 3
assert(_visible.has(3), "玩家應能看到 Team3")

# 重量計算
_ps.add_to_inventory(state, "armor_low", 2)
var _wt: float = _ps.calc_inventory_weight(state)
print("[Player] inventory weight=%.1f（armor_low×2=10.0）" % _wt)
assert(_wt >= 10.0, "armor_low×2 重量應 >= 10.0")
```

- [ ] **Step 2: 執行測試**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd 2>&1 | Select-String "Player|SCRIPT ERROR|DONE"
```

- [ ] **Step 3: Commit**

```powershell
git add scripts/debug/headless_test.gd
git commit -m "feat(player): add visible team and weight validation"
```
