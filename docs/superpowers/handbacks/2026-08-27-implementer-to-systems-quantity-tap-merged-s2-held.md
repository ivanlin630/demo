---
from: implementer
to: systems
status: open
slice: S2-quantity-tap-prereq
tier: probe
topic: ★tap 已 merge @34e7d52f、S2 仍 held(patch 未 commit),已通知 measurer 可拿 before;★★掛第一版我掛錯地方——只掛一源,量恰為 0.000000 而次數 107(矛盾不是結果),真正入帳有三源;★★★而 S2 的工作我已做到主 gate 之前(根反轉/刪 mult/turn 保時長/COLLECT→T2/動作>=10 守衛雙向驗過),細節在③備查
---

# ①照你的時序：**tap merged、S2 held**
```
34e7d52f  quantity tap（已 push）
S2        ★仍在 patch 裡，未 commit ⇒ measurer 量到的就是 before
```
★**已寄信給 measurer**（含跑法、exact path、以及一個他會撞到的解析度問題）。
★★**我不會在他回報前 merge S2。**

# ★★②掛第一版我掛錯地方 —— **而抓到它的是「量 0／次數 107」這個矛盾**
★**第一版只掛在野地採集入帳點** ⇒ **`qty.harvest_taken.food = 0.000000`、而 `qty.harvest_n.food = 107`。**
★★**「次數非 0 而量恰好 0」不是結果，是矛盾** ⇒ 回去查，**糧食入帳有三源，我只掛到一源**：
`_collect_from_tile`（野地）／`farm_yield`（`resource_system.gd:120`）／`hunt`（`hunt_system.gd:28`）。
⇒ ★**三源都掛，且分 source 欄** —— **否則「採集量變了」分不出哪一源在動。**

★★★**而它跟今天那串同型**：**我以為我量的是 A，其實量的是 A 的一小塊**
—— **表徵一樣是【一個看起來正常的數字】。**

# ★★★③S2 的進度（★備查，未 commit）
```
\u2460\u6839\u53cd\u8f49\uff1aTICKS_PER_HOUR \u6210\u70ba\u552f\u4e00\u81ea\u7531\u53c3\u6578 = 60\uff1bTICKS_PER_DAY = \u5b83 \u00d7 24 = 1440
\u2461WORLD_SPEED_MULT \u5220\u9664\uff1bMOVE = BASE_ACTION \u00d7 MAP_SCALE = 240 tick = \u30104 \u5c0f\u6642\u3011
\u2462BASE_ACTION_TICKS \u6539\u5ba3\u544a\u6210 TICKS_PER_HOUR/6\uff1d10 tick\uff1d\u301010 \u5206\u9418\u3011\uff08\u503c\u4e0d\u8b8a\uff0c\u8a9e\u610f\u7d42\u65bc\u5c0d\u4e86\uff09
\u2463TICKS_PER_TURN \u4fdd\u4f4f 2.4 \u5c0f\u6642\uff1aTimeScale \u65b0\u589e TICK_PER_MINUTE + minutes()\uff0c144 \u5206 = 2.4h\uff08\u6574\u6578\u7121\u9918\uff09
   \u2605\u540c\u6642\u6536\u6389 S1b \u552f\u4e00\u90a3\u9846 (b)
\u2464COLLECT_INTERVAL 30h \u2192 T2 1 \u5929\uff1b\u4eba\u683c\u8abf\u8b8a 0.5~2.25 \u500d\u7387\u5f62\u72c0\u4e0d\u52d5
\u2465TICKS_PER_SECOND 4 \u2192 24\uff08\u00d76 \u540c\u6b65\uff0c\u5426\u5247 UI \u6162\u52d5\u4f5c 6 \u500d\uff09
\u2466\u52d5\u4f5c >= 10 tick \u5b88\u885b\uff1a\u5beb\u9032 time_const_check\uff0c\u2605\u96d9\u5411\u9a57\u904e
   \uff08\u6839\u66ab\u8a2d 30 \u21d2 \u52d5\u4f5c 5 tick \u21d2 FAIL\uff1b\u9084\u539f \u21d2 PASS\uff09
\u2467time_const_check \u91cd\u5beb\uff1a\u51cd\u3010\u5c0f\u6642\u3011\u4e0d\u51cd\u3010tick \u6578\u3011
   \u2605\u820a\u7248\u51cd `== 720`\uff0c\u800c 720 \u662f\u820a\u6839\u4e0b\u7684 tick \u6578 \u21d2 \u6bcf\u91cd\u9328\u4e00\u6b21\u5c31\u8981\u6539\u4e00\u6b21\u9019\u4efd\u6a94
   \u2605\u2605\u6539\u51cd\u5c0f\u6642\u5f8c\uff0c\u91cd\u9328\u3010\u4e00\u884c\u90fd\u4e0d\u7528\u6539\u3011\u800c\u5b83\u4ecd\u7136\u62b3\u5f97\u4f4f
```
★**還沒做的**：**統計等價床本身**（要等 measurer 的 before）＋ **specimen trace 送 QA**。

## ★④一個我查過、可以讓你少擔心一件事的東西
★**我原本擔心 `*_PER_TICK` 那一族會被根旋鈕靜默 ×6**（HP/blood/stamina 再生）。
★★**窮盡查過呼叫節奏**：`tick_natural_regen` 走 NEAR pass（`NEAR_CADENCE = TICKS_PER_HOUR` ⇒ **每日 24 次不變**），
`STAMINA_REGEN_PER_TICK` 走遭遇內部 `encounter_tick`（動作 = 10 tick 不變）
⇒ ★★★**這族實際上是 per-call 不是 per-tick，不受根旋鈕影響 —— 名字在說謊（§4 七病之一），但行為安全。**
★**所有 cadence 常數也都已由根導出**（S1 的功勞），**唯二裸值是遭遇內部的 `PRISONER_CHECK_INTERVAL`（走 encounter_tick，界外）。**
