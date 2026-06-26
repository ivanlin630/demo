# Invariants

## World

- 世界獨立運作
- 玩家不是世界中心

## Map

- Hex Grid Only
- 禁止 Square Grid 假設

## Time

- 大地圖與遭遇戰共用時間尺度

## Information

- 認知不等於真實
- NPC 可說謊
- 訊息可能失真
- 任何資訊命令都需傳遞 ,永不跨距離傳播,也不全知

### belief 單一 accessor + multi-claim（G3b）
- 決策/UI 讀 `team_intel` 一律經 `BeliefSystem`（best_estimate/uncertainty/claims/has_belief/known_targets），**禁直讀 state.team_intel**（含 UI/inquiry）。
- storage = `team_intel[obs][tgt]` Array of claim（值/源/時效/可信度/失真）。寫端一律 `record_claim`。
- **多源不覆蓋**：claim 按 source_id 保留，同源更新、跨源 append，**禁 confidence-max 跨源覆蓋**（否則矛盾無從察）。
- **真值不隨行**：傳播失真寫 copy（`_distort_intel_entry` 回新 dict），原 claim 不被改。
- best_estimate = 最高 **effective_credibility** claim 的 value（G3c-1 真公式，含時效）。uncertainty = **credibility-weighted**（G3d-2 重定義，見 belief 段 G3d-2 條；取代舊 raw `(max-min)/max`）。
- caps：每 (r,t)≤MAX_CLAIMS_PER_TARGET、每 observer≤MAX_CLAIMS_PER_OBSERVER（TEST VALUE，剪低可信/最老）。
- 讀容錯（transitional）：accessor 遇舊式 Dict（test 直設/漏遷）coerce 成單親見 claim。canonical 仍 Array，生產寫端強制 Array。G3c 可收緊。

### 可信度公式 + 身份信任（G3c-1）
- **可信度公式**：claim 排序用 `effective_credibility = source_credibility(類型基準 CRED_BASE × 身份信任 × 跳數衰減) × 時效衰減`。寫時 cred 存進 claim（時不變部分），讀時乘 time_decay → 新鮮勝陳舊。**禁在 BeliefSystem 外算 claim 可信度**。
- **身份信任 = `TeamData.known_reputations[source]`**（team→team 動態，0..1 default 0.5，`update_reputation` clamp）。claim source = giver team → 複用既有 team→team 信任，**不開 RelationGraph person 邊**（team-keyed 不需 per-信使邊）。known_reputations 兼外交/施捨/勒索口碑 = 預期 coupling（量測顯衝突再拆專用 trust）。
- **source_type = 真來源類別**（親見/隊友/商旅/流民，非 distort mode）；失真另存 `distorted` flag（兩維度分離）。relay 分類：同 faction→隊友、商隊 tag→商旅、else→流民。
- **身份信任迴路（被動）**：record_claim 寫入親見後，比對同 tgt relayed claim 的 pop_est → `update_reputation(source, ±TRUST_DELTA)`（比值近 1 升、離譜/失真降）。被動偶遇既有 relayed 才跑，scout 主動查證 = G3d。
- **relay hop 只算一次**：message 傳播 cred 走 `source_credibility(...,hop=1)`，不再 `(1-HOP_DECAY)*confidence` 疊（修 G3b 雙重 HOP debt）。

### 技能識破 + 觀察吃技能（G3c-2）
- **技能識破**：收 distorted claim 時 `detection_discount(我 max(偵查,計謀), 對方計謀)` 折 claim credibility（信假1.0/生疑0.5/裁決0.2）。**非 un-distort**（值不動，只壓信）。效果經 best_estimate cred 排序（謊低於誠實/親見）。`is_suspicious` 由分級寫（降為 UI/G3d 提示 flag，非唯一效果，不再 dormant）。
- **觀察吃技能**：親見值噪 = `observation_noise(距離噪, 觀察者技能)`，低技能殘留噪 → 高 conf 親見可錯值（cred 仍 1.0）。源頭 claim 正確性 = 觀察者技能函數（vision pop_est 吃偵查、interaction armed_est 吃戰術）。

### 決策風險 gate（G3d-1）
- **攻擊性 commit 讀 uncertainty**：攻擊性決策（faction_ai 掠食/攻擊鎖定 prey、外交求貢）commit 前經 `BeliefSystem.confident_enough(state, 觀察者, 目標, 慎重)`——`confidence=1-uncertainty`，`threshold=lerp(GATE_CONF_LOW,GATE_CONF_HIGH,慎重)`。不確定且慎重 → 本 tick 不 commit（**被動按兵**，下次 cadence 重評，靠後續親見壓低 uncertainty）。莽者門檻低→照衝→假情報誘殺。
- **只 gate 攻擊性主動選擇**（belief-弱→主動攻/敵對）：prosperity attack + survival loot（`_find_weakest_prey`）+ 外交 demand_tribute。**不 gate**：威脅(防禦,極性相反 → G3d-2)、vendetta(私仇確定性脫軌 G2d)、結盟/求和。survival loot gate 失敗 → 落回其他絕境路徑（回家/覓食），不凍結。
- **不凍結**：親見單源 uncertainty≈0 → confidence≈1 → 恆過 → 正常掠食/攻擊不受影響；gate 只咬矛盾多源高 uncertainty。
- scout 主動查證（不確定→派斥候→親見壓謊→才動）= **G3d-2 ✅**（見下）；威脅(防禦)uncertainty-gate 仍延 post-measure。

### scout 主動查證 + cred-weighted uncertainty（G3d-2）
- **uncertainty = credibility-weighted**：`clamp((1−top_eff_cred) + cred 加權值分歧, 0, 1)`，`top`=最強源 effective_credibility，分歧 = `Σ wᵢ·|vᵢ−best| / (Σwᵢ·best)`（wᵢ=eff_cred，vᵢ=claim pop_est，best=best_estimate pop）。親見高 cred 主導→top→1 + 假源時效衰權重低→分歧小→壓低不確定（查證可收斂）；純未驗 relay→(1−cred) 高；雙新鮮高 cred 矛盾→分歧高。無 claim→1.0。取代 G3b/c raw 分歧公式。**禁在 BeliefSystem 外算 uncertainty**。
- **scout 查證迴路**：攻擊性 commit gate-fail（慎重者不確定）→ 不再被動按兵，改 dispatch `TASK_SCOUT`(move_target=prey best_estimate 位，`PRIO_DISPATCH`，reason `"scout"`)，記 `prosperity_target_id`=prey，**不設 combat_target**（純觀察）。斥候移入視野→親見壓謊→下 cadence uncertainty 降→confident→`release` scout 後 try_set `TASK_ATTACK`（同 PRIO_DISPATCH 須先 release 換手）。莽者(低慎重)恆過 gate→不 scout→攻假 belief→誘殺。
- **收斂保證**：scout 中允許重評（`_evaluate_prosperity_attack` 不對自家 scout 早退）；逾 `SCOUT_TIMEOUT`(TEST VALUE) 未收斂→`release` 回常規（防永 scout 卡死）。prey 親見後顯示強→find_prosperity_prey 不選→自然放棄（避誘殺）。scout 同 PRIO_DISPATCH 可被生存/威脅高層覆蓋（不凍結）。

### 攻擊目標選擇讀 belief（G3-targeting）
- **選擇層讀 belief**：`find_prosperity_prey`/`_find_weakest_prey` 的 prey 價值(richness)/弱點(weakness/pop)一律經 `BeliefSystem.best_estimate`，**禁直讀 prey 真 population/resources/armed**（god-view）。自身真值(`team.population`)照讀（自己不靠情報）。
- **無 belief 不評估**：候選經 `has_belief` 守衛，無情報→`continue`（**禁 fallback 回真值**，否則 god-view 回潮，違「team_discovered 僅可見性不作真值」）。
- **weakness 吃 armed_est**：`clamp(1 − armed_est/max(team.pop,1), 0,1)`，`armed_est = bel.get("armed_est", pop_est)`（tier2 偽裝低報在此咬；tier0/1 無 armed→退 pop_est）。richness 經 `_belief_richness`：tier2 資源估 sum/100 → 無 tier2 但有 `resource_scale` 粗估 → 皆無 0（TEST VALUE）。
- **誘殺載體**：偽裝(低報 armed_est)/失真 relay → 假弱 belief → 選假弱目標 → 戰鬥按**真**實力結算 → 莽者踢鐵板、慎重者 scout(G3d-2)看穿真強後不選。選擇層(價值)+gate(把握 G3d-1)兩層齊 = 誘殺脊椎閉環。位置/reachability 屬可見性物理(PathSystem 讀真位)，不在此限。

## Simulation

- Event = Consequence
- 禁止 Scripted Outcome
- **遍歷 id 快照前必驗存在**：team/person id 陣列是 tick 開頭的快照，元素可能在本 tick 內滅團/死亡被移除；存取 dict 前先驗 `.has(id)`，否則 Invalid get index

## 關鍵設計規則

- **不直接 script 結果**：所有行為從 NPC values/skills/stress/loyalty 計算產生
- **新功能前定義**：影響的世界狀態、資訊流動、時間消耗、受影響群體、二次後果

## 對稱性

- **無玩家專屬機制**：任一交互 / 生存系統（戰鬥 / 貿易 / 外交 / 覓食 / 狩獵 / 任務 / 賞金…）NPC 必須同樣能用
- 玩家與 NPC 走同一套底層數學；差別只在玩家可手動接管、NPC 自動解算

### 敗方損耗對稱
- encounter 與 npc_combat 敗方結算皆對敗方整隊 anon pop（**含未上場 reserve**）施 tier 加權陣亡（`AnonTierSystem.kill_random` + `SURVIVAL_KILL_WEIGHT`），無玩家專屬豁免（game-design §對稱性）。
- pop 變動只經 cohort API。武裝下限 `ARMED_RATIO_FLOOR` 在消費端（encounter spawn / npc 戰力）套用，不覆寫 `armed_anon_ratio` 推導值。

## 玩法節奏

- **decisions-not-chores**：玩家做決策，模擬跑雜活；壓力存在是為製造決策岔路，不是逼玩家重複操作
- 可跳時間；事件只在 juncture 介入
- **激情時刻全手動 + 真風險**，且主要由玩家冒險決策觸發（非隨機 spam）

## UI 邊界

- **UI 只經 player API**：UI 層（`scripts/ui/*`）禁止直讀/直寫 `WorldState`；一切經 `SimBridge` → `PlayerQueryApi`/`PlayerCommandApi` 的 DTO
- **DTO 是 UI 契約**：玩家 UI 需要的任何 sim 資訊，必須 map 進 DTO（非讓 UI 繞道取）→ 換 UI（文字↔圖形）只需接同一 API

## NPC

決策來源：

- Values
- Skills
- Needs
- Memories

禁止硬編碼結果

## Interaction

- **嚴禁非同格互動**：戰鬥 / 貿易 / 外交 / 投靠 / 徵收 / 信使 / 安頓 / 安撫 全部需 `team.tile_pos == other.tile_pos`
- 觸發點：`interaction_system.process_on_move`（mover 對全 team 掃同格 → try_interact）

## Anon

- anon 是 team-level 抽象集體，**無個體 entity**
- 統一儲存於 `team.anon_cohorts`（稀疏 dict，鍵 `"tier|health"`→count；tier ∈ 平民/新兵/老兵/菁英，health ∈ healthy/wounded）
- 變動只透過 `AnonCohort`（add/move/remove）或 `AnonTierSystem`（add_anon/remove_anon/kill_random/wound_random/heal_random/kill_wounded/transfer_proportional/try_promote）
- `population` / `wounded` / `anon_combat_skill` / `anon_wage` 為 computed getter（投影自 cohort，**不可直接寫**，舊 set no-op）
- 入團時保留來源 tier（戰俘 / 投靠 帶原 tier 進入）；受傷 = move healthy→wounded；晉升 named/leader 從 anon 桶移除 1

## Task

- `current_task` 是團體狀態（不是個體）
- `combat_target` 是「正在戰鬥」flag（戰鬥中設、結束清）
- `prosperity_target_id` 是「想攻擊誰」意圖（攻擊 AI 評估時設）
- 兩者語意分離，不可混用
- **每個高優先 task 必須有釋放條件**：進得去必須出得來，否則凍結世界（高優先 task 蓋住一切）

## 財產 / 守恆

- **居民私產與統治者公庫永不混淆**：私產（採集稅後）vs 公庫（owner 稅金）兩錢包分明
- **建造資源嚴格本地**：建材來自施工團自身 + 腳下據點公庫（兩源皆可），不可動用他處據點的資產（非隔空遠端取物）
- **有限資源守恆**：建造永不消耗有限資源；任何死亡 / 滅團，資產走守恆路由，永不憑空銷毀
- coin 只能由鑄幣產生，無其他來源

## 飢餓 / 人口

- 飢餓判定唯一來源 = 團糧（個人不另算飢餓）
- 死亡順序：弱者先死（minor → anon → named）
- 生育是生命事件（可與行動並行），不與行動反應競爭單一名額

## 資料模型不變量規則（防散落純量 drift）

1. **可衍生聚合 → computed getter，不存可變欄位**。任何 `= f(權威來源)` 的值用唯讀 getter（範本 `team_data.population` / `wounded` / `anon_combat_skill`）。物理上不可 drift；加人必須動真來源（named_members / anon_cohorts），不能偷改數字。
2. **來源/雙向關係走單一入口**。anon 改動走 `AnonCohort`/`AnonTierSystem` 入口；勿直接 `anon_cohorts[k] = ...`。
3. **不可衍生的真存量 / 不變量 → 註冊進 `InvariantAudit.check`**。真存守恆量（coin_eq）、cohort 自洽、faction/subteam 雙向等靠 audit 守。加新不變量 = 加一個 `_check_*` 並在 `check()` 呼叫。
4. **改資料模型前讀本節。**

## team reference 契約

移除 team 一律走 `state.erase_team(tid)`（唯一 chokepoint，清光所有指向它的 ref）。但解析時分兩類 —— **實證後的區分**（2026-06-18 batch1 子 session 證偽「全部納管 ref 永遠活」）：

### A. 維護集合元素 → 保證活 → `require_team`
`faction.member_team_ids` / `subteam_ids` / `team_known[obs]` / `team_discovered[obs]` 內的元素由 erase_team + 雙向 audit 持續維護，迭代時**每個元素必活**：
```
for tid in faction.member_team_ids:
    var t := state.require_team(tid)   # 保證活，不檢 null
```
這類**不可**寫 `if t == null`（dangling 不可能；寫了=死碼）。

### B. 單一可變 target 欄位 → 可瞬時懸空 → 保留容忍/自癒
`combat_target` / `order_target_id` / `parent_team_id` / `faction.leader_team_id` 是單欄位 target。**tick 內有瞬時懸空窗**：setter 可能從快照塞入「本 tick 稍早被 erase」的 id（setter 未驗存在）；erase_team 清得乾淨，但下個 setter 又塞 stale。月 audit 抓不到（自癒/cleanup 在取樣前清掉）。
→ 這類**保留** `teams.get()` + null 容忍/自癒（`if t == null: 自癒清 -1`）。**那些 guard 是 load-bearing 處理真瞬時態，非壞味道，勿改 require_team**（會在瞬時態崩）。

### 不納管（照舊 `teams.get()` + null）
玩家輸入 tid、`teams.keys()` 快照迭代期間可能已 erase、persons/tiles/factions 等非 team-ref lookup。

> `require_team` 對不存在 assert（debug 抓持久懸空 bug、release 剝離保韌性）。只用於 A 類。要讓 B 類也成立 = 修所有 setter 驗存在（大、收益邊際，因 guard 已正確處理瞬時態）→ 不建議。

## Leader 繼承單一 owner

- **繼承邏輯單一 owner = `EventSystem.on_leader_death(state, team) -> bool`。** 偵測單一點 = `faction_ai` 每-tick 安全網（`leader_id==-1` → 呼 owner）；`npc_combat._kill_named_npc` 戰中即時呼為效能捷徑（非另一 owner）。
- 禁止在 `on_leader_death` 外自行決定繼承人 / promote。裸置 `leader_id = -1` 僅允許作 transient（須由安全網次 tick 補位）。
- 分派：player → forced `choose_heir`（named 空則 `game_over`）；NPC → best named 無門檻晉升 → 無 named 則 anon 晉升 → 皆無回 `false` 滅團。晉升成功後呼 `PopulationSystem.check_overflow_for_team`（弱 leader → pop_cap 溢出回饋）。
- player 分支偵測靠 `WorldState.get_player_team_id()`（單一源）。但**死者 person 已 erase 時偵測查不到**（leader_id=-1 且不在 named）→ 已知是 player team 的 external caller（encounter `_check_player_wiped`、player_command stale-heir 終局）**直呼 public `EventSystem.handle_player_succession(state, team)`** 繞過自動偵測。所有真實路徑呼 `on_leader_death` 時死者 person 尚在 `persons`（combat 在 erase 前呼、famine/encounter/安全網從不 erase）→ 自動偵測對它們成立。
- 冪等：`on_leader_death` 的 player 偵測分支對已 pending 同隊 `choose_heir` 直接回 `true` 不重設（安全網每 tick 重呼）；`handle_player_succession` 本身不帶冪等（external caller 要即時重評）。

## 關係圖（typed-edge）

- typed 關係事實只經 `RelationGraph`（add_edge/edges_of_type/edges_to/strongest）寫讀 `PersonData.relation_edges`。
- 圖核心**型別無關**：只按 `type`/`target` filter；加新型別 = 加 reader，**禁改 RelationGraph 核心**（WHAT spec §4 硬約束）。
- 扁平 `relations`（純量泛好感）與 typed 圖**語義分職**並存：前者連續情感（loyalty/反應），後者事件型關係邊（feud/protect/gratitude/killed）。
- G2 用型別：`feud`/`gratitude`/`protect`（write_memory 填）/`killed`（G2d 死亡鏈）。未來 `kin`/`spouse`/`master` 等同型塞入。
- 回傳：`true`=已處理（含 player pending）；`false`=無繼承人 → caller 滅團/faction 解散。

## 私人脫軌（血仇）

- feud 邊由戰鬥（looted/betrayal/extorted 記憶 → G2a `write_memory` 映射）populate（敗方含 leader 對勝方獲 feud）；本層只加 reader，不重做血仇 populate。
- `NpcAiSystem.vendetta_target` 讀 leader 最強 feud 邊 + 衝動 gate（好戰 ≥ `VENDETTA_BELLIGERENCE`、慎重 < `VENDETTA_PRUDENCE`、intensity ≥ `VENDETTA_INTENSITY`，全 TEST VALUE）→ 回仇人 team_id（存在且非自隊）否則 -1。冷靜 leader 隱忍不脫軌。
- 脫軌 = `faction_ai.evaluate_all` 在 `_evaluate_threat` 後以 `TaskArbiter.PRIO_VENDETTA`(55) try_set TASK_ATTACK：生存(80)/威脅(70) 擋得住、prosperity(50) 擋不住。置於 threat 後因 `_evaluate_threat` 只在 idle 動作 → threat 先佔 task 則 vendetta@55 搶不動（威脅優先）。
- `relation_edges` 的行為 consumer = `vendetta_target`（G2a 圖不再 dormant）。pre-existing dormant `NpcAiSystem.get_goal_task_override` 已刪（revenge 意圖由本路徑經 G2a 圖取代）。

## 訂單系統

- 訂單權威存發起隊 `active_orders`；`emit_message("order_buy"/"order_sell")` 為**可失真傳播副本**（殘缺市場知識湧現，復用 message propagate/distort）。
- 履約/讀取依 message 副本，須回發起隊 active_orders 核對（撲空 = 副本過期/失真，G1d）。
- 生產需求偏好讀 `OrderSystem.received_buy_orders`，不另建需求表。同格本地交易沿用既有 interaction trade；跨格商隊 = G1d。
- 商隊（商業 archetype）目標**讀收到的訂單**（`team_known` order message = 殘缺/可失真，`OrderSystem.best_arbitrage_order`），**禁讀 `team_discovered` 上帝視角**挑貿易對象（接「目標決策讀殘缺情報」總則）。`_find_trade_target`（team_discovered）降為無訂單時 fallback，最終應刪。到場履約走既有 interaction 同格 trade。
- 短缺發買單：`tick_team_orders` 對 `_ORDER_ELIGIBLE_RES` 中低於 `SHORTAGE_QTY` 的料/武器 res post buy order（生產買單來源，閉 G1b 半 inert）。
- 撲空 = 訂單過期/失真 → 到場供需已變 → 既有 `local_value` glut 給壞 deal（**無新機制**）。準情報值錢，為 ③G3 鋪路。

## 隊目標單一 owner = leader 野心階梯

- 隊無獨立目標。`TeamData.ambition_rung/archetype/cap` 由 leader values + 隊安全經 `AmbitionLadder` derive，**單一真值源**。換 leader → 重 derive（方向劇變）。
- faction strategic_goals **衍生**自 faction-leader 階梯（`strategic_ai._update_faction_goals` 讀 rung/archetype），禁他處獨立定隊/勢力戰略目標。
- 階梯門檻/權重全 TEST VALUE（正式平衡 pass 調）。rung→每階 task/tag 全表 = G2c ✅；個人脫軌（血仇）= G2d ✅（見「私人脫軌」）。
- 隊常態行為由 `AmbitionLadder.rung_task(archetype×rung)` 驅動（既有 TASK_*，零新 task），`PRIO_AMBIENT` 只填 idle。生存 rung→`_trigger_survival`；武力擴張→prosperity；立國/稱霸→faction strategic(G2b)。極絕境/威脅/脫軌(vendetta)優先序皆高於 ambient ladder。

## 混合協調（faction stakes vs team 日常）
- **stakes-to-faction → 頂層協同；team 日常 op → 個體**（ruling §1）。stakes 集合 = **攻擊/徵收/外交**（`DecisionContext.STAKES_SET`；後續可擴大徵收等）由霸主 `_update_goals` 設 `f.goals`（readiness/belief gate=稀有蓄意）；unified 隊經 `faction_duty` term 響應。日常（貿易/掠奪/scout/survival）無 faction_duty=各隊個體決。**立國 = leader-level（`_declare_established`，非 member option，不在 stakes 集合）；掠奪 = 日常個體（非 stakes）；結盟 ⊂ 外交。**
- **頂層決 WHETHER，人格染 HOW**：派系 directive 決定「要不要做」；member 經對應 option 的個人 drive×weight 染色執行強度。染色映射：攻擊=`attack_drive×attack`(好戰/殘忍)、徵收=`levy_drive×levy`(貪婪/好戰)、外交=`diplo_drive×diplo`(義氣/計謀)。協同≠同質。
- **stakes target finder**：攻擊/外交→`_nearest_independent`（最近獨立隊）；徵收→`_richest_member`（同 faction 最富 member，**雙重排除自身** `== team.team_id`，因 `_richest_member` 未排自身）。徵收/外交=非戰（不設 combat_target）。
- **脫軌逃閥**：`faction_duty` weight **與** 個人 drive（`attack_drive`/`levy_drive`/`diplo_drive`）共用脫軌因子 `_duty_factor = clampf(loy − max(0,野心−0.5)×DEFECT_K, 0,1)` → 低忠誠+高野心 member 的 duty 與個人驅力齊壓 0 → 個人驅力（survival/野心/貿易）蓋過 → 不參與/自走=破framework脫軌。faction_duty 是**加權 term 非 hard override**（非 100% 服從，by construction）。
- **危時不為派系做事**：survival-class term 危時量級碾壓 faction_duty（食物優先；攻擊/徵收/外交皆然）。
