---
from: systems
to: implementer
status: open
topic: "[dispatch labor-slice v2(食物真邊際分配+★farm production解耦level-cancellation修+估算器、v1 FAIL後全鏈重做)·base main abaab1f7·spec=2026-08-19-labor-marginal-food-alloc-v2-HOW.md R²-CLEAN(reviewer親算代數證level-cancellation真bug+v2修法數學正確+窮盡grep確認無漏第三處)·★v1教訓:v1只改weight-side→治斷崖FAIL(demand-side/level-cancellation沒動)、v2全鏈一致·★T1食物真邊際分配:食物組(gather:food+farm)合併need-weight=food_need單一(double-count keep、跨資源不變)、組內按per-labor yield分配labor流向高者(yield_g=productivity×COLLECT_RATE own-tile/yield_f=farming_level×FUY×harvest own-tile level-dependent發展越高每勞力越產)、farm alloc上限=capacity=level×K_FARM(cap而已大農田吸收多工位)·★★T2 farm production解耦fill/demand(level-cancellation核心修):現fyield=level×FUY×flabor×harvest、flabor=fill×SCALE=alloc/(level×K_FARM)×SCALE→level分子分母相消labor-starved level-independent;修=demand[farm]=level×K_FARM只作alloc capacity cap不除進production、production=alloc×per-labor-yield(per-labor=level×FUY×harvest、level生效)→production∝level×alloc發展farm labor-starved也真增產;★正規化守FARM_UNIT_YIELD 2.0量級避magnitude爆·gather產出對稱檢視不受破·★T3估算器同步(★R²訂正:main仍原始farming_bonus=1+level×0.5乘性boost、v1未merge、T3整條替換從零寫非調既有):food_flow._sustainable_inflow:46-47+marginal_economy:21(恰2處、faction_ai:2161 facility_roi下游自動繼承)移farming_bonus改farm_contribution=新production式(alloc×per-labor-yield level生效勞力飽和誠實)、estimator==production同源、god-view防線(VillageEstimate est-based)·感知鐵律self-knowledge·禁crank·double-count keep(B5瀕餓food need飆→勞力回食保護底線)·守恆·guns-vs-butter動員不動·TDD:①T1食物per-labor yield分配非equal②farm高level拿多份③T2 production隨level真升(alloc固定level升→產出升=治cancellation硬證)④magnitude守FUY 2.0不爆⑤T3估算器==production同源level生效⑥self-knowledge無god-view·gate:★production隨level真升(核心)+share隨發展+B5瀕餓食勞力飆+動員照抽+守恆+starve不升+determinism+constitution+fp intended標;fill%診斷非gate·worktree feat/labor-marginal-food-v2·完→handback附measurer·地基KEEP"
---

# dispatch labor-slice v2（食物真邊際分配 + ★farm production 解耦 + 估算器）

spec=`docs/superpowers/specs/2026-08-19-labor-marginal-food-alloc-v2-HOW.md`（**R²-CLEAN**、reviewer 親算代數證 + 窮盡無漏第三處）。base=main `abaab1f7`。v1 SUPERSEDED（只改 weight-side→治斷崖 FAIL）。

## ★T1 食物真邊際分配
食物組（`gather:food`+`farm`）合併 need-weight=`food_need` 單一（double-count keep、跨資源不變）、組內按 per-labor yield 分配 labor 流向高者：
- `yield_g=productivity×COLLECT_RATE`（own-tile）、`yield_f=farming_level×FUY×harvest`（own-tile、level-dependent 發展越高每勞力越產）。
- farm alloc 上限=capacity=`level×K_FARM`（cap 而已、大農田吸收多工位）。

## ★★T2 farm production 解耦 fill/demand（level-cancellation 核心修）
現 `fyield=level×FUY×flabor×harvest`、`flabor=fill×SCALE=alloc/(level×K_FARM)×SCALE`→level 分子分母相消 labor-starved level-independent。
- **修=`demand[farm]=level×K_FARM` 只作 alloc capacity cap 不除進 production**、`production=alloc×per-labor-yield`（per-labor=`level×FUY×harvest`、level 生效）→ **production ∝ level×alloc、發展 farm labor-starved 也真增產**。
- ★正規化守 FARM_UNIT_YIELD 2.0 量級避 magnitude 爆。gather 產出對稱檢視不受破。

## ★T3 估算器同步（★R² 訂正現況）
**main 仍原始 `farming_bonus=1+level×0.5` 乘性 boost、v1 未 merge、T3 整條替換從零寫非調既有**：`food_flow._sustainable_inflow:46-47` + `marginal_economy:21`（恰 2 處、`faction_ai:2161 facility_roi` 下游自動繼承）移 farming_bonus 改 `farm_contribution=新 production 式`（alloc×per-labor-yield level 生效、勞力飽和誠實）、estimator==production 同源、god-view 防線（VillageEstimate est-based）。

## 守則
感知鐵律 self-knowledge、禁 crank、**double-count keep**（B5 瀕餓 food need 飆→勞力回食保護底線）、守恆、guns-vs-butter 動員不動。

## TDD
①T1 食物 per-labor yield 分配非 equal ②farm 高 level 拿多份 ③**T2 production 隨 level 真升**（alloc 固定 level 升→產出升=治 cancellation 硬證）④magnitude 守 FUY 2.0 不爆 ⑤T3 估算器==production 同源 level 生效 ⑥self-knowledge 無 god-view。

## gate（measurer bounded）
**★production 隨 level 真升（核心）**+share 隨發展+B5 瀕餓食勞力飆+動員照抽+守恆+starve 不升+determinism+constitution+fp intended 標；fill%=診斷非 gate。

worktree `feat/labor-marginal-food-v2`。完 → handback 附 measurer。地基 KEEP。
