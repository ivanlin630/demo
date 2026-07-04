# Hand Back: Trade 估值單一真值源（TradeValuation）

## 實作摘要

- `scripts/simulation/trade_valuation.gd`（新）：`class_name TradeValuation`。canonical `BASE_PRICE` / `TARGET_PER_POP` / `SURVIVAL_GOODS` const + 唯一 `static local_value(team, res) -> float`。表逐鍵原樣搬自 `interaction_system` 現值（含「# in」原料成本調過值）。公式 = interaction 的 survival 不對稱（food/medicine shortage>0.5 → 最高 5×）＋ player_trade 的 coin guard（`if res=="coin": return 1.0`）。
- `scripts/simulation/interaction_system.gd`：刪自己的 `BASE_PRICE`/`TARGET_PER_POP`/`SURVIVAL_GOODS` const + `_local_value`。`local_value()` 改 `return TradeValuation.local_value(...)`。內部估值/表引用（`_calc_reserve`、`_attempt_trade_direction` 的 inventory/surplus 賣出、`BASE_PRICE.keys()` 迭代）全改 `TradeValuation.X`。
- `scripts/simulation/player_trade_system.gd`：刪 `BASE_PRICE`/`TARGET_PER_POP` 副本 + `_local_value`。`get_tradeable_resources`/`evaluate_offer`/`preview_offer` 的估值與白名單迭代改 `TradeValuation.local_value` / `TradeValuation.BASE_PRICE`。保留 `_sellable_qty` + `FOOD_RESERVE_TICKS`/`MAX_COIN_PER_TRADE`/`WEAPON_RESERVE_RATIO`（非估值）。
- `scripts/simulation/player_api_mapper.gd`：`map_trade_session` DTO 天平 give/want_value + player/target items unit_value + 白名單，由 `InteractionSystem.local_value` 改 `TradeValuation.local_value`/`TradeValuation.BASE_PRICE` → **天平(give/want)與接受(evaluate_offer)同源**。移除已不需要的 `inter` 實例。
- `scripts/simulation/faction_ai_system.gd`：`_find_trade_target`（商隊 gap 評估）+ 設施缺口評估的 `InteractionSystem.BASE_PRICE/TARGET_PER_POP`/`inter._local_value` 引用改 `TradeValuation.X`。移除已不需要的 `inter` 局部變數。
- `scripts/simulation/player_query_api.gd`：comment 更新（`_local_value` → `TradeValuation.local_value`）。
- `scripts/debug/headless_test.gd`：新 `_test_trade_valuation_single_source`（survival 5× 區，三路 direct/interaction.local_value/player_trade preview 同單價 == 天平==接受；coin 硬閘 1.0）。既有 `_test_price_covers_input_cost`/`_test_famine_price_spike`/Material Task4b/trade conservation 的 `InteractionSystem.BASE_PRICE` 與 `PlayerTradeSystem.BASE_PRICE`/`isys._local_value` 引用改 `TradeValuation.X`。

## 與 plan 的差異

- **plan File Structure 表只列 4 檔（interaction/player_trade/api_mapper/headless_test）改動，但實際多改 `faction_ai_system.gd` + `player_query_api.gd`。** 原因：plan Step（Task2 註）已要求「BASE_PRICE/TARGET 若被估值以外用途引用，那些也改 `TradeValuation.X`」。grep 發現這兩處外部引用 `InteractionSystem.BASE_PRICE/TARGET_PER_POP`/`inter._local_value`，刪除 interaction 的 const 後會編譯失敗，故一併改向單一源。屬 plan 既定指引內，非新規則。
- canonical 表搬到 `TradeValuation` 後，**所有舊 `InteractionSystem.BASE_PRICE` / `PlayerTradeSystem.BASE_PRICE` 外部引用統一改 `TradeValuation.BASE_PRICE`**（含 headless_test、faction_ai、api_mapper）。單一真實位置，符合 invariants「單一源」哲學。
- `manufacturing_system.gd` 另有獨立 `TARGET_PER_POP`（製造缺口排序用子集，非貿易估值），**未動**——不同語意、不同關注點，plan 範圍外。

## 驗證結果

- `headless_test.gd`：`=== DONE ===`，新 `[OK] _test_trade_valuation_single_source`，無 SCRIPT ERROR。
- `ui_flow_test.gd`：`=== UI Flow Test DONE === errors: 0`。
- `game_sim_multi.gd`：4 scenario 全 **coin_eq delta=0.00**（game_sim_test/tyrant/merchant/warzone），全 `InvariantSummary 違反總計=0`，SCRIPT ERROR count=0。
- canonical 表：**與舊 `interaction_system` 完全一致**（BASE_PRICE 21 鍵 + TARGET_PER_POP 21 鍵逐鍵原樣搬，含 goods 15 / weapon_melee_low 34 / ore_steel 24 等「# in」調值）。`player_trade` 舊副本（goods 5 / weapon_melee_low 8…，且缺 herb/horses/mounts/wagons/medicine）已刪。

## 連動風險

- `player_trade` 估值差異 = **預期行為**：player 交易現走 canonical 表（goods 5→15、weapon_melee_low 8→34 等漲價，且新增 herb/horses/mounts/wagons/medicine 可估值），是 drift 修正回真值源，非 bug。`coin_eq` 雙向守恆與單價無關（成交價兩側用同一單價，轉移守恆），已驗 delta=0。
- `faction_ai` 商隊 `_find_trade_target`：估值單價變大（canonical），gap score 絕對值變大，但選 target 的相對排序邏輯不變；headless/multi 已跑過無異常。
- DTO 天平：原 give/want 用 interaction(5×)、accept 用 player_trade(2×) 的 survival goods 不一致已消除——統一後玩家在缺糧 NPC 處的天平顯示值會更高（反映真實接受門檻），UI 數字會變，屬修正。

## 待主 session 確認

- 無 spec 未覆蓋的設計決策。
- 建議後續（plan Self-Review 已標獨立後續）：trade-economy-review 其餘問題（barter/saturation/offer-board）未在本 task 範圍。
- `manufacturing_system.TARGET_PER_POP` 與 `TradeValuation.TARGET_PER_POP` 內容部分重疊（製造子集）。目前語意分離（製造缺口 vs 貿易估值）故未合併；若日後要再收斂可評估，但非當前必要。
