---
from: systems
to: blueprint
status: consumed
topic: "[status·掛單噪音死常數清理+effective_holding 收斂=DONE(merged 非 in-seam)·grounded=決策層已 gate·order-noise 量測=backlog·★3線重疊判=不用 bundle 新 thread:(1)死常數清理 DONE closed(2)reserve_factor in-flight 三腿(3)結構稽核找 NEW 候選→我 triage dedup 掉 done/in-flight] 用戶問掛單噪音 status，code-坐實(非記憶):①economy 結構統一掛單層=★DONE merged(order_system:10-12/96-140:掛單門檻走 effective_holding−人格 reserve;FOOD_SELL_RESERVE_RATIO/FOOD_BUY_DAYS/SURPLUS_RESERVE_MULT/×0.5/20.0 全廢[:11 註+grep 無 live const];effective_holding 單源 resource_system:405;M3/M4/M5 marker)——非仍在 seam,掛單層那塊已落。②grounded/dedup/expiry:dedup DONE(_has_active:118 防重掛)、expiry DONE(expire_tick+tick_team_orders 過期清理:89-93);grounded(別掛買不到/賣不掉)=掛單走真 surplus/shortfall(非亂掛)+『買不到』的 look-before-leap 在決策層(買糧/買料 applicable gate has_specie/has_buyable_food/has_material_market)——effectively 有,非 order-post 層。③order-noise 量測(order_placed/arb_kill_nostock 月率供給修後降沒)=backlog 未量(當初『別預修』的 gate 沒跑);要量我派 measurer。★★3線重疊判=不用 bundle 成新 order 層 thread:(1)死常數清理已 DONE=closed 無重疊(2)reserve_factor(coin/material urgency 賣光)=正在修 in-flight 三腿(extraction+material-hold)非新 thread(3)結構稽核會掃 trade_valuation 找 NEW 候選——我 triage 時 dedup 掉已廢死常數+in-flight reserve_factor→不會挖三次同層。∴無大塊未做 order 層可收斂;協調=triage 稽核輸出時我 hold dedup(排除 done+in-flight)。不急,回用戶即可。"
---

# status：掛單噪音 = 大塊已 DONE；3 線重疊 = 不用 bundle（triage 時 dedup）

## 用戶問「掛單噪音處理了沒」——code-坐實 status
### ① economy 結構統一掛單層 = ★DONE（merged，非仍在 seam）
- `order_system.gd:10-12/96-140`：**掛單門檻走 `effective_holding − 人格 reserve`**（M3）；**死常數全廢**：`FOOD_SELL_RESERVE_RATIO / FOOD_BUY_DAYS / SURPLUS_RESERVE_MULT / FOOD_BUY_TARGET_DAYS / ×0.5 / 20.0`（:11 註明廢 + grep **無 live const**，只剩廢弃註解）；food 走 `food_security_target` 統一（廢 FOOD_BUY_DAYS）。
- `effective_holding` 單源（`resource_system.gd:405`），掛單層讀它 + `TradeValuation.reserve`（人格化）。M3/M4/M5 marker。
- ∴ **掛單層那塊已落**（非「仍在切 seam」）。

### ② grounded-order / dedup / expiry
- **dedup DONE**：`_has_active`（:118）防同 res 重掛買/賣單。
- **expiry DONE**：`expire_tick` + `tick_team_orders` 過期清理（:89-93）。
- **grounded**：掛單走**真 surplus/shortfall**（`effective_holding−reserve`，非亂掛）；「買不到/賣不掉」的 look-before-leap 在**決策層**（買糧/買料 applicable gate `has_specie`/`has_buyable_food`/`has_material_market`）——effectively 有，作用在決策非 order-post 層。

### ③ order-noise 量測（order_placed / arb_kill_nostock 月率供給修後降沒）
- **backlog 未量**（當初「別預修、供給修好再量」的 measurement gate 沒跑）。要量我派 measurer（不急）。

## ★★3 線重疊判 = 不用 bundle 成新 order 層 thread
- **(1) 死常數清理** = ★已 DONE closed（無重疊可挖）。
- **(3) reserve_factor**（coin/material 被 urgency 壓賣光）= ★正在修 **in-flight 三腿**（extraction merged-pending + material-hold dispatched）——非新 thread，是本場主線。
- **(2) 結構稽核** = 會掃 `trade_valuation` 找 **NEW** 候選——**我 triage 時 dedup 掉**「已廢死常數」+「in-flight reserve_factor」→ **不會挖三次同層**。
- ∴ **無大塊未做的 order 層可收斂**（死常數 done、reserve_factor in-flight）。**協調 = triage 稽核輸出時我 hold dedup**（排除 done + in-flight），避免結構稽核跟既有 seam 工作撞車重工。
- **判：不 bundle 新 thread**。若稽核找出**真新**的 order 層 sibling（非已 done/in-flight），那筆單獨 measure→spec，不硬湊一次大收斂。

## 回用戶
掛單噪音的**死常數/effective_holding/dedup/expiry 已修好 merged**；churn 真根是 threat-preempt（非亂掛，2026-07-15 trace）；reserve_factor 賣光那層正在三腿修；量測 gate（噪音率降沒）待供給穩後補。不急。
