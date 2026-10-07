---
from: systems
to: blueprint
status: consumed
slice: GUI 前端回歸 —— HOW 盤點（你出版面稿之前要知道的骨架）
topic: ★文字模型的三個資料口今天已經是資料（不是字串）：快照 `get_player_snapshot`、動作清單 `get_available_actions`（每項 action_id／label／enabled／disabled_reason／command）、事件 `read_player_events`，都經 SimBridge ⇒ GUI 掛同三支即可｜★要拆的一處：終端的 compose 吃的是「已排好的字串區塊」，GUI 不能吃那個，要吃區塊之前的資料｜版面稿出來我寫 spec
---

# 一、文字模型的資料口（樹 c2fc130c4）

```
快照：SimBridge.get_player_snapshot（sim_bridge.gd:312 → player_query_api）—— 頂列、生存頁、威脅欄都從它
動作清單＋原因：SimBridge.get_available_actions（sim_bridge.gd:324 → player_query_api.gd:217）
  ⇒ 吃一個焦點（team_id／member_id／tile_q,r／強制事件 id），回每個動作 {action_id, label, enabled, disabled_reason, target_requirements, command_name, command_args}
  ⇒ ★這就是你要的「點地圖格／隊伍 ⇒ 動作清單跟著變」：焦點＝被點的東西，清單直接來自這支
事件流：SimBridge.read_player_events（sim_bridge.gd:426），每筆帶 tick 與句子
下令：SimBridge.command_player(command_name, args)（同終端；結算後結果句走四缺陷 D3 那個讀點）
```

# 二、終端怎麼用它們、GUI 要怎麼不一樣

```
終端：text_ui_main 把三個資料口組成「區塊字串」，再交 TextUiView.compose（text_ui_view.gd:343）拼成一屏
  ⇒ action_block（:180）吃的已經是排好的行；★GUI 若吃這些字串就會回到「解析畫面文字」——不行
⇒ 要拆的一處：text_ui_main 裡「資料 → 區塊資料（list/dict）」與「區塊資料 → 字串」分開；終端走第二步排成字，GUI 走自己的排版
  ⇒ 兩邊共用第一步（同一份區塊資料），床的「GUI 按鈕集合＝文字模型動作清單」就比這一份
戰鬥區：encounter_view 已有六欄資料＋render_battle_map（:320）—— 同理拆成資料與排版
```

# 三、要你在版面稿裡定的（WHAT）

```
·地圖：可點的單位是「格」還是「格＋格上隊伍」（點隊伍 ⇒ 焦點 team_id；點空格 ⇒ 焦點 tile）
·動作按鈕區：全列（能做＋灰掉帶原因）的排序與分組（自家隊動作／對目標的動作／強制事件回應各一區？）
·強制事件：彈窗還是固定區（按鍵三態要求它一定看得到）
·推進：X／Space／走到抵達做成按鈕的位置
·舊 GUI 場景（scenes/Main.tscn 那棵）：是死樹 —— 新做還是在 TextUI.tscn 上加控件層，我傾向後者（同一個節點、同一份資料）
```

# 四、藍圖已答（035f68b09，GUI 做的時候照用、不再問）

```
①點隊伍優先、格次之（點格＝選格，格上有隊＝選那支；多隊列出來點）
②按鈕四組固定順序：時間（到整點／到隔日／走到抵達）／移動／對選中目標／自家隊；組內能做在前、不可在後帶原因
③強制事件＝固定區（右欄頂端醒目框，含到期時間與 A／B），不彈窗
④推進三顆固定右下（到整點／到隔日／走到抵達）
⑤在 TextUI.tscn 上加控件層
```
