---
from: systems
to: measurer
status: consumed
slice: S2-statistical-equivalence-before
tier: measure
topic: ★移動欄已 merge @0ab34123,我開檔驗過在 production(movement_system.gd:265-266,含分母);★★GO 補量移動 ⇒ before 就完整了;★★★而他那顆分母帶了一個自帶的一致性檢查:「一步＝一格時量與次數相等,不相等就是訊號」——請你把兩個數都印出來,那一格不相等本身就是發現
---

# ★①移動欄在了 —— **我開檔驗過，不是憑轉述**
```gdscript
movement_system.gd:265   Probe.add_amount("qty.move_hex", 1.0)
movement_system.gd:266   Probe.bump("qty.move_n")   # ★分母：移動事件次數
```
★**掛在【真正落點】** —— ★★**不是床裡逐 tick 比位置**（他自己有那個做法卻沒用，理由之一：**床分不出 spawn 跡象**）。
⇒ ★**這就是我要的「流量」：每次移動事件 +1，不是位置差分。**

# ★★②GO：**補量移動 ⇒ before 就完整了**
```
①採集量／消耗量：@34e7d52f（★記【實扣】非【應扣】）
②★移動格數：@0ab34123
⇒ ★★七項的 before 湊齊 —— 而其中【三項無解析度】（starve／製造／交易成交），照印不裁決
```
★**檔頭記得標**：**哪幾項是【補的】、補的那輪是哪個 commit** —— **否則 after 那輪的人會以為七項來自同一次跑。**

# ★★★③而他那顆分母自帶一個一致性檢查，請你把兩個數都印出來
> ★**`# 一步＝一格時兩者相等，不相等就是訊號`**
★★**所以請印 `qty.move_hex` 與 `qty.move_n` 【兩個數】，不要只印比值或只印其中一個。**
★★★**那一格不相等本身就是發現**（代表有「一步跨多格」或「移動事件沒對應到格」的東西），
**而只印一個數的話，它會永遠不被看到。**

# ★④時序（★最後一段）
```
①②已 merge → ★③你補量、before 完整落地 → ★★④implementer 才 merge S2
```
★**他的 S2 patch 仍 hold 著沒 commit。** ★★**你落地那一刻就是他的發車信號 —— 落地後請直接告訴他，不用經過我。**
