# 統一矩陣稽核 — 實體 × 領域結構圖（first-pass，非逐行窮盡）

> 系統產出（藍圖 `unification-matrix-program` task 1）。grep 實碼 4-domain fan-out 綜合。每格 **統一 / 補丁 / 缺口**。
> **⚠ 覆蓋誠實標記（別當窮盡稽核）**：方法 = 4 Explore agent 用 **grep pattern + 讀關鍵 function 節選**（非逐行逆向）。碰到 core AI/決策/互動/資源/戰鬥 **~25/66 sim 檔**;**沒碰/薄**：`events/*`、order_system、movement、health、outpost 片段、skill、world_generator、player 讀側片段、**全部 data/ui/debug（53 檔）**。
> **信心**：4 大 fork 區（思考決策/player-NPC/單寫者/俘虜）= **高**（grep-backed，在該住的核心掃到）;**63 格完整性 = 中**（部分格 NA/by-design 未深驗，fork 可能藏在沒掃系統=(B) 缺口風險本身）。
> → 夠挑首燒（intent-forming fork 明確），**不夠喊「不再驚喜」**。要真窮盡需逐檔 sweep（見末段）。

## ★ 結構總洞察
**所有 team 型（team/subteam/faction-member/獨立/player）= 同 `TeamData` class** → for teams 多數領域**自動統一**（population/anon/breeding/resource-read/belief-substrate 都因同 class 免費統一）。真系統性 fork **聚在 4 區**：
1. **思考決策 intent-forming**：FORKED（5 套菜單、4 條平行 scorer）← **藍圖首燒，帶出致富/征服錨**。
2. **player-vs-NPC**：primitive 多統一（2026-06-16 parity）但 **trigger/dispatch 層整條裂** + 部分 verb 全平行（betrayal/demand_tribute/recruit）。
3. **狀態所有權/單寫者（第3不變量）**：大半**未實現**（ResourceBank 被繞 53×、Pattern B driver-ledger=stub、5 ad-hoc bank、granary/purse 直寫）。
4. **俘虜兩模型**：captive_groups（NPC 活控制人力）vs prisoner_population（player 死路 int）。

## 矩陣（列=實體、欄=領域）

| 實體＼領域 | 思考決策 | belief情報 | 狀態所有權 | 物品資源 | 互動 | 人力 | combat捕俘 |
|---|---|---|---|---|---|---|---|
| **named person** | 補丁¹ | 缺口(併team,by-design) | 補丁(person.coin 死時和解) | 補丁(person.coin 無bank) | payload/target only | 缺口(無 anon→named 晉升) | 統一(kill_random tier) |
| **anon cohort** | 缺口(無agency) | NA | 補丁(captive 散寫) | 統一(AnonTreasuryBank) | payload only | 統一(AnonTierSystem) | 補丁(capture NPC-only) |
| **team(unified)** | 統一²(但零 named intent) | 統一 | 統一(bidir+erase) | 統一(ResourceBank) | 多統一 | 統一 | 統一(NpcCombat) |
| **subteam** | 補丁³(unified-tag 進不了engine) | 統一 | 統一(parent↔subteam bidir) | 統一 | 統一 | 統一 | 統一 |
| **faction** | 補丁⁴(自 _score_intents+第2producer) | 補丁(known_member_states 雙寫混epistemics) | 缺口(known_member_states 雙寫) | 缺口(無treasury,by-design) | 補丁(tribute收集/2 diplomacy resolver) | 缺口(無pop,by-design) | NA(協調層) |
| **獨立 team** | 缺口⁵(菜單截斷 建國/守成) | 統一 | 統一 | 統一 | 補丁(found_ally 走另 resolver) | 統一 | 統一 |
| **player** | 統一(手動,一致 guard) | 統一(同 best_estimate) | 統一 | 統一(同 ResourceBank) | 補丁(dispatch 整條裂,primitive 多共享) | 統一 | **補丁/缺口(EncounterSystem 全fork)** |
| **item** | NA | NA(target attr) | 統一(pool via bank) | 統一(pool checkout) | NA | NA | 統一 |
| **tile** | NA | 補丁(team_discovered/known 另冊) | 缺口(granary public_storage 直寫) | 補丁(granary 直寫繞bank) | NA | NA | NA |

註：¹named 走 reaction scorer(comply/riot/defect 另軸) ²唯一真上 DecisionEngine 但不 emit named intent ³subteam 自 `_evaluate_idle_subteam` ⁴faction `_score_intents`+`strategic_ai _update_faction_goals` 兩 producer ⁵獨立 `_evaluate_independent_strategy`(建國/守成)+`_evaluate_solo`(第3 scorer)

## Fork 清單（同領域邏輯按實體型分岔）

### 思考決策（首燒目標）
- **F-D1 決策引擎 fork**：DecisionEngine 只 unified team 用（`_decide_unified:1121`）;faction(`_score_intents`)/非統一solo(`_evaluate_solo`)/subteam(`_evaluate_idle_subteam`)/named(`_evaluate_person`)各一手寫 argmax = **4 條平行 scorer**。
- **F-D2 intent 菜單 fork（headline）**：faction{征服/致富/防衛/守成/+立國} / 獨立{建國/守成} / unified team{無(emergent)} / subteam{回歸/掠奪/攻擊} / named{P1..N5}。**無共享菜單**。
- **F-D3 faction 兩 strategic producer**：`_update_goals`(means-end) + `strategic_ai_system.gd:42 _update_faction_goals`(expand/defend/trade_net)，**擴張只在後者**、與 intent 菜單脫節。
- **F-D4 solo_intent 一槽兩義**：`_evaluate_independent_strategy` 寫戰略值(建國/守成)、`_evaluate_solo` 寫 task string 同槽。
- **F-D5 unified-tag subteam 缺口**：merchant/produce subteam 走 `_evaluate_subteam` 進不了 engine。
- **非-fork**：survival 選擇真統一（`rank_survival`，unified+非統一同漏斗，P2b-1）。

### player-vs-NPC
- **F-P1 dispatch 整條裂**：NPC 設 `current_task`;player 走平行 command registry(40+ handler)+forced_event。primitive 多共享(trade/extort/aid/subjugate/settle/diplomacy-accept)但 trigger 層分離。
- **F-P2 player demand_tribute**：`_action_demand_tribute` 手寫 coin×0.1、不走 `_resolve_extortion`（同 verb 兩路徑）。
- **F-P3 player betrayal**：`_action_betray_faction` 全平行、無 belief gate、無條件成功 vs NPC `betrayal_assessment`(belief+人格 gate)。
- **F-P4 player combat 全 fork**：EncounterSystem(tactical hex) vs NpcCombatSystem(abstract rounds)，只共享 kill_random。

### 互動
- **F-I1 兩 NPC diplomacy resolver**：`_try_diplomacy`(interaction,task,獨立) vs `handle_diplomacy_message`(diplomatic,message,faction+player)，重複 accept 邏輯。
- **F-I2 alliance faction-vs-獨立**：faction 走 `_form_alliance`(message)、獨立走 `_try_diplomacy`(task-collision)，不同 accept 數學。
- **F-I3 combat-decision verb 仍讀 god-view**：`_should_pay_tribute`/`_should_attack`/`_resolve_extortion` 讀真 strength(非 belief)，vs diplomacy/strategy verb 已 belief-gated（G3-E 部分轉換）。
- **recruit 缺口**：個體 poach = player-only、NPC 無等價（只全隊 diplomacy-absorb/merge/subjugate）。

### ⚠ latent bug 疑點（code-read,需 runtime 驗,別直接當實)
- **F-I4 NPC-NPC aid(beg)/join task 路徑疑死**：`TASK_BEG` 設 `combat_target`;但 `_try_interact` interaction:197 `if combat_target != -1: return` **先於** BEG resolver(247) → NPC beggar combat_target 恆設 → BEG branch 不可達。player beg 直呼 `_resolve_aid_request` 繞過。`TASK_JOIN` **interaction 無 handler**。→ **需 measure 驗**（NPC-NPC 乞食/投靠實際 fire 否），非直接斷定 bug。

### 狀態所有權/單寫者
- **F-S1 ResourceBank 被繞**：53 處直寫 `.resources[`(15 檔) 繞過 bank = 最大單寫者洞。
- **F-S2 Pattern B driver-ledger=stub**：`reason` 參數每 fn 有但**丟棄不記**（第3不變量「凡 state 變化必有 driver」未實現）。
- **F-S3 5 ad-hoc bank**：resource/outpost/treasury/loyalty/unrest 各自 file、無共享 ledger interface。
- **F-S4 granary/purse 直寫**：tile public_storage + person.coin 無 bank;effective_food 只統一讀側、寫側裂。

### 人力/俘虜
- **F-M1 俘虜兩模型**：captive_groups(tier/morale/treatment/assimilate,NPC 活) vs prisoner_population(裸 int,player 死路,只測讀)。
- **F-M2 minor_population 孤島**：無晉升路入 anon/named,只 famine sink。
- **F-M3 無 anon→named 晉升**：`try_promote` 只 tier 內,named 只從 person_generator 生。

## 燒優先序（矩陣據排）
1. **★首燒 獨立/faction 戰略合併**（F-D1/D2/D3/D4/D5）：intent-forming 統一成「任何 leader 一套菜單(致富/擴張/征服/守成/建國)、faction 只是執行規模 context」→ **一次帶出致富錨(獨立商隊)+征服錨(好戰隊)**。順收 F-D3(擴張併入菜單)/F-D4(solo_intent 拆義)/F-D5(subteam engine)。
2. **B R1 食物張力**（給錨牙齒接觸面,tracer 證強耦合）。隨戰略合併後。
3. **單寫者實現**（F-S1~S4）：ResourceBank 真單寫 + Pattern B driver-ledger 落地（第3不變量 enforce）+ granary/purse 納 bank。大塊、獨立 arc。
4. **俘虜統一**（F-M1）：prisoner_population→captive_groups（受控人力 Phase 2 早列）。
5. **player-vs-NPC dispatch**（F-P1~P4）：player 走 NPC 同 intent/betrayal/combat 路徑（玩家面 arc、大）。
6. **互動 resolver 統一**（F-I1/I2）+ combat verb belief-gate（F-I3）+ recruit NPC 化。
7. latent bug 驗（F-I4 NPC 乞食/投靠）+ 強制閘推廣（守 F-D 填好不退化）+ 設計 checklist。

## 強制閘 + checklist（program ②③，守住+少犯）
- **強制閘**：intent/決策/state-change 點沒在統一路徑 → CI FAIL（比照「無因令=0」）。首批守 F-D（戰略合併後）+ F-S2（driver-ledger）。
- **設計 checklist**：新決策/狀態/意圖/互動系統必列「涵蓋哪些實體型」+ 誠實標記（補丁叫補丁）。納 `docs/process/01_architect.md`。

## 覆蓋缺口 + 真窮盡 sweep（若要「不再驚喜」）
本稿 = grep+節選 first-pass，非逐行。要保證完整需**逐檔 sweep**：
- 枚舉全 119 .gd（非只 25/66 sim），每檔標「觸哪些 實體×領域格 + 統一/補丁/缺口」。
- cross-check 每個 site 類：全部 `.resources[`/`public_storage[` 寫（F-S1 只數了 53，需逐一歸類）、全部 decision/intent emit 點、全部 state-mutation、全部 interaction verb dispatch。
- 特查沒掃系統：`events/*`(defect/tag_shift/unrest×3)、order_system、movement、health、skill、world_generator、outpost 全體、player 讀側(api_mapper/query 1400+行)。
- 產出：每格附「已驗檔清單」→ 空白格=真缺口 vs 未查。**成本**：per-file pass ~119 檔，可 fan-out（按目錄/系統分批 agent）。
- **建議**：首燒（intent-forming）已明確可先開，**逐檔 sweep 平行補**（不阻塞首燒，但補完才敢喊窮盡 + 才立得起可靠強制閘）。
