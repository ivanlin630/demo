# Hand Back: B 食物張力（R1 供給 cadence + R2 flow-not-stock）

branch `feat/food-tension`（未 merge）。spec/plan `2026-07-01-food-tension`。

## 實作摘要

### R2 — 成長吃 flow 非 stock
- `scripts/data/team_data.gd`：加 `food_flow_avg`（日均淨食物流 EMA）+ `food_flow_last`（上次取樣 sentinel）。
- `scripts/simulation/resource_system.gd`：加 `_update_food_flow`（`resolve_consumption` 每 cadence 末呼；net = effective_food 末 − 上次取樣，÷day_fraction → 日率，α=day_fraction/FLOW_WINDOW_DAYS[=5] 時間常數平滑，cadence 無關；首取樣只 seed）。
- `scripts/simulation/reaction_system.gd`：生育 gate（`_evaluate_life_events`）`effective_food(stock)` → `food_flow_avg > BREED_FLOW_MIN[=1.2]`。
- `scripts/simulation/ambition_ladder.gd`：積累 rung gate（`target_rung`）`effective_food ≥ pop×2.4×7` → `food_flow_avg ≥ ACCUMULATE_FLOW_MIN[=0.5]`。

### R1 — 供給側對齊 day_fraction（修 24× cadence bug）
- `scripts/simulation/resource_system.gd`：`regenerate_tiles(cadence_ticks)` food_regen 乘 day_fraction；`collect_resources(cadence_ticks)`→`_collect_from_tile(day_fraction)` harvest gain 乘 day_fraction。material regen **未**縮放（pool cap-bound、harvest ÷24 已是節流）。
- `scripts/simulation/sim_runner.gd`：near/far 分支傳對應 cadence 給 collect/regenerate；**移除 far 分支冗餘 `_step5a_regenerate_tiles`**（near 分支已每小時全域再生所有 tile，far 重複=24× 雙記元凶之一）。
- **張力校準**：`FOOD_PER_PERSON_PER_DAY 2.4 → 0.8`（穩態食物 income≈regen；0.8 使 plains op1 養小鎮微盈餘=繁榮、forest op1 微赤=苟活、赤字溫和）。REGEN_RATE 常數（plains 8/forest 3/mountain 0.5）**未動**。
- 連帶把散落硬編 `2.4` 改引用 const（`interaction_system` 乞食/mercy、`faction_ai_system:2411/2482` food-days 閾、`inquiry_system:102`）→ 隨 const 一致縮放。

### 測試/bed
- `scripts/debug/headless_test.gd`：~18 assert 更新——breed/ambition-rung 測改設 `food_flow_avg`（flow-not-stock）；消耗/乞食/mercy/food_days 數值改用 const 計算。
- `scripts/debug/framework_validation.gd`：S3 scout scenario 加 `atk.food_flow_avg`（維持 EXPAND rung，否則 flow=0 降 SURVIVE → prosperity-attack 不評 → scout dormant）。
- `scripts/debug/food_ledger_diagnose.gd`：月數改 env `LEDGER_MONTHS`（default 8），供 timeout 內跑短窗。

## 驗收（bed 驗每步）
- **headless 全綠**：0 SCRIPT ERROR、`=== DONE ===`、coin_eq/InvariantAudit（pop/faction/subteam）綠。
- **framework 7/7 PASS**（S1 found/S2 feud+vendetta/S3 scout/S4 ambush/S5 mint/S6 order）。
- **econ_bed**：forest T0 pop **6→7 苟活**（不死、eff_food→0 手到口、food_buy=Y 想交易）、plains T1 **6→8 繁榮**。前 baseline forest 6→12 純 granary爆倉（granary 釘 1999 / days 129）。
- **warring 不 mass-starve**：1 月 famine=69（1-anon-at-a-time 涓滴集中在少數超編隊 right-size，非潮）；能人 T3 25→4（但活且回充 granary 315/task=訓練）、T18 forest 24→19（較 pre-fix 24→6 溫和）、T32 9→9 持平。無滅團潮。
- **致富→交易→成長鏈：未接（誠實標）**。specimen 商隊 想=致富 262/263 → winner=**建設** 263/263（建設 0.79 > 貿易 0.26），**從不貿易**。granary爆倉閘已拆，露出下一閘 = **建設 util 碾壓貿易（決策層權重）**。

## 連動風險（主 session 決定是否補修）
- **`ambition_ladder` rung 改讀 flow = 戰略層行為變**：新隊/marginal 隊 `food_flow_avg=0` 起步暫卡 RUNG_SURVIVE，需持續食物盈餘才升 rung → **prosperity-attack（侵略擴張）現需經濟盈餘**（飢餓隊不再主動開戰＝合理但是行為變）。**founding 未受影響**（獨立建國走自身 stock gate `faction_ai:994` 未改，framework S1 PASS）。⚠ warring 全窗（8 月）未驗——健康隊多使 sim 變重、600s wrapper timeout 跑不完（反證不 mass-starve）。建議主 session 用長 timeout / 分段跑確認 warring 仍 found/conquer。
- **`FOOD_PER_PERSON_PER_DAY 0.8` economy-wide**：所有 food-days 計算、buffer、famine、order buy 觸發皆隨此縮放（已全用 const）。material 經濟：harvest ÷24 但 mat_regen 未縮放（pool 保滿、harvest 節流）→ 建材供給 ÷24，未見 bed 異常但未專測建造/製造吞吐，建議掃一眼。
- **far 分支 regen 移除**：near 分支每小時全域再生覆蓋 far tile（near 分支時間閘每小時無條件跑，far tick ⊂ near tick），已驗無 tile 餓死；但這是 sim_runner 結構動作，記錄在案。
- **`_score_breed`（reaction:172）確認 dead code**（無 caller，P5_breed 只來自 `_evaluate_life_events`）——未動，可另案清。

## 待主 session 確認
- **致富→交易 下一閘（建設 util > 貿易 util）**：屬決策權重域（本軌 scope 外，spec 明訂不碰決策）。修向＝貿易 util 提權 or 建設 gate（有訂單/arb 時貿易應勝）。已記 known_issues。
- **TEST VALUE 待平衡 pass**：FOOD_PER_PERSON 0.8、FLOW_WINDOW_DAYS 5、BREED_FLOW_MIN 1.2、ACCUMULATE_FLOW_MIN 0.5、CAPTURE... 皆暫定。
- **經濟維度 emergence 到不到（誠實）**：張力機制（forest 苟活須交易 / plains 繁榮 / 不 mass-starve）**到**；「繁榮須交易」的交易網真轉 **未到**（trade loop 仍不 fire，因建設碾貿易，非食物）。
- **與並行軌 merge 序**：本軌碰 `resource_system` 經濟函數 + `reaction`/`ambition` growth gate + `team_data` flow 欄 + `sim_runner` collect/regen 佈線；**未碰** resource_bank ledger（單寫者軌）/roster/faction_ai intent/combat_target。與單寫者/征服 measure 軌若同觸 `reaction_system`/`ambition_ladder` 為不同函數，naive merge 應可，但請系統 session 過一眼 merge 序。
