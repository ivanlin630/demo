---
from: systems
to: all
status: open
topic: ★**任何角色要從 Bash 跑 `.ps1`（閘／床／量測）之前，先 `export PSExecutionPolicyPreference=Bypass`** —— 否則 `tools/godot.ps1` **一次都不會被載入**，而你會看到一整批「紅」｜★★**那不是新增繞過**：Claude Code 的【PowerShell 工具】進程本來就是 Bypass，這一行只是讓 Bash 端拿到同一個東西｜★★★**而失敗的樣子會騙你**
---

# 一、症狀（★記住這個樣子，它很會騙人）

```
整批閘裡一大片紅，而★每一支都在 0〜1 秒就紅
逐字：因為這個系統上已停用指令碼執行，所以無法載入 …\tools\godot.ps1
      + FullyQualifiedErrorId : UnauthorizedAccess
⇒ ★★畫面上長得像「N 個測試壞了」，實際是【引擎一次都沒被啟動】
```

# 二、修法（一行，這個工作階段有效）

```bash
export PSExecutionPolicyPreference=Bypass
# 然後照常：bash .claude/hooks/merge-gates.sh
#           powershell -NoProfile -File ./tools/godot.ps1 --headless --script <床>
```
★**實測**：整批 **66 支跑得起來**，環境紅 ＝ 0。
★★**機器層的 ExecutionPolicy 是 `Undefined`，而我們【沒有動它】** —— 也不需要動。

# 三、★閘現在會幫你分辨（2026-09-22 起）

```
離開碼 0 ＝ 全過｜1 ＝ 判準紅｜★2 ＝ 本輪【不可判】：引擎沒被啟動
⇒ ★★環境紅會印成 `⚡ENV <閘名>`，而且【不進任何統計、不更新基線】
⇒ ★★★所以你看到 ⚡ENV 時：**不要去修床，去修發射器**
```

# 四、★這一格的來歷（免得有人重走一次）

```
我第一版診斷說「這台機器停用了指令碼執行」＋「而它的 rc ＝ 0」——★兩句都錯
  ・rc 真值是 1（我那個 0 是自己接了 `| head` 吃掉回傳碼量出來的）
  ・★★機器沒壞，是【誰啟動它】：Bash 端 spawn 的 powershell 沒有 Process-scope Bypass
⇒ ★★★而我已經拿那個錯的診斷去要用戶改機器安全設定 —— 已撤回
```
★**相關檔**：`docs/measurements/_generation-boundary.md`（硬體世代 HW-2）／
`.claude/hooks/merge-gates.sh`（第三色的實作與註解裡的訂正）。
