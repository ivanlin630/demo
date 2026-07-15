extends SceneTree

# 統一生產框架 v2 TDD（feat/production-framework）
# spec: docs/superpowers/specs/2026-07-16-unified-production-framework.md
# S1 製造 precondition 規則 + no-op tap。S2 survival-crush + granary seam。S3 means-end 獨立隊。S4 de-patch。

var _fail: int = 0

func _initialize() -> void:
	_test_s1_has_facility_gate()
	_test_s1_produce_applicable()
	_test_s2_gate_hungry_farming_wins()
	_test_s2_granary_seam()
	_test_s4_pick_facility_no_override()
	_test_s4_mining_personality()
	if _fail == 0:
		print("=== DONE === ALL PASS")
	else:
		print("=== DONE === %d FAIL" % _fail)
	quit()

func _ok(cond: bool, msg: String) -> void:
	if cond: print("  [PASS] %s" % msg)
	else: _fail += 1; print("  [FAIL] %s" % msg)

func _mk_state() -> WorldState:
	var s := WorldState.new(); s.world = WorldData.new(); s.world.current_tick = 0
	return s

# 據點 tile（可設 manufacturing_level 等製造設施）。
func _mk_tile(s: WorldState, pos: Vector2i, owner: int, workshop: int = 0) -> HexTileData:
	var t := HexTileData.new()
	t.tile_pos = pos; t.outpost_level = 1; t.outpost_owner = owner; t.outpost_type = "civilian"
	t.manufacturing_level = workshop
	s.world.tiles[pos.x * 1000 + pos.y] = t
	return t

func _mk_team(s: WorldState, tid: int, pos: Vector2i) -> TeamData:
	var t := TeamData.new(); t.team_id = tid; t.tile_pos = pos
	var ldr := PersonData.new(); ldr.id = tid * 10; s.persons[ldr.id] = ldr; t.leader_id = ldr.id
	t.named_members.append(tid * 10 + 1)
	s.teams[tid] = t
	return t

# ── S1：has_manufacturing_facility 規則（本格製造設施 + 生產權）──
func _test_s1_has_facility_gate() -> void:
	print("--- S1：has_manufacturing_facility 規則 ---")
	var s := _mk_state()
	var team := _mk_team(s, 1, Vector2i(0, 0))
	# 無設施 outpost → false
	_mk_tile(s, Vector2i(0, 0), 1, 0)
	_ok(not FactionAISystem.has_manufacturing_facility(s, team), "無製造設施→false（A2 補缺，不選製造空轉）")
	# 有 workshop → true
	s.world.tiles[0].manufacturing_level = 1
	_ok(FactionAISystem.has_manufacturing_facility(s, team), "有 workshop→true（可製造）")
	# 別團 outpost 非同 faction → false（無生產權）
	var s2 := _mk_state()
	var t2 := _mk_team(s2, 1, Vector2i(0, 0)); t2.faction_id = -1
	_mk_tile(s2, Vector2i(0, 0), 99, 1)   # owner=99 別團, 有 workshop
	_ok(not FactionAISystem.has_manufacturing_facility(s2, t2), "別團 outpost 無生產權→false")

# ── S1：「生產」applicable 補 precondition（無設施→濾 + kill probe）──
func _test_s1_produce_applicable() -> void:
	print("--- S1：生產 applicable precondition ---")
	Probe.enabled = true; Probe.reset()
	var s := _mk_state()
	var team := _mk_team(s, 1, Vector2i(0, 0))
	_mk_tile(s, Vector2i(0, 0), 1, 0)   # 有據點無設施
	var ctx := DecisionContext.gather(s, team)
	_ok(ctx.has_own_outpost, "has_own_outpost=true（有據點）")
	_ok(not ctx.has_manufacturing_facility, "has_manufacturing_facility=false（無設施）")
	var opts: Array = DecisionOptions.applicable(ctx)
	_ok(not ("生產" in opts), "★無設施→「生產」被濾（不空轉 no-op）")
	_ok("駐守" in opts, "「駐守」仍 applicable（只需據點）")
	_ok(int(Probe.counts.get("produce.appl_kill_nofacility", 0)) > 0, "★kill probe 動（A2 主病可觀測=%d）" % int(Probe.counts.get("produce.appl_kill_nofacility", 0)))
	# 有設施 → 生產 applicable
	s.world.tiles[0].manufacturing_level = 1
	var ctx2 := DecisionContext.gather(s, team)
	var opts2: Array = DecisionOptions.applicable(ctx2)
	_ok("生產" in opts2, "有設施→「生產」applicable")
	Probe.enabled = false

# ── ★S2 GATE（硬性）：餓隊 farming score 主導可耕地（直答 R① 駁表，S4 拆 override 前提）──
func _test_s2_gate_hungry_farming_wins() -> void:
	print("--- ★S2 GATE：餓隊 farming score > workshop（拆 override 前提）---")
	var s := _mk_state()
	# civilian tile harvest 1.0（farming terrain fit 1.0）；鄰森林（workshop terrain fit 2.0）
	var tile := _mk_tile(s, Vector2i(0, 0), 1, 0)
	tile.terrain = "plains"; tile.harvest_factor = 1.0
	for d in PathSystem.HEX_DIRS:   # 6 鄰放森林 → workshop terrain fit=2.0
		var np: Vector2i = Vector2i(0, 0) + d
		var ft := HexTileData.new(); ft.tile_pos = np; ft.terrain = "forest"
		s.world.tiles[np.x * 1000 + np.y] = ft
	# 中性人格領袖（R① 駁表基準）+ 餓（據點局部糧=0）
	var team := _mk_team(s, 1, Vector2i(0, 0))
	team.resources = {"food": 0.0}
	var leader: PersonData = s.persons[team.leader_id]
	leader.values = {"慎重": 0.5, "貪婪": 0.5, "野心": 0.5, "好戰": 0.5}
	var fai := FactionAISystem.new()
	var farm_s: float = fai._facility_score(s, team, tile, leader, "farming")
	var work_s: float = fai._facility_score(s, team, tile, leader, "workshop")
	_ok(farm_s > work_s, "★★餓隊 farming(%.2f) > workshop(%.2f)（survival-crush 保底，override 可拆）" % [farm_s, work_s])
	# 飽足時 workshop 該回歸領先（軟連續非鎖死 farming）
	team.resources = {"food": 1000.0}   # 據點局部糧充足→urgency≈0
	var farm_fed: float = fai._facility_score(s, team, tile, leader, "farming")
	var work_fed: float = fai._facility_score(s, team, tile, leader, "workshop")
	_ok(work_fed > farm_fed, "飽足時 workshop(%.2f) > farming(%.2f)（軟連續，非永鎖農）" % [work_fed, farm_fed])

# ── S2 granary seam：facility food_days 讀據點局部（糧倉），非 positional effective_food ──
func _test_s2_granary_seam() -> void:
	print("--- S2 granary seam：facility 食安讀據點局部糧倉 ---")
	var s := _mk_state()
	var tile := _mk_tile(s, Vector2i(0, 0), 1, 0)
	tile.public_storage = {"food": 400.0}   # 糧倉滿（但 team.resources food=0）
	var team := _mk_team(s, 1, Vector2i(0, 0))
	team.resources = {"food": 0.0}   # 私產空（定居隊糧在糧倉）
	var fai := FactionAISystem.new()
	var fdays: float = fai._facility_food_days(s, team, tile)
	# pop=2(leader+1 named)，burn=2×0.8=1.6，(400+0)/1.6=250 天 → 不餓（讀糧倉非私產）
	_ok(fdays > 50.0, "★據點糧倉 food 算進 food_days(%.0f 天)——不誤判定居隊餓（granary seam）" % fdays)
	var leader: PersonData = s.persons[team.leader_id]
	leader.values = {"慎重": 0.5}
	var urg: float = fai._facility_food_urgency(s, team, tile, leader)
	_ok(urg < 0.01, "糧倉滿→urgency≈0(%.2f)，不觸 survival-crush（不誤判餓）" % urg)

# ── S4：_pick_facility 無 override，餓隊經 score 選 farming、飽隊選 workshop ──
func _test_s4_pick_facility_no_override() -> void:
	print("--- S4：_pick_facility 無 override（score 驅動）---")
	var s := _mk_state()
	var tile := _mk_tile(s, Vector2i(0, 0), 1, 0)
	tile.terrain = "plains"; tile.harvest_factor = 1.0
	for d in PathSystem.HEX_DIRS:
		var np: Vector2i = Vector2i(0, 0) + d
		var ft := HexTileData.new(); ft.tile_pos = np; ft.terrain = "forest"
		s.world.tiles[np.x * 1000 + np.y] = ft
	var team := _mk_team(s, 1, Vector2i(0, 0))
	var leader: PersonData = s.persons[team.leader_id]
	leader.values = {"慎重": 0.5, "貪婪": 0.5, "野心": 0.5, "好戰": 0.5}
	var fai := FactionAISystem.new()
	# 餓 → farming（survival-crush 經 score 勝出，非 override）
	team.resources = {"food": 0.0}
	var pick_hungry: Dictionary = fai._pick_facility(s, team, tile, leader)
	_ok(pick_hungry.get("facility", "") == "farming", "★餓隊 _pick_facility→farming（score 驅動非 override，實際=%s）" % pick_hungry.get("facility", ""))
	# 飽 → workshop（發展）
	team.resources = {"food": 1000.0}
	var pick_fed: Dictionary = fai._pick_facility(s, team, tile, leader)
	_ok(pick_fed.get("facility", "") == "workshop", "飽隊 _pick_facility→workshop（發展，實際=%s）" % pick_fed.get("facility", ""))

# ── S4.4：礦山 outpost type 走人格秤（非硬 civilian override）──
func _test_s4_mining_personality() -> void:
	print("--- S4.4：礦山 outpost type 人格秤（非硬 override）---")
	var s := _mk_state()
	var lt := HexTileData.new(); lt.tile_pos = Vector2i(5, 5); lt.terrain = "mountain"
	lt.resource_cap = {"ore_gold": 100.0}
	var lteam := _mk_team(s, 1, Vector2i(0, 0)); lteam.resources = {"tools": 10.0}   # 有 tools→可軍鎮
	# 貪婪領袖 + 礦 → civilian（採礦村）
	var greedy: PersonData = s.persons[lteam.leader_id]
	greedy.values = {"貪婪": 1.0, "慎重": 0.5, "好戰": 0.1, "野心": 0.1}
	var fai := FactionAISystem.new()
	_ok(fai._pick_outpost_type(s, lteam, greedy, lt) == "civilian", "貪婪領袖+礦→civilian（採礦村，人格秤）")
	# 好戰領袖 + 礦 → 仍可 military（非硬 override 鎖 civilian）
	greedy.values = {"貪婪": 0.1, "慎重": 0.1, "好戰": 1.0, "野心": 1.0}
	_ok(fai._pick_outpost_type(s, lteam, greedy, lt) == "military", "★好戰領袖+礦→仍可 military（非硬 override 鎖死）")
