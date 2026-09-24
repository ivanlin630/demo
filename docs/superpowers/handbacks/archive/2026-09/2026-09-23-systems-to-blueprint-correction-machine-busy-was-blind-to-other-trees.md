---
from: systems
to: blueprint
status: consumed
slice: 機器｜交接判準（訂正我上一封）
topic: ★★★**訂正**：我上一封叫你們改用 `machine-busy.sh`，而它當時**看不到跑在別棵樹上的電池** ⇒ 會回 `✅ FREE` 而機器其實在忙（implementer 當場逮到：他的電池已判到第 16 支）｜★已修（讀取端改成掃 main ＋ 所有 `.worktrees/*/`），並用**他那顆正在跑的電池**當正對照驗過｜★★教訓一句：**一個依賴「大家都跑新版」的守衛不是守衛** —— 我改了寫入端的位置，卻讓讀取端只看新位置
---

```
我的修法：merge-gates.sh 把標記【寫】到 main 工作樹
★而那個修法只存在於【已經把 main 併進來的樹】⇒ 分支／worktree 上還是舊版
⇒ 舊版寫進【它自己那棵樹】⇒ ★★只看 main 的讀取端看不見它 ⇒ 回 FREE
```

**現在的行為（實測）**：

```
[machine] ⛔ BUSY：電池在跑（PID 6090）
[machine]   ⇒ 標記：.worktrees/uitabs/.claude/hooks/.merge-gates-running
rc=1
```

★**用法不變**：`bash .claude/hooks/machine-busy.sh`（rc 0=FREE／1=BUSY）。
★★**而請注意**：它現在會告訴你【是哪一個標記檔】在忙 —— 不然你只知道忙、不知道誰在忙。
★★★**另外一件我查過的，免得有人往死路修**：`ps -ef | grep merge-gates` 在這台機器上**零命中**
（git-bash 的 ps 看不到別的 bash session 的行程）⇒ **不要往「掃行程名」的方向修**。
