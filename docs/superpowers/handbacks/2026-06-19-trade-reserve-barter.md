# Hand Back: Trade 問題1（reserve 單一源）+ 問題2（NPC barter）

## 實作摘要

- `scripts/simulation/trade_valuation.gd`：加 `FOOD_RESERVE_TICKS` const（從 player_trade 搬）+ `static func reserve(team, res)`（canonical 留底：food 按存糧 tick、coin 半留、其他按 target 需求）。武器留底統一走 target-based。
- `scripts/simulation/interaction_system.gd`：
  - `_calc_reserve` → delegate `TradeValuation.reserve`（單一源）。
  - `FOOD_RESERVE_TICKS` const 改為 alias `TradeValuation.FOOD_RESERVE_TICKS`（保留 `InteractionSystem.FOOD_RESERVE_TICKS` 對外引用，由 faction_ai_system:1158 使用，仍解析到單一源）。
  - `_resolve_market` 在兩個 `_attempt_trade_direction` 後加 `_attempt_barter(state, a, b)`。
  - 新 `_attempt_barter`：缺幣互補 surplus 等值互換（按雙方各自 local_value，缺方願付高/surplus 方願收低，價差內成交）。MVP 每 give_res 至多換一筆 + break。不碰 coin。
- `scripts/simulation/player_trade_system.gd`：`_sellable_qty` → delegate `TradeValuation.reserve`（全資源留底,修玩家刷光）。刪 `FOOD_RESERVE_TICKS` / `WEAPON_RESERVE_RATIO`（不再用）；保留 `MAX_COIN_PER_TRADE`。
- `scripts/debug/headless_test.gd`：加 `_test_trade_reserve_no_drain`（reserve 量不可賣 + 超量可賣 + delegate 同源驗證）、`_test_npc_barter_coinless`（兩缺幣團互補 barter 成交 + 雙方 coin 維持 0）。已註冊 `_initialize`。

## 與 spec 的差異

- plan Step 1 寫「搬 FOOD_RESERVE_TICKS」。為不破壞 `faction_ai_system.gd:1158` 的 `InteractionSystem.FOOD_RESERVE_TICKS` 引用，採「TradeValuation 為真值源 + InteractionSystem const alias」而非整段刪除。單一源仍成立（值只在 TradeValuation 定義一次）。faction_ai 引用未改（透過 alias 解析）。
- 其餘完全照 plan。

## 連動風險

- `faction_ai_system._can_trade`（:1157）：經 `InteractionSystem.FOOD_RESERVE_TICKS` alias 取 food reserve，值不變，行為等價。
- 玩家貿易（`player_trade_system`）：非 food/weapon 資源現受 target reserve 限（之前 0 留底）。玩家不再能掃光 NPC 的 material/ore/gem/tools/armor → 這是預期修正（問題1）。可能讓某些玩測「大量採購」行為受限,屬設計意圖。
- barter pass 每 tick market 結算都跑：multi sim 觀察僅 1 筆 `[Barter]` 成交（缺幣團少且 surplus 需精準互補才觸發），效能與既有平衡影響極小。

## 待主 session 確認

- barter MVP 限「每 give_res 至多一筆 + break」。multi sim 中 `[Barter] Team9 21xfood <-> Team6 3xgoods` 觸發一次（缺幣互補確實能換,修對稱性）。若後續想讓缺幣團更積極換貨,可放寬「一筆」限制（避免巢狀爆量需另測 coin_eq）。
- barter 等值用雙方各自 local_value（價差內成交）。價差由 surplus/shortage 決定,屬 NPC 估值自然產物,非 scripted。
- 問題5（需求飽和）/ offer-board 為獨立後續,本 task 未涵蓋（plan self-review 已標）。

## 回歸結果

- `headless_test.gd`：`=== DONE ===`，無 SCRIPT ERROR。新測試 `[OK] _test_trade_reserve_no_drain (reserve=50)`、`[OK] _test_npc_barter_coinless (a material=348, b food=20, coins=0/0)`。
- `ui_flow_test.gd`：`=== UI Flow Test DONE === errors: 0`。
- `game_sim_multi.gd`：四 config 全跑完，**coin_eq delta=0**（game_sim_test/tyrant/merchant/warzone 全 init==final），**全 invariant 違反=0**，無 SCRIPT ERROR。barter 觸發 1 次（`Team9 21xfood <-> Team6 3xgoods`）。
- pre-existing baseline：ui_logic_test 2 個 vision-dist FAIL 未理會（依指示）。
