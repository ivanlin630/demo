# Hand Back: Trade 接公庫

> 日期：2026-06-11　branch：`feat/trade-public-storage`
> Spec：`docs/superpowers/specs/2026-06-11-trade-public-storage-design.md`
> Plan：`docs/superpowers/plans/2026-06-11-trade-public-storage.md`

## 實作摘要

改了哪些檔案：

- `scripts/simulation/interaction_system.gd`
  - `_absorb_public_storage` / `_spill_back_public_storage`：在自家 outpost 上的 team，交易前把 `tile.public_storage` 併入 `team.resources`，交易後依 cap 分流回公庫。
  - `_resolve_market`：開頭 absorb 雙方公庫、結尾 spill back；新增 `[Market] ... 成交` print（觀測用，偵測 coin 變動）。
  - `_try_trader_vs_outpost` / `_resolve_market_trader_vs_storage`：trader 抵達 owner 不在場的 outpost tile 時，暫 sync owner.tile_pos 讓 absorb 生效後跑 `_resolve_market`，跑完還原。
  - call site：`process_on_arrival` / `process_on_move` 內 same-tile 互動掃描後，對 moved/arrived team 補呼叫 `_try_trader_vs_outpost`。
- `scripts/debug/headless_test.gd`：+5 測試（round-trip / 別人 outpost 不 absorb / cap overflow / market absorb / 空 outpost）。

## 與 spec 的差異（重要）

Spec/Plan 的 helper 有**守恆 bug**，已修正：

- 原 plan `_absorb` 不清空 `tile.public_storage`，`_spill` 又把 `diff` 疊加到原 `stored` 上 → 物資雙重存在（round-trip 後公庫 50 會變 100，違反 plan 自己的 Task1a 測試）。
- 修正：**absorb 改為 MOVE**（`tile.public_storage[res] = 0`），spill 再把 team 多出來的分流回公庫；spill 的 `diff < 0` 分支改為保留 team 實際剩餘（`= current`）而非 `= orig`，避免憑空生資源。
- 結果守恆：公庫 + team 總量在 absorb→trade→spill 全程不變。Task1a/1c 測試驗證。

## 驗證

- headless：5/5 TradePublic 測試 OK，全檔 0 SCRIPT ERROR / 0 Assertion。
- multi（`game_sim_multi.gd`，21600 tick × 4 config）：跑完無崩潰，`[Market] 成交` = **2**（> 0，達標）。

## 連動風險

- `resolve_trade_direct`（玩家直接交易）：走 `_attempt_trade_direction`，**不經** `_resolve_market`，故不 absorb 公庫。玩家跟居民團交易時拿不到公庫物資 → 後續若要對齊行為，主 session 評估是否也接 absorb/spill。
- `OutpostSystem.new()._get_storage_cap`：spill_back 每個 res 都 new 一個 OutpostSystem（輕量，但高頻交易時可考慮快取）。
- `_try_trader_vs_outpost` 的 owner tile_pos 暫 sync 是 **hack**：跑 `_resolve_market` 期間 owner.tile_pos 短暫被改，若該函式內未來新增依賴 owner 真實座標的邏輯會出錯。

## 待主 session 確認

- **trade 成交數偏低（僅 2）**：根因不在本 spec — `trade_net` dispatch 大量 `target=-1`（432 次找不到 partner，`_find_trade_partner` 只選有 outpost 者）。接公庫已讓「有派到的」能成交，但派得到的太少。建議後續 task 檢視 `StrategicAiSystem._find_trade_partner` / trade_net 派遣與 partner discovery。
- **空 outpost trade hack 清理**：建議獨立 trade path（virtual partner 直接用 public_storage 當 resources），不再暫改 owner.tile_pos。
- **玩家交易是否也接公庫**（見連動風險）。
