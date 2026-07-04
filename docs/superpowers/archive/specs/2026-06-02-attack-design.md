# Attack & Post-Combat Loot Design

> 日期：2026-06-02 | 依賴：interaction-ui-framework | 修正 G1

---

## 目標

1. 玩家選攻擊 → **立即**顯示 EncounterView（G1 修正）
2. 遭遇戰結束後若玩家勝 → 顯示掠奪確認面板

---

## G1：攻擊後即時路由

**根因**：`execute_action("attack")` 設 `encounter_active=true`，但 `show_encounter()` 只在 `_on_tick_advanced` 執行。

**修正**：在 framework 的 `_on_interact_execute` 中，execute_action 回傳 `ok=true` 且 `action_id == "attack"` → 立即執行。

已在 interaction-ui-framework spec 的 `_on_interact_execute` 中定義：
```gdscript
if action_id == "attack" and result.get("ok"):
    _map.visible = false
    _encounter.show_encounter()
    return
```

**框架端無需額外改動**；此條目說明必要的 `player_command_api` 內部配合。

### `player_command_api.gd` — `execute_action("attack")` 結果

確認 `execute_action` 對 `attack` action_id 返回：
```gdscript
{
    "ok": true,
    "code": "ok",
    "message": "發起攻擊",
    "payload": {
        "action_id": "attack",
        "result_summary": "encounter_started",
        "refresh_required": true
    }
}
```

### `player_command_system.gd` — 確認 attack 實作

現有邏輯已設 `encounter_active=true`，無需修改。
但需確認 `player_command_api.execute_action` 正確路由到 `_cmd_sys.execute_action(state, request)`。

---

## 戰後掠奪

### WorldState 新增欄位

```gdscript
# scripts/data/world_state.gd
var last_encounter_result: Dictionary = {}
# 格式：
# {
#   "winner_id": int,     # 勝者 team_id；-1 = 平手/逃跑
#   "loser_id":  int,
#   "loot_pool": Dictionary   # { "food": float, "coin": float, ... }
# }
```

### `encounter_system.gd` — 戰鬥結算後寫入

在 encounter 結束邏輯（`_resolve_end()` 或等效位置）加：

```gdscript
var loot: Dictionary = {}
for rk in ["food", "coin", "goods", "weapon_melee_low", "weapon_ranged_low",
           "armor_low", "medicine", "tools"]:
    var v: float = float(loser_team.resources.get(rk, 0))
    if v > 0.0:
        loot[rk] = v * 0.3   # 最多 30%，TEST VALUE
state.last_encounter_result = {
    "winner_id": winner_id,
    "loser_id":  loser_id,
    "loot_pool": loot
}
print("[Encounter] 戰後掠奪池: %s" % str(loot))
```

若平手或逃跑（無明確勝者）：
```gdscript
state.last_encounter_result = {"winner_id": -1, "loser_id": -1, "loot_pool": {}}
```

### `player_query_api.gd` — snapshot 中暴露 take_loot action

在 `get_player_snapshot` / `_build_available_actions` 中，若：
- `state.last_encounter_result.winner_id == player_team_id`
- `loot_pool` 非空

則在 `available_actions` 加入：

```gdscript
{
    "action_id": "take_loot",
    "label": "掠奪戰利品",
    "enabled": true,
    "disabled_reason": "",
    "target_requirements": {
        "allowed_kinds": ["none"],
        "requires_visible_target": false,
        "requires_forced_interaction": false,
        "allows_self_target": false
    },
    "command_name": "execute_action",
    "command_args": {
        "action_id": "take_loot",
        "target": {"kind": "none", "team_id": -1, "member_id": -1,
                   "tile_q": -1, "tile_r": -1},
        "loot_preview": loot_pool_copy   # 供 UI 顯示用（只讀）
    }
}
```

同時加入 `leave_loot`（enabled=true，label="放棄掠奪"）。

### `player_command_api.gd` — take_loot / leave_loot handler

```gdscript
# execute_action 中加
"take_loot":
    return _cmd_sys.take_loot(state)
"leave_loot":
    state.last_encounter_result = {}
    return { "ok": true, "code": "ok",
             "message": "放棄掠奪", "payload": {"refresh_required": true} }
```

### `player_command_system.gd` — `take_loot()`

```gdscript
func take_loot(state: WorldState) -> Dictionary:
    var res: Dictionary = state.last_encounter_result
    if res.is_empty() or res.get("winner_id") != _get_player_team_id(state):
        return { "ok": false, "code": "action_unavailable",
                 "message": "無有效掠奪結果", "payload": {} }
    var pt: TeamData    = _get_player_team(state)
    var loser: TeamData = state.teams.get(res.get("loser_id", -1))
    var pool: Dictionary = res.get("loot_pool", {})
    var taken: Array = []
    for rk in pool:
        var amount: float = float(pool[rk])
        pt.resources[rk] = float(pt.resources.get(rk, 0)) + amount
        if loser:
            loser.resources[rk] = maxf(float(loser.resources.get(rk, 0)) - amount, 0.0)
        taken.append("%s×%.0f" % [rk, amount])
    state.last_encounter_result = {}
    var summary: String = ", ".join(taken) if not taken.is_empty() else "無"
    print("[Loot] 掠奪: %s" % summary)
    return { "ok": true, "code": "ok",
             "message": "掠奪：%s" % summary,
             "payload": {"action_id": "take_loot", "refresh_required": true} }
```

### `popup_layer.gd` — `show_loot_panel()`

接收 `loot_preview: Dictionary` 與 `confirm_fn: Callable(take: bool)`：

```gdscript
func show_loot_panel(loot_preview: Dictionary, confirm_fn: Callable) -> void:
    _close_current()
    var popup := _make_base_popup("戰後掠奪")
    var vbox: VBoxContainer = popup.get_node("VBox/Scroll/Content")

    if loot_preview.is_empty():
        var lbl := Label.new(); lbl.text = "無可掠奪資源"; vbox.add_child(lbl)
        var close_btn := Button.new(); close_btn.text = "關閉"
        close_btn.pressed.connect(func(): _close_current(); confirm_fn.call(false))
        vbox.add_child(close_btn)
        _current_popup = popup; add_child(popup); return

    var hdr := Label.new()
    hdr.text = "可掠奪（全取或放棄）："; vbox.add_child(hdr)
    for rk in loot_preview:
        var lbl := Label.new()
        lbl.text = "  %s: %.0f" % [rk, float(loot_preview[rk])]
        vbox.add_child(lbl)

    var btn_row := HBoxContainer.new(); vbox.add_child(btn_row)
    var take_btn := Button.new(); take_btn.text = "全部掠奪"
    take_btn.pressed.connect(func(): _close_current(); confirm_fn.call(true))
    btn_row.add_child(take_btn)
    var leave_btn := Button.new(); leave_btn.text = "放棄"
    leave_btn.pressed.connect(func(): _close_current(); confirm_fn.call(false))
    btn_row.add_child(leave_btn)

    _current_popup = popup; add_child(popup)
```

---

## 驗證

| 情境 | 預期 |
|---|---|
| 玩家選攻擊，result ok=true | EncounterView 立即出現（不等 tick） |
| 遭遇戰玩家勝，有掠奪物 | `_on_encounter_ended` 彈出掠奪面板 |
| 選「全部掠奪」 | `execute_action(take_loot)` 執行，player team 資源增加 |
| 選「放棄」 | `execute_action(leave_loot)` 執行，last_encounter_result 清空 |
| 遭遇戰平手/玩家敗 | 無掠奪面板（winner_id != player_team_id） |
| headless：execute_action attack | ok=true，encounter_active=true |
