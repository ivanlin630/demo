class_name SalarySystem

const SALARY_INTERVAL: int = WorldState.TICKS_PER_DAY * 7   # 1週/次
const SALARY_PER_SKILL_POINT: float = 2.0   # TEST VALUE
const OVERPAY_BONUS: float     = 0.02  # TEST VALUE
const SALARY_LOYALTY_PENALTY: float = 0.03  # TEST VALUE
const MAX_LOYALTY: float       = 0.95

var _npc_ai: NpcAiSystem

func _init() -> void:
	_npc_ai = NpcAiSystem.new()

func tick(state: WorldState, team_ids: Array) -> void:
	if state.world.current_tick % SALARY_INTERVAL != 0:
		return
	for tid in team_ids:
		var team: TeamData = state.teams.get(tid)
		if team == null: continue
		_pay_salary(state, team)

func _calc_fair_salary(p: PersonData) -> float:
	var total: float = 0.0
	for v in p.skills.values():
		total += float(v)
	return total * SALARY_PER_SKILL_POINT

func _pay_salary(state: WorldState, team: TeamData) -> void:
	for pid in team.named_members:
		var p: PersonData = state.persons.get(pid)
		if p == null: continue
		if _has_master_memory(p, team.leader_id): continue
		var fair: float = _calc_fair_salary(p)
		var ratio: float = p.salary / maxf(fair, 0.01)
		team.resources["coin"] = float(team.resources.get("coin", 0)) - p.salary
		p.coin += p.salary
		if ratio >= 1.0:
			p.loyalty = minf(p.loyalty + (ratio - 1.0) * OVERPAY_BONUS, MAX_LOYALTY)
			var intensity: float = clampf((ratio - 1.0) * 0.5, 0.05, 0.8)  # TEST VALUE
			_npc_ai.write_memory(p, "kindness", team.leader_id,
				state.world.current_tick, intensity)
		else:
			p.loyalty -= (1.0 - ratio) * SALARY_LOYALTY_PENALTY
	var anon_count: int = team.population - team.named_members.size() - 1
	var anon_total: float = team.anon_wage * maxf(anon_count, 0)
	team.resources["coin"] = float(team.resources.get("coin", 0)) - anon_total
	if float(team.resources.get("coin", 0)) < 0:
		team.unrest_turns += 1
	print("[Salary] Team%d 薪水結算 coin=%.1f" % [team.team_id, float(team.resources.get("coin", 0))])

func _has_master_memory(p: PersonData, leader_id: int) -> bool:
	for m in p.memory:
		if m.get("type") == "master" and m.get("subject_id") == leader_id:
			return true
	return false
