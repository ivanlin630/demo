# 文字 UI 全面翻新 — Design

> 日期：2026-06-14
> 議題：stage-1 整套機制（覓食→狩獵唯一 / 小獵物 hunt / 野獸戰鬥 / 伏擊 / 絕境多元生存 / SoloAI 尋家）已 merge 且 NPC-verified，但**玩家經 UI 完全玩不到** — `text_ui_main` grep 無任何 hunt/forage/beast/ambush；player API DTO 也未暴露糧 precarity / tile wild_game / predator。原 arc 目標「世界合理 → 轉玩家可玩迴路」，世界已豐富合理，該讓玩家真能玩。
>
> 用戶指示：**UI 一律經 player API，不直讀 WorldState** → 未來換 UI（文字→圖形）只接同一 API。本翻新同時把 API 做成 UI-agnostic 契約 + 清現有邊界洩漏。

## 設計核心

四要素：

1. **API 暴露（UI-agnostic 契約）**：sim 有資料但 DTO 未 map → 補上玩家 UI 需要的全部（precarity / tile 獵物獸情 / hunt 動作 / stage-1 事件）。任何 UI（現文字、未來圖形）只讀此 DTO。
2. **嚴格 API 邊界**：UI ↔ sim **只經 player API（query/command）**，UI 不碰 `WorldState`。順帶清現有洩漏（`text_ui` 互動模式直呼 `_player_cmd`，progress 已記）。
3. **chrome 重整**：常駐 status（糧 precarity / 趨勢 / 成員健康）/ hint 行 / last-result feedback / 分級 event log。
4. **stage-1 互動接線**：hunt/hunt_beast 動作、tile 獵物獸情顯示、伏擊進 encounter、求生 precarity 可見。

## 不變量

- **UI 只經 player API**：UI 層（`scripts/ui/*`）禁止直讀 / 直寫 `WorldState`；一切經 `SimBridge` → `PlayerQueryApi` / `PlayerCommandApi` 的 DTO。換 UI 只需接同一 API。
- **DTO 是 UI 契約**：玩家 UI 需要的任何 sim 資訊，必須由 `player_api_mapper` map 進 DTO（非讓 UI 繞道取）。
- **不改 sim 規則**：本翻新只動 UI 層 + player API 暴露層（DTO mapping / available_actions）；不改 stage-1 模擬邏輯。

## 1. API 暴露層（`player_api_mapper` / `player_query_api`）

補 DTO（sim 已有資料）：
- **糧 precarity**：`map_controlled_team` / `map_player_summary` 加 `food_days`（= food ÷ pop×2.4）、`starving`(days < WARNING_DAYS)。
- **tile 獵物獸情**：`map_location_context` 加 `wild_game`(該 tile 數)、`predator`(該 tile predator_density>0 → 預警旗，依偵測 roll 給 clear/vague/none tier — 復用 `AmbushSystem.detect` 語意，認知≠真實)。
- **hunt 動作**：`available_actions` 確保含 `hunt`(腳下 wild_game>0)、`hunt_beast`(腳下 predator>0) — self/tile-target 動作（比照 build_outpost 的 none-kind）。確認 `_build_available_actions` 把這類 self 動作列入。
- **stage-1 事件**：覓食/狩獵/野獸/伏擊 episode（現多為 print）→ route 進玩家事件流 DTO（`map_global_messages` 或新 alert）。

## 2. 嚴格 API 邊界（清洩漏）

- 審 `scripts/ui/text_ui_main.gd`（+ 其他 `scripts/ui/*`）所有 `WorldState` / `_player_cmd` / 直接 sim 物件存取 → 改走 `_bridge`（SimBridge facade）。
- 已知洩漏（progress 記）：互動模式直呼 `_player_cmd.get_available_actions` → 改 `_bridge`。
- 結果：UI 對 sim 的依賴面 = 僅 SimBridge。

## 3. chrome 重整（Approach A）

VBox 動態加 Label（仿既有 AlertBar，不改 .tscn）：
- **status 區**（StateLabel 增強）：糧 `food_days`/餓警、資源**趨勢箭頭**（UI 端存每日基準 delta）、成員健康一行摘要。
- **hint 行**（常駐）：當前模式可用鍵表（各 `_handle_*_mode` 對一張靜態 keymap）。
- **feedback 行**（常駐）：上一指令成/敗 + 原因，著色（綠成/紅敗），持續到下個指令（不再瞬時擠 InputBar）。
- **event log**：與 panel 共存（常駐最新 N 條，不被 panel 蓋）+ 分級著色 + 露 stage-1 episode。

## 4. 全動作覆蓋（Phase 3 — 現有功能一律上 UI）

**鐵則：現有 player 指令一律 UI 可達，不遺漏。** registry 現 63 動作。

- **覆蓋審計**：列 `player_command_system` registry 全 63 動作 → 對照 text_ui 已接 / 未接，補齊未接的（含**調稅 `set_tribute_rate`**、outpost build/upgrade/farming/manufacturing、faction goal/order、subteam、trade、recruit、treasury/storage…）。
- **調薪缺口（S9，需先補指令）**：玩家設 named 成員薪資**無指令**（grep 空）→ 屬 sim 側缺口，非純 UI。Phase 3 前置：`player_command_system` 補 `set_member_salary`（玩家管 loyalty 的手段，S9 設計意圖）→ 再上 UI。
- 每動作經 `available_actions` DTO 驅動（contextual 可用性），UI 只渲染清單，不硬編動作邏輯。

## 5. stage-1 互動接線（text_ui）

- **hunt / hunt_beast**：tile/互動選單列出（available_actions 驅動），站獵物/獸格可發起。hunt_beast → 起 encounter（既有 encounter_view 接管）。
- **tile info**：顯 `wild_game` 數、`predator` 預警 tier（認知分級）。
- **伏擊**：被伏擊 → encounter（既有 view）；偵測到 → 預警訊息（feedback/event）。
- **precarity**：status 區糧 days + 餓警；求生 task（覓食/紮營/投靠/掠奪）若玩家隊觸發 → 顯示當前求生行動。

## 風險

- **範圍大**：跨 player API 暴露 + text_ui 渲染。plan 須**分 phase**（建議：① API 暴露 + 邊界清理 → ② chrome → ③ stage-1 互動），各 phase 獨立可驗。
- **邊界回歸**：清洩漏時勿改 sim 行為；改完跑既有 UI 測試（`team_ui_test` / `ui_logic_test`）+ headless 確認無回歸。
- **趨勢基準**：UI 端存每日基準算 delta（無需改 API）。
- **keymap 維護**：hint keymap 為 UI 靜態表，新增 mode 須同步（接受）。
- **不改 .tscn**：新 Label 動態建立（仿 AlertBar）。
- **YAGNI**：不碰圖形 Main.tscn 場景棧（本翻新限文字 UI）。

## 測試

- API 暴露：`player_query`/`mapper` 單元 — DTO 含 food_days/starving、location 含 wild_game/predator、available_actions 含 hunt/hunt_beast（站對應格時）。
- 邊界：grep `scripts/ui/` 無直接 `WorldState` / `_player_cmd` 存取（除 bridge 持有）。
- UI 渲染：`team_ui_test` / `ui_logic_test` 覆蓋新 chrome 區塊 + stage-1 顯示（沿用既有 UI 測試模式，headless 可驗的部分）。
- 整合：headless_test 無回歸；手動/腳本確認 chrome 四區 + hunt 動作 + tile 獸情顯示（互動式部分以 helper 函數單元覆蓋）。
