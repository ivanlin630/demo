---
from: implementer
to: systems
status: consumed
slice: S3-tiered-cadence
tier: behavior
topic: ★★★★S3 搬遷落地 @e7308bd1+75ef9e06,但【主判準量不出來】——五支 faction 級在 12 日與 30 日窗都只 fire 一次(tick 4320),per-actor 間隔樣本 = 0;★★而 0 我當場分了是哪一種:不是「沒掛上」(4320 有 fire)是【掛了但之後不再命中】;★★★外層 _evaluate_all_body 12 日跑 144 次而【只有 1 次落在 % 4320 == 0】,且它最後一筆是 tick 8160(窗 17280);★★★★★可逆閥跟「單一 T3 常數」有真衝突,我改了形狀,理由在①
---

# ★★★★★①可逆閥：**它跟「單一 T3 常數」有真衝突，我改了形狀**
★**你寫**：**「把七支還原成 10h/20h/30h/50h」要能靠改一個地方做到。**
★★**而「單一個 `T3_STRATEGIC`」做不到** —— **回滾要回的是【七支各自的舊值】，一顆常數回不了異質值。**
⇒ ★**做法**：**七支各給具名別名，全部放在 `decision_tier.gd`，舊值寫在同一行註解**：
```gdscript
const C_GOAL_CHECK: int      = T3_STRATEGIC   # \u820a\u503c 10 * TICKS_PER_HOUR
const C_ALLIANCE_CHECK: int  = T3_STRATEGIC   # \u820a\u503c 30 * TICKS_PER_HOUR
\u2026
```
★★**回滾仍是【改一個檔】，而且回滾的人不必翻 git 歷史。**
★★★**若你要的是別的形狀，這是最容易改回來的一個決定，說一聲。**

# ★★②補遺③的結構檢查 —— **它抓到我自己造的違規**
★**我把 INTENT 的 tap 插進了意圖排程碼**，**而補遺明文要求那一段【逐字元不變】。**
⇒ **已移除，意圖改用出口分類的 `reached_intent_gate` 計數。**
★★**`git diff` 驗過**：**意圖排程碼零新增行、零刪除行。**
★★★**而它證明了那條檢查的價值**：**行為指標永遠答不了「排程碼有沒有被動到」，只有 diff 答得了。**

## 出口分類對帳（補遺②）平
```
entry 1152 = reached_intent_gate 48 + \u5176\u9918 1104\uff08leader_null / player_override / survival_override \u5168 0\uff09
```

# ★★★③而主判準【量不出來】—— 這是本票最重要的東西
```
\u4e94\u652f faction \u7d1a\uff1a12 \u65e5\u7a97\u8207 30 \u65e5\u7a97\u90fd\u3010\u53ea fire \u4e00\u6b21\u3011\uff08tick 4320\uff09\uff5cper-actor \u9593\u9694\u6a23\u672c = 0
LADDER\uff1a42 \u500b\u884c\u70ba\u8005\u5404 fire \u4e00\u6b21\uff0c\u540c\u6a23\u7b97\u4e0d\u51fa\u9593\u9694
```
★**照你要求「0 是訊號，要當場分【沒掛上】vs【掛了沒到期】」** —— ★★**兩者都不是**：
**tick 4320 確實 fire 了（掛上了），而 8640/12960 沒有（不是沒到期，是沒命中）。**

## ★★★★而查外層拿到了機制
```
_evaluate_all_body 12 \u65e5\u7a97\u8dd1 144 \u6b21\uff0c\u2605\u5176\u4e2d\u3010\u53ea\u6709 1 \u6b21\u3011\u843d\u5728 % 4320 == 0 \u4e0a
\u2605\u2605\u800c\u5b83\u7684\u6700\u5f8c\u4e00\u7b46\u662f tick 8160\uff08\u7a97\u6709 17280\uff09\u21d2 \u5b83\u5728\u4e2d\u9014\u5c31\u4e0d\u518d\u88ab\u547c\u53eb
\u5916\u5c64\u9593\u9694\uff1a\u4e2d\u4f4d 60 tick\uff5c\u6700\u5c0f 0\uff5c\u6700\u5927 360
```
★**我的推論（★標成推論）**：**`% X == 0` 這個 gate 形狀，在【外層評估本身是錯峰/不規則】時，
X 越大命中機率越低** —— **舊值 600 tick 在窗內有 28 次機會，新值 4320 只有 4 次。**
★★**而「外層在 tick 8160 之後不再被呼叫」這一件我【不下結論】** ——
**它看起來更像世界狀態（faction 消失？pass 條件不成立？）而不是本次改動，交你判。**

## ⇒ ★★★所以我【沒有】宣稱 S3 達成 3 天節律
**我宣稱的是**：**七支已改讀層級來源、可逆閥可用、結構檢查通過** ——
★**而「它們是不是真的每 3 天評一次」目前【證據不足】，且證據指向 gate 形狀與外層節律的交互。**

# ★④headless：我 commit 完才發現多一題，已修並補理由
★**S3 撞到我自己在錯峰票立的凍結**：`assert(LADDER_EVAL_CADENCE == 10h, "錯峰票不得靠改 cadence 長度達成")`。
★★**它凍的其實是【錯峰票沒有偷改 cadence】，不是【這數字永遠 10h】** ——
**而 S3 是有 spec 授權的搬家。**
⇒ **改凍【它來自層級來源】**：`== DecisionTier.C_LADDER_EVAL`
★**別處寫死數字仍會紅；而「改 T3 該多長」不會紅 —— 那正是可逆閥要的形狀。**
```
headless \u56de\u5230 8\uff08\u591a\u7684\u4ecd\u662f g1a\uff0c\u672a\u6b78\u56e0\uff09
```

# ★⑤fp：**照 spec ⑤先聲明我走的是哪一種**
```
warring  4f1c0eda \u2192 f7f09077  \u2605\u8b8a\u4e86\uff08\u7b26\u5408\u9810\u671f\uff1a\u6709 fire\uff09
peaceful c5ef5b06 \u3010\u6c92\u8b8a\u3011
```
★**peaceful 那一格我分兩半講**：
**①五支 faction 級在那張床【結構上不可能 fire】** —— `config/peaceful_economy.json` 的 `faction_id` 全是 `-1`，沒有 faction。
**②而 GOAL/LADDER 在那張床有 fire，卻沒動到 fp** —— ★★**這一格我沒有解釋，標為【未解】，不當它是「乾淨」。**

# ⑥逐 site 標記
```
46 \u9846\uff1aunmigrated(b) 25 / n/a 21
```
★**而第一版把 `world_state` 的曆法基底誤標成「待 S5+ 的節律」** ——
**`TICKS_PER_MONTH` 不是「多久評一次」，它是單位定義。已修成 `n/a — 曆法基底`。**

## 落地 exact path
```
A:\GDS\demo\.worktrees\old-growth\scripts\simulation\decision_tier.gd      \u2190 \u5c64\u7d1a\u4f86\u6e90 + \u53ef\u9006\u95a5
A:\GDS\demo\.worktrees\old-growth\scripts\debug\s3_tier_interval_bed.gd    \u2190 \u9593\u9694\u5e8a\uff08\u542b\u5916\u5c64\u8a55\u4f30\u8a3a\u65b7\uff09
commit e7308bd1\uff08\u642c\u9077\uff09+ 75ef9e06\uff08\u51cd\u7d50\u76ee\u6a19\u66f4\u65b0\uff09
\u2605\u81e8\u6642 tap \u5df2\u5168\u64a4\uff08grep TEMP-S3 = 0\uff09
```
