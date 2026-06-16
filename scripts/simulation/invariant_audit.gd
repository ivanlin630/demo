class_name InvariantAudit

# 通用不變量審計：回違反訊息清單（空=全部一致）。
# 加新不變量 = 加一個 _check_* 並在 check() 呼叫。真存的守恆量(coin_eq)/不能衍生的不變量註冊於此。
static func check(state: WorldState) -> Array[String]:
	var violations: Array[String] = []
	_check_population(state, violations)
	return violations

# population 不變量：== leader(0/1) + named + anon + wounded
static func _check_population(state: WorldState, out: Array[String]) -> void:
	for tid in state.teams:
		var t: TeamData = state.teams[tid]
		var expected: int = (1 if t.leader_id != -1 else 0) \
			+ t.named_members.size() + AnonTierSystem.total_pop(t) + t.wounded
		if t.population != expected:
			out.append("population drift Team%d: 欄位=%d 期望=%d (leader%d+named%d+anon%d+wounded%d)" % [
				tid, t.population, expected,
				(1 if t.leader_id != -1 else 0), t.named_members.size(),
				AnonTierSystem.total_pop(t), t.wounded])
