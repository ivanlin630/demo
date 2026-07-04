# UI-API 完整接合設計：Spec 2 — UI 直讀清除

## Goal

UI 層（4 個檔案）零 WorldState 直讀。所有狀態透過 SimBridge / PlayerQueryApi / PlayerApiMapper 取得。`sim_bridge.get_state()` 只在 SimBridge 內部使用。

## Architecture

PlayerApiMapper 補 3 個新 static 函式（body_slots、global_messages、visible_teams_render）。4 個 UI 檔所有 `_state.*` / `state.*` 直讀改為 SimBridge 呼叫或 snapshot key 取用。

## 新增 PlayerApiMapper 函式

### `map_body_slots(state: WorldState) -> Dictionary`

```gdscript
# 回傳 player 的 body 裝備格
{
  "head": String,        # grade 或 ""
  "torso": String,
  "right_arm": String,
  "left_arm": String,
  "right_leg": String,
  "left_leg": String
}
```

### `map_global_messages(state: WorldState, n: int = 10) -> Array[String]`

```gdscript
# 回傳最近 n 條 global_messages 的 description 字串
["Team3 建成 civilian_outpost at (4,4)", ...]
```

### `map_visible_teams_render(state: WorldState, observer_team_id: int) -> Array`

```gdscript
# 用於地圖渲染，整合既有 vision 過濾邏輯
[
  { "team_id": int, "tile_pos": Vector2i, "faction_id": int,
    "population": int, "is_player": bool, "is_hostile": bool }
]
```

## 新增 SimBridge Wrappers

```gdscript
func query_body_slots() -> Dictionary:
    return PlayerApiMapper.map_body_slots(_state)

func query_global_messages(n: int = 10) -> Array[String]:
    return PlayerApiMapper.map_global_messages(_state, n)

func query_visible_teams_render() -> Array:
    var ptid: int = get_player_team_id()
    return PlayerApiMapper.map_visible_teams_render(_state, ptid)
```

## UI 直讀改動清單

### `text_ui_main.gd`

| 原始直讀 | 改後 |
|---|---|
| `_state.persons[_state.player_id].team_id` | `_bridge.get_player_team_id()` |
| `_state.teams[_player_tid]` | snapshot `player_summary` 取 |
| `_state.world.current_tick` | snapshot `player_summary.current_tick` |
| `_state.global_messages` | `_bridge.query_global_messages()` |
| `_state.persons.get(_state.player_id)` (body_slots) | `_bridge.query_body_slots()` |
| `_state.teams` 迭代（地圖字串渲染） | `_bridge.query_visible_teams_render()` |

### `right_sidebar.gd`

| 原始直讀 | 改後 |
|---|---|
| `_bridge.get_state()` → `state.teams.get(ptid)` | `_bridge.query_player_team(ptid)` |
| `state.persons.get(state.player_id)` | snapshot `player_summary` |
| `_find_team_at(pos, state)` 內部直讀 | `query_visible_teams_render()` 過濾 tile_pos |

### `bottom_bar.gd`

| 原始直讀 | 改後 |
|---|---|
| `_bridge.get_state()` → `state.teams` | `_bridge.query_player_team()` + `query_visible_teams_render()` |

### `world_map_view.gd`

| 原始直讀 | 改後 |
|---|---|
| `state.teams` 全迭代 + `_is_tile_discovered` + `_is_team_visible` | `_bridge.query_visible_teams_render()`（fog of war 移入 mapper） |
| `state.persons.get(player_tid)` | snapshot 取 player tile_pos |

**重要：** `map_visible_teams_render` 需整合 `_is_tile_discovered` 和 `_is_team_visible` 邏輯（vision_system 相關 check），移入 mapper，world_map_view 只用回傳結果渲染。

## 成功標準

完成後 `grep -n "_state\." scripts/ui/*.gd` 零輸出（`sim_bridge.gd` 除外）。

## 測試

- headless_test 無崩潰
- 跑 1000 tick 地圖仍正常渲染（無回歸）
