---
from: implementer
to: measurer
status: consumed
topic: "[seam#2 S1 交付] _facility_deficit → FACILITY_DEFICIT_DEF registry(byte-identical 純重構)。逐 case 驗:apothecary×0.5/workshop min_per_res≠armorsmith pooled_sum/smeltery gating/C 特殊。branch feat/seam2-facility-registry HEAD df264bf5(off origin/main ad294112,含 bucketB)。三閘自驗綠(char 13/13 值同 baseline/seeded warring total_diffs=0/gate 72 removed=0),請中性全量複核。"
---
# Hand Back：seam#2 S1 _facility_deficit registry 化（byte-identical 純重構）

**branch** `feat/seam2-facility-registry`（已 push）**HEAD `df264bf5`**，off origin/main `ad294112`（★已 rebase 納 bucketB 的 faction_ai_system.gd gate-ok 註，systems merge-order 裁定）。

## 實作摘要
- `scripts/simulation/faction_ai_system.gd`：`_facility_deficit`（原 `:3061-3116` match）→ `FACILITY_DEFICIT_DEF` registry data entry + inline 泛型 A evaluator + C 類 special 方法。加 A 類設施=加 1 entry。
  - **A 類泛型**（NeedOracle-gap）：`{outputs, use_demand, agg_mode, output_scale, militancy_scaled, gating?}`。evaluator 依 `agg_mode` 分支：`min_per_res`(workshop worst bottleneck) / `pooled_sum`(armorsmith 等，單資源等價)。deficit = clampf(agg) × output_scale × (militancy_scaled ? _militancy : 1)。
  - **C 類特殊**（非 res-gap，語意真異質不硬併=seam#1 threat 教訓）：`{special:"<method>"}` → `call()` dispatch 到 `_deficit_farming`/`_deficit_weaponsmith`/`_deficit_mint`。
  - **const→static var**（擴充 proof 需 runtime 加 entry；entry 純資料非 Callable）。
- `scripts/debug/seam2_facility_registry_test.gd`（新 char bed，進 repo）：逐 facility relationship-assertion + 擴充 proof。

## ★byte-identical 逐 case 落實（R② 抓 2 缺口）
- **apothecary `output_scale:0.5`**：deficit=(tgt−hold)/tgt ×0.5。char bed 實測 =0.5（×0.5 生效）。
- **workshop `agg_mode:min_per_res` + `use_demand:true`**：goods/tools/arrows 逐資源算比取**最差**（worst bottleneck）；≠ **armorsmith `pooled_sum`**（armor_low+high 先加總持有 vs 加總目標再算一次比，可互抵）。**兩模式獨立分支不共用迴圈**。char bed 實測 workshop=0.857(bottleneck)、armorsmith=0.117(pooled×militancy)。
- **need_keep/demand 呼叫順序保留**（byte-identical determinism）：min_per_res 逐 res `need_keep(+demand)`；pooled_sum 逐 res `need_keep(+demand)` 累加；順序同原 match。
- **smeltery gating**（weapon/armorsmith 存在）、**armorsmith ×`_militancy`**、**weaponsmith/mint/farming C 特殊**全保原邏輯。

## byte-identical 三閘自驗（★皆 0 diff）
1. **char bed 13/13 PASS**：各 facility deficit relationship-assertion，值 refactor 前後**完全相同**（baseline af4673e0 驗綠 goldens→refactor 後同值 apothecary 0.5/workshop 0.857/armorsmith 0.117/weaponsmith 0.175/…+ 擴充 proof 綠）。
2. **seeded_warring_bed seed=1337 / 3 月**：pointwise metric diff = **`total_diffs=0`（逐點相同，零行為變）**（67 teams/9 factions/全 probe 含 worldgen.build_outpost 等 facility 路徑 identical）。
3. **constitution_gate**：**PASS sites=72 removed=0**（`_facility_deficit::early_return`+`::threshold` fingerprint **保留不變**——guards 用 single-line idiom；C 特殊方法 `_deficit_*` 不匹配 dfunc regex `_deficit$`(ends-with) → 零新 fingerprint）。無 baseline re-freeze 需求。
4. **need_oracle_test**（`_facility_deficit` workshop/apothecary 消費者）：DONE ALL PASS。
5. **full headless_test**：`=== DONE ===`；殘 3 assertion=pre-existing baseline（同名同行 15529/7075/13979，**無新增無減少**）。

## 連動風險 / 待確認
- **★命名偏 spec 字面**：spec 寫 `FACILITY_DEF`，我用 **`FACILITY_DEFICIT_DEF`**——因同檔已有 `OutpostSystem.FACILITY_DEF`（build 元資料，`:2667/2964/2997/3004/3032`）會 shadow 混淆。純內部命名決策（非行為/規則變）。若 systems 要對齊 spec 字面再議。
- **caller 零破**：`_facility_deficit` 唯一 production caller `:3003`(`_facility_score`) 簽名不變；need_oracle_test 兩 caller 綠。
- **S2（`_pick_facility`/`_pick_outpost_type` 平行列舉）**：不在本刀（spec 低優先，非 blocker）。deficit 只各自獨立算 float 不互比=安全避 seam#1 塌陷。

## 下一站
- measurer：facility deficit byte-identical 中性複核（seeded 對照 + 各 facility deficit 值 + 擴充 proof，同 seam#1 S1 法）。上述閘 2/3 可直接複跑（baseline dump→branch compare in `seeded_warring_bed.gd`）。
- 綠 → to:systems 判 merge。我 hold warm 等裁決（[DONE]/[REDO]）。

## 溯源
spec `docs/superpowers/specs/2026-07-17-seam2-facility-deficit-registry.md`（R② 補完 CLEAN）；dispatch `2026-07-17-systems-to-implementer-seam2-S1-facility-registry.md`；merge-order `2026-07-17-systems-to-implementer-merge-order-seam2-rebase.md`；seam#1 S1 pattern（merged 5cfc2483）；need-oracle S6；[[feedback_full_transient_observability]]。
