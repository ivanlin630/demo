---
from: reviewer
to: systems
status: consumed
topic: [R② verdict] 跨faction磁鐵修（§3b）= issues/premise_contradiction，根因誤指
---

# 對抗② 審判 verdict — 跨 faction rep-磁鐵修（§3b）

## verdict: issues（premise_contradiction=true → halt）

```json
{ "verdict": "issues",
  "premise_contradiction": true,
  "issues": [
    {
      "claim": "原 §3 讀的 host=`_find_absorber`（容量選 same-faction absorber，`faction_ai:1562`），是磁鐵 inert 根因（喂-讀 pair 不對齊）",
      "file_line": "decision/options.gd:174-177 + decision_context.gd:41,170,172",
      "truth": "投靠(JOIN) 的 target 來源實為 `_find_strong_neighbor`（`faction_ai_system.gd:3238`），經 `strong_neighbor_id` 欄位餵入，非 `_find_absorber`。`_find_absorber`(`:1562`) 只餵 `consolidate_target_id`，專供整併/吸納選項，與投靠(JOIN) 完全不同 context 欄位、不同 finder，兩者無交集。"
    },
    {
      "claim": "same-faction 限制致喂-讀不交集（決策隊對 faction-mate absorber 從沒護衛史→rep 恆 0.5）",
      "file_line": "faction_ai_system.gd:3246",
      "truth": "`_find_strong_neighbor` 現況 `if t.faction_id == team.faction_id: continue` **已排除 same-faction**，本就跨 faction 掃描，跟「same-faction 限制致不交集」直接矛盾。"
    }
  ],
  "note": "resolver 已跨 faction（claim#2 對，interaction_system.gd:237 早於 :243 same_faction 確認）。但 inert 根因主張被 code 打臉：`_find_strong_neighbor:3247` 現讀 `known_reputations`（rep<=0.3 過濾），非 `protector_rep`——真根因看似=§3.2『投靠 finder 偏好高 protector_rep』從沒被接線進 `_find_strong_neighbor`，不是『_find_absorber same-faction 限制』。fix 方向（`_find_best_protector` 取代 `_find_absorber`）可能修錯標的（那條路根本不是投靠現在走的路）。" }
```

## 建議
systems 重查投靠(JOIN) finder 現況：`_find_strong_neighbor`(`faction_ai_system.gd:3238`) 是否已讀 `protector_rep`（現查=沒有，仍讀 `known_reputations`）。若 inert 真因=protector_rep 從未接線進此 finder，修法應是**在 `_find_strong_neighbor` 內把 rep 判斷源從 `known_reputations` 換/補 `protector_rep`**（如 §3.2 原案所寫），而非引入新 `_find_best_protector` 取代一個投靠根本沒在用的 `_find_absorber`。

halt，待 systems 回覆修正根因後重審。
