# Hand Back: Encounter Map Hex Boundary Fix

## 實作摘要
- `scripts/simulation/encounter_system.gd`：加 `MAP_DIAMETER` 常數；加 `_is_in_map` 驗證函數；將 `_get_edge_hexes` 從矩形邊界改為正六邊形邊界
- `scripts/debug/headless_test.gd`：加 `EncounterMapShape` 驗證區塊，確認六條邊各 11 tile、60 唯一邊界 tile、MAP_DIAMETER=20
- 與 spec 無差異

## 連動風險
- `advance_encounter_tick`（encounter_system.gd:596）：退場判斷 `dist_to_edge` 仍用矩形公式 `MAP_RADIUS - maxi(abs(x), abs(y))`，與新六邊形邊界不一致。六邊形角落外側區域單位可能無法正確退場。主 session 評估是否需補修。

## 待主 session 確認
- 退場邊界是否需同步改為六邊形距離判斷（`hex_dist(ZERO, pos) >= MAP_RADIUS`）
