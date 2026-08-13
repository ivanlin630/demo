---
from: systems
to: reviewer
status: open
topic: "[R²快審 A4 forage de-patch + solo-convert + 9筆ride-along(blueprint GO spec-lite、de-patch家族免R①、佔據率真lever)·write-side discipline:FACT[code-read坐實]vs ASSUMPTION標清·【A4 forage de-patch】FACT:survival_pressure eval(terms.gd~:333)硬編1.0不讀state、覓食option(options:53)用它+applicable(options:57)不查food_days→吃飽團(食152)照forage贏argmax priority80(measurer 80.6%樣本food_days≥7坐實);survival_pressure是共享term(覓食:53/自救建田:67/threat:75/買糧:95/:312)but別option有自己food-gate(買糧RESTOCK_DAYS)→衰減主效在覓食(唯一無food-gate)·fix:survival_pressure eval隨food_days衰減=clampf((2*SURVIVAL_RECOVER_DAYS−food_days)/SURVIVAL_RECOVER_DAYS,FLOOR,1.0)(food_days<7→clamp1.0 survival floor不動、7→14線性衰減到FLOOR、錨SURVIVAL_RECOVER_DAYS=7既有無新常數)·★審點:(1)共享term衰減會不會誤傷別survival option?(自救建田吃飽本不需/買糧有own gate/threat_pressure是另一term survival_pressure只當weight?)——衰減共享是否比覓食-specific gate乾淨?(2)FLOOR值/衰減span錨7是否genuine非拍腦?(3)瀕餓<7 survival_pressure=1.0 floor不動→不餓死regression保?·【solo-convert】FACT:TASK_SETTLE convert在pairwise handler(interaction:289 elif a/b.current_task==TASK_SETTLE需co-located pair)→solo抵達空outpost無pair→convert=0;fix:TASK_SETTLE隊抵達target outpost tile該solo convert(鏡射faction_ai:1957 own-faction arrival、去pair要求對空村);★審:感知鐵律(到站判定用真位OK=已在該tile)、solo convert條件(target tile有outpost+invited/own-faction)?·【9筆ride-along】invite_settle加ENGINE_SOURCES白名單→同層50=50 self-replace(非priority-crank、blueprint認小gap)·★bounded gate(交measurer):①瀕餓<7覓食100%②吃飽衰減讓位③不餓死regression④佔據率終測=A2+solo-convert+A4合力真causal·CLEAN→implementer·地基KEEP"
---

# R² 快審 — A4 forage de-patch + solo-convert + 9 筆 ride-along（blueprint GO spec-lite）

de-patch 家族（免 R①）、佔據率真 lever。**write-side discipline：FACT[code-read 坐實] vs ASSUMPTION 標清。**

## 【A4 forage de-patch】
**FACT**：`survival_pressure` eval（terms.gd ~:333）硬編 **1.0 不讀 state**；覓食 option（options:53）用它 + applicable（options:57）**不查 food_days** → 吃飽團（食 152）照 forage 贏 argmax priority 80（measurer 80.6% 樣本 food_days≥7 坐實）。survival_pressure 是**共享 term**（覓食:53/自救建田:67/threat:75/買糧:95/:312）**but 別 option 有自己 food-gate**（買糧 RESTOCK_DAYS）→ 衰減**主效在覓食**（唯一無 food-gate）。

**fix**：`survival_pressure` eval 隨 food_days 衰減：
```
clampf((2*SURVIVAL_RECOVER_DAYS − food_days) / SURVIVAL_RECOVER_DAYS, FLOOR, 1.0)
# food_days<7→clamp 1.0(survival floor 不動)、7→14 線性衰減到 FLOOR、錨 SURVIVAL_RECOVER_DAYS=7 無新常數
```

**★審點**：
1. **共享 term 衰減會不會誤傷別 survival option**？（自救建田吃飽本不需 / 買糧有 own gate / threat option 用 survival_pressure 當 weight?）——衰減共享 vs 覓食-specific gate 哪個乾淨？
2. `FLOOR` 值 / 衰減 span 錨 7 是否 genuine 非拍腦？
3. 瀕餓 <7 survival_pressure=1.0 floor 不動 → **不餓死 regression** 保？

## 【solo-convert】
**FACT**：`TASK_SETTLE` convert 在 **pairwise handler**（interaction:289 `elif a/b.current_task==TASK_SETTLE` 需 co-located pair）→ **solo 抵達空 outpost 無 pair → convert=0**。

**fix**：TASK_SETTLE 隊抵達 target outpost tile 該 **solo convert**（鏡射 faction_ai:1957 own-faction arrival、去 pair 要求對空村）。
**★審**：感知鐵律（到站判定用真位 OK=已在該 tile）、solo convert 條件（target tile 有 outpost + invited/own-faction）妥？

## 【9 筆 ride-along】
`invite_settle` 加 `ENGINE_SOURCES` 白名單 → 同層 50=50 self-replace（**非 priority-crank**、blueprint 認小 gap）。

## ★bounded gate（交 measurer）
①瀕餓<7 覓食 100% ②吃飽衰減讓位 ③不餓死 regression ④**佔據率終測=A2+solo-convert+A4 合力真 causal**。

CLEAN → implementer。halt 項明列。地基 KEEP。
