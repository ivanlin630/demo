---
role: implementer
code: "03"
status: idle
current_ticket: "-（★二刀 hysteresis 8c7fbd83 systems green-light merge-partial(seed1337 -45%/-53% 大勝+QA 逐tick 食安綠+停切 GATE-A)→handback to:reviewer 請 merge-gate R²→融合驗→merge。③movement 刀撤(QA 翻案=合法 survival flee+resettle 非 bug)。★停切 GATE-A(一刀+二刀=settled-left-home job done)。下一 keystone=facility-build(coin-scope+means-end+carrying-cap valves,等 dispatch)。前:GATE-A MERGED 2d7134e7+mil-facility MERGED 37988f71+武器 arc 收官 produce_need 0bf67e29(reviewer R² CLEAN+systems ratify+green-light,我 --no-ff merge)。全鏈 merged:material-buy v1/v2a(e6519f9f)/tools-demand+cost70(9c551c06)/produce_need(0bf67e29),每層真 bug 已修。workshop-BUILD 剩閘=farming 求生 override=食物經濟下游症狀(blueprint 新 arc,★禁 force-workshop 違憲)。下步待食物地方安全新 arc(measure-first,等 measurer 數字才 spec,別預先動工)。v2b DEFER 收攤。idle-wait。製造 bootstrap 子根②:produce_need 死常數 0.3/0.6→ctx.produce_pull(自家可造 outputs belief demand-responsive worst-shortfall)+tap wanted_not_chosen。TDD 6/6(RED ①neuter 0.90→0/④term const;★⑤god-view 感知鐵律硬驗);headless 0-new;gate PASS 75;determinism MD5 a2835d99(2mo 無行為變=workshop 幾乎沒建 bootstrap ① 仍閘,正是 measure 要坐實)。measure:manufacture.* probe 0→?/TASK_MANUFACTURE 隊數/tools+goods 產量/weaponsmith 建成/感知鐵律 civ 沒聽到=揭子根①→QA。完成=systems+reviewer merge-gate R²。前 tools-demand MERGED 9c551c06。v2b DEFER。:兩修有效(cost70 afford 可達+tools demand 接上)可增量 merge,但 weaponsmith 仍 0=單一剩閘 tools SUPPLY=0(workshop 建少+產 0)。我 scout 坐實終閘深一層(manufacturing:67 TASK_MANUFACTURE gate+生產 option:32 需 has_manufacturing_facility)=製造產能 bootstrap 根(非單 slice)。systems RATIFY 授權 merge(正確 plumbing 銀行)→handback to:reviewer 請 merge-gate R²(複 confirm re-entrancy guard)→融合驗→merge。製造 bootstrap=established-chain arc 範圍等 blueprint。await reviewer merge-gate。v2b DEFER。前工單詳:兩 build 閘一起解:①need_oracle material→{material,tools}+雙遞迴守衛(output-guard+re-entrancy,graph-independent)②order_system tools eligible/proxy③weaponsmith material 80→70。TDD 11/11(RED ①tools 3→0/③b re-entrancy 0→100/⑤proxy 無單/⑥70→80);headless 0-new;gate PASS 75;determinism MD5 a2835d99。measure 終驗=weaponsmith 建成數>0+感知鐵律 tools 未繞道→QA。完成判定=systems+reviewer(merge-gate 複 confirm 守衛 impl)。前 material-buy v2a MERGED e6519f9f;v2b(coin)DEFER。接 v1 branch 疊①③修半破:①full build-need(desire=gate 非 multiplier,全 cost 80 非稀釋 24)②buymaterial_drive 繫建設迫切(shortfall/CAP×max _facility_deficit)③food-ok gate(food>=DESPERATION 鏡射買糧互斥=防餓死)。TDD 8/8(RED ①80→30.2/③1.0 flat/④餓隊 applicable);headless 0-new;gate PASS 75;determinism MD5 99b47415。measurer 量完:三修有效(material peak 117/買料 chosen/food-safe 無迴歸)=真進度可增量 merge,但 weaponsmith 仍 0 建。★真根更深(patch-gate-first):卡兩硬閘非 trade/coin=①facility afford×1.5(faction_ai:2801 非 verdict 引 2572)material 120 vs 封頂 117 ②tools=0 全域(workshop civilian-only cross-type 缺口)。v2b(coin)也建不了→flag systems 裁 build 閘先於 v2b。待 systems/blueprint 裁。Gate B chicken-egg 真根修:material need 只在已有 facility 時 fire→builder 不帶 need→買不到→建不了=weaponsmith-HELD/market-seek-WITHDRAW/facility-buffer-ABANDON 收斂之真根。3-part 閉環:need_oracle _construction_facility_need(means-end,cost-guard 前置+CAP100 防疊爆,build-cost∩output=∅ 無遞迴)/decision_context has_material_market+material_shortfall/options 買料+terms buymaterial(貪婪 scale)。TDD 5/5(RED ①100→0);headless 0-new;gate PASS sites=75(_facility_deficit 呼叫非新閘);determinism byte-identical MD5 57f44e2a 純 utility 無 RNG。handback to:measurer(→QA):買料 DEAL 0→?/post_buy.material/no_want 率/weaponsmith 建成/owner-depletion/§④b sample。前 facility-buffer ABANDON:const 1.5→1.1 觸 owner-depletion(G1a 斷)=reviewer『查 ×1.5 承重』具現。systems 分析=空解窗[weaponsmith material80/mil hold54-80 需 buffer≤1.0 才幫到,但 1.1 已破 G1a→無 buffer 值能幫 weaponsmith 又不破 G1a]→buffer 部分承重+對 weaponsmith 空解=非對的 lever。branch feat/facility-buffer 別 merge/可棄,main 從沒拿改=已 1.5。TDD 沒白做=有價值負結果(RED 驗+具現 depletion 邊界=證 lever 死),已記 known_issue。weaponsmith 真解=material 貿易(Gate B 主線 measure 在飛)。並行 HELD:weaponsmith(0aa7d3ae 同 Gate B)。等 Gate B material 貿易主線 dispatch。）"
updated: 2026-07-22[dispatch→HALT→HOLD-for-QA→WITHDRAW 來回收尾]:QA 最終判治標非治本(doom↓=止 re-seek churn 副效果,真根 Gate B production under-supply)。feat/market-sticky@d26ae644 不 merge、branch 可棄(fix 驗證 stickiness 機制對 re-seek churn 有效=留檔 known,但非該修層)。並行 HELD:weaponsmith(0aa7d3ae 同 Gate B under-production 家族)。主線回 Gate B production(weaponsmith afford/material 分配/build-completion),systems 定案再派。QA 撿獨立 crisis-threshold bug(food=0×500tick 不 fire)已記低優先 known-issue,非我這條。）"
updated: 2026-08-03[統一勞力池全綠交付+乙 revert 完成，皆 await R²]
---

# 03 implementer 現況

**★herald-lifecycle(缺口B)+warring-prereq(缺口A)診斷交付（measure-first、`feat/info-network-whole` 3fcb3194）·await systems 定 2 root→設計 fix**：
- RE-measure#3:herald dispatch 但 distribute=0（缺口B 交付黑洞）+ herald warring 恆 0（缺口A）。
- ★缺口B:isolated 交付鏈全通（spawn→on_leader_death promote P13→travel→DEPOSIT tick20）；full-sim 8-heralds-never-tick 重現不出=full-sim-only 黑洞、非 promotion-break（已排除）；team-carrier 副作用（succession 出 throwaway P13）支持 (a→B) lean 非 team carrier。
- ★缺口A:target 前置（severity_positive=5 夠餓 但 target_resolved=0/unresolved=5=餓隊 solo/faction_id=-1/領主無固定 outpost→_resolve_help_target 解不出），非 severity。
- bed-only+transient probe（Probe-gated 零行為變）。measurement docs/measurements/2026-08-04-herald-lifecycle-warring-prereq-diagnostic.json。handback herald-lifecycle-diag-findings（open）。source consumed。★HOLD 待 systems 定 2 root+設計 fix。

**★資訊網 Part2 (a) side-action 交付（`feat/info-network-whole` ea8d4dbd）·await systems R²→measurer re-measure whole**：
- root（diagnostic 確認）=求援輸主 argmax rank 3/4（category error：派信使≠放棄自救）。fix=求援/偵察脫主 argmax→平行 side-dispatch（de-patch 同勞力池精神）。
- 主 argmax 零改（REGISTRY 移 loser）；新 _step6b2_info_dispatch（cadence-gate 每日/team）評 herald/scout mini-util+throttle；mini-util 錨真值（RELIEF_EXPECT=DESPERATION×FOOD_PPD 2.4/ANON_COST=FOOD_PPD 0.8 DERIVED）；herald+scout 皆 anon empty-handed。
- 全綠：TDD sideaction 6/6（深餓務實派/傲慢撐死 emergent/throttle）+part2 7/7+herald 4/4+scout 4/4、headless 3=baseline、constitution 74、determinism 3 跑 byte-identical 9ACAC8D7。
- ★emergent teams 84→120 attrition 0→1.35（info-net→存活互動）。⚠★perf-watch:warring 1mo ~900s（累積+teams 成長 compounding）→measurer 長 timeout/resume+恐 perf follow-up。vestigial:ctx help/scout/can_send+terms help/scout_drive REGISTRY 已不讀→cleanup follow-up。handback part2-side-action-delivery（open）。source consumed。await R²→measurer。

**★Part2 求援 argmax-loss 診斷交付（measure-first、`feat/info-network-whole` 436f85c2）·await systems 確認 root→設計 (a) side-action**：
- RE-measure#2 揭 help/scout/distribute 仍 0→真 root=argmax-loss（dispatch-gate 修 necessary 但 insufficient）。
- ★求援每 food 級輸 argmax rank 3/4：winner=返家補給（非假設覓食/relocate/買糧、home-based resident）；求援 util 0.04-0.21（非假設 0.35；window[2,3)severity 低、food→0 返家補給 boost 破頂追不上）。求援輸求生=引擎正確但派信使≠放棄自救=argmax 二選一機制錯配→支持 (a) side-action。
- ⑥distribute 依賴驗：distress 塞領主 team_known→distribute candidate 生成 util 0.659=證 distribute=0 下游於 herald 送達（非獨立第二關）。
- bed-only 零 production 改。measurement docs/measurements/2026-08-04-part2-argmax-loss-diagnostic.json。handback part2-argmax-diag-findings（open）。source consumed。★HOLD 修待 systems 設計 (a)。

**★資訊網 Part2 dispatch-fix 交付（`feat/info-network-whole` 85edc4f6）·await systems R²→measurer re-measure whole**：
- root=bootstrap 修好 applicable 但 dispatch=0（herald 需 spare named、小餓 resident 無→送不出）+ seed1337 regression。
- ①spawn-ability applicable gate（can_send_herald=pop>=2/can_send_scout=named>=2、look-before-leap 治 regression+誠實）②求援 herald→anon 1 人 empty-handed 信使（dispatch_anon_messenger:leader_id=-1、1 anon pop、★零 res carry 不 proportional-split；_dispatch_help_herald reframe）。偵察保留 named subteam。util 一字不改 genuine。
- 全綠：TDD part2 7/7+herald 9/9+scout 9/9、headless 3=baseline、constitution 74、determinism 3 跑 byte-identical 2B7A0A5。handback part2-dispatch-delivery（open）。source consumed。★re-measure（herald_dispatched>0+distribute>0+regression 消+scout spare-named）交 measurer。await R²。

**★資訊網 bootstrap-fix 交付（`feat/info-network-whole` d9550ad8）·await systems R²→measurer re-measure whole**：
- root=herald/scout 0-fire bootstrap 死結（target_pos 卡 live-belief、成員從不 meet→無位→永不 applicable；真病 target_pos 無值非 util 低）。
- 修=名冊 fallback：help/scout_target_pos fresh belief→無→_faction_roster_pos（自家勢力固定據點位、組織常識、5 硬界 encode，④誠實標 known gap 非 frozen-snapshot）。util 一字不改（genuine 非 crank）。outpost_hidden stub（界⑤）。gv_mapscan gate-ok（感知鐵律 own-infra legit）。tap help/scout.roster_fallback。
- 全綠：TDD 6/6、headless 3=baseline、constitution 74（god-view detector 綠）、determinism 3 跑 byte-identical E87F455。handback bootstrap-fix-delivery（open）。source consumed。★whole re-measure（症1 distribute/food_delivered、famine、人格分化、fog、hub、economy）交 measurer。await R²。

**★資訊網 whole 全 4 slice build 完+整合 gate 綠（`feat/info-network-whole`）·await systems R²→measurer whole 量**：
- 一 root 三症（propagation dead-end :79）通例修、接既有 seam。S-prop 99deaa80（看板 relay hub、修共位 dead-end）/S-herald d17cd050（求援→TASK_HERALD 送 need 到領主 team_known 修症1）/S-scout d4766834（偵察→TASK_SCOUT 領主查子民帶 need 回 active 症1）/S-trade ac7d3975（交易面 broaden 同格 peer 私產 keep-line 守 修症iv）。各 TDD 綠（5/8/8/3）。
- 整合 gate：headless 3=baseline、constitution 74（★god-view detector 綠=感知鐵律守）、determinism 3 跑 byte-identical MD5 34C8B74（零新 randf）。
- genuine 非 crank：per-option util dump 證分化（help 務實0.640>傲0.102、scout 統領0.800>野心0.160）；calibration 常數皆錨真值（decay=TIME_DECAY_PER_TICK/util base=真severity·staleness/modulation coeff 非 fire-crank）。全量 tap 就位。
- ⚠flag:1mo warring attrition 0.68%→0 teams 84→86（可能 emergent 合作 vs 戰鬥抑制，measurer 跨 seed/月斷）。perf-watch:_market_peer_trade O(teams)/市集到訪。
- handback infonet-whole-delivery（open）。source dispatch consumed。★whole emergent 量（§5 商業/famine/人格/fog/hub/economy）交 systems 路 measurer。await R²。

**★甲 distribute/deliver=0 + 饑荒-flee 診斷（measure-first、別下結論）交付·await systems 讀定 root**：
- 甲（`feat/jia-distribute-diag` b2d67e7d）：三 ask 合批（a/b + iv 交易面 + differential）。root=**買單傳達可撮合方 team_known**（received_buy_orders）、非 argmax(ii)。B:買單達→distribute util 1.3333 rank 0/5 贏。D 差分:唯一差異 received_buy_orders。C(iv):交易面=owner public_storage、私產 surplus buy_no_stock 賣不掉。真世界 0=settled 各據點不共位（propagate_on_arrival:79 要同 tile）→買單從不達。measurement docs/measurements/2026-08-03-jia-distribute-zero-diagnostic.json。handback consumed by systems。
- 饑荒-flee（`feat/famine-flee-diag` 32827479）：root≠(a)決策 pin——resident 給可達已知糧源即 遷移找糧 relocate（與 mobile 同、無結構 pin，blueprint(a) REFUTED）→narrows (b)/visibility（真 §5 大概率 food_seek_target=-1）。★converge jia root:food_seek_target 源②親聞 food 賣單=team_known propagation co-location-only→settled 不共位→從不親聞→學不到哪有糧。measurement docs/measurements/2026-08-03-famine-flee-diagnostic.json。handback open。
- 兩診斷純觀測（jia Probe taps 零行為/零 RNG determinism 4D6FCB46；famine bed-only 零 production 改）。★HOLD 任何 fix build 待 systems 讀定 root。measurer confirm 真經濟床（Probe-on>wrapper timeout、taps 就位）。

**★manufacturing per-labor-allocation de-patch（`feat/mfg-labor-depatch` 0c9a5c6a，stacked on labor-pool 61b2a354）全綠交付·await systems R²**：
- 領導軸真根=facility 從不 RUN（mfg:67 current_task 補丁閘 pre-empt 勞力池，飽和 6.7%/材料 0.000）。移除一行補丁閘 → PRODUCE 隊在自家 outpost 就跑（如 gather）。保留 gate 全自動（need-gated/materials/position/PRODUCE/dedup）。tap manufacture.fired/input_consumed/output。
- TDD 5/5（①de-patch 生效 IDLE 隊產 tools 0.050 移閘前=0 + ②satisfied ③materials ④position ⑤PRODUCE 4 保留 gate 皆 0）。headless 3=baseline、constitution 74、determinism 3 跑 byte-identical MD5 06D9B76D（=labor-pool baseline：warring 無 settled producer→de-patch 行為中性/零 RNG）、非凍。
- ★economy volume before/after + §8 領導軸 ratio 追平 = 交 measurer（warring combat 場景 manufacture.fired=0；機制 unit-proven）。依賴 labor-pool 先 merge。follow-up TASK_MANUFACTURE vestigial 別本輪。handback mfg-depatch-delivery（open）。source consumed。await R²。

**★B idle-labor→建設 genuine 激勵 MVP（`feat/idle-labor-build` eb263529，stacked on labor-pool 61b2a354）全綠交付·await systems R²**：
- ①ctx.idle_labor=maxf(pool_of−Σ demand,0) ②建設 util+idle_employ_value（★anti-crank：全因子 manufacturing 真公式反推、禁 PER_HAND 發明；min(idle/d_new,1)×facility_full_output×need_weight）。guardrail grep clean（只建設、只 PRODUCE、連續乘非 gate）。tap idle_employ.value_positive/build_chosen_with_idle。
- ★自查自修 perf regression：_idle_employ_value 每決策 NeedOracle tile-scan 爆 → tile 快取（LABOR_CADENCE gate 單寫者=owner）。A/B 坐實修後 28s=baseline 零 regression。
- 全 gate 綠：TDD 11/11、headless 3=baseline、constitution 74、determinism 3 跑 byte-identical MD5 4D6FCB46、非凍。
- ★real-sim §8 領導軸 fire-count 交 measurer（Probe-on 全經濟 decision_engine 診斷 loop>590s 超 wrapper；機制 unit-proven+perf-clean）。依賴 labor-pool 先 merge。handback idle-labor-build-delivery（open）。source dispatch consumed。await R²。

**★統一勞力池（`feat/unified-labor-pool` 61b2a354）全綠交付·await systems R²**：
- systems 判「headless +10 皆 intended 新契約非 bug」→ 照 (a)(b) 做完。(a) 10 產線測更新新 model（`_mfg_q` sqrt→LABOR_SCALE、tax fixture 補 TAG_PRODUCE+親聞 material 買單 gain=5.0 不變、collect 補 PRODUCE）。(b) dev-verify：need-gate 雙向（food need>0 fill>0 / gem need=0 fill=0）+ ★供給鏈多級傳播 weapon(5.5)→ore_steel(19.8 PURE self_use=0 純傳導)→ore_iron(79.2 level-2) 不斷。
- 全 gate 綠：headless 3=baseline、labor_pool_test 7/7、determinism 3 跑 byte-identical MD5 06D9B76D、非凍(attrition 0.68%+84 隊活躍)、constitution 74。
- handback `labor-pool-green-delivery`（已 consumed by systems）。await R² 融合驗 + measurer §8。

**★乙 consolidation revert（`feat/scale-consolidation-revert` b65a9692）完成確認·await systems R²**：
- absorb + join_drive 皆回 pre-ce369dca genuine baseline（join=`clampf(0.5+best_protector_rep×REP_MAGNET_W×0.5,0,1)` quality band；absorb=`ABSORB_DRIVE_BASE×resource_slack×(0.5+0.5·yield_pos)×(0.5+0.5·amb_gap)`）。JOIN_PROTECT_GAIN/JOIN_DRIVE_CAP/ABSORB_DRIVE_BASE_V2/AMB_GAIN 全刪。
- 全 gate 綠：headless 3=baseline、constitution 74、determinism 3 跑 byte-identical MD5 FBF182FA。
- handback `yi-revert-complete`（open）。source dispatch `yi-revert-join-too` 已 consumed。await R² 融合驗→merge。

---

**means-end S7 收尾（HEAD 待 commit,branch feat/means-end-s7-cadence off local main 0d10df05[含 S6],在飛）★最後 slice·S7 merge=whole-done**：
- **修（收尾不新增機制）**：①★perf cadence-gate（`ensure_maintain_goals` 加 `team.goal_eval_next_tick` 每 `GOAL_EVAL_CADENCE`=3天 呼一次非每 decide，鏡射 residency_eval；解 known_issues A goal gen facility_deficit 慢）②★goal 掛退 lifecycle（build_F 建成/desire 掉→退移除，免 goal_state 無限累積；maintain 冪等持久留）③must-fix① 護欄不動。
- **驗全綠**：TDD 7/7（RED cadence-gate load-bearing）；headless 0-new+**perf 改善（4m25s<超時，cadence-gate 生效）**；gate PASS 74 removed=0；determinism byte-identical MD5 `da33122a`。commit `737ee409` pushed。
- **下一站**：handback to:systems（`means-end-s7-done`）收+驗+S7 R²→CLEAN merge=**★means-end whole-done**→systems 喚藍圖+QA measure 整系統（用戶原則②）。
- **★★means-end S1-S7 WHOLE-DONE**（待 S7 R²+merge）：S1 骨架/S2 資源型/S3 定位+閉環/S4 設施/S5 委派/S6 折現/S7 收尾。統一決策框架 goal frontier 與 static option 同 rank 池 argmax。**await systems S7 R²。**

---

**前 means-end S6 折現（`2d89ca6c`→MERGED b2a34b4c）★arc 收官·折現**：
- **修（組件 F）**：`_candidate_util` 加 delay-based discount=`payoff×dev_coeff×discount(delay,rate)`；delay 估=移動天數(target hex dist÷移速)+build 工期；discount=`1/(1+rate×delay)`；人格折現率 rate=`DISCOUNT_BASE×(絕境因子+1-慎重)`（絕境高短視/慎重低遠視/極慎重趨 0）；`_mk_candidate` 加 team 參數傳 delay。★護欄:折現乘法(≤1)只變小非變大→must-fix① 護欄不破。
- **驗**：TDD `means_end_s6_test` 8/8（①遠 candidate 折現 util 低 ②近/即時不折 discount≈1 ③人格折現率慎重遠視>衝動短視 ★④絕境遠 candidate 趨零不走遠路 ★★⑤must-fix① range regression 折現後絕境 goal<survival；RED discount 移除→3 FAIL load-bearing）；gate PASS sites=74 removed=0；headless+determinism 在跑。
- **驗全綠**：TDD 8/8；headless 0-new；gate PASS 74 removed=0；determinism byte-identical MD5 `d08b90a7`（≠S5=discount 真改決策）。commit `2d89ca6c` pushed（index.lock 卡→移除重 commit）。
- **下一站**：handback to:systems（`means-end-s6-done`）收+驗+S6 R²（★must-fix① 折現後仍守+人格折現率+delay 有界）→CLEAN merge→**★means-end arc 收官**。
- **★★means-end 長程規劃 arc 收官**（S1-S6）：想要 F→缺料→買/採@forest(絕境不走遠路 折現)→建 outpost→採→湊料→建 F(夠 pop 委派子隊)。統一決策框架 goal frontier 與 static option 同 rank 池 argmax，must-fix① 護欄保 survival 恆贏。
- **S7 followup backlog**（非本 arc）：goal gen cadence 泛化(掛退)/perf optimize(S4 facility_deficit 慢)/facility-type 改建 unowned 優選(S4/S5)/_try_dispatch_or_invite residency 8-12 浪費帶 de-patch(S5)。
- **狀態：await systems S6 R²。means-end arc 收官。**

---

**前 means-end S5 委派 peer option（`3f765ad8`→MERGED b381b5f7）★委派變體+gate②正解**：
- **修**：①`_delegate_variant`（build/settle candidate 產「派子隊做」變體並列 rank 池）②★gate② 正解（applicable=真 viability `pop−settler[clampi(pop/4,2,5)]≥MIN_PARENT_POP_AFTER_DISPATCH=10`，attempt=dispatch 同源→無 8-12 浪費帶）③委派 util=自己做+多線紅利-餘力成本（clamp<survival 沿用）④consumer wiring `_dispatch_goal_delegate`（winner delegate→SubteamSystem.dispatch，unified/solo 派、subteam skip 避 nesting）。★`_try_dispatch_or_invite` 不退（residency repopulate 語意不同我委派=build/settle→flag followup 別強退）。
- **驗**：TDD `means_end_s5_test` 9/9（delegate 變體出現 / ★gate② pop 8-12 not applicable+pop≥13 applicable / 餘力 gate / delegate to_task settler / must-fix① regression / 非 build-settle 不委派）；gate PASS sites=74 removed=0（委派讀狀態+SubteamSystem.dispatch 既有，無新 god-view/RNG）；headless+determinism 在跑。
- **驗全綠**：TDD 9/9；headless 0-new；gate PASS 74 removed=0；determinism byte-identical MD5 `0efd2191`。commit `3f765ad8` pushed。
- **下一站**：handback to:systems（`means-end-s5-done`）收+驗+S5 R²（★reviewer 查 gate②正解+委派 viability+multi-line 無委派恆贏+_try_dispatch_or_invite 不退判斷）→CLEAN merge→dispatch S6 折現。★whole-system-first:S5 只委派+gate②+餘力。**await systems R²。**

---

**前 means-end S4 設施發展（`8a2d862d`→MERGED 2d953ff4）★8 座設施 goal+設施/人力型前置**：
- **修**：①GoalRegistry 8 build_F goal（facility 標記，prereqs 動態導 FACILITY_DEF）②`_resolve_build_facility`（walk resource[build-cost]→facility[outpost-type]→manpower[pop]→全滿 build_F action，first-unsatisfied 前置生 frontier 遞迴 S2/S3 資源鏈）③manpower pop<6→靜默（無假 candidate）④facility goal 生成（`_facility_deficit≥CONSTRUCTION_DESIRE_MIN`+未建→掛 build_F，只 allowed-type/有 outpost 隊算）⑤unowned track（build outpost start_build 自然擋）⑥util 護欄沿用 S2。build_F action=TASK_BUILD→既有 build 挑 wanted facility。
- **驗**：TDD `means_end_s4_test` 7/7（8 build_F registry / build_F action candidate / manpower 靜默 / 缺 material 遞迴資源鏈 / must-fix① regression；RED build_F action load-bearing）；headless **0-new**（3 baseline，S4 慢但 exit 0 非 hang）；gate PASS sites=74 removed=0（讀自有 outpost/belief 非 god-view，無 RNG）；determinism 在跑。⚠ perf：S4 goal 生成加 facility_deficit（team-cadence，只 allowed-type+有 outpost 隊），headless 較慢（可後續 optimize gen cadence）。
- **驗全綠**：TDD 7/7；headless 0-new；gate PASS 74 removed=0；determinism byte-identical MD5 `0efd2191`。commit `8a2d862d` pushed。
- **下一站**：handback to:systems（`means-end-s4-done`）收+驗+S4 R²（★非自判，含 perf 註）→CLEAN merge→dispatch S5 委派/S6 折現。★whole-system-first:S4 只設施+人力型。**await systems R²。**

---

**前 means-end S3 定位型+tile-resolver（`660a9506`→MERGED 73f4e322）★must-fix② 守住·material 閉環**：
- **6 塊**：①location 前置 handler(`_resolve_location_prereq`,{terrain,control?})②★通用 tile-resolver 拆兩類(must-fix②):`find_nearest_terrain_tile`(純地形公共地理全圖掃 # gate-ok)/`find_nearest_known_tile`(所有權/control 讀 team_tile_known belief 禁 god-view)③新 `state.team_tile_known` belief store+`_harvest_tile_known`(bounded vision+relay 兩源)④★material 缺口鏈(`_resolve_resource_prereq` 加採@forest:買不到+RES_HARVEST_TERRAIN material→forest→無 forest outpost→移動到最近 forest tile candidate)⑤util 護欄沿用 S2⑥belief-reachable=bounded hex dist。
- **驗**：TDD `means_end_s3_test` 7/7（①material 缺口鏈 maintain_material:location→MIGRATE forest ②tile-resolver 兩類分流[terrain 全圖 vs known belief]③belief 37<400 只已發現 ⑤bounded reachable）；headless 0-new；★**gate PASS sites=74 removed=0=must-fix② 守住**(terrain scan # gate-ok / known 讀 belief 無 mapscan leak)；determinism 在跑（無 RNG）。
- **★systems 收驗（consumed）**：must-fix②/tile-resolver/belief **全 PASS 別動**；但 material 缺口鏈**未閉環**（只到移動到 forest，缺「到了建 outpost」→own.terrain 仍非 forest→反覆 d=0 移動卡住）。systems 澄清 dispatch 含糊（非我錯）。**REDO 只補 build-closure frontier**：`_resolve_resource_prereq` 採@地形加——隊已在 forest tile 未建→「建 outpost 那裡」candidate（TASK_BUILD in-place，label maintain_material:facility）→own.terrain==forest→採 satisfied（閉環）。+防 d=0（`pos != team.tile_pos`）。
- **驗全綠（REDO）**：TDD `means_end_s3_test` 10/10（+build-closure ②③閉環；全 regression 綠）；headless 0-new；★gate PASS 74 removed=0（must-fix② 續守+build-closure 無新閘）；determinism byte-identical MD5 `123c889b`（無 RNG）。commit `660a9506` pushed。
- **下一站**：handback to:systems（`s3-redo-done`）收+驗+S3 R² 完整含閉環→CLEAN merge→dispatch S4。★whole-system-first:只補 build-closure。**await systems R²。**

---

**前 means-end S2 資源型 resolver（`f9114f74`→MERGED 707238d2）★第一實質 slice·打破 byte-identical**：
- **6 塊**：①組件 A goal 生成（`GoalResolver.ensure_maintain_goals` 冪等 5 maintain goal+active/satisfied，rank_scored 呼）②組件 B `GoalRegistry` 填 5 資源維持 goal（resource 前置）③組件 C `frontier_candidates` 資源型 walk（缺 res+已知市場+籌碼→買 candidate；定位/設施=S3/S4 stub）④組件 E need_keep 泛化任 res（resolver 通用用之）⑤組件 G ★must-fix① util 護欄（`_candidate_util`=payoff×dev_coeff[絕境→0]+clamp<SURVIVAL_BOOST_MAX）⑥winner→to_task 整合（3 rank consumer 用 cand.to_task）。
- **驗**：TDD `means_end_s2_test` 9/9（①resource candidate 出現 to_task TASK_TRADE ②need_keep 泛化 weapon>0 ③location 前置 stub 無 candidate ★④must-fix① range 斷言[絕境 goal util<SURVIVAL_BOOST_MAX,clamp 硬護欄]⑤冪等；RED ①frontier stub→無 candidate/④無 clamp→util 333k>2.5）；headless 0-new；gate PASS sites=74 removed=0（GoalResolver 讀 belief team_market_known 非 god-view,0 新閘）；determinism 在跑（S2 打破 byte-identical=有行為,2 跑一致無 RNG）。
- **驗全綠**：TDD 9/9；headless 0-new；gate 74 removed=0；determinism byte-identical MD5 `57381eace`；★S2!=baseline（有真行為）。commit `f9114f74` pushed。
- **下一站**：handback to:systems（`means-end-s2-done`）請收+驗+S2 R²（★非自判，reviewer 查 range 斷言護欄 must-fix①）→CLEAN merge→dispatch S3（定位型 tile-resolver+team_tile_known belief）。★whole-system-first:S2 只資源型。**await systems R²。**

---

**前 means-end S1 骨架（`e339ac4c`→MERGED，off 0823b823）★HOW arc 開端·byte-identical no-op proof**：
- **HOW spec**：`2026-07-24-long-range-planning-means-end-HOW.md`（R①R² CLEAN）。S1=骨架 slice，接線就位零行為變（candidate 空）。統一決策框架/means-end 長程規劃 arc 開端。
- **4 塊接線**：①`TeamData.goal_state:Array`（組件 A，GoalInstance schema，空初始）②`GoalRegistry`（組件 B，decision/，5 前置 kind 常數+空 REGISTRY）③`GoalResolver`（組件 C，decision/，`frontier_candidates`→[] stub）④`decision_engine.rank_scored_ctx` +optional state/team+goal frontier hook（sort 前，S1 candidate 空=no-op）。
- **驗**：TDD `means_end_s1_test` 7/7；headless 0-new；gate PASS sites=74 removed=0（0 新閘）；★**byte-identical no-op proof 硬證**：S1 2跑一致 + **S1==baseline byte-identical**（both MD5 `d1071c59`，stash S1→baseline 比對=零行為變）。commit `e339ac4c` pushed。
- **下一站**：handback to:systems（`means-end-s1-done`）請收+驗+S1 R²（★非自判）→CLEAN merge→dispatch S2。★whole-system-first:resolver 保持 stub []。**await systems R²。**

---

**前 material-hold-protection（`1017fe31`→MERGED a728fe90）★脫貧第三腿·守護 merit**：
- **root**：`trade_valuation:94` material reserve=need_keep×_reserve_factor，`_urgency=max(food,coin)`→coin_urg(91% chronic)壓 factor→construction-material 賣掉不累積→afford×1.5 湊不到。
- **4 touch**：①`_reserve_factor_food_only`（新，_urgency 只用 food_urg，refactor `_food_urgency` 抽出）②`reserve(material):94` construction-need>0→food-only factor 否則照舊③acute food 天然含 food_urg（食急仍釋放=守護防抱料餓死）④`coin_need` material 對齊 cost×1.5-holding（非 need_keep shortfall）。
- **驗**：TDD `material_hold_test` 10/10（RED ②reserve gate→用 max coin 壓 / ④1.5→1.0 coin_need 20≠120）；headless 0-new；gate PASS sites=74（material-hold 加 0 新閘；removed=1 繼承 extraction de-patch）；determinism byte-identical MD5 `d1071c59`（純算術無 RNG）。handback→measurer 送出。
- **★measurer verdict（cc consumed）**：**守護對了**（兩 seed starve=0 優於 baseline 1/1、無抱料餓死、跨 seed 穩健）但**核心目標未達甚至更低**：peak_material≥105 兩 seed 0%、avg holding 卡 ~50-52 高原遠低 105、facility Δ+1（三階段 +4→+2/3→+1 一路降）。★疑真瓶頸=**material INFLOW（生產/貿易流量）非賣壓**（holding 卡高原=流入太慢，連結 material-afford-trace/facility-build-binding=demand 不缺 accumulation 卡死）。coin_urg 非 robust。
- **★MERGED→local main `a728fe90`（systems green-light on GUARD MERIT）**：守護硬勝(starve 1/1→0/0)+reserve 政策正確=各自站得住正確性 fix→merge。**★撤三腿 escape poverty 宣稱**（afford-unlock refuted peak≥105=0%）。非 retrogression（QA raw T37 material 凍結=真沒進帳非賣掉，liquidity 假設被觀測反駁；三階段 Δ=trajectory artifact）。→ to:systems 確認 merge 送出。
- **★真瓶頸=material INFLOW/供給（root④，blueprint WHAT inflow arc）**：base 資源只 tile regen(forest12/plains0.5)、無 recipe 產 material、plains 定居隊斷離 forest。systems 另 handback 交 blueprint。watch(inflow arc 非 blocker):produce-burn+liquidity(低 prior)。
- **狀態：material-hold MERGED。脫貧三腿(食 GATE-A+coin extraction+material-hold)皆 merged 但**核心 afford 未解=material INFLOW 才是真根**。等 inflow/供給 arc(blueprint WHAT)dispatch。idle-wait。

---

**前 extraction de-patch need-driven（`29c44ad9`→MERGED fb58753f）★coin liquidity 腿**：
- **root**：`_consider_extraction:2364` flat `greed-prud×0.5>0.4` 死常數+不讀 need→中位領袖(0.25<0.4)永不 extract→salary coin 鎖 anon_treasury 取不回→spendable 低→has_specie=false→買不起脫貧鏈斷。
- **3 touch de-patch**：①`coin_need(state,team)`=material-buy(缺料×料價)+food-buy(食壓×糧價)means-end 信號 clamp COIN_NEED_CAP ②`_consider_extraction` 重寫 need-driven（spendable=coin,shortfall=coin_need-spendable,>0 才 extract,砍 flat gate）③`_extract_buffer`=lerpf(BUFFER_MIN 5,BUFFER_MAX 30,慎重)，★BUFFER_MIN>0 非清空。
- **驗**：TDD `extraction_need_driven_test` 9/9（RED ①flat gate→中位不 extract / ③floor 0→貪婪 buffer 0）；headless 0-new；**gate PASS sites=74 removed=1**（de-patch 正確移除 flat 死常數閘=de-patch 簽名，★systems merge 時更新 baseline）；determinism byte-identical MD5 `25655ec0`（純算術無 RNG）。handback→measurer 送出。
- **★measurer verdict（cc consumed）**：**機制對**（fire 66.0-66.3% 兩 seed 一致[原 flat 幾乎不 fire]、真取回 152-169 coin、team.coin +36-37%、無新餓死、determinism 採信）=coin 腿修對可 merge-partial。但**脫貧鏈端到端未達成**（coin_urg 90-95% vs baseline 91% 持平、facility built Δ+2/+3 vs baseline Δ+4 偏低）=撞另兩根（皆非 coin）：①material afford×1.5（reserve_factor<1.05，coin_need 只算缺口沒對齊門檻）②facility-build 排隊限額（每 call 1 outpost、dispatch_fail_afford 壓倒，跟 coin 無關）。
- **★finding→systems**：extraction=facility-build keystone 三根之①coin liquidity（機制對）；脫貧鏈需疊②material afford×1.5+③排隊限額（measurer 前幾輪已坐實 file:line）。→ handback to:systems（`extraction-partial-finding`）呈裁：extraction merge-partial（coin 腿銀行）+序②③。**v2b(coin)收攤**（coin 不再是 blocker）。不逕改。
- **★MERGED→local main `fb58753f`**（systems green-light 全綠[measurer fire 66%/coin+36% + QA 故事綠 + blueprint 認可]+reviewer merge-gate R² CLEAN[buffer floor 補齊]→我 --no-ff merge，3-way content-clean，staged clean）。coin 腿銀行。★de-patch 移除 flat 死常數閘（constitution sites 75→74 removed=1）→ **systems 更新 baseline**（非我檔）。
- **★merge 後=material-hold 第三腿（systems spec 中）**：blueprint 三腿 reframe=食(GATE-A)+coin(extraction)+**material HOLD-protection**（reserve_factor-suppression 同一 villain 三度）：construction-material reserve 對 coin_urg 免疫、acute food 釋放（decouple 兩 urgency，別 survival-floor 全保護=餓隊抱料餓死）+coin_need 對齊 afford×1.5。R²→派我。三腿齊才端到端。
- **狀態：extraction MERGED fb58753f。脫貧三腿=食(GATE-A merged)+coin(extraction merged)+material-hold(第三腿等 systems spec dispatch)。三腿齊才端到端。v2b 收攤。idle-wait material-hold dispatch。**

---

**前 GATE-A 二刀 返家閉環 hysteresis（`8c7fbd83`→MERGED 30dff00e）★破 oscillation**：
- **root**：返家補給 applicable food_days<DESPERATION(3)→隊返家途中 food 過 3→option 消失→漂回 idle/trade→震盪（days_left 卡 1.6-3.0 never 爬升=never 到家補飽）=committed-not-executed。
- **2 touch**：①touch0 `decision_context` c.current_task=team.current_task（自身欄非 god-view）②`options 返家補給` applicable +`or (current_task==RETURN_HOME and food_days<RETURN_HYSTERESIS_DAYS)`，新 const `terms.RETURN_HYSTERESIS_DAYS=5.0`（=RESTOCK_DAYS 重用）→ band[3,5]。
- **驗**：TDD `gateA_hysteresis_test` 5/5（RED hysteresis clause neuter→① returning+food4 applicable false FAIL）；headless 0-new；gate PASS sites=75；determinism byte-identical MD5 `25655ec0`（純算術無 RNG）。handback→measurer 送出。
- **★measurer verdict（cc consumed）**：hysteresis **機制對但非 robust**——seed1337 大勝（GATE-A 19→9 **-53%**/total 31→17 **-45%**）但 seed42 幾乎無效（11→9/持平）。12 隊 trace 四型：①clean-success 3②long-delay-success 2（50+天終究成功）③**chronic-fail-dragged-away 2**（task=return_home 全程卻越漂越遠）④**arrived-but-starving 1**（到家 food 卡 0=薄利）。無迴歸、determinism 採信。
- **★finding→systems**：我 scout ③=**movement 層非 hysteresis**（FLEE-away task-gated 不劫持 return_home、combat=freeze 非 drift→剩候選 strategic_move override 或 move_target 沒同步到家 stale drift，需 trajectory trace）=committed-not-executed 更深（movement/task-priority 層）。④=settled 薄利（systems 已知）。→ handback to:systems（`hysteresis-residual-finding`）呈裁：①hysteresis merge-partial（seed1337 真勝+無迴歸=銀行）②③movement task-execution（trace 定 strategic-override vs stale）③④薄利各別刀+seed robustness。不逕改。
- **★MERGED→local main `30dff00e`**（systems green-light 全綠[measurer seed1337 -45%/-53%+seed42 無害有解釋+QA 逐tick 食安綠+blueprint 認可]+reviewer merge-gate R² CLEAN[touch0+band]→我 --no-ff merge，3-way content-clean，staged clean）。merge-partial 銀行決策層 gain。
- **★③ movement 刀撤**：我 scout 查得對（FLEE-gate/combat-freeze 排除）但沒走完整 trajectory；QA 逐tick 翻案=T41 合法 survival flee>return_home（15 次嘗試）→主動 resettle=coherent 非 bug（premise 被駁）。④T53=split stuck-recover 非 carrying-cap。**殘留 largely spurious**。教訓：「越漂越遠」可能合法 survival 非 bug；我 flag 待 trace 對、未逕改對。
- **★停切 GATE-A**（一刀 merged + 二刀 merge-partial = settled-left-home fixable 子集 job done）。
- **狀態：hysteresis MERGED 30dff00e。GATE-A arc 全 merged(一刀 2d7134e7+二刀 30dff00e)=settled-left-home job done。下一 keystone=facility-build（coin-scope+means-end+④carrying-cap valves 三根，等 systems dispatch）。idle-wait。v2b/其他 DEFER。**

---

**前 GATE-A 認自家食物源（`7a2e22b0`→MERGED 2d7134e7）★merge-partial 銀行**：
- **4 touch（同 home_food_productive 信號）**：①`decision_context` c.home_food_productive=家 outpost tile REGEN_RATE[terrain].food×harvest_factor≥burn(pop×FOOD_PER_PERSON_PER_DAY)，僅 has_home_outpost ②`返家補給` applicable +OR productive ③`restock_need` +productive floor 1.0 ④★`買糧` applicable +not productive（reviewer R² 必加閉商隊 toss-up trap）。★感知鐵律:自家 outpost terrain。
- **驗**：TDD `gateA_test` 10/10（RED 4 touch 各失效對應 FAIL）；headless 0-new；gate PASS sites=75（無新閘）；純算術無 RNG（determinism-safe by construction，det run1 完）。
- **★UN-HOLD resume（systems 翻回，consumed）**：measurer proper end-state 分類（跨 seed 42/1337）翻回=**settled-left-home（GATE-A）=56%/61% 主體**、settled-productive 薄利 23-36%、no-outpost 只 8-13% 少數、forest 0-3%。上輪 T48 是 transient 單點（systems 過度一般化，誠實承認）。∴GATE-A **正是主體修、原 scoping 對**。determinism 補完 byte-identical MD5 `a6b736fb`。→ handback to:measurer（`gateA`）跑 measure→QA（food_days<3 24-37%→? / 返家 chosen / 離家隊脫餓 / forest 不誤鎖 + ★薄利 caveat:with-outpost collect 5.58-6.55<pop10 burn 8→返家大隊可能仍薄利慢餓 harvest rate 另議）。
- **★measurer verdict（cc consumed）**：4-touch **有效**（返家 chosen 1248-2638 強 fire、買糧 560-640 forest 未誤鎖✓、無新餓死、end-絕境 **-16~-40%**、farming 0→8-11、determinism 採信）=真部分勝。但**殘留主體未閉**（GATE-A bucket 仍 58-73%，絕對 -3/-4）=返家 chosen 高卻 end 在外=**「決定返家」接上「真到家補飽」未閉**=committed-not-executed（[[project_hand_obeys_brain_arc]]）。
- **★finding→systems**：我 scout=RETURN_HOME generic movement+到家 collect on-outpost 被動採，無 arrival→harvest handshake。二刀候選（travel 未到/到又離/override 再離）需 trajectory measure 定哪支。→ handback to:systems（`gateA-residual-finding`）呈裁：①GATE-A merge-partial（洩壓真+機制對+無迴歸=銀行）②二刀追殘留（建議先 measure trajectory）③薄利 harvest caveat#6 第三刀。不逕改。
- **★MERGED→local main `2d7134e7`**（systems green-light 全綠[measurer -40%/-16%+QA §④b coherent+blueprint 認可]+reviewer merge-gate R² CLEAN[交叉驗證 tile 公式非偽陽性、RNG 鐵律 clean]→我 --no-ff merge，3-way content-clean，staged clean）。merge-partial 銀行決策層 gain。
- **★二刀=systems spec 中**：殘留=返家閉環 oscillation（Team66/85/59 決定返家→漂回 idle/迎戰/貿易→re-warn，days_left 卡 1.6-3.0 never 爬升=never 到家補飽）=committed-not-executed（手不聽腦家族）。systems patch-gate-first 查 commitment/re-rank 機制→spec 二刀（commitment/hysteresis）。等二刀 dispatch。

---

**mil-facility-cost70（HEAD `f3d201cb`,branch feat/mil-facility-cost70 off main 02d39c9f,已 push）★trivial·閉同族 afford-ceiling 洞·無 measure**：
- smeltery(:81)+armorsmith(:93) material 80→70（仿 weaponsmith 已 70；70×1.5=105<天花板 117）。★僅這兩（mint 100 bootstrap/其餘≤60 不動）。獨立於 GATE-A（不同檔 outpost_system）。
- **驗**：TDD `mil_facility_cost70_test` 5/5；headless 0-new；gate PASS sites=75；determinism byte-identical MD5 `a2835d99`（純常數無 RNG，2mo 無行為變=上游堵短期不建）。
- **★MERGED→local main `37988f71`**（reviewer merge-gate R² CLEAN[逐行核只動 2 值、不碰 afford gate faction_ai:2801、值算對]+systems dispatch→我 --no-ff merge，無 measure 合理）。閉同族 afford-ceiling 洞。

---

**produce_need demand-responsive（`50337300`→MERGED 0bf67e29）★製造 bootstrap 子根②**：
- **root**：「生產」util produce_need=死常數 0.3/0.6（不隨市場）→ workshop 隊沒選生產→產 0（measurer:0 個 manufacture.* probe）。
- **2 修**：①`decision_context` gather 加 `c.produce_pull`=自家可造 outputs worst-shortfall ratio（need_keep+demand[★親聞單]-hold）/target，僅 has_manufacturing_facility ②`terms.gd` produce_need 死常數→`ctx.produce_pull`。+ tap `produce.wanted_not_chosen`。★感知鐵律:demand=_trade_demand 讀 team_known 親聞（非 global）。
- **驗**：TDD `produce_demand_test` **6/6**（RED ①neuter 0.90→0 / ④term 死常數 0.6≠0.7；★⑤god-view fixture 沒聽到→produce_pull 不含=感知鐵律硬驗）；headless 0-new；gate PASS sites=75（無新閘）；determinism byte-identical MD5 `a2835d99`（純 utility 無 RNG；digest 同 tools-demand=2mo 場景無行為變，workshop 幾乎沒建=bootstrap ① 仍閘）。
- **★measurer verdict（cc consumed）**：responsiveness **修對**（TASK_MANUFACTURE 0→1、生產 chosen 10、produce_pull 隨市場、goods 無亂產、determinism 採信）=真進度可增量 merge（verdict→blueprint）。但 tools/goods/weaponsmith 仍 0——**我預測的子根① 證實=workshop-BUILD 終閘**（`appl_kill_nofacility` 7479/9136=想產無 workshop 被擋，workshop 3mo 才 0→1）。
- **★★下 thread=workshop-BUILD（我 scout 坐實+refine）→ flag systems**：閘=`_pick_facility` argmax（`faction_ai:3089`）via `_facility_score`（3132）=terrain_fit×(1+_facility_deficit)×personality，workshop 輸 apothecary/farming/stable。★**refine systems goods 假設**：workshop deficit=min_per_res(goods/tools/arrows)，但 goods target=0→min_per_res **SKIP 非 binding** → deficit 由 tools/arrows self_use 驅動**非** goods=0 starve →「apothecary 40× 勝」需 measure _facility_score 三因子分解。→ handback to:systems（`workshopbuild-finding`）呈裁下 thread 範圍（blueprint owns goods 消費/facility 平衡 WHAT）。不逕改。
- **★MERGED→local main `0bf67e29`**（reviewer merge-gate R² CLEAN[produce_pull impl 精確吻合 spec、belief-gate 硬驗 _test_perception_gate、tap 純觀測、零 RNG、融合綠]+systems ratify+green-light=全綠→我執行 --no-ff merge；3-way content-clean[main delta 純 docs]，staged clean 無殘留，髒檔未動。local main 不 push）。**武器 arc 最後一刀。**
- **★★裁②workshop-BUILD 終閘=blueprint 已收斂（別攻）**：根=**farming 求生優先 override 碾壓**（`_facility_score` survival-crush，**正確機制非 argmax/personality/terrain bug**）。食壓下隊卡 subsistence 升不到 specialization→武器 gap=**食物經濟下游症狀**（連回最早 starvation 根）。★★**禁 force-workshop 補丁（違憲）**：別碰 `_facility_score`/`SURVIVAL_CRUSH`/argmax，3-factor measure 取消。
- **★武器經濟 arc 正式收斂完畢**（food→goods→weapons→material→tools→workshop-build 每層真 bug 已修:material-buy v1/v2a/tools-demand/cost70/produce_need）。**v2b(coin)DEFER 收攤**。
- **★武器經濟 arc 收官（全 merged）**：material-buy v1/v2a(e6519f9f)→tools-demand+cost70(9c551c06)→produce_need(0bf67e29)。food→goods→weapons→material→tools→workshop-build 每層真 bug 已修。
- **下一步：待食物地方安全新 arc 工單（blueprint 裁 vision，★measure-first——systems 派 measurer 診斷 subsistence-trap+food-local 失敗根，等數字才 spec，別預先動工）。v2b(coin)DEFER 收攤。idle-wait。**

---

**tools-demand + weaponsmith cost70（`bdbcfd22`→MERGED 9c551c06）★兩 build 閘一起解**：
- **root**：weaponsmith 0 建=兩硬 build 閘皆非 material-trade（血證 T26 material80+coin70 仍不建）。tools=0 全域=生產端 demand-routing 缺口。
- **3 修**：①`need_oracle._construction_facility_need` material→{material,tools}（CONSTRUCTION_COST_RES 白名單+cost_r 泛化）+★★**兩層遞迴守衛**（tools=build-cost∩workshop-output=hazard）:(a)output-guard `if res in _facility_output_res(facility): continue`(b)re-entrancy `static _construction_visiting` 入口切環（graph-independent；A-class evaluator 讀 need_keep(outputs)=真回呼路徑）②`order_system` :6 eligible+:121 proxy 加 tools ③`outpost_system:87` weaponsmith material 80→70（blueprint 裁②，70×1.5=105<天花板 117；僅 weaponsmith）。
- **驗**：TDD `tools_demand_test` **11/11**（RED ①tools 3→0 / ③b re-entrancy 0→100 / ⑤ proxy 無單 / ⑥ 70→80）；`material_buy_test` ① 80→70 維護+綠；headless 0-new；gate PASS sites=75（無新閘）；determinism byte-identical MD5 `a2835d99`（純 utility 無 RNG）。
- **★measurer verdict（cc consumed）**：兩修**皆有效**（③cost70 afford 可達 T23=113/T35=110≥105 / ②tools demand 接上 post_buy.tools 795-796 / determinism 採信 / 無新閘）=真進度可增量 merge（verdict→blueprint）。但 weaponsmith 兩 seed 仍 0、**單一剩閘=tools SUPPLY=0**（global tools 全程 0、goods 也 0、只 1 workshop 晚建產 0；§④b 全 9 建成皆 tools-cost=0 設施）。
- **★★真根深一層（patch-gate-first）→ flag systems**：我 scout 坐實終閘比 measurer 深一層——生產只在 `current_task==TASK_MANUFACTURE` 跑（`manufacturing:67`），而「生產」option applicable 需 `has_own_outpost AND has_manufacturing_facility`（`options:32`）→ workshop 先建才可生產。兩子根:①workshop 建太少（goods=0 經濟→desire 低→少建=雞生蛋）②建了的 workshop 隊沒上 TASK_MANUFACTURE（無 manufacture.* probe=沒選生產）。=製造產能 bootstrap 根（[[project_established_chain]] 五層雞生蛋家族，**非單 slice**）→ handback to:systems（`toolssupply-finding`）呈裁範圍。不逕改。
- **⚠ 已實作預警項**：tools=workshop output+weaponsmith build-cost 遞迴風險 → 雙守衛已納（output-guard graph-依賴+re-entrancy graph-independent 一勞永逸，reviewer verdict 建議 1）。
- **★MERGED→local main `9c551c06`**（reviewer merge-gate R² CLEAN[re-entrancy guard 親驗 balanced+poison-TDD 結構驗]+systems ratify+green-light=全綠→我執行 --no-ff merge；3-way content-clean[main delta 純 docs 零 code overlap]，staged clean 無殘留，髒檔未動。local main 不 push=授權工作線）。
- **下一步（等 systems spec+R²→dispatch）**：製造 bootstrap=established-chain arc。systems 在 spec **produce_need demand-responsive**（子根②：`terms.gd:103-105` 死常數 0.3/0.6→讀 belief demand，解「已建 workshop 不產」）=另 branch `feat/produce-demand-responsive`（off merge 後 main）。等 systems spec+R² CLEAN 派我。**別逕攻 bootstrap**。v2b DEFER。
- **狀態：tools-demand MERGED。idle-wait produce-demand-responsive dispatch。**

---

**★material-buy arc（v2a MERGED e6519f9f;v2b DEFER→tools-demand 續，above）**：
- **systems ruling（consumed）**：build-gate finding **採信**（patch-gate-first 好判斷，不逕改呈系統正確）。v2a **merged e6519f9f**（三修真進度）。兩閘拆軌：①**tools=0** reframe=生產端 demand-routing 缺口（order_system 無 tools 買單→demand=0→workshop tools gap 恆輸 goods），spec `2026-07-23-tools-demand-registration.md` 進 reviewer R²，CLEAN→派我（**新 branch feat/tools-demand**，修 need_oracle `_construction_facility_need` material→{material,tools}+output-guard、order_system tools eligible/proxy）②**afford×1.5** 不可安全下修（mint buffer load-bearing），真閘=material 天花板 117<120→呈 blueprint 裁 WHAT。**v2b(coin) DEFER**（我證 build 閘不解 coin 無用）。
- **⚠ readiness 技術預警**：tools = **workshop output + weaponsmith build-cost** → 正是 v1 標「build-cost ∩ facility-output ≠ ∅」遞迴風險案例。tools-demand 擴 `_construction_facility_need` 到 tools 必帶 **output-guard**（systems 已標）→ 收 dispatch 謹慎實作 visited-set/output-guard。
- **狀態：idle-wait tools-demand R² CLEAN dispatch。**

---

**前 material-buy v2a（`1076c0d5`→merged e6519f9f）Gate B 半破→閉環①③**：
- **v1 半破根**：need 進 need_keep 但**執行稀釋**（QA:want 接上 buy-to-80 未達）。systems dispatch v2a（R² CLEAN+food-ok gate 已納）。
- **3 fix 疊 v1**：①`_construction_facility_need` `total+=cost_mat*desire`→`total+=cost_mat`（desire 當 gate，過閘=全 cost 80 非稀釋 24 白買）②`buymaterial_drive` 繫建設迫切 `shortfall/CAP × max _facility_deficit`（+`NeedOracle.max_material_facility_desire`+ctx `material_build_urgency`，競建設非墊底 1.7%）③★`options 買料` applicable +`food_days>=DESPERATION_DAYS`（鏡射買糧互斥=結構防餓死，買料非 survival-class 防搶 survival rank）。
- **驗**：TDD 8/8（RED ①80→30.2 / ③drive 1.0=1.0 flat / ④餓隊 gate 移除→applicable）；headless 0-new；gate PASS sites=75（無新閘）；determinism byte-identical MD5 `99b47415`（純 utility 無 RNG）。
- **★measurer verdict（cc consumed）**：三修**皆有效**（material peak T28=117 vs baseline 98 / 買料 chosen 80-307 / food-ok starve 0 無餓死回歸 / determinism 採信 / 無迴歸）=**真進度可增量 merge**（verdict→blueprint）。但 weaponsmith 仍 0 建、DEAL≈0-3、no_want 77。
- **★★真根更深（patch-gate-first）→ flag systems**：weaponsmith 卡**兩硬閘皆非 material-trade/coin**：①facility afford×1.5 **實在 faction_ai:2801**（measurer verdict 引 2572=outpost 閘，實 facility 閘 2801 同 ×1.5；ref 校正）→ material 80 需 **120** vs 隊封頂 ~117 差 3 ②**tools=0 全域**：source=workshop(3205,civilian-only) 但 weaponsmith military-only=**cross-outpost-type 供給缺口**→tools 恆 0→afford tools fail。血證:baseline T26 material80+coin70 都夠 base cost 仍沒建=閘非供給/錢。**∴我計畫 v2b(coin)也建不了**（material 封頂<120+tools=0 擋）。→ handback to:systems（`buildgate-finding`）請裁 afford×1.5 對 facility 是否過嚴(×1.3=104 可達)+tools 產/取鏈，**build 閘先於 v2b**。不逕改（settled-architecture/measure-sensitive）。

---

**前 material means-end buy v1（`ca199844`，QA 判半破→v2a 續，above）★Gate B 真根**：
- **Root**：material need **只在已有 facility 時 fire** → builder 隊不帶 material need → 買不到 → 建不了 weaponsmith/armorsmith。material trade under-supply latch（weaponsmith-HELD 0aa7d3ae / market-seek-WITHDRAW / facility-buffer-ABANDON 三收斂之真根）。
- **3-part 閉環**：①`need_oracle._construction_facility_need` means-end（outpost 想建 facility desire≥0.3 折 material cost 進 need_keep；**cost-guard 前置**+`CAP`=100 防疊爆；build-cost∩facility-output=∅ 結構無遞迴）②`decision_context` has_material_market+material_shortfall+gather ③`options 買料`(mirror 買糧)+`terms buymaterial_drive/buymaterial`(商業非 value→貪婪 scale 人格化)+`faction_ai._nearest_market_outpost_with`。
- **驗**：TDD `material_buy_test` 5/5（RED 確認 neuter→① 100.0→0.0）；headless 0-new（3 baseline）；gate PASS sites=75（新 option/term/`_facility_deficit` 呼叫**非新閘**）；determinism seed1337×2mo×2 跑 byte-identical MD5 `57f44e2a`（純 utility 無 RNG，diff 無 randf）。
- **★measurer verdict（cc consumed）**：需求半修對（post_buy.material 0→**127**、買料 chosen 87-102、determinism 採信、無迴歸 doom 不惡化）。但目標半未達：DEAL≈0（1337=2/42=0）、weaponsmith 0→0 未建、weapon 未產。chicken-egg **未破**（想買了但買不到）。verdict→blueprint、specimen→QA。
- **★第二半 2 blocker（待 blueprint 裁 merge-partial vs iterate → systems spec，別逕改）**：①**執行 want-gate no_want 72%**：`trade_valuation.gd:94` `reserve(material)=need_keep(含建設 need)×_reserve_factor`（非活命品液化係數<1）→ **建設 need 被稀釋** → holding>稀釋 reserve → no_want。post/execute 落差已坐實 file:line。②**coin 餓**：買方 coin_after≈0.25-0.72、qty 1-2，累積不到 weaponsmith 80-120。第二半治點（measurer 建議，非指令）：執行側 want 認建設 need（建設品 reserve 不液化如 survival，或繞 reserve_factor）+ 買方 coin。R² 過 reviewer 再 dispatch。已 scope，待信號。

---

**beast-fix（HEAD `1524d5ed`,branch feat/beast-fix off local main f469127f,已 push,待 measurer）**：
- **兩 root**：①id 碰撞—`_next_beast_id` BeastSystem instance var→每 `.new()` 重置 -1000000→全 beast 撞 id→create_team 覆寫。修=counter 移 `WorldState.next_beast_id`（per-world fresh，★禁 static）。②決策洩漏—beast(faction_id=-1)落 evaluate_all loop2/loop3→succession 晉升領袖+ambition+survival。修=兩 loop body 頂 `if team.beast_kind != "": continue`。
- **驗**：TDD `beast_decision_leak_test` 11/11（RED→GREEN；id 唯一/per-world fresh 禁 static/beast 不晉升-派 task-ambition/對照真隊仍晉升）；headless `=== DONE ===` 3 fail=baseline 0 new；gate 64 removed=0（continue+string compare 非新閘）；determinism seed1337 3mo 2 跑 byte-identical md5 `ff7878af`。
- **下一站**：measurer（seed1337/42/4201 真隊無 regression starve/pop/teams + 真隊 belief 無 -1000000 幻影）→ .qa.json/餵 blueprint 或 pre-merge to:systems。

**hook-prepush（HEAD `22604514`,branch feat/hook-prepush off main 35e9ee8f,已 push,systems RATIFY+HOLD）**：
- pre-commit→pre-push 遷移，折 constitution_gate（恆跑）+verification_gate（branch-scoped fast-exit）；刪舊 pre-commit。build done、systems 判設計過。**merge+install 都 HOLD 待信號**（starvation 落地+beast 在飛+measurer prove）。

---

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
