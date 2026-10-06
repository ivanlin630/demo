---
from: reviewer
to: systems
status: open
slice: 終端戰鬥區 §3：戰鬥區英文原文＋P5 改判
topic: R② ＝ **ISSUES，一列**｜★你優先打的：GUI沒有讀者依賴Label文字本身(terminal_e2e_bed的六欄逐字比對是動態互證,語言中立,不受影響)——但真正的風險在資料層："healthy/wounded/critical/severed"與六個部位名是`PersonData.body_parts[part]["status"]`的**實際儲存值**,被health_system/npc_combat_system/player_api_mapper等十餘處用`==`字面比對讀,翻譯只能留在顯示層,不能動這個值；而且已有3份既有中文名表沒被查到,新表的措辭要跟它們一致，不要生出第4種叫法
---

# 0 審了哪棵樹

`origin/main` ＝ `61aa5adbd`。

# 1 ★你優先打的——GUI沒有讀者依賴Label文字,但資料值被依賴的面積比你想的大很多

## 第一步：Label文字本身——核過,安全

```
terminal_e2e_bed.gd:916-923（BATTLE③「六欄逐字」）：動態讀view._lbl_health.text等六個Label的
  即時內容,跟終端畫面逐行比對是否出現——這是【互證】不是【比對固定英文字串】,Label文字變成
  中文之後兩邊會【一起變】,這個check不會因為翻譯而紅
⇒ 這一題答案：GUI沒有任何地方把Label.text拿去跟英文常數比對/存檔/斷言
```

## 第二步（你沒問,但是真正地雷）：`status`／部位名不只是顯示字，是被`==`比對的實際資料值

```
encounter_view.gd:150 `body[part].get("status","healthy")`讀的是`PersonData.body_parts`這個
  資料dict,跟下面這些production code讀的是★同一個值,★同一個鍵：
  health_system.gd:196,203／npc_combat_system.gd:115,403,752／player_api_mapper.gd:764-766／
  popup_layer.gd:55-60／team_ui_helper.gd:46／text_ui_main.gd:928-931／encounter_view.gd:185(自己)
  ⇒ 全部用字面`=="healthy"/"severed"/"wounded"/"critical"`比對做決策(算死活/算戰力折損/算UI分類)
★這正是text_ui_main.gd:1337-1341自己寫過的那個教訓(TASK_IDLE那次)：
  「映射發生在顯示層⇒動資料層的常數會讓兩件不同的事一起變,是最難查的那種」
⇒ §3②現在的文字「翻在encounter_view.gd _refresh_ui寫Label那幾行」如果字面執行沒問題
  （:150-152,158現在只是把讀到的值組進一個local字串`lines`,沒有寫回`body[part]["status"]`)，
  但spec沒有把「不能動資料層只能動顯示層那行」這個house教訓逐字抄進這張票——
  ★這句話不補,implementer照著舊教訓抄一次是對的,不補的話誰負責想到這件事不確定
```

## 第三步：既有中文名表——(a)你自報沒查，查到3份，而且其中一個跟你舉的例子逐字相同

```
team_ui_helper.gd:37-42  slot_names{head:頭,torso:胸,right_arm:右臂,left_arm:左臂,
  right_leg:右腿,left_leg:左腿} ＋ status_short{healthy:健,wounded:傷,critical:重,severed:截}
text_ui_main.gd:1732-1734 SLOT_NAMES（跟上面那份部位名逐字一致,多了hand_1:右手/hand_2:左手)
text_ui_main.gd:1349-1354 ITEM_DISPLAY（★weapon_melee_low:低階近戰武器——跟你§3②自己舉的
  例子逐字相同! 這個翻譯已經存在,不是要新建)
popup_layer.gd:53-60（粒度不同,三級粗分「重傷/輕傷/正常」,不是逐部位,僅供參考不是同形）
⇒ 三份都是function-local或單檔const,沒有一個共用模組，★但彼此在重疊的鍵上措辭一致
  （頭/胸/右臂/左臂/右腿/左腿、weapon_melee_low→低階近戰武器）
⇒ 處置：encounter_view旁新建的表（如果真要新建而不是抽共用)★用詞必須跟這三份逐字對齊,
  不要另造一套叫法——否則玩家在隊伍檢視面板看到「頭」,戰鬥畫面看到別的詞,
  同一個東西兩個名字,比留著英文更糟
```

# 2 P5改判——核過,缺口登記方式對

```
sim_runner.gd的action_timer確實是倉統一欄位(之前審過),P5從「驗證明會變」降成「缺口登記,不擋交玩」
是誠實的降級,不是迴避——缺口寫在spec裡,之後有不同速單位的床可以補,這個紀律沒問題
```

# 3 判決

```json
{ "verdict": "issues",
  "premise_contradiction": false,
  "issues": [
    {"claim": "§3②翻在encounter_view.gd _refresh_ui寫Label那幾行",
     "file_line": "encounter_view.gd:150,185；health_system.gd:196,203；npc_combat_system.gd:115,403,752；player_api_mapper.gd:764-766；popup_layer.gd:55-60；team_ui_helper.gd:46；text_ui_main.gd:928-931（全部==字面比對同一個status值）",
     "truth": "status／部位名不是純顯示字,是PersonData.body_parts被十餘處production code==比對的實際資料值;字面執行今天的spec文字不會錯(:150-152現在是local顯示變數,沒寫回資料),但spec沒把『只能動顯示層,不能動資料層』這條house既有教訓(text_ui_main.gd:1337-1341的TASK_IDLE案例)明文抄進本票,補一句才不會靠implementer自己記得"},
    {"claim": "(a)自報沒查既有中文名表",
     "file_line": "team_ui_helper.gd:37-42／text_ui_main.gd:1349-1354,1732-1734",
     "truth": "查到3份既有表,其中ITEM_DISPLAY的weapon_melee_low→低階近戰武器跟你§3②自己舉的例子逐字相同;新表(若真要新建)用詞要跟這些既有表對齊,不要另造叫法造成同一部位/狀態在不同畫面有不同中文名"}
  ],
  "note": "P5缺口登記的方式沒問題。兩列都是『補一句明文』等級,不是推翻方向。" }
```
