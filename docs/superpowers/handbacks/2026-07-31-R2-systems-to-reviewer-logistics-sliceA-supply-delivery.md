---
from: systems
to: reviewer
status: consumed
topic: "[R²·後勤SLICE A供給-delivery convoy(GATE-B撮合物理送貨,measure定案grounded)·spec=2026-07-31-logistics-slice-A-supply-delivery-convoy-HOW.md·measure第一手釘死GATE-B真gap=賣方菜單缺deliver option(Team3 surplus400但無deliver option/ever_moved=false/granary=0)非argmax輸非spatial·SLICE A=(A)新deliver決策option(surplus+知市場demand→生deliver candidate入argmax util秤非scripted,★measured驗真fire別假設)+(B)convoy生命週期(②新TASK_CONVOY+FETCH撥款樣式+③各階段專屬_evaluate_subteam分支防generic fallback:1753攔截+④撤persist-hold子隊本sticky+DELIVER TileBank.deposit市場granary+RETURN釋放pop非settle/merge)·接既有_market_visitor_buy→fulfilled>0·★★三驗收線(blueprint鎖):①真派真deposit granary②fulfilled>0材料第一次真換手③貨物理真離賣方·審deliver option真fire(measured非假設)+convoy生命週期不被settle/merge攔+cargo守恆+感知鐵律demand讀belief+不凍] 後勤SLICE A物理送貨第一刀。GATE-B真fix。審deliver option真fire+lifecycle不被攔+守恆+不凍。"
---

# R²：後勤 SLICE A — 供給-delivery convoy（GATE-B 撮合物理送貨）

## spec
`docs/superpowers/specs/2026-07-31-logistics-slice-A-supply-delivery-convoy-HOW.md`。measure 定案 grounded（賣方 dump 第一手釘死 GATE-B 真 gap）。

## measure grounded（非猜）
GATE-B 撮合 0 成交真 gap＝**賣方菜單缺 deliver option**（Team3 surplus=400 但 applicable 無 deliver option、`ever_moved=false`、`granary material=0`）＝**option 不存在、非 argmax 輸、非 spatial**（決策層 fire 正常已 measured：T0 買方 economy goal 贏 argmax）。

## 做（兩塊一體）
- **(A) 新 deliver option**：surplus + 知市場 demand（belief-gated）→ 生 deliver candidate 入 argmax（util 秤非 scripted）。★**measured 驗真 fire**（本 session 鐵律：dump per-option util 驗、別假設決策 fire）。
- **(B) convoy 生命週期**（②③④ plumbing）：新 TASK_CONVOY + FETCH（撥款樣式取貨）+ **③各階段專屬 `_evaluate_subteam` 分支**（防 generic fallback:1753 攔截半路棄貨）+ DELIVER（`TileBank.deposit` 市場 granary）+ RETURN（釋放 pop 非 settle/merge 消失）+ ④撤 persist-hold（子隊本 sticky）。
- 接既有 `_market_visitor_buy` → **`fulfilled>0`**。

## ★reviewer focus（異質 refute）
1. **★deliver option 真 fire（measured 非假設）**：加了 deliver candidate，賣方 dump per-option util 驗它贏 argmax when surplus+demand——★spec 要求 measured 驗（別重蹈本 session 5 次假設決策 fire）。util payoff 正規化（賣 X coin gain）接得到、真能 fire 否？
2. **★convoy 生命週期不被既有 settle/merge 攔**（③核心）：FETCH/OUTBOUND/DELIVER/RETURN 各階段專屬 early-return 分支比照 TASK_BUILD/SETTLE——真擋掉 `_evaluate_subteam:1753 generic fallback`（抵達目標格 merge_queue）+ `:1737 TASK_SETTLE convert_to_resident`？RETURN 到家釋放 pop（非整隊 `_merge_into` 消失）機制對否？
3. **cargo 守恆**（賣方 vault − / porter carry / 市場 granary + 全程守恆）？
4. **感知鐵律**：demand 讀 belief/known 市場（`_nearest_market_outpost_with`）非 god-view？
5. **不凍**（convoy 只抽少數 porter，seed1337 attrition 非→0）+ ④撤 persist-hold 對否（子隊非 IDLE 本 sticky faction_ai:1758-1760）？

## 判
CLEAN → implementer（deliver option + convoy 生命週期 + ★三驗收線 TDD）→ measurer（①真派真 deposit ②fulfilled>0 ③貨真離賣方）→ QA。有洞（尤其 1 deliver option 真 fire / 2 lifecycle 被攔）→ 回 `to:systems`。**★這是後勤 arc 物理送貨第一刀、GATE-B 真 fix、三驗收線 blueprint 鎖，R² 從嚴。**
