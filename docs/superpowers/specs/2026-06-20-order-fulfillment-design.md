# #1 經濟閉環 — Plan 1：訂單履約 HOW design

> 來源：藍圖 ruling `2026-06-20-blueprint-to-systems-feud-scenarios-ruling`（§3 #1：履約 0% + 腐壞/儲限）。
> #1 大根拆增量 plan：**本 = 履約**（訂單結算）；腐壞/儲限 = 後續 plan-2；mint 待 #1 重量。
> WHAT（經濟要閉環、履約要真發生）藍圖給；結算 seam / 度量 = 系統 HOW + TEST VALUE。

## 病（履約 = 0%）

訂單流現況**斷在最後一步**：
1. `OrderSystem.post_order` 發單（buy 短缺/sell 餘量）→ 存發起隊 `active_orders` + emit message 副本（殘缺/可失真情報）。✅
2. 商隊 `_merchant_trade_target` 讀 `best_arbitrage_order`（received buy/sell）→ 挑 local_value 差最大單 → TASK_TRADE 去 `ord["pos"]`。✅（`g1.arb_attempt` bump）
3. 到場 → `interaction._resolve_market`（`_attempt_trade_direction` ×2 + `_attempt_barter`）做**純供需估值交易**——**完全不認 order**：`qty_remaining` 永不減、order 只 `tick_team_orders` 到 `expire_tick` 過期清。**沒有任何 order 被標履約**。

→ `Probe` 的 `g1.order_fulfilled` / `g1.arb_hit` 已在 ProbeSummary 履約率/命中率 公式內，但**無人 bump** → 履約率恆 0%。貨其實有搬（估值交易），但訂單系統與實際交易脫節 = 帳對不上、無履約訊號、G1b/c/d 半空轉。

## HOW 決定：結算 = 觀察交易後 res 淨變，歸帳到 active_orders（純記帳，不改交易機制）

**不新建 order-directed 交易路徑**（估值交易已會搬貨 + 守恆安全 + 供需不align 自然撲空=emergent，藍圖要的）。改為**讓 order 認得已發生的交易**：`_resolve_market` 交易後，按各隊該 res 的淨持有變化，沖銷其 `active_orders`。

### 結算點 + 度量窗
`_resolve_market`（interaction:557）內，`_absorb_public_storage`（:558-559）與 `_spill_back_public_storage`（:566）之間，team.resources = **完整持有**（私有 + 吸入的公庫）。在此窗測淨變最乾淨：

```
:559 兩隊 absorb 完 → 快照 a_before/b_before（各 active_order 的 res 持有量）
:561-563 交易 + barter（既有，不動）
[新] 沖銷：對 a、b 各自 active_orders 按 res 淨變沖 qty_remaining
:566 spill back（既有）
```

### 沖銷規則（`OrderSystem.settle_orders(team, before_snapshot, tick)`）
對 team 每筆 `active_orders` o：
- `delta = team.resources[o.res] - before[o.res]`（窗內淨變）。
- **buy 單**（隊想進貨）：`filled = clampi(int(round(delta)), 0, o.qty_remaining)`（持有**增**才算履約）。
- **sell 單**（隊想出貨）：`filled = clampi(int(round(-delta)), 0, o.qty_remaining)`（持有**減**才算）。
- `o.qty_remaining -= filled`；`filled > 0` → 該隊本次 market `progressed = true`。
- `qty_remaining <= 0` → 移除該 order + `Probe.bump("g1.order_fulfilled")`。
- 同隊同 res 多單 → FIFO（`active_orders` append 序）逐筆扣同一 delta（一個 res 的 delta 池依序分配）。

> 一個 res 的 delta 只能沖該 res 的單（不跨 res）。多筆同 res 同向單共享該 res delta 池，FIFO 配。

### 命中率（arb_hit）
market 雙方任一隊有 order `progressed`（qty 有減）且**對方掛 `TAG_MERCHANT`** → `Probe.bump("g1.arb_hit")`（每次 market 至多 1，配對 `g1.arb_attempt`）。= 「商隊套利 dispatch 真的成交了訂單」命中。

## 邊界 / 守恆
- **不碰 resources / coin 數值**（交易機制原樣 `_attempt_trade_direction`/`_attempt_barter`/`_execute_transfer`）→ coin_eq、物資守恆**完全無關**。本 plan 只動 `active_orders` 記帳 + 2 個 probe bump。
- order 權威仍在發起隊 `active_orders`（單一所有者，無雙寫）。商隊不持單複本（received = message 唯讀情報）→ 沖銷只動發起隊自己的單，無 race。
- 撲空（到場供需已變、delta=0）= 不沖銷 = order 留到 expire/下次 → emergent，符 ruling。
- 部分履約 = `qty_remaining` 部分扣，留單 → 自然多次成交累積。
- barter（無 coin）也算履約（buy 單可由 barter 進貨滿足）→ 度量用 res 淨變，barter/coin 兩路徑都涵蓋。
- 賣盤過剩 sell 單可能被「賣給非下單對象」的 delta 誤沖？→ delta 是與**當前 market 對手**交易窗內的淨變，窗內只有這對交易在動該隊 res，歸因正確。

## 驗收
- 單測：發 buy 單→商隊帶貨同格 market→qty_remaining 減、填滿→order 移除 + `g1.order_fulfilled` bump。sell 單對稱。撲空（無互補供需）→ qty_remaining 不變、無 bump。
- 部分履約單測：delta < qty_remaining → 部分扣、留單。
- headless 全綠、coin_eq=0、InvariantAudit 0（純記帳，守恆不動）。
- （重量）world_sim 有戰／有貿易 run：ProbeSummary `訂單履約率` 0%→非零（受 world_sim 非確定性限，僅證機制通；真平衡 TEST VALUE 待確定場景）。

## 後續（本 plan OUT）
- **腐壞 / 儲限**（#1 plan-2）：食物囤 4-5 萬無壓力 → 腐壞率 + 儲存上限軟懲罰。獨立排。
- **mint**：待 #1 重量看是否自湧現。
- 履約率 TEST VALUE 平衡（單價/reserve/range）待確定性貿易場景。
