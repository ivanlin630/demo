# Movement Boundary Fix Design

## Goal

Prevent teams from stepping onto tiles that don't exist in `state.world.tiles`. Currently `_get_neighbors` returns all 6 axial neighbours unconditionally; if a team is at the world edge, `_step_team` may choose an off-map neighbour and write an invalid position to `team.tile_pos`.

## Root Cause

```gdscript
# movement_system.gd _step_team
for neighbor in _get_neighbors(team.tile_pos):
    var d: int = _hex_dist(neighbor, team.move_target)
    if d < best_dist:
        best_dist = d
        best_pos = neighbor   # ← no check that neighbor tile exists
team.tile_pos = best_pos      # ← may write off-map position
```

## Already Fixed (no change needed)

`player_command_system.move_to` already validates the target tile:
```gdscript
if not state.world.tiles.has(key):
    return { "ok": false, "msg": "目標格不在地圖內" }
```

## Fix

### `_step_team` — filter off-map neighbours

Add one guard inside the neighbour loop:

```gdscript
for neighbor in _get_neighbors(team.tile_pos):
    var nid: int = neighbor.x * 1000 + neighbor.y
    if not state.world.tiles.has(nid):
        continue          # skip off-map cells
    var d: int = _hex_dist(neighbor, team.move_target)
    if d < best_dist:
        best_dist = d
        best_pos  = neighbor
```

If no on-map neighbour improves distance (team boxed in at corner, or moving toward unreachable off-map target), `best_pos` stays `team.tile_pos`. No position mutation. Additionally, if `best_pos == team.tile_pos` AND `tile_pos != move_target`, cancel `move_target` with a warning print to prevent infinite stuck loops.

## No changes to

- `_get_neighbors` signature (stays pure, no state dependency)
- `_on_arrival`, `_hex_dist`, tile occupation logic
- NPC move_target assignment (always uses `team.tile_pos` of existing teams)
- `move_to` player command (already guarded)

## Testing

Add to `headless_test.gd` before `print("=== DONE ===")`:

```gdscript
# ── movement boundary test ────────────────────────────────────────
var _ms_test := MovementSystem.new()
var _test_team: TeamData = state.teams[0]
var _orig_pos: Vector2i = _test_team.tile_pos
# set off-map target: team should never step off-map
_test_team.move_target = Vector2i(9999, 9999)
for _mi in range(30):
    _ms_test._step_team(state, _test_team)
    assert(state.world.tiles.has(_test_team.tile_pos.x * 1000 + _test_team.tile_pos.y),
        "[BoundaryTest] team must stay on-map (step %d)" % _mi)
_test_team.tile_pos    = _orig_pos
_test_team.move_target = Vector2i(-1, -1)
print("[BoundaryTest] movement boundary guard ok — team stayed on-map for 30 steps")
# ── end movement boundary test ───────────────────────────────────
```

*Spec written: 2026-06-05*
