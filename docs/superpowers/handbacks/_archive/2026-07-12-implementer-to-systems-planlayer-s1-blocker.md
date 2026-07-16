---
from: implementer
to: systems
status: consumed
topic: [卡點 S1] plan-layer Task1 demote 測試+設計矛盾—trend≤0 對常數 metric 永不觸發 + pop=10 走升 branch;需裁決
---
# 卡點：plan-layer S1 Task 1 事件驅動 demote 邏輯自相矛盾

worktree `feat/plan-layer-s1` 已建（疊 origin/main 9a5cd61）。實作前 trace plan Step 3 code + Step 1 測試，發現 **demote 路徑無法通過自身測試**，且暴露設計層問題。停下呈報（不猜改）。

## 問題 1：EWMA trend 對「常數/上升 metric」永遠 > 0 → demote 永不觸發
Step 3 code：`trend = rung_trend_ewma − rung_trend_ewma_last`，demote 條件 `if trend <= 0.0: stall_count++`。
- EWMA 遞推：`ewma_n = 0.7·ewma_{n-1} + 0.3·metric`。metric 常數 = m 時，`trend_n = 0.3·(m − ewma_{n-1}) > 0` **嚴格為正**（漸近 0 但永不 ≤0）。
- ∴ metric 不下跌時 `stall_count` **永遠不累加** → demote 永不 fire。
- Step 1 測試用 `food_flow_avg = 1.0` **常數** 期待「trend 停滯 K 次→降回 SURVIVE」→ **測試必 fail**（trend 恆 >0）。
- 結論：`trend≤0` 語意 = 「metric 實際下跌」，**非**「metric 停滯不漲」。plan 敘述「trend 停滯 K 次才降」與 code `trend<=0` 語意不符。停滯（plateau，metric 平但非降）在此 code 下**不觸發 demote**。

## 問題 2：測試隊 pop=10 → 走「升」branch，根本到不了 demote
Step 1：`_mk_team(state, 10, {野心0.5,慎重0.5})` → pop=10。demote loop 內 old=ACCUMULATE，`next_rung=EXPAND`，`milestone_met(EXPAND)= food_flow≥0.5 && pop≥8` = **TRUE**（pop 10≥8）→ 升 branch 取 → rung 升 EXPAND，**永不進 demote elif**。assert `rung==SURVIVE` 雙重必 fail。
（對照 Step 1 §T2 `_test_plan_phase_derive` 用 `_mk_team(state, 4,...)` 標「人少」佐證第二引數=pop。）

## 需裁決（不猜，等 systems 定）
**A. demote 語意 = metric 下跌**（改測試模型，不改 code）：demote 測試改讓 `food_flow_avg` 逐 cadence **下降**（如 1.0→0.3→0…），且 pop 設 <8（如 5）使 `milestone_met(EXPAND)` 為 false 才進 demote elif。code Step 3 保持 `trend<=0`。→ 語意=「持續退步 K 次才降」（承載力真跌）。
**B. demote 語意 = 停滯（含 plateau）**：改 code demote 條件為「milestone(當前 rung) 不再滿足 或 trend<=epsilon」——plateau 也降。需定 epsilon + 「milestone 掉出」判準。改動較大，動 Step 3 核心。

我方傾向 **A**（改測不改 code，最小面、保 code 簡潔；且「該降沒降的 plateau 窗」正是 Task 3 survival-bypass 要接管的——demote 只管真下跌，plateau 交 bypass，職責分層乾淨）。但語意屬設計層，systems 裁。

## 附：其餘 Step 已驗可行
- 3 欄（rung_trend_ewma/_last/stall_count）加 team_data、常數 RUNG_TREND_ALPHA=0.3/RUNG_STALL_K=3、milestone_met/_progress_metric helper、target_rung 保留（外部 caller = `specimen_tracer.gd:104`，確認保留相容）——皆無礙，等 demote 語意定案即可一次做完 + 改測 + 跑。
- test helper `_mk_min_state`/`_mk_team` headless_test **無現成**（只有 `_mk_leader_with_values:15693`）→ 我自 inline 構造 state/team（比照既有 headless 手構 pattern），不阻塞。

standby 等 systems 回（A/B 或第三案）。不冷啟、不改猜、不問 user。
