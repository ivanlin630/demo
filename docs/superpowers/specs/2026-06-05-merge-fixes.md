# Merge System Fixes Design

## Goal

Fix two bugs in the team merge pipeline:
1. `interaction_system._try_merge` passes arguments in wrong order — small merger team absorbs large target instead of vice versa.
2. `subteam_system._merge_into` omits `state.team_discovered` and faction membership cleanup when absorbed team is erased.

Note: audit entry said `subteam_system._merge_into` stub, but real root cause is in `interaction_system._try_merge`. Both files need changes.

---

## Bug 1 — `_try_merge` parameter swap

### Current (wrong)

```gdscript
var absorbed_team: TeamData = state.teams[target_id]   # ← large/leader team's NPCs taken
var all_npcs: Array = [...]
SubteamSystem.new().merge_teams(state, merger_id, target_id, all_npcs)
# merger_id (small) = absorber  ← WRONG: small absorbs large
# target_id  (large) = absorbed ← WRONG: leader team stripped of NPCs, risks being erased
```

### Fix

Take NPCs from the merger (small team) and pass target (large team) as absorber:

```gdscript
var absorbed_team: TeamData = state.teams[merger_id]   # small team provides its NPCs
var all_npcs: Array = []
if absorbed_team.leader_id != -1: all_npcs.append(absorbed_team.leader_id)
all_npcs.append_array(absorbed_team.named_members)
SubteamSystem.new().merge_teams(state, target_id, merger_id, all_npcs)
# target_id  (large) = absorber ← correct: large team grows
# merger_id  (small) = absorbed ← correct: small team dissolves into large
merger.current_task    = TeamData.TASK_IDLE
merger.order_target_id = -1
```

Note: `merger.current_task` reset is safe even if merger_id team is erased from state — GDScript reference stays valid.

---

## Bug 2 — `_merge_into` incomplete cleanup

### Current (incomplete)

```gdscript
if absorbed.population <= 0:
    state.teams.erase(absorbed_id)
    state.team_known.erase(absorbed_id)
    # ← missing: team_discovered, faction.member_team_ids
```

### Fix

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

---

## Files to modify

| File | Change |
|---|---|
| `scripts/simulation/interaction_system.gd` | `_try_merge`: swap absorber/absorbed args and NPC source |
| `scripts/simulation/subteam_system.gd` | `_merge_into`: add faction + team_discovered cleanup |

---

## Testing

Add to `headless_test.gd` before `print("=== DONE ===")`:

```gdscript
	# ── merge fixes test ─────────────────────────────────────────────
	# Verify _merge_into cleanup: after full merge, absorbed team absent from all state dicts
	# Use two fresh throwaway teams so existing simulation state isn't corrupted
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
	state.teams[_mt_abs_id]         = _mt_abs
	state.teams[_mt_abr_id]         = _mt_abr
	state.team_known[_mt_abs_id]    = []
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

*Spec written: 2026-06-05*
