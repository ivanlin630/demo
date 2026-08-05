extends SceneTree

# [measurer persist fixture 2026-08-05] faction-cohesion③改床：config-assigned established factions,出口全活著不壓。
# 工單:2026-08-05-systems-to-measurer-established-bed-cohesion-reverify.md
# ★第一輪(15天)只做sanity check(bed建好+確認is_established/出口機制皆正常運作)→PASS。
# ★本輪(60天)=正式①②③ re-measure——g3 extension(03f03ce4)+uprising faction_id gate(00a40775)
#   已於worktree HEAD landed(ledger subteam記帳缺口為另案known_issues追蹤,與此床exit動態機制無關,非blocker)。
# ★is_established=true由此bed在setup後直接標記兩個faction(config無此欄位,founding pipeline目前P3已知斷根)——
#   這是模擬「世界開局就有正當歷史的既有勢力」初始條件，非繞過任何出口機制本身(defect/uprising/g3.betrayal/defection-eval全部原樣運作)。

const CONFIG_PATH := "res://config/infonet_established_fragility.json"
const SEED: int = 6066
const DAYS: int = 30
const OUT_PATH := "res://docs/measurements/2026-08-05-infonet-established-fragility-remeasure.json"

func _initialize() -> void:
	print("=== faction-cohesion③改床 sanity check（seed=%d %d天，只驗bed本身，非正式re-measure）===" % [SEED, DAYS])
	seed(SEED)
	FactionAISystem._a2b_remote_tribute_payers.clear()
	Probe.reset(); Probe.enabled = true
	var state := WorldState.new()
	var runner := SimRunner.new()
	var config: Dictionary = GameSetup.load_config(CONFIG_PATH)
	config["seed"] = SEED
	GameSetup.setup(state, config)
	SpecimenDumpHelper.setup_from_env(state)   # [measurer temp §⑤ 2026-08-05] 長跑因果結論必附specimen trace(用戶2026-07-22 hook)

	# ★世界開局就有勢力：直接標記兩個 faction 為 established（繞過 founding-never-establish confound、
	#   founding pipeline本身P3已知斷根[立國goal token從未emit]，此為正當初始條件非作弊）。
	var marked: Array = []
	for fid in state.factions:
		var f = state.factions[fid]
		f.is_established = true
		marked.append(fid)
	print("[setup] 標記 established factions: %s" % str(marked))

	var no_player := Vector2i(-1, -1)
	var ticks: int = WorldState.TICKS_PER_DAY * DAYS

	var members: Dictionary = {0: _mk_track(), 1: _mk_track(), 2: _mk_track(),
		3: _mk_track(), 4: _mk_track(), 5: _mk_track()}
	var labels: Dictionary = {0: "T0(GoodLord)", 1: "T1(GoodMember_Fed)", 2: "T2(GoodMember_Distress)",
		3: "T3(BadLord)", 4: "T4(BadMember_Fed)", 5: "T5(BadMember_Distress)"}
	var faction_track: Dictionary = {1: [], 2: []}   # daily {day, member_count, established}

	for tick in range(ticks):
		runner.advance_tick(state, no_player)
		var cur_tick: int = state.world.current_tick
		var day: int = cur_tick / WorldState.TICKS_PER_DAY
		for rid in [0, 1, 2, 3, 4, 5]:
			var R: Dictionary = members[rid]
			if state.teams.has(rid):
				var T: TeamData = state.teams[rid]
				R["alive_at_end"] = true
				if int(R.get("exit_day", -1)) == -1 and T.faction_id == -1:
					R["exit_day"] = day
				if cur_tick % WorldState.TICKS_PER_DAY == 0:
					(R["daily"] as Array).append({"day": day, "faction": T.faction_id,
						"unrest_turns": T.unrest_turns, "pop": T.population,
						"food": snappedf(ResourceSystem.effective_food(state, T), 0.1)})
			else:
				R["alive_at_end"] = false
		if cur_tick % WorldState.TICKS_PER_DAY == 0:
			for fid in [1, 2]:
				var mcount: int = 0
				for tid in state.teams:
					if state.teams[tid].faction_id == fid: mcount += 1
				var est: bool = state.factions.has(fid) and state.factions[fid].is_established
				(faction_track[fid] as Array).append({"day": day, "member_count": mcount, "established": est})

	print("\n───── re-measure 摘要(%d天) ─────" % DAYS)
	print("final: teams=%d factions=%d established=%d" % [
		state.teams.size(), state.factions.size(), _count_established(state)])
	for rid in [0, 1, 2, 3, 4, 5]:
		var R: Dictionary = members[rid]
		print("  %s: exit_day=%d alive_at_end=%s last_daily=%s" % [
			String(labels[rid]), int(R.get("exit_day", -1)), str(R["alive_at_end"]),
			str((R["daily"] as Array).back() if not (R["daily"] as Array).is_empty() else {})])

	print("\n①分化(faction member_count軌跡,好領主faction1 vs 壞領主faction2):")
	for fid in [1, 2]:
		var track: Array = faction_track[fid]
		print("  faction%d: day0=%s day10=%s day20=%s day%d(last)=%s" % [
			fid, str(track[0] if track.size()>0 else {}), str(track[10] if track.size()>10 else {}),
			str(track[20] if track.size()>20 else {}), DAYS - 1,
			str(track.back() if not track.is_empty() else {})])

	print("\n★出口機制未動確認：g3.betrayal=%d cohesion.defect_fire=%d cohesion.uprising_stay_faction=%d" % [
		int(Probe.counts.get("g3.betrayal", 0)), int(Probe.counts.get("cohesion.defect_fire", 0)),
		int(Probe.counts.get("cohesion.uprising_stay_faction", 0))])

	var dump: Dictionary = {
		"diagnostic": "faction-cohesion③正式re-measure(30天,g3+uprising fix已landed)",
		"marked_established": marked, "members": members, "faction_track": faction_track,
		"final": {"teams": state.teams.size(), "factions": state.factions.size(), "established": _count_established(state)},
		"probe": {"g3.betrayal": Probe.counts.get("g3.betrayal", 0),
			"cohesion.defect_fire": Probe.counts.get("cohesion.defect_fire", 0),
			"cohesion.uprising_stay_faction": Probe.counts.get("cohesion.uprising_stay_faction", 0)},
	}
	var f := FileAccess.open(OUT_PATH, FileAccess.WRITE)
	if f != null:
		f.store_string(JSON.stringify(dump, "  ")); f.close()
		print("\n[dump] → %s" % OUT_PATH)
	SpecimenDumpHelper.dump(state, "res://docs/measurements/2026-08-05-infonet-established-fragility-remeasure.specimen.jsonl")
	print("=== DONE ===")
	Probe.enabled = false
	quit()

func _count_established(state: WorldState) -> int:
	var n: int = 0
	for fid in state.factions:
		if state.factions[fid].is_established: n += 1
	return n

func _mk_track() -> Dictionary:
	return {"daily": [], "exit_day": -1, "alive_at_end": false}
