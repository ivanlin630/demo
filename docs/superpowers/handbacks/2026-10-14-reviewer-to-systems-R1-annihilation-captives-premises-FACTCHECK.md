---
from: reviewer
to: systems
status: consumed
slice: R① 玩家可見批第 7 張前提（消滅三漏＋俘虜接帳＋追擊＋combat_end 玩家事件）
topic: R① factcheck ＝ **premise_contradiction: true（一條）**｜note 的『失能者從不寫回 wounded』不成立:resolve_encounter_end 對雙方呼 HealthSystem.resolve_anon_units → wound_random（encounter_system.gd:1216-1222→health_system.gd:165-200→anon_tier_system.gd:162）——你的 (a) 成立;(c) 的擔心不成立（kill_random 只從 healthy 桶移,anon_tier_system.gd:125）;(b) 有一格小縫:anon 單位因『血量昏迷』失能（encounter_system.gd:112-114）而 resolve_anon_units 不讀 unit["blood"] ⇒ 若該單位所有部位 healthy、無骨折且流血已被藥處理,會漏記;其餘 9 條逐條見下（U10b ✓ 已修、俘虜只是計數器 ✓、combat_end 玩家事件 ✓ 零、追擊/俘虜入口可重用但有兩個語意問題）
---

# 0 方法
讀 code,未跑世界;標 ✓成立／✗不成立／⚠成立但有縫。全部 file:line 取自 main 06cc47079。

# 1 漏②『失能者從不寫回 wounded』——✗ premise_contradiction
```
(a) 會不會走到:✓ 會。
   resolve_encounter_end（encounter_system.gd:1209 起）在 beast／draw／一般三條結算分岔【之前】就對 atk、def 各跑
   `_sync_back_units`→`HealthSystem.resolve_negative_flags`→`HealthSystem.resolve_anon_units(state, team_id)`（:1216-1222）。
   三條結算路都先過這一段,所以玩家遭遇戰（init_encounter 的四個玩家入口,見 #10）每場結束都會寫回。
   (未核:玩家『投降』『逃出場外』是否另有不經 resolve_encounter_end 的收場;我沒找到,但沒逐條追到 result 字串的所有產生者。)
   寫入點:health_system.gd:200 `AnonTierSystem.wound_random(team, wounded_count)`;anon_tier_system.gd:162 把 healthy→wounded 搬 n 人（回實際數,受 healthy 池上限約束）。
   TeamData.wounded 是 cohort 的計算屬性（你寫 team_data.gd:385 屬實）。
   ⇒ note 的『encounter 全檔零寫入』字面對（寫入在 HealthSystem),但結論『失能者不寫回』錯。
(b) 失能但沒被記成傷的格:⚠ 有一個縫。
   resolve_anon_units 的 injured 判準（health_system.gd:176-197）:有非 healthy 部位、有骨折、或有流血且無藥 ⇒ injured。
   is_combat_capable 為假的所有原因:死亡（排除）、has_exited、torso critical、雙腿 critical(⇒ 都是非 healthy 部位 ⇒ injured ✓)、
   以及【血量昏迷】:anon 單位 `unit["blood"] < BLOOD_COMA_THRESHOLD`（encounter_system.gd:112-114,註解自己寫『body parts 全 healthy 仍倒』）。
   昏迷單位若各部位 status 皆 healthy、無骨折、流血已被藥處理（has_bleed 且藥足 ⇒ 走 :186-188 不 injured）⇒ 不計入 wounded_count。
   resolve_anon_units 全函式不讀 unit["blood"]。縫的大小未量;機制上要同時滿足『血量低到昏迷』與『所有部位 status healthy』(輕傷多處流血可達),罕見但不為零。
   建議:量一格（失能數 − 入帳傷兵數,逐場列),不要靠這段推測;若有差,修法是 resolve_anon_units 把 `is_combat_capable==false 且非死亡` 一律算 injured（單一判準,而不是平行再列一份部位條件)。
(c) wound_random 先於 kill_random 會不會讓『該死的』先被標傷再被抽走:✗ 擔心不成立。
   kill_random（anon_tier_system.gd:120-146）註解與 code 都是『只移 healthy』(:125-131 只讀 `_key(tier,"healthy")`),所以先標的 wounded 不會被死亡抽走;
   順序是 resolve_anon_units（:1222,wound）→ 後面 :1258 `kill_random(t, dead_anon, "combat")`;wound 搬走的是 healthy 池的人,kill 再從剩下的 healthy 移。
   兩個不影響總數但影響『誰』的性質（anon 是匿名 cohort,本來就不追身份):
     ·wound_random 是對【整個 cohort】加權抽（含未上場的後備,anon_tier_system.gd:149-171 `_weighted_tier`),不是對上場那幾個;
     ·若 healthy 池小於 wounded_count（極端:全員幾乎都受傷),wound_random 因池空而少搬,入帳傷兵 < 失能數。
   ⇒ 『實際入帳 ≠ 失能數』的可能來源只剩這兩格（池上限、昏迷縫),都是小量;§1a 第一列的修法改寫成『量差多少』是對的。
```

# 2 逐條
```
2. U10b（known_issues:2356『玩家全隊死亡直接退出』）:✓ 已修,條目沒關。
   _check_player_wiped（encounter_system.gd:1410）在三條結算路尾都被呼（:1288 野獸、:1301 平手、:1403 一般）;條件 pt.population <= 0 ⇒ EventSystem.handle_player_succession（event_system.gd:79）:
   named_members 空 ⇒ state.game_over＝true＋reason（:87-89）,player_id≠-1 時再走 _npc_succession（:95）,【不是靜默退出】;有候選 ⇒ set_player_forced_event choose_heir（:96-100）。
   我只做靜態讀碼,沒跑;headless_test.gd 有引用（grep 命中 1 檔),請在關條目前跑一次該格確認綠。
   (補:玩家 leader 死但隊還有人時 population>0,_check_player_wiped 不觸發,leader 位由 loop3 `leader_id==-1 → on_leader_death` 補(faction_ai_system.gd:1553)——是另一條路,不是漏。)
3. 『死＝軀幹 severed』:✓ encounter_system.gd:101-103 is_dead;health_system.gd:202-203 _is_unit_dead_bp 同判準。
   遭遇【內】沒有別的死亡路:血量只造成昏迷（is_combat_capable false,:108-114),不是死;named 人員的流血至死/餓死在遭遇外（HealthSystem 日界 check_starvation_deaths 等)。
   遭遇結算時 named 的死亡寫回:encounter_system.gd:1226-1235（is_dead ⇒ dp.is_dead＝true,remove_member(…,false),leader 清空)。
4. 『俘虜進 prisoner_population 計數器、讀者只有指紋』:✓。
   全 scripts（排除 debug)對 prisoner_population:宣告 team_data.gd:130;唯一寫 encounter_system.gd:1324-1334(+= 1,上限 winner.population);唯一讀 state_fingerprint.gd:392。UI／manpower／糧耗無讀者。
   連帶事實（補):戰場上被標 is_prisoner 的是『失能且旁有敵人的單位』(encounter_system.gd:596-612 _check_prisoners),結算時【沒有任何人員搬移】——
   anon 被俘單位仍在 loser 的 cohort（經 wound_random 成 wounded),named 被俘者仍在原隊 roster;winner 只多一個計數。所以『俘虜接帳』要的是新入口,不是改計數。
5. 『居民處置讀攻方領袖人格自動決定,攻方是玩家時不問』:✓ encounter_system.gd:1390-1391 → 1437-1473（我與你讀到相同;未逐行複核人格欄位)。
6. 『combat_end 只在 npc_combat_system.gd:419 發』:✓,且 encounter 結算路整條沒有任何玩家事件。
   grep encounter_system.gd／beast_system.gd 對 WorldEvents.emit／emit_message／_msg./_feed 零命中;npc_combat_system.gd:419 的 _msg.emit_message(state,"combat_end",…) 與 :119 的 WorldEvents.emit "combat_engaged" 是 NPC 戰鬥的;
   health_system.gd:251 的 member_died emit 是另一個(成員死亡,進推進停點)。
   注意:『combat_end』在 MESSAGE_KINDS（world_events.gd:27)是【訊息】類;玩家事件佇列的唯一寫入點是 WorldEvents.emit→_feed_player,
   且 _player_perceives 要 subjects 含玩家隊（world_events.gd:288)。給玩家戰場新增的 combat_end 玩家事件要走 WorldEvents.emit（subjects 含玩家隊),不要沿用 emit_message(那是 NPC 訊息傳播通道,有 TTL 與傳播語意)。
7. 『NPC 對 NPC 的俘虜走 capture_routed_as_captive＋manpower 帳,玩家戰場從不轉進』:✓ 事實;可重用性:⚠。
   capture_routed_as_captive（anon_tier_system.gd:275）呼叫端只有 npc_combat_system.gd:554（潰逃）;它的比例=(1−retreater.readiness) 與 _pop_crit 取 max × CAPTURE_GUARD_FACTOR,
   讀的是『潰逃隊』的 readiness/ wounded——玩家戰場的敗方 readiness 沒有『潰逃』語意,直接呼叫得到的比例與玩家戰場無關。
   更合適的入口已存在:absorb_as_captive(state, holder, loser, rate)（anon_tier_system.gd:237）——明確傳 rate、health-aware、守恆、append captive_groups,
   呼叫端 npc_combat_system.gd:446（征服吸收）。玩家戰場勝方對『場上失能敵人』:rate 由『失能（wounded 桶)中被標 is_prisoner 的比例』決定,傳給 absorb_as_captive;不需另造入口,但 rate 的定義是新的 WHAT。
   帳:captive_groups 的讀者 manpower_system.gd:74-77 與 InvariantAudit P1（invariant_audit.gd:128-133）已覆蓋 ✓。
   ⚠ guard 容量:capture_routed 內有 pop_cap−population−total_captives 的 budget（守衛容量)；absorb_as_captive 沒有——玩家戰場若直接用它,俘虜數不受守衛容量限制(目前 prisoner_population 有『上限＝winner.population』);要決定沿用哪個上限。
8. 『追擊只在 npc_combat._apply_pursuit,上限 3』:✓ PURSUIT_KILL_CAP＝3（npc_combat_system.gd:9);函式 :609-634。
   輸入:winner.population ≥ loser.population×2 的 reachability gate（:614),勝方領袖『殘忍』『貪婪』→ straggler_kill = round(殘忍×2.0 + 貪婪×0.8) 夾 [0,3],最後 _apply_casualties(state, loser_id, pursuit_loss)。
   純隊伍層(人數),不依賴單位級資料 ⇒ 技術上玩家戰場可呼叫（輸入 winner_id/loser_id)。
   ⚠ 語意:這是【勝方領袖人格自動決定屠殺】——玩家勝方時等於替玩家決定殺不殺,與居民處置(#5)同型,也與 #12『玩家隊決策不屬 AI』同一邊界;是否讓玩家戰場套用是 WHAT(藍圖),不是重用的技術問題。
9. 『敗方後備照死亡率連坐 RESERVE_CASUALTY_MULT 1.0』:✓ encounter_system.gd:1195-1210（_apply_reserve_casualty;只對 loser_for_reserve,:1256-1258)。
   注意它用 kill_random（只殺 healthy)。
10. 『encounter_system 是否只用於玩家參與的戰鬥』:✓ 實質是。init_encounter（encounter_system.gd:227)的呼叫端:ambush_system.gd:62（【只在 leader.id==player_id 時】,NPC 走 NpcCombatSystem.start_combat,:66)、
    player_command_system.gd:793、1020、1506、1528（都是玩家指令或玩家的預備遭遇戰回應)。沒有 NPC↔NPC 入口。
    state.encounter_active 是單一全域旗標(一次只有一場),結構上也只容一場玩家戰。
    ⚠ 小:1506 `init_encounter(atk_id, def_id)` 來自 _action_accept_encounter 讀 player_pre_encounter,attacker 可為 NPC、defender 為玩家——『玩家是否為攻方』要分(#5 的『攻方是玩家時不問』即此)。
```

# 3 判決
```
premise_contradiction: true —— 僅漏②（失能不寫回 wounded)這一條,且它已被你坐實;§1a 第一列改寫成『量失能數 − 入帳傷兵數』(含昏迷縫、池上限),不是『接上』。
其餘 9 條前提成立,其中 #7/#8 的『重用』要區分技術（可,absorb_as_captive 比 capture_routed 合適)與 WHAT（玩家戰場是否自動追擊/俘虜上限)——請把這兩個 WHAT 連同 #6 的玩家事件走 WorldEvents.emit 一併帶回藍圖。
U10b:建議關條目前先跑 headless_test 該格。
```
