class_name FactionSystem
extends RefCounted
## Per-turn simulation: resource collection, population dynamics,
## territorial expansion, and inter-faction conflict.

var _world: WorldState
var _msgs:  MessageSystem

func _init(ws: WorldState, ms: MessageSystem) -> void:
	_world = ws
	_msgs  = ms

## Advance all factions by one simulation turn.
func update_turn() -> void:
	for item in _world.factions:
		var f := item as WorldState.FactionData
		_collect_resources(f)
		_update_population(f)
		_try_expand(f)
	_resolve_conflicts()

# ── Resource collection ───────────────────────────────────────────────────────

func _collect_resources(f: WorldState.FactionData) -> void:
	var food_gain := 0.0
	var wood_gain := 0.0
	var ore_gain  := 0.0

	for pos_var in f.territory:
		var pos := pos_var as Vector2i
		var c   := _world.get_cell(pos.x, pos.y)
		if c == null:
			continue
		food_gain += GameConfig.TERRAIN_FOOD_YIELD[c.terrain]
		wood_gain += GameConfig.TERRAIN_WOOD_YIELD[c.terrain]
		ore_gain  += GameConfig.TERRAIN_ORE_YIELD [c.terrain]

	f.food += food_gain
	f.wood += wood_gain
	f.ore  += ore_gain

	# Consume food
	var consumed: float = f.population * GameConfig.FOOD_PER_PERSON
	f.food -= consumed
	if f.food < 0.0:
		f.food = 0.0
		_msgs.emit_message("famine",
			"%s 陷入饑荒！" % f.name, f.outpost_pos, f.id)

# ── Population dynamics ───────────────────────────────────────────────────────

func _update_population(f: WorldState.FactionData) -> void:
	if f.food > 0.0:
		f.population += f.population * GameConfig.GROWTH_RATE
	else:
		f.population -= f.population * GameConfig.STARVATION_RATE

	f.population = max(1.0, f.population)
	# Trickle of new military from population
	f.military   += f.population * 0.001

# ── Expansion ─────────────────────────────────────────────────────────────────

func _try_expand(f: WorldState.FactionData) -> void:
	if f.military < GameConfig.EXPAND_MIL_COST:
		return

	# Gather unclaimed, non-water cells adjacent to owned territory
	var candidates: Array = []
	for pos_var in f.territory:
		var pos := pos_var as Vector2i
		for nb in _neighbors(pos):
			var c := _world.get_cell(nb.x, nb.y)
			if c != null and c.faction_id == -1 \
					and c.terrain != GameConfig.Terrain.WATER \
					and not candidates.has(nb):
				candidates.append(nb)

	if candidates.is_empty():
		return

	var expand_pos: Vector2i = candidates[randi() % candidates.size()]
	var ec := _world.get_cell(expand_pos.x, expand_pos.y)
	if ec != null:
		ec.faction_id = f.id
		f.territory.append(expand_pos)
		f.military   -= GameConfig.EXPAND_MIL_COST * 0.1

		if randf() < 0.08:
			_msgs.emit_message("expansion",
				"%s 向外擴張！" % f.name, f.outpost_pos, f.id)

# ── Conflict resolution ───────────────────────────────────────────────────────

func _resolve_conflicts() -> void:
	for i in range(_world.factions.size()):
		for j in range(i + 1, _world.factions.size()):
			var fa := _world.factions[i] as WorldState.FactionData
			var fb := _world.factions[j] as WorldState.FactionData
			if _are_adjacent(fa, fb):
				_maybe_fight(fa, fb)

func _are_adjacent(fa: WorldState.FactionData, fb: WorldState.FactionData) -> bool:
	return Vector2(fa.outpost_pos).distance_to(Vector2(fb.outpost_pos)) < 35.0

func _maybe_fight(fa: WorldState.FactionData, fb: WorldState.FactionData) -> void:
	if fa.military < GameConfig.CONFLICT_MIN_MIL \
			or fb.military < GameConfig.CONFLICT_MIN_MIL:
		return
	if randf() > GameConfig.CONFLICT_CHANCE:
		return

	var total: float    = fa.military + fb.military
	var fa_ratio: float = fa.military / total
	var fa_loss: float  = fb.military * GameConfig.CONFLICT_MIL_RATIO * (1.0 - fa_ratio)
	var fb_loss: float  = fa.military * GameConfig.CONFLICT_MIL_RATIO * fa_ratio

	fa.military   = max(0.0, fa.military   - fa_loss)
	fb.military   = max(0.0, fb.military   - fb_loss)
	fa.population = max(1.0, fa.population - fa_loss * 0.5)
	fb.population = max(1.0, fb.population - fb_loss * 0.5)

	# Transfer one border cell from the weaker faction to the stronger one
	var loser:  WorldState.FactionData = fa if fa.military < fb.military else fb
	var winner: WorldState.FactionData = fb if loser == fa else fa

	if not loser.territory.is_empty():
		var lost_pos: Vector2i = loser.territory.pick_random()
		loser.territory.erase(lost_pos)
		var lc := _world.get_cell(lost_pos.x, lost_pos.y)
		if lc != null:
			lc.faction_id = winner.id
			winner.territory.append(lost_pos)

	_msgs.emit_message("war",
		"%s 與 %s 爆發衝突！" % [fa.name, fb.name],
		fa.outpost_pos, fa.id)

# ── Utility ───────────────────────────────────────────────────────────────────

func _neighbors(pos: Vector2i) -> Array:
	var result: Array = []
	for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
		var nb: Vector2i = pos + d
		if _world.is_valid_pos(nb):
			result.append(nb)
	return result
