# 開發進度

## 📍 當前狀態（2026-06-22）

- **🏛 P0 G1a 礦村（山村特化）✅（merge `61af5c4`）→ 鑄幣脈絡 default 真活**：量測推翻 stale premise（[[feedback_verify_backlog_fresh]]）——非「無金礦 tile / 鑄幣 code 壞」，真根 = **金礦只在山地、山地住不了人(food 再生 0.5)、採礦需在地 → 金礦物理上不可開採**（雞生蛋死鎖）。用戶裁模型 **B 礦村**（蓋在含礦山的不自給 civilian outpost，外部供糧）。最大複用既有（自格採 ore/mint facility/_pick_facility/food 買單/糧倉/subteam 建造）。S1 礦脈保證 guard / S2+ 貪婪 leader 選 **ore-mountain 本身**（非鄰接平原，threshold gate 保稀有=非貪婪不建）/ S3 bootstrap 攜糧+market food buy / 施工子隊韌性（survival/betrayal/tribute/encirclement/discipline/tag-shift 豁免，皆 10 日 CONSTRUCT timeout 或 build 完成或滅團兜底，**只豁免行為不碰死亡/守恆**）。**結果**：default.json r8 自然 fire 4/5 run（mine_founded>0、mint>0、coin 增）、world_sim 1/1、真鏈端到端證（ground ore→vault→mint→coin，無 pre-seed）、coin_eq 0、InvariantAudit 0、framework S1-S6 PASS DORMANT=0。3 輪 review（含 opus 終審 APPROVE）抓並修：far-construction 雙計(LOD 前提錯→刪)、distance 免疫過廣、zombie latch、facility_deficit 洩漏、測試 pre-seed。spec/plan `2026-06-23-g1a-mint-mining-village`。**backlog（known_issues）**：mint coin-cap 燒 ore off-ledger(pre-existing,G1a 首 fire 才浮現)、非貪婪 leader 在無平原時仍可建礦村(稀有邊際)、dense map distance 免疫未測。
- **🏛 他域遷入 ruling 到 + HOW 序定（P0 完成，P1-P5 待）**：藍圖裁 `otherdomain-ruling`（consumed）解鎖全卡項。**協調=混合**（stakes-to-faction→頂層協同 faction_duty 壓人格；team 日常 op→個體人格）；**believability 守則**（頂層決 WHETHER 人格染 HOW + 脫軌逃閥非 100% 服從）；**主動開戰=稀有+蓄意+吃 belief**（霸主決策、readiness 門檻）；**mint 現在排 G1a**（覆前判緩做）。**HOW 序**（小切片先、dependency-correct，每 Phase spec→plan→worktree→跑驗證套件 TC+S 魂）：
  - **P0 G1a mint ✅ done**（merge `61af5c4`，見上條）：礦村模型 B，default 自然 fire 4/5。
  - **P1 個體域 options**（不需 faction seam，最廉）：scout（既有 TASK_SCOUT→option）/ 小掠奪（survival loot→option）/ 小徵收。**解鎖 loot option**。
  - **P2 survival 全隊退役 + loot/join 還經濟隊**（依 P1 loot）：退役舊 `_evaluate_survival` 雙 owner、loot/join/camp/beg/hunt 遷引擎+全隊化。閉框架完成塊③ + 經濟↔衝突橋（藍圖標記1債）。
  - **P3 混合協調 seam**（重塊）：`faction_duty` term（霸主 directive→成員協同；stakes 高權壓人格/日常弱 term）+ 霸主頂層決策步 + believability 兩不變量寫 invariants.md。
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
| `movement_system.gd` | tile_pos 移動（`_step_team` 用 A* `_calc_next_step`，繞山）；weighted 均速 (NAMED_WEIGHT=3 + tier-aware anon speed)；time_mult（日夜）；fatigue/超載懲罰；wagon 地形懲罰；strategic_assignments 優先邏輯；移動時記 `last_tile_pos`；WORLD_SPEED_MULT=5 → 菁英 0.2 天/hex（平民 0.29 天/hex）；process 回傳 `{arrived, moved}`；stuck log 加 source（task + strategic_assignments）|
| `path_system.gd` | A* `find_path`（同-tick cache）；`eta_ticks`/`_team_speed_mult`；`observe_velocity`（限視野+距離雜訊）；`estimate_catch_up`（reachable/eta/reason，ETA cap=AI_ETA_LIMIT 1200 tick = 25 hex plains at WORLD_SPEED_MULT=5）|
| `event_system.gd` | Registry 架構；on_leader_death；PersonGenerator fallback |
| `person_generator.gd` | 從匿名人口晉升記名 NPC；tag 屬性/技能偏移 |
| `faction_ai_system.gd` | 策略層 evaluate_all；values 整合；成員 task 指派；SoloAI；tag 過濾；discovered-only 目標；`_find_*_target`（trade/prey/strong/aid）用 `PathSystem.estimate_catch_up`（reachable 過濾 + eta score）；每 20 Tick 外交評估；每 BETRAY_CHECK_INTERVAL 背叛評估；`_evaluate_prosperity_attack`（野心驅動征服 cadence 3 日，軍隊 tag 加倍 1.5 日，個性公式 attack_score / readiness threshold / find_prosperity_prey）；`_trigger_survival` Path 1 B 分支（遠 outpost + 殘忍/好戰 → 改 TASK_LOOT）；stuck 視為 idle 允許重評（_is_stuck → STUCK_TASKS）|
| `diplomatic_ai_system.gd` | _calc_diplomacy_score（5 因子）；try_proactive_diplomacy；handle_diplomacy_message（4 動作）；_form_alliance；_update_reputation；consider_betrayal；_execute_betrayal |
| `strategic_ai_system.gd` | 戰略目標更新（expand/defend/trade_net）；包圍指派；突圍指派；威脅評估（team_discovered，非全知）；in-map check（off-map target → nearest_valid_tile）；ENCIRCLE_DIST=1 / BREAKOUT_DIST=2 / BREAKOUT_NEAREST_THRESHOLD=3；trade_net handler（dispatch idle 商隊找有 goods/coin 鄰商隊）|
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
