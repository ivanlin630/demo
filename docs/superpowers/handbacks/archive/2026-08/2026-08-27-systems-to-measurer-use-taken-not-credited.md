---
from: systems
to: measurer
status: consumed
slice: S2-statistical-equivalence-after
tier: measure
topic: ★★★★讀你的 before dump 抓到一件會決定 after 怎麼判的:採集 food taken=1723 vs credited=595(三分之二沒入帳,糧倉 cap 溢出);★★而 S2 的 intended「糧耗/格 −17%」⇒消耗變少⇒糧倉更容易滿⇒溢出更多⇒credited 更低 ⇒【用 credited 當不變項會把「採集變少」誤判出來】;★裁定=不變項用 taken,credited 照印當附註
---

# ★★★★①我從你的 dump 讀到的
```
qty.harvest_taken.food     = 1723.11        ★採到
qty.harvest_credited.food  =  595.33        ★★入帳
⇒ ★★★credited / taken ＝ 34.5%  —— 三分之二的採集【沒有入帳】
（material：55.6 / 55.6 ＝ 100%，★只有 food 有這個 gap ⇒ 糧倉 cap 溢出）
```

# ★★②而它跟 S2 的 intended 直接互動 —— **這是我要攔的那件**
```
★S2 intended：糧耗/格 −17% ⇒ ★★消耗變少 ⇒ 糧倉更容易滿 ⇒ ★★★溢出【更多】⇒ credited【更低】
⇒ ★★★★若「採集量/日」用 credited，after 會看起來【採集變少】——而採集根本沒變少
```
★**這跟移動那件是【同一個形狀】**：★★**一個會被 S2 系統性推動的量測偏誤，掩蓋掉真正的不變項。**
★★★**差別是移動那件我們修了 tap；這件不用修，因為你已經【兩個數都記了】——只要選對用哪個。**

# ★★★③裁定
```
★不變項用 qty.harvest_taken.*   —— ★★它是「世界產出了多少」，不受下游倉容影響
★credited 照原樣印，當【附註】—— ★★★而 credited/taken 的【比值】本身值得單獨看：
   它是「倉容有多吃緊」的指標，而 S2 會動它 ⇒ 那是 intended 的【副作用】，不是不變項
```
★**請在 after 的 dump 裡把這三個都印**：`taken`／`credited`／★**比值**。
★★**而比值的變化【不列入 <5% 裁決】**（它是預期會動的），**但要照印** —— **因為它是「糧倉開始爆」的早期訊號。**

# ★④順帶：你 dump 裡有兩件我要記下來
1. ★★**`★key 不存在，而 Probe 是 ON 【這件事從未發生】（tap 在，只是沒 fire）`**
   ⇒ ★★★**你把「key 不存在」正確地區分成【沒發生】而不是【沒接上】，並且把證據（Probe ON、tap 在）寫在同一行。**
   ★**那正是我們一路在防的形狀，而你把它做成輸出的一部分，不是靠讀者記得。**
2. ★**移動：tap 98.17/日 vs 床側 84.07/日 ⇒ 床側低估 14%**，★★**而你標「差額極可能是 spawn/合併造成的位置跡象（tap 為準）」**
   ⇒ ★★★**那正是 implementer 預測的「床分不出 spawn 跡象」——被量出來了，而且他標了「極可能」不是「就是」。**

# ★⑤時序
★**S2 已 GO（你發的信）** —— ★★**after 那輪照這封的選擇跑：`taken` 當判準、`credited`＋比值當附註。**
