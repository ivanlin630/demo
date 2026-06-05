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
const MAX_COIN_PER_TRADE: float   = 300.0  # TEST VALUE — reserved; player offers currently uncapped
const WEAPON_RESERVE_RATIO: float = 0.5    # TEST VALUE — armed_anon_ratio fraction to keep

var _msg: SimMessageSystem = SimMessageSystem.new()

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

	if player_gives.is_empty() and player_wants.is_empty():
		return { "accepted": false, "reason": "出價為空", "ratio": 0.0, "threshold": 1.0 }

	# Guard: all quantities must be positive
	for res in player_gives:
		if float(player_gives[res]) <= 0.0:
			return { "accepted": false, "reason": "無效數量：" + res, "ratio": 0.0, "threshold": 1.0 }
	for res in player_wants:
		if float(player_wants[res]) <= 0.0:
			return { "accepted": false, "reason": "無效數量：" + res, "ratio": 0.0, "threshold": 1.0 }

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
			if int(mem.get("event_id", 0)) < state.world.current_tick - 1000:
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
		"Player(Team%d)↔Team%d 貿易完成" % [pt_id, tgt_id], pt)

	# Update NPC leader memory
	var leader: PersonData = state.persons.get(tgt.leader_id) if tgt.leader_id >= 0 else null
	if leader != null:
		leader.memory.append({
			"event_id": state.world.current_tick,
			"intensity": "minor",
			"reaction": "trade_positive"
		})

	return { "ok": true, "msg": "貿易成功" }
