# A1a 工單 — 拆閥（arbiter latch），精簡自足版

## WHAT
決策要閉迴路：腦每 cadence 選 rank[0]、手無條件執行。現在 TaskArbiter 用**嚴格大於** latch，引擎同層 re-rank 的 rank[0] 被靜默丟。A1a = 拆這個閥。**本 slice 只做兩件事，別擴張。**

## 改動（自己 grep 驗，別信我）
1. **`scripts/simulation/task_arbiter.gd:24`**：`try_set` 的 `priority > task_priority` → `priority >= task_priority`，但 **source-gate 引擎**：只有引擎自己的 dispatch（呼叫端 reason=="unified" / PRIO_DISPATCH）允許 `>=`（equal-priority self-replace，引擎換自己的 task）；**外部子系統／PLAYER 仍用嚴格大於**，不能 stomp 引擎。實作法你決定（傳參數標示 source，或分兩個 API）。
2. **四個 no-release task 加 release**：`TASK_TRAIN / TASK_MANUFACTURE / TASK_GOVERN / TASK_PRODUCE`（現在裝上永不 release＝永久 latch）。仿現有 `TRADE_TIMEOUT` 樣板（`faction_ai_system.gd:114` 附近，grep `TRADE_TIMEOUT` 找）加一個合理 timeout release，讓這些 task 每過一段能被重新競爭。timeout 用合理 test-value（照妖鏡債，日後調）。

## 護欄（別做壞）
- 外部子系統（strategic/diplomatic）、PLAYER@60、combat 物理鎖（combat_target，task_arbiter:22-23）**都不准動**。只放行「引擎換自己的 task」。
- 別碰 subset 層、別碰 side-effect 寫法（那是別的 slice：A1b/A1c，不在本 slice）。

## 明確不在本 slice（別做）
- A1b subset 折疊、A1c side-effect atomicity（faction_ai:1517 combat_target gate）＝**各自獨立 slice**，本 slice 不碰。
- 不引用 HandBrainProbe / 單點 bed（那在別的 worktree 未 merge）。驗收用下面 main 現有工具。

## 驗收（用 main 現有工具）
1. **無 GDScript 錯誤**：`.\tools\godot.ps1 --headless --import` 乾淨。
2. **不崩**：`.\tools\godot.ps1 --headless --script scripts/debug/hand_obeys_brain_bed.gd`（main 現有版）跑完無 SCRIPT ERROR、無 timeout。
3. **憲法閘綠**：`scripts/debug/constitution_gate.gd` 跑完不 FAIL。
4. **非退化**：跑一次 sanity（headless ≥1000 tick 無崩、關鍵 print 在）。
5. 效果方向：現有 bed 的 arbiter_latch/no_release 桶**該減少**（不追精確數字，方向對即可；精確單點驗收是別的 slice 的事）。
