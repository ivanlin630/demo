extends SceneTree

# tap-gap fix TDD：4 faction-leave 出口 Probe tap 真 fire（構 defection/uprising 場景→counter 非零）。
# 純觀測 tap、零行為變（Probe.bump 不耗 RNG）。

var _fail: int = 0
func _ok(c: bool, m: String) -> void:
	if c: print("  [PASS] %s" % m)
	else: _fail += 1; print("  [FAIL] %s" % m)

# 建 faction 成員隊（有領主）。faction 有領主隊 lord=Team99（不同隊）。
func _mk(vals: Dictionary) -> Array:
	var state := WorldState.new(); state.world = WorldData.new(); state.world.current_tick = 100000
	var fac := FactionData.new(); fac.faction_id = 0; fac.leader_team_id = 99; fac.member_team_ids = [99, 1]; state.factions[0] = fac
	var lord := TeamData.new(); lord.team_id = 99; lord.faction_id = 0; lord.tile_pos = Vector2i(0,0); state.teams[99] = lord
	var t := TeamData.new(); t.team_id = 1; t.faction_id = 0; t.tile_pos = Vector2i(5,5)
	var lp := PersonData.new(); lp.id = 11; lp.values = vals; state.persons[11] = lp; t.leader_id = 11
	state.teams[1] = t
	return [state, t]

func _initialize() -> void:
	var fai := FactionAISystem.new()

	print("=== defection path C 獨立 → defection.independent ===")
	var c := _mk({"義氣": 0.1, "慎重": 0.1, "野心": 0.9})   # c_score(野心)最高
	Probe.reset(); Probe.enabled = true
	fai._trigger_defection_evaluation(c[0], c[1], "test")
	Probe.enabled = false
	_ok(int(Probe.counts.get("defection.independent", 0)) == 1 and (c[1] as TeamData).faction_id == -1,
		"path C 獨立 → defection.independent tap fire + 脫 faction")

	print("=== defection path B 投降 fail → defection.surrender_fail ===")
	var b := _mk({"義氣": 0.2, "慎重": 0.9, "野心": 0.2})   # b_score(慎重)最高、無強鄰→fail
	Probe.reset(); Probe.enabled = true
	fai._trigger_defection_evaluation(b[0], b[1], "test")
	Probe.enabled = false
	_ok(int(Probe.counts.get("defection.surrender_fail", 0)) == 1 and (b[1] as TeamData).faction_id == -1,
		"path B 投降強鄰 fail(無強鄰)→ defection.surrender_fail tap fire + 脫 faction")

	# uprising 場景：resident(PRODUCE+自 outpost) + avg_loy<0.2 + unrest≥60 + stress≥2。
	print("=== uprising secede → uprising.secede ===")
	var us := _mk_uprising({"野心": 0.9, "慎重": 0.5, "義氣": 0.1, "求生欲": 0.1})   # stand + secede_u>stay_u
	Probe.reset(); Probe.enabled = true
	fai._evaluate_uprising(us[0], us[1])
	Probe.enabled = false
	_ok(int(Probe.counts.get("uprising.secede", 0)) == 1, "起義守城自立 → uprising.secede tap fire")

	print("=== uprising exile → uprising.exile ===")
	var ue := _mk_uprising({"野心": 0.1, "慎重": 0.1, "義氣": 0.1, "求生欲": 0.9})   # flee(求生高)→exile
	Probe.reset(); Probe.enabled = true
	fai._evaluate_uprising(ue[0], ue[1])
	Probe.enabled = false
	_ok(int(Probe.counts.get("uprising.exile", 0)) == 1, "起義流亡 → uprising.exile tap fire")

	if _fail == 0: print("=== DONE === ALL PASS")
	else: print("=== DONE === %d FAIL" % _fail)
	quit()

# 起義場景 fixture：resident 團 + 崩潰態（低忠誠/高 unrest/多 stress 源）。
func _mk_uprising(vals: Dictionary) -> Array:
	var a := _mk(vals)
	var state: WorldState = a[0]; var t: TeamData = a[1]
	t.tags = [TeamData.TAG_PRODUCE]
	t.unrest_turns = 60          # ≥60 + >40（stress 源①）
	t.tax_rate = 0.6             # >0.5（stress 源②）
	AnonCohort.add(t.anon_cohorts, "平民", "healthy", 5)   # food 0 < pop×7（stress 源③冗餘）
	(state.persons[11] as PersonData).loyalty = 0.1   # avg_named_loyalty<0.2（僅 leader）
	var tile := HexTileData.new(); tile.tile_pos = Vector2i(5,5); tile.terrain = "plains"
	tile.outpost_level = 1; tile.outpost_owner = 1   # 自 outpost → resident
	state.world.tiles[5005] = tile
	return [state, t]
