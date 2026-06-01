# Known Issues

> 最後更新：2026-06-02 | 來源：動態測試 + code review

---

## 🔴 高優先（影響基本可玩性）

### S1. 視野公式門檻太高
- **症狀**：只能看到相鄰 1 格的 team；dist=2 的 team 即使 pop=10 仍不可見
- **根因**：`exposure + scout×0.3 > 0.5`，距離衰減（dist_f）使 dist=2 時 eff_exp=0.45，永遠低於門檻
- **計算**：pop=10 plains → base=0.60；dist=2 vrange=3 → dist_f=0.75；eff_exp=0.45 < 0.5
- **位置**：`scripts/simulation/vision_system.gd:41`
- **建議**：門檻降至 0.3，或移除距離衰減改為二元（在範圍內就看到）

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

### U2. 可移動到地圖外
- **症狀**：設定 move_target 到 (100,100)，team 實際移動過去不報錯
- **根因**：`movement_system` 只看 `move_target != (-1,-1)`，不驗證 tile 存在
- **位置**：`scripts/simulation/movement_system.gd`，及 `scripts/ui/main.gd:_on_set_move_target`
- **建議**：`_on_set_move_target` 設定前先 `state.world.tiles.has(pos.x*1000+pos.y)`

### U3. NPC 旗子看不到
- **症狀**：地圖上看不到其他 team 的旗子
- **根因**：S1（視野公式）+ 人口下降後暴露值不足（pop<8 → exposure<0.5）
- **連動**：camera 已修，但 S1 不修視野範圍仍只剩 dist=1

---

## 🟠 中優先（影響遊戲合理性）

### S3. SEASON_LENGTH=30 → 1年=5天
- **症狀**：季節極速切換，春夏秋冬沒有存在感
- **根因**：30 tick = 1.25 天，4季=5天/年
- **位置**：`scripts/simulation/harvest_system.gd:3`
- **建議**：720（30天/季），或至少 240（10天/季）

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

### G1. 攻擊後無遭遇戰 UI
- **症狀**：玩家選攻擊，模擬結算完畢但不顯示 encounter 畫面；戰後無掠奪
- **根因**：`encounter_view.gd` 在戰前設定 `pending_action`，但 `encounter_system._decide_action` 舊版未讀取；已由 agent-repl branch 修正消費邏輯，但 UI 畫面切換邏輯尚未串接
- **位置**：`scripts/ui/encounter_view.gd`，`scripts/ui/main.gd`

### G2. 外交/貿易自動執行，無玩家選擇
- **症狀**：NPC 發起外交/貿易，模擬自動決定結果；`player_forced_event` 有值但 UI 不顯示
- **根因**：`main.gd` 沒有讀取 `player_forced_event` 並顯示選項 UI
- **位置**：`scripts/ui/main.gd`

### G3. 玩家無法建立自己的勢力
- **症狀**：`PlayerCommandSystem.execute_action` 沒有 `establish_faction` 選項
- **位置**：`scripts/simulation/player_command_system.gd`

### G4. Recruit STUB 永遠失敗
- **症狀**：玩家選招募，回傳 `"recruit: STUB"` 不實際執行
- **位置**：`scripts/simulation/player_command_system.gd:_execute_recruit`

### G5. Alliance 兩者皆獨立時無效
- **症狀**：雙方皆無勢力時外交 accept 只有一方加入（或無效）
- **位置**：`scripts/simulation/player_command_system.gd:_accept_diplomacy`

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

### D2. player person 死亡無保護
- **症狀**：玩家可被事件殺死，`player_id` 仍指向已刪除的 person，所有 UI 失效
- **建議**：player person 死亡時觸發 game over 或角色轉移

### A1. agent_repl stdin 模式 stdout 污染
- **症狀**：stdin 模式下模擬 `print()` 混入 JSON Lines stdout，污染協定
- **根因**：GDScript `print()` 寫入 stdout；stdin REPL 與模擬 print 共用同一 fd
- **影響範圍**：僅限 stdin 模式（Windows headless 走 TCP fallback，實際不受影響）
- **位置**：`scripts/debug/agent_repl.gd:_run_stdin_loop`
- **建議**：加 `--quiet` flag suppress 模擬 print，或在 stdin loop 前重導向 print 到 stderr

### A2. encounter_view.gd `_max_timer` 欄位缺失（pre-existing）
- **症狀**：`unit.get("_max_timer", 10)` 永遠回傳預設值 10，計時器顯示不正確
- **根因**：`_create_named_unit` 未設置 `_max_timer` 欄位
- **位置**：`scripts/ui/encounter_view.gd:263`
- **建議**：`_create_named_unit` 加 `_max_timer` 欄位，或 encounter_view 改讀正確欄位

---

## 待討論（設計決策）

| 問題 | 選項 A | 選項 B |
|---|---|---|
| S1 視野門檻 | 降至 0.3（保留距離衰減） | 移除衰減，範圍內直接可見 |
| U7 Camera | 每次 tick 回正 | C 鍵手動回正 |
| D2 player 死亡 | Game Over 畫面 | 自動轉移到新角色 |
| S4 人口分裂 | 提高門檻 | demo 期間停用 |
