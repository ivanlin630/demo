# NPC 生存決策 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** NPC team 食物危機時自動觸發生存行動（回家／掠奪／投靠／乞食），用既有 memory + reputation 系統建立援助互動的長期後果。

**Architecture:** `faction_ai_system.evaluate_all` 加 survival 評估；`interaction_system` 加 `_resolve_aid_request`；`player_command_system` 加 `respond_aid_request`；`TeamData` 加 `previous_task` 欄位；`sim_runner` forced_event 超時 callback 觸發 refuse memory。

**Tech Stack:** Godot 4.2.2 GDScript；headless test 驗證；npc_ai memory 系統重用。

**Spec:** `docs/superpowers/specs/2026-06-07-npc-survival-decision-design.md`

---

## 檔案結構

| 檔案 | 變更 |
|---|---|
| `scripts/data/team_data.gd` | 加 `var previous_task: String = ""` |
| `scripts/simulation/faction_ai_system.gd` | 加 survival 評估 + 4 個決策函數 + 4 個 find helper + sticky check |
| `scripts/simulation/strategic_ai_system.gd` | 設 task 前檢查 SURVIVAL_TASKS sticky |
| `scripts/simulation/interaction_system.gd` | 加 `_resolve_aid_request` + pair resolve 判斷 |
| `scripts/simulation/sim_runner.gd` | forced_event 超時時 emit aid_refused + write memory |
| `scripts/simulation/player_command_system.gd` | 加 `respond_aid_request` action |
| `scripts/debug/headless_test.gd` | 加 13 個 survival 測試 case |

## 執行測試的標準命令

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/game_sim_test.gd
```

## SURVIVAL_TASKS 常數

`scripts/simulation/faction_ai_system.gd` 加：

```gdscript
const SURVIVAL_TASKS: Array = ["return_home", "乞食", TeamData.TASK_LOOT, "投靠"]
```

---

## Task 1: TeamData 加 `previous_task` 欄位

**Files:**
- Modify: `scripts/data/team_data.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 加失敗測試**

`headless_test.gd` 末尾加：

```gdscript
func _test_team_previous_task_field() -> void:
	print("--- Survival Task1: TeamData.previous_task ---")
	var t := TeamData.new()
	assert(t.previous_task == "", "預設應為空字串，實際=%s" % t.previous_task)
	t.previous_task = "貿易"
	assert(t.previous_task == "貿易", "指派後應為 貿易")
	print("Survival Task1 OK")
```

於 `_initialize()` 加 `_test_team_previous_task_field()`。

- [ ] **Step 2: 跑測試確認失敗**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

預期：`Invalid get index 'previous_task'`

- [ ] **Step 3: 加欄位**

`scripts/data/team_data.gd` 找 `var current_task: String = "idle"` 那行（約 line 45），下方加：

```gdscript
var previous_task: String = ""   # survival override 前的原 task，回復用
```

- [ ] **Step 4: 跑測試確認通過**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

預期：`Survival Task1 OK`

- [ ] **Step 5: Commit**

```powershell
git add scripts/data/team_data.gd scripts/debug/headless_test.gd
git commit -m "feat(team): add previous_task field for survival override (Task 1)"
```

---

## Task 2: faction_ai_system survival 觸發 + sticky check

**Files:**
- Modify: `scripts/simulation/faction_ai_system.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 加失敗測試**

`headless_test.gd` 末尾加：

```gdscript
func _test_survival_trigger_urgent() -> void:
	print("--- Survival Task2: 緊急觸發 (food < 1 day) ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	var team := TeamData.new()
	team.team_id = 100
	team.population = 10
	team.resources["food"] = 0.0   # 0 食物 → 緊急
	team.tile_pos = Vector2i(0, 0)
	team.current_task = "idle"
	var leader := PersonData.new()
	leader.id = 200
	leader.team_id = 100
	leader.values = { "義氣": 0.5, "信義": 0.5, "貪婪": 0.5, "殘忍": 0.3, "好戰": 0.3, "求生欲": 0.5 }
	state.persons[200] = leader
	team.leader_id = 200
	state.teams[100] = team
	state.team_discovered[100] = []
	var fai := FactionAISystem.new()
	# 直接呼叫評估函數（不跑完整 evaluate_all）
	fai._evaluate_survival(state, team)
	assert(team.current_task in FactionAISystem.SURVIVAL_TASKS,
		"緊急觸發後應為 SURVIVAL_TASKS，實際=%s" % team.current_task)
	print("Survival Task2 OK (task=%s)" % team.current_task)

func _test_survival_sticky() -> void:
	print("--- Survival Task2b: sticky 不重覆觸發 ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	var team := TeamData.new()
	team.team_id = 101
	team.current_task = "乞食"   # 已在 survival 中
	team.previous_task = "貿易"
	state.teams[101] = team
	var fai := FactionAISystem.new()
	fai._evaluate_survival(state, team)
	assert(team.current_task == "乞食", "sticky 不應改變 task")
	assert(team.previous_task == "貿易", "previous_task 不應變")
	print("Survival Task2b OK")
```

於 `_initialize()` 加兩個呼叫。

- [ ] **Step 2: 跑測試確認失敗**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

預期：`Nonexistent function '_evaluate_survival'`

- [ ] **Step 3: 加 SURVIVAL_TASKS 常數與 `_evaluate_survival` 入口**

打開 `scripts/simulation/faction_ai_system.gd`，在檔案常數區（line 1-30 附近）加：

```gdscript
const SURVIVAL_TASKS: Array = ["return_home", "乞食", TeamData.TASK_LOOT, "投靠"]
const FOOD_PER_PERSON_PER_DAY_SURVIVAL: float = 2.4
const URGENCY_DAYS: float = 1.0
const WARNING_DAYS: float = 3.0
```

於檔案末尾或 `_update_anon_combat_skill` 附近加：

```gdscript
func _evaluate_survival(state: WorldState, team: TeamData) -> void:
	# 玩家 team 跳過
	if team.leader_id == state.player_id and state.player_id != -1:
		return
	# sticky：已在 survival 中不重評
	if team.current_task in SURVIVAL_TASKS:
		return
	var pop_eff: int = team.population
	if pop_eff <= 0: return
	var food: float = float(team.resources.get("food", 0))
	var food_per_day: float = float(pop_eff) * FOOD_PER_PERSON_PER_DAY_SURVIVAL
	var days_left: float = food / maxf(food_per_day, 0.001)
	if days_left < URGENCY_DAYS:
		_trigger_survival(state, team, "urgent")
	elif days_left < WARNING_DAYS:
		_trigger_survival(state, team, "warning")

func _trigger_survival(state: WorldState, team: TeamData, _severity: String) -> void:
	# Task 3 會實作完整決策樹；此處先設 placeholder = "乞食"
	team.previous_task = team.current_task
	team.current_task = "乞食"
```

- [ ] **Step 4: 跑測試確認通過**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

預期：
```
Survival Task2 OK (task=乞食)
Survival Task2b OK
```

- [ ] **Step 5: Commit**

```powershell
git add scripts/simulation/faction_ai_system.gd scripts/debug/headless_test.gd
git commit -m "feat(faction_ai): survival trigger + sticky check (Task 2)"
```

---

## Task 3: 4 個 find helper 函數

**Files:**
- Modify: `scripts/simulation/faction_ai_system.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 加失敗測試**

`headless_test.gd` 末尾加：

```gdscript
func _test_survival_helpers() -> void:
	print("--- Survival Task3: find helpers ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	# Team0 with outpost @ (5,5)
	var t0 := TeamData.new()
	t0.team_id = 0; t0.tile_pos = Vector2i(0, 0); t0.population = 10
	state.teams[0] = t0
	var tile := HexTileData.new()
	tile.tile_pos = Vector2i(5, 5)
	tile.outpost_level = 1
	tile.outpost_owner = 0
	state.world.tiles[5 * 1000 + 5] = tile
	# Weak prey Team1 pop=3 food=50 at (1,0)
	var t1 := TeamData.new()
	t1.team_id = 1; t1.tile_pos = Vector2i(1, 0); t1.population = 3
	t1.resources["food"] = 50.0
	state.teams[1] = t1
	state.team_discovered[0] = [1, 2]
	# Strong neighbor Team2 pop=20 at (2,0), different faction
	var t2 := TeamData.new()
	t2.team_id = 2; t2.tile_pos = Vector2i(2, 0); t2.population = 20
	t2.faction_id = 99   # different
	t2.resources["food"] = 500.0   # surplus
	state.teams[2] = t2
	state.team_discovered[2] = [0]
	state.team_discovered[1] = [0]
	
	var fai := FactionAISystem.new()
	# 找 own outpost
	var op_pos = fai._find_own_outpost(state, t0)
	assert(op_pos == Vector2i(5, 5), "own outpost 應 (5,5)，實際=%s" % str(op_pos))
	# 找 weak prey
	var prey = fai._find_weakest_prey(state, t0)
	assert(prey == 1, "weak prey 應 Team1，實際=%d" % prey)
	# 找 strong neighbor
	var strong = fai._find_strong_neighbor(state, t0)
	assert(strong == 2, "strong neighbor 應 Team2，實際=%d" % strong)
	# 找 aid target（陌生也算，Team2 有 surplus）
	var aid = fai._find_aid_target(state, t0)
	assert(aid != -1, "aid target 應有，實際=%d" % aid)
	# 無 outpost 的 team
	var t3 := TeamData.new()
	t3.team_id = 3; t3.tile_pos = Vector2i(8, 8); t3.population = 5
	state.teams[3] = t3
	var no_op = fai._find_own_outpost(state, t3)
	assert(no_op == Vector2i(-1, -1), "無 outpost 應 (-1,-1)，實際=%s" % str(no_op))
	print("Survival Task3 OK")
```

- [ ] **Step 2: 跑測試確認失敗**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

預期：`Nonexistent function '_find_own_outpost'` 等

- [ ] **Step 3: 加 4 個 helper 函數**

於 `faction_ai_system.gd` 接續加：

```gdscript
func _find_own_outpost(state: WorldState, team: TeamData) -> Vector2i:
	for tile_id in state.world.tiles:
		var tile: HexTileData = state.world.tiles[tile_id]
		if tile.outpost_level > 0 and tile.outpost_owner == team.team_id:
			return tile.tile_pos
	return Vector2i(-1, -1)

func _find_weakest_prey(state: WorldState, team: TeamData) -> int:
	var best_id: int = -1
	var best_pop: int = 999999
	for tid in state.team_discovered.get(team.team_id, []):
		if tid == team.team_id: continue
		var t: TeamData = state.teams.get(tid)
		if t == null: continue
		if t.population >= int(float(team.population) * 0.7): continue
		if float(t.resources.get("food", 0)) < 20.0: continue
		if t.population < best_pop:
			best_pop = t.population
			best_id = tid
	return best_id

func _find_strong_neighbor(state: WorldState, team: TeamData) -> int:
	var best_id: int = -1
	var best_pop: int = 0
	for tid in state.team_discovered.get(team.team_id, []):
		if tid == team.team_id: continue
		var t: TeamData = state.teams.get(tid)
		if t == null: continue
		if t.faction_id != -1 and t.faction_id == team.faction_id: continue   # 跳過自己 faction
		# 簡化：rep <= 0.3 視為敵對，跳過
		var rep: float = float(team.known_reputations.get(tid, 0.5))
		if rep <= 0.3: continue
		if t.population <= int(float(team.population) * 1.5): continue
		if t.population > best_pop:
			best_pop = t.population
			best_id = tid
	return best_id

func _find_aid_target(state: WorldState, team: TeamData) -> int:
	# 優先序：同 faction > rep>=0.5 > 距離
	var candidates: Array = []
	for tid in state.team_discovered.get(team.team_id, []):
		if tid == team.team_id: continue
		var t: TeamData = state.teams.get(tid)
		if t == null: continue
		# 過濾：必須有兩週存糧
		var reserve: float = float(t.population) * 14.0
		if float(t.resources.get("food", 0)) <= reserve: continue
		var same_faction: bool = (t.faction_id != -1 and t.faction_id == team.faction_id)
		var rep: float = float(team.known_reputations.get(tid, 0.5))
		var dist: int = _hex_dist(team.tile_pos, t.tile_pos)
		# Score：同 faction +1000, rep>=0.5 +100, 距離負分
		var score: float = 0.0
		if same_faction: score += 1000.0
		if rep >= 0.5: score += 100.0
		score -= float(dist)
		candidates.append({ "tid": tid, "score": score })
	if candidates.is_empty():
		return -1
	candidates.sort_custom(func(a, b): return a["score"] > b["score"])
	return int(candidates[0]["tid"])
```

- [ ] **Step 4: 跑測試確認通過**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

預期：`Survival Task3 OK`

- [ ] **Step 5: Commit**

```powershell
git add scripts/simulation/faction_ai_system.gd scripts/debug/headless_test.gd
git commit -m "feat(faction_ai): survival find helpers (own_outpost/prey/neighbor/aid_target) (Task 3)"
```

---

## Task 4: 完整決策樹（4 路徑）+ `_should_abandon_current_task`

**Files:**
- Modify: `scripts/simulation/faction_ai_system.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 加 4 個路徑測試**

```gdscript
func _test_survival_decision_tree() -> void:
	print("--- Survival Task4: 決策樹 4 路徑 ---")
	var fai := FactionAISystem.new()
	# (1) 有 outpost → return_home
	var s1 := WorldState.new()
	s1.world = WorldData.new()
	var t1 := TeamData.new(); t1.team_id = 0; t1.tile_pos = Vector2i(0,0); t1.population = 5; t1.resources["food"] = 0
	var l1 := PersonData.new(); l1.id = 100; l1.values = { "義氣": 0.3, "信義": 0.3, "殘忍": 0.2, "好戰": 0.2 }
	s1.persons[100] = l1; t1.leader_id = 100
	s1.teams[0] = t1; s1.team_discovered[0] = []
	var tile := HexTileData.new(); tile.tile_pos = Vector2i(3,3); tile.outpost_level = 1; tile.outpost_owner = 0
	s1.world.tiles[3003] = tile
	fai._trigger_survival(s1, t1, "urgent")
	assert(t1.current_task == "return_home", "Path 1 應 return_home，實際=%s" % t1.current_task)
	# (2) 殘忍 + 鄰弱 → 掠奪
	var s2 := WorldState.new()
	s2.world = WorldData.new()
	var t2 := TeamData.new(); t2.team_id = 0; t2.tile_pos = Vector2i(0,0); t2.population = 10; t2.resources["food"] = 0
	var l2 := PersonData.new(); l2.id = 100; l2.values = { "殘忍": 0.7, "好戰": 0.5 }
	s2.persons[100] = l2; t2.leader_id = 100
	var prey := TeamData.new(); prey.team_id = 1; prey.tile_pos = Vector2i(1,0); prey.population = 3
	prey.resources["food"] = 50
	s2.teams[0] = t2; s2.teams[1] = prey; s2.team_discovered[0] = [1]
	fai._trigger_survival(s2, t2, "urgent")
	assert(t2.current_task == TeamData.TASK_LOOT, "Path 2 應 掠奪，實際=%s" % t2.current_task)
	# (3) 義氣 + 信義 → 投靠
	var s3 := WorldState.new()
	s3.world = WorldData.new()
	var t3 := TeamData.new(); t3.team_id = 0; t3.tile_pos = Vector2i(0,0); t3.population = 5; t3.resources["food"] = 0
	var l3 := PersonData.new(); l3.id = 100; l3.values = { "義氣": 0.7, "信義": 0.7, "求生欲": 0.5 }
	s3.persons[100] = l3; t3.leader_id = 100
	var ally := TeamData.new(); ally.team_id = 1; ally.tile_pos = Vector2i(2,0); ally.population = 20; ally.faction_id = 99
	ally.resources["food"] = 500
	var ally_leader := PersonData.new(); ally_leader.id = 200
	s3.persons[200] = ally_leader; ally.leader_id = 200
	s3.teams[0] = t3; s3.teams[1] = ally; s3.team_discovered[0] = [1]
	t3.known_reputations[1] = 0.6   # 中立
	fai._trigger_survival(s3, t3, "urgent")
	assert(t3.current_task == "投靠", "Path 3 應 投靠，實際=%s" % t3.current_task)
	# (4) 默認 → 乞食
	var s4 := WorldState.new()
	s4.world = WorldData.new()
	var t4 := TeamData.new(); t4.team_id = 0; t4.tile_pos = Vector2i(0,0); t4.population = 5; t4.resources["food"] = 0
	var l4 := PersonData.new(); l4.id = 100; l4.values = { "義氣": 0.4, "信義": 0.4, "殘忍": 0.3, "好戰": 0.3 }
	s4.persons[100] = l4; t4.leader_id = 100
	var aid := TeamData.new(); aid.team_id = 1; aid.tile_pos = Vector2i(2,0); aid.population = 10
	aid.resources["food"] = 500
	s4.teams[0] = t4; s4.teams[1] = aid; s4.team_discovered[0] = [1]
	fai._trigger_survival(s4, t4, "urgent")
	assert(t4.current_task == "乞食", "Path 4 應 乞食，實際=%s" % t4.current_task)
	print("Survival Task4 OK")
```

- [ ] **Step 2: 跑測試確認失敗**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

預期：Path 1 fail（placeholder 只設「乞食」）

- [ ] **Step 3: 改寫 `_trigger_survival` 為完整決策樹**

替換 Task 2 的 placeholder：

```gdscript
func _trigger_survival(state: WorldState, team: TeamData, severity: String) -> void:
	var leader: PersonData = state.persons.get(team.leader_id)
	if leader == null: return
	
	team.previous_task = team.current_task
	
	# Path 1: 有 own outpost → 回家
	var own_pos: Vector2i = _find_own_outpost(state, team)
	if own_pos != Vector2i(-1, -1):
		if severity == "warning" and not _should_abandon_current_task(team, own_pos):
			team.previous_task = ""   # 不切換，previous 也不留
			return
		team.current_task = "return_home"
		team.move_target = own_pos
		return
	
	# Path 2: 殘忍/好戰 + 有獵物 → 掠奪
	if float(leader.values.get("殘忍", 0.5)) > 0.5 \
			or float(leader.values.get("好戰", 0.5)) > 0.6:
		var prey_id: int = _find_weakest_prey(state, team)
		if prey_id != -1:
			team.current_task = TeamData.TASK_LOOT
			team.move_target = state.teams[prey_id].tile_pos
			team.combat_target = prey_id
			return
	
	# Path 3: 義氣 + 信義 → 投靠 (or 結盟)
	var honor_sum: float = float(leader.values.get("義氣", 0.5)) \
		+ float(leader.values.get("信義", 0.5))
	if honor_sum > 1.2:
		var ally_id: int = _find_strong_neighbor(state, team)
		if ally_id != -1:
			# diplomatic message 暫且簡化（後續可整合 diplomatic_ai）
			team.current_task = "投靠"
			team.move_target = state.teams[ally_id].tile_pos
			team.combat_target = ally_id
			return
	
	# Path 4: 默認 → 乞食
	var aid_target: int = _find_aid_target(state, team)
	if aid_target != -1:
		team.current_task = "乞食"
		team.move_target = state.teams[aid_target].tile_pos
		team.combat_target = aid_target
		return
	# 全失敗 → 放棄
	team.previous_task = ""   # 不留 previous

func _should_abandon_current_task(team: TeamData, survival_target: Vector2i) -> bool:
	if team.move_target == Vector2i(-1, -1):
		return true
	var cur_dist: int = _hex_dist(team.tile_pos, team.move_target)
	var surv_dist: int = _hex_dist(team.tile_pos, survival_target)
	return surv_dist <= cur_dist + 2
```

- [ ] **Step 4: 跑測試確認通過**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

預期：`Survival Task4 OK`

- [ ] **Step 5: 整合 `_evaluate_survival` 到 `evaluate_all`**

在 `evaluate_all` team loop 內加：

```gdscript
for tid in state.teams:
    if not state.teams.has(tid): continue
    var team: TeamData = state.teams[tid]
    # S11: leader 死亡自動繼承...
    if team.leader_id == -1 and not team.named_members.is_empty():
        _promote_successor(state, team)
    # B: 生存決策（在其他 update 前評估，task 改完後 strategic_ai 看到 sticky 不蓋）
    _evaluate_survival(state, team)
    _update_equip_order(state, team)
    ...
```

- [ ] **Step 6: 跑 game_sim_test 看效果**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/game_sim_test.gd > godot_test.log 2>&1
Get-Content godot_test.log -Encoding UTF8 | Select-String "乞食|return_home|TASK_LOOT|投靠" | Select-Object -First 10
```

預期：log 出現 survival task 切換。

- [ ] **Step 7: Commit**

```powershell
git add scripts/simulation/faction_ai_system.gd scripts/debug/headless_test.gd
git commit -m "feat(faction_ai): survival decision tree (return_home/loot/surrender/beg) (Task 4)"
```

---

## Task 5: strategic_ai_system sticky check

**Files:**
- Modify: `scripts/simulation/strategic_ai_system.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 加 sticky 測試**

```gdscript
func _test_strategic_ai_respects_survival() -> void:
	print("--- Survival Task5: strategic_ai sticky ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	var t := TeamData.new()
	t.team_id = 0; t.tile_pos = Vector2i(0,0); t.population = 10
	t.current_task = "乞食"   # 已 survival
	t.previous_task = "貿易"
	state.teams[0] = t
	var leader := PersonData.new()
	leader.id = 100
	leader.values = { "野心": 0.9, "好戰": 0.9 }
	state.persons[100] = leader; t.leader_id = 100
	var f := FactionData.new()
	f.faction_id = 0; f.leader_team_id = 0; f.member_team_ids = [0]
	f.strategic_goals = [{ "type": "expand", "target_id": -1, "priority": 0.9 }]
	state.factions[0] = f
	var sai := StrategicAiSystem.new()
	# 強制 tick=STRATEGIC_INTERVAL 倍數
	state.world.current_tick = StrategicAiSystem.STRATEGIC_INTERVAL
	sai.tick(state, f)
	assert(t.current_task == "乞食",
		"sticky 應保持乞食 task，實際=%s" % t.current_task)
	print("Survival Task5 OK")
```

- [ ] **Step 2: 跑測試確認失敗**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

預期：assertion fail（strategic_ai 改 task）

- [ ] **Step 3: 加 sticky 檢查**

打開 `scripts/simulation/strategic_ai_system.gd`。找所有設 `team.current_task = ...` 或 `leader_team.current_task = ...` 的位置（用 grep 確認）。每處加守衛：

```gdscript
if team.current_task in FactionAISystem.SURVIVAL_TASKS:
    continue   # 不蓋過 survival
```

主要修改點（依檔案結構）：
- `_assign_encirclement`
- `_assign_breakout`
- 任何其他直接設 current_task 的點

- [ ] **Step 4: 跑測試確認通過**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

預期：`Survival Task5 OK`

- [ ] **Step 5: Commit**

```powershell
git add scripts/simulation/strategic_ai_system.gd scripts/debug/headless_test.gd
git commit -m "feat(strategic_ai): respect SURVIVAL_TASKS sticky (Task 5)"
```

---

## Task 6: `interaction_system._resolve_aid_request`（NPC 自決路徑）

**Files:**
- Modify: `scripts/simulation/interaction_system.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 加 NPC 接受/拒絕測試**

```gdscript
func _test_aid_resolve_npc_accept() -> void:
	print("--- Survival Task6a: NPC 接受 ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	# Beggar
	var b := TeamData.new(); b.team_id = 0; b.population = 10; b.resources["food"] = 0
	b.current_task = "乞食"; b.previous_task = "貿易"
	b.combat_target = 1; b.tile_pos = Vector2i(2,2)
	var b_leader := PersonData.new(); b_leader.id = 100; b_leader.team_id = 0
	state.persons[100] = b_leader; b.leader_id = 100
	state.teams[0] = b
	# Target（高義氣 + surplus）
	var t := TeamData.new(); t.team_id = 1; t.population = 10
	t.resources["food"] = 500.0   # 餘糧充足
	t.tile_pos = Vector2i(2,2)
	var t_leader := PersonData.new(); t_leader.id = 200
	t_leader.values = { "義氣": 0.8, "貪婪": 0.3 }
	state.persons[200] = t_leader; t.leader_id = 200
	state.teams[1] = t
	var inter := InteractionSystem.new()
	var r: Dictionary = inter._resolve_aid_request(state, 0, 1)
	assert(r.get("accepted", false), "高義氣應接受，msg=%s" % r.get("msg", ""))
	assert(float(b.resources["food"]) > 0.0, "beggar food 應 > 0")
	assert(b.current_task == "貿易", "beggar 應回 previous_task，實際=%s" % b.current_task)
	print("Survival Task6a OK (給 %.1f food)" % r.get("amount", 0.0))

func _test_aid_resolve_npc_refuse() -> void:
	print("--- Survival Task6b: NPC 拒絕 ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	var b := TeamData.new(); b.team_id = 0; b.population = 10; b.resources["food"] = 0
	b.current_task = "乞食"; b.previous_task = "貿易"; b.combat_target = 1
	var b_leader := PersonData.new(); b_leader.id = 100
	state.persons[100] = b_leader; b.leader_id = 100
	state.teams[0] = b
	var t := TeamData.new(); t.team_id = 1; t.population = 10
	t.resources["food"] = 500.0
	var t_leader := PersonData.new(); t_leader.id = 200
	t_leader.values = { "義氣": 0.1, "貪婪": 0.9 }   # 極吝嗇
	state.persons[200] = t_leader; t.leader_id = 200
	state.teams[1] = t
	var inter := InteractionSystem.new()
	var r: Dictionary = inter._resolve_aid_request(state, 0, 1)
	assert(not r.get("accepted", true), "極吝嗇應拒絕")
	assert(float(b.resources["food"]) == 0.0, "beggar food 應仍 0")
	assert(b.current_task == "貿易", "拒絕後 beggar 仍回 previous_task")
	print("Survival Task6b OK")
```

- [ ] **Step 2: 跑測試確認失敗**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

預期：`Nonexistent function '_resolve_aid_request'`

- [ ] **Step 3: 加函數**

打開 `scripts/simulation/interaction_system.gd`，在末尾或 `_resolve_extortion` 附近加：

```gdscript
const AID_RESERVE_DAYS: float = 14.0   # target 必留 2 週存糧

func _resolve_aid_request(state: WorldState, beggar_id: int, target_id: int) -> Dictionary:
	var beggar: TeamData = state.teams.get(beggar_id)
	var target: TeamData = state.teams.get(target_id)
	if beggar == null or target == null:
		return { "ok": false, "msg": "對象不存在" }
	# 玩家 target → forced event (Task 7)
	if target.leader_id == state.player_id and state.player_id != -1:
		state.player_forced_event = {
			"from_id": beggar_id,
			"action": "aid_request",
			"beggar_food": float(beggar.resources.get("food", 0)),
			"beggar_pop": beggar.population,
		}
		state.player_forced_event_id = "aid_%d_%d" % [beggar_id, state.world.current_tick]
		return { "ok": true, "pending": true, "msg": "等玩家回應" }
	# NPC 自決
	var target_leader: PersonData = state.persons.get(target.leader_id)
	var beggar_leader: PersonData = state.persons.get(beggar.leader_id)
	if target_leader == null or beggar_leader == null:
		return { "ok": false, "msg": "leader 缺失" }
	var honor: float = float(target_leader.values.get("義氣", 0.5))
	var greed: float = float(target_leader.values.get("貪婪", 0.5))
	var rep: float   = float(target.known_reputations.get(beggar_id, 0.5))
	var annoyance: float = _count_recent_begs(target_leader, beggar_id) * 0.2
	var give_score: float = honor + rep - greed * 0.5 - annoyance
	if give_score < 0.3:
		_msg.emit_message(state, "aid_refused",
			"Team%d 拒絕援助 Team%d" % [target_id, beggar_id], target,
			{ "origin": str(target_id), "target": str(beggar_id) })
		_update_reputation(beggar, target_id, -0.1)
		_npc_ai.write_memory(beggar_leader, "rejected_aid", target_id,
			state.world.current_tick, 0.5)
		_npc_ai.write_memory(target_leader, "begged_at_me", beggar_id,
			state.world.current_tick, 0.3)
		_clear_aid_task(beggar)
		return { "ok": true, "accepted": false, "msg": "拒絕" }
	# 接受：計算給多少
	var need: float = float(beggar.population) * 2.4 * 3.0 \
		- float(beggar.resources.get("food", 0))
	var target_food: float = float(target.resources.get("food", 0))
	var target_reserve: float = float(target.population) * AID_RESERVE_DAYS
	var surplus: float = maxf(target_food - target_reserve, 0.0)
	var give: float = minf(need, surplus * give_score)
	if give <= 0.0:
		_msg.emit_message(state, "aid_refused",
			"Team%d 無餘糧 Team%d" % [target_id, beggar_id], target,
			{ "origin": str(target_id), "target": str(beggar_id) })
		_clear_aid_task(beggar)
		return { "ok": true, "accepted": false, "msg": "無餘糧" }
	target.resources["food"] = target_food - give
	beggar.resources["food"] = float(beggar.resources.get("food", 0)) + give
	_msg.emit_message(state, "aid_given",
		"Team%d 援助 Team%d %.0f 食物" % [target_id, beggar_id, give], target,
		{ "origin": str(target_id), "target": str(beggar_id), "amount": "%.0f" % give })
	_update_reputation(beggar, target_id, 0.15)
	var intensity: float = clampf(give / maxf(need, 1.0), 0.1, 1.0)
	_npc_ai.write_memory(beggar_leader, "benefactor", target_id,
		state.world.current_tick, intensity)
	_npc_ai.write_memory(target_leader, "begged_at_me", beggar_id,
		state.world.current_tick, 0.2)
	_clear_aid_task(beggar)
	return { "ok": true, "accepted": true, "amount": give, "msg": "獲援助" }

func _count_recent_begs(leader: PersonData, beggar_id: int) -> int:
	var count: int = 0
	for m in leader.memory:
		if not (m is Dictionary): continue
		if m.get("type") == "begged_at_me" and m.get("subject_id") == beggar_id:
			count += 1
	return count

func _clear_aid_task(beggar: TeamData) -> void:
	beggar.current_task = beggar.previous_task if beggar.previous_task != "" else TeamData.TASK_IDLE
	beggar.previous_task = ""
	beggar.combat_target = -1

func _update_reputation(team: TeamData, other_id: int, delta: float) -> void:
	var cur: float = float(team.known_reputations.get(other_id, 0.5))
	team.known_reputations[other_id] = clampf(cur + delta, 0.0, 1.0)
```

注意：`_msg`、`_npc_ai` 必須在 `interaction_system` 已有實例化。檢查 `_init` 函數，如果沒則加：

```gdscript
var _npc_ai: NpcAiSystem
func _init() -> void:
	_msg = SimMessageSystem.new()
	_npc_ai = NpcAiSystem.new()
```

- [ ] **Step 4: 跑測試確認通過**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

預期：`Survival Task6a OK` + `Survival Task6b OK`

- [ ] **Step 5: 整合到 pair resolve**

打開 `interaction_system._resolve_pair`（line ~225 附近），加：

```gdscript
elif a.current_task == "乞食" and a.combat_target == id_b:
    _resolve_aid_request(state, id_a, id_b)
elif b.current_task == "乞食" and b.combat_target == id_a:
    _resolve_aid_request(state, id_b, id_a)
```

- [ ] **Step 6: Commit**

```powershell
git add scripts/simulation/interaction_system.gd scripts/debug/headless_test.gd
git commit -m "feat(interaction): _resolve_aid_request with memory dynamics (Task 6)"
```

---

## Task 7: 玩家 forced event + `respond_aid_request`

**Files:**
- Modify: `scripts/simulation/player_command_system.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 加玩家測試**

```gdscript
func _test_aid_player_forced_event() -> void:
	print("--- Survival Task7a: 玩家收到 aid forced event ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	state.player_id = 200
	# 玩家 team
	var pt := TeamData.new(); pt.team_id = 0; pt.population = 10
	pt.resources["food"] = 500.0
	pt.leader_id = 200
	state.teams[0] = pt
	var player := PersonData.new(); player.id = 200; player.team_id = 0
	state.persons[200] = player
	# Beggar
	var b := TeamData.new(); b.team_id = 1; b.population = 10
	b.resources["food"] = 0; b.combat_target = 0; b.current_task = "乞食"
	b.previous_task = "idle"
	var b_leader := PersonData.new(); b_leader.id = 300
	state.persons[300] = b_leader; b.leader_id = 300
	state.teams[1] = b
	var inter := InteractionSystem.new()
	var r: Dictionary = inter._resolve_aid_request(state, 1, 0)
	assert(r.get("pending", false), "玩家 target 應 pending")
	assert(not state.player_forced_event.is_empty(), "forced_event 應寫入")
	assert(state.player_forced_event.get("action") == "aid_request",
		"forced action 應為 aid_request")
	print("Survival Task7a OK")

func _test_aid_player_response_give() -> void:
	print("--- Survival Task7b: 玩家給予回應 ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	state.player_id = 200
	var pt := TeamData.new(); pt.team_id = 0; pt.population = 10
	pt.resources["food"] = 500.0; pt.leader_id = 200
	state.teams[0] = pt
	var player := PersonData.new(); player.id = 200; player.team_id = 0
	state.persons[200] = player
	var b := TeamData.new(); b.team_id = 1; b.population = 10
	b.resources["food"] = 0; b.current_task = "乞食"; b.previous_task = "idle"
	var b_leader := PersonData.new(); b_leader.id = 300
	state.persons[300] = b_leader; b.leader_id = 300
	state.teams[1] = b
	state.player_forced_event = { "from_id": 1, "action": "aid_request" }
	state.player_state["aid_response"] = { "give_amount": 50.0 }
	var cmd := PlayerCommandSystem.new()
	var r: Dictionary = cmd.execute_action(state, 1, "respond_aid_request")
	assert(r.get("ok", false), "respond 應成功")
	assert(float(b.resources["food"]) == 50.0, "beggar 應收 50 food")
	assert(float(pt.resources["food"]) == 450.0, "玩家應扣 50 food")
	assert(b.current_task == "idle", "beggar 應回 previous_task")
	assert(state.player_forced_event.is_empty(), "forced_event 應清空")
	print("Survival Task7b OK")
```

- [ ] **Step 2: 跑測試確認失敗**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

預期：`respond_aid_request` 未實作 → fail

- [ ] **Step 3: 加 `respond_aid_request` action**

`player_command_system.gd` 加：

```gdscript
"respond_aid_request": _action_respond_aid_request,
```

於 action 註冊區（match action_name 附近）。實作：

```gdscript
func _action_respond_aid_request(state: WorldState, target_id: int, pt: TeamData, pt_id: int) -> Dictionary:
	var fe: Dictionary = state.player_forced_event
	if fe.is_empty() or fe.get("action", "") != "aid_request":
		return { "ok": false, "msg": "無待回應 aid event" }
	var beggar_id: int = int(fe.get("from_id", -1))
	var beggar: TeamData = state.teams.get(beggar_id)
	if beggar == null:
		state.player_forced_event = {}
		return { "ok": false, "msg": "beggar 不存在" }
	var b_leader: PersonData = state.persons.get(beggar.leader_id)
	var response: Dictionary = state.player_state.get("aid_response", {})
	var msg_sys := SimMessageSystem.new()
	var npc_ai := NpcAiSystem.new()
	if response.get("refuse", false):
		msg_sys.emit_message(state, "aid_refused",
			"玩家拒絕援助 Team%d" % beggar_id, pt,
			{ "origin": str(pt_id), "target": str(beggar_id) })
		_update_rep(beggar, pt_id, -0.1)
		if b_leader: npc_ai.write_memory(b_leader, "rejected_aid", pt_id,
			state.world.current_tick, 0.5)
	else:
		var amt: float = float(response.get("give_amount", 0.0))
		var actual: float = minf(amt, float(pt.resources.get("food", 0)))
		if actual <= 0.0:
			msg_sys.emit_message(state, "aid_refused",
				"玩家無餘糧", pt, ...)
		else:
			pt.resources["food"] = float(pt.resources.get("food", 0)) - actual
			beggar.resources["food"] = float(beggar.resources.get("food", 0)) + actual
			msg_sys.emit_message(state, "aid_given",
				"玩家援助 Team%d %.0f 食物" % [beggar_id, actual], pt,
				{ "origin": str(pt_id), "target": str(beggar_id), "amount": "%.0f" % actual })
			_update_rep(beggar, pt_id, 0.15)
			if b_leader: npc_ai.write_memory(b_leader, "benefactor", pt_id,
				state.world.current_tick, clampf(actual / 50.0, 0.1, 1.0))
	# beggar 回 previous_task
	beggar.current_task = beggar.previous_task if beggar.previous_task != "" else TeamData.TASK_IDLE
	beggar.previous_task = ""
	beggar.combat_target = -1
	state.player_forced_event = {}
	state.player_forced_event_id = ""
	state.player_state.erase("aid_response")
	return { "ok": true, "msg": "已處理" }

func _update_rep(team: TeamData, other_id: int, delta: float) -> void:
	var cur: float = float(team.known_reputations.get(other_id, 0.5))
	team.known_reputations[other_id] = clampf(cur + delta, 0.0, 1.0)
```

- [ ] **Step 4: 跑測試確認通過**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

預期：`Survival Task7a/b OK`

- [ ] **Step 5: Commit**

```powershell
git add scripts/simulation/player_command_system.gd scripts/debug/headless_test.gd
git commit -m "feat(player_cmd): respond_aid_request action + forced event flow (Task 7)"
```

---

## Task 8: forced_event 超時 = aid_refused

**Files:**
- Modify: `scripts/simulation/sim_runner.gd`

- [ ] **Step 1: 找超時邏輯位置**

`sim_runner.gd:82-86`：

```gdscript
if not state.player_forced_event.is_empty():
    print("[PlayerCmd] forced_event 超時自動拒絕: %s" % str(state.player_forced_event))
    state.player_forced_event = {}
    state.player_forced_event_id = ""
```

- [ ] **Step 2: 加 aid_request callback**

改為：

```gdscript
if not state.player_forced_event.is_empty():
    var fe: Dictionary = state.player_forced_event
    if fe.get("action", "") == "aid_request":
        # 超時 = 拒絕（同 NPC 自決）
        var beggar_id: int = int(fe.get("from_id", -1))
        var beggar: TeamData = state.teams.get(beggar_id)
        if beggar != null:
            var b_leader: PersonData = state.persons.get(beggar.leader_id)
            var pt: TeamData = _get_player_team(state)
            if pt != null and b_leader != null:
                _message_system.emit_message(state, "aid_refused",
                    "玩家未回應，視同拒絕援助 Team%d" % beggar_id, pt,
                    { "origin": str(pt.team_id), "target": str(beggar_id) })
                # rep 降、memory
                var cur: float = float(beggar.known_reputations.get(pt.team_id, 0.5))
                beggar.known_reputations[pt.team_id] = clampf(cur - 0.1, 0.0, 1.0)
                NpcAiSystem.new().write_memory(b_leader, "rejected_aid",
                    pt.team_id, state.world.current_tick, 0.5)
            # beggar 回 previous_task
            beggar.current_task = beggar.previous_task if beggar.previous_task != "" else TeamData.TASK_IDLE
            beggar.previous_task = ""
            beggar.combat_target = -1
    print("[PlayerCmd] forced_event 超時自動拒絕: %s" % str(state.player_forced_event))
    state.player_forced_event = {}
    state.player_forced_event_id = ""
```

加 `_get_player_team` helper（若未有）：

```gdscript
func _get_player_team(state: WorldState) -> TeamData:
    if state.player_id == -1: return null
    var p: PersonData = state.persons.get(state.player_id)
    if p == null: return null
    return state.teams.get(p.team_id)
```

- [ ] **Step 3: 跑全測試確認無 regression**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

預期：全 OK。

- [ ] **Step 4: Commit**

```powershell
git add scripts/simulation/sim_runner.gd
git commit -m "fix(sim_runner): aid_request forced event timeout = refuse + memory (Task 8)"
```

---

## Task 9: 反覆乞食 annoyance 測試 + 陌生 team 測試

**Files:**
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 加測試**

```gdscript
func _test_aid_repeated_annoyance() -> void:
	print("--- Survival Task9a: 反覆乞食 annoyance ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	# beggar
	var b := TeamData.new(); b.team_id = 0; b.population = 10
	b.combat_target = 1
	var b_leader := PersonData.new(); b_leader.id = 100
	state.persons[100] = b_leader; b.leader_id = 100
	# target 中等義氣，給 4 次後應拒絕
	var t := TeamData.new(); t.team_id = 1; t.population = 10
	t.resources["food"] = 5000.0
	var t_leader := PersonData.new(); t_leader.id = 200
	t_leader.values = { "義氣": 0.5, "貪婪": 0.3 }
	state.persons[200] = t_leader; t.leader_id = 200
	state.teams[0] = b; state.teams[1] = t
	var inter := InteractionSystem.new()
	# 重置 beggar food + task 後重乞 5 次
	var accepted_count: int = 0
	for i in range(5):
		b.resources["food"] = 0
		b.current_task = "乞食"; b.previous_task = "idle"
		b.combat_target = 1
		var r: Dictionary = inter._resolve_aid_request(state, 0, 1)
		if r.get("accepted", false):
			accepted_count += 1
	# 預期：annoyance 累積後拒絕，accepted_count < 5
	assert(accepted_count < 5,
		"反覆乞食 5 次應有拒絕，全接受 = annoyance 機制無效")
	print("Survival Task9a OK (5 次中接受 %d 次)" % accepted_count)

func _test_aid_stranger() -> void:
	print("--- Survival Task9b: 陌生 team 也可乞食 ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	var b := TeamData.new(); b.team_id = 0; b.population = 5
	b.combat_target = 1; b.current_task = "乞食"; b.previous_task = "idle"
	var b_leader := PersonData.new(); b_leader.id = 100
	state.persons[100] = b_leader; b.leader_id = 100
	state.teams[0] = b
	var t := TeamData.new(); t.team_id = 1; t.population = 10
	t.resources["food"] = 500.0
	var t_leader := PersonData.new(); t_leader.id = 200
	t_leader.values = { "義氣": 0.7, "貪婪": 0.2 }
	state.persons[200] = t_leader; t.leader_id = 200
	state.teams[1] = t
	# 確認 rep 預設 0.5（陌生）
	assert(not t.known_reputations.has(0), "預設無 rep 記錄")
	var inter := InteractionSystem.new()
	var r: Dictionary = inter._resolve_aid_request(state, 0, 1)
	assert(r.get("accepted", false), "陌生 + 高義氣 target 應接受")
	print("Survival Task9b OK")
```

- [ ] **Step 2: 跑測試確認通過**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

預期：全 OK

- [ ] **Step 3: Commit**

```powershell
git add scripts/debug/headless_test.gd
git commit -m "test(survival): repeated begging annoyance + stranger team beg (Task 9)"
```

---

## Task 10: 整合驗證 + handback

**Files:**
- Modify: `docs/superpowers/handbacks/2026-06-08-npc-survival-decision.md`

- [ ] **Step 1: 跑 game_sim_test 看 survival 是否觸發**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/game_sim_test.gd > godot_test.log 2>&1
Get-Content godot_test.log -Encoding UTF8 | Select-String "乞食|return_home|aid_given|aid_refused|Survival" | Select-Object -First 30
```

預期：log 出現至少 1 個 survival task 切換 + 1 個 aid 結算。

- [ ] **Step 2: 寫 handback**

新建 `docs/superpowers/handbacks/2026-06-08-npc-survival-decision.md`：

```markdown
# Hand Back: NPC Survival Decision

## 實作摘要

- `team_data.gd`: 加 `previous_task: String` 欄位
- `faction_ai_system.gd`:
  - 加 `SURVIVAL_TASKS`、`URGENCY_DAYS`、`WARNING_DAYS` 常數
  - 加 `_evaluate_survival` 入口 + sticky check
  - 加 `_trigger_survival` 4 路徑決策樹
  - 加 4 個 find helper（own_outpost、weakest_prey、strong_neighbor、aid_target）
  - 加 `_should_abandon_current_task`（警戒等級距離考量）
  - 整合到 `evaluate_all` team loop
- `strategic_ai_system.gd`: 設 task 前檢查 SURVIVAL_TASKS sticky
- `interaction_system.gd`:
  - 加 `_resolve_aid_request`（NPC 自決路徑 + 玩家 forced event）
  - 加 `_count_recent_begs`、`_clear_aid_task` helpers
  - pair resolve 加乞食判斷
- `player_command_system.gd`: 加 `respond_aid_request` action
- `sim_runner.gd`: forced event 超時 = aid_refused + write memory

## 行為變化

- NPC team food < 3 天份 → 自動切 survival task
- 4 路徑依 leader values 選擇：return_home / 掠奪 / 投靠 / 乞食
- 乞食既能對盟友也能對陌生（rep=0.5 預設）
- 反覆乞食累積 annoyance memory → 自然遞減接受率
- 接受 = beggar 寫 benefactor memory（未來忠誠盟友）
- 拒絕 = beggar 寫 rejected_aid memory（未來敵意）

## 連動風險

- strategic_ai 仍可能漏改某處 → 多測 game_sim_test 確認
- 玩家被乞食時的 UI 未做（S9 領域）
- aid 訊息文字未進 text_bank（emit_message 寫死字串，後續可整合）

## 待主 session 確認

- 速度評估系統 spec（影響「乞食抵達途中目標移動」）
- 分層評估頻率 spec（影響 survival 評估在哪層）
```

- [ ] **Step 3: Commit handback**

```powershell
git add docs/superpowers/handbacks/2026-06-08-npc-survival-decision.md
git commit -m "docs: NPC survival decision handback (Task 10)"
```
