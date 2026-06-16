# Resolved Issues（已修歸檔）

> 從 `known_issues.md` 移出的已修項（✅）。保留根因/修法/驗證/教訓供搜尋與回歸參考。
> 仍開放的問題見 `docs/known_issues.md`。最後歸檔：2026-06-16。
> 順序依原 known_issues 優先級分區（高/中/低）。

---

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

### S3. SEASON_LENGTH=30 → 1年=5天 ✅ 已修
- **修正**：`SEASON_LENGTH = TICKS_PER_SEASON`（= 90天/季）
- **位置**：`scripts/simulation/harvest_system.gd:3`

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

### Bug7. interaction_system._try_interact Out of bounds ✅ 已修（2026-06-14）
- **症狀**：multi-sim 尾段 `interaction_system.gd:233 Out of bounds get index '5' (on base: 'Dictionary')` ×3
- **根因**：本 tick 內滅團/合併移除的 team id 仍留在 `process_on_move` 掃描迴圈 → `_try_interact` line 233 `state.teams[id]` 直接 index stale id（同 vision_system 那類 race）
- **修**：`_try_interact` 頂加 `if not state.teams.has(id_a) or not state.teams.has(id_b): return`（L3 一行守衛）
- **驗證**：warzone 2 年 multi `Out of bounds` 0（原 3）、SCRIPT ERROR 0、died=no

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

### U17. 遭遇戰旗色反了（玩家當攻擊方）✅ 已修（2026-06-14，待 run-verify）
- **症狀**：玩家發起攻擊時自家 anon 顯紅(像敵)、敵方顯綠(像友) — 直覺相反
- **根因**：`encounter_view._draw` 用 `is_enemy = team_id==attacker_id`；玩家當攻擊方時 attacker_id=自家 → 自家 anon 判敵(紅)、敵方(defender)落 else(綠)
- **修**：改按「自家隊 vs 敵隊」上色（玩家=藍/自家=綠/敵=紅），不用 attacker_id
- **自動測（2026-06-15）**：抽 `encounter_view._unit_color` static helper + ui_logic `_test_unit_color` 鎖。實際渲染色待玩測肉眼。

### U15. 遭遇戰後按鍵閃退 ✅ 已修（2026-06-14，待 run-verify）
- **症狀**：戰鬥一結束（戰後「按任意鍵離開」畫面）按鍵 → 整個遊戲閃退（2026-06-14 玩測）。
- **根因**：`text_ui_main._input` 無 overlay 守衛。`encounter_view` overlay 顯示時主畫面 `_input` 仍處理同鍵；`KEY_Q`→`get_tree().quit()` 僅由 `is_encounter_active()` 把關。U10 戰後畫面 `encounter_active=false` 但 overlay 仍可見 → 玩家按遭遇戰移動鍵 **Q** 想離開 → 觸發 `quit()` → 閃退。WASD 亦漏到 `_move_cursor` 漂移世界游標。
- **修**：`_input` 開頭 `if _encounter_view != null and _encounter_view.visible: return`（用 overlay 可見性，涵蓋戰後 active=false 視窗）。
- **連動**：U10 修引入「按任意鍵離開」提示才暴露此既有 Q=quit 衝突。
- **自動測（2026-06-15）**：ui_flow `_test_u15_overlay_input_guard`（overlay 可見→KEY_W 被吞、隱藏→移游標）鎖回歸。
- **後續風險**：`KEY_Q`→`get_tree().quit()` 在一般地圖遊玩仍是「按 Q 直接退遊戲」的危險綁定（Q 也是直覺移動鍵），建議改安全組合或移除（另議）。

### U16. 世界地圖迷霧/視野與玩家位置對不上 ✅ 真修（2026-06-16,二修）
- **2026-06-15 首修不完整**：只把列縮排改累進切變(axial 投影),但 render 仍是**整圖絕對座標 + @ 放玩家絕對位置** → 玩家偏離地圖中心時 @ 不在視窗中央。首修的 palindrome 回歸測 player 在 (4,4) 正中心 → 看似置中而誤過。玩測(2026-06-16)確認仍偏。
- **2026-06-16 真修**：`text_map_renderer.render` 改 **VIEW_RADIUS 玩家中心視窗**——以玩家為中心畫 ±VIEW_RADIUS,@ 恆在正中列/欄,地圖在底下捲。`_cell` 玩家標記恆畫(null tile 也顯 @)。
- **回歸**：`map_render_test` 改驗 @ 恆在視窗正中(玩家放偏離格,換位 @ col 不變),取代舊 palindrome(只驗中心 case 故漏)。`=== ASSERTIONS PASSED ===`。
- **教訓**：(1) 回歸測須涵蓋**非中心 case**(首修漏因測點剛好對稱)。(2) headless `--script` 中 `assert` 失敗中止在 `quit()` 前 → 進程 idle 卡死;寫測先 print 診斷再 assert。

<details><summary>原根因紀錄</summary>
- **症狀**：文字世界地圖「揭露區域（視野）與玩家位置 @ 對不上」（2026-06-14 玩測，描述為「遭遇戰視野很怪」，實為世界地圖 fog）。
- **根因**：座標系為 **axial**（`world_generator` `tile_pos = axial + radius`、movement/vision 用 axial cube 距離）。`text_map_renderer.render` 視野判定 `_hex_dist`（axial，正確）**但渲染用「奇數列縮排 2 空格」交替 stagger**——對 axial 是錯誤投影（pointy-top 正確為每列累進半格 / 先 axial→offset 轉換）。→ @-中心的視野 disc 在交替 stagger 下逐列剪切偏移，遠處對不上。
- **與本批無關**：`text_map_renderer` 非本批改動，純既有渲染 bug。
- **修向（待確認）**：render 改正確 axial→offset 投影（col = q + (r - (r&1))/2 類）或累進列偏移；屬視覺需逐步對照調，建議獨立 task 與使用者看輸出迭代。
- **優先**：M（影響可讀性，不致崩潰）。
</details>

### Bug10. 屠村 _massacre_residents 破壞 coin 守恆 ✅ 已修（2026-06-15）
- **症狀**：multi tyrant 啟用 command_schedule(Bug6 修)後,coin_eq delta 0→+60。
- **根因**：`encounter_system._massacre_residents` 兩個守恆破:(1) `attacker.anon_treasury += resident.population × 5.0` = **憑空鑄幣**(無來源);(2) resident 直接 `state.teams.erase` 但 `resident.anon_treasury` 未轉走 → **銷毀**。淨 = 鑄 − 丟 = +60。
- **隔離**：`_extract_treasury` 守恆乾淨(排除);`_force_occupy` 無 coin(排除)。
- **修**：移除 `+= pop×5` 鑄幣;改 `attacker.anon_treasury += resident.anon_treasury; resident.anon_treasury = 0`(接收 resident 公庫,守恆)。
- **驗證**：headless `Bug10 massacre conservation OK`(coin 190→190)+ 修正既有 `_test_occupy_massacre`(改驗精確接收非鑄幣)+ tyrant 端到端 coin_eq delta=−0.00。
- **教訓**：Bug6(schedule 不 fire)長期遮蔽此漏;測試保真度修好才暴露真守恆 bug。

### Bug9. EncounterSystem player_id==-1 → anon 被當玩家 ✅ 已修（2026-06-15）
- **症狀**：`advance_encounter_tick` / `_decide_action` 以 `person_id == state.player_id` 判玩家；若 `player_id==-1`（無玩家），anon（person_id=-1）全被當玩家 → 回 `player_turn` 停手 / idle
- **修**：`encounter_system` 4 處 `person_id==state.player_id` 全前置 `state.player_id != -1 and`（367/389/812/856 玩家回合/idle/pending 判定）→ player_id=-1 時 anon 不再誤判為玩家。latent 防護(現流程 player_id>=0,但無玩家 encounter 不再卡)。

### Bug6. multi runner 不注入 command_schedule ✅ 已修（2026-06-15）
- **症狀**：`game_sim_multi.gd` 只跑 advance_tick，未呼叫 `GameSetup.run_command_schedule_tick`
- **影響**：config 的 `command_schedule`（如 tyrant extract_treasury / warzone attack）全部不觸發；放大 W1/W2 觀感
- **修**：`_run_config` 加 `cmd := PlayerCommandSystem.new()` + `schedule` + 迴圈內 `run_command_schedule_tick(state, cmd, schedule, tick+1)` + fired log。**另補 `GameSetup._dispatch_command` 缺的 `extract_treasury` 分支**(原只 attack/trade/alliance/recruit/build,extract 落 `_:` no-op)。
- **驗證**：tyrant 跑出 `[Schedule] tick=240 fired extract_treasury → ok`、`tick3360 attack → ok`。
- **副產**：schedule 真 fire 後暴露 **Bug10**(attack 戰鬥路徑漏 +60 coin_eq)——原被「schedule 不 fire」遮蔽。

### D2. player person 死亡無保護 ✅ 已修（2026-06-09）
- **修正**：H spec 玩家 leader 死亡 → forced event 選繼承人；無 named member → game_over
- **位置**：`scripts/simulation/faction_ai_system.gd._handle_player_leader_death`、`player_command_system.choose_heir`
- **連動**：選繼承人期間 `advance_tick` 凍結（回 "awaiting_heir"）；無人 → 凍結（回 "game_over"）

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
