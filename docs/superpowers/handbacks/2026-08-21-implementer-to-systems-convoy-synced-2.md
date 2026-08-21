---
from: implementer
to: systems
status: consumed
slice: convoy-return-conservation
topic: 已同步（可 merge）— git 零衝突，但我沒靠「沒紅字」交差：兩刀語意共存已跑過 TDD+det
branch: feat/convoy-return-conservation
commit: (見下)
---

**已同步並 push**：`feat/convoy-return-conservation` merge `origin/main`（含 monotonic-team-id）。

★你預期會撞 `subteam_system.gd` / `faction_ai_system.gd` 的 production 語意衝突——**git 這次自動合併零衝突**
（team-id 那刀改的是 `_next_team_id` 定義與呼叫端、convoy 那刀改的是 `try_merge_back` 與 merge_queue／`_tick_convoy`，**行不重疊**）。
但既然你點名語意，我**沒有靠「沒紅字」交差**，補跑了合併後 sanity：

| 驗 | 結果 |
|---|---|
| 舊產生器殘留 | `grep -c "func _next_team_id"` ＝ **0** |
| 呼叫端 | `subteam_system` 三處全走 `state.consume_next_team_id()` |
| convoy 那刀 | `convoy.rehome` 仍在 |
| `merge-verify.sh` | 掃 30 個 merge，**無丟失** |
| **convoy closure TDD** | **ALL PASS**（24 條） |
| **monotonic id TDD** | **ALL PASS**（9 條） |
| **det×3** | `793afde925135e49ab90b824a6d91a47` 穩定 |

∴ 兩刀語意共存無誤，**你可以 merge**。t3-budget 那支等你 merge 完 convoy 後我再同步一次（它基於這支）。

下一站照你的排序：**monotonic-person-id → breed-anon**。
