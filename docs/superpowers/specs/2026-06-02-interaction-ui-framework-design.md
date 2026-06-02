# Interaction UI Framework Design

> 日期：2026-06-02 | 依賴：player-api-boundary-design（須先實作）

---

## 目標

建立玩家互動 UI 基礎，所有行動 spec 共用此框架：
- 「互動」按鈕 → refresh → query → show popup
- 所有命令透過 `execute_action` / `respond_to_forced`，不碰內部 state
- Popup 只接收 DTO，不持有 bridge 引用

---

## 合規模式（所有 spec 遵守）

### 讀取
```gdscript
# 只許用 bridge query 方法
var r = _bridge.query_player({
    "focus_team_id": -1, "focus_member_id": -1,
    "cursor_tile_q": -1, "cursor_tile_r": -1
})
var snap: Dictionary = r.get("data", {}).get("snapshot", {})
# snap.pending_targets  ← 取代 state.player_pending_targets
# snap.forced_interaction  ← 取代 state.player_forced_event
# snap.player_summary.encounter_active
# snap.available_actions
```

### 命令
```gdscript
# execute_action：action_id + target（完整 schema）
_bridge.command_player("execute_action", {
    "action_id": String,
    "target": {
        "kind": String,     # "none" | "team" | "member" | "tile"
        "team_id": int,     # -1 if not applicable
        "member_id": int,   # -1 if not applicable
        "tile_q": int,      # -1 if not applicable
        "tile_r": int       # -1 if not applicable
    }
})
# respond_to_forced：直接使用 forced_interaction.responses[*].command_args
_bridge.command_player("respond_to_forced", {
    "interaction_id": String, "response_id": String
})
```

### Popup 設計規則
- Popup 方法只接受 DTO（Dictionary/Array），不接受 bridge 或 state 引用
- 回呼（Callable）由 main.gd 傳入，已封裝好 bridge 呼叫
- Popup 內不出現 `PlayerCommandSystem.new()`

---

## 新增 execute_action 支援的 action_id 清單

（各 spec 的細節各自說明；此處僅列需加入 `player_command_api.execute_action` 的 handler）

| action_id | target.kind | 對應內部呼叫 |
|---|---|---|
| `"refresh_targets"` | `"none"` | `_cmd_sys.refresh_colocation_targets(state)` |
| `"establish_faction"` | `"none"` | `_cmd_sys.establish_faction(state)` |
| `"take_loot"` | `"none"` | `_cmd_sys.take_loot(state)` |
| `"leave_loot"` | `"none"` | `_cmd_sys.leave_loot(state)` |
| `"recruit_anon"` | `"team"` | `_cmd_sys.recruit_anon(state, target.team_id)` |
| `"recruit_named"` | `"member"` | `_cmd_sys.recruit_named(state, target.team_id, target.member_id)` |

（既有 `attack`/`trade`/`propose_alliance`/`demand_tribute`/`extort`/`ignore`/`recruit` 已在 player_command_system，不重複列）

---

## sim_bridge.gd 擴充

除現有 API boundary 定義的方法外，加入：

```gdscript
# 貿易預覽（只讀，不修改 state）
func query_trade_preview(target_team_id: int) -> Dictionary:
    return _query_api.get_trade_preview(_state, target_team_id)
```

（`player_query_api.get_trade_preview` 詳見 trade spec）

---

## A. `right_sidebar.gd`

加 signal：
```gdscript
signal open_interaction
```

接線「互動」按鈕：
```gdscript
# 原：_make_btn("互動", row1)
# 改：
_make_btn("互動", row1).pressed.connect(_on_interact)
```

加方法：
```gdscript
func _on_interact() -> void:
    open_interaction.emit()
```

---

## B. `main.gd`

**`_ready()` 加：**
```gdscript
_sidebar.open_interaction.connect(_on_open_interaction)
```

**新增方法：**

```gdscript
func _on_open_interaction() -> void:
    # 1. 刷新同格對象
    _bridge.command_player("execute_action", {
        "action_id": "refresh_targets",
        "target": {"kind": "none", "team_id": -1, "member_id": -1, "tile_q": -1, "tile_r": -1}
    })
    # 2. Query snapshot 取 pending_targets
    var r = _bridge.query_player({
        "focus_team_id": -1, "focus_member_id": -1,
        "cursor_tile_q": -1, "cursor_tile_r": -1
    })
    var snap: Dictionary = r.get("data", {}).get("snapshot", {})
    var targets: Array = snap.get("pending_targets", [])
    if targets.is_empty():
        _bottom.add_message("[互動] 附近無可互動隊伍")
        return
    # 3. 取各目標可用行動（每個 target 各查一次）
    var targets_with_actions: Array = []
    for tgt_dto in targets:
        if not tgt_dto.get("is_valid", false):
            continue
        var tid: int = tgt_dto.get("target_id", -1)
        var ar = _bridge.query_player_actions({
            "team_id": tid, "member_id": -1,
            "tile_q": -1, "tile_r": -1, "forced_interaction_id": ""
        })
        var actions: Array = ar.get("data", {}).get("actions", [])
        targets_with_actions.append({"target": tgt_dto, "actions": actions})
    # 4. 開 popup（只傳 DTO，不傳 bridge）
    _popups.show_interaction(targets_with_actions,
        func(cmd_name: String, cmd_args: Dictionary) -> void:
            _on_interact_execute(cmd_name, cmd_args))

func _on_interact_execute(cmd_name: String, cmd_args: Dictionary) -> void:
    var result: Dictionary = _bridge.command_player(cmd_name, cmd_args)
    _sidebar.refresh_player()
    _debug.refresh()
    var action_id: String = cmd_args.get("action_id", "")
    if action_id == "attack" and result.get("ok"):
        _map.visible = false
        _encounter.show_encounter()
        return
    if action_id == "recruit" and result.get("ok"):
        # recruit 可能返回 willing_members DTO，開招募面板
        var payload: Dictionary = result.get("payload", {})
        if payload.get("has_willing_named", false):
            _popups.show_recruit_panel(
                payload.get("willing_members", []),
                cmd_args.get("target", {}).get("team_id", -1),
                func(recruit_cmd: String, recruit_args: Dictionary) -> void:
                    var r2 = _bridge.command_player(recruit_cmd, recruit_args)
                    _bottom.add_message("[招募] %s" % r2.get("message", ""))
                    _sidebar.refresh_player(); _debug.refresh())
            return
    _bottom.add_message("[互動] %s" % result.get("message", "完成"))

func _on_forced_response(cmd_args: Dictionary) -> void:
    var result: Dictionary = _bridge.command_player("respond_to_forced", cmd_args)
    _bottom.add_message("[強制事件] %s" % result.get("message", ""))
    _sidebar.refresh_player()
    _debug.refresh()
```

**修改 `_on_tick_advanced()`：**

```gdscript
func _on_tick_advanced(_events: Array) -> void:
    # 死亡偵測
    var r0 = _bridge.query_player({
        "focus_team_id": -1, "focus_member_id": -1,
        "cursor_tile_q": -1, "cursor_tile_r": -1
    })
    var snap0: Dictionary = r0.get("data", {}).get("snapshot", {})
    if not snap0.get("player_summary", {}).get("player_exists", true):
        _bottom.add_message("[!] 玩家已陣亡，模擬暫停")
        _controls.set_process(false)
        return

    _map.refresh()
    _debug.refresh()
    _sidebar.refresh_player()

    for evt in _events:
        _bottom.add_message("[T%d] %s" % [
            snap0.get("snapshot_meta", {}).get("current_tick", 0),
            str(evt.get("type", "?"))])

    # G2: 被動強制事件
    var fi: Dictionary = snap0.get("forced_interaction", {})
    if fi.get("interaction_id", "") != "":
        _popups.show_forced_event(fi,
            func(cmd_args: Dictionary) -> void: _on_forced_response(cmd_args))

    # 遭遇戰
    if snap0.get("player_summary", {}).get("encounter_active", false):
        _encounter.show_encounter()
        _map.visible = false
```

**修改 `_on_encounter_ended()`：**

```gdscript
func _on_encounter_ended() -> void:
    _map.visible = true
    _map.refresh()
    # 查詢是否有可掠奪戰利品
    var r = _bridge.query_player({
        "focus_team_id": -1, "focus_member_id": -1,
        "cursor_tile_q": -1, "cursor_tile_r": -1
    })
    var snap: Dictionary = r.get("data", {}).get("snapshot", {})
    var loot_action: Dictionary = {}
    for act in snap.get("available_actions", []):
        if act.get("action_id", "") == "take_loot":
            loot_action = act; break
    if not loot_action.is_empty() and loot_action.get("enabled", false):
        _popups.show_loot_panel(
            loot_action.get("command_args", {}).get("loot_preview", {}),
            func(take: bool) -> void:
                var aid: String = "take_loot" if take else "leave_loot"
                var r2 = _bridge.command_player("execute_action", {
                    "action_id": aid,
                    "target": {"kind": "none", "team_id": -1, "member_id": -1,
                               "tile_q": -1, "tile_r": -1}
                })
                _bottom.add_message("[掠奪] %s" % r2.get("message", ""))
                _sidebar.refresh_player(); _debug.refresh())
    else:
        _sidebar.refresh_player()
        _debug.refresh()
```

---

## C. `popup_layer.gd`

**`show_interaction()` — 接受 DTO，不碰 bridge：**

```gdscript
func show_interaction(targets_with_actions: Array, execute_fn: Callable) -> void:
    _close_current()
    var popup := _make_base_popup("互動")
    var vbox: VBoxContainer = popup.get_node("VBox/Scroll/Content")

    for entry in targets_with_actions:
        var tgt: Dictionary  = entry.get("target", {})
        var actions: Array   = entry.get("actions", [])
        var hdr := Label.new()
        hdr.text = "%s" % tgt.get("display_name", "Team?")
        vbox.add_child(hdr)

        var row := HBoxContainer.new(); vbox.add_child(row)
        for act in actions:
            if not act.get("enabled", true) and act.get("action_id") == "ignore":
                continue   # 不顯示隱性 disabled
            var btn := Button.new()
            btn.text = act.get("label", act.get("action_id", "?"))
            btn.disabled = not act.get("enabled", true)
            if btn.disabled:
                btn.tooltip_text = act.get("disabled_reason", "")
            var cmd_name: String = act.get("command_name", "execute_action")
            var cmd_args: Dictionary = act.get("command_args", {})
            btn.pressed.connect(func():
                _close_current()
                execute_fn.call(cmd_name, cmd_args))
            row.add_child(btn)
        vbox.add_child(HSeparator.new())

    _current_popup = popup; add_child(popup)
```

**`show_forced_event()` — 使用 forced_interaction DTO：**

```gdscript
func show_forced_event(fi: Dictionary, respond_fn: Callable) -> void:
    _close_current()
    var title_map: Dictionary = {
        "diplomacy": "外交提案", "extort": "勒索", "trade": "貿易提案"
    }
    var itype: String = fi.get("interaction_type", "")
    var title: String = title_map.get(itype, "強制互動")
    var popup := _make_base_popup(title)
    var vbox: VBoxContainer = popup.get_node("VBox/Scroll/Content")

    var src: Dictionary = fi.get("source", {})
    var from_str: String = src.get("team_name",
        "Team%d" % src.get("team_id", -1))
    var desc := Label.new()
    desc.text = "%s 向你發出%s" % [from_str, title]
    desc.autowrap_mode = TextServer.AUTOWRAP_WORD; vbox.add_child(desc)

    var msg: String = fi.get("message", "")
    if msg != "":
        var ml := Label.new(); ml.text = msg
        ml.autowrap_mode = TextServer.AUTOWRAP_WORD; vbox.add_child(ml)

    var btn_row := HBoxContainer.new(); vbox.add_child(btn_row)
    for resp in fi.get("responses", []):
        var btn := Button.new()
        btn.text = resp.get("label", resp.get("response_id", "?"))
        var ca: Dictionary = resp.get("command_args", {})
        btn.pressed.connect(func():
            _close_current()
            respond_fn.call(ca))
        btn_row.add_child(btn)

    _current_popup = popup; add_child(popup)
```

---

## D. `player_api_mapper.gd` — 新增映射責任

- `map_pending_targets` 已定義；確認每筆含 `target_type`, `target_id`, `display_name`, `is_valid`
- `map_forced_interaction`：`responses` 陣列須含 `response_id`, `label`, `command_args: {interaction_id, response_id}` → 直接可傳入 `respond_to_forced`
- `map_available_action`：每筆含 `action_id`, `label`, `enabled`, `disabled_reason`, `command_name="execute_action"`, `command_args`（完整 target schema）
- 新增：`map_encounter_loot(last_result)` → 生成 `take_loot` available_action，`command_args.loot_preview` 含可掠奪資源

---

## E. `player_query_api.gd` — 確認 snapshot 包含

- `snapshot_meta.current_tick`（UI tick 顯示用）
- `player_summary.player_exists`（死亡偵測）
- `player_summary.encounter_active`
- `available_actions` 在戰後含 `take_loot`（若 `last_encounter_result` 非空且玩家為 winner）

---

## 驗證

| 情境 | 預期 |
|---|---|
| 按「互動」，同格無 NPC | 底部：「附近無可互動隊伍」 |
| 按「互動」，同格有 NPC | popup 列出目標 + 行動按鈕（來自 query_player_actions DTO） |
| 行動按鈕使用 `command_name + command_args` | 不需 UI hardcode action 邏輯 |
| tick 後有 forced_interaction | 彈出被動對話框（from snapshot DTO） |
| forced_interaction.responses 含 command_args | 直接傳 respond_to_forced，無需 UI 自組參數 |
| 無 `get_state()` 呼叫在 main.gd | ✓ |
