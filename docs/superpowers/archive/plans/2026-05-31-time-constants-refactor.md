# Time Constants Refactor Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 將所有時間常數從裸數字改為以 WorldState 具名單位定義，一處改 TICKS_PER_DAY 全體等比縮放。

**Architecture:** 在 `world_state.gd` 加 6 個 static const；各系統的 interval/rate 常數改參照 WorldState；移動速度改用遭遇戰常數導出。

**Tech Stack:** Godot 4.2.2 GDScript，headless test `scripts/debug/headless_test.gd`

**⚠️ 前置條件：** 實作前先確認 `EncounterSystem` 已有 `MAP_DIAMETER` 和 `BASE_ACTION_TICKS`（來自 `worktree-feat+encounter-core-systems` 分支）。若主 branch 尚未合併，先請主 session 合併。

---

## 檔案一覽

| 檔案 | 改動 |
|---|---|
| `scripts/data/world_state.gd` | 加 6 個 const（TICKS_PER_DAY 等） |
| `scripts/simulation/salary_system.gd` | SALARY_INTERVAL → WorldState.TICKS_PER_MONTH |
| `scripts/simulation/harvest_system.gd` | SEASON_LENGTH → WorldState.TICKS_PER_SEASON |
| `scripts/simulation/population_system.gd` | OVERFLOW_CHECK_INTERVAL → WorldState.TICKS_PER_DAY |
| `scripts/simulation/sim_runner.gd` | FATIGUE_PER_TICK/RECOVERY → per-day 定義 |
| `scripts/simulation/resource_system.gd` | FOOD_PER_PERSON_PER_TICK → per-day 定義 |
| `scripts/simulation/movement_system.gd` | BASE/MIN/MAX_MOVE_TICKS → EncounterSystem 常數導出 |
| `scripts/debug/headless_test.gd` | 更新相關 assert |

---

## Task 1：WorldState 加時間常數

**Files:**
- Modify: `scripts/data/world_state.gd`

- [ ] **Step 1：在 `var ticks_per_day: int = 24` 上方加 const 區塊**

在 `class_name WorldState` 下方、第一個 `var` 之前加：

```gdscript
# ── 時間基底 ──────────────────────────────────────────────────
const TICKS_PER_DAY:    int   = 24           # TEST VALUE（正式: 8640 = 10秒/tick）
const TICKS_PER_HOUR:   int   = TICKS_PER_DAY / 24   # = 1（TEST）
const TICKS_PER_MONTH:  int   = TICKS_PER_DAY * 30   # = 720 ticks
const TICKS_PER_SEASON: int   = TICKS_PER_DAY * 90   # = 2160 ticks（3月）
const TICKS_PER_YEAR:   int   = TICKS_PER_DAY * 360  # = 8640 ticks（12月）
const SECONDS_PER_TICK: float = 86400.0 / float(TICKS_PER_DAY)
```

- [ ] **Step 2：跑 headless 確認無 SCRIPT ERROR**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd 2>&1 | Select-String "DONE|SCRIPT ERROR"
```

預期：`=== DONE ===`，無 SCRIPT ERROR。

- [ ] **Step 3：Commit**

```
git add scripts/data/world_state.gd
git commit -m "feat(world): add TICKS_PER_DAY/MONTH/SEASON/YEAR constants to WorldState"
```

---

## Task 2：SalarySystem → TICKS_PER_MONTH

**Files:**
- Modify: `scripts/simulation/salary_system.gd`

- [ ] **Step 1：替換常數定義**

將：
```gdscript
const SALARY_INTERVAL: int     = 720   # 30天/月（原30=1.25天）
```
改為：
```gdscript
const SALARY_INTERVAL: int = WorldState.TICKS_PER_MONTH   # 1月/次
```

- [ ] **Step 2：跑 headless 確認**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd 2>&1 | Select-String "DONE|SCRIPT ERROR|salary|Salary"
```

預期：`=== DONE ===`，`[Salary]` 出現（1000 ticks 內至少 1 次，TICKS_PER_MONTH=720 → 約 tick 720 觸發）。

- [ ] **Step 3：Commit**

```
git add scripts/simulation/salary_system.gd
git commit -m "refactor(salary): SALARY_INTERVAL = WorldState.TICKS_PER_MONTH"
```

---

## Task 3：HarvestSystem → TICKS_PER_SEASON

**Files:**
- Modify: `scripts/simulation/harvest_system.gd`

⚠️ **行為變更**：SEASON_LENGTH 從 720（1月）→ 2160（3月）。季節變化頻率降低為原來 1/3，這是設計目標。

- [ ] **Step 1：替換常數定義**

將：
```gdscript
const SEASON_LENGTH: int  = 720                        # 30天/季，1年=120天（原30=1.25天）
```
改為：
```gdscript
const SEASON_LENGTH: int = WorldState.TICKS_PER_SEASON   # 1季 = 90天
```

- [ ] **Step 2：跑 headless 確認**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd 2>&1 | Select-String "DONE|SCRIPT ERROR|harvest|Harvest|season"
```

預期：`=== DONE ===`，無 SCRIPT ERROR。（1000 ticks 不夠跑完 1 季，harvest tick 可能不出現，但不應崩潰。）

- [ ] **Step 3：Commit**

```
git add scripts/simulation/harvest_system.gd
git commit -m "refactor(harvest): SEASON_LENGTH = WorldState.TICKS_PER_SEASON (90 days)"
```

---

## Task 4：PopulationSystem → TICKS_PER_DAY

**Files:**
- Modify: `scripts/simulation/population_system.gd`

- [ ] **Step 1：替換常數定義**

找到：
```gdscript
const OVERFLOW_CHECK_INTERVAL: int = 10  # TEST VALUE
```
改為：
```gdscript
const OVERFLOW_CHECK_INTERVAL: int = WorldState.TICKS_PER_DAY   # 每天檢查
```

- [ ] **Step 2：跑 headless 確認**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd 2>&1 | Select-String "DONE|SCRIPT ERROR"
```

預期：`=== DONE ===`，無 SCRIPT ERROR。

- [ ] **Step 3：Commit**

```
git add scripts/simulation/population_system.gd
git commit -m "refactor(population): OVERFLOW_CHECK_INTERVAL = WorldState.TICKS_PER_DAY"
```

---

## Task 5：SimRunner 疲勞率 → per-day

**Files:**
- Modify: `scripts/simulation/sim_runner.gd`

- [ ] **Step 1：替換常數定義**

將：
```gdscript
const FATIGUE_PER_TICK: float        = 0.002   # TEST VALUE
const FATIGUE_RECOVERY: float        = 0.01    # TEST VALUE
```
改為：
```gdscript
const FATIGUE_PER_DAY: float          = 0.048   # TEST VALUE — 約 20.8 天疲勞滿（原 0.002×24）
const FATIGUE_RECOVERY_PER_DAY: float = 0.24    # TEST VALUE — 約 4.2 天回滿（原 0.01×24）
```

- [ ] **Step 2：更新使用處**

在 `sim_runner.gd` 找到所有使用 `FATIGUE_PER_TICK` 和 `FATIGUE_RECOVERY` 的地方，改為除以 `WorldState.TICKS_PER_DAY`：

搜尋模式：`FATIGUE_PER_TICK` 和 `FATIGUE_RECOVERY`（不含 `FATIGUE_LOYALTY_PENALTY`）

用法示例（使用處通常類似）：
```gdscript
# 原
team.fatigue += FATIGUE_PER_TICK * terrain_mult * time_mult
team.fatigue -= FATIGUE_RECOVERY * rest_mult
# 改
team.fatigue += FATIGUE_PER_DAY / float(WorldState.TICKS_PER_DAY) * terrain_mult * time_mult
team.fatigue -= FATIGUE_RECOVERY_PER_DAY / float(WorldState.TICKS_PER_DAY) * rest_mult
```

實際改動前先用 Grep 確認所有使用位置：
```powershell
Select-String -Path scripts/simulation/sim_runner.gd -Pattern "FATIGUE_PER_TICK|FATIGUE_RECOVERY[^_]"
```

- [ ] **Step 3：跑 headless 確認**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd 2>&1 | Select-String "DONE|SCRIPT ERROR|fatigue|Fatigue"
```

預期：`=== DONE ===`，無 SCRIPT ERROR，fatigue 值範圍 [0,1]（不出現 >1 或 <0）。

- [ ] **Step 4：Commit**

```
git add scripts/simulation/sim_runner.gd
git commit -m "refactor(sim): fatigue constants per-day (FATIGUE_PER_DAY, FATIGUE_RECOVERY_PER_DAY)"
```

---

## Task 6：ResourceSystem 食物消耗 → per-day

**Files:**
- Modify: `scripts/simulation/resource_system.gd`

- [ ] **Step 1：替換常數定義**

將：
```gdscript
const FOOD_PER_PERSON_PER_TICK: float = 0.1
```
改為：
```gdscript
const FOOD_PER_PERSON_PER_DAY: float = 2.4   # TEST VALUE — 2.4食物/人/天（原 0.1×24）
```

- [ ] **Step 2：更新使用處**

找到使用 `FOOD_PER_PERSON_PER_TICK` 的地方（通常 1 處），改為：
```gdscript
# 原
var food_needed: float = float(total_pop) * FOOD_PER_PERSON_PER_TICK
# 改
var food_needed: float = float(total_pop) * FOOD_PER_PERSON_PER_DAY / float(WorldState.TICKS_PER_DAY)
```

- [ ] **Step 3：跑 headless 確認**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd 2>&1 | Select-String "DONE|SCRIPT ERROR|food|Food"
```

預期：`=== DONE ===`，無 SCRIPT ERROR，食物消耗數值不變（等比換算）。

- [ ] **Step 4：Commit**

```
git add scripts/simulation/resource_system.gd
git commit -m "refactor(resource): FOOD_PER_PERSON_PER_DAY (was per-tick)"
```

---

## Task 7：MovementSystem → EncounterSystem 常數

**Files:**
- Modify: `scripts/simulation/movement_system.gd`

**⚠️ 前置確認：** 先確認 `EncounterSystem.MAP_DIAMETER` 和 `EncounterSystem.BASE_ACTION_TICKS` 存在：
```powershell
Select-String -Path scripts/simulation/encounter_system.gd -Pattern "MAP_DIAMETER|BASE_ACTION_TICKS"
```
若不存在，停止此 Task，通知主 session 先合併 encounter branch。

- [ ] **Step 1：替換常數定義**

將：
```gdscript
const BASE_MOVE_TICKS: int = 10
const MIN_MOVE_TICKS: int = 3
const MAX_MOVE_TICKS: int = 30
```
改為：
```gdscript
# world-hex 移動成本 = encounter-hex 動作時間 × 地圖直徑（1 world-hex = MAP_DIAMETER encounter-hex）
const BASE_MOVE_TICKS: int = EncounterSystem.BASE_ACTION_TICKS * EncounterSystem.MAP_DIAMETER
const MIN_MOVE_TICKS: int  = EncounterSystem.BASE_ACTION_TICKS * EncounterSystem.MAP_DIAMETER / 3
const MAX_MOVE_TICKS: int  = EncounterSystem.BASE_ACTION_TICKS * EncounterSystem.MAP_DIAMETER * 3
```

數值驗算（BASE_ACTION_TICKS=10, MAP_DIAMETER=20）：
- BASE_MOVE_TICKS = 10 × 20 = 200
- MIN_MOVE_TICKS  = 200 / 3 = 66（整數除法）
- MAX_MOVE_TICKS  = 200 × 3 = 600

- [ ] **Step 2：跑 headless 確認**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd 2>&1 | Select-String "DONE|SCRIPT ERROR|move|Move"
```

預期：`=== DONE ===`，無 SCRIPT ERROR，team 移動行為正常（不應出現 team 瞬移或完全不動）。

- [ ] **Step 3：Commit**

```
git add scripts/simulation/movement_system.gd
git commit -m "refactor(movement): BASE/MIN/MAX_MOVE_TICKS derived from EncounterSystem constants"
```

---

## Task 8：HeadlessTest 更新 assert

**Files:**
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1：加時間常數驗證**

在現有測試區（建議在 DataStruct 驗證段落附近）加：

```gdscript
print("--- TimeConstants ---")
assert(WorldState.TICKS_PER_MONTH  == WorldState.TICKS_PER_DAY * 30,
    "TICKS_PER_MONTH 應 = TICKS_PER_DAY*30")
assert(WorldState.TICKS_PER_SEASON == WorldState.TICKS_PER_DAY * 90,
    "TICKS_PER_SEASON 應 = TICKS_PER_DAY*90")
assert(WorldState.TICKS_PER_YEAR   == WorldState.TICKS_PER_DAY * 360,
    "TICKS_PER_YEAR 應 = TICKS_PER_DAY*360")
assert(SalarySystem.SALARY_INTERVAL == WorldState.TICKS_PER_MONTH,
    "SALARY_INTERVAL 應 = TICKS_PER_MONTH")
assert(HarvestSystem.SEASON_LENGTH  == WorldState.TICKS_PER_SEASON,
    "SEASON_LENGTH 應 = TICKS_PER_SEASON")
assert(PopulationSystem.OVERFLOW_CHECK_INTERVAL == WorldState.TICKS_PER_DAY,
    "OVERFLOW_CHECK_INTERVAL 應 = TICKS_PER_DAY")
print("TimeConstants OK — TICKS_PER_DAY=%d MONTH=%d SEASON=%d YEAR=%d" % [
    WorldState.TICKS_PER_DAY, WorldState.TICKS_PER_MONTH,
    WorldState.TICKS_PER_SEASON, WorldState.TICKS_PER_YEAR])
```

- [ ] **Step 2：更新既有的 ticks_per_day assert（若有）**

搜尋 `ticks_per_day` 相關 assert：
```powershell
Select-String -Path scripts/debug/headless_test.gd -Pattern "ticks_per_day"
```

這些 assert 測的是 instance field，與新加的 static const 共存，不需刪除。

- [ ] **Step 3：跑 headless 完整確認**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd 2>&1 | Select-String "DONE|SCRIPT ERROR|FAIL|TimeConstants"
```

預期：
- `TimeConstants OK — TICKS_PER_DAY=24 MONTH=720 SEASON=2160 YEAR=8640`
- `=== DONE ===`，無 SCRIPT ERROR，無 FAIL

- [ ] **Step 4：Commit**

```
git add scripts/debug/headless_test.gd
git commit -m "test: add TimeConstants assertions to headless_test"
```

---

## Task 9：最終驗證與 hand-back

- [ ] **Step 1：跑完整 1000 tick headless**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd 2>&1 | Select-String "DONE|SCRIPT ERROR|FAIL|TimeConstants|Salary|season"
```

預期：
- `TimeConstants OK`
- `=== DONE ===`
- 無 SCRIPT ERROR，無 FAIL
- `[Salary]` 在約 tick 720 出現
- 季節在 tick 2160 才換

- [ ] **Step 2：Push branch**

```powershell
git push -u origin <feature-branch-name>
```

- [ ] **Step 3：寫 hand-back**

建立 `docs/superpowers/handbacks/2026-05-31-time-constants-refactor.md`：

```markdown
# Hand Back: Time Constants Refactor

## 實作摘要
- `world_state.gd`：加 TICKS_PER_DAY/HOUR/MONTH/SEASON/YEAR/SECONDS_PER_TICK 常數
- `salary_system.gd`：SALARY_INTERVAL = WorldState.TICKS_PER_MONTH（數值不變 720）
- `harvest_system.gd`：SEASON_LENGTH = WorldState.TICKS_PER_SEASON（720→2160，行為變更）
- `population_system.gd`：OVERFLOW_CHECK_INTERVAL = WorldState.TICKS_PER_DAY（10→24）
- `sim_runner.gd`：FATIGUE_PER_DAY / FATIGUE_RECOVERY_PER_DAY（數值等比換算）
- `resource_system.gd`：FOOD_PER_PERSON_PER_DAY（數值等比換算）
- `movement_system.gd`：BASE/MIN/MAX_MOVE_TICKS 由 EncounterSystem 常數導出（10→200）
- `headless_test.gd`：加 TimeConstants assert

## 連動風險
- `harvest_system.gd` SEASON_LENGTH 從 720→2160，若其他系統依賴季節切換頻率需確認
- `movement_system.gd` BASE_MOVE_TICKS 從 10→200，團隊移動速度大幅降低，AI 行為（尤其 faction_ai 的目標追蹤）可能需要重新評估
- `population_system.gd` OVERFLOW_CHECK_INTERVAL 10→24，微小效能差異，行為等效

## 待主 session 確認
- SEASON_LENGTH=2160 導致 1000 tick headless 看不到 harvest 觸發，是否需調整測試 tick 數？
- BASE_MOVE_TICKS=200 是否合理（plains 標準速度 1.0 → 200 ticks/world-hex）？
```

- [ ] **Step 4：Commit hand-back，不 merge**

```
git add docs/superpowers/handbacks/2026-05-31-time-constants-refactor.md
git commit -m "docs: hand-back for time-constants-refactor"
```
