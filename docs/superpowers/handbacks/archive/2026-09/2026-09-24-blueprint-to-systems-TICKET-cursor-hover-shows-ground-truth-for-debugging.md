---
from: blueprint
to: systems
status: consumed
slice: 玩家實跑回饋 #3（用戶 2026-09-24：「先顯示真值 我好debug」）
topic: ★小票：TextUI 游標移到哪就印哪一格的【真值】（不用按 Enter），內容擴到整格（地形/收成係數/全部資源/據點型別等級主人/格上所有隊與人口/（若有）控制方），區塊標題明寫「真值·debug（非附身者所知）」｜★★這是用戶為了 debug 明裁的 god-view 例外，登意圖帳；玩家版（讀 team_tile_known 的「已知資訊」）另存小票不作廢｜HOW：純 render 讀，禁寫 state（票4 那條）
---

# 一、用戶裁（逐字）

```
「如果加入顯示游標處已知資訊會很多工作嗎?」→ 我報小版（讀記憶）／中版（記憶多存欄位）→
「算了 先顯示真值 我好debug」
```

# 二、現況（file:line）

```
text_ui_main.gd:326-329  WASD 移 _cursor；:330-332 KEY_ENTER 才把 _selected=_cursor
text_ui_main.gd:939-962  「選中」區塊：sim_bridge.query_tile(_selected) 真值（地形/農/食）＋ occupants 從 snapshot visible_teams 對名
sim_bridge.gd:139-151    query_tile 直讀 state.world.tiles（god-view），回 terrain/harvest_factor/resources/outpost_*
⇒ 已經是真值，只是 ①要按 Enter ②欄位少 ③沒標明它是 god-view
```

# 三、要做的（WHAT）

```
①改成跟著 _cursor 即時顯示（不用 Enter；Enter 仍可保留給「選目標下令」）。
②欄位擴到整格真值：地形、收成係數、resources 全部鍵值、據點（型別/等級/主人隊名）、
  格上所有隊（真值，不只 visible_teams）＋人口＋所屬勢力、控制方（若有該欄）、tile id。
③區塊標題固定印「真值·debug（非附身者所知）」—— 讓玩家版上線前這個 god-view 不會被誤當成遊戲內容。
④純 render：禁寫 state（票4「render 不得寫 state」那格會守）；fp 不變。
⑤player_reachable=yes（就是玩家畫面）。
```

# 四、驗收句

```
游標移到一格未去過的格 ⇒ 區塊出現且含該格 resources 真值與「真值·debug」字樣；不按 Enter。
陽性對照：把 ③ 的標題拿掉這格必紅（標題是機械可查的字串）。
render 前後 world-fp 逐字相同（票4 那格）。
```

# 五、登帳

```
意圖帳 #42 玩家端可達性 補一句：游標真值面板＝用戶裁的 debug 例外（2026-09-24），非感知鐵律的鬆綁；
玩家版「游標處已知資訊」（讀 team_tile_known：未知／地形／記得的據點與主人／最後見到幾天前；食物印「不記得」）= 待開小票。
```
