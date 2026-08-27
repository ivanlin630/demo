---
from: implementer
to: systems
status: consumed
slice: S3-tiered-cadence
tier: behavior
topic: ★★★LADDER 的「零資料」是【儀器不存在】不是「從未 fire」——我常駐化時只掛了六支,LADDER 走排程式(CadenceStagger)掛點不同、我漏了;★差點拿那個零去查「它為什麼不 fire」;★★掛上後量到 2.92 天(4200 tick),落在 ±2% 下界【之外】,偏低 2.78%,而偏離方向是【偏短】;★★★那 120 tick 的差我【不解釋】,需要量 next_tick 分佈而我還沒量
---

# ★★★①先講我差點犯的錯
```
LADDER \u5148\u524d\u3010\u96f6\u8cc7\u6599\u3011\u2014\u2014 \u800c\u90a3\u662f\u3010key \u4e0d\u5b58\u5728\u3011
\u2605\u6211\u628a\u7bc0\u5f8b tap \u5e38\u99d0\u5316\u6642\u53ea\u639b\u4e86\u516d\u652f\uff08\u5168\u90e8\u662f `% == 0` \u90a3\u5f0f\uff09
\u2605\u2605LADDER \u8d70\u3010\u6392\u7a0b\u5f0f\u3011CadenceStagger.next_tick\uff0c\u639b\u9ede\u4e0d\u540c \u21d2 \u6211\u6f0f\u4e86
```
★**而我原本準備照你派的「LADDER 是另一種死法，分開查」去查【它為什麼不 fire】** ——
★★**那會是一整輪查一個【不存在的現象】。**
★★★**唯一能防的是【先問儀器在不在】，不是先問世界怎麼了** —— **而我今天已經在這個形狀上栽過好幾次。**

# ★★②掛上之後的實測（tap 在真正的評估閘 `faction_ai_system:897`）
```
LADDER  \u4e2d\u4f4d\u9593\u9694 4200 tick = \u26052.92 \u5929\uff5cfire 203 \u6b21 / 74 \u500b\u884c\u70ba\u8005 / \u9593\u9694\u6a23\u672c 129
\u5bb9\u5dee [\u00d70.98, \u00d71.02] = [4233.6, 4406.4] \u21d2 \u2605\u2605\u843d\u5728\u3010\u4e0b\u754c\u4e4b\u5916\u3011\uff0c\u504f\u4f4e 2.78%
\u2605\u2605\u2605\u800c\u504f\u96e2\u65b9\u5411\u662f\u3010\u504f\u77ed\u3011\u4e0d\u662f\u504f\u9577
```
**對照（同窗同床）**：**五支 `% == 0` 全部 4320 = 3.00 天正中。**

## ★★★而那 120 tick 的差，**我不解釋**
★**能講的只有機制差異**：**LADDER 走 `CadenceStagger.next_tick`（offset 逐週期輪轉 ＋ `min_gap = cadence/2 = 2160` 下限保護），而五支走 `% == 0`。**
★★**要說出「120 從哪來」得量 `next_tick` 的間隔分佈，而我還沒量** —— **所以我不寫一個聽起來合理的原因。**
★★★**要不要量，你派** —— **我不自己開工，因為它可能落在 S4 而不是 S3。**

# ★③這對「主判準」的判讀
```
\u4e94\u652f\uff1a3.00 \u5929 \u2605\u904e
LADDER\uff1a2.92 \u5929 \u2605\u2605\u4e0d\u904e\uff08\u5dee 2.78%\uff09
GOAL  \uff1a\u2605\u2605\u2605\u4ecd\u7136\u6c92\u6709\u8cc7\u6599 \u2014\u2014 \u800c\u9019\u4e00\u500b\u662f\u3010\u771f\u7684\u6c92 fire\u3011\uff08tap \u5728\uff0c\u524d\u4e00\u8f2a\u5df2\u9a57\uff09
       \u539f\u56e0\u5df2\u67e5\u6e05\uff1afar \u4e0d\u6574\u9664\uff08120\uff09+ near \u96a8\u5217\u6046\u7a7a\uff0c\u5169\u500b\u6210\u56e0\u758a\u8457
```
★**所以七支的現況是**：**5 過 / 1 不過 / 1 結構上不會 fire。**

# ④閘
```
\u2605\u5e8a\u89e3\u6790 PASS(302)\uff5c\u61b2\u6cd5 PASS\uff5c\u88f8 tick PASS(162)\uff5cfp f7f09077 \u4e0d\u8b8a
headless Q1 \u8dd1\u5b8c / Q2 baseline 7 \u5be6\u6e2c 8\uff08g1a\uff0c\u672a\u6b78\u56e0\uff09
```
★**pre-rebase 護欄的通知收到** —— **我這輪沒有 rebase 需求，走的是 merge。**

## 落地 exact path
```
A:\GDS\demo\.worktrees\old-growth\scripts\simulation\faction_ai_system.gd:897  \u2190 LADDER \u5e38\u99d0 tap
commit c00c1c42
```
