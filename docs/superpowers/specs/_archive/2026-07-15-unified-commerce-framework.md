# Spec：統一商業框架（market-as-place，經濟 revive 主刀）

status: draft（大架構重構，待 R②[可能異質框外審] → dispatch implementer）
owner: systems
premise_verified: ★整條經濟調查 file:line 坐實——`_market_pos` 固定 outpost≠賣方實位(65% 漫遊)、TAG_MERCHANT=0 真閘 ARCHETYPE_TRADE(`faction_ai:2045`)、雙 resolver(board-travel `best_arbitrage_order:233` vs 到場 ask/bid `_attempt_trade_direction:664` + `_find_trade_target:2078`)、accessor 5 縫(order:110/118/252、trade_valuation:86、decision_context:138)、掛單死常數(FOOD_SELL_RESERVE_RATIO/FOOD_BUY_DAYS/孤兒 SURPLUS_RESERVE_MULT)、absorb/spill dance(interaction:724-725)
blueprint_vision: `2026-07-15-blueprint-to-systems-unify-whole-commerce-first.md`（用戶裁：整個商業框架一次做好、所有補釘融入、再量測；骨幹=B market-as-place；先有統一模型 revive 後磨）
governing: `invariants.md`（資源守恆 + 決策模型人格化 + 全量暫態可觀測性）+ [[project_unification_matrix]]/[[project_framework_seams]]

## 為何整框架一次做（用戶裁，非 hole-by-hole）
hole-by-hole 每融一縫→下個補丁擋（打地鼠：seam→churn→threat→accessor→coin→液化→漫遊，6+ 刀全 inert/held）；**補釘互相 confound 量測**（sequential 疊、舊公式複刻不可信）。∴ **整個商業子系統一次收進統一框架 + 全補釘融入 + 人格化 + 無殘補釘 → 跑乾淨模型量測**。骨幹＝**market-as-place（B）**：貨在 outpost，買方到市場買 stock，免賣方 team 在場（解 65% 漫遊）。

## 北極星：market = 地方（outpost），非 team-to-team 追人
- **市場節點＝outpost**：任何有貨（public_storage）/掛單（board）的 outpost ＝市場。貨留市場，買方來買。
- **成交＝買方到市場向 stock 買**（免賣方 team 在場）；扣 public_storage、coin 給 outpost owner team。
- **貿易決策＝目標選市場地方 + 到場 resolver 單一**。

## 統一模組（全收框架，人格化，de-patch）

### M1 市場節點 + 目標（target 收單一路徑）
- **`_nearest_market(state, team)`**：ARCHETYPE_TRADE（+ 任何有 buy 需求）隊 → 目標**最近/最優市場 outpost**（有 stock/board 的固定地方）。**收斂三路 fallback**（`_merchant_trade_target` arb→巡市集→`_find_trade_target`）成單一「選市場地方」。
- **★R②缺口2 修：市場知識＝「公開地標」豁免（路線 b，誠實非假裝）**：BeliefSystem 目前 team-keyed、**無 tile/market 級知識庫**——∴ 選市場**保留 `_nearest_market_outpost` 掃全 tile 的「市集=公開地標」豁免**（WS-2b 已論證的死鎖破除器，冷啟動靠它出門，拆掉=經濟停擺）。**不假裝 belief-based**；把「市集 outpost 公開可見（地標）」**誠實寫進 `invariants.md` 感知鐵律豁免清單**（同已有 known_reputations/同-faction 豁免）。belief-based market-knowledge store＝**未來增益 backlog**，非本刀。
- 移動：target=市場 outpost（固定地標，不漫遊）→ 到達穩定（解 65% 撲空）。

### M2 到場 resolver（單一，market-as-place，★含賣方變現半環）
**`_resolve_market_at_outpost(state, visitor, outpost)`**（隊到市場 outpost 觸發，取代 team-to-team `_attempt_trade_direction` 雙向 pair）——**owner-mediated 市場**：outpost owner team＝做市商，訪客對 owner 的 board 兩側交易。
- **★R②缺口1 修：賣方變現半環（雙側都寫）**：
  - **訪客買**（有 need）：向 outpost **sell 單/public_storage stock** 買 → 扣 public_storage、`visitor.coin → owner_team.coin`。
  - **★訪客賣**（有 surplus/merchant inventory）：向 outpost **buy 單** 賣（owner 掛的 buy 單＝收購需求）→ 貨入 public_storage、`owner_team.coin → visitor.coin`。**商隊「高賣」端有 resolver＝套利循環閉合、coin 雙向**（非單向泵）。owner buy 單無 coin→買不成（連 coin 循環風險，見驗收觀測項）。
  - **producer 變現**：settled producer＝自家 outpost owner → 產進自家 public_storage、買方來買 coin 入自team.coin＝自然變現（owner=producer）。resident 生產隊產進 owner 公庫→coin 歸 owner（faction 經濟；resident 個人不直接賺＝已知，coin 循環後磨處理）。
- **★R②缺口3 修：履約記帳權威側直記**：resolver 成交當下**按 `order_id` 直接沖 `active_orders` + board**（權威記帳，不靠 delta 推斷）；`settle_orders`（delta 法）**降級只服務巧遇路**。→ sell/buy 單成交即沖、不掛幽靈單（WS-2b 死鎖不復活）。
- **★R②#5 賣超語意**：計價/扣量以 `TileBank.withdraw` 實際取出量（現量 clamp），禁信 board 鏡像數字。
- **★R²#6 「+」鎖**：可購量=`min(board 單餘量, 現貨)`；**無單不賣**；SURVIVAL_GOODS 強制要有單（防活命糧被買穿，守驗收#6）。
- **★R²#4 無主 outpost coin**：owner 已滅團 → 成交 coin 入 `tile.public_storage.coin`（CoinAudit 池內，不蒸發）；或 abandoned_coin。
- **★R²#8 巧遇/市場路交界**：**outpost tile（有 board）＝market resolver 專屬**（`_resolve_market_at_outpost`）；**pairwise 巧遇 ask/bid resolver 限非市場格**（途中相遇機會交易，次路，不砍好戲）→ 同 tick 不雙 fire、不重複沖銷（明文分工）。
- **收斂雙 resolver**：board 決定去哪 + 到場認 board 單成交（旅行目標=成交對象一致）；`_find_trade_target` peer 路併入 market 路。

### M3 掛單層（人格化，廢死常數）
- **`order_system` 掛單讀人格**：sell（surplus）/buy（shortage）門檻走 `effective_holding` + 人格（`food_security_target` 統一，**廢 FOOD_SELL_RESERVE_RATIO/FOOD_BUY_DAYS**；**清孤兒 SURPLUS_RESERVE_MULT**）。
- **reserve 人格化 + 降底**（承液化設計，SURVIVAL_GOODS=food/medicine 保 floor 不甩活命糧；非活命品 `reserve_factor`：貪婪守/絕境鬆）。

### M4 accessor + 定價（統一，去 absorb/spill）
- **`effective_holding(state,team,res)`** 統一 **6 讀點（★R²缺口4 補第 6 縫）**：order:110/118/252、trade_valuation:86、decision_context:138 + **`_can_trade:2031`（`faction_ai` 貿易總閘，直讀 team.resources + `pop×0.1×FOOD_RESERVE_TICKS` 殭屍公式=`trade_valuation:68` 自稱已退役卻還活著）** → 全走 effective_holding + 廢殭屍公式。+ `spend_holding`（先扣 public_storage 餘 team.resources）。**廢 absorb/spill dance**（interaction:724-725）——accessor 直接 storage-aware，決策-執行語意對稱。
- **`local_value` 讀 effective_holding**（糧倉貨算進→不誤判短缺）。
- **ask/bid 人格化**（承液化：commerce 折扣 + 急鬆手/貪守價 + SPREAD_TOL willing 大多成交）。

### M5 de-patch（融入，無殘補釘）
- **held 分支融入/廢**：supply-seam(effective_holding)、液化(reserve/ask 人格化) → **全收進本框架 M2/M3/M4**（非獨立分支，一個統一框架）。coin-B(成員稅) → **降 coin 循環 backlog**（先乾淨模型 revive）。
- **★R²#9 死常數 kill-list（明確,implementer 照拆免拆一半留一半）**：`SURPLUS_RESERVE_MULT`(孤兒清)、`FOOD_SELL_RESERVE_RATIO`、`FOOD_BUY_DAYS`、`FOOD_BUY_TARGET_DAYS`、`SHORTAGE_QTY`、掛單 `×0.5` 硬碼、`20.0` surplus 門檻、`TRADE_MIN_STOCK`、arb 收益 `×0.1` 硬碼、`_can_trade` 殭屍公式(缺口4) → 人格化或收進 effective_holding/reserve_factor。**`MERCHANT_MAX_RANGE` 兩處重複宣告**(`order_system:10`+`faction_ai:2039`)→ 收單一源。
- **absorb/spill、雙 resolver、target 三 fallback** 全拆（M2/M4 已接手）。

## invariant 守
- **資源守恆**：全走 ResourceBank/TileBank chokepoint，coin/goods 只搬。CoinAudit=0、InvariantAudit=0。
- **感知鐵律**：★R²訂正——目標選市場走 **`_nearest_market_outpost` 的「市集=公開地標」豁免**（誠實入 invariants 豁免清單，同 known_reputations/同-faction；非假裝 belief——BeliefSystem 無 tile 級知識庫，belief-market store=backlog）。敵情/社交目標位置仍走 belief（god-view 位置根治不回退）。
- **全量暫態可觀測性**：新 resolver/target/掛單路徑接 specimen tap（盲點閘掃）+ 補 A 縫 tap（躲 public_storage 貨可觀測）。
- **determinism**：純人格+狀態，零 randf → 同 seed 兩跑 bit-identical（行為本就該變＝market-as-place，驗收同 seed 兩跑非 baseline）。
- **憲法**：決策交引擎（target/掛單走 rank/人格），無新 try_set 繞過。

## 驗收（★中性 full-HD + 守恆，先有 revive）
1. **★市場 revive（headline）**：`deal` 從 ~0 大幅升（到市場成交）；到場成交率大幅升（解 65% 漫遊）。**★R²#7：`deal_merchant`/`merchant_inventory` probe 改按 `ARCHETYPE_TRADE` 分流**（TAG_MERCHANT 全 0 隊，舊 probe 不可達）——修 probe 或指標改 archetype，順手處理 merchant_inventory 死路。
1b. **★R²coin 單向泵風險觀測（納量測視野）**：market-as-place 有結構性單向 coin 泵風險（買方→owner，賣方半環+resident 產貨 coin 歸 owner）→ **長窗 deals 不得單調衰減到 0**（脈衝 vs 穩態）+ **coin 分佈逐月記錄**（team/person/treasury/tile）。若量到脈衝→coin 循環（backlog）提前。
2. **統一無殘補釘**：雙 resolver→單一、target 三 fallback→單一、accessor 5 縫→一個、掛單死常數→人格化、absorb/spill 拆。憲法/矩陣稽核無殘。
3. **人格戲**：貪婪守價/絕境鬆手、reserve 人格差異（specimen 可讀）。
4. **★守恆**：CoinAudit=0、InvariantAudit=0、無幽靈貨。
5. **觀測**：新路徑 specimen tap + 盲點閘綠 + on/off byte-identical（觀測非侵入）。
6. **不誤傷**：活命糧不甩、既有飢荒/戰鬥鏈綠、resident 巧遇次路保。
7. **無回歸**：同 seed 兩跑 bit-identical、憲法 sites 面稽核、headless 零新增。
8. **中性世界判**。後磨（流動摩擦 tune / coin 循環 / threat 韌性）＝revive 後另刀。

## dispatch 註
- 新分支 `feat/unified-commerce`，base 最新 main。**大架構重構、多檔面**（order_system/interaction/trade_valuation/faction_ai/decision_context + accessor），worktree。
- **★R②（大框結構重構，可能升異質框外審）**：dispatch 前 to:reviewer 審統一設計（market-as-place resolver 正確+守恆、target 收斂、accessor 全統一、de-patch 無殘、人格化、觀測 tap、感知鐵律）。三對齊（藍圖願景+用戶+systems）大框→reviewer 判要不要升異質。
- 完成判定 = systems + reviewer + measurer（中性 full-HD：市場 revive + 統一無殘 + 守恆 + 觀測）+ blueprint 批。
- **held 分支處置**：supply-seam/coin-B/液化 融入本框架（M3/M4）；coin 循環願景降 backlog（revive 後）。
- **序**：先有（統一模型 revive）→ 後磨（流動摩擦/coin/threat，revive 後乾淨模型量得出真形狀）。
