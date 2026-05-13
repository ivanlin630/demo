class_name FactionSystem
extends RefCounted
## Per-turn simulation refactored for Q-010 NPC-layer model:
## - Resources collected into shared faction pool
## - Distribution driven by lord NPC traits
## - Population/military/labor derived from NPC aggregation (not independent values)

var _world: WorldState
var _msgs:  MessageSystem
var _war_last_turn_by_pair: Dictionary = {}

func _init(ws: WorldState, ms: MessageSystem) -> void:
	_world = ws
	_msgs  = ms

## Advance all factions by one simulation turn (refactored for Q-010).
func update_turn() -> void:
	# Phase 1: Collect resources from territory
	for item in _world.factions:
		var f := item as WorldState.FactionData
		_collect_resources(f)

	# Phase 2: Distribute resources via lord NPC decision + update NPC satisfaction
	for item in _world.factions:
		var f := item as WorldState.FactionData
		_distribute_resources(f)
		_check_npc_satisfaction(f)

	# Phase 3: Recalculate faction-level aggregates from NPC layer
	for item in _world.factions:
		var f := item as WorldState.FactionData
		_recalc_faction_stats(f)  # populate cached_* fields

	# Phase 4: Check settlement needs and emit events
	for item in _world.factions:
		var f := item as WorldState.FactionData
		_check_faction_needs(f)

	# Phase 5: Expansion & conflict
	for item in _world.factions:
		var f := item as WorldState.FactionData
		f.march_tick_acc += GameConfig.TURN_TO_TICK
		var march_cost := _get_march_tick_cost(f)
		if f.march_tick_acc >= march_cost:
			f.march_tick_acc -= march_cost
			_try_expand(f)
	_resolve_conflicts()

## Tick cost for one NPC expansion step – mirrors the player speed formula.
func _get_march_tick_cost(f: WorldState.FactionData) -> int:
	return clampi(
		roundi(float(GameConfig.BASE_MOVE_TICK_COST) / f.speed_factor),
		GameConfig.MIN_MOVE_TICK_COST,
		GameConfig.MAX_MOVE_TICK_COST
	)

# ── Phase 1: Resource collection ──────────────────────────────────────────────

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

	# Consumption is deferred to Phase 4 (needs check), based on peasant population

# ── Phase 2: Resource distribution (Q-010 Phase B) ───────────────────────────

## Lord NPCs collectively decide the food allocation ratios each turn.
func _distribute_resources(f: WorldState.FactionData) -> void:
	if f.lord_npcs.is_empty() or f.squad_npcs.is_empty() or f.peasant_npcs.is_empty():
		return

	# Average lord traits to determine allocation policy
	var lord_militarism := 0.0
	var lord_greed      := 0.0
	var lord_fear       := 0.0
	for nvar in f.lord_npcs:
		var n := nvar as WorldState.NpcEntityData
		lord_militarism += n.militarism
		lord_greed      += n.greed
		lord_fear       += n.fear
	var lc := float(f.lord_npcs.size())
	lord_militarism /= lc
	lord_greed      /= lc
	lord_fear       /= lc

	# Compute allocation ratios
	var squad_ratio   := clampf(
		GameConfig.NPC_ALLOC_BASE_SQUAD + lord_militarism * 0.3 + lord_fear * 0.2,
		0.10, 0.70)
	var reserve_ratio := clampf(
		GameConfig.NPC_ALLOC_BASE_RESERVE + lord_greed * 0.2,
		0.00, 0.40)
	var peasant_ratio := clampf(1.0 - squad_ratio - reserve_ratio, 0.05, 0.80)

	# Satisfaction delta vs expected split (squad 35%, peasant 55%)
	var squad_delta   := (squad_ratio   - 0.35) * 0.5
	var peasant_delta := (peasant_ratio - 0.55) * 0.5
	var lord_delta    := (reserve_ratio - GameConfig.NPC_ALLOC_BASE_RESERVE) * 0.3

	# Extra penalty when food pool ran out this turn
	var famine_mult := -0.15 if f.food <= 0.0 else 0.0
	_update_group_satisfaction(f.squad_npcs,   squad_delta   + famine_mult)
	_update_group_satisfaction(f.peasant_npcs, peasant_delta + famine_mult * 1.5)
	_update_group_satisfaction(f.lord_npcs,    lord_delta    + famine_mult * 0.5)

func _update_group_satisfaction(group: Array, delta: float) -> void:
	for nvar in group:
		var n := nvar as WorldState.NpcEntityData
		n.satisfaction = clampf(n.satisfaction + delta, 0.0, 1.0)

func _avg_satisfaction(group: Array) -> float:
	if group.is_empty():
		return 1.0
	var total := 0.0
	for nvar in group:
		var n := nvar as WorldState.NpcEntityData
		total += n.satisfaction
	return total / float(group.size())

# ── Phase 2b: NPC satisfaction checks (Q-010 Phase C) ──────────────────────────

## When a group's average satisfaction falls below threshold, emit an event
## and apply a mechanical penalty to the matching faction stat.
func _check_npc_satisfaction(f: WorldState.FactionData) -> void:
	var squad_avg   := _avg_satisfaction(f.squad_npcs)
	var peasant_avg := _avg_satisfaction(f.peasant_npcs)

	if squad_avg < GameConfig.NPC_SATISFACTION_LOW:
		_emit_faction_event(
			f, "squad_unrest", "unrest",
			"%s 衛隊不滿分配，士氣低落！" % f.name,
			GameConfig.EVENT_LABOR_COOLDOWN
		)

	if peasant_avg < GameConfig.NPC_SATISFACTION_LOW:
		_emit_faction_event(
			f, "peasant_unrest", "unrest",
			"%s 平民怨聲載道，生產意願下降！" % f.name,
			GameConfig.EVENT_LABOR_COOLDOWN
		)

# ── Phase 3: Faction-level stat recalculation ─────────────────────────────────

## Recalculate cached faction stats by aggregating NPC data.
func _recalc_faction_stats(f: WorldState.FactionData) -> void:
	# Population = sum of peasant NPC population
	f.cached_population = 0.0
	for nvar in f.peasant_npcs:
		var n := nvar as WorldState.NpcEntityData
		# Peasant population scales with satisfaction
		var base_pop := 50.0  # base population per peasant NPC
		var satisfaction_mult := 1.0 + (n.satisfaction - 0.5) * 0.4  # ±20% based on satisfaction
		f.cached_population += base_pop * satisfaction_mult

	# Military = sum of squad NPC strength
	f.cached_military = 0.0
	for nvar in f.squad_npcs:
		var n := nvar as WorldState.NpcEntityData
		var base_mil := 15.0  # base military per squad NPC
		var satisfaction_mult := 1.0 + (n.satisfaction - 0.5) * 0.3  # ±15% based on satisfaction
		f.cached_military += base_mil * satisfaction_mult

	# Labor = peasant population * labor ratio, scaled by satisfaction
	var labor_mult := 1.0
	var peasant_avg := _avg_satisfaction(f.peasant_npcs)
	labor_mult = 0.5 + peasant_avg * 1.0  # 0.5x to 1.5x
	f.cached_labor = f.cached_population * GameConfig.LABOR_FROM_POP_RATIO * labor_mult

	# Safety = military scaled with squad satisfaction
	var squad_avg := _avg_satisfaction(f.squad_npcs)
	var safety_mult := 0.5 + squad_avg * 1.0
	f.cached_safety = clamp(
		f.cached_military * GameConfig.SAFETY_FROM_MIL_RATIO * safety_mult,
		0.0, 100.0
	)

# ── Phase 4: Settlement needs & events ────────────────────────────────────────

## Check population/labor/safety needs and emit events.
func _check_faction_needs(f: WorldState.FactionData) -> void:
	# Food consumption
	var consumed := f.cached_population * GameConfig.FOOD_PER_PERSON
	f.food -= consumed
	if f.food < 0.0:
		f.food = 0.0
		_emit_faction_event(
			f,
			"famine",
			"famine",
			"%s 陷入饑荒！" % f.name,
			GameConfig.EVENT_FAMINE_COOLDOWN
		)

	# Labor shortage check
	if not f.is_armed_group and f.cached_labor < GameConfig.LABOR_MIN_THRESHOLD:
		_emit_faction_event(
			f,
			"labor_shortage",
			"unrest",
			"%s 勞力短缺，生產受阻！" % f.name,
			GameConfig.EVENT_LABOR_COOLDOWN
		)

	# Safety check → unrest
	# (Note: unrest_turns field removed; satisfaction tracks this now)
	if f.cached_safety < GameConfig.SAFETY_MIN_THRESHOLD:
		_msgs.emit_message("unrest",
			"%s 治安惡化，居民人心惶惶！" % f.name, f.outpost_pos, f.id)

# ── Expansion ─────────────────────────────────────────────────────────────────

func _try_expand(f: WorldState.FactionData) -> void:
	if f.cached_military < GameConfig.EXPAND_MIL_COST:
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
		# Reduce squad NPC satisfaction when sent to expand
		_update_group_satisfaction(f.squad_npcs, -0.05)

		if randf() < 0.20:
			_emit_faction_event(
				f,
				"expansion",
				"expansion",
				"%s 向外擴張！" % f.name,
				GameConfig.EVENT_EXPANSION_COOLDOWN
			)

# ── Conflict resolution ───────────────────────────────────────────────────────

func _resolve_conflicts() -> void:
	for i in range(_world.factions.size()):
		for j in range(i + 1, _world.factions.size()):
			var fa := _world.factions[i] as WorldState.FactionData
			var fb := _world.factions[j] as WorldState.FactionData
			if _are_adjacent(fa, fb):
				_maybe_fight(fa, fb)

func _are_adjacent(fa: WorldState.FactionData, fb: WorldState.FactionData) -> bool:
	for pos_var in fa.territory:
		var pos := pos_var as Vector2i
		for nb in _world.get_hex_neighbors(pos):
			var c := _world.get_cell(nb.x, nb.y)
			if c != null and c.faction_id == fb.id:
				return true
	return _world.hex_distance(fa.outpost_pos, fb.outpost_pos) <= 6

func _maybe_fight(fa: WorldState.FactionData, fb: WorldState.FactionData) -> void:
	if fa.cached_military < GameConfig.CONFLICT_MIN_MIL \
			or fb.cached_military < GameConfig.CONFLICT_MIN_MIL:
		return
	if randf() > GameConfig.CONFLICT_CHANCE:
		return

	var total: float    = fa.cached_military + fb.cached_military
	var fa_ratio: float = fa.cached_military / total
	var fa_loss: float  = fb.cached_military * GameConfig.CONFLICT_MIL_RATIO * (1.0 - fa_ratio)
	var fb_loss: float  = fa.cached_military * GameConfig.CONFLICT_MIL_RATIO * fa_ratio

	# Reduce squad satisfaction when in conflict
	_update_group_satisfaction(fa.squad_npcs, -0.10)
	_update_group_satisfaction(fb.squad_npcs, -0.10)

	# Transfer one border cell from the weaker faction to the stronger one
	var loser:  WorldState.FactionData = fa if fa.cached_military < fb.cached_military else fb
	var winner: WorldState.FactionData = fb if loser == fa else fa

	if not loser.territory.is_empty():
		var lost_pos: Vector2i = loser.territory.pick_random()
		loser.territory.erase(lost_pos)
		var lc := _world.get_cell(lost_pos.x, lost_pos.y)
		if lc != null:
			lc.faction_id = winner.id
			winner.territory.append(lost_pos)

	var a_id: int = mini(fa.id, fb.id)
	var b_id: int = maxi(fa.id, fb.id)
	var pair_key: String = "%d-%d" % [a_id, b_id]
	var last_war_turn: int = int(_war_last_turn_by_pair.get(pair_key, -999999))
	if _world.current_turn - last_war_turn >= GameConfig.EVENT_WAR_COOLDOWN:
		_msgs.emit_message("war",
			"%s 與 %s 爆發衝突！" % [fa.name, fb.name],
			fa.outpost_pos, fa.id)
		_war_last_turn_by_pair[pair_key] = _world.current_turn

func _can_emit_faction_event(f: WorldState.FactionData, key: String, cooldown: int) -> bool:
	var last_turn: int = int(f.event_last_turns.get(key, -999999))
	return _world.current_turn - last_turn >= cooldown

func _emit_faction_event(
		f: WorldState.FactionData,
		key: String,
		message_type: String,
		description: String,
		cooldown: int) -> void:
	if not _can_emit_faction_event(f, key, cooldown):
		return
	_msgs.emit_message(message_type, description, f.outpost_pos, f.id)
	f.event_last_turns[key] = _world.current_turn

# ── Utility ───────────────────────────────────────────────────────────────────

func _neighbors(pos: Vector2i) -> Array:
	return _world.get_hex_neighbors(pos)
