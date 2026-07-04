# Hand Back: 買糧 求生 option（Phase 1）

branch: `feat/buyfood-survival-option`（基於 `cd11a07`）

## 實作摘要
- `scripts/simulation/decision/decision_context.gd`：加 4 欄 `has_food_market`/`food_market_pos`/`food_market_dist`/`has_specie`；gather 注入 `_is_merchant`（同 `_loyalty` 法），複用 `_fa._nearest_market_outpost` + `_fa._hex_dist` 算最近市集距離；`has_specie = coin>0 or goods>=10`。
- `scripts/simulation/decision/terms.gd`：加 const `BUYFOOD_DIST_FULL=6.0`（# TEST VALUE）；eval `buyfood_drive`（餓×旅費折扣 `BUYFOOD_DIST_FULL/max(dist,FULL)`，無市集/無錢=0）；weight `buyfood`（商隊 1.0 / 非商隊 `NON_MERCHANT_TRADE_FACTOR=0.3`）。
- `scripts/simulation/decision/options.gd`：REGISTRY 加 `"買糧":[["buyfood_drive","buyfood"]]`；`SURVIVAL_OPTION_SET` 加 `買糧`（→ P2b-1 non-unified `rank_survival` 自動全隊化）；applicable（`food_days<DESPERATION_DAYS` + 有市集 + 有錢）；to_task（最近市集 → 既有 `TASK_TRADE`，撲空 mp==-1 → IDLE）。
- `scripts/debug/headless_test.gd`：加 `_test_buyfood_term_and_option`（term/weight/子集）+ `_test_buyfood_integration`（餓商隊有錢→TASK_TRADE、無錢→非 TASK_TRADE）+ helpers `_mk_starving_merchant`/`_mk_market_outpost`/`_buyfood_tile`，註冊進 runner。

## 與 spec/plan 差異
- 無實質差異。全照 plan 介面實作。
- 實作備註：terms.gd 因 Edit 工具對中文 old_string 匹配失敗，改用 Write 全檔重寫（內容無關差異，僅 buyfood 段加入）。

## 驗證證據
- headless 全套：`=== DONE ===`，0 SCRIPT ERROR、0 Assertion failed（含既有絕境/飢荒/P2a/P2b-1/P3 全綠）。
- **核心 gap 閉**：`buyfood_measure.gd` 首選 **紮營 → 買糧**（util 紮營 1.08 / 乞食 0.87 / **買糧 3.48**），實際 task=貿易(TASK_TRADE)。無錢分支 has_specie=false → 買糧不 applicable。
- framework_validation：PASS=7 DORMANT=0。
- world_sim 2yr（月 24 / tick 172800）：DONE 無崩、存活隊穩定 6–7（無 mass starvation）、`InvariantViolation`=0（含 coin_eq 守恆）、`g1.seek_market`=43（商隊巡市集既有路徑活）。
- game_sim_multi：4 情境（game_sim_test/tyrant/merchant/warzone）違反取樣總計=0。

## 連動風險
- `_resolve_market` / interaction trade：買糧到場走既有 `TASK_TRADE`，到場由 `_resolve_market` 依 local_value 決定買啥。餓隊 food local_value 高應買 food，但**未加專屬探針驗「到場真買到 food 而非別貨」** → world_sim 無崩無餓即視為合理，但精確「買糧成功率」未量。建議主 session 評估是否加 probe。
- 撲空（市集到場無糧/供需已變）：沿用既有 glut/local_value 機制（無新機制），to_task mp==-1 落 IDLE 退次佳。world_sim 無 mass starvation = 撲空率在容忍內，但**無撲空率專屬探針**。
- `_is_merchant` 注入 leader_values：`_` 前綴非人格鍵，既有 term match 不誤讀，leader_values 已 duplicate 不污染 PersonData。僅 weight("buyfood") 讀。
- SURVIVAL_OPTION_SET 加項：P2b-1 委派 `rank_survival` 自動納入 → non-unified 隊（軍隊等）絕境時也可買糧（全隊化，符 spec）。既有 survival 測全綠 = 不破既有排序。

## 待主 session 確認
- **撲空容忍 vs `_nearest_food_market` refinement**：目前用 `_nearest_market_outpost`（任意市集，不保證售糧）。若 world_sim 顯撲空過頻，Phase 2 可加「最近**售糧**市集」finder。現量測未顯問題 → 暫不做。
- **Phase 2 距離折扣全 options 序**：spec 規 `掠奪`/`返家補給`/`覓食` 暫不動，Phase 2 才距離折扣全套。本次只 `買糧`。
- **TEST VALUE**：`BUYFOOD_DIST_FULL=6.0` 待平衡 pass 調。
