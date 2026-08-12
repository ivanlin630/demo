---
from: systems
to: blueprint
status: consumed
topic: "[②军民混编/民兵動員 grounding 現況表 DONE(measure-first 硬讀 file:line 非 inference、7×over-claim 教訓)·★核心發現:三 ratio 各自為政+勞力池二元 by-tag+団型建點二元定死、★『全動員/mobiliz 機制不存在』(grep 零命中=arc 全新建非改現有)·現況表(owner/規則/消費者/能否表達民兵分數):①armed_anon_ratio(equipment_system:62-73、=min(anon,武器庫存/UNITS)/anon=武器庫存推 equippability、消費 encounter/npc_combat/faction_ai:3281 戰力、部分能表達但 inventory-driven 非動員選擇[武器夠就全上非抽多少去打])②guard_ratio(faction_ai:3069-3081、★硬編碼離散 task/threat/tag→0.1/0.15/0.2/0.35/0.4 clamp[.05,.5]=照妖鏡死常數族、消費 day_night:40 夜哨+sim_runner:442 rest、NO 只夜哨比 tag-gated 死常數只影響休息)③captive_guard_ratio(manpower_system:_decide_guard_ratio 連續 慎重×W+load×W、消費看守俘虜、NO 獨立域)④pool_of 勞力池(labor_system:23、★二元 by-tag TAG_PRODUCE→全 pop 算/其餘→0、消費生產 rebalance、NO 全有全無無法半兵半農)⑤団型(outpost_system:401-408 _auto_settle_builder、★二元 outpost_type civilian→TAG_PRODUCE/else→TAG_MILITARY 紮營時定死、消費 tag 全域 gate、NO 建點二元無混編梯度)⑥TASK_TRAIN(training_system anon tier 累積 exp tier-up、育成非動員抽離、部分)·★★統一缺口 5:①三 ratio 三 owner 三規則互不通②pool_of 二元無法表達 mobilizable 民兵分數③団型建點二元定死無混編梯度④無現有動員機制→guns-vs-butter 搬人力(勞力池↔戰力)不存在⑤guard_ratio 硬編碼離散 tag-gated 死常數=照妖鏡族(統一時連續化/人格化)·★★感知鐵律 flag(spec 必守):動員 trigger(威脅→動員)須讀 belief-threat 非 god-view;現 guard_ratio 用 _has_hostile_within(state,team,3)=需查掃真位置(god-view)or belief、統一模型 threat-trigger 必走 threat_assessment belief 路(同 threat-oracle arc)·★audit WHAT 對齊:收斂成一個団型驅動 mobilizable 分數(威脅時勞力池↔戰力搬=guns-vs-butter 真成本、和平解甲回田)、団型分級(專業軍團純軍/後備開墾團半兵半農/居民團民兵制)·統一非補丁鐵律:五散落收進一模型禁再加平行補丁·序:你 spec 統一 mobilizable 模型(基於此表)→R①/R²→build→驗(威脅→民兵動員抽勞力→產出掉+和平解甲+団型分化)·這輪只 grounding 完成·地基 KEEP"
---

# ②军民混编/民兵動員 grounding 現況表（measure-first 硬讀 file:line）

★這輪只 grounding。核心發現：**三 ratio 各自為政 + 勞力池二元 by-tag + 団型建點二元定死、且「全動員/mobiliz 機制不存在」（grep 零命中 = arc 全新建非改現有）**。

## 現況表（owner / 規則 / 消費者 / 能否表達民兵分數）
| 機制 | owner file:line | 規則 | 消費者 | 表達民兵分數? |
|---|---|---|---|---|
| **armed_anon_ratio** | equipment_system:62-73 `_update_anon_ratio` | `=min(anon, 武器庫存/UNITS)/anon` = **武器庫存推**(equippability) | encounter:249/1079、npc_combat:203/653、faction_ai:3281 戰力 | 部分——是戰力比但 **inventory-driven 非動員選擇**（武器夠就全上、非「抽多少去打」）|
| **guard_ratio** | faction_ai:3069-3081 `_update_guard_ratio` | ★**硬編碼離散** task/threat/tag → 0.1/0.15/0.2/0.35/0.4 clamp[.05,.5] | day_night:40 夜哨 + sim_runner:442 rest | NO——夜哨比、tag-gated **死常數**、只影響休息 |
| **captive_guard_ratio** | manpower_system:283 `_decide_guard_ratio` | 連續（慎重×W + load×W）| 看守俘虜（manpower:192/238）| NO——俘虜守衛、獨立域 |
| **pool_of（勞力池）** | labor_system:23 | ★**二元 by-tag**（TAG_PRODUCE→全 pop 算 / 其餘→0）| 生產 rebalance | NO——全有全無、無法「半兵半農」|
| **団型** | outpost_system:401-408 `_auto_settle_builder` | ★**二元**（outpost_type civilian→TAG_PRODUCE / else→TAG_MILITARY、紮營時定死）| tag 全域 gate | NO——建點二元、無混編梯度 |
| **TASK_TRAIN** | training_system | anon tier 累積 exp（tier-up）| anon tier 晉升 | 部分——育成（anon→強兵）非動員抽離 |
| **全動員/mobiliz** | **不存在**（grep 零命中）| — | — | NO——**無現有動員機制**（arc 新建）|

## ★★統一缺口 5
1. 三 ratio（armed_anon / guard / captive_guard）**三 owner 三規則互不通**。
2. pool_of 二元 by-tag → **無法表達 mobilizable 民兵分數**（半兵半農）。
3. 団型建點時二元定死（PRODUCE xor MILITARY）→ **無混編梯度**。
4. **無現有動員機制** → guns-vs-butter 搬人力（勞力池↔戰力）不存在。
5. guard_ratio 硬編碼離散 tag-gated **死常數 = 照妖鏡族**（統一時連續化/人格化）。

## ★★感知鐵律 flag（spec 必守）
動員 trigger（威脅→動員）須讀 **belief-threat 非 god-view**。現 guard_ratio 用 `_has_hostile_within(state, team, 3)` = 需查掃真位置（god-view）or belief；統一模型 threat-trigger 必走 `threat_assessment` belief 路（同 threat-oracle arc 精神）。

## ★audit WHAT 對齊（你 spec 收斂目標）
收斂成**一個団型驅動 mobilizable 分數**（威脅時勞力池↔戰力搬 = guns-vs-butter 真成本、和平解甲回田）、団型分級（專業軍團純軍拒屯兵 / 後備開墾團半兵半農 / 居民團民兵制主力勞力+小武裝防禦才召）。**統一非補丁鐵律**：五散落收進一模型、禁再加平行補丁。

序：你 spec 統一 mobilizable 模型（基於此表）→ R①/R² → build → 驗（威脅→民兵動員抽勞力→產出掉 guns-vs-butter + 和平解甲 + 団型分化）。地基 KEEP。
