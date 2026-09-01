# Resolved Issues（已修歸檔）

> 從 `known_issues.md` 移出的已修項（✅）。保留根因/修法/驗證/教訓供搜尋與回歸參考。
> 仍開放的問題見 `docs/known_issues.md`。最後歸檔：2026-06-16。
> 順序依原 known_issues 優先級分區（高/中/低）。

---

### B-1. 收留撞 pop_cap：扣糧成功但 0 人併入 + msg 謊報 ✅ 已修（驗證 2026-06-19 #3）
- **症狀**：`_accept_join_request` 先用意圖值 `from_team.population` 算 cost/joined 再 merge；capacity<=0 時 merge transfer=0（沒人進）但食物已先扣 → 憑空蒸發 + msg 謊報併入人數（守恆紅線）。
- **修**（player_command_system.gd:817-841，雙保險）：(1) merge 前驗容量 `will_join<=0 → return ok:false「隊伍已滿」`（撞滿直接拒，不扣糧）；(2) 實際 cost 改 merge 後量 delta（`joined = pt.population - pop_before`，`food -= JOIN_ONBOARD_MEAL × joined`）→ 食物按真實併入扣、msg 與 payload 報實際 joined。
- **驗證**：`_test_join_request_cap_capped`（headless_test.gd:593，撞滿 → joined=0 / spent<0.01 / ok=false）+ 部分容量測試（joined 與 reported 一致）；headless 全綠、coin_eq 守恆。
- **教訓**：守恆量測要綁「實際 mutation 後 delta」，不可用「意圖值」預扣——merge/transfer 受容量截斷時意圖≠實際。

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

---

## ★⑦群批次歸檔：43 條從 `known_issues.md` 移出（2026-09-02）

> ★**母體來源**：`docs/measurements/2026-09-02-knownissues-triage-grouping.txt` 的【群⑦ 已結案／純紀錄】欄 ＝ **43 條**。
> ★★**它們的共同性質**：對「這條在等什麼」的答案是【不等】——已收束的 arc／「保留原文供溯源」／已併入他條／ABANDON／真根定案。
> ★★★**而它們留在 known_issues 的代價**：每個 session 開場都掃到它們，而它們不是待辦。
>
> ★**hash 有兩型，★★別把 B 當結案證據**：
> - **A（8 條）** ＝ 條目【自己引用】且 `git rev-parse` 解得開的 commit。
> - **B（35 條）** ＝ 【此條目寫入 `known_issues` 的那顆 commit】（`git log -S` 找的）——★**不是結案 commit**，
>   ★★是「這段文字是誰寫進去的」。★★★**多數已結案條目的內文根本沒附結案 commit** —— 那本身是個發現。
>
> ★**檢索義務已改雙目標**（systems 已寫進 `01_architect`／`03_implementer`／`03b_measurer`）：
> 查問題要同時查 `known_issues.md` **與本檔**，否則會【重造已解的問題】。

**索引（43 條，依原 `known_issues` 行序）**

- `9f551096`(B) 原 `known_issues:53` — ★★facility 這條路的出口分布（`entry` 為分母，三種歸宿互斥且窮盡、逐日對帳）
- `1a6ab991`(B) 原 `known_issues:68` — ★★被這份資料【作廢】的三個舊讀法（★保留原文，因為它們每一個都曾經看起來很有道理）
- `77b3b681`(B) 原 `known_issues:708` — ★★食安 arc release-pass 成功判準守護（blueprint 命 2026-07-23，防誤判）
- `de6f924d`(B) 原 `known_issues:728` — ★★★武器經濟 arc 正式收斂完畢 → 併入食物安全 arc（2026-07-23 blueprint 收官裁定）
- `de6f924d`(B) 原 `known_issues:736` — arc 收斂中間態（保留脈絡）：weaponsmith 0→0 供給側（2026-07-23，已併入上方收官）
- `65d3c31e`(B) 原 `known_issues:775` — dispatch afford buffer ×1.5 承重（G1a mint 依賴，不能為 weaponsmith 降，2026-07-22 ABANDON）
- `93966d15`(A) 原 `known_issues:846` — team68 手不聽腦-STUCK + team64 RESOLVED（food-ok idle 坐死，2026-07-19，measurer 死因校準）
- `a32d7e74`(B) 原 `known_issues:867` — ② stall 對併入-rejection loop 不 fire（retry 不 re-stamp，2026-07-19，crisis-override R² 抓，crisis 已覆）
- `441c8f9a`(B) 原 `known_issues:1069` — G2 目標錨點進度
- `2933563`(A) 原 `known_issues:1078` — G3 殘缺情報進度
- `958bf1a8`(B) 原 `known_issues:1122` — 框架驗證套件（2026-06-22 framework-validation 子 session）
- `186e433`(A) 原 `known_issues:1133` — G1 供應鏈進度
- `acd6f738`(B) 原 `known_issues:1461` — 決策引擎（term-normalize T5）
- `8e42cea1`(B) 原 `known_issues:1519` — ★經濟供給鏈斷點:非糧賣單查錯 storage(framework seam,2026-07-15 full-HD 觀察揪出)
- `4c2f85cb`(A) 原 `known_issues:1531` — 經濟供給seam修正確但非binding(2026-07-15,多層調查中)
- `909798f0`(B) 原 `known_issues:1537` — ★經濟binding修正:非churn,是threat-preempt+meet_nodeal(2026-07-15 trace推翻churn假設)
- `ceccb718`(B) 原 `known_issues:1544` — ★★經濟修向定案:結構統一重構(非調threat,blueprint靜態稽核+用戶核准 2026-07-15)
- `5cb95e78`(B) 原 `known_issues:1551` — ★★經濟真根定音:私囊鎖coin循環斷(no_coin 91%,非accessor/threat,2026-07-15 measure第4次救)
- `14fa4ab9`(B) 原 `known_issues:1558` — ★★經濟真binding=merchant不co-locate+deal條件牆(coin紅鯡魚,2026-07-15 measure第5次擋)
- `b9bac5ad`(B) 原 `known_issues:1563` — ★經濟arb_hit=0根確認+fix fork(2026-07-15,重排序②merchant先)
- `160301d9`(A) 原 `known_issues:1569` — 經濟深multi-wall stack:coin大勝但供給側牆(2026-07-15,~10層measured剝殼)
- `0c9576f3`(B) 原 `known_issues:1576` — 供給牆=生產arc(統一商業merged後,2026-07-15→16 patch-gate-first中)
- `4505377a`(B) 原 `known_issues:1582` — ★供給根precise=製造設施幾乎不建(生產arc甲,2026-07-16 measurer坐實)
- `c25abfb7`(A) 原 `known_issues:1600` — Arc1 need oracle 進行中（統一路線首塊，2026-07-16）
- `71280560`(A) 原 `known_issues:1605` — Arc1 need oracle done + urgency-閾順延 arc5（2026-07-16）
- `fcf5d8c0`(B) 原 `known_issues:1622` — 框架做好 stream① 進度（2026-07-17，constitution_gate v2 + 軌2 merged 08d3a39d）
- `57b4f241`(B) 原 `known_issues:1721` — ★observer-neutrality 疑（2026-08-12、③story-audit、★systems 自審訂正=非新 leak）
- `2e00f6d1`(B) 原 `known_issues:1724` — ★★founding 降級 park（2026-08-13、blueprint WHAT 裁+用戶框挑戰「為啥一定要立國」+code 坐實=標籤非槓桿、SUPERSEDE 下方「founding 真根」的 incoherence 定位）
- `45747d0e`(B) 原 `known_issues:1727` — ★founding never-establish 真根定案（2026-08-12、③story-audit + systems code-read、supersede「立國 orphan」stale 記載）
- `6d6ccd60`(B) 原 `known_issues:1785` — ★★而 `upgd.dispatched` 仍是 0，**那不是壞掉**
- `3f03d263`(B) 原 `known_issues:1815` — ★★兩條沒接的線（★第二條才是解鎖那一半）
- `829a9a05`(B) 原 `known_issues:1828` — ★★順帶結案一個先前掛著的殘謎（blueprint 指出）
- `3f03d263`(B) 原 `known_issues:1833` — ★★★而這條 arc 的形狀第三次重複：**又是一條沒接的線**
- `e839d2b4`(B) 原 `known_issues:1997` — ★★★`assert(false, …)` 讓 headless process **掛死到逾時**（hang，不是 abort）（2026-08-25，implementer 實測）
- `f0bcfa3a`(B) 原 `known_issues:2020` — [搬自 game-design.md 2026-08-25] 情報操控接線現況（2026-07-06 盤點）
- `f0bcfa3a`(B) 原 `known_issues:2041` — [搬自 game-design.md 2026-08-25] 生產/牆移進度與量測史（2026-07-16~24）
- `f0bcfa3a`(B) 原 `known_issues:2069` — [搬自 game-design.md 2026-08-25] 貿易死因診斷（2026-07-15）
- `b149b5fb`(A) 原 `known_issues:2105` — ★★★★S3 搬遷（七支→T3 3 天）讓 `warring_states` 提前 `game_over`（2026-08-27，★可逆閥 A/B 實測）
- `22ec101e`(B) 原 `known_issues:2168` — ★LADDER 的事件喚醒【也會重排 cadence】—— 具名不對稱（2026-08-28，S4b 交件時自報）
- `fc4b80ec`(B) 原 `known_issues:2185` — ★★★「emit 了 ≠ 有人醒了」：**S4b 的 210 格證的是【閘會不會醒】**（2026-08-28 界限訂正）
- `5faaa623`(B) 原 `known_issues:2259` — ★baseline 三欄補齊（2026-09-01 記）
- `be2fc65c`(B) 原 `known_issues:2296` — ★★★known_issues 自己就是「記下來沒人回來看」的地方（2026-09-01，implementer 指出）
- `4b75a559`(B) 原 `known_issues:2339` — ★~~人口不成長：90 天只生 1 個~~ ⇒ ★★★**結案：觀測窗短於機制週期**（2026-09-01）

---

### ★★facility 這條路的出口分布（`entry` 為分母，三種歸宿互斥且窮盡、逐日對帳）

> ★歸檔自 `known_issues.md`（2026-09-02）｜原行號 `:53`｜證據 `9f551096`（型B）
```
build_candidate      = 0     ★★★每一天都是 0
resource_candidate   = 548   ★「先去買料」的 candidate，穿著 facility 的名字（貿易 516／無 task 欄 32）
empty_defer_infra    = 最大的回空類（38/12/24/15/18…）★語意是「交給 infra path 就地建」，而 build_ok = 0
empty_wrong_type     = 持續（16/10/14/9…）★而那 7 隊 30/30 都有 outpost ⇒ 有 outpost ≠ type 對
empty_already_built / empty_no_fdef / empty_pop_low = 少量
```
★**`resource_candidate` 比所有回空類加起來還多** ⇒ ★★**這支函式最常做的事是說「先去買料」。**

★★★**而這裡有一個母體盲點（implementer 自揭）**：`goal.skip.seen` 迭代的是 `team.goal_state`
⇒ **被移除的 goal 不在裡面，永遠不會被 `seen` 數到** ——
**六類 reason 每天都加得回 `seen` 是真的，但那個 `seen` 的母體已經把答案排除在外。**
⇒ **通則已立（`01_architect`）：對帳式證明母體內部無漏，不證明母體本身完整。**

### ★★被這份資料【作廢】的三個舊讀法（★保留原文，因為它們每一個都曾經看起來很有道理）

> ★歸檔自 `known_issues.md`（2026-09-02）｜原行號 `:68`｜證據 `1a6ab991`（型B）
| 舊讀法 | 為什麼廢 |
|---|---|
| ★**「蓋採料點要 50 material，而隊上恆 0~35 從未達標」＝ catch-22** | ★**材料確實會累積**：day30 有 3 隊持 250／246／160、tile 池還有 14769 ⇒ **不是「永遠達不到」，是【達到了也沒有人來拿去蓋】** |
| 「`avail` 從未超過 20」 | ★★**證據是 `cap = 30` 的樣本，而那 30 筆【全部同一個 tick】** —— 那不是分布，是一個時刻的快照 |
| 「有料的隊從不嘗試」 | ★★★**它們 day 1 之後根本沒有 build 候選可選** —— **不是不想，是沒東西可想** |

★**而「均值」那一格也要記**：day30 private 總和 811.9 / 12 隊 ⇒ 均值 74 > 閘要的 50，
**但逐隊分布是 `≥50` 只有 4/12、前 3 隊吃走 80.8%、一隊是 0** —— ★★**均值在高度集中的分布上不代表任何東西。**

### ★★食安 arc release-pass 成功判準守護（blueprint 命 2026-07-23，防誤判）

> ★歸檔自 `known_issues.md`（2026-09-02）｜原行號 `:708`｜證據 `77b3b681`（型B）

**GATE-A/二刀/食安修 measure→QA 的成功判準 = food_urg 降 / 絕境隊降 / 隊守家（脫 oscillation）——★NOT『設施建造數上升』**。因 **coin 鎖還在**（貧困陷阱兩鎖，見上 poverty-trap 洞）：食安只解 food 那把，設施 unlock 要 food AND coin 兩鎖都解。∴食安修後**建設不會跳是預期**（coin 鎖壓著 reserve_factor），別誤判成「食安修失敗」（= threat-oracle「修 X 但 Y 沒動→誤判 X 失敗」血證同型）。QA 稽核食安 release-pass 時用 food-side 判準，設施建造留給 facility-build keystone（兩鎖+means-end 一起收）。

### ★★★武器經濟 arc 正式收斂完畢 → 併入食物安全 arc（2026-07-23 blueprint 收官裁定）

> ★歸檔自 `known_issues.md`（2026-09-02）｜原行號 `:728`｜證據 `de6f924d`（型B）

food→goods→weapons→material→tools→workshop-build 整條鏈**正式收斂**。誠實記：**每一層都是真 bug 且已修**——material-buy v1/v2a（chicken-egg trade 側）、tools-demand（生產端 demand-routing）、weaponsmith cost70（afford margin）、produce_need demand-responsive（死常數→市場反應，子根②）全部 merged/授權 merge、無迴歸。**但終閘不在本輪範圍**：
- **workshop-build 終閘根 = farming 求生優先 override 碾壓（QA 終驗，正確機制非 bug）**：`_facility_score`（faction_ai:3132）farming `×(1+SURVIVAL_CRUSH×urgency²)`，食壓下 farming 壓過一切發展設施 → 隊永遠卡 subsistence farming、升不到 specialization（workshop/apothecary）→ 無 workshop → 無 tools → 無 weapon。= **食物經濟下游症狀**，連回 session 最早 starvation/desperation-economy 根。
- **★★禁 force-workshop 補丁（blueprint 明裁，違憲）**：不准繞合法求生優先權強蓋 workshop / 動 `SURVIVAL_CRUSH`/argmax。求生優先是正確憲法行為，武器 gap 的解在**上游食物安全**非強塞下游。
- implementer refine（採信）：workshop deficit ≠ goods-starve（goods target=0→min_per_res SKIP 非 binding，workshop deficit 由 tools/arrows self_use 驅≈1 高）→ 「apothecary 40× 勝」非 goods-demand 缺、亦非 argmax 因子問題，是 farming survival-crush 碾壓整個 specialization 層。
- **真下一步 = 食物地方分配/穩定性**（新 arc，meta-pattern「world-level 夠、local/team-level 不夠」第 N 次；material/goods/tools/food 同款）。詳 [[project_economy_arc]] + systems 盤點。

### arc 收斂中間態（保留脈絡）：weaponsmith 0→0 供給側（2026-07-23，已併入上方收官）

> ★歸檔自 `known_issues.md`（2026-09-02）｜原行號 `:736`｜證據 `de6f924d`（型B）

cost70+tools-demand **兩修 confirmed 有效**（measurer：afford 達 105≤天花板113、tools-demand 接 795 筆買單）但 weaponsmith 仍 0→0 → 唯一剩因 = **tools 供給全域 0**（workshop 幾乎沒蓋 + 蓋出來也產 0）= 製造業產能本身（非需求/貿易/門檻）。blueprint 授權查兩子閘，fix 範圍**等 QA §④b build-sample 判故事後**定。結構圖（systems patch-gate-first 查，file:line）：
- **子閘 A：workshop 0→1 稀少（build 側）**：workshop=civilian-only A-class；build-completion 家族（同日 civ 設施 **20-44% 完工率**調查）——construction 起手不完工（subteam abandon/timeout/資源）+ facility-argmax 選擇。連 [[project_hand_obeys_brain_arc]]。此 seed 尤糟（只 1 workshop + 晚建）。
- **子閘 B：蓋出來產 0（生產側，manufacturing_system:62-102）**。候選（QA build-sample 待判哪個主導）：
  1. **★silent MANUFACTURE-assign gate**（`:67` `if current_task != TASK_MANUFACTURE: continue` **無 tap**）：workshop tile 的 owner 沒被指派 MANUFACTURE → 產 0 **零可觀測**（決策沒選生產任務；tap-gap，違全量暫態可觀測性）。
  2. **no-material**（`:102` `noop_no_material`）：material=**tile-harvest**（forest 12/day 富、mountain 2、**plains 0.5 貧**；resource_system:35-37），**無 facility 產 material**（只 harvest+beast-hide+loot+anon）→ workshop 在 material-貧 tile（plains）或沒 harvest → 產 0。
  3. **no-demand**：recipe target≤0（need+demand 皆 0）。
- **★★兩 tap-gap（觀測盲點，會讓 QA build-sample 捏假故事）**：(1) `:67` silent MANUFACTURE gate 無 tap (2) `:102` `noop_no_material` **混淆** no-material/no-demand/already-satisfied 三因（`_run_recipe_group` 回 "" 三種都落此 tap）。→ 若 QA specimen 無法 tile-level 拆這三，需補 tap 再 measure（觀測=判決前置，憲法）。
- fix **未定**（等 build-sample）。連下方兩 build 閘（afford/tools 已解，供給側是新終閘）。

### dispatch afford buffer ×1.5 承重（G1a mint 依賴，不能為 weaponsmith 降，2026-07-22 ABANDON）

> ★歸檔自 `known_issues.md`（2026-09-02）｜原行號 `:775`｜證據 `65d3c31e`（型B）

`faction_ai_system.gd::_dispatch_facility_builder()` / `faction_ai_system.gd::_dispatch_upgrader()`（3 站含 2551）dispatch-afford `avail < cost×1.5`——嘗試降解 weaponsmith 卡建（mil 隊 material 54-80、cost 80×1.5=120），**但 buffer 承重**：降到 1.1 → owner 撥完料 depletion → **G1a 礦村→鑄幣鏈斷（headless 1 new）**。★**空解窗**：幫 80-料隊需 buffer≤1.0，但 1.1 已破 G1a（1.4 才安全）→ 無值能幫 weaponsmith 又不破 G1a。∴ **buffer 不是 weaponsmith lever**，ABANDON（revert 1.5）。weaponsmith 真解=material 貿易（mil 買料達標，Gate B trade-primary 主線）。**若日後要**：depletion-guard（降 buffer 但守 owner critical needs 如 mint 資源）拆 weaponsmith afford=另案 slice（非 cheap，需 guard 設計）。reviewer 預警「查承重」+ implementer TDD 具現（1.4 過/1.1 破）雙證。

### team68 手不聽腦-STUCK + team64 RESOLVED（food-ok idle 坐死，2026-07-19，measurer 死因校準）

> ★歸檔自 `known_issues.md`（2026-09-02）｜原行號 `:846`｜證據 `93966d15`（型A）
> 更新（transition-arbiter QA 稽核 2026-07-19）：team64 branch 93966d15 **SURVIVES**（transition fix 生效）；team68 resolved 成 food-ok-vanish。**team64/68 = transition-bypass 家族已解**（非 subteam-idle-latch 那 6 隊的獨立機制）。

measurer 校準 seed1337 14 消失真隊（`beastfix-lockpoint-deaths-7fb16350-1337.txt`）：9 TRUE-FAMINE（coherent 窮死）+ 手不聽腦-STUCK + 3 food-ok vanish。
- **team68 = 手不聽腦-STUCK（solid）**：food 4.58 **>CRISIS_FLOOR 1.5=不缺糧** + `dispatch_would_succeed=true` 卻 task idle 坐死＝控制層不執行（非餓）。
- **team64 = broken idle-latch（QA v2 讓步 2026-07-19）**：QA 前判 coherent-flee 是**抽樣偏誤**，v2 讓步 = 實為 idle-latch 坐死（food 4.17）。與 team68 同 idle-latch 型。

**★★pivot 到結構 sweep（blueprint 裁 2026-07-20）→ 再定向（finder-check 反轉 2026-07-20）**：subteam-idle v1→v2→v3 三輪 gate-tuning 治標 → 結構 sweep（15 drop 點地圖 `docs/process/hand_obeys_brain_sweep_map.md`）→ slice1 spec（D6+D1/D2 faction 成員 survival 命脈）→ **異質 R² BLOCKING**：would_succeed 只驗優先權零 finder → 真 famine 誤標手不聽腦，slice1 前提未坐實。→ **measurer 補 finder-check（d12ef6fb，RNG-free）重分類反轉圖像**：加 finder 後當前 seed1337 world **idle-freeze 手不聽腦 ≈0、finder-miss-famine ≈0**——finder 幾乎總 hit，「手不聽腦遍地」大半是 finder-blind bed 假象。**arc 真案例（crisis 5-stuck/transition team16/64）已修+merged=真救；slice1 靶 team21/65 岔出當前世界不存在。當前死隊只 team62/73=finder-hit+task=貿易+food 低=task-priority/merge 非 idle-freeze。** **★★手不聽腦 mini-arc 收工（blueprint 裁 2026-07-20）——誠實邊界**：
- **真成果（收工=真案例修好+驗證清楚，非填平所有結構洞）**：crisis-override 5-stuck 家族（`35e9ee8f`）+ transition-arbiter team16/64（`980e0b1c`），兩批經 QA 故事稽核確認真救活、已 merge。
- **slice1 DROP**（faction 成員 survival 命脈 D1/D2/D6）：當前世界 idle-freeze≈0，靶 team21/65 岔走不存在，不建大結構修。
- **未做（靶岔走，除非再冒真實例）**：slice2 D3/D4/D5（等待新領主 preemptible）+ subteam-idle D10/D11（branch `feat/subteam-idle@c53c8cbb` v3 **PARK 不 merge**，target 已 reclassify economy）。**★別讓後人以為「手不聽腦已徹底填平」——是「真案例修好」收工，D1-D15 sweep map 存 `docs/process/hand_obeys_brain_sweep_map.md` 供後續（若真實例冒出）。**
- **team62/73**（finder-hit+缺糧仍貿易/merge）→ **併入 [[經濟 arc]] scope**（食物供給/task-priority 決策品質，樣本僅 2 非急，economy arc 開工一起看）。
- **standing 工具**：finder-check bed（`d12ef6fb`）+ **per-team raw > 聚合 bucket count 判讀原則**（finder-blind bucket 假象教訓）= 本 arc 最實在副產出。
連 [[feedback_frame_challenge]]（異質審攔假象）/[[project_hand_obeys_brain_arc]]。

**★收斂（blueprint broken-count 2026-07-19）＝broken 3 隊可能兩種 DISTINCT 機制，開票別預設同根**：
- **team16 = leaderless-limbo**（已 root-cause 到 [[TaskArbiter.transition 後門]]：defection path A transition「等待新領主」→ crisis 永不 fire + 免疫繞過）。
- **team64/68 = idle-latch**（`would_succeed=true` ×300 能救沒救，task idle）——**機制未定，別預設同 transition-bypass 根**。可能 release-無-redispatch / arbiter latch / 另條 transition。**分開查根因**（QA 提醒）。

`famine_days=0 → 不在 extinct.starve metric`（∴ 不污染 cascade verdict：淨 8 coherent 窮死 + 3 broken stuck + 3 merge/combat + 2 combat）。**pre-existing 控制層 latch**（beast-fix skip 只碰 `beast_kind!=""`，真隊照跑→非 beast-fix；被 seed1337 較苦 basin 暴露）。**開票拆兩查**：team16→[[TaskArbiter.transition 後門]] HIGH 票（root 已定）；team64/68 idle-latch→獨立查根因（別綁 transition 假設）。**bed 死因標籤已批 3 分類修**（famine/stuck-task/手不聽腦，measurer 出 determinism-safe patch）——消觀測盲點（全量暫態可觀測性不變量）。連 [[project_reverse_engineering_arc]]（手不聽腦 arc 未竟殘留）。

### ② stall 對併入-rejection loop 不 fire（retry 不 re-stamp，2026-07-19，crisis-override R² 抓，crisis 已覆）

> ★歸檔自 `known_issues.md`（2026-09-02）｜原行號 `:867`｜證據 `a32d7e74`（型B）

② `_detect_survival_stall` 判 `survival_committed_option` + relief（`_stamp_survival_commit` **只在 try_set 成功時 re-stamp baseline**）。**併入被 host 拒→retry loop** 不成功 try_set → 不 re-stamp → ② stall 不 fire（team 卡 pending-join 食不回升餓死）。**crisis-override（2026-07-19）已涵蓋**（OUTCOME=famine 未緩，不管 dispatch 成敗）→ 非急。**② 那 gap（retry 該不該 re-stamp baseline）**留 backlog：realistic 應維持首次 baseline（仍卡=stall 累積）而非每 retry 重置窗。crisis 覆後低優先。連 [[project_desperation_economy]]。

### G2 目標錨點進度

> ★歸檔自 `known_issues.md`（2026-09-02）｜原行號 `:1069`｜證據 `441c8f9a`（型B）

- **G2a（關係圖 typed-edge）✅** + **G2b（野心階梯狀態 + strategic 衍生）✅**：`TeamData.ambition_rung/archetype/cap` 由 `AmbitionLadder` 從 leader values + 隊安全 derive（faction_ai cadence update）；`strategic_ai._update_faction_goals` 改讀階梯衍生 expand/trade（真 reader，非 dormant）。階梯門檻/權重全 TEST VALUE（待藍圖平衡 pass，handback `systems-to-blueprint-g2b-feel`）。
- **G2c（rung×archetype→task 映射）✅**：`AmbitionLadder.rung_task(archetype×rung)→既有 TASK_*`（零新 task）；faction_ai ambient caller 以 `PRIO_AMBIENT`(最低,只填 idle) 指派；prosperity attack 對齊（僅武力 archetype 才主動征服；**R1 2026-07-02 拔 rung>=擴張 條件**——rung 職權收窄=立國/坐穩/擴編，餬口帶狼由 `find_prosperity_prey` logistics 因子[②路程糧×③belief 歸屬]連續壓權管住，非閘）。rung1-2 三 archetype（武力 TRAIN/→prosperity、商業 TRADE、定居 PRODUCE/BUILD）。立國/稱霸細節、商業遠程商隊(依 G1)、外交/徵收深做 = 後續 refinement。
- **G2d（私人脫軌 / 血仇）✅**：`NpcAiSystem.vendetta_target` 讀 leader 最強 feud 邊 + 衝動 gate；`faction_ai` 以 `PRIO_VENDETTA`(55) 脫軌設 TASK_ATTACK（生存/威脅擋得住、prosperity 擋不住）。= G2a `relation_edges` 真行為 consumer（消 dormant）。框架債：pre-existing dormant `get_goal_task_override` 已刪（接 `project_framework_seams` dormant 清理）。
  - **OUT（後續）**：弱仇「偏置」（擴張優先挑仇人邊）= refinement；`killed` 型別深用。
- **A 類 feud 放寬 ✅（2026-06-20 merge）**：feud 由「被侵害」本身形成（劫掠/吞併/屠/背叛，非只倖存被搶）+ **滅族 faction 餘部繼承**（`spread_feud`，事件當下傳同 faction member team，**非血親**）+ severity×個性 gate（`form_feud` 唯一形成點，`FEUD_MIN=0.30` 擋噪音）。把 G2 §5 血仇傳播做實。**血親(parent/kin)傳播仍 OUT** = 待 ④Trait/家族樹（G2 無血緣邊）；獨立團(faction_id=-1)無餘部=仇隨滅消（可接受）。**emergent 量未驗**（world_sim seed77 該 run 零戰鬥；非確定性）→ 遞延 #1 經濟壓力 + scout/ambush 場景。TEST VALUE（FEUD_MIN/severity 階梯/SPREAD 0.6）待有戰鬥重量 run 校。
- **G2 主體（a/b/c/d）全完成 ✅**。後續 = 上述各 refinement + 商業遠程依 G1d + feud 血親傳播(待家族樹)。

### G3 殘缺情報進度

> ★歸檔自 `known_issues.md`（2026-09-02）｜原行號 `:1078`｜證據 `2933563`（型A）

- **G3a（belief accessor seam）✅**：`BeliefSystem.best_estimate/has_belief/uncertainty` 包 `team_intel` 單一讀 accessor；決策單 entry 讀者（diplomatic/strategic/threat/faction_ai/player_api_mapper/inquiry）全遷走它，**行為完全保留**（accessor 回現單 entry 語義，回歸零變）。de-risk G3b：屆時換 multi-claim 只改 accessor 內部，讀者零動。inquiry key 迭代（讀「對所有 tgt」）保留，僅取 entry 改 accessor。
- **G3b（multi-claim 儲存）✅**：`team_intel[obs][tgt]` 由單 dict → Array of claim（值/源/時效/可信度/失真）。寫端三處遷 `record_claim`（vision/interaction 親見 cred=1.0 同源 merge；message 傳播停 confidence-max 覆蓋 → 跨源 append 不覆蓋、同 giver 更新）。`best_estimate` 聚合最高 credibility claim、`uncertainty` 換 claim 分歧（≥2 用 population_est `(max-min)/max`）、caps 剪枝。讀端收尾 sim_bridge/inquiry（`known_targets` accessor）。讀容錯舊 Dict（test/transitional coerce 單親見 claim）。回歸：headless 全綠、coin_eq=0、InvariantAudit 0、1000 tick；行為非保留（多源/分歧為真 WHAT 變化）。
  - **TEST VALUE**：`MAX_CLAIMS_PER_TARGET=4`、`MAX_CLAIMS_PER_OBSERVER=200`、uncertainty 分歧欄選 `population_est`、relay credibility interim `(1-HOP_DECAY)*entry.confidence`（G3c 換 類型×trust×跳數×時效）。
- **G3c-1（可信度公式 + 身份信任 + 類型基準）✅**：claim 可信度從 G3b interim flat → 真公式 `effective_credibility = source_credibility(類型基準 CRED_BASE × 身份信任 × 跳數) × 時效衰減`。寫時 cred 存進 claim、讀時乘 time_decay → best_estimate 改排 effective（新鮮勝陳舊）。source_type 正名真來源類別（親見/隊友/商旅/流民，relay 依 giver 分類；distort 另存 `distorted` flag 兩維度）。**身份信任 = `TeamData.known_reputations`（team→team，覆寫 HOW spec §4 trust 邊，不開 RelationGraph person 邊）**；親見比對 relayed claim pop_est → `update_reputation(source, ±)`（準升騙降，被動查證，record_claim 內單一 choke）。修 G3b relay 雙重 HOP（hop 只算一次）。回歸：headless 全綠、coin_eq=0、InvariantAudit 0。行為非保留（best 排序變 = WHAT 可信度真公式）。
  - **TEST VALUE**：`CRED_BASE`{親見 1.0/隊友 0.8/商旅 0.6/流民 0.3}、`TRUST_FLOOR=0.5`、`BELIEF_HOP_DECAY=0.15`、`CRED_AGE_FULL_DECAY=TICKS_PER_DAY*30`、`CRED_TIME_FLOOR=0.2`、`TRUST_DELTA=0.05`、reconcile 比值門檻 [0.7,1.3] 升 / <0.4 或 >2.5 降。
  - **coupling（interim）**：known_reputations 兼外交/施捨/勒索口碑 → belief 查證 ±它 =「騙我者我也少分享」emergent-coherent（非 bug）。量測顯衝突再拆專用 trust。
  - **OUT（待）**：決策改讀 uncertainty + scout 主動查證迴路（G3d）；team_known 事件謠言 claim 化（G3d/專案）。本 plan 決策仍讀 best_estimate（多源時值改變、接口不變）；查證為被動（親見偶遇既有 relayed 才比對，無 scout dispatch）。
- **G3c-2（技能識破 + 觀察吃技能）✅**：識破 = 收 distorted claim 折 cred（信假/生疑/裁決，best_estimate 排序消費）；觀察吃技能 = 親見值噪吃觀察者偵查/戰術（cred 仍 1.0）。is_suspicious 由 G3b dormant → 分級寫（降 UI/G3d flag，非唯一效果）。TEST VALUE：DETECT_SCHEME_GAIN/SUSPECT_T/ADJUDICATE_T/SUSPECT_MULT/ADJUDICATE_MULT/OBS_SKILL_NOISE_GAIN。
  - **⚠ watch（觀察吃技能 × reconcile 交互）**：觀察吃技能 → 親見 truth 本身可能錯 → G3c-1 `reconcile_firsthand` 拿錯 truth 比對 relayed → 可能誤罰對的 source。主題 coherent（看錯怪線人），balance watch；若量測顯線人信用噪過大 → reconcile gate by observer 偵查 或降 gain（後續）。
  - **OUT（待）**：決策讀 uncertainty + scout 主動查證（G3d；裁決級「觸發查證」在此接，本層裁決 = 強折 cred + flag）；team_known 謠言 claim 化（G3d/專案）；戰術識破伏兵/佯動（戰鬥域 OUT）。
- **G3d-1（決策讀 uncertainty + 風險 gate）✅**：攻擊性 commit 讀 (best 值 + uncertainty)，`BeliefSystem.confident_enough(觀察者,目標,慎重)` gate（confidence=1-uncertainty、threshold=lerp(LOW,HIGH,慎重)）。插 faction_ai prosperity attack + survival loot、diplomatic demand_tribute。不確定+慎重→被動按兵（下次 cadence 重評）；莽者→照衝→假情報誘殺。不 gate 威脅(防禦極性反)/vendetta/結盟求和。survival loot gate 失敗 fall-through 不凍結。回歸：headless 全綠、coin_eq=0、InvariantAudit 0、200 Tick sim 仍有攻擊（不凍結）。行為非保留。
  - **TEST VALUE**：`GATE_CONF_LOW=0.0`、`GATE_CONF_HIGH=0.6`（莽者門檻 0 恆過，慎重者需 confidence≥0.6 即 uncertainty≤0.4）。
  - **OUT → G3d-2**：①scout 主動查證迴路 ✅（見下）②威脅(防禦)uncertainty-gate（延 post-measure）③team_known 謠言 claim 化（延 post-measure）。
- **G3d-2（scout 主動查證 + uncertainty cred-weighted）✅**：①**uncertainty 重定義 = credibility-weighted**：`clamp((1−top_eff_cred)+cred 加權值分歧,0,1)`（top=最強源 eff_cred；分歧=`Σwᵢ·|vᵢ−best|/(Σwᵢ·best)`）。取代舊 raw `(max-min)/max`——親見高 cred 主導壓謊→查證可收斂（舊式親見壓不掉舊假 claim → scout 永不收斂，故為 scout 前提）。既有 G3b/c uncertainty 測試核對後**仍對齊**（accessor 0.2 / multiclaim >0.5 / confidence gate / diplomacy 皆同號）。②**scout dispatch**：`_evaluate_prosperity_attack` gate-fail → dispatch `TASK_SCOUT`(move_target=prey best_estimate 位，PRIO_DISPATCH，reason "scout")、記 prosperity_target_id=prey、**不設 combat_target**；confident 後 release scout（同 PRIO_DISPATCH 擋不住自身）→ try_set ATTACK。莽者跳過誘殺不變。回歸：headless 全綠（cred-weighted/scout verification/attack gate OK）、coin_eq=0、InvariantAudit 0、1000 Tick、`[Scout]`+`[ProsperityAttack]` 並見（不凍結、收斂）。行為非保留。
  - **TEST VALUE**：`SCOUT_TIMEOUT=TICKS_PER_DAY*3`、uncertainty top/spread 權重。
  - **⚠ watch（收斂依賴時效/值接近）**：cred-weighted spread 由 best_val 正規化——假 claim 值離 best 越遠、cred 越未衰，uncertainty 越壓不下（真打架→持續 scout 直到 SCOUT_TIMEOUT release）。設計符合（矛盾大本該查不停）；若 sim 顯 scout 過頻/卡 timeout → 調 SCOUT_TIMEOUT 或 GATE_CONF_HIGH。
  - **scout 追擊精度**：`_refresh_attack_pursuit` 僅處理 TASK_ATTACK/LOOT，scout 追擊靠每 cadence 重評刷新 move_target=最新 best_estimate（prey 移出視野→走陳舊位→timeout release）。可接受（timeout 防卡），未做攔截預測（OUT）。
  - **OUT（待 post-measure）**：威脅(防禦)uncertainty-gate（§8 極性反）、team_known 謠言 claim 化（§3 獨立 arc，**告知藍圖呈報**）、斥候被抓/餵假（C 情報戰）。
- **G3-targeting（攻擊目標選擇讀 belief）✅**：G3d-2 揭的 `find_prosperity_prey`/`_find_weakest_prey` 直讀 prey 真 population/resources（god-view）缺口**已補**——選擇層 richness/weakness/pop 一律經 `BeliefSystem.best_estimate`，`has_belief` 守衛無情報不評估（禁 fallback 回真值）。weakness 吃 `armed_est`(偽裝載體,退 pop_est)、richness 經 `_belief_richness`(tier2 sum/100 → resource_scale 粗估 → 0)。自身真值照讀、位置 reachability 讀真位(物理 OUT)。**誘殺脊椎閉環**：選擇讀假 belief(本) + gate 把握(G3d-1) + scout 查證(G3d-2) + 戰鬥按真實力結算。回歸 headless 全綠、coin_eq=0、InvariantAudit 0、`[ProsperityAttack]`+`[SurvivalLoot]`+`[Scout]` 並見(不凍結)。
  - **TEST VALUE**：`_belief_richness` 粗細混排(tier2 sum/100 vs resource_scale 0-3 同尺度排序)、survival `_find_weakest_prey` food 門檻（belief 無 food_est 時不擋,以 pop 弱點為主）。
  - **OUT（延 post-measure）**：威脅(防禦)uncertainty、team_known claim 化、情報戰 C（同 G3d-2 OUT,本 plan 只攻擊選擇真值→belief 遷移）。
- **⚠ [高·measure-first·藍圖裁定中] 征服者 emergence 卡 ambition-ladder EXPAND gate — 非 targeting/reachability（2026-07-02 attack→combat measure）**：藍圖裁「measure 90% 攻擊為何不進戰鬥→修 targeting/reachability」**被 measure 證偽**。seeded warring 14400 tick 漏斗探針（`conquest_measure` funnel census + `prosp.gate_*` ladder）：**追擊距離 0.48 hex(貼身)、reached→combat ≈100%+ → 追不到/接觸轉化都不是問題**；征服者 **14400 tick 只真派出 1 次攻擊**（`conq.prosperity_reached=1`），卡在 `_evaluate_prosperity_attack` 第一關 archetype/rung gate（faction_ai:200）。**雙等根**：**R1 rung(50%)** = 主動征服需 `ambition_rung>=EXPAND`，爬 EXPAND 需持續糧盈餘 `food_flow_avg>=0.5/日`+pop>=8（ambition_ladder:54-58），但 **86.5% FORCE 隊 food_flow<0.5 卡 SURVIVE**（rung 狂 yo-yo 0→2→0）——苟活戰爭經濟無糧盈餘→爬不上征服階（= #10「食物 rung-flow-gate 壓平征服」釘成主瓶頸）；**R2 archetype(48%)** = 隊有 `征服` solo_intent 但 `ambition_archetype≠FORCE`——`select_strategic_intent` 與 `AmbitionLadder.derive_archetype` 兩判斷器讀同 leader values 48% 分類矛盾（決策域不變量違反,統一矩陣型缺口）。**狀態：✅ R1+R2 merged（2026-07-02,handback `2026-07-02-r1-threeband-r2-retire`）**——R2 disposition 共源+derive_archetype 委派（判斷器−1,desync 結構歸零）;R1a 拔 rung-food 攻擊閘;R1b logistics 因子（②路程糧×③歸屬,belief claim+deceive faction_id 誤報 channel+未知→0.5 保守 fallback）。**驗收**:③管住（believed-owned 攻擊=0）、不 over-war（隊數 75→78/attrition 降）、絕境仍搏（surv.loot 140/201）、貿易不歸零（[Market] 3→9）、specimen 狼弧可見（想=征服→做=raid 78/80）、回歸全綠。**⚠ 殘項**:①`prosperity_reached` 1→4 **未達門檻 10**（方向對量級不足;三因:R2 分布位移 FORCE 16%（義氣負項,好戰 boost 腳本半數狼落 TRADE）/91% FORCE 隊 food_flow<0.5 在 survival 域佔用/drift）→ **呈藍圖裁**（收貨 or disposition 權重平衡 pass）②assimilate 如預測=0（win_absorbed=0/P1Absorb=0,manpower cadence=下一瓶頸候選）③~~「intent=征服且被 archetype 擋」交叉探針~~ ✅已加（`prosp.desync_conq_blocked`,長窗 6 月=0 ✓）④seed42 post 對照因機器爭用未取得（assets JSON 已入庫,獨占時補跑）。
- **長窗斷鏈修進度（2026-07-03,長窗 6 月+zoom 拆根,藍圖四裁 `chain-rulings-envoy`）**：
  - ✅ **②a found_ally 凍結修 merged（`envoy-diplomacy-fi1`）**：founding timeout（距離估非死常數,MULT=6.0/floor 12 天=**步行信使追移動 target 實測收斂裕度**,TEST VALUE）+ **信使實體**（herald+子隊+撥馬+冗餘騎+自身 timeout,零新系統）+ 送達走 `handle_diplomacy_message`（belief）+ **F-I1 退役 god-view `team_strength` 接受公式（judge −1）**。驗收:T32/T34 解凍（不再跨月卡 found_ally,結構必然——母隊派信使即 release）、T32 raid 曲線恢復、S1 PASS、envoy 分佈 dispatched=5 delivered=2 accept=1 reject=1 timeout=1、回歸全綠。**行為變（pointwise 預期 DIRTY）,月線 sanity 過**。
  - **⚠ 同型缺口列管（新 invariant「凡 latch 必 timeout」CI-scan 候選）**：faction 外交 goal 路徑（`_assign_tasks`/`_assign_member_tasks` 外交→TASK_DIPLOMACY 直追）**仍無 timeout**——本波只修獨立建國路。同型,待掃全 dispatch-guard 補齊。
  - **⚠ 無馬經濟 → ★升 vision 標記（藍圖 2026-07-03 `envoy-acks-horse-vision`,經濟深化 pass 做,非現在）**：seeded 世界 mounts=0=信使/騎兵/機動 movement 模型全 dormant。vision:**馬=亂世戰略資源**（中原缺馬 vs 北方產馬=戰略不對稱）+**地形特化貿易品**（產馬區→賣馬→騎兵/信使加速,接地形特化-交易網,貿易 stakes 新維度:馬貴/軍事價值/禁運=外交武器）。連鎖:信使 timeout 縮回、E-2 騎兵、機動戰;stable 設施已在=半地基。**時機:經濟深化 pass（複利弧優先）**。暫收 (c) 步行信使慢=believable。
  - ✅ **第二波 merged（2026-07-03 `asm-deepen-hunger-raid`）**:**②b/②c 達標**——T36 餬口狼 raid 0→37-54/月（hunger_relief 只降 prosperity 搶糧路,T32 食足不誤放/T29 知足仍蹲/不 over-war attrition 47.1% vs 47.9%）;food<20 濾殺=0 窮村可俘;score 0.30→0.25。**★③ asm 誠實呈報:completion 1→0 反向（同 seed）——spec「flee-always=主斷因」假設證偽**:main 唯一 completion 靠「厚待免費餵養」（假 affordance）撐出;真掏糧後食貧狼付不起 25 天餵養（feed_quality 崩→厚待失效）+ FORCE 狼高殘忍選苛待。**=以戰養戰經濟真相:raid 搶的糧<養俘成本（目標全窮村）**。機制無 bug（headless 決定性:厚待+糧足→必同化;guard/cap/守恆全過）。**值旋鈕升藍圖裁**（INIT_MORALE 0.25/FOOD_RATE 0.5/ASSIM 窗 25 天/treatment util,handback `asm-wave-falsified`,我傾向 INIT→0.35+FOOD_RATE→0.3+壯兵 intent 厚待加權,消化期不縮）。**guard_ratio 機會成本未實體化**（調變比例非真抽 anon 出生產,後續 task）。treatment_history String→Dict（消費端型別檢過）。
  - ✅ **asm 旋鈕落地（2026-07-03 藍圖 `asm-knobs-slavery-dial` 裁,L3×3）**:FOOD_RATE 0.3/INIT_MORALE 0.35/壯兵 intent→厚待加權 0.3（means-end 接回）;ASSIM 窗不動。asm 三測過。**驗收框改三帶**（糧正狼同化成/純餬口敗=believable/殘忍照炸）,長窗二跑驗。
  - **[列管] 奴役=合法終態（用戶裁,Phase 2/3 照舊）**:處置 means-end 按意圖（要兵→同化買斷/要勞力→奴役租/要錢→贖賣/要威懾→屠）。**build gate=勞動產出 hook 要真**（俘虜幹活→採集建設真加速,否則假 affordance）。**觸發=長窗二跑見「狼卡 養不起同化↔白放 之間,中間選項缺」→提前 build**。spec §4b 已補（看守=買暴動的 dial:同化=買斷壓力遞減/奴役=租恆壓;戰時守衛抽走=暴動窗;named 剛烈寧死不為奴+頭目效應煽動,零新判斷器）。
  - ✅ **斷① merged（2026-07-03 `raid-continuity-identity-weight`）**:打草穀（候選放行成員）+ ③own 減免只給能拍板者（leader/獨立;成員 day-op 對屬村恆基準罰,`member_atk_believed_owned=0` 哨證）+ 不換腦 enforce 第一處（拆 fid 早退,成員跑戰略 intent 層;`_evaluate_solo` 全域=後續 F-D 矩陣格）。**asm 三帶框首驗過:completed=2>0（糧正狼同化達標,新旋鈕生效）**,interrupted 5 仍主導（隊死/散/逃=另鏈）。**⚠ 實作抓出 spec PRIO 誤述**:實碼 `PRIO_DISPATCH=50>PRIO_FACTION=30`,真 enforce=prosperity idle-guard+急件層（80/70/100）;殘留反向 race（成員 raid@50 先設→directive@30 搶不動至 release）**系統裁可接受**（短 op+cadence 重發+急件壓;三軌若見抗令再調）——spec 已補正註。sampling gap:該 seed 代表狼全程 fid=-1,member raid 由 unit test 直證。
  - ✅ **長窗二跑三軌 done（2026-07-03,`longwindow2-results`+assets）**:軌1 斷鏈修全過（T36 raid 活法閉環/asm 暴動歸零/T32 糧正不誤放）;軌2 泛化 ✓（seed7 by_attack=3 首 fire）;軌3 default 半死寂（過擬合 warring 密度部分成立）。藍圖裁（`dual-engine-horses`）:**雙引擎複利**（人力×糧,咬合點=佔村）。
  - ✅ **三平行軌 merged（佔村/誘因結盟/馬 slice,2026-07-03）**:
    - **佔村**:measure——「戰不落村格」否決（100% 落村格,翻旗 13 真發生）;**主斷=收益鏈**（(a) 翻旗村不為新 owner 產出:`_team_works_tile` 擋原住民 (b) 小狼贏不了圍城:pop8 圍 pop15-25 必敗=循環依賴 (c) asm scatter/escape）。option=safe foundation（means-end 佔/走並列+緊 gate,dispatch 13 翻旗 0）。**→ 收益鏈修=下一燒**（村民→受控人力歸新 owner/圍城勝算/同化鏈三段）。
    - **誘因結盟**:accept 脫 0、白嘴仍難、禮沉沒=押鏢、聯姻槽 payload 鋪好。
    - **馬 slice**:產馬帶（seeded 集中=戰略不對稱地基）、stable breed、mounts 入訂單鏈、envoy 配馬 ×2.96 速;breed 湧現 world_sim 印證,warring 因 stable 建造率低餓死=config 投資偏好非源缺陷;`horse_slice_proof.gd` 留作源回歸閘。
  - ✅ **征服收益鏈 merged（2026-07-03 `conquest-yield-chain`）**:A 翻旗接治權（capture∧subjugate 合一,三 case 含以戰立國授統領;`flip_with_rule=2`+`works_tile_pass=93`=**村產出真歸 owner,主斷閉合**）;B margin gate（真 armed≥believed pop×0.1×1.3,`kill_margin=2310` 弱狼不自殺=序列成長階梯）;C 收取鏈驗**無洞**（effective_food 現格制=既有設計+home_food 決策層 restock 閉環,**系統確認不動全域 accessor**）。Team32 糧引擎正循環（flow +3~4.7/pop 7→9）。asm (c) 殘留順記。全弧 specimen 串接=軌3 二考驗。
  - ✅ **單寫者 B 波 merged（2026-07-03 `singlewriter-chokepoints`）**:5 chokepoint（create_team S9/tags S5/readiness+solo_intent S6/faction_id S11/reputation S12）,pointwise CLEAN×3、直寫殘量 grep=0、**CI-scan pattern 每 chokepoint 附=強制閘地基**。**defect:21 stale-spec 證偽**（防禦路徑健康,純 refactor;舊「待 systematic-debug」backlog 結案）。create_team 剪 scope 保 pointwise（tile index/intel row lazy init 各歸其主）。順修 recruit_tutorial 漏 init。S6 殘量（fatigue/work_morale/current_option/strategic_assignments）列殘;**S10 stale 劃掉**（slice3 set_leader 順收）。
  - ✅ **S1 tile-bank merged（2026-07-03 `tile-bank`）**:TileBank chokepoint（banker pattern mirror,判斷器淨 0）、~40 站點收編（豁免明示:bootstrap+player F-P）、pointwise CLEAN×3、mint 走 bank+minted 軌、兩舊項結案（mint-cap 燒 ore/off-map coin 顯性 sink 入全池）、S5 mint 魂活、CI-scan 附。另型欄殘量:facility levels/stable_progress/construction_team_id/resource_cap。**→ 第 3 不變量單寫者大塊全齊,強制閘可全立**。
  - **★管線序（現位置→）**:①~~收益鏈~~✅~~單寫者B~~✅~~S1 tile-bank~~✅ → **default 組成/健康 measure（FORCE 狼=0 根因+和平隊餓崩）→ 藍圖裁生成參數 → 軌3 二考** + 強制閘全立（CI-scan 已鋪,收攏成閘）+ cadence spike 殘餘（far.total/orders_ambition）+ 矩陣剩餘（互動 F-I2/I4/I5/I7[順盤 finder 濾鏈 C 類 watch]/人力 F-M1-7/belief F-B1/B4/S6 殘量;F-P 留玩家面）②**觀測 GUI 輕 slice**（bar=看著狼崛起）③願景凍結照舊。G3 Phase D 照排。
- **⚠ [量測基建] world_sim 非確定性 — ProbeSummary 不可作回歸/歸因閘（#0b 實證）**：handoff #5「seed 77 可重現」**不成立**。同一 branch 跑兩次 ProbeSummary 大幅分歧（promote 35↔71、trust_up 14735↔3690、feud 1↔0、末月存活 8↔7），run-to-run 噪聲**遠大於** pre/post 差 → 無法對任何改動做 emergent 因果歸因。擴展既有 [[reference_multi_sanity_unseeded]]（multi drift 不可重現）至 world_sim。**系統裁定**：world_sim = **不可重現煙霧台**（驗「不崩 + ProbeSummary 仍印 + faction_found≥1」），**非平衡/回歸證據**；emergent 因果一律走**確定性 headless 場景 + 定向探針斷言**（如 #0/#0b 重量證 root 走的是 headless 階梯差，非 world_sim drift）。**含 feud plan Task3**：其 world_sim `feud_formed 對照前次` 同屬煙霧，真驗收 = gate/spread 單測（確定）。**選用後續（不阻塞）**：若要 world_sim 可作閘 → 補種子化（全 `randf()`/`randi()` 走 seeded rng）= 大改（散落多系統），post-#1 評估。
- **✅ 懸空 known_reputations 死隊已修（`2933563`，systematic-debug）**：root = `belief_system.reconcile_firsthand`(165-176) 迭代 claims 對每個 `sid`(來源隊) 呼 `update_reputation(sid)` **無 liveness 檢查**；claim 存活過來源隊（隊死後其轉述仍留別隊 team_intel）→ reconcile 跑到死隊 claim → `update_reputation(dead_sid)`(team_data:174 建 key) → 重注入死 id。`world_state.gd::erase_team()` 死時清了但 reconcile 死後重注入。**修 = `reconcile_firsthand` 加 `if not state.teams.has(sid): continue`**（死 source 不更新口碑）。world_sim InvariantViolation **556→0**。先前「補 erase_team 清 team_intel」猜錯方向（症狀非根）。**教訓**：藍圖 `state-fight-scope` 指 event_faction_defect:21 是另一回事（faction bidir，world_sim 0 violation，防禦清理非 bug）——reproduce 校正 pointer，[[feedback_verify_backlog_fresh]]。

### 框架驗證套件（2026-06-22 framework-validation 子 session）

> ★歸檔自 `known_issues.md`（2026-09-02）｜原行號 `:1122`｜證據 `958bf1a8`（型B）

- **Part 2 魂觸發 harness（`scripts/debug/framework_validation.gd`）✅**：每魂最小場景 setup→觸發→斷言 probe>0。**全 7 魂 PASS**（S1 立國/S2a feud/S2b vendetta/S3 scout/S4 ambush/S5 mint/S6 order_fulfilled）= 6 子系統魂的 plumbing 全可觸發，**無 code-level dormancy**。
- **dormant-in-default backlog（魂在預設 2yr world_sim 不觸發，非壞 = 場景稀有 / TEST VALUE 門檻高）**：定向 harness 證可 fire，但預設世界 run 計數為 0 —— 觸發鏈正確但**自然發生條件罕見**。各魂初判：
  - **`g2.vendetta_trigger`（world_sim=0，harness PASS）**：vendetta@55 被 threat@70 系統性擋住（設計優先序）。自然只在「強隊 leader 對**已不構成現役威脅的弱小舊仇**」才觸發（仇敵須被發現但 ThreatAssessment score < 門檻）。預設世界血仇多伴隨現役敵對 → threat 先佔 → vendetta 罕見。**非 bug**（符合「威脅優先於私仇」invariant）；若藍圖要 vendetta 更常見 → 調 VENDETTA_* 門檻或弱仇偏置（G2d OUT 已列）。
  - **`g3.scout_dispatch/converge/timeout`（world_sim=0，harness PASS）**：需 FORCE archetype + rung≥擴張 + attack_score≥.3 + readiness 過 + **prey belief 不確定 + leader 慎重**全同時成立。預設世界多為親見高 cred（uncertainty 低→直接攻不 scout）或莽者（低慎重恆過 gate 不 scout）。場景稀有，鏈正確。
  - **`g1.mint`（world_sim=0，harness PASS）**：需 tile `mint_level>0` + 居民 PRODUCE 隊 + `ore_gold/ore_silver>0` 同時。預設 config 無金/銀礦 tile 或無鑄幣廠設施 → 鏈空轉。**初判 = 場景/config 缺供給端**（金銀礦生成 + 鑄幣廠建造路徑未在預設世界出現）；接 G1a 鑄幣 arc，待 config 補金礦 + AI 蓋鑄幣廠評估。
  - **`g3.ambush`（world_sim=0，harness PASS）**：`Probe.ambush_check`（觀測點）僅在 encounter 敗方=攻方時呼（attacker 誤判弱敵踢鐵板）。預設 2yr 該 run 無「攻方低估 belief 且戰敗」事件 → 0。純觀測探針（不 gate AI），誘殺脊椎成立才會自然累計。
  - **fire-in-default（對照）**：`g2.faction_found=1`、`g2.feud_formed=3`、`g1.order_fulfilled=4`（+ g1/g3 經濟/belief 大量活動）在預設 2yr 自然觸發。
  - **量測注意**：world_sim 非確定性（見 §「量測基建」），上述 0/非0 為單 run 快照，run-to-run 會抖；harness 為確定性證據（魂可 fire），world_sim 計數僅佐證自然頻率粗略級別。

### G1 供應鏈進度

> ★歸檔自 `known_issues.md`（2026-09-02）｜原行號 `:1133`｜證據 `186e433`（型A）

- **G1a（鑄幣觀測：W8 機制已存 + log/驗）**、**G1b（訂單 infra + 餘→賣盤 + 需求驅動生產）✅**：訂單走 message（權威存發起隊 `active_orders`，emit 為可失真傳播副本）；`OrderSystem.tick_team_orders` faction_ai cadence 發賣盤 + 過期清；`manufacturing._run_recipe_group` 讀 `received_buy_orders` 偏向需求 recipe（訂單真 reader，非 dormant）。
- **G1d（商隊訂單驅動 + 短缺買單）✅**：商業 archetype 隊 targeting 改讀 `team_known` 訂單（`best_arbitrage_order`，殘缺情報），取代 `_find_trade_target` 的 `team_discovered` 上帝視角（後者降 fallback/標 deprecated，最終應刪）；`tick_team_orders` 短缺發買單（料/武器 < `SHORTAGE_QTY`）→ G1b infra 閉環（賣盤有 reader、生產買單有來源）。到場履約走既有 interaction 同格 trade（守恆）。撲空 = 訂單 stale → `local_value` glut，emergent 無新機制。
- **#1 訂單履約 ✅（2026-06-20 merge `186e433`）**：`OrderSystem.settle_orders`（`_resolve_market` 後按 res 淨變沖 `active_orders`、填滿移除 + 點亮 `g1.order_fulfilled`/`g1.arb_hit`）。純記帳、守恆無關。settle 機制單測證正確（履約/部分/撲空/sell 對稱）。
- **⚠ [中][measure-first] order/trade 迴路 runtime 半 inert — 商隊 runtime 不交易（履約 merge 後揭）**：履約 code 正確但 world_sim 該 run **`g1.arb_attempt=0` + `[Market]成交=0`**（整 run 零交易）→ 履約率仍 0%。**非結算 bug，根因上游**：商隊 `_merchant_trade_target`(faction_ai:1180) 的 `best_arbitrage_order` 從未回非空單 → 沒商隊被 dispatch TASK_TRADE。懷疑（**未驗，別猜** [[feedback_avoid_rabbithole]]）：①商隊沒成形/沒掛 `TAG_MERCHANT`(archetype 派生) ②`received_buy/sell_orders`(team_known order message) 空 — message 沒傳到商隊 or `MERCHANT_MAX_RANGE`(20) 外。
  - **WS-1 食物糧倉已 merge（`cde372c`）= 殺幽靈囤 + 滿了賣決策**：food→capped 糧倉、消耗合併池、food sell 單 fire。囤糧崩（4-5萬→cap≤18000）、無過餓。**剩待後續**：①**UI/面板讀 team food 誤判**——定居隊 team.resources food 現=0（全在糧倉 public_storage），面板/FoodLedger 若讀 team food 顯示「沒糧」（消耗合併池已正確不誤餓，純顯示層）→ 需改讀「team+自家糧倉」合併。②**food 買單側未做**——糧倉滿發 sell，但飢荒隊買 food 的 buy 單未補（`tick_team_orders` shortage_buy 不含 food）→ 食物經濟只半邊（賣有、買無）→ 待補 + WS-2 市集完成交易。③**食物稅語意變更**（systems ack `cde372c`）：food 進糧倉不走一般稅 split（=自存自村，語意一致），稅 split 機制測覆蓋已移 material。
  - **⚠⚠⚠ [FOUNDATIONAL ARC·藍圖裁定 2026-06-21] 經濟真根 = AI 決策框架不統一 → 做「統一決策框架」大 arc**：完整 trace 證實——商隊 T1 掛商隊 tag 但 leader 人格 derive archetype=定居 → 目標錨驅動建設/生產，跟 WS-2/2b tag-based 商隊 hoist 互搏，貿易每 ~2 天被搶走 → 震盪永不完成一趟（d8 鐵證：人在別人市集、有 arb、卻在生產）。藍圖+用戶定論：**真根更深，非經濟局部**——目標錨/faction AI/solo AI/subteam/商隊 hoist/survival **各自 latch task、用 ad-hoc TaskArbiter 優先序互搏**，無「一隊一個連貫決策」。= `[[project_framework_seams]]` 框架債現形。**決定做統一決策框架 foundational arc**（比經濟大，惠及全 NPC 行為），(a)/(b) tag-vs-人格 patch **全不做、fold 進框架輸入**。believability bar：①一隊一連貫決策（survival/野心/archetype/tag/faction/feud/經濟 全是 weigh 的輸入）②加行為=加 term 非加吵架子系統 ③服務全行為類型 ④**連貫≠同質（人格必須分歧權重，嚴禁抹平戲劇尾巴）** ⑤任一隊在幹嘛都講得出「所有驅力綜合此刻最該做這」。HOW（我）：utility 形狀 / 從 N 子系統遷移路徑（de-risk seam-first 如 G3 accessor）/ term 權重 TEST VALUE / 保人格分歧機制。**經濟=第一個驗證案例**（框架對→商隊不被搶→走完貿易→6 層 plumbing 被 exercise→履約脫 0）；arc 須含重量經濟驗證當驗收。WS-2/1/3/2b/2c/2d 六層 plumbing **不浪費**=貿易執行層，只是被破碎決策擋門外。ruling `2026-06-21-blueprint-to-systems-unified-decision-framework`。**待開 brainstorm/spec**。
    - **scope map（藍圖徹查 `state-fight-scope`）**：**Pattern A 決策吵架** = 6 平行意圖槽（current_task/task_priority/move_target[無 arbiter,22 寫點]/strategic_assignments[第二套決策槽]/combat_target[全域 mutex,一沒清=整隊凍結]/prosperity_target_id/order_target_id+order_task[一槽三義]）+ 3 生產者（faction_ai→strategic_ai 順序耦合）+ 5 cadence 時鐘自閘 + IDLE-only 重評（結構性餓死=stuck 主因）+ 雙重意圖表徵 4×（goals/strategy/strategic_goals/player_goal_override）→ **收成 1 生產者/1 意圖表徵/1 weigh 非 latch/去 IDLE-only**。**Pattern B 所有權吵架** = 6 池 delta-vs-絕對 set 互洗無銀行（loyalty ~26 寫/resources ~110 寫/anon_treasury 24 寫[貨幣守恆風險]/unrest_turns[歸零壓掉該爆叛亂]/outpost_owner 16 寫/stress·fear）→ **各設 banker 收 delta 禁外部絕對 set**。現成乾淨 owner 藍本：ambition_ladder.update / AnonCohort / RelationGraph / world_state bidir。對上 `[[project_framework_seams]]`（pipeline 縫+所有權圖縫）。
  - ~~**[可即修·藍圖定位] `event_faction_defect.gd:21` faction_id 繞 bidir helper**~~ **✅ 收（2026-07-03 單寫者收齊 B）**：機制已明——line 21 僅 faction-missing 防禦路徑，faction 不存在時無 member_team_ids 可懸空（健康路徑 line 24 `clear_team_faction` 早已處理懸空）。改走 `clear_team_faction` = 純 refactor（語意等同 `=-1`），非行為修，pointwise CLEAN。「懸空單向鏈」屬 stale-spec 誤標。
  - **⚠ [下一層·measure-first] 履約仍 0% — market_arrive 高但 board_read≈0（WS-2c 後）**：WS-2c 破 survival 鎖後 `market_arrive` 0→100-250（商隊終於到市集）、`merchant_survival` 18837→~0，**但履約仍 0%**——商隊站上市集 tile 卻 `board_read≈0`（讀不到別隊單）。下一層 root 待查：可能 ①商隊巡到的 outpost 看板無別隊單（residents 沒 post 到該板 / `_sync_board` 清掉 / `_market_pos` 登錄到別處）②時序（到達 tick vs 看板登錄）③`_nearest_market_outpost` 巡到無單的板。measure-first：market_arrive 當下印 `tile.market_orders` 總數 vs 非己單數。**別硬調**。
  - **✅ 商隊 survival 二階死鎖已破（WS-2c merge `bb63f18`）**：`effective_food` accessor 單源（team food+自家糧倉），10 決策讀者路由（survival/trade/ambition gate）。根因 = WS-1 food 搬糧倉只改消耗、漏改決策讀者（[[project_framework_seams]] 搬資源位置=所有讀者跟著走）。merchant_survival 18837→~0、market_arrive 0→100-250。世界無過餓（2 年穩 6 隊）。保留 2 讀者（`_calc_team_need` 需求常數、`_find_aid_target` 讀他隊私產）。剩履約 0 = 下一層（見上）。
  - **~~商隊 chronic survival 阻斷~~（✅ 已破 WS-2c，見上）**：WS-2b 市集可見性機制**確定性測通**（fulfilled=1，看板登錄+親讀+巡市集全鏈），但 world_sim 3 跑仍 0%。探針定位：`g1.board_register=4831`(看板運作)、`g1.seek_market=113`(商隊想巡市集)、但 `g1.market_arrive=0`(2 年僅 1 次抵達)、`g1.merchant_survival=18837`(商隊永卡 return_home/forage)。= **商隊被 chronic survival 鎖死永不出門到市集** → 機制無從 exercise。疑**二階死鎖**：商隊無自有糧源、靠貿易進食，但貿易又被 survival 鎖（要出門貿易才有糧、但沒糧只能 survival 不能出門）。**下一個 measure-first WS** = 診斷+破商隊 survival 鎖（修後 `g1.market_arrive` 0→正、履約脫 0 = 成功信號，WS-2b 碼無需再改）。留 4 永久探針（board_register/seek_market/market_arrive/merchant_survival）作驗收。**別硬調 survival 參數，先 measure-first 查二階死鎖結構**。
  - **WS-2b 市集可見性 ✅ merge（`2ee85bb`）= 解 ③訂單可見性死鎖（機制層）**：看板登錄 outpost tile + 抵達親讀(firsthand honest,守 G3)+ 商隊巡市集 fallback。確定性整鏈測通。world_sim 待商隊 survival 解（見上）。
  - **~~經濟在 world_sim 仍 0 交易~~（已定位+WS-2b 機制修，剩 survival 阻斷見上）— 訂單可見性死鎖**：本 session 探針定位——商隊收到的訂單 **100% 是自己的**（`origin==self`）→ `best_arbitrage_order` 濾掉 → arb 永空 → 無 dispatch → 0 交易。`message_system`：`emit_message` 只放發起隊自己 team_known；跨隊**只**靠 `propagate_on_arrival`（同格碰面交換+carrier 失真）。**死鎖**：交易需知別隊單 → 單只碰面傳 → 商隊只在有 arb 才出門 → 永不碰面 → 永不知 → 永不出門。**WS-2 漏修**：只做 order pos routing，沒做 order **可見性**（藍圖 B 市集本意含「市集訂單可見」）。**教訓**：WS-2 的「[Market]5→8/履約 0→1.5%」是 `game_sim_test/multi` 量的——那台隊密集碰面遮蔽此 bug → **經濟驗收必走 world_sim（散開隊），別信密集 harness**。修：WS-2b 市集看板（訂單登錄 outpost tile + 抵達親讀 firsthand honest + 商隊巡市集破死鎖，守 G3 傳播原則）plan `2026-06-21-economy-ws2b-market-visibility`。**次旗標**：全隊卡 `return_home[survival]`（有糧仍 survival）疑壓制出門，WS-2b 量測仍 0 才查。
  - **WS-2 主角已 merge（`81bd56b`）= 解 ①dispatch 角色卡死 + ②order pos routing（但 ③可見性漏，見上）**：商隊 member hoist + solo bonus（真被派貿易）+ order pos route 到固定 outpost 市集。throughput 限 → WS-3 carry cap+馬車（已 merge）。
  - **數據定論（world_sim 診斷，臨時探針已還原）+ 藍圖架構裁定**：先前「零 TRADE archetype」**猜錯**（商業穩定 2-3 隊、arb 常非空、隊真進 task=貿易）。真因 = **多因結構縫**：①是 TRADE 的隊都卡在永不呼 `_merchant_trade_target` 的角色（faction leader 跑勢力 AI / 獨立隊覓食分數蓋過 / 子團 / member 被 SETTLE+faction goal 攔截）②漫遊商隊追舊位置 → co-location 幾不可能（`[Market]成交` 2 年僅 5 次）③那 5 次沒對上單 res → fulfill 0。④食物幽靈囤真因 = `faction_ai_system.gd::_merchant_trade_target()` food 不在 PUBLIC_RESOURCES → else **uncapped**。**架構裁定**（ruling `economy-direction`）：選 **B 固定市集**（co-location 解）+ 硬上限給「滿」信號 + 糧倉 + **解角色卡死讓 NPC 決策 fire**（主角）；**腐壞砍**（上限封頂取代）。arc spec `2026-06-20-economy-marketplace-caps-design`（WS-1 食物糧倉 route/WS-2 市集+角色卡死[主角]/WS-3 carry cap+馬車/WS-4 糧倉設施）。**主從鐵則**：僕人不改 NPC 局部決策 = 砍。**caveat：單一 world_sim run（非確定 [[reference_multi_sanity_unseeded]]），他 run 可能有交易；確認「真never trade」需確定性貿易場景**。後果：#1 經濟閉環 runtime 沒真正活（腐壞/儲限即使造短缺→買單，若商隊仍不履約則經濟照空轉）→ **腐壞 plan-2 dispatch 前宜先釐清此上游**。修需 measure-first：建確定性貿易場景（兩隊互補供需 + 商隊）看 arb_attempt/成交在 code 路徑哪段斷，非長跑猜。
- **G1d 剩 refinement**：~~部分履約精細記帳~~（✅ 上述 settle_orders）、distort 是否動 order params（現假設只動 description/strength，撲空主靠過期）、信用幣/異地折價（移出 ③G3）、`_find_trade_target` 完全刪除、arbitrage 分數公式（現 proxy TEST VALUE）。
- ORDER_LIFETIME/cadence/SURPLUS 門檻/eligible res/SHORTAGE_QTY/MERCHANT_MAX_RANGE 全 TEST VALUE，待平衡。

### 決策引擎（term-normalize T5）

> ★歸檔自 `known_issues.md`（2026-09-02）｜原行號 `:1461`｜證據 `acd6f738`（型B）
- **乞食 chosen≈0**：非缺陷。BEG_FLOOR_FACTOR 故意低（乞食=最後手段低品質）+ applicable 稀有（需 has_aid_target，appl_n 8-180）。合理現象，不改 code（measure 觀察佐證）。

### ★經濟供給鏈斷點:非糧賣單查錯 storage(framework seam,2026-07-15 full-HD 觀察揪出)

> ★歸檔自 `known_issues.md`（2026-09-02）｜原行號 `:1519`｜證據 `8e42cea1`（型B）
- **現象**:order_placed 539-850/月(需求穩)但 order_fulfilled≈0(6月共1筆),arb_kill_nostock 數千/月(無貨撮)。市場撮合引擎在跑非壞,供給端拿不出貨。
- **根(code-verified,framework seam)**:manufacture 產出(`manufacturing_system._add_output:117-118`)outpost 隊→`tile.public_storage`(非 team.resources);但非糧賣單(`order_system.gd`（★L2 錨：檔級。原為行號錨，而行號跟著編輯走）)`qty=team.resources.get(res); if qty<20: continue`只讀 team.resources→定居隊製造的 goods/weapon/ore_steel 在糧倉、賣單查私產=0→**永不掛非糧賣單**→市場無貨。**同 WS-2c food accessor 家族**(資源搬位置讀者沒跟)。food 賣單已修(`order_system.gd::_tick_food_granary_sell()` 讀 granary,227筆/年);非糧漏同款修。
- **修向**:非糧賣單讀 effective 持有(team.resources+自家 public_storage,鏡射 effective_food 單源 accessor)+ 成交從正確 storage 扣。**下一層**(seam 修後若供給仍薄):material 產能 vs 消耗(measure-first 別預修)。
- **=經濟/發展 arc 經濟維核心**(生產→surplus→貿易→財富鏈接通)。blueprint 出願景→systems spec。溯源 handback `2026-07-15-systems-to-blueprint-economy-supply-root-found`。關 [[project_framework_seams]]/[[project_economy_arc]]。

### 經濟供給seam修正確但非binding(2026-07-15,多層調查中)

> ★歸檔自 `known_issues.md`（2026-09-02）｜原行號 `:1531`｜證據 `4c2f85cb`（型A）
- **seam修(effective_holding)驗證**:kill_nostock月1-3降(-22/-47/-59%=賣單看見糧倉貨,供給可見性真改善)但deals仍~0(order_fulfilled 1→2),coin三池凍,守恆PASS。**seam是真bug但非市場死的binding約束**(同絕境五層鏈,修一層露下一層)。
- **binding層候選(待漏斗證,別猜)**:①賣單貼了merchant看不到(board_read≈0 known_issue)②太遠arb_kill_range③追了到不了點(travel/co-location)④會合不成交(transfer)。deal路徑要買方/merchant到producer outpost co-locate,非只「賣單看見貨」。
- **best_arbitrage_order:252讀merchant.resources**(carried stock,同seam家族但不同path=merchant carried非producer granary)——待漏斗定是否binding。
- **處置**:seam分支`feat/supply-seam-effective-holding`(4c2f85cb)hold不單獨merge(inert避換皮),等binding層挖出bundle。measurer跑完整trade漏斗breakdown(post_sell/arb_sell_seen/arb_pick/meet_nodeal/deal)定binding站。溯源handback `2026-07-15-systems-to-blueprint-seam-not-binding`。關 [[project_economy_arc]]/[[project_established_chain]](多層調查同精神)。

### ★經濟binding修正:非churn,是threat-preempt+meet_nodeal(2026-07-15 trace推翻churn假設)

> ★歸檔自 `known_issues.md`（2026-09-02）｜原行號 `:1537`｜證據 `909798f0`（型B）
- **trace判定**(measurer T5商隊specimen逐tick):非A churn(target 28000tick僅切6次穩定)、非B(抵達print命中29次有到)、落C變體(到點co-location落空);native bed:**dispatch404→arrive僅17(4.2%),96%被逃跑/threat preempt腰斬**;到場17裡meet_nodeal12/14。
- **真binding兩層**:①**主根=96% trade被threat/flee preempt到不了**(TASK_TRADE PRIO_DISPATCH50被threat PRIO_THREAT70 override;full-HD warring威脅常在+flee剛修好加劇)=survival vs commerce張力(WHAT:貿易該對threat有韌性or危險世界殺貿易對?)②次根=到場meet_nodeal(order pos=_market_pos固定outpost,疑對方移走/供需窗變/price)。
- **line 252 accessor**(best_arbitrage_order讀merchant.resources,kill_nostock 49970)=同seam第3讀點,code確定valid,正交收全(併held seam分支)。
- **★systems churn overclaim第2次被trace/HALT救**(seam非binding→churn非binding):**先證再修紀律價值再證**。churn假設trace推翻,沒白spec。merchant移出churn家族(progress backlog#5訂正)。
- **待blueprint定主根WHAT**(threat-vs-trade韌性方向)→systems spec。溯源handback `2026-07-15-systems-to-blueprint-trade-binding-corrected`。關 [[project_economy_arc]]。

### ★★經濟修向定案:結構統一重構(非調threat,blueprint靜態稽核+用戶核准 2026-07-15)

> ★歸檔自 `known_issues.md`（2026-09-02）｜原行號 `:1544`｜證據 `ceccb718`（型B）
- **靜態稽核破死法二**:主根=結構沒統一,三層裸。accessor seam **5讀點**(非3):order_system:110/118/252 + ★trade_valuation:86 local_value(讀team.resources→糧倉貨誤估短缺→ask高/拒賣=meet_nodeal根) + decision_context:138 has_goods。我supply-seam只收3漏:86/:138/:252。**結構視圖抓measure-first撞不到的縫**([[feedback_structural_audit_complement]])。
- **主刀(結構統一,用戶核准)**:①effective_holding(state,team,res)收斂5讀點+廢absorb/spill dance ②order_system掛單層讀它+讀人格(食物留底統一走food_security_target,廢FOOD_SELL_RESERVE_RATIO/FOOD_BUY_DAYS死常數,清孤兒SURPLUS_RESERVE_MULT) ③雙resolver收斂(訂單看板vs到場ask/bid對齊,_find_trade_target+best_arbitrage_order收單一路徑) ④補accessor縫tap(躲public_storage的貨可觀測,守全量暫態可觀測性)。**大框→R²**。
- **第二刀(死法一,附帶,待量)**:387半路跑threat-preempt動態坐實掉因→定B threat韌性該修多少(商隊threat門檻人格化,PRIO_THREAT vs TASK_TRADE別flat)。
- **紀律**:先量再spec不變(死法二local_value hypothesis動態抽驗+死法一掉因坐實才spec)。line252併主刀收全。supply-seam分支(held)併入或廢重做。
- **兩刀分明**:死法二結構根(主刀)、死法一threat願景B(第二刀)。溯源handback `2026-07-15-blueprint-to-systems-economy-structural-unification`。關 [[project_economy_arc]]/[[project_unification_matrix]]/[[project_framework_seams]]。

### ★★經濟真根定音:私囊鎖coin循環斷(no_coin 91%,非accessor/threat,2026-07-15 measure第4次救)

> ★歸檔自 `known_issues.md`（2026-09-02）｜原行號 `:1551`｜證據 `5cb95e78`（型B）
- **死法二主根=no_coin 91%(24600/27020)**:買方team.resources.coin空。**code root=私囊鎖**:salary(salary_system:65-66)team.resources.coin→person.coin單向抽,person.coin唯一outflow=死亡(npc_combat:745),living named成員永不花回流;anon_treasury有extraction回收但named person.coin沒有→team.resources.coin單調枯竭→買不了→市場死。
- **★四假設全被measure/trace推翻(非binding)**:supply seam(可見性,deals~0)/merchant-target churn(target穩定trace推翻)/threat-preempt(真~6起,80.6% normal rotation,FLEE缺糧非threat)/accessor local_value(absorb+114%但<3%)。**真binding第5層=私囊鎖**。measure-first第4次擋非-binding大重構(accessor當主刀<3%=白做)。
- **真修向=coin循環(WHAT待blueprint)**:named成員person.coin該花回經濟(消費/週期回收/salary別單向枯竭)。**成員守財奴=私囊鎖病**。
- **accessor統一降級**:主刀→小follow-up(line 252/86/138/absorb真債,material +114%真小改善,非binding)。併框架債or coin修後順手。
- **Team6 execlock thrash**(死法一24筆survival↔trade)=churn家族→併backlog#5。**threat韌性B降優先**(非threat殺貿易是沒錢買)。溯源handback `2026-07-15-systems-to-blueprint-economy-real-root-siku`。關 [[project_economy_arc]]/[[feedback_symptom_vs_root_retry]]。

### ★★經濟真binding=merchant不co-locate+deal條件牆(coin紅鯡魚,2026-07-15 measure第5次擋)

> ★歸檔自 `known_issues.md`（2026-09-02）｜原行號 `:1558`｜證據 `14fa4ab9`（型B）
- **coin紅鯡魚證實**:reconcile coin新解禁370筆全落coin_ok_other_bail、WOULD_TRADE恆零(有錢照樣不成交)→coin非binding。census:person.coin(named)61-63%最大池(B對準對池但floor/rate太弱補不動team_pool才3.6%)。**coin B治標,棄(非held),coin循環願景A+B降框架債backlog**(日後市場活了才有意義)。
- **2真結構binding**:①**merchant從不co-locate**(100% co-loc買方resident,0 merchant!arb_hit=0直因=merchant travel到order pos但從不與賣方成pair;churn trace證到達但落空)=blueprint預授WHAT「merchant完成trade」。候選根:move_target(order pos=_market_pos賣方outpost)vs賣方實位不符/normal-rotation preempt。②**price/surplus/qty牆**:deals=3 vs WOULD_TRADE 560(WOULD_TRADE該→deal卻沒),成交條件本身此世界幾乎不滿足。
- **measure-first第5次**擋非-binding(seam/churn/threat/accessor/coin全非市場死主根)。市場死=多結構疊(絕境五層鏈同精神)。**待blueprint定序(merchant co-locate vs deal牆)→systems patch-gate-first→spec**。溯源handback `2026-07-15-systems-to-blueprint-coin-red-herring-real-bindings`。關 [[project_economy_arc]]/[[project_established_chain]]。

### ★經濟arb_hit=0根確認+fix fork(2026-07-15,重排序②merchant先)

> ★歸檔自 `known_issues.md`（2026-09-02）｜原行號 `:1563`｜證據 `b9bac5ad`（型B）
- **根(75到達,measurer)**:65.3%賣方漫遊離outpost(_market_pos固定outpost≠賣方實位,owner_settled_here=false)=dominant;24% owner在家仍零deal(②成交條件牆);preempt僅21.6%非主因。
- **★方法論修正**:TAG_MERCHANT本世界全程0隊!真閘=ambition_archetype==ARCHETYPE_TRADE(faction_ai:2045)。fix對象ARCHETYPE_TRADE非TAG_MERCHANT。
- **fix WHAT-fork(待blueprint)**:A追賣方belief_pos(鏡射pursuit,漫遊難追fragile,team-to-team)vs B outpost-market(貨在public_storage買方到outpost買stock免賣方在場,WS-2b infra現成,穩+像真市場,systems建議B)。市場模型WHAT:追人vs place-based。
- **序**:②merchant完成trade(通co-location)→①成交條件液化(held)→coin combo重驗。液化+coin B held不merge(下游)。溯源handback `2026-07-15-systems-to-blueprint-arb-root-fix-fork`。關 [[project_economy_arc]]。

### 經濟深multi-wall stack:coin大勝但供給側牆(2026-07-15,~10層measured剝殼)

> ★歸檔自 `known_issues.md`（2026-09-02）｜原行號 `:1569`｜證據 `160301d9`（型A）
- **coin combo大勝**:buy_no_coin 30421→27(-99.9%),coin雙向流動,私囊鎖root治對。但deal仍~1-2(未revive)。
- **層序(每層measured,修一露一)**:①供給可見性(seam)②撮合③移動④co-location(65%漫遊→market-as-place解)⑤成交條件(液化)⑥coin(私囊鎖,大勝)⑦**sell_no_surplus 51.7%(訪客到市場沒貨賣)=供給存在性最深牆**。
- **供給最深根候選**:producer產不出surplus(自用即耗/產能低)or TRADE隊無inventory累積(買低賣高需先買=chicken-egg)。=回到blueprint最初「誰生產可賣surplus」。
- **策略點(blueprint+用戶定)**:①續剝供給②重估市場模型/目標(稀缺世界本就少貿易?=設計特徵)③止血merge coin+foundation(unified-commerce巨大正確refactor+coin流+守恆,非inert,誠實標供給待續)。systems傾向3+1。
- **branch feat/unified-commerce(160301d9)**:market-as-place+液化+coin,守恆PASS,機制真fire(deal_market非零),但deals低=供給頂上。溯源handback `2026-07-15-systems-to-blueprint-coin-won-supply-wall-strategy`。關 [[project_economy_arc]]/[[project_established_chain]](深stack同精神)。

### 供給牆=生產arc(統一商業merged後,2026-07-15→16 patch-gate-first中)

> ★歸檔自 `known_issues.md`（2026-09-02）｜原行號 `:1576`｜證據 `0c9576f3`（型B）
- **市場未大revive因sell_no_surplus 51.7%**(訪客到市場沒貨賣)——掛單碼確認`surplus=effective_holding−reserve>ORDER_POST_MIN才掛`(seam已修含public_storage)→∴根=producer累積不出goods surplus。
- **根候選(systems measure中)**:①manufacture產能低(material稀/facility rare/生產鮮少選)②reserve太高(surplus never>reserve)③TRADE隊無inventory累積(買低賣高chicken-egg)。=回blueprint最初「誰產可賣surplus」。
- **決定甲/乙(measure後)**:甲=建surplus經濟(生產鏈產tradeable餘)/乙=接受薄貿易(稀缺世界本少貿易=設計特徵)。
- **孤兒函式advisory**(reviewer merge-gate標,de-patch殘留,非阻擋):生產arc順手清。溯源handback `2026-07-16-systems-to-implementer-unified-commerce-merged-done`。關 [[project_economy_arc]]。

### ★供給根precise=製造設施幾乎不建(生產arc甲,2026-07-16 measurer坐實)

> ★歸檔自 `known_issues.md`（2026-09-02）｜原行號 `:1582`｜證據 `4505377a`（型B）
- **根(measurer)**:has_facility隊恆=1(僅1隊有製造設施6月不變),8隊goods holding恒=0(從未產一單位),[Manufacture]全程6次。非material稀(surplus 417→破千)非reserve高非task-selection(TASK_MANUFACTURE dispatch 1→11隊想製造但has_facility=1每tick空轉no-op)。
- **precise=facility建造鏈存在但幾乎不產製造設施**(_evaluate_infrastructure→_pick_facility→_dispatch_facility_builder)。候選gate:①恆-hungry永建農(_pick_facility hungry→farming優先,WS-2c註定居隊food在糧倉恆hungry)②_facility_score製造太低(<門檻0.05)③builder gate(cost×1.5/advisor/pop≥6/subteam)。
- **生產arc(甲,待blueprint+用戶greenlight)**:讓製造設施蓋起→goods產出→surplus→市場供給→貿易活。接發展模型(生產/軍事/建設維度)。乙=接受薄貿易(稀缺特徵)。→greenlight則systems patch-gate-first定哪gate(可能measure一輪)→spec。溯源handback `2026-07-16-systems-to-blueprint-supply-root-facility-chain-production-arc`。關 [[project_economy_arc]]/[[project_established_chain]]。

### Arc1 need oracle 進行中（統一路線首塊，2026-07-16）

> ★歸檔自 `known_issues.md`（2026-09-02）｜原行號 `:1600`｜證據 `c25abfb7`（型A）
- **S1 done**（branch feat/need-oracle @ c25abfb7，Tier1 5 綠，零產線影響=fallback 防中間態設計生效）。**S2-S5 remaining**（fresh session 續，ctx 衛生）。
- **核心架構**：NeedOracle 獨立新 module（NeedHierarchy 零改），出兩量 `need_keep`(自用+供應鏈,保留向)+`demand`(貿易,流出向);reader 組合 生產=keep+demand·可賣餘量=holding−keep·賣=min(餘量,demand)（R² 異質框外審抓單標量混反向缺陷後修）。
- **next=S2** 供應鏈 gap+gating+多配方→S3 貿易 demand 非幽靈→S4 共讀兩量+per-recipe 停產+TARGET_PER_POP 退役+SURVIVAL_CRUSH reconcile→S5 溢出落地雙 sink+migrate。spec v2=唯一真相。關 [[project_economy_arc]]。

### Arc1 need oracle done + urgency-閾順延 arc5（2026-07-16）

> ★歸檔自 `known_issues.md`（2026-09-02）｜原行號 `:1605`｜證據 `71280560`（型A）
- **Arc1 need-quantity oracle S1-S5 core done**（branch feat/need-oracle @ 71280560,measurer full-HD 驗中）：NeedOracle 兩量(need_keep 自用+供應鏈/demand 貿易)、manufacturing 需求驅動、per-recipe 停產、reserve→need_keep、溢出雙 sink 落地守恆、TARGET_PER_POP 退役。早訊號:矛盾率 0.716→0.667、goods 死鎖解、trade 活、CoinAudit=0×多輪、生產框架 crossover reconcile。
- **★scope 釐清(implementer 抓)**:「散 need」混兩軸——**need-quantity**(該留多少:farming×14/reserve/TARGET)本 arc 收斂✓;**urgency-天閾**(DESPERATION/WARNING/RECOVER/SLACK/URGENCY days-常數,離餓幾天驅 survival 排序)=獨立 urgency 軸,量≠急,留 NeedHierarchy 零改動→**順延 arc5 死常數人格化**(它們是決策門檻常數該人格化)。migrate 進 NeedOracle=category error。
- deal 側成交牆(死法②)可能仍需專 arc(貿易 need 綁 deal 是供給側誠實,成交起否待 measurer)。關 [[project_economy_arc]]/[[project_unification_matrix]] arc5。

### 框架做好 stream① 進度（2026-07-17，constitution_gate v2 + 軌2 merged 08d3a39d）

> ★歸檔自 `known_issues.md`（2026-09-02）｜原行號 `:1622`｜證據 `fcf5d8c0`（型B）
- **constitution_gate v2 merged**:抓全閘型(值閘 RNG/override/硬門檻 + 控制流閘 手派route/散落入口/近似重複),baseline-freeze enumerate 93閘,綠=baseline全gate-ok=零殘留可證。baseline 現 91(37 gate-ok + 54 待軌1/triage)。
- **de-patch 軌2 值閘 merged**:閘1 _threat_recent→intent軍備/閘5 tribute FLEE→膽識絕望秤/閘7 calc_attack_score孤兒刪/try_proactive陡化。結構正確+無回歸,gate grep證消失。
- **★fast-follow(非blocker)**:①軌2分化 multi-seed confirm(militancy/低慎重 try_proactive/tribute修測法)——militancy綁**軍事設施thinness**(軍事設施幾乎不建,同生產框架facility-thin,production域separate)②守measure前不宣victory,分化待confirm。
- **剩零殘留工**:**軌1 seam#1 控制流收斂**(route×10+dispatch_entry收斂成一encounter eval+registry=真統一+擴充,大slice)+ 其餘54閘triage/de-patch → gate baseline續縮向零。stream② seam#2/#3(facility_deficit資料驅動/sim_runner registry)+ stream③情緒接線。關 [[project_unification_matrix]]。

### ★observer-neutrality 疑（2026-08-12、③story-audit、★systems 自審訂正=非新 leak）

> ★歸檔自 `known_issues.md`（2026-09-02）｜原行號 `:1721`｜證據 `57b4f241`（型B）
measurer 揭 specimen 手動選不同 team_id → 世界分岔（teams130 vs 148）。★systems 首判「SpecimenTracer re-query randf leak 第4 instance」**over-claim 訂正**：`specimen_tracer.gd:1 @observe-pure`（observability_gate 護）+ `:57 _begin_observe()` **已 suppress_observe_noise 包住 :53 randf**（RNG-neutral）→ **tracer 本就中性、非新 leak**（我漏讀 :57 suppress wrap=[[feedback_fileline_vs_interpretation]]）。真相=**manual 直設 `specimen_team_ids` 繞過 `setup_from_env`（跳過 `SpecimenTracer.reset()`+enabled 序）的 confound**（[[feedback_observer_no_global_rng]] 第5 instance「手工繞 canonical helper 是岔開常見源、非 infra bug」）；measurer isolation 混淆 manual-vs-helper 與 id-content、未純測 id-content。**非 HIGH 新 bug**（已 mitigate：measurer 改回永遠用 helper + 檔頭危險註記）。若要 100% 坐實可加「helper-with-leader-ids env vs strided」純 id-content isolation，但 tracer 可證中性下 ROI 低。

### ★★founding 降級 park（2026-08-13、blueprint WHAT 裁+用戶框挑戰「為啥一定要立國」+code 坐實=標籤非槓桿、SUPERSEDE 下方「founding 真根」的 incoherence 定位）

> ★歸檔自 `known_issues.md`（2026-09-02）｜原行號 `:1724`｜證據 `2e00f6d1`（型B）
established=0 **不是** 世界死氣的真根=**被標籤騙**。blueprint grep 驗 `is_established` 全引擎只 gate 三處：`faction_ai_system.gd::find_prosperity_prey()`（戰爭成本−0.3）/ `distortion_engine.gd`（★L2 錨：檔級）（唬人招牌選最大 established）/ 宣告效果=國名+公告（:5093）——**零經濟/生產/擴張解鎖=立國是章非槓桿**。因果=**強大→立國、非立國→強大**。∴established=0 是章沒蓋非世界壞；世界死氣真因=**沒人吃飽（famine）+沒人打仗（零戰死）**。#3① 立國 gate 門檻 vs leader-gen mismatch（下方定案）**技術描述仍對但降級 park**（強者上位有獨立價值=未來 arc、非現在解、用戶 b/c 選項撤回）。修正後 fix 序：①famine ②migrant belief 死角 ③零戰死（待 famine 連動：吃飽→readiness 回→打得起來）④立國 park。

### ★founding never-establish 真根定案（2026-08-12、③story-audit + systems code-read、supersede「立國 orphan」stale 記載）

> ★歸檔自 `known_issues.md`（2026-09-02）｜原行號 `:1727`｜證據 `45747d0e`（型B）
established=0 真根**非** goal orphan（立國鏈已接：gate `faction_ai_system.gd::_assign_tasks()`→emit `:1045`→`faction_ai_system.gd::_declare_established()`），**是 gate 門檻 vs leader-gen 分布 mismatch=structural**：立國 gate `cmd≥0.4 + 野心≥0.6`（+readiness≥0.7/member≥2、後兩者從沒擋），but 凡人 leader-gen `統領∈[0.1,0.4]`（skill base randf[0,0.3]+leader0.1）/`野心∈[0.35,0.65]`（NORMAL_LO/HI）**系統性低於 gate**、只**霸主-archetype**（hi_v 野心+hi_s 統領+SKILL_TAIL[0.5,0.9]）夠格。典型 warring 床無霸主 leader→「立國」goal 從不 emit→established=0「世界不建國」。fix=WHAT/balance 用戶裁（a 降門檻/b 確保霸主 spawn/c 接受立國罕見=macro 扁平代價、連正統/王朝 arc）。

### ★★而 `upgd.dispatched` 仍是 0，**那不是壞掉**

> ★歸檔自 `known_issues.md`（2026-09-02）｜原行號 `:1785`｜證據 `6d6ccd60`（型B）
```
lt_cost 182（71%：連物理成本 150 都不到）｜cost_to_margin 75（29%）｜ge_margin 1
```
⇒ ★★★**71% 是【就是窮】。而「窮」是經濟問題，不是配管問題** ——
**它該用經濟的方式解（產能／規模／交易），不是再找一條沒接的線。**
★**下一步歸 blueprint 的 roadmap（規模經濟／有大有小），不由本 arc 延伸。**

### ★★兩條沒接的線（★第二條才是解鎖那一半）

> ★歸檔自 `known_issues.md`（2026-09-02）｜原行號 `:1815`｜證據 `3f03d263`（型B）
| # | 缺的 | 只修①會怎樣 |
|---|---|---|
| ① | 採集所得 material 不入公庫 | —— |
| ★② | **不存在「回家卸貨」** | ★★**已超載的隊仍然解不開**：那 400 還卡在私產，`carry_full` 仍 72/72 |
★**②窮盡坐實**：`TileBank.deposit` 全 codebase **9 個 caller 逐條看過，沒有一個是「隊回自家據點卸私產」**（無 head 無 glob）。
★`invest_material_in`（faction_ai:2839）**證明 material 進公庫在機制上完全 OK** —— **只是採集那條路把它排除了。**

### ★★順帶結案一個先前掛著的殘謎（blueprint 指出）

> ★歸檔自 `known_issues.md`（2026-09-02）｜原行號 `:1828`｜證據 `829a9a05`（型B）
老熟林那刀量到 **汲取 `0 → 736`**，而 `material avail` **仍然短** —— **當時說不通，被放著。**
★**載重根解釋掉它了：採得到，背不動。**（`carry_full 72/72`、`pool_empty 0`。）
⇒ ★★**通則：找到新根時回頭掃一遍當時說不通的數字 —— 它們常是同一個根的另一面，不是各自獨立的謎。**

### ★★★而這條 arc 的形狀第三次重複：**又是一條沒接的線**

> ★歸檔自 `known_issues.md`（2026-09-02）｜原行號 `:1833`｜證據 `3f03d263`（型B）
**升級沒接線 → material 沒接進倉庫 → 沒有卸貨。**
★**修票**：`docs/superpowers/specs/2026-08-26-material-storage-and-unload-HOW.md`（送 R② 中）。
★**先講死的算術（防不可達驗收）**：`L1 公庫 cap 200 ＋ pop6 載重 60 = 260` vs `升級含緩衝 225` ⇒ **可達，但餘裕只有 35。**

### ★★★★★收口（2026-08-26）：**閉環四層，而根是【一個零】——並且我上面那張表【判錯了一半】**

**十張儀器票逐層收斂，每一層都是真牆、都量得到、都修得動、修了數字都真的動**：
```
材料不夠(163) → 富點看不見(→64) → slot 滿(180/258) → 據點不升級 → ★升級沒接線
```
★★★**而它們沒有一層是根。根在第四層，且它是一個【零】：`upg.eval_entry = 0`（一個從來沒有被呼叫的函式）。**
★**教訓**：**能被量、能被修、修了數字會動 —— 這三件事同時成立，仍然不代表它是根。**

### ★★★`assert(false, …)` 讓 headless process **掛死到逾時**（hang，不是 abort）（2026-08-25，implementer 實測）

> ★歸檔自 `known_issues.md`（2026-09-02）｜原行號 `:1997`｜證據 `e839d2b4`（型B）
**假說（他提，能同時解釋兩份互斥證據）**：★**編譯期常數 vs 執行期條件**
| assert 形態 | 觀察 |
|---|---|
| ★**執行期條件**（`assert(x > 0, …)`） | ★**印 `SCRIPT ERROR: Assertion failed:` 後【繼續跑】** —— 血證：單一 headless run 裡 6 條共存 |
| ★★**編譯期常數 false**（`assert(false, …)`） | ★★★**process hang 到逾時** |

⇒ ★★**「`assert` 會不會中止」這個問題【本身問錯了】** —— 正確問法是
**「這個 `assert` 的條件是【編譯期可判定】的嗎？」**
★**同族**：`01_architect`「問題的框架也會建立在錯誤前提上」的又一次實例。

### ★★★而 `hang` 比 `abort` 更危險 —— **它會偽裝成「正在工作」**
| | 外顯 | 誰會發現 |
|---|---|---|
| `abort` | **exit code 非 0** | 閘會抓 |
| ★**`hang`** | ★★**看起來像「跑很久」** | ★★★**可能被判成 `RUNNING` ⇒ 監控靜默** |

★**與同日 watchdog 的 `RUNNING` 遮蔽是同一枚硬幣的兩面**：**「有東西在動」不等於「事情在前進」。**
★★**現有防線裡唯一抓得到它的是【結尾標記】** —— **hang ⇒ 沒有結尾標記 ⇒ 判「無法證明跑完」。**
（★**那條標記原本是為 parse error 加的，對 hang 一併有效。**）

---

### [搬自 game-design.md 2026-08-25] 情報操控接線現況（2026-07-06 盤點）

> ★歸檔自 `known_issues.md`（2026-09-02）｜原行號 `:2020`｜證據 `f0bcfa3a`（型B）

### [搬自 game-design.md 2026-08-25] 生產/牆移進度與量測史（2026-07-16~24）

> ★歸檔自 `known_issues.md`（2026-09-02）｜原行號 `:2041`｜證據 `f0bcfa3a`（型B）

#### ★★進度 + 牆移子系統：貿易機制通,市場死在供給（2026-07-16）
統一商業框架 build 後量測:**貿易機制證明對（`deal_merchant` 史上首次非零 + 守恆 + de-patch cleanup 對）+ coin 大勝（`buy_no_coin -99.9%`,雙向流）。**
- **coin 從「磨」升「先有」（確認）**：coin 是 deals 前提非事後精修（no_coin -99.9% 才讓機制真跑）。
- **★但市場仍未 revive,牆移子系統**：deals 仍 ~1-2。新主牆＝`sell_no_surplus 51.7%`（訪客到市場**沒貨賣**）。**貿易水管全通了,但沒水可灌——producer 產不出可賣 surplus。** binding 從「貿易子系統」（已解）移到「生產/經濟實質子系統」（sell_no_surplus）。這正是最初的問題「誰生產可賣 surplus」＝整條經濟最深牆。
- **merge 決定（用戶定 2026-07-16）**：merge 貿易 foundation+coin（機制+coin 通,誠實標供給待）——**revise「revive 才 merge」,理由 blocker 移到不同子系統,避正確大 refactor 爛 branch drift**。過 reviewer R② + probe 語意核（新 order_id 路可觀測）才 merge。
- **供給牆 patch-gate-first（決定 2 前置）**：先查 `sell_no_surplus` 是 **gate 擋賣單**（`SURVIVAL 無單不賣` / 餘量門檻太高 → 有貨不掛賣單 → de-patch）**還是真沒 surplus**（生產求生型無餘糧）。
- **★決定 2＝甲（用戶定 2026-07-16，patch-gate-first 解疑）**：供給根 precise＝**製造設施幾乎不建**（`has_facility` 恆 1）。隊**想**製造（TASK_MANUFACTURE 1→11）、**有材料**（surplus 破千）,純被 **補丁閘擋**（頭號＝`恆-hungry→永建農`:定居隊糧在糧倉卻恆判餓→永優先農田→製造 never）。**∴ 非天生稀缺是 bug 閘 → 乙不成立（補丁閘通則＝de-patch,不把 bug 當設計）→ 甲。**
- **★★生產 arc＝拆光補丁閘融入框架（用戶定 2026-07-16，同商業那套）**：不 de-patch 單一閘,**拆光生產/設施子系統所有補丁閘、全融進框架（引擎 + 人格秤）、無殘補釘再量**（否則又抓下個閘＝打地鼠）。
  - **願景＝[[綜合發展模型]] 落地**：食安地基後多維發展人格化——工匠型建工坊/冶煉、農夫型續農、好戰型建軍事。食安→製造→餘貨→貿易,人格+情境定速。
  - **這是「吃得飽的窮部落爬薄階梯」突破口**：從求生升發展。
  - HOW 全交系統（哪些閘、怎麼進引擎、切幾 slice）;藍圖只定「食安後多維人格化發展 + 拆光補丁閘 + 全程人格化」。靜態稽核列全補丁閘餵系統。
  - **★★premise 訂正（R① 2026-07-16 手算推翻天真 de-patch）**：原以為「拆 `恆-hungry` override → 人格自然選農田」＝**假**。reviewer 手算 `_facility_score=地利×(1+deficit)×人格`:普通~良好地力,餓隊會選 workshop（4.40）> farming（除非地力近 max）,因 **deficit clamp[0,1] 使「快餓死」與「略缺」都=1.0 無量級**。**∴ override 其實承重（補償壞公式防餓死），天真拆掉會餓死＝比現狀更糟。**
    - **修正 WHAT**：不是拆 override,是**讓食安地基「真實在秤裡」**——deficit/急迫度要有**量級**（快餓死須輾壓 workshop/軍事 → 自然選農田;食安後急迫降 → 才輪人格選發展）。food-floor 從秤裡湧現,override 才能安全退役。**序：score 修好（地基進秤）才准拆 override。**
    - **means-end 斷鏈**：「建設 option 接手蓋工坊」全 codebase 不存在;facility 建造只由 `_evaluate_infrastructure`（僅 `state.factions`）發起 → faction_id=-1 獨立定居隊永無建設施路。**修：所有隊都要有「想 goods→需設施→能發起建」的真 means-end 路。**
    - **常數訂正**：`FOOD_PER_PERSON_PER_DAY=0.8`＝代謝物理**絕不人格化**;只「7」安全天數視野該人格化。世界物理常數留 flat,只人格化決策常數。
    - **修材引擎裡本就有（systems 親驗）**：`need_hierarchy L_SURVIVAL`（連續急迫度隨餓程度縮放）+ `food_security_target`（已人格調變 buffer）＝reviewer 說 flat deficit 缺的量級 + 願景要的人格 buffer。修＝facility-choice 接上這套（非新造 flat deficit 平行系統）。
    - **WHAT 定（2026-07-16）**：①**獨立隊（faction_id=-1）也發展生產＝YES**（綜合發展涵蓋所有據點主,非 faction 特權,排除＝任意豁免;means-end 統一發起涵蓋）。②**食安壓倒＝軟連續急迫曲線非硬 cliff**（cliff＝另一種死 gate）,但急性瀕死須真壓倒（農田輾壓,別讓餓隊蓋工坊死）;人格 textures 轉折（慎重 buffer 大→餓更晚仍發展、大膽→發展進更薄邊際＝戲）。
    - **序/閘**：score 修好（地基進秤）才准拆 override;v2 須再過 R①（可能 measure 坐實「急迫度真讓飢隊 farming 主導」）才 spec。
  - **★★供給側大成功（measurer full-HD 坐實 2026-07-16）**：`has_facility 恆1→31.3%`（含獨立隊 27.3%）、世界成品池 `26→480（18x）`、`Manufacture 6→4348（700x）`、`no-op=0`、**餓隊沒餓死（食安地基靠軟急迫守住,非 override）**、守恆 PASS、無殘補釘。**R① 訂正後的設計成功落地**（urgency 真 fire、獨立隊真發展兩項坐實）。**供給牆破。**
    - **merge 裁（2026-07-16）**：觀測閘綠即 merge（框架 correct+safe+主目標達成＝強證,不卡 emergence）,誠實標「供給破+surplus,人格分化 mechanism-present 待 multi-seed」。
    - **emergence 定案（multi-seed 2026-07-16）**：**好戰→軍事真 emergence 強坐實（Δ+0.36）**;貪婪→工坊/慎重→農**不顯＝need-first 設計的正確後果非 bug**（farming/workshop 由求生+deficit 主導,人格是 texture;食安不因人格打折）。**接受 by-design,不 tune 人格權重**（盲 tune 打架 need-correctness 傷供給側成功）。**願景訂正:人格化多路＝人格→archetype→目標→discretionary,非平坦 trait→設施映射;「工坊=貪婪」是錯映射該除。** 商業/定居的濃差異＝deal 側 arc 長出（為賣而產）。
  - **★deal 側牆＝死法②（下個 arc）**：供給「量」有了（18x goods）但**流通到 visitor 隨身可交易貨未打通**（sell_no_surplus 仍最大 bail）＝成交牆同款。經濟全景:**水管通（商業）+ 水有了（供給）→ 但水流到買家（deal-flow）仍塞**。下個 arc。
  - **★★貧困陷阱＝兩把鎖（food + coin urgency）鎖住建設層（measurer §④b 3 隊坐實 2026-07-23）**：追武器坊建造不成，一路挖到 afford 根＝**常駐求生高壓的隊會賣光非求生資產換食/coin，structurally 湊不到投資本**。機制:`reserve_factor=0.6+(hoard-0.5)×0.5-urgency×0.4`，`urgency=max(food_urg, coin_urg)` 常駐 0.72-0.98 → factor 壓到 0.25-0.29 → material 賣到 reserve 25-29 → 永遠囤不到建造門檻（105）→ 蓋不出**原本能解它壓的設施** → 永困。**設計自洽的『貧困陷阱』非 bug**。**★關鍵訂正（data 坐實，非單一逃生閥）：這是兩把鎖**——`urgency=max(food_urg, coin_urg)`，食安修只解 food 那把；**coin_urg 常駐 0.8-0.97（3 隊 coin 全極低）＝很可能是 binding 那把**，光 coin_urg≈0.8 就把 factor 壓到 0.28（正中觀測）→ **食安修單獨後 urgency 仍=coin_urg 0.8 → afford 仍鎖**。∴**軍設施 afford 要 food AND coin 兩鎖都解**；coin 鎖＝既有 coin poverty（掠奪 coin→anon_treasury 不流 team.coin，v2b defer）從「buy 錢包」升格成「貧困陷阱第 2 鎖」。∴**食安是建設層前置閥之一非唯一**；afford/cost/cap 都是下游症狀，不獨立修（cost70 balance 值 keep=銀行，兩鎖解後才生效）。連結 [[means-end]]:前瞻買料 target 是拍死常數（cap 100）非由建造實際需求推導＝決策模型缺「為目標湊足所需」的缺口，facility-build keystone 頭號 exhibit。**★診斷史血證**:此線靜態推理三次全錯（117 框架→persona 1.13→實測 0.25），唯 measure 結案＝涉「隊會不會累積到某量」的判斷靜態不可信（動態 sell/urgency 沖銷），必實測。
  - **★★material = 開採/地理資源非耕作資源（用戶定 2026-07-24，脫貧真脊椎的 world-model 裁決）**：三腿（reserve/coin/hold）修完 afford 仍 0%——patch-gate-first 證 inflow 無非法閘，真 binding = **aggregate material SUPPLY + 地理 food-terrain≠material-terrain 錯位**（隊為食定居 plains[食8/材0.5]被斷離 forest[材12]；material 只能採不能造[無 recipe out:material]、被所有 recipe 吃）。**★裁決 = 地理張力是 intended feature（非 bug、不 flatten）**：food vs material 走**兩種不同經濟邏輯**——**food=耕作**（原地改良、farming 設施放大產出[★歷史公式已被 2026-08-18 農業a 取代:農田現=獨立產線,見意圖帳「農田」row]、作物**季節級快再生** → 改良**永續**產量 coherent）；**material=開採**（樹**年代級慢生** → **不能像耕作那樣永續增產**）。**★關鍵區別（用戶 2026-07-24）：育林/種樹增產不 coherent（樹慢長不出來），但『伐木場=加快開採』coherent——它不種樹，把現有的樹砍更快。** ∴ farming＝永續耕作放大器 vs 伐木場＝**開採加速器**。**★核心框架 = 賽跑（用戶定 2026-07-24，非個人 boom-bust 取捨）：forest 材料是有限存量，『誰先砍完誰優勢大』**——誰先搶到 forest、砍得快、清完，誰把那筆材料收進口袋 → 發展優勢滾雪球；永續採贏不了清伐者（別人直接清光）→ 誘因永遠是衝/搶/快砍。**★機制＝現行的就夠（用戶 2026-07-24 核對坐實，非新機制）**：`regenerate_tiles:93-97` material regen＝**additive +12/天往 `resource_cap` 補（慢慢長、非瞬補、cap-bound）**、harvest 扣池（`_collect_from_tile` current−gain）→ **可耗竭池 + 慢回 + cap 全已在**。∴只需加兩樣：①**森林初始材料庫存高一點點**（forest tile 開局材料近一個高 `resource_cap`＝老熟林大獎，world-gen 初始值非改 regen 機制）②**伐木場設施＝加快 material 開採速率**（forest-only，讓「砍得快」變能贏的選項）。**regen 機制不動（已是慢慢長）。** **★唯一 measure＝tune 數字非改機制**：現行 +12/天夠不夠慢讓清伐後先手優勢維持夠久（賽跑尖銳）、還是太快幾天長回（先手不夠）→ measure 後微調 regen 數字/初始庫存/伐木場 boost（**別預調，先量**）。**不加育林（不 coherent）。** ∴ forest 隊＝材料生產者（搶砍+出口），plains 隊取得 material 靠**控產地（擴張搶 forest tile）+ 貿易 + 遷徙**＝取得閥。**★選擇的後果（用戶明選）：材料稀缺真實、發展是『競爭性』非『普世』**——能控/搶砍 forest/買得到的隊才發展，控不到=發展不起，**地理遊戲核心張力非 bug**（搶 forest tile 衝突 + 材料貿易 + forest 材料國↔plains 農業國互賴 + 先手滾雪球）。**★snowball 平衡待盯**：先手優勢別變死局（「先手必勝、遊戲結束」），靠既有 prosperity-prey 自我修正（滾大的富隊→眾矢之的→崛起與傾覆戲）+ measure 盯，過火再 tune。ore→material 製造（選項 c）用戶未選=暫緩（未來 mountain-archetype 深度可回訪，別繞地理張力）。


### [搬自 game-design.md 2026-08-25] 貿易死因診斷（2026-07-15）

> ★歸檔自 `known_issues.md`（2026-09-02）｜原行號 `:2069`｜證據 `f0bcfa3a`（型B）

#### 貿易死因診斷：真根＝兩結構牆（成交條件 + merchant 不成對），修向＝流動偏摩擦市場（與用戶成形 2026-07-15）
市場 deals≈0 挖到底,商隊「想做生意 404 次 → 成交 ~2 筆」。歷五層假設,measure/trace 逐一坐實**皆非 binding**,真根＝兩道結構牆:

| 假設 | measure/trace | 判 |
|---|---|---|
| supply seam（可見性）| deals~0 | 非 binding |
| merchant-target churn | target 穩定（28000tick 僅切6次）| 推翻 |
| threat-preempt（半路跑）| 真 preempt 僅 ~6 起,FLEE 是缺糧非 threat | 推翻 |
| accessor 結構（local_value）| absorb 修 +114% 但 <3% | 真債但非 binding |
| coin 私囊鎖（no_coin 91%）| **解禁 coin→全落 other_bail,WOULD_TRADE 恆零** | **紅鯡魚**（no_coin 是 co-loc bail 表面標記,非真兇）|

- **★★真根＝兩道結構牆（reconcile 坐實）**：
  1. **成交條件牆（最刺眼）**：雙方都想交易（WOULD_TRADE）**560 次卻只成 3 筆**（0.5%）。price/surplus/qty 三門檻疊乘,willing 夥伴幾乎永遠過不了。**是普世閘**（擋 resident + merchant 所有路）。
  2. **merchant 從不 co-locate**：100% 成交買方是 resident,**0 個 merchant**——商隊 travel 到訂單位卻從不跟賣方成對（arb 路死）。
- **★★修向＝流動偏摩擦市場（用戶定 2026-07-15）**：
  - **底線＝流動**：雙方都想交易 → **多數該成**。現 0.5% 不是「真實摩擦」,是**死常數幾乎不對齊＝壞**（照妖鏡）。
  - **質感＝摩擦**：交易不免費——價差談判 / 餘量謹慎 / 運力成本 讓**一部分** willing 夥伴談不攏,且**真實有意義**（真的價不對/運不划算），非全體卡死。
  - **摩擦掛人格**：急著交易/絕境的鬆手（接受薄利）、貪婪/謹慎的收緊（守價、留餘量）→ 談不成＝**性格與情境的戲**,非一道誰都過不了的死門檻。
  - 一句：**willing 夥伴大多能成交,談不攏是少數且有理由（人格/情境）,非常態。** 成交率/門檻數字系統 tune（HOW）。

### ★★★★S3 搬遷（七支→T3 3 天）讓 `warring_states` 提前 `game_over`（2026-08-27，★可逆閥 A/B 實測）

> ★歸檔自 `known_issues.md`（2026-09-02）｜原行號 `:2105`｜證據 `b149b5fb`（型A）

```
                   T3(3 天)      ★閥回滾(10/20/30/50h)
game_over          tick 8160     ★★從未
結束時 teams        69            89
_evaluate_all_body  144 次        316 次
```
★**同 seed 同床，唯一差異＝七支 cadence** ⇒ ★★**世界是【結束】，不是【變慢】。**
★★★**這超出 blueprint「有界窪地窗」條款①的前提**（該條款說窗內「隊反應慢」＝已知態非 bug）——
**「世界在 5.7 天內結束」不是「反應慢」。**

★**下一步已定：先查 `game_over` 的【原因】，不調 T3 值。**
★★**理由**：**兩種原因的下一步完全相反** ——
①**某一支的評估是某個維生迴路的必要前提**（＝執行層缺陷，修好後 3 天可能可行）
②**決策普遍太慢導致崩潰**（＝3 天真的太慢，`provisional` 值該調，而那是 blueprint 的權）
★★★**在分清楚之前調 cadence ＝ 把質地訊號調掉**（同「不 fire 就 crank 到會 fire ＝ 廢引擎」那族）。
出處：`docs/superpowers/specs/2026-08-27-S3-tiered-cadence-HOW.md`、implementer commit `b149b5fb`

### ★LADDER 的事件喚醒【也會重排 cadence】—— 具名不對稱（2026-08-28，S4b 交件時自報）

> ★歸檔自 `known_issues.md`（2026-09-02）｜原行號 `:2168`｜證據 `22ec101e`（型B）
```
★其餘八支:重排寫在閘旁邊（if _due: 才排）⇒ 事件喚醒【不動】cadence 時鐘
★★LADDER:重排寫在 callee（ambition_ladder.gd:126/156）⇒ 事件喚醒那次【也會】往後排
```
★**implementer 沒有伸手進 callee 壓它，理由對**：**那等於在 `AmbitionLadder` 外長出第二條排程路徑，
而「只能有一條排程路徑」正是 S3 整支的前提。**
★★**而 systems 排除了一個看起來像的風險**：**廣播事件同時重置所有人 ⇒ 會不會恢復 lockstep？**
**⇒ 不會 —— `CadenceStagger` 的 offset 是 `_mix(team_id, cycle_index)`，★同刻重置仍然各自錯開。**
★★★**所以爭點只剩【評估次數】，不是【同批到期】** ——
**而「事件喚醒之後，還該不該照原 cadence 再評一次」是【未定】的：**
```
不重排（八支）:事件醒一次 + 週期再醒一次 ⇒ 多做一次,但節律可預測
重排（LADDER）:事件醒了就算數 ⇒ 少做一次,但一串事件可能把週期那條路餓死
```
★**未夾帶進 S4b**（一次一類）。**要動的話是另一票，而它需要先答「哪一邊才對」。**

### ★★★「emit 了 ≠ 有人醒了」：**S4b 的 210 格證的是【閘會不會醒】**（2026-08-28 界限訂正）

> ★歸檔自 `known_issues.md`（2026-09-02）｜原行號 `:2185`｜證據 `fc4b80ec`（型B）
★**我 merge S4b 時把「210/210 woken」當成覆蓋證據** —— ★★**而 implementer 事後指出它的界限，訂正如下**：
```
★S4b 的 B 相把 burst 注在 advance_tick【之前】⇒ 那些格子永遠看得到 pending
   ⇒ ★★它證的是【閘會不會醒】,證不到【真 emit 站有沒有趕在自己消費者那一 pass 之前】
★★★而 consume_and_clear 在 tick【最末】(sim_runner:313)
   ⇒ 排在消費者之後才 emit 的,不是【延遲】是【那一次喚醒消失】
```
★**2 日 smoke 已看到逐 kind 分歧**（`intel_arrived` 99.5%／`order_buy` 8.9%／`combat_start` 0.0%）——
★★**母體小、不下結論**，30 日數字在跑。
★**修法三候選與代價**（★等數字才選）：
```
(a) 維持 tick 末清空 + 要求 emit 排在消費者前 ⇒ 脆弱:新增 emit 會【靜默】破壞
(b) 改 tick【開頭】清空 ⇒ ★pending 跨 tick 存活 ⇒【必須入 fingerprint】
    （world_events.gd 註解自己寫著「tick 結尾清空正是它不必入 fingerprint 的正當性基礎」）
(c) 雙緩衝(tick N emit → N+1 可見) ⇒ 一律延遲 1 tick(新根=1 分鐘),★但順序無關 by construction
```

### ★baseline 三欄補齊（2026-09-01 記）

> ★歸檔自 `known_issues.md`（2026-09-02）｜原行號 `:2259`｜證據 `5faaa623`（型B）
`docs/test-baseline-failures.txt` 現有 8 行沒有【出處／成因／待修票】三欄。
★新規矩只約束新行 ⇒ ★★**舊行不補，這條規矩三個月後就只有一行遵守。**

### ★★★known_issues 自己就是「記下來沒人回來看」的地方（2026-09-01，implementer 指出）

> ★歸檔自 `known_issues.md`（2026-09-02）｜原行號 `:2296`｜證據 `be2fc65c`（型B）
```
他量的「製造 no-op 混三因」⇒ ★本檔 :728 早就把它記成 tap-gap
⇒ ★★他今天量的是一個【已經被記下來、但沒有人回來看】的東西
```
★**規模（★我數的，不是憑印象）**：`docs/known_issues.md` = **2279 行 / 132 條目**，
★★**其中 105 條帶著 ≥1 個月前的日期。**
★★★**而本檔沒有到期機制** —— 跟今天治好的 `b_defer` 一模一樣：**判決寫下來了，而沒有東西在該回來看的時候叫人。**
⇒ ★**候選修法（同形）**：條目帶【什麼事發生時該回來看】的 token，而那件事發生時閘要紅。
⇒ ★★**尚未動工**：它會動到 132 條的格式，且與 `b_defer` 到期閘可能共用機制 —— **呈 blueprint 排序。**

### ★~~人口不成長：90 天只生 1 個~~ ⇒ ★★★**結案：觀測窗短於機制週期**（2026-09-01）

> ★歸檔自 `known_issues.md`（2026-09-02）｜原行號 `:2339`｜證據 `4b75a559`（型B）
```
★★★team9 的 `breed_progress` 走到 **0.9052**（1.0 ＝ 一名額）⇒ ★它不是卡住，是【還沒到】
★90 天的窗【短於這機制的一個週期（≈100 天）】
⇒ ★★【正常運作但週期比窗長】量出來，與【死閘】長得一模一樣
⇒ ★★★所以 born≈0 【既不是 bug 也不是 by design】—— 是【我們看得不夠久】
```
★**若要再看，回訪條件是【跑一個 > 100 天的窗】**，不是繼續在生育側歸因。
★★**而這一輪三票找到的東西都是真的**（breed 讀存量差分／床的盈餘是模型值／四處直寫繞過 tally）——
★★★**只是它們都不是 born=0 的原因。**

---
（以下為結案前的原始記錄，保留供溯源）

