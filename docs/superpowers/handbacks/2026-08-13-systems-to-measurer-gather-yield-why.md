---
from: systems
to: measurer
status: open
topic: "[gather-yield WHY:240x 同平原採集差真兇(blueprint GO、用戶線索收齊再裁 arc scope 的 missing clue)·problem:同 plains、team47 4.1/event vs team70 0.017/event(40次採僅0.67)vs team83 0.01(顆粒無收)=240x 差、定 binding 因子·★gather formula(resource_system:268)per-team 直測分項(不 code-guess、逐 harvest 事件 dump 各乘數):gain=productivity×current(tile池餘量)×COLLECT_RATE(0.05)×labor_mult×labor_share×work_morale×(1+farming_level×0.5)×(1+prod_skill×0.3)×harvest_factor·★逐團(9居民、重點 team47 vs 30/70/83)dump 各因子值:①current(該團 tile.resources.food 池餘量、疑枯竭=gain∝current 頭號嫌疑;plains 均衡池≈160[regen8÷COLLECT0.05]、若 team70 tile current<<160=枯池)②productivity(tile.productivity)③labor_mult(LaborSystem.labor_mult gather:food or LABOR_SCALE 若無 alloc=team70 疑無 labor 分配到採糧)④labor_share⑤work_morale⑥farming_level(tile)⑦prod_skill(leader 生產技能)⑧harvest_factor(tile 季節/狀態)⑨outpost_mult⑩pop(context)·★輸出=team47 vs team70/83 各因子並排表→一眼定 240x 差來自哪個乘數(枯池? 無labor alloc? 低farming? 低skill? 低morale?)·可能多因子疊、報各因子 team47/team70 比值→最大比值=主兇·官方 SpecimenDumpHelper 勿手設 team_ids·evidence-only 禁 fix 禁預設·output→systems 收口(gather-yield binding 因子)→blueprint 定 arc scope(接入+yield vs 接入alone)帶用戶裁·地基 KEEP"
---

# gather-yield WHY — 240x 同平原採集差真兇（blueprint GO）

用戶線索收齊再裁 arc scope 的 missing clue。**不 code-guess、逐 harvest 事件真測分項** [[feedback_measure_peroption_util_before_decision_claim]]。evidence-only、禁 fix、禁預設。

## problem
同 plains terrain：**team47 4.1/event** vs **team70 0.017/event**（40 次採僅 Σ0.67）vs **team83 0.01**（顆粒無收）= **240x 差**。定 binding 因子。

## ★gather formula per-team 分項直測（resource_system:268）
```
gain = productivity × current(tile池餘量) × COLLECT_RATE(0.05) × labor_mult × labor_share
       × work_morale × (1+farming_level×0.5) × (1+prod_skill×0.3) × harvest_factor
```
逐團（9 居民、重點對照 **team47 vs 30/70/83**）在其 harvest 事件時點 dump 各乘數值：

| # | 因子 | 讀處 | 頭號嫌疑 |
|---|---|---|---|
| ① | **current**（tile 池餘量） | `tile.resources.food` | ★`gain∝current`=頭號。plains 均衡池 ≈160（regen 8 ÷ COLLECT 0.05）；team70 tile current **<<160 = 枯池** |
| ② | productivity | `tile.productivity` | |
| ③ | **labor_mult** | `LaborSystem.labor_mult(home,gather:food)` 或 `LABOR_SCALE`（無 alloc） | team70 疑**無 labor 分配到採糧** |
| ④ | labor_share | | |
| ⑤ | work_morale | `team.work_morale` | |
| ⑥ | farming_level | `tile.farming_level` | (1+×0.5) |
| ⑦ | prod_skill | leader 生產技能 | (1+×0.3) |
| ⑧ | harvest_factor | `tile.harvest_factor` | 季節/狀態 |
| ⑨ | outpost_mult | | |
| ⑩ | pop | context | |

## ★輸出
**team47 vs team70/83 各因子並排表** + 各因子 **team47/team70 比值** → 最大比值 = 主兇（一眼定 240x 來自枯池 / 無 labor alloc / 低 farming / 低 skill / 低 morale / 或多因子疊）。

## ★併入：ownership-mismatch seam 檢查（blueprint 查出、用戶問「跑公庫嗎」）
**code seam CONFIRMED（我複核）**：存入端 `deposit`（resource:288）只查 `outpost_level>0`、**無 owner check**（註假設採集者=owner 但不驗）；吃飯端 `own_granary_tile`（:400）**要 `outpost_owner==team`**。∴站**非自有** outpost（level>0、owner≠己）→ 採的糧存進該倉**但吃不到**=邊採邊餓。
- ★**nuance（別搞錯 population）**：panel 9 居民 resident_detail 準則=`own_granary≠null`=**owner-matched**→**對這 9 團 seam 不適用**（它們 own 自己 tile、granary=0 是清空/低 yield 非 ownership）。mismatch 若存在=在**站非自有 outpost 的團**（panel 因 own_granary=null 歸為 wanderer）。
- ★**check（world-wide、非只 9 panel）**：掃**所有站 outpost_level>0 tile 的團**：`腳下 tile.outpost_owner == team.team_id`？
  - **mismatch 團數** + 其 `harvest_intake_vault` 流向誰的倉（存進非自有倉的量 Σ）。
  - 這些 mismatch 團的 team.food / famine 狀態（採進吃不到→餓？）。
- ★**不預設**（blueprint 定）：6 團採集量本身近零（0.01-15% 飯量）=主病**可能仍在 yield**、ownership 是**第二嫌疑並查**（別讓 ownership 假說蓋過 yield 真測）。

## 紀律
官方 `SpecimenDumpHelper` 勿手設 `specimen_team_ids`（observer-neutrality [[feedback_observer_no_global_rng]]）。若現 specimen batch 已含這些 tile/team/owner 欄可直讀、不足才補 tap（**先讀既有 dump 再決定跑不跑**）。
output → systems 收口（gather-yield binding 因子）→ blueprint 定 arc scope（接入+yield vs 接入 alone）帶用戶裁。地基 KEEP。
