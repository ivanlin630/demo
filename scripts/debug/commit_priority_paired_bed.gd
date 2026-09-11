extends SceneTree
# @bed-kind: acceptance
# slice: 優先序隨需求（commit priority from need, not set membership）
# 成對對照（HOW 2026-09-11 interrupt 票 §④④，systems 定）：
#   ★格一【真餓】：food_days < 人格化絕境門檻 ⇒ 覓食仍持 PRIO_SURVIVAL(80) ⇒ 求居(50) **被擋**
#   ★格二【吃飽】：food_days 遠高於門檻       ⇒ 覓食降為 PRIO_DISPATCH(50) ⇒ 求居 **換得上**
# ★★★兩格都要跑：只驗格二 ＝ 證明不了我們沒有把 80 一路拆掉（而那會製造餓死的病）。
# ★母體：同一支隊、同一個 leader、同一個門檻 —— 兩格之間【只有食物量不同】。
#   ⇒ 這一點是刻意的：它讓「差異來自需求強度」成為唯一可能的解釋。
# ★★失敗走 push_error（會叫、不會停）＋ 結尾標記，否則閘看不見。

func _initialize() -> void:
	_run(); quit(0 if _fails == 0 else 1)

var _fails: int = 0

func _ok(cond: bool, msg: String) -> void:
	if cond:
		print("  [OK] %s" % msg)
	else:
		_fails += 1
		push_error("[FAIL] %s" % msg)

func _run() -> void:
	seed(1337)
	var st: WorldState = MeasureBedHelper.arm_and_setup("res://config/warring_states.json")
	var team: TeamData = null
	for tid in st.teams:
		var t: TeamData = st.teams[tid]
		if t.population > 0 and st.persons.has(t.leader_id):
			team = t
			break
	if team == null:
		push_error("[FAIL] 母體 0：找不到任何有領袖的活隊 —— ★這不是綠，是床沒有輸入")
		print("[TEST-SUITE-COMPLETE]")
		return
	var leader: PersonData = st.persons.get(team.leader_id)
	var thr: float = DecisionTerms.desperation_entry_threshold(leader.values)
	var need_per_day: float = maxf(float(team.population) * ResourceSystem.FOOD_PER_PERSON_PER_DAY, 0.001)
	print("=== commit 優先序 成對對照（team=%d pop=%d 人格化絕境門檻=%.2f 天）===" % [
		team.team_id, team.population, thr])

	# ── 格一：真餓（食物 ＝ 門檻的一半）──
	var fd_hungry: float = _set_food(st, team, need_per_day * thr * 0.5)
	var p_hungry: int = DecisionOptions.priority_for_need(st, team, "覓食")
	_ok(p_hungry == TaskArbiter.PRIO_SURVIVAL,
		"【真餓】覓食 commit 優先序 ＝ %d（期望 PRIO_SURVIVAL %d）" % [p_hungry, TaskArbiter.PRIO_SURVIVAL])
	team.current_task = TeamData.TASK_FORAGE
	team.task_priority = p_hungry
	team.task_reason = "unified"
	team.persist_strength = 0.0
	var got_hungry: bool = TaskArbiter.try_set(st, team, TeamData.TASK_SEEK_HOME, team.tile_pos,
		DecisionOptions.priority_for_need(st, team, "求居"), "unified", "求居")
	_ok(not got_hungry and team.current_task == TeamData.TASK_FORAGE,
		"【真餓】求居【被擋】、現任仍是覓食（實際 current_task=%s）" % team.current_task)

	# ── 格二：吃飽（食物 ＝ 門檻的 10 倍）──
	var fd_fed: float = _set_food(st, team, need_per_day * thr * 10.0)
	var p_fed: int = DecisionOptions.priority_for_need(st, team, "覓食")
	_ok(p_fed == TaskArbiter.PRIO_DISPATCH,
		"【吃飽】覓食 commit 優先序 ＝ %d（期望 PRIO_DISPATCH %d）" % [p_fed, TaskArbiter.PRIO_DISPATCH])
	team.current_task = TeamData.TASK_FORAGE
	team.task_priority = p_fed
	team.task_reason = "unified"
	team.persist_strength = 0.0
	var got_fed: bool = TaskArbiter.try_set(st, team, TeamData.TASK_SEEK_HOME, team.tile_pos,
		DecisionOptions.priority_for_need(st, team, "求居"), "unified", "求居")
	_ok(got_fed and team.current_task == TeamData.TASK_SEEK_HOME,
		"【吃飽】求居【換得上】（實際 current_task=%s）" % team.current_task)

	# ── 第三格（★systems 沒要，我加的）：逃跑不受這一刀影響 ──
	# ★理由：`survival` 的需求軸是威脅不是糧食 ⇒ 拿糧食平安去降它，是換一個病。
	_ok(DecisionOptions.priority_for_need(st, team, "survival") == TaskArbiter.PRIO_SURVIVAL,
		"【吃飽】逃跑(survival) 仍是 PRIO_SURVIVAL —— ★★這一格證明我們沒有把 80 一路拆掉")

	print("=== DONE === SECTIONS=1/1 FAILS=%d" % _fails)
	print("[TEST-SUITE-COMPLETE]")

# ★把【有效持糧】設成指定量：★★effective_food 除了 team.resources 還含自家糧倉的公庫，
#   ★★★只寫 resources 會被糧倉抬回去（第一版就是這樣紅的）—— 兩邊都要設，
#   而且回傳【實際達到的 food_days】讓斷言印出來可被證偽。
func _set_food(st: WorldState, team: TeamData, amount: float) -> float:
	var g: HexTileData = ResourceSystem.own_granary_tile(st, team)
	if g != null: g.public_storage["food"] = 0.0
	team.resources["food"] = amount
	var need: float = maxf(float(team.population) * ResourceSystem.FOOD_PER_PERSON_PER_DAY, 0.001)
	return ResourceSystem.effective_food(st, team) / need
