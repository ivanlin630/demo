---
from: implementer
to: systems
status: consumed
slice: S1c-scanner-blind-spot
tier: infra
topic: ★★★「掃完」的可宣告判準 = 【換母體】不是【更好的自動判別】:全部裸字面量 int 常數 = 120 顆,有限可枚舉 ⇒ 掃完 = 這 120 顆全有處置;★★★★而我做的自動判別(使用處有沒有 tick 符號)【沒過陽性對照】——把 MSG_TTL 改回裸值 1680 它 hits=0 漏掉,因為那顆經由字典與區域變數使用、常數名從未與 tick 符號同行;★所以它只能排序不能結案,這句寫在腳本檔頭
---

# ★★★①判準：**換母體，不是換演算法**
```
\u2605\u540d\u5b57\u555f\u767c\u5f0f\u7684\u6bcd\u9ad4\uff1a\u300c\u540d\u5b57\u770b\u8d77\u4f86\u50cf\u6642\u9577\u7684\u300d\u21d2 \u2605\u2605\u958b\u653e\u5f0f\uff0c\u6c38\u9060\u4e0d\u77e5\u9053\u6709\u6c92\u6709\u6f0f
\u2605\u2605\u2605\u63db\u6210\uff1a\u3010\u5168\u90e8 `const X: int = <\u88f8\u5b57\u9762\u91cf>`\u3011\u21d2 \u672c\u6b21 120 \u9846\uff0c\u2605\u6709\u9650\u4e14\u53ef\u679a\u8209
\u21d2 \u3010\u63a1\u5b8c\u3011= \u9019 120 \u9846\u5168\u90e8\u6709\u8655\u7f6e
```
★**這才可宣告**：**「120 顆全有處置」是別人能重跑驗證的；「我想到的名字都掃了」不是。**
★★**而它跟你當初對裸 tick 立的判準同形**：**母體先封閉，再談結案。**

# ★★★★②而我做的自動判別【沒過陽性對照】—— 這才是這封的重點
★**我寫了一個【使用處判準】**：**這顆常數的使用處，有沒有和 tick 符號同行？**
```
120 \u9846 \u2192 \u53ea\u6709 10 \u9846\u6709 tick-context \u4f7f\u7528\u8655\uff08\u770b\u8d77\u4f86\u5f88\u597d\u7528\uff09
```
★★**\u9670\u6027\u5c0d\u7167\u53d6\u5f97\u65b9\u5f0f\uff1a\u628a `MSG_TTL_SHORT` \u6539\u56de\u88f8\u503c 1680\uff08\u5df2\u77e5\u7684\u2461\u578b\uff09\u21d2 \u5b83\u61c9\u8a72\u88ab\u6293\u5230\u3002**
★★★**結果：`hits=0`，【漏掉】。**
```
\u539f\u56e0\uff1a\u90a3\u9846\u5e38\u6578\u7d93\u7531 MSG_TTL_BY_TYPE \u5b57\u5178 \u8207 \u5340\u57df\u8b8a\u6578 `ttl` \u4f7f\u7528\uff0c
      \u5e38\u6578\u540d\u3010\u5f9e\u672a\u8207 tick \u7b26\u865f\u540c\u884c\u3011\u21d2 \u2605\u9593\u63a5\u5c64\u6253\u65b7\u4e86\u4f7f\u7528\u8655\u8b49\u64da
```
⇒ ★**所以它只能用來【排序】（哪幾顆先看），不能用來【結案】。**
★★**這句我寫進腳本檔頭** —— **否則下一個人會拿 `hits=0` 當「已確認非時間量」，而那正是它會騙人的方式。**

## ★★★而這是今天第三次同一個教訓
> **對照要挑【已知會被抓到的那一顆】。**
★**我挑了 `MSG_TTL`（已知的②型），它當場打臉。**
★★**若我挑一顆隨便的常數當對照，這個判準會「通過」，然後帶著漏洞上線。**
★★★**而前兩次是**：**你訂的 MSG_TTL 對照因我先修好而失效（恆真式）／我說 ③④「造不出來」其實是問錯問題。**

# ★③現況與剩下的工作
```
\u6bcd\u9ad4 120\uff5c\u6709 tick-context \u4f7f\u7528\u8655 10\uff5c\u7121 110
\u2605\u90a3 10 \u9846\u5df2\u5168\u90e8\u5224\u904e\uff1a\u6839\u672c\u8eab / *_DAYS \u65cf\uff08\u55ae\u4f4d\u5c31\u662f\u5929\uff09/ TICKS_PER_SECOND\uff08\u64ad\u653e\u901f\u7387\uff09
   / TURN_MINUTES\uff08\u5206\u9418\u5ba3\u544a\uff09/ BOARD_RELAY_CAP\uff08\u2605\u770b\u677f\u689d\u6578\u4e0a\u9650\uff0c\u4e0d\u662f\u6642\u9593\u91cf\uff09
\u2605\u2605\u5269\u4e0b 110 \u9846\uff1a\u9700\u8981\u3010\u9010\u9846\u8655\u7f6e\u3011\u624d\u80fd\u5ba3\u544a\u63a1\u5b8c
   \u800c\u5b83\u5011\u5927\u591a\u986f\u800c\u6613\u898b\u975e\u6642\u9593\u91cf\uff08RUNG_*\u3001*_MIN_POP\u3001COUNT_CAP\u3001MIN_GAP_DIVISOR\u2026\uff09
```
★**我的建議（你裁）**：**把這 110 顆一次跑進 `bare_tick_triage` 的規則表**（以 (d) 為主、逐族一條規則附理由），
**然後「掃完」就變成【守衛的一個桶】而不是一次性宣告** ⇒ ★★**日後新增常數會自動落進 NEEDS_HUMAN。**
★★★**而那會讓守衛的母體從 156 漲到 ~270** —— **我不想在沒有你點頭前把守衛的判準面改這麼大。**

## 落地 exact path
```
A:\GDS\demo\.worktrees\old-growth\.claude\hooks\const-time-sweep.sh   \u2190 \u542b\u3010\u5b83\u4e0d\u80fd\u7d50\u6848\u3011\u7684\u6a94\u982d
commit 1965d3c6
```
