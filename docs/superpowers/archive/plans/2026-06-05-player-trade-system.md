# Player Trade System Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the heuristic `preview_trade` with an accurate dry-run preview, and add a bidirectional player offer system where NPC evaluates and accepts/rejects based on economics, values, and memory.

**Architecture:** New `PlayerTradeSystem` class handles all player-initiated trade logic (get inventory snapshot, evaluate offer, preview, execute). `player_command_system.gd` and `player_query_api.gd` are updated to delegate to it. NPC auto-trade (`InteractionSystem._resolve_trade`) is untouched.

**Tech Stack:** GDScript 4.2, Godot 4.2.2, headless test runner

---

## File Map

| File | Action | Responsibility |
|---|---|---|
| `scripts/simulation/player_trade_system.gd` | **Create** | All player-trade logic: tradeable snapshot, offer evaluation, preview (no-mutate), execute |
| `scripts/simulation/player_command_system.gd` | **Modify** | Add `_action_submit_trade_offer`; modify `_action_confirm_trade` to delegate; register `submit_trade_offer` |
| `scripts/simulation/player_query_api.gd` | **Modify** | Replace `get_trade_preview` body to call PlayerTradeSystem |
| `scripts/debug/headless_test.gd` | **Modify** | Add PlayerTradeSystem unit tests + submit_trade_offer command test |

---

## Task 1: Create `player_trade_system.gd`

**Files:**
- Create: `scripts/simulation/player_trade_system.gd`
- Modify: `scripts/debug/headless_test.gd` (tests only, no other change)

- [ ] **Step 1: Write failing test in headless_test.gd**

Open `scripts/debug/headless_test.gd`. Find `print("=== DONE ===")` near line 1889. Insert the following block **directly before** that line:

```gdscript
	# ── PlayerTradeSystem tests ──────────────────────────────────────────
	var _trade_sys := PlayerTradeSystem.new()

	# get_tradeable_resources
	var _tr_res := _trade_sys.get_tradeable_resources(state, 0, 1)
	assert(_tr_res.has("player"),          "[TradeTest] missing 'player' key")
	assert(_tr_res.has("target_sellable"), "[TradeTest] missing 'target_sellable' key")
	assert(_tr_res.has("prices"),          "[TradeTest] missing 'prices' key")
	print("[TradeTest] get_tradeable_resources ok")

	# evaluate_offer: fair trade (coin for food)
	var _offer_fair := { "player_gives": {"coin": 20}, "player_wants": {"food": 5} }
	var _eval_fair  := _trade_sys.evaluate_offer(state, 0, 1, _offer_fair)
	print("[TradeTest] evaluate fair: accepted=%s reason=%s ratio=%.2f threshold=%.2f" % [
		str(_eval_fair.get("accepted")),
		str(_eval_fair.get("reason")),
		float(_eval_fair.get("ratio", 0.0)),
		float(_eval_fair.get("threshold", 0.0))])

	# evaluate_offer: empty offer must be rejected
	var _eval_empty := _trade_sys.evaluate_offer(state, 0, 1, {})
	assert(not _eval_empty.get("accepted", true), "[TradeTest] empty offer must be rejected")

	# evaluate_offer: demand more food than available → layer-1 reject
	var _food_stock: float = float(state.teams[1].resources.get("food", 0))
	var _offer_over := { "player_gives": {}, "player_wants": {"food": _food_stock + 9999} }
	var _eval_over  := _trade_sys.evaluate_offer(state, 0, 1, _offer_over)
	assert(not _eval_over.get("accepted", true), "[TradeTest] over-demand must be rejected (layer 1)")
	print("[TradeTest] evaluate_offer layer-1 reject ok: %s" % _eval_over.get("reason", ""))

	# preview_offer: must not mutate state
	var _food_before: float = float(state.teams[1].resources.get("food", 0))
	var _preview     := _trade_sys.preview_offer(state, 0, 1, _offer_fair)
	var _food_after:  float = float(state.teams[1].resources.get("food", 0))
	assert(_food_before == _food_after,          "[TradeTest] preview_offer must not mutate food")
	assert(_preview.has("gives_value"),           "[TradeTest] preview missing gives_value")
	assert(_preview.has("wants_value"),           "[TradeTest] preview missing wants_value")
	print("[TradeTest] preview_offer no-mutate ok  gives=%.2f wants=%.2f" % [
		float(_preview.get("gives_value")),
		float(_preview.get("wants_value"))])

	# execute_offer: run fair trade if accepted; run bad offer if rejected
	var _coin_pt_before:  float = float(state.teams[0].resources.get("coin", 0))
	var _food_tgt_before: float = float(state.teams[1].resources.get("food", 0))
	var _exec := _trade_sys.execute_offer(state, 0, 1, _offer_fair)
	print("[TradeTest] execute_offer: ok=%s msg=%s" % [str(_exec.get("ok")), str(_exec.get("msg", ""))])
	if _exec.get("ok", false):
		assert(float(state.teams[0].resources.get("coin", 0)) < _coin_pt_before,
			"[TradeTest] player coin should decrease after execute")
		assert(float(state.teams[1].resources.get("food", 0)) < _food_tgt_before,
			"[TradeTest] NPC food should decrease after execute")
		print("[TradeTest] execute_offer mutations verified ok")

	# execute_offer: player over-commits their own stock → rejected without mutation
	var _offer_badstock := { "player_gives": {"coin": 999999}, "player_wants": {} }
	var _exec_bad := _trade_sys.execute_offer(state, 0, 1, _offer_badstock)
	assert(not _exec_bad.get("ok", true), "[TradeTest] over-commit player stock must fail")
	print("[TradeTest] execute_offer bad-stock reject ok")
	# ── end PlayerTradeSystem tests ──────────────────────────────────────
```

- [ ] **Step 2: Run test to confirm parse error (class doesn't exist yet)**

```powershell
A:\GDS\demo\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

Expected: Error mentioning `"PlayerTradeSystem"` identifier not found.

- [ ] **Step 3: Create `scripts/simulation/player_trade_system.gd`**

Create the file with the full implementation:

```gdscript
class_name PlayerTradeSystem

# ──────── Constants (synced from interaction_system.gd) ────────
# NOTE: Any update here must also be applied to InteractionSystem's copy.
const BASE_PRICE: Dictionary = {
	"food":              2.0,
	"material":          4.0,
	"goods":             5.0,
	"gem":              20.0,
	"ore_gold":         10.0,
	"ore_silver":        5.0,
	"ore_iron":          8.0,
	"ore_steel":        12.0,
	"weapon_melee_low":  8.0,
	"weapon_melee_high": 18.0,
	"weapon_ranged_low": 9.0,
	"weapon_ranged_high": 20.0,
	"coin":              1.0,   # currency at face value (13th resource type)
}
const TARGET_PER_POP: Dictionary = {
	"food":              10.0,
	"material":           5.0,
	"goods":              3.0,
	"gem":                1.0,
	"ore_gold":           2.0,
	"ore_silver":         3.0,
	"ore_iron":           3.0,
	"ore_steel":          1.5,
	"weapon_melee_low":   1.0,
	"weapon_melee_high":  0.5,
	"weapon_ranged_low":  0.8,
	"weapon_ranged_high": 0.4,
	"coin":              20.0,
}
const FOOD_RESERVE_TICKS: float   = 20.0   # TEST VALUE
const MAX_COIN_PER_TRADE: float   = 300.0  # TEST VALUE
const WEAPON_RESERVE_RATIO: float = 0.5    # TEST VALUE — armed_anon_ratio fraction to keep

var _msg: MessageSystem = MessageSystem.new()

# ──────── Helpers ────────

func _local_value(team: TeamData, res: String) -> float:
	if not BASE_PRICE.has(res): return 0.0
	var pop: float    = maxf(float(team.population), 1.0)
	var stock: float  = float(team.resources.get(res, 0))
	var target: float = pop * float(TARGET_PER_POP.get(res, 1.0))
	var sr: float     = clampf((target - stock) / maxf(target, 1.0), -0.5, 1.0)
	return float(BASE_PRICE[res]) * (1.0 + sr)

func _sellable_qty(team: TeamData, res: String) -> float:
	var stock: float = float(team.resources.get(res, 0))
	if res == "food":
		var reserve: float = float(team.population) * 0.1 * FOOD_RESERVE_TICKS
		return maxf(stock - reserve, 0.0)
	if res.begins_with("weapon_"):
		var reserve: float = float(team.population) * team.armed_anon_ratio * WEAPON_RESERVE_RATIO
		return maxf(stock - reserve, 0.0)
	return maxf(stock, 0.0)

# ──────── Public API ────────

## Returns inventory snapshot and NPC prices for the trade UI.
## result: { "player": {res→qty}, "target_sellable": {res→max_qty}, "prices": {res→value} }
func get_tradeable_resources(state: WorldState, pt_id: int, tgt_id: int) -> Dictionary:
	var pt: TeamData  = state.teams.get(pt_id)
	var tgt: TeamData = state.teams.get(tgt_id)
	if pt == null or tgt == null:
		return {}

	var player_res: Dictionary = {}
	for res in pt.resources:
		if float(pt.resources[res]) > 0.0:
			player_res[res] = pt.resources[res]

	var sellable: Dictionary = {}
	for res in BASE_PRICE.keys():
		var qty: float = _sellable_qty(tgt, res)
		if qty > 0.0:
			sellable[res] = qty

	var prices: Dictionary = {}
	for res in BASE_PRICE.keys():
		prices[res] = _local_value(tgt, res)

	return {
		"player":          player_res,
		"target_sellable": sellable,
		"prices":          prices,
	}

## Evaluate whether NPC accepts the offer. Pure function — no state mutation.
## result: { "accepted": bool, "reason": String, "ratio": float, "threshold": float }
func evaluate_offer(state: WorldState, pt_id: int, tgt_id: int, offer: Dictionary) -> Dictionary:
	var tgt: TeamData = state.teams.get(tgt_id)
	if tgt == null:
		return { "accepted": false, "reason": "目標不存在", "ratio": 0.0, "threshold": 1.0 }

	var player_gives: Dictionary = offer.get("player_gives", {})
	var player_wants: Dictionary = offer.get("player_wants", {})

	# Layer 1 — Self-preservation (hard reject)
	for res in player_wants:
		var want_qty: float = float(player_wants[res])
		var avail: float    = _sellable_qty(tgt, res)
		if want_qty > avail:
			return { "accepted": false, "reason": "資源不足：" + res, "ratio": 0.0, "threshold": 1.0 }

	# Layer 2 — Economic fairness
	var gives_value: float = 0.0
	for res in player_gives:
		gives_value += _local_value(tgt, res) * float(player_gives[res])
	var wants_value: float = 0.0
	for res in player_wants:
		wants_value += _local_value(tgt, res) * float(player_wants[res])

	var ratio: float = gives_value / maxf(wants_value, 0.01)

	# Layer 3 — Values + memory threshold
	var threshold: float = 1.0
	var leader: PersonData = state.persons.get(tgt.leader_id) if tgt.leader_id >= 0 else null
	if leader != null:
		threshold += float(leader.values.get("貪婪", 0.5))  * 0.3
		threshold -= float(leader.values.get("信義", 0.5))  * 0.2
		threshold += float(leader.values.get("慎重", 0.5))  * 0.15
		# Memory modifier
		var pos_count: int = 0
		var neg_count: int = 0
		for mem in leader.memory:
			if int(mem.get("event_id", 0)) < state.current_tick - 1000:
				continue
			var reaction: String = str(mem.get("reaction", ""))
			if reaction in ["tribute_paid", "alliance_accepted", "trade_positive"]:
				pos_count += 1
			elif reaction in ["tribute_refused", "extortion", "attack"]:
				neg_count += 1
		var memory_mod: float = clampf(pos_count * -0.05, -0.20, 0.0) \
		                      + clampf(neg_count *  0.10,  0.00, 0.40)
		threshold += memory_mod
	else:
		# No leader → neutral defaults (0.5 for all values)
		threshold += 0.5 * 0.3
		threshold -= 0.5 * 0.2
		threshold += 0.5 * 0.15

	if ratio >= threshold:
		return { "accepted": true, "reason": "成交", "ratio": ratio, "threshold": threshold }
	else:
		var pct: int = roundi(ratio / threshold * 100)
		return { "accepted": false, "reason": "出價不足（%d%%）" % pct,
		         "ratio": ratio, "threshold": threshold }

## Dry-run preview: calls evaluate_offer, returns result + value summary. No mutation.
## result: { "accepted": bool, "reason": String, "gives_value": float,
##           "wants_value": float, "ratio": float, "threshold": float }
func preview_offer(state: WorldState, pt_id: int, tgt_id: int, offer: Dictionary) -> Dictionary:
	var tgt: TeamData = state.teams.get(tgt_id)
	var eval := evaluate_offer(state, pt_id, tgt_id, offer)

	var gives_value: float = 0.0
	var wants_value: float = 0.0
	if tgt != null:
		for res in offer.get("player_gives", {}).keys():
			gives_value += _local_value(tgt, res) * float(offer["player_gives"][res])
		for res in offer.get("player_wants", {}).keys():
			wants_value += _local_value(tgt, res) * float(offer["player_wants"][res])

	return {
		"accepted":    eval.get("accepted", false),
		"reason":      eval.get("reason",   ""),
		"gives_value": gives_value,
		"wants_value": wants_value,
		"ratio":       eval.get("ratio",     0.0),
		"threshold":   eval.get("threshold", 1.0),
	}

## Execute the offer. Evaluates first; returns early without mutation on failure.
## result: { "ok": bool, "msg": String }
func execute_offer(state: WorldState, pt_id: int, tgt_id: int, offer: Dictionary) -> Dictionary:
	var pt: TeamData  = state.teams.get(pt_id)
	var tgt: TeamData = state.teams.get(tgt_id)
	if pt == null or tgt == null:
		return { "ok": false, "msg": "隊伍不存在" }

	var player_gives: Dictionary = offer.get("player_gives", {})
	var player_wants: Dictionary = offer.get("player_wants", {})

	if player_gives.is_empty() and player_wants.is_empty():
		return { "ok": false, "msg": "出價為空" }

	# Guard: player must own what they offer
	for res in player_gives:
		if float(pt.resources.get(res, 0)) < float(player_gives[res]):
			return { "ok": false, "msg": "玩家資源不足：" + res }

	var eval := evaluate_offer(state, pt_id, tgt_id, offer)
	if not eval.get("accepted", false):
		return { "ok": false, "msg": eval.get("reason", "拒絕") }

	# Transfer player_gives: player → NPC
	for res in player_gives:
		var qty: float = float(player_gives[res])
		pt.resources[res]  = float(pt.resources.get(res, 0))  - qty
		tgt.resources[res] = float(tgt.resources.get(res, 0)) + qty

	# Transfer player_wants: NPC → player
	for res in player_wants:
		var qty: float = float(player_wants[res])
		tgt.resources[res] = float(tgt.resources.get(res, 0)) - qty
		pt.resources[res]  = float(pt.resources.get(res, 0))  + qty

	_msg.emit_message(state, "trade_done",
		"Player(Team%d)↔Team%d 貿易完成" % [pt_id, tgt_id], pt,
		{ "origin": str(pt_id), "target": str(tgt_id) })

	# Update NPC leader memory
	var leader: PersonData = state.persons.get(tgt.leader_id) if tgt.leader_id >= 0 else null
	if leader != null:
		leader.memory.append({
			"event_id": state.current_tick,
			"intensity": "minor",
			"reaction": "trade_positive"
		})

	return { "ok": true, "msg": "貿易成功" }
```

- [ ] **Step 4: Register the new class with Godot**

```powershell
A:\GDS\demo\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --import
```

Expected: completes without error.

- [ ] **Step 5: Run tests**

```powershell
A:\GDS\demo\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

Expected:
- `[TradeTest] get_tradeable_resources ok`
- `[TradeTest] evaluate fair: accepted=...`
- `[TradeTest] evaluate_offer layer-1 reject ok: 資源不足：food`
- `[TradeTest] preview_offer no-mutate ok  gives=... wants=...`
- `[TradeTest] execute_offer: ok=... msg=...`
- `[TradeTest] execute_offer bad-stock reject ok`
- `=== DONE ===`

No `SCRIPT ERROR` anywhere.

- [ ] **Step 6: Commit**

```
git add scripts/simulation/player_trade_system.gd scripts/debug/headless_test.gd
git commit -m "feat(trade): add PlayerTradeSystem with offer evaluation and execution"
```

---

## Task 2: Modify `player_command_system.gd`

**Files:**
- Modify: `scripts/simulation/player_command_system.gd`
- Modify: `scripts/debug/headless_test.gd` (add command-level test)

- [ ] **Step 1: Write failing test**

In `headless_test.gd`, add immediately **after** the last TradeTest block (still before `print("=== DONE ===")`):

```gdscript
	# ── submit_trade_offer command test ─────────────────────────────────
	var _pcs := PlayerCommandSystem.new()
	# Set up trade state manually
	state.player_state["pending_trade_target"] = 1
	state.player_state["trade_offer"] = {
		"player_gives": {"coin": 10},
		"player_wants": {"food": 3}
	}
	# Ensure player has enough coin
	state.teams[0].resources["coin"] = floorf(float(state.teams[0].resources.get("coin", 0)) + 100)
	# Ensure NPC has enough food (it should already from init)
	var _sub_result := _pcs.execute_action(state, 1, "submit_trade_offer")
	print("[TradeTest] submit_trade_offer: ok=%s msg=%s" % [
		str(_sub_result.get("ok")), str(_sub_result.get("msg", ""))])
	# Clean up state in case trade failed (so later assertions aren't affected)
	state.player_state.erase("pending_trade_target")
	state.player_state.erase("trade_offer")
	# ── end submit_trade_offer test ─────────────────────────────────────
```

- [ ] **Step 2: Run to confirm current failure**

```powershell
A:\GDS\demo\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

Expected: `submit_trade_offer: ok=false msg=無待送出的出價` (action not in registry) or similar unknown-action error. No parse error. Test reaches `=== DONE ===`.

- [ ] **Step 3: Add `_action_submit_trade_offer` to `player_command_system.gd`**

Find the `_action_cancel_trade` function (around line 238). Insert the new function **after** `_action_cancel_trade`:

```gdscript
func _action_submit_trade_offer(state: WorldState, _target_id: int, _pt: TeamData, pt_id: int) -> Dictionary:
	var tid: int     = int(state.player_state.get("pending_trade_target", -1))
	var offer: Dictionary = state.player_state.get("trade_offer", {})
	if tid < 0 or offer.is_empty():
		return { "ok": false, "msg": "無待送出的出價" }
	if not state.teams.has(tid):
		return { "ok": false, "msg": "目標隊伍不存在" }
	var result := PlayerTradeSystem.new().execute_offer(state, pt_id, tid, offer)
	if result.get("ok", false):
		state.player_pending_targets.erase(tid)
		state.player_state.erase("pending_trade_target")
		state.player_state.erase("trade_offer")
	return result
```

- [ ] **Step 4: Modify `_action_confirm_trade` to delegate when `trade_offer` is present**

Replace the existing `_action_confirm_trade` body (lines 229–236):

```gdscript
func _action_confirm_trade(state: WorldState, target_id: int, pt: TeamData, pt_id: int) -> Dictionary:
	# If a structured trade_offer is present, delegate to the new offer system
	if state.player_state.has("trade_offer"):
		return _action_submit_trade_offer(state, target_id, pt, pt_id)
	# Legacy fallback: NPC-initiated trade confirmation
	var tid2: int = int(state.player_state.get("pending_trade_target", -1))
	if tid2 < 0 or not state.teams.has(tid2):
		return { "ok": false, "msg": "無待確認貿易" }
	var result2 := _interaction.resolve_trade_direct(state, pt_id, tid2)
	state.player_pending_targets.erase(tid2)
	state.player_state.erase("pending_trade_target")
	return result2
```

- [ ] **Step 5: Add `"submit_trade_offer"` to registry**

In `_setup_registry()`, after `"confirm_trade": _action_confirm_trade,`, add:

```gdscript
		"submit_trade_offer":    _action_submit_trade_offer,
```

- [ ] **Step 6: Run tests**

```powershell
A:\GDS\demo\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

Expected:
- `[TradeTest] submit_trade_offer: ok=true msg=貿易成功` (or `ok=false` with a trade-rejection reason if Team1's NPC threshold is strict — either is valid, the key check is no `SCRIPT ERROR`)
- `=== DONE ===`

- [ ] **Step 7: Commit**

```
git add scripts/simulation/player_command_system.gd scripts/debug/headless_test.gd
git commit -m "feat(trade): add submit_trade_offer command; confirm_trade delegates to offer system"
```

---

## Task 3: Update `player_query_api.gd`

**Files:**
- Modify: `scripts/simulation/player_query_api.gd`

- [ ] **Step 1: Replace `get_trade_preview` body**

Find `get_trade_preview` (lines 91–99 in `player_query_api.gd`). Replace the function body:

```gdscript
func get_trade_preview(state: WorldState, target_team_id: int) -> Dictionary:
	var check := _check_player_with_team(state)
	if check["code"] != "ok":
		return PlayerApiMapper.map_query_envelope(false, check["code"], check["msg"], {})
	var p: PersonData  = state.persons[state.player_id]
	var pt_id: int     = p.team_id
	var trade          := PlayerTradeSystem.new()
	var resources      := trade.get_tradeable_resources(state, pt_id, target_team_id)
	var offer: Dictionary = state.player_state.get("trade_offer", {})
	var preview: Dictionary = {}
	if not offer.is_empty():
		preview = trade.preview_offer(state, pt_id, target_team_id, offer)
	return PlayerApiMapper.map_query_envelope(true, "ok", "", {
		"resources":    resources,
		"offer_preview": preview,
	})
```

- [ ] **Step 2: Run full headless test**

```powershell
A:\GDS\demo\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

Expected: `=== DONE ===` with no `SCRIPT ERROR`.

- [ ] **Step 3: Commit**

```
git add scripts/simulation/player_query_api.gd
git commit -m "feat(trade): get_trade_preview now uses PlayerTradeSystem (accurate dry-run)"
```

---

## Task 4: Write hand-back and push

- [ ] **Step 1: Run 1000-tick stress test to confirm no crash**

The headless_test already runs 1000 ticks. Verify `=== DONE ===` appears.

- [ ] **Step 2: Write hand-back document**

Create `docs/superpowers/handbacks/2026-06-05-player-trade-system.md`:

```markdown
# Hand Back: Player Trade System

## 實作摘要

- `scripts/simulation/player_trade_system.gd` — 新建。PlayerTradeSystem class：`get_tradeable_resources`、`evaluate_offer`（三層審核）、`preview_offer`（dry-run）、`execute_offer`
- `scripts/simulation/player_command_system.gd` — 新增 `_action_submit_trade_offer`；修改 `_action_confirm_trade` 檢查 `trade_offer` key 並委派；registry 加入 `submit_trade_offer`
- `scripts/simulation/player_query_api.gd` — `get_trade_preview` 改呼叫 PlayerTradeSystem，返回 resources + offer_preview
- `scripts/debug/headless_test.gd` — 加入 PlayerTradeSystem 單元測試 + submit_trade_offer 指令測試
- BASE_PRICE 新增 `"coin": 1.0`（TARGET_PER_POP `"coin": 20.0`）作為第 13 種資源，讓玩家可用 coin 出價

與 spec 無差異，除：`coin` 加入 BASE_PRICE（spec 說 13 種但未列出，推斷為 coin）。

## 連動風險

- `interaction_system.gd` BASE_PRICE 仍為 12 種（無 coin）。PlayerTradeSystem 多了 coin。若未來需統一，須同步更新。
- `_action_confirm_trade` 的 legacy fallback（無 trade_offer 時呼叫 `resolve_trade_direct`）仍存在，保持向後相容。

## 待主 session 確認

- coin 加入 BASE_PRICE 的決策是否正確？或 coin 應以特殊方式處理（face-value only）？
- `interaction_system.gd` 的 BASE_PRICE 是否需同步加入 coin？
```

- [ ] **Step 3: Commit hand-back, push branch**

```
git add docs/superpowers/handbacks/2026-06-05-player-trade-system.md
git commit -m "docs: add hand-back for player-trade-system"
git push -u origin HEAD
```

---

## Self-Review Checklist

**Spec coverage:**
- `get_tradeable_resources` → Task 1 ✓
- `preview_offer` (dry-run, replaces heuristic) → Task 1 ✓, Task 3 ✓
- `evaluate_offer` three layers → Task 1 ✓
- `execute_offer` transfers + memory update → Task 1 ✓
- `_action_submit_trade_offer` + registry → Task 2 ✓
- `_action_confirm_trade` delegation → Task 2 ✓
- `get_trade_preview` API update → Task 3 ✓
- Headless tests → Task 1 + Task 2 ✓
- Error cases (empty offer, over-demand, player stock) → Task 1 test coverage ✓
- NPC leader no PersonData → default neutral handled in `evaluate_offer` ✓

**No placeholders:** All code blocks are complete. No TBD/TODO.

**Type consistency:** `execute_offer` returns `{ "ok": bool, "msg": String }` throughout. `evaluate_offer` returns `{ "accepted": bool, "reason": String, "ratio": float, "threshold": float }` everywhere it's called. `preview_offer` returns superset of evaluate_offer with added `gives_value`/`wants_value` floats.
