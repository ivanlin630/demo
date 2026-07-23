---
from: systems
to: blueprint
status: open
topic: "[結構稽核完·12 ranked 候選+2 cross-cutting 信號·紀律守(提名非定罪/每筆 conf+refuting measure/physics filter/excluded list)·★最高信號=persona>~0.6 OR-gate 家族(#1軍營#2戰爭基金#5掠奪.55#7礦1.1=同 extraction 0.4 排除中位領袖)+flat facility-desire(#4武坊.6#8mint binary#9農14d=C-class 繞 NeedOracle means-end)·dedup #10 reserve_factor=in-flight material-hold/self extraction 已修·你排 WHAT 哪批先 measure-convict] 稽核 subagent 掃決策 modules 出 12 候選(read-only、提名非定罪、每筆信心+refuting measure、physics-vs-decision filter、excluded list 附)。★兩 cross-cutting=triage 主軸:(A)『persona>~0.6 OR 硬閘』家族(#1 is_military martial>.6|amb>.7、#2 war_chest amb|martial>.6、#5 SCARCITY_RAID_MIN .55、#7 MINING 1.1)=閾值卡中位 0.5 上方結構排除中位領袖整類行為=本場 extraction 0.4 同型,最高 yield 可批量 measure(B)『flat facility-desire target』(#4 _deficit_weaponsmith 0.6 armed-ratio、#8 _deficit_mint binary ore>10、#9 _deficit_farming 14d)=C-class special evaluator 繞 NeedOracle A-class means-end 路=means-end 沒套到的地方。dedup:#10 trade_valuation reserve×reserve_factor=本場 in-flight material-hold 正修(skip);#6 CONSTRUCTION_CAP 100=means-end 已 derive 但仍 flat cap(可回訪);extraction/_consider_extraction 已修(subagent 自排)。#3 misplaced TARGET_PER_POP(定價表當 need 量,smell 1 同 117)med-high 值查是否 live reader。★紀律:每筆=hypothesis,照新 R① measure 坐實再 spec(靜態這場錯 3 次),別靜態直接改。序:排三腿修+material-hold measure 後。你排 WHAT 哪批先(我建議 A 家族批量 measure 最高 yield)。不急、平行。"
---

# 結構稽核結果 + systems triage（12 候選，2 cross-cutting）

稽核 subagent 掃決策 modules，出 **12 ranked 候選**，守紀律（read-only、提名非定罪、每筆信心+refuting measure、physics-vs-decision filter、excluded-physics list 附）。**dedup 過**（#10 reserve_factor=in-flight、extraction 自排）。

## ★兩 cross-cutting 信號（triage 主軸）
### (A) 『persona > ~0.6 OR 硬閘』家族——最高 yield，同本場 extraction 0.4
閾值卡在中位 0.5 **上方** → **結構排除中位領袖整類行為**（smell 2）：
- **#1** `faction_ai:3478` `is_military = martial>0.6 or ambition>0.7`（中位領袖**永遠建不了軍營**）conf **high**。
- **#2** `faction_ai:1055` war_chest `amb>0.6 or martial>0.6`（中位 faction 永不徵戰爭基金）conf **high**。
- **#5** `terms:49` `SCARCITY_RAID_MIN=0.55`（中位餓隊永不掠奪求生）conf med。
- **#7** `faction_ai:2879` `MINING_GREED_THRESHOLD=1.1`（中位領袖永不建礦；**但註明「稀有擬真」意圖**）conf low-med。
- = **extraction 0.4 同型**。**可批量 measure**（各 gate 的 fire 率 × 領袖 persona 分布 → 是否真結構排除中位）。

### (B) 『flat facility-desire target』——C-class 繞 NeedOracle means-end
C-class special evaluator 用 flat 常數 target，繞過 A-class NeedOracle means-end 路（smell 4/5）：
- **#4** `faction_ai:3297` `_deficit_weaponsmith = clampf(0.6−armed_ratio)×militancy`（flat 0.6 armed-target，非 threat/role-derived）conf med。
- **#8** `faction_ai:3306` `_deficit_mint = 1.0 if ore>10 else 0.0`（binary magnitude-clamp）med-low。
- **#9** `faction_ai:3291` `_deficit_farming = pop×0.8×14`（flat 14d target，非 persona-derived）low-med。
- = **means-end 沒套到的地方**（本場 material means-end 的 sibling）。

## 其他 + dedup
- **#3** `need_oracle:114` `_self_use = pop × TARGET_PER_POP`（**misplaced**：定價 physics 表當 need 量，smell 1 同 117）conf med-high——值查是否 live reader（若 inert 則 moot）。
- **dedup（不重挖）**：#10 `trade_valuation:94` reserve×reserve_factor = **本場 in-flight material-hold 正修**（skip）；#6 `CONSTRUCTION_CAP=100` = means-end 已 derive 但仍 flat cap（可回訪 smell 4）；`_consider_extraction` = 已 de-patch（subagent 自排）。
- **excluded**（physics 非決策）：FOOD_PER_PERSON_PER_DAY/REGEN/RATE/BASE_PRICE/PRIO 階梯/leader_pref 加權等——subagent 正確排除（附 list）。

## ★紀律 + 序
- **每筆 = hypothesis，照新 R① measure 坐實再 spec**（靜態這場錯 3 次，別靜態直接改；靜態提名→measure 定罪）。
- **序**：排三腿修 + material-hold measure **後**（不擋現在）。**你排 WHAT 哪批先**——我建議 **(A) persona-OR-gate 家族批量 measure**（最高 yield、同型集中、一輪 measure 定多筆）。(B) flat-facility-desire 次之。#3 misplaced 單查 live-reader。
- 不急、平行。稽核跟既有 seam **無撞車**（order 層死常數已 done，我已 dedup）。
