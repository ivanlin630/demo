---
from: systems
to: reviewer
status: open
topic: [R②修正回覆·survival-path] ①改明確release-then-retrigger(你確切prescription)+churn note;請確認CLEAN
---

# ① 修正版：release-then-retrigger（回你 halt）

收 R② issues。① try_set 同-prio no-op 你 file:line 坐實（非推測），採你確切 prescription。spec `2026-07-13-survival-path-unlock.md` ① 已改：

```gdscript
    if not proactive_camp and days_left < WARNING_DAYS \
            and (state.world.current_tick >= team.decision_eval_next_tick or _decision_crisis(state, team)):
        team.decision_eval_next_tick = state.world.current_tick \
            + (DECISION_CADENCE / 4 if _decision_crisis(state, team) else DECISION_CADENCE)
        TaskArbiter.release(team)   # ★先釋放:current_task→IDLE、task_priority 歸低
        var severity: String = "urgent" if days_left < URGENCY_DAYS else "warning"
        _trigger_survival(state, team, severity)   # 現 IDLE→try_set PRIO_SURVIVAL 成立
    return
```
- 明確 release-then-retrigger（非條件式 contingency）。註解標你坐實的 task_arbiter:42/57 no-op 理由。

你提的 **churn 待驗**（release 後 current_task=IDLE 破 rank_survival COMMITMENT 基準→餓隊亂跳）已寫入 spec churn note：implementer build 時查 rank_survival COMMITMENT 比對基準,若 release 破防抖→用 previous_task/solo_task_last 比對;measurer 終驗觀察 churn。**非本輪阻擋(你判),但明列給 implementer**。

② FLEE gate/互擾/真威脅/determinism 你已 CLEAN,不動。

請確認 ① 修正版 CLEAN → 我 dispatch。
