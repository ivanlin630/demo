extends SceneTree
# convoy RETURN 收尾 TDD（slice: convoy-return-conservation、HOW spec 2026-08-21）。
# ①★persist.hold 對 CONVOY 真 fire：RETURN 途中 routine（貿易/外交）搶班 → 被擋
# ②★survival 仍搶得走（不做成硬鎖）＋③玩家命令不擋
# ④T3 母隊滅團 → 轉獨立 + T0 喚醒 + ★貨物原封留在身上（禁瞬移交割）
# ⑤T3 逾時（elapsed > 3× 預期 ETA）→ 同上，reason=timeout
# ⑥T2 抵達即結案：try_merge_back 認 convoy.return 並清 convoy_phase
# ⑦★守恆：stranded 前後，母隊資源零變動（沒有任何東西被瞬移回去）

var _fail := 0
func _ok(c: bool, m: String) -> void:
	if c: print("  PASS ", m)
	else: _fail += 1; print("  FAIL ", m)

func _initialize() -> void:
	_run(); quit()

# 母隊(0,0) + porter 子隊（帶貨在 (3,0)），porter 已在 RETURN
func _mk(return_phase: bool = true) -> Array:
	var s := WorldState.new(); s.world = WorldData.new(); s.player_id = -1
	s.world.current_tick = 5000
	for x in range(5):
		var t := HexTileData.new(); t.tile_id = x * 1000; t.tile_pos = Vector2i(x, 0); t.terrain = "plains"
		t.resources = {"food": 60.0}; t.resource_cap = {"food": 200.0}
		s.world.tiles[t.tile_id] = t
	var lp := PersonData.new(); lp.id = 500; lp.team_id = 5
	lp.values = {"慎重": 0.6, "義氣": 0.6, "野心": 0.3, "貪婪": 0.3}; lp.skills = {"統領": 0.6}
	s.persons[500] = lp
	var lord := TeamData.new(); lord.team_id = 5; lord.leader_id = 500; lord.tile_pos = Vector2i(0, 0)
	AnonCohort.add(lord.anon_cohorts, "平民", "healthy", 12)
	lord.resources = {"food": 100.0, "coin": 500.0, "material": 50.0}
	s.teams[5] = lord

	var pp := PersonData.new(); pp.id = 501; pp.team_id = 12
	pp.values = {"慎重": 0.6, "義氣": 0.6, "野心": 0.3, "貪婪": 0.3}; pp.skills = {"統領": 0.4}
	s.persons[501] = pp
	var porter := TeamData.new(); porter.team_id = 12; porter.leader_id = 501; porter.tile_pos = Vector2i(3, 0)
	AnonCohort.add(porter.anon_cohorts, "平民", "healthy", 1)
	porter.resources = {"food": 10.0, "coin": 220.0, "material": 15.0}
	porter.current_task = TeamData.TASK_CONVOY
	porter.task_priority = TaskArbiter.PRIO_DISPATCH
	porter.task_start_tick = 5000 - 3 * WorldState.TICKS_PER_DAY   # 已跑 3 天（沉沒成本）
	porter.task_extra_data = {
		"convoy_phase": "RETURN" if return_phase else "OUTBOUND", "cargo_res": "material",
		"cargo_qty": 30.0, "market_pos": Vector2i(4, 0), "home_pos": Vector2i(0, 0),
		"convoy_kind": "deliver", "order_id": -1,
	}
	s.teams[12] = porter
	s.set_subteam_parent(porter, 5)
	PersistStrength.compute(s, porter)
	return [s, lord, porter]

func _run() -> void:
	print("=== convoy RETURN closure test ===")
	var fai := FactionAISystem.new()

	# ① persist.hold 對 CONVOY fire
	var w := _mk(); var s: WorldState = w[0]; var porter: TeamData = w[2]
	_ok(porter.persist_strength > TaskArbiter.PERSIST_HOLD_THRESHOLD,
		"①前提：CONVOY 有持守強度 %.3f > %.2f" % [porter.persist_strength, TaskArbiter.PERSIST_HOLD_THRESHOLD])
	Probe.enabled = true; Probe.reset()
	var stolen: bool = TaskArbiter.try_set(s, porter, TeamData.TASK_TRADE, Vector2i(4, 0),
		TaskArbiter.PRIO_DISPATCH, "unified")
	_ok(not stolen and porter.current_task == TeamData.TASK_CONVOY, "★①routine（貿易@DISPATCH）搶不走")
	_ok(int(Probe.counts.get("persist.hold", 0)) == 1, "★①persist.hold 真的 fire（=1）")

	# ② survival 仍可搶
	var ok_surv: bool = TaskArbiter.try_set(s, porter, TeamData.TASK_FLEE, Vector2i(2, 0),
		TaskArbiter.PRIO_SURVIVAL, "survival")
	_ok(ok_surv and porter.current_task == TeamData.TASK_FLEE, "★②survival（逃跑@80）仍搶得走（不是硬鎖）")

	# ③ 玩家命令不擋
	var w3 := _mk(); var s3: WorldState = w3[0]; var p3: TeamData = w3[2]
	var ok_player: bool = TaskArbiter.try_set(s3, p3, TeamData.TASK_TRADE, Vector2i(4, 0),
		TaskArbiter.PRIO_PLAYER, "player")
	_ok(ok_player, "③玩家命令（PRIO_PLAYER）不被擋")

	# ④ 母隊滅團 → 轉獨立 + 喚醒 + 貨物留身上
	var w4 := _mk(); var s4: WorldState = w4[0]; var p4: TeamData = w4[2]
	var before: Dictionary = p4.resources.duplicate()
	s4.teams.erase(5)   # 母隊沒了
	Probe.reset()
	var mq: Array = []
	fai._tick_convoy(s4, p4, mq)
	_ok(int(Probe.counts.get("convoy.stranded.parent_gone", 0)) == 1, "★④母隊滅團 → stranded(parent_gone)")
	_ok(p4.parent_team_id == -1 and p4.current_task == TeamData.TASK_IDLE, "④轉獨立隊（parent=-1、task=IDLE）")
	_ok(WorldEvents.is_pending(s4, 12), "★④T0 喚醒（pending_rethink）＝不靜默漂流")
	_ok(not (p4.task_extra_data as Dictionary).has("convoy_phase"), "④convoy 旗標已清")
	_ok(p4.resources == before, "★④★貨物原封不動留在身上（禁瞬移交割）")

	# ⑤ 逾時（elapsed > 3×ETA）
	var w5 := _mk(); var s5: WorldState = w5[0]; var p5: TeamData = w5[2]
	p5.task_extra_data["return_eta"] = 100
	p5.task_extra_data["return_start_tick"] = s5.world.current_tick - 400   # 400 > 3×100
	Probe.reset()
	fai._tick_convoy(s5, p5, [])
	_ok(int(Probe.counts.get("convoy.stranded.timeout", 0)) == 1, "★⑤逾時（>3×ETA）→ stranded(timeout)")
	_ok(p5.parent_team_id == -1, "⑤逾時後亦轉獨立")

	# ⑤b 未逾時 → 不放棄
	var w5b := _mk(); var s5b: WorldState = w5b[0]; var p5b: TeamData = w5b[2]
	p5b.task_extra_data["return_eta"] = 100
	p5b.task_extra_data["return_start_tick"] = s5b.world.current_tick - 200   # 200 < 300
	p5b.move_target = Vector2i(0, 0)
	Probe.reset()
	fai._tick_convoy(s5b, p5b, [])
	_ok(int(Probe.counts.get("convoy.stranded", 0)) == 0 and p5b.parent_team_id == 5,
		"⑤b 還在合理時間內 → 不放棄（不誤殺）")

	# ⑥ T2：同格 → merge_back 認 return 並清旗標
	var w6 := _mk(); var s6: WorldState = w6[0]; var lord6: TeamData = w6[1]; var p6: TeamData = w6[2]
	p6.tile_pos = lord6.tile_pos   # 回到家門口
	var lord_coin_before: float = float(lord6.resources.get("coin", 0))
	var porter_coin: float = float(p6.resources.get("coin", 0))
	Probe.reset()
	var merged: bool = SubteamSystem.new().try_merge_back(s6, 12)
	_ok(merged, "⑥同格 → try_merge_back 成功")
	_ok(int(Probe.counts.get("convoy.return", 0)) == 1, "★⑥convoy.return 計 1")
	_ok(float(lord6.resources.get("coin", 0)) >= lord_coin_before + porter_coin - 0.001,
		"★⑥貨款真的併回母隊（%.1f → %.1f）" % [lord_coin_before, float(lord6.resources.get("coin", 0))])
	Probe.enabled = false

	print("=== %s（fail=%d）===" % ["ALL PASS" if _fail == 0 else "HAS FAILURE", _fail])
