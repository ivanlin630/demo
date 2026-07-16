---
from: systems
to: implementer
status: consumed
topic: "[DISPATCH·最高優先] SpecimenTracer RNG confound修——新分支feat/specimen-rng-confound-fix;R²CLEAN;包suppress_observe_noise;三跑byte-identical驗"
---

# Dispatch：SpecimenTracer RNG confound 修（★最高優先，擋一切）

spec：`docs/superpowers/specs/2026-07-15-specimen-rng-confound-fix.md`
R² CLEAN：`2026-07-15-reviewer-to-systems-confound-fix-r2-clean.md`（鏈全驗、稽核無漏、scope 精準；★spec 行號有小誤，**照 substance 不照行號**——grep 函式名定位）。

## 在哪：新獨立小分支（快 merge=infra 擋一切）
`feat/specimen-rng-confound-fix`，base 最新 main。**這是 infra bug 修，優先於 desperation**（desperation 分支先擱，等 confound 修 merge 後 rebase 重驗）。

## 做什麼
`specimen_tracer.gd`：tracer **額外重跑決策/估算**（觸達 `observe_velocity` randf）處，包 `PathSystem.suppress_observe_noise` save/restore：
- **`capture_options` 的 to_task 迴圈**（每候選呼 `DecisionOptions.to_task`→finder→`estimate_catch_up`→`observe_velocity`→randf）：迴圈前 `var _prev = PathSystem.suppress_observe_noise; PathSystem.suppress_observe_noise = true`；迴圈後 `PathSystem.suppress_observe_noise = _prev`。
- **稽核其餘 tracer 函式**（`_snapshot`/`capture_decision`/`capture_intent` 的 own_granary_tile/target_rung/best_estimate/_target_team_id）：grep 確認有無其他觸達 observe_velocity/randf/mutation 的路；有→同包 suppress；無→不動。**可選更穩**：capture 入口設 suppress=true、出口 restore（整個觀測期 RNG-neutral，真實 rank 在 capture 外不受影響）。
- **scope 精準**：只包 tracer **額外**呼叫，**真實 rank/dispatch 的 estimate_catch_up（在 rank 內、capture 之前）不動、保留 noise**（真實世界軌跡不變）。

## TDD / 驗（★操作定義=不變量）
1. **三跑 byte-identical**：同 seed force_full_hd，`SPECIMEN_TEAM_ID=A` / `=B` / 無-specimen → **除 SpecimenTracer entries 外世界狀態/所有隊軌跡 byte-identical**（修前紅：0/71/88 岔；修後綠：三組一致）。這是核心 red/green。
2. determinism 保；憲法 sites 不變（tracer 純觀測零新 try_set）；headless 零新增。

## 完成後
→ measurer **中性世界重驗**（confound 除三跑一致 + **thrash 在真實世界到底消沒消**=desperation release 真門檻）→ 回 systems/blueprint。
完成判定 = systems + reviewer/QA + measurer 中性重驗。scope 疑義走 `to:systems`。
