# Hand Back: 物物交換 offer-builder 交易介面

## 實作摘要

- `scripts/simulation/interaction_system.gd`：加公開 wrapper `local_value(team, res)`（`_local_value` 仍私有），供 DTO 估值。
- `scripts/simulation/player_api_mapper.gd`：新 `map_trade_session(state, target_id)` → 回 `{feasible, player_items, target_items, offer{gives,wants}, give_value, want_value, npc_would_accept}`。估值 reuse `InteractionSystem.local_value`，接受預估 reuse `PlayerTradeSystem.evaluate_offer`（單一真相，與 submit 同函數）。白名單限 `BASE_PRICE`（coin 另列 face value 1.0）。
- `scripts/simulation/player_query_api.gd`：新 `get_trade_session(state, target_id)` facade（`_check_player_with_team` + envelope）。
- `scripts/ui/sim_bridge.gd`：新 `query_trade_session(target_team_id)`。
- `scripts/ui/text_ui_main.gd`：重寫 `_handle_trade_mode`/`_build_trade_str`（舊「貿易確認」auto-trade → offer-builder）。新 `_trade_session_rows`/`_trade_add` helper、`_trade_page` 分頁。進交易模式時初始化空 `trade_offer`。MODE_KEYMAP trade 鍵表更新。
- `scripts/debug/headless_test.gd`：新 `_test_trade_session_dto`（DTO 結構）+ `_test_trade_conservation`（成交守恆：coin_eq 不變、雙向轉移）。
- `scripts/debug/ui_flow_test.gd`：新 `_test_trade_offer_builder`（雙欄+天平字串）。

與 spec 無差異。零新交易邏輯（估值/接受/轉移全 reuse 既有）。

## 測試結果

- headless：`=== DONE ===`，trade_session DTO OK / trade conservation OK。
- ui_flow：errors 0（含新 offer-builder 測）。
- ui_logic：errors 0。
- **baseline 既有失敗**（非本 plan 造成，main 同樣失敗）：`_on_team_extinct` 的 `assert(... food 應進公庫)`（FactionAISystem 滅團路由）。本 plan 未碰 FactionAISystem。

## 連動風險

- `估值雙來源`：天平顯示值用 `InteractionSystem.local_value`，NPC 接受用 `PlayerTradeSystem.evaluate_offer`（內部 `PlayerTradeSystem._local_value`）。兩 `_local_value` 公式僅差 SURVIVAL_GOODS 飢荒加價（生存品短缺過半時 InteractionSystem 會飆價、PlayerTradeSystem 不會）。一般物資相同；極端飢荒情境下「天平給值看似足夠但 NPC 拒絕」可能誤導玩家。spec 已選此 whose-value 設計，若要消除可改 DTO 估值也走 `PlayerTradeSystem._local_value`。
- `confirm_trade legacy`：`_action_confirm_trade` 仍保留 NPC-initiated 的 legacy auto-trade 分支（無 trade_offer 時走 `resolve_trade_direct`）。玩家 UI 現只走 offer-builder + `submit_trade_offer`，legacy 分支僅 NPC 觸發流程使用，未動。
- `query_trade_direct_preview`：本介面已不再呼叫（舊 `_build_trade_str` 用）。API 仍在，未移除。

## 待主 session 確認

- 真視覺（兩欄版面、分頁、天平排版）需人工 run-verify（DTO/flow/守恆已自動測，但版面美觀無法自動斷言）。
- counter-offer 未做（YAGNI，spec 確認）。
- 建議後續：若覺得估值雙來源易誤導，統一為單一 `_local_value` 來源。
