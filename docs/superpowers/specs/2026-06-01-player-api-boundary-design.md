# Player API Boundary 設計 Spec

> **狀態：設計完成，待 implementation plan**
> 本 spec 定義玩家操作 API 邊界，目標是讓 text UI、playtest、未來圖形 UI 都透過穩定 DTO / command result 與模擬層互動，而不是直接依賴 `WorldState` 或內部資料結構。

## 目標

- 收斂所有玩家相關入口，覆蓋現有 text UI、playtest、player helper。
- 收斂現有 text UI inventory / equip / take / deposit 流程，不留玩家入口旁路。
- 玩家入口不再直接碰 `WorldState`、`TeamData`、`PersonData`。
- API 層同時支援現有 headless/text UI，並保留未來升級成 snapshot store / command bus 的路徑。
- 這次除了邊界整理，也要補齊目前 UI 直接讀 state 所需查詢 API 與必要指令 API。

---

## 非目標

- 不重寫整個模擬系統。
- 不導入完整事件匯流排或獨立 snapshot store。
- 不擴充新的玩家玩法，只整理既有能力與既有流程需要的查詢/指令面。

---

## 架構原則

- **玩家入口只看 API**：UI / playtest 只依賴 query DTO 與 command result。
- **模擬狀態只留在 API 內部**：`WorldState` 與各種 data class 不外漏。
- **Query / Command 分離**：讀取與操作分檔，避免單一 facade 過胖。
- **可漸進升級**：未來若引入 snapshot store / command bus（即 Query 改讀快照、Command 改走 dispatcher），盡量不改 UI 介面。
- **禁止直接 script outcome**：API 只暴露由既有 NPC / team 狀態推導出的可見結果，不新增繞過模擬規則的捷徑。

---

## 目標結構

```text
scripts/simulation/
  player_query_api.gd
  player_command_api.gd
  player_api_mapper.gd
  player_command_system.gd   # internal bridge / legacy player state hooks
```

### `player_query_api.gd`

責任：
- 提供玩家相關 read-only 查詢。
- 從 `WorldState` 擷取資料並組裝成穩定 DTO。
- 對外隱藏內部 data class 與字典結構。

生命週期：
- 預設為 stateless helper；每次呼叫顯式接收 `WorldState` 與 request。
- 不持有 UI 狀態，也不快取 mutable world data。

### `player_command_api.gd`

責任：
- 提供玩家操作入口。
- 代理既有玩家操作流程（move / cancel / execute_action / forced response 等）。
- 回傳標準 result，避免 UI 再回頭讀內部 state 補判斷。

生命週期：
- 預設為 stateless helper；每次呼叫顯式接收 `WorldState` 與 command 參數。
- 不持有 long-lived mutable state；玩家相關持久狀態仍留在 `WorldState`。

### `player_command_system.gd`

責任：
- 作為 internal bridge，承接既有玩家狀態欄位與 legacy 邏輯。
- 提供 `player_command_api.gd` 與 `sim_runner.gd` 需要的內部 hook。
- 統一處理 player pending targets / forced interaction 等內部狀態清理，不讓外部 UI 直接碰欄位。

最小 internal interface：
- `move_to(state: WorldState, tile_q: int, tile_r: int) -> Dictionary`
- `cancel_move(state: WorldState) -> Dictionary`
- `execute_action(state: WorldState, request: Dictionary) -> Dictionary`
- `equip_item(state: WorldState, slot_id: String, item_grade: String) -> Dictionary`
- `unequip_item(state: WorldState, slot_id: String) -> Dictionary`
- `deposit_item(state: WorldState, item_grade: String, qty: int) -> Dictionary`
- `take_team_item(state: WorldState, item_grade: String, qty: int) -> Dictionary`
- `on_player_team_moved(state: WorldState) -> void`
- `on_forced_interaction_timeout(state: WorldState) -> void`
- `clear_pending_targets(state: WorldState) -> void`
- `get_active_forced_interaction(state: WorldState) -> Variant`
- `resolve_forced_response(state: WorldState, interaction_id: String, response_id: String) -> Dictionary`

ownership 規則：
- `player_command_system.gd` 擁有 internal player-state hook、forced interaction lifecycle、與既有 move/action/inventory 執行邏輯。
- `player_command_api.gd` 是唯一 public command surface。
- `player_command_api.gd` 只負責 public contract 驗證、dispatch 到 internal bridge、以及回傳標準 result。
- `sim_runner.gd` 只能呼叫上述 internal hook，不直接讀寫玩家 UI 狀態欄位。
- UI / playtest / `sim_bridge.gd` 都不可直接呼叫 `player_command_system.gd`。

### `player_api_mapper.gd`

責任：
- 集中做 DTO 映射與欄位裁切。
- 統一欄位命名，避免 UI 分散依賴不同內部命名。
- 成為未來切換到 snapshot store 時的相容層。

最小 interface：
- `map_player_summary(...) -> Dictionary`
- `map_controlled_team(...) -> Dictionary`
- `map_team_details(...) -> Dictionary`
- `map_visible_team(...) -> Dictionary`
- `map_member_details(...) -> Dictionary`
- `map_pending_targets(...) -> Array`
- `map_forced_interaction(...) -> Dictionary`
- `map_location_context(...) -> Dictionary`
- `map_available_action(...) -> Dictionary`
- `map_inventory_state(...) -> Dictionary`
- `map_snapshot_meta(...) -> Dictionary`
- `map_player_snapshot(...) -> Dictionary`
- `map_query_envelope(ok, code, message, data) -> Dictionary`
- `map_command_result(ok, code, message, payload) -> Dictionary`

ownership 規則：
- mapper 擁有 public query DTO、command payload/result shape、envelope shape 的輸出責任。
- mapper 不擁有業務判斷，不決定 action 是否可用，也不執行 command。

public DTO 對應：
- `map_controlled_team` 對應 snapshot 內 `controlled_team`
- `map_team_details` 對應 detail query 內 `data.team`
- `map_member_details` 對應 detail query 內 `data.member`
- `map_location_context` 對應 snapshot/detail query 內 location DTO

action generation owner：
- `player_query_api.gd` 擁有 available action 的組裝、優先序、dedupe、context 合成規則。
- mapper 只負責把已決定的 action 轉成 public DTO shape。

---

## API 邊界

### Query API 對外輸出

Query API 採統一 envelope：

```gdscript
{
    "ok": bool,
    "code": String,
    "message": String,
    "data": Dictionary
}
```

規則：
- 成功時 `ok = true`，`data` 為查詢結果。
- 失敗時 `ok = false`，`code` 為穩定錯誤碼，`data` 為空字典。
- 對玩家 UI 的主要刷新查詢使用單一 snapshot DTO，放在 `data.snapshot`。
- 次級 detail 查詢也使用同一 envelope，避免 UI 對 query 與 command 採兩套錯誤判斷。

主要 snapshot DTO 至少包含以下區塊：

- `player_summary`
- `controlled_team`
- `visible_teams`
- `focused_member`
- `pending_targets`
- `forced_interaction`
- `location_context`
- `available_actions`
- `inventory_state`
- `snapshot_meta`

DTO 規則：
- 可序列化、平面化優先。
- 只放 UI 真正需要的欄位。
- 不回傳 `TeamData`、`PersonData`、原始節點引用、內部索引結構。
- 若欄位暫時不存在，明確用 `null`、空陣列、空字典或狀態欄位表達，不靠 UI 猜。

Query API 至少提供以下方法：

- `get_player_snapshot(state: WorldState, request: Dictionary)`
- `get_team_details(state: WorldState, team_id: int)`
- `get_member_details(state: WorldState, team_id: int, member_id: int)`
- `get_location_context(state: WorldState, tile_q: int, tile_r: int)`
- `get_available_actions(state: WorldState, request: Dictionary)`

`get_player_snapshot(state: WorldState, request)` 的 request 至少包含：

```gdscript
{
    "focus_team_id": int,
    "focus_member_id": int,
    "cursor_tile_q": int,
    "cursor_tile_r": int
}
```

規則：
- `focus_team_id` / `focus_member_id` 使用 `-1` 表示無 focus。
- `cursor_tile_q` / `cursor_tile_r` 使用 `-1` 表示無 cursor tile。
- 若缺欄位，API 先補成上述預設值再處理。
- 若型別錯誤，回 `invalid_request`。
- 若只有 `focus_member_id` 但 `focus_team_id` 為空，回 `invalid_focus`。
- 若只有 `cursor_tile_q` 或只有 `cursor_tile_r` 非 `-1`，回 `invalid_request`。
- snapshot 內的 `focused_member`、`location_context`、`available_actions` 都由這些 UI-local 輸入決定。
- UI 自己保管 focus / cursor 狀態，不寫入 world state。

invalid local state 規則：
- 型別錯誤或結構錯誤仍回 `invalid_request` / `invalid_focus`。
- 但 stale local ref 不使整個 snapshot fail。
- `focus_team_id` / `focus_member_id` 指向不存在或不可見目標時，`focused_member` 回 sentinel 空物件，並在 `snapshot_meta.focus_valid = false`。
- `cursor_tile_q` / `cursor_tile_r` 指向不存在 tile 時，`location_context` 回 hidden/sentinel context，並在 `snapshot_meta.cursor_valid = false`。
- 其他主區塊仍正常回傳，讓 UI 可自我修正本地 focus/cursor。

各 query 合約：

| Query | 輸入 | `data` 最低欄位 | 常見錯誤碼 |
|---|---|---|---|
| `get_player_snapshot` | `focus_team_id`, `focus_member_id`, `cursor_tile_q`, `cursor_tile_r` | `snapshot.player_summary`, `snapshot.controlled_team`, `snapshot.visible_teams`, `snapshot.focused_member`, `snapshot.pending_targets`, `snapshot.forced_interaction`, `snapshot.location_context`, `snapshot.available_actions`, `snapshot.inventory_state`, `snapshot.snapshot_meta` | `invalid_request`, `invalid_focus`, `no_player`, `no_controlled_team` |
| `get_team_details` | `team_id` | `team.id`, `team.name`, `team.faction`, `team.position`, `team.members`, `team.resources`, `team.interaction_options` | `no_player`, `no_controlled_team`, `invalid_team`, `not_visible` |
| `get_member_details` | `team_id`, `member_id` | `member.id`, `member.name`, `member.team_id`, `member.role`, `member.status`, `member.available_actions` | `no_player`, `no_controlled_team`, `invalid_team`, `invalid_member`, `not_visible` |
| `get_location_context` | `tile_q`, `tile_r` | `location.tile`, `location.terrain`, `location.settlement`, `location.occupants`, `location.hints` | `no_player`, `no_controlled_team`, `invalid_tile` |
| `get_available_actions` | `team_id`, `member_id`, `tile_q`, `tile_r`, `forced_interaction_id` | `actions` | `no_player`, `no_controlled_team`, `invalid_request`, `invalid_focus`, `forced_response_missing` |

### Command API 對外輸出

Command API 提供既有玩家行為入口，至少覆蓋：

- `move_to(state: WorldState, tile_q: int, tile_r: int)`
- `cancel_move(state: WorldState)`
- `execute_action(state: WorldState, request: Dictionary)`
- `respond_to_forced(state: WorldState, interaction_id: String, response_id: String)`
- `equip_item(state: WorldState, slot_id: String, item_grade: String)`
- `unequip_item(state: WorldState, slot_id: String)`
- `deposit_item(state: WorldState, item_grade: String, qty: int)`
- `take_team_item(state: WorldState, item_grade: String, qty: int)`

若 UI 需要改變本地 focus，只由 UI 自己保管目前 focus 的 team/member id，再把 id 傳給 query API。focus 不作為 world command。

所有 command 皆回傳統一結果：

```gdscript
{
    "ok": bool,
    "code": String,
    "message": String,
    "payload": Dictionary
}
```

規則：
- `ok = true` 表示操作已接受並完成既有流程。
- `code` 給 UI / playtest 穩定判斷，不依賴文字訊息。
- `message` 給使用者顯示或 debug print。
- `payload` 只放下一步 UI 真正需要的資訊，例如刷新 hint、更新後目標、互動狀態摘要。

各 command 合約：

| Command | 輸入 | 成功 payload 最低欄位 | 常見錯誤碼 | UI 是否重刷 |
|---|---|---|---|---|
| `move_to` | `tile_q`, `tile_r` | `move_target`, `refresh_required=true` | `no_controlled_team`, `invalid_tile`, `move_unavailable` | 是 |
| `cancel_move` | 無 | `move_cancelled=true`, `refresh_required=true` | `no_controlled_team`, `move_unavailable` | 是 |
| `execute_action` | `action_id`, `target.kind`, `target.*` | `action_id`, `result_summary`, `refresh_required` | `invalid_request`, `invalid_target`, `action_unavailable` | 通常是 |
| `respond_to_forced` | `interaction_id`, `response_id` | `forced_interaction_resolved`, `refresh_required=true` | `forced_response_missing`, `forced_response_invalid` | 是 |
| `equip_item` | `slot_id`, `item_grade` | `equipped_slot`, `item_grade`, `refresh_required=true` | `invalid_request`, `item_unavailable`, `equip_unavailable` | 是 |
| `unequip_item` | `slot_id` | `unequipped_slot`, `refresh_required=true` | `invalid_request`, `equip_unavailable` | 是 |
| `deposit_item` | `item_grade`, `qty` | `item_grade`, `qty`, `refresh_required=true` | `invalid_request`, `item_unavailable`, `deposit_unavailable` | 是 |
| `take_team_item` | `item_grade`, `qty` | `item_grade`, `qty`, `refresh_required=true` | `invalid_request`, `item_unavailable`, `take_unavailable` | 是 |

command target/error 規則：
- `move_to` 對不存在 tile 回 `invalid_tile`；tile 存在但不可走/不可下令回 `move_unavailable`。
- `execute_action` 對不存在或過期 target 回 `invalid_target`。
- `execute_action` 對 target 存在但目前不可見，亦回 `invalid_target`，不洩漏更多視野資訊。
- `execute_action` 對 target 可見但當前規則不允許執行，回 `action_unavailable`。
- `respond_to_forced` 對過期 interaction 回 `forced_response_missing`。

`execute_action(request)` 的 request：

```gdscript
{
    "action_id": String,
    "target": {
        "kind": String, # "none" | "team" | "member" | "tile"
        "team_id": int,
        "member_id": int,
        "tile_q": int,
        "tile_r": int
    }
}
```

規則：
- 無目標 action 使用 `target.kind = "none"`。
- team 目標使用 `kind = "team"` + `team_id`。
- member 目標使用 `kind = "member"` + `team_id` + `member_id`。
- tile 目標使用 `kind = "tile"` + `tile_q` + `tile_r`。
- 若 `target` 內容與 `action_id` 所需 target 不匹配，回 `invalid_target`。
- 不支援複合 target；若未來需要複合 target，視為新 command contract，不在本次 spec。

---

## 資料流

### 讀取流程

1. UI 啟動或每 tick 刷新。
2. UI 透過 `sim_bridge.query_player(request)` 取得 envelope。
3. `sim_bridge` 在內部持有/注入 `WorldState`，再呼叫 `player_query_api.get_player_snapshot(state, request)`。
4. 若 `ok = true`，UI 讀 `data.snapshot` 重繪畫面。
5. 若 `ok = false`，UI 依 `code/message` 顯示一致錯誤訊息，不直接讀 `WorldState` 補救。

### 操作流程

1. UI 透過 `sim_bridge.command_player(name, args)` 發出玩家操作。
2. `sim_bridge` 在內部持有/注入 `WorldState`，再呼叫 `player_command_api`。
3. API 在內部執行既有模擬/玩家流程。
4. API 回傳標準 result。
5. UI 依 result 決定提示訊息與是否重刷 query。

### 未來升級路徑

若未來導入「snapshot store + command bus」架構：
- Query API 背後可改接 snapshot store。
- Command API 背後可改接 dispatcher / command bus。
- UI 仍維持相同 DTO / result 合約。

這是本次設計最重要的前向相容點。

---

## DTO 設計原則

### `player_summary`

用途：
- 提供全域玩家狀態，讓任何 UI 都有共同頂層資訊。

至少包含：
- 玩家是否存在
- 玩家 person id / name
- 受控 team id / name
- 當前位置摘要
- 關鍵狀態旗標（是否有 pending target、是否有 forced interaction）

### `controlled_team`

用途：
- 統一玩家自隊畫面需要的主要資訊。

至少包含：
- team id / name / faction
- 座標與地點摘要
- 成員摘要列表
- 資源摘要
- 任務 / 移動狀態摘要

### `visible_teams`

用途：
- 提供當前可見隊伍列表，給 text UI 與未來圖形 UI 共用。

至少包含：
- team id / name
- relation / stance 摘要
- 位置摘要
- 是否可互動、可 inspect、可作為 target

可見性規則：
- 只列出目前可見隊伍。
- 已發現但目前不可見的隊伍不放進 `visible_teams`。
- API 不可為了 UI 便利洩漏隱藏隊伍資訊。

### `focused_member`

用途：
- 提供 UI 當前聚焦成員資訊，而不是直接回 person 物件。

查詢方式：
- UI 持有 `focus_team_id` + `focus_member_id`
- `get_player_snapshot(request)` 會依兩者內嵌 `focused_member`
- 若需要獨立詳查，使用 `get_member_details(team_id, member_id)`

至少包含：
- member id / name
- 所屬 team id / name
- role 摘要
- 關鍵狀態摘要（health / stress / loyalty 等現有 UI 已需要欄位）
- 當前可執行 member-level actions

### `pending_targets`

用途：
- 取代 UI 直接讀 `_state.player_pending_targets` 的行為。

至少包含：
- target 列表
- 每個 target 的 `target_type`
- `target_id`
- 顯示名稱
- 是否仍有效

### `forced_interaction`

用途：
- 取代 UI 直接讀 `_state.player_forced_event`。
- 統一輸出必回應互動的類型、來源、可選動作與必要顯示文字。

至少包含：
- `interaction_id`
- `interaction_type`
- 來源 team/person 摘要
- prompt/message
- 可選 responses 列表（每筆含 `response_id`, `label`, `command_args`）

### `location_context`

用途：
- 提供目前 tile / settlement / occupant 等位置上下文，讓不同 UI 不必自行拆 state。

至少包含：
- tile 座標
- `visibility_state` (`"hidden"` 或 `"visible"`)
- terrain 摘要
- settlement 摘要（若無則為 `null`）
- occupant teams 摘要列表
- 是否為玩家目前所在位置
- 與該位置相關的 target / interaction hints

可見性規則：
- 若 tile 不可見，`visibility_state = "hidden"`。
- valid-but-hidden tile 仍回真實 `tile.q/r` 與 `visibility_state="hidden"`，但不回 terrain / settlement / occupants / hints 的真實內容。
- 若 tile 可見，`visibility_state = "visible"`，才回完整摘要。

### `available_actions`

用途：
- 集中列出目前上下文下可執行的玩家操作。
- 未來 graphical UI 可直接以此生成按鈕或選單。

查詢方式：
- `get_available_actions(request)`

`request` 最低欄位：

```gdscript
{
    "team_id": int,
    "member_id": int,
    "tile_q": int,
    "tile_r": int,
    "forced_interaction_id": String
}
```

request 規則：
- `team_id` / `member_id` 使用 `-1` 表示不適用。
- `tile_q` / `tile_r` 使用 `-1` 表示不適用。
- `forced_interaction_id` 使用空字串 `""` 表示不適用。
- 若型別錯誤，回 `invalid_request`。
- 若欄位缺失，API 先補成上述預設值再處理。
- 若只有 `tile_q` 或只有 `tile_r` 非 `-1`，回 `invalid_request`。
- 若無 player 或無 controlled team，回 `no_player` / `no_controlled_team`。
- 若只有 context 不適用（例如全部 sentinel），回成功 envelope 並給空 `actions`。
- `forced_interaction_id` 是 optional optimistic-concurrency guard：空字串表示不驗證；有值時必須等於目前 world state 的 forced interaction id，否則回 `forced_response_missing`。

每個 action 至少包含：
- `action_id`
- `label`
- `enabled`
- `disabled_reason`
- `target_requirements`
- `command_name`
- `command_args`

`command_name` 只允許對應既有 command surface：
- `move_to`
- `cancel_move`
- `execute_action`
- `respond_to_forced`
- `equip_item`
- `unequip_item`
- `deposit_item`
- `take_team_item`

canonical 規則：
- `snapshot.available_actions` 的 shape 必須與 `get_available_actions(request)` 完全相同。
- `get_player_snapshot(request)` 內的 `available_actions` 視為直接重用同一套判定與映射結果，不允許雙邏輯。

composition 規則：
- top-level action 來源分四層：forced interaction、focused member、tile context、team/global context。
- 合成順序固定為：forced interaction > focused member > tile context > team/global context。
- dedupe key 為 `command_name + serialized(command_args)`。
- 若同 key 重複，保留較高優先層版本。
- 最終輸出順序依上述優先層，再依 `label` 字母序穩定排序。
- snapshot 內 forced-interaction actions 直接從當前 world state 的單一 `forced_interaction.responses` 產生，`command_args={interaction_id, response_id}`。

`target_requirements` 固定 schema：

```gdscript
{
    "allowed_kinds": PackedStringArray,
    "requires_visible_target": bool,
    "requires_forced_interaction": bool,
    "allows_self_target": bool
}
```

`command_args` 規則：
- 每個 action 必須直接攜帶足夠呼叫對應 command 的參數。
- `command_args` 永遠視為 fully bound，可直接送進 command；`target_requirements` 只做 UI 呈現/可用性說明，不補參數。
- `command_args` shape 直接對應 `command_name`：
  - `move_to` → `{tile_q, tile_r}`
  - `cancel_move` → `{}`
  - `execute_action` → `{action_id, target}`
  - `respond_to_forced` → `{interaction_id, response_id}`
  - `equip_item` → `{slot_id, item_grade}`
  - `unequip_item` → `{slot_id}`
  - `deposit_item` → `{item_grade, qty}`
  - `take_team_item` → `{item_grade, qty}`
- UI 不自行推導 command 參數；直接使用 `command_args`。

### `inventory_state`

用途：
- 收斂現有 text UI inventory mode 所需資料，避免直接讀 `player_state.inventory` 與 team 儲物內容。

至少包含：
- 玩家 inventory items
- 每筆 item 的 `grade`, `qty`, `equip_slots`
- team 可取物品列表
- 當前裝備摘要
- 與 inventory 相關的 `available_actions`

關係規則：
- `inventory_state.available_actions` 只放 inventory-global actions。
- row-scoped inventory actions 只放在 `inventory_items[*].available_actions` 與 `team_takeable_items[*].available_actions`。
- top-level `available_actions` 不包含 row-scoped inventory actions。

## Canonical DTO Schema

以下 key/type/nullability 視為 public contract。實作可內部分拆，但 public shape 不得漂移。

### `player_summary`

```gdscript
{
    "player_exists": true,
    "player_person_id": int,
    "player_name": String,
    "controlled_team_id": int,
    "controlled_team_name": String,
    "position": {"q": int, "r": int},
    "has_pending_targets": bool,
    "has_forced_interaction": bool
}
```

### `controlled_team`

```gdscript
{
    "id": int,
    "name": String,
    "faction": String,
    "position": {"q": int, "r": int},
    "members": Array[Dictionary],   # [{id, name, role}]
    "resources": Dictionary,
    "movement": {"has_target": bool, "target_q": int, "target_r": int},
    "task_summary": String
}
```

### `visible_teams`

```gdscript
[
    {
        "id": int,
        "name": String,
        "relation": String,
        "position": {"q": int, "r": int},
        "can_interact": bool,
        "can_inspect": bool,
        "can_target": bool
    }
]
```

### `focused_member`

```gdscript
{
    "id": int,                     # 無 focus 時為 -1
    "name": String,
    "team_id": int,
    "team_name": String,
    "role": String,
    "status": Dictionary,
    "available_actions": Array[Dictionary]
}
```

### `pending_targets`

```gdscript
[
    {
        "target_type": String,
        "target_id": String,
        "display_name": String,
        "is_valid": bool
    }
]
```

### `forced_interaction`

```gdscript
{
    "interaction_id": String,      # 無互動時為 ""
    "interaction_type": String,
    "source": Dictionary,
    "message": String,
    "responses": Array[Dictionary] # [{response_id, label, command_args}]
}
```

### `location_context`

```gdscript
{
    "tile": {"q": int, "r": int},
    "visibility_state": String,    # "hidden" | "visible"
    "terrain": Variant,            # hidden 時為 null
    "settlement": Variant,         # hidden/none 時為 null
    "occupants": Array[Dictionary],
    "is_player_here": bool,
    "hints": Array[String]
}
```

### `available_actions`

```gdscript
[
    {
        "action_id": String,
        "label": String,
        "enabled": bool,
        "disabled_reason": String,
        "target_requirements": Dictionary,
        "command_name": String,
        "command_args": Dictionary
    }
]
```

### `inventory_state`

```gdscript
{
    "inventory_items": Array[Dictionary],
    "team_takeable_items": Array[Dictionary],
    "equipped_items": Dictionary,
    "available_actions": Array[Dictionary]
}
```

nested sub-schema：

```gdscript
# team.members[*]
{"id": int, "name": String, "role": String}

# controlled_team.resources
{"food": int, "coin": int, "material": int}

# focused_member.status
{"health": String, "stress": float, "loyalty": float}

# forced_interaction.source
{"team_id": int, "team_name": String, "member_id": int, "member_name": String}

# forced_interaction.responses[*]
{"response_id": String, "label": String, "command_args": {"interaction_id": String, "response_id": String}}

# team.interaction_options[*]
{"action_id": String, "label": String}

# location_context.terrain
String | null

# location_context.settlement
{"id": int, "name": String, "owner_faction": String} | null

# location_context.occupants[*]
{"team_id": int, "team_name": String, "relation": String}

# inventory_items[*]
{"row_id": String, "grade": String, "qty": int, "equip_slots": PackedStringArray, "available_actions": Array[Dictionary]}

# team_takeable_items[*]
{"row_id": String, "grade": String, "qty": int, "available_actions": Array[Dictionary]}

# equipped_items
{"head": String, "torso": String, "hand_1": String, "hand_2": String}
```

empty/sentinel 規則：
- `focused_member` 無 focus 或 stale focus 時：`id=-1`, `name=""`, `team_id=-1`, `team_name=""`, `role=""`, `status={"health":"", "stress":0.0, "loyalty":0.0}`, `available_actions=[]`
- `forced_interaction` 無互動時：`interaction_id=""`, `interaction_type=""`, `source={team_id:-1, team_name:"", member_id:-1, member_name:""}`, `message=""`, `responses=[]`
- `location_context` valid-but-hidden tile 時：保留真實 `tile.q/r`，`visibility_state="hidden"`，其餘內容 redacted/null。
- `location_context` invalid/stale cursor 時：`tile={"q":-1, "r":-1}`, `visibility_state="hidden"`, `terrain=null`, `settlement=null`, `occupants=[]`, `is_player_here=false`, `hints=[]`
- `inventory_state` 無資料時：各陣列空、`equipped_items` 各槽為空字串

### `snapshot_meta`

```gdscript
{
    "focus_valid": bool,
    "cursor_valid": bool
}
```

detail query canonical shapes：

```gdscript
# get_team_details(team_id)
{
    "ok": bool,
    "code": String,
    "message": String,
    "data": {
        "team": {
            "id": int,
            "name": String,
            "faction": String,
            "position": {"q": int, "r": int},
            "members": Array[Dictionary],
            "resources": Dictionary,
            "interaction_options": Array[Dictionary]
        }
    }
}

# get_member_details(team_id, member_id)
{
    "ok": bool,
    "code": String,
    "message": String,
    "data": {
        "member": {
            "id": int,
            "name": String,
            "team_id": int,
            "team_name": String,
            "role": String,
            "status": Dictionary,
            "available_actions": Array[Dictionary]
        }
    }
}

# get_location_context(tile_q, tile_r)
{
    "ok": bool,
    "code": String,
    "message": String,
    "data": {
        "location": {
            "tile": {"q": int, "r": int},
            "visibility_state": String,
            "terrain": Variant,
            "settlement": Variant,
            "occupants": Array[Dictionary],
            "is_player_here": bool,
            "hints": Array[String]
        }
    }
}

# get_available_actions(request)
{
    "ok": bool,
    "code": String,
    "message": String,
    "data": {
        "actions": Array[Dictionary]
    }
}
```

command result canonical shapes：

```gdscript
# success
{
    "ok": true,
    "code": String,        # "ok"
    "message": String,
    "payload": Dictionary
}

# failure
{
    "ok": false,
    "code": String,
    "message": String,
    "payload": {}
}
```

各 command success payload schema：

```gdscript
# move_to
{"move_target": {"q": int, "r": int}, "refresh_required": true}

# cancel_move
{"move_cancelled": true, "refresh_required": true}

# execute_action
{"action_id": String, "result_summary": String, "refresh_required": bool}

# respond_to_forced
{"forced_interaction_resolved": true, "refresh_required": true}

# equip_item
{"equipped_slot": String, "item_grade": String, "refresh_required": true}

# unequip_item
{"unequipped_slot": String, "refresh_required": true}

# deposit_item
{"item_grade": String, "qty": int, "refresh_required": true}

# take_team_item
{"item_grade": String, "qty": int, "refresh_required": true}
```

inventory action 綁定規則：
- `inventory_items` 每筆至少包含 `row_id`, `grade`, `qty`, `equip_slots`, `available_actions`。
- `team_takeable_items` 每筆至少包含 `row_id`, `grade`, `qty`, `available_actions`。
- inventory row 內的 `available_actions[*].command_args` 必須已綁定該 row 所需參數。
- `equip_item` 若同 item 可裝多槽，需展開成多個 action，各自帶不同 `slot_id`。
- `unequip_item` 由已裝備槽位直接產生 action，`command_args={slot_id}`。
- `deposit_item` 與 `take_team_item` 在目前 spec 先用固定 qty action：deposit 預設整筆 qty、take 預設 1。若未來要可調數量，新增 `allows_qty_override` 欄位，但不阻擋本次規劃。
- 直接 command caller 若不走 generated action，可自行傳任意 `qty > 0`；API 依現有規則驗證是否允許。

interaction routing 規則：
- `respond_to_forced(interaction_id, response_id)` 專責處理 `forced_interaction.responses[*]`。
- `execute_action` 不接受 `target.kind = "interaction"`；其合法 target 只限 `none | team | member | tile`。
- 非 forced 的一般互動，透過 `execute_action` + `team/member` target 處理。
- `respond_to_forced` 需要 `interaction_id + response_id` 成對驗證。
- generated forced actions 必須攜帶 `command_args={interaction_id, response_id}`。
- `respond_to_forced` 會先比對目前 active forced interaction 的 `interaction_id`；若互動已消失或 id 不匹配，回 `forced_response_missing`。
- 在 interaction_id 匹配前提下，若 response 不存在，回 `forced_response_invalid`。

canonical envelope examples：

```gdscript
# snapshot success
{
    "ok": true,
    "code": "ok",
    "message": "",
    "data": {
        "snapshot": {
            "player_summary": {...},
            "controlled_team": {...},
            "visible_teams": [...],
            "focused_member": {...},
            "pending_targets": [...],
            "forced_interaction": {...},
            "location_context": {...},
            "available_actions": [...],
            "inventory_state": {...},
            "snapshot_meta": {...}
        }
    }
}

# detail query failure
{
    "ok": false,
    "code": "not_visible",
    "message": "target not visible",
    "data": {}
}

# command failure
{
    "ok": false,
    "code": "item_unavailable",
    "message": "item unavailable",
    "payload": {}
}
```

---

## 錯誤處理

- Query API 不 silent fail。
- 找不到玩家、隊伍、目標、互動內容時，要回傳 query envelope 錯誤，不混用「空 DTO」與「錯誤欄位」兩種模式。
- Command API 不把失敗情況留給 UI 自己讀 state 補判斷。
- 所有玩家入口共用同一套錯誤碼。

首批標準錯誤碼至少包含：

- `no_player`
- `no_controlled_team`
- `invalid_target`
- `invalid_member`
- `invalid_team`
- `invalid_tile`
- `invalid_focus`
- `invalid_request`
- `not_visible`
- `action_unavailable`
- `move_unavailable`
- `item_unavailable`
- `equip_unavailable`
- `deposit_unavailable`
- `take_unavailable`
- `forced_response_missing`
- `forced_response_invalid`

Query API 的 envelope 失敗規則：
- `get_player_snapshot` 若無玩家或無受控 team，回 `ok=false` 與對應錯誤碼。
- `get_team_details` / `get_member_details` 若目標存在但目前不可見，回 `ok=false` 與 `not_visible`。
- `get_team_details` / `get_member_details` / `get_location_context` 若無玩家或無 controlled team，回 `ok=false` 與 `no_player` / `no_controlled_team`。
- `get_location_context` 若 tile 存在但目前 hidden，回 `ok=true` 與 hidden/redacted `data.location`。
- detail query 若目標不存在，回 `ok=false` 與 `invalid_team` / `invalid_member` / `invalid_tile`。
- `get_available_actions` 若無玩家或無受控 team，回 `ok=false`；若只有 context 不適用，回 `ok=true` 且 `data.actions = []`。
- 不使用「成功但資料為錯誤字典」的混合模式。

fail-vs-sentinel carve-out：
- 只有 `get_player_snapshot` 允許對 stale UI-local 狀態降級成 sentinel sub-DTO。
- 允許降級的欄位只有 `focused_member` 與 `location_context`。
- 其他 query 一律採明確錯誤，不回 sentinel 假資料。
- `forced_interaction` 不屬於 stale local state；若世界狀態中無 forced interaction，回其空 sentinel shape，這是正常狀態，不是錯誤。

query decision table：

| Query | case | 回應 |
|---|---|---|
| `get_player_snapshot` | stale focus | `ok=true` + sentinel `focused_member` + `snapshot_meta.focus_valid=false` |
| `get_player_snapshot` | stale/invalid cursor tile | `ok=true` + hidden `location_context` + `snapshot_meta.cursor_valid=false` |
| `get_team_details` | team not visible | `ok=false`, `code=not_visible` |
| `get_member_details` | team/member not visible | `ok=false`, `code=not_visible` |
| `get_available_actions` | no player / no team | `ok=false`, `code=no_player/no_controlled_team` |
| `get_available_actions` | all context sentinel | `ok=true`, `data.actions=[]` |
| `get_available_actions` | `member_id != -1` but `team_id == -1` | `ok=false`, `code=invalid_focus` |
| `get_available_actions` | only one of `tile_q` / `tile_r` is `-1` | `ok=false`, `code=invalid_request` |
| `get_available_actions` | nonexistent `team_id` / `member_id` | `ok=false`, `code=invalid_team/invalid_member` |
| `get_available_actions` | tile 不存在 | `ok=false`, `code=invalid_tile` |
| `get_available_actions` | tile 存在但目前 hidden | `ok=true`, `data.actions=[]` |
| `get_available_actions` | stale/non-visible `team_id` / `member_id` | `ok=true`, `data.actions=[]` |
| `get_available_actions` | `forced_interaction_id` 指向不存在 forced interaction | `ok=false`, `code=forced_response_missing` |

錯誤碼原則：
- 穩定、可比對。
- 描述原因，不描述 UI 呈現。
- 不把內部實作細節暴露到 public contract。

ID 型別規則：
- public API 的 `team_id`、`member_id` 一律使用 `int`。
- `member_id` 視為 team-scoped，因此 focus/detail 查詢需要同時帶 `team_id` 與 `member_id`。
- 若 UI 端有字串化顯示，僅限顯示層，不回寫到 API 輸入。
- 若收到錯型別 id，回 `invalid_request`。

command 驗證規則：
- 所有 command 若無 player 或無 controlled team，優先回 `no_player` 或 `no_controlled_team`。
- `qty <= 0` 一律回 `invalid_request`。
- 未知 `slot_id`、未知 `item_grade`、未知 `action_id` 一律回 `invalid_request`。
- item 不存在或數量不足回 `item_unavailable`。
- slot 合法但無法裝備回 `equip_unavailable`。
- 可存/可取規則不允許時，分別回 `deposit_unavailable` / `take_unavailable`。

---

## 既有呼叫點遷移範圍

這次遷移目標：
- `scripts/ui/sim_bridge.gd`
- `scripts/ui/main.gd`
- `scripts/ui/popup_layer.gd`
- `scripts/ui/text_ui_main.gd`
- `scripts/debug/playtest_minimal.gd`
- `scripts/debug/headless_test.gd`
- `scripts/simulation/player_system.gd` 內現有玩家 helper
- 現有 `player_command_system.gd` 中可保留且值得重用的邏輯
- `scripts/simulation/sim_runner.gd` 內玩家專屬 hook
- 若在上述檔案內追蹤到同一條玩家 UI 流程的直接 consumer，再一併納入；除此之外不擴 scope

遷移完成後要求：
- 玩家相關 UI / playtest 不直接讀寫 `WorldState`。
- 玩家相關入口不直接依賴 `_state.player_pending_targets`、`_state.player_forced_event`、`_state.teams` 這類內部欄位。
- `main.gd` 不直接寫 `team.move_target`。
- inventory mode 不直接呼叫 `PlayerSystem.new().equip_item()`、`deposit_to_team()`、`take_from_team()`。
- popup inventory UI 不直接呼叫 `PlayerSystem.new().unequip_item()`。
- 若還有非玩家系統需要直接碰 state，不在本次範圍內。

---

## 與現有程式的關係

- 現有 `player_command_system.gd` 可視為 command API 前身。
- 可重用既有操作邏輯，但 public surface 要整理成明確 query / command 分層。
- 若某些 inspect helper 目前散在 UI 或 player system，應收回 query API。
- 這次重點不是改變模擬結果，而是把玩家視角邊界集中、穩定化。
- `SimRunner` 仍負責 tick 順序，但玩家專屬狀態清理（例如 clear pending targets、forced interaction timeout cleanup）要透過 player command/internal bridge 單一入口處理，避免 `SimRunner` 直接依賴玩家 UI 狀態欄位細節。
- concrete owner 定義如下：
  - `player_command_api.gd` 對外提供玩家 command。
  - `player_command_system.gd` 降為 internal bridge / legacy logic owner。
  - `SimRunner` 只可呼叫 internal bridge 的 `on_player_team_moved(state)`、`on_forced_interaction_timeout(state)`，不可直接讀寫 `player_pending_targets` / `player_forced_event`。
  - `sim_bridge.gd` 對 player-facing UI 的 end-state public interface 只保留：
    - `query_player(request) -> Dictionary`  # 代理 `player_query_api.get_player_snapshot`
    - `query_player_team(team_id: int) -> Dictionary`  # 代理 `get_team_details`
    - `query_player_member(team_id: int, member_id: int) -> Dictionary`  # 代理 `get_member_details`
    - `query_player_location(tile_q: int, tile_r: int) -> Dictionary`  # 代理 `get_location_context`
    - `query_player_actions(request: Dictionary) -> Dictionary`  # 代理 `get_available_actions`
    - `command_player(name: String, args: Dictionary) -> Dictionary`  # 代理 `player_command_api`
    - `advance_ticks(n: int) -> Array`
  - `sim_bridge.gd` 的 `get_state()` 不再提供給 player-facing UI 消費；若暫時保留，只視為 internal/testing escape hatch，不可作為新 UI 邊界。
  - `command_player(name, args)` 只允許 dispatch 到 public command surface：`move_to`、`cancel_move`、`execute_action`、`respond_to_forced`、`equip_item`、`unequip_item`、`deposit_item`、`take_team_item`。
  - `command_player(name, args)` 若 `name` 不在白名單，回 `{"ok": false, "code": "invalid_request", "message": "unknown command", "payload": {}}`
  - `command_player(name, args)` 若 `args` 缺必要欄位或型別錯誤，回 public command 的 `invalid_request`

---

## 測試與驗證

headless 測試需新增或補強以下驗證：

- Query API 可取得穩定 DTO。
- Query API 可處理 inspect / detail 類流程。
- Command API 可處理 move、cancel、action、forced interaction、inventory 類流程。
- text UI / playtest 不再直接讀玩家內部 state。
- DTO / result 必要欄位存在，避免 UI 契約回歸。
- 關鍵流程有對應驗證 print，能在 headless log 中確認。

至少覆蓋：
- `get_player_snapshot` 在有/無 focus、有/無 forced interaction 下的 shape 穩定。
- `get_team_details` / `get_member_details` / `get_location_context` / `get_available_actions` 的成功與失敗 envelope。
- 每個 command 的成功與失敗 code。
- inventory 相關 command 可取代現有 text UI 直接呼叫 player system 的流程。
- command 回傳 `refresh_required` 後，UI 可重跑 query 而不需碰內部 state。

成功標準：
- headless test 無 `SCRIPT ERROR`
- 既有玩家流程仍可跑通
- 玩家入口邊界改為 API 契約後，text UI 與 playtest 不需知道 `WorldState` 內部細節

---

## 實作注意事項

- 優先沿用現有邏輯，不要為了 API 邊界而重寫模擬規則。
- 若發現某些 UI 需求需要讀取原始 data class，先補 mapper/DTO，不回退成直接暴露內部物件。
- 若未來 graphical UI 需要更多欄位，原則上擴充 DTO，不讓 UI 穿透 API。
- 若某欄位定義不穩定，先在 API 層固定命名與 shape，再由內部做適配。

---

## 已定決策

- `focused_member` 由 UI 持有 focus id，再傳給 query API 查詢；不寫入 world state。
- `available_actions` 必須同時帶 `label` 與 `disabled_reason`，避免 UI 自行硬編。
- `available_actions` 必須直接帶 `command_args`，UI 不推導 command 參數。
- `location_context` 先由單一 query 一次回傳 tile / settlement / occupant 摘要；若後續證明過胖，再在實作中內部分拆，但 public contract 先維持單一入口。
- inspect 是 query responsibility，不是 command responsibility。
- detail query 對不可見目標回 `not_visible`，不回 redacted DTO。
