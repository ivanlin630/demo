---
from: implementer
to: systems
status: consumed
topic: "[done·乙 整併 util boost·dev-verify 4/4+warring absorb.dispatch 0→10·請 R²(②連續複驗)] feat/scale-consolidation-util-boost 21119a35。A absorb_drive 野心真放大(ambition_amp=0.5+1.5×gap_norm)+base 1.0→1.5;B join_drive 加理性 protection urgency(near protector×求生欲×低野心,cap 2.0)。全連續乘無硬 gate。dev-verify:absorb_drive 掃連續(step 0.675)+人格分化(高野心 3.0>低 0.75)+join 連續(step 0.056)+理性 protection(near 1.64>無 0.5);warring absorb.dispatch 0→10(argmax starvation 治好)+merge fire+teams 84(保守未塌非 blob)。determinism byte-identical(943B9480)+不凍(1.58%/84)+headless 3=baseline(0-new,修 stale [0,1]斷言)+constitution 74。★residual dispatch10→merge1=pull mid-travel 蒸發交§5。保守起步值靠§5 tune。"
branch: feat/scale-consolidation-util-boost
commit: 21119a35
base: 92e93873 (local main HEAD)
measurements:
  - docs/measurements/2026-08-01-warring-consol-boost-3seed.json
---

# 乙 整併 util boost — de-patch util-starvation（dev-verify）

根=決策層 util-starvation（吸納 ownutil 0.104 vs 贏 1.09；finder 找 4794 但 dispatch 0）=terms.gd 死常數過度正規化。統一 de-patch（四約束）。

## 做（terms.gd）
- **A absorb_drive**（治①base [0,1]cap +②野心 ×0.3 被閹）：`ABSORB_DRIVE_BASE_V2=1.5`（base 保守抬）+ `ambition_amp = 0.5 + AMB_GAIN(1.5) × gap_norm`（野心真放大；gap 滿→amp~2.0/content→0.5）。`absorb_drive = BASE_V2 × slack × (0.5+0.5·yield) × ambition_amp`。yield/slack gate 保留（防亂吸）。
- **B join_drive**（治 fed 隊 util 太弱、只絕境 spike）：加理性 protection urgency `= JOIN_PROTECT_GAIN(1.0) × best_protector_rep × 求生欲 × 低野心`（near 好 protector 非絕境也理性投靠、順治 97% mid-travel）；`clampf(quality+protection, 0, JOIN_DRIVE_CAP=2.0)`。
- **★全連續乘**（無 `if ambition>X` 硬 gate）。★保守起步值（§5 tune）。

## ★四約束（統一非補丁，grep 自證）
| # | 約束 | 自證 |
|---|---|---|
| ① | 走既有 term pipeline 無特判 | 只改 terms.gd `absorb_drive`/`join_drive` drive 值，走既有 `DecisionTerms.eval`→weight→argmax；無新 dispatch 特判 branch |
| ② | **連續 weigh 非硬 gate** | ambition_amp/protection 全連續乘（0.5+GAIN×gap / rep×survival×low_amb）；grep 無 `if ambition>`/`if 野心>` 階梯。**dev-verify 掃證**（absorb step 0.675、join step 0.056 連續）。★reviewer 請專門複驗此項 |
| ③ | term re-weight 非新機制 | 改既有 drive 公式常數/係數；無新 term/機制 |
| ④ | 感知鐵律 | prey_pos/host_pos/rep 走既有 belief（未動） |

## dev-verify（`consol_boost_test` 4/4）
- **absorb_drive 連續**：掃 ambition_gap 0→5 max step=0.675 + 單調↑ = WEIGH 非 GATE。
- **人格分化**：高野心 absorb_drive=**3.0** > 低野心=**0.75**（有大有小湧現自人格）。
- **join_drive 連續**：掃野心 0→1 max step=0.056 + 單調↓（野心↑→stay 獨立）。
- **理性 protection**：低野心高求生 near 強 protector join_drive=**1.64** > 無 protector=0.5（非絕境理性投靠）。

## warring 3-seed（`docs/measurements/2026-08-01-warring-consol-boost-3seed.json`）
```
absorb.dispatch = 10   ← ★0→10（argmax util-starvation 治好！高野心強隊真選吸納）
absorb.target_found = 4482
accept.merge_accept = 1   mergein.subteam = 1   ← merge 真 fire（team 數真降）
merge.consolidate_dispatch = 2   join.dispatch = 7
avg final teams = 84   ← ★保守未塌（非 1 blob；仍有小隊=有大有小）
```

## 驗（全綠）
- `consol_boost_test` **4/4**、`headless` **3=baseline(0-new)**（修 term_normalize 的 stale `absorb/join_drive ∈[0,1]` 斷言→新上界=boost 刻意去正規化，legit 測維護）、constitution **74**、determinism seed1337 三跑 **byte-identical**（943B9480）、不凍（attrition 1.58%/teams 84）。

## ★residual + §5 去向（honest）
warring `absorb.dispatch=10 → merge=1`：argmax starvation **治好**（dispatch 0→10），但露 **pull-side mid-travel 蒸發**（強隊行軍 prey/prey 移動/re-eval churn，dispatch 10→arrive/merge 少）——同 JOIN mid-travel 家族、**本 de-patch（argmax 層）外**。→ **§5 一次合量**：tune AMB_GAIN/base 分布朝 ~50 有大有小 + 治 pull-side mid-travel（若需）。★保守起步值全 §5 tune。

## 待
→ R²（★異質：② 連續 weigh 硬檢[reviewer 專項]/無特判①/term re-weight③/感知鐵律；absorb 0→10 measured）→ §5 一次合量（甲 distribute + 乙 join/absorb boost + 全貌 tune）。隔離 branch 未 merge。
