extends SceneTree
# T0-A1 TDD。
# ①事件瞬醒：非 cadence tick 發生 combat_start → 該隊當 tick 可思考（對照舊行為要等 cadence）
# ③消費順序穩定（team_id 升序）+ 單 tick 清空（不跨 tick 存活）
# ④在途不想：移動中隊 cadence 不重評、但被襲仍瞬醒
# 掛點覆蓋：五個函式 chokepoint + 三個狀態跨線 kind 都在表內

var _fail := 0
func _ok(c: bool, m: String) -> void:
	if c: print("  PASS ", m)
	else: _fail += 1; print("  FAIL ", m)

func _initialize() -> void:
	_run(); quit()

func _mk() -> Array:
	var s := WorldState.new(); s.world = WorldData.new(); s.player_id = -1
	s.world.current_tick = 1000
	for x in range(0, 4):
		var t := HexTileData.new(); t.tile_id = x*1000; t.tile_pos = Vector2i(x,0); t.terrain = "plains"
		t.resources = {"food": 50.0}; t.resource_cap = {"food": 100.0}
		s.world.tiles[t.tile_id] = t
	var mk := func(tid: int, pos: Vector2i) -> TeamData:
		var ldr := PersonData.new(); ldr.id = 800 + tid; ldr.team_id = tid
		ldr.skills = {"統領": 0.5}
		s.persons[ldr.id] = ldr
		var t := TeamData.new(); t.team_id = tid; t.leader_id = ldr.id; t.tile_pos = pos
		t.faction_id = -1
		AnonCohort.add(t.anon_cohorts, "平民", "healthy", 5)
		t.resources = {"food": 40.0}
		s.teams[tid] = t
		return t
	var a: TeamData = mk.call(1, Vector2i(0,0))
	var b: TeamData = mk.call(2, Vector2i(1,0))
	return [s, a, b]

func _run() -> void:
	print("=== T0-A1 event bus test ===")
	var fai := FactionAISystem.new()
	# ① 事件瞬醒 vs 舊行為（cadence 未到 → 不重評）
	var w := _mk(); var s: WorldState = w[0]; var a: TeamData = w[1]
	a.current_task = TeamData.TASK_PRODUCE
	a.decision_eval_next_tick = s.world.current_tick + 9999   # cadence 遠未到
	_ok(not fai._should_reeval(s, a), "對照：cadence 未到 → 不重評（舊行為）")
	WorldEvents.emit(s, "combat_engaged", [a.team_id])
	_ok(fai._should_reeval(s, a), "★事件瞬醒：pending 標記後當 tick 就能思考")
	# ③ 單 tick 清空（不跨 tick 存活）
	WorldEvents.consume_and_clear(s)
	_ok(s.pending_rethink.is_empty(), "★consume_and_clear 後 pending 空（不跨 tick 存活）")
	_ok(not fai._should_reeval(s, a), "清空後回到 cadence 語意（事件不殘留）")
	# ③ 消費順序：升序快照
	var w2 := _mk(); var s2: WorldState = w2[0]
	WorldEvents.emit(s2, "intel_arrived", [2])
	WorldEvents.emit(s2, "intel_arrived", [1])
	var ids: Array = s2.pending_rethink.keys(); ids.sort()
	_ok(ids == [1, 2], "★消費順序＝team_id 升序（%s，禁 Dictionary 迭代序）" % str(ids))
	# ④ 在途不想：移動中 travel task → cadence 到期也不重評；但事件仍喚醒
	var w3 := _mk(); var s3: WorldState = w3[0]; var t3: TeamData = w3[1]
	t3.current_task = TeamData.TASK_TRADE
	t3.move_target = Vector2i(3, 0)          # 在途（未到）
	t3.decision_eval_next_tick = s3.world.current_tick - 1   # cadence 已到期
	_ok(not fai._should_reeval(s3, t3), "★在途不想：移動中 travel task 不因 cadence 重評")
	WorldEvents.emit(s3, "combat_engaged", [t3.team_id])
	_ok(fai._should_reeval(s3, t3), "★但被襲仍瞬醒（事件喚醒優先於在途抑制）")
	# 到達後照常吃 cadence
	WorldEvents.consume_and_clear(s3)
	t3.tile_pos = t3.move_target
	t3.decision_eval_next_tick = s3.world.current_tick - 1
	_ok(fai._should_reeval(s3, t3), "到達後恢復 cadence 重評")
	# 掛點表覆蓋
	var kinds: Array = WorldEvents.all_kinds()
	var need: Array = ["combat_engaged", "leader_death", "team_extinct", "teams_erased", "betrayed",
		"famine_crossed", "labor_crisis", "intel_arrived"]
	var miss: Array = []
	for k in need:
		if not (k in kinds): miss.append(k)
	_ok(miss.is_empty(), "五個函式 chokepoint + 三個狀態跨線 kind 全在表內（缺：%s）" % str(miss))
	if _fail == 0: print("ALL PASS")
	else: print("FAILS=%d" % _fail)
