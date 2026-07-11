extends SceneTree

# consolidation 指標團決策 trace（blueprint 要「真團怎麼想」，非聚合數字）。
# pattern 仿 buyfood_measure.gd：手構 WorldState + 團 + belief，呼叫 DecisionContext.gather +
# DecisionEngine.rank_scored，dump 每個 applicable option 的 util，看首選為何、輸贏差多少。
# 純量測，不改邏輯。

func _initialize() -> void:
	_run(); quit()

func _new_state() -> WorldState:
	var s := WorldState.new(); s.world = WorldData.new(); s.player_id = -1
	return s

func _tile(s: WorldState, pos: Vector2i) -> HexTileData:
	var key: int = pos.x * 1000 + pos.y
	if not s.world.tiles.has(key):
		var t := HexTileData.new(); t.tile_pos = pos; t.terrain = "plains"
		s.world.tiles[key] = t
	return s.world.tiles[key]

func _fill(s: WorldState, r: int) -> void:
	for x in range(-r, r + 1):
		for y in range(-r, r + 1):
			_tile(s, Vector2i(x, y))

func _mk_leader(s: WorldState, pid: int, values: Dictionary, skills: Dictionary) -> void:
	var p := PersonData.new(); p.id = pid
	p.values = values; p.skills = skills
	s.persons[pid] = p

func _mk_team(s: WorldState, tid: int, leader_id: int, pop: int, pos: Vector2i,
		food_days_hint: float = 20.0, faction_id: int = -1) -> TeamData:
	var t := TeamData.new()
	t.team_id = tid; t.leader_id = leader_id; t.tile_pos = pos; t.faction_id = faction_id
	var named: int = 1 if leader_id != -1 else 0
	if pop - named > 0:
		AnonCohort.add(t.anon_cohorts, "平民", "healthy", pop - named)
	# food_days_hint 換算成 resources.food（effective_food/pop/FOOD_PER_PERSON_PER_DAY≈food_days）
	t.resources = {"food": food_days_hint * float(pop) * ResourceSystem.FOOD_PER_PERSON_PER_DAY,
		"coin": 0.0, "goods": 0.0, "material": 0.0}
	s.teams[tid] = t
	return t

func _link_belief(s: WorldState, obs_id: int, tgt_id: int, pop_est: float, food_est: float, armed_est: float) -> void:
	if not s.team_discovered.has(obs_id): s.team_discovered[obs_id] = []
	s.team_discovered[obs_id].append(tgt_id)
	if not s.team_intel.has(obs_id): s.team_intel[obs_id] = {}
	s.team_intel[obs_id][tgt_id] = {"population_est": pop_est, "food_est": food_est,
		"armed_est": armed_est, "last_tick": 0, "confidence": 1.0}

func _dump(s: WorldState, team: TeamData, label: String) -> void:
	var ctx := DecisionContext.gather(s, team)
	print("\n========== %s (Team%d) ==========" % [label, team.team_id])
	var ldr: PersonData = s.persons.get(team.leader_id)
	var v: Dictionary = ldr.values if ldr != null else {}
	print("  領袖: 野心=%.2f 好戰=%.2f 殘忍=%.2f(仁慈=%.2f) 慎重=%.2f 統領=%.2f" % [
		float(v.get("野心", 0.5)), float(v.get("好戰", 0.5)), float(v.get("殘忍", 0.5)),
		1.0 - float(v.get("殘忍", 0.5)), float(v.get("慎重", 0.5)),
		float(ldr.skills.get("統領", 0.0)) if ldr != null else 0.0])
	print("  ctx: food_days=%.2f intent=%s intent_target=%d absorb_target=%d(slack=%.2f yield=%.2f) consolidate_target=%d has_weak_prey=%s has_strong_neighbor=%s ctx.threat(併入gate用)=%.2f/thr=%.2f threat_react(迎戰/備戰用)=%.2f" % [
		ctx.food_days, ctx.intent, ctx.intent_target, ctx.absorb_target_id, ctx.resource_slack, ctx.absorb_yield,
		ctx.consolidate_target_id, ctx.has_weak_prey, ctx.has_strong_neighbor, ctx.threat, ctx.threat_threshold, ctx.threat_react])
	var scored: Array = DecisionEngine.rank_scored(s, team)
	print("  --- ranked options (util 降序) ---")
	for e in scored:
		print("    %-10s util=%.4f" % [e["opt"], e["u"]])
	print("  首選 = %s" % (String(scored[0]["opt"]) if scored.size() > 0 else "(空)"))
	if scored.size() >= 2:
		print("  首選-次選差距 = %.4f" % (float(scored[0]["u"]) - float(scored[1]["u"])))

func _run() -> void:
	print("=== consolidation 決策 trace（blueprint 要真團思考記錄）===")

	# ── 強隊 A：高好戰/高殘忍(低仁慈)/高野心，征服 intent，有 absorb target 也是 weak_prey ──
	var sA := _new_state(); _fill(sA, 3)
	_mk_leader(sA, 1, {"野心": 0.75, "好戰": 0.8, "殘忍": 0.75, "慎重": 0.3, "義氣": 0.5}, {"統領": 0.8, "戰術": 0.3})
	var teamA := _mk_team(sA, 0, 1, 15, Vector2i(0, 0), 20.0)
	teamA.solo_intent = {"type": "征服"}
	teamA.ambition_archetype = "武力"
	teamA.armed_anon_ratio = 0.8
	AnonCohort.add(teamA.anon_cohorts, "菁英", "healthy", 5)   # 真有戰力才不被 capability gate 壓平
	_mk_leader(sA, 2, {"殘忍": 0.5}, {})
	_mk_team(sA, 1, 2, 8, Vector2i(0, 0), 10.0)   # 弱鄰（同時是 absorb target 與 weak_prey 候選，純平民=真弱）
	_link_belief(sA, 0, 1, 8.0, 10.0, 0.5)
	_dump(sA, teamA, "強隊A：高好戰/高殘忍/征服intent（測 absorb vs 攻擊 誰贏）")

	# ── 強隊 B：低好戰/低殘忍(高仁慈)、同野心、同弱鄰 ──
	var sB := _new_state(); _fill(sB, 3)
	_mk_leader(sB, 1, {"野心": 0.75, "好戰": 0.15, "殘忍": 0.1, "慎重": 0.5, "義氣": 0.5}, {"統領": 0.8, "戰術": 0.3})
	var teamB := _mk_team(sB, 0, 1, 15, Vector2i(0, 0), 20.0)
	teamB.solo_intent = {"type": "征服"}   # 即便好戰低，intent 若仍標征服（測 intent_fit capability/仁慈壓低攻擊 util 後誰接手）
	teamB.ambition_archetype = "武力"
	teamB.armed_anon_ratio = 0.8
	AnonCohort.add(teamB.anon_cohorts, "菁英", "healthy", 5)
	_mk_leader(sB, 2, {"殘忍": 0.5}, {})
	_mk_team(sB, 1, 2, 8, Vector2i(0, 0), 10.0)
	_link_belief(sB, 0, 1, 8.0, 10.0, 0.5)
	_dump(sB, teamB, "強隊B：低好戰/高仁慈、同弱鄰（測「仁慈保護型」是否真選吸納，還是兩頭皆輸躲去別的option）")

	# ── 弱隊 C：絕境（food<3），無強鄰，pop 夠小可覓食 ──
	var sC := _new_state(); _fill(sC, 3)
	_mk_leader(sC, 1, {"求生欲": 0.7, "慎重": 0.5}, {"統領": 0.3})
	var teamC := _mk_team(sC, 0, 1, 10, Vector2i(0, 0), 1.5)   # food_days=1.5 絕境
	_dump(sC, teamC, "弱隊C：絕境無強鄰（測覓食 vs 併入 vs 乞食 誰贏——併入需 faction member 身分,本隊獨立故 consolidate_target 恆-1，觀察是否走覓食）")

	# ── 弱隊 D：faction member，絕境（food<3），有 leader 可併入 ──
	var sD := _new_state(); _fill(sD, 3)
	_mk_leader(sD, 10, {"野心": 0.5, "求生欲": 0.7}, {"統領": 0.9})   # faction leader（absorber 候選）
	var leaderTeam := _mk_team(sD, 100, 10, 20, Vector2i(0, 0), 15.0, 1)
	_mk_leader(sD, 11, {"求生欲": 0.8, "慎重": 0.4}, {"統領": 0.2})
	var teamD := _mk_team(sD, 101, 11, 2, Vector2i(2, 0), 1.5, 1)   # member，絕境，距 leader 2格；pop=2 嚴格 < int(cap13*0.3)=3 才觸發 small_b
	var fac := FactionData.new(); fac.faction_id = 1; fac.leader_team_id = 100
	fac.member_team_ids = [100, 101]
	sD.factions[1] = fac
	_link_belief(sD, 101, 100, 20.0, 15.0, 5.0)   # member 對自家 leader 也要 belief/reachable 才選得到（同陌生finder）
	var _dbg_absorber: int = FactionAISystem.new()._find_absorber(sD, teamD, fac)
	print("  [debug] _find_absorber(teamD,fac) = %d (leaderTeam=100)" % _dbg_absorber)
	var _dbg_ct: int = FactionAISystem.consolidate_target_of(sD, teamD, fac)
	print("  [debug] consolidate_target_of(teamD,fac) = %d" % _dbg_ct)
	_dump(sD, teamD, "弱隊D：faction member 絕境，同 faction leader 可併入（補 belief link 後測併入是否真 fire）")

	# ── 弱隊 E：faction member，food 夠（非絕境），但有打不過的外部強鄰（測「謹慎投靠」ungate 是否 fire） ──
	var sE := _new_state(); _fill(sE, 3)
	_mk_leader(sE, 10, {"野心": 0.5, "求生欲": 0.7}, {"統領": 0.9})
	_mk_team(sE, 100, 10, 20, Vector2i(0, 0), 15.0, 1)
	_mk_leader(sE, 11, {"求生欲": 0.8, "慎重": 0.7}, {"統領": 0.2})
	var teamE := _mk_team(sE, 101, 11, 2, Vector2i(2, 0), 10.0, 1)   # 同 D 位置/pop，但 food 夠(10天,非絕境)
	var facE := FactionData.new(); facE.faction_id = 1; facE.leader_team_id = 100
	facE.member_team_ids = [100, 101]
	sE.factions[1] = facE
	# 外部強鄰（非本 faction）：pop 大、reputation 中性→視為威脅
	_mk_leader(sE, 20, {"殘忍": 0.6}, {"統領": 0.9})
	_mk_team(sE, 200, 20, 40, Vector2i(3, 0), 20.0, -1)
	_link_belief(sE, 101, 200, 40.0, 20.0, 15.0)   # teamE 對外部強鄰有 belief(打不過)
	# 兩道 reputation 閘交集：ctx.threat(併入gate)需 rep<0.5(neutral)；has_strong_neighbor 需 rep>0.3（已公開翻臉的不算「強鄰」，只算「還沒但打不過」）→ 用 0.4 同時滿足。
	teamE.known_reputations[200] = 0.4
	_dump(sE, teamE, "弱隊E：faction member food夠(非絕境)+外部強鄰打不過（測謹慎投靠 ungate 是否 fire）")

	print("\n=== consolidation 決策 trace DONE ===")
