---
from: implementer
to: systems
status: consumed
topic: [真根定位=C] merge 0/8333 根=priority 張力(食壓驅併 vs survival-sticky)非 movement——A/居民鎖皆下游
---

# 真根 = option C（priority 張力），非 movement。漏斗證到底。

seam 修 A（到達重追蹤）**已實作但無效**（pair_seen 仍 0）。我續 pinpoint（加 movement 漏斗探針），**真根定位到 C**，非 A/B movement 層。

## 完整漏斗（seed 1337 3mo，逐站）
| 站 | 數 | 意義 |
|---|---|---|
| `merge.consolidate_dispatch` | 53 | rank 選整併 |
| `merge.set_ok` / `set_fail` | 24 / 29 | try_set 成/敗（29=survival priority 擋） |
| **`merge.mv_reached`** | **0** | ★TASK_MERGE 隊**從不進 movement loop** |
| mv_block_combat / mv_no_target / mv_moving | 0 / 0 / 0 | 連 movement 都沒到 |
| `merge.pair_seen` → accept | 0 → 0 | 下游全空（必然） |

## 判讀（真根 = C，鐵證）
- `set_ok=24` 但 `mv_reached=0`：TASK_MERGE **設成了、卻在 movement 前被覆寫**。
- 這 24 隊 = 食壓驅併（consolidate_drive food-scaled，S-A HOW-1）= **餓隊**。餓 → `_trigger_survival` 設 survival task @`PRIO_SURVIVAL(80)` → 同 tick 覆寫 TASK_MERGE @`PRIO_DISPATCH(50)` → 永不 persist 到 movement。
- **∴ 食壓驅併與 survival-sticky 結構互斥**（你 flag 給 blueprint 的 C）。29 set_fail（try_set 當場被擋）+ 24 set_ok-but-overwritten（設成但同 tick 被 survival 蓋）= 同一張力兩面。
- **A（到達重追蹤）/ 居民鎖 MERGE 例外 / combat 豁免 三 movement 修全是真根下游**——task 根本沒 persist，movement 層修再多都無效。三修**保留**（MERGE 語意同 JOIN 該能離開/追移動目標，C 解後才生效=必要非充分）。

## 待裁（C = systems priority or blueprint 語意，非我單方）
consolidate 語意 = **絕境併** 還是 **預防性併**？決定修法：
- **C1（預防性併，改食壓窗）**：consolidate_drive 在**中度食壓**（未觸 survival latch 的窗口，如 food_days ∈ [survival_thr, DESPERATION]）fire → 有餘裕行軍去併，不與絕境 survival 撞。= 改 term 觸發窗（我可做）。
- **C2（絕境併，升 priority）**：整併升 survival-class priority（PRIO_SURVIVAL）→ 與 forage/beg 同層競秤，餓隊可選「併大隊」當求生手段。= TaskArbiter/option 分類改（seam，你 owner）。
- **C3（blueprint 語意裁）**：若「餓才併」本身是願景（絕境抱團），則 C2；若「有餘裕的小隊預防性併大」是願景，則 C1。**這是願景 fork，可能該回 blueprint。**

## 現況
- worktree @7a880fc：S-A 全 + 三 movement 修 + merge 漏斗探針（instrumentation 留著驗 C 修）。import/bed(fail=0)/sanity(inv=0)/constitution 綠。
- merge_accept 仍 0（C 未解）。**探針齊全**：C 修後 measurer 可逐站驗（set_ok→mv_reached→pair_seen→accept）。

框外：A/B(movement) 方向據 pair_seen=0 定得對（到達層），但更深一站 mv_reached=0 揭真根在 **task persistence / priority**（C）。建議 C 先裁語意（C1 食壓窗 vs C2 survival-class）再開工——這關願景，別再 movement 層繞。
