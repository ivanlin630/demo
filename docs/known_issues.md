# Known Issues

> 最後更新：2026-06-12（馬爾薩斯修正 2 年驗證）| 來源：動態測試 + code review

---

## 🔴 高優先（影響基本可玩性）

### W5. Task latch 凍結世界 ✅ 大部分已修（2026-06-13）
- **症狀**：TeamTrace 量測 90 天，92% team-time 卡在不釋放的 survival(return_home/乞食 p80) + panic(逃跑 p70)。生產性 task 僅 8%。世界非窮而是癱瘓（T1 囤 mat 1622 卻凍死、T2 糧 34 天坐死）。
- **根因**：`_evaluate_survival` 一進 survival 就 early-return 不釋放；`_has_active_threat` dist_factor floor 0.1 + 小地圖逃不到 5 格 → 永威脅；乞食無施主空轉 latch；餓死團 pop floor 1 不清除成空殼。
- **修**：survival 糧恢復釋放(hysteresis 7天)、threat dist_factor floor→0 + 逃跑 5天 timeout、乞食無施主釋放、餓死 pop→0 + tick末單點 erase。逃跑 217→32、乞食消、攻擊 8→82。
- **發現**：TeamTrace 遙測（scripts/debug/team_trace.gd，gated game_sim_test 每日 dump）

### W6. 死亡路徑資產不守恆 ✅ 已修（2026-06-13）
- **症狀**：latch 修好啟用死亡後，multi coin_eq delta game_sim_test -200 / merchant -150（~5%）。
- **根因**：(1) 戰死 `persons.erase` 連 person.coin 銷毀；(2) **團死在地圖外格**（config spawn 超出 radius，如 merchant Team4/7 @(7,7)）→ `_route_extinct_assets` tile==null 分支清資產不路由（merchant -150 = oreS 5+25=30×5 完全吻合）。
- **修**：戰死 person.coin 退回團；tile==null → `_nearest_valid_tile` 擴環找最近有效格路由（守恆）。
- **驗證**：4 config coin_eq delta 全 0.00、ALL INVARIANTS PASSED。
- **遺留**：config 在 radius 外 spawn team（(7,7) 超 radius 4）為獨立 config/世界生成問題，待查。

### W3. P5 生育永不觸發 — reaction 權重結構性輸分 ✅ 已修（2026-06-13 economy-bootstrap）
- **症狀**：COLLECT_RATE tune 後多 team 糧緩衝 100+ 天（7 天盈餘門檻遠超），2 年 multi 生育/長大成人 = 0
- **根因**：`_score_breed` max ≈ 0.5（0.4 + 醫療×0.1），P2_produce active=0.6+、P1_comply 忠誠高可達 1.0 → P5 永不中選；且 minor cap = `int(pop×0.2)` → pop≤4 cap=0
- **修**：P5_breed 移出 `_evaluate_person`/`_apply_reaction`（脫離 winner-take-all），改 `_evaluate_life_events` 獨立層（與行動反應並行，機率 roll `BREED_BASE_CHANCE`=0.15 + 醫療×0.1）；cap 改 `maxi(1, int(pop×0.25))`
- **驗證**：2 年 multi 長大成人 0→**39**；game_sim_test 60→46 止跌
- **遺留**：生育仍受 surplus gate（food > pop×2.4×7）限制 → 餓肚軍閥團（food=0/乞食）永不生育，無法逆轉軍閥型崩潰（設計上飢餓不生，但平衡待 famine spec）

### W4. Faction leader 行為性貧窮 — 建造解鎖極慢 ⚠ 部分修（2026-06-13 economy-bootstrap）
- **症狀**：2 年 multi 派建造子隊 = 0；失敗原因 log（本批新增）顯示全是 material < cost×1.5（leader material +0.2/day 涓滴，門檻 75 要爬數年）
- **根因**：leader team 常駐外面（迎戰/乞食/逃跑），不在 outpost tile → collect 收入 0；material 只靠稅/貿易涓滴
- **修（部分）**：faction leader 補「治理」回家路徑（公庫<75 + 不在家 + idle → 回家攢公庫）；自給階梯讓無 tools faction 先蓋民村→工坊→產 tools→後期軍鎮
- **驗證**：2 年設施完工 2→4（merchant 自然長出 workshop）；但限**常駐型 leader**（merchant）有效
- **遺留**：遊牧軍閥 leader（tyrant/warzone 好戰高）永遠在外迎戰，從不 idle 在家 → 治理觸發不到、建造仍 0。需 leader 駐留行為 spec（強制週期回防/或建造資金走 faction 共同出資）才能根治

### W1. NPC 0 Combat ✅ 大半解（2026-06-13 W5 latch 修復）
- **原症狀**：multi 90 天 ProsperityAttack 排程但 `[Combat Start]`/`[Hit]` = 0
- **真根因（修正）**：非「擦肩追不到」— 是 **W5 task latch**：team 凍在 survival/逃跑(p80/p70) 從不去追攻擊目標。速度差(tier 0.7-1.0 + 坐騎)本就存在，team 真的動起來就收斂得到。
- **解凍後實測**：2 年 4 config `[Combat Start]` 0→**13**。W5 latch 修復連帶解 W1。
- **遺留**：戰鬥量仍偏低（13/2年/4config）；`[Hit]` 僅 1（多數戰前投降/逃）。量級 tune + 軍閥型存活屬下一層（W4 leader 駐留 + 食物基礎），非收斂問題。

### W2. NPC 0 Trade ✅ 大半解（2026-06-13 W5 latch 修復）
- **原症狀**：trade_net 派發但 `[Market]` 成交 = 0
- **真根因（修正）**：同 W1 — latch 症狀，trader 凍住沒去追 partner。非擦肩。
- **解凍後實測**：2 年 `[Market]` 成交 0→**11**、tribute 12、aid_given 6。經濟流動起來。
- **遺留**：成交量偏低；商隊專業化貿易量待 slot/供應鏈成熟（C 期）。

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
- **勘誤（2026-06-13）**：症狀數字（0.1/tick×24）為 2026-05 舊 prototype 行為；現行 burn 為 `FOOD_PER_PERSON_PER_DAY=2.4`/人/天，斷糧後的人口死亡鏈已由 2026-06-13 famine-death spec 補實（團級 famine_days minor/anon 耗損 + named hunger→blood 餓死，grace 7 天）。

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
- **勘誤（2026-06-13）**：「player 無死亡保護」為 2026-05 舊 prototype 行為；現行 famine-death spec 下，玩家 leader 餓死（blood=0）走既有 `_handle_player_leader_death` → `choose_heir` forced event（凍結世界等選繼承人），非靜默 `player_tid=-1`。地圖全黑殘留問題如仍存在屬 UI 層獨立議題。

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

### Bug7. interaction_system._try_interact Out of bounds（baseline）
- **症狀**：multi-sim 尾段 `interaction_system.gd:233 Out of bounds get index '5' (on base: 'Dictionary')` ×3
- **狀態**：pre-existing baseline（早於 forage merge，覓食 stash 驗證確認無關）
- **優先**：L — 另案查

### Bug8. _test_on_team_extinct_to_storage 失敗（baseline）
- **症狀**：headless `food 應進公庫` assert 失敗（滅團食物未進公庫）
- **狀態**：pre-existing baseline（與覓食無關）
- **優先**：M — 滅團守恆相關，另案

### W7. 覓食 vs 乞食 仲裁（forage-foundation 遺留）
- **症狀**：`_find_forage_tile` 周圍無食物時仍回本格 → 小隊（pop≤15）恆覓食、不到乞食 Path4。枯竭區小隊空覓而非乞食富鄰
- **狀態**：2 年 multi 實測世界穩定（died=no、未顯退化）→ **暫不動，留量測**。主 session 曾試加 `best_food` 門檻使無食物回 -1,-1，但會弄紅 3 個依賴「urgent→SURVIVAL_TASK」的 baseline 測試（那些測試 setup 無食物 tile）→ 還原。要修需同步重整那批測試語意
- **優先**：L — 量測顯問題再開

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
| **M** | mount 公庫系統 | mounts 改為 outpost public_storage（採集 / stable 產出 → 公庫，team 出征前 withdraw）；同時加 outpost 鄰格 wild_horses 自動採集 |
| **M** | 設施改制 B 期（材料層）| herb / 野馬群 圖塊資源 + 戰馬/野馬分離（民用馬廄馴野馬、軍用馬廄練戰馬）+ wagons 合成（野馬+mat+tools）+ medicine 配方接 herb。依賴 A 期 spec：2026-06-12-facility-overhaul |
| **L** | 信用貨幣（勢力券）| 各勢力自行發行、互不承認；coin 維持硬通貨總量固定。等 slot 專業化讓貿易量起來（C 期驗證）後再做。敘事接點：金銀挖完 → coin 通縮 → 勢力發券的歷史動機 |
| **L** | 新礦發現事件 | 低頻事件：tile 探出新礦脈（每脈有限量）— 後期擴張動機 + 淘金熱戰爭誘因，不破壞稀缺性 |
| **L** | 裝備回收鏈 | 戰損裝備 → 廢鐵 → 折損重煉（80%）。只在未來引入「銷毀事件」時才需要（守恆審計後現無銷毀）|
| **L** | goods 消費 sink | goods 目前純財富品無功能消耗；後續可加奢侈品 → named loyalty/滿足加成 |
| **L** | 子隊居民團 leader 留/回個性評估 + 合併 | outpost-residency-ai (ii) → (iii) 升級：流民駐紮後子隊 leader 個性決定留下（合併或共處）或回母團 |
| **L** | Residency dispatch print spam | NPC AI 派子隊到 outpost 後 sub pathing 失敗 / 母團 mobile，子隊未 settle → outpost 仍 missing resident → cadence 重派；in-flight check 在 sub task 被改 idle 時失效。invariant 過，但 print 多 |
| **M** | 人口循環受窮困抑制 | minor 長大簡版已實作（每月 10% → 平民，2026-06-12）。但 multi 90 天 0 次長大：reaction 收斂後世界窮 → P5 生育的糧食盈餘條件（>7 天份）幾乎無人達標 → 無小孩可長大。需 harvest/初始糧 tune 讓富裕村能生。完整人口結構 spec（性別/生育年齡）仍待 |
| **M** | task 優先權仲裁（Spec A）| current_task 被 5+ 系統互蓋（reaction bridge / faction goals / strategic dispatch / threat / survival），白名單散落。設計已討論（優先表 100 戰鬥/80 存亡/70 威脅/60 玩家/50 派遣/30 勢力/10 閒置 + 每層釋放條件），待 reaction 收斂後實作 |
| **M** | trade 三層問題殘餘 | TASK_TRADE 加入 faction_ai:660 exclusion（1 行）；trade partner 改限「tile 上有居民團」；DiplomacyAI reject cooldown；Equip print diff check |
| **M** | unrest / 抗命 玩家可見性 | unrest 完全沒露出 player API/UI。自家 team → team_stats 加欄位；同 faction → intel unrest_est；外人 → 躁動傳聞 message。[抗命] 事件玩家通知。等 UI batch |
| **L** | NPC 對 NPC 抗命 | arbiter 抗命窗口只開「50 挑戰玩家 60」；NPC leader 對 NPC 上級命令的抗命（50 vs 50 個性判定）後續另議 |
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
