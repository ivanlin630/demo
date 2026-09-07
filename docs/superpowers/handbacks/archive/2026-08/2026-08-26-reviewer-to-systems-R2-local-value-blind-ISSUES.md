---
from: reviewer
to: systems
status: consumed
slice: local-value-blind-callsites
topic: R² 判決:ISSUES(premise_contradiction)——:952 不是純 NPC 路徑,player_command_system 也走得到
---

# 判決：`issues`，`premise_contradiction: true`

咬完你點名的三處，逐一回：

## ① 「15」這個數字
以「相異行」算對：player 9 行（`player_trade_system:46,85,88,137,139` + `player_api_mapper:864,866,876,879`）+ NPC 6 行（`faction_ai_system:3482` + `interaction_system:952,996,1002,1004,1005`）＝ 15 行。
★但實際 `local_value(` **呼叫次數是 17**——`interaction_system.gd:996`、`:1002` 各一行藏兩次呼叫（`if local_value(b,res) <= local_value(a,res)` 這種左右各一次）。
⇒ **窮盡 grep 若逐次 match（非逐行）會抓到 17，implementer/量測員照 spec 的「15」核對時別誤判「少 2 個沒抓到」——這不是漏抓，是行/次沒分清。**

## ② NPC/player 分類：表頭數字本身算錯（但總數矇對）
spec §2 表頭寫「NPC 路徑（5）／player 路徑（10）」，但表格自己列出的項目數是 **NPC=6 行**（`faction_ai:3482` + interaction 5 行）、**player=9 行**（5+4）。
5+10=15 跟 6+9=15 剛好同總數 ⇒ 表頭錯被總數矇混過去。★跟你信裡自己認的「`record_driver` 我報 37、實際 29」同一種病，這次在另一個表又犯一次——建議兩個表頭數字都改成清單自動算，別手寫。

## ③★★premise_contradiction：`interaction_system.gd:952` 不是純 NPC 路徑
你自己點名要查「interaction_system 那 5 個真的是 NPC 路徑？裡面有玩家會走到的分支嗎？」——**有**：

`:952` 在 `_attempt_trade_direction(state, seller, buyer)` 內。這支函式的呼叫端不只 `_resolve_market`（`:693-695`，純 tick-driven）：
- `interaction_system.gd:1073 resolve_trade_direct(...)` 也呼叫它（`:1081-1082`），此函式自己的註解寫死：「供 `PlayerCommandSystem` 呼叫：不需要 seller 有 `TASK_TRADE`」。
- `player_command_system.gd:414 _action_confirm_trade(...)` 真的呼叫 `resolve_trade_direct`——**活的玩家指令 handler**（legacy trade confirm 分支），非死碼。

⇒ `:952` 這行 blind call **同時吃 tick 路徑和玩家直接下單路徑**。spec §2 把它單邊歸「NPC（fp 會變）」沒錯（tick 那條線本來就該變），但表格隱含「player 那 10 個之外沒別的玩家可達 call」——**這個假設在 code 層面是假的**。

（★對照組：`_attempt_barter`（`996/1002/1004/1005`）的呼叫端只有 `interaction_system.gd:695`、`:806` 兩處，都在自己 tick 函式內，grep 不到 `player_command_system` 或任何 player 入口呼叫它——**這 4 行乾淨，問題只在 `:952` 一行**。）

**⇒ 影響**：a4「無玩家」情境下 `resolve_trade_direct` 不會被觸發，短期 fp 測不會因此穿幫；但驗收⑤「player 那 10 個不要求 fp 變」的防呆邏輯漏了 `:952`——它不在「player 10」名單裡，卻一樣玩家可達。等 player-trade regression 接進來，這行 patch 後**玩家直接下單的估值也會跟著變**，不能只拿「player 那 10 個沒變」當防呆全貌。

## ③b「純接線」宣稱——查證成立
15 個逐一查 enclosing 函式：`_attempt_trade_direction`／`_find_trade_target`／`get_tradeable_resources`／`evaluate_offer`／`preview_offer`／`map_trade_session` **全部本來就有 `state` 參數在 scope**。跟 `_sellable_qty` 那次「包裝層根本沒 `state` 可傳」不同型——**這次不用往上開口，「呼叫端把手上已有的 state 傳下去」屬實。**

## ⇒ 要你改的地方
spec §2/§4 補一句：`:952` 是 tick 路徑與玩家直接下單路徑的共用碼，不是「NPC 專屬」；驗收⑤的「player 那 10 個不要求 fp 變」需明確排除 `:952`（它屬於「歸類 NPC 但玩家可達」的第三類，不是二分）。①②兩個計數/表頭錯改掉即可，不影響設計方向。

**premise_contradiction: true** → halt，改完這幾點再送。
