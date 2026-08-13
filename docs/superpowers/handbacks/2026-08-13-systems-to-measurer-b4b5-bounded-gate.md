---
from: systems
to: measurer
status: open
topic: "[B4+B5 merge gate:realistic bounded 量測(branch feat/survival-prod-b4b5、B4=46342d41 B5=203aab2c)·implementer unit-test 已過 bounded 兩象限、但 unit≠realistic fire([[feedback_measure_peroption_util]] extra_lesson:realistic 床驗真 emerge 非只構造極端)·★量測(branch worktree 對 baseline main):①B4 新居民首3天採糧非硬零=settle 的團 onset 後首3天 labor_mult(gather:food)>0(baseline 硬零 57-80%→branch 顯著降)②B5 bounded 兩象限 machine-demonstrate:飢餓村(food_days<5)gather:food labor share/weight 升→勞力回糧 + 吃飽村(food_days≥5)照舊採 material(escalation=1 不變)=兩象限都 demo 到、非只一邊③FAMINE_NEED_GAIN=2.0 bounded-verify:食飽村 food need 真沒變(escalation 精確1.0)、瀕餓放大有界(×3 非失控)、無新村因 escalation 反而 starve(over-correction 檢查)④端到端(可選、branch 1月窗):居民 food-security 脫0天升? material 產出有無被過度犧牲(bounded=material 不歸零、只飢餓時讓位)·★determinism:branch peaceful 3-run byte-identical(implementer 報 48554984)、你獨立複；warring 有意 fp 變(need→labor→gather)標 intended-change·官方 SpecimenDumpHelper 勿手設 team_ids、先讀既有 dump·evidence-only 禁預設·output=兩象限 machine-demonstrate 綠/紅→綠我 merge dispatch A1、紅回 implementer·地基 KEEP"
---

# B4+B5 merge gate — realistic bounded 量測

branch `feat/survival-prod-b4b5`（B4=46342d41 B5=203aab2c）。implementer unit-test 已過 bounded 兩象限、但 **unit≠realistic fire**（[[feedback_measure_peroption_util_before_decision_claim]] extra_lesson：realistic 床驗真 emerge、非只構造極端條件）。branch worktree 對 baseline main 量測。evidence-only、禁預設。

## ★量測（§4 硬 gate）
1. **B4 新居民首 3 天採糧非硬零**：settle 的團 onset 後首 3 天 `labor_mult(gather:food)>0`（baseline 硬零 57-80% → branch 顯著降）。
2. **B5 bounded 兩象限 machine-demonstrate**（★兩邊都要 demo、非只一邊）：
   - **飢餓村**（food_days<5）：`gather:food` labor share/weight 升 → **勞力回糧**。
   - **吃飽村**（food_days≥5）：**照舊採 material**（escalation=1.0 不變、不被誤傷）。
3. **FAMINE_NEED_GAIN=2.0 bounded-verify**：吃飽村 food need 精確不變（escalation=1.0）、瀕餓放大有界（×3 非失控）、**over-correction 檢查**（無村因 escalation 反而排擠掉必要 material 而崩）。
4. **端到端**（可選、branch 1 月窗）：居民 food-security 脫 0 天升？material 產出未被過度犧牲（bounded=material 不歸零、只飢餓時讓位）。

## determinism
branch peaceful 3-run byte-identical（implementer 報 FP `48554984`、你獨立複）；warring 有意 fp 變（need→labor→gather）= **intended-change** 標。

## 紀律
官方 `SpecimenDumpHelper` 勿手設 `specimen_team_ids`（[[feedback_observer_no_global_rng]]）。先讀既有 dump。
output = 兩象限 machine-demonstrate **綠/紅** → 綠我 merge + dispatch A1、紅回 implementer。地基 KEEP。
