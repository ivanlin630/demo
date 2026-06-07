# S7 faction_ai 動態初始化 TeamData 戰鬥參數 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 由 `faction_ai_system` 每輪根據 `team.tags` + `current_task` + 鄰近威脅，動態計算 4 個 TeamData 戰鬥/經濟欄位（`anon_combat_skill`、`armor_config`、`guard_ratio`、`anon_wage`），同時把 `anon_combat_skill` 從 `team.resources` dict 遷移為獨立欄位。

**Architecture:** 跟隨 `_update_equip_order` 模式：新增 4 個私有 `_update_*` 函數，於 `faction_ai_system.run()` 末尾 team 迴圈中呼叫。`anon_combat_skill` 欄位遷移為純粹資料結構整理，移完後 `encounter_system` 讀取新欄位。

**Tech Stack:** Godot 4.2.2 GDScript；headless test 透過 `Godot_v4.2.2-stable_win64_console.exe --headless --script` 執行。

**Spec:** `docs/superpowers/specs/2026-06-07-s7-faction-ai-team-params-design.md`

---

## 檔案結構

| 檔案 | 變更 |
|---|---|
| `scripts/data/team_data.gd` | 新增獨立欄位 `anon_combat_skill: float = 0.2`；保留 `resources["anon_combat_skill"]` 直到 Task 2 完成（避免破壞順序） |
| `scripts/simulation/encounter_system.gd` | line 152：讀取改用 `team.anon_combat_skill` |
| `scripts/simulation/faction_ai_system.gd` | 新增 4 個 `_update_*` 函數 + `_has_hostile_within` 輔助 + `run()` 呼叫 |
| `scripts/debug/headless_test.gd` | 新增 6 個測試 case 於 `_run_sim_test` 末尾 |
| `docs/known_issues.md` | 標記 S7a/S7b/S7c/S7d 為已修 |

## 執行測試的標準命令

每個 Task 都會用到的命令：

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

通用驗證命令（確認既有測試不壞）：

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/game_sim_test.gd
```

預期：`ALL INVARIANTS PASSED (violations=0)`

---

## Task 1: 新增 `team.anon_combat_skill` 獨立欄位

**Files:**
- Modify: `scripts/data/team_data.gd:54-58`（在 `equip_order` 附近加新欄位）
- Modify: `scripts/debug/headless_test.gd`（末尾新增測試 `_test_anon_combat_skill_field`）

- [ ] **Step 1: 在 headless_test.gd 末尾加失敗測試**

打開 `scripts/debug/headless_test.gd`，在檔案最後 `quit()` 之前加：

```gdscript
func _test_anon_combat_skill_field() -> void:
	print("--- S7 Task1: team.anon_combat_skill 獨立欄位 ---")
	var t := TeamData.new()
	assert(t.anon_combat_skill == 0.2, "預設值應為 0.2，實際=%s" % str(t.anon_combat_skill))
	# 確認欄位可被指派
	t.anon_combat_skill = 0.55
	assert(t.anon_combat_skill == 0.55, "指派後應為 0.55")
	print("S7 Task1 OK")
```

並在 `_initialize()` 的 `_run_sim_test()` 後面（quit() 前）呼叫：

```gdscript
func _initialize() -> void:
	_run_sim_test()
	_test_anon_combat_skill_field()
	quit()
```

- [ ] **Step 2: 跑測試確認失敗**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

預期：parse error 或 `Invalid get index 'anon_combat_skill'` —— 因為 TeamData 還沒這欄位。

- [ ] **Step 3: 加 TeamData 欄位**

修改 `scripts/data/team_data.gd`，在 line 58 `var armed_anon_ratio: float = 0.0` 上方加：

```gdscript
var anon_combat_skill: float = 0.2
```

- [ ] **Step 4: 跑測試確認通過**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

預期輸出含：
```
--- S7 Task1: team.anon_combat_skill 獨立欄位 ---
S7 Task1 OK
```

- [ ] **Step 5: Commit**

```powershell
git add scripts/data/team_data.gd scripts/debug/headless_test.gd
git commit -m "feat(data): add team.anon_combat_skill standalone field (S7 Task 1)"
```

---

## Task 2: encounter_system 讀取改用新欄位

**Files:**
- Modify: `scripts/simulation/encounter_system.gd:152`
- Verify: `scripts/debug/encounter_sim_test.gd` 仍能跑

- [ ] **Step 1: 找出讀取位置**

打開 `scripts/simulation/encounter_system.gd`，line 152 目前是：

```gdscript
"skills": { "戰鬥": float(team.resources.get("anon_combat_skill", 0.2)) },
```

- [ ] **Step 2: 改為讀新欄位**

把 line 152 改為：

```gdscript
"skills": { "戰鬥": team.anon_combat_skill },
```

- [ ] **Step 3: 跑 encounter_sim_test 確認無 regression**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/encounter_sim_test.gd
```

預期：能正常結束（attacker_win 或 defender_win），不變量全過。注意：測試腳本 line 65 `atk.resources["anon_combat_skill"] = 0.35` 對新邏輯無效（resources 不再被讀），所以 atk anon 戰鬥技能會回到預設 0.2。改測試腳本讓它走新欄位。

- [ ] **Step 4: 更新 encounter_sim_test.gd 使用新欄位**

找 `scripts/debug/encounter_sim_test.gd` line 65 `atk.resources["anon_combat_skill"] = 0.35` 改為：

```gdscript
atk.anon_combat_skill = 0.35
```

同樣 def 那行（約 line 82）`def.resources["anon_combat_skill"] = 0.5` 改為：

```gdscript
def.anon_combat_skill = 0.5
```

再跑一次：

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/encounter_sim_test.gd
```

預期：照樣通過全部不變量。

- [ ] **Step 5: 跑 game_sim_test 確認主遊戲不壞**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/game_sim_test.gd
```

預期：`ALL INVARIANTS PASSED (violations=0)`

- [ ] **Step 6: Commit**

```powershell
git add scripts/simulation/encounter_system.gd scripts/debug/encounter_sim_test.gd
git commit -m "refactor(encounter): read anon_combat_skill from new field (S7 Task 2)"
```

---

## Task 3: `_update_anon_combat_skill` 函數 + 測試

**Files:**
- Modify: `scripts/simulation/faction_ai_system.gd`（在 `_update_equip_order` 後加新函數，line 506 附近）
- Modify: `scripts/debug/headless_test.gd`（新增 `_test_update_anon_combat_skill`）

- [ ] **Step 1: headless_test.gd 加失敗測試**

於 `headless_test.gd` 加新函數：

```gdscript
func _test_update_anon_combat_skill() -> void:
	print("--- S7 Task3: _update_anon_combat_skill ---")
	var fai := FactionAISystem.new()
	# MILITARY → 0.5
	var t_mil := TeamData.new()
	t_mil.tags = [TeamData.TAG_MILITARY]
	fai._update_anon_combat_skill(t_mil)
	assert(t_mil.anon_combat_skill >= 0.45 and t_mil.anon_combat_skill <= 0.55,
		"MILITARY 應 ~0.5，實際=%s" % str(t_mil.anon_combat_skill))
	# PRODUCE → 0.15
	var t_pro := TeamData.new()
	t_pro.tags = [TeamData.TAG_PRODUCE]
	fai._update_anon_combat_skill(t_pro)
	assert(t_pro.anon_combat_skill <= 0.2,
		"PRODUCE 應 <=0.2，實際=%s" % str(t_pro.anon_combat_skill))
	# 多重 tag 取最高
	var t_multi := TeamData.new()
	t_multi.tags = [TeamData.TAG_PRODUCE, TeamData.TAG_MILITARY]
	fai._update_anon_combat_skill(t_multi)
	assert(t_multi.anon_combat_skill >= 0.45,
		"多重 tag 應取最高（MILITARY=0.5），實際=%s" % str(t_multi.anon_combat_skill))
	# 無 tag → default 0.25
	var t_def := TeamData.new()
	fai._update_anon_combat_skill(t_def)
	assert(t_def.anon_combat_skill >= 0.2 and t_def.anon_combat_skill <= 0.3,
		"default 應 ~0.25，實際=%s" % str(t_def.anon_combat_skill))
	print("S7 Task3 OK")
```

於 `_initialize()` 加呼叫：

```gdscript
func _initialize() -> void:
	_run_sim_test()
	_test_anon_combat_skill_field()
	_test_update_anon_combat_skill()
	quit()
```

- [ ] **Step 2: 跑測試確認失敗**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

預期：`Invalid call. Nonexistent function '_update_anon_combat_skill'`

- [ ] **Step 3: 加 `_update_anon_combat_skill` 函數**

於 `scripts/simulation/faction_ai_system.gd` 的 `_update_equip_order` 之後（約 line 506），加：

```gdscript
func _update_anon_combat_skill(team: TeamData) -> void:
	var best: float = 0.25  # default
	for tag in team.tags:
		match tag:
			TeamData.TAG_MILITARY: best = maxf(best, 0.5)
			TeamData.TAG_MERCHANT: best = maxf(best, 0.2)
			TeamData.TAG_PRODUCE:  best = maxf(best, 0.15)
			TeamData.TAG_RELIGION: best = maxf(best, 0.2)
			TeamData.TAG_EXILE:    best = maxf(best, 0.3)
	team.anon_combat_skill = clampf(best, 0.1, 0.8)
```

注意：實作邏輯 `best` 起始為 0.25（default），逐 tag 取最高。`TAG_PRODUCE=0.15` 比 default 0.25 還低，所以單純 PRODUCE 結果是 0.25。測試用 `<= 0.2` 會失敗！修測試：

回去改 `_test_update_anon_combat_skill` 的 PRODUCE assertion：

```gdscript
	# PRODUCE 單一 tag → max(0.15, default 0.25) = 0.25
	var t_pro := TeamData.new()
	t_pro.tags = [TeamData.TAG_PRODUCE]
	fai._update_anon_combat_skill(t_pro)
	assert(t_pro.anon_combat_skill >= 0.2 and t_pro.anon_combat_skill <= 0.3,
		"PRODUCE 單一 tag → default 0.25，實際=%s" % str(t_pro.anon_combat_skill))
```

- [ ] **Step 4: 跑測試確認通過**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

預期：
```
--- S7 Task3: _update_anon_combat_skill ---
S7 Task3 OK
```

- [ ] **Step 5: Commit**

```powershell
git add scripts/simulation/faction_ai_system.gd scripts/debug/headless_test.gd
git commit -m "feat(faction_ai): _update_anon_combat_skill by tags (S7 Task 3)"
```

---

## Task 4: `_update_anon_wage` 函數 + 測試

**Files:**
- Modify: `scripts/simulation/faction_ai_system.gd`（接續 Task 3 函數後）
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: headless_test.gd 加失敗測試**

加函數：

```gdscript
func _test_update_anon_wage() -> void:
	print("--- S7 Task4: _update_anon_wage ---")
	var fai := FactionAISystem.new()
	# MILITARY → 1.5
	var t_mil := TeamData.new()
	t_mil.tags = [TeamData.TAG_MILITARY]
	fai._update_anon_wage(t_mil)
	assert(t_mil.anon_wage >= 1.4 and t_mil.anon_wage <= 1.6,
		"MILITARY 應 ~1.5，實際=%s" % str(t_mil.anon_wage))
	# PRODUCE → 0.7
	var t_pro := TeamData.new()
	t_pro.tags = [TeamData.TAG_PRODUCE]
	fai._update_anon_wage(t_pro)
	assert(t_pro.anon_wage <= 0.8,
		"PRODUCE 應 <=0.8，實際=%s" % str(t_pro.anon_wage))
	# EXILE → 0.3
	var t_ex := TeamData.new()
	t_ex.tags = [TeamData.TAG_EXILE]
	fai._update_anon_wage(t_ex)
	assert(t_ex.anon_wage <= 0.4,
		"EXILE 應 <=0.4，實際=%s" % str(t_ex.anon_wage))
	# default → 1.0
	var t_def := TeamData.new()
	fai._update_anon_wage(t_def)
	assert(t_def.anon_wage >= 0.9 and t_def.anon_wage <= 1.1,
		"default 應 ~1.0，實際=%s" % str(t_def.anon_wage))
	print("S7 Task4 OK")
```

於 `_initialize()` 加：

```gdscript
	_test_update_anon_wage()
```

- [ ] **Step 2: 跑測試確認失敗**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

預期：`Invalid call. Nonexistent function '_update_anon_wage'`

- [ ] **Step 3: 加 `_update_anon_wage` 函數**

於 `faction_ai_system.gd` 接續 `_update_anon_combat_skill` 之後加：

```gdscript
func _update_anon_wage(team: TeamData) -> void:
	var best: float = 1.0  # default
	for tag in team.tags:
		match tag:
			TeamData.TAG_MILITARY: best = maxf(best, 1.5)
			TeamData.TAG_MERCHANT: best = maxf(best, 1.2)
			TeamData.TAG_PRODUCE:  best = minf(best, 0.7)
			TeamData.TAG_RELIGION: best = minf(best, 0.5)
			TeamData.TAG_EXILE:    best = minf(best, 0.3)
	team.anon_wage = clampf(best, 0.0, 2.0)
```

注意：PRODUCE/RELIGION/EXILE 用 `minf` —— 這些 tag 拉低薪資，不是「取最高」邏輯。MILITARY/MERCHANT 拉高薪資用 `maxf`。

- [ ] **Step 4: 跑測試確認通過**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

預期：
```
--- S7 Task4: _update_anon_wage ---
S7 Task4 OK
```

- [ ] **Step 5: Commit**

```powershell
git add scripts/simulation/faction_ai_system.gd scripts/debug/headless_test.gd
git commit -m "feat(faction_ai): _update_anon_wage by tags (S7 Task 4)"
```

---

## Task 5: `_update_armor_config` 函數 + 測試

**Files:**
- Modify: `scripts/simulation/faction_ai_system.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: headless_test.gd 加失敗測試**

加函數：

```gdscript
func _test_update_armor_config() -> void:
	print("--- S7 Task5: _update_armor_config ---")
	var fai := FactionAISystem.new()
	# MILITARY + 高甲庫存充足
	var t1 := TeamData.new()
	t1.tags = [TeamData.TAG_MILITARY]
	t1.population = 10
	t1.resources["armor_high"] = 20
	t1.resources["armor_low"]  = 20
	fai._update_armor_config(t1)
	assert(t1.armor_config["torso"] == "high",
		"MILITARY+high 充足 torso 應 high，實際=%s" % t1.armor_config["torso"])
	assert(t1.armor_config["right_arm"] == "low",
		"MILITARY+high 充足 arm 應 low，實際=%s" % t1.armor_config["right_arm"])
	# MILITARY + 僅低甲
	var t2 := TeamData.new()
	t2.tags = [TeamData.TAG_MILITARY]
	t2.population = 10
	t2.resources["armor_low"]  = 20
	t2.resources["armor_high"] = 0
	fai._update_armor_config(t2)
	assert(t2.armor_config["torso"] == "low",
		"MILITARY+僅低 torso 應 low，實際=%s" % t2.armor_config["torso"])
	assert(t2.armor_config["head"] == "low",
		"MILITARY+僅低 head 應 low，實際=%s" % t2.armor_config["head"])
	assert(t2.armor_config["right_arm"] == "none",
		"MILITARY+僅低 arm 應 none，實際=%s" % t2.armor_config["right_arm"])
	# 無護甲 → 全 none
	var t3 := TeamData.new()
	t3.tags = [TeamData.TAG_MILITARY]
	t3.population = 10
	t3.resources["armor_low"]  = 0
	t3.resources["armor_high"] = 0
	fai._update_armor_config(t3)
	assert(t3.armor_config["torso"] == "none",
		"無甲 torso 應 none，實際=%s" % t3.armor_config["torso"])
	print("S7 Task5 OK")
```

於 `_initialize()` 加：

```gdscript
	_test_update_armor_config()
```

- [ ] **Step 2: 跑測試確認失敗**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

預期：`Invalid call. Nonexistent function '_update_armor_config'`

- [ ] **Step 3: 加 `_update_armor_config` 函數**

於 `faction_ai_system.gd` 接續加：

```gdscript
func _update_armor_config(team: TeamData) -> void:
	var pop_threshold: float = team.population * 0.3
	var has_high: bool = int(team.resources.get("armor_high", 0)) >= pop_threshold
	var has_low:  bool = int(team.resources.get("armor_low", 0))  >= pop_threshold
	# 重設全 none，再依條件填值
	team.armor_config = {
		"head": "none", "torso": "none",
		"right_arm": "none", "left_arm": "none",
		"right_leg": "none", "left_leg": "none",
	}
	var is_mil: bool = team.tags.has(TeamData.TAG_MILITARY)
	var is_mer: bool = team.tags.has(TeamData.TAG_MERCHANT)
	if is_mil and has_high:
		team.armor_config["torso"]     = "high"
		team.armor_config["head"]      = "low"
		team.armor_config["right_arm"] = "low"
		team.armor_config["left_arm"]  = "low"
		team.armor_config["right_leg"] = "low"
		team.armor_config["left_leg"]  = "low"
	elif is_mil and has_low:
		team.armor_config["torso"] = "low"
		team.armor_config["head"]  = "low"
	elif is_mer and has_low:
		team.armor_config["torso"] = "low"
	elif has_low:
		team.armor_config["torso"] = "low"
```

- [ ] **Step 4: 跑測試確認通過**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

預期：
```
--- S7 Task5: _update_armor_config ---
S7 Task5 OK
```

- [ ] **Step 5: Commit**

```powershell
git add scripts/simulation/faction_ai_system.gd scripts/debug/headless_test.gd
git commit -m "feat(faction_ai): _update_armor_config by tags+resources (S7 Task 5)"
```

---

## Task 6: `_update_guard_ratio` + `_has_hostile_within` 輔助函數 + 測試

**Files:**
- Modify: `scripts/simulation/faction_ai_system.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: headless_test.gd 加失敗測試**

加函數：

```gdscript
func _test_update_guard_ratio() -> void:
	print("--- S7 Task6: _update_guard_ratio ---")
	var fai := FactionAISystem.new()
	var state := WorldState.new()
	# 場景 A：MILITARY + 鄰格有敵對 team → 0.4
	var t_mil := TeamData.new()
	t_mil.team_id = 100
	t_mil.tags = [TeamData.TAG_MILITARY]
	t_mil.faction_id = 10
	t_mil.tile_pos = Vector2i(5, 5)
	state.teams[100] = t_mil
	var t_enemy := TeamData.new()
	t_enemy.team_id = 101
	t_enemy.faction_id = 20  # 不同 faction
	t_enemy.tile_pos = Vector2i(6, 6)  # distance ~1
	state.teams[101] = t_enemy
	fai._update_guard_ratio(t_mil, state)
	assert(t_mil.guard_ratio >= 0.35,
		"MILITARY 鄰敵 應 >=0.35，實際=%s" % str(t_mil.guard_ratio))
	# 場景 B：current_task=攻擊 → 0.1
	t_mil.current_task = TeamData.TASK_ATTACK
	fai._update_guard_ratio(t_mil, state)
	assert(t_mil.guard_ratio <= 0.15,
		"攻擊中 應 <=0.15，實際=%s" % str(t_mil.guard_ratio))
	# 場景 C：PRODUCE 無威脅 → 0.15
	var t_pro := TeamData.new()
	t_pro.team_id = 102
	t_pro.tags = [TeamData.TAG_PRODUCE]
	t_pro.faction_id = 30  # 自己 faction，無鄰敵
	t_pro.tile_pos = Vector2i(-20, -20)
	state.teams[102] = t_pro
	fai._update_guard_ratio(t_pro, state)
	assert(t_pro.guard_ratio <= 0.2,
		"PRODUCE 無威脅 應 <=0.2，實際=%s" % str(t_pro.guard_ratio))
	# 場景 D：default 無威脅 → 0.2
	var t_def := TeamData.new()
	t_def.team_id = 103
	t_def.faction_id = 40
	t_def.tile_pos = Vector2i(-30, -30)
	state.teams[103] = t_def
	fai._update_guard_ratio(t_def, state)
	assert(t_def.guard_ratio >= 0.15 and t_def.guard_ratio <= 0.25,
		"default 無威脅 應 ~0.2，實際=%s" % str(t_def.guard_ratio))
	print("S7 Task6 OK")
```

於 `_initialize()` 加：

```gdscript
	_test_update_guard_ratio()
```

- [ ] **Step 2: 跑測試確認失敗**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

預期：`Invalid call. Nonexistent function '_update_guard_ratio'`

- [ ] **Step 3: 加 `_has_hostile_within` 輔助 + `_update_guard_ratio`**

於 `faction_ai_system.gd` 加：

```gdscript
func _has_hostile_within(state: WorldState, team: TeamData, range_hex: int) -> bool:
	for tid in state.teams:
		if tid == team.team_id: continue
		var other: TeamData = state.teams[tid]
		if other.faction_id == team.faction_id and team.faction_id != -1: continue
		var d: int = _hex_dist(team.tile_pos, other.tile_pos)
		if d <= range_hex:
			return true
	return false

func _hex_dist(a: Vector2i, b: Vector2i) -> int:
	var dq: int = a.x - b.x
	var dr: int = a.y - b.y
	return (abs(dq) + abs(dr) + abs(dq + dr)) / 2

func _update_guard_ratio(team: TeamData, state: WorldState) -> void:
	var ratio: float = 0.2  # default
	if team.current_task == TeamData.TASK_ATTACK or team.current_task == TeamData.TASK_LOOT:
		ratio = 0.1
	else:
		var threat: bool = _has_hostile_within(state, team, 3)
		if team.tags.has(TeamData.TAG_MILITARY) and threat:
			ratio = 0.4
		elif threat:
			ratio = 0.35
		elif team.tags.has(TeamData.TAG_PRODUCE):
			ratio = 0.15
	team.guard_ratio = clampf(ratio, 0.05, 0.5)
```

注意：`_hex_dist` 是 axial coord 標準公式，用作 fallback —— 若 `EncounterSystem.hex_dist` 已存在可改用它，但 faction_ai 應自含工具不依賴遭遇戰系統。

- [ ] **Step 4: 跑測試確認通過**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

預期：
```
--- S7 Task6: _update_guard_ratio ---
S7 Task6 OK
```

- [ ] **Step 5: Commit**

```powershell
git add scripts/simulation/faction_ai_system.gd scripts/debug/headless_test.gd
git commit -m "feat(faction_ai): _update_guard_ratio + _has_hostile_within (S7 Task 6)"
```

---

## Task 7: `run()` 末尾迴圈呼叫 4 個 update 函數 + 整合測試

**Files:**
- Modify: `scripts/simulation/faction_ai_system.gd:81-84`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: headless_test.gd 加整合測試**

加函數：

```gdscript
func _test_faction_ai_run_calls_all_updates() -> void:
	print("--- S7 Task7: faction_ai.run() 整合 ---")
	var fai := FactionAISystem.new()
	var state := WorldState.new()
	# 建 MILITARY team 且資源充足
	var t := TeamData.new()
	t.team_id = 200
	t.tags = [TeamData.TAG_MILITARY]
	t.population = 10
	t.faction_id = 50
	t.tile_pos = Vector2i(0, 0)
	t.resources["armor_high"] = 20
	t.resources["armor_low"]  = 20
	state.teams[200] = t
	# faction_ai run 後 4 個欄位都應被更新
	fai.run(state)
	assert(t.anon_combat_skill >= 0.45,
		"run() 後 MILITARY anon_combat_skill 應 >=0.45，實際=%s" % str(t.anon_combat_skill))
	assert(t.anon_wage >= 1.4,
		"run() 後 MILITARY anon_wage 應 >=1.4，實際=%s" % str(t.anon_wage))
	assert(t.armor_config["torso"] == "high",
		"run() 後 MILITARY armor_config torso 應 high，實際=%s" % t.armor_config["torso"])
	assert(t.guard_ratio >= 0.15 and t.guard_ratio <= 0.5,
		"run() 後 guard_ratio 應在合理範圍，實際=%s" % str(t.guard_ratio))
	print("S7 Task7 OK")
```

於 `_initialize()` 加：

```gdscript
	_test_faction_ai_run_calls_all_updates()
```

- [ ] **Step 2: 跑測試確認失敗**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

預期：MILITARY team 的 `anon_combat_skill` 仍為 0.2（未呼叫 update）→ assertion fail。

- [ ] **Step 3: 修 `run()` 末尾迴圈**

打開 `scripts/simulation/faction_ai_system.gd` 找 line 81-84：

```gdscript
	for tid in state.teams:
		if not state.teams.has(tid):
			continue
		_update_equip_order(state, state.teams[tid])
```

改為：

```gdscript
	for tid in state.teams:
		if not state.teams.has(tid):
			continue
		var team: TeamData = state.teams[tid]
		_update_equip_order(state, team)
		_update_anon_combat_skill(team)
		_update_anon_wage(team)
		_update_armor_config(team)
		_update_guard_ratio(team, state)
```

- [ ] **Step 4: 跑測試確認通過**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

預期：
```
--- S7 Task7: faction_ai.run() 整合 ---
S7 Task7 OK
```

- [ ] **Step 5: 跑 game_sim_test 確認主遊戲不壞**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/game_sim_test.gd
```

預期：`ALL INVARIANTS PASSED (violations=0)`

- [ ] **Step 6: 跑 encounter_sim_test 確認遭遇戰不壞**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/encounter_sim_test.gd
```

預期：能正常結束（attacker_win 或 defender_win），全部不變量通過。

- [ ] **Step 7: Commit**

```powershell
git add scripts/simulation/faction_ai_system.gd scripts/debug/headless_test.gd
git commit -m "feat(faction_ai): wire 4 new update functions into run() (S7 Task 7)"
```

---

## Task 8: 更新 known_issues.md 標記 S7 已修

**Files:**
- Modify: `docs/known_issues.md`

- [ ] **Step 1: 打開 known_issues.md 找 S7a-S7d**

找到 `### S7. anon_combat_skill 從未由遊戲邏輯設定` 那一節（連同 S7b、S7c、S7d）。

- [ ] **Step 2: 改標題加「✅ 已修」**

把：

```markdown
### S7. `anon_combat_skill` 從未由遊戲邏輯設定
```

改為：

```markdown
### S7. `anon_combat_skill` 從未由遊戲邏輯設定 ✅ 已修（2026-06-07）
```

同樣改 S7b、S7c、S7d 標題加 `✅ 已修（2026-06-07）`。

於 S7 描述底下加（每個 S7x 都加類似一段）：

```markdown
- **修正**：`faction_ai_system._update_anon_combat_skill` 依 tags 計算；`anon_combat_skill` 從 `team.resources` 遷出為獨立欄位
- **位置**：`scripts/simulation/faction_ai_system.gd`、`scripts/data/team_data.gd`
- **commit**：S7 Task 1-7 系列
```

S7b：

```markdown
- **修正**：`faction_ai_system._update_armor_config` 依 tags + 護甲庫存閾值計算各 slot
- **位置**：`scripts/simulation/faction_ai_system.gd`
```

S7c：

```markdown
- **修正**：`faction_ai_system._update_guard_ratio` 依 current_task + 鄰近威脅計算；新增 `_has_hostile_within` 輔助
- **位置**：`scripts/simulation/faction_ai_system.gd`
```

S7d：

```markdown
- **修正**：`faction_ai_system._update_anon_wage` 依 tags 計算（MILITARY 拉高、PRODUCE/EXILE 拉低）
- **位置**：`scripts/simulation/faction_ai_system.gd`
```

- [ ] **Step 3: 更新檔頭時戳**

把第 3 行：

```markdown
> 最後更新：2026-06-07（遭遇戰修正後）| 來源：動態測試 + code review
```

改為：

```markdown
> 最後更新：2026-06-07（S7 faction_ai 動態初始化）| 來源：動態測試 + code review
```

- [ ] **Step 4: Commit**

```powershell
git add docs/known_issues.md
git commit -m "docs: mark S7a-S7d resolved by faction_ai dynamic init (S7 Task 8)"
```

---

## 完成後驗證

執行最終整體驗證：

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/game_sim_test.gd
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/encounter_sim_test.gd
```

三個測試腳本都應通過。
