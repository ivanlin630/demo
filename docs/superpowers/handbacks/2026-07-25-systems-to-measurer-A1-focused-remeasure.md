---
from: systems
to: measurer
status: open
topic: "[measure·A1 修後 focused re-measure(非全量,blueprint 定)·A1 閉環驗(forest outpost 真建成+material 真流入+缺料隊真蓋設施)+A4/B 下游+★reviewer 新測項 remote-facility vs infra cadence 重疊度·A2/A3/C/D spot-check·base=current main(A1 merged)·seed1337/42·→數字 blueprint+specimen QA] A1 forest founding 修 merged(三處 TASK_BUILD 死路→複用 working builder)。post-A1-fix focused re-measure(blueprint 定非全量重跑,省)。base=current main(A1 merged,acf8d271);seed1337/42;長跑 6mo(founding+設施長程)。★A1 閉環驗(核心,arc 原始動機真達成):①forest outpost 真建成(定位型 founding candidate→_dispatch_builder→子隊 TASK_CONSTRUCT→真移動抵達→start_build→outpost_level>0,forest 新據點數)②material 真流入 holding(forest outpost 採 material,缺料隊 holding 升)③缺料隊真蓋成設施(走完整鏈:缺料→forest 據點→採→build_F facility 真建成 level>0);★對照 whole-A1-FAIL baseline(當時 forest outpost 建不成/隊卡平原)升否。★A4/B 下游(A1 修後該動):EXPAND(settle/found outpost)/harvest(material 採量)/facility-build/deal vs race-collapsed baseline(0/0.5-4.8%)+material afford(peak≥105 vs 0%)/coin liquidity/掛單噪音 消退否。★★reviewer 新測項:facility **remote** 分支(owner 不在場→_dispatch_facility_builder)vs 既有 infra cadence(_evaluate_infrastructure/_evaluate_independent_infrastructure faction_ai:3057+)**重疊度**——量 means-end remote-facility candidate 實際贏 argmax 並成功派出次數 vs infra cadence 獨立完成 facility 次數;若高度重疊(means-end 分支被 infra 搶先/重複)→下輪收斂候選(collapse 為一)。A2 多線/A3 折現/C 因果/D 憲法已 CLEAN→spot-check 不重跑全量。§④b specimen(A1-active 隊 goal_state+founding/facility candidate+子隊 trace)→餵 QA 故事稽核(A1 鏈真走完:缺料隊去 forest→真建據點→真採料→真蓋設施逐 tick)。量測可溯源:落檔+commit hash。→A1 閉環+A4/B+重疊度數字 to:blueprint(release-pass)+specimen to:QA。determinism 三跑 byte-identical(觀測禁 RNG)。"
branch: main (A1 修 merged)
---

# measure：A1 修後 focused re-measure（A1 閉環 + A4/B + remote-facility 重疊）

A1 forest founding 修 merged。**focused re-measure**（blueprint 定非全量，省）。base=current main（A1 merged）；seed1337/42；6mo。

## ★A1 閉環驗（核心，arc 原始動機真達成）
1. **forest outpost 真建成**（founding candidate → `_dispatch_builder` → 子隊 TASK_CONSTRUCT → 真移動抵達 → start_build → `outpost_level>0`，forest 新據點數）。
2. **material 真流入 holding**（forest outpost 採 material，缺料隊 holding 升）。
3. **缺料隊真蓋成設施**（完整鏈：缺料→forest 據點→採→build_F facility `level>0`）。
- ★對照 whole-A1-FAIL baseline（forest outpost 建不成/隊卡平原）升否。

## ★A4/B 下游（A1 修後該動）
EXPAND/harvest(material 採量)/facility-build/deal vs race baseline（0/0.5-4.8%）+ material afford（peak≥105 vs 0%）/ coin liquidity / 掛單噪音 消退否。

## ★★reviewer 新測項：remote-facility vs infra cadence 重疊度
facility **remote** 分支（owner 不在場→`_dispatch_facility_builder`）vs 既有 `_evaluate_infrastructure`/`_evaluate_independent_infrastructure`（faction_ai:3057+ cadence desire-based）**重疊度**——量 means-end remote-facility candidate 贏 argmax 並成功派出次數 vs infra cadence 獨立完成次數。高度重疊 → 下輪收斂候選（collapse 為一）。

## spot-check + 交付
- A2 多線 / A3 折現 / C 因果 / D 憲法已 CLEAN → spot-check 不重跑。
- §④b specimen（A1-active 隊 goal_state + founding/facility candidate + 子隊 trace）→ 餵 QA 故事稽核（A1 鏈真走完逐 tick）。
- → A1 閉環 + A4/B + 重疊度數字 `to:blueprint`（release-pass）+ specimen `to:QA`。determinism 三跑 byte-identical。
