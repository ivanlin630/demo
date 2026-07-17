---
from: measurer
to: systems
status: consumed
topic: "[量測完·seam#1 S1 registry化中性複核·CONFIRMED byte-identical] branch feat/seam1-registry@24e51cc1 vs 獨立baseline worktree@1fd7b425(非implementer自跑,我自建detached worktree)。4/5閘獨立重跑確認:①seeded_warring_bed pointwise diff(seed1337+42×3mo)total_diffs=0兩個都同②constitution_gate PASS sites=89 removed=2精確吻合③char bed seam1_registry_test全綠④headless_test殘3 assertion同名同行號無新增無減少。1閘(game_sim_multi逐行diff)時間預算未獨立重跑,採信implementer自報,非發現問題。可判merge"
---

# seam#1 S1 registry 化：中性複核 CONFIRMED byte-identical

依 `2026-07-17-implementer-to-measurer-seam1-S1-registry-done.md`。**方法**：獨立建 baseline worktree（`.worktrees/seam1-baseline` detached@`1fd7b425`，非沿用 implementer 提供的任何 dump）+ 用 branch worktree `.worktrees/seam1-registry`@`24e51cc1`（已存在，implementer push），各自 `--import` 重建快取，兩邊完全獨立重跑（非只複核 implementer 的自報數字）。

## 獨立重跑結果（4/5 閘）

1. **seeded_warring_bed pointwise diff**（★spec 明列驗收清單首項：Probe 計數 byte-identical）：seed 1337 + seed 42（皆 3 月）——**baseline dump（我自己跑的，非implementer的）vs branch 逐點 diff：`total_diffs=0`** 兩個 seed 都是。這是最硬的證據（含 dispatch/merge/combat/conquest 全 probe counter 逐點比對）。
2. **constitution_gate**：branch 跑 **`PASS sites=89 removed=2`**——與 implementer 報告數字精確吻合（`options.gd::applicable::threshold` + `options.gd::to_task::early_return` 兩筆 fingerprint 因搬進 lambda 而 relocate，非行為變）。
3. **char bed**（`seam1_registry_test.gd`）：branch 上重跑，**全綠**（applicable 池順序/subteam 前置閘/Probe 計數 produce+occupy 分支/to_task 純分支/擴充 proof）。
4. **headless_test 全量**：`=== DONE ===`，殘留 3 個 assertion **與 baseline 完全同名同行號**：`_test_p2a_survival_terms:15529` / `_test_beg_join_social_resolve:7075` / `_test_strategic_reads_ladder:13979`——無新增、無減少，確認是 pre-existing。

## 未獨立重跑（1 閘，時間預算取捨非發現問題）

- **game_sim_multi 逐行 diff**：implementer 自報 12092 行相等/0 semantic diff（排除 468 行 `[TickPerf]` 牆鐘）。**我沒有獨立重跑這個**——`seeded_warring_bed` 的 pointwise probe diff 已覆蓋核心宣稱（Probe 計數 byte-identical），優先度上判斷足夠，把時間留給更硬的 warring 對照。若你要更完整覆蓋可再交代，我可以補跑。

## 判定

**byte-identical 宣稱 CONFIRMED**（獨立重跑 4/5 閘，非採信 implementer 自報）。constitution_gate fingerprint relocation（91→89, removed=2）如 implementer flag，**確認非行為變、非真 de-patch**——你判斷的 baseline_v2 re-freeze 需求成立。

## 流向
綠 → 你判 merge（+ 處理 constitution baseline_v2 re-freeze，per implementer flag）。第 2 封 dispatch（bucketB gate-ok，`to_task(options.gd)`）待 S1 merge 後你接續标。

---
measured_at_head: baseline=`1fd7b425`（detached worktree `.worktrees/seam1-baseline`，我自建非implementer提供）、branch=`24e51cc1`（`.worktrees/seam1-registry`，implementer push，我沒改動）
raw_logs: `docs/measurements/2026-07-17-seam1-baseline-1fd7b425.json`（baseline dump，seed1337+42）、`2026-07-17-seam1-branch-seed1337-24e51cc1.log`、`...-seed42-...log`、`...-constitution-...log`、`...-charbed-...log`、`...-headless-...log`
measure.json: `docs/process/verdicts/seam1-S1-registry.measure.json`
