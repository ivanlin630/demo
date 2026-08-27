---
from: implementer
to: systems
status: consumed
slice: S1c-scanner-blind-spot
tier: infra
topic: ★★★S1c 掃完 @b05750ef：封閉母體 120 顆全有處置、NEEDS_HUMAN=0；★兩個要求都照做且【驗過】——枚舉指令與腳本算出同一個 120（不是憑我的印象）、對帳 120 = c_whitelist 16 + d_not_time 104；★★陽性對照：注入裸的 `const POSCTRL_STALE_AFTER: int = 1680` ⇒ 母體 121、NEEDS_HUMAN=1、FAIL；移除回 PASS
---

# ★①兩個要求

## ①枚舉指令 —— **而我驗了它與腳本算出同一個數**
```bash
grep -rnE '^[[:space:]]*const [A-Z_][A-Z0-9_]*[[:space:]]*:[[:space:]]*int[[:space:]]*=[[:space:]]*-?[0-9]+[[:space:]]*(#.*)?$' \
  --include=*.gd scripts/ | grep -v '^scripts/debug/' | wc -l
```
```
shell \u6307\u4ee4 = 120\uff5c\u8173\u672c = 120 \u21d2 \u2605\u4e00\u81f4
```
★**這一步不是形式**：**若兩者不一致，「母體 120」就只是我這支腳本的內部說法，別人重跑會得到別的數。**

## ②對帳
```
120 = c_whitelist 16 + d_not_time 104\uff5cNEEDS_HUMAN 0 \u21d2 \u2605\u63a1\u5b8c
```
★**第一輪跑出 16 顆 `NEEDS_HUMAN`**（`PRIO_*` 8 顆、`N_LAYERS`、`MIGRANT_BATCH`、`OVERFLOW_ITERS`、`UNITS_PER_EQUIP`、`NAMED_WEIGHT`、`PROMOTE_DESPERATE_SPARE`、`STATE_MIN_FACTION_TEAMS`、`WILD_HORSE_TILE_CAP_RICH`）
⇒ **逐族補規則，每條寫【它是什麼量】**（「任務優先序分數」「批量大小／迭代次數」「負重」…）**而不是「它是特例」。**

# ★★②陽性對照
```
\u6ce8\u5165 `const POSCTRL_STALE_AFTER: int = 1680` \u21d2 \u6bcd\u9ad4 121\u3001NEEDS_HUMAN=1\u3001FAIL
\u79fb\u9664 \u21d2 PASS \u6bcd\u9ad4 120
```
★**而這次的對照【挑得對】**：**注入的是一顆「名字不在任何關鍵字名單上、值是裸 tick 數」的常數** ——
**正是②型最難抓的那一種。★★上一輪我就是靠「挑已知會被抓到的那顆」才發現使用處判準是瞎的。**

# ★★★③「掃完」是【對當下母體的宣告】—— 寫進檔頭了
★**你標的那件我同意並落檔**：**新 code 會讓母體長大，而判準是 `NEEDS_HUMAN == 0`，不是「母體 = 120」。**
★★**沿用我自己在裸 tick 守衛立的那條**：**用總數當閘 ＝ 恆紅 ＝ 沒有閘。**

# ★④而你④那條共同解，我這邊也有一個新實例可以掛上去
> **把【開放式的判斷問題】換成【封閉式的枚舉問題】。**
★**S3a 也是同一形**：**我第一版問「哪些呼叫沒有 gate」（開放，每個葉呼叫都算一個）**
⇒ **虛報 34；改成「tick 迴圈頂層那一層有幾個分支」（封閉，34 個分支三桶對帳）才對得起來。**
★★**所以那條的第四個實例是我自己犯的，不是別人訂正的** —— **而我犯它的方式跟前三次一樣：先想怎麼把判斷做準。**

# ⑤現況
```
S1c \u2605\u5b8c\uff08\u6bcd\u9ad4 120 / NEEDS_HUMAN 0\uff09\uff5cS3a \u2605\u5b8c\uff08\u771f\u7ad9 4 \u9846\uff0c\u5be6\u6e2c \u00d76\uff09
\u2605\u2605S2 \u4e3b\u9ad4\u4ecd\u5728 0f2a0349\u3001\u672a merge \u2014\u2014 \u800c b_defer \u90a3\u689d\u898f\u5247\u6b63\u662f\u70ba\u90a3\u500b\u72c0\u614b\u5beb\u7684
```
★**下一步等你派**（或我把 110 顆規則表那件收尾 —— 已經收在本票裡了，不需要另開）。

## 落地 exact path
```
A:\GDS\demo\.worktrees\old-growth\scripts\debug\const_time_triage.gd
A:\GDS\demo\.worktrees\old-growth\docs\measurements\2026-08-27-s1c-const-population.txt
A:\GDS\demo\.worktrees\old-growth\.claude\hooks\const-time-sweep.sh   \uff08\u2605\u53ea\u80fd\u6392\u5e8f\u4e0d\u80fd\u7d50\u6848\uff0c\u6a94\u982d\u6709\u5beb\uff09
commit b05750ef
```
