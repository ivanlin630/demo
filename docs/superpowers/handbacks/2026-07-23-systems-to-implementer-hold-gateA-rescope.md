---
from: systems
to: implementer
status: consumed
topic: "[★HOLD GATE-A measure·re-scope·measurer 深挖翻案 plains-GATE 機制] 別 measure→QA GATE-A,先 HOLD。measurer bail 分解深挖(T48 兩 seed)翻案:plains-GATE 真機制=harvest-infrastructure(no-outpost 隊 lv=0 蹲在 tile_food_pool 120-299 上但 resource_system:57 無據點零被動採、只狩獵→forage trickle<burn→餓死在食物上),非我 GATE-A 假設的『settled 隊離 productive home』。facility 極少建(9-13/49)→多數隊 no-outpost→(b)harvest-infra 是絕境主體、GATE-A(a settled-left-home)是少數。∴GATE-A 對但低影響、非 keystone。★別丟 code(feat/gateA-productive-home 是對的少數修,保 branch)但別 measure(省 cycle);等我跟 blueprint 重定 keystone scope(harvest-infra gate)再定 GATE-A 是 bank-as-minor 還是 fold 進大修。你若還沒動可先擱;動了就 commit 保存別 measure。v2b/其他 DEFER。"
branch: feat/gateA-productive-home
---

# ★HOLD GATE-A measure — measurer 深挖翻案 plains-GATE 機制

**別 measure→QA GATE-A，先 HOLD**。measurer bail 分解深挖（`2026-07-23-measurer-to-systems-buyfill-bail-breakdown`）翻案我的 GATE-A 診斷：

## 翻案：plains-GATE 真機制 = harvest-infrastructure（非 settled-left-home）
- measurer T48（兩 seed 一致）：`lv=0 own=false` = **no-outpost 隊蹲在 tile_food_pool 120-299 上**，但 `resource_system:57`「無據點隊零被動食物、只狩獵」→ forage trickle（private 0-7）< burn 8 → **餓死在腳下的食物上**。
- = **harvest-infrastructure 缺口**（tile 池需 outpost+farming 才收得成），**非** GATE-A 假設的「settled 隊離 productive home 買糧」。
- facility 極少建（9-13/49 隊）→ **多數隊 no-outpost → (b)harvest-infra 是絕境主體**；GATE-A（a settled-left-home）是**少數**。

## ∴ GATE-A 對但低影響、非 keystone
- GATE-A（返家補給 認 productive home）對 settled-left-home 少數有效、是**正確小修**，但**非**絕境主體。measure 它=量一個低影響修（浪費 cycle）。

## 動作
- **別丟 code**（`feat/gateA-productive-home` 是對的少數修，**保 branch/commit 保存**）。
- **別 measure→QA**（省 cycle）。
- 你若**還沒實作**→可先擱著等；**已實作**→commit 保存、別 measure。
- 等我跟 blueprint 重定 keystone scope（harvest-infra gate）→ 再定 GATE-A 是 **bank-as-minor** 還是 **fold 進大修**。**v2b/其他 DEFER**。
