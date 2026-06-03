# UI-API 完整接合設計：Spec 1 — API 補全

## Goal

PlayerApiMapper / PlayerQueryApi / SimBridge 補全，暴露 batch1-3 所有新行動與資料，讓 UI 不需直讀 WorldState 即可取得完整狀態。

## Architecture

新增 3 個 panel query functions（PlayerQueryApi）+ 對應 SimBridge wrappers + PlayerApiMapper static map functions。擴充 `_build_available_actions` 涵蓋 batch1-3 新行動。

## 新增 Query Functions

### `query_faction_panel(state: WorldState) -> Dictionary`

```
{
  "in_faction": bool,
  "faction_id": int,               # -1 = 無
  "is_leader": bool,
  "faction_goal": String,          # f.strategic_goals[0] 或 ""
  "player_goal_override": String,  # f.player_goal_override
  "tribute_rate": float,
  "member_orders": [               # faction 旗下所有 team（含玩家隊）
    { "team_id": int, "name": String, "tile_pos": Vector2i,
      "commanded_task": String }   # "" = 無指令
  ],
  "actions": [String]              # 已過濾：leave_faction / betray_faction /
                                   # disband_faction（需 is_leader）/
                                   # set_tribute_rate（需 is_leader）/
                                   # set_faction_goal（需 is_leader）/
                                   # order_faction_member / clear_member_order
}
```

### `query_outpost_panel(state: WorldState) -> Dictionary`

```
{
  "tile_pos": Vector2i,
  "outpost_type": String,          # "" = 無前哨站
  "outpost_level": int,
  "outpost_owner": int,            # -1 = 無
  "has_control": bool,             # OutpostSystem._has_control
  "construction_in_progress": bool,
  "ticks_left": int,
  "actions": [String]              # build_outpost / upgrade_outpost /
                                   # upgrade_farming / upgrade_manufacturing /
                                   # demolish_outpost（過濾條件見下）
}
```

**行動過濾條件：**
- `build_outpost` → `outpost_type == ""` AND `has_control`
- `upgrade_outpost` / `upgrade_farming` / `upgrade_manufacturing` → `outpost_type != ""` AND `has_control`
- `demolish_outpost` → `outpost_type != ""` AND `has_control`

### `query_subteam_panel(state: WorldState) -> Dictionary`

```
{
  "subteams": [
    { "team_id": int, "tile_pos": Vector2i,
      "current_task": String, "order_task": String,
      "population": int, "player_commanded_task": String }
  ],
  "actions_per_subteam": {         # team_id(String) → [String]
    "5": ["order_subteam", "recall_subteam"],
    ...
  }
}
```

## `_build_available_actions` 擴充

新增判斷（在 PlayerQueryApi._build_available_actions）：

| Action | 條件 |
|---|---|
| `subjugate_enemy` | `state.last_encounter_result.get("can_subjugate", false) == true` |
| `gather_intel` | 永遠對 pending target 可選 |
| `confirm_gather_intel` | `state.player_state.has("pending_intel_target")` |
| `offer_surrender` | `state.encounter_active == true`（作為 target action） |

## SimBridge 新增 Wrappers

```gdscript
func query_faction_panel() -> Dictionary:
    return PlayerQueryApi.new().query_faction_panel(_state)

func query_outpost_panel() -> Dictionary:
    return PlayerQueryApi.new().query_outpost_panel(_state)

func query_subteam_panel() -> Dictionary:
    return PlayerQueryApi.new().query_subteam_panel(_state)
```

## PlayerApiMapper 新增函式

- `static func map_faction_panel(state: WorldState) -> Dictionary`
- `static func map_outpost_panel(state: WorldState) -> Dictionary`
- `static func map_subteam_panel(state: WorldState) -> Dictionary`

各 query function 呼叫對應 mapper，加 `map_query_envelope` 包裝。

## PlayerCommandApi payload 轉發修正

`PlayerCommandApi.execute_action`（line 71）目前建立新 payload 時不合併底層 command 的 `payload`。  
需修正為：

```gdscript
var payload: Dictionary = {"action_id": action_id, "result_summary": result.get("msg", ""), "refresh_required": true}
payload.merge(result.get("payload", {}))   # ← 新增：轉發底層 payload（inquiry_options 等）
```

## SimBridge `set_player_input` 新增

UI 需要在呼叫某些 action 前先寫 `player_state` 參數（如 `tribute_rate_input`, `gather_intel_choice`）。  
SimBridge 加：

```gdscript
func set_player_input(key: String, value: Variant) -> void:
    _state.player_state[key] = value
```

## 測試

headless_test.gd 驗證：
- `query_faction_panel` 回傳 `in_faction` 欄位存在
- `query_outpost_panel` 回傳 `tile_pos` 欄位存在
- `query_subteam_panel` 回傳 `subteams` array
- `_build_available_actions` 含 `gather_intel` 在 pending target 情境
