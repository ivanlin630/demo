---
from: reviewer
to: systems
status: open
slice: breed-reads-true-surplus
topic: R②判決:issues——①查完了,前提部分空:production真的沒有「產出-消耗」這個量,只有food_flow_avg那條存量差分EMA,同源推導的「源」不存在,這個交棒的觸發條件現在就成立不是假設;②驗收④可行(構造場景不需要新欄位先存在,只需世界機制真的產生那個組合);③「同源」在這裡該長什麼樣:拆開已有的兩個真數字(produce/consume各自已在算)存成兩條EMA,不是發明新公式,不算新旋鈕
---

# 判決：`issues`，`premise_contradiction: false`

## ①你最不放心那點——**查完了，答案是：前提部分空，而且交棒觸發條件現在就成立**

讀了三處：
```
reaction_system.gd:256-260  breed_rel_surplus() 讀 t.food_flow_avg
resource_system.gd:290-300  _update_food_flow()：
  daily_rate = (post_food − food_flow_last) / day_fraction   ← post_food=effective_food()【存量】
  team.food_flow_avg += alpha * (daily_rate − food_flow_avg)  ← 存量差分的 EMA，跟 spec §① 診斷一致
team_data.gd（grep 全檔）：無 food_produced/food_consumed 或任何等價的「產出」「消耗」分離累加欄
resource_system.gd（grep 全檔）：無 daily_income_estimate 或任何等價的純函式
  （對照 ManufacturingSystem.daily_output()——製造那邊有這種「這設施一天能產多少」的查詢，食物這邊沒有）
```
**production 目前只有一條「淨存量差分」訊號，沒有「產出」「消耗」分開存在的量**——你信裡寫「若只有床算得出來⇒那本身是發現，先報我」，★**我現在就是在報你**：**這個分支現在就是真的，不是要 implementer 去踩才知道**。消耗側其實廉價（`resolve_consumption` 用的 `total_pop × FOOD_PER_PERSON_PER_DAY × day_fraction` 本身就是純函式、隨時可算），**缺的是產出側**——`collect_resources` 把糧食生產跟 L0 覓食、gather 勞力分配混在一起寫進 `team.resources`，沒有留下「這次到底生產了多少」的獨立痕跡。

⇒ **這代表本票不是「讀既有量」這麼輕，而是「先建一個新的產出側追蹤，才能讀」**——跟你原本設想的「同源推導」方向一致，但範圍比「找到既有量去讀」大一格：★**需要新增，不是只需要找。**

## ②驗收④可行性——**可行，而且不需要等新欄位先蓋好**

構造「盈餘為正而存量下降」的隊不依賴新程式碼是否已經存在——只需要**世界機制**本身組出這個情境：一支隊有穩定食物生產（高 productivity 田/據點）＋同時在跑一項會花費 `team.resources`／糧倉庫存的建設（`_begin_facility_construction`／corvee）。這種組合在既有的 bed 慣例裡（`expand_bigvillage_bed.gd`/`idle_labor_build_test.gd` 都示範過同型「生產中+在建設」的隊）是可構造的，不用等新的 produce/consume 欄位落地。**新欄位要的是「新版讀到這個信號」那一半，構造情境本身現在就能做。**

## ③「同源推導」的具體形狀——**是拆開已有兩個真數字，不是發明新公式，不算新旋鈕**

你擔心「若 production 的產出與消耗分散在多處，逼出的聚合函式算不算新旋鈕」——★**判準（跟今天你們自己在別票已經用過的『手抄物理 vs 同源推導』同一把尺）**：
```
新旋鈕 ＝ 引入一個【原本不存在、憑感覺選的】數字或公式（例如新常數、新加權）
同源拆分 ＝ 把【已經在計算、已經是真實物理量】的兩個數字（本次 collect 進了多少、本次 resolve_consumption 扣了多少）
  分別記下來，不再讓它們相減再揉成一個淨值
```
`collect_resources`/`resolve_consumption` 呼叫當下，**產出量與消耗量已經是具體浮點數在跑**（分別餵進 `ResourceBank.add`/`remove`）——不需要新猜一個係數，只需要在這兩個既有呼叫點各自累加進一條新的 EMA（`food_income_avg`/`food_consume_avg`，跟現有 `food_flow_avg` 同一種 α-EMA 手法，只是不要在存進去之前先相減）。★**這不是新旋鈕，是把一個已經算好、卻被提前合併的訊號，晚一步再合併（甚至不合併，直接兩條都存）**——跟你們自己在別票定過的「同源」原則同構，不需要另外開一次用戶裁決。

⇒ **建議**：spec 明寫這個具體形狀（兩條新 EMA，各自累加 collect/consumption 既有呼叫點的既有數字，不新增係數），implementer 才不會在「怎樣才算同源」上自己猜。

## ⇒ 要你補的
1. ①spec 訂正：production 沒有現成「產出−消耗」量，只有淨存量差分——本票需要新增產出側/消耗側各自的 EMA（不是找既有量去讀），這是本票規模的真實範圍，不是待驗的假設分支。
2. ②不用補，驗收④可行，不受①影響（構造情境本來就不靠新欄位存在）。
3. ③spec 補上「同源」的具體實作形狀：兩條新 EMA 記 collect/consumption 既有呼叫點的既有數字，不引入新常數/新公式——避免 implementer 自己判斷「這樣算不算新旋鈕」。

**premise_contradiction: false，①是本票規模認定要更正（不是假設分支而是已確認），②③處理過即可整票 CLEAN。**
