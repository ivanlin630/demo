# Hand Back: PlayerCommands & Interaction

## 實作摘要

- `scripts/data/world_state.gd` — 新增 `player_pending_targets: Array` 和 `player_forced_event: Dictionary` 兩個欄位
- `scripts/simulation/interaction_system.gd` — (1) 新增 `resolve_trade_direct()` 和 `resolve_extortion_direct()` 兩個公開直接呼叫函式；(2) 替換舊玩家分支為四路非阻塞邏輯（combat / diplomacy / extort / pending）
- `scripts/simulation/player_command_system.gd` — **新建**，薄包裝層，含 `get_available_actions`、`execute_action`、`get_forced_response_options`、`respond_to_forced`、`clear_pending_targets`
- `scripts/simulation/sim_runner.gd` — 新增 `_player_cmd` member 及初始化、near zone forced_event 超時清除（`TICKS_PER_HOUR` 條件）、near zone 移動偵測後清 pending、`_get_player_tile_pos` helper
- `scripts/debug/headless_test.gd` — 新增 PlayerCommandSystem 7 項測試，全部通過，`=== DONE ===` 無 SCRIPT ERROR

### 與 spec 的差異

- Spec Step 3 說「找到近區 `TICKS_PER_HOUR` block」，但現有 sim_runner 近區無此 block。實裝時在 `_step1b_update_vision` 之前插入 `if current_tick % TICKS_PER_HOUR == 0:` 包裹 forced_event 清除邏輯（TICKS_PER_HOUR=1 in test，等效每 tick 執行）。

## 連動風險

- `InteractionSystem`：玩家分支邏輯大幅替換，原有「任何非同陣營遭遇都觸發 EncounterSystem」改為四路分流。路徑 1（NPC `combat_target == player`）維持原行為。**其他路徑需 UI 層接收 pending/forced 並讓玩家回應，否則互動事件將靜默忽略。**
- `SimRunner`：forced_event 每 TICKS_PER_HOUR 自動清除，若未來 TICKS_PER_DAY 調整為 240（TICKS_PER_HOUR=10），UI 必須在 10 ticks 內讓玩家回應強制事件。
- `PlayerCommandSystem._accept_diplomacy`：目前為 STUB，接受外交提案不產生實際效果（無陣營合併/同盟邏輯）。

## 待主 session 確認

- `_accept_diplomacy` STUB — 接受 NPC 外交提案應呼叫 `DiplomaticAiSystem` 對應方法，目前僅 print log，主 session 評估是否補開 spec。
- `recruit` action STUB — `execute_action("recruit")` 永遠返回 `ok=false`，接口預留，邏輯未實裝。
- UI 接入點 — `WorldState.player_pending_targets` 和 `player_forced_event` 已就緒，UI 層如何讀取並呈現給玩家屬 UI 系統職責，本 session 不涉及。
