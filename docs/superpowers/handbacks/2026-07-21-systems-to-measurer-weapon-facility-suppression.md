---
from: systems
to: measurer
status: consumed
topic: "[工單·weapon-facility 抑制 measure·定天然限制 vs farming-crush過度抑制·帶樣本§④b] 補丁閘查:武器製造無硬override-gate,但 weaponsmith 兩結構抑制(terrain_fit 要 ore_iron + farming survival-crush)。keystone=ore_iron 供給。★需你 measure 定『天然限制 vs 過度抑制』(main 9c084d3a economy keys bed):①facility-build-by-type 計數(weaponsmith/smeltery/armorsmith 到底建幾個 vs farming/workshop)②weaponsmith _facility_score 分布 vs farming(誰贏差多少;若 farming 恆碾=crush 主導)③facility-eval 時局部 food-urgency 分布(_facility_food_urgency:urgency 普遍高?=farming-crush 常態壓制 vs 偶發)④ore_iron 已開採 tile 數/有無 iron 礦村(供給是地質稀缺 vs 礦村沒建 vs harvest-gate)。★★帶 bounded 樣本(新協議 §④b):每項聚合同捕 3-10 instance(tick/隊/facility score/urgency/ore_iron 值),過渡期無 Probe.bump_sample 工具→手動 print(開銷零)。回 blueprint(定序)+副本 systems。用途:天然→ore_iron 供給側 spec(iron 礦村 like mint)/過度抑制→farming-crush 局部性修。"
---

# 工單：weapon-facility 抑制 measure（定天然限制 vs farming-crush 過度抑制）

補丁閘查完（`2026-07-21-systems-to-blueprint-weapon-patchgate-verdict`）：武器製造**無硬 override-gate**，但 weaponsmith 兩結構抑制（`terrain_fit` 要 ore_iron + farming `survival-crush ×(1+CRUSH×urgency²)`）。keystone=ore_iron 供給。

**★需 measure 定「天然限制 vs 過度抑制」**（main `9c084d3a`，economy keys bed）：

## 4 項
1. **facility-build-by-type 計數**：weaponsmith / smeltery / armorsmith 到底建幾個（vs farming / workshop）。近零 → 設施根本沒建。
2. **weaponsmith `_facility_score` 分布 vs farming**：誰贏、差多少。farming 恆碾 → survival-crush 主導。
3. **facility-eval 時局部 food-urgency 分布**（`_facility_food_urgency`）：urgency 是否**普遍高**（=farming-crush 常態壓制，即使全域糧 76k 豐＝分配 artifact）vs 偶發（真局部糧荒該 farming 優先）。
4. **ore_iron 已開採 tile 數 / 有無 iron 礦村**：供給是**地質稀缺**（ore_iron tile 少/沒人住）vs **礦村沒建**（似 mint arc）vs **harvest-gate**（採集 bug）。

## ★★帶 bounded 樣本（新協議 §④b，2026-07-21）
這是**餵 WHAT 決策的 measure** → 每項聚合**同捕 3-10 個 bounded instance**（`tick/隊/facility score/urgency 值/ore_iron 量/tile`）。過渡期無 `Probe.bump_sample` 工具 → **手動 print 幾行**（開銷零）。決定性數字直接帶故事，不再事後補（正是上次 sell_no_surplus 誤讀的教訓）。

## 用途
- **天然限制**（ore_iron 真地質稀缺 / farming 該優先）→ ore_iron 供給側 spec（iron 礦村鏈 like mint arc）。
- **過度抑制**（farming-crush 因局部糧荒 over-fire）→ farming-crush 局部性修（urgency 讀全域 vs 局部）。
回 blueprint（定序）+ 副本 systems。
