extends SceneTree

# [measurer persist fixture 2026-08-05] faction-cohesion g3 betrayal-fires 專床(工單床2)。
# 工單:2026-08-05-systems-to-measurer-cohesion-moderate-g3-beds.md
# ★in situ 真fire驗證(非手呼API):用GameSetup產真WorldState+跑真advance_tick loop,
#   讓g3.betrayal真的經faction_ai_system.gd:703 BETRAY_CHECK_INTERVAL cadence觸發
#   (implementer既有g3_betrayal_bond_test.gd是直呼betrayal_assessment()的純函數TDD,
#   本床補足「live cadence真fire」這層,兩者互補非重複)。
# ★人格/benefactor memory/known_reputations由bed script在setup後直接標記(config無此欄位,
#   同established fixture先例技法)——member T1(saved)3x benefactor memory指向lord+好rep,
#   T3(neglected)0 benefactor+差rep,唯一變因,人格(野心1.0/信義0/義氣0)兩邊相同控制confound。

const CONFIG_PATH := "res://config/infonet_g3_betrayal_bond.json"
const SEED: int = 8080
const RUN_TICKS: int = 1100   # >2x BETRAY_CHECK_INTERVAL(500) 保證至少2次評估cadence
const OUT_PATH := "res://docs/measurements/2026-08-05-infonet-g3-betrayal-bond.json"

func _initialize() -> void:
	print("=== g3 betrayal-fires 專床（seed=%d %d ticks，in-situ live cadence驗bond counter）===" % [SEED, RUN_TICKS])
	seed(SEED)
	FactionAISystem._a2b_remote_tribute_payers.clear()
	Probe.reset(); Probe.enabled = true
	var state := WorldState.new()
	var runner := SimRunner.new()
	var config: Dictionary = GameSetup.load_config(CONFIG_PATH)
	config["seed"] = SEED
	GameSetup.setup(state, config)
	SpecimenDumpHelper.setup_from_env(state)

	# ★seed 唯一變因：T1(saved) 3x benefactor memory 指向 lord(T0)+好rep；T3(neglected) 0+差rep。
	#   人格(野心1.0/信義0/義氣0)兩邊由 config 已相同設定，此處不重複改。
	var saved_leader: PersonData = state.persons.get(state.teams[1].leader_id)
	for i in range(3):
		saved_leader.memory.append({"type": "benefactor", "subject_id": 0, "tick": 0, "intensity": 1.0})
	state.teams[1].known_reputations[0] = 0.8

	var neglected_leader: PersonData = state.persons.get(state.teams[3].leader_id)
	state.teams[3].known_reputations[2] = 0.15   # 差rep、0 benefactor memory(不加)

	# ★ally_pop_est 可讀保證：faction known_member_states 補領主自身快照(member視角看領主population,
	#   同既有 g3_betrayal_bond_test.gd 手法,非god-view——代表member已知領主兵力估計此初始條件)。
	if state.factions.has(1): state.factions[1].known_member_states[0] = {"population": 5.0}
	if state.factions.has(2): state.factions[2].known_member_states[2] = {"population": 5.0}

	print("[setup] T1(saved) benefactor=3 rep=0.8 | T3(neglected) benefactor=0 rep=0.15")
	print("[setup] T1 stay_benefit(pre-run)=%.4f  T3 stay_benefit(pre-run)=%.4f" % [
		FactionAISystem.new()._faction_stay_benefit(state, state.teams[1]),
		FactionAISystem.new()._faction_stay_benefit(state, state.teams[3])])

	var no_player := Vector2i(-1, -1)
	for tick in range(RUN_TICKS):
		runner.advance_tick(state, no_player)

	print("\n───── g3 betrayal-fires 摘要 ─────")
	print("final teams=%d factions=%d" % [state.teams.size(), state.factions.size()])
	print("T1(saved)存活=%s faction=%s | T3(neglected)存活=%s faction=%s" % [
		str(state.teams.has(1)), str(state.teams[1].faction_id if state.teams.has(1) else "N/A"),
		str(state.teams.has(3)), str(state.teams[3].faction_id if state.teams.has(3) else "N/A")])
	print("★g3.betrayal總次數=%d" % int(Probe.counts.get("g3.betrayal", 0)))

	var dump: Dictionary = {
		"diagnostic": "g3 betrayal-fires 專床 in-situ live cadence驗bond counter",
		"final": {"teams": state.teams.size(), "factions": state.factions.size()},
		"T1_saved": {"alive": state.teams.has(1), "faction_id": state.teams[1].faction_id if state.teams.has(1) else null},
		"T3_neglected": {"alive": state.teams.has(3), "faction_id": state.teams[3].faction_id if state.teams.has(3) else null},
		"probe": {"g3.betrayal": Probe.counts.get("g3.betrayal", 0)},
	}
	var f := FileAccess.open(OUT_PATH, FileAccess.WRITE)
	if f != null:
		f.store_string(JSON.stringify(dump, "  ")); f.close()
		print("\n[dump] → %s" % OUT_PATH)
	SpecimenDumpHelper.dump(state, "res://docs/measurements/2026-08-05-infonet-g3-betrayal-bond.specimen.jsonl")
	print("=== DONE ===")
	Probe.enabled = false
	quit()
