extends SceneTree

# ★★★⑩ 拆閥之後的世界讀數（驗收 2/3/4/5b/7a）——★一跑收齊，避免同一件事跑五次。
#
# ★驗收 5b 是 systems 指定【先做】的那格，而它的價值在於：
#   它把「我的推導對不對」變成【一個直接可量的斷言】，而不是只靠 fp 有沒有變去反推。
#   ★★推導是：`stock >= 0` ⇒ `shortage <= 1.0` ⇒ 上臂永不觸發。
#   ⇒ ★★★若哪天 `ResourceBank.add()` / `set_amt()`（★兩者【沒有下限保護】）收到負量，
#     `stock` 會變負 ⇒ 前提破 ⇒ 而【那時候上臂桶會非 0】—— 兩條線互相印證。
#
# 用法：DECLAMP_DAYS（default 30）／DECLAMP_SEED（default 1337）／DECLAMP_CONFIG（default warring_states）

var _min_res: float = 1e18
var _min_res_where: String = "(none)"
var _neg_hits: int = 0
var _min_pub: float = 1e18
var _min_pub_where: String = "(none)"

func _initialize() -> void:
	_run(); quit()

func _sweep(state: WorldState) -> void:
	# gate-ok: 純觀測（床側稽核，不進任何決策）
	for tid in state.teams:
		var t: TeamData = state.teams[tid]
		for k in t.resources.keys():
			var v: float = float(t.resources[k])
			if v < _min_res:
				_min_res = v; _min_res_where = "team%d.%s" % [int(tid), String(k)]
			if v < 0.0:
				_neg_hits += 1
	for tile_id in state.world.tiles:
		var tile: HexTileData = state.world.tiles[tile_id]
		for k in tile.public_storage.keys():
			var v2: float = float(tile.public_storage[k])
			if v2 < _min_pub:
				_min_pub = v2; _min_pub_where = "tile%d.%s" % [int(tile_id), String(k)]
			if v2 < 0.0:
				_neg_hits += 1

func _run() -> void:
	var days: int = int(OS.get_environment("DECLAMP_DAYS")) if OS.has_environment("DECLAMP_DAYS") else 30
	var world_seed: int = int(OS.get_environment("DECLAMP_SEED")) if OS.has_environment("DECLAMP_SEED") else 1337
	var cfg: String = OS.get_environment("DECLAMP_CONFIG") if OS.has_environment("DECLAMP_CONFIG") else "warring_states"
	print("=== declamp_effects_bed: config=%s seed=%d days=%d ===" % [cfg, world_seed, days])
	seed(world_seed)
	var config: Dictionary = GameSetup.load_config("res://config/%s.json" % cfg)
	config["seed"] = world_seed
	var state: WorldState = MeasureBedHelper.arm_and_setup(config)
	var runner := SimRunner.new()
	for d in range(days):
		for _t in range(WorldState.TICKS_PER_DAY):
			runner.advance_tick(state, Vector2i(-1, -1))
		_sweep(state)
		if state.teams.is_empty():
			break

	# ── 驗收 5b：★資源不得為負（★它是「上臂死碼」那個推導的【前提】）──
	print("")
	print("═══ ★驗收 5b：資源最小值（★這是【上臂永不觸發】那個推導的前提）═══")
	print("  team.resources 最小 = %.4f  @ %s" % [_min_res, _min_res_where])
	print("  tile.public_storage 最小 = %.4f  @ %s" % [_min_pub, _min_pub_where])
	print("  ★負值出現次數 = %d" % _neg_hits)
	print("     ★★`ResourceBank.remove()` 有 clampf 保底，而 `add()`／`set_amt()`【沒有下限保護】")
	print("     ⇒ ★★★負值非 0 ⇒【`shortage <= 1.0` 的前提破了】⇒ 上臂桶【應該】跟著非 0")
	print("        —— 而【兩條線要一起看】：只有一條動 ⇒ 是儀器問題不是世界問題。")

	# ── 驗收 3：分帶分布（★deep_glut 是 regime change 的入口）──
	var dg: int = int(Probe.counts.get("valuation.band_deep_glut", 0))
	var g: int = int(Probe.counts.get("valuation.band_glut", 0))
	var oh: int = int(Probe.counts.get("valuation.band_over_hi", 0))
	var nm: int = int(Probe.counts.get("valuation.band_normal", 0))
	var tot: int = dg + g + oh + nm
	print("")
	print("═══ ★★驗收 3：raw shortage 分帶（母體 %d）═══" % tot)
	if tot == 0:
		print("  ★★★母體 0 ⇒【儀器沒開或 local_value 沒被呼叫】—— 不是「沒有過剩」")
	else:
		print("  deep_glut(stock>2×target) = %d (%.1f%%) ｜ glut = %d (%.1f%%) ｜ normal = %d (%.1f%%) ｜ over_hi = %d"
			% [dg, 100.0 * dg / tot, g, 100.0 * g / tot, nm, 100.0 * nm / tot, oh])
		print("     ★over_hi 應為 0（上臂死碼）；★★deep_glut 佔比【高】⇒ 那些貨拆後價格直接 0")
		print("     ⇒ ★★★若 food 大量落在 deep_glut ⇒【農隊賣糧收入歸零】＝ regime change 不是價格波動")

	# ── 驗收 2/4：價格分布 ──
	var priced: int = int(Probe.counts.get("valuation.priced", 0))
	var zero: int = int(Probe.counts.get("valuation.price_zero", 0))
	var psum: float = Probe.amount("valuation.price_sum")
	print("")
	print("═══ ★驗收 2/4：價格分布 ═══")
	print("  估價次數 = %d ｜ 價格為 0 的次數 = %d (%.1f%%) ｜ 平均價 = %.3f"
		% [priced, zero, (100.0 * zero / maxf(float(priced), 1.0)), psum / maxf(float(priced), 1.0)])
	var zres: Array = []
	for k in Probe.counts.keys():
		var ks: String = String(k)
		if ks.begins_with("valuation.price_zero."):
			zres.append("%s=%d" % [ks.substr(21), int(Probe.counts[k])])
	zres.sort()
	print("  ★價格為 0 的【是哪些 res】：%s" % ("｜".join(PackedStringArray(zres)) if not zres.is_empty() else "（無）"))
	print("     ★★這一欄比總數重要：★★★`food` 出現在這裡才是 regime change 的訊號。")

	Probe.enabled = false
	print("")
	print("=== declamp_effects_bed DONE ===")
