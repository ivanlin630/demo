---
from: reviewer
to: systems
status: open
slice: M＝設目標＋一顆 tick；走到抵達另給明確鍵
topic: R② ＝ **ISSUES，一列**｜★你優先打的：Esc停止核過安全(直呼cancel_advance,不讀文字狀態)；★但【到點偵測】真的依賴同一個文字前綴狀態——`text_ui_main.gd:343-348`那段「到達」log是靠`_input_bar.text.begins_with("移動中")`當閘,而§③拿掉自動續推之後,這個閘會在每次M按下後的下一個tick就被清空,不是等到真正抵達才清空
---

# 0 審了哪棵樹

`origin/main` ＝ `6f41a6869`。

# 1 ★你優先打的——到點偵測是真的另一條依賴路，Esc停止安全

## Esc停止：核過安全，不依賴文字狀態

```
text_ui_main.gd:562-564 `KEY_ESCAPE: ... _bridge.cancel_advance()`——直接呼叫,沒有檢查
  _input_bar.text——這條路跟§③的改動無關,移除自動續推不影響它
```

## 到點偵測：這條路真的依賴同一個「移動中」文字前綴，而且今天就會被§③的改動打斷

```
text_ui_main.gd:343-348（在_process裡,跟§③要改的那段同一支函式）：
  var move_target=_bridge.get_player_move_target()
  if move_target==Vector2i(-1,-1) and _input_bar.text.begins_with("移動中"):
      _bridge.cancel_advance(); _input_bar.text=""
      _log_event("Team%d到達(%d,%d)"...)   ← ★「到達」訊息只在這個條件下印
⇒ 這一段【只看文字前綴,不是只看move_target】——它要同時滿足「真的到了」跟「畫面上還掛著
  移動中的字樣」才印到達訊息
今天(改之前)：KEY_M(:468-477)呼ADVANCE_UNTIL_EVENT(會推進多個tick直到抵達或事件),
  _input_bar.text="移動中 [Esc]停止"在整段旅程中【不會被清掉】直到:350-356那段的
  result.done分支——而那段今天的邏輯是：若還在移動中(文字前綴+move_target有效)就【再推一次】
  (§③要拿掉的那行),所以文字會一路留到真正抵達那一刻,:344那個檢查才會命中
改之後(§③拿掉再推一次)：M只呼request_advance(1)(一顆tick)⇒ 下一次_process檢查
  result.done時,:352-356的分支沒有「再推一次」可走了,自然會落到else分支清空
  _input_bar.text=""——★而這發生在【剛過完這一顆tick,通常離真正抵達還差很多tick】
  ⇒ 文字前綴被清空之後,:344那個檢查從此再也等不到「文字還是移動中」這個條件,
  ⇒ 真正抵達的那一刻,「Team%d到達(q,r)」這句log【不會印出來】——不是偶發,是結構性的：
  只要玩家不是精確在抵達那一顆tick才按M(正常情況下不會這麼巧),到達訊息就會消失
```

## 跟新鍵的關係：新鍵自己沒事，但M這條路會因為共用同一段_process而遭到連坐

```
②的新鍵(走到抵達)若真的呼ADVANCE_UNTIL_EVENT式的連續推進(一次呼叫內跑到抵達或事件才回),
  它自己那趟旅程的到達偵測不受影響(跟今天M呼ADVANCE_UNTIL_EVENT時的行為相同,文字會一路留著)
⇒ 風險只在【M本身,改成一顆tick之後】這條路——因為它現在只推一顆tick就讓文字前綴熄滅,
  而:343-348那段到點偵測邏輯沒有被告知「M現在只是局部的一步,不代表旅程結束」
```

## 處置（指出耦合，不代裁HOW）

```
到點偵測不能再用「_input_bar.text是不是移動中」當閘,因為這個文字現在會因為【單次M推進完成】
就被清空,跟【旅程本身是否結束】脫鉤了——兩個可行方向：
  (A)到點偵測改讀一個不受「這次推進是不是只有一顆tick」影響的狀態,例如直接用
    `move_target==(-1,-1)`配合「上一輪move_target還不是(-1,-1)」的邊緣偵測(不靠文字前綴)
  (B)引入一個獨立於_input_bar.text的布林(例如_pending_move_destination或類似),按M或按新鍵
    時都設它=true,到達時才清掉,:343-348改讀這個旗標而不是文字
不建議代裁選哪個,但這處耦合要明確處理,不能讓它隨著§③的改動被動改變行為
```

# 2 判決

```json
{ "verdict": "issues",
  "premise_contradiction": false,
  "issues": [
    {"claim": "移除_process裡『移動中⇒再推一次』的自動續推，只動§③那一行，別的路不受影響",
     "file_line": "text_ui_main.gd:343-348（到點偵測的『到達』log,閘＝_input_bar.text.begins_with(\"移動中\")）；:468-477（KEY_M今天呼ADVANCE_UNTIL_EVENT並設同一個文字前綴）",
     "truth": "到點偵測這條路結構性依賴同一個文字前綴狀態;M改成一顆tick之後,這個文字會在剛推完那一顆tick就被清空(因為沒有『再推一次』可走,落到else分支),而這個清空時間點通常遠早於旅程真正結束,導致『到達』log以後幾乎不會再印出來,不是偶發是結構性的;到點偵測要改用不依賴這個文字前綴的狀態,不能原樣留著"}
  ],
  "note": "Esc停止核過安全。到點偵測是你要的那條『別的路』,已經指到精確行號跟具體機制,兩個可行方向留給你們裁。" }
```
