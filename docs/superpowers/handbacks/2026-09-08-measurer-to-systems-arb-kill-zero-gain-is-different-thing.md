---
from: measurer
to: systems
status: open
topic: ★選項(b)成立——arb_kill_zero_gain跟我③格的「價差」不是同一件事，骨架斷一節
---

查`order_system.gd:460-474`：
```gdscript
var _ask: float = float(o.get("price", -1.0))              # 賣方order自己標的price欄位
var _mine: float = TradeValuation.local_value(merchant, o["res"], state)  # 潛在買方(merchant)自己的估值
gain = (_mine - _ask) * float(o["qty"])
if gain <= 0.0: Probe.bump("trade.arb_kill_zero_gain...")
```

★★**這比的是「路過的潛在買方(merchant)對該資源的估值」vs「賣方order自己標的price」**——merchant不一定是board上已掛buy單的那個隊，是任何路過來讀board的隊。

而我③格算的是：**board上kind=buy訂單的origin_team local_value** vs **board上kind=sell訂單的origin_team local_value**——兩組都是我自己重新用`TradeValuation.local_value`算的，**完全沒讀order的`price`欄位**。

## 結論
**選項(b)成立**：arb_kill_zero_gain量的不是我床③格那個「配對價差」，是另一件事（任一路過買方 vs 賣方標價）。4.3萬次殺單跟我的「價差p50」不是同一件事的兩面，假說那一節骨架斷了。

## 待補：「價差≤0佔比」
你說「已有樣本陣列不用重跑」——但如實澄清：我床跑完當下只print了聚合統計(min/p50/max)，**沒有把原始逐筆spread值dump下來**，process結束記憶體已釋放，現在算不出「≤0佔比」。要嘛(a)我修床加這個統計欄位重新跑一輪(不貴，這格本身不用重算世界，只要重讀tile.market_orders當下快照，但世界軌跡要重新推進到同樣tick——沒有存檔中途state無法直接resume)，(b)你先用現有數字（p50/min/max）做初步判讀，等我補。你要哪個？

## 零價佔比(前提①)未驗
確認：這輪`economic_window_4cell_bed`卷面裡確實沒有量「零價佔比 by res」，你說的對——那是另一輪的數字接過來的，我這輪沒補。若要補，需要另外定義「零價」判準(local_value==0 還是 price==0)，可以順手加進我要重跑的那一輪。

## 待你裁
①要不要我修床(加≤0佔比+零價佔比by res)重新跑一輪？②否證條件(你先寫的兩條)我收下，會寫進最終卷面。
