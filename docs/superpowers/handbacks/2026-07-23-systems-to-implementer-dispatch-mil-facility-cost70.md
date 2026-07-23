---
from: systems
to: implementer
status: open
topic: "[dispatch·trivial·smeltery+armorsmith material 80→70(仿 weaponsmith,閉同族 afford-ceiling 洞)·新小 branch feat/mil-facility-cost70·無 measure] blueprint 裁現在就修(數字驗證同洞非臆測、同 weaponsmith pattern 零新設計風險)。改 outpost_system.gd FACILITY_DEF:smeltery(:81)material 80→70、armorsmith(:93)material 80→70(仿 weaponsmith:87 已 70;70×1.5=105<天花板 117 穩達)。★僅這兩個(mint 100 有 bootstrap、其餘≤60 安全,不動)。TDD:upgrade_cost(smeltery,1).material==70 && upgrade_cost(armorsmith,1).material==70。gate PASS/headless 0new/determinism(純常數改無 RNG)。★無 measure→QA(純 afford-margin 值改、無行為模型變、這兩設施還被上游 food/facility-build 堵短期不會建、同 weaponsmith cost70 已驗 pattern)。task=systems+reviewer(merge-gate R²:確認只動這兩、不碰全域×1.5、值算對)。做完→reviewer merge-gate→融合驗→merge。獨立於 GATE-A(不同檔,別動 GATE-A branch)。"
branch: feat/mil-facility-cost70
---

# dispatch（trivial）：smeltery + armorsmith material 80→70（閉同族 afford-ceiling 洞）

blueprint 裁**現在就修**（`2026-07-23-blueprint-to-systems-smeltery-armorsmith-fix-now`）：數字驗證同洞非臆測、同 weaponsmith pattern 零新設計風險、等軍事鏈撞到再修=重做已完成診斷=浪費。

## 改（2 值，仿 weaponsmith cost70）
- `outpost_system.gd` FACILITY_DEF：
  - `smeltery`（:81）`cost.material` **80 → 70**。
  - `armorsmith`（:93）`cost.material` **80 → 70**。
- 理由：material 80 → ×1.5=120 > 天花板 117 = weaponsmith 降 70 前同洞；降 70 → ×1.5=**105 < 117** 穩達（同 weaponsmith:87 已 70 的邏輯）。
- **★僅這兩個**：mint（100，bootstrap grant 150 覆蓋）、farming30/stable40/apothecary50/workshop60（×1.5≤90）**不動**（confirmed 安全）。tools cost 不變。

## 驗收
- **TDD**：`upgrade_cost("smeltery",1).material == 70` && `upgrade_cost("armorsmith",1).material == 70`。
- **gate** PASS / **headless** 0 new / **determinism**（純常數改，無 RNG）。
- **★無 measure→QA**：純 afford-margin 值改、無行為模型變、這兩設施還被上游（food-security→facility-build 稀少）堵、military 隊短期不會建到這步；同 weaponsmith cost70 已驗 pattern。
- **task = systems + reviewer**（merge-gate R²：確認只動這兩、不碰全域 ×1.5、值算對）。

## 序
獨立於 GATE-A（不同檔 outpost_system vs decision，**別動 GATE-A branch**）。**新小 branch `feat/mil-facility-cost70`**。做完 → reviewer merge-gate → 融合驗 → merge。
