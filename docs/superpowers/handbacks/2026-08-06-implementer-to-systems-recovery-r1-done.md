---
from: implementer
to: systems
status: consumed
topic: "[復甦路徑 Slice R1 DONE·feat/recovery-r1 commit 84ef8682]①MarginalEconomy 計算層(★★命門① god-view 結構防線:_inflow_est(est:VillageEstimate)簽名只吃純 struct 拿不到 state.teams[target]、鏡射 food_flow 公式非直呼 _sustainable_inflow;VillageEstimate 結構欄=行政/harvest+prod_skill=NEUTRAL/pop=belief)②移民 marginal-util dispatch(_try_migrant_side 掛 info_side_dispatch、三態 REGEN 主導湧現零 if-terrain:plains 收/forest/mountain 不收、util=marginal×EXPECT×pmult−MOVE_COST、來源不抽穿、真成本 dispatch_anon_migrants→_tick_migrant 併入 target=P2)。驗:r1_test 6/6(三態+★_inflow_est 純函式結構防線+★_village_est.pop=belief 非 live+森林不派+來源不抽穿)+headless 0-new+constitution 74(MarginalEconomy 純未新增 gv)+determinism FCE1BAC4 byte-identical(migrant warring 1mo inert、真效果需 recovery 床)。★merge-gate 請逐行核 _inflow_est 簽名確認拿不到 live target。請 R²→measurer(移民只去邊際正地:森林/山地不收、平原欠人收)→QA→merge。R2/R3 後續。"
branch: feat/recovery-r1
commit: 84ef8682
---

# 復甦路徑 Slice R1 — DONE（MarginalEconomy substrate + 移民 dispatch、路 systems R²）

照 spec `2026-08-06-recovery-path-HOW` §1/§2A（R² round2 CLEAN）。最小閉環先坐實 substrate。三動詞共讀邊際經濟、terrain 三態行為湧現零 lookup。

## ①MarginalEconomy 計算層（新 static、純算術零 RNG）
- **★★命門①（god-view 結構防線、最高風險 R² blocker）**：`_inflow_est(est: VillageEstimate)` 簽名**只吃純 struct、拿不到 `state.teams[target]`**——**結構上不可能 god-view**（非道德勸說）。**禁呼 `FoodFlow._sustainable_inflow(state, live_target)`**（那讀 live tile/leader）、改內部重算（**鏡射** food_flow.gd:39-47 公式`REGEN×harvest×outpost_mult×pop_mult(sqrt clamp)×farming×(1+prod_skill×0.3)`、非直呼）。
- **`VillageEstimate`（新 class、無 state 參照）逐欄**（spec §1.0 表）：terrain/outpost_level/farming_level=自家村行政記錄（結構欄、非 live-tile）、pop=belief `pop_est`、**harvest_factor=NEUTRAL 1.0 / prod_skill=NEUTRAL 0.0**（belief 無來源=誠實無知、= §3 底查 Model B baseline；neutral 只改 magnitude 不改 sign 三態）。
- `migrant_marginal(est, k) = _inflow_est(pop+k) − _inflow_est(pop) − k×MIGRANT_UPKEEP`（0.8=FOOD_PER_PERSON_PER_DAY DERIVED）。

## ②移民 marginal-util dispatch（`_try_migrant_side`、掛 `info_side_dispatch_all` 家族）
- 領主掃 holding 村算 `migrant_marginal`（belief pop_est）、往最高正的 target 移民。
- **★★命門②三態 REGEN 主導湧現、零 if-terrain**：plains(REGEN8)`marginal>0→收` / forest(3)/mountain(0.5)`marginal<0→不收`（加人加速惡化）。
- `util = marginal × MIGRANT_EXPECT_DAYS(30 回收視野) × _help_pmult − MIGRANT_MOVE_COST`（DERIVED）；`marginal≤0→util<0→不派`。
- **★來源不抽穿**：領主(源)留守下限（`pop>=CONVOY_MIN_PARENT_POP` + `anon>=BATCH+2`）、不拆東牆補西牆。
- **真成本**：`dispatch_anon_migrants` 抽 k anon→遷徙 subteam→`_tick_migrant` 抵 target 村**併入**（P2 共址即產能、非併回母隊）；throttle 一隊一。
- **`_village_est` 組裝**：自家村 outpost tile 行政記錄（`# gate-ok` own-faction infra 結構欄、非 live public_storage）+ belief pop_est；無 belief→null 保守不行動（invariants:186）。

## ★★merge-gate 逐行核對點（命門①）
`MarginalEconomy._inflow_est` / `migrant_marginal` 簽名**只吃 `VillageEstimate`（純 struct）、無 `state`/`team` 參數**＝拿不到 live target 物件＝**結構上不可能違憲**。`_village_est`（caller 組裝 est）讀單一自家村 admin tile（`# gate-ok`、非掃圖）+ belief pop。**請 reviewer 逐行確認 `_inflow_est` 簽名拿不到 live target**（結構防線非道德勸說）。constitution PASS 74（MarginalEconomy 純 + 單 admin tile 讀未新增 gv_mapscan/gv_teamstate）。

## 驗（全綠）
| 閘 | 結果 |
|---|---|
| `recovery_r1_test` | **6/6**（①migrant_marginal 三態 REGEN 主導[plains 0.54>0/forest −1.30<0/mountain −2.22<0] / ★③`_inflow_est` 純函式結構防線 / ★③`_village_est.pop`=belief pop_est(2) 非 live pop(50) / ②森林村不派 / 平原欠人村派 / ④來源不抽穿） |
| headless | **0-new** |
| constitution_gate | **PASS sites=74 removed=0** |
| determinism | 3-run（GODOT_TIMEOUT=1200、seed1337 1mo）MD5 `FCE1BAC4E808430F3222CCBEDB2E1FDB` **byte-identical**（=care-loop base＝migrant warring 1mo **inert**：該窗無 faction-leader-holding-plains-deficit setup 觸發；**真效果需 recovery/faction 結構床 measurer**、同 bed-specific pattern） |

## 路
1. **你 R²**（★merge-gate 逐行核 `_inflow_est` 簽名拿不到 live target + 三態 REGEN 湧現零 if-terrain + 來源不抽穿 + 真成本 + calibration DERIVED）。
2. → measurer：**移民只去邊際正的地**（森林/山地村不收、平原欠人村收）+ 驗計算層 belief-only（god-view 防線）；三態分化可觀測、無配額。
3. → QA → merge。**R2（投資 material-delivery）/ R3（遷村令）後續 slice。**

★recovery-path Slice R1 = 最小閉環坐實 substrate（MarginalEconomy 三動詞共讀基石）。**HOLD-warm 待 R²。**
