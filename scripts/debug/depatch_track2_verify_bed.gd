extends SceneTree

# depatch_track2_verify_bed：de-patch軌2驗證——閘1軍備人格分化+閘5屈服人格分化+閘2b陡化行為+無回歸。
# 純觀測：_militancy/tribute_accept唯讀call(同TDD測法,不寫state)；try_proactive用真實task current_task採樣(非call消耗RNG的函式本身)。
# 用法：DT_SEEDS（逗號分隔,default內建8個）DT_MONTHS（default 8）
# ★2026-07-17 fast-follow修：舊版全域cap(2000/400/300)在前1-2 seed就填滿→後續seed對低慎重/稀有樣本零貢獻,已改per-seed cap讓每seed獨立配額,multi-seed才真的增樣本多樣性。

func _initialize() -> void:
	_run(); quit()

var _militancy_samples: Array = []
var _tribute_samples: Array = []
var _diplomacy_task_samples: Array = []   # {慎重, is_diplomacy_task}
var _seed_militancy_n: int = 0
var _seed_tribute_n: int = 0
var _seed_dip_n: int = 0
const PER_SEED_MILITANCY_CAP: int = 200
const PER_SEED_TRIBUTE_CAP: int = 150
const PER_SEED_DIP_CAP: int = 800

func _run() -> void:
	var seeds_raw: String = OS.get_environment("DT_SEEDS") if OS.has_environment("DT_SEEDS") else "1337,2674,4201,5590,7183,8842,9911,3355"
	var months: int = int(OS.get_environment("DT_MONTHS")) if OS.has_environment("DT_MONTHS") else 8
	var seed_list: Array = []
	for tok in seeds_raw.split(","):
		if tok.strip_edges().is_valid_int():
			seed_list.append(int(tok.strip_edges()))
	print("=== depatch_track2_verify_bed: seeds=%s months=%d ===" % [str(seed_list), months])
	var last_state: WorldState = null
	for world_seed in seed_list:
		last_state = _run_one(world_seed, months, world_seed == seed_list[0])
		print("[progress] seed=%d done" % world_seed)
	_report()
	print("=== DONE ===")

func _run_one(world_seed: int, months: int, verbose_first: bool) -> WorldState:
	var total_ticks: int = months * WorldState.TICKS_PER_MONTH
	_seed_militancy_n = 0; _seed_tribute_n = 0; _seed_dip_n = 0
	seed(world_seed)
	SimRunner.force_full_hd = true
	Probe.enabled = true
	if verbose_first:
		Probe.reset()
	var state := WorldState.new()
	var runner := SimRunner.new()
	var config: Dictionary = GameSetup.load_config("res://config/default.json")
	config["seed"] = world_seed
	GameSetup.setup(state, config)
	var coin_start: float = CoinAudit.total(state)
	var no_player := Vector2i(-1, -1)
	var fai := FactionAISystem.new()
	for tick in range(total_ticks):
		runner.advance_tick(state, no_player)
		if tick % 60 == 0:   # 每decision cadence採樣一次(非每tick,省時)
			_sample(state, world_seed, tick, fai)
		if state.teams.is_empty():
			break
	if verbose_first:
		var coin_end: float = CoinAudit.total(state)
		print("[regression-seed%d] CoinAudit start=%.4f end=%.4f delta=%.4f" % [world_seed, coin_start, coin_end, coin_end - coin_start])
		var inv: Array = InvariantAudit.check(state)
		print("[regression-seed%d] InvariantAudit violations=%d %s" % [world_seed, inv.size(), str(inv)])
		print("[regression-seed%d] death: starve_minor=%d starve_anon=%d combat_pop=%d" % [
			world_seed, _c("death.starve_minor"), _c("death.starve_anon"), _c("death.combat_pop")])
		print("[regression-seed%d] diplomacy活性: envoy.dispatched=%d envoy.accept=%d envoy.reject=%d raid.extort=%d raid.combat_at_outpost=%d raid.combat_open_field=%d" % [
			world_seed, _c("envoy.dispatched"), _c("envoy.accept"), _c("envoy.reject"), _c("raid.extort"),
			_c("raid.combat_at_outpost"), _c("raid.combat_open_field")])
	SimRunner.force_full_hd = false
	Probe.enabled = false
	return state

func _sample(state: WorldState, world_seed: int, tick: int, fai: FactionAISystem) -> void:
	for tid in state.teams:
		var t: TeamData = state.teams[tid]
		var leader: PersonData = state.persons.get(t.leader_id)
		if leader == null:
			continue
		var lv: Dictionary = leader.values
		# ①militancy vs 軍備設施
		var tile_id: int = t.tile_pos.x * 1000 + t.tile_pos.y
		var tile: HexTileData = state.world.tiles.get(tile_id)
		if tile != null and tile.outpost_level > 0 and tile.outpost_owner == t.team_id:
			var militancy: float = fai._militancy(t, lv)
			var has_weapon_fac: bool = int(tile.get("weaponsmith_level")) > 0 or int(tile.get("armorsmith_level")) > 0
			if _seed_militancy_n < PER_SEED_MILITANCY_CAP:
				_militancy_samples.append({"militancy": militancy, "has_weapon_fac": has_weapon_fac, "好戰": float(lv.get("好戰", 0.5))})
				_seed_militancy_n += 1
		# ②tribute submission tendency（同TDD測法：合成同戰力對手，唯讀call不寫state）
		if t.current_task == TeamData.TASK_FLEE and _seed_tribute_n < PER_SEED_TRIBUTE_CAP:
			var synthetic_agg := TeamData.new(); synthetic_agg.team_id = -999; synthetic_agg.leader_id = -1
			for i in range(maxi(t.population - 1, 1)):
				synthetic_agg.named_members.append(-1000 - i)   # 同population≈同戰力,非碾壓
			# threat=0.0（同TDD勇者案例，隔離人格軸——原0.3+flee_desperation固定項壓過threshold,100%submit,方法論bug已修）
			var accept: bool = DiplomaticAiSystem.tribute_accept(state, t, synthetic_agg, 0.0)
			_tribute_samples.append({"submit": accept, "義氣": float(lv.get("義氣", 0.5)),
				"求生欲": float(lv.get("求生欲", 0.5)), "fear": leader.fear})
			_seed_tribute_n += 1
		# ③diplomacy task頻率 vs 慎重
		if _seed_dip_n < PER_SEED_DIP_CAP:
			_diplomacy_task_samples.append({"is_dip": t.current_task == TeamData.TASK_DIPLOMACY, "慎重": float(lv.get("慎重", 0.5))})
			_seed_dip_n += 1

func _report() -> void:
	print("[N-militancy] %d 樣本" % _militancy_samples.size())
	_corr_bool(_militancy_samples, "has_weapon_fac", "militancy")
	_corr_bool(_militancy_samples, "has_weapon_fac", "好戰")
	print("[N-tribute] %d FLEE中隊樣本" % _tribute_samples.size())
	_corr_bool(_tribute_samples, "submit", "義氣")
	_corr_bool(_tribute_samples, "submit", "求生欲")
	_corr_bool(_tribute_samples, "submit", "fear")
	print("[N-diplomacy-task] %d 樣本" % _diplomacy_task_samples.size())
	_corr_bool(_diplomacy_task_samples, "is_dip", "慎重")
	# 陡化分佈：慎重分箱(0-0.3/0.3-0.7/0.7-1.0)看is_dip比率是否兩端陡峭中間也陡(非平)
	_bucket_rate(_diplomacy_task_samples, "慎重", "is_dip")
	print("[samples-tribute-raw前15]")
	for s in _tribute_samples.slice(0, 15):
		print("  " + str(s))

func _corr_bool(samples: Array, flag_key: String, trait_key: String) -> void:
	var sum_t: float = 0.0; var n_t: int = 0
	var sum_f: float = 0.0; var n_f: int = 0
	for s in samples:
		if bool(s[flag_key]):
			sum_t += float(s[trait_key]); n_t += 1
		else:
			sum_f += float(s[trait_key]); n_f += 1
	var avg_t: float = sum_t / maxf(float(n_t), 1.0)
	var avg_f: float = sum_f / maxf(float(n_f), 1.0)
	print("[CORR] %s=true(n=%d) 平均%s=%.4f | %s=false(n=%d) 平均%s=%.4f | Δ=%.4f" % [
		flag_key, n_t, trait_key, avg_t, flag_key, n_f, trait_key, avg_f, avg_t - avg_f])

func _bucket_rate(samples: Array, trait_key: String, flag_key: String) -> void:
	var buckets: Dictionary = {"低(0-0.3)": [0, 0], "中(0.3-0.7)": [0, 0], "高(0.7-1.0)": [0, 0]}
	for s in samples:
		var v: float = float(s[trait_key])
		var key: String = "低(0-0.3)" if v < 0.3 else ("高(0.7-1.0)" if v >= 0.7 else "中(0.3-0.7)")
		buckets[key][1] += 1
		if bool(s[flag_key]):
			buckets[key][0] += 1
	print("[BUCKET] %s分箱 vs %s比率: %s" % [trait_key, flag_key, str(buckets)])
	for k in buckets:
		var arr: Array = buckets[k]
		print("  %s: %d/%d = %.2f%%" % [k, arr[0], arr[1], 100.0 * float(arr[0]) / maxf(float(arr[1]), 1.0)])

func _c(key: String) -> int:
	return int(Probe.counts.get(key, 0))
