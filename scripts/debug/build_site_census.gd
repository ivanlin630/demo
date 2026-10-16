extends SceneTree
# @bed-kind: diagnostic
# slice: 結構輪兩個探針 §驗收 V8／§交件信要列（spec 2026-10-16-structure-round-probes-build-and-subteam-arrival-HOW）
# ★派子隊這條路活了沒有（量測，不是床）：電池世界 30 天，按目標地形拆 attempt／派出／site_barren／開工／gather_ticks／gather_abort／完工，
#   ＋六道閘、選址候選數、site.filtered_barren、infra.stop.3_loc_empty、subteam.arrival.*、紮根帶料比例、gather_term 平均。
# ★修前樹也跑得動：只讀 Probe 計數（不呼新 API）；修前沒有的鍵印 0，地形另從 attempt 樣本（target）回推。
# env：LW_CONFIG（預設 peaceful_economy）／PERF_SEED（1337）／ADHOC_DAYS（30）

func _initialize() -> void:
	_run()
	quit()

func _env(k: String, d: String) -> String:
	var v: String = OS.get_environment(k)
	return v if v != "" else d

func _c(k: String) -> int:
	return int(Probe.counts.get(k, 0))

func _run() -> void:
	var cfg: String = _env("LW_CONFIG", "peaceful_economy")
	var days: int = int(_env("ADHOC_DAYS", "30"))
	var sd: int = int(_env("PERF_SEED", "1337"))
	print("=== build_site_census：config=%s days=%d seed=%d ===" % [cfg, days, sd])
	seed(sd)
	Probe.enabled = true
	Probe.reset()
	FactionAISystem._a2b_remote_tribute_payers.clear()
	var state := WorldState.new()
	var runner := SimRunner.new()
	var config: Dictionary = GameSetup.load_config("res://config/%s.json" % cfg)
	config["seed"] = sd
	GameSetup.setup(state, config)
	var terr_of: Dictionary = {}
	for tid in state.world.tiles:
		var t: HexTileData = state.world.tiles[tid]
		terr_of[t.tile_pos] = t.terrain
	for _t in range(days * WorldState.TICKS_PER_DAY):
		runner.advance_tick(state, Vector2i(-1, -1))
		if state.encounter_active and state.encounter_tick > 800:
			runner._encounter_system.resolve_encounter_end(state, "draw")
		if state.teams.is_empty():
			break
	print("V8|teams=%d tick=%d" % [state.teams.size(), state.world.current_tick])
	print("V8|--- 六道閘（★對帳：閘＋派出 == attempt）---")
	var gates: Array = ["funnel.build_gate.busy_subteam", "funnel.build_gate.tile_occupied", "funnel.build_gate.cost",
		"funnel.build_gate.site_barren", "funnel.build_gate.no_advisor", "funnel.build_gate.pop", "funnel.build_gate.food_bridge",
		"funnel.build_gate.subteam_dispatch", "funnel.build_gate.dispatched"]
	var gsum: int = 0
	for g in gates:
		gsum += _c(g)
		print("V8|  %-36s = %d" % [g, _c(g)])
	print("V8|  %-36s = %d（閘＋派出合計 %d）" % ["dispatch_builder.attempt", _c("dispatch_builder.attempt"), gsum])
	print("V8|  funnel.build_gate.cost 鍵存在=%s" % str(Probe.counts.has("funnel.build_gate.cost")))
	for k in Probe.counts.keys():
		if String(k).begins_with("funnel.build_gate.cost."):
			print("V8|    %s = %d" % [String(k), _c(String(k))])
	print("V8|--- 按目標地形（attempt｜派出｜site_barren｜開工｜gather_ticks｜gather_abort｜完工｜選址選中｜gather_term 平均）---")
	for terr in ["plains", "forest", "mountain"]:
		var best_n: int = _c("site.best.terrain." + terr)
		var gt_sum: float = Probe.amount("site.best_gather_term.terrain." + terr)
		print("V8|  %-8s｜attempt %d｜派出 %d｜site_barren %d｜開工 %d｜gather_ticks %d｜gather_abort %d｜完工 %d｜選中 %d｜gather_term 平均 %s" % [terr,
			_c("dispatch_builder.attempt.terrain." + terr), _c("funnel.build_gate.dispatched.terrain." + terr),
			_c("funnel.build_gate.site_barren." + terr), _c("construct.start_build.terrain." + terr),
			_c("construct.gather_ticks.terrain." + terr), _c("construct.gather_abort.terrain." + terr),
			_c("construct.complete_build.terrain." + terr), best_n, ("%.2f" % (gt_sum / float(best_n))) if best_n > 0 else "—"])
	# 地形回推（修前樹也有）：attempt 樣本的 target
	var by_t: Dictionary = {}
	var smp: Array = Probe.samples.get("dispatch_builder.attempt", [])
	for s in smp:
		var tgt = (s as Dictionary).get("target", null)
		var tr: String = String(terr_of.get(tgt, "?")) if tgt is Vector2i else "?"
		by_t[tr] = int(by_t.get(tr, 0)) + 1
	print("V8|  attempt 樣本按 target 地形回推（樣本 %d 筆，cap 100）：%s" % [smp.size(), str(by_t)])
	print("V8|--- 選址 ---")
	print("V8|  site.candidates_scored=%d｜site.candidates_kept 累計=%.0f｜site.filtered_barren=%d｜infra.stop.3_loc_empty=%d｜infra.stop.3_reached_dispatch_builder=%d" % [
		_c("site.candidates_scored"), Probe.amount("site.candidates_kept"), _c("site.filtered_barren"), _c("infra.stop.3_loc_empty"),
		_c("infra.stop.3_reached_dispatch_builder")])
	print("V8|--- 採段與完工 ---")
	print("V8|  construct.start=%d｜construct.gather_ticks=%d｜gather_done=%d｜gather_abort=%d｜gathered 累計=%.1f｜timeout_cancel=%d｜complete_build=%d｜outpost.l0_to_l1=%d｜settlement.l0_to_l1_start=%d" % [
		_c("construct.start"), _c("construct.gather_ticks"), _c("construct.gather_done"), _c("construct.gather_abort"), Probe.amount("construct.gathered"),
		_c("construct.timeout_cancel"), _c("construct.complete_build"), _c("outpost.l0_to_l1"), _c("settlement.l0_to_l1_start")])
	print("V8|--- 開工帶料（入口×帶料 >0／=0）---")
	for e in ["settle", "subteam", "main"]:
		print("V8|  %-8s 帶料>0 %d｜帶料=0 %d" % [e, _c("construct.start_build.%s.carried_pos" % e), _c("construct.start_build.%s.carried_zero" % e)])
	print("V8|--- subteam.arrival.* ---")
	var ks: Array = []
	for k in Probe.counts.keys():
		if String(k).begins_with("subteam.arrival."):
			ks.append(String(k))
	ks.sort()
	for k in ks:
		print("V8|  %s = %d" % [k, _c(k)])
	if ks.is_empty():
		print("V8|  （無 subteam.arrival.* 鍵）")
	# ★§三之三：新點缺料進同一本需求帳（隊日數＝每隊每日一次的 tap；修前樹沒有這些鍵 ⇒ 逐鍵印、缺鍵印 0）
	print("V8|--- §三之三 新點需求 ---")
	for k in ["need.new_outpost.walk", "need.new_outpost.walk.main", "need.new_outpost.walk.sub",
			"need.new_outpost.gather", "need.new_outpost.gather.main", "need.new_outpost.gather.sub", "need.new_outpost.gather.not_ct",
			"g1.shortage_buy.new_outpost", "g1.shortage_buy.new_outpost.main", "g1.shortage_buy.new_outpost.sub",
			"order.new_outpost.filled", "order.new_outpost.abandoned", "construct.absorb", "construct.gather_done", "construct.gather_abort"]:
		print("V8|  %s = %d" % [k, _c(k)])
	print("V8|  construct.absorbed 累計=%.1f" % Probe.amount("construct.absorbed"))
	var _fd: int = _c("order.new_outpost.filled")
	var _ab: int = _c("order.new_outpost.abandoned")
	print("V8|  新點料單成交比例 filled/(filled+abandoned)=%s｜採段轉築段 gather_done/(done+abort)=%s（★全工地，不只新點需求那幾隊）" % [
		("%.2f" % (float(_fd) / float(_fd + _ab))) if _fd + _ab > 0 else "—",
		("%.2f" % (float(_c("construct.gather_done")) / float(_c("construct.gather_done") + _c("construct.gather_abort")))) if _c("construct.gather_done") + _c("construct.gather_abort") > 0 else "—"])
	print("=== build_site_census DONE ===")
