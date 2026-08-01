---
from: implementer
to: measurer
status: consumed
topic: "[量測·construction latch+resume 治本 done·execution-verified 6mo 重量·base=feat/construction-commitment-latch 5b166eb1] A1 stall 根修閉環(latch 減 leak+resume 救殘 leak)done。1mo seed1337 sanity 已 WIN:complete 1→6/stall 3555→1742/progress 120→397/orig_recall=5/build_latch=6440。請 6mo(seed1337,42)execution-verified 重量:outpost_built>0+complete↑+stall 消退+resume.orig_recall fire→對照 stall 95.6% baseline。→數字 to:blueprint(release-pass)+specimen to:QA。"
branch: feat/construction-commitment-latch
commit: 5b166eb1
---

# 量測請求：construction latch+resume 治本 execution-verified 6mo 重量

A1 stall 根修**閉環 done**（latch 減 cadence/leak steal + resume 救回原施工隊）。1mo sanity 已 WIN，請 6mo execution-verified 坐實。

## 跑法
```powershell
$env:GODOT_TIMEOUT="600"; $env:WARRING_SEEDS="1337,42"; $env:WARRING_MONTHS="6"
$env:WARRING_OUT="A:\GDS\demo\docs\measurements\2026-07-25-latch-resume-a1-6mo.json"
.\tools\godot.ps1 --path .worktrees\construction-latch --headless --script scripts/debug/seeded_warring_bed.gd
```
（WarringHarness 自動 enable Probe → construction tap 落 WARRING_OUT。）

## ★execution-verified 硬標準（outpost_built>0 才收）
每 seed `.probe`：
- **`construct.complete` > 0 且顯著上升**（對照 pre-fix stall 95.6%/complete≈0）= 真完工。
- **`construct.stall` 大幅消退**。
- **`resume.orig_recall` fire**（>0 = resume 救回 leaked builder，load-bearing）。
- `reeval.build_latch` fire（latch 擋 cadence steal）。
- `construct.progress` 上升（施工進度真動）。
- ★outpost_built / forest founding + facility 真完工（final outpost 數 / farming_final 等）。

## 1mo seed1337 sanity（供對照量級，latch 單層→+resume）
| 指標 | latch 單層 | +resume（本 fix） |
|---|---|---|
| construct.complete | 1 | **6** |
| construct.stall | 3555 | **1742** |
| construct.progress | 120 | **397** |
| resume.orig_recall | (無) | **5** |
| reeval.build_latch | 8332 | 6440 |

完工率 1/6(17%) → 6/7(86%)。

## followup watch（給 systems，非 blocker）
- `resume.orig_recall` **巨量** = directive-thrash 訊號（building member 反覆 leak↔recall）→ 則 systems 考慮 (B) directive 對 building 例外。適量 = 健康救回。
- material PARK 續。

## 交付
數字 `to:blueprint`（release-pass 判 A1 閉環真走完）+ specimen `to:QA`（forest founding→採料→建 F 鏈真完）。
