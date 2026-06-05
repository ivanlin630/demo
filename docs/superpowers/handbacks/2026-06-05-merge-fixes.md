# Hand Back: Merge System Fixes

## 實作摘要

- `scripts/simulation/interaction_system.gd` — `_try_merge`：修正 `merge_teams` 參數順序。原本小隊（merger）誤作 absorber，大隊（target）誤作 absorbed，導致大隊可能被清空刪除。現改為 `merge_teams(state, target_id, merger_id, merger_npcs)`，大隊吸收小隊，all_npcs 取自小隊
- `scripts/simulation/subteam_system.gd` — `_merge_into` 及 named-transfer 路徑：`absorbed.population <= 0` 清理區塊新增 `state.team_discovered.erase()` 及 faction `member_team_ids`/`known_member_states` 清理。兩條路徑（named-transfer ~L138 與 `_merge_into` ~L205）現已對稱
- `scripts/debug/headless_test.gd` — 新增 throwaway team 測試，驗證 `_merge_into` 後 `state.teams`、`state.team_known`、`state.team_discovered` 清理正確

## 超出 spec 的修正

原 spec 只指定修 `_merge_into`，但 code review 發現 `merge_teams` 的 named-transfer 路徑（merger 有 leader/named members 時走此路徑）同樣缺少清理，且此路徑比 `_merge_into` 更常被執行。已同步補齊，commit `d0ce8da`。

## 連動風險

- `_try_merge` 修正後，小隊現在會被正確吸收（人口歸零）並從 state 刪除。若有任何系統持有小隊的 `team_id` 引用（例如 `f.member_team_ids`），將在 cleanup block 中一併清除。
- `_try_merge` 的 `merger.current_task = TASK_IDLE` 在 merger 被刪除後仍寫入（GDScript object ref 存活），不影響正確性。

## 待主 session 確認

- 無
