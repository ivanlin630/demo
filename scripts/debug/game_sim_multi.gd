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
	var pop_init: int = _total_pop(state)
	var coin_eq_init: float = _coin_equivalent_total(state)
	var food_snapshot: Dictionary = {}   # team_id → 上月食物量（FoodLedger 反推 income 用）
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
		if state.world.current_tick % WorldState.TICKS_PER_MONTH == 0:
			print("[PopSample] %s tick=%d total_pop=%d" % [
				cfg_name, state.world.current_tick, _total_pop(state)])
			_print_food_ledger(state, cfg_name, food_snapshot)
	# 蒐集事件統計（從 log 或 state）
	var team_count: int = state.teams.size()
	var alive_persons: int = state.persons.size()
	# coin 守恆審計：coin 等值總量（coin + gold×20 + silver×5，含地面/公庫/人身/遺財）
	# mint 依固定匯率轉換 → 等值總量應恆定
	var coin_eq_final: float = _coin_equivalent_total(state)
	print("[CoinAudit] %s coin_eq init=%.1f final=%.1f delta=%.2f" % [
		cfg_name, coin_eq_init, coin_eq_final, coin_eq_final - coin_eq_init])
	# 設施統計：NPC 建造數 + 村莊設施組合
	var fac: Dictionary = _facility_stats(state)
	print("[FacilityStats] %s 設施總數=%d 組合=%s" % [
		cfg_name, int(fac.facility_count), str(fac.combos)])
	# B 期材料層統計：team 持有 + 公庫總量（herb 只能從 tile 採集而來 → >0 即驗證採集鏈）
	var mat: Dictionary = _material_totals(state)
	print("[MaterialStats] %s herb=%.1f horses=%.1f mounts=%.1f wagons=%.2f medicine=%.2f" % [
		cfg_name, mat.herb, mat.horses, mat.mounts, mat.wagons, mat.medicine])
	return {
		"coin_eq_init": coin_eq_init,
		"coin_eq_final": coin_eq_final,
		"facility_count": fac.facility_count,
		"facility_combos": fac.combos,
		"ticks_completed": min(state.world.current_tick, max_ticks),
		"team_count_final": team_count,
		"persons_final": alive_persons,
		"pop_init": pop_init,
		"pop_final": _total_pop(state),
		"player_died": (state.player_id == -1 or state.game_over),
		"max_treasury": max_treasury,
		"min_coin": min_coin,
		"game_over": state.game_over,
		"game_over_reason": state.game_over_reason,
	}

# 有限資源守恆審計：coin 等值總量（mint 匯率 gold×20 / silver×5）
func _coin_equivalent_total(state: WorldState) -> float:
	var total: float = 0.0
	for tid in state.teams:
		var t: TeamData = state.teams[tid]
		total += float(t.resources.get("coin", 0)) + t.anon_treasury
		total += float(t.resources.get("ore_gold", 0)) * OutpostSystem.GOLD_TO_COIN_RATIO
		total += float(t.resources.get("ore_silver", 0)) * OutpostSystem.SILVER_TO_COIN_RATIO
	for pid in state.persons:
		total += state.persons[pid].coin
	for tile_id in state.world.tiles:
		var tile: HexTileData = state.world.tiles[tile_id]
		total += float(tile.public_storage.get("coin", 0)) + tile.abandoned_coin
		total += float(tile.public_storage.get("ore_gold", 0)) * OutpostSystem.GOLD_TO_COIN_RATIO
		total += float(tile.public_storage.get("ore_silver", 0)) * OutpostSystem.SILVER_TO_COIN_RATIO
		total += float(tile.resources.get("ore_gold", 0)) * OutpostSystem.GOLD_TO_COIN_RATIO
		total += float(tile.resources.get("ore_silver", 0)) * OutpostSystem.SILVER_TO_COIN_RATIO
	return total

# 設施統計：總設施類數 + 各 outpost 的設施組合分佈
func _facility_stats(state: WorldState) -> Dictionary:
	var combos: Dictionary = {}
	var count: int = 0
	for tile_id in state.world.tiles:
		var tile: HexTileData = state.world.tiles[tile_id]
		if tile.outpost_level == 0: continue
		var set_arr: Array = []
		for f in OutpostSystem.FACILITY_DEF:
			if int(tile.get(OutpostSystem.FACILITY_DEF[f]["current_level_key"])) > 0:
				set_arr.append(f)
		count += set_arr.size()
		if not set_arr.is_empty():
			set_arr.sort()
			var key: String = ",".join(set_arr)
			combos[key] = int(combos.get(key, 0)) + 1
	return { "facility_count": count, "combos": combos }

func _total_pop(state: WorldState) -> int:
	var total: int = 0
	for tid in state.teams:
		total += state.teams[tid].population
	return total

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

func _material_totals(state: WorldState) -> Dictionary:
	var totals: Dictionary = { "herb": 0.0, "horses": 0.0, "mounts": 0.0, "wagons": 0.0, "medicine": 0.0 }
	for tid in state.teams:
		var team: TeamData = state.teams[tid]
		for k in totals:
			totals[k] = float(totals[k]) + float(team.resources.get(k, 0))
	for tile_id in state.world.tiles:
		var tile: HexTileData = state.world.tiles[tile_id]
		for k in totals:
			totals[k] = float(totals[k]) + float(tile.public_storage.get(k, 0))
	return totals

# 月度糧收支儀器：burn = pop×2.4 + (mounts+horses)×0.5（估算）；
# 收入難直接量 → 用月間 food 變化反推：income/day = ΔF/30 + burn
func _print_food_ledger(state: WorldState, cfg_name: String, snapshot: Dictionary) -> void:
	var owners: Dictionary = {}
	for tile_id in state.world.tiles:
		var tile: HexTileData = state.world.tiles[tile_id]
		if tile.outpost_level > 0 and tile.outpost_owner != -1:
			owners[tile.outpost_owner] = true
	for tid in state.teams:
		var t: TeamData = state.teams[tid]
		var food: float = float(t.resources.get("food", 0))
		var burn: float = float(t.population) * ResourceSystem.FOOD_PER_PERSON_PER_DAY \
			+ (float(t.resources.get("mounts", 0)) + float(t.resources.get("horses", 0))) \
			* ResourceSystem.FOOD_PER_MOUNT_PER_DAY
		var days: float = food / maxf(burn, 0.001)
		var kind: String = "wander"
		if owners.has(tid): kind = "outpost"
		elif TeamData.TAG_PRODUCE in t.tags: kind = "resident"
		elif TeamData.TAG_MILITARY in t.tags: kind = "military"
		var income_str: String = "NA"
		if snapshot.has(tid):
			income_str = "%.1f" % ((food - float(snapshot[tid])) / 30.0 + burn)
		var tile: HexTileData = state.world.tiles.get(t.tile_pos.x * 1000 + t.tile_pos.y)
		var tile_str: String = "off_map"
		if tile != null:
			tile_str = "%s/pool=%.0f/op=%d" % [tile.terrain, float(tile.resources.get("food", 0)), tile.outpost_level]
		print("[FoodLedger] %s team=%d kind=%s pop=%d food=%.0f days=%.1f burn/day=%.1f income/day=%s tile=%s task=%s" % [
			cfg_name, tid, kind, t.population, food, days, burn, income_str, tile_str, t.current_task])
		snapshot[tid] = food

func _print_comparison(summary: Array) -> void:
	print("\n========== 多配置對比 ==========")
	print("%-20s %10s %12s %10s %10s %12s %10s %10s %10s" % [
		"config", "ticks", "teams", "persons", "died", "max_treas", "min_coin",
		"pop_init", "pop_final"])
	for entry in summary:
		var s = entry.stats
		print("%-20s %10d %12d %10d %10s %12.0f %10.0f %10d %10d" % [
			entry.config,
			int(s.get("ticks_completed", 0)),
			int(s.get("team_count_final", 0)),
			int(s.get("persons_final", 0)),
			"yes" if s.get("player_died", false) else "no",
			float(s.get("max_treasury", 0)),
			float(s.get("min_coin", 0)),
			int(s.get("pop_init", 0)),
			int(s.get("pop_final", 0))
		])
		if s.get("game_over", false):
			print("    > game_over: %s" % s.get("game_over_reason", "?"))
