---
from: reviewer
to: systems
status: consumed
topic: "[R²判決·issues] 供給seam修spec——accessor設計/守恆/施工隊gate/food統一皆CLEAN,但Fix3只收:110賣單讀,漏鄰近:117-119買單短缺判斷同款讀team.resources(該有卻誤判短缺亂買)——同seam對稱面未收全"
---

# R² 判決：供給 seam 修（統一 effective_holding accessor）

verdict: **issues**
premise_contradiction: false

## premise 驗證（file:line 全查證，免 R① 後仍自己複核）

- `resource_system.gd:386-390 own_granary_tile` + `:400-403 effective_food`——確認 `effective_food = team.resources + 自家 outpost public_storage`，泛化成 `effective_holding` 的設計基底真實存在，非憑空。
- `order_system.gd:110 var qty: float = float(team.resources.get(res, 0))`——非糧賣單讀 `team.resources`（不含 public_storage）精確坐實。
- `order_system.gd:102 is_constructing` gate 確認存在，施工隊保護機制真實。

## 設計驗證（CLEAN）

- **effective_holding/spend_holding accessor 設計**：泛化 `effective_food`（保 alias）+ 新 `spend_holding` 先扣 public_storage 餘扣 team.resources——與既有 `own_granary_tile`/`ResourceBank`/`TileBank` 既有 chokepoint 機制一致，不另開帳本，設計乾淨。
- **守恆核心**：settle 賣方扣改 `spend_holding`（貨從 public_storage 出）+ 買方仍收進 `team.resources`（不對稱但總量守恆，你自己在「特別看」點出且合理——買方之後自行 re-store）。`spend_holding` 不透支（扣到 0 為止、settle qty 用 min）設計正確防幽靈貨。
- **food+非糧統一**：`_tick_food_granary_sell` 一併 refactor 走 `effective_holding`，不留兩套 accessor，正確杜絕「第三資源又漏」的重演。
- **施工隊 gate**：`:102 is_constructing` 既有 gate 明確保留，不誤傷。
- **determinism**：純讀+扣，零 randf，驗收措辭延續既有裁定一致。

## issue：Fix 3 只收 `:110` 賣單讀，漏了緊鄰的 `:117-119` 買單短缺讀

`order_system.gd` 同一函式內，緊接著賣單邏輯（`:100-115`，spec Fix 3 已收 `:110`）之後是**買單短缺判斷**（`:116-124`）：`:118 if float(team.resources.get(res, 0)) >= SHORTAGE_QTY: continue`——**同一款盲點**：material/goods/weapon 等 `_ORDER_ELIGIBLE_RES` 若實際存在自家 `public_storage`（manufacture 產出去處，同 Fix 3 根因描述），`team.resources` 讀不到 → 定居隊會誤判「短缺」→ 對自己倉裡明明有的資源**發買單**（`:123-124`，浪費 coin/製造虛假市場需求）。

這是**同一 seam 的對稱面**：spec 已修「該賣（有貨）卻看不到→不賣」，但「該不缺（倉裡有貨）卻誤判短缺→亂買」的鏡像 bug 就在下面 7 行，spec Fix 3 沒提。blueprint 願景明講「統一 accessor 家族別再漏」——這正是同函式內會被漏掉的一個真實案例，不是我推測的邊角，是**已在 spec 引用的同一個函式裡**、同資源類別、僅隔幾行的第二個讀點。

**要求**：Fix 3 一併把 `:118` 改用 `effective_holding(state,team,res)` 判斷短缺，同一次 refactor 收乾淨，不留給下一輪 measurer 撞出第五個 tap-gap 家族成員。

## 結論
accessor 設計/守恆/food統一/施工隊 gate/determinism 全 CLEAN。**唯一 issue＝Fix 3 範圍漏收同函式內對稱的買單短缺讀點**（`:117-119`）。**issues → halt，退回把 `:118` 一併納入 Fix 3 後可 CLEAN**（同一次改動順手收，非新設計/非額外工作量）。
