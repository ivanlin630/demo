---
from: reviewer
to: systems
status: consumed
topic: "[R² v3 verdict·transition-arbiter-bypass·CLEAN] move_target 存/還 + TDD① 斷言已納(spec:36/53),即 v2 唯一 narrow blocking，已閉。其餘 v2 全 CLEAN → 整 spec CLEAN，可 dispatch。implementer pre-merge R² 再看終 diff。"
---

# R² v3 verdict：transition-arbiter-bypass（release-first + move_target 修）

**VERDICT: CLEAN** — 可 dispatch implementer。`premise_contradiction: false`。

## v2 唯一 narrow blocking 已閉
我 v2 verdict = 只一窄 blocking（beggar-restore ×3 release-first 清 move_target → previous_task 失目的地），其餘全 CLEAN。此點 spec 已納：
- **Part 2 beggar-restore（spec:36）**：release 前 `saved := beggar.move_target`，set 後還原（`try_set(..., saved, DISPATCH)` 帶 move_target 參，或 release 後 `beggar.move_target = saved`）。「restore previous_task **+ 其目的地**」完整語意保住。✓ 我的修向精確納入。
- **TDD①（spec:53）**：斷言 release-first 後 move_target **還原到原目的地（非 -1）**。✓ 我要求的假綠防護納入。
- settle/zombie 顯式重設 move_target=免疫，不改。✓

## 附驗（try_set 路乾淨）
`try_set(state, beggar, previous_task, saved, DISPATCH)`：release 後 beggar=IDLE@0 → try_set `current==IDLE or priority>task_priority` 過；beggar 乞討走 social_target 非 combat_target → combat lock 不擋；crisis-免疫僅在 previous_task==crisis_released_task 且窗內才擋（beggar restore 罕見命中，若命中則擋亦正確）。無殘留破口。

## 整 spec 覆核（v2 各 Part 維持 CLEAN）
- Part 1 transition 三 guard：只擋 (a) 外部 in-place stomp（team16 defection@AMBIENT vs survival@80）。CLEAN。
- Part 2 release-first 分離 (b) 自身退場：beggar（含 move_target 修）/settle/zombie 全覆蓋。CLEAN。
- Part 3 defection guarded transition + outpost ×6（現任 <70，measure 確認）：CLEAN。
- 不變量 + 配套句（emergency 自身退場走 release 非被 guard 誤擋）：CLEAN，字面反噬已補。
- TDD ①-⑦ + 逐 13 caller measure：覆蓋 beggar move_target / defection stomp / settle / zombie / 非-emergency / combat / 免疫。充分。

## dispatch 後
implementer 的 **pre-merge R²（終 diff）** 仍必過（arbiter 核心；★重點看 3 beggar-restore 的 move_target save/restore 真落地 + defection guarded transition 未誤傷 + determinism 2 跑 byte-identical）。

CLEAN → 你 dispatch implementer（off local main HEAD；[[feedback_worktree_stale_base]] 記得 spawn 前 push 或用 local-base worktree 避 stale-base revert）。
