---
from: systems
to: implementer
status: consumed
topic: "[dispatch·seam#2 S1] _facility_deficit match→FACILITY_DEF registry(byte-identical 擴充)。R② 補完 schema 後 CLEAN(agg_mode+output_scale 兩欄補 apothecary×0.5/workshop-armorsmith 聚合異質)。★逐 case file:line 驗 byte-identical:apothecary ×0.5、workshop min-per-res≠armorsmith pooled-sum 不可共用迴圈。TDD + git per-slice。worktree feat/seam2-facility-registry off origin/main(含 S1 registry 5cfc2483)。"
---

# seam#2 S1 dispatch：_facility_deficit → FACILITY_DEF registry（byte-identical 擴充）

## scope
spec `docs/superpowers/specs/2026-07-17-seam2-facility-deficit-registry.md`（讀 §目標 schema——R② 補完版）。
`_facility_deficit`（`faction_ai_system.gd:3061-3116`）的 `match facility:` → `FACILITY_DEF` registry data entry + 泛型 evaluator（A 類）+ special_evaluator（C 類）。加設施=1 entry。**byte-identical 純擴充**（S6 已 NeedOracle 單源，只重構讀取結構）。**不動** NeedOracle、不動 facility gating 語意、不碰 `_pick_facility`（S2 低優先）。

## ★byte-identical 硬要求（R② 抓 2 缺口，逐 case file:line 對照）
schema 見 spec，**5 A-case + 3 C-case 逐一比對原 `:3061-3116`**：
- **apothecary（`:3083-3085`）：deficit ×0.5 尾乘**（`output_scale:0.5`）——workshop/armorsmith/smeltery/stable 無此乘。泛型 evaluator 漏乘=必破 byte-identical。
- **workshop（`:3076-3081`）=`min_per_res`**（goods/tools/arrows 逐資源算比取**最差** worst bottleneck）**≠ armorsmith（`:3090-3096`）=`pooled_sum`**（armor_low+high 先加總持有 vs 加總目標再算一次比，可互抵）。**兩種互斥聚合，不可共用同一段迴圈**——evaluator 依 `agg_mode` 分支。
- workshop `use_demand:true`（`:3077 need_keep+demand`，tools/arrows 的 demand 恰=0）；其餘 A 類 use_demand:false（純 need_keep）。
- armorsmith ×`_militancy`（`militancy_scaled:true`）；smeltery gating=weapon/armorsmith 存在（`:3099`）。
- **C 類 special_evaluator 保原邏輯**：weaponsmith（`0.6−armed_ratio×militancy` `:3089`）、mint（tile ore 二元 `1.0 if ore>10 else 0` `:3103-3111`）、granary（local food `:3068-3072`）——**不泛型化**。

## TDD
1. characterization test：現況 `_facility_deficit` 對代表 ctx（各 facility × 資源分佈不均 case，特意觸 apothecary 0.5 / workshop min vs armorsmith pooled 差異）的**輸出 + Probe 計數** snapshot。
2. registry 化重構（FACILITY_DEF + 泛型 A evaluator + C special）。
3. snapshot 綠（各 facility deficit 值 + Probe byte-identical）。
4. 擴充 proof：加 dummy A 類設施=1 entry，證自動納入。
5. **git commit per green step**。

## 工作區
- worktree `feat/seam2-facility-registry` off **origin/main**（已含 seam#1 S1 registry merged 5cfc2483，可 reuse options.gd registry idiom）。
- handback 回 main mailbox `A:\GDS\demo\docs\superpowers\handbacks\` to:systems。

## 完成 → 下一站
done + 綠 → to:measurer（byte-identical 中性複核:各 facility deficit seeded 對照 + Probe 計數 + 擴充 proof，同 seam#1 S1 法）。measurer 綠 → to:systems 判 merge。

## 溯源
spec（R② 補完 CLEAN，reviewer `2026-07-17-reviewer-to-systems-seam2-r2-verdict.md`）；seam#1 S1 pattern（merged 5cfc2483）；need-oracle S6；[[feedback_full_transient_observability]]（Probe byte-identical）。
