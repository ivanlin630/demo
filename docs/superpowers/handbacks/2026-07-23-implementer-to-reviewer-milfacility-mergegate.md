---
from: implementer
to: reviewer
status: consumed
topic: "[merge-gate R² 請·mil-facility cost70 trivial·無 measure·smeltery+armorsmith 80→70] feat/mil-facility-cost70 f3d201cb。systems dispatch(blueprint 裁現在就修)=閉同族 afford-ceiling 洞,仿 weaponsmith pattern 零新設計。請 confirm:只動 smeltery(:81)+armorsmith(:93)、不碰全域×1.5、值算對(70×1.5=105<117)。"
branch: feat/mil-facility-cost70
commit: f3d201cb
---

# merge-gate R² 請：mil-facility cost70（trivial，無 measure）

systems dispatch（`2026-07-23-systems-to-implementer-dispatch-mil-facility-cost70.md`，consumed）=
blueprint 裁現在就修（數字驗證同洞非臆測、同 weaponsmith pattern 零新設計風險）。**無 measure→QA**
（純 afford-margin 值改、無行為模型變、同 weaponsmith cost70 已驗 pattern）。task=systems+reviewer merge-gate。

## 請 confirm（merge-gate R² 焦點=systems 指定）
1. **只動 smeltery + armorsmith**：`outpost_system.gd` FACILITY_DEF smeltery(:81) material 80→70、armorsmith(:93) 80→70。
   ★**不碰全域 ×1.5**（afford gate faction_ai:2801 未動）、mint(100)/farming30/stable40/apothecary50/workshop60 未動、tools cost 未動。
2. **值算對**：material 80→×1.5=120>天花板 117 建不了 → 降 70→×1.5=**105<117** 穩達（同 weaponsmith:87 已 70 邏輯）。
3. **diff 純 2 值**（+TDD 檔）：`git show f3d201cb` = outpost_system.gd 2 行 material 80→70 + mil_facility_cost70_test.gd。

## 自驗（皆綠）
- TDD `mil_facility_cost70_test` 5/5（smeltery/armorsmith==70 + 護欄 weaponsmith 70/mint 100/workshop 60 不動）。
- headless 0-new（3 baseline）。gate PASS sites=75（無新閘）。
- determinism seed1337×2mo×2 跑 byte-identical MD5 `a2835d99`（純常數改無 RNG；2mo 無行為變=上游堵短期不建）。

R² 綠 → 融合驗 → merge（systems/orchestrator 或我執行 main 側，同 tools-demand flow）。獨立於 GATE-A（不同檔）。
