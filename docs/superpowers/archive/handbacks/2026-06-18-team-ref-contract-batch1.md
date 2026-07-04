# Hand Back: Team Ref 契約 批次1（立基 + 形態 A）

## 實作摘要

| 檔案 | 改動 |
|---|---|
| `scripts/data/world_state.gd` | 加 `require_team(tid) -> TeamData`（接 `erase_team` 後）：非 -1 須存在，不存在則 assert（debug 抓、release 剝離）。 |
| `scripts/debug/headless_test.gd` | 加 `_test_require_team` + 註冊於 `_initialize`。 |
| `docs/invariants.md` | 加「team reference 契約」節（納管 vs 不納管、解析統一形狀、erase_team chokepoint）。 |
| `scripts/simulation/faction_ai_system.gd` | `_check_food_shortage` / `_check_goods_shortage` / `_check_mount_demand` / `_assign_member_tasks`：`for tid in faction.member_team_ids` 迭代內純 dangling `teams.get()+null` → `require_team`。 |
| `scripts/simulation/player_api_mapper.gd` | `get_faction_info`：`for mid in f.member_team_ids` 迭代純 dangling → `require_team`。 |

**轉換站：只動 `member_team_ids` 迭代（Task 3）。** Task 4（單 ref 站）全數**未轉換**（見下）。

## 與 spec 的差異（重要）

**Task 4 全部站留批次 2。** 計畫前提「`-1` 先檢後的單 ref 站為純 dangling、分支不可達、行為等價」**經測試證偽**：

1. **`order_target_id`（escort：`faction_ai._update_escort` / `movement_system.process`）**
   轉 `require_team` 後 headless 噴 `require_team: Team20 不存在` 連續多 tick。
   `_check_no_dangling_team_id` **有**審 `order_target_id`，但 multi audit=0 的原因是 **escort 自癒（`if target == null: release + order_target_id = -1`）每 tick 在 audit 前就把懸空清掉**。自癒區塊是 load-bearing，非死碼。→ 形態 B。

2. **`parent_team_id`（`faction_ai` merge_queue 迴圈 / `_evaluate_idle_subteam` / `subteam_system.try_merge_back`）**
   轉 `require_team` 後同樣噴 `Team20 不存在`。
   **根因：`_check_no_dangling_team_id` 根本沒審 `parent_team_id`**（只審 `combat_target` / `order_target_id` / `known_reputations` / `strategic_assignments` / `team_discovered`）。所以懸空 `parent_team_id` 在模擬中**未被偵測地存在**，舊 `if parent == null` 守衛一直默默吞掉（pre-existing latent bug）。
   `erase_team` 孤兒化子隊靠 `subteam_ids` 雙向正確；一旦 desync，孤兒化漏掉 → 懸空 `parent_team_id`。→ 形態 B。

依計畫自身逃生規則「不能保證非 dangling → 留批次 2」，Task 4 全站回退原狀。

## 驗證

- `headless_test.gd`：`=== DONE ===`、`[OK] _test_require_team`、無 `SCRIPT ERROR`。
- `game_sim_multi.gd`：4 情境（game_sim_test / tyrant / merchant / warzone）違反取樣總計=0、coin_eq delta=0、無 `SCRIPT ERROR`、無 require_team assert。
- Task 3 轉換行為等價（`member_team_ids` 由 `erase_team:134 f.member_team_ids.erase(tid)` 直接維護 + faction 雙向 audit；multi 全綠證實不懸空）。
- `invariant_audit.gd` 偵測器全程未動。

## 連動風險

- `member_team_ids` 轉換站：若未來新增「迭代中 erase faction 成員」的路徑（如 Task 3 :466 背叛檢查已是此類，故**未轉**，保留 `.duplicate()` 快照 + null 守衛），須走快照不可轉 require_team。已於 invariants「不納管」節載明。
- 無其他已知連動。

## 待主 session 確認

1. **audit 缺口（建議優先）**：`_check_no_dangling_team_id` 未審 `parent_team_id`。建議補一條 `_check_*`（會把現存懸空 `parent_team_id` 暴露成 violation → 須先修產生懸空的根因，否則 multi 轉紅）。這是 `parent_team_id` 能默默懸空的結構成因。
2. **批次 2（形態 B）**：`order_target_id`（escort×2）、`parent_team_id`（×3）逐站拆 `-1`／dangling。前提是先補 audit + 修懸空根因，否則只是把自癒換成 assert。
3. **懸空 `parent_team_id` 根因**：查 `erase_team` 孤兒化 vs `subteam_ids` 雙向是否會 desync（Team20 案例）。
