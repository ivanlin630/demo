# Trade Design

> 日期：2026-06-02 | 依賴：interaction-ui-framework

---

## 目標

玩家選「貿易」→ **先查預覽 DTO** → 顯示確認面板 → 確認後執行，而非自動結算。

---

## 資料流

```
玩家點「貿易」（command_args from available_actions）
  → command_player("execute_action", {action_id:"trade", target:{kind:"team", team_id:tid}})
  → result.payload.requires_preview = true
  → main._on_interact_execute 偵測到需預覽
  → _bridge.query_trade_preview(tid)
  → popups.show_trade_preview(preview_dto, confirm_fn, cancel_fn)
      → 確認 → command_player("execute_action", {action_id:"confirm_trade", target:...})
      → 取消 → command_player("execute_action", {action_id:"cancel_trade", target:...})
```

---

## 修改檔案

| 檔案 | 改動 |
|---|---|
| `scripts/simulation/interaction_system.gd` | 加 `preview_trade(state, from_id, to_id)` |
| `scripts/simulation/player_query_api.gd` | 加 `get_trade_preview(state, target_team_id)` |
| `scripts/simulation/sim_bridge.gd` | 加 `query_trade_preview(target_team_id)` |
| `scripts/simulation/player_command_system.gd` | `execute_action("trade")` 改回傳 requires_preview；加 `confirm_trade`/`cancel_trade` |
| `scripts/simulation/player_command_api.gd` | 路由 `confirm_trade`、`cancel_trade` |
| `scripts/ui/main.gd` | `_on_interact_execute` 加 trade 預覽分支 |
| `scripts/ui/popup_layer.gd` | 加 `show_trade_preview()` |

---

## A. `interaction_system.gd` — 加 `preview_trade()`

```gdscript
func preview_trade(state: WorldState, from_id: int, to_id: int) -> Dictionary:
    var from_t: TeamData = state.teams.get(from_id)
    var to_t:   TeamData = state.teams.get(to_id)
    if from_t == null or to_t == null:
        return { "feasible": false, "player_gives": {}, "player_gets": {} }

    # 複製 resolve_trade_direct 計算邏輯，但不修改 state
    # TODO（實作時）：對齊 resolve_trade_direct 的計算規則
    # 暫用估算：交換食物 / 金幣差值各 20%
    var gives: Dictionary = {}
    var gets:  Dictionary = {}
    var feasible: bool = true

    var from_food: float  = float(from_t.resources.get("food", 0))
    var to_food: float    = float(to_t.resources.get("food", 0))
    var from_coin: float  = float(from_t.resources.get("coin", 0))
    var to_coin: float    = float(to_t.resources.get("coin", 0))

    # 玩家付出（from → to）：若對方 food 更少，付出部分食物
    if to_food < from_food * 0.5 and from_food > 10:
        var transfer: float = minf(from_food * 0.2, from_food)
        gives["food"] = transfer

    # 玩家獲得（to → from）：若對方 coin 更多，取一部分
    if to_coin > from_coin * 1.5 and to_coin > 10:
        var take: float = minf(to_coin * 0.2, to_coin)
        gets["coin"] = take

    # 可行性：雙方均有資源可交換
    feasible = not (gives.is_empty() and gets.is_empty())

    return { "feasible": feasible, "player_gives": gives, "player_gets": gets }
```

---

## B. `player_query_api.gd` — 加 `get_trade_preview()`

```gdscript
func get_trade_preview(state: WorldState, target_team_id: int) -> Dictionary:
    var pt_id: int = _get_player_team_id(state)
    var preview: Dictionary = _interaction.preview_trade(state, pt_id, target_team_id)
    return {
        "ok": true, "code": "ok", "message": "",
        "data": {"preview": preview}
    }
```

---

## C. `sim_bridge.gd` — 加 `query_trade_preview()`

```gdscript
func query_trade_preview(target_team_id: int) -> Dictionary:
    return _query_api.get_trade_preview(_state, target_team_id)
```

---

## D. `player_command_system.gd` — trade 修改

**`execute_action("trade")` 改為先返回 requires_preview：**

```gdscript
"trade":
    var tgt: TeamData = state.teams.get(target_id)
    if tgt == null:
        state.player_pending_targets.erase(target_id)
        return { "ok": false, "msg": "目標不存在" }
    # 暫存待確認的交易目標
    state.player_state["pending_trade_target"] = target_id
    return { "ok": true, "msg": "等待確認",
             "requires_preview": true, "preview_target_id": target_id }
```

**加 `confirm_trade`：**

```gdscript
"confirm_trade":
    var tid2: int = int(state.player_state.get("pending_trade_target", -1))
    if tid2 < 0 or not state.teams.has(tid2):
        return { "ok": false, "msg": "無待確認貿易" }
    var result := _interaction.resolve_trade_direct(state, pt_id, tid2)
    state.player_pending_targets.erase(tid2)
    state.player_state.erase("pending_trade_target")
    return result

"cancel_trade":
    var tid3: int = int(state.player_state.get("pending_trade_target", -1))
    state.player_pending_targets.erase(tid3)
    state.player_state.erase("pending_trade_target")
    return { "ok": true, "msg": "取消貿易" }
```

---

## E. `player_command_api.gd` — 路由

```gdscript
"confirm_trade":
    return _cmd_sys.execute_action(state,
        {"action_id": "confirm_trade", "target": {"kind":"none","team_id":-1,
         "member_id":-1,"tile_q":-1,"tile_r":-1}})
"cancel_trade":
    # 同上
```

（或直接在 execute_action handler 中處理 confirm_trade / cancel_trade action_id）

---

## F. `main.gd` — `_on_interact_execute` 加 trade 分支

```gdscript
func _on_interact_execute(cmd_name: String, cmd_args: Dictionary) -> void:
    var result: Dictionary = _bridge.command_player(cmd_name, cmd_args)
    _sidebar.refresh_player(); _debug.refresh()
    var action_id: String = cmd_args.get("action_id", "")

    # 攻擊特殊路由
    if action_id == "attack" and result.get("ok"):
        _map.visible = false; _encounter.show_encounter(); return

    # 貿易預覽分支
    if action_id == "trade" and result.get("ok") and result.get("requires_preview"):
        var tid: int = result.get("preview_target_id", -1)
        var pr = _bridge.query_trade_preview(tid)
        var preview: Dictionary = pr.get("data", {}).get("preview", {})
        var base_args: Dictionary = {
            "target": {"kind":"team","team_id":tid,
                       "member_id":-1,"tile_q":-1,"tile_r":-1}
        }
        _popups.show_trade_preview(preview,
            func() -> void:   # 確認
                var ca = base_args.duplicate()
                ca["action_id"] = "confirm_trade"
                var r2 = _bridge.command_player("execute_action", ca)
                _bottom.add_message("[貿易] %s" % r2.get("message", ""))
                _sidebar.refresh_player(); _debug.refresh(),
            func() -> void:   # 取消
                var ca = base_args.duplicate()
                ca["action_id"] = "cancel_trade"
                _bridge.command_player("execute_action", ca)
                _bottom.add_message("[貿易] 已取消"))
        return

    # 招募面板
    if action_id == "recruit" and result.get("ok"):
        var payload: Dictionary = result.get("payload", {})
        if payload.get("has_willing_named", false):
            _popups.show_recruit_panel(...)   # 見 recruit spec
            return

    _bottom.add_message("[互動] %s" % result.get("message", "完成"))
```

---

## G. `popup_layer.gd` — `show_trade_preview()`

```gdscript
func show_trade_preview(preview: Dictionary, confirm_fn: Callable, cancel_fn: Callable) -> void:
    _close_current()
    var popup := _make_base_popup("貿易預覽")
    var vbox: VBoxContainer = popup.get_node("VBox/Scroll/Content")
    var feasible: bool = preview.get("feasible", false)

    for section in [["你付出：", "player_gives"], ["你獲得：", "player_gets"]]:
        var lbl := Label.new(); lbl.text = section[0]; vbox.add_child(lbl)
        var data: Dictionary = preview.get(section[1], {})
        if data.is_empty():
            var l := Label.new(); l.text = "  （無）"; vbox.add_child(l)
        for rk in data:
            var l := Label.new()
            l.text = "  %s: %.0f" % [rk, float(data[rk])]; vbox.add_child(l)

    var btn_row := HBoxContainer.new(); vbox.add_child(btn_row)
    var confirm_btn := Button.new()
    confirm_btn.text = "✓ 確認" if feasible else "無法交易（資源不足）"
    confirm_btn.disabled = not feasible
    confirm_btn.pressed.connect(func(): _close_current(); confirm_fn.call())
    btn_row.add_child(confirm_btn)
    var cancel_btn := Button.new(); cancel_btn.text = "取消"
    cancel_btn.pressed.connect(func(): _close_current(); cancel_fn.call())
    btn_row.add_child(cancel_btn)

    _current_popup = popup; add_child(popup)
```

---

## NPC 發起貿易（player_forced_event.action = "trade"）

`player_api_mapper.map_forced_interaction` 已在 alliance spec 中處理 `"trade"` case：
- responses: `[{response_id:"accept", label:"✓ 接受貿易"}, {response_id:"refuse", ...}]`

`player_command_system.respond_to_forced` — `"trade"` case：

```gdscript
"trade":
    if response == "accept":
        _interaction.resolve_trade_direct(state, fe.get("from_id", -1),
            _get_player_team_id(state))
        result = { "ok": true, "msg": "接受貿易" }
    else:
        result = { "ok": true, "msg": "拒絕貿易提案" }
```

---

## 驗證

| 情境 | 預期 |
|---|---|
| 選「貿易」 | 先查 preview，顯示「付出/獲得」面板 |
| 可行，確認 | `confirm_trade` 執行，資源轉移，顯示結果 |
| 不可行 | 確認鍵 disabled，顯示「無法交易」 |
| 取消 | `cancel_trade`，無資源變動 |
| NPC 發起貿易 | `forced_interaction` 有 accept/refuse 選項 |
