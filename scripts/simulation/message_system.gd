class_name SimMessageSystem

const HOP_DECAY: float = 0.15
const TIME_DECAY_PER_TICK: float = 0.005

func emit_message(state: WorldState, type: String, description: String, team: TeamData) -> MessageData:
	var msg := MessageData.new()
	msg.id = state.global_messages.size()
	msg.type = type
	msg.description = description
	msg.source_pos = team.tile_pos
	msg.origin_team_id = team.team_id
	msg.origin_tick = state.world.current_tick
	msg.strength = 1.0
	state.global_messages.append(msg)
	if not state.team_known.has(team.team_id):
		state.team_known[team.team_id] = []
	state.team_known[team.team_id].append(msg)
	return msg

func propagate_on_arrival(state: WorldState, arrived_ids: Array, all_team_ids: Array) -> void:
	for arrived_id in arrived_ids:
		if not state.teams.has(arrived_id):
			continue
		var arrived_team: TeamData = state.teams[arrived_id]
		for other_id in all_team_ids:
			if other_id == arrived_id or not state.teams.has(other_id):
				continue
			var other_team: TeamData = state.teams[other_id]
			if other_team.tile_pos != arrived_team.tile_pos:
				continue
			var leader_arrived: PersonData = state.persons.get(arrived_team.leader_id)
			var leader_other: PersonData = state.persons.get(other_team.leader_id)
			if leader_arrived != null:
				_exchange_one_way(state, arrived_id, other_id, leader_arrived)
			if leader_other != null:
				_exchange_one_way(state, other_id, arrived_id, leader_other)

func _exchange_one_way(state: WorldState, from_id: int, to_id: int, carrier: PersonData) -> void:
	if not state.team_known.has(from_id) or state.team_known[from_id].is_empty():
		return
	if not state.team_known.has(to_id):
		state.team_known[to_id] = []
	var known_ids: Dictionary = {}
	for msg in state.team_known[to_id]:
		known_ids[msg.id] = true
	for msg in state.team_known[from_id]:
		if known_ids.has(msg.id):
			continue
		var age: int = state.world.current_tick - msg.origin_tick
		var time_factor: float = maxf(1.0 - float(age) * TIME_DECAY_PER_TICK, 0.1)
		var copy := _copy_message(msg)
		copy.strength = msg.strength * (1.0 - HOP_DECAY) * time_factor
		if copy.strength <= 0.05:
			continue
		match _decide_propagation_mode(carrier):
			"honest":
				state.team_known[to_id].append(copy)
			"unintentional":
				copy.is_distorted = true
				copy.strength *= 0.8
				if randf() < 0.4:
					var offsets := [Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1),
									Vector2i(0,-1), Vector2i(1,-1), Vector2i(-1,1)]
					copy.source_pos += offsets[randi() % offsets.size()]
				state.team_known[to_id].append(copy)
			"malicious":
				copy.is_distorted = true
				copy.strength *= 0.5
				_distort_content(state, copy)
				state.team_known[to_id].append(copy)
			"silent":
				pass

func _decide_propagation_mode(carrier: PersonData) -> String:
	var cunningness: float = float(carrier.skills.get("計謀", 0.0))
	var honor: float = float(carrier.values.get("義氣", 0.5))
	var caution: float = float(carrier.values.get("慎重", 0.5))
	var stress: float = carrier.stress

	var w_honest: float        = maxf(honor * 0.6 + caution * 0.3 - cunningness * 0.2, 0.1)
	var w_unintentional: float = maxf(stress * 0.4 + (1.0 - caution) * 0.2, 0.05)
	var w_malicious: float     = maxf(cunningness * 0.7 - honor * 0.4, 0.0)
	var w_silent: float        = maxf(caution * 0.3 + carrier.fear * 0.3, 0.05)

	var total: float = w_honest + w_unintentional + w_malicious + w_silent
	var roll: float = randf() * total
	if roll < w_honest: return "honest"
	roll -= w_honest
	if roll < w_unintentional: return "unintentional"
	roll -= w_unintentional
	if roll < w_malicious: return "malicious"
	return "silent"

func _distort_content(state: WorldState, msg: MessageData) -> void:
	if randf() < 0.5:
		var ids: Array = state.teams.keys()
		ids.erase(msg.origin_team_id)
		if not ids.is_empty():
			msg.origin_team_id = ids[randi() % ids.size()]
	else:
		var offsets: Array = [
			Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1), Vector2i(0,-1),
			Vector2i(1,-1), Vector2i(-1,1), Vector2i(2,0), Vector2i(-2,0)
		]
		msg.source_pos += offsets[randi() % offsets.size()]

# 實體接觸時交換訊息（需要明確呼叫，不自動）
func exchange_messages(state: WorldState, from_team_id: int, to_team_id: int, person: PersonData) -> void:
	if not state.team_known.has(from_team_id):
		return
	if not state.team_known.has(to_team_id):
		state.team_known[to_team_id] = []

	var age_factor := _time_decay_factor(state, from_team_id)

	for msg in state.team_known[from_team_id]:
		var copy := _copy_message(msg)
		# 熵增失真：hop 衰減 × 時間老化
		copy.strength *= (1.0 - HOP_DECAY) * age_factor
		# 人為失真：依 NPC loyalty 計算
		if randf() > person.loyalty:
			copy.is_distorted = true
			copy.description = "[失真] " + copy.description
		if copy.strength > 0.05:
			state.team_known[to_team_id].append(copy)

func process_pending(_state: WorldState) -> void:
	# 未來：處理 pending delivery queue（據點同步、信使到達）
	pass

func _time_decay_factor(state: WorldState, team_id: int) -> float:
	if not state.team_known.has(team_id) or state.team_known[team_id].is_empty():
		return 1.0
	var oldest_tick: int = state.world.current_tick
	for msg in state.team_known[team_id]:
		if msg.origin_tick < oldest_tick:
			oldest_tick = msg.origin_tick
	var age := state.world.current_tick - oldest_tick
	return maxf(1.0 - age * TIME_DECAY_PER_TICK, 0.1)

func _copy_message(original: MessageData) -> MessageData:
	var copy := MessageData.new()
	copy.id = original.id
	copy.type = original.type
	copy.description = original.description
	copy.source_pos = original.source_pos
	copy.origin_team_id = original.origin_team_id
	copy.origin_tick = original.origin_tick
	copy.strength = original.strength
	copy.is_distorted = original.is_distorted
	return copy
