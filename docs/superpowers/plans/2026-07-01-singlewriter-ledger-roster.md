# Plan — 單寫者 slice2：driver-ledger + roster chokepoint

> spec = `specs/2026-07-01-singlewriter-ledger-roster-design.md`。零行為變（純所有權重構）。
> 前置：headless 基準 PASS + coin_eq(全池) 0 + InvariantAudit 0 記下。

## Task 1 — Pattern B driver-ledger（TDD）
- `world_state.gd`：`driver_ledger`（ring-buffer cap N or off-by-default）+ `record_driver(entity, field, delta, reason, tick)`。
- 5 bank（resource_bank/anon_treasury/outpost_owner/loyalty/unrest）：`reason` 參數 → `record_driver`（現丟棄）。
- **測**：一筆 `ResourceBank.add(...,reason)` 後 ledger 有該筆 reason;off 時零記錄零成本。
- **DoD**：5 bank driver 真記、bounded/off 零成本、守恆不變、測綠。

## Task 2 — roster chokepoint + bidir（TDD）
- `world_state.gd`：`add_member(team, person)` / `remove_member(team, person)`（`named_members` ↔ `person.team_id` bidir,類比 set_team_faction）。leader_id 語意先定（傾向 chokepoint 涵蓋 or leader 獨立)。
- **測**：add→both set、remove→both clear、idempotent、無 desync。
- **DoD**：chokepoint + bidir 測綠。

## Task 3 — 59 直寫 site 遷 chokepoint（逐檔,零行為變）
- 逐檔改 `named_members.append/.erase/.clear` → chokepoint：熱點先（`subteam_system` 9/`reaction_system` 3/`health_system` 2）→ 其餘（faction_ai/event_*/game_setup/person_generator…）。
- 每檔改後跑 headless,結果不變（零行為變硬驗）。
- **DoD**：59 site 全走 chokepoint、每檔回歸綠。

## Task 4 — InvariantAudit roster bidir
- `invariant_audit.gd`：`named_members` ↔ `person.team_id` 雙向自洽（類比 faction bidir audit）。
- **測**：正常 state audit 綠;人工 desync → audit 抓。
- **DoD**：roster bidir audit 就位綠。

## Task 5 — 守恆閘（零行為變）
- headless PASS≥基準、coin_eq(全池)0、pop 守恆、**InvariantAudit（含新 roster bidir）0**、framework S1-S6 PASS、無 GDScript 錯。模擬結果不變。

## 不碰（scope + 並行 guard）
- tile-granary-bank（B 食物後）、tile.resources bank（後）、combat_target（BEG-JOIN 綁下輪）、faction_ai intent（首燒 merged）、resource_system 經濟函數（B 食物軌）、reaction growth 函數（B 食物軌;本軌只碰 reaction 的 named_members 寫）。

## 完成
- handback：ledger 真記就位、roster chokepoint+bidir、59 site 遷完、audit 補、零行為變證。= 強制閘有可查對象的前提就位。
- ⚠ 與 B 食物/征服 measure 並行同觸 reaction_system/faction_ai 不同函數 → 系統 merge 序解。
