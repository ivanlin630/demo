---
from: systems
to: implementer
status: open
topic: "[REDIRECT+DISPATCH] probe-fix funnel部分moot(measurer證order_fulfilled雙路共用counter已計新路,7→0真低樣本非gap);真下層=coin combo:fold coin-B成員稅進feat/unified-commerce(no_coin 72.75%坐實binding)+tune強(單獨3.6%太弱);測combo revive"
---

# Redirect + Dispatch：coin combo 進 branch（no_coin 坐實 binding）

> **[worker 守則] 卡住/疑義 → handback `to:systems`,禁 `AskUserQuestion` 中斷用戶（用戶明言再犯上 hook 強制擋）。**

## Redirect：probe-fix funnel 部分 moot
measurer 核：`order_fulfilled` **雙路共用同一 counter**（舊 settle_orders:290 + 新 `interaction:834 _settle_owner_order`）——**新路已計 order_fulfilled**，我 premise 錯（以為沒 bump）。7→0 是**真低樣本**（2 筆 partial fill + 巧遇路本輪 meet=0 運氣）非 probe gap 非 regression。∴ **funnel probe 修取消**（已統一）。
- **若你已加 `trade.market_bail.<reason>` bail 因 probe → 保留**（headline 化 bail 因,省 measurer replica-scan,有價值）；funnel-probe 部分不用做。

## ★真下層：coin combo（no_coin 72.75% 坐實 binding）
measurer bail 拆（49161 掃描）：**visitor_no_coin 72.75%（排空板後）碾壓主因**——market-as-place 通了、買方到市場但**沒 coin**。∴ **coin 從「磨」升「先有」**（blueprint 預言中）。fold coin 進 branch 測 combo（market-as-place + liquidize + coin 一起）。

## 做什麼
1. **fold coin-B 成員稅進 `feat/unified-commerce`**：`_collect_member_tax`（spec `2026-07-15-coin-circulation.md`，已 R² CLEAN）——person.coin→team.coin 週期稅、領袖人格 rate、留 PERSONAL_COIN_FLOOR、守恆。
2. **★tune 強（單獨 3.6% 太弱）**：coin-B 單刀時 team_pool 才 3.6%（floor/rate 太保守）。**now load-bearing**（買方要有錢買）→ **調 MEMBER_TAX rate 高 / PERSONAL_COIN_FLOOR 低**（TEST VALUE，讓 team.resources.coin 回補夠買 market ask ~3.4+）。measurer census：person.coin 61-63% 是最大池（named 稅對準對池，只是要抽夠）。
3. **守恆**：CoinAudit=0 不破（person→team 池間搬）。

## 守則
- **守恆 CoinAudit=0**、determinism 零 randf、on/off byte-identical。
- **tune 空間**：rate/floor TEST VALUE，measurer 校到「買方有錢 + 不泵乾」（雙向流動非單向）。

## TDD
- coin-B 稅（person→team 守恆+floor）沿用 coin-circulation TDD。
- combo：市場 outpost 有 sell stock + 買方經稅有 coin → deal fire（整合測，非只單測）。

## 完成後
→ handback `to:systems` → measurer 中性 full-HD（★combo revive？deal 大幅升 + no_coin 大降 + coin 雙向不泵乾 + 守恆）→ 若 revive → to:blueprint 批 merge（統一模型 revive，先有結果達成）。
scope 疑義走 `to:systems`。若 combo 仍不 revive（更深）→ halt。
