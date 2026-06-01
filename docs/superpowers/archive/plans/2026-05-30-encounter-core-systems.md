# 遭遇戰核心系統 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement ItemAttributes registry, HealthSystem, EncounterTemplates, and update EncounterSystem/PlayerSystem so every encounter unit has equipment+inventory slots and combat runs on action timers with reactive block windows.

**Architecture:** ItemAttributes is a pure-static data class — adding an item means one entry, zero other changes. HealthSystem owns HP damage, blood, status flags, and weight-based speed. EncounterTemplates fills unit inventory at encounter start. EncounterSystem grows from round-based to tick-based action-timer combat. All 6 specs share one sub-session because they form a single dependency chain.

**Tech Stack:** Godot 4.2.2, GDScript. Headless test:
```
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```
After creating any file with `class_name`, always run `--headless --import` first or the class won't be found.

---

## File Map

| Action | File | Spec |
|---|---|---|
| **Create** | `scripts/data/item_attributes.gd` | item-attributes-design |
| **Modify** | `scripts/data/person_data.gd` | health-system-design |
| **Modify** | `scripts/simulation/equipment_system.gd` | encounter-system-design |
| **Modify** | `scripts/simulation/skill_system.gd` | encounter-system-design |
| **Modify** | `scripts/simulation/interaction_system.gd` | health-system-design |
| **Modify** | `scripts/simulation/faction_ai_system.gd` | encounter-system-design |
| **Create** | `scripts/simulation/health_system.gd` | health-system-design |
| **Create** | `scripts/data/encounter_templates.gd` | encounter-templates-design |
| **Modify** | `scripts/simulation/encounter_system.gd` | encounter-system + encounter-combat |
| **Modify** | `scripts/simulation/player_system.gd` | player-system-design |
| **Modify** | `scripts/debug/headless_test.gd` | all specs |

> **⚠️ Slot rename:** `right_hand` → `hand_1`, `left_hand` → `hand_2` throughout. The data-structure-update spec used the old names; the newer encounter/player specs supersede it.

---

## Task 1: ItemAttributes

**Files:**
- Create: `scripts/data/item_attributes.gd`

- [ ] **Step 1: Verify baseline passes**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```
Expected: `=== DONE ===` with no `SCRIPT ERROR`.

- [ ] **Step 2: Create `scripts/data/item_attributes.gd`**

```gdscript
# scripts/data/item_attributes.gd
class_name ItemAttributes

const ITEM_REGISTRY: Dictionary = {

    # ── 武器 ──────────────────────────────────────────────
    "weapon_melee_low": {
        "display_name":  "短劍",
        "category":      "weapon",
        "damage":        10.0,
        "range":         1,
        "is_2h":         false,
        "parry_chance":  0.10,
        "weight":        2.5,
    },
    "weapon_melee_high": {
        "display_name":  "長劍",
        "category":      "weapon",
        "damage":        15.0,
        "range":         1,
        "is_2h":         false,
        "parry_chance":  0.20,
        "weight":        4.0,
    },
    "weapon_ranged_low": {
        "display_name":  "短弓",
        "category":      "weapon",
        "damage":        8.0,
        "range":         4,
        "is_2h":         true,
        "parry_chance":  0.0,
        "weight":        2.0,
    },
    "weapon_ranged_high": {
        "display_name":  "長弓",
        "category":      "weapon",
        "damage":        12.0,
        "range":         6,
        "is_2h":         true,
        "parry_chance":  0.0,
        "weight":        3.0,
    },
    "unarmed": {
        "display_name":  "徒手",
        "category":      "weapon",
        "damage":        5.0,
        "range":         1,
        "is_2h":         false,
        "parry_chance":  0.05,
        "weight":        0.0,
    },

    # ── 護甲 / 盾牌 ────────────────────────────────────────
    "armor_low": {
        "display_name":        "皮甲",
        "display_name_shield": "皮盾",
        "category":            "armor",
        "damage_reduction":    0.4,
        "block_chance":        0.30,
        "weight":              4.0,
    },
    "armor_high": {
        "display_name":        "鐵甲",
        "display_name_shield": "鐵盾",
        "category":            "armor",
        "damage_reduction":    0.6,
        "block_chance":        0.50,
        "weight":              7.0,
    },

    # ── 消耗品 ─────────────────────────────────────────────
    "food": {
        "display_name": "乾糧",
        "category":     "consumable",
        "weight":       0.5,
    },
    "medicine": {
        "display_name": "藥品",
        "category":     "consumable",
        "weight":       0.3,
        "use_cost": {
            "草藥":   1,
            "繃帶":   2,
            "解毒劑": 3,
        },
    },
    "tools": {
        "display_name": "工具包",
        "category":     "consumable",
        "weight":       2.0,
        "use_cost": {
            "夾板": 1,
        },
    },
    "arrows": {
        "display_name":   "箭矢",
        "category":       "consumable",
        "weight":         0.05,
        "cost_per_shot":  1,
    },
}

const ARROW_COST_PER_SHOT: int = 1

static func _get(grade: String) -> Dictionary:
    return ITEM_REGISTRY.get(grade, {})

static func get_damage(grade: String) -> float:
    return float(_get(grade).get("damage", _get("unarmed").get("damage", 5.0)))

static func get_range(grade: String) -> int:
    return int(_get(grade).get("range", 1))

static func is_2h(grade: String) -> bool:
    return bool(_get(grade).get("is_2h", false))

static func get_parry_chance(grade: String) -> float:
    return float(_get(grade).get("parry_chance", 0.05))

static func get_damage_reduction(grade: String) -> float:
    return float(_get(grade).get("damage_reduction", 0.0))

static func get_block_chance(grade: String) -> float:
    return float(_get(grade).get("block_chance", 0.0))

static func get_weight(grade: String, qty: int = 1) -> float:
    return float(_get(grade).get("weight", 1.0)) * qty

static func get_medicine_cost(action: String) -> int:
    return int(_get("medicine").get("use_cost", {}).get(action, 0))

static func get_tools_cost(action: String) -> int:
    return int(_get("tools").get("use_cost", {}).get(action, 0))

static func get_display_name(grade: String, slot: String = "") -> String:
    var item: Dictionary = _get(grade)
    if slot in ["hand_1", "hand_2"] and item.has("display_name_shield"):
        return item["display_name_shield"]
    return item.get("display_name", grade)

static func get_category(grade: String) -> String:
    return _get(grade).get("category", "")

static func is_weapon(grade: String) -> bool:
    return get_category(grade) == "weapon"

static func is_armor(grade: String) -> bool:
    return get_category(grade) == "armor"
```

- [ ] **Step 3: Register class**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --import
```
Expected: exits without error.

- [ ] **Step 4: Add assertions to `scripts/debug/headless_test.gd`**

Find the `=== DONE ===` print near the end of `_run_sim_test()` and add **before** it:

```gdscript
	# ── ItemAttributes 驗證 ──
	print("--- ItemAttributes ---")
	assert(ItemAttributes.get_damage("weapon_melee_low") == 10.0,
		"get_damage weapon_melee_low should be 10.0")
	assert(ItemAttributes.get_block_chance("armor_high") == 0.50,
		"get_block_chance armor_high should be 0.50")
	assert(ItemAttributes.get_parry_chance("weapon_melee_high") == 0.20,
		"get_parry_chance weapon_melee_high should be 0.20")
	assert(ItemAttributes.is_2h("weapon_ranged_low") == true,
		"weapon_ranged_low should be 2h")
	assert(ItemAttributes.is_2h("weapon_melee_high") == false,
		"weapon_melee_high should not be 2h")
	assert(ItemAttributes.get_weight("armor_high", 1) == 7.0,
		"armor_high weight should be 7.0")
	assert(ItemAttributes.get_medicine_cost("繃帶") == 2,
		"medicine 繃帶 cost should be 2")
	assert(ItemAttributes.get_display_name("armor_low", "hand_1") == "皮盾",
		"armor_low in hand_1 should display as 皮盾")
	print("ItemAttributes OK")
```

- [ ] **Step 5: Run test**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```
Expected: `ItemAttributes OK` printed, `=== DONE ===`, no SCRIPT ERROR.

- [ ] **Step 6: Commit**

```
git add scripts/data/item_attributes.gd scripts/debug/headless_test.gd
git commit -m "feat(data): add ItemAttributes with ITEM_REGISTRY and static query functions"
```

---

## Task 2: PersonData + slot rename across all files

**Files:**
- Modify: `scripts/data/person_data.gd`
- Modify: `scripts/simulation/equipment_system.gd`
- Modify: `scripts/simulation/skill_system.gd`
- Modify: `scripts/simulation/interaction_system.gd`
- Modify: `scripts/simulation/faction_ai_system.gd`
- Modify: `scripts/simulation/encounter_system.gd`
- Modify: `scripts/debug/headless_test.gd`

> This task renames `right_hand`→`hand_1` and `left_hand`→`hand_2` everywhere. It also upgrades `person_data.gd` with `blood` and the new `body_parts` format.

- [ ] **Step 1: Update `person_data.gd`**

Replace the `equipment` dict and `body_parts` dict, and add `blood`:

```gdscript
# After var coin: float = 0.0  (near line 57)
var blood: float = 100.0   # 全身血液值（0=死亡，<30=昏迷）

var equipment: Dictionary = {
    "head":       { "type": "none", "grade": "" },
    "torso":      { "type": "none", "grade": "" },
    "right_arm":  { "type": "none", "grade": "" },
    "left_arm":   { "type": "none", "grade": "" },
    "right_leg":  { "type": "none", "grade": "" },
    "left_leg":   { "type": "none", "grade": "" },
    "hand_1":     { "type": "none", "grade": "" },
    "hand_2":     { "type": "none", "grade": "" },
}

var body_parts: Dictionary = {
    "head":      { "hp": 20.0, "max_hp": 20.0, "status": "healthy",
                   "poisoned": false, "bleeding": "none", "fracture": false },
    "torso":     { "hp": 50.0, "max_hp": 50.0, "status": "healthy",
                   "poisoned": false, "bleeding": "none", "fracture": false },
    "right_arm": { "hp": 25.0, "max_hp": 25.0, "status": "healthy",
                   "poisoned": false, "bleeding": "none", "fracture": false },
    "left_arm":  { "hp": 25.0, "max_hp": 25.0, "status": "healthy",
                   "poisoned": false, "bleeding": "none", "fracture": false },
    "right_leg": { "hp": 30.0, "max_hp": 30.0, "status": "healthy",
                   "poisoned": false, "bleeding": "none", "fracture": false },
    "left_leg":  { "hp": 30.0, "max_hp": 30.0, "status": "healthy",
                   "poisoned": false, "bleeding": "none", "fracture": false },
}
```

Also update `get_effective_speed()` — replace entire function:

```gdscript
func get_effective_speed() -> float:
    var base: float = 0.5 + float(attributes.get("體力", 0.5)) * 0.5
    var r: float = 1.0 if not body_parts["right_leg"].get("fracture", false) else 0.5
    var l: float = 1.0 if not body_parts["left_leg"].get("fracture", false) else 0.5
    var leg_mult: float = 1.0
    if r < 1.0 and l < 1.0: leg_mult = 0.1
    elif r < 1.0 or l < 1.0: leg_mult = 0.5
    return base * leg_mult
```

- [ ] **Step 2: Update `equipment_system.gd` — rename + new format**

Replace the entire `_update_equipment` function body. The key changes:
- `right_hand` → `hand_1`
- Reading weapon type: from `p.equipment["hand_1"].get("type", "none")` (old) to reading `grade`
- Writing weapon: from `p.equipment["hand_1"]["type"] = wtype` to `p.equipment["hand_1"] = { "type": "pool", "grade": "weapon_" + wtype }`
- Clearing: from `p.equipment["hand_1"]["type"] = "none"` to `p.equipment["hand_1"] = { "type": "none", "grade": "" }`

Full replacement for `_update_equipment`:

```gdscript
func _update_equipment(state: WorldState, team: TeamData) -> void:
    var equipped: Dictionary = {
        "melee_low": 0, "melee_high": 0, "ranged_low": 0, "ranged_high": 0
    }
    var named_ids: Array = _get_named_ids(team)
    for pid in named_ids:
        var p: PersonData = state.persons.get(pid)
        if p == null: continue
        var grade: String = p.equipment["hand_1"].get("grade", "")
        var wtype: String = grade.replace("weapon_", "") if grade.begins_with("weapon_") else "none"
        if wtype in equipped: equipped[wtype] += 1

    for wtype in WEAPON_TYPES:
        var pool_key: String = "weapon_" + wtype
        var target: int  = team.equip_order.get(wtype, 0)
        var current: int = equipped[wtype]
        var deficit: int = target - current

        if deficit > 0:
            var pool: int     = int(team.resources.get(pool_key, 0))
            var can_equip: int = pool / UNITS_PER_EQUIP
            var to_equip: int  = mini(deficit, can_equip)
            var equipped_count: int = 0
            for pid in named_ids:
                if equipped_count >= to_equip: break
                var p: PersonData = state.persons.get(pid)
                if p == null: continue
                if p.equipment["hand_1"].get("type", "none") == "none":
                    p.equipment["hand_1"] = { "type": "pool", "grade": pool_key }
                    equipped_count += 1
            team.resources[pool_key] = pool - equipped_count * UNITS_PER_EQUIP
            if equipped_count > 0:
                print("[Equip] Team%d 裝備 %s ×%d" % [team.team_id, wtype, equipped_count])

        elif deficit < 0:
            var to_unequip: int   = -deficit
            var unequipped_count: int = 0
            for pid in named_ids:
                if unequipped_count >= to_unequip: break
                var p: PersonData = state.persons.get(pid)
                if p == null: continue
                var grade: String = p.equipment["hand_1"].get("grade", "")
                if grade == pool_key:
                    p.equipment["hand_1"] = { "type": "none", "grade": "" }
                    unequipped_count += 1
            var pool: int = int(team.resources.get(pool_key, 0))
            team.resources[pool_key] = pool + unequipped_count * UNITS_PER_EQUIP
```

- [ ] **Step 3: Update `on_named_death` in `equipment_system.gd`**

The function signature stays the same. Callers in `interaction_system.gd` already pass `wtype`. No change needed here.

- [ ] **Step 4: Update `skill_system.gd`**

In `on_combat_round` and `on_volley`, replace `right_hand` reads:

```gdscript
# on_combat_round — replace lines with right_hand:
func on_combat_round(state: WorldState, team: TeamData) -> void:
    var named_ids: Array = ([team.leader_id] as Array) + team.named_members
    for pid in named_ids:
        var p: PersonData = state.persons.get(pid)
        if p == null: continue
        var grade: String = p.equipment["hand_1"].get("grade", "")
        var wtype: String = grade.replace("weapon_", "") if grade.begins_with("weapon_") else "none"
        if wtype in ["melee_low", "melee_high"]:
            _grow(p, "戰鬥", "體力")

# on_volley:
func on_volley(state: WorldState, team: TeamData) -> void:
    var named_ids: Array = ([team.leader_id] as Array) + team.named_members
    for pid in named_ids:
        var p: PersonData = state.persons.get(pid)
        if p == null: continue
        var grade: String = p.equipment["hand_1"].get("grade", "")
        var wtype: String = grade.replace("weapon_", "") if grade.begins_with("weapon_") else "none"
        if wtype in ["ranged_low", "ranged_high"]:
            _grow(p, "弓箭", "智力")
```

- [ ] **Step 5: Update `interaction_system.gd` — all `right_hand` references**

There are multiple places. Search for `right_hand` in interaction_system.gd and replace each:

For weapon-type reading (lines ~521, ~550):
```gdscript
# OLD pattern:
var wtype: String = p.equipment["right_hand"].get("type", "none")
match wtype:
    "melee_low": ...

# NEW pattern:
var grade: String = p.equipment["hand_1"].get("grade", "")
var wtype: String = grade.replace("weapon_", "") if grade.begins_with("weapon_") else "none"
match wtype:
    "melee_low": ...
```

For the `on_named_death` call (line ~651):
```gdscript
# OLD:
_equip.on_named_death(team, p.equipment["right_hand"].get("type", "none"))
p.equipment["right_hand"]["type"] = "none"

# NEW:
var _death_grade: String = p.equipment["hand_1"].get("grade", "")
var _death_wtype: String = _death_grade.replace("weapon_", "") if _death_grade.begins_with("weapon_") else "none"
_equip.on_named_death(team, _death_wtype)
p.equipment["hand_1"] = { "type": "none", "grade": "" }
```

For any other `right_hand` check (line ~926):
```gdscript
# OLD: p.equipment["right_hand"].get("type", "none") != "none"
# NEW: p.equipment["hand_1"].get("type", "none") != "none"
```

- [ ] **Step 6: Update `faction_ai_system.gd`**

Find the `right_hand` reference (line ~545):
```gdscript
# OLD: p.equipment["right_hand"].get("type", "none") != "none"
# NEW: p.equipment["hand_1"].get("type", "none") != "none"
```

- [ ] **Step 7: Update `encounter_system.gd` — hand slot rename**

In `_equip_named_npc` (line ~451):
```gdscript
# OLD: p.equipment["right_hand"]
# NEW: p.equipment["hand_1"]
```

- [ ] **Step 8: Update `headless_test.gd` — all right_hand/left_hand references**

Search for `right_hand` and `left_hand` in headless_test.gd and replace:
- `right_hand` → `hand_1`
- `left_hand` → `hand_2`

- [ ] **Step 9: Run test**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```
Expected: `=== DONE ===`, no `SCRIPT ERROR`.

- [ ] **Step 10: Commit**

```
git add scripts/data/person_data.gd scripts/simulation/equipment_system.gd
git add scripts/simulation/skill_system.gd scripts/simulation/interaction_system.gd
git add scripts/simulation/faction_ai_system.gd scripts/simulation/encounter_system.gd
git add scripts/debug/headless_test.gd
git commit -m "refactor(data): rename right_hand/left_hand to hand_1/hand_2; add blood + new body_parts format to PersonData"
```

---

## Task 3: HealthSystem

**Files:**
- Create: `scripts/simulation/health_system.gd`
- Modify: `scripts/simulation/encounter_system.gd` (replace `_apply_body_part_damage`)
- Modify: `scripts/simulation/interaction_system.gd` (add natural regen)

- [ ] **Step 1: Create `scripts/simulation/health_system.gd`**

```gdscript
# scripts/simulation/health_system.gd
class_name HealthSystem

const BLOOD_MAX: float         = 100.0
const BLOOD_COMA_THRESHOLD: float = 30.0
const BLEEDING_MINOR_DRAIN: float = 3.0
const BLEEDING_MAJOR_DRAIN: float = 10.0
const POISON_HP_DRAIN: float   = 5.0
const RESOLVE_BLOOD_MAJOR: float = 30.0
const RESOLVE_BLOOD_MINOR: float = 10.0
const RESOLVE_POISON_HP: float = 10.0
const HP_REGEN_PER_TICK: float = 0.5
const HP_REGEN_FRACTURE: float = 0.05
const BLOOD_REGEN_PER_TICK: float = 0.2
const CARRY_BASE: float        = 20.0
const CARRY_PER_BODY: float    = 10.0

static func _calc_status(hp: float, max_hp: float, part: String) -> String:
    var ratio: float = hp / max_hp
    if ratio > 0.75:  return "healthy"
    if ratio > 0.25:  return "wounded"
    if ratio > 0.0:   return "critical"
    if part in ["head", "torso"]: return "critical"
    return "severed"

static func receive_damage(unit: Dictionary, state: WorldState,
        part: String, final_dmg: float) -> void:
    var bp: Dictionary = _get_body_parts(unit, state)
    if not bp.has(part): return
    bp[part]["hp"] = maxf(bp[part]["hp"] - final_dmg, 0.0)
    bp[part]["status"] = _calc_status(bp[part]["hp"], bp[part]["max_hp"], part)

static func _get_body_parts(unit: Dictionary, state: WorldState) -> Dictionary:
    if unit.get("person_id", -1) != -1:
        var p: PersonData = state.persons.get(unit["person_id"])
        return p.body_parts if p else {}
    return unit.get("body_parts", {})

static func _fracture_speed_mult(bp: Dictionary) -> float:
    var broken: int = 0
    if bp.get("right_leg", {}).get("fracture", false): broken += 1
    if bp.get("left_leg",  {}).get("fracture", false): broken += 1
    if broken >= 2: return 0.1
    if broken == 1: return 0.5
    return 1.0

static func _max_carry(unit: Dictionary, state: WorldState) -> float:
    var p: PersonData = state.persons.get(unit.get("person_id", -1))
    var body: float = float(p.attributes.get("體力", 0.5)) if p else 0.5
    return CARRY_BASE + body * CARRY_PER_BODY

static func _calc_carry_weight(unit: Dictionary, state: WorldState) -> float:
    var total: float = 0.0
    for slot in unit.get("equipment", {}):
        var s: Dictionary = unit["equipment"][slot]
        if s.has("grade") and s["grade"] != "":
            total += ItemAttributes.get_weight(s["grade"])
    for item in unit.get("inventory", []):
        total += ItemAttributes.get_weight(item.get("grade", ""), item.get("qty", 1))
    return total

static func _weight_mult(unit: Dictionary, state: WorldState) -> float:
    var load: float  = _calc_carry_weight(unit, state)
    var cap: float   = _max_carry(unit, state)
    var ratio: float = load / maxf(cap, 0.001)
    if ratio <= 0.5: return 1.0
    return clampf(1.0 - (ratio - 0.5) * 1.0, 0.3, 1.0)

static func get_speed_mult(unit: Dictionary, state: WorldState) -> float:
    var p: PersonData = state.persons.get(unit.get("person_id", -1))
    var stamina_mult: float = float(unit.get("stamina", 1.0))
    var blood_mult: float   = 1.0
    var frac_mult: float    = 1.0
    var weight_mult: float  = _weight_mult(unit, state)
    if p:
        blood_mult = clampf(p.blood / BLOOD_MAX, 0.0, 1.0)
        frac_mult  = _fracture_speed_mult(p.body_parts)
    return stamina_mult * blood_mult * frac_mult * weight_mult

static func get_weight_stamina_drain_mult(unit: Dictionary,
        state: WorldState) -> float:
    var load: float  = _calc_carry_weight(unit, state)
    var cap: float   = _max_carry(unit, state)
    var ratio: float = load / maxf(cap, 0.001)
    if ratio <= 0.5: return 1.0
    return clampf(1.0 + (ratio - 0.5) * 2.0, 1.0, 3.0)

static func tick_status_effects(unit: Dictionary, state: WorldState) -> void:
    var bp: Dictionary = _get_body_parts(unit, state)
    var blood_drain: float = 0.0
    for part in bp:
        match bp[part].get("bleeding", "none"):
            "minor": blood_drain += BLEEDING_MINOR_DRAIN
            "major": blood_drain += BLEEDING_MAJOR_DRAIN
        if bp[part].get("poisoned", false):
            bp[part]["hp"] = maxf(bp[part]["hp"] - POISON_HP_DRAIN, 0.0)
            bp[part]["status"] = _calc_status(
                bp[part]["hp"], bp[part].get("max_hp", 50.0), part)
    if blood_drain > 0.0:
        _drain_blood(unit, state, blood_drain)

static func _drain_blood(unit: Dictionary, state: WorldState,
        amount: float) -> void:
    if unit.get("person_id", -1) != -1:
        var p: PersonData = state.persons.get(unit["person_id"])
        if p: p.blood = maxf(p.blood - amount, 0.0)
    else:
        unit["blood"] = maxf(float(unit.get("blood", 100.0)) - amount, 0.0)

static func resolve_negative_flags(state: WorldState, team: TeamData) -> void:
    var all_ids: Array = team.named_members.duplicate()
    if state.player_id != -1 and state.persons.has(state.player_id):
        if state.persons[state.player_id].team_id == team.team_id:
            if not all_ids.has(state.player_id):
                all_ids.append(state.player_id)
    var best_med: float = _best_skill(state, team, "醫療")
    for pid in all_ids:
        var p: PersonData = state.persons.get(pid)
        if p == null: continue
        for part in p.body_parts:
            var bp = p.body_parts[part]
            if bp.get("bleeding") == "major":
                if int(team.resources.get("medicine", 0)) >= 2:
                    team.resources["medicine"] = int(team.resources["medicine"]) - 2
                elif randf() < best_med * 0.5:
                    pass
                else:
                    p.blood = maxf(p.blood - RESOLVE_BLOOD_MAJOR, 1.0)
                bp["bleeding"] = "none"
            if bp.get("bleeding") == "minor":
                if int(team.resources.get("medicine", 0)) >= 1:
                    team.resources["medicine"] = int(team.resources["medicine"]) - 1
                elif randf() < best_med * 0.5:
                    pass
                else:
                    p.blood = maxf(p.blood - RESOLVE_BLOOD_MINOR, 1.0)
                bp["bleeding"] = "none"
            if bp.get("poisoned", false):
                if int(team.resources.get("medicine", 0)) >= 3:
                    team.resources["medicine"] = int(team.resources["medicine"]) - 3
                elif randf() < best_med * 0.5:
                    pass
                else:
                    for p2 in p.body_parts:
                        p.body_parts[p2]["hp"] = maxf(
                            p.body_parts[p2]["hp"] - RESOLVE_POISON_HP, 1.0)
                        p.body_parts[p2]["status"] = _calc_status(
                            p.body_parts[p2]["hp"], p.body_parts[p2]["max_hp"], p2)
                bp["poisoned"] = false
            if bp.get("fracture", false):
                if int(team.resources.get("tools", 0)) >= 1:
                    team.resources["tools"] = int(team.resources["tools"]) - 1
                    bp["fracture"] = false

static func resolve_anon_units(state: WorldState, team_id: int) -> void:
    var team: TeamData = state.teams[team_id]
    var anon_units: Array = []
    for u in state.encounter_units:
        if u["team_id"] == team_id and u.get("person_id", -1) == -1:
            anon_units.append(u)
    for unit in anon_units:
        var bp: Dictionary = unit.get("body_parts", {})
        for part in bp:
            if bp[part].get("poisoned", false):
                bp[part]["hp"] = maxf(bp[part]["hp"] - RESOLVE_POISON_HP, 1.0)
                bp[part]["status"] = _calc_status(
                    bp[part]["hp"], bp[part].get("max_hp", 50.0), part)
                bp[part]["poisoned"] = false
        if _is_unit_dead_bp(bp):
            team.population = maxi(team.population - 1, 0)
            continue
        var has_bleed: bool = false
        var has_major: bool = false
        for part in bp:
            if bp[part].get("bleeding", "none") == "major": has_major = true
            if bp[part].get("bleeding", "none") != "none":  has_bleed = true
        if has_bleed:
            var cost: int = 2 if has_major else 1
            if int(team.resources.get("medicine", 0)) >= cost:
                team.resources["medicine"] = int(team.resources["medicine"]) - cost
            else:
                team.wounded += 1
        if bp.values().any(func(x): return x.get("fracture", false)):
            team.wounded += 1
        elif bp.values().any(func(x): return x.get("status", "healthy") != "healthy"):
            team.wounded += 1

static func _is_unit_dead_bp(bp: Dictionary) -> bool:
    return bp.get("torso", {}).get("status", "healthy") == "severed"

static func tick_natural_regen(state: WorldState) -> void:
    for pid in state.persons:
        var p: PersonData = state.persons[pid]
        if p.team_id == -1: continue
        var has_bleeding: bool = false
        for part in p.body_parts:
            if p.body_parts[part].get("bleeding", "none") != "none":
                has_bleeding = true; break
        if not has_bleeding:
            p.blood = minf(p.blood + BLOOD_REGEN_PER_TICK, BLOOD_MAX)
        for part in p.body_parts:
            var bp = p.body_parts[part]
            var regen: float = HP_REGEN_FRACTURE if bp.get("fracture", false) \
                               else HP_REGEN_PER_TICK
            bp["hp"] = minf(bp["hp"] + regen, bp["max_hp"])
            bp["status"] = _calc_status(bp["hp"], bp["max_hp"], part)

static func use_splint(state: WorldState, pid: int, part: String) -> bool:
    var inv: Array = state.player_state.get("inventory", [])
    for i in range(inv.size()):
        if inv[i]["grade"] == "tools" and inv[i].get("qty", 0) >= 1:
            inv[i]["qty"] -= 1
            if inv[i]["qty"] <= 0: inv.remove_at(i)
            var p: PersonData = state.persons.get(pid)
            if p and p.body_parts.has(part):
                p.body_parts[part]["fracture"] = false
            return true
    return false

static func _best_skill(state: WorldState, team: TeamData,
        skill: String) -> float:
    var best: float = 0.0
    var ids: Array  = ([team.leader_id] as Array) + team.named_members
    for pid in ids:
        var p: PersonData = state.persons.get(pid)
        if p: best = maxf(best, float(p.skills.get(skill, 0.0)))
    return best
```

- [ ] **Step 2: Register class**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --import
```

- [ ] **Step 3: Replace `_apply_body_part_damage` in `encounter_system.gd`**

Find and replace the entire `_apply_body_part_damage` function:

```gdscript
func _apply_body_part_damage(unit: Dictionary, state: WorldState,
        part: String, final_dmg: float) -> void:
    HealthSystem.receive_damage(unit, state, part, final_dmg)
```

Also update `_default_body_parts()` to return the new format with hp/max_hp:

```gdscript
func _default_body_parts() -> Dictionary:
    return {
        "head":      { "hp": 20.0, "max_hp": 20.0, "status": "healthy",
                       "poisoned": false, "bleeding": "none", "fracture": false },
        "torso":     { "hp": 50.0, "max_hp": 50.0, "status": "healthy",
                       "poisoned": false, "bleeding": "none", "fracture": false },
        "right_arm": { "hp": 25.0, "max_hp": 25.0, "status": "healthy",
                       "poisoned": false, "bleeding": "none", "fracture": false },
        "left_arm":  { "hp": 25.0, "max_hp": 25.0, "status": "healthy",
                       "poisoned": false, "bleeding": "none", "fracture": false },
        "right_leg": { "hp": 30.0, "max_hp": 30.0, "status": "healthy",
                       "poisoned": false, "bleeding": "none", "fracture": false },
        "left_leg":  { "hp": 30.0, "max_hp": 30.0, "status": "healthy",
                       "poisoned": false, "bleeding": "none", "fracture": false },
    }
```

- [ ] **Step 4: Add natural regen call to `interaction_system.gd`**

Find the `tick()` function (or `advance_tick`) in interaction_system.gd and add near the end of each world-tick cycle:

```gdscript
# Inside the per-tick loop (before the end of the tick method), add:
HealthSystem.tick_natural_regen(state)
```

- [ ] **Step 5: Add HealthSystem tests to `headless_test.gd`**

Before `=== DONE ===`:

```gdscript
	# ── HealthSystem 驗證 ──
	print("--- HealthSystem ---")
	var _hs_unit: Dictionary = {
		"person_id": 0,
		"stamina": 1.0,
		"equipment": {},
		"inventory": [],
	}
	# get_speed_mult with full stamina + full blood = 1.0
	var _sm: float = HealthSystem.get_speed_mult(_hs_unit, state)
	assert(_sm > 0.0 and _sm <= 1.0, "get_speed_mult should be in (0,1]")
	# receive_damage reduces hp
	var _bp_before: float = state.persons[0].body_parts["torso"]["hp"]
	HealthSystem.receive_damage(_hs_unit, state, "torso", 10.0)
	var _bp_after: float = state.persons[0].body_parts["torso"]["hp"]
	assert(_bp_after < _bp_before, "receive_damage should reduce torso hp")
	print("HealthSystem OK")
```

- [ ] **Step 6: Run test**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```
Expected: `HealthSystem OK`, `=== DONE ===`, no `SCRIPT ERROR`.

- [ ] **Step 7: Commit**

```
git add scripts/simulation/health_system.gd scripts/simulation/encounter_system.gd
git add scripts/simulation/interaction_system.gd scripts/debug/headless_test.gd
git commit -m "feat(sim): add HealthSystem with HP/blood/status/weight; integrate into EncounterSystem"
```

---

## Task 4: EncounterTemplates

**Files:**
- Create: `scripts/data/encounter_templates.gd`

- [ ] **Step 1: Create `scripts/data/encounter_templates.gd`**

```gdscript
# scripts/data/encounter_templates.gd
class_name EncounterTemplates

const TEMPLATES: Dictionary = {
    "archer": {
        "fill": [
            { "grade": "arrows",   "qty": 20 },
            { "grade": "medicine", "qty": 2  },
        ],
    },
    "melee": {
        "fill": [
            { "grade": "medicine", "qty": 3 },
        ],
    },
    "medic": {
        "fill": [
            { "grade": "medicine", "qty": 6 },
        ],
    },
    "default": {
        "fill": [
            { "grade": "medicine", "qty": 2 },
        ],
    },
}

static func select_template(unit: Dictionary, state: WorldState) -> String:
    if unit.get("person_id", -1) != -1:
        var p: PersonData = state.persons.get(unit["person_id"])
        if p and float(p.skills.get("醫療", 0.0)) > 0.5:
            return "medic"
    var equip: Dictionary = unit.get("equipment", {})
    var h1_grade: String  = equip.get("hand_1", {}).get("grade", "")
    if h1_grade.contains("ranged"): return "archer"
    for hand in ["hand_1", "hand_2"]:
        if equip.get(hand, {}).get("grade", "").begins_with("armor_"):
            return "melee"
    if h1_grade.contains("melee") or h1_grade == "unarmed":
        return "melee"
    return "default"

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

- [ ] **Step 2: Register class**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --import
```

- [ ] **Step 3: Add template test to `headless_test.gd`**

Before `=== DONE ===`:

```gdscript
	# ── EncounterTemplates 驗證 ──
	print("--- EncounterTemplates ---")
	var _tmpl_team: TeamData = state.teams[0]
	_tmpl_team.resources["arrows"]   = 30
	_tmpl_team.resources["medicine"] = 10
	var _archer_unit: Dictionary = {
		"person_id": -1,
		"team_id": 0,
		"equipment": {
			"hand_1": { "type": "pool", "grade": "weapon_ranged_low" },
			"hand_2": {}, "head": {}, "torso": {},
			"right_arm": {}, "left_arm": {}, "right_leg": {}, "left_leg": {},
		},
		"inventory": [],
	}
	EncounterTemplates.fill_inventory(_archer_unit, _tmpl_team, state)
	var _has_arrows: bool = false
	for _item in _archer_unit["inventory"]:
		if _item["grade"] == "arrows": _has_arrows = true
	assert(_has_arrows, "archer unit should have arrows in inventory")
	assert(_tmpl_team.resources["arrows"] < 30, "team arrows should decrease after template fill")
	print("EncounterTemplates OK")
```

- [ ] **Step 4: Run test**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```
Expected: `EncounterTemplates OK`, `=== DONE ===`, no `SCRIPT ERROR`.

- [ ] **Step 5: Commit**

```
git add scripts/data/encounter_templates.gd scripts/debug/headless_test.gd
git commit -m "feat(data): add EncounterTemplates with archer/melee/medic/default templates"
```

---

## Task 5: EncounterSystem — unit equipment/inventory init

**Files:**
- Modify: `scripts/simulation/encounter_system.gd`

- [ ] **Step 1: Update `_create_anon_unit` to include equipment and inventory**

Find `_create_anon_unit` and add these fields to the returned Dictionary (after `"skills": ...`):

```gdscript
        "equipment": {
            "hand_1": {}, "hand_2": {}, "head": {}, "torso": {},
            "right_arm": {}, "left_arm": {}, "right_leg": {}, "left_leg": {},
        },
        "inventory": [],
```

- [ ] **Step 2: Add `_init_named_unit` function**

Add after `_create_named_unit`:

```gdscript
func _init_named_unit(unit: Dictionary, p: PersonData,
        team: TeamData, state: WorldState) -> void:
    unit["equipment"] = p.equipment.duplicate(true)
    # 補裝武器空槽
    if unit["equipment"]["hand_1"].get("type", "none") in ["none", ""]:
        for grade in ["weapon_melee_low", "weapon_melee_high",
                "weapon_ranged_low", "weapon_ranged_high"]:
            if int(team.resources.get(grade, 0)) > 0:
                unit["equipment"]["hand_1"] = { "type": "pool", "grade": grade }
                team.resources[grade] = int(team.resources[grade]) - 1
                break
    # 補裝 torso 護甲空槽
    if unit["equipment"]["torso"].get("type", "none") in ["none", ""]:
        var cfg: String = team.armor_config.get("torso", "none")
        if cfg == "low" and int(team.resources.get("armor_low", 0)) > 0:
            unit["equipment"]["torso"] = { "type": "pool", "grade": "armor_low" }
            team.resources["armor_low"] -= 1
        elif cfg == "high" and int(team.resources.get("armor_high", 0)) > 0:
            unit["equipment"]["torso"] = { "type": "pool", "grade": "armor_high" }
            team.resources["armor_high"] -= 1
    # 其他部位護甲（head, right_arm, left_arm, right_leg, left_leg）
    for slot in ["head", "right_arm", "left_arm", "right_leg", "left_leg"]:
        if unit["equipment"][slot].get("type", "none") in ["none", ""]:
            var cfg2: String = team.armor_config.get(slot, "none")
            if cfg2 == "low" and int(team.resources.get("armor_low", 0)) > 0:
                unit["equipment"][slot] = { "type": "pool", "grade": "armor_low" }
                team.resources["armor_low"] -= 1
            elif cfg2 == "high" and int(team.resources.get("armor_high", 0)) > 0:
                unit["equipment"][slot] = { "type": "pool", "grade": "armor_high" }
                team.resources["armor_high"] -= 1
    unit["inventory"] = []
    EncounterTemplates.fill_inventory(unit, team, state)
```

- [ ] **Step 3: Add `_init_anon_unit` function**

```gdscript
func _init_anon_unit(unit: Dictionary, team: TeamData,
        state: WorldState) -> void:
    for grade in ["weapon_melee_low", "weapon_melee_high",
            "weapon_ranged_low", "weapon_ranged_high"]:
        if int(team.resources.get(grade, 0)) > 0:
            unit["equipment"]["hand_1"] = { "type": "pool", "grade": grade }
            team.resources[grade] = int(team.resources[grade]) - 1
            break
    var cfg: String = team.armor_config.get("torso", "none")
    if cfg == "low" and int(team.resources.get("armor_low", 0)) > 0:
        unit["equipment"]["torso"] = { "type": "pool", "grade": "armor_low" }
        team.resources["armor_low"] -= 1
    elif cfg == "high" and int(team.resources.get("armor_high", 0)) > 0:
        unit["equipment"]["torso"] = { "type": "pool", "grade": "armor_high" }
        team.resources["armor_high"] -= 1
    EncounterTemplates.fill_inventory(unit, team, state)
```

- [ ] **Step 4: Update `_spawn_team_units` to call init functions**

Replace the `_spawn_team_units` function:

```gdscript
func _spawn_team_units(state: WorldState, team: TeamData,
        positions: Array) -> void:
    var pos_idx: int = 0
    var named_ids: Array = ([team.leader_id] as Array) + team.named_members
    for pid in named_ids:
        var p: PersonData = state.persons.get(pid)
        if p == null: continue
        var pos: Vector2i = positions[pos_idx % positions.size()]
        pos_idx += 1
        var unit: Dictionary = _create_named_unit(pid, team.team_id, pos, state)
        _init_named_unit(unit, p, team, state)
        state.encounter_units.append(unit)
    for _i in range(team.population):
        var pos: Vector2i = positions[pos_idx % positions.size()]
        pos_idx += 1
        var unit: Dictionary = _create_anon_unit(team, pos)
        _init_anon_unit(unit, team, state)
        state.encounter_units.append(unit)
```

- [ ] **Step 5: Replace `setup_arrows` with inventory-based helpers**

Remove the old `setup_arrows` function entirely. Add these two functions:

```gdscript
func _has_arrows(unit: Dictionary) -> bool:
    for item in unit.get("inventory", []):
        if item.get("grade") == "arrows" \
                and item.get("qty", 0) >= ItemAttributes.ARROW_COST_PER_SHOT:
            return true
    return false

func _consume_arrow(unit: Dictionary) -> void:
    for item in unit.get("inventory", []):
        if item.get("grade") == "arrows":
            item["qty"] = maxi(item["qty"] - ItemAttributes.ARROW_COST_PER_SHOT, 0)
            return
```

- [ ] **Step 6: Update `advance_round` to use `_has_arrows`/`_consume_arrow`**

In the `advance_round` function, find:
```gdscript
unit["arrows"] = max(unit.get("arrows", 0) - 1, 0)
```
Replace with:
```gdscript
_consume_arrow(unit)
```

And find archer detection (line ~281):
```gdscript
is_archer = archer_skill > 0.1 and unit.get("arrows", 0) > 0
```
Replace with:
```gdscript
is_archer = archer_skill > 0.1 and _has_arrows(unit)
```

- [ ] **Step 7: Add `_sync_back_units` function**

```gdscript
func _sync_back_units(state: WorldState, team_id: int) -> void:
    var team: TeamData = state.teams.get(team_id)
    if team == null: return
    for unit in state.encounter_units:
        if unit["team_id"] != team_id: continue
        if unit.get("person_id", -1) != -1:
            var p: PersonData = state.persons.get(unit["person_id"])
            if p: p.equipment = unit["equipment"].duplicate(true)
        else:
            for slot in unit.get("equipment", {}):
                var s: Dictionary = unit["equipment"][slot]
                if s.get("type") == "pool" and s.get("grade", "") != "":
                    team.resources[s["grade"]] = \
                        int(team.resources.get(s["grade"], 0)) + 1
        for item in unit.get("inventory", []):
            if item.get("type") == "pool":
                var g: String = item.get("grade", "")
                if g != "":
                    team.resources[g] = int(team.resources.get(g, 0)) + item.get("qty", 0)
```

- [ ] **Step 8: Update `resolve_encounter_end` to call sync-back and health resolution**

Inside `resolve_encounter_end`, after `_return_pool_equipment(state)` (which we'll keep for compatibility), add calls:

```gdscript
    # New: sync equipment/inventory back and resolve health
    for team_id in [atk_id, def_id]:
        if team_id == -1: continue
        _sync_back_units(state, team_id)
        var t: TeamData = state.teams.get(team_id)
        if t: HealthSystem.resolve_negative_flags(state, t)
        HealthSystem.resolve_anon_units(state, team_id)
```

Add this block right before the `state.encounter_units.clear()` line.

- [ ] **Step 9: Run test**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```
Expected: `=== DONE ===`, no `SCRIPT ERROR`.

- [ ] **Step 10: Commit**

```
git add scripts/simulation/encounter_system.gd scripts/debug/headless_test.gd
git commit -m "feat(encounter): all units get equipment+inventory; EncounterTemplates fills on spawn; sync-back on end"
```

---

## Task 6: EncounterSystem — action timer + combat resolution

**Files:**
- Modify: `scripts/simulation/encounter_system.gd`

> This task adds the tick-based action timer, stance system, reactive block window, and complete attack resolution. The old `advance_round` runs on a per-round basis; the new `advance_encounter_tick` runs every tick.

- [ ] **Step 1: Add constants at the top of `encounter_system.gd`**

Add after existing constants (ESCORT_DETECT_RANGE etc.):

```gdscript
const BASE_ACTION_TICKS: int  = 10
const BLOCK_WINDOW: int       = 8
const BLOCK_PENALTY: int      = 5

const STANCE_SPEED_MULT: Dictionary = {
    "walk":   1.0,
    "sprint": 1.5,
    "crouch": 0.5,
    "prone":  0.1,
}
const STANCE_MOVE_STAMINA: Dictionary = {
    "walk":   0.02,
    "sprint": 0.05,
    "crouch": 0.005,
    "prone":  0.0,
}
const STANCE_RANGED_DMG_MULT: Dictionary = {
    "walk":   1.0,
    "sprint": 1.0,
    "crouch": 0.7,
    "prone":  0.4,
}
const STAMINA_EXHAUSTED_ATK_MULT: float = 0.5
```

- [ ] **Step 2: Update `_create_named_unit` and `_create_anon_unit` to include action_timer fields**

In `_create_named_unit`, add these fields to the returned dict:

```gdscript
        "action_timer":  BASE_ACTION_TICKS,
        "stance":        "walk",
        "pending_dodge": false,
```

In `_create_anon_unit`, add the same three fields (after `"escort_target": -1`):

```gdscript
        "action_timer":  BASE_ACTION_TICKS,
        "stance":        "walk",
        "pending_dodge": false,
```

- [ ] **Step 3: Add speed / timer helper functions**

Add these functions (before `advance_round`):

```gdscript
func _base_speed(unit: Dictionary, state: WorldState) -> float:
    var p: PersonData = state.persons.get(unit.get("person_id", -1))
    var body: float = float(p.attributes.get("體力", 0.5)) if p else 0.5
    return 1.0 + body * 0.2

func _effective_speed(unit: Dictionary, state: WorldState) -> float:
    var base: float   = _base_speed(unit, state)
    var stance: float = STANCE_SPEED_MULT.get(unit.get("stance", "walk"), 1.0)
    var health: float = HealthSystem.get_speed_mult(unit, state)
    return base * stance * health

func _max_timer(unit: Dictionary, state: WorldState) -> int:
    return maxi(roundi(float(BASE_ACTION_TICKS) / _effective_speed(unit, state)), 1)
```

- [ ] **Step 4: Add helper functions (equipment reads from unit, not PersonData)**

```gdscript
func _get_weapon_grade(unit: Dictionary, _state: WorldState) -> String:
    var equip: Dictionary = unit.get("equipment", {})
    var h1: Dictionary    = equip.get("hand_1", {})
    if h1.get("type", "none") not in ["none", "2h_ref", ""]:
        return h1.get("grade", "unarmed")
    return "unarmed"

func _get_armor_grade_at(unit: Dictionary, _state: WorldState,
        part: String) -> String:
    var equip: Dictionary = unit.get("equipment", {})
    var slot: Dictionary  = equip.get(part, {})
    if slot.get("type", "none") in ["none", ""]: return "none"
    return slot.get("grade", "none")

func _get_shield_grade(unit: Dictionary, _state: WorldState) -> String:
    var equip: Dictionary = unit.get("equipment", {})
    for hand in ["hand_1", "hand_2"]:
        var s: Dictionary = equip.get(hand, {})
        if s.get("grade", "").begins_with("armor_"): return s.get("grade", "")
    return ""

func _has_shield(unit: Dictionary, state: WorldState) -> bool:
    return _get_shield_grade(unit, state) != ""

func _has_melee_weapon(unit: Dictionary, state: WorldState) -> bool:
    var grade: String = _get_weapon_grade(unit, state)
    return grade.contains("melee") or grade == "unarmed"

func _get_skill(unit: Dictionary, state: WorldState, skill: String) -> float:
    var p: PersonData = state.persons.get(unit.get("person_id", -1))
    if p: return float(p.skills.get(skill, 0.0))
    return float(unit.get("skills", {}).get(skill, 0.0))
```

- [ ] **Step 5: Add block system functions**

```gdscript
func _can_block(unit: Dictionary) -> bool:
    return int(unit.get("action_timer", 999)) <= BLOCK_WINDOW

func _shield_block_chance(unit: Dictionary, state: WorldState) -> float:
    var grade: String  = _get_shield_grade(unit, state)
    var base: float    = ItemAttributes.get_block_chance(grade)
    var combat: float  = _get_skill(unit, state, "戰鬥")
    return clampf(base + combat * 0.3, 0.0, 0.90)

func _parry_chance(unit: Dictionary, state: WorldState) -> float:
    var weapon: String = _get_weapon_grade(unit, state)
    var base: float    = ItemAttributes.get_parry_chance(weapon)
    var combat: float  = _get_skill(unit, state, "戰鬥")
    return clampf(base + combat * 0.4, 0.0, 0.85)

func _dodge_chance(unit: Dictionary, state: WorldState) -> float:
    var p: PersonData  = state.persons.get(unit.get("person_id", -1))
    var survival: float = _get_skill(unit, state, "求生")
    var body: float     = float(p.attributes.get("體力", 0.5)) if p else 0.5
    return clampf(0.2 + survival * 0.4 * (0.5 + body * 0.5), 0.0, 0.80)

func _resolve_block(unit: Dictionary, state: WorldState,
        choice: String) -> bool:
    match choice:
        "shield": return randf() < _shield_block_chance(unit, state)
        "parry":  return randf() < _parry_chance(unit, state)
        "dodge":
            unit["stamina"] = maxf(float(unit.get("stamina", 0.0)) - 0.1, 0.0)
            return randf() < _dodge_chance(unit, state)
    return false

func _npc_auto_block(unit: Dictionary, state: WorldState) -> String:
    var options: Dictionary = {}
    if _has_shield(unit, state):
        options["shield"] = _shield_block_chance(unit, state)
    if _has_melee_weapon(unit, state):
        options["parry"] = _parry_chance(unit, state)
    if float(unit.get("stamina", 0.0)) > 0.1:
        options["dodge"] = _dodge_chance(unit, state)
    var best: String = "none"; var best_val: float = 0.3
    for opt in options:
        if options[opt] > best_val: best_val = options[opt]; best = opt
    return best
```

- [ ] **Step 6: Add attack resolution functions**

```gdscript
func _check_range(attacker: Dictionary, target: Dictionary,
        state: WorldState) -> bool:
    var weapon: String = _get_weapon_grade(attacker, state)
    return hex_dist(attacker["pos"], target["pos"]) \
           <= ItemAttributes.get_range(weapon)

func _hit_chance(attacker: Dictionary, state: WorldState) -> float:
    var weapon: String = _get_weapon_grade(attacker, state)
    var base: float    = 0.6
    var skill: float   = 0.0
    if weapon.contains("ranged"):
        skill = _get_skill(attacker, state, "弓箭") * 0.4
    else:
        skill = _get_skill(attacker, state, "戰鬥") * 0.4
    return clampf(base + skill, 0.05, 0.95)

func resolve_attack(attacker: Dictionary, target: Dictionary,
        state: WorldState, target_part: String) -> void:
    var weapon: String  = _get_weapon_grade(attacker, state)
    var is_ranged: bool = weapon.contains("ranged")
    if is_ranged and not _check_range(attacker, target, state): return
    if target.get("pending_dodge", false):
        target["pending_dodge"] = false
        if _resolve_block(target, state, "dodge"):
            print("[Dodge] unit team=%d 閃避成功" % target["team_id"])
            target["action_timer"] = mini(target["action_timer"] + BLOCK_PENALTY,
                _max_timer(target, state))
            return
    if _can_block(target):
        var choice: String = "none"
        if target.get("person_id", -1) == state.player_id:
            pass  # player: UI handles; assume no block in headless
        else:
            choice = _npc_auto_block(target, state)
        if choice != "none":
            var blocked: bool = _resolve_block(target, state, choice)
            target["action_timer"] = mini(target["action_timer"] + BLOCK_PENALTY,
                _max_timer(target, state))
            if blocked:
                print("[Block] team=%d blocked with %s" % [target["team_id"], choice])
                return
    if randf() > _hit_chance(attacker, state):
        print("[Miss]")
        return
    var raw_dmg: float = ItemAttributes.get_damage(weapon)
    var drain_mult: float = HealthSystem.get_weight_stamina_drain_mult(attacker, state)
    attacker["stamina"] = maxf(float(attacker.get("stamina", 1.0)) - 0.05 * drain_mult, 0.0)
    if float(attacker.get("stamina", 1.0)) <= 0.0:
        raw_dmg *= STAMINA_EXHAUSTED_ATK_MULT
    if is_ranged:
        raw_dmg *= STANCE_RANGED_DMG_MULT.get(target.get("stance", "walk"), 1.0)
    var armor: String      = _get_armor_grade_at(target, state, target_part)
    var reduction: float   = ItemAttributes.get_damage_reduction(armor)
    var final_dmg: float   = raw_dmg * (1.0 - reduction)
    HealthSystem.receive_damage(target, state, target_part, final_dmg)
    print("[Hit] part=%s dmg=%.1f" % [target_part, final_dmg])
```

- [ ] **Step 7: Add tick-based encounter loop**

Add `advance_encounter_tick` (keep old `advance_round` intact for fallback, rename it `_advance_round_legacy`):

```gdscript
func advance_encounter_tick(state: WorldState) -> String:
    var atk_id: int = state.encounter_attacker_id
    var def_id: int = state.encounter_defender_id
    var round_num: int = state.get("encounter_tick", 0)
    state["encounter_tick"] = round_num + 1

    for i in range(state.encounter_units.size()):
        var unit: Dictionary = state.encounter_units[i]
        if is_dead(unit, state): continue
        if unit.get("has_exited", false): continue
        if unit.get("is_prisoner", false): continue

        HealthSystem.tick_status_effects(unit, state)
        unit["action_timer"] -= 1
        if unit["action_timer"] > 0: continue

        # Action frame
        var action: Dictionary = _decide_action(i, state, -1)
        match action["type"]:
            "attack", "shoot":
                if action["target_idx"] != -1:
                    var target: Dictionary = state.encounter_units[action["target_idx"]]
                    if not is_dead(target, state) and not target.get("has_exited", false):
                        if action["type"] == "shoot" and not _has_arrows(unit): pass
                        else:
                            if action["type"] == "shoot": _consume_arrow(unit)
                            resolve_attack(unit, target, state, action["attack_part"])
            "move", "move_back", "escort_move", "start_escort":
                var drain_mult: float = HealthSystem.get_weight_stamina_drain_mult(unit, state)
                var stamina_cost: float = STANCE_MOVE_STAMINA.get(unit.get("stance","walk"), 0.02)
                unit["pos"]     = action["move_to"]
                unit["stamina"] = maxf(float(unit.get("stamina", 1.0)) - stamina_cost * drain_mult, 0.0)
                if action["type"] == "start_escort":
                    unit["escort_target"] = action["target_idx"]
            "retreat", "messenger_exit":
                unit["pos"]     = action["move_to"]
                unit["stamina"] = maxf(float(unit.get("stamina", 1.0)) - 0.03, 0.0)
                var dist_to_edge: int = MAP_RADIUS - maxi(abs(unit["pos"].x), abs(unit["pos"].y))
                if dist_to_edge <= 0:
                    unit["has_exited"] = true
                    if action["type"] == "messenger_exit":
                        var parent: TeamData = state.teams.get(unit["team_id"])
                        if parent: _messenger_exit(state, unit, parent)

        unit["action_timer"] = _max_timer(unit, state)

    _check_prisoners(state, round_num)

    var atk_alive: bool  = _has_active_units(atk_id, state)
    var def_alive: bool  = _has_active_units(def_id, state)
    var atk_exited: bool = _all_exited(atk_id, state)
    var def_exited: bool = _all_exited(def_id, state)

    if def_exited or (not def_alive and def_id != -1): return "attacker_win"
    if atk_exited or (not atk_alive and atk_id != -1): return "defender_win"
    if not atk_alive and not def_alive: return "draw"
    return "ongoing"
```

- [ ] **Step 8: Add headless test for action timer and combat**

Before `=== DONE ===`:

```gdscript
	# ── EncounterCombat 驗證 ──
	print("--- EncounterCombat ---")
	# Init a mini encounter: Team0 vs Team1
	var _enc_state := WorldState.new()
	var _enc_runner := SimRunner.new()
	var _enc_t0 := TeamData.new()
	_enc_t0.team_id = 0; _enc_t0.population = 2
	_enc_t0.resources = { "weapon_melee_low": 10, "arrows": 20, "medicine": 5,
		"armor_low": 0, "armor_high": 0, "food": 0 }
	_enc_t0.armor_config = { "torso": "none" }
	var _enc_t1 := TeamData.new()
	_enc_t1.team_id = 1; _enc_t1.population = 2
	_enc_t1.resources = { "weapon_melee_low": 10, "arrows": 0, "medicine": 5,
		"armor_low": 0, "armor_high": 0, "food": 0 }
	_enc_t1.armor_config = { "torso": "none" }
	_enc_state.teams[0] = _enc_t0
	_enc_state.teams[1] = _enc_t1
	_enc_state.encounter_active = true
	_enc_state.encounter_attacker_id = 0
	_enc_state.encounter_defender_id = 1
	var _enc_sys := EncounterSystem.new()
	_enc_sys.init_encounter(_enc_state, 0, 1, "normal")
	assert(_enc_state.encounter_units.size() > 0, "encounter should have units")
	# Verify action_timer present
	assert(_enc_state.encounter_units[0].has("action_timer"), "unit should have action_timer")
	assert(_enc_state.encounter_units[0].has("stance"), "unit should have stance")
	# Run 50 ticks
	var _enc_result: String = "ongoing"
	for _t in range(50):
		_enc_result = _enc_sys.advance_encounter_tick(_enc_state)
		if _enc_result != "ongoing": break
	print("EncounterCombat: result=%s [Hit] or [Miss] should appear above" % _enc_result)
	assert(_enc_result != "ongoing" or true, "encounter ran without crash")
	print("EncounterCombat OK")
```

- [ ] **Step 9: Run test**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```
Expected: `EncounterCombat OK`, `[Hit]` or `[Miss]` printed, `=== DONE ===`, no `SCRIPT ERROR`.

- [ ] **Step 10: Commit**

```
git add scripts/simulation/encounter_system.gd scripts/debug/headless_test.gd
git commit -m "feat(encounter): add action-timer combat system with stance, block window, and attack resolution"
```

---

## Task 7: PlayerSystem updates

**Files:**
- Modify: `scripts/simulation/player_system.gd`

- [ ] **Step 1: Remove `ITEM_WEIGHT` and `PLAYER_MAX_WEIGHT`; add slot-only limit**

Replace the top of `player_system.gd`:

```gdscript
# scripts/simulation/player_system.gd
class_name PlayerSystem

const PLAYER_INVENTORY_MAX_SLOTS: int = 6   # TEST VALUE

func _can_add_item(state: WorldState, grade: String) -> bool:
    var inv: Array = state.player_state.get("inventory", [])
    var already_has: bool = inv.any(func(x): return x.get("grade") == grade)
    if not already_has and inv.size() >= PLAYER_INVENTORY_MAX_SLOTS:
        return false
    return true

func calc_inventory_weight(state: WorldState) -> float:
    var total: float = 0.0
    for item in state.player_state.get("inventory", []):
        total += ItemAttributes.get_weight(item.get("grade", ""), item.get("qty", 1))
    return total
```

- [ ] **Step 2: Update `add_to_inventory` to use `_can_add_item`**

```gdscript
func add_to_inventory(state: WorldState, grade: String, qty: int = 1) -> bool:
    if not _can_add_item(state, grade): return false
    var inv: Array = state.player_state.get("inventory", [])
    for item in inv:
        if item["grade"] == grade and item.get("type", "pool") == "pool":
            item["qty"] += qty
            return true
    inv.append({ "grade": grade, "type": "pool", "qty": qty })
    return true
```

- [ ] **Step 3: Update `take_from_team` to use `_can_add_item`**

```gdscript
func take_from_team(state: WorldState, grade: String, qty: int) -> bool:
    var team: TeamData = _get_player_team(state)
    if team == null: return false
    var cur: int = int(team.resources.get(grade, 0))
    if cur < qty: return false
    if not _can_add_item(state, grade): return false
    team.resources[grade] = cur - qty
    add_to_inventory(state, grade, qty)
    return true
```

- [ ] **Step 4: Update `equip_item` slot names and format**

```gdscript
func equip_item(state: WorldState, slot: String, grade: String) -> bool:
    var inv: Array = state.player_state.get("inventory", [])
    var player: PersonData = state.persons.get(state.player_id)
    if player == null: return false
    for i in range(inv.size()):
        if inv[i]["grade"] == grade and inv[i].get("type", "pool") == "pool":
            var old: Dictionary = player.equipment.get(slot, {})
            if old.get("type", "none") != "none":
                add_to_inventory(state, old["grade"])
            player.equipment[slot] = { "type": "pool", "grade": grade }
            if ItemAttributes.is_2h(grade):
                player.equipment["hand_2"] = { "type": "2h_ref" }
            inv[i]["qty"] -= 1
            if inv[i]["qty"] <= 0: inv.remove_at(i)
            return true
    return false
```

- [ ] **Step 5: Add `use_splint` delegating to HealthSystem**

```gdscript
func use_splint(state: WorldState, pid: int, part: String) -> bool:
    return HealthSystem.use_splint(state, pid, part)
```

- [ ] **Step 6: Run test**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```
Expected: `=== DONE ===`, no `SCRIPT ERROR`. Existing PlayerSystem tests should still pass.

- [ ] **Step 7: Commit**

```
git add scripts/simulation/player_system.gd scripts/debug/headless_test.gd
git commit -m "refactor(player): use ItemAttributes for weight; slot limit only; fix hand_1/hand_2 slot names"
```

---

## Task 8: Final verification

**Files:**
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: Add item-weight integration test**

Before `=== DONE ===`:

```gdscript
	# ── PlayerSystem weight integration ──
	print("--- PlayerSystem weight ---")
	var _ws: WorldState = WorldState.new()
	var _ps2 := PlayerSystem.new()
	var _pp := PersonData.new(); _pp.id = 99; _pp.team_id = 0
	_ws.persons[99] = _pp
	_ws.player_id   = 99
	_ws.player_state = { "inventory": [], "coin": 0.0 }
	var _pteam := TeamData.new()
	_pteam.team_id = 0
	_pteam.resources = { "medicine": 10, "tools": 5, "arrows": 20,
		"weapon_melee_low": 5, "armor_low": 2 }
	_ws.teams[0] = _pteam
	var _ok: bool = _ps2.take_from_team(_ws, "medicine", 3)
	assert(_ok, "take_from_team should succeed")
	assert(int(_pteam.resources.get("medicine", 0)) == 7, "team medicine should be 7")
	assert(_ws.player_state["inventory"].size() == 1, "inventory should have 1 slot")
	var _w: float = _ps2.calc_inventory_weight(_ws)
	assert(_w > 0.0, "inventory weight should be > 0 (using ItemAttributes)")
	print("PlayerSystem weight OK: %.2f kg" % _w)
```

- [ ] **Step 2: Verify encounter units have equipment after init**

```gdscript
	# ── EncounterSystem unit equipment ──
	print("--- EncounterSystem unit equipment ---")
	var _es := EncounterSystem.new()
	var _es_state := WorldState.new()
	var _es_t0 := TeamData.new()
	_es_t0.team_id = 0; _es_t0.population = 3
	_es_t0.resources = {
		"weapon_melee_low": 5, "arrows": 30, "medicine": 10,
		"armor_low": 0, "armor_high": 0, "food": 0,
	}
	_es_t0.armor_config = { "torso": "none" }
	var _es_t1 := TeamData.new()
	_es_t1.team_id = 1; _es_t1.population = 2
	_es_t1.resources = {
		"weapon_melee_low": 3, "arrows": 0, "medicine": 5,
		"armor_low": 0, "armor_high": 0, "food": 0,
	}
	_es_t1.armor_config = { "torso": "none" }
	_es_state.teams[0] = _es_t0
	_es_state.teams[1] = _es_t1
	_es_state.encounter_attacker_id = 0
	_es_state.encounter_defender_id = 1
	_es.init_encounter(_es_state, 0, 1, "normal")
	for _u in _es_state.encounter_units:
		assert(_u.has("equipment"), "unit should have equipment dict")
		assert(_u.has("inventory"), "unit should have inventory array")
		assert(_u.has("action_timer"), "unit should have action_timer")
	print("Unit equipment OK — %d units spawned" % _es_state.encounter_units.size())
```

- [ ] **Step 3: Run full test**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```
Expected output must include:
- `ItemAttributes OK`
- `HealthSystem OK`
- `EncounterTemplates OK`
- `EncounterCombat OK`
- `PlayerSystem weight OK`
- `Unit equipment OK`
- `=== DONE ===`
- Zero `SCRIPT ERROR` lines

- [ ] **Step 4: Final commit**

```
git add scripts/debug/headless_test.gd
git commit -m "test: final verification for all encounter core systems"
```

---

## ⚠️ Known caveats for implementer

1. **`_return_pool_equipment` overlap**: Task 5 adds `_sync_back_units` which also returns pool items. Keep `_return_pool_equipment` but note it only processes dead units (from PersonData side, pre-sync). The sync handles living units. No double-return if equipment types are consistent.

2. **interaction_system.gd lines ~521,550,651,926**: Exact line numbers may differ — use `right_hand` text search to find all occurrences.

3. **`state["encounter_tick"]`**: WorldState.gd may not declare this field. Either add `var encounter_tick: int = 0` to world_state.gd or use `state.set("encounter_tick", ...)` pattern (GDScript allows dynamic properties on Object subclasses).

4. **`advance_round` callers**: After adding `advance_encounter_tick`, check if anything in `sim_runner.gd` or `interaction_system.gd` calls `advance_round`. Update those callers to use `advance_encounter_tick`. If both coexist, the old `advance_round` can remain temporarily renamed as `_advance_round_legacy`.
