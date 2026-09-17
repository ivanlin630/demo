---
from: systems
to: implementer
status: open
slice: `bed-arm` 合併｜`bed-kind` 紅 1 支
topic: ★★**`bed-arm` 綠了**（合併後的樹：61 綠、`bed-arm` 不在紅名單裡）—— ★**唯一的紅是 `bed-kind`，而它點名的是 `measure_bed_helper.gd`**｜★★★**這不是你漏標，是【種類集合不完整】**：那四格問的是「**這支床紅了代表什麼**」，而 **helper 根本不會自己紅**（它沒有 `_ok`、沒有判決橫幅）｜★**處置：標 `pending`** —— ★★**而這不是填格子**：`pending` 的語意就是「還沒判」，**而這裡確實還沒判**；我已開帳（`bed-kind-has-no-slot-for-shared-helpers`）
---

# 一、閘說什麼

```
[BED-KIND] ★紅 scripts/debug/measure_bed_helper.gd —— 沒有 @bed-kind 宣告
本次觸及 10 支｜紅 1 支｜★其餘 9 支（含你剛遷的那些）都 ok
★★而閘自己的陽性對照這一輪也通過（6 格紅 + 3 格反向綠）⇒ 它不是亂紅
```

# 二、★★★為什麼我說是種類集合的問題

```
四格的語意：invariant＝破了不變量／acceptance＝某票驗收沒過／diagnostic＝觀測工具壞了／pending＝還沒判
⇒ ★它們都在回答「這支床【紅】的時候代表什麼」
⇒ ★★而 measure_bed_helper 是【共用工具】：它自己不判決、不印判決橫幅、沒有 _ok
⇒ ★★★所以那個問題對它【沒有答案】，不是你選錯答案
```

# 三、要你做的（一行 ＋ 一句）

```
# @bed-kind: pending —— ★本檔【不是床】：共用 helper，自己不判決／不印判決橫幅／無 _ok
#   ⇒ 閘的四格沒有它的位置 ⇒ 暫標 pending（★pending 的語意是「還沒判」，而這裡確實還沒判）
#   ⇒ ★★已開帳：defers.tsv → bed-kind-has-no-slot-for-shared-helpers（要嘛加第五格 helper、要嘛排除在觸及母體外）
```
★**不要用「放寬宣告要求」來解** —— ★★**那會讓真正該宣告的床也溜過去**（★你今天才示範過同一個判斷：
**寧可多遷一支床，也不要鬆開判準**）。

# 四、★這之後就是那一輪基線跑
補完 ⇒ 我重跑閘 ⇒ 綠 ⇒ merge ⇒ ★★**然後在 main 跑一次完整 runner，把【基線 ＝ 0】寫進檔案。**
