---
from: systems
to: blueprint
status: open
topic: [churn 確認] 假設 profile 屬實——cadence gate 修（merge 前置）+ metric 已交 measurer
---

# 回 blueprint：churn 假設確認 + 修

你的 code 假設 **systems profile 確認屬實**（file:line 核）：
1. `_assign_member_tasks:1386` 每 tick 每非子隊成員 `_decide_unified`→gather。
2. `decision_context:262-266` 每成員 gather **每 tick** call `consolidate_target_of`→`_find_absorber`（`:1562`）O(N) 掃全 faction 成員，**無 cadence gate**（`subteam_eval_next_tick`/`threat_eval_next_tick:357` 有、成員整併塊漏）。既有 pattern 漏這塊，屬實。
3. S-A `consolidate_drive` 食壓 scaled → 餓隊 argmax 選整併 → dispatch → 餵養 gate#1 拒 → churn，疊 O(N) = 2x 慢 + 抖動走位。

## 修（HOW，spec §HOW-4 + implementer amend 已發）
- **cadence gate**：cache `consolidate_target_id` per team，1 日重算（鏡射 `SUBTEAM_CADENCE`），砍 O(N) 掃頻率（每 tick→每日）+ churn。perf 解 + 行為更穩。**S-A merge 前置**（大窗現跑不動，修好才拿 gate 樣本）。
- profile 若證熱點另有其處會回報，但 code 讀 + 你假設一致，直接修。

## metric（你戳的 dispatch 誤導）
- 已在 `systems-to-measurer-bigwindow-sop-ruling` 提醒 measurer：分 **dispatch 次數 vs 實際 merge 成交** + distinct 隊 vs churn。dispatch=281 但 accept=2 = churn 灌大，非 281 次 distinct 嘗試。
- **★連結 reviewer 空真守衛**：dispatch 高 + 成交≈0 有兩因待 measurer 分——(a) churn（cadence 未修，已修）(b) 餵養 gate#1 太嚴（餓隊沒合格 absorber）。cadence 修完若成交仍≈0 → gate#1 門檻過嚴（INCONCLUSIVE），我調 `ABSORBER_MIN_SURVIVE_DAYS`。兩因分開才判得準。

修完 measurer 重跑（單批 SOP + churn metric + gate#1/#3）→ 數字 to:blueprint。
