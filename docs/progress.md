# 開發進度

## 已完成

### 資料結構層（`scripts/data/`）

| 檔案 | 內容 |
|---|---|
| `person_data.gd` | id, name, role, team_id, age, needs, stress, fear, loyalty, salary, coin, goals, attributes(4：智力/體力/毅力/魅力), skills(14：統領/戰鬥/弓箭/求生/生產/製造/工程/醫療/戰術/計謀/交涉/商業/偵查/潛行), values(8：野心/求生欲/義氣/貪婪/慎重/好戰/殘忍/信義), memory, relations, body_parts(6部位/status), equipment(right_hand槽), get_effective_speed, get_skill_mult, get_attribute_mult |
| `team_data.gd` | team_id, leader_id, named_members（取代 advisors+members）, population, minor_population, resources(19種), move_speed, equip_order, armed_anon_ratio, tags, current_task, unrest_turns, faction_id, tile_pos, move_target, move_tick_acc, combat_target, readiness, wounded, guard_ratio, fatigue, strategic_assignments；TAG_* 常數（7種）；TASK_* 常數；pop_cap_from_leadership |
| `tile_data.gd`（HexTileData） | tile_id, terrain(plains/forest/mountain), resources, productivity, farming_level, harvest_factor, occupied_by, outpost_type/level/owner, manufacturing_level |
| `world_data.gd` | tiles dict, current_tick, current_turn, ticks_per_day(24) |
| `world_state.gd` | world, teams, persons, factions, team_known, team_discovered, team_intel, player_id, player_state, encounter_active/units/attacker_id/defender_id/pursuit_edge_offset, snapshot_faction_member(), create_faction(), disband_faction() |
| `faction_data.gd` | faction_id, faction_name, is_established, leader_team_id, member_team_ids, tribute_rate, goals(string), strategic_goals(dict), strategy, relations, known_member_states |
| `message_data.gd` | id, type, description, source_pos, origin_team_id, origin_tick, strength, is_distorted |

---

### 模擬系統層（`scripts/simulation/`）

| 檔案 | 內容 |
|---|---|
| `sim_runner.gd` | Tick 循環 14 步（含日夜乘數、遭遇戰暫停分支）；LOD：近區每 Tick，遠區每 FAR_ZONE_INTERVAL=10 Tick |
| `resource_system.gd` | 資源收集（outpost → food_gain）；消耗結算（0.1/人/Tick）；needs/stress/fear 更新；tile 再生 |
| `outpost_system.gd` | 據點建立/拆除；civilain/military 兩類；建設 ticks 進度 |
| `harvest_system.gd` | 主動採集：team 到資源格採收 tile.resources |
| `manufacturing_system.gd` | 6 種配方優先序（工藝品 > 高階武器 > 冶煉 > 低階武器 > 一般製造） |
| `reaction_system.gd` | 10 種反應（P1–P5、N1–N5）；skills/values/goals 整合效用函數；每 10 Tick 更新目標 + 呼叫 NpcAiSystem.check_goal_alignment 調整 loyalty；`on_attack_defeat` event（named loyalty / leader stress，依義氣/信義/慎重）|
| `skill_system.gd` | on_reaction / on_combat_round / on_volley / on_combat_end 技能成長；屬性乘數；部位損傷修正 |
| `equipment_system.gd` | 記名 NPC 武器槽分配；armed_anon_ratio 計算；死亡武器歸還 |
| `vision_system.gd` | 迷霧：scout_range（偵查）+ exposure（人口+潛行+地形）；dist_factor 衰減；team_discovered；Tier 0/1 intel 快照寫入；偵查/潛行技能成長 |
| `interaction_system.gd` | 接觸結算：齊射→多回合戰鬥；flanking/morale cascade/pursuit；loot；body part 命中；_try_subjugate / _try_diplomacy / _try_merge / _resolve_tribute；貿易；玩家遭遇戰觸發（同陣營豁免）；execute_prisoner；Tier 2 intel；夜間突襲判定 _check_night_raid（待接入）；`process_on_move`（取代 process_on_arrival，每 tick 移動 team 對全 team 掃同格 try_interact）|
| `movement_system.gd` | tile_pos 移動（`_step_team` 用 A* `_calc_next_step`，繞山）；weighted 均速 (NAMED_WEIGHT=3 + tier-aware anon speed)；time_mult（日夜）；fatigue/超載懲罰；wagon 地形懲罰；strategic_assignments 優先邏輯；移動時記 `last_tile_pos`；WORLD_SPEED_MULT=5 → 菁英 0.2 天/hex（平民 0.29 天/hex）；process 回傳 `{arrived, moved}`；stuck log 加 source（task + strategic_assignments）|
| `path_system.gd` | A* `find_path`（同-tick cache）；`eta_ticks`/`_team_speed_mult`；`observe_velocity`（限視野+距離雜訊）；`estimate_catch_up`（reachable/eta/reason，ETA cap=AI_ETA_LIMIT 1200 tick = 25 hex plains at WORLD_SPEED_MULT=5）|
| `event_system.gd` | Registry 架構；on_leader_death；PersonGenerator fallback |
| `person_generator.gd` | 從匿名人口晉升記名 NPC；tag 屬性/技能偏移 |
| `faction_ai_system.gd` | 策略層 evaluate_all；values 整合；成員 task 指派；SoloAI；tag 過濾；discovered-only 目標；`_find_*_target`（trade/prey/strong/aid）用 `PathSystem.estimate_catch_up`（reachable 過濾 + eta score）；每 20 Tick 外交評估；每 BETRAY_CHECK_INTERVAL 背叛評估；`_evaluate_prosperity_attack`（野心驅動征服 cadence 3 日，軍隊 tag 加倍 1.5 日，個性公式 attack_score / readiness threshold / find_prosperity_prey）；`_trigger_survival` Path 1 B 分支（遠 outpost + 殘忍/好戰 → 改 TASK_LOOT）；stuck 視為 idle 允許重評（_is_stuck → STUCK_TASKS）|
| `diplomatic_ai_system.gd` | _calc_diplomacy_score（5 因子）；try_proactive_diplomacy；handle_diplomacy_message（4 動作）；_form_alliance；_update_reputation；consider_betrayal；_execute_betrayal |
| `strategic_ai_system.gd` | 戰略目標更新（expand/defend/trade_net）；包圍指派；突圍指派；威脅評估（team_discovered，非全知）；in-map check（off-map target → nearest_valid_tile）；ENCIRCLE_DIST=1 / BREAKOUT_DIST=2 / BREAKOUT_NEAREST_THRESHOLD=3；trade_net handler（dispatch idle 商隊找有 goods/coin 鄰商隊）|
| `npc_ai_system.gd` | write_memory（修剪+relations+goals觸發）；generate_birth_goals（values 門檻）；check_goal_alignment（目標×任務 delta）；get_goal_task_override（待接入）；cleanup_goals（target 死後重定向） |
| `salary_system.gd` | 每 30 Tick 結算；fair_salary = skills × 2.0；超付 → loyalty 上升 + kindness 記憶；欠付 → loyalty 下降；anon wage 改用 `AnonTierSystem.total_wage()` |
| `anon_tier_system.gd` | 4 tier（平民/新兵/老兵/菁英）；TIER_STATS（combat/speed/base_wage）；PROMOTION_EXP_THRESHOLD + ×count；leader 戰術 cap 訓練上限；菁英需 weapon_melee_high；kill_random weighted；transfer_proportional；avg_speed/avg_combat_skill/total_wage computed |
| `training_system.gd` | TASK_TRAIN team 每 tick 為 tier 累積 exp（速率 = leader 戰術 × n）|
| `day_night_system.gd` | get_time_period（dawn/day/dusk/night）；get_speed_mult / get_fatigue_mult / get_vision_mult；get_camp_vision_range（guard_ratio 守夜） |
| `population_system.gd` | 超額強制分裂（每 10 Tick）；有 advisor → dispatch 子隊；無 advisor → 獨立流亡 + PersonGenerator 晉升 |
| `subteam_system.gd` | dispatch / try_merge_back / 護衛跟隨；動態人口上限；紀律失效脫離 |
| `message_system.gd` | emit_message；propagate_on_arrival；4 種失真模式；去重衰減 |
| `world_generator.gd` | hex 地圖（radius 可配）；地形三型；ore_iron 分布 |
| `player_api_mapper.gd` | pure static DTO mapping（map_player_summary / map_forced_interaction / map_inventory_state / **map_members_detail** / **map_team_stats** 等） |
| `player_query_api.gd` | snapshot 查詢組合（get_player_snapshot / get_team_details / get_location_context 等） |
| `player_command_api.gd` | 指令驗證+分派（dispatch / move_to / respond_to_forced / execute_action 等） |
| `sim_bridge.gd` (更新) | query_player / command_player facade；UI 與 WorldState 玩家欄位完全隔離 |
| `encounter_system.gd` | 六角遭遇戰：init_encounter / _spawn_team_units（含匿名）；進場位置（attacker/defender/pursuit）；裝備分配；箭矢系統；decide_action 戰術 AI；advance_round 戰鬥解算（範圍/近戰/撤退/逃跑）；俘虜判定；傳令兵退出（SubteamSystem stub 待接）；resolve_encounter_end 結算（含勝方 occupy outpost 三 path：屠/放棄/強佔，依 leader 個性 + 居民拒投靠 reputation 判定；anon kill 改 `AnonTierSystem.kill_random`；戰場存活 exp +5 + 勝方 +5）|

---

### 事件層（`scripts/simulation/events/`）

| 檔案 | 內容 |
|---|---|
| `base_event.gd` | check() + execute() 基底 |
| `event_unrest_split.gd` | 分裂：unrest≥30 + 義氣<0.4 + 目標衝突；reset_loyalty_on_transfer |
| `event_unrest_replace.gd` | 替換：unrest≥20 + 統領≥0.3 |
| `event_faction_defect.gd` | 脫離：faction≠-1 + unrest≥20 + 義氣<0.35 |
| `event_tag_shift.gd` | tag 增減：好戰/野心→+軍隊；戰損>50%→+流亡；資源穩定→-流亡 |

---

### 測試

| 檔案 | 內容 |
|---|---|
| `scripts/debug/headless_test.gd` | 1000+ Tick headless 模擬；涵蓋所有系統驗證（資源/反應/戰鬥/faction/子團/視野/薪水/疲勞/日夜/外交/戰略/玩家/遭遇戰/**members_detail/team_stats**） |
| `scripts/debug/team_ui_test.gd` | 成員快照欄位驗證 + TeamUiHelper 所有渲染函數覆蓋測試 |

---

### 文件

| 檔案 | 狀態 |
|---|---|
| `docs/person.md` | 四層決策、14技能、部位健康、慎重契約 |
| `docs/team.md` | 欄位、人口規則、unrest 門檻 |
| `docs/world.md` | Tick 循環、LOD、資源、迷霧 |
| `docs/event.md` | Registry 架構、現有事件 |
| `docs/message.md` | 三層架構、衰減公式、4種傳播 |

---

## 待完成 / 技術債

### 功能缺口

| 項目 | 說明 | 優先 |
|---|---|---|
| `_check_night_raid` 接入 | interaction_system 已有函數，尚未在 `_try_interact` 呼叫；遭遇戰 encounter-system 負責整合 combat_type="pursuit" | 中 |
| `get_goal_task_override` 接入 | NpcAiSystem 已實作，尚未被任何系統呼叫；需在 faction_ai 或 sim_runner 決定呼叫點 | 中 |
| 傳令兵 SubteamSystem 接口 | `_messenger_exit` 呼叫 SubteamSystem.create_subteam（不存在）；目前 has_method 保護為空殼 | 低 |
| `generate_birth_goals` → world_generator | NpcAiSystem 已有邏輯，world_generator 另有初始化；兩套並行，可統一 | 低 |
| `_evaluate_alliance_need` → 實際觸發外交 | 目前僅 print 警告；需呼叫 DiplomaticAiSystem._form_alliance | 低 |
| PLAYER_MAX_WEIGHT 強制執行 | PlayerSystem 定義 30.0 但未在 add_to_inventory 執行重量限制 | 低 |
| text_ui `_player_cmd.get_available_actions` | text_ui_main.gd 互動模式仍直呼 `_player_cmd`（非 bridge），未完全隔離 | 低 |
| text_ui `_build_interact_str` 直讀 state | pending targets 顯示仍直讀 `_state.teams`；body_slots 直讀 `_state.persons` | 低 |
| `player_forced_event_id` 碰撞風險 | 目前 `str(randi())`；可改雙 randi 或 UUID，但碰撞機率極低 | 低 |
| Agent REPL encounter 測試 SKIP | seed=42 radius=3 在 5000 ticks 內未觸發遭遇戰；AC#13-16 GDScript 端已實作，需調整測試條件 | 低 |
| Agent REPL stdin stdout 污染 | stdin 模式下模擬 print 混入 stdout JSON Lines；TCP 模式無此問題 | 低 |
| `preview_trade` 精確度 | `preview_trade()` 用簡化比例公式，與 `resolve_trade_direct()` 實際計算略有差異 | 低 |

### 系統整合缺口

| 項目 | 說明 |
|---|---|
| salary → kindness 記憶 | ✅ 已完成（2026-05-28） |
| check_goal_alignment 接入 | ✅ 已完成（reaction_system，2026-05-28） |
| threat_map → team_discovered | ✅ 已完成（strategic_ai，2026-05-28） |

### 平衡（所有 TEST VALUE 未正式調整）

| 分類 | 涉及系統 |
|---|---|
| 疲勞速率/恢復 | SimRunner FATIGUE_PER_TICK=0.002 / FATIGUE_RECOVERY=0.01 |
| 日夜乘數 | DayNightSystem speed/fatigue/vision mults |
| 視野常數 | VisionSystem VISION_RADIUS=3 / SCOUT_BONUS=2.0 |
| AI 追擊上限 | PathSystem AI_ETA_LIMIT=1200（≈10 plains hex）|
| 薪資比例 | SalarySystem SALARY_PER_SKILL_POINT=2.0 / OVERPAY_BONUS=0.02 |
| 外交門檻 | DiplomaticAiSystem score 0.55/0.6 |
| 遭遇戰數值 | EncounterSystem 射程/命中/傷亡率 |
| 戰略 AI 間隔 | StrategicAiSystem STRATEGIC_INTERVAL / ALLIANCE_CHECK_INTERVAL |

### 待開發（大功能）

| 項目 | 狀態 | 說明 |
|---|---|---|
| **Mounts/Wagons 速度** | 🚧 plan + sub 中 | mount bonus max 3X + size_penalty / wagon -30% / 1 人 1 獸 / stable facility / wild_horses 野採 / mount 吃糧 / loot 公式 |
| **NPC 會合/攔截**（W1+W2）| 🚧 spec + plan 寫好，待 mounts merge 後 dispatch | ThreatAssessment + predict_intercept + 4 反應 + trader → outpost-only + trade timeout |
| **戰場 mount unit-level** | 未開 spec | mounts/wagons spec 後續：encounter 騎兵 unit + 衝擊 + 機動 + 戰場 mount 死亡 |
| **named 升階機制** | 未開 spec | 從 anon 抽 → tier 決定 named 初始屬性 |
| **戰俘處置 spec** | 未開 spec | 賣 / 屠 / 招降 / 釋放，loyalty 規則 |
| **外交招募 spec** | 未開 spec | 投靠 / 雇傭軍 / 直接買高 tier |
| **tag drift** | 未開 spec | leader values / event 改 tag（軍隊變商隊等）|
| **salary 欠薪後果** | 未開 spec | Bug2：coin<0 → loyalty 降 / 離隊（接 reaction）|
| **NPC promote/train AI** | 未開 spec | W4：leader 個性 + 物資 自動評估 promote/train |
| **UI / 渲染** | ✅ text_ui_main / popup_layer / main.gd 已透過 SimBridge 隔離 WorldState 玩家欄位 |
| **玩家操作介面** | ✅ PlayerApiMapper + PlayerQueryApi + PlayerCommandApi + SimBridge 玩家 API 邊界已建立 |
| **成員檢視 UI（team_ui）** | ✅ 三欄式 member inspector 完成（2026-06-02）：PlayerApiMapper.members_detail + team_stats；TeamUiHelper 靜態渲染；text_ui_main member_mode 狀態機（W/S 選人，1–4 切換子模式：快覽/健康/裝備/能力）；headless_test + team_ui_test 驗證 |
| **anon tier UI** | team panel tier 分布 / 升等進度條 / combat 死亡分檔 |
| **遭遇戰 UI** | EncounterSystem 已有邏輯層，需 hex 地圖渲染 + 玩家指令輸入 |
| **天氣/季節系統** | 影響地形乘數、採集效率、疲勞 |
| **宗教/文化系統** | 新 values 或 faction 屬性 |
| **PersonGenerator 其他 call site** | 玩家招募、天賦事件 |
| **存檔/讀檔** | WorldState 序列化 |
