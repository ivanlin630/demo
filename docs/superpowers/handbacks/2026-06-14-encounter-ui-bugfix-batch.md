# Hand Back: 遭遇戰/互動 UI Bug 批修（U10-U14）

Branch: `feat/encounter-ui-bugfix`
Plan: `docs/superpowers/plans/2026-06-14-encounter-ui-bugfix-batch.md`

## 實作摘要

| 檔案 | 改動 |
|---|---|
| `scripts/ui/encounter_view.gd` | U10 戰後分支（不再空白凍結）+ static helper `_post_combat_hint`/`_post_combat_summary`；U11 「戰報」label 滾顯 `query_encounter_log`；U14 「我方/敵方」兵力 label |
| `scripts/data/world_state.gd` | U11 新增 `encounter_log: Array` 欄位 |
| `scripts/simulation/encounter_system.gd` | U11 `init_encounter` 清空 log；`resolve_attack` 命中/落空/格擋/閃避各 append；helper `_unit_label`/`_enc_log` |
| `scripts/ui/sim_bridge.gd` | U11 `query_encounter_log(n)`；U12 `query_trade_direct_preview` facade |
| `scripts/simulation/player_query_api.gd` | U12 `get_trade_direct_preview`（包 `InteractionSystem.preview_trade`，回 `{feasible, player_gives, player_gets}`） |
| `scripts/ui/text_ui_main.gd` | U12 `_build_trade_str` 改呼叫 direct preview；U13 inv 版面三段化 + `[U]` 卸下鍵（`_inv_equipped_slots` helper）+ 模式提示 |
| `scripts/debug/headless_test.gd` | U11 `encounter_log` append 測；U12 `_test_u12_trade_direct_preview`；U14 spawn 公式 assert |
| `scripts/debug/ui_logic_test.gd` | U10 `_test_post_combat_hint`（5 斷言） |

### 逐 bug 根因 + 修法 + 驗證

- **U10（H, blocker）戰後凍結**：`_refresh_ui` 無 player_unit 即 early-return，戰畢 `encounter_units` 清空 → 戰後提示從未渲染。修：`_post_combat`/`not encounter_active` 分支顯戰果 + 「按任意鍵離開 / [J]收編」。**驗證**：ui_logic_test 5 斷言 PASS。**GUI 凍結觀感待人工 run-verify**。
- **U11（M）命中無回饋**：`resolve_attack` 只 `print` 到 console。修：加 `encounter_log` channel 經 bridge facade 顯 UI。**只加 log，不改戰鬥結果**。**驗證**：headless `encounter_log OK: ["匿名兵 擊中 匿名兵 torso -10"]`。**滾動顯示待 run-verify**。
- **U12（M）交易誤判無資源**：根因 = `_build_trade_str` 讀錯 preview shape（offer-based vs auto-trade）。confirm 流程本身正常。修：加 direct preview API。**驗證**：headless `feasible=true, player_gives={food:20}, player_gets={coin:20}`。**GUI 待 run-verify**。
- **U13（M）無卸下入口**：inv 已裝備物不可選。修：已裝備槽前置可選 + `[U]` 綁 `unequip_item`。**卸下流程待 run-verify**。
- **U14（L）進場人數存疑**：**確認非 bug** — spawn = `named + min(pop×ratio, CAP)` 正確（ratio<1 非全員上場為設計）。加公式 assert + UI 兵力 label 補觀感。**驗證**：headless `team0 進場 5（pop10×0.5）`。

### 全測試結果
- `ui_logic_test`：**0 errors**（含 U10 5 斷言）。
- `headless_test`：U11/U12/U14 OK、`=== DONE ===`。唯一 `SCRIPT ERROR: food 應進公庫` = **pre-existing Bug8 baseline**（非本批，plan 明示勿動），與 baseline 同一 halt 點，**無新增回歸**。
- `team_ui_test`：`=== TEAM UI TEST DONE ===`，無 error。

## 連動風險
- `encounter_system.resolve_attack`：新增 `_enc_log` 對 NPC vs NPC 的 encounter 也會 append（玩家視角戰報含非玩家單位戰鬥）。僅顯示用，無守恆/結果影響。NPC vs NPC 多走 `npc_combat`（不經 encounter），實際 spam 風險低。
- `world_state.encounter_log`：未在 `resolve_encounter_end` 清空（僅 `init_encounter` 清）→ 戰後仍可讀（U10 戰後畫面正需要）。下場戰開始時清。**不入存檔/快照**，無守恆顧慮。
- `encounter_view.gd` 仍 `_bridge.get_state()` 直讀 raw state（U9 邊界債既有）；U11 combat log 走 bridge facade 符合邊界，但本檔整體解耦屬 U9 另案。
- `text_ui_main` inv 選取 index 版面重排（已裝備在前）：E/S/G 既有鍵的 index 計算已同步調整，數字鍵 1-9 範圍含三段。**若他處依賴舊 inv index 語意需注意**（已查無其他依賴）。

## 待主 session 確認
- **GUI run-verify 清單**（headless 測不到）：
  1. U10 獵獸/打贏後畫面顯「按任意鍵離開 / [J]收編」，按鍵可離開不卡。
  2. U11 戰鬥中右側「戰報」滾動顯命中/傷害。
  3. U12 互動→交易顯實際付出/獲得，不再跳「無可交換資源」。
  4. U13 inv 選已裝備物 → `[U]` → 卸下、回庫、feedback。
  5. U14 進場「我方/敵方」兵力 label 正確。
- **設計決策**：U12 text-UI 交易採 auto-trade（`resolve_trade_direct`，系統自動算互補轉移），非 offer-based 議價。若要玩家自訂出價 UI 屬另案（offer-based 路徑已存在但無 text-UI 入口）。
- **建議後續**：encounter_log 可接「戰報廣播」（known_issues 待 spec「encounter-engagement 後續」）。
