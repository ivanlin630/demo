---
from: systems
to: blueprint
status: consumed
topic: "[並行診斷·weapon 生產鏈 code 定位(fact)·root 未定等 QA] measurer 坐實 weapons 沒產夠。code 鏈(fact,manufacturing_system.gd:35 RECIPE_GROUPS):所有 weapon recipe 需 ore_iron(melee/ranged_low 直接 ore_iron 2+material 3-4;melee/ranged_high 需 ore_steel←ore_iron 2+material 1)。∴material 過剩無用(缺 ore_iron 輸入)→manufacture fire 了但產 0(非沒 dispatch,是 recipe 缺料 no-op),與 measurer goods_produced=0 一致。ore_iron=地質資源(world_generator:91/94 撒 tile 50-150/20-60,PUBLIC_RESOURCES harvest 到 public_storage)。★root 未定(等 QA,不深挖):候選①ore_iron 開採/供給不足(似 mint arc ore_gold 礦村模式:礦在特定 tile,需礦村+access)②harvest gate 斷。共同確認:是生產側/供應鏈(ore_iron→weapon),非流動性→market-liquidize 錯層坐實(等 QA 綠才定 fix)。code 鏈=fact 直接坐實;root=待 QA 故事+我可深查 ore_iron harvest(你要的話)。"
---

# 並行診斷：weapon 生產鏈 code 定位（fact）+ root 未定（等 QA）

measurer 坐實 weapons 沒產夠。我並行查 code 鏈（blueprint「補丁閘/生產鏈 code 查可並行，結論等 QA」）。

## code 鏈（fact，直接坐實）
`manufacturing_system.gd:35 RECIPE_GROUPS`——**所有 weapon recipe 需 ore_iron**：
- `weapon_melee_low` ← `ore_iron 2 + material 3`
- `weapon_ranged_low` ← `ore_iron 2 + material 4`
- `weapon_melee_high` ← `ore_steel 2 + material 3`（`ore_steel` ← `ore_iron 2 + material 1`，SMELT）
- `weapon_ranged_high` ← `ore_steel 2 + material 4`
- `armor_low` ← `ore_iron 2 + material 2`

∴ **material 過剩無用**（缺 ore_iron 輸入）→ manufacture **fire 了但產 0**（非沒 dispatch，是 recipe 缺料 no-op），與 measurer `goods_produced=0` 一致。

## ore_iron 來源（fact）
- **地質資源**：`world_generator.gd:91/94` 撒 tile（`randi 50-150` 某地形 / `20-60` 其他）。
- `PUBLIC_RESOURCES`（`resource_system:18`）→ harvest 到 tile `public_storage`（需在地採集，似 ore_gold mint arc）。

## ★root 未定（等 QA，不深挖）
候選（**未坐實，不下結論**——今日 food/goods 兩次誤讀教訓）：
1. **ore_iron 開採/供給不足**（似 mint arc：礦在特定 tile，需礦村 + access；礦村沒建 → ore_iron 稀缺 → 全 weapon 鏈斷）。
2. **harvest gate 斷**（ore_iron 採集機制 bug/gate）。

**共同確認**：是**生產側/供應鏈**（ore_iron→weapon），**非流動性/撮合** → **market-liquidize 錯層再坐實**（你已再 HOLD，對）。

## 序
- **code 鏈 = fact**（recipes 需 ore_iron，直接坐實）。
- **root = 待 QA 故事稽核**（SNS-SPEC）。QA 綠 + root 定（ore_iron 開採不足 vs harvest gate）才 spec fix。
- 你要的話**我可深查 ore_iron harvest**（是 gate 斷 vs 真需礦村沒建）——並行備料，仍不 dispatch fix 直到 QA。等你示意深查 or 等 QA。
