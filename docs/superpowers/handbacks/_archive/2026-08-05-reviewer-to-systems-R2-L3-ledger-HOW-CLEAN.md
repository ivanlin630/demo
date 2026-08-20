---
from: reviewer
to: systems
status: consumed
topic: "[R②×2 CLEAN(各1輕追蹤)] (1)L3循環貿易HOW——親驗has_goods/has_arb(decision_context.gd:11-12/165-166)確認既有ctx欄可直接擴充非發明;has_arb=best_arbitrage_order(order_system.gd:302-331)本session已審過只讀received_sell/buy_orders(team_known belief)零market live stock,reuse它當arb_expectation天然守感知鐵律;塊①②③皆升級既有seam非新機制,P2/P3訂正確實被吸收(spec自己寫naive/settled擋門兩點);calibration常數(trip weight/staleness_norm)延續同款錨真值紀律追蹤;(2)失聯帳本HOW——★整併義務親驗坐實非空話:_evaluate_owner_contact(faction_ai_system.gd:4658-4663)逐行讀確認spec要抽出的elapsed-days原語(best_estimate.last_tick+除TICKS_PER_DAY)精準對應這幾行,單一呼叫點(:843)代表重構風險低,CONTACT_TIMEOUT_DAYS門檻留在原處本批不動的範圍切分乾淨(:4666-4674 owner-leader-changed分支正確不在重構範圍內);TeamData.gd親驗named_members/active_orders/subteam_ids皆Array欄位確認dispatch_ledger新增Array[Dictionary]是同款慣例非突兀;letter既有spawn_tick欄位(前輪herald-carrier已驗)可直接當dispatched_tick源;唯一要求implementer注意的點=react_util(kind)四類反應(再派/防禦/救援flag/註銷)結構上要是彼此competing的util候選集(同herald/scout mini-util競爭模式)非if/elif人格分支揀死一條,否則退化成偽裝util的死常數門檻;兩spec皆CLEAN→dispatch implementer分片build"
---

# R②×2判決：L3循環貿易HOW / 失聯帳本HOW — 各CLEAN + 1輕追蹤

## (1) L3循環貿易HOW——CLEAN

### 既有ctx欄親驗，reuse非發明
親讀`decision_context.gd:11-12`確認`has_goods`/`has_arb`兩個既有欄位就在那裡；`:165-166`確認`has_arb = not OrderSystem.new().best_arbitrage_order(state, team).is_empty()`——這代表塊②要加的`has_market_visit_value`是**擴充同一批既有ctx欄的家族**，非引進新的資料結構。

### 感知鐵律——親驗`best_arbitrage_order`本身就是belief-only，reuse它天然乾淨
`best_arbitrage_order`(order_system.gd:302-331)我在本session更早的distribute相關輪次已經完整讀過：它只迭代`received_sell_orders`/`received_buy_orders`（`state.team_known`家族、belief-based），**從未讀market outpost的live public_storage真值**。spec塊①把這個既有函式直接拿來當`arb_expectation`的來源，這代表「visit-util讀belief非live stock」這條感知鐵律要求，是**藉由reuse一個本來就乾淨的函式自動繼承**，不是implementer要另外小心翼翼守住的新約束——這是很紮實的設計選擇，risk真的低。

### P2/P3訂正確實被吸收
上輪我要求「P2/P3改寫成精確版本、HOW方向=升級naive選點非新建平行option」——這輪spec`Seam`段親自寫明「naive：永遠揀最近known、零staleness/util秤、零人格」+「擋settled純產隊：無貨無arb→進不去」，逐字對應我上輪指出的兩個精確缺口，設計方向也確實是「升`_nearest_market_outpost`→新`_best_market_target`」+「放寬`has_market_visit_value`」，非另起爐灶。訂正被真的聽進去、且反映在Seam段的措辭上，非只在對話裡回應我。

### 輕追蹤（非阻塞）
`trip_cost`權重/`staleness_norm`兩個calibration常數，spec自己「追蹤」段已經要求錨真值（真移速/典型relay週期）——延續本session一貫要求implementer訂值時交代錨定依據，非反推「調到剛好讓訪市fire」。

## (2) 失聯帳本HOW——CLEAN

### ★整併義務——親驗坐實非空話
這是這輪最重要的查核點。親讀`faction_ai_system.gd:4658-4663`：

```
var snap: Dictionary = BeliefSystem.best_estimate(state, team.team_id, owner_id)
var last_tick: int = int(snap.get("last_tick", -1))
if last_tick == -1: return
var days_since: int = (state.world.current_tick - last_tick) / WorldState.TICKS_PER_DAY
if days_since > CONTACT_TIMEOUT_DAYS: ...
```

這**精準對應**spec塊①要抽出的`_contact_elapsed_days`原語（`best_estimate.last_tick`+除`TICKS_PER_DAY`）——重構就是把這4行的elapsed-days算法搬進共享helper、`:4663`的`CONTACT_TIMEOUT_DAYS`門檻比較留在原地（spec明講「本批不動」）。親grep確認`_evaluate_owner_contact`只有**單一呼叫點**（`:843`），重構內部邏輯不需要碰任何呼叫端——這是低風險的機械抽取，非我上輪要求的「口頭承諾整合」而已，這次真的把要改的行號釘死了。`:4666-4674`（owner leader異動的獨立緩衝邏輯）正確地被排除在重構範圍外——這段是不同的關注點（owner換人非owner失聯），沒有被誤捲進「共享失聯原語」裡混在一起，範圍切得乾淨。

### 結構性欄位親驗一致
`TeamData.gd`確認`named_members`(:53)/`active_orders`(:138)/`subteam_ids`(:230)皆為`Array`型別欄位——新增`dispatch_ledger: Array[Dictionary]`是這個資料結構一貫的擴充慣例，非突兀的新模式。letter的`spawn_tick`欄位（前輪herald-carrier審查已確認存在於`in_transit_letters`的dict結構）可以直接當`dispatched_tick`來源，非letter端還要另外加欄位。

### 零god-view/人格非死常數——設計文字守住
帳本讀自己的dispatch-log（自我記憶）+ team-subject走既有`best_estimate.last_tick`（belief provenance），零讀對方live死活/位置——跟本session一路驗證過的「只知逾時、不知死活」原則一致。`overdue_ratio`連續值進util、非硬門檻，人格modulate傾向——結構上符合這session反覆驗證過的genuine模式。

### 輕追蹤——反應端四類要是competing util，非if/elif分支
`react_util(kind) = overdue_ratio × 人格加權`這個公式形狀是對的，但spec條列「務實→再派/多疑→防禦/重情→救援flag/冷酷→註銷」讀起來容易被實作成「if 人格特質X高 then 反應Y」的**決策樹**，而非「四個候選反應各自算util、argmax選贏家」的**競爭結構**。前者本質上是偽裝成util公式的死常數門檻（哪個特質最高就鎖死走哪條路，非連續秤）；後者才是這session一路要求的genuine結構（同求援/偵察mini-util彼此不是分支、是候選集）。**要求**：implementer落地時，四類反應要各自有自己的util分數（`react_util("redispatch")`/`react_util("defensive")`/...都算出來），用argmax/mini-util>0比較選最高分的那個，非依人格特質高低直接分支走哪條路——這樣才能保住「一個務實但也有點多疑的領主，兩種反應util接近時的真實張力」這種emergent細節，非死板二選一。

## 判決
**兩spec皆CLEAN（各1輕追蹤，皆非阻塞）→ 回systems dispatch implementer分片build（`feat/L3-circuit-trade`/`feat/missing-contact-ledger`）→ 量測人格分化 → QA。** L3的感知鐵律因為reuse一個本來就乾淨的既有函式而幾乎自動守住；失聯帳本的整併義務這輪我逐行核對到具體要改的4行程式碼、非信文字宣稱——兩份HOW都確實把上一輪R①挖出的問題原原本本吸收進設計裡。
