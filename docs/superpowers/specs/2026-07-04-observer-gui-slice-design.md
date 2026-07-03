# 觀測 GUI 輕 slice（事件 ticker + 隊伍 inspect + 速度控制）— Design

> 藍圖 handback `2026-07-04-blueprint-to-systems-gui-parallel-quality-bar` + 用戶追裁。
> 用戶第一次親眼看世界。**品質 bar=硬**：範圍內完整、穩、可讀、bar 場景親測可過、交付前截圖自驗。
> **用戶追裁：三件=底線範圍，不可砍件**（砍了打開什麼都沒有=更糟）。範圍固定+品質固定，唯一鬆的是時間。

## 系統偵察（已盤，實作按此走）

- **Main scene = TextUI.tscn（純文字玩家 UI）**。`Main.tscn` 圖形套件 dormant：`WorldMapView`（Node2D `_draw` 六角+camera/zoom）、`TurnControls`（ticks/sec 節流+SKIP 選項）、RightSidebar 等。**復用零件，不接玩家流程**。
- 事件結構源：`MessageSystem.emit_message` → `state.global_messages`（type 白名單≈TTL 表 `message_system.gd:7-20`）。`combat_start/end`、`subjugate`、`faction_establish`、`outpost_built`、`faction_defect`、tribute/extortion/aid、`famine_warning` 都有。
- **洞 1**：同化/暴動/逃亡=純 print（`manpower_system.gd:134,159,174` `[P1Assim]`/`[P1Revolt]`/`[P1Flee]`）——追狼弧的同化段 ticker 拿不到。
- **洞 2**：inspect 只有玩家隊 DTO（`PlayerQueryApi`/`sim_bridge.query_player`）；TextUI 路徑=玩家中心+迷霧+事件中斷推進。觀測=god-view+任意隊+不中斷，另一 driver 模式。
- **洞 3**：截圖 harness 不存在（`save_png` 全樹零命中）。bar 第 5 條依賴，本 slice 內建。
- tick 驅動：scene `_process` → `sim_bridge.tick_step()`（每 frame ≤`TICKS_PER_HOUR`=10 tick，事件即中斷）。`sim_runner.advance_tick(state, player_pos)` 需 LOD 錨點。
- cadence 撞點：`TickPerf max=294ms` 單 tick spike 存在（far.total 0.45-0.83s/500tick=top violator）。單 tick 不可分割 → spike tick 那 frame 必卡。
- 字型：無打包，TextUI 中文靠系統 fallback 已正常（同機自用，不加字型檔）。

## Task 0 — 事件源補洞（sim 層，最小侵入）

manpower 三事件 print→`emit_message`（保留 print 不動，**加** emit）：
- `assim_complete` / `revolt` / `flee`，params 帶 team_id、人數、地點。
- 俘虜獲得（capture 吸收進 captive_groups 處）若無 message 一併補 `captives_taken`。
- TTL 表加對應 key。
- **★RNG 流神聖**：emit_message 不得含任何 `randf`/RNG 消耗（strength 用常數）。驗證= `seeded warring reproducible OK` 行必須不變（同 seed 同 final hash）。

## Task 1 — Observer driver（不動玩家路徑）

- 新 `observer_bridge.gd`：
  - `tick_step()` 每 frame 推進，**不因事件中斷**（無玩家 encounter 概念）。
  - **frame 時間預算**：每 frame sim 累計耗時 cap（預設 ~12ms），到頂就把剩餘 tick 留給下一 frame——spike 攤平非凍結。
  - LOD 錨點：與 headless bed 同策略（固定/世界中心），sim 行為與二考 assets 一致。
  - `query_team(team_id)` / `query_all_teams()` read-only snapshot（新 ObserverQueryApi，pattern 沿 PlayerQueryApi，不碰玩家耦合欄）。
  - `consume_messages(since_id)`：`global_messages` 全量增量消費（非 `_diff_events` 兩型別版）。
- `sim_bridge.gd` / `text_ui_main.gd` **不改**（玩家路徑零風險）。

## Task 2 — ObserverMain scene（三件）

新 `scenes/ObserverMain.tscn`（main scene 不換，跑法=`godot.ps1 res://scenes/ObserverMain.tscn`）：

1. **地圖**：改造 `WorldMapView` → god-view（無迷霧）、隊伍圖示（archetype 色/faction 色）、outpost/村標記、click pick 隊、選中 highlight + follow camera toggle、zoom/pan。
2. **事件 ticker**（panel）：
   - 吃 `consume_messages` 全量，顯示 `[月X日Y] 中文句子`。
   - **人話 formatter（UI 層）**：type→模板，填 leader `person_name`/隊名/地名/數字。例：`subjugate` →「李霸攻陷南村，俘 4 人」。**逐 type 走查**：description 已人話者直用；probe 味者 UI 層改寫。數字帶單位。
   - **隊過濾**：選中隊時可切「只看該隊相關」（origin_team_id/params 內 team match）——追狼弧核心。
   - scroll 保留歷史（上限 500 條）。
3. **隊伍 inspect**（panel）：
   - 全隊清單（一行摘要：名/pop/rung/task），點選 → 詳情：leader 名、pop 分解（named/minor/prisoner/anon）、糧+flow、rung+archetype、faction、current_task、solo_intent、readiness、fatigue。
   - 與地圖 click pick 雙向同步。
4. **速度控制**：pause / 1× / 4× / max（max=時間預算內盡量跑）。復用 `TurnControls` 節流 pattern。顯示當前 月/日/tick。

## Task 3 — 截圖 harness（新建，bar 5 依賴）

- ObserverMain 支援 cmdline：`--obs-seed=N --obs-run-months=M --obs-shots=t1,t2,... --obs-out=dir`——跑到指定 tick 各截一張 PNG（`get_viewport().get_texture().get_image().save_png()`），完自動 quit。
- **非 headless**（headless 無 render）：windowed 跑，同機有顯示可行。wrapper 沿 `tools/godot.ps1`。
- 產出 = 交付自驗 assets：我 Read 看圖確認再交用戶。

## Task 4 — cadence spike 實測裁決

GUI max 速度跑 default seed，量 frame hitch：
- hitch ≤150ms 偶發 → 收（時間預算已攤大部分）。
- hitch >150ms 常態撞（far.total spike tick）→ **本 slice 內收 top violator**（far.total 攤平，向=cadence-aware accumulation 既有 design；quantified in `cadence-spike-fix` handback）。不降 tick 頻牽 sim 行為。

## 硬約束

- 玩家路徑（TextUI/sim_bridge/PlayerQueryApi）零 diff。
- Observer 全 read-only（query snapshot），唯一寫=Task 0 emit_message（append-only，單寫者格局不變）。
- RNG 流不擾：`seeded warring reproducible OK` 同 hash 為證。
- **寧慢不糙**：三件全上、每件到 bar；時間鬆、範圍品質不鬆。

## 驗收

1. 回歸：headless（1 pre-existing FAIL+0 SCRIPT ERROR+DONE）+ framework PASS=7 DORMANT=0 + seeded warring 同 hash。
2. 三件各自：ticker 中文成句無 probe dump、隊過濾 work；inspect 任意隊欄位齊且與地圖同步；速度四檔+時間顯示，max 6 月不崩不噴錯、無常態 >150ms hitch。
3. **bar 場景**：seed 1337+2674 各跑 6 月，用 ticker 隊過濾+inspect 追 Team19（轉糧引擎）/Team16（raid 爬階入 faction）型狼弧——事件鏈（raid→俘→同化→佔村/立國或轉糧）畫面上看得懂。
4. 截圖 assets（ticker/inspect/地圖/狼弧序列）進 handback，交付前自驗。

## 檔案 scope（平行紀律）

新：`scenes/ObserverMain.tscn`、`scripts/ui/observer_bridge.gd`、`observer_main.gd`、`observer_query_api.gd`、ticker/inspect panel scripts。
改：`world_map_view.gd`（god-view 改造）、`turn_controls.gd`（復用改）、`message_system.gd`（TTL key）、`manpower_system.gd`（僅 +emit 三處）、`npc_combat_system.gd`（僅若補 captives_taken emit）。
**勿碰**：`interaction_system.gd`、RelationGraph、belief——矩陣剩餘平行軌領地。矩陣軌本輪只挑 F-I2/F-I4/F-I5（避 manpower_system 撞檔）。
