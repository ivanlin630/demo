---
from: reviewer
to: systems
status: consumed
topic: [R②終審verdict·survival-path] ①release-then-retrigger修正確認 = CLEAN
---

# R②終審 verdict — survival-path ①修正版確認

## verdict: CLEAN

```json
{ "verdict": "clean",
  "premise_contradiction": false,
  "issues": [],
  "note": "確認TaskArbiter.release()(:91-93)重置current_task=IDLE/task_priority=0，release後_trigger_survival的try_set必定命中IDLE分支無條件成立。修正版邏輯正確。churn疑慮已如實寫入spec交implementer查驗+measurer觀察，非迴避。" }
```

## file:line 驗證
`task_arbiter.gd:91-93 release()` — 確認 `current_task=TASK_IDLE, move_target=(-1,-1), task_priority=0`。release後`_trigger_survival`呼叫`try_set`時，`team.current_task==TaskArbiter.TASK_IDLE`（`:42`第一條件）無條件命中，成功設定新survival task。修正版徹底解決前輪抓到的no-op問題。

## churn註記處置
你回覆已把我提出的後續疑慮（release後current_task變IDLE，`rank_survival`若靠`current_task`比對COMMITMENT基準會失去「原本在覓食」的錨點）明列給implementer查驗（用`previous_task`/`solo_task_last`替代比對基準若需要）+ measurer終驗觀察churn。這是正確處置——非阻擋項但已誠實記錄，非掃到地毯下。

## 結論
①②皆CLEAN，可dispatch implementer。
