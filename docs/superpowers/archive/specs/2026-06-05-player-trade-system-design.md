# Player Trade System Design

## Goal

Replace the broken `preview_trade` heuristic with an accurate dry-run preview, and add a player offer system: player specifies what to give and what to want, NPC evaluates and accepts/rejects based on economics, values, and memory.

## Architecture

### New file: `scripts/simulation/player_trade_system.gd`

All player-initiated trade logic lives here. NPC auto-trade (`InteractionSystem._resolve_trade`) is untouched.

```
class_name PlayerTradeSystem

get_tradeable_resources(state, pt_id, tgt_id) → Dictionary
preview_offer(state, pt_id, tgt_id, offer)    → Dictionary
evaluate_offer(state, pt_id, tgt_id, offer)   → Dictionary
execute_offer(state, pt_id, tgt_id, offer)    → Dictionary
```

### Offer structure (stored in `player_state["trade_offer"]`)

```gdscript
{
    "player_gives": { "food": 50 },       # resources player offers (may be empty)
    "player_wants": { "material": 20 }    # resources player requests (may be empty)
}
```

Both sides may contain multiple resource types. Either side may be empty (pure gift / pure purchase).

### Shared constants and helpers (copied from `interaction_system.gd`)

```gdscript
const BASE_PRICE: Dictionary = { "food": 2.0, "material": 4.0, ... }   # 13 resource types
const TARGET_PER_POP: Dictionary = { "food": 10.0, "material": 5.0, ... }
const FOOD_RESERVE_TICKS: float = 20.0   # TEST VALUE
const MAX_COIN_PER_TRADE: float = 300.0  # TEST VALUE
const WEAPON_RESERVE_RATIO: float = 0.5  # TEST VALUE — fraction of armed_anon_ratio to keep

var _msg: MessageSystem = MessageSystem.new()

func _local_value(team: TeamData, res: String) -> float:
    if not BASE_PRICE.has(res): return 0.0
    var pop: float   = maxf(float(team.population), 1.0)
    var stock: float = float(team.resources.get(res, 0))
    var target: float = pop * float(TARGET_PER_POP.get(res, 1.0))
    var sr: float = clampf((target - stock) / maxf(target, 1.0), -0.5, 1.0)
    return float(BASE_PRICE[res]) * (1.0 + sr)
```

GDScript has no shared const/function mechanism; `BASE_PRICE`, `TARGET_PER_POP`, and `_local_value` are copied verbatim from `interaction_system.gd`. Any update to either copy must be synced manually.

---

## `get_tradeable_resources`

Returns inventory snapshots and prices for the trade UI.

```gdscript
func get_tradeable_resources(state: WorldState, pt_id: int, tgt_id: int) -> Dictionary:
    # returns:
    {
        "player": { res → current_qty },        # all non-zero player resources
        "target_sellable": { res → max_sellable_qty },  # after reserve deduction
        "prices": { res → _local_value(tgt_team, res) } # NPC's ask price per unit
    }
```

`max_sellable_qty` for NPC:
- food: `max(0, stock - population × 0.1 × FOOD_RESERVE_TICKS)`
- weapon_*: `max(0, stock - population × armed_anon_ratio × WEAPON_RESERVE_RATIO)`
- all others: `max(0, stock)`

---

## `evaluate_offer`

Three-layer evaluation. Returns early on hard failure.

### Layer 1 — Self-preservation (hard reject)

For each resource in `player_wants`:
- Compute `qty_available` (same formula as `get_tradeable_resources`)
- If `offer["player_wants"][res] > qty_available` → `{ accepted: false, reason: "資源不足：" + res }`

### Layer 2 — Economic fairness

```gdscript
# Value everything at NPC's local prices
gives_value = Σ _local_value(tgt_team, res) × qty   for res in player_gives
wants_value = Σ _local_value(tgt_team, res) × qty   for res in player_wants

ratio = gives_value / max(wants_value, 0.01)
```

### Layer 3 — Threshold from values + memory

```gdscript
threshold = 1.0
threshold += leader.values["貪婪"] × 0.3
threshold -= leader.values["信義"] × 0.2
threshold += leader.values["慎重"] × 0.15
threshold += memory_mod   # see below
```

**memory_mod**: scan `leader.memory` for entries with `event_id >= current_tick - 1000`:
- Positive reactions (`"tribute_paid"`, `"alliance_accepted"`, `"trade_positive"`): each `-0.05`, capped at `-0.20`
- Negative reactions (`"tribute_refused"`, `"extortion"`, `"attack"`): each `+0.10`, capped at `+0.40`

**Final decision:**

```gdscript
if ratio >= threshold:
    return { "accepted": true, "reason": "成交", "ratio": ratio, "threshold": threshold }
else:
    var pct: int = roundi(ratio / threshold * 100)
    return { "accepted": false, "reason": "出價不足（%d%%）" % pct, "ratio": ratio, "threshold": threshold }
```

---

## `preview_offer` (dry run)

Calls `evaluate_offer` (does not mutate state). Returns evaluation result plus value summary:

```gdscript
{
    "accepted": bool,
    "reason": String,
    "gives_value": float,
    "wants_value": float,
    "ratio": float,
    "threshold": float
}
```

This replaces `InteractionSystem.preview_trade` for the player flow.

---

## `execute_offer`

Calls `evaluate_offer` first. If rejected, returns early without mutating state.

If accepted:
1. Transfer `player_gives` resources: deduct from player, add to NPC
2. Transfer `player_wants` resources: deduct from NPC, add to player
3. Emit message via `_msg.emit_message` (category: `"trade_done"`)
4. Update NPC leader memory: append `{ "event_id": current_tick, "intensity": "minor", "reaction": "trade_positive" }`
5. Return `{ "ok": true, "msg": "貿易成功" }`

---

## Changes to existing files

### `player_command_system.gd`

**Offer input flow:**

The UI writes the offer directly via `sim_bridge.set_player_input("trade_offer", { "player_gives": {...}, "player_wants": {...} })` before calling `submit_trade_offer`. No `set_trade_offer` command needed.

**New action:**

```gdscript
# Calls PlayerTradeSystem.evaluate_offer + execute_offer
func _action_submit_trade_offer(state, _target_id, _pt, pt_id) -> Dictionary:
    var tid: int = int(state.player_state.get("pending_trade_target", -1))
    var offer: Dictionary = state.player_state.get("trade_offer", {})
    if tid < 0 or offer.is_empty():
        return { "ok": false, "msg": "無待送出的出價" }
    var result := PlayerTradeSystem.new().execute_offer(state, pt_id, tid, offer)
    if result.get("ok"):
        state.player_pending_targets.erase(tid)
        state.player_state.erase("pending_trade_target")
        state.player_state.erase("trade_offer")
    return result
```

**Modified action:**

`_action_confirm_trade`: delegates to `_action_submit_trade_offer` (backward compatibility — existing GUI flow works unchanged).

**Registry addition:**
```gdscript
"submit_trade_offer": _action_submit_trade_offer,
```

### `player_query_api.gd`

`get_trade_preview(state, target_team_id)`:
- Change: call `PlayerTradeSystem.new().get_tradeable_resources(state, pt_id, target_team_id)`
- Return format: `map_query_envelope(true, "ok", "", { "resources": ..., "offer_preview": preview_offer_result })`

### `interaction_system.gd`

No changes. `_resolve_trade` continues to handle NPC-vs-NPC trades unmodified.

---

## Text UI minimal test interface (state: `"trade_offer"`)

New menu state in `text_ui_main.gd`:
- Entered when `action_id == "trade"` and `requires_preview == true`
- Shows:
  - NPC sellable resources + prices (from `get_tradeable_resources`)
  - Player resources available to offer
  - Current offer (if any) + preview acceptance
- Commands:
  - `[1] 賣 <resource> <qty>` → `sim_bridge.set_player_input("trade_offer", {player_gives: {res: qty}, player_wants: {}})`
  - `[2] 買 <resource> <qty>` → `sim_bridge.set_player_input("trade_offer", {player_gives: {}, player_wants: {res: qty}})`
  - `[3] 送出` → `submit_trade_offer`
  - `[4] 取消` → `cancel_trade`
- Display updates after each `set_trade_offer` (shows new preview)

This UI is intentionally minimal. Any interactive menu replacement only touches `text_ui_main.gd` or `popup_layer.gd`; `PlayerTradeSystem` is UI-agnostic.

---

## Error handling

| Condition | Behaviour |
|---|---|
| `player_wants` resource qty > NPC sellable | Layer 1 hard reject, no state mutation |
| `player_gives` resource qty > player stock | `execute_offer` returns `ok=false`, no mutation |
| Both `player_gives` and `player_wants` empty | `execute_offer` returns `ok=false, msg="出價為空"` |
| NPC leader has no PersonData | Values default to 0.5 (neutral), memory_mod = 0 |
| `pending_trade_target` missing on submit | Returns `ok=false, msg="無待確認貿易"` |

---

## Testing (headless)

Add to `scripts/debug/headless_test.gd`:

```gdscript
# PlayerTradeSystem test
var _trade := PlayerTradeSystem.new()
var _res := _trade.get_tradeable_resources(_state, player_tid, npc_tid)
assert(_res.has("player") and _res.has("target_sellable") and _res.has("prices"))

# fair offer: give coin for cheap food
var _offer := { "player_gives": {"coin": 20}, "player_wants": {"food": 5} }
var _eval := _trade.evaluate_offer(_state, player_tid, npc_tid, _offer)
print("[Test] trade evaluate: accepted=%s reason=%s" % [_eval["accepted"], _eval["reason"]])

# preview = no state mutation
var _preview := _trade.preview_offer(_state, player_tid, npc_tid, _offer)
assert(_preview.has("gives_value") and _preview.has("wants_value"))

# execute fair trade
var _exec := _trade.execute_offer(_state, player_tid, npc_tid, _offer)
print("[Test] trade execute: ok=%s msg=%s" % [_exec["ok"], _exec.get("msg", "")])
```

---

*Spec written: 2026-06-05*
