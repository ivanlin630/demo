# Known Issues

> 最後更新：2026-06-16 | **本檔只列開放項**。已修項（✅）移 `docs/archive/resolved_issues.md`（保留根因/修法/教訓,可搜尋）。
> 來源：動態測試 + code review + QA harness 遍歷。
> **仍有效真 backlog**：Bug2(salary floor 後果)、Bug5(休眠)、W4(NPC promote/train + leader 駐留)、W3(dist tune)。（P5 C-1~C-6 對稱缺口 ✅ 2026-06-16 reframe+實作,見下 P5 段。）
> **圖形 Main.tscn 項 moot**：`run/main_scene = TextUI.tscn` → S5/U5/U6/U7/U8/U9 等 graphical 項凍結,復活圖形 UI 才解。


## 統一矩陣窮盡稽核揭項（2026-07-01，全貌 `specs/2026-07-01-unification-matrix-audit`）

- **★確認 bug：NPC-NPC 乞食(BEG)/投靠(JOIN) task 路徑死**：`interaction_system.gd:197` `if a.combat_target != -1 or b.combat_target != -1: return` **先於** BEG resolver(`:247`);BEG/JOIN dispatch 恆設 `combat_target`(options.gd:96/104、faction_ai:1377)→ 早退不可達;**TASK_JOIN 根本無 `_try_interact` handler**。NPC 絕境「乞食/投靠」(P2a option)walk 到目標被 197 殺、無 resolve;player 版直呼 `_resolve_aid_request` 繞過故沒露。**影響**：P2a 絕境 repertoire NPC 側可能空轉。**先 measure**(插探針量 NPC BEG/JOIN 實際 dispatch+resolve 率)再修,別直接當實([[feedback_avoid_rabbithole]])。修向：BEG/JOIN resolver 移到 197 早退前 or combat_target 語意拆(社交 target ≠ 戰鬥 target)。
- **★第3不變量單寫者大面積未實現（強制閘前提）**：`team.resources` 乾淨(全 ResourceBank,first-pass「53直寫」修正=錯)。真洞：**tile.public_storage(granary)+tile.resources 全無 bank**(22+直寫)、**coin 憑空鑄入 public_storage 無 treasury bank**(outpost:228/241)、**named_members roster 無 chokepoint**(59 site/17 檔)、**combat_target/tags/solo_intent/faction.leader_team_id/person.coin/fatigue/armed_anon_ratio 無主**、**Pattern B driver-ledger=全 5 bank stub(reason 丟棄)**。team-creation 無 chokepoint(vs erase_team 有)、succession 三重手寫、faction_id=-1 6 處直寫繞 set_team_faction。= 統一矩陣「單寫者」領域最空,撐強制閘的前提。
- **守恆盲區**：person.coin `+=` raw(salary:66)+ coin 憑空鑄 public_storage → coin_eq audit(對 team.resources 求和)看不到。
- **其餘 fork（全 30+ 條見 audit doc）**：思考決策 5 scorer/threat term 死 stub(DecisionContext.threat=0.0)/雙 faction-goal producer;互動 2 diplomacy resolver(god-view vs belief)/3 tribute 公式/3 deception 引擎/RelationGraph orphaned;人力雙 skill/injury/equipment 模型;player 48 handler 4 缺口(demand_tribute/recruit×2/betray 全平行)+ UI god-view 洩漏。**燒序見 audit doc**（首燒=獨立/faction 戰略合併）。

### 燒進度（2026-07-01 首三軌 merged）
- ✅ **首燒 戰略 intent 統一 done**（F-D1/D2/D3/D4/D6 收；致富錨接上、CONQUER 0→1）。**follow-up**：①**征服名vs實斷點**(unified 好戰獨立 想=征服但 winner=掠奪,`_decide_unified` 掠奪 option 搶在 prosperity attack 前 → 需讓征服 intent 真驅乾淨攻擊 or 掠奪納征服 affordance) ②**F-D5 unified-tag subteam 進不了 engine**(未收) ③擴張 scorer TEST VALUE(0.3+野心*0.3)待平衡校 ④solo driver 未進全隊持久 ledger(Pattern B 所有權域另軌)。
- ✅ **單寫者 slice1 coin 守恆 done**（F-S8/S1 coin 部分：全池 audit + person.coin 單寫者 + mint ledger；順修 mint-cap 燒 ore 舊項）。**follow-up**：`_route_extinct_assets` no-tile LEAK(`faction_ai:1753`,radius 全無有效格 coin 憑空丟失,正常小地圖不觸發)納下 slice or 標永久豁免。
- **單寫者剩餘 slice（未做，第3不變量 enforce 前提）**：tile.public_storage/tile.resources 一般資源 bank(granary/自然池)、**Pattern B 全域 driver-ledger 落地**(現全 5 bank reason stub)、roster(named_members 59 site)/combat_target/tags/team-creation chokepoint、succession 統一。
- **BEG/JOIN 修（follow-up，探針已證）**：JOIN=中(66/月空轉,需新 resolver + combat_target 社交語意拆)、BEG=低(被197擋)。**建議合併一次修**(combat_target「社交 target≠戰鬥 target」=共根)。BEG endgame-scarcity runtime 頻率未實測(機制已證死,頻率次要)。

### 第二批燒進度（2026-07-01 三軌 merged）
- ✅ **B 食物張力 done**（張力機制到:forest 苟活須交易/plains 繁榮/不 mass-starve）。**★下一閘=交易網未轉真因=建設 util 碾貿易**（specimen 商隊 想=致富但 winner=建設 0.79>貿易 0.26,決策權重域非食物）→ granary 爆倉閘拆後露出。**修向**：貿易 util 提權（有訂單/arb 時應勝建設）or 建設 gate。屬決策權重 slice。**其他 follow-up**：FOOD_PER_PERSON 0.8 + flow 常數 TEST VALUE 待平衡 pass;material harvest ÷24 但 mat_regen 未縮放（建造/製造吞吐未專測,掃一眼）;ambition rung 讀 flow=行為變（marginal 隊 flow=0 起步卡 SURVIVE、prosperity-attack 需盈餘=飢餓不主動開戰）。**★warring 全窗 24 月已驗（系統補跑,radius14 seed）**：**不 mass-starve ✓**（teams 穩~30、Famine 涓滴非潮、DONE、0 error）、**founding ✓**（found_ally=5/factions=7 穩/FOUND=1 全程）、RICH=13 主導（致富錨活）;**但 ⚠ CONQUER=0 全程、established 卡1、EXPAND=0=征服/擴張 emergence 全窗變平**。**根=雙重壓制**:①食物軌 ambition rung 讀 flow → prosperity-attack 需經濟盈餘（食物緊→少隊達 EXPAND rung→少開戰）②征服攻擊路徑分裂（見征服 measure,粗攻擊不轉化）。首燒 bounded-3 月曾見 CONQUER 0→1,加食物軌全窗回 0。**修向**:征服攻擊統一（本批 measure 修向）+ 可能 rung-gate flow 門檻放寬（TEST VALUE）讓侵略隊更易達 EXPAND。= 沙盒征服維度**仍差最後一哩**（食物張力到了、但耦合壓平了侵略,需征服修 + rung 調重啟）。
- ✅ **單寫者 slice2 done**（driver-ledger 真記 + roster chokepoint + audit）。**★audit 揭 pre-existing leader/team_id desync**（merchant leader P0 team_id!=本隊,經 leader 指派非-named 路徑;roster chokepoint 已修 named-transfer desync tyrant 4→0,但 leader 指派路徑覆蓋不到）= **第3不變量首個可查對象,root fix 行為變待 triage**（動 leader 指派/team_id 寫路徑）。**其他 follow-up**：`driver_tick_hint` sim_runner 未接線（要真 tick 溯源再接）;反向 roster audit 未做（需先解 health famine「死亡留屍保 team_id」語意）;`beast:30`/`subteam clear()` 兩豁免暫緩。
- ✅ **征服名實 measure done（證偽首燒假設）**：真斷點**非**掠奪搶排序（掠奪僅 2.4% winner、0 capture=打錯靶）,是**攻擊實作分裂**——舊 solo 粗攻擊(`_nearest_independent` 無 scout/rung gate,@PRIO_DISPATCH 優先)vs `_evaluate_prosperity_attack` 細攻擊(weakest-prey/scout-gated/導 subjugate),粗淹細 → 243 攻擊→1 capture。**修向（follow-up spec，數據支持）=統一征服攻擊路徑**（非-unified 好戰隊 TASK_ATTACK 委派 prosperity/共用 gate+subjugate 導向）。**次診斷**：攻擊→capture 轉化崩在「打不贏」還是「贏了不吸收」需另一輪 measure（戰鬥結局分布）。**→ means-end 已收攻擊路徑統一（route 6.6×）,但 capture 完成 depth 仍低,見下。**

### 第三批燒進度（2026-07-02 means-end + slice3 merged）
- ✅ **means-end 接戰術層 done（intent_fit,願景進化第一深化）**：戰術層 intent-blind 修（intent 注入 ctx + intent_fit reshape option util）。**症狀 a（致富→貿易）全解**。**follow-up（移動標靶下一步）**：①**capture 完成 depth 低**（征服→攻擊 route 6.6×成、但吞併完成率未升 3→1=combat/subjugate 完成度,pre-existing;需 measure「打不贏 vs 贏了不吸收」→修 combat/subjugate depth）②**conqueror 食物 survival-trap**（高野心獨立隊 food_days≈3→困 survival-loot、發不出乾淨征服=食物軌張力壓過戰略層;裁「餓則搶」emergence 收 or 戰略層對高野心鬆 survival gate,跨食物軌）③**over-war 4pp 落 unseeded 噪**（要硬證不 over-war 需 **seeded warring 回歸 harness**,現 conquest_measure 無 seed [[reference_multi_sanity_unseeded]]）④**防衛/守成/建國/擴張 intent uplift**（後增量,本增量只致富/征服/匱乏）⑤TEST VALUE（INTENT_FIT_DRIVE 1.5/SURPLUS_FOOD_DAYS 7/SCARCITY_RAID_MIN 0.55）待校。
- ✅ **單寫者 slice3 done（leader desync 根修）**：`set_leader` chokepoint + 反向 roster audit + ledger tick 接線。**F-S3 leader/team_id desync 結構性關閉**（chokepoint 強制同步 + 反向 audit 常駐;merchant desync unseeded 間歇未在此環境復現,結構保證非 case repro,seeded 復現=backlog）。**follow-up**：~~combat_target chokepoint + BEG/JOIN 社交語意拆~~ **✅ done（2026-07-02,social_target 拆 + JOIN resolver,join.resolve 0→4 死路消,F-S4+F-I3 收）**、tile-granary-bank/tile.resources bank（剩餘單寫者 slice）。

## 後期 scaling / late-game 卡死風險（2026-07-01 評估，全報告 `specs/2026-07-01-late-game-scaling-assessment`）

> LOD infra 存在且對 movement/economy 正確,但重認知系統 defeat LOD → O(N²)/hr。沙盒長跑須加固(否則大戲跑不到)。非重寫,P0 三項 targeted。
- **★compute top:`faction_ai_system.gd:513 evaluate_all` 忽略 LOD 參數 → O(N²)/小時**：`evaluate_all(_team_ids)` 的 subset 被 `_` 忽略、對全 `state.teams` 跑;`_has_hostile_within:1455` 每隊掃全隊無空間索引 = 主 O(N²)/hr。修=honor LOD / 加 tile→teams 索引。
- **★compute:`world_state.gd:123 erase_team` O(N)/erase → die-off O(K·N)≈O(N²)**：3× 全隊/registry ref-sweep × `cleanup_extinct_teams` 每 tick;大滅團潮 = late-game 崩塌直接放大器 = **最可能卡死觸發**（且正是沙盒最想看的大戲時刻）。
- compute 其他 O(N²)/O(N·T)/hr：`_evaluate_outpost_residency:419`(全 tile/隊)、`vision_system.gd:22 tick_discovery`(inner 全 N)、`interaction_system.gd:74`(co-location 全掃,修 pattern 已存 `sim_runner.gd:247` pos_map)、`outpost_system.gd:168 tick_all`。
- **★memory top leak:`world_state.gd:17 team_intel` observer rows O(世界年齡無界)**：`erase_team` 從不 prune team_intel → 每個曾存在的隊留永久 observer dict + 死 target claim rows。per-obs 200 claim cap 有、observer row 無。修=erase_team 加 `team_intel.erase(tid)` + 掃 observer 清死 target（同 create_faction chokepoint）。
- memory 其他：`player_alerts` headless 無 poll leak(diplomatic 未 dedup)、`person_data.gd:54 memory` 繞過 `_trim_memory` 路徑(reaction:369/diplomacy/trade/command)可超 MEMORY_MAX=20。其餘結構全有 cap/TTL/erase-prune 界住。
- **nit**:`world_state.gd:157-158 team_known[obs].erase(tid)` no-op(array 存 MessageData 非 int)→ 意圖 cleanup 沒跑;無害(TTL 覆蓋)該修對。
- **加固排序建議**：granary(定世界規模)→ P0(faction AI honor LOD + tile→teams 共用空間索引 + team_intel erase-prune)配 #2/#3 探針/計時 + scaling bed 驗 → 長跑觀 emergence。
- **P0 加固進度（2026-07-01 merged）**：✅ **tile→teams 索引 done**(co-location O(N²)→O(N)、hostile-within/residency sparse tail 收) + ✅ **team_intel erase-prune done**(top leak 修) + ✅ tick 計時 instrument + scaling bed。**honor-LOD 未觸發**(量到 evaluate_all 誠實 O(N)、索引已足;行為變 measure-gated 沒量到不做)。⚠ **die-off erase O(N) ref-sweep spike 仍 open**(不在 P0;大滅團潮 K×O(N) 放大器=長跑滅團潮若量到 freeze 再另案:erase 索引化/批次)。scaling bed sparse+high-movement near-zone 場景待加(整合 TickPerf 顯 co-location 增益)。
- **★致富非 named intent（specimen tracer 揭，經濟真根，2026-07-01）**：獨立商隊決策全走 DecisionEngine per-tick utility 標「日常」,**零 named 致富 intent**(commander-v2 只給 faction intent、獨立隊無致富意圖節點)→ 交易純 emergent、被 survival/食物壓力碾成覓食/買糧(無複利)。**修向（待藍圖）**：致富要不要成 named 意圖=給獨立隊致富 intent 節點(統一決策 arc 延伸);且食物壓力(R1,緩)是掐致富直接手。**更新（首燒 merged）**：致富**已成 named intent**(select_strategic_intent 給獨立隊全菜單) → specimen 商隊現 想=致富262/263。
- **★致富→交易 下一閘＝建設 util 碾壓貿易（B 食物張力 branch 揭，2026-07-01，`feat/food-tension` 未 merge）**：granary爆倉真根**已修**(R1 供給 day_fraction 對齊 + far 冗餘 regen 移除 + R2 成長讀 flow 非 stock + FOOD_PER_PERSON 0.8 張力校準;forest 苟活/plains 繁榮/不 mass-starve 皆 bed 證)。但 specimen 商隊 想=致富262 → winner=**建設**263/263(建設0.79 > 貿易0.26)，**從不貿易** → 致富→交易→成長鏈仍不接。**新真閘 = 決策層 建設 util 高於貿易**（非食物/granary，屬決策權重域,本軌 scope 外）。修向：貿易 util 提權 or 建設 gate（有訂單/有 arb 時貿易應勝建設）＝決策層另軌。
- **★野心 rung 改讀食物 flow → 戰略層行為變（B 食物張力 branch，待主 session 裁）**：`ambition_ladder` 積累 rung 由 `effective_food`(stock) 改讀 `food_flow_avg`(持續淨盈餘) → 新隊/marginal 隊 flow=0 起步暫卡 RUNG_SURVIVE(需持續盈餘才升 rung/觸 prosperity-attack)。**founding 未受影響**(獨立建國用自身 stock gate `faction_ai:994` 未動,framework S1 PASS);但**侵略性擴張(prosperity-attack)現需經濟盈餘**(飢餓隊不再主動開戰)＝合理但屬行為變,warring 全窗未驗(sim 太重 timeout,見 progress)。
- **specimen tracer scope 缺口（非 bug）**：`capture_decision` 只 tap unified+survival winner commit,**prosperity-attack(`_evaluate_prosperity_attack`)+faction-goal-dispatch(~faction_ai:1090) TASK_ATTACK commit 不捕** → 「征服 intent→攻擊 action」鏈那段 tracer 看不到。要完整 trace 需增這兩點 capture。

## 讀B/G3 Phase E backlog（2026-07-01 平行軌）

- **★次閘：定居隊 granary 自填 = trade loop 不 fire 真閘（讀B 覓食 cap 後 measure 揭）**：覓食 subsistence cap 正確封住覓食成長路徑（unit 測 + priv food 壓低證），但 econ_bed baseline 對照顯 **forest 定居隊（regen food=3）granary 月1 即填至 ~cap（gran≈1999）並維持**，pop 成長由 granary（eff_food≈2200）驅動非覓食（priv≈150-288）→ cap 對定居成長影響小 → **trade loop 沒需求驅動、不 fire**。「繁榮須交易」emergence 未到（覓食封了、granary 旁路未封）。屬 **granary/harvest 域**（食物統一 arc 下一 slice），非覓食 cap scope。**修向（待藍圖排序 + measure）**：查 forest regen 3 為何 granary 也填滿（harvest 產出 / storage cap / tile 食物池 init 來源）→ 定居隊 granary 亦須「特化受限」才逼交易。覓食 cap 是必要地板層（granary 修好後覓食不能 backfill 成長）。
- **`FORAGE_FLOOR_DAYS=1.5` = TEST VALUE**：econ_bed/warring 顯覓食隊苟活不死、不膨脹；正式平衡再校（太低=餓死潮、太高=仍自足）。覓食 cap 對玩家 active hunt 同樣生效（對稱），玩家面手感待真人玩測。
- **G3「自信地錯」emergence 需 Phase D + 專屬 probe 才量得到**：Phase E enforce 機制到位（決策真讀 belief、欺敵可有後果、回歸測綠），但**未加專屬「按假 belief 行動並被咬」計數器** → 短窗 seed 無法量化 emergence。需 Phase D（植假 primitive）+ probe。本 phase 只證「決策跟 belief 走」。
- **headless baseline 既有 FAIL：`[FAIL] 弱目標未加入攻擊 goal`（pre-existing，非 G3/讀B 引入）**：已驗 main dd26f67 baseline 即此 1 FAIL（G3/foraging 兩 branch 皆 1 FAIL 同源）。locus = commander-v2 `_update_goals` 攻擊 goal 未對弱目標開（belief/goal-emit 相關，非本輪 5 leak）。待另案追（確認為 bug or 刻意行為）。
- **G3 1c 施援同 faction snapshot 豁免 = 可選增益（裁定：維持 belief-strict）**：`_find_aid_target` 對同 faction 成員現走 belief-strict（無本隊 team_intel belief→跳過），未讀 faction `known_member_states` snapshot（leader 共享 belief）。**不違 provenance 不變量**（snapshot 本身 = best_estimate 派生、非 god-view）→ 現行正確且保守。snapshot 豁免=增益非修正，列可選後續，不擴 scope。

- **anon_treasury 滅隊 off-map leak（既有,degenerate only,2026-06-22 AnonTreasuryBank 揭）**：`faction_ai_system.gd:~1456`——隊死於 off-map 且 `_nearest_valid_tile`(radius-12)找不到 tile → 公庫 coin 無處傾倒、靜默丟失（命名 `AnonTreasuryBank.reset(team,"extinct_no_tile_LEAK")`）。**coin_eq/CoinAudit 抓不到**（隊正被 erase，丟的是「該路由到 tile 的」非「留在隊的」，audit 對 state.teams 求和 delta 仍 0）。正常地圖不觸發（radius-12 內必有 tile）。**小修方向**：找不到 tile 時擴大搜尋 / 倒入全域 sink / 記 ledger。非阻塞。

- **mint coin-cap 燒 ore off-ledger（pre-existing，G1a 首 fire 才浮現，2026-06-23 opus 終審揭）**：`outpost_system.gd:~228/241` `_tick_mint` 用 `minf(cur_coin+coin_added, cap)` clamp coin 到 storage cap——若鑄幣 tile 的 coin vault 飽和，ore 被消耗但 coin 被 clamp 截掉 → coin_eq 損失（ore 燒掉沒換 coin）。G1a 前 mint 從沒 fire 故未觸；G1a 讓 mint 真 fire → 長跑可能浮現。**小修**：coin 滿 cap 時跳過/部分消耗 ore（別燒）。非阻塞（現 run delta=0）。

## affordance 真實性債（commander-unify v2 盤點，2026-06-28）

> 北極星「凡 named 意圖必有可解釋驅動」+ affordance 真實性 invariant：宣稱效果模擬不出=孤兒 affordance=假。commander v2 **只掛真 affordance**，下列孤兒=暫不掛、列債（撐起來才掛）。盤點 = action-effect 審計（7 action/47 真效果/29 孤兒）。

- **真 affordance（v2 可掛）**：攻擊=削軍力(`npc_combat`casualty)+掠奪得資源(30% loot)；徵收=籌資(resource transfer)+壓迫(stress/loyalty hit)；外交=真結盟(faction merge)+背叛(betrayal 65%)；貿易=致富(+coin/換貨)；建設=mint(ore→coin)/stable(練騎)/倉儲;結盟=faction merge。
- **孤兒 affordance（藍圖願景但 sim 不產出 → 債）**：
  - **欺敵外交/離間/緩兵**（外交只有真結盟+背叛，無假和/離間第三方/緩兵機制）→ 玩家錨 C「拋外交=真心還是欺敵」的欺敵層**需先建欺敵機制**。
  - **貿易戰=砸敵經濟**（貿易只 local +coin/換貨，無供應斷鏈/壟斷收購/傾銷崩價）→ 需建供應鏈缺貨傳導（撐在既有市集/order plumbing 上）。
  - **壓迫 cascade/削弱屬民**（徵收有 stress/loyalty hit，無「缺糧→餓→忠誠崩」spiral）。
  - **城防/威望/產能升級**（建設只 mint/stable/倉儲，無守備加成/招募吸引/製造佇列）。
  - **互防/離間**（結盟只 faction merge，無自動戰鬥支援）。**戰俘 ransom/勞役**（prisoner_population 欄存在未用）。
- **影響**：v2 means-end commander **真 affordance 可跑**（征服X→攻擊+結盟/徵收 補軍力，depth-1 回推）；欺敵/貿易戰 deception 層 = 下列承諾 arc。
- **★ 欺敵 sim arc = anchored-pre-player 承諾 arc（藍圖裁 A，2026-06-28，非一般債）**：欺敵=玩家錨 C 心臟（看 action 反推 driver 全靠它）。**硬綁「玩家面開工之前必落地」**。內容=假和/斷供-貿易戰/離間/緩兵 sim 機制 → 建好**插回 commander 既有 means-end 機器**（affordance 由孤兒轉真、自動進匹配）。時序：commander-v2 → **欺敵 arc(玩家面前)** → 其餘孤兒 richness pipeline（壓迫 cascade/城防-威望-產能/戰俘 ransom，按 player-visibility）→ 玩家面。**禁無限延**（承諾 arc 非 cosmetic）。

## 統一決策框架 / survival backlog（P2b-1 揭）

- **attacker 輕飢 churn（pre-existing，P2b-1 world_sim 量測揭）**：~927 次/2yr 攻擊隊輕飢→`_evaluate_survival`→survival 評估無可派 option→`release`→idle→再攻 → churn。**非 P2b-1 引入**（baseline 927→after 932 幾乎不變）= 既有獨立問題。spec measure-first 把 1037 `[Survival]` 誤解為 return_home 熱路徑，實為此 churn 主導。**修向**：survival entry 對「無可派 option 之輕飢攻擊隊」早退不進 survival 評估 / 或攻擊 task 對輕飢更黏。待排序。
- **restock_need 非距離感知（P2b-1 距離 nuance 丟失）**：舊 `_trigger_survival` home-path「遠 outpost(eta>5天)+殘忍/好戰→就近掠」隨委派移除（`返家補給` 一律返家）。loot 稀有(11/2yr)，影響小。**後補向**：`restock_need` 加距離衰減 → 遠家殘忍隊重獲就近掠傾向。
- **survival 掠奪 option 無 G3d-1 confident_enough gate**：`掠奪` option（P1 建，P2b-1 沿用）的 `_find_weakest_prey` 只 has_belief 守衛，**未過 `confident_enough`**（invariants §決策風險 gate 列 survival loot 應 gate）。= 與舊 homeless loot parity（舊亦無 gate）、與舊 remote-loot Path1（有 gate，已隨 P2b-1 刪）不一致。後果：慎重 leader 絕境掠奪可能中假弱誘殺（無 scout 保護）。非 P2b-1 引入（P1 既存）。**修向**：`掠奪` applicable 或 to_task 前過 confident_enough（慎重者不確定→不選/scout）。
- **`_evaluate_solo` survival 仍雙 owner（P2b-1 範圍外）**：solo AI 的 camp/join survival scoring（`faction_ai_system.gd:~1058-1099`）仍手寫，未統一進 `rank_survival`。P2b-1 只統一 `_trigger_survival`。並 P2b-2 或獨立塊清。
- **`返家補給` 站家上 edge（P2b-1 generalize 擴大觸及）**：隊站自家(空)outpost 上絕境 → `返家補給` target=當前格 → return_home 原地。舊 Path1 同行為，未新增 latch，但 generalize 擴大觸及面 → 留意 world_sim 是否現原地空轉。

## G1a 礦村（鑄幣脈絡）backlog

- **礦村稀有邊際**：非貪婪 leader 在無 in-range 平原勝 MIN_BUILD_SCORE 時，ore +35 仍可把含礦山推過建址下限 → 偶founds 礦村。可信（山是唯一選項）非守恆問題，稍寬「稀有」。量測註記。
- **dense map distance 免疫未測**：`_check_distance` 含礦山 civilian 免疫（同 tick 多寫/密圖）未驗。
- **default 自然 fire 4/5（unseeded）**：礦村魂 default.json 自然 fire 但非每 run（tail 行為）；world_sim(buffed) 1/1。看機制 fire 非絕對閾 [[reference_multi_sanity_unseeded]]。

## G2 目標錨點進度

- **G2a（關係圖 typed-edge）✅** + **G2b（野心階梯狀態 + strategic 衍生）✅**：`TeamData.ambition_rung/archetype/cap` 由 `AmbitionLadder` 從 leader values + 隊安全 derive（faction_ai cadence update）；`strategic_ai._update_faction_goals` 改讀階梯衍生 expand/trade（真 reader，非 dormant）。階梯門檻/權重全 TEST VALUE（待藍圖平衡 pass，handback `systems-to-blueprint-g2b-feel`）。
- **G2c（rung×archetype→task 映射）✅**：`AmbitionLadder.rung_task(archetype×rung)→既有 TASK_*`（零新 task）；faction_ai ambient caller 以 `PRIO_AMBIENT`(最低,只填 idle) 指派；prosperity attack 對齊（僅武力 archetype + rung>=擴張 才主動征服）。rung1-2 三 archetype（武力 TRAIN/→prosperity、商業 TRADE、定居 PRODUCE/BUILD）。立國/稱霸細節、商業遠程商隊(依 G1)、外交/徵收深做 = 後續 refinement。
- **G2d（私人脫軌 / 血仇）✅**：`NpcAiSystem.vendetta_target` 讀 leader 最強 feud 邊 + 衝動 gate；`faction_ai` 以 `PRIO_VENDETTA`(55) 脫軌設 TASK_ATTACK（生存/威脅擋得住、prosperity 擋不住）。= G2a `relation_edges` 真行為 consumer（消 dormant）。框架債：pre-existing dormant `get_goal_task_override` 已刪（接 `project_framework_seams` dormant 清理）。
  - **OUT（後續）**：弱仇「偏置」（擴張優先挑仇人邊）= refinement；`killed` 型別深用。
- **A 類 feud 放寬 ✅（2026-06-20 merge）**：feud 由「被侵害」本身形成（劫掠/吞併/屠/背叛，非只倖存被搶）+ **滅族 faction 餘部繼承**（`spread_feud`，事件當下傳同 faction member team，**非血親**）+ severity×個性 gate（`form_feud` 唯一形成點，`FEUD_MIN=0.30` 擋噪音）。把 G2 §5 血仇傳播做實。**血親(parent/kin)傳播仍 OUT** = 待 ④Trait/家族樹（G2 無血緣邊）；獨立團(faction_id=-1)無餘部=仇隨滅消（可接受）。**emergent 量未驗**（world_sim seed77 該 run 零戰鬥；非確定性）→ 遞延 #1 經濟壓力 + scout/ambush 場景。TEST VALUE（FEUD_MIN/severity 階梯/SPREAD 0.6）待有戰鬥重量 run 校。
- **G2 主體（a/b/c/d）全完成 ✅**。後續 = 上述各 refinement + 商業遠程依 G1d + feud 血親傳播(待家族樹)。

## G3 殘缺情報進度

- **G3a（belief accessor seam）✅**：`BeliefSystem.best_estimate/has_belief/uncertainty` 包 `team_intel` 單一讀 accessor；決策單 entry 讀者（diplomatic/strategic/threat/faction_ai/player_api_mapper/inquiry）全遷走它，**行為完全保留**（accessor 回現單 entry 語義，回歸零變）。de-risk G3b：屆時換 multi-claim 只改 accessor 內部，讀者零動。inquiry key 迭代（讀「對所有 tgt」）保留，僅取 entry 改 accessor。
- **G3b（multi-claim 儲存）✅**：`team_intel[obs][tgt]` 由單 dict → Array of claim（值/源/時效/可信度/失真）。寫端三處遷 `record_claim`（vision/interaction 親見 cred=1.0 同源 merge；message 傳播停 confidence-max 覆蓋 → 跨源 append 不覆蓋、同 giver 更新）。`best_estimate` 聚合最高 credibility claim、`uncertainty` 換 claim 分歧（≥2 用 population_est `(max-min)/max`）、caps 剪枝。讀端收尾 sim_bridge/inquiry（`known_targets` accessor）。讀容錯舊 Dict（test/transitional coerce 單親見 claim）。回歸：headless 全綠、coin_eq=0、InvariantAudit 0、1000 tick；行為非保留（多源/分歧為真 WHAT 變化）。
  - **TEST VALUE**：`MAX_CLAIMS_PER_TARGET=4`、`MAX_CLAIMS_PER_OBSERVER=200`、uncertainty 分歧欄選 `population_est`、relay credibility interim `(1-HOP_DECAY)*entry.confidence`（G3c 換 類型×trust×跳數×時效）。
- **G3c-1（可信度公式 + 身份信任 + 類型基準）✅**：claim 可信度從 G3b interim flat → 真公式 `effective_credibility = source_credibility(類型基準 CRED_BASE × 身份信任 × 跳數) × 時效衰減`。寫時 cred 存進 claim、讀時乘 time_decay → best_estimate 改排 effective（新鮮勝陳舊）。source_type 正名真來源類別（親見/隊友/商旅/流民，relay 依 giver 分類；distort 另存 `distorted` flag 兩維度）。**身份信任 = `TeamData.known_reputations`（team→team，覆寫 HOW spec §4 trust 邊，不開 RelationGraph person 邊）**；親見比對 relayed claim pop_est → `update_reputation(source, ±)`（準升騙降，被動查證，record_claim 內單一 choke）。修 G3b relay 雙重 HOP（hop 只算一次）。回歸：headless 全綠、coin_eq=0、InvariantAudit 0。行為非保留（best 排序變 = WHAT 可信度真公式）。
  - **TEST VALUE**：`CRED_BASE`{親見 1.0/隊友 0.8/商旅 0.6/流民 0.3}、`TRUST_FLOOR=0.5`、`BELIEF_HOP_DECAY=0.15`、`CRED_AGE_FULL_DECAY=TICKS_PER_DAY*30`、`CRED_TIME_FLOOR=0.2`、`TRUST_DELTA=0.05`、reconcile 比值門檻 [0.7,1.3] 升 / <0.4 或 >2.5 降。
  - **coupling（interim）**：known_reputations 兼外交/施捨/勒索口碑 → belief 查證 ±它 =「騙我者我也少分享」emergent-coherent（非 bug）。量測顯衝突再拆專用 trust。
  - **OUT（待）**：決策改讀 uncertainty + scout 主動查證迴路（G3d）；team_known 事件謠言 claim 化（G3d/專案）。本 plan 決策仍讀 best_estimate（多源時值改變、接口不變）；查證為被動（親見偶遇既有 relayed 才比對，無 scout dispatch）。
- **G3c-2（技能識破 + 觀察吃技能）✅**：識破 = 收 distorted claim 折 cred（信假/生疑/裁決，best_estimate 排序消費）；觀察吃技能 = 親見值噪吃觀察者偵查/戰術（cred 仍 1.0）。is_suspicious 由 G3b dormant → 分級寫（降 UI/G3d flag，非唯一效果）。TEST VALUE：DETECT_SCHEME_GAIN/SUSPECT_T/ADJUDICATE_T/SUSPECT_MULT/ADJUDICATE_MULT/OBS_SKILL_NOISE_GAIN。
  - **⚠ watch（觀察吃技能 × reconcile 交互）**：觀察吃技能 → 親見 truth 本身可能錯 → G3c-1 `reconcile_firsthand` 拿錯 truth 比對 relayed → 可能誤罰對的 source。主題 coherent（看錯怪線人），balance watch；若量測顯線人信用噪過大 → reconcile gate by observer 偵查 或降 gain（後續）。
  - **OUT（待）**：決策讀 uncertainty + scout 主動查證（G3d；裁決級「觸發查證」在此接，本層裁決 = 強折 cred + flag）；team_known 謠言 claim 化（G3d/專案）；戰術識破伏兵/佯動（戰鬥域 OUT）。
- **G3d-1（決策讀 uncertainty + 風險 gate）✅**：攻擊性 commit 讀 (best 值 + uncertainty)，`BeliefSystem.confident_enough(觀察者,目標,慎重)` gate（confidence=1-uncertainty、threshold=lerp(LOW,HIGH,慎重)）。插 faction_ai prosperity attack + survival loot、diplomatic demand_tribute。不確定+慎重→被動按兵（下次 cadence 重評）；莽者→照衝→假情報誘殺。不 gate 威脅(防禦極性反)/vendetta/結盟求和。survival loot gate 失敗 fall-through 不凍結。回歸：headless 全綠、coin_eq=0、InvariantAudit 0、200 Tick sim 仍有攻擊（不凍結）。行為非保留。
  - **TEST VALUE**：`GATE_CONF_LOW=0.0`、`GATE_CONF_HIGH=0.6`（莽者門檻 0 恆過，慎重者需 confidence≥0.6 即 uncertainty≤0.4）。
  - **OUT → G3d-2**：①scout 主動查證迴路 ✅（見下）②威脅(防禦)uncertainty-gate（延 post-measure）③team_known 謠言 claim 化（延 post-measure）。
- **G3d-2（scout 主動查證 + uncertainty cred-weighted）✅**：①**uncertainty 重定義 = credibility-weighted**：`clamp((1−top_eff_cred)+cred 加權值分歧,0,1)`（top=最強源 eff_cred；分歧=`Σwᵢ·|vᵢ−best|/(Σwᵢ·best)`）。取代舊 raw `(max-min)/max`——親見高 cred 主導壓謊→查證可收斂（舊式親見壓不掉舊假 claim → scout 永不收斂，故為 scout 前提）。既有 G3b/c uncertainty 測試核對後**仍對齊**（accessor 0.2 / multiclaim >0.5 / confidence gate / diplomacy 皆同號）。②**scout dispatch**：`_evaluate_prosperity_attack` gate-fail → dispatch `TASK_SCOUT`(move_target=prey best_estimate 位，PRIO_DISPATCH，reason "scout")、記 prosperity_target_id=prey、**不設 combat_target**；confident 後 release scout（同 PRIO_DISPATCH 擋不住自身）→ try_set ATTACK。莽者跳過誘殺不變。回歸：headless 全綠（cred-weighted/scout verification/attack gate OK）、coin_eq=0、InvariantAudit 0、1000 Tick、`[Scout]`+`[ProsperityAttack]` 並見（不凍結、收斂）。行為非保留。
  - **TEST VALUE**：`SCOUT_TIMEOUT=TICKS_PER_DAY*3`、uncertainty top/spread 權重。
  - **⚠ watch（收斂依賴時效/值接近）**：cred-weighted spread 由 best_val 正規化——假 claim 值離 best 越遠、cred 越未衰，uncertainty 越壓不下（真打架→持續 scout 直到 SCOUT_TIMEOUT release）。設計符合（矛盾大本該查不停）；若 sim 顯 scout 過頻/卡 timeout → 調 SCOUT_TIMEOUT 或 GATE_CONF_HIGH。
  - **scout 追擊精度**：`_refresh_attack_pursuit` 僅處理 TASK_ATTACK/LOOT，scout 追擊靠每 cadence 重評刷新 move_target=最新 best_estimate（prey 移出視野→走陳舊位→timeout release）。可接受（timeout 防卡），未做攔截預測（OUT）。
  - **OUT（待 post-measure）**：威脅(防禦)uncertainty-gate（§8 極性反）、team_known 謠言 claim 化（§3 獨立 arc，**告知藍圖呈報**）、斥候被抓/餵假（C 情報戰）。
- **G3-targeting（攻擊目標選擇讀 belief）✅**：G3d-2 揭的 `find_prosperity_prey`/`_find_weakest_prey` 直讀 prey 真 population/resources（god-view）缺口**已補**——選擇層 richness/weakness/pop 一律經 `BeliefSystem.best_estimate`，`has_belief` 守衛無情報不評估（禁 fallback 回真值）。weakness 吃 `armed_est`(偽裝載體,退 pop_est)、richness 經 `_belief_richness`(tier2 sum/100 → resource_scale 粗估 → 0)。自身真值照讀、位置 reachability 讀真位(物理 OUT)。**誘殺脊椎閉環**：選擇讀假 belief(本) + gate 把握(G3d-1) + scout 查證(G3d-2) + 戰鬥按真實力結算。回歸 headless 全綠、coin_eq=0、InvariantAudit 0、`[ProsperityAttack]`+`[SurvivalLoot]`+`[Scout]` 並見(不凍結)。
  - **TEST VALUE**：`_belief_richness` 粗細混排(tier2 sum/100 vs resource_scale 0-3 同尺度排序)、survival `_find_weakest_prey` food 門檻（belief 無 food_est 時不擋,以 pop 弱點為主）。
  - **OUT（延 post-measure）**：威脅(防禦)uncertainty、team_known claim 化、情報戰 C（同 G3d-2 OUT,本 plan 只攻擊選擇真值→belief 遷移）。
- **⚠ [量測基建] world_sim 非確定性 — ProbeSummary 不可作回歸/歸因閘（#0b 實證）**：handoff #5「seed 77 可重現」**不成立**。同一 branch 跑兩次 ProbeSummary 大幅分歧（promote 35↔71、trust_up 14735↔3690、feud 1↔0、末月存活 8↔7），run-to-run 噪聲**遠大於** pre/post 差 → 無法對任何改動做 emergent 因果歸因。擴展既有 [[reference_multi_sanity_unseeded]]（multi drift 不可重現）至 world_sim。**系統裁定**：world_sim = **不可重現煙霧台**（驗「不崩 + ProbeSummary 仍印 + faction_found≥1」），**非平衡/回歸證據**；emergent 因果一律走**確定性 headless 場景 + 定向探針斷言**（如 #0/#0b 重量證 root 走的是 headless 階梯差，非 world_sim drift）。**含 feud plan Task3**：其 world_sim `feud_formed 對照前次` 同屬煙霧，真驗收 = gate/spread 單測（確定）。**選用後續（不阻塞）**：若要 world_sim 可作閘 → 補種子化（全 `randf()`/`randi()` 走 seeded rng）= 大改（散落多系統），post-#1 評估。
- **✅ 懸空 known_reputations 死隊已修（`2933563`，systematic-debug）**：root = `belief_system.reconcile_firsthand`(165-176) 迭代 claims 對每個 `sid`(來源隊) 呼 `update_reputation(sid)` **無 liveness 檢查**；claim 存活過來源隊（隊死後其轉述仍留別隊 team_intel）→ reconcile 跑到死隊 claim → `update_reputation(dead_sid)`(team_data:174 建 key) → 重注入死 id。`erase_team:147` 死時清了但 reconcile 死後重注入。**修 = `reconcile_firsthand` 加 `if not state.teams.has(sid): continue`**（死 source 不更新口碑）。world_sim InvariantViolation **556→0**。先前「補 erase_team 清 team_intel」猜錯方向（症狀非根）。**教訓**：藍圖 `state-fight-scope` 指 event_faction_defect:21 是另一回事（faction bidir，world_sim 0 violation，防禦清理非 bug）——reproduce 校正 pointer，[[feedback_verify_backlog_fresh]]。

## 框架驗證套件（2026-06-22 framework-validation 子 session）

- **Part 2 魂觸發 harness（`scripts/debug/framework_validation.gd`）✅**：每魂最小場景 setup→觸發→斷言 probe>0。**全 7 魂 PASS**（S1 立國/S2a feud/S2b vendetta/S3 scout/S4 ambush/S5 mint/S6 order_fulfilled）= 6 子系統魂的 plumbing 全可觸發，**無 code-level dormancy**。
- **dormant-in-default backlog（魂在預設 2yr world_sim 不觸發，非壞 = 場景稀有 / TEST VALUE 門檻高）**：定向 harness 證可 fire，但預設世界 run 計數為 0 —— 觸發鏈正確但**自然發生條件罕見**。各魂初判：
  - **`g2.vendetta_trigger`（world_sim=0，harness PASS）**：vendetta@55 被 threat@70 系統性擋住（設計優先序）。自然只在「強隊 leader 對**已不構成現役威脅的弱小舊仇**」才觸發（仇敵須被發現但 ThreatAssessment score < 門檻）。預設世界血仇多伴隨現役敵對 → threat 先佔 → vendetta 罕見。**非 bug**（符合「威脅優先於私仇」invariant）；若藍圖要 vendetta 更常見 → 調 VENDETTA_* 門檻或弱仇偏置（G2d OUT 已列）。
  - **`g3.scout_dispatch/converge/timeout`（world_sim=0，harness PASS）**：需 FORCE archetype + rung≥擴張 + attack_score≥.3 + readiness 過 + **prey belief 不確定 + leader 慎重**全同時成立。預設世界多為親見高 cred（uncertainty 低→直接攻不 scout）或莽者（低慎重恆過 gate 不 scout）。場景稀有，鏈正確。
  - **`g1.mint`（world_sim=0，harness PASS）**：需 tile `mint_level>0` + 居民 PRODUCE 隊 + `ore_gold/ore_silver>0` 同時。預設 config 無金/銀礦 tile 或無鑄幣廠設施 → 鏈空轉。**初判 = 場景/config 缺供給端**（金銀礦生成 + 鑄幣廠建造路徑未在預設世界出現）；接 G1a 鑄幣 arc，待 config 補金礦 + AI 蓋鑄幣廠評估。
  - **`g3.ambush`（world_sim=0，harness PASS）**：`Probe.ambush_check`（觀測點）僅在 encounter 敗方=攻方時呼（attacker 誤判弱敵踢鐵板）。預設 2yr 該 run 無「攻方低估 belief 且戰敗」事件 → 0。純觀測探針（不 gate AI），誘殺脊椎成立才會自然累計。
  - **fire-in-default（對照）**：`g2.faction_found=1`、`g2.feud_formed=3`、`g1.order_fulfilled=4`（+ g1/g3 經濟/belief 大量活動）在預設 2yr 自然觸發。
  - **量測注意**：world_sim 非確定性（見 §「量測基建」），上述 0/非0 為單 run 快照，run-to-run 會抖；harness 為確定性證據（魂可 fire），world_sim 計數僅佐證自然頻率粗略級別。

## G1 供應鏈進度

- **G1a（鑄幣觀測：W8 機制已存 + log/驗）**、**G1b（訂單 infra + 餘→賣盤 + 需求驅動生產）✅**：訂單走 message（權威存發起隊 `active_orders`，emit 為可失真傳播副本）；`OrderSystem.tick_team_orders` faction_ai cadence 發賣盤 + 過期清；`manufacturing._run_recipe_group` 讀 `received_buy_orders` 偏向需求 recipe（訂單真 reader，非 dormant）。
- **G1d（商隊訂單驅動 + 短缺買單）✅**：商業 archetype 隊 targeting 改讀 `team_known` 訂單（`best_arbitrage_order`，殘缺情報），取代 `_find_trade_target` 的 `team_discovered` 上帝視角（後者降 fallback/標 deprecated，最終應刪）；`tick_team_orders` 短缺發買單（料/武器 < `SHORTAGE_QTY`）→ G1b infra 閉環（賣盤有 reader、生產買單有來源）。到場履約走既有 interaction 同格 trade（守恆）。撲空 = 訂單 stale → `local_value` glut，emergent 無新機制。
- **#1 訂單履約 ✅（2026-06-20 merge `186e433`）**：`OrderSystem.settle_orders`（`_resolve_market` 後按 res 淨變沖 `active_orders`、填滿移除 + 點亮 `g1.order_fulfilled`/`g1.arb_hit`）。純記帳、守恆無關。settle 機制單測證正確（履約/部分/撲空/sell 對稱）。
- **⚠ [中][measure-first] order/trade 迴路 runtime 半 inert — 商隊 runtime 不交易（履約 merge 後揭）**：履約 code 正確但 world_sim 該 run **`g1.arb_attempt=0` + `[Market]成交=0`**（整 run 零交易）→ 履約率仍 0%。**非結算 bug，根因上游**：商隊 `_merchant_trade_target`(faction_ai:1180) 的 `best_arbitrage_order` 從未回非空單 → 沒商隊被 dispatch TASK_TRADE。懷疑（**未驗，別猜** [[feedback_avoid_rabbithole]]）：①商隊沒成形/沒掛 `TAG_MERCHANT`(archetype 派生) ②`received_buy/sell_orders`(team_known order message) 空 — message 沒傳到商隊 or `MERCHANT_MAX_RANGE`(20) 外。
  - **WS-1 食物糧倉已 merge（`cde372c`）= 殺幽靈囤 + 滿了賣決策**：food→capped 糧倉、消耗合併池、food sell 單 fire。囤糧崩（4-5萬→cap≤18000）、無過餓。**剩待後續**：①**UI/面板讀 team food 誤判**——定居隊 team.resources food 現=0（全在糧倉 public_storage），面板/FoodLedger 若讀 team food 顯示「沒糧」（消耗合併池已正確不誤餓，純顯示層）→ 需改讀「team+自家糧倉」合併。②**food 買單側未做**——糧倉滿發 sell，但飢荒隊買 food 的 buy 單未補（`tick_team_orders` shortage_buy 不含 food）→ 食物經濟只半邊（賣有、買無）→ 待補 + WS-2 市集完成交易。③**食物稅語意變更**（systems ack `cde372c`）：food 進糧倉不走一般稅 split（=自存自村，語意一致），稅 split 機制測覆蓋已移 material。
  - **⚠⚠⚠ [FOUNDATIONAL ARC·藍圖裁定 2026-06-21] 經濟真根 = AI 決策框架不統一 → 做「統一決策框架」大 arc**：完整 trace 證實——商隊 T1 掛商隊 tag 但 leader 人格 derive archetype=定居 → 目標錨驅動建設/生產，跟 WS-2/2b tag-based 商隊 hoist 互搏，貿易每 ~2 天被搶走 → 震盪永不完成一趟（d8 鐵證：人在別人市集、有 arb、卻在生產）。藍圖+用戶定論：**真根更深，非經濟局部**——目標錨/faction AI/solo AI/subteam/商隊 hoist/survival **各自 latch task、用 ad-hoc TaskArbiter 優先序互搏**，無「一隊一個連貫決策」。= `[[project_framework_seams]]` 框架債現形。**決定做統一決策框架 foundational arc**（比經濟大，惠及全 NPC 行為），(a)/(b) tag-vs-人格 patch **全不做、fold 進框架輸入**。believability bar：①一隊一連貫決策（survival/野心/archetype/tag/faction/feud/經濟 全是 weigh 的輸入）②加行為=加 term 非加吵架子系統 ③服務全行為類型 ④**連貫≠同質（人格必須分歧權重，嚴禁抹平戲劇尾巴）** ⑤任一隊在幹嘛都講得出「所有驅力綜合此刻最該做這」。HOW（我）：utility 形狀 / 從 N 子系統遷移路徑（de-risk seam-first 如 G3 accessor）/ term 權重 TEST VALUE / 保人格分歧機制。**經濟=第一個驗證案例**（框架對→商隊不被搶→走完貿易→6 層 plumbing 被 exercise→履約脫 0）；arc 須含重量經濟驗證當驗收。WS-2/1/3/2b/2c/2d 六層 plumbing **不浪費**=貿易執行層，只是被破碎決策擋門外。ruling `2026-06-21-blueprint-to-systems-unified-decision-framework`。**待開 brainstorm/spec**。
    - **scope map（藍圖徹查 `state-fight-scope`）**：**Pattern A 決策吵架** = 6 平行意圖槽（current_task/task_priority/move_target[無 arbiter,22 寫點]/strategic_assignments[第二套決策槽]/combat_target[全域 mutex,一沒清=整隊凍結]/prosperity_target_id/order_target_id+order_task[一槽三義]）+ 3 生產者（faction_ai→strategic_ai 順序耦合）+ 5 cadence 時鐘自閘 + IDLE-only 重評（結構性餓死=stuck 主因）+ 雙重意圖表徵 4×（goals/strategy/strategic_goals/player_goal_override）→ **收成 1 生產者/1 意圖表徵/1 weigh 非 latch/去 IDLE-only**。**Pattern B 所有權吵架** = 6 池 delta-vs-絕對 set 互洗無銀行（loyalty ~26 寫/resources ~110 寫/anon_treasury 24 寫[貨幣守恆風險]/unrest_turns[歸零壓掉該爆叛亂]/outpost_owner 16 寫/stress·fear）→ **各設 banker 收 delta 禁外部絕對 set**。現成乾淨 owner 藍本：ambition_ladder.update / AnonCohort / RelationGraph / world_state bidir。對上 `[[project_framework_seams]]`（pipeline 縫+所有權圖縫）。
  - **[可即修·藍圖定位] `event_faction_defect.gd:21` faction_id 繞 bidir helper**：活隊離派系在 faction 已不存在路徑直接 `team.faction_id=-1`，沒走 `set_team_faction`/bidir → 疑留懸空單向鏈（invariant audit 報）。**待 systematic-debug 驗機制再修**（別盲 patch，line 21 僅在 faction missing 時觸發，機制待確認）。與框架 arc 無關，獨立排。
  - **⚠ [下一層·measure-first] 履約仍 0% — market_arrive 高但 board_read≈0（WS-2c 後）**：WS-2c 破 survival 鎖後 `market_arrive` 0→100-250（商隊終於到市集）、`merchant_survival` 18837→~0，**但履約仍 0%**——商隊站上市集 tile 卻 `board_read≈0`（讀不到別隊單）。下一層 root 待查：可能 ①商隊巡到的 outpost 看板無別隊單（residents 沒 post 到該板 / `_sync_board` 清掉 / `_market_pos` 登錄到別處）②時序（到達 tick vs 看板登錄）③`_nearest_market_outpost` 巡到無單的板。measure-first：market_arrive 當下印 `tile.market_orders` 總數 vs 非己單數。**別硬調**。
  - **✅ 商隊 survival 二階死鎖已破（WS-2c merge `bb63f18`）**：`effective_food` accessor 單源（team food+自家糧倉），10 決策讀者路由（survival/trade/ambition gate）。根因 = WS-1 food 搬糧倉只改消耗、漏改決策讀者（[[project_framework_seams]] 搬資源位置=所有讀者跟著走）。merchant_survival 18837→~0、market_arrive 0→100-250。世界無過餓（2 年穩 6 隊）。保留 2 讀者（`_calc_team_need` 需求常數、`_find_aid_target` 讀他隊私產）。剩履約 0 = 下一層（見上）。
  - **~~商隊 chronic survival 阻斷~~（✅ 已破 WS-2c，見上）**：WS-2b 市集可見性機制**確定性測通**（fulfilled=1，看板登錄+親讀+巡市集全鏈），但 world_sim 3 跑仍 0%。探針定位：`g1.board_register=4831`(看板運作)、`g1.seek_market=113`(商隊想巡市集)、但 `g1.market_arrive=0`(2 年僅 1 次抵達)、`g1.merchant_survival=18837`(商隊永卡 return_home/forage)。= **商隊被 chronic survival 鎖死永不出門到市集** → 機制無從 exercise。疑**二階死鎖**：商隊無自有糧源、靠貿易進食，但貿易又被 survival 鎖（要出門貿易才有糧、但沒糧只能 survival 不能出門）。**下一個 measure-first WS** = 診斷+破商隊 survival 鎖（修後 `g1.market_arrive` 0→正、履約脫 0 = 成功信號，WS-2b 碼無需再改）。留 4 永久探針（board_register/seek_market/market_arrive/merchant_survival）作驗收。**別硬調 survival 參數，先 measure-first 查二階死鎖結構**。
  - **WS-2b 市集可見性 ✅ merge（`2ee85bb`）= 解 ③訂單可見性死鎖（機制層）**：看板登錄 outpost tile + 抵達親讀(firsthand honest,守 G3)+ 商隊巡市集 fallback。確定性整鏈測通。world_sim 待商隊 survival 解（見上）。
  - **~~經濟在 world_sim 仍 0 交易~~（已定位+WS-2b 機制修，剩 survival 阻斷見上）— 訂單可見性死鎖**：本 session 探針定位——商隊收到的訂單 **100% 是自己的**（`origin==self`）→ `best_arbitrage_order` 濾掉 → arb 永空 → 無 dispatch → 0 交易。`message_system`：`emit_message` 只放發起隊自己 team_known；跨隊**只**靠 `propagate_on_arrival`（同格碰面交換+carrier 失真）。**死鎖**：交易需知別隊單 → 單只碰面傳 → 商隊只在有 arb 才出門 → 永不碰面 → 永不知 → 永不出門。**WS-2 漏修**：只做 order pos routing，沒做 order **可見性**（藍圖 B 市集本意含「市集訂單可見」）。**教訓**：WS-2 的「[Market]5→8/履約 0→1.5%」是 `game_sim_test/multi` 量的——那台隊密集碰面遮蔽此 bug → **經濟驗收必走 world_sim（散開隊），別信密集 harness**。修：WS-2b 市集看板（訂單登錄 outpost tile + 抵達親讀 firsthand honest + 商隊巡市集破死鎖，守 G3 傳播原則）plan `2026-06-21-economy-ws2b-market-visibility`。**次旗標**：全隊卡 `return_home[survival]`（有糧仍 survival）疑壓制出門，WS-2b 量測仍 0 才查。
  - **WS-2 主角已 merge（`81bd56b`）= 解 ①dispatch 角色卡死 + ②order pos routing（但 ③可見性漏，見上）**：商隊 member hoist + solo bonus（真被派貿易）+ order pos route 到固定 outpost 市集。throughput 限 → WS-3 carry cap+馬車（已 merge）。
  - **數據定論（world_sim 診斷，臨時探針已還原）+ 藍圖架構裁定**：先前「零 TRADE archetype」**猜錯**（商業穩定 2-3 隊、arb 常非空、隊真進 task=貿易）。真因 = **多因結構縫**：①是 TRADE 的隊都卡在永不呼 `_merchant_trade_target` 的角色（faction leader 跑勢力 AI / 獨立隊覓食分數蓋過 / 子團 / member 被 SETTLE+faction goal 攔截）②漫遊商隊追舊位置 → co-location 幾不可能（`[Market]成交` 2 年僅 5 次）③那 5 次沒對上單 res → fulfill 0。④食物幽靈囤真因 = `resource_system:213` food 不在 PUBLIC_RESOURCES → else **uncapped**。**架構裁定**（ruling `economy-direction`）：選 **B 固定市集**（co-location 解）+ 硬上限給「滿」信號 + 糧倉 + **解角色卡死讓 NPC 決策 fire**（主角）；**腐壞砍**（上限封頂取代）。arc spec `2026-06-20-economy-marketplace-caps-design`（WS-1 食物糧倉 route/WS-2 市集+角色卡死[主角]/WS-3 carry cap+馬車/WS-4 糧倉設施）。**主從鐵則**：僕人不改 NPC 局部決策 = 砍。**caveat：單一 world_sim run（非確定 [[reference_multi_sanity_unseeded]]），他 run 可能有交易；確認「真never trade」需確定性貿易場景**。後果：#1 經濟閉環 runtime 沒真正活（腐壞/儲限即使造短缺→買單，若商隊仍不履約則經濟照空轉）→ **腐壞 plan-2 dispatch 前宜先釐清此上游**。修需 measure-first：建確定性貿易場景（兩隊互補供需 + 商隊）看 arb_attempt/成交在 code 路徑哪段斷，非長跑猜。
- **G1d 剩 refinement**：~~部分履約精細記帳~~（✅ 上述 settle_orders）、distort 是否動 order params（現假設只動 description/strength，撲空主靠過期）、信用幣/異地折價（移出 ③G3）、`_find_trade_target` 完全刪除、arbitrage 分數公式（現 proxy TEST VALUE）。
- ORDER_LIFETIME/cadence/SURPLUS 門檻/eligible res/SHORTAGE_QTY/MERCHANT_MAX_RANGE 全 TEST VALUE，待平衡。

## 🔴 高優先（影響基本可玩性）

### P4 玩測批（2026-06-16 玩測抓,主 session harness 驗修中）
- **U16 地圖視野不以玩家為中心** ✅ 真修(viewport,見下 U16)。
- **P4-1 demand_tribute forced event「未知提案類型」** ✅ 修(`_accept_diplomacy` 加 "demand_tribute" case + framing「要求納貢」)。
- **P4-2 打獵選項混在 team 互動選單中** ✅ 修:`_interact_action_split()` 分離 self/原地動作 vs team-target;self-actions 在目標選擇階段直接可選,team-focus 只顯 team-kind。ui_flow 驗。
- **P4-3 跟其他 team 互動缺乞討等生存選項(選項不全)** ⚠ 開→roadmap:玩家無「乞討/投靠」等主動生存動作(對稱性缺——NPC 會,玩家不能)。**非「已有功能 UI 落差」,是缺玩家 command(新 feature)** → 對稱性,需設計 spec。
- **P4-4 遭遇戰到邊界不會停** ✅ 修:encounter_view 移動 target + attack_select 游標加 `_is_in_map` clamp。GUI clamp 邏輯確,視覺待玩測。
- **動作 UI 覆蓋保證**:新增 `_test_action_ui_coverage`,47 registry actions 全驗有 UI 路徑(防未來新增漏接)。
- **「等很多」**:玩測尚有未列出問題,待用戶補。
- **狀態**:U16/P4-1/P4-2/P4-4 已修 + harness 驗;P4-3=對稱性 feature→roadmap;覆蓋測保證已有功能全可達。

### P6 玩測批（2026-06-17 玩家實機遭遇戰玩測抓）
- **E-1 弱隊殺不光 / 對攻擊免疫**（高，世界無法收斂）。`armed_anon_ratio=0` 隊 → encounter spawn 0 匿名只 1 named 接戰；normal 遭遇戰**不減隊 pop**（只擊退上場單位）→ 打贏隊 pop 原封不動 → 弱隊無限被刷但殺不死。根因：normal 遭遇戰無「敗方 pop 損耗」機制 + 未上場 unarmed pop 不受傷。修向需設計：敗方 pop 損耗 / 強制 subjugate-or-flee / 武裝率下限。
  - **退化修已實作（2026-06-19，spec `2026-06-19-e1-annihilation-degenerate`）**：A 敗方整隊 pop 損耗（encounter reserve 連坐 `_apply_reserve_casualty` + npc_combat `_end_combat` `LOSER_CASUALTY_RATE`，對稱）+ B tier 加權存活（`SURVIVAL_KILL_WEIGHT`，平民承重/菁英多生還）+ C 武裝下限（`ARMED_RATIO_FLOOR`，消費端套用不覆寫推導值）。完整意志/人海/戰俘模型仍待母 spec `2026-06-19-combat-unification-umbrella` 後續子 spec；「打到死」滅團整鏈需繼承統一 plan（`2026-06-19-leader-succession-single-source`）合入才完整。
  - **brainstorm 深挖（2026-06-19，#1 spec 前置）**：E-1 實為**兩個獨立病灶**疊加：
    1. **結構免疫**：encounter 只 spawn 上場 units = `named + mini(pop×armed_anon_ratio, ANON_UNIT_CAP)`（encounter:247-248）；死亡 `kill_random` 只記上場陣亡（:1186-1194）→ 未上場 anon mass 永不在 kill 池 → pop 殺不掉。
    2. **繼承分叉（違單一真值源）**：兩套繼承實作分叉。`event_system.on_leader_death`(:47) named 不足→**從 anon 晉升**（符合設計）；但 faction_ai 每 tick 偵測點(:502) gate `not named_members.is_empty()` + `_promote_successor`(:1066) **只從現存 named 拔、無 anon fallback** → 遭遇戰打到 named 全滅的隊「設計該晉升 anon 卻沒晉升」= 永久 leaderless anon blob（玩測觀察到 named 不再生）。`generate_for_team`(anon→named) 只被 `npc_combat:456`+`subteam:161` 呼，faction_ai 偵測沒接。
  - **關鍵推論**：單修繼承會回到「named 工廠」死循環（死→晉升 anon→又上場→又死），仍不收斂。**必須繼承統一 + 敗方 pop 損耗(模型 A) 兩件一起** → 一直打→anon 漸減→anon=0→無人晉升→`on_leader_death` 回 false→團崩潰滅團（event:54）= 真「打到死」。
  - **複用先例**：`force_occupy`(encounter:1424 `occ_dead = pop − pop×0.8`) 已有 20% pop 損耗機制，模型 A 可複用公式。
  - **分叉解剖（2026-06-19 #3，③ 已挖→證實）**：戰鬥**兩條路徑 explicit by design 分叉**（`ambush:60-66` 註明「Bug9：NPC 不走 encounter」）：
    - **encounter（戰術）**：觸發者 = `player_command_system` 全部 + `ambush` 玩家分支。spawn 上場 units、`kill_random` 只數上場（:1186-1194）。
    - **npc_combat（抽象）**：觸發者 = `interaction:248-260`（NPC 遭遇）、`faction_ai:2050`、`ambush:66`（NPC 分支）。`_apply_casualties`(:404)→`wound_random` 打**全 anon pool（無 cap 免疫）**、`_kill_named_npc`(:451)→`on_leader_death`(:456) **有 anon 晉升 fallback**。
    - **結論：兩病灶全在 encounter 路徑，NPC-vs-NPC 結構無病** → 解釋為何 multi sanity NPC 世界不崩、只玩測玩家介入才見 leaderless blob。**E-1 範圍大幅縮，不需碰 npc_combat。**
    - **繼承分叉真因鎖定**：`encounter_system:1184` 死 leader **只 `leader_id=-1`，從不叫 `on_leader_death`**；靠 `faction_ai:502` 補但 gate `named 非空` → named 全滅時不觸發 + `_promote_successor`(:1066) 無 anon fallback。對照 `npc_combat:456` 死 leader 直接叫 `on_leader_death` ✓。同樣死 leader，encounter 走殘缺路徑 = 分叉本體。
  - **owner 分屬（2026-06-19 #3 裁）**：
    - **繼承統一 = 系統 HOW**（單一真值源 seam）：立 `on_leader_death` 為繼承**單一 owner**，三入口（encounter:1184 / faction_ai:502 / npc_combat:456）全 route 進來、補 invariant。⚠ 合併須吸收 `_promote_successor` 的 **player heir 分支**(`_handle_player_leader_death`:1069，`on_leader_death` 現無)否則玩家死亡選繼承壞掉。行為不變（anon 晉升早在 on_leader_death），故非擴大願景。3 檔 + invariant → L2，需 spec/plan→worktree。
      - **✅ 繼承分叉已修（2026-06-19，spec `2026-06-19-leader-succession-single-source-design.md` + plan + `feat/leader-succession`）**：`on_leader_death` 成單一 owner（named 掃 named_members、無統領門檻、anon fallback、晉升後 check_overflow、player 分支內聚 + 冪等）；`faction_ai` 偵測 gate 由 `leader_id==-1 and named非空` 改為純 `leader_id==-1`（唯一偵測點，捕捉 encounter 裸置/饑荒/任意 leaderless）；刪 `_promote_successor`/`_handle_player_leader_death`，外部 caller（encounter `_check_player_wiped`、player_command stale-heir）改呼 public `EventSystem.handle_player_succession`；`get_player_team_id` 抽到 WorldState 單一源；順修 player 絕後經安全網 game_over 的 latent gap。**encounter 不碰**（死者 person 未 erase → 安全網次 tick 補位）。**結構免疫（殲滅模型 A）仍待藍圖 WHAT**，未在此 plan。
    - **結構免疫→「打到死」殲滅模型(模型 A pop 損耗) = 藍圖 WHAT 待決**：呈報藍圖（handback `systems-to-blueprint`）。
  - **spec 前剩小挖點**：① encounter 觸發/spawn 端（誰發起、為何反覆刷弱隊、spawn 時未上場 pop 怎記）② `ANON_UNIT_CAP` 值 ④ retreat/draw 是否常態結局（接 E-2，則連現有 pop 損耗都不觸發）。
- **E-2 AI 死戰到死**（中）。`_should_retreat`(encounter:322) 存在(殘廢率>0.7/torso critical/求生欲高30%機率) 但小隊(1單位)只在該單位倒下 ratio 才>0.7 → 等於戰到殘才逃,觀感死戰。小隊撤退門檻需調(絕對 HP/敵我懸殊判定,非只 ratio)。
- ✅ **E-3 玩家走到戰場邊無逃離**（已修，sim 驗 / UI 待 run-verify）。`_decide_action` 玩家 move 分支偵測 off-map target → 轉 retreat（既有 apply 在 `hex_dist>MAP_RADIUS` 設 `has_exited`）；encounter_view idle 邊界往外方向鍵 → `_do_exit`。sim 端 `_test_e3_player_edge_exit` 驗證離場機制；UI 鍵入 headless 不可測 → **待真人玩測**「邊界按往外方向 → 玩家離場、結算返世界」。**範圍**：只最小玩家角色離場（復用 has_exited/retreat apply）；「退場有代價」（追擊落跑傷兵）/全隊撤退 留藍圖衝突統一傘，未做。
- **U16-b 遭遇戰相機固定 ✅ 修（2026-06-17，待 run-verify）**。確認=**遭遇戰 tactical view**（非世界地圖;world map render headless 證實正確）。根因：`encounter_view.show_encounter:45` 相機固定置中 axial(0,0) **設一次永不更新** → 玩家單位偏離 (0,0) 時看不到自己、半邊出畫面（「x=0可視 x≤-1切」）。**修**：`_refresh_ui` 每次重置相機跟玩家單位 pos（`_camera = vp*0.5 - _hex_center(player_unit.pos)*_zoom`）。parse 綠、ui_logic 0。**GUI 視覺待玩家 run-verify**。
- **俘虜處置缺**（→ roadmap 中期）。capture/store(`prisoner_population`)✅,處置(賣/屠/招降/釋放/勞役)❌ 全沒 → 俘虜只增不用的死數字。

### P5 QA批（2026-06-16 QA session harness 系統遍歷，stage2 驗收抓）
> ui_flow 31/31 全綠但漏抓——測試只驗「能呼叫/字串含關鍵字」，不驗端到端守恆與主場景路徑。
- **B-1 收留撞 pop_cap** ✅ 已修（驗證 2026-06-19，移 `archive/resolved_issues.md`）。merge 前驗容量拒收 + cost 改 merge 後量 delta，無蒸發/msg 誠實；`_test_join_request_cap_capped` 覆蓋。
- **A-1 記名招募在主場景 TextUI 死路**（高，stage2 核心迴路斷）。`recruit` 回 payload menu(has_willing_named/anon_available)，但 `text_ui_main.gd` team-target handler（916-977）不消費此 menu，只 `_log_event` 後清 target。`recruit_named` 唯一路徑 `execute_action_with_target`（member-kind）text UI 從不呼 → 記名招募完全不可達。功能寫在停用的圖形 `main.gd`（show_recruit_panel:115-142）。`recruit_named` 不在 registry → `_test_action_ui_coverage` 抓不到。修向：把 recruit menu 消費搬進 text_ui_main。
- **C-1~C-6 ✅ 2026-06-16 brainstorm 重frame + 實作（merged 81e245b）**。走查發現原框架混淆「NPC task(AI 抽象)」與「玩家能力(直接動作)」——玩家直接控,不需持續 auto-task,真對稱=動作 parity（見 spec `2026-06-16-player-action-parity-design.md`）：
  - **C-1 設自隊 task → 砍掉**（玩家不要 auto-task,reframe 非缺口）。
  - **C-4 訓練/升 tier ✅ 做**（`_action_train` 一次性 coin→add_exp+try_promote;玩家版比 NPC 完整,NPC 無 promote tick caller=W4）。
  - **C-2 紮營 ✅ 做**（`_action_camp` Y版:免材料/無即時糧/距離spacing/限時施工）。
  - **C-3 覓食 ⏸ 擱置**（冗餘 hunt/hunt_beast,YAGNI）/ **C-5 pacify ⏸** / **C-6 settle ⏸**（niche/階段3 過早）/ **主動投靠 ⏸**（邊緣）。
  - **副產**：玩家主隊被恐慌橋寫 task=逃跑（latent,未實際劫持移動）→ 加守衛 ✅;「任務:」label→「狀態:」✅。
- **NPC crude_camp 即時糧 ✅ 量測+移除（2026-06-16）**：A/B（種子糧 ON vs OFF）2yr×4config → died 兩者皆 0、pop 相當（±噪音）→ 即時糧**非 load-bearing**（NPC 不靠它免死）。移除即時糧（`faction_ai:2105` 刪,保留抬 cap）恢復絕境稀缺,與玩家紮營版一致。

### Q7 QA批（2026-06-18 QA session harness 遍歷 + forced/encounter 動態驅動抓）→ **全 6 項 ✅ 修（2026-06-18）**
> 既有 37 harness 斷言全綠但漏抓——`_test_action_ui_coverage` A-baseline 只驗「靜態覆蓋圖存在」非端到端可走。動態驅動 forced-event/encounter 才現形。
> **✅ 修復**：Q7-1+Q7-2（forced-event 三聯單一源化 + choose_heir/aid_request，spec `2026-06-18-forced-event-single-source-design.md`，致命 softlock 解、雙重端到端驗）；Q7-3（戰利品文字 UI take_loot/leave_loot）；Q7-4（promote_anon 拔擢 anon→named，復用 generate_for_team，全 anon 隊可派子隊）；Q7-5（子隊派遣開放任務選擇）；Q7-6（faction 設定鈕 gate leader）。全 headless+ui_flow+multi 綠、coin_eq=0、invariant 0。
> **待議**：promote_anon 無 coin 成本（純拔擢，treasury 走 generate_for_team 內建守恆）；如要對玩家收費另議。

### Q8 QA 自檢批（2026-06-18 Q7 修後重掃，驗證 Q7 關閉 + 新落差）→ **N-1/N-2/N-3 全 ✅ 修（2026-06-18）**
> Q7-1~6 **六項全端到端驗證關閉**（含邊界）。新發現 3 項殘留已修：
> **✅ 修復**：N-1（子隊面板無 candidate 但有 anon 時引導去 promote_anon，補 Q7-4 發現性）；N-2（choose_heir 重查活候選不吃 stale 快照,單一 stale→重選,全死→`_handle_player_leader_death` 終局,修永久 leaderless;N-2 用 `fe.team_id` 解隊因 player_id 指向死 leader）；N-3（camp/train available_actions 補真 gate:camp `_check_distance`、train coin>=TRAIN_COST_COIN,gate 通過仍可達）。全 headless+ui_flow+multi 綠、coin_eq=0、invariant 0。
- **N-1 全 anon 隊子隊面板死路不引導 promote_anon**（中，A/B）。`_build_subteam_str`(text_ui_main:1683) 顯「（無：需命名非 leader 成員）」但不交叉引導去互動選單「拔擢匿名→記名」(Q7-4 的 promote_anon)。功能可達但發現性差 → Q7-4 半殘。修向：subteam 面板死路時提示「先拔擢匿名成員」或直接內嵌入口。
- **N-2 choose_heir 候選 raise→select 窗內死亡 → 隊永久 leaderless**（低，B）。`respond_to_forced`(player_command:918) 對 stale heir 失敗仍無條件清 forced、不重 raise；`get_forced_response_options` 讀 `forced.candidates` 快照非重查活 named（responses 以 fallback 名列死者）。非 softlock（forced 有清）。修向：respond 對 stale heir 失敗時重查活 named 重 raise，或 game_over。
- **N-3 camp/train 恆列即使 command 會拒**（低，B 顯示）。`_build_available_actions`(player_query_api:445/454) 只查粗 gate(anon>0)，未查 coin/`_check_distance`；camp label 未標成本門檻。選後才 reject。屬 gate-display 類（部分已知 Q7-6 同類）。

### 🆕 vision-dist 測試 FAIL（pre-existing，Q7 work 期間確認）
- `ui_logic_test.gd` 有 2 個 `team0 看不到 team1/team2 (dist=1/2)` FAIL，**Q7 前 main 即存在**（非新引入）。屬視野/距離可見性測試與實作不符——待查 VisionSystem 門檻 vs 測試期望（或測試過時）。低優先（不影響主流程,headless/ui_flow/multi 全綠）。
- **Q7-1 `choose_heir` 無選繼承人 UI → forced_event 永不清 → 世界永凍**（🔴 致命 softlock）。玩家 leader 餓死/戰死（`faction_ai:1058`/`health_system:221` 真觸發）→ `_process` 進互動模式 → `forced_interaction.responses` 只有「拒絕」（候選人沒出現）→ 按下 `resolve_forced_response` 驗 `get_forced_response_options(choose_heir)` 回 `[]` → `invalid response_id` → forced_event 不清。且 `sim_runner:99-100` 明確把 choose_heir 排除超時自動清除（設計凍世界）→ **玩家永遠選不了繼承人,世界永凍**。根因：`PlayerApiMapper.map_forced_interaction()`(player_api_mapper.gd:266) `match action` 無 choose_heir 分支→落 `_` fallback 只給拒絕；`get_forced_response_options()`(player_command_system.gd:834)+`respond_to_forced()`(:849) 也無 choose_heir（它走獨立 `_action_choose_heir` 需 `player_state["heir_id"]`,但 UI 無路徑設 heir_id/列候選）。
- **Q7-2 NPC 乞食玩家(`aid_request`) 無「給予」UI → 玩家只能(超時)拒**（高,破對稱）。注入 `aid_request` forced(`interaction_system:836` NPC 對玩家乞食真觸發)→ responses 只「拒絕」→ 按下同 `invalid response_id`→`sim_runner:102` 一 tick 後超時視同拒。`respond_aid_request` 是 registered action(含 give_amount/守恆/reputation 全套) 卻**無 UI 觸達**。根因同 Q7-1（三聯缺 aid_request 分支）。**Q7-1+Q7-2 同源,可一 plan 修。**
- **Q7-3 文字 UI 戰勝無 `take_loot` 路徑 → 戰利品憑空丟棄**（中高,A+B）。玩家贏遭遇戰→`encounter_system:1301` 算 loot_pool 存 last_encounter_result。戰後 `encounter_view._post_combat_hint:569` 只 `[J]收編`,無 take_loot/leave_loot（encounter_view grep 0 命中）。功能只圖形 `main.gd:184` 接線→文字 UI(主測 UI) 打贏拿不到戰利品。
- **Q7-4 玩家無「升 anon→named」command;全 anon 隊無法派子隊**（中,C 對稱）。NPC `person_generator:46`/`faction_ai:389` 缺 named 時自動拔擢 1 anon 為 named leader(帶 treasury×3);玩家無對應。`_action_dispatch_subteam`(player_command:531) 硬要 `sub_leader_id ∈ persons`→全 anon 隊 `dispatch_candidates` 空→`「無可用隊長」`。
- **Q7-5 子隊派遣/下令 UI 寫死 `TASK_IDLE`**（低,A）。`dispatch_subteam` command 支援任意 sub_task,但 UI(text_ui_main:1534,1589) 只給 IDLE→玩家只能派「移動」子隊。
- **Q7-6 faction 面板對非 leader 顯示設定鈕但 command 拒**（低,B 誤導非 crash）。`_build_faction_str`(text_ui_main:1282) 對所有成員列 `[A]設定目標 [B]徵收率`,但 command 要 leader→非 leader 按了 reject。
- **OK 項（非落差）**：37 harness 斷言全過;hunt/train/camp/recruit_named/equip/trade/storage/outpost/extract happy-path 觸達+state 變正確;互動分頁索引一致;對稱已 OK:beg/camp/build_outpost/train/recruit。

### W4. Faction leader 行為性貧窮 — 建造解鎖極慢 ⚠ 部分修（2026-06-13 economy-bootstrap）
- **症狀**：2 年 multi 派建造子隊 = 0；失敗原因 log（本批新增）顯示全是 material < cost×1.5（leader material +0.2/day 涓滴，門檻 75 要爬數年）
- **根因**：leader team 常駐外面（迎戰/乞食/逃跑），不在 outpost tile → collect 收入 0；material 只靠稅/貿易涓滴
- **修（部分）**：faction leader 補「治理」回家路徑（公庫<75 + 不在家 + idle → 回家攢公庫）；自給階梯讓無 tools faction 先蓋民村→工坊→產 tools→後期軍鎮
- **驗證**：2 年設施完工 2→4（merchant 自然長出 workshop）；但限**常駐型 leader**（merchant）有效
- **遺留**：遊牧軍閥 leader（tyrant/warzone 好戰高）永遠在外迎戰，從不 idle 在家 → 治理觸發不到、建造仍 0。需 leader 駐留行為 spec（強制週期回防/或建造資金走 faction 共同出資）才能根治

### Bug2. salary 拖 coin 無下限
- **症狀**：integration test merchant min_coin=-49 / warzone min_coin=-42（90 天）
- **根因**：salary 系統發薪前不檢查 coin >= 0；新團 `[Split]` 出來特別易負
- **影響**：經濟守恆破，新生團體永久赤字
- **發現**：2026-06-09 integration test
- **驗證（2026-06-15）**：**floor 已修**——`salary_system:65/75` 已 `maxf(coin−paid, 0.0)` → coin 不再為負。
- **驗證（2026-06-16，原「欠薪後果未做」= stale）**：欠薪後果鏈**其實已有**——減薪→掉忠誠（`salary_system:73` `loyalty -= (1-ratio) × SALARY_LOYALTY_PENALTY`）→ 低忠誠/高壓觸發 reaction `N3_defect`(`:259`)→`_anon_actually_left`(`:269`) 真離隊。**功能完整**。剩「anon 補充停」屬邊緣低優先（budget_ratio<1 時 anon 薪自然少，已部分反映）。
- **狀態**：負 coin ✅；欠薪後果鏈 ✅（已存在,非缺）；anon 補充停 = 低優先邊緣 tune

---

## 🟠 中優先（影響遊戲合理性）

### S4. 人口分裂太快
- **症狀**：main.gd 開局 3 team，tick 10 開始自動分裂，tick 30 已有 10+ team
- **根因**：PopMgmt 分裂條件觸發太容易；10 人就能分裂出子隊
- **位置**：`scripts/simulation/population_system.gd`
- **勘誤（2026-06-15）**：描述過時。現 population_system 無「pop10 分裂」,改 **overflow-based**(`check_overflow`/`_create_overflow_team`,超 cap 才溢出建團)。且症狀指 graphical `main.gd` 開局 = **moot**(TextUI 為 `main_scene`)。如仍嫌溢出太快屬另議 tune。

### S5. main.gd test setup 無 outpost → 12.5 天必定斷糧
- **症狀**：300 food / (10人×0.1/tick×24tick/天) = 12.5 天；斷糧後人口死亡，UI 失效
- **根因**：`collect_resources` 只採 outpost 格，test setup 沒建 outpost
- **位置**：`scripts/ui/main.gd`（test setup）
- **建議**：加初始 outpost，或大幅增加初始食物（如 10000）
- **勘誤（2026-06-13）**：症狀數字（0.1/tick×24）為 2026-05 舊 prototype 行為；現行 burn 為 `FOOD_PER_PERSON_PER_DAY=2.4`/人/天，斷糧後的人口死亡鏈已由 2026-06-13 famine-death spec 補實（團級 famine_days minor/anon 耗損 + named hunger→blood 餓死，grace 7 天）。

### U4. 地圖移動後有時消失
- **症狀**：移動幾次後地圖變黑、旗子消失
- **根因**：player person 因食物不足死亡 → `player_tid=-1` → `discovered=[]` → 地圖全黑
- **連動**：S5（食物）是主因；player 無死亡保護是次因
- **勘誤（2026-06-13）**：「player 無死亡保護」為 2026-05 舊 prototype 行為；現行 famine-death spec 下，玩家 leader 餓死（blood=0）走既有 `_handle_player_leader_death` → `choose_heir` forced event（凍結世界等選繼承人），非靜默 `player_tid=-1`。地圖全黑殘留問題如仍存在屬 UI 層獨立議題。

### U5. 右側欄資訊不完整
- **缺少**：玩家 HP（body_parts 狀態）、attributes/values、skills
- **缺少**：team 完整資源列表（只顯示部分 key）
- **缺少**：faction 狀態（隸屬、等級）
- **位置**：`scripts/ui/right_sidebar.gd`

### U6. 圖塊資訊只有地形
- **缺少**：tile.resources（food/material/ore 庫存量）
- **缺少**：地形速度減益係數（plains 1.0 / forest 0.7 / mountain 0.4）
- **缺少**：outpost 類型/等級/擁有者
- **缺少**：harvest_factor（農業效率）
- **位置**：`scripts/ui/bottom_bar.gd:show_tile_info`

### Bug8. _test_on_team_extinct_to_storage 失敗 = stale test（非碼 bug）
- **症狀**：headless `food 應進公庫` assert 失敗
- **驗證（2026-06-15）**：**非碼 bug,是測試過時**。W6 重構後 `_on_team_extinct` 只標記 `teams_pending_erase`,實際路由延到 `cleanup_extinct_teams → _route_extinct_assets`(邏輯正確,進公庫)。測試只呼 `_on_team_extinct` 沒呼 `cleanup_extinct_teams` → 路由沒跑 → assert 失敗。
- **修**：測試加呼 `fai.cleanup_extinct_teams(state)` 再斷言。assert 值(50 food/30 coin)正確,「勿動」誤解除——值對,只缺呼全路徑。無守恆風險。

### U19. 強制事件無選單 → 卡死（H, blocker, 2026-06-14 run-verify 新發現）
- **症狀**：強制事件（乞食/繼承/勒索回應等）觸發但畫面無選單，一直卡（choose_heir 還凍世界）
- **根因**：`text_ui_main._process`（154-160）pre_encounter/encounter_active 有自動進模式，**一般 `forced_interaction` 無對等自動進選單** → 只顯「⚠強制事件」hint，玩家無從回應
- **修向**：`_process` 偵測 `forced_interaction` 非空 → `cancel_advance` + 進 forced-response 模式（仿 pre_encounter）；新 `_forced_mode` + handler 列 `forced_interaction.responses` 供選

### U10b. 全 Team 死亡直接退出（edge，2026-06-14 run-verify）
- **症狀**：遭遇戰中玩家全隊死亡 → 直接退出（應走 game-over / choose_heir）
- **修向**：encounter 結算偵測玩家隊全滅 → 接 `_handle_player_leader_death`/game-over，非靜默退出。低頻 edge

### U11b. 戰報 label 未顯（U11 修了但 GUI 沒出，run-verify）
- **症狀**：`_lbl_log` 戰報已加+wire（query_encounter_log）但玩家戰鬥沒看到
- **疑因**：encounter_log 玩家戰鬥未填 / facade 回空 / label 被佈局擠出。需 GUI 查
### U12b. 交易仍跳無資源（U12 direct preview 修沒對症，run-verify）
- **症狀**：互動→交易仍誤判。direct preview 加了但 text_ui trade 流可能仍走舊 path
### U13b. 裝備穿脫僅玩家，NPC named 成員無入口（run-verify）
- **修向**：member 面板加成員 equip/unequip（equip_item slot 已支援,需 member-target UI）
### U14b. 主畫面看不到自 team 武裝數（U14 reframe + U18，run-verify）
- **症狀**：玩家想在平時 UI 看自隊武裝 anon 數,非進場後。併 U18（武裝 anon 指令）+ status 顯 armed 數

### U18. 玩家無法武裝 anon（UI/指令皆缺）
- **症狀**：找不到 UI 武裝匿名兵
- **根因**：`armed_anon_ratio`/`equip_order` 由 `faction_ai` 為 NPC 自動設，**玩家無指令**（grep `player_command_system` 空）→ UI 自然無入口。同 S9 調薪類缺口
- **修向**：補 `player_command_system` 設 armed_anon_ratio/equip_order 指令 → 再上 UI。屬 P3 全動作覆蓋前置（sim 側缺口）
- **優先**：M

### U9. 圖形 Main.tscn UI 仍 reach-through raw WorldState（邊界債）
- **症狀**：`main.gd`/`encounter_view.gd`/`popup_layer.gd`/`debug_bar.gd` 大量 `_bridge.get_state()` 直讀 raw `WorldState`（body_parts/units/world.current_tick）→ 違反「UI 只經 player API」invariant（2026-06-14 新增）
- **狀態**：text_ui 已清（P1）；圖形 UI 未清。text-UI-only 階段不影響
- **優先**：M — 若推圖形 UI 或全面套 UI 邊界 invariant 才需解耦（範圍大,涉 encounter tactical view）。另案

### W8. coin 鑄造實機罕見 — 鑄幣**機制 ✅ 已存在且守恆**，缺實機觸發（2026-06-19 G1a 更正）
- **機制 ✅（G1a 驗證）**：鑄幣鏈**完整且守恆**——world_gen 放金銀礦 → resource harvest 進 `public_storage` → `OutpostSystem._tick_mint` ore→coin（`GOLD_TO_COIN_RATIO=20`/`SILVER_TO_COIN_RATIO=5`）→ `tick_all` 已 wired。`_test_mint_conserving`（headless）證 coin_eq delta=0。**非機制 bug**。
- **先前誤判更正**：原「coin 鑄造Δ=0 = 產出鏈完全休眠」≈ **無觀測 log 致錯覺** + 實機建造罕見。`_tick_mint` 現已加 `[Mint] tile(x,y) ore→coin +N` log（觀測藍圖 §12「coin 被鑄 Δ>0」）。
- **殘留（屬經濟平衡, 非機制）**：實機 NPC 罕採金銀 ore / 罕蓋鑄幣廠 → coin 生成稀 → 經濟偏零和集中（贏家集中、窮團翻身路弱）。此為**建造/經濟平衡**問題，另案。
- **不破壞**：減薪=0、無死、世界穩（coin 對生存非必要,團跑 lean 仍活）。
- **修向**：實機鑄幣頻率 = 平衡 / **G1c 需求驅動生產**接上後再觀察（需求迴路驅動蓋鑄幣廠 + 採礦）。屬經濟深度玩法層。
- **優先**：M（機制已綠；頻率待 G1c 後量測）。

### W7. 覓食 vs 乞食 仲裁（forage-foundation 遺留）
- **症狀**：`_find_forage_tile` 周圍無食物時仍回本格 → 小隊（pop≤15）恆覓食、不到乞食 Path4。枯竭區小隊空覓而非乞食富鄰
- **狀態**：2 年 multi 實測世界穩定（died=no、未顯退化）→ **暫不動，留量測**。主 session 曾試加 `best_food` 門檻使無食物回 -1,-1，但會弄紅 3 個依賴「urgent→SURVIVAL_TASK」的 baseline 測試（那些測試 setup 無食物 tile）→ 還原。要修需同步重整那批測試語意
- **優先**：L — 量測顯問題再開

---

### Bug5. DiplomacyAI demand_tribute 恆負
- **症狀**：90 天 120 次 evaluation，分數恆 −0.15（power_r=0.40, caution=0.80, pride=0.50）
- **根因**：caution=0.80 權重壓制 score 恆 < 0；同一決策每次重算同值
- **影響**：強者不勒索，AI 過保守
- **發現**：2026-06-09 integration test
- **結案（2026-06-15 量測）：非缺陷,原症狀誤判。** 經 warzone 整場量測:
  - **NPC demand_tribute 發起 = 0 次**。收方公式(`:129` `d_score=(power_r−1)×0.4 + caution×0.3 − pride×0.3`)其實**正確**——拒絕弱者勒索合理。舊「score 恆 −0.15 過保守」= 把正確的收方行為當 bug(−0.15 正是 power_r=0.4 弱者來勒索的應拒值)。
  - 真實狀態:**NPC 勒索機制休眠**。唯一發起點 `try_proactive_diplomacy:68` 被三重掐死:早 return(score>0.6 結盟/>0.4 貿易先返)、U20 同格 gate、**方向反**(`power_gap>0.5`=other 較大才發 → 弱勒強 → 必拒)。
  - **不破壞任何東西**(世界穩),屬休眠機制非 defect → **關閉**。要活化 NPC 勒索 = 設計題,見路線圖。

### W3. BREAKOUT_DIST / ENCIRCLE_DIST tune
- **症狀**：常數調為 2/1 適配 radius 4 測試地圖；正式地圖 radius 可能不同
- **發現**：2026-06-10 NPC wakeup
- **建議**：改 `min(N, map_radius)` 動態計算

### W4. NPC 不主動 promote / train ⚠ 部分修（2026-06-16）
- **症狀**：multi 90 天 tier promotion = 0；戰場升等 0（因 0 combat），訓練 task 0 派
- **根因（兩層）**：(1) **promote tick caller 缺**——`training_system` 只 `add_exp` 從不 `try_promote` → 即使 TASK_TRAIN 累積 exp 也永不升階;(2) NPC AI 鮮少選 TASK_TRAIN。
- **修（2026-06-16，層1）✅**：`training_system.process` 補 `try_promote`（count=1 迴圈升到不能升）。headless `W4 NPC 訓練升階 OK`、warzone sanity 世界穩。**機制活化:NPC 一旦訓練即會升階**。
- **遺留（層2）**：NPC AI 決策仍鮮少選 TASK_TRAIN（faction_ai 無 promote/train 評估邏輯）→ 實戰升階量仍低。要常態升階需 faction_ai 加 leader 個性 + 物資自動評估 train。低-中優先，接戰場 exp（W1）成熟後一起 tune。

## 🟡 低優先（體驗問題，不影響可玩性）

### U7. Camera 每 tick 強制回正
- **症狀**：每次推進 tick，鏡頭自動對齊玩家，無法保持手動視角
- **根因**：`refresh()` 每次呼叫 `_center_on_player()`
- **建議**：改為只在玩家移動時重置，或加 C 鍵手動回正

### U8. Members/History popup 待確認
- **症狀**：按成員按鈕可能不顯示 popup（已加 print debug，尚未確認）
- **位置**：`scripts/ui/popup_layer.gd`

### D1. SoloAI 保護條件脆弱 ⚠ 部分緩解（2026-06-15 驗證）
- **症狀**：`team.leader_id == state.player_id` 在子隊分裂後可能失效
- **根因**：subteam 分裂可能重新指定 leader_id
- **位置**：`scripts/simulation/faction_ai_system.gd:_evaluate_solo`
- **驗證（2026-06-15）**：部分點已加 `named_members` fallback(`:1049` `leader_id==player_id or player_id in named_members`)+ player_id≠−1 守衛(`:141`)。但 `_evaluate_solo`(`:907`) 仍只查 leader_id → 邊緣仍脆。低優先。

### A1. agent_repl stdin 模式 stdout 污染
- **症狀**：stdin 模式下模擬 `print()` 混入 JSON Lines stdout，污染協定
- **根因**：GDScript `print()` 寫入 stdout；stdin REPL 與模擬 print 共用同一 fd
- **影響範圍**：僅限 stdin 模式（Windows headless 走 TCP fallback，實際不受影響）
- **位置**：`scripts/debug/agent_repl.gd:_run_stdin_loop`
- **建議**：加 `--quiet` flag suppress 模擬 print，或在 stdin loop 前重導向 print 到 stderr

### S9. 玩家 team 名 NPC 薪資 UI
- **症狀**：玩家無法調整 named NPC 薪水，預設 0 → 自然扣 loyalty 直到叛逃
- **設計意圖**：玩家管理 loyalty 的關鍵手段（過薪換忠誠）
- **建議**：team panel 加每個 named NPC 薪資設定，顯示「目前 / 公平」比值

---

## Movement

- **mounts/wagons 速度**：⚠ 部分修（2026-06-15 驗證）。`_compute_team_speed`(`movement:138`) 現已 `× _compute_mount_bonus(team) × _compute_wagon_penalty(team)` → mount 加速、wagon 拖速**已有**。
  - **遺留**：speed_class（步兵/騎兵/輜重分類）仍缺——同隊內騎/步未分速,只算隊級平均 bonus。完整 unit-level speed_class 待 spec。
  - **發現**：2026-06-10 combat-engagement；2026-06-15 驗證 mount/wagon bonus 已實作

## 待 spec（按優先排序）

| 優先 | spec | 解的問題 |
|---|---|---|
| **H** | NPC 會合/攔截 | W1 + W2（0 Combat / 0 Trade）|
| **M** | mount 公庫系統 | mounts 改為 outpost public_storage（採集 / stable 產出 → 公庫，team 出征前 withdraw）；同時加 outpost 鄰格 wild_horses 自動採集 |
| **M** | 設施改制 B 期（材料層）| herb / 野馬群 圖塊資源 + 戰馬/野馬分離（民用馬廄馴野馬、軍用馬廄練戰馬）+ wagons 合成（野馬+mat+tools）+ medicine 配方接 herb。依賴 A 期 spec：2026-06-12-facility-overhaul |
| **L** | 信用貨幣（勢力券）| 各勢力自行發行、互不承認；coin 維持硬通貨總量固定。等 slot 專業化讓貿易量起來（C 期驗證）後再做。敘事接點：金銀挖完 → coin 通縮 → 勢力發券的歷史動機 |
| **L** | 新礦發現事件 | 低頻事件：tile 探出新礦脈（每脈有限量）— 後期擴張動機 + 淘金熱戰爭誘因，不破壞稀缺性 |
| **L** | 裝備回收鏈 | 戰損裝備 → 廢鐵 → 折損重煉（80%）。只在未來引入「銷毀事件」時才需要（守恆審計後現無銷毀）|
| **L** | goods 消費 sink | goods 目前純財富品無功能消耗；後續可加奢侈品 → named loyalty/滿足加成 |
| **L** | 子隊居民團 leader 留/回個性評估 + 合併 | outpost-residency-ai (ii) → (iii) 升級：流民駐紮後子隊 leader 個性決定留下（合併或共處）或回母團 |
| **L** | Residency dispatch print spam | NPC AI 派子隊到 outpost 後 sub pathing 失敗 / 母團 mobile，子隊未 settle → outpost 仍 missing resident → cadence 重派；in-flight check 在 sub task 被改 idle 時失效。invariant 過，但 print 多 |
| **M** | 人口循環受窮困抑制 | minor 長大簡版已實作（每月 10% → 平民，2026-06-12）。但 multi 90 天 0 次長大：reaction 收斂後世界窮 → P5 生育的糧食盈餘條件（>7 天份）幾乎無人達標 → 無小孩可長大。需 harvest/初始糧 tune 讓富裕村能生。完整人口結構 spec（性別/生育年齡）仍待 |
| **M** | task 優先權仲裁（Spec A）| current_task 被 5+ 系統互蓋（reaction bridge / faction goals / strategic dispatch / threat / survival），白名單散落。設計已討論（優先表 100 戰鬥/80 存亡/70 威脅/60 玩家/50 派遣/30 勢力/10 閒置 + 每層釋放條件），待 reaction 收斂後實作 |
| **M** | trade 三層問題殘餘 | TASK_TRADE 加入 faction_ai:660 exclusion（1 行）；trade partner 改限「tile 上有居民團」；DiplomacyAI reject cooldown；Equip print diff check |
| **M** | unrest / 抗命 玩家可見性 | unrest 完全沒露出 player API/UI。自家 team → team_stats 加欄位；同 faction → intel unrest_est；外人 → 躁動傳聞 message。[抗命] 事件玩家通知。等 UI batch |
| **L** | NPC 對 NPC 抗命 | arbiter 抗命窗口只開「50 挑戰玩家 60」；NPC leader 對 NPC 上級命令的抗命（50 vs 50 個性判定）後續另議 |
| **M** | encounter-engagement 後續 | 攔截方反追（prey 預測 attacker）；戰報廣播；玩家版反應 UI |
| **H** | salary 欠薪後果 | Bug2 |
| **M** | NPC promote/train AI | W4 |
| **M** | DiplomacyAI 平衡 | Bug5 |
| **M** | multi runner schedule 注入 | Bug6 |
| **M** | 戰場 mount unit-level | encounter 騎兵 unit + 衝擊 + 機動 + 戰場死亡（mounts/wagons spec 後續）|
| **L** | mount 細分 | 戰馬/馱馬/拉車馬；輕車/重車；草地補糧；城市買飼料 |
| **M** | named 升階機制 | anon tier spec 列後續 |
| **L** | tag drift | leader / event 改 tag |
| **M** | 團 vs 團突襲優勢 | 對稱：野獸伏擊已實作（AmbushSystem，2b-2）；團對團伏擊待做 — reuse `vision_system` 偵測（潛行降 exposure / 偵查偵測）+ 攻擊方未被偵測 → 首擊/陣位優勢 + 激活 dormant `_check_night_raid`。屬階段2+ 劫掠/戰團。**注意：團伏擊用 vision 偵測，非 beast 專屬 AmbushSystem** |
| **M** | AI 目標錨（策略延續②深層） | SoloAI 承諾慣性（solo_intent 加成，spec soloai-proactive-home）止短期 flip-flop；更深的「持久 goal 錨」（隊有慢變長期目標如稱霸/安身/致富，task 選擇朝 goal-aligned 跨多 tick）= 接 dormant `npc_ai.get_goal_task_override`。**先量測承諾慣性夠不夠再做**。**極克制 — 一個慢變 goal 欄位+偏好加成，非多層規劃器**（防戰略引擎無底洞） |
| **M** | 山村採礦換糧特化經濟 | 山地 food regen 低（種田餵不飽），真實山村靠採礦/畜牧→交易換糧（進口糧）。現食物模型只「收本地糧」→ 山村必餓。需缺糧村自動 trade ore→food / 進口糧 AI。階段3+ 經濟深度。現階段 explicit 村用 `outpost.terrain` 釘可農地規避 |
| **L** | 戰俘處置 | 賣/屠/招降 |
| **L** | 外交招募 / 雇傭軍 | 直接買高 tier anon |
| **L** | anon tier UI | team panel / 升等進度 / 死亡分檔 |

---

## 🟡 代碼健康批（2026-06-18 研究 session 審計，非阻塞·維護性債）

> 不變量架構（cohort/faction/subteam/erase）已乾淨。以下為**重複值 / smells / 缺抽象**，改一處其他 drift 的風險。

### 重複值 / magic numbers
- **[高] `FOOD_PER_PERSON_PER_DAY = 2.4` 獨立定義 3 份**：`resource_system.gd:3`(權威) / `player_api_mapper.gd:156` / `faction_ai_system.gd:45`(`_SURVIVAL` 名同值)。部分點正確引用 `ResourceSystem.FOOD_PER_PERSON_PER_DAY`,部分用本地副本 → silent drift 炸彈。修：留一份,其餘改引用,刪副本。
- **[高] tier 字串「平民/新兵/老兵/菁英」全專案硬編碼**,不引用 `AnonTierSystem.TIER_ORDER`：encounter:1250 / player_command:190,198 / training:22 / beast:32 / population:21 / recruit_tutorial:22 / game_setup:340。修：非迴圈處用 `TIER_ORDER[0]/[-1]` 具名索引或加 `TIER_PLEB/TIER_ELITE` const。
- **[高] `TIER_ORDER` 兩處各一份**：`anon_tier_system.gd:7` 與 `anon_cohort.gd:6` 內容相同。修：擇一為源(建議 AnonCohort 更底層),另引用。
- **[中] task 字串「安頓/安撫/乞食/投靠/return_home」無 TASK_* const**：team_data.gd:3-22 有 TASK_* 塊但缺這幾個;散落 interaction:264-290 / faction_ai 多處 / `SURVIVAL_TASKS`(faction_ai:30) 混用 const 與字面。85 處用常數 vs 33 處裸字串 → typo 即 silent false。修：補進 TASK_* 全改引用。
- **[中] `VISION_RADIUS = 3` 三處副本**：vision_system:3 / text_map_renderer:4(註解「與 X 一致」自承耦合) / encounter_view:501。修：UI 引用 sim const。

### smells
- **[高] dead const `TRAINING_CAP_THRESHOLDS`**(anon_tier_system:34-38) 零引用 + `_training_cap`(:232) 硬編碼同 0.4/0.7 門檻。修：刪 dead 或讓 `_training_cap` 讀它(二選一)。
- **[中] 超長函數**：encounter_system `resolve_encounter_end`(186行)/`_decide_action`(150) / interaction `_try_interact`(132) / faction_ai `_trigger_survival`(106)。按分支抽 helper。
- **[低] `resources.get(key,0)` 樣板 99 處(17 檔)**,預設值有的 `0` 有的 `0.0`(型別不一)。可加 `ResourceSystem.get_res(team,key)->float` 統一。

### 架構
- **[中] 資源鍵無單一權威清單**：team_data:52-59 default dict 是唯一全鍵源;weapon/armor 鍵(跨 21 檔 51 處) 無集中枚舉。新增資源得手動同步多處。修：建 `ResourceKeys` 常數模組(PUBLIC/WEAPON/ARMOR 子集)。
- **[中] UI↔Sim 常數靠註解耦合**(見 VISION_RADIUS)：靠「人記得改兩邊」。修：UI 引用 sim const。

**前 3 優先**：① FOOD const 收斂 ② 補 TASK_* 全引用 ③ 刪 TRAINING_CAP dead + tier 字串具名化。

---

## 待討論（設計決策）

| 問題 | 選項 A | 選項 B |
|---|---|---|
| S1 視野門檻 | 降至 0.3（保留距離衰減） | 移除衰減，範圍內直接可見 |
| U7 Camera | 每次 tick 回正 | C 鍵手動回正 |
| D2 player 死亡 | Game Over 畫面 | 自動轉移到新角色 |
| S4 人口分裂 | 提高門檻 | demo 期間停用 |

