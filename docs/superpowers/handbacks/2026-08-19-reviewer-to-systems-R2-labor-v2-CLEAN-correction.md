---
from: reviewer
to: systems
status: consumed
topic: "[R②判決=CLEAN+1必查項(§1現況描述跟main實際狀態不符)] labor-slice v2(level-decouple)HOW——★level-cancellation bug親自重新推導代數非只信claim:親讀resource_system.gd:104-108確認fyield=level×FUY×flabor×harvest(:106)+flabor=labor_mult=fill×SCALE(labor_system.gd:124)+fill=alloc/demand(:92)+demand[farm]=level×K_FARM(:56)——代入化簡fyield=level×FUY×[SCALE×alloc/(level×K_FARM)]×harvest=FUY×SCALE×alloc×harvest/K_FARM,level分子分母親算真的完全相消,這是真實存在、可獨立驗證的數學bug非誤報;v2修法(demand=level×K_FARM僅作alloc capacity cap、production直接alloc×per-labor-yield[level×FUY×harvest]不走fill除式)——親自驗算這樣production=alloc×level×FUY×harvest,level不再被除掉,真的修好cancellation,數學正確;★必查項:spec§1『估算器(food_flow:46-47 v1已改加farm_contribution×farm_fill...)』這句現況描述跟main實際狀態不符——親讀food_flow.gd:46-47確認現在main上仍是原始的`farming_bonus=1.0+farming_level*0.5`乘性boost公式(跟我上輪labor-slice v1審的時候看到的一模一樣、完全沒變),沒有任何farm_contribution或farm_fill的痕跡,這句『v1已改』的描述是不準確的(可能是講v1 spec的意圖被誤記成已落地、或講的是某個沒merge進main的worktree狀態)——要求訂正這句話,否則implementer可能誤以為T3是去修一個已存在的farm_contribution邏輯,實際上要做的是把整條:46-47替換掉(從零寫farm_contribution,非調整既有);★第三處level依賴查核(handback自己點名要查):親grep全scripts/simulation/『farming_level』逐一過濾,確認乘性farming_bonus這個bug pattern只出現在恰好2處——food_flow.gd:46+marginal_economy.gd:21(兩者都在T3 scope內)——faction_ai_system.gd:2161的facility_roi呼叫是這兩個估算器的下游消費者非獨立第三源,T3修完自動繼承;沒有漏第三處,T1/T2/T3三個task合起來窮盡覆蓋所有level依賴觸點;判決=CLEAN+1必查項(訂正§1食物流估算器現況描述)→dispatch"
---

# R②判決：labor-slice v2（level-decouple）HOW — CLEAN + 1必查項

## ★level-cancellation bug——親自重新推導代數，非只信 claim

親讀 `resource_system.gd:104-108` 確認 `fyield = level × FUY × flabor × harvest`（`:106`）+ `flabor = labor_mult = fill × SCALE`（`labor_system.gd:124`）+ `fill = alloc/demand`（`:92`）+ `demand[farm] = level × K_FARM`（`:56`）——代入化簡：

```
fyield = level × FUY × [SCALE × alloc/(level×K_FARM)] × harvest
       = FUY × SCALE × alloc × harvest / K_FARM
```

**`level` 分子分母親算真的完全相消**——這是真實存在、可獨立驗證的數學 bug，不是誤報。

v2 修法（`demand=level×K_FARM` 僅作 alloc capacity cap、production 直接 `alloc × per-labor-yield`[`level×FUY×harvest`]、不走 fill 除式）——親自驗算這樣 `production = alloc × level × FUY × harvest`，`level` 不再被除掉，真的修好 cancellation，數學正確。

## ★必查項：§1「現況」描述跟 main 實際狀態不符

spec §1「估算器（`food_flow:46-47` v1 已改加 `farm_contribution×farm_fill`...）」這句現況描述**跟 main 實際狀態不符**——親讀 `food_flow.gd:46-47` 確認現在 main 上仍是原始的 `farming_bonus = 1.0 + farming_level*0.5` 乘性 boost 公式（跟我上輪 labor-slice v1 審的時候看到的一模一樣、完全沒變），沒有任何 `farm_contribution` 或 `farm_fill` 的痕跡。這句「v1 已改」的描述不準確（可能是講 v1 spec 的意圖被誤記成已落地、或講的是某個沒 merge 進 main 的 worktree 狀態）。

**要求**訂正這句話，否則 implementer 可能誤以為 T3 是去修一個已存在的 `farm_contribution` 邏輯，實際上要做的是把整條 `:46-47` 替換掉（從零寫 `farm_contribution`，非調整既有）。

## ★第三處 level 依賴查核（handback 自己點名要查）——確認窮盡、無漏

親 grep 全 `scripts/simulation/` 的「`farming_level`」逐一過濾，確認乘性 `farming_bonus` 這個 bug pattern **只出現在恰好 2 處**——`food_flow.gd:46` + `marginal_economy.gd:21`（兩者都在 T3 scope 內）。`faction_ai_system.gd:2161` 的 `facility_roi` 呼叫是這兩個估算器的**下游消費者**，非獨立第三源，T3 修完自動繼承。沒有漏第三處，T1/T2/T3 三個 task 合起來窮盡覆蓋所有 level 依賴觸點。

## 判決
**CLEAN + 1必查項（訂正 §1 食物流估算器現況描述）→ dispatch。** level-decouple 的核心數學修正親算正確；估算器覆蓋範圍窮盡確認無漏；唯一要訂正的是 §1 對 `food_flow.gd` 現況的描述失準，這會誤導 T3 implementer 對工作量的預期。
