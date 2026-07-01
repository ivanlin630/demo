class_name InvariantAudit

# 通用不變量審計：回違反訊息清單（空=全部一致）。
# 加新不變量 = 加一個 _check_* 並在 check() 呼叫。真存的守恆量(coin_eq)/不能衍生的不變量註冊於此。
static func check(state: WorldState) -> Array[String]:
	var violations: Array[String] = []
	_check_population(state, violations)
	_check_faction_bidir(state, violations)
	_check_subteam_bidir(state, violations)
	_check_roster_bidir(state, violations)
	_check_anon_cohort(state, violations)
	_check_captive_cohort(state, violations)
	_check_no_dangling_team_id(state, violations)
	return violations

# population 不變量：== leader(0/1) + named + anon(含 wounded 桶)
static func _check_population(state: WorldState, out: Array[String]) -> void:
	for tid in state.teams:
		var t: TeamData = state.teams[tid]
		var expected: int = (1 if t.leader_id != -1 else 0) \
			+ t.named_members.size() + AnonTierSystem.total_pop(t)
		if t.population != expected:
			out.append("population drift Team%d: 欄位=%d 期望=%d (leader%d+named%d+anon%d)" % [
				tid, t.population, expected,
				(1 if t.leader_id != -1 else 0), t.named_members.size(),
				AnonTierSystem.total_pop(t)])

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

# subteam 雙向：parent.subteam_ids 內每隊 parent_team_id 須回指 parent。
static func _check_subteam_bidir(state: WorldState, out: Array[String]) -> void:
	for pid in state.teams:
		var parent: TeamData = state.teams[pid]
		for cid in parent.subteam_ids:
			var child: TeamData = state.teams.get(cid)
			if child == null:
				out.append("subteam 懸空 Team%d.subteam_ids 含已不存在 Team%d" % [pid, cid])
			elif child.parent_team_id != pid:
				out.append("subteam 雙向破 Team%d 列子隊 Team%d 但其 parent_team_id=%d" % [pid, cid, child.parent_team_id])

# roster 雙向：named_members / leader_id 內每人 team_id 須回指本隊（forward）；
# 且凡 person.team_id!=-1 須在該隊 roster（leader 或 named）（reverse，slice3）。
# = 「凡在編制者必認本隊」+「凡認隊者必在編制」。單值 team_id → 亦擋一人列兩隊。
# add_member/remove_member/set_leader chokepoint 維護此。
# reverse 跳 is_dead：health famine/戰死蓄意留屍保 team_id（不在 roster 卻 team_id!=-1）→
#   標 is_dead → 反向不誤報（活人 person→wrong-roster 才是真 desync）。
static func _check_roster_bidir(state: WorldState, out: Array[String]) -> void:
	for tid in state.teams:
		var t: TeamData = state.teams[tid]
		for pid in t.named_members:
			var p: PersonData = state.persons.get(pid)
			if p != null and p.team_id != tid:
				out.append("roster 雙向破 Team%d 列 named P%d 但其 team_id=%d" % [tid, pid, p.team_id])
		if t.leader_id != -1:
			var lp: PersonData = state.persons.get(t.leader_id)
			if lp != null and lp.team_id != tid:
				out.append("roster 雙向破 Team%d leader P%d 但其 team_id=%d" % [tid, t.leader_id, lp.team_id])
	# reverse：person.team_id → 須在該隊 roster（活人）；dead 留屍跳過
	for pid in state.persons:
		var p: PersonData = state.persons[pid]
		if p.team_id == -1 or p.is_dead:
			continue
		var t: TeamData = state.teams.get(p.team_id)
		if t == null:
			continue   # 懸空 team_id 由 remove_member 語意保證不生（此網不重複審）
		if t.leader_id != pid and pid not in t.named_members:
			out.append("roster 反向破 P%d team_id=%d 但不在該隊 roster(leader/named)" % [pid, p.team_id])

# anon cohort 自洽：每桶 count>0、鍵合法（tier ∈ TIER_ORDER、health ∈ HEALTH_ORDER）。
# count<0 或非法鍵 = AnonCohort 入口被繞過或腐化。population getter 已是恆等式（total_pop），
# 故 _check_population 對 anon 部分恆綠；此網守的是 cohort 內部結構。
static func _check_anon_cohort(state: WorldState, out: Array[String]) -> void:
	for tid in state.teams:
		var t: TeamData = state.teams[tid]
		for key in t.anon_cohorts:
			var parts: Array = AnonCohort._parse(key)
			if parts.size() != 2 or parts[0] not in AnonCohort.TIER_ORDER \
					or parts[1] not in AnonCohort.HEALTH_ORDER:
				out.append("cohort 非法鍵 Team%d: '%s'" % [tid, key])
			if int(t.anon_cohorts[key]) <= 0:
				out.append("cohort 桶非正 Team%d: '%s'=%d（稀疏應刪零桶）" % [tid, key, int(t.anon_cohorts[key])])

# 受控人力 P1：captive_groups cohorts 自洽（鍵合法、count>0）。captive 隔離不入 population，
# 故 _check_population 看不到；此網守 captive cohorts 結構（吸收/同化/暴動/逃守恆的底層完整性）。
static func _check_captive_cohort(state: WorldState, out: Array[String]) -> void:
	for tid in state.teams:
		var t: TeamData = state.teams[tid]
		for group in t.captive_groups:
			var cohorts: Dictionary = group.get("cohorts", {})
			for key in cohorts:
				var parts: Array = AnonCohort._parse(key)
				if parts.size() != 2 or parts[0] not in AnonCohort.TIER_ORDER \
						or parts[1] not in AnonCohort.HEALTH_ORDER:
					out.append("captive cohort 非法鍵 Team%d: '%s'" % [tid, key])
				if int(cohorts[key]) <= 0:
					out.append("captive cohort 桶非正 Team%d: '%s'=%d（稀疏應刪零桶）" % [tid, key, int(cohorts[key])])

# 無懸空 team_id：任何欄位/dict/list 指向不存在的 team = erase 漏清。
static func _check_no_dangling_team_id(state: WorldState, out: Array[String]) -> void:
	for tid in state.teams:
		var t: TeamData = state.teams[tid]
		if t.combat_target != -1 and not state.teams.has(t.combat_target):
			out.append("懸空 Team%d.combat_target=%d 不存在" % [tid, t.combat_target])
		if t.social_target != -1 and not state.teams.has(t.social_target):
			out.append("懸空 Team%d.social_target=%d 不存在" % [tid, t.social_target])
		if t.order_target_id != -1 and not state.teams.has(t.order_target_id):
			out.append("懸空 Team%d.order_target_id=%d 不存在" % [tid, t.order_target_id])
		if t.parent_team_id != -1 and not state.teams.has(t.parent_team_id):
			out.append("懸空 Team%d.parent_team_id=%d 不存在" % [tid, t.parent_team_id])
		# known_reputations 鍵overload：tid(int)→聲望 + String 快取鍵(_cached_owner_leader_*)；只審 int 鍵
		for k in t.known_reputations:
			if k is int and not state.teams.has(k):
				out.append("懸空 Team%d.known_reputations 含死 Team%d" % [tid, k]); break
		for k in t.strategic_assignments:
			if k is int and k != -1 and not state.teams.has(k):
				out.append("懸空 Team%d.strategic_assignments 含死 Team%d" % [tid, k]); break
	for obs in state.team_discovered:
		for did in state.team_discovered[obs]:
			if not state.teams.has(did):
				out.append("懸空 team_discovered[%d] 含死 Team%d" % [obs, did]); break
