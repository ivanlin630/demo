# 復甦路徑 HOW（systems / 邊際經濟計算層 + 三動詞 dispatch）

status: DRAFT（待 R² per slice）
owner: systems（HOW）← WHAT LOCKED `2026-08-05-recovery-path-design.md`（§2.5 動詞通用、邊際經濟湧現、禁地型查表）
date: 2026-08-06
grounding: §3 經濟底查（`2026-08-06-...econ-baseline-verdict`）+ R① CLEAN（P1-P5 reuse、P3=新 lord-side 機制訂正）+ blueprint marginal-ruling（2026-08-06）。

## §0 架構總則（blueprint 裁 = 命門）
**禁地型查表**（「山→遷/森→投」= 腳本違憲）。三動詞（移民/投資/遷村）**共讀同一邊際經濟計算層**、各自 util = 真邊際數字 → **terrain 三態行為湧現、零 lookup**。terrain 三態 = **驗證床設計參考**（量測分化），非 code 分支。同「補丁閘優先查／決策交引擎人格秤」精神。

## §1 邊際經濟計算層 `MarginalEconomy`（三動詞共讀 substrate）
新 static helper（純算術、零 RNG、類 `FoodFlow`），計算三個邊際量、**全部 off `FoodFlow._sustainable_inflow`**（food_flow.gd:35-47，遊戲自身 survival 判讀的可持續產出公式，含 terrain REGEN × outpost_mult × `pop_mult=clampf(sqrt(pop/5),0.5,2.0)` × farming × prod_skill）：

1. **移民邊際** `migrant_marginal(village_est, +k)`
   = `inflow(pop_est+k) − inflow(pop_est)` **−** `k × FOOD_PER_PERSON_PER_DAY(0.8)`。
   → 森林 pop2→3：Δinflow≈+0.42 − 0.8 = **−0.38（負）** → 引擎自己算出「不移」；平原 pop2→3：Δinflow 大 − 0.8 = 正 → 移。**三態從此式湧現**。
   ★語意修正（底查）：「人到=產能到」**僅邊際為正的地成立**——`pop_mult` concave+封頂 = 加人邊際遞減，deficit 村加人=加速惡化。

2. **投資 ROI** `facility_roi(village_est, facility, next_lvl)`
   = `[inflow(farming_lvl+1) − inflow(current)] × HORIZON` **−** `material_cost`。
   reuse `idle_employ_value` 計算基礎（terms.gd:115-120、真 need-weighted 期望產出、anti-crank 全因子從真公式反推）。`material_cost`=`NeedOracle._construction_facility_need`（faction_ai_system:2858 既有）。
   → 森林 pop3 farming L1（30mat×1.5）：inflow 1.90→2.85、翻正 → ROI 正 → 投資划算；山地 pop2 滿升仍 inflow<consumption → ROI 永負 → 引擎不投（emerges）。
   `HORIZON`=DERIVED（≈回本評估窗、非 invent-crank；建議 = DESPERATION_DAYS 級或 outpost 壽命 proxy，R² 校）。

3. **遷村價值** `relocate_value(team, target_tile_est)`
   = `inflow(target_terrain, pop)` （他地前景）**−** `inflow(current)` **−** `sunk_penalty`（既有據點沉沒；reuse persist 統一既有秤 P1）。
   → 山地村：current inflow 永<consumption、target 平原/森林前景高 → relocate_value 大正 → 遷；平原村：current 已盈餘 → 遷無益 → 不遷（emerges）。

**★§1 感知鐵律硬約束（god-view 防線、命門）**：三邊際量的**目標村狀態輸入（pop / 現有 facility level / food-deficit）一律 belief-estimated、禁讀 god-view target team live**。terrain 視為 belief-known（村已在 holding ledger／已 scout 過才知其地；未知地不能算前景）。來源 = `BeliefSystem.best_estimate` / holding ledger / **care-scout firsthand co-location**（已 merged、傲村不 post 也看得見）。**無 belief → 保守不行動**（不 fabricate 邊際 off god-view，invariants:186）。自身真值（`team.population` 領主自己）照讀。**新增決策讀他村 stat → 走 belief + 補「真值≠belief」回歸測**（invariants:197 契約）。

## §2 三動詞 dispatch（lord-side side-action 家族）
全部掛既有 `info_side_dispatch_all`（faction_ai_system:1667）迴圈：脫主 argmax（母隊 body 照自救=同 herald/scout/distribute）、per-team cadence-gate（:1673）、mini-util cost-benefit、真成本、throttle。mini-util anchor 紀律照 :1660（DERIVED 自食物常數、非 fire-crank）。

### (A) 移民 dispatch `_try_migrant_side`（Slice R1）
- 領主評自家 faction 各村（holding ledger 已知村），對每村算 `migrant_marginal`（belief pop_est）。
- util = `migrant_marginal × _help_pmult(領主人格) × EXPECT − CONVOY_COST`；**marginal≤0 → util<0 → 不派**（森林/山地村自動不收移民 = 三態湧現）。
- **來源約束**：migrant 來自**盈餘村/anon 池**，且**不得把來源村抽到自身 sweet spot 以下**（來源村 migrant_marginal 抽走後仍≥0）——否則拆東牆補西牆。
- dispatch = migrant convoy（reuse convoy movement、payload=人；抵達 = P2 勞力池共址即產能）。真成本（人隨 convoy 離源村）。

### (B) 投資 dispatch `_try_invest_side`（Slice R2、R① P3 新機制）
- **P3 gap**：`options.gd:40-47` 建設 option target **寫死 `team.tile_pos`**（不能指定別村蓋）。**解法非跨 tile build**——領主**送料**（material convoy）到目標村、**目標村自己既有的建設 option（本 tile）收到料→ idle labor 在地蓋**。
- 機制 = **material-delivery convoy**（reuse `_try_distribute_side`/`_dispatch_convoy`:1694，payload 從 food 換 **material**、指定 facility 類型）。lord-side mini-util = 目標村 `facility_roi`（belief）；`facility_roi≤0 → 不送`（山地村自動不獲投資）。
- ★**驗執行端**（memory feedback_verify_execution_end）：送料後**目標村建設須真 fire**——verify 村建設 precondition 讀 holding material（`has_manufacturing_facility`/build start 讀料）。candidate 生成≠真蓋；build-time 必驗料到→建設 argmax 勝→TASK_BUILD 真轉→facility level 真升。若料到但建設不 fire = 手不聽腦執行層 blocker，須查（options.gd 建設 applicable/util 是否反映到手 material）。

### (C) 遷村令 dispatch `_try_relocate_order`（Slice R3、P4）
- 領主秤自家村 `relocate_value`（belief）+ 領主人格（規劃型整併/仁君勸+送搬遷糧/放任）→ 下遷村令。
- 機制 = **信使 directive 走資訊網**（reuse `in_transit_letters` kind=`"relocate"`、payload=target_tile；令**真送達**才生效、非瞬間 = 感知鐵律跨距）。throttle 一令/村。

## §3 村端收令 + 自願遷（village-side、Slice R3）
- **村自願遷**：村秤 `relocate_value`（belief-known 目標地、非 god-view best-tile scan）> 閾 → 自發遷。
- **遷村令收令 handler**（用戶定兩層對抗）：令送達 → 村**從 vs 抗人格秤**：
  - 忠/懼 高 → **從**、但 `unrest` 累積（帶怨；reuse cohesion unrest）。
  - 傲/戀土 高 → **抗命**（不遷）。
- 抗命後果 = 領主人格：算了 / 斷賑濟（既有 distribute 停）/ **武力押遷 = 軍事 arc、本 arc 只留鉤子**（不實作強遷、只留 unrest→起義/叛離既有出口 P5 承接暴君逼反 → 湧現劇情）。

## §4 感知鐵律 enforce（god-view 防線彙總）
- §1 三邊際輸入 = belief only（目標村 pop/facility/deficit）；terrain=belief-known；relocate 目標 = explored/known tiles（禁 god-view 全地掃最佳）。
- 無 belief→保守不行動（invariants:186）。跨距 = convoy/letter 真送達（非瞬間、reuse in_transit_letters/_dispatch_convoy）。
- **新測**：`_test_leak_*` 家族補「領主邊際決策讀 belief 非真值」兩向斷言（真值≠belief 時決策跟 belief）——invariants:197 契約，R² 必查。

## §5 §1 防 crank enforce（WHAT §1 + memory §1 雙向）
- **無復甦配額**；三動詞 util 全真值（migrant_marginal=真邊際、facility_roi=真回收、relocate_value=真前景−沉沒；**禁 boost 逼 fire**）。
- **村站不起來照樣站不起來**：mountain marginal 永負 → 引擎自己不救 → 遷或死（真死路存在=正確、非 bug）。
- 量測驗**分化**（好領主投資的村回升 vs 疏忽的照樣完蛋 vs 爛地村遷走/死）、非達標值。

## §6 全量暫態可觀測性（憲法、tap 必接）
新 decision/state 全接 tap（撐 QA 故事、防捏假故事）：`migrant.mini_util` / `migrant.dispatched` / `invest.roi` / `invest.material_delivered` / `village.build_fired`（★驗執行端）/ `relocate.util` / `relocate_order.dispatched` / `village.comply` / `village.resist` / `relocate.unrest_added`。marginal 計算層 tap 禁耗 global RNG（observer 中性、memory feedback_observer_no_global_rng）。

## §7 reuse map（P1-P5 file:line 坐實）
| 件 | file:line | 用途 |
|---|---|---|
| P1 沉沒成本秤 | persist 統一（merged） | relocate_value 的 sunk_penalty |
| P2 勞力池共址即產能 | merged | 移民抵村即產（僅邊際正） |
| P3 idle_employ_value | terms.gd:115-120 / decision_context.gd:201 | facility_roi 計算基礎 |
| P3 建設 option（自 tile） | options.gd:40-47 | 村端收料在地蓋（material-delivery 解 target 寫死） |
| P3 distribute convoy | faction_ai:1686-1694 | material-delivery dispatch 母體（換 payload） |
| P4 in_transit_letters | faction_ai:1724 | 遷村令 directive（kind="relocate"） |
| P5 unrest/起義/叛離 | cohesion（merged） | 承接遷怨/抗命/暴君逼反 |
| 產出公式 | food_flow.gd:35-47 | 三邊際量 off `_sustainable_inflow` |
| relief target | faction_ai:2868-2869 | relief 一次性補血（結構修在三動詞） |

## §8 build 序（3 slice、各 R²→build→量→QA）
- **Slice R1**：`MarginalEconomy` 計算層 + 移民 marginal-util dispatch (A)。**量**：移民只去邊際正的地（森林/山地村不收、平原欠人村收）；驗計算層 belief-only（god-view 防線）。**最小閉環、先坐實 substrate**。
- **Slice R2**：投資 dispatch (B、P3 material-delivery)。**量**：森村被投資回升（deficit→farming L1→surplus→breed fire）；★驗執行端（料到→村真蓋）。
- **Slice R3**：遷村令 (C、P4) + 村自願遷 + 從抗人格秤 (§3)。**量**：山村遷/遷村令劇情鏈（令送達/從帶怨/抗命/暴君逼反案例）+ 三態全湧現分化。
- 各 slice：R²（reviewer 審設計、CLEAN 才 build）→ implementer TDD build → measurer 量 → QA 故事判 → merge（atomic、憲法閘 74+、byte-identity 繼承）。
- 平原真 distress = 先查因（care-loop scout 工具、非 terrain/pop）再開藥——**非本 HOW slice**（逐村查、若現）。

## §9 size-matter arc 地基（副產、記長程）
底查確證 production 全域無規模經濟（`sqrt(pop/5)` clamp[0.5,2.0] concave+封頂、labor `K_GATHER=5.0` 工位封頂）= `project_size_matter_arc` CASE B「規模經濟 absent→反獎勵 size」精確數字地基。recovery-path 與 size-matter 同源（production 不獎勵 size）——**本 arc 不解 size-matter**（那是獨立 arc、此處只記 file:line 地基供其跑時用）。
