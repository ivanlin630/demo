# Plan — 單寫者 slice3：leader desync 修 + ledger 接線

> spec = `specs/2026-07-01-singlewriter-slice3-leader-desync-design.md`。
> 前置：headless 基準 PASS + coin_eq(全池)0 + InvariantAudit 0 + game_sim_multi merchant P0 desync=1（baseline）記下。

## Task 1 — set_leader chokepoint（TDD）
- `world_state.gd`：`set_leader(team, pid)` = `team.leader_id=pid` + `person.team_id=team.team_id` + 舊 leader 留隊走 `add_member`（語意 plan 定）。
- **測**：set_leader 後 leader.team_id=本隊、bidir 一致、idempotent。
- **DoD**：chokepoint 綠。

## Task 2 — leader_id 直寫 site 遷 set_leader
- 盤 + 改：`event_system`(succession)/`event_unrest_replace`/`event_unrest_split`/`person_generator`/`game_setup`/`faction_ai`(晉升) 的 `leader_id =` → set_leader。
- 每處 headless,語意不壞（繼承/晉升/建國）。
- **DoD**：leader 指派全走 chokepoint;game_sim_multi merchant P0 desync **1→0**。

## Task 3 — driver_tick_hint 接線
- `sim_runner.gd`：每 tick `if WorldState.driver_ledger_enabled: WorldState.driver_tick_hint = tick`（off 跳,避 hot path）。
- **測**：開 ledger → record 帶真 tick。
- **DoD**：ledger tick 溯源真。

## Task 4 — 反向 roster audit
- `invariant_audit.gd`：反向——`person.team_id != -1` 須在該隊 named_members/leader。**dead 跳過**（health famine 留屍）：dead 標記（`health_system` flag or audit 認）先解。
- **測**：正常綠（不誤報 dead）;人工 person→wrong-team 抓。
- **DoD**：反向 audit 綠、不誤報。

## Task 5 — 守恆閘
- headless PASS≥基準、coin_eq(全池)0、pop 守恆、**InvariantAudit（forward+反向 roster）0**、framework S1-S6 PASS、無錯。bed leader 繼承/晉升/建國語意正常。

## 不碰（scope + 並行 guard）
- combat_target chokepoint（means-end 後綁 BEG/JOIN）、tile-bank（後）、decision/*（means-end 軌）、faction_ai 決策函數（means-end）。**只碰 world_state/sim_runner/invariant_audit/leader_id site（event_*/person_gen/game_setup/faction_ai 晉升函數）/health_system dead 標記**。

## 完成
- handback：leader desync 消（P0 1→0）+ ledger tick + 反向 audit;強制閘首個可查對象「修好」證。
- ⚠ 與 means-end 並行同觸 faction_ai 不同函數（晉升 vs 決策）→ 系統 merge 序解。
