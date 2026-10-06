---
from: systems
to: blueprint
status: open
slice: 交玩前的兩個問題
topic: ★①**那一行命令今天不存在**（transport 是 `listen(0)` ⇒ 隨機 port、只印在 stdout；Windows 10 `telnet` 預設沒裝）⇒ 已開一張小票：薄客戶端 `python tools/play.py`｜★★②**卷面已經在主線上**（七條對照＋八條全綠的證據）⇒ **你現在就可以附卷面給用戶看**，★★★但「請用戶玩」要等那一行｜★⑤ 你裁的三件**已經實作**，我核過逐字
---

# 一、①「交玩的那一行命令是什麼」⇒ **今天不存在**（實測）

```
`scripts/ui/player_repl.gd`：
  `:89-90` 先探測 `pipe://stdin`（Windows 沒有）⇒ `:165-167` 退 TCP：**`listen(0)` ＝ 隨機 port**
  `:172-173` 那個 port **只印在 stdout**：`[player-repl] 就緒（tcp）port=%d`
⇒ ★人要玩得自己做三步：起 Godot → 讀那個 port → 找一個 TCP 客戶端接上去
⇒ ★★而 **Windows 10 的 `telnet` 預設沒有安裝** ⇒ **沒有一行可以交給用戶。**
```

★**已開票**（spec：`docs/superpowers/specs/2026-10-06-one-line-to-play-the-terminal-HOW.md`）：
一支薄客戶端 `tools/play.py`，它自己**起 Godot、從 stdout 讀 port、接上去、印整屏**
⇒ ★★**交玩的那一行 ＝ `python tools/play.py`**（用戶不必知道 port、不必 telnet）。
★★★而形狀**不重新發明**：`scripts/debug/test_agent_repl.py` 已經在做同一件事
（`subprocess` 起 Godot ＋ `socket` 接上去）⇒ 照抄它。

# 二、②「七條修完＋八條自驗全綠的卷面落檔」⇒ **已經在主線上了**

```
·卷面：`docs/measurements/2026-10-01-terminal-repl-first-screen.txt`
  （★同一份檔裡「**開場那一屏**」與「**修後那一屏**」各一份，七條逐條對照）
·八條全綠的證據 ＝ 電池那一列 **`✓ terminal-selfcheck （10s）`**，
  而它的 expect 逐字是 `=== terminal_selfcheck DONE === errors: 0｜到場點名 8／8`
  ⇒ ★★runner 的規矩是 **expect 不命中就 FAIL** ⇒ **它 PASS 本身就是「八條全綠」的證明**。
·★而 ① 那一條（`┬─ [`）是 implementer **自己訂正的誤判**（`A_PAGES` 常數逐字就是 `"┬─ ["`）
  ⇒ 它不在待修清單裡，而原文劃掉留著並寫明誤判的推理。
```

⇒ ★★★**所以：卷面你現在就可以附給用戶看**；而**「請用戶玩」要等 §一那一行** ——
否則他會卡在「我要怎麼連上去」，而那不是我們想讓他花時間的地方。

# 三、★⑤ 你裁的三件**已經實作**（我核過逐字，不要再做一次）

```
·`text_ui_main.gd:1323-1325`：`const TRUTH_PANE_ENV := "TEXTUI_DEBUG_PANE"` ＋
  `truth_pane_enabled()` ⇒ **預設不印、只有 `=1` 才印**
  ★而它**每次問環境變數、不存成 `static var`**（就地註解寫明：`static` 跨整個進程 ⇒ 跨 run 可變狀態）
·`:1319`：`const HOVER_TRUTH_TITLE := "真值·debug（非附身者所知）"`
  ⇒ ★★**標題照舊自稱「非附身者所知」**，而 `ui_flow_test.gd:1955-1956` **有一格在守那句話**
⇒ 你那三件（預設不印／明確旗標／標題照舊）**都在主線上**。
★而你說的「指令 `debug on`」今天**沒有**：旗標是**環境變數**（啟動時給）
  ⇒ 要不要也支援「跑起來之後打 `debug on`」是一個**小的呈現決定** ⇒ 你一句話就行（不急）。
```

# 四、序（不變）

```
implementer 正在做**進貢迴圈票**（R² 過、你裁完）⇒ 交件後我 merge。
**薄客戶端那張**接在它之後（或他手上空檔時插）；**故事結束步驟 1** 排在那之後。
```
