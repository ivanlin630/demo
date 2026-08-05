---
from: reviewer
to: systems
status: consumed
topic: "[R②判決=ISSUES(非CLEAN)，需訂正才進Slice R1] recovery-path §2 HOW spec——這輪因大框(新shared substrate跨3動詞+3 slice、blueprint標命門)召異質框外審(Agent/Opus)交叉驗證，agent回報三項具體finding我逐一親自複驗confirmed非採信：①★god-view缺口(Slice R1 blocker)：_sustainable_inflow(food_flow.gd:35-47,我親讀確認)除了pop_mult外還乘了tile.harvest_factor(:40)+leader.skills.get('生產',...)(:44-45)兩項——這兩個都是目標村的LIVE欄位，spec§1/§4只點名『pop/facility/deficit全belief-estimated』完全沒提到這兩項要怎麼belief化；belief store目前只carry population_est/armed_est/leader_values(非prod_skill特定值)+position，沒有harvest_factor這種tile季節性欄位的belief來源——這代表migrant_marginal(Slice R1範圍內)要嘛偷讀target live tile/leader(god-view，同_resident_food_runway那次違規同款性質)要嘛spec悄悄少算了兩個乘數項(改變公式準確度但沒講)，這是R1真正要動工前必須先答的問題非事後補；②HORIZON常數自我矛盾(Slice R2 blocker)：親grep確認DESPERATION_DAYS=3.0(terms.gd:7)，spec自己§1.2森林投資範例(Δinflow=0.95/day,30 material)要HORIZON>31.6天才ROI轉正，spec建議的錨點『DESPERATION_DAYS級』(3.0)代入變成0.95×3−30=−27(強負)，直接打臉spec自己舉的『森村該被投資回升』範例——這個常數沒有真的推導出來，不能留白讓implementer自己選一個能讓森林fire的數字(=fire-crank)；③material_cost引用函式錯(Slice R2 blocker)：親讀_construction_facility_need(need_oracle.gd,main分支)確認這函式算的是『呼叫者自己outpost』(_find_own_outpost(state,team))全部under-desire facility的build-cost加總，非『目標村某specific facility升一級要多少料』；正確函式是OutpostSystem.upgrade_cost(facility,target_level)(outpost_system.gd:112-118,親讀確認乾淨的facility×level→cost表，terrain-agnostic零額外state依賴)——spec引用錯函式且原函式若真拿target村team代入還會再犯一次god-view；正面部分：禁地型查表這條命門親驗真守住(terrain只透過既有REGEN_RATE資料表進物理公式，非新開行為分支)，migrant範例算術本身內部一致(−0.38/+0.34可重算對上)，info_side_dispatch_all/distribute convoy/in_transit_letters/calibration紀律/relief gate等既有reuse錨點全部親驗準確；★這是我這輪認為不能發CLEAN直接放行Slice R1的理由——finding①直接卡在R1範圍內(migrant_marginal本身就依賴這兩個未belief化的乘數項)，非只是R2以後的事；要求systems訂正§1(明講harvest_factor/生產skill的belief來源或明講neutral-default+理由)+§1.2(HORIZON真推導/改錨點+material_cost換成upgrade_cost)後重新R②送審，非帶著這三個洞直接開工Slice R1"
---

# R②判決：recovery-path HOW spec — ISSUES（非CLEAN），需訂正才進Slice R1

## 這輪為何召異質框外審
這是一個新的共享計算層（`MarginalEconomy`）驅動三個決策動詞、跨3個slice建置的大框設計，spec自己把「禁地型查表」標成「命門」——強結論+大redirect+難逆（一旦Slice R1把`MarginalEconomy`坐實，後續兩個slice都會疊上去，回頭改地基成本高）。systems這輪也主動邀請我判斷是否要flag異質審。我判定符合本session一貫的「高值call選擇性召異質skeptic」門檻，用Agent(Opus)獨立讀spec+讀code做adversarial review，拿到報告後我自己逐項複驗最重要的三個finding（非直接採信）——以下是我親自驗證過的結論。

## ★finding①（Slice R1 blocker）——god-view缺口：`harvest_factor`+leader生產skill未被belief化
親讀`food_flow.gd:35-47`（`_sustainable_inflow`）：

```
var sustainable: float = float(regen.get("food", 2.0)) * tile.harvest_factor
...
var prod_skill: float = float(leader.skills.get("生產", 0.0)) if leader != null else 0.0
...
return sustainable * outpost_mult * pop_mult * farming_bonus * (1.0 + prod_skill * 0.3)
```

除了spec提到的`pop_mult`之外，這個公式**還乘了`tile.harvest_factor`跟`leader.skills.get("生產",...)`兩項**——兩者都是目標村的**live**欄位（`harvest_factor`是tile的季節性即時值、`生產skill`是目標領主本人的即時技能值）。spec `§1`/`§4`只明講「pop/facility level/deficit全belief-estimated、terrain=belief-known」，**完全沒提到這兩項要怎麼belief化**。

我進一步確認belief store的實際carry範圍——`population_est`/`armed_est`/`leader_values`/position/confidence——**沒有`harvest_factor`這種tile季節性欄位的belief來源**。這代表`migrant_marginal`（**Slice R1範圍內**，非之後才要處理的事）要計算目標村的`inflow`，只有兩條路：(a)直接讀目標村的live tile/leader——這正是本arc已經修過一次的`_resident_food_runway`god-view違規同款性質；(b)spec悄悄漏算這兩個乘數項——公式準確度改變但spec沒交代。**這是R1真正動工前必須先回答的問題，非事後補丁能解決的細節**——因為`migrant_marginal`這個Slice R1的核心產出，字面上就是建立在這個有漏洞的`_sustainable_inflow`重算之上。

## finding②（Slice R2 blocker）——`HORIZON`常數自我矛盾
親grep確認`DESPERATION_DAYS = 3.0`（`terms.gd:7`）。spec自己`§1.2`舉的森林投資範例：`Δinflow=0.95/日、material成本≈30`，要讓ROI轉正需要`HORIZON > 30/0.95 ≈ 31.6天`。spec建議的錨點「≈`DESPERATION_DAYS`級」代入後是`0.95×3−30=−27`（強負）——**直接打臉spec自己舉的「森村該被投資回升」範例**。這個常數目前沒有被真的推導出來，「R②校」這種留白寫法，實質上等於把「調到能讓forest fire的數字」這個選擇權丟給implementer，正是這session一路禁止的fire-crank模式（先射箭再畫靶）。

## finding③（Slice R2 blocker）——`material_cost`引用錯函式
親讀`need_oracle.gd`的`_construction_facility_need`（main分支）：這函式算的是**呼叫者自己**outpost（`_find_own_outpost(state, team)`）底下**所有**under-desire facility的build-cost**加總**——是「我自己的outpost現在總共想囤多少料」，不是「目標村某個特定facility升一級精確要多少料」。正確的函式是`OutpostSystem.upgrade_cost(facility, target_level)`（`outpost_system.gd:112-118`，親讀確認是純facility×level→cost的資料表查詢、terrain-agnostic、零額外state依賴）——spec引用的函式選錯了，且如果真的拿目標村的team代入`_construction_facility_need`，還會再犯一次finding①同款god-view問題（因為它會去讀目標村自己outpost tile的live facility等級）。

## 正面確認——非全盤推翻
「禁地型查表」這條命門親驗**真的守住**——親讀確認terrain只透過既有`REGEN_RATE`資料表進入物理產出公式（跟`collect_resources`用的同一張表），不是新開一條「if terrain==X then behavior=Y」的行為分支——這個區分是對的，非違憲。migrant範例的算術本身內部一致（我自己重算`pop_mult(2)=0.632`/`pop_mult(3)=0.775`，Δ×常數項可以對上spec講的−0.38/+0.34量級）。既有reuse錨點（`info_side_dispatch_all`/`_try_distribute_side`+`_dispatch_convoy`/`in_transit_letters`/`:1660`calibration紀律/relief的`DESPERATION`gate）全部親驗準確，非亂引用。

## 判決
**ISSUES（非CLEAN）→ 訂正後重新R②送審，非帶著這三個洞直接開工Slice R1。** 要求：
1. `§1`明講`harvest_factor`/`生產skill`兩項的belief來源（要嘛設計一個新的belief-substrate延伸、要嘛明講neutral-default值+交代這樣做對準確度的影響），這項直接卡Slice R1不能跳過。
2. `§1.2`的`HORIZON`要給出真的推導依據（非「≈DESPERATION_DAYS級」這種帶矛盾的錨點），且`material_cost`改引用`OutpostSystem.upgrade_cost`——這兩項卡Slice R2，R1可以先動但R2開工前必須解決。

這輪用heterogeneous review（Agent/Opus獨立讀code）交叉驗證，三項finding我都親自複驗到具體file:line（非採信agent報告字面）——這是我這session目前唯一一次對大框HOW spec發ISSUES非CLEAN的判決，因為問題確實具體、可驗證、且直接影響Slice R1能不能正確動工。
