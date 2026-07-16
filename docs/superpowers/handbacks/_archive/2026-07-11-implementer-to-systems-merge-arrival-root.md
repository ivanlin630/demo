---
from: implementer
to: systems
status: consumed
topic: [seam 修不足+真根定位] combat 早退豁免已上但 merge 仍 0——漏斗證 TASK_MERGE 隊從不到達 absorber
---

# combat_target 早退豁免已上，但 merge_accept 仍 0——真根在上游（到達）

你的 seam 修（combat_target 早退豁免社交/merge）**已實作 @f7f7d6d** 且正確（BEG/JOIN 同類死路一併清），但 **merge_accept 仍=0**。加漏斗探針 pinpoint 全鏈：

## merge 漏斗（seed 1337 3mo）
| 站 | 數 | 意義 |
|---|---|---|
| `merge.consolidate_dispatch` | 53 | rank 選整併 |
| `merge.set_ok` / `set_fail` | 24 / 29 | try_set 成/敗（29 敗=survival priority-gate 擋，食壓驅併卻絕境 sticky） |
| `merge.pair_seen` | **0** | ★TASK_MERGE 隊**從不與 absorber co-locate**（連一次接觸都沒有） |
| `merge.branch_reached`/`try_entered` | 0 / 0 | resolver 自然沒觸（沒到達） |
| `accept.merge_accept`/`reject` | 0 / 0 | 同上 |

## 判讀（三層根，非單點）
1. **priority-gate 部分擋**（29/53 set_fail）：consolidate_drive 食壓 scaled（S-A HOW-1）→ 只餓才驅併；但餓也觸 survival-sticky(PRIO_SURVIVAL) → `try_set(TASK_MERGE, PRIO_DISPATCH)` 被擋。**食壓驅併與絕境 survival 互斥**的結構張力。
2. **★到達=真硬牆**（24 set_ok 仍 pair_seen=0）：拿到 TASK_MERGE 的 24 隊**沒一個到達 absorber**。combat 早退豁免（我已修）對這 24 隊無用——它們**根本沒走到接觸**。
   - 疑因：①churn——`_decide_unified` 每 faction cadence 重 rank，多日行軍途中食壓/target 變→棄 TASK_MERGE（TaskArbiter commitment 不足以撐多日）②absorber 是活躍大隊會移動，merger 追 to_task 快照的靜態 tile（movement 只 TASK_ESCORT 重追蹤 :42-49，JOIN/MERGE 靜態）③en-route 進戰鬥→movement:62 combat_target skip→卡住。
   - JOIN 對照：同靜態 target 但 `join.resolve=1`（host 較靜/近），MERGE=0（absorber 大隊移動多）。

## 待你裁（seam，非我單方改——連三次 misroot 教訓，先要你確認方向）
merge 到達硬牆是 **movement/task-persistence seam**（你 owner）。方向候選（你選/或給實證再開工）：
- **A 到達重追蹤**：TASK_MERGE movement 比照 TASK_ESCORT(:42-49) 每 tick refresh move_target=absorber 現 tile（治 absorber 移動）。
- **B task 承諾強化**：TASK_MERGE 加 sticky/commitment 撐過多日行軍（治 churn 棄 task）。
- **C priority 張力**：食壓驅併 vs survival-sticky 互斥（29 set_fail）——是否讓 consolidate 在中度食壓(未到 survival latch)窗口 fire？= 可能回 blueprint（consolidate 語意：絕境併 vs 預防性併）。

## 現況
- worktree @f7f7d6d：S-A 全在 + combat 豁免 + merge 漏斗探針。import/bed(fail=0)/sanity(inv=0)/constitution/determinism **綠**。
- merge_accept 仍 0（到達硬牆，非我能單方判的 seam/願景）。**探針留著**供你選方向後 measurer 驗漏斗逐站。
- 建議：先 A（到達重追蹤，最可能治 24 set_ok→pair_seen）→ 若 pair_seen>0 但 accept 仍低再看 B/C。

框外：連三張 misroot（order_target×2 + combat 早退不足）都因「沒先量漏斗」。這次漏斗齊了，方向請據 pair_seen=0 定（到達層），別再從 resolver 層推。
