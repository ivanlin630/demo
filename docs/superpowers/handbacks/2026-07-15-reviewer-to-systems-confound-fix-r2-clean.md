---
from: reviewer
to: systems
status: consumed
topic: "[R②判決·CLEAN] SpecimenTracer RNG confound修——鏈全驗證,稽核無漏,scope精準;spec引用行號有誤(substance對)供訂正;可dispatch"
---

# R② 判決：SpecimenTracer RNG confound 修

verdict: **clean**
premise_contradiction: false

## 逐點驗（file:line 全查證，實際行號與 spec 引用有出入見下方訂正）

1. **scope 精準**：`decision_engine.gd:15-19 rank_scored` 先跑 `rank_scored_ctx`（真實 rank，:17，此時消耗真實 noise）**才**呼叫 `capture_options`（:18，specimen-gated）。suppress 只包 `capture_options` 內部自己的 to_task 迴圈，發生在真實 rank 已完成之後 → 真實 rank/dispatch 的 `estimate_catch_up` 呼叫（在 `rank_scored_ctx`→`DecisionTerms.eval` 內，capture_options 之前/之外）完全不受 suppress 影響、noise 保留。scope 邊界天然正確。
2. **稽核完整**：逐一查過 `_snapshot`（`resource_system.gd:386 own_granary_tile` 全文無 randf/randi；`ambition_ladder.gd:67 target_rung` 純讀 team 欄位+factions dict，無 randf）、`capture_decision`（`belief_system.gd` 全文 grep randf/randi 零命中，`best_estimate`/`claims` 純讀；`_target_team_id` 純迭代 tile_pos 比對）、`capture_intent`（純 scratch dict 寫入）——**確認皆零 RNG**，confound 只有 observe_velocity 一條路，稽核無漏。額外查 `_check_discipline:1688 randf()`（子隊紀律檢定）——不在 capture_options 呼叫鏈上，與本 confound 無關。
3. **真根對**：`path_system.gd:172-186 observe_velocity`（真實函式位置，非 spec 引用的 :14-15——見下方訂正）確認 `if not suppress_observe_noise: randf()`；`:196-218 estimate_catch_up` 於 :207 呼叫 observe_velocity，`trusted` 參數只影響 :198/:174 的 discovery gate，**不影響** :185 的 randf 消耗閘（獨立控制）——即便 `_find_weakest_prey`(`faction_ai_system.gd:3290`)/`_find_aid_target`(`:3430`) 皆以 `trusted=true` 呼叫，randf 仍照消耗，confound 鏈成立。`options.gd:169`/`:196` 呼叫這兩個 finder 確認吻合。
4. **byte-identical 可達**：稽核覆蓋全 tracer 函式後零殘留 RNG 路徑，suppress wrap 後 specimen=A/B/無三跑理論上應 byte-identical——這點最終仍需 measurer 實跑驗證（design-level 已無理由不達成）。

## 訂正（非阻擋，供 implementer 免走冤枉路）
spec 引用的 `path_system.gd:12`/`:14-15` 行號與實際檔案不符——**實際**：`observe_velocity` 在 `:172-192`（randf 消耗在 `:185-186`），`estimate_catch_up` 在 `:196-218`（呼叫 observe_velocity 在 `:207`）。**substance 完全正確**（函式名/邏輯鏈/suppress 機制皆核實無誤），只是行號引用過期，建議 systems 順手訂正 spec 引用行號，implementer 對照較快。

## 框外審評估
同意——鏡射既有 HOB 解法的 infra bug 修，非新框，標準審足夠。

## 結論
根因、scope、稽核完整性、determinism 設計全驗證無誤。**CLEAN → 可直接 dispatch implementer**（獨立小分支 `feat/specimen-rng-confound-fix`）。
