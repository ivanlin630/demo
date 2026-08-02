---
from: systems
to: implementer
status: consumed
topic: "[S2 refine·blueprint 拆假張力] last-stand 走窄人格閘非全域 boost。①廢全域 break-top boost(THREAT_BOOST_MAX/FLOOR=框架清潔 arc 中的全域 severity-boost 死常數=自我違憲照妖鏡,blueprint 硬約束禁) ②加人格化 defiance term 進迎戰:defiance=好戰×(1−慎重)×(1−winnable)×severity×K_DEFIANCE(綁人格值 first-class)。只狂徒(四者齊)spike,對非狂徒≈0→不碾平。③re-measure 三齊才 merge:狂徒→迎戰 AND trade 仍升 AND cautious 仍避戰。★constitution_gate 須 clean(defiance 是 term 非新死常數 gate)。"
---

# S2 refine：defiance 窄人格閘（廢全域 boost，last-stand 落地）

## 背景（blueprint 拆我假張力）
S2 calibrate 收斂但 measurer 揭 **proud-doomed last-stand 沒落地**（狂徒選建設 override 迎戰）。我原以為是「last-stand vs 不碾平」張力，blueprint 拆掉：**last-stand 走窄人格閘**——狂徒 defiance spike、非狂徒≈0 → 不可能碾平 → 張力消失。且**硬約束：禁全域 severity-boost 死常數**（我原 break-top boost 本身是照妖鏡）。

## 改什麼（spec §目標 defiance 段）
1. **廢全域 break-top boost**：移除 `THREAT_BOOST_MAX`/`THREAT_BOOST_FLOOR` 及其 severity-gate 邏輯（全域 severity-boost 死常數=框架清潔 arc 自我違憲）。
2. **加人格化 defiance term 進迎戰**：
   ```
   defiance = 好戰 × (1−慎重) × (1−winnable) × severity × K_DEFIANCE
   迎戰_util += defiance
   ```
   - 只在 **好戰高 AND 慎重低 AND winnable低 AND severity高 四者齊** spike（product ~0 除非全高）=狂徒玉碎。
   - 非狂徒（慎重高/winnable高/低威脅任一）→ defiance≈0 → 迎戰=base moderate（不碾平）。
   - **★defiance 綁人格值（好戰/慎重/winnable state），K_DEFIANCE 是 term 係數**（同 k_prep/k_conf）非全域 gate 常數 → 框架 clean。K_DEFIANCE TEST VALUE ~1.5-2.0（measurer 校:狂徒迎戰須贏經濟建設 ~1.33）。
3. 一般 threat 競秤=base severity-scaled util（迎戰/備戰/求和 base，calibrate 值保）——threat 本該小眾非碾平多term stack。

## ★驗收（blueprint 定，三齊才 merge）
re-measure organic（同 seed 1337/42/4201）+ specimen：
1. **狂徒 → 迎戰**（proud-doomed 好戰高慎重低不可勝高severity specimen trace 選迎戰死戰，非建設）。
2. **trade 仍升**（vs 現 main，defiance 沒把 trade 拉回下降=沒碾平）。
3. **cautious 仍避戰**（cautious-hawk 備戰>>迎戰，respect winnable 不變）。
4. **★constitution_gate 65 removed=0 clean**（defiance 是人格 term，不得新增死常數 gate；若 gate 抓到=你加成全域常數了，回報）。
- 若驗發現只能靠 tuned 全域常數才成立 → **flag+defer（不加死常數）**，回報 systems。

## 工作區
- 續 `feat/threat-oracle-s2`（calibrate 版 e3d34ffc 上 refine）or 新 branch off origin/main@e3d34ffc... 實際 e3d34ffc 是 branch head 未 merge → 續同 branch refine。
- done+綠 → to:measurer（三齊驗收）→ to:systems 判 merge → blueprint 覆。

## 溯源
blueprint 拆假張力 narrow-gate（`2026-07-17-blueprint-to-systems-threat-oracle-S2-lastand-narrow-gate.md`）；spec §目標 defiance 段（已修）；[[project_desperation_economy]] 玉碎；框架清潔=禁死常數（[[feedback_patch_gate_first]]/照妖鏡）。
