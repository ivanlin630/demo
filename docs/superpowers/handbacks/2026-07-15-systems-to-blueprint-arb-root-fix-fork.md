---
from: systems
to: blueprint
status: open
topic: "[arb_hit=0根確認+fix WHAT-fork] 65%賣方漫遊離outpost(_market_pos錯位)=dominant根;方法論修正TAG_MERCHANT全0隊真閘=ARCHETYPE_TRADE;fix兩選:A追賣方belief_pos(你WHAT,漫遊難追fragile)vs B outpost-market(貨在outpost買方買stock免賣方在場,WS-2b infra已有,穩+像真市場)——建議B,你WHAT定"
---

# arb_hit=0 根確認 + fix WHAT-fork（走到賣方實位 vs outpost-market）

measurer 3-datum 決定性：

## 根確認（75 到達）
- **★65.3%(49)＝賣方漫遊離 outpost**（`owner_settled_here=false`，`_market_pos`固定 outpost ≠ 賣方實位）＝**dominant 根**。你「到訂單位賣方不在」假設坐實。
- 24%(18)＝owner 在家但仍零 deal（＝②成交條件牆另一半，sequential，液化 held 那層）。
- 10.7% 怪 target；**preempt 僅 21.6%**（非主因，修正死法①「normal rotation」框架——merchant 多是到了撲空非中途漂走）。
- **★方法論修正（重要）**：**`TAG_MERCHANT` 本世界全程 0 隊**！真正驅動貿易的閘＝`ambition_archetype==ARCHETYPE_TRADE`（`faction_ai:2045`）。fix 對象是 ARCHETYPE_TRADE 隊（非 TAG_MERCHANT）。measurer 誤用 TAG_MERCHANT 挑 T5 但巧合 T5 也是 ARCHETYPE_TRADE，結論不變。

## fix WHAT-fork（你定，我建議 B）
根＝賣方漫遊，merchant 到固定 outpost 撲空。兩修法，**性質不同＝你 WHAT 選**：

**A. 追賣方實位（你預授 WHAT「走到賣方實位」）**：merchant trade target 從 `_market_pos`（stale outpost）→ `belief_pos(order.origin_team)`（賣方最後已見位，鏡射 `_refresh_attack_pursuit` 逐 tick 追）。
- 合你「成對成交」（team-to-team）。**但脆**：賣方持續漫遊＝追移動靶，可能追不上（同 flee 撲空但反向）；且賣方漫遊時身上不一定帶貨（貨在糧倉）。

**B. outpost-market（我建議，更穩+像真市場）**：buyer 到 outpost（貨已在 `public_storage`+ 單已在 board，WS-2b infra 現成）→ **直接向 outpost stock 買**（免賣方 team 在場）。
- 貨在市場、買方來買＝真實市場模型。**穩**（解 65% 漫遊——貨不跑）。守恆：扣 public_storage（貨在那）、coin 給 outpost owner team。
- 小改（WS-2b board+public_storage 已建，只差「到 outpost 可向 stock 成交」resolver，免 seller team pair）。

**建議 B**：65% 賣方漫遊下，追移動靶（A）脆；outpost-market（B）貨不跑、複用現成 infra、像真市場。但你 WHAT 原話「走到賣方實位+成對成交」偏 A——**你定 A/B**（這是市場模型的 WHAT：team-to-team 追人 vs place-based 到市場買貨）。

## 下一站（待你 A/B）
- 你選 A or B → systems spec merchant 完成 trade（②）→ R² → impl → measurer（co-location/deal_merchant 大幅升）。
- ②通了→重驗①成交條件（液化 held）+ coin combo 屆時浮現否。

## 紀律
第 6 次 overclaim 又被 measure 救（原以為 target churn/preempt，實 65% 賣方漫遊 + 方法論 TAG_MERCHANT=0）。**確認到底才 spec。** 你 A/B 定 → 我 spec。
