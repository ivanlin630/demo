extends SceneTree

# 資訊網 Part2 求援 argmax-loss 診斷（spec 2026-08-04-part2-argmax-diagnostic）。measure-first、別下結論、只交真值+argmax 輸給誰表。
# RE-measure#2:help/scout/distribute 仍全 0→真 blocker=argmax（求援 applicable 但輸、從沒 reach dispatch）。
# 假設:DESPERATION_DAYS=3 help applicable food<3;SURVIVAL_BOOST_FLOOR=2 boost food<2→窗口[2,3)求援 util≈0.35 輸食物 option。
# 純觀測 tap（讀 rank_scored）零行為變。seed1337 honest-carrier。★bed 在 feat/info-network-whole（需 求援 machinery）。

func _initialize() -> void:
	seed(1337)
	print("=== Part2 求援 argmax-loss 診斷 (DESPERATION_DAYS=3 SURVIVAL_BOOST_FLOOR=2 BOOST_MAX=2.5) ===")
	# 掃 food_days 窗口：3.5(不絕境對照) / 2.5([2,3)求援 applicable 無 boost) / 1.5(<2 survival-boost 破頂)
	for fd in [3.5, 2.5, 1.5, 0.5]:
		_diag_resident_argmax(fd)
	_diag_distribute_dependency()
	print("=== DONE ===")
	quit()

# 小餓 resident（pop3、名冊可達領主）在 food_days=fd 的 rank_scored 逐站 tap。
func _diag_resident_argmax(target_fd: float) -> void:
	var state := WorldState.new(); state.world = WorldData.new(); state.world.current_tick = 1000
	var fac := FactionData.new(); fac.faction_id = 0; fac.leader_team_id = 1; state.factions[0] = fac
	# 領主 team1 固定 outpost @(9,9)（resident 無 belief→名冊 fallback 解析）
	var lt := HexTileData.new(); lt.tile_pos = Vector2i(9,9); lt.outpost_level = 1; lt.outpost_owner = 1
	state.world.tiles[9*1000+9] = lt
	var lord := TeamData.new(); lord.team_id = 1; lord.faction_id = 0; lord.tile_pos = Vector2i(9,9)
	AnonCohort.add(lord.anon_cohorts, "平民", "healthy", 20); state.teams[1] = lord
	# resident team2 outpost @(5,5)、pop3（leader 1 + anon 2）、food 設到 target_fd
	var rt := HexTileData.new(); rt.tile_pos = Vector2i(5,5); rt.outpost_type = "civilian"; rt.outpost_level = 1; rt.outpost_owner = 2
	state.world.tiles[5*1000+5] = rt
	var r := TeamData.new(); r.team_id = 2; r.faction_id = 0; r.tile_pos = Vector2i(5,5)
	r.tags = [TeamData.TAG_PRODUCE]; AnonCohort.add(r.anon_cohorts, "平民", "healthy", 2)
	var lr := PersonData.new(); lr.id = 12; lr.values = {"求生欲": 0.7, "野心": 0.3, "義氣": 0.6, "慎重": 0.5}; state.persons[12] = lr; r.leader_id = 12
	var pop: int = r.population
	r.resources = {"food": target_fd * float(pop) * ResourceSystem.FOOD_PER_PERSON_PER_DAY}
	state.teams[2] = r
	Probe.reset(); Probe.enabled = true
	var scored: Array = DecisionEngine.rank_scored(state, r)
	Probe.enabled = false
	var ctx: DecisionContext = DecisionContext.gather(state, r)
	# ① applicable 各條真值
	print("--- food_days≈%.2f (pop=%d) ---" % [ctx.food_days, pop])
	print("  ①applicable 條:can_send_herald=%s help_target_id=%d help_need_severity=%.2f" % [str(ctx.can_send_herald), ctx.help_target_id, ctx.help_need_severity])
	# ②③④ 求援在 scored? util? winner?
	var help_u: float = -999.0; var help_rank: int = -1
	for i in range(scored.size()):
		if String(scored[i].get("opt","")) == "求援": help_u = float(scored[i]["u"]); help_rank = i; break
	if help_rank == -1:
		print("  ②求援未進 rank_scored（applicable 擋？見①）")
	else:
		var w: Dictionary = scored[0]
		print("  ②求援進 rank ③util=%.3f rank=%d/%d" % [help_u, help_rank, scored.size()])
		print("  ④★argmax winner='%s' util=%.3f（求援%s）" % [String(w.get("opt","")), float(w["u"]), "贏" if help_rank==0 else "輸給它"])
		var top: String = ""
		for i in range(mini(6, scored.size())):
			top += "%s=%.2f " % [String(scored[i].get("opt","")), float(scored[i]["u"])]
		print("  top: %s" % top)

# ⑥ distribute 依賴驗：人工塞 distress(resident food 買單)進領主 team_known → distribute fire?
func _diag_distribute_dependency() -> void:
	print("--- ⑥distribute 依賴（distress 塞領主 team_known→distribute fire?）---")
	var state := WorldState.new(); state.world = WorldData.new(); state.world.current_tick = 1000
	var fac := FactionData.new(); fac.faction_id = 0; fac.leader_team_id = 1; state.factions[0] = fac
	var lt := HexTileData.new(); lt.tile_pos = Vector2i(9,9); lt.outpost_type = "civilian"; lt.outpost_level = 1; lt.outpost_owner = 1
	state.world.tiles[9*1000+9] = lt
	var lord := TeamData.new(); lord.team_id = 1; lord.faction_id = 0; lord.tile_pos = Vector2i(9,9)
	lord.tags = [TeamData.TAG_PRODUCE]; AnonCohort.add(lord.anon_cohorts, "平民", "healthy", 20); lord.resources = {"food": 3000.0}
	var ll := PersonData.new(); ll.id = 11; ll.values = {"義氣": 0.6, "貪婪": 0.5, "慎重": 0.5, "野心": 0.5}; state.persons[11] = ll; lord.leader_id = 11
	state.teams[1] = lord
	var rt := HexTileData.new(); rt.tile_pos = Vector2i(6,5); rt.outpost_type = "civilian"; rt.outpost_level = 1; rt.outpost_owner = 2
	state.world.tiles[6*1000+5] = rt
	var r := TeamData.new(); r.team_id = 2; r.faction_id = 0; r.tile_pos = Vector2i(6,5); r.tags = [TeamData.TAG_PRODUCE]
	AnonCohort.add(r.anon_cohorts, "平民", "healthy", 10); r.resources = {"food": 1.0}
	r.active_orders = [{"order_id": 700, "kind": "buy", "res": "food", "qty_remaining": 50, "expire_tick": 99999}]
	state.teams[2] = r
	# 人工塞 distress（resident food 買單）進領主 team_known（模擬 herald 已送達）
	var m := MessageData.new(); m.id = 0; m.type = "order_buy"; m.origin_team_id = 2; m.origin_tick = 1000; m.strength = 1.0
	m.params = {"order_id": 700, "res": "food", "qty": 50, "origin_team": 2, "origin_pos": Vector2i(6,5), "expire_tick": 99999}
	state.team_known[1] = [m]
	Probe.reset(); Probe.enabled = true
	var scored: Array = DecisionEngine.rank_scored(state, lord)
	Probe.enabled = false
	var d_rank: int = -1; var d_u: float = -999.0
	for i in range(scored.size()):
		if String(scored[i].get("opt","")) == "distribute_food": d_rank = i; d_u = float(scored[i]["u"]); break
	if d_rank == -1:
		print("  ⑥distribute candidate 未生成（distress 在領主 team_known 仍不 fire=另有 gate）")
	else:
		print("  ⑥★distress 塞領主 team_known → distribute candidate 生成 util=%.3f rank=%d/%d winner='%s'（證 distribute=0 下游於 herald 送達、非獨立第二關）" % [d_u, d_rank, scored.size(), String(scored[0].get("opt",""))])
