extends SceneTree

func _init() -> void:
	print("=== playtest_minimal 開始 ===")
	var state := WorldState.new()
	var runner := SimRunner.new()
	var bridge := SimBridge.new(runner, state)
	var cmd := PlayerCommandSystem.new()

	var config := GameSetup.load_config("res://config/default.json")
	if config.is_empty():
		push_error("Config 載入失敗")
		quit(); return

	GameSetup.setup(state, config)
	print("世界建立：%d teams, %d factions, %d persons" %
		[state.teams.size(), state.factions.size(), state.persons.size()])

	var pt: TeamData = cmd.get_player_team(state)
	if pt == null:
		push_error("玩家 team 不存在"); quit(); return
	print("玩家 team: id=%d, pos=%s, faction=%d, pop=%d, named=%d" %
		[pt.team_id, str(pt.tile_pos), pt.faction_id,
		 pt.population, pt.named_members.size()])
	print("玩家 leader: %s" % cmd.get_player_person(state).person_name)

	# 列出已生成 teams
	print("--- Teams ---")
	for tid in state.teams:
		var t: TeamData = state.teams[tid]
		var leader_name: String = ""
		var leader: PersonData = state.persons.get(t.leader_id)
		if leader: leader_name = leader.person_name
		print("  Team%d: pos=%s, fid=%d, pop=%d, leader=%s" %
			[tid, str(t.tile_pos), t.faction_id, t.population, leader_name])

	# 推進 7 天
	print("--- 推進 7 天 ---")
	bridge.advance_ticks(WorldState.TICKS_PER_DAY * 7)
	print("Tick: %d (Day %d)" % [state.world.current_tick,
		state.world.current_tick / WorldState.TICKS_PER_DAY])

	# inspect 玩家 team
	print("--- 玩家 inspect ---")
	var info: Dictionary = cmd.inspect_team(state, pt.team_id)
	print("  fatigue=%.3f, task=%s, faction=%d" %
		[info.get("fatigue"), info.get("current_task"), info.get("faction_id")])
	print("  food=%.1f, coin=%d" %
		[info.get("resources", {}).get("food", 0.0),
		 info.get("resources", {}).get("coin", 0)])
	print("  已發現 teams: %s" % str(state.team_discovered.get(pt.team_id, [])))

	# 測試移動
	print("--- 測試 move_to ---")
	var target: Vector2i = pt.tile_pos + Vector2i(1, 0)
	var r: Dictionary = cmd.move_to(state, target)
	print("  move_to(%s): %s" % [str(target), str(r)])
	bridge.advance_ticks(WorldState.TICKS_PER_DAY * 3)
	print("  3 天後位置：%s（目標 %s, move_target=%s）" %
		[str(pt.tile_pos), str(target), str(pt.move_target)])

	print("=== playtest_minimal 完成 ===")
	quit()
