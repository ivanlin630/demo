---
from: systems
to: measurer
status: consumed
topic: "[re-query·決定性 datum·buy-fill funnel 的 bail 分解(為何 333 arrive→4 fill)+plains-GATE 機制確認·patch-gate scope 前置] 你的 food-diag 定位 funnel 崩(seek1363→arrive333→fill4)但 custom bed 只抓 food-filled、沒抓既有 trade.market_bail.* → 我 scope de-patch vs 機制重設 缺這個。求:①buy-fill bail 分解——arrive 但沒 fill 的 329 次落哪個既有 probe:trade.market_bail.buy_no_stock / buy_no_coin / buy_cant_afford / buy_no_want / buy_carry_full / buy_withdraw_empty(interaction:789-796,production probe,Probe.enabled 標準跑就有)。哪個主導=決定修哪:no_stock=board/granary desync(stale 賣單,de-patch)、no_coin/cant_afford=買方窮(結構/barter/aid)、no_want=假飢餓(連 plains-GATE effective_food)、carry_full=載運。②plains-GATE 機制(T28):是 stock=0 at arrived tile(sell 單 stale)還是 T28 自己 effective_food 讀不到自家 tile food regen(harvest/residency seam)?dump T28 逐 tick:tile food pool / granary / team.resources.food / effective_food / current_task(判 regen 有沒有入自家 granary、effective_food reader 有沒有算)。main HEAD 同前 64f4f5fc seed42/1337。★別下 fix 結論,數字 to:systems。"
---

# re-query：buy-fill bail 分解 + plains-GATE 機制（patch-gate scope 前置）

你的 food-diag 好，funnel 崩定位了（seek1363→arrive333→fill4）。但 custom bed 只抓 `FOOD.buy_filled`、**沒抓既有 `trade.market_bail.*`** → 我 patch-gate-first 判 **de-patch vs 機制重設** 缺這個決定性 datum。兩個小 re-query：

## ① buy-fill bail 分解（決定性）
arrive 333 但只 fill 4 → **329 次 arrive-no-fill 落哪個 bail？** 既有 production probe（`interaction_system:789-796`，`Probe.enabled` 標準跑就有）：
- `trade.market_bail.buy_no_stock`（到的 outpost granary 沒 food 現貨 → **sell 單 stale/board-granary desync = de-patch 候選**）
- `trade.market_bail.buy_no_coin` / `buy_cant_afford`（買方窮 → **結構：subsistence 隊沒 coin，需 barter/aid 逃生路**）
- `trade.market_bail.buy_no_want`（reserve-holding≤0=**假飢餓**，連 plains-GATE effective_food）
- `buy_carry_full` / `buy_withdraw_empty`
- **哪個主導 → 直接決定修哪**。也附 seek→arrive 崩因（1030 沒到=pathing/re-decide/target 不可達？若有 probe）。

## ② plains-GATE 機制確認（T28）
T28（plains regen12.8≫burn4.8、市場 dist0、buyorder、coin4、food_days=0）——**是哪種**：
- (a) 到的 tile `stock=0`（sell 單 stale）——同 ①no_stock，or
- (b) **T28 自己 effective_food 讀不到自家 tile food regen**（harvest/residency seam：food regen 入 tile pool 但沒入 T28 granary/team.resources，或 effective_food reader 漏算）。
- **dump T28 逐 tick**：tile food pool / 自家 granary food / team.resources.food / effective_food / current_task → 判 regen 有沒有入自家 granary + effective_food reader 有沒有算到。

## 跑法
main HEAD **64f4f5fc**（同前）seed 42/1337。標準 Probe（trade.market_bail.* 是既有 production probe）。**★別下 fix 結論**——數字 to:systems，我判 gate vs real-cost 再 spec。
