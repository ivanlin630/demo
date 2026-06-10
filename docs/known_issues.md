# Known Issues

> 最後更新：2026-06-10（NPC wakeup fixes + tier system + speed tune）| 來源：動態測試 + code review

---

## 🔴 高優先（影響基本可玩性）

### W1. NPC 0 Combat 起戰 — 會合不上
- **症狀**：multi 4 config × 90 天，ProsperityAttack 5 次排程 + attacker 都會動，但 `[Encounter]` / `[Hit]` = 0
- **根因**：attacker 追會動的 prey，雙方同速 → 永遠差 1 hex；`interaction_system.process_on_move` 要嚴格同格才 try_interact
- **發現**：2026-06-10 NPC wakeup fixes merge 後驗證
- **建議**：開「會合/攔截」spec，候選方案：
  - A. 相鄰即接戰（距 ≤ 1 hex）
  - B. prey 預警停下（看到 hostile attacker 靠近）
  - C. 攻擊方攔截預測（算 prey 未來位置）
  - D. 防守方 active 反應（迎戰/逃跑）

### W2. NPC 0 Trade 成交 — 會合不上
- **症狀**：trade_net 派發 433 次（wakeup 後），但 `[Market]` / 成交 = 0
- **根因**：同 W1，trader 追會動的 partner 永遠差 1 hex
- **副作用**：商隊 task 卡 "貿易" 不回 idle → 新形態 zombie（已非 stuck，但等同無進度）
- **發現**：2026-06-10
- **建議**：跟 W1 一起解，或 trader 派往「定點」對象（有 outpost 的 resident / 商隊駐點）；trade task 加 timeout 自動回 idle

### Bug2. salary 拖 coin 無下限
- **症狀**：integration test merchant min_coin=-49 / warzone min_coin=-42（90 天）
- **根因**：salary 系統發薪前不檢查 coin >= 0；新團 `[Split]` 出來特別易負
- **影響**：經濟守恆破，新生團體永久赤字
- **發現**：2026-06-09 integration test
- **建議**：coin<0 觸發欠薪後果（接 reaction 系統 → loyalty 降 / 離隊 / anon 補充停），或夾在 0 並記欠薪

### S1. 視野公式門檻太高 ✅ 已修
- **修正**：`_can_detect` 門檻從 `> 0.5` 降至 `> 0.3`
- **位置**：`scripts/simulation/vision_system.gd:42`

### S2. SALARY_INTERVAL=30 → tick 30 全體 loyalty 歸零 ✅ 已修
- **修正**：`SALARY_INTERVAL = TICKS_PER_MONTH`（= 7200 ticks = 30天）
- **位置**：`scripts/simulation/salary_system.gd:3`

### S6. P3_recruit 人口崩潰 ✅ 已修（2026-06-02）
- **症狀**：開局 tick 10 人口從 10 降至 1；named member 變成 ghost（仍在列表但 pop=1）
- **根因 A**：`team.population = mini(pop+1, cap)`，玩家 leader 統領=0.0 → cap=1 → `mini(11,1)=1`
- **根因 B**：N1_flee/N3_defect 只改 `team.population`，不清 `named_members` → ghost member
- **修正**：
  - `P3_recruit`：改為 `if team.population < cap: team.population += 1`（永不減少）
  - 玩家 leader 初始 `skills["統領"] = 0.15`（cap=10，支撐預設 pop=10）
  - `N1_flee`/`N3_defect`：加 `named_members.erase(id)` + `person.team_id = -1`
- **commit**：`274a08b`（recruit+初始技能）、`ef60b64`（ghost member 清理）

### U1. X<0 圖塊無法選取與移動 ✅ 已修
- **修正了**：`pixel_to_hex` guard、`_on_move` sentinel、`_draw` 白框 sentinel
- **仍需驗證**：重開遊戲後實測確認

### U2. 可移動到地圖外 ✅ 已修
- **修正**：`_on_set_move_target` 加 `state.world.tiles.has(pos.x*1000+pos.y)` 驗證
- **位置**：`scripts/ui/main.gd:86`

### U3. NPC 旗子看不到 ✅ 已修（連動 S1）

---

## 🟠 中優先（影響遊戲合理性）

### S3. SEASON_LENGTH=30 → 1年=5天 ✅ 已修
- **修正**：`SEASON_LENGTH = TICKS_PER_SEASON`（= 90天/季）
- **位置**：`scripts/simulation/harvest_system.gd:3`

### S4. 人口分裂太快
- **症狀**：main.gd 開局 3 team，tick 10 開始自動分裂，tick 30 已有 10+ team
- **根因**：PopMgmt 分裂條件觸發太容易；10 人就能分裂出子隊
- **位置**：`scripts/simulation/population_system.gd`
- **建議**：提高分裂門檻，或 demo 期間停用自動分裂

### S5. main.gd test setup 無 outpost → 12.5 天必定斷糧
- **症狀**：300 food / (10人×0.1/tick×24tick/天) = 12.5 天；斷糧後人口死亡，UI 失效
- **根因**：`collect_resources` 只採 outpost 格，test setup 沒建 outpost
- **位置**：`scripts/ui/main.gd`（test setup）
- **建議**：加初始 outpost，或大幅增加初始食物（如 10000）

### G1. 攻擊後無遭遇戰 UI ✅ 已修（2026-06-02）
- **修正**：`main.gd._on_interact_execute` attack 分支：`_map.visible=false; _encounter.show_encounter()`；`_on_encounter_ended` 查詢 `take_loot` action 顯示 `show_loot_panel`
- **連動**：`encounter_system.resolve_encounter_end` 寫入 `state.last_encounter_result`；`player_command_system` 新增 `take_loot` / `leave_loot`
- **commit**：feat/attack branch merge

### G2. 外交/貿易自動執行，無玩家選擇 ✅ 已修（2026-06-02）
- **修正**：`main.gd._on_tick_advanced` 輪詢 `forced_interaction`，呼叫 `popup_layer.show_forced_event`；貿易加 `show_trade_preview` 確認步驟
- **commit**：feat/interaction-ui-framework + feat/trade branch merge

### G3. 玩家無法建立自己的勢力 ✅ 已修（2026-06-02）
- **修正**：`player_command_system.establish_faction`；`player_query_api` Layer 5 在 faction_id==-1 時顯示行動
- **commit**：feat/alliance-faction branch merge

### G4. Recruit STUB 永遠失敗 ✅ 已修（2026-06-02）
- **修正**：`player_command_system` 實裝 `_recruit_anon_internal` + `_recruit_named_internal`；coin gate（anon=50/named=150）；`popup_layer.show_recruit_panel` 供記名成員選擇
- **commit**：feat/recruit branch merge

### G5. Alliance 兩者皆獨立時無效 ✅ 已修（2026-06-02）
- **修正**：`player_command_system._accept_diplomacy_as_leader`：雙獨立時先 `create_faction(from_id)` 再 `_form_alliance`；mapper 更新 3-way 回應選項（accept / accept_join / accept_lead）
- **commit**：feat/alliance-faction branch merge

### U4. 地圖移動後有時消失
- **症狀**：移動幾次後地圖變黑、旗子消失
- **根因**：player person 因食物不足死亡 → `player_tid=-1` → `discovered=[]` → 地圖全黑
- **連動**：S5（食物）是主因；player 無死亡保護是次因

### U5. 右側欄資訊不完整
- **缺少**：玩家 HP（body_parts 狀態）、attributes/values、skills
- **缺少**：team 完整資源列表（只顯示部分 key）
- **缺少**：faction 狀態（隸屬、等級）
- **位置**：`scripts/ui/right_sidebar.gd`

### U6. 圖塊資訊只有地形
- **缺少**：tile.resources（food/material/ore 庫存量）
- **缺少**：地形速度減益係數（plains 1.0 / forest 0.7 / mountain 0.4）
- **缺少**：outpost 類型/等級/擁有者
- **缺少**：harvest_factor（農業效率）
- **位置**：`scripts/ui/bottom_bar.gd:show_tile_info`

---

### Bug5. DiplomacyAI demand_tribute 恆負
- **症狀**：90 天 120 次 evaluation，分數恆 −0.15（power_r=0.40, caution=0.80, pride=0.50）
- **根因**：caution=0.80 權重壓制 score 恆 < 0；同一決策每次重算同值
- **影響**：強者不勒索，AI 過保守
- **發現**：2026-06-09 integration test
- **建議**：調 caution 權重或 power_ratio 門檻；對未變動局勢快取決策

### Bug6. multi runner 不注入 command_schedule
- **症狀**：`game_sim_multi.gd` 只跑 advance_tick，未呼叫 `GameSetup.run_command_schedule_tick`
- **影響**：config 的 `command_schedule`（如 tyrant extract_treasury / warzone attack）全部不觸發；放大 W1/W2 觀感
- **嚴重度**：測試保真度
- **發現**：2026-06-09 integration test
- **建議**：runner 比照 game_sim_test 補 schedule 注入 + encounter 超時保護

### W3. BREAKOUT_DIST / ENCIRCLE_DIST tune
- **症狀**：常數調為 2/1 適配 radius 4 測試地圖；正式地圖 radius 可能不同
- **發現**：2026-06-10 NPC wakeup
- **建議**：改 `min(N, map_radius)` 動態計算

### W4. NPC 不主動 promote / train
- **症狀**：multi 90 天 tier promotion = 0；戰場升等 0（因 0 combat），訓練 task 0 派
- **根因**：NPC AI 無 promote/train 決策邏輯
- **發現**：2026-06-10 anon tier merge 後
- **建議**：faction_ai 加 leader 個性 + 物資 自動評估 promote/train（接 W1 解了戰鬥才有戰場 exp）

## 🟡 低優先（體驗問題，不影響可玩性）

### U7. Camera 每 tick 強制回正
- **症狀**：每次推進 tick，鏡頭自動對齊玩家，無法保持手動視角
- **根因**：`refresh()` 每次呼叫 `_center_on_player()`
- **建議**：改為只在玩家移動時重置，或加 C 鍵手動回正

### U8. Members/History popup 待確認
- **症狀**：按成員按鈕可能不顯示 popup（已加 print debug，尚未確認）
- **位置**：`scripts/ui/popup_layer.gd`

### D1. SoloAI 保護條件脆弱
- **症狀**：`team.leader_id == state.player_id` 在子隊分裂後可能失效
- **根因**：subteam 分裂可能重新指定 leader_id
- **位置**：`scripts/simulation/faction_ai_system.gd:_evaluate_solo`

### D2. player person 死亡無保護 ✅ 已修（2026-06-09）
- **修正**：H spec 玩家 leader 死亡 → forced event 選繼承人；無 named member → game_over
- **位置**：`scripts/simulation/faction_ai_system.gd._handle_player_leader_death`、`player_command_system.choose_heir`
- **連動**：選繼承人期間 `advance_tick` 凍結（回 "awaiting_heir"）；無人 → 凍結（回 "game_over"）

### A1. agent_repl stdin 模式 stdout 污染
- **症狀**：stdin 模式下模擬 `print()` 混入 JSON Lines stdout，污染協定
- **根因**：GDScript `print()` 寫入 stdout；stdin REPL 與模擬 print 共用同一 fd
- **影響範圍**：僅限 stdin 模式（Windows headless 走 TCP fallback，實際不受影響）
- **位置**：`scripts/debug/agent_repl.gd:_run_stdin_loop`
- **建議**：加 `--quiet` flag suppress 模擬 print，或在 stdin loop 前重導向 print 到 stderr

### S7a. `anon_combat_skill` 從未由遊戲邏輯設定 ✅ 已修（2026-06-07）
- **症狀**：主遊戲所有匿名單位戰鬥技能固定為 fallback 值 `0.2`，與勢力強度無關
- **根因**：`encounter_system._create_anon_unit` 讀 `team.resources["anon_combat_skill"]`，但 `faction_ai`、`world_generator`、`TeamData` 初始化都未設置此 key
- **修正**：`faction_ai_system._update_anon_combat_skill` 依 tags 計算；`anon_combat_skill` 從 `team.resources` 遷出為獨立欄位
- **位置**：`scripts/simulation/faction_ai_system.gd`、`scripts/data/team_data.gd`
- **commit**：S7 Task 1-7 系列

### S7b. `armor_config` 從未由遊戲邏輯設定 ✅ 已修（2026-06-07）
- **症狀**：主遊戲所有隊伍護甲配置固定為 `TeamData` 預設值（torso=low，其他=none），與勢力類型無關
- **根因**：`faction_ai`、`world_generator`、`game_setup` 均未設置 `armor_config`
- **修正**：`faction_ai_system._update_armor_config` 依 tags + 護甲庫存閾值計算各 slot
- **位置**：`scripts/simulation/faction_ai_system.gd`

### S7c. `guard_ratio` 從未由遊戲邏輯設定 ✅ 已修（2026-06-07）
- **症狀**：所有隊伍警衛比例固定 0.2，夜間警衛數 = `ceil(pop × 0.2)`，無勢力差異
- **根因**：`day_night_system` 讀 `team.guard_ratio`，但 faction_ai 從未寫入
- **修正**：`faction_ai_system._update_guard_ratio` 依 current_task + 鄰近威脅計算；新增 `_has_hostile_within` 輔助
- **位置**：`scripts/simulation/faction_ai_system.gd`

### S7d. `anon_wage` 從未由遊戲邏輯設定 ✅ 已修（2026-06-07）
- **症狀**：所有隊伍匿名薪資係數固定 1.0，`salary_system` 計算 `anon_total = anon_wage × anon_count`
- **根因**：`salary_system` 讀 `team.anon_wage`，但 faction_ai 從未寫入
- **修正**：`faction_ai_system._update_anon_wage` 依 tags 計算（MILITARY 拉高、PRODUCE/EXILE 拉低）
- **位置**：`scripts/simulation/faction_ai_system.gd`

### A2. encounter_view.gd `_max_timer` 欄位缺失（pre-existing）
- **症狀**：`unit.get("_max_timer", 10)` 永遠回傳預設值 10，計時器顯示不正確
- **根因**：`_create_named_unit` 未設置 `_max_timer` 欄位
- **位置**：`scripts/ui/encounter_view.gd:263`
- **建議**：`_create_named_unit` 加 `_max_timer` 欄位，或 encounter_view 改讀正確欄位

### S8. `p.salary` 預設未設，主遊戲 NPC 全 0 薪資 ✅ 已修（2026-06-07）
- **症狀**：`PersonData.salary` 預設 0.0，主遊戲 / world_generator / game_setup 從未設定；發薪時 ratio=0 → loyalty -= 0.03 每次
- **影響**：cadence-aware 改週發薪後加劇，NPC loyalty 1.56/年下滑
- **修正**：`salary_system._pay_salary` NPC team 自動 set fair salary（`p.salary <= 0` 時 = `_calc_fair_salary(p)`）；player team 保留玩家自訂值（0 = 玩家選擇）
- **位置**：`scripts/simulation/salary_system.gd:28-49`
- **待後續**：player team UI 加薪資輸入框（未做）

### S9. 玩家 team 名 NPC 薪資 UI
- **症狀**：玩家無法調整 named NPC 薪水，預設 0 → 自然扣 loyalty 直到叛逃
- **設計意圖**：玩家管理 loyalty 的關鍵手段（過薪換忠誠）
- **建議**：team panel 加每個 named NPC 薪資設定，顯示「目前 / 公平」比值

### S10. `named_members` 失控膨脹 ✅ 已修（2026-06-07）
- **症狀**：跑 7200 tick，Team0 `named_members` 從 2-3 暴漲到 2563 名
- **根因**：GDScript `var x: Array = team.named_members` 是 reference 而非 copy。後續 `x.append(leader_id)` 直接 mutate 原 array
- **修正**：5 個 site 全部加 `.duplicate()`：
  - `equipment_system._get_named_ids` (line 106)
  - `interaction_system._treat_wounded` (line 106)
  - `npc_combat_system` line 57、389、452
- **影響**：修前每天 ×96 增長（4 個 site × 24 hour），導致 loyalty/encounter/salary 全部計算錯誤
- **commit**：cb2171d
- **發現**：2026-06-07 game_sim_test.gd 7200 tick 跑出來

### S13. `WorldState.create_faction` Out of bounds ✅ 已修（2026-06-08）
- **症狀**：`create_faction` line 67 Out of bounds get index '0'/'2'
- **真實根因**：`game_setup._setup_explicit_teams` 順序錯誤——先 create_faction 再 build_explicit_team，導致 leader_team_id 對應 team 不存在
- **修正**：
  - `_setup_explicit_teams` 改為 3 段：build teams → create factions → 加非 leader members
  - `create_faction` 加 `teams.has()` guard（防禦性）
  - `_build_explicit_team` 移除無效的 faction member append（factions 此時尚未建立）
- **位置**：`scripts/simulation/game_setup.gd`、`scripts/data/world_state.gd`
- **發現**：2026-06-08 NPC survival merge 後浮現

### S11. Leader 死亡後無 succession ✅ 已修（2026-06-07）
- **症狀**：遭遇戰 leader 戰死 → `team.leader_id = -1`；之後 team 永遠無 leader
- **修正**：`faction_ai_system._promote_successor` 從 `named_members` 選統領技能最高者升任；`evaluate_all` 每輪檢查 `leader_id == -1 and not named_members.is_empty()` 自動觸發
- **位置**：`scripts/simulation/faction_ai_system.gd`（新函數 + evaluate_all 加判斷）
- **限制**：若無 named members 則 team 仍無 leader（合理：真正全滅）；玩家身分轉移屬 D2 議題
- **發現**：2026-06-07 game_sim_test.gd 跑出來

### S12. encounter draw 不清 state.encounter_active ✅ 已修（2026-06-07）
- **症狀**：`resolve_encounter_end` result="draw" 提早 return，沒清 encounter_active → 世界永久卡 encounter 模式，所有非遭遇戰系統凍結
- **修正**：draw 分支也清 encounter_units / encounter_active / attacker_id / defender_id
- **位置**：`scripts/simulation/encounter_system.gd:1054-1066`
- **發現**：2026-06-07 game_sim_test.gd 跑出來

---

## Movement

- **mounts/wagons 沒加速度**：`_compute_team_speed` 只算個人 effective_speed + named 加權（NAMED_WEIGHT=3）+ 傷兵；mounts 只加 carry capacity（`get_carry_capacity`），wagons 只加 carry + 地形 penalty（`WAGON_TERRAIN_MULT`）。騎兵跟步兵當前同速。
  待 spec：speed_class（步兵/騎兵/輜重）+ mount 速度 bonus + wagon 拖速 penalty。
  - **發現**：2026-06-10 combat-engagement（NAMED_WEIGHT=3 實作時）

## 待 spec（按優先排序）

| 優先 | spec | 解的問題 |
|---|---|---|
| **H** | NPC 會合/攔截 | W1 + W2（0 Combat / 0 Trade）|
| **M** | encounter-engagement 後續 | 攔截方反追（prey 預測 attacker）；戰報廣播；玩家版反應 UI |
| **H** | salary 欠薪後果 | Bug2 |
| **M** | NPC promote/train AI | W4 |
| **M** | DiplomacyAI 平衡 | Bug5 |
| **M** | multi runner schedule 注入 | Bug6 |
| **M** | 戰場 mount unit-level | encounter 騎兵 unit + 衝擊 + 機動 + 戰場死亡（mounts/wagons spec 後續）|
| **L** | mount 細分 | 戰馬/馱馬/拉車馬；輕車/重車；草地補糧；城市買飼料 |
| **M** | named 升階機制 | anon tier spec 列後續 |
| **L** | tag drift | leader / event 改 tag |
| **L** | 戰俘處置 | 賣/屠/招降 |
| **L** | 外交招募 / 雇傭軍 | 直接買高 tier anon |
| **L** | anon tier UI | team panel / 升等進度 / 死亡分檔 |

---

## 待討論（設計決策）

| 問題 | 選項 A | 選項 B |
|---|---|---|
| S1 視野門檻 | 降至 0.3（保留距離衰減） | 移除衰減，範圍內直接可見 |
| U7 Camera | 每次 tick 回正 | C 鍵手動回正 |
| D2 player 死亡 | Game Over 畫面 | 自動轉移到新角色 |
| S4 人口分裂 | 提高門檻 | demo 期間停用 |
