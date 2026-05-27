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
