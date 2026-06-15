# Known Issues

> 最後更新：2026-06-15（對現碼驗證掃描）| 來源：動態測試 + code review
>
> **2026-06-15 驗證掃描**：對現碼核對開放項,多數已漂移。已修/過時標記:Bug2(floor 已修)、Bug5(公式已改)、Bug8(stale test)、S4(改 overflow-based)、A2(重構解)、Movement mount/wagon(已有 bonus)、D1(部分緩解)。**仍有效真 backlog**:Bug6(runner schedule)、Bug9(player_id 守衛 latent)、W4(promote/train、leader 駐留)、W3(dist tune)。
> **圖形 Main.tscn 項 moot**:`run/main_scene = TextUI.tscn` → S5/U5/U6/U7/U8/U9 等 graphical(`main.gd`/`right_sidebar`/`bottom_bar`/`popup_layer`)項凍結,復活圖形 UI 才解。

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
- **驗證（2026-06-15）**：**floor 已修**——`salary_system:65/75` 已 `maxf(coin−paid, 0.0)` → coin 不再為負。剩「欠薪後果」(發不出薪 → loyalty/離隊/anon 補充停)= 設計 spec,未做。
- **狀態**：負 coin 缺陷 ✅；欠薪後果 → 路線圖 spec

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
- **勘誤（2026-06-15）**：描述過時。現 population_system 無「pop10 分裂」,改 **overflow-based**(`check_overflow`/`_create_overflow_team`,超 cap 才溢出建團)。且症狀指 graphical `main.gd` 開局 = **moot**(TextUI 為 `main_scene`)。如仍嫌溢出太快屬另議 tune。

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

### Bug7. interaction_system._try_interact Out of bounds ✅ 已修（2026-06-14）
- **症狀**：multi-sim 尾段 `interaction_system.gd:233 Out of bounds get index '5' (on base: 'Dictionary')` ×3
- **根因**：本 tick 內滅團/合併移除的 team id 仍留在 `process_on_move` 掃描迴圈 → `_try_interact` line 233 `state.teams[id]` 直接 index stale id（同 vision_system 那類 race）
- **修**：`_try_interact` 頂加 `if not state.teams.has(id_a) or not state.teams.has(id_b): return`（L3 一行守衛）
- **驗證**：warzone 2 年 multi `Out of bounds` 0（原 3）、SCRIPT ERROR 0、died=no

### Bug8. _test_on_team_extinct_to_storage 失敗 = stale test（非碼 bug）
- **症狀**：headless `food 應進公庫` assert 失敗
- **驗證（2026-06-15）**：**非碼 bug,是測試過時**。W6 重構後 `_on_team_extinct` 只標記 `teams_pending_erase`,實際路由延到 `cleanup_extinct_teams → _route_extinct_assets`(邏輯正確,進公庫)。測試只呼 `_on_team_extinct` 沒呼 `cleanup_extinct_teams` → 路由沒跑 → assert 失敗。
- **修**：測試加呼 `fai.cleanup_extinct_teams(state)` 再斷言。assert 值(50 food/30 coin)正確,「勿動」誤解除——值對,只缺呼全路徑。無守恆風險。

### U10. 遭遇戰戰後「卡住」（敵死後）✅ 已修（2026-06-14，待 run-verify）
- **修**：`encounter_view._refresh_ui` 在 `_post_combat`/`not encounter_active` 時不再因無 player_unit early-return → 改顯戰果摘要 + `_post_combat_hint`（「按任意鍵離開」/ can_subjugate 加「[J]收編敗者」）。組字抽 static helper，ui_logic_test 覆蓋。
- **驗證**：ui_logic_test PASS；GUI 凍結觀感待人工 run-verify。

<details><summary>原根因紀錄</summary>
- **症狀**：殺光敵人後遭遇戰畫面卡住，無法離開（2026-06-14 玩測，用戶被迫關遊戲）
- **根因**：`encounter_view._refresh_ui` line 96-97 無 player_unit 即 early-return。戰畢 resolve 清空 `encounter_units`/`encounter_active=false` → `_find_player_unit` 回空 → `_refresh_ui` 提早 return → 戰後 `_post_combat`（can_subjugate=true）的「按任意鍵離開 / J 收編」提示**從未渲染** → 看似凍結（實際按任意鍵會走 `_handle_key` 戰後分支離開，但無提示）
- **觸發**：僅 `last_encounter_result.can_subjugate=true`（贏且可收編敗者）；不可收編 → `hide_encounter()` 直接退出，無此問題
- **修向**：`_refresh_ui` 在 `_post_combat`/戰畢時不因無 player_unit 就 return → 改顯戰果摘要 + 「按任意鍵離開 / [J]收編」提示
- **優先**：H（game-breaking 凍結觀感）
</details>

### U11. 戰鬥無擊中指示 ✅ 已修（2026-06-14，待 run-verify）
- **修**：新增 `WorldState.encounter_log` channel；`resolve_attack` 命中/落空/格擋/閃避各 append 一條（`init_encounter` 清空）；`sim_bridge.query_encounter_log(n)` facade；`encounter_view` 加「戰報」label 滾顯最新 6 條。只加 log，不改戰鬥結果/守恆。
- **驗證**：headless `encounter_log OK`；GUI 滾動顯示待人工 run-verify。

### U12. 互動交易跳「無資源」 ✅ 已修（2026-06-14，待 run-verify）
- **根因**：text-UI `_build_trade_str` 呼叫 offer-based `query_trade_preview`（回 `{resources, offer_preview}`），卻期望 auto-trade `interaction_system.preview_trade` 的 `{feasible, player_gives, player_gets}` shape → 永遠讀不到 feasible → 誤判「雙方均無可交換資源」。confirm 流程（`resolve_trade_direct`）本身正常。
- **修**：新增 `PlayerQueryApi.get_trade_direct_preview` + `sim_bridge.query_trade_direct_preview`，`_build_trade_str` 改用之。
- **驗證**：headless `U12 trade preview OK`（互補資源 feasible=true）；GUI 待 run-verify。

### U13. 物品欄已裝備物無卸下路徑 ✅ 已修（2026-06-14，待 run-verify）
- **修**：inv 版面改「已裝備槽（可選）→ 背包 → Team取出」三段，加 `[U]` 卸下鍵綁既有 `unequip_item`；已裝備槽前置使數字鍵可達。
- **驗證**：parse OK；卸下流程待人工 run-verify。

### U14. 遭遇戰進場人數存疑 ✅ 確認非 bug，已標總數（2026-06-14）
- **結論**：spawn 數 = `named + min(pop × armed_anon_ratio, ANON_UNIT_CAP)`，正確（armed_anon_ratio<1 → 非全員上場為設計）。headless 加公式 assert 佐證。
- **觀感補**：`encounter_view` 加「我方 X 敵方 Y」在場兵力 label，避免玩家誤以為人數錯。

### U19. 強制事件無選單 → 卡死（H, blocker, 2026-06-14 run-verify 新發現）
- **症狀**：強制事件（乞食/繼承/勒索回應等）觸發但畫面無選單，一直卡（choose_heir 還凍世界）
- **根因**：`text_ui_main._process`（154-160）pre_encounter/encounter_active 有自動進模式，**一般 `forced_interaction` 無對等自動進選單** → 只顯「⚠強制事件」hint，玩家無從回應
- **修向**：`_process` 偵測 `forced_interaction` 非空 → `cancel_advance` + 進 forced-response 模式（仿 pre_encounter）；新 `_forced_mode` + handler 列 `forced_interaction.responses` 供選

### U10b. 全 Team 死亡直接退出（edge，2026-06-14 run-verify）
- **症狀**：遭遇戰中玩家全隊死亡 → 直接退出（應走 game-over / choose_heir）
- **修向**：encounter 結算偵測玩家隊全滅 → 接 `_handle_player_leader_death`/game-over，非靜默退出。低頻 edge

### U11b. 戰報 label 未顯（U11 修了但 GUI 沒出，run-verify）
- **症狀**：`_lbl_log` 戰報已加+wire（query_encounter_log）但玩家戰鬥沒看到
- **疑因**：encounter_log 玩家戰鬥未填 / facade 回空 / label 被佈局擠出。需 GUI 查
### U12b. 交易仍跳無資源（U12 direct preview 修沒對症，run-verify）
- **症狀**：互動→交易仍誤判。direct preview 加了但 text_ui trade 流可能仍走舊 path
### U13b. 裝備穿脫僅玩家，NPC named 成員無入口（run-verify）
- **修向**：member 面板加成員 equip/unequip（equip_item slot 已支援,需 member-target UI）
### U14b. 主畫面看不到自 team 武裝數（U14 reframe + U18，run-verify）
- **症狀**：玩家想在平時 UI 看自隊武裝 anon 數,非進場後。併 U18（武裝 anon 指令）+ status 顯 armed 數

### U17. 遭遇戰旗色反了（玩家當攻擊方）✅ 已修（2026-06-14，待 run-verify）
- **症狀**：玩家發起攻擊時自家 anon 顯紅(像敵)、敵方顯綠(像友) — 直覺相反
- **根因**：`encounter_view._draw` 用 `is_enemy = team_id==attacker_id`；玩家當攻擊方時 attacker_id=自家 → 自家 anon 判敵(紅)、敵方(defender)落 else(綠)
- **修**：改按「自家隊 vs 敵隊」上色（玩家=藍/自家=綠/敵=紅），不用 attacker_id
- **自動測（2026-06-15）**：抽 `encounter_view._unit_color` static helper + ui_logic `_test_unit_color` 鎖。實際渲染色待玩測肉眼。

### U18. 玩家無法武裝 anon（UI/指令皆缺）
- **症狀**：找不到 UI 武裝匿名兵
- **根因**：`armed_anon_ratio`/`equip_order` 由 `faction_ai` 為 NPC 自動設，**玩家無指令**（grep `player_command_system` 空）→ UI 自然無入口。同 S9 調薪類缺口
- **修向**：補 `player_command_system` 設 armed_anon_ratio/equip_order 指令 → 再上 UI。屬 P3 全動作覆蓋前置（sim 側缺口）
- **優先**：M

### U15. 遭遇戰後按鍵閃退 ✅ 已修（2026-06-14，待 run-verify）
- **症狀**：戰鬥一結束（戰後「按任意鍵離開」畫面）按鍵 → 整個遊戲閃退（2026-06-14 玩測）。
- **根因**：`text_ui_main._input` 無 overlay 守衛。`encounter_view` overlay 顯示時主畫面 `_input` 仍處理同鍵；`KEY_Q`→`get_tree().quit()` 僅由 `is_encounter_active()` 把關。U10 戰後畫面 `encounter_active=false` 但 overlay 仍可見 → 玩家按遭遇戰移動鍵 **Q** 想離開 → 觸發 `quit()` → 閃退。WASD 亦漏到 `_move_cursor` 漂移世界游標。
- **修**：`_input` 開頭 `if _encounter_view != null and _encounter_view.visible: return`（用 overlay 可見性，涵蓋戰後 active=false 視窗）。
- **連動**：U10 修引入「按任意鍵離開」提示才暴露此既有 Q=quit 衝突。
- **自動測（2026-06-15）**：ui_flow `_test_u15_overlay_input_guard`（overlay 可見→KEY_W 被吞、隱藏→移游標）鎖回歸。
- **後續風險**：`KEY_Q`→`get_tree().quit()` 在一般地圖遊玩仍是「按 Q 直接退遊戲」的危險綁定（Q 也是直覺移動鍵），建議改安全組合或移除（另議）。

### U16. 世界地圖迷霧/視野與玩家位置對不上 ✅ 已修（2026-06-15）
- **修**：`text_map_renderer.render` 列縮排由「奇偶交替 stagger」（offset 慣例，與 axial 不符）改為**累進切變** `indent = "  ".repeat(y - ymin)`（axial q+r/2 投影）→ 視野 `?` 邊界成對稱菱形繞 @，@ 與視野對齊。代價：整盤右下斜（平行四邊形，axial 正確投影），地圖本身六角形故觀感正常。
- **回歸**：`map_render_test` 改驗前導空白序列對稱（V 形回文，`[16,14,12,10,8,10,12,14,16]`）；舊交替 stagger 非回文 → 抓得到。`=== ASSERTIONS PASSED ===`。
- **教訓**：headless `--script` 中 `assert` 失敗會中止 `_initialize` 在 `quit()` 前 → SceneTree 不退、進程 idle 卡死（誤判為「跑很久」）。寫測勿讓 assert 擋在 quit 前無條件路徑。

<details><summary>原根因紀錄</summary>
- **症狀**：文字世界地圖「揭露區域（視野）與玩家位置 @ 對不上」（2026-06-14 玩測，描述為「遭遇戰視野很怪」，實為世界地圖 fog）。
- **根因**：座標系為 **axial**（`world_generator` `tile_pos = axial + radius`、movement/vision 用 axial cube 距離）。`text_map_renderer.render` 視野判定 `_hex_dist`（axial，正確）**但渲染用「奇數列縮排 2 空格」交替 stagger**——對 axial 是錯誤投影（pointy-top 正確為每列累進半格 / 先 axial→offset 轉換）。→ @-中心的視野 disc 在交替 stagger 下逐列剪切偏移，遠處對不上。
- **與本批無關**：`text_map_renderer` 非本批改動，純既有渲染 bug。
- **修向（待確認）**：render 改正確 axial→offset 投影（col = q + (r - (r&1))/2 類）或累進列偏移；屬視覺需逐步對照調，建議獨立 task 與使用者看輸出迭代。
- **優先**：M（影響可讀性，不致崩潰）。
</details>

### U9. 圖形 Main.tscn UI 仍 reach-through raw WorldState（邊界債）
- **症狀**：`main.gd`/`encounter_view.gd`/`popup_layer.gd`/`debug_bar.gd` 大量 `_bridge.get_state()` 直讀 raw `WorldState`（body_parts/units/world.current_tick）→ 違反「UI 只經 player API」invariant（2026-06-14 新增）
- **狀態**：text_ui 已清（P1）；圖形 UI 未清。text-UI-only 階段不影響
- **優先**：M — 若推圖形 UI 或全面套 UI 邊界 invariant 才需解耦（範圍大,涉 encounter tactical view）。另案

### Bug10. attack schedule 觸發後戰鬥路徑漏 +60 coin_eq（2026-06-15 Bug6 修後暴露）
- **症狀**：multi tyrant 啟用 command_schedule 後,coin_eq delta 0→**+60**。schedule fire 時序:tick240/1680 extract_treasury(已驗守恆乾淨)、tick3360 **attack** → 戰鬥。
- **隔離**：`_extract_treasury` 守恆乾淨(`anon_treasury−=amt; coin+=amt`,兩者皆在 coin_eq)→ 排除。**+60 來自 attack→encounter→戰鬥**(死亡 person.coin 退團 / loot / subjugate coin 路由疑兇)。
- **成因**：schedule 從不 fire(Bug6)時此漏洞被遮蔽;Bug6 修好讓玩家發起 attack 真觸發 → 才現形。屬 W6 死亡資產守恆的遺漏分支。
- **狀態**：新發現,未修。需隔離戰鬥 coin 路由(逐段 audit attack→death→loot/subjugate)。**勿與 extract 混淆**。
- **優先**：M（守恆破,但需玩家主動 attack 才觸發,NPC vs NPC 走 npc_combat 另路徑待查是否同漏）

### Bug9. EncounterSystem player_id==-1 → anon 被當玩家 ✅ 已修（2026-06-15）
- **症狀**：`advance_encounter_tick` / `_decide_action` 以 `person_id == state.player_id` 判玩家；若 `player_id==-1`（無玩家），anon（person_id=-1）全被當玩家 → 回 `player_turn` 停手 / idle
- **修**：`encounter_system` 4 處 `person_id==state.player_id` 全前置 `state.player_id != -1 and`（367/389/812/856 玩家回合/idle/pending 判定）→ player_id=-1 時 anon 不再誤判為玩家。latent 防護(現流程 player_id>=0,但無玩家 encounter 不再卡)。

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
- **勘誤（2026-06-15）**：公式已改,描述失效。現 `d_score = (power_r−1)×0.4 + caution×0.3 − pride×0.3`(`diplomatic_ai_system:129`)——caution 現為**加**分(原記為壓制)。是否仍偏保守 **需重新量測**,勿照舊描述盲調。
- **建議**：量測現 score 分布 → 若仍少勒索再調 power_r 門檻 + 對未變局勢快取

### Bug6. multi runner 不注入 command_schedule ✅ 已修（2026-06-15）
- **症狀**：`game_sim_multi.gd` 只跑 advance_tick，未呼叫 `GameSetup.run_command_schedule_tick`
- **影響**：config 的 `command_schedule`（如 tyrant extract_treasury / warzone attack）全部不觸發；放大 W1/W2 觀感
- **修**：`_run_config` 加 `cmd := PlayerCommandSystem.new()` + `schedule` + 迴圈內 `run_command_schedule_tick(state, cmd, schedule, tick+1)` + fired log。**另補 `GameSetup._dispatch_command` 缺的 `extract_treasury` 分支**(原只 attack/trade/alliance/recruit/build,extract 落 `_:` no-op)。
- **驗證**：tyrant 跑出 `[Schedule] tick=240 fired extract_treasury → ok`、`tick3360 attack → ok`。
- **副產**：schedule 真 fire 後暴露 **Bug10**(attack 戰鬥路徑漏 +60 coin_eq)——原被「schedule 不 fire」遮蔽。

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

### D1. SoloAI 保護條件脆弱 ⚠ 部分緩解（2026-06-15 驗證）
- **症狀**：`team.leader_id == state.player_id` 在子隊分裂後可能失效
- **根因**：subteam 分裂可能重新指定 leader_id
- **位置**：`scripts/simulation/faction_ai_system.gd:_evaluate_solo`
- **驗證（2026-06-15）**：部分點已加 `named_members` fallback(`:1049` `leader_id==player_id or player_id in named_members`)+ player_id≠−1 守衛(`:141`)。但 `_evaluate_solo`(`:907`) 仍只查 leader_id → 邊緣仍脆。低優先。

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

### A2. encounter_view.gd `_max_timer` 欄位缺失 ✅ 已重構解（2026-06-15 驗證）
- **症狀**：`unit.get("_max_timer", 10)` 永遠回傳預設值 10，計時器顯示不正確
- **驗證（2026-06-15）**：encounter_view 已不再讀 `_max_timer` default;timer reset 移到 `encounter_system._max_timer()`(view `:402/:428` 註解)。原 stale 讀取消失 → 解。

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

- **mounts/wagons 速度**：⚠ 部分修（2026-06-15 驗證）。`_compute_team_speed`(`movement:138`) 現已 `× _compute_mount_bonus(team) × _compute_wagon_penalty(team)` → mount 加速、wagon 拖速**已有**。
  - **遺留**：speed_class（步兵/騎兵/輜重分類）仍缺——同隊內騎/步未分速,只算隊級平均 bonus。完整 unit-level speed_class 待 spec。
  - **發現**：2026-06-10 combat-engagement；2026-06-15 驗證 mount/wagon bonus 已實作

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
| **M** | 團 vs 團突襲優勢 | 對稱：野獸伏擊已實作（AmbushSystem，2b-2）；團對團伏擊待做 — reuse `vision_system` 偵測（潛行降 exposure / 偵查偵測）+ 攻擊方未被偵測 → 首擊/陣位優勢 + 激活 dormant `_check_night_raid`。屬階段2+ 劫掠/戰團。**注意：團伏擊用 vision 偵測，非 beast 專屬 AmbushSystem** |
| **M** | AI 目標錨（策略延續②深層） | SoloAI 承諾慣性（solo_intent 加成，spec soloai-proactive-home）止短期 flip-flop；更深的「持久 goal 錨」（隊有慢變長期目標如稱霸/安身/致富，task 選擇朝 goal-aligned 跨多 tick）= 接 dormant `npc_ai.get_goal_task_override`。**先量測承諾慣性夠不夠再做**。**極克制 — 一個慢變 goal 欄位+偏好加成，非多層規劃器**（防戰略引擎無底洞） |
| **M** | 山村採礦換糧特化經濟 | 山地 food regen 低（種田餵不飽），真實山村靠採礦/畜牧→交易換糧（進口糧）。現食物模型只「收本地糧」→ 山村必餓。需缺糧村自動 trade ore→food / 進口糧 AI。階段3+ 經濟深度。現階段 explicit 村用 `outpost.terrain` 釘可農地規避 |
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

### U20. 遠端 demand_tribute 對玩家 spam ✅ 已修（2026-06-14 run-verify）
- **症狀**：Team5 在 (7,10) 對玩家 (4,4) 隔空 demand_tribute，每幾 tick 重寫 forced_event spam（玩家未動）
- **根因**：`diplomatic_ai_system.try_proactive_diplomacy` 遍歷 `team_discovered`（所有已發現隊，非同格）→ 隔空提案，違反 invariant「外交/徵收需同格」；且玩家路徑漏設 reject_cooldown → forced_event 超時清掉後無限重發
- **修**：(1) proactive diplomacy 加同格 gate `other.tile_pos != self_team.tile_pos → continue`（守不變量，對齊 process_on_move 同格外交）；(2) 玩家路徑補設 `diplomacy_reject_cooldown`
- **連動**：同格 gate 降 NPC 遠端外交頻率（本就違規），NPC 外交改靠 process_on_move 同格觸發。頻率變化待量測
- **自動測（2026-06-15）**：headless `_test_u20_proactive_same_tile_gate`（遠端隊不得隔空提案 + 同格正控）+ `_test_diplomacy_reject_cooldown` 鎖。

### U21. 互動選單超過 9 項無法選 ✅ 已修（2026-06-14 run-verify）
- **症狀**：互動選單（forced 回應 + pending 目標 / 行動清單）>9 項時，數字鍵只 1-9，第 10+ 項選不了
- **修**：互動模式加分頁 `_interact_page`，`[,]`上頁 `[.]`下頁，每頁 9 項 renumber 1-9，num 含頁偏移；target-list 改 forced→pending 合一清單（全域索引對齊 handler）。進互動/選目標/Esc 重置頁
- **待 run-verify**
