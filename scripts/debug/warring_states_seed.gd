extends SceneTree

# 戰國 seed（藍圖 roadmap 2026-06-29）：多派系活世界 = commander 協同驗證床 + G3/欺敵/玩家面前置。
# 純 NPC 觀測（不驅動 player）。量 commander-v2 意圖分布 + 立國/攻擊/背叛 emergent + 守恆。
# config/warring_states.json：radius14 / 8 faction / 多獨立。

func _initialize() -> void:
	_run(); quit()

# ascii label（避 CP950 terminal garbled）：征服=CONQUER 致富=RICH 防衛=DEFEND 守成=HOLD 擴張=EXPAND 建國=FOUND
const _INTENT_ASCII: Dictionary = {"征服": "CONQUER", "致富": "RICH", "防衛": "DEFEND",
	"守成": "HOLD", "擴張": "EXPAND", "建國": "FOUND"}
# 首燒：統一 intent 分布 = faction commander(f.intent) + 獨立隊(solo_intent struct，F-D4)。
# 一套菜單跨實體型 → 獨立商隊 RICH / 好戰獨立 CONQUER 顯化（前僅 faction 計 → CONQUER 恆 0 假象）。
func _intent_histogram(state: WorldState) -> Dictionary:
	var h: Dictionary = {"CONQUER": 0, "RICH": 0, "DEFEND": 0, "HOLD": 0, "EXPAND": 0, "FOUND": 0, "NONE": 0}
	for fid in state.factions:
		var f = state.factions[fid]
		var it: String = f.intent.get("type", "") if f.intent is Dictionary else ""
		h[_INTENT_ASCII.get(it, "NONE")] += 1
	for tid in state.teams:
		var t: TeamData = state.teams[tid]
		if t.faction_id != -1 or t.parent_team_id != -1: continue   # 只獨立隊（非子隊）
		var si: String = String(t.solo_intent.get("type", "")) if t.solo_intent is Dictionary else ""
		h[_INTENT_ASCII.get(si, "NONE")] += 1
	return h

func _established_count(state: WorldState) -> int:
	var n: int = 0
	for fid in state.factions:
		if state.factions[fid].is_established: n += 1
	return n

func _run() -> void:
	# WARRING_SEED env（default 1337）→ seed() 播 global RNG + config.seed 播 setup RNG → 逐 tick 逐隊重現。
	# 同 seed 兩跑逐點相同（見 headless _test_seeded_warring_reproducible）。RNG 盤點見 warring_harness.gd 檔頭。
	var world_seed: int = int(OS.get_environment("WARRING_SEED")) if OS.has_environment("WARRING_SEED") else 1337
	seed(world_seed)
	print("=== warring_states seed: 多派系活世界（commander 協同驗證床）seed=%d ===" % world_seed)
	Probe.enabled = true
	Probe.reset()
	var state := WorldState.new()
	var runner := SimRunner.new()
	var config := GameSetup.load_config("res://config/warring_states.json")
	if config.is_empty():
		print("[FAIL] config 載入失敗"); Probe.enabled = false; return
	config["seed"] = world_seed
	GameSetup.setup(state, config)
	var max_ticks: int = int(config.get("max_ticks", 172800))
	print("[戰國] max_ticks=%d (%.1f 年) teams=%d factions=%d" % [
		max_ticks, max_ticks / 86400.0, state.teams.size(), state.factions.size()])

	var no_player := Vector2i(-1, -1)
	for tick in range(max_ticks):
		runner.advance_tick(state, no_player)
		if state.encounter_active and state.encounter_tick > 800:
			runner._encounter_system.resolve_encounter_end(state, "draw")
		if (tick + 1) % (240 * 30) == 0:
			var month: int = (tick + 1) / (240 * 30)
			print("[戰國] 月%d tick=%d teams=%d factions=%d established=%d 意圖=%s" % [
				month, tick + 1, state.teams.size(), state.factions.size(),
				_established_count(state), str(_intent_histogram(state))])
		if state.teams.is_empty():
			print("[戰國] 全滅 @ tick=%d" % (tick + 1)); break

	print("\n[戰國] === 收尾 ===")
	print("[戰國] 最終 teams=%d factions=%d established=%d" % [
		state.teams.size(), state.factions.size(), _established_count(state)])
	print("[戰國] 意圖分布=%s" % str(_intent_histogram(state)))
	# emergent probes（commander 協同 + 信息域驗證床）
	for k in ["g2.faction_found", "g2.feud_formed", "g2.vendetta_trigger", "g3.scout_dispatch",
			"g3.betrayal", "g3.trust_up", "g3.trust_down",
			"indep.found_ally", "indep.found_subjugate"]:
		print("[戰國] probe %s=%d" % [k, int(Probe.counts.get(k, 0))])
	# 受控人力 P1 (a)：吸收→同化(pop 累積)/暴動/逃 emergent
	for k in ["p1.assimilate", "p1.revolt", "p1.flee"]:
		print("[戰國] probe %s=%d" % [k, int(Probe.counts.get(k, 0))])
	# BEG/JOIN 死路探針（F-I3）：NPC-NPC 絕境乞食/投靠 dispatch vs resolve 死路量化
	for k in ["beg.dispatch", "beg.early_return_197", "beg.resolve",
			"join.dispatch", "join.arrived_no_handler", "join.resolve"]:
		print("[戰國] probe %s=%d" % [k, int(Probe.counts.get(k, 0))])
	Probe.enabled = false
	print("=== warring_states seed DONE ===")
