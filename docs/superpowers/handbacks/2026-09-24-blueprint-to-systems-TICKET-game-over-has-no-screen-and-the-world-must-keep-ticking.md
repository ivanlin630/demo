---
from: blueprint
to: systems
status: open
slice: 玩家實跑回饋 #2（用戶 2026-09-24：「玩家死後不會結束是因為還沒做嗎?」）
topic: ★是還沒做：sim 會設 game_over 並停止 tick（sim_runner.gd:114-116），而玩家路徑 TextUI 對 game_over【零處理】（grep text_ui_main.gd/ui_pages.gd 無命中；只有死樹 main.gd:70/168 有 popup）⇒ 玩家看到世界靜止、沒有任何字｜★★而且「停止 tick」本身違反意圖帳 #43（game_over=UI 層故事結束、可續觀沙盒、非世界物理）與 #44（世界存在不綁玩家）｜裁：一張票兩件：①TextUI 加「故事結束」畫面三選一（續觀／附身另一隊／離開）②game_over 不停世界
---

# 一、現況（file:line）

```
event_system.gd:80-82      無繼承人 ⇒ state.game_over=true（player_id≠-1 時）
player_command_system.gd:929 隊已滅 ⇒ 同上
sim_runner.gd:114-116      game_over ⇒ 只消費指令、return "game_over"、【不 tick】⇒ 世界永久靜止
text_ui_main.gd            對 "game_over"／state.game_over 零處理（:247 只有 choose_heir 註解；U19 自動進互動模式只管 forced_interaction）
main.gd:70/168 + popup_layer.gd:213  舊死樹才有 show_forced_event（玩家不走這棵）
⇒ 有繼承人：choose_heir 會自動開互動選單（U19），這條活著。
⇒ 無繼承人：flag 設了、世界停了、畫面什麼都不說 ⇒ 用戶看到的就是「死了但不會結束」。
```

# 二、裁（WHAT）

```
①「故事結束」畫面（TextUI）：印 game_over_reason 人話＋這場附身的一行摘要（活了幾天／隊最後狀態），三選一：
   (a) 續觀：拔掉插頭（player_id=-1），世界照跑，畫面切旁觀（五分頁照看，指令全部拒絕「無附身」＝不讀世界的當場拒絕）。
   (b) 附身另一隊：列出可附身的隊（同 #43 進場規則，挑一隊插上），插上後 game_over 清掉、故事重開。
   (c) 離開：quit。
②game_over 不停世界：sim_runner 那個 early return 拿掉，世界照 tick；game_over 只擋【指令】不擋【時間】。
   ★這條是 de-patch，不是新功能：#43「非世界物理」#44「世界存在不綁玩家」早就裁了，code 沒服從表。
③無玩家世界永不凍結那條（event_system.gd:74-77 註解）保持；本票只動 player_id≠-1 的分支。
```

# 三、驗收句（床用，母體要真有死）

```
一場附身的隊全滅 ⇒ 畫面出現「故事結束」＋三選項；選 (a) 後推進 N tick，world-fp 必變（世界在動）；選 (b) 後五分頁顯示新隊、指令可入列。
陽性對照：把 ② 的 early return 放回去，(a) 那格必紅（fp 不變）。
```

# 四、序

```
排在回饋 #1（:213 String 進 _events）之後；同屬「真機第一批」，兩張一起走 R²。
```
