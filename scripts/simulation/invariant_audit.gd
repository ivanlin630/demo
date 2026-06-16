class_name InvariantAudit

# 通用不變量審計：回違反訊息清單（空=全部一致）。
# 加新不變量 = 加一個 _check_* 並在 check() 呼叫。真存的守恆量(coin_eq)/不能衍生的不變量註冊於此。
static func check(state: WorldState) -> Array[String]:
	var violations: Array[String] = []
	_check_population(state, violations)
	_check_faction_bidir(state, violations)
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

# faction 雙向：member_team_ids 內每隊須回指此 faction；team.faction_id != -1 須在對應 member 列。
static func _check_faction_bidir(state: WorldState, out: Array[String]) -> void:
	for fid in state.factions:
		var f: FactionData = state.factions[fid]
		for tid in f.member_team_ids:
			var t: TeamData = state.teams.get(tid)
			if t == null:
				out.append("faction 懸空 Faction%d.member_team_ids 含已不存在 Team%d" % [fid, tid])
			elif t.faction_id != fid:
				out.append("faction 雙向破 Faction%d 列 Team%d 但其 faction_id=%d" % [fid, tid, t.faction_id])
	for tid in state.teams:
		var t: TeamData = state.teams[tid]
		if t.faction_id == -1: continue
		var f: FactionData = state.factions.get(t.faction_id)
		if f == null:
			out.append("faction 反向破 Team%d.faction_id=%d 但 faction 不存在" % [tid, t.faction_id])
		elif not f.member_team_ids.has(tid):
			out.append("faction 反向破 Team%d 自稱屬 Faction%d 但不在 member_team_ids" % [tid, t.faction_id])
