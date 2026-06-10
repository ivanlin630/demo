# Hand Back: Mount 公庫系統

## 實作摘要

- `scripts/simulation/resource_system.gd`：`PUBLIC_RESOURCES` 加 `"mounts"`（mount 改 outpost 公庫資源）
- `scripts/simulation/outpost_system.gd`：
  - 加 `MOUNT_STORAGE_CAP = [10, 30, 80]`（index = outpost_level-1）
  - `_get_storage_cap` 加 mount 分支（mount 用專屬 cap，其餘走 generic）
  - `produce_stable_day` 產出改進 `tile.public_storage["mounts"]`（受 cap 限制），不再進 `owner.resources`
- `scripts/simulation/harvest_system.gd`：
  - 加 `HEX_DIRS` + `_collect_wild_horses_by_outposts`
  - `tick_all` 於日邊界（`current_tick % TICKS_PER_DAY == 0`）對所有 outpost 鄰格 `wild_horses` 批採進公庫
- `scripts/simulation/faction_ai_system.gd`：
  - 加 `MOUNT_TARGET_RATIO = 0.5` + `_auto_withdraw_mounts`
  - 串入 `evaluate_all` 末段 per-team 迴圈（task 評估後）：team 在自家 outpost + 非 idle → withdraw 至 `population × 0.5`
- `scripts/debug/headless_test.gd`：
  - 改既有 `_test_stable_produces_mounts` → 驗 `public_storage` 而非 `owner.resources`
  - 加 7 新測試（Task1/2/3×3/4×2）

## 與 spec 的差異

- spec Task 4 守衛條件列 `TeamData.TASK_PREPARE`，但 `TeamData` **無此 const**（task 清單只有 idle/攻擊/掠奪…）。
  改以 `current_task == TASK_IDLE` 為唯一不出征狀態。其餘所有 task（含攻擊/護衛/偵查/貿易等）都會 withdraw。
  **需主 session 確認**此語意是否符合「出征前」原意，或要改成白名單（僅軍事 task）。

## 連動風險

- `resource_system._collect_from_tile`：mounts 進 PUBLIC_RESOURCES 後，若某 tile.resources 帶 `"mounts"` key 會走公庫路徑。正常 tile 只有 `wild_horses`，無影響。
- `encounter` loot（`apply_mount_loot`）：戰利品仍進 `team.resources["mounts"]`，**無自動 deposit 回公庫**。維持 spec 行為。
- NPC 行為改變：stable 產馬不再直接進 team，team 需經 `_auto_withdraw_mounts` 才有 mount → 戰力時序略有延遲（withdraw 在 faction_ai tick）。
- 玩家 withdraw/deposit：走既有 public_storage 路徑，mount 自動支援（未改玩家碼）。

## 驗證結果

- `headless_test`：全部 MountStorage Task1/2/3/3b/3c/4a/4b **OK**；既有 Mount Task3b（stable）改後 **OK**
  - 唯一 assert 失敗為 **pre-existing**：`game_sim_test 應 5 team，實際=8`（與本功能無關，baseline 即失敗）
- `game_sim_test`：**ALL INVARIANTS PASSED (violations=0)**
  - `[FEATURE FAIL] Trade trade_success=0` 為 pre-existing，與 mount 無關
- `game_sim_multi`（4 configs × 21600 tick）：全數跑完無崩潰（died=no），無 SCRIPT ERROR / INVARIANT VIOLATION
  - log 觀察到 `auto-withdraw` ×1（該 run 無 outpost 鄰格野馬，故無「採野馬」）

| config | ticks | teams | persons | died |
|---|---|---|---|---|
| game_sim_test | 21600 | 8 | 20 | no |
| tyrant | 21600 | 8 | 11 | no |
| merchant | 21600 | 9 | 10 | no |
| warzone | 21600 | 11 | 13 | no |

## 待主 session 確認

- `MOUNT_TARGET_RATIO = 0.5` 是否合理
- mount cap `10/30/80` 是否合理
- 出征守衛：用 `!= idle` 還是改軍事 task 白名單（見上「與 spec 的差異」）
- loot 戰利品仍 `team.resources`（無自動 deposit 公庫）是否要補
