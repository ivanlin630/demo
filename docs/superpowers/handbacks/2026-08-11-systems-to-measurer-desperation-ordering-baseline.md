---
from: systems
to: measurer
status: open
topic: "[派量測員:iii 絕境排序底查(死亡螺旋 per-option util dump、兩 mispricing 定位、spec docs/superpowers/specs/2026-08-11-desperation-ordering-baseline-measure-HOW.md)·measure-first(禁靜態斷言、dump per-option util 再開藥、乙教訓 genuine 非 crank)·★床=死亡螺旋(seed8181 dispersed Team2 餓死隊、既有 fixture)逐決策點 dump·★量兩 util 軌跡+terms+per-option 橫排(day18-28 race 窗口 focus):①求援 mini-util(_try_herald_side:1994=need_severity×P(help)×INFO_RELIEF_EXPECT(2.4)−INFO_ANON_COST(0.8)×_help_pmult)軌跡+分項→day23 為何太低:genuine(還沒絕境 severity 真低)vs mispricing(絕境了缺可逆-低成本因子)?②叛離 defect_util(event_faction_defect=distress_pressure×loyalty_deficit−stay_benefit、unrest>=20 gate)軌跡+分項→day25 fire 有無 factored『叛離後果 factionless→relief 不可達→死』(現公式無此項)?③per-option 橫排(求援vs叛離vs逃[遷移找糧/覓食]vs撐[survival])整條螺旋→兩 mispricing 真 lever vs 第三因(逃早該 fire 沒?撐異常?)·★觀測 tap 補(pure-read 填 gap):現求援 mini-util 值未 tap(只 help.severity_positive fire、對比 distribute/migrant.mini_util:1678/1714 有值)+defect_util 值未 tap(只 cohesion.defect_fire)→補 Probe.note('help.mini_util',util)+分項/Probe.note('cohesion.defect_util',defect_util)+distress_pressure/loyalty_deficit/stay_benefit(mirror 既有範式、純讀零 RNG 零行為、env-gated 診斷或提議 permanent 填 herald gap)·★分類判準 genuine 命門:求援 too-low=genuine(還沒絕境正確)vs mispricing(絕境缺可逆因子);叛離=有 price 後果仍 fire(genuine desperation-defection 該保)vs 無 price 後果(餓叛通往死不知);驗『餓叛→死=util 該低』『野心叛吃飽→util 該高』差異能否從 state 湧現·★長跑附 specimen(餓隊逐決策 motive→util→action)送 QA 故事稽核硬規則·output=兩 util 軌跡+terms+per-option→餵 blueprint spec iii genuine repricing(哪個/都是/第三因)·地基 KEEP"
---

# 派量測員：iii 絕境排序底查（死亡螺旋 per-option util dump、兩 mispricing 定位）

spec：`docs/superpowers/specs/2026-08-11-desperation-ordering-baseline-measure-HOW.md`。measure-first（禁靜態斷言、dump 再開藥、乙教訓 genuine 非 crank）。

## ★床 + 量什麼
死亡螺旋（seed8181 dispersed Team2 餓死隊、既有 fixture）逐決策點 dump。day18-28 race 窗口 focus：
1. **求援 mini-util 軌跡**（`_try_herald_side:1994` 公式）+ 分項 → day23 太低 = genuine（還沒絕境）vs mispricing（缺可逆-低成本因子）？
2. **叛離 defect_util 軌跡**（`event_faction_defect` 公式、unrest≥20 gate）+ 分項 → day25 fire 有無 factored「叛離後果 factionless→relief 不可達→死」？
3. **per-option 橫排**（求援 vs 叛離 vs 逃[遷移找糧/覓食] vs 撐[survival]）→ 兩 mispricing 真 lever vs 第三因？

## ★觀測 tap 補（pure-read 填 gap）
求援 mini-util 值未 tap（只 severity_positive fire、對比 distribute/migrant.mini_util:1678/1714）+ defect_util 值未 tap → 補 `Probe.note("help.mini_util", util)` + 分項 / `Probe.note("cohesion.defect_util", ...)` + distress_pressure/loyalty_deficit/stay_benefit（mirror 既有範式、純讀零 RNG、env-gated 診斷或提議 permanent 填 herald gap）。

## ★分類判準（genuine 命門）
- 求援 too-low = genuine（還沒絕境正確）vs mispricing（絕境缺可逆因子）。
- 叛離 = 有 price 後果仍 fire（genuine desperation-defection 該保）vs 無 price 後果（餓叛通往死不知）。
- ★驗「餓叛→死=util 該低」「野心叛吃飽→util 該高」差異能否從 state 湧現。

★長跑附 specimen（餓隊逐決策 motive→util→action）送 QA 故事稽核。output = 兩 util 軌跡+terms+per-option → 餵 blueprint spec iii genuine repricing。地基 KEEP。
