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
- **honest 定義（守感知鐵律，★R②#1 修正）**：`has_buyable_food` = **唯一支**：`OrderSystem.received_sell_orders(team)` 含 `res=="food"` 且 origin_pos 距隊 ≤ `MERCHANT_MAX_RANGE`（既有常數，`order_system.gd:10`）。
  - `received_sell_orders` 讀 `team_known`（來源限 `read_market_board` 物理在場注入 + message 傳播失真）＝隊**真知道的**食物賣單，守感知鐵律。
  - **★刪除原第二支「遠端讀糧市 board」**（R②#1：違 `order_system.gd:189-198`「不在 outpost tile→讀不到」既有鐵律，我原 spec 誤標違律寫法為 honest）。要遠端知糧供給只能靠 received（傳播）或親臨。
- **★不濾 stale（R②#4，血訓 `order_system.gd:161-163` G1d/r3）**：`received_sell_orders` **保留過期/失真副本**（追舊單=有理由出門→到市集撞活單/撲空 emergent 是設計，濾掉重演「資訊自證飢荒」崩盤 成交15→6/5→0）。∴ stale food 賣單**入** has_buyable_food（撲空後靠 Fix B 遷移/Fix C 連貫死收）。**這是刻意**：買糧 applicable = 隊「以為買得到」（有聽過賣單），非全知「真有貨」。
- `options.gd:137`：`... and has_specie and ctx.has_buyable_food`。
- 效果：**從沒聽過任何食物賣單**時買糧不入候選（不追純幻覺）；聽過（含 stale）則入，撲空由 B/C 承接。買不到就別追＝慾望配現實。
- ⚠ **與 Fix3c 關係**：has_specie（料/武算籌碼）保留；has_buyable_food 另軸管「有沒有聽過賣方」。兩軸都真才追買糧。

## Fix B：遷移找糧（絕境階梯新階，「奮力求生」核心）
當地求生選項全不可 fulfill（無 has_forage_tile / 無 has_buyable_food / 無 local prey·aid·join target）→ 隊**移動去找已知/可感知糧源**，非坐死市集。

**設計**：
1. **感知內找糧源**（`decision_context` 加 `food_seek_target: Vector2i`）：
   - 主：**視野內**掃 wild_game tile 取最近。**★半徑經 `VisionSystem` 導出（R②#2）**：用 `VisionSystem` 的視野（`VISION_RADIUS=3` × 地形係數 `TERRAIN_VISION_MULT` + scout bonus），**禁另立自由半徑常數**（超視野=god-view + 違空間常數污染條）。隊只找**自己看得到的**野味格。
   - 次：已知食物賣單 pos（`received_sell_orders` food 的 origin_pos，同 Fix A honest 來源）。
   - **★可達性過濾（R②#5）**：兩類 target 都須過 `PathSystem` 可達檢查（`estimate_catch_up(...).reachable` 或 `find_path` 非空，鏡射既有情報 finder 先例）——山/水隔斷的 target 排除，防「選回同一不可達 target → dispatch→timeout→dispatch 永動」死循環。
   - **★wild_game 支繼承 pop 守衛（R②#3）**：wild_game target 僅當 `population <= FORAGE_VIABLE_POP` 才算數（同 `options.gd:84` 覓食守衛）——否則 pop>15 隊追永遠吃不到的野味死＝新型不連貫死（正犯 C 要防）。pop>15 隊 food_seek 只走「已知食物賣單」支。
   - 取通過(可達+適用)者最近 → `food_seek_target`。無 → `(-1,-1)`（真無可達已知糧源 → C 連貫死）。
2. **新 survival option `遷移找糧`**（options.gd SURVIVAL_OPTION_SET 加；獨立 option 非參數化 forage 半徑＝保 weight/trace 可讀性 + 承諾慣性獨立，R② advisory）：
   - applicable：`food_days < DESPERATION and food_seek_target != (-1,-1) and 當地覓食·買糧皆不 applicable`（有 local 出路優先 local）。
   - `to_task`：move 向 `food_seek_target`。task 複用 TASK_FORAGE（target=遠野味格）或 TASK_TRADE（target=糧市），implementer 定。
   - weight：survival_pressure 驅（食物越低越想動）。**★排序=emergent 非硬階梯（R② advisory）**：weight×人格 argmax 自然排（膽小隊可能先乞食＝合憲個性），spec 不 prescribe 嚴格順序。
3. **★抵達 relatch = release 非新 try_set（R②#6，憲法閘）**：遷移找糧抵達 `food_seek_target` → **`TaskArbiter.release(team)` → 下個 cadence 引擎 rank 重秤**（該格有 wild_game→覓食自然勝 / 是糧市且 has_buyable_food→買糧自然勝）。**禁在 faction_ai 手寫新 try_set 落點**（憲法閘契約 `invariants.md:14` 新增=FAIL，會擋）。→ 零新 mutation site、零 constitution_baseline 變動。
4. **latch/timeout（凡 in-flight guard 必配，藍圖鐵律）**：遷移找糧 dispatch 後配 timeout（按距離/移速估）——抵達或 timeout release 重評，防移向糧源途中糧源消失死鎖。

## Fix C：連貫窮死（驗收準，非機制）
真四方無糧（無 local 覓/買、無已知糧源可遷移、無 prey/aid/join）→ 餓死＝合法悲劇（判準表 窮死 ✅）。**QA 驗 winner 連貫**：死前 trace 是「覓食/遷移找糧/乞食/掠奪/併入 輪番嘗試、四處落空」，**非死守買糧海市蜃樓**。這是故事 QA 驗收，非 code gate。

## Fix A-2：併入 look-before-leap（完成 A 覆蓋，2026-07-15）
**背景**：blueprint 原 A=全求生選項 look-before-leap，v1 只做買糧。QA 複判：買糧✅、掠奪✅（移動延遲非幻覺）、乞食=死 rung（never-selected，另案）、**併入=幻覺**（code 定音，見下）。

**併入幻覺 code 坐實（systems 讀 code 定音）**：`_resolve_join`(`interaction_system:1094`)→`_absorber_accepts`(`:1066`)：`feed_ok = clampf(combined_days/ABSORBER_MIN_SURVIVE_DAYS,0,1)`，`accept_util=(野心0.6+統領0.4)×feed_ok`，`< ACCEPT_UTIL_THRESHOLD` → 拒 → `release joiner`。**餓世界 absorber+joiner 合隊糧低→feed_ok≈0→恆拒**→joiner 重選併入→又拒→loop，`faction_id` 永不變。`_resolve_mergein` 是 **full-or-nothing absorb（無 partial）**→Team26 pop 3→2→1=餓死非漸進吸收（blueprint(b)排除）。∴ 併入同買糧幻覺。

**設計（Fix A gate 家族，慾望配現實）**：`decision_context` 加 `has_acceptable_join_host: bool`，gate `options.gd:103` 併入 applicable：
- **honest 定義（守感知鐵律）**：有**可達**（PathSystem）host（strong_neighbor/consolidate_target）且 joiner **依自身認知預估** host 收得起——鏡射 `_absorber_accepts` 的 feed_ok，但**用 joiner 對 host 的 belief 估 host 糧/pop**（`BeliefSystem.best_estimate`），**非 god-view 讀 host 精確 effective_food**。粗估 `combined_days_est ≥ ABSORBER_MIN_SURVIVE_DAYS × 保守係數` 才算 acceptable。
  - 無 belief（沒情報）→ 保守**當不可估**（不入候選；認慫投靠陌生強鄰本就該先有接觸/情報，合感知鐵律）。
- `options.gd:103`：併入 applicable 加 `and ctx.has_acceptable_join_host`。
- 效果：餓世界無收得起的 host 時**併入不入候選**（不追必被拒的幻覺）→ 隊 fall through 覓食/遷移/掠奪 或連貫窮死。**這是慾望配現實在投靠層**。
- ⚠ **不誤殺真投靠**：belief 估 host 收得起（含 stale/失真副本，同 A 不濾原則）→ 入候選；到場真被拒（host 現況變）→ 既有 release 回退（撲空 emergent 保留，非 bug）。gate 只擋「明知（依情報）沒 host 收得起」的純幻覺，非所有可能撲空。

## 觸及檔
- `decision_context.gd`：`has_buyable_food`（received food 賣單，≤MERCHANT_MAX_RANGE，不濾 stale）+ **`has_acceptable_join_host`（belief 估可達 host 收得起，Fix A-2）** + `food_seek_target`（VisionSystem 視野內 wild_game[繼承 pop 守衛] / 已知食物賣單，皆過 PathSystem 可達）（+ gather 填）。
- `options.gd`：買糧 applicable 加 `has_buyable_food` gate；新 `遷移找糧` option（applicable + to_task + SURVIVAL_OPTION_SET）。
- `terms.gd`：遷移找糧 weight term（survival_pressure 驅）。
- finder（`faction_ai` helper 或 context 內）：VisionSystem-導出半徑 wild_game 掃 + received 食物賣單 pos + PathSystem 可達過濾。
- `faction_ai_system.gd`：遷移找糧 latch/timeout；**抵達→`TaskArbiter.release`→引擎重秤（零新 try_set 落點）**。
- **無執行鎖 recognizer**（那個廢；本修不碰 `_in_survival`）。**★零新 TaskArbiter mutation site → constitution_baseline 不變**（R②#6）。

## invariant 守
- **感知鐵律（R②#1/#2 修正後守）**：has_buyable_food 只讀 `received_sell_orders`（team_known，物理在場/傳播來源，**無遠端讀板**）；food_seek_target wild_game 只掃 **VisionSystem 視野內**（含地形係數，**無自由半徑常數、無 god-view**）。
- **慾望配現實**（決策模型 v2）：買糧只在「聽過食物賣單」時當目標＝正向落地。
- **不濾 stale 情報**（R②#4，血訓）：received 賣單保留過期/失真副本（撲空 emergent 是設計，濾掉重演資訊自證飢荒崩盤）。
- **凡 in-flight latch 必 timeout**（藍圖鐵律）：遷移找糧配 timeout + 可達性過濾（防死循環，R②#5）。
- **determinism**：finder 純確定性讀（VisionSystem/wild_game/orders/PathSystem），零 randf。
- **★憲法 site-freeze（R②#6）**：遷移找糧**抵達→`TaskArbiter.release`→引擎 cadence 重秤**，**零新 try_set 落點 → constitution_baseline 不變**。若實作發現非得新 mutation site＝**紅旗**，停下報 systems 特批，**非 implementer 自決更 baseline**。
- **憲法/決策模型**：遷移找糧走引擎 rank（survival option weight×人格），非硬寫行為腳本、無新判斷器；排序 emergent 非 prescribed。

## 驗收法（measurer 重跑 + QA 故事複判）
1. **A 生效**：**從沒聽過任何食物賣單**時買糧不入候選（trace candidates 無純幻覺買糧）；**聽過（含 stale 過期單）則入＝合法**（撲空後由 B/C 承接，非 bug——R②#4 不濾 stale）。
2. **B 生效**：困死市集型隊（Team20/Team18）**離開死市集移向視野內可達糧源**（trace 見 遷移找糧 winner + move + 抵達 release→覓食/買糧引擎重秤承接）；不再原地守買糧 880 tick。pop>15 隊不追野味（走賣單支或連貫死）。
3. **C 連貫（★故事 QA 複判，headline）**：Team20/Team18 + 新指定死隊 specimen → 死前 trace 求生選項**輪番嘗試、四處落空**才死＝連貫窮死；**QA 判「奮力後死」非「守幻覺死」**。**★不要求嚴格階梯順序（R② advisory）**——weight×人格 argmax emergent（膽小隊先乞食=合憲個性非 bug）；連貫=「試過真出路且真在動」，非固定序。
4. **thrash 自然消（驗執行鎖不需要）**：買糧不選海市蜃樓 → 反覆重試壞買糧的抖動源頭消失 → thrash-flip ≈0（不靠執行鎖）。
5. **不回歸**：determinism byte-identical；憲法 sites（新 dispatch 落點更新 baseline 則標）；established/attrition 全-HD 定性不惡化（平衡待 gen 重校，本輪主判故事連貫）；感知鐵律守（無 god-view）。
6. **Team18 一併解**：孤隊不再卡 31 天買糧 death-limbo（買不到→遷移或連貫死）。

## R② 修訂記錄（v2，2026-07-15）
異質框外審（Fable，refute-first）抓 6 條全 file:line 坐實，v2 逐條收斂：#1 has_buyable_food 刪遠端讀板支（只 received）；#2 wild_game 半徑錨 VisionSystem（無自由常數）；#3 wild_game 支繼承 FORAGE_VIABLE_POP；#4 明寫不濾 stale + 驗收準改；#5 food_seek_target 加 PathSystem 可達過濾；#6 抵達 release→引擎重秤（零新 try_set，baseline 不變）。advisory：獨立 option 理由補、C 排序改 emergent、has_food_market god-view 既有債記 known_issues（下）。

## dispatch 註（reviewer R② v2 CLEAN 後）
- **新分支 `feat/desperation-food-seeking`**（base 最新 main，含 cherry-pick 的 tap/bed infra；execlock 分支廢棄）。
- **R② v2 = 標準審複核**（reviewer 定：大框方向已過，這輪收斂細節，不需重升異質框外審）。
- **has_food_market god-view 既有債（R② advisory）**：`_nearest_market_outpost` 掃全圖＝既有 god-view 債，非本刀 blocker，記 `known_issues.md`。
- 完成判定 = systems + reviewer/QA。implementer TDD：構「當地無糧+視野內可達 wild_game」斷言隊選遷移找糧移向它（非守買糧）+ 抵達 release 後覓食承接；構「真四方無糧/不可達」斷言連貫嘗試 + 不死循環。
