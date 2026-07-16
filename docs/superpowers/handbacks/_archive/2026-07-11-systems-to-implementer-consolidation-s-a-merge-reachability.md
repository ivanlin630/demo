---
from: systems
to: implementer
status: consumed
topic: [S-A merge-blocker 修] 整隊合併可達性 de-patch——補接 order_target(0/8333 根因)
---

# 修：整隊合併可達性 de-patch（TASK_MERGE 0/8333 → 補接 order_target）

18-seed 揭 `TASK_MERGE` 0/8333 never-accept（blueprint `taskmerge-deadpath`）。systems characterize **根因確認**（spec §HOW-5）：`_decide_unified` 成員 dispatch 漏接 `order_target` → `order_target_id` 恆 -1 → resolver/`_try_merge` 條件恆 false。

## 改（1 處，de-patch 補接，鏡射 leader 路 :403）
`faction_ai_system.gd` `_decide_unified` dispatch 尾（`:1508-1512`，`combat_target`/`social_target` 處理旁）補：
```gdscript
		if td.has("social_target"):
			state.set_social_target(team, int(td["social_target"]))
		if td.has("order_target"):
			team.order_target_id = int(td["order_target"])   # ★整併=成員決策走此路,漏接→TASK_MERGE 0/8333(v.s. leader :403 有接)
```
（若有 `set_order_target` chokepoint 就用它；無則直寫，鏡射 `:403` 直寫。）

## 驗
- **整隊合併真發生**：measurer 重跑量 `TASK_MERGE` accept >0（distinct 隊合併，非 solo-join）。
- determinism/融合閘/憲法綠。
- 次要（非本修）：`interaction:214` combat_target 早退可能仍擋部分（absorber 戰鬥中）→ 先看 accept 率，仍低才判第二修。

## 併入
- 加進 `feat/consolidation-s-a`（與 term/餵養/cadence gate 一起）。**merge 前 measurer 重跑 gate#1/#3 + TASK_MERGE accept>0 + churn metric（distinct vs 重派）**。
- ★worktree 記得 rebase/merge 最新 main（拿 bed resume/detach + 這批 spec）。
