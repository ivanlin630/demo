---
from: reviewer
to: systems
status: consumed
slice: R² 玩家子隊真的做事（12ff4120a＋dff99dcba）
topic: R② ＝ **ISSUES,兩處擋**｜①設計自己卡自己:建設走 begin_subteam_construction → start_build（outpost_system.gd:581）內有 TaskArbiter.transition(…"建設", PRIO_DISPATCH),預設來源 "transition",你擴後的 _possessed_blocks 對玩家子隊只放 PLAYER／EVENT／物理反應來源 ⇒ 這一步被 deny ⇒ 子隊卡在 CONSTRUCT,10 天後被強制 release/merge;且蓋好的據點 owner＝子隊 id,玩家召回併回後子隊被 erase ⇒ 據點可能被釋放(無主);②PHYSICAL_REACTION_SOURCES 母體是空的/會開洞——全專案沒有純物理的 source 字串(自衛/逃走根本不經 arbiter,逃與求生走 "unified"/"survival" 與 AI 閒逛同名),且與附身隊已定的規則(威脅/求生【決策】不放行,用事件通知)相反;另:覓食/巡邏沒有主動執行端,S1/S2 的『抵達後會做事』要重寫成與實際機制相符
---

# 0 審了哪棵樹
main 12ff4120a＋dff99dcba。核對 faction_ai_system.gd:4095-4140,4287-4307;diplomatic_ai_system.gd:167-200(try_proactive_diplomacy);subteam_system.gd:178-205,313-345;
outpost_system.gd:428-440,561-587,785-830;resource_system.gd:85-105;faction_ai_system.gd:585-625,1759-1765;interaction_system.gd:165-195;text_ui_main.gd:10-31;
TeamData.parent_team_id／subteam_ids（team_data.gd:447-448）。

# 1 你問的第 1 點:謂詞與換附身邊界
```
①『is_player_subteam(state, team)』要 state,但守衛要用它的地方多數沒有 state:release()（task_arbiter.gd:338）、set_strategic_move()——
   多格移動票為同一個理由把『附身』做成事實欄 TeamData.possessed（由 sync_possession 單寫者維護）。玩家子隊同理:
   ⇒ 存一個派生事實欄(例 player_controlled_sub),由【同一個 sync_possession】在附身變動時順著 parent.subteam_ids 重算(子隊可枚舉,team_data.gd:448),
      並在 dispatch(新增子隊)、召回/併回、detach(紀律失效 faction_ai_system.gd:4302、容量滿分團 subteam_system.gd 約 322)、母隊消滅時寫;
      P8 漂移守衛延伸到這一欄(tick 尾驗『標記為真的子隊 ⇔ dispatched_by_player ∧ parent.possessed』)。
   不要在 arbiter 裡臨時查 state.teams[parent]——release/set_strategic_move 做不到,而且會讓同一個謂詞有兩種算法。
②附身切換:換到別的隊時,舊隊的 dispatched_by_player 子隊 parent 已非 player ⇒ 謂詞假 ⇒ NPC AI 接手(含歸建、外交);切回來謂詞又真。
   這是合理的,但要明寫『玩家不在時它們會被 AI 當 NPC 子隊處理(可能被併回/改派)』。
   S12(dff99dcba):玩家對舊 NPC 子隊下任一令 ⇒ flag 翻 true——只在【指令被接受執行之後】翻(被拒的令不翻),否則『按錯一個鍵就接管了一支自主子隊』。面板標『自主(非你派出)』✓ 好。
③spec 沒列但會把玩家子隊拉走的出口(都要嘛豁免要嘛通知玩家,別靜默):
   ·_check_discipline(faction_ai_system.gd:4287-4307):對非 idle 子隊 randf()<fail_chance ⇒ detach_subteam＋release——人格/忠誠 gate 的合法機率,不是 AI 決策,可保留,
     但必須 emit『你的子隊 Team20 紀律失效,脫離』給玩家(S8 只有被攻擊)。
   ·CONSTRUCT 抵達後 10 天未開工 ⇒ 強制 release＋merge（faction_ai_system.gd:4095-4104)。
   ·_merge_into 容量滿 ⇒ 子隊被 detach 成獨立分團;try_merge_back 路過母隊格被吞(你已列,條件=子隊移動後與母隊同格且 task 不在 TRANSIT 清單,subteam_system.gd:178-193)。
   ·玩家子隊永不歸建 ⇒ 累積:派遣有沒有數量上限?子隊糧食/死亡的玩家通知要一起想(famine_crossed 停點只看 subjects 含玩家隊 id,子隊 id 不是——你的 emit 要把玩家隊放進 subjects,你已寫 ✓)。
```

# 2 你問的第 2 點:PHYSICAL_REACTION_SOURCES——不要建這個集合
```
(a) 全專案 try_set／transition 的來源字串(普查):unified(15)、solo(4)、survival(3)、ambition(2)、beggar_restore(2)、vendetta、scout、relocate、merchant_order、herald_order、invite_settle、player*。
    沒有一個是『純物理反應』:
    ·自衛/戰鬥:encounter_system／npc_combat_system／reaction_system 對 TaskArbiter 零呼叫,戰鬥靠 try_set 頂端的 combat_target 鎖保護——不需要放行任何來源;
    ·逃:威脅反應走 _decide_unified@PRIO_THREAT,來源仍是 "unified";求生走 "survival"。這兩個字串與 AI 閒逛(DISPATCH@50 的 "unified")完全同名。
    把它們放進允許集合＝讓決策引擎重新替玩家子隊做事,也就是開一個洞。
(b) 與附身隊已定規則相反:藍圖/用戶 2026-10-13 已裁『閒著的附身隊不覓食是意圖』、威脅與求生的【決策】不放行,事件通知玩家(famine_crossed 進推進停點)。
    玩家子隊是同一個『由玩家決定』的語意;若這裡允許求生決策,同一個世界就有兩套標準。
⇒ 建議:玩家子隊與附身隊用【同一個】允許集合(PLAYER_SOURCES ∪ EVENT_SOURCES),不另立物理集合;『物理反應』靠 combat 鎖＋事件通知,逃與求生交給玩家。
   若藍圖真要『被攻擊時子隊自己逃』,那是 WHAT:鍵要用事實(combat_target≠-1 或進行中遭遇),不是來源字串。
```

# 3 ★擋:你的建設路徑被自己的守衛擋住,且蓋好的據點可能無主
```
begin_subteam_construction（outpost_system.gd:788）→ start_build（:561）:
   ·:581 TaskArbiter.transition(state, team, "建設", TaskArbiter.PRIO_DISPATCH, Vector2i(-1,-1)),來源參數用預設 "transition";
   ·你擴後的 _possessed_blocks:玩家子隊只接受 PLAYER_SOURCES∪EVENT_SOURCES∪(物理反應);"transition" 不在其中 ⇒ deny(transition 是 void,呼叫端不知道)。
   ·此時 start_build 前面已把 tile.construction_team_id＝子隊、扣了料(:575-580)——扣了錢、設了工地,但子隊 task 仍是 CONSTRUCT、move_target 已清
     ⇒ 被 faction_ai_system.gd:4095 起的『抵達後逾時未開工』分支守著,10 天後強制 release＋merge。
   S7『抵達後開工(construction_team_id 有值、進度推進)』可能前半綠後半紅,看起來像是『進度不推進』的別的毛病。
   同類:_convert_to_resident、establish_crude_camp 等『抵達觸發的 lifecycle 寫入』都會經 transition/try_set;EVENT_SOURCES 必須含這些 lifecycle 來源(抵達開工、轉居民、紮營完工),
   且逐個 grep 實際來源字串(多數是預設值 "transition"／"")——要先給它們具名來源,不能把空字串/"transition" 整類放行,那等於撤守衛。
據點歸屬:
   ·完工時 outpost_system.gd:435 set_owner(tile, tile.construction_team_id, "construct"):owner＝子隊 id(construction_target 沒有 owner 鍵;只有 crude_camp 分支才讀 construction_target["owner"],:478)。
   ·玩家召回 ⇒ _merge_into ⇒ 子隊被 erase_team(subteam_system.gd:224-225)。_merge_into 全函式沒有任何據點歸屬轉移(我讀過 313-345,grep 該檔無 outpost_owner);
     erase_team 對『被 erase 隊擁有的據點』是否同走 world_state.gd:925-940 的死亡釋放(直寫 -1)我沒逐行核,請核;若同路,玩家蓋的據點在召回那一刻變無主。
   ⇒ 玩家子隊建設要在 construction_target 帶 owner＝母隊(玩家隊)(沿用 crude_camp 已有的 owner 鍵形狀),完工 set_owner(…, owner);與 §三『移居:地主＝玩家或同勢力』一致。
   ⇒ S7 加兩格:(a)抵達後 task 變『建設』且進度推進(堵 transition 被擋);(b)完工後 owner＝玩家隊,再召回子隊 ⇒ 據點 owner 仍是玩家隊(堵無主)。
『選單同玩家建設前哨/蓋設施,同一份來源』:現況不是。子隊任務選單是 text_ui_main.gd:10-18 的 SUBTEAM_TASK_CHOICES(常數);玩家自己建設是 _prompt_build_facility／build_type(civilian/military) 的提示(text_ui_main.gd:約 2787-2816)。
   spec 說『實作端找出那份清單的單一來源』——現在沒有這份單一來源,要新建:OutpostSystem 層的具名常數(可建類型/等級/設施),玩家建設提示與子隊建設選單都讀它;
   並由 begin_subteam_construction 的 match(CONSTRUCT／UPGRADE／EXPAND)決定哪幾種子隊做得到(升級/擴建要地主=玩家或同勢力,_faction_owns :815)。
```

# 4 各任務的『執行端』:S1／S2 的前提與現況不符
```
覓食:沒有『主動覓食』動詞。resource_system.gd:85-105 的被動採集依【所在格】(camp_level>0 的 L0 forage、據點 gather、wild_game 的被動小獵),與 task 是否為 FORAGE 無關(只有 Probe 用 TASK_FORAGE 計數)。
   ⇒ 拿掉歸建閘後,玩家子隊抵達『沒有營地/據點/野味的格』覓食 ⇒ 零產出(probe 名就叫 collect.no_outpost_no_camp_zero_food.subteam)。
   S1『抵達後 1 天內有覓食產出』只在目標格有食物來源時成立;佈置要明寫,且『覓食』若是承諾『去那格找吃的』,前提(該格已知有糧源/可獵)應像落腳一樣進選定任務後的前提判斷,不可帶原因。
巡邏:全 simulation 對 TASK_PATROL 只剩一行標籤親和表(faction_ai_system.gd:1765),沒有執行端 ⇒ 玩家選『巡邏』什麼都不會發生(宣稱動作必須改世界)。S2 的巡邏格造不出紅/綠。
   你已寫『沒有 ⇒ 停手列出』:證據在此,請直接定:選單移除巡邏,或定義它(例=原地待命＋視野),由你/藍圖定。
偵查:唯一執行端是征服 scout(_tick_conquest_scout,faction_ai_system.gd:610,條件 task_reason=="scout" 且 prosperity_target_id),玩家派的偵查不屬它。
   實際效果＝『走到該格並停留(視野更新)』——這就是偵查在玩家手上的全部,要在結果句誠實說(『前往 (q,r) 偵查』,抵達事件『你的子隊已到 (q,r),看到:…』)。
   S2 偵查格據此寫:抵達後 tile_knowledge 該格由 unvisited 變 visible。
```

# 5 外交:根因是『同勢力』判斷在無勢力時失效
```
try_proactive_diplomacy（diplomatic_ai_system.gd:167-186）排除自家人的條件是 other.faction_id == self.faction_id and self.faction_id != -1——
   玩家隊獨立(faction -1)時它的子隊也是 -1 ⇒ 條件為假 ⇒ 子隊會對【自己的母隊】(同格)送 trade／demand_tribute(alliance 需要 faction≠-1 所以不會)。
   這就是 QA 看到的『找上門來自自己子隊』。同病也在 NPC 獨立隊的子隊上。
⇒ 修在【譜系】不是勢力:排除 {自己的母隊、自己的子隊、同母兄弟}(用 parent_team_id／subteam_ids),對所有子隊成立;玩家子隊另外在入口整個跳過(S4)。
   NPC 獨立隊子隊不再對母隊索貢是行為改變(fp)。
   與 §四 威脅掃描排除用同一把『譜系』謂詞(decision_context.gd:652-661 只排自己、threat_assessment.gd:31-70 不排同勢力——兩處用同一個 is_kin(a,b),別各寫一份);
   先量你已寫(3 seed),補量『獨立隊子隊→母隊』的 propose／tribute 次數。
```

# 6 小註
```
·入口跳過清單(_decide_subteam、loop3 野心層、set_strategic_move、外交)與『附身隊三件』丙票的 loop3 寫者分類重疊:玩家子隊也走 loop3,_evaluate_threat／_evaluate_survival／_update_* 等同樣會寫它。
  共用一個『玩家控制的隊』入口跳過謂詞(附身隊 ∪ 玩家子隊),別在兩張票各列一次跳過清單;丙票的分類結果直接套用。
·S3『待機 24 小時 task、位置不變、零外交』✓;補 S3b:對 IDLE 子隊 _decide_subteam 的跳過要有負對照(拿掉跳過 ⇒ 24 小時內出現改派)。
·§五 腳下派遣 6 小時:我沒查呼叫端計時;movement_system.gd:340-344 的同格清除在 _step_team 內,而 _step_team 只在累積 ≥ 每格成本時被呼叫,所以同格派遣也要等一格的時間——
  你的『同格直接視為抵達』方向合理,但請在 move_to 與派遣兩處共用同一個『目標＝腳下』判斷(多格移動票的 move_to 已有 pt.tile_pos == target_pos → 已在目標格)。
```

# 7 判決
```
verdict: issues
擋:§3(建設被自己的守衛擋住＋據點無主)、§2(不建 PHYSICAL_REACTION_SOURCES,與附身隊同一集合)
同版補:§1 事實欄與 sync、§4 覓食/巡邏/偵查現況、§5 譜系謂詞、§6
補完 §2§3 後不需再審;§4 巡邏的定奪請寫進 spec(移除或定義)
```
