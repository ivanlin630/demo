# Hand Back: G1b 訂單系統 + 需求驅動生產

> branch `feat/g1b-orders`（已 push origin）。plan `2026-06-19-g1b-orders-demand-production.md` 全 4 Task 完成。

## 實作摘要

- `scripts/simulation/order_system.gd`（新）：`class_name OrderSystem`。`post_order`（權威存發起隊 `active_orders` + `emit_message("order_buy"/"order_sell")` 傳播副本 + `[Order]` log）、`received_buy_orders`（掃 team_known 的 order_buy 副本）、`tick_team_orders`（過期清理 + 餘量發賣盤，cadence）、`_has_active`。常數 ORDER_LIFETIME/POST_CADENCE/SURPLUS_RESERVE_MULT/_ORDER_ELIGIBLE_RES 全 TEST VALUE。
- `scripts/data/team_data.gd`：加 `active_orders: Array`、`order_eval_next_tick: int`。
- `scripts/simulation/faction_ai_system.gd`：`evaluate_all` 每-team loop（野心 cadence 後）加訂單 cadence——`leader_id != -1 且到期 → tick_team_orders + 設下次 ORDER_POST_CADENCE`。
- `scripts/simulation/manufacturing_system.gd`：`_run_recipe_group` 加 `state` 參數（caller tick_all 同步更新）；選 recipe 前讀 `received_buy_orders` 建需求集，排序改 ①需求命中優先 ②其次原缺口 ratio。訂單 → 生產真 reader（非 dormant）。
- `scripts/debug/headless_test.gd`：3 測試 + `_initialize` 註冊——`_test_order_post_and_read`、`_test_order_cadence_and_expire`、`_test_demand_driven_production`（含控制組證無需求時走預設順序、實驗組證買單翻轉偏好）。
- `docs/invariants.md`：加「訂單系統」section。
- `docs/known_issues.md`：加「G1 供應鏈進度」（G1a/G1b ✅，G1d 待辦）。

## 與 spec 差異

- Task2 plan code 留了一行 `var reserve = TradeValuation.local_value(...)` 當 proxy 但實際 gate 在 `qty >= 20`——該行未被使用故**省略**，gate 直接用囤量門檻（語意同 plan，去 dead code）。
- Task3 plan 標為最高風險（怕 RECIPE_GROUPS 全單-out 致偏好無從展現）。**已證偽**：weaponsmith_level（melee_low/ranged_low/...）與 manufacturing_level/armorsmith_level 皆多-out，需求偏好可展現。reader 接點維持在 recipe 選取層，無需上移到 facility 層。
- `post_order` 加了 `[Order]` log（plan 要求「log 見訂單發布」但 plan code 無 print）——對齊 `[Manufacture]` 觀測模式。

## 回歸

`--import` + `headless_test.gd`：`=== DONE ===`、0 SCRIPT ERROR、0 失敗 assert、InvariantAudit(population/faction/subteam) OK、3 新測 OK。live sim 見多隊 `[Order] ... sell/buy ...` 觸發。

## 連動風險

- `manufacturing_system._run_recipe_group`：簽名加 `state` 參數。已掃唯一 caller = `tick_all`（同 commit 更新）。若他處有外部呼叫需確認（grep 當下只有 tick_all + test）。
- `faction_ai_system.evaluate_all`：每-team 每到 cadence `OrderSystem.new()`（per-team 短命物件，同 AmbitionLadder/既有模式）。量大時可考慮共用單例，但與現有 pattern 一致，未改。
- `message_system`：訂單復用 emit_message → order_buy/order_sell 進入既有傳播/失真/time-decay 管線。未驗證失真對訂單 params(res/qty) 的具體效果（distort 是否改 params）——若 distort 只改 description/strength 則 res 不失真；G1d 履約核對時需確認。
- coin 守恆：訂單**只發信號不轉移資源**（履約走既有 interaction trade），不碰 coin_eq；回歸 coin 守恆 assert 通過。

## 待主 session 確認

- **TEST VALUE 平衡**：ORDER_LIFETIME(5天)/POST_CADENCE(12h)/賣盤門檻(囤≥20、賣半)/_ORDER_ELIGIBLE_RES 全待平衡 pass。
- **買單（短缺驅動）未做**：plan 釘賣盤骨架，買單留 G1c/G1d（依 `_check_*_shortage`）。目前 `received_buy_orders` 的買單來源 = 其他隊發的 order_buy；本 plan 無隊主動發買單，需 G1d 補短缺→買單觸發才形成完整買賣環。
- **G1d 範圍**：商隊遠端套利/撲空（副本過期/失真 → 履約核對發起隊 active_orders）、跨格交付、買單完整化。
- **message distort 對 order params 的影響**：建議 G1d 履約前確認 distort 是否動 res/qty（撲空語意依賴此）。
