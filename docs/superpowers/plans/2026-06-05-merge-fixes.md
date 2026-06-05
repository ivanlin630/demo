# Merge System Fixes Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fix two bugs: `_try_merge` swaps absorber/absorbed causing small teams to absorb large ones; `_merge_into` skips `team_discovered` and faction membership cleanup on full erasure.

**Architecture:** Two surgical edits across two files. No new files, no API changes.

**Tech Stack:** GDScript 4.2, Godot 4.2.2, headless test runner

---

## File Map

| File | Action |
|---|---|
| `scripts/simulation/interaction_system.gd` | **Modify** — `_try_merge`: swap merger/target in `merge_teams` call; take NPCs from merger not target |
| `scripts/simulation/subteam_system.gd` | **Modify** — `_merge_into`: add `team_discovered` + faction cleanup when `absorbed.population <= 0` |
| `scripts/debug/headless_test.gd` | **Modify** — add `_merge_into` cleanup test using throwaway teams |

---

## Task 1: Fix `_try_merge` and `_merge_into`, add test

**Files:**
- Modify: `scripts/simulation/interaction_system.gd` (function `_try_merge`, ~line 766)
- Modify: `scripts/simulation/subteam_system.gd` (function `_merge_into`, ~line 196)
- Modify: `scripts/debug/headless_test.gd` (before `print("=== DONE ===")`)

- [ ] **Step 1: Write failing test in headless_test.gd**

Find `print("=== DONE ===")`. Insert directly before it:

```gdscript
	# ── merge fixes test ─────────────────────────────────────────────
	# Verify _merge_into cleanup: after full merge, absorbed team absent from all state dicts
	var _mt_abs_id: int = 9990
	var _mt_abr_id: int = 9991
	var _mt_abs := TeamData.new()
	_mt_abs.team_id    = _mt_abs_id
	_mt_abs.population = 2
	_mt_abs.faction_id = -1
	var _mt_abr := TeamData.new()
	_mt_abr.team_id    = _mt_abr_id
	_mt_abr.population = 100
	_mt_abr.faction_id = -1
	state.teams[_mt_abs_id]           = _mt_abs
	state.teams[_mt_abr_id]           = _mt_abr
	state.team_known[_mt_abs_id]      = []
	state.team_discovered[_mt_abs_id] = []
	var _sub_m := SubteamSystem.new()
	_sub_m._merge_into(state, _mt_abr_id, _mt_abs_id)
	assert(not state.teams.has(_mt_abs_id),
		"[MergeTest] absorbed team must be erased from state.teams")
	assert(not state.team_discovered.has(_mt_abs_id),
		"[MergeTest] absorbed team must be erased from state.team_discovered")
	state.teams.erase(_mt_abr_id)
	state.team_known.erase(_mt_abr_id)
	state.team_discovered.erase(_mt_abr_id)
	print("[MergeTest] _merge_into cleanup ok")
	# ── end merge fixes test ─────────────────────────────────────────
```

- [ ] **Step 2: Run to confirm failure**

```powershell
A:\GDS\demo\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

Expected: `assert` failure `[MergeTest] absorbed team must be erased from state.team_discovered` (since `team_discovered` cleanup is missing). Note exact failure message.

- [ ] **Step 3: Fix `_try_merge` in `interaction_system.gd`**

Locate `_try_merge` (~line 766). Replace the current body from `var absorbed_team` to the end of the function:

**Current:**
```gdscript
	var absorbed_team: TeamData = state.teams[target_id]
	var all_npcs: Array = []
	if absorbed_team.leader_id != -1: all_npcs.append(absorbed_team.leader_id)
	all_npcs.append_array(absorbed_team.named_members)
	SubteamSystem.new().merge_teams(state, merger_id, target_id, all_npcs)
	merger.current_task = TeamData.TASK_IDLE
	merger.order_target_id = -1
```

**Replace with:**
```gdscript
	# absorbed_team is the MERGER (small team dissolving into target)
	var absorbed_team: TeamData = state.teams[merger_id]
	var all_npcs: Array = []
	if absorbed_team.leader_id != -1: all_npcs.append(absorbed_team.leader_id)
	all_npcs.append_array(absorbed_team.named_members)
	SubteamSystem.new().merge_teams(state, target_id, merger_id, all_npcs)
	# reset merger task (safe even if merger_id erased — GDScript ref stays valid)
	merger.current_task    = TeamData.TASK_IDLE
	merger.order_target_id = -1
```

- [ ] **Step 4: Fix `_merge_into` in `subteam_system.gd`**

Locate the `if absorbed.population <= 0:` block (~line 196). Replace it:

**Current:**
```gdscript
	if absorbed.population <= 0:
		state.teams.erase(absorbed_id)
		state.team_known.erase(absorbed_id)
		print("[Merge] Team%d ← Team%d 完全合併 (pop=%d)" % [absorber_id, absorbed_id, absorber.population])
```

**Replace with:**
```gdscript
	if absorbed.population <= 0:
		# Faction cleanup before erasing
		if absorbed.faction_id != -1:
			var f_merge: FactionData = state.factions.get(absorbed.faction_id)
			if f_merge != null:
				f_merge.member_team_ids.erase(absorbed_id)
				f_merge.known_member_states.erase(absorbed_id)
		state.teams.erase(absorbed_id)
		state.team_known.erase(absorbed_id)
		state.team_discovered.erase(absorbed_id)
		print("[Merge] Team%d ← Team%d 完全合併 (pop=%d)" % [absorber_id, absorbed_id, absorber.population])
```

- [ ] **Step 5: Run test**

```powershell
A:\GDS\demo\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

Expected:
- `[MergeTest] _merge_into cleanup ok`
- `=== DONE ===`
- Zero `SCRIPT ERROR`

- [ ] **Step 6: Commit**

```
git add scripts/simulation/interaction_system.gd scripts/simulation/subteam_system.gd scripts/debug/headless_test.gd
git commit -m "fix(merge): swap absorber/absorbed in _try_merge; add team_discovered+faction cleanup in _merge_into"
```

---

## Task 2: Write hand-back and push

- [ ] **Step 1: Create hand-back**

Create `docs/superpowers/handbacks/2026-06-05-merge-fixes.md`:

```markdown
# Hand Back: Merge System Fixes

## 實作摘要

- `scripts/simulation/interaction_system.gd` — `_try_merge`：修正 `merge_teams` 參數順序。原本小隊（merger）誤作 absorber，大隊（target）誤作 absorbed，導致大隊可能被清空刪除。現改為 `merge_teams(state, target_id, merger_id, merger_npcs)`，大隊吸收小隊，all_npcs 取自小隊
- `scripts/simulation/subteam_system.gd` — `_merge_into`：`absorbed.population <= 0` 清理區塊新增 `state.team_discovered.erase()` 及 faction `member_team_ids`/`known_member_states` 清理
- `scripts/debug/headless_test.gd` — 新增 throwaway team 測試，驗證 `_merge_into` 後 `state.team_discovered` 清理正確

與 spec 無差異。

## 連動風險

- `_try_merge` 修正後，小隊現在會被正確吸收（人口歸零）並從 state 刪除。若有任何系統持有小隊的 `team_id` 引用（例如 `f.member_team_ids`），將在 `_merge_into` 的 faction cleanup 中一併清除。
- `_try_merge` 的 `merger.current_task = TASK_IDLE` 在 merger 被刪除後仍寫入（GDScript object ref 存活），不影響正確性。

## 待主 session 確認

- 無
```

- [ ] **Step 2: Commit and push**

```
git add docs/superpowers/handbacks/2026-06-05-merge-fixes.md
git commit -m "docs: add hand-back for merge-fixes"
git push -u origin HEAD
```
