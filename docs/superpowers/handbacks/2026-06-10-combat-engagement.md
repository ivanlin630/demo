# Hand Back: NPC 戰鬥成形（combat engagement）

> 日期：2026-06-10　branch：`feat/combat-engagement`（從 main 開，含已 merge 的 prosperity-attack）
> Plan：`docs/superpowers/plans/2026-06-10-combat-engagement.md`
> Spec：`docs/superpowers/specs/2026-06-10-combat-engagement-and-named-weight-design.md`

## 實作摘要（每檔一行）

- `scripts/simulation/movement_system.gd`：`process` 回傳 `{ "arrived":[...], "moved":[...] }`；`_compute_team_speed` 加 `NAMED_WEIGHT=3`
- `scripts/simulation/interaction_system.gd`：新 `process_on_move`（body 同 `process_on_arrival`，driver 換 `moved_ids`）；`process_on_arrival` 保留
- `scripts/simulation/sim_runner.gd`：`_step4_resolve_interactions` 改 call `process_on_move(moved)`；message（`_step3`/`_step3b`）保留 `arrived`
- `docs/known_issues.md`：加 Movement 段（mounts/wagons 無速度）
- `scripts/debug/headless_test.gd`：3 個 combat 測試 + 修既有 `mv.process` caller（回傳型別改 Dictionary）

## 驗證結果

- `headless_test`：**Combat 3/3 + Prosperity 16/16 綠**，0 SCRIPT ERROR、0 Assertion failed、無回歸
- `game_sim_test`（standalone）：`ALL INVARIANTS PASSED (violations=0)`、**NPC-NPC `[Combat Start] Team8 vs Team7` 觸發**（tick 3660）
- `game_sim_multi`（4 config × 90 天）：0 error、**0 invariant violation**、`ProsperityAttack`×4、全 config 存活到 21600 tick

## ★ 待主 session 確認（關鍵 — 實作中發現 plan 假設與現況不符）

1. **舊 `arrived` 其實已經是「本 tick 所有移動者」，不是「走到最終目標者」。**
   - `_step_team` 回傳 `team.tile_pos != old_pos`（有走就 true），舊 `process` 即 `if _step_team(): arrived.append()` → 舊 `arrived` = movers。
   - 即舊 `process_on_arrival(arrived,…)` **早就在掃所有移動者同格**。所以本 plan 把 interaction 換 `moved`，對「戰鬥掃描範圍」**行為等價、近乎 no-op**。
   - **真正改變戰鬥的槓桿是 `NAMED_WEIGHT=3`**（attacker named 多 → 速度快 → 較易追上 prey 同格）。
2. **訊息傳播被「縮窄」了（潛在 regression）：**
   - 本 plan 讓 message（`_step3`/`_step3b`）改吃**新的窄義 `arrived`（只含走到最終 move_target 者）**，而舊行為是吃 movers（每步都傳）。
   - 結果：intel/訊息現在只在「抵達終點」那刻傳，不再每步傳 → 傳播面變窄。
   - game_sim 不變量全過、無明顯破壞，但這是**行為變更**。若非預期，應讓 message 也吃 `moved`（一行改回）。
3. **multi 仍 0 NPC encounter（確定性，重跑同結果）：**
   - standalone game_sim_test 會出 1 場 NPC-NPC 戰（Team8 vs Team7），但 multi（同 advance_tick path，固定 RNG）4 config 全 0。
   - 根因：兩個移動體要「同 tick 落在同一個 exact hex」機率極低；NAMED_WEIGHT 只是微調速度差，未根本解決「擦肩而過」（attacker 踏進 prey 舊格、prey 同 tick 已走掉）。
   - **建議下一 spec**：交戰判定改「相鄰即接戰」或「踏入 prey 當前格即攔截」，而非 exact same-hex；或加 interception/攔截路徑。這才是讓 encounter 穩定 >0 的根本解。

## 連動風險

- `movement_system.process` 回傳型別 Array→Dictionary：已掃全 caller（`sim_runner` 2 處 + headless_test 1 處 resident-lock 測試），其餘無。
- `process_on_arrival` 保留未刪（無其他 caller，純留底）。
- NAMED_WEIGHT=3 改變所有隊速（named 比例高的隊變快）→ 全域 ETA 變動，戰爭/貿易/追擊頻率可能連動，需觀察。
- mounts/wagons 仍無速度差（已記 known_issues）。

## 後續

- ★ 交戰接觸判定改相鄰/攔截（根本解 encounter 頻率）
- message 是否改回吃 moved（確認傳播語意）
- NAMED_WEIGHT 數值 tune
- speed_class（步兵/騎兵/輜重）+ mount/wagon 速度
