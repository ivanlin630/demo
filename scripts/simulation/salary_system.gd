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
	# 居民 PRODUCE team 不走薪資系統（村民自食其力，村長非家臣）
	if team.tags.has(TeamData.TAG_PRODUCE):
		return
	var is_player_team: bool = (team.leader_id == state.player_id and state.player_id != -1)
	# NPC team: 每次發薪依 leader 個性同步薪資（慷慨/吝嗇 leader 隊伍動態不同）
	var npc_salary_mult: float = 1.0
	if not is_player_team:
		var leader: PersonData = state.persons.get(team.leader_id)
		if leader != null:
			var honor: float = (float(leader.values.get("義氣", 0.5)) \
				+ float(leader.values.get("信義", 0.5))) / 2.0
			var greed: float = float(leader.values.get("貪婪", 0.5))
			npc_salary_mult = clampf(1.0 + (honor - greed * 0.5) * 0.4, 0.7, 1.3)
	for pid in team.named_members:
		var p: PersonData = state.persons.get(pid)
		if p == null: continue
		if _has_master_memory(p, team.leader_id): continue
		var fair: float = _calc_fair_salary(p)
		# NPC team: 每輪同步薪資（隨技能成長 / leader 個性），player team 保留玩家自訂值
		if not is_player_team:
			p.salary = fair * npc_salary_mult
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
