# Player API Boundary 設計 Spec

> **狀態：設計完成，待 implementation plan**
> 本 spec 定義玩家操作 API 邊界，目標是讓 text UI、playtest、未來圖形 UI 都透過穩定 DTO / command result 與模擬層互動，而不是直接依賴 `WorldState` 或內部資料結構。

## 目標

- 收斂所有玩家相關入口，覆蓋現有 text UI、playtest、player helper。
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
- **可漸進升級**：未來若引入 snapshot store / command bus，盡量不改 UI 介面。
- **禁止直接 script outcome**：API 只暴露由既有 NPC / team 狀態推導出的可見結果，不新增繞過模擬規則的捷徑。

---

## 目標結構

```text
scripts/simulation/
  player_query_api.gd
  player_command_api.gd
  player_api_mapper.gd
```

### `player_query_api.gd`

責任：
- 提供玩家相關 read-only 查詢。
- 從 `WorldState` 擷取資料並組裝成穩定 DTO。
- 對外隱藏內部 data class 與字典結構。

### `player_command_api.gd`

責任：
- 提供玩家操作入口。
- 代理既有玩家操作流程（move / cancel / execute_action / forced response 等）。
- 回傳標準 result，避免 UI 再回頭讀內部 state 補判斷。

### `player_api_mapper.gd`

責任：
- 集中做 DTO 映射與欄位裁切。
- 統一欄位命名，避免 UI 分散依賴不同內部命名。
- 成為未來切換到 snapshot store 時的相容層。

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

DTO 規則：
- 可序列化、平面化優先。
- 只放 UI 真正需要的欄位。
- 不回傳 `TeamData`、`PersonData`、原始節點引用、內部索引結構。
- 若欄位暫時不存在，明確用 `null`、空陣列、空字典或狀態欄位表達，不靠 UI 猜。

Query API 至少提供以下方法：

- `get_player_snapshot()`
- `get_team_details(team_id: String)`
- `get_member_details(team_id: String, member_id: String)`
- `get_location_context(tile_q: int, tile_r: int)`
- `get_available_actions(context: Dictionary)`

### Command API 對外輸出

Command API 提供既有玩家行為入口，至少覆蓋：

- `move_to`
- `cancel_move`
- `execute_action`
- `respond_to_forced`

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

---

## 資料流

### 讀取流程

1. UI 啟動或每 tick 刷新。
2. UI 呼叫 `player_query_api.get_player_snapshot()` 取得 envelope。
3. 若 `ok = true`，UI 讀 `data.snapshot` 重繪畫面。
4. 若 `ok = false`，UI 依 `code/message` 顯示一致錯誤訊息，不直接讀 `WorldState` 補救。

### 操作流程

1. UI 呼叫 `player_command_api` 發出玩家操作。
2. API 在內部執行既有模擬/玩家流程。
3. API 回傳標準 result。
4. UI 依 result 決定提示訊息與是否重刷 query。

### 未來升級路徑

若未來導入方案 C：
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

### `focused_member`

用途：
- 提供 UI 當前聚焦成員資訊，而不是直接回 person 物件。

查詢方式：
- UI 持有 `focused_member_id`
- 透過 `get_member_details(team_id, member_id)` 取得

至少包含：
- member id / name
- 所屬 team id / name
- role 摘要
- 關鍵狀態摘要（health / stress / loyalty 等現有 UI 已需要欄位）
- 當前可執行 member-level actions

### `pending_targets`

用途：
- 取代 UI 直接讀 `_state.player_pending_targets` 的行為。

### `forced_interaction`

用途：
- 取代 UI 直接讀 `_state.player_forced_event`。
- 統一輸出必回應互動的類型、來源、可選動作與必要顯示文字。

### `location_context`

用途：
- 提供目前 tile / settlement / occupant 等位置上下文，讓不同 UI 不必自行拆 state。

至少包含：
- tile 座標
- terrain 摘要
- settlement 摘要（若無則為 `null`）
- occupant teams 摘要列表
- 是否為玩家目前所在位置
- 與該位置相關的 target / interaction hints

### `available_actions`

用途：
- 集中列出目前上下文下可執行的玩家操作。
- 未來 graphical UI 可直接以此生成按鈕或選單。

查詢方式：
- `get_available_actions(context)`，其中 context 至少可帶 `team_id`、`member_id`、`tile_q`、`tile_r`、`forced_interaction_id`

每個 action 至少包含：
- `action_id`
- `label`
- `enabled`
- `disabled_reason`
- `target_requirements`
- `command_name`

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
- `action_unavailable`
- `move_unavailable`
- `forced_response_missing`
- `forced_response_invalid`

錯誤碼原則：
- 穩定、可比對。
- 描述原因，不描述 UI 呈現。
- 不把內部實作細節暴露到 public contract。

---

## 既有呼叫點遷移範圍

這次遷移目標：
- `scripts/ui/text_ui_main.gd`
- `scripts/debug/playtest_minimal.gd`
- `scripts/simulation/player_system.gd` 內現有玩家 helper
- 現有 `player_command_system.gd` 中可保留且值得重用的邏輯

遷移完成後要求：
- 玩家相關 UI / playtest 不直接讀寫 `WorldState`。
- 玩家相關入口不直接依賴 `_state.player_pending_targets`、`_state.player_forced_event`、`_state.teams` 這類內部欄位。
- 若還有非玩家系統需要直接碰 state，不在本次範圍內。

---

## 與現有程式的關係

- 現有 `player_command_system.gd` 可視為 command API 前身。
- 可重用既有操作邏輯，但 public surface 要整理成明確 query / command 分層。
- 若某些 inspect helper 目前散在 UI 或 player system，應收回 query API。
- 這次重點不是改變模擬結果，而是把玩家視角邊界集中、穩定化。

---

## 測試與驗證

headless 測試需新增或補強以下驗證：

- Query API 可取得穩定 DTO。
- Command API 可處理 move、cancel、forced interaction、inspect 類流程。
- text UI / playtest 不再直接讀玩家內部 state。
- DTO / result 必要欄位存在，避免 UI 契約回歸。
- 關鍵流程有對應驗證 print，能在 headless log 中確認。

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
- `location_context` 先由單一 query 一次回傳 tile / settlement / occupant 摘要；若後續證明過胖，再在實作中內部分拆，但 public contract 先維持單一入口。
