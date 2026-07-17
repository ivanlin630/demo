extends SceneTree

# threat-oracle S1 probe：_decide_unified commit loop 補 threat.dispatch.* tap（byte-identical 加項）。
# spec: threat-oracle S1；seam#1 finding5（統一路 threat dispatch 盲點，僅 preempt loop :405 有 tap）。
#
# 直接驅 _decide_unified（非 preempt _evaluate_threat）→ 統一隊選 threat option commit →
# threat.dispatch.<opt> 應 bump。RED before(commit loop 無 tap)、GREEN after。

var _fail: int = 0
var fai: FactionAISystem = FactionAISystem.new()

func _initialize() -> void:
	_test_unified_threat_dispatch_tap()
	if _fail == 0:
		print("=== DONE === ALL PASS")
	else:
		print("=== DONE === %d FAIL" % _fail)
	quit()

func _ok(cond: bool, msg: String) -> void:
	if cond:
		print("  [PASS] %s" % msg)
	else:
		_fail += 1
		print("  [FAIL] %s" % msg)

func _place_plains(state: WorldState, pos: Vector2i) -> void:
	var tile := HexTileData.new(); tile.tile_pos = pos; tile.terrain = "plains"
	state.world.tiles[pos.x * 1000 + pos.y] = tile

# 構「統一隊遇威脅 → threat option 勝 argmax」場景（鏡射 threat_dissolution_check._check_unified_path，
# 調 leader 值強偏迎戰：好戰=1.0/野心=0/慎重=0 壓 建設/備戰，求生欲低壓 survival）。
func _test_unified_threat_dispatch_tap() -> void:
	print("--- 統一路 threat dispatch tap（_decide_unified commit）---")
	var state := WorldState.new(); state.world = WorldData.new(); state.world.current_tick = 100
	var tid := 800
	var t := TeamData.new(); t.team_id = tid; t.tags = [TeamData.TAG_MERCHANT]
	t.tile_pos = Vector2i(5, 5); t.leader_id = tid * 10
	AnonTierSystem.add_anon(t, "平民", 10)
	t.resources = {"food": 300.0}   # 健康（survival 絕境不壓 rank）
	state.teams[tid] = t
	state.team_discovered[tid] = []
	state.team_intel[tid] = {}
	var ldr := PersonData.new(); ldr.id = tid * 10; ldr.team_id = tid
	ldr.values = {"好戰": 1.0, "慎重": 0.1, "求生欲": 0.0, "貪婪": 0.3, "信義": 0.3, "野心": 0.0}
	state.persons[ldr.id] = ldr
	_place_plains(state, Vector2i(5, 5))
	# 敵隊逼近 + 敵意 rep + 同等實力（moderate threat）
	var etid := 801
	var e := TeamData.new(); e.team_id = etid; e.tile_pos = Vector2i(7, 5); e.faction_id = -1
	e.last_tile_pos = Vector2i(8, 5)   # 8→7 逼近我(5,5)（threat 過門檻，threat opts applicable）
	AnonTierSystem.add_anon(e, "平民", 8)   # moderate 敵（threat 中量級，survival 不碾壓）
	state.teams[etid] = e
	_place_plains(state, Vector2i(7, 5))
	t.known_reputations[etid] = 0.1   # 敵意
	state.team_discovered[tid].append(etid)
	BeliefSystem.record_claim(state, tid, etid, etid, "親見", {"population_est": 8}, 1.0, false)
	t.current_option = "迎戰"   # 承諾慣性（合法：已在迎戰）→ +COMMITMENT_BONUS 助 threat opt 奪 argmax（穩定觸發 tap）

	Probe.reset(); Probe.enabled = true
	fai._decide_unified(state, t)   # ★單次呼叫（rank_scored 的 gather 有 need_urgency EWMA 副作用，勿先呼叫污染）
	Probe.enabled = false
	var chosen: String = t.current_option
	var threat_opts := ["備戰", "迎戰", "求和"]
	print("  [info] chosen=%s threat.dispatch: 備戰=%d 迎戰=%d 求和=%d" % [chosen,
		int(Probe.counts.get("threat.dispatch.備戰", 0)),
		int(Probe.counts.get("threat.dispatch.迎戰", 0)),
		int(Probe.counts.get("threat.dispatch.求和", 0))])
	_ok(chosen in threat_opts, "統一隊選 threat option（chosen=%s）" % chosen)
	if chosen in threat_opts:
		_ok(int(Probe.counts.get("threat.dispatch." + chosen, 0)) >= 1,
			"threat.dispatch.%s bump（統一路 tap）" % chosen)
