# 開發進度

## 已完成

### 資料結構層（`scripts/data/`）

| 檔案 | 內容 |
|---|---|
| `person_data.gd` | id, name, role, team_id, age, needs, stress, fear, loyalty, goals, attributes(4), skills(12), values(5), memory |
| `team_data.gd` | team_id, leader_id, advisors, members, population(上限50/最小1), minor_population(cap=pop×20%), resources, move_speed, tags, current_task, unrest_turns, faction_id, tile_pos, combat_target, readiness, wounded |
| `tile_data.gd` | tile_id, resources(food/wood/ore/special), productivity, occupied_by, has_outpost |
| `world_data.gd` | tiles dict, current_tick, current_turn |
| `world_state.gd` | world, teams, persons, global_messages, team_known |
| `message_data.gd` | id, type, description, source_pos, origin_team_id, origin_tick, strength, is_distorted |

### 模擬系統層（`scripts/simulation/`）

| 檔案 | 內容 |
|---|---|
| `sim_runner.gd` | Tick 循環 9 步驟；LOD：近區每 Tick，遠區每 10 Tick（跳過人物反應） |
| `resource_system.gd` | 資源收集（has_outpost → food_gain）；消耗結算（0.1/人/Tick）；needs/stress/fear 更新 |
| `reaction_system.gd` | 10 種反應（P1–P5、N1–N5）；skills/values/goals 整合進效用函數；目標自動生成（每 10 Tick） |
| `skill_system.gd` | on_reaction 技能成長；速率 = BASE_GROWTH × attr × (0.5 + 毅力 × 0.5) |
| `event_system.gd` | Registry 架構；process_events loop；on_leader_death（外部呼叫） |
| `events/base_event.gd` | BaseEvent 基底：check() + execute() |
| `events/event_unrest_split.gd` | 分裂：unrest≥30、義氣<0.4、目標衝突 |
| `events/event_unrest_replace.gd` | 替換：unrest≥20、統領≥0.3 |
| `message_system.gd` | emit_message（事件觸發）；propagate_on_arrival（同格 event-driven）；4 種傳播模式（honest/unintentional/malicious/silent）；去重+衰減 |

### 測試

| 檔案 | 內容 |
|---|---|
| `scripts/debug/headless_test.gd` | 200 Tick headless 模擬；驗證資源/壓力/反應/技能成長/事件/移動/戰鬥 |
| `scripts/simulation/movement_system.gd` | greedy hex step；速度公式；_on_arrival 只更新 occupied_by；交戰中禁止移動 |
| `scripts/simulation/interaction_system.gd` | current_task 驅動互動；多回合拉鋸戰；整備值/傷兵/醫療；勒索分支；撤退機制 |

### 文件

| 檔案 | 狀態 |
|---|---|
| `docs/person.md` | 完整記錄四層決策模型、技能成長、慎重設計契約 |
| `docs/team.md` | 完整記錄欄位、人口規則、unrest 門檻 |
| `docs/world.md` | 完整記錄 Tick 循環、LOD、資源系統、資料結構 |
| `docs/event.md` | 完整記錄 registry 架構、現有事件邏輯 |
| `docs/message.md` | 完整記錄三層架構、衰減公式、4 種傳播模式、event-driven 流程 |
| `docs/superpowers/specs/2026-05-22-world-simulator-design.md` | 設計規格 |

---

## 待完成

### 高優先

| 項目 | 說明 | 前置需求 |
|---|---|---|
| ~~**Team 移動**~~ | ~~tile_pos 實際改變；移動 AI（目標格、行軍）；速度公式~~ | ~~無~~ |
| ~~**訊息傳播**~~ | ~~同格 event-driven propagate_on_arrival；4 種失真模式；去重衰減~~ | ~~✅ Team 移動 完成~~ |

### 中優先

| 項目 | 說明 | 前置需求 |
|---|---|---|
| ~~**Team 間互動**~~ | ~~戰鬥（多回合）/ 勒索 / 撤退；貿易外交設計預留~~ | ~~✅ Team 移動 完成~~ |
| **Faction 系統** | faction_id 啟用；勢力結構、支配關係 | Team 間互動 |
| **世界生成** | 隨機 tile 分佈與資源（目前 headless_test 硬編碼） | 無 |

### 低優先（玩家系統預留）

| 項目 | 說明 |
|---|---|
| 玩家角色 | 作為世界中一個人，step7 預留介面 |
| UI / 渲染 | 大地圖顯示、勢力標記、訊息日誌 |
| 遭遇戰地圖 | Team 成員展開至各格，全精度模擬 |
