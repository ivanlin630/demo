# 開發進度

## 📍 當前狀態（2026-06-14）

**玩家核心迴路定為 Kenshi 型下而上生存**（spec `2026-06-14-stage1-survival-forage-hunt-design`）。階段拆分：1 開局生存 / 2 招人 / 3 據點 / 4 成勢力。

- **階段1 Plan 1（覓食地基）已 merge**（`ff646f6`）：無據點隊覓食食物（FORAGE_RATE/食物only/枯竭/scale鎖）+ NPC survival forage path（pop≤15 門檻防大軍蟑螂）+ 釋放條件 + `survival_start` 開局 config。2 年 multi died=no、coin_eq delta=0、大軍無覓食、小隊 23→41。遺留見 known_issues W7。
- **階段1 Plan 2a（小獵物食物層）已 merge**：wild_game world-gen + 月再生 + `HuntSystem.hunt_small_game`（求生 roll/枯竭/食物）+ NPC 覓食被動小獵 + 玩家 hunt 指令 + `_collect_from_tile` 排除活物。2 年 multi died=no/coin_eq 0/survival_start 23→36。
- **Bug7 已修**（interaction:233 stale-id race，一行守衛；warzone 2 年 OOB 3→0）。
- **階段1 Plan 2b-1（野獸戰鬥核心）已 merge**：爪牙武器 grade + predator_density 生成/再生 + BeastSystem pseudo-team（負 id）+ encounter beast spawn/逃戰行為/爪牙攻擊/得肉清除 + npc_combat beast_strength/reward + 玩家 hunt_beast 指令。reuse 人類戰鬥機制。6 測試綠/2 年 multi died=no/coin_eq 0/無 beast 殘留。
- **階段1 Plan 2b-2（野獸伏擊+偵測）已 merge**：AmbushSystem.detect（偵查/求生 vs 掠食者隱蔽）+ 伏擊編排（玩家→encounter/NPC→npc_combat 遵 Bug9）+ sim_runner 接入 + 獵勝戰鬥 exp + 掠食者 infamy 計數 + NPC 主動獵獸。7 測試綠/2 年 died=no/coin_eq 0/[Ambush]×5。
- **subsistence 改狩獵唯一（Plan 2c）已 merge**：移除被動覓食食物噴泉（量測 income~44>>burn~7、囤 300+天糧）→ 食物唯一來源=狩獵 wild_game。
- **tile_food_init→cap bug 修 + outpost.terrain 釘地形**：村餓死真因（tile_food_init 不設 cap、村在山地）；survival_start 村釘平原 → 23→22 穩。
- **絕境驅動多元生存行為（desperation-survival）已 merge**：`_trigger_survival` 重構 desperation×values（warning 個性門檻 / urgent 解閘人人有活路）+ pref helpers + 紮營（依個性軍/民 + 升 tag 清流亡 = 流浪→定居攀爬）。2 年 multi 行為多元（loot130/camp17/forage14/beg15/join9/hunt6）、survival_start 23→21、coin_eq 0、無誤觸。
- **✅ 階段1（開局生存）整套完成 + 求生行為多元化**：覓食(已退場)→狩獵唯一 + 野獸戰鬥/伏擊 + 絕境多元生存。世界 2 年無崩、守恆 0。
- **NPC 向上攀爬**：吞併→建勢力（npc_combat/interaction）、建造/紮營→定居成生產/軍隊（auto_settle + crude camp）、W4 設施階梯、pop→分裂。流浪→定居這階補齊。

- **SoloAI 主動尋家 + 承諾慣性已 merge**：`_evaluate_solo` 加 紮營/投靠 value 加權（無家團、bypass _tag_weight 避流亡歸零）+ solo_intent 慣性（止 flip-flop）。churn 修（主動 camp 免糧足釋放 + 到達兜底）。2 年×3 roving 主導非 uniform、安身率↑、守恆 0。流浪→定居 bottom-up 進展接上。

### 佇列（下一步選項）
- ~~狩獵受傷→醫療~~ **已涵蓋**：危險獸走真戰鬥（encounter/npc_combat）→ body_parts 傷 → 戰後 `resolve_negative_flags` 耗 medicine。小獵物抽象 roll 免傷（合理）。無需另做。
1. **UI 接入（player 可玩性）**：stage-1 全機制（覓食/狩獵/hunt 指令/野獸/伏擊/求生）目前**僅 headless 驗,玩家無法經 UI 玩**。原 arc 目標「世界合理→轉玩家迴路」。team0 harness 餓死症結也因玩家無 UI 自驅。
2. **量測 tune 階段1 全 TEST VALUE**：loot 偏高 130 / SoloAI proactive 投靠占比低（0 次,門檻嚴）/ FORAGE/BEAST/AMBUSH 數值。一次一變因（世界已穩,非急）。
3. **②深層目標錨**（待 spec）：接 dormant goal 系統,長弧（盜匪→建國）。先量測承諾慣性夠不夠。
4. 階段2（招人成幫）。

### 殘留 bug / 量測限制
- **team0(玩家隊)在 multi 餓死 = harness 限制**（玩家隊 _evaluate_survival early-return + auto-driver 不代跑玩家生存）非 cascade bug。要量測玩家生存需 NPC-觀測 config 或 auto-driver 補生存代跑。
- Bug8（滅團 food 公庫 baseline）；Bug9（encounter player_id==-1 latent）。
- invariants 新增：對稱性、玩法節奏（decisions-not-chores + 激情時刻）。
- invariants 新增：對稱性（無玩家專屬機制）、玩法節奏（decisions-not-chores + 激情時刻）。

---

## 📍 前狀態（2026-06-13 session 末，重啟交接）

### 本 arc 已 merge（依序）
設施改制 A 期（slot/8設施/軍民/三級成本/守恆審計）→ B 期材料層（herb/馬鏈/選址滾動拓殖）→ 經濟一致性（per-unit 製造 + 全表定價 + 飢荒5x）→ 馬爾薩斯修正（選址diff/復工門檻/COLLECT_RATE 0.01→0.05）→ 飢餓致死鏈（famine_days + hunger→blood + 昏迷 + blood=0死）→ 封建財政公庫（一般稅自動進公庫 + 建造扣公庫 + 特別稅 + 慷慨光譜 + 兩稅不滿）→ W4 caravan-load 派工提領 + leader 治理 → **W5 task latch 大修**（核心）→ W6 死亡資產守恆 → 經濟死水解鎖（自給階梯 + 治理faction leader + 生育分層）

### 🔑 本 session 最大發現：task latch 凍結世界（W5）
TeamTrace 遙測（`scripts/debug/team_trace.gd`，gated game_sim_test 每日 dump）量出 **92% team-time 凍結在不釋放的 survival(p80)/panic(p70)**。世界非窮而是**癱瘓**。修 survival 糧恢復釋放 + 逃跑 timeout + 乞食釋放 + 餓死團清除後，**所有機制自己活起來**：

| 機制 | latch 修前 | 解凍後（2年×4config）|
|---|---|---|
| 戰鬥 Combat Start | ~0 | 13 |
| 貿易 Market 成交 | 0 | 11 |
| 徵稅 / 援助 | 稀有 | 12 / 6 |
| 生育長大成人 | 0 | 39 |
| 設施建造 | 2 | 4 |
| coin_eq 守恆 | — | delta 0.00 ×4 |

**重要結論**：W1/W2「0 combat/0 trade」**不是擦肩會合問題，是 latch 症狀**（速度差本就存在，team 凍住沒去追）。會合機制不用做。

### ✅ 軍閥型 config 已達標（2026-06-13 後續，config-first 解）
前況：tyrant 60→0 全滅、warzone 54→3。**純 config 修**（未動 AI）：
1. 每軍閥 faction 加一座生產村（生產 tag + civilian L1 outpost + tile_food_init 500，複製受壓村模式）→ faction 自給
2. tyrant `敵對暴君` tile_pos (8,5) 出界（hex_dist=5 > radius 4）→ 修 (7,5)。整個 faction 1 原坐空 tile 無法收糧 = 主要崩因（交接舊記「(7,7)」為誤記，真凶 (8,5)）

跑 21600 tick（2.5 年）結果，**達「合理」門檻全部**：

| config | pop | teams | died | 戰鬥(Round) | 貿易(Market) |
|---|---|---|---|---|---|
| tyrant | 88→57 | 5→14 | no | 166 | 59 |
| warzone | 134→128 | 5→28 | no | 33 | 211 |

順帶修 `vision_system.tick_discovery` race：team_ids 快照含本 tick 內滅團 id → `state.teams[tid]` 報 Invalid get index。加 `state.teams.has(tid)` 守衛（[Extinct] 增多才觸發）。修後 SCRIPT ERROR 0。

**結論：世界已合理 → 下一步轉玩家可玩性迴路，勿再追 NPC 完美化。** 殘留 [Survival] 6399 次警告為高頻但非 latch（戰鬥/貿易/製造/分裂全流動，team 數淨增），低優先可後看。

### 🎯 重啟後的決策（已與用戶確認）
- **遊戲類型 = 世界模擬器，合理 NPC+經濟是可玩前提**（不能把玩家迴路硬接在自毀世界上）
- 但「合理」≠「完美 AI」。標準：**2 年無荒謬全滅 + 各 config pop≠0 + 戰鬥/貿易≠0**。達標即收手，**勿掉回 NPC 完美化無底洞**
- ~~下一步：改軍閥 config 給生產基礎 → 跑 2 年 → 資料說話~~ **已完成，世界達標（見下「✅ 軍閥型 config 已達標」）**
- **現在下一步：轉玩家可玩性迴路**（世界已合理，不再追 NPC 完美化）
- 順手（非優先）：`faction_ai_system.gd` 2000+ 行怪獸拆檔（每次都改它，編輯可靠性受損）

### 待修小項
- W4 遊牧軍閥 leader 不駐留（建造仍卡 tyrant/warzone）— 部分修
- Bug2 salary coin 無下限
- config 在 radius 外 spawn team（(7,7) 超 radius 4）隱患
- 全參數 TEST VALUE 待正式平衡

---

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
| 生育機率 | ReactionSystem BREED_BASE_CHANCE=0.15（+醫療×0.1）；minor cap=maxi(1,int(pop×0.25))（2026-06-13 economy-bootstrap）|
| 治理門檻 | FactionAISystem GOVERN_MATERIAL_TARGET=75（公庫達標放手擴張）|

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
