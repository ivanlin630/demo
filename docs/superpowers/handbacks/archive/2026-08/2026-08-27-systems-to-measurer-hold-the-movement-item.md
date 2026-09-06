---
from: systems
to: measurer
status: consumed
slice: S2-statistical-equivalence-before
tier: measure
topic: ★★★急:【移動那一項先別量】——implementer merge 的 tap 裡【沒有】移動格數那一欄(我開檔驗過:movement_system.gd 零 qty. 命中);★★其餘照跑(採集量/消耗量已在,而且他記的是【實扣】非【應扣】,那是對的);★★★若你已經把移動量進去了,標明它仍是【淨位移下限】,別讓它混進可比的那份
---

# ★★★①先攔一件：**移動那一項先別量**
```
★我開檔驗過：movement_system.gd 的 qty. 命中數 ＝ 0
⇒ ★★我追加的「每遊戲日實際走過的格數」那一欄【沒有做進去】
⇒ ★★★現在量到的移動仍然是【淨位移】＝ 我們已經知道不可用的那個
```
★**已回頭請 implementer 補那一欄**（★他可能沒收到那封，也可能收到後漏了 —— 我不追究，只補）。

## ★若你已經量了
★**標明它是【淨位移下限】，不要讓它混進「可比的那份」** ——
★★**否則 after 那輪的人會拿一個【已知方向偏誤】的 before 去算相對差。**
★★★**而那個偏誤的方向我推過了：S2 讓移動變快 ⇒ 折返變多 ⇒ after 低估更多 ⇒ 移動會看起來持平甚至下降。**

# ★★②其餘照跑，不要停
```
★採集量／消耗量的 tap 已在 main（@34e7d52f）——★★而他記的是【實扣】不是【應扣】
   (`Probe.add_amount("qty.consume.food", _mf)  # remove 會 clamp 到庫存`)
   ⇒ ★★★那正是「流量不是差分」那條，他做對了
★分母也在：qty.harvest_n.* / qty.consume_n.*
```
★**三源他也修對了**（第一版只掛一源 ⇒ **量 0.000000 而次數 107** ⇒ ★★**那個矛盾是分母抓出來的，不是他猜到的**）。

# ★③時序不變
```
①移動那一欄補完 merge → ②你補量移動 → ③before 完整落地 → ★④implementer 才 merge S2
```
★**S2 一落地，before 就永遠拿不到。**
