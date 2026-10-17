---
from: blueprint
to: systems
status: consumed
slice: 吞吐（用戶裁 2026-10-18「好 開」）：再開實作端終端
topic: 用戶同意開第二個實作端；藍圖建議先兩條（不是多條），你出啟動指令、通訊錄登記、分工規則；用戶自己開終端
---

# 用戶裁
用戶問「開 或是開多實作」。藍圖建議：**先兩條**。理由：
- 排隊的票（開點目標／小修二／全員在場／跳窗報價／子隊繼位）大多碰同幾支檔（text_ui_main、interaction_system、encounter），三條以上衝突成本吃掉平行收益。
- 每條實作線上游要一張審過的 HOW、下游要審查員與量測員的時間；三張 HOW 提前寫（我上一封信）剛好餵兩條。
- 第三條的條件：審過待派的 HOW 穩定 ≥3 張、且兩條線連續兩張票沒互撞。到時再問用戶。

# 請你定（流程是你 owner）
1. **角色名與通訊錄**：第二個實作端怎麼登記（`implementer2`？`peers.sh`／`whoami.sh`／`role-watch` 都認得），00_roles §六角色與 README §開六個角色終端補一行。CLAUDE.md 若要動一字，拿去系統終端給用戶點頭。
2. **啟動指令**：逐字一行，照 README 現有格式（含 `CLAUDE_CODE_DISABLE_BG_SHELL_PRESSURE_REAP=1`），寫在 README 給用戶貼。
3. **分工規則**（寫進 03_implementer.md 或 00_roles）：
   - 一線一 worktree 一 branch；派件信 `to:` 點名哪一線；一張票不拆兩線。
   - 共檔衝突歸先合併者贏，後者 rebase；同一支函式兩線都要改 ⇒ 你排序，不平行。
   - handback 命名帶線名，避免兩線同名檔互蓋。
4. **第一刀分工**：實作一 繼續開點目標（已在 feat/founding-goal）；實作二 立刻接批尾小修二（派件信 2026-10-17-systems-to-implementer-DISPATCH-tail-fixes-2 已 open，改 `to:` 即可）。小修二與開點目標檔面幾乎不重疊。

# 給用戶的話（我會轉）
你把啟動指令寫好敲我，我把「開哪個資料夾、貼哪一行」用白話轉給用戶。
