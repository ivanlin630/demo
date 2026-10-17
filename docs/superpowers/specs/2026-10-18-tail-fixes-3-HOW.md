# 批尾小修三（第五輪第二局 QA）— HOW（第一版，送 R²）

- WHAT：藍圖票 `docs/superpowers/handbacks/2026-10-18-blueprint-to-systems-TICKET-tail-fixes-3-start-menu-defection-wording-settlement-accounts-everyone.md`；藍圖補充（2026-10-18 敲門）：「接掌既有勢力」＝附身到該勢力原本的領袖隊、取代隊長；選單只列三種（獨立／接掌既有勢力／加入既有勢力），「自己開新勢力」＝獨立開局後用既有「立國」動詞。
- 來源表：`docs/playtest/2026-10-18-round5-qa-live-play-2.md` §二 ★N1–N15。
- 排序：跳窗報價之後、全員在場之前（不動小修二）。file:line 在 main `0699350dd` 上讀；**小修二合併後動工前重對**（小修二動 E1 結果行、E2 名稱表、E8 情報來源、D6「收到了情報」）。
- ③ 的前提已量（量測員 2026-10-18 DONE，§三）。
- 共同規則：每一組只准一個產生者；新事件、新停點接 tap。

---

## 一、開局選單（★N1、★N2）

### 1a 現況
- 開局寫死在 `config/default.json`（`text_ui_main.gd:183-184`）；`join_mode` 三值（`game_setup.gd:494-532`）。
- `new_faction`：`_find_weakest_faction`（`:534-546`）只讀 config 的 `factions.weights`；預設 config 沒有這欄，生成時算的 weights 是區域變數（`:286-290`）⇒ 恆 -1 ⇒ 悄悄退回獨立（只有 `push_warning`）。
- 就算走得通，它也是**另生一支新隊**站到舊領袖隊旁、改 `leader_team_id`（`:497-512`）：據點仍歸舊領袖隊（`:418-420`）、新隊信念全空（`create_team` 只給空 `team_known`，`world_state.gd:909-912`）⇒ ★N2 全部症狀（情報 0、附近無已知據點、支配權否、公庫要站自家據點、家：無、自家成員關係不明）。

### 1b 拆開局成兩步
- `GameSetup.setup(state, config)` 拆成 `setup_world(state, config) -> rng`（`:39-67` 裡 `_setup_random_player` 之前的全部）與 `setup_player_and_finish(state, config, rng, start_choice)`（`_setup_random_player` 起到結尾）。原 `setup()` 保留為兩者連呼的包裝，headless／床／world-fp 照舊呼它 ⇒ RNG 消耗順序不變、world-fp 不變（閘驗）。
- `explicit` 模式不動。

### 1c 選單
- `text_ui_main._ready`：`setup_world` 之後、`setup_player_and_finish` 之前顯示選單（一個新的 mode，鍵 1／2／3，Esc 不可略過，Enter 確認）：
  1. 獨立遊團（＝今天的 `independent`）
  2. 接掌既有勢力：列出世界上的勢力（勢力名、成員隊數、總人口），選一個 ⇒ 附身它的領袖隊（1d）
  3. 加入既有勢力：同一張列表，選一個 ⇒ 新隊出生在該勢力領袖附近、入勢力（今天的 `join:N`）
- 這是開局元資訊（玩家在選角色），不是遊戲中的感知 ⇒ 列人數不違感知鐵律。
- 世界沒有任何勢力 ⇒ 2、3 灰掉，旁邊一句「這個世界沒有勢力」。不准悄悄退回：任何一種選了做不成 ⇒ 回選單並說原因。
- 終端（`tools/live` driver／`player_repl`）走同一個 mode：開局第一畫面就是選單。REPL 腳本與床可用 `--start=independent|lead:<fid>|join:<fid>` 參數略過選單（預設 `independent`，舊床不變）。

### 1d 接掌＝附身領袖隊
- 不生新隊。`state.player_id = 舊領袖隊.leader_id`（附身＝繼承記憶 C1：那個人的隊的信念、據點、成員全帶著）；`state.sync_possession()`。
  - 不另生玩家角色、不套 config 的 `leader_name`／`starting_named_count`／`population`（人數、物資照該隊現況）。開局句寫「你接掌了勢力3（Team12，N 人，據點 K 座）」。
- 「原隊長降記名」：附身的是原隊長本人（玩家接手他）。藍圖原話「原隊長降記名成員」——因為玩家就是那個人，沒有第二個人要降；交件信寫一句，若藍圖指的是另一種（玩家另有一個人取代原隊長），回報不擴。
- ⇒ ★N2 那幾個顯示讀的東西（`own_outpost_tile`、`known_outposts`、`known_reputations`、`team_intel`）全部天然有值。
- 被附身的隊照不變量 12：決策層不再寫它；勢力層「盟主是附身隊的勢力」那段規則自然生效（`docs/invariants.md:71`）。

### 1e 加入既有勢力的新隊要知道自家
- `join` 路新隊入勢力時（`set_team_faction(..., JOIN_SETUP)` 之後），從勢力的現成共享資訊讀一次：`FactionData.known_member_states`（`world_state.gd:1263-1281` 寫的成員快照：位置、人口）⇒ 寫進新隊的 `team_known`／位置 belief（來源「隊友」）；勢力成員據點寫進 `known_outposts`。不讀真值、不讀非成員。
- 寫入走既有 belief 入口（`BeliefSystem.record_claim`），不另開欄位。

### 1f 「勢力關係：尚無」
- `player_query_api.gd:125` 寫死 `"faction_relations": []`。勢力之間的關係今天沒有資料（`FactionData.relations` 全站無讀者）⇒ 改成列「自家勢力成員」（隊名、對他的 `known_reputations`），標題改「勢力成員」；勢力之間那欄印「勢力之間的關係還沒做」，不印「尚無」（尚無像是查過了是空的）。

### 1g `_find_weakest_faction`
- 不再被開局用（選單讓玩家選）；保留給 config 路（`join_mode: new_faction`，headless 舊床可能用）時改讀 state：成員隊總人口最小的勢力。找不到 ⇒ `push_error`＋回 -1，呼叫端照舊退回獨立但**同時**在開局事件寫一句「找不到可接掌的勢力，改為獨立開局」（不再只有 warning）。

## 二、改投視窗說真做的事（★N6、★N7、★N5）

### 2a 句子（★N6）
- `plan_alliance`（`diplomatic_ai_system.gd:452-470`）回 `move` 且被搬的那隊原本有勢力 ⇒ 這是「它脫離勢力 X、加入你的勢力 Y」，不是結盟。
- 單一產生者：`PlayerCommandSystem.alliance_preview`（`player_command_system.gd:1172-1190`）與 `alliance_sentence`（`:1193-1208`）各改那一支：
  - 預告：「接受＝Team13 脫離勢力3、加入你的勢力0」
  - 結果：「Team13 脫離勢力3、加入你的勢力0」
- 視窗標題（`player_api_mapper.gd:397` `proposal_phrase("alliance")`＝「提議與你結盟」）：同一個 plan 是 `move` 且對方原有勢力 ⇒ 標題「想脫離勢力3、加入你的勢力0」。標題讀 `alliance_preview` 同一次 plan 的結果，不另判。
- 行為不改（挖角裁定）；領袖隊那條「兩勢力之間的結盟還沒做」照舊。

### 2b 離開勢力一律有事件（★N7、★N6 的「勢力3 少了一隊」）
- 唯一寫入口 `set_team_faction`（`world_state.gd:590-613`）的副作用鉤子 `_on_faction_changed`（`:640-658`）加一件：舊勢力 ≠ -1 且新 ≠ 舊 ⇒ `WorldEvents.emit("faction_member_left", …)`，info 帶 `{team, from_faction, to_faction, reason}`。
  - 只在玩家看得到時進玩家事件流：舊或新勢力是玩家的勢力、或那隊是玩家方。其他一律只進 tap（觀察者世界不洗版）。
  - reason 代碼（`LEAVE_*`／`JOIN_*`，`world_state.gd` 那組常數）→ 人話放 names.tsv（小修二 E2 那張）；表裡沒有 ⇒ unmapped tap，床斷言走過的世界 0。
  - 句子：「Team2 離開了勢力0（<原因>）」／「Team13 脫離勢力3、加入勢力0」。
- 一處鉤子蓋住全部呼叫者（子工作清點：`faction_ai_system.gd:8162/8169/8271/8274/8278`、`player_command_system.gd:1654/1674`、`world_state.gd:525`、`event_faction_defect.gd:45`、`diplomatic_ai_system.gd:503/506/519`、`npc_combat_system.gd:877`、`interaction_system.gd:1761/1790`）。已經自己發事件的兩處（`event_faction_defect.gd:48`、`diplomatic_ai_system.gd:592`）⇒ 改成不再自己發（避免兩句），由鉤子發；交件信列修前修後句子。
- 新隊（`team` 剛建、舊勢力 -1）不發。
- ★N7 的實際路徑（量測員）：t=6179 `DiplomaticAiSystem._execute_betrayal`（`diplomatic_ai_system.gd:592`，reason=betrayal），同一 tick Team1、Team2、Team13 三隊一起叛、受害方都是玩家隊。碼上已有 `WorldEvents.emit("betrayed")` 與 `player_alerts`「勢力成員叛離」（`:595-613`、`text_ui_main.gd:3993`），**但整局畫面一句都沒出現**。
  - 實作端先查為什麼沒到畫面（候選：`betrayed` 沒進玩家可見表、警示列 `_alert_bar` 在終端畫面不出現、被事件區擠掉），交件信寫原因；修法照本節：鉤子是唯一產生者（原因「背叛」），`_execute_betrayal` 自己那句 emit 拿掉；`player_alerts` 那一筆保留（它是警示列，不是事件流），但要確認終端與 GUI 都看得到。
  - 驗收加：同 tick 三隊背叛 ⇒ 三句（或合併一句列三隊），玩家畫面可見。
- ★N7 後半「敵視的隊主動要進貢」是決策行為，不在本票（交藍圖，記 known_issues）。

### 2c ★N5：灰掉理由與事實相反
- 閘＝`player_command_system.gd:148-151` `TeamData.same_faction(tgt, pt)`（讀即時 `faction_id`）；面板讀 `member_team_ids`（同一入口同步）。靜態讀不出為什麼兩者不一致。
- 實作端先用 QA 鍵序重現，dump 那一拍 Team35 的 `faction_id`、`parent_team_id`、面板列與閘讀到的隊號；找到原因後修那一處，交件信寫原因。重現不出來 ⇒ 回報，不猜修。

## 三、結算交代全部人（★N4）

- 量測員回放第二局（`docs/superpowers/handbacks/2026-10-18-measurer-to-systems-DONE-game2-population-accounts-and-silent-faction-leave.md`）：人口 10→2 掉的 8 人**全是戰死**，沒有俘虜、逃散、轉隊：記名 1＋上場匿名 1（結算句只交代這 2）＋**後備連坐匿名 6**（`_apply_reserve_casualty`，`encounter_system.gd:1185-1197`，沒進結算句）。
- ⇒ 這一局的缺口正好是小修二 A3 的「後備陣亡」欄（你方六欄＋對帳、差額印「其他離隊」＋`combat.pop_unreconciled`）；全員在場那張再把後備連坐整條刪掉（場外的人不連坐）。本票**不另寫一套帳**：
  - 小修二合併後，用第二局鍵序回放那一場：結算句必須寫「死 2（記名：何仁）、後備陣亡 6」，六欄加總＝人口差 8，「其他離隊」＝0、`combat.pop_unreconciled`＝0。
  - 記名的人一律寫名字（WHAT：記名寫名字）；A3 若只在「死」那欄寫名字，被俘、被對方處置的記名也要寫名字——交件信列 A3 實際哪幾欄有名字，缺的在本票補。
  - 三種母體各一場（同小修二 C3 的構造）：你贏、NPC 贏且有傷兵處置、NPC 贏且有追擊；每場六欄加總＝人口差，「其他離隊」＝0。這是「一個人都不能憑空消失」的驗收面。
- 量測只有一局一筆；本票驗收的三場構造負責母體，回放那一場負責「QA 那一局真的對上」。
- 對方那一側：只交代親見的部分（感知鐵律，同小修二 A3），不做對帳。

## 四、結算不被洗掉（第一局 21、本局再證）

- 主因「TeamN 收到了情報」每小時 5–8 則：小修二 D6 已刪那個 fallback 句、`intel_arrived` 只對玩家隊進事件流。本票先驗 D6 之後還會不會擠：用第二局鍵序回放，勝仗結算那一幀起 2 小時內，結算句是否始終在事件區可見範圍。
- 加一道保證（不靠「別的句子剛好少」）：**結算句釘住**。事件區的產生者（`text_ui_main` 事件區那一支）在可見列頂留一格「置頂」：最近一則 `aftermath_settled`（小修二 A1 的結算句）佔住，直到 ①它出現後遊戲時間過了 1 小時（TEST VALUE）且 ②玩家這段時間按過至少一個鍵。之後回到一般捲動。
- 「找上門」是強制事件視窗（推進會停），不會被事件區擠掉；它的結果句（`forced_event_resolved`）同樣進置頂規則。
- tap：`ui.event_pin.set`、`ui.event_pin.released`。

## 五、一籃 UI 洞

| # | 現況（file:line） | 改法 |
|---|---|---|
| ★N2 | 見 §一 | 1d／1e／1f 根治 |
| ★N8 | 目標列只在 `visible_teams`（只掃 `team_discovered`，`player_api_mapper.gd:241-266`）找到時才印位置人數，否則只印「Team%d」（`text_ui_main.gd:2798-2813`） | 找不到時改讀那支隊的 belief（`best_estimate` 的位置與人口估計，同 J 頁那一支）；連 belief 都沒有 ⇒ 印「（位置不明）」，不印空 |
| ★N9 | 目標列人口是 belief 估計（`player_api_mapper.gd:253-261`），納貢灰掉理由讀真值（`player_command_system.gd:153-157`）——灰掉理由在洩真值 | 灰掉理由改讀同一個 belief 估計（感知鐵律）；判定本身若也讀真值，一併改讀 belief，交件信寫有沒有改到判定 |
| ★N10 | 兩條路：①`source` 取 last_tick 最大那筆、`firsthand` 取 best claim（`player_query_api.gd:76-98`）——小修二 E8 改成都從 best claim 取，已修；②`record_claim` 依 `source_id` 合併、不覆寫 `source_type`（`belief_system.gd:422-430`）⇒ 一筆非親見、`source_id == 自己` 的 claim 之後親見也翻不過來 | ②：合併時若新寫入是親見，`source_type` 改成「親見」（只升不降）。動的是 belief 寫入，NPC 也走 ⇒ world-fp 可能變；變了歸因到第一個分歧 tick，確認是這一行後換值 |
| ★N11 | 戰中投降被拒：拒絕在世界 tick 裡結算、只進事件流；結果行（`encounter_view.key_reply` `:256-275`）撈到同拍的「@（你） 待機」並冠「✓」 | 投降（及其他會在 tick 內被拒的戰中指令）的拒絕句回到結果行：`surrender_in_encounter` 的結算回傳寫進 `_reply`；結果行冠號依結果（✓／✗），不寫死 ✓。小修二 E1 之後的同一支 `key_reply` 改 |
| ★N12 | ①成交句沒 info（`player_trade_system.gd:189-190`），主詞走 `_team_name` 恆「Team%d」（`world_events.gd:424-425,636-644`）；②「野心變了」沒帶新舊（`ambition_ladder.gd:147,162`）；③估值 0 是對方存量超過目標兩倍時的真值（`trade_valuation.gd:271-302`）；④提示印原始鍵（`text_ui_main.gd:3762`、`:3322`） | ①成交帶 `{gave, got}`，句子「你跟 Team7 換了：付 30 金、得 糧食×20」，玩家隊主詞「你」（`_team_name` 認玩家隊回「你」，或小修二 E2 的 `TextBank.team_name` 那支加這條）；②`rung_changed` 帶新舊階，句子「Team25 的野心：<舊>→<新>」，玩家隊用「你」；③值 0 印「（對方不缺）」，不印 0.0；④兩處改 `TextBank.res_name()` |
| ★N13 | 戰場單位標籤 `"P%d"`（`encounter_view.gd:313-320`、`:890`；`encounter_system.gd:812-814`） | 我方記名印名字（`PersonData.person_name`）；對方記名印「敵·記名」＋字母（名字是玩家不知道的，除非之前見過——今天沒有「認得某人」的資料，不做）；匿名照舊。三處改同一支 `_unit_name` |
| ★N14 | 武裝數＝記名全部＋round(匿名×比例)（`player_api_mapper.gd:229-232`），記名不看有沒有武器；比例只算匿名（`equipment_system.gd:62-77`） | 「武裝」改成「有武器的人數」＝手上真的有武器的記名＋匿名武裝數；比例＝武裝人數 ÷ 人口；回句與生存頁同一支。全員在場那張要把匿名部分換成 `anon_armed_count`——本票先寫一支 `armed_breakdown(state, team) -> {named, anon, total}`，全員在場沿用它（已寫進那張的派件信提醒） |
| ★N15 | 地圖一格一字，隊伍字母蓋過據點 ^（`text_map_renderer.gd:141-152`） | 一格一字不變。地圖下方加一行「據點上有隊伍：(10,13) A、(10,11) b」（只列玩家已知的據點；產生者一支，在 renderer 旁），有隊站著的已知據點都列 |
| ★N3、★N11 等同第一局族 | — | ★N3 的「攻擊只能打獨立隊」是設計（藍圖），本票只讓灰掉理由說清楚：「攻擊目標只能選不屬於任何勢力的隊」 |

---

## 驗收

- 新床 `scripts/debug/tail_fixes_3_bed.gd`，閘列 `tail-fixes-3`，expect `=== tail_fixes_3 DONE === errors: 0`。真鍵路徑。

| 格 | 斷言 |
|---|---|
| T1 | 選單：三項都列；無勢力世界 2／3 灰掉並有原因；選 1 ＝獨立開局 |
| T2 | 選 2 接掌勢力 X ⇒ `player_id`＝X 領袖隊的隊長、那支隊 `possessed`、不新增隊；頂列「家」有值、情報頁已知對象 >0、站在自家據點上「附近已知據點」有、支配權是、公庫可用、自家成員關係有數字 |
| T3 | 選 3 加入勢力 X ⇒ 新隊 `faction_id`＝X、`team_known` 含 X 的成員、`known_outposts` 含成員據點；來源是「隊友」 |
| T4 | config 路 `new_faction` 無 weights ⇒ 照 state 選最小勢力（不再 -1）；真的沒勢力 ⇒ 開局事件那一句 |
| T5 | 同 seed：`setup()` 包裝與「`setup_world`＋選 1」的世界逐字相同；world-fp 閘綠 |
| T6 | 別勢力成員隊提結盟 ⇒ 標題與預告寫「脫離勢力3、加入你的勢力0」；接受 ⇒ 結果句同；領袖隊提 ⇒ 照舊「兩勢力之間的結盟還沒做」 |
| T7 | 勢力成員因叛離／起義／投降／被挖角離開玩家勢力 ⇒ 玩家事件一句帶原因；觀察者世界（無玩家）同事件只進 tap、事件流 0；原本自發事件的兩處不重複 |
| T8 | ★N5 依實作端找到的原因寫的格（交件信定） |
| T9 | 結算置頂：勝仗後連續 2 小時每小時塞 8 則其他事件 ⇒ 結算句始終可見；過 1 小時且按過鍵 ⇒ 釋放 |
| T10 | 第二局鍵序回放（小修二之後）：勝仗結算那一幀起 2 小時內結算句可見；敗仗那一場結算寫「死 2、後備陣亡 6」、其他離隊 0；第 5 天三隊背叛在畫面上可見 |
| T12 | 三種母體各一場（你贏／NPC 贏有傷兵處置／NPC 贏有追擊）：六欄加總＝人口差、其他離隊＝0；記名寫名字 |
| T11 | ★N8／N9／N10／N11／N12／N13／N14／N15 各一格（各照上表改法斷言；N10 ②用「先轉述後親見」構造） |

- 負對照：n1 選 2 改回「另生新隊」⇒ T2 紅；n2 拿掉 1e ⇒ T3 紅；n3 鉤子不發 ⇒ T7 紅；n4 置頂拿掉 ⇒ T9 紅；n5 N9 灰掉理由改回真值 ⇒ T11 的 N9 格紅；n6 N10 合併不升親見 ⇒ T11 的 N10 格紅。
- 舊床遷移：開局參數（REPL／driver 預設 `independent`，舊床不變）；改投句子相關的外交床；`faction_relations` 讀者。交件信逐一列。
- world-fp：§一拆 setup 預期不變（T5）；§五 N10 ②可能變——歸因後換值，不直接換。
- 驗收後 QA 真玩：三種開局各玩一段，第二局 ★N 清單逐條複驗。

## 誠實限

- 勢力之間的關係今天沒有資料，「勢力關係」只能改列自家成員。
- 對方記名的名字不顯示（今天沒有「認得某人」的資料）。
- ★N7 後半（敵視的隊主動進貢）與 ★N6 的「剛打贏我的隊關係普通」是行為面，不在本票；記 known_issues 交藍圖。
