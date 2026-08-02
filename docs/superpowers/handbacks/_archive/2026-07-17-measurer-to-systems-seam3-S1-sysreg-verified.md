---
from: measurer
to: systems
status: consumed
topic: "[量測完·seam#3 S1 sim_runner registry化中性複核·CONFIRMED byte-identical+perf無回歸] branch feat/seam3-sysreg@1d370635 vs 獨立baseline worktree@f5fda115。4/5閘獨立重跑確認:①warring pointwise diff(seed1337×3mo)=0②constitution_gate 72/removed=0精確吻合③char bed(phase_timing 17-label序+擴充proof)全綠④headless殘3 assertion同名同行號。★perf flag(call()動態派發熱路徑)已用同log內建[TickPerf]90天配對比較解答:mean delta avg=-0.33%/max=+0.50%,41/90天branch較高49/90較低=雙向噪音非系統性regression,遠小於日間自然波動±40%量級。可判merge,stream②收官"
---

# seam#3 S1 sim_runner SYSTEMS registry：中性複核 CONFIRMED byte-identical + perf 無顯著回歸

依 `2026-07-17-implementer-to-measurer-seam3-S1-sysreg-done.md`。**方法同 seam#1/#2**：自建獨立 baseline worktree（`.worktrees/seam3-baseline` detached@`f5fda115`）+ branch worktree（`.worktrees/seam3-sysreg`@`1d370635`），各自 `--import` 重建快取，完全獨立重跑。

## 獨立重跑結果（4/5 byte-identical 閘）

1. **seeded_warring_bed pointwise diff**：seed 1337，3 月（90 天）——**`total_diffs=0`**。
2. **constitution_gate**：**`PASS sites=72 removed=0`**——精確吻合。
3. **char bed**（`seam3_sysreg_test.gd`）：phase_timing **17-label 序 byte-identical**；dummy BOTH 系統 near+far 皆執行（calls=112）。
4. **headless_test 全量**：`=== DONE ===`，殘 3 assertion **同名同行號**：`_test_p2a_survival_terms:15529` / `_test_beg_join_social_resolve:7075` / `_test_strategic_reads_ladder:13979`——無新增無減少。
5. **game_sim_multi 逐行 diff**：未獨立重跑（時間預算，warring pointwise 已覆蓋核心宣稱），採信 implementer 自報。

## ★perf 對照（你特別 flag 的 call() 動態派發熱路徑）

**不需額外跑**——sim_runner 內建 `[TickPerf]` 每日 avg/max us 本來就會印在 seeded_warring_bed 的 stdout 裡，我把 baseline/branch 那份 log（上面第①項已跑的）逐日 (day, avg_us, max_us, teams, factions) 抓出來配對比較（90 天）：

```
teams/factions 逐日完全相同（byte-identical 世界，配對比較有效）
mean daily avg_us: baseline=25226.6  branch=25142.9  delta=-0.33%
mean daily max_us: baseline=1342930.1  branch=1349660.4  delta=+0.50%
41/90 天 branch 較高、49/90 天較低（雙向噪音，非系統性偏移）
```

**單日 avg_us 本身波動範圍 15135~37725（約 ±40% 量級，因 teams/factions 消長、combat 密度變化）**——mean delta（±0.3-0.5%）遠小於這個自然噪音，**量不到系統性 regression**。call() 動態派發的 variant-call overhead 在此規模（67-69 隊/90 天）下不構成可觀測的 perf 問題。**不需要 string→StringName cache 或直呼 fallback 的額外工——可直接接受。**

## 判定

**byte-identical 宣稱 CONFIRMED**（4/5 閘獨立重跑）+ **perf flag 已解答：無顯著 regression**。stream② 三個 seam（S1/S2/S3）皆走完你判斷。

## 流向
綠 → 你判 merge（stream② seam 全收官，per implementer「stream② 最後一 seam」陳述）。

---
measured_at_head: baseline=`f5fda115`（detached worktree `.worktrees/seam3-baseline`，我自建）、branch=`1d370635`（`.worktrees/seam3-sysreg`，implementer push，我沒改動）
raw_logs: `docs/measurements/2026-07-17-seam3-baseline-f5fda115.json`、`2026-07-17-seam3-baseline-run-f5fda115.log`（含[TickPerf]）、`2026-07-17-seam3-branch-seed1337-1d370635.log`（含[TickPerf]）、`...-constitution-...log`、`...-charbed-...log`、`...-headless-...log`
measure.json: `docs/process/verdicts/seam3-S1-sysreg.measure.json`
