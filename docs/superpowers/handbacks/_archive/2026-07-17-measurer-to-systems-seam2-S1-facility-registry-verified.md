---
from: measurer
to: systems
status: consumed
topic: "[量測完·seam#2 S1 facility registry化中性複核·CONFIRMED byte-identical] branch feat/seam2-facility-registry@df264bf5 vs 獨立baseline worktree@ad294112(我自建,非implementer提供)。5/5閘全獨立重跑確認:①seeded_warring_bed pointwise diff(seed1337×3mo)total_diffs=0②constitution_gate PASS sites=72 removed=0精確吻合③char bed 13/13逐值精確吻合(apothecary0.5/workshop0.857142857/armorsmith0.116666667等)④need_oracle_test 19/19全綠⑤headless殘3 assertion同名同行號無新增無減少。可判merge"
---

# seam#2 S1 facility registry 化：中性複核 CONFIRMED byte-identical

依 `2026-07-17-implementer-to-measurer-seam2-S1-facility-registry-done.md`。**方法同 seam#1 S1**：自建獨立 baseline worktree（`.worktrees/seam2-baseline` detached@`ad294112`，非沿用 implementer 提供的任何 dump）+ branch worktree `.worktrees/seam2-facility-registry`@`df264bf5`（已存在，implementer push），各自 `--import` 重建快取，完全獨立重跑。

## 獨立重跑結果（5/5 閘，implementer 本輪未宣稱 game_sim_multi 閘，故無缺口）

1. **seeded_warring_bed pointwise diff**：seed 1337，3 月——**baseline dump（我自己跑的）vs branch 逐點 diff：`total_diffs=0`**。
2. **constitution_gate**：branch 跑 **`PASS sites=72 removed=0`**——與 implementer 報告精確吻合（single-line guard idiom 保留 fingerprint + C 特殊方法 `_deficit_*` 不匹配 dfunc regex，零新 fingerprint）。
3. **char bed**（`seam2_facility_registry_test.gd`）：**13/13 PASS，逐值精確吻合** implementer 報告的具體數字：apothecary=0.5、workshop=0.857142857（min_per_res worst bottleneck）、armorsmith=0.116666667（pooled_sum×militancy）、smeltery gating（0.0 無設施/1.0 有）、weaponsmith=0.175、mint（1.0/0.0 ore 門檻）、farming=1.0、未知 facility=0.0、擴充 proof=1.0。
4. **need_oracle_test**（`_facility_deficit` 消費者路徑）：**19/19 PASS**（workshop/apothecary deficit-driven need 全綠）。
5. **headless_test 全量**：`=== DONE ===`，殘留 3 個 assertion **與 baseline 完全同名同行號**：`_test_p2a_survival_terms:15529` / `_test_beg_join_social_resolve:7075` / `_test_strategic_reads_ladder:13979`——無新增、無減少。

## 判定

**byte-identical 宣稱 CONFIRMED**（5/5 閘獨立重跑，非採信 implementer 自報）。constitution_gate 無 removed，implementer flag 的「零 baseline re-freeze 需求」成立。命名偏 spec 字面（`FACILITY_DEFICIT_DEF` vs spec 的 `FACILITY_DEF`）純內部命名決策，不影響行為驗證——留給你判斷是否要求對齊 spec 字面。

## 流向
綠 → 你判 merge。

---
measured_at_head: baseline=`ad294112`（detached worktree `.worktrees/seam2-baseline`，我自建）、branch=`df264bf5`（`.worktrees/seam2-facility-registry`，implementer push，我沒改動）
raw_logs: `docs/measurements/2026-07-17-seam2-baseline-ad294112.json`、`2026-07-17-seam2-branch-seed1337-df264bf5.log`、`...-constitution-...log`、`...-charbed-...log`、`...-needoracle-...log`、`...-headless-...log`
measure.json: `docs/process/verdicts/seam2-S1-facility-registry.measure.json`
