extends SceneTree

# [measurer persist fixture 2026-08-05] faction-cohesion moderate-distress分化床(工單床1)。
# 工單:2026-08-05-systems-to-measurer-cohesion-moderate-g3-beds.md
# ★ex-ante物理判準(防narrative-tuning,systems/blueprint命,詳config._doc)：
#   resident距lord D=5 hex(物理最短relief延遲≈(49×5+240)/240≈2.02天/趟)、
#   food0=180(runway0=22.5天,consume=8/天,mountain無產出)→unrest-onset(runway<2.0)預期~day20.5，
#   遠早於此的每日INFO_DISPATCH_CADENCE(1天)給好/壞領主AI數十次proactive relief機會，
#   distress窗(unrest-onset→死亡/退出)遠大於物理最短relief延遲=relief物理來得及。
#   此判準寫在code跑之前(config._doc timestamp)、非事後對到剛好才回頭圓。

const CONFIG_PATH := "res://config/infonet_moderate_distress_fragility.json"
const SEED: int = 7070
const DAYS: int = 65
const OUT_PATH := "res://docs/measurements/2026-08-05-infonet-moderate-distress-fragility.json"

func _initialize() -> void:
	print("=== moderate-distress分化床（seed=%d %d天，ex-ante判準見config._doc）===" % [SEED, DAYS])
	seed(SEED)
	FactionAISystem._a2b_remote_tribute_payers.clear()
	Probe.reset(); Probe.enabled = true
	var state := WorldState.new()
	var runner := SimRunner.new()
	var config: Dictionary = GameSetup.load_config(CONFIG_PATH)
	config["seed"] = SEED
	GameSetup.setup(state, config)
	SpecimenDumpHelper.setup_from_env(state)

	var marked: Array = []
	for fid in state.factions:
		state.factions[fid].is_established = true
		marked.append(fid)
	print("[setup] 標記 established factions: %s" % str(marked))
	print("[setup] hex_dist(lord0,member1)=%d  hex_dist(lord2,member3)=%d" % [
		_hex_dist(state.teams[0].tile_pos, state.teams[1].tile_pos),
		_hex_dist(state.teams[2].tile_pos, state.teams[3].tile_pos)])

	var no_player := Vector2i(-1, -1)
	var ticks: int = WorldState.TICKS_PER_DAY * DAYS

	var members: Dictionary = {1: _mk_track(), 3: _mk_track()}
	var labels: Dictionary = {1: "T1(GoodMember_Moderate)", 3: "T3(BadMember_Moderate)"}

	for tick in range(ticks):
		runner.advance_tick(state, no_player)
		var cur_tick: int = state.world.current_tick
		var day: int = cur_tick / WorldState.TICKS_PER_DAY
		for rid in [1, 3]:
			var R: Dictionary = members[rid]
			if state.teams.has(rid):
				var T: TeamData = state.teams[rid]
				R["alive_at_end"] = true
				if int(R.get("exit_day", -1)) == -1 and T.faction_id == -1:
					R["exit_day"] = day
				if cur_tick % WorldState.TICKS_PER_DAY == 0:
					var runway: float = GoalResolver._resident_food_runway(state, T)
					(R["daily"] as Array).append({"day": day, "faction": T.faction_id,
						"unrest_turns": T.unrest_turns, "pop": T.population,
						"food": snappedf(ResourceSystem.effective_food(state, T), 0.1),
						"runway": snappedf(runway, 0.2)})
			else:
				R["alive_at_end"] = false

	print("\n───── moderate-distress 摘要(%d天) ─────" % DAYS)
	for rid in [1, 3]:
		var R: Dictionary = members[rid]
		print("  %s: exit_day=%d alive_at_end=%s last_daily=%s" % [
			String(labels[rid]), int(R.get("exit_day", -1)), str(R["alive_at_end"]),
			str((R["daily"] as Array).back() if not (R["daily"] as Array).is_empty() else {})])
	# runway crossing<2.0 day（驗ex-ante預期~day20.5是否對上）
	for rid in [1, 3]:
		var R: Dictionary = members[rid]
		var cross_day: int = -1
		for d in R["daily"]:
			if float(d["runway"]) < 2.0: cross_day = int(d["day"]); break
		print("  %s: runway<2.0首日=%d" % [String(labels[rid]), cross_day])

	print("\n★relief/出口機制計數：distribute.deliver=%d cohesion.benefactor_write=%d cohesion.defect_fire=%d cohesion.uprising_stay_faction=%d g3.betrayal=%d" % [
		int(Probe.counts.get("distribute.deliver", 0)), int(Probe.counts.get("cohesion.benefactor_write", 0)),
		int(Probe.counts.get("cohesion.defect_fire", 0)), int(Probe.counts.get("cohesion.uprising_stay_faction", 0)),
		int(Probe.counts.get("g3.betrayal", 0))])

	# ★QA要求補tap(2026-08-05-qa-to-measurer-moderate-distress-verdict.md)：help.*/distribute.*鏈中間環節，
	#   判「求援求助全程沒fire」vs「fire了但lord沒回應」vs「回應了但太慢」三種故事。
	print("★help鏈(resident自身求援側)：help.severity_positive=%d help.target_unresolved=%d help.target_resolved=%d help.letter_dispatched=%d help.delivered=%d help.letter_timeout=%d help.letter_intercepted=%d help.need_deposited=%d" % [
		int(Probe.counts.get("help.severity_positive", 0)), int(Probe.counts.get("help.target_unresolved", 0)),
		int(Probe.counts.get("help.target_resolved", 0)), int(Probe.counts.get("help.letter_dispatched", 0)),
		int(Probe.counts.get("help.delivered", 0)), int(Probe.counts.get("help.letter_timeout", 0)),
		int(Probe.counts.get("help.letter_intercepted", 0)), int(Probe.counts.get("help.need_deposited", 0))])
	print("★distribute鏈(lord回應側)：distribute.dispatch=%d distribute.unrest_add=%d distribute.unrest_reduce=%d distribute.mini_util(peak)=%.4f help.mini_util(peak)=%.4f" % [
		int(Probe.counts.get("distribute.dispatch", 0)), int(Probe.counts.get("distribute.unrest_add", 0)),
		int(Probe.counts.get("distribute.unrest_reduce", 0)), float(Probe.peaks.get("distribute.mini_util", 0.0)),
		float(Probe.peaks.get("help.mini_util", 0.0))])

	# ★care-loop鏈(工單2026-08-05-systems-to-measurer-care-loop-cohesion-1natural.md)：
	#   holding overdue→care/ignore秤→scout dispatch→co-location firsthand→synth distress order→distribute pickup。
	print("★care-loop鏈(領主主動照護)：contact.overdue=%d contact.care_check=%d contact.care_ignore=%d care.scout_dispatched=%d care.firsthand_distress=%d" % [
		int(Probe.counts.get("contact.overdue", 0)), int(Probe.counts.get("contact.care_check", 0)),
		int(Probe.counts.get("contact.care_ignore", 0)), int(Probe.counts.get("care.scout_dispatched", 0)),
		int(Probe.counts.get("care.firsthand_distress", 0))])

	var dump: Dictionary = {
		"diagnostic": "faction-cohesion moderate-distress分化床(ex-ante判準見config._doc)+QA要求help/distribute鏈補tap",
		"marked_established": marked, "members": members,
		"probe": {"distribute.deliver": Probe.counts.get("distribute.deliver", 0),
			"cohesion.benefactor_write": Probe.counts.get("cohesion.benefactor_write", 0),
			"cohesion.defect_fire": Probe.counts.get("cohesion.defect_fire", 0),
			"cohesion.uprising_stay_faction": Probe.counts.get("cohesion.uprising_stay_faction", 0),
			"g3.betrayal": Probe.counts.get("g3.betrayal", 0),
			"help.severity_positive": Probe.counts.get("help.severity_positive", 0),
			"help.target_unresolved": Probe.counts.get("help.target_unresolved", 0),
			"help.target_resolved": Probe.counts.get("help.target_resolved", 0),
			"help.letter_dispatched": Probe.counts.get("help.letter_dispatched", 0),
			"help.delivered": Probe.counts.get("help.delivered", 0),
			"help.letter_timeout": Probe.counts.get("help.letter_timeout", 0),
			"help.letter_intercepted": Probe.counts.get("help.letter_intercepted", 0),
			"help.need_deposited": Probe.counts.get("help.need_deposited", 0),
			"distribute.dispatch": Probe.counts.get("distribute.dispatch", 0),
			"distribute.unrest_add": Probe.counts.get("distribute.unrest_add", 0),
			"distribute.unrest_reduce": Probe.counts.get("distribute.unrest_reduce", 0),
			"contact.overdue": Probe.counts.get("contact.overdue", 0),
			"contact.care_check": Probe.counts.get("contact.care_check", 0),
			"contact.care_ignore": Probe.counts.get("contact.care_ignore", 0),
			"care.scout_dispatched": Probe.counts.get("care.scout_dispatched", 0),
			"care.firsthand_distress": Probe.counts.get("care.firsthand_distress", 0)},
		"care_sample": Probe.samples.get("care.reaction_sample", []),
	}
	var f := FileAccess.open(OUT_PATH, FileAccess.WRITE)
	if f != null:
		f.store_string(JSON.stringify(dump, "  ")); f.close()
		print("\n[dump] → %s" % OUT_PATH)
	SpecimenDumpHelper.dump(state, "res://docs/measurements/2026-08-05-infonet-moderate-distress-fragility.specimen.jsonl")
	print("=== DONE ===")
	Probe.enabled = false
	quit()

func _hex_dist(a: Vector2i, b: Vector2i) -> int:
	var dx: int = b.x - a.x
	var dy: int = b.y - a.y
	return int((absf(dx) + absf(dx + dy) + absf(dy)) / 2)

func _mk_track() -> Dictionary:
	return {"daily": [], "exit_day": -1, "alive_at_end": false}
