class_name PopulationSystem

const OVERFLOW_CHECK_INTERVAL: int = WorldState.TICKS_PER_DAY   # 每天檢查
const MATURE_RATE: float = 0.1   # TEST VALUE — 每月 minor 轉成人比例（簡版，無性別/個體年齡）

func check_overflow(state: WorldState) -> void:
	# minor 長大簡版：每月 10% minor → 平民 anon（人口循環下游，性別/年齡留人口結構 spec）
	if state.world.current_tick % WorldState.TICKS_PER_MONTH == 0:
		_mature_minors(state)
	for tid in state.teams.keys():
		check_overflow_for_team(state, tid)

func _mature_minors(state: WorldState) -> void:
	# 不設人口上限：長大超過 cap → 同一次 check_overflow 後續的溢出檢查自然分團（移民潮）
	for tid in state.teams:
		var team: TeamData = state.teams[tid]
		if team.minor_population <= 0: continue
		var n: int = maxi(int(team.minor_population * MATURE_RATE), 1)
		n = mini(n, team.minor_population)
		team.minor_population -= n
		AnonTierSystem.add_anon(team, AnonCohort.TIER_PLEB, n)
		print("[PopMgmt] Team%d %d 名未成年長大成人（平民）" % [tid, n])

func check_overflow_for_team(state: WorldState, tid: int) -> void:
	if not state.teams.has(tid):
		return
	var team: TeamData = state.teams[tid]
	# ★農業b ⑥：effective_pop_cap=領導基數×據點放大器（統一取代 PRODUCE-outpost-table/leader-only 分流；
	# L0/無據點→放大器×1=領導帽守 S2a 界線；據點發展→承載更多=size matter via 據點 genuine）。
	var cap: int = FactionAISystem.effective_pop_cap(state, team)
	var overflow: int = team.population - cap
	if overflow <= 0:
		return
	var spare_id: int = -1
	for nid in team.named_members:
		if nid != team.leader_id:
			spare_id = nid
			break
	if spare_id != -1:
		SubteamSystem.new().dispatch(state, tid, spare_id, overflow, "idle", team.tile_pos)
		print("[PopMgmt] Team%d 超額 %d 人，advisor Team%d 帶走" % [tid, overflow, spare_id])
	else:
		_create_overflow_team(state, team, overflow)

func _create_overflow_team(state: WorldState, origin: TeamData, overflow_pop: int) -> void:
	var ot := TeamData.new()
	ot.team_id      = _next_team_id(state)
	ot.tile_pos     = origin.tile_pos
	state.set_team_faction(ot, -1)   # S11 chokepoint（fresh team，no-op；單寫者一致）
	state.set_team_tags(ot, ["流亡"], "overflow_split")
	ot.current_task = TeamData.TASK_IDLE   # 新 team 建立豁免：overflow 流亡 idle + priority 0
	ot.task_priority = 0
	var frac: float = float(overflow_pop) / float(origin.population)
	for res in origin.resources:
		var amt: float = float(origin.resources.get(res, 0)) * frac
		ResourceBank.set_amt(ot, res, amt, "overflow_split")
		ResourceBank.add(origin, res, -amt, "overflow_split")
	AnonTierSystem.transfer_proportional(origin, ot, overflow_pop)
	state.create_team(ot)   # S9 chokepoint：註冊 + known/discovered init
	var promoted := PersonGenerator.generate_for_team(state, ot, "member")
	if promoted != null:
		ot.leader_id  = promoted.id
		promoted.role = "leader"
	print("[PopMgmt] Team%d 超額 %d 人無 advisor，獨立流亡 Team%d" % [
		origin.team_id, overflow_pop, ot.team_id])

func _next_team_id(state: WorldState) -> int:
	var max_id: int = -1
	for tid in state.teams:
		if tid > max_id:
			max_id = tid
	return max_id + 1
