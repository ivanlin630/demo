# 你領導的勢力不自動定目標＋收編要告訴你——HOW

狀態：**GO**——R² 第一輪 ISSUES 全改、第二輪 M1／M4 CLEAN（2026-10-15-reviewer-to-systems-R2b-player-led-faction-m1-m4-CLEAN），兩條小註照字面收進改法 2 與謂詞段
來源：藍圖票 2026-10-14-blueprint-to-systems-TICKET-player-led-faction-has-no-ai-goals-rule-12-at-faction-level（用戶裁「1」嚴格延伸）＋2026-10-14-…-TICKETS-live-play-findings…§4（收編三件，同一面板併本票）
順位：玩家可見批尾（第 7 張戰後收尾之後；與真玩小修並列，誰先寫完誰先派）。
不變量：#12 勢力層那句已在 invariants.md（2026-10-14 補），本票是它的執行。

## 事實（main 74d7c54af；R² 逐條重驗）
- 謂詞：附身隊 `team.possessed`；`TeamData.player_controlled`（附身隊＋玩家派出的子隊，唯一寫者 `WorldState.sync_possession`）。
- **目標**：`_update_goals` 外殼（faction_ai_system.gd:1900-1910）→ `_rebuild_goals`（:1931）每勢力每小時；**無附身 guard**；只有 `player_goal_override` 非空時放那一個（:1939）。其餘依盟主人格產 緊急徵收（:1955）、立國（:1965）、攻擊（:2012）、外交（:2021）、守成徵收、戰爭基金徵收（:2006）；並重選 `f.intent`（:1978-1991）。
- **目標／intent 的讀者**：
  - 盟主本人 `_decide_unified` 入口 `if team.possessed: return`（:3497）⇒ 附身盟主不接目標。
  - 成員 `faction_stakes` 只讀 `f.goals`（decision_context.gd:1131-1145）；`f.intent` 只給盟主隊（:1156-1162）。
  - `f.intent` 其餘讀者：faction_ai :137-139 `_intent_sig`、:1868 committed 滯後、:3583 probe；strategic_ai :96-97；manpower_system.gd:51-56（**成員隊當 holder 時**取 intent.type 給厚待加權）——全是 `.get`／`is_empty` 保護，faction_ai:1993-1994 對空字典當守成用。
  - `f.goals` 其他讀者：faction_ai :729、:3422（立國 → `_declare_established`）、:3469、:3580；state_fingerprint.gd:437。
  - `strategic_ai_system.gd`：每勢力寫 `strategic_goals`、對成員寫 `strategic_assignments`（:175 起）；同一支也負責清（:127-139 無 expand 逐隊 erase、:214-235 突圍單 erase）。consumer：sim_runner `_step2a_strategic_move`（:870-891）對**非** player_controlled 隊吃 assignments；task_arbiter.gd:94 對 player_controlled 隊本來就擋。
- **勢力名義外交**：唯一呼叫點 faction_ai_system.gd:1389，以盟主隊當 sender 呼 `try_proactive_diplomacy`（diplomatic_ai_system.gd:162）；:168 有 `randf() < 慎重³`；sender 端無附身 guard。
- **BETRAY 迴圈**（faction_ai:1411-1417）對所有非盟主成員跑 `consider_betrayal`；玩家隊若是 NPC 勢力成員 ⇒ AI 替它決定背叛離團（`_execute_betrayal` ⇒ clear_team_faction，diplomatic_ai_system.gd:584-586；全檔無 possessed／player_controlled 判斷）＝同一條 #12。
- **盟主側十支**：`info_side_dispatch_all`（:2837，sim_runner.gd:1090）對每支非子隊、非戰鬥隊每日一次跑十支（:2846-2855），迴圈與十支皆無附身 guard。
  - `_step_contact_ledger`（:8217-8255）沒有記帳半：逾時只 `Probe.bump` 與寫 `entry["lost"]`（零讀者）；反應 `_apply_contact_reaction`（:8284-8303）全是派人／寫警戒＝決策。ledger 的寫者全是 AI 派遣（:3262、:3320、:5870、:8190）。
  - `_ensure_holding_ledger` 的條目唯一讀者是上面 holding 分支 ⇒ 同進退。
  - `_try_self_relocate` 只排除 faction_id==-1（:3147）與盟主（:3150）；玩家隊若是 NPC 勢力的非盟主成員且紮根 ⇒ 走 `_begin_village_relocate`，:2978 先棄據點、:2984 寫 extra，arbiter 才擋 :2985/:2988 ⇒ 據點丟了而遷移沒發生。
  - ⇒ 這個迴圈對獨立附身隊、NPC 勢力裡的玩家成員隊也照跑——同一條 #12。
- **徵收率**：`FactionData.tribute_rate` 初值 0.10（faction_data.gd:8）；唯一寫者＝玩家指令（player_command_system.gd:1161）⇒ 「不自動調」今天已成立。
- **收編**：
  - 玩家路：encounter_system.gd:1366-1375 `can_subjugate = 玩家是勝方`（戰鬥結束那一刻的快照）；選單 encounter_view.gd:199（GUI「J:收編敗者」）、:1008（終端「[J]收編敗者」）讀它；precheck_subjugate_enemy（player_command_system.gd:598-602）`not can_subjugate ⇒ "無可收編的敗者"`。
  - 指令 → InteractionSystem.subjugate_team（interaction_system.gd:583）→ NpcCombatSystem.subjugate_team（npc_combat_system.gd:244-245）→ `_try_subjugate(state, winner, loser)`（三參數，on_captured_tile 預設 false；true 只有 :473／:575，且 :466 排除玩家勝方）⇒ 玩家路恆 false。
  - `_try_subjugate` 的門：:841 `loser.faction_id != -1 or not winner.tags.has("統領")` ⇒ 靜默 return；:845-846 立國失敗／已同勢力 ⇒ return。指令 :1387 不論成敗回「收編 TeamN」⇒ 列≠做、做不成還說做了。
  - 勝方無勢力 ⇒ `create_faction`（:845）不發事件。
  - 事件：`_msg.emit_message(..., winner, {origin, loser, faction})`（:859-864）。emit_message（message_system.gd:40-67）本來就呼 `WorldEvents.emit`（:59）並把訊息放進 global_messages／team_known（資訊網通道，TTL :26）；subjects 由 params 鍵尾推（"…team"／"…team_id"／"origin_team"／"target"），origin/loser/faction 都不命中 ⇒ subjects＝[勝方] ⇒ 玩家看到「Team15：臣服」。text_bank honest 句寫「主服」。
  - `ADVANCE_STOP_KINDS`（world_events.gd:118-120）無 subjugate。`_player_perceives`（:335-358）只放自家隊與同勢力 ⇒ NPC 對 NPC 的臣服本來就進不了玩家佇列。
  - 「玩家是敗方被收編」：遭遇戰勝負走 encounter_system，`_try_subjugate` 的 NPC 呼叫點只排除勝方是玩家——**沒有找到敗方是玩家的路徑** ⇒ 本票不寫那一句。
- **敵對帳**：`state.player_hostile_teams` 寫者三處（玩家攻擊 player_command_system.gd:1021、玩家背叛 :1416、NPC 攻擊 interaction_system.gd:278——後者被 :273 `player_pre_encounter.is_empty()` 包住），無移除。入勢力咽喉：`team.faction_id` 唯一寫者 world_state.gd:583、名冊加入唯一 :586，都在 `set_team_faction`（R² 普查 0 繞過）。讀者：mapper :973（威脅欄）、:1279、:1288 is_hostile；message_system.gd:192-193 交換模式（敵對 ⇒ 30% 惡意／沉默）；inquiry_system.gd:125；sim_bridge.gd:357；sim_runner.gd:855；state_fingerprint.gd:262。
- **面板**：mapper `map_faction_panel`（:1009）`faction_goal = ", ".join(f.goals)`（:1056）；text_ui_main.gd:2827-2830 印「AI 目標: …　玩家目標: （跟隨 AI）」。

## 謂詞（一支）
謂詞本體放 **data 層** `WorldState.is_player_led(f) -> bool` ＝ 盟主隊存在且 `player_controlled`（`set_team_faction` 在 data 層要用）；`FactionAiSystem.is_player_led(state, f)` 只是呼它的薄殼。全專案一支，不內聯第二份。勢力層的擋都呼它；隊層的擋直接讀 `team.player_controlled`。

## 改法
1. **目標不自動產**：`_rebuild_goals` 在 :1935（leader_team==null 早退）之後、:1939 override 之前：`is_player_led` ⇒ override 非空就放它；`f.intent = {}`（**不寫守成**——寫了會在玩家交出盟主後被 :1868 committed 當既有承諾偏袒一次；空字典下游全有保護，等價於守成）；`f.strategy = "玩家領導"`；return。
   - 成員照常：goals 空＝成員沒有勢力義務加權；玩家設了目標 ⇒ 成員照那一個加權。
   - 立國不自動：只由 goals 的「立國」觸發 ⇒ 不會發。玩家沒有立國動詞 ⇒ 面板列「還沒做」。
   - 預期變化（census 印出來，不判相同）：manpower:53 對玩家勢力成員 holder 的厚待加權從此拿不到（intent 空）。
2. **戰略層：清成員再返回（狀態無關，不掛邊）**：`StrategicAiSystem.tick` 每勢力那一圈，`is_player_led` ⇒ 對 `f.member_team_ids` 逐隊 `strategic_assignments.clear()`（冪等）→ return（不寫 strategic_goals、不寫新指派）。
   - 這樣三條路都接得住：①附身成為盟主 ②盟主繼位交給玩家成員隊（world_state.gd:506 無 hook）③後入成員帶舊勢力指派進來；最長延遲 STRATEGIC_INTERVAL。
   - ②另補：`succeed_or_disband_faction` 設完 `leader_team_id`（:506）後，若新勢力 `is_player_led` ⇒ 呼**同一支**清成員函式（與 tick 共用，不另寫）⇒ 交接當 tick 清空。
   - 同咽喉補一刀：`set_team_faction` 入**玩家領導的勢力**時清該隊 assignments（與改法 6c 同一處），③就不必等一輪。
   - 整段跳過同時略過 `_evaluate_alliance_need`（只有 print）與 STRATEGIC／ALLIANCE 的 DecisionTier 戳記 ⇒ 玩家交出後該勢力第一輪立刻 due，可接受。
3. **勢力名義外交不自動提**：`try_proactive_diplomacy` 入口、**:168 的 randf 之前**：`sender.player_controlled ⇒ return`（整支不耗 RNG）。收到提案的找上門流程不動。
4. **BETRAY 迴圈**（R² §3，併本票）：faction_ai:1411-1417 迴圈內 `member_team.player_controlled ⇒ continue`——AI 不替玩家的隊決定背叛離團。NPC 成員照跑。
5. **盟主側十支：迴圈級整支跳過**：`info_side_dispatch_all` 迴圈頂端、`info_eval_next_tick` 戳記**之前**：`team.player_controlled ⇒ continue`（之前＝玩家交出後第一輪立刻評）。十支一網打盡，不分記帳／決策（記帳半不存在、holding 條目無別的讀者、self_relocate 會先棄據點）。玩家隊身上附身前的 NPC 殘 ledger 留著不動（無讀者，無害）。Probe `side.skip_player_controlled` 一個計數。範圍＝勢力盟主、獨立附身隊、NPC 勢力裡的玩家成員隊（同一條 #12、同一個迴圈）。
6. **收編三件**：
   a. **列＝做**：
      - 抽純門 `NpcCombatSystem.subjugate_block_reason(state, winner, loser, on_captured_tile) -> String`（空＝可），`_try_subjugate` 自己用它（NPC 路逐位相同）。
      - `can_subjugate` **不動**（維持「玩家是勝方」，選單照列）。
      - `precheck_subjugate_enemy` 在 can_subjugate 之後現算 `subjugate_block_reason(…, false)`（固定 false：玩家路恆不走佔村捷徑，:466；註解寫明，防有人傳 true 造成選單說可以、實際不能）；不空 ⇒ 回理由。
      - 理由兩句：「Team{loser} 已屬勢力{f}，不能收編」（含同勢力）、「要有統領才能收編」。
      - encounter_view 兩處（:199 GUI、:1008 終端）把 precheck 理由帶進該項（照列、標理由）。
      - `_action_subjugate_enemy` 在 `_try_subjugate` 之後**驗結果**（敗方 faction_id 已等於勝方勢力才回 ok:true），否則回 ok:false「收編沒有成功」——create_faction 失敗只有 :845 才知道，block_reason 預測不了，這一層補它。
   b. **事件：留 emit_message（資訊網通道不動），補 subjects＋停點**：
      - :859-864 params 加 `"loser_team": loser_id`（鍵尾命中 ⇒ subjects＝[勝方, 敗方]）與 `"_event_info": {founded, faction, winner, loser}`（message_system.gd:58 本來就收）；`founded`＝本次呼叫才 create_faction。
      - `WorldEvents.describe` 讀 `_event_info` 產句：玩家是勝方 ⇒ founded「你收編了 Team{loser}，成立勢力{f}，你是領袖」／否則「你收編了 Team{loser}，它加入你的勢力{f}」；其餘「Team{loser} 臣服於 Team{winner}，加入勢力{f}」。
      - text_bank honest 句「主服」改「臣服於」（observer_event_text.gd:42-46 同改）。
      - `ADVANCE_STOP_KINDS` 加 `subjugate`（stop_event_since 只認 subjects 含玩家隊的 ⇒ 玩家收編別人會停；盟友臣服別人進得了玩家佇列但 subjects 不含玩家隊 ⇒ 不停）。
      - 唯一無玩家世界行為差：多喚醒敗方一隊（emit 的 pending_rethink／pending_think 是 subjects 全員）⇒ census 單列（次數≈subjugate 次數）。
   c. **敵對帳跟著勢力走**：`set_team_faction` 在 :569 `team.faction_id == fid` 早退**之後**、只在 `fid != -1` 且 `state.player_id != -1` 時：入的是玩家隊所在勢力 ⇒ `player_hostile_teams.erase(該隊)`；入勢力的是玩家隊本身 ⇒ erase 新勢力全員。Probe 分開記：`hostile.erase_on_join.<reason>`（JOIN_SUBTEAM_INHERIT 單獨一桶，不混進收編／結盟）。讀者不改；預期跟著變的：威脅欄、mapper is_hostile、同格交換模式變 honest。之後再打起來由既有寫者重新標。
7. **面板**：`map_faction_panel` 加 `player_led: bool`、`missing_leader_verbs: Array`；`_build_faction_str`：
   - player_led：「目標：無（等你下令）」或「目標：{override}（你設的）」；不再印「AI 目標」。
   - 非 player_led（玩家是成員）：「勢力目標：{goals}」，不印「玩家目標」。
   - 「還沒做的盟主動作：…」清單由 mapper 給；實作端逐項對 player_command_system 的 action 表核，有玩家指令的（例：提拔）不列；交件信貼核對表。
8. **可觀測**：Probe `faction.goals_rebuild_player_led`、`strategic.clear_player_led`、`diplo.skip_player_controlled`、`betray.skip_player_controlled`、`side.skip_player_controlled`、`subjugate.blocked.<理由>`、`subjugate.action_failed_after_try`、`hostile.erase_on_join.<reason>`。

## 驗收（新床 `player_led_faction_bed.gd`，acceptance，註冊表登一列）
佈置：附身隊當盟主、兩支 NPC 成員的勢力（床直接建）；對照：同世界一個 NPC 盟主勢力。玩家 30 天不按鍵。
- F1 goals：玩家勢力每 tick `goals` 恆空、`intent` 恆空；對照勢力 goals 非空 >0 次。
- F1b override：玩家設「防禦」⇒ goals＝["防禦"] 恆定 30 天、成員 faction_stakes 讀到它。
- F2 徵收率恆 0.10；對照：玩家按 [B] 設 30 ⇒ 0.30。
- F3 以玩家盟主隊為 sender 的提案 0 次；對照勢力 >0。
- F4 strategic_assignments 清空：①附身成為盟主（佈置：成員先有指派）⇒ STRATEGIC_INTERVAL 內清空 ②NPC 盟主死、繼位給玩家成員隊 ⇒ **繼位那一 tick 清空**（succeed_or_disband 後呼清除）③NPC 隊帶指派入玩家勢力 ⇒ 當下清空。斷言的時窗與機制一致（不寫當 tick 卻只做 hour 級）。對照勢力成員 >0。
- F5 十支：各支入口的「被呼叫」計數對玩家隊 0；對照 NPC 盟主 >0（不足 >0 的那支印「不可判」，不湊）。
- F5b 獨立附身隊：同 F5。F5c NPC 勢力裡紮根的玩家成員隊：據點 owner 30 天不變（self_relocate 負對照會紅）。
- F6 成員照常：玩家勢力兩支成員 `_decide_unified` 次數 >0、有任務變化。
- F7 背叛：玩家隊當 NPC 勢力成員、佈置成 consider_betrayal 會想走 ⇒ 30 天仍在該勢力；對照同條件 NPC 成員會走。
- S1（修前紅）列＝做：玩家勝、無統領、敗方獨立 ⇒ 選單照列收編並標「要有統領才能收編」、按下 ok=false、勢力數不變；敗方屬別勢力 ⇒ 標「已屬勢力」；有統領 ⇒ 成功。
- S1b 做後驗：佈置 create_faction 失敗 ⇒ 回「收編沒有成功」。
- S2（修前紅）玩家勝且無勢力 ⇒ 玩家佇列有一則、subjects 含敗方、句「你收編了 TeamX，成立勢力N，你是領袖」、推進停在它；已有勢力 ⇒「…它加入你的勢力N」；同勢力盟友收編別人 ⇒ 進玩家佇列、旁觀句、不停。NPC 對 NPC 的旁觀句只斷言在 `describe()` 純函式輸出（玩家佇列本來就收不到）。
- S3（修前紅）敵對帳：先攻擊 TeamX（標敵對）→ 收編 ⇒ 威脅欄不含 TeamX、mapper is_hostile=false、同格交換模式 honest。之後 TeamX 背叛 → 攻擊（佈置 `player_pre_encounter` 為空）⇒ 重新標。順序是「背叛 → 攻擊 → 才標」，背叛本身不標。
- P1 面板：player_led 印「目標：無（等你下令）」與「還沒做」清單、不含「AI 目標」；玩家當成員 ⇒「勢力目標」。
- 負對照（各拔一刀）：改法 1 return ⇒ F1；strategic clear ⇒ F4 三格；外交入口 ⇒ F3；betray continue ⇒ F7；side continue ⇒ F5／F5b／F5c；precheck 不呼 block_reason ⇒ S1；action 不驗結果 ⇒ S1b；subjects 不補／停點不加 ⇒ S2；set_team_faction 不 erase ⇒ S3。
- census（先量再改，3 seed × 30 天）——判準分兩層：
  - ①**無玩家世界**：NPC 勢力 goals 分佈、外交提案數、十支次數、betray 次數修前修後逐項相同；world-fp 不變。**唯一已知差**＝收編多喚醒敗方（單列次數，≈subjugate 次數）；若 world-fp 因此變，做二分證明只差這一處。
  - ②**有玩家世界**：跳過玩家隊的 AI 呼叫會少耗 randf ⇒ 全域 RNG 位移，逐位相同構造上不可能。只比 NPC 勢力（不含玩家勢力）分佈是否同量級（3 seed 區間重疊），印差異、不判逐位；manpower:53 處置分布、玩家勢力本身的變化＝預期，印出來。
- terminal E2E 綠。

## 範圍外
- 顧問制（每日建議、接受／拒絕）：顧問票。
- 玩家的立國／信使／斥候／分糧／移民／投資／遷村／勢力外交動詞：面板列「還沒做」，各自另開。
- 據點稅 `ResourceSystem.tax_rate_for` 對附身隊仍由人格算：已記 known_issues，等調稅動詞。
- `player_goal_override` 在玩家交出盟主後仍留在勢力上、驅動 NPC 勢力：既有行為，記 known_issues。
- `FactionData.relations` 無寫者：關係帳另案。
- 「你被收編」：沒有玩家當敗方被 `_try_subjugate` 的路徑，不寫死句；將來有路徑時再加。
