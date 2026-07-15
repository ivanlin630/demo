# Spec：供給 seam 修 — 統一 effective_holding accessor（經濟維第一刀）

status: draft（待 R² → dispatch implementer）
owner: systems
premise_verified: ★file:line 坐實——manufacture 產出→public_storage(`_add_output:117`)、非糧賣單讀 team.resources=0(`order_system:110`)、settle 扣 team.resources(`_execute_transfer:665`)；full-HD 觀察血證 order_fulfilled≈0 + arb_kill_nostock 數千/月
blueprint_confirm: `2026-07-15-blueprint-to-systems-supply-seam-fix-direction.md`（願景：非糧賣 accessor 對齊 public_storage + 統一 accessor 家族別再漏；先修 seam 啟動經濟）
governing: `invariants.md`（資源守恆 + 所有權域單源）+ [[project_framework_seams]]（資源搬位置讀者必跟）

## 根因（framework seam，同 WS-2c food accessor 家族）
manufacture 產出（goods/weapon/ore_steel/armor…）→ outpost 隊進 `tile.public_storage`（`_add_output:117-118`）；但**非糧賣單讀 `team.resources`=0**（`order_system:110`）→ 定居隊製造的 surplus 在糧倉、賣單查私產看不到 → **永不掛非糧賣單** → 市場無貨 → arb_kill_nostock。food 賣單已修（`_tick_food_granary_sell:138` 讀 granary），**非糧漏同款修**＝seam 修一半。

## Fix（統一 accessor 家族，別再漏）

### Fix 1：統一讀 accessor `effective_holding`
`ResourceSystem` 加 `effective_holding(state, team, res) -> float` = `team.resources.get(res)` + 自家 outpost `public_storage.get(res)`（複用 `own_granary_tile`；泛化現有 `effective_food` = `effective_holding(...,"food")`，保 effective_food 為 alias 不破既有 caller）。**所有資源賣單走此**，不分 food/非糧。

### Fix 2：統一 spend accessor `spend_holding`（★守恆核心）
`ResourceSystem` 加 `spend_holding(state, team, res, qty)` = **先扣 public_storage（貨在那），餘額扣 team.resources**（`TileBank.deposit(tile,res,-x)` + `ResourceBank.add(team,res,-y)`，守恆、不透支）。回實際扣量。

### Fix 3：非糧賣單讀 effective（`order_system:110`）
`var qty = ResourceSystem.effective_holding(state, team, res)`（取代 `team.resources.get`）→ 定居隊製造 surplus（≥20）觸發賣單。**food 路（`_tick_food_granary_sell`）同 refactor 走 effective_holding**（統一，不留兩套；food 保 cap×reserve 語意＝賣超 reserve 的半）。

### Fix 4：settle 從正確 storage 扣（`_execute_transfer:665`）
seller `res` 扣 `ResourceSystem.spend_holding(state, seller, res, qty)`（取代 `ResourceBank.add(seller,res,-qty)`）→ 貨從 public_storage 出（製造成品所在）→ **守恆不賣幽靈貨**。coin/buyer 側不動（buyer 收進 resources 照舊）。

## 邊界（先修 seam，別過度）
- **只接對 storage**（讀+spend accessor 統一 + 賣單/settle 對齊），**非新機制、非改產能/價格/regen**。
- 產能夠不夠（material 採集 vs 消耗）＝**seam 修後 measure-first**（先看 revived 市場，別預修）。blueprint 願景明令：先修 seam→觀察 revived→再定發展模型。
- 施工隊不賣建材（`is_constructing` gate 保）。

## invariant 守
- **資源守恆**：spend_holding 扣實際 storage，不透支/不憑空（`ResourceBank`/`TileBank` chokepoint 走 ledger）。CoinAudit=0、InvariantAudit=0。
- **所有權域單源**：effective_holding/spend_holding 成資源「可賣/花庫存」單源 accessor（比照 effective_food），未來新資源賣單走此=不再漏（seam 統一收）。
- **determinism**：純讀+扣，零 randf。同 seed 兩跑行為變（市場活）=預期；驗收同 seed 兩跑 bit-identical。

## 驗收（★中性 full-HD + 守恆）
1. **★供給活**：order_fulfilled 從 ~0 回升（>0 顯著）、arb_kill_nostock 大降（有貨可撮）。
2. **市場流動**：定居隊製造 surplus 掛賣單（trade.post_sell 非糧 >0）、成交（fulfilled）、coin 流動（買方付賣方收）。
3. **★守恆**：CoinAudit delta=0、InvariantAudit=0、無幽靈貨（賣量=實扣量，public_storage 真減）。
4. **無誤傷**：施工隊不賣建材、food 賣單照常（227 筆量級不掉）、既有飢荒/貿易鏈綠。
5. **無回歸**：headless 零新增；憲法 sites=29；同 seed 兩跑 bit-identical。
6. **中性世界判**（force_full_hd 觀察世界）。
7. **★掛單噪音量測（blueprint+用戶抓，納驗收）**：供給修**前後對比** `order_placed`/`order_fulfilled`/`arb_call`/`arb_kill_nostock`（現 539-850 單/月、arb 數千、kill_nostock 8372-20331/月）。**看噪音是供給下游還獨立 churn**：
   - seam 修後 kill_nostock 大降（有貨可撮，供給下游噪音自消，像 flee 修 N1_flee 回落）→ 剩的是獨立 churn。
   - **剩的獨立 churn**（隊照掛 20-50 張/月 不管有沒有貨/買不買得起）→ **掛單紀律 follow-up**（下述，scope 待此量測定）。

## 掛單紀律 follow-up（order-discipline，scope 待噪音量測定，可同刀 or 下刀）
掛單噪音的獨立 churn 部分（供給修後殘留）＝churn 家族又一個（掛成不了的單還重掛，同 flee/買糧幻覺精神）。治＝**訂單 grounded**（訂單也是決策/行動，該 grounded，同結構稽核 grounded-ness 家族）：
- **grounded-order**（掛單版 look-before-leap）：買不到（無賣方）/賣不掉（無買方）/付不起（coin 不足）的單**別掛**。
- **dedup**：常駐單去重（別每 cycle 重掛同張，Team0 6 張跨 tick 不變重掛）。
- **expiry**：過期單清（掛太久沒成交 release）。
**本刀先量噪音組成**（驗收 #7）→ 供給下游自消多少 vs 獨立 churn 多少 → blueprint 定 order-discipline 同刀補 or 獨立下刀。**別預修**（先看 seam 修後噪音長什麼樣）。

## dispatch 註
- 新分支 `feat/supply-seam-effective-holding`，base 最新 main。
- **R²**（seam 修，標準審）：dispatch 前 to:reviewer 審設計（effective_holding/spend_holding 守恆、food+非糧統一不留兩套、settle 扣對 storage、施工隊保 gate、determinism）。premise file:line 坐實→免 R①。
- 完成判定 = systems + reviewer + measurer（中性 full-HD：order_fulfilled 回升 + arb_kill_nostock 降 + coin 流 + 守恆）+ blueprint 批。
- TDD：構「定居隊 public_storage 有 goods」斷言掛賣單（effective_holding 看到）；「成交」斷言從 public_storage 扣（守恆）；「施工隊」斷言不賣；「同 seed 兩跑」bit-identical。
- **修後 → blueprint+用戶觀察 revived 經濟 → 定發展模型細節**（先有結果紀律）。
