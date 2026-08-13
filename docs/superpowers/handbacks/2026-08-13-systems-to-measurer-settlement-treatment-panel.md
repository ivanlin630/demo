---
from: systems
to: measurer
status: open
topic: "[安家報酬對照實驗=9居民福祉面板(用戶問『搬進據點的team過得如何』、blueprint 升級成 treatment-vs-control)·併入在跑 9居民量測(ac568c7c/e4b3bbff 未回部分)、SUPERSEDE 舊 9resident-income-attribution·★framing:9居民=世界唯一 treatment group、福祉=接入 arc ROI 直接證據——安家若也慘→光修接入不夠(需 production 層也修)、安家若好→接入-fix 就是 ROI(讓多數團接到富池)·team47(21.5→28.2 thriving)已知 1 點=安家可行存在證·★panel(per-team 9隻全列):①pop 軌跡逐月(餓死/折損?)②所在村 granary 餘額軌跡 per-village(granary 總體+2.5% but 可能集中少數村、要拆村看各村夠不夠)③food security days=granary_food÷(0.8×pop)④地形(tile.terrain plains/forest/mountain=承載力對照、REGEN plains8/forest3/mtn0.5)⑤residency-onset tick(第一次 has_own_outpost=true;前22天0 resident=只活後半月?)·★對照組=wanderer cohort(nonresident)死亡率+pop 軌跡→treatment effect=安家 vs 流浪生存差·★bed 已捕大部分(resident_detail per-team granary_food/team_food/pop/food_days、bed 日 census):需加 terrain(resident tile.terrain)+residency-onset tick+wanderer 死亡軌跡·官方 SpecimenDumpHelper 勿手設 team_ids·evidence-only 禁 fix 禁預設·output=9隻 panel+對照數字→systems 收口→blueprint 答用戶+定接入 arc ROI(安家夠不夠)·地基 KEEP"
---

# 安家報酬對照實驗 — 9 居民福祉面板（treatment-vs-control）

用戶問「搬進據點的 team 過得如何」→ blueprint 升級成對照實驗。**併入在跑 9 居民量測**（`ac568c7c`/`e4b3bbff` 未回部分），SUPERSEDE 舊 `9resident-income-attribution`。evidence-only、禁 fix、禁預設。

## ★framing（為何這實驗關鍵）
9 居民 = **世界唯一 treatment group**（其餘 91% 流浪）。其福祉 = **接入 arc ROI 直接證據**：
- 安家若也慘 → 光修接入不夠（production 層也要修）。
- 安家若好 → **接入-fix 就是 ROI**（訂正故事說世界富、多數接不到 → 讓多數接到富池就解）。
- team47（21.5→28.2 thriving）= 已知 1 點=**安家可行存在證**；但要看 9 隻全貌。

## ★panel（per-team、9 隻全列）
1. **pop 軌跡逐月**：有無餓死/折損？（安家的活得比流浪久嗎）
2. **所在村 granary 餘額軌跡 per-village**：granary 總體 +2.5% **但可能集中少數村** → 拆村看各村倉夠不夠（team47 村 vs 其餘村）。
3. **food security days** = `granary_food ÷ (0.8 × pop)`（能撐幾天）。
4. **地形**：resident tile `tile.terrain`（plains/forest/mountain）= 承載力對照（REGEN plains 8 / forest 3 / mtn 0.5、break-even 人口 10/3.75/0.6）。
5. **residency-onset tick**：第一次 `has_own_outpost=true` 的 tick（前 22 天 0 resident → 這 9 隻是**只活了後半月**才安家？還是老早安家？定「安家時長」）。

## ★對照組（treatment effect）
**wanderer cohort（nonresident）死亡率 + pop 軌跡** → 「安家 vs 流浪」生存差 = **treatment effect**。bed 已有 nonresident 聚合（食物_days_avg 等），需補**死亡/pop 軌跡**對照。

## bed 現況（省你重造）
`phase3_longterm_story_audit_bed` 已捕：per-team `resident_detail`（`granary_food`/`team_food`/`pop`/`food_days`/`has_own_outpost`/`is_subteam`）+ 日 `_pool_census`。
**需加**：①resident tile `terrain`（`tile.terrain`）②residency-onset tick（首次 has_own_outpost）③wanderer 死亡軌跡對照。

## 紀律
官方 `SpecimenDumpHelper` 勿手設 `specimen_team_ids`（observer-neutrality [[feedback_observer_no_global_rng]]）。
output = 9 隻 panel + 對照數字 → systems 收口 → blueprint 答用戶 + **定接入 arc ROI（安家到底夠不夠）**。地基 KEEP。
