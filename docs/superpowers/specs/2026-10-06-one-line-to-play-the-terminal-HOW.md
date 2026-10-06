# HOW：**交玩的那一行命令** —— 薄客戶端（今天沒有那一行）

- **來源**：blueprint 問「①人怎麼輸入？交玩的那一行命令是什麼」（2026-10-06）
- **HOW owner**：systems｜**它是「請用戶玩」的阻塞點**，而且只有它是
- **基準樹**：`e38ee4f7b`

---

## §1 ★今天沒有那一行（實測，不是推想）

```
`scripts/ui/player_repl.gd`：
  `:89-90` 先探測 `FileAccess.open("pipe://stdin")`（Windows 沒有它）
  `:165-167` 退 TCP：`_tcp_server.listen(0)` ⇒ ★**隨機 port**
  `:172-173` 只把它**印在 stdout**：`[player-repl] 就緒（tcp）port=%d`
⇒ ★★所以人要玩，得自己：①啟動 Godot ②從 stdout 讀那個 port ③找一個 TCP 客戶端接上去
  ⇒ ★★★而 Windows 10 的 `telnet` **預設沒有安裝** ⇒ **那一行命令今天不存在**。
```

## §2 做什麼（一支薄客戶端，★形狀抄既有先例）

```
·新增 `tools/play.py`（★先例：`scripts/debug/test_agent_repl.py` 已經在做同一件事：
  `subprocess` 起 Godot ＋ `socket` 接上去 ⇒ **不要重新發明，照抄那個形狀**）
·它要做四件：
  ①啟動 headless Godot 跑 `scripts/ui/player_repl.gd`
  ②★**從它的 stdout 讀那一行 `port=`**（而不是要用戶看）
  ③接上去，把使用者打的每一行丟進去、把回來的整屏印出來
  ④`q`（或 `QUIT_TOKEN`）離開時把子行程收掉
·★★**交玩的那一行 ＝ `python tools/play.py`** —— 使用者不需要知道 port、不需要 telnet。
·★★★而 debug 走法照 blueprint 的裁定：**預設不印**，要看就
  `TEXTUI_DEBUG_PANE=1 python tools/play.py`（★那個旗標已經是環境變數，見 §3）。
```

## §3 ★而 blueprint 的 ⑤ 裁定【已經實作】——我核過逐字，不要再做一次

```
`text_ui_main.gd:1323-1325`：
  `const TRUTH_PANE_ENV: String = "TEXTUI_DEBUG_PANE"`
  `static func truth_pane_enabled() -> bool: return OS.get_environment(TRUTH_PANE_ENV) == "1"`
  ★**每次問環境變數、不存成 `static var`**（就地註解寫明理由：`static` 跨整個進程 ⇒ 跨 run 可變狀態）
`:1319`：`const HOVER_TRUTH_TITLE := "真值·debug（非附身者所知）"`
  ⇒ ★★**標題照舊自稱「非附身者所知」**（而 `ui_flow_test.gd:1955-1956` 有一格在守那句話）
⇒ ★★★所以他裁的三件（預設不印／明確旗標／標題照舊）**都已經在主線上**。
```

## §4 地板（P）

```
P1 [一行可玩] `python tools/play.py` ⇒ 印出完整第一屏，且**使用者沒有被要求輸入 port**
P2 [★收得掉] 離開之後**沒有殘留的 Godot 行程**（★而這一條是電池開跑前那個「Godot 數必須 0」的前提）
P3 [debug 預設關] `python tools/play.py` 的輸出**不含** `DEBUG_TOKENS` 任何一個
   ⇒ ★**反向走法**：`TEXTUI_DEBUG_PANE=1` 之下**必須出現**（否則那個走法是死的）
P4 [不新發明] `tools/play.py` 的 transport 形狀與 `scripts/debug/test_agent_repl.py` 同源
   ⇒ ★指名：若兩支各自寫一份 socket 迴圈 ⇒ 那是第二份真相 ⇒ 抽共用或明寫為什麼不共用
```

## §5 不在本票

```
✘ 逐鍵（raw mode）輸入 —— 仍在待辦（本票是逐行）
✘ 任何資料層／畫面內容改動（本票只做「人怎麼接上去」）
✘ 把 `agent_repl.gd` 與 `player_repl.gd` 合併（兩者讀者不同：agent 讀 JSON、人讀整屏）
