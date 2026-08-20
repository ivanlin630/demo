# labor-slice v2：食物真邊際分配 + farm production 解耦 + 估算器（HOW / systems）

status: DRAFT→R²（2026-08-19）
owner: systems（HOW）← labor-slice v1 FAIL(治斷崖沒過) + level-cancellation 發現 + blueprint scope v2 確認
溯源：v1 只改 weight-side→FAIL(demand-side 沒動)。★深層真根=**level-cancellation**：`fyield=level×FUY×flabor×harvest`、`flabor=fill×SCALE=alloc/(level×K_FARM)×SCALE`→level 分子(yield)與 level 分母(demand 内)相消→labor-starved farm production **level-independent**（發展不增產）。blueprint 確認 v2 全鏈（分配+產出+信念一致）。**v1 spec SUPERSEDED。**

## §0 命門
- **★fp intended-change**（分配+產出+估算器行為變）。感知鐵律 self-knowledge（own-tile yield/labor、估算器 own-state）。禁 crank（yields 真公式）。守恆 farm_yield chokepoint。guns-vs-butter（動員抽勞力不動）。**★double-count keep**（單一 food_need=誠實、B5 瀕餓 food need 飆→勞力回食=保護底線、無需補償）。
- **★level-decouple 命門**：`demand[farm]=level×K_FARM` 語意轉 **capacity 上限**（level 級農田能吸收工位數）、**只作 alloc cap、不除進 production**。production 用 level-independent 正規化讓 yield 的 level 存活。

## §1 現況（grounded）
- 分配（labor_system:45-93）：食物兩工位 need-weight 相等、demand[gather:food]=K_GATHER/[farm]=level×K_FARM、proportional-capped-by-demand。
- 產出（resource:104-108）：`fyield=level×FUY×labor_mult×harvest`、labor_mult=`fill×SCALE`、fill=`alloc/(level×K_FARM)`=level 相消。
- 估算器（★**R² 訂正現況**：main 上 `food_flow:46-47` 仍是**原始 `farming_bonus=1.0+farming_level*0.5` 乘性 boost**、v1 未 merge 無 farm_contribution 痕跡；`marginal_economy:21` 同 pattern；**T3=整條替換從零寫 farm_contribution 非調既有**）。★reviewer 窮盡 grep 確認乘性 farming_bonus bug 恰 2 處（food_flow:46+marginal_economy:21 皆 T3 scope、faction_ai:2161 facility_roi 是下游消費者自動繼承 T3 修、無漏第三處）。

## §2 Task（TDD、每 task headless 驗）
### T1：食物工位真邊際分配（labor 流向 per-labor yield 高者）
- 食物組（gather:food+farm）**合併 need-weight=food_need 單一**（跨資源不變、double-count keep）；**組內按 per-labor yield 分配 labor**（labor 流向高 yield 者=farm 發展好 yield_f 高自然拿多）。
- `yield_g=productivity×COLLECT_RATE`（own-tile、gather 隨池竭遞減）、`yield_f=farming_level×FUY×harvest`（own-tile、**level-dependent 發展越高每勞力越產**）。
- **farm alloc 上限=capacity=`level×K_FARM`**（cap 而已、大農田吸收多工位）。
- 純算術零 randf。
### T2：★farm production 解耦 fill/demand（level-cancellation 修）
- `fyield = farm_alloc × per_labor_yield`（**level-independent 正規化**：per_labor_yield=`level×FUY×harvest`、alloc=實配勞力）→ **production ∝ level×alloc、level 不再被 demand 抵銷**（發展 farm labor-starved 也真增產）。
- ★實作：labor_mult(farm)/production 的 fill 分母改 **level-independent 參考**（K_FARM 常數非 level×K_FARM）、或 production 直接 alloc×per-labor-yield；**demand=level×K_FARM 僅 alloc cap 不進 production 除式**。FARM_UNIT_YIELD 量級守（正規化保 2.0 校準、避magnitude爆）。
- gather 產出對稱檢視（gather 若也走類似 fill，確認不受破）。
### T3：估算器同步建模新式
- `food_flow._sustainable_inflow` + `MarginalEconomy._inflow_est`：farm_contribution 改用**新 production 式**（alloc×per-labor-yield、level 生效、勞力飽和誠實）。estimator==production 同源。god-view 防線（VillageEstimate est-based）。

## §3 gate（measurer bounded、綠才 merge、blueprint 定）
1. **★production 隨 level 真升**（發展 farm 團 farm production 絕對值隨 farming_level 升=v2 核心、治 level-cancellation）。
2. **farm 佔食物收入 share 隨發展長**。
3. 未發展團（farming0）gather 照舊。
4. **瀕餓食勞力飆（B5 驗）**：餓時 food need 飆→勞力回食（保護底線在）。
5. guns-vs-butter 動員照抽。
6. 守恆 farm_yield chokepoint、starve 不升、determinism byte-identical(純算術)、constitution、fp intended 標注。
- fill% = **診斷指標非 gate**（demand 無界時天然降、量它=量錯）。

## §4 界外
- FARM_UNIT_YIELD/K_FARM 絕對量級 tune=12mo 大考 story-A。
- pop-emergence(①大vs小團)=warring config 另驗。

序：R² 審此 HOW（★level-decouple 正確[demand 只 cap 不除進 production]+真邊際+估算器同源+production 隨 level 升可達）→ CLEAN → dispatch（base 現 main）→ gate → merge。地基 KEEP。
