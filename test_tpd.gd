extends SceneTree

func _initialize() -> void:
	var state = WorldState.new()
	print("TICKS_PER_DAY const: ", WorldState.TICKS_PER_DAY)
	print("ticks_per_day var: ", state.ticks_per_day)
	print("ticks_per_day == 240: ", state.ticks_per_day == 240)
	quit()
