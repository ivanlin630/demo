extends SceneTree
# @bed-kind: diagnostic
# ★派工觸發（systems 2026-10-08，infonet_scout_test triage）：不修 infonet_scout_test.gd、不改世界，
# 只複製它④那格的fixture，把 state.team_known[1] 裡每一筆 order_buy/origin_team==2 的訊息逐筆印出來，
# 查「got=2」是不是兩筆不同成因的訊息疊加。

func _initialize() -> void:
	var state := WorldState.new(); state.world = WorldData.new(); state.world.current_tick = 1000
	var lord := TeamData.new(); lord.team_id = 1; lord.faction_id = 0; lord.tile_pos = Vector2i(5,5); state.teams[1] = lord
	var sub := TeamData.new(); sub.team_id = 2; sub.faction_id = 0; sub.tile_pos = Vector2i(8,8)
	sub.active_orders = [{"order_id": 700, "kind": "buy", "res": "food", "qty_remaining": 50, "expire_tick": 99999}]
	state.teams[2] = sub
	var scout := TeamData.new(); scout.team_id = 3; scout.faction_id = 0; scout.parent_team_id = 1
	scout.current_task = TeamData.TASK_SCOUT; scout.task_reason = "info_scout"
	scout.order_target_id = 2; scout.tile_pos = Vector2i(8,8)
	scout.task_start_tick = 1000; scout.task_extra_data = {"scout_mother": 1, "timeout": 99999}
	var sl := PersonData.new(); sl.id = 33; state.persons[33] = sl; scout.leader_id = 33
	state.teams[3] = scout

	print("[佈置] sub(team2) population=%d｜resources=%s" % [sub.population, str(sub.resources)])

	FactionAISystem.new()._tick_info_scout(state, scout, [])

	print("\n[逐筆] state.team_known[1] 裡 type==order_buy 且 origin_team==2 的訊息：")
	for m in state.team_known.get(1, []):
		if m.type == "order_buy" and int(m.params.get("origin_team", -1)) == 2:
			print("  order_id=%d｜qty=%s｜params=%s" % [int(m.params.get("order_id", -1)), str(m.params.get("qty")), str(m.params)])
	print("=== infonet_scout_fail_probe DONE ===")
	quit(0)
