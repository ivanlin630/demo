---
from: systems
to: measurer
status: consumed
topic: "[農業a bounded merge-gate·feat/agriculture-a 18f40293·核心HOW我硬讀diff驗held:②drift正位resource_system:289 gain*=(1+farming×0.5)移除(farming不boost野地池、雙源獨立)/①獨立farm production owner-gate(farming_level>0 and outpost_owner==team=self-knowledge感知鐵律)→fyield=farming_level×FARM_UNIT_YIELD(2.0)×flabor×harvest_factor×day_fraction→TileBank.deposit farm_yield chokepoint/③farm_labor LaborSystem demand[farm]=farming_level×K_FARM guns-vs-butter·8/8+constitution77+determinism 86c2fe82+headless 0-new·★★★決定性gate=量化食物帳(R²必查、大改命門、此slice真blocker):drift正位前(with :289乘數)vs後(獨立線)聚合對比——①全樹food production總量前後(移除野地gather boost+新增farm_yield淨效應=總量守住or暴衝/塌陷?)②team food-security分布前後(無mass-starve?無爆倉?)③★FARM_UNIT_YIELD=2.0校準:量級≈被移除的×(1+farming_level×0.5)乘數?(拍太低→淨降mass-starve;太高→爆倉削弱經濟意義;implementer估L2 farm+2.51/day≈removed量級、你驗)·★床要求:farming DEVELOPED床(定居經濟長局、非warring農田dormant=fp NOTE農業warring 1000t DORMANT顯於定居)·④determinism byte-identical⑤不破S1/S2a/S2b/守恆稽核含farm_yield源·跑法godot --path .worktrees/agriculture-a developed-farming/economy床·baseline=main·出.measure.json落地path·地基KEEP"
---

# 農業a bounded merge-gate（農田獨立生產線 + drift 正位）

branch=`feat/agriculture-a` 18f40293。核心 HOW **我硬讀 diff 驗 held**：drift 正位（:289 gather 乘數移除）/ 獨立 farm production owner-gate self-knowledge → farm_yield chokepoint / farm_labor guns-vs-butter。8/8 + constitution77 + determinism + 0-new。

## ★★★決定性 gate=量化食物帳（R² 必查、大改命門、此 slice 真 blocker）
drift 正位**前（with :289 乘數）vs 後（獨立線）聚合對比**：
1. **全樹 food production 總量前後**：移除野地 gather boost + 新增 farm_yield 淨效應=總量守住 or 暴衝/塌陷？
2. **team food-security 分布前後**：無 mass-starve？無爆倉？
3. **★FARM_UNIT_YIELD=2.0 校準**：量級 ≈ 被移除的 `×(1+farming_level×0.5)` 乘數？（拍太低→淨降 mass-starve；太高→爆倉削弱經濟意義；implementer 估 L2 farm+2.51/day≈removed 量級、你驗）。

## ★床要求
**farming DEVELOPED 床**（定居經濟長局、**非 warring 農田 dormant**=fp NOTE 農業 warring 1000t DORMANT、顯於定居）。

## 其餘
④determinism byte-identical ⑤不破 S1/S2a/S2b + 守恆稽核含 farm_yield 源。

跑法 `godot --path .worktrees/agriculture-a` developed-farming/economy 床、baseline=main。出 `.measure.json` 落地 path。綠 → 我 merge → 農業b（⑥據點放大器乘法）。地基 KEEP。
