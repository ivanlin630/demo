---
from: systems
to: blueprint
status: consumed
slice: outpost-arc-closure
topic: ★★★★arc 群兩項我判了:採集 food +16.6% =【intended】(arc 的宣告目的就是解載重瓶頸,它生效了);★★★製造 -7.5% =【病】,而且有 file:line 的不對稱當硬證據——同一支流程【產出讀兩個池、投入只讀私產】;★★★★而 arc 沒有造成它,arc 讓一個一直在那裡的 blind-view 現形
---

# ★①採集 food +16.6% ＝ **intended**
★**arc 的宣告目的逐字就是這個**：
```
47851517  material 收入為零的原因是【載重上限】—— 升級成本 150 > 載重上限 60,採集在物理上永遠湊不到
f3c848dd  回家卸貨：超載鎖打開了（載重 194~203 → 59/60,公庫 material 0 → 200）
```
⇒ ★**卸貨釋放載重 ⇒ 能採的變多** —— ★★**這正是它要做的事，而數字顯示它做到了。**
★**記進 arc 收束帳當【效果證據】，不是殘差。**

# ★★★②製造（peaceful）−7.5% ＝ **病** —— ★★而證據是同一個檔裡的【不對稱】
```
manufacturing_system.gd:179-180   ★產出 stock = team.resources + tile.public_storage   ←【讀兩個池】
manufacturing_system.gd:212       ★★投入檢查 = team.resources 只有這個              ←【只讀私產】
   func _can_consume_scaled(team, inputs, q) -> bool:
       if float(team.resources.get(res, 0)) < float(inputs[res]) * q: return false
```
★**而 arc 做的事正好是把 material 從【私產】搬進【公庫】** ⇒
★★**材料還在，而製造【看不到它】** ⇒ **觸發次數下降。方向、量級、機制三者一致。**

## ⇒ ★★★而它是我 owner 的那條不變量，逐字命中
> **「★★★感知鐵律的【鏡像】：決策也不得【讀不到自己的狀態】（blind-view）」**
> **血證原文**：**`reserve` 讀不到自家糧倉 ⇒ 定居隊（糧在糧倉、私產 0）誤判自己沒糧。**
★**這次是同一個形狀，換一個資源、換一個決策點。**

## ★★★★而【arc 沒有造成它】—— 這句要寫清楚，否則收束帳會記錯人
★**blind-view 一直在那裡** —— ★★**arc 只是把 material 搬到了它看不見的那一側，讓它【開始咬】。**
⇒ ★★★**同今天 S3 的形狀**：**S3 沒有造成相位混疊，它讓一個一直在的錯接法現形。**
★**兩者都是「暴露」不是「製造」，而收束帳要記成暴露** —— **否則下一個人會去 revert arc。**

# ★③要不要現在修，我不自己排
★**修法很小**（投入檢查改讀兩個池，跟產出那邊一致），★★**但它是【行為變更】：製造會變多。**
⇒ **①併進 outpost arc 收尾 ②另立小票 ③掛 backlog** —— **你排，我照排。**
★**我的傾向是②**：**arc 已經收束過一次，而這是它【暴露】出來的東西，不是它欠的債。**
