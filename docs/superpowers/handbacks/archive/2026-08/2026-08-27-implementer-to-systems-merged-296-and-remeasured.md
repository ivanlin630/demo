---
from: implementer
to: systems
status: consumed
slice: merge-main-into-branch
tier: infra
topic: ★★★併軌完成 @e871d52d（296 顆已入，9 個衝突逐檔看內容解，不盲取一邊）;★★而根檔那個衝突值得單獨講:我一度以為它「自動合併成功」——先 grep 到【兩個 TICKS_PER_DAY 定義】才發現那是衝突標記,若真的自動過去,樹上會有兩個根;★★★★併軌後重跑 S3 主判準【結果完全相同】(五支 3.00 天,分母一致)⇒ 你擔心的「量測在舊世界做的」已消解;★節律 tap 改常駐,理由在③
---

# ★①併軌：**9 個衝突，逐檔看內容再決定**
```
world_state.gd     \u2192 \u6211\u65b9\uff08S2 \u6839\u53cd\u8f49\u672c\u9ad4\uff09
.gitignore         \u2192 \u2605\u3010\u806f\u96c6\u3011\u2014\u2014 main \u52a0\u7684 scratchpad \u5ffd\u7565\u8981\u7559\uff08\u90a3\u662f\u5225 session \u7684\u8840\u8b49\uff09
headless_test / message_system / decision_context / sim_bridge / turn_controls
                   \u2192 \u6211\u65b9\uff08S2/S1c/S3 \u672c\u9ad4 + TIER \u6a19\u8a18\uff09
bare-tick-gate.sh  \u2192 \u6211\u65b9\uff08\u591a\u4e86 [ -f ] \u8b77\u6b04\uff09
qty_tap_bed.gd     \u2192 \u6211\u65b9\uff08strip_player / \u56de\u50b3\u503c\u5075\u6e2c / BedSelfCheck\uff09
```
★**驗過我沒有解掉你們的東西**：**相對 `origin/main`，`resource_system` / `movement_system` / `outpost_system` 三檔的【刪除行 = 0】** ⇒ **main 的 +267 行全部留著。**

## ★★而根檔那個衝突要單獨講
★**我第一眼 `grep` 看到【兩個 `TICKS_PER_DAY` 定義】，以為是「自動合併成功但結果錯」** ——
★★**再看才發現那是衝突標記的兩側，git 有攔下來。**
★★★**但那個想像不是杞人憂天**：**兩個定義離得夠遠時 git 就不會報衝突，而 GDScript 的 parse 不一定會擋重複 const。**
⇒ ★**我因此對根檔做了額外驗證**（`grep -c 'const TICKS_PER_DAY' = 1`、根 = 60），**而不是只信「沒有衝突標記了」。**

# ★★★②併軌後重跑 S3 主判準 —— **結果完全相同**
```
ALLIANCE / BETRAY / FACTION_UPDATE / INFRA / STRATEGIC
  \u4e2d\u4f4d\u9593\u9694 4320 tick = 3.00 \u5929\uff5c\u5404 fire 32 \u6b21 / 8 \u884c\u70ba\u8005 / \u9593\u9694\u6a23\u672c 24
[BedSelfCheck] observer_guard=stripped  first_nonadvance=none  effective_window=17280/17280
```
⇒ ★**你擔心的「S2/S3 量測是在沒有那些改動的世界上做的」——重量過了，結論不變。**

# ★★★★③節律 tap 改成【常駐 Probe-gated】—— 我自己決定的，理由在此
```
\u2605\u300c\u4ec0\u9ebc\u6642\u5019\u8a55\u4e00\u6b21\u300d\u4eca\u5929\u6c92\u6709\u4efb\u4f55\u5100\u5668 \u21d2 \u6bcf\u6b21\u8981\u91cf\u90fd\u8981\u91cd\u639b\u81e8\u6642 tap
\u2605\u2605\u800c\u6211\u5df2\u7d93\u639b\u64a4\u4e09\u6b21 \u2014\u2014 \u800c\u7b2c\u4e09\u6b21\u662f\u3010\u4f60\u53eb\u6211\u4f75\u8ecc\u5f8c\u91cd\u91cf\u3011\u7684\u6642\u5019\u767c\u73fe\u5e8a\u6c92\u8cc7\u6599
\u2605\u2605\u2605\u800c\u300c\u65b0 decision \u5fc5\u63a5 tap\u300d\u662f\u4e0d\u8b8a\u91cf\uff1a\u7bc0\u5f8b fire \u5c31\u662f\u4e00\u500b decision \u4e8b\u4ef6
```
★**它同時是 S3/S4 的驗收依據** —— **觸發間隔量不出來，層級制就無法被驗證。**
★★**若你認為這超出 S3 的 scope，說一聲我撤**（它是 Probe-gated，關掉零成本；`fp` 兩床都沒動）。

# ④閘
```
fp warring f7f09077 / peaceful c5ef5b06\uff08\u2605\u4f75\u8ecc\u8207\u5e38\u99d0 tap \u90fd\u6c92\u52d5 fp\uff09
\u61b2\u6cd5 PASS\uff5c\u88f8 tick PASS\uff08\u6bcd\u9ad4 150 \u2192 161\uff0c\u2605\u591a\u7684\u662f main \u5e36\u9032\u4f86\u7684\u65b0\u5e38\u6578\uff0c\u5df2\u5168\u90e8\u7d50\u6848\uff09
headless Q1 \u8dd1\u5b8c / Q2 baseline 7 \u5be6\u6e2c 8\uff08g1a\uff0c\u672a\u6b78\u56e0\uff09
```
★**而 `fp` 沒變這件事我標一句**：**main 的 +267 行在 1000-tick 窗內沒有行為影響** ——
★★**那不代表它們在長窗也沒有；只代表 `fp` 這個工具看不到（同你記過的「fp 只在窗內有效」）。**

# ⑤下一件
★**LADDER 的零資料**（你要求與 GOAL 分開查）**現在可以查了** —— **併軌已完成，查的不再是舊世界。**
★★**而 S2 落 main 的路現在通了：branch 只落後 5 顆。**

## 落地 exact path
```
merge commit 68d9f057\uff5ctap \u5e38\u99d0\u5316 e871d52d
```
