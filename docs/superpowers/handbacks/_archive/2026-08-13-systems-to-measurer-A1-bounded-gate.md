---
from: systems
to: measurer
status: consumed
topic: "[A1 merge gate:realistic bounded 四象限 + ★紮營真 fire/佔據率升(branch feat/survival-access-a1 commit ac8f5418)·systems diff review 已過(禁crank雙防線+感知鐵律proximate+常數CAP1.5 bound/URGENCY_DAYS導PROVISION_DAYS錨)·implementer unit-test 四象限 PASS 但 unit≠realistic·★量測兩面(branch 對 baseline main):【anti-crank 面 bounded 四象限 machine-demonstrate】①有家/已resident→不紮(marg≈0 or gate)②富流浪 food_days≥10→urgency0→camp_drive 0 不紮③瀕餓+肥沃平原→camp_drive 高→紮④瀕餓+低產farmable(森林高pop marg→0)→camp_drive 0 不紮(★anti-crank marginal 路徑、非純mountain[那個走gate])·【arc-目標 面=A1 真意義】★紮營真 fire(baseline camp.fire=0→branch>0?)+佔據率(baseline月底8.6%→顯著升?)+分化(瀕餓平原團紮/富流浪不紮/有家不動=湧現非全紮或全不紮)·CAMP_MARGINAL_CAP=1.5 bounded-verify(camp_drive 不超 CAP、無團因 crank 恆紮)·★注 implementer flag:warring 1000t camp 路徑可能 dormant→需 vagrant/founding 情境床(流浪團+可耕空地)才 exercise camp、選對床·determinism:branch 3-run byte-identical(implementer 報 warring 678b3ee3、你複);camp fire 後 fp intended-change·官方 SpecimenDumpHelper 勿手設 team_ids、先讀既有 dump·evidence-only 禁預設·output=四象限+紮營fire/佔據率 綠/紅→綠我 merge dispatch A2/A3、紅回 implementer·地基 KEEP"
---

# A1 merge gate — realistic bounded 四象限 + ★紮營真 fire/佔據率升

branch `feat/survival-access-a1`（ac8f5418）。systems diff review 已過（禁 crank 雙防線 + 感知鐵律 proximate observable + 常數 CAP 1.5 bound/URGENCY_DAYS 導 PROVISION_DAYS 錨）。implementer unit-test 四象限 PASS 但 **unit≠realistic**。branch 對 baseline main。evidence-only、禁預設。

## ★量測兩面（★兩面都要綠）

### 面1：anti-crank bounded 四象限 machine-demonstrate
1. **有家/已 resident** → 不紮（marg≈0 or gate）。
2. **富流浪**（food_days≥10）→ urgency=0 → camp_drive 0 不紮。
3. **瀕餓+肥沃平原** → camp_drive 高 → 紮。
4. **瀕餓+低產 farmable**（森林高 pop marg→0）→ camp_drive 0 不紮（★anti-crank marginal 路徑；純 mountain 走 gate 非此）。

### 面2：arc-目標（A1 真意義、別只驗 bounded 忘了目標）
- ★**紮營真 fire**：baseline `camp.fire=0` → branch **>0**？（A1 沒讓紮營 fire=白做）。
- **佔據率**：baseline 月底 8.6% → **顯著升**？
- **分化**（湧現非全紮/全不紮）：瀕餓平原團紮 / 富流浪不紮 / 有家不動。

### bounded-verify
`CAMP_MARGINAL_CAP=1.5`：camp_drive 不超 CAP、無團因 crank 恆紮。

## ★床選（implementer flag）
warring 1000t camp 路徑可能 **dormant** → 需 **vagrant/founding 情境床**（流浪團 + 可耕空地）才 exercise camp。選對床。

## determinism
branch 3-run byte-identical（implementer 報 warring `678b3ee3`、你複）；camp fire 後 fp **intended-change**。

## 紀律
官方 `SpecimenDumpHelper` 勿手設 `specimen_team_ids`（[[feedback_observer_no_global_rng]]）。先讀既有 dump。
output = 四象限 + 紮營 fire/佔據率 **綠/紅** → 綠我 merge + dispatch A2/A3、紅回 implementer。地基 KEEP。
