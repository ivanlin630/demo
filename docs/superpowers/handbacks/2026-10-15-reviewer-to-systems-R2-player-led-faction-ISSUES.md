---
from: reviewer
to: systems
status: consumed
slice: R² 你領導的勢力不自動定目標＋收編要告訴你（main 74d7c54af）
topic: R② ＝ **ISSUES（四處要改、其中三處是 spec 的前提不成立）**｜①收編事件改走 WorldEvents.emit 會【丟掉資訊網那條通道】（emit_message 本來就已呼 emit，缺的只是 subjects 少一隊）、且 ADVANCE_STOP_KINDS 沒有 subjugate、旁觀句在玩家佇列裡到不了｜②can_subjugate 改成「玩家勝且空字串」會讓 GUI 直接不列、precheck 回「無可收編的敗者」⇒ S1 要的「標理由」做不到；on_captured_tile 玩家路徑恆 false｜③十支裡 `_step_contact_ledger` 的「記帳半」不存在（沒有失聯 belief、lost 欄位無讀者），而「拆不乾淨整支照跑」那條退路會讓 AI 替玩家隊派斥候；`_try_self_relocate` 對已紮根的玩家隊不是「不動」，且它在 arbiter 擋之前就已棄了據點｜④清 strategic_assignments 掛在 sync_possession 邊抓不到盟主交接、後入成員，且 skip 也關掉了生產者自己的清理；consumer 端本來就擋了玩家控制的隊，真正有殘單的是 NPC 成員｜另：census 在有玩家世界要求「逐項相同」會因 RNG 位移必紅
---

# 0 審了哪棵樹
main 74d7c54af（spec 引的 048f526c5 行號我逐條重驗）。讀：faction_ai_system.gd:125-145,1380-1420,1895-2085,2837-2856,2970-2993,3140-3161,8165-8330；strategic_ai_system.gd:28-140,175-282；diplomatic_ai_system.gd:162-234,569-591；task_arbiter.gd:39-98；world_state.gd:455-625,945-970,1100-1170；npc_combat_system.gd:236-246,455-475,832-867；interaction_system.gd:255-295,581-585；player_command_system.gd:592-604,1016-1025,1374-1427；encounter_system.gd:1340-1400；encounter_view.gd:195-205,1004-1013；message_system.gd:20-70,186-198；world_events.gd:96-134,175-194,333-358；manpower_system.gd:40-69；decision_context.gd:1120-1165；全 scripts 普查 `\.intent\b`、`strategic_assignments`、`player_hostile_teams`、`\.faction_id\s*=`、`member_team_ids.append/erase`、`_try_subjugate`、`dispatch_ledger`、`"subjugate"`、`\.goals\b`。

# 1 你問的五處（答案先給）

## ①intent 固定值：不會讓 NPC 成員路「變樣」到有害，但有一處會變、而且固定值沒有必要
```
讀者全表（f.intent，非 debug）：
  faction_ai:137-139 _intent_sig（空字典 ⇒ ""）｜faction_ai:1868 committed｜faction_ai:3583 probe
  strategic_ai:96-97（.get）｜manpower:53（.get("type","")）｜decision_context:1160-1162（只讀「leader 自己」那支，且先 is Dictionary）
✓ 成員讀的是 goals 不是 intent：decision_context:1131-1145 faction_stakes 只讀 f.goals；:1156-1162 的 intent 只給【leader 隊】（成員走 faction_stakes，:1154-1155 註解自己說不重覆）。
✓ leader＝附身隊 ⇒ _decide_unified 在 faction_ai:3497 就 return，decision_context:1160 的值沒人用。
✗ 唯一會變的 NPC 路：manpower_system.gd:51-56 decide_treatment——【成員隊當 holder】時取 f.intent.type，征服／擴張／建國 ⇒ 厚待加權 INTENT_ARMY_KIND_BONUS。
   玩家領導的勢力裡，NPC 成員從此永遠拿不到這個加權（intent 恆 守成）。這是合理的（那個 intent 本來就是拿玩家人格算出來的 AI 代決），但 spec 沒列、census 沒量。
✗ 固定值的反面：「守成／player_led」寫進 f.intent 之後，玩家交出盟主（死亡繼位 / 換附身）⇒ 勢力帶著 守成 進 NPC 時代；_select_intent 的 committed 滯後（faction_ai:1868）把「守成」當既有承諾偏袒一次。
   空字典下游全是 .get 或 is_empty 保護（上表逐處），faction_ai:1993-1994 對空字典本來就當 守成 用 ⇒ 兩者行為等價、空字典不留殘影。
   headless `_test_strategic_reads_ladder` 要的非空契約（:1972-1976）是 NPC 勢力的契約，player-led 不經過它。
⇒ 建議：f.intent = {}（不寫「守成」）、f.strategy 照給；census 單列 manpower:53 對玩家勢力成員的處置分布（修前修後差＝預期，印出來不用「相同」）。
```

## ②十支分類＋獨立附身隊同一刀：不是擴大範圍；但分類表有三處錯
```
範圍：同一個迴圈（faction_ai:2837-2855）、同一條 #12、迴圈頂端一個 `team.player_controlled ⇒ continue` 就收掉兩種隊——不另開 ✓。
✗ 與其「分記帳／決策」，這十支對 player_controlled 隊【整支跳過】更對（理由見下），表可以砍成一句話。
  (a) _step_contact_ledger（:8217-8255）的『記帳半』不存在：
      · 「逾時→失聯 belief」——函式體裡逾時只有 `Probe.bump("contact.overdue")`（:8236）和 `entry["lost"] = true`（:8251）；沒有任何 belief 寫入。
      · `"lost"` 全 scripts 只有 :8251 一處【寫】，零讀者（grep `\["lost"\]|get\("lost"` 非 debug）⇒ 這個旗標沒有人在乎。
      · ledger 的寫者只有四個點：_try_herald_side :3262、_try_scout_side :3320、_dispatch_convoy :5870、_ensure_holding_ledger :8190——全是 AI 派遣；
        十支對玩家隊全跳過後，玩家隊的 dispatch_ledger【只剩附身前的 NPC 殘單】。
      · 殘單被 `_apply_contact_reaction`（:8284-8303）處理時：redispatch ⇒ _try_scout_side／_try_herald_side（派人）、rescue ⇒ _dispatch_named_runner（派斥候）、
        holding 的 care ⇒ _dispatch_care_scout（:8241）、defensive ⇒ 寫 contact_vigilant_until（decision_context:648 讀）——全是決策。
      ⇒ spec 的退路「拆不乾淨就整支照跑並列 care 寫了什麼」是危險的：它讓 AI 替玩家的隊派斥候。請改成：玩家控制的隊整支不跑；殘單留著不動（無害：沒人讀）或在附身邊清掉。
  (b) _ensure_holding_ledger（:8172-8190）「記帳照跑」：它寫的 holding 條目唯一的讀者是 (a) 那個 holding 分支（:8238-8248，care 就派 scout）。
      (a) 跳過後它是無讀者的寫入 ⇒ 一併跳過；F5 的「記帳兩支照跑 >0」整格刪（那是替一個沒有讀者的寫入作陽性對照）。
  (c) _try_self_relocate「已排除盟主、玩家隊不是村 ⇒ 不動」不成立：
      · 排除條件只有 `faction_id == -1`（:3147）與【盟主】（:3150）。玩家控制的隊若是 NPC 勢力的【非盟主成員】、又紮根成居民（player_settle → resident_converted，task_arbiter.gd:46-52 自己列了這條事件來源）、
        `tile.outpost_owner == team.team_id and outpost_level > 0`（:3153）成立 ⇒ 走到 _begin_village_relocate（:3160）。
      · 該函式的順序是：:2978 `OutpostOwnerBank.set_owner(..., -1, "relocate_abandon")` 棄據點 ⇒ :2984 寫 task_extra_data ⇒ :2985 release ⇒ :2988 transition("relocate")。
        arbiter 的 _possessed_blocks（task_arbiter.gd:60-66）會擋 :2985/:2988，但【:2978 棄據點與 :2984 已經寫了】⇒ 玩家的據點被丟了、遷移卻沒發生＝兩邊都吃虧。
      ⇒ 這也是「arbiter 擋住就夠了」不成立的一個實例：此支必須在入口跳過。
  → 迴圈級 `if team.player_controlled: continue`（放在 info_eval_next_tick 戳記之前或之後都行，但要寫明哪個——之前＝玩家交出後第一輪立刻評，之後＝照 cadence），十支一網打盡；
    Probe `side.skip_player_controlled` 一個計數就夠（不用十個）；F5/F5b 改成：十支各自對玩家隊 0 次（用 Probe 在各支入口計「被呼叫」，跳過在迴圈故應 0）＋對照 NPC 盟主 >0。
```

## ③strategic_assignments：邊抓不到兩條路，而且清的位置不對
```
先釐清誰真的有殘單：
  · consumer 端 task_arbiter.gd:94（_set_strategic_move_body）：`if team.player_controlled: return` ——玩家控制的隊（盟主本人）【本來就不會被戰略佈點移動】。
    ⇒ 對盟主清 assignments 是無效動作（殘單在它身上也是惰性的）。
  · 真正會被殘單拉走的是【NPC 成員】：_step2a_strategic_move（sim_runner.gd:870-891）對非 player_controlled 的隊照吃 strategic_assignments.values()[0]。
    producer 一旦 skip，三件事一起發生：新單不再寫、舊單不再被 :127-139（無 expand ⇒ 逐隊 erase 非 -1 key）清、-1 突圍單不再被 :214-235 的 erase 清 ⇒ 殘單【永遠不過期】，NPC 成員被一張 NPC 時代的包圍令拉到天荒地老。
你問的「第三條路」——有兩條：
  (i) 盟主交接，沒有附身邊：succeed_or_disband_faction（world_state.gd:506 `f.leader_team_id = best`）零 hook。NPC 勢力的繼位者若是玩家的非盟主成員隊（統領技能最高即可）⇒ 勢力瞬間變 player-led，sync_possession 的 false→true 邊不會響（它早就 possessed）。
  (ii) 後入成員：set_team_faction（world_state.gd:568-587）把別勢力的隊搬進玩家勢力（結盟整併／投靠／收編後敗方原屬其他勢力的路徑），該隊帶著舊勢力時代的 assignments 進來；邊只響一次。
  (iii) 反向：玩家勢力的成員離團成獨立隊——殘單隨身（既有行為，NPC 時代也一樣，不在本票；僅提醒 skip 之後它不再被「無 expand ⇒ erase」遇到）。
⇒ 建議（狀態無關、不掛邊）：strategic_ai_system.tick 在 is_player_led 時 → 對 faction.member_team_ids 逐隊 `strategic_assignments.clear()`（冪等）→ return。
   延遲最長 STRATEGIC_INTERVAL（日級），在這段內殘單最多讓成員走向一個舊位置；不夠就再加一個 set_team_faction 入玩家勢力時清該隊（同咽喉、你本來就要加 erase 敵對帳，一起做）。
   不要靠 sync_possession 的邊：那裡的 _nt.possessed 判的是隊，不是勢力。
   F4 加三格：①成為盟主（附身邊）②繼位交接給玩家成員隊 ③後入成員帶舊單進來 ⇒ 各在 STRATEGIC_INTERVAL 內清空；負對照：拿掉 clear ⇒ 三格紅。
另：tick() 整段 skip 同時略過 `_evaluate_alliance_need`（strategic_ai:75，只有一句 print，無害）與 STRATEGIC／ALLIANCE 的 DecisionTier 戳記——玩家交出後該勢力第一輪立刻 due（stale next_tick 在過去），可接受，寫進 spec 即可。
```

## ④on_captured_tile：戰後選單「算不算得出」——問法本身要改，玩家路徑恆 false
```
· 玩家收編走：_action_subjugate_enemy（player_command_system.gd:1385）→ InteractionSystem.subjugate_team（interaction_system.gd:583-584）→ NpcCombatSystem.subjugate_team（npc_combat_system.gd:244-245）→ `_try_subjugate(state, winner_id, loser_id)`——【三參數，on_captured_tile 取預設 false】。
· on_captured_tile=true 只有 npc_combat_system.gd:473、:575 兩個呼叫點，而 :466 明寫「winner_id != 玩家隊才進」＝玩家勝方從不走。
⇒ 對玩家：:841 的門（`loser.faction_id != -1 or not winner.tags.has("統領")`）永遠是生效的那一條；:838-840 的『佔村授統領』捷徑玩家永遠拿不到。
⇒ 抽出的 subjugate_block_reason 對【玩家選單】不需要也不應該有 on_captured_tile 參數（傳進去的人只會傳 false；有人哪天傳 true＝選單說可以、實際不能＝列≠做回來）。
   做法：抽兩層——(a) 純門：block_reason(state, winner, loser, on_captured_tile) 給 _try_subjugate 自己用（保留 NPC 路徑逐位相同）；(b) 玩家入口 precheck 呼 (a) 並固定傳 false，註明為什麼。
· 理由句：:841 擋的是「敗方【任何】勢力成員」，不只是「已屬某勢力 f」；:846 另有「立國失敗(fid == -1)／已同勢力」。理由要兩句：「敗方已屬勢力{f}，不能收編」（含同勢力）與「要有統領才能收編」；create_faction 失敗是 :845 才知道的，block_reason 預測不了——寫明是少數不列的例外，並讓 _action 在 _try_subjugate 之後驗結果（勢力數/敗方 faction_id 有變才回 ok:true），否則「做不成還說做了」只修了一半。
```

## ⑤set_team_faction 咽喉 erase：沒有漏路；背叛重新標只有一個寫者且有條件
```
入勢力路徑普查（非 debug，`\.faction_id\s*=[^=]|member_team_ids\.(append|erase|push_back)|member_team_ids\s*=`）：
  寫 team.faction_id：world_state.gd:583（set_team_faction 本體）——唯一（:463 是 FactionData 自己的 id）。
  加名冊：world_state.gd:586——唯一。減名冊：world_state.gd:582、:960（隊死）、faction_ai:5220（隊死）——都是【出】，不是入。
  create_faction（:458-472）走 set_team_faction（JOIN_CREATE_LEADER）；disband 走 set_team_faction（:520-522）。
  ✓ 0 條繞過。★誠實限：我沒搜字典／場景載入式的 `faction_id:` 初始化（game_setup 的 JOIN_SETUP 走 set_team_faction，是 reason 常數自己說的）；若要寫成「0 條」請在交件信補一條 `faction_id\s*:` 的普查。
erase 位置：放在 :569 的 `team.faction_id == fid` 早退【之後】（冪等，不洗）、只在 fid != -1 且有玩家時做（無玩家世界要早退，否則 world-fp 會被動；fingerprint 吃 player_hostile_teams：state_fingerprint.gd:262）。
JOIN_SUBTEAM_INHERIT 也會走到（玩家派出的子隊繼承母隊勢力）——erase 無害但要在 Probe 分開記，免得把『子隊繼承』算成『收編/結盟後清敵對』。
NPC 背叛玩家後「重新標」的寫者：只有 interaction_system.gd:278（路徑 1：npc.combat_target == 玩家隊 ⇒ 預備遭遇戰時 append）。
  ✗ 它被 `if state.player_pre_encounter.is_empty()`（:273）包住——已有預備遭遇戰時第二個攻擊者【不標】。S3 的「TeamX 背叛再打 ⇒ 重新標」要在 pre_encounter 為空的佈置下才綠，請寫進夾具前提。
  ✗ NPC 的背叛本身（_execute_betrayal，diplomatic_ai_system.gd:584-591）不標敵對；只有它後來攻擊才標。S3 的順序要寫「背叛 → 攻擊 → 才標」，不是「背叛 ⇒ 標」。
  玩家側寫者：player_command_system.gd:1021（攻擊）、:1416（背叛離團標原勢力全員）——:1416 是玩家背叛，不是 NPC 背叛玩家（你問的區分正確）。
讀者不止威脅欄（你寫「威脅欄讀者不改」，但源頭 erase 會同時改這些）：
  message_system.gd:192-193 _decide_exchange_mode：敵對收方 ⇒ 30% 惡意／否則沉默；同勢力才走 :194 honest ⇒ erase 後 NPC 對這隊的情報交換從「惡意／沉默」變「誠實」，且少一次 randf()
  inquiry_system.gd:125（ask_enemy_movement 的權重隨集合是否空）｜sim_bridge.gd:357｜sim_runner.gd:855｜player_api_mapper.gd:973,1279,1288 is_hostile
  ⇒ S3 加兩格：mapper is_hostile 為 false；同格交換 mode 為 honest。這是預期的改變，要被看見。
```

# 2 必改清單（阻擋）

## M1（§6b）收編事件：不要換通道，補 subjects；加停點；旁觀句別當成玩家佇列的斷言
```
事實：message_system.gd:40-67 emit_message【本來就】呼 WorldEvents.emit（:59，wake_thinking=true），subjects 由 params 鍵尾（"…team"/"…team_id"/"origin_team"/"target"）推：
      現在 params 是 origin/loser/faction，沒有一個符合 ⇒ subjects＝[勝方] ⇒ 玩家是勝方才進佇列（這就是真玩看到「Team15：臣服」主詞反了的來由）。
      同時它還做：msg 進 state.global_messages（:62）、team_known[勝方]（:65），訊息型別 subjugate 有 TTL（message_system.gd:26 MSG_TTL_LONG）——這是資訊網那條通道，NPC 靠它聽到「誰臣服了誰」。
✗ spec 改法 6b「改走 WorldEvents.emit，不再 emit_message」⇒ 這條通道被拔掉（NPC 再也聽不到臣服新聞）＝無玩家世界也變，且 spec 沒有一句講。
✓ 最小改法：留 emit_message；params 加 "loser_team": loser_id（鍵尾命中 → subjects＝[勝方, 敗方]）、"_event_info": {founded, faction, winner, loser}（message_system.gd:58 本來就收）。
   describe 讀 _event_info 組句。這樣 NPC 通道逐位不變，只多喚醒敗方一隊（emit 的 pending_rethink/pending_think 是 subjects 全員——這是無玩家世界唯一的行為差，census 單列）。
✗ ADVANCE_STOP_KINDS（world_events.gd:118-120）沒有 "subjugate"——spec「玩家是勝方或敗方 ⇒ 進推進停點」要在這裡【加進集合】；stop_event_since（:123-133）只認 kind ∈ 集合 且 subjects 含玩家隊。
✗ 旁觀句「Team{loser} 臣服於 Team{winner}」在玩家佇列裡【到不了】：_player_perceives（:335-358）③他隊先不放行，只放自家隊與同勢力。NPC 對 NPC 的臣服玩家本來就看不到 ⇒ S2「NPC 對 NPC ⇒ 旁觀句、不停」不能斷言在 player_events 上；
   要斷言在 describe() 的純函式輸出（觀察者那份 observer_event_text.gd:42-46 用得到）。同勢力盟友臣服別人（subjects 含同勢力隊）才會進玩家佇列，那一格才是真旁觀句，S2 補它。
✗ 玩家是敗方：_try_subjugate 的 NPC 呼叫點(:473/:575)排除的只是『勝方是玩家』(:466)，敗方是玩家隊的路徑我沒查到會發生（遭遇戰勝負走 encounter_system 不走 _try_subjugate）。
   「你被 Team{winner} 收編」這句請先證明有路徑到得了（file:line），否則是死句；到不了就拿掉，不要為它寫夾具。
```

## M2（§6a）can_subjugate 不能依賴 block_reason；理由要走 precheck
```
事實：選單兩處都只讀 `last_encounter_result.can_subjugate`——GUI encounter_view.gd:199（加「J:收編敗者」）與 :1008（「[J]收編敗者」）；precheck_subjugate_enemy（player_command_system.gd:598-602）也是 `not can_subjugate ⇒ "無可收編的敗者"`。
✗ spec「can_subjugate 由 block_reason 算（玩家勝 且 空字串）」⇒ 理由非空時 can_subjugate=false ⇒ GUI 整行不列、precheck 回的是「無可收編的敗者」而不是「要有統領才能收編」。
   與同一段的「戰後選單在不可收編時照列但標理由」自相矛盾；S1 的預期（標理由）做不到。
✗ 另一個陳舊：can_subjugate 是戰鬥結束那一刻寫死的快照（encounter_system.gd:1366-1375），選單可以開很多 tick；用快照存理由字串就是第二份帳。
⇒ 改法：can_subjugate 維持「玩家是勝方」（不動、GUI 照列）；理由只由 precheck_subjugate_enemy 現算（呼 block_reason(…, false)），_action_subjugate_enemy 與選單的標註都讀它——『列的條件＝做的條件』同一支。
   encounter_view 兩處要標理由：把 precheck.reason 帶進 hint（GUI 與終端選單各一處）。S1 的負對照改成：precheck 不呼 block_reason ⇒ S1 紅。
```

## M3（§4）十支整支跳過＋刪『記帳照跑』（見 §1②）
## M4（§2）strategic_assignments 清法改成狀態無關（見 §1③）

## M5 census：「有玩家世界逐項相同」是必紅的判準，改掉
```
· 跳過對玩家隊的 AI 呼叫會【少耗 randf】：try_proactive_diplomacy 入口就是一個 `randf() < 慎重³`（diplomatic_ai_system.gd:168）、consider_betrayal 之類同理；全域 RNG 序列在玩家世界從第一次跳過起整個位移，
  之後每一個 NPC 的骰都換了 ⇒ 『NPC 勢力 goals 分佈、提案數、side 十支次數修前修後逐項相同』在有玩家世界裡【構造上不可能】，不同也不代表洩到 NPC（預寫的「停」會被誤觸發，同 feedback_prewritten_verdict）。
⇒ 判準拆開：①無玩家世界（player_id==-1）：逐項相同、world-fp 不變（硬）。②有玩家世界：NPC 勢力【不含玩家勢力】的分佈做『同量級』比較（3 seed 的區間重疊），並印出差異，不判逐位；玩家勢力本身的變化＝預期。
  守衛放在 `player_controlled` 之後所以無玩家世界 0 變——但 §M1 的『多喚醒敗方』是例外：NPC 對 NPC 臣服在無玩家世界也會多喚醒敗方，這格要在 ① 裡明說是已知的唯一差並量它（次數 ≈ subjugate 次數）。
· 另：intent={} 後 manpower:53 的處置分布（§1①）在有玩家世界必差，同上處理。
```

# 3 其餘（不擋）
```
· 擋 try_proactive_diplomacy 入口（你的改法 3）✓ 方向對；唯一 production 呼叫點是 faction_ai_system.gd:1389（grep 全 simulation），盟主以外沒人被呼到。
  守衛請放在 :168 的 randf【之前】（整支不耗 RNG）；寫在 :163-164 之後也可，但要在 spec 裡講『放在骰之前』。
· ✗ 鄰近的 #12 洞（你寫「BETRAY 迴圈成員自己的腦照跑」）：對【NPC 成員】成立；但迴圈（faction_ai:1411-1417）對所有非盟主成員跑 consider_betrayal，
  玩家的隊若是 NPC 勢力的成員，AI 會替它決定背叛離團（_execute_betrayal ⇒ clear_team_faction，diplomatic_ai_system.gd:584-586；betrayal_assessment 全檔無 possessed／player_controlled 判斷：grep 回 0）。
  這是同一條 #12（AI 改玩家的勢力身分）、同一個迴圈、一行 `member_team.player_controlled ⇒ continue`。不是 WHAT，是不變量的執法點——建議併進本票或明確記 known_issues，請你擇一；我不在這裡裁。
· f.goals 的其他讀者你沒列（不擋）：faction_ai:729（'攻擊' in goals ⇒ 非私仇）、:3469、:3580；goals 空 ⇒ 這幾處走空分支，與『成員沒有勢力義務加權』一致 ✓。state_fingerprint.gd:437 吃 f.goals ⇒ 玩家世界 fp 必變，spec 已預期。
· `_rebuild_goals` 的早返回放在 :1935 leader_team==null 之後、:1939 override 之前 ✓ 符合『is_player_led 才需要 leader』；override 非空時你本來就放它——但 override 在『玩家交出盟主』後仍留在 f.player_goal_override 驅動 NPC 勢力（既有行為，建議記 known_issues，不在本票）。
· 面板（改法 7）：還沒做的盟主動作清單由 mapper 給 ✓；請同時鎖住『非 player_led 的玩家成員看不到 AI 目標以外的欄』— 無異議。
· 收編 S2「founded」：founded 為真＝本次呼叫才 create_faction（npc_combat_system.gd:844-845）；payload 只放 bool／id／faction，不放相對時間 ✓。
```

# 4 判決
```
verdict: issues
必改：M1（收編事件留 emit_message＋補 subjects＋加停點＋旁觀斷言改 describe）、M2（precheck 走理由、can_subjugate 不動、玩家路徑不帶 on_captured_tile）、M3（十支整支跳過、刪 ledger 兩支的『記帳照跑』與拆法）、M4（strategic_assignments 清法無狀態化＋三格）、M5（census 判準拆兩層）
同版補：§1① intent={}＋manpower 處置分布；§1⑤ S3 兩格（is_hostile、交換 mode）與 pre_encounter 空的佈置、erase 在早退之後且無玩家要早退、Probe 分 JOIN_SUBTEAM_INHERIT；§3 betray 迴圈那一行（擇一）
我想再看一眼：M1 與 M4 的改法（貼進交件信或回我一封短信）；其餘照 spec 修就好，不需再審
```
