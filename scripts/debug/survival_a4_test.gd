extends SceneTree

# slice A4 TDD：forage de-patch(survival_pressure 隨 food_days 衰減 bounded) + solo-convert + 9筆 invite_settle self-replace。

var _fail: int = 0
func _ok(c: bool, m: String) -> void:
	if c: print("  [PASS] %s" % m)
	else: _fail += 1; print("  [FAIL] %s" % m)

func _sp(food_days: float) -> float:
	var c := DecisionContext.new(); c.food_days = food_days
	return DecisionTerms.eval("survival_pressure", c, "覓食")

func _initialize() -> void:
	print("=== A4 forage de-patch：survival_pressure 隨 food_days 衰減 bounded ===")
	print("  SLACK_COMFORT_DAYS(SURVIVAL_RECOVER)=%.1f" % DecisionContext.SLACK_COMFORT_DAYS)
	for fd in [0.0, 3.0, 7.0, 10.0, 14.0, 30.0]:
		print("    food_days=%.0f  survival_pressure=%.3f" % [fd, _sp(fd)])
	_ok(_sp(3.0) == 1.0, "瀕餓 food_days=3 → survival_pressure=1.0（floor 不動、不餓死 regression）")
	_ok(_sp(7.0) == 1.0, "food_days=7 → 1.0（<門檻仍 floor）")
	_ok(abs(_sp(10.0) - 4.0/7.0) < 1e-3, "food_days=10 → %.3f 連續衰減（(14−10)/7）" % _sp(10.0))
	_ok(_sp(14.0) == 0.0 and _sp(30.0) == 0.0, "吃飽 food_days≥14 → 0（讓位、覓食 util 降）")
	_ok(_sp(3.0) > _sp(10.0) and _sp(10.0) > _sp(14.0), "單調：越餓越高（need-connected 非死值）")

	print("=== solo-convert：獨立 TASK_SETTLE 抵達 own-faction outpost → convert（非等 pair）===")
	var state := WorldState.new(); state.world = WorldData.new(); state.world.current_tick = 1000
	var fac := FactionData.new(); fac.faction_id = 0; fac.leader_team_id = 99; state.factions[0] = fac
	var lord := TeamData.new(); lord.team_id = 99; lord.faction_id = 0; lord.tile_pos = Vector2i(0,0); state.teams[99] = lord
	var tile := HexTileData.new(); tile.tile_pos = Vector2i(5,5); tile.terrain = "plains"; tile.outpost_level = 1; tile.outpost_owner = 99
	state.world.tiles[5005] = tile
	var w := TeamData.new(); w.team_id = 1; w.faction_id = 0; w.tile_pos = Vector2i(5,5); w.parent_team_id = -1
	w.current_task = TeamData.TASK_SETTLE; w.move_target = Vector2i(-1,-1)   # 已抵達
	AnonCohort.add(w.anon_cohorts, "平民", "healthy", 4)
	var wlp := PersonData.new(); wlp.id = 22; state.persons[22] = wlp; w.leader_id = 22
	state.teams[1] = w
	Probe.reset(); Probe.enabled = true
	FactionAISystem.new()._tick_solo_settle(state, w)
	Probe.enabled = false
	_ok(w.tags.has(TeamData.TAG_PRODUCE) and int(Probe.counts.get("convert_via_settle", 0)) == 1,
		"solo TASK_SETTLE 抵 own-faction outpost → _convert_to_resident（PRODUCE）+ convert_via_settle=1（非等 pairwise）")
	# 還在路上(move_target≠-1)→不 convert。
	var w2 := TeamData.new(); w2.team_id = 2; w2.faction_id = 0; w2.tile_pos = Vector2i(5,5); w2.parent_team_id = -1
	w2.current_task = TeamData.TASK_SETTLE; w2.move_target = Vector2i(9,9)   # 未抵
	state.teams[2] = w2
	Probe.reset(); Probe.enabled = true
	FactionAISystem.new()._tick_solo_settle(state, w2)
	Probe.enabled = false
	_ok(not w2.tags.has(TeamData.TAG_PRODUCE), "還在路上(move_target≠-1)→不 convert（未抵不安頓）")

	print("=== 9筆：invite_settle 同層 self-replace ===")
	var s2 := WorldState.new(); s2.world = WorldData.new(); s2.world.current_tick = 1000
	var t := TeamData.new(); t.team_id = 1; t.current_task = TeamData.TASK_IDLE
	t.task_priority = TaskArbiter.PRIO_DISPATCH; t.task_reason = "invite_settle"; s2.teams[1] = t
	var ok: bool = TaskArbiter.try_set(s2, t, TeamData.TASK_SETTLE, Vector2i(5,5), TaskArbiter.PRIO_DISPATCH, "invite_settle")
	_ok(ok and t.current_task == TeamData.TASK_SETTLE, "invite_settle 同層 50=50 self-replace 過（ENGINE_SOURCES 白名單、非 priority-crank）")

	if _fail == 0: print("=== DONE === ALL PASS")
	else: print("=== DONE === %d FAIL" % _fail)
	quit()
