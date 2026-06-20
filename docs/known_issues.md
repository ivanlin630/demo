# Known Issues

> 最後更新：2026-06-16 | **本檔只列開放項**。已修項（✅）移 `docs/archive/resolved_issues.md`（保留根因/修法/教訓,可搜尋）。
> 來源：動態測試 + code review + QA harness 遍歷。
> **仍有效真 backlog**：Bug2(salary floor 後果)、Bug5(休眠)、W4(NPC promote/train + leader 駐留)、W3(dist tune)。（P5 C-1~C-6 對稱缺口 ✅ 2026-06-16 reframe+實作,見下 P5 段。）
> **圖形 Main.tscn 項 moot**：`run/main_scene = TextUI.tscn` → S5/U5/U6/U7/U8/U9 等 graphical 項凍結,復活圖形 UI 才解。


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
- **⚠ [中] 懸空 known_reputations 死隊（world_sim 2 年揭，~2380 InvariantAudit violations，root cause 未定）**：隊死後存活隊 `known_reputations[死隊]` 重現懸空 entry。`erase_team`(world_state:147)死時清 known_reputations，但某路徑死後重注入死隊 id（疑 `update_reputation` caller 未驗 liveness；reconcile_firsthand sid / 外交其一）。**試補 `erase_team` 清 team_intel（belief store，G3b 加無登記此清理 choke = 框架債 [[project_framework_seams]]）→ violations 沒降 + 改了存活動態(8→3→5,清死隊 belief 影響決策)→ 猜錯已 revert**。行為良性（死隊聲望不再被查），但記憶體單調增 + audit 噪。只長跑+強審計(InvariantAudit.check)現形，game_sim_test 週期審較弱抓不到。**修需 systematic-debug 找重注入 caller，非猜**。

## G1 供應鏈進度

- **G1a（鑄幣觀測：W8 機制已存 + log/驗）**、**G1b（訂單 infra + 餘→賣盤 + 需求驅動生產）✅**：訂單走 message（權威存發起隊 `active_orders`，emit 為可失真傳播副本）；`OrderSystem.tick_team_orders` faction_ai cadence 發賣盤 + 過期清；`manufacturing._run_recipe_group` 讀 `received_buy_orders` 偏向需求 recipe（訂單真 reader，非 dormant）。
- **G1d（商隊訂單驅動 + 短缺買單）✅**：商業 archetype 隊 targeting 改讀 `team_known` 訂單（`best_arbitrage_order`，殘缺情報），取代 `_find_trade_target` 的 `team_discovered` 上帝視角（後者降 fallback/標 deprecated，最終應刪）；`tick_team_orders` 短缺發買單（料/武器 < `SHORTAGE_QTY`）→ G1b infra 閉環（賣盤有 reader、生產買單有來源）。到場履約走既有 interaction 同格 trade（守恆）。撲空 = 訂單 stale → `local_value` glut，emergent 無新機制。
- **#1 訂單履約 ✅（2026-06-20 merge `186e433`）**：`OrderSystem.settle_orders`（`_resolve_market` 後按 res 淨變沖 `active_orders`、填滿移除 + 點亮 `g1.order_fulfilled`/`g1.arb_hit`）。純記帳、守恆無關。settle 機制單測證正確（履約/部分/撲空/sell 對稱）。
- **⚠ [中][measure-first] order/trade 迴路 runtime 半 inert — 商隊 runtime 不交易（履約 merge 後揭）**：履約 code 正確但 world_sim 該 run **`g1.arb_attempt=0` + `[Market]成交=0`**（整 run 零交易）→ 履約率仍 0%。**非結算 bug，根因上游**：商隊 `_merchant_trade_target`(faction_ai:1180) 的 `best_arbitrage_order` 從未回非空單 → 沒商隊被 dispatch TASK_TRADE。懷疑（**未驗，別猜** [[feedback_avoid_rabbithole]]）：①商隊沒成形/沒掛 `TAG_MERCHANT`(archetype 派生) ②`received_buy/sell_orders`(team_known order message) 空 — message 沒傳到商隊 or `MERCHANT_MAX_RANGE`(20) 外。
  - **WS-1 食物糧倉已 merge（`cde372c`）= 殺幽靈囤 + 滿了賣決策**：food→capped 糧倉、消耗合併池、food sell 單 fire。囤糧崩（4-5萬→cap≤18000）、無過餓。**剩待後續**：①**UI/面板讀 team food 誤判**——定居隊 team.resources food 現=0（全在糧倉 public_storage），面板/FoodLedger 若讀 team food 顯示「沒糧」（消耗合併池已正確不誤餓，純顯示層）→ 需改讀「team+自家糧倉」合併。②**food 買單側未做**——糧倉滿發 sell，但飢荒隊買 food 的 buy 單未補（`tick_team_orders` shortage_buy 不含 food）→ 食物經濟只半邊（賣有、買無）→ 待補 + WS-2 市集完成交易。③**食物稅語意變更**（systems ack `cde372c`）：food 進糧倉不走一般稅 split（=自存自村，語意一致），稅 split 機制測覆蓋已移 material。
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

