---
from: reviewer
to: systems
status: open
slice: 用戶第二手四件（滿上限收留無聲／上限不可見／事件流時序／沒錢也提進貢）
topic: R② ＝ **ISSUES,一列**｜★你優先打的①：找到真因了——強制事件[A]那條路確實走`_accept_join_request`(player_command_system.gd:1462那支本身沒問題),但UI端的回饋機制繞過了「等結算真結果」那套既有機制,直接拿`command_player()`的【入列確認】當結果顯示——那個入列確認永遠是「已排入:...」,跟實際accept/reject的真結果完全無關,:1462那句因此【從來不會被讀到】,不是這次才壞,是結構性繞過
---

# 0 審了哪棵樹

`origin/main` ＝ `e81940f32`。

# 1 ★你優先打的——找到真因：UI端讀錯了層

## 強制事件[A]確實走_accept_join_request,這支函式本身沒問題

```
player_command_system.gd:1515 `respond_to_forced(state,response)`：
  "join_request": if response=="accept": result=_accept_join_request(state,fe.get("from_id",-1))
  ⇒ 跟一般玩家指令走的是【同一支】,:1462那句「隊伍已滿,無法收留」確實在這條路上,沒有分岔
```

## 真因：UI端的letter-key handler讀的是「入列確認」不是「結算結果」

```
text_ui_main.gd:2003-2018（字母鍵分流,處理forced_interaction回應）：
  var rr:Dictionary = _bridge.command_player("respond_to_forced",ra)
  _set_feedback(rr.get("ok",true), rr.get("message",""))
⇒ 關鍵在`command_player()`這支本身：sim_bridge.gd:352-356只呼`_enqueue_command()`,
  而_enqueue_command(:361-390)【只做入列,不執行】——它回的dict永遠是
  {"ok":true,"queued":true,"message":"已排入:respond_to_forced(...)"}這種形狀
  (:384,:389-390兩個return都是這個樣子),★不管佇列裡那道指令最後會不會成功★
⇒ respond_to_forced真正的結果(例如_accept_join_request回的{"ok":false,
  "msg":"隊伍已滿,無法收留"})要等【佇列被消費那一刻】(世界tick推進時)才算出來——
  而text_ui_main.gd:2013-2014這一行讀的`rr`是【入列那一刻】的confirmation,
  兩者是時間上完全不同的兩個dict,:1462那句話根本不在`rr`裡出現過
⇒ 這不是「這次才壞」,是這條UI路徑一直以來都在讀錯的那一層——其他指令(例如移動)
  已經有專門機制(D3那張票:「令結算後,結果行換成完成句/被拒句」,讀_feed_rows／
  _report_key_advance那條)去抓真正的結算結果,而這裡(字母鍵回應forced_interaction)
  是一條【沒有套用那個機制、直接shortcut讀入列確認】的獨立路徑
```

## 處置（指出根因與既有可重用機制，不代裁UI細節）

```
不建議在:2013-2014這裡另外發明一套「等結算」邏輯——D3那張票已經有「結算後結果行換成
真句子」的機制在別的指令上運作,這裡要做的是讓respond_to_forced的回應也走同一條路
(不管是讓它跟其他指令共用同一個「佇列消費後讀真結果」的讀點,還是在這個按鍵路徑裡等
下一次result.done後才_set_feedback),細節交你們裁,但方向確定：★不能繼續用
command_player()的return值當這個按鍵的最終回饋,那個值結構性地不可能是真結果
```

# 2 判決

```json
{ "verdict": "issues",
  "premise_contradiction": false,
  "issues": [
    {"claim": "先查強制事件[A]走的是不是_accept_join_request這支、:1462那句去哪了",
     "file_line": "text_ui_main.gd:2003-2018(字母鍵分流直接讀command_player回傳值)；sim_bridge.gd:352-390(_enqueue_command永遠只回入列確認,不執行指令)；player_command_system.gd:1515-1558(respond_to_forced/_accept_join_request路徑本身正確)",
     "truth": "引擎路沒有分岔,:1462那句真的會被算出來,但UI端的字母鍵回應handler讀的是command_player()的【入列確認dict】不是結算後的真結果,兩者結構上不可能相等；本票①要修的『回饋』,根因在這個讀點錯層,不是respond_to_forced或_accept_join_request本身"}
  ],
  "note": "引擎路徑健康,根因在UI讀點。②上限可見核過effective_pop_cap確實存在，這輪沒有其他疑慮。" }
```
