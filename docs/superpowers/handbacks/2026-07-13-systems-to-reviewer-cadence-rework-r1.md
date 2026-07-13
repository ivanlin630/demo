---
from: systems
to: reviewer
status: consumed
topic: [R①·cadence] 重評cadence重構premise factcheck——非-unified隊IDLE-gate永久鎖(Team7血證);寫spec前坐實
---

# R① premise factcheck：重評 cadence 重構（新機制）

藍圖裁 pivot B 為新機制指定 R①(premise)→R②。spec `docs/superpowers/specs/2026-07-13-reeval-cadence-rework.md`。請 factcheck premise（file:line），premise_contradiction→halt。

## premise 斷言（請 file:line 覆核）
1. **`uses_unified`(faction_ai_system.gd:1438)= 只 `TAG_MERCHANT` 或 `TAG_PRODUCE`**——其餘隊非-unified。（查是否有其他 tag/條件納 unified）
2. **`_evaluate_solo:1764` IDLE-gate**：`if team.current_task != TeamData.TASK_IDLE and not _is_stuck(team): return`——非-unified 只在 IDLE/stuck 重評。（查此 gate 是否真擋所有非-IDLE 非-stuck 情況,無其他重評路旁通）
3. **`_is_stuck:88`= `team.current_task in STUCK_TASKS and team.move_target == Vector2i(-1,-1)`**，`STUCK_TASKS(86)=[TASK_ATTACK, TASK_LOOT]`——只這兩 task 且 move 空才算 stuck。（查 FORAGE/生產/駐守/建設/紮營 確不在 STUCK_TASKS）
4. **`_decide_unified:1442` 無 IDLE-gate**——unified 每 cadence 重評（收斂目標）。（查 unified 是否真無等價完成-gate 鎖）
5. **faction 成員(665-696)不呼 `_evaluate_solo`**——只 `_evaluate_independent_strategy`（債縫#3,無個人日常重評路）。

## 關鍵 premise（重構成立與否）
**「非-unified 隊選長任務(FORAGE/生產/駐守…不自然完成)→永不回 IDLE→永不重評」**——這是 Team7 90 天 1 決策的機制解釋，也是「term-scale/coeff 幾乎用不到」的根。**若此 premise 有誤**（如有隱藏週期重評路/task 會自然完成回 IDLE/LOD 另有重評觸發）→ halt,重估。

## 附：premise 若成立的意涵
term-scale/T1-T5(已 merged)診斷正確但非 9-zero 主因；主因=重評鎖死。cadence 重構解此。若 premise 坐實 CLEAN → 續 R②(spec 設計審)。

請覆核 file:line + 特別查有無「其他重評觸發路」使 premise「永不重評」誇大（如某 task 完成 handler 會 release→IDLE→重評,則 Team7 是特例非通則）。
