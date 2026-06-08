# NPC 基建系統 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** NPC AI 主動蓋 / 升級 outpost / 擴建設施。data-driven FACILITY_DEF + 派子隊執行 + 副官建言（玩家 leader）+ 蓋完自動安頓。

**Architecture:**
- `outpost_system` 加 `FACILITY_DEF` const + `_on_construction_complete` callback
- `TeamData` 加 `task_extra_data: Dictionary`
- `faction_ai_system` 加 `_evaluate_infrastructure` entry + 3 個 dispatch helper + 評分 helper
- `interaction_system` 子隊抵達觸發 start_build / upgrade（依 task）
- `player_command_system` 加 `upgrade_outpost`、`build_facility` actions

**Spec:** `docs/superpowers/specs/2026-06-09-npc-infrastructure-design.md`

---

## 檔案結構

| 檔案 | 變更 |
|---|---|
| `scripts/data/team_data.gd` | 加 `task_extra_data: Dictionary = {}` |
| `scripts/simulation/outpost_system.gd` | 加 `FACILITY_DEF` const + completion callback |
| `scripts/simulation/faction_ai_system.gd` | 加 `_evaluate_infrastructure` + 3 個 dispatch + 評分 helpers |
| `scripts/simulation/interaction_system.gd` | 子隊抵達 task=建造/升級/擴建 觸發 |
| `scripts/simulation/subteam_system.gd` | `dispatch` 加 extra_data 參數 |
| `scripts/simulation/player_command_system.gd` | 加 `upgrade_outpost` + `build_facility` |
| `scripts/debug/headless_test.gd` | 12 個測試 |

## 測試命令

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/game_sim_test.gd
```

---

## Task 1: TeamData.task_extra_data 欄位

**Files:**
- Modify: `scripts/data/team_data.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 加失敗測試**

```gdscript
func _test_task_extra_data_field() -> void:
	print("--- Infra Task1: task_extra_data ---")
	var t := TeamData.new()
	assert(t.task_extra_data == {}, "預設為空 dict")
	t.task_extra_data = { "build_type": "civilian", "level": 1 }
	assert(t.task_extra_data["build_type"] == "civilian")
	print("Infra Task1 OK")
```

於 `_initialize()` 加 `_test_task_extra_data_field()`。

- [ ] **Step 2: 加欄位**

`scripts/data/team_data.gd` 找 `var task_extra_data` 一塊區（或 `var current_task` 附近）加：

```gdscript
var task_extra_data: Dictionary = {}   # 子隊任務附加數據（build_type/level/facility_type 等）
```

- [ ] **Step 3: 跑測試 + Commit**

```powershell
git add scripts/data/team_data.gd scripts/debug/headless_test.gd
git commit -m "feat(team): add task_extra_data field (Task 1)"
```

---

## Task 2: FACILITY_DEF + _check 函數

**Files:**
- Modify: `scripts/simulation/outpost_system.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 加失敗測試**

```gdscript
func _test_facility_def_registry() -> void:
	print("--- Infra Task2: FACILITY_DEF ---")
	assert(OutpostSystem.FACILITY_DEF.has("farming"))
	assert(OutpostSystem.FACILITY_DEF.has("manufacturing"))
	var farming = OutpostSystem.FACILITY_DEF["farming"]
	assert(farming.cost.material == 30)
	assert(farming.cap_by_outpost.civilian == [1, 2, 3])
	print("Infra Task2 OK")
```

- [ ] **Step 2: 加 const**

`outpost_system.gd` 開頭加：

```gdscript
const FACILITY_DEF: Dictionary = {
	"farming": {
		"cost":             { "material": 30, "coin": 0, "ticks": 50 },
		"cap_by_outpost":   { "civilian": [1, 2, 3], "military": [0, 0, 0] },
		"category":         "生產",
		"trigger_check":    "_check_food_shortage",
		"leader_pref":      { "慎重": 0.3, "野心": -0.1 },
		"current_level_key": "farming_level",
	},
	"manufacturing": {
		"cost":             { "material": 60, "coin": 20, "ticks": 100 },
		"cap_by_outpost":   { "civilian": [0, 1, 3], "military": [0, 0, 0] },
		"category":         "經濟",
		"trigger_check":    "_check_goods_shortage",
		"leader_pref":      { "野心": 0.2, "貪婪": 0.3 },
		"current_level_key": "manufacturing_level",
	},
}
```

- [ ] **Step 3: 加 trigger_check 函數於 faction_ai_system**

```gdscript
func _check_food_shortage(state: WorldState, faction: FactionData) -> float:
	var total_food: float = 0.0
	var total_pop: int = 0
	for tid in faction.member_team_ids:
		var t = state.teams.get(tid)
		if t == null: continue
		total_food += float(t.resources.get("food", 0))
		total_pop += t.population
	var per_capita: float = total_food / maxf(total_pop, 1)
	# 缺糧（< 5 天份）→ 高 priority
	return clampf((10.0 - per_capita) / 10.0, 0.0, 1.0) * 100.0

func _check_goods_shortage(state: WorldState, faction: FactionData) -> float:
	var total_goods: float = 0.0
	for tid in faction.member_team_ids:
		var t = state.teams.get(tid)
		if t == null: continue
		total_goods += float(t.resources.get("goods", 0))
	# goods < 50 → 觸發
	return clampf((100.0 - total_goods) / 100.0, 0.0, 1.0) * 50.0
```

- [ ] **Step 4: 跑測試 + Commit**

```powershell
git add scripts/simulation/outpost_system.gd scripts/simulation/faction_ai_system.gd scripts/debug/headless_test.gd
git commit -m "feat(outpost): FACILITY_DEF registry + check helpers (Task 2)"
```

---

## Task 3: `_pick_advisor` + `_dispatch_builder`

**Files:**
- Modify: `scripts/simulation/faction_ai_system.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 加失敗測試**

```gdscript
func _test_dispatch_builder() -> void:
	print("--- Infra Task3: _dispatch_builder ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	var owner := TeamData.new()
	owner.team_id = 0; owner.population = 30; owner.faction_id = 10
	owner.tile_pos = Vector2i(0, 0)
	owner.resources["material"] = 200.0; owner.resources["coin"] = 50.0
	var leader := PersonData.new(); leader.id = 100; leader.team_id = 0
	state.persons[100] = leader; owner.leader_id = 100
	var adv := PersonData.new(); adv.id = 101; adv.team_id = 0
	adv.skills["統領"] = 0.4
	state.persons[101] = adv; owner.named_members = [101]
	state.teams[0] = owner
	state.create_faction(0)
	var fai := FactionAISystem.new()
	var result = fai._dispatch_builder(state, owner, Vector2i(3, 3), "civilian", 1)
	assert(result, "資源足應派子隊")
	# 應有新子隊
	var sub_count = 0
	for tid in state.teams:
		if state.teams[tid].parent_team_id == 0 and state.teams[tid].current_task == "建造":
			sub_count += 1
	assert(sub_count == 1, "應派出 1 個子隊 task=建造")
	print("Infra Task3 OK")
```

- [ ] **Step 2: 加函數**

```gdscript
func _pick_advisor(team: TeamData) -> int:
	for pid in team.named_members:
		if pid != team.leader_id: return pid
	return -1

func _dispatch_builder(state: WorldState, leader_team: TeamData, target_pos: Vector2i,
		outpost_type: String, level: int) -> bool:
	var cost: Dictionary = OutpostSystem.BUILD_COST[outpost_type][level - 1]
	# 1.5x 安全餘量
	for k in cost:
		if float(leader_team.resources.get(k, 0)) < float(cost[k]) * 1.5:
			return false
	var advisor_id: int = _pick_advisor(leader_team)
	if advisor_id == -1: return false
	var pop: int = maxi(10, level * 5)
	if leader_team.population < pop * 2: return false
	# Dispatch 子隊（加 task_extra_data）
	var sub_id: int = SubteamSystem.new().dispatch(
		state, leader_team.team_id, advisor_id, pop, "建造", target_pos)
	if sub_id == -1: return false
	state.teams[sub_id].task_extra_data = {
		"build_type": outpost_type, "level": level
	}
	return true
```

- [ ] **Step 3: 跑測試 + Commit**

```powershell
git add scripts/simulation/faction_ai_system.gd scripts/debug/headless_test.gd
git commit -m "feat(faction_ai): _dispatch_builder + _pick_advisor (Task 3)"
```

---

## Task 4: `_evaluate_new_outpost_location` 評分

**Files:**
- Modify: `scripts/simulation/faction_ai_system.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 測試**

```gdscript
func _test_evaluate_outpost_location() -> void:
	print("--- Infra Task4: outpost location scoring ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	var leader_team := TeamData.new()
	leader_team.team_id = 0; leader_team.tile_pos = Vector2i(0, 0)
	state.teams[0] = leader_team
	# 設幾個 candidate tile
	for x in range(-3, 4):
		for y in range(-3, 4):
			var tile := HexTileData.new()
			tile.tile_pos = Vector2i(x, y)
			tile.terrain = "plains"
			tile.productivity = 1.0 if abs(x) + abs(y) > 2 else 0.5
			tile.outpost_level = 0
			state.world.tiles[x * 1000 + y] = tile
	var fai := FactionAISystem.new()
	var best = fai._evaluate_new_outpost_location(state, leader_team)
	assert(best != null, "應找到 candidate")
	print("Infra Task4 OK (best=%s)" % str(best))
```

- [ ] **Step 2: 加函數**

```gdscript
const MIN_BUILD_SCORE: float = 50.0

const TERRAIN_BUILD_BONUS: Dictionary = {
	"plains": 20.0, "forest": 10.0, "mountain": -10.0,
}

func _evaluate_new_outpost_location(state: WorldState, leader_team: TeamData) -> Dictionary:
	var candidates: Array = []
	var center: Vector2i = leader_team.tile_pos
	# 搜 5 hex 內
	for tile_id in state.world.tiles:
		var tile: HexTileData = state.world.tiles[tile_id]
		if tile.outpost_level > 0: continue
		var dist: int = _hex_dist(center, tile.tile_pos)
		if dist > 5 or dist < 2: continue   # 太近不行
		var score: float = float(tile.productivity) * 100.0
		score += float(TERRAIN_BUILD_BONUS.get(tile.terrain, 0))
		score -= float(dist) * 5.0
		score += clampf(10.0 - float(dist), 0.0, 10.0) * 2.0
		# 太近敵方 outpost
		var min_enemy_dist: int = _min_dist_to_enemy_outpost(state, leader_team, tile.tile_pos)
		if min_enemy_dist < 5: score -= float(5 - min_enemy_dist) * 10.0
		if score >= MIN_BUILD_SCORE:
			candidates.append({ "pos": tile.tile_pos, "score": score, "tile": tile })
	if candidates.is_empty(): return {}
	candidates.sort_custom(func(a, b): return a.score > b.score)
	return candidates[0]

func _min_dist_to_enemy_outpost(state: WorldState, leader_team: TeamData, pos: Vector2i) -> int:
	var min_dist: int = 9999
	for tile_id in state.world.tiles:
		var tile: HexTileData = state.world.tiles[tile_id]
		if tile.outpost_level == 0: continue
		var owner: TeamData = state.teams.get(tile.outpost_owner)
		if owner == null: continue
		if owner.faction_id == leader_team.faction_id and owner.faction_id != -1: continue
		var d: int = _hex_dist(pos, tile.tile_pos)
		if d < min_dist: min_dist = d
	return min_dist
```

- [ ] **Step 3: 跑測試 + Commit**

```powershell
git add scripts/simulation/faction_ai_system.gd scripts/debug/headless_test.gd
git commit -m "feat(faction_ai): _evaluate_new_outpost_location scoring (Task 4)"
```

---

## Task 5: `_evaluate_infrastructure` 主決策 + outpost type 選擇

**Files:**
- Modify: `scripts/simulation/faction_ai_system.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 測試**

```gdscript
func _test_evaluate_infrastructure() -> void:
	print("--- Infra Task5: _evaluate_infrastructure ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	# faction with leader team + resources
	var leader_team := TeamData.new()
	leader_team.team_id = 0; leader_team.population = 30; leader_team.tile_pos = Vector2i(0, 0)
	leader_team.faction_id = 10
	leader_team.resources["material"] = 500.0; leader_team.resources["coin"] = 100.0
	var leader := PersonData.new(); leader.id = 100
	leader.values = { "野心": 0.3, "慎重": 0.7, "好戰": 0.2, "貪婪": 0.4 }
	state.persons[100] = leader; leader_team.leader_id = 100
	var adv := PersonData.new(); adv.id = 101
	state.persons[101] = adv; leader_team.named_members = [101]
	state.teams[0] = leader_team
	var fid = state.create_faction(0)
	var f = state.factions[fid]
	# 加 plains tile 鄰近
	for x in range(-3, 4):
		for y in range(-3, 4):
			var tile := HexTileData.new()
			tile.tile_pos = Vector2i(x, y); tile.terrain = "plains"
			tile.productivity = 1.0; tile.outpost_level = 0
			state.world.tiles[x * 1000 + y] = tile
	state.world.tiles[0].outpost_level = 1   # 自家 outpost 在 (0,0)
	state.world.tiles[0].outpost_type = "civilian"
	state.world.tiles[0].outpost_owner = 0
	var fai := FactionAISystem.new()
	fai._evaluate_infrastructure(state, f)
	# 應派子隊或選擇任務
	var sub_count = 0
	for tid in state.teams:
		if state.teams[tid].parent_team_id == 0:
			sub_count += 1
	print("Infra Task5 OK (派出 %d 子隊)" % sub_count)
```

- [ ] **Step 2: 加函數**

```gdscript
func _pick_outpost_type(leader: PersonData) -> String:
	var military: float = float(leader.values.get("好戰", 0.5)) + float(leader.values.get("野心", 0.5))
	var civilian: float = float(leader.values.get("慎重", 0.5)) + float(leader.values.get("貪婪", 0.5))
	return "military" if military > civilian else "civilian"

func _evaluate_infrastructure(state: WorldState, faction: FactionData) -> void:
	var leader_team: TeamData = state.teams.get(faction.leader_team_id)
	if leader_team == null: return
	var leader: PersonData = state.persons.get(leader_team.leader_id)
	if leader == null: return
	# 玩家 leader → 副官 path（簡化版：暫不做副官，僅 print 建議）
	if leader_team.leader_id == state.player_id and state.player_id != -1:
		# TODO: 後續用 AdvisorSystem.push_outpost_advice
		return
	# (1) 蓋新 outpost
	var loc = _evaluate_new_outpost_location(state, leader_team)
	if loc.is_empty(): return
	var outpost_type: String = _pick_outpost_type(leader)
	_dispatch_builder(state, leader_team, loc.pos, outpost_type, 1)
```

整合到 `evaluate_all` faction loop（在現有 strategic_ai tick 後或 faction_ai 迭代內）：

```gdscript
# faction_ai evaluate_all 加（已有 faction 迭代邏輯）
for fid in state.factions:
    var f: FactionData = state.factions[fid]
    if state.world.current_tick % STRATEGIC_INTERVAL == 0:
        _evaluate_infrastructure(state, f)
```

- [ ] **Step 3: 跑測試 + Commit**

```powershell
git add scripts/simulation/faction_ai_system.gd scripts/debug/headless_test.gd
git commit -m "feat(faction_ai): _evaluate_infrastructure entry + integrate (Task 5)"
```

---

## Task 6: 子隊抵達觸發 start_build / upgrade

**Files:**
- Modify: `scripts/simulation/interaction_system.gd` 或 `subteam_system.gd`
- Modify: `scripts/simulation/outpost_system.gd`（可能需要 `start_build(team, type, level)` 簽名確認）

- [ ] **Step 1: 找子隊抵達 callback 位置**

```bash
grep -n "current_task" scripts/simulation/movement_system.gd | head -5
grep -n "arrival\|on_arrive\|抵達" scripts/simulation/ -r --include="*.gd" | head
```

如果 movement_system 有 `on_arrival` callback 或在 `process` 內 check `move_target == tile_pos` 觸發。

- [ ] **Step 2: 加 task arrival handler**

於 `movement_system.process` 或 `interaction_system` 適當位置：

```gdscript
# 子隊抵達 target → 依 task 觸發
func _on_subteam_arrive(state, team):
    var extra = team.task_extra_data
    match team.current_task:
        "建造":
            var t = extra.get("build_type", "civilian")
            var lv = int(extra.get("level", 1))
            OutpostSystem.new().start_build(team, t, lv)
        "升級":
            var lv = int(extra.get("target_level", 2))
            var tile = state.world.tiles.get(team.tile_pos.x * 1000 + team.tile_pos.y)
            if tile and tile.outpost_owner == team.team_id:
                OutpostSystem.new().start_build(team, tile.outpost_type, lv)
        "擴建":
            var facility = extra.get("facility_type", "farming")
            OutpostSystem.new().upgrade(team, facility)
```

- [ ] **Step 3: 測試 + Commit**

```gdscript
func _test_subteam_arrival_triggers_build() -> void:
	print("--- Infra Task6: 子隊抵達觸發 ---")
	# 建子隊 + task=建造 + 抵達 → tile.construction_target 應寫入
	# ...
	print("Infra Task6 OK")
```

```powershell
git add scripts/simulation/movement_system.gd scripts/debug/headless_test.gd
git commit -m "feat(arrival): subteam task=建造/升級/擴建 triggers outpost_system (Task 6)"
```

---

## Task 7: NPC 升級 / 擴建 dispatch

**Files:**
- Modify: `scripts/simulation/faction_ai_system.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 測試**

```gdscript
func _test_dispatch_upgrader_and_facility() -> void:
	print("--- Infra Task7: 升級/擴建 dispatch ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	var leader_team := TeamData.new()
	leader_team.team_id = 0; leader_team.population = 30
	leader_team.resources["material"] = 500.0; leader_team.resources["coin"] = 100.0
	var leader := PersonData.new(); leader.id = 100; state.persons[100] = leader
	leader_team.leader_id = 100
	var adv := PersonData.new(); adv.id = 101; state.persons[101] = adv
	leader_team.named_members = [101]
	state.teams[0] = leader_team
	var tile := HexTileData.new()
	tile.tile_pos = Vector2i(3, 3); tile.outpost_level = 1
	tile.outpost_type = "civilian"; tile.outpost_owner = 0
	tile.farming_level = 0
	state.world.tiles[3003] = tile
	var fai := FactionAISystem.new()
	var r = fai._dispatch_upgrader(state, leader_team, Vector2i(3, 3), 2)
	assert(r, "升級派子隊應成功")
	# 重置然後試擴建
	# ...
	print("Infra Task7 OK")
```

- [ ] **Step 2: 加函數**

```gdscript
func _dispatch_upgrader(state, owner_team, outpost_pos, target_level) -> bool:
	var tile = state.world.tiles.get(outpost_pos.x * 1000 + outpost_pos.y)
	if tile == null or tile.outpost_owner != owner_team.team_id: return false
	if target_level <= tile.outpost_level: return false
	if target_level > 3: return false
	var cost = OutpostSystem.BUILD_COST[tile.outpost_type][target_level - 1]
	for k in cost:
		if float(owner_team.resources.get(k, 0)) < float(cost[k]) * 1.5: return false
	var advisor_id = _pick_advisor(owner_team)
	if advisor_id == -1: return false
	if owner_team.population < 10: return false
	var sub_id = SubteamSystem.new().dispatch(
		state, owner_team.team_id, advisor_id, 5, "升級", outpost_pos)
	if sub_id == -1: return false
	state.teams[sub_id].task_extra_data = { "target_level": target_level }
	return true

func _dispatch_facility_builder(state, owner_team, outpost_pos, facility_type) -> bool:
	var def = OutpostSystem.FACILITY_DEF[facility_type]
	var cost = def.cost
	for k in cost:
		if k == "ticks": continue
		if float(owner_team.resources.get(k, 0)) < float(cost[k]) * 1.5: return false
	var advisor_id = _pick_advisor(owner_team)
	if advisor_id == -1: return false
	if owner_team.population < 6: return false
	var sub_id = SubteamSystem.new().dispatch(
		state, owner_team.team_id, advisor_id, 3, "擴建", outpost_pos)
	if sub_id == -1: return false
	state.teams[sub_id].task_extra_data = { "facility_type": facility_type }
	return true
```

擴充 `_evaluate_infrastructure` 加 (1) 升級評估、(2) 擴建評估：

```gdscript
func _evaluate_infrastructure(state, faction):
    var leader_team = state.teams.get(faction.leader_team_id)
    if leader_team == null: return
    var leader = state.persons.get(leader_team.leader_id)
    if leader == null: return
    if leader_team.leader_id == state.player_id and state.player_id != -1:
        return
    # (1) 升級
    for tile_id in state.world.tiles:
        var tile = state.world.tiles[tile_id]
        if tile.outpost_owner != leader_team.team_id: continue
        if tile.outpost_level >= 3: continue
        if _dispatch_upgrader(state, leader_team, tile.tile_pos, tile.outpost_level + 1):
            return
    # (2) 擴建
    for tile_id in state.world.tiles:
        var tile = state.world.tiles[tile_id]
        if tile.outpost_owner != leader_team.team_id: continue
        if tile.outpost_type != "civilian": continue
        for facility in OutpostSystem.FACILITY_DEF:
            var def = OutpostSystem.FACILITY_DEF[facility]
            var cap_arr = def.cap_by_outpost[tile.outpost_type]
            var cap = int(cap_arr[tile.outpost_level - 1])
            var current = int(tile.get(def.current_level_key)) if tile.get(def.current_level_key) != null else 0
            if current >= cap: continue
            # 簡化：先嘗試派
            if _dispatch_facility_builder(state, leader_team, tile.tile_pos, facility):
                return
    # (3) 蓋新
    var loc = _evaluate_new_outpost_location(state, leader_team)
    if loc.is_empty(): return
    var outpost_type = _pick_outpost_type(leader)
    _dispatch_builder(state, leader_team, loc.pos, outpost_type, 1)
```

- [ ] **Step 3: 測試 + Commit**

```powershell
git add scripts/simulation/faction_ai_system.gd scripts/debug/headless_test.gd
git commit -m "feat(faction_ai): _dispatch_upgrader + _dispatch_facility_builder (Task 7)"
```

---

## Task 8: 蓋完 outpost 自動安頓（連動 E）

**Files:**
- Modify: `scripts/simulation/outpost_system.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 找 outpost completion 位置**

Grep for 完工 / construction complete in outpost_system.gd.

- [ ] **Step 2: 加 callback**

於 `outpost_system` 完工 trigger 處（依既有實作可能在 `tick_all` 內 check `construction_progress >= ticks`）加：

```gdscript
# 完工
tile.outpost_owner = team.team_id
print("[Outpost] 完工 (%d,%d) owner=Team%d" % [...])
# NPC：自動派人安頓
if team.parent_team_id != -1:
    var parent = state.teams.get(team.parent_team_id)
    if parent and parent.leader_id != state.player_id:
        _auto_dispatch_settler(state, parent, tile.tile_pos, tile.outpost_type)

func _auto_dispatch_settler(state, parent, pos, outpost_type):
    var advisor_id = _pick_advisor(parent)
    if advisor_id == -1: return
    var pop = 10 if outpost_type == "civilian" else 5
    if parent.population < pop * 2: return
    SubteamSystem.new().dispatch(state, parent.team_id, advisor_id, pop, "安頓", pos)
```

- [ ] **Step 3: 測試 + Commit**

```gdscript
func _test_auto_settle_after_build() -> void:
	# 蓋完 outpost → parent 派 anothe 子隊 task=安頓
	# ...
```

```powershell
git add scripts/simulation/outpost_system.gd scripts/debug/headless_test.gd
git commit -m "feat(outpost): auto-dispatch settler subteam on completion (Task 8)"
```

---

## Task 9: 起義 cancel construction

**Files:**
- Modify: `scripts/simulation/faction_ai_system.gd`（_evaluate_uprising）

- [ ] **Step 1: 修 `_evaluate_uprising`**

於既有 A/B 二路徑前加：

```gdscript
# 起義 → cancel 建造（無論 A/B 路徑）
var tile_at = state.world.tiles.get(team.tile_pos.x * 1000 + team.tile_pos.y)
if tile_at and not tile_at.construction_target.is_empty():
    tile_at.construction_target = {}
    tile_at.construction_progress = 0
    print("[Uprising] cancel construction at (%d,%d)" % [team.tile_pos.x, team.tile_pos.y])
```

- [ ] **Step 2: Commit**

```powershell
git add scripts/simulation/faction_ai_system.gd
git commit -m "feat(uprising): cancel construction on uprising (Task 9)"
```

---

## Task 10: 玩家 upgrade_outpost action

**Files:**
- Modify: `scripts/simulation/player_command_system.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 測試 + 加 action**

```gdscript
"upgrade_outpost": _action_upgrade_outpost,

func _action_upgrade_outpost(state, _target, pt, pt_id):
    var pos = pt.tile_pos
    var tile = state.world.tiles.get(pos.x * 1000 + pos.y)
    if tile == null or tile.outpost_level == 0:
        return { "ok": false, "msg": "目標無 outpost" }
    if tile.outpost_owner != pt_id:
        return { "ok": false, "msg": "非自家 outpost" }
    if tile.outpost_level >= 3:
        return { "ok": false, "msg": "已滿級" }
    var r = OutpostSystem.new().start_build(pt, tile.outpost_type, tile.outpost_level + 1)
    return r
```

```gdscript
func _test_player_upgrade_outpost() -> void:
	# 玩家在自家 L1 outpost + 資源 → 升 L2
```

- [ ] **Step 2: Commit**

```powershell
git add scripts/simulation/player_command_system.gd scripts/debug/headless_test.gd
git commit -m "feat(player_cmd): upgrade_outpost action (Task 10)"
```

---

## Task 11: 玩家 build_facility action

**Files:**
- Modify: `scripts/simulation/player_command_system.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 測試 + 加 action**

```gdscript
"build_facility": _action_build_facility,

func _action_build_facility(state, _target, pt, pt_id):
    var facility = state.player_state.get("facility_type", "farming")
    if not OutpostSystem.FACILITY_DEF.has(facility):
        return { "ok": false, "msg": "未知 facility" }
    var pos = pt.tile_pos
    var tile = state.world.tiles.get(pos.x * 1000 + pos.y)
    if tile == null or tile.outpost_owner != pt_id:
        return { "ok": false, "msg": "非自家 outpost" }
    var r = OutpostSystem.new().upgrade(pt, facility)
    return r
```

- [ ] **Step 2: Commit**

```powershell
git add scripts/simulation/player_command_system.gd scripts/debug/headless_test.gd
git commit -m "feat(player_cmd): build_facility action (Task 11)"
```

---

## Task 12: 整合驗證 + handback

**Files:**
- Create: `docs/superpowers/handbacks/2026-06-09-npc-infrastructure.md`

- [ ] **Step 1: 跑全 test**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/game_sim_test.gd > godot_test.log 2>&1
Get-Content godot_test.log -Encoding UTF8 | Select-String "Infra|建造|升級|擴建|outpost.*completed|安頓" | Select-Object -First 30
```

預期：ALL INVARIANTS PASSED + NPC infra log（NPC 主動蓋/升級）

- [ ] **Step 2: 寫 handback**

```markdown
# Hand Back: NPC Infrastructure (C)

## 實作摘要

- TeamData：加 task_extra_data: Dictionary
- outpost_system：FACILITY_DEF 註冊表、auto_dispatch_settler 完工 callback
- faction_ai_system：_evaluate_infrastructure 主決策、3 dispatch helpers、location scoring
- movement_system / interaction_system：子隊抵達依 task 觸發 start_build / upgrade
- player_command_system：upgrade_outpost、build_facility actions
- 起義 cancel construction（連動 D）

## 連動風險

- 副官建言路徑簡化（TODO 後續實作 AdvisorSystem.push_outpost_advice）
- 蓋完 outpost callback 需確認 outpost_system 完工點是否暴露 hook
- AI 評估 location 在小地圖（radius=4）可能無 candidate → 預期跳過不蓋
- 獨立 team 蓋 outpost 暫未實作（spec 提及但 task 沒展開）

## 待主 session 確認

- 副官 push_outpost_advice spec
- 新設施類型擴充包 spec（城牆、市集等）
- 獨立 team 主動蓋 outpost 邏輯（資源門檻 + 行為條件）
```

- [ ] **Step 3: Commit**

```powershell
git add docs/superpowers/handbacks/2026-06-09-npc-infrastructure.md
git commit -m "docs: NPC infrastructure handback (Task 12)"
```
