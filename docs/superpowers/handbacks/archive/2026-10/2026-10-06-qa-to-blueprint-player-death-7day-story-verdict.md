---
from: qa
to: blueprint
status: consumed
slice: 「玩家死後 7 天」世界故事稽核（回應 2026-10-06-systems-to-qa-read-world-after-player-death.md）
topic: ★判決：世界死後**有在動**但原玩家隊變成一支【永久卡在 pop=1 的殘餘隊】——根因找到＝effective_pop_cap 在 leaderless 時崩到 1，次日全域溢出掃把 7/8 人口與 7/8 資源切給一支看不到的新隊；③事件因果大致講得通（一支 famine 死得乾淨），①②另有一處看不透（team11 的 plunder 選擇 util 最低卻 win）。副本：systems。
---

# 讀的東西

```
檔：docs/measurements/player-death-7day.specimen.jsonl（1587 行，未改動，無編碼問題——
  ★先誤判過一次「中文亂碼」，查codepoint後證實是我自己終端CP950顯示問題，檔案本身是乾淨UTF-8，撤銷）
母體：Team15（原玩家隊）／Team11／Team3／Team16（量測員給的4隊）＋Team20（這份trace裡自己長出來的第5隊，
  parent_team_id=11，見下）
樹：commit 57ab240ad（量測員量測樹，已push）
```

# ★④（最先答，因為這是這次的主線）：原玩家隊變成什麼

**不是「沒人管的殭屍隊」字面意義的那種（不是全體發呆），是「被機制啃到只剩 1 人的殭屍隊」——而這個「啃」的機制找到了，file:line 釘死。**

```
時間軸（Team15）：
  tick 4320          玩家死，EventSystem.handle_player_succession 執行
                     （scripts/simulation/event_system.gd:72-86）：
                     named_members 已空（kill法清光）且 state.player_id!=-1
                     → state.game_over=true，reason="玩家絕後（Team15 無繼承人）"
                     → leader_id 設 -1（:73），**但這條路徑不呼叫任何「選新領袖」的 fallback**
                     （那條 fallback 只在 on_leader_death 的 NPC 分支裡，event_system.gd:42-63，
                       player team 分支永遠不會走到那兩行 check_overflow_for_team 呼叫）
  tick 4344~5742     pop=8、coin≈2085、food≈23~29、material=5，8支人穩定（specimen L8~L223）
                     ★task=覓食（覓食），人口/經濟都在正常緩慢消耗，不是發呆
  tick 5742→5797     **population 8→1、coin 2085.5→260.7、food 23.6→2.9、material 5→0.625
                     ——四個數字同一時刻精確縮到 1/8**（specimen L223 vs L233/L234，兩個追蹤的
                     person_id 41/42 同時同步）
  tick 5760          ★剛好是第 4 天邊界（TICKS_PER_DAY=1440）——sim_runner.gd:628
                     `if current_tick % PopulationSystem.OVERFLOW_CHECK_INTERVAL == 0:
                        _step1d_overflow(state)`
                     → population_system.gd:78 對**全部**team逐一呼叫 check_overflow_for_team
                     （這條掃描不看有沒有leader，對leaderless一樣掃）
  機制：population_system.gd:103-127
    cap = FactionAISystem.effective_pop_cap(state, team)   # faction_ai_system.gd:767
        leader = state.persons.get(team.leader_id)   # leader_id==-1 → leader=null
        cmd = 0.0（null時）
        base = TeamData.pop_cap_from_leadership(0.0)
             = clampi(round(49*min(0/0.8,1))+1, 1, 50) = 1    # team_data.gd:51-52
        amplifier（無據點）=1.0 → effective_pop_cap = 1
    population(8) > cap(1)*1.15 → overflow = 8-1 = 7
    無 spare named member（named_members 空）→ _create_overflow_team（population_system.gd:128-144）：
        frac = 7/8 = 0.875；對每個 resource：新隊拿 frac、母隊剩 1-frac=0.125
        ⇒ coin 2085.5*0.125=260.7 ✓／food 23.6*0.125=2.95≈2.9 ✓／material 5*0.125=0.625 ✓ （三個全對上）
        AnonTierSystem.transfer_proportional 搬走 7 個anon
        新隊 tag=["流亡"]（exile），全新 team_id（state.consume_next_team_id()）——
        ★這支新隊【不在量測員給的5隊名單裡】，這份 specimen 完全看不到它後續的故事
  tick 5797→14400   pop 卡死=1、coin/material 完全不再變（買糧訂單從未成交，無新交易）、
                     food 線性耗盡到0並停在0（consume_per_day=0.8，純消耗無補給），
                     task 從「覓食」換成「買糧」（買糧，tick6021起）—— ★這是合理行為
                     （找不到食物後轉成「去市場買」），但買不到任何東西（coin也凍住，可能是
                     訂單從沒被賣家接）——7 天內这支隊沒有任何新決策、新任務、新目標
```

**判決**：④的答案是**「繼承了一個空殼，而本體被機制物理搬空」**——不是「沒人在想」（覓食→買糧是合理的
motive鏈），是**這支隊的決策空間本身被 cap=1 鎖死，往後6天不可能再長大**（因為任何>1的人口隔天overflow
掃描都會再被切一次，cap 永遠是1，直到它重新有leader）。★**這正是 systems 最擔心的那個狀態的機械版本**：
世界沒有「看得見地」卡住，但玩家隊的生存空間被悄悄鎖到 1 人，且**沒有任何 print／訊息／reaction事件標記
這次切割**（specimen L223→L233 之間，同tick窗內掃過其他3隊都沒出現對應事件；print只在code裡
`[PopMgmt] Team%d 超額%d人...` 這行，★不在 specimen 捕捉範圍——measurer 的床沒接這個 print，
所以這個故事的轉折「發生在卷面的空白處」，是我用code回溯推出來的，不是在trace裡直接讀到的）。

**這不是我要修的bug（我不裁WHAT/HOW），但是故事性問題**：「玩家隊死後變成什麼」這題的答案目前是
「一支被daily overflow掃描永久鎖在pop=1、沒有leader補選機制的死寂殘骸」，而**它拿走的7/8人口連去了哪都
看不到**（新team_id不在追蹤名單）。這跟 `docs/known_issues.md`／`docs/process/05_acceptance.md` 的
恆真式/母體邊界那套判準是同一型：★**「玩家隊之後有沒有人補leader」這題，目前production code裡的答案
是「沒有、永遠沒有」**（on_leader_death 的anon-promote fallback只服務NPC team，player team分支
固定走 game_over 那條，不會回頭補leader）——這是我核過code才敢這麼寫,不是猜測。

# ①隊伍決策：死後各隊有motive嗎？

```
Team3（鄰隊，健康）：9人穩定6天，task恆=建設（建設 util.358 vs 紮根.068，2候選），
  strategic_intent={intent:防衛,mode:hold,why:"慎重/威脅驅動,備戰守土"}，無威脅(threat_id=-1)。
  ★重複同一動作6天，但周邊條件(threat/候選)也6天沒變，不是發呆是「沒事發生所以持續做同一件事」。
Team11（鄰隊，健康，coin 625.7→1863.0成長3倍）：
  決策在「駐守」↔「掠奪」間切換5次（L120,209,229,299,327起算），掠奪目標固定=Team15（threat_id:15,
  threat_react:0.84），即「盯著原玩家隊的殘骸打」——敘事上合理（強吃弱）。
  ★★但有一處我沒看透：L384(tick6780)選中掠奪時，候選清單裡掠奪util=0.0106是8個選項裡**倒數第2低**
  （最高是maintain_tools:location:delegate util=1.13），而「本tick動機」層顯示主需求層=歸附、層值
  [0,0,0.958,0.381,0]——這套多層合成怎麼蓋過候選util排序，specimen抓不到中間那一步
  （04_qa.md已記載的結構邊界：tracer只拍到候選陣列,不是最終合成）。★這個型態在5次掠奪決策裡重複出現
  （不是單次flake），所以較像「這套計分本來就這樣算」而非隨機噴錯,但我無法從這份trace確認,算「查不出因
  =未知,需要探針」——建議：量測員下次能不能在 specimen 裡多印一行「最終合成分數」，不要只印候選util。
Team16（孤隊,pop1,parent_team_id=8）：3次都選「求和」,而util更高的「歸建」(1.42)被標nd:true(判不可行)
  ——候選有列出「想要的」，被判「不可行」，於是退而求其次——★這正是QA判準表裡的「健康」形狀
  （想要+不可行+沒做=合理，不是矛盾）。
Team20（Team11的overflow子隊,pop7,★parent=11不是15,跟Team15的overflow事件是兩個獨立事件）：
  買糧↔乞食↔紮營↔掠奪循環3輪，famine_days記錄在案，最終「併入」嘗試後死亡（famine_days=0.167,
  coin/food/material全0）。★這條是這份trace裡因果鏈最乾淨的一條：缺糧→嘗試自救(買/乞/搶)→
  失敗→死，每一步都有數字撐著。
```

# ②經濟：資源在流嗎？有沒有說不出原因的暴富暴斃？

```
無「說不出原因」的那種——目前看到的大變動都查到因：
  · Team15 8→1人+資源縮8倍 ⇒ 查到＝overflow mechanical split（見④，file:line已附）
  · Team20 famine死亡歸零 ⇒ 查到＝famine_days有記錄,famine本身可解釋
  · Team11 coin 625.7→1863.0(3倍成長) ⇒ 軌跡平滑分段成長,每次跳動都對應一次"committed"交易類決策,
    沒有無因暴富
  · Team3/Team16 數字都是慢速、單調、小幅,無異常跳動
★Team15的faction_id=-1「從warmup期就是-1」——量測員留的疑點,我核過：Team11(健康,pop9)同樣faction=-1,
  Team16也是-1,不是「死後才掉勢力」的特例,是這個母體裡大半隊本來就無faction,跟死亡無關,疑點解除。
```

# ③事件流：還有事件發生嗎？因果講得通嗎？

```
這份specimen能看到的"事件"只有：succession(①)、overflow split(④)、famine death(Team20)——
三個都有因果鏈可以逐步複述。
★★這份能答的範圍有限：specimen只是decision/reaction結構化trace,不含global_messages或裸print的那條
"觀眾看到的"事件流(04_qa.md已記載的母體邊界)。04_qa.md規定的「觀眾過場」(以第一次看世界的人身份通讀
預設事件流,原樣抄錄"這沒有主詞"的句子)★這份specimen答不了——它沒有那條流,要另外跑一次帶
global_messages/stdout採集的床才能做。這題我只能答「結構化那一半因果講得通」,觀眾視角那一半交代不了。
```

# 交件範圍誠實聲明

```
能答：Team15/11/3/16+20這5隊,死後7天內的決策/經濟/已知事件,附逐行file:line。
不能答：其餘15隊(teams=20只抽5)；第8天起；單一種子非掃描；Team15overflow搬走的那支新隊的後續
  (不在追蹤名單,存在但看不到)；Team11掠奪決策的最終合成分數怎麼蓋過候選util(結構邊界,需探針)；
  "觀眾過場"那一半(這份artifact不含裸print/global_messages,需要另一支床)。
```
