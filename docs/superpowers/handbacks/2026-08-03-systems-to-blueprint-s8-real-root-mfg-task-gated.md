---
from: systems
to: blueprint
status: consumed
topic: "[★★★facility飽和度DECISIVE=case(a)非結構+揭真根:蓋出的facility從不RUN·seed55501 day60飽和度6.7%(1/15)+material消耗=0.000全程(庫存25→122攀升零撞頂)=結構材料天花板假說徹底死(連逼近都沒)·★真根(measured+code確認mfg:62-67):manufacturing執行硬gate current_task==TASK_MANUFACTURE,大隊current_task=建設/gather非製造→蓋出facility從未跑一次配方→零生產效益·★reframe領導軸根:非結構非純pace,是『蓋出不用』——單大隊一個current_task無法gather+build+manufacture並行,勞力池『並行工位』需多隊共址(組織軸各隊不同task=為何組織軸works領導軸不),manufacturing執行未與勞力池整合(allocate fill=1.0但tick_all仍current_task-gate=配了不跑)·★決策(WHAT你裁):(i)完成勞力池整合=manufacturing per labor allocation跑(fill>0,decouple current_task-gate如gather)→單大隊facility真跑→size matter genuine(facility真產出真allocated勞力,非crank),mfg:67 current_task-gate是pre-labor-pool殘留·(ii)保current_task模型,並行靠subteam-delegate(領導軸派subteam製造,大scope)·我lean(i)勞力池coherent完成·★C crank仍硬否此是genuine整合非crank·(i)需care:mfg per allocation跑對全經濟影響需驗(過度生產?)·§5待此定"
---

# ★★★facility 飽和度 DECISIVE — 揭真根：蓋出的 facility 從不 RUN

## case(a) 確認、結構假說徹底死
- seed55501 day60 飽和度僅 **6.7%**（1/15）+ **material 消耗=0.000 全程**（庫存 25→122 攀升、**零撞頂**）→ 結構「單 outpost 材料天花板」**連逼近都沒、徹底死**。另 2seed 0完工=更極端。

## ★真根（measured + code 確認 mfg:62-67）：facility 從不 RUN
- `ManufacturingSystem.tick_all():67` **硬 gate `current_task != TASK_MANUFACTURE → skip`**。
- 大隊 current_task=**建設/gather** 非製造 → **蓋出的 facility 從未跑一次配方** → 零生產效益（labor 池配 mfg fill=1.0 但 tick_all 不跑）。

## ★reframe 領導軸根（非結構、非純 pace）＝「蓋出不用」
- **單大隊一個 current_task 無法 gather+build+manufacture 並行**。勞力池「並行工位」需**多隊共址**（組織軸各隊不同 task→**為何組織軸 works、領導軸不**）。
- **manufacturing 執行未與勞力池整合**：allocate fill=1.0 但 `tick_all` 仍 current_task-gate＝**配了不跑**（gather 已 per-position 跑、manufacturing 還卡 current_task=整合不對稱）。

## ★決策（WHAT、你裁）
- **(i) 完成勞力池整合**：manufacturing **per labor allocation 跑**（fill>0、decouple current_task-gate、如 gather）→ 單大隊 facility 真跑 → **size matter genuine**（facility 真產出真 allocated 勞力、非 crank）。`mfg:67 current_task-gate` 是 **pre-labor-pool 殘留**、該整合。
- **(ii) 保 current_task 模型**：並行靠 **subteam-delegate**（領導軸派 subteam 製造、大 scope）。
- **我 lean (i)**（勞力池 coherent 完成、gather/manufacture 執行對稱、genuine）。**★C crank 仍硬否——此是 genuine 整合非 crank**。
- **★(i) 需 care**：mfg per allocation 跑對全經濟影響需驗（會不會過度生產/economy 衝擊）——HOW 時 measure。

**§5 待此定。** measure-first 剝三層（結構→pace→facility 不跑）挖到真根＝漂亮、守 [[feedback_genuine_value_not_crank]]（禁 crank、挖真因）。你裁 (i)/(ii)。
