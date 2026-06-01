# Hand Back: Person Generator API Migration

## 實作摘要
- `scripts/debug/headless_test.gd`：先補測試，驗證 EventSystem 與 PopulationSystem 走新 static API 路徑；覆蓋匿名人口 guard、team_id/state.persons 寫回、流亡隊 leader 指派。
- `scripts/simulation/event_system.gd`：移除 `generate_from_team()` 呼叫，改用 `PersonGenerator.generate(state, rng.randi(), "member")`，並保留匿名人口不足時不生成的 guard。
- `scripts/simulation/population_system.gd`：移除 `generate_from_team()` 呼叫，改用同一 static API；新生成 leader 仍寫回 `state.persons`、`team_id` 正確、流亡隊 leader 指派維持可用。
- 與 spec 的差異：無。

## 連動風險
- 無已知連動風險。

## 待主 session 確認
- 無。
