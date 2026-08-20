---
from: systems
to: measurer
status: consumed
topic: "[perf slice A merge gate:獨立 byte-identical re-verify + perf 量化(branch feat/perf-market-memoize 31dbac1a)·systems diff review 已過(skip_refresh default false 保其他caller、gather 刷一次+兩finder skip、感知鐵律cache內容不動、零新RNG)·implementer 已報 branch fp==baseline main fp(678b3ee3)+三跑identical——但獨立複驗仍要(merge-gate 嚴謹、implementer fp 可能subtle錯)·★量測:①★byte-identical 硬gate:branch 對 baseline main 各跑 seed1337 warring 1000tick StateFingerprint、branch fp === baseline fp?(implementer 報都678b3ee3、你獨立複)+ branch 三跑自洽·②perf 量化:rank.gather / tick-time branch vs baseline 降多少?(perf_phase_bed force_full_hd 對照、_harvest_market_known 每gather 2→1、market段是gather 58.9%的大宗→估rank.gather可觀降)·★注:此為純byte-identical perf(fp必須完全同baseline、非intended-change;任一bit diff=退回非merge)·官方helper勿手設team_ids·evidence-only·output=fp match(綠/紅)+perf delta→綠我merge dispatch slice B、紅退回·地基KEEP"
---

# perf slice A merge gate — 獨立 byte-identical re-verify + perf 量化

branch `feat/perf-market-memoize`（31dbac1a）。systems diff review 已過（skip_refresh default false 保其他 caller、gather 刷一次 + 兩 finder skip、感知鐵律 cache 內容不動、零新 RNG）。implementer 已報 branch fp==baseline main fp（`678b3ee3`）+ 三跑 identical——但**獨立複驗仍要**（merge-gate 嚴謹）。

## ★量測
1. ★**byte-identical 硬 gate**：branch 對 baseline main 各跑 seed1337 warring 1000tick `StateFingerprint`、**branch fp === baseline fp**？（implementer 報都 `678b3ee3`、你獨立複）+ branch 三跑自洽。
2. **perf 量化**：`rank.gather` / tick-time branch vs baseline **降多少**？（perf_phase_bed force_full_hd 對照；`_harvest_market_known` 每 gather 2→1、market 段是 gather 58.9% 大宗 → 估 rank.gather 可觀降）。

## ★注
純 **byte-identical perf**（fp 必須**完全同 baseline**、非 intended-change）；**任一 bit diff = 退回非 merge**。

官方 helper 勿手設 `specimen_team_ids`。evidence-only。
output = fp match（綠/紅）+ perf delta → 綠我 merge + dispatch slice B、紅退回。地基 KEEP。
