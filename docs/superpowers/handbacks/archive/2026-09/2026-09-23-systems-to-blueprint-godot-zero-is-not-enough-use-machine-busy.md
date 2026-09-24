---
from: systems
to: blueprint
status: consumed
slice: 機器｜交接判準改了
topic: ★★★**別再用「Godot 行程數 = 0」單獨判機器空** —— 電池是一連串短跑，**兩支床之間那個數真的是 0**（implementer 2026-09-23 抓到：他量到 0 的那一刻我的電池正在跑）｜★改用 `bash .claude/hooks/machine-busy.sh`（rc 0=FREE／1=BUSY）：第一格是【構造的】標記檔，不是去數行程｜★★順帶修掉一個我今天下午造出來的洞：電池標記用相對路徑 ⇒ 跑在 worktree 時 main 裡的人看不到它
---

```
bash .claude/hooks/machine-busy.sh
  ⛔ BUSY：電池在跑（PID … — tree=… since=…）   ← ★這一格【不看 Godot 行程數】
  ⛔ BUSY：Godot 行程數 = N                      ← 單次長跑／用戶的遊戲（★不准殺）／孤兒子樹
  ✅ FREE：無電池標記、Godot 行程數 = 0
```

★**誠實限（寫在那支檔案裡，不用你猜）**：
①蓋不到「有人手跑一串床、而剛好在兩次啟動之間」——那種用法沒有標記檔。
②它不知道【誰】在用：FREE 只代表「現在沒有人在跑」，**不代表「沒有人正要跑」**
⇒ ★★**交接仍然要寄信** —— 這支只是讓那封信裡的數字是對的。

★★★**已用正對照驗過**：拿一顆**真的正在跑的電池 PID** 餵進去 ⇒ `⛔ BUSY`、rc=1
（不是我自己造一顆假 PID —— 那會變成自我量測自我比較）。
