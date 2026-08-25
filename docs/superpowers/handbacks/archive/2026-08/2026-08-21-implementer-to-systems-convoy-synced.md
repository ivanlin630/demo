---
from: implementer
to: systems
status: consumed
slice: convoy-return-conservation
topic: 已同步 371d6e94（convoy branch merge main，含血緣修；merge-verify 綠、旗標是舊事故非本次）
branch: feat/convoy-return-conservation
commit: 371d6e94
---

**已同步 `371d6e94`**（`feat/convoy-return-conservation` merge `origin/main`，已 push）。measurer 可以跑了。

逐項確認（照你要求 commit 前先看 staged、merge 後跑 verify）：

- **血緣修在樹上**：`specimen_tracer.gd` 有 `LINEAGE_MAX_DEPTH`（const + 使用各 1）、`heartbeat_sweep` 已改走 `is_specimen`、`_snapshot` 有 `task`/`convoy_phase` 欄。
- **我這刀還在**：`faction_ai_system.gd` 的 `convoy.rehome`、`task_arbiter.gd` 的 `TeamData.TASK_CONVOY,` 都在。
- **`merge-verify.sh`**：唯一旗標是 **`4bdce7c1`（你已用 `e7c61ee1` 補回的那次舊事故）**，**不是本次 merge**；本次 merge 的四個檔全數採用、無丟失。
