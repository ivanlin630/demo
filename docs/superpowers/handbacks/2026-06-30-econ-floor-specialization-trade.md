# Hand Back: 經濟底 — 閉特化-交易-換糧環

## 實作摘要
- `scripts/simulation/decision/decision_context.gd`：加 `home_food: float` 欄 + `_home_granary_food()` static helper（掃自有 outpost tile granary food，team 離家也讀得到）；`has_specie` 廣義納 material/ore（`>= MATERIAL_TRADE_MIN`），不再只認 coin/goods。
- `scripts/simulation/decision/options.gd`：`返家補給` applicable 加 `ctx.home_food >= RESTOCK_MIN` gate（空家不 offer → 讓買糧/交易/覓食接手）。
- `scripts/simulation/decision/terms.gd`：加 `RESTOCK_MIN=10.0` + `MATERIAL_TRADE_MIN=20.0`（皆 TEST VALUE）。
- `scripts/debug/headless_test.gd`：新 `_test_econ_empty_home_no_return`（空家 forest→買糧非返家、material 納 specie、家有糧仍返）+ `_test_econ_believability`（barter material→food 量足驗證、coin 市集得 coin、真窮不買糧）；既有有家 survival 測補家糧倉（`_give_home_outpost`/`_mk_homed_desperate_team`/Survival Task4 Path1/Prosperity Task5 遠近 outpost/merchant restock s4），真絕境測加 forage 鄰格（空家改覓食非返空家）。

REGEN_RATE **未動**（forest food 仍 3）。守住藍圖硬 guard。

## 核心驗收結果
- **單元（決定性）**：forest 空家隊 → `task=貿易`(TASK_TRADE) 非 return_home。barter `material 300→100, food 5→170`（換糧量遠夠，藍圖「barter 量夠不夠」風險證偽=夠）。真窮（無 material/coin）→ 買糧不 applicable（乞食真語意保留）。
- **food_ledger（warring 種子 T18 forest）**：baseline = food=0 整段、卡 task=return_home、granary=0、pop 慢性崩。新碼 = granary **0→107**（首月 net=+1.3）、food 一度 288。**確認 gate 生效**（家有糧才填得起）。但 T18 隨後**遷 plains 去攻擊/逃**，被戰鬥打到 pop=1——食物信號被戰鬥噪音污染，非乾淨的「granary 0→正永續」線。
- **game_sim_multi（最乾淨正面證據）**：多 forest outpost 隊永續（food=336/168/97、net≈0、granary 填充），無空家死亡螺旋。coin_eq init=final（守恆）、InvariantSummary 違反=0。

## 守恆 / framework
- coin_eq init=1280 final=1280 delta=-0.00（守恆，barter 不碰 coin）。
- InvariantSummary 違反取樣=0。
- framework_validation S1-S6 全 PASS（PASS=7 DORMANT=0）。
- headless 全綠（`=== DONE ===`，無 SCRIPT ERROR/Assertion）。

## 連動風險
- **返家 gate 對既有有家 survival 隊**：凡「該返家」的測場景，家糧倉先前是空的（helper 漏設）。已逐一補家糧倉（≥RESTOCK_MIN）使語意成立（值得返的家有糧）。生產路徑：真實世界中有家隊若 granary 真空，現在會改走買糧/覓食而非返空家——這是**意圖行為**，但留意是否有依賴「返空家」的下游（未發現）。
- **has_specie 納 material 對 plains 隊**：plains 隊也常有 material → 更易進買糧入口。但 plains 家有糧（返家 gate 過）→ 多數返家非買糧；game_sim_multi 未見 plains over-buy 異常。
- **barter 換糧 seed 級可見性（待確認）**：決定側閉環已證（飢餓+有 material → 進 TASK_TRADE 非返空家）、barter 機制單元已證（量足）。**但全 seed 跑（game_sim_multi/warring）內未捕捉到 `[Barter]`/`[Market]成交` 實際在市集結算**——隊到場 TASK_TRADE 但料→糧結算在這些視窗未顯。forest 隊在 seed 內主要靠 granary/food order 存活。可能 barter 觸發條件（同格 + 雙向 surplus + 賣家身分）在 seed 內較稀有，或市集 food order 路徑先滿足。**未硬調，交主 session 判斷是否要更強的賣特產 driver。**

## 待主 session 確認
- **warring 種子非乾淨驗收（誠實標記）**：新碼 end teams=25 < baseline 36、established 1>0、死亡潮早期同樣陡。**無法乾淨分離「少餓死」vs「多被征服/併」**——warring 種子戰鬥動態支配，是 economy-floor 的差勁隔離床。`g2.feud_formed` 32<53（churn 降）、established=1 撐到底（baseline 月11 失），世界更積極而非更脆。**「非 plains 餓死潮消、pop 長」此種子無法證實亦未證偽。** 建議主 session 若要乾淨驗收，用低戰鬥/純經濟種子（如 game_sim_multi 的 forest 隊軌跡）為準。
- **量級（TEST VALUE）**：`RESTOCK_MIN=10` / `MATERIAL_TRADE_MIN=20` / buyfood weight（非商隊仍 0.3，未提）。是否要提 buyfood weight 讓「賣特產換糧」更常態（目前 forest 在 seed 內較少實際走到市集 barter 結算）——平衡 pass 決定。
- **賣特產 option**：plan 傾向複用買糧 TASK_TRADE barter（已做、單元證量夠）。若主 session 要 seed 級更顯著的料→糧流，可能需獨立「賣特產」driver 或提 buyfood weight；本 session 守 scope 未開新 option。

## plan 偏離
- 無功能偏離。Task 2 的 believability 測與 Task 1 測同 commit（測碼一體加入），無獨立 Task 2 commit（無新生產碼，Task 2 = 驗收）。
- 額外補了 plan 未列的既有測 helper 家糧倉（返家 gate 連動），屬必要回歸修復，非 scope 擴張。
