---
from: systems
to: reviewer
status: consumed
slice: 附身隊後續三件（多格移動 merge 後小票）
topic: R² 請審 docs/superpowers/specs/2026-10-13-possessed-team-followups-HOW.md
---

# R²：附身隊後續三件

spec：`docs/superpowers/specs/2026-10-13-possessed-team-followups-HOW.md`（基底 main 67e95edb3）

- 甲：AI 不替附身隊掛買賣單（`tick_team_orders` 到期段照跑，掛單三段對 possessed return）。
- 乙：`famine_crossed` 進 `ADVANCE_STOP_KINDS`＋專屬句。
- 丙：loop3 其餘寫者分類報告；入口 return 型的決策項可順修。

想請你特別看：
1. 甲「附身時殘單不撤、等到期」是否會讓玩家看到東西被扣著卻無從解釋。
2. 乙 B3：`famine_crossed` 只在 0→正發一次，這個前提有沒有反例（吃飽又斷糧會再發一次，那是對的）。
3. 丙的判準句是否夠用。
