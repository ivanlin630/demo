# 製造樞紐湧現 — 補齊決策輸入讓製造/貿易樞紐自然長出（WHAT / vision）

status: DRAFT（pending R① factcheck audit 前提 → CLEAN 才鎖）
owner: blueprint（WHAT）→ systems 做 HOW
date: 2026-08-03

## 動機
§8 定案：單大隊**採掘**追不上分散小隊（正確湧現、大隊=軍事/集團=採掘生產）。**但單大隊可當「製造/貿易樞紐」= 第二種生產強權**：進口原料 → 大勞力池×多設施 大量加工 → 出口成品換真需求。加值型（vs 集團採掘型）。用戶裁定 甲(correctness) + B'(樞紐)。

## ★核心原則：湧現，非 script（用戶定）
**不建「樞紐系統」、不 script「某隊變工廠城」。** 補齊決策引擎缺的 genuine 輸入 → 引擎自己秤出「進料→加工→出口」是某隊最高價值 → **樞紐在該長的地方自動長**。驗收 = 量「樞紐有沒有湧現」，沒湧現 = 輸入/條件要調、**不 script**。

## 現況（audit 2026-08-03，★pending R① factcheck file:line + 詮釋）
**決策機器大半已存在**（樞紐真 emergent、非從零）：
- **P1** 製造已讀貿易需求：`manufacturing_system.gd:146` target = `NeedOracle.need_keep(out) + NeedOracle.demand(out)`；`goods` need_keep=0（`need_oracle:109`）→ **goods 製造已 100% 需求驅動**。
- **P2** 出口運貨鏈已存在：`goal_resolver:220 _deliver_candidates`（surplus + 聽到 buy-order → 送貨候選）+ `_dispatch_convoy`(:2961) + `_tick_convoy` DELIVER(:1770)。
- **P3** 需求信號可跨距：買方 `order_buy` 經 message 傳為 `team_known` belief（`need_oracle:96/153 demand`=Σ 聽到 buy-order qty），無需物理在場（撮合才需在場）。
- **P4** 買料路已存在：`goal_resolver:369 _resolve_resource_prereq`（has_specie→nearest_market→TASK_TRADE）+ `need_oracle:119 _supply_chain`（下游缺口拉 material need_keep）。
- **P5** coin 累積可自籌：trade profit → team/owner（`interaction:860`），`has_specie` gate 採購，coin 守恆。

> R① 判準：P1–P5 file:line + 詮釋（尤「機器已存在、樞紐 emergent」）成立否？premise_contradiction → halt。

## 三塊 genuine 缺口（arc = 補這三、接既有 seam、非建系統）
- **(A) 大出口需求源 absent**：現每張 `order_buy` = 某隊小缺口（`order_system:114`），無人掛「大量、持續」成品需求 → `demand()` 量級天生小、樞紐餓需求。**補**：一個 **genuine 出口需求源**往既有 `order_buy`/`team_known` 管道掛 sizeable standing 買單（製造端 `mfg:146` 不動、需求自然流進）。★genuine = 真買家真需要（如真聚落/勢力的持續需求），**非憑空灌 demand（crank）**。
- **(B) 進料商隊 absent**：商隊只 home→out（賣/送），無 fetch/import（遠方源→home）。`CONVOY_RES` 含 material 但只當 surplus 賣、不當 deficit 取。**補**：**取料商隊變體**（鏡射 `_dispatch_convoy`：foreign 源載、home 卸），供應鏈 material 缺口觸發、複用 porter/subteam spine。
- **(3) GATE-B 撮合 local-only**：`interaction_system:786 _market_visitor_buy` 只買「踩到的 tile 公庫」（`known_issues:93` buy-fill 0.5%）→ **進料 + 出貨撞同一道牆**。**補**：de-localize 撮合讓 raw-in + goods-out 皆能跨距成交（★守感知鐵律：非 god-view 瞬間，靠 convoy 物理橋接距離）——**一道 seam 同解進出口，非兩平行補丁**。**GATE-B 是全經濟老瓶頸 → 拆它全經濟受惠、高槓桿。**

## 結構縫（audit 定）
「製造需求」與「貿易需求」**已在唯一一點交會**：`NeedOracle.demand()`（need_oracle:96）把聽到的 `order_buy` 折入 `mfg:146` 生產目標。arc = **接兩個新源到此既有縫**（(A) 出口需求源 + (B) 取料商隊），**兩者都過 (3) 去 local 化的 GATE-B 撮合**——非建新縫。

## 守
- **湧現非 script**；**genuine 非 crank**（真出口需求/真進料/真撮合，禁憑空灌 demand）。
- **unify 非 patch**：接既有 `demand()`/convoy/GATE-B seam，禁平行 trade 邏輯（valuation 已統一，別重引 TARGET_PER_POP）。
- **need-gated full-stop 守**（不需求→不產、§51 no-floor）；**感知鐵律**（撮合/需求非 god-view，belief/proximity/convoy 橋接）。
- determinism 三跑 byte-identical；economy 不爆（產出/價/coin 無病態 spike）。

## 交 systems 的 HOW（開放）
- (A) 出口需求源 = 什麼實體、量級怎麼 genuine 定（真聚落/勢力持續需求、非 arbitrary 大數）。
- (B) 取料 convoy trigger/volume/route。
- (3) GATE-B de-local 機制（撮合能觸多遠、belief/range gate 怎麼守感知鐵律）。

## 量測（emergent 驗收）
- **樞紐有沒有湧現**：交易節點 + 大隊 + 有出口需求 + 進得到料 → 引擎是否選 import→manufacture→export（真 dispatch、真成交、真加值）？sizeable 出現於該長之處、不該長之處不長。
- economy 不爆（need-gated 守、價/coin 健康）、determinism、感知鐵律不破。
- **沒湧現 = 輸入/條件/util 調（非 script、非 crank）**。

## 血脈
- 溯源：`2026-08-03 §8 triple verdict`（單大隊採掘非強權=vision 驗證）；`2026-08-03 trade audit`（機器大半在、三缺口）。
- 地基（KEEP）：勞力池 `506aaa64` + de-patch `2c25a82c` + B `dbc31952` + 甲 —— 樞紐全建於上。
