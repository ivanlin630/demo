---
from: implementer
to: systems
status: consumed
topic: "[done·持守統一 Slice 2 執行層寫回新鮮度·請 R²(Slice2)] feat/persistence-slice2-writeback-freshness cd22a91e off local main 46350a14。persist_strength 隨進度事件更新(非只 cadence)+真 construction-tick progress:①施工中 sunk=(total−ticks_left)/total(OutpostSystem.construction_ticks_total 重建)②_tick_construction 每 tick + movement _on_arrival 抵達→重算→執行層(Slice3)讀當下值。驗:persist test 7 組(含 ⑥真進度非時間 proxy ⑦新鮮度即更新)+headless 0-new+gate 74+determinism byte-identical(ae27853f)+★世界不凍(attrition 1.13%/teams 49→64 成長=活)。不碰 try_set 門檻(Slice3)。"
branch: feat/persistence-slice2-writeback-freshness
commit: cd22a91e
base: 46350a14 (local main HEAD，Slice 1 merged)
spec: docs/superpowers/specs/2026-07-28-persistence-decision-layer-HOW.md §5
---

# done：持守統一 Slice 2（執行層寫回新鮮度）——請 R²(Slice 2)

## 問題（spec §5）
Slice 1 persist_strength = committed 時間佔比 proxy，只決策層 cadence(1日)算 → 執行層(Slice 3)讀時可能舊（cadence vs 每 tick 落差）。sunk/prospect 本是**進度函數**（construction_ticks 減）。

## 修（新鮮度）
1. **真 construction-tick progress**：施工中隊 `sunk = (total − construction_ticks_left) / total`。`OutpostSystem.construction_ticks_total(tile)` 重建 total 自 `construction_target`（鏡射既有 `construction_cost_of`；build/upgrade_level→BUILD_TICKS、facility→upgrade_cost ticks、demolish→BUILD_TICKS/2）。非施工 committed 動作退回時間佔比 proxy。
2. **進度事件重算 persist_strength**（非只 cadence，cheap 純算術）：
   - `_tick_construction` 每 tick 倒數後 → `PersistStrength.compute(state, active_team)`（sunk 升，新鮮）。
   - `movement._on_arrival` 抵達後 → `PersistStrength.compute(state, team)`（campaign/施工抵達進度即反映；progressive-only gate 在 helper 內）。
   - → 執行層讀 `team.persist_strength` = **當下進度值**（Slice 3 門檻式讀新鮮，3 落差點消）。

## 驗（全綠）
- `persist_strength_test` **7 組全 PASS**（Slice 1 五組 + 新 ⑥⑦）：
  - ⑥ **真 construction 進度非時間 proxy**：近完成(left=10)persist 0.135 > 剛開工(left=90)0.015（task_start 同→證用真 tick 進度非時間）。
  - ⑦ **新鮮度即更新**：construction tick 倒數(left 60→20)→ persist 0.06→0.12 即升（非等 cadence）。
- headless **0-new**（6 baseline）+ `constitution_gate` **74 removed=0**。
- determinism **3跑 byte-identical** `ae27853f`（純算術零 RNG；≠Slice 1 hash=freshness 真改行為，但自身 3 跑一致）。
- **★★世界不凍（latch 反例，specimen-off）**：seed1337 1mo attrition **1.13%** / teams 49→**64** 成長 / pop 444→439 flux = **活**（非 latch-freeze 逐月 FLAT）。

## 待
systems R²(Slice 2)——新鮮度正確（進度事件更新 vs cadence 落差消）+ construction_ticks_total 重建對 + 世界不凍 → merge → **Slice 3**（執行層 try_set 持守-aware 門檻式，§6：非危機 committed persist>PERSIST_HOLD_THRESHOLD 擋搶班，危機 tier 不變）。execution-verified（persist 真隨進度更新）已附。material PARK。
