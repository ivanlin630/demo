---
from: reviewer
to: systems
status: consumed
slice: R² 情報面板（c5a7d3520）
topic: R② ＝ **小 ISSUES（五處,同版補,不需再審）**｜方向對（不開第二面板）;你三問:①_known_outpost_relations 其實【已經以隊為單位】（游標處 F7 就以 pt 呼叫,player_query_api.gd:432）,唯一的人層讀取是『該隊 leader 的 relation_edges』——非領袖附身時是 NPC 領袖的恩怨;②隊伍『關係』讀 TeamData.known_reputations（隊層 belief）,據點的 g 沿用同一支;③改名成本=3 支床 4 個呼叫點（不是 4 支床）,值不高,且床以 JSON 前後比對該面板 ⇒ 新欄位【不得含相對現在的時間】;另:『最後所知位置』要過與游標處同一道 staleness 閘,否則 I7 對舊情報必紅;『距今多久』要用 value.last_tick（位置年齡）不是收到訊息的時間
---

# 0 審了哪棵樹
main c5a7d3520。核對 player_query_api.gd:53-90,412-480;faction_ai_system.gd:6060-6110;text_ui_main.gd:1794-1810;message_system.gd:247-330;
belief_system.gd:99,213-236;全 scripts 對 query_memory_panel 的呼叫端。

# 1 你問的第 1 點:_known_outpost_relations 與附身隊
```
簽章 `_known_outpost_relations(state, leader_team: TeamData)`——參數名叫 leader_team,但游標處 F7 已經用【玩家隊 pt】呼叫它（player_query_api.gd:432 `…_known_outpost_relations(state, pt)`）,不是『領袖隊』專屬。
函式內讀的東西:
  ·BeliefSystem.known_outposts(state, leader_team.team_id)：【這一隊自己】的據點 belief（註解:親見時寫、relay 不寫）——隊層,不是勢力層 ✓
  ·state.factions[leader_team.faction_id].member_team_ids：『我勢力的名冊』（自知,註解已論證合法）✓
  ·【人層】me_leader = state.persons[leader_team.leader_id].relation_edges → grat/feud:這一隊 leader 的恩怨。
結論:不會讀到『勢力的』或真值的據點資料。唯一要想的是上面最後一項:附身者不是 leader 時,g 反映的是 NPC 領袖的好惡,不是附身者自己的。
  F7 游標處已經這樣出貨;面板沿用同一支就與游標處一致（I7 成立）。但這是個感知邊界的小問題:
  請在 spec 寫明二選一:(a)『g 是隊的立場（取自領袖）』並在面板標頭一句話;(b) 附身者非領袖時 g 欄顯示『—』只留主人與名冊關係（+1 自家勢力）。
  建議 (a)——F7 已是 (a),改 (b) 會讓面板與游標處不一致。需要 WHAT 的話請藍圖知道,不擋。
```

# 2 你問的第 2 點:『關係』欄讀哪一份
```
隊伍類:TeamData.known_reputations（message_system.gd:~262 `giver.known_reputations.get(receiver_id, 0.5)` 證它是『這一隊對別隊聲望』的隊層欄;細則 1a 把它列為 belief 欄）。
  不要讀 leader.relations／relation_edges 來當隊伍類的『關係』——那是人層,而且與據點的 g 雙軌。
  未知 ⇒ 顯示『不明』,不要用預設 0.5 當值（message_system 的 get 預設 0.5 會讓『不知道』顯示成『中立』;兩者不同——第三態）。
據點類:g 沿用 _known_outpost_relations（見 §1）,一個來源。
```

# 3 你問的第 3 點:改名
```
呼叫端普查:sim_bridge.gd:236（轉發）←text_ui_main.gd:1796（唯一玩家端使用);床:inquiry_v1_bed.gd:258、inquiry_writes_bed.gd:141,149、terminal_e2e_bed.gd:462（另有 :7,:441 註解）
  ⇒ 3 支床、4 個呼叫點（你寫『4 支床』是把 bridge 算進去了）。
價值:低。『query_memory_panel』是查詢面的名字,頁籤名是呈現名,兩者不必一致;改名換來的是兩個名字(若留轉呼叫)或一次全改。
  若改:一次全改、不留別名（留別名＝兩個名字指同一物,下一個人不知道哪個是真的）。若不改:在函式註解寫『頁名＝情報』。我傾向不改,省 3 支床的動作。
★比改名更要緊的:inquiry_writes_bed 以 `JSON.stringify(query_memory_panel())` 前後比對（:141,:149）,terminal_e2e_bed 把它整個存成快照（:462）。
  面板的 payload 必須是 belief 狀態的【純函數】:不得含相對現在的欄位（『N 分鐘前』『距今』）,否則同一份 belief 隔一個 tick 兩次呼叫 JSON 就不同,這些床會因時間流逝紅或誤判。
  ⇒ 查詢回【絕對 tick】（last_tick），『N 分鐘前』在 UI 組句時用 current_tick 算。I2 的『N 分鐘前』斷言在 UI 層驗。
```

# 4 其餘四處
```
①staleness 與 I7:游標處（_remembered_teams_at,player_query_api.gd:467-480）用 BeliefSystem.belief_pos 過濾,belief_pos 帶 staleness 閘（belief_system.gd:~140 BELIEF_STALE_TICKS）;
   面板若直接印 best_estimate.tile_pos,舊情報在面板有、在游標處沒有 ⇒ I7 對舊情報紅。
   ⇒ 面板對超過閘的情報標『（太久,視同不知）』並從 I7 母體排除（I7 只驗未過期者）；或與游標處同閘一起隱藏。要選一個寫進 spec,別讓兩處各自判。
②『距今多久』用 value.last_tick（位置被確認的時間;轉述時 entry 繼承了 giver 的 last_tick,所以是原始觀察時間）,不是 claim 收到的 tick。
   現行記憶頁印的『最新 T』是 claim 層的 last_tick 取最大;新欄位要換成位置年齡,並在欄標明確寫『位置是 N 分鐘前的』,否則玩家把轉述舊位置當新的。
③『親見』判定:不要自寫『source 是自己』——重用 _remembered_teams_at 已有的謂詞（source_type==『親見』且 source_id==ptid;別隊轉述的『親見』對我仍是聽說,player_query_api.gd:477）,單一來源。
④位置缺:known_targets 包含只有 claim 沒有 tile_pos 的對象（belief 註解:『有 claim 不代表有位置』）;best_estimate 可能是 {}。這類印『位置不明』,不是略過也不是 (-1,-1)。
   I2/I3 補一格:只有實力估沒有位置的對象。
⑤長清單『每類最多 N 列＋另有 M 筆』:N 由可用列數推 OK;分頁列數受上下排後的框高影響（地圖整寬票）——N 要在該票版面確定後再推,或讀分頁框實際可用列數,不寫死。
```

# 5 判決
```
verdict: issues（小）;①~⑤ 與 §1 §2 §3 同版補,不需再審
最要緊:§3 的『payload 不含相對時間』（會讓 3 支床誤紅）與 §4① 的 staleness/I7
```
