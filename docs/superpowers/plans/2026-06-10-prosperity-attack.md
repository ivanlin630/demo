# NPC 主動征服系統 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** NPC 主動征服系統。野心驅動 prosperity attack + survival B 分支（遠 outpost 可掠）+ 軍隊 tag 加成 + 攻佔 outpost 居民處置 + 戰敗 reaction。

**Architecture:**
- `_evaluate_prosperity_attack` 入口，cadence 3 日 + 3 事件重評
- attack_score / readiness threshold / prey 選擇 個性公式
- `_trigger_survival` Path 1 修改加 B 分支
- encounter end callback 處理 occupy outpost 三 path（屠/放棄/強佔）
- reaction_system 加 `AttackDefeat` event tag

**Spec:** `docs/superpowers/specs/2026-06-10-prosperity-attack-design.md`

---

## 檔案結構

| 檔案 | 變更 |
|---|---|
| `scripts/simulation/faction_ai_system.gd` | 加 prosperity attack 函數 + readiness + prey selector + 修 Path 1 (B 分支) |
| `scripts/simulation/sim_runner.gd` | 加 cadence + 事件 trigger 重評 |
| `scripts/simulation/encounter_system.gd` | end callback 處理 occupy + defeat reaction |
| `scripts/simulation/reaction_system.gd` | 加 `AttackDefeat` event 處理 |
| `scripts/data/team_data.gd` | 加 `prosperity_eval_cooldown_until: int = 0` 欄位 |
| `scripts/debug/headless_test.gd` | 15 個測試 |

## 測試命令

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --import
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/game_sim_test.gd
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/game_sim_multi.gd
```

---

## Task 1: 加 const + readiness helpers

**Files:**
- Modify: `scripts/simulation/faction_ai_system.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 測試先**

```gdscript
func _test_readiness_threshold() -> void:
	print("--- Prosperity Task1: readiness threshold ---")
	var team := TeamData.new()
	team.tags = []
	var leader := PersonData.new()
	leader.values = { "殘忍": 0.8, "好戰": 0.5, "慎重": 0.3 }
	# threshold = 0.55 - max(0.8, 0.5)*0.15 + 0.3*0.15 = 0.55 - 0.12 + 0.045 = 0.475
	var t = FactionAiSystem.calc_readiness_threshold(team, leader)
	assert(abs(t - 0.475) < 0.01, "預期 0.475 實際=%.3f" % t)
	team.tags = ["軍隊"]
	t = FactionAiSystem.calc_readiness_threshold(team, leader)
	assert(abs(t - 0.375) < 0.01, "軍隊預期 0.375 實際=%.3f" % t)
	print("Prosperity Task1 OK")
```

- [ ] **Step 2: 加常數 + helper**

`faction_ai_system.gd` 加：

```gdscript
const PROSPERITY_CADENCE: int = 720           # 3 天
const PROSPERITY_CADENCE_MILITARY: int = 360  # 1.5 天
const ANON_TREASURY_BONUS_THRESHOLD: float = 200.0

static func calc_readiness_threshold(team: TeamData, leader: PersonData) -> float:
	var ferocity: float = maxf(
		float(leader.values.get("殘忍", 0.5)),
		float(leader.values.get("好戰", 0.5))
	)
	var caution: float = float(leader.values.get("慎重", 0.5))
	var threshold: float = 0.55 - ferocity * 0.15 + caution * 0.15
	if "軍隊" in team.tags:
		threshold -= 0.1
	return clampf(threshold, 0.3, 0.85)

static func calc_readiness(team: TeamData) -> float:
	var pop_factor: float = clampf(float(team.population) / 10.0, 0.0, 1.0)
	var skill: float = team.anon_combat_skill
	var food_days: float = float(team.resources.get("food", 0)) \
		/ maxf(float(team.population) * FOOD_PER_PERSON_PER_DAY_SURVIVAL, 0.001)
	var food_factor: float = clampf(food_days / 14.0, 0.0, 1.0)
	var weapon: float = float(team.resources.get("weapon_melee_low", 0))
	var weapon_factor: float = clampf(weapon / maxf(float(team.population), 1.0), 0.0, 1.0)
	return (pop_factor + skill + food_factor + weapon_factor) / 4.0

static func calc_attack_score(team: TeamData, leader: PersonData) -> float:
	var ambition: float = float(leader.values.get("野心", 0.5))
	var martial: float = float(leader.values.get("好戰", 0.5))
	var honor: float = float(leader.values.get("信義", 0.5))
	var base: float = ambition * 0.4 + martial * 0.4 - honor * 0.4
	if team.anon_treasury > ANON_TREASURY_BONUS_THRESHOLD:
		base += 0.1
	return base
```

- [ ] **Step 3: 跑測試 + Commit**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
git add scripts/simulation/faction_ai_system.gd scripts/debug/headless_test.gd
git commit -m "feat(faction_ai): prosperity helpers (readiness/attack_score) (Task 1)"
```

---

## Task 2: `_find_prosperity_prey` selector

**Files:**
- Modify: `scripts/simulation/faction_ai_system.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 測試**

```gdscript
func _test_find_prosperity_prey() -> void:
	print("--- Prosperity Task2: prey selector ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	for x in range(-3, 5):
		for y in range(-3, 5):
			var tile := HexTileData.new()
			tile.tile_pos = Vector2i(x, y); tile.terrain = "plains"
			state.world.tiles[x * 1000 + y] = tile
	# self
	var team := TeamData.new()
	team.team_id = 0; team.tile_pos = Vector2i(0, 0); team.population = 10
	team.faction_id = 0
	state.teams[0] = team
	var leader := PersonData.new()
	leader.values = { "貪婪": 0.8, "殘忍": 0.5, "野心": 0.5 }
	# 弱 + 富 prey
	var rich_prey := TeamData.new()
	rich_prey.team_id = 1; rich_prey.tile_pos = Vector2i(2, 0); rich_prey.population = 4
	rich_prey.faction_id = 1
	rich_prey.resources = { "coin": 200, "food": 100, "material": 50 }
	rich_prey.last_tile_pos = rich_prey.tile_pos
	state.teams[1] = rich_prey
	# 同 faction
	var ally := TeamData.new()
	ally.team_id = 2; ally.tile_pos = Vector2i(1, 0); ally.population = 3
	ally.faction_id = 0
	state.teams[2] = ally
	state.team_discovered[0] = [1, 2]
	var prey_id = FactionAiSystem.find_prosperity_prey(state, team, leader)
	assert(prey_id == 1, "應選 1 (rich_prey)，實際=%d" % prey_id)
	print("Prosperity Task2 OK")
```

- [ ] **Step 2: 加函數**

```gdscript
static func find_prosperity_prey(state: WorldState, team: TeamData, leader: PersonData) -> int:
	var greed: float = float(leader.values.get("貪婪", 0.5))
	var cruelty: float = float(leader.values.get("殘忍", 0.5))
	var ambition: float = float(leader.values.get("野心", 0.5))
	var best_id: int = -1
	var best_score: float = 0.0
	for tid in state.team_discovered.get(team.team_id, []):
		if tid == team.team_id: continue
		var prey: TeamData = state.teams.get(tid)
		if prey == null: continue
		if prey.faction_id != -1 and prey.faction_id == team.faction_id: continue
		var catch_result: Dictionary = PathSystem.estimate_catch_up(state, team, tid)
		if not catch_result.reachable: continue
		var richness: float = (float(prey.resources.get("coin", 0))
			+ float(prey.resources.get("food", 0))
			+ float(prey.resources.get("material", 0))) / 100.0
		var weakness: float = clampf(
			1.0 - float(prey.population) / maxf(float(team.population), 1.0),
			0.0, 1.0)
		var border: float = 1.0 if _is_border_adjacent(team, prey) else 0.3
		var eta_days: float = maxf(float(catch_result.eta) / 240.0, 1.0)
		var score: float = (richness * greed + weakness * cruelty + border * ambition) / eta_days
		if score > best_score:
			best_score = score
			best_id = tid
	return best_id

static func _is_border_adjacent(attacker: TeamData, prey: TeamData) -> bool:
	var dx: int = prey.tile_pos.x - attacker.tile_pos.x
	var dy: int = prey.tile_pos.y - attacker.tile_pos.y
	return (abs(dx) + abs(dx + dy) + abs(dy)) / 2 <= 2
```

- [ ] **Step 3: 跑 + Commit**

```powershell
git add scripts/simulation/faction_ai_system.gd scripts/debug/headless_test.gd
git commit -m "feat(faction_ai): find_prosperity_prey selector (Task 2)"
```

---

## Task 3: `_evaluate_prosperity_attack` 入口

**Files:**
- Modify: `scripts/simulation/faction_ai_system.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 測試**

```gdscript
func _test_evaluate_prosperity_trigger() -> void:
	print("--- Prosperity Task3: 評估 trigger TASK_ATTACK ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	for x in range(-3, 5):
		for y in range(-3, 5):
			var tile := HexTileData.new()
			tile.tile_pos = Vector2i(x, y); tile.terrain = "plains"
			state.world.tiles[x * 1000 + y] = tile
	var team := TeamData.new()
	team.team_id = 0; team.tile_pos = Vector2i(0, 0); team.population = 15
	team.faction_id = 0; team.anon_combat_skill = 0.7
	team.resources = { "food": 200, "weapon_melee_low": 15 }
	team.current_task = TeamData.TASK_IDLE
	state.teams[0] = team
	var leader := PersonData.new()
	leader.person_id = 100
	leader.values = { "野心": 0.9, "好戰": 0.8, "信義": 0.1, "殘忍": 0.7, "貪婪": 0.6, "慎重": 0.3 }
	state.persons[100] = leader
	team.leader_id = 100
	var prey := TeamData.new()
	prey.team_id = 1; prey.tile_pos = Vector2i(2, 0); prey.population = 4
	prey.faction_id = 1
	prey.resources = { "coin": 200, "food": 100 }
	prey.last_tile_pos = prey.tile_pos
	state.teams[1] = prey
	state.team_discovered[0] = [1]
	var fas = FactionAiSystem.new()
	fas._evaluate_prosperity_attack(state, team)
	assert(team.current_task == TeamData.TASK_ATTACK, "應 TASK_ATTACK，實際=%s" % team.current_task)
	assert(team.combat_target == 1, "應 combat_target=1，實際=%d" % team.combat_target)
	print("Prosperity Task3 OK")
```

- [ ] **Step 2: 加入口函數**

```gdscript
func _evaluate_prosperity_attack(state: WorldState, team: TeamData) -> void:
	if team.leader_id == state.player_id and state.player_id != -1: return
	if team.combat_target != -1: return
	if team.current_task != TeamData.TASK_IDLE: return
	if team.current_task in SURVIVAL_TASKS: return
	var leader: PersonData = state.persons.get(team.leader_id)
	if leader == null: return

	var score: float = calc_attack_score(team, leader)
	if score < ATTACK_SCORE_THRESHOLD: return

	var threshold: float = calc_readiness_threshold(team, leader)
	var readiness: float = calc_readiness(team)
	if readiness < threshold: return

	var prey_id: int = find_prosperity_prey(state, team, leader)
	if prey_id == -1: return

	team.current_task = TeamData.TASK_ATTACK
	team.move_target = state.teams[prey_id].tile_pos
	team.combat_target = prey_id
	if state.has_method("log_event"):
		state.log_event("ProsperityAttack", {
			"attacker": team.team_id, "prey": prey_id, "score": score
		})
```

- [ ] **Step 3: 反案 testcase**

```gdscript
func _test_prosperity_low_ambition_skip() -> void:
	# 野心 0.1 + 好戰 0.1 → score < 0.3 → 不 trigger
	# ...
	print("Prosperity Task3b OK")

func _test_prosperity_low_readiness_skip() -> void:
	# pop=2, skill=0.1, food=10 → readiness 太低
	# ...
	print("Prosperity Task3c OK")

func _test_prosperity_same_faction_skip() -> void:
	# 唯一 prey 同 faction → 不 trigger
	# ...
	print("Prosperity Task3d OK")
```

- [ ] **Step 4: 跑 + Commit**

```powershell
git add scripts/simulation/faction_ai_system.gd scripts/debug/headless_test.gd
git commit -m "feat(faction_ai): _evaluate_prosperity_attack entry (Task 3)"
```

---

## Task 4: Cadence + 事件 trigger 入 sim_runner

**Files:**
- Modify: `scripts/simulation/sim_runner.gd`
- Modify: `scripts/data/team_data.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: TeamData 加 cooldown 欄位**

```gdscript
var prosperity_eval_next_tick: int = 0   # 下次 prosperity 評估 tick
```

- [ ] **Step 2: sim_runner 加 cadence 評估**

找 sim_runner 既有 faction_ai cadence 區段（grep `faction_ai_system`），加：

```gdscript
# Prosperity attack cadence per leader_team
for tid in state.teams:
	var team: TeamData = state.teams[tid]
	if not team.is_faction_leader: continue
	if state.world.current_tick < team.prosperity_eval_next_tick: continue
	_faction_ai_system._evaluate_prosperity_attack(state, team)
	var cad: int = FactionAiSystem.PROSPERITY_CADENCE
	if "軍隊" in team.tags:
		cad = FactionAiSystem.PROSPERITY_CADENCE_MILITARY
	team.prosperity_eval_next_tick = state.world.current_tick + cad
```

- [ ] **Step 3: 事件 trigger 重評**

加 hook 處理：
- (a) `_on_pop_drop` 鄰 team pop 暴跌 > 30%
- (b) `_on_team_discovered` 新發現
- (d) `_on_leader_values_changed` reaction 改性格

實作：
```gdscript
func mark_prosperity_recheck(state: WorldState, observer_team_id: int) -> void:
	var t: TeamData = state.teams.get(observer_team_id)
	if t != null:
		t.prosperity_eval_next_tick = state.world.current_tick   # 立即重評
```

在 vision_system / reaction_system / 相關事件 call point 加 `mark_prosperity_recheck(state, observer_id)`。

- [ ] **Step 4: 整合 test**

```gdscript
func _test_prosperity_cadence() -> void:
	# tick 0 evaluate → next_tick = 720
	# tick 360 evaluate → 跳過
	# tick 720 evaluate → 跑
	# ...
	print("Prosperity Task4 OK")
```

- [ ] **Step 5: 跑 + Commit**

```powershell
git add scripts/simulation/sim_runner.gd scripts/data/team_data.gd scripts/debug/headless_test.gd
git commit -m "feat(sim_runner): prosperity cadence + event triggers (Task 4)"
```

---

## Task 5: B 分支 — `_trigger_survival` Path 1 修改

**Files:**
- Modify: `scripts/simulation/faction_ai_system.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 測試**

```gdscript
func _test_survival_b_branch_far_outpost_loot() -> void:
	print("--- Prosperity Task5: B 分支 遠 outpost + 殘忍 → 掠 ---")
	# Setup: own outpost ETA > 5 日 + 殘忍 0.8 + 有 weak prey 近
	# Expected: current_task = TASK_LOOT
	# ...
	print("Prosperity Task5 OK")

func _test_survival_b_branch_near_outpost_return() -> void:
	# outpost ETA < 5 日 → 仍走 return_home
	# ...
	print("Prosperity Task5b OK")
```

- [ ] **Step 2: 改 `_trigger_survival` Path 1**

找原 Path 1 (`scripts/simulation/faction_ai_system.gd:1124`)，改：

```gdscript
# Path 1: 有 own outpost
var own_pos: Vector2i = _find_own_outpost(state, team)
if own_pos != Vector2i(-1, -1):
	var own_eta_ticks: int = _estimate_eta_to(state, team, own_pos)
	var own_eta_days: float = float(own_eta_ticks) / 240.0
	var ferocity_ok: bool = (
		float(leader.values.get("殘忍", 0.5)) > 0.5
		or float(leader.values.get("好戰", 0.5)) > 0.6
	)
	if own_eta_days > 5.0 and ferocity_ok:
		var prey_id: int = _find_weakest_prey(state, team)
		if prey_id != -1:
			team.current_task = TeamData.TASK_LOOT
			team.move_target = state.teams[prey_id].tile_pos
			team.combat_target = prey_id
			return
	if severity == "warning" and not _should_abandon_current_task(team, own_pos):
		team.previous_task = ""
		return
	team.current_task = "return_home"
	team.move_target = own_pos
	return
```

加 helper：

```gdscript
func _estimate_eta_to(state: WorldState, team: TeamData, target: Vector2i) -> int:
	var path: Dictionary = PathSystem.find_path(state, team.tile_pos, target)
	if path.path.is_empty(): return 9999999
	return PathSystem.eta_ticks(team, path.cost)
```

- [ ] **Step 3: 跑 + Commit**

```powershell
git add scripts/simulation/faction_ai_system.gd scripts/debug/headless_test.gd
git commit -m "feat(faction_ai): survival B branch (far outpost + 殘忍 → loot) (Task 5)"
```

---

## Task 6: 攻佔 outpost 居民處置（屠/放棄/強佔）

**Files:**
- Modify: `scripts/simulation/encounter_system.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: grep 既有 encounter end callback**

```powershell
grep -n "_resolve_encounter_end\|outpost_owner" scripts/simulation/encounter_system.gd
```

確認既有 5 路 ownership 處理位置。

- [ ] **Step 2: 測試**

```gdscript
func _test_occupy_resident_accept() -> void:
	print("--- Prosperity Task6: 居民接受 → outpost 易主 ---")
	# rep 高 + caution 低 → accept
	# ...

func _test_occupy_massacre() -> void:
	# 殘忍 0.8 leader + 拒投 → 屠
	# ...

func _test_occupy_abandon() -> void:
	# 義氣 0.7 leader + 拒投 → 放棄
	# ...

func _test_occupy_force() -> void:
	# 野心 0.8 + 慎重 0.6 leader + 拒投 → 強佔 pop -20%
	# ...
	print("Prosperity Task6 OK")
```

- [ ] **Step 3: 加 callback + 3 helper**

在 encounter end 既有 5 路後加：

```gdscript
func _process_occupied_residents(state: WorldState, attacker_id: int, prey_id: int) -> void:
	var attacker: TeamData = state.teams.get(attacker_id)
	var prey: TeamData = state.teams.get(prey_id)
	if attacker == null or prey == null: return
	var occupied_tile: HexTileData = _find_prey_outpost(state, prey)
	if occupied_tile == null: return
	var resident: TeamData = _find_resident_team_on_tile(state, occupied_tile)
	if resident == null: return
	# 居民拒投靠判定
	var rep: float = float(resident.known_reputations.get(attacker_id, 0.5))
	var resident_leader: PersonData = state.persons.get(resident.leader_id)
	var fear: float = clampf(1.0 - rep, 0.0, 1.0)
	var caution: float = float(resident_leader.values.get("慎重", 0.5)) if resident_leader else 0.5
	var accept: bool = (fear > caution + 0.2) and rep > 0.3
	if accept:
		occupied_tile.outpost_owner = attacker_id
		state.log_event("ResidentAccept", { "attacker": attacker_id, "resident": resident.team_id })
		return
	# 攻城方 leader 個性決定
	var atk_leader: PersonData = state.persons.get(attacker.leader_id)
	if atk_leader == null:
		_abandon_occupation(state, occupied_tile); return
	var cruelty: float = float(atk_leader.values.get("殘忍", 0.5))
	var martial: float = float(atk_leader.values.get("好戰", 0.5))
	var honor: float = float(atk_leader.values.get("義氣", 0.5))
	var faith: float = float(atk_leader.values.get("信義", 0.5))
	var ambition: float = float(atk_leader.values.get("野心", 0.5))
	var caution2: float = float(atk_leader.values.get("慎重", 0.5))
	if cruelty > 0.7 or martial > 0.7:
		_massacre_residents(state, attacker, resident, occupied_tile)
	elif honor > 0.6 or faith > 0.6:
		_abandon_occupation(state, occupied_tile)
	elif ambition > 0.7 and caution2 > 0.5:
		_force_occupy(state, attacker, resident, occupied_tile)
	else:
		_abandon_occupation(state, occupied_tile)

func _massacre_residents(state, attacker, resident, tile) -> void:
	tile.outpost_owner = attacker.team_id
	for k in resident.resources:
		attacker.resources[k] = attacker.resources.get(k, 0) + resident.resources[k]
	attacker.anon_treasury += resident.population * 5.0
	state.teams.erase(resident.team_id)
	state.log_event("Massacre", { "attacker": attacker.team_id, "resident": resident.team_id })

func _abandon_occupation(state, tile) -> void:
	state.log_event("AbandonOccupation", { "tile": tile.tile_pos })

func _force_occupy(state, attacker, resident, tile) -> void:
	tile.outpost_owner = attacker.team_id
	resident.population = int(float(resident.population) * 0.8)
	state.log_event("ForceOccupy", { "attacker": attacker.team_id, "resident": resident.team_id })
```

- [ ] **Step 4: 接 encounter end**

於既有 `_resolve_encounter_end` victory branch 結束處 call `_process_occupied_residents(state, winner_id, loser_id)`。

- [ ] **Step 5: 跑 + Commit**

```powershell
git add scripts/simulation/encounter_system.gd scripts/debug/headless_test.gd
git commit -m "feat(encounter): occupy outpost resident handling (Task 6)"
```

---

## Task 7: 戰敗 reaction (AttackDefeat event)

**Files:**
- Modify: `scripts/simulation/encounter_system.gd`
- Modify: `scripts/simulation/reaction_system.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 測試**

```gdscript
func _test_attack_defeat_reaction() -> void:
	print("--- Prosperity Task7: 戰敗 reaction ---")
	# Setup attacker 戰敗, pop_loss=0.4
	# Expected: named loyalty 降, leader stress 升
	# ...
	print("Prosperity Task7 OK")
```

- [ ] **Step 2: encounter end defeat branch 加 log_event**

```gdscript
func _on_attack_defeat(state, attacker_id: int, pop_loss_ratio: float) -> void:
	var attacker: TeamData = state.teams.get(attacker_id)
	if attacker == null: return
	state.log_event("AttackDefeat", {
		"team": attacker_id, "pop_loss_ratio": pop_loss_ratio
	})
```

- [ ] **Step 3: reaction_system handler**

```gdscript
func _on_attack_defeat(state, payload: Dictionary) -> void:
	var team: TeamData = state.teams.get(int(payload["team"]))
	if team == null: return
	var leader: PersonData = state.persons.get(team.leader_id)
	if leader == null: return
	var honor: float = float(leader.values.get("義氣", 0.5))
	var faith: float = float(leader.values.get("信義", 0.5))
	var caution: float = float(leader.values.get("慎重", 0.5))
	var loyalty_delta: float = -0.1 * (honor + faith) / 2.0
	var stress_delta: float = 0.2 * caution
	if float(payload.get("pop_loss_ratio", 0)) > 0.3:
		loyalty_delta *= 2.0
		stress_delta *= 1.5
	for nm in team.named_members:
		var p: PersonData = state.persons.get(int(nm.get("person_id", -1)))
		if p == null: continue
		p.loyalty = clampf(p.loyalty + loyalty_delta, 0.0, 1.0)
	leader.stress = clampf(leader.stress + stress_delta, 0.0, 1.0)
```

接 reaction dispatcher（既有 event 分派表加 `"AttackDefeat": _on_attack_defeat`）。

- [ ] **Step 4: 跑 + Commit**

```powershell
git add scripts/simulation/encounter_system.gd scripts/simulation/reaction_system.gd scripts/debug/headless_test.gd
git commit -m "feat(reaction): AttackDefeat event handler (Task 7)"
```

---

## Task 8: 整合驗證 + handback

**Files:**
- Create: `docs/superpowers/handbacks/2026-06-10-prosperity-attack.md`

- [ ] **Step 1: 跑全測試**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/game_sim_test.gd > godot_test.log 2>&1
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/game_sim_multi.gd > godot_multi.log 2>&1
Get-Content godot_test.log -Encoding UTF8 | Select-String "ALL INVARIANTS|ProsperityAttack|encounter" | Select-Object -First 20
Get-Content godot_multi.log -Encoding UTF8 -Tail 30
```

預期：multi runner 4 config × 90 天 encounter > 0、ProsperityAttack 事件出現、無 invariant violation。

- [ ] **Step 2: 寫 handback**

`docs/superpowers/handbacks/2026-06-10-prosperity-attack.md`：

```markdown
# Hand Back: NPC Prosperity Attack

## 實作摘要

- faction_ai：calc_readiness / calc_attack_score / find_prosperity_prey / _evaluate_prosperity_attack
- sim_runner：cadence + 事件 trigger
- _trigger_survival Path 1 B 分支：遠 outpost + 殘忍/好戰 → 掠
- encounter_system：occupy outpost 屠/放棄/強佔
- reaction_system：AttackDefeat handler

## 行為變化

- 野心 leader 主動征服
- 軍隊 tag 加成（門檻 -0.1 + cadence 加倍）
- 遠 outpost 飢餓團可掠
- 攻佔後居民處置依 leader 個性
- 戰敗 named loyalty 降 + leader stress 升

## 驗證結果

- multi runner 4 config × 90 天：encounter 觸發 N 次（vs 之前 0）
- ProsperityAttack 事件出現 M 次
- 無 invariant violation
- game_sim_test ALL INVARIANTS PASSED

## 待主 session 確認

- 戰爭頻率是否合理（過頻 / 過稀）
- 個性公式參數 tune
- 多 team 聯合攻打後續
- 防守方 active 行為後續
```

- [ ] **Step 3: Commit**

```powershell
git add docs/superpowers/handbacks/2026-06-10-prosperity-attack.md
git commit -m "docs: prosperity attack handback (Task 8)"
```
