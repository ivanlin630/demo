---
from: systems
to: implementer
status: open
topic: "[bed dump 補·pin remote founding 拉走機制·peaceful_economy_bed.gd 4Q dump 補印 construct.stall/construct.progress/construct.timeout_cancel/resume.* + probe_samples(ct_reason/ct_task/task_after)·WarringHarness.run result已含probe_samples(CONSTRUCT_SAMPLE_KEYS)只是bed沒print=小改·目的:complete_build=0但complete_upgrade_facility=6=remote founding子隊完工前被拉走,看ct_task/ct_reason坐實argmax搶班vs timeout release·re-run落地docs/measurements標path·零sim改零行為變(純多print既有data)] bed 4Q dump補印construct.stall/samples(ct_reason/ct_task)。已captured data純多print。re-run落地→pin拉走機制。"
branch: feat/peaceful-economy-bed
---

# bed dump 補：pin remote founding 拉走機制

**目的**：`complete_build=0` vs `complete_upgrade_facility=6`＝remote founding 子隊完工前被拉走（own-outpost 升級正常）。**拉走機制未坐實**（argmax try_set 搶班 vs 10 天 timeout release vs pre-TASK_BUILD），fix 方向依此不同 → 先 dump 看 `ct_reason`/`ct_task` 坐實。

## 補（bed 4Q dump 段，純多 print 既有 data）
`peaceful_economy_bed.gd` 4 問 dump 補印：
- **`construct.stall` / `construct.progress` / `construct.timeout_cancel` / `resume.attempt` / `resume.success` / `resume.reject_*`**（`result["probe"]` 已含這些 key，只是 4Q 段沒印）。
- **`result["probe_samples"]`**（WarringHarness.run 已 capture `CONSTRUCT_SAMPLE_KEYS` = construct.start/stall/progress/complete/timeout_cancel/resume.* 的 sample payload，含 **`ct_reason`/`ct_task`/`task_after`** 等 why 欄）→ print 出來（尤其 `construct.stall` 的 samples：施工隊被搶時 current_task 變成什麼 ct_task + 誰搶 ct_reason）。
- ★純多 print `result` 既有欄位，**零 sim 改、零行為變、零數字變**（4 問數不變）。

## 驗 + 交付
1. bed exit0、observability_gate 仍 PASS（bed 無 marker、不被掃）、constitution 74。
2. **re-run 落地 `docs/measurements/`（標 exact path 驗存在）**——含 construct.stall/samples ct_reason/ct_task。
3. commit + handback `to:systems`（帶 construct.stall 計數 + ct_task/ct_reason 摘要：remote founding 子隊被搶時 current_task 變啥、誰搶）。

→ 我讀 dump pin 拉走機制（argmax vs timeout）→ 設計 non-freeze founding fix（persist floor 或 timeout-aware）→ R²。卡住報 `to:systems`。
