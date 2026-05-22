class_name InteractionSystem

const ROUND_CASUALTY_RATE: float    = 0.1
const WOUNDED_TREATMENT_RATE: float = 0.3
const TRIBUTE_RATE: float           = 0.25
const LOOT_RATE: float              = 0.3
const COMBAT_THRESHOLD: float       = 0.7
const COMBAT_ABANDON_THRESHOLD: float = 0.2
const ROUND_READINESS_DRAIN: float  = 0.08
const READINESS_RECOVERY_BASE: float = 0.04
const READINESS_FOOD_COST: float    = 0.05

var _msg: SimMessageSystem

func _init() -> void:
	_msg = SimMessageSystem.new()

# ──────── 主入口 ────────

func process_on_arrival(state: WorldState, arrived_ids: Array, all_team_ids: Array) -> void:
	_tick_readiness(state, all_team_ids)
	_process_ongoing_combat(state, all_team_ids)
	for arrived_id in arrived_ids:
		if not state.teams.has(arrived_id):
			continue
		var arrived: TeamData = state.teams[arrived_id]
		for other_id in all_team_ids:
			if other_id == arrived_id or not state.teams.has(other_id):
				continue
			var other: TeamData = state.teams[other_id]
			if other.tile_pos != arrived.tile_pos:
				continue
			_try_interact(state, arrived_id, other_id)

# ──────── 整備值恢復 + 傷兵治療（交戰中均不進行） ────────

func _tick_readiness(state: WorldState, team_ids: Array) -> void:
	for tid in team_ids:
		var team: TeamData = state.teams[tid]
		if team.combat_target != -1:
			continue
		if team.wounded > 0:
			_treat_wounded(state, team)
		if team.readiness >= 1.0:
			continue
		var deficit: float = 1.0 - team.readiness
		var morale_factor: float = 1.0 - clampf(float(team.unrest_turns) / 30.0, 0.0, 1.0)
		var food_needed: float  = deficit * float(team.population) * READINESS_FOOD_COST
		var food_avail: float   = float(team.resources.get("food", 0))
		var food_used: float    = minf(food_needed, food_avail)
		team.resources["food"]  = food_avail - food_used
		var resource_factor: float = 0.3 + 0.7 * (food_used / maxf(food_needed, 0.001))
		team.readiness = minf(team.readiness + READINESS_RECOVERY_BASE * morale_factor * resource_factor, 1.0)

func _treat_wounded(state: WorldState, team: TeamData) -> void:
	var best_medicine: float = 0.0
	var named_ids: Array = team.advisors + team.members
	if team.leader_id != -1:
		named_ids.append(team.leader_id)
	for pid in named_ids:
		var p: PersonData = state.persons.get(pid)
		if p != null:
			best_medicine = maxf(best_medicine, float(p.skills.get("醫療", 0.0)))
	var food_per_person: float = float(team.resources.get("food", 0)) / maxf(team.population, 1)
	var resource_factor: float = clampf(food_per_person / 2.0, 0.3, 1.0)
	var to_treat: int = mini(maxi(1, int(round(team.wounded * WOUNDED_TREATMENT_RATE))), team.wounded)
	var save_rate: float = (0.1 + best_medicine * 0.6) * resource_factor
	var saved: int = int(round(float(to_treat) * save_rate))
	var died: int  = to_treat - saved
	team.wounded   -= to_treat
	team.population = maxi(team.population - died, 1)
	if died > 0:
		print("[Treat] Team%d 治療 %d 傷兵：救 %d 死 %d (medicine=%.2f)" % [
			team.team_id, to_treat, saved, died, best_medicine])

# ──────── 持續戰鬥結算 ────────

func _process_ongoing_combat(state: WorldState, all_team_ids: Array) -> void:
	var processed: Dictionary = {}
	for tid in all_team_ids:
		if processed.has(tid) or not state.teams.has(tid):
			continue
		var team: TeamData = state.teams[tid]
		var enemy_id: int = team.combat_target
		if enemy_id == -1 or not state.teams.has(enemy_id):
			if enemy_id != -1:
				team.combat_target = -1
			continue
		var enemy: TeamData = state.teams[enemy_id]
		if enemy.combat_target != tid:
			team.combat_target = -1
			continue
		processed[tid]      = true
		processed[enemy_id] = true
		_resolve_combat_round(state, tid, enemy_id)

# ──────── 新互動判斷 ────────

func _try_interact(state: WorldState, id_a: int, id_b: int) -> void:
	var a: TeamData = state.teams[id_a]
	var b: TeamData = state.teams[id_b]
	if a.combat_target != -1 or b.combat_target != -1:
		return
	var same_faction: bool = a.faction_id != -1 and a.faction_id == b.faction_id
	if same_faction:
		return
	if a.current_task == "攻擊":
		_start_combat(state, id_a, id_b)
	elif b.current_task == "攻擊":
		_start_combat(state, id_b, id_a)
	elif a.current_task == "掠奪" and a.readiness >= COMBAT_THRESHOLD:
		if _should_pay_tribute(state, id_b, id_a):
			_resolve_extortion(state, id_a, id_b)
		elif _should_attack(state, id_a, id_b):
			_start_combat(state, id_a, id_b)
	elif b.current_task == "掠奪" and b.readiness >= COMBAT_THRESHOLD:
		if _should_pay_tribute(state, id_a, id_b):
			_resolve_extortion(state, id_b, id_a)
		elif _should_attack(state, id_b, id_a):
			_start_combat(state, id_b, id_a)

# ──────── 決策函式 ────────

func _should_pay_tribute(state: WorldState, def_id: int, atk_id: int) -> bool:
	var def: TeamData = state.teams[def_id]
	if def.current_task == "逃跑":
		return true
	var leader: PersonData = state.persons.get(def.leader_id)
	if leader == null:
		return false
	var survival: float = float(leader.values.get("求生欲", 0.5))
	var caution: float  = float(leader.values.get("慎重", 0.5))
	var honor: float    = float(leader.values.get("義氣", 0.5))
	var weakness: float = _team_strength(state, def_id) / maxf(_team_strength(state, atk_id), 0.01)
	var score: float    = survival * 0.4 + caution * 0.3 - honor * 0.3 + (1.0 - weakness) * 0.3
	return score > 0.4

func _should_attack(state: WorldState, atk_id: int, def_id: int) -> bool:
	var atk: TeamData = state.teams[atk_id]
	var leader: PersonData = state.persons.get(atk.leader_id)
	if leader == null:
		return false
	var ambition: float  = float(leader.values.get("野心", 0.5))
	var caution: float   = float(leader.values.get("慎重", 0.5))
	var greed: float     = float(leader.values.get("貪婪", 0.5))
	var str_ratio: float = _team_strength(state, atk_id) / maxf(_team_strength(state, def_id), 0.01)
	var score: float     = ambition * 0.3 + greed * 0.3 + (str_ratio - 1.0) * 0.2 - caution * 0.5
	return score > 0.0

# ──────── 結算函式 ────────

func _start_combat(state: WorldState, atk_id: int, def_id: int) -> void:
	var atk: TeamData = state.teams[atk_id]
	var def: TeamData = state.teams[def_id]
	atk.combat_target = def_id
	def.combat_target = atk_id
	_msg.emit_message(state, "combat_start",
		"Team %d 對 Team %d 宣戰" % [atk_id, def_id], atk)
	print("[Combat Start] Team%d vs Team%d" % [atk_id, def_id])

func _resolve_combat_round(state: WorldState, id_a: int, id_b: int) -> void:
	var a: TeamData  = state.teams[id_a]
	var b: TeamData  = state.teams[id_b]
	var str_a: float = _team_strength(state, id_a) * a.readiness
	var str_b: float = _team_strength(state, id_b) * b.readiness
	var total: float = str_a + str_b
	var eff_a: int   = maxi(a.population - a.wounded, 1)
	var eff_b: int   = maxi(b.population - b.wounded, 1)

	var loss_a: int = max(int(round(eff_a * str_b / total * ROUND_CASUALTY_RATE)), 0)
	var loss_b: int = max(int(round(eff_b * str_a / total * ROUND_CASUALTY_RATE)), 0)
	a.wounded   += loss_a
	b.wounded   += loss_b
	a.readiness  = maxf(a.readiness - ROUND_READINESS_DRAIN, 0.0)
	b.readiness  = maxf(b.readiness - ROUND_READINESS_DRAIN, 0.0)

	print("[Round] Team%d(rd=%.2f) vs Team%d(rd=%.2f)  wnd+%d/%d  eff=%d/%d" % [
		id_a, a.readiness, id_b, b.readiness, loss_a, loss_b,
		maxi(a.population - a.wounded, 1), maxi(b.population - b.wounded, 1)])

	if maxi(a.population - a.wounded, 1) <= 1:
		_end_combat(state, id_b, id_a)
		return
	if maxi(b.population - b.wounded, 1) <= 1:
		_end_combat(state, id_a, id_b)
		return
	if a.readiness <= COMBAT_ABANDON_THRESHOLD:
		_force_retreat(state, id_a, id_b)
		return
	if b.readiness <= COMBAT_ABANDON_THRESHOLD:
		_force_retreat(state, id_b, id_a)
		return
	_try_retreat(state, id_a, id_b)
	if a.combat_target != -1:
		_try_retreat(state, id_b, id_a)

func _end_combat(state: WorldState, winner_id: int, loser_id: int) -> void:
	var winner: TeamData = state.teams[winner_id]
	var loser: TeamData  = state.teams[loser_id]
	winner.combat_target = -1
	loser.combat_target  = -1
	for res in ["food", "material", "weapon", "money", "goods"]:
		var taken: float = float(loser.resources.get(res, 0)) * LOOT_RATE
		winner.resources[res] = float(winner.resources.get(res, 0)) + taken
		loser.resources[res]  = float(loser.resources.get(res, 0)) - taken
	_msg.emit_message(state, "combat_end",
		"Team %d 擊潰 Team %d" % [winner_id, loser_id], winner)
	print("[Combat End] Team%d 勝 Team%d (rd=%.2f/%.2f wnd=%d/%d)" % [
		winner_id, loser_id, winner.readiness, loser.readiness,
		winner.wounded, loser.wounded])

func _force_retreat(state: WorldState, retreater_id: int, pursuer_id: int) -> void:
	var retreater: TeamData = state.teams[retreater_id]
	var pursuer: TeamData   = state.teams[pursuer_id]
	retreater.combat_target = -1
	pursuer.combat_target   = -1
	print("[Exhaust] Team%d 力竭撤退 (rd=%.2f wnd=%d)" % [
		retreater_id, retreater.readiness, retreater.wounded])

func _resolve_extortion(state: WorldState, atk_id: int, def_id: int) -> void:
	var atk: TeamData = state.teams[atk_id]
	var def: TeamData = state.teams[def_id]
	for res in ["food", "goods", "money"]:
		var tribute: float = float(def.resources.get(res, 0)) * TRIBUTE_RATE
		if tribute > 0.0:
			atk.resources[res] = float(atk.resources.get(res, 0)) + tribute
			def.resources[res] = float(def.resources.get(res, 0)) - tribute
	_msg.emit_message(state, "extortion",
		"Team %d 向 Team %d 收過路費" % [atk_id, def_id], atk)
	print("[Extort] Team%d 勒索 Team%d，Team%d 妥協給付" % [atk_id, def_id, def_id])

func _try_retreat(state: WorldState, team_id: int, enemy_id: int) -> void:
	var team: TeamData = state.teams[team_id]
	if team.combat_target == -1 or team.current_task != "逃跑":
		return
	var leader: PersonData = state.persons.get(team.leader_id)
	var survival: float = 0.5
	if leader != null:
		survival = float(leader.values.get("求生欲", 0.5))
	var str_ratio: float = _team_strength(state, team_id) / maxf(_team_strength(state, enemy_id), 0.01)
	var retreat_chance: float = survival * 0.5 + (1.0 - minf(str_ratio, 1.0)) * 0.3
	if randf() < retreat_chance:
		var enemy: TeamData = state.teams[enemy_id]
		team.combat_target  = -1
		enemy.combat_target = -1
		print("[Retreat] Team%d 成功撤退 (rd=%.2f wnd=%d)" % [team_id, team.readiness, team.wounded])

func _team_strength(state: WorldState, team_id: int) -> float:
	var team: TeamData = state.teams[team_id]
	var leader: PersonData = state.persons.get(team.leader_id)
	var combat_skill: float = 0.0
	if leader != null:
		combat_skill = float(leader.skills.get("戰鬥", 0.0))
	var weapon_bonus: float = 1.0 + float(team.resources.get("weapon", 0)) * 0.02
	var effective_pop: int  = maxi(team.population - team.wounded, 1)
	return float(effective_pop) * (0.5 + combat_skill * 0.5) * weapon_bonus
