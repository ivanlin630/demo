extends SceneTree

# A2c-1 TDD bed：FA5 consolidate 折入引擎 option。
# Task1: consolidate_target_of 逐條件等價現行 _try_consolidate_merge target 兩支。
# Task2: consolidate_drive term。Task3: 整併 option。Task4: pre-gate 拆除整合行為 + survival 保。

var fail_count: int = 0
var _next_id: int = 1

func _assert(cond: bool, msg: String) -> void:
	if not cond:
		fail_count += 1
		print("[FAIL] " + msg)
	else:
		print("[PASS] " + msg)

func _mk_person(state: WorldState, cmd: float) -> int:
	var p := PersonData.new()
	p.id = _next_id; _next_id += 1
	p.skills["統領"] = cmd
	state.persons[p.id] = p
	return p.id

func _mk_team(state: WorldState, pop: int, cmd: float, pos: Vector2i, faction_id: int) -> TeamData:
	var t := TeamData.new()
	t.team_id = _next_id; _next_id += 1
	t.leader_id = _mk_person(state, cmd)
	if pop > 0:
		AnonTierSystem.add_anon(t, AnonCohort.TIER_PLEB, pop - 1)   # leader 算 1
	# S-A：預設充足糧（10 天餘命）→ 過 _find_absorber 餵養 gate#1，隔離 target 選擇特徵測試。
	t.resources["food"] = float(pop) * ResourceSystem.FOOD_PER_PERSON_PER_DAY * 10.0
	t.tile_pos = pos
	t.faction_id = faction_id
	t.parent_team_id = -1
	t.current_task = TeamData.TASK_IDLE
	state.teams[t.team_id] = t
	return t

func _mk_faction(state: WorldState, leader_team_id: int, goals: Array) -> FactionData:
	var f := FactionData.new()
	f.faction_id = _next_id; _next_id += 1
	f.leader_team_id = leader_team_id
	f.member_team_ids = [leader_team_id]
	f.goals = goals
	state.factions[f.faction_id] = f
	return f

func _run() -> void:
	print("=== A2c1 consolidate bed ===")

	# ── Task1 case A: 容量吸收命中（small member near absorber with capacity）──
	var state_a := WorldState.new()
	var leader_a := _mk_team(state_a, 5, 5.0, Vector2i(0, 0), -1)
	var f_a := _mk_faction(state_a, leader_a.team_id, [])
	leader_a.faction_id = f_a.faction_id
	var absorber_a := _mk_team(state_a, 5, 5.0, Vector2i(1, 0), f_a.faction_id)
	f_a.member_team_ids.append(absorber_a.team_id)
	var small_a := _mk_team(state_a, 1, 1.0, Vector2i(3, 0), f_a.faction_id)
	f_a.member_team_ids.append(small_a.team_id)

	var fai := FactionAISystem.new()
	var target_a: int = FactionAISystem.consolidate_target_of(state_a, small_a, f_a)
	_assert(target_a != -1, "case A: consolidate_target_of 命中容量吸收 target != -1")
	_assert(target_a == absorber_a.team_id, "case A: target == absorber_id")

	# ── S-A case A2: 餵養 gate#1——所有候選 absorber 無糧 → 不選（防搬餓）──
	# （leader_a 也在 dist≤3 內=候選；須一併餓才隔離 gate）
	absorber_a.resources["food"] = 0.0
	leader_a.resources["food"] = 0.0
	var target_a2: int = FactionAISystem.consolidate_target_of(state_a, small_a, f_a)
	_assert(target_a2 == -1, "case A2: 餵養 gate——候選 absorber 皆無糧 → target == -1")
	absorber_a.resources["food"] = float(absorber_a.population) * ResourceSystem.FOOD_PER_PERSON_PER_DAY * 10.0  # 復原
	leader_a.resources["food"] = float(leader_a.population) * ResourceSystem.FOOD_PER_PERSON_PER_DAY * 10.0

	# ── Task1 case B: small member 不夠小（不命中）──
	var state_b := WorldState.new()
	var leader_b := _mk_team(state_b, 5, 5.0, Vector2i(0, 0), -1)
	var f_b := _mk_faction(state_b, leader_b.team_id, [])
	leader_b.faction_id = f_b.faction_id
	var absorber_b := _mk_team(state_b, 5, 5.0, Vector2i(1, 0), f_b.faction_id)
	f_b.member_team_ids.append(absorber_b.team_id)
	var notsmall_b := _mk_team(state_b, 20, 5.0, Vector2i(1, 1), f_b.faction_id)
	f_b.member_team_ids.append(notsmall_b.team_id)

	var target_b: int = FactionAISystem.consolidate_target_of(state_b, notsmall_b, f_b)
	_assert(target_b == -1, "case B: 不夠小 → target == -1")

	# ── Task1 case C: 攻擊 goal + member 近 leader 有容量（戰前集結）──
	var state_c := WorldState.new()
	var leader_c := _mk_team(state_c, 5, 5.0, Vector2i(0, 0), -1)
	var f_c := _mk_faction(state_c, leader_c.team_id, ["攻擊"])
	leader_c.faction_id = f_c.faction_id
	var member_c := _mk_team(state_c, 3, 3.0, Vector2i(2, 0), f_c.faction_id)
	f_c.member_team_ids.append(member_c.team_id)

	var target_c: int = FactionAISystem.consolidate_target_of(state_c, member_c, f_c)
	_assert(target_c == leader_c.team_id, "case C: 戰前集結 target == leader_team_id")

	# ── Task2: consolidate_drive term（C2 絕境 survival-class，mirror join：food<DESPERATION 才 fire）──
	var ctx_a := DecisionContext.new()
	ctx_a.consolidate_target_id = absorber_a.team_id
	ctx_a.food_days = 0.0   # 絕境 → 食壓最大
	# C2：絕境 food-scaled，food=0 → DESPERATION_SCALE*DESPERATION_DAYS。
	var drive_hit: float = DecisionTerms.eval("consolidate_drive", ctx_a, "整併")
	_assert(is_equal_approx(drive_hit, DecisionTerms.DESPERATION_SCALE * DecisionTerms.DESPERATION_DAYS),
		"term: consolidate_drive 絕境 food-scaled（餓→DESPERATION_SCALE*DAYS）")
	var ctx_fed := DecisionContext.new()
	ctx_fed.consolidate_target_id = absorber_a.team_id
	ctx_fed.food_days = 99.0   # 飽（≥DESPERATION）→ 食壓 0
	_assert(DecisionTerms.eval("consolidate_drive", ctx_fed, "整併") == 0.0, "term: 飽足 → consolidate_drive 0")
	var drive_wrong_opt: float = DecisionTerms.eval("consolidate_drive", ctx_a, "貿易")
	_assert(drive_wrong_opt == 0.0, "term: opt != 整併 → 0")
	var ctx_none := DecisionContext.new()
	ctx_none.consolidate_target_id = -1
	var drive_no_target: float = DecisionTerms.eval("consolidate_drive", ctx_none, "整併")
	_assert(drive_no_target == 0.0, "term: target == -1 → 0")

	# ── Task3: 整併 option applicable + to_task ──
	var applicable_hit: Array = DecisionOptions.applicable(ctx_a)
	_assert("整併" in applicable_hit, "option: consolidate_target_id!=-1 → 整併 applicable")
	var applicable_none: Array = DecisionOptions.applicable(ctx_none)
	_assert(not ("整併" in applicable_none), "option: consolidate_target_id==-1 → 整併 不 applicable")

	var td: Dictionary = DecisionOptions.to_task(state_a, small_a, "整併")
	_assert(td["task"] == TeamData.TASK_MERGE, "to_task: task == TASK_MERGE")
	_assert(td["target"] == state_a.teams[absorber_a.team_id].tile_pos, "to_task: target == absorber tile_pos")
	_assert(int(td["order_target"]) == absorber_a.team_id, "to_task: order_target == absorber_id")

	# ── Task4: 整合行為（跑一次 _assign_member_tasks，整併經引擎達成）──
	# C2：整併=絕境 survival-class——small_a 需絕境食壓（food<DESPERATION_DAYS）consolidate 才 fire。
	# 設 ~1.5 天餘命；absorber 仍充足糧過餵養 gate。
	small_a.resources["food"] = float(small_a.population) * ResourceSystem.FOOD_PER_PERSON_PER_DAY * 1.5
	fai._assign_member_tasks(state_a, f_a)
	_assert(small_a.current_task == TeamData.TASK_MERGE, "整合: small member current_task == TASK_MERGE（經引擎）")
	_assert(small_a.order_target_id == absorber_a.team_id, "整合: order_target_id == absorber_id")

	# survival case：餓/危 member 已在 survival task → 仍 survival，非整併
	var state_s := WorldState.new()
	var leader_s := _mk_team(state_s, 5, 5.0, Vector2i(0, 0), -1)
	var f_s := _mk_faction(state_s, leader_s.team_id, [])
	leader_s.faction_id = f_s.faction_id
	var absorber_s := _mk_team(state_s, 5, 5.0, Vector2i(1, 0), f_s.faction_id)
	f_s.member_team_ids.append(absorber_s.team_id)
	var starving_s := _mk_team(state_s, 1, 1.0, Vector2i(1, 1), f_s.faction_id)
	starving_s.current_task = TeamData.TASK_FORAGE
	starving_s.task_priority = TaskArbiter.PRIO_SURVIVAL   # 鏡射真實 _trigger_survival 設 priority（保護 sticky）
	f_s.member_team_ids.append(starving_s.team_id)
	var fai_s := FactionAISystem.new()
	fai_s._assign_member_tasks(state_s, f_s)
	_assert(starving_s.current_task == TeamData.TASK_FORAGE, "survival: 餓隊仍 survival task，非整併（priority-gate 保）")

	print("=== done, fail_count=%d ===" % fail_count)
	quit(1 if fail_count > 0 else 0)

func _initialize() -> void:
	_run()
