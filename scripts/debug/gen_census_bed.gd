extends SceneTree

# default 組成普查（管線:default 組成/健康 measure）。gen-time 零 sim,跨 seed 統計:
# 獨立隊數/archetype 分佈/野心直方/FORCE+野心≥0.5 狼候選數——default vs warring 對照。
# 用法: GC_CONFIG=default|warring_states GC_SEEDS=10

func _initialize() -> void:
	_run(); quit()

func _run() -> void:
	var cfg_name: String = OS.get_environment("GC_CONFIG") if OS.has_environment("GC_CONFIG") else "default"
	var n_seeds: int = int(OS.get_environment("GC_SEEDS")) if OS.has_environment("GC_SEEDS") else 10
	print("=== gen_census: config=%s seeds=%d ===" % [cfg_name, n_seeds])
	var tot_teams: int = 0
	var tot_indep: int = 0
	var arche: Dictionary = {"武力": 0, "商業": 0, "定居": 0}
	var indep_arche: Dictionary = {"武力": 0, "商業": 0, "定居": 0}
	var wolf_cands: int = 0          # 獨立+FORCE+野心≥0.5（狼候選）
	var amb_hist: Dictionary = {}    # 野心 0.1 桶（全 leader）
	for s in range(n_seeds):
		var world_seed: int = 1000 + s * 337
		seed(world_seed)
		var state := WorldState.new()
		var config: Dictionary = GameSetup.load_config("res://config/%s.json" % cfg_name)
		if config.is_empty():
			print("[FAIL] config"); return
		config["seed"] = world_seed
		GameSetup.setup(state, config)
		for tid in state.teams:
			var t: TeamData = state.teams[tid]
			if t.parent_team_id != -1 or t.leader_id == -1: continue
			var ldr: PersonData = state.persons.get(t.leader_id)
			if ldr == null: continue
			tot_teams += 1
			var a: String = AmbitionLadder.derive_archetype(ldr)
			arche[a] = int(arche.get(a, 0)) + 1
			var amb: float = float(ldr.values.get("野心", 0.5))
			var bucket: String = "%.1f" % (floorf(amb * 10.0) / 10.0)
			amb_hist[bucket] = int(amb_hist.get(bucket, 0)) + 1
			if t.faction_id == -1:
				tot_indep += 1
				indep_arche[a] = int(indep_arche.get(a, 0)) + 1
				if a == AmbitionLadder.ARCHETYPE_FORCE and amb >= 0.5:
					wolf_cands += 1
	print("[census] leader 隊總=%d（均 %.1f/seed）獨立=%d（均 %.1f/seed）" % [
		tot_teams, float(tot_teams) / n_seeds, tot_indep, float(tot_indep) / n_seeds])
	print("[census] 全 leader archetype: 武力=%d(%.0f%%) 商業=%d(%.0f%%) 定居=%d(%.0f%%)" % [
		arche["武力"], 100.0 * arche["武力"] / maxf(tot_teams, 1),
		arche["商業"], 100.0 * arche["商業"] / maxf(tot_teams, 1),
		arche["定居"], 100.0 * arche["定居"] / maxf(tot_teams, 1)])
	print("[census] 獨立隊 archetype: 武力=%d 商業=%d 定居=%d" % [
		indep_arche["武力"], indep_arche["商業"], indep_arche["定居"]])
	print("[census] ★狼候選（獨立+武力+野心≥0.5）= %d（均 %.2f/seed）" % [
		wolf_cands, float(wolf_cands) / n_seeds])
	var keys: Array = amb_hist.keys(); keys.sort()
	var hs: String = ""
	for k in keys: hs += "%s:%d " % [k, amb_hist[k]]
	print("[census] 野心直方: %s" % hs)
	print("=== gen_census DONE ===")
