class_name GameSetup

const RICHNESS_MULT: Dictionary = {
	1: 0.2, 2: 0.4, 3: 0.6, 4: 0.8, 5: 1.0,
	6: 1.5, 7: 2.5, 8: 4.0, 9: 6.5, 10: 10.0
}

const TEAM_RESOURCE_PRESET: Dictionary = {
	"faction_main": {
		"food": 500.0, "material": 80.0, "coin": 50,
		"weapon_melee_low": 8, "armor_low": 4
	},
	"faction_branch": {
		"food": 250.0, "material": 30.0, "coin": 15,
		"weapon_melee_low": 4, "armor_low": 1
	},
	"independent_settled": {
		"food": 320.0, "material": 60.0, "coin": 20
	},
	"independent_roving": {
		"food": 180.0, "coin": 8, "weapon_melee_low": 2
	}
}

const FLOAT_RES_KEYS: Array = ["food", "material"]

static func setup(state: WorldState, config: Dictionary) -> void:
	var mode: String = config.get("mode", "random")
	var rng := RandomNumberGenerator.new()
	rng.seed = int(config.get("seed", 42))
	_generate_map(state, config, rng)
	if mode == "explicit":
		_setup_explicit_teams(state, config)
		_setup_player(state, config)
	else:
		var outpost_plan: Dictionary = _plan_outposts(state, config, rng)
		_generate_factions(state, outpost_plan, config, rng)
		_generate_independent_teams(state, outpost_plan, config, rng)
		_setup_random_player(state, config, rng)

	print("[GameSetup] 完成：%d teams, %d factions, %d persons" %
		[state.teams.size(), state.factions.size(), state.persons.size()])

static func load_config(path: String) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Config not found: " + path)
		return {}
	var json := JSON.new()
	var err := json.parse(file.get_as_text())
	if err != OK:
		push_error("Config JSON parse error at line %d: %s" % [
			json.get_error_line(), json.get_error_message()])
		return {}
	return json.data

# ── 子步驟 ──

static func _generate_map(state, config, rng) -> void:
	var map_cfg: Dictionary = config.get("map", {})
	var richness_level: int = int(map_cfg.get("resource_richness", 5))
	var richness_mult: float = RICHNESS_MULT.get(richness_level, 1.0)

	var gen = load("res://scripts/simulation/world_generator.gd").new()
	gen.generate(state, {
		"radius": int(map_cfg.get("radius", 4)),
		"seed": rng.randi(),
		"resource_multiplier": richness_mult
	})

static func _plan_outposts(state, config, rng) -> Dictionary:
	var ocfg: Dictionary = config.get("outposts", {})
	var total: int = int(ocfg.get("total_count", 10))
	var min_sp: int = int(ocfg.get("min_spacing", 2))
	var indep_ratio: float = float(ocfg.get("independent_ratio", 0.3))
	var type_ratio: Dictionary = ocfg.get("type_ratio",
		{ "civilian": 0.6, "military": 0.4 })

	var gen = load("res://scripts/simulation/world_generator.gd").new()
	var positions: Array = gen.pick_start_positions(state, total, min_sp)
	if positions.size() < total:
		push_warning("Only %d outposts placed (wanted %d)" % [positions.size(), total])

	var types: Dictionary = {}
	var civ_ratio: float = float(type_ratio.get("civilian", 0.6))
	for pos in positions:
		types[pos] = "civilian" if rng.randf() < civ_ratio else "military"

	var indep_count: int = int(round(positions.size() * indep_ratio))
	var indep_outposts: Array = positions.slice(0, indep_count)
	var faction_pool: Array = positions.slice(indep_count)

	var fcfg: Dictionary = config.get("factions", {})
	var fcount: int = int(fcfg.get("count", 2))
	var weights: Array = fcfg.get("weights", [])
	if weights.size() < fcount:
		weights = []
		for i in range(fcount):
			weights.append(1)

	var total_w: int = 0
	for w in weights: total_w += int(w)
	if total_w == 0: total_w = 1

	var faction_outposts: Dictionary = {}
	var assigned: int = 0
	for fi in range(fcount):
		var share: int
		if fi == fcount - 1:
			share = faction_pool.size() - assigned
		else:
			share = int(faction_pool.size() * float(weights[fi]) / float(total_w))
		faction_outposts[fi] = faction_pool.slice(assigned, assigned + share)
		assigned += share

	return {
		"faction_outposts": faction_outposts,
		"independent_outposts": indep_outposts,
		"outpost_types": types
	}

static func _generate_factions(state, plan, config, rng) -> void:
	var fcfg: Dictionary = config.get("factions", {})
	var range_per: Array = fcfg.get("teams_per_faction_range", [2, 4])
	var tcfg: Dictionary = config.get("teams", {})
	var pop_range: Array = tcfg.get("population_range", [8, 25])
	var named_ratio: float = float(tcfg.get("named_ratio", 0.3))
	var richness_mult: float = RICHNESS_MULT.get(
		int(config.get("map", {}).get("resource_richness", 5)), 1.0)
	var granary: float = float(config.get("opening_granary_food", 0.0))

	for fi in plan.faction_outposts:
		var outposts: Array = plan.faction_outposts[fi]
		if outposts.is_empty(): continue

		var main_pos: Vector2i = outposts[0]
		var main_type: String = plan.outpost_types[main_pos]

		var team_count: int = rng.randi_range(range_per[0], range_per[1])
		var this_faction_team_ids: Array = []
		for ti in range(team_count):
			var team: TeamData = _create_team(state, rng, pop_range,
				named_ratio, richness_mult,
				"faction_main" if ti == 0 else "faction_branch")
			if ti == 0:
				team.tile_pos = main_pos
			else:
				team.tile_pos = _random_near(state, outposts, rng)
			this_faction_team_ids.append(team.team_id)

		var first_team_id: int = this_faction_team_ids[0]
		var faction_id: int = state.create_faction(first_team_id)

		for tid in this_faction_team_ids.slice(1):
			state.set_team_faction(state.teams[tid], faction_id)   # 入 faction（雙向同步）

		_build_outpost_tile(state, main_pos, main_type, 1, first_team_id, granary)
		for opos in outposts.slice(1):
			_build_outpost_tile(state, opos, plan.outpost_types[opos], 1, first_team_id, granary)

static func _generate_independent_teams(state, plan, config, rng) -> void:
	var indep_cfg: Dictionary = config.get("independent_teams", {})
	var tcfg: Dictionary = config.get("teams", {})
	var pop_range: Array = tcfg.get("population_range", [8, 25])
	var named_ratio: float = float(tcfg.get("named_ratio", 0.3))
	var richness_mult: float = RICHNESS_MULT.get(
		int(config.get("map", {}).get("resource_richness", 5)), 1.0)
	var granary: float = float(config.get("opening_granary_food", 0.0))

	for opos in plan.independent_outposts:
		_build_outpost_tile(state, opos, plan.outpost_types[opos], 1, -1, granary)
		if rng.randf() < 0.5:
			var team: TeamData = _create_team(state, rng, pop_range,
				named_ratio, richness_mult, "independent_settled")
			team.tile_pos = opos
			var key: int = opos.x * 1000 + opos.y
			OutpostOwnerBank.set_owner(state.world.tiles[key], team.team_id, "init")
			# 補注 granary：據點方入主（_build_outpost_tile 時 owner=-1 未注）→ 有主才給 buffer。
			if granary > 0.0:
				TileBank.deposit(state.world.tiles[key], "food", granary, "gen_seed")

	var roving_range: Array = indep_cfg.get("roving_count_range", [2, 4])
	var roving_count: int = rng.randi_range(roving_range[0], roving_range[1])
	for _i in range(roving_count):
		var team: TeamData = _create_team(state, rng, pop_range,
			named_ratio, richness_mult, "independent_roving")
		team.tile_pos = _random_empty_tile(state, rng)

static func _setup_random_player(state, config, rng) -> void:
	var pcfg: Dictionary = config.get("player", {})
	var join_mode: String = pcfg.get("join_mode", "independent")
	var richness_mult: float = RICHNESS_MULT.get(
		int(config.get("map", {}).get("resource_richness", 5)), 1.0)

	var team := TeamData.new()
	team.team_id = _next_team_id(state)
	var target_pop: int = int(pcfg.get("population", 10))
	state.set_team_tags(team, ["統領"], "player_init")
	team.resources = _default_full_resources()
	var starting: Dictionary = pcfg.get("starting_resources", {})
	for k in starting:
		if k in FLOAT_RES_KEYS:
			ResourceBank.set_amt(team, k, float(starting[k]) * richness_mult, "init_starting")
		else:
			ResourceBank.set_amt(team, k, int(round(float(starting[k]) * richness_mult)), "init_starting")

	var leader := PersonData.new()
	leader.id = _next_person_id(state)
	leader.person_name = pcfg.get("leader_name", "玩家")
	leader.role = "leader"
	leader.team_id = team.team_id
	leader.age = 30
	LoyaltyBank.set_baseline(leader, 1.0, "init")
	# 統領初始值需支撐起始人口：pop_cap_from_leadership(0.15) = 10
	leader.skills["統領"] = 0.15
	state.persons[leader.id] = leader
	state.set_leader(team, leader.id)   # chokepoint：leader_id+team_id+role（建國）
	state.player_id = leader.id

	var named_count: int = int(pcfg.get("starting_named_count", 1))
	for _i in range(named_count):
		var m := PersonGenerator.generate(state, rng.randi(), "member")
		m.team_id = team.team_id
		state.persons[m.id] = m
		state.add_member(team, m.id)

	_setup_anon_tiers(team, {}, target_pop)
	state.create_team(team)   # S9 chokepoint：註冊 + known/discovered init
	state.player_state = { "inventory": [],
	                       "coin": float(starting.get("coin", 0)) }

	match join_mode:
		"independent":
			team.tile_pos = _random_empty_tile(state, rng)

		"new_faction":
			var weakest_fid: int = _find_weakest_faction(state, config)
			if weakest_fid == -1:
				team.tile_pos = _random_empty_tile(state, rng)
				push_warning("No faction to take over, fallback to independent")
			else:
				var faction = state.factions[weakest_fid]
				var old_leader_team: TeamData = state.teams.get(faction.leader_team_id)
				if old_leader_team:
					team.tile_pos = old_leader_team.tile_pos
				else:
					team.tile_pos = _random_empty_tile(state, rng)
				state.set_team_faction(team, weakest_fid)   # 玩家入 faction（雙向同步）
				var old_leader_tid: int = faction.leader_team_id
				faction.leader_team_id = team.team_id
				print("[GameSetup] 玩家成為勢力 %d 統領（原 leader_team=%d 保留為下屬）" %
					[weakest_fid, old_leader_tid])

		_:
			if join_mode.begins_with("join:"):
				var fi: int = int(join_mode.substr(5))
				if state.factions.has(fi):
					state.set_team_faction(team, fi)   # 入 faction（雙向同步）
					var lt: TeamData = state.teams.get(state.factions[fi].leader_team_id)
					if lt:
						team.tile_pos = _random_near(state, [lt.tile_pos], rng)
					else:
						team.tile_pos = _random_empty_tile(state, rng)
				else:
					team.tile_pos = _random_empty_tile(state, rng)
					push_warning("Faction %d not found, fallback to independent" % fi)
			else:
				team.tile_pos = _random_empty_tile(state, rng)
				push_warning("Unknown join_mode: %s" % join_mode)

static func _find_weakest_faction(state, config) -> int:
	var weights: Array = config.get("factions", {}).get("weights", [])
	if weights.is_empty() or state.factions.is_empty():
		return -1
	var min_w: int = 999999; var min_idx: int = -1
	for i in range(weights.size()):
		if int(weights[i]) < min_w:
			min_w = int(weights[i])
			min_idx = i
	var sorted_fids: Array = state.factions.keys()
	sorted_fids.sort()
	if min_idx >= 0 and min_idx < sorted_fids.size():
		return sorted_fids[min_idx]
	return -1

# ── 內部 helpers ──────────────────────────────────────

static func _next_team_id(state: WorldState) -> int:
	var m: int = -1
	for tid in state.teams:
		if int(tid) > m: m = int(tid)
	return m + 1

static func _next_person_id(state: WorldState) -> int:
	var m: int = -1
	for pid in state.persons:
		if int(pid) > m: m = int(pid)
	return m + 1

static func _hex_dist(a: Vector2i, b: Vector2i) -> int:
	var dx := b.x - a.x; var dy := b.y - a.y
	return (abs(dx) + abs(dx + dy) + abs(dy)) / 2

static func _is_tile_occupied(state: WorldState, pos: Vector2i) -> bool:
	for tid in state.teams:
		if state.teams[tid].tile_pos == pos: return true
	return false

static func _random_near(state: WorldState, positions: Array, rng) -> Vector2i:
	if positions.is_empty(): return _random_empty_tile(state, rng)
	var origin: Vector2i = positions[rng.randi() % positions.size()]
	var dirs: Array = [Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1),
	                   Vector2i(0,-1), Vector2i(1,-1), Vector2i(-1,1)]
	# 隨機起點掃 6 方向，取第一個「存在且未被佔」鄰格；全越界/被佔 → 退 _random_empty_tile。
	# RNG 保近 case 不變：start 1 抽取代舊 dir 抽，for 掃描不呼 rng（純位移）→ 非邊緣 origin 同舊消耗。
	var start: int = rng.randi() % dirs.size()
	for i in range(dirs.size()):
		var cand: Vector2i = origin + dirs[(start + i) % dirs.size()]
		var key: int = cand.x * 1000 + cand.y
		if state.world.tiles.has(key) and not _is_tile_occupied(state, cand):
			return cand
	return _random_empty_tile(state, rng)   # 邊緣全鄰格越界/被佔 → 安全兜底

static func _random_empty_tile(state: WorldState, rng) -> Vector2i:
	var keys: Array = state.world.tiles.keys()
	if keys.is_empty(): return Vector2i(0, 0)
	var attempts: int = 50
	while attempts > 0:
		var k: int = keys[rng.randi() % keys.size()]
		var pos := Vector2i(k / 1000, k % 1000)
		if not _is_tile_occupied(state, pos):
			return pos
		attempts -= 1
	return Vector2i(keys[0] / 1000, keys[0] % 1000)

static func _build_outpost_tile(state: WorldState, pos: Vector2i,
		type_str: String, level: int, owner_team_id: int,
		granary_food: float = 0.0) -> void:
	var key: int = pos.x * 1000 + pos.y
	var tile: HexTileData = state.world.tiles.get(key)
	if tile == null: return
	tile.outpost_type  = type_str
	tile.outpost_level = level
	OutpostOwnerBank.set_owner(tile, owner_team_id, "init")
	# 開局糧倉 buffer（緩坡旋鈕，TEST VALUE）：注入公庫 food（effective_food 讀 own granary
	# → 開局幾月不餓崩，讓 pop 從初始緩降至穩態而非懸崖）。走 TileBank.deposit（bootstrap
	# 亦走 bank，reason="gen_seed" → driver-ledger 可查；deposit 自帶 FOOD_STORAGE_CAP clamp）。
	# 只注入「有主」outpost——無主（owner=-1）據點 effective_food 讀不到（需 outpost_owner==team），
	# 注了=鬼糧浪費 buffer + 白送 raider。無主 indep 據點的 granary 由呼叫端在 set_owner 後補注。
	if granary_food > 0.0 and owner_team_id != -1:
		TileBank.deposit(tile, "food", granary_food, "gen_seed")

static func _setup_anon_tiers(team: TeamData, cfg: Dictionary, target_pop: int) -> void:
	# population 為 getter（leader+named+anon）→ 不可讀回算 anon；改傳 config 目標 pop。
	var at: Dictionary = cfg.get("anon_tiers", {})
	if at.is_empty():
		var named_in: int = team.named_members.size() + (1 if team.leader_id != -1 else 0)
		var anon_total: int = maxi(target_pop - named_in, 0)
		AnonCohort.add(team.anon_cohorts, AnonCohort.TIER_PLEB, "healthy", anon_total)
	else:
		for tier in AnonTierSystem.TIER_ORDER:
			AnonCohort.add(team.anon_cohorts, tier, "healthy", int(at.get(tier, 0)))

static func _default_full_resources() -> Dictionary:
	return {
		"food": 0.0, "material": 0.0, "coin": 0, "goods": 0,
		"gem": 0, "ore_gold": 0, "ore_silver": 0, "ore_iron": 0, "ore_steel": 0,
		"weapon_melee_low": 0, "weapon_melee_high": 0,
		"weapon_ranged_low": 0, "weapon_ranged_high": 0,
		"mounts": 0, "wagons": 0, "arrows": 0, "medicine": 0, "tools": 0,
		"armor_low": 0, "armor_high": 0
	}

static func _apply_preset_resources(team: TeamData, preset_key: String,
		richness_mult: float) -> void:
	var preset: Dictionary = TEAM_RESOURCE_PRESET[preset_key]
	for k in preset:
		if k in FLOAT_RES_KEYS:
			ResourceBank.set_amt(team, k, float(preset[k]) * richness_mult, "init_preset")
		else:
			ResourceBank.set_amt(team, k, int(round(float(preset[k]) * richness_mult)), "init_preset")

static func _create_team(state: WorldState, rng, pop_range: Array,
		named_ratio: float, richness_mult: float, preset_key: String) -> TeamData:
	var team := TeamData.new()
	team.team_id = _next_team_id(state)
	var target_pop: int = rng.randi_range(pop_range[0], pop_range[1])

	match preset_key:
		"faction_main":         state.set_team_tags(team, ["統領"], "gen_preset")
		"faction_branch":       state.set_team_tags(team, ["獨立軍隊"], "gen_preset")
		"independent_settled":  state.set_team_tags(team, [], "gen_preset")
		"independent_roving":   state.set_team_tags(team, ["獨立軍隊"], "gen_preset")

	team.resources = _default_full_resources()
	_apply_preset_resources(team, preset_key, richness_mult)

	var leader := PersonGenerator.generate(state, rng.randi(), "leader")
	leader.team_id = team.team_id
	state.persons[leader.id] = leader
	state.set_leader(team, leader.id)   # chokepoint：leader_id+team_id+role（建國）

	var named_count: int = maxi(0, int(round(target_pop * named_ratio)) - 1)
	for _i in range(named_count):
		var m := PersonGenerator.generate(state, rng.randi(), "member")
		m.team_id = team.team_id
		state.persons[m.id] = m
		state.add_member(team, m.id)

	_setup_anon_tiers(team, {}, target_pop)
	state.create_team(team)   # S9 chokepoint：註冊 + known/discovered init
	return team

# ── explicit mode ─────────────────────────────────────────────────

static func _setup_explicit_teams(state: WorldState, config: Dictionary) -> void:
	var teams_cfg: Array = config.get("teams", [])
	if teams_cfg.is_empty():
		push_error("explicit mode 但 teams 陣列為空")
		return
	# 先 build teams（create_faction 需要 team 已存在於 state.teams）
	for t_cfg in teams_cfg:
		_build_explicit_team(state, t_cfg)
	# 再 create factions（leader 自動加入 member_team_ids）
	var seen_factions: Dictionary = {}
	for t_cfg in teams_cfg:
		var fid: int = int(t_cfg.get("faction_id", -1))
		if fid == -1: continue
		if seen_factions.has(fid): continue
		seen_factions[fid] = true
		if t_cfg.get("is_faction_leader", false):
			state.create_faction(int(t_cfg["id"]))
	# 第三段：非 leader 的 faction member 加入 faction list（leader 在 create_faction 已加）
	for t_cfg in teams_cfg:
		var fid2: int = int(t_cfg.get("faction_id", -1))
		if fid2 == -1: continue
		if t_cfg.get("is_faction_leader", false): continue
		var tid: int = int(t_cfg["id"])
		if state.factions.has(fid2) and state.teams.has(tid):
			state.set_team_faction(state.teams[tid], fid2)   # 入 faction（雙向同步）
	for ta_cfg in teams_cfg:
		var ta_id: int = int(ta_cfg["id"])
		if not state.team_discovered.has(ta_id):
			state.team_discovered[ta_id] = []
		if not state.team_known.has(ta_id):
			state.team_known[ta_id] = []
		for tb_cfg in teams_cfg:
			var tb_id: int = int(tb_cfg["id"])
			if ta_id != tb_id and not state.team_discovered[ta_id].has(tb_id):
				state.team_discovered[ta_id].append(tb_id)

static func _build_explicit_team(state: WorldState, t_cfg: Dictionary) -> void:
	var team := TeamData.new()
	team.team_id = int(t_cfg["id"])
	var pos_arr: Array = t_cfg.get("tile_pos", [0, 0])
	team.tile_pos = Vector2i(int(pos_arr[0]), int(pos_arr[1]))
	var target_pop: int = int(t_cfg.get("population", 1))
	state.set_team_tags(team, t_cfg.get("tags", []).duplicate(), "explicit_init")
	# faction_id 不在此預設（factions 尚未建立）；leader 由 create_faction、非 leader 由第三段 set_team_faction 設
	# 入口（set_team_faction）有 idempotent early-return：fresh team faction_id 已 -1 → no-op，第三段照常 append。
	state.set_team_faction(team, -1)   # S11 chokepoint（fresh team，no-op；單寫者一致）
	var base_res: Dictionary = _default_full_resources()
	for k in t_cfg.get("resources", {}):
		base_res[k] = t_cfg["resources"][k]
	team.resources = base_res
	state.create_team(team)   # S9 chokepoint：註冊 + known/discovered init
	var leader_cfg: Dictionary = t_cfg.get("leader", {})
	var leader: PersonData = _make_person(team.team_id, leader_cfg, true)
	state.persons[leader.id] = leader
	state.set_leader(team, leader.id)   # chokepoint：leader_id+team_id+role（建國）
	for nm_cfg in t_cfg.get("named_members", []):
		var nm: PersonData = _make_person(team.team_id, nm_cfg, false)
		state.persons[nm.id] = nm
		state.add_member(team, nm.id)
	_setup_anon_tiers(team, t_cfg, target_pop)
	var op_cfg: Dictionary = t_cfg.get("outpost", {})
	if not op_cfg.is_empty():
		var tile_id: int = team.tile_pos.x * 1000 + team.tile_pos.y
		var tile: HexTileData = state.world.tiles.get(tile_id)
		if tile:
			if op_cfg.has("terrain"):
				tile.terrain = String(op_cfg["terrain"])   # explicit 場景可釘地形（如村莊放可農平原）
			tile.outpost_type = op_cfg.get("type", "civilian")
			tile.outpost_level = int(op_cfg.get("level", 1))
			OutpostOwnerBank.set_owner(tile, team.team_id, "init")
			if op_cfg.has("tile_food_init"):
				var f: float = float(op_cfg["tile_food_init"])
				tile.resources["food"] = f
				# bug 修：tile_food_init 須同抬 resource_cap，否則初始糧吃完後 regen 卡回地形預設 → 村餓死
				tile.resource_cap["food"] = maxf(float(tile.resource_cap.get("food", 0)), f)
	# 注意：faction member 加入由 _setup_explicit_teams 第三段處理（factions 此時尚未建立）

static func _make_person(team_id: int, p_cfg: Dictionary, is_leader: bool) -> PersonData:
	var p := PersonData.new()
	p.id = (team_id * 1000) + (0 if is_leader else _next_member_id(team_id))
	p.person_name = p_cfg.get("name", "P%d" % p.id)
	p.role = "leader" if is_leader else "civilian"
	p.team_id = team_id
	p.age = int(p_cfg.get("age", 30))
	LoyaltyBank.set_baseline(p, float(p_cfg.get("loyalty", 0.8)), "init")
	p.stress = float(p_cfg.get("stress", 0.0))
	p.salary = float(p_cfg.get("salary", 0.0))
	for k in p_cfg.get("skills", {}):
		p.skills[k] = float(p_cfg["skills"][k])
	for k in p_cfg.get("values", {}):
		p.values[k] = float(p_cfg["values"][k])
	for k in p_cfg.get("attributes", {}):
		p.attributes[k] = float(p_cfg["attributes"][k])
	return p

static var _member_counters: Dictionary = {}
static func _next_member_id(team_id: int) -> int:
	var n: int = int(_member_counters.get(team_id, 0)) + 1
	_member_counters[team_id] = n
	return n

static func _setup_player(state: WorldState, config: Dictionary) -> void:
	var pcfg: Dictionary = config.get("player", {})
	if pcfg.is_empty():
		return
	var pteam_id: int = int(pcfg.get("team_id", -1))
	if pteam_id == -1 or not state.teams.has(pteam_id):
		push_warning("player.team_id=%d 不存在" % pteam_id)
		return
	var pteam: TeamData = state.teams[pteam_id]
	state.player_id = pteam.leader_id

# ── command schedule ───────────────────────────────────────────────

static func run_command_schedule_tick(state: WorldState, cmd_sys,
		schedule: Array, current_tick: int) -> Dictionary:
	var fired: Array = []
	var results: Array = []
	for entry in schedule:
		if int(entry.get("tick", -1)) != current_tick:
			continue
		var action: String = entry.get("action", "")
		var args: Dictionary = entry.get("args", {})
		var r: Dictionary = _dispatch_command(state, cmd_sys, action, args)
		fired.append(action)
		results.append(r)
	return { "fired": fired, "results": results }

static func _dispatch_command(state: WorldState, cmd_sys, action: String, args: Dictionary) -> Dictionary:
	match action:
		"set_move_target":
			var pos_arr: Array = args.get("target_pos", [0, 0])
			var mv_target := Vector2i(int(pos_arr[0]), int(pos_arr[1]))
			if cmd_sys.has_method("move_to"):
				return cmd_sys.move_to(state, mv_target)
			state.player_state["move_target"] = mv_target
			return { "ok": true, "msg": "move_target set" }
		"propose_alliance":
			var target_id: int = int(args.get("team_id", -1))
			return cmd_sys.execute_action(state, target_id, "propose_alliance")
		"attack":
			var target_id: int = int(args.get("team_id", -1))
			return cmd_sys.execute_action(state, target_id, "attack")
		"submit_trade_offer":
			var target_id: int = int(args.get("team_id", -1))
			state.player_state["pending_trade_target"] = target_id
			state.player_state["trade_offer"] = {
				"player_gives": args.get("gives", {}),
				"player_wants": args.get("wants", {})
			}
			return cmd_sys.execute_action(state, target_id, "submit_trade_offer")
		"recruit_named":
			var target_id: int = int(args.get("team_id", -1))
			return cmd_sys.execute_action(state, target_id, "recruit_named")
		"build_outpost":
			state.player_state["build_type"] = args.get("type", "civilian")
			return cmd_sys.execute_action(state, -1, "build_outpost")
		"extract_treasury":   # Bug6: tyrant config schedule 用,原缺 dispatch → no-op
			state.player_state["extract_ratio"] = float(args.get("extract_ratio", 0.0))
			return cmd_sys.execute_action(state, -1, "extract_treasury")
		_:
			return { "ok": false, "msg": "未知 action: " + action }
