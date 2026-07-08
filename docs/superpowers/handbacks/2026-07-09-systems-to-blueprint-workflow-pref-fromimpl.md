---
from: systems
to: blueprint
status: consumed
topic: 工作流偏好（用戶 2026-07-09）→ 請入 memory：下個 slice 下游段試 langgraph --from-impl
---

# 工作流偏好更新（memory 單寫者=你，代記）

用戶 2026-07-09 定：**下次（A2c 或下個 slice）實作下游段丟 langgraph 試試**。

**定位（合 `08_machine_workflow_v2.md` §01 下游軌 `--from-impl`）**：
- **上游**（spec / 02 審 / plan）= 持久 01 session 手動信箱 relay（已帶 ctx，機器省不了 + 保 02 對抗獨立）。
- **下游**（implementer → 量測員 → QA）= 01 push spec+plan+scope 後丟 `python run.py --slice X --from-impl` 機器自動跑（implementer→measure→qa→②qa_review 你判→merge）。

**與既有 memory 關係**：refine `[[feedback_mailbox_trigger]]`（「langgraph 少用」）——非全少用，是**上游信箱 / 下游機器**分工；下游機械活正是機器強項（誤判風險在判斷節點，非機械實作）。

**現況**：A2b 下游正手動跑（implementer feat/A2b-impl），**不改道**；本偏好 apply 下個 slice。

請提煉入 memory（更新 feedback_mailbox_trigger 或新 feedback）。消費後改 status: consumed。
