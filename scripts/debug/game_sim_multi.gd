extends SceneTree

const CONFIGS: Array = [
	"game_sim_test", "tyrant", "merchant", "warzone"
]

func _initialize() -> void:
	var summary: Array = []
	for cfg_name in CONFIGS:
		var stats: Dictionary = _run_config(cfg_name)
		summary.append({ "config": cfg_name, "stats": stats })
	_print_comparison(summary)
	quit()

func _run_config(cfg_name: String) -> Dictionary:
	print("\n======== Running config: %s ========" % cfg_name)
	var state := WorldState.new()
	var runner := SimRunner.new()
	var config: Dictionary = GameSetup.load_config("res://config/%s.json" % cfg_name)
	if config.is_empty():
		print("[FAIL] config %s 載入失敗" % cfg_name)
		return {}
	GameSetup.setup(state, config)
	var max_ticks: int = int(config.get("max_ticks", 21600))
	var initial_player_id: int = state.player_id
	var encounters: int = 0
	var uprisings: int = 0
	var captures: int = 0
	var player_died: bool = false
	var max_treasury: float = 0.0
	var min_coin: float = 1e9
	for tick in range(max_ticks):
		var pp: Vector2i = _player_pos(state)
		var result = runner.advance_tick(state, pp)
		if state.encounter_active and result == "player_turn":
			_auto_drive_encounter(state, runner)
		if state.game_over:
			print("[GameOver] %s @ tick=%d 因: %s" % [cfg_name, tick, state.game_over_reason])
			break
		# 統計
		if state.encounter_active:
			# 估計 (避免每 tick 加)
			pass
		for tid in state.teams:
			var t = state.teams[tid]
			max_treasury = maxf(max_treasury, t.anon_treasury)
			min_coin = minf(min_coin, float(t.resources.get("coin", 0)))
	# 蒐集事件統計（從 log 或 state）
	var team_count: int = state.teams.size()
	var alive_persons: int = state.persons.size()
	return {
		"ticks_completed": min(state.world.current_tick, max_ticks),
		"team_count_final": team_count,
		"persons_final": alive_persons,
		"player_died": (state.player_id == -1 or state.game_over),
		"max_treasury": max_treasury,
		"min_coin": min_coin,
		"game_over": state.game_over,
		"game_over_reason": state.game_over_reason,
	}

func _player_pos(state: WorldState) -> Vector2i:
	var p: PersonData = state.persons.get(state.player_id)
	if p == null: return Vector2i(-1, -1)
	var t: TeamData = state.teams.get(p.team_id)
	return t.tile_pos if t else Vector2i(-1, -1)

func _auto_drive_encounter(state: WorldState, runner: SimRunner) -> void:
	# 同 game_sim_test 的 auto drive
	var enc = runner._encounter_system
	for u in state.encounter_units:
		if u.get("person_id", -1) == state.player_id:
			if not u.get("pending_action", {}).is_empty(): continue
			var enemy_idx = enc._get_nearest_enemy_index(u, state)
			if enemy_idx == -1:
				u["pending_action"] = { "type": "idle", "target_idx": -1,
					"move_to": u["pos"], "attack_part": "" }
			else:
				var enemy = state.encounter_units[enemy_idx]
				var dist = enc.hex_dist(u["pos"], enemy["pos"])
				if dist <= 1:
					u["pending_action"] = { "type": "attack",
						"target_idx": enemy_idx, "attack_part": "torso" }
				else:
					u["pending_action"] = { "type": "move", "target_idx": -1,
						"move_to": enc._calc_next_step(u["pos"], enemy["pos"]),
						"attack_part": "" }
			break

func _print_comparison(summary: Array) -> void:
	print("\n========== 多配置對比 ==========")
	print("%-20s %10s %12s %10s %10s %12s %10s" % [
		"config", "ticks", "teams", "persons", "died", "max_treas", "min_coin"])
	for entry in summary:
		var s = entry.stats
		print("%-20s %10d %12d %10d %10s %12.0f %10.0f" % [
			entry.config,
			int(s.get("ticks_completed", 0)),
			int(s.get("team_count_final", 0)),
			int(s.get("persons_final", 0)),
			"yes" if s.get("player_died", false) else "no",
			float(s.get("max_treasury", 0)),
			float(s.get("min_coin", 0))
		])
		if s.get("game_over", false):
			print("    > game_over: %s" % s.get("game_over_reason", "?"))
