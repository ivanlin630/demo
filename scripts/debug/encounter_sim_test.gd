extends SceneTree
# 遭遇戰模擬測試 — 自動跑完一場遭遇戰，印每 tick 狀態，檢查不變量
# 用法: Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/encounter_sim_test.gd
#
# 場景：玩家隊（混近/遠端匿名）vs NPC 精英隊（高戰鬥技能，有護甲）
# 測試重點：equip_order 武器分配、俘虜、遭遇戰結束條件、timer 無負數

func _initialize() -> void:
	_run()
	quit()

func _run() -> void:
	print("=== EncounterSim START ===")
	var enc := EncounterSystem.new()
	var state := WorldState.new()
	state.player_id = 0

	# ── 玩家 Person（中等戰力）────────────────────────────────────────────────
	var player := PersonData.new()
	player.id          = 0
	player.person_name = "玩家"
	player.team_id     = 0
	player.skills   = { "統領": 0.2, "戰鬥": 0.5, "弓箭": 0.3, "求生": 0.4,
	                    "生產": 0.0, "製造": 0.0, "工程": 0.0, "醫療": 0.0,
	                    "戰術": 0.3, "計謀": 0.0, "交涉": 0.0, "商業": 0.0,
	                    "偵查": 0.3, "潛行": 0.0 }
	player.attributes = { "體力": 0.7, "智力": 0.5, "魅力": 0.5, "毅力": 0.6 }
	player.values     = { "野心": 0.5, "求生欲": 0.3, "義氣": 0.5, "貪婪": 0.3,
	                      "慎重": 0.4, "好戰": 0.6, "殘忍": 0.3, "信義": 0.6 }
	# 玩家個人武器（不從 pool 借）
	player.equipment["hand_1"] = { "type": "sword", "grade": "weapon_melee_low" }
	state.persons[0] = player

	# ── NPC Person（高戰力精英，帶護甲）──────────────────────────────────────
	var npc := PersonData.new()
	npc.id          = 1
	npc.person_name = "NPC甲"
	npc.team_id     = 1
	npc.skills   = { "統領": 0.2, "戰鬥": 0.7, "弓箭": 0.0, "求生": 0.5,
	                 "生產": 0.0, "製造": 0.0, "工程": 0.0, "醫療": 0.0,
	                 "戰術": 0.4, "計謀": 0.0, "交涉": 0.0, "商業": 0.0,
	                 "偵查": 0.2, "潛行": 0.0 }
	npc.attributes = { "體力": 0.8, "智力": 0.5, "魅力": 0.5, "毅力": 0.7 }
	npc.values     = { "野心": 0.5, "求生欲": 0.4, "義氣": 0.5, "貪婪": 0.4,
	                   "慎重": 0.4, "好戰": 0.7, "殘忍": 0.4, "信義": 0.5 }
	# NPC 個人裝備（高階近戰武器 + 護甲）
	npc.equipment["hand_1"] = { "type": "sword",  "grade": "weapon_melee_high" }
	npc.equipment["torso"]  = { "type": "armor",  "grade": "armor_low" }
	state.persons[1] = npc

	# ── 攻擊方（玩家隊）：人多，近/遠混合 ───────────────────────────────────
	var atk := TeamData.new()
	atk.team_id          = 0
	atk.leader_id        = 0
	atk.named_members    = []          # leader 不算進 named_members
	atk.population       = 20
	atk.armed_anon_ratio = 0.5         # 10 個匿名參戰
	atk.fatigue          = 0.0
	atk.resources        = TeamData.new().resources.duplicate()
	atk.resources["weapon_melee_low"]  = 10
	atk.resources["weapon_ranged_low"] = 10
	atk.resources["armor_low"]         = 20
	atk.resources["arrows"]            = 200
	atk.resources["anon_combat_skill"] = 0.35
	# equip_order: 3 近戰 + 2 遠端（_assign_anon_weapons 會按此分配）
	atk.equip_order = { "melee_low": 5, "melee_high": 0, "ranged_low": 5, "ranged_high": 0 }
	state.teams[0] = atk

	# ── 防守方（NPC 隊）：人少但精銳，全近戰 ────────────────────────────────
	var def := TeamData.new()
	def.team_id          = 1
	def.leader_id        = 1
	def.named_members    = []
	def.population       = 5
	def.armed_anon_ratio = 0.6         # 3 個匿名參戰
	def.fatigue          = 0.0
	def.resources        = TeamData.new().resources.duplicate()
	def.resources["weapon_melee_low"]  = 2
	def.resources["weapon_melee_high"] = 1
	def.resources["armor_low"]         = 3
	def.resources["armor_high"]        = 10
	def.resources["anon_combat_skill"] = 0.5
	# equip_order: 先配高階，再配低階
	def.equip_order = { "melee_low": 2, "melee_high": 1, "ranged_low": 0, "ranged_high": 0 }
	state.teams[1] = def

	# ── Init encounter ────────────────────────────────────────────────────────
	enc.init_encounter(state, 0, 1, "normal")
	print("[EncounterSim] Units spawned: %d" % state.encounter_units.size())
	for u in state.encounter_units:
		print("  team=%d p=%d pos=%s" % [u["team_id"], u["person_id"], str(u["pos"])])
		for slot in u.get("equipment", {}):
			var eq: Dictionary = u["equipment"][slot]
			if eq.get("grade", "") == "": continue
			print("    equip[%s] type=%s grade=%s" % [
				slot, eq.get("type", "?"), eq.get("grade", "?")])
		var inv: Array = u.get("inventory", [])
		if inv.is_empty():
			print("    inv: (空)")
		else:
			for item in inv:
				print("    inv: grade=%s qty=%s" % [
					item.get("grade", "?"), str(item.get("qty", 1))])

	# ── Simulation loop ───────────────────────────────────────────────────────
	var max_ticks               := 800
	var player_turns            := 0
	var player_attacks          := 0
	var consecutive_player_turns := 0
	var last_result             := "ongoing"

	for tick in range(max_ticks):
		var result: String = enc.advance_encounter_tick(state)
		last_result = result

		match result:
			"player_turn":
				player_turns            += 1
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
					print("[Tick%d] player_turn #%d: 無敵人，idle" % [tick, player_turns])
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
							tick, player_turns, str(pu["pos"]), str(next),
							str(enemy["pos"]), dist])
						pu["pending_action"] = { "type": "move", "target_idx": -1,
							"move_to": next, "attack_part": "" }

			"attacker_win", "defender_win", "draw":
				print("[EncounterSim] ENDED tick=%d result=%s" % [tick, result])
				break

			"ongoing":
				consecutive_player_turns = 0
				if tick % 60 == 0:
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
		var dead     := enc.is_dead(u, state)
		var capable  := enc.is_combat_capable(u, state)
		var timer: int = u.get("action_timer", -1)
		var prisoner: bool = u.get("is_prisoner", false)
		var exited: bool   = u.get("has_exited", false)
		var wpn: String    = u.get("equipment", {}).get("hand_1", {}).get("grade", "unarmed")
		var arm: String    = u.get("equipment", {}).get("torso",  {}).get("grade", "none")
		var tag := ""
		if dead:          tag = " [死]"
		elif prisoner:    tag = " [俘]"
		elif exited:      tag = " [退]"
		elif not capable: tag = " [失能]"
		print("  team=%d p=%d pos=%s timer=%d wpn=%s arm=%s%s" % [
			u["team_id"], u["person_id"], str(u["pos"]), timer,
			wpn, arm, tag])


func _check_invariants(state: WorldState, enc: EncounterSystem,
		player_turns: int, result: String, max_ticks: int) -> void:
	print("[EncounterSim] --- 不變量檢查 ---")
	var fail := false

	# 1. 玩家至少一次行動
	if player_turns == 0:
		print("  FAIL: 玩家從未得到行動機會")
		fail = true
	else:
		print("  OK: 玩家共得到 %d 次行動" % player_turns)

	# 2. 遭遇戰正常結束
	if result == "ongoing":
		print("  FAIL: 遭遇戰超時（%d ticks 未結束）— 可能卡住" % max_ticks)
		fail = true
	else:
		print("  OK: 遭遇戰正常結束 (%s)" % result)

	# 3. 無存活單位重疊
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

	# 4. 玩家 timer 不為負
	var pu := _find_player_unit(state)
	if not pu.is_empty():
		var t: int = pu.get("action_timer", 0)
		if t < 0:
			print("  FAIL: 玩家 action_timer=%d < 0" % t)
			fail = true
		else:
			print("  OK: 玩家 action_timer=%d" % t)

	# 5. 俘虜計數一致：prisoner_population 與實際標記數吻合
	var marked_prisoners: Dictionary = {}   # team_id → count
	for u in state.encounter_units:
		if u.get("is_prisoner", false):
			var tid: int = u["team_id"]
			marked_prisoners[tid] = marked_prisoners.get(tid, 0) + 1
	for tid in marked_prisoners:
		print("  INFO: Team%d 有 %d 具名/匿名單位被標記為俘虜" % [tid, marked_prisoners[tid]])

	# 6. 武器分配驗證：無單位同時有兩種武器
	for u in state.encounter_units:
		var h1: String = u.get("equipment", {}).get("hand_1", {}).get("grade", "")
		var h2: String = u.get("equipment", {}).get("hand_2", {}).get("grade", "")
		if h1 != "" and h2 != "" and h1 != h2:
			print("  WARN: team=%d p=%d 同時持有 h1=%s h2=%s" % [
				u["team_id"], u["person_id"], h1, h2])

	if not fail:
		print("  全部通過")
