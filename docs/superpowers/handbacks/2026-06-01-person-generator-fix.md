# Hand Back: Person Generator API Migration

## 實作摘要
- `scripts/debug/headless_test.gd`：先補測試，驗證 EventSystem 與 PopulationSystem 走新生成人口路徑；覆蓋匿名人口 guard、team_id/state.persons 寫回、流亡隊 leader 指派，並新增 deterministic helper 驗證。
- `scripts/simulation/person_generator.gd`：提取共用 `generate_for_team()` helper，集中 anon-pop guard、deterministic seed、team_id/state.persons 寫回；移除舊 compat shim。
- `scripts/simulation/event_system.gd`：改用 `PersonGenerator.generate_for_team()`，不再重複匿名人口生成邏輯。
- `scripts/simulation/population_system.gd`：改用同一 helper，流亡隊 leader 指派維持可用。
- 與 spec 的差異：無。

## 連動風險
- 無已知連動風險。

## 待主 session 確認
- commit 粒度最初偏大；本次 follow-up 以追加 commit 修正 DRY/RNG，未重寫已 push 歷史。
