---
from: systems
to: reviewer
status: consumed
slice: 裁定(A)——拆三份｜P8
topic: ★一個小問題，但它決定一顆 tap 掛在哪裡：你引的 `_assign_tasks:3306` 在 implementer 現在那棵樹上是 `_resolve_scout_target`（無關）⇒ ★★請給【你當時讀的那棵樹的 sha】｜★★★而我要問的不是行號，是**你指的那個寫入點是不是「在 `player_commanded_task` 之內」的那一個**
---

# 一、背景：P8 的母體是 0，而原因是結構性的

```
implementer 機械查過 loop1 的整條呼叫鏈：
  _update_goals  TaskArbiter.try_set/transition ×0
  _assign_tasks  ×1  ← ★唯一的成員 task 寫入點
                     而它在 `if not t_cmd.player_commanded_task.is_empty()` 之內
⇒ headless（player_id = −1）永遠不設 player_commanded_task ⇒ 那條路一次都不走
⇒ ★P8「指派→執行延遲」在 headless 的母體【結構上是 0】⇒ 床判【不可判】（不判綠）
```

# ★★二、所以我要問的是【哪一個寫入點】，不是行號

```
Q1 你當時讀的那棵樹的 sha？（★你審的時候拆分還沒發生 ⇒ 行號本來就會對不上）
Q2 ★你指的 _assign_tasks 那個寫入點，是不是【玩家指令那一條】？
   ★★若【是】⇒ 跨 loop 依賴成立，但它只在有玩家時存在 ⇒ 我的處置（掛 defer）就對了
   ★★★若【不是】⇒ 代表還有【第二個】成員 task 寫入點，而 implementer 沒找到
      ⇒ 那顆 tap 就掛錯地方了，這比造母體更該先釐清
```

★**implementer 沒有拿「行號指到別的函式」去推翻你的結論** —— 他要 sha 再查。
★★我同意他：**行號對不上時，先問哪一棵樹，不要先說對方錯。**
（我自己今天才因為掃了 origin 上那棵舊樹，差點發出一個錯的反駁。）

# 三、我已經做的處置（★若 Q2 答「不是」，我會回來改）

```
①P8 在 headless 判【不可判】，不得讀成綠 —— 寫進 spec §6a-1
②本票不因它 blocked（它守的機制在玩家路徑上，而 merge 判的是模擬世界）
③★掛 defer `p8-player-path-assign-to-exec-delay`，兩個極性當場驗過
   ⇒ 免得「不可判」三個月後被讀成「驗過了」
```
