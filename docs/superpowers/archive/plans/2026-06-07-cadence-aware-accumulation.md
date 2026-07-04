# Cadence-Aware 累積公式重構 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 把食物/疲勞累積公式改為 cadence-aware（每 call 計算 `cadence_ticks / TICKS_PER_DAY` 的量），抽出 `NEAR_CADENCE` 常數，薪水週期從 1 月縮短到 1 週。

**Architecture:** `sim_runner` 加 `NEAR_CADENCE` 常數，line 80 從 `% TICKS_PER_HOUR` 改為 `% NEAR_CADENCE`。`resource_system.resolve_consumption` 與 `sim_runner._step6d_fatigue` 簽名加 `cadence_ticks` 參數，呼叫端傳 `NEAR_CADENCE`（near block）或 `FAR_ZONE_INTERVAL`（far block）。`SALARY_INTERVAL` 改為 `TICKS_PER_DAY × 7`。

**Tech Stack:** Godot 4.2.2 GDScript；headless test 透過 `Godot_v4.2.2-stable_win64_console.exe --headless --script` 執行。

**Spec:** `docs/superpowers/specs/2026-06-07-cadence-aware-accumulation-design.md`

---

## 檔案結構

| 檔案 | 變更 |
|---|---|
| `scripts/simulation/sim_runner.gd` | 加 `NEAR_CADENCE` 常數；line 80 cadence 判斷改 `NEAR_CADENCE`；`_step6d_fatigue` 簽名加 `cadence_ticks`；公式 cadence-aware |
| `scripts/simulation/resource_system.gd` | `resolve_consumption` 簽名加 `cadence_ticks`；公式改 cadence-aware |
| `scripts/simulation/salary_system.gd` | `SALARY_INTERVAL` 由 `TICKS_PER_MONTH` 改 `TICKS_PER_DAY × 7` |
| `scripts/debug/headless_test.gd` | 加 4 個累積總量測試 |
| `docs/tick_parameters.md` | 修正「12.5 天斷糧」為「125 天 → 修完 12.5 天」 |
| `docs/known_issues.md` | 加新 issue 標 `p.salary` 預設值需平衡（週發薪後月支出 4 倍） |

## 執行測試的標準命令

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/game_sim_test.gd
```

---

## Task 1: 加 NEAR_CADENCE 常數 + line 80 改判斷

**Files:**
- Modify: `scripts/simulation/sim_runner.gd:4` 附近加常數，line 80 改判斷

- [ ] **Step 1: 加常數**

打開 `scripts/simulation/sim_runner.gd`，找 line 4 附近的 `FAR_ZONE_INTERVAL` 宣告。在它後面加：

```gdscript
const NEAR_CADENCE: int = WorldState.TICKS_PER_HOUR   # TEST VALUE — 近區更新頻率（1h，可調）
```

- [ ] **Step 2: 改 line 80 判斷**

找：

```gdscript
if state.world.current_tick % WorldState.TICKS_PER_HOUR == 0:
```

改為：

```gdscript
if state.world.current_tick % NEAR_CADENCE == 0:
```

- [ ] **Step 3: 跑測試確認無 regression**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/game_sim_test.gd
```

預期：headless_test 全 OK；game_sim_test `ALL INVARIANTS PASSED`。

- [ ] **Step 4: Commit**

```powershell
git add scripts/simulation/sim_runner.gd
git commit -m "refactor(sim_runner): extract NEAR_CADENCE constant (Task 1)"
```

---

## Task 2: `resource_system.resolve_consumption` cadence-aware

**Files:**
- Modify: `scripts/simulation/resource_system.gd:60-66`
- Modify: `scripts/simulation/sim_runner.gd:100, 126, 202-203`（呼叫端）
- Modify: `scripts/debug/headless_test.gd`（加食物總量測試）

- [ ] **Step 1: 加失敗測試**

打開 `scripts/debug/headless_test.gd`，在末尾 `quit()` 前加：

```gdscript
func _test_food_consumption_total() -> void:
	print("--- Cadence Task2: 食物消耗總量 ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	var team := TeamData.new()
	team.team_id = 0
	team.population = 10
	team.minor_population = 0
	team.resources["food"] = 2400.0
	state.teams[0] = team
	var rs := ResourceSystem.new()
	# 模擬跑 1 天（240 tick），每 NEAR_CADENCE=10 call 一次 → 24 calls
	for _i in range(24):
		rs.resolve_consumption(state, [0], 10)
	# 預期消耗：10 × 2.4 = 24 食物/天 → 剩 2376
	var remaining: float = float(team.resources["food"])
	assert(remaining >= 2375.0 and remaining <= 2377.0,
		"1 天後應剩 ~2376，實際=%s" % str(remaining))
	print("Cadence Task2 OK")
```

於 `_initialize()` 加：

```gdscript
	_test_food_consumption_total()
```

- [ ] **Step 2: 跑測試確認失敗**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

預期：`Too few arguments` 或函數簽名不符 → 或 assertion fail（公式還沒改）。

- [ ] **Step 3: 改 `resolve_consumption` 簽名與公式**

打開 `scripts/simulation/resource_system.gd` line 60，把：

```gdscript
func resolve_consumption(state: WorldState, team_ids: Array) -> void:
	for tid in team_ids:
		if not state.teams.has(tid):
			continue
		var team: TeamData = state.teams[tid]
		var total_pop: int = team.population + team.minor_population
		var food_needed: float = float(total_pop) * FOOD_PER_PERSON_PER_DAY / float(WorldState.TICKS_PER_DAY)
```

改為：

```gdscript
func resolve_consumption(state: WorldState, team_ids: Array, cadence_ticks: int) -> void:
	var day_fraction: float = float(cadence_ticks) / float(WorldState.TICKS_PER_DAY)
	for tid in team_ids:
		if not state.teams.has(tid):
			continue
		var team: TeamData = state.teams[tid]
		var total_pop: int = team.population + team.minor_population
		var food_needed: float = float(total_pop) * FOOD_PER_PERSON_PER_DAY * day_fraction
```

- [ ] **Step 4: 改 sim_runner 呼叫端**

打開 `scripts/simulation/sim_runner.gd` line 202-203，把：

```gdscript
func _step6_resolve_consumption(state: WorldState, team_ids: Array) -> void:
	_resource_system.resolve_consumption(state, team_ids)
```

改為：

```gdscript
func _step6_resolve_consumption(state: WorldState, team_ids: Array, cadence_ticks: int) -> void:
	_resource_system.resolve_consumption(state, team_ids, cadence_ticks)
```

改 line 100（near block）：

```gdscript
_step6_resolve_consumption(state, near_teams, NEAR_CADENCE)
```

改 line 126（far block）：

```gdscript
_step6_resolve_consumption(state, far_teams, FAR_ZONE_INTERVAL)
```

- [ ] **Step 5: 跑測試確認通過**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

預期：
```
--- Cadence Task2: 食物消耗總量 ---
Cadence Task2 OK
```

- [ ] **Step 6: 跑 game_sim_test 確認主遊戲不壞**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/game_sim_test.gd
```

預期：`ALL INVARIANTS PASSED`。注意：現在食物消耗變 10 倍，game_sim_test 的初始 food=5000 應該夠（10 人 × 2.4 = 24/天 × 30 天 = 720 食物消耗，遠少於 5000）。

- [ ] **Step 7: Commit**

```powershell
git add scripts/simulation/resource_system.gd scripts/simulation/sim_runner.gd scripts/debug/headless_test.gd
git commit -m "fix(resource): cadence-aware food consumption (Task 2)"
```

---

## Task 3: `_step6d_fatigue` cadence-aware

**Files:**
- Modify: `scripts/simulation/sim_runner.gd:216, 223`（公式 + 簽名）
- Modify: `scripts/debug/headless_test.gd`（加疲勞總量測試）

- [ ] **Step 1: 找 _step6d_fatigue 函數位置**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

打開 `scripts/simulation/sim_runner.gd`，grep `_step6d_fatigue`，找到函數定義（line 200 附近）與呼叫端（line 102, 128）。

- [ ] **Step 2: headless_test 加失敗測試**

於 `headless_test.gd` 末尾 `quit()` 前加：

```gdscript
func _test_fatigue_accumulation() -> void:
	print("--- Cadence Task3: 疲勞累積總量 ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	var team := TeamData.new()
	team.team_id = 0
	team.population = 10
	team.fatigue = 0.0
	team.current_task = TeamData.TASK_ATTACK   # 行軍狀態
	team.tile_pos = Vector2i(0, 0)
	# 設定地形為 plains
	var tile := HexTileData.new()
	tile.terrain = "plains"
	state.world.tiles[0] = tile
	state.teams[0] = team
	var sr := SimRunner.new()
	# 模擬跑 1 天（24 calls）
	for _i in range(24):
		sr._step6d_fatigue(state, [0], 10)
	# 預期：0.048/day → ≈ 0.048
	assert(team.fatigue >= 0.04 and team.fatigue <= 0.06,
		"1 天行軍後 fatigue 應 ~0.048，實際=%s" % str(team.fatigue))
	print("Cadence Task3 OK")
```

於 `_initialize()` 加：

```gdscript
	_test_fatigue_accumulation()
```

- [ ] **Step 3: 跑測試確認失敗**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

預期：`Too few arguments` 或 assertion fail（公式還是用 /TICKS_PER_DAY，1 天累積 0.0048 ≠ 0.048）。

- [ ] **Step 4: 改 `_step6d_fatigue` 簽名與公式**

打開 `scripts/simulation/sim_runner.gd`，找 `_step6d_fatigue` 函數。把簽名加 `cadence_ticks: int`：

```gdscript
func _step6d_fatigue(state: WorldState, team_ids: Array, cadence_ticks: int) -> void:
	var day_fraction: float = float(cadence_ticks) / float(WorldState.TICKS_PER_DAY)
	# ... 原邏輯 ...
```

把 line 216 的：

```gdscript
team.fatigue -= FATIGUE_RECOVERY_PER_DAY / float(WorldState.TICKS_PER_DAY) * rest_mult
```

改為：

```gdscript
team.fatigue -= FATIGUE_RECOVERY_PER_DAY * day_fraction * rest_mult
```

把 line 223 的：

```gdscript
team.fatigue += FATIGUE_PER_DAY / float(WorldState.TICKS_PER_DAY) * terrain_mult * time_mult
```

改為：

```gdscript
team.fatigue += FATIGUE_PER_DAY * day_fraction * terrain_mult * time_mult
```

注意：`FATIGUE_LOYALTY_PENALTY`（line 228 `p.loyalty -= FATIGUE_LOYALTY_PENALTY`）**不動**，它是 per-call penalty，非 per-day rate。

- [ ] **Step 5: 改呼叫端傳入 cadence**

找到 `sim_runner` 內呼叫 `_step6d_fatigue` 的地方（line 102 near block、line 128 far block）。

near 改：

```gdscript
_step6d_fatigue(state, near_teams, NEAR_CADENCE)
```

far 改：

```gdscript
_step6d_fatigue(state, far_teams, FAR_ZONE_INTERVAL)
```

- [ ] **Step 6: 跑測試確認通過**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

預期：
```
--- Cadence Task3: 疲勞累積總量 ---
Cadence Task3 OK
```

- [ ] **Step 7: 跑 game_sim_test**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/game_sim_test.gd
```

預期：`ALL INVARIANTS PASSED`。

- [ ] **Step 8: Commit**

```powershell
git add scripts/simulation/sim_runner.gd scripts/debug/headless_test.gd
git commit -m "fix(sim_runner): cadence-aware fatigue (Task 3)"
```

---

## Task 4: 疲勞回復測試 + game_sim_test 連動驗證

**Files:**
- Modify: `scripts/debug/headless_test.gd`（加疲勞回復測試）

- [ ] **Step 1: 加疲勞回復測試**

於 `headless_test.gd` 末尾加：

```gdscript
func _test_fatigue_recovery() -> void:
	print("--- Cadence Task4: 疲勞回復總量 ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	var team := TeamData.new()
	team.team_id = 0
	team.population = 10
	team.fatigue = 1.0   # 從滿開始
	team.current_task = TeamData.TASK_IDLE   # 紮營
	team.tile_pos = Vector2i(0, 0)
	var tile := HexTileData.new()
	tile.terrain = "plains"
	state.world.tiles[0] = tile
	state.teams[0] = team
	var sr := SimRunner.new()
	# 跑 1 天紮營
	for _i in range(24):
		sr._step6d_fatigue(state, [0], 10)
	# 預期：fatigue -= 0.24/day → ≈ 0.76
	assert(team.fatigue >= 0.74 and team.fatigue <= 0.78,
		"1 天紮營後 fatigue 應 ~0.76，實際=%s" % str(team.fatigue))
	print("Cadence Task4 OK")
```

於 `_initialize()` 加：

```gdscript
	_test_fatigue_recovery()
```

- [ ] **Step 2: 跑測試確認通過**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

預期：
```
--- Cadence Task4: 疲勞回復總量 ---
Cadence Task4 OK
```

- [ ] **Step 3: Commit**

```powershell
git add scripts/debug/headless_test.gd
git commit -m "test: fatigue recovery cadence-aware verification (Task 4)"
```

---

## Task 5: SALARY_INTERVAL 改 1 週

**Files:**
- Modify: `scripts/simulation/salary_system.gd:3`
- Modify: `scripts/debug/headless_test.gd`（加薪水週期測試）

- [ ] **Step 1: headless_test 加薪水週期測試**

於 `headless_test.gd` 末尾加：

```gdscript
func _test_salary_interval_weekly() -> void:
	print("--- Cadence Task5: 薪水週期 ---")
	# SALARY_INTERVAL 應為 1 週（240 × 7 = 1680 tick）
	assert(SalarySystem.SALARY_INTERVAL == WorldState.TICKS_PER_DAY * 7,
		"SALARY_INTERVAL 應為 1 週(1680)，實際=%s" % str(SalarySystem.SALARY_INTERVAL))
	# 確認 NEAR_CADENCE 整除性（1680 % 10 == 0）
	assert(SalarySystem.SALARY_INTERVAL % SimRunner.NEAR_CADENCE == 0,
		"SALARY_INTERVAL 必須是 NEAR_CADENCE 倍數")
	print("Cadence Task5 OK")
```

於 `_initialize()` 加：

```gdscript
	_test_salary_interval_weekly()
```

- [ ] **Step 2: 跑測試確認失敗**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

預期：assertion fail，因為 `SALARY_INTERVAL = TICKS_PER_MONTH = 7200 ≠ 1680`。

- [ ] **Step 3: 改 `SALARY_INTERVAL`**

打開 `scripts/simulation/salary_system.gd` line 3，把：

```gdscript
const SALARY_INTERVAL: int = WorldState.TICKS_PER_MONTH   # 1月/次
```

改為：

```gdscript
const SALARY_INTERVAL: int = WorldState.TICKS_PER_DAY * 7   # 1週/次
```

- [ ] **Step 4: 跑測試確認通過**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

預期：
```
--- Cadence Task5: 薪水週期 ---
Cadence Task5 OK
```

- [ ] **Step 5: 跑 game_sim_test 確認**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/game_sim_test.gd
```

預期：`ALL INVARIANTS PASSED`。注意：跑 500 tick 不會觸發薪水（1680 > 500），但若 game_sim 改跑 7200 tick，會觸發 4 次而非 1 次。確認 coin 不會被扣到負（>0）。

- [ ] **Step 6: Commit**

```powershell
git add scripts/simulation/salary_system.gd scripts/debug/headless_test.gd
git commit -m "feat(salary): change interval from monthly to weekly (Task 5)"
```

---

## Task 6: 驗證所有 interval 是 NEAR_CADENCE 倍數

**Files:**
- Modify: `scripts/debug/headless_test.gd`（加整除性 assertion）

- [ ] **Step 1: 加整除性測試**

於 `headless_test.gd` 末尾加：

```gdscript
func _test_intervals_divisible_by_cadence() -> void:
	print("--- Cadence Task6: interval 整除性 ---")
	var cadence: int = SimRunner.NEAR_CADENCE
	# 列出所有應該被 cadence 觸發的 interval 常數
	var intervals: Dictionary = {
		"STRATEGIC_INTERVAL":      StrategicAiSystem.STRATEGIC_INTERVAL,
		"ALLIANCE_CHECK_INTERVAL": StrategicAiSystem.ALLIANCE_CHECK_INTERVAL,
		"BETRAY_CHECK_INTERVAL":   DiplomaticAiSystem.BETRAY_CHECK_INTERVAL,
		"FACTION_UPDATE_INTERVAL": FactionAISystem.FACTION_UPDATE_INTERVAL,
		"COLLECT_INTERVAL":        FactionAISystem.COLLECT_INTERVAL,
		"GOAL_CHECK_INTERVAL":     ReactionSystem.GOAL_CHECK_INTERVAL,
		"SALARY_INTERVAL":         SalarySystem.SALARY_INTERVAL,
		"FAR_ZONE_INTERVAL":       SimRunner.FAR_ZONE_INTERVAL,
		"OVERFLOW_CHECK_INTERVAL": PopulationSystem.OVERFLOW_CHECK_INTERVAL,
	}
	for name in intervals:
		var val: int = intervals[name]
		assert(val % cadence == 0,
			"%s=%d 必須是 NEAR_CADENCE(%d) 倍數" % [name, val, cadence])
	# TICKS_PER_DAY 也必須整除（保證每天整除次數）
	assert(WorldState.TICKS_PER_DAY % cadence == 0,
		"TICKS_PER_DAY 必須是 NEAR_CADENCE 倍數")
	print("Cadence Task6 OK")
```

於 `_initialize()` 加：

```gdscript
	_test_intervals_divisible_by_cadence()
```

- [ ] **Step 2: 跑測試確認通過**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

預期：
```
--- Cadence Task6: interval 整除性 ---
Cadence Task6 OK
```

若有任何 interval 不整除（例如將來改 NEAR_CADENCE 為 60），這個測試會立刻 fail，提示需要重新評估該 interval。

- [ ] **Step 3: Commit**

```powershell
git add scripts/debug/headless_test.gd
git commit -m "test: assert all intervals divisible by NEAR_CADENCE (Task 6)"
```

---

## Task 7: 更新文件

**Files:**
- Modify: `docs/tick_parameters.md`
- Modify: `docs/known_issues.md`

- [ ] **Step 1: 修 tick_parameters.md**

打開 `docs/tick_parameters.md` 找到「食物存量參考」一節（line 46-49）：

```markdown
### 食物存量參考（主場景 test setup）
- 初始 food = 300，人口 = 10
- 每天消耗 = 10 × 0.1 × 24 = **24 food/天**
- 無 outpost → 300 food ÷ 24 = **約 12.5 天後斷糧**
```

改為：

```markdown
### 食物存量參考（主場景 test setup，cadence-aware 修正後）
- 初始 food = 300，人口 = 10
- 每天消耗 = 10 × `FOOD_PER_PERSON_PER_DAY (2.4)` = **24 food/天**
- 無 outpost → 300 food ÷ 24 = **約 12.5 天後斷糧**

> 註：2026-06-07 之前公式 bug 導致實際消耗為設計值 1/10（每天 2.4 食物 → 125 天），cadence-aware 修正後對齊設計值。
```

找「主要問題清單」（line 117 附近），加一行：

```markdown
| 食物/疲勞 1/10 速率 bug | 公式 /TICKS_PER_DAY 假設每 tick 跑，實際每 hour | ✅ 已修（2026-06-07，cadence-aware）|
```

並把 SALARY_INTERVAL 表更新（line 57 附近）：

```markdown
| `SALARY_INTERVAL` | `simulation/salary_system.gd:3` | **1680** | 每週發薪 | — | — |
```

- [ ] **Step 2: 修 known_issues.md 加技術債項目**

打開 `docs/known_issues.md`，在 `### A2.` 之後加：

```markdown
### S8. `p.salary` 預設值未對齊週發薪語意
- **症狀**：`SALARY_INTERVAL` 改為 1 週後，月發薪總量變 4 倍；`p.salary` 若原為月薪意圖則玩家月支出爆增
- **位置**：`scripts/simulation/sim_runner.gd`、`scripts/data/person_data.gd`、各 `game_setup`
- **建議**：grep 所有設定 `p.salary = N` 的地方，N 改為 N/4；或加註解明確「per-pay-period」語意
- **連動**：2026-06-07 cadence-aware 修正後浮現
```

- [ ] **Step 3: Commit**

```powershell
git add docs/tick_parameters.md docs/known_issues.md
git commit -m "docs: update tick_parameters food rate + add S8 salary balance issue (Task 7)"
```

---

## Task 8: 整體驗證

- [ ] **Step 1: 三個測試腳本連跑**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/game_sim_test.gd
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/encounter_sim_test.gd
```

預期：
- headless_test：全 OK，含新加的 5 個 Cadence Task 測試
- game_sim_test：`ALL INVARIANTS PASSED`
- encounter_sim_test：正常結束（attacker_win / defender_win）

- [ ] **Step 2: 確認沒有遺漏的 % TICKS_PER_HOUR == 0 殘留**

```bash
grep -rn "% WorldState.TICKS_PER_HOUR" scripts/ --include="*.gd"
```

應只有 `sim_runner` 內 `% NEAR_CADENCE` 改完的版本，**無 `% WorldState.TICKS_PER_HOUR` 殘留**（其他系統若有用 `TICKS_PER_HOUR` 作為單位也 OK，只是 `% TICKS_PER_HOUR == 0` 模式應全部消失）。

如果有殘留，**回頭評估**是否該檔案也需要 cadence-aware 改造。可能存在的：
- `day_night_system` 內計算白天/夜晚（不該改，是「絕對時間」邏輯）

通常 day/night 用 `current_tick % TICKS_PER_DAY` 算位置，不會 fail，但若有 `% TICKS_PER_HOUR == 0` 邏輯，需個案評估。

- [ ] **Step 3: 撰寫 hand-back 文件**

於 `docs/superpowers/handbacks/2026-06-07-cadence-aware-accumulation.md` 寫實作摘要：

```markdown
# Hand Back: Cadence-Aware 累積公式重構

## 實作摘要

- `sim_runner.gd`：加 `NEAR_CADENCE = TICKS_PER_HOUR` 常數；line 80 cadence 改 NEAR_CADENCE
- `resource_system.gd`：`resolve_consumption` 簽名加 `cadence_ticks`，公式改為 `pop × FOOD_PER_PERSON_PER_DAY × day_fraction`
- `sim_runner._step6d_fatigue`：簽名加 `cadence_ticks`，公式改為 `FATIGUE_PER_DAY × day_fraction × ...`
- `salary_system.gd`：`SALARY_INTERVAL` 由 TICKS_PER_MONTH 改 TICKS_PER_DAY × 7（1 週）
- `headless_test.gd`：加 5 個 Cadence Task 測試
- `docs/tick_parameters.md`：修「12.5 天」說明
- `docs/known_issues.md`：加 S8 `p.salary` 平衡技術債

## 行為變化

- 食物消耗：0.24/人/天 → **2.4/人/天**（10 倍）
- 疲勞累積：0.0048/天 → **0.048/天**（20.8 天滿）
- 疲勞回復：0.024/天 → **0.24/天**（4.2 天回滿）
- 薪水：每月 1 次 → **每週 1 次**（月支出 4 倍，需平衡 p.salary）

## 連動風險

- main.gd test setup 食物 300 → 12.5 天斷糧（從 125 天）。已存在 known_issues S5
- demo 場景 `p.salary` 預設值需手動降 25%（S8）
- 任何依賴「每月發薪一次」的事件 / NPC 反應需檢查

## 待主 session 確認

- main.gd test setup 是否需要加初始 food（連動 S5）
- p.salary 全域降 25% 是否要包在這個 sprint 還是另開
```

- [ ] **Step 4: Commit hand-back**

```powershell
git add docs/superpowers/handbacks/2026-06-07-cadence-aware-accumulation.md
git commit -m "docs: cadence-aware refactor handback (Task 8)"
```
