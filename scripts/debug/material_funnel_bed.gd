extends SceneTree
# material 漏斗床（systems 派 2026-08-26，slice=material-funnel-unlock）
# 問題：森林 material 初始80-220/再生12/日，隊手上 avail 卻常 0-20。
# 三選一：採不到／採到了被消耗／採到了但沒進公庫。
# 判準：每段有分母；沒現成 tap 的段回報缺口，不用鄰近數字推。
# env：LW_CONFIG(peaceful_economy) / PERF_SEED(1337) / ADHOC_DAYS(30) / PERF_OUT

func _initialize() -> void:
	_run(); quit()

func _c(k: String) -> int:
	return int(Probe.counts.get(k, 0))

func _a(k: String) -> float:
	return float(Probe.amounts.get(k, 0.0))

func _env(key: String, dflt: String) -> String:
	var v: String = OS.get_environment(key)
	return v if v != "" else dflt

func _run() -> void:
	var cfg: String = _env("LW_CONFIG", "peaceful_economy")
	var days: int = int(_env("ADHOC_DAYS", "30"))
	var sd: int = int(_env("PERF_SEED", "1337"))
	var out_path: String = _env("PERF_OUT", "")
	print("=== material 漏斗：config=%s days=%d seed=%d ===" % [cfg, days, sd])
	seed(sd)
	Probe.enabled = true
	Probe.reset()
	var state := WorldState.new()
	var runner := SimRunner.new()
	var config: Dictionary = GameSetup.load_config("res://config/%s.json" % cfg)
	if config.is_empty():
		print("[FAIL] config"); return
	config["seed"] = sd
	GameSetup.setup(state, config)
	var no_player := Vector2i(-1, -1)
	for _t in range(days * WorldState.TICKS_PER_DAY):
		runner.advance_tick(state, no_player)
		if state.encounter_active and state.encounter_tick > 800:
			runner._encounter_system.resolve_encounter_end(state, "draw")
		if state.teams.is_empty(): break

	var lines: Array = []
	lines.append("[%s day %d seed %d] teams=%d" % [cfg, days, sd, state.teams.size()])

	lines.append("--- ①有沒有人去採（★不是 material 專屬——collect.gather_ran 是「有據點隊該 cadence 整批採集路徑跑了」，material 是同一迴圈裡的其中一種 res，file:line=resource_system.gd:83+299）---")
	lines.append("  collect.gather_ran(有據點隊跑gather的次數，非material專屬) = %d" % _c("collect.gather_ran"))
	lines.append("  collect.no_outpost_no_camp_zero_food(無據點無camp，不會採material) = %d" % _c("collect.no_outpost_no_camp_zero_food"))
	lines.append("  ★缺口：沒有 material 專屬的『嘗試採集』計數——gather_ran 是全資源共用閘，不能單獨拆出 material 那一支跑了幾次")

	lines.append("--- ②採了多少（★缺口：resource_system.gd:306-346 的 gain 從未被 tap，carry_space 硬限(:341-344)也沒有 tap）---")
	lines.append("  ★★這段完全量不到：沒有 material gain 的 add_amount、也沒有 carry_space 擋下次數的 bump")
	lines.append("  ★鄰近可用信號(不是這段本身，不當替代)：manufacture.noop_no_material(下面④) 是【製造端缺料】不是【採集端沒採到】，兩者不可互推")

	lines.append("--- ③採到的進了哪裡（private vs public，讀最終快照，非tap，不受 Probe 影響）---")
	var priv_total: float = 0.0
	var pub_total: float = 0.0
	var priv_nonzero_teams: int = 0
	var priv_teams: int = 0
	for tid in state.teams:
		var team: TeamData = state.teams[tid]
		if team.parent_team_id != -1:
			continue   # 子隊材料是母隊資源的暫時分配，只算母隊層級，避免重複計
		priv_teams += 1
		var m: float = float(team.resources.get("material", 0))
		priv_total += m
		if m > 0.0: priv_nonzero_teams += 1
	var pub_tiles: int = 0
	var pub_nonzero_tiles: int = 0
	for tid2 in state.world.tiles:
		var tile: HexTileData = state.world.tiles[tid2]
		if tile.outpost_level <= 0:
			continue
		pub_tiles += 1
		var pm: float = float(tile.public_storage.get("material", 0))
		pub_total += pm
		if pm > 0.0: pub_nonzero_tiles += 1
	lines.append("  private(team.resources.material，母隊層級) 加總 = %.1f，跨 %d 隊（%d 隊非零）" % [priv_total, priv_teams, priv_nonzero_teams])
	lines.append("  public(有outpost tile.public_storage.material) 加總 = %.1f，跨 %d 個outpost（%d 個非零）" % [pub_total, pub_tiles, pub_nonzero_tiles])
	if priv_total + pub_total > 0.0:
		lines.append("  ⇒ private 佔比 = %.1f%%（%.1f / %.1f）" % [100.0 * priv_total / (priv_total + pub_total), priv_total, priv_total + pub_total])
	lines.append("  ★tile 側池存量(world_generator 初始80-220+regen)不在這欄——這欄只算『已經被採集離開tile的material』落在私產還是公庫")

	lines.append("--- ★tile 側原始池（世界層還剩多少沒被採走，佐證『世界不缺』那句）---")
	var tile_pool_total: float = 0.0
	var tile_pool_forest_total: float = 0.0
	var forest_tiles: int = 0
	for tid3 in state.world.tiles:
		var tile2: HexTileData = state.world.tiles[tid3]
		var tp: float = float(tile2.resources.get("material", 0))
		tile_pool_total += tp
		if tile2.terrain == "forest":
			forest_tiles += 1
			tile_pool_forest_total += tp
	lines.append("  全圖 tile.resources.material 加總 = %.1f（%d 個forest tile 佔 %.1f）" % [tile_pool_total, forest_tiles, tile_pool_forest_total])

	lines.append("--- ④進來的又出去多少（outflow，★逐個標明有沒有現成tap）---")
	lines.append("  manufacture.input_consumed(add_amount，★跨所有原料混算，非material單獨) = %.1f" % _a("manufacture.input_consumed"))
	lines.append("    ★缺口：這個是 ore_iron/ore_steel/gem/horses/material/tools 全部混一個總量，量不出 material 單獨吃掉多少")
	lines.append("  manufacture.noop_no_material(想生產但material不夠、次數) = %d" % _c("manufacture.noop_no_material"))
	lines.append("    ★這是需求側信號（有設施+人力但material不足），不是流出量")
	lines.append("  manufacture.fired(製造真的RUN的次數，母體) = %d" % _c("manufacture.fired"))
	lines.append("  order.placed.sell_material(貼material賣單次數，非數量) = %d" % _c("order.placed.sell_material"))
	lines.append("  order.placed.buy_material(貼material買單次數，非數量) = %d" % _c("order.placed.buy_material"))
	lines.append("    ★這是【訂單次數】不是【成交量】，order.filled 沒有拆到per-resource，量不出material真的透過交易流出/流入多少")
	lines.append("  ★★兩個完全沒 tap 的流出點（讀code確認存在，file:line坐實機制存在，不宣稱佔比）：")
	lines.append("      resource_system.gd:353 _apply_normal_tax — private→public 稅收轉移(material在NORMAL_TAX_RES內)，零tap")
	lines.append("      faction_ai_system.gd:4226 _fund_subteam_from_vault — 建造子隊出發時從private+public扣material付cost，零tap")

	var text: String = "\n".join(PackedStringArray(lines))
	print("\n" + text)
	if out_path != "":
		var f := FileAccess.open(out_path, FileAccess.WRITE)
		if f != null:
			f.store_string(text + "\n"); f.close()
	print("=== material 漏斗 DONE ===")
