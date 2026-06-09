# Anon Tier 系統 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** anon 4 tier 系統。新 `AnonTierSystem` class + `team.anon_tiers/anon_exp` dict + 升等 + 廢 scalar。所有依賴系統 migration。

**Architecture:**
- 新 class `AnonTierSystem` 集中：屬性表、查詢、變動、升等、死亡分配
- `team.anon_tiers/anon_exp` 取代 `anon_combat_skill/anon_wage` scalar
- 既有 system 改用 API（salary/movement/combat/interaction/outpost/event_split）

**Spec:** `docs/superpowers/specs/2026-06-10-anon-tier-system-design.md`

---

## 檔案結構

| 檔案 | 變更 |
|---|---|
| `scripts/simulation/anon_tier_system.gd` | **新檔**：class_name AnonTierSystem + const + API |
| `scripts/data/team_data.gd` | 加 anon_tiers / anon_exp dict；getter for compat |
| `scripts/simulation/salary_system.gd` | wage 改用 total_wage |
| `scripts/simulation/movement_system.gd` | speed 用 tier-aware |
| `scripts/simulation/npc_combat_system.gd` | combat_skill 用 avg |
| `scripts/simulation/encounter_system.gd` | 死亡用 kill_random |
| `scripts/simulation/interaction_system.gd` | 投靠/居民化 add_anon(tier) |
| `scripts/simulation/outpost_system.gd` | 補 anon → add_anon(平民) |
| `scripts/simulation/events/event_unrest_split.gd` | transfer_proportional |
| `scripts/simulation/faction_ai_system.gd` | 廢 _update_anon_combat_skill/_update_anon_wage |
| `scripts/simulation/game_setup.gd` | config 解 anon_tiers |
| `scripts/data/team_data.gd` | 加 TASK_TRAIN 常數 |
| `scripts/simulation/training_system.gd` | **新檔**：每 tick 為 TASK_TRAIN team 加 exp |
| `scripts/simulation/sim_runner.gd` | call training_system |
| `scripts/debug/headless_test.gd` | ~16 個測試 |

## 測試命令

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --import
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/game_sim_test.gd
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/game_sim_multi.gd
```

---

## Task 1: AnonTierSystem skeleton + TeamData 欄位

**Files:**
- Create: `scripts/simulation/anon_tier_system.gd`
- Modify: `scripts/data/team_data.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 測試**

```gdscript
func _test_anon_tier_const() -> void:
	print("--- AnonTier Task1: const ---")
	assert(AnonTierSystem.TIER_ORDER.size() == 4)
	assert(AnonTierSystem.TIER_STATS["平民"]["combat"] == 0.1)
	assert(AnonTierSystem.TIER_STATS["菁英"]["speed"] == 1.0)
	assert(AnonTierSystem.PROMOTION_EXP_THRESHOLD["老兵"] == 200.0)
	assert(not AnonTierSystem.PROMOTION_EXP_THRESHOLD.has("菁英"))
	print("AnonTier Task1 OK")

func _test_team_anon_tiers_default() -> void:
	var t := TeamData.new()
	assert(t.anon_tiers["平民"] == 0)
	assert(t.anon_tiers.size() == 4)
	assert(t.anon_exp["平民"] == 0.0)
	assert(t.anon_exp.size() == 3)
	print("AnonTier Task1b OK")
```

- [ ] **Step 2: TeamData 加欄位**

```gdscript
var anon_tiers: Dictionary = {
	"平民": 0, "新兵": 0, "老兵": 0, "菁英": 0,
}
var anon_exp: Dictionary = {
	"平民": 0.0, "新兵": 0.0, "老兵": 0.0,
}
```

於 `_initialize`（或建構流程）確保預設值。

- [ ] **Step 3: AnonTierSystem const + skeleton**

```gdscript
class_name AnonTierSystem

const TIER_ORDER: Array = ["平民", "新兵", "老兵", "菁英"]

const TIER_STATS: Dictionary = {
	"平民": { "combat": 0.1, "speed": 0.7, "base_wage": 0.5 },
	"新兵": { "combat": 0.3, "speed": 0.8, "base_wage": 1.0 },
	"老兵": { "combat": 0.5, "speed": 0.9, "base_wage": 1.5 },
	"菁英": { "combat": 0.7, "speed": 1.0, "base_wage": 2.5 },
}

const PROMOTION_EXP_THRESHOLD: Dictionary = {
	"平民": 50.0,
	"新兵": 100.0,
	"老兵": 200.0,
}

const PROMOTION_COST: Dictionary = {
	"平民": { "coin": 5, "food": 10, "material": 2 },
	"新兵": { "coin": 15, "food": 20, "material": 5 },
	"老兵": { "coin": 50, "food": 50, "material": 10 },
}

const ELITE_WEAPON_REQ: String = "weapon_melee_high"

const TRAINING_CAP_THRESHOLDS: Dictionary = {
	0.0: "新兵",
	0.4: "老兵",
	0.7: "菁英",
}
```

- [ ] **Step 4: 跑 + Commit**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --import
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
git add scripts/simulation/anon_tier_system.gd scripts/data/team_data.gd scripts/debug/headless_test.gd
git commit -m "feat(anon_tier): skeleton + TeamData fields (Task 1)"
```

---

## Task 2: 查詢 API

**Files:**
- Modify: `scripts/simulation/anon_tier_system.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 測試**

```gdscript
func _test_anon_tier_queries() -> void:
	var t := TeamData.new()
	t.anon_tiers = { "平民": 5, "新兵": 3, "老兵": 2, "菁英": 0 }
	assert(AnonTierSystem.total_pop(t) == 10)
	# wage: 5*0.5 + 3*1.0 + 2*1.5 = 2.5+3+3 = 8.5（不含 tag mult）
	assert(abs(AnonTierSystem.total_wage(t) - 8.5) < 0.01)
	# avg combat: (5*0.1 + 3*0.3 + 2*0.5) / 10 = (0.5+0.9+1.0)/10 = 0.24
	assert(abs(AnonTierSystem.avg_combat_skill(t) - 0.24) < 0.01)
	# avg speed: (5*0.7 + 3*0.8 + 2*0.9) / 10 = (3.5+2.4+1.8)/10 = 0.77
	assert(abs(AnonTierSystem.avg_speed(t) - 0.77) < 0.01)
	assert(AnonTierSystem.tier_count(t, "新兵") == 3)
	print("AnonTier Task2 OK")
```

- [ ] **Step 2: API 實作**

```gdscript
static func total_pop(team: TeamData) -> int:
	var s: int = 0
	for tier in TIER_ORDER:
		s += int(team.anon_tiers.get(tier, 0))
	return s

static func total_wage(team: TeamData) -> float:
	var w: float = 0.0
	for tier in TIER_ORDER:
		w += float(team.anon_tiers.get(tier, 0)) * TIER_STATS[tier]["base_wage"]
	return w

static func avg_speed(team: TeamData) -> float:
	var total: int = total_pop(team)
	if total <= 0: return 1.0
	var s: float = 0.0
	for tier in TIER_ORDER:
		s += float(team.anon_tiers.get(tier, 0)) * TIER_STATS[tier]["speed"]
	return s / float(total)

static func avg_combat_skill(team: TeamData) -> float:
	var total: int = total_pop(team)
	if total <= 0: return 0.1
	var s: float = 0.0
	for tier in TIER_ORDER:
		s += float(team.anon_tiers.get(tier, 0)) * TIER_STATS[tier]["combat"]
	return s / float(total)

static func tier_count(team: TeamData, tier: String) -> int:
	return int(team.anon_tiers.get(tier, 0))

static func tier_breakdown(team: TeamData) -> Dictionary:
	return team.anon_tiers.duplicate()
```

- [ ] **Step 3: 跑 + Commit**

```powershell
git add scripts/simulation/anon_tier_system.gd scripts/debug/headless_test.gd
git commit -m "feat(anon_tier): query API (Task 2)"
```

---

## Task 3: 變動 API (add/remove/add_exp/kill_random/transfer)

**Files:**
- Modify: `scripts/simulation/anon_tier_system.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 測試**

```gdscript
func _test_add_remove_anon() -> void:
	var t := TeamData.new()
	AnonTierSystem.add_anon(t, "新兵", 5)
	assert(t.anon_tiers["新兵"] == 5)
	var removed: int = AnonTierSystem.remove_anon(t, "新兵", 3)
	assert(removed == 3 and t.anon_tiers["新兵"] == 2)
	var removed2: int = AnonTierSystem.remove_anon(t, "新兵", 10)
	assert(removed2 == 2 and t.anon_tiers["新兵"] == 0)
	print("AnonTier Task3a OK")

func _test_add_exp() -> void:
	var t := TeamData.new()
	AnonTierSystem.add_exp(t, "平民", 30.0)
	assert(abs(t.anon_exp["平民"] - 30.0) < 0.01)
	print("AnonTier Task3b OK")

func _test_kill_random_proportional() -> void:
	var t := TeamData.new()
	t.anon_tiers = { "平民": 50, "新兵": 30, "老兵": 20, "菁英": 0 }
	var killed = AnonTierSystem.kill_random(t, 10, "combat")
	assert(killed["平民"] + killed["新兵"] + killed["老兵"] + killed["菁英"] == 10)
	assert(AnonTierSystem.total_pop(t) == 90)
	# 機率上平民死最多
	print("AnonTier Task3c OK (killed=%s)" % str(killed))

func _test_transfer_proportional() -> void:
	var src := TeamData.new()
	var dst := TeamData.new()
	src.anon_tiers = { "平民": 50, "新兵": 30, "老兵": 20, "菁英": 0 }
	var moved = AnonTierSystem.transfer_proportional(src, dst, 20)
	assert(AnonTierSystem.total_pop(src) == 80)
	assert(AnonTierSystem.total_pop(dst) == 20)
	# 各 tier 按比例
	assert(moved["平民"] + moved["新兵"] + moved["老兵"] == 20)
	print("AnonTier Task3d OK (moved=%s)" % str(moved))
```

- [ ] **Step 2: API 實作**

```gdscript
static func add_anon(team: TeamData, tier: String, count: int) -> void:
	if count <= 0: return
	if not team.anon_tiers.has(tier): return
	team.anon_tiers[tier] = int(team.anon_tiers[tier]) + count

static func remove_anon(team: TeamData, tier: String, count: int) -> int:
	if count <= 0: return 0
	if not team.anon_tiers.has(tier): return 0
	var cur: int = int(team.anon_tiers[tier])
	var removed: int = mini(cur, count)
	team.anon_tiers[tier] = cur - removed
	return removed

static func add_exp(team: TeamData, tier: String, exp: float) -> void:
	if tier == "菁英": return    # 無下一階
	if not team.anon_exp.has(tier): return
	team.anon_exp[tier] = float(team.anon_exp[tier]) + exp

static func kill_random(team: TeamData, count: int, source: String) -> Dictionary:
	var killed: Dictionary = {}
	for tier in TIER_ORDER: killed[tier] = 0
	for _i in range(count):
		var total: int = total_pop(team)
		if total <= 0: break
		var roll: int = randi() % total
		var acc: int = 0
		for tier in TIER_ORDER:
			acc += int(team.anon_tiers.get(tier, 0))
			if roll < acc:
				team.anon_tiers[tier] -= 1
				killed[tier] += 1
				break
	return killed

static func transfer_proportional(from: TeamData, to: TeamData, count: int) -> Dictionary:
	var moved: Dictionary = {}
	for tier in TIER_ORDER: moved[tier] = 0
	var total: int = total_pop(from)
	if total <= 0 or count <= 0: return moved
	var actual: int = mini(count, total)
	# 按比例分配
	var remaining: int = actual
	for tier in TIER_ORDER:
		if remaining <= 0: break
		var n: int = int(team_from_tier_proportional(from, tier, actual, total))
		n = mini(n, int(from.anon_tiers.get(tier, 0)))
		n = mini(n, remaining)
		moved[tier] = n
		from.anon_tiers[tier] = int(from.anon_tiers[tier]) - n
		to.anon_tiers[tier] = int(to.anon_tiers.get(tier, 0)) + n
		remaining -= n
	# 處理 round 後剩餘
	if remaining > 0:
		for tier in TIER_ORDER:
			if remaining <= 0: break
			var avail: int = int(from.anon_tiers.get(tier, 0))
			if avail > 0:
				var take: int = mini(avail, remaining)
				moved[tier] += take
				from.anon_tiers[tier] -= take
				to.anon_tiers[tier] = int(to.anon_tiers.get(tier, 0)) + take
				remaining -= take
	return moved

static func team_from_tier_proportional(from: TeamData, tier: String, target: int, total: int) -> int:
	return int(round(float(from.anon_tiers.get(tier, 0)) / float(total) * float(target)))
```

- [ ] **Step 3: 跑 + Commit**

```powershell
git add scripts/simulation/anon_tier_system.gd scripts/debug/headless_test.gd
git commit -m "feat(anon_tier): mutation API (add/remove/exp/kill/transfer) (Task 3)"
```

---

## Task 4: try_promote（含 leader skill cap + cost + weapon req）

**Files:**
- Modify: `scripts/simulation/anon_tier_system.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 測試**

```gdscript
func _test_promote_success() -> void:
	var state := WorldState.new()
	var team := TeamData.new()
	team.anon_tiers = { "平民": 10, "新兵": 0, "老兵": 0, "菁英": 0 }
	team.anon_exp["平民"] = 50.0
	team.resources = { "coin": 100, "food": 200, "material": 50 }
	var leader := PersonData.new()
	leader.person_id = 1
	leader.skills = { "戰術": 0.5 }
	state.persons[1] = leader
	team.leader_id = 1
	var n = AnonTierSystem.try_promote(state, team, "平民", 5)
	assert(n == 5, "預期升 5，實際=%d" % n)
	assert(team.anon_tiers["平民"] == 5)
	assert(team.anon_tiers["新兵"] == 5)
	assert(team.resources["coin"] == 100 - 25)  # 5×5
	assert(team.resources["food"] == 200 - 50)  # 5×10
	assert(team.resources["material"] == 50 - 10)  # 5×2
	# exp 扣減
	assert(team.anon_exp["平民"] == 0.0)
	print("AnonTier Task4a OK")

func _test_promote_insufficient_exp() -> void:
	# anon_exp["平民"] = 30 < 50 → 失敗
	# ...

func _test_promote_insufficient_resources() -> void:
	# coin 不夠 → 失敗，不部分扣
	# ...

func _test_promote_elite_requires_weapon() -> void:
	# 升菁英但 weapon_melee_high 不夠 → 失敗
	# ...

func _test_promote_leader_skill_cap() -> void:
	# leader 戰術 0.3 → 不可升老兵
	# ...
	print("AnonTier Task4 OK")
```

- [ ] **Step 2: API**

```gdscript
static func try_promote(state: WorldState, team: TeamData, from_tier: String, count: int) -> int:
	if count <= 0: return 0
	if from_tier == "菁英": return 0
	# 找 to_tier
	var idx: int = TIER_ORDER.find(from_tier)
	if idx == -1 or idx + 1 >= TIER_ORDER.size(): return 0
	var to_tier: String = TIER_ORDER[idx + 1]
	# 1. count
	if int(team.anon_tiers.get(from_tier, 0)) < count: return 0
	# 2. exp
	var threshold: float = PROMOTION_EXP_THRESHOLD[from_tier]
	if float(team.anon_exp.get(from_tier, 0.0)) < threshold * float(count): return 0
	# 3. 物資
	var cost: Dictionary = PROMOTION_COST[from_tier]
	for res in cost:
		if float(team.resources.get(res, 0)) < float(cost[res]) * float(count):
			return 0
	# 4. leader skill cap
	var leader: PersonData = state.persons.get(team.leader_id)
	if leader != null:
		var tact: float = float(leader.skills.get("戰術", 0.0))
		var cap: String = _training_cap(tact)
		if TIER_ORDER.find(to_tier) > TIER_ORDER.find(cap): return 0
	# 5. 菁英武器
	if to_tier == "菁英":
		var future_elite: int = int(team.anon_tiers.get("菁英", 0)) + count
		if int(team.resources.get(ELITE_WEAPON_REQ, 0)) < future_elite: return 0
	# 全過 → 執行
	for res in cost:
		team.resources[res] = float(team.resources[res]) - float(cost[res]) * float(count)
	team.anon_tiers[from_tier] = int(team.anon_tiers[from_tier]) - count
	team.anon_tiers[to_tier] = int(team.anon_tiers.get(to_tier, 0)) + count
	team.anon_exp[from_tier] = float(team.anon_exp[from_tier]) - threshold * float(count)
	return count

static func _training_cap(tact: float) -> String:
	var cap: String = "新兵"
	if tact > 0.4: cap = "老兵"
	if tact > 0.7: cap = "菁英"
	return cap
```

- [ ] **Step 3: 跑 + Commit**

```powershell
git add scripts/simulation/anon_tier_system.gd scripts/debug/headless_test.gd
git commit -m "feat(anon_tier): try_promote with cap+cost+weapon (Task 4)"
```

---

## Task 5: 訓練 task + per-tick exp

**Files:**
- Create: `scripts/simulation/training_system.gd`
- Modify: `scripts/data/team_data.gd`（const TASK_TRAIN）
- Modify: `scripts/simulation/sim_runner.gd`（call）
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 加 const + 測試**

`team_data.gd`：
```gdscript
const TASK_TRAIN := "訓練"
```

測試：
```gdscript
func _test_training_adds_exp() -> void:
	var state := WorldState.new()
	var team := TeamData.new()
	team.current_task = TeamData.TASK_TRAIN
	team.anon_tiers["平民"] = 10
	var leader := PersonData.new(); leader.skills = { "戰術": 0.5 }
	leader.person_id = 1
	state.persons[1] = leader
	team.leader_id = 1
	var ts = TrainingSystem.new()
	ts.process(state, [team.team_id])
	# 速率 = leader 戰術 * count
	# 每 tick exp += 0.5 × 10 = 5.0
	assert(abs(team.anon_exp["平民"] - 5.0) < 0.01)
	print("AnonTier Task5 OK")
```

- [ ] **Step 2: training_system.gd**

```gdscript
class_name TrainingSystem

const EXP_RATE_MULT: float = 1.0   # global tunable

func process(state: WorldState, team_ids: Array) -> void:
	for tid in team_ids:
		var team: TeamData = state.teams.get(tid)
		if team == null: continue
		if team.current_task != TeamData.TASK_TRAIN: continue
		var leader: PersonData = state.persons.get(team.leader_id)
		if leader == null: continue
		var tact: float = float(leader.skills.get("戰術", 0.0))
		if tact <= 0.0: continue
		# 對每 tier 加 exp（除菁英），依該 tier count × tact
		for tier in AnonTierSystem.TIER_ORDER:
			if tier == "菁英": continue
			var n: int = int(team.anon_tiers.get(tier, 0))
			if n <= 0: continue
			AnonTierSystem.add_exp(team, tier, tact * float(n) * EXP_RATE_MULT)
```

- [ ] **Step 3: sim_runner call**

`sim_runner.gd` advance_tick 內加：

```gdscript
_training_system.process(state, team_ids)
```

於 movement 前（與 task evaluation 同階段）。

- [ ] **Step 4: 跑 + Commit**

```powershell
git add scripts/simulation/training_system.gd scripts/data/team_data.gd scripts/simulation/sim_runner.gd scripts/debug/headless_test.gd
git commit -m "feat(anon_tier): training task + per-tick exp (Task 5)"
```

---

## Task 6: 戰鬥存活 exp（encounter end callback）

**Files:**
- Modify: `scripts/simulation/encounter_system.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 測試**

```gdscript
func _test_combat_survivor_exp() -> void:
	# encounter end with team A 勝 / 倖存
	# Expected: A 每 tier exp +5 + 勝方 bonus +5
	# ...
```

- [ ] **Step 2: 改 encounter end**

於 `_resolve_encounter_end` 既有勝/敗分配後加：

```gdscript
const EXP_SURVIVOR: float = 5.0
const EXP_VICTORY_BONUS: float = 5.0

# 假設 winner_id / loser_id 已知
for tier in AnonTierSystem.TIER_ORDER:
	if tier == "菁英": continue
	var winner_n: int = AnonTierSystem.tier_count(winner, tier)
	if winner_n > 0:
		AnonTierSystem.add_exp(winner, tier, EXP_SURVIVOR + EXP_VICTORY_BONUS)
	var loser_n: int = AnonTierSystem.tier_count(loser, tier)
	if loser_n > 0:
		AnonTierSystem.add_exp(loser, tier, EXP_SURVIVOR)
```

- [ ] **Step 3: 跑 + Commit**

```powershell
git add scripts/simulation/encounter_system.gd scripts/debug/headless_test.gd
git commit -m "feat(anon_tier): combat survival exp on encounter end (Task 6)"
```

---

## Task 7: salary + movement + npc_combat migration

**Files:**
- Modify: `scripts/simulation/salary_system.gd`
- Modify: `scripts/simulation/movement_system.gd`
- Modify: `scripts/simulation/npc_combat_system.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: salary 改**

找原 `team.anon_wage × anon_count`，改：

```gdscript
var anon_total: float = AnonTierSystem.total_wage(team)
team.anon_treasury += anon_total
```

- [ ] **Step 2: movement `_compute_team_speed` 改**

```gdscript
func _compute_team_speed(state: WorldState, team: TeamData) -> float:
	var total_speed: float = 0.0
	var total_count: int = 0
	var named_ids: Array = team.named_members.duplicate()
	if team.leader_id != -1:
		named_ids.append(team.leader_id)
	for pid in named_ids:
		var p = state.persons.get(pid)
		if p != null:
			total_speed += p.get_effective_speed() * NAMED_WEIGHT
			total_count += NAMED_WEIGHT
	for tier in AnonTierSystem.TIER_ORDER:
		var n: int = int(team.anon_tiers.get(tier, 0))
		if n > 0:
			total_speed += float(n) * AnonTierSystem.TIER_STATS[tier]["speed"]
			total_count += n
	total_speed += float(team.wounded) * 0.5
	total_count += team.wounded
	if total_count == 0: return 1.0
	return total_speed / float(total_count)
```

- [ ] **Step 3: npc_combat 改**

grep `anon_combat_skill`，改用 `AnonTierSystem.avg_combat_skill(team)`：

```gdscript
var skill: float = AnonTierSystem.avg_combat_skill(team)
```

- [ ] **Step 4: 跑 game_sim_test 無 regression**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/game_sim_test.gd > godot_test.log 2>&1
Get-Content godot_test.log -Encoding UTF8 | Select-String "ALL INVARIANTS|FAIL|ERROR" | Select-Object -First 5
```

- [ ] **Step 5: Commit**

```powershell
git add scripts/simulation/salary_system.gd scripts/simulation/movement_system.gd scripts/simulation/npc_combat_system.gd scripts/debug/headless_test.gd
git commit -m "feat(anon_tier): salary/movement/combat migration (Task 7)"
```

---

## Task 8: encounter / interaction / outpost / event_split migration

**Files:**
- Modify: `scripts/simulation/encounter_system.gd`
- Modify: `scripts/simulation/interaction_system.gd`
- Modify: `scripts/simulation/outpost_system.gd`
- Modify: `scripts/simulation/events/event_unrest_split.gd`

- [ ] **Step 1: encounter 死亡用 kill_random**

grep encounter `population -=` 或類似，改：

```gdscript
AnonTierSystem.kill_random(team, count, "combat")
```

- [ ] **Step 2: interaction 投靠/居民化**

grep `team.population +=` 投靠情境，改：

```gdscript
# 投靠 / 居民化 / 合併：將來源 team 的 tier 結構轉入
AnonTierSystem.transfer_proportional(from_team, to_team, count)
```

- [ ] **Step 3: outpost 補 anon**

grep `outpost_system` 補 anon 點（生育 / 新人加入），改：

```gdscript
AnonTierSystem.add_anon(team, "平民", n)
```

- [ ] **Step 4: event_unrest_split**

```gdscript
AnonTierSystem.transfer_proportional(original_team, new_team, split_count)
```

- [ ] **Step 5: 跑 + Commit**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/game_sim_test.gd > godot_test.log 2>&1
git add scripts/simulation/encounter_system.gd scripts/simulation/interaction_system.gd scripts/simulation/outpost_system.gd scripts/simulation/events/event_unrest_split.gd
git commit -m "feat(anon_tier): encounter/interaction/outpost/split migration (Task 8)"
```

---

## Task 9: 廢 faction_ai._update_anon_combat_skill/_update_anon_wage

**Files:**
- Modify: `scripts/simulation/faction_ai_system.gd`

- [ ] **Step 1: 刪函數 + call**

grep `_update_anon_combat_skill\|_update_anon_wage`，刪定義 + 所有 call。`anon_combat_skill` 既然是 computed（透過 AnonTierSystem.avg_combat_skill），不再需要主動更新。

- [ ] **Step 2: 跑驗證 + Commit**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
git add scripts/simulation/faction_ai_system.gd
git commit -m "refactor(faction_ai): drop _update_anon_combat_skill/wage (computed now) (Task 9)"
```

---

## Task 10: game_setup config parsing + 整合 + handback

**Files:**
- Modify: `scripts/simulation/game_setup.gd`
- Create: `docs/superpowers/handbacks/2026-06-10-anon-tier-system.md`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: config parsing**

`game_setup.gd` 解析 config team：

```gdscript
# 讀 t_cfg["anon_tiers"]，若存在 → set team.anon_tiers
var at: Dictionary = t_cfg.get("anon_tiers", {})
if at.is_empty():
	# Fallback: 全部進平民
	team.anon_tiers["平民"] = team.population - team.named_members.size() - team.wounded
else:
	for tier in AnonTierSystem.TIER_ORDER:
		team.anon_tiers[tier] = int(at.get(tier, 0))
```

- [ ] **Step 2: 跑全測試 + multi**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --import
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/game_sim_test.gd > godot_test.log 2>&1
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/game_sim_multi.gd > godot_multi.log 2>&1
Get-Content godot_test.log -Encoding UTF8 | Select-String "ALL INVARIANTS|FAIL|ERROR" | Select-Object -First 5
Get-Content godot_multi.log -Encoding UTF8 -Tail 30
```

- [ ] **Step 3: handback**

`docs/superpowers/handbacks/2026-06-10-anon-tier-system.md`：

```markdown
# Hand Back: Anon Tier System

## 實作摘要

- AnonTierSystem 新檔：const + 查詢 + 變動 + 升等 API
- TeamData：anon_tiers / anon_exp dict + computed getter
- TrainingSystem 新檔：每 tick exp 累積
- TASK_TRAIN 常數
- 廢 faction_ai._update_anon_combat_skill/wage
- 既有 salary/movement/npc_combat/encounter/interaction/outpost/event_split 全 migrate

## 行為變化

- team 之間有 tier 質量差異
- leader 戰術 skill 影響團隊養成（高戰術可訓菁英）
- 戰鬥死亡 weighted random tier
- 訓練 task 持續累積 exp 直到升等門檻
- 升等需 coin + food + material（不消耗武器，菁英需擁有 high）

## 驗證結果

- headless_test：N/N 過
- game_sim_test：ALL INVARIANTS PASSED
- game_sim_multi 4 config × 90 天：tier 動態變化、無 invariant violation

## 連動風險

- API 破壞性改動，所有 salary/movement/combat call 點都改
- 升等 magic number 待 tune
- config migration：舊 config 無 anon_tiers 自動 fallback 平民

## 待主 session 確認

- TIER_STATS 屬性平衡
- 升等 exp/cost 平衡
- 訓練速率公式
- named 升階機制（從 anon 抽）另 spec
```

- [ ] **Step 4: Commit**

```powershell
git add scripts/simulation/game_setup.gd docs/superpowers/handbacks/2026-06-10-anon-tier-system.md
git commit -m "feat(anon_tier): game_setup config + handback (Task 10)"
```
