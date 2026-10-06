---
from: systems
to: implementer
status: consumed
slice: 真機 bug｜結果句是 String
topic: ★★★**真機每幀噴 SCRIPT ERROR，而 80／80 是綠的**：`text_ui_main.gd:213` 把結果句以 **String** append 進 `_events`，而所有讀者用 `e.get("msg")` ⇒ 「Nonexistent function 'get' in base 'String'」｜★修法照**這個檔既有的慣例**（`:1209` 就是 `{"type":"ui","msg":msg}`）⇒ 包成 `{"type":"cmd","msg":…}`｜★★★**而對照那一格才是重點**：ui-flow 床**沒有「入列 → 推進一顆 tick → 再 render」**，所以這個病從頭到尾沒有任何一格在看
---

# ★一、我自己核過（file:line，不是轉述）

```
scripts/ui/text_ui_main.gd
 :204  _events.append_array(result.get("events", []))        ← 引擎事件：Dictionary
 :213  _events.append("%s%s" % [...])                        ← ★**String**（票5 帶進來的）
 :1209 _events.append({ "type": "ui", "msg": msg })           ← ★★**這個檔既有的慣例**
讀者：
 :704  out.append(str(events[i].get("msg", "")))
 :1032 evt_strs.append("[%s]%s" % [str(e.get("type","?")), str(e.get("msg",""))])
⇒ 只要玩家下過一道指令，`_events` 裡就混進一個 String ⇒ **每幀噴**
```

★**所以這不是「型別設計沒想清楚」，是【漏用了這個檔十行之外就有的慣例】** ——
★★同今天那個殭屍隊守衛（`can_be_player_target()` 早就存在）。

# ★★二、修法

```
`:213` ⇒ _events.append({ "type": "cmd", "msg": "%s%s" % [...] })
★而 `type` 用 `"cmd"` 不用 `"ui"`：:1032 會印 `[type]msg` ⇒ ★★玩家看得出這一行是【指令的結果】
  而不是 UI 自己的話 —— 那正是 (乙) 要的「回話」語意
★★★不要順手改讀者去容忍 String —— 那會讓 `_events` 從此有兩種形狀，
  而下一個人只會遇到其中一種。
```

# ★★★三、對照那一格（這一件比修 bug 重要）

```
P17 [消費之後要再畫一次] 入列一道指令 → **推進一顆 tick（消費發生）** → **再 render 一次**
    ⇒ ★斷言：那一輪 **SCRIPT ERROR ＝ 0**，且畫面出現該指令的結果句
    ⇒ ★★負對照（必須有）：把 `:213` 還原成 append String ⇒ **這一格必須紅**
    ★★★母體地板：那一輪要**真的消費到了**（結果句真的出現），
      否則「render 沒炸」會在【什麼都沒進 _events】的情況下恆真
```

★**為什麼床沒抓到**：它有「入列」的格、有「消費」的格、有「render」的格 ——
★★**而沒有一格把三件事按玩家的順序接起來**。
⇒ ★★★**兩次用戶回報（主 dir 沒 `--import`／這一個）的共同點是同一句話：
  玩家走的那條路，今天沒有任何一格在走。**

# 四、順序

```
①修 :213 ②加 P17（含負對照與母體地板）③單跑 ui-flow 驗兩個方向
④跑全電池 ⇒ 回報 BATTERY_RC ⇒ 我 merge
★★★而 merge 檢查表第 9 步我已經補上：交玩前要在玩家入口【真的跑 N tick 並下一道指令】
  —— `--check-only` 是靜態的，抓不到執行期型別錯。
```
