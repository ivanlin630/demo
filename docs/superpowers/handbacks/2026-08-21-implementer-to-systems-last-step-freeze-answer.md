---
from: implementer
to: systems
cc: qa
status: open
slice: convoy-return-conservation
topic: 「相鄰卻不走最後一步」答案 — ★不是不走，是【一格要走 144 tick】；真缺陷＝ETA 與真實移動成本是兩套獨立模型，系統性低估 3×，讓 T3 預算恰好等於路程本身（零餘裕）
commit: 診斷在拋棄式 worktree（origin/main @5dafa82d），temp tap 不進任何 branch
---

# 最後一步凍結：答案

## 先殺掉兩個假設（有數據、不是推論）
| 假設 | 結果 |
|---|---|
| 居民鎖（`movement_system:72-74`，`TASK_CONVOY` 不在脫離清單） | ★**否**。`diag.mv_skip_resident.*` 全是 治理/貿易/建設/外交/覓食/製造/乞食/return_home，**零筆「運輸」** |
| 目標格無路/被佔 → stuck | ★**否**。`diag.mv_stuck.運輸` **零命中** |

## 現場實況：porter 一直在走，只是「一格 ＝ 144 tick」
`diag.mv_convoy_enter = 26`、`diag.mv_acc_short = 16`，樣本顯示 acc **穩定累加**且座標一路在變：
```
acc=100 cost=144 pos=[10,6] → acc=56 pos=[9,7] → acc=12 pos=[8,7] → acc=112 pos=[8,7]
→ acc=68 pos=[7,8] → acc=124 pos=[6,8] → acc=80 pos=[7,8] → acc=36 pos=[8,8]
```
⇒ QA 看到的「連續多個判斷週期一步不走」＝**正在走那一格**（判斷週期遠短於 144 tick）。

## ★★真缺陷：同一件事有兩套獨立模型，而且系統性低估 3×

| | 公式 | 吃哪些因素 |
|---|---|---|
| **T3 預算來源** `PathSystem.eta_ticks`（`path_system:158-160`） | `path_cost × BASE_MOVE_TICKS / (1−fatigue)` | **只有疲勞** |
| **真實走一格** `MovementSystem._move_cost`（`movement_system:170-193`） | `BASE / (隊速×地形×疲勞×超載×車輛)`，**clamp `[BASE/3, BASE×3]`** | 隊速組成、地形、**超載**、車輛 |

實測（純算術對照床，`BASE_MOVE_TICKS = 48`）：

| porter 情境 | cap | weight | **真實每格 cost** | **eta_ticks(1格)** | 低估 |
|---|---|---|---|---|---|
| 空手 pop=1 | 10.0 | 0.0 | 69 | 48 | 1.44× |
| 帶 30 material | 10.0 | 30.0 | **144（MAX 飽和）** | 48 | **3.00×** |
| 帶 64 material + 17 food | 10.0 | 65.7 | **144** | 48 | **3.00×** |
| 帶 200 material | 10.0 | 200.0 | **144** | 48 | **3.00×** |

★**porter 永遠超載**：`BASE_CARRY = 10/人`，pop=1 卻背 30–200 ⇒ **每一趟 convoy 都吃 MAX clamp（144 ＝ 3×BASE）**。

**致命的算術**：`MAX = 3 × BASE`、`eta` 用 `BASE`、而 T3 預算 `= RETURN_ABANDON_ETA_MULT(3.0) × eta`
⇒ **預算 ＝ 3 × BASE × 格數 ＝ 真實路程時間本身**
⇒ ★**餘裕恰好為零**：只要有任何一點延遲（LOD 視窗、決策 cadence、地形、一次 rehome 後多走的距離），就會在**最後一格**上超支。
∴ 三筆 stranded「卡在相鄰格」不是巧合——**那正是預算用罄的位置**。

## 連帶問題（porter164 貨沒掉）
本輪 `convoy.deliver = 2 / settled = 2`、**零 bail**、`stranded = 0`，∴ **本輪沒有重現「貨沒交割」**。
我**不把它併進上面的結論**（那是另一條因果）。要驗它需要在**會出現 stranded 的世界**（measurer 那組 150d/t3-budget）重跑並看 `convoy.deliver_bail_*` 分因——
★**但依你「相鄰卻不走」的真因是預算耗盡**，porter164「一進 RETURN 即刻凍」也可用同一機制解釋：
它進 RETURN 當下的 `eta` 只夠一格，而它至少要走一格。

## ★這缺陷為什麼今天才浮出（你自己那句我同意，補一個機制細節）
T3 兜底把現場收乾淨；而**在 T3 之前**，`27.9 日漂流`那個病把時間尺度整個蓋過去了——
兩層都會產生「porter 沒回家」，但**成因完全不同**，先修掉大的才看得見小的。

## 交付
- **無 code 交付**（診斷票）。temp tap（movement 三處分因 + 純算術對照床）全在拋棄式 worktree `laststep-diag`。
- **不產修法**，但把可裁的選項列給你（**我沒有動任何一個**）：
  1. **統一模型**：`eta_ticks` 改呼 `MovementSystem._move_cost`（同一把尺）——最徹底，但它是 belief/ETA 到處在用的函式，影響面要另評
  2. **預算改用真實成本**：T3 只在自己這裡用 `_move_cost × 格數` 當基準（不動 `eta_ticks` 的其他消費端）
  3. 只調大 `RETURN_ABANDON_ETA_MULT`（★我不建議：那是拿常數蓋住「兩套模型」的結構問題，且你上輪已否決過同型做法）
