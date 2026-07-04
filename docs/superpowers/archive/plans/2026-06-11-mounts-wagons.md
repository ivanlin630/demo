# Mounts / Wagons 速度系統 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** mounts/wagons 加速度差異化（騎兵 max 3X、輜重 max −30%）+ 1 人 1 獸限制 + 馬廄 facility + 野外採集 + mount 吃糧 + 戰利品 loot + 移除 stray。

**Architecture:**
- `_compute_team_speed` 加 mount/wagon multiplier
- `get_effective_mounts/wagons` 1 人 1 獸（mount + wagon ≤ pop）
- `FACILITY_DEF` 加 "stable" entry
- `world_generator` 加 wild_horses tile resource
- `resource_system` mount 吃糧
- `encounter_system` loot mount
- 刪 `_tick_stray_mounts`

**Spec:** `docs/superpowers/specs/2026-06-11-mounts-wagons-design.md`

---

## 檔案結構

| 檔案 | 變更 |
|---|---|
| `scripts/simulation/movement_system.gd` | `get_effective_mounts/wagons` 1 人 1 獸；`_compute_team_speed` 加 mount/wagon mult；刪 `_tick_stray_mounts` |
| `scripts/simulation/outpost_system.gd` | `FACILITY_DEF` 加 `stable` entry |
| `scripts/simulation/world_generator.gd` | tile 生成加 wild_horses |
| `scripts/simulation/harvest_system.gd` | 採集 wild_horses → mounts |
| `scripts/simulation/resource_system.gd` | mount 食物消耗 |
| `scripts/simulation/encounter_system.gd` | `resolve_encounter_end` 記 prey_initial_pop + 加 mount loot |
| `scripts/data/team_data.gd` | 加 `prey_initial_pop_at_encounter`（or encounter_system 內快照）|
| `scripts/debug/headless_test.gd` | ~10 個測試 |

## 測試命令

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --import
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/game_sim_test.gd
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/game_sim_multi.gd
```

---

## Task 1: 1 人 1 獸限制 + speed mount/wagon mult

**Files:**
- Modify: `scripts/simulation/movement_system.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 測試**

```gdscript
func _test_effective_mount_wagon_limit() -> void:
	print("--- Mount Task1a: 1人1獸 ---")
	var ms = MovementSystem.new()
	var team := TeamData.new()
	team.population = 10
	team.resources = { "mounts": 5, "wagons": 8 }
	assert(ms.get_effective_mounts(team) == 5, "5 mounts < 10 pop")
	assert(ms.get_effective_wagons(team) == 5, "wagons cap by remaining pop (10-5)")
	team.resources["mounts"] = 12
	assert(ms.get_effective_mounts(team) == 10, "mount cap by pop")
	assert(ms.get_effective_wagons(team) == 0, "no remaining pop")
	print("Mount Task1a OK")

func _test_compute_mount_bonus() -> void:
	print("--- Mount Task1b: mount bonus 公式 ---")
	var ms = MovementSystem.new()
	var team := TeamData.new()
	team.population = 10
	team.resources = { "mounts": 10 }   # 全騎兵
	# ratio=1.0, size_penalty = 1 - 10/50*0.2 = 0.96 → bonus = 3.0*0.96 = 2.88
	var b = ms._compute_mount_bonus(team)
	assert(abs(b - 2.88) < 0.01, "全騎 expect 2.88, got %.2f" % b)
	team.resources["mounts"] = 0
	assert(ms._compute_mount_bonus(team) == 1.0)
	team.population = 50; team.resources["mounts"] = 50
	# ratio=1, size_penalty=0.8, bonus = 3.0*0.8 = 2.4
	var b2 = ms._compute_mount_bonus(team)
	assert(abs(b2 - 2.4) < 0.01, "50 騎 expect 2.4, got %.2f" % b2)
	print("Mount Task1b OK")

func _test_compute_wagon_penalty() -> void:
	var ms = MovementSystem.new()
	var team := TeamData.new()
	team.population = 10
	team.resources = { "wagons": 5 }
	# ratio = 0.5, penalty = 1 - 0.5*0.3 = 0.85
	assert(abs(ms._compute_wagon_penalty(team) - 0.85) < 0.01)
	print("Mount Task1c OK")
```

- [ ] **Step 2: 改 `get_effective_mounts/wagons`**

```gdscript
func get_effective_mounts(team: TeamData) -> int:
	return mini(int(team.resources.get("mounts", 0)), team.population)

func get_effective_wagons(team: TeamData) -> int:
	var rem: int = team.population - get_effective_mounts(team)
	return mini(int(team.resources.get("wagons", 0)), maxi(rem, 0))
```

- [ ] **Step 3: 加 mount/wagon helper + 整合到 `_compute_team_speed`**

```gdscript
func _compute_mount_bonus(team: TeamData) -> float:
	if team.population <= 0: return 1.0
	var em: int = get_effective_mounts(team)
	if em == 0: return 1.0
	var ratio: float = float(em) / float(team.population)
	var size_penalty: float = 1.0 - clampf(float(em) / 50.0, 0.0, 1.0) * 0.2
	return (1.0 + ratio * 2.0) * size_penalty

func _compute_wagon_penalty(team: TeamData) -> float:
	if team.population <= 0: return 1.0
	var ew: int = get_effective_wagons(team)
	if ew == 0: return 1.0
	var ratio: float = float(ew) / float(team.population)
	return 1.0 - ratio * 0.3
```

於既有 `_compute_team_speed` 結尾，return 前乘上：

```gdscript
var base_speed: float = ...   # 既有計算結果
return base_speed * _compute_mount_bonus(team) * _compute_wagon_penalty(team)
```

- [ ] **Step 4: 刪 `_tick_stray_mounts`**

刪 line 106 函數定義 + line 46 caller。

- [ ] **Step 5: 跑 + Commit**

```powershell
git add scripts/simulation/movement_system.gd scripts/debug/headless_test.gd
git commit -m "feat(movement): mount/wagon speed mult + 1人1獸 + 移除 stray (Task 1)"
```

---

## Task 2: Mount 食物消耗

**Files:**
- Modify: `scripts/simulation/resource_system.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 測試**

```gdscript
func _test_mount_food_consumption() -> void:
	# Setup: team pop 10 + 10 mounts + 1000 food
	# 跑 1 day = 240 tick
	# Expected: food 減 10 mounts × 0.5 = 5 額外 + 10 人 × 2.4 = 24 = 29
	# ...
	print("Mount Task2 OK")
```

- [ ] **Step 2: 加 mount 消耗**

於 `_tick_team_resources`（或既有食物消耗位置），加：

```gdscript
const FOOD_PER_MOUNT_PER_DAY: float = 0.5

# 既有人口食物消耗後加
var em: int = MovementSystem.get_effective_mounts(team)
if em > 0:
    var mount_food: float = float(em) * FOOD_PER_MOUNT_PER_DAY * day_fraction
    team.resources["food"] = maxf(0.0, float(team.resources.get("food", 0)) - mount_food)
```

注意 `get_effective_mounts` 是 movement_system instance method，要 `MovementSystem.new().get_effective_mounts(team)` 或改為 static。

- [ ] **Step 3: 跑 + Commit**

```powershell
git add scripts/simulation/resource_system.gd scripts/debug/headless_test.gd
git commit -m "feat(resource): mount 食物消耗 0.5/day (Task 2)"
```

---

## Task 3: 馬廄 facility

**Files:**
- Modify: `scripts/simulation/outpost_system.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 測試**

```gdscript
func _test_stable_facility_def() -> void:
	assert(OutpostSystem.FACILITY_DEF.has("stable"))
	var s = OutpostSystem.FACILITY_DEF["stable"]
	assert(s["category"] == "軍事" or s["category"] == "生產")
	assert(s["cost"]["material"] == 30)
	print("Mount Task3a OK")

func _test_stable_produces_mounts() -> void:
	# Setup: tile with stable level 1 + outpost + team with food
	# 跑 1 month = 7200 tick
	# Expected: team mounts +9 (0.3/day * 30 days)
	# ...
	print("Mount Task3b OK")
```

- [ ] **Step 2: 加 FACILITY_DEF entry**

```gdscript
const FACILITY_DEF: Dictionary = {
	# 既有 farming / manufacturing / mint ...
	"stable": {
		"cost":              { "material": 30, "coin": 50, "ticks": 7200 },
		"cap_by_outpost":    { "civilian": [1, 2, 3], "military": [1, 2, 3] },
		"category":          "軍事",
		"trigger_check":     "_check_mount_demand",   # 軍隊/商隊 tag + plains
		"leader_pref":       { "野心": 0.2, "好戰": 0.3 },
		"current_level_key": "stable_level",
		"produces_per_day":  { "mounts": 0.3 },
		"consumes_per_day":  { "food": 5.0 },
		"required_terrain":  "plains",
	},
}
```

- [ ] **Step 3: tile.stable_level 欄位 + 生產邏輯**

`tile_data.gd` 加 `var stable_level: int = 0`。

`outpost_system` 既有 facility 生產 tick 函數加 stable 處理：每 day per level → +0.3/0.7/1.0 mounts to outpost owner team。

- [ ] **Step 4: NPC AI check_mount_demand**

```gdscript
func _check_mount_demand(state, team, tile) -> bool:
	if tile.terrain != "plains": return false
	if not ("軍隊" in team.tags or "商隊" in team.tags): return false
	var ratio: float = float(team.resources.get("mounts", 0)) / maxf(float(team.population), 1.0)
	return ratio < 0.5
```

- [ ] **Step 5: 跑 + Commit**

```powershell
git add scripts/simulation/outpost_system.gd scripts/data/tile_data.gd scripts/debug/headless_test.gd
git commit -m "feat(facility): stable (馬廄) facility + NPC demand check (Task 3)"
```

---

## Task 4: 野外採集 wild_horses

**Files:**
- Modify: `scripts/simulation/world_generator.gd`
- Modify: `scripts/simulation/harvest_system.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 測試**

```gdscript
func _test_wild_horses_generation() -> void:
	# 跑 world_generator 1000 次 → 應該約 1% plains tile 有 wild_horses
	# ...
	print("Mount Task4a OK")

func _test_wild_horses_harvest() -> void:
	# Setup: team on tile with wild_horses=2 + task=採集
	# Expected: team.mounts += 2, tile.wild_horses = 0
	# ...
	print("Mount Task4b OK")
```

- [ ] **Step 2: world_generator 加生成**

於 tile 初始化加：

```gdscript
match tile.terrain:
	"plains":
		if randf() < 0.01:
			tile.resources["wild_horses"] = randi_range(1, 2)
	"forest":
		if randf() < 0.005:
			tile.resources["wild_horses"] = 1
```

- [ ] **Step 3: harvest_system 加採集**

於 `harvest_system._harvest_tile`（或既有採集點）加 wild_horses 採集：

```gdscript
var wh: int = int(tile.resources.get("wild_horses", 0))
if wh > 0:
	team.resources["mounts"] = int(team.resources.get("mounts", 0)) + wh
	tile.resources["wild_horses"] = 0
```

再生：每月 5% chance +1 per tile。

- [ ] **Step 4: 跑 + Commit**

```powershell
git add scripts/simulation/world_generator.gd scripts/simulation/harvest_system.gd scripts/debug/headless_test.gd
git commit -m "feat(world): wild_horses 野採 + 慢再生 (Task 4)"
```

---

## Task 5: 戰利品 mount loot

**Files:**
- Modify: `scripts/simulation/encounter_system.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 測試**

```gdscript
func _test_mount_loot_total_wipe() -> void:
	# prey 10 pop + 5 mounts → 全滅 → winner gets 5
	# ...
	print("Mount Task5a OK")

func _test_mount_loot_partial() -> void:
	# prey 10 pop + 5 mounts → 死 6 → winner gets 3
	# ...
	print("Mount Task5b OK")
```

- [ ] **Step 2: encounter_system 加初始 pop 快照**

`init_encounter` 內，記錄 attacker / defender initial_pop：

```gdscript
# 既有
var atk: TeamData = state.teams.get(state.encounter_attacker_id)
var def: TeamData = state.teams.get(state.encounter_defender_id)
if atk: atk.encounter_initial_pop = atk.population
if def: def.encounter_initial_pop = def.population
```

team_data 加 `var encounter_initial_pop: int = 0`。

- [ ] **Step 3: resolve_encounter_end 加 loot 邏輯**

於既有勝負結算後加：

```gdscript
# mount loot
var winner_id: int = -1
var loser_id: int = -1
if result == "attacker_win":
	winner_id = atk_id; loser_id = def_id
elif result == "defender_win":
	winner_id = def_id; loser_id = atk_id
if winner_id != -1 and loser_id != -1:
	var loser: TeamData = state.teams.get(loser_id)
	var winner: TeamData = state.teams.get(winner_id)
	if loser != null and winner != null:
		var initial: int = loser.encounter_initial_pop
		if initial > 0:
			var dead: int = initial - loser.population
			var ratio: float = float(dead) / float(initial)
			var loser_mounts: int = int(loser.resources.get("mounts", 0))
			var loot: int = roundi(float(loser_mounts) * ratio)
			loser.resources["mounts"] = loser_mounts - loot
			winner.resources["mounts"] = int(winner.resources.get("mounts", 0)) + loot
			if loot > 0:
				print("[Loot] Team%d → Team%d mounts +%d" % [loser_id, winner_id, loot])
```

- [ ] **Step 4: 跑 + Commit**

```powershell
git add scripts/simulation/encounter_system.gd scripts/data/team_data.gd scripts/debug/headless_test.gd
git commit -m "feat(encounter): mount loot 戰利品 公式 (Task 5)"
```

---

## Task 6: 整合驗證 + handback

**Files:**
- Create: `docs/superpowers/handbacks/2026-06-11-mounts-wagons.md`

- [ ] **Step 1: 跑全測試 + multi**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --import
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/game_sim_test.gd > godot_test.log 2>&1
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/game_sim_multi.gd > godot_multi.log 2>&1
Get-Content godot_multi.log -Encoding UTF8 | Select-String "Combat Start|stable|wild_horses|Loot.*mount" | Group-Object | Select-Object Count, Name | Sort-Object Count -Descending
```

預期：
- ALL INVARIANTS PASSED
- multi 中可能有 stable 建造 + mount 採集 + mount loot
- Combat 可能因 mount 速度差出現 > 0（部分解 W1）

- [ ] **Step 2: 寫 handback**

`docs/superpowers/handbacks/2026-06-11-mounts-wagons.md`：

```markdown
# Hand Back: Mounts / Wagons 速度系統

## 實作摘要

- movement_system：mount/wagon speed mult + 1人1獸 + 刪 stray
- resource_system：mount 食物消耗 0.5/day
- outpost_system：stable facility + check_mount_demand
- world_generator + harvest_system：wild_horses 1% 生成 + 採集
- encounter_system：mount loot 戰利品（initial_pop 快照）

## 行為變化

- 騎兵 vs 步兵速度差最大 4.3X（菁英全騎 vs 平民全步）
- 1 人 1 獸（mount + wagon ≤ pop）
- mount 吃糧加大食物消耗
- mount 取得：facility 眷養 + 野外採集 + 戰利品

## 驗證結果

- headless_test：N/N 過
- game_sim_test：ALL INVARIANTS PASSED
- game_sim_multi：[填數據]

## 待主 session 確認

- mount bonus / size_penalty 參數 tune
- stable food cost 30/month 是否過重
- wild_horses 1% 機率是否過稀
- Combat=0 是否因 mount 速度差有改善
```

- [ ] **Step 3: Commit**

```powershell
git add docs/superpowers/handbacks/2026-06-11-mounts-wagons.md
git commit -m "docs: mounts/wagons handback (Task 6)"
```
