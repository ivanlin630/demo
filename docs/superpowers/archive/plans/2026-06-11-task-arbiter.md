# Task Arbiter Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task.

**Goal:** task 優先權仲裁：新 `TaskArbiter`（try_set / release / transition + 抗命/壓抑）+ 60 處 `current_task =` 寫入點 migration（9 檔）。驗收：逃跑↔乞食 ping-pong 30,478 → < 1,000。

**Architecture:**
- 新檔 `scripts/simulation/task_arbiter.gd`（static class）
- `team.task_priority` 新欄位
- 9 檔 60 處寫入點分 4 批 migration（faction_ai 34 處最大）
- 抗命窗口：50 挑戰玩家 60 → leader 個性確定性判定；壓抑 → stress/unrest

**Spec:** `docs/superpowers/specs/2026-06-11-task-arbiter-design.md`

**Verified facts:**
- class names：`TaskArbiter`（新）/ `FactionAISystem` / `InteractionSystem` / `OutpostSystem` / `ReactionSystem` / `StrategicAiSystem` / `SubteamSystem`
- `PersonData.id`（非 person_id）；`values` dict；`loyalty` / `stress` float
- `TeamData.TASK_IDLE = "idle"`；`unrest_turns: int`；無 `task_priority`（需加）
- 寫入點分布：faction_ai 34 / outpost 9 / interaction 8 / player_command 3 / reaction 2 / strategic 1 / subteam 1 / population 1 / sim_runner 1
- 既有測試跑法：`.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`

---

## 檔案結構

| 檔案 | 變更 |
|---|---|
| `scripts/simulation/task_arbiter.gd` | **新檔**：const + try_set / release / transition / _defiance_check |
| `scripts/data/team_data.gd` | 加 `task_priority: int = 0` |
| 9 個系統檔 | 60 處寫入點 migration |
| `scripts/debug/headless_test.gd` | ~15 測試 |

## Migration 對映表（給每批 task 用）

| 寫入情境 | 改為 |
|---|---|
| 開新任務（survival 觸發）| `TaskArbiter.try_set(state, team, task, mt, TaskArbiter.PRIO_SURVIVAL, "survival")` |
| 開新任務（threat/起義/bridge 恐慌）| `... PRIO_THREAT ...` |
| 玩家命令 | `... PRIO_PLAYER ...` |
| AI 派遣（貿易/安頓/建設/prosperity/偵查/信使/徵收/外交/護衛）| `... PRIO_DISPATCH ...` |
| faction goal 攻擊傾向 | `... PRIO_FACTION ...` |
| 任務完成 / 取消 / timeout / stuck 釋放 | `TaskArbiter.release(team)` |
| 就地轉換（安頓→生產 / settle）| `TaskArbiter.transition(team, task, TaskArbiter.PRIO_AMBIENT)` |
| 新 team 建立時初始 task | 直接賦值可留，但同時設 `task_priority`（dispatch 出的 = PRIO_DISPATCH；overflow 流亡 idle = 0）|

**規則：try_set 回 false 時，呼叫端不得執行配套副作用**（不設 prosperity_target_id / order_target_id / move 等）。改寫時把配套欄位設定移到 `if TaskArbiter.try_set(...):` 內。

---

## Task 1: TaskArbiter 新檔 + 欄位 + 單元測試

**Files:**
- Create: `scripts/simulation/task_arbiter.gd`
- Modify: `scripts/data/team_data.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 失敗測試**

```gdscript
func _test_arbiter_basic() -> void:
	print("--- Arbiter Task1a: try_set 高低層 ---")
	var state := WorldState.new(); state.world = WorldData.new()
	var t := TeamData.new(); t.team_id = 0
	state.teams[0] = t
	assert(t.task_priority == 0)
	# idle 任何層可寫
	assert(TaskArbiter.try_set(state, t, "貿易", Vector2i(1, 1), TaskArbiter.PRIO_DISPATCH))
	assert(t.current_task == "貿易" and t.task_priority == 50)
	# 低蓋高 ✗
	assert(not TaskArbiter.try_set(state, t, "攻擊", Vector2i(2, 2), TaskArbiter.PRIO_FACTION))
	# 同層 ✗
	assert(not TaskArbiter.try_set(state, t, "攻擊", Vector2i(2, 2), TaskArbiter.PRIO_DISPATCH))
	# 高蓋低 ✓
	assert(TaskArbiter.try_set(state, t, "乞食", Vector2i(3, 3), TaskArbiter.PRIO_SURVIVAL))
	assert(t.task_priority == 80)
	print("Arbiter Task1a OK")

func _test_arbiter_combat_lock() -> void:
	var state := WorldState.new(); state.world = WorldData.new()
	var t := TeamData.new(); t.team_id = 0; t.combat_target = 5
	state.teams[0] = t
	assert(not TaskArbiter.try_set(state, t, "逃跑", Vector2i(1, 1), TaskArbiter.PRIO_SURVIVAL))
	print("Arbiter Task1b OK")

func _test_arbiter_release_transition() -> void:
	var state := WorldState.new(); state.world = WorldData.new()
	var t := TeamData.new(); t.team_id = 0
	state.teams[0] = t
	TaskArbiter.try_set(state, t, "安頓", Vector2i(1, 1), TaskArbiter.PRIO_DISPATCH)
	TaskArbiter.transition(t, "生產", TaskArbiter.PRIO_AMBIENT)
	assert(t.current_task == "生產" and t.task_priority == 10)
	TaskArbiter.release(t)
	assert(t.current_task == TeamData.TASK_IDLE and t.task_priority == 0)
	assert(t.move_target == Vector2i(-1, -1))
	print("Arbiter Task1c OK")

func _test_arbiter_defiance() -> void:
	print("--- Arbiter Task1d: 抗命/壓抑 ---")
	var state := WorldState.new(); state.world = WorldData.new()
	var t := TeamData.new(); t.team_id = 0
	state.teams[0] = t
	var leader := PersonData.new(); leader.id = 1
	leader.loyalty = 0.1
	leader.values = { "貪婪": 0.9, "野心": 0.8, "義氣": 0.1, "信義": 0.1 }
	state.persons[1] = leader; t.leader_id = 1
	# 玩家命令在任
	TaskArbiter.try_set(state, t, "巡邏", Vector2i(1, 1), TaskArbiter.PRIO_PLAYER)
	# 貪婪低忠 → 抗命成功
	assert(TaskArbiter.try_set(state, t, "攻擊", Vector2i(2, 2), TaskArbiter.PRIO_DISPATCH),
		"低忠貪婪 leader 應抗命成功")
	print("Arbiter Task1d OK")

func _test_arbiter_suppression() -> void:
	var state := WorldState.new(); state.world = WorldData.new()
	var t := TeamData.new(); t.team_id = 0
	state.teams[0] = t
	var leader := PersonData.new(); leader.id = 1
	leader.loyalty = 0.9
	leader.values = { "貪婪": 0.6, "野心": 0.5, "義氣": 0.8, "信義": 0.8 }
	state.persons[1] = leader; t.leader_id = 1
	TaskArbiter.try_set(state, t, "巡邏", Vector2i(1, 1), TaskArbiter.PRIO_PLAYER)
	var stress0: float = leader.stress
	var unrest0: int = t.unrest_turns
	assert(not TaskArbiter.try_set(state, t, "攻擊", Vector2i(2, 2), TaskArbiter.PRIO_DISPATCH),
		"忠誠 leader 應被壓抑")
	assert(leader.stress > stress0, "壓抑 stress 上升")
	assert(t.unrest_turns > unrest0, "壓抑 unrest 上升")
	print("Arbiter Task1e OK")

func _test_arbiter_suppression_burst() -> void:
	# 中間 leader 連續被擋 → stress 累積推 desire 過閾 → 終於抗命
	var state := WorldState.new(); state.world = WorldData.new()
	var t := TeamData.new(); t.team_id = 0
	state.teams[0] = t
	var leader := PersonData.new(); leader.id = 1
	leader.loyalty = 0.4
	leader.values = { "貪婪": 0.7, "野心": 0.6, "義氣": 0.3, "信義": 0.3 }
	state.persons[1] = leader; t.leader_id = 1
	TaskArbiter.try_set(state, t, "巡邏", Vector2i(1, 1), TaskArbiter.PRIO_PLAYER)
	var defied: bool = false
	for _i in range(30):
		if TaskArbiter.try_set(state, t, "攻擊", Vector2i(2, 2), TaskArbiter.PRIO_DISPATCH):
			defied = true
			break
	assert(defied, "壓抑累積後應爆發抗命")
	print("Arbiter Task1f OK")
```

- [ ] **Step 2: 實作**

`team_data.gd`：
```gdscript
var task_priority: int = 0   # 現任 task 優先權；idle 時 0（TaskArbiter 管理）
```

`scripts/simulation/task_arbiter.gd`（照 spec API 全文 + 抗命/壓抑窗口；`_defiance_check` 公式照 spec）。

注意 try_set 開頭：`if priority <= team.task_priority and team.current_task != TeamData.TASK_IDLE:` 先過抗命窗口判斷再 return false：

```gdscript
static func try_set(state: WorldState, team: TeamData, new_task: String,
		move_target: Vector2i, priority: int, source: String = "") -> bool:
	if team.combat_target != -1:
		return false
	if team.current_task == TeamData.TASK_IDLE or priority > team.task_priority:
		team.current_task = new_task
		team.move_target = move_target
		team.task_priority = priority
		return true
	# 抗命窗口：NPC 慾望 (50) 挑戰玩家命令 (60)
	if team.task_priority == PRIO_PLAYER and priority == PRIO_DISPATCH:
		var leader: PersonData = state.persons.get(team.leader_id)
		if leader != null and _defiance_check(leader):
			print("[抗命] Team%d leader 棄玩家命令 → %s" % [team.team_id, new_task])
			team.current_task = new_task
			team.move_target = move_target
			team.task_priority = priority
			return true
		if leader != null:
			leader.stress = minf(leader.stress + 0.05, 1.0)
			team.unrest_turns += 1
	return false

static func _defiance_check(leader: PersonData) -> bool:
	var obedience: float = leader.loyalty \
		+ float(leader.values.get("義氣", 0.5)) * 0.5 \
		+ float(leader.values.get("信義", 0.5)) * 0.5
	var desire: float = float(leader.values.get("貪婪", 0.5)) \
		+ float(leader.values.get("野心", 0.5)) * 0.5 \
		+ leader.stress * 0.3
	return desire > obedience + 0.3
```

- [ ] **Step 3: 跑 + Commit**

```powershell
.\tools\godot.ps1 --headless --import
.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd
git add scripts/simulation/task_arbiter.gd scripts/data/team_data.gd scripts/debug/headless_test.gd
git commit -m "feat(arbiter): TaskArbiter + task_priority + 抗命/壓抑 (Task 1)"
```

---

## Task 2: faction_ai migration（34 處）

**Files:**
- Modify: `scripts/simulation/faction_ai_system.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 列出全部寫入點**

```powershell
grep -n "current_task = " scripts/simulation/faction_ai_system.gd
```

- [ ] **Step 2: 逐處分類 migration**

依 Migration 對映表逐處改。分類指引（行號以 grep 結果為準）：
- `_trigger_survival`（return_home / TASK_LOOT / 投靠 / 乞食）→ PRIO_SURVIVAL
- `_dispatch_threat_response`（逃跑/迎戰/備戰/外交求和）→ PRIO_THREAT
- `_evaluate_prosperity_attack` TASK_ATTACK → PRIO_DISPATCH。**try_set false → 不設 prosperity_target_id**：
```gdscript
if TaskArbiter.try_set(state, team, TeamData.TASK_ATTACK, prey_pos, TaskArbiter.PRIO_DISPATCH, "prosperity"):
	team.prosperity_target_id = prey_id
```
- `_assign_tasks` / `_evaluate_solo` 成員派遣（徵收/偵查/信使/外交/護衛/貿易）→ PRIO_DISPATCH
- faction goal 攻擊傾向（line ~660）→ PRIO_FACTION
- trade timeout / stuck 釋放 / 任務完成回 idle → `TaskArbiter.release(team)`
- residency `_dispatch_subteam_settle`：dispatch 由 SubteamSystem 處理（Task 4），此處只看 faction_ai 內直接賦值

- [ ] **Step 3: 整合測試**

```gdscript
func _test_arbiter_survival_beats_dispatch() -> void:
	# team 在貿易 (50)，斷糧 → survival try_set 乞食 (80) 成功
	# ...
func _test_arbiter_dispatch_beats_faction_goal() -> void:
	# team 在貿易 (50)，faction goal 攻擊 (30) try_set 失敗 → 貿易保留
	# ...
```

- [ ] **Step 4: 跑 + Commit**

```powershell
.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd
.\tools\godot.ps1 --headless --script scripts/debug/game_sim_test.gd | Select-String "ALL INVARIANTS|FAIL"
git add scripts/simulation/faction_ai_system.gd scripts/debug/headless_test.gd
git commit -m "feat(arbiter): faction_ai 34 處寫入點 migration (Task 2)"
```

---

## Task 3: interaction + outpost migration（17 處）

**Files:**
- Modify: `scripts/simulation/interaction_system.gd`
- Modify: `scripts/simulation/outpost_system.gd`

- [ ] **Step 1: grep + 分類**

```powershell
grep -n "current_task = " scripts/simulation/interaction_system.gd scripts/simulation/outpost_system.gd
```

分類指引：
- interaction：trade 完成回 idle（`_resolve_market` 內 2 處）→ `release`；安頓 handler `_convert_to_resident` 設「生產」→ `transition(team, "生產", PRIO_AMBIENT)`；勒索/投降/合併後 task 變更 → 逐案（完成 → release；強制狀態 → try_set 對應層）
- outpost：建設完成 / settle / demolish 回 idle → `release`；builder 派工初始 → 保留賦值 + 設 priority = PRIO_DISPATCH

- [ ] **Step 2: 跑 + Commit**

```powershell
.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd
git add scripts/simulation/interaction_system.gd scripts/simulation/outpost_system.gd
git commit -m "feat(arbiter): interaction/outpost 17 處 migration (Task 3)"
```

---

## Task 4: 其餘 5 檔 migration（9 處）

**Files:**
- Modify: `scripts/simulation/player_command_system.gd`（3 → PRIO_PLAYER）
- Modify: `scripts/simulation/reaction_system.gd`（2：bridge 恐慌逃跑 → PRIO_THREAT via try_set）
- Modify: `scripts/simulation/strategic_ai_system.gd`（1：trade dispatch → PRIO_DISPATCH，false 則不設 trade_task_start_tick）
- Modify: `scripts/simulation/subteam_system.gd`（1：dispatch 新 team 初始 → 賦值保留 + task_priority = PRIO_DISPATCH）
- Modify: `scripts/simulation/population_system.gd`（1：overflow 流亡 team 初始 idle → task_priority = 0）
- Modify: `scripts/simulation/sim_runner.gd`（1：逐案判 — grep 看情境，arrival 清 task → release）

- [ ] **Step 1: 逐檔改 + bridge 行為測試**

```gdscript
func _test_bridge_cannot_stomp_survival() -> void:
	# team 在乞食 (80)，bridge 恐慌 try_set 逃跑 (70) → 失敗，乞食保留
	# = ping-pong 結構性消失
	# ...
	print("Arbiter Task4 OK")
```

- [ ] **Step 2: 跑 + Commit**

```powershell
.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd
git add scripts/simulation/player_command_system.gd scripts/simulation/reaction_system.gd scripts/simulation/strategic_ai_system.gd scripts/simulation/subteam_system.gd scripts/simulation/population_system.gd scripts/simulation/sim_runner.gd scripts/debug/headless_test.gd
git commit -m "feat(arbiter): 其餘 5 檔 migration + bridge 測試 (Task 4)"
```

---

## Task 5: grep 驗證 + 整合 + handback

**Files:**
- Create: `docs/superpowers/handbacks/2026-06-11-task-arbiter.md`

- [ ] **Step 1: migration 完整性驗證**

```powershell
grep -rn "current_task = " scripts/simulation/ | Select-String -NotMatch "task_arbiter.gd"
```
殘留者逐一確認屬「新 team 建立」豁免類，否則改掉。

- [ ] **Step 2: 跑全測試 + multi**

```powershell
.\tools\godot.ps1 --headless --import
.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd
.\tools\godot.ps1 --headless --script scripts/debug/game_sim_test.gd > godot_test.log 2>&1
.\tools\godot.ps1 --headless --script scripts/debug/game_sim_multi.gd > godot_multi.log 2>&1
Get-Content godot_multi.log | Select-String "逃跑→乞食|乞食→逃跑" | Measure-Object | Select-Object Count
Get-Content godot_multi.log | Select-String "抗命|ALL INVARIANTS" | Select-Object -First 10
```

驗收：
- ping-pong 轉換 < 1,000（baseline 30,478）
- ALL INVARIANTS PASSED ×4 config
- [抗命] / 壓抑有出現（敘事活了）
- task 滯留：抽查 log 無 team 同 task > 30 天無進度（除居民「生產」常駐）

- [ ] **Step 3: handback**

```markdown
# Hand Back: Task Arbiter

## 實作摘要
[檔案表]

## 行為變化
- ping-pong：30,478 → [實測]
- [抗命] 次數 / 壓抑次數
- migration 殘留豁免清單（新 team 建立點）

## 驗證
[headless N/N + invariants + multi]

## 待主 session 確認
- 優先表數值 / 抗命閾值 0.3 tune
- 殘留豁免點是否合規
```

- [ ] **Step 4: Commit**

```powershell
git add docs/superpowers/handbacks/2026-06-11-task-arbiter.md
git commit -m "docs: task arbiter handback (Task 5)"
```
