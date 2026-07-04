# Hand Back: Movement Boundary Fix

## 實作摘要

- `scripts/simulation/movement_system.gd` — `_step_team` 新增 `state.world.tiles.has(nid)` guard，濾掉地圖外鄰格；新增 stuck handler：若所有 on-map 鄰格均不靠近目標，清除 move_target 並 return false
- `scripts/debug/headless_test.gd` — 新增 30-step boundary 測試：以 (9999,9999) 為目標，驗證 team 每步均在地圖內

與 spec 無差異。

## 連動風險

- `_step_team` 加了 `state` 依賴性（原本只讀 `team`），但 `state` 已是既有參數，無 API 變動。
- stuck handler 會清除 NPC 的 move_target，可能導致 NPC 在地圖邊緣停頓，等待下一次 FactionAI tick 重設目標。這是可接受的退化行為。

## 待主 session 確認

- 無
