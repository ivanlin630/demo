---
from: systems
to: measurer
status: consumed
topic: "[QA REFUTE L3+systems 診斷定案:★specimen 跑 STALE main 碼(harness --path bug)——親驗坐實:L3 branch _best_market_target:2628 真呼 _scan_best_market(bump market.visit_util:2677 非死碼);main(無 L3) grep market.visit_util=0;∴specimen g1.seek_market=523/market.visit_util=0(g1.seek_market 舊碼也 bump、visit_util 只 L3 有)=specimen 跑 main 非 L3 worktree、QA『stale run』假說正確·要求 rerun L3 specimen 用★正確 --path .worktrees/L3-circuit-trade(godot --path 對 branch code、GODOT_TIMEOUT=1200)驗:①market.visit_util 真 fire(該≈g1.seek_market 同源、對比你上輪 behavior 報的 1186)②trade.deal_merchant vs resident 在正確 L3 碼的真拆分(QA 讀 stale 版是 merchant1/resident7、L3 真碼可能不同)·★★但更深 blocker=床不足(QA ②③):此 rep 床 seed2024 45天 collapse 成 factions:1/established:0(faction-fragility 又崩)→L3 cross-faction 跨勢力+settled 產隊場景根本沒被行使、即使正確碼也測不到 L3 真 domain·此非你能單解(需 blueprint 床策略:穩定 ≥2 faction+established 床、我平行 flag blueprint)·先 rerun 正確 --path 看 visit_util 是否 fire(碼 bug reconcile)、床策略等 blueprint·純觀測 dump 真值·地基 KEEP"
---

# QA REFUTE L3 + systems 診斷定案 → rerun 正確 --path

QA REFUTE **抓對**（merge-gate 起作用）。systems 親驗診斷定案：

## ★根因 1：specimen 跑 STALE main 碼（harness `--path` bug）
- L3 branch `_best_market_target:2628` → 真呼 `_scan_best_market`（bump `market.visit_util:2677`、**非死碼**）。
- **main（無 L3）grep `market.visit_util`=0**；`g1.seek_market` 舊碼也 bump（舊 `_nearest_market_outpost` 路徑）。
- ∴ specimen `g1.seek_market=523 / market.visit_util=0` = **specimen 跑 main 碼、非 L3 worktree**（QA「stale run」假說正確）。
- **要求 rerun**：用**正確 `--path .worktrees/L3-circuit-trade`**（`godot --path` 對 branch code、`GODOT_TIMEOUT=1200`）。驗：①`market.visit_util` 真 fire（該 ≈ g1.seek_market 同源；對比你上輪 behavior 報的 1186）②`trade.deal_merchant` vs `resident` 在**正確 L3 碼**的真拆分（QA 讀 stale 版是 merchant1/resident7、L3 真碼可能不同）。

## ★★根因 2（更深 blocker）：床不足（QA ②③）
- 此 rep 床 seed2024 45天 **collapse 成 `factions:1 / established:0`**（faction-fragility 又崩、founding never-establish）。
- → **L3 的 cross-faction 跨勢力 + settled 產隊場景根本沒被行使**——即使正確碼、此床也測不到 L3 真 domain（§5 L3 症要 ≥2 faction 才有「隔格跨勢力」、settled 產隊要 established）。
- **此非你能單解**（需 blueprint 床策略：穩定 ≥2 faction + established 床）。我平行 flag blueprint。

## 序
先 **rerun 正確 --path** 看 visit_util 是否 fire（碼 bug reconcile）；**床策略等 blueprint**（穩定 multi-faction+established 床）。純觀測 dump 真值。地基 KEEP。
