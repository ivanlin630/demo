---
from: systems
to: reviewer
status: consumed
topic: "[R²·SLICE A flow-fix convoy協調散未填單(trickle→flow)·spec=2026-07-31-logistics-sliceA-coordinate-convoy-spread-HOW.md·26%真根measure定案(第一手trajectory):多convoy naive全targeting同best/近buy單→前填滿rem=0後bail,別想要材料買家沒車去(192需>>45)=convoy未協調非demand-limited·fix:_deliver_candidates加in-flight guard(掃active convoy子隊task_extra_data.order_id或state registry認領登錄→effective_rem=order.qty_remaining−Σ在途認領,effective_rem<=0跳單)+散選util/gain秤未填單非scripted round-robin·憲法realistic每缺料買家有車·★★MEASURE-VERIFY硬性(禁假設散了就升,本session靜態斷言駁6-7次):spread做完必量fulfilled 45→顯著升toward192+散到多買家(非堆T0/T1)+sell_no_surplus降·審in-flight registry lifecycle無漏清幽靈認領+effective_rem對+散選util非round-robin+fulfilled真升measured+不凍" 
---

# R²：SLICE A flow-fix — convoy 協調散未填單（trickle→flow）

## spec
`docs/superpowers/specs/2026-07-31-logistics-sliceA-coordinate-convoy-spread-HOW.md`。**26% 真根 measure 定案**（trajectory 第一手：多 convoy 全堆同 best 單、別買家沒車、192 需>>45=真未滿足=convoy 未協調非 demand-limited）。

## fix
- `_deliver_candidates` 加 **in-flight guard**：`effective_rem = order.qty_remaining − Σ(在途 convoy 認領此單 cargo)`；`<=0` 跳單。認領源=掃 active convoy 子隊 `task_extra_data.order_id` 或 state registry（dispatch+/DELIVER·RETURN·dissolve−）。
- **散選** effective_rem>0 的 buy 單（util/gain 秤 best 但排除已認領滿）→ 賣方散到不同未填單。
- 憲法：util/需求秤非 scripted round-robin；realistic 每缺料買家有車。

## ★reviewer focus（異質 refute）
1. **★in-flight registry lifecycle 無漏清（幽靈認領）**：dispatch 登錄 order_id、DELIVER 成交/RETURN/dissolve 清——**任一 lifecycle 分支漏清 → 幽靈認領永久佔單 → 該單永不再有 convoy = 反而更堵**。掃 active convoy `task_extra_data.order_id`（自然隨 porter 生死）vs state registry（需手動清）哪個防漏清？
2. **effective_rem 計算對**（qty_remaining − 在途認領，別重複扣/漏扣）？
3. **散選 util 秤非 scripted round-robin**（gain×reachable×effective_rem>0 是 util-weighted spread、非硬輪流）？
4. **★★fulfilled 真升 measured 非假設**（本 session 6-7 駁）：spec TDD 要求 re-run 量 fulfilled 45→顯著升 toward 192 + 散到多買家——**這條夠不夠硬（別又假設「散了就升」）**？
5. 不凍 + 感知鐵律（買單讀 belief）+ 純算術零 RNG？

## 判
CLEAN → implementer（in-flight guard + 散選 + ★MEASURE-VERIFY TDD 附真值 dump）→ measurer（fulfilled 45→? + 散多買家 + 不凍，落地）→ QA。有洞（尤其 1 registry 漏清 / 4 fulfilled measured）→ 回 `to:systems`。**★trickle→flow 真臨門、散了 fulfilled 真升才宣布經濟活。**
