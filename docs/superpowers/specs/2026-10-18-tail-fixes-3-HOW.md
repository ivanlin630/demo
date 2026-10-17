# 批尾小修三（第五輪第二局 QA）— HOW（第二版，依 R² M1–M6／S1–S8）

- 審查：R² `docs/superpowers/handbacks/2026-10-18-reviewer-to-systems-R2-tail-fixes-3-ISSUES.md`。

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
- `explicit` 模式不動：它的 `_setup_explicit_teams`＋`_setup_player`（`:61-62`）整段留在 `setup()` 裡，不經選單（S1）。

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
  - `state.player_state` 設成與 `_setup_random_player`（`game_setup.gd:491`）同形：`{"inventory": [], "coin": float(config.player.starting_resources.coin)}`（S1）。
- 「原隊長降記名」：附身的是原隊長本人（玩家接手他）。藍圖原話「原隊長降記名成員」——因為玩家就是那個人，沒有第二個人要降；交件信寫一句，若藍圖指的是另一種（玩家另有一個人取代原隊長），回報不擴。
- ★N2 各項接掌後的資料來源（R² M3）：

  | 項 | 讀者 | 接掌後 |
  |---|---|---|
  | 家 | `player_api_mapper.gd:72-78` `_home_tile` → `state.own_outpost_tile` | 該隊擁有據點（`game_setup.gd:418-420` 以 `first_team_id`＝領袖隊建）⇒ 第 0 tick 有值 |
  | 支配權／公庫 | `player_api_mapper.gd:1209`、`:1167-1168` 比 `outpost_owner == pt.team_id` | 同上 ⇒ 第 0 tick 有值 |
  | 附近已知據點 | `player_query_api.gd:536-545`：`own_outpost_tile` ＋ `known_outposts` | 自家據點那一項第 0 tick 有值 |
  | 已知對象（情報頁） | `BeliefSystem.known_targets`（`player_query_api.gd:72`） | 開局全世界的信念都是空的（`create_team` 給空、隨機模式不播，R² 查過）⇒ 第 0 tick＝0，第一次視野／勢力相位後才有。不是接掌的洞，所有開局都一樣 |
  | 自家成員關係 | `known_reputations`（`player_query_api.gd:103-106`） | 開局全世界都沒有 ⇒「不明」。同上 |

  - ⇒ T2 分兩個時間點量：第 0 tick 量前三項；開局後 24 小時量後兩項（印數字，不設門檻，只證「接掌後會長出來」，對照同 seed 獨立開局同時點）。
- 被附身的隊照不變量 12：決策層不再寫它；勢力層「盟主是附身隊的勢力」那段規則自然生效（`docs/invariants.md:71`）。

### 1e 加入既有勢力的新隊要知道自家（R² M3 重寫）
- 不往 belief 複製（會灌 `intel_arrived`、設 `pending_rethink`、時間戳錯，`belief_system.gd:310-340,421,430`），也不讀開局時是空的 `known_member_states`。
- 先 dump：選 3 開局，第 0 tick 與 24 小時後各印一次「新隊畫面上缺哪幾項、各項的讀者是誰」（家、附近已知據點、情報頁、成員列、勢力面板）。
- 修**讀者**，不複製資料：同勢力的成員與據點今天已有直接讀者（`belief_pos` 對同勢力走 `known_member_states`，`belief_system.gd:128-133,191`；`query_memory_panel` 的據點列讀自家勢力名冊，`player_query_api.gd:110-120`）。dump 裡缺的那幾項，讀者改成同樣讀勢力名冊（`FactionData.member_team_ids` → 各成員 `own_outpost_tile`；勢力成員彼此知道的事）。
  - 只改玩家查詢（`player_query_api`／`player_api_mapper`），不改 NPC 決策讀的函式（`_known_outpost_relations` 等）⇒ world-fp 不動。
- 加入者沒有自己的據點 ⇒「家：（無）」、支配權否、公庫不可用是正確的（別人的據點）。交件信寫明。

### 1f 「勢力關係：尚無」
- `player_query_api.gd:125` 寫死 `"faction_relations": []`。勢力之間的關係今天沒有資料（`FactionData.relations` 全站無讀者）⇒ 改成列「自家勢力成員」（隊名、對他的 `known_reputations`），標題改「勢力成員」；勢力之間那欄印「勢力之間的關係還沒做」，不印「尚無」（尚無像是查過了是空的）。

### 1g config 路的 `new_faction`（S3）
- 全庫沒有 config 或床用它（R² 搜過）。改成走接掌路徑：`join_mode: new_faction` ⇒ 以 state 取成員總人口最小的勢力，走 1d；`_find_weakest_faction` 讀 config weights 那支刪掉。沒有勢力 ⇒ `push_error`＋開局事件一句「找不到可接掌的勢力，改為獨立開局」。

## 二、改投視窗說真做的事（★N6、★N7、★N5）

### 2a 句子（★N6）
- `plan_alliance`（`diplomatic_ai_system.gd:452-470`）回 `move` 且被搬的那隊原本有勢力 ⇒ 這是「它脫離勢力 X、加入你的勢力 Y」，不是結盟。
- 單一產生者：`PlayerCommandSystem.alliance_preview`（`player_command_system.gd:1172-1190`）與 `alliance_sentence`（`:1193-1208`）各改那一支：
  - 預告：「接受＝Team13 脫離勢力3、加入你的勢力0」
  - 結果：「Team13 脫離勢力3、加入你的勢力0」
- 視窗標題（`player_api_mapper.gd:397` `proposal_phrase("alliance")`＝「提議與你結盟」）：同一個 plan 是 `move` 且對方原有勢力 ⇒ 標題「想脫離勢力3、加入你的勢力0」。標題讀 `alliance_preview` 同一次 plan 的結果，不另判。
- 行為不改（挖角裁定）；領袖隊那條「兩勢力之間的結盟還沒做」照舊。
- 標題畫的那一刻算一次 plan；接受當下 `_accept_diplomacy` 會重算（S4）。重算與標題不同 ⇒ 以重算為準，結果句照實寫，後面加「（跟視窗寫的不同：<重算的原因>）」。

### 2b 離開勢力一律有玩家看得到的一句（★N7、★N6；R² M1 重寫）
- **鉤子只是玩家事件流的產生者**；NPC 那側的訊息與喚醒全部保留：`event_faction_defect.gd:51-53` 的 `emit_message("faction_defect")`（訊息層，NPC 靠它聽說）、`diplomatic_ai_system.gd:595` 的 `WorldEvents.emit("betrayed")`（喚醒受害方，`t0_event_bus_test.gd:72` 守它）都不動。⇒「只准一個產生者」在這裡指「玩家看到的那一句只准一個產生者」。
- 位置：`set_team_faction`（`world_state.gd:590-613`）裡，寫入之前先用 `WorldEvents._player_perceives(state, [team.team_id])` 判一次（舊勢力值下），寫入後再判一次；任一為真才是「玩家看得到」。不在鉤子裡另寫第二份規則。
  - 放在 `_on_faction_changed` 的 `LEAVE_FACTION_DISSOLVED` 早返回（`:642-643`）之後：解散時不逐隊發。
  - 領袖離開會先跑 `succeed_or_disband_faction`（`:644-646`）；鉤子句排在它之後。
- 發法：看得到 ⇒ `WorldEvents.emit(state, "faction_member_left", [玩家隊 id], false, {team, from_faction, to_faction, reason})`——subjects 放玩家隊（離開的那隊此時已不是同勢力，放它會被 `_player_perceives` 擋掉，`world_events.gd:354-356`），`wake_thinking=false`，句子主詞從 info 的 `team` 取。看不到（含觀察者世界）⇒ **不呼 emit**（emit 會無條件設 `pending_rethink`，`:187-191`），只 `Probe.bump("faction.member_left.unseen." + reason)`。
- 註冊：`faction_member_left` 進 `FUNC_KINDS`（`:34-84`）、`KIND_LABEL`（`:103-117`，短名「離開勢力」）。推進停點（`ADVANCE_STOP_KINDS`，`:124-126`）：原因是背叛或起義、而且離開的是玩家的勢力 ⇒ 停；其餘不停——我定的設計預設，已告知藍圖。
- 各呼叫者現有的玩家句與鉤子怎麼辦（交件信逐列填修前修後句子）：

| 呼叫者 | reason | 現有玩家可見句 | 鉤子 |
|---|---|---|---|
| `diplomatic_ai_system.gd:592` 背叛 | `LEAVE_BETRAYAL` | `betrayed`「%s 被盟友背叛」（`world_events.gd:466`）＋警示列 | 鉤子出「Team2 背叛勢力0、離開」；`betrayed` 在玩家流中不印（照樣喚醒 NPC 受害方），避免兩句 |
| `faction_ai_system.gd:8162/8169` 起義 | `LEAVE_UPRISING_*` | 無（只 print） | 鉤子出 |
| `faction_ai_system.gd:8274/8278` 投降失敗／自立 | `LEAVE_DEFECT_*` | 無 | 鉤子出 |
| `event_faction_defect.gd:45/48` | defect | `faction_defect` 走訊息層（不是玩家流） | 鉤子出（訊息層照舊） |
| `faction_ai_system.gd:8271` 投降鄰國 | `JOIN_SURRENDER_NEIGHBOR` | 無 | 鉤子出 |
| `npc_combat_system.gd:877` 收編 | `JOIN_SUBJUGATE` | `subjugate_sentence`（`world_events.gd:389-400`）——玩家是收編方時 | 玩家是收編方 ⇒ 讓位；別的勢力把你的成員收走 ⇒ 鉤子出 |
| `diplomatic_ai_system.gd:503/506/519` 結盟搬隊 | 結盟 | `alliance_sentence`（玩家是接受方時，2a） | 玩家是提案或接受方 ⇒ 讓位；第三方結盟把你的成員搬走 ⇒ 鉤子出 |
| `player_command_system.gd:1654/1674` 玩家離團／背叛 | `LEAVE_PLAYER*` | 指令結果句 | 讓位 |
| `interaction_system.gd:1761/1790` 吸收／定居 | `JOIN_ABSORB`／`JOIN_SETTLE` | 無 | 鉤子出 |
| `world_state.gd:525` 解散 | `LEAVE_FACTION_DISSOLVED` | — | 不發 |

  - 「讓位」寫成 reason＋玩家角色的判斷，在鉤子一處，不在呼叫端各寫。
- **死亡不發離開句**（S5）：滅團（`faction_ai_system.gd:5329-5331`）與 `erase_teams`（`world_state.gd:1004-1008`）不經 `set_team_faction`，各有 `team_extinct`／`teams_erased`，不補。
- reason → 人話放 names.tsv（小修二 E2 那張）；沒對到 ⇒ unmapped tap，床斷言走過的世界 0。
- **★N7 背叛句沒到畫面**：量測員證實 `betrayed` 已 emit、subject 是玩家隊，`_player_perceives` 按理放行（`:349-350`）⇒ 缺口在 emit 之後（事件區容量／顯示，或警示列在終端不出現）。實作端先查原因；**修法取決於原因**——鉤子換產生者本身不會修好「畫面看不到」。交件信寫原因與修法。
- ★N7 後半「敵視的隊主動要進貢」是決策行為，不在本票（已記 known_issues）。

### 2c ★N5：灰掉理由與事實相反
- 閘＝`player_command_system.gd:148-151` `TeamData.same_faction(tgt, pt)`（讀即時 `faction_id`）；面板讀 `member_team_ids`（同一入口同步）。靜態讀不出為什麼兩者不一致。
- 實作端先用 QA 鍵序重現，dump 那一拍 Team35 的 `faction_id`、`parent_team_id`、面板列與閘讀到的隊號；找到原因後修那一處，交件信寫原因。重現不出來 ⇒ 回報，不猜修。

## 三、結算交代全部人（★N4；R² M5）

- 量測員回放第二局（`docs/superpowers/handbacks/2026-10-18-measurer-to-systems-DONE-game2-population-accounts-and-silent-faction-leave.md`）：人口 10→2 掉的 8 人全是戰死：記名 1＋上場匿名 1（結算只交代這 2）＋後備連坐匿名 6（`encounter_system.gd:1185-1197`，沒進結算句）。
- ⇒ 缺口＝小修二 A3 的「後備陣亡」欄；全員在場再把後備連坐整條刪掉。本票不另寫帳、不重複 A3 的驗收（A3 的三種母體床格已涵蓋）。
- 本票只加：
  - **記名寫名字**：A3 若只在「死」那欄寫名字，被俘、被對方處置的記名也要寫名字——交件信列 A3 實際哪幾欄有名字，缺的在本票補，床格一格（T13）。
  - **一次性回放驗收**（不進常駐閘，印在交件信）：①先證同一個世界（QA 錄影的頂列讀數全數出現在回放，缺 0；不是 ⇒「不可判」）；②那一場斷言「六欄加總＝人口差、其他離隊＝0」；③「後備陣亡 >0」是前提——只在全員在場合併之前成立，不成立標「不適用」不算紅。
- 對方那一側：只交代親見的部分（感知鐵律，同小修二 A3）。

## 四、結算不被洗掉（第一局 21、本局再證；R² M2）

- 主因「TeamN 收到了情報」：小修二 D6 已刪。本票先驗 D6 之後還會不會擠（一次性回放，同 §三的同世界證明）。
- 加一道保證：**結算句置頂**。事件區的產生者在可見列頂留一格：
  - 釘的 kind：`combat_end` 且 info 帶 `aftermath`（小修二 A1 的戰鬥結算句，`world_events.gd:478-481,573-634`）、`forced_event_resolved`（找上門的結果句）。不是 `aftermath_settled`（那是下一次推進時的「你沒有處置」，`player_command_system.gd:865`）——它要不要釘另議，本票不釘。
  - 釋放：自那一句**第一次被畫出**那一幀起，①遊戲時間過了 1 小時（TEST VALUE）且 ②玩家按過至少一個鍵；第一次畫出之前按的鍵（關結算頁的 Esc、推進鍵）不算。
- tap：`ui.event_pin.set.<kind>`、`ui.event_pin.released`。

## 五、一籃 UI 洞

| # | 現況（file:line） | 改法 |
|---|---|---|
| ★N2 | 見 §一 | 1d／1e／1f 根治 |
| ★N8 | 目標列只在 `visible_teams`（只掃 `team_discovered`，`player_api_mapper.gd:241-266`）找到時才印位置人數，否則只印「Team%d」（`text_ui_main.gd:2798-2813`） | 找不到時改讀那支隊的 belief（`best_estimate` 的位置與人口估計，同 J 頁那一支）；連 belief 都沒有 ⇒ 印「（位置不明）」，不印空 |
| ★N9 | 目標列人口是 belief 估計（`player_api_mapper.gd:253-261`）；納貢的判定與理由都讀真值（`player_command_system.gd:153-157`：`pt.population <= int(tgt.population * 1.5)`）——玩家用「按得下／灰掉」就能二分出對方真實人口（R² M6） | 判定與理由都改讀目標列那一支 belief 估計；沒有估計 ⇒ 不灰掉、理由寫「對方人口不明」，由執行端 `handle_diplomacy_message` 照今天用真值裁決（那是對方的決定，不是玩家的感知） |
| ★N10 | `source` 取 last_tick 最大那筆、`firsthand` 取 best claim（`player_query_api.gd:76-98`），兩筆可以不同 | 小修二 E8 已改成都從 best claim 取 ⇒ 本票只驗（回放不再出現「來自自己」）。R² M4：「非親見且 `source_id==自己`」的 claim 在生產上不存在，第一版寫的第二條路拿掉 |
| ★N11 | 戰中投降被拒：拒絕在世界 tick 裡結算、只進事件流；結果行（`encounter_view.key_reply` `:256-275`）撈到同拍的「@（你） 待機」並冠「✓」 | 投降（及其他會在 tick 內被拒的戰中指令）的拒絕句回到結果行：`surrender_in_encounter` 的結算回傳寫進 `_reply`；結果行冠號依結果（✓／✗），不寫死 ✓。小修二 E1 之後的同一支 `key_reply` 改 |
| ★N12 | ①成交句沒 info（`player_trade_system.gd:189-190`），主詞走 `_team_name` 恆「Team%d」（`world_events.gd:424-425,636-644`）；②「野心變了」沒帶新舊（`ambition_ladder.gd:147,162`）；③估值 0 是對方存量超過目標兩倍時的真值（`trade_valuation.gd:271-302`）；④提示印原始鍵（`text_ui_main.gd:3762`、`:3322`） | ①成交帶 `{gave, got}`，句子「你跟 Team7 換了：付 30 金、得 糧食×20」；②`rung_changed` 帶新舊階，句子「你的野心：<舊>→<新>」／「Team9 的野心：<舊>→<新>」。主詞「你」只在這兩個 kind 的句型裡用（一支 `subject_phrase(state, tid)`），不改全域 `_team_name`——改全域會牽動所有句型與比對「Team%d」的床（S6）；③值 0 印「（對方不缺）」，不印 0.0；④兩處改 `TextBank.res_name()` |
| ★N13 | 戰場單位標籤 `"P%d"`（`encounter_view.gd:313-320`、`:890`；`encounter_system.gd:812-814`） | 我方記名印名字（`PersonData.person_name`）；對方記名印「敵·記名」＋字母（名字是玩家不知道的，除非之前見過——今天沒有「認得某人」的資料，不做）；匿名照舊。三處改同一支 `_unit_name` |
| ★N14 | 武裝數＝記名全部＋round(匿名×比例)（`player_api_mapper.gd:229-232`），記名不看有沒有武器；比例只算匿名（`equipment_system.gd:62-77`） | 「武裝」改成「有武器的人數」＝手上真的有武器的記名＋匿名武裝數；比例＝武裝人數 ÷ 人口；回句與生存頁同一支。全員在場那張要把匿名部分換成 `anon_armed_count`——本票先寫一支 `armed_breakdown(state, team) -> {named, anon, total}`，全員在場沿用它（已寫進那張的派件信提醒） |
| ★N15 | 地圖一格一字，隊伍字母蓋過據點 ^（`text_map_renderer.gd:141-152`） | 一格一字不變。地圖下方加一行「據點上有隊伍：(10,13) A、(10,11) b」（只列玩家已知的據點；產生者一支，在 renderer 旁），有隊站著的已知據點都列 |
| ★N3、★N11 等同第一局族 | — | ★N3 的「攻擊只能打獨立隊」是設計（藍圖），本票只讓灰掉理由說清楚：「攻擊目標只能選不屬於任何勢力的隊」 |

---

## 驗收

- 新床 `scripts/debug/tail_fixes_3_bed.gd`，閘列 `tail-fixes-3`，expect `=== tail_fixes_3 DONE === errors: 0`。真鍵路徑。

| 格 | 斷言 |
|---|---|
| T1 | 選單：三項都列；`factions.count=0` 的 config 構造（印勢力數＝0 當母體地板）⇒ 2／3 灰掉並有原因；選 1 ＝獨立開局（S7） |
| T2 | 選 2 接掌勢力 X ⇒ `player_id`＝X 領袖隊的隊長、那支隊 `possessed`、不新增隊、`player_state` 同形；第 0 tick：家、支配權、公庫、附近已知據點（自家）有值；開局後 24 小時：已知對象數、成員關係數印出，與同 seed 獨立開局同時點對照 |
| T3 | 選 3 加入勢力 X ⇒ 第 0 與 24 小時的 dump 印出；dump 裡原本缺的項在修讀者後有值；belief 寫入次數修前修後相同（沒有往 belief 複製） |
| T4 | config 路 `new_faction` ⇒ 走接掌路徑（同 T2 前三項）；沒勢力 ⇒ 開局事件那一句 |
| T5 | world-fp：改之前在 HEAD 先印一次 world-fp 存檔；改完比對相同（S2） |
| T6 | 別勢力成員隊提結盟 ⇒ 標題與預告寫「脫離勢力3、加入你的勢力0」；接受 ⇒ 結果句同；開窗期間世界變了 ⇒ 結果句照重算並附「跟視窗寫的不同」；領袖隊提 ⇒ 照舊「兩勢力之間的結盟還沒做」 |
| T7 | 表上每一列各一格：該 reason 離開玩家勢力 ⇒ 玩家流恰好一句（讓位的列＝原有句子一句、鉤子 0 句）；觀察者世界同事件 ⇒ emit 0 次、`faction.member_left.unseen.*` >0；`betrayed` 對 NPC 受害方照樣喚醒（`t0_event_bus_test` 綠） |
| T7b | 同 tick 三隊背叛 ⇒ 玩家畫面可見（依實作端查到的原因修完之後）；推進停下 |
| T8 | ★N5 依實作端找到的原因寫的格（交件信定） |
| T9 | 置頂：真打一場仗到結算 ⇒ 被釘的是 `combat_end`（印 kind）；之後兩小時每小時塞 8 則其他事件 ⇒ 結算句始終可見；第一次畫出前按的鍵不算；畫出後過 1 小時且按過鍵 ⇒ 釋放 |
| T11 | ★N8／N9／N10（只驗）／N11／N12／N13／N14／N15 各一格；N9 用「估計與真值落在 1.5 倍門檻兩側」的構造（印兩值當母體地板）；無估計 ⇒ 不灰掉 |
| T13 | 記名被俘 ⇒ 結算句有名字 |

- 負對照：n1 選 2 改回「另生新隊」⇒ T2 紅；n2 拿掉 1e 的讀者修改 ⇒ T3 紅；n3 鉤子不發 ⇒ T7 紅；n3b 觀察者世界也呼 emit ⇒ T7「emit 0 次」紅；n4 置頂拿掉 ⇒ T9 紅；n4b 釘成 `aftermath_settled` ⇒ T9「印 kind」紅；n4c 第一次畫出前的鍵也算 ⇒ T9 紅；n5 N9 判定改回真值 ⇒ T11 N9 格紅（須在兩側構造下）。
- 一次性回放（§三、§四）：印在交件信，不進常駐閘。
- 舊床遷移：開局參數（REPL／driver 預設 `independent`，舊床不變）；改投句子相關的外交床；`faction_relations` 讀者。交件信逐一列。
- world-fp：本票預期不變（§一拆 setup 驗 T5；§二 鉤子觀察者世界不呼 emit；1e 只改玩家查詢）；變了歸因到第一個分歧 tick，不直接換值。
- 驗收後 QA 真玩：三種開局各玩一段，第二局 ★N 清單逐條複驗。

## 誠實限

- 勢力之間的關係今天沒有資料，「勢力關係」只能改列自家成員。
- 對方記名的名字不顯示（今天沒有「認得某人」的資料）。
- ★N7 後半（敵視的隊主動進貢）與 ★N6 的「剛打贏我的隊關係普通」是行為面，不在本票；已記 known_issues。
- 開局全世界信念都是空的，接掌與加入在第 0 tick 一樣「已知對象 0、關係不明」；這不是本票的洞。
- 接掌＝玩家成為盟主 ⇒ 勢力層從第 1 tick 起不替玩家產目標、不自動調徵收率（不變量 12）。這是玩家面的後果，已請藍圖寫進 game-design（S8）。
