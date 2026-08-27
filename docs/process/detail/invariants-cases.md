# invariants 的血證與案例（按需讀，不在開場必讀區）

**必讀版留【規則本體】，這裡放【它為什麼成立】。**

> ★**2026-08-25 #4：開場讀不完的規則，等於不存在。**

## Time

凡時間量              必從 TimeScale 骨架導出（禁裸硬編 tick）
凡移動                大地圖格 = 遭遇戰動作 × 遭遇戰地圖尺度（連動,不准倍率打破）  ← 錨①②
凡延遲/timeout/cadence  以語意單位（TimeScale.days(N)/hours(N)，非裸 720）
```
- **單一權威源 = `TimeScale`**（`scripts/simulation/time_scale.gd`）。承既有根：`TICK_PER_DAY`←WorldState、`BASE_ACTION_TICKS`/`ENCOUNTER_MAP_SCALE`←EncounterSystem。**單向依賴 TimeScale→{WorldState,EncounterSystem}，反向禁**（循環）。新碼一律 `TimeScale.*`。
- **錨①（移動連動,釘死）**：`MOVE_TICKS_PER_HEX = BASE_ACTION_TICKS × ENCOUNTER_MAP_SCALE / WORLD_SPEED_MULT`。`MovementSystem.BASE_MOVE_TICKS` 唯一讀站走此連動式。**★A1/A2 拆片（藍圖 timewave-five-rulings）**：**A1（現行）= ×5 先留 → MOVE=240/5=48（零行為變,骨架 refactor 即 merge）**；**A2 = 拿掉 `WORLD_SPEED_MULT`(×5→1)→ MOVE=240=1天/hex**，綁 ④沿途補給+FOOD 消耗重校+gen 承載力重校 **四件一個 landing**（缺補給裸切 ×1=餓死潮,已 measure 證 10 格斷糧）。A2 落地後此錨終值=240、mult 刪、禁再塞倍率。
- **錨②**：`ENCOUNTER_MAP_SCALE = EncounterSystem.MAP_DIAMETER = 24`（遭遇戰地圖尺度,不變）。
- **錨⑤（觀看組不碰物理）**：倍速靠 GUI（TICKS_PER_SECOND/TURN/DUMP 橋），非改時間尺度。
- **enforce 進度**：**A1 立骨架單源（×5 留,零行為;headless time-invariant assert 守 MOVE=48）**；A2=×5→1+補給+FOOD+gen 四件；B=far elapsed ✅（一修 V1 trade+V4 envoy+V3 帶禮結盟,merged）；**③序0 done ✅（10 裸 cadence/timeout const 導出 `TimeScale.TICK_PER_DAY*N`＋FLEE 硬編240修＋eta/240→/TICKS_PER_DAY＋near/far hoist 進 gate,全零行為變 seeded 46/8/1/380 守恆）**;CI 掃裸 tick/倍率=後段。**FOOD/FATIGUE per-day 率=A2 重校對象（×5 手校痕）**；跨格旅途糧耗（×1 下 5× 增）=④完整食物收支 measure。
- **解析度旋鈕（藍圖 tick-resolution-60）**：`TICKS_PER_HOUR`（現 10）= 時間解析度旋鈕（動根字面 `TICKS_PER_DAY 240→1440`），`BASE_ACTION_TICKS=10` 遭遇戰動作粒度守速度鑑別度**釘死**。60 下運算安全（掃證：唯 `_get_near/far_teams` O(N) 需 cadence 化,餘 O(1)）;**序0 已修 ✅**（near/far hoist 進 gate＋10 常數導出＋eta/FLEE，全就位；根值仍 240 待 A2 切）。**`PRISONER_CHECK_INTERVAL=5` 非違規**（活凍結遭遇戰 time-frame,measure 證藍圖定性有誤）。

### ★ 空間尺度骨架（矩陣新維度，時間的空間孿生，藍圖 space-dim-freq-gate，2026-07-05，enforce 起步）
```
凡空間量  必從遭遇戰動作粒度錨導出（一格真實距離 → 據點密度/min_spacing/地圖 radius 連動）,不各自硬編
```
- 病：「一格多大」散三處（遭遇戰 `MAP_DIAMETER=24` / 據點 `min_spacing`/`total_count` / 移動 `MOVE_TICKS_PER_HEX`）= 空間版時間常數污染。
- **矩陣加第二跨切維度「空間尺度」**（配「時間尺度」，非綁單一實體，與意圖/belief/state/人力/互動同級）。單一來源=遭遇戰動作粒度錨。
- **強制閘**：掃裸硬編地圖大小/據點間距/移動成本（繞骨架）=fail。
- **enforce 起步**：本 arc（TICKS_PER_HOUR 調 + 據點反推）=首次落地,非結束；散落點=`game_setup.gd:66/73/74`(config radius/count/spacing)、`encounter:174/175`(MAP_RADIUS/DIAMETER)。**時間-空間橋**：一格真實時長 = `MOVE_TICKS_PER_HEX / TICKS_PER_HOUR`（60 下 240/60=4h/格=據點密度合理化,「1天/hex」語意隨解析度變=預期）。
- **運算頻率 = 非維度**（藍圖釘清）：= per-tick 有界 + 時間量必導出 兩既有不變量的閘檢查,非新格。裸 tick 常數導出=時間閘直接應用;每 tick 無條件 O(N) 迴圈=per-tick 有界守門對象。


## Information


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
- **收斂保證**（序5 後：scout 機制在 `_commit_conquest_attack`/`_tick_conquest_scout` scaffolding，非已刪的 `_evaluate_prosperity_attack`）：scout 中允許重評；逾 `SCOUT_TIMEOUT`(TEST VALUE) 未收斂→`release` 回常規（防永 scout 卡死）。prey 親見後顯示強→find_prosperity_prey 不選→自然放棄（避誘殺）。scout 同 PRIO_DISPATCH 可被生存/威脅高層覆蓋（不凍結）。

### 攻擊目標選擇讀 belief（G3-targeting）
- **選擇層讀 belief**：`find_prosperity_prey`/`_find_weakest_prey` 的 prey 價值(richness)/弱點(weakness/pop)一律經 `BeliefSystem.best_estimate`，**禁直讀 prey 真 population/resources/armed**（god-view）。自身真值(`team.population`)照讀（自己不靠情報）。
- **無 belief 不評估**：候選經 `has_belief` 守衛，無情報→`continue`（**禁 fallback 回真值**，否則 god-view 回潮，違「team_discovered 僅可見性不作真值」）。
- **weakness 吃 armed_est**：`clamp(1 − armed_est/max(team.pop,1), 0,1)`，`armed_est = bel.get("armed_est", pop_est)`（tier2 偽裝低報在此咬；tier0/1 無 armed→退 pop_est）。richness 經 `_belief_richness`：tier2 資源估 sum/100 → 無 tier2 但有 `resource_scale` 粗估 → 皆無 0（TEST VALUE）。
- **誘殺載體**：偽裝(低報 armed_est)/失真 relay → 假弱 belief → 選假弱目標 → 戰鬥按**真**實力結算 → 莽者踢鐵板、慎重者 scout(G3d-2)看穿真強後不選。選擇層(價值)+gate(把握 G3d-1)兩層齊 = 誘殺脊椎閉環。
- **★位置語義澄清（2026-07-18，感知鐵律空間延伸）**：原「位置/reachability 屬可見性物理讀真位」**僅指地形**——拆兩事：①**地形/pathfinding cost/reachability = 物理真值**（PathSystem 讀真 tiles、A* 走真地形，合憲）;②**他隊「當前位置」= belief last-seen 非 live 真 `tile_pos`**（決策移動目標讀 `BeliefSystem.belief_pos`，範式=攻擊 to_task `options.gd:194`「攻擊 target 走 belief last-seen」）。**讀他隊 live `tile_pos` 作決策移動目標 = god-view（跟蹤已脫離視野的隊）= 違憲**。已知殘留(slice2 修)：threat DEFEND/求和 `decision_context.gd:192`→`options.gd:294/305` 讀 live threat_pos（與攻擊 belief 不一致）。
- **★threat evasion = intended 深度（blueprint 裁 2026-07-18，勿當 regression 修回）**：threat DEFEND/求和走 belief last-seen ⟹ 敵脫離視野可甩掉你的威脅反應（你朝最後見到位追，非瞬鎖真位）=**伏擊/脫接觸/佯動湧現玩法**，非 bug。belief staleness 自限（不永追鬼影）。**未來勿以「威脅反應追丟了」為由改回 live-track**（=違憲換皮）。威脅反應憑啥獨全知——同攻擊/FLEE。

### 決策讀 belief 非真值（G3 Phase E — provenance enforce）
- **信息域不變量**：凡決策評估**他隊**的 pop/food/armed/實力**或當前位置(tile_pos，作移動目標)**，一律經 belief（`BeliefSystem.best_estimate` / **`belief_pos`**，追得回 provenance），**禁直讀 `other.population`/`.resources`/`.armed`/`.tile_pos`（god-view 真值）**。比照決策域「無因令=0」硬約束：決策直讀真值 = 違規（=「自信地錯」的地基，欺敵才有後果）。已知殘留(slice2)：`absorb_yield`(decision_context.gd:369-372 讀 target 真 food+pop)、threat-move(讀 live threat_pos)。
- **★★資訊永遠傳播、無 dead-end；fog 靠延遲/decay 非硬擋（2026-08-03，用戶定、systems invariant-owner；★更正同日早先「intra-faction 直接 perceive carve-out」誤framing——用戶否定開特例後門）**：資訊模型**一個、零特例**。**任何消息（含饑荒/需求/威脅）always 經 belief/carrier 系統擴散、傳得到（無死角 dead-end）**；戰爭迷霧**不是靠「硬擋某些隊看不到」保住、而是靠「延遲 + decay/distortion」**（遠/敵=舊/模糊、近/自家=快/reliable）。∴ **決策照 belief 行動**（延遲但終會知），**禁為「讓 X 知道 Y」開直讀真值後門**（=特例違此模型）。
  - **intra-faction vs cross-faction＝傳播速度/保真度差、非有無**：自勢力內部消息傳播**快、reliable**（低 decay、`_decide_propagation_mode` 義氣高）；cross-faction/rival **慢、decay/distort 重**（fog 在此自然湧現）。兩者**同一 propagation 機制、參數不同**，非兩套。
  - **★現況 dead-end＝待修病根**：`propagate_on_arrival:79 if other_team.tile_pos != arrived_team.tile_pos: continue` 令傳播**只在共位發生**——settled 不共位→消息 dead-end 永不傳（違「無 dead-end」）。§5 root L1（領主不知自家居民餓）＝此 dead-end 症狀。**修法方向＝讓 propagation 無死角（延遲/decay 保 fog）**、**非**領主直掃居民特例（用戶明否）。HOW spec 待 blueprint user-confirmed reframe。
  - **decay 骨架已在**（勿重造）：`propagate_on_arrival:103` `strength*(1-HOP_DECAY)*time_factor`、<0.05 drop、義氣/慎重 distort（:111/117）——延遲/衰減零件齊，缺的是**無死角的傳播拓撲**（跨距 carrier/relay，非只共位）。
- **★★god-view belief-化 arc COMPLETE（2026-07-21，機器強制）**：全 leak 治完（**A/F/E/D/B/C + null-belief-flee + 1119 + followup**）——敵情/威脅/追擊/創世/市場/可達性(can_reach)/join(jhost)/選址(enemy_outpost) **全 belief 化**，零 god-view cheat。**★machine 證＝`constitution_gate.gd` v3 god-view detector**（`gv_teamstate`=indexed `state.teams[id].動態欄` / `gv_mapscan`=whole-map `for x in tiles`；GV_FILE_RE 含 threat_assessment；enumerate-not-classify，凍 baseline_v2.txt，NEW=FAIL）**續守回歸**——任何新 indexed 他隊 live 態讀 / whole-map 決策掃 → gate FAIL。**detector 揪出人審(+異質 R²)漏的 2 殘留**（`_enemy_outpost_positions` 全圖敵據點 + `decision_context:373` jhost）＝**機器證 > 人審 completeness 的實證**（連 [[feedback_structural_audit_complement]]）。**限制**：靜態 regex 分不出 loop var 自/他（不抓 `for t in teams: t.tile_pos`）＝回歸閘非證明，細粒度靠 review。**現存 baseline god-view site 全 legit**：gv_teamstate 1（`consolidate_target_of` 同-faction own-member pop=faction 知自家人）+ gv_mapscan 10（self/地理/own-infra + `_enemy_outpost_positions` belief-filtered gate-ok）。**doom-delta 哲學後果（blueprint accept）**：AI 不再全知瞄準→世界更靜、擴張更少（conq.declared -22%）、某些隊獨自撐不住餓死＝**機制正確的真實 trade-off 非 bug**。
- **★nearby-scan/LOD landmine（2026-07-18，連 [[時間統一 wave]] O(N²)）**：未來「只掃附近隊」的空間優化（LOD / reachability / intercept 預測）若**餵決策**，鄰隊位置一律 **belief last-seen 非 live `tile_pos`**。**★★訂正（2026-07-19 god-view audit，systems 前述「死碼」誤=grep glob bug 漏頂層檔）**：`path_system.gd` `observe_velocity`/`estimate_catch_up`/`predict_intercept`/**`_is_moving_away_observed`(226)** 讀 live `target.tile_pos` = god-view，**非死碼——production caller 以 `trusted=true` 跳 discovery 讀 live 位置**。stats(pop/food/armed) 已 belief-gate，**唯 position/velocity leak**。= **live god-view 違憲待修（god-view 殲滅 arc Slice D，最大塊）**。**★★caller inventory 訂正（reviewer 異質審 file:line 親驗 2026-07-20，前列行號 stale 勿信）＝10 caller**：`faction_ai:205/293/1403/2134/3607/3636/3666/3715/3747` + `threat_assessment:27`；~~3596~~ 非 caller。**★修法差異化（velocity≠position，異質 R² BLOCKER）**：velocity func（observe_velocity/predict_intercept/_is_moving_away_observed）斷視線→**invisible**（belief 無 velocity time-series analog，不可 last-seen）；position func（estimate_catch_up catch_cost）斷視線→belief last-seen 合法。freshness=`belief last_tick==current_tick`（鏡射 `_refresh_attack_pursuit:269` 但**分 velocity/position 語意**）。predict_intercept sentinel+envoy caller(1403) lockstep。詳 spec `2026-07-20-godview-slice-D-pathsystem-freshness-gate.md`。
- **★★`value.last_tick` 語意（Slice D freshness 前提，systems 裁 2026-07-20）**：= **位置最後被 firsthand 直接確認的 tick**。**firsthand 兩路都須寫**：①`vision:114`（親見 LOD）②`BeliefSystem.record_claim` 親見（`source_type=="親見" and source_id==obs_id`）——**後者原漏寫=Slice D belief-freshness 縫（14 fixture fail 症狀）→ 裁 A 補寫 `value.last_tick=current_tick`（治根非補 fixture）**。relayed claim（轉述 source≠obs）**不寫** last_tick（轉述≠親見 fresh→該當 last-seen 非「本 tick 可見」）。freshness gate（`last_tick==current_tick`=本 tick 親見）靠此語意一致。
- **★★掃近隊兩-channel（blueprint/用戶定 2026-07-18，遠方危險不得隱形）**：perf 靠「掃近隊」bound 的是**直接感知成本**，**禁把掃近隊當唯一 belief 填充源**。awareness 經 belief，belief **兩源填**：①**直接掃近隊**（近隊進 belief）②**情報網**（message/relay/known_reputations 把**遠方**高危險傳進 belief，獨立於直接掃）。∴ scan-nearby 優化**不得**讓遠方強敵隱形（=戰略盲）；遠隊「從沒掃過」仍須能經情報網進 awareness。scan-nearby spec 前 R① 必坐实既有 message/belief relay 真傳得到遠威脅（率/延遲），別假設。**★★兌現（2026-07-20 god-view Slice B，reviewer R① 載重驗出 relay→discovery 原不存在=前置承諾未履行）**：blueprint 裁 (b) **建 relay-discovery**（`message_system:239` relay claim 提及未識隊→連帶 set `team_discovered`+初始 belief entry，含 distorted）→ **discovery 兩-channel 成真**（①直接視野 vision ②relay 聽說）。**範圍收窄**：只求「聽說→discover」最小行為，**率/延遲/失真的完整情報網模型=defer（資訊操控維度另軌）**。∴ awareness 遠識現靠情報網撐（非只 proximity）；決策 gate 的 team_discovered 經 relay 也長。
- **無估 fallback = 保守/不行動，非偷讀真值**：無 belief → 攻擊性決策(掠食/求貢/背叛)最保守（skip 或視對方等強/強 → 不主動敵對）；選擇層(prey/aid/strong)無 belief→`continue` 不列 candidate。
- **已補 leak（6 處）**：
  - `diplomatic_ai_system.gd` `try_proactive_diplomacy` demand_tribute power_gap（1a）
  - `diplomatic_ai_system.gd` `handle_diplomacy_message` demand_tribute 回應讀 sender 實力（1d）
  - `diplomatic_ai_system.gd` `consider_betrayal`/`betrayal_assessment` 盟友實力（1e，優先 faction snapshot 次 belief）
  - `faction_ai_system.gd` `_find_strong_neighbor` 強鄰 pop（1b）
  - `faction_ai_system.gd` `_find_aid_target` 施援目標 pop+food（1c）
  - `threat_assessment.gd` `_power_ratio` 無 belief fallback→self_pop 視等強（1f，2026-07-17 threat-oracle S1.5;原 fallback `other.population`=首接觸讀真 pop 破虛張）
- **背叛 belief 驅動化（Task3）**：`betrayal_assessment` 純函數＝人格 + belief power advantage（盟弱我利→動機↑）+ confidence gate（1−uncertainty，不憑不確定情報背叛）。`consider_betrayal` driver 為主驅、僅門檻邊界保留小 stochastic tie-break（去純 `randf()<0.1`）。driver 可解釋。
- **刻意豁免（同 faction 內部協調，讀真值合法）**：merge/consolidate、faction/global tally（`faction_ai_system.gd` :1060/:1072/:1145/:1630/:1650/:1991 一帶）＝同勢力共享情報 believable；背叛的 faction `known_member_states` snapshot 亦屬此類。**★~~位置/reachability = 可見性物理(PathSystem 讀真位)不在此限~~ 否決（2026-07-19 god-view audit）**：他隊當前位置=belief last-seen（見上位置語義段）;PathSystem `estimate_catch_up/observe_velocity/predict_intercept` 讀 live 他隊位=**god-view 違憲待修（Slice D）非豁免**（terrain/自身位=物理真合法，他隊位≠）。
- **★★市集＝零豁免、必經 belief（用戶定 2026-07-19，否決舊「公開地標豁免」；god-view 殲滅 arc Slice C）**：~~市集 outpost 公開地標豁免~~ **否決**——**市場資訊永遠要傳播（憑聽過/belief，非全圖 god-view 掃）**。`_nearest_market_outpost`（`faction_ai_system.gd:2065-2078`）現全 `state.world.tiles` 掃無 discovery gate = **god-view 後門**（汙染 economy 診斷=改序先修 god-view 的硬理由）。**修（Slice C）**：貿易/買糧選市場**憑 belief（聽過該市集/其賣單，經 message/relay 傳播）**非全圖掃。**★前置**：BeliefSystem 現 team-keyed **無 tile/market 級知識庫** → Slice C 需**建 market-discovery belief store**（tile/market-level）+ 市集資訊經傳播進入。冷啟動出門憑「聽過附近有市集」的傳播 belief（非全知）。敵情/社交/市場位置**全走 belief，零 god-view 豁免**。
- **審計手段 = 回歸測**（非 runtime probe，成本裁）：`headless_test.gd` `_test_leak_*`（真值≠belief 兩向斷言決策跟 belief）+ `_test_betrayal_belief_driven`。新增決策讀他隊 stat 須走 belief 並補對應「真值≠belief」測。

### 屈服/失真/戰意單一 owner（F-I2/I4/I7，2026-07-04 互動統一）
- **屈服判斷單一 owner = `DiplomaticAI.tribute_accept`（static）**：勒索/求貢/兵臨「要不要屈服」一律委派此公式——belief-gated（aggressor 實力讀 believed pop_est，無估 fallback=視等強保守）、fear/求生欲在公式內（防衛方心理恆在）、兵臨壓力=caller `threat` 輸入權重、feud/gratitude 邊入權重（血仇不屈/恩義軟化）。**禁新開屈服公式**（三舊公式已退役：`_should_pay_tribute` ✂/`resolve_extortion_direct` 內嵌 ✂/`demand_tribute` 內嵌 ✂）。
- **失真單一 owner = `DistortionEngine`**：訊息內容（`distort_message`）/intel 估值（`distort_intel_entry`）/親見欺敵（`apply_observation_deception`）三 call site 傳 context，**禁在 engine 外寫失真邏輯**（舊三引擎+dormant 第 4 已退役）。寫點（`_write_tier2_intel`/`record_claim`）不變。
- **combat verb belief-gated**：`_should_attack` 讀 believed `armed_est`（退 pop_est）vs 自身真 armed；**無 belief → 保守不攻**（G3-E「無估 fallback=不行動」）。新 caller 契約：呼前須確保 belief 已寫（`_try_interact` 開頭雙向 `_write_tier2_intel` 即此保證），否則恆 false。


## ★★ 三條對稱不變量（統一架構骨架，believability 北極星，藍圖 2026-06-29）

凡 state 變化  必有可解釋來源/單寫者   ← 所有權域 Pattern B driver-ledger 起步（slice2:5 bank reason 真記+roster chokepoint;tile-bank/combat_target 後 slice）
凡位置        必有可解釋上位路徑      ← 選擇/階級域 (a) 攀爬動力待修（起始劇本擺放豁免=authored premise）
凡 tick       早晚期成本無延遲差      ← 效能域  硬不變量（藍圖 2026-07-02,perf 倒推 1-2 代尺度,玩家直感）
凡 in-flight latch 必有 timeout/release ← 決策域  硬規則（藍圖 2026-07-03,②a found_ally 揭家族病）
凡身分        只能是權重不能是路徑切換  ← 決策域  原則（藍圖 2026-07-03,「入勢力不換腦」）
```
- **★效能域（per-tick 有界,藍圖 2026-07-02 升硬不變量）**：per-tick 成本早晚期**無延遲差**（玩家直接感受;perf 倒推出 1-2 代尺度）。推論：**世界大小全程有界**（1-2 代內累積也 bound）。**die-off erase O(N) spike 從「另案 backlog」升為必收**（滅團潮=大戲時刻最會爆、直接違反此不變量;長跑滅團潮量到 freeze 前該修，見 known_issues scaling）。scaling 加固（P0 索引+leak done、die-off spike 待）服務此不變量。
- **選擇/階級域（藍圖 2026-06-29）**：位置持有者（faction leader / established ruler / named commander）的 traits 必須**靠真選擇掙來、可解釋**（從其出身階級池帶真 rolled traits 爬上來），**非生成 fiat 欽定**（當了領袖就塞強數值=作弊）。**例外：起始劇本擺放 = authored premise 明示豁免**（設計者佈局種子，非憑空）。**(a) 主體 = 攀爬動力**（能人從底層真能升到立國/征服的鏈每段要通：累積>損耗 / 每階有可走轉換 / 跑途中能 founder 新派系 / 活得夠久爬完）；稀有度=屬性分佈旋鈕（攀爬通後才微調）。
- **決策域 ✓**：見下「意圖驅動完備」（commander-v2 落實）。
- **★latch-timeout 規則（藍圖 2026-07-03 升格,②a 揭）**：凡 in-flight latch（dispatch 後「不重評」guard）**必有 timeout/release**。scout 有 SCOUT_TIMEOUT、FLEE 有 FLEE_TIMEOUT、TRADE 有 TRADE_TIMEOUT、**found_ally 漏了=狼凍 4-6 月**＝家族病。timeout 別死常數——按「距離/移速」估合理往返時間。CI 可掃（有 dispatch-guard 無對應 timeout 常數=fail,強制閘 program ②候選）。
- **★身分=權重非路徑切換（藍圖 2026-07-03 升格,斷① 揭,用戶裁）**：**個人戰略層對每個 leader 永遠在跑**（統一架構本義）;faction 身分=一個 context/term（faction_duty）,大事壓上來、日常人格照驅動、低忠高野仍能叛。**任何「按身分切換決策路徑」（如 `fid≠-1 → 關掉個人層`）=違規**——入夥即人格蒸發。身分只能加權重。
- **信息域（G3，next keystone）**：凡 belief 必有 provenance（來源/credibility/時效）。= 欺敵地基 + 玩家錨 C 核心（玩家=霧裡 belief 消費者）+ 因果脊椎③。G3a-d 已建 multi-claim/credibility/detection/uncertainty/scout，待 provenance-complete enforce。
- **所有權域（Pattern B，slice2 起步）**：凡 state 變化必有單寫者 + driver-ledger（非僅 banker 集中寫，還要可追「為何變」）。解鎖可信內政（忠誠/民怨/壓力→叛亂崩潰有因）。**slice2 落地**：driver-ledger 真記（5 bank reason）+ roster chokepoint（見資料模型規則 2/4）。**首個可查對象揭 pre-existing leader/team_id desync → slice3 根修**（`set_leader` chokepoint force-sync + 反向 roster audit 常駐守 + driver_tick_hint 接線[ledger tick 溯源真]）。**combat_target/social_target chokepoint 落地**（`set_combat_target`/`set_social_target`,語意拆戰鬥≠社交,dangling audit;順修 BEG/JOIN 死路 F-I3）。剩餘：tile-granary-bank / tile.resources bank（後 slice）。完整未實現面見 `known_issues` 統一矩陣。


## 對稱性

- encounter 與 npc_combat 敗方結算皆對敗方整隊 anon pop（**含未上場 reserve**）施 tier 加權陣亡（`AnonTierSystem.kill_random` + `SURVIVAL_KILL_WEIGHT`），無玩家專屬豁免（game-design §對稱性）。
- pop 變動只經 cohort API。武裝下限 `ARMED_RATIO_FLOOR` 在消費端（encounter spawn / npc 戰力）套用，不覆寫 `armed_anon_ratio` 推導值。
- **每 round 傷亡走分數累積器**（`_resolve_combat_round`+`_accum_casualty`，2026-07-10 §D4 de-patch）：real-valued 傷亡跨 round carry 於 `_combat_track[id].cas_carry`、floor 取整。**禁 `int(round())` 直接量化**——對小 pop（eff≤3，積 <0.5）恆捨入 0=絕境隊零流血=殲滅結構不可能（補丁閘型病）。累積器**零新增 randf**（傷亡量化不引入 RNG），seeded warring determinism 保。


## NPC

- Needs
- Memories

禁止硬編碼結果


## ★ 統一搬運脊椎（後勤，用戶定 2026-08-01，enforce 起步）

- **不含空間移動者 N/A**（如 consolidation/併隊不搬供給、tile-local 消耗）。
- **為何**（血證）：散件（auto-withdraw/provision-carry/harvest-carry/remote-tribute/糧橋）各做各的 = 後勤統一 arc 要收斂的病根；平行搬運路 = drift + 觀測盲點 + 難維護。
- WHAT owner=game-design.md 後勤節；HOW/enforce=本檔 + [[project_logistics_unification]]。


## ★ 統一勞力池（生產規模、用戶定 size-matter 2026-08-03，enforce 起步）

- **tile 生態承載獨立不碰**：`_collect_from_tile` 的 `current`(庫存遞減)/`COLLECT_RATE`/`regen`（resource:254-284）是承載真載體；勞力池**只改 `pop_mult→labor_mult` 那一支、庫存數學零改**。大隊採快→current 掉快→yield 降（人均遞減意圖）。
- **size 靠 facility breadth**：單工位 `demand-cap(K×level)` saturate；size 優勢來自餵多/大 facility（資本投產能）非 raw pop 灌單工位。
- **執行層非決策**：勞力池＝生產 rate、util/argmax 不碰。**非 crank**（產出 ∝ 真手數到 demand-cap、勞力真經濟投入、[[genuine-value 非 arbitrary boost]]）。
- WHAT owner=game-design.md；HOW=`docs/superpowers/specs/2026-08-03-unified-labor-pool-HOW.md` + `project_size_matter_arc`。


## 飢餓 / 人口

### ★ 生存決策 = 讀真 state 非死常數（照妖鏡族，生存經濟 arc 2026-08-13，enforce 起步）
生存/接入類決策項的 util/need **讀團自身真 state**（食糧跑道/飢餓）、**禁 flat 死常數**（死常數=吃飽仍照做的假 state）。感知鐵律：讀**自家** state=自知非 god-view。
- **食物 need 隨飢餓升**（`NeedOracle._self_use` food 分支×famine-escalation、單一 source 勿平行 food-need）→ 飢餓時 labor 自然回糧、吃飽不誤搶。
- **覓食 util 隨飽足衰減**（`survival_pressure` eval 隨 food_days 衰減、瀕餓 floor 1.0 不動/吃飽讓位 settle）→ 吃飽團不 fake-forage 佔決策 turn。
- **紮營價值=邊際經濟真帳**（`MarginalEconomy.camp_marginal` 共讀既有 substrate、地形期望流−覓食地板 × 緊迫度、`maxf(0,·)` anti-crank）→ 低產地/富流浪不濫紮。**禁 crank**：接既有 MarginalEconomy 共讀、bounded 非調分數到贏。
- **bounded machine-demonstrate=merge 硬 gate**：瀕餓照常求生（floor 不誤傷）+ 吃飽讓位（四象限驗）。HOW=`specs/2026-08-13-survival-economy-*`、code 為準。


## 資料模型不變量規則（防散落純量 drift）


**所有權域 Pattern B driver-ledger（slice2 落地，第3不變量 enforce 起步）**：`WorldState.driver_ledger`（off-by-default ring-buffer）+ `record_driver(entity,field,delta,reason)`。5 bank（Resource/AnonTreasury/OutpostOwner/Loyalty/Unrest）的 `reason` 真 append（非丟棄）→ 強制閘/審計可查「這筆 state change 為何」。**新 bank 操作須帶 reason 並經 `record_driver`。** 剩餘（tile-granary-bank / tile.resources bank / combat_target chokepoint）= 後 slice。


## team reference 契約

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

- 冪等：`on_leader_death` 的 player 偵測分支對已 pending 同隊 `choose_heir` 直接回 `true` 不重設（安全網每 tick 重呼）；`handle_player_succession` 本身不帶冪等（external caller 要即時重評）。

- **勢力盟主繼承（faction 層、≠ 上列 team 層 leader 繼承）** = `WorldState.succeed_or_disband_faction` 單一 owner（繼承-lite slice）：領袖團死 → 成員中最強者接位（統領→pop→tid 全序），無成員才 `disband_faction`。候選過濾**必吃死集合**見〈死亡窗口（走屍隊）決策紀律〉。


## 關係圖（typed-edge）

- **consumer 現況（2026-07-04 F-I5 接線）**：feud → `vendetta_target` + `tribute_accept` 權重；gratitude → `tribute_accept` 權重。killed/protect = dormant（zero writer 或 writer-dead chain，見 known_issues，收徒/擊殺鏈機制時裁復活或刪）。
- 回傳：`true`=已處理（含 player pending）；`false`=無繼承人 → caller 滅團/faction 解散。


## 訂單系統

- 商隊（商業 archetype）目標**讀收到的訂單**（`team_known` order message = 殘缺/可失真，`OrderSystem.best_arbitrage_order`），**禁讀 `team_discovered` 上帝視角**挑貿易對象（接「目標決策讀殘缺情報」總則）。`_find_trade_target`（team_discovered）降為無訂單時 fallback，最終應刪。到場履約走既有 interaction 同格 trade。
- 短缺發買單：`tick_team_orders` 對 `_ORDER_ELIGIBLE_RES` 中低於 `SHORTAGE_QTY` 的料/武器 res post buy order（生產買單來源，閉 G1b 半 inert）。
- 撲空 = 訂單過期/失真 → 到場供需已變 → 既有 `local_value` glut 給壞 deal（**無新機制**）。準情報值錢，為 ③G3 鋪路。


## 隊目標單一 owner = leader 野心階梯

- **統領 `_update_goals` = means-end 意圖驅動（commander-v2，北極星第一處落實）**：非並行多閾值 append、非收斂單一姿態。流程＝意圖 predicate（小集 `{征服X,致富,防衛,守成}`，`_select_intent` 人格×belief×viability×hysteresis argmax）→ 子需求現算（深度1，主行動未滿足前提 vs live 世界，`_decompose_needs`，**不遞迴**）→ 真 affordance 匹配補肢（`_match_fillers` util=affordance∩need×人格適性×viable，從人格餘裕抽，非硬塞）→ `_emit_goal`（**每令 `f.goal_drivers[goal]={intent,why,mode}` 連回意圖＝可解釋驅動，無無因令**）。意圖 hysteresis（`f.intent` 承諾，`COMMANDER_COMMITMENT_BONUS`）；resource-aware viability（征服湊不出實打力→退更小意圖，不發打不贏攻擊令）。只掛真 affordance（攻擊combat/徵收levy·fund_war/外交ally）；**欺敵孤兒（擋敵盟子需求）無真 filler→不開該 need=anchored-pre-player**。掠奪=team option（非統領令）；緊急徵收=survival override（意圖前 return）；立國=既有分離 gate（非意圖集）。
- **獨立戰略層 = 野心普世驅力，戰略意圖非 faction-only（統一決策 arc 第三塊）**：戰略意圖層**下放到野心獨立隊**（`faction_ai._evaluate_independent_strategy`，fid=-1 + 野心≥`AMBITION_FOUND_MIN` + 累積夠[pop≥EXPAND_MIN_POP + 食盈餘] + founding 路徑可達 才觸發），mirror commander-v2 `_select_intent`（輕量）。意圖集只 `{建國, 守成}`（征服/徵收等 = 成 faction 後 commander-v2 給，獨立層不重做）。**建國 = means-end 秤的 option（driver=野心，driver-complete），非「野心+夠 pop→自動 create_faction」fiat**；means-end 子行動 **結盟（primary，義氣染）/吞併（機會，殘忍·好戰染）** argmax+hysteresis → **複用既有 `create_faction`**（結盟 `interaction:333` 兩獨立 / 吞併 `npc_combat:524` subjugate，**不新 founding 機制**）。守成=不 dispatch（繼續既有個體決策 SoloAI/survival/ambient）。**稀有 by construction**（三閘）→ 多數獨立隊守成（非建國潮）。**宣告（solo declare）defer**：無獨立鄰+無弱鄰的孤立野心隊暫無路（守成累積，backlog）。接點 = `evaluate_all` per-team 迴圈（survival 後 prosperity 前，fid=-1 cadence gate），不雙寫 `_evaluate_solo`（後者 idle-gated，被 PRIO_DISPATCH 建國令覆蓋）。


## 死亡窗口（走屍隊）決策紀律（2026-08-20 systems 立、R² 繼承-lite 抓到具體 race 後升格）

| **大窗**：`teams_pending_erase` 標記 → tick 末 `cleanup_extinct_teams` | 該 tick 剩餘全部系統 | `state.teams_pending_erase` |
| **小窗**：`erase_teams` 批次迴圈內（真 `teams.erase` 在迴圈**之後**） | 迴圈內每隊的 step1/2 | 該函式內已建的 `dead` 字典（`world_state.gd:287-292`） |

**紀律（判準=後果是否跨窗口存續）**：
- **純粹改動「即將消失的物件」→ 無害、免防**（step1 孤兒化子隊 `parent_team_id=-1`、`disband_faction` 把同批死者 `faction_id=-1`）——寫進去的值隨物件一起消失。
- **★產生「窗口後仍生效的綁定」→ 必須排除死集合**：選出/指派/接位/締約一個 team_id 並寫入**存活實體**的欄位。只信 `teams.has(tid)` = 綁到走屍。
  - 血證（R² 2026-08-20）：勢力盟主繼承若只信 `teams.has(cid)`，領袖隊在 `dead_list` 順序中先處理時，**同批死亡的隊友仍 `has()==true`** → 選為繼任者、然後同一次 `erase_teams` 親手清掉它。
- **傳法（零新資料結構）**：小窗傳該函式已建的 `dead`；大窗傳既有 `state.teams_pending_erase`。**禁**為此新增 `is_dead` 旗標或平行登記（兩集合已是權威）。
- 新增任何「跨窗口存續綁定」的機制時，**spec 必須明寫吃哪個死集合**；R² 視為必查項。

（繼承-lite slice 接線時落地；契約先立，後續同類機制一律照此。與上方「team reference 契約 B 類瞬時懸空」互補：B 類講 erase **之後**的懸空自癒，本節講 erase **之前**的走屍可見。）



## LOD 降頻補償紀律（2026-08-20 立、LOD 紅線修實戰產出）

| 型別 | 例 | 降頻後果 | 處置 |
|---|---|---|---|
| **機率型**（每次呼叫抽獎） | `if randf() < p` 生育 | 期望次數 ÷trials | **跑 trials 次真試驗**；★**禁**用單抽 `1-(1-p)^trials`（結構性封頂每窗最多 1 次＝系統性低估） |
| **累積型**（每次呼叫加一點） | `loyalty += 0.01`／`unrest ±1`／技能 XP／`lerp(x, target, w)` | 累積速度 ÷trials | **×trials**；lerp 型用 `w_eff = 1-(1-w)^trials`（對固定 target 精確等價） |
| **離散門檻型**（達標即發生一次） | 叛逃/出走 | **最多延遲 M tick、非降率**（條件持續則下次評估照樣發生） | **不補償** |
| **飽和型** | `stress = max(stress-0.3, 0)` | 觸底即止 | **不補償** |

**上限語意**：補償迴圈內必須**逐次重查上限**（如團級 `minor_population < cap`），否則補償會突破高頻端本來就會撞到的天花板。

**驗收＝rate-equivalence**（同窗數下 far ≈ near 的**累積量**），★**只證「有 fire」不算過**。且量 rate-equivalence 時必須確認**落在未飽和區間**、且**兩側都真的有事情發生**——「兩側相等」在「兩側都撞上限」或「兩側都沒 fire」時是**假通過**（本輪實戰各踩一次）。

**起手檢查**：頻率換算型改動，先查 `SYSTEMS` registry 該 entry 的 **`shape`**（決定函式收不收 cadence）**與 pass 層的 outer guard**（決定該 pass 多久跑一次）——**兩者都要查**（本輪 systems 假設常數適用、reviewer 假設沒有 throttle，各錯一邊）。



## 長跑量測床的三條硬規（2026-08-20 立、大考實戰產出）

★ 三條共同的教訓：**量測工具的沉默失敗，會被讀成世界的性質**。

### ★窗長不足時，「遲到」看起來會跟「破口」一模一樣（2026-08-21 血證）
convoy RETURN 腿：**30 天窗**觀測到「母隊一毛沒收到、porter 身上殘留 233 coin」→ 初判**守恆破口**；**拉到 75 天**後 porter 於 **day37.9 全額歸建**（母隊 coin 666.7→961.9）→ **實為「回家遲到 27.9 日」**。
**判準**：宣稱「**資源不見了／流程斷了**」前，先確認**窗長 ≥ 該流程的自然週期**（此例：一趟 convoy 的完整生命週期）。**窗不夠長時，正確結論是「本窗未觀察到完成」而非「不會完成」。**
★與〈長跑量測床三條硬規〉同族：**量測工具的限制會被讀成世界的性質**。


**★2026-08-21 同日第二次血證：窗末的「未終局」不是結論（censoring）**
convoy `porter_22` 在 **75 天窗末仍 `ghost_alive`**，被讀成「**卡住、可能永遠回不了家**」——
我甚至據此推論它會是 **T3 防呆絕對上限的第一個真樣本**。
**延長到 150 天後**：它在 **`tick 18100`（day 75.4，cutoff 之後僅 100 ticks）就正常 `merged_home`** ＝ **純 timing artifact**。

**規則**：**窗末仍未終局的個體，只能記成「未觀測到結局（censored）」**，
**不得記成任何一種結局**（`ghost`／`stranded`／失敗），更**不得拿它當某機制「即將觸發」的證據**。
報表要把 **`censored` 獨立一格** —— 否則「**還沒演完**」會被讀成「**演壞了**」。
### ★效果小於機器雜訊時的量法：in-situ 開關對照（2026-08-21、owner-outpost 索引實戰產出）
當一刀的效果**小於臂間雜訊**（本例：全局 wall/day 臂內抖動 **±4–8%**、其中一趟甚至反向 +7.7%），**A/B 跑兩個 build 量不出決定性差異**——此時**不得**宣稱「證明加速」，也**不得**挑最好看的那趟。
**改用 in-situ**：**同一個 binary、同一條世界軌跡**，只切一個「多做/不做那份工」的開關（如影子模式：on ＝ 額外再跑一次舊路徑），**差值 ＝ 該工的真實成本**。本例得 **+973 ms/日**，與微觀 per-call 換算的 **895 ms/日** 相互印證。
**為什麼有效**：兩趟的世界、RNG、隊數、快取行為完全相同，**唯一變數就是那份工**——把「跨 run 差異」這個最大雜訊源從等式裡消掉（同 perf③ k 值測不準的元凶）。
★**配套誠實**：仍要報全局 A/B 的原始數字與其雜訊幅度，並明說「**全局窗測不出**、in-situ 才是證據」。

### ★量「有沒有變」時，比對基準不能是「剛被自己清空的結構」（2026-08-20 血證：差點殺掉一個正確假說）
在 **clear-then-rebuild** 的資料結構上量「這輪有沒有真的改變」，**必須跟「上一輪的快照」比**，**不能跟「當前結構」比**——因為當前結構在比對前**剛被清空**，任何重建都會被判成「全新」。
**血證**：directive churn 證據刀第一版量出 `restate = 0%`、**差點回報「假說錯」**；真因是 `_update_goals` 每輪 `goals.clear()` + `goal_drivers.clear()` 後才重發，於是「跟剛清空的 dict 比」永遠是新 goal。改成**跟上一輪快照比**才得到真數字（**純重申 88.0%**）。
★**這是偽陰性**（把真的病判成沒病），比偽陽性更危險——偽陽性會被下游對抗閘擋下，偽陰性會讓調查**就此結案**。

### ★byte-identical 能證明什麼、不能證明什麼（2026-08-20 R² 指正、systems 採納）
- **能證明**：同輸入下**分岔沒有發生**（世界軌跡一致）。
- **★不能證明**：**沒有殘留 / 沒有盲點**——**deterministic 的殘留仍然是殘留**。三跑相同只說明「殘留是可重現的」，不說明「殘留不存在」。
- **推論**：凡「某暫態不入 fingerprint」的設計判斷（如 tick 內 pending 佇列），**不得只靠三跑 byte-identical 當防線**，必須有**明文設計保證**（例：「消費迴圈單 tick 內清空、不得分批」）。**事後量測抓分岔，設計保證抓存在性**，兩者角色不同。



## 承諾態只能經仲裁移轉：直接寫欄位 ＝ 承諾靜默消失（2026-08-21 立，convoy RETURN 實戰產出）

`TaskArbiter.release(sub)`，而 **`release()` 直接寫欄位、繞過 `try_set`** ⇒ 承諾態被丟掉、隊變 `IDLE`
⇒ 下一輪決策**合法地**把它改派成別的事。

★ **為什麼 hold 擋不住**：`PROGRESSIVE_HOLD_TASKS` 擋的是「**CONVOY → 別的**」；
而現場發生的是「**IDLE → 別的**」——**承諾在被問之前就已經不存在了**。
`diag.convoy_preempt_try.* = 0`／`persist.hold = 0` ＝ **根本沒有人問過仲裁**。

### 規則
1. **任何會讓隊伍離開一個承諾態（progressive／hold 類 task）的路徑，都必須經過 `try_set`／`transition`**，
   讓仲裁有機會拒絕。**直接寫 `current_task` 等欄位 ＝ 繞過仲裁。**
2. `release()` 是**合法的**，但它的語意是「**承諾已結束**」。
   **當承諾其實還在（`convoy_phase` 非空、build 未完、護送未達）時呼叫 `release()` ＝ bug。**
3. 新增任何 `release()` 呼叫點時，**必須說明「為什麼此刻承諾確實結束了」**；說不出來就是該走 `transition`。

### ★診斷順序（可複用）
遇到「承諾態被搶走」型症狀，**先分兩種可能再開藥**：
- **(a) 搶班沒走仲裁**（沒人問過）→ 查 `try_set` 的 try/hold tap **是不是 0**。**0 ＝ 問題不在門檻，在根本沒問。**
- **(b) 仲裁問了但沒守住**（門檻／持守強度不足）→ 這時才輪到調 hold／persist。
**先看 tap 是不是 0，再談門檻。** 反過來做會像我這次一樣，把藥開在沒發生的事情上。

★ 這是「**補丁閘優先查**」的近親：不是機械 override 壓過引擎，而是**繞過引擎**——
症狀一樣（決策層看起來沒生效），查法一樣（先問「引擎到底有沒有被呼叫」）。


## specimen 選樣必須「血緣封閉」：執行期生成的實體不得落在觀測範圍外（2026-08-21 立，convoy RETURN QA 判不了產出）

★ **整條 slice 的主角自始至終沒被錄到**——聚合數字全都有（延遲、吞吐、守恆），但**故事層完全空白**。

### 規則
1. **specimen 範圍要對「因果對象」封閉，不是對「起跑當下存在的物件」封閉。**
   母隊入選 ⇒ **它在執行期派生的子隊自動入選**（血緣封閉），不需要事先知道 id。
2. **凡是「執行期才生成實體」的機制**（convoy porter／護衛隊／分遣隊／未來任何 spawn），
   **設計時就要回答「它會不會被觀測到」**——答案是「不會」就等於**製造了量測盲點**（違反〈全量暫態可觀測性〉）。
3. **交 specimen 給 QA 前，producer 要自己先驗一次「主角在不在裡面」**：
   `grep -c <主角關鍵字> <specimen>` **＝ 0 就是還沒完工**，別送。
   ★ 這比「檔案存在」強一級——**檔案存在 ≠ 內容涵蓋**（同 memory `feedback_specimen_handoff_landed_path` 升一階）。
   ★★**但關鍵字要挑「語料裡真的存在」的**（2026-08-21 當天就自打臉）：我在派工單寫死驗收 `grep -c convoy > 0`，
   而 **trace 裡的任務名是中文「運輸」**——修好之後 `convoy` 仍然 ＝ 0，**判準本身製造了假陰性**。
   ⇒ 挑**語言無關的欄位鍵**（如 `convoy_phase`）或**先確認該 token 在語料中出現過**，
   否則這條自驗會把「修好了」讀成「沒修好」。**同 `expect_min` 的精神：檢查自己也要有已知良品。**

### ★這一族已經栽第三次
① specimen observe-scope 用**黑名單清單**漏欄 ② LOD 補償碼靠**紀律**記得移除 ③ 本次**選樣清單凍結**。
共同形狀：**用「當下枚舉」代替「規則涵蓋」**——枚舉在世界變化後就過期，而**過期的枚舉看起來跟正常運作一模一樣**。


## ★工作紀律八條 → 已搬家（2026-08-25 #4 doc 瘦身）

| ★`docs/process/03b_measurer.md` | **量測紀律六條**（同 commit 兩趟／`id` 是狀態非事件／產能 vs 存貨／停滯要留成功證據／一個物理量一個模型／聚合掉第一格要問上一格） |

★**搬家不是刪除** —— **原文在 `git log` 裡，壓縮版在上面兩份 doc 的對應節。**


## ★★★觀測器**禁任何副作用**（不只禁耗 RNG）——2026-08-25 擴充

> ★**偵測器自己在【卸工地】。**
> ⇒ ★★**先前每輪數字裡的「放棄」，【無法排除】有一部分是觀測器造出來的。**
>
> ⚠️★**措辭訂正（2026-08-25）**：implementer 原本提供「`det fp` 變了」當經驗證據，
> **後來自己撤回**（那個 fp 來自**型別 bug 版本**，非副作用移除版；跑在已 commit 樹上 **fp 回到與 base 相同**）。
> ⇒ ★**「副作用改變了行為」目前只有 code-read 支撐**（清 `corvee_site` 是寫入世界狀態），
> **沒有經驗證據**；而 `a4` 床本來就對決策／仲裁層無覆蓋（`03b §④k`），**fp 相同也證明不了乾淨**。

⇒ ★**條款成立與否【不依賴那個證據】** —— **它靠 code-read**：
**清 `corvee_site` 就是寫入世界狀態，這件事本身即違反本條款。**
（★**這是「規範性條款」與「經驗主張」的分野：前者由 code 判定，後者要數字。**）

★**條款擴為**：**觀測器【禁任何寫入世界狀態的副作用】** ——
**RNG 只是其中一種；直接改欄位比耗 RNG 更嚴重**（**耗 RNG 改的是未來，改欄位改的是當下**）。

### ★判準（寫 tap／detector 時問一句）
> ★**「如果我把這段觀測整個拿掉，世界會不會不一樣？」**
> **會 ⇒ 它不是觀測器，是一個機制。** —— **那就要走機制的閘（R²／acceptance），不能當 tap 加。**

### ★★連帶紀律：**污染要往回追**
**發現觀測器有副作用時，不只是「修掉它」** ——
★**要列出【哪些已交件的數字受影響】**，因為那些結論可能建立在觀測器造出來的現象上。

## World


- 世界獨立運作
- 玩家不是世界中心


## Map


- Hex Grid Only
- 禁止 Square Grid 假設


## Time


- 大地圖與遭遇戰共用時間尺度

### ★ TimeScale 骨架三不變量（time-scale wave slice A，2026-07-05，enforce 起步）
```

> ★血證／案例 → `invariants-cases.md`（同標題節）


## Information


- 認知不等於真實
- NPC 可說謊
- 訊息可能失真
- 任何資訊命令都需傳遞 ,永不跨距離傳播,也不全知

> ★血證／案例 → `invariants-cases.md`（同標題節）


## Simulation


- Event = Consequence
- 禁止 Scripted Outcome
- **遍歷 id 快照前必驗存在**：team/person id 陣列是 tick 開頭的快照，元素可能在本 tick 內滅團/死亡被移除；存取 dict 前先驗 `.has(id)`，否則 Invalid get index


## ★★ 三條對稱不變量（統一架構骨架，believability 北極星，藍圖 2026-06-29）


同一隻病（憑空 / latch / 無可解釋來源）跨三域，三條對稱不變量 = 統一架構全骨架：
```
凡 named 意圖  必有可解釋驅動        ← 決策域  ✓ done（commander-v2 無因令=0 enforce）
凡 belief     必有 provenance(來源)  ← 信息域  G3 待 enforce（provenance 即識破機制：能追來源才能疑）

> ★血證／案例 → `invariants-cases.md`（同標題節）


## ★ 意圖驅動完備（決策域，藍圖 2026-06-28）


- **凡 named 意圖必有可解釋驅動**：每個 named 意圖（派系令 / 隊 task / 人物 action / 野心階）**必追得回根驅動**——need / value / belief / **父意圖**。**追不出驅動 = bug**（閾值/tag/latch 憑空跳出=該病）。
- **連貫來自共享父意圖，非收斂單一**：多重命令 OK 甚至嚮往——只要可解釋。統領先 utility 選**戰略意圖**（征服敵X / 防衛 / 致富 / 擴張），意圖**生成協同子命令**（征服X → 攻擊X[手段] + 對X盟友外交[欺敵拖住] + 徵收[籌軍費]＝多令服務同一意圖）。**每令帶「為什麼」（連回父意圖）**。欺敵 = driver 真實（服務征服X）+ action 不真心（戰術外交）。
- **= 因果脊椎 + 統一決策合一**（[[project_causal_spine]] / [[project_unified_decision_framework]]）：驅動鏈 = 因果脊椎顯化 + 強制。直接定義玩家錨 C——世界 driver-complete → 玩家情報遊戲 = 從看得到的 action 反推看不到的 driver（外交=真結盟還是欺敵？囤糧=遠征還是投機？）。亦是 believability 審計鏡（走任一意圖問 driver，答不出=洞）。
- **範圍紀律**：北極星 + 不變量，**非現在停下給所有 action 塞 driver 欄重寫**。**統領層現在落實**（commander-unify 第一處）；其餘 = 審計鏡頭，按 player-visibility 排序逐步補——新工作須滿足，舊工作照洞補。**禁鑽牛角尖**（[[feedback_avoid_rabbithole]]）。


## 關鍵設計規則


- **不直接 script 結果**：所有行為從 NPC values/skills/stress/loyalty 計算產生
- **新功能前定義**：影響的世界狀態、資訊流動、時間消耗、受影響群體、二次後果


## 對稱性


- **無玩家專屬機制**：任一交互 / 生存系統（戰鬥 / 貿易 / 外交 / 覓食 / 狩獵 / 任務 / 賞金…）NPC 必須同樣能用
- 玩家與 NPC 走同一套底層數學；差別只在玩家可手動接管、NPC 自動解算

### 敗方損耗對稱

> ★血證／案例 → `invariants-cases.md`（同標題節）


## 玩法節奏


- **decisions-not-chores**：玩家做決策，模擬跑雜活；壓力存在是為製造決策岔路，不是逼玩家重複操作
- 可跳時間；事件只在 juncture 介入
- **激情時刻全手動 + 真風險**，且主要由玩家冒險決策觸發（非隨機 spam）


## UI 邊界


- **UI 只經 player API**：UI 層（`scripts/ui/*`）禁止直讀/直寫 `WorldState`；一切經 `SimBridge` → `PlayerQueryApi`/`PlayerCommandApi` 的 DTO
- **DTO 是 UI 契約**：玩家 UI 需要的任何 sim 資訊，必須 map 進 DTO（非讓 UI 繞道取）→ 換 UI（文字↔圖形）只需接同一 API
- **觀測 UI（ObserverMain）= 平行契約**：god-view 合法（觀測非玩家），但**全 read-only**——經 `ObserverBridge` → `ObserverQueryApi` DTO，禁寫任何 sim state（唯一 sim 側接點=`emit_ambient` append，見訂單系統節）。玩家 UI 禁用 ObserverQueryApi（god-view 洩漏）。`world_map_view.gd` 雙用途（`_observer` guard 分流），動 player 繪製須顧 observer 分支。


## NPC


決策來源：

- Values
- Skills

> ★血證／案例 → `invariants-cases.md`（同標題節）


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


## ★ 統一搬運脊椎（後勤，用戶定 2026-08-01，enforce 起步）


**所有供給的空間移動走同一 convoy 原件**（`_tick_convoy` FETCH→OUTBOUND→DELIVER→RETURN）。後勤運自己的 / 貿易換外面 / 進貢 / 領主分配 = **不同 dispatch 動機 + 不同 DELIVER 終點**，但**共用同一搬運機制**。禁各建平行搬運路。

- **一個機制、多種動機/終點**：DELIVER 終點分支（賣 market_order / 領主→居民直注 / 進貢入上級 vault…）擴 `_resolve_market_at_outpost`，非另刻搬運迴圈。
- **新供給移動需求 = 加 candidate 動機（`_*_candidates`）+ 加 DELIVER 終點分支**，不是新搬運系統。

> ★血證／案例 → `invariants-cases.md`（同標題節）


## ★ 統一勞力池（生產規模、用戶定 size-matter 2026-08-03，enforce 起步）


**勞力＝有限稀缺資源**：所有生產（採集+每製造設施）吃**同一 per-tile 勞力池**（共址 `TAG_PRODUCE` 隊 pop 總和）。`LaborSystem` 單一共享 allocator、採集端+製造端共讀（統一非平行）。取代舊兩套免費 `sqrt(pop/5)` pop_mult residue。

- **deterministic**：allocator sorted key + 純算術 + cascade 固定迭代上限 + **零 RNG** → 三跑 byte-identical。
- **need-gated、無 scripted min-floor**：工位 need 權重走 `need_oracle`（self+supply+construction+trade、多級供給鏈傳播）；`need=0 → fill=0 → 產出 0`（不需求貨不產＝真經濟）。**禁加 min-floor 保底**（違憲法硬 gate）；buffer/戰略儲備走 genuine anticipatory need（need_oracle reserve target）非 floor。

> ★血證／案例 → `invariants-cases.md`（同標題節）


## 飢餓 / 人口


- 飢餓判定唯一來源 = 團糧（個人不另算飢餓）
- 死亡順序：弱者先死（minor → anon → named）
- 生育是生命事件（可與行動並行），不與行動反應競爭單一名額


> ★血證／案例 → `invariants-cases.md`（同標題節）


## 資料模型不變量規則（防散落純量 drift）


1. **可衍生聚合 → computed getter，不存可變欄位**。任何 `= f(權威來源)` 的值用唯讀 getter（範本 `team_data.population` / `wounded` / `anon_combat_skill`）。物理上不可 drift；加人必須動真來源（named_members / anon_cohorts），不能偷改數字。
2. **來源/雙向關係走單一入口**。anon 改動走 `AnonCohort`/`AnonTierSystem` 入口；勿直接 `anon_cohorts[k] = ...`。team↔faction 走 `set_team_faction`、child↔parent 走 `set_subteam_parent`、**named 成員↔person.team_id 走 `add_member`/`remove_member`**（勿直接 `named_members.append/erase`；`remove_member(...,clear_team_id:=false)` 給晉升 leader/死亡留屍/轉隊已先設目標隊三類）。**leader_id 賦值走 `set_leader(team, pid, old_leader_action)` chokepoint**（設 leader_id + **強制 person.team_id 回指本隊**[根修 slice2 揭的 leader/team_id desync] + role="leader" + 出 named_members;`old_leader_action="member"` 舊 leader 降 named）。建隊構造（`beast:30` 全新欄位初始化）+ bulk 清空（`subteam _merge_into` 尾 per-member add 後）= 明示豁免。**新增轉隊/晉升/死亡路徑須：入 roster（add_member/set_leader）或標 `person.is_dead`**（否則反向 audit 抓）。**combat_target 走 `set_combat_target`/`clear`（純戰鬥語意）、投靠/乞食社交目標走 `set_social_target`/`clear`（≠戰鬥,別塞 combat_target 否則被 `_try_interact:197` 戰鬥早退吃掉=BEG/JOIN 死路）。**
3. **不可衍生的真存量 / 不變量 → 註冊進 `InvariantAudit.check`**。真存守恆量（coin_eq **全池=team.resources+anon_treasury+person.coin+tile.public_storage.coin+abandoned_coin,見 `CoinAudit`；coin_eq 剔 ore=採集產出非守恆、mint 唯一 coin 源走 ledger 認增發**）、cohort 自洽、faction/subteam/**roster（named/leader↔team_id **雙向**:forward=roster→team_id、reverse=活人 team_id→roster,`p.is_dead`/team 不存在跳；`_check_roster_bidir`）**等靠 audit 守。加新不變量 = 加一個 `_check_*` 並在 `check()` 呼叫。
4. **改資料模型前讀本節。**

> ★血證／案例 → `invariants-cases.md`（同標題節）


## team reference 契約


移除 team 一律走 `state.erase_team(tid)`（唯一 chokepoint，清光所有指向它的 ref）。但解析時分兩類 —— **實證後的區分**（2026-06-18 batch1 子 session 證偽「全部納管 ref 永遠活」）：

### A. 維護集合元素 → 保證活 → `require_team`
`faction.member_team_ids` / `subteam_ids` / `team_known[obs]` / `team_discovered[obs]` 內的元素由 erase_team + 雙向 audit 持續維護，迭代時**每個元素必活**：

> ★血證／案例 → `invariants-cases.md`（同標題節）


## Leader 繼承單一 owner


- **繼承邏輯單一 owner = `EventSystem.on_leader_death(state, team) -> bool`。** 偵測單一點 = `faction_ai` 每-tick 安全網（`leader_id==-1` → 呼 owner）；`npc_combat._kill_named_npc` 戰中即時呼為效能捷徑（非另一 owner）。
- 禁止在 `on_leader_death` 外自行決定繼承人 / promote。裸置 `leader_id = -1` 僅允許作 transient（須由安全網次 tick 補位）。
- 分派：player → forced `choose_heir`（named 空則 `game_over`）；NPC → best named 無門檻晉升 → 無 named 則 anon 晉升 → 皆無回 `false` 滅團。晉升成功後呼 `PopulationSystem.check_overflow_for_team`（弱 leader → pop_cap 溢出回饋）。
- player 分支偵測靠 `WorldState.get_player_team_id()`（單一源）。但**死者 person 已 erase 時偵測查不到**（leader_id=-1 且不在 named）→ 已知是 player team 的 external caller（encounter `_check_player_wiped`、player_command stale-heir 終局）**直呼 public `EventSystem.handle_player_succession(state, team)`** 繞過自動偵測。所有真實路徑呼 `on_leader_death` 時死者 person 尚在 `persons`（combat 在 erase 前呼、famine/encounter/安全網從不 erase）→ 自動偵測對它們成立。

> ★血證／案例 → `invariants-cases.md`（同標題節）


## 關係圖（typed-edge）


- typed 關係事實只經 `RelationGraph`（add_edge/edges_of_type/edges_to/strongest）寫讀 `PersonData.relation_edges`。
- 圖核心**型別無關**：只按 `type`/`target` filter；加新型別 = 加 reader，**禁改 RelationGraph 核心**（WHAT spec §4 硬約束）。
- 扁平 `relations`（純量泛好感）與 typed 圖**語義分職**並存：前者連續情感（loyalty/反應），後者事件型關係邊（feud/protect/gratitude/killed）。
- G2 用型別：`feud`/`gratitude`/`protect`（write_memory 填）/`killed`（G2d 死亡鏈）。未來 `kin`/`spouse`/`master` 等同型塞入。

> ★血證／案例 → `invariants-cases.md`（同標題節）


## 私人脫軌（血仇）


- feud 邊由戰鬥（looted/betrayal/extorted 記憶 → G2a `write_memory` 映射）populate（敗方含 leader 對勝方獲 feud）；本層只加 reader，不重做血仇 populate。
- `NpcAiSystem.vendetta_target` 讀 leader 最強 feud 邊 + 衝動 gate（好戰 ≥ `VENDETTA_BELLIGERENCE`、慎重 < `VENDETTA_PRUDENCE`、intensity ≥ `VENDETTA_INTENSITY`，全 TEST VALUE）→ 回仇人 team_id（存在且非自隊）否則 -1。冷靜 leader 隱忍不脫軌。
- 脫軌 = `faction_ai.evaluate_all` 在 `_evaluate_threat` 後以 `TaskArbiter.PRIO_VENDETTA`(55) try_set TASK_ATTACK：生存(80)/威脅(70) 擋得住、prosperity(50) 擋不住。置於 threat 後因 `_evaluate_threat` 只在 idle 動作 → threat 先佔 task 則 vendetta@55 搶不動（威脅優先）。
- `relation_edges` 的行為 consumer = `vendetta_target`（G2a 圖不再 dormant）。pre-existing dormant `NpcAiSystem.get_goal_task_override` 已刪（revenge 意圖由本路徑經 G2a 圖取代）。


## 訂單系統


- 訂單權威存發起隊 `active_orders`；`emit_message("order_buy"/"order_sell")` 為**可失真傳播副本**（殘缺市場知識湧現，復用 message propagate/distort）。
- **★`global_messages` 禁外部 append**：`order_system` 借 `global_messages.size()` 當 order_id 空間 → 任何非 `emit_message` 傳播路徑的 append 位移 oid 流=訂單去重/履約行為真變（2026-07-04 observer 軌 seeded 逐點 diff 實證）。**觀測型事件走 `emit_ambient` → `state.observer_messages`**（獨立 append-only channel，cap 裁尾）：不進 global_messages/team_known、**sim 禁讀**、無 RNG 消耗——觀測零擾 by construction。
- 履約/讀取依 message 副本，須回發起隊 active_orders 核對（撲空 = 副本過期/失真，G1d）。
- 生產需求偏好讀 `OrderSystem.received_buy_orders`，不另建需求表。同格本地交易沿用既有 interaction trade；跨格商隊 = G1d。

> ★血證／案例 → `invariants-cases.md`（同標題節）


## 隊目標單一 owner = leader 野心階梯


- 隊無獨立目標。`TeamData.ambition_rung/archetype/cap` 由 leader values + 隊安全經 `AmbitionLadder` derive，**單一真值源**。換 leader → 重 derive（方向劇變）。
- faction strategic_goals **衍生**自 faction-leader 階梯（`strategic_ai._update_faction_goals` 讀 rung/archetype），禁他處獨立定隊/勢力戰略目標。
- 階梯門檻/權重全 TEST VALUE（正式平衡 pass 調）。rung→每階 task/tag 全表 = G2c ✅；個人脫軌（血仇）= G2d ✅（見「私人脫軌」）。
- 隊常態行為由 `AmbitionLadder.rung_task(archetype×rung)` 驅動（既有 TASK_*，零新 task），`PRIO_AMBIENT` 只填 idle。生存 rung→`_trigger_survival`；武力擴張→prosperity；立國/稱霸→faction strategic(G2b)。極絕境/威脅/脫軌(vendetta)優先序皆高於 ambient ladder。

> ★血證／案例 → `invariants-cases.md`（同標題節）


## 混合協調（faction stakes vs team 日常）

- **stakes-to-faction → 頂層協同；team 日常 op → 個體**（ruling §1）。stakes 集合 = **攻擊/徵收/外交**（`DecisionContext.STAKES_SET`）由霸主 `_update_goals` **means-end** 設 `f.goals`（單意圖→主令+補肢，每令帶 driver；viability gate=稀有蓄意）；unified 隊經 `faction_duty` term 響應。日常（貿易/掠奪/scout/survival）無 faction_duty=各隊個體決。**立國 = leader-level（`_declare_established`，非 member option，不在 stakes 集合）；掠奪 = 日常個體（非 stakes）；結盟 ⊂ 外交。** **war-priority（`FACTION_DUTY_DRIVE_LESSER`）已 revert**：單意圖後成員一次服務一意圖的子命令（主令+補肢）無同級矛盾，徵收/外交 drive 回 `FACTION_DUTY_DRIVE`(1.5) 與攻擊同級。
- **頂層決 WHETHER，人格染 HOW**：派系 directive 決定「要不要做」；member 經對應 option 的個人 drive×weight 染色執行強度。染色映射：攻擊=`attack_drive×attack`(好戰/殘忍)、徵收=`levy_drive×levy`(貪婪/好戰)、外交=`diplo_drive×diplo`(義氣/計謀)。協同≠同質。
- **stakes target finder**：攻擊/外交→`_nearest_independent`（最近獨立隊）；徵收→`_richest_member`（同 faction 最富 member，**雙重排除自身** `== team.team_id`，因 `_richest_member` 未排自身）。徵收/外交=非戰（不設 combat_target）。
- **脫軌逃閥**：`faction_duty` weight **與** 個人 drive（`attack_drive`/`levy_drive`/`diplo_drive`）共用脫軌因子 `_duty_factor = clampf(loy − max(0,野心−0.5)×DEFECT_K, 0,1)` → 低忠誠+高野心 member 的 duty 與個人驅力齊壓 0 → 個人驅力（survival/野心/貿易）蓋過 → 不參與/自走=破framework脫軌。faction_duty 是**加權 term 非 hard override**（非 100% 服從，by construction）。
- **危時不為派系做事**：survival-class term 危時量級碾壓 faction_duty（食物優先；攻擊/徵收/外交皆然）。


## perf 優化 arc（用戶+blueprint 憲章 2026-08-18）

- **★優化兩道分類（每個 perf 優化必分類 + 對應驗證）**：(a) **位元級安全道**＝cache/memo/spatial-index/避重複 query/減 allocation → **不改行為、FP byte-identical 機器證（3 跑）**；(b) **行為影響道**＝降頻/deferred cascade → **時序變=指紋變=intended-change 流程**（fp 標 + 全故事審）+ **守 LOD 紅線**（§掃近隊兩-channel/nearby-scan：餵決策的鄰隊位置一律 belief last-seen 非 live god-view、遠威脅經情報網不隱形）。**分類錯（把行為影響誤當安全道 merge）=違規**（外部 agent 誤列降頻為無害已被 blueprint 修正）。
- **★perf 禁降故事生成 fidelity（紅線）**：Team decision fidelity / message / reaction 等**故事生成機制不可為 perf 犧牲**（reaction all-far 從沒跑=故事基質已薄、perf 不得再削）。優化只碰「怎麼算得快」非「算什麼/多細」。
- **驗證流程**：每改→full sim→Story QA **不降不取消**（過渡期分層：slice 短窗+定向 QA、arc 里程碑 full 12mo+全故事審=現行實務）；終極目標=把 full sim 壓便宜到每改全跑付得起。


## resource 分類學（農業a merge 落定、守恆稽核依此）

- **零生成**：礦/寶石（ore_*/gem）=挖完就沒、無再生無生產龍頭（守恆硬守=不可憑空生）。
- **自然再生**：野味/藥草/野馬（食物野地池/herb/horses 野生源）=regen 率物理再生（`regenerate_tiles`）。
- **生產類**：食物（farm_yield 農田獨立產線龍頭 + 野地採集雙源）=可有掛帳生產龍頭（`TileBank.deposit(...,"farm_yield")` chokepoint、守恆稽核含農業源）。
- **木材採集加速**：伐木場=加快野地木材收集（非獨立生產、樹非短期可種）。
- **鑄幣**：coin 唯一源=`_tick_mint` 礦→幣（room-capped 守恆、無其他生成）。
- ★守恆=**可溯源非禁生成**：生產類/regen 可有掛帳龍頭（tagged reason）、零生成類硬守不可生。守恆稽核（InvariantAudit）逐源對帳。


## 決策 option 的「競爭範圍」與「承諾優先級」解耦（§4a、2026-08-20 systems 裁 + R² 護欄）

- **兩語意本就不同、禁再綁死**：`sets`（`survival`/`passive_survival`…）=**這個 option 在哪些 rank 清單裡競爭**（`rank_survival` 只收 survival-set）；**commit priority**=**committed 後誰能打斷它**（`TaskArbiter` 階梯）。
- **★`DecisionOptions.REGISTRY` 可用 optional `"priority"` 欄顯式覆蓋** `priority_for` 的預設推導（預設：survival-set→`PRIO_SURVIVAL` / threat 三 option→`PRIO_THREAT` / 其餘→`PRIO_DISPATCH`）。**此欄是把 threat 早已在用的顯式覆蓋模式推廣成通用**（收斂「隱式 set 推導 + 顯式 threat 清單」兩套並存語意）、**非後門**。
- **★護欄①值域鎖死**：`priority` 只准填 `TaskArbiter` **既有具名常數**（`PRIO_COMBAT/SURVIVAL/THREAT/PLAYER/VENDETTA/DISPATCH/FACTION/AMBIENT`）、**禁裸 int**（防隨手標 `99` 繞過整個優先序階梯=真後門）。
- **★護欄②必附 why-comment**：任何 option 使用此欄覆蓋預設，**須在 REGISTRY entry 留一行理由**（防日後有人為了讓某 option「贏」隨手蓋掉、事後看不出是刻意設計還是誤標）。
- **首例**：`紮根`（L0→L1 工期）留 `survival` set（絕境隊也該能被 util 秤、拿掉=隱含硬門檻）但標 `PRIO_DISPATCH`——**長工期發展型動作必須能被 threat(70)/survival(80) 打斷**（`corvee_site` recovery 讓進度不歸零）。


## 死亡窗口（走屍隊）決策紀律（2026-08-20 systems 立、R² 繼承-lite 抓到具體 race 後升格）


滅團**不即時 erase**（`world_state.gd:44` 註：中途 erase 不安全、多系統持 team_ids 快照）→ 存在**兩層窗口**，窗口內死隊在 `state.teams` **完全活著**（無 `is_dead` flag、population 可能非 0）：

| 窗口 | 範圍 | 已死但仍可見的集合 |
|---|---|---|

> ★血證／案例 → `invariants-cases.md`（同標題節）


## LOD 降頻補償紀律（2026-08-20 立、LOD 紅線修實戰產出）


> ★**適用範圍（2026-08-21 加）**：效能 arc 的 **G 刀（零 LOD／刪近遠分班）落地後，本節僅適用於「仍然存在的降頻機制」**（如未來任何 tier 降頻）。**判準本身（機率型/累積型/離散門檻型/飽和型四分法）通用、不隨 G 作廢。**

**LOD 只能降解析度、不能降真實**（用戶 2026-08-14 立身宣言）。當某系統從「每 N tick 跑」改成「每 M tick 跑」（M>N，`trials = M/N`），逐項按**行為型別**判斷要不要補償——**判準是「每次呼叫是否累積/抽獎」，不是「有沒有用 RNG」**（這個誤判本人犯過：見下）：


> ★血證／案例 → `invariants-cases.md`（同標題節）


## 長跑量測床的三條硬規（2026-08-20 立、大考實戰產出）


1. **「day」必須由真 tick 導出，禁用 loop counter**——`day = state.world.current_tick / TICKS_PER_DAY`。血證：世界 `game_over` 凍結後 `advance_tick` 近 0us 直接返回，loop 照跑滿 → 產出 **290 天假列**（tick 凍結／phase 塌成單 key／probe 全空），且**歷史上至少 4 個舊 run 同款**。
2. **必須驗前進**：偵測到「真 tick 在 N 個迴圈內沒有前進」→ **print 原因 + break**，並寫進 progress sidecar。**沉默地跑完**比崩潰更危險（崩潰看得見，假資料看不見）。
3. **probe 過濾器不可只靠白名單**：床若只落 `watch_prefixes` 命中的 key，**沒列到的 family 事後完全救不回**（血證：政治質地欄全 0＝prefix 對不上 production key 名，而非世界沒政治）。→ **結尾必 dump 全量 `Probe.counts` 一行**（成本近零），白名單只作為「每日增量」的快取用途。


> ★血證／案例 → `invariants-cases.md`（同標題節）


## 承諾態只能經仲裁移轉：直接寫欄位 ＝ 承諾靜默消失（2026-08-21 立，convoy RETURN 實戰產出）


**血證**：convoy RETURN 歸建遲到 27.9 日。我在 spec §5 預測首要嫌疑是 `persist_strength` 的 time-proxy，
並要求「先補一行 `PROGRESSIVE_HOLD_TASKS += TASK_CONVOY`」。
**實測：那一行單獨補 ＝ 與 main 逐字節相同、零效果。**
真根因是 `faction_ai:797-809` 的 merge_queue：母隊走掉 → `parent.tile_pos != sub.tile_pos` → 走

> ★血證／案例 → `invariants-cases.md`（同標題節）


## specimen 選樣必須「血緣封閉」：執行期生成的實體不得落在觀測範圍外（2026-08-21 立，convoy RETURN QA 判不了產出）


**血證**：convoy RETURN 收尾送 QA 故事稽核 → **QA 判不了**。specimen 1701 行裡 **`convoy` 出現 0 次**、
只有母隊 `3/5/7`。因為 `SpecimenDumpHelper.setup_from_env` 把 `state.specimen_team_ids`
**在 setup 當下凍結成固定清單**，而 porter 子隊是 **`SubteamSystem.dispatch` 執行期才生成的新 `team_id`**
⇒ **永遠不可能進範圍**。

> ★血證／案例 → `invariants-cases.md`（同標題節）


## ★工作紀律八條 → 已搬家（2026-08-25 #4 doc 瘦身）


**原本 176 行（全檔 21%）躲在一個只講第一條的標題底下。★它們是【我們怎麼做事】，不是【世界怎麼運作】。**
| 去哪了 | 內容 |
|---|---|
| ★`docs/process/01_architect.md` | **spec 紀律三條**（掛決策層前先驗／前提標已驗或假設／「只有一處實作」也是負斷言） |

> ★血證／案例 → `invariants-cases.md`（同標題節）


## ★★★觀測器**禁任何副作用**（不只禁耗 RNG）——2026-08-25 擴充


**既有條款**：觀測儀器（tracer／probe／HOB）**禁耗 global RNG**，否則**觀測會改變被觀測物**。

★**2026-08-25 血證把它擴到更嚴重的形式**：
> **停滯偵測器的舊 `STALLED` 分支【會清 `corvee_site`】** ——

> ★血證／案例 → `invariants-cases.md`（同標題節）


## ★means-end / 前提解析的「無手段終止」不得靜默（2026-08-25）


**遞迴解析前置依賴時，走到「這個資源沒有任何取得手段」而終止 —— 必須發 tap。**
★**理由**：那是**最容易被誤判的分支**（真相源只蓋部分物理 ⇒ 明明有路卻回「無手段」），
**而它的外顯症狀是「什麼都沒發生」** ⇒ ★**沒有 tap 就等於製造量測盲點，違反「全量暫態可觀測性」。**
**tap 必須帶【是哪個資源】，否則只知道有終止、不知道缺口在哪。**

## ★★★床必須接 `advance_tick` 的回傳值 —— **「有效窗」≠「請求窗」**（systems 立 2026-08-27，血證當日）

**血證**：S3 的間隔床請求 12 日／30 日窗，★**而 `advance_tick` 在 `tick 8160` 回傳 `game_over`** ——
★★**床忽略回傳值，繼續空轉 9000 個死 tick** ⇒ ★★★**它口中的「12 日窗」，實際有效窗是【5.7 天】。**
> ★**「活著 ≠ 前進」的床版本**：**迴圈在跑、tick 在加、床照常印出數字 —— 而世界早就停了。**

★**規則**：**任何跑 tick 的床，必須接 `advance_tick` 回傳值，並在輸出印出【首次非推進的 tick 與原因】。**
★★**沒有 game_over 也要印**（`首次非推進 = 無`）—— **否則「沒印」與「沒接」長得一模一樣。**
★★★**而報任何 per-day／per-window 數字時，分母必須是【有效窗】不是【請求窗】。**

★**現況（2026-08-27 機械查）**：`scripts/debug/` 共 **173** 個 `advance_tick` 呼叫點，
★★**只有 2 個接回傳值**（`game_sim_multi.gd:51`／`game_sim_test.gd:119`）⇒ **這是系統性的，不是單一床的疏忽。**
★**便宜的既有訊號**：**多數床已經在印 `[TickPerf] day=N ... teams=M factions=K`**
—— ★★**逐日行【中途消失】就是死窗的指紋**（S2 終量 warring 查過：印到 `day=29 teams=118 factions=8` ⇒ 乾淨，未受汙染）。

## ★★★T0 事件瞬醒：**任何突發即喚醒相關決策層**（現況與例外，2026-08-28）
★**現況（S4b 落地）**：**九個閘位已接、覆蓋對帳 210/210、閘上 kind 過濾 0 處（零例外）。**
★★**行為證據**（注射 vs 陰性對照，同 600 tick 窗）：勢力五支／INTENT ~12×｜GOAL ~4×｜INDEP_INFRA ~47×｜LADDER ~44×。
★★★**而正常世界（未注射，7200 tick）每一支都是 event >> cadence**：
```
GOAL 595:63｜LADDER 303:19｜勢力五支 72:4｜INDEP_INFRA 103:16｜INTENT 72:12
⇒ ★S3 把七支拉到 3 日之所以還能反應,不是「慢了但可接受」,是【慢的那條路只佔 6–20%】
```
★**已具名例外**：**`LADDER` 的 cadence 重排寫在 callee ⇒ 事件喚醒那次【也會】把週期往後排**（其餘八支不會）。
★★**排除的假風險**：**廣播事件同時重置 ⇒ 會恢復 lockstep？不會** —— `CadenceStagger` 的 offset 是 `_mix(team_id, cycle_index)`，**同刻重置仍各自錯開** ⇒ **爭點只剩【評估次數】。**
★**未定**：**「事件醒過之後，還該不該照原 cadence 再醒一次」** —— 見 `known_issues`。

## ★★★感知鐵律的**鏡像**：決策也不得【讀不到自己的狀態】（2026-08-25）

**既有鐵律**：★**決策只能吃 belief，不得 god-view 讀世界真值。**
★★**本條是它的另一端**：★★★**決策也不得【連自己的狀態都讀不到】。**

| ★**god-view**（既有） | ★**blind-view**（本條） |
|---|---|
| **讀了不該讀的**（別人的真值） | ★★**讀不到該讀的**（自己的糧倉） |
| ⇒ **神目決策** | ⇒ ★**手不聽腦的另一種**：**腦沒有眼睛** |

**血證**：`TradeValuation.reserve(team, res, leader_values, state = null)` ——
**包裝層 `InteractionSystem.local_value(team, res)`（`:660`）／`PlayerTradeSystem._sellable_qty(team, res, leader_values)`（`:13`）簽名裡【沒有 `state`】**
⇒ ★**留底估值讀不到自家糧倉** ⇒ **定居隊（糧在糧倉、私產 0）會誤判自己沒糧。**

★★**而 `state` 明明在呼叫端手上**：`player_trade_system.gd:72` **同一行**裡
`TradeValuation.leader_vals(state, tgt)` **傳了 `state`**、`_sellable_qty(tgt, res, …)` **沒傳**。
⇒ ★★★**不是「拿不到」，是【簽名沒開那個口】—— 純接線可達，不需要新增資料流。**

★**同源**：`resource_system.gd:443-445` 早已寫明「**WS-1 把定居隊糧搬進糧倉只改了消耗，漏改決策讀者 → 定居隊/商隊 AI 誤判餓**」。
⇒ ★★**`reserve` 正是那批「漏改的決策讀者」之一 —— 這不是新設計，是既有裁決還沒走完。**

### ★★第二例（2026-08-27，S4 期間抓到並修）：**製造投入端只讀私產**
```
manufacturing_system.gd:179-180  產出【檢查】= team.resources + tile.public_storage   ←讀兩池
_add_output                       產出【寫入】= TileBank.deposit(tile,…)              ←寫公庫
:212                              ★投入【檢查】= team.resources 只有這個
:197                              ★★投入【扣款】= ResourceBank.add(team, res, -(cost))
```
★**修法四件**：**同池集／以實扣為準＋loud-fail／走單寫者 `TileBank.withdraw`／所有權複用 `_team_works_tile`。**
★★**而【半修比原病更糟】**：**檢查讀兩池、扣款只扣私產 ⇒ `add` 負數不保證 clamp ⇒ 私產扣成負數＝憑空造材料。**
★★★**誠實限**：**修完【不等於】那個殘差被解釋** —— **公庫路徑 `tried = 0` ⇒ 這條 blind-view 在該床從未綁**（因果已撤回）。
