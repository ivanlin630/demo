# A1a 工單 — 拆閥（arbiter latch）

## WHAT（藍圖裁定）
決策要閉迴路：腦每 cadence 選 rank[0]、手無條件執行。現在腦手之間插了個**閥**（TaskArbiter 嚴格大於 latch），腦選 X、手被 latch 卡在舊 task Y。**A1a = 拆這個閥。**

## 前提（可 grep 驗，別信我、自己查）
- 手聽腦單點 bed（`scripts/debug/hand_obeys_brain_bed.gd` / `HandBrainProbe`）baseline（seed 1337, 1月）：**arbiter_latch = 99.0% of 違規**、freeze=0.0%。→ 閥是戰術層手不聽腦的幾乎全部。
- 現行閥：`scripts/simulation/task_arbiter.gd:24` `try_set` 用**嚴格大於**（`priority > task_priority`）→ 引擎同層 re-rank 的 rank[0] 被靜默丟。
- no-release latch：`TASK_TRAIN/MANUFACTURE/GOVERN` 無 release → 裝上後每 cadence rank[0] 全被丟＝永久 latch。

## 改動（spec 已在，精修+實作）
完整設計見 `docs/superpowers/specs/2026-07-07-A1-pipeline-collapse.md`（讀「★總綱：閉迴路」+ A1a 段）。要點：
1. `task_arbiter.gd:24` `>` → `>=`，**source-gate 引擎**：只有引擎自己的 dispatch（reason=="unified"/PRIO_DISPATCH）用 `>=`（equal-priority self-replace）；外部子系統仍嚴格大於，不能 stomp 引擎。
2. `TRAIN/MANUFACTURE/GOVERN` 加 release（仿 `TRADE_TIMEOUT`），不再永久 latch。

## 兩護欄（別做壞）
- 別把閥改成「引擎永遠贏」——外部子系統（strategic/diplomatic/player@60）仍要能合法壓過。只放行「引擎換自己的 task」。
- 別動戰鬥物理鎖（combat_target 那條）。

## 驗收（QA + 閘）
- 跑 `hand_obeys_brain_bed.gd`（seed 1337, 1月）：**arbiter_latch 應從 99% of 違規大幅掉**、determinism 逐事件 PASS。
- 憲法閘綠、無退化（其他桶別暴增）。
- 效果發生（違規率真掉），非只「改了 code」。
