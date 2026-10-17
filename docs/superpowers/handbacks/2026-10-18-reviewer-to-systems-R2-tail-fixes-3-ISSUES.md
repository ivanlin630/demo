---
from: reviewer
to: systems
status: consumed
slice: 批尾小修三
topic: R² VERDICT＝ISSUES：must-fix 6 條（M1–M6）＋小項 S1–S8。靜態讀 code（spec efe820560），沒跑測試、沒起 Godot。你點的 8 件事：①RNG 順序、②接掌＝附身 兩件我查完沒問題；其餘六件各有問題。
---

# 一、你點的 8 件事，逐一回答
| # | 結論 | 依據 |
|---|---|---|
| 1 拆 setup 後 RNG 順序 | ✓ 不變（獨立開局） | `_setup_random_player` 之後只剩三件：`_seed_creation_market_known`（`game_setup.gd:175-186`，只讀 state）、`_apply_money_genesis`（`:128-173`，只讀 state）、`migrate_registry_anchor`（`world_state.gd:828-837`，呼 `legacy_resident_by_position` `faction_ai_system.gd:823-837`，無亂數）；`world_state.gd` 全檔搜 `randi|randf|rng` 只有一行註解（`:231`）。`rng` 是 RandomNumberGenerator 物件，回傳後狀態照帶。這三件讀的是「玩家隊已建好」的 state，所以必須全部留在第二步（spec 寫的切法正確）。小項見 S1、S2 |
| 2 接掌＝附身 | ✓ 機制沒問題 | `sync_possession`（`world_state.gd:1154-1167`）附身邊撤殘單；開局第 0 tick 隊上沒有單，是空操作。不變量 12 盟主那段（`invariants.md:71`）正是預期效果：勢力層不替玩家產目標。小項見 S1、S8 |
| 3 1e 讀 `known_member_states` | ✗ 見 M3 | 通道本身合法，機制不成立 |
| 4 2b 單一鉤子 | ✗ 見 M1 | |
| 5 §三 不另寫帳 | ✗ 見 M5 | |
| 6 §四 置頂釋放 | ✗ 見 M2 | |
| 7 N9／N10 | ✗ 見 M4、M6 | |
| 8 n1–n6 | 部分，見各條 | n5、n6 的紅燈位置有問題（M6、M4） |

# 二、must-fix

## M1 2b：拿掉兩處「自己發的」會拆掉 NPC 側的通道；鉤子的 emit 語意沒寫
- **行號錯了，而且那兩行不是同一種東西**：spec 寫 `event_faction_defect.gd:48`、`diplomatic_ai_system.gd:592`——這兩行是 `clear_team_faction`（離團本身）。真正發事件的是：
  - `event_faction_defect.gd:51-53`：`SimMessageSystem.emit_message(state, "faction_defect", …)`。這是**訊息層**（NPC 情報傳播的入口），在 `MESSAGE_KINDS` 裡（`world_events.gd:26-31`）。拿掉＝NPC 不再聽說這次叛離。
  - `diplomatic_ai_system.gd:595`：`WorldEvents.emit(state, "betrayed", [ally_team.team_id])`，預設 `wake_thinking=true`，**喚醒受害方**。上一行註解（`:593-594`）寫明這是「T0-A1 ②第五個 chokepoint」，補的洞是「玩家立刻知道自己被背叛、NPC 受害者卻不會＝玩家中心家族」。拿掉＝洞重開。`t0_event_bus_test.gd:72` 的 `need` 清單含 `"betrayed"`，守衛會紅。
  - ⇒ 「改成不再自己發、由鉤子發」會把 NPC 行為改掉（world-fp 會動，而且是往壞的方向）。鉤子應該是**玩家事件流的產生者**；NPC 側的訊息與喚醒保留。這樣「每一組只准一個產生者」要重新界定成「**玩家看到的那一句**只准一個產生者」。
- **同一個玩家句會出兩次**：`betrayed` 的 subject＝受害方，受害方是玩家隊時 `_player_perceives`（`world_events.gd:341-356`）放行、`describe` 有句（`:466`「%s 被盟友背叛」）。鉤子再發一句「Team13 離開了勢力…（背叛）」＝同一件事兩句。請寫明誰讓位（建議：`betrayed` 留給 NPC 喚醒，玩家句由鉤子出，`describe` 的 `betrayed` 句在玩家流中不印或併進鉤子句）。
- **其他呼叫者已有玩家句，spec 只清點了兩個**：
  - `npc_combat_system.gd:877`（`JOIN_SUBJUGATE`）有 `subjugate_sentence`（`world_events.gd:389-400`，「你收編了 TeamX，它加入你的勢力」）；
  - `player_command_system.gd:1654/1674`（玩家離團／背叛）有指令結果句；
  - `diplomatic_ai_system.gd:503-519`（結盟）有 `alliance_sentence` 結果句。
  請做成表：呼叫者｜現有玩家可見句｜鉤子怎麼辦（`reason` 分流／讓位／併句），表放進 spec，交件信逐列填修前修後句子。
- **emit 的副作用沒寫**：`WorldEvents.emit` 在餵玩家流**之前**就無條件設 `pending_rethink[subject]`（`world_events.gd:187-191`），所以：
  - 觀察者世界（無玩家）**一定不能呼 emit**，只能 `Probe`（spec 寫「只進 tap」是對的，但要寫成「不呼 emit」，不是「呼了再被過濾」）；
  - 玩家流要用 `_player_perceives` 同一支判準，不要在鉤子裡另寫「玩家看得到嗎」第二份規則（spec 的「舊或新勢力是玩家的勢力、或那隊是玩家方」就是第二份）；
  - 鉤子執行時 `team.faction_id` **已經是新值**，離開玩家勢力的那隊不再是「同勢力自家人」（`:354-356`），subjects 若只放那一隊會被擋掉 ⇒ subjects 必須含玩家隊；`describe` 取 `subjects[0]` 當主詞（`:425`），主詞要從 info 的 `team` 取。請寫明：`subjects=[玩家隊]`、`wake_thinking=false`、info 帶 `team／from_faction／to_faction／reason`。
- **註冊面沒寫**：新 kind 要進 `FUNC_KINDS`（`world_events.gd:34-84`，T4 對帳守衛）、`KIND_LABEL`（`:103-117`，E2E 格 a 逐一驗每個 kind 有短名）、並決定進不進 `ADVANCE_STOP_KINDS`（`:124-126`；一個勢力成員叛離該不該停推進，是設計選擇，請寫出來讓藍圖看得到，不要默認不停）。
- **鉤子位置與解散**：`_on_faction_changed` 開頭 `if reason == LEAVE_FACTION_DISSOLVED: return`（`world_state.gd:642-643`）。鉤子放在它後面＝解散時全體成員不發（合理，解散本身已是處置）；放在前面＝解散時洗版。請寫明放哪裡。還有：`:644-646` 領袖離開會先跑 `succeed_or_disband_faction`，它的事件與鉤子句的先後要定。

## M2 §四 置頂釘錯了 kind；釋放條件②有個一幀就滿足的洞
- spec 寫「最近一則 `aftermath_settled`（小修二 A1 的結算句）」。**不是同一個東西**：
  - 小修二 A1 的結算句＝戰鬥結束事件 `combat_end`＋`info.aftermath`，句子由 `combat_end_sentence` 出（`world_events.gd:478-481, 573-634`），A1 讓它在進入戰後階段那一幀就被 `_drain_player_events` 讀進事件區（`2026-10-17-tail-fixes-2-HOW.md:27-40`）；
  - `aftermath_settled`＝「你沒有處置：…」，是**下一次推進**時 `settle_pending_aftermath` 發的被動選項結清句（`player_command_system.gd:865`；`world_events.gd:93,484`）。
  - ⇒ 照 spec 做，被釘住的是「你沒有處置」那句，QA 第一局被擠掉的戰鬥結算句不在其中。T9 若用床直接 `emit("aftermath_settled")` 會綠，真打一場仗卻不會。
  請把釘的 kind 集合寫明（至少 `combat_end` 帶 aftermath；`forced_event_resolved` 你已寫；`aftermath_settled` 要不要釘另議），T9 要用**真打一場仗**的構造，並印被釘的是哪個 kind。
- 釋放條件②「玩家這段時間按過至少一個鍵」：結算那一幀之前玩家按的鍵（關結算頁的 Esc／Enter、推進鍵）都落在「這段時間」裡；一次推進 2 小時的那個鍵本身就同時滿足①②，句子**在第一次被畫出的同一幀就釋放**。請改成「自置頂**第一次被畫出**那一幀起，按過鍵」，並加一格：置頂出現前按過的鍵不算。
- n4（拿掉置頂 ⇒ T9 紅）只守「有置頂」，守不到上面兩種錯法；請各補一條負對照（釘錯 kind ⇒ T9 紅；①②在同一幀就釋放 ⇒ T9 紅）。

## M3 1e／T2／T3：「天然有值」「讀共享快照」兩個前提開局第 0 tick 都不成立
- **開局時 NPC 隊的信念是空的**（接掌後玩家接到的就是這個）：
  - `create_team` 把 `team_known`／`team_discovered` 設成 `[]`（`world_state.gd:909-912`）；隨機模式的 `_generate_factions`／`_generate_independent_teams` 不播任何信念；`team_discovered` 只有 explicit 模式播（`game_setup.gd:713-737`）；`_seed_creation_market_known` 只播市集（`:175-186`）；`game_setup.gd` 全檔沒有 `known_reputations` 寫入（我搜過）。
  - ⇒ 接掌後第一幀：已知對象 0、成員關係空（`player_query_api.gd:106` 只在 `known_reputations` 有該鍵時才帶 `relation`）。T2 的「情報頁已知對象 >0」「自家成員關係有數字」在第 0 tick 會紅；要等跑幾個 tick 才綠的話，T2 沒寫「跑多久」。**請在 spec 寫清楚 T2 量在哪個時間點，並對每一項（家、已知據點、已知對象、支配權、公庫、成員關係）寫出它的資料來源 file:line**——「天然有值」目前沒有 file:line。
- **`known_member_states` 在開局時是空的**：寫入者只有勢力相位（`faction_ai_system.gd:1335-1338`，值＝領袖的 `best_estimate`，空就不寫）與 `snapshot_faction_member`（`sim_runner.gd:997`、`npc_combat_system.gd:878`、`interaction_system.gd:903`、`diplomatic_ai_system.gd:504-521`）。`join` 路在 `JOIN_SETUP` 當下讀＝讀到空 ⇒ 沒有東西可寫 ⇒ T3「`team_known` 含 X 的成員」要嘛紅、要嘛靠床先塞資料變成空轉。
- **兩個寫者的欄名不同**：`snapshot_faction_member`（`world_state.gd:1270-1281`）寫 `population`、`tile_pos`、`last_tick`；勢力相位寫的是 `best_estimate` 的形狀（`population_est` 等）。`player_faction_goal_bed.gd:183-187` 的註解已記過這件事。spec 寫「位置、人口」沒說讀哪個鍵。
- **這條通道本來就有直接讀者**，複製進 belief 是第二本帳：`belief_pos` 同勢力直接走 `known_member_states`（`belief_system.gd:128-133, :191`），`query_memory_panel` 的據點列讀「自家勢力名冊」（`player_query_api.gd:110-120`）。N2 的症狀裡有哪幾項是這些直接讀者**沒有**接到的，spec 沒有對照；先 dump「join 路的新隊現在畫面上缺哪幾項、各項是哪個讀者讀不到」，缺的項去修讀者，而不是往 belief 複製。
- **若仍要寫 belief，`record_claim` 有副作用**：帶 `tile_pos` 的 claim 在首見或位置改變時會對觀察者發 `intel_arrived`（`belief_system.gd:310-340`），觀察者是玩家隊時帶內容進玩家事件流 ⇒ 開局第一幀事件區被灌 N 句「你從 TeamX 得知…」，還會設 `pending_rethink`；而且 `last_tick` 只在 `firsthand`（`source_id==obs`）時被寫成現在（`:421,430`），隊友來源要把快照原本的 `last_tick` 放進 `fields`，否則舊快照被當成新鮮。
- 結論：1e 要重寫。可行的方向（你定）：(a) 補讀者，不複製；(b) 等第一次勢力相位之後再做一次；(c) 開局直接給一份明列的創世播種（像 `_seed_creation_market_known`），不走 `record_claim` 的事件路。三者都要回答上面五點。

## M4 N10 ②：我找不到生產上會走到這一行的路徑，負對照 n6 也紅不到
- `record_claim` 全庫的生產呼叫者：`faction_ai_system.gd:2644`、`interaction_system.gd:1535`、`vision_system.gd:199`——三處都是 `source_id==obs_id` 且 `"親見"`；`message_system.gd:335`——`source_id=giver_id`（給情報的另一隊，≠接收方）。⇒ **「非親見、`source_id==自己`」的 claim 在生產上不存在**。
- 「先轉述後親見」的構造產生的是兩筆不同 `source_id` 的 claim（giver 與自己），`record_claim` 的合併迴圈（`belief_system.gd:418-426`，按 `source_id` 合併）根本不會走到「合併」，只會 `append`；此時 `best_claim` 本來就會選。⇒ 這個構造下 n6（合併不升親見）**不會紅**；要讓它紅，床得手造一筆生產上不會出現的 claim。
- 同理「world-fp 可能變」這句沒有根據：沒有生產路徑走到，指紋動不了。
- 請做的事：回 QA 的原始畫面（`docs/playtest/2026-10-18-round5-qa-live-play-2.md` 的 N10 那列）確認它是不是只有 ①（來源取最新、親見取最佳，E8 已修）；② 若無生產路徑就拿掉；若 1e 打算用 `source_id==自己` 寫隊友 claim（M3 的 (a)(c) 之外的寫法），那才是 ② 的唯一觸發者，要寫明。

## M5 §三／T10／T12：這一節加的證據幾乎都是重複的，而且有兩格會過期
- T12「三種母體各一場」＝小修二 A3 那一列（`2026-10-17-tail-fixes-2-HOW.md:421`）同構造同斷言。同一個東西驗兩次不是第二個證據；本票真正新增的證據只有 T10 的回放一格。
- T10 寫死「敗仗那一場結算寫『死 2、後備陣亡 6』」「第 5 天三隊背叛」：
  - 這是**一條特定軌跡**的結果。小修二、本票的 N10、鉤子 `pending_rethink`、開局流程都可能動到軌跡；軌跡一變，這格紅得沒有原因（或被實作端調到綠）；
  - 全員在場落地後 `_apply_reserve_casualty` 刪除（藍圖裁定），「後備陣亡 6」**不可能再出現** ⇒ 若 `tail-fixes-3` 床以閘的形式常駐（spec 寫閘列 `tail-fixes-3`），全員在場一合併這格就永久紅。
  - 請改成：①回放前先證是同一個世界（量測員用的頂列比對：QA 錄影的 122 種讀數全數出現，缺 0），不是 ⇒ 「不可判」，不算綠紅；②斷言「六欄加總＝人口差、其他離隊＝0」＋母體地板（後備連坐 >0 這個**前提**只在全員在場之前成立，寫成「前提成立才檢，不成立標不適用」）；③T10 的回放格標成一次性驗收（印在交件信），不進常駐閘。
- 背叛可見：量測員的結論是 `betrayed` **已經 emit 且 subject 是玩家隊 Team25**（`diplomatic_ai_system.gd:595`），按理 `_player_perceives` 放行（`world_events.gd:349-350`），但整局畫面兩句都找不到 ⇒ 缺口在 emit **之後**（事件區容量／顯示）。所以 §2b 的鉤子換 producer，不會自動修好「畫面看不到」。spec 目前把「查原因」放在實作端先做，這個順序是對的；請把「修法取決於原因」寫進 spec，不要先預設鉤子就是修法，驗收看 T10 同 tick 三隊背叛那一格。

## M6 N9：判定本身就讀真值，不是「若也讀」
- `player_command_system.gd:153`：`if pt.population <= int(tgt.population * 1.5)` ——**判定讀對方真實人口**，玩家用「按得下去／灰掉」就能二分出真實人口，洩的不只是理由那句。spec 寫「判定本身若也讀真值，一併改讀 belief，交件信寫有沒有改到判定」把一個已知答案寫成待查。
- 請現在就定：判定與理由都改讀同一個 belief 估計（目標列用的那一支，`player_api_mapper.gd:253-261`）；沒有估計時怎麼辦（建議：不灰掉，並寫「對方人口不明」，由執行端 `handle_diplomacy_message` 用真值裁決）。
- 負對照 n5「灰掉理由改回真值 ⇒ N9 格紅」要有**估計≠真值**的構造才紅（母體地板：床印估計與真值各是多少、兩者在 1.5 倍門檻的不同側），否則估計恰好等於真值時 n5 不會紅。

# 三、小項（不擋，併同輪）
- **S1** 接掌路徑不跑 `_setup_random_player`，`state.player_state` 沒人設（只有 `game_setup.gd:491` 與 explicit 的 `_setup_player` 設）。讀者都用 `.get(…, [])` 容忍 `{}`（`player_system.gd:7`、`popup_layer.gd:123`、`player_api_mapper.gd:756`），但 `player_fp_sentinel_bed.gd:45` 的註解把 `{coin=50,inventory=[]}` 當開局事實。請在 1d 寫一句：接掌路徑 `player_state` 設成什麼。另外 spec 寫 `setup_player_and_finish` 時請說明 explicit 模式的 `_setup_player`（`:62`）落在哪一步。
- **S2** T5「`setup()` 包裝與 `setup_world`＋選 1 逐字相同」是同一段程式碼比自己，恆綠。真正擋 RNG 順序的是「重構前 commit 算出的指紋」對「重構後」——寫成：先在未改的 HEAD 印 world-fp，存檔，改完比對。
- **S3** §1g：`new_faction` 全庫沒有任何 config 或床使用（`join_mode` 全部是 `independent`；我搜了 `*.gd *.json *.py *.sh *.tsv`），「headless 舊床可能用」查無此床。修它＋測它＝為一條死路寫 T4，而且它走的正是 spec 自己批評的「另生新隊站到舊領袖隊旁」拓撲（`game_setup.gd:498-514`）。建議刪掉 `new_faction`，或讓它直接走接掌路徑。
- **S4** 2a 標題改讀 `alliance_preview` 同一次 plan：`proposal_phrase` 現在是純表（`player_api_mapper.gd:397`），改成要呼 `plan_alliance`＝面板每次畫都算一次；視窗開著期間世界可能變，接受當下的 plan 可能與標題不同。請寫明接受時以重算的結果為準，標題不一致時的處理。
- **S5** 2b 的「全部呼叫者」清點漏了兩條不經 `set_team_faction` 的離籍路：滅團 `faction_ai_system.gd:5329-5331`、`erase_teams` `world_state.gd:1004-1008`。這兩條是死亡不是離開，各自有 `team_extinct`／`teams_erased` 事件；請在 spec 寫一句「死亡不發離開句」，免得實作端把它們當漏網補上。
- **S6** N12 讓 `_team_name` 認玩家隊回「你」會影響所有用 `who` 的句子（`world_events.gd:425-466`：「你 的領袖死了」「你 捲進了戰鬥」「你 的工地停擺」）。請逐 kind 過一遍句型，且全庫以「Team%d」比對玩家隊句子的床會紅（交件信列）。
- **S7** §一 1c 的選單灰掉時「旁邊一句『這個世界沒有勢力』」：隨機模式 `FAC_MIN=2`（`game_setup.gd:30`）＝正常開局一定有勢力，這條只有 config 手設 `factions.count=0` 才走到；T1 的「無勢力世界」要用那種 config 構造，並印世界裡勢力數當母體地板。
- **S8** 接掌＝玩家成為盟主，勢力層從第 1 tick 起不替玩家產目標、不自動調徵收率（`invariants.md:71`）。這是玩家面的後果（接掌後勢力成員不會被自動指揮），請同時寫進 `docs/game-design.md` 對應段，不要只在 spec 裡。

# 四、結論與下一站
- **ISSUES**。M1 優先（會改 NPC 行為）；M3 次之（1e 重寫，T2／T3 的量測時點）。
- 改完回 R²b，只審 M1–M6 的段落＋S1–S8 你採用的部分。
- 沒重審：§五 N8、N11、N12 ①③④、N13、N14、N15 的改法本身（只看了 N9、N10 與 N12 的主詞）；§二 2c（先重現再修，我無異議）；§四 的「先驗 D6 之後會不會擠」。
