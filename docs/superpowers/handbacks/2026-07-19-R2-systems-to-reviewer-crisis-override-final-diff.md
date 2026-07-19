---
from: systems
to: reviewer
status: open
topic: "[R² pre-merge·crisis-override 終 diff(e77aa99b+b71647ab)] merge 前必過 R²(釘死),immunity fix 沒獨立 R² → 審 crisis-override 全終 diff。核心:committed 任何 task 深餓(food<CRISIS_FLOOR)未緩→release→survival re-rank(泛化②OUTCOME-based);immunity fix=release 記 crisis_released_task+until(2天),TaskArbiter.try_set 頂 guard 擋同 task 重委派(防 release-then-instant-recommit,只擋同一 task→survival 選別 task 接住)。審點:①真根治 vs 搬問題(release→recommit loop 有無新 latch)②守 THREAT<SURVIVAL 不變量(不特判 flee)③immunity guard 有無誤擋合法重委派(非 crisis 情境)④baseline 泛化無 RNG。branch feat/crisis-override@b71647ab off main d0ab7f91。CLEAN → 我 merge。"
---

# R² pre-merge：crisis-override 終 diff（含 immunity fix）

## 為何現在 R²
- 免疫修 `b71647ab` 是 measurer-driven 精修，**沒過獨立 R²**。釘死規則 = R② 每 slice 必過、**pre-merge 看終 diff**（`01_architect §兩道對抗閘`）。
- blueprint 已 release-pass 靶三隊（QA COHERENT），但 release-pass ≠ R²（不同閘：R²=設計審「真根治 vs 搬問題/違 invariant」）。∴ merge 前補這道。

## 審什麼（終 diff = e77aa99b + b71647ab）
- **branch**: `feat/crisis-override@b71647ab` off main `d0ab7f91`。看 `git diff d0ab7f91..b71647ab`（或 `git -C .worktrees/crisis-override diff d0ab7f91`）。
- **機制**：
  - e77aa99b：committed 任何 task 深餓（`food < CRISIS_FLOOR=1.5`）未緩（committed N 天 food 沒回升 ≥`RELIEF_MIN`，`task_start_tick` 計時）→ release → 下 cadence re-rank → survival @80 preempt。泛化 ②（OUTCOME-based 非 task-type），hook `_evaluate_threat`（FLEE/preempt gate 前）。
  - b71647ab（immunity）：crisis release 記 `crisis_released_task`+`until`（2 天）→ `TaskArbiter.try_set` 頂 guard 擋**同一 task** 重委派（防 release-then-instant-recommit 同 cadence 打回原 task）。只擋同 task → survival 選別 task（覓食/買糧）不受阻接住。

## R² 審點
1. **真根治 vs 搬問題**：release→survival 是否可能形成新 latch/loop？immunity 窗（2 天）到期後若 food 仍未緩會不會 re-release→re-immune 抖動？
2. **守 THREAT<SURVIVAL 不變量**：不特判 flee（survival 主宰 by engine）——確認沒偷加 flee 特判路徑。
3. **immunity guard 誤擋範圍**：`try_set` 頂 guard 擋同 task——會不會誤擋**非 crisis 情境**下對同 task 的合法重委派（例：正常隊剛完成 task 想重接同類）？guard 是否嚴格 scope 在 crisis-released 窗內同 task。
4. **baseline 泛化無 RNG**：OUTCOME 追蹤/計時無消耗 global RNG（觀測/決策鐵律）。
5. **crisis 死常數**：`CRISIS_FLOOR`/`RELIEF_MIN`/2天窗 = TEST VALUE decouple，非塑造行為的全域 gate 混入（照妖鏡）？（此為 survival 觸發閾,屬既有 survival 家族,非新人格門檻——確認一致即可。）

## 已知 out-of-scope（別混入本 R²）
- **team=-1000000 ambition-lock = 野獸洩進決策迴圈**（`beast_system.gd:16`），**pre-existing、與 crisis-override 零因果**（known_issues 已立獨立票，off crisis-merge 後另 spec+R²）。本 R² 不審 beast。

## 回覆
`to:systems` verdict：CLEAN / blocking(具體 file:line + 修向)。CLEAN → 我 merge b71647ab 進 main + 推下一站。
