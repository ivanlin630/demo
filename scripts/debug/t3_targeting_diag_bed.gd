extends SceneTree

# ★資訊網 T3 cross-faction relief 目標錯位診斷（systems dispatch 2026-08-05、measure-first、只交真值別下修結論）。
# #7：T1(resident1/fac1)真救活，但 T3(resident2/fac2)仍死——T2(lord2/fac2)relief convoy 目標鎖 T1 非自家 T3。
# puzzle：faction gate(goal_resolver:173)存在→T2 不該選 T1。逐站 tap 定錯位：
#   ①candidate 選誰(diag.dist_heard 聽到的單/diag.dist_pick 最終選)②convoy target(market_pos/terminus)③settle 收貨方(diag.dist_settle)。
# ★純觀測：seed()+inline advance_tick + 3 sim-code tap(Probe-gated 零行為變)；每 tick 只 READ state。
# bed：config/infonet_whole.json persist(#7 同 bed)。

const CONFIG_PATH := "res://config/infonet_whole.json"
const SEED: int = 1337
const MONTHS: int = 2
const OUT_PATH := "res://docs/measurements/2026-08-05-t3-crossfaction-targeting-diagnostic.json"

func _initialize() -> void:
	print("=== T3 cross-faction relief 目標錯位診斷（infonet_whole seed=%d %d月、純觀測）===" % [SEED, MONTHS])
	seed(SEED)
	FactionAISystem._a2b_remote_tribute_payers.clear()
	Probe.reset(); Probe.enabled = true
	var state := WorldState.new()
	var runner := SimRunner.new()
	var config: Dictionary = GameSetup.load_config(CONFIG_PATH)
	config["seed"] = SEED
	GameSetup.setup(state, config)
	var no_player := Vector2i(-1, -1)
	var ticks: int = WorldState.TICKS_PER_MONTH * MONTHS

	# 確認 team id→faction map（explicit mode 應保 id）
	print("--- t0 team→faction map ---")
	for tid in [0,1,2,3]:
		var t: TeamData = state.teams.get(tid)
		if t != null: print("  T%d faction=%d pos=%s food=%.0f pop=%d name-proxy(義氣=%s)" % [
			tid, t.faction_id, str(t.tile_pos), float(t.resources.get("food",0)), t.population,
			str(state.persons.get(t.leader_id).values.get("義氣","?") if state.persons.has(t.leader_id) else "?")])

	var track: Dictionary = {}   # (T1=1,T3=3) → daily food/pos/task/pop + death
	for k in [1, 3]: track[k] = {"daily": [], "death_tick": -1, "last_pop": -1}
	var convoys: Dictionary = {}   # porter → {terminus, market_pos, phases, last_tile, settled_at, gone_tick}
	var seen_prev: Dictionary = {}

	for tick in range(ticks):
		runner.advance_tick(state, no_player)
		if state.encounter_active and state.encounter_tick > 800:
			runner._encounter_system.resolve_encounter_end(state, "draw")
		var ct: int = state.world.current_tick

		# distribute convoy 逐站（terminus vs 實際 tile）
		var seen_now: Dictionary = {}
		for tid in state.teams:
			var t: TeamData = state.teams[tid]
			if t.current_task != TeamData.TASK_CONVOY: continue
			if String(t.task_extra_data.get("convoy_kind","")) != "distribute": continue
			seen_now[tid] = true
			if not convoys.has(tid):
				convoys[tid] = {"porter": tid, "spawn_tick": ct,
					"terminus": int(t.task_extra_data.get("terminus_team_id", -1)),
					"market_pos": str(t.task_extra_data.get("market_pos", Vector2i(-1,-1))),
					"phases": {}, "last_tile": "", "last_phase": "", "gone_tick": -1}
			var C: Dictionary = convoys[tid]
			var ph: String = String(t.task_extra_data.get("convoy_phase","OUTBOUND"))
			C["phases"][ph] = int(C["phases"].get(ph,0)) + 1
			C["last_tile"] = str(t.tile_pos); C["last_phase"] = ph
		for pid in convoys:
			if seen_prev.has(pid) and not seen_now.has(pid) and int(convoys[pid]["gone_tick"]) == -1:
				convoys[pid]["gone_tick"] = ct
		seen_prev = seen_now

		# T1/T3 timeline
		for k in [1, 3]:
			if state.teams.has(k):
				var t: TeamData = state.teams[k]
				track[k]["last_pop"] = t.population
				if ct % WorldState.TICKS_PER_DAY == 0:
					track[k]["daily"].append({"day": ct/WorldState.TICKS_PER_DAY, "pop": t.population,
						"food": snappedf(ResourceSystem.effective_food(state, t), 0.1), "pos": str(t.tile_pos), "task": t.current_task})
			elif int(track[k]["death_tick"]) == -1 and int(track[k]["last_pop"]) >= 0:
				track[k]["death_tick"] = ct

	# ── dump ──
	print("\n───── (a) diag.dist_heard（領主聽到的 food 買單 origin+faction+pos）─────")
	for s in Probe.samples.get("diag.dist_heard", []):
		print("  lord T%d(fac%d) 聽到 rid=T%d(fac%d) gate_same_fac=%s opos=%s" % [
			int(s["lord"]), int(s["lord_fac"]), int(s["rid"]), int(s["rid_fac"]), str(s["gate_same_fac"]), str(s["opos"])])
	print("───── (b) diag.dist_pick（最終選中賑濟對象）─────")
	for s in Probe.samples.get("diag.dist_pick", []):
		print("  lord T%d(fac%d) → 選 rid=T%d(fac%d) mpos=%s oid=%d %s" % [
			int(s["lord"]), int(s["lord_fac"]), int(s["rid"]), int(s["rid_fac"]), str(s["mpos"]), int(s["oid"]),
			("★★跨勢力錯選!" if int(s["rid_fac"]) != int(s["lord_fac"]) else "(同勢力OK)")])
	print("───── (c) diag.dist_settle（convoy settle 真收貨方）─────")
	for s in Probe.samples.get("diag.dist_settle", []):
		print("  porter T%d terminus=T%d → 實際 tile_owner=T%d(fac%d) tile=%s oid=%d dep=%d %s" % [
			int(s["porter"]), int(s["terminus"]), int(s["tile_owner"]), int(s["owner_fac"]), str(s["tile_pos"]), int(s["oid"]), int(s["deposited"]),
			("★★settle 撿錯人(terminus≠tile_owner)!" if int(s["terminus"]) != int(s["tile_owner"]) else "(收貨=terminus OK)")])
	print("───── (d) distribute convoy 逐站（terminus vs market_pos）─────")
	var cids: Array = convoys.keys(); cids.sort()
	for pid in cids:
		var C: Dictionary = convoys[pid]
		print("  porter%d spawn@%d terminus=T%d market_pos=%s phases=%s last=(%s ph%s) gone@%d" % [
			pid, int(C["spawn_tick"]), int(C["terminus"]), str(C["market_pos"]), str(C["phases"]),
			str(C["last_tile"]), str(C["last_phase"]), int(C["gone_tick"])])
	print("───── (e) T1/T3 survival ─────")
	for k in [1, 3]:
		var d: Array = track[k]["daily"]
		var last = d[-1] if d.size() > 0 else {}
		print("  T%d death_tick=%d last=%s (%d 日點)" % [k, int(track[k]["death_tick"]), str(last), d.size()])
	print("  probe: distribute.dispatch=%d deliver=%d food_delivered=%.1f" % [
		int(Probe.counts.get("distribute.dispatch",0)), int(Probe.counts.get("distribute.deliver",0)),
		float(Probe.amounts.get("distribute.food_delivered",0.0))])

	var dump: Dictionary = {
		"diagnostic": "T3 cross-faction relief 目標錯位（measure-first、只交真值）",
		"bed": "t3_targeting_diag_bed (infonet_whole seed 1337 6mo inline、純觀測 3-station tap)",
		"dist_heard": Probe.samples.get("diag.dist_heard", []),
		"dist_pick": Probe.samples.get("diag.dist_pick", []),
		"dist_settle": Probe.samples.get("diag.dist_settle", []),
		"convoys": convoys, "t1_t3": track,
		"probe": {"distribute.dispatch": int(Probe.counts.get("distribute.dispatch",0)),
			"distribute.deliver": int(Probe.counts.get("distribute.deliver",0)),
			"distribute.food_delivered": float(Probe.amounts.get("distribute.food_delivered",0.0))},
	}
	var f := FileAccess.open(OUT_PATH, FileAccess.WRITE)
	if f != null:
		f.store_string(JSON.stringify(dump, "  ")); f.close()
		print("\n[dump] → %s" % OUT_PATH)
	print("=== DONE ===")
	quit()
