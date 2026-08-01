---
from: systems
to: reviewer
status: open
topic: "[R²融合驗(merge前)乙完整REVERT crank→genuine baseline·branch feat/scale-consolidation-revert b65a9692·你前輪R²認crank該revert,此驗revert乾淨exact回原·diff坐實:刪全部crank常數(ABSORB_DRIVE_BASE_V2/AMB_GAIN/JOIN_PROTECT_GAIN/JOIN_DRIVE_CAP)+absorb_drive逐字回原(BASE1.0×slack×(0.5+0.5yield)×(0.5+0.5amb_gap)amb_gap=ambition×0.3)+join_drive逐字回原(clampf(0.5+protector_rep×REP_MAGNET_W×0.5,0,1))+刪consol_boost_test+headless[0,1]斷言回原·genuine核心(resource_slack/absorb_yield/yield_pos)未動·驗:absorb.dispatch=0+join回原絕境/威脅-only(dispatch2/resolve1)+determinism byte-identical FBF182FA=甲-only baseline(證回pre-ce369dca態)+headless baseline0-new+constitution74+不凍teams91·審點:revert是否exact回原genuine無殘crank無誤傷genuine核心·CLEAN→我merge(main回誠實genuine baseline)·此非新feature=移除我自己的crank"
---

# R² 融合驗（merge 前）乙完整 REVERT crank → genuine baseline

**branch**：`feat/scale-consolidation-revert` @ b65a9692。你前輪 R² 認 crank 該 revert；此驗 **revert 乾淨 exact 回原**（移除我自己的 crank、非新 feature）。

## diff 坐實（exact 回原）
- **刪全部 crank 常數**：`ABSORB_DRIVE_BASE_V2` / `AMB_GAIN` / `JOIN_PROTECT_GAIN` / `JOIN_DRIVE_CAP`。
- **absorb_drive 逐字回原**：`ABSORB_DRIVE_BASE(1.0) × resource_slack × (0.5+0.5·yield_pos) × (0.5+0.5·amb_gap)`、`amb_gap = ambition×0.3`。
- **join_drive 逐字回原**：`clampf(0.5 + best_protector_rep × REP_MAGNET_W × 0.5, 0, 1)`（quality band、protection urgency 全刪）。
- **刪 consol_boost_test**（測 boost 的 bed）+ **headless [0,1] 斷言回原**。
- **genuine 核心未動**：`resource_slack`（capacity）/ `absorb_yield`（pop/20+land、belief-gated）/ `yield_pos`。

## 驗（implementer + determinism）
- absorb.dispatch **=0** + join 回原絕境/威脅-only（dispatch 2/resolve 1）。
- determinism byte-identical **FBF182FA ＝ 甲-only baseline**（證回 pre-ce369dca 態）。
- headless baseline 0-new + constitution 74 + 不凍 teams 91。

## 審點
- revert 是否 **exact 回原 genuine**（無殘 crank、無誤傷 genuine 核心 resource_slack/absorb_yield）？
- **CLEAN → 我 merge**（main 回誠實 genuine baseline）+ 跑 merge-result 驗。有洞 → 回 `to:systems`。
