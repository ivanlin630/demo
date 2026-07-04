# Text UI → Player API 接口補全 Spec

> **狀態：設計完成，待 implementation plan**
> 前置 spec：`2026-06-01-player-api-boundary-design.md`
> 目標：`text_ui_main.gd` 所有 display function 改用 snapshot，不再直接讀 `WorldState`／`TeamData`／`PersonData`。

---

## 背景

`feat/player-api-boundary` 已建立 mapper + query/command API + SimBridge，但：

1. `map_controlled_team.resources` 只含 food/coin/material，缺 weapon/armor/medicine/tools。
2. `map_controlled_team` 缺 fatigue、population、minor_population、faction 顯示。
3. `map_controlled_team.members` 每項缺 hp_status、equipment。
4. `map_player_summary` 缺 hp_status、skills。
5. `map_visible_teams` 每項缺 faction_display、population。
6. `text_ui_main.gd` `_build_state_str` / `_build_member_str` 仍直讀 `_state`。
7. `_refresh_snapshot` 未傳 cursor（`_selected`），導致 `location_context` 永遠回 hidden。

---

## 非目標

- 不改 `TextMapRenderer`（map 渲染工具，非 player data）
- 不改 `_build_debug_str`（debug 欄位，直讀 `_state` 可接受）
- 不改 `_process` 的移動完成偵測（real-time tick，直讀 `_state.teams` 可接受）
- 不改 tile productivity / tile food 的 display（tile 原始資料非 player DTO，保留直讀 `_state.world.tiles`）
- 不新增任何玩法行為

---

## Mapper DTO 擴充

### `map_controlled_team` 補充欄位

`resources` dict 補齊所有可顯示的隊伍資源鍵：

```
food, coin, material,
weapon_melee_low, weapon_melee_high,
weapon_ranged_low, weapon_ranged_high,
armor_low, armor_high,
medicine, tools
```

新增 top-level 欄位：

| 欄位 | 型別 | 來源 |
|------|------|------|
| `fatigue_pct` | int (0–100) | `int(t.fatigue * 100)` |
| `population` | int | `t.population` |
| `minor_population` | int | `t.minor_population` |
| `faction_id` | int | `t.faction_id` |
| `faction_display` | String | `"勢力N"` 或 `"獨立"` |

`members` 陣列每項新增：

| 欄位 | 型別 | 說明 |
|------|------|------|
| `hp_status` | String | `"正常"` / `"輕傷"` / `"重傷"` |
| `equipment` | Dictionary | `{"hand_1": grade_or_empty, "torso": grade_or_empty}` |

### `map_player_summary` 補充欄位

| 欄位 | 型別 | 說明 |
|------|------|------|
| `hp_status` | String | `"正常"` / `"輕傷"` / `"重傷"` |
| `skills` | Dictionary | `{skill_name: float}`，只含值 > 0.01 的技能 |

### `map_visible_teams` 每項補充欄位

| 欄位 | 型別 | 說明 |
|------|------|------|
| `faction_display` | String | `"勢力N"` 或 `"獨立"` |
| `population` | int | `dt.population` |

### 新增 private helper

在 `player_api_mapper.gd` 底部加 private static helper，供 `map_controlled_team.members` 與 `map_player_summary` 共用：

```gdscript
static func _hp_status(p: PersonData) -> String:
    if p == null: return ""
    var has_severe := false
    var has_wound  := false
    for part in p.body_parts.values():
        var s: String = part.get("status", "healthy")
        if s == "severed" or s == "critical": has_severe = true
        elif s == "wounded": has_wound = true
    if has_severe: return "重傷"
    if has_wound:  return "輕傷"
    return "正常"
```

---

## text_ui_main.gd 修改

### `_refresh_snapshot` 補傳 cursor

spec 要求 `cursor_tile_q` / `cursor_tile_r`，現有 `player_query_api.gd` 實際接受的 key 為 `cursor_q` / `cursor_r`（需以現有 impl 為準，查確認後填正確 key）。

當 `_selected != Vector2i(-1, -1)` 時，傳入選中 tile 座標，讓 `location_context` 有效填充。

### `_build_state_str` 改用 snapshot

讀取來源：
- `_cached_snapshot.player_summary`：player_name、hp_status、skills
- `_cached_snapshot.controlled_team`：position、faction_display、task_summary、fatigue_pct、population、minor_population、resources（全欄位）
- `_cached_snapshot.location_context`：terrain、settlement、occupants（選中 tile 資訊）
- `_cached_snapshot.visible_teams`：查詢 occupant 的 faction_display + population

選中 tile 的 productivity / tile.resources.food 仍從 `_state.world.tiles` 直讀（tile 原始資料非 player DTO）。

### `_visible_team_at` 改用 snapshot

從 `_cached_snapshot.visible_teams` 中以 `position.q` / `position.r` 比對 tile_key，回傳 `id`。舊的直讀 `_state.team_discovered` 改為從 `visible_teams` 查詢。

**注意**：tile_key 計算規則 `q * 1000 + r`，比對時需拆分：`q = tile_key / 1000`，`r = tile_key % 1000`。

### `_build_member_str` 改用 snapshot

從 `_cached_snapshot.controlled_team.members` 取成員清單（含 hp_status、equipment.hand_1）。
匿名人口 = `controlled_team.population - members.size()`。
武裝率計算從 `controlled_team.resources` 取 weapon 欄位加總。

### `_build_inv_str` equipped 區段改用 snapshot

`equipped_items` 從 `_cached_snapshot.inventory_state.equipped_items` 讀取（mapper 已有）。
body_slots（head / right_arm / left_arm / right_leg / left_leg）mapper 目前未 expose，保留直讀 `_state.persons` 這段顯示，不視為違反邊界。

### 保留 `_get_hp_status` helper

不刪除，保留作為 private helper，供 TextMapRenderer 或未來其他地方使用。

---

## 邊界確認

| 讀取位置 | 直讀 `_state`？ | 說明 |
|----------|----------------|------|
| `_build_state_str` | 只剩 tile productivity / tile.resources.food | tile 原始資料，不在 player boundary |
| `_build_member_str` | 否 | 全改 snapshot |
| `_build_inv_str` equipped | 部分（body_slots） | mapper 未 expose，保留直讀 |
| `_build_debug_str` | 是 | debug，豁免 |
| `TextMapRenderer.render` | 是 | map 渲染工具，豁免 |
| `_process` | 是 | real-time tick，豁免 |
| `_visible_team_at` | 否 | 改用 visible_teams |

---

## 驗收標準

1. `headless_test.gd` 跑到 `=== DONE ===`，無 `SCRIPT ERROR`。
2. `map_controlled_team` 含全部 11 個資源欄位 + 5 個新 top-level 欄位。
3. `map_player_summary` 含 `hp_status` + `skills`。
4. `map_visible_teams` 每項含 `faction_display` + `population`。
5. `_build_state_str` 不再直讀 `_state.teams` / `_state.persons`（允許直讀 `_state.world.tiles` 取 tile 原始資料）。
6. `_build_member_str` 不再直讀 `_state.teams` / `_state.persons`。
