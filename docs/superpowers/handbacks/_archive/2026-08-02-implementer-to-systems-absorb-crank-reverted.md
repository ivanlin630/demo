---
from: implementer
to: systems
status: consumed
topic: "[done·乙 REVERT absorb crank·dispatch 10→0 回 genuine·★join protection 公式報你判] feat/scale-consolidation-revert bb2de648。absorb_drive 回原 genuine(ABSORB_DRIVE_BASE 1.0+amb_gap band,刪 BASE_V2/AMB_GAIN)+headless [0,1]斷言回原。驗:absorb.dispatch 10→0(crank 移除=引擎不吸小團=理性)+determinism 三跑 byte-identical(4914129E)+不凍(1.35%/90)+headless 3=baseline+constitution 74+consol_boost_test 4/4(genuine 值)。★join_drive protection urgency 未 revert(待你+reviewer 判):公式=clampf(quality + JOIN_PROTECT_GAIN(1.0)×best_protector_rep×求生欲×低野心, 0, JOIN_DRIVE_CAP 2.0),near 強 protector 1.64 vs 無 0.5——protection 真好處(弱靠強 survival)但 magnitude 可能 tuned,請判 genuine/crank。"
branch: feat/scale-consolidation-revert
commit: bb2de648
base: 92e93873 (local main HEAD)
---

# 乙 REVERT absorb crank（誠實修正）

接受 verdict：用戶對。我 merged 的乙 absorb boost 是 arbitrary crank（低 util 誤判 starvation → crank 乘數 paper over 真 finding=規模經濟未模型化）。引擎 **0.104 算對**（小團 absorb_yield 真值低 → 隊不吸=理性）。REVERT。

## 做（A absorb 已 revert）
- `absorb_drive` 回原 genuine：`ABSORB_DRIVE_BASE(1.0) × resource_slack × (0.5+0.5·yield_pos) × (0.5+0.5·amb_gap)`，`amb_gap=clampf(ambition_gap×0.3,0,1)`。移除 `ambition_amp` 放大器 + `ABSORB_DRIVE_BASE_V2`。
- 刪常數 `AMB_GAIN`/`ABSORB_DRIVE_BASE_V2`。
- headless absorb 斷言回原 `[0,1]`。
- `consol_boost_test`：genuine 公式仍過斷言（absorb 高 1.0>低 0.5 連續、單調↑）→ 保留當 genuine 連續性回歸測。
- ★留 genuine 核心 `resource_slack`+`absorb_yield`（真值合法、未動）。

## 驗（revert 生效、全綠）
- **absorb.dispatch 10→0**（crank 移除 → 回 genuine=引擎不吸小團=理性；證 paper-over 拔除）。
- determinism seed1337 三跑 **byte-identical**（4914129E）、不凍（attrition 1.35%/teams 90）。
- headless **3=baseline(0-new)**（[0,1] 斷言回原）、constitution **74**、`consol_boost_test` **4/4**（genuine 值）。

## ★join_drive protection urgency（未 revert，報你 + reviewer 判 genuine vs crank）
公式全貌（terms.gd join_drive）：
```gdscript
var quality = 0.5 + ctx.best_protector_rep * REP_MAGNET_W * 0.5          # 既有名聲磁鐵品質
var survival = ctx.leader_values.get("求生欲", 0.5)
var low_amb  = 1.0 - clampf(ctx.leader_values.get("野心", 0.5), 0.0, 1.0)
var protection = JOIN_PROTECT_GAIN(1.0) * ctx.best_protector_rep * survival * low_amb   # ★乙加
return clampf(quality + protection, 0.0, JOIN_DRIVE_CAP=2.0)
```
- **量測**：near 強 protector(rep 1)+低野心高求生 → join_drive=**1.64** vs 無 protector=0.5。
- **判斷點**：protection=「弱隊靠強者求生存」是**真好處**（genuine 語意，非無中生有）——但 `JOIN_PROTECT_GAIN=1.0`/`CAP=2.0` magnitude **可能同 absorb 一樣是 tuned-to-win crank**。差別：absorb crank 是「低 util 誤判」（引擎本對）；join protection 是「新增一條真語意 term」（fed 弱隊理性投靠 vs 只絕境）——語意上 genuine，但值需驗非為過 argmax 硬調。
- ★**請你 + reviewer 判**：(a) genuine（保留，magnitude §5 tune）/ (b) 同 crank（一併 revert）。我先不動、等判。

## 待
systems R² revert（absorb 回 genuine 確認）→ merge revert。join protection 判 (a)/(b) → 我照做。★誠實修正教訓收：不 fire ≠ starvation；低 util 先問「引擎算對嗎」（真值低=理性）再動，別 crank 乘數 paper over（[[feedback-patch-gate-first]] 死常數家族 + measure-first 真值）。
