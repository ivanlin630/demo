# Faction Known State Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 建立 FactionAI 情報介面層 `known_member_states`，讓 AI 讀成員快照而非即時全知讀取，並預留未來 IntelSystem 限制傳播的接口。

**Architecture:** `FactionData` 加快照 dict；`WorldState` 加 stub helper 直接讀取狀態；`FactionAISystem.evaluate_all` 每輪刷新快照（stub）；`_richest_member` 和 `_assign_member_tasks` 改讀快照介面；`_try_subjugate`/`_try_diplomacy` 加入時初始快照。

**Tech Stack:** Godot 4.2.2 GDScript，無外部依賴。

---

## 背景知識（implementer 必讀）

### 現有 FactionData（scripts/data/faction_data.gd）

```gdscript
class_name FactionData
var faction_id: int = 0
var faction_name: String = ""
var is_established: bool = false
var leader_team_id: int = -1
var member_team_ids: Array = []   # 含 leader_team_id
var tribute_rate: float = 0.10
var goals: Array = []
var strategy: String = "idle"
var relations: Dictionary = {}
```

### FactionAI `_richest_member` 現況（faction_ai_system.gd line 511）

```gdscript
func _richest_member(state: WorldState, f) -> int:
    var best_tid: int    = -1
    var best_food: float = 0.0
    for mid in f.member_team_ids:
        if mid == f.leader_team_id or not state.teams.has(mid):
            continue
        var mfood: float = float(state.teams[mid].resources.get("food", 0))
        if mfood > best_food:
            best_food = mfood
            best_tid  = mid
    return best_tid
```

### `_assign_member_tasks` 任務過濾（faction_ai_system.gd line 194）

```gdscript
        if mt == null or mt.combat_target != -1 or mt.current_task != "idle":
            continue
```

### `evaluate_all`（faction_ai_system.gd lines 29-33）

```gdscript
func evaluate_all(state: WorldState, _team_ids: Array) -> void:
    for fid in state.factions:
        var f = state.factions[fid]
        _update_goals(state, f)
        _assign_tasks(state, f)
    # ...
```

### `_declare_established`（faction_ai_system.gd lines 523-532）

```gdscript
func _declare_established(state: WorldState, f, leader_team: TeamData) -> void:
    f.is_established = true
    f.faction_name   = "勢力%d" % f.faction_id
    f.goals.erase("立國")
    SimMessageSystem.new().emit_message(...)
    print(...)
```

### `_try_subjugate`（interaction_system.gd line 615）

```gdscript
func _try_subjugate(state: WorldState, winner_id: int, loser_id: int) -> void:
    ...
    loser.faction_id = fid
    _msg.emit_message(...)
    print(...)
```

### `_try_diplomacy`（interaction_system.gd line 630）

```gdscript
func _try_diplomacy(state: WorldState, initiator_id: int, target_id: int) -> void:
    ...
    target.faction_id = fid
    initiator.current_task = "idle"
    _msg.emit_message(...)
    print(...)
```

---

## 檔案結構

| 檔案 | 動作 |
|---|---|
| `scripts/data/faction_data.gd` | 加 `known_member_states` |
| `scripts/data/world_state.gd` | 加 `snapshot_faction_member()` |
| `scripts/simulation/faction_ai_system.gd` | 改 `evaluate_all` + `_richest_member` + `_assign_member_tasks` + `_declare_established` |
| `scripts/simulation/interaction_system.gd` | 改 `_try_subjugate` + `_try_diplomacy` |
| `scripts/debug/headless_test.gd` | 加快照驗證場景 |
| `docs/progress.md` | 更新 |

---

## Task A：FactionData + WorldState 介面

**Files:**
- Modify: `scripts/data/faction_data.gd`
- Modify: `scripts/data/world_state.gd`

- [ ] **Step 1: 加 `known_member_states` 到 FactionData**

找到（faction_data.gd 末行）：
```gdscript
var relations: Dictionary = {}  # faction_id → String
```
替換為：
```gdscript
var relations: Dictionary = {}  # faction_id → String

var known_member_states: Dictionary = {}
# { team_id: int → {
#   "food":         float,    # resources["food"]
#   "weapons":      int,      # sum(melee_low+melee_high+ranged_low+ranged_high)
#   "goods":        float,    # resources["goods"]
#   "population":   int,
#   "tile_pos":     Vector2i,
#   "current_task": String,
#   "last_tick":    int,
# }}
```

- [ ] **Step 2: 加 `snapshot_faction_member` 到 WorldState**

找到（world_state.gd 末行）：
```gdscript
	print("[Faction] 勢力%d 解散" % faction_id)
```
在其後加：
```gdscript

func snapshot_faction_member(team_id: int, tick: int) -> void:
	var t: TeamData = teams.get(team_id)
	if t == null or t.faction_id == -1:
		return
	var f = factions.get(t.faction_id)
	if f == null:
		return
	f.known_member_states[team_id] = {
		"food":         float(t.resources.get("food", 0.0)),
		"weapons":      int(t.resources.get("weapon_melee_low",   0))
		              + int(t.resources.get("weapon_melee_high",  0))
		              + int(t.resources.get("weapon_ranged_low",  0))
		              + int(t.resources.get("weapon_ranged_high", 0)),
		"goods":        float(t.resources.get("goods", 0.0)),
		"population":   t.population,
		"tile_pos":     t.tile_pos,
		"current_task": t.current_task,
		"last_tick":    tick,
	}
```

- [ ] **Step 3: 重建快取**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --import
```

預期：無 SCRIPT ERROR（exit 1 因 WARNING 正常）。

- [ ] **Step 4: Commit**

```powershell
git add scripts/data/faction_data.gd scripts/data/world_state.gd
git commit -m "feat(data): add known_member_states to FactionData + snapshot helper"
```

---

## Task B：FactionAI 改讀快照

**Files:**
- Modify: `scripts/simulation/faction_ai_system.gd`

- [ ] **Step 1: `evaluate_all` 加 stub 刷新**

找到：
```gdscript
func evaluate_all(state: WorldState, _team_ids: Array) -> void:
	for fid in state.factions:
		var f = state.factions[fid]
		_update_goals(state, f)
		_assign_tasks(state, f)
```
替換為：
```gdscript
func evaluate_all(state: WorldState, _team_ids: Array) -> void:
	for fid in state.factions:
		var f = state.factions[fid]
		for mid in f.member_team_ids:
			state.snapshot_faction_member(mid, state.world.current_tick)
		_update_goals(state, f)
		_assign_tasks(state, f)
```

- [ ] **Step 2: `_richest_member` 改讀快照**

找到：
```gdscript
func _richest_member(state: WorldState, f) -> int:
	var best_tid: int    = -1
	var best_food: float = 0.0
	for mid in f.member_team_ids:
		if mid == f.leader_team_id or not state.teams.has(mid):
			continue
		var mfood: float = float(state.teams[mid].resources.get("food", 0))
		if mfood > best_food:
			best_food = mfood
			best_tid  = mid
	return best_tid
```
替換為：
```gdscript
func _richest_member(state: WorldState, f) -> int:
	var best_tid: int    = -1
	var best_food: float = 0.0
	for mid in f.member_team_ids:
		if mid == f.leader_team_id or not state.teams.has(mid):
			continue
		var snap: Dictionary = f.known_member_states.get(mid, {})
		var food: float = float(snap.get("food", 0.0))
		if food > best_food:
			best_food = food
			best_tid  = mid
	return best_tid
```

- [ ] **Step 3: `_assign_member_tasks` 過濾改讀快照**

找到：
```gdscript
		if mt == null or mt.combat_target != -1 or mt.current_task != "idle":
			continue
```
替換為：
```gdscript
		var snap: Dictionary = f.known_member_states.get(mid, {})
		var known_task: String = snap.get("current_task", "idle")
		if mt == null or mt.combat_target != -1 or known_task != "idle":
			continue
```

- [ ] **Step 4: `_declare_established` 加初始快照**

找到：
```gdscript
	f.goals.erase("立國")
	SimMessageSystem.new().emit_message(state, "faction_establish",
```
替換為：
```gdscript
	f.goals.erase("立國")
	for mid in f.member_team_ids:
		state.snapshot_faction_member(mid, state.world.current_tick)
	SimMessageSystem.new().emit_message(state, "faction_establish",
```

- [ ] **Step 5: 重建快取**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --import
```

預期：無 SCRIPT ERROR。

- [ ] **Step 6: Commit**

```powershell
git add scripts/simulation/faction_ai_system.gd
git commit -m "feat(sim): FactionAI reads known_member_states snapshot"
```

---

## Task C：Interaction System 初始快照

**Files:**
- Modify: `scripts/simulation/interaction_system.gd`

- [ ] **Step 1: `_try_subjugate` 末段加快照**

找到（_try_subjugate 末行）：
```gdscript
	print("[Faction] Team%d 主服 Team%d → 勢力%d" % [winner_id, loser_id, fid])
```
替換為：
```gdscript
	state.snapshot_faction_member(loser_id, state.world.current_tick)
	print("[Faction] Team%d 主服 Team%d → 勢力%d" % [winner_id, loser_id, fid])
```

- [ ] **Step 2: `_try_diplomacy` 末段加快照**

找到（_try_diplomacy 末行）：
```gdscript
	print("[Faction] Team%d 外交 Team%d → 勢力%d" % [initiator_id, target_id, fid])
```
替換為：
```gdscript
	state.snapshot_faction_member(target_id, state.world.current_tick)
	print("[Faction] Team%d 外交 Team%d → 勢力%d" % [initiator_id, target_id, fid])
```

- [ ] **Step 3: 重建快取**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --import
```

預期：無 SCRIPT ERROR。

- [ ] **Step 4: Commit**

```powershell
git add scripts/simulation/interaction_system.gd
git commit -m "feat(sim): snapshot faction member on subjugate/diplomacy join"
```

---

## Task D：headless_test 驗證

**Files:**
- Modify: `scripts/debug/headless_test.gd`

在 population management 清理段後（`state.factions.erase(fac99)` 之後）、`print("=== Sim Test: 200 Ticks ===")` 之前插入：

- [ ] **Step 1: 插入驗證場景**

找到：
```gdscript
	state.factions.erase(fac99)

	print("=== Sim Test: 200 Ticks ===")
```
替換為：
```gdscript
	state.factions.erase(fac99)

	# ── FactionKnownState 驗證 ──
	var ks_fac := state.create_faction(30)
	state.factions[ks_fac].leader_team_id = 30
	var ks_a := TeamData.new()
	ks_a.team_id = 30; ks_a.population = 10; ks_a.tile_pos = Vector2i(0, -9)
	ks_a.resources["food"] = 80.0; ks_a.faction_id = ks_fac
	state.teams[30] = ks_a; state.team_known[30] = []; state.team_discovered[30] = []
	var ks_a_l := PersonData.new()
	ks_a_l.id = 60; ks_a_l.person_name = "KS_leader"; ks_a_l.role = "leader"
	ks_a_l.team_id = 30; ks_a_l.skills["統領"] = 0.6
	state.persons[60] = ks_a_l; ks_a.leader_id = 60

	var ks_b := TeamData.new()
	ks_b.team_id = 31; ks_b.population = 5; ks_b.tile_pos = Vector2i(1, -9)
	ks_b.resources["food"] = 50.0; ks_b.faction_id = ks_fac
	state.teams[31] = ks_b; state.team_known[31] = []; state.team_discovered[31] = []
	var ks_b_l := PersonData.new()
	ks_b_l.id = 61; ks_b_l.person_name = "KS_mem1"; ks_b_l.role = "leader"
	ks_b_l.team_id = 31
	state.persons[61] = ks_b_l; ks_b.leader_id = 61
	state.factions[ks_fac].member_team_ids.append(31)

	var ks_c := TeamData.new()
	ks_c.team_id = 32; ks_c.population = 3; ks_c.tile_pos = Vector2i(2, -9)
	ks_c.resources["food"] = 30.0; ks_c.faction_id = ks_fac
	state.teams[32] = ks_c; state.team_known[32] = []; state.team_discovered[32] = []
	var ks_c_l := PersonData.new()
	ks_c_l.id = 62; ks_c_l.person_name = "KS_mem2"; ks_c_l.role = "leader"
	ks_c_l.team_id = 32
	state.persons[62] = ks_c_l; ks_c.leader_id = 62
	state.factions[ks_fac].member_team_ids.append(32)

	var _ks_fai: Object = load("res://scripts/simulation/faction_ai_system.gd").new()
	_ks_fai.evaluate_all(state, [30, 31, 32])
	print("=== FactionKnownState 驗證 ===")

	# 場景1：快照正確建立
	var _snap_b: Dictionary = state.factions[ks_fac].known_member_states.get(31, {})
	if _snap_b.get("food", -1.0) == 50.0:
		print("  [OK] known_member_states[31].food=50.0")
	else:
		print("  [FAIL] known_member_states[31].food=%s" % str(_snap_b.get("food", "missing")))

	# 場景2：_richest_member 讀快照（Team31 food=50 > Team32 food=30）
	var _rm: int = _ks_fai._richest_member(state, state.factions[ks_fac])
	if _rm == 31:
		print("  [OK] _richest_member 返回 Team31（快照 food=50）")
	else:
		print("  [FAIL] _richest_member 返回 %d（預期 31）" % _rm)

	# 場景3：直接改 Team31 food 但不刷新快照 → _richest_member 仍讀舊值
	ks_b.resources["food"] = 5.0  # 繞過快照直接改
	var _rm2: int = _ks_fai._richest_member(state, state.factions[ks_fac])
	if _rm2 == 31:
		print("  [OK] 快照未更新 → _richest_member 仍返回 Team31（介面隔離正確）")
	else:
		print("  [FAIL] _richest_member 返回 %d（預期 31，快照應仍為 food=50）" % _rm2)

	# 清理
	for _tid2 in [30, 31, 32]:
		state.teams.erase(_tid2)
		state.team_known.erase(_tid2)
		state.team_discovered.erase(_tid2)
	for _pid2 in [60, 61, 62]:
		state.persons.erase(_pid2)
	state.factions.erase(ks_fac)

	print("=== Sim Test: 200 Ticks ===")
```

- [ ] **Step 2: 跑 headless**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

預期輸出（含以下片段）：
```
=== FactionKnownState 驗證 ===
  [OK] known_member_states[31].food=50.0
  [OK] _richest_member 返回 Team31（快照 food=50）
  [OK] 快照未更新 → _richest_member 仍返回 Team31（介面隔離正確）
=== Sim Test: 200 Ticks ===
...
=== DONE ===
```

無 SCRIPT ERROR，原有輸出（PersonGenerator/merge_teams/PopMgmt/200Tick）仍正常。

- [ ] **Step 3: Commit**

```powershell
git add scripts/debug/headless_test.gd
git commit -m "test: add FactionKnownState snapshot interface validation"
```

---

## Task E：文件更新

**Files:**
- Modify: `docs/progress.md`

- [ ] **Step 1: 加入模擬系統層表格**

找到模擬系統層表格末行：
```
| `population_system.gd` | 超額強制分裂：每 10 tick 掃全域；有 advisor → dispatch 子隊；無 advisor → 獨立流亡 team + PersonGenerator 晉升 |
```
後方加：
```
| `faction_ai_system.gd`（快照層） | `known_member_states` 介面：FactionAI 讀成員快照（food/weapons/goods/population/tile_pos/current_task）；stub 每輪刷新，預留 IntelSystem 限制接口 |
```

- [ ] **Step 2: Commit**

```powershell
git add docs/progress.md
git commit -m "docs: add faction known state to progress"
```

---

## 驗證 Checklist

```
[ ] headless 無 SCRIPT ERROR
[ ] === DONE === 出現
[ ] known_member_states[31].food=50.0 [OK]
[ ] _richest_member 返回 Team31 [OK]
[ ] 快照隔離：繞過更新後 _richest_member 仍讀舊值 [OK]
[ ] 原有 200 Tick 輸出正常（FactionAI 立國/外交/徵收仍運作）
```

---

## ⚠️ 設計備忘

| 事項 | 說明 |
|---|---|
| Stub 刷新 | `evaluate_all` 開頭每輪刷新，未來 IntelSystem 完成後移除 |
| 快照缺失 | `known_member_states.get(mid, {})` → 空 dict → food=0.0/task="idle"（可指派） |
| `combat_target` 仍即時讀 | 安全閘：不打斷進行中戰鬥 |
| IntelSystem 預留 | `snapshot_faction_member` 為唯一更新入口，未來只需限制呼叫時機 |
