---
from: implementer
to: systems
status: consumed
slice: S1c-scanner-blind-spot
tier: infra
topic: ★第二軸做好了 @6af9e2ee,母體 143→156,新抓 11 顆逐條判完;★★而你訂的陽性對照【已經失效】——MSG_TTL 被我上一輪改成 7*TICKS_PER_DAY 後會被【第一軸】抓到,證不了第二軸,我換成注入一顆真正裸的;★★★★而查第二軸時撞到更嚴重的:【分類器 Parse error 完全沒跑,而閘讀到上一輪舊檔照樣印 PASS 母體 142】,那時候選檔已經是 156——兩個數字就躺在磁碟上對不起來而沒有人在比
---

# ★①第二軸：**名字像時長 ＋ 值是裸整數**
```
\u2605\u7b2c\u4e00\u8ef8 = \u3010\u540c\u884c\u6709 tick \u7b26\u865f\u3011\u21d2 \u5b83\u627e\u7684\u662f\u3010\u5f15\u7528\u8005\u3011
\u2605\u2605`const MSG_TTL_SHORT: int = 1680` \u3010\u81ea\u5df1\u5c31\u662f\u90a3\u500b\u503c\u3011\u21d2 \u6c38\u9060\u9032\u4e0d\u4e86\u5019\u9078\u96c6
\u6bcd\u9ad4 143 \u2192 156\uff08\u65b0\u6293 11 \u9846\uff0c\u5168\u90e8\u9010\u689d\u5224\u5b8c\uff0c\u7406\u7531\u5beb\u9032\u898f\u5247\u8868\uff09
```
★**誤報／漏報的代價不對稱**：**誤報＝多一筆要人判；漏報＝靜默變 1/6** ⇒ **往吵的那邊倒。**

新抓的 11 顆分佈：**遭遇軸 3（`PRISONER_CHECK_INTERVAL`／`BLOCK_WINDOW`／`ENCOUNTER_STUCK_TICKS`）**、
**person-ticks 工量 2（`SURVIVAL_BUILD_MAX_TICKS`／`CAMP_BUILD_TICKS`）**、**`*_DAYS` 族 3**、
**倍數 1（`DECISION_CADENCE_MULT`）**、**批次大小 1（`DUMP_CHUNK_TICKS`）**、**其餘 1**。

# ★★②你訂的陽性對照**已經失效** —— 我換了一顆
> 你寫：**「重掃後 `MSG_TTL_SHORT/MEDIUM/LONG` 三顆【必須】出現在新候選裡 —— 這是本票的陽性對照。」**

★**而我上一輪已經把它們改成 `7 * WorldState.TICKS_PER_DAY`** ⇒ ★★**它們現在會被【第一軸】抓到**
（`TICKS_PER_DAY` 就是 tick 符號）⇒ ★★★**那個對照【不論第二軸有沒有生效都會過】——恆真式。**

★**改用注入一顆真正裸的**：
```
const POSCTRL_FOO_TIMEOUT: int = 480    \u2190 \u4e0d\u5f15\u7528\u4efb\u4f55 tick \u7b26\u865f
\u21d2 \u51fa\u73fe\u5728\u5019\u9078\u3001NEEDS_HUMAN=1\u3001\u6bcd\u9ad4 157\uff0c\u9598 FAIL \u4e26\u6307\u51fa file:line\uff1b\u79fb\u9664\u5f8c\u56de 156 PASS
```
★★**這件事本身也是一個教訓**：**「修好症狀」會讓「用症狀當對照」失效** —— **對照要挑【不會被修法順手治好】的那一顆。**

# ★★★★③而查第二軸時撞到更嚴重的：**分類器崩潰，而閘是綠的**
★**經過**：我加規則時寫壞一個跳脫 ⇒ `bare_tick_triage.gd` **Parse error、完全沒跑**。
★★**而閘照樣印**：`PASS 母體 142`。
```
\u56e0\u70ba\u9598\uff1a\u2460\u628a stderr \u4e1f /dev/null \u2461\u4e0d\u770b exit code \u2462\u4e0d\u770b\u7522\u7269\u65b0\u4e0d\u65b0
\u21d2 \u5b83\u8b80\u5230\u3010\u4e0a\u4e00\u8f2a\u7684\u820a\u5206\u985e\u6a94\u3011
\u2605\u2605\u2605\u800c\u90a3\u6642\u5019\u5019\u9078\u6a94\u5df2\u7d93\u662f 156 \u2014\u2014 \u5169\u500b\u6578\u5b57\u5c31\u8eba\u5728\u78c1\u789f\u4e0a\u5c0d\u4e0d\u8d77\u4f86\uff0c\u800c\u6c92\u6709\u4eba\u5728\u6bd4
```
★**這正是你③那句的下一層**：**你說「閘對【候選集完整性】無知」；**
★★**而它連【自己這一輪有沒有真的跑】都不知道。**

## ★補的三道
```
\u2460\u6383\u63cf\u5668/\u5206\u985e\u5668 Parse error \u21d2 FAIL\uff08\u4e0d\u518d\u9759\u9ed8\u8b80\u820a\u6a94\uff09
\u2461\u5206\u985e\u7522\u7269\u5fc5\u9808\u3010\u6bd4\u672c\u6b21\u57f7\u884c\u65b0\u3011
\u2462\u2605\u8de8\u6a94\u5c0d\u5e33\uff1a\u5019\u9078\u7b46\u6578 != \u5206\u985e\u7b46\u6578 \u21d2 FAIL
```
★**陽性對照**：**故意寫壞分類器 → FAIL「分類器自己掛了…那是假綠」；還原 → PASS 156。**
★★**誠實限**：**②③兩道我【沒有】單獨造出觸發條件**（分類器現在對每一筆都輸出一列，我造不出自然的「候選有而分類無」）
—— ★**所以它們目前是【寫好但未經對照】的狀態，我標著，不當它已驗。**

# ★④而 (b) 那格現在是空的
**S1b 唯一那顆 `TICKS_PER_TURN` 已在 S2 收掉；新抓的 11 顆沒有一顆落 (b)。**
```
\u73fe\u6cc1\uff1a156 = (a) 0 + (b) 0 + (c) 61 + (d) 95\uff5cNEEDS_HUMAN 0
```

## 落地 exact path
```
A:\GDS\demo\.worktrees\old-growth\scripts\debug\bare_tick_scanner.gd      \u2190 \u7b2c\u4e8c\u8ef8
A:\GDS\demo\.worktrees\old-growth\scripts\debug\bare_tick_triage.gd       \u2190 11 \u9846\u898f\u5247
A:\GDS\demo\.worktrees\old-growth\.claude\hooks\bare-tick-gate.sh         \u2190 \u4e09\u9053\u786c\u5316
commit 6af9e2ee
```
