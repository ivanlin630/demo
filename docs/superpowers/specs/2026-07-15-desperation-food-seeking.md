# Spec：絕境找糧真根修（A 買糧 look-before-leap + B 遷移找糧 + C 連貫窮死）

status: draft（待 reviewer R② CLEAN → dispatch implementer）
owner: systems
premise_verified: 真根 file:line 坐實（QA 交易 tap trace + code）；R① 免（前提已 tap trace 坐實）
blueprint_ruling: `2026-07-14-blueprint-to-systems-desperation-ladder-verdict.md`（WHAT=A+B+C；執行鎖廢；D 經濟供給 defer 觀察 slice）
frame_challenge: ★大框改求生路（新遷移行為 + 慾望配現實 gate）→ blueprint 明示「升異質框外審都可」→ R② 建議升異質 refute-first
governing: `game-design.md §決策模型 v2`（現實 gate 慾望）+ `invariants.md`（感知鐵律：只吃已知/可感知，非 god-view）

## 一句話
真根＝**買糧海市蜃樓（applicable 不驗真買得到）+ 隊困死選項不遷移**（QA trace 鐵證：Team20 死亡窗 coin=0、無食物賣方、料/武換不到糧、覓食當地不 applicable，卻死守買糧 880 tick 餓死）。修＝**A 買糧只在真買得到時當慾望目標 + B 買不到/覓不到時奮力遷移找糧 + C 真四方無糧才連貫地死**。執行鎖（recognizer thrash-fix）**廢**——真根修好 thrash 自然消。

## 真根（承重診斷，全坐實）
- `_attempt_trade_direction:768 if buyer_coin<=0: return`（coin=0 買不成）+ `_tick_food_granary_sell` 只定居隊糧倉>cap×0.5 賣糧（餓世界無賣方）→ 買糧單永不出貨。
- `options.gd:137 買糧 applicable = food_days<DESPERATION and has_food_market and has_specie`——**不驗真買得到**（has_specie Fix3c 納料/武 over-promise）。
- `_find_forage_tile` 只 radius-1 → 當地無野味即覓食不 applicable，隊**困死市集不遷移**。

## Fix A：買糧 look-before-leap（慾望配現實，鏡射 Fix4）
`decision_context.gd` 加 `has_buyable_food: bool`（+ gather 填），gate `買糧` applicable：
- **honest 定義（守感知鐵律）**：`has_buyable_food` = 隊**已知**有可達食物賣方——
  - `OrderSystem.received_sell_orders(team)` 含 `res=="food"` 且 pos 在可達範圍（隊聽過的食物賣單，firsthand/傳播）；**或**
  - coin>0 且最近糧市（`has_food_market`）確有食物供給信號（board 有 food sell entry）。
  - 只認**隊知道的**糧源（received orders / 板讀），非 god-view 掃全圖有沒有食物。
- `options.gd:137`：`... and has_specie and ctx.has_buyable_food`。
- 效果：無已知食物賣方時**買糧不入候選**（不當慾望目標）→ 隊 fall through 覓食/遷移/乞食/掠奪/併入。買不到就別追買糧＝慾望配現實。
- ⚠ **與 Fix3c 關係**：has_specie（料/武算付得起）保留當「有籌碼」；has_buyable_food 另軸管「有沒有得買」。兩軸都真才追買糧（有籌碼 + 有賣方）。

## Fix B：遷移找糧（絕境階梯新階，「奮力求生」核心）
當地求生選項全不可 fulfill（無 has_forage_tile / 無 has_buyable_food / 無 local prey·aid·join target）→ 隊**移動去找已知/可感知糧源**，非坐死市集。

**設計**：
1. **擴半徑找糧源**（`decision_context` 加 `food_seek_target: Vector2i`）：
   - 主：wider-radius（建議 N=3-5，TEST VALUE）掃 wild_game tile（隊對周邊地形的合理認知；非 god-view 全圖，是可感知鄰域）取最近。
   - 次：已知食物賣單 pos（`received_sell_orders` food 的最近可達 origin_pos）。
   - 取兩者最近可達者 → `food_seek_target`。無 → `(-1,-1)`（真無已知糧源 → C）。
2. **新 survival option `遷移找糧`**（options.gd SURVIVAL_OPTION_SET 加）：
   - applicable：`food_days < DESPERATION and food_seek_target != (-1,-1) and 當地覓食/買糧皆不 applicable`（只在坐死時才遷移，有 local 出路優先 local）。
   - `to_task`：move 向 `food_seek_target`（抵達後該格若有 wild_game → 覓食 relatch / 若是糧市且 has_buyable_food → 買糧 relatch）。task 建議複用 TASK_FORAGE（target=遠格）或 TASK_TRADE（target=糧市），implementer 定哪個乾淨承接抵達 relatch。
   - **排序**：絕境階梯 覓食(local)→**遷移找糧**→乞食→掠奪→併入（遷移優先於認慫乞食/搏命掠奪＝先自食其力找糧）。weight：survival_pressure 驅動（食物越低越想動），implementer 掛 term。
3. **latch/timeout（凡 in-flight guard 必配，藍圖鐵律）**：遷移找糧 dispatch 後配 timeout（按距離/移速估）——抵達或 timeout 重評，防移向糧源途中糧源消失卻死鎖。

## Fix C：連貫窮死（驗收準，非機制）
真四方無糧（無 local 覓/買、無已知糧源可遷移、無 prey/aid/join）→ 餓死＝合法悲劇（判準表 窮死 ✅）。**QA 驗 winner 連貫**：死前 trace 是「覓食/遷移找糧/乞食/掠奪/併入 輪番嘗試、四處落空」，**非死守買糧海市蜃樓**。這是故事 QA 驗收，非 code gate。

## 觸及檔
- `decision_context.gd`：`has_buyable_food` + `food_seek_target`（+ gather 填，finder 各跑一次 cheap）。
- `options.gd`：買糧 applicable 加 `has_buyable_food` gate；新 `遷移找糧` option（applicable + to_task + SURVIVAL_OPTION_SET）。
- `terms.gd`：遷移找糧 weight term（survival_pressure 驅）。
- finder：wider-radius 覓食掃 + 已知食物賣單 pos（`faction_ai` helper 或 context 內，implementer 定）。
- `faction_ai_system.gd`：遷移找糧抵達 relatch（覓食/買糧承接）+ latch/timeout。
- **無執行鎖 recognizer**（那個廢；本修不碰 `_in_survival`）。

## invariant 守
- **感知鐵律**：has_buyable_food/food_seek_target 只讀隊**已知**糧源（received orders / 可感知鄰域 wild_game），**禁 god-view 掃全圖**。這是硬約束，R② 重點驗。
- **慾望配現實**（決策模型 v2）：買糧只在真買得到時當目標＝正向落地。
- **凡 in-flight latch 必 timeout**（藍圖鐵律）：遷移找糧配 timeout。
- **determinism**：finder 純確定性讀（wild_game/orders），零 randf。
- **憲法/決策模型**：遷移找糧走引擎 rank（survival option），非硬寫行為腳本；無新判斷器。
- **憲法 site-freeze**：遷移找糧經 to_task→TaskArbiter dispatch，若新 try_set 落點需更 constitution_baseline（implementer 標，systems 審）。

## 驗收法（measurer 重跑 + QA 故事複判）
1. **A 生效**：無已知食物賣方時，specimen 買糧**不入候選**（trace candidates 無買糧海市蜃樓）；有賣方才入。
2. **B 生效**：困死市集型隊（Team20/Team18）**離開死市集移向糧源**（trace 見 遷移找糧 winner + move + 抵達覓食/買糧 relatch）；不再原地守買糧 880 tick。
3. **C 連貫（★故事 QA 複判，headline）**：Team20/Team18 + 新指定死隊 specimen → 死前 trace 求生選項輪番嘗試、四處落空才死＝連貫窮死；**QA 判「奮力後死」非「守幻覺死」**。
4. **thrash 自然消（驗執行鎖不需要）**：買糧不選海市蜃樓 → 反覆重試壞買糧的抖動源頭消失 → thrash-flip ≈0（不靠執行鎖）。
5. **不回歸**：determinism byte-identical；憲法 sites（新 dispatch 落點更新 baseline 則標）；established/attrition 全-HD 定性不惡化（平衡待 gen 重校，本輪主判故事連貫）；感知鐵律守（無 god-view）。
6. **Team18 一併解**：孤隊不再卡 31 天買糧 death-limbo（買不到→遷移或連貫死）。

## dispatch 註（reviewer R② CLEAN 後）
- **新分支 `feat/desperation-food-seeking`**（base 最新 main，含 cherry-pick 的 tap/bed infra；execlock 分支廢棄）。
- R②：★升異質框外審（別 Opus 代 + refute prompt）——大框改求生路。重點驗：感知鐵律（無 god-view）、遷移不製造 churn（latch/timeout）、遷移找糧 vs 乞食/掠奪排序合理、A gate 不誤殺真買得到的買糧、C 驗收準可判。
- 完成判定 = systems + reviewer/QA。implementer TDD：構「當地無糧+遠處有 wild_game」場景，斷言隊選遷移找糧移向它（非守買糧）；構「真四方無糧」斷言連貫嘗試序。
