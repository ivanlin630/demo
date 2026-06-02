# Alliance & Faction (G3, G5) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement G3 (establish_faction action), G5 (propose_alliance when both independent: player becomes leader), and 收編防護 (NPC-initiated alliance gives 3 responses when both independent).

**Architecture:** Pure simulation changes — no new UI. `establish_faction` added as action in `player_command_system.execute_action`. G5 fix: add `create_faction(pt_id)` call in `propose_alliance` branch. 收編防護: `player_api_mapper.map_forced_interaction` generates 3 responses; `player_command_system.respond_to_forced` handles `accept_lead` and `accept_join`.

**Tech Stack:** Godot 4.2.2 GDScript — player_command_system.gd, player_api_mapper.gd

**Depends on:** interaction-ui-framework plan (establish_faction appears in Layer 5 available_actions, player_query_api changes already done there)

---

### Task 1: player_command_system — establish_faction action

**Files:**
- Modify: `scripts/simulation/player_command_system.gd`

- [ ] **Step 1: Add establish_faction() method**

After `cancel_move()` function, add:

```gdscript
func establish_faction(state: WorldState) -> Dictionary:
    var pt: TeamData = _get_player_team(state)
    var pt_id: int   = _get_player_team_id(state)
    if pt == null:
        return { "ok": false, "code": "no_controlled_team",
                 "message": "找不到玩家隊伍", "payload": {} }
    if pt.faction_id != -1:
        return { "ok": false, "code": "action_unavailable",
                 "message": "已屬勢力%d" % pt.faction_id, "payload": {} }
    state.create_faction(pt_id)
    print("[PlayerCmd] 玩家建立勢力%d" % pt.faction_id)
    return { "ok": true, "code": "ok",
             "message": "建立勢力%d" % pt.faction_id,
             "payload": {"action_id": "establish_faction", "refresh_required": true} }
```

- [ ] **Step 2: Add "establish_faction" case in execute_action()**

In `execute_action()`, before `"ignore":` case, add:

```gdscript
"establish_faction":
    return establish_faction(state)
```

- [ ] **Step 3: Run headless test**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```
Expected: `=== DONE ===`, no `SCRIPT ERROR`.

- [ ] **Step 4: Commit**

```
git add scripts/simulation/player_command_system.gd
git commit -m "feat(sim): add establish_faction action to player_command_system"
```

---

### Task 2: player_command_system — G5 fix propose_alliance

**Files:**
- Modify: `scripts/simulation/player_command_system.gd`

Current `execute_action("propose_alliance")` (lines 47-54) does NOT call `create_faction` or `_form_alliance`.

- [ ] **Step 1: Replace "propose_alliance" case**

Replace:
```gdscript
"propose_alliance":
    var tgt: TeamData = state.teams.get(target_id)
    if tgt == null:
        return { "ok": false, "msg": "目標不存在" }
    var resp: String = _diplomatic.handle_diplomacy_message(
        state, tgt, pt, "propose_alliance")
    state.player_pending_targets.erase(target_id)
    return { "ok": resp == "accept", "msg": "外交結果: %s" % resp }
```

with:
```gdscript
"propose_alliance":
    var tgt: TeamData = state.teams.get(target_id)
    if tgt == null:
        return { "ok": false, "msg": "目標不存在" }
    var resp: String = _diplomatic.handle_diplomacy_message(
        state, tgt, pt, "propose_alliance")
    if resp == "accept":
        if pt.faction_id == -1 and tgt.faction_id == -1:
            state.create_faction(pt_id)   # 玩家為領袖（G5 修正）
        _diplomatic._form_alliance(state, pt, tgt)
        print("[PlayerCmd] 同盟成立，勢力%d" % pt.faction_id)
    state.player_pending_targets.erase(target_id)
    return { "ok": resp == "accept", "msg": "外交結果: %s" % resp }
```

- [ ] **Step 2: Run headless test**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```
Expected: `=== DONE ===`, no `SCRIPT ERROR`. May see `[PlayerCmd] 同盟成立` prints.

- [ ] **Step 3: Commit**

```
git add scripts/simulation/player_command_system.gd
git commit -m "fix(sim): G5 propose_alliance now calls create_faction+_form_alliance when both independent"
```

---

### Task 3: player_command_system — respond_to_forced with accept_lead / accept_join

**Files:**
- Modify: `scripts/simulation/player_command_system.gd`

- [ ] **Step 1: Update get_forced_response_options diplomacy branch**

Replace:
```gdscript
"diplomacy": return ["accept", "refuse"]
```
with:
```gdscript
"diplomacy":
    return ["accept", "accept_join", "accept_lead", "refuse"]
```

- [ ] **Step 2: Update respond_to_forced "diplomacy" case**

Replace the current `"diplomacy":` match arm in `respond_to_forced()`:
```gdscript
"diplomacy":
    if response == "accept":
        result = _accept_diplomacy(state,
            fe.get("from_id", -1), fe.get("proposal", "alliance"))
    else:
        result = { "ok": true, "msg": "拒絕外交提案" }
```
with:
```gdscript
"diplomacy":
    match response:
        "accept", "accept_join":
            result = _accept_diplomacy(state,
                fe.get("from_id", -1), fe.get("proposal", "alliance"))
        "accept_lead":
            result = _accept_diplomacy_as_leader(state, fe.get("from_id", -1))
        "refuse":
            result = { "ok": true, "msg": "拒絕外交提案" }
        _:
            result = { "ok": false, "msg": "未知回應: %s" % response }
```

- [ ] **Step 3: Add _accept_diplomacy_as_leader()**

After `_accept_diplomacy()` function, add:

```gdscript
func _accept_diplomacy_as_leader(state: WorldState, from_id: int) -> Dictionary:
    var from_team: TeamData = state.teams.get(from_id)
    var pt: TeamData = _get_player_team(state)
    var pt_id: int   = _get_player_team_id(state)
    if from_team == null or pt == null:
        return { "ok": false, "msg": "隊伍不存在" }
    if pt.faction_id == -1:
        state.create_faction(pt_id)
    _diplomatic._form_alliance(state, pt, from_team)
    return { "ok": true, "msg": "自立後接納 Team%d，勢力%d" % [from_id, pt.faction_id] }
```

- [ ] **Step 4: Run headless test**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```
Expected: `=== DONE ===`, no `SCRIPT ERROR`.

- [ ] **Step 5: Commit**

```
git add scripts/simulation/player_command_system.gd
git commit -m "feat(sim): add accept_lead/accept_join branches to respond_to_forced"
```

---

### Task 4: player_api_mapper — 收編防護 3-way responses

**Files:**
- Modify: `scripts/simulation/player_api_mapper.gd`

- [ ] **Step 1: Replace map_forced_interaction "diplomacy" case**

In `map_forced_interaction()` (around line 207), replace the `"diplomacy":` arm:

```gdscript
"diplomacy":
    msg = "Team%d 提議 %s" % [from_id, proposal]
    var from_team: TeamData = state.teams.get(from_id) if state.teams.has(from_id) else null
    var player_pid: int = state.player_id
    var pp: PersonData = state.persons.get(player_pid) if state.persons.has(player_pid) else null
    var player_team: TeamData = state.teams.get(pp.team_id if pp != null else -1) if pp != null else null
    var both_independent: bool = from_team != null and player_team != null \
        and from_team.faction_id == -1 and player_team.faction_id == -1 \
        and evt.get("proposal", "") in ["alliance", "surrender"]

    if both_independent:
        responses = [
            { "response_id": "accept_join",  "label": "加入對方勢力（對方為主）",
              "command_args": {"interaction_id": iid, "response_id": "accept_join"} },
            { "response_id": "accept_lead",  "label": "自立後接納對方（我為主）",
              "command_args": {"interaction_id": iid, "response_id": "accept_lead"} },
            { "response_id": "refuse",       "label": "✗ 拒絕",
              "command_args": {"interaction_id": iid, "response_id": "refuse"} }
        ]
    else:
        responses = [
            {"response_id": "accept", "label": "✓ 接受",
             "command_args": {"interaction_id": iid, "response_id": "accept"}},
            {"response_id": "refuse", "label": "✗ 拒絕",
             "command_args": {"interaction_id": iid, "response_id": "refuse"}}
        ]
```

Note: `map_forced_interaction` is a `static func`, so `state` is available as a parameter already.

- [ ] **Step 2: Run headless test**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```
Expected: `=== DONE ===`, no `SCRIPT ERROR`.

- [ ] **Step 3: Commit**

```
git add scripts/simulation/player_api_mapper.gd
git commit -m "feat(sim): map_forced_interaction generates 3 responses when both teams independent"
```

---

## 驗證

| 情境 | 預期 |
|---|---|
| `pt.faction_id == -1` → available_actions | `establish_faction` action 出現 |
| 玩家發起同盟，NPC 接受，雙方獨立 | `pt.faction_id >= 0`（玩家為主），NPC 加入同勢力 |
| NPC 發起同盟，雙方獨立 | forced_interaction.responses 有 3 個選項 |
| 選「自立後接納」 | `_accept_diplomacy_as_leader` 執行，玩家為主 |
| NPC 發起同盟，玩家已有勢力 | 只有 accept/refuse 2 個 |
