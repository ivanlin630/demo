# Population Management Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 實作超額強制分裂（pop > pop_cap → 自動切出）和 FactionAI 小隊合併整合（閾值合併 + 戰前集結）。

**Architecture:** 新建 `PopulationSystem` 做 overflow 檢查（每 10 tick 全域掃），SimRunner 呼叫。FactionAI `_assign_member_tasks` 加閾值合併和戰前集結邏輯（直接指派，不用 herald）。

**Tech Stack:** Godot 4.2.2 GDScript，無外部依賴。

---

## 背景知識（implementer 必讀）

### pop_cap_from_leadership

```gdscript
# scripts/data/team_data.gd line 26
static func pop_cap_from_leadership(skill: float) -> int:
    return clampi(int(round(49.0 * minf(skill / 0.8, 1.0))) + 1, 1, 50)
# skill=0.0 → cap=1, skill=0.3 → cap=19, skill=0.6 → cap=37, skill=0.8 → cap=50
```

### 溢出觸發原因

目前：leader 死亡後繼任者統領較低（`on_leader_death` 已有即時 overflow dispatch，本次為週期性安全網補掃）。未來：自然人口增長。

### SubteamSystem.dispatch

```gdscript
# subteam_system.gd line 3
func dispatch(state, parent_id, sub_leader_id, pop_count, task, move_target,
    order_target_id=-1, order_task="", extra_advisor_ids=[]) -> int
# sub_leader_id 必須在 parent.advisors 或 parent.members 中
# pop_count 自動 clamp 到 sub_leader 的 pop_cap 和 parent.population-1
```

### FactionAI _assign_member_tasks 現況

```gdscript
# faction_ai_system.gd lines 186-213
func _assign_member_tasks(state: WorldState, f) -> void:
    for mid in f.member_team_ids:
        if mid == f.leader_team_id: continue
        var mt: TeamData = state.teams.get(mid)
        if mt == null or mt.combat_target != -1 or mt.current_task != "idle":
            continue
        if "徵收" in f.goals and _tag_weight(mt, "徵收") > 0.0:
            ...
        elif "外交" in f.goals and _tag_weight(mt, "外交") > 0.0:
            ...
        elif "攻擊" in f.goals and _tag_weight(mt, "攻擊") > 0.0:
            var target_id: int = _nearest_independent(state, mt)
            if target_id != -1:
                mt.current_task = "攻擊"
                mt.move_target  = state.teams[target_id].tile_pos
        elif _can_manufacture(state, mt):
            ...
        elif _can_trade(state, mt):
            ...
```

新邏輯插入在現有 if-elif 鏈**之前**（優先級最高）。

### _hex_dist 已存在於 FactionAI

```gdscript
func _hex_dist(a: Vector2i, b: Vector2i) -> int:
    var dx := b.x - a.x; var dy := b.y - a.y
    return (abs(dx) + abs(dx + dy) + abs(dy)) / 2
```

---

## 檔案結構

| 檔案 | 動作 |
|---|---|
| `scripts/simulation/population_system.gd` | 新建 |
| `scripts/simulation/sim_runner.gd` | 加成員變數 + `_step1d_overflow` |
| `scripts/simulation/faction_ai_system.gd` | 加常數 + 修改 `_assign_member_tasks` + 加 `_find_absorber` |
| `scripts/debug/headless_test.gd` | 加 4 個驗證場景 |
| `docs/progress.md` | 更新 |

---

## Task A：PopulationSystem 新建

**Files:**
- Create: `scripts/simulation/population_system.gd`

- [ ] **Step 1: 建立檔案**

```gdscript
# scripts/simulation/population_system.gd
class_name PopulationSystem

const OVERFLOW_CHECK_INTERVAL: int = 10  # TEST VALUE

func check_overflow(state: WorldState) -> void:
	for tid in state.teams.keys():
		if not state.teams.has(tid):
			continue
		var team: TeamData = state.teams[tid]
		var leader = state.persons.get(team.leader_id)
		var cmd: float = float(leader.skills.get("統領", 0.0)) if leader else 0.0
		var cap: int = TeamData.pop_cap_from_leadership(cmd)
		var overflow: int = team.population - cap
		if overflow <= 0:
			continue
		var spare_id: int = -1
		for aid in team.advisors:
			if aid != team.leader_id:
				spare_id = aid
				break
		if spare_id == -1:
			for mid in team.members:
				spare_id = mid
				break
		if spare_id != -1:
			SubteamSystem.new().dispatch(state, tid, spare_id, overflow, "idle", team.tile_pos)
			print("[PopMgmt] Team%d 超額 %d 人，advisor Team%d 帶走" % [tid, overflow, spare_id])
		else:
			_create_overflow_team(state, team, overflow)

func _create_overflow_team(state: WorldState, origin: TeamData, overflow_pop: int) -> void:
	var ot := TeamData.new()
	ot.team_id      = _next_team_id(state)
	ot.tile_pos     = origin.tile_pos
	ot.faction_id   = -1
	ot.tags         = ["流亡"]
	ot.population   = overflow_pop
	ot.current_task = TeamData.TASK_IDLE
	var frac: float = float(overflow_pop) / float(origin.population)
	for res in origin.resources:
		var amt: float = float(origin.resources.get(res, 0)) * frac
		ot.resources[res]     = amt
		origin.resources[res] = float(origin.resources.get(res, 0)) - amt
	origin.population -= overflow_pop
	state.teams[ot.team_id]           = ot
	state.team_known[ot.team_id]      = []
	state.team_discovered[ot.team_id] = []
	var gen := PersonGenerator.new()
	var promoted := gen.generate(ot, state)
	if promoted != null:
		ot.leader_id  = promoted.id
		promoted.role = "leader"
	print("[PopMgmt] Team%d 超額 %d 人無 advisor，獨立流亡 Team%d" % [
		origin.team_id, overflow_pop, ot.team_id])

func _next_team_id(state: WorldState) -> int:
	var max_id: int = -1
	for tid in state.teams:
		if tid > max_id:
			max_id = tid
	return max_id + 1
```

- [ ] **Step 2: 重建快取**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --import
```

預期：無 SCRIPT ERROR，exit 0（PowerShell 可能 exit 1 因 WARNING，正常）。

- [ ] **Step 3: Commit**

```powershell
git add scripts/simulation/population_system.gd
git commit -m "feat(sim): add PopulationSystem for overflow split"
```

---

## Task B：SimRunner 整合

**Files:**
- Modify: `scripts/simulation/sim_runner.gd`

- [ ] **Step 1: 加成員變數和初始化**

找到（line 18）：
```gdscript
var _equipment_system: EquipmentSystem
```

替換為：
```gdscript
var _equipment_system: EquipmentSystem
var _population_system: PopulationSystem
```

找到 `_init()` 末段（line 33）：
```gdscript
	_equipment_system = EquipmentSystem.new()
```

替換為：
```gdscript
	_equipment_system    = EquipmentSystem.new()
	_population_system   = PopulationSystem.new()
```

- [ ] **Step 2: 加 `_step1d_overflow` 呼叫**

找到（line 36–37）：
```gdscript
func advance_tick(state: WorldState, player_pos: Vector2i) -> void:
	_step1_advance_time(state)
```

替換為：
```gdscript
func advance_tick(state: WorldState, player_pos: Vector2i) -> void:
	_step1_advance_time(state)
	if state.world.current_tick % PopulationSystem.OVERFLOW_CHECK_INTERVAL == 0:
		_step1d_overflow(state)
```

找到（line 72）：
```gdscript
func _step1b_update_vision(state: WorldState, team_ids: Array) -> void:
```

在其**之前**插入：
```gdscript
func _step1d_overflow(state: WorldState) -> void:
	_population_system.check_overflow(state)

```

- [ ] **Step 3: 重建快取**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --import
```

預期：無 SCRIPT ERROR。

- [ ] **Step 4: Commit**

```powershell
git add scripts/simulation/sim_runner.gd
git commit -m "feat(sim): wire PopulationSystem overflow check in SimRunner"
```

---

## Task C：FactionAI 小隊合併整合

**Files:**
- Modify: `scripts/simulation/faction_ai_system.gd`

- [ ] **Step 1: 加三個常數（在現有常數末段，約 line 18 後）**

找到（line 18）：
```gdscript
const DEVIATION_RATE: float       = 0.05  # TEST VALUE — 子團偏離基礎概率
```

替換為：
```gdscript
const DEVIATION_RATE: float       = 0.05  # TEST VALUE — 子團偏離基礎概率
const SMALL_TEAM_RATIO: float     = 0.3   # TEST VALUE — pop < cap×0.3 視為小隊
const SMALL_VS_LARGE: float       = 0.33  # TEST VALUE — pop < absorber.pop×0.33 才觸發合併
const CONSOLIDATE_MAX_DIST: int   = 3     # TEST VALUE — 戰前集結距離上限（hex）
```

- [ ] **Step 2: 修改 `_assign_member_tasks`（lines 186-213）**

找到完整函式：
```gdscript
func _assign_member_tasks(state: WorldState, f) -> void:
	for mid in f.member_team_ids:
		if mid == f.leader_team_id: continue
		var mt: TeamData = state.teams.get(mid)
		if mt == null or mt.combat_target != -1 or mt.current_task != "idle":
			continue
		if "徵收" in f.goals and _tag_weight(mt, "徵收") > 0.0:
			var best_tid: int = _richest_member(state, f)
			if best_tid != -1 and best_tid != mid:
				mt.current_task = "徵收"
				mt.move_target  = state.teams[best_tid].tile_pos
		elif "外交" in f.goals and _tag_weight(mt, "外交") > 0.0:
			var target_id: int = _nearest_independent(state, mt)
			if target_id != -1:
				mt.current_task = "外交"
				mt.move_target  = state.teams[target_id].tile_pos
		elif "攻擊" in f.goals and _tag_weight(mt, "攻擊") > 0.0:
			var target_id: int = _nearest_independent(state, mt)
			if target_id != -1:
				mt.current_task = "攻擊"
				mt.move_target  = state.teams[target_id].tile_pos
		elif _can_manufacture(state, mt):
			mt.current_task = TeamData.TASK_MANUFACTURE
		elif _can_trade(state, mt):
			var pid: int = _find_trade_target(state, mt)
			if pid != -1:
				mt.current_task = TeamData.TASK_TRADE
				mt.move_target  = state.teams[pid].tile_pos
```

替換為：
```gdscript
func _assign_member_tasks(state: WorldState, f) -> void:
	var leader_team: TeamData = state.teams.get(f.leader_team_id)
	for mid in f.member_team_ids:
		if mid == f.leader_team_id: continue
		var mt: TeamData = state.teams.get(mid)
		if mt == null or mt.combat_target != -1 or mt.current_task != "idle":
			continue
		# 閾值合併：team 過小 → 找附近大隊合併
		var absorber_id: int = _find_absorber(state, mt, f)
		if absorber_id != -1:
			var mt_leader = state.persons.get(mt.leader_id)
			var mt_cmd: float = float(mt_leader.skills.get("統領", 0.0)) if mt_leader else 0.0
			var mt_cap: int = TeamData.pop_cap_from_leadership(mt_cmd)
			var small_b: bool = mt.population < int(float(mt_cap) * SMALL_TEAM_RATIO)
			var small_c: bool = float(mt.population) < float(state.teams[absorber_id].population) * SMALL_VS_LARGE
			if small_b and small_c:
				mt.current_task    = TeamData.TASK_MERGE
				mt.order_target_id = absorber_id
				mt.move_target     = state.teams[absorber_id].tile_pos
				continue
		# 戰前集結：攻擊 goal 時，近距離小隊先合併進主力
		if "攻擊" in f.goals and leader_team != null:
			var dist_to_leader: int = _hex_dist(mt.tile_pos, leader_team.tile_pos)
			if dist_to_leader > 1 and dist_to_leader <= CONSOLIDATE_MAX_DIST:
				var ldr_leader = state.persons.get(leader_team.leader_id)
				var ldr_cmd: float = float(ldr_leader.skills.get("統領", 0.0)) if ldr_leader else 0.0
				var ldr_cap: int = TeamData.pop_cap_from_leadership(ldr_cmd) - leader_team.population
				if ldr_cap > 0:
					mt.current_task    = TeamData.TASK_MERGE
					mt.order_target_id = f.leader_team_id
					mt.move_target     = leader_team.tile_pos
					continue
		# 既有邏輯
		if "徵收" in f.goals and _tag_weight(mt, "徵收") > 0.0:
			var best_tid: int = _richest_member(state, f)
			if best_tid != -1 and best_tid != mid:
				mt.current_task = "徵收"
				mt.move_target  = state.teams[best_tid].tile_pos
		elif "外交" in f.goals and _tag_weight(mt, "外交") > 0.0:
			var target_id: int = _nearest_independent(state, mt)
			if target_id != -1:
				mt.current_task = "外交"
				mt.move_target  = state.teams[target_id].tile_pos
		elif "攻擊" in f.goals and _tag_weight(mt, "攻擊") > 0.0:
			var target_id: int = _nearest_independent(state, mt)
			if target_id != -1:
				mt.current_task = "攻擊"
				mt.move_target  = state.teams[target_id].tile_pos
		elif _can_manufacture(state, mt):
			mt.current_task = TeamData.TASK_MANUFACTURE
		elif _can_trade(state, mt):
			var pid: int = _find_trade_target(state, mt)
			if pid != -1:
				mt.current_task = TeamData.TASK_TRADE
				mt.move_target  = state.teams[pid].tile_pos
```

- [ ] **Step 3: 加 `_find_absorber` 函式（在 `_assign_member_tasks` 之後）**

找到（緊接 `_assign_member_tasks` 後的下一個 `func`，即 `# ──────── 子團自主 AI ────────`）：
```gdscript
# ──────── 子團自主 AI ────────
```

在其**之前**插入：
```gdscript
func _find_absorber(state: WorldState, mt: TeamData, f) -> int:
	var best_id: int = -1
	var best_d: int  = 999
	for tid in f.member_team_ids:
		if tid == mt.team_id:
			continue
		var t: TeamData = state.teams.get(tid)
		if t == null or t.combat_target != -1:
			continue
		var t_leader = state.persons.get(t.leader_id)
		var t_cmd: float = float(t_leader.skills.get("統領", 0.0)) if t_leader else 0.0
		var t_cap: int = TeamData.pop_cap_from_leadership(t_cmd) - t.population
		if t_cap <= 0:
			continue
		var d: int = _hex_dist(mt.tile_pos, t.tile_pos)
		if d <= 1 or d > CONSOLIDATE_MAX_DIST:
			continue
		if d < best_d:
			best_d = d
			best_id = tid
	return best_id

```

- [ ] **Step 4: 重建快取**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --import
```

預期：無 SCRIPT ERROR。

- [ ] **Step 5: Commit**

```powershell
git add scripts/simulation/faction_ai_system.gd
git commit -m "feat(sim): add small-team consolidation and pre-battle merge in FactionAI"
```

---

## Task D：headless_test.gd 驗證

**Files:**
- Modify: `scripts/debug/headless_test.gd` — 在 merge_teams 清理後（line 347）、`print("=== Sim Test")` 前插入

- [ ] **Step 1: 插入 4 個驗證場景**

找到（line 347–348）：
```gdscript
	state.persons.erase(40); state.persons.erase(41); state.persons.erase(42); state.persons.erase(43)

	print("=== Sim Test: 200 Ticks ===")
```

替換為：
```gdscript
	state.persons.erase(40); state.persons.erase(41); state.persons.erase(42); state.persons.erase(43)

	# ── PopulationSystem 驗證 ──
	# 場景 1：超額 + 有 advisor → dispatch 子隊
	var ov1 := TeamData.new()
	ov1.team_id = 20; ov1.population = 5; ov1.tile_pos = Vector2i(0, -5)
	ov1.resources["food"] = 100.0
	state.teams[20] = ov1; state.team_known[20] = []; state.team_discovered[20] = []
	var ov1_leader := PersonData.new()
	ov1_leader.id = 50; ov1_leader.person_name = "OV1_leader"; ov1_leader.role = "leader"
	ov1_leader.team_id = 20; ov1_leader.skills["統領"] = 0.3  # cap≈19，pop=5 不會溢出
	state.persons[50] = ov1_leader; ov1.leader_id = 50
	# 強制用 skill=0.0 → cap=1，pop=5 → overflow=4
	ov1_leader.skills["統領"] = 0.0
	var ov1_adv := PersonData.new()
	ov1_adv.id = 51; ov1_adv.person_name = "OV1_adv"; ov1_adv.role = "civilian"
	ov1_adv.team_id = 20; ov1_adv.skills["統領"] = 0.3
	state.persons[51] = ov1_adv; ov1.advisors.append(51)
	var _pop_sys := PopulationSystem.new()
	_pop_sys.check_overflow(state)
	print("=== PopulationSystem 場景1（有advisor）===")
	var _ov1_subteam_found: bool = false
	for _tid in state.teams:
		var _t: TeamData = state.teams[_tid]
		if _t.parent_team_id == 20:
			_ov1_subteam_found = true
			print("  [OK] Team%d 子隊建立 pop=%d" % [_t.team_id, _t.population])
			break
	if not _ov1_subteam_found:
		print("  [FAIL] 未建立子隊")
	if ov1.population <= 1:
		print("  [OK] Team20 pop 降至 %d（≤cap=1）" % ov1.population)
	else:
		print("  [FAIL] Team20 pop=%d 仍超額" % ov1.population)

	# 場景 2：超額 + 無 advisor → 獨立流亡 team
	var ov2 := TeamData.new()
	ov2.team_id = 21; ov2.population = 4; ov2.tile_pos = Vector2i(0, -5)
	ov2.resources["food"] = 80.0
	state.teams[21] = ov2; state.team_known[21] = []; state.team_discovered[21] = []
	var ov2_leader := PersonData.new()
	ov2_leader.id = 52; ov2_leader.person_name = "OV2_leader"; ov2_leader.role = "leader"
	ov2_leader.team_id = 21; ov2_leader.skills["統領"] = 0.0  # cap=1，pop=4 → overflow=3
	state.persons[52] = ov2_leader; ov2.leader_id = 52
	var _teams_before_ov2: int = state.teams.size()
	_pop_sys.check_overflow(state)
	print("=== PopulationSystem 場景2（無advisor）===")
	if state.teams.size() > _teams_before_ov2:
		print("  [OK] 新 team 建立（流亡）")
		for _tid in state.teams:
			var _t: TeamData = state.teams[_tid]
			if _t.tags.has("流亡") and _t.tile_pos == Vector2i(0, -5) and _t.team_id != 21:
				print("  [OK] Team%d 流亡 pop=%d leader_id=%d" % [_t.team_id, _t.population, _t.leader_id])
				break
	else:
		print("  [FAIL] 未建立流亡 team")

	# 場景 3：FactionAI 閾值合併（小隊 pop 過小）
	var fac99 = state.create_faction(22)
	var fa := TeamData.new()
	fa.team_id = 22; fa.population = 20; fa.faction_id = fac99; fa.tile_pos = Vector2i(0, -6)
	state.teams[22] = fa; state.team_known[22] = []; state.team_discovered[22] = []
	var fa_l := PersonData.new()
	fa_l.id = 53; fa_l.person_name = "FA_leader"; fa_l.role = "leader"
	fa_l.team_id = 22; fa_l.skills["統領"] = 0.6  # cap≈37
	state.persons[53] = fa_l; fa.leader_id = 53
	if not state.factions[fac99].member_team_ids.has(22):
		state.factions[fac99].member_team_ids.append(22)
	state.factions[fac99].leader_team_id = 22

	var fb := TeamData.new()
	fb.team_id = 23; fb.population = 2; fb.faction_id = fac99; fb.tile_pos = Vector2i(0, -8)  # dist=2
	state.teams[23] = fb; state.team_known[23] = []; state.team_discovered[23] = []
	var fb_l := PersonData.new()
	fb_l.id = 54; fb_l.person_name = "FB_leader"; fb_l.role = "leader"
	fb_l.team_id = 23; fb_l.skills["統領"] = 0.2  # cap≈13，pop=2 < 13×0.3=3.9 → 小隊
	state.persons[54] = fb_l; fb.leader_id = 54
	state.factions[fac99].member_team_ids.append(23)

	var _fai := load("res://scripts/simulation/faction_ai_system.gd").new()
	var _f99 = state.factions[fac99]
	_fai._assign_member_tasks(state, _f99)
	print("=== FactionAI 閾值合併測試 ===")
	if fb.current_task == TeamData.TASK_MERGE and fb.order_target_id == 22:
		print("  [OK] Team23 收到 TASK_MERGE → Team22")
	else:
		print("  [FAIL] Team23 task=%s order=%d" % [fb.current_task, fb.order_target_id])

	# 場景 4：FactionAI 戰前集結
	_f99.goals = ["攻擊"]
	fb.current_task = "idle"; fb.order_target_id = -1; fb.move_target = Vector2i(-1, -1)
	_fai._assign_member_tasks(state, _f99)
	print("=== FactionAI 戰前集結測試 ===")
	if fb.current_task == TeamData.TASK_MERGE and fb.order_target_id == 22:
		print("  [OK] Team23（dist=2）收到 TASK_MERGE → 主力Team22（戰前集結）")
	else:
		print("  [FAIL] Team23 task=%s order=%d" % [fb.current_task, fb.order_target_id])

	# 清理
	for _tid in [20, 21, 22, 23]:
		state.teams.erase(_tid)
		state.team_known.erase(_tid)
		state.team_discovered.erase(_tid)
	for _pid in [50, 51, 52, 53, 54]:
		state.persons.erase(_pid)
	state.factions.erase(fac99)

	print("=== Sim Test: 200 Ticks ===")
```

- [ ] **Step 2: 跑 headless**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

預期輸出（含以下片段）：
```
=== PopulationSystem 場景1（有advisor）===
  [OK] TeamXX 子隊建立 pop=...
  [OK] Team20 pop 降至 1（≤cap=1）
=== PopulationSystem 場景2（無advisor）===
  [OK] 新 team 建立（流亡）
  [OK] TeamXX 流亡 pop=3 leader_id=...
=== FactionAI 閾值合併測試 ===
  [OK] Team23 收到 TASK_MERGE → Team22
=== FactionAI 戰前集結測試 ===
  [OK] Team23（dist=2）收到 TASK_MERGE → 主力Team22（戰前集結）
=== Sim Test: 200 Ticks ===
...
=== DONE ===
```

無 SCRIPT ERROR，`=== DONE ===` 出現，原有輸出（[Trade], [SubAI], PersonGenerator, merge_teams 等）仍正常。

- [ ] **Step 3: Commit**

```powershell
git add scripts/debug/headless_test.gd
git commit -m "test: add population management headless validation"
```

---

## Task E：文件更新

**Files:**
- Modify: `docs/progress.md`

- [ ] **Step 1: 加入模擬系統層表格**

在 `docs/progress.md` 的模擬系統層表格末段加一行：

```
| `population_system.gd` | 超額強制分裂：每 10 tick 掃全域；有 advisor → dispatch 子隊；無 advisor → 獨立流亡 team + PersonGenerator 晉升 |
```

- [ ] **Step 2: 加入低優先完成項目**

找到「低優先」表格中的超額人口項目：
```
| 超額人口強制離開 | pop 超過 pop_cap_from_leadership 時強制縮減（分團或逃亡）；PersonGenerator path 目前略過此檢查 |
```

以 strikethrough 替換並加 FactionAI 合併說明：
```
| ~~**超額人口強制離開 + 小隊合併整合**~~ | ~~PopulationSystem overflow split（每 10 tick）；FactionAI 閾值合併（pop < cap×0.3）；戰前集結（dist 2–3 先合併）~~ |
```

- [ ] **Step 3: Commit**

```powershell
git add docs/progress.md
git commit -m "docs: add population management to progress"
```

---

## 驗證 Checklist

```
[ ] headless 無 SCRIPT ERROR
[ ] === DONE === 出現
[ ] 場景1 [OK] TeamXX 子隊建立 + Team20 pop 降至 1
[ ] 場景2 [OK] 流亡 team 建立 + leader_id != -1
[ ] 場景3 [OK] Team23 TASK_MERGE → Team22（閾值合併）
[ ] 場景4 [OK] Team23 TASK_MERGE → Team22（戰前集結）
[ ] 原有輸出正常（PersonGenerator/merge_teams/200Tick 仍 OK）
```

---

## ⚠️ 測試值（平衡期調整）

| 常數 | 位置 | 值 |
|---|---|---|
| `OVERFLOW_CHECK_INTERVAL` | `population_system.gd` | 10 |
| `SMALL_TEAM_RATIO` | `faction_ai_system.gd` | 0.3 |
| `SMALL_VS_LARGE` | `faction_ai_system.gd` | 0.33 |
| `CONSOLIDATE_MAX_DIST` | `faction_ai_system.gd` | 3 |
