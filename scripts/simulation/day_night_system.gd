# scripts/simulation/day_night_system.gd
class_name DayNightSystem

func get_time_of_day(state: WorldState) -> float:
	return float(state.world.current_tick % state.ticks_per_day) / \
		float(state.ticks_per_day)

func get_time_period(state: WorldState) -> String:
	var t: float = get_time_of_day(state)
	if t < 0.1:  return "dawn"
	if t < 0.75: return "day"
	if t < 0.9:  return "dusk"
	return "night"

func get_speed_mult(state: WorldState) -> float:
	match get_time_period(state):
		"day":   return 1.0
		"dawn":  return 0.8
		"dusk":  return 0.8
		"night": return 0.5
	return 1.0

func get_fatigue_mult(state: WorldState) -> float:
	match get_time_period(state):
		"day":   return 1.0
		"dawn":  return 1.2
		"dusk":  return 1.2
		"night": return 1.5
	return 1.0

func get_vision_mult(state: WorldState) -> float:
	match get_time_period(state):
		"day":   return 1.0
		"dawn":  return 0.75
		"dusk":  return 0.75
		"night": return 0.5
	return 1.0

func get_guards(state: WorldState, team: TeamData) -> Array:
	var guard_count: int = ceili(team.population * team.guard_ratio)
	var scored: Array = []
	for pid in team.named_members:
		var p: PersonData = state.persons.get(pid)
		if p == null: continue
		scored.append({ "id": pid, "scout": float(p.skills.get("偵查", 0.0)) })
	scored.sort_custom(func(a, b): return a["scout"] > b["scout"])
	var guards: Array = []
	for i in range(mini(guard_count, scored.size())):
		guards.append(scored[i]["id"])
	return guards

func get_camp_vision_range(state: WorldState, team: TeamData) -> int:
	var guards: Array = get_guards(state, team)
	if guards.size() == 0: return 0
	var total_scout: float = 0.0
	for pid in guards:
		var p: PersonData = state.persons.get(pid)
		if p: total_scout += float(p.skills.get("偵查", 0.0))
	var avg_scout: float = total_scout / guards.size()
	var base: int = 3   # VisionSystem.VISION_RADIUS (避免跨系統依賴)
	return roundi((base + avg_scout * 2.0) * get_vision_mult(state))
