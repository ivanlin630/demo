# Hand-back：不變量架構收口 Phase 1 — InvariantAudit 框架 + 三網

> Plan：`docs/superpowers/plans/2026-06-17-invariant-audit-phase1.md`
> Spec：`docs/superpowers/specs/2026-06-17-invariant-architecture-design.md`
> Branch：`feat/invariant-audit-phase1`（基於 main `0db7e78`）

## 做了什麼

純新增「檢查」層，**零模擬行為改動**。

- 新檔 `scripts/simulation/invariant_audit.gd`（`class_name InvariantAudit`）：static `check(state) -> Array[String]`，回違反訊息清單（空=一致）。三個私有 `_check_*`：
  - `_check_population`：`population == leader(0/1) + named_members + AnonTierSystem.total_pop + wounded`
  - `_check_faction_bidir`：`FactionData.member_team_ids` ↔ `TeamData.faction_id` 雙向 + 懸空
  - `_check_subteam_bidir`：`parent.subteam_ids` → `child.parent_team_id` 回指 + 懸空
- `scripts/debug/headless_test.gd`：3 個單元測（正常 0 違反 + 故意造 drift 被偵測），註冊進 `_initialize()`。
- `scripts/debug/game_sim_multi.gd`：月取樣（`current_tick % TICKS_PER_MONTH == 0`）呼 `InvariantAudit.check`，非空印 `[InvariantViolation]` + 計數，config 結束印 `[InvariantSummary]`。

加新不變量 = 加一個 `_check_*` 並在 `check()` 呼叫。

## 驗證

- headless：`=== DONE ===`，三個 `InvariantAudit ... OK` 綠。
- ui_logic_test：errors 0。ui_flow_test：errors 0。無回歸。
- multi：4 config 全跑完，`[InvariantViolation]` 如預期現形（診斷正確）。

## multi 揭露的現有 drift 清單（Phase 2/3 修復基準）

**全部是 `population` drift；faction / subteam 雙向兩網 0 違反（runtime 乾淨）。**

每月取樣違反總計（21600 tick / 3 取樣點）：

| config | 違反取樣總計 | 首現 tick | 模式 |
|---|---|---|---|
| game_sim_test | 36 | 7200 | 欄位 < 期望 |
| tyrant | 60 | 7200 | 欄位 < 期望 |
| merchant | 27 | 7200 | 欄位 < 期望 |
| warzone | 106 | 7200 | 欄位 < 期望 |

**統一病徵：`population` 欄位 < 期望（leader+named+anon+wounded）**，差距隨時間擴大。即 anon 成長（生育/招募/升等流入）有更新 `anon_tiers` 但**沒同步加 `population` 欄位**。典型例：

- `game_sim_test` tick21600 Team1：欄位=6 期望=10（leader1+named1+anon8）→ 漏 4
- `tyrant` tick7200 Team4：欄位=15 期望=28（anon27）→ 漏 13（anon 流入規模最大者漂最兇）
- `merchant` tick7200 Team1：欄位=1 期望=9（anon8）→ 欄位幾乎沒動，anon 整批沒進 pop
- `warzone` tick21600 Team1：欄位=1 期望=13（anon12）→ 同上，戰時 anon 流動最大、漂最多（總計 106）

無懸空 faction/subteam、無 named 反向破口出現於 4 config 的月取樣。

**注意**：plan 明定 Phase 1 不修。上述差距是 Phase 2/3 走「population getter 衍生化（非補貼 mutation）」收斂的目標清單。**不要**靠到處 `+= 1` 補貼修——那會再製造散亂聚合。

## 連動風險

純加檢查，不改 mutation/行為路徑。`InvariantAudit` 僅被 headless 測 + multi 月取樣呼叫，不接入 `SimRunner.advance_tick` 主迴圈（不影響正式跑效能/行為）。風險：低。

## 待後續

- **Phase 2**：wounded getter + wounded net（需先解 anon 傷況來源 — 本 plan 未碰）。
- **Phase 3**：population getter 衍生化 + 審 spec 列的 44 個 mutation 點，把上表 drift 一次收斂。

## Commits（branch `feat/invariant-audit-phase1`）

1. `feat(audit): InvariantAudit 框架 + population 衍生一致性檢查（Phase1）`
2. `feat(audit): faction 雙向一致性檢查（Phase1）`
3. `feat(audit): subteam 雙向一致性檢查（Phase1）`
4. `feat(audit): multi sanity 接入 InvariantAudit（揭露現有 drift,Phase1 診斷）`
