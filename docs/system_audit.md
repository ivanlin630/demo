# System Audit Report — 2026-06-05

逆向工程產生。描述「現在是什麼」，不是「應該是什麼」。

---

## DATA STRUCTURES

### `world_state.gd`
**Purpose:** 中央遊戲狀態容器。

**Key fields:**
- `world: WorldData` — current_tick, tiles
- `teams / persons / factions: Dictionary`
- `team_known / team_discovered / team_intel: Dictionary`
- `player_id, player_state, player_hostile_teams, player_pending_targets`
- `player_forced_event` — NPC 主動外交/勒索（non-blocking，1小時無回應自動拒絕）
- `player_pending_orders` — 信使傳令格式 `{ member_team_id → { task, herald_id } }`
- `player_alerts` — food_critical / member_defected / faction_member_betrayed / subteam_destroyed / outpost_captured
- `encounter_active, encounter_units, encounter_attacker_id, encounter_defender_id, last_encounter_result`

**Functions:**
- `create_faction(leader_team_id)` → 建立勢力，回傳 faction_id
- `disband_faction(faction_id)` → 解散勢力，清 member faction_id
- `snapshot_faction_member(team_id, tick)` → 更新 known_member_states

---

### `person_data.gd`
**Purpose:** 單一 NPC 資料。

**Key fields:**
- `needs: { food, safety, belonging }` (0–1)
- `stress, fear, loyalty` (0–1)
- `attributes: { 體力, 智力, 魅力, 毅力 }` (0–1)
- `skills: { 統領, 戰鬥, 弓箭, 求生, 生產, 製造, 工程, 醫療, 戰術, 計謀, 交涉, 商業, 偵查, 潛行 }` (0–1)
- `values: { 野心, 求生欲, 義氣, 貪婪, 慎重, 好戰, 殘忍, 信義 }` (0–1，**慎重**為全系統風險行為抑制鍵）
- `equipment: { head/torso/arms/legs/hand_1/hand_2 }` → `{ type, grade }`
- `body_parts` → `{ hp, max_hp, status, poisoned, bleeding, fracture }`
- `memory: Array` → 混用兩種格式（reaction 紀錄 + 目標追蹤）

**SMELL:** `memory` 同時存兩種結構不一致。

---

### `team_data.gd`
**Purpose:** 單一 team。

**Key fields:**
- `leader_id, named_members: Array` (person_ids)
- `population, minor_population, prisoner_population`
- `resources: { food, material, coin, goods, gem, ore_*, weapon_*, mounts, wagons, arrows, medicine, tools, armor_* }`
- `current_task: String` (idle/徵收/偵查/信使/攻擊/掠奪/外交/護衛/逃跑/生產/製造/貿易/巡邏/建設/合併)
- `combat_target: int`
- `readiness: float` (0–1)
- `parent_team_id, subteam_ids`
- `order_target_id, order_task, player_commanded_task`
- `strategic_assignments: { -1(breakout) or enemy_team_id → Vector2i }`

---

### `faction_data.gd`
**Key fields:**
- `goals: Array` — 徵收/立國/擴張/防禦
- `strategy: String` — idle/緊急徵收/定期徵收
- `relations: { faction_id → neutral/ally/enemy }`
- `known_member_states: { team_id → { food, weapons, goods, population, tile_pos, current_task, last_tick } }`
- `player_goal_override, strategic_goals`

---

### `tile_data.gd`
**Key fields:**
- `terrain` (plains/forest/mountain)
- `resources, resource_cap` (cap 生成後不變)
- `harvest_factor` (0.1–2.0 季節修正)
- `outpost_type/level, farming_level, manufacturing_level` (0–3)
- `construction_ticks_left, construction_team_id, construction_target`

---

---

## SIMULATION SYSTEMS

### `sim_runner.gd`
**Purpose:** 主 tick 循環協調器。LOD_NEAR_RADIUS=3，FAR_ZONE_INTERVAL=100 ticks。

**Tick order (near zone, every TICKS_PER_HOUR):**
1. VisionSystem (偵測)
2. EquipmentSystem (裝備分配)
3. MovementSystem (移動)
4. MessageSystem (訊息傳播 + intel 交換)
5. InteractionSystem (遭遇/互動)
6. OutpostSystem (建設)
7. ResourceSystem (採集)
8. HarvestSystem (6小時)
9. ManufacturingSystem (製造)
10. ResourceSystem.resolve_consumption (消耗)
11. SalarySystem (薪資)
12. FatigueSystem (疲勞)
13. FactionAISystem (AI決策)
14. StrategicAISystem
15. ReactionSystem (人物反應)
16. NpcAiSystem.cleanup_goals
17. EventSystem (事件)
18. MessageSystem.emit

**INCOMPLETE:** Far-zone 不執行 ReactionSystem，遠方 NPC stress/loyalty 不更新。

---

### `resource_system.gd`
**Constants:** FOOD_PER_PERSON_PER_DAY=2.4 (TEST)

**Functions:**
- `collect_resources()` → 有 outpost Lv1+ 的 team 採集；Lv3 可採鄰格 0.5×
- `regenerate_tiles()` → 食物按 harvest_factor 再生；礦石/寶石**不再生**
- `resolve_consumption()` → 扣食物，更新 needs["food"]；危急時 player_alerts

**SMELL:** `_collect_from_tile()` 7個參數；採集係數 hardcoded (0.01 × pop × outpost)。

---

### `reaction_system.gd`
**Constants:** GOAL_CHECK_INTERVAL=100 ticks

**10 種反應評分 (每10小時更新):**
- 正面: comply(+loyalty), produce(+food), recruit(+pop), expand(-unrest), breed(+minor_pop)
- 負面: flee(-pop), riot(+unrest), defect(-pop/loyalty), shirk(-food), extort(-coin)

**INCOMPLETE:**
- 無探索、技能訓練、多人陰謀等複雜反應
- "None" 反應 baseline 0.2，無機制效果
- 30% flee → 切換 task 到 "逃跑"，但無後續邏輯

---

### `movement_system.gd`
**Constants:**
- WORLD_SPEED_MULT=2
- TERRAIN_SPEED: plains 1.0, forest 0.7, mountain 0.4
- WAGON_TERRAIN: plains 0.9, forest 0.4, mountain 0.2

**INCOMPLETE:**
- **無地圖邊界檢查** → NPC 可移動到地圖外
- Stray mount loss: 高隨機方差，per-tick 離散 RNG

---

### `message_system.gd`
**Propagation modes:** honest/unintentional/malicious/silent（由 carrier 義氣/計謀/慎重決定）

**INCOMPLETE:**
- 舊訊息**永遠累積**，無衰減清除
- 無訊息數量上限 → 可能 memory leak

---

### `interaction_system.gd`
**Constants:**
- ROUND_CASUALTY_RATE=0.1, WOUNDED_TREATMENT_RATE=0.3
- LOOT_RATE=0.3, COMBAT_THRESHOLD=0.7

**Functions:**
- `process_on_arrival()` → readiness 恢復、治療傷患、持續戰鬥、嘗試新互動
- `_tick_readiness()` → 不在戰鬥時恢復
- `_treat_wounded()` → 最高醫療技能者治療
- `_process_ongoing_combat()` → 同格才繼續戰鬥
- `_try_interact()` → 判斷是否開戰/貿易/外交

**SMELL:** 600+ 行長函式，戰鬥+外交+貿易全混。

---

### `encounter_system.gd`
**Constants:**
- MAP_RADIUS=12, MAP_DIAMETER=24
- BASE_ACTION_TICKS=10
- ANON_UNIT_CAP=30

**Functions (已實作，850+ 行):**
- `init_encounter()` → 初始化戰場，生成雙方單位
- `advance_encounter_tick()` → 主循環：處理所有單位行動，檢查勝負
- `_decide_action()` → 每單位 AI（追敵/逃跑/信使/玩家等待）
- `resolve_attack()` → 傷害計算（武器/身體部位/出血/骨折）
- `resolve_encounter_end()` → 結算：俘虜、掠奪、encounter_active=false
- `_create_named_unit() / _create_anon_unit()`
- `is_dead() / is_combat_capable()`
- `_get_edge_entry_positions() / _get_edge_hexes()`
- `_is_in_map()` → hex_dist(ZERO, pos) <= MAP_RADIUS

**已知 bug（已修）：**
- `_action_attack` 未呼叫 `init_encounter` → 已修（feat/encounter-bug-fix）

**已知 bug（待修）：**
- L640：retreat/messenger_exit 用 `>= MAP_RADIUS` 判斷退出，應為 `> MAP_RADIUS`（邊界單位提早退出）→ 已修 main

---

### `faction_ai_system.gd`
**Constants:**
- COLLECT_INTERVAL=300 ticks, FACTION_UPDATE_INTERVAL=200 ticks
- FOOD_EMERGENCY=3.0 (food/capita 閾值)

**Functions:**
- `evaluate_all()` → 每 faction 更新目標、分配任務、外交、背叛風險
- `_update_goals()` → 根據 food/readiness/power 追加「徵收」「立國」目標
- `_assign_tasks()` → 成員任務分配：player_commanded_task loyalty 檢查、徵收/立國/外交/攻擊/掠奪目標分配（已實作）

---

### `npc_ai_system.gd`
**Functions:**
- `write_memory()` → 更新 relations，觸發目標（背叛→復仇, 善意→感激）
- `generate_birth_goals()` → 依 values 生成初始目標
- `check_goal_alignment()` → 目標-任務對齊加成
- `cleanup_goals()` → 清除死亡目標，尋找復仇重導向

**INCOMPLETE:** 目標成功/失敗條件無，觸發僅靠 memory write。

---

### `vision_system.gd`
**Constants:** VISION_RADIUS=3, SCOUT_BONUS=2.0 per 1.0 偵查

**SMELL:** 技能成長 `_grow_skill()` 寫在 vision_system 內，非 skill_system。

---

### `equipment_system.gd`
**Functions:** 武器分配給 named members，更新 armed_anon_ratio

**INCOMPLETE:**
- 無護甲分配給 named members
- Hand_2（副手/盾牌）未處理
- 武器回收率 hardcoded

---

### `population_system.gd`
**Function:** 每日檢查人口溢出，超過 pop_cap 時強制分隊或建立「流亡」team

**SMELL:** 溢出邏輯碎片化 — PopulationSystem（每日檢查）+ ReactionSystem（flee）+ EventSystem（leader death split）三處各管，無統一狀態機。

---

### `outpost_system.gd`
**Functions:** 建設 tick、完工處理（build/upgrade/demolish）

**INCOMPLETE:**
- 無攻城/佔領邏輯
- 無駐軍/製造加成對資源產出的實際效果
- 無俘虜勞動機制

---

### `salary_system.gd`
**Constants:** SALARY_INTERVAL=TICKS_PER_MONTH, SALARY_PER_SKILL_POINT=2.0

**INCOMPLETE:**
- 無薪資破產後果（叛亂/解散）
- 無玩家調整薪資機制

---

### `diplomatic_ai_system.gd`
**Functions:**
- `_calc_diplomacy_score()` → 食物/權力/信譽/關係/和平值加權
- `try_proactive_diplomacy()` → 掃描已發現 teams，評分後提案
- `handle_diplomacy_message()` → 回傳 accept/reject
- `consider_betrayal()` → 背叛評分

**INCOMPLETE:**
- 背叛評分有，**背叛動作不執行**
- 進貢提案有，**無收款/違約機制**

---

### `strategic_ai_system.gd`
**Functions:** 每10小時更新勢力目標（擴張/防禦/貿易網），分配包圍圈任務

**INCOMPLETE:** 包圍圈幾何計算不明，防禦目標無保護移動。

---

### `subteam_system.gd`
**Functions:**
- `dispatch()` → 建立子隊 TeamData，按比例分資源，從 parent 移除 sub_leader
- `try_merge_back()` → 子隊在 parent 同格時合併回去
- `merge_teams()` → 部分合併

**🔴 INCOMPLETE:** `_merge_into()` 完整合併邏輯未找到，資源再平衡後合併細節不詳。

---

### `harvest_system.gd`
**Constants:** SEASON_BASE: [spring 1.1, summer 1.5, autumn 1.2, winter 0.3]

**INCOMPLETE:** 饑荒警告是單向訊息，無 team 行為回應。

---

### `manufacturing_system.gd`
**Functions:** task="製造" + civilian outpost Lv1+ 時執行配方

**INCOMPLETE:**
- 無生產排隊/自動化
- 配方優先序固定（無玩家偏好設定）

---

### `player_command_system.gd`
**Constants:** RECRUIT_COST_ANON=50, RECRUIT_COST_NAMED=150

**Known actions:**
- ignore, attack, trade, propose_alliance, demand_tribute, extort, recruit, gather_intel
- accept_encounter, surrender_pre_encounter, confirm_trade, cancel_trade, offer_surrender
- set_faction_goal, order_faction_member, clear_member_order, recall_subteam, dispatch_subteam

**🔴 多數 _action_* 是 stub 或不完整：**
- `_action_trade` → 設 pending_trade_target，無實際交換邏輯
- `_action_recruit` → 花 50 coin +1 匿名人口，無選單
- `_action_extort` → 有，調用 resolve_extortion_direct
- `_action_attack` → ✅ 已修：呼叫 `_encounter.init_encounter(state, pt_id, target_id, "normal")`

**SMELL:** 大型 registry，complex actions 無參數驗證。

---

### `inquiry_system.gd`
**Functions:** NPC 情報查詢（位置/食物/敵軍/事件/勢力），relation < 0.5 加位置噪聲

**INCOMPLETE:** 無諜報風險，無虛假情報懲罰，relevance scoring 不詳。

---

### `health_system.gd`
**Functions:** 體部 HP、出血/中毒 tick、速度/攜帶懲罰

**INCOMPLETE:**
- 無肢體截肢後果
- 無長期感染/傷疤

---

### `skill_system.gd`
**Growth:** 每次 reaction 成長 BASE_GROWTH=0.005

**INCOMPLETE:**
- 無技能衰退（長期不用）
- 無勝負比對技能成長
- 無跨技能協同

---

---

## 嚴重程度排序

### S1 — 遊戲根本無法運作
| 問題 | 位置 | 狀態 |
|---|---|---|
| ~~遭遇戰行動邏輯不存在~~ | ~~`encounter_system.gd`~~ | ❌ 誤判：已實作 850+ 行 |
| ~~玩家攻擊不呼叫 init_encounter~~ | ~~`player_command_system._action_attack`~~ | ✅ 已修 (2026-06-05) |
| ~~貿易無實際交換邏輯~~ | ~~`player_command_system._action_trade`~~ | ✅ 已修 (2026-06-05) — PlayerTradeSystem |

### S2 — 重要功能殘缺
| 問題 | 位置 |
|---|---|
| ~~招募無選單（匿名/據名選擇）~~ | ~~`player_command_system._action_recruit`~~ | ✅ 已修 (2026-06-05) — recruit 改為永遠回傳選單 payload（anon_available/willing_members），不再自動執行 |
| ~~子隊合併邏輯不完整~~ | ~~`subteam_system._merge_into`~~ | ✅ 已修 (2026-06-05) — team_discovered+faction cleanup, _try_merge 參數順序修正 |
| ~~FactionAI 任務分配 stub~~ | ~~`faction_ai_system._assign_tasks`~~ | ❌ 誤判：已實作（loyalty/goals/dispatch） |
| ~~NPC 可移動出地圖~~ | ~~`movement_system`~~ | ✅ 已修 (2026-06-05) |
| ~~進貢無收款/違約~~ | ~~`diplomatic_ai_system`~~ | ✅ 已修 (2026-06-05) — 拒絕寫記憶+聲譽 |
| ~~背叛評分但不執行~~ | ~~`diplomatic_ai_system.consider_betrayal`~~ | ✅ 已修 (2026-06-05) — orphan cleanup + iteration safety |

### S3 — 品質問題
| 問題 | 位置 |
|---|---|
| InteractionSystem 600+ 行 | `interaction_system.gd` |
| 溢出邏輯碎片化三處 | Pop/Reaction/Event |
| 技能成長邏輯散落各處 | Vision/Skill/Manufacturing |
| 舊訊息永遠累積 | `message_system.gd` |
| 全系統 magic numbers | 多處 |

### S4 — 功能設計了但未實作
| 問題 | 位置 |
|---|---|
| 俘虜系統（欄位存在，邏輯無） | `team_data.prisoner_population` |
| 薪資破產後果 | `salary_system` |
| 攻城/佔領邏輯 | `outpost_system` |
| 護甲分配給具名成員 | `equipment_system` |
| 技能衰退 | `skill_system` |
| 顧問效果 | 未在任何系統中出現 |

---

*Generated: 2026-06-05*
