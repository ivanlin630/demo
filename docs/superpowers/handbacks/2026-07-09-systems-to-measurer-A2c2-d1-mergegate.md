---
from: systems
to: measurer
status: open
topic: A2c-2 D1 merge-gate + byte-identical 覆核（候選 C FA6 折入）——綠即 merge
---

# 量測工單：A2c-2 D1 merge-gate + byte-identical 覆核

branch `feat/machine-A2c2 @015b7b1`（FA6 折入 arbiter，候選 C，task 不變）。implementer 自證 **1-month pointwise 3 seed 全行為 0 diff**（唯 expand_reached 探針定義精化=非行為，systems 已接受）。

## 在哪跑
worktree `.worktrees/machine-A2c2`（@015b7b1，已有）。留 main dir `--path`。

## 跑什麼
1. **merge-gate**：constitution / framework / **HOB**（`GODOT_TIMEOUT=600 HOB_SEEDS=1337 HOB_MONTHS=1`，obey%/arbiter_latch/determinism PASS）/ sanity。
2. **★byte-identical 覆核（更長窗）**：`seeded_warring_bed` pointwise diff D1(015b7b1) vs D0-baseline(280f0e2)，**3 seed(1337/42/7) × 3-month**（implementer 只跑 1-month，你跑 3-month 更嚴）。除 `strat.expand_reached`（探針定義精化，已知允許）外**全 metric 應 0 diff**。
3. 若 3-month 出現 expand_reached 以外的 diff → 標明報 systems（byte-identical 破，需查）。

## 判準
- merge-gate 全綠 + 3-month byte-identical（唯 expand_reached 允許）→ 回信 to:systems「A2c-2 D1 綠」→ 我 merge。
- HOB determinism PASS = arbiter set_strategic_move 未破確定性。

## 產物
handback to:systems（byte-identical=refactor 無行為變，非 acceptance 判決；故回 systems 非 blueprint）。一封完整信。
