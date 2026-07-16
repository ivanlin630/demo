# 單寫者 slice3：leader/team_id desync 修 + ledger 接線 — 設計 spec

> 系統 HOW spec。承藍圖 `means-end-tactical-arc`（單寫者 ledger arc 平行續,leader/team_id desync 修納此）。統一矩陣 F-S3 續 + slice2 audit 揭的 pre-existing desync。
> **combat_target chokepoint 延**（與 means-end 征服 route 撞 faction_ai 攻擊/combat_target,means-end 先定攻擊路徑再收 combat_target + BEG/JOIN 綁）。本 slice 只 leader desync + ledger 接線 + 反向 audit。

## 現況（slice2 audit 揭）
- **leader/team_id desync**（pre-existing）：merchant leader P0 `team_id != 本隊`（tick 7200→21600 persistent）。roster chokepoint（slice2）修了 named-transfer desync（tyrant 4→0),但 **leader 指派經非-named 路徑**（`leader_id =` 直寫 + team_id 不同步）覆蓋不到 → 殘留。
- **driver_tick_hint 未接線**（slice2）：ledger 記 driver 但無真 tick 溯源。
- **反向 roster audit 未做**（slice2 forward-only,因 health famine「死亡留屍保 team_id」會誤報）。

## 設計

### A. leader/team_id desync 根修
- 盤 `leader_id =` 賦值 site（`event_system`(succession)/`event_unrest_replace`/`event_unrest_split`/`person_generator`/`game_setup`/`faction_ai`(晉升)…）：每處**確保新 leader 的 `person.team_id` = 本隊**（leader 屬本隊）。
- **統一 leader chokepoint**（傾向）：`WorldState.set_leader(team, pid)`（設 `team.leader_id` + `person.team_id=team.team_id` + 舊 leader 若留隊走 add_member）。mirror roster chokepoint。改所有 `leader_id =` 直寫 site。
- **這是行為變修**（動 leader 指派路徑）——非零行為變（修 desync=改結果,但改的是 bug）。bed 驗 leader 語意不壞（繼承/晉升/建國正常）。

### B. driver_tick_hint 接線
- `sim_runner.gd`：每 tick（或 `if driver_ledger_enabled`）填 `WorldState.driver_tick_hint = tick` → ledger record 帶真 tick 溯源。避 hot path（off 時跳）。

### C. 反向 roster audit（person→roster）
- `invariant_audit.gd`：加反向——凡 `person.team_id != -1` 須在該隊 named_members/leader（或 anon,但 anon 無 person）。
- **解 famine 誤報**：health famine「死亡留屍保 team_id」（`health_system:219` 蓄意）→ 反向會誤報 dead person。修向：dead person 標記（存活 flag）or 清 dead team_id;audit 跳 dead。plan 定（傾向 audit 認 dead 標記跳過）。

## 驗收
- **leader desync 消**：game_sim_multi audit merchant P0 desync 0（前 1）;tyrant/warzone 續 0;bed leader 繼承/晉升/建國語意正常。
- **ledger tick**：ledger record 帶真 tick（開 ledger 時）。
- **反向 audit**：正常 state 綠（不誤報 dead）;人工 person→wrong-team desync 抓。
- 守恆：coin_eq 全池 0、pop 守恆、framework S1-S6 PASS、InvariantAudit（forward+反向 roster）0、headless 全綠。

## 檔案
- `world_state.gd`：`set_leader` chokepoint + driver_tick_hint 接線 helper。
- `sim_runner.gd`：driver_tick_hint 每 tick 填（off 跳）。
- leader_id 直寫 site（`event_system`/`event_unrest_replace`/`event_unrest_split`/`person_generator`/`game_setup`/`faction_ai` 晉升）→ 走 set_leader。
- `invariant_audit.gd`：反向 roster audit + dead 標記跳過。
- `health_system.gd`：dead person 標記（若反向 audit 需）。
- `headless_test.gd`：leader chokepoint 測 + 反向 audit 測 + ledger tick 測。

## 風險 + 緩解
- **leader 指派路徑多**：逐 site TDD,bed 驗繼承/晉升/建國語意不壞。desync 修=行為變（改 bug 結果）,非任意行為變。
- **反向 audit dead 誤報**：dead 標記/跳過先解,否則 audit 噪。
- **與 means-end 並行**：本軌碰 world_state/sim_runner/invariant_audit/leader_id site（event_*/person_gen/game_setup/faction_ai 晉升）→ means-end 碰 decision/*+faction_ai(_decide_unified/攻擊)→ faction_ai 不同函數（晉升 vs 決策）,merge 序解。**不碰** combat_target（延）、decision/*（means-end）。
- **scope**：leader desync + ledger tick + 反向 audit。**不碰** combat_target chokepoint（means-end 後,綁 BEG/JOIN）、tile-bank（後）、decision。

## 開放細節（plan 定）
- set_leader chokepoint 涵蓋範圍（舊 leader 降 member 是否走 add_member）。
- dead person 標記形式（flag vs 清 team_id）。
- driver_tick_hint off 時完全跳 vs 總填。
