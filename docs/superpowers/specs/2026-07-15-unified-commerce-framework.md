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
- **`_nearest_market(state, team)`**：ARCHETYPE_TRADE（+ 任何有 buy 需求）隊 → 目標**最近/最優市場 outpost**（有 stock/board 的固定地方）。**收斂三路 fallback**（`_merchant_trade_target` arb→巡市集→`_find_trade_target`）成單一「選市場地方」——用 belief（感知鐵律，去過/傳聞的市場），非 god-view 掃全 tile。
- 移動：target=市場 outpost（固定，不漫遊）→ 到達穩定（解 65% 撲空）。

### M2 到場 resolver（單一，market-as-place）
- **`_resolve_market_at_outpost(state, buyer, outpost)`**（買方到市場 outpost 觸發，取代 team-to-team `_attempt_trade_direction` 的雙向 pair）：
  - 讀 outpost board 的 sell 單 + public_storage stock → 買方按需求/coin/carry 買（ask/bid 人格化，見 M4）。
  - 扣 `public_storage`（貨在那）、`buyer.coin` → `outpost_owner_team.coin`。守恆走 TileBank/ResourceBank。
  - **收斂雙 resolver**：廢「board 決定去哪 + 到場另起機會性 ask/bid」的斷裂——**到場認 board 的單 + stock 成交**（旅行的目標＝成交的對象一致）。
  - **`_find_trade_target`（peer belief 估值差）與 board 路收斂**成單一「跟市場交易」。
  - **保留**：途中同格巧遇 resident 互售（機會交易）可續存為次要路（不砍好戲），但主路＝market-as-place。

### M3 掛單層（人格化，廢死常數）
- **`order_system` 掛單讀人格**：sell（surplus）/buy（shortage）門檻走 `effective_holding` + 人格（`food_security_target` 統一，**廢 FOOD_SELL_RESERVE_RATIO/FOOD_BUY_DAYS**；**清孤兒 SURPLUS_RESERVE_MULT**）。
- **reserve 人格化 + 降底**（承液化設計，SURVIVAL_GOODS=food/medicine 保 floor 不甩活命糧；非活命品 `reserve_factor`：貪婪守/絕境鬆）。

### M4 accessor + 定價（統一，去 absorb/spill）
- **`effective_holding(state,team,res)`** 統一 5 讀點（承 supply-seam 設計，收全含 :252/:86/:138）+ `spend_holding`（先扣 public_storage 餘 team.resources）。**廢 absorb/spill dance**（interaction:724-725）——accessor 直接 storage-aware，決策-執行語意對稱。
- **`local_value` 讀 effective_holding**（糧倉貨算進→不誤判短缺）。
- **ask/bid 人格化**（承液化：commerce 折扣 + 急鬆手/貪守價 + SPREAD_TOL willing 大多成交）。

### M5 de-patch（融入，無殘補釘）
- **held 分支融入/廢**：supply-seam(effective_holding)、coin-B(成員稅=coin 循環，**降框架債 backlog**先不併，先乾淨模型)、液化(reserve/ask 人格化) → **全收進本框架 M3/M4**（非 3 個獨立分支，一個統一框架）。
- **coin 循環（私囊鎖）**：先不併（先讓貨/相遇/成交通，coin 分佈屆時乾淨模型量得出真形狀）→ backlog。
- **absorb/spill、雙 resolver、target 三 fallback、死常數** 全拆。

## invariant 守
- **資源守恆**：全走 ResourceBank/TileBank chokepoint，coin/goods 只搬。CoinAudit=0、InvariantAudit=0。
- **感知鐵律**：目標選市場走 belief（去過/傳聞），非 god-view 掃全 tile。
- **全量暫態可觀測性**：新 resolver/target/掛單路徑接 specimen tap（盲點閘掃）+ 補 A 縫 tap（躲 public_storage 貨可觀測）。
- **determinism**：純人格+狀態，零 randf → 同 seed 兩跑 bit-identical（行為本就該變＝market-as-place，驗收同 seed 兩跑非 baseline）。
- **憲法**：決策交引擎（target/掛單走 rank/人格），無新 try_set 繞過。

## 驗收（★中性 full-HD + 守恆，先有 revive）
1. **★市場 revive（headline）**：`deal`/`deal_merchant` 從 ~0 大幅升（買方到市場買 stock 成交）；co-location/到場成交率大幅升（解 65% 漫遊）。
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
