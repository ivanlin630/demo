extends SceneTree

# [measurer持久fixture 2026-08-11] 統一派遣模型(feat/unified-dispatch 285bca8f)下游re-measure。
# ticket:docs/superpowers/handbacks/2026-08-11-systems-to-measurer-unified-dispatch-remeasure.md
# ★★★4×over-claim教訓命門:禁預設『修好anon就unblock relief/care/builder』,量真數字非硬套payoff。
# 同一bed跑main(before)+worktree unified-dispatch(after)兩次,seed8181 dispersed,45天,直接比對。
# 量5件:①anon池穩否②組成分化(named runner統領最低)③機械升格=0確認④下游真unblock否(care/facility)
# ⑤團數/O(N²)幽靈團貢獻。純觀測,零production tap,既有Probe key+state直讀。

const DISP_CONFIG := "res://config/infonet_scale_econ_dispersed.json"
const SEED: int = 8181
const DAYS: int = 45
const LORD: int = 0

func _initialize() -> void:
	print("=== 統一派遣re-measure(seed=%d %d天) ===" % [SEED, DAYS])
	seed(SEED)
	FactionAISystem._a2b_remote_tribute_payers.clear()
	Probe.reset(); Probe.enabled = true
	var state := WorldState.new()
	var runner := SimRunner.new()
	var config: Dictionary = GameSetup.load_config(DISP_CONFIG)
	config["seed"] = SEED
	GameSetup.setup(state, config)
	var no_player := Vector2i(-1, -1)
	var ticks: int = WorldState.TICKS_PER_DAY * DAYS

	state.specimen_team_ids = [0, 1, 2, 3]
	SpecimenTracer.reset(); SpecimenTracer.enabled = true

	var watch_keys: Array = ["scout.dispatched", "care.scout_dispatched", "contact.react_rescue",
		"help.letter_dispatched", "manufacture.fired", "manufacture.noop_no_facility",
		"construct.complete_upgrade_facility"]
	var prev_counts: Dictionary = {}
	for k in watch_keys: prev_counts[k] = 0

	var daily_log: Array = []
	var seen_tids: Dictionary = {}
	for tid in state.teams: seen_tids[tid] = true
	var mechanical_promo_hits: Array = []   # 機械升格偵測:新team_id born leaderless且非named-led

	print("\nday | anon池(T0) | named(T0) | team數 | scout累計 | care累計 | rescue累計 | manu.fired累計 | noop_no_facility累計")
	print("----|-----------|-----------|--------|----------|----------|-----------|----------------|----------------------")

	for tick in range(ticks):
		runner.advance_tick(state, no_player)
		if state.encounter_active and state.encounter_tick > 800:
			runner._encounter_system.resolve_encounter_end(state, "draw")
		if state.world.current_tick % WorldState.TICKS_PER_DAY == 0:
			var day: int = state.world.current_tick / WorldState.TICKS_PER_DAY
			var new_today: Array = []
			for tid in state.teams:
				if not seen_tids.has(tid):
					seen_tids[tid] = true
					new_today.append(tid)
					# ★機械升格偵測:新born team若leader_id==-1(leaderless誕生)=舊病徵;
					# 統一派遣模型下scout/care/rescue子隊born即有named leader,不該再出現這個特徵。
					var nt: TeamData = state.teams[tid]
					if nt.leader_id == -1:
						mechanical_promo_hits.append({"day": day, "tid": tid, "tile": nt.tile_pos})

			var counts_now: Dictionary = {}
			for k in watch_keys: counts_now[k] = int(Probe.counts.get(k, 0))

			var entry: Dictionary = {"day": day, "anon_t0": -1, "named_t0": -1, "team_count": state.teams.size(),
				"new_teams": new_today, "counts": counts_now}
			if state.teams.has(LORD):
				var t: TeamData = state.teams[LORD]
				entry["anon_t0"] = AnonTierSystem.total_pop(t)
				entry["named_t0"] = t.named_members.size()
				entry["pop_t0"] = t.population
				# ★組成分化:記名roster的統領分布(驗證派走的是最低統領那個,非隨機/非最強)
				var cmds: Array = []
				for nid in t.named_members:
					var p = state.persons.get(nid)
					if p != null: cmds.append(float(p.skills.get("統領", 0.0)))
				entry["named_cmd_skills"] = cmds
			daily_log.append(entry)
			print("%3d | %9s | %9s | %6d | %8d | %8d | %9d | %14d | %20d" % [
				day, str(entry.get("anon_t0", "-")), str(entry.get("named_t0", "-")), state.teams.size(),
				counts_now["scout.dispatched"], counts_now["care.scout_dispatched"], counts_now["contact.react_rescue"],
				counts_now["manufacture.fired"], counts_now["manufacture.noop_no_facility"]])

	# facility/manufacturing 終態(builder/manufacturing下游檢查,不預設)
	var facility_log: Dictionary = {}
	for tid in [0, 1, 2, 3]:
		if not state.teams.has(tid): continue
		var t: TeamData = state.teams[tid]
		var tile: HexTileData = state.world.tiles.get(t.tile_pos.x * 1000 + t.tile_pos.y)
		if tile != null:
			facility_log["team%d" % tid] = {"outpost_level": tile.outpost_level, "manufacturing_level": tile.manufacturing_level}

	print("\n───── 終態總結 ─────")
	print("  team數: 起始4 → 終end=%d" % state.teams.size())
	print("  scout.dispatched累計=%d care.scout_dispatched累計=%d contact.react_rescue累計=%d" % [
		int(Probe.counts.get("scout.dispatched", 0)), int(Probe.counts.get("care.scout_dispatched", 0)),
		int(Probe.counts.get("contact.react_rescue", 0))])
	print("  manufacture.fired累計=%d noop_no_facility累計=%d construct.complete_upgrade_facility累計=%d" % [
		int(Probe.counts.get("manufacture.fired", 0)), int(Probe.counts.get("manufacture.noop_no_facility", 0)),
		int(Probe.counts.get("construct.complete_upgrade_facility", 0))])
	print("  facility終態: %s" % str(facility_log))
	print("  ★機械升格偵測(leaderless誕生的新team): %d 筆 %s" % [mechanical_promo_hits.size(), str(mechanical_promo_hits)])

	SpecimenTracer.flush()
	var spec_path: String = "docs/measurements/2026-08-11-unified-dispatch-remeasure-seed%d.specimen.jsonl" % SEED
	SpecimenDumpHelper.dump(state, spec_path)
	SpecimenTracer.reset()
	Probe.enabled = false

	var dump: Dictionary = {"seed": SEED, "days": DAYS, "daily_log": daily_log,
		"final_team_count": state.teams.size(), "facility_log": facility_log,
		"mechanical_promo_hits": mechanical_promo_hits,
		"scout_total": int(Probe.counts.get("scout.dispatched", 0)),
		"care_total": int(Probe.counts.get("care.scout_dispatched", 0)),
		"rescue_total": int(Probe.counts.get("contact.react_rescue", 0)),
		"manufacture_fired_total": int(Probe.counts.get("manufacture.fired", 0)),
		"noop_no_facility_total": int(Probe.counts.get("manufacture.noop_no_facility", 0))}
	var f := FileAccess.open("res://docs/measurements/2026-08-11-unified-dispatch-remeasure-seed%d.json" % SEED, FileAccess.WRITE)
	if f != null:
		f.store_string(JSON.stringify(dump, "  ")); f.close()
		print("\n[dump] → res://docs/measurements/2026-08-11-unified-dispatch-remeasure-seed%d.json" % SEED)
	print("=== DONE ===")
	quit()
