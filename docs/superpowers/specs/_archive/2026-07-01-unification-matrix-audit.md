# 統一矩陣稽核 — 實體 × 領域（EXHAUSTIVE，逐檔 sweep 完成）

> 系統產出（藍圖 `unification-matrix-program` task 1）。**逐檔 sweep 全 76 production 檔**（sim 66 + data 10；debug 31/ui 12 = harness/presentation 出 scope）。8-batch fan-out 逐行讀。每格 統一/補丁/缺口。
> **覆蓋**：76/76 production 檔逐行。confidence 高。（first-pass grep 版已被本稿取代——含重要修正，見下。）

## ★ 結構總洞察（窮盡後修正）
- **核心抽象對**：所有 team 型=同 `TeamData`，且 **computed getter + no-op setter**（`population`/`wounded`/`anon_tiers`，team_data.gd:54-155）= **最強單寫者（compile-time redirect，比任何 Bank 強）**。→ 藍圖「不 KILL」正確。
- **但 fork 遠比 first-pass「4 cluster」多、且第3不變量大面積未實現**。真相：
  1. **思考決策**：5+ 平行 scorer（確認）+ threat term 是死 stub + 雙 faction-goal producer（新）。
  2. **狀態所有權/單寫者**：**first-pass「ResourceBank 被 53 直寫繞」是錯的**——`team.resources` **乾淨全走 bank**。真洞在 **tile 層 + roster + 一堆無主 team 欄** + **Pattern B ledger 全 stub**。這格是**最未實現**的領域。
  3. **互動**：多平行 resolver（2 diplomacy/3 tribute 公式/3 deception 引擎）+ **NPC 乞食/投靠 task 路徑確認死** + belief-gating 不一致。
  4. **player-vs-NPC**：primitive 多統一（48 handler:~24 統一/18 補丁/4 缺口）但 dispatch 裂 + player-only 不對稱能力 + UI god-view 洩漏。
  5. **人力/俘虜**：雙 skill/injury/equipment 模型（按實體型）+ prisoner_population 是**互相死路**（無任何消費者）。

## 矩陣（列=實體、欄=領域；括號=關鍵證據）

| 實體＼領域 | 思考決策 | belief情報 | 狀態所有權 | 物品資源 | 互動 | 人力 | combat捕俘 |
|---|---|---|---|---|---|---|---|
| **named person** | 補丁(reaction scorer 9-react + goals 第2軌) | 缺口(併team) | 缺口(coin/salary/skills/stress 無主) | 補丁(person.coin 無bank) | actor via leader | 補丁(named skill=float,無 anon→named 除 person_gen) | 統一(kill_random) |
| **anon cohort** | 缺口(無agency) | NA | 補丁(anon_exp/armed_ratio 直寫) | 統一(AnonTreasuryBank) | payload | 統一(AnonTierSystem)但 skill=tier(異模型) | 補丁(capture NPC-only) |
| **team(unified)** | 統一(DecisionEngine,零named intent) | 統一 | 部分(resources✓/roster✗/combat_target✗/tags✗/solo_intent✗) | 統一(ResourceBank) | 多統一(trade/barter/settle) | 統一 | 統一(NpcCombat) |
| **subteam** | 補丁(_evaluate_idle_subteam;unified-tag 進不了engine) | 統一 | 統一(parent↔subteam bidir)但 roster 直寫9site | 統一 | 統一 | 統一 | 統一 |
| **faction** | 補丁(_score_intents+strategic_ai 雙producer) | 補丁(known_member_states 雙寫混epistemics) | 缺口(leader_team_id 無chokepoint/goals 直寫) | 缺口(無treasury,by-design) | 補丁(tribute收集/2 resolver) | 缺口(無pop) | NA |
| **獨立 team** | 缺口(菜單截斷 建國/守成) | 統一 | 統一 | 統一 | 補丁(found_ally 走 resolver#1;betray 無-無faction) | 統一 | 統一 |
| **player** | 統一(手動) | 統一(best_estimate)但 UI 洩 god-view(loyalty/psychology) | 補丁(player_state 命令匯流排無schema) | 補丁(unequip:1293 繞bank) | 補丁(48handler;4缺口 demand_tribute/recruit×2/betray) | 統一 | **補丁/缺口(EncounterSystem 全fork;prisoner_pop 死路)** |
| **item** | NA | NA | 補丁(encounter_templates:55 直寫team.resources) | 統一(pool)但 named-slot vs anon-ratio 異模型 | NA | NA | 統一 |
| **tile** | NA | 補丁(team_discovered/known/velocity 三 registry) | **缺口(public_storage+resources+occupied_by+tags 全無bank)** | **缺口(public_storage 22+直寫/coin 憑空鑄)** | NA | NA | NA |

## 完整 fork 清單（窮盡，按領域）

### 思考決策
- **F-D1** 4-5 平行 scorer:DecisionEngine(unified team)/`_score_intents`(faction)/`_evaluate_solo`(非統一solo)/`_evaluate_idle_subteam`(subteam)/`_evaluate_person`(named,reaction_system:109)。
- **F-D2** intent 菜單 fork（headline）:faction{征服/致富/防衛/守成/+立國} / 獨立{建國/守成} / unified{無emergent} / subteam{回歸/掠奪/攻擊} / named{P1..N5}。無共享菜單。
- **F-D3** 雙 faction-goal producer:`_update_goals`→`f.goals`(means-end) vs `strategic_ai:42 _update_faction_goals`→`f.strategic_goals`(expand/defend/trade_net)。擴張只在後者。
- **F-D4** solo_intent 一槽兩義(戰略值 vs task string)。
- **F-D5** unified-tag subteam 進不了 engine(`_evaluate_subteam`)。
- **F-D6（新）** threat/FLEE 雙路:DecisionContext.threat **hardcoded 0.0**(decision_context:69)→ engine threat option 永死;真 threat 走手寫 `_evaluate_threat`+`_dispatch_threat_response`(ThreatAssessment)。統一那條是 stub。
- **F-D7（新）** f.goals 雙消費:非統一 member 直讀(`_assign_member_tasks`)vs 統一 member 經 DecisionContext faction_stakes→faction_duty term。
- **非-fork**:survival 選擇真統一(`rank_survival`)。

### 狀態所有權/單寫者（第3不變量——最未實現，first-pass 修正）
- **✅ 已實現單寫者**:team↔faction bidir(`set_team_faction`)、parent↔subteam bidir(`set_subteam_parent`)、`erase_team`、**TeamData computed getter+no-op setter(最強)**、`team.resources`(ResourceBank,**全乾淨,first-pass「53直寫」錯**)、outpost_owner(OutpostOwnerBank)、loyalty/unrest/anon_treasury banks、update_reputation、TaskArbiter(task)。
- **❌ 未實現(無 chokepoint,直寫)**:
  - **F-S1（修正）tile 層全無 bank**:`tile.public_storage`(granary,22+直寫:resource_system/outpost/manufacturing/interaction/faction_ai)+`tile.resources`(自然池,harvest/hunt/ambush/resource_system)+`occupied_by`(移動設不清=stale)+`abandoned_coin`+`stable_progress`+facility levels。coin **憑空鑄入 public_storage["coin"]**(outpost:228/241)無 treasury bank。
  - **F-S2 Pattern B driver-ledger=stub**:全 5 bank 的 `reason` 參數**丟棄不記**;第3不變量「凡 state 變化必有 driver」= **未實現**。
  - **F-S3（新）roster `named_members` 無 chokepoint**:59 直寫 site/17 檔(subteam 9/reaction 3/health 2…) `.append/.erase/.clear`。person↔team 無 bidir。
  - **F-S4（新）combat_target 無 chokepoint**:9 檔直寫,TaskArbiter 只讀不擁;erase_team 反應式清。
  - **F-S5（新）tags 無 chokepoint**:load-bearing(軍隊/生產/流亡,movement:51 讀決策)、event_tag_shift 直寫。
  - **F-S6（新）無主 team 欄**:solo_intent/current_option/fatigue/readiness/work_morale/strategic_assignments/ambition_*/armed_anon_ratio…直寫。
  - **F-S7（新）faction.leader_team_id 無 chokepoint**:game_setup:247 直 swap;領導轉移無 maintainer。
  - **F-S8（新）person.coin/salary 無 bank**:salary:62/66 直寫(團 coin 走 bank、人 coin `+=` raw=守恆不對稱洞)。
  - **F-S9（新）team 建立無 chokepoint**:`erase_team` 有、但建立 `state.teams[id]=` 直寫(6+ site)+ 須手動 init team_known/discovered → 忘了就 desync。
  - **F-S10（新）succession 三重**:event_system/event_unrest_replace/event_unrest_split 各手寫 leader_id+role+named_members,規則微異。
  - **F-S11（新）faction_id=-1 直寫繞 set_team_faction**:6 site(defect/split/beast/manpower/population/reaction);defect:21 最險(離 faction 沒清 member_team_ids)。
  - **F-S12（新）reputation 寫不一致**:sim_runner:141 直寫 known_reputations 繞 update_reputation。

### belief情報
- substrate 統一(team_intel/best_estimate,team/subteam/獨立/player 同)。
- **F-B1** faction known_member_states 平行 snapshot,雙寫混 epistemics(全知 world_state:244 + leader belief faction_ai:519),readers stitch。
- **F-B2** tile discovery 三 registry:team_discovered(vision)/team_known(near-orphan,只 split 寫)/path velocity channel(第2 epistemic,走 last_tile_pos raw)。
- **F-B3** named person 無個人 belief(併 team)。
- **F-B4** invariant_audit 只查 team_discovered dangling,**不查 team_intel source_id/team_known**。

### 互動
- **F-I1** 2 NPC diplomacy resolver:`_try_diplomacy`(interaction,**god-view strength**,task trigger)vs `handle_diplomacy_message`(diplomatic,**belief**,message)。同 verb 相反 epistemics。
- **F-I2** 3 tribute/extort accept 公式,belief-gating 不一致:`_should_pay_tribute`(god-view strength)/`handle demand_tribute`(belief pop)/`resolve_extortion_direct`(raw pop+fear)。
- **F-I3（★確認 bug）NPC-NPC BEG/JOIN task 路徑死**:`_try_interact:197` `if combat_target != -1: return` **先於** BEG resolver(:247);BEG 設 combat_target → 恆早退不可達。**JOIN 根本無 resolver**。→ NPC 絕境「乞食/投靠」(P2a option)walk 到目標被 197 殺、無 resolve。player 版直呼繞過。**確認 code-flow 死;runtime 影響待探針**(measure-first)。
- **F-I4** 3 deception/distortion 引擎(interaction `_write_tier2_intel` / message `_distort_content` / message `_distort_intel_entry`)+ 第4 dormant。
- **F-I5** RelationGraph typed-edge(feud/killed/protect/gratitude)**orphaned**:互動/外交/salary 全用 known_reputations+person.memory,**不 consult feud graph**。
- **F-I6** memory-schema fork:`tribute_refused`(diplomatic:111)缺 `type` 欄 → type-scan counter 看不到。
- **F-I7** combat-decision verb 仍讀 god-view(`_should_attack`/`_should_pay_tribute` team_strength),vs diplomacy 已 belief(G3-E 部分轉換)。
- **F-I8** recruit 個體 = player-only,NPC 無等價。

### player-vs-NPC
- 48 handler:~24 統一(reuse primitive)/18 補丁(reuse+平行 wrapper)/**4 缺口**(demand_tribute/recruit_anon/recruit_named/betray_faction=全平行手寫,NPC 等價存在未用)。
- **F-P1** dispatch 裂(command registry vs current_task);combat 全 fork(Encounter vs NpcCombat)。
- **F-P2** player-only 不對稱能力:set_armed_anon_ratio/set_faction_goal(player_goal_override)/order_faction_member(命令通道)/gather_intel(主動情報)/set_member_salary/inventory——NPC 全無對稱。
- **F-P3** NPC 能力 player 弱/無:player betray 無條件(NPC belief+confidence gate);tribute 額 player 硬寫 0.1 無共享 primitive。
- **F-P4** UI god-view 洩漏:map_willing_members 洩 raw loyalty;PlayerTradeSystem 洩 NPC 全 psychology/valuation;inspect 洩 resources(只 discovered gate 無數字霧)。
- **F-P5** magic const 手寫(tribute 0.1/surrender 0.3/recruit cost)無共享 valuation(對比 trade 已統一 TradeValuation)。

### 人力/俘虜
- **F-M1** 俘虜:captive_groups(NPC 活)vs **prisoner_population(互相死路,encounter:1293 寫、無任何消費者、無 ransom/release)**。2 capture 機制 + 2 capacity 語意。
- **F-M2** 雙 skill 表示:named=float(skill_system) vs anon=exp→tier(training_system),leader.戰術 驅 anon 升(跨實體耦合)。
- **F-M3** 雙 injury 引擎:named=per-person body_parts vs anon=aggregate wound_random(health_system 114 vs 159),player 特例入 named。
- **F-M4** 雙 equipment:named=個體 slot vs anon=armed_anon_ratio scalar。
- **F-M5** scalar silo:minor_population(無晉升除 anon平民)/armed_anon_ratio/anon_female_ratio,無 bank 無路。
- **F-M6** anon-tier→named-skill 耦合:promote 的 named 起始技能依 consumed anon tier(菁英≠平民)。
- **F-M7** named 選擇散 ≥3 系統(reaction scorer/_pick_subteam_leader/overflow pick)未 reconcile。

## 燒優先序（窮盡後）
1. **★首燒 獨立/faction 戰略合併**(F-D1/D2/D3/D4/D5/D6/D7):intent-forming 統一「任何 leader 一套菜單、faction=規模 context」→ 帶致富+征服錨。順收 threat stub、雙 producer。
2. **B R1 食物張力**(給錨牙,隨戰略合併後)。
3. **第3不變量單寫者實現**(F-S1~S12):**大塊獨立 arc**——tile-state bank(granary/coin 憑空鑄=connect 守恆)、Pattern B driver-ledger 落地、roster/combat_target/tags/team-creation chokepoint、succession 統一。這格最未實現、且撐強制閘的前提。
4. **互動 resolver 統一 + BEG/JOIN 死路修**(F-I1/I2/I3):先驗 BEG/JOIN runtime 影響(探針)→ 統一 diplomacy resolver + tribute 公式。
5. **俘虜統一**(F-M1):prisoner_population→captive_groups(受控人力 Phase 2)。
6. **人力雙模型收斂**(F-M2/M3/M4)+ **player-vs-NPC dispatch**(F-P1~P5,玩家面 arc)。
7. **belief 收尾**(F-B1 known_member_states 統一/F-B4 audit 補)+ combat verb belief-gate(F-I7)+ RelationGraph 接線(F-I5)。

## ⚠ 確認 bug（非只 fork）
- **F-I3 NPC-NPC BEG/JOIN 死路**:兩 agent 獨立確認 code-flow(interaction:197 早退 + JOIN 無 resolver)。P2a 絕境「乞食/投靠」NPC 側可能空轉。**建議先插探針量 runtime 影響**(NPC BEG/JOIN 實際 dispatch+resolve 率),別直接當實(measure-first)。→ 另案 known_issues。
- **F-S2 守恆隱洞**:person.coin `+=` raw 不走 bank(F-S8)、coin 憑空鑄 public_storage(F-S1)= coin_eq audit 現對 team.resources 求和 delta 0,但這些在 audit 盲區。

## 強制閘 + checklist（program ②③）
- **強制閘**:先守 F-D(戰略合併後 intent 統一路徑)+ F-S(driver-ledger + roster/combat_target chokepoint)。CI 掃決策/state-change 點沒在統一路徑 FAIL。
- **設計 checklist**:新系統必列「涵蓋哪些實體型」+ 誠實標記。納 `docs/process/01_architect.md`。

## 覆蓋（本稿 = 窮盡）
- **76/76 production 檔逐行 sweep**(sim 66 + data 10)。debug 31(harness)/ui 12(presentation,player UI god-view 洩漏經 player_api_mapper 已含)出 scope。
- confidence 高。空白/NA 格 = 該實體在該領域無 production 邏輯(已驗非漏)。
