# 批次 1 — 核心修正 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 修正 4 個高優先問題：G-01 NPC外交繞過玩家、T-02 NPC全知（外部+內部）、G-04 玩家通知機制、G-08 設定徵收率。

**Architecture:** 全部改現有檔案，零新系統。T-02 讓 AI 改讀 `team_intel` / `faction_snapshot` 代替直讀 WorldState；G-01 在 `_send_diplomacy_message` 攔截並寫 `player_forced_event`；G-04 在各觸發點寫 `player_alerts`；G-08 加一個 action。

**Tech Stack:** GDScript 4.2.2，無外部依賴。

---

## 修改檔案一覽

| 檔案 | 動作 | 涵蓋 |
|---|---|---|
| `scripts/simulation/diplomatic_ai_system.gd` | 修改 `_send_diplomacy_message`、`_calc_diplomacy_score`、`consider_betrayal`、`_execute_betrayal` | G-01、T-02外部、G-04 |
| `scripts/simulation/strategic_ai_system.gd` | 修改 `_evaluate_alliance_need`、`_assign_encirclement`、`_find_weakest_member`、`_faction_total_pop` | T-02外部+內部 |
| `scripts/simulation/interaction_system.gd` | 修改 `_deliver_order` | T-02 快照A |
| `scripts/simulation/sim_runner.gd` | 加 `_step4e_faction_snapshot` | T-02 快照B |
| `scripts/data/world_state.gd` | 加 `player_alerts` 欄位 | G-04 |
| `scripts/simulation/resource_system.gd` | 加 `food_critical` 觸發 | G-04 |
| `scripts/simulation/player_command_system.gd` | 加 `set_tribute_rate` action | G-08 |
| `scripts/debug/headless_test.gd` | 加驗證輸出 | 測試 |

---

## Task 1：G-01 — NPC外交攔截

**Files:**
- Modify: `scripts/simulation/diplomatic_ai_system.gd`

- [ ] **Step 1: 修改 `_send_diplomacy_message`**

在函式開頭加玩家攔截邏輯（`_send_diplomacy_message` 目前第 59–64 行）：

```gdscript
func _send_diplomacy_message(state: WorldState, sender: TeamData,
		target: TeamData, action: String) -> void:
	# G-01：偵測玩家目標 → 寫入 forced_event，不直接解算
	if state.player_id != -1 and target.team_id == state.teams.get(state.player_id, TeamData.new()).team_id:
		state.player_forced_event = {
			"type": "diplomacy",
			"from_id": sender.team_id,
			"proposal": action,
		}
		state.player_forced_event_id = str(randi())
		print("[Diplomacy] Team%d 向玩家發起 %s → 寫入 forced_event" % [sender.team_id, action])
		return
	print("[Diplomacy] Team%d → Team%d: %s" % [sender.team_id, target.team_id, action])
	var response: String = handle_diplomacy_message(state, target, sender, action)
	print("[Diplomacy] Team%d 回應: %s" % [target.team_id, response])
```

- [ ] **Step 2: 跑 headless test 確認無錯誤**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

預期：`=== DONE ===`，無 `SCRIPT ERROR`，仍出現 `[Diplomacy]` 日誌。

- [ ] **Step 3: Commit**

```
git add scripts/simulation/diplomatic_ai_system.gd
git commit -m "fix(diplomatic_ai): G-01 intercept NPC diplomacy targeting player"
```

---

## Task 2：T-02 外部目標 — diplomatic_ai 改讀 team_intel

**Files:**
- Modify: `scripts/simulation/diplomatic_ai_system.gd`

`_calc_diplomacy_score` 目前讀 `other_team.population`（精確值）。改讀 `team_intel` 估算值。

- [ ] **Step 1: 加 helper `_get_pop_est`**

在 `DiplomaticAiSystem` 加：

```gdscript
# T-02：從 team_intel 取人口估算；無資料 fallback = self_pop（謹慎：視對方與己等強）
func _get_pop_est(state: WorldState, obs_id: int, tgt_id: int, fallback: int) -> int:
	return state.team_intel.get(obs_id, {}).get(tgt_id, {}).get("population_est", fallback)
```

- [ ] **Step 2: 修改 `_calc_diplomacy_score`**

```gdscript
func _calc_diplomacy_score(state: WorldState,
		self_team: TeamData, other_team: TeamData) -> float:
	var self_leader: PersonData = state.persons.get(self_team.leader_id)
	if self_leader == null: return 0.0

	var food_ratio: float = float(self_team.resources.get("food", 0)) / \
		maxf(self_team.population * 5.0, 1.0)
	var resource_need: float = clampf(1.0 - food_ratio, 0.0, 1.0)

	# T-02：用估算人口，fallback = self.population（謹慎估算）
	var other_pop_est: int = _get_pop_est(state, self_team.team_id, other_team.team_id, self_team.population)
	var power_gap: float = clampf(
		float(other_pop_est - self_team.population) / \
		maxf(self_team.population, 1.0), -1.0, 1.0)

	var rep: float = float(self_team.known_reputations.get(other_team.team_id, 0.5))

	var other_leader_id: int = other_team.leader_id
	var relation: float = float(self_leader.relations.get(other_leader_id, 0.0))

	var self_peace: float = self_leader.values.get("義氣", 0.5) * \
		self_leader.values.get("信義", 0.5)

	return clampf(
		resource_need * 0.3 +
		power_gap     * 0.2 +
		rep           * 0.2 +
		relation      * 0.15 +
		self_peace    * 0.15,
		0.0, 1.0)
```

- [ ] **Step 3: 修改 `consider_betrayal`**

目前讀 `ally_team.population`（精確）→ 改讀 faction_snapshot：

```gdscript
func consider_betrayal(state: WorldState, self_team: TeamData,
		ally_team: TeamData) -> bool:
	var self_leader: PersonData = state.persons.get(self_team.leader_id)
	if self_leader == null: return false
	var betrayal_score: float = \
		self_leader.values.get("野心", 0.5) * 0.4 + \
		(1.0 - self_leader.values.get("信義", 0.5)) * 0.4 + \
		(1.0 - self_leader.values.get("義氣", 0.5)) * 0.2
	# T-02：從 faction_snapshot 讀盟友人口（非直讀 WorldState）
	var ally_pop: int = ally_team.population  # fallback
	if self_team.faction_id != -1:
		var f: FactionData = state.factions.get(self_team.faction_id)
		if f:
			ally_pop = f.known_member_states.get(ally_team.team_id, {}).get("population", ally_team.population)
	var power_gap: float = float(ally_pop - self_team.population) / \
		maxf(self_team.population, 1.0)
	if power_gap > 0.5: betrayal_score -= 0.3
	if betrayal_score > 0.65 and randf() < 0.1:
		_execute_betrayal(state, self_team, ally_team)
		return true
	return false
```

- [ ] **Step 4: 跑 headless test**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

預期：`=== DONE ===`，無 `SCRIPT ERROR`。

- [ ] **Step 5: Commit**

```
git add scripts/simulation/diplomatic_ai_system.gd
git commit -m "fix(diplomatic_ai): T-02 read team_intel/faction_snapshot instead of WorldState"
```

---

## Task 3：T-02 外部目標 — strategic_ai 改讀 team_intel

**Files:**
- Modify: `scripts/simulation/strategic_ai_system.gd`

- [ ] **Step 1: 加 helper `_get_pop_est`**

```gdscript
func _get_pop_est(state: WorldState, obs_id: int, tgt_id: int, fallback: int) -> int:
	return state.team_intel.get(obs_id, {}).get(tgt_id, {}).get("population_est", fallback)
```

- [ ] **Step 2: 修改 `_evaluate_alliance_need`**

```gdscript
func _evaluate_alliance_need(state: WorldState, faction: FactionData) -> void:
	var self_pop: int = _faction_total_pop(state, faction)
	var threat_map: Dictionary = {}
	var seen: Dictionary = {}
	for mid in faction.member_team_ids:
		for tid in state.team_discovered.get(mid, []):
			seen[tid] = mid  # 記錄是哪個 member 看到的
	for tid in seen:
		var t: TeamData = state.teams.get(tid)
		if t == null: continue
		if t.faction_id == faction.faction_id or t.faction_id == -1: continue
		# T-02：讀目擊者 member 的 team_intel 估算值
		var obs_id: int = seen[tid]
		var pop_est: int = _get_pop_est(state, obs_id, tid, t.population)
		threat_map[t.faction_id] = threat_map.get(t.faction_id, 0) + pop_est
	for fid in threat_map:
		if threat_map[fid] > self_pop * 1.5:
			print("[StrategicAI] Faction%d 受威脅，尋求結盟" % faction.faction_id)
			break
```

- [ ] **Step 3: 修改 `_assign_encirclement`**

```gdscript
func _assign_encirclement(state: WorldState, faction: FactionData,
		target_id: int) -> void:
	var target: TeamData = state.teams.get(target_id)
	if target == null: return
	var member_teams: Array = []
	for tid in faction.member_team_ids:
		var t: TeamData = state.teams.get(tid)
		if t: member_teams.append(t)
	for t in member_teams:
		t.strategic_assignments.clear()
	var dirs: Array = [
		Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1),
		Vector2i(0, -1), Vector2i(1, -1), Vector2i(-1, 1),
	]
	# T-02：用 leader 的 team_intel 取目標最後已知位置
	var leader_id: int = faction.leader_team_id
	var target_pos: Vector2i = state.team_intel.get(leader_id, {}).get(
		target_id, {}).get("tile_pos", target.tile_pos)
	for i in range(member_teams.size()):
		var t: TeamData = member_teams[i]
		var dir: Vector2i = dirs[i % dirs.size()]
		t.strategic_assignments[target_id] = target_pos + dir * 2
```

- [ ] **Step 4: 跑 headless test**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

預期：`=== DONE ===`，`[StrategicAI]` 日誌仍出現。

- [ ] **Step 5: Commit**

```
git add scripts/simulation/strategic_ai_system.gd
git commit -m "fix(strategic_ai): T-02 read team_intel for external target decisions"
```

---

## Task 4：T-02 內部快照 A+B — 觸發 faction_snapshot 更新

**Files:**
- Modify: `scripts/simulation/interaction_system.gd`
- Modify: `scripts/simulation/sim_runner.gd`

### 4A：信使抵達（`_deliver_order`）

`_deliver_order` 目前（第 790–803 行）在信使傳令後沒有更新快照。加一行：

- [ ] **Step 1: 修改 `_deliver_order`**

```gdscript
func _deliver_order(state: WorldState, messenger_id: int, target_id: int) -> void:
	var messenger: TeamData = state.teams[messenger_id]
	var target: TeamData    = state.teams[target_id]
	var order: String = messenger.order_task if messenger.order_task != "" else "idle"
	target.current_task       = order
	messenger.current_task    = "idle"
	messenger.order_target_id = -1
	messenger.order_task      = ""
	var parent: TeamData = state.teams.get(messenger.parent_team_id)
	if parent != null:
		messenger.move_target = parent.tile_pos
	# T-02 快照A：信使抵達 = 情報傳遞，更新 messenger 母隊在 faction 中的快照
	if messenger.parent_team_id != -1:
		state.snapshot_faction_member(messenger.parent_team_id, state.world.current_tick)
	_msg.emit_message(state, "order_delivered",
		"Team%d 傳令 Team%d → task=%s" % [messenger_id, target_id, order], messenger)
	print("[Order] Team%d 傳令 Team%d → %s" % [messenger_id, target_id, order])
```

### 4B：同格同勢力接觸（`sim_runner`）

- [ ] **Step 2: 在 `sim_runner.gd` 加 `_step4e_faction_snapshot`**

在 `_step4b_outpost_tick` 附近加新函式：

```gdscript
func _step4e_faction_snapshot(state: WorldState, team_ids: Array) -> void:
	# T-02 快照B：同格同勢力 → 互相更新快照（模擬面對面情報交換）
	var pos_map: Dictionary = {}  # tile_id → Array[int] team_ids
	for tid in team_ids:
		var t: TeamData = state.teams.get(tid)
		if t == null or t.faction_id == -1: continue
		var tile_id: int = t.tile_pos.x * 1000 + t.tile_pos.y
		if not pos_map.has(tile_id): pos_map[tile_id] = []
		pos_map[tile_id].append(tid)
	for tile_id in pos_map:
		var same_tile: Array = pos_map[tile_id]
		if same_tile.size() < 2: continue
		for tid in same_tile:
			var t: TeamData = state.teams[tid]
			# 找同格同勢力
			for other_tid in same_tile:
				if other_tid == tid: continue
				var other: TeamData = state.teams[other_tid]
				if other.faction_id == t.faction_id:
					state.snapshot_faction_member(tid, state.world.current_tick)
					break
```

- [ ] **Step 3: 在 `advance_tick` 加呼叫**

在近區的 `_step4b_outpost_tick(state)` 後加：

```gdscript
_step4e_faction_snapshot(state, near_teams)
```

在遠區的 `_step4b_outpost_tick` 對應位置沒有，但可以在 `_step4_resolve_interactions` 後加（遠區也需要）：

在遠區區塊的 `_step4_resolve_interactions(state, arrived_far, far_teams)` 後加：

```gdscript
_step4e_faction_snapshot(state, far_teams)
```

- [ ] **Step 4: 跑 headless test**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

預期：`=== DONE ===`，無錯誤。

- [ ] **Step 5: Commit**

```
git add scripts/simulation/interaction_system.gd scripts/simulation/sim_runner.gd
git commit -m "fix(interaction,sim_runner): T-02 faction snapshot A+B triggers"
```

---

## Task 5：T-02 內部快照 — strategic_ai 改讀 faction_snapshot

**Files:**
- Modify: `scripts/simulation/strategic_ai_system.gd`

- [ ] **Step 1: 修改 `_find_weakest_member`**

```gdscript
func _find_weakest_member(state: WorldState, faction: FactionData) -> int:
	var weakest_id: int = -1; var weakest_pop: int = 9999
	for tid in faction.member_team_ids:
		# T-02：從 faction_snapshot 讀人口；無快照 = 9999（視為強健，不優先支援）
		var pop: int = faction.known_member_states.get(tid, {}).get("population", 9999)
		if pop < weakest_pop:
			weakest_pop = pop; weakest_id = tid
	return weakest_id
```

- [ ] **Step 2: 修改 `_faction_total_pop`**

```gdscript
func _faction_total_pop(state: WorldState, faction: FactionData) -> int:
	var total: int = 0
	for tid in faction.member_team_ids:
		# T-02：從快照讀人口；無快照 fallback = 直讀（自己的隊伍應有快照）
		var t: TeamData = state.teams.get(tid)
		var snap_pop: int = faction.known_member_states.get(tid, {}).get("population", -1)
		if snap_pop >= 0:
			total += snap_pop
		elif t:
			total += t.population
	return total
```

- [ ] **Step 3: 跑 headless test**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

預期：`=== DONE ===`，`[StrategicAI]` 仍運作。

- [ ] **Step 4: Commit**

```
git add scripts/simulation/strategic_ai_system.gd
git commit -m "fix(strategic_ai): T-02 read faction_snapshot for member population"
```

---

## Task 6：G-04 — 玩家通知機制

**Files:**
- Modify: `scripts/data/world_state.gd`
- Modify: `scripts/simulation/resource_system.gd`
- Modify: `scripts/simulation/diplomatic_ai_system.gd`

### 6A：加資料結構

- [ ] **Step 1: 在 `world_state.gd` 加 `player_alerts`**

在 `player_forced_event_id` 後加：

```gdscript
var player_alerts: Array = []
# Array[Dictionary]，格式：{ "type": String, "tick": int, "data": Dictionary }
# 類型：food_critical / member_defected / faction_member_betrayed /
#       subteam_destroyed / outpost_captured
# UI 輪詢後清空（同 forced_event 模式）
```

### 6B：觸發點

- [ ] **Step 2: `resource_system.resolve_consumption` 加 `food_critical`**

在 `resolve_consumption` 的食物不足分支加（`satisfaction` 計算後）：

```gdscript
# G-04：玩家食物告急通知
if state.player_id != -1:
	var pt: TeamData = state.teams.get(state.player_id)
	if pt != null and pt.team_id == tid and satisfaction < 0.3:
		var already: bool = false
		for a in state.player_alerts:
			if a["type"] == "food_critical": already = true; break
		if not already:
			state.player_alerts.append({
				"type": "food_critical",
				"tick": state.world.current_tick,
				"data": { "needs_ratio": satisfaction }
			})
```

- [ ] **Step 3: `diplomatic_ai._execute_betrayal` 加 `faction_member_betrayed`**

在 `_execute_betrayal` print 之前加：

```gdscript
# G-04：勢力成員背叛通知
if state.player_id != -1:
	var player_team: TeamData = state.teams.get(state.player_id)
	if player_team != null and player_team.faction_id != -1 and \
			player_team.faction_id == self_team.faction_id:
		state.player_alerts.append({
			"type": "faction_member_betrayed",
			"tick": state.world.current_tick,
			"data": { "betrayer_id": self_team.team_id }
		})
```

- [ ] **Step 4: 跑 headless test**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

預期：`=== DONE ===`，無錯誤。

- [ ] **Step 5: 在 headless_test 加 player_alerts 輸出驗證**

在 `_run_sim_test` 的結尾（`=== DONE ===` 前）加：

```gdscript
print("--- player_alerts ---")
print("  alerts 數量: %d" % state.player_alerts.size())
for a in state.player_alerts:
	print("  %s tick=%d data=%s" % [a["type"], a["tick"], str(a["data"])])
```

- [ ] **Step 6: Commit**

```
git add scripts/data/world_state.gd scripts/simulation/resource_system.gd scripts/simulation/diplomatic_ai_system.gd scripts/debug/headless_test.gd
git commit -m "feat(world_state,resource,diplomatic_ai): G-04 player_alerts notification system"
```

---

## Task 7：G-08 — set_tribute_rate

**Files:**
- Modify: `scripts/simulation/player_command_system.gd`

- [ ] **Step 1: 在 `execute_action` 的 match 加 `set_tribute_rate`**

在現有 `match action:` 的最後一個 case 前加（找到類似 `"recruit":` 的位置後插入）：

```gdscript
"set_tribute_rate":
	var rate: float = float(state.player_state.get("tribute_rate_input", 0.1))
	rate = clampf(rate, 0.0, 1.0)
	if pt.faction_id == -1:
		return { "ok": false, "msg": "玩家不在勢力中" }
	var f: FactionData = state.factions.get(pt.faction_id)
	if f == null:
		return { "ok": false, "msg": "勢力不存在" }
	if f.leader_team_id != pt.team_id:
		return { "ok": false, "msg": "只有 leader 可設定徵收率" }
	f.tribute_rate = rate
	print("[PlayerCmd] set_tribute_rate → %.2f" % rate)
	return { "ok": true, "msg": "徵收率設為 %.0f%%" % (rate * 100) }
```

> **Note：** UI 呼叫前先設 `state.player_state["tribute_rate_input"] = 想要的值`，再呼叫 `execute_action(state, -1, "set_tribute_rate")`。`target_id` 傳 -1（不需要目標）。

- [ ] **Step 2: 跑 headless test**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

預期：`=== DONE ===`，無錯誤。

- [ ] **Step 3: Commit**

```
git add scripts/simulation/player_command_system.gd
git commit -m "feat(player_command): G-08 set_tribute_rate action"
```

---

## 最終驗證

- [ ] **全部跑過一次**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

預期：
- `=== DONE ===`，無 `SCRIPT ERROR`
- 出現 `[Diplomacy]` 日誌（G-01 攔截或正常外交）
- 出現 `[StrategicAI]` 日誌
- `--- player_alerts ---` 顯示（可能 0 筆，但無 crash）

- [ ] **Push branch**

```powershell
git push -u origin feat/batch1-core-fixes
```

---

*最後更新：2026-06-04*
