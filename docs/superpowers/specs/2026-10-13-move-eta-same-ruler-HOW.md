# 移動「預計 N 分鐘」與實走不符——HOW

狀態：收 R²（2026-10-13-reviewer-to-systems-R2-move-eta-same-ruler-ISSUES；補完同版不需再審）
來源：藍圖 2026-10-13-blueprint-to-systems-TICKET-move-eta-mismatch-and-round5-launched；稿 docs/measurements/2026-10-13-round5-blueprint-real-run-merged.txt
排序：排在「附身隊後續三件」之後（同一位實作端，序列做）
WHAT（藍圖）：畫面印的預計時間要跟物理同一把尺（估算器禁手抄物理，用戶 2026-08-21）；抵達時印實走分鐘讓玩家能對帳。

## 症狀（藍圖實跑）
- 兩格：「預計 480 分鐘」，01:01 → 13:01 ＝ 720。
- 一格：「預計 240 分鐘」，13:02 → 20:02 ＝ 420。
- 全程畫面「疲勞: 0%」。

## 事實（main 17b51e689）
- 估算：`player_command_system.gd:2050` `PathSystem.eta_ticks(pt, float(_hex_dist(...)))`；`path_system.gd:185-193` ＝ 距離 × `BASE_MOVE_TICKS` ÷ `stamina_factor`。
- 物理：`movement_system.gd:124` 每走一格重算 `_move_cost` → `move_cost_pure`（:241-263）＝ `BASE_MOVE_TICKS` ÷（隊速 × 晝夜倍率 × **腳下地形** × 疲勞 × 超載 × 車輛地形），clamp 到 [MIN, MAX]。
  晝夜倍率由 `sim_runner.gd:668` `DayNightSystem.get_speed_mult`（白天 1.0／晨昏 0.8／夜 0.5）傳入。
  移動步在 hour 組（`sim_runner.gd:253`），每次累加 elapsed 進 `move_tick_acc`。
- 迴圈的隱含輸入（R² §1.2）：`move_tick_acc` 跨窗口持久（下令時不一定 0）；move 只在 `cur_t % NEAR_CADENCE == 0` 跑（`sim_runner.gd:684`），第一窗在下一個整點、先 `acc += elapsed`；晝夜倍率在窗口邊界那顆 tick 取一次（:668）套整窗；`max_steps`、餘量夾 MAX、到達／stuck 即 break。
- 路徑：物理每走一步都從當前格重新 `_calc_next_step` → `find_path`（`movement_system.gd:372-376`）；A* 等代價格多 ⇒ 起點算的完整路徑 ≠ 每步重算的路徑。
- ⇒ 估算漏了：晝夜、地形、超載、車輛、相位、起始餘量；距離用直線格數不用路徑。差額方向與量級和症狀一致（夜裡 0.5 倍），但**哪一項占多少由床量，不由我斷言**。

## 改法
1. **抽共用算術，不抄第二份**：把 `process()` 單隊單窗口的算術抽成 static 純函式（輸入：acc、pos、time_mult、elapsed、每步 cost 提供者、next-step 提供者；輸出：acc、pos、步數、是否到達／stuck）。`process()` 與估算器**都呼叫它**；`process()` 行為逐字不變（world-fp 不動是驗收之一）。
   - cost 提供者＝`move_cost_pure` 的「在某格」版（參數多帶 `pos`；原函式傳 `team.tile_pos` 呼叫它）。
   - next-step 提供者＝同一個 `_calc_next_step`（改 static 或抽純版，從影子 pos 呼叫）。
   - 晝夜倍率：`DayNightSystem` 加 static `speed_mult_at(tick)`，舊實例方法呼叫它；估算器在**每個窗口邊界 tick** 取一次（同物理取樣點），不是每格。
2. **估算器** `MovementSystem.estimate_travel_ticks(state, team, target, start_tick) -> Dictionary`（static，只吃 state＋team＋終點＋起始 tick，不碰 UI／PlayerCommand，AI 日後可直接遷移）：
   - 影子值：pos＝`team.tile_pos`、acc＝`team.move_tick_acc`（下令當下真值）；從 start_tick 之後第一個 hour 窗口起逐窗呼叫第 1 條的純函式，直到到達。
   - **不得**呼叫會寫狀態的 `_step_team`（它改 tile_pos、occupied_by、_on_arrival、Probe）；影子位置的 find_path 只走既有快取入口，不另存。
   - 上限：窗口數超過「一天的窗口數 × 路徑長」仍未到 ⇒ 回 `{ticks:-1, reason}`，畫面印「預計超過 N 分鐘」，不靜默截斷。
   - 回 `{ticks, residual_inputs}`：後者列出被當常數凍住的第二階輸入（疲勞、重量、人口）供床印殘差。
3. `move_to` 改用 2；結果句不變。改 `player_command_system.gd:2049` 那句註解（「讀既有移動成本 eta_ticks」修後過期）。`path_system.gd:185` `eta_ticks` 本體留著（AI 在用），加註解指向真尺。
4. **抵達對帳**：抵達句「抵達 (q,r)（走了 N 分鐘）」，N＝**sim 的抵達 tick**（清 move_target／發抵達的那顆 tick，或事件自帶 tick）− 下令 tick；不取 UI 輪詢看到的 tick。
5. **疲勞 0%：用跑的分，不先猜**。對玩家隊 12 小時行進印每次疲勞 pass 的 `team.fatigue` 原始值＋`fatigue.class.*`＋`fatigue.pass.n`，判是哪一個：
   (a) 增量小於顯示精度；(c) 畫面讀錯欄（寫明 UI「疲勞」讀 `team.fatigue` 還是成員 stress——`inspect_member` 把 "fatigue" 填 `p.stress`）；(d) 疲勞 pass 錯開相位與行走相位對不上，「moved」類落不到；(e) 回復與累積同窗抵銷。
   （「行進沒被算耗力」已由 R² 讀碼排除：`fatigue_exertion` 先判 `moved_since_fatigue`，與 task 無關。）
   (c)(d) ⇒ 本票修；(a)(e) ⇒ 不改，寫明數字。
- **範圍外**：AI 的 `_estimate_eta_to`（`faction_ai_system.gd:7612`）——改它動決策與 world-fp ⇒ 深層批（known_issues 已記）；本票床順便量 AI 舊估算在夜間 2 格路程的低估百分比，回填那條 known_issues。

## 驗收（容差 0，tick 精確）
- E1 陽性對照：平原兩格、白天、下令 tick 為 60 的倍數 ⇒ 估算＝實走。（修前可能也綠，不標修前紅。）
- E2（修前紅）：同路徑、下令 tick 非 60 倍數（例：整點後 1 分、整點前 1 分各一格）⇒ 估算＝實走。
- E3（修前紅）：跨夜（21:00 前後下令）⇒ 相等。
- E4（修前紅）：含森林、且 `move_tick_acc` 起始非 0 的路徑 ⇒ 相等。
- E5（修前紅）：等代價路徑多的平原長路（≥6 格）⇒ 相等（守「每步重規劃」）。
- E6：抵達句 N＝sim 抵達 tick − 下令 tick，且推進塊 >1 tick 時仍準。
- E7：疲勞判定（改法 5）的量測與結論。
- 第二階殘差格：疲勞中途變、糧吃掉變輕、人口變動——**印出殘差數值**，不放寬 E1–E5 的容差；這些格的佈置與 E1–E5 分開。
- 同源守衛：床內暫改窗口長度（或 MAX clamp）⇒ 估算與實走同步變。不新增閘。
- 負對照：估算器改回 `eta_ticks(hex_dist)` ⇒ E2–E5 紅；估算器改沿凍結路徑 ⇒ E5 紅。
- world-fp 不變（`process()` 抽純函式後行為逐字不變）。變了 ⇒ 先二分。
- 症狀數字來源：藍圖稿 `-merged` ＝ 多格移動 merge 後的樹。
