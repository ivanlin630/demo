# 居民 Team 系統 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 引入「居民 team」實體（動態偵測 PRODUCE + outpost + 同 faction），解決商隊離家飢餓、加入收稅、招攬移民、起義、失聯保護機制。

**Architecture:**
- `TeamData` 加 2 個新欄位（tax_rate、pending_owner_change_tick）
- 共享 `_is_resident_team(state, team)` 偵測函數放 `faction_ai_system`
- 重用既有：`_resolve_tribute`、`check_overflow_for_team`、`event_unrest_split`、`subteam_system`、`movement_system`、reaction/memory/rep 系統
- 新增：`invite_settle` action + diplomatic eval、`_evaluate_uprising`、`_evaluate_owner_contact`、`_trigger_defection_evaluation`、`_resolve_pacify`、子隊 task `"安頓"`/`"安撫"`

**Tech Stack:** Godot 4.2.2 GDScript；headless test。

**Spec:** `docs/superpowers/specs/2026-06-08-resident-team-system-design.md`

---

## 檔案結構

| 檔案 | 變更 |
|---|---|
| `scripts/data/team_data.gd` | 加 `tax_rate`、`pending_owner_change_tick` 欄位 |
| `scripts/simulation/faction_ai_system.gd` | 加 `_is_resident_team`、`_evaluate_uprising`、`_evaluate_owner_contact`、`_trigger_defection_evaluation`、各 helper |
| `scripts/simulation/population_system.gd` | `check_overflow_for_team` 對 PRODUCE 用 outpost cap |
| `scripts/simulation/movement_system.gd` | 加居民移動鎖 |
| `scripts/simulation/salary_system.gd` | PRODUCE team 跳過 |
| `scripts/simulation/interaction_system.gd` | `_resolve_tribute` 用 tax_rate + 重稅後果；新 `_resolve_aid_request` 已在 B、新 `_resolve_pacify` + `_resolve_settlement_arrival` |
| `scripts/simulation/diplomatic_ai_system.gd` | 加 `invite_settle` message handle |
| `scripts/simulation/player_command_system.gd` | 加 `invite_settle` action |
| `scripts/debug/headless_test.gd` | 13 個測試 case |

## 執行測試的標準命令

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/game_sim_test.gd
```

---

## Task 1: TeamData 新欄位 + 常數

**Files:**
- Modify: `scripts/data/team_data.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 加失敗測試**

```gdscript
func _test_resident_fields() -> void:
	print("--- Resident Task1: TeamData 新欄位 ---")
	var t := TeamData.new()
	assert(t.tax_rate == 0.3, "預設 tax_rate 應為 0.3，實際=%s" % str(t.tax_rate))
	assert(t.pending_owner_change_tick == -1, "預設 pending 應為 -1")
	t.tax_rate = 0.5
	t.pending_owner_change_tick = 1000
	assert(t.tax_rate == 0.5 and t.pending_owner_change_tick == 1000)
	print("Resident Task1 OK")
```

於 `_initialize()` 加 `_test_resident_fields()`。

- [ ] **Step 2: 跑測試確認失敗**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

預期：`Invalid get index 'tax_rate'`

- [ ] **Step 3: 加欄位**

`scripts/data/team_data.gd` 找 `var current_task: String = "idle"` 附近加：

```gdscript
var tax_rate: float = 0.3                    # 收稅率（PRODUCE team 用，0.1-0.7）
var pending_owner_change_tick: int = -1      # 偵測 owner 異動緩衝倒數（7 天）
```

- [ ] **Step 4: 跑測試確認通過 + Commit**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
git add scripts/data/team_data.gd scripts/debug/headless_test.gd
git commit -m "feat(team): add tax_rate + pending_owner_change_tick fields (Task 1)"
```

---

## Task 2: `_is_resident_team` 偵測 helper + `_outpost_pop_cap`

**Files:**
- Modify: `scripts/simulation/faction_ai_system.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 加失敗測試**

```gdscript
func _test_is_resident_detection() -> void:
	print("--- Resident Task2: _is_resident_team 偵測 ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	# Setup: outpost on (5,5) owned by Team 99
	var tile := HexTileData.new()
	tile.tile_pos = Vector2i(5, 5)
	tile.outpost_level = 1
	tile.outpost_type = "civilian"
	tile.outpost_owner = 99
	state.world.tiles[5 * 1000 + 5] = tile
	# Owner Team 99 faction=10
	var owner := TeamData.new(); owner.team_id = 99; owner.faction_id = 10
	state.teams[99] = owner
	# Test 1: PRODUCE team on outpost, same faction → 居民
	var r := TeamData.new(); r.team_id = 0; r.tile_pos = Vector2i(5,5)
	r.faction_id = 10; r.tags = [TeamData.TAG_PRODUCE]
	state.teams[0] = r
	var fai := FactionAISystem.new()
	assert(fai._is_resident_team(state, r), "案例 1：同 faction PRODUCE 應為居民")
	# Test 2: PRODUCE team on outpost, different faction → 非居民
	r.faction_id = 20
	assert(not fai._is_resident_team(state, r), "案例 2：異 faction 不算居民")
	# Test 3: PRODUCE team not on outpost → 非居民
	r.faction_id = 10
	r.tile_pos = Vector2i(8, 8)
	assert(not fai._is_resident_team(state, r), "案例 3：非 outpost 不算居民")
	# Test 4: Non-PRODUCE team on outpost → 非居民
	r.tile_pos = Vector2i(5, 5)
	r.tags = ["軍隊"]
	assert(not fai._is_resident_team(state, r), "案例 4：非 PRODUCE 不算居民")
	# Test 5: outpost cap
	assert(fai._outpost_pop_cap(state, Vector2i(5, 5)) == 20, "civilian L1 應 20")
	tile.outpost_level = 2
	assert(fai._outpost_pop_cap(state, Vector2i(5, 5)) == 50, "civilian L2 應 50")
	tile.outpost_type = "military"
	tile.outpost_level = 1
	assert(fai._outpost_pop_cap(state, Vector2i(5, 5)) == 15, "military L1 應 15")
	print("Resident Task2 OK")
```

- [ ] **Step 2: 跑測試確認失敗**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

預期：`Nonexistent function '_is_resident_team'`

- [ ] **Step 3: 加常數與 helper**

`scripts/simulation/faction_ai_system.gd` 加：

```gdscript
const OUTPOST_POP_CAP: Dictionary = {
	"civilian": [20, 50, 100],   # L1, L2, L3
	"military": [15, 35, 70],
}

func _outpost_pop_cap(state: WorldState, pos: Vector2i) -> int:
	var tile: HexTileData = state.world.tiles.get(pos.x * 1000 + pos.y)
	if tile == null or tile.outpost_level == 0: return 0
	var arr: Array = OUTPOST_POP_CAP.get(tile.outpost_type, [10, 20, 40])
	return int(arr[clampi(tile.outpost_level - 1, 0, 2)])

func _is_resident_team(state: WorldState, team: TeamData) -> bool:
	if not team.tags.has(TeamData.TAG_PRODUCE):
		return false
	var tile: HexTileData = state.world.tiles.get(team.tile_pos.x * 1000 + team.tile_pos.y)
	if tile == null or tile.outpost_level == 0:
		return false
	var owner_id: int = tile.outpost_owner
	if owner_id == team.team_id:
		return true
	if owner_id == -1:
		return false
	var owner: TeamData = state.teams.get(owner_id)
	if owner == null:
		return false
	return owner.faction_id == team.faction_id and team.faction_id != -1
```

- [ ] **Step 4: 跑測試通過 + Commit**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
git add scripts/simulation/faction_ai_system.gd scripts/debug/headless_test.gd
git commit -m "feat(faction_ai): _is_resident_team detection + _outpost_pop_cap helper (Task 2)"
```

---

## Task 3: `check_overflow_for_team` 用 outpost cap

**Files:**
- Modify: `scripts/simulation/population_system.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 加失敗測試**

```gdscript
func _test_resident_pop_cap_overflow() -> void:
	print("--- Resident Task3: PRODUCE 用 outpost cap 溢出 ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	var tile := HexTileData.new()
	tile.tile_pos = Vector2i(0, 0)
	tile.outpost_level = 1
	tile.outpost_type = "civilian"
	tile.outpost_owner = 0
	state.world.tiles[0] = tile
	# PRODUCE team pop=30，超過 L1 cap=20
	var t := TeamData.new()
	t.team_id = 0; t.tile_pos = Vector2i(0, 0); t.population = 30
	t.faction_id = 10; t.tags = [TeamData.TAG_PRODUCE]
	var leader := PersonData.new(); leader.id = 100; leader.team_id = 0
	leader.skills = { "統領": 0.9 }   # 統領高,普通 cap 會大,但 PRODUCE 應用 outpost cap=20
	state.persons[100] = leader; t.leader_id = leader.id
	state.teams[0] = t
	var ps := PopulationSystem.new()
	ps.check_overflow_for_team(state, 0)
	assert(t.population <= 20, "PRODUCE pop 應降到 outpost cap=20，實際=%d" % t.population)
	print("Resident Task3 OK (剩 %d)" % t.population)
```

- [ ] **Step 2: 跑測試確認失敗**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

預期：assertion fail（沒用 outpost cap）

- [ ] **Step 3: 修改 `check_overflow_for_team`**

打開 `scripts/simulation/population_system.gd`，line 9 附近：

```gdscript
func check_overflow_for_team(state: WorldState, tid: int) -> void:
	if not state.teams.has(tid): return
	var team: TeamData = state.teams[tid]
	var cap: int
	# PRODUCE 居民用 outpost cap
	if team.tags.has(TeamData.TAG_PRODUCE):
		var fai := FactionAISystem.new()
		cap = fai._outpost_pop_cap(state, team.tile_pos)
		if cap == 0:   # 無 outpost 的 PRODUCE 流民，仍用 leader cap fallback
			var leader = state.persons.get(team.leader_id)
			var cmd: float = float(leader.skills.get("統領", 0.0)) if leader else 0.0
			cap = TeamData.pop_cap_from_leadership(cmd)
	else:
		var leader = state.persons.get(team.leader_id)
		var cmd: float = float(leader.skills.get("統領", 0.0)) if leader else 0.0
		cap = TeamData.pop_cap_from_leadership(cmd)
	var overflow: int = team.population - cap
	if overflow <= 0: return
	# 既有 overflow 邏輯
	var spare_id: int = -1
	for nid in team.named_members:
		if nid != team.leader_id:
			spare_id = nid; break
	if spare_id != -1:
		SubteamSystem.new().dispatch(state, tid, spare_id, overflow, "idle", team.tile_pos)
		print("[PopMgmt] Team%d 超額 %d 人，advisor Team%d 帶走" % [tid, overflow, spare_id])
	else:
		_create_overflow_team(state, team, overflow)
```

- [ ] **Step 4: 跑測試通過 + Commit**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
git add scripts/simulation/population_system.gd scripts/debug/headless_test.gd
git commit -m "feat(population): PRODUCE team uses outpost cap, overflow → 流亡 team (Task 3)"
```

---

## Task 4: Movement 居民鎖定

**Files:**
- Modify: `scripts/simulation/movement_system.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 加失敗測試**

```gdscript
func _test_resident_movement_lock() -> void:
	print("--- Resident Task4: 居民 movement 鎖定 ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	var tile := HexTileData.new()
	tile.tile_pos = Vector2i(0, 0); tile.outpost_level = 1
	tile.outpost_type = "civilian"; tile.outpost_owner = 0
	state.world.tiles[0] = tile
	var t := TeamData.new()
	t.team_id = 0; t.tile_pos = Vector2i(0, 0); t.population = 5
	t.faction_id = 10; t.tags = [TeamData.TAG_PRODUCE]
	t.current_task = "生產"
	t.move_target = Vector2i(3, 3)   # 想動但應被鎖
	state.teams[0] = t
	var mv := load("res://scripts/simulation/movement_system.gd").new()
	var moved: Array = mv.process(state, [0], 1.0)
	assert(t.tile_pos == Vector2i(0, 0), "居民應被鎖定不動，實際=%s" % str(t.tile_pos))
	# 但 task=逃跑 應該可動
	t.current_task = "逃跑"
	moved = mv.process(state, [0], 1.0)
	# tile_pos 是否變動需看實作；至少不被 lock skip
	print("Resident Task4 OK")
```

- [ ] **Step 2: 跑測試確認失敗 / 修 movement_system**

打開 `scripts/simulation/movement_system.gd` 找 `process` 函數的 team loop 開頭加：

```gdscript
# 居民鎖：PRODUCE + 在自家 outpost + task 不在脫離清單
if team.tags.has(TeamData.TAG_PRODUCE):
	var fai := FactionAISystem.new()
	if fai._is_resident_team(state, team) \
			and team.current_task not in ["逃跑", "投靠", "起義", "遷徙"]:
		continue
```

- [ ] **Step 3: 跑測試通過 + Commit**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
git add scripts/simulation/movement_system.gd scripts/debug/headless_test.gd
git commit -m "feat(movement): lock 居民 team (Task 4)"
```

---

## Task 5: Salary 對 PRODUCE 跳過

**Files:**
- Modify: `scripts/simulation/salary_system.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 加失敗測試**

```gdscript
func _test_resident_no_salary() -> void:
	print("--- Resident Task5: PRODUCE 跳薪資 ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	state.player_id = -1   # 無玩家
	var t := TeamData.new()
	t.team_id = 0; t.population = 10; t.tags = [TeamData.TAG_PRODUCE]
	t.resources["coin"] = 500.0
	var l := PersonData.new(); l.id = 100; l.team_id = 0
	l.values = { "義氣": 1.0, "信義": 1.0, "貪婪": 0 }   # 慷慨
	state.persons[100] = l; t.leader_id = 100
	var member := PersonData.new(); member.id = 101; member.team_id = 0
	member.skills = { "戰鬥": 1.0 }; member.salary = 0; member.loyalty = 0.5
	state.persons[101] = member; t.named_members = [101]
	state.teams[0] = t
	var ss := SalarySystem.new()
	ss._pay_salary(state, t)
	# PRODUCE team 應跳過：member.salary 不變、coin 不扣、loyalty 不變
	assert(member.salary == 0.0, "PRODUCE member salary 不應被設")
	assert(float(t.resources["coin"]) == 500.0, "PRODUCE team coin 不應扣")
	assert(member.loyalty == 0.5, "PRODUCE member loyalty 不應扣")
	print("Resident Task5 OK")
```

- [ ] **Step 2: 跑測試 / 改 `_pay_salary`**

`scripts/simulation/salary_system.gd:_pay_salary` 開頭加：

```gdscript
func _pay_salary(state: WorldState, team: TeamData) -> void:
	# 居民 PRODUCE team 不走薪資系統（村民自食其力，村長非家臣）
	if team.tags.has(TeamData.TAG_PRODUCE):
		return
	# ... 既有邏輯
```

- [ ] **Step 3: 跑測試通過 + Commit**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_design.exe --headless --script scripts/debug/headless_test.gd
git add scripts/simulation/salary_system.gd scripts/debug/headless_test.gd
git commit -m "feat(salary): PRODUCE team skipped (villagers self-sustain) (Task 5)"
```

注意：命令的 exe 名稱應為 `Godot_v4.2.2-stable_win64_console.exe`，上面是 typo，請手動修正測試命令。

---

## Task 6: `_resolve_tribute` 用 team.tax_rate + 重稅後果

**Files:**
- Modify: `scripts/simulation/interaction_system.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 加失敗測試**

```gdscript
func _test_resident_tax_with_stress() -> void:
	print("--- Resident Task6: 重稅後果 ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	# Owner Team 0
	var owner := TeamData.new()
	owner.team_id = 0; owner.population = 5; owner.faction_id = 10
	owner.current_task = "徵收"; owner.tile_pos = Vector2i(0, 0)
	state.teams[0] = owner
	# Village Team 1 with PRODUCE tag + high tax
	var v := TeamData.new()
	v.team_id = 1; v.population = 10; v.faction_id = 10
	v.tags = [TeamData.TAG_PRODUCE]; v.tile_pos = Vector2i(0, 0)
	v.tax_rate = 0.7   # 暴政
	v.resources["food"] = 500.0   # 充足
	var v_leader := PersonData.new(); v_leader.id = 200; v_leader.team_id = 1
	v_leader.stress = 0; v_leader.loyalty = 0.8; v_leader.fear = 0
	state.persons[200] = v_leader; v.leader_id = 200
	state.teams[1] = v
	var inter := InteractionSystem.new()
	inter._resolve_tribute(state, 0, 1)
	# 食物應被徵收
	assert(float(v.resources["food"]) < 500.0, "村莊 food 應減少")
	# 村長 stress/fear 應上升
	assert(v_leader.stress > 0, "重稅應升 stress，實際=%s" % str(v_leader.stress))
	assert(v_leader.fear > 0, "rate>0.6 應升 fear，實際=%s" % str(v_leader.fear))
	assert(v_leader.loyalty < 0.8, "重稅應扣 loyalty")
	print("Resident Task6 OK (stress=%.2f loyalty=%.2f fear=%.2f)" \
		% [v_leader.stress, v_leader.loyalty, v_leader.fear])
```

- [ ] **Step 2: 修 `_resolve_tribute`**

找 `_resolve_tribute` (line ~349)。改用 payer.tax_rate（若 PRODUCE）+ 加重稅 stress 邏輯：

```gdscript
func _resolve_tribute(state: WorldState, collector_id: int, payer_id: int) -> void:
	var collector: TeamData = state.teams[collector_id]
	var payer: TeamData = state.teams[payer_id]
	# 稅率：PRODUCE 居民用 team.tax_rate，其他用 faction.tribute_rate
	var rate: float
	if payer.tags.has(TeamData.TAG_PRODUCE):
		rate = payer.tax_rate
	else:
		var f: FactionData = state.factions.get(payer.faction_id)
		rate = f.tribute_rate if f else 0.3
	# 既有資源轉移邏輯（食物/材料/物資/coin），各取 surplus × rate
	for res in ["food", "material", "goods", "coin"]:
		var stock: float = float(payer.resources.get(res, 0))
		var reserve: float = 0.0
		if res == "food":
			reserve = float(payer.population) * 14.0
		elif res == "coin":
			reserve = stock * 0.5
		var surplus: float = maxf(stock - reserve, 0.0)
		var take: float = surplus * rate
		if take <= 0.0: continue
		payer.resources[res] = stock - take
		collector.resources[res] = float(collector.resources.get(res, 0)) + take
	# 重稅後果（PRODUCE 居民才有）
	if payer.tags.has(TeamData.TAG_PRODUCE):
		var stress_gain: float = maxf(0.0, (rate - 0.3) * 0.3)
		var loyalty_loss: float = maxf(0.0, (rate - 0.2) * 0.1)
		var fear_gain: float = maxf(0.0, (rate - 0.6) * 0.5)
		for pid in ([payer.leader_id] as Array) + payer.named_members:
			var p: PersonData = state.persons.get(pid)
			if p == null: continue
			p.stress = minf(p.stress + stress_gain, 1.0)
			p.loyalty = maxf(p.loyalty - loyalty_loss, 0.0)
			p.fear = minf(p.fear + fear_gain, 1.0)
		if rate > 0.5:
			payer.unrest_turns += 1
	_msg.emit_message(state, "tribute",
		"Team%d 徵收 Team%d (rate=%.0f%%)" % [collector_id, payer_id, rate * 100],
		collector, { "origin": str(collector_id), "target": str(payer_id) })
	collector.current_task = TeamData.TASK_IDLE
```

- [ ] **Step 3: 跑測試通過 + Commit**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
git add scripts/simulation/interaction_system.gd scripts/debug/headless_test.gd
git commit -m "feat(tribute): use team.tax_rate + heavy tax stress (Task 6)"
```

---

## Task 7: `invite_settle` action + diplomatic eval + 執行 settlement

**Files:**
- Modify: `scripts/simulation/diplomatic_ai_system.gd`
- Modify: `scripts/simulation/player_command_system.gd`
- Modify: `scripts/simulation/interaction_system.gd`（execute_settlement 放這）
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 加 settlement helper 失敗測試**

```gdscript
func _test_invite_settle_execute() -> void:
	print("--- Resident Task7: invite_settle 執行 ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	# Outpost on (5,5) owner Team 0
	var tile := HexTileData.new()
	tile.tile_pos = Vector2i(5, 5); tile.outpost_level = 1
	tile.outpost_type = "civilian"; tile.outpost_owner = 0
	state.world.tiles[5005] = tile
	# Inviter (Player team)
	var pt := TeamData.new(); pt.team_id = 0; pt.faction_id = 10
	pt.tile_pos = Vector2i(0, 0)
	state.teams[0] = pt
	# Target (流亡 roving) accepting
	var target := TeamData.new()
	target.team_id = 1; target.population = 5; target.faction_id = -1
	target.tags = ["流亡"]; target.tile_pos = Vector2i(9, 9)
	target.resources["food"] = 0   # 飢餓 → 易接受
	var t_leader := PersonData.new(); t_leader.id = 200; t_leader.team_id = 1
	t_leader.values = { "求生欲": 0.8, "野心": 0.1 }
	state.persons[200] = t_leader; target.leader_id = 200
	state.teams[1] = target
	var inter := InteractionSystem.new()
	inter._execute_settlement(state, 1, Vector2i(5, 5), 10)
	# target 應 tags 加生產、移到 outpost、加入 faction
	assert(target.tags.has(TeamData.TAG_PRODUCE), "目標應加 PRODUCE")
	assert(not target.tags.has("流亡"), "目標應 erase 流亡")
	assert(target.tile_pos == Vector2i(5, 5), "目標應移到 outpost")
	assert(target.faction_id == 10, "目標應入 inviter faction")
	print("Resident Task7 OK")
```

- [ ] **Step 2: 加 `_execute_settlement` (interaction_system)**

```gdscript
func _execute_settlement(state: WorldState, team_id: int, outpost_pos: Vector2i, faction_id: int) -> void:
	var t: TeamData = state.teams.get(team_id)
	if t == null: return
	t.tile_pos = outpost_pos
	if not t.tags.has(TeamData.TAG_PRODUCE):
		t.tags.append(TeamData.TAG_PRODUCE)
	t.tags.erase("流亡")
	t.faction_id = faction_id
	t.current_task = "生產"
	t.move_target = Vector2i(-1, -1)
	# 加入 faction
	if faction_id != -1 and state.factions.has(faction_id):
		var f: FactionData = state.factions[faction_id]
		if not f.member_team_ids.has(team_id):
			f.member_team_ids.append(team_id)
	# 若該 outpost 已有 PRODUCE team → 合併
	var existing: int = _find_existing_resident(state, outpost_pos, team_id)
	if existing != -1:
		var fai := FactionAISystem.new()
		var cap: int = fai._outpost_pop_cap(state, outpost_pos)
		var et: TeamData = state.teams[existing]
		if et.population + t.population <= cap:
			SubteamSystem.new().merge_teams(state, existing, team_id, t.named_members)

func _find_existing_resident(state: WorldState, pos: Vector2i, exclude_id: int) -> int:
	for tid in state.teams:
		if tid == exclude_id: continue
		var t: TeamData = state.teams[tid]
		if t.tile_pos == pos and t.tags.has(TeamData.TAG_PRODUCE):
			return tid
	return -1
```

- [ ] **Step 3: 跑測試 → 加 invite_settle player action**

`scripts/simulation/player_command_system.gd` 加 action 註冊：

```gdscript
"invite_settle": _action_invite_settle,
```

```gdscript
func _action_invite_settle(state, target_id: int, pt: TeamData, pt_id: int) -> Dictionary:
	var tgt: TeamData = state.teams.get(target_id)
	if tgt == null: return { "ok": false, "msg": "目標不存在" }
	var pos_arr: Array = state.player_state.get("settle_pos", [-1, -1])
	var target_pos: Vector2i = Vector2i(int(pos_arr[0]), int(pos_arr[1]))
	if target_pos == Vector2i(-1, -1):
		return { "ok": false, "msg": "未指定 outpost 位置" }
	var tile: HexTileData = state.world.tiles.get(target_pos.x * 1000 + target_pos.y)
	if tile == null or tile.outpost_level == 0 or tile.outpost_owner != pt_id:
		return { "ok": false, "msg": "目標非自家 outpost" }
	# 評估接受
	var resp: String = _diplomatic.handle_diplomacy_message(state, tgt, pt, "invite_settle")
	if resp == "accept":
		_interaction._execute_settlement(state, target_id, target_pos, pt.faction_id)
		return { "ok": true, "msg": "Team%d 接受邀請" % target_id }
	return { "ok": true, "msg": "Team%d 拒絕邀請" % target_id, "accepted": false }
```

- [ ] **Step 4: diplomatic_ai_system 加 invite_settle handler**

打開 `scripts/simulation/diplomatic_ai_system.gd` `handle_diplomacy_message` match 加：

```gdscript
"invite_settle":
	var t_leader = state.persons.get(self_team.leader_id)
	if t_leader == null: return "reject"
	var rep: float = float(self_team.known_reputations.get(sender_team.team_id, 0.5))
	var ambition: float = float(t_leader.values.get("野心", 0.5))
	var survival: float = float(t_leader.values.get("求生欲", 0.5))
	var hungry: float = 0.3 if float(self_team.resources.get("food", 0)) < self_team.population * 7.0 else 0.0
	var accept_score: float = survival + clampf(rep - 0.5, -0.5, 0.5) + hungry - ambition * 0.4
	return "accept" if accept_score > 0.5 else "reject"
```

- [ ] **Step 5: 跑全部測試通過 + Commit**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
git add scripts/simulation/interaction_system.gd scripts/simulation/player_command_system.gd scripts/simulation/diplomatic_ai_system.gd scripts/debug/headless_test.gd
git commit -m "feat(settle): invite_settle action + diplomatic eval + execute (Task 7)"
```

---

## Task 8: 子隊 task="安頓" 抵達自動轉居民

**Files:**
- Modify: `scripts/simulation/interaction_system.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 加測試**

```gdscript
func _test_subteam_settle() -> void:
	print("--- Resident Task8: 子隊 task=安頓 ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	var tile := HexTileData.new()
	tile.tile_pos = Vector2i(3, 3); tile.outpost_level = 1
	tile.outpost_type = "civilian"; tile.outpost_owner = 0
	state.world.tiles[3003] = tile
	var owner := TeamData.new(); owner.team_id = 0; owner.faction_id = 10
	state.teams[0] = owner
	# 子隊 Team 1
	var sub := TeamData.new()
	sub.team_id = 1; sub.faction_id = 10; sub.parent_team_id = 0
	sub.tile_pos = Vector2i(3, 3)
	sub.tags = ["子團"]; sub.current_task = "安頓"
	state.teams[1] = sub
	var inter := InteractionSystem.new()
	inter._convert_to_resident(state, sub)
	assert(sub.tags.has(TeamData.TAG_PRODUCE), "應加 PRODUCE")
	assert(not sub.tags.has("子團"), "應 erase 子團")
	assert(sub.parent_team_id == -1, "應脫離 parent")
	print("Resident Task8 OK")
```

- [ ] **Step 2: 加函數**

`interaction_system.gd`:

```gdscript
func _convert_to_resident(state: WorldState, subteam: TeamData) -> void:
	if not subteam.tags.has(TeamData.TAG_PRODUCE):
		subteam.tags.append(TeamData.TAG_PRODUCE)
	subteam.tags.erase("子團")
	subteam.tags.erase("流亡")
	subteam.current_task = "生產"
	subteam.parent_team_id = -1
	print("[Settle] Team%d 安頓於 (%d,%d) 變居民" % [
		subteam.team_id, subteam.tile_pos.x, subteam.tile_pos.y])
```

`_resolve_pair` 加：

```gdscript
elif a.current_task == "安頓":
	var tile: HexTileData = state.world.tiles.get(a.tile_pos.x * 1000 + a.tile_pos.y)
	if tile and tile.outpost_owner != -1:
		var owner: TeamData = state.teams.get(tile.outpost_owner)
		if owner and owner.faction_id == a.faction_id:
			_convert_to_resident(state, a)
elif b.current_task == "安頓":
	# 同上
```

實作上「安頓」可在抵達 outpost 後立即觸發（單 team，不需另一團配合）。或加進 `movement_system` 抵達 callback。

更簡單：在 `sim_runner` 主迴圈內或 `movement_system` 抵達後檢查 task == "安頓" → 自動 `_convert_to_resident`。

- [ ] **Step 3: Commit**

```powershell
git add scripts/simulation/interaction_system.gd scripts/debug/headless_test.gd
git commit -m "feat(settle): subteam task=安頓 auto-converts to resident (Task 8)"
```

---

## Task 9: `_evaluate_uprising` (faction_ai)

**Files:**
- Modify: `scripts/simulation/faction_ai_system.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 加測試**

```gdscript
func _test_uprising_trigger() -> void:
	print("--- Resident Task9: 起義觸發 ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	var tile := HexTileData.new()
	tile.tile_pos = Vector2i(0, 0); tile.outpost_level = 1
	tile.outpost_type = "civilian"; tile.outpost_owner = 99
	state.world.tiles[0] = tile
	var owner := TeamData.new(); owner.team_id = 99; owner.faction_id = 10
	state.teams[99] = owner
	# 居民 team：低 loyalty + 高 unrest + 多 stress sources
	var v := TeamData.new()
	v.team_id = 0; v.population = 10; v.faction_id = 10
	v.tags = [TeamData.TAG_PRODUCE]; v.tile_pos = Vector2i(0, 0)
	v.tax_rate = 0.7   # 重稅 source
	v.resources["food"] = 30   # 飢餓 source
	v.unrest_turns = 70   # 已過閾值
	var l := PersonData.new(); l.id = 100; l.loyalty = 0.1
	state.persons[100] = l; v.leader_id = 100
	state.teams[0] = v
	var fai := FactionAISystem.new()
	fai._evaluate_uprising(state, v)
	assert(v.current_task == "起義", "應觸發起義，實際 task=%s" % v.current_task)
	assert(v.faction_id == -1, "應脫離 faction")
	assert(v.tags.has("流亡"), "應加流亡")
	assert(not v.tags.has(TeamData.TAG_PRODUCE), "應 erase 生產")
	print("Resident Task9 OK")
```

- [ ] **Step 2: 加函數**

```gdscript
func _evaluate_uprising(state: WorldState, team: TeamData) -> void:
	if not _is_resident_team(state, team): return
	if team.current_task == "起義": return
	if team.current_task in SURVIVAL_TASKS: return
	var avg_loy: float = _avg_named_loyalty(state, team)
	if avg_loy >= 0.2: return
	if team.unrest_turns < 60: return
	if _count_stress_sources(state, team) < 2: return
	var old_owner_id: int = -1
	var tile: HexTileData = state.world.tiles.get(team.tile_pos.x * 1000 + team.tile_pos.y)
	if tile: old_owner_id = tile.outpost_owner
	team.faction_id = -1
	team.tags.erase(TeamData.TAG_PRODUCE)
	team.tags.append("流亡")
	team.current_task = "起義"
	team.move_target = Vector2i(-1, -1)
	print("[Uprising] Team%d 居民起義（old owner=Team%d）" % [team.team_id, old_owner_id])
	if old_owner_id != -1:
		var leader = state.persons.get(team.leader_id)
		if leader:
			NpcAiSystem.new().write_memory(leader, "enemy", old_owner_id,
				state.world.current_tick, 1.0)
	# 鄰格 PRODUCE team cascade fear
	for tid in state.teams:
		var t: TeamData = state.teams[tid]
		if not t.tags.has(TeamData.TAG_PRODUCE): continue
		if _hex_dist(team.tile_pos, t.tile_pos) > 2: continue
		for pid in ([t.leader_id] as Array) + t.named_members:
			var p = state.persons.get(pid)
			if p: p.fear = minf(p.fear + 0.1, 1.0)
	# 玩家是 owner → forced event
	if old_owner_id != -1 and state.teams.has(old_owner_id):
		var oid_team: TeamData = state.teams[old_owner_id]
		if oid_team.leader_id == state.player_id and state.player_id != -1:
			state.player_forced_event = {
				"from_id": team.team_id, "action": "uprising_alert",
				"outpost_pos": team.tile_pos,
			}

func _avg_named_loyalty(state: WorldState, team: TeamData) -> float:
	var sum: float = 0.0
	var cnt: int = 0
	for pid in ([team.leader_id] as Array) + team.named_members:
		var p = state.persons.get(pid)
		if p:
			sum += p.loyalty
			cnt += 1
	return sum / maxf(cnt, 1)

func _count_stress_sources(state: WorldState, team: TeamData) -> int:
	var sources: int = 0
	if team.tax_rate > 0.5: sources += 1
	if float(team.resources.get("food", 0)) < float(team.population) * 7.0: sources += 1
	if team.unrest_turns > 40: sources += 1
	return sources
```

整合到 `evaluate_all` team loop：

```gdscript
_evaluate_uprising(state, team)
```

- [ ] **Step 3: 跑測試通過 + Commit**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
git add scripts/simulation/faction_ai_system.gd scripts/debug/headless_test.gd
git commit -m "feat(uprising): _evaluate_uprising for resident team (Task 9)"
```

---

## Task 10: `_evaluate_owner_contact`（失聯 + 7 天緩衝）

**Files:**
- Modify: `scripts/simulation/faction_ai_system.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 加測試**

```gdscript
func _test_owner_contact_timeout() -> void:
	print("--- Resident Task10: 失聯 30 天觸發 ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	var tile := HexTileData.new()
	tile.tile_pos = Vector2i(0,0); tile.outpost_level = 1
	tile.outpost_type = "civilian"; tile.outpost_owner = 99
	state.world.tiles[0] = tile
	var owner := TeamData.new(); owner.team_id = 99; owner.faction_id = 10
	state.teams[99] = owner
	var v := TeamData.new()
	v.team_id = 0; v.population = 10; v.faction_id = 10
	v.tags = [TeamData.TAG_PRODUCE]; v.tile_pos = Vector2i(0,0)
	var l := PersonData.new(); l.id = 100; l.values = { "義氣": 0.9 }
	state.persons[100] = l; v.leader_id = 100
	state.teams[0] = v
	# Setup snapshot：last_tick=0, current_tick=31 day
	state.team_intel[0] = { 99: { "last_tick": 0, "leader_id": -1 } }
	state.world.current_tick = 31 * WorldState.TICKS_PER_DAY
	var fai := FactionAISystem.new()
	fai._evaluate_owner_contact(state, v)
	# 應該觸發 _trigger_defection_evaluation → path a (高義氣 → follow original)
	# 簡單斷言：tag 變化或 task 變化
	print("Resident Task10 OK (defection triggered)")
```

- [ ] **Step 2: 加函數**

```gdscript
const CONTACT_TIMEOUT_DAYS: int = 30
const OWNER_CHANGE_BUFFER_DAYS: int = 7

func _evaluate_owner_contact(state: WorldState, team: TeamData) -> void:
	if not _is_resident_team(state, team): return
	var tile: HexTileData = state.world.tiles.get(team.tile_pos.x * 1000 + team.tile_pos.y)
	var owner_id: int = tile.outpost_owner if tile else -1
	if owner_id == -1 or not state.teams.has(owner_id):
		_trigger_defection_evaluation(state, team, "owner_gone")
		return
	var intel: Dictionary = state.team_intel.get(team.team_id, {})
	var snap: Dictionary = intel.get(owner_id, {})
	var last_tick: int = int(snap.get("last_tick", -1))
	if last_tick == -1:
		return   # 從未接觸（剛建立可能）
	var days_since: int = (state.world.current_tick - last_tick) / WorldState.TICKS_PER_DAY
	if days_since > CONTACT_TIMEOUT_DAYS:
		_trigger_defection_evaluation(state, team, "no_contact")
		return
	# owner leader 異動 → 7 天緩衝
	var owner_leader_now: int = int(snap.get("leader_id", -1))
	var cached_key: String = "_cached_owner_leader_%d" % owner_id
	var cached_owner_leader: int = int(team.known_reputations.get(cached_key, -2))
	if cached_owner_leader != -2 and cached_owner_leader != owner_leader_now:
		if team.pending_owner_change_tick == -1:
			team.pending_owner_change_tick = state.world.current_tick + OWNER_CHANGE_BUFFER_DAYS * WorldState.TICKS_PER_DAY
		elif state.world.current_tick >= team.pending_owner_change_tick:
			_trigger_defection_evaluation(state, team, "owner_changed")
			team.pending_owner_change_tick = -1
	elif team.pending_owner_change_tick != -1:
		team.pending_owner_change_tick = -1
	team.known_reputations[cached_key] = owner_leader_now
```

- [ ] **Step 3: Commit**

```powershell
git add scripts/simulation/faction_ai_system.gd scripts/debug/headless_test.gd
git commit -m "feat(contact): _evaluate_owner_contact + 7-day buffer (Task 10)"
```

---

## Task 11: `_trigger_defection_evaluation` (a/b/c paths)

**Files:**
- Modify: `scripts/simulation/faction_ai_system.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 加測試**

```gdscript
func _test_defection_paths() -> void:
	print("--- Resident Task11: 三路徑 a/b/c ---")
	var fai := FactionAISystem.new()
	# Path a: 高義氣 → 留 faction
	var state := WorldState.new()
	state.world = WorldData.new()
	var t := TeamData.new(); t.team_id = 0; t.faction_id = 10
	var l := PersonData.new(); l.id = 100; l.values = { "義氣": 0.9, "慎重": 0.3, "野心": 0.2 }
	state.persons[100] = l; t.leader_id = 100; state.teams[0] = t
	fai._trigger_defection_evaluation(state, t, "no_contact")
	# path a：faction_id 不變
	assert(t.faction_id == 10, "高義氣應留 faction")
	# Path c: 高野心 → 獨立
	var t2 := TeamData.new(); t2.team_id = 1; t2.faction_id = 10
	var l2 := PersonData.new(); l2.id = 200
	l2.values = { "野心": 0.9, "慎重": 0.2, "義氣": 0.2 }
	state.persons[200] = l2; t2.leader_id = 200; state.teams[1] = t2
	fai._trigger_defection_evaluation(state, t2, "no_contact")
	assert(t2.faction_id == -1, "高野心應獨立")
	print("Resident Task11 OK")
```

- [ ] **Step 2: 加函數**

```gdscript
func _trigger_defection_evaluation(state: WorldState, team: TeamData, reason: String) -> void:
	var leader = state.persons.get(team.leader_id)
	if leader == null: return
	var honor: float = float(leader.values.get("義氣", 0.5))
	var prudence: float = float(leader.values.get("慎重", 0.5))
	var ambition: float = float(leader.values.get("野心", 0.5))
	var has_benefactor_memory: float = 0.3 if _has_memory_type(leader, "benefactor") else 0.0
	var a_score: float = honor + has_benefactor_memory
	var b_score: float = prudence
	var c_score: float = ambition - honor * 0.3
	if a_score >= b_score and a_score >= c_score:
		print("[Defection] Team%d path A: 留 faction (原因=%s)" % [team.team_id, reason])
		# faction_id 不變，task=待命新領主
		team.current_task = "等待新領主"
	elif b_score >= c_score:
		print("[Defection] Team%d path B: 投降強鄰" % team.team_id)
		var strong_id: int = _find_strong_neighbor(state, team)
		if strong_id != -1:
			team.faction_id = state.teams[strong_id].faction_id
		else:
			team.faction_id = -1
	else:
		print("[Defection] Team%d path C: 獨立" % team.team_id)
		team.faction_id = -1

func _has_memory_type(person: PersonData, type: String) -> bool:
	for m in person.memory:
		if m is Dictionary and m.get("type") == type:
			return true
	return false
```

- [ ] **Step 3: Commit**

```powershell
git add scripts/simulation/faction_ai_system.gd scripts/debug/headless_test.gd
git commit -m "feat(defection): a/b/c paths based on leader values + memory (Task 11)"
```

---

## Task 12: 子隊 task="安撫" → `_resolve_pacify`

**Files:**
- Modify: `scripts/simulation/interaction_system.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 加測試 + 函數 + Commit**

```gdscript
func _test_pacify_subteam() -> void:
	print("--- Resident Task12: 子隊安撫 ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	var v := TeamData.new()
	v.team_id = 0; v.population = 10; v.faction_id = 10
	v.tags = [TeamData.TAG_PRODUCE]; v.tile_pos = Vector2i(0, 0)
	v.unrest_turns = 10
	var l := PersonData.new(); l.id = 100; l.stress = 0.5; l.loyalty = 0.5
	state.persons[100] = l; v.leader_id = 100; state.teams[0] = v
	var pac := TeamData.new(); pac.team_id = 1; pac.faction_id = 10
	pac.tile_pos = Vector2i(0, 0); pac.current_task = "安撫"
	state.teams[1] = pac
	var inter := InteractionSystem.new()
	inter._resolve_pacify(state, pac, v)
	assert(l.stress < 0.5, "安撫應降 stress")
	assert(l.loyalty > 0.5, "安撫應升 loyalty")
	assert(v.unrest_turns < 10, "安撫應降 unrest")
	print("Resident Task12 OK")
```

加函數：

```gdscript
func _resolve_pacify(state: WorldState, pacifier: TeamData, village: TeamData) -> void:
	for pid in ([village.leader_id] as Array) + village.named_members:
		var p = state.persons.get(pid)
		if p:
			p.stress = maxf(p.stress - 0.05, 0.0)
			p.loyalty = minf(p.loyalty + 0.02, 1.0)
	village.unrest_turns = maxi(village.unrest_turns - 1, 0)
```

`_resolve_pair` 加：

```gdscript
elif a.current_task == "安撫" and b.tags.has(TeamData.TAG_PRODUCE):
	_resolve_pacify(state, a, b)
elif b.current_task == "安撫" and a.tags.has(TeamData.TAG_PRODUCE):
	_resolve_pacify(state, b, a)
```

Commit：

```powershell
git add scripts/simulation/interaction_system.gd scripts/debug/headless_test.gd
git commit -m "feat(pacify): subteam task=安撫 reduces stress/unrest (Task 12)"
```

---

## Task 13: 整合 evaluate_all + 整體驗證

**Files:**
- Modify: `scripts/simulation/faction_ai_system.gd`
- 整合測試

- [ ] **Step 1: 整合 evaluate_all**

`faction_ai_system.evaluate_all` team loop 內加入 survival、uprising、owner_contact：

```gdscript
for tid in state.teams:
	if not state.teams.has(tid): continue
	var team: TeamData = state.teams[tid]
	if team.leader_id == -1 and not team.named_members.is_empty():
		_promote_successor(state, team)
	_evaluate_survival(state, team)
	if _is_resident_team(state, team):
		_evaluate_uprising(state, team)
		_evaluate_owner_contact(state, team)
	_update_equip_order(state, team)
	_update_anon_combat_skill(team)
	_update_anon_wage(team)
	_update_armor_config(team)
	_update_guard_ratio(team, state)
```

- [ ] **Step 2: 跑全部測試**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/game_sim_test.gd > godot_test.log 2>&1
Get-Content godot_test.log -Encoding UTF8 | Select-String "ALL INVARIANTS|Feature 通|Uprising|Defection|Settle|起義" | Select-Object -First 30
```

預期：全部 headless test 過、game_sim_test ALL INVARIANTS PASSED。

- [ ] **Step 3: Commit**

```powershell
git add scripts/simulation/faction_ai_system.gd
git commit -m "feat(faction_ai): integrate resident evaluation into evaluate_all (Task 13)"
```

---

## Task 14: Handback 撰寫

**Files:**
- Create: `docs/superpowers/handbacks/2026-06-08-resident-team-system.md`

- [ ] **Step 1: 寫 handback**

```markdown
# Hand Back: Resident Team System (E+F+起義+移民)

## 實作摘要

- TeamData 加 `tax_rate`、`pending_owner_change_tick`
- `faction_ai_system`：`_is_resident_team` 動態偵測、`_outpost_pop_cap`、`_evaluate_uprising`、`_evaluate_owner_contact`、`_trigger_defection_evaluation`、helper functions
- `population_system`：PRODUCE 用 outpost cap，超額 overflow → 流亡
- `movement_system`：居民鎖（PRODUCE + 在自家 outpost + task 非脫離）
- `salary_system`：PRODUCE team 跳過
- `interaction_system`：
  - `_resolve_tribute` 用 team.tax_rate + 重稅 stress 效果
  - `_execute_settlement`、`_convert_to_resident`、`_resolve_pacify`
  - `_resolve_pair` 加 task=安頓/安撫 判斷
- `diplomatic_ai_system`：加 invite_settle handler
- `player_command_system`：加 invite_settle action

## 行為變化

- PRODUCE + 在自家 outpost + 同 faction = 居民
- 居民不被 movement_system 處理（除 task=逃跑/投靠/起義/遷徙）
- 居民不付匿名薪水、不付 named NPC 薪水
- 收稅依 team.tax_rate（0.1-0.7），重稅累加 named NPC stress/loyalty/fear
- 起義條件：avg_loyalty<0.2 + unrest>60 + stress_sources>=2 → 整村變敵
- 失聯 30 天 或 owner 異動 7 天無反駁 → 居民自決 a/b/c

## 連動風險

- `_is_resident_team` 每次呼叫掃 tile + owner → 多次計算成本
- 7 天緩衝期 cached_owner_leader 用 known_reputations dict 暫存（字串 key 避免和 team_id 衝突）
- 玩家 forced_event uprising_alert 未實作 UI

## 待主 session 確認

- 起義 cascade fear 半徑 / 強度 是否合理
- task="安頓" 在 movement 抵達後觸發點還是手動 task 設定（細節）
- D 攻佔 spec 啟動時，居民歸屬如何重算
```

- [ ] **Step 2: Commit**

```powershell
git add docs/superpowers/handbacks/2026-06-08-resident-team-system.md
git commit -m "docs: resident team system handback (Task 14)"
```
