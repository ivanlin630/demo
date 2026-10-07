# 第五輪邀請前的友善度收斂（四條；收斂不是新功能）（HOW）

```
票源 ＝ 藍圖第四輪收場 `b76807546`（用戶總評「這 UI 對我很不友好」＝第五輪驗收句）
序 ＝ 本輪所有票之後、觀察輪重跑之前｜藍圖第五輪真跑時逐條看，缺一不邀
```

```
F1【開場三行】主畫面最上方（或首屏）三行「你現在能做的」：從**當下可做的動作**（enabled）挑出最相關的三個（推進鍵＋兩個可做動作），每行一鍵一句
   ⇒ 來源＝動作清單同一份資料（不另寫一份「建議」邏輯）；排序規則一行寫明（例：有強制事件 ⇒ 回應排第一；否則可做動作依清單序）
F2【能做的排前、不可的折疊】動作清單：enabled 在前；不可的收成一行「另有 N 個暫時不能做（按 ? 展開看原因）」
   ⇒ 鍵號不因折疊而漂移（不變量 #10：鍵＝靜態 id，不靠位置）；展開後每個不可的仍帶引擎原因（承上一張票 ②）
F3【拒絕句帶主詞與下一步】每個被拒／不可的句子＝「誰／什麼不行：原因；可以先做 X」
   ⇒ 「下一步」由引擎給（disabled_reason 旁加一個 hint 欄位：能解除這個條件的動作 id），排版層禁自寫
   ⇒ 先盤點：今天有幾個 disabled_reason，各自能不能指出一個解除動作（印清單；指不出的寫「—」不硬湊）
   ★R² 打回：盤點要照**語意**找（所有印在玩家面上的「不可／為什麼不可」句），不照欄位名 —— 第三種產生者 `precheck_*` 系列 12 支
     （`player_command_system.gd:515-615`）欄位叫 "reason" 不叫 "disabled_reason"，而用戶最早抱怨的「紮營（離據點太近）」就在這裡
     ⇒ 盤點母體＝disabled_reason 產生者＋precheck_* 的 reason＋inquiry 的 DISABLED_REASON；三者在區塊資料層統一成同一欄（F6）
F4【鍵列只印當下有效的鍵】頁腳鍵列依當下模式與狀態過濾（面板開著只印面板鍵＋全域鍵；戰鬥中只印戰鬥鍵）
   ⇒ 來源＝各模式的鍵處理表（同一份），不另抄字串
E2E 加四格：F1 首屏三行存在且每個鍵按下有效｜F2 enabled 全排在不可之前、折疊行數正確、展開後原因齊｜F3 每個拒絕句含主詞與（有則）下一步｜F4 鍵列每個鍵在當下按下都不是「此鍵無作用」
```

## F5 play.py 單鍵即時輸入（藍圖 `4fa3388c2`，用戶：「什麼都要打字，連 Esc 都要打 e-s-c 加 Enter」；與 F1–F4 同批）

```
現況：`tools/play.py:216` main 迴圈 `input("> ")` 逐行讀 ⇒ 按一個鍵要打字＋Enter
⇒ stdin 是 tty（且 Windows）：用 `msvcrt.getwch()` 讀原始按鍵，**按一鍵送一個 token**，不打字不按 Enter
   對照（一支純函式 `key_token(chars) -> str`，放 play.py）：
     一般可印字元 ⇒ 該字元｜\x1b ⇒ esc｜\r ⇒ enter｜\t ⇒ tab｜空白 ⇒ space｜\x08 ⇒ backspace
     方向鍵（\xe0 或 \x00 前綴＋H/P/K/M）⇒ up／down／left／right｜Ctrl+C（\x03）⇒ 離開 ——★走既有離開路（送 QUIT_TOKEN \":quit\"，同 q 那支），不另開一條
   ★token 名稱＝`player_repl.gd:51 NAMED_KEYS` 的鍵名（同一份；play.py 不另發明名字）
   ★q 照舊＝離開 harness（現行語意不變）
⇒ stdin **不是** tty（管道、床、藍圖餵鍵）⇒ 自動退回逐行模式（現行行為逐字不變）
⇒ 每次收到新畫面先清屏再印（ANSI 清屏），畫面不往上捲
⇒ G「跳 N tick」要先按 G 再按數字再 Enter：單鍵模式下照樣是一鍵一 token，不需特例
P5a `python tools/play.py --selfcheck`（不起 Godot）：key_token 對照表逐項斷言（含方向鍵兩種前綴、Ctrl+C）
P5b 既有 play-selfcheck（管道）照綠＝逐行模式沒壞
P5d ★人工驗證（讀碼答不出、R² 不能放行）：在 VS Code 整合終端與 Windows Terminal 各實按一次（x、Esc、Tab、方向鍵、Ctrl+C），確認是單鍵模式、不是退回逐行
    ⇒ 交件信貼兩個終端的實按結果；任一環境判不成 tty ⇒ 回報（可能要加 --raw 強制旗）
P5c 藍圖第五輪真跑前，用戶面的操作說明（README「開六個角色終端」旁或 play.py 開場一行）寫「直接按鍵，不用 Enter」
```

## F6 資料／排版拆刀（藍圖 `035f68b09`：GUI 延後，但這一刀跟 F1–F5 同批現在做）

```
今天：text_ui_main 把三個資料口（快照／動作清單／事件流）直接排成字串區塊，再交 `TextUiView.compose` 拼屏
⇒ 拆成兩步：
  ①資料 → **區塊資料**（Dictionary／Array：頂列欄位、動作清單〔id／label／enabled／reason／hint／組別〕、事件列〔tick／句〕、結果行、鍵列〔當下有效鍵〕、戰鬥區六欄＋單位表）
     ——一支函式產生，放 text_ui_main（或新檔 ui_model.gd），**終端與將來的 GUI 都只吃它**
  ②區塊資料 → 字串（終端專用，TextUiView 既有那些排版函式改吃區塊資料）
⇒ 床：E2E 與終端自驗改對**區塊資料**斷言（動作清單、原因、結果句、事件序）；字串層另留四缺陷那組（英文識別字、佔位句、欄寬、截字）
⇒ F1–F4 的規則（首屏三行、能做排前不可折疊、拒絕句主詞＋下一步、鍵列依模式）**寫在第①步**（區塊資料就已經是排好序、折好疊的），排版層只負責畫
⇒ ★動作清單的組別欄依藍圖已定的 GUI 四組（時間／移動／對選中目標／自家隊），終端照同一順序排，將來 GUI 不必再排一次
P6 一格：同一個世界狀態，區塊資料 → 字串 的輸出與拆刀前的畫面逐字相同（除 F1–F4 刻意改的地方，差異逐行印出）
```

## F7 游標處明細一行（藍圖 `07d5c599a`，排進友善度批）

```
主畫面加一行「游標處」，跟游標即時更新，內容**只用附身者知道的**（belief／親見）：
  地形｜已知據點與擁有者（belief）｜看得到／記得的隊伍（含最後所知時間）｜距最近**已知**據點幾格｜此格可否紮營＋引擎原因
⇒ 資料來源：快照與 belief 查詢（走區塊資料層，F6）；可否紮營＝`precheck_camp` 同一支（列的條件＝做的條件）
⇒ debug pane（TEXTUI_DEBUG_PANE=1）印真值那支照舊，不混進這一行
⇒ 間距規則已整條退場（用戶裁，藍圖 `e1a09f429`；見 F8）⇒ 擋紮營的只剩「同格已有據點／營地」，那一格就是腳下、玩家看得見 ⇒ 原因句不涉及看不見的據點
P7 游標移到三種格各一次（已知據點格／自己營地格／空地）⇒ 明細內容正確
```

F7b【「選中」區塊同一條規則】（量測員旁證 afaf2bea1 → systems 追到）：text_ui_main.gd:1553-1560 選中格印 `query_tile`（sim_bridge.gd:189 直讀 state.world.tiles）的
   農產比例與糧量 ⇒ 選一個從沒去過的遠格也印得出它的糧 ＝ 顯示邊界 god-view
   ⇒ 選中區塊與游標處那行同源（走 F6 區塊資料層、只讀附身者知識）：視野內 ⇒ 真值；記得的格 ⇒ 地形＋「糧量：未記錄」（★不印「上次見到時」：普通格的記憶只是 bool、沒有時戳，同 #9 §7 HOW補二；R² 9440615ac）；沒去過 ⇒ 「沒去過」
   ★debug pane（:1494 `_build_hover_truth_lines`）照舊讀 query_tile，那是合法的真值區
P7c 選一個沒去過的遠格 ⇒ 選中區塊不得出現糧量數字｜反向：走過去看見 ⇒ 出現

（紮營被擋寫弱 belief「附近有據點」那條：間距退場後不會再有「被看不見的據點擋住」⇒ 作廢）

## F8 玩家紮營＝L0、紮根＝第二步；間距與山地禁令整條退場、只留物理（藍圖裁 (i) `7d10ddb4a`＋用戶裁 `e1a09f429`；同批）

```
前提（git grep）：
  間距規則 production 出現處＝3：outpost_system.gd:571 start_build→_check_distance（:932-952，MIN_DIST_ANY 2／MIN_DIST_SAME 11，:228-229）
    ｜player_command_system.gd:592 precheck_camp→_check_distance｜★faction_ai_system.gd:5960-5964 NPC 建點選址 `min_dist = 1 if 礦山 else 2`（第三處，不叫 distance 的那一處）
  山地禁紮出現處＝2：player_command_system.gd:590 precheck_camp｜faction_ai_system.gd:6939 establish_crude_camp
  玩家「紮營」今天＝crude_camp 工程，完工即 L1（outpost_system.gd:472-492）＝一鍵直達 L1
  「同格已有據點」今天四個寫入點各自已查（start_build :564／establish :6937／precheck_camp :588／NPC 紮根 :7137）

①退場（刪，不留空殼）：MIN_DIST_ANY／MIN_DIST_SAME 兩常數、_check_distance 整支、start_build 與 precheck_camp 那兩行呼叫、
   faction_ai:5960 的 min_dist（候選格本來就 `outpost_level > 0 ⇒ continue`，同格已排除 ⇒ min_dist 改成無；max_dist 是搜尋半徑不是間距，留）、
   兩處山地禁紮；礦村豁免（outpost_system.gd:936-941、faction_ai:5957-5960 的 is_ore_mountain 對 min_dist 那半）隨之消失
   ★不新增 _distance_blockers：同格檢查四處已在，再包一支只會變成第二份
   qa_probe.gd／ui_flow_test.gd:208／★註解例句 player_command_system.gd:500,506,773、player_query_api.gd:360（R² ed7b0c0be）引用 _check_distance 的一起改（P8f grep 會算到它們）
   player_command_system.gd:1041 原因句「資源不足或距離限制」⇒ 去掉「或距離限制」
②兩步結構（保留）：
   玩家紮營：_action_camp 改呼 establish_crude_camp（同一支，不准第二份 L0 寫法）；precheck_camp 加「此地已有營地」（camp_level>0）
   玩家紮根：新動作「紮根」——只在【自己的 L0 營地】上列出（camp_level==1 且 camp_team_id==玩家隊）；
            執行＝把 NPC 紮根落地那段（faction_ai:7140-7161）抽成一支共用函式，玩家與 NPC 同呼；type 參數化（NPC 照 leader 價值、玩家照 build_type）
            precheck_settle：另查 tile.construction_team_id == -1（施工中 camp_level 仍是 1 ⇒ 不查就能重按把工期重置）；不可時「紮根施工中（剩 N 人時）」
③成本：玩家紮根＝NPC 紮根今天的成本：settle 工期、免材料（藍圖定：成本就是時間）
   ★藍圖信寫「山地可（工期按地形）」——今天工期【不】看地形（build_person_hours 只吃 kind／level；TERRAIN_BUILD_BONUS 只進 NPC 選址分數）
   ⇒ 本票不加；山地的代價今天只有野糧少、走得慢（已回藍圖）
④營地欄（藍圖裁（乙）`68cd9883d`：§6「營地不是家」保留）：家欄與 _home_tile 一行不動
   mapper 新增 camp_pos／camp_distance（同一支 state.own_camp_tile(玩家隊) 取值，兩欄同給或同 null）
   頂列「營地：(x,y) 離 N」；null ⇒「營地：無」——「無」只在那一欄有寫入者時印（缺席 ⇒「營地：？」）
⑤動作鍵：紮根是新 action id（不變量 #10）；不讓「紮營」在自己營地上變成紮根
```
```
P8a 緊鄰既有村的平地 ⇒ 紮營可｜山地 ⇒ 紮營可｜同格已有據點或營地 ⇒ 不可，原因照實
P8b 緊鄰同類據點處先紮營、再紮根 ⇒ 可（工期＝settle）
P8c NPC：establish_crude_camp 在緊鄰村的格與山地 ⇒ true｜NPC 選址候選含距中心 1 格的格（修前被 min_dist 排除）
P8d 紮營後營地欄＝座標、家欄不變；紮根完工 ⇒ 家欄＝那座據點、營地欄＝無｜反向：快照拿掉 camp_pos 鍵 ⇒ 印「？」不印「無」
P8e 站在自己營地上 ⇒ 動作清單有「紮根」；別人營地／空地 ⇒ 沒有｜紮根施工中再按 ⇒ 不可、工期不變
P8f grep：MIN_DIST_／_check_distance／「山地無法紮營」在 scripts/ 出現次數＝0｜crude_camp 工程設點只准一處（共用函式）
P8g world-fp 會變 ⇒ 先量、換基準同 commit；回報 30 天 seed 1337 改前改後：camp.built／settlement.l0_to_l1_start／山地立營數／據點兩兩最近距離分佈
    ★報告逐字印一行 `mountain_camp_survived_days: <山地營地存活最大天數>`（defer mountain-build-time-by-terrain 的 met_check 讀它；落在 docs/measurements/）
```

## F9′ NPC 選址讀【已知】敵友據點（用戶裁 (C)，藍圖 `c2ed35c05`；與 F8 同批 merge，不等覓食範圍物理）

```
前提（逐字）：faction_ai_system.gd:6047 _enemy_outpost_positions 已讀 BeliefSystem.known_outposts（親見才有、owner＝最後所見）✓
  但「敵」＝「非自家且不在我勢力名冊」⇒ 陌生人一律當敵；:5978-5981 `if min_enemy_dist < 5: score -= (5 - d) * 10`
  ⇒ 只看【最近一座】、只有扣分、不分敵友
改：
①_enemy_outpost_positions 改名改形 ⇒ _known_outpost_relations(state, leader_team) -> Array：每筆 {tile_pos, owner_id, g}
   g（關係，[-1, 1]）：
     owner 在我勢力名冊（自知，合法）⇒ +1
     否則 ⇒ clampf(grat − feud, -1, 1)；grat／feud ＝ DiplomaticAiSystem._edge_intensity_to(我隊 leader.relation_edges, "gratitude"/"feud", owner 隊 leader_id)（同外交那支，不另寫）
     沒有邊 ⇒ 0（中立；★今天陌生人被當敵 ⇒ 改後陌生人不再被避開——這是裁定要的行為變化，不是回歸）
   自家據點不進本表（既有 centers／離家近那兩項保留）
②分數項（★R² 打回 62d736fa7：Σ 每一座會隨密度線性長，3–4 座就 300–400 分、蓋過 productivity／地形／資源 ⇒ 不用 Σ）：
   每筆 v＝g × maxf(0, 5 − d) × 10 × w；score += min(0, 最負的一筆 v) + max(0, 最正的一筆 v)
   ＝「最危險的那一座敵城」＋「最可靠的那一座友城」，各自上限與今天的單項同級（≤ 50 × w）
   ★不用 √N 或總上限：那是新造的形狀與常數；「各取最強一座」是今天「只看最近一座」的直接推廣
   （舊寫法 Σ 那行作廢，以本行為準）
   f(d)＝maxf(0, 5 − d) × 10 ⇒ 搬 :5981 既有的 5 與 10（不新增常數；從「最近一座」改成「每一座都算」）
   w（人格，連續）＝ 慎重 + (1 − 好戰)；預設 0.5／0.5 ⇒ w = 1 ⇒ 對敵對據點與今天同量級
   ★不知道的據點不在 known_outposts ⇒ 自然不進分（不另寫判斷）
★誠實限（R² ①）：查邊用的是對方隊【現在的】leader_id，不是我記得的領袖——relation_edges 全部以人物 id 為鍵，codebase 沒有 belief 版「我記得誰是首領」
   ⇒ 對方換過首領 ⇒ 舊恩怨查無 ⇒ 該座退成中立；本票不另開記憶首領機制（R² 同意），床不測這一格
③tap：Probe.note 候選格該項；[Site] 那行印贏家的這一項值＋用到的據點清單（tile_pos／owner／g）
   ★觀測不耗 RNG
④玩家面：F7 游標處的「已知據點／擁有者／關係」讀同一支 _known_outpost_relations 的資料（玩家隊當觀察者）——★同一份資料兩個讀者，不另寫
```
```
P9a belief 有敵對（feud 邊）據點在候選格 2 格外 vs 同位置但 belief 沒有那座 ⇒ 前者分數低、後者與無據點同分
P9b 同勢力據點 2 格外 ⇒ 分數比沒有時高
P9c 陌生人（無邊、非同勢力）據點 2 格外 ⇒ 分數與沒有時相同（★改前會扣，這格改前紅）
P9d 慎重 0.9／好戰 0.1 vs 慎重 0.1／好戰 0.9 ⇒ 同一敵對據點的扣分前者大
P9e 負對照：拿掉該項 ⇒ P9a 兩者同分
P9h 量級：候選格 5 格內放 4 座已知敵城 ⇒ 該項 ≥ −50 × w（只算最強一座）｜反向：改回 Σ ⇒ 必紅
P9f grep `_enemy_outpost_positions` 在 scripts/ 出現次數＝0（改名後舊名不得殘留）
P9g world-fp 會變（與 F8 同一顆量）⇒ 先量、換基準同 commit
```

## F10 終端地圖視窗＝整張（用戶裁，藍圖 `4d70c8aad`②；同批）

```
今天：text_map_renderer.gd:5 VIEW_RADIUS = 5，以玩家為中心（:24-34），每列切變縮排 "  " × (dr + VIEW_RADIUS)
改：視窗中心＝地圖中心、半徑＝地圖半徑——★兩者都從 state.world.tiles 的座標範圍算一次（不寫死 8；world_generator.gd:63 的 radius 是 config，生成後沒存進 state）
   ⇒ @ 不再固定在正中，畫在玩家實際位置；沒去過照 ?；圖示優先序、記憶層、游標規則全不變（#9 那張照它的 spec 接在這上面）
   ★寬度：r=8 ⇒ 每列 17 格 × 4 字＝68，加最末列切變縮排 2 × 2r＝32 ⇒ 最寬 100 欄（藍圖信寫 68 只算了格子；120 欄仍放得下）
   ★戰鬥區局部圖不動（另一支）
P10a 列數＝2r+1、每列實格數 ≤ 2r+1、最寬列格數＝2r+1｜任一列字元寬 ≤ 120
P10b 玩家走到地圖邊緣 ⇒ @ 在那個位置（不是正中）、整張輪廓不動
P10c 反向：VIEW_RADIUS 改回 5 ⇒ P10a 必紅
```
