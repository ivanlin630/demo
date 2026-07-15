---
from: systems
to: measurer
status: consumed
topic: "[量測·漏斗定位] seam修正確但非binding(deals仍~0);需完整trade漏斗breakdown定binding層:arb_sell_seen/arb_pick/meet_nodeal/board_read——別再賭,數字定哪站斷"
---

# 量測：trade 漏斗完整 breakdown（定 binding 層）

> **[worker 守則] 卡住/量不到 → handback `to:systems`,禁 `AskUserQuestion` 中斷用戶（用戶明言再犯上 hook 強制擋）。**

你 HALT 對——seam 修正確（kill_nostock 月1-3 降=賣單看見糧倉貨）但**非 binding**（deals 仍~0）。systems 查 code：deal 路徑不只「賣單看見貨」，還要**買方/merchant 到 producer outpost co-locate 交易**。binding 層在下游，**別再賭，要漏斗數字定哪站斷**。

## 請跑（同分支 `feat/supply-seam-effective-holding` @ 4c2f85cb，force_full_hd，同你上輪）
補全 trade 漏斗**全站 Probe counter**（多在既有，一次 dump 全部，6月合計 + 月切面）：
| 站 | probe key | 意義 |
|---|---|---|
| 1 貼單 | `trade.post_sell` / `trade.post_buy` | 賣/買單各貼幾張（★賣單 seam 修後真變多嗎） |
| 3 arb 呼叫 | `trade.arb_call` | merchant 找套利次數 |
| 3 賣單可見 | `trade.arb_sell_seen` | merchant 看到幾個別隊賣單（★供給可見性） |
| 3 買單可見 | `trade.arb_buy_seen` | |
| 3 距離殺 | `trade.arb_kill_range` | 超 MERCHANT_MAX_RANGE（★太遠撮不到=geography 斷） |
| 3 無貨殺 | `trade.arb_kill_nostock` | merchant carried stock=0 |
| 3 選中 | `trade.arb_pick` | arb 選到非空單（★找到可追的單嗎） |
| 5/6 會合 | `trade.arb_hit` / `trade.meet_nodeal` | 到點會合成交 vs 會合零成交（★co-locate 了但不成？） |
| 6 成交 | `trade.deal` / `trade.deal_merchant` / `trade.deal_resident` / `trade.barter_deal` | 真成交 |
| board | `board_read`（若有 probe）/ market_arrive | 買方到 producer 市集讀單率（★known_issue board_read≈0） |

## 定位邏輯（哪站掉到零＝binding 層）
- **post_sell 修後仍~0** → 供給根本沒貼出（產能/累積問題，非 seam）。
- **post_sell 升 but arb_sell_seen~0** → 賣單貼了但 merchant 看不到（board/傳播斷）。
- **arb_sell_seen 升 but arb_pick~0 / arb_kill_range 高** → 看到了但太遠/valuation 不划算（geography/價格斷）。
- **arb_pick 升 but meet_nodeal 高 / arb_hit~0** → 追了但到不了點 or 到了不成（travel/co-location 斷）。
- **arb_hit 升 but deal~0** → 會合了但 transfer 失敗（成交邏輯斷）。

**這一站定 binding 層**，不必再猜。

## 判定
漏斗 breakdown → handback `to:systems`（哪站掉零 + 前後對比）→ systems patch-gate-first 挖那站真根 → spec binding 層。**seam 分支先 hold**（正確但 inert，等 binding 層一起定 merge 策略）。

## 溯源
raw + measured_at_head `4c2f85cb`。log/jsonl UTF-8。
