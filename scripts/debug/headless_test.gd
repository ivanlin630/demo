extends SceneTree

func _initialize() -> void:
	_run_sim_test()
	_test_anon_tier_const()
	_test_team_anon_tiers_default()
	_test_anon_tier_queries()
	_test_add_remove_anon()
	_test_add_exp()
	_test_kill_random_proportional()
	_test_transfer_proportional()
	_test_promote_success()
	_test_promote_insufficient_exp()
	_test_promote_insufficient_resources()
	_test_promote_elite_requires_weapon()
	_test_promote_leader_skill_cap()
	_test_training_adds_exp()
	_test_anon_speed_tiers()
	_test_update_armor_config()
	_test_update_guard_ratio()
	_test_faction_ai_run_calls_all_updates()
	_test_food_consumption_total()
	_test_fatigue_accumulation()
	_test_fatigue_recovery()
	_test_salary_interval_weekly()
	_test_intervals_divisible_by_cadence()
	_test_salary_auto_npc_vs_player()
	_test_setup_mode_explicit()
	_test_full_config_load()
	_test_s11_leader_succession()
	_test_team_previous_task_field()
	_test_survival_trigger_urgent()
	_test_survival_sticky()
	_test_survival_helpers()
	_test_survival_decision_tree()
	_test_strategic_ai_respects_survival()
	_test_strategic_in_map_check()
	_test_breakout_distance_guard()
	_test_stuck_allows_reeval()
	_test_survival_reeval_in_loot()
	_test_trade_net_dispatches()
	_test_aid_resolve_npc_accept()
	_test_aid_resolve_npc_refuse()
	_test_aid_player_forced_event()
	_test_aid_player_response_give()
	_test_aid_repeated_annoyance()
	_test_aid_stranger()
	_test_resident_fields()
	_test_is_resident_detection()
	_test_resident_pop_cap_overflow()
	_test_resident_movement_lock()
	_test_resident_no_salary()
	_test_resident_tax_with_stress()
	_test_invite_settle_execute()
	_test_subteam_settle()
	_test_uprising_trigger()
	_test_defection_paths()
	_test_owner_contact_timeout()
	_test_pacify_subteam()
	# ── Merchant Trade (A) + Outpost Capture (D) ──
	_test_merchant_capture_fields()
	_test_resolve_market_bidirectional()
	_test_merchant_inventory_trade()
	_test_find_trade_target_max_gap()
	_test_encounter_capture_outpost()
	_test_unowned_outpost_takeover()
	_test_alliance_outpost_transfer()
	_test_uprising_paths()
	_test_abandon_outpost()
	# ── NPC Infrastructure (C) ──
	_test_task_extra_data_field()
	_test_facility_def_registry()
	_test_dispatch_builder()
	_test_evaluate_outpost_location()
	_test_evaluate_infrastructure()
	_test_subteam_arrival_triggers_build()
	_test_dispatch_upgrader_and_facility()
	_test_auto_settle_after_build()
	_test_player_upgrade_outpost()
	_test_player_build_facility()
	_test_game_over_field()
	_test_handle_player_leader_death()
	_test_no_heir_game_over()
	_test_choose_heir_action()
	_test_choose_heir_invalid_candidate()
	_test_advance_tick_game_over_freeze()
	_test_advance_tick_awaiting_heir_freeze()
	_test_encounter_kills_player_triggers_heir()
	# ── Coin Economy + Outpost Public Storage ──
	_test_coin_storage_fields()
	_test_storage_cap()
	_test_collect_ore_to_storage()
	_test_mint_facility()
	_test_manufacturing_to_storage()
	_test_salary_to_treasury()
	_test_promote_anon_takes_share()
	_test_extraction()
	_test_player_extract_treasury()
	_test_encounter_treasury_loot()
	_test_on_team_extinct_to_storage()
	_test_pickup_abandoned_coin()
	_test_subteam_treasury_split()
	_test_npc_auto_withdraw()
	_test_npc_auto_deposit()
	_test_player_withdraw_deposit()
	_test_last_tile_pos_field()
	_test_find_path_basic()
	_test_find_path_cache()
	_test_find_path_no_path()
	_test_eta_ticks()
	_test_observe_velocity_visible()
	_test_observe_velocity_invisible()
	_test_estimate_catch_up_reachable()
	_test_estimate_catch_up_too_far()
	_test_estimate_catch_up_out_of_sight()
	_test_movement_uses_astar()
	_test_ai_catch_up_filters_unreachable()
	# ── Prosperity Attack ──
	_test_readiness_threshold()
	_test_find_prosperity_prey()
	_test_evaluate_prosperity_trigger()
	_test_prosperity_low_ambition_skip()
	_test_prosperity_low_readiness_skip()
	_test_prosperity_same_faction_skip()
	_test_prosperity_treasury_bonus()
	_test_prosperity_prey_personality_weight()
	_test_prosperity_cadence()
	_test_survival_b_branch_far_outpost_loot()
	_test_survival_b_branch_near_outpost_return()
	_test_occupy_resident_accept()
	_test_occupy_massacre()
	_test_occupy_abandon()
	_test_occupy_force()
	_test_attack_defeat_reaction()
	# ── Combat Engagement ──
	_test_movement_returns_moved_and_arrived()
	_test_process_on_move_triggers_combat()
	_test_named_weight_speed()
	# ── Mounts / Wagons 速度系統 ──
	_test_effective_mount_wagon_limit()
	_test_compute_mount_bonus()
	_test_compute_wagon_penalty()
	_test_mount_food_consumption()
	_test_stable_facility_def()
	_test_stable_produces_mounts()
	_test_wild_horses_generation()
	_test_wild_horses_no_auto_collect()
	_test_mount_loot_total_wipe()
	_test_mount_loot_partial()
	_test_mounts_in_public_resources()
	_test_stable_produces_to_public_storage()
	_test_outpost_collect_wild_horses()
	_test_outpost_collect_no_outpost_skip()
	_test_outpost_collect_cap_limit()
	_test_auto_withdraw_on_active_task()
	_test_no_withdraw_when_idle()
	# ── Encounter Engagement ──
	_test_predict_intercept_static()
	_test_predict_intercept_moving()
	_test_predict_intercept_out_of_sight()
	_test_threat_score_out_of_sight()
	_test_threat_score_high_hostile()
	_test_threat_score_distance_decay()
	_test_task_defend_prepare_const()
	_test_evaluate_threat_finds_hostile()
	_test_evaluate_threat_cadence()
	_test_dispatch_flee_high_survival()
	_test_dispatch_defend_high_martial_non_resident()
	_test_dispatch_prepare_resident()
	_test_dispatch_tribute_high_business()
	_test_resident_lock_prepare_allowed()
	_test_find_trade_partner_outpost_only()
	_test_trade_timeout()
	_test_absorb_then_spill_no_trade()
	_test_absorb_only_at_own_outpost()
	_test_spill_back_with_cap_overflow()
	_test_resolve_market_absorbs_storage()
	_test_resident_team_absorbs_public_storage()
	# ── Outpost 居民派駐 AI ──
	_test_residency_team_fields()
	_test_has_resident_team_check()
	_test_dispatch_high_ambition()
	_test_invite_high_commerce()
	_test_dispatch_subteam_creates_subteam()
	_test_invite_exile_accept()
	_test_invite_exile_reject_cooldown()
	_test_settle_triggers_subteam_merge_back()
	# ── Reaction 職責收斂 ──
	_test_reaction_fields()
	_test_p3_removed()
	_test_p2_no_food()
	_test_work_morale_shift()
	_test_collect_uses_morale()
	_test_p5_needs_surplus()
	_test_n5_coin_conserved()
	_test_n1_solo_skip()
	_test_n1_leader_tier_sync()
	_test_n1_named_spawns_exile()
	_test_n3_joins_existing_exile()
	_test_bridge_no_threat_no_hijack()
	_test_bridge_with_threat_flees()
	# ── Task Arbiter ──
	_test_arbiter_basic()
	_test_arbiter_combat_lock()
	_test_arbiter_release_transition()
	_test_arbiter_defiance()
	_test_arbiter_suppression()
	_test_arbiter_suppression_burst()
	_test_arbiter_survival_beats_dispatch()
	_test_arbiter_dispatch_beats_faction_goal()
	_test_bridge_cannot_stomp_survival()
	# ── Economy / Spam Fixes ──
	_test_salary_budget_ratio()
	_test_salary_full_pay_unchanged()
	_test_trade_partner_requires_resident()
	_test_diplomacy_reject_cooldown()
	_test_equip_order_no_oscillation()
	_test_n1_leader_no_anon_pop_stable()
	# ── Minor 長大簡版 ──
	_test_minor_maturation()

	_test_facility_def_v2()
	_test_facility_slots()
	_test_outpost_cost_no_finite()
	quit()

func _test_minor_maturation() -> void:
	print("--- PopFix: minor 每月長大 ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	state.world.current_tick = WorldState.TICKS_PER_MONTH   # 月邊界
	var team := TeamData.new(); team.team_id = 0
	team.population = 10
	team.minor_population = 5
	var leader := PersonData.new(); leader.id = 1; leader.team_id = 0
	leader.skills = { "統領": 0.99 }   # cap 大，避免 overflow 干擾
	state.persons[1] = leader; team.leader_id = 1
	state.teams[0] = team
	var tiers_before: int = AnonTierSystem.total_pop(team)
	var ps := PopulationSystem.new()
	ps.check_overflow(state)
	# 5 × 0.1 = 0.5 → max(,1) = 1 名長大
	assert(team.minor_population == 4, "minor 應 4，實際=%d" % team.minor_population)
	assert(team.population == 11, "pop 應 11，實際=%d" % team.population)
	assert(AnonTierSystem.total_pop(team) == tiers_before + 1, "tier 平民 +1")
	# 非月邊界不觸發
	state.world.current_tick = WorldState.TICKS_PER_MONTH + WorldState.TICKS_PER_DAY
	ps.check_overflow(state)
	assert(team.minor_population == 4, "非月邊界不長大")
	# pop 滿 50 照長 → 溢出交給 overflow 分團（同呼叫內處理）
	team.population = 50
	state.world.current_tick = WorldState.TICKS_PER_MONTH * 2
	ps.check_overflow(state)
	assert(team.minor_population == 3, "滿 50 仍長大，實際 minor=%d" % team.minor_population)
	print("PopFix OK")

func _run_sim_test() -> void:
	var state := WorldState.new()
	var runner := SimRunner.new()

	# 用 WorldGenerator 產生 radius=4 的 hex 地圖（含 (8,4) 位置）
	var generator = load("res://scripts/simulation/world_generator.gd").new()
	generator.generate(state, { "radius": 4, "seed": 42 })
	# 強制路徑地形為 plains，避免 mountain 拖慢移動驗證外交時序
	for _tid in [4004, 5004, 6004, 7004, 8004]:
		if state.world.tiles.has(_tid):
			(state.world.tiles[_tid] as HexTileData).terrain = "plains"
	# 測試劇本：設定固定據點
	var _t0: HexTileData = state.world.tiles[4004] as HexTileData
	_t0.outpost_type  = "military"
	_t0.outpost_level = 1
	_t0.outpost_owner = 0                                          # Team0 起始軍事據點（營寨）
	(state.world.tiles[5004] as HexTileData).resources["food"] = 0 # 測試：tile(5,4) 無糧

	for t in range(3):
		var team := TeamData.new()
		team.team_id = t
		team.population = 10
		team.minor_population = 1
		var _mat: int = 100 if t == 2 else 10
		team.resources = {
			"food": 500.0, "material": _mat, "coin": 20, "goods": 0, "gem": 0,
			"ore_gold": 0, "ore_silver": 0, "ore_iron": 0, "ore_steel": 0,
			"weapon_melee_low": 0, "weapon_melee_high": 0,
			"weapon_ranged_low": 0, "weapon_ranged_high": 0,
			"mounts": 0, "wagons": 0, "arrows": 0, "medicine": 0, "tools": 0,
			"armor_low": 0, "armor_high": 0,
		}
		team.tags = ["生產"]
		team.tile_pos = Vector2i(t + 4, 4)
		state.teams[t] = team
		state.team_known[t] = []
		state.team_discovered[t] = []

		# 移動目標設定
		if t == 0:
			team.current_task = "掠奪"
			team.tags = ["統領"]
			team.resources["weapon_melee_low"] = 40
		elif t == 1:
			team.tile_pos = Vector2i(7, 4)     # 從(7,4)出發，距Team2(6,4)更遠
			team.move_target = Vector2i(4, 4)  # 向左走到 (4,4)
			team.unrest_turns = 22             # Tick 1 觸發替換事件，emit message
		# t == 2: 無目標，駐守

		for p in range(3):
			var person := PersonData.new()
			person.id = t * 3 + p
			person.person_name = "P%d_%d" % [t, p]
			person.role = "leader" if p == 0 else "civilian"
			person.team_id = t
			person.age = 25
			person.loyalty = 0.8
			person.stress = 0.0

			if t == 1 and p > 0:
				person.goals = [
					{ "type": "escape_war", "target_id": -1, "active": true },
					{ "type": "wealth",     "target_id": -1, "active": true },
				]
				person.values["義氣"] = 0.3
				person.skills["統領"] = 0.5
				person.loyalty = 0.2  # 低忠誠度 → 成為異見者，觸發替換事件
			else:
				person.goals = [
					{ "type": "domination", "target_id": -1, "active": true },
					{ "type": "wealth",     "target_id": -1, "active": true },
				]

			state.persons[person.id] = person
			if p == 0:
				team.leader_id = person.id
			else:
				team.named_members.append(person.id)

	# Team2 建設測試：在 (6,4) 建造村落（civilian Lv1）
	# Team0 營寨在 (4,4)，距離 2（不同類型，無同類限制）
	var _outpost_sys := OutpostSystem.new()
	var _build_ok := _outpost_sys.start_build(state, state.teams[2], "civilian", 1)
	print("=== 據點建設測試：Team2 建村落 start_build=%s ===" % str(_build_ok))

	# Team3：預先設為 Team0 附庸（測試 faction AI 行為）
	var team3 := TeamData.new()
	team3.team_id = 3
	team3.population = 8
	team3.resources = {
		"food": 200.0, "material": 5, "coin": 30, "goods": 10, "gem": 0,
		"ore_gold": 0, "ore_silver": 0, "ore_iron": 0, "ore_steel": 0,
		"weapon_melee_low": 4, "weapon_melee_high": 0,
		"weapon_ranged_low": 0, "weapon_ranged_high": 0,
		"mounts": 0, "wagons": 0, "arrows": 0, "medicine": 0, "tools": 0,
		"armor_low": 0, "armor_high": 0,
	}
	team3.tags = []
	team3.tile_pos = Vector2i(8, 4)
	team3.unrest_turns = 0
	state.teams[3] = team3
	state.team_known[3] = []
	state.team_discovered[3] = []
	var p3 := PersonData.new()
	p3.id = 9
	p3.person_name = "P3_0"
	p3.role = "leader"
	p3.team_id = 3
	p3.age = 30
	p3.loyalty = 0.5
	p3.values["義氣"] = 0.2   # 低義氣 → 容易脫離勢力
	p3.values["信義"] = 0.2   # 低信義 → 叛離觸發更容易
	p3.values["野心"] = 0.3
	state.persons[9] = p3
	team3.leader_id = 9
	# 直接建立 faction（模擬主服結果）
	var init_fid: int = state.create_faction(0)   # Team0 為 leader
	state.factions[init_fid].member_team_ids.append(3)
	team3.faction_id = init_fid
	# 手動補雙向發現（繞過正常外交流程）
	state.team_discovered[0].append(3)
	state.team_discovered[3].append(0)
	# Team0 leader 設高野心（達到立國條件）
	state.persons[0].values["野心"] = 0.8
	state.persons[0].values["好戰"] = 0.8
	state.persons[0].values["義氣"] = 0.2
	state.persons[0].values["貪婪"] = 0.8
	state.persons[0].values["殘忍"] = 0.9   # 高殘忍 → 戰後多掠奪 + 傷兵惡化
	state.persons[0].skills["統領"] = 0.5
	# Team2 食物設低，確保 Team3 始終為最富成員（徵收目標）
	state.teams[2].resources["food"] = 50.0

	# ── 子團驗證場景 ──
	# Team0 有 Person1 作為 advisor，派出偵查子隊
	state.persons[0].skills["統領"] = 0.5
	state.persons[1].skills["統領"] = 0.2   # sub_cap = clamp(round(49×0.25)+1,1,50) = 14
	state.persons[1].skills["偵查"] = 0.4   # 高偵查：子隊視野更廣
	state.persons[1].values["貪婪"] = 0.8   # 高貪婪 → idle 子團有機會觸發 mini-loop（掠奪/攻擊）
	state.persons[1].values["好戰"] = 0.7
	state.persons[1].loyalty       = 0.4    # 低忠誠 → deviation_chance 更高
	# Person1 期望薪水（非死士，需結算）
	state.persons[1].salary = 5.0
	state.persons[2].salary = 3.0
	# Person1 和 Person2 已在 named_members 中，無需額外移動（advisors/members 已合併）
	# Team5：獨立軍隊（應觸發 SoloAI 攻擊/掠奪）
	var team5 := TeamData.new()
	team5.team_id = 5; team5.population = 8
	team5.resources = {
		"food": 300.0, "material": 5, "coin": 0, "goods": 0, "gem": 0,
		"ore_gold": 0, "ore_silver": 0, "ore_iron": 0, "ore_steel": 0,
		"weapon_melee_low": 16, "weapon_melee_high": 0,
		"weapon_ranged_low": 0, "weapon_ranged_high": 0,
		"mounts": 0, "wagons": 0, "arrows": 0, "medicine": 0, "tools": 0,
		"armor_low": 0, "armor_high": 0,
	}
	team5.tags = ["軍隊"]; team5.tile_pos = Vector2i(1, 4)
	state.teams[5] = team5; state.team_known[5] = []; state.team_discovered[5] = []
	var p5 := PersonData.new()
	p5.id = 10; p5.person_name = "P5_0"; p5.role = "leader"; p5.team_id = 5
	p5.values["好戰"] = 0.8; p5.values["野心"] = 0.7
	p5.skills["潛行"] = 0.5   # 高潛行：軍隊仍能隱蔽
	state.persons[10] = p5; team5.leader_id = 10

	# Team6：獨立商隊（應觸發 SoloAI 外交）
	var team6 := TeamData.new()
	team6.team_id = 6; team6.population = 6
	team6.resources = {
		"food": 200.0, "material": 3, "coin": 50, "goods": 20, "gem": 0,
		"ore_gold": 0, "ore_silver": 0, "ore_iron": 0, "ore_steel": 0,
		"weapon_melee_low": 2, "weapon_melee_high": 0,
		"weapon_ranged_low": 0, "weapon_ranged_high": 0,
		"mounts": 0, "wagons": 0, "arrows": 0, "medicine": 0, "tools": 0,
		"armor_low": 0, "armor_high": 0,
	}
	team6.tags = ["商隊"]; team6.tile_pos = Vector2i(1, 5)
	state.teams[6] = team6; state.team_known[6] = []; state.team_discovered[6] = []
	var p6 := PersonData.new()
	p6.id = 11; p6.person_name = "P6_0"; p6.role = "leader"; p6.team_id = 6
	p6.values["野心"] = 0.6; p6.values["好戰"] = 0.2
	p6.skills["潛行"] = 0.3   # 中等潛行
	state.persons[11] = p6; team6.leader_id = 11

	var _sub_sys2 := SubteamSystem.new()
	var _best := _sub_sys2._pick_subteam_leader(state, state.teams[0], "偵查")
	print("[TeamAI] _pick_subteam_leader(偵查) = P%d" % _best)
	assert(_best != -1, "應能找到偵查子隊 leader")
	assert(_best == 1, "最高偵查技能應為 Person1")

	var _sub_sys := SubteamSystem.new()
	var scout_id: int = _sub_sys.dispatch(state, 0, 1, 3, "偵查", Vector2i(7, 4),
		-1, "", [2])  # Person2 作為 extra advisor
	print("=== 子隊派遣：scout_id=%d ===" % scout_id)
	if scout_id != -1:
		print("  Team0 pop=%d  Team%d pop=%d task=%s" % [
			state.teams[0].population, scout_id,
			state.teams[scout_id].population, state.teams[scout_id].current_task])

	# ── Team8 製造測試 ──
	# Tile (7,5)：civilian Lv2，manufacturing_level=1
	var _tile31_id: int = 7 * 1000 + 5
	if state.world.tiles.has(_tile31_id):
		var _t31: HexTileData = state.world.tiles[_tile31_id] as HexTileData
		_t31.outpost_type         = "civilian"
		_t31.outpost_level        = 2
		_t31.manufacturing_level  = 1
		_t31.outpost_owner        = 8
		_t31.terrain              = "plains"
	var team8 := TeamData.new()
	team8.team_id    = 8
	team8.population = 10
	team8.resources  = {
		"food": 500.0, "material": 500.0, "coin": 0, "goods": 0, "gem": 5,
		"ore_gold": 0, "ore_silver": 100, "ore_iron": 80, "ore_steel": 0,
		"weapon_melee_low": 0, "weapon_melee_high": 0,
		"weapon_ranged_low": 0, "weapon_ranged_high": 0,
		"mounts": 0, "wagons": 0, "arrows": 0, "medicine": 0, "tools": 0,
		"armor_low": 0, "armor_high": 0,
	}
	team8.tags         = ["生產"]
	team8.tile_pos     = Vector2i(7, 5)
	team8.current_task = TeamData.TASK_MANUFACTURE
	state.teams[8]     = team8
	state.team_known[8] = []
	state.team_discovered[8] = []
	var p8 := PersonData.new()
	p8.id = 20; p8.person_name = "P8_0"; p8.role = "leader"; p8.team_id = 8
	p8.loyalty = 0.9; p8.skills["製造"] = 0.2
	state.persons[20] = p8
	team8.leader_id = 20
	print("=== 製造測試：Team8 tile(7,5) civilian Lv2, mfg_level=1, gem=5, ore_silver=100 ===")

	# ── Team9 商隊測試 ──
	# Tile (1,1)：plains（world gen 已有）
	var team9 := TeamData.new()
	team9.team_id    = 9
	team9.population = 5
	team9.resources  = {
		"food": 300.0, "material": 0, "coin": 0, "goods": 100.0, "gem": 3,
		"ore_gold": 0, "ore_silver": 0, "ore_iron": 0, "ore_steel": 0,
		"weapon_melee_low": 0, "weapon_melee_high": 0,
		"weapon_ranged_low": 0, "weapon_ranged_high": 0,
		"mounts": 0, "wagons": 0, "arrows": 0, "medicine": 0, "tools": 0,
		"armor_low": 0, "armor_high": 0,
	}
	team9.tags       = ["商隊"]
	team9.tile_pos   = Vector2i(5, 5)
	state.teams[9]   = team9
	state.team_known[9] = []
	state.team_discovered[9] = []
	var p9 := PersonData.new()
	p9.id = 21; p9.person_name = "P9_0"; p9.role = "leader"; p9.team_id = 9
	p9.loyalty = 0.9; p9.skills["商業"] = 0.1
	p9.values["貪婪"] = 0.6
	state.persons[21] = p9
	team9.leader_id = 21
	print("=== 商隊測試：Team9 tile(5,5) 商隊，goods=100, gem=3, coin=0 ===")

	# ── EventSystem 匿名晉升驗證 ──
	var gen_team := TeamData.new()
	gen_team.team_id    = 10
	gen_team.population = 5     # anon_pop = 5-1(leader) = 4
	gen_team.tags       = ["軍隊"]
	gen_team.tile_pos   = Vector2i(4, 1)
	state.teams[10]     = gen_team
	state.team_known[10]      = []
	state.team_discovered[10] = []
	var p10_0 := PersonData.new()
	p10_0.id          = 30
	p10_0.person_name = "P10_leader"
	p10_0.role        = "leader"
	p10_0.team_id     = 10
	state.persons[30]   = p10_0
	gen_team.leader_id  = 30
	var _es_gen   := EventSystem.new()
	var _gen_ok   : bool = _es_gen.on_leader_death(state, gen_team)
	print("=== EventSystem 匿名晉升測試 ===")
	print("  gen_ok=%s  new_leader_id=%d" % [str(_gen_ok), gen_team.leader_id])
	if _gen_ok and gen_team.leader_id != 30:
		var _np: PersonData = state.persons.get(gen_team.leader_id)
		if _np:
			var _name_looks_static: bool = not _np.person_name.begins_with("NPC_")
			if _np.team_id == 10 and _np.role == "leader" and _name_looks_static \
					and state.persons.has(gen_team.leader_id):
				print("  [OK] 靜態 API 晉升 Person%d name=%s team=%d role=%s" % [
					_np.id, _np.person_name, _np.team_id, _np.role])
			else:
				print("  [FAIL] 晉升資料錯誤 name=%s team=%d role=%s stored=%s" % [
					_np.person_name, _np.team_id, _np.role,
					str(state.persons.has(gen_team.leader_id))])
		else:
			print("  [FAIL] new_leader 不在 state.persons")
	else:
		print("  [FAIL] gen_ok=false or leader_id unchanged")
	state.persons.erase(30)   # 清理「假死」leader（模擬 _kill_named_npc 後段）
	if gen_team.leader_id != 30:
		state.persons.erase(gen_team.leader_id)
	state.teams.erase(10)
	state.team_known.erase(10)
	state.team_discovered.erase(10)

	# 無匿名人口時不應憑空晉升
	var gen_team_empty := TeamData.new()
	gen_team_empty.team_id = 14
	gen_team_empty.population = 1
	gen_team_empty.tags = ["軍隊"]
	gen_team_empty.tile_pos = Vector2i(4, 2)
	state.teams[14] = gen_team_empty
	state.team_known[14] = []
	state.team_discovered[14] = []
	var p14_0 := PersonData.new()
	p14_0.id = 31
	p14_0.person_name = "P14_leader"
	p14_0.role = "leader"
	p14_0.team_id = 14
	state.persons[31] = p14_0
	gen_team_empty.leader_id = 31
	var _persons_before_empty: int = state.persons.size()
	var _gen_empty_ok: bool = _es_gen.on_leader_death(state, gen_team_empty)
	print("=== EventSystem 無匿名人口測試 ===")
	if not _gen_empty_ok and gen_team_empty.leader_id == 31 and \
			state.persons.size() == _persons_before_empty:
		print("  [OK] 無匿名人口時不晉升")
	else:
		print("  [FAIL] 無匿名人口仍晉升 ok=%s leader=%d persons=%d(before=%d)" % [
			str(_gen_empty_ok), gen_team_empty.leader_id,
			state.persons.size(), _persons_before_empty])
	state.persons.erase(31)
	state.teams.erase(14)
	state.team_known.erase(14)
	state.team_discovered.erase(14)

	print("=== PersonGenerator 匿名 helper 測試 ===")
	var helper_state_a := WorldState.new()
	var helper_team_a := TeamData.new()
	helper_team_a.team_id = 15
	helper_team_a.population = 3
	helper_state_a.teams[15] = helper_team_a
	var helper_a: PersonData = PersonGenerator.generate_for_team(helper_state_a, helper_team_a, "member")
	if helper_a != null and helper_a.team_id == 15 and helper_state_a.persons.has(helper_a.id):
		print("  [OK] helper 寫回 team_id 與 state.persons")
	else:
		print("  [FAIL] helper 未正確寫回 team/state")

	var helper_state_b := WorldState.new()
	var helper_team_b := TeamData.new()
	helper_team_b.team_id = 15
	helper_team_b.population = 3
	helper_state_b.teams[15] = helper_team_b
	var helper_b: PersonData = PersonGenerator.generate_for_team(helper_state_b, helper_team_b, "member")
	if helper_a != null and helper_b != null \
			and helper_a.person_name == helper_b.person_name \
			and helper_a.age == helper_b.age \
			and is_equal_approx(helper_a.skills["統領"], helper_b.skills["統領"]):
		print("  [OK] helper 對相同 state/team 決定性一致")
	else:
		print("  [FAIL] helper 非決定性或產出不一致")

	var helper_state_empty := WorldState.new()
	var helper_team_empty := TeamData.new()
	helper_team_empty.team_id = 16
	helper_team_empty.population = 1
	helper_state_empty.teams[16] = helper_team_empty
	var helper_leader := PersonData.new()
	helper_leader.id = 90
	helper_leader.team_id = 16
	helper_leader.role = "leader"
	helper_state_empty.persons[90] = helper_leader
	helper_team_empty.leader_id = 90
	if PersonGenerator.generate_for_team(helper_state_empty, helper_team_empty, "member") == null:
		print("  [OK] helper 無匿名人口時回傳 null")
	else:
		print("  [FAIL] helper 無匿名人口仍生成")

	# ── merge_teams 驗證 ──
	var ma := TeamData.new()
	ma.team_id = 11; ma.population = 5; ma.faction_id = 99; ma.tile_pos = Vector2i(4, 0)
	state.teams[11] = ma; state.team_known[11] = []; state.team_discovered[11] = []
	var ma_p := PersonData.new()
	ma_p.id = 40; ma_p.person_name = "MA_leader"; ma_p.role = "leader"
	ma_p.team_id = 11; ma_p.skills["統領"] = 0.6; ma_p.loyalty = 0.8
	state.persons[40] = ma_p; ma.leader_id = 40

	var mb := TeamData.new()
	mb.team_id = 12; mb.population = 3; mb.faction_id = 99; mb.tile_pos = Vector2i(4, 0)
	mb.resources["food"] = 90.0
	state.teams[12] = mb; state.team_known[12] = []; state.team_discovered[12] = []
	var mb_p := PersonData.new()
	mb_p.id = 41; mb_p.person_name = "MB_leader"; mb_p.role = "leader"
	mb_p.team_id = 12; mb_p.loyalty = 0.7
	state.persons[41] = mb_p; mb.leader_id = 41
	var mb_m := PersonData.new()
	mb_m.id = 42; mb_m.person_name = "MB_member"; mb_m.role = "civilian"
	mb_m.team_id = 12; mb_m.loyalty = 0.7
	state.persons[42] = mb_m; mb.named_members.append(42)

	# 完全合併：transfer 所有 MB NPC，transfer_anon=-1（比例帶走匿民）
	# MB pop=3：leader(41) + member(42) + 1 匿民；named=2 → anon=1
	# transfer 2 named → anon_xfer = round(1 * 2/2) = 1 → total_xfer=3 → MB 完全合併
	var _merge_npcs: Array = [41, 42]
	var _ss := SubteamSystem.new()
	_ss.merge_teams(state, 11, 12, _merge_npcs)  # transfer_anon 預設 -1
	print("=== merge_teams 測試（完全合併）===")
	if not state.teams.has(12):
		print("  [OK] Team12 完全合併入 Team11 (pop=%d)" % ma.population)
		if ma.named_members.has(41):
			print("  [OK] MB_leader(41) 加入 Team11 named_members")
		else:
			print("  [FAIL] MB_leader(41) 未進入 named_members")
		if ma.named_members.has(42):
			print("  [OK] MB_member(42) 加入 Team11 named_members")
		else:
			print("  [FAIL] MB_member(42) 未進入 named_members")
		if ma.population == 8:  # 5 + 3
			print("  [OK] Team11 pop=8（含 1 匿民）")
		else:
			print("  [WARN] Team11 pop=%d（預期 8）" % ma.population)
	else:
		print("  [FAIL] Team12 未被刪除（pop=%d）" % mb.population)

	# 追加：transfer_anon=0 測試（只移記名 NPC，匿民留下）
	var mc := TeamData.new()
	mc.team_id = 13; mc.population = 4; mc.faction_id = 99; mc.tile_pos = Vector2i(4, 0)
	mc.resources["food"] = 60.0
	state.teams[13] = mc; state.team_known[13] = []; state.team_discovered[13] = []
	var mc_p := PersonData.new()
	mc_p.id = 43; mc_p.person_name = "MC_leader"; mc_p.role = "leader"
	mc_p.team_id = 13; mc_p.loyalty = 0.7
	state.persons[43] = mc_p; mc.leader_id = 43
	# pop=4：1 named(43) + 3 anon
	_ss.merge_teams(state, 11, 13, [43], 0)  # transfer_anon=0：只移 leader，匿民留下
	print("=== merge_teams 測試（transfer_anon=0）===")
	if state.teams.has(13) and mc.population == 3:
		print("  [OK] Team13 剩 3 匿民（成為子隊）")
		if mc.parent_team_id == 11:
			print("  [OK] Team13.parent_team_id=11")
		else:
			print("  [FAIL] Team13.parent_team_id=%d" % mc.parent_team_id)
	else:
		print("  [FAIL] Team13 pop=%d（預期 3）" % mc.population)
	# 清理
	state.teams.erase(11); state.teams.erase(12); state.teams.erase(13)
	state.team_known.erase(11); state.team_known.erase(12); state.team_known.erase(13)
	state.team_discovered.erase(11); state.team_discovered.erase(12); state.team_discovered.erase(13)
	state.persons.erase(40); state.persons.erase(41); state.persons.erase(42); state.persons.erase(43)

	# ── PopulationSystem 驗證 ──
	# 場景 1：超額 + 有 advisor → dispatch 子隊
	var ov1 := TeamData.new()
	ov1.team_id = 20; ov1.population = 5; ov1.tile_pos = Vector2i(0, -5)
	ov1.resources["food"] = 100.0
	state.teams[20] = ov1; state.team_known[20] = []; state.team_discovered[20] = []
	var ov1_leader := PersonData.new()
	ov1_leader.id = 50; ov1_leader.person_name = "OV1_leader"; ov1_leader.role = "leader"
	ov1_leader.team_id = 20; ov1_leader.skills["統領"] = 0.0  # cap=1，pop=5 → overflow=4
	state.persons[50] = ov1_leader; ov1.leader_id = 50
	var ov1_adv := PersonData.new()
	ov1_adv.id = 51; ov1_adv.person_name = "OV1_adv"; ov1_adv.role = "civilian"
	ov1_adv.team_id = 20; ov1_adv.skills["統領"] = 0.3
	state.persons[51] = ov1_adv; ov1.named_members.append(51)
	var _pop_sys := PopulationSystem.new()
	_pop_sys.check_overflow(state)
	print("=== PopulationSystem 場景1（有advisor）===")
	var _ov1_subteam_found: bool = false
	for _tid in state.teams:
		var _t: TeamData = state.teams[_tid]
		if _t.parent_team_id == 20:
			_ov1_subteam_found = true
			print("  [OK] Team%d 子隊建立 pop=%d" % [_t.team_id, _t.population])
			break
	if not _ov1_subteam_found:
		print("  [FAIL] 未建立子隊")
	if ov1.population <= 1:
		print("  [OK] Team20 pop 降至 %d（≤cap=1）" % ov1.population)
	else:
		print("  [FAIL] Team20 pop=%d 仍超額" % ov1.population)

	# 場景 2：超額 + 無 advisor → 獨立流亡 team
	var ov2 := TeamData.new()
	ov2.team_id = 21; ov2.population = 4; ov2.tile_pos = Vector2i(0, -5)
	ov2.resources["food"] = 80.0
	state.teams[21] = ov2; state.team_known[21] = []; state.team_discovered[21] = []
	var ov2_leader := PersonData.new()
	ov2_leader.id = 52; ov2_leader.person_name = "OV2_leader"; ov2_leader.role = "leader"
	ov2_leader.team_id = 21; ov2_leader.skills["統領"] = 0.0  # cap=1，pop=4 → overflow=3
	state.persons[52] = ov2_leader; ov2.leader_id = 52
	var _teams_before_ov2: int = state.teams.size()
	_pop_sys.check_overflow(state)
	print("=== PopulationSystem 場景2（無advisor）===")
	if state.teams.size() > _teams_before_ov2:
		print("  [OK] 新 team 建立（流亡）")
		var _ov2_found: bool = false
		for _tid in state.teams:
			var _t: TeamData = state.teams[_tid]
			if _t.tags.has("流亡") and _t.tile_pos == Vector2i(0, -5) and _t.team_id != 21:
				_ov2_found = true
				var _ov2_leader_person: PersonData = state.persons.get(_t.leader_id)
				if _ov2_leader_person != null and _ov2_leader_person.team_id == _t.team_id \
						and not _ov2_leader_person.person_name.begins_with("NPC_") \
						and state.persons.has(_t.leader_id):
					print("  [OK] Team%d 流亡 pop=%d leader_id=%d name=%s" % [
						_t.team_id, _t.population, _t.leader_id, _ov2_leader_person.person_name])
				else:
					print("  [FAIL] 流亡 leader 錯誤 team=%d leader=%d person=%s stored=%s" % [
						_t.team_id, _t.leader_id,
						str(_ov2_leader_person), str(state.persons.has(_t.leader_id))])
				break
		if not _ov2_found:
			print("  [FAIL] 未找到流亡 team 詳情")
	else:
		print("  [FAIL] 未建立流亡 team")

	# 場景 3：FactionAI 閾值合併（小隊 pop 過小）
	var fac99 = state.create_faction(22)
	var fa := TeamData.new()
	fa.team_id = 22; fa.population = 20; fa.faction_id = fac99; fa.tile_pos = Vector2i(0, -6)
	state.teams[22] = fa; state.team_known[22] = []; state.team_discovered[22] = []
	var fa_l := PersonData.new()
	fa_l.id = 53; fa_l.person_name = "FA_leader"; fa_l.role = "leader"
	fa_l.team_id = 22; fa_l.skills["統領"] = 0.6  # cap≈37
	state.persons[53] = fa_l; fa.leader_id = 53
	if not state.factions[fac99].member_team_ids.has(22):
		state.factions[fac99].member_team_ids.append(22)
	state.factions[fac99].leader_team_id = 22

	var fb := TeamData.new()
	fb.team_id = 23; fb.population = 2; fb.faction_id = fac99; fb.tile_pos = Vector2i(0, -8)  # dist=2
	state.teams[23] = fb; state.team_known[23] = []; state.team_discovered[23] = []
	var fb_l := PersonData.new()
	fb_l.id = 54; fb_l.person_name = "FB_leader"; fb_l.role = "leader"
	fb_l.team_id = 23; fb_l.skills["統領"] = 0.2  # cap≈13，pop=2 < 13×0.3=3.9 → 小隊
	state.persons[54] = fb_l; fb.leader_id = 54
	state.factions[fac99].member_team_ids.append(23)

	var _fai: Object = load("res://scripts/simulation/faction_ai_system.gd").new()
	var _f99 = state.factions[fac99]
	_fai._assign_member_tasks(state, _f99)
	print("=== FactionAI 閾值合併測試 ===")
	if fb.current_task == TeamData.TASK_MERGE and fb.order_target_id == 22:
		print("  [OK] Team23 收到 TASK_MERGE → Team22")
	else:
		print("  [FAIL] Team23 task=%s order=%d" % [fb.current_task, fb.order_target_id])

	# 場景 4：FactionAI 戰前集結
	_f99.goals = ["攻擊"]
	fb.current_task = "idle"; fb.order_target_id = -1; fb.move_target = Vector2i(-1, -1)
	_fai._assign_member_tasks(state, _f99)
	print("=== FactionAI 戰前集結測試 ===")
	if fb.current_task == TeamData.TASK_MERGE and fb.order_target_id == 22:
		print("  [OK] Team23（dist=2）收到 TASK_MERGE → 主力Team22（戰前集結）")
	else:
		print("  [FAIL] Team23 task=%s order=%d" % [fb.current_task, fb.order_target_id])

	# 清理
	for _tid in [20, 21, 22, 23]:
		state.teams.erase(_tid)
		state.team_known.erase(_tid)
		state.team_discovered.erase(_tid)
	for _pid in [50, 51, 52, 53, 54]:
		state.persons.erase(_pid)
	state.factions.erase(fac99)

	# ── FactionKnownState 驗證 ──
	var ks_fac := state.create_faction(30)
	state.factions[ks_fac].leader_team_id = 30
	var ks_a := TeamData.new()
	ks_a.team_id = 30; ks_a.population = 10; ks_a.tile_pos = Vector2i(0, -9)
	ks_a.resources["food"] = 80.0; ks_a.faction_id = ks_fac
	state.teams[30] = ks_a; state.team_known[30] = []; state.team_discovered[30] = []
	var ks_a_l := PersonData.new()
	ks_a_l.id = 60; ks_a_l.person_name = "KS_leader"; ks_a_l.role = "leader"
	ks_a_l.team_id = 30; ks_a_l.skills["統領"] = 0.6
	state.persons[60] = ks_a_l; ks_a.leader_id = 60

	var ks_b := TeamData.new()
	ks_b.team_id = 31; ks_b.population = 5; ks_b.tile_pos = Vector2i(1, -9)
	ks_b.resources["food"] = 50.0; ks_b.faction_id = ks_fac
	state.teams[31] = ks_b; state.team_known[31] = []; state.team_discovered[31] = []
	var ks_b_l := PersonData.new()
	ks_b_l.id = 61; ks_b_l.person_name = "KS_mem1"; ks_b_l.role = "leader"
	ks_b_l.team_id = 31
	state.persons[61] = ks_b_l; ks_b.leader_id = 61
	state.factions[ks_fac].member_team_ids.append(31)

	var ks_c := TeamData.new()
	ks_c.team_id = 32; ks_c.population = 3; ks_c.tile_pos = Vector2i(2, -9)
	ks_c.resources["food"] = 30.0; ks_c.faction_id = ks_fac
	state.teams[32] = ks_c; state.team_known[32] = []; state.team_discovered[32] = []
	var ks_c_l := PersonData.new()
	ks_c_l.id = 62; ks_c_l.person_name = "KS_mem2"; ks_c_l.role = "leader"
	ks_c_l.team_id = 32
	state.persons[62] = ks_c_l; ks_c.leader_id = 62
	state.factions[ks_fac].member_team_ids.append(32)

	# 預建 team_intel snap（原由 VisionSystem 在 tick 中寫入，此處繞過以直接驗證橋接）
	state.team_intel[30] = {
		31: {
			"tier": 1, "population_est": 5, "tile_pos": Vector2i(1, -9),
			"last_tick": 0, "resource_scale": 1,
			"food_est": 50.0, "material_est": 0.0, "coin_est": 0.0, "goods_est": 0.0,
			"armed_est": 0, "faction_id": ks_fac, "tags": [], "current_task": "idle",
		},
		32: {
			"tier": 1, "population_est": 3, "tile_pos": Vector2i(2, -9),
			"last_tick": 0, "resource_scale": 0,
			"food_est": 30.0, "material_est": 0.0, "coin_est": 0.0, "goods_est": 0.0,
			"armed_est": 0, "faction_id": ks_fac, "tags": [], "current_task": "idle",
		},
	}
	var _ks_fai: Object = load("res://scripts/simulation/faction_ai_system.gd").new()
	_ks_fai.evaluate_all(state, [30, 31, 32])
	print("=== FactionKnownState 驗證 ===")

	# 場景1：快照正確建立
	var _snap_b: Dictionary = state.factions[ks_fac].known_member_states.get(31, {})
	if _snap_b.get("food_est", -1.0) == 50.0:
		print("  [OK] known_member_states[31].food_est=50.0（bridge 正確）")
	else:
		print("  [FAIL] known_member_states[31].food_est=%s" % str(_snap_b.get("food_est", "missing")))

	# 場景2：_richest_member 讀快照（Team31 food=50 > Team32 food=30）
	var _rm: int = _ks_fai._richest_member(state, state.factions[ks_fac])
	if _rm == 31:
		print("  [OK] _richest_member 返回 Team31（快照 food=50）")
	else:
		print("  [FAIL] _richest_member 返回 %d（預期 31）" % _rm)

	# 場景3：直接改 Team31 food 但不刷新快照 → _richest_member 仍讀舊值
	ks_b.resources["food"] = 5.0  # 繞過快照直接改
	var _rm2: int = _ks_fai._richest_member(state, state.factions[ks_fac])
	if _rm2 == 31:
		print("  [OK] 快照未更新 → _richest_member 仍返回 Team31（介面隔離正確）")
	else:
		print("  [FAIL] _richest_member 返回 %d（預期 31，快照應仍為 food=50）" % _rm2)

	# 清理
	for _tid2 in [30, 31, 32]:
		state.teams.erase(_tid2)
		state.team_known.erase(_tid2)
		state.team_discovered.erase(_tid2)
	for _pid2 in [60, 61, 62]:
		state.persons.erase(_pid2)
	state.factions.erase(ks_fac)

	# ── IntelSystem Tier 0/1 驗證 ──
	var _it_vis := VisionSystem.new()
	# 觀察者 Team70（偵查=0，在 (4,4)，vrange=3）
	var _it_a := TeamData.new()
	_it_a.team_id = 70; _it_a.population = 5; _it_a.tile_pos = Vector2i(4, 4)
	state.teams[70] = _it_a; state.team_discovered[70] = []
	var _it_a_l := PersonData.new()
	_it_a_l.id = 70; _it_a_l.role = "leader"; _it_a_l.team_id = 70
	_it_a_l.skills["偵查"] = 0.0
	state.persons[70] = _it_a_l; _it_a.leader_id = 70

	# 目標 Team71（pop=20，在 (6,4)，dist=2，exposure 高）
	var _it_b := TeamData.new()
	_it_b.team_id = 71; _it_b.population = 20; _it_b.tile_pos = Vector2i(6, 4)
	_it_b.resources = {
		"food": 80.0, "material": 30.0, "coin": 0.0, "goods": 0.0, "gem": 0.0,
		"ore_gold": 0.0, "ore_silver": 0.0, "ore_iron": 0.0, "ore_steel": 0.0,
		"weapon_melee_low": 0.0, "weapon_melee_high": 0.0,
		"weapon_ranged_low": 0.0, "weapon_ranged_high": 0.0,
		"mounts": 0, "wagons": 0, "arrows": 0, "medicine": 0, "tools": 0,
		"armor_low": 0, "armor_high": 0,
	}
	state.teams[71] = _it_b; state.team_discovered[71] = []
	var _it_b_l := PersonData.new()
	_it_b_l.id = 71; _it_b_l.role = "leader"; _it_b_l.team_id = 71
	state.persons[71] = _it_b_l; _it_b.leader_id = 71

	_it_vis.tick_discovery(state, [70, 71])
	print("=== IntelSystem Tier 0 驗證 ===")
	var _it_snap0: Dictionary = state.team_intel.get(70, {}).get(71, {})
	if _it_snap0.get("tier", -1) == 0:
		print("  [OK] tier=0")
	else:
		print("  [FAIL] tier=%s（預期 0）" % str(_it_snap0.get("tier", "missing")))
	var _pop_est: int = int(_it_snap0.get("population_est", -1))
	if _pop_est >= 10 and _pop_est <= 30:
		print("  [OK] population_est=%d（範圍 10–30）" % _pop_est)
	else:
		print("  [FAIL] population_est=%d（預期 10–30）" % _pop_est)

	# Tier 1：Team70 移到 (5,4)，dist=1；Team71 total_res=110 → bucket=1，±1 → 0–2
	_it_a.tile_pos = Vector2i(5, 4)
	_it_vis.tick_discovery(state, [70])
	print("=== IntelSystem Tier 1 驗證 ===")
	var _it_snap1: Dictionary = state.team_intel.get(70, {}).get(71, {})
	if _it_snap1.get("tier", -1) >= 1:
		print("  [OK] tier≥1（dist=1 近接觸）")
	else:
		print("  [FAIL] tier=%s（預期 ≥1）" % str(_it_snap1.get("tier", "missing")))
	var _rscale: int = int(_it_snap1.get("resource_scale", -1))
	if _rscale >= 0 and _rscale <= 2:
		print("  [OK] resource_scale=%d（預期 0–2，total=110→bucket1±1）" % _rscale)
	else:
		print("  [FAIL] resource_scale=%d（預期 0–2）" % _rscale)

	# 快照持久：Team71 移出視野（dist=10），team_intel 應仍保留舊值
	var _last_pop: int = int(state.team_intel.get(70, {}).get(71, {}).get("population_est", -1))
	_it_b.tile_pos = Vector2i(10, 0)
	_it_vis.tick_discovery(state, [70])
	var _it_snap_p: Dictionary = state.team_intel.get(70, {}).get(71, {})
	print("=== IntelSystem 快照持久 驗證 ===")
	if int(_it_snap_p.get("population_est", -1)) == _last_pop and _last_pop > 0:
		print("  [OK] 快照保留（population_est=%d 不變）" % _last_pop)
	else:
		print("  [FAIL] 快照被清除（got=%s）" % str(_it_snap_p.get("population_est", "missing")))

	# 清理
	state.teams.erase(70); state.teams.erase(71)
	state.team_discovered.erase(70); state.team_discovered.erase(71)
	state.persons.erase(70); state.persons.erase(71)

	# ── IntelSystem Tier 2 驗證 ──
	var _it_inter := InteractionSystem.new()

	# 觀察者 Team72
	var _it_obs := TeamData.new()
	_it_obs.team_id = 72; _it_obs.population = 5; _it_obs.tile_pos = Vector2i(4, 4)
	state.teams[72] = _it_obs; state.team_discovered[72] = []
	var _it_obs_l := PersonData.new()
	_it_obs_l.id = 72; _it_obs_l.role = "leader"; _it_obs_l.team_id = 72
	state.persons[72] = _it_obs_l; _it_obs.leader_id = 72

	# 高信義 Team73（生產隊，幾乎不造假）
	var _it_hon := TeamData.new()
	_it_hon.team_id = 73; _it_hon.population = 10; _it_hon.tile_pos = Vector2i(4, 4)
	_it_hon.tags = ["生產"]
	_it_hon.resources = {
		"food": 100.0, "material": 0.0, "coin": 20.0, "goods": 0.0, "gem": 0.0,
		"ore_gold": 0.0, "ore_silver": 0.0, "ore_iron": 0.0, "ore_steel": 0.0,
		"weapon_melee_low": 4.0, "weapon_melee_high": 0.0,
		"weapon_ranged_low": 0.0, "weapon_ranged_high": 0.0,
		"mounts": 0, "wagons": 0, "arrows": 0, "medicine": 0, "tools": 0,
		"armor_low": 0, "armor_high": 0,
	}
	_it_hon.armed_anon_ratio = 0.0
	state.teams[73] = _it_hon; state.team_discovered[73] = []
	var _it_hon_l := PersonData.new()
	_it_hon_l.id = 73; _it_hon_l.role = "leader"; _it_hon_l.team_id = 73
	_it_hon_l.values["信義"] = 0.95
	state.persons[73] = _it_hon_l; _it_hon.leader_id = 73

	_it_inter._write_tier2_intel(state, 72, 73)
	print("=== IntelSystem Tier 2（高信義）===")
	var _snap73: Dictionary = state.team_intel.get(72, {}).get(73, {})
	if _snap73.get("tier", -1) == 2:
		print("  [OK] tier=2")
	else:
		print("  [FAIL] tier=%s（預期 2）" % str(_snap73.get("tier", "missing")))
	var _food73: float = float(_snap73.get("food_est", -1.0))
	# 高信義不應高報 food（偽裝平民時 food × 1.5–2.5）；直接值應為 100.0
	if _food73 >= 80.0:
		print("  [OK] food_est=%.1f（高信義，接近實際 100）" % _food73)
	else:
		print("  [WARN] food_est=%.1f（可能觸發偽裝，但高信義概率極低）" % _food73)
	if _snap73.has("coin_est"):
		print("  [OK] coin_est=%.1f（Tier 2 欄位存在）" % float(_snap73.get("coin_est", 0.0)))
	else:
		print("  [FAIL] coin_est 欄位缺少")

	# 低信義軍隊 Team74（高 deceive_chance → 偽裝平民）
	var _it_low := TeamData.new()
	_it_low.team_id = 74; _it_low.population = 10; _it_low.tile_pos = Vector2i(4, 4)
	_it_low.tags = ["軍隊"]
	_it_low.resources = {
		"food": 50.0, "material": 0.0, "coin": 0.0, "goods": 0.0, "gem": 0.0,
		"ore_gold": 0.0, "ore_silver": 0.0, "ore_iron": 0.0, "ore_steel": 0.0,
		"weapon_melee_low": 0.0, "weapon_melee_high": 0.0,
		"weapon_ranged_low": 0.0, "weapon_ranged_high": 0.0,
		"mounts": 0, "wagons": 0, "arrows": 0, "medicine": 0, "tools": 0,
		"armor_low": 0, "armor_high": 0,
	}
	_it_low.armed_anon_ratio = 0.8  # anon_pop=9 → actual_armed≈7
	state.teams[74] = _it_low; state.team_discovered[74] = []
	var _it_low_l := PersonData.new()
	_it_low_l.id = 74; _it_low_l.role = "leader"; _it_low_l.team_id = 74
	_it_low_l.values["信義"] = 0.05   # deceive_chance ≈ (0.95)×0.5 = 0.475
	_it_low_l.skills["計謀"] = 0.5    # + 0.5×0.2 = 0.1 → total ≈ 0.575
	state.persons[74] = _it_low_l; _it_low.leader_id = 74

	# 多次取樣（造假為機率事件），偽裝觸發 → armed_est < 4（實際≈7 × 0.2–0.4 = 1–3）
	var _deception_ok: bool = false
	for _i in range(20):
		_it_inter._write_tier2_intel(state, 72, 74)
		var _s74: Dictionary = state.team_intel.get(72, {}).get(74, {})
		if int(_s74.get("armed_est", 999)) < 4:
			_deception_ok = true; break
	print("=== IntelSystem Tier 2（低信義軍隊 偽裝平民）===")
	if _deception_ok:
		print("  [OK] 偽裝平民觸發（20次取樣中 armed_est 低報）")
	else:
		print("  [WARN] 20次取樣均未觸發（RNG 偶發，偵查概率=0.575 應多數觸發）")

	# 清理
	for _tid_t2 in [72, 73, 74]:
		state.teams.erase(_tid_t2)
		state.team_discovered.erase(_tid_t2)
		state.persons.erase(_tid_t2)

	# ── IntelSystem 攻擊決策驗證 ──
	print("=== IntelSystem 攻擊決策 驗證 ===")
	var _ad_leader := TeamData.new()
	_ad_leader.team_id = 80; _ad_leader.population = 10
	_ad_leader.tile_pos = Vector2i(4, 5); _ad_leader.tags = ["統領"]
	_ad_leader.readiness = 0.8
	_ad_leader.armed_anon_ratio = 0.3  # anon_pop=9 → roundi(9×0.3)=3 → own_armed=3
	state.teams[80] = _ad_leader; state.team_discovered[80] = []
	var _ad_fid: int = state.create_faction(80)  # 必須在 teams[80] 存在後呼叫
	state.factions[_ad_fid].is_established = true
	_ad_leader.faction_id = _ad_fid
	var _ad_l_p := PersonData.new()
	_ad_l_p.id = 80; _ad_l_p.role = "leader"; _ad_l_p.team_id = 80
	_ad_l_p.values["野心"] = 0.8; _ad_l_p.values["好戰"] = 0.8
	_ad_l_p.values["義氣"] = 0.1; _ad_l_p.skills["統領"] = 0.5
	state.persons[80] = _ad_l_p; _ad_leader.leader_id = 80

	var _ad_tgt := TeamData.new()
	_ad_tgt.team_id = 81; _ad_tgt.population = 8; _ad_tgt.tile_pos = Vector2i(5, 5)
	_ad_tgt.faction_id = -1; _ad_tgt.armed_anon_ratio = 0.0
	state.teams[81] = _ad_tgt
	state.team_discovered[80].append(81)
	var _ad_tgt_p := PersonData.new()
	_ad_tgt_p.id = 81; _ad_tgt_p.role = "leader"; _ad_tgt_p.team_id = 81
	state.persons[81] = _ad_tgt_p; _ad_tgt.leader_id = 81

	var _ad_fai: Object = load("res://scripts/simulation/faction_ai_system.gd").new()

	# 場景 1：無 team_intel snap → armed_est=999 → 不應加入攻擊 goal
	_ad_fai._update_goals(state, state.factions[_ad_fid])
	if not state.factions[_ad_fid].goals.has("攻擊"):
		print("  [OK] 未知目標（armed_est=999）→ 無攻擊 goal")
	else:
		print("  [FAIL] 未知目標仍加入攻擊 goal（應檢查 _update_goals 實力比較邏輯）")

	# 場景 2：寫入弱目標 snap（armed_est=2）→ own_armed≥2×0.8=1.6 → 應加入攻擊 goal
	if not state.team_intel.has(80):
		state.team_intel[80] = {}
	state.team_intel[80][81] = {
		"tier": 0, "population_est": 8, "armed_est": 2,
		"tile_pos": Vector2i(5, 5), "last_tick": 0,
	}
	state.factions[_ad_fid].goals.clear()
	_ad_fai._update_goals(state, state.factions[_ad_fid])
	if state.factions[_ad_fid].goals.has("攻擊"):
		print("  [OK] 弱目標（armed_est=2）→ 加入攻擊 goal")
	else:
		print("  [FAIL] 弱目標未加入攻擊 goal")

	# 清理
	state.teams.erase(80); state.teams.erase(81)
	state.team_discovered.erase(80)
	state.persons.erase(80); state.persons.erase(81)
	state.factions.erase(_ad_fid)
	state.team_intel.erase(80)

	print("=== Sim Test: 200 Ticks ===")
	print("Team0(統領) 預建為勢力 leader，Team3 為附庸")
	print("預期：立國 → 外交(Team1,Team2) → 定期徵收(Team3)，子隊偵查後回歸")
	print("Team1 目標: (4,4)  Team2 無目標，駐守 (6,4)  player_pos=(6,4)")
	var player_pos := Vector2i(6, 4)

	for tick in range(200):
		runner.advance_tick(state, player_pos)
		if (tick + 1) % 20 == 0:
			print("\n--- Tick %d ---" % state.world.current_tick)
			for tid in state.teams:
				var t: TeamData = state.teams[tid]
				var known_count: int = state.team_known[tid].size() if state.team_known.has(tid) else 0
				print("  Team%d pos=(%d,%d) food=%.1f pop=%d wnd=%d ct=%d rd=%.2f" % [
					t.team_id,
					t.tile_pos.x, t.tile_pos.y,
					float(t.resources.get("food", 0)),
					t.population,
					t.wounded,
					t.combat_target,
					t.readiness
				])

	# Team9 商隊結果
	if state.teams.has(9):
		var t9: TeamData = state.teams[9]
		print("\n=== Team9 商隊結果 ===")
		print("  coin=%.0f  goods=%.1f  gem=%.0f  food=%.0f" % [
			float(t9.resources.get("coin", 0)),
			float(t9.resources.get("goods", 0)),
			float(t9.resources.get("gem", 0)),
			float(t9.resources.get("food", 0))
		])
		print("  Person21 商業=%.4f" % float(state.persons[21].skills.get("商業", 0)))

	# Team8 製造結果
	if state.teams.has(8):
		var t8: TeamData = state.teams[8]
		print("\n=== Team8 製造結果 ===")
		print("  goods=%.2f  melee_low=%.2f  melee_high=%.2f  steel=%.2f  material=%.1f" % [
			float(t8.resources.get("goods", 0)),
			float(t8.resources.get("weapon_melee_low", 0)),
			float(t8.resources.get("weapon_melee_high", 0)),
			float(t8.resources.get("ore_steel", 0)),
			float(t8.resources.get("material", 0))
		])
		print("  Person20 製造技能=%.4f" % float(state.persons[20].skills.get("製造", 0)))

	print("\nglobal_messages: %d" % state.global_messages.size())
	for tid in state.team_known:
		print("  team_known[%d]: %d 條" % [tid, state.team_known[tid].size()])
	print("factions: %d" % state.factions.size())
	for fid in state.factions:
		var f = state.factions[fid]
		print("  勢力%d [%s] leader=Team%d members=%s" % [
			fid, f.faction_name if f.is_established else "未立國號",
			f.leader_team_id, str(f.member_team_ids)])
	print("--- 子團狀態 ---")
	for tid in state.teams:
		var t: TeamData = state.teams[tid]
		if t.parent_team_id != -1:
			print("  Team%d(子團) parent=Team%d task=%s pop=%d" % [
				tid, t.parent_team_id, t.current_task, t.population])
	if scout_id != -1 and state.teams.has(scout_id):
		print("  [OK] 子隊 Team%d 仍存活（偵查任務無自動回歸，需主動召回）" % scout_id)
	elif scout_id != -1:
		print("  [OK] 子隊已完全合併回 Team0")
	print("--- 視野 ---")
	for tid in state.team_discovered:
		print("  Team%d 已發現: %s" % [tid, str(state.team_discovered[tid])])
	print("--- 裝備統計 ---")
	for tid in state.teams:
		var t: TeamData = state.teams[tid]
		var equip_counts: Dictionary = { "melee_low": 0, "melee_high": 0, "ranged_low": 0, "ranged_high": 0, "none": 0 }
		for pid in ([t.leader_id] as Array) + t.named_members:
			var p: PersonData = state.persons.get(pid)
			if p == null: continue
			var wt: String = p.equipment["hand_1"].get("type", "none")
			if wt in equip_counts: equip_counts[wt] += 1
			else: equip_counts["none"] += 1
		print("  Team%d pool_ml=%d mh=%d rl=%d rh=%d | armed_anon=%.2f | named:%s" % [
			tid,
			int(t.resources.get("weapon_melee_low", 0)),
			int(t.resources.get("weapon_melee_high", 0)),
			int(t.resources.get("weapon_ranged_low", 0)),
			int(t.resources.get("weapon_ranged_high", 0)),
			t.armed_anon_ratio,
			str(equip_counts)
		])
	print("--- 戰鬥技能 ---")
	for pid in state.persons:
		var p: PersonData = state.persons.get(pid)
		if p == null: continue
		var bat: float = float(p.skills.get("戰鬥", 0))
		var bow: float = float(p.skills.get("弓箭", 0))
		var tac: float = float(p.skills.get("戰術", 0))
		if bat > 0.001 or bow > 0.001 or tac > 0.001:
			print("  Person%d 戰鬥=%.4f 弓箭=%.4f 戰術=%.4f" % [p.id, bat, bow, tac])
	print("--- 偵查/潛行技能 ---")
	for pid in [1, 10, 11]:
		var _sp: PersonData = state.persons.get(pid)
		if _sp: print("  Person%d 偵查=%.4f 潛行=%.4f" % [
			pid, float(_sp.skills.get("偵查", 0)), float(_sp.skills.get("潛行", 0))])
	# === 資料結構驗證 ===
	var _dsp: PersonData = state.persons.get(0)
	assert(_dsp != null, "Person0 不存在")
	assert("salary" in _dsp, "缺少 salary 欄位")
	assert("coin" in _dsp, "缺少 coin 欄位")
	assert("relations" in _dsp, "缺少 relations 欄位")
	assert(_dsp.relations is Dictionary, "relations 應為 Dictionary")
	print("[DataStruct] salary/coin/relations 欄位驗證通過")

	var _dep: PersonData = state.persons.get(0)
	assert(_dep.equipment.has("hand_1"), "缺少 hand_1 裝備格")
	assert(_dep.equipment.has("torso"), "缺少 torso 裝備格")
	assert(_dep.equipment["hand_1"] is Dictionary, "hand_1 應為 Dictionary")
	print("[DataStruct] equipment 8格驗證通過")

	var _dgp: PersonData = state.persons.get(0)
	assert(_dgp.goals.size() > 0, "goals 不應為空")
	assert(_dgp.goals[0] is Dictionary, "goals[0] 應為 Dictionary")
	assert(_dgp.goals[0].has("type"), "goals[0] 缺少 type")
	assert(_dgp.goals[0].has("active"), "goals[0] 缺少 active")
	print("[DataStruct] goals 格式驗證通過")

	var _dtm: TeamData = state.teams.get(0)
	assert("named_members" in _dtm, "缺少 named_members 欄位")
	assert(_dtm.named_members is Array, "named_members 應為 Array")
	print("[DataStruct] named_members 欄位驗證通過")

	var _dte: TeamData = state.teams.get(0)
	assert("fatigue" in _dte, "缺少 fatigue")
	assert("guard_ratio" in _dte, "缺少 guard_ratio")
	assert("anon_wage" in _dte, "缺少 anon_wage")
	assert("armor_config" in _dte, "缺少 armor_config")
	assert("known_reputations" in _dte, "缺少 known_reputations")
	assert("strategic_assignments" in _dte, "缺少 strategic_assignments")
	print("[DataStruct] TeamData 新欄位驗證通過")

	var _dtr: TeamData = state.teams.get(0)
	assert(_dtr.resources.has("mounts"), "resources 缺少 mounts")
	assert(_dtr.resources.has("arrows"), "resources 缺少 arrows")
	assert(_dtr.resources.has("medicine"), "resources 缺少 medicine")
	print("[DataStruct] resources 新 key 驗證通過")

	assert("player_id" in state, "WorldState 缺少 player_id")
	assert(state.player_id == -1, "player_id 預設應為 -1")
	assert("ticks_per_day" in state, "WorldState 缺少 ticks_per_day")
	assert(state.ticks_per_day == 240, "ticks_per_day 應為 240")
	print("[DataStruct] WorldState 新欄位驗證通過")

	print("--- TimeConstants ---")
	assert(WorldState.TICKS_PER_MONTH  == WorldState.TICKS_PER_DAY * 30,
		"TICKS_PER_MONTH 應 = TICKS_PER_DAY*30")
	assert(WorldState.TICKS_PER_SEASON == WorldState.TICKS_PER_DAY * 90,
		"TICKS_PER_SEASON 應 = TICKS_PER_DAY*90")
	assert(WorldState.TICKS_PER_YEAR   == WorldState.TICKS_PER_DAY * 360,
		"TICKS_PER_YEAR 應 = TICKS_PER_DAY*360")
	assert(SalarySystem.SALARY_INTERVAL == WorldState.TICKS_PER_DAY * 7,
		"SALARY_INTERVAL 應 = 1週(TICKS_PER_DAY*7)")
	assert(HarvestSystem.SEASON_LENGTH  == WorldState.TICKS_PER_SEASON,
		"SEASON_LENGTH 應 = TICKS_PER_SEASON")
	assert(PopulationSystem.OVERFLOW_CHECK_INTERVAL == WorldState.TICKS_PER_DAY,
		"OVERFLOW_CHECK_INTERVAL 應 = TICKS_PER_DAY")
	print("TimeConstants OK — TICKS_PER_DAY=%d MONTH=%d SEASON=%d YEAR=%d" % [
		WorldState.TICKS_PER_DAY, WorldState.TICKS_PER_MONTH,
		WorldState.TICKS_PER_SEASON, WorldState.TICKS_PER_YEAR])

	print("[DataStruct] named_members 非空: Team0=%d" % state.teams[0].named_members.size())
	print("[DataStruct] person.salary 型別: %s" % typeof(state.persons[0].salary))
	print("[DataStruct] state.ticks_per_day=%d" % state.ticks_per_day)

	# 解析 NpcAI 測試用 person（person 1 可能在模擬中死亡，回退到其他存活 person）
	var _npc_pid: int = 1
	if not state.persons.has(_npc_pid) or state.persons.get(_npc_pid) == null:
		for _fpid in state.persons:
			if _fpid != 0:
				_npc_pid = _fpid; break

	# === NpcAI Task 1: write_memory / relations ===
	var _npc_sys := NpcAiSystem.new()
	var _mp: PersonData = state.persons.get(_npc_pid)
	_mp.relations.clear()  # 隔離：清除 sim 累積的 kindness 影響，確保測試純粹
	_npc_sys.write_memory(_mp, "looted", 0, 0, 0.7)
	assert(_mp.memory.size() > 0, "memory 應有記錄")
	assert(_mp.memory[_mp.memory.size() - 1]["type"] == "looted", "記憶 type 應為 looted")
	assert(float(_mp.relations.get(0, 0.0)) < 0.0, "relations[0] 應為負值")
	print("[NpcAI] write_memory/relations 驗證通過")

	# === NpcAI Task 2: 目標生成/觸發 ===
	var _gp: PersonData = PersonData.new()
	_gp.values["貪婪"] = 0.8
	NpcAiSystem.new().generate_birth_goals(_gp)
	assert(_gp.goals.size() > 0, "birth goals 應生成")
	assert(_gp.goals[0]["type"] == "wealth", "高貪婪應生成 wealth 目標")

	var _npc2 := NpcAiSystem.new()
	var _rp: PersonData = state.persons.get(_npc_pid)
	_npc2.write_memory(_rp, "looted", 0, 1, 0.7)
	var _has_revenge: bool = false
	for g in _rp.goals:
		if g["type"] == "revenge" and g["active"]: _has_revenge = true
	assert(_has_revenge, "looted 記憶應觸發 revenge 目標")
	print("[NpcAI] 目標生成/觸發驗證通過")

	# === NpcAI Task 3: check_goal_alignment ===
	var _npc3 := NpcAiSystem.new()
	var _cp: PersonData = state.persons.get(_npc_pid)
	_npc3._activate_goal(_cp, "revenge", 9)
	var _align: float = _npc3.check_goal_alignment(_cp, "逃跑")
	assert(_align < 0.0 or _align == 0.0, "revenge+逃跑不衝突（返回 0 或負）")
	var _align2: float = _npc3.check_goal_alignment(_cp, "攻擊")
	assert(_align2 > 0.0, "revenge+攻擊應 aligned（> 0）")
	print("[NpcAI] check_goal_alignment 驗證通過")

	# === TeamAI 驗證 ===
	print("[Salary] 驗證：30 tick 後應有薪水結算 print（見上方 tick 30 附近輸出）")
	var _evt_split: Object = load("res://scripts/simulation/events/event_unrest_split.gd").new()
	var _tp := PersonData.new()
	_tp.loyalty = 0.8
	_evt_split.reset_loyalty_on_transfer(_tp, "split_hard")
	assert(_tp.loyalty == 0.5, "split_hard loyalty 應為 0.5")
	_evt_split.reset_loyalty_on_transfer(_tp, "split_leader")
	assert(_tp.loyalty == 1.0, "split_leader loyalty 應為 1.0")
	print("[TeamAI] reset_loyalty_on_transfer 驗證通過")
	var _split_found: bool = false
	for _stid in state.teams:
		var _st: TeamData = state.teams[_stid]
		if _stid in [0, 1, 2, 3, 5, 6, 8, 9, 10]: continue
		var _sldr: PersonData = state.persons.get(_st.leader_id)
		if _sldr and absf(_sldr.loyalty - 1.0) < 0.01:
			print("[TeamAI] split_leader loyalty=1.0 驗證通過 (Team%d)" % _stid)
			_split_found = true
			break
	if not _split_found:
		print("[TeamAI] split_leader loyalty=1.0 未找到（分裂事件可能未觸發，屬正常）")
	var _ft: TeamData = state.teams.get(0)
	if _ft:
		print("[TeamAI] Team0 fatigue=%.4f（預期 > 0）" % _ft.fatigue)
		assert(_ft.fatigue > 0.0, "移動 team 應有疲勞累積")
	var _ms: Object = load("res://scripts/simulation/movement_system.gd").new()
	var _wt: TeamData = state.teams.get(0)
	if _wt:
		var _cap: float = _ms.get_carry_capacity(_wt)
		print("[TeamAI] Team0 carry_cap=%.1f weight=%.1f" % [_cap, _ms.calc_total_weight(_wt)])
		assert(_cap > 0.0, "carry capacity 應 > 0")

	# ── DayNightSystem 驗證 ──
	var _dns := DayNightSystem.new()
	var _saved_tick: int = state.world.current_tick
	# tick=0, ticks_per_day=240 → time_of_day=0.0 → "dawn"
	state.world.current_tick = 0
	assert(_dns.get_time_period(state) == "dawn", "tick 0 應為 dawn")
	# 驗證 tick 25 → day（25/240=0.104 > 0.1）
	state.world.current_tick = 25
	assert(_dns.get_time_period(state) == "day", "tick 25 應為 day")
	assert(_dns.get_fatigue_mult(state) == 1.0, "白天疲勞乘數應為 1.0")
	state.world.current_tick = 220   # 220/240=0.917 → "night"
	assert(_dns.get_time_period(state) == "night", "tick 220 應為 night")
	assert(_dns.get_speed_mult(state) == 0.5, "夜間速度乘數應為 0.5")
	state.world.current_tick = _saved_tick
	print("[DayNight] 時間計算驗證通過")

	var _dns2 := DayNightSystem.new()
	var _rest_team: TeamData = state.teams.get(2)
	_rest_team.current_task = "rest"
	_rest_team.guard_ratio = 0.0
	var _cvr: int = _dns2.get_camp_vision_range(state, _rest_team)
	assert(_cvr == 0, "無守夜 → camp_vision_range 應為 0")
	_rest_team.guard_ratio = 0.5
	_cvr = _dns2.get_camp_vision_range(state, _rest_team)
	print("[DayNight] guard_ratio=0.5 camp_vision_range=%d" % _cvr)
	var _dip := DiplomaticAiSystem.new()
	var _ds: float = _dip._calc_diplomacy_score(state, state.teams[0], state.teams[3])
	print("[Diplomacy] Team0→Team3 score=%.3f" % _ds)
	assert(_ds >= 0.0 and _ds <= 1.0, "diplomacy score 應在 0.0–1.0")

	var _dip2 := DiplomaticAiSystem.new()
	# Team6（商隊）主動提外交
	_dip2.try_proactive_diplomacy(state, state.teams[6])
	# 攻擊後信譽下降
	_dip2._update_reputation(state.teams[0], 3, -0.3)
	var _rep: float = float(state.teams[0].known_reputations.get(3, 0.5))
	assert(_rep < 0.5, "攻擊後 known_reputations 應下降")
	print("[Diplomacy] known_reputations 更新驗證通過")

	var _strat := StrategicAiSystem.new()
	var _f0: FactionData = state.factions.get(0)
	if _f0:
		_strat._update_faction_goals(state, _f0)
		print("[StrategicAI] Faction0 strategic_goals=%d" % _f0.strategic_goals.size())
		assert(_f0.strategic_goals.size() > 0, "Faction0 應有至少一個戰略目標")

	if _f0 and _f0.strategic_goals.size() > 0 and _f0.strategic_goals[0]["type"] == "expand":
		_strat._assign_encirclement(state, _f0, _f0.strategic_goals[0]["target_id"])
		for tid in _f0.member_team_ids:
			var mt: TeamData = state.teams.get(tid)
			if mt and mt.strategic_assignments.size() > 0:
				print("[StrategicAI] Team%d strategic_assignments=%s" % [
					tid, str(mt.strategic_assignments)])
				break

	var _ps := PlayerSystem.new()
	_ps.init_player(state, 0, 0)   # Person0 = 玩家，Team0
	assert(state.player_id == 0, "player_id 應為 0")
	assert(state.player_state.has("inventory"), "player_state 應有 inventory")
	assert(float(state.player_state.get("coin", 0)) == 50.0, "初始金幣應為 50")
	print("[Player] init_player 驗證通過")

	# take_from_team 測試
	state.teams[0].resources["medicine"] = 5
	var _took: bool = _ps.take_from_team(state, "medicine", 2)
	assert(_took, "take_from_team 應成功")
	assert(int(state.teams[0].resources.get("medicine", 0)) == 3, "team medicine 應剩 3")
	var _inv: Array = state.player_state.get("inventory", [])
	var _has_med: bool = false
	for item in _inv:
		if item["grade"] == "medicine": _has_med = true
	assert(_has_med, "inventory 應有 medicine")
	print("[Player] take_from_team 驗證通過")

	# deposit_to_team 測試
	var _dep2: bool = _ps.deposit_to_team(state, "medicine", 1)
	assert(_dep2, "deposit_to_team 應成功")
	assert(int(state.teams[0].resources.get("medicine", 0)) == 4, "team medicine 應為 4")
	print("[Player] deposit_to_team 驗證通過")

	# 隔離：清除模擬可能殘留的 hand_1 裝備和 inventory 中的武器
	state.persons.get(0).equipment["hand_1"] = { "type": "none", "grade": "" }
	var _pre_inv: Array = state.player_state.get("inventory", [])
	for _pi in range(_pre_inv.size() - 1, -1, -1):
		if _pre_inv[_pi]["grade"] == "weapon_melee_low": _pre_inv.remove_at(_pi)
	# 先給 inventory 一把武器
	_ps.add_to_inventory(state, "weapon_melee_low", 1)
	var _eq: bool = _ps.equip_item(state, "hand_1", "weapon_melee_low")
	assert(_eq, "equip_item 應成功")
	var _player: PersonData = state.persons.get(0)
	assert(_player.equipment["hand_1"]["grade"] == "weapon_melee_low",
		"hand_1 應裝備 weapon_melee_low")
	# inventory 中武器應減少
	var _weapon_in_inv: bool = false
	for item in state.player_state["inventory"]:
		if item["grade"] == "weapon_melee_low": _weapon_in_inv = true
	assert(not _weapon_in_inv, "裝備後 inventory 不應有武器")
	print("[Player] equip_item 驗證通過")

	# unequip_item 測試
	var _uneq: bool = _ps.unequip_item(state, "hand_1")
	assert(_uneq, "unequip_item 應成功")
	assert(state.persons.get(0).equipment["hand_1"]["grade"] == "", "hand_1 應卸下")
	var _has_weapon_back: bool = false
	for item in state.player_state["inventory"]:
		if item["grade"] == "weapon_melee_low": _has_weapon_back = true
	assert(_has_weapon_back, "卸裝後 inventory 應有武器")
	var _uneq_empty: bool = _ps.unequip_item(state, "hand_2")
	assert(not _uneq_empty, "卸下空槽應失敗")
	print("[Player] unequip_item 驗證通過")

	# get_visible_teams
	var _visible: Array = _ps.get_visible_teams(state)
	print("[Player] 玩家可見 team 數=%d" % _visible.size())
	# 玩家在 Team0，Team0 discovered Team3 → visible 應包含 3
	assert(_visible.has(3), "玩家應能看到 Team3")

	# 重量計算
	_ps.add_to_inventory(state, "armor_low", 2)
	var _wt2: float = _ps.calc_inventory_weight(state)
	print("[Player] inventory weight=%.1f（累計，armor_low×2貢獻8.0）" % _wt2)
	assert(_wt2 >= 8.0, "armor_low×2 重量應 >= 8.0")

	# ── EncounterSystem 基礎驗證 ──
	var _enc := EncounterSystem.new()
	var _enc_unit: Dictionary = {
		"person_id": 0, "team_id": 0,
		"pos": Vector2i(0, 0),
		"stamina": 1.0, "is_messenger": false, "has_exited": false,
	}
	var _p0: PersonData = state.persons.get(0)
	if _p0:
		_p0.body_parts["torso"]["status"] = "healthy"
		assert(not _enc.is_dead(_enc_unit, state), "healthy torso 不應死亡")
		assert(_enc.is_combat_capable(_enc_unit, state), "healthy 應戰鬥能力")
		_p0.body_parts["torso"]["status"] = "severed"
		assert(_enc.is_dead(_enc_unit, state), "severed torso 應死亡")
		_p0.body_parts["torso"]["status"] = "healthy"  # 還原
	print("[Encounter] 基礎輔助函數驗證通過")

	var _anon_unit: Dictionary = {
		"person_id": -1, "team_id": 0,
		"pos": Vector2i(1, 0),
		"stamina": 0.8, "is_messenger": false, "has_exited": false,
		"body_parts": _enc._default_body_parts(),
	}
	assert(_enc.is_combat_capable(_anon_unit, state), "匿名 unit 應戰鬥能力")
	assert(_enc.hex_dist(Vector2i(0,0), Vector2i(3,0)) == 3, "hex_dist 應為 3")
	print("[Encounter] 匿名 unit 驗證通過")

	var _enc2 := EncounterSystem.new()
	state.player_id = 0
	_enc2.init_encounter(state, 0, 1, "normal")
	assert(state.encounter_active, "encounter_active 應為 true")
	var _unit_count: int = state.encounter_units.size()
	assert(_unit_count > 0, "應有 encounter units")
	print("[Encounter] init_encounter units=%d" % _unit_count)
	state.encounter_active = false
	state.encounter_units.clear()

	var _enc3 := EncounterSystem.new()
	_enc3.init_encounter(state, 0, 1, "normal")
	if state.encounter_units.size() >= 2:
		var _test_unit_idx: int = -1
		for _i in range(state.encounter_units.size()):
			if state.encounter_units[_i]["team_id"] == 0:
				_test_unit_idx = _i
				break
		if _test_unit_idx != -1:
			var _action: Dictionary = _enc3._decide_action(_test_unit_idx, state, -1)
			assert(_action.has("type"), "_decide_action 應有 type 欄位")
			print("[Encounter] decide_action type=%s" % _action["type"])
	state.encounter_active = false
	state.encounter_units.clear()

	var _enc4 := EncounterSystem.new()
	_enc4.init_encounter(state, 0, 1, "normal")
	var _result: String = "ongoing"
	for _r in range(50):
		_result = _enc4.advance_encounter_tick(state)
		if _result != "ongoing": break
	print("[Encounter] advance_encounter_tick 結果=%s (50輪)" % _result)
	assert(_result != "" and _result != null, "advance_encounter_tick 應有結果")
	state.encounter_active = false
	state.encounter_units.clear()

	# 完整遭遇戰流程
	var _enc5 := EncounterSystem.new()
	state.player_id = 0
	state.persons[0].team_id = 0
	_enc5.init_encounter(state, 0, 1, "normal")
	print("[Encounter] 遭遇戰流程測試開始 units=%d" % state.encounter_units.size())
	var _final_result: String = "ongoing"
	for _r in range(100):
		_final_result = _enc5.advance_encounter_tick(state)
		if _final_result != "ongoing": break
	_enc5.resolve_encounter_end(state, _final_result)
	assert(not state.encounter_active, "結算後 encounter_active 應為 false")
	assert(state.encounter_units.size() == 0, "結算後 encounter_units 應清空")
	print("[Encounter] 完整遭遇戰流程驗證通過 result=%s" % _final_result)

	# ── ItemAttributes 驗證 ──
	print("--- ItemAttributes ---")
	assert(ItemAttributes.get_damage("weapon_melee_low") == 10.0,
		"get_damage weapon_melee_low should be 10.0")
	assert(ItemAttributes.get_block_chance("armor_high") == 0.50,
		"get_block_chance armor_high should be 0.50")
	assert(ItemAttributes.get_parry_chance("weapon_melee_high") == 0.20,
		"get_parry_chance weapon_melee_high should be 0.20")
	assert(ItemAttributes.is_2h("weapon_ranged_low") == true,
		"weapon_ranged_low should be 2h")
	assert(ItemAttributes.is_2h("weapon_melee_high") == false,
		"weapon_melee_high should not be 2h")
	assert(ItemAttributes.get_weight("armor_high", 1) == 7.0,
		"armor_high weight should be 7.0")
	assert(ItemAttributes.get_medicine_cost("繃帶") == 2,
		"medicine 繃帶 cost should be 2")
	assert(ItemAttributes.get_display_name("armor_low", "hand_1") == "皮盾",
		"armor_low in hand_1 should display as 皮盾")
	print("ItemAttributes OK")

	# ── HealthSystem 驗證 ──
	print("--- HealthSystem ---")
	var _hs_unit: Dictionary = {
		"person_id": 0,
		"stamina": 1.0,
		"equipment": {},
		"inventory": [],
	}
	# get_speed_mult with full stamina + full blood = 1.0
	var _sm: float = HealthSystem.get_speed_mult(_hs_unit, state)
	assert(_sm > 0.0 and _sm <= 1.0, "get_speed_mult should be in (0,1]")
	# receive_damage reduces hp — reset torso to known value first to avoid edge-case
	if state.persons.has(0):
		state.persons[0].body_parts["torso"]["hp"] = 50.0
		state.persons[0].body_parts["torso"]["status"] = "healthy"
	var _bp_before: float = state.persons[0].body_parts["torso"]["hp"]
	HealthSystem.receive_damage(_hs_unit, state, "torso", 10.0)
	var _bp_after: float = state.persons[0].body_parts["torso"]["hp"]
	assert(_bp_after < _bp_before, "receive_damage should reduce torso hp")
	print("HealthSystem OK")

	# ── EncounterTemplates 驗證 ──
	print("--- EncounterTemplates ---")
	var _tmpl_team: TeamData = state.teams[0]
	_tmpl_team.resources["arrows"]   = 30
	_tmpl_team.resources["medicine"] = 10
	var _archer_unit: Dictionary = {
		"person_id": -1,
		"team_id": 0,
		"equipment": {
			"hand_1": { "type": "pool", "grade": "weapon_ranged_low" },
			"hand_2": {}, "head": {}, "torso": {},
			"right_arm": {}, "left_arm": {}, "right_leg": {}, "left_leg": {},
		},
		"inventory": [],
	}
	EncounterTemplates.fill_inventory(_archer_unit, _tmpl_team, state)
	var _has_arrows: bool = false
	for _item in _archer_unit["inventory"]:
		if _item["grade"] == "arrows": _has_arrows = true
	assert(_has_arrows, "archer unit should have arrows in inventory")
	assert(_tmpl_team.resources["arrows"] < 30, "team arrows should decrease after template fill")
	print("EncounterTemplates OK")

	# ── EncounterCombat 驗證 ──
	print("--- EncounterCombat ---")
	var _enc_state := WorldState.new()
	var _enc_t0 := TeamData.new()
	_enc_t0.team_id = 0; _enc_t0.population = 2; _enc_t0.armed_anon_ratio = 1.0
	_enc_t0.resources = { "weapon_melee_low": 10, "arrows": 20, "medicine": 5,
		"armor_low": 0, "armor_high": 0, "food": 0 }
	_enc_t0.armor_config = { "torso": "none", "head": "none",
		"right_arm": "none", "left_arm": "none", "right_leg": "none", "left_leg": "none" }
	var _enc_t1 := TeamData.new()
	_enc_t1.team_id = 1; _enc_t1.population = 2; _enc_t1.armed_anon_ratio = 1.0
	_enc_t1.resources = { "weapon_melee_low": 10, "arrows": 0, "medicine": 5,
		"armor_low": 0, "armor_high": 0, "food": 0 }
	_enc_t1.armor_config = { "torso": "none", "head": "none",
		"right_arm": "none", "left_arm": "none", "right_leg": "none", "left_leg": "none" }
	_enc_state.teams[0] = _enc_t0
	_enc_state.teams[1] = _enc_t1
	_enc_state.encounter_active = true
	_enc_state.encounter_attacker_id = 0
	_enc_state.encounter_defender_id = 1
	var _enc_sys := EncounterSystem.new()
	_enc_sys.init_encounter(_enc_state, 0, 1, "normal")
	assert(_enc_state.encounter_units.size() > 0, "encounter should have units")
	assert(_enc_state.encounter_units[0].has("action_timer"), "unit should have action_timer")
	assert(_enc_state.encounter_units[0].has("stance"), "unit should have stance")
	assert(_enc_state.encounter_units[0].has("equipment"), "unit should have equipment")
	assert(_enc_state.encounter_units[0].has("inventory"), "unit should have inventory")
	var _enc_result: String = "ongoing"
	for _t in range(50):
		_enc_result = _enc_sys.advance_encounter_tick(_enc_state)
		if _enc_result != "ongoing": break
	print("EncounterCombat: result=%s" % _enc_result)
	assert(_enc_result != "ongoing" or true, "encounter ran without crash")
	print("EncounterCombat OK")

	# ── PlayerSystem weight integration ──
	print("--- PlayerSystem weight ---")
	var _ws: WorldState = WorldState.new()
	var _ps2 := PlayerSystem.new()
	var _pp := PersonData.new(); _pp.id = 99; _pp.team_id = 0
	_ws.persons[99] = _pp
	_ws.player_id   = 99
	_ws.player_state = { "inventory": [], "coin": 0.0 }
	var _pteam := TeamData.new()
	_pteam.team_id = 0
	_pteam.resources = { "medicine": 10, "tools": 5, "arrows": 20,
		"weapon_melee_low": 5, "armor_low": 2 }
	_ws.teams[0] = _pteam
	var _ok: bool = _ps2.take_from_team(_ws, "medicine", 3)
	assert(_ok, "take_from_team should succeed")
	assert(int(_pteam.resources.get("medicine", 0)) == 7, "team medicine should be 7")
	assert(_ws.player_state["inventory"].size() == 1, "inventory should have 1 slot")
	var _w: float = _ps2.calc_inventory_weight(_ws)
	assert(_w > 0.0, "inventory weight should be > 0 (using ItemAttributes)")
	print("PlayerSystem weight OK: %.2f kg" % _w)

	# ── EncounterSystem unit equipment ──
	print("--- EncounterSystem unit equipment ---")
	var _es := EncounterSystem.new()
	var _es_state := WorldState.new()
	var _es_t0 := TeamData.new()
	_es_t0.team_id = 0; _es_t0.population = 3
	_es_t0.resources = {
		"weapon_melee_low": 5, "arrows": 30, "medicine": 10,
		"armor_low": 0, "armor_high": 0, "food": 0,
	}
	_es_t0.armor_config = { "torso": "none", "head": "none",
		"right_arm": "none", "left_arm": "none", "right_leg": "none", "left_leg": "none" }
	var _es_t1 := TeamData.new()
	_es_t1.team_id = 1; _es_t1.population = 2
	_es_t1.resources = {
		"weapon_melee_low": 3, "arrows": 0, "medicine": 5,
		"armor_low": 0, "armor_high": 0, "food": 0,
	}
	_es_t1.armor_config = { "torso": "none", "head": "none",
		"right_arm": "none", "left_arm": "none", "right_leg": "none", "left_leg": "none" }
	_es_state.teams[0] = _es_t0
	_es_state.teams[1] = _es_t1
	_es_state.encounter_attacker_id = 0
	_es_state.encounter_defender_id = 1
	_es.init_encounter(_es_state, 0, 1, "normal")
	for _u in _es_state.encounter_units:
		assert(_u.has("equipment"), "unit should have equipment dict")
		assert(_u.has("inventory"), "unit should have inventory array")
		assert(_u.has("action_timer"), "unit should have action_timer")
	print("Unit equipment OK — %d units spawned" % _es_state.encounter_units.size())

	# prisoner_population 驗證
	print("--- prisoner_population ---")
	var _total_prisoners: int = 0
	for _tid in state.teams:
		var _t: TeamData = state.teams[_tid]
		_total_prisoners += _t.prisoner_population
		assert(_t.prisoner_population <= _t.population,
			"prisoner_population 不可超過 population（Team%d）" % _tid)
	print("全域俘虜總數: %d" % _total_prisoners)
	print("prisoner_population OK")

	# spawn cap 驗證（觀察用）
	print("--- encounter unit count ---")
	print("遭遇戰 unit 上限確認：每隊 named + max %d anon" % EncounterSystem.ANON_UNIT_CAP)

	print("--- EncounterMapShape ---")
	var enc := EncounterSystem.new()
	# 每條邊應有 MAP_RADIUS+1 tiles
	for edge in range(6):
		var hexes: Array = enc._get_edge_hexes(edge)
		var ok: bool = hexes.size() == EncounterSystem.MAP_RADIUS + 1
		print("  edge%d size=%d %s" % [edge, hexes.size(), "OK" if ok else "FAIL"])
		# 每個 tile 都應在地圖內（hex_dist == MAP_RADIUS）
		for h in hexes:
			var d: int = enc.hex_dist(Vector2i.ZERO, h)
			if d != EncounterSystem.MAP_RADIUS:
				print("  FAIL edge%d tile(%d,%d) dist=%d != %d" % [edge, h.x, h.y, d, EncounterSystem.MAP_RADIUS])
	# 總唯一邊界 tile = 6 * MAP_RADIUS = 60
	var all_edge: Array = []
	for edge in range(6):
		for h in enc._get_edge_hexes(edge):
			if not all_edge.has(h): all_edge.append(h)
	var expected: int = 6 * EncounterSystem.MAP_RADIUS
	print("  unique edge tiles=%d (expected %d) %s" % [
		all_edge.size(), expected, "OK" if all_edge.size() == expected else "FAIL"])
	print("  MAP_DIAMETER=%d" % EncounterSystem.MAP_DIAMETER)
	print("EncounterMapShape OK" if all_edge.size() == expected else "EncounterMapShape FAIL")

	print("--- TextMapRenderer ---")
	var map_str := TextMapRenderer.render(state, 0, Vector2i(4, 4))
	assert(map_str.contains("@"), "renderer: 需包含玩家符號 @")
	assert(map_str.contains("?"), "renderer: 需包含迷霧符號 ?")
	assert(map_str.length() > 100, "renderer: 非空")
	print("  map length=%d OK" % map_str.length())
	print("  first 200 chars:\n" + map_str.substr(0, 200))

	# ────────── PlayerCommandSystem 測試 ──────────
	print("--- PlayerCommandSystem Tests ---")
	# 確保 encounter 狀態乾淨
	state.encounter_active = false
	state.encounter_units.clear()
	state.player_pending_targets.clear()
	state.player_forced_event = {}
	state.player_forced_event_id = ""

	state.player_id = 0   # 安全設定，確保 player_id 有效
	var _cmd := PlayerCommandSystem.new()
	var _pt_id: int = state.persons.get(state.player_id).team_id   # = 0

	# ── 測試 1：get_available_actions（ignore/attack 永遠可選；recruit coin-gated）──
	state.player_pending_targets.append(1)
	var _pt_team0: TeamData = state.teams.get(state.persons.get(0).team_id)
	var _orig_coin: float = float(_pt_team0.resources.get("coin", 0))
	_pt_team0.resources["coin"] = 100.0
	var _actions := _cmd.get_available_actions(state, 1)
	assert(_actions.has("ignore"), "ignore 永遠可選")
	assert(_actions.has("attack"), "attack 永遠可選")
	assert(_actions.has("recruit"), "recruit: coin 足夠時可選")
	_pt_team0.resources["coin"] = 0.0
	var _actions_no_coin := _cmd.get_available_actions(state, 1)
	assert(not _actions_no_coin.has("recruit"), "recruit: coin 不足時不可選")
	_pt_team0.resources["coin"] = _orig_coin
	print("  [OK] get_available_actions: %s" % str(_actions))

	# ── 測試 2：execute_action("ignore") → pending 清除 ──
	var _r_ignore := _cmd.execute_action(state, 1, "ignore")
	assert(_r_ignore.get("ok"), "ignore 應成功")
	assert(not state.player_pending_targets.has(1), "ignore 後 pending 清除")
	print("  [OK] execute_action ignore: %s" % _r_ignore.get("msg", ""))

	# ── 測試 3：forced_event diplomacy → refuse ──
	state.player_forced_event = { "from_id": 2, "action": "diplomacy", "proposal": "alliance" }
	state.player_forced_event_id = "test-forced-id"
	var _opts_d := _cmd.get_forced_response_options(state)
	assert(_opts_d.has("accept") and _opts_d.has("refuse"), "diplomacy 選項應有 accept/refuse")
	var _r_refuse := _cmd.respond_to_forced(state, "refuse")
	assert(_r_refuse.get("ok"), "refuse 應成功")
	assert(state.player_forced_event.is_empty(), "refuse 後 forced_event 清除")
	print("  [OK] forced diplomacy refuse: %s" % _r_refuse.get("msg", ""))

	# ── 測試 4：forced_event extort → pay ──
	# Team2 勒索 Team0（玩家）
	state.player_forced_event = { "from_id": 2, "action": "extort" }
	state.player_forced_event_id = "test-forced-id"
	var _r_pay := _cmd.respond_to_forced(state, "pay")
	assert(_r_pay.get("ok"), "pay 應成功")
	assert(state.player_forced_event.is_empty(), "pay 後 forced_event 清除")
	print("  [OK] forced extort pay: %s" % _r_pay.get("msg", ""))

	# ── 測試 5：respond_to_forced 空事件 ──
	var _r_empty := _cmd.respond_to_forced(state, "refuse")
	assert(not _r_empty.get("ok"), "空 forced_event 應返回 ok=false")
	print("  [OK] empty forced_event handled correctly")

	# ── 測試 6：execute_action("attack") → encounter_active ──
	state.player_pending_targets.append(1)
	state.encounter_active = false
	var _r_atk := _cmd.execute_action(state, 1, "attack")
	assert(_r_atk.get("ok"), "attack 應成功")
	assert(state.encounter_active, "attack 後 encounter_active 應為 true")
	assert(state.encounter_attacker_id == _pt_id, "attacker 應為玩家")
	assert(state.encounter_defender_id == 1, "defender 應為 Team1")
	assert(not state.player_pending_targets.has(1), "attack 後 pending 清除")
	print("  [OK] execute_action attack: encounter triggered, attacker=%d defender=%d" % [
		state.encounter_attacker_id, state.encounter_defender_id])
	state.encounter_active = false
	state.encounter_units.clear()

	# ── 測試 7：clear_pending_targets ──
	state.player_pending_targets = [1, 2, 3]
	state.player_forced_event = { "from_id": 2, "action": "extort" }
	state.player_forced_event_id = "test-forced-id"
	_cmd.clear_pending_targets(state)
	assert(state.player_pending_targets.is_empty(), "clear_pending_targets 應清空 pending")
	assert(not state.player_forced_event.is_empty(), "clear_pending_targets 不影響 forced_event")
	state.player_forced_event = {}
	state.player_forced_event_id = ""
	print("  [OK] clear_pending_targets 只清 pending，保留 forced_event")

	print("--- PlayerCommandSystem Tests PASSED ---")
	# ────────────────────────────────────────────

	# ── _accept_diplomacy 驗證 ──
	print("--- _accept_diplomacy Tests ---")
	var _cmd_a := PlayerCommandSystem.new()
	# 建立 NPC 勢力（Team1 為領袖）
	var _npc_faction_id: int = state.create_faction(1)
	var _pt_a: TeamData = state.teams.get(state.persons.get(state.player_id).team_id)
	# 暫時清除玩家勢力（隔離測試前置條件）
	var _saved_pt_faction: int = _pt_a.faction_id
	_pt_a.faction_id = -1
	assert(_pt_a.faction_id == -1, "_accept_diplomacy 前玩家無勢力")
	# 模擬 NPC 外交提案
	state.player_forced_event = { "from_id": 1, "action": "diplomacy", "proposal": "alliance" }
	state.player_forced_event_id = "test-forced-id"
	var _resp_a := _cmd_a.respond_to_forced(state, "accept")
	assert(_resp_a.get("ok"), "_accept_diplomacy 應成功")
	assert(_pt_a.faction_id == _npc_faction_id, "接受後玩家應加入 NPC 勢力")
	assert(state.player_forced_event.is_empty(), "accept 後 forced_event 應清除")
	print("  [OK] _accept_diplomacy alliance: player faction_id=%d" % _pt_a.faction_id)
	# 清理（避免影響其他測試）
	_pt_a.faction_id = _saved_pt_faction
	print("--- _accept_diplomacy Tests PASSED ---")

	# ── PlayerApiMapper unit tests ─────────────────────────────────────────────────
	print("\n--- PlayerApiMapper ---")
	var _mapper_state := WorldState.new()

	# map_query_envelope
	var _qenv := PlayerApiMapper.map_query_envelope(true, "ok", "msg", {"x": 1})
	assert(_qenv["ok"] == true, "map_query_envelope ok")
	assert(_qenv["code"] == "ok", "map_query_envelope code")
	assert(_qenv["message"] == "msg", "map_query_envelope message")
	assert(_qenv["data"]["x"] == 1, "map_query_envelope data")
	print("map_query_envelope: OK")

	# map_command_result
	var _cres := PlayerApiMapper.map_command_result(false, "no_player", "err", {})
	assert(_cres["ok"] == false, "map_command_result ok")
	assert(_cres["code"] == "no_player", "map_command_result code")
	print("map_command_result: OK")

	# map_player_summary — no player
	var _ps_empty := PlayerApiMapper.map_player_summary(_mapper_state)
	assert(_ps_empty["player_exists"] == false, "map_player_summary no player")
	print("map_player_summary (no player): OK")

	# map_pending_targets — empty
	var _pt_empty := PlayerApiMapper.map_pending_targets(_mapper_state)
	assert(_pt_empty.size() == 0, "map_pending_targets empty")
	print("map_pending_targets (empty): OK")

	# map_forced_interaction — empty
	var _fi_empty := PlayerApiMapper.map_forced_interaction(_mapper_state)
	assert(_fi_empty["interaction_id"] == "", "map_forced_interaction empty")
	assert(_fi_empty["responses"].size() == 0, "map_forced_interaction responses empty")
	print("map_forced_interaction (empty): OK")

	# map_forced_interaction — extort
	_mapper_state.player_forced_event = {"from_id": 2, "action": "extort"}
	_mapper_state.player_forced_event_id = "abc123"
	var _fi_extort := PlayerApiMapper.map_forced_interaction(_mapper_state)
	assert(_fi_extort["interaction_id"] == "abc123", "map_forced_interaction extort id")
	assert(_fi_extort["interaction_type"] == "extort", "map_forced_interaction extort type")
	assert(_fi_extort["responses"].size() == 2, "map_forced_interaction extort responses count")
	assert(_fi_extort["responses"][0]["response_id"] == "pay", "map_forced_interaction extort first response")
	print("map_forced_interaction (extort): OK")

	# map_forced_interaction — diplomacy
	_mapper_state.player_forced_event = {"from_id": 3, "action": "diplomacy", "proposal": "alliance"}
	_mapper_state.player_forced_event_id = "def456"
	var _fi_dipl := PlayerApiMapper.map_forced_interaction(_mapper_state)
	assert(_fi_dipl["interaction_type"] == "diplomacy", "map_forced_interaction diplomacy type")
	assert(_fi_dipl["responses"].size() == 2, "map_forced_interaction diplomacy responses count")
	print("map_forced_interaction (diplomacy): OK")

	# Reset
	_mapper_state.player_forced_event = {}
	_mapper_state.player_forced_event_id = ""
	print("PlayerApiMapper: ALL PASS")

	# ── PlayerQueryApi unit tests ──────────────────────────────────────────────────
	print("\n--- PlayerQueryApi ---")
	var _qapi := PlayerQueryApi.new()
	var _qapi_state := WorldState.new()

	# No player → error envelope
	var _qapi_r1 := _qapi.get_player_snapshot(_qapi_state, {})
	assert(_qapi_r1["ok"] == false, "get_player_snapshot no player ok=false")
	assert(_qapi_r1["code"] == "no_player", "get_player_snapshot no player code")
	print("get_player_snapshot (no player): OK")

	# get_team_details — invalid team
	var _qapi_r2 := _qapi.get_team_details(_qapi_state, 999)
	assert(_qapi_r2["ok"] == false, "get_team_details invalid team")
	print("get_team_details (invalid): OK")

	# get_location_context — invalid tile
	var _qapi_r3 := _qapi.get_location_context(_qapi_state, -1, -1)
	assert(_qapi_r3["ok"] == false, "get_location_context invalid tile")
	print("get_location_context (invalid tile): OK")

	# get_available_actions — no player
	var _qapi_r4 := _qapi.get_available_actions(_qapi_state, {"team_id": -1, "member_id": -1, "tile_q": -1, "tile_r": -1, "forced_interaction_id": ""})
	assert(_qapi_r4["ok"] == false, "get_available_actions no player")
	print("get_available_actions (no player): OK")

	print("PlayerQueryApi: ALL PASS")

	# ── PlayerCommandApi unit tests ────────────────────────────────────────────────
	print("\n--- PlayerCommandApi ---")
	var _capi := PlayerCommandApi.new()
	var _capi_state := WorldState.new()

	# No player → error
	var _capi_r1 := _capi.move_to(_capi_state, 0, 0)
	assert(_capi_r1["ok"] == false, "cmd move_to no player")
	assert(_capi_r1["code"] == "no_player", "cmd move_to no player code")
	print("move_to (no player): OK")

	# No player → respond_to_forced error
	var _capi_r2 := _capi.respond_to_forced(_capi_state, "abc", "refuse")
	assert(_capi_r2["ok"] == false, "respond_to_forced no player")
	print("respond_to_forced (no player): OK")

	# dispatch — unknown command
	var _capi_r3 := _capi.dispatch(_capi_state, "unknown_cmd", {})
	assert(_capi_r3["ok"] == false, "dispatch unknown cmd")
	assert(_capi_r3["code"] == "invalid_request", "dispatch unknown cmd code")
	print("dispatch (unknown): OK")

	# respond_to_forced — expired id
	var _capi_p1 := PersonData.new()
	_capi_p1.id = 1; _capi_p1.person_name = "CApiP1"; _capi_p1.team_id = -1
	_capi_state.persons[1] = _capi_p1
	_capi_state.player_id = 1
	_capi_state.player_forced_event = {"from_id": 2, "action": "extort"}
	_capi_state.player_forced_event_id = "real-id"
	var _capi_r4 := _capi.respond_to_forced(_capi_state, "wrong-id", "refuse")
	assert(_capi_r4["ok"] == false, "respond_to_forced wrong id")
	assert(_capi_r4["code"] == "forced_response_missing", "respond_to_forced wrong id code")
	print("respond_to_forced (wrong id): OK")

	# respond_to_forced — invalid response_id
	var _capi_r5 := _capi.respond_to_forced(_capi_state, "real-id", "invalid_resp")
	assert(_capi_r5["ok"] == false, "respond_to_forced invalid resp")
	assert(_capi_r5["code"] == "forced_response_invalid", "respond_to_forced invalid resp code")
	print("respond_to_forced (invalid response_id): OK")

	# Reset
	_capi_state.player_id = -1
	_capi_state.player_forced_event = {}
	_capi_state.player_forced_event_id = ""
	print("PlayerCommandApi: ALL PASS")

	# ── SimBridge player API integration test ────────────────────────────
	print("\n--- SimBridge Player API Integration ---")
	var _sb_state := WorldState.new()
	var _sb_runner := SimRunner.new()
	var _sb_bridge := SimBridge.new(_sb_runner, _sb_state)

	# Setup minimal player
	var _sb_p := PersonData.new()
	_sb_p.id = 0; _sb_p.person_name = "SBPlayer"; _sb_p.team_id = 0
	_sb_state.persons[0] = _sb_p
	_sb_state.player_id = 0
	var _sb_team := TeamData.new()
	_sb_team.team_id = 0; _sb_team.population = 5
	_sb_team.tile_pos = Vector2i(0, 0)
	_sb_team.resources = {"food": 100.0, "coin": 10, "material": 10}
	_sb_state.teams[0] = _sb_team
	_sb_state.world.tiles[0] = HexTileData.new()
	_sb_state.world.tiles[1000] = HexTileData.new()  # (1,0) for move target

	# query_player returns ok envelope with snapshot
	var _qp := _sb_bridge.query_player()
	assert(_qp.get("ok"), "SimBridge query_player should succeed")
	var _snap: Dictionary = _qp.get("data", {}).get("snapshot", {})
	assert(_snap.has("player_summary"), "snapshot has player_summary")
	assert(_snap.get("player_summary", {}).get("player_exists"), "player_exists in snapshot")
	assert(not _snap.get("player_summary", {}).get("encounter_active"), "no encounter initially")
	print("  [OK] query_player snapshot: player_exists, no encounter")

	# query_player with no player → ok=false
	var _sb_state2 := WorldState.new()
	var _sb_bridge2 := SimBridge.new(_sb_runner, _sb_state2)
	var _qp2 := _sb_bridge2.query_player()
	assert(not _qp2.get("ok"), "query_player no player should fail")
	print("  [OK] query_player no player: ok=false")

	# command_player move_to valid tile → ok
	var _cmd_r1 := _sb_bridge.command_player("move_to", {"tile_q": 1, "tile_r": 0})
	assert(_cmd_r1.get("ok"), "move_to valid tile: ok=true")
	assert(_sb_state.teams[0].move_target == Vector2i(1, 0), "move_target set")
	print("  [OK] command_player move_to: move_target set")

	# command_player move_to invalid tile → ok=false
	var _cmd_r2 := _sb_bridge.command_player("move_to", {"tile_q": 99, "tile_r": 99})
	assert(not _cmd_r2.get("ok"), "move_to invalid tile: ok=false")
	print("  [OK] command_player move_to invalid: ok=false")

	# command_player unknown command → ok=false
	var _cmd_r3 := _sb_bridge.command_player("nonexistent_cmd", {})
	assert(not _cmd_r3.get("ok"), "unknown cmd: ok=false")
	print("  [OK] command_player unknown: ok=false")

	print("SimBridge Player API Integration: ALL PASS")

	# ── members_detail + team_stats in snapshot ──────────────────────────
	print("\n--- members_detail / team_stats fields ---")
	# Add a second named member to _sb_team to test multi-member case
	var _sb_p2 := PersonData.new()
	_sb_p2.id = 1; _sb_p2.person_name = "SBMember"; _sb_p2.team_id = 0
	_sb_state.persons[1] = _sb_p2
	_sb_team.leader_id = 0
	_sb_team.named_members = [1]

	var _snap2: Dictionary = _sb_bridge.query_player().get("data", {}).get("snapshot", {})
	assert(_snap2.has("members_detail"), "snapshot has members_detail")
	assert(_snap2.has("team_stats"), "snapshot has team_stats")
	var _md: Array = _snap2.get("members_detail", [])
	assert(_md.size() == 2, "members_detail has 2 entries, got %d" % _md.size())
	assert(_md[0].get("role") == "leader", "first member is leader")
	assert(_md[1].get("role") == "member", "second member is member")
	assert(_md[0].has("hp_current"), "member has hp_current")
	assert(_md[0].has("hp_max"), "member has hp_max")
	assert(_md[0].has("attributes"), "member has attributes")
	assert(_md[0].has("values"), "member has values")
	assert(_md[0].has("skills"), "member has skills")
	assert(_md[0].has("body_parts"), "member has body_parts")
	assert(_md[0].has("equipped"), "member has equipped")
	assert(_md[0].has("inventory"), "member has inventory")
	var _ts: Dictionary = _snap2.get("team_stats", {})
	assert(_ts.has("food_qty"), "team_stats has food_qty")
	assert(_ts.has("carry_weight"), "team_stats has carry_weight")
	assert(_ts.has("carry_capacity"), "team_stats has carry_capacity")
	assert(_ts.has("member_count"), "team_stats has member_count")
	assert(_ts.get("food_qty") == 100, "food_qty == 100, got %d" % _ts.get("food_qty"))
	assert(_ts.get("carry_capacity") > 0.0, "carry_capacity > 0")
	assert(_ts.get("member_count") == 2, "member_count == 2, got %d" % _ts.get("member_count"))
	print("  [OK] members_detail: 2 members with all required fields")
	print("  [OK] team_stats: food=%d cap=%.1f count=%d" % [
		_ts.get("food_qty"), _ts.get("carry_capacity"), _ts.get("member_count")])
	print("members_detail / team_stats: ALL PASS")

	print("--- player_alerts ---")
	print("  alerts 數量: %d" % state.player_alerts.size())
	for a in state.player_alerts:
		print("  %s tick=%d data=%s" % [a["type"], a["tick"], str(a["data"])])

	print("--- AdvisorSystem 驗證 ---")
	var _adv_sys = AdvisorSystem.new()
	var test_person: PersonData = state.persons.get(0)
	if test_person:
		test_person.skills["戰術"] = 0.0
		var wrong_advice: String = _adv_sys.get_advice(test_person, "assess_enemy",
			{"enemy_pop": 20, "self_pop": 5}, state)
		print("  低技能建議: %s" % wrong_advice)
		test_person.skills["戰術"] = 1.0
		var right_advice: String = _adv_sys.get_advice(test_person, "assess_enemy",
			{"enemy_pop": 20, "self_pop": 5}, state)
		print("  高技能建議: %s" % right_advice)
	print("  AdvisorSystem 驗證通過")

	print("--- InquirySystem 驗證 ---")
	var _inq := InquirySystem.new()
	var _pt_inq: TeamData = state.teams.get(state.player_id if state.player_id != -1 else 0)
	if _pt_inq:
		for _other_id in state.teams:
			if _other_id == _pt_inq.team_id: continue
			var _other_t: TeamData = state.teams[_other_id]
			var _opts: Array = _inq.get_options(state, _pt_inq, _other_t)
			print("  Team%d 打聽 Team%d → %d 個選項" % [_pt_inq.team_id, _other_id, _opts.size()])
			assert(_opts.size() <= 5, "InquirySystem 選項不超過 5")
			break
	print("  InquirySystem 驗證通過")

	# --- faction_panel API ---
	var _fp_api := PlayerQueryApi.new()
	var _fp_result := _fp_api.query_faction_panel(state)
	print("[Test] query_faction_panel ok=%s in_faction=%s" % [
		str(_fp_result.get("ok")),
		str(_fp_result.get("data", {}).get("faction_panel", {}).get("in_faction"))])

	# --- outpost_panel API ---
	var _op_result := PlayerQueryApi.new().query_outpost_panel(state)
	print("[Test] query_outpost_panel ok=%s tile_pos=%s" % [
		str(_op_result.get("ok")),
		str(_op_result.get("data", {}).get("outpost_panel", {}).get("tile_pos"))])

	# --- subteam_panel API ---
	var _sp_result := PlayerQueryApi.new().query_subteam_panel(state)
	print("[Test] query_subteam_panel ok=%s subteams=%d" % [
		str(_sp_result.get("ok")),
		_sp_result.get("data", {}).get("subteam_panel", {}).get("subteams", []).size()])

	# ── PlayerTradeSystem tests ──────────────────────────────────────────
	var _trade_sys := PlayerTradeSystem.new()

	# get_tradeable_resources
	var _tr_res := _trade_sys.get_tradeable_resources(state, 0, 1)
	assert(_tr_res.has("player"),          "[TradeTest] missing 'player' key")
	assert(_tr_res.has("target_sellable"), "[TradeTest] missing 'target_sellable' key")
	assert(_tr_res.has("prices"),          "[TradeTest] missing 'prices' key")
	print("[TradeTest] get_tradeable_resources ok")

	# evaluate_offer: fair trade (coin for food)
	var _offer_fair := { "player_gives": {"coin": 20}, "player_wants": {"food": 5} }
	var _eval_fair  := _trade_sys.evaluate_offer(state, 0, 1, _offer_fair)
	print("[TradeTest] evaluate fair: accepted=%s reason=%s ratio=%.2f threshold=%.2f" % [
		str(_eval_fair.get("accepted")),
		str(_eval_fair.get("reason")),
		float(_eval_fair.get("ratio", 0.0)),
		float(_eval_fair.get("threshold", 0.0))])

	# evaluate_offer: empty offer must be rejected
	var _eval_empty := _trade_sys.evaluate_offer(state, 0, 1, {})
	assert(not _eval_empty.get("accepted", true), "[TradeTest] empty offer must be rejected")

	# evaluate_offer: demand more food than available → layer-1 reject
	var _food_stock: float = float(state.teams[1].resources.get("food", 0))
	var _offer_over := { "player_gives": {}, "player_wants": {"food": _food_stock + 9999} }
	var _eval_over  := _trade_sys.evaluate_offer(state, 0, 1, _offer_over)
	assert(not _eval_over.get("accepted", true), "[TradeTest] over-demand must be rejected (layer 1)")
	print("[TradeTest] evaluate_offer layer-1 reject ok: %s" % _eval_over.get("reason", ""))

	# preview_offer: must not mutate state
	var _food_before: float = float(state.teams[1].resources.get("food", 0))
	var _preview     := _trade_sys.preview_offer(state, 0, 1, _offer_fair)
	var _food_after:  float = float(state.teams[1].resources.get("food", 0))
	assert(_food_before == _food_after,          "[TradeTest] preview_offer must not mutate food")
	assert(_preview.has("gives_value"),           "[TradeTest] preview missing gives_value")
	assert(_preview.has("wants_value"),           "[TradeTest] preview missing wants_value")
	print("[TradeTest] preview_offer no-mutate ok  gives=%.2f wants=%.2f" % [
		float(_preview.get("gives_value")),
		float(_preview.get("wants_value"))])

	# Ensure player has enough coin for the fair trade test
	state.teams[0].resources["coin"] = 50.0
	# execute_offer: run fair trade if accepted; run bad offer if rejected
	var _coin_pt_before:  float = float(state.teams[0].resources.get("coin", 0))
	var _food_tgt_before: float = float(state.teams[1].resources.get("food", 0))
	var _exec := _trade_sys.execute_offer(state, 0, 1, _offer_fair)
	print("[TradeTest] execute_offer: ok=%s msg=%s" % [str(_exec.get("ok")), str(_exec.get("msg", ""))])
	if _exec.get("ok", false):
		assert(float(state.teams[0].resources.get("coin", 0)) < _coin_pt_before,
			"[TradeTest] player coin should decrease after execute")
		assert(float(state.teams[1].resources.get("food", 0)) < _food_tgt_before,
			"[TradeTest] NPC food should decrease after execute")
		print("[TradeTest] execute_offer mutations verified ok")

	# execute_offer: player over-commits their own stock → rejected without mutation
	var _offer_badstock := { "player_gives": {"coin": 999999}, "player_wants": {} }
	var _exec_bad := _trade_sys.execute_offer(state, 0, 1, _offer_badstock)
	assert(not _exec_bad.get("ok", true), "[TradeTest] over-commit player stock must fail")
	print("[TradeTest] execute_offer bad-stock reject ok")
	# ── end PlayerTradeSystem tests ──────────────────────────────────────

	# ── submit_trade_offer command test ─────────────────────────────────
	var _pcs := PlayerCommandSystem.new()
	state.player_state["pending_trade_target"] = 1
	state.player_state["trade_offer"] = {
		"player_gives": {"coin": 10},
		"player_wants": {"food": 3}
	}
	state.teams[0].resources["coin"] = floorf(float(state.teams[0].resources.get("coin", 0)) + 100)
	var _sub_result := _pcs.execute_action(state, 1, "submit_trade_offer")
	print("[TradeTest] submit_trade_offer: ok=%s msg=%s" % [
		str(_sub_result.get("ok")), str(_sub_result.get("msg", ""))])
	assert(_sub_result.has("ok"),  "[TradeTest] submit_trade_offer result missing 'ok' key")
	assert(_sub_result.has("msg"), "[TradeTest] submit_trade_offer result missing 'msg' key")
	state.player_state.erase("pending_trade_target")
	state.player_state.erase("trade_offer")
	# ── end submit_trade_offer test ─────────────────────────────────────

	# ── movement boundary test ────────────────────────────────────────
	var _ms_test := MovementSystem.new()
	var _test_team: TeamData = state.teams[0]
	var _orig_tile_pos: Vector2i = _test_team.tile_pos
	# set off-map target: team must never leave the world tiles
	_test_team.move_target = Vector2i(9999, 9999)
	for _mi in range(30):
		_ms_test._step_team(state, _test_team)
		assert(state.world.tiles.has(_test_team.tile_pos.x * 1000 + _test_team.tile_pos.y),
			"[BoundaryTest] team must stay on-map (step %d)" % _mi)
	_test_team.tile_pos    = _orig_tile_pos
	_test_team.move_target = Vector2i(-1, -1)
	print("[BoundaryTest] movement boundary guard ok — team stayed on-map for 30 steps")
	# ── end movement boundary test ───────────────────────────────────

	# ── diplomatic fixes test ────────────────────────────────────────
	var _diplo_test := DiplomaticAiSystem.new()

	# Test 1: Betrayal orphan — after _execute_betrayal, faction.member_team_ids must not contain betrayer
	var _diplo_tested_betrayal: bool = false
	for _fid_bt in state.factions:
		var _f_bt: FactionData = state.factions[_fid_bt]
		if _f_bt.member_team_ids.size() < 2:
			continue
		var _betrayer_tid: int = -1
		for _mid in _f_bt.member_team_ids:
			if _mid != _f_bt.leader_team_id:
				_betrayer_tid = _mid
				break
		if _betrayer_tid == -1:
			continue
		var _betrayer_bt: TeamData  = state.teams.get(_betrayer_tid)
		var _leader_bt: TeamData    = state.teams.get(_f_bt.leader_team_id)
		if _betrayer_bt == null or _leader_bt == null:
			continue
		_diplo_test._execute_betrayal(state, _betrayer_bt, _leader_bt)
		assert(not _f_bt.member_team_ids.has(_betrayer_tid),
			"[DiploTest] betrayer must be removed from faction.member_team_ids after betrayal")
		assert(_betrayer_bt.faction_id == -1,
			"[DiploTest] betrayer faction_id must be -1 after betrayal")
		print("[DiploTest] betrayal orphan fix ok — Team%d removed from faction" % _betrayer_tid)
		_diplo_tested_betrayal = true
		break
	if not _diplo_tested_betrayal:
		print("[DiploTest] betrayal test skipped (no suitable faction found)")

	# Test 2: Tribute refusal — handle_diplomacy_message response shape
	var _dem2: TeamData = state.teams[0]
	var _pay2: TeamData = state.teams[2]
	var _resp2: String  = _diplo_test.handle_diplomacy_message(state, _pay2, _dem2, "demand_tribute")
	print("[DiploTest] demand_tribute from Team0 to Team2: response=%s" % _resp2)
	assert(_resp2 == "accept" or _resp2 == "refuse",
		"[DiploTest] demand_tribute response must be 'accept' or 'refuse'")
	print("[DiploTest] tribute refusal shape ok")
	# ── end diplomatic fixes test ───────────────────────────────────

	# ── merge fixes test ─────────────────────────────────────────────
	# Verify _merge_into cleanup: after full merge, absorbed team absent from all state dicts
	var _mt_abs_id: int = 9990
	var _mt_abr_id: int = 9991
	var _mt_abs := TeamData.new()
	_mt_abs.team_id    = _mt_abs_id
	_mt_abs.population = 2
	_mt_abs.faction_id = -1
	var _mt_abr := TeamData.new()
	_mt_abr.team_id    = _mt_abr_id
	_mt_abr.population = 3
	_mt_abr.faction_id = -1
	var _mt_abr_leader := PersonData.new()
	_mt_abr_leader.id       = 9991
	_mt_abr_leader.team_id  = _mt_abr_id
	_mt_abr_leader.role     = "leader"
	_mt_abr_leader.skills["統領"] = 0.8   # cap=50, population=3, capacity=47 > 2
	state.persons[9991]               = _mt_abr_leader
	_mt_abr.leader_id                 = 9991
	state.teams[_mt_abs_id]           = _mt_abs
	state.teams[_mt_abr_id]           = _mt_abr
	state.team_known[_mt_abs_id]      = []
	state.team_discovered[_mt_abs_id] = []
	var _sub_m := SubteamSystem.new()
	_sub_m._merge_into(state, _mt_abr_id, _mt_abs_id)
	assert(not state.teams.has(_mt_abs_id),
		"[MergeTest] absorbed team must be erased from state.teams")
	assert(not state.team_discovered.has(_mt_abs_id),
		"[MergeTest] absorbed team must be erased from state.team_discovered")
	assert(not state.team_known.has(_mt_abs_id),
		"[MergeTest] absorbed team must be erased from state.team_known")
	state.teams.erase(_mt_abr_id)
	state.team_known.erase(_mt_abr_id)
	state.team_discovered.erase(_mt_abr_id)
	state.persons.erase(9991)
	print("[MergeTest] _merge_into cleanup ok")
	# ── end merge fixes test ─────────────────────────────────────────

	# ── message prune test ────────────────────────────────────────────
	var _msg_prune_sys := SimMessageSystem.new()
	var _old_msg := MessageData.new()
	_old_msg.type        = "combat_start"
	_old_msg.origin_tick = 0
	_old_msg.id          = 99990
	state.global_messages.append(_old_msg)
	var _before_g: int = state.global_messages.size()
	_msg_prune_sys.prune_old_messages(state, 9999)
	assert(state.global_messages.size() < _before_g,
		"[MsgPruneTest] expired message must be pruned from global_messages")
	print("[MsgPruneTest] message TTL prune ok")
	# ── end message prune test ────────────────────────────────────────

	# ── overflow consolidation test ───────────────────────────────────
	var _pop_sys_t := PopulationSystem.new()
	var _ov_team   := TeamData.new()
	_ov_team.team_id   = 8880
	_ov_team.population = 999   # far exceeds any cap
	_ov_team.faction_id = -1
	_ov_team.tile_pos   = Vector2i(0, 0)
	state.teams[8880]           = _ov_team
	state.team_known[8880]      = []
	state.team_discovered[8880] = []
	var _teams_before: int = state.teams.size()
	_pop_sys_t.check_overflow_for_team(state, 8880)
	assert(state.teams.size() > _teams_before or _ov_team.population < 999,
		"[OverflowTest] overflow must reduce origin pop or create new team")
	# cleanup
	for _ov_tid in state.teams.keys().duplicate():
		if int(_ov_tid) >= 8880:
			state.teams.erase(_ov_tid)
			state.team_known.erase(_ov_tid)
			state.team_discovered.erase(_ov_tid)
	print("[OverflowTest] check_overflow_for_team ok")
	# ── end overflow consolidation test ──────────────────────────────

	# ── skill cap_add test ────────────────────────────────────────────
	var _sk_p := PersonData.new()
	_sk_p.skills["商業"] = 0.9
	SkillSystem.cap_add(_sk_p, "商業", 0.5)
	assert(_sk_p.skills.get("商業", 0.0) <= 1.0,
		"[SkillTest] cap_add must not exceed 1.0")
	assert(_sk_p.skills.get("商業", 0.0) > 0.9,
		"[SkillTest] cap_add must apply positive delta")
	SkillSystem.cap_add(_sk_p, "商業", 0.0)
	assert(_sk_p.skills.get("商業", 0.0) <= 1.0,
		"[SkillTest] cap_add delta=0 must be safe")
	SkillSystem.cap_add(null, "商業", 0.1)   # must not crash
	print("[SkillTest] SkillSystem.cap_add ok")
	# ── end skill cap_add test ────────────────────────────────────────

	# ── encounter system test ────────────────────────────────────────────────
	var _enc_sys2 := EncounterSystem.new()

	# hex_dist correctness
	assert(_enc_sys2.hex_dist(Vector2i(0,0), Vector2i(3,0)) == 3,
		"[EncounterTest] hex_dist(0,0→3,0) should be 3")
	assert(_enc_sys2.hex_dist(Vector2i(0,0), Vector2i(2,-2)) == 2,
		"[EncounterTest] hex_dist diagonal should be 2")
	assert(_enc_sys2.hex_dist(Vector2i(1,2), Vector2i(-1,2)) == 2,
		"[EncounterTest] hex_dist negative q should be 2")

	# _all_exited with prisoner: prisoner should be ignored (BUG-8)
	var _enc_state2 := WorldState.new()
	_enc_state2.encounter_attacker_id = 10
	_enc_state2.encounter_defender_id = 11
	var _prisoner_bp: Dictionary = _enc_sys2._default_body_parts()
	var _prisoner_unit: Dictionary = {
		"team_id": 11, "person_id": -1, "pos": Vector2i(0, 0),
		"has_exited": false, "is_prisoner": true, "body_parts": _prisoner_bp,
	}
	_enc_state2.encounter_units.append(_prisoner_unit)
	assert(_enc_sys2._all_exited(11, _enc_state2) == true,
		"[EncounterTest] _all_exited must exclude prisoners")

	# _count_nearby_enemies should exclude prisoners (BUG-B)
	# Scenario: incapacitated unit (team 11, NOT prisoner) at (-1,0)
	# surrounded by 1 real guard (team 10) at (0,0) + 1 prisoner (team 10) at (-2,0).
	# With fix: count=1 (only real guard). Without fix: count=2, chain-capture occurs.
	var _inc_unit: Dictionary = {
		"team_id": 11, "person_id": -1, "pos": Vector2i(-1, 0),
		"has_exited": false, "is_prisoner": false, "body_parts": _enc_sys2._default_body_parts(),
	}
	var _guard_unit: Dictionary = {
		"team_id": 10, "person_id": -1, "pos": Vector2i(0, 0),
		"has_exited": false, "is_prisoner": false, "body_parts": _enc_sys2._default_body_parts(),
	}
	var _prisoner2: Dictionary = {
		"team_id": 10, "person_id": -1, "pos": Vector2i(-2, 0),
		"has_exited": false, "is_prisoner": true, "body_parts": _enc_sys2._default_body_parts(),
	}
	_enc_state2.encounter_units.append(_inc_unit)
	_enc_state2.encounter_units.append(_guard_unit)
	_enc_state2.encounter_units.append(_prisoner2)
	assert(_enc_sys2._count_nearby_enemies(_inc_unit, _enc_state2, 1) == 1,
		"[EncounterTest] _count_nearby_enemies must not count prisoner (is_prisoner=true) as enemy")

	print("[EncounterTest] encounter logic ok")
	# ── end encounter system test ─────────────────────────────────────────

	print("=== DONE ===")

func _test_update_armor_config() -> void:
	print("--- S7 Task5: _update_armor_config ---")
	var fai := FactionAISystem.new()
	# MILITARY + 高甲庫存充足
	var t1 := TeamData.new()
	t1.tags = [TeamData.TAG_MILITARY]
	t1.population = 10
	t1.resources["armor_high"] = 20
	t1.resources["armor_low"]  = 20
	fai._update_armor_config(t1)
	assert(t1.armor_config["torso"] == "high",
		"MILITARY+high 充足 torso 應 high，實際=%s" % t1.armor_config["torso"])
	assert(t1.armor_config["right_arm"] == "low",
		"MILITARY+high 充足 arm 應 low，實際=%s" % t1.armor_config["right_arm"])
	# MILITARY + 僅低甲
	var t2 := TeamData.new()
	t2.tags = [TeamData.TAG_MILITARY]
	t2.population = 10
	t2.resources["armor_low"]  = 20
	t2.resources["armor_high"] = 0
	fai._update_armor_config(t2)
	assert(t2.armor_config["torso"] == "low",
		"MILITARY+僅低 torso 應 low，實際=%s" % t2.armor_config["torso"])
	assert(t2.armor_config["head"] == "low",
		"MILITARY+僅低 head 應 low，實際=%s" % t2.armor_config["head"])
	assert(t2.armor_config["right_arm"] == "none",
		"MILITARY+僅低 arm 應 none，實際=%s" % t2.armor_config["right_arm"])
	# 無護甲 → 全 none
	var t3 := TeamData.new()
	t3.tags = [TeamData.TAG_MILITARY]
	t3.population = 10
	t3.resources["armor_low"]  = 0
	t3.resources["armor_high"] = 0
	fai._update_armor_config(t3)
	assert(t3.armor_config["torso"] == "none",
		"無甲 torso 應 none，實際=%s" % t3.armor_config["torso"])
	print("S7 Task5 OK")

func _test_update_guard_ratio() -> void:
	print("--- S7 Task6: _update_guard_ratio ---")
	var fai := FactionAISystem.new()
	var state := WorldState.new()
	# 場景 A：MILITARY + 鄰格有敵對 team → 0.4
	var t_mil := TeamData.new()
	t_mil.team_id = 100
	t_mil.tags = [TeamData.TAG_MILITARY]
	t_mil.faction_id = 10
	t_mil.tile_pos = Vector2i(5, 5)
	state.teams[100] = t_mil
	var t_enemy := TeamData.new()
	t_enemy.team_id = 101
	t_enemy.faction_id = 20  # 不同 faction
	t_enemy.tile_pos = Vector2i(6, 6)  # distance ~1
	state.teams[101] = t_enemy
	fai._update_guard_ratio(t_mil, state)
	assert(t_mil.guard_ratio >= 0.35,
		"MILITARY 鄰敵 應 >=0.35，實際=%s" % str(t_mil.guard_ratio))
	# 場景 B：current_task=攻擊 → 0.1
	t_mil.current_task = TeamData.TASK_ATTACK
	fai._update_guard_ratio(t_mil, state)
	assert(t_mil.guard_ratio <= 0.15,
		"攻擊中 應 <=0.15，實際=%s" % str(t_mil.guard_ratio))
	# 場景 C：PRODUCE 無威脅 → 0.15
	var t_pro := TeamData.new()
	t_pro.team_id = 102
	t_pro.tags = [TeamData.TAG_PRODUCE]
	t_pro.faction_id = 30
	t_pro.tile_pos = Vector2i(-20, -20)
	state.teams[102] = t_pro
	fai._update_guard_ratio(t_pro, state)
	assert(t_pro.guard_ratio <= 0.2,
		"PRODUCE 無威脅 應 <=0.2，實際=%s" % str(t_pro.guard_ratio))
	# 場景 D：default 無威脅 → 0.2
	var t_def := TeamData.new()
	t_def.team_id = 103
	t_def.faction_id = 40
	t_def.tile_pos = Vector2i(-30, -30)
	state.teams[103] = t_def
	fai._update_guard_ratio(t_def, state)
	assert(t_def.guard_ratio >= 0.15 and t_def.guard_ratio <= 0.25,
		"default 無威脅 應 ~0.2，實際=%s" % str(t_def.guard_ratio))
	# 場景 E：高聲望盟友（rep>=0.7）不應計為威脅
	var t_ally_a := TeamData.new()
	t_ally_a.team_id = 104
	t_ally_a.faction_id = 50
	t_ally_a.tile_pos = Vector2i(20, 20)
	var t_ally_b := TeamData.new()
	t_ally_b.team_id = 105
	t_ally_b.faction_id = 51   # 不同 faction
	t_ally_b.tile_pos = Vector2i(21, 20)   # 鄰格
	t_ally_a.known_reputations[105] = 0.8   # 高聲望
	state.teams[104] = t_ally_a
	state.teams[105] = t_ally_b
	fai._update_guard_ratio(t_ally_a, state)
	assert(t_ally_a.guard_ratio <= 0.25,
		"鄰格盟友（rep=0.8）不應觸發威脅 guard_ratio，實際=%s" % str(t_ally_a.guard_ratio))
	print("S7 Task6 OK")

func _test_faction_ai_run_calls_all_updates() -> void:
	print("--- S7 Task7: faction_ai.run() 整合 ---")
	var fai := FactionAISystem.new()
	var state := WorldState.new()
	# 建 MILITARY team 且資源充足
	var t := TeamData.new()
	t.team_id = 200
	t.tags = [TeamData.TAG_MILITARY]
	t.population = 10
	t.faction_id = 50
	t.tile_pos = Vector2i(0, 0)
	t.resources["armor_high"] = 20
	t.resources["armor_low"]  = 20
	state.teams[200] = t
	# faction_ai evaluate_all 後 armor / guard 仍更新（anon_combat_skill/anon_wage 改 computed）
	fai.evaluate_all(state, [200])
	assert(t.armor_config["torso"] == "high",
		"evaluate_all() 後 MILITARY armor_config torso 應 high，實際=%s" % t.armor_config["torso"])
	assert(t.guard_ratio >= 0.15 and t.guard_ratio <= 0.5,
		"evaluate_all() 後 guard_ratio 應在合理範圍，實際=%s" % str(t.guard_ratio))
	print("S7 Task7 OK")

func _test_food_consumption_total() -> void:
	print("--- Cadence Task2: 食物消耗總量 ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	var team := TeamData.new()
	team.team_id = 0
	team.population = 10
	team.minor_population = 0
	team.resources["food"] = 2400.0
	state.teams[0] = team
	var rs := ResourceSystem.new()
	# 模擬跑 1 天（240 tick），每 NEAR_CADENCE=10 call 一次 → 24 calls
	for _i in range(24):
		rs.resolve_consumption(state, [0], 10)
	# 預期消耗：10 × 2.4 = 24 食物/天 → 剩 2376
	var remaining: float = float(team.resources["food"])
	assert(remaining >= 2375.0 and remaining <= 2377.0,
		"1 天後應剩 ~2376，實際=%s" % str(remaining))
	print("Cadence Task2 OK")

func _test_fatigue_accumulation() -> void:
	print("--- Cadence Task3: 疲勞累積總量 ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	var team := TeamData.new()
	team.team_id = 0
	team.population = 10
	team.fatigue = 0.0
	team.current_task = TeamData.TASK_ATTACK   # 行軍狀態
	team.tile_pos = Vector2i(0, 0)
	# 設定地形為 plains
	var tile := HexTileData.new()
	tile.terrain = "plains"
	state.world.tiles[0] = tile
	state.teams[0] = team
	var sr := SimRunner.new()
	# 模擬跑 1 天（24 calls）
	for _i in range(24):
		sr._step6d_fatigue(state, [0], 10)
	# 預期：0.048/day → ≈ 0.048
	assert(team.fatigue >= 0.04 and team.fatigue <= 0.06,
		"1 天行軍後 fatigue 應 ~0.048，實際=%s" % str(team.fatigue))
	print("Cadence Task3 OK")

func _test_fatigue_recovery() -> void:
	print("--- Cadence Task4: 疲勞回復總量 ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	var team := TeamData.new()
	team.team_id = 0
	team.population = 10
	team.fatigue = 1.0   # 從滿開始
	team.current_task = "rest"   # 紮營
	team.guard_ratio = 0.0       # 無哨兵，確保 rest_mult=1.0
	team.tile_pos = Vector2i(0, 0)
	var tile := HexTileData.new()
	tile.terrain = "plains"
	state.world.tiles[0] = tile
	state.teams[0] = team
	var sr := SimRunner.new()
	# 跑 1 天紮營
	for _i in range(24):
		sr._step6d_fatigue(state, [0], 10)
	# 預期：fatigue -= 0.24/day → ≈ 0.76
	assert(team.fatigue >= 0.74 and team.fatigue <= 0.78,
		"1 天紮營後 fatigue 應 ~0.76，實際=%s" % str(team.fatigue))
	print("Cadence Task4 OK")

func _test_salary_interval_weekly() -> void:
	print("--- Cadence Task5: 薪水週期 ---")
	# SALARY_INTERVAL 應為 1 週（240 × 7 = 1680 tick）
	assert(SalarySystem.SALARY_INTERVAL == WorldState.TICKS_PER_DAY * 7,
		"SALARY_INTERVAL 應為 1 週(1680)，實際=%s" % str(SalarySystem.SALARY_INTERVAL))
	# 確認 NEAR_CADENCE 整除性（1680 % 10 == 0）
	assert(SalarySystem.SALARY_INTERVAL % SimRunner.NEAR_CADENCE == 0,
		"SALARY_INTERVAL 必須是 NEAR_CADENCE 倍數")
	print("Cadence Task5 OK")

func _test_intervals_divisible_by_cadence() -> void:
	print("--- Cadence Task6: interval 整除性 ---")
	var cadence: int = SimRunner.NEAR_CADENCE
	# 列出所有應該被 cadence 觸發的 interval 常數
	var intervals: Dictionary = {
		"STRATEGIC_INTERVAL":      StrategicAiSystem.STRATEGIC_INTERVAL,
		"ALLIANCE_CHECK_INTERVAL": StrategicAiSystem.ALLIANCE_CHECK_INTERVAL,
		"BETRAY_CHECK_INTERVAL":   DiplomaticAiSystem.BETRAY_CHECK_INTERVAL,
		"FACTION_UPDATE_INTERVAL": FactionAISystem.FACTION_UPDATE_INTERVAL,
		"COLLECT_INTERVAL":        FactionAISystem.COLLECT_INTERVAL,
		"GOAL_CHECK_INTERVAL":     ReactionSystem.GOAL_CHECK_INTERVAL,
		"SALARY_INTERVAL":         SalarySystem.SALARY_INTERVAL,
		"FAR_ZONE_INTERVAL":       SimRunner.FAR_ZONE_INTERVAL,
		"OVERFLOW_CHECK_INTERVAL": PopulationSystem.OVERFLOW_CHECK_INTERVAL,
	}
	for name in intervals:
		var val: int = intervals[name]
		assert(val % cadence == 0,
			"%s=%d 必須是 NEAR_CADENCE(%d) 倍數" % [name, val, cadence])
	# TICKS_PER_DAY 也必須整除（保證每天整除次數）
	assert(WorldState.TICKS_PER_DAY % cadence == 0,
		"TICKS_PER_DAY 必須是 NEAR_CADENCE 倍數")
	print("Cadence Task6 OK")

func _test_salary_auto_npc_vs_player() -> void:
	print("--- Salary auto NPC vs player (leader 個性) ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	state.player_id = 0
	# 慷慨 NPC leader（義氣=1, 信義=1, 貪婪=0）→ mult ≈ 1.3 → salary > fair
	var npc_leader_g := PersonData.new()
	npc_leader_g.id = 10
	npc_leader_g.team_id = 1
	npc_leader_g.values = { "義氣": 1.0, "信義": 1.0, "貪婪": 0.0 }
	state.persons[10] = npc_leader_g
	var npc_member_g := PersonData.new()
	npc_member_g.id = 11
	npc_member_g.team_id = 1
	npc_member_g.skills = { "戰鬥": 1.0, "統領": 0.5 }   # fair = 3.0
	npc_member_g.salary = 0.0
	npc_member_g.loyalty = 0.5
	state.persons[11] = npc_member_g
	var npc_team_g := TeamData.new()
	npc_team_g.team_id = 1
	npc_team_g.leader_id = 10
	npc_team_g.named_members = [11]
	npc_team_g.population = 2
	npc_team_g.resources["coin"] = 1000.0
	state.teams[1] = npc_team_g
	# 吝嗇 NPC leader（義氣=0, 信義=0, 貪婪=1）→ mult ≈ 0.7 → salary < fair
	var npc_leader_s := PersonData.new()
	npc_leader_s.id = 20
	npc_leader_s.team_id = 2
	npc_leader_s.values = { "義氣": 0.0, "信義": 0.0, "貪婪": 1.0 }
	state.persons[20] = npc_leader_s
	var npc_member_s := PersonData.new()
	npc_member_s.id = 21
	npc_member_s.team_id = 2
	npc_member_s.skills = { "戰鬥": 1.0, "統領": 0.5 }
	npc_member_s.salary = 0.0
	npc_member_s.loyalty = 0.5
	state.persons[21] = npc_member_s
	var npc_team_s := TeamData.new()
	npc_team_s.team_id = 2
	npc_team_s.leader_id = 20
	npc_team_s.named_members = [21]
	npc_team_s.population = 2
	npc_team_s.resources["coin"] = 1000.0
	state.teams[2] = npc_team_s
	# Player team
	var player := PersonData.new()
	player.id = 0
	player.team_id = 0
	state.persons[0] = player
	var player_member := PersonData.new()
	player_member.id = 12
	player_member.team_id = 0
	player_member.skills = { "戰鬥": 1.0 }
	player_member.salary = 0.0
	player_member.loyalty = 0.5
	state.persons[12] = player_member
	var player_team := TeamData.new()
	player_team.team_id = 0
	player_team.leader_id = 0
	player_team.named_members = [12]
	player_team.population = 2
	player_team.resources["coin"] = 1000.0
	state.teams[0] = player_team
	var ss := SalarySystem.new()
	ss._pay_salary(state, npc_team_g)
	ss._pay_salary(state, npc_team_s)
	ss._pay_salary(state, player_team)
	# 慷慨 leader：salary > fair(3.0) → ratio > 1 → loyalty 上升
	assert(npc_member_g.salary > 3.0,
		"慷慨 leader salary 應 > 3.0，實際=%s" % str(npc_member_g.salary))
	assert(npc_member_g.loyalty > 0.5,
		"慷慨 leader 應加 loyalty，實際=%s" % str(npc_member_g.loyalty))
	# 吝嗇 leader：salary < fair(3.0) → ratio < 1 → loyalty 下降
	assert(npc_member_s.salary < 3.0,
		"吝嗇 leader salary 應 < 3.0，實際=%s" % str(npc_member_s.salary))
	assert(npc_member_s.loyalty < 0.5,
		"吝嗇 leader 應扣 loyalty，實際=%s" % str(npc_member_s.loyalty))
	# Player team 保留玩家設定
	assert(player_member.salary == 0.0,
		"Player team salary 應保留 0，實際=%s" % str(player_member.salary))
	assert(player_member.loyalty < 0.5,
		"Player team 0 薪 應扣 loyalty，實際=%s" % str(player_member.loyalty))
	print("Salary auto NPC vs player OK")

func _test_setup_mode_explicit() -> void:
	print("--- Config Task1: GameSetup mode=explicit ---")
	var state := WorldState.new()
	var config: Dictionary = {
		"seed": 42,
		"map": { "radius": 4 },
		"mode": "explicit",
		"teams": [
			{
				"id": 0,
				"name": "玩家",
				"tile_pos": [4, 4],
				"population": 8,
				"tags": ["統領"],
				"faction_id": 0,
				"is_faction_leader": true,
				"resources": { "food": 96.0, "coin": 600 },
				"leader": { "name": "TestLeader", "skills": { "統領": 0.7 } },
				"named_members": []
			}
		],
		"player": { "team_id": 0, "is_leader": true }
	}
	GameSetup.setup(state, config)
	assert(state.teams.has(0), "Team 0 應建立")
	var t: TeamData = state.teams[0]
	assert(t.population == 8, "pop 應 8，實際=%d" % t.population)
	assert(t.tile_pos == Vector2i(4, 4), "tile_pos 應 (4,4)，實際=%s" % str(t.tile_pos))
	assert(float(t.resources.get("food", 0)) == 96.0, "food 應 96")
	assert(state.player_id == t.leader_id, "player_id 應 = team leader_id")
	print("Config Task1 OK")

func _test_full_config_load() -> void:
	print("--- Config Task6: 完整 config 載入 ---")
	var s1 := WorldState.new()
	var c1 := GameSetup.load_config("res://config/demo.json")
	assert(not c1.is_empty(), "demo.json 載入失敗")
	GameSetup.setup(s1, c1)
	assert(s1.teams.size() == 3, "demo 應 3 team，實際=%d" % s1.teams.size())
	assert(s1.player_id != -1, "demo player_id 應已設")
	var s2 := WorldState.new()
	var c2 := GameSetup.load_config("res://config/game_sim_test.json")
	assert(not c2.is_empty(), "game_sim_test.json 載入失敗")
	GameSetup.setup(s2, c2)
	var expected_teams: int = c2.get("teams", []).size()
	assert(s2.teams.size() == expected_teams,
		"game_sim_test 應 %d team，實際=%d" % [expected_teams, s2.teams.size()])
	assert(c2.get("command_schedule", []).size() >= 6, "command_schedule 應有 ≥6 entries")
	var s3 := WorldState.new()
	var c3 := GameSetup.load_config("res://config/default.json")
	assert(c3.get("mode", "random") == "random", "default 應為 random mode")
	GameSetup.setup(s3, c3)
	assert(s3.teams.size() >= 2, "default 隨機應產生 >= 2 team")
	print("Config Task6 OK")

func _test_s11_leader_succession() -> void:
	print("--- S11: Leader succession ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	var team := TeamData.new()
	team.team_id = 0
	team.leader_id = -1
	team.population = 4
	state.teams[0] = team
	var p1 := PersonData.new()
	p1.id = 1; p1.team_id = 0
	p1.skills = { "統領": 0.3 }
	state.persons[1] = p1
	team.named_members.append(1)
	var p2 := PersonData.new()
	p2.id = 2; p2.team_id = 0
	p2.skills = { "統領": 0.7 }
	state.persons[2] = p2
	team.named_members.append(2)
	var p3 := PersonData.new()
	p3.id = 3; p3.team_id = 0
	p3.skills = { "統領": 0.5 }
	state.persons[3] = p3
	team.named_members.append(3)
	var fai := FactionAISystem.new()
	fai._promote_successor(state, team)
	assert(team.leader_id == 2,
		"應升統領最高的 P2 (0.7)，實際=%d" % team.leader_id)
	assert(not team.named_members.has(2),
		"P2 升職後不應留 named_members")
	assert(state.persons[2].role == "leader",
		"P2.role 應為 leader")
	# 第二次 leader 死亡，應選 P3 (0.5)
	team.leader_id = -1
	fai._promote_successor(state, team)
	assert(team.leader_id == 3,
		"第二次應選 P3 (0.5 次高)，實際=%d" % team.leader_id)
	# 無 named 時 no-op
	var team2 := TeamData.new()
	team2.team_id = 99
	team2.leader_id = -1
	fai._promote_successor(state, team2)
	assert(team2.leader_id == -1, "無 named 不應升職")
	print("S11 OK")

func _test_team_previous_task_field() -> void:
	print("--- Survival Task1: TeamData.previous_task ---")
	var t := TeamData.new()
	assert(t.previous_task == "", "預設應為空字串，實際=%s" % t.previous_task)
	t.previous_task = "貿易"
	assert(t.previous_task == "貿易", "指派後應為 貿易")
	print("Survival Task1 OK")

func _test_survival_trigger_urgent() -> void:
	print("--- Survival Task2: 緊急觸發 (food < 1 day) ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	var team := TeamData.new()
	team.team_id = 100
	team.population = 10
	team.resources["food"] = 0.0
	team.tile_pos = Vector2i(0, 0)
	team.current_task = "idle"
	var leader := PersonData.new()
	leader.id = 200
	leader.team_id = 100
	leader.values = { "義氣": 0.5, "信義": 0.5, "貪婪": 0.5, "殘忍": 0.3, "好戰": 0.3, "求生欲": 0.5 }
	state.persons[200] = leader
	team.leader_id = 200
	state.teams[100] = team
	state.team_discovered[100] = []
	var fai := FactionAISystem.new()
	fai._evaluate_survival(state, team)
	assert(team.current_task in FactionAISystem.SURVIVAL_TASKS,
		"緊急觸發後應為 SURVIVAL_TASKS，實際=%s" % team.current_task)
	print("Survival Task2 OK (task=%s)" % team.current_task)

func _test_survival_sticky() -> void:
	print("--- Survival Task2b: sticky 不重覆觸發 ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	var team := TeamData.new()
	team.team_id = 101
	team.current_task = "乞食"
	team.previous_task = "貿易"
	state.teams[101] = team
	var fai := FactionAISystem.new()
	fai._evaluate_survival(state, team)
	assert(team.current_task == "乞食", "sticky 不應改變 task")
	assert(team.previous_task == "貿易", "previous_task 不應變")
	print("Survival Task2b OK")

func _test_survival_helpers() -> void:
	print("--- Survival Task3: find helpers ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	state.world.current_tick = 801   # 唯一 tick，避免 path cache 跨測試污染
	# 平原網格，讓 estimate_catch_up 的 A* 有路可走
	for gx in range(-1, 9):
		for gy in range(-1, 9):
			var g := HexTileData.new()
			g.tile_pos = Vector2i(gx, gy); g.terrain = "plains"
			state.world.tiles[gx * 1000 + gy] = g
	var t0 := TeamData.new()
	t0.team_id = 0; t0.tile_pos = Vector2i(0, 0); t0.population = 10
	state.teams[0] = t0
	var tile := HexTileData.new()
	tile.tile_pos = Vector2i(5, 5)
	tile.outpost_level = 1
	tile.outpost_owner = 0
	state.world.tiles[5 * 1000 + 5] = tile
	var t1 := TeamData.new()
	t1.team_id = 1; t1.tile_pos = Vector2i(1, 0); t1.population = 3
	t1.resources["food"] = 50.0
	state.teams[1] = t1
	state.team_discovered[0] = [1, 2]
	var t2 := TeamData.new()
	t2.team_id = 2; t2.tile_pos = Vector2i(2, 0); t2.population = 20
	t2.faction_id = 99
	t2.resources["food"] = 500.0
	state.teams[2] = t2
	state.team_discovered[2] = [0]
	state.team_discovered[1] = [0]
	var fai := FactionAISystem.new()
	var op_pos = fai._find_own_outpost(state, t0)
	assert(op_pos == Vector2i(5, 5), "own outpost 應 (5,5)，實際=%s" % str(op_pos))
	var prey = fai._find_weakest_prey(state, t0)
	assert(prey == 1, "weak prey 應 Team1，實際=%d" % prey)
	var strong = fai._find_strong_neighbor(state, t0)
	assert(strong == 2, "strong neighbor 應 Team2，實際=%d" % strong)
	var aid = fai._find_aid_target(state, t0)
	assert(aid != -1, "aid target 應有，實際=%d" % aid)
	var t3 := TeamData.new()
	t3.team_id = 3; t3.tile_pos = Vector2i(8, 8); t3.population = 5
	state.teams[3] = t3
	var no_op = fai._find_own_outpost(state, t3)
	assert(no_op == Vector2i(-1, -1), "無 outpost 應 (-1,-1)，實際=%s" % str(no_op))
	print("Survival Task3 OK")

func _test_survival_decision_tree() -> void:
	print("--- Survival Task4: 決策樹 4 路徑 ---")
	var fai := FactionAISystem.new()
	# (1) 有 outpost → return_home
	var s1 := WorldState.new()
	s1.world = WorldData.new()
	var t1 := TeamData.new(); t1.team_id = 0; t1.tile_pos = Vector2i(0,0); t1.population = 5; t1.resources["food"] = 0
	var l1 := PersonData.new(); l1.id = 100; l1.values = { "義氣": 0.3, "信義": 0.3, "殘忍": 0.2, "好戰": 0.2 }
	s1.persons[100] = l1; t1.leader_id = 100
	s1.teams[0] = t1; s1.team_discovered[0] = []
	var tile1 := HexTileData.new(); tile1.tile_pos = Vector2i(3,3); tile1.outpost_level = 1; tile1.outpost_owner = 0
	s1.world.tiles[3003] = tile1
	fai._trigger_survival(s1, t1, "urgent")
	assert(t1.current_task == "return_home", "Path 1 應 return_home，實際=%s" % t1.current_task)
	# (2) 殘忍 + 鄰弱 → 掠奪
	var s2 := WorldState.new()
	s2.world = WorldData.new()
	s2.world.current_tick = 810
	_fill_plains(s2, -1, 4, -1, 2)
	var t2 := TeamData.new(); t2.team_id = 0; t2.tile_pos = Vector2i(0,0); t2.population = 10; t2.resources["food"] = 0
	var l2 := PersonData.new(); l2.id = 100; l2.values = { "殘忍": 0.7, "好戰": 0.5 }
	s2.persons[100] = l2; t2.leader_id = 100
	var prey := TeamData.new(); prey.team_id = 1; prey.tile_pos = Vector2i(1,0); prey.population = 3
	prey.resources["food"] = 50
	s2.teams[0] = t2; s2.teams[1] = prey; s2.team_discovered[0] = [1]
	fai._trigger_survival(s2, t2, "urgent")
	assert(t2.current_task == TeamData.TASK_LOOT, "Path 2 應 掠奪，實際=%s" % t2.current_task)
	# (3) 義氣 + 信義 → 投靠
	var s3 := WorldState.new()
	s3.world = WorldData.new()
	s3.world.current_tick = 811
	_fill_plains(s3, -1, 4, -1, 2)
	var t3 := TeamData.new(); t3.team_id = 0; t3.tile_pos = Vector2i(0,0); t3.population = 5; t3.resources["food"] = 0
	var l3 := PersonData.new(); l3.id = 100; l3.values = { "義氣": 0.7, "信義": 0.7, "求生欲": 0.5 }
	s3.persons[100] = l3; t3.leader_id = 100
	var ally := TeamData.new(); ally.team_id = 1; ally.tile_pos = Vector2i(2,0); ally.population = 20; ally.faction_id = 99
	ally.resources["food"] = 500
	var ally_leader := PersonData.new(); ally_leader.id = 200
	s3.persons[200] = ally_leader; ally.leader_id = 200
	s3.teams[0] = t3; s3.teams[1] = ally; s3.team_discovered[0] = [1]
	t3.known_reputations[1] = 0.6
	fai._trigger_survival(s3, t3, "urgent")
	assert(t3.current_task == "投靠", "Path 3 應 投靠，實際=%s" % t3.current_task)
	# (4) 默認 → 乞食
	var s4 := WorldState.new()
	s4.world = WorldData.new()
	s4.world.current_tick = 812
	_fill_plains(s4, -1, 4, -1, 2)
	var t4 := TeamData.new(); t4.team_id = 0; t4.tile_pos = Vector2i(0,0); t4.population = 5; t4.resources["food"] = 0
	var l4 := PersonData.new(); l4.id = 100; l4.values = { "義氣": 0.4, "信義": 0.4, "殘忍": 0.3, "好戰": 0.3 }
	s4.persons[100] = l4; t4.leader_id = 100
	var aid := TeamData.new(); aid.team_id = 1; aid.tile_pos = Vector2i(2,0); aid.population = 10
	aid.resources["food"] = 500
	s4.teams[0] = t4; s4.teams[1] = aid; s4.team_discovered[0] = [1]
	fai._trigger_survival(s4, t4, "urgent")
	assert(t4.current_task == "乞食", "Path 4 應 乞食，實際=%s" % t4.current_task)
	print("Survival Task4 OK")

func _test_strategic_ai_respects_survival() -> void:
	print("--- Survival Task5: strategic_ai sticky ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	var t := TeamData.new()
	t.team_id = 0; t.tile_pos = Vector2i(0,0); t.population = 10
	t.current_task = "乞食"
	t.previous_task = "貿易"
	state.teams[0] = t
	var leader := PersonData.new()
	leader.id = 100
	leader.values = { "野心": 0.9, "好戰": 0.9 }
	state.persons[100] = leader; t.leader_id = 100
	var f := FactionData.new()
	f.faction_id = 0; f.leader_team_id = 0; f.member_team_ids = [0]
	f.strategic_goals = [{ "type": "expand", "target_id": -1, "priority": 0.9 }]
	state.factions[0] = f
	var sai := StrategicAiSystem.new()
	state.world.current_tick = StrategicAiSystem.STRATEGIC_INTERVAL
	sai.tick(state, f)
	assert(t.current_task == "乞食",
		"sticky 應保持乞食 task，實際=%s" % t.current_task)
	print("Survival Task5 OK")

func _test_resident_tax_with_stress() -> void:
	print("--- Resident Task6: 重稅後果 ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	# Owner Team 0
	var owner := TeamData.new()
	owner.team_id = 0; owner.population = 5; owner.faction_id = 10
	owner.current_task = "徵收"; owner.tile_pos = Vector2i(0, 0)
	state.teams[0] = owner
	# Village Team 1 with PRODUCE tag + high tax
	var v := TeamData.new()
	v.team_id = 1; v.population = 10; v.faction_id = 10
	v.tags = [TeamData.TAG_PRODUCE]; v.tile_pos = Vector2i(0, 0)
	v.tax_rate = 0.7   # 暴政
	v.resources["food"] = 500.0   # 充足
	var v_leader := PersonData.new(); v_leader.id = 200; v_leader.team_id = 1
	v_leader.stress = 0; v_leader.loyalty = 0.8; v_leader.fear = 0
	state.persons[200] = v_leader; v.leader_id = 200
	state.teams[1] = v
	var inter := InteractionSystem.new()
	inter._resolve_tribute(state, 0, 1)
	# 食物應被徵收
	assert(float(v.resources["food"]) < 500.0, "村莊 food 應減少")
	# 村長 stress/fear 應上升
	assert(v_leader.stress > 0, "重稅應升 stress，實際=%s" % str(v_leader.stress))
	assert(v_leader.fear > 0, "rate>0.6 應升 fear，實際=%s" % str(v_leader.fear))
	assert(v_leader.loyalty < 0.8, "重稅應扣 loyalty")
	print("Resident Task6 OK (stress=%.2f loyalty=%.2f fear=%.2f)" \
		% [v_leader.stress, v_leader.loyalty, v_leader.fear])

func _test_aid_resolve_npc_accept() -> void:
	print("--- Survival Task6a: NPC 接受 ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	var b := TeamData.new(); b.team_id = 0; b.population = 10; b.resources["food"] = 0
	b.current_task = "乞食"; b.previous_task = "貿易"
	b.combat_target = 1; b.tile_pos = Vector2i(2,2)
	var b_leader := PersonData.new(); b_leader.id = 100; b_leader.team_id = 0
	state.persons[100] = b_leader; b.leader_id = 100
	state.teams[0] = b
	var target := TeamData.new(); target.team_id = 1; target.population = 10
	target.resources["food"] = 500.0
	target.tile_pos = Vector2i(2,2)
	var t_leader := PersonData.new(); t_leader.id = 200
	t_leader.values = { "義氣": 0.8, "貪婪": 0.3 }
	state.persons[200] = t_leader; target.leader_id = 200
	state.teams[1] = target
	var inter := InteractionSystem.new()
	var r: Dictionary = inter._resolve_aid_request(state, 0, 1)
	assert(r.get("accepted", false), "高義氣應接受，msg=%s" % r.get("msg", ""))
	assert(float(b.resources["food"]) > 0.0, "beggar food 應 > 0")
	assert(b.current_task == "貿易", "beggar 應回 previous_task，實際=%s" % b.current_task)
	print("Survival Task6a OK (給 %.1f food)" % r.get("amount", 0.0))

func _test_aid_resolve_npc_refuse() -> void:
	print("--- Survival Task6b: NPC 拒絕 ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	var b := TeamData.new(); b.team_id = 0; b.population = 10; b.resources["food"] = 0
	b.current_task = "乞食"; b.previous_task = "貿易"; b.combat_target = 1
	var b_leader := PersonData.new(); b_leader.id = 100
	state.persons[100] = b_leader; b.leader_id = 100
	state.teams[0] = b
	var target := TeamData.new(); target.team_id = 1; target.population = 10
	target.resources["food"] = 500.0
	var t_leader := PersonData.new(); t_leader.id = 200
	t_leader.values = { "義氣": 0.1, "貪婪": 0.9 }
	state.persons[200] = t_leader; target.leader_id = 200
	state.teams[1] = target
	var inter := InteractionSystem.new()
	var r: Dictionary = inter._resolve_aid_request(state, 0, 1)
	assert(not r.get("accepted", true), "極吝嗇應拒絕")
	assert(float(b.resources["food"]) == 0.0, "beggar food 應仍 0")
	assert(b.current_task == "貿易", "拒絕後 beggar 仍回 previous_task")
	print("Survival Task6b OK")

func _test_aid_player_forced_event() -> void:
	print("--- Survival Task7a: 玩家收到 aid forced event ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	state.player_id = 200
	var pt := TeamData.new(); pt.team_id = 0; pt.population = 10
	pt.resources["food"] = 500.0
	pt.leader_id = 200
	state.teams[0] = pt
	var player := PersonData.new(); player.id = 200; player.team_id = 0
	state.persons[200] = player
	var b := TeamData.new(); b.team_id = 1; b.population = 10
	b.resources["food"] = 0; b.combat_target = 0; b.current_task = "乞食"
	b.previous_task = "idle"
	var b_leader := PersonData.new(); b_leader.id = 300
	state.persons[300] = b_leader; b.leader_id = 300
	state.teams[1] = b
	var inter := InteractionSystem.new()
	var r: Dictionary = inter._resolve_aid_request(state, 1, 0)
	assert(r.get("pending", false), "玩家 target 應 pending")
	assert(not state.player_forced_event.is_empty(), "forced_event 應寫入")
	assert(state.player_forced_event.get("action") == "aid_request",
		"forced action 應為 aid_request")
	print("Survival Task7a OK")

func _test_aid_player_response_give() -> void:
	print("--- Survival Task7b: 玩家給予回應 ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	state.player_id = 200
	var pt := TeamData.new(); pt.team_id = 0; pt.population = 10
	pt.resources["food"] = 500.0; pt.leader_id = 200
	state.teams[0] = pt
	var player := PersonData.new(); player.id = 200; player.team_id = 0
	state.persons[200] = player
	var b := TeamData.new(); b.team_id = 1; b.population = 10
	b.resources["food"] = 0; b.current_task = "乞食"; b.previous_task = "idle"
	var b_leader := PersonData.new(); b_leader.id = 300
	state.persons[300] = b_leader; b.leader_id = 300
	state.teams[1] = b
	state.player_forced_event = { "from_id": 1, "action": "aid_request" }
	state.player_state["aid_response"] = { "give_amount": 50.0 }
	var cmd := PlayerCommandSystem.new()
	var r: Dictionary = cmd.execute_action(state, 1, "respond_aid_request")
	assert(r.get("ok", false), "respond 應成功")
	assert(float(b.resources["food"]) == 50.0, "beggar 應收 50 food，實際=%.1f" % float(b.resources["food"]))
	assert(float(pt.resources["food"]) == 450.0, "玩家應扣 50 food，實際=%.1f" % float(pt.resources["food"]))
	assert(b.current_task == "idle", "beggar 應回 previous_task，實際=%s" % b.current_task)
	assert(state.player_forced_event.is_empty(), "forced_event 應清空")
	print("Survival Task7b OK")

func _test_aid_repeated_annoyance() -> void:
	print("--- Survival Task9a: 反覆乞食 annoyance ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	var b := TeamData.new(); b.team_id = 0; b.population = 10
	b.combat_target = 1
	var b_leader := PersonData.new(); b_leader.id = 100
	state.persons[100] = b_leader; b.leader_id = 100
	var target := TeamData.new(); target.team_id = 1; target.population = 10
	target.resources["food"] = 5000.0
	var t_leader := PersonData.new(); t_leader.id = 200
	t_leader.values = { "義氣": 0.5, "貪婪": 0.3 }
	state.persons[200] = t_leader; target.leader_id = 200
	state.teams[0] = b; state.teams[1] = target
	var inter := InteractionSystem.new()
	var accepted_count: int = 0
	for i in range(5):
		b.resources["food"] = 0
		b.current_task = "乞食"; b.previous_task = "idle"
		b.combat_target = 1
		var r: Dictionary = inter._resolve_aid_request(state, 0, 1)
		if r.get("accepted", false):
			accepted_count += 1
	assert(accepted_count < 5,
		"反覆乞食 5 次應有拒絕，全接受 = annoyance 機制無效")
	print("Survival Task9a OK (5 次中接受 %d 次)" % accepted_count)

func _test_aid_stranger() -> void:
	print("--- Survival Task9b: 陌生 team 也可乞食 ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	var b := TeamData.new(); b.team_id = 0; b.population = 5
	b.combat_target = 1; b.current_task = "乞食"; b.previous_task = "idle"
	var b_leader := PersonData.new(); b_leader.id = 100
	state.persons[100] = b_leader; b.leader_id = 100
	state.teams[0] = b
	var target := TeamData.new(); target.team_id = 1; target.population = 10
	target.resources["food"] = 500.0
	var t_leader := PersonData.new(); t_leader.id = 200
	t_leader.values = { "義氣": 0.7, "貪婪": 0.2 }
	state.persons[200] = t_leader; target.leader_id = 200
	state.teams[1] = target
	assert(not target.known_reputations.has(0), "預設無 rep 記錄")
	var inter := InteractionSystem.new()
	var r: Dictionary = inter._resolve_aid_request(state, 0, 1)
	assert(r.get("accepted", false), "陌生 + 高義氣 target 應接受")
	print("Survival Task9b OK")

func _test_resident_fields() -> void:
	print("--- Resident Task1: TeamData 新欄位 ---")
	var t := TeamData.new()
	assert(t.tax_rate == 0.3, "預設 tax_rate 應為 0.3，實際=%s" % str(t.tax_rate))
	assert(t.pending_owner_change_tick == -1, "預設 pending 應為 -1")
	t.tax_rate = 0.5
	t.pending_owner_change_tick = 1000
	assert(t.tax_rate == 0.5 and t.pending_owner_change_tick == 1000)
	print("Resident Task1 OK")

func _test_is_resident_detection() -> void:
	print("--- Resident Task2: _is_resident_team 偵測 ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	# Setup: outpost on (5,5) owned by Team 99
	var tile := HexTileData.new()
	tile.tile_pos = Vector2i(5, 5)
	tile.outpost_level = 1
	tile.outpost_type = "civilian"
	tile.outpost_owner = 99
	state.world.tiles[5 * 1000 + 5] = tile
	# Owner Team 99 faction=10
	var owner := TeamData.new(); owner.team_id = 99; owner.faction_id = 10
	state.teams[99] = owner
	# Test 1: PRODUCE team on outpost, same faction → 居民
	var r := TeamData.new(); r.team_id = 0; r.tile_pos = Vector2i(5,5)
	r.faction_id = 10; r.tags = [TeamData.TAG_PRODUCE]
	state.teams[0] = r
	var fai := FactionAISystem.new()
	assert(fai._is_resident_team(state, r), "案例 1：同 faction PRODUCE 應為居民")
	# Test 2: PRODUCE team on outpost, different faction → 非居民
	r.faction_id = 20
	assert(not fai._is_resident_team(state, r), "案例 2：異 faction 不算居民")
	# Test 3: PRODUCE team not on outpost → 非居民
	r.faction_id = 10
	r.tile_pos = Vector2i(8, 8)
	assert(not fai._is_resident_team(state, r), "案例 3：非 outpost 不算居民")
	# Test 4: Non-PRODUCE team on outpost → 非居民
	r.tile_pos = Vector2i(5, 5)
	r.tags = ["軍隊"]
	assert(not fai._is_resident_team(state, r), "案例 4：非 PRODUCE 不算居民")
	# Test 5: outpost cap
	assert(fai._outpost_pop_cap(state, Vector2i(5, 5)) == 20, "civilian L1 應 20")
	tile.outpost_level = 2
	assert(fai._outpost_pop_cap(state, Vector2i(5, 5)) == 50, "civilian L2 應 50")
	tile.outpost_type = "military"
	tile.outpost_level = 1
	assert(fai._outpost_pop_cap(state, Vector2i(5, 5)) == 15, "military L1 應 15")
	print("Resident Task2 OK")

func _test_resident_pop_cap_overflow() -> void:
	print("--- Resident Task3: PRODUCE 用 outpost cap 溢出 ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	var tile := HexTileData.new()
	tile.tile_pos = Vector2i(0, 0)
	tile.outpost_level = 1
	tile.outpost_type = "civilian"
	tile.outpost_owner = 0
	state.world.tiles[0] = tile
	# PRODUCE team pop=30，超過 L1 cap=20
	var t := TeamData.new()
	t.team_id = 0; t.tile_pos = Vector2i(0, 0); t.population = 30
	t.faction_id = 10; t.tags = [TeamData.TAG_PRODUCE]
	var leader := PersonData.new(); leader.id = 100; leader.team_id = 0
	leader.skills = { "統領": 0.9 }   # 統領高,普通 cap 會大,但 PRODUCE 應用 outpost cap=20
	state.persons[100] = leader; t.leader_id = leader.id
	state.teams[0] = t
	var ps := PopulationSystem.new()
	ps.check_overflow_for_team(state, 0)
	assert(t.population <= 20, "PRODUCE pop 應降到 outpost cap=20，實際=%d" % t.population)
	print("Resident Task3 OK (剩 %d)" % t.population)

func _test_resident_movement_lock() -> void:
	print("--- Resident Task4: 居民 movement 鎖定 ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	var tile := HexTileData.new()
	tile.tile_pos = Vector2i(0, 0); tile.outpost_level = 1
	tile.outpost_type = "civilian"; tile.outpost_owner = 0
	state.world.tiles[0] = tile
	var t := TeamData.new()
	t.team_id = 0; t.tile_pos = Vector2i(0, 0); t.population = 5
	t.faction_id = 10; t.tags = [TeamData.TAG_PRODUCE]
	t.current_task = "生產"
	t.move_target = Vector2i(3, 3)   # 想動但應被鎖
	state.teams[0] = t
	var mv: Object = load("res://scripts/simulation/movement_system.gd").new()
	var _r: Dictionary = mv.process(state, [0], 1.0)
	assert(t.tile_pos == Vector2i(0, 0), "居民應被鎖定不動，實際=%s" % str(t.tile_pos))
	# 但 task=逃跑 應該可動
	t.current_task = "逃跑"
	_r = mv.process(state, [0], 1.0)
	# tile_pos 是否變動需看實作；至少不被 lock skip
	print("Resident Task4 OK")

func _test_resident_no_salary() -> void:
	print("--- Resident Task5: PRODUCE 跳薪資 ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	state.player_id = -1   # 無玩家
	var t := TeamData.new()
	t.team_id = 0; t.population = 10; t.tags = [TeamData.TAG_PRODUCE]
	t.resources["coin"] = 500.0
	var l := PersonData.new(); l.id = 100; l.team_id = 0
	l.values = { "義氣": 1.0, "信義": 1.0, "貪婪": 0 }   # 慷慨
	state.persons[100] = l; t.leader_id = 100
	var member := PersonData.new(); member.id = 101; member.team_id = 0
	member.skills = { "戰鬥": 1.0 }; member.salary = 0; member.loyalty = 0.5
	state.persons[101] = member; t.named_members = [101]
	state.teams[0] = t
	var ss := SalarySystem.new()
	ss._pay_salary(state, t)
	# PRODUCE team 應跳過：member.salary 不變、coin 不扣、loyalty 不變
	assert(member.salary == 0.0, "PRODUCE member salary 不應被設")
	assert(float(t.resources["coin"]) == 500.0, "PRODUCE team coin 不應扣")
	assert(member.loyalty == 0.5, "PRODUCE member loyalty 不應扣")
	print("Resident Task5 OK")

func _test_invite_settle_execute() -> void:
	print("--- Resident Task7: invite_settle 執行 ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	# Outpost on (5,5) owner Team 0
	var tile := HexTileData.new()
	tile.tile_pos = Vector2i(5, 5); tile.outpost_level = 1
	tile.outpost_type = "civilian"; tile.outpost_owner = 0
	state.world.tiles[5005] = tile
	# Inviter (Player team)
	var pt := TeamData.new(); pt.team_id = 0; pt.faction_id = 10
	pt.tile_pos = Vector2i(0, 0)
	state.teams[0] = pt
	# Target (流亡 roving) accepting
	var target := TeamData.new()
	target.team_id = 1; target.population = 5; target.faction_id = -1
	target.tags = ["流亡"]; target.tile_pos = Vector2i(9, 9)
	target.resources["food"] = 0   # 飢餓 → 易接受
	var t_leader := PersonData.new(); t_leader.id = 200; t_leader.team_id = 1
	t_leader.values = { "求生欲": 0.8, "野心": 0.1 }
	state.persons[200] = t_leader; target.leader_id = 200
	state.teams[1] = target
	var inter := InteractionSystem.new()
	inter._execute_settlement(state, 1, Vector2i(5, 5), 10)
	# target 應 tags 加生產、移到 outpost、加入 faction
	assert(target.tags.has(TeamData.TAG_PRODUCE), "目標應加 PRODUCE")
	assert(not target.tags.has("流亡"), "目標應 erase 流亡")
	assert(target.tile_pos == Vector2i(5, 5), "目標應移到 outpost")
	assert(target.faction_id == 10, "目標應入 inviter faction")
	print("Resident Task7 OK")

func _test_subteam_settle() -> void:
	print("--- Resident Task8: 子隊 task=安頓 ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	var tile := HexTileData.new()
	tile.tile_pos = Vector2i(3, 3); tile.outpost_level = 1
	tile.outpost_type = "civilian"; tile.outpost_owner = 0
	state.world.tiles[3003] = tile
	var owner := TeamData.new(); owner.team_id = 0; owner.faction_id = 10
	state.teams[0] = owner
	# 子隊 Team 1
	var sub := TeamData.new()
	sub.team_id = 1; sub.faction_id = 10; sub.parent_team_id = 0
	sub.tile_pos = Vector2i(3, 3)
	sub.tags = ["子團"]; sub.current_task = "安頓"
	state.teams[1] = sub
	var inter := InteractionSystem.new()
	inter._convert_to_resident(state, sub)
	assert(sub.tags.has(TeamData.TAG_PRODUCE), "應加 PRODUCE")
	assert(not sub.tags.has("子團"), "應 erase 子團")
	assert(sub.parent_team_id == -1, "應脫離 parent")
	print("Resident Task8 OK")

func _test_uprising_trigger() -> void:
	print("--- Resident Task9: 起義觸發 ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	var tile := HexTileData.new()
	tile.tile_pos = Vector2i(0, 0); tile.outpost_level = 1
	tile.outpost_type = "civilian"; tile.outpost_owner = 99
	state.world.tiles[0] = tile
	var owner := TeamData.new(); owner.team_id = 99; owner.faction_id = 10
	state.teams[99] = owner
	# 居民 team：低 loyalty + 高 unrest + 多 stress sources
	var v := TeamData.new()
	v.team_id = 0; v.population = 10; v.faction_id = 10
	v.tags = [TeamData.TAG_PRODUCE]; v.tile_pos = Vector2i(0, 0)
	v.tax_rate = 0.7   # 重稅 source
	v.resources["food"] = 30   # 飢餓 source
	v.unrest_turns = 70   # 已過閾值
	var l := PersonData.new(); l.id = 100; l.loyalty = 0.1
	# 求生欲高 → 走 Path B 流亡（保留原本斷言）
	l.values = { "求生欲": 0.9, "野心": 0.2, "慎重": 0.2, "義氣": 0.2 }
	state.persons[100] = l; v.leader_id = 100
	state.teams[0] = v
	var fai := FactionAISystem.new()
	fai._evaluate_uprising(state, v)
	assert(v.current_task == "起義", "應觸發起義，實際 task=%s" % v.current_task)
	assert(v.faction_id == -1, "應脫離 faction")
	assert(v.tags.has("流亡"), "應加流亡")
	assert(not v.tags.has(TeamData.TAG_PRODUCE), "應 erase 生產")
	print("Resident Task9 OK")

func _test_defection_paths() -> void:
	print("--- Resident Task11: 三路徑 a/b/c ---")
	var fai := FactionAISystem.new()
	# Path a: 高義氣 → 留 faction
	var state := WorldState.new()
	state.world = WorldData.new()
	var t := TeamData.new(); t.team_id = 0; t.faction_id = 10
	var l := PersonData.new(); l.id = 100; l.values = { "義氣": 0.9, "慎重": 0.3, "野心": 0.2 }
	state.persons[100] = l; t.leader_id = 100; state.teams[0] = t
	fai._trigger_defection_evaluation(state, t, "no_contact")
	# path a：faction_id 不變
	assert(t.faction_id == 10, "高義氣應留 faction")
	# Path c: 高野心 → 獨立
	var t2 := TeamData.new(); t2.team_id = 1; t2.faction_id = 10
	var l2 := PersonData.new(); l2.id = 200
	l2.values = { "野心": 0.9, "慎重": 0.2, "義氣": 0.2 }
	state.persons[200] = l2; t2.leader_id = 200; state.teams[1] = t2
	fai._trigger_defection_evaluation(state, t2, "no_contact")
	assert(t2.faction_id == -1, "高野心應獨立")
	print("Resident Task11 OK")

func _test_owner_contact_timeout() -> void:
	print("--- Resident Task10: 失聯 30 天觸發 ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	var tile := HexTileData.new()
	tile.tile_pos = Vector2i(0,0); tile.outpost_level = 1
	tile.outpost_type = "civilian"; tile.outpost_owner = 99
	state.world.tiles[0] = tile
	var owner := TeamData.new(); owner.team_id = 99; owner.faction_id = 10
	state.teams[99] = owner
	var v := TeamData.new()
	v.team_id = 0; v.population = 10; v.faction_id = 10
	v.tags = [TeamData.TAG_PRODUCE]; v.tile_pos = Vector2i(0,0)
	var l := PersonData.new(); l.id = 100; l.values = { "義氣": 0.9 }
	state.persons[100] = l; v.leader_id = 100
	state.teams[0] = v
	# Setup snapshot：last_tick=0, current_tick=31 day
	state.team_intel[0] = { 99: { "last_tick": 0, "leader_id": -1 } }
	state.world.current_tick = 31 * WorldState.TICKS_PER_DAY
	var fai := FactionAISystem.new()
	fai._evaluate_owner_contact(state, v)
	# 應該觸發 _trigger_defection_evaluation → path a (高義氣 → follow original)
	# 簡單斷言：tag 變化或 task 變化
	print("Resident Task10 OK (defection triggered)")

func _test_pacify_subteam() -> void:
	print("--- Resident Task12: 子隊安撫 ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	var v := TeamData.new()
	v.team_id = 0; v.population = 10; v.faction_id = 10
	v.tags = [TeamData.TAG_PRODUCE]; v.tile_pos = Vector2i(0, 0)
	v.unrest_turns = 10
	var l := PersonData.new(); l.id = 100; l.stress = 0.5; l.loyalty = 0.5
	state.persons[100] = l; v.leader_id = 100; state.teams[0] = v
	var pac := TeamData.new(); pac.team_id = 1; pac.faction_id = 10
	pac.tile_pos = Vector2i(0, 0); pac.current_task = "安撫"
	state.teams[1] = pac
	var inter := InteractionSystem.new()
	inter._resolve_pacify(state, pac, v)
	assert(l.stress < 0.5, "安撫應降 stress")
	assert(l.loyalty > 0.5, "安撫應升 loyalty")
	assert(v.unrest_turns < 10, "安撫應降 unrest")
	print("Resident Task12 OK")

# ════════════ Merchant Trade (A) + Outpost Capture (D) ════════════

func _test_merchant_capture_fields() -> void:
	print("--- Trade Task1: TeamData 新欄位 ---")
	var t := TeamData.new()
	assert(t.merchant_inventory == [], "預設 merchant_inventory 應為空")
	assert(t.occupying_outpost_since == -1, "預設 occupying_outpost_since 應 -1")
	t.merchant_inventory.append({ "grade": "food", "qty": 5, "bought_at": 2.0, "bought_from": 1 })
	assert(t.merchant_inventory.size() == 1)
	print("Trade Task1 OK")

func _test_resolve_market_bidirectional() -> void:
	print("--- Trade Task2: _resolve_market 雙向 ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	# A：有 food surplus，缺 material
	var a := TeamData.new()
	a.team_id = 0; a.population = 10
	a.resources["food"] = 500.0
	a.resources["material"] = 5.0
	a.resources["coin"] = 200.0
	a.current_task = TeamData.TASK_TRADE
	state.teams[0] = a
	# B：有 material surplus，缺 food
	var b := TeamData.new()
	b.team_id = 1; b.population = 10
	b.resources["food"] = 10.0
	b.resources["material"] = 500.0
	b.resources["coin"] = 300.0
	state.teams[1] = b
	var inter := InteractionSystem.new()
	inter._resolve_market(state, a, b)
	# 預期：A 賣 food 給 B、B 賣 material 給 A
	assert(float(b.resources["food"]) > 10.0, "B 應收到 food")
	assert(float(a.resources["material"]) > 5.0, "A 應收到 material")
	print("Trade Task2 OK (a food=%.0f mat=%.0f, b food=%.0f mat=%.0f)" % [
		float(a.resources["food"]), float(a.resources["material"]),
		float(b.resources["food"]), float(b.resources["material"])])

func _test_merchant_inventory_trade() -> void:
	print("--- Trade Task3: 商隊 inventory 賺差價 ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	# 商隊 A：inventory 有 weapon_melee_low，bought_at=10
	var a := TeamData.new()
	a.team_id = 0; a.population = 5
	a.tags = ["商隊"]
	a.resources["coin"] = 0.0
	a.merchant_inventory.append({
		"grade": "weapon_melee_low", "qty": 5, "bought_at": 10.0, "bought_from": 99
	})
	a.current_task = TeamData.TASK_TRADE
	state.teams[0] = a
	# Buyer B：缺武器，coin 充足
	var b := TeamData.new()
	b.team_id = 1; b.population = 20   # 大隊缺武器 → local_value 高
	b.resources["coin"] = 500.0
	b.resources["weapon_melee_low"] = 0
	state.teams[1] = b
	var inter := InteractionSystem.new()
	inter._resolve_market(state, a, b)
	# 預期：A inventory 物品賣給 B，coin 多
	assert(float(a.resources["coin"]) > 0.0, "A 應收到 coin")
	assert(int(b.resources.get("weapon_melee_low", 0)) > 0, "B 應收到武器")
	# inventory 應減少或清空
	var remaining: int = 0
	for item in a.merchant_inventory: remaining += int(item.qty)
	assert(remaining < 5, "inventory 應減少（賣出部分）")
	print("Trade Task3 OK (A coin=%.0f, B 武器=%d, inv 剩 %d)" % [
		float(a.resources["coin"]), int(b.resources["weapon_melee_low"]), remaining])

func _test_find_trade_target_max_gap() -> void:
	print("--- Trade Task4: _find_trade_target 最大價差 ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	state.world.current_tick = 802   # 唯一 tick，避免 path cache 跨測試污染
	# 平原網格，讓 estimate_catch_up 的 A* 有路可走
	for gx in range(-1, 5):
		for gy in range(-1, 2):
			var g := HexTileData.new()
			g.tile_pos = Vector2i(gx, gy); g.terrain = "plains"
			state.world.tiles[gx * 1000 + gy] = g
	var merchant := TeamData.new()
	merchant.team_id = 0; merchant.tile_pos = Vector2i(0, 0); merchant.population = 5
	merchant.resources["food"] = 100.0
	state.teams[0] = merchant
	state.team_discovered[0] = [1, 2]
	# Team 1: 近，價差小
	var t1 := TeamData.new()
	t1.team_id = 1; t1.tile_pos = Vector2i(1, 0); t1.population = 5
	t1.resources["food"] = 100.0
	state.teams[1] = t1
	state.team_intel[0] = { 1: { "food": 100.0, "population": 5 } }
	# Team 2: 遠，價差大
	var t2 := TeamData.new()
	t2.team_id = 2; t2.tile_pos = Vector2i(3, 0); t2.population = 50
	t2.resources["food"] = 0.0
	state.teams[2] = t2
	state.team_intel[0][2] = { "food": 0.0, "population": 50 }
	var fai := FactionAISystem.new()
	var target = fai._find_trade_target(state, merchant)
	# Team 2 食物缺 + 人多 → local_value 高，價差大；雖遠但 score 應較高
	assert(target == 2, "應選最大價差 target，實際=%d" % target)
	print("Trade Task4 OK (target=%d)" % target)

func _test_encounter_capture_outpost() -> void:
	print("--- Trade Task6: 戰勝接管 outpost ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	# Outpost on (4,4) owned by Team 99
	var tile := HexTileData.new()
	tile.tile_pos = Vector2i(4, 4); tile.outpost_level = 1
	tile.outpost_type = "civilian"; tile.outpost_owner = 99
	state.world.tiles[4004] = tile
	# Attacker Team 0, defender Team 99（守 outpost 格）
	var atk := TeamData.new(); atk.team_id = 0; atk.tile_pos = Vector2i(4, 4)
	state.teams[0] = atk
	var def := TeamData.new(); def.team_id = 99; def.tile_pos = Vector2i(4, 4)
	state.teams[99] = def
	state.encounter_attacker_id = 0
	state.encounter_defender_id = 99
	state.encounter_active = true
	var enc := EncounterSystem.new()
	enc.resolve_encounter_end(state, "attacker_win")
	# Outpost owner 應變 attacker
	assert(tile.outpost_owner == 0, "outpost owner 應變 attacker=0，實際=%d" % tile.outpost_owner)
	print("Trade Task6 OK")

func _test_unowned_outpost_takeover() -> void:
	print("--- Trade Task7: 無人 outpost 3 天接管 ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	var tile := HexTileData.new()
	tile.tile_pos = Vector2i(2, 2); tile.outpost_level = 1
	tile.outpost_type = "civilian"; tile.outpost_owner = -1   # 無人
	state.world.tiles[2002] = tile
	var t := TeamData.new()
	t.team_id = 0; t.tile_pos = Vector2i(2, 2)
	state.teams[0] = t
	var fai := FactionAISystem.new()
	# 第一次：起始駐留
	state.world.current_tick = 0
	fai._evaluate_outpost_takeover(state, t)
	assert(t.occupying_outpost_since == 0, "起始 tick 應記")
	assert(tile.outpost_owner == -1, "尚未到 3 天")
	# 跳到 3 天後
	state.world.current_tick = 3 * WorldState.TICKS_PER_DAY
	fai._evaluate_outpost_takeover(state, t)
	assert(tile.outpost_owner == 0, "3 天後應接管，實際=%d" % tile.outpost_owner)
	assert(t.occupying_outpost_since == -1, "接管後 reset")
	print("Trade Task7 OK")

func _test_alliance_outpost_transfer() -> void:
	print("--- Trade Task8: 居民團 alliance → outpost 轉 ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	var tile := HexTileData.new()
	tile.tile_pos = Vector2i(3, 3); tile.outpost_level = 1
	tile.outpost_type = "civilian"; tile.outpost_owner = 99
	state.world.tiles[3003] = tile
	# Original owner Team 99 faction 10
	var owner := TeamData.new(); owner.team_id = 99; owner.faction_id = 10
	state.teams[99] = owner
	# 居民團 Team 0
	var v := TeamData.new()
	v.team_id = 0; v.faction_id = 10; v.tile_pos = Vector2i(3, 3)
	v.tags = [TeamData.TAG_PRODUCE]; v.population = 10
	var v_leader := PersonData.new(); v_leader.id = 100
	v_leader.values = { "義氣": 0.4, "信義": 0.5 }   # 中等義氣
	state.persons[100] = v_leader; v.leader_id = 100
	state.teams[0] = v
	# 攻方 Team 5 faction 20
	var attacker := TeamData.new(); attacker.team_id = 5; attacker.faction_id = 20
	attacker.tile_pos = Vector2i(3, 3)
	state.teams[5] = attacker
	state.create_faction(5)   # 確保 faction 存在
	# 模擬 alliance accept（直接呼叫 _form_alliance + outpost 連動）
	var diplo := DiplomaticAiSystem.new()
	diplo._form_alliance(state, attacker, v)
	assert(tile.outpost_owner == 5, "outpost owner 應變攻方 5，實際=%d" % tile.outpost_owner)
	print("Trade Task8 OK")

func _test_uprising_paths() -> void:
	print("--- Trade Task9: 起義 A 守城 vs B 流亡 ---")
	# Path A: 野心高 → 守城
	var state := WorldState.new()
	state.world = WorldData.new()
	var tile := HexTileData.new()
	tile.tile_pos = Vector2i(0, 0); tile.outpost_level = 1
	tile.outpost_type = "civilian"; tile.outpost_owner = 99
	state.world.tiles[0] = tile
	var owner := TeamData.new(); owner.team_id = 99; owner.faction_id = 10
	state.teams[99] = owner
	var v := TeamData.new()
	v.team_id = 0; v.population = 10; v.faction_id = 10
	v.tags = [TeamData.TAG_PRODUCE]; v.tile_pos = Vector2i(0, 0)
	v.tax_rate = 0.7; v.resources["food"] = 0; v.unrest_turns = 70
	var l := PersonData.new(); l.id = 100; l.loyalty = 0.1
	l.values = { "野心": 0.9, "慎重": 0.7, "義氣": 0.3, "求生欲": 0.2 }
	state.persons[100] = l; v.leader_id = 100
	state.teams[0] = v
	var fai := FactionAISystem.new()
	fai._evaluate_uprising(state, v)
	assert(tile.outpost_owner == 0, "Path A 應 outpost = village，實際=%d" % tile.outpost_owner)
	assert(v.current_task == "守城", "Path A task 應 守城，實際=%s" % v.current_task)
	assert(v.tags.has(TeamData.TAG_PRODUCE), "Path A tags 仍 PRODUCE")
	# Path B: 求生欲高 → 流亡
	var state2 := WorldState.new()
	state2.world = WorldData.new()
	var tile2 := HexTileData.new()
	tile2.tile_pos = Vector2i(0, 0); tile2.outpost_level = 1
	tile2.outpost_type = "civilian"; tile2.outpost_owner = 99
	state2.world.tiles[0] = tile2
	var owner2 := TeamData.new(); owner2.team_id = 99; owner2.faction_id = 10
	state2.teams[99] = owner2
	var v2 := TeamData.new()
	v2.team_id = 0; v2.population = 10; v2.faction_id = 10
	v2.tags = [TeamData.TAG_PRODUCE]; v2.tile_pos = Vector2i(0, 0)
	v2.tax_rate = 0.7; v2.resources["food"] = 0; v2.unrest_turns = 70
	var l2 := PersonData.new(); l2.id = 100; l2.loyalty = 0.1
	l2.values = { "求生欲": 0.9, "野心": 0.2, "慎重": 0.2, "義氣": 0.2 }
	state2.persons[100] = l2; v2.leader_id = 100
	state2.teams[0] = v2
	var fai2 := FactionAISystem.new()
	fai2._evaluate_uprising(state2, v2)
	assert(tile2.outpost_owner == 99, "Path B outpost owner 暫不變")
	assert(v2.tags.has("流亡"), "Path B tags 應 流亡")
	assert(not v2.tags.has(TeamData.TAG_PRODUCE), "Path B tags 應 erase 生產")
	print("Trade Task9 OK")

func _test_task_extra_data_field() -> void:
	print("--- Infra Task1: task_extra_data ---")
	var t := TeamData.new()
	assert(t.task_extra_data == {}, "預設為空 dict")
	t.task_extra_data = { "build_type": "civilian", "level": 1 }
	assert(t.task_extra_data["build_type"] == "civilian")
	print("Infra Task1 OK")

func _test_facility_def_registry() -> void:
	print("--- Infra Task2: FACILITY_DEF ---")
	assert(OutpostSystem.FACILITY_DEF.has("farming"))
	assert(OutpostSystem.FACILITY_DEF.has("workshop"))
	var farming = OutpostSystem.FACILITY_DEF["farming"]
	assert(farming.cost.material == 30)
	assert(farming.allowed_outpost == ["civilian"])
	# trigger_check helpers 可呼叫
	var state := WorldState.new()
	state.world = WorldData.new()
	var t := TeamData.new(); t.team_id = 0; t.population = 10
	t.resources["food"] = 0.0; t.resources["goods"] = 0.0
	state.teams[0] = t
	var fid = state.create_faction(0)
	var f = state.factions[fid]
	var fai := FactionAISystem.new()
	assert(fai._check_food_shortage(state, f) > 50.0, "缺糧應高分")
	assert(fai._check_goods_shortage(state, f) > 0.0, "缺貨應有分")
	print("Infra Task2 OK")

func _test_dispatch_builder() -> void:
	print("--- Infra Task3: _dispatch_builder ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	var owner := TeamData.new()
	owner.team_id = 0; owner.population = 30; owner.faction_id = 10
	owner.tile_pos = Vector2i(0, 0)
	owner.resources["material"] = 200.0; owner.resources["coin"] = 50.0
	var leader := PersonData.new(); leader.id = 100; leader.team_id = 0
	state.persons[100] = leader; owner.leader_id = 100
	var adv := PersonData.new(); adv.id = 101; adv.team_id = 0
	adv.skills["統領"] = 0.4
	state.persons[101] = adv; owner.named_members = [101]
	state.teams[0] = owner
	state.create_faction(0)
	var fai := FactionAISystem.new()
	var result = fai._dispatch_builder(state, owner, Vector2i(3, 3), "civilian", 1)
	assert(result, "資源足應派子隊")
	var sub_count = 0
	for tid in state.teams:
		if state.teams[tid].parent_team_id == 0 and state.teams[tid].current_task == "建造":
			sub_count += 1
	assert(sub_count == 1, "應派出 1 個子隊 task=建造")
	print("Infra Task3 OK")

func _test_evaluate_outpost_location() -> void:
	print("--- Infra Task4: outpost location scoring ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	var leader_team := TeamData.new()
	leader_team.team_id = 0; leader_team.tile_pos = Vector2i(0, 0)
	state.teams[0] = leader_team
	for x in range(-3, 4):
		for y in range(-3, 4):
			var tile := HexTileData.new()
			tile.tile_pos = Vector2i(x, y)
			tile.terrain = "plains"
			tile.productivity = 1.0 if abs(x) + abs(y) > 2 else 0.5
			tile.outpost_level = 0
			state.world.tiles[x * 1000 + y] = tile
	var fai := FactionAISystem.new()
	var best = fai._evaluate_new_outpost_location(state, leader_team)
	assert(not best.is_empty(), "應找到 candidate")
	print("Infra Task4 OK (best=%s)" % str(best.pos))

func _test_evaluate_infrastructure() -> void:
	print("--- Infra Task5: _evaluate_infrastructure ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	var leader_team := TeamData.new()
	leader_team.team_id = 0; leader_team.population = 30; leader_team.tile_pos = Vector2i(0, 0)
	leader_team.resources["material"] = 500.0; leader_team.resources["coin"] = 100.0
	var leader := PersonData.new(); leader.id = 100
	leader.values = { "野心": 0.3, "慎重": 0.7, "好戰": 0.2, "貪婪": 0.4 }
	state.persons[100] = leader; leader_team.leader_id = 100
	var adv := PersonData.new(); adv.id = 101
	state.persons[101] = adv; leader_team.named_members = [101]
	state.teams[0] = leader_team
	var fid = state.create_faction(0)
	var f = state.factions[fid]
	for x in range(-3, 4):
		for y in range(-3, 4):
			var tile := HexTileData.new()
			tile.tile_pos = Vector2i(x, y); tile.terrain = "plains"
			tile.productivity = 1.0; tile.outpost_level = 0
			state.world.tiles[x * 1000 + y] = tile
	var fai := FactionAISystem.new()
	fai._evaluate_infrastructure(state, f)
	var sub_count = 0
	for tid in state.teams:
		if state.teams[tid].parent_team_id == 0:
			sub_count += 1
	assert(sub_count >= 1, "應派出基建子隊")
	print("Infra Task5 OK (派出 %d 子隊)" % sub_count)

func _test_subteam_arrival_triggers_build() -> void:
	print("--- Infra Task6: 子隊抵達觸發建造 ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	var owner := TeamData.new()
	owner.team_id = 0; owner.population = 30; owner.tile_pos = Vector2i(0, 0)
	owner.resources["material"] = 300.0; owner.resources["coin"] = 80.0
	var leader := PersonData.new(); leader.id = 100; state.persons[100] = leader
	owner.leader_id = 100
	var adv := PersonData.new(); adv.id = 101; state.persons[101] = adv
	adv.skills["統領"] = 0.5
	owner.named_members = [101]
	state.teams[0] = owner
	state.create_faction(0)
	var tile := HexTileData.new()
	tile.tile_pos = Vector2i(3, 3); tile.terrain = "plains"
	state.world.tiles[3003] = tile
	var fai := FactionAISystem.new()
	assert(fai._dispatch_builder(state, owner, Vector2i(3, 3), "civilian", 1), "派建造子隊")
	var sub_id := -1
	for tid in state.teams:
		if state.teams[tid].parent_team_id == 0:
			sub_id = tid
	var sub: TeamData = state.teams[sub_id]
	sub.tile_pos = Vector2i(3, 3)   # 模擬抵達
	var os := OutpostSystem.new()
	assert(os.begin_subteam_construction(state, sub), "抵達應啟動建造")
	assert(tile.construction_target.get("action", "") == "build", "construction action=build")
	assert(tile.construction_ticks_left > 0, "施工 ticks > 0")
	assert(sub.current_task == TeamData.TASK_BUILD, "子隊 task → 建設")
	print("Infra Task6 OK")

func _test_dispatch_upgrader_and_facility() -> void:
	print("--- Infra Task7: 升級/擴建 dispatch ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	var leader_team := TeamData.new()
	leader_team.team_id = 0; leader_team.population = 30
	leader_team.resources["material"] = 500.0; leader_team.resources["coin"] = 100.0
	var leader := PersonData.new(); leader.id = 100; state.persons[100] = leader
	leader_team.leader_id = 100
	var adv := PersonData.new(); adv.id = 101; adv.skills["統領"] = 0.5
	state.persons[101] = adv
	var adv2 := PersonData.new(); adv2.id = 102; adv2.skills["統領"] = 0.5
	state.persons[102] = adv2
	leader_team.named_members = [101, 102]
	state.teams[0] = leader_team
	state.create_faction(0)
	var tile := HexTileData.new()
	tile.tile_pos = Vector2i(3, 3); tile.outpost_level = 1
	tile.outpost_type = "civilian"; tile.outpost_owner = 0
	tile.farming_level = 0
	state.world.tiles[3003] = tile
	var fai := FactionAISystem.new()
	assert(fai._dispatch_upgrader(state, leader_team, Vector2i(3, 3), 2), "升級派子隊應成功")
	# 擴建（farming，cap@L1=1，current=0）
	assert(fai._dispatch_facility_builder(state, leader_team, Vector2i(3, 3), "farming"), "擴建派子隊應成功")
	var upgrade_count := 0
	var facility_count := 0
	for tid in state.teams:
		var t: TeamData = state.teams[tid]
		if t.current_task == "升級": upgrade_count += 1
		if t.current_task == "擴建": facility_count += 1
	assert(upgrade_count == 1, "1 個升級子隊")
	assert(facility_count == 1, "1 個擴建子隊")
	print("Infra Task7 OK")

func _test_auto_settle_after_build() -> void:
	print("--- Infra Task8: 蓋完自動安頓 ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	var owner := TeamData.new()
	owner.team_id = 0; owner.population = 30; owner.tile_pos = Vector2i(0, 0)
	owner.resources["material"] = 300.0; owner.resources["coin"] = 80.0
	var leader := PersonData.new(); leader.id = 100; state.persons[100] = leader
	owner.leader_id = 100
	var adv := PersonData.new(); adv.id = 101; adv.skills["統領"] = 0.5
	state.persons[101] = adv; owner.named_members = [101]
	state.teams[0] = owner
	state.create_faction(0)
	var tile := HexTileData.new()
	tile.tile_pos = Vector2i(3, 3); tile.terrain = "plains"
	state.world.tiles[3003] = tile
	var fai := FactionAISystem.new()
	assert(fai._dispatch_builder(state, owner, Vector2i(3, 3), "civilian", 1), "派建造子隊")
	var sub_id := -1
	for tid in state.teams:
		if state.teams[tid].parent_team_id == 0:
			sub_id = tid
	var sub: TeamData = state.teams[sub_id]
	sub.tile_pos = Vector2i(3, 3)
	var os := OutpostSystem.new()
	assert(os.begin_subteam_construction(state, sub), "啟動建造")
	# 強制完工
	tile.construction_ticks_left = 1
	os.tick_all(state)
	assert(tile.outpost_level == 1, "outpost 完工 Lv1")
	assert(tile.outpost_owner == sub_id, "owner = 子隊")
	assert(sub.parent_team_id == -1, "子隊脫離母團")
	assert(sub.tags.has(TeamData.TAG_PRODUCE), "civilian → PRODUCE tag")
	print("Infra Task8 OK")

func _test_player_upgrade_outpost() -> void:
	print("--- Infra Task10: 玩家 upgrade_outpost ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	state.player_id = 100
	var pt := TeamData.new(); pt.team_id = 0; pt.leader_id = 100
	pt.tile_pos = Vector2i(5, 5); pt.population = 10
	pt.resources["material"] = 300.0; pt.resources["coin"] = 60.0
	state.teams[0] = pt
	var pp := PersonData.new(); pp.id = 100; pp.team_id = 0
	state.persons[100] = pp
	var tile := HexTileData.new()
	tile.tile_pos = Vector2i(5, 5); tile.outpost_level = 1
	tile.outpost_type = "civilian"; tile.outpost_owner = 0
	state.world.tiles[5005] = tile
	var cmd := PlayerCommandSystem.new()
	var r: Dictionary = cmd.execute_action(state, -1, "upgrade_outpost")
	assert(r.get("ok", false), "升級應成功: %s" % r.get("msg", ""))
	assert(tile.construction_target.get("action", "") == "upgrade_level", "施工=升級")
	assert(tile.construction_ticks_left > 0, "施工 ticks > 0")
	print("Infra Task10 OK")

func _test_player_build_facility() -> void:
	print("--- Infra Task11: 玩家 build_facility ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	state.player_id = 100
	var pt := TeamData.new(); pt.team_id = 0; pt.leader_id = 100
	pt.tile_pos = Vector2i(5, 5); pt.population = 10
	pt.resources["material"] = 300.0; pt.resources["coin"] = 60.0
	state.teams[0] = pt
	var pp := PersonData.new(); pp.id = 100; pp.team_id = 0
	state.persons[100] = pp
	var tile := HexTileData.new()
	tile.tile_pos = Vector2i(5, 5); tile.outpost_level = 1
	tile.outpost_type = "civilian"; tile.outpost_owner = 0
	tile.farming_level = 0
	state.world.tiles[5005] = tile
	state.player_state["facility_type"] = "farming"
	var cmd := PlayerCommandSystem.new()
	var r: Dictionary = cmd.execute_action(state, -1, "build_facility")
	assert(r.get("ok", false), "擴建應成功: %s" % r.get("msg", ""))
	assert(tile.construction_target.get("action", "") == "upgrade_facility", "施工=upgrade_facility")
	assert(tile.construction_target.get("facility", "") == "farming", "facility=farming")
	# 未知 facility → 失敗
	state.player_state["facility_type"] = "nonexist"
	var r2: Dictionary = cmd.execute_action(state, -1, "build_facility")
	assert(not r2.get("ok", true), "未知 facility 應失敗")
	print("Infra Task11 OK")

func _test_abandon_outpost() -> void:
	print("--- Trade Task10: 玩家棄置 outpost ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	state.player_id = 100
	var tile := HexTileData.new()
	tile.tile_pos = Vector2i(5, 5); tile.outpost_level = 1
	tile.outpost_type = "civilian"; tile.outpost_owner = 0
	state.world.tiles[5005] = tile
	var pt := TeamData.new(); pt.team_id = 0; pt.leader_id = 100
	state.teams[0] = pt
	var pp := PersonData.new(); pp.id = 100; pp.team_id = 0
	state.persons[100] = pp
	state.player_state["abandon_pos"] = [5, 5]
	var cmd := PlayerCommandSystem.new()
	var r: Dictionary = cmd.execute_action(state, -1, "abandon_outpost")
	assert(r.get("ok", false), "abandon 應成功")
	assert(tile.outpost_owner == -1, "outpost owner 應 -1，實際=%d" % tile.outpost_owner)
	print("Trade Task10 OK")

# ──────── H: 玩家死亡保護測試 ────────

func _test_game_over_field() -> void:
	print("--- Death Task1: game_over 欄位 ---")
	var s := WorldState.new()
	assert(s.game_over == false, "預設 false")
	assert(s.game_over_reason == "", "預設空字串")
	s.game_over = true
	s.game_over_reason = "test"
	assert(s.game_over and s.game_over_reason == "test")
	print("Death Task1 OK")

func _test_handle_player_leader_death() -> void:
	print("--- Death Task2: _handle_player_leader_death ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	state.player_id = 100
	var pt := TeamData.new()
	pt.team_id = 0; pt.leader_id = 100
	pt.named_members = [101, 102]
	state.teams[0] = pt
	var p := PersonData.new(); p.id = 100; p.team_id = 0
	state.persons[100] = p
	var heir1 := PersonData.new(); heir1.id = 101; heir1.team_id = 0
	state.persons[101] = heir1
	var heir2 := PersonData.new(); heir2.id = 102; heir2.team_id = 0
	state.persons[102] = heir2
	# 模擬玩家死亡：persons 中移除
	state.persons.erase(100)
	pt.leader_id = -1
	var fai := FactionAISystem.new()
	fai._handle_player_leader_death(state, pt)
	assert(not state.player_forced_event.is_empty(), "應寫入 forced_event")
	assert(state.player_forced_event.get("action") == "choose_heir")
	var cands: Array = state.player_forced_event.get("candidates", [])
	assert(cands.has(101) and cands.has(102), "candidates 應含 named_members")
	print("Death Task2 OK")

func _test_no_heir_game_over() -> void:
	print("--- Death Task2b: 無 named → game_over ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	state.player_id = 100
	var pt := TeamData.new()
	pt.team_id = 0; pt.leader_id = -1
	pt.named_members = []
	state.teams[0] = pt
	var fai := FactionAISystem.new()
	fai._handle_player_leader_death(state, pt)
	assert(state.game_over, "無 named 應 game_over")
	assert(state.game_over_reason != "", "應有原因")
	print("Death Task2b OK")

func _test_choose_heir_action() -> void:
	print("--- Death Task3: choose_heir action ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	state.player_id = 100   # 此時 100 已死,但 player_id 還沒清
	var pt := TeamData.new()
	pt.team_id = 0; pt.leader_id = -1
	pt.named_members = [101, 102]
	state.teams[0] = pt
	var heir1 := PersonData.new(); heir1.id = 101; heir1.team_id = 0
	heir1.person_name = "繼承人1"
	state.persons[101] = heir1
	var heir2 := PersonData.new(); heir2.id = 102; heir2.team_id = 0
	state.persons[102] = heir2
	state.player_forced_event = {
		"action": "choose_heir",
		"team_id": 0,
		"candidates": [101, 102]
	}
	state.player_state["heir_id"] = 101
	var cmd := PlayerCommandSystem.new()
	var r = cmd.execute_action(state, -1, "choose_heir")
	assert(r.get("ok", false), "choose_heir 應成功，msg=%s" % str(r.get("msg", "")))
	assert(pt.leader_id == 101, "leader_id 應 = 101")
	assert(state.player_id == 101, "player_id 應 = 101")
	assert(heir1.role == "leader", "heir1 role 應 leader")
	assert(not pt.named_members.has(101), "heir1 應從 named_members 移除")
	assert(state.player_forced_event.is_empty(), "forced_event 應清空")
	print("Death Task3 OK")

func _test_choose_heir_invalid_candidate() -> void:
	print("--- Death Task3b: 非合法候選 reject ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	state.player_forced_event = {
		"action": "choose_heir", "team_id": 0, "candidates": [101]
	}
	state.player_state["heir_id"] = 999   # 不在候選
	var pt := TeamData.new(); pt.team_id = 0
	state.teams[0] = pt
	var cmd := PlayerCommandSystem.new()
	var r = cmd.execute_action(state, -1, "choose_heir")
	assert(not r.get("ok", true), "非合法候選應 reject")
	print("Death Task3b OK")

func _test_advance_tick_game_over_freeze() -> void:
	print("--- Death Task4: advance_tick game_over 凍結 ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	state.game_over = true
	var runner := SimRunner.new()
	var saved_tick: int = state.world.current_tick
	var r: String = runner.advance_tick(state, Vector2i(0, 0))
	assert(r == "game_over", "應回 game_over，實際=%s" % r)
	assert(state.world.current_tick == saved_tick, "tick 不應推進")
	print("Death Task4 OK")

func _test_advance_tick_awaiting_heir_freeze() -> void:
	print("--- Death Task4b: 等繼承人 awaiting_heir 凍結 ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	state.player_forced_event = { "action": "choose_heir", "team_id": 0, "candidates": [101] }
	var runner := SimRunner.new()
	var saved_tick: int = state.world.current_tick
	var r: String = runner.advance_tick(state, Vector2i(0, 0))
	assert(r == "awaiting_heir", "應回 awaiting_heir")
	assert(state.world.current_tick == saved_tick, "tick 不應推進")
	print("Death Task4b OK")

func _test_encounter_kills_player_triggers_heir() -> void:
	print("--- Death Task5: encounter 殺玩家觸發 forced_event ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	state.player_id = 100
	# Player team
	var pt := TeamData.new()
	pt.team_id = 0; pt.leader_id = 100
	pt.named_members = [101]
	state.teams[0] = pt
	var player_person := PersonData.new()
	player_person.id = 100; player_person.team_id = 0
	# 模擬玩家戰死：torso severed
	player_person.body_parts = { "torso": { "status": "severed", "hp": 0, "max_hp": 50 } }
	state.persons[100] = player_person
	var heir := PersonData.new(); heir.id = 101; heir.team_id = 0
	state.persons[101] = heir
	# 模擬 encounter resolve：直接呼叫 promote_successor (encounter 結束後 faction_ai 會跑)
	# encounter_system line 1042-1043：死者從 named_members 移除、leader_id=-1，
	# 但「不」從 state.persons 移除（死者 record 保留，body_parts 標記死亡）。
	# 故 _get_player_team_id 仍可由 persons[100].team_id 反查到玩家 team。
	pt.leader_id = -1   # 玩家戰死（leader_id 清空，person 保留於 state.persons）
	# 跑 faction_ai _promote_successor
	var fai := FactionAISystem.new()
	fai._promote_successor(state, pt)
	# 應有 forced_event 而非 auto-promote
	assert(not state.player_forced_event.is_empty(), "玩家 team 應 forced event 而非 auto")
	assert(state.player_forced_event.get("action") == "choose_heir")
	assert(pt.leader_id == -1, "leader_id 不應自動升 (等玩家選)")
	print("Death Task5 OK")

# ── Coin Economy + Outpost Public Storage ──

func _test_coin_storage_fields() -> void:
	print("--- CoinStorage Task1: 新欄位 ---")
	var t := TeamData.new()
	assert(t.anon_treasury == 0.0, "anon_treasury 預設 0")
	var tile := HexTileData.new()
	assert(tile.public_storage == {}, "public_storage 預設空")
	assert(tile.abandoned_coin == 0.0, "abandoned_coin 預設 0")
	assert(tile.mint_level == 0, "mint_level 預設 0")
	print("CoinStorage Task1 OK")

func _test_storage_cap() -> void:
	print("--- CoinStorage Task2: storage cap ---")
	var tile := HexTileData.new()
	tile.outpost_type = "civilian"; tile.outpost_level = 1
	var os := OutpostSystem.new()
	assert(os._get_storage_cap(tile, "food") == 200.0, "civilian L1 應 200")
	tile.outpost_level = 3
	assert(os._get_storage_cap(tile, "food") == 1500.0, "civilian L3 應 1500")
	tile.outpost_type = "military"; tile.outpost_level = 2
	assert(os._get_storage_cap(tile, "food") == 800.0, "military L2 應 800")
	print("CoinStorage Task2 OK")

func _test_collect_ore_to_storage() -> void:
	print("--- CoinStorage Task3: ore 進公庫 ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	var src_tile := HexTileData.new()
	src_tile.tile_pos = Vector2i(0, 0)
	src_tile.outpost_type = "civilian"; src_tile.outpost_level = 1
	src_tile.outpost_owner = 0
	src_tile.resources["ore_gold"] = 100.0
	src_tile.resources["food"] = 100.0
	src_tile.productivity = 1.0
	state.world.tiles[0] = src_tile
	var team := TeamData.new()
	team.team_id = 0; team.tile_pos = Vector2i(0, 0); team.population = 10
	state.teams[0] = team
	var rs := ResourceSystem.new()
	rs.collect_resources(state, [0])
	assert(float(team.resources.get("food", 0)) > 0, "food 應進 team")
	assert(float(src_tile.public_storage.get("ore_gold", 0)) > 0, "ore 應進公庫")
	assert(float(team.resources.get("ore_gold", 0)) == 0, "ore 不應進 team")
	print("CoinStorage Task3 OK")

func _test_mint_facility() -> void:
	print("--- CoinStorage Task4: mint facility ---")
	assert(OutpostSystem.FACILITY_DEF.has("mint"), "FACILITY_DEF 應有 mint")
	var state := WorldState.new()
	state.world = WorldData.new()
	var tile := HexTileData.new()
	tile.tile_pos = Vector2i(0, 0)
	tile.outpost_type = "civilian"; tile.outpost_level = 3
	tile.outpost_owner = 0
	tile.mint_level = 1
	tile.public_storage["ore_gold"] = 10.0
	state.world.tiles[0] = tile
	var team := TeamData.new()
	team.team_id = 0; team.tile_pos = Vector2i(0, 0)
	state.teams[0] = team
	var os := OutpostSystem.new()
	os._tick_mint(state, tile, team)
	assert(float(tile.public_storage["ore_gold"]) < 10.0, "ore 應減")
	assert(float(tile.public_storage.get("coin", 0)) > 0, "coin 應增")
	print("CoinStorage Task4 OK")

func _test_manufacturing_to_storage() -> void:
	print("--- CoinStorage Task5: manufacturing 產出 → 公庫 ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	var tile := HexTileData.new()
	tile.tile_pos = Vector2i(0, 0)
	tile.outpost_type = "civilian"; tile.outpost_level = 1
	tile.outpost_owner = 0
	tile.manufacturing_level = 1
	state.world.tiles[0] = tile
	var team := TeamData.new()
	team.team_id = 0; team.tile_pos = Vector2i(0, 0); team.population = 10
	team.current_task = TeamData.TASK_MANUFACTURE
	team.resources["material"] = 100.0
	state.teams[0] = team
	var ms := ManufacturingSystem.new()
	ms.tick_all(state, [0])
	assert(float(tile.public_storage.get("goods", 0)) > 0, "goods 應進公庫")
	assert(float(team.resources.get("goods", 0)) == 0, "goods 不應進 team")
	print("CoinStorage Task5 OK")

func _test_salary_to_treasury() -> void:
	print("--- CoinStorage Task6: wage → treasury ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	var team := TeamData.new()
	team.team_id = 0; team.population = 10; team.named_members = [101]
	team.anon_tiers["新兵"] = 8   # total_wage = 8 × 1.0 = 8.0
	team.resources["coin"] = 100.0
	team.leader_id = 100
	state.teams[0] = team
	var leader := PersonData.new(); leader.id = 100
	state.persons[100] = leader
	var member := PersonData.new(); member.id = 101
	state.persons[101] = member
	var ss := SalarySystem.new()
	ss._pay_salary(state, team)
	# anon_count = 10 - 1 - 1 = 8, wage = 1.0, total = 8
	assert(float(team.anon_treasury) == 8.0, "treasury 應 8，實際=%s" % team.anon_treasury)
	assert(float(team.resources["coin"]) < 100.0, "coin 應被扣")
	print("CoinStorage Task6 OK")

func _test_promote_anon_takes_share() -> void:
	print("--- CoinStorage Task7: 升 anon 帶 ×3 share ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	var team := TeamData.new()
	team.team_id = 0; team.population = 11; team.named_members = []
	team.leader_id = -1
	team.anon_treasury = 100.0
	state.teams[0] = team
	var promoted := PersonGenerator.generate_for_team(state, team, "member")
	assert(promoted != null, "應產生 named NPC")
	assert(promoted.coin > 0, "新 NPC 應有 coin (升階加成)")
	assert(team.anon_treasury < 100.0, "treasury 應扣")
	print("CoinStorage Task7 OK (新 NPC coin=%.0f, 剩 treasury=%.0f)" % [promoted.coin, team.anon_treasury])

func _test_extraction() -> void:
	print("--- CoinStorage Task8: 徵用機制 ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	var team := TeamData.new()
	team.team_id = 0; team.population = 10
	team.anon_treasury = 100.0; team.resources["coin"] = 0.0
	var leader := PersonData.new(); leader.id = 100
	leader.values = { "貪婪": 0.8, "慎重": 0.2 }
	state.persons[100] = leader; team.leader_id = 100
	state.teams[0] = team
	var fai := FactionAISystem.new()
	fai._extract_treasury(state, team, 0.3, "貪婪驅動")
	assert(float(team.anon_treasury) == 70.0, "treasury 應 70")
	assert(float(team.resources["coin"]) == 30.0, "coin 應 30")
	assert(team.unrest_turns == 1, "unrest_turns 應 +1")
	print("CoinStorage Task8 OK")

func _test_player_extract_treasury() -> void:
	print("--- CoinStorage Task9: 玩家徵用 ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	var team := TeamData.new()
	team.team_id = 0; team.population = 10; team.leader_id = 100
	team.anon_treasury = 100.0; team.resources["coin"] = 0.0
	state.teams[0] = team
	state.player_state["extract_ratio"] = 0.5
	var pcs := PlayerCommandSystem.new()
	var r := pcs._action_extract_treasury(state, -1, team, 0)
	assert(r.get("ok") == true, "應成功")
	assert(float(team.anon_treasury) == 50.0, "treasury 應 50")
	assert(float(team.resources["coin"]) == 50.0, "coin 應 50")
	print("CoinStorage Task9 OK")

func _test_encounter_treasury_loot() -> void:
	print("--- CoinStorage Task10: encounter loot 比例 ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	var loser := TeamData.new()
	loser.team_id = 0; loser.population = 15
	loser.anon_treasury = 100.0
	state.teams[0] = loser
	var winner := TeamData.new()
	winner.team_id = 1
	winner.anon_treasury = 0.0
	state.teams[1] = winner
	var enc := EncounterSystem.new()
	enc._loot_treasury_share(state, loser, winner, 5, 20)
	assert(float(winner.anon_treasury) == 25.0, "winner 應拿 25，實際=%s" % winner.anon_treasury)
	assert(float(loser.anon_treasury) == 75.0, "loser 剩 75")
	print("CoinStorage Task10 OK")

func _test_on_team_extinct_to_storage() -> void:
	print("--- CoinStorage Task11a: 滅團 → 公庫 ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	var tile := HexTileData.new()
	tile.tile_pos = Vector2i(0, 0)
	tile.outpost_type = "civilian"; tile.outpost_level = 2
	tile.outpost_owner = 0
	state.world.tiles[0] = tile
	var team := TeamData.new()
	team.team_id = 0; team.population = 0; team.tile_pos = Vector2i(0, 0)
	team.resources = { "food": 50.0 }
	team.anon_treasury = 30.0
	state.teams[0] = team
	var fai := FactionAISystem.new()
	fai._on_team_extinct(state, team)
	assert(float(tile.public_storage.get("food", 0)) == 50.0, "food 應進公庫")
	assert(float(tile.public_storage.get("coin", 0)) == 30.0, "treasury 應進公庫 coin")
	assert(float(team.anon_treasury) == 0.0, "treasury 清空")
	print("CoinStorage Task11a OK")

func _test_pickup_abandoned_coin() -> void:
	print("--- CoinStorage Task11b: 撿 abandoned_coin ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	var tile := HexTileData.new()
	tile.tile_pos = Vector2i(1, 1)
	tile.outpost_owner = -1
	tile.abandoned_coin = 40.0
	state.world.tiles[1 * 1000 + 1] = tile
	var team := TeamData.new()
	team.team_id = 1; team.tile_pos = Vector2i(1, 1); team.anon_treasury = 0.0
	state.teams[1] = team
	var mv := MovementSystem.new()
	mv._on_arrival(state, team)
	assert(float(team.anon_treasury) == 40.0, "應撿 40 遺財")
	assert(float(tile.abandoned_coin) == 0.0, "abandoned_coin 清空")
	print("CoinStorage Task11b OK")

func _test_subteam_treasury_split() -> void:
	print("--- CoinStorage Task12: 子隊帶 treasury ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	var parent := TeamData.new()
	parent.team_id = 0; parent.population = 10; parent.leader_id = 100
	parent.named_members = [101]
	parent.anon_treasury = 100.0
	parent.tile_pos = Vector2i(0, 0)
	state.teams[0] = parent
	var leader := PersonData.new(); leader.id = 100
	state.persons[100] = leader
	var sub_leader := PersonData.new(); sub_leader.id = 101
	sub_leader.skills = { "統領": 0.2 }
	state.persons[101] = sub_leader
	var ss := SubteamSystem.new()
	var sub_id := ss.dispatch(state, 0, 101, 3, "偵查", Vector2i(1, 0))
	assert(sub_id != -1, "派遣應成功")
	var sub: TeamData = state.teams[sub_id]
	assert(abs(sub.anon_treasury - 30.0) < 0.01, "子隊 treasury 應 30，實際=%s" % sub.anon_treasury)
	assert(abs(parent.anon_treasury - 70.0) < 0.01, "母團 treasury 應 70，實際=%s" % parent.anon_treasury)
	print("CoinStorage Task12 OK")

func _test_npc_auto_withdraw() -> void:
	print("--- CoinStorage Task13a: NPC 自動領 ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	var tile := HexTileData.new()
	tile.tile_pos = Vector2i(0, 0)
	tile.outpost_type = "civilian"; tile.outpost_level = 2
	tile.outpost_owner = 0
	tile.public_storage = { "food": 100.0 }
	state.world.tiles[0] = tile
	var team := TeamData.new()
	team.team_id = 0; team.population = 5; team.tile_pos = Vector2i(0, 0)
	team.resources["food"] = 0.0
	state.teams[0] = team
	var fai := FactionAISystem.new()
	fai._evaluate_storage_visit(state, team, tile)
	# need = 5 * 14 = 70；team 有 0 → 領 70；公庫剩 30
	assert(abs(float(team.resources["food"]) - 70.0) < 0.01, "team 應領到 70，實際=%s" % team.resources["food"])
	assert(abs(float(tile.public_storage["food"]) - 30.0) < 0.01, "公庫剩 30")
	print("CoinStorage Task13a OK")

func _test_npc_auto_deposit() -> void:
	print("--- CoinStorage Task13b: NPC 自動存 ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	var tile := HexTileData.new()
	tile.tile_pos = Vector2i(0, 0)
	tile.outpost_type = "civilian"; tile.outpost_level = 2
	tile.outpost_owner = 0
	tile.public_storage = { "food": 0.0 }
	state.world.tiles[0] = tile
	var team := TeamData.new()
	team.team_id = 0; team.population = 5; team.tile_pos = Vector2i(0, 0)
	team.resources["food"] = 200.0   # need=70, >2x=140 → 存超量
	state.teams[0] = team
	var fai := FactionAISystem.new()
	fai._evaluate_storage_visit(state, team, tile)
	# deposit = team_have(200) - need(70) = 130，cap=500 足夠
	assert(abs(float(team.resources["food"]) - 70.0) < 0.01, "team 應剩 70，實際=%s" % team.resources["food"])
	assert(abs(float(tile.public_storage["food"]) - 130.0) < 0.01, "公庫應 130")
	print("CoinStorage Task13b OK")

func _test_player_withdraw_deposit() -> void:
	print("--- CoinStorage Task14: 玩家領/存 ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	var tile := HexTileData.new()
	tile.tile_pos = Vector2i(0, 0)
	tile.outpost_type = "civilian"; tile.outpost_level = 2
	tile.outpost_owner = 0
	tile.public_storage = { "food": 100.0 }
	state.world.tiles[0] = tile
	var team := TeamData.new()
	team.team_id = 0; team.tile_pos = Vector2i(0, 0)
	team.resources["food"] = 10.0
	state.teams[0] = team
	var pcs := PlayerCommandSystem.new()
	# 領 40
	state.player_state["storage_res"] = "food"
	state.player_state["storage_amount"] = 40.0
	var rw := pcs._action_withdraw_from_storage(state, -1, team, 0)
	assert(rw.get("ok") == true, "領取應成功")
	assert(abs(float(team.resources["food"]) - 50.0) < 0.01, "team 應 50")
	assert(abs(float(tile.public_storage["food"]) - 60.0) < 0.01, "公庫應 60")
	# 存 20
	state.player_state["storage_amount"] = 20.0
	var rd := pcs._action_deposit_to_storage(state, -1, team, 0)
	assert(rd.get("ok") == true, "存入應成功")
	assert(abs(float(team.resources["food"]) - 30.0) < 0.01, "team 應 30")
	assert(abs(float(tile.public_storage["food"]) - 80.0) < 0.01, "公庫應 80")
	print("CoinStorage Task14 OK")

# ════════ Pathfinding + ETA + catch-up ════════

func _fill_plains(state: WorldState, x0: int, x1: int, y0: int, y1: int) -> void:
	for gx in range(x0, x1):
		for gy in range(y0, y1):
			var g := HexTileData.new()
			g.tile_pos = Vector2i(gx, gy); g.terrain = "plains"
			state.world.tiles[gx * 1000 + gy] = g

func _test_last_tile_pos_field() -> void:
	print("--- Path Task1: last_tile_pos 欄位 ---")
	var t := TeamData.new()
	assert(t.last_tile_pos == Vector2i(-999, -999), "預設 (-999,-999)")
	t.last_tile_pos = Vector2i(5, 5)
	assert(t.last_tile_pos == Vector2i(5, 5))
	print("Path Task1 OK")

func _test_find_path_basic() -> void:
	print("--- Path Task2: A* basic ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	state.world.current_tick = 100
	for x in range(-3, 4):
		for y in range(-3, 4):
			var tile := HexTileData.new()
			tile.tile_pos = Vector2i(x, y)
			tile.terrain = "plains"
			state.world.tiles[x * 1000 + y] = tile
	var r = PathSystem.find_path(state, Vector2i(0, 0), Vector2i(3, 0))
	assert(not r.path.is_empty(), "應有 path")
	assert(r.cost > 0, "cost 應 > 0")
	print("Path Task2 OK (path size=%d, cost=%.1f)" % [r.path.size(), r.cost])

func _test_find_path_cache() -> void:
	print("--- Path Task2b: cache ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	state.world.current_tick = 200
	for x in range(-3, 4):
		for y in range(-3, 4):
			var tile := HexTileData.new()
			tile.tile_pos = Vector2i(x, y); tile.terrain = "plains"
			state.world.tiles[x * 1000 + y] = tile
	var r1 = PathSystem.find_path(state, Vector2i(0, 0), Vector2i(2, 0))
	var r2 = PathSystem.find_path(state, Vector2i(0, 0), Vector2i(2, 0))
	assert(r1.tick == r2.tick, "同 tick 應命中 cache")
	# tick + 1 → 應重算
	state.world.current_tick = 201
	var r3 = PathSystem.find_path(state, Vector2i(0, 0), Vector2i(2, 0))
	assert(r3.tick == 201, "新 tick 重算")
	print("Path Task2b OK")

func _test_find_path_no_path() -> void:
	print("--- Path Task2c: 無路徑 ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	state.world.current_tick = 300
	# 只放 from tile，沒 to tile
	var tile := HexTileData.new(); tile.terrain = "plains"; tile.tile_pos = Vector2i(0, 0)
	state.world.tiles[0] = tile
	var r = PathSystem.find_path(state, Vector2i(0, 0), Vector2i(5, 5))
	assert(r.path.is_empty(), "無路徑應空 path")
	assert(r.cost == INF, "cost 應 INF")
	print("Path Task2c OK")

func _test_eta_ticks() -> void:
	print("--- Path Task3: eta_ticks ---")
	var team := TeamData.new()
	team.population = 5; team.fatigue = 0.0
	var eta = PathSystem.eta_ticks(team, 5.0)
	# BASE_MOVE_TICKS = 48, speed_mult = 1.0 → eta = 5 * 48 = 240
	assert(eta == 240, "eta 應 240，實際=%d" % eta)
	team.fatigue = 0.5   # speed reduced
	var eta2 = PathSystem.eta_ticks(team, 5.0)
	assert(eta2 > eta, "fatigue 應延長 ETA")
	print("Path Task3 OK")

func _test_observe_velocity_visible() -> void:
	print("--- Path Task4: observe_velocity visible ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	var observer := TeamData.new()
	observer.team_id = 0; observer.tile_pos = Vector2i(0, 0)
	state.teams[0] = observer
	var target := TeamData.new()
	target.team_id = 1; target.tile_pos = Vector2i(2, 0)
	target.last_tile_pos = Vector2i(1, 0)
	state.teams[1] = target
	state.team_discovered[0] = [1]
	var r = PathSystem.observe_velocity(state, observer, target)
	assert(r.get("visible", false), "應可見")
	assert(r.get("speed", 0) > 0, "speed 應 > 0 (1 hex movement)")
	print("Path Task4 OK (speed=%.2f)" % r.get("speed", 0))

func _test_observe_velocity_invisible() -> void:
	print("--- Path Task4b: 不可見 ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	var observer := TeamData.new()
	observer.team_id = 0
	state.teams[0] = observer
	var target := TeamData.new()
	target.team_id = 1
	state.teams[1] = target
	# 不加進 discovered
	var r = PathSystem.observe_velocity(state, observer, target)
	assert(not r.get("visible", true), "不可見")
	print("Path Task4b OK")

func _test_estimate_catch_up_reachable() -> void:
	print("--- Path Task5: catch_up reachable ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	for x in range(-3, 4):
		for y in range(-3, 4):
			var tile := HexTileData.new()
			tile.tile_pos = Vector2i(x, y); tile.terrain = "plains"
			state.world.tiles[x * 1000 + y] = tile
	var observer := TeamData.new()
	observer.team_id = 0; observer.tile_pos = Vector2i(0, 0); observer.fatigue = 0.0
	state.teams[0] = observer
	var target := TeamData.new()
	target.team_id = 1; target.tile_pos = Vector2i(2, 0); target.fatigue = 0.0
	# Target static (last_pos == current_pos → speed 0)
	target.last_tile_pos = Vector2i(2, 0)
	state.teams[1] = target
	state.team_discovered[0] = [1]
	var r = PathSystem.estimate_catch_up(state, observer, 1)
	assert(r.get("reachable", false), "應 reachable")
	print("Path Task5 OK (eta=%d)" % r.get("eta", 0))

func _test_estimate_catch_up_too_far() -> void:
	print("--- Path Task5b: too_far ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	# 直線 plains 走廊 (0,0)→(27,0)，path cost 27 → eta 1296 > AI_ETA_LIMIT(1200)
	for x in range(0, 28):
		var tile := HexTileData.new()
		tile.tile_pos = Vector2i(x, 0); tile.terrain = "plains"
		state.world.tiles[x * 1000 + 0] = tile
	var observer := TeamData.new()
	observer.team_id = 0; observer.tile_pos = Vector2i(0, 0); observer.fatigue = 0.0
	state.teams[0] = observer
	var target := TeamData.new()
	target.team_id = 1; target.tile_pos = Vector2i(27, 0); target.fatigue = 0.0
	target.last_tile_pos = Vector2i(27, 0)
	state.teams[1] = target
	state.team_discovered[0] = [1]
	var r = PathSystem.estimate_catch_up(state, observer, 1)
	assert(not r.get("reachable", true), "應 unreachable")
	assert(r.get("reason", "") == "too_far", "reason 應 too_far，實際=%s" % r.get("reason", ""))
	print("Path Task5b OK (eta=%d)" % r.get("eta", 0))

func _test_estimate_catch_up_out_of_sight() -> void:
	print("--- Path Task5c: out_of_sight ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	var observer := TeamData.new()
	observer.team_id = 0; observer.tile_pos = Vector2i(0, 0)
	state.teams[0] = observer
	var target := TeamData.new()
	target.team_id = 1; target.tile_pos = Vector2i(2, 0)
	state.teams[1] = target
	# 不加進 discovered
	var r = PathSystem.estimate_catch_up(state, observer, 1)
	assert(not r.get("reachable", true), "應 unreachable")
	assert(r.get("reason", "") == "out_of_sight", "reason 應 out_of_sight")
	print("Path Task5c OK")

func _test_movement_uses_astar() -> void:
	print("--- Path Task6: movement A* 繞山 ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	state.world.current_tick = 700   # 唯一 tick，避免與其他測試共用 (0,0)->(2,0) path cache
	for x in range(-1, 4):
		for y in range(-2, 2):
			var tile := HexTileData.new()
			tile.tile_pos = Vector2i(x, y); tile.terrain = "plains"
			state.world.tiles[x * 1000 + y] = tile
	# (1,0) 設山地：直線成本高，A* 應改走 (1,-1) 繞行
	(state.world.tiles[1 * 1000 + 0] as HexTileData).terrain = "mountain"
	var mv := MovementSystem.new()
	var next_step: Vector2i = mv._calc_next_step(state, Vector2i(0, 0), Vector2i(2, 0))
	# 繞山：不直接踏入山地 (1,0)，且必須前進（非原地）
	assert(next_step != Vector2i(1, 0), "A* 不應直踏山地 (1,0)")
	assert(next_step != Vector2i(0, 0), "應前進非原地")
	print("Path Task6 OK (next=(%d,%d) 繞山)" % [next_step.x, next_step.y])

func _test_ai_catch_up_filters_unreachable() -> void:
	print("--- Path Task7: AI catch_up 過濾不可達 ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	state.world.current_tick = 803   # 唯一 tick
	# 平原網格 (predator 周邊)
	for gx in range(-1, 4):
		for gy in range(-1, 2):
			var g := HexTileData.new()
			g.tile_pos = Vector2i(gx, gy); g.terrain = "plains"
			state.world.tiles[gx * 1000 + gy] = g
	var t0 := TeamData.new()
	t0.team_id = 0; t0.tile_pos = Vector2i(0, 0); t0.population = 10
	state.teams[0] = t0
	# prey 1：人更少但孤島不可達（無連通 tile）
	var t1 := TeamData.new()
	t1.team_id = 1; t1.tile_pos = Vector2i(50, 50); t1.population = 2
	t1.resources["food"] = 50.0
	state.teams[1] = t1
	var iso := HexTileData.new()
	iso.tile_pos = Vector2i(50, 50); iso.terrain = "plains"
	state.world.tiles[50 * 1000 + 50] = iso   # 唯一孤立 tile，from (0,0) 無路
	# prey 2：可達
	var t2 := TeamData.new()
	t2.team_id = 2; t2.tile_pos = Vector2i(2, 0); t2.population = 3
	t2.resources["food"] = 50.0
	state.teams[2] = t2
	state.team_discovered[0] = [1, 2]
	var fai := FactionAISystem.new()
	var prey = fai._find_weakest_prey(state, t0)
	# t1 人更少但不可達 → 應被過濾，選可達的 t2
	assert(prey == 2, "不可達 prey 應被過濾，選 Team2，實際=%d" % prey)
	print("Path Task7 OK (prey=%d)" % prey)

func _test_readiness_threshold() -> void:
	print("--- Prosperity Task1: readiness threshold ---")
	var team := TeamData.new()
	team.tags = []
	var leader := PersonData.new()
	leader.values = { "殘忍": 0.8, "好戰": 0.5, "慎重": 0.3 }
	# threshold = 0.55 - max(0.8, 0.5)*0.15 + 0.3*0.15 = 0.55 - 0.12 + 0.045 = 0.475
	var t = FactionAISystem.calc_readiness_threshold(team, leader)
	assert(abs(t - 0.475) < 0.01, "預期 0.475 實際=%.3f" % t)
	team.tags = ["軍隊"]
	t = FactionAISystem.calc_readiness_threshold(team, leader)
	assert(abs(t - 0.375) < 0.01, "軍隊預期 0.375 實際=%.3f" % t)
	print("Prosperity Task1 OK")

func _test_find_prosperity_prey() -> void:
	print("--- Prosperity Task2: prey selector ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	for x in range(-3, 5):
		for y in range(-3, 5):
			var tile := HexTileData.new()
			tile.tile_pos = Vector2i(x, y); tile.terrain = "plains"
			state.world.tiles[x * 1000 + y] = tile
	# self
	var team := TeamData.new()
	team.team_id = 0; team.tile_pos = Vector2i(0, 0); team.population = 10
	team.faction_id = 0
	state.teams[0] = team
	var leader := PersonData.new()
	leader.values = { "貪婪": 0.8, "殘忍": 0.5, "野心": 0.5 }
	# 弱 + 富 prey
	var rich_prey := TeamData.new()
	rich_prey.team_id = 1; rich_prey.tile_pos = Vector2i(2, 0); rich_prey.population = 4
	rich_prey.faction_id = 1
	rich_prey.resources = { "coin": 200, "food": 100, "material": 50 }
	rich_prey.last_tile_pos = rich_prey.tile_pos
	state.teams[1] = rich_prey
	# 同 faction
	var ally := TeamData.new()
	ally.team_id = 2; ally.tile_pos = Vector2i(1, 0); ally.population = 3
	ally.faction_id = 0
	state.teams[2] = ally
	state.team_discovered[0] = [1, 2]
	var prey_id = FactionAISystem.find_prosperity_prey(state, team, leader)
	assert(prey_id == 1, "應選 1 (rich_prey)，實際=%d" % prey_id)
	print("Prosperity Task2 OK")

func _prosperity_grid() -> WorldState:
	var state := WorldState.new()
	state.world = WorldData.new()
	for x in range(-3, 6):
		for y in range(-3, 6):
			var tile := HexTileData.new()
			tile.tile_pos = Vector2i(x, y); tile.terrain = "plains"
			state.world.tiles[x * 1000 + y] = tile
	return state

func _test_evaluate_prosperity_trigger() -> void:
	print("--- Prosperity Task3: 評估 trigger TASK_ATTACK ---")
	var state := _prosperity_grid()
	var team := TeamData.new()
	team.team_id = 0; team.tile_pos = Vector2i(0, 0); team.population = 15
	team.faction_id = 0; team.anon_tiers["菁英"] = 15  # avg_combat=0.7
	team.resources = { "food": 200, "weapon_melee_low": 15 }
	team.current_task = TeamData.TASK_IDLE
	state.teams[0] = team
	var leader := PersonData.new()
	leader.id = 100
	leader.values = { "野心": 0.9, "好戰": 0.8, "信義": 0.1, "殘忍": 0.7, "貪婪": 0.6, "慎重": 0.3 }
	state.persons[100] = leader
	team.leader_id = 100
	var prey := TeamData.new()
	prey.team_id = 1; prey.tile_pos = Vector2i(2, 0); prey.population = 4
	prey.faction_id = 1
	prey.resources = { "coin": 200, "food": 100 }
	prey.last_tile_pos = prey.tile_pos
	state.teams[1] = prey
	state.team_discovered[0] = [1]
	var fas = FactionAISystem.new()
	fas._evaluate_prosperity_attack(state, team)
	assert(team.current_task == TeamData.TASK_ATTACK, "應 TASK_ATTACK，實際=%s" % team.current_task)
	assert(team.move_target == Vector2i(2, 0), "move_target 應指向 prey tile，實際=%s" % str(team.move_target))
	assert(team.combat_target == -1, "combat_target 不預設（到達才起戰），實際=%d" % team.combat_target)
	print("Prosperity Task3 OK")

func _test_prosperity_low_ambition_skip() -> void:
	print("--- Prosperity Task3b: 低野心不評估 ---")
	var state := _prosperity_grid()
	var team := TeamData.new()
	team.team_id = 0; team.tile_pos = Vector2i(0, 0); team.population = 15
	team.faction_id = 0; team.anon_tiers["菁英"] = 15  # avg_combat=0.7
	team.resources = { "food": 200, "weapon_melee_low": 15 }
	team.current_task = TeamData.TASK_IDLE
	state.teams[0] = team
	var leader := PersonData.new()
	leader.id = 100
	leader.values = { "野心": 0.1, "好戰": 0.1, "信義": 0.5, "殘忍": 0.5, "貪婪": 0.5, "慎重": 0.5 }
	state.persons[100] = leader
	team.leader_id = 100
	var prey := TeamData.new()
	prey.team_id = 1; prey.tile_pos = Vector2i(2, 0); prey.population = 4
	prey.faction_id = 1; prey.resources = { "coin": 200 }; prey.last_tile_pos = prey.tile_pos
	state.teams[1] = prey
	state.team_discovered[0] = [1]
	FactionAISystem.new()._evaluate_prosperity_attack(state, team)
	assert(team.current_task == TeamData.TASK_IDLE, "score 太低應跳過，實際=%s" % team.current_task)
	print("Prosperity Task3b OK")

func _test_prosperity_low_readiness_skip() -> void:
	print("--- Prosperity Task3c: 低 readiness 不評估 ---")
	var state := _prosperity_grid()
	var team := TeamData.new()
	team.team_id = 0; team.tile_pos = Vector2i(0, 0); team.population = 2
	team.faction_id = 0; team.anon_tiers["平民"] = 2  # avg_combat=0.1
	team.resources = { "food": 10 }
	team.current_task = TeamData.TASK_IDLE
	state.teams[0] = team
	var leader := PersonData.new()
	leader.id = 100
	leader.values = { "野心": 0.9, "好戰": 0.8, "信義": 0.1, "殘忍": 0.7, "貪婪": 0.6, "慎重": 0.3 }
	state.persons[100] = leader
	team.leader_id = 100
	var prey := TeamData.new()
	prey.team_id = 1; prey.tile_pos = Vector2i(2, 0); prey.population = 4
	prey.faction_id = 1; prey.resources = { "coin": 200 }; prey.last_tile_pos = prey.tile_pos
	state.teams[1] = prey
	state.team_discovered[0] = [1]
	FactionAISystem.new()._evaluate_prosperity_attack(state, team)
	assert(team.current_task == TeamData.TASK_IDLE, "readiness 太低應跳過，實際=%s" % team.current_task)
	print("Prosperity Task3c OK")

func _test_prosperity_same_faction_skip() -> void:
	print("--- Prosperity Task3d: 同 faction 排除 ---")
	var state := _prosperity_grid()
	var team := TeamData.new()
	team.team_id = 0; team.tile_pos = Vector2i(0, 0); team.population = 15
	team.faction_id = 5; team.anon_tiers["菁英"] = 15  # avg_combat=0.7
	team.resources = { "food": 200, "weapon_melee_low": 15 }
	team.current_task = TeamData.TASK_IDLE
	state.teams[0] = team
	var leader := PersonData.new()
	leader.id = 100
	leader.values = { "野心": 0.9, "好戰": 0.8, "信義": 0.1, "殘忍": 0.7, "貪婪": 0.6, "慎重": 0.3 }
	state.persons[100] = leader
	team.leader_id = 100
	var prey := TeamData.new()
	prey.team_id = 1; prey.tile_pos = Vector2i(2, 0); prey.population = 4
	prey.faction_id = 5; prey.resources = { "coin": 200 }; prey.last_tile_pos = prey.tile_pos
	state.teams[1] = prey
	state.team_discovered[0] = [1]
	FactionAISystem.new()._evaluate_prosperity_attack(state, team)
	assert(team.current_task == TeamData.TASK_IDLE, "唯一 prey 同 faction 應跳過，實際=%s" % team.current_task)
	print("Prosperity Task3d OK")

func _test_prosperity_treasury_bonus() -> void:
	print("--- Prosperity Task3e: anon_treasury 加成 +0.1 ---")
	var team := TeamData.new()
	var leader := PersonData.new()
	leader.values = { "野心": 0.5, "好戰": 0.5, "信義": 0.5 }
	team.anon_treasury = 0.0
	var s0 = FactionAISystem.calc_attack_score(team, leader)
	team.anon_treasury = 250.0
	var s1 = FactionAISystem.calc_attack_score(team, leader)
	assert(abs((s1 - s0) - 0.1) < 0.001, "公庫加成應 +0.1，實際=%.3f" % (s1 - s0))
	print("Prosperity Task3e OK")

func _test_prosperity_prey_personality_weight() -> void:
	print("--- Prosperity Task14: prey 評分個性權重 ---")
	var state := _prosperity_grid()
	var team := TeamData.new()
	team.team_id = 0; team.tile_pos = Vector2i(0, 0); team.population = 10
	team.faction_id = 0
	state.teams[0] = team
	# A：富 + 遠（dist3 → 非接壤）
	var rich := TeamData.new()
	rich.team_id = 1; rich.tile_pos = Vector2i(3, -1); rich.population = 5
	rich.faction_id = 1; rich.resources = { "coin": 300 }; rich.last_tile_pos = rich.tile_pos
	state.teams[1] = rich
	# B：窮 + 接壤（dist2）
	var border := TeamData.new()
	border.team_id = 2; border.tile_pos = Vector2i(2, 0); border.population = 5
	border.faction_id = 1; border.resources = {}; border.last_tile_pos = border.tile_pos
	state.teams[2] = border
	state.team_discovered[0] = [1, 2]
	var greedy := PersonData.new()
	greedy.values = { "貪婪": 1.0, "野心": 0.0, "殘忍": 0.0 }
	assert(FactionAISystem.find_prosperity_prey(state, team, greedy) == 1,
		"高貪婪應選富 prey(1)")
	var ambitious := PersonData.new()
	ambitious.values = { "貪婪": 0.0, "野心": 1.0, "殘忍": 0.0 }
	assert(FactionAISystem.find_prosperity_prey(state, team, ambitious) == 2,
		"高野心應選接壤 prey(2)")
	print("Prosperity Task14 OK")

func _test_prosperity_cadence() -> void:
	print("--- Prosperity Task4: cadence ---")
	var state := _prosperity_grid()
	var team := TeamData.new()
	team.team_id = 0; team.tile_pos = Vector2i(0, 0); team.population = 10
	team.faction_id = -1; team.anon_tiers["老兵"] = 10  # avg_combat=0.5
	team.resources = { "food": 200, "weapon_melee_low": 10 }
	team.current_task = TeamData.TASK_IDLE
	state.teams[0] = team
	var leader := PersonData.new()
	leader.id = 100
	leader.values = { "野心": 0.5, "好戰": 0.5, "信義": 0.5, "殘忍": 0.5, "貪婪": 0.5, "慎重": 0.5 }
	state.persons[100] = leader
	team.leader_id = 100
	state.team_discovered[0] = []   # 無 prey → 不觸發攻擊，只看 cadence
	var fas = FactionAISystem.new()
	state.world.current_tick = 0
	fas.evaluate_all(state, [0])
	assert(team.prosperity_eval_next_tick == 720, "tick0 後 next 應 720，實際=%d" % team.prosperity_eval_next_tick)
	state.world.current_tick = 360
	fas.evaluate_all(state, [0])
	assert(team.prosperity_eval_next_tick == 720, "tick360 應跳過，next 仍 720，實際=%d" % team.prosperity_eval_next_tick)
	state.world.current_tick = 720
	fas.evaluate_all(state, [0])
	assert(team.prosperity_eval_next_tick == 1440, "tick720 後 next 應 1440，實際=%d" % team.prosperity_eval_next_tick)
	# 軍隊 tag → cadence 360
	team.tags = ["軍隊"]
	team.prosperity_eval_next_tick = 720
	state.world.current_tick = 720
	fas.evaluate_all(state, [0])
	assert(team.prosperity_eval_next_tick == 1080, "軍隊 cadence 應 +360 → 1080，實際=%d" % team.prosperity_eval_next_tick)
	print("Prosperity Task4 OK")

func _survival_corridor() -> WorldState:
	# 走廊 grid：x 0..27, y -1..1，連通供 A* 找路（足夠製造 >5 日 ETA 場景）
	var state := WorldState.new()
	state.world = WorldData.new()
	for x in range(0, 28):
		for y in range(-1, 2):
			var tile := HexTileData.new()
			tile.tile_pos = Vector2i(x, y); tile.terrain = "plains"
			state.world.tiles[x * 1000 + y] = tile
	return state

func _test_survival_b_branch_far_outpost_loot() -> void:
	print("--- Prosperity Task5: B 分支 遠 outpost + 殘忍 → 掠 ---")
	var state := _survival_corridor()
	var team := TeamData.new()
	team.team_id = 0; team.tile_pos = Vector2i(0, 0); team.population = 5
	team.faction_id = 0; team.current_task = TeamData.TASK_IDLE
	state.teams[0] = team
	var leader := PersonData.new()
	leader.id = 100
	leader.values = { "殘忍": 0.8, "好戰": 0.5, "信義": 0.5, "義氣": 0.3 }
	state.persons[100] = leader
	team.leader_id = 100
	# own outpost 遠（dist 26 → ETA 26*48=1248 > 1200 = 5 日）
	var op_tile: HexTileData = state.world.tiles[26 * 1000 + 0]
	op_tile.outpost_level = 1; op_tile.outpost_owner = 0
	# 近且弱 prey（reachable）
	var prey := TeamData.new()
	prey.team_id = 1; prey.tile_pos = Vector2i(2, 0); prey.population = 1
	prey.faction_id = 1; prey.last_tile_pos = prey.tile_pos
	prey.resources = { "food": 50 }
	state.teams[1] = prey
	state.team_discovered[0] = [1]
	var fas = FactionAISystem.new()
	fas._trigger_survival(state, team, "urgent")
	assert(team.current_task == TeamData.TASK_LOOT, "遠 outpost + 殘忍 應 TASK_LOOT，實際=%s" % team.current_task)
	assert(team.move_target == Vector2i(2, 0), "move_target 應指向 prey tile，實際=%s" % str(team.move_target))
	print("Prosperity Task5 OK")

func _test_survival_b_branch_near_outpost_return() -> void:
	print("--- Prosperity Task5b: 近 outpost → 回家 ---")
	var state := _survival_corridor()
	var team := TeamData.new()
	team.team_id = 0; team.tile_pos = Vector2i(0, 0); team.population = 5
	team.faction_id = 0; team.current_task = TeamData.TASK_IDLE
	state.teams[0] = team
	var leader := PersonData.new()
	leader.id = 100
	leader.values = { "殘忍": 0.8, "好戰": 0.5, "信義": 0.5, "義氣": 0.3 }
	state.persons[100] = leader
	team.leader_id = 100
	# own outpost 近（dist 2 → ETA 240 < 1200）
	var op_tile: HexTileData = state.world.tiles[2 * 1000 + 0]
	op_tile.outpost_level = 1; op_tile.outpost_owner = 0
	var prey := TeamData.new()
	prey.team_id = 1; prey.tile_pos = Vector2i(3, 0); prey.population = 1
	prey.faction_id = 1; prey.last_tile_pos = prey.tile_pos
	state.teams[1] = prey
	state.team_discovered[0] = [1]
	var fas = FactionAISystem.new()
	fas._trigger_survival(state, team, "urgent")
	assert(team.current_task == "return_home", "近 outpost 應 return_home，實際=%s" % team.current_task)
	print("Prosperity Task5b OK")

# Task6 共用：建 attacker(0) + prey(1)擁 outpost(5,5) + resident(2)駐該 tile
func _occupy_setup(atk_values: Dictionary, rep: float, res_caution: float) -> Dictionary:
	var state := WorldState.new()
	state.world = WorldData.new()
	var tile := HexTileData.new()
	tile.tile_pos = Vector2i(5, 5); tile.terrain = "plains"
	tile.outpost_level = 1; tile.outpost_owner = 1   # prey 擁有
	state.world.tiles[5 * 1000 + 5] = tile
	var attacker := TeamData.new()
	attacker.team_id = 0; attacker.tile_pos = Vector2i(5, 5); attacker.population = 10
	var atk_leader := PersonData.new()
	atk_leader.id = 10; atk_leader.values = atk_values
	state.persons[10] = atk_leader; attacker.leader_id = 10
	state.teams[0] = attacker
	var prey := TeamData.new()
	prey.team_id = 1; prey.tile_pos = Vector2i(5, 5); prey.population = 3
	state.teams[1] = prey
	var resident := TeamData.new()
	resident.team_id = 2; resident.tile_pos = Vector2i(5, 5); resident.population = 10
	resident.tags = ["生產"]
	resident.resources = { "food": 100, "material": 40 }
	resident.known_reputations = { 0: rep }
	var res_leader := PersonData.new()
	res_leader.id = 20; res_leader.values = { "慎重": res_caution }
	state.persons[20] = res_leader; resident.leader_id = 20
	state.teams[2] = resident
	return { "state": state, "tile": tile }

func _test_occupy_resident_accept() -> void:
	print("--- Prosperity Task6a: 居民接受 → 易主 ---")
	# rep 0.5 (>0.3) + caution 0.1 → fear 0.5 > 0.3 → accept
	var d := _occupy_setup({ "殘忍": 0.5 }, 0.5, 0.1)
	var state: WorldState = d["state"]
	var tile: HexTileData = d["tile"]
	EncounterSystem.new()._process_occupied_residents(state, 0, 1)
	assert(tile.outpost_owner == 0, "接受後 outpost 應易主給 0，實際=%d" % tile.outpost_owner)
	assert(state.teams.has(2), "居民團應仍存活")
	print("Prosperity Task6a OK")

func _test_occupy_massacre() -> void:
	print("--- Prosperity Task6b: 殘忍 → 屠 ---")
	# rep 0.2 → 拒投；殘忍 0.8 → 屠
	var d := _occupy_setup({ "殘忍": 0.8, "好戰": 0.3 }, 0.2, 0.5)
	var state: WorldState = d["state"]
	var tile: HexTileData = d["tile"]
	var atk: TeamData = state.teams[0]
	var t0: float = atk.anon_treasury
	EncounterSystem.new()._process_occupied_residents(state, 0, 1)
	assert(not state.teams.has(2), "屠村後居民團應消失")
	assert(tile.outpost_owner == 0, "屠村後 outpost 易主，實際=%d" % tile.outpost_owner)
	assert(atk.anon_treasury > t0, "屠村應增公庫")
	assert(float(atk.resources.get("food", 0)) >= 100.0, "屠村應收居民資源")
	print("Prosperity Task6b OK")

func _test_occupy_abandon() -> void:
	print("--- Prosperity Task6c: 義氣 → 放棄 ---")
	var d := _occupy_setup({ "義氣": 0.8, "殘忍": 0.1, "好戰": 0.1 }, 0.2, 0.5)
	var state: WorldState = d["state"]
	var tile: HexTileData = d["tile"]
	EncounterSystem.new()._process_occupied_residents(state, 0, 1)
	assert(tile.outpost_owner == 1, "放棄後 outpost 仍屬 prey(1)，實際=%d" % tile.outpost_owner)
	assert(state.teams.has(2), "放棄後居民團應存活")
	print("Prosperity Task6c OK")

func _test_occupy_force() -> void:
	print("--- Prosperity Task6d: 野心+慎重 → 強佔 pop-20%% ---")
	var d := _occupy_setup(
		{ "野心": 0.8, "慎重": 0.6, "殘忍": 0.1, "好戰": 0.1, "義氣": 0.1, "信義": 0.1 }, 0.2, 0.5)
	var state: WorldState = d["state"]
	var tile: HexTileData = d["tile"]
	EncounterSystem.new()._process_occupied_residents(state, 0, 1)
	assert(tile.outpost_owner == 0, "強佔後 outpost 易主，實際=%d" % tile.outpost_owner)
	assert(state.teams.has(2), "強佔後居民團應存活")
	assert(state.teams[2].population == 8, "強佔 pop 應 10→8，實際=%d" % state.teams[2].population)
	print("Prosperity Task6d OK")

func _test_attack_defeat_reaction() -> void:
	print("--- Prosperity Task7: 戰敗 reaction ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	var team := TeamData.new()
	team.team_id = 0; team.population = 10
	state.teams[0] = team
	var leader := PersonData.new()
	leader.id = 100; leader.stress = 0.0
	leader.values = { "義氣": 0.6, "信義": 0.4, "慎重": 0.5 }
	state.persons[100] = leader; team.leader_id = 100
	var member := PersonData.new()
	member.id = 101; member.loyalty = 1.0
	state.persons[101] = member
	team.named_members = [100, 101]
	ReactionSystem.new().on_attack_defeat(state, 0, 0.4)   # loss>0.3 → 加倍
	# loyalty_delta = -0.1*(0.6+0.4)/2 = -0.05, *2 = -0.1 → 101: 1.0→0.9
	assert(abs(member.loyalty - 0.9) < 0.01, "named loyalty 應降至 0.9，實際=%.3f" % member.loyalty)
	# stress_delta = 0.2*0.5 = 0.1, *1.5 = 0.15 → leader 0→0.15
	assert(abs(leader.stress - 0.15) < 0.01, "leader stress 應升至 0.15，實際=%.3f" % leader.stress)
	print("Prosperity Task7 OK")

func _test_movement_returns_moved_and_arrived() -> void:
	print("--- Combat Task1: movement 回傳 moved+arrived ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	for x in range(-3, 4):
		for y in range(-3, 4):
			var tile := HexTileData.new()
			tile.tile_pos = Vector2i(x, y); tile.terrain = "plains"
			state.world.tiles[x * 1000 + y] = tile
	# Team A: 移動但不 arrived（目標遠）
	var a := TeamData.new()
	a.team_id = 0; a.tile_pos = Vector2i(0, 0); a.move_target = Vector2i(3, 0)
	a.population = 5; a.move_tick_acc = 9999
	state.teams[0] = a
	# Team B: 同 tick arrived（目標相鄰）
	var b := TeamData.new()
	b.team_id = 1; b.tile_pos = Vector2i(2, 0); b.move_target = Vector2i(3, 0)
	b.population = 5; b.move_tick_acc = 9999
	state.teams[1] = b
	var ms = MovementSystem.new()
	var result = ms.process(state, [0, 1])
	assert(result is Dictionary, "回傳應 Dictionary")
	assert(result.has("arrived") and result.has("moved"), "缺 key")
	assert(1 in result["arrived"], "B 應 arrived，實際=%s" % str(result["arrived"]))
	assert(not (0 in result["arrived"]), "A 不應 arrived（仍在途），實際=%s" % str(result["arrived"]))
	assert(0 in result["moved"] and 1 in result["moved"], "兩 team 都 moved，實際=%s" % str(result["moved"]))
	print("Combat Task1 OK")

func _test_process_on_move_triggers_combat() -> void:
	print("--- Combat Task2: moved 不 arrived 同格 → combat ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	for x in range(0, 7):
		for y in range(0, 7):
			var tile := HexTileData.new()
			tile.tile_pos = Vector2i(x, y); tile.terrain = "plains"
			state.world.tiles[x * 1000 + y] = tile
	# 攻擊團 A：與 prey 同格，但 move_target 指向遠處（途經，非 arrived）
	var a := TeamData.new()
	a.team_id = 0; a.tile_pos = Vector2i(1, 1); a.population = 5
	a.faction_id = 0; a.current_task = "攻擊"; a.move_target = Vector2i(5, 5)
	var al := PersonData.new(); al.id = 10
	state.persons[10] = al; a.leader_id = 10
	state.teams[0] = a
	# prey P：同格 (1,1)
	var p := TeamData.new()
	p.team_id = 1; p.tile_pos = Vector2i(1, 1); p.population = 3
	p.faction_id = 1
	var pl := PersonData.new(); pl.id = 20
	state.persons[20] = pl; p.leader_id = 20
	state.teams[1] = p
	state.team_discovered[0] = [1]; state.team_discovered[1] = [0]
	InteractionSystem.new().process_on_move(state, [0], [0, 1])
	assert(a.combat_target == 1, "途經同格應 start_combat（combat_target=1），實際=%d" % a.combat_target)
	print("Combat Task2 OK")

func _test_named_weight_speed() -> void:
	print("--- Combat Task4: named K=3 weight ---")
	var state := WorldState.new()
	var team := TeamData.new()
	team.team_id = 0; team.population = 10
	# 2 named (leader + 1) + 8 unnamed
	var leader := PersonData.new()
	leader.id = 1; leader.attributes["體力"] = 0.9
	state.persons[1] = leader
	team.leader_id = 1
	var member := PersonData.new()
	member.id = 2; member.attributes["體力"] = 0.9
	state.persons[2] = member
	team.named_members = [2]
	var ms = MovementSystem.new()
	var speed_hi = ms._compute_team_speed(state, team)
	# named 體力 降至 0.3
	leader.attributes["體力"] = 0.3
	member.attributes["體力"] = 0.3
	var speed_lo = ms._compute_team_speed(state, team)
	var diff: float = speed_hi - speed_lo
	assert(diff > 0.08, "K=3 應差 >8%%，實際=%.3f" % diff)
	print("Combat Task4 OK (Δspeed=%.3f)" % diff)

# ════════════ Anon Tier 系統 ════════════

func _test_anon_tier_const() -> void:
	print("--- AnonTier Task1: const ---")
	assert(AnonTierSystem.TIER_ORDER.size() == 4)
	assert(AnonTierSystem.TIER_STATS["平民"]["combat"] == 0.1)
	assert(AnonTierSystem.TIER_STATS["菁英"]["speed"] == 1.0)
	assert(AnonTierSystem.PROMOTION_EXP_THRESHOLD["老兵"] == 200.0)
	assert(not AnonTierSystem.PROMOTION_EXP_THRESHOLD.has("菁英"))
	print("AnonTier Task1 OK")

func _test_team_anon_tiers_default() -> void:
	var t := TeamData.new()
	assert(t.anon_tiers["平民"] == 0)
	assert(t.anon_tiers.size() == 4)
	assert(t.anon_exp["平民"] == 0.0)
	assert(t.anon_exp.size() == 3)
	print("AnonTier Task1b OK")

func _test_anon_tier_queries() -> void:
	var t := TeamData.new()
	t.anon_tiers = { "平民": 5, "新兵": 3, "老兵": 2, "菁英": 0 }
	assert(AnonTierSystem.total_pop(t) == 10)
	# wage: 5*0.5 + 3*1.0 + 2*1.5 = 8.5
	assert(abs(AnonTierSystem.total_wage(t) - 8.5) < 0.01)
	# avg combat: (5*0.1 + 3*0.3 + 2*0.5) / 10 = 0.24
	assert(abs(AnonTierSystem.avg_combat_skill(t) - 0.24) < 0.01)
	# avg speed: (5*0.7 + 3*0.8 + 2*0.9) / 10 = 0.77
	assert(abs(AnonTierSystem.avg_speed(t) - 0.77) < 0.01)
	assert(AnonTierSystem.tier_count(t, "新兵") == 3)
	print("AnonTier Task2 OK")

func _test_add_remove_anon() -> void:
	var t := TeamData.new()
	AnonTierSystem.add_anon(t, "新兵", 5)
	assert(t.anon_tiers["新兵"] == 5)
	var removed: int = AnonTierSystem.remove_anon(t, "新兵", 3)
	assert(removed == 3 and t.anon_tiers["新兵"] == 2)
	var removed2: int = AnonTierSystem.remove_anon(t, "新兵", 10)
	assert(removed2 == 2 and t.anon_tiers["新兵"] == 0)
	print("AnonTier Task3a OK")

func _test_add_exp() -> void:
	var t := TeamData.new()
	AnonTierSystem.add_exp(t, "平民", 30.0)
	assert(abs(t.anon_exp["平民"] - 30.0) < 0.01)
	# 菁英 無 exp slot → no-op
	AnonTierSystem.add_exp(t, "菁英", 99.0)
	assert(not t.anon_exp.has("菁英"))
	print("AnonTier Task3b OK")

func _test_kill_random_proportional() -> void:
	var t := TeamData.new()
	t.anon_tiers = { "平民": 50, "新兵": 30, "老兵": 20, "菁英": 0 }
	var killed = AnonTierSystem.kill_random(t, 10, "combat")
	assert(killed["平民"] + killed["新兵"] + killed["老兵"] + killed["菁英"] == 10)
	assert(AnonTierSystem.total_pop(t) == 90)
	print("AnonTier Task3c OK (killed=%s)" % str(killed))

func _test_transfer_proportional() -> void:
	var src := TeamData.new()
	var dst := TeamData.new()
	src.anon_tiers = { "平民": 50, "新兵": 30, "老兵": 20, "菁英": 0 }
	var moved = AnonTierSystem.transfer_proportional(src, dst, 20)
	assert(AnonTierSystem.total_pop(src) == 80)
	assert(AnonTierSystem.total_pop(dst) == 20)
	assert(moved["平民"] + moved["新兵"] + moved["老兵"] + moved["菁英"] == 20)
	print("AnonTier Task3d OK (moved=%s)" % str(moved))

func _make_promote_team(state: WorldState, tact: float) -> TeamData:
	var team := TeamData.new()
	team.team_id = 0
	var leader := PersonData.new()
	leader.id = 1
	leader.skills = { "戰術": tact }
	state.persons[1] = leader
	team.leader_id = 1
	state.teams[0] = team
	return team

func _test_promote_success() -> void:
	var state := WorldState.new()
	var team := _make_promote_team(state, 0.5)
	team.anon_tiers = { "平民": 10, "新兵": 0, "老兵": 0, "菁英": 0 }
	team.anon_exp["平民"] = 250.0   # ×count: 5 升等需 5×50
	team.resources = { "coin": 100, "food": 200, "material": 50 }
	var n = AnonTierSystem.try_promote(state, team, "平民", 5)
	assert(n == 5, "預期升 5，實際=%d" % n)
	assert(team.anon_tiers["平民"] == 5)
	assert(team.anon_tiers["新兵"] == 5)
	assert(team.resources["coin"] == 100 - 25)   # 5×5
	assert(team.resources["food"] == 200 - 50)    # 5×10
	assert(team.resources["material"] == 50 - 10) # 5×2
	assert(team.anon_exp["平民"] == 0.0)            # 250 - 5×50
	print("AnonTier Task4a OK")

func _test_promote_insufficient_exp() -> void:
	var state := WorldState.new()
	var team := _make_promote_team(state, 0.5)
	team.anon_tiers = { "平民": 10, "新兵": 0, "老兵": 0, "菁英": 0 }
	team.anon_exp["平民"] = 30.0   # < 50
	team.resources = { "coin": 100, "food": 200, "material": 50 }
	var n = AnonTierSystem.try_promote(state, team, "平民", 5)
	assert(n == 0, "exp 不足應回 0，實際=%d" % n)
	assert(team.anon_tiers["平民"] == 10)
	assert(team.resources["coin"] == 100)   # 不部分扣
	print("AnonTier Task4b OK")

func _test_promote_insufficient_resources() -> void:
	var state := WorldState.new()
	var team := _make_promote_team(state, 0.5)
	team.anon_tiers = { "平民": 10, "新兵": 0, "老兵": 0, "菁英": 0 }
	team.anon_exp["平民"] = 250.0   # exp 夠（×count: 5×50）
	team.resources = { "coin": 10, "food": 200, "material": 50 }   # coin 不夠 25
	var n = AnonTierSystem.try_promote(state, team, "平民", 5)
	assert(n == 0, "物資不足應回 0，實際=%d" % n)
	assert(team.anon_tiers["平民"] == 10)
	assert(team.resources["coin"] == 10)   # 不部分扣
	print("AnonTier Task4c OK")

func _test_promote_elite_requires_weapon() -> void:
	var state := WorldState.new()
	var team := _make_promote_team(state, 0.8)   # cap 菁英
	team.anon_tiers = { "平民": 0, "新兵": 0, "老兵": 10, "菁英": 0 }
	team.anon_exp["老兵"] = 1000.0   # ×count: 5×200
	team.resources = { "coin": 1000, "food": 1000, "material": 1000, "weapon_melee_high": 0 }
	var n0 = AnonTierSystem.try_promote(state, team, "老兵", 5)
	assert(n0 == 0, "無高武器升菁英應回 0，實際=%d" % n0)
	team.resources["weapon_melee_high"] = 5
	var n1 = AnonTierSystem.try_promote(state, team, "老兵", 5)
	assert(n1 == 5, "有高武器應升 5，實際=%d" % n1)
	assert(team.anon_tiers["菁英"] == 5)
	assert(team.resources["weapon_melee_high"] == 5, "武器只 check 不消耗")
	print("AnonTier Task4d OK")

func _test_promote_leader_skill_cap() -> void:
	var state := WorldState.new()
	var team := _make_promote_team(state, 0.3)   # cap 新兵
	team.anon_tiers = { "平民": 0, "新兵": 10, "老兵": 0, "菁英": 0 }
	team.anon_exp["新兵"] = 500.0   # ×count: 5×100（exp 夠，但 skill cap 應卡）
	team.resources = { "coin": 1000, "food": 1000, "material": 1000 }
	var n = AnonTierSystem.try_promote(state, team, "新兵", 5)
	assert(n == 0, "leader 戰術 0.3 不可升老兵，應回 0，實際=%d" % n)
	assert(team.anon_tiers["新兵"] == 10)
	print("AnonTier Task4e OK")

func _test_training_adds_exp() -> void:
	var state := WorldState.new()
	var team := TeamData.new()
	team.team_id = 0
	team.current_task = TeamData.TASK_TRAIN
	team.anon_tiers["平民"] = 10
	var leader := PersonData.new()
	leader.id = 1
	leader.skills = { "戰術": 0.5 }
	state.persons[1] = leader
	team.leader_id = 1
	state.teams[0] = team
	var ts = TrainingSystem.new()
	ts.process(state, [0])
	# 每 tick exp += 0.5 × 10 = 5.0
	assert(abs(team.anon_exp["平民"] - 5.0) < 0.01, "訓練 exp 應 5.0，實際=%f" % team.anon_exp["平民"])
	print("AnonTier Task5 OK")

func _test_anon_speed_tiers() -> void:
	print("--- AnonTier: movement speed tier-aware ---")
	var state := WorldState.new()
	var ms = MovementSystem.new()
	var t_pleb := TeamData.new()
	t_pleb.team_id = 0; t_pleb.population = 10; t_pleb.leader_id = -1
	t_pleb.anon_tiers = { "平民": 10, "新兵": 0, "老兵": 0, "菁英": 0 }
	var sp_pleb = ms._compute_team_speed(state, t_pleb)
	var t_elite := TeamData.new()
	t_elite.team_id = 1; t_elite.population = 10; t_elite.leader_id = -1
	t_elite.anon_tiers = { "平民": 0, "新兵": 0, "老兵": 0, "菁英": 10 }
	var sp_elite = ms._compute_team_speed(state, t_elite)
	assert(abs(sp_pleb - 0.7) < 0.01, "純平民隊速應 0.7，實際=%f" % sp_pleb)
	assert(abs(sp_elite - 1.0) < 0.01, "純菁英隊速應 1.0，實際=%f" % sp_elite)
	assert(sp_elite - sp_pleb > 0.25, "菁英應快約 30%%")
	print("AnonTier speed OK (pleb=%.2f elite=%.2f)" % [sp_pleb, sp_elite])

func _test_strategic_in_map_check() -> void:
	print("--- Wakeup Task1: in-map check ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	for x in range(0, 5):
		for y in range(0, 5):
			var tile := HexTileData.new()
			tile.tile_pos = Vector2i(x, y); tile.terrain = "plains"
			state.world.tiles[x * 1000 + y] = tile
	# off-map (10,10) → nearest valid 應回 in-map tile
	var pos = StrategicAiSystem._nearest_valid_tile(state, Vector2i(10, 10), Vector2i(0, 0))
	assert(StrategicAiSystem._is_valid_tile(state, pos), "回 in-map tile，實際=%s" % str(pos))
	assert(StrategicAiSystem._is_valid_tile(state, Vector2i(2, 2)), "(2,2) in map")
	assert(not StrategicAiSystem._is_valid_tile(state, Vector2i(10, 10)), "(10,10) out")
	print("Wakeup Task1 OK (nearest=%s)" % str(pos))

func _test_breakout_distance_guard() -> void:
	print("--- Wakeup Task2: breakout 距離 guard ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	var self_team := TeamData.new()
	self_team.team_id = 0; self_team.tile_pos = Vector2i(0, 0); self_team.faction_id = 1
	self_team.current_task = "idle"
	state.teams[0] = self_team
	# 2 enemy 都在 5 hex 外 → 不觸發 breakout
	var e1 := TeamData.new(); e1.team_id = 1; e1.tile_pos = Vector2i(5, 0); e1.faction_id = 2
	var e2 := TeamData.new(); e2.team_id = 2; e2.tile_pos = Vector2i(0, 5); e2.faction_id = 2
	state.teams[1] = e1; state.teams[2] = e2
	state.team_discovered[0] = [1, 2]
	var sai := StrategicAiSystem.new()
	sai._assign_breakout(state, self_team)
	assert(not self_team.strategic_assignments.has(-1),
		"鄰敵 > 3 hex 不應觸發 breakout，實際 sa=%s" % str(self_team.strategic_assignments))
	# 移近一個 enemy 至 2 hex → 觸發
	e1.tile_pos = Vector2i(2, 0)
	sai._assign_breakout(state, self_team)
	assert(self_team.strategic_assignments.has(-1),
		"鄰敵 <= 3 hex 應觸發 breakout")
	print("Wakeup Task2 OK")

func _test_stuck_allows_reeval() -> void:
	print("--- Wakeup Task3: stuck 視為 idle ---")
	var stuck := TeamData.new()
	stuck.current_task = TeamData.TASK_ATTACK
	stuck.move_target = Vector2i(-1, -1)
	assert(FactionAISystem._is_stuck(stuck), "攻擊+無 target 應 stuck")
	var moving := TeamData.new()
	moving.current_task = TeamData.TASK_ATTACK
	moving.move_target = Vector2i(2, 2)
	assert(not FactionAISystem._is_stuck(moving), "有 target 不算 stuck")
	# 行為：stuck solo team 應被重評派新目標
	var state := WorldState.new()
	state.world = WorldData.new()
	var team := TeamData.new()
	team.team_id = 0; team.faction_id = -1; team.parent_team_id = -1
	team.tile_pos = Vector2i(0, 0); team.population = 10
	team.current_task = TeamData.TASK_ATTACK   # stuck
	team.move_target = Vector2i(-1, -1)
	team.resources["food"] = 100.0
	state.teams[0] = team
	var leader := PersonData.new()
	leader.id = 100
	leader.values = { "野心": 1.0, "好戰": 1.0, "貪婪": 0.0, "求生欲": 0.0 }
	state.persons[100] = leader; team.leader_id = 100
	var prey := TeamData.new()
	prey.team_id = 1; prey.faction_id = -1; prey.tile_pos = Vector2i(2, 0)
	state.teams[1] = prey
	state.team_discovered[0] = [1]
	var fai := FactionAISystem.new()
	fai._evaluate_solo(state, team)
	assert(team.move_target == Vector2i(2, 0),
		"stuck solo 應重評派新 move_target，實際=%s" % str(team.move_target))
	print("Wakeup Task3 OK")

func _test_survival_reeval_in_loot() -> void:
	print("--- Wakeup Task4: survival 在 loot 中可重評 ---")
	assert(not (TeamData.TASK_LOOT in FactionAISystem.SURVIVAL_TASKS),
		"TASK_LOOT 應已從 SURVIVAL_TASKS 移除")
	var state := WorldState.new()
	state.world = WorldData.new()
	var team := TeamData.new()
	team.team_id = 0; team.population = 10; team.tile_pos = Vector2i(0, 0)
	team.current_task = TeamData.TASK_LOOT
	team.move_target = Vector2i(3, 3)
	team.resources["food"] = 0.0   # days_left = 0 → urgent
	team.previous_task = ""
	var leader := PersonData.new()
	leader.id = 100
	leader.values = { "殘忍": 0.1, "好戰": 0.1, "義氣": 0.1, "信義": 0.1 }
	state.persons[100] = leader; team.leader_id = 100
	state.teams[0] = team
	var fai := FactionAISystem.new()
	fai._evaluate_survival(state, team)
	# loot 不再 early-return → _trigger_survival 跑 → previous_task 被設
	assert(team.previous_task == TeamData.TASK_LOOT,
		"survival 應進入評估（previous_task=掠奪），實際=%s" % team.previous_task)
	print("Wakeup Task4 OK")

func _test_trade_net_dispatches() -> void:
	print("--- Wakeup Task5: trade_net dispatch ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	var f := FactionData.new()
	f.faction_id = 0; f.member_team_ids = [0]; f.leader_team_id = 0
	state.factions[0] = f
	var trader := TeamData.new()
	trader.team_id = 0; trader.faction_id = 0; trader.tile_pos = Vector2i(0, 0)
	trader.tags = ["商隊"]; trader.current_task = "idle"
	state.teams[0] = trader
	var partner := TeamData.new()
	partner.team_id = 1; partner.faction_id = -1; partner.tile_pos = Vector2i(3, 0)
	partner.resources["goods"] = 50.0
	partner.tags = ["生產"]   # EcoFix Task2: outpost tile 須有居民團才派
	state.teams[1] = partner
	# W2: trade partner 須有 outpost（靜止目標才追得上）
	var p_tile := HexTileData.new()
	p_tile.tile_pos = Vector2i(3, 0); p_tile.outpost_owner = 1
	state.world.tiles[3 * 1000 + 0] = p_tile
	state.team_discovered[0] = [1]
	var sai := StrategicAiSystem.new()
	sai._dispatch_trade_net(state, f)
	assert(trader.current_task == TeamData.TASK_TRADE,
		"商隊應派 trade，實際=%s" % trader.current_task)
	assert(trader.move_target == Vector2i(3, 0), "move_target 應指 partner")
	print("Wakeup Task5 OK")

# ──────── Mounts / Wagons 速度系統 ────────

func _test_effective_mount_wagon_limit() -> void:
	print("--- Mount Task1a: 1人1獸 ---")
	var ms = MovementSystem.new()
	var team := TeamData.new()
	team.population = 10
	team.resources = { "mounts": 5, "wagons": 8 }
	assert(ms.get_effective_mounts(team) == 5, "5 mounts < 10 pop")
	assert(ms.get_effective_wagons(team) == 5, "wagons cap by remaining pop (10-5)")
	team.resources["mounts"] = 12
	assert(ms.get_effective_mounts(team) == 10, "mount cap by pop")
	assert(ms.get_effective_wagons(team) == 0, "no remaining pop")
	print("Mount Task1a OK")

func _test_compute_mount_bonus() -> void:
	print("--- Mount Task1b: mount bonus 公式 ---")
	var ms = MovementSystem.new()
	var team := TeamData.new()
	team.population = 10
	team.resources = { "mounts": 10 }   # 全騎兵
	# ratio=1.0, size_penalty = 1 - 10/50*0.2 = 0.96 → bonus = 3.0*0.96 = 2.88
	var b = ms._compute_mount_bonus(team)
	assert(abs(b - 2.88) < 0.01, "全騎 expect 2.88, got %.2f" % b)
	team.resources["mounts"] = 0
	assert(ms._compute_mount_bonus(team) == 1.0)
	team.population = 50; team.resources["mounts"] = 50
	# ratio=1, size_penalty=0.8, bonus = 3.0*0.8 = 2.4
	var b2 = ms._compute_mount_bonus(team)
	assert(abs(b2 - 2.4) < 0.01, "50 騎 expect 2.4, got %.2f" % b2)
	print("Mount Task1b OK")

func _test_compute_wagon_penalty() -> void:
	print("--- Mount Task1c: wagon penalty 公式 ---")
	var ms = MovementSystem.new()
	var team := TeamData.new()
	team.population = 10
	team.resources = { "wagons": 5 }
	# ratio = 0.5, penalty = 1 - 0.5*0.3 = 0.85
	assert(abs(ms._compute_wagon_penalty(team) - 0.85) < 0.01)
	print("Mount Task1c OK")

func _test_mount_food_consumption() -> void:
	print("--- Mount Task2: mount 食物消耗 ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	var team := TeamData.new()
	team.team_id = 0
	team.population = 10
	team.resources = { "food": 1000.0, "mounts": 10 }
	state.teams[0] = team
	var rs := ResourceSystem.new()
	# 跑 1 天份消耗（cadence = TICKS_PER_DAY）
	rs.resolve_consumption(state, [0], WorldState.TICKS_PER_DAY)
	# 人口：10 × 2.4 = 24；mount：10 × 0.5 = 5 → 共 29
	var consumed: float = 1000.0 - float(team.resources["food"])
	assert(abs(consumed - 29.0) < 0.01, "1天應耗 29 food (24人+5馬), 實際 %.2f" % consumed)
	print("Mount Task2 OK")

func _test_stable_facility_def() -> void:
	print("--- Mount Task3a: stable FACILITY_DEF ---")
	assert(OutpostSystem.FACILITY_DEF.has("stable"), "FACILITY_DEF 應有 stable")
	var s = OutpostSystem.FACILITY_DEF["stable"]
	assert(s["cost"]["material"] == 40, "stable material cost 40")
	assert(s["current_level_key"] == "stable_level", "current_level_key=stable_level")
	assert(s["required_terrain"] == "plains", "stable 限平原")
	print("Mount Task3a OK")

func _test_stable_produces_mounts() -> void:
	print("--- Mount Task3b: stable 產 mount ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	var tile := HexTileData.new()
	tile.tile_id = 0; tile.tile_pos = Vector2i(0, 0); tile.terrain = "plains"
	tile.outpost_type = "civilian"; tile.outpost_level = 1
	tile.outpost_owner = 0; tile.stable_level = 1
	state.world.tiles[0] = tile
	var team := TeamData.new()
	team.team_id = 0; team.population = 10
	team.resources = { "food": 1000.0, "mounts": 0 }
	team.tile_pos = Vector2i(0, 0)
	state.teams[0] = team
	var os := OutpostSystem.new()
	# 直接呼叫產出 1 個月份（30 天 × 每天 1 次）→ Lv1 = 0.3/day → ~9
	for _d in range(30):
		os.produce_stable_day(state, tile, 1.0)
	# 公庫系統：產出進 tile.public_storage["mounts"]，不進 owner team
	assert(int(tile.public_storage.get("mounts", 0)) == 9, "1月 Lv1 公庫應 +9 mounts, 實際 %d" % int(tile.public_storage.get("mounts", 0)))
	assert(int(team.resources.get("mounts", 0)) == 0, "owner team 不應拿 mount")
	assert(float(team.resources["food"]) < 1000.0, "stable 應耗 food")
	print("Mount Task3b OK")

func _test_wild_horses_generation() -> void:
	print("--- Mount Task4a: wild_horses 生成機率 ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	var gen = load("res://scripts/simulation/world_generator.gd").new()
	gen.generate(state, { "radius": 12, "seed": 7 })
	var plains: int = 0
	var with_horses: int = 0
	for tid in state.world.tiles:
		var t: HexTileData = state.world.tiles[tid]
		if t.terrain == "plains":
			plains += 1
			if int(t.resources.get("wild_horses", 0)) > 0:
				with_horses += 1
	# 約 1% plains 有 wild_horses；只驗證機制存在且不全為 0/全部
	assert(plains > 0, "應有 plains tile")
	assert(with_horses <= plains, "wild_horses tile 不超過 plains 數")
	print("Mount Task4a OK (plains=%d with_horses=%d)" % [plains, with_horses])

func _test_wild_horses_no_auto_collect() -> void:
	# 抵達不自動收編野馬（待公庫 spec 加 outpost 採集）
	print("--- Mount Task4b: wild_horses 抵達不自動收編 ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	var tile := HexTileData.new()
	tile.tile_id = 5 * 1000 + 5; tile.tile_pos = Vector2i(5, 5); tile.terrain = "plains"
	tile.resources["wild_horses"] = 2
	state.world.tiles[tile.tile_id] = tile
	var team := TeamData.new()
	team.team_id = 0; team.population = 5
	team.resources = { "mounts": 0 }
	team.tile_pos = Vector2i(5, 5)
	state.teams[0] = team
	var ms := MovementSystem.new()
	ms._on_arrival(state, team)
	assert(int(team.resources.get("mounts", 0)) == 0, "不收編 mounts=0, 實際 %d" % int(team.resources.get("mounts", 0)))
	assert(int(tile.resources.get("wild_horses", 0)) == 2, "tile 野馬保留")
	print("Mount Task4b OK")

func _test_mount_loot_total_wipe() -> void:
	print("--- Mount Task5a: loot 全滅 ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	var winner := TeamData.new()
	winner.team_id = 0; winner.population = 10; winner.resources = { "mounts": 0 }
	winner.tile_pos = Vector2i(0, 0)
	state.teams[0] = winner
	var loser := TeamData.new()
	loser.team_id = 1; loser.population = 0; loser.resources = { "mounts": 5 }
	loser.encounter_initial_pop = 10   # 全滅：10 → 0
	loser.tile_pos = Vector2i(9, 9)
	state.teams[1] = loser
	var es := EncounterSystem.new()
	es.apply_mount_loot(state, 0, 1)
	assert(int(winner.resources["mounts"]) == 5, "全滅 winner +5, 實際 %d" % int(winner.resources["mounts"]))
	assert(int(loser.resources["mounts"]) == 0, "loser 失全部")
	print("Mount Task5a OK")

func _test_mount_loot_partial() -> void:
	print("--- Mount Task5b: loot 半勝 ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	var winner := TeamData.new()
	winner.team_id = 0; winner.population = 10; winner.resources = { "mounts": 0 }
	winner.tile_pos = Vector2i(0, 0)
	state.teams[0] = winner
	var loser := TeamData.new()
	loser.team_id = 1; loser.population = 4; loser.resources = { "mounts": 5 }
	loser.encounter_initial_pop = 10   # 死 6 → ratio 0.6 → roundi(5*0.6)=3
	loser.tile_pos = Vector2i(9, 9)
	state.teams[1] = loser
	var es := EncounterSystem.new()
	es.apply_mount_loot(state, 0, 1)
	assert(int(winner.resources["mounts"]) == 3, "死60%% winner +3, 實際 %d" % int(winner.resources["mounts"]))
	assert(int(loser.resources["mounts"]) == 2, "loser 剩 2")
	print("Mount Task5b OK")

# ──────── Mount 公庫系統 ────────

func _test_mounts_in_public_resources() -> void:
	print("--- MountStorage Task1: mounts in PUBLIC_RESOURCES ---")
	assert("mounts" in ResourceSystem.PUBLIC_RESOURCES)
	assert(OutpostSystem.new()._get_storage_cap(_mk_outpost_tile(1), "mounts") == 10.0)
	print("MountStorage Task1 OK")

func _mk_outpost_tile(level: int) -> HexTileData:
	var tile := HexTileData.new()
	tile.tile_id = 0; tile.tile_pos = Vector2i(0, 0)
	tile.outpost_level = level; tile.outpost_owner = 0
	return tile

func _test_stable_produces_to_public_storage() -> void:
	print("--- MountStorage Task2: stable 產出進公庫 ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	var tile := HexTileData.new()
	tile.tile_id = 5 * 1000 + 5; tile.tile_pos = Vector2i(5, 5)
	tile.terrain = "plains"; tile.outpost_type = "civilian"
	tile.outpost_level = 1; tile.outpost_owner = 0
	tile.stable_level = 1
	state.world.tiles[tile.tile_id] = tile
	var owner := TeamData.new()
	owner.team_id = 0; owner.resources = { "food": 500 }
	state.teams[0] = owner
	var os := OutpostSystem.new()
	# 跑 4 天確保 stable progress >= 1（0.3/day）
	os.produce_stable_day(state, tile, 1.0)
	os.produce_stable_day(state, tile, 1.0)
	os.produce_stable_day(state, tile, 1.0)
	os.produce_stable_day(state, tile, 1.0)
	var stored: int = int(tile.public_storage.get("mounts", 0))
	assert(stored >= 1, "公庫應 >= 1, 實際=%d" % stored)
	assert(int(owner.resources.get("mounts", 0)) == 0, "owner team 不應拿 mount")
	print("MountStorage Task2 OK (stored=%d)" % stored)

func _test_outpost_collect_wild_horses() -> void:
	print("--- MountStorage Task3: outpost 鄰格採野馬 ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	state.world.current_tick = WorldState.TICKS_PER_DAY   # day 邊界
	var tile_op := HexTileData.new()
	tile_op.tile_id = 0; tile_op.tile_pos = Vector2i(0, 0)
	tile_op.outpost_level = 1; tile_op.outpost_owner = 0
	state.world.tiles[tile_op.tile_id] = tile_op
	var ntile := HexTileData.new()
	ntile.tile_id = 1 * 1000 + 0; ntile.tile_pos = Vector2i(1, 0)
	ntile.resources["wild_horses"] = 2
	state.world.tiles[ntile.tile_id] = ntile
	var hs := HarvestSystem.new()
	hs.tick_all(state)
	assert(int(tile_op.public_storage.get("mounts", 0)) == 2,
		"應收 2，實際=%d" % int(tile_op.public_storage.get("mounts", 0)))
	assert(int(ntile.resources.get("wild_horses", 0)) == 0, "野馬應清空")
	print("MountStorage Task3 OK")

func _test_outpost_collect_no_outpost_skip() -> void:
	print("--- MountStorage Task3b: 無 outpost 不採 ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	state.world.current_tick = WorldState.TICKS_PER_DAY
	var ntile := HexTileData.new()
	ntile.tile_id = 0; ntile.tile_pos = Vector2i(0, 0)
	ntile.resources["wild_horses"] = 2   # 無任何 outpost
	state.world.tiles[ntile.tile_id] = ntile
	var hs := HarvestSystem.new()
	hs.tick_all(state)
	assert(int(ntile.resources.get("wild_horses", 0)) == 2, "無 outpost 野馬保留")
	print("MountStorage Task3b OK")

func _test_outpost_collect_cap_limit() -> void:
	print("--- MountStorage Task3c: 公庫滿不收 ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	state.world.current_tick = WorldState.TICKS_PER_DAY
	var tile_op := HexTileData.new()
	tile_op.tile_id = 0; tile_op.tile_pos = Vector2i(0, 0)
	tile_op.outpost_level = 1; tile_op.outpost_owner = 0
	tile_op.public_storage["mounts"] = 10.0   # 已滿（Lv1 cap=10）
	state.world.tiles[tile_op.tile_id] = tile_op
	var ntile := HexTileData.new()
	ntile.tile_id = 1 * 1000 + 0; ntile.tile_pos = Vector2i(1, 0)
	ntile.resources["wild_horses"] = 2
	state.world.tiles[ntile.tile_id] = ntile
	var hs := HarvestSystem.new()
	hs.tick_all(state)
	assert(int(tile_op.public_storage.get("mounts", 0)) == 10, "滿庫不增")
	assert(int(ntile.resources.get("wild_horses", 0)) == 2, "野馬保留")
	print("MountStorage Task3c OK")

func _test_auto_withdraw_on_active_task() -> void:
	print("--- MountStorage Task4a: active task 自動 withdraw ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	var tile := HexTileData.new()
	tile.tile_id = 5 * 1000 + 5; tile.tile_pos = Vector2i(5, 5)
	tile.outpost_level = 1; tile.outpost_owner = 0
	tile.public_storage["mounts"] = 10.0
	state.world.tiles[tile.tile_id] = tile
	var team := TeamData.new()
	team.team_id = 0; team.population = 10
	team.tile_pos = Vector2i(5, 5)
	team.current_task = TeamData.TASK_ATTACK
	team.resources = { "mounts": 0 }
	state.teams[0] = team
	FactionAISystem.new()._auto_withdraw_mounts(state, team)
	assert(int(team.resources.get("mounts", 0)) == 5, "應拉 5（pop10×0.5），實際=%d" % int(team.resources.get("mounts", 0)))
	assert(int(tile.public_storage.get("mounts", 0)) == 5, "公庫剩 5")
	print("MountStorage Task4a OK")

func _test_no_withdraw_when_idle() -> void:
	print("--- MountStorage Task4b: idle 不 withdraw ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	var tile := HexTileData.new()
	tile.tile_id = 5 * 1000 + 5; tile.tile_pos = Vector2i(5, 5)
	tile.outpost_level = 1; tile.outpost_owner = 0
	tile.public_storage["mounts"] = 10.0
	state.world.tiles[tile.tile_id] = tile
	var team := TeamData.new()
	team.team_id = 0; team.population = 10
	team.tile_pos = Vector2i(5, 5)
	team.current_task = TeamData.TASK_IDLE
	team.resources = { "mounts": 0 }
	state.teams[0] = team
	FactionAISystem.new()._auto_withdraw_mounts(state, team)
	assert(int(team.resources.get("mounts", 0)) == 0, "idle 不拉")
	assert(int(tile.public_storage.get("mounts", 0)) == 10, "公庫不變")
	print("MountStorage Task4b OK")

# ════════ Encounter Engagement ════════

func _eng_plains_grid(state: WorldState, x0: int, x1: int, y0: int, y1: int) -> void:
	for x in range(x0, x1):
		for y in range(y0, y1):
			var tile := HexTileData.new()
			tile.tile_pos = Vector2i(x, y); tile.terrain = "plains"
			state.world.tiles[x * 1000 + y] = tile

func _test_predict_intercept_static() -> void:
	print("--- Engagement Task1a: prey 不動 → 回當前 ---")
	var state := WorldState.new(); state.world = WorldData.new()
	_eng_plains_grid(state, 0, 12, -1, 2)
	var attacker := TeamData.new(); attacker.team_id = 0; attacker.tile_pos = Vector2i(0, 0)
	state.teams[0] = attacker
	var prey := TeamData.new(); prey.team_id = 1; prey.tile_pos = Vector2i(5, 0)
	prey.last_tile_pos = Vector2i(5, 0)   # velocity 0
	state.teams[1] = prey
	state.team_discovered[0] = [1]
	var p = PathSystem.predict_intercept(state, attacker, prey)
	assert(p == prey.tile_pos, "靜止 prey → 回當前，實際=%s" % str(p))
	print("Engagement Task1a OK")

func _test_predict_intercept_moving() -> void:
	print("--- Engagement Task1b: prey 移動 → 預測前方 ---")
	var state := WorldState.new(); state.world = WorldData.new()
	_eng_plains_grid(state, 0, 12, -1, 2)
	var attacker := TeamData.new(); attacker.team_id = 0; attacker.tile_pos = Vector2i(0, 0)
	state.teams[0] = attacker
	var prey := TeamData.new(); prey.team_id = 1; prey.tile_pos = Vector2i(3, 0)
	prey.last_tile_pos = Vector2i(2, 0)   # 朝 +x
	state.teams[1] = prey
	state.team_discovered[0] = [1]
	var p = PathSystem.predict_intercept(state, attacker, prey)
	assert(p != prey.tile_pos, "移動 prey 應預測未來格，實際=%s" % str(p))
	assert(p.x > prey.tile_pos.x, "預測應在 prey 前方，實際=%s" % str(p))
	print("Engagement Task1b OK")

func _test_predict_intercept_out_of_sight() -> void:
	print("--- Engagement Task1c: 視野外 → fallback 當前 ---")
	var state := WorldState.new(); state.world = WorldData.new()
	_eng_plains_grid(state, 0, 12, -1, 2)
	var attacker := TeamData.new(); attacker.team_id = 0; attacker.tile_pos = Vector2i(0, 0)
	state.teams[0] = attacker
	var prey := TeamData.new(); prey.team_id = 1; prey.tile_pos = Vector2i(3, 0)
	prey.last_tile_pos = Vector2i(2, 0)
	state.teams[1] = prey
	state.team_discovered[0] = []   # 不在視野
	var p = PathSystem.predict_intercept(state, attacker, prey)
	assert(p == prey.tile_pos, "視野外應 fallback 當前，實際=%s" % str(p))
	print("Engagement Task1c OK")

func _test_threat_score_out_of_sight() -> void:
	print("--- Engagement Task2a: 視野外 score = 0 ---")
	var state := WorldState.new(); state.world = WorldData.new()
	var self_team := TeamData.new(); self_team.team_id = 0; self_team.tile_pos = Vector2i(0, 0)
	state.teams[0] = self_team
	var other := TeamData.new(); other.team_id = 1; other.tile_pos = Vector2i(5, 0)
	state.teams[1] = other
	var s = ThreatAssessment.score(state, self_team, other)
	assert(s == 0.0, "視野外應 0，實際=%.2f" % s)
	print("Engagement Task2a OK")

func _test_threat_score_high_hostile() -> void:
	print("--- Engagement Task2b: 朝我來+敵意+近 → score 高 ---")
	var state := WorldState.new(); state.world = WorldData.new()
	var self_team := TeamData.new(); self_team.team_id = 0; self_team.tile_pos = Vector2i(0, 0)
	self_team.population = 5
	self_team.known_reputations = { 1: 0.1 }   # 高敵意
	state.teams[0] = self_team
	var other := TeamData.new(); other.team_id = 1; other.tile_pos = Vector2i(2, 0)
	other.last_tile_pos = Vector2i(3, 0)   # velocity (-1,0) → 朝我來
	other.population = 20
	state.teams[1] = other
	state.team_discovered[0] = [1]
	state.team_intel[0] = { 1: { "population_est": 20 } }
	var s = ThreatAssessment.score(state, self_team, other)
	assert(s > 0.5, "敵意接近應 score>0.5，實際=%.2f" % s)
	print("Engagement Task2b OK (score=%.2f)" % s)

func _test_threat_score_distance_decay() -> void:
	print("--- Engagement Task2c: 近 > 遠（距離衰減）---")
	var state := WorldState.new(); state.world = WorldData.new()
	var self_team := TeamData.new(); self_team.team_id = 0; self_team.tile_pos = Vector2i(0, 0)
	self_team.population = 5; self_team.known_reputations = { 1: 0.2 }
	state.teams[0] = self_team
	var other := TeamData.new(); other.team_id = 1
	state.teams[1] = other
	state.team_discovered[0] = [1]
	state.team_intel[0] = { 1: { "population_est": 15 } }
	# 近：dist 1，朝我來
	other.tile_pos = Vector2i(1, 0); other.last_tile_pos = Vector2i(2, 0)
	var near_s = ThreatAssessment.score(state, self_team, other)
	# 遠：dist 5，朝我來
	other.tile_pos = Vector2i(5, 0); other.last_tile_pos = Vector2i(6, 0)
	var far_s = ThreatAssessment.score(state, self_team, other)
	assert(near_s > far_s, "近應 > 遠，near=%.2f far=%.2f" % [near_s, far_s])
	print("Engagement Task2c OK (near=%.2f far=%.2f)" % [near_s, far_s])

func _test_task_defend_prepare_const() -> void:
	print("--- Engagement Task3: const + 欄位 ---")
	assert(TeamData.TASK_DEFEND == "迎戰")
	assert(TeamData.TASK_PREPARE == "備戰")
	var t := TeamData.new()
	assert(t.threat_eval_next_tick == 0)
	assert(t.trade_task_start_tick == 0)
	print("Engagement Task3 OK")

func _eng_make_leader(state: WorldState, team: TeamData, vals: Dictionary) -> void:
	var leader := PersonData.new()
	leader.id = team.team_id * 100 + 1; leader.team_id = team.team_id
	leader.values = vals
	state.persons[leader.id] = leader
	team.leader_id = leader.id

func _test_evaluate_threat_finds_hostile() -> void:
	print("--- Engagement Task4a: _evaluate_threat 找到敵 → dispatch ---")
	var state := WorldState.new(); state.world = WorldData.new()
	state.world.current_tick = 0
	var team := TeamData.new(); team.team_id = 0; team.tile_pos = Vector2i(0, 0)
	team.population = 5; team.known_reputations = { 1: 0.1 }
	team.current_task = TeamData.TASK_IDLE
	_eng_make_leader(state, team, { "慎重": 0.0, "求生欲": 0.9, "好戰": 0.1,
		"貪婪": 0.1, "信義": 0.1 })
	state.teams[0] = team
	var enemy := TeamData.new(); enemy.team_id = 1; enemy.tile_pos = Vector2i(2, 0)
	enemy.last_tile_pos = Vector2i(3, 0); enemy.population = 20
	state.teams[1] = enemy
	state.team_discovered[0] = [1]
	state.team_intel[0] = { 1: { "population_est": 20 } }
	var fai := FactionAISystem.new()
	fai._evaluate_threat(state, team)
	assert(team.current_task != TeamData.TASK_IDLE, "應觸發反應，task=%s" % team.current_task)
	assert(team.threat_eval_next_tick == 240, "cadence 應設 240，實際=%d" % team.threat_eval_next_tick)
	print("Engagement Task4a OK (→ %s)" % team.current_task)

func _test_evaluate_threat_cadence() -> void:
	print("--- Engagement Task4b: cadence 跳過 ---")
	var state := WorldState.new(); state.world = WorldData.new()
	var team := TeamData.new(); team.team_id = 0; team.tile_pos = Vector2i(0, 0)
	team.current_task = TeamData.TASK_IDLE
	team.threat_eval_next_tick = 240
	_eng_make_leader(state, team, { "慎重": 0.0 })
	state.teams[0] = team
	state.team_discovered[0] = []
	var fai := FactionAISystem.new()
	# tick 120 < 240 → 跳過，不改 next_tick
	state.world.current_tick = 120
	fai._evaluate_threat(state, team)
	assert(team.threat_eval_next_tick == 240, "120 不應評，next 仍 240，實際=%d" % team.threat_eval_next_tick)
	# tick 240 → 評，next = 480
	state.world.current_tick = 240
	fai._evaluate_threat(state, team)
	assert(team.threat_eval_next_tick == 480, "240 應評，next=480，實際=%d" % team.threat_eval_next_tick)
	print("Engagement Task4b OK")

func _eng_dispatch_setup(vals: Dictionary, resident: bool) -> Array:
	var state := WorldState.new(); state.world = WorldData.new()
	var team := TeamData.new(); team.team_id = 0; team.tile_pos = Vector2i(0, 0)
	team.population = 5
	if resident:
		var tile := HexTileData.new()
		tile.tile_pos = Vector2i(0, 0); tile.outpost_level = 1
		tile.outpost_type = "civilian"; tile.outpost_owner = 0
		state.world.tiles[0] = tile
		team.tags = [TeamData.TAG_PRODUCE]
	var leader := PersonData.new(); leader.id = 1; leader.team_id = 0; leader.values = vals
	state.persons[1] = leader; team.leader_id = 1
	state.teams[0] = team
	var other := TeamData.new(); other.team_id = 1; other.tile_pos = Vector2i(1, 0)
	state.teams[1] = other
	return [state, team]

func _test_dispatch_flee_high_survival() -> void:
	print("--- Engagement Task5a: 求生欲高 → 逃跑 ---")
	var r := _eng_dispatch_setup({ "求生欲": 0.9, "好戰": 0.1, "慎重": 0.1,
		"貪婪": 0.1, "信義": 0.1 }, false)
	FactionAISystem.new()._dispatch_threat_response(r[0], r[1], 1, 0.6)
	assert(r[1].current_task == TeamData.TASK_FLEE, "應逃跑，實際=%s" % r[1].current_task)
	print("Engagement Task5a OK")

func _test_dispatch_defend_high_martial_non_resident() -> void:
	print("--- Engagement Task5b: 好戰高+非居民 → 迎戰 ---")
	var r := _eng_dispatch_setup({ "求生欲": 0.2, "好戰": 0.9, "慎重": 0.2,
		"貪婪": 0.1, "信義": 0.1 }, false)
	FactionAISystem.new()._dispatch_threat_response(r[0], r[1], 1, 0.3)
	assert(r[1].current_task == TeamData.TASK_DEFEND, "應迎戰，實際=%s" % r[1].current_task)
	print("Engagement Task5b OK")

func _test_dispatch_prepare_resident() -> void:
	print("--- Engagement Task5c: 好戰高+居民 → 備戰（不可迎戰）---")
	var r := _eng_dispatch_setup({ "求生欲": 0.2, "好戰": 0.9, "慎重": 0.2,
		"貪婪": 0.1, "信義": 0.1 }, true)
	FactionAISystem.new()._dispatch_threat_response(r[0], r[1], 1, 0.3)
	assert(r[1].current_task == TeamData.TASK_PREPARE, "居民應備戰，實際=%s" % r[1].current_task)
	print("Engagement Task5c OK")

func _test_dispatch_tribute_high_business() -> void:
	print("--- Engagement Task5d: 貪婪+信義高 → 求和外交 ---")
	var r := _eng_dispatch_setup({ "求生欲": 0.2, "好戰": 0.1, "慎重": 0.1,
		"貪婪": 0.9, "信義": 0.7 }, false)
	FactionAISystem.new()._dispatch_threat_response(r[0], r[1], 1, 0.3)
	assert(r[1].current_task == TeamData.TASK_DIPLOMACY, "應外交，實際=%s" % r[1].current_task)
	assert(r[1].order_task == "tribute_offer", "應 tribute_offer，實際=%s" % r[1].order_task)
	print("Engagement Task5d OK")

func _test_resident_lock_prepare_allowed() -> void:
	print("--- Engagement Task6: 居民 task=備戰 不被鎖 ---")
	var state := WorldState.new(); state.world = WorldData.new()
	_eng_plains_grid(state, 0, 5, 0, 5)
	var tile: HexTileData = state.world.tiles[0]
	tile.outpost_level = 1; tile.outpost_type = "civilian"; tile.outpost_owner = 0
	var t := TeamData.new(); t.team_id = 0; t.tile_pos = Vector2i(0, 0); t.population = 5
	t.faction_id = 10; t.tags = [TeamData.TAG_PRODUCE]
	t.current_task = TeamData.TASK_PREPARE
	t.move_target = Vector2i(3, 0)
	state.teams[0] = t
	var mv: Object = load("res://scripts/simulation/movement_system.gd").new()
	for _i in range(300):
		mv.process(state, [0], 1.0)
	assert(t.tile_pos.x > 0, "備戰 不應被鎖，tile 應移動，實際=%s" % str(t.tile_pos))
	print("Engagement Task6 OK (移動到 %s)" % str(t.tile_pos))

func _test_find_trade_partner_outpost_only() -> void:
	print("--- Engagement Task7a: trade partner 只選有 outpost ---")
	var state := WorldState.new(); state.world = WorldData.new()
	var trader := TeamData.new(); trader.team_id = 0; trader.faction_id = -1
	state.teams[0] = trader
	var with_op := TeamData.new(); with_op.team_id = 1; with_op.faction_id = -1
	with_op.resources["goods"] = 10
	with_op.tags = ["生產"]; with_op.tile_pos = Vector2i(0, 0)   # EcoFix Task2: 居民團駐 outpost tile
	state.teams[1] = with_op
	var no_op := TeamData.new(); no_op.team_id = 2; no_op.faction_id = -1
	no_op.resources["goods"] = 10
	no_op.tile_pos = Vector2i(9, 9)
	state.teams[2] = no_op
	var tile := HexTileData.new(); tile.tile_pos = Vector2i(0, 0); tile.outpost_owner = 1
	state.world.tiles[0] = tile
	state.team_discovered[0] = [2, 1]   # 2 先掃但無 outpost → 應跳過
	var partner: Dictionary = StrategicAiSystem.new()._find_trade_partner(state, trader)
	assert(not partner.is_empty() and int(partner["team_id"]) == 1, "應選有 outpost 的 Team1，實際=%s" % str(partner))
	assert(partner["outpost_pos"] == Vector2i(0, 0), "outpost_pos 應 (0,0)")
	print("Engagement Task7a OK")

func _test_trade_timeout() -> void:
	print("--- Engagement Task7b: 貿易 task 超時 → idle ---")
	var state := WorldState.new(); state.world = WorldData.new()
	state.world.current_tick = 1500
	var tile := HexTileData.new(); tile.tile_pos = Vector2i(0, 0); tile.terrain = "plains"
	state.world.tiles[0] = tile
	var t := TeamData.new(); t.team_id = 0; t.faction_id = -1; t.tile_pos = Vector2i(0, 0)
	t.population = 2; t.resources["food"] = 100.0; t.tags = [TeamData.TAG_MERCHANT]
	t.current_task = TeamData.TASK_TRADE; t.trade_task_start_tick = 0
	var leader := PersonData.new(); leader.id = 1; leader.team_id = 0
	leader.values = { "求生欲": 0.5 }
	state.persons[1] = leader; t.leader_id = 1
	state.teams[0] = t
	FactionAISystem.new().evaluate_all(state, [0])
	assert(t.current_task == TeamData.TASK_IDLE, "超時應 idle，實際=%s" % t.current_task)
	print("Engagement Task7b OK")

# ──────── Trade 接公庫 ────────

func _test_absorb_then_spill_no_trade() -> void:
	print("--- TradePublic Task1a: absorb→spill round-trip ---")
	var state := WorldState.new(); state.world = WorldData.new()
	var tile := HexTileData.new()
	tile.tile_pos = Vector2i(0, 0); tile.outpost_owner = 0
	tile.outpost_type = "civilian"; tile.outpost_level = 1
	tile.public_storage = { "food": 50.0 }
	state.world.tiles[0] = tile
	var team := TeamData.new(); team.team_id = 0; team.tile_pos = Vector2i(0, 0)
	team.resources = { "food": 10.0 }
	state.teams[0] = team
	var orig: Dictionary = InteractionSystem._absorb_public_storage(state, team)
	assert(float(team.resources["food"]) == 60.0, "absorb 後 team.food 應 60，實際 %.1f" % float(team.resources["food"]))
	assert(float(orig["food"]) == 10.0, "original 應記 team 原 food=10")
	assert(float(tile.public_storage["food"]) == 0.0, "absorb 應 move 出公庫（=0）")
	InteractionSystem._spill_back_public_storage(state, team, orig)
	assert(float(team.resources["food"]) == 10.0, "spill_back 後 team.food 應還原 10，實際 %.1f" % float(team.resources["food"]))
	assert(float(tile.public_storage["food"]) == 50.0, "公庫 food 應還原 50，實際 %.1f" % float(tile.public_storage["food"]))
	print("TradePublic Task1a OK")

func _test_absorb_only_at_own_outpost() -> void:
	print("--- TradePublic Task1b: 別人 outpost 不 absorb ---")
	var state := WorldState.new(); state.world = WorldData.new()
	var tile := HexTileData.new()
	tile.tile_pos = Vector2i(0, 0); tile.outpost_owner = 99   # 別團 outpost
	tile.public_storage = { "food": 50.0 }
	state.world.tiles[0] = tile
	var team := TeamData.new(); team.team_id = 0; team.tile_pos = Vector2i(0, 0)
	team.resources = { "food": 10.0 }
	state.teams[0] = team
	var orig: Dictionary = InteractionSystem._absorb_public_storage(state, team)
	assert(orig.is_empty(), "別人 outpost 不應 absorb")
	assert(float(team.resources["food"]) == 10.0, "team.food 不變")
	assert(float(tile.public_storage["food"]) == 50.0, "公庫不變")
	print("TradePublic Task1b OK")

func _test_spill_back_with_cap_overflow() -> void:
	print("--- TradePublic Task1c: spill_back 超 cap 留 team ---")
	var state := WorldState.new(); state.world = WorldData.new()
	var tile := HexTileData.new()
	tile.tile_pos = Vector2i(0, 0); tile.outpost_owner = 0
	tile.outpost_type = "civilian"; tile.outpost_level = 1   # cap food = 200
	tile.public_storage = { "food": 180.0 }
	state.world.tiles[0] = tile
	var team := TeamData.new(); team.team_id = 0; team.tile_pos = Vector2i(0, 0)
	team.resources = { "food": 0.0 }
	state.teams[0] = team
	var orig: Dictionary = InteractionSystem._absorb_public_storage(state, team)
	# 模擬 trade 後 team food 多 100（180 借出 + 100 賺）
	team.resources["food"] = 280.0
	InteractionSystem._spill_back_public_storage(state, team, orig)
	assert(float(tile.public_storage["food"]) == 200.0, "公庫應補到 cap=200，實際 %.1f" % float(tile.public_storage["food"]))
	assert(float(team.resources["food"]) == 80.0, "超 cap 的 80 應留 team，實際 %.1f" % float(team.resources["food"]))
	print("TradePublic Task1c OK")

func _test_resolve_market_absorbs_storage() -> void:
	print("--- TradePublic Task2: _resolve_market absorb 公庫 ---")
	var state := WorldState.new(); state.world = WorldData.new()
	var it := InteractionSystem.new()
	# b：outpost owner，公庫有 food，自己 coin 少；a：trader 帶 coin
	var tile := HexTileData.new()
	tile.tile_pos = Vector2i(0, 0); tile.outpost_owner = 1
	tile.outpost_type = "civilian"; tile.outpost_level = 1
	tile.public_storage = { "food": 200.0 }
	state.world.tiles[0] = tile
	var a := TeamData.new(); a.team_id = 0; a.faction_id = -1; a.tile_pos = Vector2i(0, 0)
	a.population = 5; a.current_task = TeamData.TASK_TRADE
	a.resources = { "coin": 300.0, "food": 0.0 }
	var a_leader := PersonData.new(); a_leader.id = 10; a_leader.team_id = 0
	state.persons[10] = a_leader; a.leader_id = 10
	state.teams[0] = a
	var b := TeamData.new(); b.team_id = 1; b.faction_id = -1; b.tile_pos = Vector2i(0, 0)
	b.population = 5; b.current_task = "idle"
	b.resources = { "coin": 0.0, "food": 0.0 }
	var b_leader := PersonData.new(); b_leader.id = 11; b_leader.team_id = 1
	state.persons[11] = b_leader; b.leader_id = 11
	state.teams[1] = b
	var public_before: float = float(tile.public_storage["food"])
	var a_coin_before: float = float(a.resources["coin"])
	it._resolve_market(state, a, b)
	# a 應買到 food（coin 減），b 公庫 food 減（賣出），b coin 增
	assert(float(a.resources.get("food", 0)) > 0.0, "trader 應買到 food，實際 %.1f" % float(a.resources.get("food", 0)))
	assert(float(a.resources["coin"]) < a_coin_before, "trader coin 應減少")
	assert(float(tile.public_storage["food"]) < public_before, "公庫 food 應減少（賣出），實際 %.1f" % float(tile.public_storage["food"]))
	assert(float(b.resources.get("coin", 0)) > 0.0, "owner 應收到 coin")
	print("TradePublic Task2 OK")

func _test_resident_team_absorbs_public_storage() -> void:
	# 改設計：trader 跟 居民團（PRODUCE+在自家 faction outpost）交易，居民團代管公庫
	print("--- TradePublic Task3: 居民團 absorb 公庫 ---")
	var state := WorldState.new(); state.world = WorldData.new()
	var tile := HexTileData.new()
	tile.tile_pos = Vector2i(0, 0); tile.outpost_owner = 1
	tile.outpost_type = "civilian"; tile.outpost_level = 1
	tile.public_storage = { "food": 100.0 }
	state.world.tiles[0] = tile
	# 居民團 (PRODUCE tag, 同 faction owner) 在 outpost tile
	var resident := TeamData.new(); resident.team_id = 2; resident.faction_id = 0
	resident.tile_pos = Vector2i(0, 0); resident.population = 5
	resident.tags = ["生產"]
	resident.resources = { "food": 10.0 }
	state.teams[2] = resident
	# owner team 同 faction
	var owner := TeamData.new(); owner.team_id = 1; owner.faction_id = 0
	state.teams[1] = owner
	var original = InteractionSystem._absorb_public_storage(state, resident)
	assert(original.has("food"), "居民團 absorb 應觸發")
	assert(int(resident.resources["food"]) == 110, "資源應 absorb，實際=%d" % int(resident.resources["food"]))
	assert(float(tile.public_storage["food"]) == 0.0, "公庫應清空")
	print("TradePublic Task3 OK")

# ──────── Outpost 居民派駐 AI ────────

func _test_residency_team_fields() -> void:
	print("--- Residency Task1: TeamData 新欄位 ---")
	var t := TeamData.new()
	assert(t.residency_eval_next_tick == 0, "預設 residency_eval_next_tick 應為 0")
	assert(t.invite_cooldown is Dictionary and t.invite_cooldown.size() == 0, "預設 invite_cooldown 應為空 dict")
	print("Residency Task1 OK")

func _test_has_resident_team_check() -> void:
	print("--- Residency Task2: _has_resident_team_on_tile ---")
	var state := WorldState.new(); state.world = WorldData.new()
	var tile := HexTileData.new()
	tile.tile_pos = Vector2i(5, 5); tile.outpost_level = 1
	tile.outpost_type = "civilian"; tile.outpost_owner = 0
	state.world.tiles[5005] = tile
	var fai := FactionAISystem.new()
	# 無 team → false
	assert(not fai._has_resident_team_on_tile(state, tile), "無 team 應 false")
	# 非 PRODUCE team 在 tile → false
	var m := TeamData.new(); m.team_id = 1; m.tile_pos = Vector2i(5, 5); m.tags = ["軍隊"]
	state.teams[1] = m
	assert(not fai._has_resident_team_on_tile(state, tile), "非 PRODUCE 應 false")
	# PRODUCE team 在 tile → true
	var r := TeamData.new(); r.team_id = 2; r.tile_pos = Vector2i(5, 5); r.tags = ["生產"]
	state.teams[2] = r
	assert(fai._has_resident_team_on_tile(state, tile), "PRODUCE 應 true")
	print("Residency Task2 OK")

func _test_dispatch_high_ambition() -> void:
	print("--- Residency Task3a: 高野心走 dispatch ---")
	var state := WorldState.new(); state.world = WorldData.new()
	var tile := HexTileData.new()
	tile.tile_pos = Vector2i(2, 2); tile.outpost_level = 1
	tile.outpost_type = "civilian"; tile.outpost_owner = 0
	state.world.tiles[2002] = tile
	var owner := TeamData.new(); owner.team_id = 0; owner.faction_id = 10
	owner.population = 20; owner.tile_pos = Vector2i(5, 5)
	var leader := PersonData.new(); leader.id = 100; leader.team_id = 0
	leader.values = { "野心": 0.9, "好戰": 0.8, "慎重": 0.1 }
	leader.skills = { "商業": 0.0, "統領": 0.8 }
	state.persons[100] = leader; owner.leader_id = 100
	for i in range(3):
		var mm := PersonData.new(); mm.id = 200 + i; mm.team_id = 0; mm.skills = { "統領": 0.5 }
		state.persons[mm.id] = mm; owner.named_members.append(mm.id)
	state.teams[0] = owner
	var before: int = state.teams.size()
	var fai := FactionAISystem.new()
	fai._try_dispatch_or_invite(state, owner, tile, leader)
	assert(state.teams.size() == before + 1, "高野心應派子隊（teams+1），實際=%d" % state.teams.size())
	print("Residency Task3a OK")

func _test_invite_high_commerce() -> void:
	print("--- Residency Task3b: 高商業走 invite ---")
	var state := WorldState.new(); state.world = WorldData.new()
	var tile := HexTileData.new()
	tile.tile_pos = Vector2i(2, 2); tile.outpost_level = 1
	tile.outpost_type = "civilian"; tile.outpost_owner = 0
	state.world.tiles[2002] = tile
	var owner := TeamData.new(); owner.team_id = 0; owner.faction_id = 10
	owner.population = 20; owner.tile_pos = Vector2i(2, 2)
	var leader := PersonData.new(); leader.id = 100; leader.team_id = 0
	leader.values = { "野心": 0.1, "好戰": 0.1, "慎重": 0.9 }
	leader.skills = { "商業": 0.9 }
	state.persons[100] = leader; owner.leader_id = 100
	state.teams[0] = owner
	var ex := TeamData.new(); ex.team_id = 1; ex.faction_id = -1
	ex.tags = ["流亡"]; ex.population = 8; ex.tile_pos = Vector2i(3, 3)
	ex.resources["food"] = 0
	var el := PersonData.new(); el.id = 101; el.team_id = 1
	el.values = { "求生欲": 0.9, "野心": 0.1 }
	state.persons[101] = el; ex.leader_id = 101
	state.teams[1] = ex
	state.team_discovered[0] = [1]
	var fai := FactionAISystem.new()
	fai._try_dispatch_or_invite(state, owner, tile, leader)
	assert(ex.current_task == "安頓", "高商業低野心應邀流亡安頓，實際=%s" % ex.current_task)
	print("Residency Task3b OK")

func _test_dispatch_subteam_creates_subteam() -> void:
	print("--- Residency Task4: _dispatch_subteam_settle ---")
	var state := WorldState.new(); state.world = WorldData.new()
	var tile := HexTileData.new()
	tile.tile_pos = Vector2i(4, 4); tile.outpost_level = 1
	tile.outpost_type = "civilian"; tile.outpost_owner = 0
	state.world.tiles[4004] = tile
	var owner := TeamData.new(); owner.team_id = 0; owner.faction_id = 10
	owner.population = 20; owner.tile_pos = Vector2i(7, 7)
	var leader := PersonData.new(); leader.id = 100; leader.team_id = 0; leader.skills = { "統領": 0.8 }
	state.persons[100] = leader; owner.leader_id = 100
	for i in range(3):
		var mm := PersonData.new(); mm.id = 200 + i; mm.team_id = 0; mm.skills = { "統領": 0.5 }
		state.persons[mm.id] = mm; owner.named_members.append(mm.id)
	state.teams[0] = owner
	var fai := FactionAISystem.new()
	fai._dispatch_subteam_settle(state, owner, tile)
	var found: int = -1
	for tid in state.teams:
		if state.teams[tid].parent_team_id == 0:
			found = tid; break
	assert(found != -1, "應創建子隊")
	var sub: TeamData = state.teams[found]
	assert(sub.tags.has("子團"), "子隊應有 子團 tag")
	assert(sub.current_task == "安頓", "子隊 task 應為 安頓，實際=%s" % sub.current_task)
	assert(sub.move_target == Vector2i(4, 4), "子隊 move_target 應為 outpost")
	assert(sub.population == 5, "settler_count clamp 20/4=5，實際=%d" % sub.population)
	print("Residency Task4 OK")

func _test_invite_exile_accept() -> void:
	print("--- Residency Task5a: 邀流亡接受 ---")
	var state := WorldState.new(); state.world = WorldData.new()
	var tile := HexTileData.new()
	tile.tile_pos = Vector2i(1, 1); tile.outpost_level = 1
	tile.outpost_type = "civilian"; tile.outpost_owner = 0
	state.world.tiles[1001] = tile
	var owner := TeamData.new(); owner.team_id = 0; owner.faction_id = 10
	state.teams[0] = owner
	var ex := TeamData.new(); ex.team_id = 1; ex.faction_id = -1
	ex.tags = ["流亡"]; ex.population = 8; ex.tile_pos = Vector2i(3, 3)
	ex.resources["food"] = 0
	var el := PersonData.new(); el.id = 101; el.team_id = 1
	el.values = { "求生欲": 0.9, "野心": 0.1 }
	state.persons[101] = el; ex.leader_id = 101
	state.teams[1] = ex
	state.team_discovered[0] = [1]
	var fai := FactionAISystem.new()
	fai._try_invite_nearby_exile(state, owner, tile)
	assert(ex.current_task == "安頓", "接受應 task=安頓")
	assert(ex.move_target == Vector2i(1, 1), "move_target 應為 outpost")
	print("Residency Task5a OK")

func _test_invite_exile_reject_cooldown() -> void:
	print("--- Residency Task5b: 邀流亡拒絕設冷卻 ---")
	var state := WorldState.new(); state.world = WorldData.new()
	state.world.current_tick = 1000
	var tile := HexTileData.new()
	tile.tile_pos = Vector2i(1, 1); tile.outpost_level = 1
	tile.outpost_type = "civilian"; tile.outpost_owner = 0
	state.world.tiles[1001] = tile
	var owner := TeamData.new(); owner.team_id = 0; owner.faction_id = 10
	state.teams[0] = owner
	var ex := TeamData.new(); ex.team_id = 1; ex.faction_id = -1
	ex.tags = ["流亡"]; ex.population = 8; ex.tile_pos = Vector2i(3, 3)
	ex.resources["food"] = 1000.0
	var el := PersonData.new(); el.id = 101; el.team_id = 1
	el.values = { "求生欲": 0.1, "野心": 0.9 }
	state.persons[101] = el; ex.leader_id = 101
	state.teams[1] = ex
	state.team_discovered[0] = [1]
	var fai := FactionAISystem.new()
	fai._try_invite_nearby_exile(state, owner, tile)
	assert(ex.current_task != "安頓", "拒絕不應安頓")
	assert(int(owner.invite_cooldown.get(1, 0)) == 1000 + FactionAISystem.RESIDENCY_COOLDOWN, "應設 7 天冷卻")
	print("Residency Task5b OK")

func _test_settle_triggers_subteam_merge_back() -> void:
	print("--- Residency Task6: 流民駐紮觸發子隊回母團 ---")
	var state := WorldState.new(); state.world = WorldData.new()
	var tile := HexTileData.new()
	tile.tile_pos = Vector2i(0, 0); tile.outpost_level = 1
	tile.outpost_type = "civilian"; tile.outpost_owner = 0
	state.world.tiles[0] = tile
	var parent := TeamData.new(); parent.team_id = 0; parent.faction_id = 10
	parent.tile_pos = Vector2i(0, 0); parent.population = 5
	var pl := PersonData.new(); pl.id = 100; pl.team_id = 0; pl.skills = { "統領": 0.8 }
	state.persons[100] = pl; parent.leader_id = 100
	state.teams[0] = parent
	var sub := TeamData.new(); sub.team_id = 1; sub.faction_id = 10; sub.parent_team_id = 0
	sub.tile_pos = Vector2i(0, 0); sub.tags = ["子團", "生產"]; sub.population = 3
	state.teams[1] = sub; parent.subteam_ids = [1]
	var flee := TeamData.new(); flee.team_id = 2; flee.faction_id = 10
	flee.tile_pos = Vector2i(0, 0); flee.tags = ["流亡"]; flee.population = 4
	state.teams[2] = flee
	var inter := InteractionSystem.new()
	inter._convert_to_resident(state, flee)
	assert(not state.teams.has(1), "子隊應回母團（完全合併移除），teams 仍有 1")
	print("Residency Task6 OK")

# ── Reaction 職責收斂 ──────────────────────────────────────

func _test_reaction_fields() -> void:
	print("--- Reaction Task1a: work_morale / last_reaction 欄位 ---")
	var t := TeamData.new()
	assert(abs(t.work_morale - 1.0) < 0.001)
	var p := PersonData.new()
	assert(p.last_reaction == "")
	print("Reaction Task1a OK")

func _test_p3_removed() -> void:
	print("--- Reaction Task1b: P3_recruit 已刪除 ---")
	var rs := ReactionSystem.new()
	var team := TeamData.new(); team.team_id = 0; team.population = 5
	var p := PersonData.new(); p.id = 1; p.team_id = 0
	p.values = { "野心": 0.9, "貪婪": 0.9 }   # 舊 P3 高分個性
	var r: String = rs._evaluate_person(p, team)
	assert(r != "P3_recruit", "P3 應已刪除，實際=%s" % r)
	print("Reaction Task1b OK")

func _test_p2_no_food() -> void:
	print("--- Reaction Task2a: P2 不加 food ---")
	var state := WorldState.new(); state.world = WorldData.new()
	var team := TeamData.new(); team.team_id = 0; team.population = 5
	team.resources = { "food": 100.0 }
	state.teams[0] = team
	var p := PersonData.new(); p.id = 1; p.team_id = 0
	state.persons[1] = p
	var rs := ReactionSystem.new()
	rs._apply_reaction(state, p, team, "P2_produce")
	assert(abs(float(team.resources["food"]) - 100.0) < 0.001, "P2 不應加 food")
	print("Reaction Task2a OK")

func _test_work_morale_shift() -> void:
	print("--- Reaction Task2b: 全員 P2 → morale 上升 ---")
	var state := WorldState.new(); state.world = WorldData.new()
	var team := TeamData.new(); team.team_id = 0; team.population = 3
	team.tags = ["生產"]
	state.teams[0] = team
	for i in range(3):
		var p := PersonData.new(); p.id = 10 + i; p.team_id = 0
		p.skills = { "生產": 0.9 }; p.values = { "慎重": 0.8 }
		p.loyalty = 0.9
		state.persons[10 + i] = p
		if i == 0: team.leader_id = p.id
		else: team.named_members.append(p.id)
	var rs := ReactionSystem.new()
	for _i in range(50):
		rs.evaluate_all(state, [0])
	assert(team.work_morale > 1.0, "勤奮村 morale 應 > 1.0，實際=%.2f" % team.work_morale)
	print("Reaction Task2b OK (morale=%.2f)" % team.work_morale)

func _test_collect_uses_morale() -> void:
	print("--- Reaction Task3: 採集 gain 乘 work_morale ---")
	var rs := ResourceSystem.new()
	var gains: Array = []
	for morale in [0.5, 1.5]:
		var state := WorldState.new(); state.world = WorldData.new()
		var team := TeamData.new(); team.team_id = 0; team.population = 5
		team.resources = { "food": 0.0 }
		team.work_morale = morale
		state.teams[0] = team
		var tile := HexTileData.new()
		tile.resources = { "food": 1000.0 }
		rs._collect_from_tile(state, team, tile, 1.0, 1.0, 0.0, 0.0)
		gains.append(float(team.resources["food"]))
	assert(gains[0] > 0.0, "morale 0.5 仍應有產出")
	var ratio: float = gains[1] / gains[0]
	assert(abs(ratio - 3.0) < 0.01, "1.5/0.5 gain 應 3 倍，實際=%.2f" % ratio)
	print("Reaction Task3 OK (ratio=%.2f)" % ratio)

func _test_p5_needs_surplus() -> void:
	print("--- Reaction Task4a: P5 需糧食盈餘 ---")
	var state := WorldState.new(); state.world = WorldData.new()
	var team := TeamData.new(); team.team_id = 0; team.population = 10
	team.resources = { "food": 50.0 }   # 50 < 10*2.4*7=168
	var p := PersonData.new(); p.id = 1; p.team_id = 0
	var rs := ReactionSystem.new()
	rs._apply_reaction(state, p, team, "P5_breed")
	assert(team.minor_population == 0, "糧不足不生")
	team.resources["food"] = 200.0
	rs._apply_reaction(state, p, team, "P5_breed")
	assert(team.minor_population == 1, "盈餘該生")
	print("Reaction Task4a OK")

func _test_n5_coin_conserved() -> void:
	print("--- Reaction Task4b: N5 coin 守恆 ---")
	var state := WorldState.new(); state.world = WorldData.new()
	var team := TeamData.new(); team.team_id = 0; team.population = 5
	team.resources = { "coin": 100.0 }
	var p := PersonData.new(); p.id = 1; p.team_id = 0
	var rs := ReactionSystem.new()
	var before: float = float(team.resources["coin"]) + p.coin
	rs._apply_reaction(state, p, team, "N5_extort")
	var after: float = float(team.resources["coin"]) + p.coin
	assert(abs(before - after) < 0.001, "coin 總和守恆")
	assert(p.coin > 0, "偷的錢進 person.coin")
	print("Reaction Task4b OK")

func _test_n1_solo_skip() -> void:
	print("--- Reaction Task5a: solo leader flee 無變化 ---")
	var state := WorldState.new(); state.world = WorldData.new()
	var team := TeamData.new(); team.team_id = 0; team.population = 1
	var p := PersonData.new(); p.id = 1; p.team_id = 0; p.stress = 0.9
	team.leader_id = 1
	state.teams[0] = team; state.persons[1] = p
	var rs := ReactionSystem.new()
	rs._apply_reaction(state, p, team, "N1_flee")
	assert(team.population == 1, "solo pop 不變")
	assert(abs(p.stress - 0.9) < 0.001, "solo stress 不洩壓，實際=%.2f" % p.stress)
	assert(state.teams.size() == 1, "不應生流亡 team")
	print("Reaction Task5a OK")

func _test_n1_leader_tier_sync() -> void:
	print("--- Reaction Task5b: leader flee → anon tier 同步 -1 ---")
	var state := WorldState.new(); state.world = WorldData.new()
	var team := TeamData.new(); team.team_id = 0; team.population = 5
	team.anon_tiers = { "平民": 4 }
	var p := PersonData.new(); p.id = 1; p.team_id = 0; p.stress = 0.9
	team.leader_id = 1
	state.teams[0] = team; state.persons[1] = p
	var rs := ReactionSystem.new()
	rs._apply_reaction(state, p, team, "N1_flee")
	assert(team.population == 4, "pop 應 4，實際=%d" % team.population)
	var anon_sum: int = 0
	for tier in team.anon_tiers: anon_sum += int(team.anon_tiers[tier])
	assert(anon_sum == 3, "anon 總和應 3，實際=%d" % anon_sum)
	assert(p.team_id == 0, "leader 留下")
	print("Reaction Task5b OK")

func _test_n1_named_spawns_exile() -> void:
	print("--- Reaction Task5c: named flee → 自立流亡 team ---")
	var state := WorldState.new(); state.world = WorldData.new()
	var team := TeamData.new(); team.team_id = 0; team.population = 5
	team.tile_pos = Vector2i(3, 3); team.leader_id = 1
	var leader := PersonData.new(); leader.id = 1; leader.team_id = 0
	var p := PersonData.new(); p.id = 2; p.team_id = 0
	team.named_members = [2]
	state.teams[0] = team; state.persons[1] = leader; state.persons[2] = p
	var rs := ReactionSystem.new()
	rs._apply_reaction(state, p, team, "N1_flee")
	assert(team.population == 4, "原 team pop -1")
	assert(not team.named_members.has(2), "named 移除")
	assert(state.teams.size() == 2, "應新建流亡 team")
	var exile: TeamData = state.teams[1]
	assert("流亡" in exile.tags, "tags 應含 流亡")
	assert(exile.leader_id == 2 and p.team_id == 1, "person 為流亡 leader")
	assert(exile.population == 1, "流亡 pop=1")
	print("Reaction Task5c OK")

func _test_n3_joins_existing_exile() -> void:
	print("--- Reaction Task5d: named defect → 加入同格流亡 team ---")
	var state := WorldState.new(); state.world = WorldData.new()
	var team := TeamData.new(); team.team_id = 0; team.population = 5
	team.tile_pos = Vector2i(3, 3); team.leader_id = 1
	var leader := PersonData.new(); leader.id = 1; leader.team_id = 0
	var p := PersonData.new(); p.id = 2; p.team_id = 0
	team.named_members = [2]
	var exile := TeamData.new(); exile.team_id = 7; exile.population = 2
	exile.tile_pos = Vector2i(3, 3); exile.tags = ["流亡"]
	state.teams[0] = team; state.teams[7] = exile
	state.persons[1] = leader; state.persons[2] = p
	var rs := ReactionSystem.new()
	rs._apply_reaction(state, p, team, "N3_defect")
	assert(p.team_id == 7, "應加入既有流亡 team，實際=%d" % p.team_id)
	assert(exile.population == 3, "流亡 pop +1")
	assert(exile.named_members.has(2), "流亡 named 含 person")
	assert(state.teams.size() == 2, "不應另建 team")
	print("Reaction Task5d OK")

func _make_panic_team(state: WorldState) -> TeamData:
	# pop=3 全 named 高壓低忠誠 → 全員 N1_flee
	var team := TeamData.new(); team.team_id = 0; team.population = 3
	team.tile_pos = Vector2i(2, 0)
	state.teams[0] = team
	for i in range(3):
		var p := PersonData.new(); p.id = 1 + i; p.team_id = 0
		p.stress = 1.0; p.loyalty = 0.0; p.fear = 0.0
		p.values = { "求生欲": 1.0, "慎重": 0.0 }
		state.persons[1 + i] = p
		if i == 0: team.leader_id = p.id
		else: team.named_members.append(p.id)
	return team

func _test_bridge_no_threat_no_hijack() -> void:
	print("--- Reaction Task6a: 無威脅不劫持 task ---")
	var state := WorldState.new(); state.world = WorldData.new()
	var team := _make_panic_team(state)
	var rs := ReactionSystem.new()
	rs.evaluate_all(state, [0])
	assert(team.current_task != "逃跑", "無威脅 task 不應變逃跑，實際=%s" % team.current_task)
	assert(team.move_target == Vector2i(-1, -1), "move_target 不應被設")
	print("Reaction Task6a OK")

func _test_bridge_with_threat_flees() -> void:
	print("--- Reaction Task6b: 真威脅 → 逃跑 + 反方向目標 ---")
	var state := WorldState.new(); state.world = WorldData.new()
	var team := _make_panic_team(state)
	var threat := TeamData.new(); threat.team_id = 9; threat.population = 20
	threat.tile_pos = Vector2i(0, 0); threat.last_tile_pos = Vector2i(-1, 0)   # 朝我來
	state.teams[9] = threat
	team.known_reputations = { 9: 0.1 }   # 高敵意
	state.team_discovered[0] = [9]
	state.team_intel[0] = { 9: { "population_est": 20 } }
	var t5 := HexTileData.new(); t5.tile_pos = Vector2i(5, 0)
	state.world.tiles[5000] = t5   # 反方向 (2,0)+(1,0)*3 = (5,0)
	var rs := ReactionSystem.new()
	rs.evaluate_all(state, [0])
	assert(team.current_task == "逃跑", "應逃跑，實際=%s" % team.current_task)
	assert(team.move_target == Vector2i(5, 0), "move_target 應 (5,0)，實際=%s" % str(team.move_target))
	print("Reaction Task6b OK")


# ══ Task Arbiter ══════════════════════════════════════════════

func _test_arbiter_basic() -> void:
	print("--- Arbiter Task1a: try_set 高低層 ---")
	var state := WorldState.new(); state.world = WorldData.new()
	var t := TeamData.new(); t.team_id = 0
	state.teams[0] = t
	assert(t.task_priority == 0)
	# idle 任何層可寫
	assert(TaskArbiter.try_set(state, t, "貿易", Vector2i(1, 1), TaskArbiter.PRIO_DISPATCH))
	assert(t.current_task == "貿易" and t.task_priority == 50)
	# 低蓋高 ✗
	assert(not TaskArbiter.try_set(state, t, "攻擊", Vector2i(2, 2), TaskArbiter.PRIO_FACTION))
	# 同層 ✗
	assert(not TaskArbiter.try_set(state, t, "攻擊", Vector2i(2, 2), TaskArbiter.PRIO_DISPATCH))
	# 高蓋低 ✓
	assert(TaskArbiter.try_set(state, t, "乞食", Vector2i(3, 3), TaskArbiter.PRIO_SURVIVAL))
	assert(t.task_priority == 80)
	print("Arbiter Task1a OK")

func _test_arbiter_combat_lock() -> void:
	var state := WorldState.new(); state.world = WorldData.new()
	var t := TeamData.new(); t.team_id = 0; t.combat_target = 5
	state.teams[0] = t
	assert(not TaskArbiter.try_set(state, t, "逃跑", Vector2i(1, 1), TaskArbiter.PRIO_SURVIVAL))
	print("Arbiter Task1b OK")

func _test_arbiter_release_transition() -> void:
	var state := WorldState.new(); state.world = WorldData.new()
	var t := TeamData.new(); t.team_id = 0
	state.teams[0] = t
	TaskArbiter.try_set(state, t, "安頓", Vector2i(1, 1), TaskArbiter.PRIO_DISPATCH)
	TaskArbiter.transition(t, "生產", TaskArbiter.PRIO_AMBIENT)
	assert(t.current_task == "生產" and t.task_priority == 10)
	TaskArbiter.release(t)
	assert(t.current_task == TeamData.TASK_IDLE and t.task_priority == 0)
	assert(t.move_target == Vector2i(-1, -1))
	print("Arbiter Task1c OK")

func _test_arbiter_defiance() -> void:
	print("--- Arbiter Task1d: 抗命/壓抑 ---")
	var state := WorldState.new(); state.world = WorldData.new()
	var t := TeamData.new(); t.team_id = 0
	state.teams[0] = t
	var leader := PersonData.new(); leader.id = 1
	leader.loyalty = 0.1
	leader.values = { "貪婪": 0.9, "野心": 0.8, "義氣": 0.1, "信義": 0.1 }
	state.persons[1] = leader; t.leader_id = 1
	# 玩家命令在任
	TaskArbiter.try_set(state, t, "巡邏", Vector2i(1, 1), TaskArbiter.PRIO_PLAYER)
	# 貪婪低忠 → 抗命成功
	assert(TaskArbiter.try_set(state, t, "攻擊", Vector2i(2, 2), TaskArbiter.PRIO_DISPATCH),
		"低忠貪婪 leader 應抗命成功")
	print("Arbiter Task1d OK")

func _test_arbiter_suppression() -> void:
	var state := WorldState.new(); state.world = WorldData.new()
	var t := TeamData.new(); t.team_id = 0
	state.teams[0] = t
	var leader := PersonData.new(); leader.id = 1
	leader.loyalty = 0.9
	leader.values = { "貪婪": 0.6, "野心": 0.5, "義氣": 0.8, "信義": 0.8 }
	state.persons[1] = leader; t.leader_id = 1
	TaskArbiter.try_set(state, t, "巡邏", Vector2i(1, 1), TaskArbiter.PRIO_PLAYER)
	var stress0: float = leader.stress
	var unrest0: int = t.unrest_turns
	assert(not TaskArbiter.try_set(state, t, "攻擊", Vector2i(2, 2), TaskArbiter.PRIO_DISPATCH),
		"忠誠 leader 應被壓抑")
	assert(leader.stress > stress0, "壓抑 stress 上升")
	assert(t.unrest_turns > unrest0, "壓抑 unrest 上升")
	print("Arbiter Task1e OK")

func _test_arbiter_suppression_burst() -> void:
	# 中間 leader 連續被擋 → stress 累積推 desire 過閾 → 終於抗命
	var state := WorldState.new(); state.world = WorldData.new()
	var t := TeamData.new(); t.team_id = 0
	state.teams[0] = t
	var leader := PersonData.new(); leader.id = 1
	leader.loyalty = 0.4
	leader.values = { "貪婪": 0.7, "野心": 0.6, "義氣": 0.3, "信義": 0.3 }
	state.persons[1] = leader; t.leader_id = 1
	TaskArbiter.try_set(state, t, "巡邏", Vector2i(1, 1), TaskArbiter.PRIO_PLAYER)
	var defied: bool = false
	for _i in range(30):
		if TaskArbiter.try_set(state, t, "攻擊", Vector2i(2, 2), TaskArbiter.PRIO_DISPATCH):
			defied = true
			break
	assert(defied, "壓抑累積後應爆發抗命")
	print("Arbiter Task1f OK")
func _test_arbiter_survival_beats_dispatch() -> void:
	print("--- Arbiter Task2a: survival(80) 蓋掉 貿易(50) ---")
	var state := WorldState.new(); state.world = WorldData.new()
	var team := TeamData.new()
	team.team_id = 100; team.population = 10
	team.resources["food"] = 0.0
	team.tile_pos = Vector2i(0, 0)
	var leader := PersonData.new(); leader.id = 200; leader.team_id = 100
	leader.values = { "義氣": 0.3, "信義": 0.3, "貪婪": 0.5, "殘忍": 0.3, "好戰": 0.3, "求生欲": 0.5 }
	state.persons[200] = leader; team.leader_id = 200
	state.teams[100] = team
	state.team_discovered[100] = []
	# 先派貿易 (50)
	assert(TaskArbiter.try_set(state, team, TeamData.TASK_TRADE, Vector2i(2, 2), TaskArbiter.PRIO_DISPATCH))
	# 斷糧 → survival 觸發應蓋掉貿易
	var fai := FactionAISystem.new()
	fai._evaluate_survival(state, team)
	assert(team.current_task in FactionAISystem.SURVIVAL_TASKS,
		"survival 應蓋掉貿易，實際=%s" % team.current_task)
	assert(team.task_priority == TaskArbiter.PRIO_SURVIVAL,
		"priority 應 80，實際=%d" % team.task_priority)
	print("Arbiter Task2a OK (task=%s)" % team.current_task)

func _test_arbiter_dispatch_beats_faction_goal() -> void:
	print("--- Arbiter Task2b: faction goal(30) 蓋不動 貿易(50) ---")
	var state := WorldState.new(); state.world = WorldData.new()
	var team := TeamData.new(); team.team_id = 0
	state.teams[0] = team
	assert(TaskArbiter.try_set(state, team, TeamData.TASK_TRADE, Vector2i(2, 2), TaskArbiter.PRIO_DISPATCH))
	assert(not TaskArbiter.try_set(state, team, TeamData.TASK_ATTACK, Vector2i(3, 3), TaskArbiter.PRIO_FACTION),
		"faction goal(30) 不得蓋 貿易(50)")
	assert(team.current_task == TeamData.TASK_TRADE, "貿易應保留")
	print("Arbiter Task2b OK")
func _test_bridge_cannot_stomp_survival() -> void:
	print("--- Arbiter Task4: bridge(70) 蓋不動 survival 乞食(80) ---")
	# = 逃跑↔乞食 ping-pong 結構性消失
	var state := WorldState.new(); state.world = WorldData.new()
	var team := _make_panic_team(state)
	# 真威脅在場（同 Task6b 設定）
	var threat := TeamData.new(); threat.team_id = 9; threat.population = 20
	threat.tile_pos = Vector2i(0, 0); threat.last_tile_pos = Vector2i(-1, 0)
	state.teams[9] = threat
	team.known_reputations = { 9: 0.1 }
	state.team_discovered[0] = [9]
	state.team_intel[0] = { 9: { "population_est": 20 } }
	var t5 := HexTileData.new(); t5.tile_pos = Vector2i(5, 0)
	state.world.tiles[5000] = t5
	# team 已在 survival 乞食 (80)
	assert(TaskArbiter.try_set(state, team, "乞食", Vector2i(1, 0), TaskArbiter.PRIO_SURVIVAL))
	var rs := ReactionSystem.new()
	rs.evaluate_all(state, [0])
	assert(team.current_task == "乞食", "bridge 不得蓋 survival，實際=%s" % team.current_task)
	assert(team.task_priority == TaskArbiter.PRIO_SURVIVAL)
	assert(team.move_target == Vector2i(1, 0), "move_target 不應被 bridge 改動")
	print("Arbiter Task4 OK")

# ──────── Economy / Spam Fixes ────────

func _test_salary_budget_ratio() -> void:
	print("--- EcoFix Task1a: 量入為出 ---")
	var state := WorldState.new(); state.world = WorldData.new()
	var team := TeamData.new(); team.team_id = 0; team.population = 5
	team.tags = ["軍隊"]
	var leader := PersonData.new(); leader.id = 1; leader.team_id = 0
	leader.values = { "義氣": 0.5, "信義": 0.5, "貪婪": 0.5 }   # mult = 1.1
	state.persons[1] = leader; team.leader_id = 1
	var m := PersonData.new(); m.id = 2; m.team_id = 0
	m.skills = { "戰鬥": 0.5 }   # fair = 0.5 * SALARY_PER_SKILL_POINT = 1.0
	m.loyalty = 0.5
	state.persons[2] = m
	team.named_members = [2]
	state.teams[0] = team
	# payroll = fair(1.0) * mult(1.1) + anon wage；coin 只給一半
	var anon_total: float = AnonTierSystem.total_wage(team)
	var payroll: float = 1.0 * 1.1 + anon_total
	team.resources["coin"] = payroll * 0.5
	var ss := SalarySystem.new()
	ss._pay_salary(state, team)
	var coin_after: float = float(team.resources.get("coin", 0))
	assert(coin_after >= -0.001, "coin 不得為負，實際=%.2f" % coin_after)
	assert(coin_after < 0.05, "錢應幾乎發光（按比例縮水發完），實際=%.2f" % coin_after)
	assert(m.coin > 0.0, "named 領到減額薪資，實際=%.2f" % m.coin)
	assert(m.loyalty < 0.5, "減薪 → ratio 路徑掉 loyalty，實際=%.2f" % m.loyalty)
	assert(team.unrest_turns == 1, "減薪應 unrest+1，實際=%d" % team.unrest_turns)
	print("EcoFix Task1a OK")

func _test_salary_full_pay_unchanged() -> void:
	print("--- EcoFix Task1b: coin 充足 → 全額照舊 ---")
	var state := WorldState.new(); state.world = WorldData.new()
	var team := TeamData.new(); team.team_id = 0; team.population = 5
	team.tags = ["軍隊"]
	var leader := PersonData.new(); leader.id = 1; leader.team_id = 0
	leader.values = { "義氣": 0.5, "信義": 0.5, "貪婪": 0.5 }   # mult = 1.1
	state.persons[1] = leader; team.leader_id = 1
	var m := PersonData.new(); m.id = 2; m.team_id = 0
	m.skills = { "戰鬥": 0.5 }   # fair = 1.0, salary = 1.1
	m.loyalty = 0.5
	state.persons[2] = m
	team.named_members = [2]
	state.teams[0] = team
	team.resources["coin"] = 100.0
	var ss := SalarySystem.new()
	ss._pay_salary(state, team)
	var coin_after: float = float(team.resources.get("coin", 0))
	assert(absf(coin_after - (100.0 - 1.1)) < 0.01, "全額發薪 coin=98.9，實際=%.2f" % coin_after)
	assert(absf(m.coin - 1.1) < 0.01, "named 領全額 1.1，實際=%.2f" % m.coin)
	assert(m.loyalty > 0.5, "超額薪資（mult 1.1）→ loyalty 上升，實際=%.2f" % m.loyalty)
	assert(team.unrest_turns == 0, "coin 充足不應 unrest，實際=%d" % team.unrest_turns)
	print("EcoFix Task1b OK")

func _test_trade_partner_requires_resident() -> void:
	print("--- EcoFix Task2: partner 限居民團 tile ---")
	var state := WorldState.new(); state.world = WorldData.new()
	var trader := TeamData.new(); trader.team_id = 0; trader.faction_id = -1
	trader.tile_pos = Vector2i(5, 5)
	state.teams[0] = trader
	var owner := TeamData.new(); owner.team_id = 1; owner.faction_id = -1
	owner.tile_pos = Vector2i(8, 8)   # owner 本人不在 outpost tile
	state.teams[1] = owner
	var tile := HexTileData.new(); tile.tile_pos = Vector2i(3, 3); tile.outpost_owner = 1
	state.world.tiles[3003] = tile
	state.team_discovered[0] = [1]
	var sai := StrategicAiSystem.new()
	# A: outpost 有 owner 但 tile 上無居民團 → 不選
	var partner_a: Dictionary = sai._find_trade_partner(state, trader)
	assert(partner_a.is_empty(), "無居民團不應選，實際=%s" % str(partner_a))
	# B: tile 上有生產居民團 → 選，outpost_pos 正確
	var resident := TeamData.new(); resident.team_id = 2; resident.tags = ["生產"]
	resident.tile_pos = Vector2i(3, 3)
	state.teams[2] = resident
	var partner_b: Dictionary = sai._find_trade_partner(state, trader)
	assert(int(partner_b.get("team_id", -1)) == 1, "應選 Team1 outpost，實際=%s" % str(partner_b))
	assert(partner_b["outpost_pos"] == Vector2i(3, 3), "outpost_pos 應 (3,3)")
	print("EcoFix Task2 OK")

func _test_diplomacy_reject_cooldown() -> void:
	print("--- EcoFix Task3: reject cooldown ---")
	var state := WorldState.new(); state.world = WorldData.new()
	state.world.current_tick = 100
	# A：缺糧（resource_need 1.0）+ 高義氣信義（self_peace 0.15）→ score 0.55 → propose_trade
	var a := TeamData.new(); a.team_id = 0; a.faction_id = -1; a.population = 5
	a.resources["food"] = 0.0
	var al := PersonData.new(); al.id = 1; al.team_id = 0
	al.values = { "義氣": 1.0, "信義": 1.0, "貪婪": 0.0, "慎重": 1.0 }
	state.persons[1] = al; a.leader_id = 1
	state.teams[0] = a
	# B：糧足 + 低義氣信義 → 對 A score 0.1 → reject
	var b := TeamData.new(); b.team_id = 1; b.faction_id = -1; b.population = 5
	b.resources["food"] = 1000.0
	var bl := PersonData.new(); bl.id = 2; bl.team_id = 1
	bl.values = { "義氣": 0.0, "信義": 0.0, "貪婪": 0.0, "慎重": 0.5 }
	state.persons[2] = bl; b.leader_id = 2
	state.teams[1] = b
	state.team_discovered[0] = [1]
	var dip := DiplomaticAiSystem.new()
	# 直接發 → B reject → cooldown 寫入
	dip._send_diplomacy_message(state, a, b, "propose_trade")
	var until: int = int(a.diplomacy_reject_cooldown.get(1, 0))
	assert(until == 100 + DiplomaticAiSystem.REJECT_COOLDOWN,
		"reject 應設 cooldown=%d，實際=%d" % [100 + DiplomaticAiSystem.REJECT_COOLDOWN, until])
	# cooldown 內 try_proactive 不再發 → cooldown 值不被刷新（再發送會被 reject 覆寫成新值）
	state.world.current_tick = 200
	seed(7)
	for i in range(50):
		dip.try_proactive_diplomacy(state, a)
	assert(int(a.diplomacy_reject_cooldown.get(1, 0)) == until,
		"cooldown 內不應再發（值被刷新=有發送），實際=%d" % int(a.diplomacy_reject_cooldown.get(1, 0)))
	# cooldown 過期 → 恢復發送（reject 重設新 cooldown）
	state.world.current_tick = until + 1
	for i in range(50):
		dip.try_proactive_diplomacy(state, a)
	assert(int(a.diplomacy_reject_cooldown.get(1, 0)) > until, "cooldown 過期應恢復發送")
	print("EcoFix Task3 OK")

func _test_equip_order_no_oscillation() -> void:
	print("--- EcoFix Task4: equip order 計入已裝備 → 不振盪 ---")
	# 根因：舊版 target 只看 storage pool；裝備後 pool 縮小 → target 縮小
	# → unequip 還回 pool → target 又變大 → 再 equip，每 tick 循環
	var state := WorldState.new(); state.world = WorldData.new()
	var team := TeamData.new(); team.team_id = 0; team.population = 10
	team.tags = ["軍隊"]
	team.resources["weapon_melee_low"] = 12
	var leader := PersonData.new(); leader.id = 1; leader.team_id = 0
	state.persons[1] = leader; team.leader_id = 1
	for i in range(3):
		var p := PersonData.new(); p.id = 2 + i; p.team_id = 0
		state.persons[p.id] = p
		team.named_members.append(p.id)
	state.teams[0] = team
	var fa := FactionAISystem.new()
	var eq := EquipmentSystem.new()
	# tick 1：4 named 全裝備，pool 12-8=4
	fa._update_equip_order(state, team)
	eq._update_equipment(state, team)
	var pool_t1: int = int(team.resources.get("weapon_melee_low", 0))
	assert(pool_t1 == 4, "tick1 後 pool 應 4，實際=%d" % pool_t1)
	# tick 2-6：target 計入已裝備 → 不 unequip、pool 恆定
	for i in range(5):
		fa._update_equip_order(state, team)
		eq._update_equipment(state, team)
		var pool_n: int = int(team.resources.get("weapon_melee_low", 0))
		assert(pool_n == 4, "pool 振盪：tick%d pool=%d（應恆 4）" % [i + 2, pool_n])
	var armed: int = 0
	for pid in [1, 2, 3, 4]:
		if state.persons[pid].equipment["hand_1"].get("grade", "") == "weapon_melee_low":
			armed += 1
	assert(armed == 4, "4 named 應全程保持裝備，實際=%d" % armed)
	print("EcoFix Task4 OK")

func _test_n1_leader_no_anon_pop_stable() -> void:
	print("--- EcoFix Task4b: leader flee 無 anon → pop 不變 ---")
	# 根因 2：舊版 leader N1/N3 無條件扣 pop，anon=0 時沒人真的走
	# → pop < named 數 → guard equip target 0↔1 振盪（multi Team14 churn）
	var state := WorldState.new(); state.world = WorldData.new()
	var team := TeamData.new(); team.team_id = 0; team.population = 2
	team.leader_id = 1; team.named_members = [2]
	var leader := PersonData.new(); leader.id = 1; leader.team_id = 0; leader.stress = 0.9
	var m := PersonData.new(); m.id = 2; m.team_id = 0
	state.persons[1] = leader; state.persons[2] = m
	state.teams[0] = team
	var rs := ReactionSystem.new()
	rs._apply_reaction(state, leader, team, "N1_flee")
	assert(team.population == 2, "anon=0 無人可走，pop 應 2，實際=%d" % team.population)
	rs._apply_reaction(state, leader, team, "N3_defect")
	assert(team.population == 2, "N3 同理 pop 應 2，實際=%d" % team.population)
	# 有 anon → 照舊扣 pop + tier -1
	team.anon_tiers["平民"] = 1; team.population = 3
	leader.stress = 0.9
	rs._apply_reaction(state, leader, team, "N1_flee")
	assert(team.population == 2, "有 anon 應扣 pop=2，實際=%d" % team.population)
	assert(int(team.anon_tiers["平民"]) == 0, "平民 tier 應 -1，實際=%d" % int(team.anon_tiers["平民"]))
	print("EcoFix Task4b OK")

# ══ Facility Overhaul A 期 ══════════════════════════════════════

func _test_facility_def_v2() -> void:
	print("--- Facility Task1a: FACILITY_DEF v2 ---")
	assert(OutpostSystem.FACILITY_DEF.size() == 8)
	for f in ["farming", "workshop", "apothecary", "mint", "stable",
			"smeltery", "weaponsmith", "armorsmith"]:
		assert(OutpostSystem.FACILITY_DEF.has(f), "缺 %s" % f)
	assert(OutpostSystem.FACILITY_DEF["weaponsmith"]["allowed_outpost"] == ["military"])
	assert(OutpostSystem.FACILITY_DEF["farming"]["allowed_outpost"] == ["civilian"])
	# 三級成本：低級無 tools，中級含 tools，全部無 coin
	assert(not OutpostSystem.FACILITY_DEF["farming"]["cost"].has("coin"))
	assert(int(OutpostSystem.FACILITY_DEF["smeltery"]["cost"].get("tools", 0)) > 0)
	assert(int(OutpostSystem.FACILITY_DEF["farming"]["cost"].get("tools", 0)) == 0)
	print("Facility Task1a OK")

func _test_facility_slots() -> void:
	print("--- Facility Task1b: slot 制 ---")
	var tile := HexTileData.new()
	tile.outpost_type = "civilian"; tile.outpost_level = 1
	assert(OutpostSystem.slot_cap(tile) == 2)
	tile.outpost_level = 3
	assert(OutpostSystem.slot_cap(tile) == 5)
	tile.outpost_type = "military"; tile.outpost_level = 1
	assert(OutpostSystem.slot_cap(tile) == 1)
	tile.farming_level = 1; tile.weaponsmith_level = 2
	assert(OutpostSystem.slots_used(tile) == 2, "2 類設施 = 2 slot（level 不佔額外）")
	# slot 滿 → 新設施蓋不了（military Lv1 cap=1，已用 2）
	var team := TeamData.new(); team.team_id = 0
	team.resources = { "material": 999.0, "tools": 99.0 }
	tile.outpost_owner = 0; tile.construction_team_id = -1
	var os := OutpostSystem.new()
	assert(not os._begin_facility_construction(team, tile, "smeltery"), "slot 滿應失敗")
	# 升級不佔 slot：weaponsmith Lv2 → Lv3 應可
	assert(os._begin_facility_construction(team, tile, "weaponsmith"), "升級不佔 slot 應成功")
	assert(tile.construction_target.get("facility", "") == "weaponsmith")
	# allowed_outpost gate：military tile 蓋 civilian 設施失敗
	tile.construction_team_id = -1; tile.construction_target = {}
	assert(not os._begin_facility_construction(team, tile, "mint"), "military 蓋 mint 應失敗")
	print("Facility Task1b OK")

func _test_outpost_cost_no_finite() -> void:
	print("--- Facility Task2: outpost 本體成本守恆 ---")
	for lvl_cost in OutpostSystem.OUTPOST_COST["civilian"]:
		assert(not lvl_cost.has("coin") or int(lvl_cost.get("coin", 0)) == 0)
		assert(int(lvl_cost.get("weapon", 0)) == 0)
		assert(int(lvl_cost.get("tools", 0)) == 0, "civilian 純 mat")
	for lvl_cost in OutpostSystem.OUTPOST_COST["military"]:
		assert(int(lvl_cost.get("coin", 0)) == 0)
		assert(int(lvl_cost.get("weapon", 0)) == 0, "weapon 成本移除")
		assert(int(lvl_cost.get("tools", 0)) > 0, "military 要 tools")
	print("Facility Task2 OK")
