extends SceneTree

# 框架驗證套件 Part 2：每「魂」一個最小場景 → setup → 觸發 → 斷言 probe > 0。
# 目的 = 揭 dormant：場景真實觸發後仍 0 → print [DORMANT] Sx <probe>=0 並續跑（不 crash/不 fail run）。
# 純驗證腳本（禁改遊戲 state 邏輯，只程式建最小 fixture）。

var _results: Array = []   # [{id, probe, count, status}]

func _initialize() -> void:
	_run()
	quit()

func _run() -> void:
	print("=== framework_validation: 魂觸發場景套件 ===")
	Probe.enabled = true
	_scenario_S1_found()
	_scenario_S2_feud_vendetta()
	_scenario_S3_scout()
	_scenario_S4_ambush()
	_scenario_S5_mint()
	_scenario_S6_order()
	Probe.enabled = false
	_summary()
	print("=== framework_validation DONE ===")

# ──────── 共用 fixture helper ────────

func _new_state() -> WorldState:
	var s := WorldState.new()
	s.world = WorldData.new()
	s.player_id = -1
	return s

func _seed_pop(team: TeamData, n: int) -> void:
	var named_in: int = team.named_members.size() + (1 if team.leader_id != -1 else 0)
	var want_anon: int = maxi(n - named_in, 0)
	if want_anon > 0:
		AnonCohort.add(team.anon_cohorts, "平民", "healthy", want_anon)

func _tile(s: WorldState, pos: Vector2i) -> HexTileData:
	var key: int = pos.x * 1000 + pos.y
	var t: HexTileData = s.world.tiles.get(key)
	if t == null:
		t = HexTileData.new()
		t.tile_pos = pos
		t.terrain = "plains"
		s.world.tiles[key] = t
	return t

# 一塊小平原地（path/catch-up 需地存在）
func _fill_plains(s: WorldState, radius: int) -> void:
	for x in range(-radius, radius + 1):
		for y in range(-radius, radius + 1):
			_tile(s, Vector2i(x, y))

func _record(id: String, probe: String) -> void:
	var c: int = int(Probe.counts.get(probe, 0))
	var status: String = "PASS" if c > 0 else "DORMANT"
	_results.append({"id": id, "probe": probe, "count": c, "status": status})
	if c > 0:
		print("[%s] %s %s=%d" % [status, id, probe, c])
	else:
		print("[DORMANT] %s %s=0 (觸發後仍 0)" % [id, probe])

# ──────── S1 立國 ────────
# faction 未立國 + ≥2 member + leader 統領>=0.4 + 野心>=0.7 + readiness>=0.7 → 立國
func _scenario_S1_found() -> void:
	print("\n--- S1 立國 ---")
	Probe.reset()
	var s := _new_state()
	_fill_plains(s, 3)
	# faction leader 隊
	var leader_team := TeamData.new()
	leader_team.team_id = 0; leader_team.tile_pos = Vector2i(0, 0)
	leader_team.faction_id = 100; leader_team.readiness = 1.0
	var ldr := PersonData.new(); ldr.id = 1
	ldr.values["野心"] = 0.9; ldr.skills["統領"] = 0.7
	s.persons[1] = ldr; leader_team.leader_id = 1
	_seed_pop(leader_team, 10)
	leader_team.resources = {"food": 500.0, "material": 200.0}
	s.teams[0] = leader_team
	# 第二支 member 隊（立國需 >=2 member）
	var member := TeamData.new()
	member.team_id = 1; member.tile_pos = Vector2i(1, 0); member.faction_id = 100
	var m_ldr := PersonData.new(); m_ldr.id = 2; s.persons[2] = m_ldr; member.leader_id = 2
	_seed_pop(member, 5); member.resources = {"food": 200.0}
	s.teams[1] = member
	# faction
	var f := FactionData.new()
	f.faction_id = 100; f.leader_team_id = 0
	f.member_team_ids = [0, 1]; f.is_established = false
	s.factions[100] = f
	var fai := FactionAISystem.new()
	for i in 5:
		fai.evaluate_all(s, [0, 1])
		if int(Probe.counts.get("g2.faction_found", 0)) > 0: break
	_record("S1", "g2.faction_found")

# ──────── S2 feud + vendetta ────────
# 預置受害 leader（高義氣/好戰 → feud 形成）+ 仇敵；脫軌 leader（好戰>=.6 慎重<.4 feud>=.6）→ vendetta
func _scenario_S2_feud_vendetta() -> void:
	print("\n--- S2 feud + vendetta ---")
	Probe.reset()
	var s := _new_state()
	_fill_plains(s, 3)
	# 仇敵隊（perp）：弱小（避免被視為現役威脅 → threat@70 不搶先佔 task）
	var foe := TeamData.new(); foe.team_id = 0; foe.tile_pos = Vector2i(2, 0)
	var foe_ldr := PersonData.new(); foe_ldr.id = 1; foe_ldr.team_id = 0
	s.persons[1] = foe_ldr; foe.leader_id = 1; _seed_pop(foe, 3)
	foe.resources = {"food": 200.0}; s.teams[0] = foe
	# 脫軌者隊（victim/avenger）：好戰高 + 慎重低 → vendetta gate 過；隊大（power_ratio<1 → 弱敵非威脅）
	var avenger := TeamData.new(); avenger.team_id = 1; avenger.tile_pos = Vector2i(0, 0)
	avenger.faction_id = -1
	var av_ldr := PersonData.new(); av_ldr.id = 2; av_ldr.team_id = 1
	av_ldr.values = {"好戰": 0.9, "慎重": 0.2, "義氣": 0.9}
	s.persons[2] = av_ldr; avenger.leader_id = 2; _seed_pop(avenger, 30)
	avenger.resources = {"food": 300.0}; s.teams[1] = avenger
	# feud 形成（戰鬥事件等價：betrayal severity 0.8）→ g2.feud_formed
	NpcAiSystem.form_feud(av_ldr, 1, 0.8, 0)
	_record("S2a", "g2.feud_formed")
	# avenger 須能看到 foe（vendetta try_set TASK_ATTACK 需 foe team 存在；不需 belief）
	s.team_discovered[1] = [0]
	# 私人脫軌語意：foe 公開口碑佳(known_reputations=1.0 → hostility=0 → 不觸 threat@70)，
	# 但私下血仇驅 vendetta@55。否則 neutral rep(0.5) → threat 先佔 task 擋住 vendetta（設計優先序）。
	avenger.known_reputations[0] = 1.0
	# vendetta：evaluate_all per-team 迴圈 → vendetta_target → TASK_ATTACK@PRIO_VENDETTA
	var fai := FactionAISystem.new()
	for i in 5:
		fai.evaluate_all(s, [0, 1])
		if int(Probe.counts.get("g2.vendetta_trigger", 0)) > 0: break
	_record("S2b", "g2.vendetta_trigger")

# ──────── S3 scout ────────
# FORCE archetype + rung>=擴張 + attack_score>=.3 + readiness 過 + 有 prey belief
# + 情報不確定(單低 cred relay claim) + leader 慎重 → confident_enough 失敗 → 派斥候
func _scenario_S3_scout() -> void:
	print("\n--- S3 scout ---")
	Probe.reset()
	var s := _new_state()
	_fill_plains(s, 3)
	# 攻擊者隊
	var atk := TeamData.new(); atk.team_id = 0; atk.tile_pos = Vector2i(0, 0)
	atk.faction_id = -1
	atk.ambition_archetype = AmbitionLadder.ARCHETYPE_FORCE
	atk.ambition_rung = AmbitionLadder.RUNG_EXPAND
	atk.current_task = TeamData.TASK_IDLE
	var ldr := PersonData.new(); ldr.id = 1; ldr.team_id = 0
	# attack_score = 野心*.4+好戰*.4-信義*.4 = .36+.36-.04 = .68 >= .3
	# 慎重=.7 → confident threshold = lerp(0,.6,.7)=.42；readiness threshold≈.52
	ldr.values = {"野心": 0.9, "好戰": 0.9, "信義": 0.1, "慎重": 0.7, "貪婪": 0.7, "殘忍": 0.7}
	s.persons[1] = ldr; atk.leader_id = 1; _seed_pop(atk, 10)
	# readiness：pop10(1.0)+skill+food14d+weapon>=pop → 足夠過 .52
	atk.resources = {"food": 99999.0, "weapon_melee_low": 20.0}
	s.teams[0] = atk
	# prey 隊（鄰格 → border + reachable）
	var prey := TeamData.new(); prey.team_id = 1; prey.tile_pos = Vector2i(1, 0)
	prey.faction_id = -1
	var p_ldr := PersonData.new(); p_ldr.id = 2; s.persons[2] = p_ldr; prey.leader_id = 2
	_seed_pop(prey, 5); prey.resources = {"food": 100.0, "coin": 200.0}; s.teams[1] = prey
	# 攻擊者已發現 prey（find_prey/catch_up 需 team_discovered）
	s.team_discovered[0] = [1]
	# belief：單一低可信度 relay claim（非親見）→ uncertainty 高 → confident_enough 失敗
	BeliefSystem.record_claim(s, 0, 1, 99, "流民",
		{"population_est": 5.0, "armed_est": 2.0, "tile_pos": Vector2i(1, 0), "coin_est": 200.0},
		0.3, false)
	var fai := FactionAISystem.new()
	for i in 3:
		atk.prosperity_eval_next_tick = 0   # 強制每輪重評
		fai.evaluate_all(s, [0, 1])
		if int(Probe.counts.get("g3.scout_dispatch", 0)) > 0: break
	_record("S3", "g3.scout_dispatch")

# ──────── S4 ambush ────────
# g3.ambush 既有 probe = Probe.ambush_check（encounter 敗方=攻方時呼）。
# 場景：攻方對守方武力嚴重低估(belief armed << 真 pop*0.5) → ambush_check 判定誤導 → bump。
func _scenario_S4_ambush() -> void:
	print("\n--- S4 ambush ---")
	Probe.reset()
	var s := _new_state()
	_fill_plains(s, 2)
	var atk := TeamData.new(); atk.team_id = 0; atk.tile_pos = Vector2i(0, 0)
	s.teams[0] = atk
	# 守方真實 pop 大（偽裝 = belief 嚴重低報）
	var defender := TeamData.new(); defender.team_id = 1; defender.tile_pos = Vector2i(0, 0)
	_seed_pop(defender, 20); s.teams[1] = defender
	# 攻方 belief：armed_est=2 << 真 pop20*0.5=10 → underest → ambush
	s.team_discovered[0] = [1]
	BeliefSystem.record_claim(s, 0, 1, 99, "流民",
		{"population_est": 4.0, "armed_est": 2.0, "tile_pos": Vector2i(0, 0)},
		0.5, true)
	# encounter 結算敗方=攻方時呼此 check（這裡直呼觀測點，誘殺驗證脊椎）
	Probe.ambush_check(s, 0, 1)
	_record("S4", "g3.ambush")

# ──────── S5 mint（真礦村迴路）────────
# 含礦山 civilian outpost + PRODUCE 隊 + bootstrap 糧 + material/tools
# → collect 採 ore → vault ore>10 → _pick_facility 選 mint → 建造 → _tick_mint 鑄幣
func _scenario_S5_mint() -> void:
	print("\n--- S5 mint (真礦村迴路) ---")
	Probe.reset()
	var s := _new_state()
	var pos := Vector2i(2, 0)
	# 含金礦山地 tile
	var tile := _tile(s, pos)
	tile.terrain = "mountain"
	tile.productivity = 0.7
	tile.resources["ore_gold"] = 50.0; tile.resource_cap["ore_gold"] = 50.0
	# civilian outpost L1
	tile.outpost_type = "civilian"; tile.outpost_level = 1
	# 預種足夠 ore 進 vault 讓 _pick_facility 即時通過 mint deficit gate
	tile.public_storage["ore_gold"] = 20.0
	# PRODUCE 駐留隊 + 貪婪 leader
	var team := TeamData.new(); team.team_id = 0; team.tile_pos = pos
	team.tags = [TeamData.TAG_PRODUCE]
	var ldr := PersonData.new(); ldr.id = 1; ldr.values["貪婪"] = 0.8; ldr.values["野心"] = 0.6
	s.persons[1] = ldr; team.leader_id = 1
	_seed_pop(team, 10)
	team.resources = {"food": 500.0, "material": 200.0, "tools": 20.0}
	s.teams[0] = team
	tile.outpost_owner = team.team_id
	# 建立 faction（讓 _evaluate_infrastructure 能用 faction.leader_team_id）
	var f := FactionData.new(); f.faction_id = 0
	f.leader_team_id = 0; f.member_team_ids = [0]
	s.factions[0] = f; team.faction_id = 0
	# 跑真迴路：collect→pick_facility→build→mint
	var runner := SimRunner.new()
	for _i in range(3000):
		runner.advance_tick(s, pos)
		if int(Probe.counts.get("g1.mint", 0)) > 0: break
	_record("S5", "g1.mint")

# ──────── S6 經濟閉環 ────────
# 賣家發 sell 單 + 商隊買家 co-located 市集 → _resolve_market 沖銷 sell 單 → order_fulfilled
func _scenario_S6_order() -> void:
	print("\n--- S6 order_fulfilled (經濟閉環) ---")
	Probe.reset()
	var s := _new_state()
	var pos := Vector2i(3, 3)
	var tile := _tile(s, pos)
	tile.outpost_owner = 0; tile.outpost_level = 1; tile.outpost_type = "civilian"
	# 定居賣家：surplus goods + 自家 outpost 市集
	var seller := TeamData.new(); seller.team_id = 0; seller.tile_pos = pos
	var s_ldr := PersonData.new(); s_ldr.id = 1; s.persons[1] = s_ldr; seller.leader_id = 1
	_seed_pop(seller, 5); seller.resources = {"goods": 200.0, "coin": 50.0}
	s.teams[0] = seller
	# 商隊買家：缺 goods + 有 coin + 已抵市集（co-locate）
	var buyer := TeamData.new(); buyer.team_id = 1; buyer.tags = [TeamData.TAG_MERCHANT]
	buyer.tile_pos = pos; buyer.faction_id = -1
	buyer.ambition_archetype = AmbitionLadder.ARCHETYPE_TRADE
	var b_ldr := PersonData.new(); b_ldr.id = 2; s.persons[2] = b_ldr; buyer.leader_id = 2
	_seed_pop(buyer, 5); buyer.resources = {"goods": 0.0, "coin": 500.0}
	s.teams[1] = buyer
	# 賣家發 sell 單（qty <= 成交量 → 整單沖銷 fulfilled）
	var os := OrderSystem.new()
	os.post_order(s, seller, "sell", "goods", 30)
	# co-locate 成交（含 settle_orders 沖 sell 單）
	var inter := InteractionSystem.new()
	inter._resolve_market(s, seller, buyer)
	_record("S6", "g1.order_fulfilled")

# ──────── 彙整報表 ────────

func _summary() -> void:
	print("\n========== [Part2 魂觸發報表] ==========")
	var pass_n := 0
	var dormant_n := 0
	for r in _results:
		print("  %-5s %-22s = %-3d  [%s]" % [r["id"], r["probe"], r["count"], r["status"]])
		if r["status"] == "PASS": pass_n += 1
		else: dormant_n += 1
	print("  --- PASS=%d  DORMANT=%d ---" % [pass_n, dormant_n])
	print("=======================================")
