# Interaction UI Framework Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Wire the "互動" button in right_sidebar through main.gd to the popup_layer, implementing the full interaction panel, forced-event panel, and loot panel using only the player API boundary.

**Architecture:** right_sidebar emits `open_interaction` signal → main.gd calls `refresh_interaction_targets()` then `query_player()` and dispatches to popup_layer. All reads via `_bridge.query_player()`, all writes via `_bridge.command_player()`. popup_layer receives DTOs only.

**Tech Stack:** Godot 4.2.2 GDScript, existing SimBridge / PlayerQueryApi / PlayerCommandApi

---

### Task 1: right_sidebar — wire "互動" button signal

**Files:**
- Modify: `scripts/ui/right_sidebar.gd:13-17` (signal block), `scripts/ui/right_sidebar.gd:59-63` (_make_btn / _on_move area)

- [ ] **Step 1: Add signal declaration**

In `right_sidebar.gd`, after `signal set_move_target(pos: Vector2i)` (line 17), add:

```gdscript
signal open_interaction()
```

- [ ] **Step 2: Connect "互動" button**

In `_build_ui()` (line 49), replace the stub:
```gdscript
_make_btn("互動", row1)
```
with:
```gdscript
_make_btn("互動", row1).pressed.connect(_on_interact)
```

- [ ] **Step 3: Add handler**

After `_on_history()` (end of file), add:
```gdscript
func _on_interact() -> void:
    open_interaction.emit()
```

- [ ] **Step 4: Run headless test — verify no SCRIPT ERROR**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```
Expected: `=== DONE ===`, no `SCRIPT ERROR`.

- [ ] **Step 5: Commit**

```
git add scripts/ui/right_sidebar.gd
git commit -m "feat(ui): add open_interaction signal to right_sidebar"
```

---

### Task 2: main.gd — connect open_interaction and implement _on_open_interaction

**Files:**
- Modify: `scripts/ui/main.gd`

- [ ] **Step 1: Connect signal in _ready()**

In `main.gd`, after `_sidebar.open_history.connect(...)` (line 73), add:
```gdscript
_sidebar.open_interaction.connect(_on_open_interaction)
```

- [ ] **Step 2: Add _on_open_interaction()**

After `_on_set_move_target()` function, add:
```gdscript
func _on_open_interaction() -> void:
    _bridge.refresh_interaction_targets()
    var snap: Dictionary = _bridge.query_player().get("data", {}).get("snapshot", {})
    var pending: Array = snap.get("pending_targets", [])
    var forced: Dictionary = snap.get("forced_interaction", {})

    # Forced interaction takes priority
    if not forced.get("responses", []).is_empty():
        _popups.show_forced_event(forced,
            func(cmd_args: Dictionary) -> void:
                var r = _bridge.command_player("respond_to_forced", cmd_args)
                _bottom.add_message("[強制] %s" % r.get("message", ""))
                _sidebar.refresh_player(); _debug.refresh())
        return

    if pending.is_empty():
        _bottom.add_message("[互動] 附近無可互動目標")
        return

    _popups.show_interaction(pending,
        func(tid: int) -> void:
            var actions_result := _bridge.query_player_actions({
                "team_id": tid, "member_id": -1, "tile_q": -1, "tile_r": -1
            })
            var acts: Array = actions_result.get("data", {}).get("actions", [])
            _popups.show_action_menu(tid, acts, _on_interact_execute))
```

- [ ] **Step 3: Add _on_interact_execute()**

```gdscript
func _on_interact_execute(cmd_name: String, cmd_args: Dictionary) -> void:
    var result: Dictionary = _bridge.command_player(cmd_name, cmd_args)
    _sidebar.refresh_player(); _debug.refresh()
    var action_id: String = cmd_args.get("action_id", "")

    if action_id == "attack" and result.get("ok"):
        _map.visible = false; _encounter.show_encounter(); return

    if action_id == "trade" and result.get("ok") and result.get("payload", {}).get("requires_preview"):
        var tid: int = result.get("payload", {}).get("preview_target_id", -1)
        var pr := _bridge.query_player({"focus_team_id": tid})
        # trade preview handled by trade plan
        return

    if action_id == "recruit" and result.get("ok"):
        var payload: Dictionary = result.get("payload", {})
        if payload.get("has_willing_named", false):
            # recruit panel handled by recruit plan
            return

    _bottom.add_message("[互動] %s" % result.get("message", "完成"))
```

- [ ] **Step 4: Run headless test**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```
Expected: `=== DONE ===`, no `SCRIPT ERROR`.

- [ ] **Step 5: Commit**

```
git add scripts/ui/main.gd
git commit -m "feat(ui): wire open_interaction flow in main.gd"
```

---

### Task 3: popup_layer — show_interaction() and show_action_menu()

**Files:**
- Modify: `scripts/ui/popup_layer.gd`

- [ ] **Step 1: Add show_interaction()**

After `show_inventory()` function (before `_add_item_action_buttons`), add:

```gdscript
# pending_targets: Array of {target_type, target_id, display_name, is_valid}
# on_select: Callable(team_id: int)
func show_interaction(pending_targets: Array, on_select: Callable) -> void:
    _close_current()
    var popup := _make_base_popup("互動目標")
    var vbox: VBoxContainer = popup.get_node("VBox/Scroll/Content")

    for tgt in pending_targets:
        if not tgt.get("is_valid", false): continue
        var tid: int = tgt.get("target_id", -1)
        var btn := Button.new()
        btn.text = tgt.get("display_name", "Team%d" % tid)
        var cap_tid: int = tid
        btn.pressed.connect(func():
            _close_current()
            on_select.call(cap_tid))
        vbox.add_child(btn)

    if vbox.get_child_count() == 0:
        var lbl := Label.new(); lbl.text = "（無可用目標）"; vbox.add_child(lbl)

    _current_popup = popup; add_child(popup)
```

- [ ] **Step 2: Add show_action_menu()**

```gdscript
# actions: Array of available_action DTOs from player_query_api
# on_execute: Callable(cmd_name: String, cmd_args: Dictionary)
func show_action_menu(target_team_id: int, actions: Array, on_execute: Callable) -> void:
    _close_current()
    var popup := _make_base_popup("對 Team%d 的行動" % target_team_id)
    var vbox: VBoxContainer = popup.get_node("VBox/Scroll/Content")

    for act in actions:
        # Skip forced_* actions here (handled by show_forced_event)
        if str(act.get("action_id", "")).begins_with("forced_"): continue
        var btn := Button.new()
        btn.text = act.get("label", act.get("action_id", "?"))
        btn.disabled = not act.get("enabled", true)
        var tooltip: String = act.get("disabled_reason", "")
        if tooltip != "": btn.tooltip_text = tooltip
        var cmd_name: String = act.get("command_name", "")
        var cmd_args: Dictionary = act.get("command_args", {})
        btn.pressed.connect(func():
            _close_current()
            on_execute.call(cmd_name, cmd_args))
        vbox.add_child(btn)

    var cancel_btn := Button.new(); cancel_btn.text = "取消"
    cancel_btn.pressed.connect(_close_current)
    vbox.add_child(cancel_btn)

    _current_popup = popup; add_child(popup)
```

- [ ] **Step 3: Add show_forced_event()**

```gdscript
# fi_dto: forced_interaction dict from snapshot
# on_respond: Callable(cmd_args: Dictionary)
func show_forced_event(fi_dto: Dictionary, on_respond: Callable) -> void:
    _close_current()
    var popup := _make_base_popup("強制事件")
    var vbox: VBoxContainer = popup.get_node("VBox/Scroll/Content")

    var msg_lbl := Label.new()
    msg_lbl.text = fi_dto.get("message", "")
    msg_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD
    vbox.add_child(msg_lbl)

    vbox.add_child(HSeparator.new())

    for resp in fi_dto.get("responses", []):
        var btn := Button.new()
        btn.text = resp.get("label", resp.get("response_id", "?"))
        var cap_args: Dictionary = resp.get("command_args", {})
        btn.pressed.connect(func():
            _close_current()
            on_respond.call(cap_args))
        vbox.add_child(btn)

    _current_popup = popup; add_child(popup)
```

- [ ] **Step 4: Run headless test**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```
Expected: `=== DONE ===`, no `SCRIPT ERROR`.

- [ ] **Step 5: Commit**

```
git add scripts/ui/popup_layer.gd
git commit -m "feat(ui): add show_interaction, show_action_menu, show_forced_event to popup_layer"
```

---

### Task 4: main.gd — _on_tick_advanced forced event polling + _on_encounter_ended

**Files:**
- Modify: `scripts/ui/main.gd`

- [ ] **Step 1: Update _on_tick_advanced to poll forced event**

Replace the existing `_on_tick_advanced` function:

```gdscript
func _on_tick_advanced(_events: Array) -> void:
    var state: WorldState = _bridge.get_state()
    if state.player_id >= 0 and not state.persons.has(state.player_id):
        _bottom.add_message("[!] 玩家 P%d 已陣亡，模擬暫停" % state.player_id)
        _controls.set_process(false)
        return

    _map.refresh()
    _debug.refresh()
    _sidebar.refresh_player()
    for evt in _events:
        _bottom.add_message("[T%d] %s" % [_bridge.get_state().world.current_tick, str(evt.get("type", "?"))])

    if _bridge.get_state().encounter_active:
        _encounter.show_encounter()
        _map.visible = false
        return

    # Poll forced interaction
    var snap: Dictionary = _bridge.query_player().get("data", {}).get("snapshot", {})
    var forced: Dictionary = snap.get("forced_interaction", {})
    if not forced.get("responses", []).is_empty():
        _popups.show_forced_event(forced,
            func(cmd_args: Dictionary) -> void:
                var r = _bridge.command_player("respond_to_forced", cmd_args)
                _bottom.add_message("[強制] %s" % r.get("message", ""))
                _sidebar.refresh_player(); _debug.refresh())
```

- [ ] **Step 2: Run headless test**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```
Expected: `=== DONE ===`, no `SCRIPT ERROR`.

- [ ] **Step 3: Commit**

```
git add scripts/ui/main.gd
git commit -m "feat(ui): poll forced_interaction on tick_advanced in main.gd"
```

---

### Task 5: player_command_system — add refresh_targets action_id

**Files:**
- Modify: `scripts/simulation/player_command_system.gd`

The `execute_action` receives `action_id = "refresh_targets"` with `target_id = -1`.

- [ ] **Step 1: Add "refresh_targets" case in execute_action**

In `execute_action()`, before `"ignore":` case (line 83), add:

```gdscript
"refresh_targets":
    refresh_colocation_targets(state)
    return { "ok": true, "msg": "互動目標已更新" }
```

- [ ] **Step 2: Run headless test**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```
Expected: `=== DONE ===`, no `SCRIPT ERROR`.

- [ ] **Step 3: Commit**

```
git add scripts/simulation/player_command_system.gd
git commit -m "feat(sim): add refresh_targets action_id to player_command_system"
```

---

### Task 6: player_command_api — support "member" target kind

**Files:**
- Modify: `scripts/simulation/player_command_api.gd`

This is needed for `recruit_named` (recruit plan). The `execute_action` currently rejects `kind != "team"` and `kind != "none"`.

- [ ] **Step 1: Add "member" case in execute_action()**

In `player_command_api.gd`, `execute_action()` match block (around line 53), after `"none":` case and before `_:` default, add:

```gdscript
"member":
    var member_id: int = target.get("member_id", -1)
    if member_id == -1:
        return PlayerApiMapper.map_command_result(false, "invalid_target", "member_id required", {})
    if target_team_id == -1 or not state.teams.has(target_team_id):
        return PlayerApiMapper.map_command_result(false, "invalid_target", "team_id required for member target", {})
    # Pass full target dict to cmd_sys; cmd_sys reads member_id from request
    # execute_action signature only takes target_id (int); pass a wrapper dict approach:
    # We'll add a new overload path: execute_action_with_target(state, action_id, target_dict)
    result = _cmd_sys.execute_action_with_target(state, action_id, target)
```

- [ ] **Step 2: Add execute_action_with_target to player_command_system.gd**

In `player_command_system.gd`, after `execute_action()` function, add:

```gdscript
# execute_action variant that passes full target dict (for "member" kind actions)
func execute_action_with_target(state: WorldState, action: String, target: Dictionary) -> Dictionary:
    var pt: TeamData = _get_player_team(state)
    var pt_id: int   = _get_player_team_id(state)
    if pt == null:
        return { "ok": false, "msg": "找不到玩家 team" }
    match action:
        "recruit_named":
            var from_team_id: int = target.get("team_id", -1)
            var person_id: int    = target.get("member_id", -1)
            return _recruit_named_internal(state, pt, from_team_id, person_id)
    return { "ok": false, "msg": "不支援 member 目標的行動: %s" % action }
```

Note: `_recruit_named_internal` will be added in the recruit plan (Task 3 there). For now this compiles with forward reference since GDScript is dynamic. Add a stub:

```gdscript
func _recruit_named_internal(_state: WorldState, _pt: TeamData,
        _from_team_id: int, _person_id: int) -> Dictionary:
    return { "ok": false, "msg": "recruit_named 尚未實裝" }
```

- [ ] **Step 3: Run headless test**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```
Expected: `=== DONE ===`, no `SCRIPT ERROR`.

- [ ] **Step 4: Commit**

```
git add scripts/simulation/player_command_api.gd scripts/simulation/player_command_system.gd
git commit -m "feat(sim): support member target kind in player_command_api + stub execute_action_with_target"
```

---

### Task 7: player_query_api — add establish_faction to available_actions

**Files:**
- Modify: `scripts/simulation/player_query_api.gd`

- [ ] **Step 1: Add establish_faction in _build_available_actions**

In `_build_available_actions()`, after the Layer 4 team-actions block (after the `focus_team_id != -1` block, around line 178), add a new Layer 5 — player-team global actions:

```gdscript
# Layer 5: player-team global actions (no target required)
var pt_data: TeamData = state.teams.get(ptid) if ptid != -1 else null
if pt_data != null and pt_data.faction_id == -1:
    actions.append(PlayerApiMapper.map_available_action(
        "establish_faction", "建立勢力", true, "",
        {
            "allowed_kinds": PackedStringArray(["none"]),
            "requires_visible_target": false,
            "requires_forced_interaction": false,
            "allows_self_target": false
        },
        "execute_action",
        {
            "action_id": "establish_faction",
            "target": {"kind": "none", "team_id": -1, "member_id": -1, "tile_q": -1, "tile_r": -1}
        }
    ))
```

- [ ] **Step 2: Update _action_label**

In `_action_label()`, add:
```gdscript
"establish_faction": return "建立勢力"
"take_loot":        return "收割戰利品"
"leave_loot":       return "放棄戰利品"
"recruit_anon":     return "招募匿名"
"recruit_named":    return "招募成員"
"confirm_trade":    return "確認貿易"
"cancel_trade":     return "取消貿易"
```

- [ ] **Step 3: Run headless test**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```
Expected: `=== DONE ===`, no `SCRIPT ERROR`.

- [ ] **Step 4: Commit**

```
git add scripts/simulation/player_query_api.gd
git commit -m "feat(sim): add establish_faction to available_actions + update action labels"
```

---

## 驗證

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

預期：
- `=== DONE ===`，無 `SCRIPT ERROR`
- 框架 tasks 全完成後，點「互動」按鈕會開啟 show_interaction popup（需 runtime 測試）
- forced event popup 由 tick_advanced 自動彈出
