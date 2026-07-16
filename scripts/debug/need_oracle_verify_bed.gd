extends SceneTree

# need_oracle_verify_bed：Arc1 need oracle 中性full-HD驗證。
# 測goods兩量方向不死鎖(holding/demand趨勢)+material消耗vs goods產出+crossover(S2-gate)+守恆+死安。
# 純觀測：force_full_hd真實advance_tick跑，has_manufacturing_facility/_facility_food_urgency唯讀call。
# 用法：NO_SEED（default 1337）NO_MONTHS（default 6）

func _initialize() -> void:
	_run(); quit()

var _prev_probe: Dictionary = {}
var _prev_material_total: float = -1.0
var _prev_goods_total: float = -1.0

func _run() -> void:
	var world_seed: int = int(OS.get_environment("NO_SEED")) if OS.has_environment("NO_SEED") else 1337
	var months: int = int(OS.get_environment("NO_MONTHS")) if OS.has_environment("NO_MONTHS") else 6
	var total_ticks: int = months * WorldState.TICKS_PER_MONTH
	print("=== need_oracle_verify_bed: seed=%d months=%d ===" % [world_seed, months])
	seed(world_seed)
	SimRunner.force_full_hd = true
	Probe.enabled = true
	Probe.reset()
	var state := WorldState.new()
	var runner := SimRunner.new()
	var config: Dictionary = GameSetup.load_config("res://config/default.json")
	config["seed"] = world_seed
	GameSetup.setup(state, config)
	var coin_start: float = CoinAudit.total(state)
	var no_player := Vector2i(-1, -1)
	for tick in range(total_ticks):
		runner.advance_tick(state, no_player)
		if (tick + 1) % WorldState.TICKS_PER_MONTH == 0:
			_print_month(state, (tick + 1) / WorldState.TICKS_PER_MONTH)
		if state.teams.is_empty():
			print("[bed] tick=%d 全滅提早結束" % tick)
			break
	var coin_end: float = CoinAudit.total(state)
	print("[CoinAudit] start=%.4f end=%.4f delta=%.4f" % [coin_start, coin_end, coin_end - coin_start])
	var inv: Array = InvariantAudit.check(state)
	print("[InvariantAudit] violations=%d %s" % [inv.size(), str(inv)])
	print("[funnel-final] order_fulfilled=%d arb_hit=%d deal=%d deal_market=%d deal_merchant=%d deal_resident=%d barter_deal=%d meet=%d meet_nodeal=%d" % [
		_c("g1.order_fulfilled"), _c("g1.arb_hit"), _c("trade.deal"), _c("trade.deal_market"), _c("trade.deal_merchant"), _c("trade.deal_resident"),
		_c("trade.barter_deal"), _c("trade.meet"), _c("trade.meet_nodeal")])
	var bail_final: Dictionary = {}
	for k in Probe.counts:
		if String(k).begins_with("trade.market_bail."):
			bail_final[k] = int(Probe.counts[k])
	print("[market_bail-final] %s" % str(bail_final))
	print("[death-final] starve_minor=%d starve_anon=%d combat_pop=%d combat_named=%d defect_leave=%d" % [
		_c("death.starve_minor"), _c("death.starve_anon"), _c("death.combat_pop"), _c("death.combat_named"), _c("death.defect_leave")])
	SimRunner.force_full_hd = false
	Probe.enabled = false
	print("=== DONE ===")

func _print_month(state: WorldState, month: int) -> void:
	var cur: Dictionary = Probe.counts.duplicate(true)
	var delta: Dictionary = {}
	for k in cur:
		if String(k).begins_with("trade.") or String(k).begins_with("g1.") or String(k).begins_with("manufacture."):
			var d: int = int(cur[k]) - int(_prev_probe.get(k, 0))
			if d != 0:
				delta[k] = d
	_prev_probe = cur

	# 世界級material/goods池（team.resources + tile.public_storage），檢死鎖/停產跡象。
	var GOODS_TYPES: Array = ["goods", "weapon_melee_low", "weapon_melee_high", "weapon_ranged_low",
		"weapon_ranged_high", "tools", "arrows", "armor_low", "armor_high"]
	var material_total: float = 0.0
	var goods_total: float = 0.0
	var fai := FactionAISystem.new()
	var teams_total: int = 0
	var has_fac_total: int = 0
	var hungry_farming_n: int = 0
	var hungry_n: int = 0
	for tid in state.teams:
		var t: TeamData = state.teams[tid]
		teams_total += 1
		material_total += float(t.resources.get("material", 0))
		for g in GOODS_TYPES:
			goods_total += float(t.resources.get(g, 0))
		if FactionAISystem.has_manufacturing_facility(state, t):
			has_fac_total += 1
		var tile_id: int = t.tile_pos.x * 1000 + t.tile_pos.y
		var tile: HexTileData = state.world.tiles.get(tile_id)
		if tile != null and tile.outpost_level > 0 and tile.outpost_owner == t.team_id:
			var leader: PersonData = state.persons.get(t.leader_id)
			if leader != null:
				var urg: float = fai._facility_food_urgency(state, t, tile, leader)
				if urg > 0.3:
					hungry_n += 1
					var farm_s: float = fai._facility_score(state, t, tile, leader, "farming")
					var work_s: float = fai._facility_score(state, t, tile, leader, "workshop")
					if farm_s > work_s:
						hungry_farming_n += 1
	for tkey in state.world.tiles:
		var wt: HexTileData = state.world.tiles[tkey]
		for g in GOODS_TYPES:
			goods_total += float(wt.public_storage.get(g, 0))
		material_total += float(wt.public_storage.get("material", 0))
	var mat_delta: float = material_total - _prev_material_total if _prev_material_total >= 0 else 0.0
	var goods_delta: float = goods_total - _prev_goods_total if _prev_goods_total >= 0 else 0.0
	_prev_material_total = material_total
	_prev_goods_total = goods_total
	print("[月%d material/goods] material池=%.2f(Δ%.2f) goods池(含weapon/tools/armor)=%.2f(Δ%.2f) has_facility=%d/%d" % [
		month, material_total, mat_delta, goods_total, goods_delta, has_fac_total, teams_total])
	print("[月%d crossover] hungry(urgency>0.3)隊數=%d farming>workshop隊數=%d(%.1f%%)" % [
		month, hungry_n, hungry_farming_n, 100.0 * float(hungry_farming_n) / maxf(float(hungry_n), 1.0)])
	print("[月%d probe_delta] %s" % [month, str(delta)])

func _c(key: String) -> int:
	return int(Probe.counts.get(key, 0))
