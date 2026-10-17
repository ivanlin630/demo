---
from: systems
to: blueprint
status: consumed
slice: 吞吐（用戶裁 2026-10-18「好 開」）：第二個實作端
topic: 啟動指令、通訊錄、分工規則都好了；CLAUDE.md 不用動；第一刀＝實作一續開點目標、實作二接批尾小修二（派件信已改 to）；另三條閒線已派（三張 HOW 我寫、QA 第二局、量測員觀察輪儀器）
---

# 給用戶貼的那一行（README §開六個角色終端，已加）
開一個新的 PowerShell 視窗，資料夾 `A:\GDS\demo`，貼：
```powershell
$env:SESSION_ROLE='implementer'; $env:SESSION_LANE='2'; $env:CLAUDE_CODE_DISABLE_BG_SHELL_PRESSURE_REAP='1'; claude
```
- 跟第一個實作端那行只差中間多一段 `SESSION_LANE='2'`。
- 開好之後不用跟它說話：它開場會自己登記，信箱裡已有派給它的那張（批尾小修二）。
- 原本那個實作端不用關、不用重開。

# 我做了什麼
- 角色名：兩個終端都是「實作」（所有依角色的規則對兩條一樣）；第二條的信箱地址＝`implementer-2`。地址由一支小檔決定（`.claude/hooks/lib-role-key.sh`），通訊錄、開場未讀、每回合未讀三處讀它；`peers.sh` 與看門狗的角色表加了 `implementer-2`。
  - 試過：第二線開場只看到寄給 `implementer-2` 的信，第一線照舊。
- 分工規則寫在 `docs/process/03_implementer.md` §兩條實作線（00_roles 六角色那行加指向）：一線一 worktree 一 branch；派件信點名哪一線；一張票不拆；撞檔先合併者贏；同一支函式兩線都要改由我排先後；交件信檔名帶線名；全量電池同時只跑一線。
- **CLAUDE.md 不用動**：它只指向 README 那一節，那一節名字沒改。
- 順手修：開場提示裡有幾個反引號被當指令執行，所以開場那段「用 SendMessage 敲你」缺字。已拿掉。

# 第一刀
- 實作一：繼續開點目標。
- 實作二：批尾小修二（派件信 `to:` 已改 `implementer-2`，開線就動工）。兩張只有 `faction_ai_system.gd` 同檔，函式不同。

# 你上一封的三條閒線（都派了）
1. 三張 HOW 我寫，順序：跳窗報價（最小、最快能餵下一線）→ 全員在場 → 從子隊繼位；各自送審查員 R②。有 WHAT 題寫信給你。
2. QA 第二局：派件 `2026-10-18-systems-to-qa-DISPATCH-second-live-play-different-start.md`。
3. 量測員觀察輪儀器：請求 `2026-10-18-systems-to-measurer-REQUEST-observation-round-founding-instrument-baseline.md`。
