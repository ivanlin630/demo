class_name MessageSystem
extends RefCounted
## Handles delayed message propagation and per-faction knowledge.

# ── MessageData inner class ───────────────────────────────────────────────────

class MessageData:
	## type values: "war" | "famine" | "resource_found" | "expansion"
	var type:        String   = ""
	var description: String   = ""
	var source_pos:  Vector2i = Vector2i.ZERO
	var faction_id:  int      = -1
	var origin_turn:   int   = 0
	var strength:      float = 1.0   # 0.0–1.0; decays over time/distance
	var received_turn: int   = -1    # turn when player personally received this

	func _init(t: String, desc: String, src: Vector2i,
			fid: int, turn: int, s: float = 1.0) -> void:
		type        = t
		description = desc
		source_pos  = src
		faction_id  = fid
		origin_turn = turn
		strength    = s

class PendingDelivery:
	var target_outpost_idx: int      = -1
	var arrive_turn:        int      = 0
	var carrier:            String   = ""
	var payload:            MessageData

	func _init(idx: int, at_turn: int, carrier_type: String, msg: MessageData) -> void:
		target_outpost_idx = idx
		arrive_turn        = at_turn
		carrier            = carrier_type
		payload            = msg

# ── Fields ────────────────────────────────────────────────────────────────────

var _world: WorldState
var _pending: Array = []   # Array[PendingDelivery]
var _rng: RandomNumberGenerator

func _init(ws: WorldState) -> void:
	_world = ws
	_rng = RandomNumberGenerator.new()
	_rng.seed = ws.seed_value + 424242

# ── Public API ────────────────────────────────────────────────────────────────

## Create a new message and immediately propagate it to nearby outposts.
func emit_message(type: String, desc: String,
		source_pos: Vector2i, faction_id: int) -> void:
	var msg := MessageData.new(
		type, desc, source_pos, faction_id, _world.current_turn, 1.0
	)
	_world.global_messages.append(msg)
	_schedule_deliveries(msg)

## Decay message strengths; remove messages that have faded below the threshold.
## Call once per simulation turn.
func update_turn() -> void:
	_process_pending_deliveries()

	for o in _world.outposts:
		var outpost := o as WorldState.OutpostData
		var to_remove: Array = []
		for m in outpost.known_messages:
			var msg := m as MessageData
			msg.strength -= GameConfig.MSG_DECAY_PER_TURN
			if msg.strength < GameConfig.MSG_MIN_STRENGTH:
				to_remove.append(msg)
		for msg in to_remove:
			outpost.known_messages.erase(msg)

	for fvar in _world.factions:
		var f := fvar as WorldState.FactionData
		var expired: Array = []
		for m in f.known_messages:
			var msg := m as MessageData
			msg.strength -= GameConfig.MSG_DECAY_PER_TURN
			if msg.strength < GameConfig.MSG_MIN_STRENGTH:
				expired.append(msg)
		for msg in expired:
			f.known_messages.erase(msg)

## Return the most-recent `count` globally emitted messages (newest last).
func get_recent_messages(count: int) -> Array:
	var n: int = _world.global_messages.size()
	return _world.global_messages.slice(max(0, n - count))

## Expose the in-transit delivery queue (for debug views).
func get_pending_deliveries() -> Array:
	return _pending

## Return subjective, nearby messages that the player can plausibly know.
func get_player_known_messages(player_pos: Vector2i, count: int = 8, radius: int = 8) -> Array:
	var entries: Array = []
	for o in _world.outposts:
		var outpost := o as WorldState.OutpostData
		if _world.hex_distance(player_pos, outpost.pos) > radius:
			continue
		for m in outpost.known_messages:
			var msg := m as MessageData
			entries.append({
				"turn": msg.origin_turn,
				"text": "[T%d][%s] %s" % [
					msg.origin_turn,
					_subjective_confidence(msg.strength),
					_subjective_text(msg)
				]
			})

	if entries.is_empty():
		return []

	entries.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return int(a["turn"]) < int(b["turn"])
	)
	var start: int = int(max(0, entries.size() - count))
	var output: Array = []
	for i in range(start, entries.size()):
		var text: String = str(entries[i]["text"])
		output.append(text)
	return output

# ── Private helpers ───────────────────────────────────────────────────────────

func _schedule_deliveries(msg: MessageData) -> void:
	for i in range(_world.outposts.size()):
		var outpost := _world.outposts[i] as WorldState.OutpostData
		var dist: int = _world.hex_distance(msg.source_pos, outpost.pos)
		if dist > GameConfig.MSG_SPREAD_RADIUS:
			continue

		var strength: float = msg.strength - dist * GameConfig.MSG_DECAY_PER_CELL
		if strength < GameConfig.MSG_MIN_STRENGTH:
			continue

		var delayed := MessageData.new(
			msg.type,
			msg.description,
			msg.source_pos,
			msg.faction_id,
			msg.origin_turn,
			strength
		)

		var carrier: String = _choose_carrier()
		var turns: int = _travel_turns(dist, carrier)
		_pending.append(PendingDelivery.new(
			i, _world.current_turn + turns, carrier, delayed
		))

func _process_pending_deliveries() -> void:
	if _pending.is_empty():
		return

	var remain: Array = []
	for dvar in _pending:
		var delivery := dvar as PendingDelivery
		if delivery.arrive_turn > _world.current_turn:
			remain.append(delivery)
			continue

		if delivery.target_outpost_idx < 0 or delivery.target_outpost_idx >= _world.outposts.size():
			continue
		var outpost := _world.outposts[delivery.target_outpost_idx] as WorldState.OutpostData
		var copy := MessageData.new(
			delivery.payload.type,
			_distort_description(delivery.payload.description, delivery.payload.strength, delivery.carrier),
			delivery.payload.source_pos,
			delivery.payload.faction_id,
			delivery.payload.origin_turn,
			delivery.payload.strength
		)
		outpost.known_messages.append(copy)

		var faction := _world.get_faction(outpost.faction_id)
		if faction != null:
			faction.known_messages.append(copy)

	_pending = remain

func _choose_carrier() -> String:
	var carriers := ["信使", "商旅", "流民", "隊友"]
	return carriers[_rng.randi_range(0, carriers.size() - 1)]

func _travel_turns(dist: int, carrier: String) -> int:
	var speed: float = 1.0
	if carrier == "信使":
		speed = 2.5
	elif carrier == "商旅":
		speed = 1.5
	elif carrier == "流民":
		speed = 1.0
	else:
		speed = 1.2
	var base_turns := int(ceil(float(dist) / speed))
	return max(0, base_turns + _rng.randi_range(0, 2))

func _subjective_confidence(strength: float) -> String:
	if strength >= 0.75:
		return "可靠"
	if strength >= 0.45:
		return "傳聞"
	return "可疑"

func _subjective_text(msg: MessageData) -> String:
	if msg.strength < 0.30:
		# Extremely weak — almost no info survives
		return "某地附近似乎有大事發生。"
	if msg.strength < 0.45:
		# Low strength — vague area + type hint
		match msg.type:
			"war":     return "聽說某處爆發了衝突，傷亡不明。"
			"famine":  return "有人說某地糧食出了問題。"
			"unrest":  return "附近好像不太平，具體不清楚。"
			"collapse": return "聽說某聚落最近狀況很差。"
			_:          return "聽說有大事發生在 %s 附近。" % str(msg.source_pos)
	if msg.strength < 0.75:
		# Medium — general description survives, attribution uncertain
		return "有人提到：%s（消息來源不確定）" % msg.description
	# High strength — full description
	return msg.description

## Apply per-carrier distortion to a description when strength is low.
## Carrier "流民" introduces more noise than "信使".
func _distort_description(desc: String, strength: float, carrier: String) -> String:
	if strength >= 0.75:
		return desc   # high-strength messages pass through clean

	# Carrier-specific distortion probability
	var distort_chance := 0.0
	match carrier:
		"信使":  distort_chance = 0.05   # official messenger: rarely distorts
		"商旅":  distort_chance = 0.20   # merchants exaggerate
		"流民":  distort_chance = 0.45   # refugees: emotionally distorted
		"隊友":  distort_chance = 0.10

	if _rng.randf() > distort_chance:
		return desc

	# Apply distortion templates based on message content
	var distortions: Array = [
		"（據說）" + desc,
		desc + "（但真相不明）",
		desc + "，傷亡人數眾說紛紜。",
		"有人聲稱：" + desc + "，也有人否認此事。",
		"情況比想像中更糟——" + desc,
	]
	return distortions[_rng.randi_range(0, distortions.size() - 1)]

func _manhattan(a: Vector2i, b: Vector2i) -> int:
	return abs(a.x - b.x) + abs(a.y - b.y)
