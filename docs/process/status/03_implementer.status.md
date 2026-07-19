---
role: implementer
code: "03"
status: idle
current_ticket: "hold-warm: crisis-override + immunity fix(branch@b71647ab,HIGH)→to:measurer re-measure seed1337。measurer 揭 crisis 真fire 但 release-then-instant-recommit(team1/19 defection/team13 FLEE 打回原 task)→加免疫窗(try_set 擋同 task 重委派,survival 選別task 接住)。TDD 8/8,gate 64,headless 0 new,determinism byte-identical(90353154)。並行:god-view F/②sweep/slice2 pipeline。剩:hook-prepush(deferred)。"
updated: 2026-07-19
---

# 03 implementer 現況

**crisis-override（HEAD `e77aa99b`,branch feat/crisis-override off main d0ab7f91,已 push,待 measurer，HIGH）**：
- **OUTCOME-based 跨線危機安全網（泛化 ②）**：committed 任何 task 深餓（food<CRISIS_FLOOR=1.5，decouple boost）+ committed N天（CRISIS_DAYS=6，task_start_tick）未緩（food 沒回升≥STALL_RELIEF_MIN）→ `_famine_crisis` true → hook `_evaluate_threat` release → 下 cadence re-rank → survival @80 preempt。涵蓋 5 種 stuck-task（FLEE/建設/外交/等待新領主/併入-pending）。
- **不特判 flee**（survival 主宰 by engine THREAT<SURVIVAL 不變量；valid-flee deferred Arc5）。baseline lazy 蓋（task 變自動重置=進度隊不誤 fire）。互補 ②（非取代，無雙 release；併入-rejection ② gap 由 crisis 覆）。
- **驗**：TDD `crisis_override_test` 7/7；gate 64 removed=0；headless comprehensive mine 6==base 6（0 new，雙格式嚴驗，base 獨立重跑）；determinism 2跑 byte-identical（`2418712a`）。
- **下一站（HIGH，先於 god-view D-後 doom-delta 讀）**：measurer（5 stuck-task 消 + 量化 54% 逃跑真vs broken）→ QA → blueprint release → merge。

---

**god-view Slice F（HEAD `d0ab7f91`,branch feat/godview-slice-F off local main a5495461,已 push,待 measurer）**：
- **+ 增量**：Part C 註訂正（`bbefcb3a`，零caller→11 caller live god-view leak/Slice D，systems 確認自身 glob-bug）；headless test-fixture fix（`d0ab7f91`，measurer 抓 1 new=矛盾情報 scout 測試漏 belief tile_pos→補=0 new comprehensive；同 slice2 款；F1 code 未動 byte-identical 不變）。
- **F1** fallback-to-live→sentinel(-1,-1)+per-site guard 4 site（scout `_commit_conquest_attack:313`/envoy dispatch `_dispatch_envoy:1284`/envoy track `:1368`/encircle `strategic_ai:139`；inquiry:64 不改=legit intel）。缺 belief 不瞎追 live。
- **F2** 刪 8 死 *_pos 欄（exhaustive grep 零消費者；保留 farmable/forage/market/threat_pos；intent 段 rewrite 保 intent_target）。
- **驗**：char bed `godview_f_test` 5/5 PASS；gate 64 removed=0；**★F2 byte-identical 4-way 硬證**（base==F2-only==full==mine-2x=`b2452128`，死欄刪零行為變）；determinism 2跑 byte-identical。F1 在 game_sim_multi 沒 fire（隊互見有 belief）→行為變只在 belief-loss→measurer organic 量 doom-delta。
- **★flag systems**：`predict_intercept` 有 production caller（faction_ai:1369 envoy tracking）→ slice2 Part C 我加的「零 caller」註不實 + envoy 追蹤仍走 live god-view（下個 slice 候選）。
- **下一站**：measurer doom-delta measure（seed1337/42/4201）→ QA → blueprint release → systems merge。

---

**slice2 感知鐵律一致（HEAD `8da63525`,branch feat/slice2-perception off local main bb1e75ff,已 push,待 measurer）**：
- 3 fix 皆 god-view→belief last-seen：**A1** threat DEFEND/求和 move→`belief_pos`（threat_pos 全域改源，鏡射攻擊:194）/ **A2** absorb yield→belief-gate 降級（無 food_est→`has_belief` gate + `population_est` proxy，保守）/ **A3** invite 距離 gate 用 `belief_pos`（INVITE_RANGE=5，無 belief→擋）。
- **Part C**：path_system 3 god-view fn 頂加 landmine 註（零 caller，純註解）。
- **驗**：TDD `slice2_perception_test` ALL PASS（A1 belief 非 live/A2 無 belief→0 有→proxy/A3 遠擋近處理）；gate 64 removed=0；headless base(bb1e75ff)-vs-mine `diff` IDENTICAL（0 new）。
- **★A2 降級 caveat**：pop_est proxy 失 burden 信號→measurer 驗併入 known-target 仍 fire。
- **下一站**：measurer sim measure（seed1337 team19 不再跨圖 settle + absorb 收斂 + threat 不瞬追）→ .qa.json → blueprint release → systems merge。

---
**並行在飛：② 絕境階梯失敗回饋**（branch feat/desperation-ladder-feedback@17fd4fc4，REDO+豁免+env override 全 done，measurer full re-measure + blueprint 裁 B sweep STALL_DAYS 中）。

**② 絕境階梯失敗回饋 REDO 修完（HEAD `bf8452b7`,branch feat/desperation-ladder-feedback off local main 1132bf0c,已 push,待 measurer re-measure）**：
- **機制**：main 真 latch 根 = `SURVIVAL_BOOST` 集體等量 order-preserving（最高 base-weight survival 格恆贏不換序，7隊卡33+天）。② = 失敗回饋:committed option stall→硬排除換次格產階梯。
- **★REDO（measurer organic 揭 stall_exclude=0 沒 fire）**：舊掛 `_trigger_survival`（:3219 uses_unified/subteam-only return→latch隊 reason=unified 碰不到）。修=STAMP+DETECT+EXCLUDE **掛單一源全5路**（同①：unified1554/subteam1768/join1790/solo1896/survival3374，抽 `_stamp_survival_commit`/`_detect_survival_stall` 共用）+ EXCLUDE 收 `applicable(ctx,ignore_stall)` 中央（全rank路共用）。
- **★去額外gather（seed42 0→8 RNG regression 根）**：移 _trigger_survival 第二次 gather；DETECT/STAMP food inline（`effective_food/pop`零RNG）。[[feedback_observer_no_global_rng]]。
- **S1/S2 邏輯**：stall_verdict（relief before/after magnitude 非瞬時，plateau=STALLED）/patience=慎重+(1-求生欲)既有trait/硬排除 cooldown（reject_cooldown idiom）/單一option豁免（rank_survival ignore_stall raw+apply_stall_exclusion）。
- **驗**：TDD ALL PASS(+applicable單一源測)；gate 64 removed=0；headless 0 new；**determinism game_sim_multi 兩跑 byte-identical**；**★organic seed1337 2月 stall_exclude=69 真fire(REDO是0)+teams 68→72 sustain**。
- **下一站**：measurer re-measure（seed1337 latch 7隊主靶 + **seed42 回0** regression 驗 + determinism 三跑 → .qa.json）→ blueprint release-pass → systems merge。

---
**前（作廢）：famine-amplifier ②**（feat/starvation-desperation-fix@ebf4489b；systems 重裁 main 無 amplifier→作廢）；**① single-source** 已 merged local main=1132bf0c（origin 未 push=用戶授權線，downstream diff 對 local）。

**絕境經濟 fix impl A 完（HEAD `ebf4489b`,branch feat/starvation-desperation-fix,已 push,待 systems R²）**：
- **① survival 保序單一源**（`1132bf0c`）：`DecisionOptions.priority_for(opt)` 一處定 priority，全 **5 dispatch 路**讀（含 grep 捕第 5 路 `_try_join_target`）。修「task 切不掉」型 no_forage。（=systems 信提「剩 ① solo/subteam@80」已完。）
- **② famine-amplifier 紮營/乞食/併入**（`764577e9`+`ebf4489b`）：`_famine_severity=clampf((FAMINE_FLOOR-food_days)/FAMINE_FLOOR,0,1)`×人格×K，cap 禁無界，覓食 baseline 不 amplify，weight famine_amp=1.0。
  - 乞食=慎重/信義、併入=(1-野心)/求生欲、**紮營=野心/求生欲**（連貫階梯:低野心→併入 vs 高野心→紮營自立）。修「非暴力象限傻站死」型 no_forage（base beg/join/camp drive 平）。
- **掠奪不 famine-amplify（systems 裁 A）**：留既有 `_intent_fit` 匱乏→搶（已 hunger-scaled+has_weak_prey/capability guard）。連貫階梯:暴力 prey-gate / 非暴力 famine-drive，兩軸不同源，避 double-count over-war。spec §掠奪作廢。
- **驗**：TDD `famine_amplifier_test`(三支)+`survival_single_source_test` ALL PASS；gate 64 removed=0；headless **base-vs-mine 逐條 `diff` IDENTICAL**（同 3 pre-existing，0 new）。
- **★flag pre-merge R²**：紮營人格軸(野心/求生欲)= 我 derive（systems 只命名 option 未給公式；mirror camp weight 野心-dominant + 完成階梯象限）。
- **下一站（照裁定 flow）**：systems pre-merge R² 綠 → measurer measure（is_sim=true+seed1337/42/4201→.qa.json）→ blueprint release-pass → merge。**不跳 QA**。

---

**前：de-patch 軌2 [DONE]**（`03e203dc`），hold warm 等 measurer 乾淨全量

**de-patch 軌2 完（HEAD `03e203dc`）**：閘1 _threat_recent→militancy(刪)/閘5 tribute FLEE→膽識絕望秤/閘6 gate-ok(systems 裁 over-reach,_calc_diplomacy 已 util)/閘7 calc_attack_score 刪/try_proactive 陡化(慎重³,retry alone). ★4 diplomacy 測 migrate(診斷=測用 out-of-range 慎重 2.0「繞 RNG」hack,真 sim=rate 變非語義破→遷 valid 慎重+loop). Tier1 8綠;gate PASS sites=91 removed=2;headless 3+3;CoinAudit=0×4. detector gap 誠實標(try_proactive caller score>0.6 未抓,下 slice widen). 前 constitution_gate v2 `07d1d651`.

**de-patch 軌2（HEAD `412251b0`）**：閘1 _threat_recent→militancy(軍閥備戰/農夫不備,刪 _threat_recent)/閘5 tribute FLEE override→膽識絕望秤(邊逃邊拒)/閘7 calc_attack_score 刪(孤兒). baseline gate-ok 37 標. Tier1 5綠;gate PASS sites=91 removed=2;headless 3+3. **★閘6+try_proactive 陡化 REVERTED**——方向翻轉(極謹慎 never proactive)破 4 diplomacy 測(求貢同 gate 語義衝突),請 systems 裁 migrate 測 or 求貢 gate 分離重設計. 前：constitution_gate v2 `07d1d651`.

**constitution_gate v2（stream① 基礎，HEAD `07d1d651`）**：v1 只抓 TaskArbiter→v2 加全閘型偵測器(值閘 rng/threshold/early_return + 控制流 dispatch_entry/route). enumerate 93 閘(baseline_v2 凍結),PASS sites=93. ★section-A 6/6 覆蓋(偵測器對)+v1 taskarbiter 28 回歸. measure-first 殘留可數→逐閘 de-patch. 誠實:route/近似重複公式=best-effort.

**前：Arc1 need oracle merged `e483f85c`。**

**Arc1 merged（`e483f85c`）**：S1-S6 need-quantity 單一源。blueprint 批 + measurer 乾淨全量對指標全綠. 2 邊界 catch(urgency≠quantity 洞 / 批前嚴查 facility_deficit 殘各算). worktree 清理待 measurer(其 need_oracle_verify_bed.gd 修改中,不 force 刪他人檔). branch feat/need-oracle Keep as-is.

**need-oracle S6 完①（HEAD `fd1625f7`,7 commit）**：_facility_deficit non-food 遷 oracle need(真單一源,grep 淨). facility 仍建(確定性檢 _pick_facility→workshop deficit 1.00,非退化)+determinism byte-identical F85E975A+CoinAudit=0×4+headless 3+3+Tier1 19綠. game_sim Manufacture 兩跑皆 0(非 drift,系統性)——機制確定性檢證正常(facility-build+per-recipe 條件足時產),但短窗場景未達 production 條件;★真 production revive=measurer full-HD 長窗真閘(誠實:sanity 證不了,不篤定已 revive). ⚠註:git add -A 誤 commit measurer 的 need_oracle_verify_bed.gd(arc 驗證床,compile 淨,benign,已 surface). → measurer 乾淨全量真閘.

**need-oracle arc DONE（HEAD `71280560`,6 commit）**：S1-S3 oracle 三分量 / S4a manufacturing 需求驅動+per-recipe 停產 / S4b reserve→need_keep(goods 死鎖解) / S5 溢出雙 sink 守恆+TARGET 退役. Tier1 16綠;全程非退化(trade 活/矛盾率 0.716→0.667 改善/CoinAudit=0 多輪/headless 3+3). ★邊界 systems 釐清確認：farming×14=need-quantity(已 migrate✓)、URGENCY/WARNING/DESPERATION/RECOVER/SLACK=urgency-天閾(離餓幾天→survival 排序)=urgency 域留 NeedHierarchy 零改動(禁 migrate=category error)；urgency-閾一致性=arc5 死常數人格化非本 arc。**Arc1 code 完整,無 more slice** → systems 派 measurer full-HD 真閘.

**need-oracle（HEAD `ef377f44`,已 push,4 commit）**：S1 骨架+food 自用 / S2 供應鏈傳導(gap+gating+多配方) / S3 貿易 demand(非幽靈+野心) / ★S4a **manufacturing reader 切 oracle+per-recipe 停產**(生產目標=need_keep+demand,out 滿→逐配方 skip 不燒 material,sort gap 降序 demand 驅動). Tier1 16綠;**game_sim Manufacture 活躍(14)+CoinAudit=0+無崩=生產真運作非退化**;headless 3+3(3 測遷移). **★S4b(reserve→need_keep)=sanity 驗不出的行為正確性風險**(facility-less 隊 material need_keep=0→傾售全 material,CoinAudit 仍 0 但行為錯,只 full-HD 抓)——停 S4a 乾淨可驗界,請裁 (a)fresh 續 S4b/S5/(b)measurer 先驗 S4a/(c)評 material 傾售風險.

**need-oracle arc（HEAD `c25abfb7`,已 push）**：S1 NeedOracle 新 module(兩量 need_keep/demand 修 R²#1 方向)+food 自用真推導. Tier1 5綠;憲法 PASS;零 reader wire=零產線影響. **★S2-S5 remaining**(供應鏈 gap/貿易 demand/reader 全切+per-recipe 停產+TARGET_PER_POP 退役+★S4 crossover reconcile/雙 sink). 誠實:本 session 連做 8 大塊 ctx 深→S1 乾淨斷點,請 systems 裁下輪 fresh 續 or re-dispatch(base c25abfb7).

**前交付（待 measurer）**：統一生產框架 S1-S4 minus S4.2(6510b52e).

**統一生產框架（HEAD `6510b52e`,已 push,3 commit）**：S1 製造 precondition+no-op tap / ★S2 survival-crush+granary seam+S2 GATE 過(餓隊 farming 13.80>4.40 精確 match R①) / S3 means-end 獨立隊 / S4.1 移 override+S4.3 govern de-patch(sites 29→28)+S4.4 mining 人格秤+S4.5 rule 明文. TDD 17綠;CoinAudit=0+1000tick 無崩+Manufacture 活躍;determinism 6D62C85F;headless 3+3. **★S4.2(A3 utility 化)未做**(大 restructure/非 safety-critical,裁 systems). 誠實標:urgency fire+獨立隊 has_facility 成長待 measurer 坐實.

**★flag**：base fa004b7a 有 stale bed trade_bail_probe_bed.gd(引用 unified-commerce 移除的 absorb/spill→parse error,非 blocking)——merge hygiene 漏,待 measurer/systems 清.

**統一商業 arc 全交付（merged eb047b6f）**：M1-M5 market-as-place + wiring-fix(release) + probe-fix(bail 分因) + coin combo(成員稅). 3 閘全過(reviewer R² CLEAN+measurer coin 大勝+誠實 log). progress/known_issues 系統已 commit 0c9576f3. worktree 清理待 measurer 撿未追蹤 bed. **下=生產 arc 供給牆(sell_no_surplus 51.7%),系統 measure-first,暫不 dispatch**.

**coin combo（HEAD `160301d9`,已 push）**：fold _collect_member_tax 進 branch(person→team coin 月稅,守恆)+tune 強(K0.6/MIN0.15/FLOOR2.0,coin load-bearing). TDD 23綠(★combo:稅前 coin=0 買不成→稅後 468 成交,no_coin binding 破機制證);CoinAudit=0×4;determinism C7862C80;憲法29;headless3+3. live: owner_no_coin 30→5(修證)但 deal 仍2——trade_funnel_bed(seed1337) binding=buy_no_want(商隊②)+LOD 非 coin,無 buy_no_coin. **★headline revive 屬 measurer full-HD(no_coin 72.75% config)**. 下序若不 revive=merchant trade②>LOD.

**觀測前置(HEAD b2c850ce)**：market resolver 全 funnel probe(deal/order_fulfilled/meet)+29 bail 分因 market_bail.<reason>(sell_owner_no_coin/buy_no_want 拆出);盲點閘 PASS.

**wiring-fix（HEAD `77479608`,已 push）**：measurer「resolver 死碼」＝審 stale 911161c9 假象;M2 wiring 實已在 4ceedbd7(sim_runner:353 呼 resolver+interaction 市集格 return). 補 release-at-dest(治 latch 凍結)+整合測. **live 自驗 trade_funnel_bed: deal_market 0→2 resolver 活**;殘 sparsity=站5 arrive 4.4%(域外 LOD,revive-後另刀). CoinAudit=0×4;determinism MD5 C7862C80;憲法29;headless 3+3. → systems 裁 LOD arrive 是否納本刀(我判非本刀).


**當前工單**：unified-commerce（經濟 revive 主刀,大架構）。HEAD `ac18721d`（已 push,4 commit）。M1 target 收斂+M2 market-as-place 到場 resolver(owner-mediated 雙側+order_id 直沖)+M3 掛單人格化+M4 effective_holding/spend_holding accessor 統一(收 supply-seam)+M5 de-patch kill-list(收液化). held 分支全折入. TDD 12綠(訪客買/賣半環/order_id 直沖/SURVIVAL 無單不賣/守恆)；CoinAudit=0×4+InvariantAudit clean；determinism byte-identical(MD5 E9C17F70)；憲法 29；盲點閘 PASS；framework S6 PASS；headless 3+3(0 net new,遷移+刪 absorb 測). 過程抓幽靈貨守恆修(巧遇 surplus 讀 team.resources). → measurer 驗市場 revive+統一無殘+coin 單向泵風險長窗.

**經濟 arc（待 measurer 驗）**：supply-seam(4c2f85cb)/coin-circulation(574d4a56)/market-liquidize(b0cdf624) held→**全折入 unified-commerce(ac18721d)** 一次做好. hole-by-hole 打地鼠改整框架 market-as-place 一次收. coin 循環/流動 tune/threat=revive 後另刀.

**前 arc（全 merged 7a9640bf）**：observability-path-completion（觀測工具全維度收官）。

**觀測工具全根治收官**：三洞（LOD-exemption/RNG-confound/tap-placement）+ 路徑維（reaction/unified/solo/threat tap）+ Probe-suppress + 盲點閘。specimen 全生命+全路徑+非侵入(world+Probe)。

**近期 arc（全 merged）**：絕境找糧+confound；loot-hunger；diplomacy；position-belief god-view；flee(12d3d7b1)；tracer-completeness；observability(7a9640bf)。

**剛完成 2 slice（平行分支，待 measurer/merge 序 systems 協調）**：
1. flee-restore-movement（FLEE no-op 根治）`77d7687c`——3 站設 flee_from_pos+movement _flee_away_tile 真逃+release 清。TDD 7綠(真逃)。
2. observability-path-completion（觀測路徑維補齊 4 Fix）`279ad8c8`——Fix1 reaction tap(內政)+Fix2 unified 挪位/solo 早退+Fix3 threat tap+Fix4 盲點閘 observability_gate。TDD 綠含 on/off byte-identical；盲點閘 PASS(cd=10/cr=1/ci=2/co=2/tryset=6)。
兩者 headless 3+3；憲法 sites=29；bit-identical。→ measurer 驗(flee 真逃+N1回落 / 內政 specimen reaction 敘事)。

**最近完成（merged→main 2a805d35）**：tracer-completeness（第三觀測洞根治）——Fix 1 attempt-tap + Fix 2 heartbeat + Fix 3 盲點閘。tracer on/off byte-identical 硬證。churn_tap_bed 進 repo。**觀測工具三洞全根治**（LOD-exemption+RNG-confound+tap-placement）。

**下個大 slice**：full-HD 觀察（先修好觀測工具，再用它觀察 live 世界；待 blueprint WHAT 設計）。

**近期 arc（全 merged）**：絕境找糧+confound(24c0c442)；loot-hunger；diplomacy-grounded(b02052c0)；position-belief god-view(6aa3ee18)。

**前工單（merged→main b02052c0）**：diplomacy-grounded。

**近期 arc**：loot-hunger-targeting(f8821ada,待 measurer 中性驗)；絕境找糧 A/B/A-2+confound(merged 24c0c442)。全系列真根修（look-before-leap 慾望配現實 + rejection-learning cooldown 破 loop）取代補丁。

**最近完成**：絕境找糧 A/B/A-2 + confound 修 **merged→main `24c0c442`**（中性世界 QA 雙綠）。真根修（買糧 look-before-leap + 遷移找糧 + 併入 rejection-learning）取代執行鎖換皮；observe_velocity confound 修（觀測禁耗 global RNG）。過程 3 次 to:systems flag 皆導向更好設計（belief-food gap→v2 rejection-learning；faction_ai latch 既有機制；2 測試遷移）＝記數功。

**前 arc**：survival-execution-lock thrash-fix(merged,122→0)；specimen 觀測非侵入+trade/threat tap+jsonl+死亡偵測修(全 merged)。

**工單**：mergein-a2 v2（belief-food gap flag→systems 重裁 rejection-learning）。HEAD `dfeecb80`（已 push）。_resolve_join 拒絕分支寫 join_rejected memory + has_acceptable_join_host（host 鏡射 to_task:200 優先序非 OR + PathSystem 可達 + 非近期被拒 cooldown=480）+ options gate。TDD 13綠；憲法 sites=29 零新 try_set；determinism OK；headless 3+3。scenario 3 mirror 由 gate/to_task 同 expression 結構性保證(待 systems 認可覆蓋方式)。

**前工單**：絕境找糧 A+B(2b9428c8,6 約束達成,2 透明報告批准)；belief-food gap flag(導向 v2 更好設計,systems 致謝)。

**工單**：desperation-food-seeking A+B（新分支 `feat/desperation-food-seeking`）。HEAD `2b9428c8`（已 push）。Fix A 買糧 look-before-leap（has_buyable_food gate，受感知鐵律/不濾 stale）+ Fix B 遷移找糧新 survival option（VisionSystem 導出半徑 wild_game[pop守衛]/received 賣單 pos，PathSystem 可達）。6 硬約束全守；★憲法 sites=29 零新 try_set；TDD 8綠；headless 3+3 baseline；determinism 逐點重現。透明報 2 點待 systems 過目：faction_ai latch 既有 cadence 機制已覆蓋(未加顯式)+2 headless 測試遷移(Fix A 語意變 hygiene)。

**前工單串**：reeval_bed 死亡偵測修(aed0f367)；specimen 交易+威脅 tap(200d7e49)；execlock env 開關+merge 工具；specimen-noninvasive merged main。

**前工單串**：specimen 交易+威脅 tap（`200d7e49`，QA 缺口①②）；reeval_bed seed 修；execlock env 開關+merge 工具；specimen-noninvasive merged main。

**前工單串**：reeval_bed seed 修（Option 1，determinism 達成）；execlock env 開關+merge 工具；specimen-noninvasive merged main（2 點校正 ACCEPT）。

**前工單串**：execlock acceptance-bed-envswitch（3 env 開關，我 flag determinism 發現→systems 裁 Option 1）；execlock merge 觀測工具（`0234153e`）；specimen-noninvasive merged main（2 點 spec 校正 ACCEPT）。

**前工單**：execlock merge 觀測工具（`0234153e`）零衝突全綠。specimen-observer-noninvasive merged main（e783d751）；2 點 spec 校正經 systems ACCEPT（記一功）。

**前工單**：specimen-observer-noninvasive（Fix1 移 LOD-exemption + Fix3 write_jsonl）已 merge main（e783d751）；2 點 spec 校正經 systems ACCEPT（TDD-1 寫錯，記一功=execlock 虛構授權反例）。

**最近**：survival-execution-lock thrash-fix merged→main（thrash flip 122→0）；其 REDO 事件經 systems provenance-flag 校正（虛構授權教訓：只認真實 tool result，設計授權只來自真 systems handback）。

---
> 慣例（此檔 owner=implementer 自更）：收工單開工 → `status: working` + `current_ticket: <handback檔名/worktree>`；handback 完 → `status: idle` + `current_ticket: "-"`。卡點也可標 `status: blocked` + 卡點簡述。01 grep 監控。
