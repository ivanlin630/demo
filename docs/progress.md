# 開發進度

## 已完成

### 資料結構層（`scripts/data/`）

| 檔案 | 內容 |
|---|---|
| `person_data.gd` | id, name, role, team_id, age, needs, stress, fear, loyalty, goals, attributes(4), skills(14：+偵查/潛行), values(8：野心/求生欲/義氣/貪婪/慎重/好戰/殘忍/信義), memory, body_parts(6部位/status), equipment(weapon槽), STATUS_MULT, get_effective_speed, get_skill_mult, get_attribute_mult |
| `team_data.gd` | team_id, leader_id, advisors, members, population(上限50/最小1), minor_population(cap=pop×20%), resources(food/material/coin/goods/gem/ore_gold/ore_silver/ore_iron/ore_steel/weapon_melee_low/weapon_melee_high/weapon_ranged_low/weapon_ranged_high), move_speed, equip_order, armed_anon_ratio, tags, current_task, unrest_turns, faction_id, tile_pos, combat_target, readiness, wounded；TAG_* 常數（7種）；TASK_* 常數（13種含4預留）；pop_cap_from_leadership |
| `tile_data.gd` | tile_id, resources(food/wood/ore/special), productivity, occupied_by, has_outpost |
| `world_data.gd` | tiles dict, current_tick, current_turn |
| `world_state.gd` | world, teams, persons, global_messages, team_known, team_discovered, factions, create_faction(), disband_faction() |
| `faction_data.gd` | faction_id, faction_name, is_established, leader_team_id, member_team_ids, tribute_rate, goals, strategy, relations |
| `message_data.gd` | id, type, description, source_pos, origin_team_id, origin_tick, strength, is_distorted |

### 模擬系統層（`scripts/simulation/`）

| 檔案 | 內容 |
|---|---|
| `sim_runner.gd` | Tick 循環（含 step1b 視野/step1c 裝備）；LOD：近區每 Tick，遠區每 10 Tick（跳過人物反應） |
| `resource_system.gd` | 資源收集（has_outpost → food_gain）；消耗結算（0.1/人/Tick）；needs/stress/fear 更新 |
| `outpost_system.gd` | 據點建立/拆除；佔領 tile has_outpost；food_gain 由 productivity 決定 |
| `harvest_system.gd` | 主動採集：team 到資源格採收 tile.resources；補充 team resources |
| `manufacturing_system.gd` | 製造系統：6 種配方優先序（工藝品 > 高階武器(steel) > 冶煉 > 低階武器(iron) > 一般製造）；ore_iron 從世界採集，ore_steel 靠冶煉 |
| `reaction_system.gd` | 10 種反應（P1–P5、N1–N5）；skills/values/goals 整合進效用函數；目標自動生成（每 10 Tick） |
| `skill_system.gd` | on_reaction 技能成長；on_combat_round（melee → 戰鬥）；on_volley（ranged → 弓箭）；on_combat_end（leader → 戰術）；速率 = BASE_GROWTH × attr × (0.5 + 毅力 × 0.5)；body_part 損傷修正 |
| `equipment_system.gd` | 記名 NPC 武器槽分配（依 equip_order）；armed_anon_ratio 計算；死亡武器歸還（named：50%機率回2單位；anon：比例回收）；UNITS_PER_EQUIP=2 |
| `vision_system.gd` | 迷霧系統：scout_range（偵查技能加成）；exposure（人口+潛行技能+地形）；dist_factor 邊緣衰減；team_discovered 雙向追蹤；偵查/潛行技能成長 |
| `interaction_system.gd` | 接觸結算：Round 0 齊射（_resolve_volley）→ 多回合戰鬥；地形防禦加成（forest×1.2/mountain×1.15）；flanking（3倍人數×1.3）；morale cascade（傷亡>30%→readiness ×2 消耗）；pursuit（勝方≥2倍→extra casualties）；loot 4種武器類型；body part 命中；_try_subjugate / _try_diplomacy / _try_merge / _resolve_tribute；貿易（12種資源 BASE_PRICE） |
| `movement_system.gd` | tile_pos 移動；_compute_team_speed 加權均速（body part 狀態） |
| `event_system.gd` | Registry 架構；process_events loop；on_leader_death（外部呼叫）；無繼承人→PersonGenerator fallback；失敗→disband_faction |
| `person_generator.gd` | PersonGenerator：anon_pop 檢查；隨機屬性(0.2–0.8)/values(0.2–0.8)/技能(0.0–0.2)；tag 偏移（6種 tag → 屬性/技能偏移 clamp）；id 從 state.persons.max()+1 派發 |
| `events/base_event.gd` | BaseEvent 基底：check() + execute() |
| `events/event_unrest_split.gd` | 分裂：unrest≥30、義氣<0.4、目標衝突 |
| `events/event_unrest_replace.gd` | 替換：unrest≥20、統領≥0.3 |
| `events/event_faction_defect.gd` | 脫離：faction≠-1 + unrest≥20 + 義氣<0.35 |
| `events/event_tag_shift.gd` | tag 增減：leader 好戰/野心 → +軍隊；戰損 > 50% → +流亡；資源穩定 → -流亡 |
| `faction_ai_system.gd` | 策略層：evaluate_all → goals/strategy → current_task/move_target；leader values 整合；成員 task 指派；獨立 team SoloAI；_tag_weight tag 權限過濾；_update_equip_order（軍隊→near戰；商隊→ranged保護）；discovered-only 目標選擇；義氣→低徵收頻率；貪婪→掠奪 goal；子團偏離 + idle mini-loop |
| `message_system.gd` | emit_message（事件觸發）；propagate_on_arrival（同格 event-driven）；4 種傳播模式（honest/unintentional/malicious/silent）；去重+衰減 |
| `world_generator.gd` | hex 地圖生成；地形三型；ore_iron 分布（mountain 30%/plains 5%） |
| `population_system.gd` | 超額強制分裂：每 10 tick 掃全域；有 advisor → dispatch 子隊；無 advisor → 獨立流亡 team + PersonGenerator 晉升 |
| `faction_ai_system.gd`（快照層） | `known_member_states` 介面：FactionAI 讀成員快照（food/weapons/goods/population/tile_pos/current_task）；stub 已由 IntelSystem bridge 取代（evaluate_all 從 team_intel 複製） |
| `intel_system`（IntelSystem） | **情報系統**：`world_state.gd` 新增 `team_intel` Dictionary；`vision_system.gd` `tick_discovery` 寫 Tier 0/1 快照（population_est/resource_scale 含距離雜訊）；`interaction_system.gd` `reveal_encounter` / `_write_tier2_intel` 寫 Tier 2 完整快照（造假機制：偽裝平民/虛張聲勢）；FactionAI bridge：`evaluate_all` 從 team_intel 複製至 known_member_states；`_find_trade_target` 讀 coin_est；`_update_goals` 攻擊決策讀 armed_est（未知=999視為強敵）；`_calc_own_armed` helper |

### 測試

| 檔案 | 內容 |
|---|---|
| `scripts/debug/headless_test.gd` | 200 Tick headless 模擬；驗證資源/壓力/反應/技能成長/事件/移動/戰鬥/faction立國/脫離/子團派遣/SoloAI/tag 增減/PersonGenerator/merge_teams |

### 文件

| 檔案 | 狀態 |
|---|---|
| `docs/person.md` | 四層決策模型、技能成長（14技能含偵查/潛行）、裝備欄、慎重設計契約、部位健康系統 |
| `docs/team.md` | 欄位（含 equip_order/armed_anon_ratio/4武器資源）、人口規則、unrest 門檻 |
| `docs/world.md` | Tick 循環、LOD、資源系統、資料結構、迷霧系統 |
| `docs/event.md` | registry 架構、現有事件邏輯 |
| `docs/message.md` | 三層架構、衰減公式、4 種傳播模式、event-driven 流程 |
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
| ~~**好戰/殘忍/信義 效果實裝**~~ | ~~好戰→攻擊決策加權；殘忍→loot rate/傷兵惡化/暴動勒索傾向；信義→外交接受率/徵收率/叛離條件~~ | ~~✅ Task/AI 整合完成~~ |
| ~~**子團自主 AI + 護衛跟隨**~~ | ~~整合於 FactionAI；parent_team_id != -1 優先；護衛任務每 tick 更新 move_target；到達自動 try_merge_back；紀律失效脫離~~ | ~~✅ 好戰/殘忍/信義完成~~ |
| ~~**採集/據點系統**~~ | ~~OutpostSystem（佔領建立 has_outpost）；HarvestSystem（主動採集 tile 資源）；ResourceSystem 整合~~ | ~~✅ 世界生成完成~~ |
| ~~**製造系統**~~ | ~~6 種配方；ore_iron 世界資源（mountain 30%/plains 5%）；ore_steel 靠冶煉；4 種武器類型生產~~ | ~~✅ 採集/據點完成~~ |
| ~~**迷霧系統（VisionSystem）**~~ | ~~scout_range（偵查）+ exposure（潛行）；team_discovered；地形乘數；偵查/潛行技能成長~~ | ~~✅ 世界生成完成~~ |
| ~~**武器/戰鬥強化**~~ | ~~4 種武器類型；EquipmentSystem（個人裝備槽 + armed_anon_ratio）；Round 0 齊射；地形防禦；flanking；morale cascade；pursuit；SkillSystem 戰鬥/弓箭/戰術成長~~ | ~~✅ 製造系統完成~~ |
| ~~**FactionAI 義氣/貪婪效果**~~ | ~~義氣高 → 徵收週期延長/緊急門檻降低；貪婪高 → 勢力 AI 加入掠奪 goal~~ | ~~✅ 武器/戰鬥強化完成~~ |
| ~~**子團自主 AI 強化**~~ | ~~偏離掠奪（貪婪×低忠誠→DEVIATION_RATE）；idle mini-loop（貪婪/好戰 weighted 決策）~~ | ~~✅ FactionAI 完成~~ |
| ~~**PersonGenerator**~~ | ~~leader 死亡且無合格記名繼承人時，從匿名人口晉升新 leader（tag 屬性/技能偏移）~~ | ~~✅ 子團自主 AI 強化完成~~ |
| ~~**Team 合併**~~ | ~~`merge_teams(transfer_npc_ids, transfer_anon)`；部分合併→idle子隊；TASK_MERGE + `_try_merge`；idle auto-merge 更新；transfer_anon=-1比例/0不帶/N指定~~ | ~~✅ PersonGenerator 完成~~ |

### 低優先（玩家系統預留）

| 項目 | 說明 |
|---|---|
| 玩家角色 | 作為世界中一個人，step7 預留介面 |
| UI / 渲染 | 大地圖顯示、勢力標記、訊息日誌 |
| 遭遇戰地圖 | Team 成員展開至各格，全精度模擬 |
| ~~**超額人口強制離開 + 小隊合併整合**~~ | ~~PopulationSystem overflow split（每 10 tick）；FactionAI 閾值合併（pop < cap×0.3）；戰前集結（dist 2–3 先合併）~~ |
| PersonGenerator 其他 call site | 玩家招募、天賦事件 |
