# 復甦路徑 HOW（systems / 邊際經濟計算層 + 三動詞 dispatch）

status: DRAFT-v2（R² round1=ISSUES 三 finding 全訂正 2026-08-06：①VillageEstimate god-view 防線 §1.0/②facility_roi survival-bounded 治 HORIZON 自打臉 §1.1.2/③material_cost→upgrade_cost；待 R² round2）
owner: systems（HOW）← WHAT LOCKED `2026-08-05-recovery-path-design.md`（§2.5 動詞通用、邊際經濟湧現、禁地型查表）
date: 2026-08-06
grounding: §3 經濟底查（`2026-08-06-...econ-baseline-verdict`）+ R① CLEAN（P1-P5 reuse、P3=新 lord-side 機制訂正）+ blueprint marginal-ruling（2026-08-06）。

## §0 架構總則（blueprint 裁 = 命門）
**禁地型查表**（「山→遷/森→投」= 腳本違憲）。三動詞（移民/投資/遷村）**共讀同一邊際經濟計算層**、各自 util = 真邊際數字 → **terrain 三態行為湧現、零 lookup**。terrain 三態 = **驗證床設計參考**（量測分化），非 code 分支。同「補丁閘優先查／決策交引擎人格秤」精神。

## §1 邊際經濟計算層 `MarginalEconomy`（三動詞共讀 substrate）
新 static helper（純算術、零 RNG、類 `FoodFlow`）。

### §1.0 ★輸入 = VillageEstimate（非 live target team）——god-view 防線核心（R² finding① 訂正）
★★**`MarginalEconomy` 禁呼 `FoodFlow._sustainable_inflow(state, live_target_team)`**（那讀 target live tile/leader = god-view，同 `_resident_food_runway` 違規同款）。改吃**純 struct `VillageEstimate`**、經內部 pure `_inflow_est(est)` 重算產出公式（鏡射 food_flow.gd:39-47 的 REGEN × outpost_mult × `pop_mult=clampf(sqrt(pop/5),0.5,2.0)` × farming × `(1+prod_skill×0.3)`）。

`VillageEstimate` 欄位來源（R② finding① 明確化——`_sustainable_inflow` 的**每一個乘數項**逐一交代，尤其 reviewer 抓的 `harvest_factor`+`prod_skill` 兩 live 欄）：
| 欄 | 來源 | 理由（感知鐵律） |
|---|---|---|
| terrain（REGEN） | 自家村行政/holding 記錄（領主治理即知；relocate 目標=explored/scouted、未知→skip） | 靜態地理、非 live-tile god-view 讀值 |
| outpost_level / farming_level | 同上（結構欄、緩變、建置時記錄） | 領主治自家村的行政知識、非 live 讀 |
| pop | **belief `pop_est`**（holding 報 / care-scout firsthand） | 動態、感知鐵律走 belief |
| **harvest_factor** | **NEUTRAL = 1.0（季節平均）** | ★belief store 無此 tile 季節欄、領主無法知遠村當下季節噪 → 誠實無知中性值；**正是 §3 底查 Model B 用的 baseline** |
| **prod_skill（生產）** | **NEUTRAL = 0.0** | ★belief 不 carry 特定技能值、遠村領主技能未知 → 保守中性；同底查 baseline |

★**三態 discrimination robust to neutral defaults**：migrant_marginal 的 sign 由 `C = REGEN×harvest×outpost×farming×(1+skill×0.3)` 對比 0.8 決定，**terrain REGEN 主導**——即使 neutral(harvest=1/skill=0/outpost=1/farming=0)：plains `C=8×Δpop_mult(0.143)=1.14>0.8→正`、forest `C=3→0.43<0.8→負`、mountain `C=0.5→0.07→負`。neutral 只改 magnitude 不改 sign 三態 → **設計成立**（neutral 是誠實近似非偷減乘數項）。

### §1.1 三邊際量（全 off `_inflow_est(VillageEstimate)`）
1. **移民邊際** `migrant_marginal(est, +k)` = `_inflow_est(pop+k) − _inflow_est(pop) − k×0.8`。
   → 森林 pop2→3 負 → 引擎不移；平原正 → 移。★「人到=產能到」**僅邊際正的地成立**（pop_mult concave+封頂、deficit 村加人加速惡化）。
2. **投資 ROI** `facility_roi(est, facility, next_lvl)`（R² finding②③ 訂正）：
   ```
   Δinflow      = _inflow_est(farming_lvl+1) − _inflow_est(current)          # 恆正小量
   net_after    = _inflow_est(farming_lvl+1) − est.pop×0.8                    # 投資後淨
   effective_days = PLANNING_HORIZON            if net_after >= 0            # 可持續→惠及全視野
                  = min(PLANNING_HORIZON, food_est / −net_after)  otherwise  # 仍赤字→只惠及殘存活窗
   roi = Δinflow × effective_days − upgrade_cost_value
   ```
   ★**HORIZON 自打臉根治（finding②）**：discrimination **非靠調 HORIZON**、靠 **survival-boundedness**——山地投資後仍赤字（net_after<0）→ effective_days 綁殘存活窗（短）→ Δinflow×短窗 < cost → ROI 負 → 引擎不投（即使 HORIZON 大）；森林投資後轉正（net_after≥0）→ full horizon → ROI 正 → 投。`PLANNING_HORIZON` = genuine 基建規劃視野（季量級、DERIVED 自 `WorldState.TICKS_PER_DAY`，**非 fire-crank**）；★measurer 驗 discrimination **robust across HORIZON 區間 [40,120] 天**（若三態不隨 horizon 知邊翻轉=證非 knife-edge tuned=anti-fire-crank proof）。
   `upgrade_cost_value` = **`OutpostSystem.upgrade_cost(facility, target_level)`**（outpost_system.gd:112-118、純 facility×level→cost 表、terrain-agnostic、零 state 依賴、零 god-view）× `TradeValuation.local_value`（共單位）。**非** `_construction_facility_need`（那 = 呼叫者自 outpost under-desire 加總 + 會讀 target live facility=god-view、finding③）。
3. **遷村價值** `relocate_value(team, target_est)` = `_inflow_est(target)` 前景 **−** `_inflow_est(current)` **−** `sunk_penalty`（reuse persist 統一 `persist_strength` 沉沒項、persist_strength.gd）。
   → 山地村 current 永赤字 + target 前景高 → 大正 → 遷；平原村 current 盈餘 → 不遷（emerges）。target_est 限 explored/scouted（未知地不能算前景）。

**★§1 感知鐵律硬約束（god-view 防線、命門）**：三邊際量**全經 VillageEstimate（§1.0）、禁讀 live target team/tile/leader**。無 est（未 scout/未在 holding）→ 保守不行動（invariants:186）。自身真值（領主自己 `team.population`）照讀。跨距 = convoy/letter 真送達非瞬間。**新測**：`_test_leak_*` 補「MarginalEconomy 給 stale/錯 VillageEstimate → 決策跟 estimate 非 live 真值」兩向斷言（invariants:197 契約、R² 必查）。

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
- §1.0 VillageEstimate = 唯一輸入面：**禁呼 `_inflow` on live target team**；結構欄（terrain/outpost/farming）=自家村行政記錄、pop=belief `pop_est`、harvest/prod_skill=NEUTRAL（見 §1.0 表逐欄理由）；relocate 目標 = explored/known tiles（禁 god-view 全地掃最佳）。
- 無 est→保守不行動（invariants:186）。跨距 = convoy/letter 真送達（非瞬間、reuse in_transit_letters/_dispatch_convoy）。
- **新測**：`_test_leak_*` 家族補「MarginalEconomy 給 stale/錯 VillageEstimate → 決策跟 estimate 非 live 真值」兩向斷言——invariants:197 契約，R² 必查。

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
| P3 idle_employ_value | terms.gd:115-120 / decision_context.gd:201 | facility_roi 期望產出計算精神（anti-crank 全因子從真公式反推） |
| ★facility 升級料成本 | `OutpostSystem.upgrade_cost` outpost_system.gd:112-118 | facility_roi 的 `upgrade_cost_value`（純表、零 god-view；**取代** finding③ 誤引的 `_construction_facility_need`） |
| P3 建設 option（自 tile） | options.gd:40-47 | 村端收料在地蓋（material-delivery 解 target 寫死） |
| P3 distribute convoy | faction_ai:1686-1694 | material-delivery dispatch 母體（換 payload） |
| P4 in_transit_letters | faction_ai:1724 | 遷村令 directive（kind="relocate"） |
| P5 unrest/起義/叛離 | cohesion（merged） | 承接遷怨/抗命/暴君逼反 |
| ★產出公式（**鏡射非直呼**） | food_flow.gd:39-47 | `_inflow_est(VillageEstimate)` 鏡射公式、**禁呼 `_sustainable_inflow(live_team)`**（§1.0 god-view 防線） |
| persist_strength 沉沒 | persist_strength.gd | relocate_value 的 sunk_penalty（人格加權沉沒） |
| relief target | faction_ai:2868-2869 | relief 一次性補血（結構修在三動詞） |

## §8 build 序（3 slice、各 R²→build→量→QA）
- **Slice R1**：`MarginalEconomy` 計算層 + 移民 marginal-util dispatch (A)。**量**：移民只去邊際正的地（森林/山地村不收、平原欠人村收）；驗計算層 belief-only（god-view 防線）。**最小閉環、先坐實 substrate**。
- **Slice R2**：投資 dispatch (B、P3 material-delivery)。**量**：森村被投資回升（deficit→farming L1→surplus→breed fire）；★驗執行端（料到→村真蓋）。
- **Slice R3**：遷村令 (C、P4) + 村自願遷 + 從抗人格秤 (§3)。**量**：山村遷/遷村令劇情鏈（令送達/從帶怨/抗命/暴君逼反案例）+ 三態全湧現分化。
- 各 slice：R²（reviewer 審設計、CLEAN 才 build）→ implementer TDD build → measurer 量 → QA 故事判 → merge（atomic、憲法閘 74+、byte-identity 繼承）。
- 平原真 distress = 先查因（care-loop scout 工具、非 terrain/pop）再開藥——**非本 HOW slice**（逐村查、若現）。

## §9 size-matter arc 地基（副產、記長程）
底查確證 production 全域無規模經濟（`sqrt(pop/5)` clamp[0.5,2.0] concave+封頂、labor `K_GATHER=5.0` 工位封頂）= `project_size_matter_arc` CASE B「規模經濟 absent→反獎勵 size」精確數字地基。recovery-path 與 size-matter 同源（production 不獎勵 size）——**本 arc 不解 size-matter**（那是獨立 arc、此處只記 file:line 地基供其跑時用）。
