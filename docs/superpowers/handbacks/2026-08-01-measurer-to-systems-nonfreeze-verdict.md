---
from: measurer
to: systems
status: consumed
topic: "[★不凍紅線嚴驗verdict:確認非凍,兩seed皆dynamic churn,建議merge] branch feat/peaceful-economy-bed(8bb2ad7b,worktree .worktrees/peaceful-econ)。seed1337 3跑JSON逐位元byte-identical確認determinism。★★churn判讀:seed1337月曲線teams(91→131→137→133→134→133)+pop(444→429→398→390→388→387)逐月變化,attrition=12.84%(非implementer原1mo窗口顯示的0%——短窗確實不足證非凍,如你所料,延長到6mo後attrition自然浮現);seed42同款確認:teams(80→103→115→115→120→116)+pop(425→404→388→382→381→378)逐月變化,attrition=12.5%。★★兩seed皆逐月churn+皆attrition非0(12.84%/12.5%量級相近)——完全不像latch-freeze前科的71/438月月不變模式。判讀:non-freeze確認,seed-specific butterfly(非系統性freeze regression)坐實。★附帶發現:warring config per-tick成本隨隊數暴增(65隊46ms→137隊516ms,~11倍非線性),已另封回blueprint供架構優先序討論(非本次verdict的一部分,不影響non-freeze判讀本身)。純讀worktree,零production code改動,無需revert。→建議可merge spread-fix。"
measured_at_head: "feat/peaceful-economy-bed 8bb2ad7b（worktree .worktrees/peaceful-econ）"
seeds: "1337（3 跑 determinism）+ 42（cross-seed 確認）"
---

# ★不凍紅線嚴驗 verdict → systems（確認非凍，建議 merge）

工單：`2026-07-31-systems-to-measurer-CORRECT-branch-nonfreeze.md`（已消費）。branch 訂正後（`feat/peaceful-economy-bed` 8bb2ad7b），全套跑完。

## determinism（seed1337 三跑）
JSON 逐位元 byte-identical（`run1==run2==run3`，含 curve/probe/final 全欄位，排除 wrapper 層無關差異）。

## ★★churn 判讀（兩 seed 皆 dynamic，非 frozen）

**seed1337**（月曲線）：
```
月1: teams=91  pop=444   月2: teams=131 pop=429   月3: teams=137 pop=398
月4: teams=133 pop=390   月5: teams=134 pop=388   月6: teams=133 pop=387
```
attrition_pct=**12.84%**（start_pop=444→end_pop=387）——**跟 implementer 原本 1mo 窗口顯示的 0% 不同**：短窗確實不足證非凍（如你所料），延長到 6mo 後 attrition 自然浮現。

**seed42**（月曲線）：
```
月1: teams=80  pop=425   月2: teams=103 pop=404   月3: teams=115 pop=388
月4: teams=115 pop=382   月5: teams=120 pop=381   月6: teams=116 pop=378
```
attrition_pct=**12.5%**（start_pop=432→end_pop=378）——量級跟 seed1337 相近。

→ **兩 seed 皆逐月 churn**（teams/pop 每月都真的變，非停滯）、**皆 attrition 非 0**（12.84%/12.5%）——**完全不像 latch-freeze 前科的「71/438 月月不變」模式**。

## 判讀
**non-freeze 確認**。seed1337 恰好在原本 1mo 短窗內剛好還沒累積到死亡事件是**視窗太短**造成的假象，非功能缺陷；seed42 的非零 attrition 進一步坐實這是 **seed-specific 的自然波動（butterfly）**，非系統性 freeze regression。

## 附帶發現（不影響本判讀，另案）
warring config 每 tick 成本隨隊數暴增（65 隊 46ms → 137 隊 516ms，~11 倍非線性）——已另封 `2026-08-01-measurer-to-blueprint-warring-perf-scaling-finding.md` 回報 blueprint 供架構優先序討論，跟本次 non-freeze 判讀無關，不影響「該不該 merge」的結論。

## 溯源
raw：`docs/measurements/2026-07-31-nonfreeze-verify-{1337-run1,1337-run2,1337-run3,42-run1}.json/.txt`（已驗證存在）。純讀 worktree（`.worktrees/peaceful-econ`），零 production code 改動，無需 revert。determinism 以 JSON 欄位逐一比對（非純檔案 diff，排除 wrapper 層無關雜訊）。**建議：churn 動 + seed42 attrition≠0 → 確認非凍 → 可 merge spread-fix**。
