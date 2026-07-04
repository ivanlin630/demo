# Forced-Event 單一真值源（修 Q7-1 致命 softlock + Q7-2）— Design

> 來源：2026-06-18 QA。`forced_event` 處理散在三處各自 `match action`：`PlayerApiMapper.map_forced_interaction`（display+responses）/ `PlayerCommandSystem.get_forced_response_options`（id 清單）/ `respond_to_forced`（resolve）。三處 id 清單獨立維護 → drift。`choose_heir`/`aid_request` 三處都缺分支 → Q7-1（玩家 leader 死→繼承 UI 無候選→forced 永不清→**世界永凍致命**）、Q7-2（NPC 乞食玩家→玩家只能拒，破對稱）。
> 目標：id 清單單一真值源，三聯不可 drift；補 choose_heir/aid_request；加新 forced action = 一致的最小增點。通用模型，非散補三處。

## 問題

三處 `match action` 各列 response id：
- `get_forced_response_options(state)`（player_command:834）：回 id 陣列。
- `map_forced_interaction`（player_api_mapper:265）：各 action 硬編 `responses[{response_id,label,command_args}]`（id 與上重複一份）。
- `respond_to_forced`（player_command:849）：各 action match response 派 handler。

id 清單在前兩處**各維護一份** → 改一處漏另一處 = drift（QA 實證：choose_heir mapper 落 `_` fallback 只給「拒絕」，但真正要的候選 id 無處生成）。

## 設計：id 單一源 + label/handler 引用

### 規則
`get_forced_response_options(state) -> Array[String]` 成**唯一 forced response id 權威**。其餘兩處引用它，不自列 id：
- **mapper** 不再硬編 `responses` 陣列；改迭代 `get_forced_response_options(state)`，每個 id 配 label（新 `_forced_label(action, response_id, state, fe) -> String`）+ 統一 command_args。→ mapper 的 response 集合 = options，**不可 drift**。
- **respond_to_forced** 照舊驗證（已用 options）+ 派 handler（per-action resolve 邏輯，本就該分離，非 drift）。
- **prompt msg**（`map_forced_interaction` 的 `msg`）保留 per-action（display 文案，單一處）。

### 加 choose_heir（修 Q7-1）
- `get_forced_response_options`：action==`choose_heir` → 回 `fe["candidates"]` 的**動態 id 清單**（每候選一個 response_id，如 `"heir_<pid>"` 或直接 pid 字串）。
- `_forced_label(choose_heir, "heir_<pid>", ...)` → 候選人姓名（從 state.persons[pid]）。
- `respond_to_forced` choose_heir 分支：解析 response_id → heir pid → 設 `player_state["heir_id"]` + 呼 `_action_choose_heir`（既有）→ 清 forced。
- 結果：繼承 UI 列出候選人、選擇生效、forced 清除、世界解凍。

### 加 aid_request（修 Q7-2）
- `get_forced_response_options`：action==`aid_request` → `["give", "refuse"]`。
- `_forced_label`：give→「施捨 N 糧」、refuse→「拒絕」。
- `respond_to_forced` aid_request 分支：give → 設 `player_state["aid_response"]` + 呼 `_action_respond_aid_request`（既有 registered action，含 give_amount/守恆/reputation）；refuse → 拒絕。
- give_amount 來源：UI 可先用預設量（如固定/比例），或 forced 內帶建議量；MVP 用合理預設（spec 釘：give 固定一餐量或 fe 帶的 request 量），避免再開數值輸入 UI。

### UI 端（text_ui / encounter_view forced 模式）
forced 互動的 response 清單已由 mapper 的 `responses[]` 驅動（DTO），UI 迭代顯示——**choose_heir/aid_request 補進 mapper 後，UI 自動列出候選/給予選項，無需改 UI 迴圈**（UI 是 data-driven）。確認 forced 模式 UI 確實迭代 DTO responses（非硬編）。

## 連動 / 風險

- **choose_heir 動態 id**：response_id 需編碼候選 pid 且 respond 能解回。用前綴 `"heir_"+str(pid)` 編解碼（或 fe candidates index）。釘一種，mapper/options/respond 一致解析。
- **`_action_choose_heir` 既有契約**：讀 `player_state["heir_id"]` + execute_action。確認設 heir_id 後呼叫路徑正確繼承（leader 接位）。
- **aid give_amount**：避免新增數值輸入 UI（YAGNI）→ 固定/建議量。spec 釘預設來源。
- **sim_runner:99 choose_heir 排除超時清除**：設計凍世界等玩家選——修好後玩家能選即解，**不動該排除**（它是對的，前提是玩家能選）。
- **demand_tribute**：已併入 diplomacy 分支（mapper:267），不在本次。

## 測試標準

- headless：新 `_test_forced_choose_heir`（注入 choose_heir forced + candidates → options 回候選 id → respond 選一 → heir_id 設 + forced 清 + leader 接位）、`_test_forced_aid_request`（give → 守恆轉移 + forced 清）。
- ui_flow harness：choose_heir/aid_request forced 模式驅動 → responses 列候選/給予（非只拒絕）→ 選擇端到端 state 變 + forced 清。
- **drift 防護測試**：`get_forced_response_options` 的 id 集合 == mapper responses 的 id 集合（每 action，含新加的）——證單一源。
- 回歸：既有 diplomacy/extort/join_request forced 不破；`=== DONE ===`、coin_eq=0、全 invariant 0。

## 範圍

本 spec = forced-event 三聯單一源化 + choose_heir + aid_request（Q7-1+Q7-2）。Q7-3（take_loot 文字 UI）/Q7-4（anon→named）/Q7-5（子隊 task）/Q7-6（faction gate）各自獨立,後續 plan。
