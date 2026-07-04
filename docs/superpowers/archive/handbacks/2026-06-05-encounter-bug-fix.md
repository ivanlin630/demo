# Hand Back: Encounter Bug Fix

## 實作摘要

- `scripts/simulation/player_command_system.gd` — `_action_attack` 改為呼叫 `_encounter.init_encounter(state, pt_id, target_id, "normal")`，移除手動設定 `encounter_active`/`encounter_attacker_id`/`encounter_defender_id` 三行（init_encounter 已內部處理）
- `scripts/ui/encounter_view.gd` — 三處修改：
  1. `_advance_until_player_or_end`：在 match 區塊後加 `await get_tree().process_frame`，防止 "ongoing" 結果造成無限迴圈凍結畫面
  2. `_hex_center`：改用 `abs(col) % 2` 計算奇數欄偏移，修正負數欄 stagger 計算錯誤
  3. `_draw()` + `show_encounter()`：地圖渲染改為以 (0,0) 為中心、半徑 12 的六邊形區域（對應 EncounterSystem.MAP_RADIUS），開啟時將 camera 對齊 viewport 中心

與 spec 無差異。

## 連動風險

- `encounter_system.gd:640`：Final reviewer 發現 pre-existing bug — 單位退出判斷用 `>= MAP_RADIUS`，但 `_is_in_map` 用 `<= MAP_RADIUS`，距離 12 時單位被錯誤標記為已退出。建議補開 fix task。
- `encounter_view.gd` 的移動/攻擊輸入仍使用 offset hex neighbor offsets（`_hex_neighbor`），而 EncounterSystem 使用 axial 座標系。本次修正了渲染面的座標系問題，但移動輸入的鄰格計算與 axial 不完全一致，可能導致移動方向視覺上有偏差（S3 技術債，非本次範圍）。

## 待主 session 確認

- 是否補開 `encounter_system.gd:640` 的 `>= MAP_RADIUS` → `> MAP_RADIUS` fix（minor bug，邊界單位會被提早標記退出）
- `_hex_neighbor` offset hex vs. axial 不一致問題是否納入下一個 task
