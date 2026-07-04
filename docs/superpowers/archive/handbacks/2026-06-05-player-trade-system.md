# Hand Back: Player Trade System

## 實作摘要

- `scripts/simulation/player_trade_system.gd` — 新建。PlayerTradeSystem class：`get_tradeable_resources`、`evaluate_offer`（三層審核）、`preview_offer`（dry-run）、`execute_offer`
- `scripts/simulation/player_command_system.gd` — 新增 `_action_submit_trade_offer`；修改 `_action_confirm_trade` 檢查 `trade_offer` key 並委派；registry 加入 `submit_trade_offer`（實際為 `match` 語句，非 dict，spec 誤記）
- `scripts/simulation/player_query_api.gd` — 新增 `get_trade_preview`（原本不存在，非替換），返回 resources + offer_preview，加入 team 存在性與可見性 guard
- `scripts/debug/headless_test.gd` — 加入 PlayerTradeSystem 單元測試 + submit_trade_offer 指令測試；coin 種子修正確保 mutation 斷言實際執行

### 與 spec 的差異

| 差異 | 原因 |
|---|---|
| `MessageSystem` → `SimMessageSystem` | spec typo，codebase 實際類名 |
| `emit_message` 4 params（非 5） | spec 多帶了不存在的 metadata 參數 |
| `get_trade_preview` 為新增非替換 | 原 player_query_api.gd 無此 function |
| registry 為 `match` 非 dict | 實際 PlayerCommandSystem 使用 match 語句 |
| `state.current_tick` → `state.world.current_tick`（兩處）| latent bug：WorldState 無 current_tick 欄位 |
| 新增 negative-quantity guard + empty-offer guard（evaluate_offer）| code review 發現 |
| 新增 team 存在性/可見性 guard（get_trade_preview）| code review 發現，與 sibling functions 一致 |
| BASE_PRICE 新增 `"coin": 1.0`（TARGET_PER_POP `"coin": 20.0`）| spec 列 13 種但未明列，推斷為 coin |

## 連動風險

- `interaction_system.gd` BASE_PRICE 仍為 12 種（無 coin）。PlayerTradeSystem 多了 coin。NPC auto-trade 不支援 coin 作為交易資源，player-trade 支援。若需統一，須同步更新 interaction_system.gd。
- `_action_confirm_trade` 的 legacy fallback（無 trade_offer 時呼叫 `resolve_trade_direct`）仍存在，保持向後相容。
- `MAX_COIN_PER_TRADE = 300.0` 常數已宣告但未套用 — player 出價 coin 上限無限制（NPC auto-trade 有套用）。現為設計決策，未來可加上 cap。
- `_local_value` / `BASE_PRICE` / `TARGET_PER_POP` 與 `interaction_system.gd` 重複。同步注意：兩者若不一致，NPC-NPC trade 與 player-trade 的 NPC 估值會不同。

## 待主 session 確認

- `coin` 加入 BASE_PRICE 的決策是否正確？或 coin 應以特殊方式處理（face-value only）？
- `interaction_system.gd` 的 BASE_PRICE 是否需同步加入 coin？
- `MAX_COIN_PER_TRADE` 是否應在 `execute_offer` 中套用，防止玩家一次性掏空 NPC coin？
