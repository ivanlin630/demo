class_name BaseEvent

func check(_state: WorldState, _team: TeamData) -> bool:
	return false

# 回傳新產生的 TeamData（分裂用），否則空 Array
func execute(_state: WorldState, _team: TeamData) -> Array:
	return []
