# Hand Back: 玩家系統

## 實作摘要

- `scripts/simulation/player_system.gd`（新建）：PlayerSystem class，含 init_player、add_to_inventory、calc_inventory_weight、take_from_team、deposit_to_team、_get_player_team、get_visible_teams、equip_item、unequip_item
- `scripts/debug/headless_test.gd`（修改）：加 Player 驗證段，測試所有 5 個核心操作

與 spec 差異：
- equip_item 寫入 equipment slot 時，type 用短格式（`grade.replace("weapon_", "")`）而非 spec 的 `"pool"`，原因見連動風險說明

## 連動風險

- `EquipmentSystem`：EquipmentSystem.tick_all 會處理 player 所在 Team0，若 `equipment["right_hand"]["type"] == "none"` 會自動從 team pool 補裝備。equip_item 現在寫入正確短格式（如 `"melee_low"`），EquipmentSystem 不會覆蓋，行為正確。
- `SkillSystem` / `InteractionSystem`：這兩個系統用 `match p.equipment["right_hand"].get("type", "none")` 計算戰鬥力。player 裝備格式現已與 NPC 一致，戰鬥計算正確。
- `WorldState.player_state`：此 dict 由 init_player 設定，模擬 tick 過程中無其他系統寫入，無衝突。
- `team_discovered`：get_visible_teams 回傳 `.duplicate()`，外部修改不影響 state。

## 待主 session 確認

- **PLAYER_MAX_WEIGHT 未強制執行**：常數定義為 30.0 但 add_to_inventory / equip_item 均不做重量限制，超重不阻止操作。目前為測試用設計，正式需確認是否需加 guard。
- **玩家被 EquipmentSystem 處理**：player person（team0 leader）每 tick 都會走 EquipmentSystem 流程。若 player 所在 team 的 resources 有武器，EquipmentSystem 可能嘗試補裝——但因 equip 後 type != "none"，實際不會覆蓋。建議主 session 評估是否需在 EquipmentSystem 加 `if pid == state.player_id: continue` 跳過玩家。
- **建議後續 task**：encounter-system（遭遇戰時需讀取 player 裝備/視野），可直接引用 PlayerSystem.get_visible_teams 與 PersonData.equipment。
