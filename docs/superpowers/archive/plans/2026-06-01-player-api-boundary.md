# Player API Boundary Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create a stable player API boundary (PlayerApiMapper + PlayerQueryApi + PlayerCommandApi + SimBridge facade) so UI and playtests never read WorldState player fields directly.

**Architecture:** 3 new stateless helper classes layered above existing simulation systems. PlayerApiMapper provides static DTO mapping; PlayerQueryApi composes snapshots from WorldState; PlayerCommandApi validates + dispatches commands; SimBridge gains 6 public player methods. UI migrates from direct state reads to bridge calls.

**Tech Stack:** Godot 4.2.2 GDScript. No external dependencies. Tests run via headless_test.gd.

**Spec:** `docs/superpowers/specs/2026-06-01-player-api-boundary-design.md`

---

## File Structure

| Action | Path | Responsibility |
|--------|------|----------------|
| Modify | `scripts/data/world_state.gd` | Add `player_forced_event_id: String` field |
| Modify | `scripts/simulation/interaction_system.gd` | Set `player_forced_event_id = str(randi())` when event fires (2 locations) |
| Modify | `scripts/simulation/sim_runner.gd` | Clear `player_forced_event_id = ""` on timeout (1 location) |
| Modify | `scripts/simulation/player_command_system.gd` | Add `resolve_forced_response(state, interaction_id, response_id)` with ID validation; keep `respond_to_forced` as shim |
| Create | `scripts/simulation/player_api_mapper.gd` | Pure static DTO mapping. No game logic |
| Create | `scripts/simulation/player_query_api.gd` | Query + snapshot composition. Delegates to mapper |
| Create | `scripts/simulation/player_command_api.gd` | Validate + dispatch. Delegates to PlayerCommandSystem / PlayerSystem |
| Modify | `scripts/ui/sim_bridge.gd` | Add `_query_api`, `_cmd_api` members; add 6 public player methods |
| Modify | `scripts/ui/popup_layer.gd` | Replace `PlayerSystem.new().*` calls with `_bridge.command_player(...)` |
| Modify | `scripts/ui/main.gd` | Replace direct `team.move_target = pos` with `_bridge.command_player("move_to", ...)` |
| Modify | `scripts/ui/text_ui_main.gd` | Cache snapshot; replace all `_state.player_*` reads + `_player_cmd.*` calls |
| Modify | `scripts/debug/headless_test.gd` | Add API layer test sections; add `player_forced_event_id = ""` to manual cleanup blocks |
| Modify | `docs/progress.md` | Record new files + migration status |

---

## Chunk 1: Foundation — player_forced_event_id lifecycle

### Task 1.1: Add `player_forced_event_id` field to WorldState

**Files:**
- Modify: `scripts/data/world_state.gd` (after line 36)

- [ ] **Step 1: Add field**

In `world_state.gd`, find the block starting at line 36:
```gdscript
var player_forced_event: Dictionary = {}
# NPC 強制非戰互動，格式：
# ...
# 空 Dict = 無待處理強制事件
```

Insert after that block (before `var ticks_per_day`):
```gdscript
var player_forced_event_id: String = ""
# 對應 player_forced_event 的唯一 ID（str(randi()) 生成）
# 空字串 = 無待處理強制事件
```

- [ ] **Step 2: Smoke test**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd 2>&1 | Select-String -Pattern "DONE|SCRIPT ERROR"
```
Expected: `=== DONE ===`, no `SCRIPT ERROR`

---

### Task 1.2: Set event_id in interaction_system.gd (2 locations)

**Files:**
- Modify: `scripts/simulation/interaction_system.gd` (lines ~198 and ~207)

- [ ] **Step 1: Add id assignment — diplomacy path**

Find the block around line 197–203:
```gdscript
elif npc.current_task == TeamData.TASK_DIPLOMACY:
    if state.player_forced_event.is_empty():   # 不覆蓋現有強制事件
        state.player_forced_event = {
            "from_id":  npc_id,
            "action":   "diplomacy",
            "proposal": npc.order_task if npc.order_task != "" else "alliance"
        }
    return
```

Replace with:
```gdscript
elif npc.current_task == TeamData.TASK_DIPLOMACY:
    if state.player_forced_event.is_empty():   # 不覆蓋現有強制事件
        state.player_forced_event = {
            "from_id":  npc_id,
            "action":   "diplomacy",
            "proposal": npc.order_task if npc.order_task != "" else "alliance"
        }
        state.player_forced_event_id = str(randi())
    return
```

- [ ] **Step 2: Add id assignment — extort path**

Find the block around line 205–208:
```gdscript
elif npc.current_task == TeamData.TASK_LOOT:
    if state.player_forced_event.is_empty():
        state.player_forced_event = { "from_id": npc_id, "action": "extort" }
    return
```

Replace with:
```gdscript
elif npc.current_task == TeamData.TASK_LOOT:
    if state.player_forced_event.is_empty():
        state.player_forced_event = { "from_id": npc_id, "action": "extort" }
        state.player_forced_event_id = str(randi())
    return
```

- [ ] **Step 3: Smoke test**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd 2>&1 | Select-String -Pattern "DONE|SCRIPT ERROR"
```
Expected: `=== DONE ===`, no `SCRIPT ERROR`

---

### Task 1.3: Clear event_id in player_command_system on forced response

**Files:**
- Modify: `scripts/simulation/player_command_system.gd` (in `respond_to_forced` method)

- [ ] **Step 1: Update respond_to_forced to clear id**

In `player_command_system.gd`, find the `respond_to_forced` method (line ~101). Every location where it does `state.player_forced_event = {}`, add `state.player_forced_event_id = ""` immediately after:

```gdscript
state.player_forced_event = {}
state.player_forced_event_id = ""
```

**Important:** The timeout logic in `sim_runner.gd` will also clear `player_forced_event` (line 83). Since `respond_to_forced` is the canonical response path, that's where we ensure the ID is cleared too.

- [ ] **Step 2: Smoke test**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd 2>&1 | Select-String -Pattern "DONE|SCRIPT ERROR"
```
Expected: `=== DONE ===`, no `SCRIPT ERROR`

---

### Task 1.4: Add `resolve_forced_response` to PlayerCommandSystem

**Files:**
- Modify: `scripts/simulation/player_command_system.gd`

The current `respond_to_forced(state, response)` must remain unchanged (backward compat with existing tests).
Add a new method `resolve_forced_response` that does ID validation, then delegates.

Note: `get_forced_response_options` already exists at line 93-97. No need to add it.

- [ ] **Step 1: Add `resolve_forced_response` method**

After the existing `respond_to_forced` method, add:

```gdscript
func resolve_forced_response(state: WorldState, interaction_id: String, response_id: String) -> Dictionary:
    if state.player_forced_event.is_empty():
        return {"ok": false, "code": "forced_response_missing", "msg": "no active forced interaction"}
    if interaction_id != "" and interaction_id != state.player_forced_event_id:
        return {"ok": false, "code": "forced_response_missing", "msg": "interaction expired or wrong id"}
    var valid: Array[String] = get_forced_response_options(state)
    if not valid.has(response_id):
        return {"ok": false, "code": "forced_response_invalid", "msg": "invalid response_id: %s" % response_id}
    return respond_to_forced(state, response_id)
```

- [ ] **Step 2: Smoke test**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd 2>&1 | Select-String -Pattern "DONE|SCRIPT ERROR"
```
Expected: `=== DONE ===`, no `SCRIPT ERROR`

---

### Task 1.5: Update headless_test.gd manual cleanup blocks

**Files:**
- Modify: `scripts/debug/headless_test.gd` (cleanup blocks around lines 1515, 1577)

Test setups that manually assign `state.player_forced_event = { ... }` should also set the id, so the new `resolve_forced_response` can find a matching id.

- [ ] **Step 1: Update cleanup blocks**

In `headless_test.gd`, grep for every occurrence of `state.player_forced_event = {}` (the empty-dict CLEAR) and add `state.player_forced_event_id = ""` after each one.

```powershell
Select-String -Path "scripts\debug\headless_test.gd" -Pattern "player_forced_event = \{\}" | Select-Object LineNumber, Line
```

For each match, add the id clear on the next line.

- [ ] **Step 2: Update manual event setups**

In `headless_test.gd`, grep for every occurrence of `state.player_forced_event = {` (the non-empty SET) and add `state.player_forced_event_id = "test-forced-id"` after each one.

```powershell
Select-String -Path "scripts\debug\headless_test.gd" -Pattern 'player_forced_event = \{[^}]' | Select-Object LineNumber, Line
```

For each match, add `state.player_forced_event_id = "test-forced-id"` on the next line.

- [ ] **Step 3: Run full headless test**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd 2>&1 | Select-String -Pattern "DONE|SCRIPT ERROR|FAILED"
```
Expected: `=== DONE ===`, no `SCRIPT ERROR`, no `FAILED`

- [ ] **Step 4: Commit**

```
git add scripts/data/world_state.gd scripts/simulation/interaction_system.gd scripts/simulation/sim_runner.gd scripts/simulation/player_command_system.gd scripts/debug/headless_test.gd
git commit -m "feat(player-api): add player_forced_event_id lifecycle to WorldState"
```

---

## Chunk 2: PlayerApiMapper — static DTO mapping

### Task 2.1: Create player_api_mapper.gd

**Files:**
- Create: `scripts/simulation/player_api_mapper.gd`

This file has ONLY static functions. No game logic. No calls to other simulation systems. Transforms WorldState data into spec-defined DTOs.

**Coordinate convention:** `tile_pos.x = tile_q`, `tile_pos.y = tile_r`. Tile key = `tile_q * 1000 + tile_r`.

- [ ] **Step 1: Write test in headless_test.gd before implementing**

At the end of `headless_test.gd`, before the final `print("=== DONE ===")` line, add a new section:

```gdscript
# ── PlayerApiMapper unit tests ─────────────────────────────────────────────────
print("\n--- PlayerApiMapper ---")
var _mapper_state := WorldState.new()

# map_query_envelope
var _qenv := PlayerApiMapper.map_query_envelope(true, "ok", "msg", {"x": 1})
assert(_qenv["ok"] == true, "map_query_envelope ok")
assert(_qenv["code"] == "ok", "map_query_envelope code")
assert(_qenv["message"] == "msg", "map_query_envelope message")
assert(_qenv["data"]["x"] == 1, "map_query_envelope data")
print("map_query_envelope: OK")

# map_command_result
var _cres := PlayerApiMapper.map_command_result(false, "no_player", "err", {})
assert(_cres["ok"] == false, "map_command_result ok")
assert(_cres["code"] == "no_player", "map_command_result code")
print("map_command_result: OK")

# map_player_summary — no player
var _ps_empty := PlayerApiMapper.map_player_summary(_mapper_state)
assert(_ps_empty["player_exists"] == false, "map_player_summary no player")
print("map_player_summary (no player): OK")

# map_pending_targets — empty
var _pt_empty := PlayerApiMapper.map_pending_targets(_mapper_state)
assert(_pt_empty.size() == 0, "map_pending_targets empty")
print("map_pending_targets (empty): OK")

# map_forced_interaction — empty
var _fi_empty := PlayerApiMapper.map_forced_interaction(_mapper_state)
assert(_fi_empty["interaction_id"] == "", "map_forced_interaction empty")
assert(_fi_empty["responses"].size() == 0, "map_forced_interaction responses empty")
print("map_forced_interaction (empty): OK")

# map_forced_interaction — extort
_mapper_state.player_forced_event = {"from_id": 2, "action": "extort"}
_mapper_state.player_forced_event_id = "abc123"
var _fi_extort := PlayerApiMapper.map_forced_interaction(_mapper_state)
assert(_fi_extort["interaction_id"] == "abc123", "map_forced_interaction extort id")
assert(_fi_extort["interaction_type"] == "extort", "map_forced_interaction extort type")
assert(_fi_extort["responses"].size() == 2, "map_forced_interaction extort responses count")
assert(_fi_extort["responses"][0]["response_id"] == "pay", "map_forced_interaction extort first response")
print("map_forced_interaction (extort): OK")

# map_forced_interaction — diplomacy
_mapper_state.player_forced_event = {"from_id": 3, "action": "diplomacy", "proposal": "alliance"}
_mapper_state.player_forced_event_id = "def456"
var _fi_dipl := PlayerApiMapper.map_forced_interaction(_mapper_state)
assert(_fi_dipl["interaction_type"] == "diplomacy", "map_forced_interaction diplomacy type")
assert(_fi_dipl["responses"].size() == 2, "map_forced_interaction diplomacy responses count")
print("map_forced_interaction (diplomacy): OK")

# Reset
_mapper_state.player_forced_event = {}
_mapper_state.player_forced_event_id = ""
print("PlayerApiMapper: ALL PASS")
```

- [ ] **Step 2: Run test to verify it FAILS (PlayerApiMapper not yet created)**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd 2>&1 | Select-String -Pattern "DONE|SCRIPT ERROR|PlayerApiMapper"
```
Expected: `SCRIPT ERROR` referencing `PlayerApiMapper`

- [ ] **Step 3: Create player_api_mapper.gd**

Create `scripts/simulation/player_api_mapper.gd` with the following content:

```gdscript
class_name PlayerApiMapper

# ── Equippable slot lookup (compile-time const) ────────────────────────────────
const EQUIPPABLE_SLOTS: Dictionary = {
    "weapon_melee_low":   ["hand_1", "hand_2"],
    "weapon_melee_high":  ["hand_1", "hand_2"],
    "weapon_ranged_low":  ["hand_1"],
    "weapon_ranged_high": ["hand_1"],
    "armor_low":          ["head", "torso", "hand_1"],
    "armor_high":         ["head", "torso"],
}

# ── Envelope builders ──────────────────────────────────────────────────────────

static func map_query_envelope(ok: bool, code: String, message: String, data: Dictionary) -> Dictionary:
    return {"ok": ok, "code": code, "message": message, "data": data}

static func map_command_result(ok: bool, code: String, message: String, payload: Dictionary) -> Dictionary:
    return {"ok": ok, "code": code, "message": message, "payload": payload}

# ── Player summary ─────────────────────────────────────────────────────────────

static func map_player_summary(state: WorldState) -> Dictionary:
    var pid: int = state.player_id
    if pid == -1:
        return {
            "player_exists": false, "player_person_id": -1, "player_name": "",
            "controlled_team_id": -1, "controlled_team_name": "",
            "position": {"q": -1, "r": -1}, "encounter_active": false,
            "has_pending_targets": false, "has_forced_interaction": false
        }
    var p: PersonData = state.persons.get(pid)
    if p == null:
        return {
            "player_exists": false, "player_person_id": pid, "player_name": "",
            "controlled_team_id": -1, "controlled_team_name": "",
            "position": {"q": -1, "r": -1}, "encounter_active": false,
            "has_pending_targets": false, "has_forced_interaction": false
        }
    var tid: int = p.team_id
    var t: TeamData = state.teams.get(tid) if tid != -1 else null
    return {
        "player_exists": true,
        "player_person_id": pid,
        "player_name": p.person_name,
        "controlled_team_id": tid,
        "controlled_team_name": "Team%d" % tid if tid != -1 else "",
        "position": {"q": t.tile_pos.x, "r": t.tile_pos.y} if t != null else {"q": -1, "r": -1},
        "encounter_active": state.encounter_active,
        "has_pending_targets": not state.player_pending_targets.is_empty(),
        "has_forced_interaction": not state.player_forced_event.is_empty()
    }

# ── Controlled team ────────────────────────────────────────────────────────────

static func map_controlled_team(state: WorldState) -> Dictionary:
    var pid: int = state.player_id
    var p: PersonData = state.persons.get(pid) if pid != -1 else null
    var tid: int = p.team_id if p != null else -1
    var t: TeamData = state.teams.get(tid) if tid != -1 else null
    if t == null:
        return {}
    var members: Array = []
    var member_ids: Array = [t.leader_id] + t.named_members
    for mid in member_ids:
        var m: PersonData = state.persons.get(mid)
        if m != null:
            members.append({"id": m.id, "name": m.person_name, "role": m.role})
    var mv: Vector2i = t.move_target
    return {
        "id": tid,
        "name": "Team%d" % tid,
        "faction": str(t.faction_id) if t.faction_id != -1 else "",
        "position": {"q": t.tile_pos.x, "r": t.tile_pos.y},
        "members": members,
        "resources": {
            "food": int(t.resources.get("food", 0)),
            "coin": int(t.resources.get("coin", 0)),
            "material": int(t.resources.get("material", 0))
        },
        "movement": {
            "has_target": mv != Vector2i(-1, -1),
            "target_q": mv.x,
            "target_r": mv.y
        },
        "task_summary": t.current_task
    }

# ── Visible teams ──────────────────────────────────────────────────────────────

static func map_visible_teams(state: WorldState) -> Array:
    var pid: int = state.player_id
    var p: PersonData = state.persons.get(pid) if pid != -1 else null
    var tid: int = p.team_id if p != null else -1
    if tid == -1:
        return []
    var discovered: Array = state.team_discovered.get(tid, [])
    var result: Array = []
    for dtid in discovered:
        var dt: TeamData = state.teams.get(dtid)
        if dt == null:
            continue
        result.append({
            "id": dtid,
            "name": "Team%d" % dtid,
            "relation": "unknown",
            "position": {"q": dt.tile_pos.x, "r": dt.tile_pos.y},
            "can_interact": not state.player_pending_targets.has(dtid),
            "can_inspect": true,
            "can_target": true
        })
    return result

# ── Focused member ─────────────────────────────────────────────────────────────

static func map_focused_member(state: WorldState, focus_team_id: int, focus_member_id: int) -> Dictionary:
    var sentinel: Dictionary = {
        "id": -1, "name": "", "team_id": -1, "team_name": "", "role": "",
        "status": {"health": "", "stress": 0.0, "loyalty": 0.0},
        "available_actions": []
    }
    if focus_team_id == -1 or focus_member_id == -1:
        return sentinel
    var t: TeamData = state.teams.get(focus_team_id)
    var mp: PersonData = state.persons.get(focus_member_id)
    if t == null or mp == null or mp.team_id != focus_team_id:
        return sentinel
    return {
        "id": focus_member_id,
        "name": mp.person_name,
        "team_id": focus_team_id,
        "team_name": "Team%d" % focus_team_id,
        "role": mp.role,
        "status": {"health": "healthy", "stress": mp.stress, "loyalty": mp.loyalty},
        "available_actions": []
    }

# ── Pending targets ────────────────────────────────────────────────────────────

static func map_pending_targets(state: WorldState) -> Array:
    var result: Array = []
    for tid in state.player_pending_targets:
        var t: TeamData = state.teams.get(tid)
        result.append({
            "target_type": "team",
            "target_id": int(tid),
            "display_name": "Team%d" % tid,
            "is_valid": t != null
        })
    return result

# ── Forced interaction ─────────────────────────────────────────────────────────

static func map_forced_interaction(state: WorldState) -> Dictionary:
    var empty_result: Dictionary = {
        "interaction_id": "",
        "interaction_type": "",
        "source": {"team_id": -1, "team_name": "", "member_id": -1, "member_name": ""},
        "message": "",
        "responses": []
    }
    var evt: Dictionary = state.player_forced_event
    if evt.is_empty():
        return empty_result
    var iid: String = state.player_forced_event_id
    var from_id: int = evt.get("from_id", -1)
    var action: String = evt.get("action", "")
    var proposal: String = evt.get("proposal", "")
    var msg: String = ""
    var responses: Array = []
    match action:
        "diplomacy":
            msg = "Team%d 提議 %s" % [from_id, proposal]
            responses = [
                {"response_id": "accept", "label": "接受", "command_args": {"interaction_id": iid, "response_id": "accept"}},
                {"response_id": "refuse", "label": "拒絕", "command_args": {"interaction_id": iid, "response_id": "refuse"}}
            ]
        "extort":
            msg = "Team%d 勒索你" % from_id
            responses = [
                {"response_id": "pay", "label": "付錢", "command_args": {"interaction_id": iid, "response_id": "pay"}},
                {"response_id": "refuse", "label": "拒絕", "command_args": {"interaction_id": iid, "response_id": "refuse"}}
            ]
        _:
            msg = "Team%d 強制事件" % from_id
            responses = [
                {"response_id": "refuse", "label": "拒絕", "command_args": {"interaction_id": iid, "response_id": "refuse"}}
            ]
    return {
        "interaction_id": iid,
        "interaction_type": action,
        "source": {
            "team_id": from_id,
            "team_name": "Team%d" % from_id if from_id != -1 else "",
            "member_id": -1,
            "member_name": ""
        },
        "message": msg,
        "responses": responses
    }

# ── Location context ───────────────────────────────────────────────────────────

static func map_location_context(state: WorldState, tile_q: int, tile_r: int) -> Dictionary:
    var not_visible: Dictionary = {
        "tile": {"q": tile_q, "r": tile_r},
        "visibility_state": "hidden",
        "terrain": null,
        "settlement": null,
        "occupants": [],
        "is_player_here": false,
        "hints": []
    }
    if tile_q == -1 or tile_r == -1:
        not_visible["tile"] = {"q": -1, "r": -1}
        return not_visible
    var tile_key: int = tile_q * 1000 + tile_r
    if not state.world.tiles.has(tile_key):
        return not_visible
    var pid: int = state.player_id
    var p: PersonData = state.persons.get(pid) if pid != -1 else null
    var ptid: int = p.team_id if p != null else -1
    var known: Array = state.team_known.get(ptid, []) if ptid != -1 else []
    if not known.has(tile_key):
        return not_visible
    var tile: HexTileData = state.world.tiles[tile_key] as HexTileData
    var pt: TeamData = state.teams.get(ptid) if ptid != -1 else null
    var is_here: bool = pt != null and pt.tile_pos == Vector2i(tile_q, tile_r)
    var occupants: Array = []
    for oid in state.teams:
        if oid == ptid:
            continue
        var ot: TeamData = state.teams[oid]
        if ot.tile_pos == Vector2i(tile_q, tile_r):
            occupants.append({"team_id": oid, "team_name": "Team%d" % oid, "relation": "unknown"})
    var settlement = null
    if tile.outpost_type != "" and tile.outpost_owner != -1:
        settlement = {
            "id": tile.outpost_owner,
            "name": "%s Lv%d" % [tile.outpost_type, tile.outpost_level],
            "owner_faction": ""
        }
    return {
        "tile": {"q": tile_q, "r": tile_r},
        "visibility_state": "visible",
        "terrain": tile.terrain,
        "settlement": settlement,
        "occupants": occupants,
        "is_player_here": is_here,
        "hints": []
    }

# ── Inventory state ────────────────────────────────────────────────────────────

static func _get_equip_slots(grade: String) -> PackedStringArray:
    var slots: Array = EQUIPPABLE_SLOTS.get(grade, [])
    return PackedStringArray(slots)

static func _make_item_action(action_id: String, label: String, enabled: bool,
        disabled_reason: String, command_name: String, command_args: Dictionary) -> Dictionary:
    return {
        "action_id": action_id, "label": label, "enabled": enabled,
        "disabled_reason": disabled_reason,
        "target_requirements": {
            "allowed_kinds": PackedStringArray(["none"]),
            "requires_visible_target": false,
            "requires_forced_interaction": false,
            "allows_self_target": false
        },
        "command_name": command_name, "command_args": command_args
    }

static func map_inventory_state(state: WorldState) -> Dictionary:
    var pid: int = state.player_id
    var p: PersonData = state.persons.get(pid) if pid != -1 else null
    var tid: int = p.team_id if p != null else -1
    var t: TeamData = state.teams.get(tid) if tid != -1 else null
    var raw_inv: Array = state.player_state.get("inventory", []) if not state.player_state.is_empty() else []

    var inv_items: Array = []
    for item in raw_inv:
        var grade: String = item.get("grade", "")
        var qty: int = item.get("qty", 1)
        var slots: PackedStringArray = _get_equip_slots(grade)
        var row_actions: Array = []
        for slot in slots:
            row_actions.append(_make_item_action(
                "equip_%s_%s" % [grade, slot],
                "裝備 %s → %s" % [grade, slot],
                true, "",
                "equip_item", {"slot_id": slot, "item_grade": grade}
            ))
        row_actions.append(_make_item_action(
            "deposit_%s" % grade, "存入隊伍",
            t != null, "" if t != null else "無受控隊伍",
            "deposit_item", {"item_grade": grade, "qty": qty}
        ))
        inv_items.append({"row_id": grade, "grade": grade, "qty": qty, "equip_slots": slots, "available_actions": row_actions})

    var take_items: Array = []
    if t != null:
        for res_key in t.resources:
            var qty: int = int(t.resources[res_key])
            if qty > 0:
                take_items.append({
                    "row_id": res_key, "grade": res_key, "qty": qty,
                    "available_actions": [
                        _make_item_action("take_%s" % res_key, "取出 %s" % res_key, true, "",
                            "take_team_item", {"item_grade": res_key, "qty": 1})
                    ]
                })

    var equipped: Dictionary = {"head": "", "torso": "", "hand_1": "", "hand_2": ""}
    if p != null:
        for slot in ["head", "torso", "hand_1", "hand_2"]:
            equipped[slot] = p.equipment.get(slot, {}).get("grade", "")

    var unequip_actions: Array = []
    for slot in ["head", "torso", "hand_1", "hand_2"]:
        if equipped[slot] != "":
            unequip_actions.append(_make_item_action(
                "unequip_%s" % slot,
                "卸下 %s (%s)" % [slot, equipped[slot]],
                true, "",
                "unequip_item", {"slot_id": slot}
            ))

    return {
        "inventory_items": inv_items,
        "team_takeable_items": take_items,
        "equipped_items": equipped,
        "available_actions": unequip_actions
    }

# ── Available action builder ───────────────────────────────────────────────────

static func map_available_action(action_id: String, label: String, enabled: bool,
        disabled_reason: String, target_requirements: Dictionary,
        command_name: String, command_args: Dictionary) -> Dictionary:
    return {
        "action_id": action_id, "label": label, "enabled": enabled,
        "disabled_reason": disabled_reason,
        "target_requirements": target_requirements,
        "command_name": command_name, "command_args": command_args
    }

# ── Snapshot meta ──────────────────────────────────────────────────────────────

static func map_snapshot_meta(focus_valid: bool, cursor_valid: bool) -> Dictionary:
    return {"focus_valid": focus_valid, "cursor_valid": cursor_valid}

# ── Full player snapshot ───────────────────────────────────────────────────────

static func map_player_snapshot(state: WorldState, focus_team_id: int, focus_member_id: int,
        cursor_q: int, cursor_r: int, actions: Array) -> Dictionary:
    var focus_valid: bool = focus_team_id != -1 and focus_member_id != -1 \
        and state.teams.has(focus_team_id) and state.persons.has(focus_member_id)
    var cursor_valid: bool = cursor_q != -1 and cursor_r != -1 \
        and state.world.tiles.has(cursor_q * 1000 + cursor_r)
    return {
        "player_summary":     map_player_summary(state),
        "controlled_team":    map_controlled_team(state),
        "visible_teams":      map_visible_teams(state),
        "focused_member":     map_focused_member(state, focus_team_id, focus_member_id),
        "pending_targets":    map_pending_targets(state),
        "forced_interaction": map_forced_interaction(state),
        "location_context":   map_location_context(state, cursor_q, cursor_r),
        "available_actions":  actions,
        "inventory_state":    map_inventory_state(state),
        "snapshot_meta":      map_snapshot_meta(focus_valid, cursor_valid)
    }
```

- [ ] **Step 4: Run import (new class_name file)**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --import 2>&1 | Select-String -Pattern "ERROR|error"
```
Expected: no errors

- [ ] **Step 5: Run test to verify it PASSES**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd 2>&1 | Select-String -Pattern "DONE|SCRIPT ERROR|PlayerApiMapper"
```
Expected: `PlayerApiMapper: ALL PASS`, `=== DONE ===`, no `SCRIPT ERROR`

- [ ] **Step 6: Commit**

```
git add scripts/simulation/player_api_mapper.gd scripts/debug/headless_test.gd
git commit -m "feat(player-api): add PlayerApiMapper with static DTO mapping"
```

---

## Chunk 3: PlayerQueryApi — snapshot composition

### Task 3.1: Create player_query_api.gd

**Files:**
- Create: `scripts/simulation/player_query_api.gd`
- Modify: `scripts/debug/headless_test.gd` (add query API tests)

- [ ] **Step 1: Write failing tests in headless_test.gd**

Before the final `print("=== DONE ===")`, add:

```gdscript
# ── PlayerQueryApi unit tests ──────────────────────────────────────────────────
print("\n--- PlayerQueryApi ---")
var _qapi := PlayerQueryApi.new()
var _qapi_state := WorldState.new()

# No player → error envelope
var _qapi_r1 := _qapi.get_player_snapshot(_qapi_state, {})
assert(_qapi_r1["ok"] == false, "get_player_snapshot no player ok=false")
assert(_qapi_r1["code"] == "no_player", "get_player_snapshot no player code")
print("get_player_snapshot (no player): OK")

# get_team_details — invalid team
var _qapi_r2 := _qapi.get_team_details(_qapi_state, 999)
assert(_qapi_r2["ok"] == false, "get_team_details invalid team")
print("get_team_details (invalid): OK")

# get_location_context — invalid tile
var _qapi_r3 := _qapi.get_location_context(_qapi_state, -1, -1)
assert(_qapi_r3["ok"] == false, "get_location_context invalid tile")
print("get_location_context (invalid tile): OK")

# get_available_actions — no player
var _qapi_r4 := _qapi.get_available_actions(_qapi_state, {"team_id": -1, "member_id": -1, "tile_q": -1, "tile_r": -1, "forced_interaction_id": ""})
assert(_qapi_r4["ok"] == false, "get_available_actions no player")
print("get_available_actions (no player): OK")

print("PlayerQueryApi: ALL PASS")
```

- [ ] **Step 2: Run test to verify it FAILS**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd 2>&1 | Select-String -Pattern "DONE|SCRIPT ERROR|PlayerQueryApi"
```
Expected: `SCRIPT ERROR` referencing `PlayerQueryApi`

- [ ] **Step 3: Create player_query_api.gd**

Create `scripts/simulation/player_query_api.gd`:

```gdscript
class_name PlayerQueryApi

func get_player_snapshot(state: WorldState, request: Dictionary) -> Dictionary:
    var player_check := _check_player_with_team(state)
    if player_check["code"] != "ok":
        return PlayerApiMapper.map_query_envelope(false, player_check["code"], player_check["msg"], {})

    var focus_team_id: int   = request.get("focus_team_id",   -1)
    var focus_member_id: int = request.get("focus_member_id", -1)
    var cursor_q: int        = request.get("cursor_tile_q",   -1)
    var cursor_r: int        = request.get("cursor_tile_r",   -1)

    if focus_member_id != -1 and focus_team_id == -1:
        return PlayerApiMapper.map_query_envelope(false, "invalid_focus",
            "focus_member_id requires focus_team_id", {})
    if (cursor_q == -1) != (cursor_r == -1):
        return PlayerApiMapper.map_query_envelope(false, "invalid_request",
            "cursor_tile_q and cursor_tile_r must both be set or both be -1", {})

    var cmd_sys := PlayerCommandSystem.new()
    var actions := _build_available_actions(state, cmd_sys, focus_team_id, focus_member_id, cursor_q, cursor_r)
    var snapshot := PlayerApiMapper.map_player_snapshot(
        state, focus_team_id, focus_member_id, cursor_q, cursor_r, actions)
    return PlayerApiMapper.map_query_envelope(true, "ok", "", {"snapshot": snapshot})

func get_team_details(state: WorldState, team_id: int) -> Dictionary:
    var check := _check_player(state)
    if check["code"] != "ok":
        return PlayerApiMapper.map_query_envelope(false, check["code"], check["msg"], {})
    if not state.teams.has(team_id):
        return PlayerApiMapper.map_query_envelope(false, "invalid_team", "team not found", {})
    var p: PersonData = state.persons[state.player_id]
    var discovered: Array = state.team_discovered.get(p.team_id, [])
    if team_id != p.team_id and not discovered.has(team_id):
        return PlayerApiMapper.map_query_envelope(false, "not_visible", "team not visible", {})
    var t: TeamData = state.teams[team_id]
    var members: Array = []
    for mid in ([t.leader_id] + t.named_members):
        var m: PersonData = state.persons.get(mid)
        if m != null:
            members.append({"id": m.id, "name": m.person_name, "role": m.role})
    var team_data: Dictionary = {
        "id": team_id,
        "name": "Team%d" % team_id,
        "faction": str(t.faction_id) if t.faction_id != -1 else "",
        "position": {"q": t.tile_pos.x, "r": t.tile_pos.y},
        "members": members,
        "resources": {
            "food":     int(t.resources.get("food", 0)),
            "coin":     int(t.resources.get("coin", 0)),
            "material": int(t.resources.get("material", 0))
        },
        "interaction_options": []
    }
    return PlayerApiMapper.map_query_envelope(true, "ok", "", {"team": team_data})

func get_member_details(state: WorldState, team_id: int, member_id: int) -> Dictionary:
    var check := _check_player(state)
    if check["code"] != "ok":
        return PlayerApiMapper.map_query_envelope(false, check["code"], check["msg"], {})
    if not state.teams.has(team_id):
        return PlayerApiMapper.map_query_envelope(false, "invalid_team", "team not found", {})
    var p: PersonData = state.persons[state.player_id]
    var discovered: Array = state.team_discovered.get(p.team_id, [])
    if team_id != p.team_id and not discovered.has(team_id):
        return PlayerApiMapper.map_query_envelope(false, "not_visible", "team not visible", {})
    var mp: PersonData = state.persons.get(member_id)
    if mp == null or mp.team_id != team_id:
        return PlayerApiMapper.map_query_envelope(false, "invalid_member", "member not found in team", {})
    var member_data: Dictionary = {
        "id": member_id,
        "name": mp.person_name,
        "team_id": team_id,
        "team_name": "Team%d" % team_id,
        "role": mp.role,
        "status": {"health": "healthy", "stress": mp.stress, "loyalty": mp.loyalty},
        "available_actions": []
    }
    return PlayerApiMapper.map_query_envelope(true, "ok", "", {"member": member_data})

func get_location_context(state: WorldState, tile_q: int, tile_r: int) -> Dictionary:
    if state.player_id == -1:
        return PlayerApiMapper.map_query_envelope(false, "no_player", "no player", {})
    if tile_q == -1 or tile_r == -1:
        return PlayerApiMapper.map_query_envelope(false, "invalid_tile", "invalid tile coordinates", {})
    if not state.world.tiles.has(tile_q * 1000 + tile_r):
        return PlayerApiMapper.map_query_envelope(false, "invalid_tile", "tile not found", {})
    var location := PlayerApiMapper.map_location_context(state, tile_q, tile_r)
    return PlayerApiMapper.map_query_envelope(true, "ok", "", {"location": location})

func get_available_actions(state: WorldState, request: Dictionary) -> Dictionary:
    var check := _check_player_with_team(state)
    if check["code"] != "ok":
        return PlayerApiMapper.map_query_envelope(false, check["code"], check["msg"], {})

    var team_id: int    = request.get("team_id",              -1)
    var member_id: int  = request.get("member_id",            -1)
    var tile_q: int     = request.get("tile_q",               -1)
    var tile_r: int     = request.get("tile_r",               -1)
    var fi_id: String   = request.get("forced_interaction_id", "")

    if member_id != -1 and team_id == -1:
        return PlayerApiMapper.map_query_envelope(false, "invalid_focus",
            "member_id requires team_id", {})
    if (tile_q == -1) != (tile_r == -1):
        return PlayerApiMapper.map_query_envelope(false, "invalid_request",
            "tile_q and tile_r must both be set or both be -1", {})
    if fi_id != "" and fi_id != state.player_forced_event_id:
        return PlayerApiMapper.map_query_envelope(false, "forced_response_missing",
            "forced interaction expired", {})
    if team_id != -1 and not state.teams.has(team_id):
        return PlayerApiMapper.map_query_envelope(false, "invalid_team", "team not found", {})
    if member_id != -1 and not state.persons.has(member_id):
        return PlayerApiMapper.map_query_envelope(false, "invalid_member", "member not found", {})
    if tile_q != -1 and not state.world.tiles.has(tile_q * 1000 + tile_r):
        return PlayerApiMapper.map_query_envelope(false, "invalid_tile", "tile not found", {})

    var cmd_sys := PlayerCommandSystem.new()
    var actions := _build_available_actions(state, cmd_sys, team_id, member_id, tile_q, tile_r)
    return PlayerApiMapper.map_query_envelope(true, "ok", "", {"actions": actions})

# ── Private helpers ────────────────────────────────────────────────────────────

func _check_player(state: WorldState) -> Dictionary:
    if state.player_id == -1 or not state.persons.has(state.player_id):
        return {"code": "no_player", "msg": "no player"}
    return {"code": "ok", "msg": ""}

func _check_player_with_team(state: WorldState) -> Dictionary:
    var check := _check_player(state)
    if check["code"] != "ok":
        return check
    var p: PersonData = state.persons[state.player_id]
    if not state.teams.has(p.team_id):
        return {"code": "no_controlled_team", "msg": "no controlled team"}
    return {"code": "ok", "msg": ""}

func _build_available_actions(state: WorldState, cmd_sys: PlayerCommandSystem,
        focus_team_id: int, focus_member_id: int, cursor_q: int, cursor_r: int) -> Array:
    var actions: Array = []
    # Layer 1: forced interaction responses
    var fi := PlayerApiMapper.map_forced_interaction(state)
    for resp in fi.get("responses", []):
        actions.append(PlayerApiMapper.map_available_action(
            "forced_%s" % resp["response_id"],
            resp["label"],
            true, "",
            {
                "allowed_kinds": PackedStringArray(["none"]),
                "requires_visible_target": false,
                "requires_forced_interaction": true,
                "allows_self_target": false
            },
            "respond_to_forced", resp["command_args"]
        ))

    # Layer 2 & 3: focused member / tile context (Phase 1: empty — spec allows this)

    # Layer 4: team-level actions against focused team
    var p: PersonData = state.persons.get(state.player_id)
    var ptid: int = p.team_id if p != null else -1
    if focus_team_id != -1 and focus_team_id != ptid and state.teams.has(focus_team_id):
        var team_actions: Array[String] = cmd_sys.get_available_actions(state, focus_team_id)
        for act in team_actions:
            actions.append(PlayerApiMapper.map_available_action(
                act, _action_label(act), true, "",
                {
                    "allowed_kinds": PackedStringArray(["team"]),
                    "requires_visible_target": true,
                    "requires_forced_interaction": false,
                    "allows_self_target": false
                },
                "execute_action",
                {
                    "action_id": act,
                    "target": {"kind": "team", "team_id": focus_team_id, "member_id": -1, "tile_q": -1, "tile_r": -1}
                }
            ))

    # move_to (cursor set)
    if cursor_q != -1 and cursor_r != -1:
        actions.append(PlayerApiMapper.map_available_action(
            "move_to", "移動到 (%d,%d)" % [cursor_q, cursor_r], true, "",
            {
                "allowed_kinds": PackedStringArray(["tile"]),
                "requires_visible_target": false,
                "requires_forced_interaction": false,
                "allows_self_target": false
            },
            "move_to", {"tile_q": cursor_q, "tile_r": cursor_r}
        ))

    # cancel_move (team has a move target)
    var pt: TeamData = state.teams.get(ptid) if ptid != -1 else null
    if pt != null and pt.move_target != Vector2i(-1, -1):
        actions.append(PlayerApiMapper.map_available_action(
            "cancel_move", "取消移動", true, "",
            {
                "allowed_kinds": PackedStringArray(["none"]),
                "requires_visible_target": false,
                "requires_forced_interaction": false,
                "allows_self_target": false
            },
            "cancel_move", {}
        ))

    return actions

func _action_label(action_id: String) -> String:
    match action_id:
        "ignore":          return "忽略"
        "attack":          return "攻擊"
        "trade":           return "貿易"
        "propose_alliance": return "提議同盟"
        "demand_tribute":  return "要求納貢"
        "extort":          return "勒索"
        "recruit":         return "招募"
    return action_id
```

- [ ] **Step 4: Run import + tests**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --import
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd 2>&1 | Select-String -Pattern "DONE|SCRIPT ERROR|PlayerQueryApi"
```
Expected: `PlayerQueryApi: ALL PASS`, `=== DONE ===`

- [ ] **Step 5: Commit**

```
git add scripts/simulation/player_query_api.gd scripts/debug/headless_test.gd
git commit -m "feat(player-api): add PlayerQueryApi snapshot composition"
```

---

## Chunk 4: PlayerCommandApi — validate + dispatch

### Task 4.1: Create player_command_api.gd

**Files:**
- Create: `scripts/simulation/player_command_api.gd`
- Modify: `scripts/debug/headless_test.gd` (add command API tests)

- [ ] **Step 1: Write failing tests in headless_test.gd**

Before the final `print("=== DONE ===")`, add:

```gdscript
# ── PlayerCommandApi unit tests ────────────────────────────────────────────────
print("\n--- PlayerCommandApi ---")
var _capi := PlayerCommandApi.new()
var _capi_state := WorldState.new()

# No player → error
var _capi_r1 := _capi.move_to(_capi_state, 0, 0)
assert(_capi_r1["ok"] == false, "cmd move_to no player")
assert(_capi_r1["code"] == "no_player", "cmd move_to no player code")
print("move_to (no player): OK")

# No player → respond_to_forced error
var _capi_r2 := _capi.respond_to_forced(_capi_state, "abc", "refuse")
assert(_capi_r2["ok"] == false, "respond_to_forced no player")
print("respond_to_forced (no player): OK")

# dispatch — unknown command
var _capi_r3 := _capi.dispatch(_capi_state, "unknown_cmd", {})
assert(_capi_r3["ok"] == false, "dispatch unknown cmd")
assert(_capi_r3["code"] == "invalid_request", "dispatch unknown cmd code")
print("dispatch (unknown): OK")

# respond_to_forced — expired id
_capi_state.player_id = 1
_capi_state.player_forced_event = {"from_id": 2, "action": "extort"}
_capi_state.player_forced_event_id = "real-id"
var _capi_r4 := _capi.respond_to_forced(_capi_state, "wrong-id", "refuse")
assert(_capi_r4["ok"] == false, "respond_to_forced wrong id")
assert(_capi_r4["code"] == "forced_response_missing", "respond_to_forced wrong id code")
print("respond_to_forced (wrong id): OK")

# respond_to_forced — invalid response_id
var _capi_r5 := _capi.respond_to_forced(_capi_state, "real-id", "invalid_resp")
assert(_capi_r5["ok"] == false, "respond_to_forced invalid resp")
assert(_capi_r5["code"] == "forced_response_invalid", "respond_to_forced invalid resp code")
print("respond_to_forced (invalid response_id): OK")

# Reset
_capi_state.player_id = -1
_capi_state.player_forced_event = {}
_capi_state.player_forced_event_id = ""
print("PlayerCommandApi: ALL PASS")
```

- [ ] **Step 2: Run test to verify it FAILS**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd 2>&1 | Select-String -Pattern "DONE|SCRIPT ERROR|PlayerCommandApi"
```
Expected: `SCRIPT ERROR` referencing `PlayerCommandApi`

- [ ] **Step 3: Create player_command_api.gd**

Create `scripts/simulation/player_command_api.gd`:

```gdscript
class_name PlayerCommandApi

var _cmd_sys: PlayerCommandSystem = PlayerCommandSystem.new()
var _ps: PlayerSystem = PlayerSystem.new()

# ── Guard helpers ──────────────────────────────────────────────────────────────
# Returns empty dict on success; returns error map_command_result on failure.
# Callers: if not pre.is_empty(): return pre

func _check_player(state: WorldState) -> Dictionary:
    if state.player_id == -1 or not state.persons.has(state.player_id):
        return PlayerApiMapper.map_command_result(false, "no_player", "no player", {})
    return {}

func _check_controlled_team(state: WorldState) -> Dictionary:
    var pre := _check_player(state)
    if not pre.is_empty():
        return pre
    var p: PersonData = state.persons[state.player_id]
    if not state.teams.has(p.team_id):
        return PlayerApiMapper.map_command_result(false, "no_controlled_team", "no controlled team", {})
    return {}

# ── Commands ───────────────────────────────────────────────────────────────────

func move_to(state: WorldState, tile_q: int, tile_r: int) -> Dictionary:
    var pre := _check_controlled_team(state)
    if not pre.is_empty(): return pre
    var result := _cmd_sys.move_to(state, Vector2i(tile_q, tile_r))
    if result.get("ok", false):
        return PlayerApiMapper.map_command_result(true, "ok", result.get("msg", ""),
            {"move_target": {"q": tile_q, "r": tile_r}, "refresh_required": true})
    var code: String = "invalid_tile" if "格" in result.get("msg", "") else "move_unavailable"
    return PlayerApiMapper.map_command_result(false, code, result.get("msg", ""), {})

func cancel_move(state: WorldState) -> Dictionary:
    var pre := _check_controlled_team(state)
    if not pre.is_empty(): return pre
    var result := _cmd_sys.cancel_move(state)
    if result.get("ok", false):
        return PlayerApiMapper.map_command_result(true, "ok", result.get("msg", ""),
            {"move_cancelled": true, "refresh_required": true})
    return PlayerApiMapper.map_command_result(false, "move_unavailable", result.get("msg", ""), {})

func execute_action(state: WorldState, action_id: String, target: Dictionary) -> Dictionary:
    var pre := _check_controlled_team(state)
    if not pre.is_empty(): return pre
    if action_id == "":
        return PlayerApiMapper.map_command_result(false, "invalid_request", "action_id required", {})
    var kind: String = target.get("kind", "none")
    var target_team_id: int = target.get("team_id", -1)
    var result: Dictionary
    match kind:
        "team":
            if not state.teams.has(target_team_id):
                return PlayerApiMapper.map_command_result(false, "invalid_target", "target team not found", {})
            result = _cmd_sys.execute_action(state, target_team_id, action_id)
        "none":
            result = _cmd_sys.execute_action(state, -1, action_id)
        _:
            return PlayerApiMapper.map_command_result(false, "invalid_target", "unsupported target kind: %s" % kind, {})
    if result.get("ok", false):
        return PlayerApiMapper.map_command_result(true, "ok", result.get("msg", ""),
            {"action_id": action_id, "result_summary": result.get("msg", ""), "refresh_required": true})
    return PlayerApiMapper.map_command_result(false, "action_unavailable", result.get("msg", ""), {})

func respond_to_forced(state: WorldState, interaction_id: String, response_id: String) -> Dictionary:
    var pre := _check_player(state)
    if not pre.is_empty(): return pre
    var result := _cmd_sys.resolve_forced_response(state, interaction_id, response_id)
    if result.has("code"):
        return PlayerApiMapper.map_command_result(false, result["code"], result.get("msg", ""), {})
    if result.get("ok", false):
        return PlayerApiMapper.map_command_result(true, "ok", result.get("msg", ""),
            {"forced_interaction_resolved": true, "refresh_required": true})
    return PlayerApiMapper.map_command_result(false, "action_unavailable", result.get("msg", ""), {})

func equip_item(state: WorldState, slot_id: String, item_grade: String) -> Dictionary:
    var pre := _check_player(state)
    if not pre.is_empty(): return pre
    if slot_id == "" or item_grade == "":
        return PlayerApiMapper.map_command_result(false, "invalid_request", "slot_id and item_grade required", {})
    var ok: bool = _ps.equip_item(state, slot_id, item_grade)
    if ok:
        return PlayerApiMapper.map_command_result(true, "ok", "裝備 %s → %s" % [item_grade, slot_id],
            {"equipped_slot": slot_id, "item_grade": item_grade, "refresh_required": true})
    return PlayerApiMapper.map_command_result(false, "equip_unavailable", "無法裝備", {})

func unequip_item(state: WorldState, slot_id: String) -> Dictionary:
    var pre := _check_player(state)
    if not pre.is_empty(): return pre
    if slot_id == "":
        return PlayerApiMapper.map_command_result(false, "invalid_request", "slot_id required", {})
    var ok: bool = _ps.unequip_item(state, slot_id)
    if ok:
        return PlayerApiMapper.map_command_result(true, "ok", "卸下 %s" % slot_id,
            {"unequipped_slot": slot_id, "refresh_required": true})
    return PlayerApiMapper.map_command_result(false, "equip_unavailable", "無法卸裝", {})

func deposit_item(state: WorldState, item_grade: String, qty: int) -> Dictionary:
    var pre := _check_controlled_team(state)
    if not pre.is_empty(): return pre
    if item_grade == "":
        return PlayerApiMapper.map_command_result(false, "invalid_request", "item_grade required", {})
    if qty <= 0:
        return PlayerApiMapper.map_command_result(false, "invalid_request", "qty must be > 0", {})
    var ok: bool = _ps.deposit_to_team(state, item_grade, qty)
    if ok:
        return PlayerApiMapper.map_command_result(true, "ok", "存入 %s×%d" % [item_grade, qty],
            {"item_grade": item_grade, "qty": qty, "refresh_required": true})
    return PlayerApiMapper.map_command_result(false, "deposit_unavailable", "無法存入", {})

func take_team_item(state: WorldState, item_grade: String, qty: int) -> Dictionary:
    var pre := _check_controlled_team(state)
    if not pre.is_empty(): return pre
    if item_grade == "":
        return PlayerApiMapper.map_command_result(false, "invalid_request", "item_grade required", {})
    if qty <= 0:
        return PlayerApiMapper.map_command_result(false, "invalid_request", "qty must be > 0", {})
    var ok: bool = _ps.take_from_team(state, item_grade, qty)
    if ok:
        return PlayerApiMapper.map_command_result(true, "ok", "取出 %s×%d" % [item_grade, qty],
            {"item_grade": item_grade, "qty": qty, "refresh_required": true})
    return PlayerApiMapper.map_command_result(false, "take_unavailable", "無法取出", {})

# ── Dispatch ───────────────────────────────────────────────────────────────────

func dispatch(state: WorldState, name: String, args: Dictionary) -> Dictionary:
    match name:
        "move_to":
            return move_to(state, args.get("tile_q", -1), args.get("tile_r", -1))
        "cancel_move":
            return cancel_move(state)
        "execute_action":
            return execute_action(state, args.get("action_id", ""), args.get("target", {}))
        "respond_to_forced":
            return respond_to_forced(state, args.get("interaction_id", ""), args.get("response_id", ""))
        "equip_item":
            return equip_item(state, args.get("slot_id", ""), args.get("item_grade", ""))
        "unequip_item":
            return unequip_item(state, args.get("slot_id", ""))
        "deposit_item":
            return deposit_item(state, args.get("item_grade", ""), args.get("qty", 0))
        "take_team_item":
            return take_team_item(state, args.get("item_grade", ""), args.get("qty", 0))
    return PlayerApiMapper.map_command_result(false, "invalid_request", "unknown command: %s" % name, {})
```

- [ ] **Step 4: Run import + tests**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --import
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd 2>&1 | Select-String -Pattern "DONE|SCRIPT ERROR|PlayerCommandApi"
```
Expected: `PlayerCommandApi: ALL PASS`, `=== DONE ===`

- [ ] **Step 5: Commit**

```
git add scripts/simulation/player_command_api.gd scripts/debug/headless_test.gd
git commit -m "feat(player-api): add PlayerCommandApi validate+dispatch layer"
```

---

## Chunk 5: SimBridge — public player API facade

### Task 5.1: Add player API methods to sim_bridge.gd

**Files:**
- Modify: `scripts/ui/sim_bridge.gd`

The current `sim_bridge.gd` is ~106 lines. It has a `_state` member. Add `_query_api` and `_cmd_api` members to `_init`, then add 6 public methods.

- [ ] **Step 1: Add member variables**

In `sim_bridge.gd`, find the member variable declarations (near the top, after `extends RefCounted` or similar). Add:

```gdscript
var _query_api: PlayerQueryApi = PlayerQueryApi.new()
var _cmd_api: PlayerCommandApi = PlayerCommandApi.new()
```

These should be declared at the class level, not inside a function.

- [ ] **Step 2: Add 6 public methods**

At the end of `sim_bridge.gd`, before the final closing (if any), add:

```gdscript
# ── Player API (query / command) ───────────────────────────────────────────────

func query_player(request: Dictionary) -> Dictionary:
    return _query_api.get_player_snapshot(_state, request)

func query_player_team(team_id: int) -> Dictionary:
    return _query_api.get_team_details(_state, team_id)

func query_player_member(team_id: int, member_id: int) -> Dictionary:
    return _query_api.get_member_details(_state, team_id, member_id)

func query_player_location(tile_q: int, tile_r: int) -> Dictionary:
    return _query_api.get_location_context(_state, tile_q, tile_r)

func query_player_actions(request: Dictionary) -> Dictionary:
    return _query_api.get_available_actions(_state, request)

func command_player(name: String, args: Dictionary) -> Dictionary:
    return _cmd_api.dispatch(_state, name, args)
```

- [ ] **Step 3: Run full headless test**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd 2>&1 | Select-String -Pattern "DONE|SCRIPT ERROR"
```
Expected: `=== DONE ===`, no `SCRIPT ERROR`

- [ ] **Step 4: Commit**

```
git add scripts/ui/sim_bridge.gd
git commit -m "feat(player-api): add SimBridge player query/command facade methods"
```

---

## Chunk 6: UI Migration

### Task 6.1: Migrate popup_layer.gd

**Files:**
- Modify: `scripts/ui/popup_layer.gd`

Currently calls `PlayerSystem.new()` directly for equip/unequip/take/store operations. Replace with `_bridge.command_player(...)`.

**Important:** Check how `_bridge` is accessed in `popup_layer.gd` before replacing. It may be passed as a constructor argument or accessed via a node path. Use whatever access pattern already exists in the file.

- [ ] **Step 1: Read popup_layer.gd and find PlayerSystem.new() calls**

```powershell
Select-String -Path "scripts\ui\popup_layer.gd" -Pattern "PlayerSystem" | Select-Object LineNumber, Line
```

- [ ] **Step 2: Understand _bridge access pattern**

```powershell
Select-String -Path "scripts\ui\popup_layer.gd" -Pattern "_bridge|bridge" | Select-Object LineNumber, Line
```

If `_bridge` is not already accessible, check how the popup is initialized (look at the `_init` or `_ready` functions and how it's called from `text_ui_main.gd` or `main.gd`).

- [ ] **Step 3: Replace `_do_equip` call**

Find the `_do_equip` method and replace the `PlayerSystem.new().equip_item(...)` call with:

```gdscript
_bridge.command_player("equip_item", {"slot_id": slot, "item_grade": grade})
```

Where `slot` and `grade` are the local variable names in that method.

- [ ] **Step 4: Replace `_do_unequip` call**

Find the `_do_unequip` method and replace the `PlayerSystem.new().unequip_item(...)` call with:

```gdscript
_bridge.command_player("unequip_item", {"slot_id": slot})
```

- [ ] **Step 5: Replace `_do_take` call**

Find the `_do_take` method and replace the `PlayerSystem.new().take_from_team(...)` call with:

```gdscript
_bridge.command_player("take_team_item", {"item_grade": grade, "qty": qty})
```

Where `grade` and `qty` are the local variable names.

- [ ] **Step 6: Replace `_do_store` call**

Find the `_do_store` method and replace the `PlayerSystem.new().deposit_to_team(...)` call with:

```gdscript
_bridge.command_player("deposit_item", {"item_grade": grade, "qty": qty})
```

- [ ] **Step 7: Run test**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd 2>&1 | Select-String -Pattern "DONE|SCRIPT ERROR"
```
Expected: `=== DONE ===`

---

### Task 6.2: Migrate main.gd

**Files:**
- Modify: `scripts/ui/main.gd`

Currently writes `team.move_target = pos` directly in `_on_set_move_target`.

- [ ] **Step 1: Read the current implementation**

```powershell
Select-String -Path "scripts\ui\main.gd" -Pattern "move_target|_on_set_move_target" | Select-Object LineNumber, Line
```

- [ ] **Step 2: Read how _bridge is accessed in main.gd**

```powershell
Select-String -Path "scripts\ui\main.gd" -Pattern "_bridge|SimBridge" | Select-Object LineNumber, Line
```

- [ ] **Step 3: Replace direct write with bridge command**

Find the `_on_set_move_target` method. The current body likely looks like:
```gdscript
func _on_set_move_target(pos: Vector2i) -> void:
    var team = ...
    team.move_target = pos
```

Replace the `team.move_target = pos` line (or the whole body) with:
```gdscript
func _on_set_move_target(pos: Vector2i) -> void:
    _bridge.command_player("move_to", {"tile_q": pos.x, "tile_r": pos.y})
```

Verify what the `pos` parameter represents (it should already be `Vector2i` in tile coords).

- [ ] **Step 4: Run test**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd 2>&1 | Select-String -Pattern "DONE|SCRIPT ERROR"
```
Expected: `=== DONE ===`

---

### Task 6.3: Migrate text_ui_main.gd

**Files:**
- Modify: `scripts/ui/text_ui_main.gd`

This is the most complex migration. Currently reads `_state.player_pending_targets`, `_state.player_forced_event`, `_state.player_state`, `_state.encounter_active` directly. Has `_player_cmd: PlayerCommandSystem`.

**Scope:** Only migrate player API reads/writes. Keep `_state` for the debug bar and map renderer (non-player reads are out of scope per spec).

**Strategy:**
1. Add `_cached_snapshot: Dictionary = {}` member
2. Add `_get_player_snapshot()` helper that calls `_bridge.query_player({})` and caches
3. In `_refresh()` (or wherever UI is updated), call `_get_player_snapshot()` at the top
4. Replace each `_state.player_forced_event` read with `_cached_snapshot.get("data", {}).get("snapshot", {}).get("forced_interaction", {})` (or a local variable extracted from snapshot)
5. Replace `_player_cmd.*` calls with `_bridge.command_player(...)`

- [ ] **Step 1: Read current direct player state accesses**

```powershell
Select-String -Path "scripts\ui\text_ui_main.gd" -Pattern "player_forced_event|player_pending_targets|player_state|encounter_active|_player_cmd" | Select-Object LineNumber, Line
```

- [ ] **Step 2: Add cached snapshot member and helper**

At the class variable declarations (near top of file), add:
```gdscript
var _cached_snapshot: Dictionary = {}
```

Add a helper method (near other private methods):
```gdscript
func _refresh_snapshot() -> void:
    var result := _bridge.query_player({})
    if result.get("ok", false):
        _cached_snapshot = result.get("data", {}).get("snapshot", {})
    else:
        _cached_snapshot = {}
```

- [ ] **Step 3: Call _refresh_snapshot() in _refresh()**

Find the `_refresh()` method (or equivalent UI update method). At the very start of the method body, add:
```gdscript
_refresh_snapshot()
```

- [ ] **Step 4: Replace _state.encounter_active**

Find each read of `_state.encounter_active` and replace with:
```gdscript
_cached_snapshot.get("player_summary", {}).get("encounter_active", false)
```

- [ ] **Step 5: Replace _state.player_forced_event reads**

For checking if forced event is active, replace `not _state.player_forced_event.is_empty()` with:
```gdscript
_cached_snapshot.get("forced_interaction", {}).get("interaction_id", "") != ""
```

For reading the event content (e.g., action type, from_id), read from:
```gdscript
var fi := _cached_snapshot.get("forced_interaction", {})
# fi["interaction_type"], fi["source"]["team_id"], fi["message"], fi["responses"]
```

- [ ] **Step 6: Replace _state.player_pending_targets reads**

Replace reads of `_state.player_pending_targets` with:
```gdscript
_cached_snapshot.get("pending_targets", [])
```

Each entry is `{"target_type": "team", "target_id": int, "display_name": String, "is_valid": bool}`.
If the code iterated over raw int IDs, update iteration accordingly.

- [ ] **Step 7: Replace _state.player_state reads**

Replace reads of `_state.player_state` (inventory access) with:
```gdscript
_cached_snapshot.get("inventory_state", {})
```

- [ ] **Step 8: Replace _player_cmd calls**

For each `_player_cmd.respond_to_forced(state, resp)` call, replace with:
```gdscript
var fi_id: String = _cached_snapshot.get("forced_interaction", {}).get("interaction_id", "")
_bridge.command_player("respond_to_forced", {"interaction_id": fi_id, "response_id": resp})
```

For each `_player_cmd.cancel_move(state)` call, replace with:
```gdscript
_bridge.command_player("cancel_move", {})
```

For each `_player_cmd.execute_action(state, target_id, action)` call, replace with:
```gdscript
_bridge.command_player("execute_action", {
    "action_id": action,
    "target": {"kind": "team", "team_id": target_id, "member_id": -1, "tile_q": -1, "tile_r": -1}
})
```

For each `_player_cmd.clear_pending_targets(state)` call, keep using `_bridge.command_player` if that command is exposed, or keep calling `_player_cmd.clear_pending_targets(state)` directly (it's an internal helper, not a public API — keep it for now; spec migration scope does not require removing it from UI).

- [ ] **Step 9: Remove `_player_cmd` member if no longer used**

Check if `_player_cmd` is referenced anywhere after the above replacements:
```powershell
Select-String -Path "scripts\ui\text_ui_main.gd" -Pattern "_player_cmd" | Select-Object LineNumber, Line
```

If only `clear_pending_targets` remains, keep `_player_cmd` for that. If nothing remains, remove the declaration.

- [ ] **Step 10: Run full headless test**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd 2>&1 | Select-String -Pattern "DONE|SCRIPT ERROR"
```
Expected: `=== DONE ===`, no `SCRIPT ERROR`

- [ ] **Step 11: Commit**

```
git add scripts/ui/popup_layer.gd scripts/ui/main.gd scripts/ui/text_ui_main.gd
git commit -m "feat(player-api): migrate UI from direct WorldState reads to SimBridge facade"
```

---

## Chunk 7: Tests + Docs

### Task 7.1: Add SimBridge integration tests to headless_test.gd

**Files:**
- Modify: `scripts/debug/headless_test.gd`

Verify the bridge dispatch layer works end-to-end using the existing sim state that the headless test builds.

- [ ] **Step 1: Add bridge integration test section**

Locate the existing PlayerCommandSystem test block (around lines 1509–1602). After it, add:

```gdscript
# ── SimBridge player API integration ──────────────────────────────────────────
print("\n--- SimBridge Player API ---")
# Note: _bridge is the SimBridge created earlier in this test file.
# Verify it has the new methods by checking the response envelope shape.

# query_player — should return ok=true with snapshot key (assumes player exists at this point)
var _sb_q1 := _bridge.query_player({})
assert(_sb_q1 is Dictionary, "query_player returns dict")
assert(_sb_q1.has("ok"), "query_player has ok")
assert(_sb_q1.has("code"), "query_player has code")
print("query_player shape: OK  (ok=%s, code=%s)" % [str(_sb_q1["ok"]), _sb_q1["code"]])

# command_player — unknown command returns error envelope
var _sb_c1 := _bridge.command_player("nonexistent_cmd", {})
assert(_sb_c1["ok"] == false, "command_player unknown returns false")
assert(_sb_c1["code"] == "invalid_request", "command_player unknown code")
print("command_player (unknown): OK")

# command_player — cancel_move (may fail if no move target, that is OK — just check shape)
var _sb_c2 := _bridge.command_player("cancel_move", {})
assert(_sb_c2 is Dictionary, "cancel_move returns dict")
assert(_sb_c2.has("ok"), "cancel_move has ok")
print("command_player cancel_move shape: OK  (ok=%s)" % str(_sb_c2["ok"]))

print("SimBridge Player API: ALL PASS")
```

- [ ] **Step 2: Run full headless test**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd 2>&1 | Select-String -Pattern "DONE|SCRIPT ERROR|SimBridge Player"
```
Expected: `SimBridge Player API: ALL PASS`, `=== DONE ===`, no `SCRIPT ERROR`

---

### Task 7.2: Update docs/progress.md

**Files:**
- Modify: `docs/progress.md`

- [ ] **Step 1: Update progress doc**

Add a new section or update the existing status table. Include:

- New files created:
  - `scripts/simulation/player_api_mapper.gd` — static DTO mapping
  - `scripts/simulation/player_query_api.gd` — snapshot query composition
  - `scripts/simulation/player_command_api.gd` — command validate + dispatch
- Modified files:
  - `scripts/data/world_state.gd` — added `player_forced_event_id`
  - `scripts/simulation/interaction_system.gd` — sets `player_forced_event_id`
  - `scripts/simulation/sim_runner.gd` — clears `player_forced_event_id` on timeout
  - `scripts/simulation/player_command_system.gd` — added `resolve_forced_response`, `get_forced_response_options`
  - `scripts/ui/sim_bridge.gd` — added 6 public player API methods
  - `scripts/ui/popup_layer.gd` — migrated to bridge commands
  - `scripts/ui/main.gd` — migrated move_target write to bridge
  - `scripts/ui/text_ui_main.gd` — migrated player state reads to snapshot cache

---

### Task 7.3: Final smoke test + push

- [ ] **Step 1: Run full headless test**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd 2>&1 | Select-String -Pattern "DONE|SCRIPT ERROR|FAILED"
```
Expected: `=== DONE ===`, no `SCRIPT ERROR`, no `FAILED`

- [ ] **Step 2: Commit docs**

```
git add docs/progress.md scripts/debug/headless_test.gd
git commit -m "docs: update progress.md after player API boundary migration"
```

- [ ] **Step 3: Push branch**

```powershell
git push -u origin feat/player-api-boundary
```

- [ ] **Step 4: Write handback**

Create `docs/superpowers/handbacks/YYYY-MM-DD-player-api-boundary.md` following the template in `docs/process/03_implementer.md`.
