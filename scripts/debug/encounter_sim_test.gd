extends SceneTree
# 遭遇戰模擬測試 — 自動跑完一場遭遇戰，印每 tick 狀態，檢查不變量
# 用法: Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/encounter_sim_test.gd

func _initialize() -> void:
	_run()
	quit()

func _run() -> void:
	print("=== EncounterSim START ===")
	var enc := EncounterSystem.new()
	var state := WorldState.new()
	state.player_id = 0

	# ── 玩家 Person ──────────────────────────────────────────────────────────
	var player := PersonData.new()
	player.id       = 0
	player.person_name = "玩家"
	player.team_id  = 0
	player.skills   = { "統領": 0.0, "戰鬥": 0.5, "弓箭": 0.0, "求生": 0.4,
	                    "生產": 0.0, "製造": 0.0, "工程": 0.0, "醫療": 0.0,
	                    "戰術": 0.3, "計謀": 0.0, "交涉": 0.0, "商業": 0.0,
	                    "偵查": 0.3, "潛行": 0.0 }
	player.attributes = { "體力": 0.7, "智力": 0.5, "魅力": 0.5, "毅力": 0.5 }
	player.values     = { "野心": 0.5, "求生欲": 0.3, "義氣": 0.5, "貪婪": 0.3,
	                      "慎重": 0.4, "好戰": 0.6, "殘忍": 0.3, "信義": 0.6 }
	# body_parts 用 PersonData 預設值（已有 head/torso/arms/legs）
	state.persons[0] = player

	# ── NPC Person ──────────────────────────────────────────────────────────
	var npc := PersonData.new()
	npc.id       = 1
	npc.person_name = "NPC甲"
	npc.team_id  = 1
	npc.skills   = { "統領": 0.0, "戰鬥": 0.3, "弓箭": 0.0, "求生": 0.3,
	                 "生產": 0.0, "製造": 0.0, "工程": 0.0, "醫療": 0.0,
	                 "戰術": 0.1, "計謀": 0.0, "交涉": 0.0, "商業": 0.0,
	                 "偵查": 0.1, "潛行": 0.0 }
	npc.attributes = { "體力": 0.6, "智力": 0.5, "魅力": 0.5, "毅力": 0.5 }
	npc.values     = { "野心": 0.5, "求生欲": 0.5, "義氣": 0.5, "貪婪": 0.5,
	                   "慎重": 0.5, "好戰": 0.5, "殘忍": 0.5, "信義": 0.5 }
	state.persons[1] = npc

	# ── Teams ─────────────────────────────────────────────────────────────
	var atk := TeamData.new()
	atk.team_id         = 0
	atk.leader_id       = 0
	atk.named_members   = []   # leader already counted
	atk.population      = 3
	atk.armed_anon_ratio = 0.5   # 1 anon unit
	atk.fatigue         = 0.0
	atk.resources       = TeamData.new().resources.duplicate()
	atk.resources["weapon_melee_low"] = 5
	state.teams[0] = atk

	var def := TeamData.new()
	def.team_id         = 1
	def.leader_id       = 1
	def.named_members   = []
	def.population      = 3
	def.armed_anon_ratio = 0.5
	def.fatigue         = 0.0
	def.resources       = TeamData.new().resources.duplicate()
	def.resources["weapon_melee_low"] = 5
	state.teams[1] = def

	# ── Init encounter ────────────────────────────────────────────────────
	enc.init_encounter(state, 0, 1, "normal")
	print("[EncounterSim] Units spawned: %d" % state.encounter_units.size())
	for u in state.encounter_units:
		print("  team=%d person=%d pos=%s timer=%d" % [
			u["team_id"], u["person_id"], str(u["pos"]), u["action_timer"]])

	# ── Simulation loop ───────────────────────────────────────────────────
	var max_ticks := 300
	var player_turns := 0
	var player_attacks := 0
	var consecutive_player_turns := 0   # detect player getting stuck in infinite turns
	var last_result := "ongoing"

	for tick in range(max_ticks):
		var result: String = enc.advance_encounter_tick(state)
		last_result = result

		match result:
			"player_turn":
				player_turns += 1
				consecutive_player_turns += 1
				if consecutive_player_turns > 5:
					print("[WARN tick=%d] 連續 player_turn=%d — 可能卡住！" % [tick, consecutive_player_turns])

				var pu: Dictionary = _find_player_unit(state)
				if pu.is_empty():
					print("[FAIL tick=%d] player_turn 但找不到玩家 unit" % tick)
					break

				# 自動決策：攻擊或移動
				var nearest_idx: int = enc._get_nearest_enemy_index(pu, state)
				if nearest_idx == -1:
					print("[Tick%d] player_turn #%d: 無敵人，設 idle" % [tick, player_turns])
					pu["pending_action"] = { "type": "idle", "target_idx": -1,
						"move_to": pu["pos"], "attack_part": "" }
				else:
					var enemy: Dictionary = state.encounter_units[nearest_idx]
					var dist: int = enc.hex_dist(pu["pos"], enemy["pos"])
					if dist <= 1:
						player_attacks += 1
						print("[Tick%d] player_turn #%d: ATTACK team=%d pos=%s dist=%d" % [
							tick, player_turns, enemy["team_id"], str(enemy["pos"]), dist])
						pu["pending_action"] = { "type": "attack",
							"target_idx": nearest_idx, "attack_part": "torso" }
					else:
						var next: Vector2i = enc._calc_next_step(pu["pos"], enemy["pos"])
						print("[Tick%d] player_turn #%d: MOVE %s→%s (enemy at %s dist=%d)" % [
							tick, player_turns, str(pu["pos"]), str(next), str(enemy["pos"]), dist])
						# Use "move" pending_action so encounter_system resets timer
						pu["pending_action"] = { "type": "move", "target_idx": -1,
							"move_to": next, "attack_part": "" }

			"attacker_win", "defender_win", "draw":
				print("[EncounterSim] ENDED tick=%d result=%s" % [tick, result])
				break

			"ongoing":
				consecutive_player_turns = 0
				if tick % 30 == 0:
					_print_state(state, enc, tick)

	print("")
	print("[EncounterSim] === 最終狀態 tick=%d ===" % state.encounter_tick)
	_print_state(state, enc, state.encounter_tick)
	print("")
	print("[EncounterSim] Summary:")
	print("  player_turns=%d  player_attacks=%d  result=%s" % [
		player_turns, player_attacks, last_result])
	_check_invariants(state, enc, player_turns, last_result, max_ticks)
	print("=== EncounterSim END ===")


func _find_player_unit(state: WorldState) -> Dictionary:
	for u in state.encounter_units:
		if u.get("person_id", -1) == state.player_id:
			return u
	return {}


func _print_state(state: WorldState, enc: EncounterSystem, tick: int) -> void:
	print("[State tick=%d]" % tick)
	for u in state.encounter_units:
		var dead    := enc.is_dead(u, state)
		var capable := enc.is_combat_capable(u, state)
		var timer: int = u.get("action_timer", -1)
		var prisoner: bool = u.get("is_prisoner", false)
		var exited: bool   = u.get("has_exited", false)
		var tag := ""
		if dead: tag = " [死]"
		elif prisoner: tag = " [俘]"
		elif exited: tag = " [退]"
		elif not capable: tag = " [失能]"
		print("  team=%d p=%d pos=%s timer=%d capable=%s%s" % [
			u["team_id"], u["person_id"], str(u["pos"]), timer,
			str(capable), tag])


func _check_invariants(state: WorldState, enc: EncounterSystem,
		player_turns: int, result: String, max_ticks: int) -> void:
	print("[EncounterSim] --- 不變量檢查 ---")
	var fail := false

	# 1. 玩家至少得到一次行動
	if player_turns == 0:
		print("  FAIL: 玩家從未得到行動機會")
		fail = true
	else:
		print("  OK: 玩家共得到 %d 次行動" % player_turns)

	# 2. 遭遇戰應結束（未達 max_ticks 超時）
	if result == "ongoing":
		print("  FAIL: 遭遇戰超時（%d ticks 未結束）— 可能卡住" % max_ticks)
		fail = true
	else:
		print("  OK: 遭遇戰正常結束 (%s)" % result)

	# 3. 無存活單位重疊（occupancy）
	var positions: Array = []
	var overlap := false
	for u in state.encounter_units:
		if enc.is_dead(u, state) or u.get("has_exited", false): continue
		if u.get("is_prisoner", false): continue
		if positions.has(u["pos"]):
			print("  FAIL: 單位重疊 pos=%s" % str(u["pos"]))
			overlap = true
		positions.append(u["pos"])
	if not overlap:
		print("  OK: 無單位重疊")

	# 4. 玩家 unit action_timer 不應為負數
	var pu := _find_player_unit(state)
	if not pu.is_empty():
		var t: int = pu.get("action_timer", 0)
		if t < 0:
			print("  FAIL: 玩家 action_timer=%d < 0" % t)
			fail = true
		else:
			print("  OK: 玩家 action_timer=%d" % t)

	if not fail:
		print("  全部通過")
