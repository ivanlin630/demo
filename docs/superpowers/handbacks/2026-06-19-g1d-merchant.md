# Hand Back: G1d 商隊訂單履約/套利（閉環 G1b）

branch: `feat/g1d-merchant`（已 push，未 merge）

## 實作摘要

- `scripts/simulation/order_system.gd`：
  - 新 const `SHORTAGE_QTY=3.0`、`MERCHANT_MAX_RANGE=20`（TEST VALUE）。
  - 新 `received_sell_orders`（鏡像 `received_buy_orders`，掃 `team_known` 的 `order_sell`）。
  - 新 `best_arbitrage_order`：掃 received sell（便宜買回）+ buy（有貨高價賣）訂單，`local_value × qty × 0.1` proxy 取最高正套利分，距離 `MERCHANT_MAX_RANGE` 內，回 `{kind,res,qty,pos,origin_team,order_id}`。
  - 新 `_hex_dist`（self-contained，未依賴 EncounterSystem）。
  - `tick_team_orders` 末加「短缺發買單」：料/武器 res < `SHORTAGE_QTY` 且無 active buy → `post_order("buy")`。
  - `received_buy_orders` 補 `order_id` key（原缺，`best_arbitrage_order` buy 分支需讀 → 修一個 runtime SCRIPT ERROR）。
- `scripts/simulation/faction_ai_system.gd`：
  - 新 `_merchant_trade_target(state, team) -> Vector2i`：商業 archetype 隊先試 `best_arbitrage_order`（殘缺情報），非空回訂單 pos；否則 fallback `_find_trade_target`（team_discovered 上帝視角）。
  - solo TASK_TRADE 指派處（`_evaluate_solo` match arm）+ faction member trade 分支（`_can_trade`）兩 caller 改用 `_merchant_trade_target` 取代直呼 `_find_trade_target`。
- `scripts/debug/headless_test.gd`：新 `_test_received_sell_and_arbitrage`、`_test_merchant_order_targeting`，註冊於 G1b 測試塊後。
- docs：`invariants.md`（訂單系統段 + 商隊讀殘缺情報/禁上帝視角/短缺買單/撲空 emergent）、`known_issues.md`（G1d ✅ + refinement 清單）、`progress.md`（2026-06-19 當前狀態）。

## 與 spec 的差異

1. **未設 `team.order_target_id`**（plan Step3 建議設為 origin_team）。原因：`order_target_id` 被 ESCORT/MERGE/HERALD 多工復用，且 `invariant_audit` 會 flag 懸空 ref（origin 隊若在商隊抵達前死亡 → 「懸空 order_target_id」→ 破 InvariantAudit 0 閘）。改純靠 `move_target=訂單 pos` + 既有 interaction 同格 trade 履約，無需 target 隊 ref。功能等效、避審計風險。
2. arbitrage 分數為 plan 標註的 proxy（TEST VALUE），未做精細「買價 vs 賣價」套利 — 屬平衡 pass。

## 驗證

- `headless_test.gd`：`received_sell + arbitrage OK`、`merchant order targeting OK`、`=== DONE ===`；SCRIPT ERROR=0、Assertion failed=0、FAIL=0；coin_eq 守恆 OK、InvariantAudit 框架全綠。
- `game_sim_multi.gd`：21600 tick 無崩潰（SCRIPT ERROR=0、crash=0），sim 中買單 oid 實際湧現（短缺買單生效）、貿易成功 log 出現。

## 連動風險

- `_find_trade_target`（team_discovered 上帝視角）：降為 fallback，仍存在於非商業 archetype 或無訂單路徑。最終應刪（已標 deprecated 於 invariants/known_issues），主 session 決定何時清。
- `interaction_system` 同格 trade：到場履約復用既有路徑，未改；撲空（stale 訂單）靠既有 `local_value` glut emergent，未加硬閘 — 需 sim 觀測確認分工鏈貨流合理（非單測可驗）。
- `order_target_id` 審計：因採差異 1 未設此欄，無新懸空風險。
- 短缺買單 res 白名單（料/武器）為 proxy；可能對非生產隊亂徵 — TEST VALUE，待平衡觀測。

## 待主 session 確認

- 差異 1（不設 order_target_id）是否接受，或要求補「履約後核對發起隊 active_orders 部分扣減」的記帳（plan OUT 範圍，現整單/盡量履約）。
- distort 是否會動 order params（res/qty）：現假設只動 description/strength，撲空主靠過期；若 distort 動 params，撲空語意需另議。
- `_find_trade_target` 完全刪除時機。
- arbitrage 公式 + SHORTAGE_QTY/MERCHANT_MAX_RANGE 平衡調參歸入後續 balance pass。
