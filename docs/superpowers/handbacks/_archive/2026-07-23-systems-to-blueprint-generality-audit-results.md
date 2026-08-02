---
from: systems
to: blueprint
status: consumed
topic: "[generality 盤點結果·①③⑤ confirmed-general 免重查·②material-specific(tools 走 passive orders 已通)·★④smeltery+armorsmith 同款 afford-ceiling 洞(material 80→120>117,weaponsmith 降 70 這兩個沒降)] 用戶對:盤點今天 fix 通用度。①material need-generation=confirmed-general(_construction_facility_need 迴圈所有 facility 讀各自 build-cost{material,tools}+_facility_deficit,非 weaponsmith 專屬;所有 facility build-cost 只有 material+tools 故全涵蓋)②buy-material 動作=material-specific(options 買料硬寫 material_shortfall/has_material_market ctx;但 tools 走 order_system passive buy-orders 已通[795 單],其他 res 若 passive orders 夠就不需 active 買-option,emergent 別預建)③produce_need demand-responsive=confirmed-general(produce_pull 掃隊所有可造 outputs、生產 task 通用跨所有製造設施,非 workshop 專屬)④weaponsmith cost70=specific,★但同款洞在 smeltery(material 80)+armorsmith(material 80)——×1.5=120>天花板 117=weaponsmith 降 70 前的同洞,這兩個沒降(mint 100→150 有 bootstrap 覆蓋、其餘 material≤60 ×1.5<117 安全)⑤workshop-build=confirmed-general(已確認)。★建議:smeltery/armorsmith 是確認同洞(非臆測),cheap fix(降 cost 如 weaponsmith)但非急(還被上游 food/facility-build 堵、military 隊還沒到建這步);列入意識、等軍事鏈浮現時同款修,或你要現在順手降兩個 cost 我照辦(balance 你裁)。連長程計劃 heads-up:①means-end material-need 是那個 means-end graph 的雛形。"
---

# generality 盤點結果（用戶問：今天 fix 通用度）

| # | fix | 通用度 | 說明 |
|---|---|---|---|
| ① | material need-generation | **✅ confirmed-general** | `_construction_facility_need` 迴圈**所有 facility** 讀各自 build-cost（`CONSTRUCTION_COST_RES={material,tools}`）+ `_facility_deficit`。非 weaponsmith 接線。**所有 facility build-cost 只有 material+tools**（FACILITY_DEF 全查）→ 全涵蓋。任何設施慾望→驅其 material/tools need。 |
| ② | buy-material 動作 | **⚠ material-specific** | `options 買料` 硬寫 `material_shortfall`/`has_material_market` ctx = 只認 material。**但 tools 走 `order_system` passive buy-orders 已通**（795 單成功）→ 其他 res 靠 passive orders；active 買-option 只 material 有。**若某設施的 build-res 靠 passive orders 送不到才需 parameterize**（emergent，別預建）。 |
| ③ | produce_need demand-responsive | **✅ confirmed-general** | `produce_pull` 掃隊**所有可造 outputs**（RECIPE_GROUPS）、`生產` task 通用跨**所有製造設施**（workshop/apothecary/smeltery/armorsmith…）。非 workshop 專屬。任何設施 outputs 好賣→demand-responsive 生產。 |
| ④ | weaponsmith cost 80→70 | **⚠ specific + 同洞未修** | 見下。 |
| ⑤ | workshop-build 稀少 | **✅ confirmed-general** | 已確認（food-security 下游，不限武器坊）。 |

## ★④ 同款 afford-ceiling 洞（用戶直覺對）——smeltery + armorsmith
afford×1.5（全域 `_dispatch:2801`）vs material 天花板 ~117 → **material ≥ 78 的設施撞洞**（×1.5 > 117）。逐查 FACILITY_DEF：
| 設施 | material | ×1.5 | 判 |
|---|---|---|---|
| farming 30 / stable 40 / apothecary 50 / workshop 60 | ≤60 | ≤90 | ✅ 安全 |
| **smeltery** | **80** | **120** | ★**同洞**（>117，military-only，未降） |
| **armorsmith** | **80** | **120** | ★**同洞**（>117，military-only，未降） |
| weaponsmith | 70（已降） | 105 | ✅ 已修 |
| mint | 100 | 150 | ✅ bootstrap grant 150 覆蓋（S3b） |

- **smeltery + armorsmith = 確認同洞**（非臆測）：material 80，同 weaponsmith 降 70 前，×1.5=120 > 117 → **同樣「天花板差一點過不了」**，這兩個沒跟著降。
- **非急**：還被上游堵（food-security→facility-build 稀少、military 隊還沒到建這步），降了短期也不會建。
- **建議**：列入意識（同族洞），**等軍事鏈浮現時同款修**（cheap：降 cost 如 weaponsmith）；或你要**現在順手降 smeltery/armorsmith cost** 我照辦（balance = 你裁；smeltery 還有 weapon/armorsmith-存在 gating，armorsmith 是 C-class militancy）。

## 結論
- **①③⑤ confirmed-general**（免重查，機制自動適用全設施）。
- **② material-specific 但 tools 已有 passive 替代**（其他 res emergent）。
- **④ smeltery+armorsmith 確認同洞**（列意識，非急，等軍事鏈或你順手降）。
- 連**長程計劃 heads-up**：① 的 means-end material-need 正是那個 means-end 依賴圖的**雛形**（facility 慾望→resource need）。
