extends SceneTree

# HorseSlice 源證明（deterministic）：產馬帶生成 → stable 繁育 → auto-withdraw → envoy 配馬 3×速。
# 不靠 emergent AI 建馬廄（時序不定）；直接架設 band tile 上的 stable 跑產出鏈證源活。

func _initialize() -> void:
	_run()
	quit()

func _run() -> void:
	var state := WorldState.new()
	var config: Dictionary = GameSetup.load_config("res://config/warring_states.json")
	config["seed"] = 1337
	GameSetup.setup(state, config)

	# 1) 產馬帶存在？
	var band: Array = []
	for tid in state.world.tiles:
		var t: HexTileData = state.world.tiles[tid]
		if float(t.resource_cap.get("mounts", 0)) > 0.0:
			band.append(t)
	print("[Proof] 產馬帶 tiles=%d（warring_states seed=1337）" % band.size())
	if band.is_empty():
		print("[FAIL] 無產馬帶"); return

	# 2) 挑一格 band tile 架 military outpost + stable + 常駐生產隊 + owner 草料
	var tile: HexTileData = band[0]
	tile.outpost_type = "military"; tile.outpost_level = 2; tile.outpost_owner = 9000
	tile.stable_level = 2
	var owner := TeamData.new()
	owner.team_id = 9000; _seed_pop(owner, 20)
	owner.resources = { "food": 100000.0, "coin": 0.0 }
	owner.tile_pos = tile.tile_pos
	owner.tags = [TeamData.TAG_PRODUCE]   # 常駐生產人力 gate
	state.teams[9000] = owner

	# 3) 跑 30 天 stable → 公庫 mounts
	var os := OutpostSystem.new()
	for _d in range(30):
		os.produce_stable_day(state, tile, 1.0)
	var bred: int = int(tile.public_storage.get("mounts", 0))
	print("[Proof] 30 天繁育 → 公庫 mounts=%d" % bred)

	# 4) auto-withdraw → owner.resources（出征狀態）
	var fai := FactionAISystem.new()
	owner.current_task = TeamData.TASK_ATTACK
	fai._auto_withdraw_mounts(state, owner)
	var got: int = int(owner.resources.get("mounts", 0))
	print("[Proof] owner 出征 auto-withdraw → resources mounts=%d" % got)

	# 5) envoy 配馬 3× 速：小信使隊，無馬 vs 有馬 move speed
	var ms := MovementSystem.new()
	var envoy := TeamData.new()
	envoy.team_id = 9001; _seed_pop(envoy, 3)
	envoy.tile_pos = tile.tile_pos
	envoy.resources = { "mounts": 0 }
	state.teams[9001] = envoy
	var spd_no: float = ms._compute_team_speed(state, envoy)
	envoy.resources["mounts"] = 3   # 全騎乘（pop=3）
	var spd_mt: float = ms._compute_team_speed(state, envoy)
	print("[Proof] envoy 無馬 speed=%.2f → 全騎乘 speed=%.2f（×%.2f）" % [
		spd_no, spd_mt, spd_mt / maxf(spd_no, 0.001)])

	var pass_all: bool = band.size() > 0 and bred >= 1 and got >= 1 and spd_mt > spd_no
	print("[Proof] %s" % ("ALL PASS" if pass_all else "FAIL"))

func _seed_pop(team: TeamData, n: int) -> void:
	AnonTierSystem.add_anon(team, "平民", n)
