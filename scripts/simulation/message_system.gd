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
