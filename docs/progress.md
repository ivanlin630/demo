# 開發進度

## 🗺 進度快照 dashboard（藍圖 2026-07-02，視覺總覽；細節見下方系統 log）

```
【沙盒三維度 = 遊戲活起來沒】
  經濟  ████████▓░  戲成 ✓  交易網轉、商隊想致富真去貿易
  征服  ██████░░░░  差一哩  機制到 route×6.6，差 capture 完成
  資訊  ███░░░░░░░  地基好  Phase E done、Phase D 欺敵(玩家錨C) queued

【統一矩陣 burn-down】
  思考決策 ████████▓░ 85%  ★旗艦燒完→致富/征服錨活、交易轉
  單寫者   ███▓░░░░░░ 35%  coin/ledger/roster/leader done；剩 8/12(強制閘前提)
  belief   ████░░░░░░ 40%  Phase E；剩 known_states/audit
  互動     ██░░░░░░░░ 20%  BEG/JOIN 驗死待修；剩多 resolver 統一
  人力俘虜 ██░░░░░░░░ 20%  失能-capture；剩雙模型/prisoner 死路
  玩家面   ▓░░░░░░░░░  5%  幾乎未動(大 arc)
  強制閘   ▓░░░░░░░░░ 起步  ledger 有牙；待單寫者撐

【方法論/願景 定型 ✓】沙盒 bar｜AI 深度節流閥｜兩隻眼(measure+矩陣)｜3 不變量
【NOW】GUI 用戶親驗 ‖ 強制閘全立 ‖ 矩陣剩餘(人力/belief)  【queued】envoy 弧殘/cadence 殘餘/G3-D/玩家面
```

## 📍 當前狀態（2026-07-01）

- **🧠 憲法 arc 序7 reaction 溶入 ✅（feat/reaction，2026-07-06）**：audit 標「最大最難」，★measure reframe=**其實小**。坐實：9 反應 apply 幾乎全 state-effect（情緒/loyalty/unrest/food/coin/離隊/生育/memory 後果），**唯一行為選擇=聚合 panic-flee bridge**（`reaction_system.gd:48-60` 手算 try_set TASK_FLEE）。∴ 序7=拆 1 bridge + 保 9 反應為 consequence scaffolding。**溶**：ctx 加 `team_panic`（高 stress 低 loyalty named 成員/pop 聚合=決策模型情緒腳首接線）→ `threat_pressure` term 疊 `team_panic × PANIC_WEIGHT(0.5)` → 引擎 survival option FLEE 自然勝（潰散壓過 leader 勇氣，非旁路 try_set）。★FLEE 三源序保（真絕境 survival 80 > panic 70，PANIC_WEIGHT max 0.5 << survival 絕境量級 12=不喧賓奪主）。個體反應 apply 全不動。自建 `reaction_dissolution_check.gd`（4 段 ALL PASS）；gate removed evaluate_all（reaction_system 零 TaskArbiter 面）；framework 7-0、全融合驗綠、seeded 49/8/1/381 零漂移。bridge seeded fire=0（dormant）→撤除零影響。**B 債**：PANIC_WEIGHT 全域 const 待人格化。**backlog**：memory 腳仍 dormant（DecisionContext 不讀 person.memory=決策模型 gap）、反應觀測空白。handback `2026-07-06-wave1-reaction-dissolution`。
- **⏱ 時間統一 wave 進行中（2026-07-05）**：時間=統一矩陣漏的維度（~80 常數散 21 檔硬編）。藍圖 5 錨定：①移動 240tick/hex=1天(BASE_ACTION×遭遇尺度,×5拿掉)②遭遇尺度24③cadence 決策層級語意化④後勤走一格帳 measure⑤觀看組不動。**目標規模=~50 隊**（LOD perf 量測揭:LOD 只 3× 常數/真根 O(N²) faction AI 忽略 subset/41隊已137tps+1s hitch/107隊全垮→A必修=空間分區+honor-LOD+cadence攤）。
  - **✅ slice A1（feat/timescale-skeleton，merged + 拆片 reconcile）**：新 `time_scale.gd` 單源類（承既有根,單向 TimeScale→{WorldState,Encounter}）+ `MOVE_TICKS_PER_HEX = BASE_ACTION×MAP_SCALE/WORLD_SPEED_MULT(5) = 48` 連動 + 3 時間不變量入 invariants。**★A 拆 A1/A2（藍圖 five-rulings 防餓死潮）**：實作原含 ×5→1(=240)已 merged，藍圖後裁「×5→1 須綁 ④補給+FOOD重校+gen 四件一 landing」→ **系統 reconcile 恢復 ×5(MOVE 48)=A1 零行為**（seeded final 回 47/8/1/380 鐵證零擾）、×5→1 推 A2。headless DONE/time assert(MOVE=48)/framework 7-0/coin_eq 0。
  - **平行 measure done（夜班）**：三病共根=**far-zone 移速稀釋(B)一修多解**(V1 trade+V4 envoy+V3 帶禮結盟);④後勤×1>10格斷糧真帳;V3(b)直解結盟0.55恆false+V2-cmd結構shadow=判準題。全入 known_issues,報藍圖 `parallel-measures`。
  - **✅ B far elapsed（feat/far-elapsed-movement，merged）**：movement process 收 elapsed_ticks(near=NEAR_CADENCE/far=FAR_ZONE_INTERVAL)+多格迴圈保餘數→修 far 10× 稀釋。**一修多解 confirmed**：V1 trade arrive 3→21/deal 16→42/矛盾率0.758→0.605、V4 envoy delivered 大漲(seed42 4→32)、V3 帶禮 accept 0→1。不塌房(pop 反升)、perf +28%(far 真做 path)無新 spike。headless DONE/framework 7-0/確定性守。**seeded 值變=B 預期→post-B baseline=46/8/1/380**(headless reproducible 自比確定性,無 hardcode 值改;seeded_warring_bed=on-demand diff 非 auto-gate)。殘因(正交移速,非本 slice)：deal_merchant=0=carrier 存在性(TAG_MERCHANT=0)、envoy accept 低=決策端拒絕(送達成功)。
  - **✅ ④ 承載力=好的餓（food_ledger_bed）**：駐紮承載力邊緣(60%負流/20%斷糧,速度無關)但**斷糧隊 89-96% 搏命**(覓食/投靠/回家補給)→餓→行動 trigger 健康、稀缺引擎在跑。藍圖裁**別灌糧**(拔引擎)→ A2a 只 recalibrate ×1 承載力維持。
  - **★沙盒憲法（藍圖 2026-07-05，專案定義級 governing invariant，凌駕級入 invariants）**：作者寫世界不寫決策，凡 NPC 行為必經統一決策引擎，禁繞過引擎的行為規則/判斷器/行為 subsystem。稽核既有違憲碼溶進引擎=統一矩陣收斂主軸（稽核 spawned）。
  - **tick60 解析度（藍圖裁）**：`TICKS_PER_HOUR` 10→60（動根 TICKS_PER_DAY 240→1440），安全證 PASS（唯 `_get_near/far` 需 cadence 化）。裁1=3 機械修獨立 slice 先做（_get_near/far gate+10 裸常數導出+eta/240+FLEE）。裁2=**60 併 A2**（60 抵消 ×5→1 食物懲罰:240/1440=4h/格≈現 ×5 4.8h → 沒餓死潮,×1+60=最終節奏一次校）。裁3=**砍 A2b 沿途補給 subsystem（違憲）→改引擎接線檢查**（食物-on-journey 登記引擎子需求?塞糧/買/搶/覓食 affordance 匹配?缺→接引擎）。裁4=空間維度全連動導出。
  - **後續序**：0.憲法閘+違憲稽核清單 1.3 機械修 slice 2.A2=×5→1+60+FOOD/gen 一次重校(砍補給subsystem) 3.空間骨架導出+據點密度 4.QA 物流重驗+食物最終節奏重量+憲法稽核 5.cadence③/carrier/V2-cmd 後段。
- **💰 貿易環點火 ✅ 半路（feat/trade-loop-ignition，2026-07-04）**：六站漏斗定主斷=**timeout stale 秒殺**（`TRADE_TIMEOUT` 讀平行欄 `trade_task_start_tick`，只三路寫，unified/ambient 派 TRADE 拿 stale 0→tick>1440 派出即死，兩 seed dispatch 5.6萬/到場 0）→修=改讀 TaskArbiter 恆蓋章的 `task_start_tick` 單源+**廢平行欄**（家族病：2026-06-11 同病補記過，第四路又漏=散落純量 drift 活教材，故廢欄非再補記）；順修 ambient TRADE target=自格（→`_merchant_trade_target`）+途中相遇即 release（→到點才 release）+timeout 按殘距估。成交 **6→16/2→5（~3×/~1.5×）**、meet 16、arrive 3。**錯修二連 revert 入檔**：過期單濾（撲空=G1d 活性設計勿濾）、駐村隊 viability guard（村攤營業=需求側環實體勿擋）。**Task 3 三機器並綠**：①矛盾率 gate（`TRADE_CONTRADICTION_MAX=0.85` 回歸 baseline，絕對率 0.71-0.76 印真值不隱藏）②常駐六站漏斗③`--obs-ticker-dump` TSV。**誠實揭半路**：成交非數十、絕對矛盾率仍病=**殘因兩塊域外**（①LOD far 移速 10× 稀釋②default TAG_MERCHANT=0 無 carrier）→報藍圖裁。不塌房（funnel sanity pop/faction_found/capture 同量級）、回歸全綠。plan/handback 同名。
- **📊 全系統充足性率表 harness ✅（feat/sufficiency-rate-harness，2026-07-04）**：新 `scripts/debug/sufficiency_bed.gd`——default 自然世界（`player_id=-1`）× seed 1337+2674 × 6 月自跑，輸出全系統率表（每列 `想要/可行/發生` 三元組＋率＋月切面 delta＋表尾 `[SUFF_JSON]` 一行/列＋事件流 dump `SUFF_DUMP`=global+observer messages）。復用 `Probe`（enabled-gated、RNG-free），各鏈補缺失 counter（純加行）：message（sent/prop_candidate/prop_done/delivered/distorted/lie_claim）、belief（has_belief call/true、best call/hit、claim 新鮮度桶、reconcile 機會/比對）、diplomacy（proposal sent/handled/accept）、RelationGraph（tribute eval/with_edge/edge_flipped，snapshot 法逐位元等價）、intent（sel_<type>/goal_emit 讀側）、event（各型 check/fire）。既有漏斗（capture/assimilate/occupy/founding/envoy/scout）收編其輸出格式不重做。**中立性硬證：seeded warring 三 seed 逐點 `total_diffs=0`**（counters 不碰 RNG 流）。framework 7/0、coin_eq delta=0、headless DONE。**純機器不判不修**——率表原始輸出交 QA 判（合理 0 vs 斷鏈 0）。貿易列=佔位引貿易軌六站漏斗。plan `2026-07-04-sufficiency-rate-harness`、handback 同名。**觀察素材（未判）**：envoy delivered≈0（首列病單候選）、消費/送達 1.7%（非 order 類無決策消費 chokepoint=結構性缺）、意圖→行為非征服 intent 未到 task 層、event fire 多型 0（split/replace/defect 六月零觸發）——全交 QA。

- **👁 觀測 GUI 輕 slice ✅（feat/observer-gui-slice，2026-07-04）**：三件全上（事件 ticker 人話+隊過濾 / 隊伍 inspect+地圖三方同步 / 速度四檔+時間）+ god-view 地圖（archetype 色+faction 環+outpost 標）+ 截圖 harness（`--obs-seed/run-months/shots/select/out`）。Task0 事件補洞（assim/revolt/flee/captives_taken）走新 `emit_ambient`→`observer_messages` 獨立 channel（global_messages.size() 被 order_system 借作 oid 空間，append 會擾訂單行為——逐點 diff 實測抓到後改道，total_diffs=0）。玩家路徑零 diff、seeded warring 同 hash、framework 7/0。bar 場景 seed 1337/2674 六月跑滿，狼弧鏈畫面可讀。hitch 偶發（≈1/月，delta clamp 蓋幅度）→ far.total 不動。handback `2026-07-04-observer-gui-slice`。

- **🤝 互動統一 F-I2/I4/I5/I7+I6 ✅（feat/interaction-unification-fi，2026-07-04）**：屈服單一公式 `tribute_accept`（belief-gated+feud/gratitude 邊權重，三舊公式退役）、失真單引擎 `DistortionEngine`（三引擎+dormant 第4退役）、F-I5 judge=接線（feud/gratitude 活;killed/protect dormant 入 known_issues）、F-I7 `_should_attack` 轉 belief（無估→保守不攻）、F-I6 type 欄補。C 類退役不並存全程。seeded finals 量級不崩（hash 變=預期）、coin_eq 0、framework 7/0。TRIBUTE_* TEST VALUE 待平衡 pass。互動格矩陣殘=F-I8（NPC recruit 個體）。handback `2026-07-04-interaction-unification-fi`。

- **🏛 沙盒 bar arc（(a) 崛起/經濟底）— 連串 measure→fix**：commander-v2 後戰國 seed 揭 default 龜縮（CONQUER=0/established 卡1）。measure-first 逐層挖（別猜）：能人 pop 崩=**飢餓非戰敗** → ①**戰鬥不決勝**(0 擊潰，撤退先於殲滅，吸收掛 `_end_combat` never fire) ②**食物模型沒統一**(成長 surplus gate 讀私產 silo→糧倉/交易糧餵不到成長→非 plains 注定餬口)。
  - **🍞 統一食物存取 ✅（merge）**：`reaction_system` `_score_expand`/`_evaluate_life_events` surplus gate → `ResourceSystem.effective_food`(coherent，對齊 ambition_ladder)。統一非補丁、不 nerf regen、保交易摩擦。乾淨 bed forest pop 6→12（原餬口）。coin_eq 0/framework PASS/餓隊不誤放寬。**藍圖 🟡：讀 A（非 plains 能累積）收下＝(a) 攀爬「累積」段解凍；讀 B（特化-交易環真轉）未到＝下一經濟 arc**（trade loop 沒 fire＝覓食勝買糧）。plan `2026-07-01-econ-food-unify`。
  - **⚔ 失能-capture（戰不決勝 fix）= (a)-征服鏈 keystone ✅（merge）**：藍圖裁「失能者被俘=控地權」。measure 證 NPC 戰 0 擊潰（撤退先於殲滅）→P1 吸收掛 `_end_combat` never fire。修：npc_combat `_force_retreat`（潰逃）勝方控地俘敗方 **wounded 一比例**（=(1−readiness)×FACTOR cap，確定性非 RNG，guard 餘力限）→ captive_groups（P1 複用）。**決勝在潰逃非對撞**。warring 量證 **[Capture] 0→5、p1.assimilate 0→2**（captive dormant→fire）。守恆綠。plan `2026-07-01-incapacitation-capture`。存儲統一（prisoner_population）=Phase 2。
  - **🏛 獨立戰略層（統一決策 arc 第三塊）= (a) 收尾 founding ✅（merge）**：measure 證 rung2→3 卡＝能人是**獨立隊**（T32 cap4/食2207/pop9 全過唯 fid=-1）；commander-v2 戰略意圖 faction-level only→獨立無建國 drive。修＝**下放戰略意圖到野心獨立隊**：`_evaluate_independent_strategy`（fid=-1+野心≥AMBITION_FOUND_MIN+累積夠+路徑可達→秤建國 vs 守成，means-end）→ 結盟(primary,TASK_DIPLOMACY→interaction:333)/吞併(TASK_ATTACK→subjugate:524) → 複用既有 `create_faction`（非補丁）。**T32 建國 deterministic 證**（fid -1→正 members=2）、不 over-found、守恆。**★S3 回歸主 session 抓修**（子 session 誤稱 pre-existing）：獨立戰略 preempt prosperity-scout→修＝**遇 prosperity 候選+belief-弱 prey→defer**（讓 prosperity scout-gated→勝 subjugate 也達建國，不繞 G3d 誘殺）。framework PASS=7 復原、indep 5 測綠、coin_eq 0。**統一決策 arc 三層全補（隊/派系統領/獨立戰略）**。spec/plan `2026-07-01-independent-strategic-layer`。
  - **✅ (a) 機制里程碑封存（藍圖驗收通過 2026-07-01）**：三源全活（累積[食物統一讀A + 失能-capture]/founding[獨立戰略層]/征服[commander-v2+P1]）。**統一決策 arc 三層全補完成（隊任務/派系統領/獨立戰略）= session 開頭「決策不統一」真根徹底清。** handback `a-milestone-go-parallel`。
  - **🟡 新：沙盒征服維度（機制✓ / 活世界戲✗）**：established 1→多 / CONQUER 明顯**未在混亂 seed 顯現**＝不算完全達成（不打勾自欺）。**emergence 平衡 + consolidation = 經濟穩後 revisit**（不現在 tune＝打移動標靶；藍圖疑真根＝**consolidation：founded 守不住、T3 立國後失據點崩**，非純 attrition 數字→經濟穩後 measure-first 再修，連受控人力守征服）。
  - **▶ 轉平行（藍圖裁，各推一沙盒維度）— 兩軌 ✅ merged（2026-07-01 平行子 session）**：
    - **讀 B 覓食=苟活地板 ✅（merge）**：覓食來源食物 net-bank cap 到 subsistence buffer（`pop×食/人日×FORAGE_FLOOR_DAYS 1.5`，`hunt_system` source-gate：達 buffer→不獵不耗 wild_game 不 bank=守恆乾淨；超額 min-clamp、剩肉腐敗 sink）。只封 team private food **非 granary** → 定居繁榮不誤傷、地形 regen/forage 決策權重不動。headless 3 測綠（subsistence cap/no-growth/settled-grows）、coin_eq 0、framework PASS。**★次閘（measure 出，非本改造成）**：trade loop 仍不 fire，真閘=**定居隊 granary 自填**（forest regen 3 也填 granary 到 ~cap→成長由 granary 非交易驅動）→ 屬 granary/harvest 域另 slice（見 known_issues）。**誠實：「繁榮須交易」emergence 未到**（覓食封了、granary 旁路未封）。spec/plan `2026-07-01-foraging-survival-floor`。
    - **G3 Phase E enforce ✅（merge）**：5 god-view leak 補 `BeliefSystem.best_estimate`（1a 求貢 power_gap / 1d 收貢回應 / 1b 強鄰投靠 / 1c 施援目標 / 1e 背叛 ally 實力，無情報→保守 fallback 非偷讀真值）+ 背叛去純 RNG（`betrayal_assessment` 純函數：driver=人格+belief advantage「盟弱我利」，confidence gate，deterministic-hard + margin tie-break，取代 `score>0.65 and randf()<0.1`）。同 faction 內部協調/tally/位置=刻意豁免（共享情報，納 invariants）。1c 裁定維持 belief-strict（snapshot 豁免=可選增益、不擴 scope）。headless 5 測綠、warring g3.betrayal=21 合理、coin_eq 0、framework PASS。**誠實：enforce 到位（決策真跟 belief 走）但「自信地錯」emergence 需 Phase D 植假 + 專屬 probe 才量得到**（短窗量不到）。spec `2026-06-29-g3-info-warfare-unified`、plan `2026-07-01-g3-phase-e-enforce`。
  - **🔧 team-ref 根因修：create_faction bidir-safe ✅（merge）**：foraging branch warring seed RNG-shift 掀出 **pre-existing 結構 bug**——`create_faction`(`world_state.gd:75`)直寫 `leader.faction_id` 沒退舊 faction 成員籍（不像 bidir-safe `set_team_faction`）。已是成員的隊建自己 faction（獨立戰略層 rung2→3 複用 create_faction）→ faction_id 翻新、舊 `member_team_ids` 殘留懸空 id → 該隊 erase 時 faction_id-gated cleanup 只清新 faction、舊懸空 → `_assign_member_tasks`(faction_ai:1043) `require_team` assert crash flood。修=create_faction 改走 `set_team_faction`（退舊籍再入新，單源非補丁）。warring seed 1337 驗 **require_team 17850→0**、combat_target Nil 0、SCRIPT ERROR 0、跑滿 24 月 DONE、established 1→2。**實作正確沒打 null-guard 補丁（team-ref 域=系統 domain），呈報主 session 裁**（[[feedback_no_patch_on_settled_architecture]] + team-ref A 類契約）。
  - **backlog（不阻塞）**：存儲統一 prisoner_population→captive / solo 宣告 founding = 受控人力 Phase 2；rung2→3 已解。3+1 對稱不變量骨架（決策✓/信息 G3/所有權 Pattern B/凡位置✓獨立戰略）已納 invariants。

- **🔬 granary 真根定位 + 指標 specimen tracer + scaling 加固 P0（藍圖 anchor-probe-and-hardening，2026-07-01 平行子 session）**：
  - **granary 真根定位（碼證，推翻藍圖 net0 前提）**：`regenerate_tiles`(`resource_system.gd:78`)+harvest(`:222`)**未 day_fraction 縮放**、consumption(`:91,108`)**有** → 供給 24× 快於需求 → forest **秘密 net-positive**、超額 trap 進封頂 granary(釘 2000=爆倉非停滯)。更大：整個世界食物太鬆=無 starvation/無 trade need/turtle 部分源此。**R1(供給 day-scale)=economy-wide rebalance 跨 WHAT 域→呈報藍圖，R1 食物緩**。handback `granary-rootcause-cadence`。
  - **🔬 指標 specimen tracer ✅（merge，觀測 only 零行為變）**：指定指標團 LOD-exempt trace 決策 timeline（想什麼 intent+全候選 util+belief / 做什麼 winner+task / 狀態 pop·food收支·rung·faction·資源）。`SpecimenTracer`(static, default off)+`specimen_bed.gd`。tap：`decision_engine.rank scored[]`(全候選 util)、`_emit_goal`(+state, commander intent)、solo intent、winner commit。**★measure 結論（藍圖要的經濟真根，修正假設）**：不是「錨有名日常無實」，而是 **(a) 獨立商隊零 named 致富 intent**（commander-v2 只給 faction intent、獨立隊無致富意圖節點 → 交易純 emergent utility 非錨驅動）+ **(b) 日常交易有實但被 survival/食物壓力碾成覓食/買糧**（早期 100% 貿易→晚期覓食107/買糧35 碾 貿易，賺 coin 轉買糧/逃命無複利）。conqueror specimen：commander 征服 intent 0、攻擊來自 survival-loot(掠奪54)+vendetta 非 means-end 鏈。**tracer 證食物壓力是掐致富的直接手（R1 雖緩但相關）**。spec/plan `2026-07-01-specimen-tracer`。**待藍圖**：致富要不要成 named 意圖（獨立隊致富 intent 節點=統一決策 arc 延伸）。
  - **⚡ scaling 加固 P0 ✅（merge，零行為變）**：`teams_by_tile` 共用空間索引（每 move rebuild）→ co-location **O(N²)→O(N)**（N=400 3.26×、speedup 隨 N 拉大）、hostile-within/residency 索引化（sparse frontier tail 保險）；`team_intel` **erase-prune**（top memory leak 修：erase 隊清 observer row + 各 observer 對其 target claims）；`sim_runner` **tick 計時 instrument**（`[TickPerf]` 日邊界聚合）；`scaling_bed.gd`（大 N 100/200/400 + 滅團潮）。**honor-LOD 量到不需**（evaluate_all 誠實 O(N)、索引已足）故不做（measure-gated）。**die-off erase O(N) spike 誠實標未收**（不在 P0，另案 known_issues）。零行為變證（加固前後隊數逐點同）、warzone 21600 tick InvariantSummary 0/coin_eq 0。spec/plan `2026-07-01-scaling-hardening-p0`、評估 `late-game-scaling-assessment`。

- **🗺 統一矩陣 program（藍圖 refactor 止打地鼠，2026-07-01）**：反覆冒「沒統一」根因=缺結構視圖 → 開實體×領域稽核。**逐檔窮盡 sweep 全 76 production 檔**（8-batch fan-out 逐行；first-pass grep 版自糾:誤稱 team.resources 被 53 直寫繞、實乾淨）。全貌 `specs/2026-07-01-unification-matrix-audit`（9×7 矩陣 + 30+ fork）。**核心對**（同 TeamData + computed getter no-op setter=最強單寫者）**但 fork 遠比 4-cluster 多、第3不變量單寫者大面積未實現**。教訓 memory `feedback_structural_audit_complement`（measure-first 只抓近端需結構互補;過早喊 done 誤導;+claim-time trigger 自糾）。program 四塊(矩陣稽核✓/強制閘/checklist/逐格燒)。**燒序首三軌並行 merged**：
  - **🎯 首燒 戰略 intent 統一 ✅（merge）**：`select_strategic_intent` 統一 scorer「任何 leader 一套菜單」`{致富/擴張/征服/防衛/守成/建國}`,獨立隊得全菜單(前截斷{建國/守成})。**致富錨接上**(specimen 商隊 想=致富263→做=貿易120,前「日常」無 driver=tracer 揭的經濟真根解)。F-D3(strategic_ai 降空間 affordance 層、單一 intent source)/F-D4(solo_intent struct 廢一槽兩義)/F-D6(threat un-stub belief-based,不壓 P2a survival)收。warring **CONQUER 0→1**(不再結構恆0=前 histogram 僅計 faction 假象)、RICH 主導、EXPAND/FOUND 顯化、DEFEND 高+CONQUER 稀=非病態全民開戰。framework 7/7 PASS、coin_eq 0。**誠實標:征服名vs實斷點**(unified 好戰獨立 想=征服但 winner=掠奪、`_decide_unified` 掠奪 option 搶在 prosperity attack 前;錨顯化非乾淨征服→攻擊)=follow-up。spec/plan `2026-07-01-strategic-intent-unification`。
  - **🪙 單寫者 slice1 coin 守恆 ✅（merge，零行為變）**：`CoinAudit.total` 全池(team.resources+anon_treasury+person.coin+tile.public_storage.coin+abandoned_coin)、`adjust_person_coin` person.coin 單寫者(4 site 含 reaction:292 勒索,plan 沒列一併收)、mint `Probe.add_amount("mint_coin")` ledger + **順修舊 known_issues「mint coin-cap 燒 ore off-ledger」**(先算 coin room 只鑄容得下量、不燒 ore)。裁 **coin_eq 剔 ore**(ore=採集產出非守恆,計入會憑空長)。baseline delta=0(無既有洩漏,值=audit 覆蓋補全 person/tile vault 盲區+單寫者紀律+常駐守恆閘)。spec/plan `2026-07-01-coin-conservation-singlewriter`。
  - **🔍 BEG/JOIN 死路探針 ✅（merge，measure-first 零行為變）**：F-I3 量到 **JOIN=中**(radius14 66/月 runtime 100%空轉,兩 failure mode:197 combat_target 早退 + **根本無 interaction handler**)、**BEG=低**(resolver:247 存在但被 197 擋、prosperity 期 dispatch~0)。機制死路單元測證。**修=follow-up**(建議合併修 combat_target「社交 target≠戰鬥 target」語意拆=共根)。spec/plan `2026-07-01-beg-join-deadpath-probe`。
  - **🍞 B 食物張力 ✅（merge，行為變已校準）= 經濟維度機制到、交易網未轉（露下一閘）**：**R1** regen(`resource_system:78`)+harvest(`:222`) day_fraction 對齊（修 24× cadence bug、移 far 分支冗餘 regen=雙記元凶）、`FOOD_PER_PERSON 2.4→0.8` 校準（REGEN 常數不動、散落硬編一併引 const）;**R2** `food_flow_avg` EMA（日均淨食物流）、breed/ambition rung gate 讀 **flow 非 stock**。econ_bed **forest 苟活 6→7**（非爆倉 6→12、eff_food→0 手到口想交易）、**plains 繁榮 6→8**;warring **不 mass-starve**（涓滴非潮）;framework 7/7。**★誠實標:致富→交易仍未接**——granary 爆倉閘拆、露**下一閘=建設 util 碾貿易**（0.79>0.26,決策權重域非食物,another slice）。行為變:ambition rung 讀 flow → prosperity-attack 需經濟盈餘（飢餓不主動開戰）。TEST VALUE 待平衡。spec/plan `2026-07-01-food-tension`。
  - **🔐 單寫者 slice2 ✅（merge，零行為變）= 強制閘首個可查對象**：**Pattern B driver-ledger 真記**（`world_state.driver_ledger` off-by-default ring-buffer、5 bank reason 現真 append 非丟棄）+ **roster chokepoint**（`add_member`/`remove_member` named_members↔person.team_id bidir、33 production site 遷、2 明示豁免）+ InvariantAudit roster bidir（forward）。**audit 立刻證價值**：揭 pre-existing **leader/team_id desync**（roster chokepoint tyrant 4→0、merchant P0 殘留=leader 指派非-named 路徑,root fix 行為變交 triage）= 第3不變量首個真實可查對象。零行為變（headless 綠、pre-existing FAIL 驗 baseline）。tile-granary-bank/combat_target 延後 slice。spec/plan `2026-07-01-singlewriter-ledger-roster`。
  - **⚔ 征服名實 measure ✅（merge，measure-first 證偽首燒假設）**：量到 **首燒假設錯**——征服隊 **100% 非-unified**（`_decide_unified` 對它不跑、`conq.declared_unified=0`）、舊 solo path 征服 winner **96.8% 攻擊非掠奪**（「想征服做掠奪」在此 seed 假）。**真斷點=攻擊→capture 轉化崩**（243 攻擊決策→1 capture）:**兩條攻擊路徑**（舊 solo 粗攻擊 `_nearest_independent` 無 scout/rung gate vs `_evaluate_prosperity_attack` 細攻擊 weakest-prey/scout-gated/導 subjugate）,粗的優先觸發淹沒細的。**修向=統一征服攻擊路徑**（非-unified 好戰隊 TASK_ATTACK 委派 prosperity）,**非動掠奪**（打錯靶）。follow-up spec（measure 支持）。spec/plan `2026-07-01-conquest-name-vs-deed-measure`。
  - **🧠 means-end 接戰術層 ✅（merge）= 願景進化第一深化（三症狀同根=查表非規劃）**：斷點 measure 確認**戰術層 flat/intent-blind**（`DecisionEngine` util=人格×context,從不讀 team 自己戰略 intent;唯一 goal→tactical hook=faction_stakes→faction_duty 只給 faction 成員、獨立隊 solo_intent reshape 零）。修=**generalize faction_duty → `intent_fit` term**（inject `intent` 進 `DecisionContext` + intent→子需求→貢獻打分 reshape option util）。**★症狀 a（致富→貿易）全解**（貿易 2.08/囤貨 1.27>建設 0.20,前建設碾;merchant specimen 想=致富→做=貿易 100%）+ 新 `囤貨` option。**症狀 b（征服→攻擊統一）機制成**（征服 intent→scored `攻擊`→route scout-gated prosperity,route 6.6×[13→86]）**但 capture 轉化未升**（吞併完成 depth 低=combat/subjugate 完成率 pre-existing、scope 外）;conqueror specimen food_days≈3 survival-trap→掠奪(「餓則搶」emergence 但食物軌壓過戰略層)。**症狀 c（匱乏→搶）gated**（匱乏+野心→掠奪、溫和不搶,防 over-war;over-war 4pp 落 unseeded 噪）。**四關**:①④部分(capture 未升)②③PASS。守恆全綠 framework 7/7、coin_eq 全池 0、北極星 holds（intent_fit boost 帶 driver）。TEST VALUE 待校。spec/plan `2026-07-01-meansend-tactical`。**移動標靶下一步**:capture 完成 depth + conqueror 食物 survival-trap（跨食物軌）。
  - **🔐 單寫者 slice3 ✅（merge，leader desync 根修）**：`set_leader` chokepoint（leader_id↔person.team_id force-sync,**根修 slice2 audit 揭的 leader/team_id desync**）+ `is_dead` 留屍標記 + **反向 roster audit**（person→roster,is_dead/team 不存在跳）+ `driver_tick_hint` 接線（ledger tick 溯源真）。game_sim_multi ×3 全配置 forward+反向 roster InvariantSummary=0（含 warzone）。**結構保證**（chokepoint 強制同步 + 反向 audit 常駐）非 case 復現（merchant desync unseeded 間歇）。納 invariants（規則 2 set_leader / 規則 3 反向 / 所有權域 desync 根修）。combat_target/tile-bank 延後 slice。spec/plan `2026-07-01-singlewriter-slice3-leader-desync`。
  - **🎯 combat_target/social_target chokepoint + BEG/JOIN 死路修 ✅（merge，2026-07-02,下燒平行軌）**：**social_target 拆 combat_target**（語意:社交投靠/乞食 ≠ 戰鬥）+ `set_combat_target`/`set_social_target` chokepoint（F-S4,mirror set_leader,dangling audit）。BEG/JOIN dispatch 改 social_target → 過 `_try_interact:197` 戰鬥早退;**新 JOIN resolver**（merge_teams full absorb）+ BEG/JOIN resolver 上移過 same_faction 塊。**F-I3 死路消**（join.resolve 0→4、arrived_no_handler 0;beg unit 決定性驗）。combat_target 9 site 遷 chokepoint（thin wrapper 零戰鬥變）。framework 7/7、coin 全池守恆、InvariantAudit（含 social_target dangling）OK。**行為變=絕境投靠/乞食復活**（藍圖 marker1）。納 invariants（規則 2 combat/social_target + 所有權域）。spec/plan `2026-07-02-combat-target-social-split`。
  - **🎲 seeded warring 回歸 harness ✅（merge，2026-07-02,純 infra 零 sim 變）= 解 recurring unseeded 盲點**：`WarringHarness.run(world_seed)`（`seed()`+`config.seed` 逐 tick 逐隊確定）+ `seeded_warring_bed.gd`（before/after pointwise diff,同 seed total_diffs=0=noise floor）+ `warring_states_seed` 加 `WARRING_SEED`。RNG 盤點:72 global randf 納 seed、setup local via config.seed、scaling_bed 自有 rng scope 外記。重現性 TDD 綠。→ **warring emergence/over-war 自此硬-verifiable**（noise floor=0→任何跨 code delta=訊號;實際 pre/post 需 dump `WARRING_OUT` baseline 切後 `WARRING_BASELINE` diff）。**但 game_sim_multi/world_sim 仍未 seed**（[[reference_multi_sanity_unseeded]] 更）。spec/plan `2026-07-02-seeded-warring-harness`。
  - **⚔ capture 完成 depth ✅（merge，2026-07-02,下燒核心）= 戰內 PAY 修、但 measure 揭主崩上游**：measure-first 漏斗（14400 tick）——**主崩=intent 126→combat_entered 12（~10% 到真戰鬥）**=攻擊派了追不到/target 消失（targeting/reachability 上游,**非本軌 scope**）。戰內兩病修:①戰不決勝（retreat 7>>decisive 1）②潰逃零 PAY（5/7 wnd=0 俘 0、`_force_retreat` 不 loot=主流戰果零收）→ **潰逃兩路皆 PAY**（掃戰場 loot + `capture_routed_as_captive` 俘 healthy `HEALTHY_ROUT_FACTOR 0.35`）。framework 7/7、coin 全池守恆、InvariantAudit 0、rout capture 測 OK。**★誠實標**:capture.total 3 仍低（戰鬥本身稀有=上游 attack→combat 轉化崩,需 targeting 補）;Task3 survival-trap 自解**上游阻**（specimen 想征服打不到）;以戰養戰人側 assimilate cadence 慢（morale 0.25→0.75 ~25 天,churn 下 P1Absorb=0=manpower 平衡）。spec/plan `2026-07-02-capture-completion-depth`。**下燒三軌全 merged。征服者 emergence 下一瓶頸=attack→combat 轉化(targeting/reachability)。**
  - **🍞 B 食物張力（R1 cadence + R2 flow-not-stock）✅（子 session，branch `feat/food-tension` 未 merge）**：granary爆倉 真根修。**R1**：`regenerate_tiles`(food_regen)+`_collect_from_tile`(harvest gain) 乘 day_fraction（與 consumption 同基準，修 24× 供給不對稱 bug）+ **移除 far 分支冗餘 `regenerate_tiles`**（near 分支已每小時全域再生所有 tile，far 重複=24× 雙記元凶之一）→ 供給真 per-day（forest regen 3/day marginal，REGEN_RATE 常數未動）。**張力校準**：`FOOD_PER_PERSON_PER_DAY 2.4→0.8`（穩態食物 income≈regen[plains op1 ~8/day]；0.8 使 plains op1 養小鎮微盈餘=繁榮、forest op1 微赤=苟活須交易；赤字溫和不成餓死潮）。**R2**：成長讀 flow 非 stock——`team_data.food_flow_avg`（日均淨食物流 EMA，`resource_system._update_food_flow` 每 cadence 更新）、生育 gate(`reaction:201`)+野心積累 rung(`ambition_ladder:52`) 讀 `food_flow_avg` 非 `effective_food` → **granary 爆倉不再驅動成長**（滿倉但 net~0→不長）。**bed 驗每步**：econ_bed **forest pop 6→7 苟活(不死/food_buy=Y 想交易)、plains 6→8 繁榮**（前 forest 6→12 純爆倉）；warring 1月 famine=69(1-anon-at-a-time 涓滴,非潮;能人 25→4 但活且回充/T18 forest 24→19 較 pre 24→6 溫和/T32 9→9 持平)=**不 mass-starve**。headless 全綠(修 ~18 assert:breed/rung 改設 flow、消耗/beg/food_days 數值×const)、framework **7/7 PASS**、coin_eq/InvariantAudit 綠。**誠實標經濟維度 emergence**：**致富→交易→成長鏈未接**——specimen 商隊 想=致富262/263 但 winner=**建設**263/263(建設0.79>貿易0.26)，**從不貿易**。granary爆倉閘已拆，露出下一閘=**建設 util 碾壓貿易(決策層權重,非本軌 scope)**。spec/plan `2026-07-01-food-tension`。**待主 session 裁**：①野心 rung 改讀 flow → 新隊/marginal 隊 flow=0 起步暫 SURVIVE(需持續盈餘才升 rung/prosperity-attack)＝**戰略層行為變**(founding 用獨立 stock gate 未動,S1 PASS;但 prosperity 侵略需經濟盈餘)；②warring 8月全窗跑不完(健康隊多=sim 變重,600s timeout,反證不 mass-starve);③FOOD_PER_PERSON 0.8/flow 門檻皆 TEST VALUE 待平衡 pass。

- **🪖 受控人力統一系統 Phase 1（anon 吸收解 (a)）✅（merge）**：(a) 攀爬卡點 measure 揭「征服只 loot 不長 pop → 戰爭非累積 → turtle-world」。fix = 征服**吸收敗方殘餘 anon pop** 成隔離 captive（低忠，不入 population getter=非戰力）→ 待遇 means-end 決策（厚待/苛待/釋放，driver=holder leader 野心/殘忍/缺糧意圖）→ 軌跡：**厚待→morale 升→同化（captive→holder free pop，population getter 漲＝解 (a)）/ 苛待→morale 崩→暴動（脫離+鎮壓戰損+holder unrest）/ 低 morale+機會→逃（脫離成流民隊）**。**純 anon、零跨域（Phase 2/3 後續）**。**架構**：captive 持有 = `TeamData.captive_groups: Array`（**非 subteam**——subteam dispatch 強制 named leader + cohort 鍵固化，純 anon captive 走 holder 上獨立結構）。**守恆（命脈）**：吸收/同化/暴動/逃全經 `AnonTierSystem.absorb_as_captive/assimilate_captives/detach_captives`（pop 轉移非憑空；暴動鎮壓亡=真死亡路由非消失）。`absorb_as_captive` 插入 npc_combat `_end_combat`（敗方陣亡結算後、erase 前）。`ManpowerSystem.tick_all` sim_runner 每日 cadence。`InvariantAudit` 加 captive cohort 自洽網。**driver-complete**：captive group 帶 `entry/origin_faction/treatment_history`（provenance 追得回吸收+待遇史）。**結果**：headless 4 mp1 測（吸收守恆/待遇軌跡/decide driver/believability）+ 全綠、framework S1-S6 PASS、game_sim_multi InvariantViolation=0 + coin_eq delta=0（含 warzone 戰鬥場景）。常數全 TEST VALUE（CAPTURE_RATE=0.5/CAPTIVE_INIT_MORALE=0.25/ASSIM_T=0.75/REVOLT_T=0.08）。spec/plan `2026-06-30-controlled-manpower-*`。**待主 session**：(a) climb/warring seed 量測解讀（CONQUER 0→? 能人 pop 累積否 不 over-war 否）、常數平衡、Phase 2 named 俘虜起點、rung2→3 另案。
- **🏛 commander-v2 統一統領決策（means-end 意圖驅動）✅（merge）→ 統一決策 arc 真根最後一處收編**：隊層早已統一進引擎，但**統領層 `_update_goals` 仍多閾值並行**（measure 證每 persona 同發 ≥2 無因令、好戰霸主 4 令矛盾=arc 在殺的同隻病最後一處）。**藍圖多輪修正**：①先單姿態（作廢，氣點非發多令是令無法解釋）②升**北極星不變量「凡 named 意圖必有可解釋驅動」**（納 invariants）③means-end 模型（意圖=目標 predicate→子需求=主行動未滿足前提現算→行動=多義 affordance→util=Σ(affordance∩子需求)×人格×可行性）④裁 A：先真 affordance（affordance 真實性盤點 7 action/47 真/29 孤兒，**欺敵外交/貿易戰=孤兒** sim 不產出→列 anchored-pre-player 承諾 arc，玩家面前必落地）。**實作**：`_update_goals` 重構——`_select_intent`（征服/致富/防衛/守成 argmax，人格×belief×viability×hysteresis；征服 gated by `_conquest_viable` 我力含補力餘裕≥belief 敵力）→`_decompose_needs`（深度1，攻擊主行動 force_ge_target 不足→開「補力」need；can_reach 擋敵盟→欺敵孤兒→**不開不假塞**）→`_match_fillers`（補力←結盟(外交 ally,義氣) vs 徵收(fund_war,貪婪) util 比較選）→`_emit_goal`（每令記 `f.goal_drivers[goal]={intent,why,mode}`=北極星）。小集（意圖4/行動3 真 affordance）+深度1+resource-aware（湊不出力退更小意圖，不發打不贏攻擊令）。掠奪移除（team P1）、war-priority `FACTION_DUTY_DRIVE_LESSER` revert（單意圖後 moot）、緊急徵收=survival override、立國=既有分離 gate。**驗收=可解釋+viability 非跟戰數**（藍圖明令）。**結果**：measure 4/2 無因令→**每令有 driver、無因令=0**（assert）；意圖 argmax 人格/belief/viability 分歧（好戰→征服[攻擊+補力肢]、貪婪→致富、敵強→退守成）；headless cmd 3 測+P2/P3/P4 全綠、coin_eq 0、framework S1-S6 PASS、world_sim 2yr teams=8 穩無意圖反覆。**means-end 真跑非退化**（filler 現算+util 比較證）。**子 session 誠實標**：湧現協同 scheme 只在「力不足但 viable」窗口（力足→單令攻擊、力太低→退守成）=正確 means-end 但 world_sim 該 seed 未捕捉到 viable 窗口（派系少/短命），靠 unit+P3 證；窗口真實頻率待真人玩測。spec/plan `2026-06-28-commander-decision-unify-v2`（v1 單姿態作廢）。**統一決策 arc 兩半（隊+統領）全收編。下一塊=欺敵 sim arc（anchored-pre-player）**。
- **🏛 P4 頂層 stakes options（徵收/外交）✅（merge，他域鏈第五步，承藍圖 ruling P3-A）**：unified 隊全響應派系 stakes（攻擊 P3 + 徵收/外交 P4）。**泛化** P3 `faction_directive`(單攻擊)→`faction_stakes: Array`（`STAKES_SET=[攻擊,徵收,外交]` ∩ f.goals；立國=leader-level `_declare_established` 非 member option、掠奪=日常個體、結盟⊂外交、大徵收=徵收）。加 `徵收`(TASK_TRIBUTE→`_richest_member`，**雙重排除自身** gather+to_task)/`外交`(TASK_DIPLOMACY→`_nearest_independent`) option（mirror 攻擊：`[[faction_duty,faction_duty],[levy_drive/diplo_drive, levy/diplo]]`）；`levy` weight=貪婪/好戰染色、`diplo`=義氣/計謀染色；全 stakes 共用脫軌逃閥 `_duty_factor`。霸主決策步複用 `_update_goals`（既有徵收/外交 gate）。**子 session 抓真 believability bug**（正確停手未硬改）：多 stakes 共存時忠誠溫和 member（好戰0.1）因 `weight(diplo)0.60>weight(attack)0.33`、faction_duty 對兩 option 等值 → 轉外交 skip 戰爭 → 跟戰 **3/4→2/4**，違反藍圖 A 裁定明文「忠誠=連勉強也到場非缺席」「B 鬆協同=戰爭溶回個體 noise」。**war-priority fix**（實作藍圖 A 原則，非新願景決策）：`攻擊`(存亡級戰事)faction_duty drive `FACTION_DUTY_DRIVE 1.5` > `徵收/外交`(次級)`FACTION_DUTY_DRIVE_LESSER 1.0` → 多 stakes 共存戰事優先、跟戰 **3/4 復原**（外交 sole-directive 仍 fire 1.06>daily）。**結果**：headless P3 不回歸（soldier→ATTACK）+ P4 全綠（levier→徵收/envoy→外交/rebel→建設脫軌/染色 ug0.199>um0.067/危時→覓食）、war_scenario 跟戰 3/4、world_sim 2yr teams=8 穩無 over-coordination、coin_eq 0、framework S1-S6 PASS。皆 TEST VALUE。spec/plan `2026-06-27-p4-faction-stakes-options`。**他域鏈 P0-P4 全完成**（P2b-2 全退 entry = polish 債）。**待藍圖**：war-priority（攻擊>徵收/外交）認可否 + FACTION_DUTY_DRIVE 量級（handback `p4-faction-stakes-options-war-priority`）。
- **🍞 買糧求生 option（Phase 1）✅（merge，承藍圖 ruling 2026-06-26 §2 取食對稱）**：measure-first（`buyfood_measure.gd`）證**餓商隊 food_days=0.10+coin=500+鄰市集售糧 → 引擎首選紮營(util1.08)/乞食(0.87)，有錢不買糧**（搶=option[掠奪] 買≠option=不對稱，乞食變成向賣家乞討而非買=荒謬）。修=補 `買糧` engine survival option：`buyfood_drive`=`hunger(DESPERATION_SCALE×(3−food)) × 旅費折扣(BUYFOOD_DIST_FULL 6/max(dist,6))`、weight `buyfood`=商隊 1.0/他隊 0.3（role 權重非 gate，守 tc7）、applicable=food<DESPERATION+有市集+有錢（`has_specie`=coin>0 or goods≥10，無錢=乞食真語意不入）、to_task=最近市集（`_nearest_market_outpost` 複用）→ `TASK_TRADE`（到場 `_resolve_market` 餓隊 food local_value 高→買 food）。入 `SURVIVAL_OPTION_SET` → P2b-1 委派 `rank_survival` **自動全隊化**（軍隊等有錢也買）。**結果**：measure 重現 rank=[買糧,紮營,乞食,建設,survival] **首選買糧**（util 3.48）、headless 全綠、world_sim 2yr 無 mass starvation/seek_market=43、coin_eq 0、framework S1-S6 PASS。**known（Phase 2）**：買糧量級(DESPERATION_SCALE 1.2×)<覓食(survival_pressure 4×)→ 小隊(pop≤15)鄰市集仍覓食非買 = same-frame 量級未統一；撲空（市集無糧）無專屬探針。皆 TEST VALUE。spec/plan `2026-06-26-buyfood-survival-option`。**Phase 2（距離折扣 retrofit 掠奪/返家補給 + same-frame 量級統一）延**（藍圖「同框」完整模型，獨立 slice）。

## 📍 前狀態（2026-06-22）

- **🏛 P0 G1a 礦村（山村特化）✅（merge `61af5c4`）→ 鑄幣脈絡 default 真活**：量測推翻 stale premise（[[feedback_verify_backlog_fresh]]）——非「無金礦 tile / 鑄幣 code 壞」，真根 = **金礦只在山地、山地住不了人(food 再生 0.5)、採礦需在地 → 金礦物理上不可開採**（雞生蛋死鎖）。用戶裁模型 **B 礦村**（蓋在含礦山的不自給 civilian outpost，外部供糧）。最大複用既有（自格採 ore/mint facility/_pick_facility/food 買單/糧倉/subteam 建造）。S1 礦脈保證 guard / S2+ 貪婪 leader 選 **ore-mountain 本身**（非鄰接平原，threshold gate 保稀有=非貪婪不建）/ S3 bootstrap 攜糧+market food buy / 施工子隊韌性（survival/betrayal/tribute/encirclement/discipline/tag-shift 豁免，皆 10 日 CONSTRUCT timeout 或 build 完成或滅團兜底，**只豁免行為不碰死亡/守恆**）。**結果**：default.json r8 自然 fire 4/5 run（mine_founded>0、mint>0、coin 增）、world_sim 1/1、真鏈端到端證（ground ore→vault→mint→coin，無 pre-seed）、coin_eq 0、InvariantAudit 0、framework S1-S6 PASS DORMANT=0。3 輪 review（含 opus 終審 APPROVE）抓並修：far-construction 雙計(LOD 前提錯→刪)、distance 免疫過廣、zombie latch、facility_deficit 洩漏、測試 pre-seed。spec/plan `2026-06-23-g1a-mint-mining-village`。**backlog（known_issues）**：mint coin-cap 燒 ore off-ledger(pre-existing,G1a 首 fire 才浮現)、非貪婪 leader 在無平原時仍可建礦村(稀有邊際)、dense map distance 免疫未測。
- **🏛 P1 個體域 掠奪 option ✅（merge，承他域 ruling #1 日常 op=個體人格）**：unified 隊（merchant/produce）加人格加權 `掠奪` engine option——殘忍×0.5+好戰×0.3+貪婪×0.2 weight、`loot_drive` base 1.0（has_weak_prey 時）→ loot util ≤~0.8（危時 survival_pressure ≥2 仍碾壓=餓隊先求生非日常打劫）；複用 `_find_weakest_prey`(belief-read)+TASK_LOOT+既有 loot/extort interaction（小徵收隨 loot 來，不另做 option）。`_decide_unified` 加 combat_target wire（`td.has("combat_target")` 守衛=既有 option 零影響）。**scope 嚴**（防 P0 sprawl）：只 掠奪、non-unified 零碰、無新 TASK_*、無 exemption 鏈。**偵查延 backlog**（下游消費存疑=避 dormant code）。headless 全綠（人格分歧+餓隊不日常掠奪驗）、coin_eq 0、framework S1-S6 PASS。**注**：world_sim 該 run unified 隊沒 fire loot（RNG 沒生殘忍商隊 leader）=機制 headless 證、rare tail + P2 loot 遷移基建，非 dormant。spec/plan `2026-06-23-p1-individual-options`。**解鎖 P2 loot option**。
- **🏛 他域遷入 ruling 到 + HOW 序定（P0/P1 完成，P2-P5 待）**：藍圖裁 `otherdomain-ruling`（consumed）解鎖全卡項。**協調=混合**（stakes-to-faction→頂層協同 faction_duty 壓人格；team 日常 op→個體人格）；**believability 守則**（頂層決 WHETHER 人格染 HOW + 脫軌逃閥非 100% 服從）；**主動開戰=稀有+蓄意+吃 belief**（霸主決策、readiness 門檻）；**mint 現在排 G1a**（覆前判緩做）。**HOW 序**（小切片先、dependency-correct，每 Phase spec→plan→worktree→跑驗證套件 TC+S 魂）：
  - **P0 G1a mint ✅ done**（merge `61af5c4`，見上條）：礦村模型 B，default 自然 fire 4/5。
  - **P1 個體域 options ✅ done**（merge，見上條）：掠奪 option（scout 延 backlog）。解鎖 loot。
  - **P2 survival 全隊退役 + loot/join 還經濟隊**（依 P1 loot）：退役舊 `_evaluate_survival` 雙 owner、loot/join/camp/beg/hunt 遷引擎+全隊化。閉框架完成塊③ + 經濟↔衝突橋（藍圖標記1債）。**切兩片**：
    - **P2a 絕境 option ✅ done**（merge，承標記1 join 債）：unified 隊（merchant/produce）加 `投靠`/`紮營`/`乞食` engine option，補齊 survival repertoire（loot P1 已做，今補 join/camp/beg；hunt 無 TASK 延 P2b）。drive=desperation magnitude（`DESPERATION_SCALE 1.2 × (DESPERATION_DAYS 3 − food_days)`，吃飽→0=健康隊不選）× weight（join=義氣0.4+信義0.3+求生欲0.3、camp=野心0.4+統領0.3+求生欲0.3、beg=求生欲×`BEG_FLOOR_FACTOR 0.5` 墊底，複用 `_join_pref`/`_camp_pref`）。applicable food_days<DESPERATION gate（健康隊不入榜=TC1/4/6/7 零影響）。複用既有 finder（`_find_strong_neighbor`/`_find_unowned_farmable_tile`/`_find_aid_target`）+ 既有 TASK_JOIN/CAMP/BEG。**2 seam wrinkle**：W1 camp-arrival 立營 hoist 到 unified gate 前（否則 unified 隊走到 camp tile 永不立營）；W2 `_decide_unified` player-join guard（投靠玩家→forced_event 非自動 merge，且 interaction layer 155-188 雙保險不 auto-merge 進玩家）。**non-unified 路徑零碰、不退役雙 owner（P2b）、不動 ~20 test 直呼點**。結果：headless 5 新測 PASS、world_sim 2yr 存活穩 7（`CrudeCamp`×3/`SurvivalJoin`×1=**標記1 join 債閉**/絕境轉移×2，無 over-camp）、coin_eq 0（4 config）、InvariantViolation 0、framework S1-S6 PASS。皆 TEST VALUE。spec/plan `2026-06-23-p2a-survival-options`。**解鎖 P2b**。
    - **P2b survival 全隊退役**（切兩片）：
      - **P2b-1 survival 選擇統一 ✅ done**（merge，消 survival 動作選擇雙 owner）：non-unified `_trigger_survival` 動作選擇改委派 `DecisionEngine.rank_survival`（survival 子集 = `返家補給`/`覓食`/`掠奪`/`投靠`/`紮營`/`乞食`，applicable 過濾、不寫 current_option、承諾比對 current_task）。**刪**手寫 `desperation×values` branch + `LOOT_GATE`/`JOIN_GATE`/`CAMP_GATE` const + `_loot_pref`/`_join_pref`/`_camp_pref` helper（公式併入 `DecisionTerms.weight` 單一 owner）。**`返家補給` generalize**：任何有家隊絕境（food<DESPERATION 3）→返家（非僅商隊 proactive food<5），保熱路徑。`覓食` viable-pop 守衛移入 applicable（pop≤15）。保 `_evaluate_survival` gate + `_trigger_survival` entry + `PRIO_SURVIVAL` + hunt fallback + player-join guard（同 P2a W2）。**measure-first 修正前提**（[[feedback_verify_backlog_fresh]]）：spec 稱 1037 `[Survival]` 多為 return_home **不準**——baseline 即 **idle-release churn 主導**（927/1032=攻擊隊輕飢→survival 無可派→release→idle→再攻，**pre-existing**，927→932 本塊未引入）；返家機制由單元測 deterministic 證。**已知行為變**（spec 明列可接受）：①遠家殘忍隊「就近掠」距離 nuance 丟失（restock_need 非距離感知→返家；loot 稀有，backlog「restock_need 距離衰減」）②severity gate 簡化（靠 drive 量級，warning「不放棄當前 task」nuance 移除，實測 churn 未增）③unified produce 隊絕境也得返家補給候選 + unified 大軍（pop>15）絕境無覓食候選（generalize/pop 守衛副作用，believability 改善/可接受）。調 4 處既有直呼點 assertion（同義：pref→weight、契約變：非商隊絕境返家；退化：Task5 LOOT→RETURN_HOME 已知）。結果：headless 全綠、world_sim 2yr 無 mass starvation（存活 6→5 噪內）、loot dest=0（無 over-loot）、coin_eq 0、framework S1-S6 PASS。spec/plan `2026-06-25-p2b1-survival-selection-unify`。**解鎖 P2b-2**。
      - **P2b-2 全退 entry（待，耦合 P3/P4）**：全退 `_evaluate_survival`/`_trigger_survival` entry（non-unified survival 整路由 engine entry）需軍隊 attack/threat/vendetta 入 engine = P3/P4 後。`_evaluate_solo` survival scoring（camp/join 手寫）仍雙 owner，並此塊或獨立清。
  - **P3 混合協調 seam ✅ done**（merge，他域鏈第四步）：unified 隊（merchant/produce）經引擎響應派系 stakes directive。**探碼揭縫**：`_decide_unified` 完全忽略 faction goals；non-unified 已響應（802-827）；霸主決策步**已存在**（`_update_goals:687-705` 攻擊 gate=野心/好戰/readiness/belief-strength=稀有蓄意吃 belief，守 ruling §3）。**做**：`DecisionContext` 加 faction directive/target/loyalty 欄（gather 讀 `f.goals` 攻擊 + `_nearest_independent` + loyalty 注入 `leader_values["_loyalty"]`）；`faction_duty` term（WHETHER）+ `attack_drive` term（HOW 染色）+ **共用脫軌逃閥因子 `_duty_factor=clampf(loy−max(0,野心−0.5)×DEFECT_K,0,1)`**（faction_duty weight 與 attack_drive 齊受 loyalty 調=低忠誠高野心 member 兩驅力齊壓 0=「這不是我的仗」）；啟用 `攻擊` engine option（REGISTRY `[[faction_duty,faction_duty],[attack_drive,attack]]`、applicable=directive=攻擊+有 target、to_task=TASK_ATTACK+combat_target）。**believability 2 不變量寫 invariants.md**（混合協調段）：①頂層決 WHETHER/人格染 HOW（攻擊 util=`duty_factor×(FACTION_DUTY_DRIVE+attack_weight×ATTACK_DRIVE_BASE)`，同忠誠下好戰>溫和）②脫軌逃閥（faction_duty=加權 term 非 hard override，by construction 非 100% 服從）+ 日常個體（貿易/掠奪/scout/survival 無 faction_duty）+ 危時 survival 碾壓。**非 dormant**：`攻擊` directive 既有 producer（`_update_goals`）+ non-unified 已示範消費。**偏離 plan**（認可）：`attack_drive` 亦乘 `_duty_factor`（plan 寫 flat 0.3 會讓 rebel 仍攻擊=逃閥失效）。**scope 緊**：只 `攻擊`（徵收/外交/立國/結盟/大徵收=後續 slice）、不碰 non-unified、不改霸主決策、無新脫軌機制、TC3 未接（feud 仍走 vendetta PRIO_VENDETTA 獨立路徑）。結果：headless 3 測 PASS（faction_duty loyal=0.90/rebel=0.00、soldier→ATTACK/rebel→建設/peace→建設、好戰染色 u_f=0.314>u_m=0.103/餓→覓食）、coin_eq 0、framework S1-S6 PASS。**⚠ world_sim 該 run 無派系觸發攻擊 directive**（僅 1 faction 商業 archetype 未達 gate）→ **協同戰 feel 改由構造場景驗（藍圖 ruling 2026-06-26 §3「要」）**：`scripts/debug/p3_war_scenario.gd`（好戰霸主派系 A 多 persona member + 和平商業 B + 弱敵）量測，**4 條 ruling feel 全綠**——跟戰 3/4（忠誠者跟、叛逆脫軌）、人格染色（忠誠好戰 util 1.70 > 忠誠溫和 1.44）、不 over-war（全世界僅 3 隊出兵=派系 A 成員，B 不被拖入）、脫軌叛離真發生（低忠0.15+高野0.9→不參戰）。**setup 教訓**：攻擊 directive 需 leader 過 strength gate（`own_armed≥敵 armed_est×0.8`）→ leader 須設 `armed_anon_ratio`（weapon 在 resources 沒裝備到人時 own_armed≈0）。**待藍圖**：faction_duty 偏強協同（忠誠溫和也跟，util 1.44）→ 強協同(A)/鬆協同(B) feel 方向，調 `FACTION_DUTY_DRIVE`（handback `p3-war-feel-report`）。皆 TEST VALUE。spec/plan `2026-06-25-p3-hybrid-coordination`。**解鎖 P4 stakes options**。
  - **P4 頂層 stakes options**（架 P3 上）：主動開戰攻擊（稀有+蓄意+吃belief+readiness gate）→結盟/外交→立國深做→大徵收動員。**解鎖 TC3 + 誘殺閉環**。
  - **P5 戰俘**（耦合 combat-unification E-2 撤退門檻/意志，跨 arc）。
  - standing flag（非阻塞）：履約脫 0 unseeded → 經濟底 🟡，待 seeded harness 確認穩定成交。
- **🏛 框架驗證套件實作完成（B，merge `1a5eee3`）**：Part1 TC2(survival=高權重輸入非latch)/TC5(經濟+情報為輸入) headless 行為測過（TC1/4/6/7 早過；**TC3 feud→脫軌攻擊需引擎攻擊 option=他域 skip**）。Part2 `scripts/debug/framework_validation.gd` harness — S1立國/S2feud+vendetta/S3scout/S4ambush/S5mint/S6經濟閉環 **全 PASS（證 6 魂可 fire）**。default world_sim fire:faction_found/feud/order_fulfilled；vendetta/scout/mint/ambush default 休眠（harness 證可觸發,記 known_issues backlog）。**S5 mint 揭真 gap**：碼可運作(harness mint=1)但 default 無金礦 tile + 無 AI 建鑄幣廠路徑=供給斷（G1a mint arc）。回歸全綠。
- **🏛 Pattern B 所有權 banker 全 5 池完成（autonomous goal-run）**：state-fight-scope Pattern B（一值多寫、delta vs 絕對 set 無銀行）全收編——各池單一 owner banker + 禁裸寫(grep 驗) + coin_eq/InvariantAudit 守恆閘：① **UnrestBank**(`3a883a6`,unrest_turns 14 寫)② **LoyaltyBank**(`6bfc719`,loyalty 25 寫,cap 參數保 clamp)③ **AnonTreasuryBank**(`05ba648`,anon_treasury 24 寫,原子 transfer 守恆;揭既有 off-map leak 記 known_issues)④ **OutpostOwnerBank**(`7631aa3`,outpost_owner 16 寫,集中化保 last-writer-wins)⑤ **ResourceBank**(`3a72fc9`,team.resources 124 寫/21 檔,簡 wrapper 保原數學=守恆 by construction)。各跑 2yr world_sim invariants=0。**Pattern B 完成 = 框架債「所有權圖縫」收編**。refinement：outpost race-policy/pending_owner_change_tick 退役、coin_eq 註冊進 InvariantAudit、transfer 原子抽象（非守恆必需）。
- **🏛 框架 arc 後續 goal-run（autonomous，照藍圖）**：① **gate→權重**（merge `b15297a`）貿易去 is_merchant 硬 gate+economic_opp 角色因子 0.3=清藍圖 gate 債第一條（生產隊能 roam-trade 但很少）。② **food 買單側**（merge `a4c4cf8`）缺糧隊發 food buy=食物雙向市集（補 WS-1 只賣）。③ **性別資料+生育需兩性**（merge `e3828d4`）PersonData.sex+anon_female_ratio+balance gate=全男隊內部不繁衍 emergent（④Trait 前置）。各跑 2yr world_sim+回歸全綠+coin_eq/InvariantAudit 0。**⏸ 他域遷入（攻擊/掠奪/徵收/結盟/立國/scout/誘殺/鑄幣）= 未決**：撞協調語意 WHAT（faction-goal 頂層 vs 個體人格驅動 + 主動開戰 feel）→ handback 藍圖求裁（`otherdomain-coordination`），暫緩。**耦合他域待 ruling**：戰俘（capture 需 combat）、survival 全隊退役+loot/join 還經濟隊、驗證套件 TC2/3/5+S 魂場景（隨域驗）。

- **🏛 統一決策框架 arc — 統一隊 survival 切片 ✅（merge `b57c79c`）→ 履約首次脫 0**：survival 遷引擎第一切片。真根（measure-first 三次剝洋蔥，含我兩次估算錯=carry-cap 漏 food weight 0.1 / restock util 沒實算→作廢一 spec、見 `[[feedback_avoid_rabbithole]]`）= 引擎 utility-survival **無牙**（survival_pressure cap 1.5 < 貪婪 trade ~1.8），逼停貿易的是引擎外 785 latch；商隊離家無糧源 drift 餓死。修：survival-class term **量級重標度**（food≥3→0、food<3→`4×(3−food)` 碾壓 trade；restock_need `1.5×(5−food)`）+ survival 威脅化（threat_pressure，hunger 走覓食/返家補給）+ 覓食接真格 + **切片邊界**（unified 隊跳舊 `_evaluate_survival`、`uses_unified` hoist 到 member/solo 的 IDLE/survival gate 前 = 退 785 latch；非 unified 隊舊 survival 原樣零改）+ 返家補給 option 地基（先前 merge `c97fc5b`）。**藍圖裁定:角色=權重輸入非硬 gate**（撤回 gate 設計、TC7 原樣）。**結果**：world_sim `order_fulfilled 0→5`、`restock_chosen 0→131`、`[Market]成交` 常態、TC1/4/6/7 原樣、coin_eq/InvariantAudit 0。**believability 缺口已修（dispatch-fallback，merge `1181b67`）**：`DecisionEngine.rank`(util 降序+index tiebreak=decide 行為不變) + `_decide_unified` 退次佳「可派」option（覓食無格→退返家補給/建設→不凍）。T1 無家隊修前 d30 凍死→修後動作存活 90d+（藍圖標記 2 達標：無凍死 believable 退化）。spec/plan `2026-06-22-dispatch-fallback`。**⚠ order_fulfilled 為 unseeded world_sim 變異**（某 run 0 某 run 5，[[reference_multi_sanity_unseeded]]）→ 機制運作（restock_chosen 維持/engine_survival 降）為準、別當絕對閾。**債**（藍圖標記，框架完成塊清）：loot/join 必還經濟隊、is_merchant 硬 gate→權重、舊 survival 全隊退役。spec/plan `2026-06-22-unified-survival-slice`。
- **🏛 統一決策框架 arc — sub-project A 經濟生產隊納引擎 ✅（merge `e6433e9`，foundational 第二塊）**：商隊已接（sub-proj1），本塊把經濟生產/定居域也接同一 `DecisionEngine`（閉經濟環另一端）。三改：①`uses_unified` 加 `TAG_PRODUCE`（生產隊 member+solo 兩 gate 都導向 `_decide_unified`，舊生產者短路=單一 owner）②`applicable()` 角色守衛——貿易加 `and ctx.is_merchant`（roam-trade 限商隊角色，生產隊原地掛單賣不漂）③建設改恆候選（bootstrap 無據點建新+升級，無據點生產隊不被困）。新 context 欄位 `is_merchant`。**判別子用角色 tag 非據點**（商隊也可能有 outpost，`not has_own_outpost` 會誤殺商隊貿易爆 TC1/TC7）。下單不動（`tick_team_orders` 自動 cadence，獨立決策切片）。**驗收**：TC1(changes=0)/TC4/TC6/TC7(建設/貿易/駐守 3 分歧) 全過、role applicable + unified seam OK、headless 全綠、coin_eq=0、InvariantAudit 0（只改決策面）。**履約未 robust 脫 0**：measure-first 證生產側 plumbing 對（生產隊 d60 起原地駐守 `task=生產` 不漂、糧倉 vault food≈1996 可掛單、`order_placed≈3300`/`board_register≈3057`），但**卡商隊 survival latch**（`merchant_survival≈164`、商隊幾乎不出門 seek_market→不 co-located→`order_fulfilled`=0~1 flaky）= 既有 WS-2b 探針標記的真壓制因（faction_ai:786-789，handback #6 §2），出本塊範疇。spec/plan `2026-06-21-economy-settle-unified*`。**系統決策**：商隊 survival 參數修列 sub-project B 首序（履約真脫 0 前置）；生產 task owner 引擎 vs AmbitionLadder rung-task 重疊待統一傘收編。TEST VALUE 沿用。
- **🏛 統一決策框架 arc — sub-project 1 決策引擎+商隊切片 ✅（merge `9c66a7e`，foundational 第一塊）**：經濟死真根 = AI 決策框架不統一（6 子系統各自 latch task 互搏，無一隊一連貫決策）。建 `DecisionEngine`（utility weigh：Σ 人格權重×驅力 term + 承諾慣性，argmax，單一生產者）+ 商隊-tag 切片（`uses_unified` seam，舊 faction_ai member hoist/solo 生產者跳過）。新 `scripts/simulation/decision/`（decision_engine/decision_context/options/terms）。term 複用既有（effective_food/best_arbitrage/team_strength/feud/_merchant_trade_target）= 非重寫。**驗收全過**：TC1 震盪消失（商隊承諾 25+天零震盪、`[unified]` 單一 owner、THE bug 死）、TC4 野心有牙（野心高→建設/低→駐守）、TC6 權衡、**TC7 分歧硬 bar 過（霸主→建設/商人→貿易/隱士→駐守，人格分歧 by construction）**。headless 全綠、coin_eq=0、InvariantAudit 0（只改決策面、不碰守恆）。**履約仍 0=正確**（兩商隊定居人格→引擎讓人格贏 tag→選治理/駐守，正是修 tag-vs-人格本意；S6 履約脫 0 需擴定居隊=後續子專案）。w_term retune（ambition floor 去除防抹平、ambition_drive 放生產/建設非貿易）= 分歧核心。spec/plan `2026-06-21-unified-decision-engine*`。**後續**：Pattern B 所有權 banker、他域遷入(戰鬥/外交/立國/scout/鑄幣=各加 Option row)、S6 擴定居隊。TEST VALUE：COMMITMENT_BONUS=0.3/w_term 映射。
- **經濟 arc WS-2c food accessor 單源 ✅（merge `bb63f18`）**：破商隊 survival 二階死鎖。根因 = WS-1 把定居隊 food 搬糧倉只改消耗（resolve_consumption 讀合併池）、**漏改 10+ AI 決策讀者**（仍讀 team.resources food=0 → 定居/商隊自以為餓 → 永卡 survival/return_home → 永不貿易）。修：`ResourceSystem.effective_food(state,team)` static accessor（team food + 自家糧倉，複用 `own_granary_tile`），路由 10 決策讀者（survival:2070/solo FLEE gate:1001/急徵稅/復工/hungry/ambition…）。純讀取改、**不碰守恆**。headless 全綠（4 新測 + 既有飢荒鏈 OK）、coin_eq=0、InvariantAudit 0。**world_sim 重大進展**：`merchant_survival` 18837→~0、`market_arrive` 0→100-250（商隊終於出門到市集）、世界穩 6 隊無過餓。**但履約仍 0%**——下一層 `board_read≈0`（站上市集讀不到別隊單，見 known_issues）。框架教訓 [[project_framework_seams]]：搬資源位置=所有讀者跟著走。plan `economy-ws2c-food-accessor`。
- **經濟 arc WS-2b 市集訂單可見性 ✅（merge `2ee85bb`）**：破訂單可見性死鎖（WS-1/2/3 merge 後 world_sim 量測仍 0% 的真 root——訂單只在發起隊 team_known、跨隊只靠碰面傳播、商隊只在有 arb 才出門→死鎖）。修：`tile.market_orders` 看板（訂單登錄 outpost tile）+ `read_market_board` 抵達親讀（firsthand honest，`outpost_level>0` 守衛=無在場讀不到，**守 G3 傳播原則**：轉述他隊仍走既有 propagate 失真零改）+ `sim_runner._step3c` arrival 讀步 + 商隊無 arb 巡最近市集 `_nearest_market_outpost`（破死鎖=有理由出門）。`_sync_board` 保看板與 active_orders 一致（無幽靈單）。純資訊+派工，**不碰守恆**。headless 全綠（market board register/read/seek market/trade chain OK fulfilled=1）、coin_eq=0、InvariantAudit 0。**機制確定性測通，但 world_sim 仍 0%**——卡上游商隊 chronic survival（market_arrive=0/merchant_survival=18837，疑二階死鎖），= 下一個 measure-first WS（見 known_issues）。留 4 探針驗收。**教訓**：WS-2 的「[Market]5→8」是 game_sim_test 量的（隊密集碰面遮蔽 bug）→ 經濟驗收必走 world_sim。plan `economy-ws2b-market-visibility`。
- **經濟 arc WS-3 carry cap 硬+馬車 ✅（merge `17940d0`）**：carry cap 從「只軟速度懲罰」→ 硬上限（intake 受限）。`movement_system` 新 `remaining_carry_space`/`carry_space_for_res`；enforce 兩處 intake：①`interaction._attempt_trade_direction` 買方進貨 qty 受 carry 空間限（+coin 取 min）②`resource_system._collect_from_tile` else 分支（移動無 outpost 隊）gain 受 carry 限、超額留 tile。`get_carry_capacity`（含馬車/獸 BONUS）從裝飾→load-bearing。**intake-cap at source = 守恆安全**（貨留 tile/seller、零 drop/零 coin 觸碰）。headless 全綠（carry cap trade/forage/throughput OK + 既有覓食/絕境/飢荒/trade 全綠=無凍結）、coin_eq=0、InvariantAudit 0。**throughput 證**：確定性測 無車進貨=50→2 馬車=130（馬車 load-bearing 確認）；world_sim 移動隊不再無限囤、無凍結。**systems ack 偏離**：`coin` 改 weightless（`_resource_weight: coin→0.0`）——coin 原 default weight 1.0 → 富買方 carry_space=0 → 買不了 → **凍結貿易**（反 WS-3 意圖），coin 非貨物 → weightless 正確且回歸必需（連帶移除「囤 coin 拖慢移動」artifact，回歸全綠）。spec `economy-marketplace-caps-design`(WS-3)、plan `economy-ws3-carry-cap`。TEST VALUE：BASE_CARRY=10/MOUNT_BONUS=15/WAGON_BONUS=40（沿用）。
- **經濟 arc WS-1 食物糧倉+硬上限 ✅（merge `cde372c`）**：殺食物幽靈囤（`resource_system:213` uncapped）。三修：①`_collect_from_tile` food route 進 outpost public_storage capped（像礦，over-cap drop=food sink）+ `outpost_system` food 專屬 cap array（staple 放大 civilian [2000/6000/18000]）②`resolve_consumption` 從「team.resources+自家糧倉」合併池吃（food 在哪都不餓死）③food 加入 `_ORDER_ELIGIBLE_RES` + `tick_team_orders` 糧倉滿(>cap×FOOD_SELL_RESERVE_RATIO 0.5)發 food sell 單（鐵則：cap 改變決策=滿了賣 fire）。純 food sink，**不碰 coin**（CoinAudit delta=0）。headless 全綠（food granary cap/consume from granary/food surplus sell OK + **既有飢荒測試全綠=無誤餓**）、coin_eq=0、InvariantAudit 0。world_sim：囤糧崩（4-5萬幽靈囤→food 全在糧倉 capped≤18000）、food sell 單 fire（227 筆）、無過餓（FoodLedger income==burn）。**⚠ 食物稅語意變更（systems ack）**：food 進糧倉後不走一般稅 private/public split（=整批入自家村庫，等義 `_apply_normal_tax` 原註「採集者即 owner→自己存自己村」）；implementer 改 4 既有稅測 fixture（split 機制覆蓋移到 material，**未放寬斷言**）。**UI 後續**：定居隊 team.resources food 現=0（在糧倉），面板讀 team food 會誤判「沒糧」→ 顯示層需讀合併池（記 known_issues）。food **買**單側未做（只 sell；飢荒隊買 food 待後補）。spec `economy-marketplace-caps-design`(WS-1)、plan `economy-ws1-granary`。
- **經濟 arc WS-2 市集+角色卡死 ✅（主角，merge `81bd56b`）**：藍圖裁定 B 市集後首個落地——讓 NPC 貿易決策真 fire。三病三修：①`order_system.post_order` 會合 pos route 到下單隊最近自家 outpost 市集（`_market_pos`，固定點，解 co-location，非隨隊移動舊 snapshot）②`faction_ai._assign_member_tasks` 商隊-tag member 有真 arb 單時 hoist 貿易（搶在徵收/外交 preempt 前）③`_evaluate_solo` 商隊-tag TASK_TRADE 加 `MERCHANT_TRADE_BONUS`（勝 CAMP/尋家，FLEE 生存仍優先=絕境不貿易）。**僅商隊 tag**（軍隊/生產/定居派工不變）。純決策/派工/order pos，**不碰 resources/coin**（成交走既有 `_resolve_market` 守恆）。headless 全綠（market routing/merchant dispatch/trade chain end-to-end OK）、coin_eq=0、InvariantAudit 0。**證主角通**：world_sim `[Market]成交` 2 年 5 次→8、履約率 0%→1.5%、商隊確被派貿易、無 over-trade（趨勢煙霧，world_sim 非確定）。履約絕對值受 throughput 限（一次搬多少=WS-3 carry cap）。spec `economy-marketplace-caps-design`、plan `economy-ws2-marketplace`。TEST VALUE：MERCHANT_TRADE_BONUS=0.5/hoist 門檻。
- **#1 經濟閉環 plan-1 訂單履約 ✅（merge `186e433`）**：訂單流接最後一步——`interaction._resolve_market` 交易後 `OrderSystem.settle_orders` 按交易窗（absorb/spillback 間，team.resources=完整持有）內 res 淨變沖 `active_orders.qty_remaining`、填滿移除 + 點亮 `g1.order_fulfilled`/`g1.arb_hit`（Probe 早有這倆死指標於 ProbeSummary 履約率/命中率公式，本 plan 補 bump）。**純記帳**：零 resources/coin 變動 → coin_eq/InvariantAudit 守恆無關（回歸 0 為形式確認）。不新建 order-directed 交易（估值交易負責搬貨，結算只認帳；供需不 align→撲空留單=emergent）。單測證機制正確（履約/部分/撲空/sell 對稱）。headless 全綠（`order fulfillment OK`）、coin_eq=0、InvariantAudit 0。spec/plan `2026-06-20-order-fulfillment*`。**⚠ 上游發現（見 known_issues）：world_sim 該 run `arb_attempt=0`、`[Market] 成交=0` → 商隊 runtime 根本沒交易 → 履約率仍 0%（非結算 bug，settle 單測正確）。order/trade 迴路 runtime 半 inert，需 measure-first 查根因（商隊沒成形/message 沒到/range 外）。** plan-2 腐壞/儲限 spec ready（未派，待藍圖 feel + 此上游釐清）。
- **A 類 feud 放寬 ✅（merge）**：血仇由「被侵害」本身形成（非只倖存被搶）+ 滅族 faction 餘部繼承 + severity×個性 gate。集中 `NpcAiSystem.form_feud`（唯一形成點：`severity × (FEUD_BASE + 義氣×0.7 + 好戰×0.4)`，`FEUD_MIN=0.30` gate 擋例行劫掠/寬厚放下/公平交手）+ `spread_feud`（同 faction 餘部 ×0.6，事件當下 erase 前傳；**非血親**=待 ④Trait/家族樹）。現有 3 觸發（looted/extorted/betrayal）改走 gate（Probe.bump 移進 form_feud 不雙計）+ 新增 subjugate 觸發 + 屠村/戰敗滅團 call site（subjugate spread 必在 `set_team_faction` 前）。`_activate_goal` 轉 static。複用 RelationGraph feud 邊，零新資料結構、不碰守恆。headless 全綠（`feud gate OK`/`feud spread OK 餘部 0.64`/`massacre wiring OK`、既有 `_test_g2a_memory_writes_edges` 受害者義氣 0.9 跨閾對齊未放寬 gate）、coin_eq=0、InvariantAudit 0。**⚠ world_sim 重量驗不到 feud — seed 77 該 run 零戰鬥**（非 gate 太嚴，無侵害事件可觸發；world_sim 非確定性，他 run 有戰鬥）→ feud emergent 量遞延 #1（經濟壓力→搶資源→更多侵害）+ scout/ambush 場景。TEST VALUE 暫不調（無有效重量數據）。spec/plan `2026-06-20-feud-broadening*`。
- **#0b 升 named 忠於來源 tier ✅（merge `c596258`）**：補 #0 戲劇尾巴的晉升稀釋缺口。`generate_for_team` 原呼 `generate()` 不看 tier + `kill_random` 按 count 抽（平民最多）→ 菁英 anon 升 named = 隨機低技能、老兵本事蒸發。改：`kill_random(team,1,"promote",PROMOTE_TIER_WEIGHT)`（偏高 tier=提拔精銳）用回傳取來源 tier → `_apply_promotion_skills` 依 tier 設戰鬥/戰術/統領帶（`maxf` 不蓋 archetype 尾巴；seeded rng）。複用 AnonTierSystem 零改、簽名不變、不碰守恆。headless 全綠（`tier fidelity OK 菁英戰鬥=0.76/平民=0.18`、Task7 平民升 coin share 不變）、coin_eq=0、InvariantAudit 0。非戰鬥技能刻意不動。TEST VALUE：PROMOTE_TIER_WEIGHT/SKILLS 帶值。spec/plan `2026-06-20-promote-tier-fidelity*`。**⚠ 量測發現見 known_issues：world_sim 非確定性（ProbeSummary 不可作回歸/歸因閘）**。**#0 全收（#0 尾巴 + #0b 晉升忠 tier）**。
- **#0 world-gen 戲劇尾巴 ✅**：generate 窄帶凡人 + per-person archetype 狂人簇（霸主/屠夫/謀士/懦夫）+ config 種極端 leader。重量證 root（立國 0→1、識破裁決 0→7，純人格值無場景）。詳 `world-gen-dramatic-tail*`。
- **G3-targeting 攻擊/掠食目標選擇讀 belief ✅ → 誘殺脊椎閉環**：補 G3d-2 揭的漏網——`find_prosperity_prey`/`_find_weakest_prey` 本直讀 prey 真 population/resources（god-view），G3d-1 gate 只調「commit 把握」(uncertainty)、不調「選誰」(value)。本 plan 補 value 面：richness/weakness/pop 一律經 `BeliefSystem.best_estimate`，`has_belief` 守衛無情報不評估（**禁 fallback 回真值**，否則 god-view 回潮）。weakness 吃 `armed_est`（tier2 偽裝低報載體，退 pop_est）、richness 經 `_belief_richness`（tier2 sum/100 → resource_scale 粗估 → 0）。自身真值(`team.population`)照讀、位置 reachability 讀真位（物理 OUT）。**誘殺 emergent**：偽裝/失真 relay → 假弱 belief → 選假弱目標 → 戰鬥按**真**實力結算 → 莽者踢鐵板、慎重者 scout(G3d-2)看穿真強→不選→避誘殺。**至此 G3 誘殺迴路真整條落地**：偽裝/失真(G3c)→選假弱目標(本)→gate 把握(G3d-1)→scout 查證或莽者照衝(G3d-2)→戰鬥按真實力結算。回歸：headless 全綠（prey select belief / survival prey belief OK）、coin_eq=0、InvariantAudit 0、`[ProsperityAttack]`+`[SurvivalLoot]`+`[Scout]` 並見（不凍結）。行為非保留（選擇吃 belief→偽裝/失真改變誰被打）。新測置尾避擾前段 unseeded RNG 序。TEST VALUE：`_belief_richness` 粗細混排、survival food 門檻（belief 無 food_est 不擋）。延 post-measure（同 G3d-2 OUT）：威脅(防禦)uncertainty、team_known claim 化、情報戰 C。
- **G3d-2 scout 主動查證 + uncertainty cred-weighted ✅ → G3 核心迴路落地**：慎重者的**被動按兵**(G3d-1)升級為**主動 scout 查證**——攻擊性 commit gate-fail → dispatch `TASK_SCOUT`(move_target=prey best_estimate 位)；斥候移入視野→vision 寫親見→下 prosperity cadence uncertainty 塌→`release` scout 後 try_set ATTACK（同 PRIO_DISPATCH 須先 release 換手）。前提修：**uncertainty 重定義 = credibility-weighted**（`clamp((1−top_eff_cred)+cred 加權值分歧,0,1)`），親見高 cred 主導→壓謊→scout 可收斂（舊 raw `(max-min)/max` 下親見壓不掉舊假 claim → 永不收斂）。莽者(低慎重)恆過 gate→不 scout→攻假 belief→誘殺（不變）。收斂保證：scout 中允許重評 + `SCOUT_TIMEOUT` 逾時 release（防永 scout 卡死）；prey 親見顯強→find_prosperity_prey 不選→自然放棄（避誘殺）。**至此 G3 核心迴路全鏈落地**：情報不對稱(G3a/b)→可信度/時效(G3c-1)→技能識破/觀察(G3c-2)→決策風險 gate(G3d-1)→查證/誘殺(G3d-2)。回歸：headless 全綠（cred-weighted uncertainty / scout verification / attack gate OK）、coin_eq=0、InvariantAudit 0、1000 Tick、`[Scout]`+`[ProsperityAttack]` 並見（不凍結、scout 收斂非永卡）。行為非保留（uncertainty 公式 + scout 行為）。TEST VALUE：SCOUT_TIMEOUT=TICKS_PER_DAY*3、uncertainty top/spread 權重、（既有 GATE_CONF_LOW/HIGH 沿用）。
  - **延 post-measure（本 plan OUT，待核心迴路量測後評估）**：①**威脅(防禦)uncertainty-gate**（§8，極性與攻擊相反，enrichment）②**team_known 事件謠言 claim 化**（§3「主味」獨立 arc，碰 WHAT → **請藍圖確認延後**：核心隊伍情報迴路先量，event 謠言獨立排）③斥候被抓/被餵假（C 情報戰）。
- **G3d-1 決策讀 uncertainty + 風險 gate ✅**：belief 層（G3b/c）首度有決策後果——攻擊性 commit 從「只讀 best_estimate 單值」→ 讀 (best 值 + uncertainty)，按 `個性慎重 × uncertainty` 風險調節（WHAT §7）。共用 gate `BeliefSystem.confident_enough(state, 觀察者, 目標, 慎重)`：`confidence=1-uncertainty`、`threshold=lerp(GATE_CONF_LOW(0.0),GATE_CONF_HIGH(0.6),慎重)`。插**攻擊性主動 commit**：faction_ai prosperity attack + survival loot(`_find_weakest_prey`)、diplomatic demand_tribute。不確定且慎重→本 tick 不 commit（**被動按兵**，下次 cadence 重評）；莽者門檻低→照衝→**假情報誘殺**（魂訊號首度由決策生）。survival loot gate 失敗 → 落回其他絕境路徑（不凍結）。**不 gate**：威脅(防禦,極性反)、vendetta(私仇 G2d)、結盟/求和。既有無-belief 攻擊測試補親見對齊。headless 全綠（confidence/attack/diplomacy gate OK）、coin_eq=0、InvariantAudit 0、200 Tick sim **仍有攻擊/掠食發生**（gate 不凍結 AI）。行為非保留（攻擊 commit 受 uncertainty 調節）。TEST VALUE：GATE_CONF_LOW=0.0/GATE_CONF_HIGH=0.6。
  - **G3d-2 待**：①scout 主動查證迴路（不確定→dispatch scout→親見壓謊→才動，加速慎重者；裁決級識破觸發查證在此接）②**威脅(防禦)uncertainty-gate**——**告知藍圖**：WHAT §8「威脅」延 G3d-2，因防禦極性與攻擊 commit 相反（不確定威脅→更該警戒/查證，非按兵）→ 與 scout 查證一併設計較一致 ③team_known 事件謠言 claim 化（G3d-2/專案）。
- **G3c-2 技能識破 + 觀察吃技能 ✅**：技能 = 理解力（WHAT §6）。**識破**：收 distorted claim 時 `BeliefSystem.detection_discount(我 max(偵查,計謀), 對方計謀)` 折 stored credibility（信假1.0/生疑0.5/裁決0.2）→ best_estimate cred 排序消費（謊低於誠實/親見）。**非 un-distort**（claim.value 不動，只壓信）→ 高計謀大說謊家騙過低技能、笨拙謊對高技能透明。is_suspicious 由分級寫（降 UI/G3d flag，消 G3b dormant，取代舊 randf 塊）。**觀察吃技能**：`observation_noise(base, skill)` 疊噪——vision pop_est 吃偵查、interaction armed_est 吃戰術 → 低技能親見也誤判，**cred 仍 1.0**（深信的錯值）。兩 helper pure static 進 `BeliefSystem`。headless 全綠（detection/observation OK）、coin_eq=0、InvariantAudit 0、1000 Tick。行為非保留（識破排序 + 觀察噪 = 真行為變）。TEST VALUE：DETECT_SCHEME_GAIN=0.8/SUSPECT_T=0.3/ADJUDICATE_T=0.6/SUSPECT_MULT=0.5/ADJUDICATE_MULT=0.2/OBS_SKILL_NOISE_GAIN=0.5。**G3c 全收（c-1+c-2）→ 魂的「源質+理解力」層完成；缺決策消費（G3d）**。OUT：決策讀 uncertainty + scout 主動查證（G3d；裁決級觸發查證在此接）、team_known 謠言 claim 化（G3d/專案）、戰術識破伏兵（戰鬥域 OUT）。**watch（記 known_issues）**：觀察吃技能 → 親見 truth 可能錯 → reconcile_firsthand 拿錯 truth 比 relayed → 可能誤罰對的 source；balance watch。
- **G3c-1 可信度公式 + 身份信任 + 類型基準 ✅**：claim 可信度 G3b interim flat → 真公式 `effective_credibility = source_credibility(類型基準 CRED_BASE × 身份信任 × 跳數) × 時效衰減`（寫時存 cred、讀時乘 time_decay）。`best_estimate` 改排 effective（新鮮勝陳舊）。source_type 正名真來源類別（親見/隊友/商旅/流民，relay 依 giver；distort 另存 flag）。身份信任 = `TeamData.known_reputations`（team→team 動態，覆寫 HOW spec trust 邊，不開 RelationGraph person 邊）；親見比對 relayed pop_est → `update_reputation(±)`（準升騙降，被動查證，record_claim 單一 choke）。修 G3b relay 雙重 HOP。headless 全綠、coin_eq=0、InvariantAudit 0。行為非保留（best 排序變）。TEST VALUE：CRED_BASE/TRUST_FLOOR=0.5/BELIEF_HOP_DECAY=0.15/CRED_AGE_FULL_DECAY=30天/CRED_TIME_FLOOR=0.2/TRUST_DELTA=0.05/reconcile 門檻。OUT：G3c-2（技能識破/觀察吃技能）、G3d（決策讀 uncertainty + scout 主動查證）、team_known 謠言 claim 化。known_reputations coupling（外交/belief 共用）= interim，量測後評估拆專用 trust。詳見 known_issues G3。
- **G3b multi-claim 儲存 ✅**：`team_intel[obs][tgt]` 單 dict → Array of claim（值/源/時效/可信度/失真，不覆蓋）。寫端（vision/interaction 親見、message 傳播）遷 `BeliefSystem.record_claim`：同源更新、跨源 append、停 confidence-max 覆蓋；`best_estimate` 聚合最高 credibility、`uncertainty` 換 claim 分歧、caps 剪枝。讀端 sim_bridge/inquiry 收尾走 accessor（`known_targets`）。讀容錯舊 Dict。改動全藏 BeliefSystem accessor 後（G3a de-risk）→ 決策讀者零動，但多源時值會變（行為非保留：多源不覆蓋 + 分歧不確定為真 WHAT 變化）。headless 全綠、coin_eq=0、InvariantAudit 0、1000 tick。TEST VALUE：MAX_CLAIMS_PER_TARGET=4 / PER_OBSERVER=200 / uncertainty 欄選 population_est / relay cred interim。下一步 G3c（可信度 trust 公式 + 技能）/ G3d（決策讀 uncertainty + 查證）。詳見 known_issues G3。
- **G1d 商隊訂單驅動 + 短缺買單 ✅（閉環 G1b）**：商業 archetype 隊 targeting 改讀 `team_known` 訂單（`OrderSystem.best_arbitrage_order`，殘缺/可失真情報），取代 `_find_trade_target` 的 `team_discovered` 上帝視角（後者降 fallback，最終應刪，符「目標決策讀殘缺情報」總則）；`tick_team_orders` 短缺發買單（料/武器 < `SHORTAGE_QTY`）→ G1b infra 半 inert 解除（賣盤有 reader、生產買單有來源）。到場履約走既有 interaction 同格 trade（守恆）。撲空 = 訂單 stale → `local_value` glut（emergent 無新機制）。headless 全綠、game_sim_multi 21600 tick 無崩潰、coin_eq=0、InvariantAudit 0。剩 refinement：部分履約記帳、distort×params、信用幣(③G3)、arbitrage 公式調平衡。詳見 known_issues G1。

## 📍 前狀態（2026-06-17）

- **玩家動作 parity 已 merge（`81e245b`）**：QA P5 走查重frame C-1~C-6（NPC task=AI 抽象 ≠ 玩家直接控,真對稱=動作 parity）。新 `_action_train`（一次性 coin 30→`add_exp`+`try_promote`,玩家版比 NPC 完整）+ `_action_camp`（紮營 Y版:免材料/無即時糧只抬cap/距離spacing/限時建造,reuse construction）+ **panic 收口**（reaction 恐慌橋加 `leader_id!=player_id` 守衛,玩家主隊不被劫持移動,其餘恐慌效果保留）+ 玩家隊狀態列「任務:」→「狀態:」。spec `2026-06-16-player-action-parity-design`、plan 同名、handback 同名。功能經 key-injection driver 端到端驗（訓練/招募/紮營）。
- **QA P5 修復已 merge**：B-1 收留撞 pop_cap 守恆（食物按量測 delta 扣、msg 報實際併入,不謊報）+ A-1 記名招募在 TextUI 主場景可達（消費 recruit menu payload）。
- **W4 promote 層1 修（`4d1e540`）**：`training_system` 補 `try_promote` tick caller（原只 add_exp 永不升階,NPC 一旦訓練即升）。層2（NPC AI 鮮少選 TASK_TRAIN）遺留。
- **NPC crude_camp 即時糧移除（`ad67869`）**：A/B 量測非 load-bearing（died=0,pop 不掉）→ 移除即時種子糧(留 cap),恢復絕境稀缺,與玩家紮營版一致。
- **W8 coin 產出鏈休眠（2026-06-17 量測新發現）**：純coin 鑄造Δ=0、ore 挖礦Δ=0 → 金銀礦從沒挖、鑄幣廠從沒用,coin 純零和集中。詳見 known_issues W8 / roadmap。
- **refactor R1-R6 + known_issues 瘦身 479→225**（已修 42 項移 `docs/archive/resolved_issues.md`）。
- **P3 全動作覆蓋確認已達**（50/50 覆蓋審計 + ui_flow 面板測綠）;**Bug2 欠薪後果確認已存在**（reaction N3_defect 離隊鏈,原「未做」=stale）。
- 全測綠、coin_eq delta=0（4 config）。

## 📍 前狀態（2026-06-16）

- **階段2 招人成幫已 merge（2026-06-16）**：投靠（NPC 絕境同格→`join_request` forced event→玩家收留,扣食物 onboarding[一餐×人數,消耗品非守恆] + reuse `merge_teams` 整團併入,守恆）+ 招募（玩家主動→coin 挖角,既有 recruit）。成本**按觸發分流**(投靠=食物/招募=coin)。隊能力讀數 DTO(`capabilities`:按真技能聚合——求生 named 平均→獵率/產出、戰鬥逐個體→戰力 proxy、pop→日耗)+ status 顯示 = emergent legibility。tutorial onboarding(食物盈餘閾值一次性送 1 堪用 named+3 tier0 anon→走真投靠流程)。reuse merge_teams/hunt 公式/forced 路徑/dispatch_subteam(specialist→子隊長),零新系統。headless+ui_flow 全綠、coin_eq 守恆。spec `2026-06-16-stage2-recruitment-design`、plan 同名。
- **養得起/離隊** = reuse 既有 famine/loyalty/defect(不新做);**部署** = emergent 自動貢獻(不做逐人指派 UI,YAGNI)。

## 📍 前狀態（2026-06-14）

**玩家核心迴路定為 Kenshi 型下而上生存**（spec `2026-06-14-stage1-survival-forage-hunt-design`）。階段拆分：1 開局生存 / 2 招人 / 3 據點 / 4 成勢力。

- **階段1 Plan 1（覓食地基）已 merge**（`ff646f6`）：無據點隊覓食食物（FORAGE_RATE/食物only/枯竭/scale鎖）+ NPC survival forage path（pop≤15 門檻防大軍蟑螂）+ 釋放條件 + `survival_start` 開局 config。2 年 multi died=no、coin_eq delta=0、大軍無覓食、小隊 23→41。遺留見 known_issues W7。
- **階段1 Plan 2a（小獵物食物層）已 merge**：wild_game world-gen + 月再生 + `HuntSystem.hunt_small_game`（求生 roll/枯竭/食物）+ NPC 覓食被動小獵 + 玩家 hunt 指令 + `_collect_from_tile` 排除活物。2 年 multi died=no/coin_eq 0/survival_start 23→36。
- **Bug7 已修**（interaction:233 stale-id race，一行守衛；warzone 2 年 OOB 3→0）。
- **階段1 Plan 2b-1（野獸戰鬥核心）已 merge**：爪牙武器 grade + predator_density 生成/再生 + BeastSystem pseudo-team（負 id）+ encounter beast spawn/逃戰行為/爪牙攻擊/得肉清除 + npc_combat beast_strength/reward + 玩家 hunt_beast 指令。reuse 人類戰鬥機制。6 測試綠/2 年 multi died=no/coin_eq 0/無 beast 殘留。
- **階段1 Plan 2b-2（野獸伏擊+偵測）已 merge**：AmbushSystem.detect（偵查/求生 vs 掠食者隱蔽）+ 伏擊編排（玩家→encounter/NPC→npc_combat 遵 Bug9）+ sim_runner 接入 + 獵勝戰鬥 exp + 掠食者 infamy 計數 + NPC 主動獵獸。7 測試綠/2 年 died=no/coin_eq 0/[Ambush]×5。
- **subsistence 改狩獵唯一（Plan 2c）已 merge**：移除被動覓食食物噴泉（量測 income~44>>burn~7、囤 300+天糧）→ 食物唯一來源=狩獵 wild_game。
- **tile_food_init→cap bug 修 + outpost.terrain 釘地形**：村餓死真因（tile_food_init 不設 cap、村在山地）；survival_start 村釘平原 → 23→22 穩。
- **絕境驅動多元生存行為（desperation-survival）已 merge**：`_trigger_survival` 重構 desperation×values（warning 個性門檻 / urgent 解閘人人有活路）+ pref helpers + 紮營（依個性軍/民 + 升 tag 清流亡 = 流浪→定居攀爬）。2 年 multi 行為多元（loot130/camp17/forage14/beg15/join9/hunt6）、survival_start 23→21、coin_eq 0、無誤觸。
- **✅ 階段1（開局生存）整套完成 + 求生行為多元化**：覓食(已退場)→狩獵唯一 + 野獸戰鬥/伏擊 + 絕境多元生存。世界 2 年無崩、守恆 0。
- **NPC 向上攀爬**：吞併→建勢力（npc_combat/interaction）、建造/紮營→定居成生產/軍隊（auto_settle + crude camp）、W4 設施階梯、pop→分裂。流浪→定居這階補齊。

- **SoloAI 主動尋家 + 承諾慣性已 merge**：`_evaluate_solo` 加 紮營/投靠 value 加權（無家團、bypass _tag_weight 避流亡歸零）+ solo_intent 慣性（止 flip-flop）。churn 修（主動 camp 免糧足釋放 + 到達兜底）。2 年×3 roving 主導非 uniform、安身率↑、守恆 0。流浪→定居 bottom-up 進展接上。

- **文字 UI 翻新 P1（API 暴露+邊界）已 merge**：DTO 暴露 stage-1（food_days/starving precarity、wild_game/predator 認知分級、available_actions hunt/hunt_beast Layer6）+ text_ui 唯一洩漏(encounter_active)走 bridge。invariants 加 UI 邊界。spec §4 含全動作覆蓋審計矩陣。
- **文字 UI 翻新 P2（chrome 重整）已 merge**：status 增強(food_days/趨勢/成員健康)+hint 行+feedback 行+LogStrip(panel 共存)。helper 單元測綠;**GUI 視覺已人工 run-verify ✓**(2026-06-14 chrome 四區正常顯示)。玩測順帶抓 pre-existing 遭遇戰/互動 UI bug。
- **遭遇戰/互動 UI bug 批修已 merge**：U10 戰後凍結✅/U11 命中回饋✅/U12 交易誤判✅/U13 卸裝[U]✅/U14 進場數(非bug)/U15 戰後按鍵閃退✅/U16 地圖迷霧 axial 投影(pre-existing 未修,記錄)。headless+ui_logic 全綠;**U10/U11/U12/U13/U15 GUI 待人工 run-verify**。**P3(全動作覆蓋照 §4 矩陣 + 調薪 set_member_salary 指令) 待寫**。

- **UI-flow 測試 harness 已 merge**：headless 實例化 TextUI.tscn + 注入 + 驅動 + 斷言 → 輸入流/選單/內容 class bug 自動回歸（省手動 GUI 驗）。`scripts/debug/ui_flow_test.gd`。
- **B3 玩測 bug 批修已 merge**：attack_select 操作提示 / U14b 自隊武裝數(DTO+status) / U10b 玩家全滅→game-over。配 harness 自動測。
- **B4 成員管理已 merge**：set_member_salary(S9)/set_armed_anon_ratio(U18)/equip_member·unequip_member(U13b) 指令+UI。守恆(裝備扣/還 team 池)。armed_anon_ratio 下游 encounter/npc_combat 有讀=有效。
- **UI 修路線圖（「都做」）全完成**：B3 ✅ → B4 ✅ → **交易 offer-builder ✅** → **P3 全動作覆蓋 ✅（2026-06-15 merge）**。U16 地圖迷霧(axial 投影)真視覺待互動迭代。
- **P3 全動作覆蓋已 merge（2026-06-15）**：6 孤兒動作補玩家 UI 路徑（對稱性閉合）。公庫面板[K](deposit/withdraw+翻頁)、outpost build_facility 設施選單/abandon 二次確認、faction extract_treasury 比例輸入+>0.5 二次確認、互動選單 emit recruit_anon/invite_settle。零新後端邏輯。DTO/emit/守恆/flow 全綠。**L3 後修**：invite_settle 經選單預設 settle_pos=玩家腳下（修死按鈕）。
- **交易 offer-builder 已 merge（2026-06-15）**：`get_trade_session` DTO（雙方清單+估值+公平天平+NPC 接受預估，reuse local_value/evaluate_offer，零新交易邏輯）+ text_ui offer-builder（我給/我要欄+數量+天平+送出+翻頁），取代舊 auto-trade confirm。買/賣/以物易物同介面。DTO/守恆/flow 全綠。
- **P3 全動作覆蓋 spec+plan 已寫（2026-06-15，待子 session）**：審計找 6 孤兒動作（公庫 deposit/withdraw、outpost build_facility/abandon、faction extract_treasury、team-target invite_settle/recruit_anon）。plan 5 task A→D→B→C→E。spec `2026-06-15-p3-action-coverage-design`、plan `2026-06-15-p3-action-coverage`。
- **🗺 路線圖 + 已知問題解方彙整：`docs/roadmap.md`（2026-06-15 建）**。近期=P3→GUI run-verify 債清償（最高槓桿，轉 ui_flow 自動回歸）→U16；中期=tune/階段2 招人/②目標錨；含 Bug2/W4/Bug5/Bug6/Bug8/Bug9/U16 各附建議解 + 工量。圖形 UI 項（U5/U6/U7/S4）moot（TextUI 主用）。
- U11 戰報/U12 交易/U13b 等 GUI 顯示部分：wiring 已接（harness/headless 驗 flow），真視覺待人工偶查。
- **bug 批修 + known_issues 對齊（2026-06-15）**：Bug6(schedule 注入+dispatch)/Bug8(stale test)/Bug9(player_id 守衛)/**Bug10(屠村 _massacre_residents 鑄幣+丟公庫,守恆 +60 → 修,Bug6 連帶撈到)** 全修。Bug2(floor 已修)/Bug5(量測證非缺陷,NPC 勒索休眠→roadmap) 結案。known_issues 全條目對齊現碼（7 項漂移已標正）。
- **行為量測儀器裝好（2026-06-15）**：`game_sim_multi` 加 `[TaskHist]` 月取樣 task team-time 佔比。**量測裁決:世界健康,不需 tune**。tyrant 掠奪 15.6%(劫掠型本該)/逃跑 15.6%/徵收 13.3%/攻擊 11.1%/治理 11.1%；warzone 治理 22.8%/idle 19.6%/紮營 12%/掠奪 5.4%。兩場 coin_eq delta=0。原「loot 偏高 130」= 原始計數假象,佔比正常。SoloAI 投靠低(2.2%)+warzone idle 偏高 = polish 非問題。**measure-first 結論:健康世界不硬調,轉階段2。**

### 佇列（下一步選項）
- ~~狩獵受傷→醫療~~ **已涵蓋**：危險獸走真戰鬥（encounter/npc_combat）→ body_parts 傷 → 戰後 `resolve_negative_flags` 耗 medicine。小獵物抽象 roll 免傷（合理）。無需另做。
1. **UI 接入（player 可玩性）**：stage-1 全機制（覓食/狩獵/hunt 指令/野獸/伏擊/求生）目前**僅 headless 驗,玩家無法經 UI 玩**。原 arc 目標「世界合理→轉玩家迴路」。team0 harness 餓死症結也因玩家無 UI 自驅。
2. **量測 tune 階段1 全 TEST VALUE**：loot 偏高 130 / SoloAI proactive 投靠占比低（0 次,門檻嚴）/ FORAGE/BEAST/AMBUSH 數值。一次一變因（世界已穩,非急）。
3. **②深層目標錨**（待 spec）：接 dormant goal 系統,長弧（盜匪→建國）。先量測承諾慣性夠不夠。
4. 階段2（招人成幫）。

### 殘留 bug / 量測限制
- **team0(玩家隊)在 multi 餓死 = harness 限制**（玩家隊 _evaluate_survival early-return + auto-driver 不代跑玩家生存）非 cascade bug。要量測玩家生存需 NPC-觀測 config 或 auto-driver 補生存代跑。
- Bug8（滅團 food 公庫 baseline）；Bug9（encounter player_id==-1 latent）。
- invariants 新增：對稱性、玩法節奏（decisions-not-chores + 激情時刻）。
- invariants 新增：對稱性（無玩家專屬機制）、玩法節奏（decisions-not-chores + 激情時刻）。

---

## 📍 前狀態（2026-06-13 session 末，重啟交接）

### 本 arc 已 merge（依序）
設施改制 A 期（slot/8設施/軍民/三級成本/守恆審計）→ B 期材料層（herb/馬鏈/選址滾動拓殖）→ 經濟一致性（per-unit 製造 + 全表定價 + 飢荒5x）→ 馬爾薩斯修正（選址diff/復工門檻/COLLECT_RATE 0.01→0.05）→ 飢餓致死鏈（famine_days + hunger→blood + 昏迷 + blood=0死）→ 封建財政公庫（一般稅自動進公庫 + 建造扣公庫 + 特別稅 + 慷慨光譜 + 兩稅不滿）→ W4 caravan-load 派工提領 + leader 治理 → **W5 task latch 大修**（核心）→ W6 死亡資產守恆 → 經濟死水解鎖（自給階梯 + 治理faction leader + 生育分層）

### 🔑 本 session 最大發現：task latch 凍結世界（W5）
TeamTrace 遙測（`scripts/debug/team_trace.gd`，gated game_sim_test 每日 dump）量出 **92% team-time 凍結在不釋放的 survival(p80)/panic(p70)**。世界非窮而是**癱瘓**。修 survival 糧恢復釋放 + 逃跑 timeout + 乞食釋放 + 餓死團清除後，**所有機制自己活起來**：

| 機制 | latch 修前 | 解凍後（2年×4config）|
|---|---|---|
| 戰鬥 Combat Start | ~0 | 13 |
| 貿易 Market 成交 | 0 | 11 |
| 徵稅 / 援助 | 稀有 | 12 / 6 |
| 生育長大成人 | 0 | 39 |
| 設施建造 | 2 | 4 |
| coin_eq 守恆 | — | delta 0.00 ×4 |

**重要結論**：W1/W2「0 combat/0 trade」**不是擦肩會合問題，是 latch 症狀**（速度差本就存在，team 凍住沒去追）。會合機制不用做。

### ✅ 軍閥型 config 已達標（2026-06-13 後續，config-first 解）
前況：tyrant 60→0 全滅、warzone 54→3。**純 config 修**（未動 AI）：
1. 每軍閥 faction 加一座生產村（生產 tag + civilian L1 outpost + tile_food_init 500，複製受壓村模式）→ faction 自給
2. tyrant `敵對暴君` tile_pos (8,5) 出界（hex_dist=5 > radius 4）→ 修 (7,5)。整個 faction 1 原坐空 tile 無法收糧 = 主要崩因（交接舊記「(7,7)」為誤記，真凶 (8,5)）

跑 21600 tick（2.5 年）結果，**達「合理」門檻全部**：

| config | pop | teams | died | 戰鬥(Round) | 貿易(Market) |
|---|---|---|---|---|---|
| tyrant | 88→57 | 5→14 | no | 166 | 59 |
| warzone | 134→128 | 5→28 | no | 33 | 211 |

順帶修 `vision_system.tick_discovery` race：team_ids 快照含本 tick 內滅團 id → `state.teams[tid]` 報 Invalid get index。加 `state.teams.has(tid)` 守衛（[Extinct] 增多才觸發）。修後 SCRIPT ERROR 0。

**結論：世界已合理 → 下一步轉玩家可玩性迴路，勿再追 NPC 完美化。** 殘留 [Survival] 6399 次警告為高頻但非 latch（戰鬥/貿易/製造/分裂全流動，team 數淨增），低優先可後看。

### 🎯 重啟後的決策（已與用戶確認）
- **遊戲類型 = 世界模擬器，合理 NPC+經濟是可玩前提**（不能把玩家迴路硬接在自毀世界上）
- 但「合理」≠「完美 AI」。標準：**2 年無荒謬全滅 + 各 config pop≠0 + 戰鬥/貿易≠0**。達標即收手，**勿掉回 NPC 完美化無底洞**
- ~~下一步：改軍閥 config 給生產基礎 → 跑 2 年 → 資料說話~~ **已完成，世界達標（見下「✅ 軍閥型 config 已達標」）**
- **現在下一步：轉玩家可玩性迴路**（世界已合理，不再追 NPC 完美化）
- 順手（非優先）：`faction_ai_system.gd` 2000+ 行怪獸拆檔（每次都改它，編輯可靠性受損）

### 待修小項
- W4 遊牧軍閥 leader 不駐留（建造仍卡 tyrant/warzone）— 部分修
- Bug2 salary coin 無下限
- config 在 radius 外 spawn team（(7,7) 超 radius 4）隱患
- 全參數 TEST VALUE 待正式平衡

---

## 已完成

### 資料結構層（`scripts/data/`）

| 檔案 | 內容 |
|---|---|
| `person_data.gd` | id, name, role, team_id, age, needs, stress, fear, loyalty, salary, coin, goals, attributes(4：智力/體力/毅力/魅力), skills(14：統領/戰鬥/弓箭/求生/生產/製造/工程/醫療/戰術/計謀/交涉/商業/偵查/潛行), values(8：野心/求生欲/義氣/貪婪/慎重/好戰/殘忍/信義), memory, relations, body_parts(6部位/status), equipment(right_hand槽), get_effective_speed, get_skill_mult, get_attribute_mult |
| `team_data.gd` | team_id, leader_id, named_members（取代 advisors+members）, population, minor_population, resources(19種), move_speed, equip_order, armed_anon_ratio, tags, current_task, unrest_turns, faction_id, tile_pos, move_target, move_tick_acc, combat_target, readiness, wounded, guard_ratio, fatigue, strategic_assignments；TAG_* 常數（7種）；TASK_* 常數；pop_cap_from_leadership |
| `tile_data.gd`（HexTileData） | tile_id, terrain(plains/forest/mountain), resources, productivity, farming_level, harvest_factor, occupied_by, outpost_type/level/owner, manufacturing_level |
| `world_data.gd` | tiles dict, current_tick, current_turn, ticks_per_day(24) |
| `world_state.gd` | world, teams, persons, factions, team_known, team_discovered, team_intel, player_id, player_state, encounter_active/units/attacker_id/defender_id/pursuit_edge_offset, snapshot_faction_member(), create_faction(), disband_faction() |
| `faction_data.gd` | faction_id, faction_name, is_established, leader_team_id, member_team_ids, tribute_rate, goals(string), strategic_goals(dict), strategy, relations, known_member_states |
| `message_data.gd` | id, type, description, source_pos, origin_team_id, origin_tick, strength, is_distorted |

---

### 模擬系統層（`scripts/simulation/`）

| 檔案 | 內容 |
|---|---|
| `sim_runner.gd` | Tick 循環 14 步（含日夜乘數、遭遇戰暫停分支）；LOD：近區每 Tick，遠區每 FAR_ZONE_INTERVAL=10 Tick |
| `resource_system.gd` | 資源收集（outpost → food_gain）；消耗結算（0.1/人/Tick）；needs/stress/fear 更新；tile 再生 |
| `outpost_system.gd` | 據點建立/拆除；civilain/military 兩類；建設 ticks 進度 |
| `harvest_system.gd` | 主動採集：team 到資源格採收 tile.resources |
| `manufacturing_system.gd` | 6 種配方優先序（工藝品 > 高階武器 > 冶煉 > 低階武器 > 一般製造） |
| `reaction_system.gd` | 10 種反應（P1–P5、N1–N5）；skills/values/goals 整合效用函數；每 10 Tick 更新目標 + 呼叫 NpcAiSystem.check_goal_alignment 調整 loyalty；`on_attack_defeat` event（named loyalty / leader stress，依義氣/信義/慎重）|
| `skill_system.gd` | on_reaction / on_combat_round / on_volley / on_combat_end 技能成長；屬性乘數；部位損傷修正 |
| `equipment_system.gd` | 記名 NPC 武器槽分配；armed_anon_ratio 計算；死亡武器歸還 |
| `vision_system.gd` | 迷霧：scout_range（偵查）+ exposure（人口+潛行+地形）；dist_factor 衰減；team_discovered；Tier 0/1 intel 快照寫入；偵查/潛行技能成長 |
| `interaction_system.gd` | 接觸結算：齊射→多回合戰鬥；flanking/morale cascade/pursuit；loot；body part 命中；_try_subjugate / _try_diplomacy / _try_merge / _resolve_tribute；貿易；玩家遭遇戰觸發（同陣營豁免）；execute_prisoner；Tier 2 intel；夜間突襲判定 _check_night_raid（待接入）；`process_on_move`（取代 process_on_arrival，每 tick 移動 team 對全 team 掃同格 try_interact）|
| `movement_system.gd` | tile_pos 移動（`_step_team` 用 A* `_calc_next_step`，繞山）；weighted 均速 (NAMED_WEIGHT=3 + tier-aware anon speed)；time_mult（日夜）；fatigue/超載懲罰；wagon 地形懲罰；strategic_assignments 優先邏輯；移動時記 `last_tile_pos`；BASE_MOVE_TICKS=TimeScale.MOVE_TICKS_PER_HEX=240 → 1 天/hex（×5→1,錨①連動）；process 回傳 `{arrived, moved}`；stuck log 加 source（task + strategic_assignments）|
| `path_system.gd` | A* `find_path`（同-tick cache）；`eta_ticks`/`_team_speed_mult`；`observe_velocity`（限視野+距離雜訊）；`estimate_catch_up`（reachable/eta/reason，ETA cap=AI_ETA_LIMIT 1200 tick = 5 hex plains at 240 tick/hex）|
| `event_system.gd` | Registry 架構；on_leader_death；PersonGenerator fallback |
| `person_generator.gd` | 從匿名人口晉升記名 NPC；tag 屬性/技能偏移 |
| `faction_ai_system.gd` | 策略層 evaluate_all；values 整合；成員 task 指派；SoloAI；tag 過濾；discovered-only 目標；`_find_*_target`（trade/prey/strong/aid）用 `PathSystem.estimate_catch_up`（reachable 過濾 + eta score）；每 20 Tick 外交評估；每 BETRAY_CHECK_INTERVAL 背叛評估；`_evaluate_prosperity_attack`（野心驅動征服 cadence 3 日，軍隊 tag 加倍 1.5 日，個性公式 attack_score / readiness threshold / find_prosperity_prey）；`_trigger_survival` Path 1 B 分支（遠 outpost + 殘忍/好戰 → 改 TASK_LOOT）；stuck 視為 idle 允許重評（_is_stuck → STUCK_TASKS）|
| `diplomatic_ai_system.gd` | _calc_diplomacy_score（5 因子）；try_proactive_diplomacy；handle_diplomacy_message（4 動作）；_form_alliance；_update_reputation；consider_betrayal；_execute_betrayal |
| `strategic_ai_system.gd` | 戰略目標更新（expand/defend/trade_net）；包圍指派；突圍指派；威脅評估（team_discovered，非全知）；in-map check（off-map target → nearest_valid_tile）；ENCIRCLE_DIST=1 / BREAKOUT_DIST=2 / BREAKOUT_NEAREST_THRESHOLD=3（trade_net dispatch 序8 溶入引擎已刪，致富交易走引擎貿易/買糧/囤貨 option）|
| `npc_ai_system.gd` | write_memory（修剪+relations+goals觸發+G2a feud/gratitude/protect 邊）；generate_birth_goals（values 門檻）；check_goal_alignment（目標×任務 delta）；vendetta_target（G2d 讀 feud 邊+衝動 gate→脫軌仇人 team）；cleanup_goals（target 死後重定向） |
| `salary_system.gd` | 每 30 Tick 結算；fair_salary = skills × 2.0；超付 → loyalty 上升 + kindness 記憶；欠付 → loyalty 下降；anon wage 改用 `AnonTierSystem.total_wage()` |
| `anon_tier_system.gd` | 4 tier（平民/新兵/老兵/菁英）；TIER_STATS（combat/speed/base_wage）；PROMOTION_EXP_THRESHOLD + ×count；leader 戰術 cap 訓練上限；菁英需 weapon_melee_high；kill_random weighted；transfer_proportional；avg_speed/avg_combat_skill/total_wage computed |
| `training_system.gd` | TASK_TRAIN team 每 tick 為 tier 累積 exp（速率 = leader 戰術 × n）|
| `day_night_system.gd` | get_time_period（dawn/day/dusk/night）；get_speed_mult / get_fatigue_mult / get_vision_mult；get_camp_vision_range（guard_ratio 守夜） |
| `population_system.gd` | 超額強制分裂（每 10 Tick）；有 advisor → dispatch 子隊；無 advisor → 獨立流亡 + PersonGenerator 晉升 |
| `subteam_system.gd` | dispatch / try_merge_back / 護衛跟隨；動態人口上限；紀律失效脫離 |
| `message_system.gd` | emit_message；propagate_on_arrival；4 種失真模式；去重衰減 |
| `world_generator.gd` | hex 地圖（radius 可配）；地形三型；ore_iron 分布 |
| `player_api_mapper.gd` | pure static DTO mapping（map_player_summary / map_forced_interaction / map_inventory_state / **map_members_detail** / **map_team_stats** 等） |
| `player_query_api.gd` | snapshot 查詢組合（get_player_snapshot / get_team_details / get_location_context 等） |
| `player_command_api.gd` | 指令驗證+分派（dispatch / move_to / respond_to_forced / execute_action 等） |
| `sim_bridge.gd` (更新) | query_player / command_player facade；UI 與 WorldState 玩家欄位完全隔離 |
| `encounter_system.gd` | 六角遭遇戰：init_encounter / _spawn_team_units（含匿名）；進場位置（attacker/defender/pursuit）；裝備分配；箭矢系統；decide_action 戰術 AI；advance_round 戰鬥解算（範圍/近戰/撤退/逃跑）；俘虜判定；傳令兵退出（SubteamSystem stub 待接）；resolve_encounter_end 結算（含勝方 occupy outpost 三 path：屠/放棄/強佔，依 leader 個性 + 居民拒投靠 reputation 判定；anon kill 改 `AnonTierSystem.kill_random`；戰場存活 exp +5 + 勝方 +5）|

---

### 事件層（`scripts/simulation/events/`）

| 檔案 | 內容 |
|---|---|
| `base_event.gd` | check() + execute() 基底 |
| `event_unrest_split.gd` | 分裂：unrest≥30 + 義氣<0.4 + 目標衝突；reset_loyalty_on_transfer |
| `event_unrest_replace.gd` | 替換：unrest≥20 + 統領≥0.3 |
| `event_faction_defect.gd` | 脫離：faction≠-1 + unrest≥20 + 義氣<0.35 |
| `event_tag_shift.gd` | tag 增減：好戰/野心→+軍隊；戰損>50%→+流亡；資源穩定→-流亡 |

---

### 測試

| 檔案 | 內容 |
|---|---|
| `scripts/debug/headless_test.gd` | 1000+ Tick headless 模擬；涵蓋所有系統驗證（資源/反應/戰鬥/faction/子團/視野/薪水/疲勞/日夜/外交/戰略/玩家/遭遇戰/**members_detail/team_stats**） |
| `scripts/debug/team_ui_test.gd` | 成員快照欄位驗證 + TeamUiHelper 所有渲染函數覆蓋測試 |
| `scripts/debug/ui_flow_test.gd` | **UI-flow 整合 harness**（2026-06-15）：實例化 TextUI.tscn → 注入 bridge state → 驅真鍵盤 handler/_process → 斷言 label/state。免手動 GUI 驗。首批覆蓋 U19 forced 自動進互動 / U21 互動選單分頁(10+) / U12 交易顯示 / hunt 動作可選。**未來修 UI 加對應 flow 測試自動回歸。** |

---

### 文件

| 檔案 | 狀態 |
|---|---|
| `docs/person.md` | 四層決策、14技能、部位健康、慎重契約 |
| `docs/team.md` | 欄位、人口規則、unrest 門檻 |
| `docs/world.md` | Tick 循環、LOD、資源、迷霧 |
| `docs/event.md` | Registry 架構、現有事件 |
| `docs/message.md` | 三層架構、衰減公式、4種傳播 |

---

## 待完成 / 技術債

### 功能缺口

| 項目 | 說明 | 優先 |
|---|---|---|
| `_check_night_raid` 接入 | interaction_system 已有函數，尚未在 `_try_interact` 呼叫；遭遇戰 encounter-system 負責整合 combat_type="pursuit" | 中 |
| 傳令兵 SubteamSystem 接口 | `_messenger_exit` 呼叫 SubteamSystem.create_subteam（不存在）；目前 has_method 保護為空殼 | 低 |
| `generate_birth_goals` → world_generator | NpcAiSystem 已有邏輯，world_generator 另有初始化；兩套並行，可統一 | 低 |
| `_evaluate_alliance_need` → 實際觸發外交 | 目前僅 print 警告；需呼叫 DiplomaticAiSystem._form_alliance | 低 |
| PLAYER_MAX_WEIGHT 強制執行 | PlayerSystem 定義 30.0 但未在 add_to_inventory 執行重量限制 | 低 |
| text_ui `_player_cmd.get_available_actions` | text_ui_main.gd 互動模式仍直呼 `_player_cmd`（非 bridge），未完全隔離 | 低 |
| text_ui `_build_interact_str` 直讀 state | pending targets 顯示仍直讀 `_state.teams`；body_slots 直讀 `_state.persons` | 低 |
| `player_forced_event_id` 碰撞風險 | 目前 `str(randi())`；可改雙 randi 或 UUID，但碰撞機率極低 | 低 |
| Agent REPL encounter 測試 SKIP | seed=42 radius=3 在 5000 ticks 內未觸發遭遇戰；AC#13-16 GDScript 端已實作，需調整測試條件 | 低 |
| Agent REPL stdin stdout 污染 | stdin 模式下模擬 print 混入 stdout JSON Lines；TCP 模式無此問題 | 低 |
| `preview_trade` 精確度 | `preview_trade()` 用簡化比例公式，與 `resolve_trade_direct()` 實際計算略有差異 | 低 |

### 系統整合缺口

| 項目 | 說明 |
|---|---|
| salary → kindness 記憶 | ✅ 已完成（2026-05-28） |
| check_goal_alignment 接入 | ✅ 已完成（reaction_system，2026-05-28） |
| threat_map → team_discovered | ✅ 已完成（strategic_ai，2026-05-28） |

### 平衡（所有 TEST VALUE 未正式調整）

| 分類 | 涉及系統 |
|---|---|
| 疲勞速率/恢復 | SimRunner FATIGUE_PER_TICK=0.002 / FATIGUE_RECOVERY=0.01 |
| 日夜乘數 | DayNightSystem speed/fatigue/vision mults |
| 視野常數 | VisionSystem VISION_RADIUS=3 / SCOUT_BONUS=2.0 |
| AI 追擊上限 | PathSystem AI_ETA_LIMIT=1200（≈10 plains hex）|
| 薪資比例 | SalarySystem SALARY_PER_SKILL_POINT=2.0 / OVERPAY_BONUS=0.02 |
| 外交門檻 | DiplomaticAiSystem score 0.55/0.6 |
| 遭遇戰數值 | EncounterSystem 射程/命中/傷亡率 |
| 戰略 AI 間隔 | StrategicAiSystem STRATEGIC_INTERVAL / ALLIANCE_CHECK_INTERVAL |
| 生育機率 | ReactionSystem BREED_BASE_CHANCE=0.15（+醫療×0.1）；minor cap=maxi(1,int(pop×0.25))（2026-06-13 economy-bootstrap）|
| 治理門檻 | FactionAISystem GOVERN_MATERIAL_TARGET=75（公庫達標放手擴張）|

### 序0 憲法防閘 + 時間 hygiene（2026-07-05 done，merged 3f2765f）

時間統一 wave 與憲法溶入 arc 的鋪路 slice，4 Task 全零 sim 行為變（seeded 46/8/1/380 守恆、framework PASS=7）：
- **修1 near/far hoist**（`sim_runner.gd`）：per-tick 無條件 O(N)×2 team scan 搬進各自 cadence gate（命中才算），消 gate-miss 純浪費，順減 O(N²)。
- **修2 十常數導出**（`faction_ai_system.gd`）：10 裸 cadence/timeout const → `TimeScale.TICK_PER_DAY*N`（跨類別 const 引用，非 `days()` static func）；順修 `FLEE_TIMEOUT` 硬編 `5*240` → 跟根。`time_const_check.gd` 斷言值不變。
- **修3 eta 除數**（`faction_ai:190`）：`/240.0` → `/float(TICKS_PER_DAY)`，殺硬編漂移。
- **★憲法 site-freeze 防閘**（`constitution_gate.gd`+`constitution_baseline.txt`）：鎖 `TaskArbiter.transition/try_set` 面（32 指紋凍結，8 known 違憲標 `# 序N`）。current⊆baseline，新增=FAIL、移除(arc溶解)=PASS。**限制**：不覆蓋 return-task-字串式違憲（coverage 誠實聲明，見 invariants）；**未掛常駐鏈**（known_issues 追）。
- **根值未動**：`TICKS_PER_DAY` 仍 240，60 切換綁 A2（×5→1+補給+FOOD+gen 四件一 landing）。本 slice 為 A2 鋪好導出面。

### 憲法溶入 arc — wave1 序1 threat done（2026-07-05，merged 804432e）

**溶=融合非刪** 首張。threat 手算 argmax（`_dispatch_threat_response`）撕除 → 引擎 `rank_threat` 秤：
- 4 反應成 REGISTRY option（FLEE 複用 `survival`；補 備戰/迎戰/求和 + eval term + weight key 人格 crosswalk）。**term = additive personality-dominant**（weight=1.0，人格 baked in eval，同既有 intent_fit/attack_drive 法）——因 `threat_react` unbounded（power_ratio 達 3.27）multiplicative 會爆量壓過 survival 絕境；additive 忠實鏡射舊公式，非 hack。
- 架構鏡射既有 survival 雙路：unified 隊 threat option 進主 rank（`_decide_unified`）；non-unified 隊 loop3 `_evaluate_threat` 保 trigger/release，內部換 `rank_threat`。trigger/release scaffolding（idle-gate/cadence/FLEE_TIMEOUT）保留=世界機制。
- **融合驗雙關綠**（`threat_dissolution_check.gd`）：①repertoire 4 原型各達（FLEE/DEFEND/PREPARE/求和）+ 居民守衛 ②率表 flee13/prepare4/defend1/pacify0=18>0（non-unified 逐類 bit-identical，該出現還出現）。
- **seeded 漂移 46/8/1/380 → 48/8/1/382**（新 baseline）：漂移純來自 unified 隊 threat option 進主 rank 微調軌跡（non-unified 逐類零變）；factions/established 守恆、pop 穩、無滅團潮 = **合理非退化**（交 QA 覆判，wave 級交付前）。
- 憲法閘：`_dispatch_threat_response` 指紋 removed=arc 進度；dispatch 移入保留的 `_evaluate_threat`（sites=32 不變，PASS）。
- **殘（watch，known_issues）**：unified 隊 迎戰/求和 下游 resolver（DEFEND prosperity_target 消費 / tribute_offer 外交鏈）未端到端驗；survival option 雙語意（主 rank reputation-filtered soft / rank_threat raw hard，刻意分離已註釋）。

### 憲法溶入 arc — wave1 序2 solo done（2026-07-05，merged f7ce320）

`_evaluate_solo` 非-unified 手算 argmax 撕除 → 引擎 `rank_scored`（鏡射 `_decide_unified`）；去 `_tag_weight` hard-gate（tag 不硬鎖）；attack/loot **capability-grounded**（藍圖 tag-soft-ruling）。
- **capability-grounding**：`ctx.self_armed_ratio = _calc_own_armed / pop`（equipped 戰力，storage 武器不算）；loot_drive/_intent_fit 攻擊 × `capability_factor = clampf(ratio/VIABLE_ARMED_RATIO[0.3])`；prey-weakness 改比 self **ARMED** 非 POP。→ 無牙商隊掠奪 util **0.000**（rank[0]=貿易，非劫匪化）；重甲商隊絕境可揮刀；軍隊 rank[0]=攻擊。**憲法**：戰力歸零=送死=世界事實（非 tag-label 禁攻）。
- **融合驗雙關綠 + 反向**（`solo_dissolution_check.gd`）：repertoire 9 各達 + 反向 3（商隊≠劫匪/重甲可揮刀/軍隊≠雜貨商）+ unified 守恆 3。threat 融合驗仍綠（共用 eval 未破）、threat 率 18 守恆（loop3 未餓死，measure 證）。
- **seeded 48/8/1/382 → 52/8/1/380**（QA wave 級判；factions/established 守恆、無滅團潮）。
- **★框架債揭（重要，見 known_issues + [[project_framework_seams]]）**：`_tag_weight` 是 solo/prosperity **隱形去衝突閘**——舊靠 `=0` 讓 FORCE 隊 attack 歸零→留 idle→loop3 prosperity 接精算征服鏈。去它 + 引擎「建設」option 恆 applicable→solo 每 idle tick 必派→餓死 loop3-idle-gated 路（S3 scout 一度 DORMANT）。實作加 **yield 閘補**（FORCE 征服候選 cadence 到期 return 讓 loop3）=橋，真結構修在序6（loop3 dispatch subsystem 溶入）。軍隊攻擊 occupancy 0%→22.5%（QA 判過度侵略否）。獨立隊 ambition-diplomacy 具體行為流失（engine 外交需 faction_stakes；獨立隊走 _evaluate_independent_strategy 結盟/建國+threat 求和；藍圖判要否保）。

### 憲法溶入 arc — wave1 序3 rung_task done（2026-07-05，merged 50dc86f）

`ambition_ladder.rung_task` `(archetype,rung)→task` 查表判斷器撕除 → archetype/rung 當 weight（`ctx.ambient_train_drive` 等）驅動 option。
- **冗餘識別**：rung_task 7 mapping，6 條既有 option 已覆蓋（TRADE→貿易/SETTLE→生產/建設/等），**唯一真缺=訓練 option**（FORCE 累積階練兵）→ 補之。刪查表。
- **idle-filler 走 `rank_ambient`**（收窄，系統裁定風險#1）：loop3 野心階梯 idle-filler 原 spec 走全 `rank_scored`→誤派 FLEE 86 次/1200t（team 到此已過 loop3 survival/threat 評估，ambient 不該二次猜）。修=`AMBIENT_OPTION_SET=[訓練,貿易,生產,建設,囤貨,駐守]` + `rank_ambient`（鏡射 rank_threat）。**FLEE churn 86→0（結構除，非壓 magnitude）、徵收 10→0**。
- **★序1 threat「率18」部分是 churn 假象（重要 measure 洞察）**：86 ambient-FLEE 隨機逃跑=隊間威脅遭遇主要製造者→序1 驗的 threat 率 18 部分虛胖。churn 除盡→seeded threat.dispatch 3→0（世界變靜）。`_evaluate_threat` 未改、仍 loop3 先跑、真威脅仍派。→ **threat 融合驗 5b 從「seeded 湧現硬斷」改「確定性 live-seam 硬斷」**（構威脅隊直呼 _evaluate_threat 斷言實派+probe bump=更 robust，seeded 值降資訊性）。教訓：湧現率斷言可被無關 churn 虛胖，確定性 seam 測才穩。
- **融合驗綠**：rung repertoire（訓練/貿易/生產/建設/讓位）+ threat（新 live-seam）+ solo 全 ALL PASS；framework PASS=7；gate PASS 32（rung_task 回字串無 TaskArbiter→不在指紋）。
- **seeded 52→48/8/1/380**（QA wave 判；pop/factions/established 守恆；48–56 帶繞 52）。**watch（藍圖/QA）**：世界變靜（threat 遭遇↓）是否過龜縮（反龜縮 bar）。

### ★★憲法溶入 arc 完成 — 序8 灰項 done（2026-07-06，merged 57f7d39）= 8 違憲全溶

`strategic_ai::_dispatch_trade_net`（唯一剩餘引擎外 task-dispatch 灰項，序6 後致富成員走引擎已成死路 trade.dispatch.trade_net=0）撕除 → 致富交易走引擎貿易/買糧/囤貨 option。gap 檢無淨增（純買家囤貨/買糧覆蓋）。gate sites 31→30 全為保留 scaffolding。融合驗綠、framework PASS=7（S6 order 不 DORMANT）、seeded 49/8/1/381 零漂移。
- **★★憲法 8 違憲全溶完（序1 threat / 序2 solo / 序3 rung / 序3.5 preempt / 序4 vendetta / 序5 prosperity / 序6 dispatch / 序7 reaction / 序8 灰項）**——「決策不統一」根因 arc 完成。所有 NPC macro 行為經統一決策引擎（DecisionEngine util weigh + 人格調製），憲法閘鎖 30 sites 全為 world-mechanic dispatch/scaffolding（非個體 utility 判斷器）。
- **arc 尾待**：撤 pre-commit site-freeze 閘 → 轉全掃常駐鏈（另 slice）。
- **arc 後平行軌**：gen readiness recalibrate（probe slice→重跑 baseline→調，待藍圖）；決策模型接線脊椎（感知腳 audit done、情緒腳序7 起步、位置god-view/戰力欄/記憶腳待）；全 pipeline 工作流切換（脊椎開軌時）。
- **殘（follow-up）**：C 類貿易 finder dedup（`_find_trade_partner` god-view vs `_find_trade_target`）；player_command trade_net override 語意（正交，另議）。

### 憲法溶入 arc — 序7 ReactionSystem 行為選擇溶入 done（2026-07-06，merged 2edf120）★reframe=其實小

audit 標「最大最難」，**measure reframe=其實小**：9 反應 apply 幾乎全 state-effect（情緒/loyalty/unrest/離隊 spawn/生育/memory 後果）——**唯一行為選擇改 task=聚合 panic-flee bridge**（`reaction:48-60` 兵卒大量恐慌整隊裹挾潰逃 try_set TASK_FLEE）。
- **溶=拆 1 bridge + 保 9 反應**（合藍圖 arc-order「拆行為 vs 情緒/離隊/生育後果保留」）：bridge 撤 → `ctx.team_panic`（高 stress 低 loyalty named 成員/pop 聚合）→ `threat_pressure` eval 疊 `team_panic×PANIC_WEIGHT(0.5)` → 引擎 survival option 自然 FLEE（潰散由統一秤輸出非旁路）。個體反應 apply 全不動=consequence scaffolding。
- **★FLEE 三源序保**：真絕境 survival util(12) >> panic-only(0.4)，PANIC_WEIGHT 不喧賓奪主。
- **★ctx 首讀 person stress/loyalty = 決策模型情緒腳首個接線起步。**
- **融合驗 4 錨 ALL PASS**（行為溶入/FLEE 三源序/反向/個體後果保）；threat/preempt/faction-dispatch/全融合驗綠；framework PASS=7；**gate sites 32→31**（evaluate_all 指紋 removed=reaction 零 TaskArbiter 面）；**seeded 49/8/1/381 零漂移**（bridge 此 seed dormant）。
- **殘（backlog）**：PANIC_WEIGHT/PANIC_STRESS/PANIC_LOY=B 債（該由膽識算，常數人格化軌）；記憶染價值腳 dormant（引擎不讀 memory=決策模型 gap，接線脊椎軌）；反應零 probe=觀測空白；玩家隊 FLEE 保護靠既有 per-path 玩家 guard（實作驗玩家到不了引擎 survival dispatch）。

### 憲法溶入 arc — wave2 序6 faction 成員 dispatch done（2026-07-06，merged 2b4a427）★最高收斂動主幹

`_assign_member_tasks` goal→task if/elif hand-dispatch（含 V2-cmd 徵收 shadow 攻擊）撕除 → faction **成員**（非 subteam）走 `_decide_unified`（引擎 rank_scored 競秤）。
- **★只改成員 dispatch gate（`parent_team_id==-1`），不動全域 `uses_unified`**（陷阱：uses_unified 兼 `_evaluate_threat` skip，擴全域會繞過序3.5 preempt scaffolding=反龜縮又斷）→ 成員 macro 走引擎 + threat/preempt/survival loop3 scaffolding 保。**教訓同序2 `_tag_weight` 隱形去衝突閘：去/擴多職 gate 前先問它兼哪些職。**
- **★V2-cmd 自消**：`rank_scored_ctx` argmax（非 if/elif 短路）→ {徵收,攻擊} 雙 goal 競秤，好戰成員攻擊 util(1.91)>徵收(1.67) 贏、貪婪成員反轉（分歧非抹平）→ 攻擊-eligible 成員不再被徵收 elif 序死。
- **★成員打草穀 raid 接回**（掠奪 option has_weak_prey 自然競秤，序5 待項）+ **框架債縫#3 完全結清**（成員退 loop3-idle-gate，主 rank 每 cadence 重評）。外交 goal 對軍隊現通（舊 tag_weight=0 走不到）。
- subteam guard 補（`parent_team_id==-1`，防 loop1/loop2 雙寫，現缺）；MERGE consolidate→`_try_consolidate_merge` scaffolding（faction 整併非個體決策）；probe 遷移引擎路。
- **融合驗 6 錨 ALL PASS**（repertoire/V2-cmd 解/raid/preempt 保/subteam/本業）；threat-preempt/prosperity/threat/solo/rung/vendetta 全綠；framework PASS=7；gate PASS 32（`_assign_member_tasks` 指紋刪=arc 進度）。
- **seeded 52→49/8/1/381**（成員 raid+V2-cmd 解→分佈變，逐點重現）。**★gen 重校 follow-up ripe**（藍圖 seq5-judgment：等序6 全溶對完整征服/掠奪圖調——現完整）。
- **殘（watch）**：MERGE 現對商隊/生產成員亦 eligible（罕觸，誤併→加 tag guard）；member_atk seeded=0=結構（此 seed 無 faction 攻擊 directive，harness 確定性已證解）；leader dispatch=序6b defer。

### 憲法溶入 arc — wave2 序5 prosperity done（2026-07-05，merged 16ab3bc）★arc 最大 slice

`_evaluate_prosperity_attack` gate cascade（archetype/attack_score/readiness/find_prey 硬閘 prescribe TASK_ATTACK）決策溶進引擎 攻擊 option。
- **readiness→權重**：`_intent_fit` 征服 × `readiness_factor=clampf(readiness/readiness_thr_eff)`（沒本錢 util 趨 0=capability grounding，非硬閘）+ 信義 penalty（對齊舊 attack_score 野心+好戰−信義）。富 prey targeting（find_prosperity_prey 經 ctx.intent_target）。
- **scout-verify 保 scaffolding**（`_commit_conquest_attack`：不確定+慎重→TASK_SCOUT/confident/莽者→TASK_ATTACK；`_tick_conquest_scout` 生命週期）——means-end 非 option（派斥候探底 option 排 trade/diplomacy 溶）。**S3 scout=1/S4 ambush=1 誘殺保**。
- 刪 cascade + 序2 yield 閘（框架債縫#3 部分結清）+ unified reroute → FORCE 隊征服走主 rank。
- **融合驗 6 錨 ALL PASS**（repertoire/readiness閘/斥候/照衝/hunger_relief/富prey）；framework PASS=7；gate PASS；seeded 52/9/1/381→**52/8/1/380**（非凍死，churn 在）。
- **★征服率發現（gen 重校輸入）**：征服 intent 隊 rank **掠奪(小承諾)壓過攻擊(出征)** → prosperity_reached 2→0=「沒本錢征服隊改掠奪」=合設計；ready+armed 隊攻擊會贏。conquest 仍經 loot→combat→capture（combat_entered=15）。**非 fail**（藍圖：雪球≠fail 唯凍死=fail，churn 在）。
- **★interim gap（序6-bound）**：舊 loop3 cascade 對 faction 成員也跑打草穀 raid；序5 刪 loop3→成員征服只宣告無 dispatch 路→**成員 raid 暫失**（獨立 FORCE 隊征服鏈完整=主交付）。序6 loop3 全溶接回（縫#3 結清）。
- **殘（arc 尾清）**：orphaned `calc_attack_score`/`ATTACK_SCORE_THRESHOLD`/`PROSPERITY_CADENCE(_MILITARY)`；cascade 單元測遷移/退役。**B 債**：`VIABLE_ARMED_RATIO`/`INTENT_FIT_DRIVE`/信義 k=0.4 待人格化（`readiness_thr_eff` 已含慎重✓）。

### 憲法溶入 arc — wave1 序3.5 threat-preempt done（2026-07-05，merged 4afbcaf）

反龜縮 seam 修：忙碌目標對逼近攻擊者盲（`_evaluate_threat` idle-gate，measure 坐實 IDLE 反應/BUSY 不反應）→ 強威脅 preempt 非緊急進行中 task。**接 approach→感知→反應因果脊椎，非新機制。**
- `_evaluate_threat` idle-gate 改三分支：idle→原路；busy-preemptible + threat_react≥`threat_threshold+PREEMPT_MARGIN(2.0)`→打斷派 defensive；busy-urgent→不評。`PREEMPTIBLE_TASKS`=生產/製造/建設/貿易/治理/訓練/覓食/紮營（8）。PRIO_THREAT(70)>DISPATCH(50) 打得斷。
- **PREEMPT_MARGIN=2.0**（measure 校，非初設 0.5）：threat_react 的 approach/hostility(weight 1.0)壓過 power(0.5)→逼近但弱敵=1.49、碾壓=5.52→margin 2.0 要 power_ratio≳5 才觸=天然「能傷你」。TEST VALUE 待 wave QA 校抖動。
- **★TASK_PRODUCE 納入**（follow-up，系統確認定居 resident 生產隊 `interaction:1065` 進 TASK_PRODUCE 非 MANUFACTURE）→ 藍圖核心「犁田遇劫匪放犁」case 接上。
- **感知鐵律守**（北極星）：preempt 門檻只讀 threat_react（belief 表象+known_reputations+approach），**禁讀 tag**。反向守 3+③ case（弱/中立/帶刀商隊/逼近弱→續 task）由低 threat_react 自然滿足，非 tag 打折。
- **融合驗雙關+③ ALL PASS**：該出現（忙碌/定居隊遇壓境→放 task 反應）+ 反向守（不抖動）+ resident guard（居民迎戰排除→給逃跑不卡死）。
- **反龜縮 flee 0→12**（defensive threat 對忙碌目標顯化）。**seeded 48→52/9/1/381**（factions 8→9=defensive 反應活化世界；QA wave 判）。
- **殘（watch）**：preempt→威脅退→release 回 idle 非續原 task→頻繁遭遇下潛在 churn（THREAT_CADENCE 1日緩解，實測 12 FLEE/1200t 無暴 churn）；PREEMPT_MARGIN=2.0 TEST。

### 憲法溶入 arc — wave1 序4 vendetta done（2026-07-05，merged 2506e6e）

hand vendetta dispatch（`faction_ai:733-741` 直塞 TASK_ATTACK@PRIO_VENDETTA）撕除 → `feud_pull` term（已存在未掛）掛進 攻擊 option。**優先序→權重序**：血仇>致富攻擊=feud_pull weight（`strongest_feud×(0.3+好戰×0.5)`）讓攻擊贏 rank；威脅>血仇=PRIO_THREAT(70)>DISPATCH(50) + rank 內 survival util 碾壓。
- 加 `ctx.feud_target_id`（vendetta_target 掃描）+ 攻擊 applicable 血仇路（`strongest_feud≥FEUD_ATTACK_MIN(0.5) and feud_target_id≠-1`）+ to_task 攻擊多源 target（faction directive>征服 intent>血仇）。`g2.vendetta_trigger` probe 移引擎 dispatch。
- **融合驗 4 錨 ALL PASS**（攻擊 rank[0]、血仇>致富、target=仇敵、威脅>血仇）；framework PASS=7（★S2b vendetta_trigger=1 不 DORMANT）；threat/solo/rung 綠；gate PASS；**seeded 零漂移 48/8/1/380**（feud 攻擊 repertoire 加項、此 seed 罕觸）。
- **感知鐵律守**：feud=已知關係（feud memory/known_reputations），合法。
- **殘（watch/藍圖）**：feud_pull **無 capability gate**（無牙血仇仍攻=送死；舊 hand dispatch 亦無 cap→語意保；血仇=衝動非理性 arguably 對，vs 序2 loot/attack 的 cap grounding 不一致=藍圖裁）；攻擊 target 多源（私仇被 faction 令蓋=directive 優先，藍圖確認要否私仇覆蓋）；FEUD_ATTACK_MIN=0.5 TEST。

### 待開發（大功能）

| 項目 | 狀態 | 說明 |
|---|---|---|
| **Mounts/Wagons 速度** | 🚧 plan + sub 中 | mount bonus max 3X + size_penalty / wagon -30% / 1 人 1 獸 / stable facility / wild_horses 野採 / mount 吃糧 / loot 公式 |
| **NPC 會合/攔截**（W1+W2）| 🚧 spec + plan 寫好，待 mounts merge 後 dispatch | ThreatAssessment + predict_intercept + 4 反應 + trader → outpost-only + trade timeout |
| **戰場 mount unit-level** | 未開 spec | mounts/wagons spec 後續：encounter 騎兵 unit + 衝擊 + 機動 + 戰場 mount 死亡 |
| **named 升階機制** | 未開 spec | 從 anon 抽 → tier 決定 named 初始屬性 |
| **戰俘處置 spec** | 未開 spec | 賣 / 屠 / 招降 / 釋放，loyalty 規則 |
| **外交招募 spec** | 未開 spec | 投靠 / 雇傭軍 / 直接買高 tier |
| **tag drift** | 未開 spec | leader values / event 改 tag（軍隊變商隊等）|
| ~~salary 欠薪後果~~ | ✅ 已存在(2026-06-17 確認) | Bug2 stale：減薪→掉忠誠(salary:73)→N3_defect 離隊鏈已完整 |
| **NPC promote/train AI（W4 層2）** | ⚠ 層1 已修 | promote tick caller 已補(training_system)；遺留：NPC AI 鮮少選 TASK_TRAIN |
| **coin 產出激活（W8）** | 未開 spec | 2026-06-17 量測:金銀礦/鑄幣全休眠,coin 零生成純零和集中。激活 NPC 採礦+鑄幣決策 |
| **UI / 渲染** | ✅ text_ui_main / popup_layer / main.gd 已透過 SimBridge 隔離 WorldState 玩家欄位 |
| **玩家操作介面** | ✅ PlayerApiMapper + PlayerQueryApi + PlayerCommandApi + SimBridge 玩家 API 邊界已建立 |
| **成員檢視 UI（team_ui）** | ✅ 三欄式 member inspector 完成（2026-06-02）：PlayerApiMapper.members_detail + team_stats；TeamUiHelper 靜態渲染；text_ui_main member_mode 狀態機（W/S 選人，1–4 切換子模式：快覽/健康/裝備/能力）；headless_test + team_ui_test 驗證 |
| **anon tier UI** | team panel tier 分布 / 升等進度條 / combat 死亡分檔 |
| **遭遇戰 UI** | EncounterSystem 已有邏輯層，需 hex 地圖渲染 + 玩家指令輸入 |
| **天氣/季節系統** | 影響地形乘數、採集效率、疲勞 |
| **宗教/文化系統** | 新 values 或 faction 屬性 |
| **PersonGenerator 其他 call site** | 玩家招募、天賦事件 |
| **存檔/讀檔** | WorldState 序列化 |
