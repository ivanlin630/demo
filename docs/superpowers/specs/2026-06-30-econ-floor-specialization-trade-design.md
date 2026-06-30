# 經濟底 — 閉特化-交易-換糧環（買糧 Phase 2）

> 系統 HOW spec。承藍圖 `econ-floor-fix-now`（確定就修、別 nerf 地形、閉交換閉環）。= 久掛 🟡 經濟底真正關閉。
> 診斷已完（measured + 碼證）：forest/mountain（半地圖）food regen 低（3 vs plains 8）→ 糧倉填不起 → 該「賣特產換糧」卻沒換 → 餬口無盈餘 → 攀爬累積段斷。

## 診斷（measured + 碼，確定，不再 measure 輪）
1. **`返家補給` 只檢 `has_home_outpost`（據點在），不檢家糧倉是否空** → forest 隊（家糧倉=0）返空家乾耗，util `restock_need=1.5×(5−food)` food0=7.5 碾壓一切 → 永不去交易。
2. **`買糧` 需 `has_specie`（coin>0 or goods≥10）** → forest 隊有 **material**（木材，forest regen 12）但常無 coin/goods → `has_specie`=false → 買糧不 applicable → **連換糧入口都進不去**。
3. 結果：forest 隊困在「返空家→乾耗→返空家」，手上 material 賣不出去換糧。**特化-交易-換糧環斷在這兩處。**

## 修（不 nerf 地形；修交換閉環）

### A. `返家補給` home-empty gate（空家不返）
- `DecisionContext` 加 `home_food: float`（自家糧倉 + 私產 food，= `ResourceSystem.effective_food` 或自家 granary food）。
- `返家補給` applicable 加：家要**有糧可補**才返（`home_food ≥ RESTOCK_MIN`，TEST VALUE）。空家 → 返家無意義 → 不 offer → 讓 買糧/交易 接手。
- restock_need 可選按 home_food 縮放（空家→0 drive）；但 applicable gate 為主。

### B. `has_specie` 納可交易特產（forest 能 barter 木材換糧）
- `has_specie` 廣義為「**有可換糧的東西**」= coin>0 **or** goods≥10 **or** material≥MATERIAL_TRADE_MIN（or ore）。forest/mountain 隊的 material/ore = 交易籌碼。
- 買糧 to_task = TASK_TRADE → 市集 `_resolve_market`（既有 barter：coin 不足以物易物）→ forest 隊 material → 換 market food。**複用既有 barter，不新交易機制。**

### C. 量級（買糧 在返家 gated 後贏）
- 返家 gated（空家）後，買糧 vs 覓食/絕境分流 競。買糧 `buyfood_drive` 食物缺×旅費折扣，forest 隊有市集可達 → 應贏覓食（forest 覓食 regen 低）。確認量級：危時買糧 ≥ 覓食（非 plains 覓食差）。weight `buyfood` 非商隊 0.3 偏低 → 可能需提（特化隊賣特產換糧是常態非稀有）。TEST VALUE，戰國 seed 校。

## believability（守藍圖 guard）
- **不 nerf 地形**：forest food regen 仍 3（特化保留）。forest 隊**靠賣木買糧活**（交換），非自己長糧。= 特化-交易引擎運轉。
- **特化↔交易閉環**：plains 產糧、forest 產木、mountain 產礦 → 互市（forest 賣木買糧、plains 賣糧買木）→ 各活 + 經濟網絡。
- **driver-complete**：買糧/賣特產 driver = 求生取食（food<DESPERATION）；返家不返空家 = 可解釋（家無糧）。

## 驗收（修完自驗，藍圖列）
- **forest/mountain 隊**：賣特產→換糧→糧倉填得起→餬口有盈餘（T18 型 granary 0→正、net>0、pop 能長）。
- **不返空家**：家糧倉空的 forest 隊 → 買糧/交易（非 return_home 乾耗）。
- **戰國 seed**：非 plains 隊不再餓死潮、pop 能長（攀爬累積段通）；plains/forest 互市可見。
- **不 nerf 地形**：forest regen 仍 3（碼不改 REGEN_RATE）。
- **守恆**：coin_eq 0（barter/trade 走既有 `_resolve_market` 守恆）、pop 守恆、1000+ tick 無錯、framework S1-S6 PASS。

## 檔案
- `scripts/simulation/decision/decision_context.gd`：`home_food` 欄 + gather（自家 granary food）；`has_specie` 廣義納 material/ore。
- `scripts/simulation/decision/options.gd`：`返家補給` applicable 加 home_food gate；`買糧` applicable 沿用（has_specie 已廣義）。
- `scripts/simulation/decision/terms.gd`：restock_need 可選 home_food 縮放；`buyfood` weight 可能提（TEST VALUE）+ 常數 `RESTOCK_MIN`/`MATERIAL_TRADE_MIN`。
- `scripts/debug/headless_test.gd`：新測（空家 forest 隊→買糧非返家、material barter 換糧、has_specie 納 material）。
- 驗證：`food_ledger_diagnose` + `warring_states_seed` 重跑（forest granary 0→正、不餓死潮）。

## 風險 + 緩解
- **買糧量級失衡**（買糧碾壓正常 survival / 或仍輸返家）：戰國 seed 校 buyfood weight/RESTOCK_MIN。
- **barter 換糧到場撲空**（市集無糧賣）：既有 `_resolve_market` glut/撲空 emergent（forest 隊巡下個市集）。
- **has_specie 納 material 影響既有 買糧**（plains 隊也有 material→更易買糧）：plains 隊家有糧（返家 gate 過）→ 多數返家非買糧，影響小。戰國 seed 確認無 over-buy。
- **守恆**：全走 `_resolve_market`（既有 barter/trade 守恆），不新交易數學。
- **scope**：只 decision/ 三檔（返家 gate + has_specie + 量級）+ 測。**不碰 REGEN_RATE（不 nerf 地形）**、不新交易機制（複用 barter）、不碰戰鬥/P1。

## 開放細節（plan 定）
- `home_food` = effective_food(自家 granary) vs 純 granary food（plan 定，傾向自家 granary food，因 effective_food 已含私產可能誤判）。
- `RESTOCK_MIN`（家要多少糧才值得返）/`MATERIAL_TRADE_MIN`/buyfood weight 提多少（TEST VALUE，seed 校）。
- 賣特產：靠 買糧 的 TASK_TRADE barter（複用）vs 需獨立「賣特產」option（傾向複用 barter，先驗夠不夠）。
