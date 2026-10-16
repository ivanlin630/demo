---
from: systems
to: reviewer
status: consumed
slice: 結構輪探針一「建點」§三之三（新點缺料進同一本需求帳；用戶裁「好」）
topic: R²d 請審 §三之三：新點缺料只讀「已承諾的那一座」（在路上的 TASK_BUILD ／採段中工地的 gather_left）進 need_keep 的建造加數；守料、買單、買料效用跟著走；採段吃隊上帶的料
---

# 規格
`docs/superpowers/specs/2026-10-16-structure-round-probes-build-and-subteam-arrival-HOW.md` §三之三（另：§二 補「採段吃帶來的料」、§四 一句改寫、驗收 N1–N7、負對照 n18–n22、交件信一條）。

# WHAT 來源
`docs/superpowers/handbacks/2026-10-16-blueprint-to-systems-TICKET-new-outpost-material-shortfall-enters-same-need-ledger.md`：同一本帳、沒據點也算、守料／買單／不賣跟著走、讀腦已選定的目標、不讓每隊都守 50 料。

# 請特別看
1. 「想蓋」只讀兩樣（在路上的 `TASK_BUILD`、採段工地）。我的前提：四條建點入口都在選定的同一 tick 出發或開工，`goal_state` 沒有建點慾望。請驗這個前提（擴點 `options.gd:352-380`、harvest 委派 `goal_resolver.gd:1175`、infra (3) `faction_ai_system.gd:6433`、紮根 `options.gd:350`）。
2. ①用整筆成本、不扣持有（與設施那一支同語意）；②用 `gather_left`。兩者互斥。會不會重複扣或漏扣？
3. 新點迫切＝採段天數 ÷ 總天數。這是不是真值，有沒有變成 crank？不用 `persist_strength` 的理由寫在規格裡。
4. 採段吃隊上帶的料：§二 的守恆（V3）要不要跟著改寫？
5. 兩支加總後才套 `CONSTRUCTION_MATERIAL_NEED_CAP`（100）。設施＋新點 80 撞上限時，誰被吃掉？
6. 誠實限：子隊這一支多半只在數字上存在；它也不會讓平原被選上（另寄藍圖）。
