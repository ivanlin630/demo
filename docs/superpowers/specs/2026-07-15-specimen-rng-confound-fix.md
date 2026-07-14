# Spec：SpecimenTracer RNG confound 修（觀測不變量最深違反·HALT 解除前提）

status: draft（待 reviewer R② CLEAN → dispatch implementer）
owner: systems
premise_verified: 根因 file:line 坐實（observe_velocity randf + suppress 旗標）
driver: `2026-07-15-blueprint-to-systems-HALT-fix-observation-confound.md`（同世界 0/71/88，觀測仍擾動）
governing: `invariants.md §全量暫態可觀測性`（觀測者不得改被觀測物）——**本 bug=該不變量最深違反：tracer 違反它自己該服務的不變量**。

## 一句話
SpecimenTracer `capture_options` 對 specimen 每候選呼 `DecisionOptions.to_task`→finders(`_find_weakest_prey`/`_find_aid_target`)→`PathSystem.estimate_catch_up`→`observe_velocity`，而 `observe_velocity`（`path_system.gd:14-15`）在 `suppress_observe_noise==false`（sim 常態）時**消耗 `randf()`**。∴ 觀測 specimen 多耗 RNG → 偏移全域 RNG 流 → 全世界岔開（同世界 0/71/88，連非被觀測隊都變）。**上輪非侵入化只修 LOD-exemption，漏這條 RNG 路。**

## 根因坐實
- `path_system.gd:7 suppress_observe_noise`（static，sim 常態 false）；`:14-15 observe_velocity`：`if not suppress_observe_noise: observed_speed = actual_speed*(1+(randf()-0.5)*noise)`——**randf 消耗閘於此旗標**。
- `:12 estimate_catch_up → observe_velocity`；`options.gd:169/196 to_task → _find_weakest_prey/_find_aid_target → estimate_catch_up(...)`；`specimen_tracer.gd:37 capture_options → to_task`（**specimen-gated，每候選一次**）。
- **同款模式已知已解**（`path_system.gd:3-7` 註解）：hand_obeys_brain_bed「每 cadence 對每隊多算一次 rank→estimate_catch_up→observe_velocity，若消耗 global RNG 會擾動 sim 軌跡」→ 用 `suppress_observe_noise` 采樣期暫開采完復原。**SpecimenTracer 是同款儀器但沒設此旗標=confound 根。**

## Fix：tracer 額外 path-work 包 suppress_observe_noise（鏡射 HOB）
`specimen_tracer.gd`：凡 tracer **額外重跑決策邏輯**（會觸達 observe_velocity）的地方，包 `suppress_observe_noise` save/restore：
```gdscript
# capture_options 內，to_task 迴圈前後（僅 specimen 走到此，gate 已過）：
var _prev: bool = PathSystem.suppress_observe_noise
PathSystem.suppress_observe_noise = true
for e in scored:
    ... var td = DecisionOptions.to_task(state, team, opt) ...   # 額外 to_task，現零 RNG
PathSystem.suppress_observe_noise = _prev
```
- **scope 精準**：只包 tracer 的**額外** to_task 呼叫（capture_options 的 nd-flag 計算）。**真實 rank/dispatch 的 estimate_catch_up 不受影響**（它們在 rank 內、tracer 之外，保留 noise）→ 真實世界軌跡不變，只消除 tracer 的額外 RNG。
- **稽核全 tracer 函式**：`_snapshot`（own_granary_tile/target_rung/effective_food/food_security_target）、`capture_decision`（`_target_team_id`/`best_estimate`）、`capture_intent`——確認**無其他觸達 observe_velocity/randf/mutation 的路**；有則同包 suppress 或改純讀。（best_estimate 讀 belief 純讀；own_granary_tile/target_rung 需查有無 RNG——一併稽核，有則包。）
- **可選更穩**：若稽核發現多處，直接在 capture_options/capture_decision/capture_intent **入口設 suppress=true、出口 restore**（整個 tracer 觀測期 RNG-neutral，最省心；但真實 decision 的 rank 在 capture 之外故不受影響）。implementer 定精準 vs 入口包。

## invariant 守
- **★全量暫態可觀測性（本 fix 就是修它的最深違反）**：tracer 額外工作 RNG-neutral → 換 specimen 零軌跡影響 → 真正非侵入。
- **determinism 保 + 真實世界不變**：suppress 只包 tracer 額外呼叫，真實 rank/dispatch 的 noise 消耗不動 → 非-specimen 世界軌跡與「無 tracer」bit-identical。

## 驗收法（measurer，★操作定義=不變量本身）
1. **★confound 消除（headline）**：同 seed force_full_hd，`SPECIMEN_TEAM_ID=A` vs `=B` vs 無-specimen 三跑 → **除 SpecimenTracer entries 外，世界狀態/所有隊軌跡（含 Team26 flip 數）byte-identical**。三組 flip 數一致（不再 0/71/88）＝confound 真除。
2. **★中性世界真相（blueprint #2，release 真門檻）**：confound 修後，在**非-specimen（真實）世界**重驗 desperation A/B/A-2 是否真有效——**尤其 thrash 在真實世界到底消沒消**（Team26 中性 56 次擾動前圖像存疑）。這才是 release 綠，非擾動世界綠。
3. 不回歸：determinism；憲法 sites 不變（tracer 純觀測，零新 try_set）。

## dispatch 註（R② CLEAN 後）
- **在哪**：`specimen_tracer.gd` 是 infra（已 merged main）→ 新分支或直接 main-infra 修（systems 判；建議獨立小分支 `feat/specimen-rng-confound-fix`，快 merge，因它擋一切）。
- R②：suppress scope 是否精準（只包 tracer 額外呼叫、不動真實 rank）？稽核有無漏的 observe_velocity/randf 路？
- **★這修完擋一切解除**：desperation release / A-3 / 死隊獵殺 全等此。完成判定 = systems + reviewer/QA + measurer 中性世界重驗。
