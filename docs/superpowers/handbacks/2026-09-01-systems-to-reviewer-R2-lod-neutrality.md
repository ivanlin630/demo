---
from: systems
to: reviewer
status: open
slice: lod-production-neutrality
topic: ★R² 審修票(blueprint 已 GO,intended-change 級);★★要你打三點:①我判「confound 不擋修」對不對 ②補償形狀 A(迴圈)vs B(倍率)我【故意不指定】而要 implementer 照既有四系統做——若四系統本身不一致呢 ③驗收③材料守恆會不會恆真;★spec: docs/superpowers/specs/2026-09-01-lod-production-neutrality-HOW.md
---

# ★①一句話
`sim_runner.gd:164` manufacture 是 `LOD_BOTH + shape "teams"` ⇒ far 隊跑得少且【不補回】
⇒ 實測 far/near ≈ 0.47~0.53。★**修法＝接既有 `teams_cadence`（四系統在用，零發明）。**

# ★★②要你打的三點
```
①★我判【confound 不擋修】：near 1 隊 vs far 9 隊的 population 分岔沒排除,但
   ★★我的論證是「率等價是 invariant ⇒ 方向本身就是違規」+「修法不依賴量級」
   ⇒ ★★★要你打：有沒有一種可能是【方向也是 confound 造成的】？(那樣就不該修)
②★★補償形狀我【故意不指定】：A 迴圈式(reactions 用的) vs B 倍率式
   ⇒ 我要 implementer 照 collect/consumption 的既有形狀做
   ⇒ ★★★而我沒查那四個系統【彼此是否一致】—— 要你看一眼:若它們本身就不一致,
     我這條「照同族做」的指示就沒有指向
③★驗收③「總材料消耗 ÷ 總產出 不變」會不會恆真？
   （若產出與材料在 code 裡是同一個迴圈裡等比例增減,那個比值【當然】不變 ⇒ 沒有偵測力）
```

# ★③已先手處理
```
★估算端自述同批改（manufacturing_system.gd:78-81 那句「產線在 NEAR pass」是假的,
  而病4 當初就是因為它被銷案）+ 補假設告警（對照 outpost_tick 有、manufacturing 沒有）
★★驗收①要求 raw + per-team 雙軌（判準⑧,血證是 S6 那個純分母效應）
★★★fp 會變且【變了不是失敗】——這是 intended-change,已標注
```
