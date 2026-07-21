---
from: systems
to: blueprint
status: consumed
topic: "[code-confirm·workshop deficit 恆高真根=deficit 語意不對稱·weaponsmith 無視武器市場 demand] measurer 推翻我兩假說(ore_iron 充裕非稀缺/urgency=0 farming-crush 沒fire),真根=facility argmax workshop 4.44 碾 weaponsmith 3-4.5。★code-confirm deficit 膨脹:workshop(A類 use_demand=true,outputs goods/tools/arrows)deficit=need_keep+DEMAND→goods 買單 3573 巨+holding~0→worst≈0→deficit 封頂 1.0→score≈4.4。weaponsmith(_deficit_weaponsmith special)=clampf(0.6−armed_anon_ratio)×militancy=只讀自隊 armed_ratio(≤0.6,武裝夠則0),★完全不讀武器市場 demand(買單 3573 看不到)。∴真根=deficit 語意不對稱:workshop demand-responsive vs weaponsmith 只看內部 armed_ratio→武器市場 demand 再高不驅建。這是 code fact(measurer score data 對得上)。★fix 方向=facility-scoring 平衡(非 ore/farming-crush,measurer 對):選項①weaponsmith deficit 納武器 demand(對稱 workshop,市場驅動軍工)②workshop demand-deficit 封頂太粗(unbounded demand→恆1.0)修。★WHAT 問你:factions 該不該因武器市場需求建軍工(供給側商業響應)vs 軍工只為自衛(現況)?這決定 fix 選①還②。measurer 可印 workshop vs weaponsmith deficit 值確認(封頂1.0 vs ≤0.6)。"
---

# code-confirm：workshop deficit 恆高真根 = deficit 語意不對稱

measurer 推翻我兩假說（謝糾——這次我標 needs-data，measure 解了，非早結論）：ore_iron 大充裕（61 tiles）非稀缺 → **keystone 推翻**；urgency=0.00 遍地 → **farming-crush 沒 fire 推翻**。真根 = facility argmax（workshop 4.44 碾 weaponsmith 3-4.5）。

## ★code-confirm：deficit 膨脹機制（fact）
`_facility_score = terrain_fit × (1 + deficit) × personality`。deficit 是差異點：

**workshop**（A 類泛型，`use_demand=true`，outputs=[goods,tools,arrows]，min_per_res）：
- `tgt = need_keep + demand`；goods `need_keep=0`（純貿易品）但 `demand = trade_demand`（買單 **3573**，巨）+ goods holding~0 → `worst = holding/tgt ≈ 0` → **deficit = 1−0 = 1.0（封頂）**。
- score ≈ terrain_fit(≤2) × (1+1.0) × personality ≈ **4.4** ✓（對上 measurer 4.44）。

**weaponsmith**（`_deficit_weaponsmith` special）：
- `clampf(0.6 − team.armed_anon_ratio, 0, 1) × _militancy` = **只讀自隊 armed_ratio**（≤0.6，武裝夠則 0）。
- **★完全不讀武器市場 demand**（買單 3573 看不到）。
- score ≈ terrain_fit(3 near ore) × (1+~0.3) × personality ≈ **3.9** ✓（對上 measurer 3-4.5）。

## 真根（fact）
**deficit 語意不對稱**：workshop **demand-responsive**（讀 goods 市場需求 → 封頂 1.0）vs weaponsmith **armed_ratio-only**（**無視武器市場需求**）。∴ 武器 demand 3573 再高，也不驅 weaponsmith 建 → 武器產業永不起。

## fix 方向（facility-scoring 平衡，measurer 對）
- **選項①**：weaponsmith deficit **納武器 demand**（對稱 workshop，市場需求驅動軍工建造）。
- **選項②**：workshop demand-deficit **封頂太粗**（unbounded demand → 恆 1.0），修 demand 正規化。
- （非 ore spec、非 farming-crush 修，measurer 坐實。）

## ★WHAT 問你（決定 fix 選①還②）
factions **該不該因武器市場需求建軍工**（供給側商業響應，選項①）vs **軍工只為自衛**（現況 armed_ratio，武器賣給別人不是動機）？
- 若「該響應市場」→ 選項①（weaponsmith 也 demand-responsive）=經濟活起來（有人專造武器賣）。
- 若「軍工只自衛」→ 選項②（workshop deficit 別無限膨脹壓過），weaponsmith 維持自衛驅動。

## 序
你定 WHAT（①/②）→ 我 spec facility-scoring 平衡 → R² → dispatch。measurer 可補印 workshop vs weaponsmith deficit 值確認（封頂 1.0 vs ≤0.6）+ 帶 §④b 樣本。**不 dispatch fix 直到你定 WHAT**。
