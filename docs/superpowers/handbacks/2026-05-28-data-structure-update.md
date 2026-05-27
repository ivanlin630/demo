# Hand Back: 資料結構更新

## 實作摘要

- `scripts/data/person_data.gd` — 加入 salary/coin/relations；equipment 遷移為 8 格 dict；goals 呼叫方改為 dict 格式
- `scripts/data/team_data.gd` — 加入 named_members（取代 advisors+members）、anon_wage、fatigue、guard_ratio、armor_config、known_reputations、strategic_assignments；resources 加入 mounts/wagons/arrows/medicine/tools/armor_low/armor_high；移除 advisors/members
- `scripts/data/world_state.gd` — 加入 player_id、player_state、ticks_per_day
- `scripts/simulation/vision_system.gd` — 遷移 named_members
- `scripts/simulation/skill_system.gd` — 遷移 named_members
- `scripts/simulation/manufacturing_system.gd` — 遷移 named_members
- `scripts/simulation/movement_system.gd` — 遷移 named_members
- `scripts/simulation/person_generator.gd` — 遷移 named_members
- `scripts/simulation/equipment_system.gd` — 遷移 named_members
- `scripts/simulation/interaction_system.gd` — 遷移 named_members（14 處）
- `scripts/simulation/event_system.gd` — 遷移 named_members
- `scripts/simulation/population_system.gd` — 遷移 named_members
- `scripts/simulation/events/event_unrest_replace.gd` — 遷移 named_members；舊 leader role 改為 "member"
- `scripts/simulation/events/event_unrest_split.gd` — 遷移 named_members
- `scripts/simulation/faction_ai_system.gd` — 遷移 named_members（4 處）
- `scripts/simulation/subteam_system.gd` — 遷移 named_members（11 處）
- `scripts/simulation/reaction_system.gd` — goals 字串比對改為 dict 型別（_has_goal_type helper）
- `scripts/debug/headless_test.gd` — 全面遷移；加入所有新欄位驗證
- `scripts/debug/data_test.gd` — 遷移 named_members

與 spec 無差異。

## 連動風險

- `reaction_system.gd`：goals 字串 mapping 新增了 helper `_has_goal_type()`，若其他系統直接 `goals.has("string")` 仍會靜默失敗（但 grep 確認已無殘留）
- `event_unrest_replace.gd`：舊 leader 現在以 `role = "member"` 存入 named_members，原本是 `role = "advisor"`；若其他地方用 `role == "advisor"` 篩人需注意
- `subteam_system.gd`：子隊的 `sub.advisors` 全部改為 `sub.named_members`，SubteamData 若有獨立 advisors 欄位請確認已移除

## 待主 session 確認

- `event_unrest_replace.gd` 的 role 從 "advisor" 改為 "member"——是否影響其他顯示或邏輯？
- `salary_system.gd`（尚未實作）讀取 `person.salary` 時可直接使用新欄位
- 下一步建議從 `2026-05-27-team-ai-redesign.md` 開新 worktree 實作
