---
from: reviewer
to: systems
status: open
slice: 批尾小修二（第五輪 QA 真玩 UI 面 20 洞）
topic: R² VERDICT＝ISSUES：8 條 must-fix（M1–M8）＋ 6 條小項（S1–S6）；九個重點逐點答在第三節。靜態讀 code，沒跑測試；file:line 都是我在 main 上自己開檔對過的。
---

# 一、結論
- **ISSUES，不能派。** 多數是「spec 指的接點接不到」或「新規則的母體沒對」，不是方向錯。五組裡 C、D2、D3、D4、D6、E3–E7 我沒挑出擋派的毛病。
- 最重的三條：M1（結算頁的鍵走不到 `_global_advance_key`，而且 `L` 同時是推進鍵與留戰利品鍵）、M4（死亡停點在「戰死窗口」可能根本不響）、M5（繼承人看子隊：現有的候選過濾會把子隊候選全砍光，然後判成「全死、故事結束」）。

# 二、must-fix

## M1 A2：推進鍵到不了 `_global_advance_key`，且 `L` 撞鍵（重點 1）
- 結算頁住在 `encounter_view`（`encounter_view.gd:709` `_post_combat`）。戰鬥 overlay 可見時，主畫面 `_input` 在 `text_ui_main.gd:422-427` 直接 return，註解還明寫「含戰後『按任意鍵離開』畫面」。終端路徑是 `player_repl.gd:197-205` `press_on` → `terminal_handle_key`（`encounter_view.gd:621-627`）→ `_handle_key`。
  ⇒ 結算頁上按 Space，**兩條路都不會到 `text_ui_main._global_advance_key`（`:1332`）**。spec 寫「走既有那一句、同一支」在這條路上不成立。要嘛 encounter_view 自己回一句（＝第二份判斷，違反本票「每組一個產生者」），要嘛 text_ui 把那支函式（或那句 `GLOBAL_KEY_IN_PANEL_MSG`，`:1330`）遞給 encounter_view。請寫明哪一種。
- `_global_advance_key` 第一行判 `_current_mode_name() != "main"`（`:1333`）；結算頁不是主畫面的 mode，這個判斷對它沒有意義。HOW 要寫結算頁怎麼被那句辨認，或另立入口。
- **鍵撞了**：`ARRIVE_KEY = KEY_L`（`text_ui_main.gd:1325`），在 `GLOBAL_ADVANCE_KEYS`（`:1327`）；而結算頁的 `L` ＝ 留下戰利品（`encounter_view.gd:718-725`，spec 自己也列「既有 K／L／J」）。A2 同時寫「推進鍵（Space／X／G／L）回面板開著」與「戰利品鍵 K／L／J 在頁上可按」——**`L` 兩個意思**。要寫誰贏（我預期是留戰利品贏、推進鍵集合在結算頁上排除 L），F 格要鎖。
- 驗收：A2 床若直呼 `_global_advance_key` 就恆真（上面說了真路徑繞過它）。要用真路徑按（GUI 的 `_input` 廣播＋終端 `press_on` 兩條都按一次），n2 才紅在該紅的位置。

## M2 A1：呼叫點接在「頁關閉」，不是「結算當下」
- spec 把第二個呼叫者放在 `_on_encounter_ended`（`text_ui_main.gd:226`）。但 `encounter_ended` 這個 signal 只在 `hide_encounter()`（`encounter_view.gd:84-86`）發。A2 把頁留到玩家按 Esc ⇒ **drain 發生在玩家看完之後**，A1「戰鬥結束那一幀事件區就有結算句」在 spec 自己的 A2 之下做不到。
- 結算點有三處：`encounter_view.gd:739-743`（世界 tick 裡結算，`_post_combat = true`）、`:635-642` `sync_with_world`、`:872-878`（`encounter_ended` 結果）。請把 drain 掛在「進入 `_post_combat` 的那一刻」（三處收成一支），不是掛在關頁。
- n1「只留 `_process` 那個呼叫者 ⇒ A1 紅」：照 spec 寫法，n1 也會把 `_on_encounter_ended` 呼叫者留著，A1 格若是在關頁後才看事件區就兩邊都綠。A1 格要在「結算頁還開著」那一幀量。

## M3 A3：恆等式兩個問題——母體不同、且可能是恆真（重點 2）
- **母體對不上**：`_aftermath_begin` 記的 `pop0`（`encounter_system.gd:1417`）是整隊 `t.population`，`_aftermath_emit` 的 `pop1`（`:1571`）也是整隊；而「上場」的單位數是 `anon_spawn_count`＝`min(人口×武裝比, ANON_UNIT_CAP=30)`＋記名（`:1075-1078`、`:260-261`）。人口 40 的隊只上 ≤30 個匿名單位，另外還有**場外後備連坐**（`:1196-1197` `reserve_dead`，`kill_random(... "combat_reserve")`）——那些人死了，但不在 `dead_anon`（`:1250` 只數上場單位）。spec 寫「只算本場上過場的人」，卻拿 `pop0`/`pop1` 當輸入的話，後備死亡會直接落進「其他離隊」。這很可能就是票三④那個 6→3 的一部分；但那是**已知可歸因的**，不該印成「原因未記」。請明寫：恆等式的每一項取自哪個母體（單位清單？隊人口？），後備連坐算哪一欄。
- **被俘兩個口徑**：場上的 `is_prisoner` 單位（`:1339`、`:1471`）與結算後 `held_by_enemy`（`:1488`，經 `captive_room` 吸收，`moved` 可能 < 被俘單位數，不夠房間就「放回」`:1476-1479`）不是同一個數。spec 問的「被俘的計法與 held_by_enemy 不一致」——**現在就不一致**，「其他離隊」會有系統性餘數。請寫被俘取哪一個、另一個差額歸誰。
- **可能恆真**：若「其他離隊」＝餘數＝`上場 − 在場 − 死 − 被俘 − 逃散`，則恆等式對任何輸入成立，A3 格「雙方恆等式每一方成立」是**永遠綠**的守衛。有實質的只有「餘數 = 0（正常戰鬥）」與「人為離隊 ⇒ 1」。請把守衛改成：餘數用**第二個獨立來源**算（單位清單分類 vs. `pop0−pop1` 對帳），兩者不等才紅；n3「拿掉其他離隊欄」也要能證明紅在恆等式而不是紅在欄位不存在。
- 另：`wounded_mid` 只在一處寫（`:1216`，`resolve_anon_units` 之後），「傷」＝匿名增量這個算法（`world_events.gd:598`）spec 保留了加記名；記名重傷要在 `_aftermath_begin`（結算前）記，但**重傷是戰鬥中就轉入的**，跟匿名傷同樣是「結算時才量」——請寫記名重傷的 before 取在 `_aftermath_begin`（結算開始）還是戰鬥開始（`_spawn`），兩者差一整場。

## M4 B2：停點在戰死窗口可能不響；入口不是單次（重點 3）
- **停點閘讀 `get_player_team_id()`**：`stop_event_since`（`world_events.gd:129-138`）開頭 `ptid = state.get_player_team_id(); if ptid == -1: return {}`，且要 `subjects` 含 `ptid`。`handle_player_succession` 第一行 `team.leader_id = -1`（`event_system.gd:80`）；`get_player_team_id`（`world_state.gd:1227-1237`）在 `persons.get(player_id) == null` 時 fallback 掃 `leader_id == player_id or player_id in named_members`——leader 被清成 -1 之後掃不到 ⇒ 回 -1。`world_state.gd:1136-1137` 與 `event_system.gd:77` 都明說戰死窗口玩家 person 會不在 `persons`。
  ⇒ `player_died` 在最需要它的那個窗口，**可能被 `stop_event_since` 過濾成「沒有停點」**。QA 那局「領袖死了、推進沒停」需要先確認是 kind 不在集合（`leader_death` 不在 `ADVANCE_STOP_KINDS` `:124-126`，這是一個原因）還是閘；只加 kind 不夠。請在 spec 寫停點閘改讀誰（`_possessed_tid` 的持有人？`player_forced_event.team_id`？），並加一格：person 已 erase 的戰死窗口，推進必停。
- **「唯一入口」我只證實一半**。呼叫者（非 debug）：`event_system.gd:40`（`on_leader_death` 玩家分支）、`encounter_system.gd:1585`（`_check_player_wiped`，pop ≤ 0）、`player_command_system.gd:2097`（choose_heir 全候選死）。冪等守衛只在 `on_leader_death`（`:36-39`，已 pending 的 choose_heir 不重設）；`_check_player_wiped` 與 `:2097` 直呼，沒守衛。絕後分支（`:81-95`）設 `game_over` 之後走 `_npc_succession`，後者在無匿名人口時回 false、隊伍仍無領袖 ⇒ 我看得出安全網會再呼進來，但**沒追到每 tick 的呼叫鏈到底**，所以不斷言「一定重發」。請：事件加一把一次性的鍵（例如以 `fe.team_id`＋死亡 tick），並加床格「絕後後再推 N tick，`player_died` 不重發」。
- **觀察者世界**：`player_id == -1` 時 `:85-86` 直接 `return false`——事件必須在這個早退**之後**才發，否則無玩家世界會對 NPC 隊印「你倒下了」。spec 寫「在入口發」，請改成「過了 player_id 守衛之後」。
- **「舊句玩家隊不再發」改的是別處**：「領袖死了」那句由 `on_leader_death` 第一行 `WorldEvents.emit(state, "leader_death", ...)`（`event_system.gd:32`）發，在玩家分支判斷**之前**；改它要動 `on_leader_death`，不是 `handle_player_succession`。另 `npc_combat_system.gd:801` 還有一條呼叫 `on_leader_death` 的戰死路。請寫在哪一行加 `if` 才不誤傷 NPC。
- **死因**：`handle_player_succession(state, team)` 沒有死因參數，入口處 `leader_id` 已被清；spec 的「你倒下了（死因）」資料從哪來沒寫。

## M5 B3：現有的候選過濾會把子隊候選砍光（重點 4）
- 實證三處：
  1. `get_forced_response_options` 的 choose_heir 分支（`player_command_system.gd:2018-2027`）只留 `pt.named_members.has(ip)` 的候選；子隊成員不在 `pt.named_members`。`respond_to_forced` 的 choose_heir（`:2089-2102`）一進來就用它重查，**空就判「全候選已死 → 終局」**。⇒ 只改 `event_system.gd:79-103` 的候選來源，子隊候選會被這裡全部丟掉，然後玩家被判故事結束。
  2. `_action_choose_heir`（`:2252-2280`）用 `state.set_leader(team, heir_id)`（`:2273`）；`set_leader`（`world_state.gd:765-780`）強制 `p.team_id = team.team_id`——**把繼承人的 team_id 改成母隊**，但他還在子隊 roster。這正是 `:2266-2270` 註解記的 P127（team_id 指向 A 而 A 的 roster 沒有他）的反向。
  3. `sync_possession`（`world_state.gd:1154-1161`）的輸入是 `persons[player_id].team_id`；它**不「移動附身」**，只是反映 person 的 team_id。spec 說「附身移到子隊，走既有唯一寫者 sync_possession」——這句會讓實作端找不到要改什麼。真正要寫的是「繼承人所在隊」的 roster 搬動（哪個 chokepoint？）。
- 請明寫：選了子隊成員之後 (a) 他在子隊裡是什麼身分（子隊原領袖怎麼處置，`set_leader(sub, heir, ?)` 的 `old_leader_action`）；(b) `sub.parent_team_id` 是否保留——保留的話 `player_controlled_ids_derived`（`world_state.gd:1182-1192`）要求子隊 `dispatched_by_player` 且 parent==possessed，母隊已不是 possessed，子隊會被 `subteam_system` 當成 NPC 母隊的子隊對待（可能被召回／併回，`subteam_system.gd:346` 附近）；(c) 母隊「照 NPC 繼承規則續走」指 `_npc_succession`。
- (b) 是 WHAT（子隊變獨立隊？留在 NPC 母隊名下？）——藍圖票 B 條沒寫，這個我不裁，請經藍圖補一句；HOW 不要自己選。
- **畫面中心跳格**：需要另一句。附身換到別格的隊，玩家視窗（游標／`H` 回自己）會換格；沒有一句「你改附身在 <隊>（x,y）」玩家只會看到畫面突然換。這是 HOW 內的顯示句，不越界；但要等 (b) 定了才寫得完整。
- 感知：子隊是自己派的、屬自家事實，沒問題。

## M6 D1：`last_encounter_result` 變長壽之後，沒人會清它（重點 6）
- 現在「收割後無其他待處置就整份清掉」（`_mark_loot_done`，`player_command_system.gd:1350-1353`）其實同時是**唯一的常態清除點**。spec 拿掉之後，spec 寫「下一場戰鬥覆蓋時才清」——但覆蓋的寫入點只有一般勝負那一條（`encounter_system.gd:1360`）；野獸戰與平手**提早 return、不寫它**（`:1284-1290`、`:1298-1305`，`world_state.gd:1125` 註解也這樣說）。
  ⇒ 贏一場、收割、（不再收編）、之後打一場獸或平手：舊結果仍在，`can_subjugate`＝true、`winner_id` 還是玩家 ⇒ `precheck_take_loot`（`:606-612`）：`loot_done` 若被某路清掉就重新可收；`precheck_subjugate_enemy`（`:624-631`）會對**幾天前的敗者**列「收編」。`encounter_view.gd:151/199` 也會用舊 `res` 畫戰果摘要。
- 要求：寫清楚清除點——至少「任何一場遭遇戰結算（含獸／平手）開頭先清」或「結果帶 tick＋同格條件、過期不列」。`res["tick"]` 已存在（`:1365`）。D1 床加一格：勝仗收割→再打一場獸戰→J 不列。
- `subjugate_block_now`（`:637-643`）spec 的修法方向對，我確認過：現況 `l == null` 回 ""，precheck 因此通過，`_action_subjugate_enemy` 到 `:1634-1635` 才說「敗者已消滅」＝列的條件≠做的條件，正是 D1 要鎖的。但 `:1634-1635` 那兩行改後變成第二份判斷，請 spec 寫「刪掉或明標為保險」。
- 其餘讀者（重點 6 問的）：`aftermath_stage`（`:697-702`）、`settle_pending_aftermath`（`:844-866`）都以 pending 欄位為準，不因結果存活變長而誤判；`player_query_api.gd:474` 只讀 `loot_pool`。我沒挑出別的。

## M7 E2：被收掉的表有非 UI 讀者，spec 漏列（重點 8）
- `OUTPOST_NAMES` 的讀者：`outpost_system.gd:1177` `get_outpost_name(type, level)`——**按等級取名的清單**（`names[level-1]`），不只「類型名」；`player_command_system.gd:1109`、`:1434`（取 `[0]`）。spec 的 tsv 加列只寫「據點類型（civilian／military）」，沒有等級名。
- `BEAST_LABEL` 的讀者：`player_api_mapper.gd:1054`，以及 `text_ui_view.gd:202` `for b in PlayerApiMapper.BEAST_LABEL.values()`（spec 完全沒提）。spec 的猛獸例「boar、bear…」，實際表有 deer／boar／bear／wolves 四種（`:979`）。
- `TASK_DISPLAY` 讀者 `text_ui_main.gd:1570`，另 `team_ui_helper.gd:40` 的註解自稱同一條教訓——請確認那邊沒有第二份表。
- 要求：交件前列「每個被收掉的表的所有讀者」；加一格「改前改後 `get_outpost_name` 對全部 type×level 輸出逐字相同」。sim 側讀 `TextBank` 已有先例（`world_events.gd:630` `TextBank.res_name`），分層上可以，但輸出必須不變。

## M8 D5：那一支存在，但挑法不是你以為的（重點 7）
- 存在：`BeliefSystem.best_claim`（`belief_system.gd:223-234`），情報頁同源（`player_query_api.gd:96`）；它讀 belief，感知合規。
- 但它挑的是 **`effective_credibility` 最高、同分取較新**（`_pick_best` `:237-245`），**不是最新、也不是親見**。站著不動的目標，若有一筆可信度高、位置不同的轉述，`best_claim` 仍會在轉述與親見之間來回挑 ⇒ 「位置變了」判斷用的基準在變 ⇒ 同一個病換了形狀。
- 另外 `best_claim` 會抬計數器（`Probe` 的 `bel.best_call`/`bel.best_hit`，`:225-229`）。同檔 `:236` 的註解與 `best_value_quiet`（`:247-249`）就是「給寫入前後比對用，不抬計數」。請 spec 指名用 `_pick_best`／`best_value_quiet`，不要用會抬計數的那支。
- D5 床格要造「一筆較高可信度、位置不同的舊轉述」＋「同格不動 24 小時的親見」；沒有這個 fixture，改回「第一筆」也不一定紅（n7 不一定紅在該紅的位置）。

# 三、九個重點逐點答（沒列在 M 的）
- 重點 1：M1。
- 重點 2：M3。
- 重點 3：M4。
- 重點 4：M5。
- 重點 5（C）：
  - 放棄據點的舊第二次按鍵（`text_ui_main.gd:3123-3129`，旗 `_outpost_pending_abandon`）遷進同層，合理。
  - **公庫徵用＞50% 不併的理由站不住**：理由寫「有門檻、不是不可逆」，但它是**同一個手勢**（`:2959-2964` `_faction_extract_pending` 的二次按鍵確認）。留著就是兩份確認寫法，違反本票自己寫的「每組一個產生者」。要嘛併進同一層（`confirm` 種類，不必標不可逆），要嘛交件信附「為何此處不能用同一層」的實證。休息我沒追，不評。
  - `aftermath_kill`／`residents_massacre` 是 `ACTION_SHAPE` 的 `listed: true, effect: encounter_result`（`player_command_system.gd:516/522`），在 A2 之後住在 **encounter_view 的結算頁**上按；`_confirm_irreversible` 寫在 TextUI（spec 寫「TextUI 一支」）⇒ 跟 M1 同一個跨節點問題：encounter_view 怎麼叫到它？請同時回答。
  - tap 名稱 `ui.confirm.shown.<action>`：床格要真的按到每一個動作（含結算頁上那兩個），不是只按 TextUI 這邊的四個。
- 重點 6：M6。
- 重點 7：M8。
- 重點 8：M7。
- 重點 9（驗收格與負對照）：
  - 恆真：A3 恆等式（M3）、A2 若直呼函式（M1）、A1 在關頁後量（M2）。
  - E2：「`ui.display_name.miss` 計數印出」只是印，**不是斷言**——請改成「走過的畫面 miss 計數 ＝ 基準值」並寫基準；否則漏網的永遠不會紅。誠實限那條已承認 grep 只看得到走過的畫面，這裡補上斷言才算守住。
  - E4：「主畫面處理的字母鍵 ⊆ 鍵列」——床怎麼「列舉主畫面處理的鍵」沒寫。手抄一份字母表就是恆綠；請寫成逐鍵驅動（A–Z 各按一次、記錄哪些不回「無作用」）或從 `_input` 的 match 分支機械抽出，並列出母體大小。
  - B1「同一個重傷不重發」需要一個邊緣記憶欄（上一拍是否已 critical）；放哪（進不進 fp／存檔）spec 沒寫，存檔重載後會不會重發要說。
  - B2 床：加「person 已 erase 的戰死窗口」與「`_check_player_wiped` 路徑」兩格（M4）。

# 四、小項（不擋，併同輪）
- S1 A2 的「Esc（或 Enter）關頁」：`Enter` 在 encounter_view 的 `_handle_key` 戰後分支（`:731-734`）目前是「其餘任意鍵離開」；改成只剩 Esc／Enter 之後，**其他鍵不再離開**——舊床（`terminal_e2e_bed.gd:216` 等）按任意鍵離開的會卡住，遷移表有列床，請列到鍵層。
- S2 A2 讓結算頁對所有玩家參戰戰鬥都留：`is_settled_for_terminal`（`encounter_view.gd:646-649`）的語意（`_post_combat` 為真時視為未收）會被終端的等待迴圈影響，`press_on` 的等待條件請一起驗。
- S3 A4 結果行 N 列 TEST VALUE 3：寫來歷即可；不擋。
- S4 A5 頂列「傷 N+M」進 `TOP_ORDER`：請寫它的最小寬度與整格讓位時被丟的順序已含它的測試格（F 格 A5 只驗有/無，沒驗窄終端）。
- S5 C 改鍵：勢力面板 D（背叛）、E（解散）改鍵，**C（離開勢力）鄰近**——spec 沒說 C 是否也要檢查，鍵位規則（不是移動字母／推進鍵／Y）對 C 也適用，請在 F 格（不可逆鍵 ∩ 移動／推進／Y ＝ 空）的母體列出全部六個動作的最終鍵。
- S6 E1「這一拍你沒有行動」：`key_reply()` 的 `_feedback_line` 回退來自 `text_ui_main.gd:1067`，請確認終端欄位 `terminal_block`（`encounter_view.gd:693` 註解「每一鍵的回應只有結果行一個出口」）同步，不要只改 GUI 路。

# 五、結論與下一站
- **ISSUES**。M1–M8 修完回 R²b，只審 M1–M8 對應段落＋S1–S6 有沒有被收。
- M5(b)（子隊獨立或留在 NPC 母隊名下）是 WHAT 缺口，請經藍圖補一句，不要在 HOW 裡自選。其餘都在 HOW 範圍內。
- 本輪沒審 D2、D3、D4、D6、E3、E4（除上述）、E5–E7 細節：沒挑出擋派問題，不等於逐行驗過；這些我只讀了 spec 的 file:line 與周邊，沒有展開成負斷言。
