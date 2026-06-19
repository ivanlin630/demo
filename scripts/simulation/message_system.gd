class_name SimMessageSystem

const MSG_TTL_SHORT:  int = 1680   # 7天  × 240 ticks/day
const MSG_TTL_MEDIUM: int = 3360   # 14天
const MSG_TTL_LONG:   int = 7200   # 30天 = TICKS_PER_MONTH

const MSG_TTL_BY_TYPE: Dictionary = {
	"combat_start":      MSG_TTL_SHORT,
	"famine_warning":    MSG_TTL_SHORT,
	"diplomacy":         MSG_TTL_SHORT,
	"trade_done":        MSG_TTL_MEDIUM,
	"extortion":         MSG_TTL_MEDIUM,
	"tribute":           MSG_TTL_MEDIUM,
	"order_delivered":   MSG_TTL_MEDIUM,
	"combat_end":        MSG_TTL_LONG,
	"subjugate":         MSG_TTL_LONG,
	"faction_establish": MSG_TTL_LONG,
	"outpost_built":     MSG_TTL_LONG,
}
const MSG_TTL_DEFAULT: int = MSG_TTL_MEDIUM

const HOP_DECAY: float = 0.15
const TIME_DECAY_PER_HOUR: float = 0.005
const TIME_DECAY_PER_TICK: float = TIME_DECAY_PER_HOUR / float(WorldState.TICKS_PER_HOUR)

func emit_message(state: WorldState, type: String, description: String,
		team: TeamData, params: Dictionary = {}) -> MessageData:
	var msg := MessageData.new()
	msg.id = state.global_messages.size()
	msg.type = type
	msg.description = description
	msg.source_pos = team.tile_pos
	msg.origin_team_id = team.team_id
	msg.origin_tick = state.world.current_tick
	msg.strength = 1.0
	msg.params = params
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
			msg.params["origin"] = str(msg.origin_team_id)
	else:
		var offsets: Array = [
			Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1), Vector2i(0,-1),
			Vector2i(1,-1), Vector2i(-1,1), Vector2i(2,0), Vector2i(-2,0)
		]
		msg.source_pos += offsets[randi() % offsets.size()]
		msg.params["x"] = str(msg.source_pos.x)
		msg.params["y"] = str(msg.source_pos.y)
	if TextBank.TEMPLATES.has(msg.type):
		msg.description = TextBank.fmt(msg.type, "malicious", msg.params)

func exchange_intel_on_arrival(state: WorldState, arrived_ids: Array, all_team_ids: Array) -> void:
	for arrived_id in arrived_ids:
		var arrived: TeamData = state.teams.get(arrived_id)
		if arrived == null: continue
		for other_id in all_team_ids:
			if other_id == arrived_id: continue
			var other: TeamData = state.teams.get(other_id)
			if other == null or other.tile_pos != arrived.tile_pos: continue
			_exchange_intel(state, arrived_id, other_id)
			_exchange_intel(state, other_id, arrived_id)

func _distort_intel_entry(entry: Dictionary, mode: String) -> Dictionary:
	var e: Dictionary = entry.duplicate()
	match mode:
		"honest":
			e["population_est"] = roundi(float(e.get("population_est", 0)) * randf_range(0.9, 1.1))
		"unintentional":
			e["population_est"] = roundi(float(e.get("population_est", 0)) * randf_range(0.6, 1.5))
			e["tile_pos"] = e.get("tile_pos", Vector2i.ZERO) + \
				Vector2i(randi_range(-2, 2), randi_range(-2, 2))
			if randf() < 0.3:
				var tasks: Array = ["idle", "攻擊", "貿易", "生產", "偵查"]
				e["current_task"] = tasks[randi() % tasks.size()]
		"malicious":
			e["population_est"] = roundi(float(e.get("population_est", 0)) * randf_range(0.2, 3.0))
			e["tile_pos"] = e.get("tile_pos", Vector2i.ZERO) + \
				Vector2i(randi_range(-6, 6), randi_range(-6, 6))
			if randf() < 0.4:
				var tasks2: Array = ["idle", "攻擊", "貿易", "生產", "偵查"]
				e["current_task"] = tasks2[randi() % tasks2.size()]
		"silent":
			return {}
	e["confidence"]    = clampf(float(e.get("confidence", 1.0)) * (1.0 - HOP_DECAY), 0.0, 1.0)
	e["is_suspicious"] = false
	return e

func _decide_exchange_mode(state: WorldState, giver: TeamData, receiver: TeamData) -> String:
	if state.player_hostile_teams.has(receiver.team_id):
		return "malicious" if randf() < 0.3 else "silent"
	if giver.faction_id != -1 and giver.faction_id == receiver.faction_id:
		return "honest"
	var rep: float = float(giver.known_reputations.get(receiver.team_id, 0.5))
	var leader: PersonData = state.persons.get(giver.leader_id)
	var cunningness: float = float(leader.skills.get("計謀", 0.0)) if leader else 0.0
	var caution: float     = float(leader.values.get("慎重", 0.5)) if leader else 0.5
	var eff_rep: float     = rep * (1.0 - caution * 0.3)
	if cunningness > 0.5 and eff_rep < 0.4:
		return "malicious"
	if eff_rep > 0.6:
		return "honest"
	if eff_rep > 0.3:
		return "unintentional"
	return "silent"

# 真來源類別（vs distort mode）：同 faction→隊友、商隊 tag→商旅、else→流民。
func _claim_source_type(giver: TeamData, receiver: TeamData) -> String:
	if giver.faction_id != -1 and giver.faction_id == receiver.faction_id:
		return "隊友"
	if giver.tags.has("商隊"):
		return "商旅"
	return "流民"

func _exchange_intel(state: WorldState, giver_id: int, receiver_id: int) -> void:
	var giver: TeamData    = state.teams.get(giver_id)
	var receiver: TeamData = state.teams.get(receiver_id)
	if giver == null or receiver == null: return

	var mode: String = _decide_exchange_mode(state, giver, receiver)
	if mode == "silent": return

	var giver_known: Array = state.team_known.get(giver_id, [])
	if not state.team_known.has(receiver_id):
		state.team_known[receiver_id] = []
	for msg in giver_known:
		var already: bool = false
		for existing in state.team_known[receiver_id]:
			if existing.id == msg.id: already = true; break
		if already: continue
		var copy: MessageData = _copy_message(msg)
		if mode in ["unintentional", "malicious"]:
			copy.is_distorted = true
			copy.strength *= 0.8
			_distort_content(state, copy)
		state.team_known[receiver_id].append(copy)

	var rep2: float = float(giver.known_reputations.get(receiver_id, 0.5))
	if rep2 < 0.3 and (giver.faction_id == -1 or giver.faction_id != receiver.faction_id):
		return
	for tgt_id in BeliefSystem.known_targets(state, giver_id):
		if tgt_id == receiver_id: continue
		var src_val: Dictionary = BeliefSystem.best_estimate(state, giver_id, tgt_id)
		var entry: Dictionary = _distort_intel_entry(src_val, mode)
		if entry.is_empty(): continue
		# 真來源類別 + 可信度公式（hop 只算一次 → 修 G3b relay 雙重 HOP debt）
		var stype: String = _claim_source_type(giver, receiver)
		var cred: float = BeliefSystem.source_credibility(state, receiver_id, stype, giver_id, 1)
		var distorted: bool = mode in ["unintentional", "malicious"]
		# G3c-2 技能識破：distorted claim 按「我理解力 vs 對方計謀」折 cred + 標疑點。
		# 非 un-distort：claim.value 不動，只壓信（best_estimate cred 排序吃）。
		if distorted:
			var recv_leader: PersonData = state.persons.get(receiver.leader_id)
			var giver_leader: PersonData = state.persons.get(giver.leader_id)
			var my_skill: float = 0.0
			if recv_leader:
				my_skill = maxf(float(recv_leader.skills.get("偵查", 0.0)), float(recv_leader.skills.get("計謀", 0.0)))
			var their_scheme: float = float(giver_leader.skills.get("計謀", 0.0)) if giver_leader else 0.0
			var det: Dictionary = BeliefSystem.detection_discount(my_skill, their_scheme)
			cred *= float(det["discount"])
			entry["is_suspicious"] = bool(det["suspicious"])
		BeliefSystem.record_claim(state, receiver_id, tgt_id, giver_id, stype, entry, cred, distorted)

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
	copy.params = original.params.duplicate()
	return copy

func prune_old_messages(state: WorldState, current_tick: int) -> void:
	# Prune global_messages
	var keep: Array = []
	for msg in state.global_messages:
		var ttl: int = MSG_TTL_BY_TYPE.get(msg.type, MSG_TTL_DEFAULT)
		if current_tick - msg.origin_tick <= ttl:
			keep.append(msg)
	var pruned_global: int = state.global_messages.size() - keep.size()
	state.global_messages = keep

	# Prune team_known for each team
	var pruned_known: int = 0
	for tid in state.team_known:
		var fresh: Array = []
		for msg in state.team_known[tid]:
			var ttl: int = MSG_TTL_BY_TYPE.get(msg.type, MSG_TTL_DEFAULT)
			if current_tick - msg.origin_tick <= ttl:
				fresh.append(msg)
		pruned_known += state.team_known[tid].size() - fresh.size()
		state.team_known[tid] = fresh

	if pruned_global + pruned_known > 0:
		print("[MsgPrune] 刪除過期訊息 global=%d known=%d" % [pruned_global, pruned_known])
