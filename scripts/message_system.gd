class_name MessageSystem
extends RefCounted
## Handles message creation and propagation between outposts.

# ── MessageData inner class ───────────────────────────────────────────────────

class MessageData:
	## type values: "war" | "famine" | "resource_found" | "expansion"
	var type:        String   = ""
	var description: String   = ""
	var source_pos:  Vector2i = Vector2i.ZERO
	var faction_id:  int      = -1
	var origin_turn: int      = 0
	var strength:    float    = 1.0   # 0.0–1.0; decays over time/distance

	func _init(t: String, desc: String, src: Vector2i,
			fid: int, turn: int, s: float = 1.0) -> void:
		type        = t
		description = desc
		source_pos  = src
		faction_id  = fid
		origin_turn = turn
		strength    = s

# ── Fields ────────────────────────────────────────────────────────────────────

var _world: WorldState

func _init(ws: WorldState) -> void:
	_world = ws

# ── Public API ────────────────────────────────────────────────────────────────

## Create a new message and immediately propagate it to nearby outposts.
func emit_message(type: String, desc: String,
		source_pos: Vector2i, faction_id: int) -> void:
	var msg := MessageData.new(
		type, desc, source_pos, faction_id, _world.current_turn, 1.0
	)
	_world.global_messages.append(msg)
	_spread_to_outposts(msg)

## Decay message strengths; remove messages that have faded below the threshold.
## Call once per simulation turn.
func update_turn() -> void:
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

## Return the most-recent `count` globally emitted messages (newest last).
func get_recent_messages(count: int) -> Array:
	var n: int = _world.global_messages.size()
	return _world.global_messages.slice(max(0, n - count))

# ── Private helpers ───────────────────────────────────────────────────────────

func _spread_to_outposts(msg: MessageData) -> void:
	for o in _world.outposts:
		var outpost := o as WorldState.OutpostData
		var dist: int = _manhattan(msg.source_pos, outpost.pos)
		if dist > GameConfig.MSG_SPREAD_RADIUS:
			continue
		var s: float = msg.strength - dist * GameConfig.MSG_DECAY_PER_CELL
		if s < GameConfig.MSG_MIN_STRENGTH:
			continue
		var copy := MessageData.new(
			msg.type, msg.description, msg.source_pos,
			msg.faction_id, msg.origin_turn, s
		)
		outpost.known_messages.append(copy)
		# Mirror to the owning faction's list
		var faction := _world.get_faction(outpost.faction_id)
		if faction != null:
			faction.known_messages.append(copy)

func _manhattan(a: Vector2i, b: Vector2i) -> int:
	return abs(a.x - b.x) + abs(a.y - b.y)
