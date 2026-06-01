# Hand Back: Team AI 重構

## 實作摘要

- `scripts/simulation/subteam_system.gd` — 新增 `_pick_subteam_leader`，依 task→skill 映射選最高技能者
- `scripts/simulation/faction_ai_system.gd` — 徵收 dispatch 改用 `_pick_subteam_leader`，fallback `named_members[0]`
- `scripts/simulation/salary_system.gd` — 新建 `SalarySystem`；每 30 tick 結算薪水，overpay/underpay 影響 loyalty；anon_wage 付匿民；coin 不足 → unrest_turns+1
- `scripts/simulation/sim_runner.gd` — 整合 `SalarySystem`（`_step6c_salary`）；新增疲勞常數與 `_step6d_fatigue`（每 tick 累積/回復疲勞，疲勞滿 → loyalty 懲罰）
- `scripts/simulation/movement_system.gd` — 疲勞速度懲罰；新增 `get_carry_capacity`/`calc_total_weight`/`_resource_weight`/`get_effective_mounts|wagons`/`_tick_stray_mounts`；超載速度懲罰；車輛地形懲罰；`calc_total_weight` 資源值 clamp 到 0（防負幣影響重量）
- `scripts/simulation/events/event_unrest_split.gd` — 新增 `reset_loyalty_on_transfer`（6 種轉隊場景）；`_has_goal_conflict` 加 `active` 篩選；`_split_team` 全面重寫，新增 split_leader/split_hard/split_soft/匿名跟隨者邏輯（依統領×魅力）
- `scripts/simulation/interaction_system.gd` — `_end_combat` 戰後 loot 後全 named_members loyalty 懲罰（依義氣）；新增 `execute_prisoner` 公開函數（目擊者 loyalty 懲罰）
- `scripts/debug/headless_test.gd` — 補充 Task 1–6 驗證 print/assert

與 spec 差異：
- `calc_total_weight` 加了 `maxf(..., 0.0)` clamp（spec 未提，但 coin 負值會使重量變負，bug fix）
- `execute_prisoner` 為 stub 公開函數（spec 說「找到處決俘虜邏輯」但原系統無此流程，故新建空接口）

## 連動風險

- `ResourceSystem` / `ReactionSystem`：sim_runner step 順序改變（salary 插在 consumption 後、faction_ai 前），可能影響當 tick 資源狀態讀取時序
- `FactionAISystem._assign_tasks`：徵收 dispatch 現在選技能最高者，若 named_members 全無「統領」技能（0.0），fallback `named_members[0]`；edge case：named_members 為空時 fallback 會 index error → 但原本就有 `named_members.size() > 0` 保護，無新風險
- `EventSystem` / `event_unrest_split.gd`：`_split_team` 現在直接操作 `parent.named_members`（erase），若 dissenters 與 named_members 不一致（人已死/已離隊）可能 erase 無效（安全，不會 crash）；split 後 parent.population 可能降到 0（極端情況）
- `SalarySystem`：far zone 每 FAR_ZONE_INTERVAL=10 tick 才跑一次，薪水結算頻率對遠區 team 較低（非 bug，LOD 設計）
- `MovementSystem._tick_stray_mounts`：每 tick 對所有 moving team 執行，若 mounts 資源大量，可能有輕微效能影響（TEST VALUE STRAY_RATE=0.1，實際影響小）

## 待主 session 確認

- **`execute_prisoner` 接入點**：目前為公開函數 stub，無系統主動呼叫。主 session 需決定何時（哪個 event）觸發處決，並在該處呼叫 `InteractionSystem.new().execute_prisoner(state, team_id)`
- **負幣重量 clamp**：coin 可能長期為負（薪水系統消耗）。建議考慮是否需要 coin 下限（如 0），或明確接受「欠薪」語意
- **疲勞 FATIGUE_PER_TICK=0.002**：200 tick 後 Team0（掠奪任務）fatigue=0.4，屬合理範圍；但尚未驗證 1000 tick 長跑行為（疲勞會飽和在 1.0，loyalty penalty 持續累積）
- **所有 TEST VALUE 常數**：SALARY_INTERVAL=30、SALARY_PER_SKILL_POINT=2.0、FATIGUE_PER_TICK=0.002 等均為測試值，正式調整見 `docs/progress.md` 或主 session 指示
