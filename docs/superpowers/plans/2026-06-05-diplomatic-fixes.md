# Diplomatic System Fixes Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fix two bugs in `diplomatic_ai_system.gd`: betrayal orphans faction membership data; tribute refusal has no consequence.

**Architecture:** Two targeted edits inside `diplomatic_ai_system.gd`. No new files. No API changes. Memory key `"reaction": "tribute_refused"` already consumed by `PlayerTradeSystem.evaluate_offer`.

**Tech Stack:** GDScript 4.2, Godot 4.2.2, headless test runner

---

## File Map

| File | Action |
|---|---|
| `scripts/simulation/diplomatic_ai_system.gd` | **Modify** — fix `_execute_betrayal` + add tribute refusal consequence in `_send_diplomacy_message` |
| `scripts/debug/headless_test.gd` | **Modify** — add betrayal orphan test + tribute refusal test |

---

## Task 1: Fix `_execute_betrayal` orphan + add tribute refusal consequence

**Files:**
- Modify: `scripts/simulation/diplomatic_ai_system.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: Write failing tests in headless_test.gd**

Find `print("=== DONE ===")`. Insert before it:

```gdscript
	# ── diplomatic fixes test ────────────────────────────────────────
	var _diplo_test := DiplomaticAiSystem.new()

	# Test 1: Betrayal orphan — after _execute_betrayal, faction.member_team_ids must not contain betrayer
	var _diplo_tested_betrayal: bool = false
	for _fid_bt in state.factions:
		var _f_bt: FactionData = state.factions[_fid_bt]
		if _f_bt.member_team_ids.size() < 2:
			continue
		var _betrayer_tid: int = -1
		for _mid in _f_bt.member_team_ids:
			if _mid != _f_bt.leader_team_id:
				_betrayer_tid = _mid
				break
		if _betrayer_tid == -1:
			continue
		var _betrayer_bt: TeamData  = state.teams.get(_betrayer_tid)
		var _leader_bt: TeamData    = state.teams.get(_f_bt.leader_team_id)
		if _betrayer_bt == null or _leader_bt == null:
			continue
		_diplo_test._execute_betrayal(state, _betrayer_bt, _leader_bt)
		assert(not _f_bt.member_team_ids.has(_betrayer_tid),
			"[DiploTest] betrayer must be removed from faction.member_team_ids after betrayal")
		assert(_betrayer_bt.faction_id == -1,
			"[DiploTest] betrayer faction_id must be -1 after betrayal")
		print("[DiploTest] betrayal orphan fix ok — Team%d removed from faction" % _betrayer_tid)
		_diplo_tested_betrayal = true
		break
	if not _diplo_tested_betrayal:
		print("[DiploTest] betrayal test skipped (no suitable faction found)")

	# Test 2: Tribute refusal — handle_diplomacy_message response shape
	var _dem2: TeamData = state.teams[0]
	var _pay2: TeamData = state.teams[2]
	var _resp2: String  = _diplo_test.handle_diplomacy_message(state, _pay2, _dem2, "demand_tribute")
	print("[DiploTest] demand_tribute from Team0 to Team2: response=%s" % _resp2)
	assert(_resp2 == "accept" or _resp2 == "refuse",
		"[DiploTest] demand_tribute response must be 'accept' or 'refuse'")
	print("[DiploTest] tribute refusal shape ok")
	# ── end diplomatic fixes test ───────────────────────────────────
```

- [ ] **Step 2: Run to confirm test state (baseline)**

```powershell
A:\GDS\demo\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

Expected: Tests run without `SCRIPT ERROR`. The betrayal assert may fail if orphan bug is triggered. Note the output.

- [ ] **Step 3: Fix `_execute_betrayal` in diplomatic_ai_system.gd**

Find `_execute_betrayal` (line ~158). Current opening:

```gdscript
func _execute_betrayal(state: WorldState, self_team: TeamData,
		ally_team: TeamData) -> void:
	self_team.faction_id = -1
```

Replace with:

```gdscript
func _execute_betrayal(state: WorldState, self_team: TeamData,
		ally_team: TeamData) -> void:
	# Remove from faction BEFORE clearing faction_id (need the id to find the faction)
	var f_bt: FactionData = state.factions.get(self_team.faction_id)
	if f_bt != null:
		f_bt.member_team_ids.erase(self_team.team_id)
	self_team.faction_id = -1
```

- [ ] **Step 4: Add tribute refusal consequence in `_send_diplomacy_message`**

Find `_send_diplomacy_message` (line ~65). Current end of function:

```gdscript
	var response: String = handle_diplomacy_message(state, target, sender, action)
	print("[Diplomacy] Team%d 回應: %s" % [target.team_id, response])
```

Replace with:

```gdscript
	var response: String = handle_diplomacy_message(state, target, sender, action)
	print("[Diplomacy] Team%d 回應: %s" % [target.team_id, response])
	# Tribute refusal consequence: write memory + reputation penalty
	if action == "demand_tribute" and response == "refuse":
		var sender_leader: PersonData = state.persons.get(sender.leader_id) if sender.leader_id >= 0 else null
		if sender_leader != null:
			sender_leader.memory.append({
				"event_id":  state.world.current_tick,
				"intensity": "minor",
				"reaction":  "tribute_refused"
			})
		_update_reputation(sender, target.team_id, -0.1)
		_update_reputation(target, sender.team_id, -0.05)
		print("[Diplomacy] Team%d 拒絕進貢 → demander memory tribute_refused, rep -0.1/-0.05" % target.team_id)
```

- [ ] **Step 5: Run tests**

```powershell
A:\GDS\demo\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

Expected:
- `[DiploTest] betrayal orphan fix ok — Team%d removed from faction` (or "skipped" if no faction has ≥2 members after 1000 ticks)
- `[DiploTest] demand_tribute from Team0 to Team2: response=accept` or `=refuse`
- `[DiploTest] tribute refusal shape ok`
- `=== DONE ===`
- Zero `SCRIPT ERROR`

- [ ] **Step 6: Commit**

```
git add scripts/simulation/diplomatic_ai_system.gd scripts/debug/headless_test.gd
git commit -m "fix(diplomacy): remove betrayer from faction.member_team_ids; add tribute_refused memory+rep"
```

---

## Task 2: Write hand-back and push

- [ ] **Step 1: Create hand-back**

Create `docs/superpowers/handbacks/2026-06-05-diplomatic-fixes.md`:

```markdown
# Hand Back: Diplomatic System Fixes

## 實作摘要

- `scripts/simulation/diplomatic_ai_system.gd`
  - `_execute_betrayal`：在清除 `self_team.faction_id` 前先讀取 faction，呼叫 `f.member_team_ids.erase(self_team.team_id)` 修正孤立成員 bug
  - `_send_diplomacy_message`：`demand_tribute` + "refuse" 分支：寫入 `tribute_refused` 記憶到 sender leader、`_update_reputation` 雙向 -0.1/-0.05
- `scripts/debug/headless_test.gd`：新增背叛孤立測試 + 進貢拒絕回應格式測試

與 spec 無差異。

## 連動風險

- `PlayerTradeSystem.evaluate_offer` 已讀 `"tribute_refused"` reaction（+0.10 threshold）— 格式一致，無需改動。
- `_execute_betrayal` 現在修改 `FactionData.member_team_ids`；FactionAI 在同 tick 迭代 `f.member_team_ids` 時若有背叛，迭代中修改 Array 可能不安全。現行 `consider_betrayal` 在 `for tid in f.member_team_ids` 迴圈內調用，GDScript Array 迭代中 erase 可能跳過元素。建議主 session 確認。

## 待主 session 確認

- `for tid in f.member_team_ids` 迴圈中呼叫 `consider_betrayal` → `_execute_betrayal` → `f.member_team_ids.erase(...)` 是否安全？（GDScript Array iteration 修改安全性）
```

- [ ] **Step 2: Commit hand-back and push**

```
git add docs/superpowers/handbacks/2026-06-05-diplomatic-fixes.md
git commit -m "docs: add hand-back for diplomatic-fixes"
git push -u origin HEAD
```
