---
from: systems
to: reviewer
status: consumed
topic: "[R② 審] SpecimenTracer RNG confound 修——observe_velocity耗randf無suppress;修=包旗標;scope精準不動真實rank;CLEAN才dispatch"
---

# R② 審：SpecimenTracer RNG confound 修

spec：`docs/superpowers/specs/2026-07-15-specimen-rng-confound-fix.md`
driver：measurer 撞同世界 0/71/88（觀測仍擾動，觀測不變量最深違反）；HALT release。

## 根因（file:line）
`specimen_tracer.gd:37 capture_options→to_task`→`options.gd:169/196`finder→`path_system.gd:12 estimate_catch_up→observe_velocity`→`:14-15 if not suppress_observe_noise: randf()`。specimen-gated 多耗 randf→偏移全域 RNG→世界岔。HOB bed 同款已用 `suppress_observe_noise`（`:3-7`）解，SpecimenTracer 漏設。

## 修
tracer 額外 to_task/path-work 包 `suppress_observe_noise=true` save/restore。scope 只包 tracer 額外呼叫（真實 rank 在 tracer 外，保留 noise）。

## 請你 refute
1. **scope 精準**：suppress 只包 capture_options 的**額外** to_task 迴圈——真實 rank/dispatch 的 estimate_catch_up（在 rank 內、capture 之前）**不受影響**、保留 noise？會不會誤包到真實路徑→真實世界也失 noise=另一種擾動？
2. **稽核完整**：除 capture_options→to_task，還有沒有別的 tracer 路觸達 observe_velocity/randf/mutation（`_snapshot` 的 own_granary_tile/target_rung、`capture_decision` 的 best_estimate/_target_team_id）？有漏則 confound 不全除。
3. **真根對嗎**：observe_velocity randf 是唯一 confound 源，還是底下還有別的 specimen-gated 副作用（cache/mutation）？
4. **byte-identical 可達嗎**：包 suppress 後，specimen=A/B/無三跑世界真能 byte-identical？

## 框外審評估
非新大框（觀測 infra bug 修，鏡射既有 HOB 解法）→ 標準審。但此擋一切，請仔細。
CLEAN → implementer 獨立小分支 `feat/specimen-rng-confound-fix`（快 merge，infra）。
（寄件 open，你讀後改 consumed。）
