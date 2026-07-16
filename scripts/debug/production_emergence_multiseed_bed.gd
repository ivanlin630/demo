extends SceneTree

# production_emergence_multiseed_bed：生產框架fast-follow——multi-seed聚合驗人格分化emergence。
# 貪婪/野心→工坊(manufacturing_level>0)、好戰→軍事outpost_type、慎重→農/farming_level>0保守。
# 純觀測不寫state。用法：PEM_SEEDS（逗號分隔,default內建8個）PEM_MONTHS（default 4）

func _initialize() -> void:
	_run(); quit()

var _samples: Array = []   # 每settled隊一筆：{貪婪,野心,好戰,慎重,manu,farm,military}

func _run() -> void:
	var seeds_raw: String = OS.get_environment("PEM_SEEDS") if OS.has_environment("PEM_SEEDS") else "1337,2674,4201,5590,7183,8842,9315,10077"
	var months: int = int(OS.get_environment("PEM_MONTHS")) if OS.has_environment("PEM_MONTHS") else 4
	var seed_list: Array = []
	for tok in seeds_raw.split(","):
		if tok.strip_edges().is_valid_int():
			seed_list.append(int(tok.strip_edges()))
	print("=== production_emergence_multiseed_bed: seeds=%s months=%d ===" % [str(seed_list), months])
	for world_seed in seed_list:
		_run_one(world_seed, months)
		print("[progress] seed=%d done, 累計樣本=%d" % [world_seed, _samples.size()])
	_report()
	print("=== DONE ===")

func _run_one(world_seed: int, months: int) -> void:
	var total_ticks: int = months * WorldState.TICKS_PER_MONTH
	seed(world_seed)
	SimRunner.force_full_hd = true
	Probe.enabled = false
	var state := WorldState.new()
	var runner := SimRunner.new()
	var config: Dictionary = GameSetup.load_config("res://config/default.json")
	config["seed"] = world_seed
	GameSetup.setup(state, config)
	var no_player := Vector2i(-1, -1)
	for tick in range(total_ticks):
		runner.advance_tick(state, no_player)
		if state.teams.is_empty():
			break
	for tid in state.teams:
		var t: TeamData = state.teams[tid]
		var tile_id: int = t.tile_pos.x * 1000 + t.tile_pos.y
		var tile: HexTileData = state.world.tiles.get(tile_id)
		if tile == null or tile.outpost_level <= 0 or tile.outpost_owner != t.team_id:
			continue   # 只算settled自家outpost隊（有意義的建設revealed preference樣本）
		var leader: PersonData = state.persons.get(t.leader_id)
		if leader == null:
			continue
		_samples.append({
			"seed": world_seed, "team": tid,
			"貪婪": float(leader.values.get("貪婪", 0.5)),
			"野心": float(leader.values.get("野心", 0.5)),
			"好戰": float(leader.values.get("好戰", 0.5)),
			"慎重": float(leader.values.get("慎重", 0.5)),
			"manu": tile.manufacturing_level > 0,
			"farm": tile.farming_level > 0,
			"military": tile.outpost_type == "military",
		})
	SimRunner.force_full_hd = false

func _report() -> void:
	print("[N] 總settled隊樣本數=%d（跨%d seeds）" % [_samples.size(), _samples.size()])
	_corr("manu", "貪婪"); _corr("manu", "野心")
	_corr("military", "好戰"); _corr("military", "野心")
	_corr("farm", "慎重"); _corr("farm", "貪婪")
	print("[samples-raw前20]")
	for s in _samples.slice(0, 20):
		print("  " + str(s))

# 群組均值對照：flag=true組 vs flag=false組 該trait均值，差異=emergence訊號強度
func _corr(flag_key: String, trait_key: String) -> void:
	var sum_true: float = 0.0; var n_true: int = 0
	var sum_false: float = 0.0; var n_false: int = 0
	for s in _samples:
		if bool(s[flag_key]):
			sum_true += float(s[trait_key]); n_true += 1
		else:
			sum_false += float(s[trait_key]); n_false += 1
	var avg_true: float = sum_true / maxf(float(n_true), 1.0)
	var avg_false: float = sum_false / maxf(float(n_false), 1.0)
	print("[CORR] %s=true(n=%d) 平均%s=%.4f | %s=false(n=%d) 平均%s=%.4f | Δ=%.4f" % [
		flag_key, n_true, trait_key, avg_true, flag_key, n_false, trait_key, avg_false, avg_true - avg_false])
