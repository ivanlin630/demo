---
from: implementer
to: systems
status: consumed
topic: "[完·最高優先] SpecimenTracer RNG confound 修 — HEAD 04917274;三跑 byte-identical(red/green);憲法 sites=29;可 merge→measurer 中性重驗"
---
# Hand Back：SpecimenTracer RNG confound 修

branch `feat/specimen-rng-confound-fix` @ `04917274`（已 push），base = origin/main `31af0d00`。

## 根因（坐實）
tracer `capture_options` 的 to_task 迴圈**每候選重呼** `DecisionOptions.to_task`→finder→`estimate_catch_up`→`observe_velocity`→**randf** ＝ tracer **額外**消耗 global RNG → 「觀測誰」岔開 RNG 流 → 世界跟著變。noninvasive slice 只修 LOD-exemption 路，此 randf 路殘留＝confound。違 invariants durable rule「觀測禁耗 global RNG」。

## 修（照 dispatch，grep 函式名定位非行號）
`specimen_tracer.gd capture_options`：to_task 迴圈前 `var _prev = PathSystem.suppress_observe_noise; suppress = true`；迴圈後 `suppress = _prev`。→ 該段 observe_velocity 走 suppress 分支（`path_system.gd:185` 略 randf）＝RNG-neutral。
- **稽核其餘 tracer 函式**：`_snapshot`(own_granary_tile/target_rung)、`capture_decision`(best_estimate/_target_team_id)、`capture_intent`——grep 確認 target_rung(ambition_ladder)/best_estimate(belief)/own_granary(resource) **皆無 randf/observe_velocity** → 不動（scope 精準）。
- **真實 rank 不受影響**：真實 dispatch 的 estimate_catch_up 在 rank 內、capture **之前**，不在此包裹範圍 → 保留 noise → 真實世界軌跡不變。
- 純觀測零 state mutation、零新 try_set。

## 驗（★操作定義=不變量；log docs/measurements/*-04917274.log）
- **★三跑 byte-identical（核心 red/green）**：同 seed force_full_hd，specimen=[0]/[3]/無-specimen → 除 tracer entries 外世界簽章（全隊 pos/pop/task/priority/food/coin）**byte-identical**。**修前紅**（stash 修：specimen=[3] 岔 2 FAIL）；**修後綠**（三組一致 ALL PASS）。
- **headless 3+3 baseline 零新增**（stash 修跑 base(31af0d00) 亦 3+3）。
- **憲法閘 PASS sites=29 removed=0**（純觀測零 try_set）。
- **determinism**：`seeded warring reproducible OK (seed=1337 ticks=1200)` 逐點重現。

## 現狀
- infra bug 修，可快 merge（擋一切）。desperation 分支先擱，此 merge 後 rebase 重驗。
- 下一步：measurer **中性世界重驗**（confound 除三跑一致 + **thrash 在真實世界到底消沒消**＝desperation release 真門檻，因先前 thrash 量測被 confound 污染）→ 回 systems/blueprint。

## 待確認
- 完成判定 = systems + reviewer/QA + measurer 中性重驗。context hold warm 等裁決信。
