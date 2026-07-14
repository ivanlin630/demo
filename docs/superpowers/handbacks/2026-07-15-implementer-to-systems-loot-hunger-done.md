---
from: implementer
to: systems
status: consumed
topic: "[完] 絕境掠奪對準糧源 hunger-weighted — HEAD f8821ada;TDD 5綠;憲法 sites=29;seeded warring byte-identical base(零退化)；★food-weighting 在中性世界 inert 觀察待 measurer 驗"
---
# Hand Back：絕境掠奪對準糧源（hunger-weighted prey）

branch `feat/loot-hunger-targeting` @ `f8821ada`（已 push），base = origin/main `a3009f74`。

## 實作（照 spec，單一連續加權，2 commit）
`faction_ai_system.gd _find_weakest_prey` 排序改：
- beatability 硬門檻 `pop_est < team.population×0.7` **不動**。
- 可打候選內單一連續 `prey_score = pop_est − FOOD_PULL×hunger×(food_est/FOOD_EST_NORM)`，**minimize**。
  - `hunger = clampf((DESPERATION_DAYS − looter.food_days)/DESPERATION_DAYS, 0, 1)`（連續，sated→0）。
  - `FOOD_PULL=1.0` / `FOOD_EST_NORM=100.0`（TEST VALUE，deterministic）。
- **sated(hunger=0)→純 pop_est=weakest**（strategic raid 零退化）。**無 `if food_days<X` 切主鍵**（純連續加權）。
- `food_est` 用 `bel.get("food_est")`（belief best_estimate，可失真/stale，非 god-view，延續既有讀法）；不加 food 硬濾（②c 血訓）。

## 前提查證（承 A-2 belief-food gap 教訓）
先驗 `bel.food_est` 存在——**存在**：`_find_weakest_prey` 既有已讀 `bel.get("food_est",0.0)`，來源 `state.team_intel`（team_intel/message claim，非 vision-only）。無 gap（A-2 gap 是 vision-only host 常無 food claim；此處延續既有 belief 讀法，一致）。

## 驗（TDD + sanity；log docs/measurements/*-f8821ada.log）
- **TDD 5/5 PASS**：飢餓→選糧多可打隊；sated→選最弱（零退化）；連續性（crossover emergent 食日≈1.8，非硬閘 DESPERATION=3）。
- **憲法閘 sites=29 removed=0**（既有 finder 內排序改，零新 try_set）。
- **headless 3+3 baseline 零新增**（stash 跑 base 亦 3+3）。
- **determinism / 零退化**：`seeded warring reproducible OK`；且**我的 final byte-identical base**（`teams:64 factions:8 established:0 pop:444`）。

## ★透明觀察（待 measurer 中性重驗確認，非 blocker）
seeded warring final 與 base **完全相同** → 在該世界 food-weighting **多半 inert**：多數 belief 是 vision-only（VisionSystem 只寫 population_est+resource_scale，**無 food_est**）→ `bel.food_est` 預設 0 → `food_norm=0` → `prey_score=pop_est`＝base 行為。food-weighting 只在 belief 有 food_est（team_intel/message 傳播的 richer intel）時 fire。
→ **measurer 中性重驗須確認**：絕境 looter 對 food-rich prey **是否真有 food_est belief**（有→掠奪對準糧 food 回升；若普遍無→fix 對其 inert，可能需 food_est 傳播是另一 slice）。這是效果驗證，非本 slice 正確性問題（公式正確，TDD 證）。

## 完成後（measurer 中性重跑）
day24-26 殘留 thrash 消 + 絕境 looter 掠奪成功 food 真回升 → QA 故事複判 → blueprint 批 merge。

## 待確認
- 上述 §透明觀察（food-weighting inert 於 vision-only belief）請 systems/measurer 過目。完成判定 = systems + reviewer/QA + measurer 中性重驗。context hold warm 等裁決信。
