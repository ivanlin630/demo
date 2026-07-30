---
type: spec
owner: systems
topic: founding-completion fix — active-construction persist floor（non-freeze）HOW
status: ready-for-R2
---

# HOW spec：founding-completion fix — active-construction persist floor

> **坐實根**（和平床 bed dump 0b6523db pin）：remote founding 子隊 `construct.stall=29101` / `complete_build=0`（vs own-outpost `complete_upgrade_facility=6`）。stall samples **`ct_task=覓食/外交` `ct_reason=unified` `ticks_left>0`**＝**argmax try_set 搶班**（`_decide_unified` 每 cadence 把施工隊改 task）**非 timeout**（timeout_cancel=0/resume.attempt=0）。
> **cold-start 機制**：`persist_strength._progress`（TASK_BUILD）= `(total−ticks_left)/total` → **施工起點 progress≈0 → base_persist≈0 < PERSIST_HOLD_THRESHOLD(0.1)** → persist.hold gate（task_arbiter:64-70）不 fire → argmax routine 搶班（覓食/外交 @PRIO_DISPATCH）**不被擋** → 施工隊被拉走 → progress 永不累積 → 回不到 threshold＝**惡性循環**。own-outpost 升級 owner 在場撐過空窗完工；remote 子隊被搶去覓食/外交、`resume.attempt=0` 沒召回 → 0 完工。
> **★blueprint steer**：fix＝用**已 RELEASED non-freeze 持守 hold 罩住施工隊**（persist.hold gate 是 util-bias 非 skip-reeval，世界照演化），**別追 skip-reeval latch 的凍**（死路）。硬約束＝**世界不凍 invariant（latch 凍過＝紅線）**。

## 1. fix：active-construction persist floor（persist_strength.gd）
施工中隊（`current_task == TASK_BUILD` AND 其施工 tile `construction_ticks_left > 0`）persist_eff **floor 到 ≥ PERSIST_HOLD_THRESHOLD + margin**（新常數 `CONSTRUCTION_ACTIVE_FLOOR`，e.g. 0.15 > 0.1）：
- `persist_eff = max(computed_persist_eff, CONSTRUCTION_ACTIVE_FLOOR)`（computed = 現 base_persist × safe_factor）。
- 效果：cold-start（progress≈0）也 persist ≥ threshold → **persist.hold gate 擋 routine argmax 搶班**（覓食/外交 @PRIO_DISPATCH < THREAT）→ 施工隊留 TASK_BUILD → `_tick_construction` 進度累積 → 完工。progress 累積後 base 自然升過 floor（floor 只保護 cold-start 空窗）。

## 2. ★non-freeze 保證（紅線，latch 凍過）
floor **不是 skip-reeval**——是 persist.hold util-bias gate 的最小值。世界照演化：
- **只 floor active-construction 隊**（一小子集）；非施工隊 persist 照算、照演化。
- **≥PRIO_THREAT bypass 保留**（task_arbiter:64-70 `priority < PRIO_THREAT and team.task_priority < PRIO_THREAT`）：crisis/survival/threat/player 照打斷施工（真餓死照放手求生＝team14 crisis 路徑保留、非靠 persist 降到 floor 下）。
- **完成/timeout 釋放**：施工完 → 非 TASK_BUILD → floor 消 → 正常。
- **re-eval 照跑**（非 skip）：施工隊每 cadence 照 re-eval、argmax 照算，只 try_set 被 persist.hold 擋 → 留 task。≠ latch 的 skip-reeval（那個停 re-eval → 停演化 → 凍）。

## 3. safe_factor / team14 交互（R² 重點）
- floor 是**最小值**；safe_factor 可把 persist 升過 floor（糧充裕）。糧見底時 base×safe_factor→0，但 floor 撐住 routine 保護。
- **team14（餓死施工隊該放手）由 crisis 路徑處理**（survival @≥THREAT bypass persist.hold），**非**靠 persist 降到 floor 下——floor 只擋 routine 覓食/外交搶班、不擋 crisis。∴ floor 不破 team14（真餓死照放）。
- ★R² judge：floor 該不該 safe_factor-scaled（`max(computed, FLOOR × safe_factor)`＝糧見底 floor 也降 → routine 也放手）vs 硬 floor（crisis 才放）？我傾向**硬 floor**（cold-start 保護是 pipeline 完整性；routine 覓食不該打斷剛開工的 build；crisis 自有 bypass）。

## 4. 憲法對齊（★人格 WEIGH 不 GATE 疑點，R² judge）
- floor＝**construction pipeline 完整性保證**（routine argmax 搶班不該讓 active build 永不完工＝機制破洞），非 gate 人格決策。persona 仍在 floor **之上** modulate persist（固執撐更久）；crisis 仍 bypass。
- ★但 floor 對所有人格給同一最小保護＝弱化 cold-start 的人格分化。R² judge：這算 WEIGH-not-GATE 違反、還是 pipeline 完整性合理例外（如 crisis handling 也不分人格）？替代：floor × lean（人格仍分化但可能低 lean 隊不過 threshold＝不保證完工）——**trade-off：保證完工 vs 純人格分化**。

## 5. TDD（★★不凍紅線 + 完工 + team14 保留）
- **★★不凍（latch 紅線）**：seed1337 6mo `attrition 非 →0`（latch 凍 attrition→0）+ **世界 churn**（Δteams/pop 逐月變、非凍）+ 三跑 determinism byte-identical。
- **founding 完工**：和平床 `complete_build > 0`（cold-start 保護後 remote founding 真完工）+ `construct.stall` 大降。
- **own-outpost 升級不退化**：`complete_upgrade_facility` 仍 ≥ baseline（6）。
- **★crisis 照打斷施工**（team14 保留）：施工隊真餓（survival @≥THREAT）→ 照放手求生（單測：construction 隊 food→0 → crisis fire → 離 TASK_BUILD）。
- 純算術零 RNG（persist_strength 零 RNG 延續）；constitution 74 + observability PASS + headless 0-new。

## 6. 交付
→ R²（★異質：不凍紅線 floor 真不凍否/floor-vs-safe_factor scaling/人格 WEIGH 不 GATE floor 判/crisis bypass 真保留/cold-start floor 值）→ implementer（persist_strength.gd floor + TDD）→ measurer 和平床 re-run（complete_build>0 + 不凍 + stall 降）→ QA。★execution-verified：founding 真完工 + 世界不凍 + crisis 照打斷。
