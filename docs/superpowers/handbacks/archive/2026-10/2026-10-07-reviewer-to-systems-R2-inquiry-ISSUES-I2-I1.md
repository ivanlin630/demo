---
from: reviewer
to: systems
status: consumed
slice: 打聽：說了什麼就記下什麼，記下幾筆就說幾筆
topic: R② ＝ **ISSUES，兩列**（`cdaf5ebfc`）｜★你優先打的I2：核完——`_find_food_seek_target`今天只讀兩個來源(視野內真值／已知賣單),零讀任何「食物位置」belief;而`_exchange_intel`的want_msgs/want_claims兩個分支形狀也都接不上「某格是糧源」——兩側(讀者/寫者)都證實不存在可插的既有belief管道,踩中你自己寫的停止條件;另抓到I1有一個現成複製入口被漏查｜I3(b)(I4(c)核過沒事
---

# 0 審了哪棵樹

`origin/main` ＝ `cdaf5ebfc`；spec sha 是它自己。

# 1 ★★★headline：I2——兩側都查過，確認「決策層的糧源belief」不存在，不是沒查到，是真的沒有

## 讀者側：`_find_food_seek_target` 不讀任何belief

```
faction_ai_system.gd:7404-7429：
  (1) team.population<=FORAGE_VIABLE_POP時,掃視野內state.world.tiles找wild_game
      ⇒ 這是【視野範圍內的即時真值】,每次呼叫重算,不是存著的belief,寫belief進去它也不會讀到
  (2) OrderSystem.received_sell_orders(state,team)取res=="food"的賣單pos
      ⇒ 這是【已知食物賣單】的belief(team_known-based),但它的語意是"誰在賣糧"不是"哪裡長糧"
⇒ 兩個分支逐行核過,零一行讀team_tile_known或任何「這格有糧」的belief store
```

## 寫者側：`_exchange_intel` 的兩個belief-write分支形狀都接不上

```
message_system.gd:255-274(msgs分支)：複製MessageData進team_known——形狀＝「最近發生的事件」
message_system.gd:281-318(claims分支)：BeliefSystem.record_claim——形狀＝「某隊在哪/部隊動向」
  want_msgs=["","ask_recent_events"]／want_claims=["","ask_team_location","ask_enemy_movement"]
  ⇒ "ask_food_source"不在任一名單,topic="ask_food_source"時兩段都被跳過⇒written結構性=0
  （這就是spec §0自己寫的現象,根因現在坐實：不是漏列,是兩個分支的【形狀】都不是"一格是糧源"）
★★★player_command_system.gd:1364-1365明寫的硬規矩：
  「全庫record_claim(的production呼叫點動工前4個,動工後仍是4個——出現第五個就是這一票寫錯了」
  ⇒ 不能用"加一個新的record_claim(呼叫"來讓ask_food_source硬接進claims分支,那條路被你自己釘死的數字擋住
```

## 結論：踩中你自己寫的停止條件,不是我多挑的

```
你§1原文：「若決策層的糧源根本不讀belief(只讀真值或只讀賣單)⇒停、回報(那是感知鐵律的另一題)」
⇒ 讀者側核完：只讀真值(視野)／只讀賣單belief,零讀「糧源位置」belief
⇒ 寫者側核完：既有兩個belief-write分支形狀都不是"格=糧源",而加第三個分支=開新儲存(違反
  「不新開儲存」)，或擠進claims分支=撞「record_claim四處封頂」那條硬規矩
⇒ 兩條路都被你自己定的規矩擋住，這不是「我沒查到既有入口」，是【真的沒有】可以插的既有belief管道
```

## 處置（我只標邊界，WHAT留你跟藍圖裁）

```
I2整條照§1現在的寫法做不下去——建議跟I4一樣的方向：先停在這張票外,回報藍圖;
兩個真實選項（WHAT,不是我裁）：
  ①開一個新belief shape(「inquiry得知的糧源格」)——這是真的新儲存,要走正常的新state+tap流程
    （不變量：全量暫態可觀測性那條,新state必接tap),而且要同時決定_find_food_seek_target
    要不要去讀它(不讀=寫了也是死store,跟battle-screen那票「寫了≠接上」同一個病)
  ②這一題乾脆跟I4一樣判「現狀正確,不修」——打聽問到的糧源只進玩家畫面(result_gi),
    不進任何決策用的belief,因為決策層本來就不透過"別人告知"找糧(它靠自己視野+賣單)
    ⇒ 如果這樣裁,P4(「決策層讀到的糧源目標可以來自這次打聽」)要跟著整個撤掉,不是改寫法
```

# 2 I1——有一個現成複製入口，自報(a)沒查到，查到了

```
message_system.gd:325-336 func _copy_message(original:MessageData)->MessageData：
  逐欄位複製(id/type/description/source_pos/origin_team_id/origin_tick/strength/is_distorted/
  params.duplicate())——跟inquiry_system.gd:76壞掉的recent[0].duplicate()要做的事完全一樣
  ⇒ 今天已有2個生產呼叫點在用它(message_system.gd:133,267)
⇒ 既有入口是真的,不是沒有——但它①私有(底線前綴,本專案既有紀律=刻意不給外面用)
  ②掛在MessageSystem這支類別不是MessageData③你§1說的位置偏好是message_data.gd
⇒ 正解＝把這支函式搬去message_data.gd變成共用的(static或MessageData自己的方法),
  message_system.gd既有兩處呼叫點＋inquiry_system.gd這個新呼叫點全部改讀同一個;
  不要照§1字面的fallback另外在message_data.gd寫一份新的——那會變成兩套複製邏輯各管各的,
  以後MessageData加欄位只有一邊記得更新
```

# 3 I3(b)／I4(c)——核過，不是問題，澄清你自己的自報

```
I3(b)「判已知的方式我沒寫」：msgs分支(message_system.gd:262-266)今天就有這段既有判斷
  （existing.id==msg.id⇒已知,跳過)——判準不是待裁的新設計,是抄既有那段邏輯,
  加written計數時照它走就好,不必另外定義「同內容」那種模糊版本
I4(c)「我判正確不修,依據只是一行條件」：核過player_command_system.gd:1370(choice=="ask_faction_status"
  時跳過_exchange_intel整支呼叫)＋inquiry_system.gd的_passes_filter同一條件——兩處同條件,
  且:1366-1367有明文註解講為什麼(self-knowledge例外)——不是只有一行條件撐著,有另一個獨立
  呼叫點(_passes_filter)跟同一個常數對齊,屬於「同一個數字出現在兩個獨立判斷點」那種可信證據
```

# 4 判決

```json
{ "verdict": "issues",
  "premise_contradiction": false,
  "issues": [
    {"claim": "I2：ask_food_source寫進『決策層讀糧源的那個belief來源』（用既有寫入口，不新開儲存）",
     "file_line": "faction_ai_system.gd:7404-7429(讀者零讀belief)；message_system.gd:255-318(寫者兩分支形狀都不是『格=糧源』)；player_command_system.gd:1364-1365(record_claim四處硬封頂)",
     "truth": "兩側都查過：決策層的糧源真的只讀真值跟賣單,不讀任何位置belief;既有兩個belief-write分支的形狀也接不上;新開第三分支=開新儲存,擠進claims分支=撞你自己釘的record_claim數量上限。踩中你§1自己寫的停止條件,這一條整個要回報藍圖當WHAT題,不是HOW能直接裁"},
    {"claim": "I1：沒有既有MessageData複製入口,要在message_data.gd另寫一份",
     "file_line": "message_system.gd:325-336 _copy_message（今天已有2個生產呼叫點：:133,:267）",
     "truth": "既有入口是真的存在,只是私有＋位置在MessageSystem不在MessageData;正解是搬去message_data.gd變共用、三個呼叫點(含inquiry這個新的)都讀同一個,不要另寫第二套複製邏輯"}
  ],
  "note": "I2停下回報藍圖,我只標邊界不裁WHAT。I1改法明確(搬遷+共讀),不是停。I3(b)I4(c)自報的疑慮都核過沒事,附帶證據點給你。" }
```
