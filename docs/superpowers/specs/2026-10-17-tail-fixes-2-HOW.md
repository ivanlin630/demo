# 批尾小修二（第五輪 QA 真玩 UI 面 20 洞）— HOW（定稿，依 R² M1–M8／S1–S6、R²b N1–N3／T1–T4、R²c C1–C3）

- WHAT：藍圖票 `docs/superpowers/handbacks/2026-10-17-blueprint-to-systems-TICKET-tail-fixes-2-and-all-hands-on-field-pulled-forward.md` 票一（五組 A–E）；裁決檔 `docs/playtest/round5-verdict.md`。
- 來源表：`docs/playtest/2026-10-17-round5-qa-live-play.md` §二 ★1–★20、21、22。
- 審查：R² `docs/superpowers/handbacks/2026-10-17-reviewer-to-systems-R2-tail-fixes-2-ISSUES.md`、R²b `…-R2b-tail-fixes-2-ISSUES.md`。本版各段標了對應的 M／S／N／T。
- 排序：開點目標票交件之後（藍圖 2026-10-17 確認不插隊）。
- 範圍：玩家面。世界行為只動一處，是 WHAT 已裁的：D1 收割不消滅敗者狀態。
  - B3「繼承人看子隊」這版**縮成只改句子**。子隊繼承有一題 WHAT 缺口，已送藍圖（`2026-10-17-systems-to-blueprint-Q-heir-from-subteam-what.md`），提議另開一張。
- file:line 是 main `1f7679c26` 上靜態讀的，動工時先重對一次。
- 共同規則：
  - 每一組都只准有**一個產生者**。不准在兩個地方各寫一份同樣的句子、表或判斷。
  - 新的事件類型、停點、確認層都要接 tap（Probe 計數），名字寫在各組裡。

---

## A 戰鬥結算讀得到（★11 ★17 ★12 ★2 ★3 第 6 條）

### A0 結算頁住在哪（M1、M2 的共同前提）
- 結算頁＝`encounter_view` 的戰後階段（`_post_combat`）。戰鬥 overlay 可見時，主畫面 `_input` 直接 return（`text_ui_main.gd:422-427`）。
- 兩條按鍵入口：
  - GUI：引擎廣播到 `encounter_view._input`；
  - 終端：`player_repl.gd:197-205` `press_on` → `terminal_handle_key`（`encounter_view.gd:621-627`）。
- 兩條最後都進 `_handle_key`。
- ⇒ 結算頁上的所有鍵，都在 `encounter_view._handle_key` 的戰後分支（`:709-734`）處理，不經 `text_ui_main._global_advance_key`。

### A1 結算當下就進事件區（M2）
- 現況：
  - `read_player_events()` 讀進 `_feed_rows` 只有一處，在 `text_ui_main.gd:282-299`，位於 `_process` 的推進分支裡。
  - `encounter_ended` 這個 signal 只在 `hide_encounter()`（`encounter_view.gd:84-86`）發，也就是關頁時。
- 改：
  - **進入戰後階段收成一支**：`encounter_view._enter_post_combat()`，取代今天三處各自設旗：
    - `:739-743`
    - `:635-642` `sync_with_world`
    - `:872-878` `encounter_ended` 結果
  - 它設 `_post_combat`／`_waiting_for_player`，並發一個新 signal `settled`。
  - `text_ui_main` 把 `:282-299` 抽成 `_drain_player_events()`，兩個呼叫者：
    - `_process` 推進分支（照舊）；
    - `settled` 的接收端。
  - ★讀者仍只有一支。`_on_encounter_ended`（關頁）不再負責 drain。

### A2 結算頁擋推進（M1、S1、S2）
- 現況：
  - 戰後畫面只有 `can_subjugate` 時才留著（`:872-878`）。
  - 戰後分支裡 K／L／J 以外的任意鍵都會關頁（`:731-734`）。
  - 下一次推進就是 `settle_pending_aftermath`（`player_command_system.gd:844-865`），會替玩家套用被動選項。
- 改：
  - 只要玩家參戰，`_enter_post_combat()` 一律留頁。
  - 頁上印：
    - A3 的結算句（整句，A4 的換行規則）；
    - 當下的待處置選項。來源＝`player_query_api.gd:446-484` 那一份，與 T 面板同源，不另列。
  - 頁上選項的鍵：
    - 待處置選項用數字鍵，走同一條 `execute_action`；
    - 戰利品／收編沿用 K／L／J。
  - **鍵衝突的規則（M1）**：頁上自己綁的鍵優先。這與主畫面面板的既有慣例 `_mode_binds_key`（`text_ui_main.gd:1435-1451`）同一條。
    - ⇒ 結算頁上 L＝留下戰利品，不是「走到抵達」。
  - 推進鍵：
    - 結算頁上「推進鍵」＝`TextUiMain.GLOBAL_ADVANCE_KEYS` 減去頁上自己綁的鍵（今天＝Space、X、G）。
    - 按到時回 `TextUiMain.GLOBAL_KEY_IN_PANEL_MSG`：同一個常數、同一句，**不另寫一句**，**不關頁、不推進**。
    - 判斷「這是面板」的是結算頁自己；它本來就是面板，不需要再判 mode。
  - 關頁：
    - 只有 Esc 或 Enter 關頁。關了＝看過了；之後推進照舊套被動選項，並發「你沒有處置：…」。
    - 其他未綁的鍵回「這一頁只收：<頁上的鍵>；Esc 關閉」，不關頁。
  - S2：
    - 頁開著時 `_waiting_for_player = true`，所以 `is_settled_for_terminal()`（`:646-649`）回 true，`press_on` 不會卡住等待。
    - 床裡要用終端路徑按一次來驗。
- tap：`ui.settle_page.shown`、`ui.settle_page.advance_blocked`、`ui.settle_page.unbound_key`。

### A3 結算句的內容（M3）
- 現況：`world_events.gd:573-634` `combat_end_sentence` 是唯一產生者。
  - 傷只算匿名（`:598`）。
  - 逃散只在可追擊時出現。
  - 記名重傷只在敗方提一句註記。
- **你方**，固定六欄，0 也印：死、傷、逃散、被俘、後備陣亡、其他離隊。
  - 母體＝**你的隊**。人口 before 取在**開戰那一刻**（`_spawn`），after 取在 `_aftermath_emit`（`encounter_system.gd:1571` `pop1`）。
  - 各欄的來源，都是寫入點計數，不從人口差回推：
    - **死**＝場上戰死：`dead_anon` 加 `dead_named`（`:1228-1256`）。
    - **後備陣亡**＝場外連坐：`reserve_dead`（`:1196-1197`，`kill_random(... "combat_reserve")`）。這是已知去向，單獨一欄，不落「其他」。
    - **被俘**＝結算後**真的被移走**的人：`held_by_enemy`（`:1488`，經 `captive_room`）。
      - 場上 `is_prisoner` 但因沒房間被放回的（`:1476-1479`）不算被俘，因為他們還在隊上。
    - **逃散**＝本場離開戰場、沒死沒被俘、仍屬原隊的人。他們不減人口，只報數。
    - **傷**＝匿名傷兵增量（`wounded_mid − wounded0`）＋記名成員**開戰時**不是重傷、結算時是重傷的人數，名字附括號。
      - before 取在 `_spawn`，因為重傷是戰鬥中轉入的。
      - 「重傷」判準＝`_get_hp_status`（`text_ui_main.gd:1186-1197`／`player_api_mapper.gd:845`）。把它搬到模擬側一支 static，兩邊共用，不寫第二份。
    - **戰後處置與追擊**（N1）：NPC 留場時，`_aftermath_captives_fate_pursuit`（`:1324`）會在 `pop1` 之前當場減你的人口：
      - 傷兵被殺：`fate_killed`（`:1540`）；
      - 傷兵被俘走：`fate_captured`（`:1542`），與 `held_by_enemy` 是兩個欄；
      - 追擊陣亡：`pursuit_killed`（`:1548-1553`）。
      - 這三項今天句子已有（`world_events.gd:613-625`），保留成獨立子句，併進對帳。
  - **人數對帳**（第二個獨立來源，不是餘數恆等式）：
    `人口差（before − after）` 對上 `死 ＋ 後備陣亡 ＋ 被俘（held_by_enemy）＋ fate_killed ＋ fate_captured ＋ pursuit_killed`。
    - `resolve_negative_flags`／`resolve_anon_units`（`:1213-1214`）若另有扣人口的路，由對照仗抓出來，不靠靜態讀。
    - 正常戰鬥兩邊必相等。
    - 不等時，差額印成「其他離隊 N（原因未記）」，並 `Probe.bump_sample("combat.pop_unreconciled", {...})`。
    - ★床格斷言的是「正常戰鬥差額＝0」，以及「人為移走一名成員 ⇒ 差額＝1、句子有那一欄」。不是斷言等式成立。
    - 票三④（6→3）的真實去向由量測員查；這一欄先保證數字不無聲消失。
- **對方**（M3 感知）：只印玩家**在場親見**的欄位：場上死、傷、逃散、被你俘。
  - 不印對方人口差，也不對帳：對方的後備和隊伍總人口不是玩家看得到的事。
  - 「對方 6→3」若出現在某個畫面上，那是另一個 god-view 顯示點，量測員票三④會指出位置。
- 戰利品照舊印可收清單。
- 收取戰利品回句（★12）：`player_command_system.gd:1317-1334` 的 `"收取戰利品成功"` 改成「收取戰利品：糧食 37、錢 131、粗製近戰武器 2」。
  - 數量就是 `:1332` print 的那一組。
  - 物品名走 E2 的顯示名表。

### A4 事件區與結果行整句不截（★17、S3）
- 現況：
  - 事件區 `text_ui_view.gd:300-302` 和結果行 `:317-318` 用 `clip_to`，無聲截斷。
  - 頂列已依 10-14 裁改成整格讓位。
- 改：
  - 這兩處改成**換行**：切點在全形標點或空白，沿用 `_keymap_lines`（`:330-347`）的寫法，抽成一支共用函式。
  - 事件區容量以列計：放不下就**整則丟最舊的**。
  - 結果行最多 3 列（TEST VALUE）。3 列是「結算句全文在 80 欄終端約 2–3 列」的量級，超過時整句移進事件區，結果行留前段加「（全文見事件區）」。
  - 判準：任何一則事件或結果，畫面上那幾列串起來＝原句全文。

### A5 傷兵欄（第 6 條、S4）
- snapshot 已有 `controlled_team.wounded`（`player_api_mapper.gd:190`），TextUI 沒讀。
- 生存頁加一行「傷兵：匿名 N、記名重傷 M（名…）」。M 用 A3 那支共用判準。
- 頂列加一格「傷 N+M」：
  - 只在 N+M > 0 時出現；
  - 進 `TOP_ORDER`，`TOP_DROP_ORDER` 排在 camp 之後、team 之前；
  - 最小寬度＝「傷 99」。
  - 床格要含窄終端：讓位時它在 camp 之後被丟。

---

## B 玩家的停點（★1）

### B0 停點閘認誰是玩家（M4）
- 現況：`stop_event_since`（`world_events.gd:129-139`）讀 `get_player_team_id()`。
  - 戰死窗口裡，玩家 person 已不在 `persons`，leader 也被清成 -1 ⇒ 回 -1 ⇒ 沒有停點。
- 改：停點閘改認 `TeamData.possessed` 事實欄為真的那支隊。
  - 唯一寫者 `WorldState.sync_possession`；不變量 #12 已規定它在戰死窗口保持。
  - 找不到 possessed 隊時才 fallback `get_player_team_id()`。
- 床格：person 已 erase 的戰死窗口，`player_died` 照樣停。

### B1 重傷警告＝停點
- 新事件 `player_critical`：「你重傷，不醫會死」。加進 `ADVANCE_STOP_KINDS`，機制同「開始挨餓」。
- 只在**轉入**重傷那一拍發一次：
  - 寫入點＝記名成員身體部位轉成 critical 的唯一寫者，實作端在交件信寫 file:line。
  - 邊緣記憶：PersonData 新欄 `critical_announced: bool`。
    - 轉入時設 true；狀態離開 critical 時清掉。
    - 進存檔，所以重載後不會重發。
    - NPC 世界不寫它（只有玩家本人會設），world-fp 不應變；若變，照例歸因。
- tap：`stop.player_critical`。

### B2 玩家死亡＝停點，主詞是「你」（M4）
- 發事件的位置：`handle_player_succession`（`event_system.gd:79-`），**在 `player_id == -1` 早退（`:85-86`）之後**，觀察者世界不發。
- 只在**死的是玩家本人**時發（T4）：`on_leader_death` 的玩家分支判的是「這支隊是玩家隊」（`event_system.gd:34`）。
  - 實作端先確認玩家是否恆為領袖。
  - 若玩家可以是非領袖成員，領袖死而玩家活著時不發「你倒下了」，走既有的 NPC 繼承句。
  - 交件信寫結論。
- 一次性：WorldState 新欄 `player_death_announced: Dictionary`，鍵＝`team_id`，值＝死亡 tick。
  - 同一支隊同一次死亡只發一次。
  - **清除**（N3）：繼承完成時，在 `_action_choose_heir`（`player_command_system.gd:2252-2280`）清 `player_forced_event` 的同一處，清掉該隊的鍵。
  - 進存檔，因為「已宣告但還沒選繼承人」時存檔重載不重發；不進 fp，只有玩家世界寫它。
  - 三個呼叫者都經過同一支函式，所以守衛只放這裡：
    - `event_system.gd:40`
    - `encounter_system.gd:1585` `_check_player_wiped`
    - `player_command_system.gd:2097`
- 句子：「你倒下了」。
  - 今天 `handle_player_succession` 沒有死因可讀，所以不印死因（誠實限）。
  - 死因要接時，從 `on_leader_death` 帶參數下來，那是另一張。
- 加進 `ADVANCE_STOP_KINDS`。本拍推進必停，下一個鍵才進「選繼承人」或「故事結束」頁。
- 舊句「<隊> 的領袖死了」由 `on_leader_death` 第一行發（`event_system.gd:32`），在玩家分支之前。
  - 改那一行：`if not team.possessed:` 才發。
  - NPC 隊照舊。`npc_combat_system.gd:801` 那條戰死路也經過 `on_leader_death`，同一個守衛。
- 床格：
  - 戰鬥中玩家戰死 ⇒ 停、句子「你倒下了」、沒有「領袖死了」；
  - `_check_player_wiped` 路徑 ⇒ 停；
  - 絕後後再推 N tick ⇒ `player_died` 不重發；
  - 死→選繼承人→再死 ⇒ 兩次都停；
  - 觀察者世界（無玩家）⇒ 0 則。
- tap：`stop.player_died`。

### B3 「無繼承人」句子照實（M5：縮範圍）
- 現況：候選只讀本隊 `named_members`（`event_system.gd:79-103`），另外還有兩處同樣只認本隊：
  - `player_command_system.gd:2018-2027` 的候選過濾；
  - `set_leader` 會把人的隊改成母隊（`world_state.gd:765-780`）。
- 本票只改句子。「玩家絕後」今天有兩個產生者（T3）：`event_system.gd:88` 與 `player_command_system.gd:2100`。收成一支 `EventSystem.story_end_reason(state, team)`，兩處都呼它（R²c C2）：
  - 回的字串就是 `game_over_reason`，UI 直接顯示（`text_ui_main.gd:1001-1002`，前綴「故事已結束：」由 UI 加）⇒ 下面兩句**不帶**「故事結束：」前綴；
  - `player_command_system.gd:2098-2100` 那支 team 可能是 null ⇒ 回「你沒有可以接手的人（隊已滅）」；
  - `game_over_reason` 不在 `state_fingerprint`，world-fp 不動。
  - 本隊沒有記名成員、但現有子隊（`subteam_ids`）有時，故事結束句改成：
    「本隊沒有記名成員可以接手（子隊 <名> 有記名成員，從子隊接手還沒做）」。
  - 兩邊都沒有：「你沒有可以接手的人」。
  - 判定本身不改。
- 子隊繼承：等藍圖裁「子隊變成什麼」、量測員票三③回來後另開一張。

---

## C 確認層（★5；重點 5、S5）

- **一個確認層，給 TextUI 與結算頁共用**：新類別 `ConfirmGate`（RefCounted，`scripts/ui/confirm_gate.gd`）。
  - `arm(action_id, prompt) -> String`：回提示句「確定要<動詞>？這不能撤回 [Y]確定 [其他鍵]取消」。
  - `consume(keycode) -> bool`：Y ⇒ true；其他鍵 ⇒ 取消、回 false。
  - TextUI 和 `encounter_view` 各持一個實例，呼叫同一支類別。提示句與判斷只在這裡寫一次。
- `ACTION_SHAPE`（`player_command_system.gd:456-533`）的列加欄位 `confirm`，值三種：
  - `"irreversible"`：每次都確認；
  - `"conditional"`：條件成立才確認。
    - 列上放條件的**名字**（字串，例 `"hostile_adjacent"`、`"extract_over_half"`），由 `ConfirmGate` 旁一支分派函式求值。
    - `ACTION_SHAPE` 是常數字典，放不進 Callable（T1）；實作端先開檔確認。
  - 不填：不確認。
- 進這一層的動作：
  - 不可逆：
    - 背叛勢力（`text_ui_main.gd:2949`）
    - 解散勢力（`:2954`）
    - 離開勢力（`:2944`）
    - 屠村 `residents_massacre`（結算頁）
    - 殺傷兵 `aftermath_kill`（結算頁）
    - 放棄據點（`:3123-3129`）
  - 條件確認：
    - 公庫徵用超過 50%（`:2959-2964`）；
    - 休息時敵對在一格內（`:1371-1384`）。
- ★三份既有的「再按一次」寫法刪掉，遷進這一層：
  - `_outpost_pending_abandon`
  - `_faction_extract_pending`
  - `_rest_confirm_armed`
  - 床格 grep 這三個名字＝0。重置點 `text_ui_main.gd:3975-3976` 一起改成重置 `ConfirmGate`。
- 處決俘虜 `interaction_system.gd:1537` 沒有玩家動詞，不在本票。日後加動詞時，它的列必帶 `confirm: "irreversible"`。
- **鍵位**：
  - 帶 `confirm` 的動作，其鍵不准是：
    - 游標移動字母（主畫面 WASD、戰鬥 QWEASD）；
    - 推進鍵（Space／X／G／L）；
    - Y。
  - 勢力面板的 D（背叛）、E（解散）改鍵，C（離開）也照同一條檢查，鍵由實作端選。
  - 面板文字（`:3080`、`:3083`）與 `MODE_KEYMAP`（`:1233`）跟著改。
  - 交件信列出八個動作的最終鍵。
- tap：`ui.confirm.shown.<action>`、`ui.confirm.cancel.<action>`。

---

## D 列的條件＝做的條件（★4 ★6 ★7 ★8 ★9 21）

### D1 收割與收編（M6）
- 收割（`_mark_loot_done`，`player_command_system.gd:1350-1355`）只標 `loot_done`、清 `loot_pool`，**不清**敗者狀態。WHAT：收割不消滅敗者。
- **清除點**（M6）：`last_encounter_result` 在**任何一場遭遇戰結算開頭**先清。
  - 含獸戰、平手。今天它們在 `:1284-1290`、`:1298-1305` 提早 return、不寫結果。
  - 清的位置放在三條結算路徑共同經過的 `:1202`（`last_encounter_outcome` 寫入處）之前，一處。
- 再加一條列出條件：敗者不在玩家這一格就不列「收編」。
  - `subjugate_block_now` 回「敗者已不在這裡」；敗者不存在或人數 0 回「敗者已不在」。不准回 ""（`:637-643`）。
  - `_action_subjugate_enemy` 的 `:1634-1635` 那兩行刪掉，判斷只留在 precheck。
- 床格：
  - 勝仗後先收割再收編 ⇒ 成功；
  - 屠村後 ⇒ 不列收編；
  - 勝仗→收割→再打一場獸戰 ⇒ J 不列、戰果摘要不是舊的那場；獸戰後 `_post_combat_summary` 在結果為空時不印空殼（`encounter_view.gd:151-153`）；
  - T2：結算頁開著（前一場待處置未結清）時能不能觸發第二場？可達 ⇒ 加一格證實不丟居民處置（`_abandon_occupation`）；不可達 ⇒ 交件信寫為什麼不可達；
  - 「列為可做的每一項都去按，結果不准是『不行』」。

### D2 攻擊對象排除自家子隊（★6）
- `faction_ai_system.gd:5181-5193` `directive_target_candidates` 加一條排除：用 kinship 謂詞族的現成謂詞（`world_state.gd` `registered_or_parent_at` 旁），不手寫。
- 根因另記 known_issues：子隊只在派出時抄母隊勢力（`subteam_system.gd:158`）。那是世界行為，不在本票。

### D3 同格說過話的隊進情報（★7）
- 同格互動（打聽、求投靠、到場交換）時，對給方寫一筆親見 claim，走現成的 `VisionSystem.write_sighting`（`vision_system.gd:140-144`）。
- 同格親見，合乎感知規則。

### D4 同格親見的時間戳要更新（★8）
- 實作端先在床裡重現「同格、每小時視野、時間戳不動」，找出 `belief_system.gd:410/421/430` 哪個條件沒成立，再修那一個條件。
- 判準：同格停留期間，J 頁「親見」分鐘數 ≤ 60。

### D5 「你看到」去重、不每小時重報（M8）
- 現況：`_known_pos`（`belief_system.gd:305-309`）取第一筆有位置的 claim。前面若有一筆舊轉述，每次親見都會判成「位置變了」。
- ★`:310` 那個 if 同時包住 NPC 的喚醒（`_wake`，`:324-327`；emit 的第四個參數 `:340`），對全部隊執行（N2）。
  - ⇒ 本票選 (a)：**喚醒維持舊基準不動**（`_known_pos` 與 `:310` 原樣），新基準只放在玩家文字路徑。
  - 也就是 `:334` 那一支 `obs_id == 玩家隊` 決定「要不要進玩家事件」時才用。
  - ⇒ NPC 世界不變，world-fp 不應因 D5 變。
  - **怎麼拿掉**（R²c C1，選 (b)）：玩家事件是在 emit（`:340`）裡進佇列的，同一個呼叫也帶 `_wake`。
    - ⇒ emit 加一個參數 `player_visible: bool`。`:310` 成立時照舊呼 emit、`_wake` 照舊算。
    - 只有玩家隊時，`player_visible` 由新基準決定；NPC 恆為 true，沒有玩家事件可進，所以無作用。
    - `player_visible == false` ⇒ 不進玩家事件佇列，其餘（喚醒、Probe）不變。
- 改：
  - 「你看到」是親見事件，進玩家事件的條件＝新位置與**這位觀察者對這個目標最近一筆親見的位置**不同。
    - 新的安靜查詢 `last_firsthand_pos(state, obs_id, tgt_id)`，不抬 Probe 計數，放在 `best_value_quiet`（`:247-249`）旁。
    - 親見判準用同檔 `:336` 的 `source_type == "親見" and source_id == obs_id`，不寫第三種。
    - 不用 `best_claim`／`_pick_best`：它們挑可信度最高的那一筆，基準會在轉述與親見之間來回跳。
  - 沒有前一筆親見 ⇒ 發；位置不同 ⇒ 發；相同 ⇒ 不發。
  - 轉述抵達（source ≠ 觀察者）：玩家事件照舊用舊基準（`:310` 的結果），本票不動。
  - 折句（`world_events.gd:527-542`）按目標去重。
- 床 fixture：
  - 一筆**可信度較高、位置不同**的舊轉述；
  - 加同格不動 24 小時的親見。
  - 判準：「你看到它」≤ 1 則，一句內同隊不重複。
  - n7（改回取第一筆）在這個 fixture 下必紅。

### D6 拔掉「%s 收到了情報」（21）
- `world_events.gd:549` 的 fallback 刪除。
- `intel_arrived` 只在觀察者是玩家隊時進玩家事件。
- grep `收到了情報` 在 `scripts/` 等於 0。

---

## E 畫面殘留（★10 ★13 顯示面 ★14 ★15 ★16 ★18 ★20 22）

### E1 結果行只印這一拍的回應（★10、S6）
- 戰鬥中結果區只印本拍玩家行動的那一句；本拍沒有就印「（這一拍你沒有行動）」，不退回 `_feedback_line`（`text_ui_main.gd:1067`）。
- 改在 `encounter_view.key_reply()`，一處。GUI 與終端 `terminal_block`（`encounter_view.gd:693`「每一鍵的回應只有結果行一個出口」）讀同一支。
- `{uN}` 代換失敗時走 E2 的隊名／人名函式，不准印「?」（`:209-222`）。
- 地圖攻擊回句（`player_command_system.gd:1250-1259`）改成「向 <隊名> 發起攻擊」。

### E2 顯示名（★14 22；M7）
- 唯一表＝`data/text/names.tsv`。檔頭自稱唯一，維持這個主張。
- 加列：
  - 據點類型×等級名：`get_outpost_name(type, level)` 的全部輸出（`outpost_system.gd:3-6`、`:1177`）；
  - 猛獸 deer／boar／bear／wolves（`player_api_mapper.gd:979`）；
  - 品級；
  - 任務名。
- 收掉的重複表，以及它們的**全部讀者**（交件前再 grep 一次補齊）：

| 表 | 讀者 |
|---|---|
| `OUTPOST_NAMES` | `outpost_system.gd:1177` `get_outpost_name`、`player_command_system.gd:1109`、`:1434` |
| `BEAST_LABEL` | `player_api_mapper.gd:1054`、`text_ui_view.gd:202` |
| 情報頁 inline dict | `text_ui_main.gd:2003` |
| `TASK_DISPLAY` | `text_ui_main.gd:1570`、`1828-1838`；`team_ui_helper.gd:40` 確認沒有第二份 |

- 隊名一支 `TextBank.team_name(state, tid)`：猛獸 id（負數）回猛獸名，其他回「Team%d」。
  - 換掉的位置：`world_events.gd:636-644`、`encounter_view.gd:925`、`text_ui_main.gd:1118`／`2809`／`2812`、`player_api_mapper.gd:146`／`257`／`683`。
- 洩漏點逐一改：
  - 物品面板 `text_ui_main.gd:2338`、`team_ui_helper.gd:86`／`148`
  - 存取買賣回句 `player_command_api.gd:263-265`
  - 據點類型 `text_ui_main.gd:3199-3201`、`player_api_mapper.gd:710`
  - 獵 `player_command_system.gd:1019`／`1022`
  - 設施選單 `text_ui_main.gd:3179`
  - 子隊任務 `text_ui_main.gd:3527-3533`
  - 角色欄 `team_ui_helper.gd:170`
- `res_name()` 等查不到時照舊回原字串，但要 `Probe.bump("ui.display_name.miss.<key>")`。
- 床格：
  - 改前改後 `get_outpost_name` 對全部 type×level 輸出逐字相同；
  - 腳本探索床＋E2E 走過的畫面：`ui.display_name.miss` 計數＝0（**斷言**，不是只印）；
  - 走過的畫面 grep `civilian|military|deer|boar|bear|wolves|weapon_|Team-[0-9]`＝0。

### E3 成員面板與 Tick（★15）
- 「總人數」改讀 `population`（`team_data.gd:120-122`），另印「記名 N」。
- 成員面板標題拿掉「Tick:%d」（`team_ui_helper.gd:109`、`text_ui_main.gd:2312`）。
- 鍵列「[G]跳Tick」改成玩家語言，照 G 的實際行為寫。

### E4 鍵列補 R／H（★16；重點 9）
- `MODE_KEYMAP["main"]`（`text_ui_main.gd:1229`）加「[R]武裝比例」「[H]回自己」。`MODE_KEYMAP["member"]`（`:1231`）加「[Y]調薪」。
- 床格**逐鍵驅動**：
  - 主畫面新開 fixture，A–Z 各按一次（每按一次重建 fixture）；
  - 記錄哪些鍵改變了狀態或回了非「無作用」的句子；
  - 那個集合 ⊆ 鍵列裡的字母集合。
  - 母體＝26，印出命中的集合。

### E5 打聽題數（★18）
- `text_ui_main.gd:3885` 與 `:1240` 的「1~5」改成實際選項數 N。

### E6 離開工地要有一句（★20）
- 玩家隊離開自己正在施工的工地格那一拍，發玩家事件：「工地留著：沒人施工就暫停，<N> 天沒動工會取消（退一半材料）」。
  - N 讀 `outpost_system.gd:75-86` 逾時函式的值。
- `check_construction_timeout`（`:980-1023`）取消玩家工地時也發玩家事件。
- tap：`ui.worksite.left`、`ui.worksite.timeout_cancel`。

### E7 糧撐變動要有一句原因（★13 顯示面）
- 每小時比一次 `food_days`（`player_api_mapper.gd:235-237`）。變動超過 2.0 天（TEST VALUE）時發：「糧撐 7.7→4.0 天：存糧 −N、人口 +M」。
- 分子、分母各自的變化都由 snapshot 算。
- 根因歸量測員票三①。
- tap：`ui.food_days.jump`。

---

## 驗收

- 新床 `scripts/debug/tail_fixes_2_bed.gd`，閘列 `tail-fixes-2`，expect `=== tail_fixes_2 DONE === errors: 0`。
- **所有按鍵格都走真路徑**：GUI 用 `_input` 廣播，終端用 `PlayerRepl.press_on`，兩條各按一次。不准直呼 `_global_advance_key` 或 `_handle_key`。

| 格 | 內容 |
|---|---|
| A1 | 進入戰後階段那一幀（結算頁**還開著**），事件區已有結算句 |
| A2 | 結算頁上按 Space ⇒ 回「面板開著」、頁還在、tick 不動、待處置還在；按 L ⇒ 留戰利品（不推進）；按未綁鍵 ⇒ 頁還在；Esc 關頁後推進 ⇒「你沒有處置」；終端 `press_on` 不卡 |
| A3 | 你方六欄有數；正常戰鬥差額＝0，對照仗至少三種：你贏、NPC 贏且有傷兵處置、NPC 贏且有追擊（構造時 `can_pursue` 要為真，`encounter_system.gd:1547-1553`；R²c C3）；三場各印自己非 0 的欄位當母體地板（處置場 `fate_*`>0、追擊場 `pursuit_killed`>0），否則該場不算數；人為移走一名 ⇒「其他離隊 1」；後備連坐 ⇒ 落「後備陣亡」不落「其他」；記名重傷算進傷；對方沒有人口差欄 |
| A3b | 收割回句含資源名與數量 |
| A4 | 超長句：畫面列串起來＝原句全文 |
| A5 | 有傷兵時頂列與生存頁都有數；0 時頂列無此格；窄終端讓位順序 |
| B0 | person 已 erase 的戰死窗口，停點照停 |
| B1 | 轉入重傷那拍停、句子「你重傷」；不重發；存檔重載後不重發 |
| B2 | 戰死 ⇒ 停、「你倒下了」、無「領袖死了」；`_check_player_wiped` 路徑停；絕後後再推 N tick 不重發；死→選繼承人→再死兩次都停；觀察者世界 0 則 |
| B3 | 本隊無記名、子隊有 ⇒ 句子提到子隊；兩邊都無 ⇒ 另一句 |
| C | 八個動作（含結算頁兩個）逐一：按 ⇒ 確認句、非 Y ⇒ 世界不變、Y ⇒ 生效；條件確認的兩個在條件不成立時不確認；帶 confirm 的鍵 ∩ 移動／推進／Y＝空；三個舊旗名 grep＝0 |
| D1 | 收割後收編成功；屠村後不列；勝仗→收割→獸戰 ⇒ 不列、摘要非舊；列為可做的都按得成 |
| D2 | 攻擊對象沒有自家子隊（含玩家獨立時派出、後來建勢力的那種） |
| D3 | 同格求投靠的隊在 J 頁與攻擊對象裡 |
| D4 | 同格 6 小時，親見分鐘數 ≤ 60 |
| D5 | 高可信度舊轉述＋同格 24 小時 ⇒「你看到它」≤ 1；一句不重複；同 fixture 下 `_wake` 次數修前＝修後，NPC 觀察者與玩家隊分開印 |
| D6 | 附庸收到情報 ⇒ 玩家事件區無那句；grep＝0 |
| E1 | 戰鬥中無行動的一拍，GUI 與終端結果區都不是開戰前那句；無「?」 |
| E2 | 據點名逐字相同；走過畫面 miss＝0；grep＝0 |
| E3 | 成員面板總人數＝頂列人口；畫面無「Tick」 |
| E4 | 逐鍵驅動：命中集合 ⊆ 鍵列，母體 26 |
| E5 | 打聽提示 N＝列出題數 |
| E6 | 離開工地有句、N＝逾時函式；逾時取消有句 |
| E7 | 人為讓存糧掉一半 ⇒ 一句、兩項拆分正確 |

- **負對照**（各拿掉一刀，該格要紅）：
  - n1：`settled` 不接 drain ⇒ A1 紅
  - n2：結算頁推進鍵照舊關頁 ⇒ A2 紅
  - n3：拿掉後備陣亡欄（併回人口差）⇒ A3「後備連坐不落其他」紅
  - n4：A4 換回 `clip_to` ⇒ A4 紅
  - n5：停點閘改回只讀 `get_player_team_id` ⇒ B0 紅
  - n6：拿掉 `player_death_announced` ⇒ B2「不重發」紅
  - n7：`_known_pos` 改回第一筆 ⇒ D5 紅
  - n8：D1 拿掉結算開頭的清除 ⇒ D1「獸戰後不列」紅
  - n9：E2 拿掉猛獸分支 ⇒ E2 紅
  - n10：`ConfirmGate.consume` 一律回 true ⇒ C 紅
- **舊床遷移**（交件信逐一列修前／修後，列到鍵層，S1）：
  - `terminal_e2e_bed.gd:216` 等「按任意鍵離開戰後畫面」的步驟 ⇒ 改按 Esc
  - `ui_flow_test.gd` 快照
  - `possessed_famine_stop_bed`
  - `live_play_small_fixes_bed.gd:571-572`、`terminal_selfcheck_bed.gd:149`（故事結束句，R²c C2）
  - `scripted_exploration_bed`（畫面行數變了；探索記錄檔照舊 `git checkout` 還原）
  - 動到 `_outpost_pending_abandon`／`_faction_extract_pending`／`_rest_confirm_armed` 的床
- world-fp：D1 的清除點、B1／B2 新欄、D5 的新基準都只在玩家世界作用（D5 依 N2 選 (a)）。fp 若變，歸因到第一個分歧 tick，不直接換值。
- 全量電池：跑前先問 QA、量測員有沒有 Godot 在跑。
- 驗收後 QA 真玩複驗：同一 seed 第一局那場仗，加第二局第二場勝仗。

## 誠實限
- A3「其他離隊」只保證差額不消失，不保證說得出原因（等票三④）。
- 對方欄只有親見部分；QA 看到的「對方 6→3」若出自某個 god-view 顯示點，不在這張修。
- B2 不印死因：今天沒有資料來源。
- B3 只改句子；子隊繼承等藍圖。
- E7 只拆分子分母，不知存糧為何變（等票三①）。
- E2 的 grep 與 miss 計數只看得到床走過的畫面。
