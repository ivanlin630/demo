# 你領導的勢力不自動定目標＋收編要告訴你——HOW

狀態：待 R²
來源：藍圖票 2026-10-14-blueprint-to-systems-TICKET-player-led-faction-has-no-ai-goals-rule-12-at-faction-level（用戶裁「1」嚴格延伸）＋2026-10-14-…-TICKETS-live-play-findings…§4（收編三件，同一面板併本票）
順位：玩家可見批尾（第 7 張戰後收尾之後；與真玩小修並列，誰先寫完誰先派）。
不變量：#12 勢力層那句已在 invariants.md（2026-10-14 補），本票是它的執行。

## 事實（main 048f526c5；survey 後我逐條抽驗過標 ✔ 的）
- 謂詞：附身隊 `team.possessed`；`TeamData.player_controlled`（附身隊＋玩家派出的子隊，唯一寫者 `WorldState.sync_possession`）。
- **目標**：`_update_goals` 外殼（faction_ai_system.gd:1900-1910）→ `_rebuild_goals`（:1931 ✔）每勢力每小時跑；**無附身 guard**；只有 `player_goal_override` 非空時放那一個（:1939 ✔）。其餘依盟主人格產 緊急徵收（:1955）、立國（:1965）、攻擊（:2012）、外交（:2021）、守成徵收（:2018-2069）、戰爭基金徵收（:2006）；並重選 `f.intent`（:1978-1991）。
- **目標的消費者**：
  - 盟主本人：`_assign_tasks` :3428 → `_decide_unified`，入口 `if team.possessed: return`（:3497 ✔，附身隊三件）⇒ 附身盟主不會自己接目標。
  - 成員：`_assign_member_tasks` :3430 → 每支 NPC 成員自己的 `_decide_unified`，`faction_stakes` 從 `f.goals` 取（decision_context.gd:1131-1145）⇒ **AI 產的目標會變成成員的「勢力義務」加權**（徵收→TASK_TRIBUTE、外交→TASK_DIPLOMACY、攻擊）。
  - 立國：`_assign_tasks` :3422 讀 `"立國" in f.goals` → `_declare_established` :7921。
  - `strategic_ai_system.gd`：:85-113 讀 `f.intent` 寫 `strategic_goals`；`_assign_encirclement`（:175，由 :54 呼）對**所有成員**寫 `strategic_assignments`、`_assign_breakout`（:57）；sim_runner.gd:1100-1102 每小時對全部勢力跑；**全檔無附身 guard**。
  - `manpower_system.gd:53` 讀 `f.intent.type`。
- **勢力名義外交**：faction_ai_system.gd:1387-1389 ✔ 每 FACTION_UPDATE 以盟主隊當 sender 呼 `DiplomaticAiSystem.try_proactive_diplomacy`（diplomatic_ai_system.gd:162）⇒ propose_alliance（:186）／demand_tribute（:204）；**sender 端無附身 guard**（:215-228 只處理「目標是玩家」）。
- **盟主側動詞**：`info_side_dispatch_all`（:2837 ✔，sim_runner.gd:1090）對每支非子隊、非戰鬥隊每日一次跑十支（:2846-2855 ✔），**迴圈與十支皆無附身 guard**：
  `_try_promote_advisor`（提拔）、`_try_herald_side`（信使）、`_try_scout_side`（斥候）、`_try_distribute_side`（分糧，→`_dispatch_convoy`）、`_ensure_holding_ledger`（村監看帳）、`_try_migrant_side`（移民）、`_try_invest_side`（投資）、`_try_relocate_order`（下遷村令）、`_try_self_relocate`（村自願遷，:3150 排除盟主）、`_step_contact_ledger`（失聯帳＋care／ignore）。
  ★這支迴圈不只管盟主：**獨立的附身隊**也每天跑這十支 ⇒ 同一個 #12 違反，不限勢力層。
- **徵收率**：`FactionData.tribute_rate` 初值 0.10（faction_data.gd:8）；唯一寫者＝玩家指令（player_command_system.gd:1161 ✔）⇒ 「不自動調」**今天已成立**。實收在 `_resolve_tribute`（interaction_system.gd:713），只在收方接了 TASK_TRIBUTE 且與付方同格時發生；徵收**目標**只負責把隊拉進 TASK_TRIBUTE。
- **收編**：
  - 玩家路：encounter_system.gd:1366-1374 ✔ `can_subjugate = 玩家是勝方`（**只看這一條**）→ `_action_subjugate_enemy`（player_command_system.gd:1374）→ … → `_try_subjugate`（npc_combat_system.gd:832）。
  - `_try_subjugate` 另有門：不在佔領格時要 **敗方獨立且勝方有「統領」tag**，否則**靜默 return**（:841-842 ✔）；而指令 :1387 ✔ 不論成敗回「收編 TeamN」⇒ **列≠做、而且做不成還說做了**。
  - 勝方無勢力 ⇒ `create_faction`（:845 ✔）**不發任何事件**；玩家就這樣成了盟主而畫面沒說（真玩 ★4）。
  - 事件 `subjugate` 用 `_msg.emit_message(..., winner, ...)`（:859-864 ✔）⇒ 主詞＝勝方；`WorldEvents` 標籤「臣服」（world_events.gd:100 ✔）⇒ 玩家看到「Team15：臣服」——主詞反了。text_bank 的 honest 句「Team{origin} 主服 Team{loser}…」字也錯（「主服」）。
  - **威脅欄**：mapper `map_threat_line`（:939）在 :973 ✔ 只看 `state.player_hostile_teams.has(g)`；該集合的寫者三處（玩家攻擊 player_command_system.gd:1021、背叛 :1416、NPC 攻擊 interaction_system.gd:278），**全 scripts 無移除** ⇒ 收編進自己勢力的隊永遠標「敵對」。
- **面板**：mapper `map_faction_panel`（:1009）`faction_goal = ", ".join(f.goals)`（:1056）；text_ui_main.gd:2827-2830 印「AI 目標: …　玩家目標: （跟隨 AI）」。

## 謂詞（一支）
`FactionAiSystem.is_player_led(state, f) -> bool` ＝ 盟主隊存在且 `player_controlled`。下面所有勢力層的擋都呼它，不各寫一份。隊層的擋直接讀 `team.player_controlled`。

## 改法
1. **目標不自動產**（WHAT 1）：`_rebuild_goals` 在 clear 之後、讀人格之前：`is_player_led` ⇒ `player_goal_override` 非空就放它，**然後 return**（不跑緊急徵收、立國 gate、intent 重選、戰爭基金、分解）。`f.intent` 設成固定的 `{"type":"守成","target_id":-1,"why":"player_led"}`、`f.strategy = "玩家領導"`（下游 strategic_ai／manpower 不讀空字典；headless `_test_strategic_reads_ladder` 那條契約見 :1972-1976 註解）。外殼的 `directive_change_tick` 照舊（goals 沒變就不蓋）。
   - 成員照常（WHAT 5）：成員的 `faction_stakes` 從 `f.goals` 取 ⇒ goals 空＝成員沒有勢力義務加權，各自的腦照跑；玩家設了目標 ⇒ 成員照那一個加權（那是玩家的令）。
   - 立國不自動：`_declare_established` 只由 goals 的「立國」觸發 ⇒ 1 擋掉就不會發。玩家沒有立國動詞 ⇒ 面板列「還沒做」。
2. **戰略層不替玩家排**：`strategic_ai_system` 每勢力那一圈在 `is_player_led` 時整個跳過（不寫 `strategic_goals`、不對成員寫 `strategic_assignments`）；且**清掉**該勢力成員身上既有的 `strategic_assignments`（玩家剛成為盟主那一刻殘留的 NPC 時代指派，比照附身隊三件「附身時撤殘單」，在同一個 false→true 邊做——`sync_possession` 偵測到某勢力的盟主隊變 player_controlled 時）。
3. **勢力名義外交不自動提**（WHAT 3）：`try_proactive_diplomacy` 入口 `sender.player_controlled` ⇒ return（擋在函式不擋在 :1387，獨立附身隊將來被別處呼到也擋）。收到提案的找上門流程不動。BETRAY 迴圈（:1409-1417）＝成員自己的腦，照跑。
4. **盟主側動詞不自動發**（WHAT 4）：`info_side_dispatch_all` 迴圈 `team.player_controlled` ⇒ 只跑**記帳**那幾支、跳過**決策**那幾支。我的分類（實作端用三問核：①替玩家決定做什麼／派誰？②動了玩家的資源或人？③結果被別的決策讀？任一是＝決策）：
   | 支 | 類 | 處置 |
   |---|---|---|
   | `_try_promote_advisor` | 決策（拿人） | 跳過；玩家有提拔動詞（verb-catalog「提拔」） |
   | `_try_herald_side`／`_try_scout_side` | 決策（派人） | 跳過 |
   | `_try_distribute_side` | 決策（送糧車隊） | 跳過 |
   | `_try_migrant_side`／`_try_invest_side`／`_try_relocate_order` | 決策（派人／送料／下令） | 跳過 |
   | `_try_self_relocate` | 村自己的腦 | 已排除盟主（:3150）；玩家隊不是村 ⇒ 不動 |
   | `_ensure_holding_ledger` | 記帳（建監看條目） | 照跑 |
   | `_step_contact_ledger` | **混合**：逾時→失聯 belief＝記帳；care／ignore 反應＝決策 | 實作端拆：玩家隊只跑 belief 那半；拆不乾淨就整支照跑並在交件信列出 care 那半寫了什麼（不准為了拆而改 NPC 行為——NPC 路逐位相同） |
   - 範圍：擋的是 `player_controlled` 的隊——**勢力盟主與獨立附身隊同一刀**（後者是同一條 #12 違反，只是今天沒人看到）。
5. **徵收率**（WHAT 2）：不改 code。今天唯一寫者就是玩家；成立勢力時初值＝`FactionData` 預設 0.10，面板照印。床斷言 30 天恆等。
6. **收編三件**（併本票）：
   a. **列＝做**：把 `_try_subjugate` 的前置門抽成一支 `NpcCombatSystem.subjugate_block_reason(state, winner, loser, on_captured_tile) -> String`（空＝可）；`can_subjugate` 由它算（玩家勝 **且** 空字串）；`_action_subjugate_enemy` 先呼它，不空 ⇒ 回 `{ok:false, msg: 理由}`，不再無條件回「收編 TeamN」。理由句：「要有統領才能收編」「Team{loser} 已屬勢力{f}，不能收編」。戰後選單在不可收編時照列但標理由（比照行動稽核「列的條件＝做的條件」寫法，不藏）。
   b. **事件主詞與句子**：`subjugate` 改走 `WorldEvents.emit`（與第 7 張 `combat_end` 同管道，不再 `emit_message` 單主詞），subjects＝[敗方, 勝方]；payload 加 `founded: bool`（本次呼叫才 `create_faction` 的為真）。`WorldEvents.describe` 產句：
      - 玩家是勝方：`founded` ⇒「你收編了 Team{loser}，成立勢力{f}，你是領袖」；否則「你收編了 Team{loser}，它加入你的勢力{f}」。
      - 玩家是敗方：「你被 Team{winner} 收編，加入勢力{f}」。
      - 旁觀：「Team{loser} 臣服於 Team{winner}，加入勢力{f}」。
      - text_bank honest 句「主服」改「臣服於」（觀察者那份 observer_event_text.gd:42-46 同改）。
      - 玩家是勝方或敗方 ⇒ 進推進停點（它改了玩家的身分）；其餘不停。
   c. **敵對帳跟著勢力走**：在 `WorldState.set_team_faction`（唯一的入勢力咽喉，收編／求投靠／結盟整併都走）加：入勢力後，若入的是玩家隊所在的勢力 ⇒ `player_hostile_teams.erase(該隊)`；若入勢力的是玩家隊本身 ⇒ erase 新勢力的所有成員。威脅欄讀者不改（源頭修，讀者不另加同勢力排除——一份帳一個寫法）。之後再打起來由既有三個寫者重新標。
7. **面板**（WHAT 6）：`map_faction_panel` 加 `player_led: bool`、`missing_leader_verbs: Array`；text_ui_main `_build_faction_str`：
   - player_led：「目標：無（等你下令）」或「目標：{override}（你設的）」；**不再印「AI 目標」那欄**。
   - 非 player_led（玩家是成員）：「勢力目標：{goals}」，不印「玩家目標」。
   - 「還沒做的盟主動作：立國、派信使、派斥候、分糧、移民、投資、遷村、以勢力名義提外交」——清單由 mapper 給，實作端逐項對 player_command_system 的 action 表核，有玩家指令的（例：提拔）不列；交件信貼核對表。
8. **可觀測**（WHAT 7）：Probe `faction.goals_rebuild_player_led`（1 的分流次數）、`strategic.skip_player_led`、`diplo.skip_player_controlled`、`side.skip_player_controlled.<支>`、`subjugate.blocked.<理由>`、`hostile.erase_on_join`。

## 驗收（新床 `player_led_faction_bed.gd`，acceptance，註冊表登一列）
佈置：附身隊當盟主、兩支 NPC 成員的勢力（床直接建，不靠收編撞到）；對照：同世界一個 NPC 盟主勢力。玩家 30 天不按鍵。
- F1 goals：玩家勢力每 tick `goals` 恆空；對照勢力 30 天內 goals 非空 >0 次。
- F1b override：玩家設「防禦」⇒ goals＝["防禦"] 恆定 30 天、成員 faction_stakes 讀到它。
- F2 徵收率恆 0.10（玩家不按）；對照：玩家按 [B] 設 30 ⇒ 0.30。
- F3 以玩家盟主隊為 sender 的提案 0 次；對照勢力 >0。
- F4 玩家勢力成員 `strategic_assignments` 30 天 0 寫入；佈置「成為盟主前已有指派」⇒ 成為盟主那一 tick 清空。對照勢力成員 >0。
- F5 盟主側十支：決策那七支對玩家隊 0 次（各一個 probe 計數）；記帳兩支照跑 >0；對照 NPC 盟主各 >0（陽性對照不足 >0 的那支照實印「不可判」，不湊）。
- F5b 獨立附身隊（不在勢力）：同 F5。
- F6 成員照常：玩家勢力兩支成員 30 天內 `_decide_unified` 次數 >0、有任務變化。
- S1（修前紅）收編列＝做：玩家勝、無統領、敗方獨立 ⇒ 戰後選單收編標「要有統領才能收編」、按下回 ok=false、勢力數不變；有統領 ⇒ 成功。
- S2（修前紅）主詞與成立：玩家勝且無勢力 ⇒ 事件句「你收編了 TeamX，成立勢力N，你是領袖」、推進停在這一則；已有勢力 ⇒「…它加入你的勢力N」；NPC 對 NPC ⇒ 旁觀句、不停。
- S3（修前紅）威脅：先攻擊 TeamX（標敵對）→ 收編 ⇒ 頂列威脅欄不含 TeamX；之後 TeamX 背叛再打 ⇒ 重新標。
- P1 面板：player_led 印「目標：無（等你下令）」與「還沒做」清單、不含「AI 目標」；玩家當成員 ⇒「勢力目標」。
- 負對照（各拔一刀）：1 的 return ⇒ F1 紅；strategic 跳過 ⇒ F4；外交入口 ⇒ F3；side 迴圈 ⇒ F5／F5b；`subjugate_block_reason` 不接 can_subjugate ⇒ S1；set_team_faction 不 erase ⇒ S3。
- census（先量再改，3 seed×30 天、無玩家世界＋有玩家世界）：NPC 勢力 goals 分佈、外交提案數、side 十支次數修前修後**逐項相同**（本票只動玩家路；不同＝洩到 NPC，停）。
- world-fp：無玩家世界應不變；變了做二分交件信寫清。
- terminal E2E 綠。

## 範圍外
- 顧問制（每日建議、接受／拒絕）：顧問票。
- 玩家的立國／信使／斥候／分糧／移民／投資／遷村／勢力外交動詞：面板列「還沒做」，各自另開。
- 據點稅 `ResourceSystem.tax_rate_for`（resource_system.gd:523-536）對附身隊仍由人格每次重算寫 `owner.tax_rate`：同族 #12 違反，但玩家沒有調稅動詞（擋了就凍在預設 0.3）⇒ 本票不動，記 known_issues，等調稅動詞一起做。
- `FactionData.relations` 無寫者（mapper :920 註）：關係帳另案。
