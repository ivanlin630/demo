extends SceneTree

# [measurer persist fixture 2026-08-05] 失聯帳本 diversity re-measure(重建先前temp未persist設計)。
# 工單:2026-08-05-systems-to-measurer-ledger-fix-remeasure.md
# 驗defensive/rescue fix後(baf2a670)：★4類反應全真世界效果 + diversity仍在(統領→redispatch/
#   野心→writeoff/慎重→defensive/義氣→rescue乾淨對應非塌一類)。
# 4組lord+resident pair,每個lord只一特質0.9(dominant)其餘0.2,resident starving(food15,
# mountain)逼lord派distribute convoy,mountain terrain 0.4×倍率讓convoy實際travel慢於
# ledger flat估算(overdue_ratio>1.0)觸發contact.overdue+_pick_contact_reaction。

const CONFIG_PATH := "res://config/infonet_ledger_diversity.json"
const SEED: int = 4044
const DAYS: int = 30
const OUT_PATH := "res://docs/measurements/2026-08-05-infonet-ledger-diversity-remeasure.json"

func _initialize() -> void:
	print("=== 失聯帳本 diversity re-measure（defensive/rescue fix驗證,seed=%d %d天）===" % [SEED, DAYS])
	seed(SEED)
	FactionAISystem._a2b_remote_tribute_payers.clear()
	Probe.reset(); Probe.enabled = true
	var state := WorldState.new()
	var runner := SimRunner.new()
	var config: Dictionary = GameSetup.load_config(CONFIG_PATH)
	config["seed"] = SEED
	GameSetup.setup(state, config)
	SpecimenDumpHelper.setup_from_env(state)

	var no_player := Vector2i(-1, -1)
	var ticks: int = WorldState.TICKS_PER_DAY * DAYS
	for tick in range(ticks):
		runner.advance_tick(state, no_player)

	print("\n───── 失聯帳本 diversity 摘要(%d天) ─────" % DAYS)
	print("final teams=%d factions=%d" % [state.teams.size(), state.factions.size()])
	print("contact.ledger_add=%d  contact.overdue=%d" % [
		int(Probe.counts.get("contact.ledger_add", 0)), int(Probe.counts.get("contact.overdue", 0))])
	print("react聚合分佈: redispatch=%d writeoff=%d defensive=%d rescue=%d" % [
		int(Probe.counts.get("contact.react_redispatch", 0)), int(Probe.counts.get("contact.react_writeoff", 0)),
		int(Probe.counts.get("contact.react_defensive", 0)), int(Probe.counts.get("contact.react_rescue", 0))])

	# ★per-team react歸因(判乾淨1:1 mapping vs 交叉污染)
	var lord_ids: Array = [0, 2, 4, 6]
	var lord_trait: Dictionary = {0: "統領", 2: "野心", 4: "慎重", 6: "義氣"}
	var per_team: Dictionary = {}
	for s in Probe.samples.get("contact.react_sample", []):
		var tid: int = int(s.get("team", -1))
		if not per_team.has(tid): per_team[tid] = {}
		var r: String = String(s.get("react", ""))
		per_team[tid][r] = int(per_team[tid].get(r, 0)) + 1
	print("\n★per-lord react歸因(判乾淨對應非交叉污染):")
	for lid in lord_ids:
		print("  lord%d(dominant=%s): %s" % [lid, String(lord_trait[lid]), str(per_team.get(lid, {}))])

	print("\n★4類真世界效果確認：")
	print("  redispatch=真re-dispatch(_try_scout_side/_try_herald_side呼叫,無獨立tap,間接見help/scout counts上升)")
	print("  defensive→contact_vigilant_until設定次數(=contact.react_defensive)=%d" % int(Probe.counts.get("contact.react_defensive", 0)))
	print("  rescue→scout真dispatch到lost_pos次數(=contact.react_rescue)=%d" % int(Probe.counts.get("contact.react_rescue", 0)))
	print("  writeoff→entry真丟棄次數(=contact.react_writeoff)=%d" % int(Probe.counts.get("contact.react_writeoff", 0)))

	var dump: Dictionary = {
		"diagnostic": "失聯帳本diversity re-measure(defensive/rescue fix驗證,baf2a670)",
		"final": {"teams": state.teams.size(), "factions": state.factions.size()},
		"probe": {"contact.ledger_add": Probe.counts.get("contact.ledger_add", 0),
			"contact.overdue": Probe.counts.get("contact.overdue", 0),
			"contact.react_redispatch": Probe.counts.get("contact.react_redispatch", 0),
			"contact.react_writeoff": Probe.counts.get("contact.react_writeoff", 0),
			"contact.react_defensive": Probe.counts.get("contact.react_defensive", 0),
			"contact.react_rescue": Probe.counts.get("contact.react_rescue", 0)},
		"per_lord_react": per_team,
	}
	var f := FileAccess.open(OUT_PATH, FileAccess.WRITE)
	if f != null:
		f.store_string(JSON.stringify(dump, "  ")); f.close()
		print("\n[dump] → %s" % OUT_PATH)
	SpecimenDumpHelper.dump(state, "res://docs/measurements/2026-08-05-infonet-ledger-diversity-remeasure.specimen.jsonl")
	print("=== DONE ===")
	Probe.enabled = false
	quit()
