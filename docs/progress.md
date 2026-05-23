# 開發進度

## 已完成

### 資料結構層（`scripts/data/`）

| 檔案 | 內容 |
|---|---|
| `person_data.gd` | id, name, role, team_id, age, needs, stress, fear, loyalty, goals, attributes(4), skills(12), values(8：野心/求生欲/義氣/貪婪/慎重/好戰/殘忍/信義), memory, body_parts(6部位/status), STATUS_MULT, get_effective_speed, get_skill_mult, get_attribute_mult |
| `team_data.gd` | team_id, leader_id, advisors, members, population(上限50/最小1), minor_population(cap=pop×20%), resources, move_speed, tags, current_task, unrest_turns, faction_id, tile_pos, combat_target, readiness, wounded；TAG_* 常數（7種）；TASK_* 常數（13種含4預留）；pop_cap_from_leadership |
| `tile_data.gd` | tile_id, resources(food/wood/ore/special), productivity, occupied_by, has_outpost |
| `world_data.gd` | tiles dict, current_tick, current_turn |
| `world_state.gd` | world, teams, persons, global_messages, team_known, factions, create_faction(), disband_faction() |
| `faction_data.gd` | faction_id, faction_name, is_established, leader_team_id, member_team_ids, tribute_rate, goals, strategy, relations |
| `message_data.gd` | id, type, description, source_pos, origin_team_id, origin_tick, strength, is_distorted |

### 模擬系統層（`scripts/simulation/`）

| 檔案 | 內容 |
|---|---|
| `sim_runner.gd` | Tick 循環 9 步驟；LOD：近區每 Tick，遠區每 10 Tick（跳過人物反應） |
| `resource_system.gd` | 資源收集（has_outpost → food_gain）；消耗結算（0.1/人/Tick）；needs/stress/fear 更新 |
| `reaction_system.gd` | 10 種反應（P1–P5、N1–N5）；skills/values/goals 整合進效用函數；目標自動生成（每 10 Tick） |
| `skill_system.gd` | on_reaction 技能成長；速率 = BASE_GROWTH × attr × (0.5 + 毅力 × 0.5)；body_part 損傷修正 |
| `interaction_system.gd` | 接觸結算：戰鬥（多回合）/ 勒索 / 撤退；body part 命中；_try_subjugate / _try_diplomacy / _resolve_tribute |
| `movement_system.gd` | tile_pos 移動；_compute_team_speed 加權均速（body part 狀態） |
| `event_system.gd` | Registry 架構；process_events loop；on_leader_death（外部呼叫）；失敗→disband_faction |
| `events/base_event.gd` | BaseEvent 基底：check() + execute() |
| `events/event_unrest_split.gd` | 分裂：unrest≥30、義氣<0.4、目標衝突 |
| `events/event_unrest_replace.gd` | 替換：unrest≥20、統領≥0.3 |
| `events/event_faction_defect.gd` | 脫離：faction≠-1 + unrest≥20 + 義氣<0.35 |
| `events/event_tag_shift.gd` | tag 增減：leader 好戰/野心 → +軍隊；戰損 > 50% → +流亡；資源穩定 → -流亡 |
| `faction_ai_system.gd` | 策略層：evaluate_all → goals/strategy → current_task/move_target；leader values 整合（野心/貪婪/求生欲/好戰/義氣）；成員 team task 指派（_assign_member_tasks）；獨立 team SoloAI（_evaluate_solo）；_tag_weight tag 權限過濾 |
| `message_system.gd` | emit_message（事件觸發）；propagate_on_arrival（同格 event-driven）；4 種傳播模式（honest/unintentional/malicious/silent）；去重+衰減 |

### 測試

| 檔案 | 內容 |
|---|---|
| `scripts/debug/headless_test.gd` | 200 Tick headless 模擬；驗證資源/壓力/反應/技能成長/事件/移動/戰鬥/faction立國/脫離/子團派遣/SoloAI/tag 增減 |

### 文件

| 檔案 | 狀態 |
|---|---|
| `docs/person.md` | 完整記錄四層決策模型、技能成長、慎重設計契約、部位健康系統 |
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
| ~~**個人健康系統**~~ | ~~6 部位 status；技能/速度比例修正；critical 瀕死判定；team 速度均速計算~~ | ~~✅ Team 間互動 完成~~ |
| ~~**Faction 系統**~~ | ~~立國/外交/徵收三路徑 headless 驗證完成；主服路徑（_force_retreat→_try_subjugate）代碼已加，測試場景未覆蓋~~ | ~~✅ 個人健康系統 完成~~ |
| ~~**世界生成**~~ | ~~WorldGenerator hex 地圖（radius 可配）；地形三型；資源 key 命名規範統一~~ | ~~無~~ |
| ~~**子團派遣與合併**~~ | ~~dispatch/merge/護衛/信使；動態人口上限（統領技能）；統領 >0.8 加成（readiness/戰力）；faction AI 距離派遣；leader 死亡溢出分團~~ | ~~✅ Faction 系統 完成~~ |
| ~~**Task/AI 整合 + 價值觀擴充**~~ | ~~values 擴充（好戰/殘忍/信義）；TAG 系統（7種 + task 權限表）；FactionAI values 整合 + 成員 task 指派；SoloTeamAI（獨立 team 自主）；ReactionSystem 逃跑橋接；EventTagShift~~ | ~~✅ 子團派遣完成~~ |

### 低優先（玩家系統預留）

| 項目 | 說明 |
|---|---|
| 玩家角色 | 作為世界中一個人，step7 預留介面 |
| UI / 渲染 | 大地圖顯示、勢力標記、訊息日誌 |
| 遭遇戰地圖 | Team 成員展開至各格，全精度模擬 |
