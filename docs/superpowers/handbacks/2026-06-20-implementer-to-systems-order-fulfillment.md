---
from: implementer
to: systems
status: consumed
date: 2026-06-20
feature: order-fulfillment
plan: docs/superpowers/plans/2026-06-20-order-fulfillment.md
spec: docs/superpowers/specs/2026-06-20-order-fulfillment-design.md
branch: feat/order-fulfillment
---

# Hand Back: #1 經濟閉環 plan-1 訂單履約結算

## 實作摘要

照 plan 全文實作，零偏離：

- `scripts/simulation/order_system.gd`：新增 `settle_orders(team, before, _tick) -> bool`。按窗內 res 淨持有變化（`team.resources[res] - before[res]`）沖 `active_orders.qty_remaining`，buy 單持有增才算 / sell 單持有減才算，同 res 多單共享 delta 池 FIFO。填滿（qty<=0）移除 order + `Probe.bump("g1.order_fulfilled")`。**零 resources/coin 變動**（純記帳）。
- `scripts/simulation/interaction_system.gd`：`_resolve_market` 在交易窗（absorb 後 / spillback 前，`team.resources` = 私有+公庫完整持有）快照雙方 `_snapshot_order_res` → 交易 → `settle_orders` 雙方。任一隊 progressed 且對方掛 `TAG_MERCHANT` → `Probe.bump("g1.arb_hit")`。新增 helper `_snapshot_order_res`。
- `scripts/debug/headless_test.gd`：新增 `_test_order_fulfillment()`（plan Step1 測試碼原樣），註冊於 G1d cluster 後。

與 plan/spec 差異：無。唯一語法調整 = `settle_orders` 的 `tick` 參數未使用，改名 `_tick` 避免 GDScript unused-param warning（純命名，行為等同）。

## 單測結果（headless 回歸，閘全綠）

- `order fulfillment OK`（買單沖 5、填滿移除、sell 撲空不沖、sell 賣出 4 沖銷——4 子斷言全過）
- `=== DONE ===`
- 0 SCRIPT ERROR、0 Assertion failed、0 FAIL
- coin_eq 守恆斷言過（`投靠守恆整合 OK` / `trade conservation OK` / barter coin=0 斷言）
- InvariantAudit population OK / faction 雙向 OK / subteam 雙向 OK

## world_sim 煙霧（非確定，僅證機制通——非閘、非平衡證據，見 reference_multi_sanity_unseeded）

跑通無 SCRIPT ERROR，`[ProbeSummary]` 印出。關鍵數字：

- `g1.order_placed = 4536`、`g1.shortage_buy = 3342`（訂單發布正常）
- **`訂單履約率 = 0.0%`**（仍 0）
- **`套利命中率 = n/a`**（`g1.arb_attempt` = 0，分母 0）
- `g1.order_fulfilled` / `g1.arb_hit` / `g1.arb_attempt` 三者皆 0（ProbeSummary 略過零值 key，故未列）
- `[Market] 成交` print 在整 run 中 0 次

## 異常 / 上游懷疑（**履約率仍 0 = 上游 targeting/reachability，非結算 bug**）

settle 機制本身單測證實正確（履約/部分/撲空/sell 對稱皆過）。world_sim 履約率 0% 的根因在**上游**，符 plan Step3 預判：

- `g1.arb_attempt = 0` → 商隊 `_merchant_trade_target`（faction_ai:1180）的 `best_arbitrage_order` **從未回非空單** → 沒有商隊被 dispatch 去 TASK_TRADE 履約地。
- `[Market] 成交 = 0` → 整 run 沒有任何 market 交易發生（不只是商隊——一般估值交易也沒成交到 coin 變動）。
- 即 `_resolve_market` 內的 settle 接線正確，但**沒有 market 被觸發**（同格 trade interaction 沒發生），所以沒貨可沖、沒 order 可履約。

可能上游懷疑（呈報系統，**未自行修**，超出本 plan 範圍）：
1. 商隊根本沒成形 / 沒掛 `TAG_MERCHANT`（archetype 派生）→ `best_arbitrage_order` 永空。
2. 有商隊但 `received_buy/sell_orders`（team_known order message）為空 → message 傳播沒到商隊，或 `MERCHANT_MAX_RANGE`(20) 外 → arb 挑不到單。
3. 商隊挑到單但 reachability/movement 沒把它帶到 `ord["pos"]` 同格 → `process_on_move` 沒觸發同格 market。
4. 此 world_sim 場景無確定貿易配對（unseeded、無確定性貿易場景）→ 供需根本沒在同格 align。plan/spec 已註明真平衡 TEST VALUE（單價/reserve/range）待**確定性貿易場景**，本 run 不可當證據。

> 結算 seam 已點亮（死 probe `g1.order_fulfilled`/`g1.arb_hit` 現可被 bump，單測證實）。要讓 world_sim 履約率非零，需上游讓「商隊帶貨到掛單隊同格成交」真發生——屬 G1d targeting / 貿易場景平衡，獨立 workstream。

## 連動風險

- **守恆**：純記帳，零 resources/coin 變動 → coin_eq/物資守恆數學上不可破（回歸 coin_eq 斷言過 = 形式確認）。無連動風險。
- **單一所有者**：沖銷只動發起隊自己的 `active_orders`；商隊 received（message 副本）唯讀不動 → 無雙寫 race。
- 與已 merge（#0b person_generator / feud npc_ai+combat）不同檔，無衝突。

## 待主 session 確認

- 履約率 world_sim 仍 0 是否接受作本 plan 收尾（機制已通+單測證實，0 是上游 targeting/場景問題，非結算 bug）？若要點亮 world_sim 履約率 → 需新 workstream 處理上述上游懷疑（建議先量測商隊 archetype/arb_attempt 為何全 0，measure-first）。
- `settle_orders` 的 `_tick` 參數目前未用（保留作未來時效/到期審計鉤子）；如系統認為應移除可後續清。
