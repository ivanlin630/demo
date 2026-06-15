# Hand Back: Encounter Map Hex Boundary Fix

## 實作摘要
- `scripts/simulation/encounter_system.gd`：加 `MAP_DIAMETER` 常數；加 `_is_in_map` 驗證函數；將 `_get_edge_hexes` 從矩形邊界改為正六邊形邊界
- `scripts/debug/headless_test.gd`：加 `EncounterMapShape` 驗證區塊，確認六條邊各 11 tile、60 唯一邊界 tile、MAP_DIAMETER=20
- 與 spec 無差異

## 連動風險
- ~~`advance_encounter_tick`（encounter_system.gd:596）：退場判斷 `dist_to_edge` 仍用矩形公式 `MAP_RADIUS - maxi(abs(x), abs(y))`，與新六邊形邊界不一致。~~ **已於 commit `9d6e032` 修正**：退場邊界改用 `hex_dist`，與六邊形邊界一致。
- 無其他已知連動風險。

## 待主 session 確認
- ~~退場邊界是否需同步改為六邊形距離判斷~~ → 已自行採用 `hex_dist(ZERO, pos) >= MAP_RADIUS` 並驗證（headless `EncounterMapShape OK`、`=== DONE ===` 無 SCRIPT ERROR）。

## 驗證
- headless_test 通過：`EncounterMapShape OK`（6 邊各 11 tile、60 唯一邊界 tile、MAP_DIAMETER=20）、`=== DONE ===`、0 SCRIPT ERROR。
