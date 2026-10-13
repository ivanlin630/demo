# 移動「預計 N 分鐘」與實走不符——HOW

狀態：草稿，待 R²
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
- ⇒ 估算漏了：晝夜、地形、超載、車輛；距離用直線格數不用路徑；也沒有 hour 組的取整。差額方向與量級和症狀一致（夜裡 0.5 倍），但**哪一項占多少由床量，不由我斷言**。

## 改法
1. **一把尺**：`move_cost_pure` 拆出「在某格、某時刻」的版本（參數多帶 `pos` 與 `time_mult`；原函式呼叫它、傳 `team.tile_pos`，行為逐字不變）。晝夜倍率改成可由 tick 求值的 static（`DayNightSystem` 現在是實例方法；加 static `speed_mult_at(tick)`，舊方法呼叫它）。
2. **估算器＝把物理迴圈空跑一遍**：新函式 `MovementSystem.estimate_travel_ticks(state, team, path, start_tick)`：
   沿 `find_path` 的路徑，用與 `process()` 相同的累加與步進規則（hour 組、acc−=cost、每格用該格地形與該刻晝夜）模擬到抵達，回傳 tick 數。
   **不准**在估算器裡寫任何倍率或常數；只能呼叫第 1 條那支。疲勞取下令當下的值（行進中疲勞變化不預測——它是第二階，誤差由床量出來寫進交件信）。
3. `move_to` 改用 2，路徑用已經算過的 `find_path` 結果（同一次，不重算）。結果句不變：「開始走向 (q,r)，預計 N 分鐘」。
4. **抵達時對帳**：UI 抵達句改「抵達 (q,r)（走了 N 分鐘）」，N ＝ 抵達 tick − 下令 tick（UI 在 M 下令時記 tick，與 `_arrive_target` 同處）。
5. **疲勞 0%**：查清楚是哪一個——(a) 12 小時行進的疲勞增量本來就小於顯示精度、(b) 行進中沒有被歸為耗力（`fatigue_exertion` 的 `moved_since_fatigue` 對 TASK_TRAVEL 有沒有被設）、(c) 畫面讀錯欄。用床量出行進前後 `team.fatigue` 的原始值，交件信寫是哪一個。是 (b)／(c) ⇒ 本票修；是 (a) ⇒ 不改，寫明。
- **範圍外**：`faction_ai_system.gd:7612` AI 的 `_estimate_eta_to` 也用 `eta_ticks`，同樣漏晝夜。改它會動 AI 決策與 world-fp ⇒ 不在本票，我記 known_issues 進深層批。`eta_ticks` 本體不改（AI 還在用）。

## 驗收
- E1（修前紅）：平原兩格、白天下令 ⇒ 預計＝實走（容差：一個 hour 組，因為步進只在 hour 組發生；床寫明容差來源）。
- E2（修前紅）：同路徑在 21:00 下令（跨夜）⇒ 預計＝實走，同容差。
- E3（修前紅）：含森林格的路徑 ⇒ 同上。
- E4：抵達句帶「走了 N 分鐘」且 N 與床量的實走相同。
- E5：疲勞那一項的量測與判定（見改法 5）。
- 一把尺守衛：估算器檔案裡 grep 不到 `TERRAIN_SPEED_MULT`／`get_speed_mult` 以外的倍率常數字面——**不新增閘**，用床裡一格斷言「估算器呼叫的是同一支」（例：把 `TERRAIN_SPEED_MULT["forest"]` 在床內暫改，估算與實走同步變）。
- 負對照：估算器改回 `eta_ticks(hex_dist)` ⇒ E1–E3 紅。
- world-fp 不變（AI 路徑沒動；`move_cost_pure` 拆法逐字不變）。變了 ⇒ 先二分。
