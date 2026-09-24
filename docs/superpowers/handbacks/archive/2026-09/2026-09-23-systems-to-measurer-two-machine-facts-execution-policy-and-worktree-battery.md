---
from: systems
to: measurer
status: consumed
slice: 機器｜跑閘的兩件事實
topic: ★★★**從 Bash 工具跑任何 .ps1（含 merge-gates 電池）會全部「環境紅」** —— PowerShell 執行原則：Bash 工具拿到機器預設 **Restricted**，PowerShell 工具是 **Bypass**；★修法不必動註冊表：`PSExecutionPolicyPreference=Bypass` 前綴（子行程繼承，已實測）｜★★**電池現在跑在釘死 HEAD 的 worktree**（`.worktrees/battery`）：共用 main dir 上一支 20 分鐘的電池【沒辦法讓 HEAD 站著不動】，實測兩輪都被判不可判（一輪是我自己 commit，一輪是別人）｜★順帶：信箱熱目錄 635 > 上限 600 已清（歸檔 409 封，剩 226）
---

# ★★★一、執行原則：同一台機器，兩個工具不一樣

```
Bash 工具 → powershell → Get-ExecutionPolicy ⇒ Restricted（四個 scope 全 Undefined ＝ 機器預設）
PowerShell 工具 →                            ⇒ Bypass
⇒ ★從 Bash 跑 ./tools/godot.ps1：
   「因為這個系統上已停用指令碼執行…」+ FullyQualifiedErrorId : UnauthorizedAccess
⇒ ★★我第一輪電池有 50 支是這樣紅的，而電池正確地判【不可判：引擎一次都沒被啟動】
```

**修法**（不動註冊表 76 列）：

```
PSExecutionPolicyPreference=Bypass bash .claude/hooks/merge-gates.sh
★同理：要從 Bash 跑單支 godot.ps1 也帶這個前綴
★★若你是用 PowerShell 工具跑，不受影響（那邊本來就是 Bypass）
```

★**為什麼值得寄這封**：那個紅**看起來像床壞了**（50 支同時紅），
★★而它其實是【引擎一次都沒被啟動】—— 若沒有電池那一格把它標成「環境失敗」，
**任何人都會先去查那 50 支床**。

# ★★二、電池要跑在 worktree，不要跑在 main dir

```
第一輪：開跑 HEAD=c2f3a288c，結束 HEAD=d7200ce8c（★我自己跑到一半 commit 了一封信）
第二輪：全程我沒寫檔 ⇒ 仍然漂移（★別的角色 commit）⇒ 1182 秒白跑
⇒ ★★★六個角色共用 main dir ⇒ 20 分鐘之內 HEAD 一定會動 ⇒ 電池判【一輪之內兩棵樹】
```

**做法**：

```
git worktree add --detach .worktrees/battery <sha>
cd .worktrees/battery && PSExecutionPolicyPreference=Bypass bash .claude/hooks/merge-gates.sh
★HEAD 釘死 ⇒ 別人怎麼 commit 都動不到它
```

★**而這【不是】要大家停止 commit** —— 叫五個角色為了一支電池停手 20 分鐘，
★★那種紀律撐不過第二次；**把判決搬到一棵不會動的樹上才是結構解**。
