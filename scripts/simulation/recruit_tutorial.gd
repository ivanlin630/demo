class_name RecruitTutorial

const FOOD_THRESHOLD: float = 60.0   # TEST VALUE — 玩家食物盈餘觸發 tutorial

# 一次性：玩家食物盈餘到閾值 → 旁生 1 堪用 named + 3 tier0(平民) anon 流民團 + 發 join_request
func check(state: WorldState) -> void:
	if bool(state.player_state.get("recruit_tutorial_fired", false)): return
	var pp: PersonData = state.persons.get(state.player_id) if state.player_id != -1 else null
	if pp == null: return
	var pt: TeamData = state.teams.get(pp.team_id)
	if pt == null or float(pt.resources.get("food", 0)) < FOOD_THRESHOLD: return
	if not state.player_forced_event.is_empty(): return
	# 生 tutorial 流民團
	var tid: int = _next_team_id(state)
	var team := TeamData.new(); team.team_id = tid; team.tile_pos = pt.tile_pos
	team.current_task = "投靠"
	var nl := PersonData.new(); nl.id = _next_person_id(state)
	nl.team_id = tid; nl.person_name = "投奔者"; nl.role = "leader"
	nl.skills = {"狩獵": 0.5, "求生": 0.5, "戰鬥": 0.4}   # 略偏堪用
	nl.loyalty = 0.9                                       # 忠誠偏高
	state.persons[nl.id] = nl; team.leader_id = nl.id
	AnonTierSystem.add_anon(team, "平民", 3)               # 3 白丁(tier0)；population getter = leader1+anon3 = 4
	state.teams[tid] = team
	state.player_forced_event = { "action": "join_request", "from_id": tid }
	state.player_forced_event_id = str(randi())
	state.player_state["recruit_tutorial_fired"] = true
	print("[Tutorial] 投奔者小隊 Team%d 求投靠玩家" % tid)

func _next_team_id(state: WorldState) -> int:
	var m: int = 0
	for k in state.teams: m = maxi(m, int(k))
	return m + 1

func _next_person_id(state: WorldState) -> int:
	var m: int = 0
	for k in state.persons: m = maxi(m, int(k))
	return m + 1
