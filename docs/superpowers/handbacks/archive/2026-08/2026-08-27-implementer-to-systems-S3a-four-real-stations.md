---
from: implementer
to: systems
status: consumed
slice: S3a-tick-station-inventory
tier: infra
topic: ★★★真每 tick 站 = 4 顆(實測新根 60.00/小時、舊根 10.00/小時,恰好 ×6);★★而我第一版虛報成 34——把每個葉呼叫都算一個分支,幾乎全是 encounter 的工具函式;你那句「虛報一個站就可能把整條路走錯」正是我送出去前抓到它的原因;★★★★靜態 11 顆裡實測只有 4 顆是真的,另外 7 顆的否掉理由逐個記(5 顆 _pht 是 opt-in 儀器實測 0 次、2 顆 encounter 本窗從未呼叫)
---

# ★①三桶對帳（★可宣告，不是「我找到 N 個」）
```
gated 18 ＋ true_candidate 11 ＋ untraceable 3 ＋ leaf_util 2 ＝ \u2605\u5206\u652f\u7e3d\u6578 34
```
★**我加了第四桶 `leaf_util`**（頂層呼叫的是索引外/內建函式）——**理由同你當初收 (d)：硬塞進三桶會污染判準。**

# ★★②而第一版【虛報成 34 顆 true_candidate】—— 我送出去前自己抓到
```
\u7b2c\u4e00\u7248\uff1a\u628a\u3010\u6bcf\u4e00\u500b\u8449\u7bc0\u9ede\u547c\u53eb\u3011\u90fd\u7b97\u4e00\u500b\u5206\u652f
\u21d2 34 \u7b46 true_candidate \u5e7e\u4e4e\u5168\u662f encounter_system \u7684\u5de5\u5177\u547c\u53eb\uff08.new()\u3001AnonCohort.total\u3001tier_count\u2026\uff09
```
★**而那些根本不是「站」，encounter 還跑在 `encounter_tick` 另一條軸上。**
★★**你那句「★★★★虛報一個站就可能把整條路走錯」是我回頭改單位的直接原因** ——
**改成：只有【tick 迴圈頂層直接呼叫的那層】算一個站，更深的遞迴只回答「這個站內部有沒有 gate」。**

# ★★★③實測複驗 —— **靜態說 11，實測只有 4 顆是真的**
```
\u2605\u771f\u6bcf tick \u7ad9 4 \u9846\uff08\u65b0\u6839 60.00/\u5c0f\u6642\uff5c\u820a\u6839 10.00/\u5c0f\u6642 \u21d2 \u6070\u597d \u00d76\uff09
   _step_captives
   _step_cleanup_extinct_teams
   DayNightSystem.get_speed_mult
   DayNightSystem.get_vision_mult
\u2605\u2605\u5426\u6389 5 \u9846\uff1a_pht\uff08phase_timing \u9810\u8a2d off \u21d2 \u5be6\u6e2c 0 \u6b21\uff09\u2014\u2014 \u5b83\u662f\u5100\u5668\u4e0d\u662f\u7ad9
\u2605\u2605\u2605\u5426\u6389 2 \u9846\uff1aadvance_encounter_tick / resolve_encounter_end\u2014\u2014\u672c\u7a97\u5167\u5f9e\u672a\u88ab\u547c\u53eb
```
★**逐個否掉的理由都在清單裡**（照你要的「靜態說是、實測否掉的逐個記」）。

## ★★★★⇒ 給 blueprint 條件式裁定的那個數字
```
\u771f\u6bcf tick \u7ad9\u8986\u84cb\u7387\uff1a4 / 34 \u5206\u652f \u2248 12%\uff08\u800c\u5176\u4e2d 2 \u9846\u662f\u7d14\u8b80\u53d6\u7684 accessor\uff09
\u2605\u2605\u800c\u90a3 4 \u9846\u78ba\u5be6\u96a8\u6839 \u00d76 \u2014\u2014 \u4e0d\u662f\u300c\u53ef\u80fd\u3011\uff0c\u662f\u5169\u6839\u5be6\u6e2c 10.00 vs 60.00
```
★**判「高/低」是你與 blueprint 的事，我只給數字與它的分母。**
★★**而我要標一句**：**4 顆裡 `get_speed_mult`／`get_vision_mult` 是【純讀取的 accessor】**（讀時段算乘數，不改世界）
—— ★**若「站」的定義是「做世界工作的」，真站其實是 2 顆。★★這個定義差異會直接改變覆蓋率，交你裁。**

# ★④untraceable 3 顆留在輸出裡
```
_ph.clear / _ph.get\uff08sim_runner\uff09\uff5c_faction_ai_system.cleanup_extinct_teams
```
★**理由照你寫的**：**它們的真實深度是【未知】，不是【確認沒 gate】。**

# ★⑤陽性對照（票要求）
```
\u66ab\u6642\u62ff\u6389 _step1d_overflow \u7684 gate \u21d2 \u5b83\u5f9e gated \u79fb\u5230 true_candidate\uff0818\u219217\uff0f11\u219212\uff09
\u9084\u539f \u21d2 \u56de gated\u3002\u2605\u7cbe\u6e96\u547d\u4e2d\u3002
```
★**程序保險照你講的**：**臨時 tap 全撤（`grep TEMP-S3A` = 0）、`git status` 乾淨、fp 兩床逐位元不變。**

# ⑥閘
```
fp 4f1c0eda / c5ef5b06\uff08\u4e0d\u8b8a\uff1d\u96f6 production \u6539\u52d5\uff09\uff5c\u61b2\u6cd5\u9598 PASS\uff5c\u88f8 tick PASS\uff08156\uff09
headless Q1 \u8dd1\u5b8c\uff5cQ2 baseline 7 / \u5be6\u6e2c 8\uff08g1a\uff0c\u672a\u6b78\u56e0\uff09
```

## 落地 exact path
```
A:\GDS\demo\.worktrees\old-growth\scripts\debug\s3a_tick_station_inventory.gd
A:\GDS\demo\.worktrees\old-growth\docs\measurements\2026-08-27-s3a-tick-stations.txt
commit 38c41919
```
