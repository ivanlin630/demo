---
from: systems
to: implementer
status: open
topic: "[dispatch build F2 treasury 域模組切(②結構首刀、byte-identical 純程序、spec docs/superpowers/specs/2026-08-07-framework-F2-treasury-module-HOW.md、R² CLEAN+caller 清單補完)·新 slice feat/framework-F2 off 更新後 main(含 F0+F1)·★純結構搬移零行為變:F0 fp 對 ce201650 baseline byte-identical(27 全同)=命門、任一 fp 漂=夾帶行為變停查非 merge·範圍:①新 CoinTreasury static module(scripts/simulation/coin_treasury.gd)逐字移 5 域函式(_extract_treasury/_extract_buffer/_consider_extraction/coin_need/_collect_member_tax=faction_ai:3175-3273+相關 const COIN_NEED_CAP/EXTRACT_BUFFER 等)零 logic 改、内部互呼内化·②介面 3 entry:CoinTreasury.consider_extraction/collect_member_tax/extract_treasury(+ coin_need/extract_buffer static 可直呼)·③★★caller 更新完整清單(R² 抓漏 debug/test、exhaustive):production=player_command:248/resource_system:177/faction_ai loop:835,836 改呼 CoinTreasury.;★debug/test 必補=extraction_need_driven_test 全篇(:54-106 extract/buffer/consider/coin_need)/material_hold_test:97,107/unified_commerce_test:224,260/★headless_test:8521(交付標準 entrypoint、不補當場炸 fp 跑不到)——全改 FactionAISystem.new()._xxx / fai._xxx → CoinTreasury.xxx·④R² 確認零反向耦合(5 函式全呼已模組化外部 AnonTreasuryBank/ResourceBank/LoyaltyBank/UnrestBank/TradeValuation/NeedOracle/ResourceSystem/DecisionTerms、shared 留原處)·守:★純 code-move 零 logic 改(逐字搬、禁夾人格化/邏輯改=①track 分 slice 不混)/F0 fp byte-identical(state_fingerprint_bed 對 ce201650 27 全同)/determinism 3-run byte-identical/constitution 綠(taskarbiter site 若隨移=同語意、baseline 路徑更新非新增)/headless 0-new/既有 arc 回歸·完成 handback to:systems R²(merge-gate 核純移零改+全 caller 更新無漏+fp byte-identical)→QA→merge=F2 收(結構 track 第一刀示範)·地基 KEEP"
---

# dispatch build F2 treasury 域模組切（②結構首刀、byte-identical）

spec：`2026-08-07-framework-F2-treasury-module-HOW.md`（R² CLEAN + caller 清單補完）。新 slice `feat/framework-F2` off 更新後 main（含 F0+F1）。★**純結構搬移零行為變**：F0 fp 對 `ce201650` baseline **byte-identical（27 全同）=命門**、任一 fp 漂=夾帶行為變停查非 merge。

## 範圍
1. **新 `CoinTreasury` static module**（`scripts/simulation/coin_treasury.gd`）逐字移 5 域函式（`_extract_treasury`/`_extract_buffer`/`_consider_extraction`/`coin_need`/`_collect_member_tax`=faction_ai:3175-3273 + 相關 const COIN_NEED_CAP/EXTRACT_BUFFER 等）**零 logic 改**、內部互呼內化。
2. **介面 3 entry**：`CoinTreasury.consider_extraction`/`collect_member_tax`/`extract_treasury`（+ coin_need/extract_buffer static 可直呼）。
3. ★★**caller 更新完整清單**（R² 抓漏 debug/test、exhaustive）：
   - production=`player_command:248`/`resource_system:177`/`faction_ai loop:835,836` 改呼 `CoinTreasury.`。
   - ★**debug/test 必補**=`extraction_need_driven_test` 全篇（:54-106 extract/buffer/consider/coin_need）/`material_hold_test:97,107`/`unified_commerce_test:224,260`/★**`headless_test:8521`**（交付標準 entrypoint、不補當場炸 fp 跑不到）——全改 `FactionAISystem.new()._xxx`/`fai._xxx`→`CoinTreasury.xxx`。
4. R² 確認**零反向耦合**（5 函式全呼已模組化外部、shared 留原處）。

## 守 / 序
★純 code-move 零 logic 改（逐字搬、**禁夾人格化/邏輯改**=①track 分 slice 不混）/ F0 fp byte-identical（state_fingerprint_bed 對 ce201650 27 全同）/ determinism 3-run byte-identical / constitution 綠 / headless 0-new / 既有 arc 回歸。
完成 → handback `to:systems`（R²、merge-gate 核純移零改 + 全 caller 更新無漏 + fp byte-identical）→ QA → merge = F2 收（結構 track 第一刀示範）。地基 KEEP。
