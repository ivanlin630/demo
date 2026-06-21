# Hand Back: food 買單側（食物雙向市集）

Plan: `docs/superpowers/plans/2026-06-22-food-buy-orders.md`
Branch: `feat/food-buy`

## 實作摘要
- `scripts/simulation/order_system.gd`：
  - 新增兩個 const：`FOOD_BUY_DAYS = 4.0`、`FOOD_BUY_TARGET_DAYS = 8.0`（皆 TEST VALUE）。
  - `tick_team_orders` 短缺買單迴圈後加 food 買單分支：`effective_food(state,team)`（私產+自家糧倉，WS-2c 單源）/ burn 天數 < FOOD_BUY_DAYS → `post_order(buy, food, need)`，need = `(FOOD_BUY_TARGET_DAYS - fdays) * burn`，並 `Probe.bump("g1.food_buy")`。純 order 層，不碰 resources/coin 池。
- `scripts/debug/headless_test.gd`：
  - 新增 `_test_food_buy_order()`（缺糧隊應發 food buy；飽糧隊不發），註冊於 `_test_food_surplus_sell()` 之後。

與 spec 無差異。

## order dict 欄位確認
plan 假設 `"kind"` / `"res"` —— **已驗證正確**。`post_order`（order_system.gd L24-27）建的 entry：
`{ "order_id", "kind", "res", "qty_remaining", "expire_tick" }`，`_has_active` 亦以 `o["kind"]`/`o["res"]` 比對。測試與斷言沿用真實 key，無需改。

## TDD 證據
- RED：未加分支前，缺糧隊只發 weapon/material/ore buy，無 food buy → 斷言失敗（active_orders 印出證明）。
- GREEN：加分支後 `food buy order OK` + `food surplus sell OK` 同綠。

## food_buy 探針 + 雙向市集證據（2 年 world_sim，unseeded）
- run 1：`g1.food_buy = 152`、`g1.order_placed = 3473`、`g1.shortage_buy = 2081`。
- run 2：`g1.food_buy = 304`（unseeded，相對判定）。
- 兩 run 皆 `food_buy > 0` → 缺糧隊有表達糧需求 = food 買單側成立。
- 雙向：WS-1 既有 food **sell**（糧倉滿→賣）+ 本 task food **buy**（缺糧→徵）同存於 order 層 = 食物雙向市集 plumbing 完整。
- `world_sim DONE`，24 月跑完，存活隊=5，0 SCRIPT ERROR。

## 回歸結果
- headless：0 SCRIPT ERROR、0 Assertion failed、`=== DONE ===`。
- coin_eq 整合測：`投靠守恆整合 OK`。
- InvariantAudit：population / faction 雙向 / subteam 雙向 全 OK。
- food-sell / famine（Task1a-3c）/ survival 既有測全綠。

## 連動風險 / 待主 session 確認
- **訂單履約率 = 0.0%、`[Market]...成交` 未在此 2yr unseeded run 出現**：food buy 單有發、但商隊未完成 food 撮合/搬運。屬下游 matching/fulfillment 議題（本 plan 範圍僅買單側 plumbing，acceptance = food_buy > 0，已達）。建議後續 task 觀測：商隊是否接 food buy 單並運糧到會合 pos、settle_orders 是否沖 food 單。
- `g1.market_arrive = 11`（隊抵市集 outpost 讀看板次數偏低）：可能限制履約，與本 task 無關，供後續定居隊/商隊路由觀測參考。
- FOOD_BUY_DAYS / FOOD_BUY_TARGET_DAYS 為 TEST VALUE，正式平衡需調。
