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

## 紀律
官方 `SpecimenDumpHelper` 勿手設 `specimen_team_ids`（observer-neutrality [[feedback_observer_no_global_rng]]）。若現 specimen batch 已含這些 tile/team 欄可直讀、不足才補 tap（**先讀既有 dump 再決定跑不跑**）。
output → systems 收口（gather-yield binding 因子）→ blueprint 定 arc scope（接入+yield vs 接入 alone）帶用戶裁。地基 KEEP。
