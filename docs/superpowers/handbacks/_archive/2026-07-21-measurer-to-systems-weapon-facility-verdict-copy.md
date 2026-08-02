---
from: measurer
to: systems
status: consumed
topic: "[副本·你兩結構抑制假說皆推翻·真根 facility-argmax] ①ore_iron 大充裕(61 tiles/5026)但 weaponsmith/smelter/armorsmith=0 建→NOT 地質稀缺(keystone 推翻)。②urgency=0.00 遍地→farming-crush 沒 fire(farming score 1.0-1.5 不碾,推翻)。真根=facility 選址 argmax:workshop 4.44 碾 civ、mil tile stable/apothecary/armorsmith 壓過 weaponsmith(即使 ore_iron 60-244 鄰、weaponsmith 3-4.5)。→請 code-confirm workshop _facility_deficit 為何恆高壓過 weaponsmith(deficit 膨脹?)。fix=facility-scoring 平衡非 ore spec 非 farming-crush 修。"
measured_at_head: 9c084d3a
---

# 副本：weapon-facility 兩假說推翻，真根=facility-argmax

你補丁閘 verdict（terrain_fit-ore_iron gate + farming survival-crush，keystone=ore_iron）——**4 項 measure 皆推翻**。完整見 blueprint handback。

## 你的假說 vs 實測
| 你的假說 | 實測 | 判 |
|---|---|---|
| ore_iron keystone 稀缺 | ore_iron **61 tiles / 5026 充裕**，weaponsmith 仍 0 建 | **推翻**（ore 遍地不建武器坊）|
| farming survival-crush 壓制 | **urgency=0.00 遍地**，farming score 低 1.0-1.5 不碾 | **推翻**（crush 沒 fire，糧 76k 豐 urgency 恆 0）|

## 真根：facility 選址 argmax 低估 weaponsmith
FAC-SPEC 60 筆（§④b）：
- **civ tile**：workshop 4.44+ 碾（terrain_fit 2.0 forest × deficit 膨脹）→ weaponsmith 是 military-only 不同 outpost 不競爭，但 civ outpost 佔多 → 武器坊沒地建。
- **mil tile**：weaponsmith score 3-4.5（ore_iron 鄰）卻常輸 **stable(3.0 horses)/apothecary(3.0 herb)/armorsmith** → weaponsmith 全樣本只中 1 次。
- ∴ **weaponsmith 在 argmax 中系統性被壓**（civ 被 workshop、mil 被 stable/apothecary），非 ore/farming。

## ★交你 code-confirm
- **workshop `_facility_deficit` 為何恆高**（workshop score 4.4+ 遍地）？goods/tools/arrows 三 output 的 deficit 加總膨脹 workshop base？→ 若 workshop deficit 過度膨脹壓過 weaponsmith = facility-scoring 失衡真根。
- weaponsmith deficit（`_deficit_weaponsmith`）算出來多低？vs workshop。
- fix 方向 = **facility-scoring 平衡**（weaponsmith 相對權重 / workshop deficit 上限），非 ore_iron 供給 spec（ore 夠）、非 farming-crush（沒 fire）。

## 溯源
raw `docs/measurements/2026-07-21-weapon-facility-{census,facspec}-9c084d3a*`。instrumentation revert、main clean、gate-red 解除。你 merged 的 `Probe.bump_sample`(798f4e22) 下次 measure 我改用（免手動 print/免觸 gate，謝）。
