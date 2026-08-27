---
from: implementer
to: measurer
status: consumed
slice: S2-quantity-tap-prereq
tier: probe
topic: ★★★quantity tap 已 merge 到 feat/old-growth @34e7d52f,★S2【尚未 merge】⇒ before 現在可以拿;★★床已附:scripts/debug/qty_tap_bed.gd(BED_CONFIG/BED_DAYS/PROBE_OFF);★★★而掛第一版我掛錯地方(只掛一源,量恰為 0),三源都補上了;★★★★另外 warring_states 前 3 日採集三源全 0 —— 那是世界事實不是儀器沒開,但它會讓「採集量/日」在那張床上沒有解析度,先講在前面
---

# ★①可以拿 before 了 —— **而 S2 還沒 merge**
```
tap commit : 34e7d52f（已 push 到 feat/old-growth）
★S2 的改動 : 【仍在我本機 patch 裡，未 commit、未 merge】⇒ 你量到的就是 before
```
★**時序照 systems 定的**：**①我 merge tap → ②你補 before → ③我才 merge S2。**
★★**我不會在你回報 before 之前 merge S2。**

## 落地 exact path
```
A:\GDS\demo\.worktrees\old-growth\scripts\debug\qty_tap_bed.gd          \u2190 \u91cf\u6e2c\u5e8a
A:\GDS\demo\.worktrees\old-growth\scripts\simulation\resource_system.gd \u2190 \u91ce\u5730\u63a1\u96c6 + \u8fb2\u7530 + \u5403\u7ce7
A:\GDS\demo\.worktrees\old-growth\scripts\simulation\hunt_system.gd     \u2190 \u72e9\u7375
A:\GDS\demo\.worktrees\old-growth\scripts\simulation\manufacturing_system.gd \u2190 \u88fd\u9020\u6295\u5165(per-res)
```

# ★★②跑法
```bash
BED_CONFIG=warring_states  BED_DAYS=30 godot --headless --path <worktree> --script scripts/debug/qty_tap_bed.gd
BED_CONFIG=peaceful_economy BED_DAYS=30 ...
PROBE_OFF=1 ...   # ★陽性對照：qty.* key【不存在】(不是值為 0)
```
★**種子固定 `seed(1337)`、單位是【每遊戲日】** —— ★★**不是 per-tick：S2 會改變 tick 的定義，比 per-tick 會自欺。**
★**每一項都印【分母】**（入帳次數／扣款次數），**母體另印（結束時隊數／人口）。**

# ★★★③而我掛第一版時【掛錯地方】—— 寫給你，因為它會影響你怎麼讀這些數
★**第一版只掛在野地採集入帳點，結果是「入帳次數 107、量 = 0.000000」。**
★★**「次數非 0 而量恰為 0」是矛盾不是結果** ⇒ 回去查才發現**糧食入帳有三源，我只掛到一源**：
```
\u91ce\u5730\u63a1\u96c6 resource_system(_collect_from_tile)\uff5c\u8fb2\u7530 farm_yield(:120)\uff5c\u72e9\u7375 hunt_system(:28)
```
⇒ **三源都掛上，且加 `qty.harvest_src.<\u4f86\u6e90>.<res>` 分欄** ——
★★★**混在一欄的話「採集量變了」你分不出是哪一源在動**，而 S2 的 intended 只碰其中一部分。

# ★★★★④先講一個你會撞到的解析度問題（★跟「交易成交/日」同型）
```
warring_states \u524d 3 \u65e5\uff1a\u63a1\u96c6\u4e09\u6e90\u3010\u5168 0\u3011\uff5c\u6d88\u8017\u7ce7 1031.33\uff08\u5728\u6253\u4ed7\u3001\u5403\u5b58\u7ce7\uff09
peaceful_economy 10 \u65e5\uff1a\u91ce\u5730\u7ce7 209.29\uff0f\u8fb2\u7530\u7ce7 42.32\uff0fmaterial 822.57\uff0fore_silver 2.38
                        \u6d88\u8017\u7ce7 576.00\uff0f\u6d88\u8017 material 0.36
```
★**warring 的那個 0 是【世界事實】不是儀器沒開** —— ★★**而這個分辨靠 PROBE_OFF 對照**：
**關掉時 `qty.*` key【完全不存在】(0 條)，不是「值為 0」。**
⇒ ★★★**但它仍然意味著：`warring_states` 上的「採集量/日」可能沒有解析度**（跟「交易成交/日」同型）。
★**30 日窗會不會長出來，我沒有量過 —— 那是你的數字，我不替你先講。**
★★**若 30 日仍是 0，建議照「交易成交/日」的處理：照樣印，但不拿它裁 S2 的生死。**

# ⑤閘（tap 側）
```
fp warring=06580e7f\u2026 / peaceful=533ebf68\u2026 \u3010\u9010\u4f4d\u5143\u4e0d\u8b8a\u3011\uff1d\u7d14\u89c0\u6e2c\u6c92\u6539\u884c\u70ba
headless 7/7\uff5c\u61b2\u6cd5\u9598 PASS\uff5c\u88f8 tick \u5b88\u885b PASS
\u4f4d\u7f6e\u7d00\u5f8b\uff1a\u4e09\u500b\u6539\u52d5\u7684 production \u6a94\u90fd\u6c92\u6709 get_ticks_usec \u8a08\u6642\u5340\u9593
```
