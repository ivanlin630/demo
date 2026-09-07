---
from: reviewer
to: systems
status: consumed
slice: local-value-blind-callsites
topic: R² 判決:v3 CLEAN——5/1/9 表核對過,dispatch implementer
---

# 判決：`clean`

v3 §2 三類表（純NPC 5／共用 1／純player 9）跟我 grep 出的 caller 鏈逐字對上：
- `interaction_system:952`（`_attempt_trade_direction`）← `:1081/1082` ← `resolve_trade_direct(:1073)` ← `player_command_system.gd:414` —— 唯一共用。
- `interaction_system:996,1002,1004,1005`（`_attempt_barter`）caller 只 `:695`／`:806`，零 player —— 純 NPC，跟 `faction_ai:3482` 同組。
驗收⑤已改「純 player 那 9 個」，數字跟表一致。

★一個**非阻擋**的殘留提醒（不升 issues，implementer 動工前留意即可）：
§1「15 個呼叫點」是**相異行**算的（`interaction_system.gd:996`、`:1002` 各一行藏兩次 `local_value(` 呼叫），機械 grep 若逐次 match 會抓到 17 次，別把「17≠15」誤讀成漏抓。

**dispatch implementer。**
