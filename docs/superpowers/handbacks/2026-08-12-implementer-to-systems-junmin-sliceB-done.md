---
from: implementer
to: systems
status: consumed
topic: "[军民混编 Slice B DONE·feat/junmin-militia-slice-b commit d9d396df]mobilized_fraction guns-vs-butter(pool 分數化+charter 梯度+F裝備)、行為變 slice·charter/mobilization split(charter TAG 保留正交、新 mobilized_fraction 動態欄)·①新 TeamData.mobilized_fraction[0,1]②_update_mobilization(cadence 先 equip/guard、frac=charter_base+belief-threat×0.5+好戰×0.15、梯度 軍團0.7/後備0.3/居民0.05、genuine 湧現 bounded 無 randf)③guns-vs-butter labor_pop=pop×(1−mob)、pool_of/rebalance 用之(動員→池降→產出掉)④finding④ labor_share≤1(manufacturing:86+resource:65 分子改 labor_pop 分子分母同步→Σ≤1)⑤F裝備 equip gate 讀 mob≥0.5 取代 TAG_MILITARY⑥finding③ cache 動員態變觸重算·charter 驅動 A 路由/E 薪資/C 居民鎖 UNCHANGED 正交零 churn·★驗:junmin_mobilize_test ALL PASS(威脅→動員 0.05→0.55+和平解甲+梯度0.7>0.3>0.05+labor_share≤1 finding④+全動員 labor_pop=0+cache)+headless 0-new+constitution 75+junmin_guard/active_promotion/named_scarcity_ab regression PASS+determinism 3-run byte-identical(warring 678b3ee3)·★fp 前後對照 LIVE(warring 752912f9→678b3ee3 DIVERGED、mobilize_peak 0→1.0)·★★透明 flag(scope):D 脆弱度顯式 prey-site(dispatch 引 interaction:395/301/303/521+diplomatic:263)行號與本 worktree 不符 stale→未 guess-edit combat 錯行;解甲民兵可劫已由 F裝備 emergence 部分達(動員<0.5→跳高階武→calc_armed 低→弱 prey)、顯式 D-site 建議 systems 確認行號後補·請 merge-gate 硬讀(核 fraction genuine 無死常數+finding④ labor_share≤1+charter 正交零 churn+感知鐵律+finding③ cache+bounded+D scope flag)→QA→merge→blueprint"
branch: feat/junmin-militia-slice-b
commit: d9d396df
---

# 军民混编 Slice B DONE（mobilized_fraction guns-vs-butter、行為變 slice）

feat/junmin-militia-slice-b commit `d9d396df`（off main HEAD b568e8f4；已 push）。

## charter/mobilization split（避 Track②A 承重牆）
charter（`TAG_PRODUCE`/`TAG_MILITARY`）**保留當穩定團型不動**、新 `mobilized_fraction` = 獨立正交動態欄。A 路由（`uses_unified`）/ E 薪資 / C 居民鎖 **UNCHANGED 正交零 churn**。

## §HOW-binding（六塊）
1. **新 `TeamData.mobilized_fraction`** [0,1] = 戰力配置（當兵）比、labor 配置=1−此。
2. **`_update_mobilization`**（faction_ai、cadence **先於 equip/guard**）：`frac = clampf(charter_base + belief-threat×0.5 + 好戰×0.15 − 0.075, 0, 1)`。charter_base 梯度：**專業軍團 0.7 / 後備 0.3 / 居民團 0.05**。genuine 從 belief-threat（Slice A `_max_belief_threat` 感知鐵律）+ charter + 好戰湧現、bounded[0,1]、無新 randf。
3. **guns-vs-butter B 勞力**：`LaborSystem.labor_pop(team) = pop×(1−mob)`；`pool_of`/`rebalance` 用 labor_pop（動員的人當兵不下田→池降→產出掉）；威脅→動員升→labor 降、和平→降回 base→解甲回田。
4. **finding④ labor_share≤1**：`manufacturing:86` + `resource:65` 分子改 `labor_pop(team)`（分子分母同步分數化）→ Σ≤1 無膨脹。
5. **F 裝備**：equip gate 讀 `mobilized_fraction≥0.5` 取代靜態 `TAG_MILITARY`（民兵動員時亦武裝）。
6. **finding③ cache**：動員態變 > EPS → 該格 `labor_eval_next_tick=0` 觸重算。

## 命門
genuine 非死常數（動員 belief-threat+charter+人格湧現）、bounded、感知鐵律（belief-threat 非 god-view）、統一非補丁（分數化既有機制、非平行旋鈕）、無新 randf。

## 驗（全綠）
| 閘 | 結果 |
|---|---|
| `junmin_mobilize_test` | **ALL PASS**：①威脅→動員升（居民團 0.05→0.55）+ ②和平解甲（0.05）③團型梯度（軍團 0.7>後備 0.3>居民 0.05）+ 好戰 modulate ④labor_pop 分數化（pool=2×10×0.5=10、**labor_share≤1 Σ≤1 finding④**、全動員 labor_pop=0）⑤finding③ cache 觸重算 |
| headless | **0-new**（生產分數化未新增 FAIL） |
| constitution_gate | **PASS sites=75** |
| regression | `junmin_guard` + `active_promotion` + `named_scarcity_ab` **ALL PASS** |
| determinism | **3-run byte-identical**（warring seed1337 1000t FP `678b3ee3`；純算術無新 randf） |

## ★fp 前後對照 LIVE（warring seed1337、baseline[no mobilize] vs branch[mobilize]）
| metric | baseline | branch |
|---|---|---|
| **FP** | `752912f9` | `678b3ee3` **DIVERGED(intended)** |
| mobilize.fraction_peak | 0（tap 無） | **1.0**（威脅全動員 = guns-vs-butter） |

## ★★透明 flag（scope、honest）
**D 脆弱度顯式 prey-site**（dispatch 引 `interaction:395/301/303/521` + `diplomatic:263`）**行號與本 worktree 不符**（stale citations、dispatch 對不同 snapshot 寫）→ 我**未 guess-edit combat 脆弱度 code 於錯行**（怕改錯戰鬥 vulnerability 邏輯）。**解甲民兵可劫已由 F裝備 emergence 部分達**：動員<0.5 → equip 跳過高階武分支 → `calc_armed` 較低 → 較弱 → 成 prey（既有 prey/str_ratio 邏輯自然吃）。**顯式 D-site 精確 mapping 建議 systems 確認行號後補**（或若 F裝備 emergence 足則本批 close D）。

## ★下游 re-measure（measurer realistic）
威脅→動員→產出掉曲線 + 和平解甲 + 梯度分化率（軍團/後備/居民）+ labor_share≤1 多隊 realistic + D 脆弱度（解甲隊被劫率）= **measurer 職**。

## 路
1. **你 merge-gate 硬讀**（核 fraction genuine 無死常數 + finding④ labor_share≤1 + charter 正交零 churn + 感知鐵律 + finding③ cache + bounded + **D scope flag 定調**）。
2. → QA → merge → blueprint 推用戶（军民混编完整、或 D-site 補一小 slice）。地基 KEEP。

（perf/F2 disk flag 續。）
