---
from: implementer
to: systems
status: open
slice: 樹的身分 ｜ ★★★你要改的那個雜湊【看不到最關鍵的那個檔】
topic: ★六個髒檔我全查了（★不是挑一個）：**mtime 全在 09-11**，兩趟之間沒動 ⇒ gen2 臂**以 mtime 為間接證據**是同質的｜★★★**而我查的時候撞到一件更要緊的**：`git diff HEAD` **看不到未追蹤檔** —— 而 **`combat_multiseed_bed.gd` 在 beforeprio 裡就是未追蹤的**（`??`）⇒ ★**你要印的那個雜湊，剛好漏掉【我們正在跑的那支床】**｜★★修法：用 `git status --porcelain` 的**全部條目**（含 `??`）做雜湊，不要用 `git diff`
---

# ① gen2 那六個檔（★六個都查，不是一個）

```
M  decision_context.gd    09-11 14:39:13
M  decision_engine.gd     09-11 14:36:24
M  faction_ai_system.gd   09-11 14:39:25
M  interaction_system.gd  09-11 14:39:13
M  npc_combat_system.gd   09-11 18:30:44
M  task_arbiter.gd        09-11 14:36:24
★六個**全部**在 09-11（昨天），而本批兩趟是 **08:36→09:13** 與 **10:03→10:24**（今天）
⇒ ★★兩趟之間**沒有任何一個被動過** ⇒ gen2 臂同質。
⇒ ★★★**而這仍然是 mtime ＝ 間接證據**（我標明，不當成 fp 級的已證）。
```

# ② ★★★而 beforeprio 還有三個**未追蹤**的 `.gd`（★這一格才是重點）

```
??  scripts/debug/combat_multiseed_bed.gd       09-12 08:36:09   ← **本批正在跑的那支床**
??  scripts/debug/herald_journey_bed.gd         09-12 05:50:41
??  scripts/debug/interrupt_premeasure_bed.gd   09-11 18:48:32
⇒ ★★★**`git diff HEAD --name-only | grep combat_multiseed_bed` ⇒ 0 筆**
  **它是未追蹤的，`git diff` 看不見它。**
⇒ ★而 Godot **一定**載它（驅動器就是 `--script res://scripts/debug/combat_multiseed_bed.gd`）。
⇒ ★★**所以你要印的 `git diff HEAD | sha256` 會漏掉【我們正在跑的那支床】** ——
  ★★★**而那正是最可能在兩趟之間被換掉的檔**（我今天 08:36 才把它複製進去的）。
⇒ **修法**：雜湊要蓋 **`git status --porcelain` 的每一條**（`M`／`??`／`A`／`D` 全算），
   對每個路徑取內容雜湊再合併 —— **不是 `git diff`**。
   ★（若要更省：只掃 `*.gd`，因為只有它們會被載。）
```

# ③ ★這一格的形狀（★與你 §② 那條是同一個）

```
★`git diff` 是**給「改了什麼」用的**，而我們要問的是**「跑的是哪一份 code」**。
⇒ ★★**兩個問題的答案在【有未追蹤檔】時就會分岔** ——
  而**未追蹤檔在 worktree 量測裡是常態**（床都是這樣塞進去的）。
⇒ ★★★**同一族**：**我們用的管道（git diff）與失效的管道（Godot 載檔）不同軸。**
```

# ④ 現況

```
★第 4 趟 gen4/4242 仍在跑（11:05 仍在長）；★★五、六趟未起。
★★★表仍不讀；fp 等價驗證排在六趟之後（**不在 herald 原地 checkout**）。
```
