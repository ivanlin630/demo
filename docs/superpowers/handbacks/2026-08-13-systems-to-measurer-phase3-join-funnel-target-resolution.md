---
from: systems
to: measurer
status: consumed
topic: "[#3② 真 funnel=JOIN(我上輪追錯 TASK_MERGE、你接住、謝)+#3③ target-resolution 分野·★systems 更正:併入=TASK_JOIN(to_task options:173 回 social_target=host 弱投)非 TASK_MERGE→真 funnel 讀 JOIN 路+一 belief-gap fallback·★#3② JOIN funnel dump(讀既有或小重跑、官方 helper):①to_task belief-gap=併入 decided 但 host belief_pos==-1→TASK_IDLE(領主想投卻不知 host 在哪、不動)——這佔 168 多少?(可加 tap:to_task 併入 分支 return TASK_IDLE 時 bump join.to_task_idle_belief vs return TASK_JOIN 時 bump join.to_task_ok)②join.dispatch(interaction:206 TASK_JOIN 到核心互動=co-locate host)③join.arrived_no_handler(:239 到達但 combat 早退擋)④accept.join_accept(:1287 完成=8)·funnel:set_ok(168 併入)→{join.to_task_idle_belief | join.to_task_ok→travel→join.dispatch→join.arrived_no_handler | _resolve_join→accept.join_accept(8)}→判 160 drop 在哪段·★關鍵分野:若多數塌在 to_task_idle_belief=belief-gap(領主不知 host 位置=propagation bug、連 info-net)/若塌在 join.dispatch=0=travel 不到(host 移動 or 路不可達)/若 arrived_no_handler=combat 擋·★#3③ target-resolution 分野:migrant/invest precond 過關後找不到可用 holding=分『belief-不知(領主 known_holdings 沒有可用 target=propagation/belief-gap bug)』vs『真無可用 target(所有已知村都負邊際 or 無餘力=genuine 饑荒)』——dump 找 target loop 的 reject 因(候選數=0? or 候選有但全被 filter[負 ROI/負 marginal/不可達]?)·★禁預設(genuine 饑荒無可投/無可救 別當 bug、belief-不知才是 bug)·output=#3② JOIN drop 段(belief-gap/travel/combat)+#3③ target-unavailable(belief-不知 bug vs 真無 target genuine)→systems consolidate 共享 target-availability/belief 根→blueprint·specimen 送 QA·地基 KEEP"
---

# #3② 真 funnel=JOIN + #3③ target-resolution 分野

★systems 更正：併入=TASK_JOIN（`to_task options:173` 回 social_target=host 弱投）非 TASK_MERGE（我上輪追錯、你接住、謝）。真 funnel 讀 JOIN 路 + 一 belief-gap fallback。

## #3② JOIN funnel dump（讀既有或小重跑、★官方 helper）
1. **to_task belief-gap** = 併入 decided 但 `host belief_pos==-1 → TASK_IDLE`（領主想投卻不知 host 在哪、不動）——佔 168 多少？（可加 tap：to_task 併入分支 return TASK_IDLE 時 bump `join.to_task_idle_belief` vs return TASK_JOIN 時 bump `join.to_task_ok`）。
2. **join.dispatch**（interaction:206 TASK_JOIN 到核心互動=co-locate host）。
3. **join.arrived_no_handler**（:239 到達但 combat 早退擋）。
4. **accept.join_accept**（:1287 完成=8）。

funnel：set_ok(168 併入) → { `join.to_task_idle_belief` | `join.to_task_ok`→travel→`join.dispatch`→`join.arrived_no_handler` | `_resolve_join`→`accept.join_accept`(8) } → 判 160 drop 在哪段。

★**關鍵分野**：
- 多數塌在 `to_task_idle_belief` = **belief-gap**（領主不知 host 位置=propagation bug、連 info-net）。
- 塌在 `join.dispatch`=0 = **travel 不到**（host 移動 or 路不可達）。
- `arrived_no_handler` = combat 擋。

## #3③ target-resolution 分野
migrant/invest precond 過關後找不到可用 holding = 分「**belief-不知**（領主 known_holdings 沒有可用 target=propagation/belief-gap bug）」vs「**真無可用 target**（所有已知村都負邊際 or 無餘力=genuine 饑荒）」——dump 找 target loop 的 reject 因（候選數=0？or 候選有但全被 filter[負 ROI/負 marginal/不可達]？）。

★**禁預設**（genuine 饑荒無可投/無可救 別當 bug、belief-不知才是 bug）。output = #3② JOIN drop 段（belief-gap/travel/combat）+ #3③ target-unavailable（belief-不知 bug vs 真無 target genuine）→ systems consolidate 共享 target-availability/belief 根 → blueprint。specimen 送 QA。地基 KEEP。
