extends SceneTree

# care-loop scout de-patch TDD（spec 2026-08-08）：_dispatch_care_scout vpos 三層 fallback（補第三層 roster）。
# 破 silent-return execution-break：belief/last_known 皆空時、領主憑 roster(own-faction outpost 位、position-only 非 god-view)派 scout。

var _fail: int = 0
func _ok(c: bool, m: String) -> void:
	if c: print("  [PASS] %s" % m)
	else: _fail += 1; print("  [FAIL] %s" % m)

# 建 lord(faction leader、pop>=2)+own-faction 村(有/無 outpost 依參)+holding ledger entry(無 belief/last_known)。
func _mk(village_has_outpost: bool, village_faction: int = 0) -> Array:
	var state := WorldState.new(); state.world = WorldData.new(); state.world.current_tick = 100000
	var fac := FactionData.new(); fac.faction_id = 0; fac.leader_team_id = 1; state.factions[0] = fac
	var lord := TeamData.new(); lord.team_id = 1; lord.faction_id = 0; lord.tile_pos = Vector2i(0,0)
	AnonCohort.add(lord.anon_cohorts, "平民", "healthy", 6)
	var ll := PersonData.new(); ll.id = 11; ll.values = {"義氣": 0.7}; state.persons[11] = ll; lord.leader_id = 11
	var adv := PersonData.new(); adv.id = 12; adv.values = {}; state.persons[12] = adv; lord.named_members = [11, 12]
	# holding ledger entry for vid=9、★無 last_known_pos（強制走 belief→roster）
	lord.dispatch_ledger.append({"kind": "holding", "subject_ref": 9, "is_team": true,
		"dispatched_tick": 90000, "expected_return_tick": 91000, "resolved": false})
	state.teams[1] = lord
	var v := TeamData.new(); v.team_id = 9; v.faction_id = village_faction; v.tile_pos = Vector2i(5,5)
	AnonCohort.add(v.anon_cohorts, "平民", "healthy", 3); state.teams[9] = v
	if village_has_outpost:
		var vt := HexTileData.new(); vt.tile_pos = Vector2i(5,5); vt.terrain = "plains"; vt.outpost_level = 1; vt.outpost_owner = 9; vt.outpost_type = "civilian"
		state.world.tiles[5005] = vt
	# ★無 belief claim for vid=9（best_estimate 無 tile_pos）+ entry 無 last_known_pos → vpos 前兩層皆 (-1,-1)。
	return [state, lord, lord.dispatch_ledger[0]]

func _initialize() -> void:
	# ①roster fallback：belief/last_known 空 + own-faction 村有 outpost → 第三層 roster (5,5) → scout 真派。
	var a := _mk(true, 0)
	Probe.reset(); Probe.enabled = true
	FactionAISystem.new()._dispatch_care_scout(a[0], a[1], a[2])
	Probe.enabled = false
	_ok(int(Probe.counts.get("care.scout_dispatched", 0)) == 1,
		"belief/last_known 空 + own-faction 村有 outpost → 第三層 roster fallback → scout 真派(care.scout_dispatched=1、破 silent-return)")

	# ②無 roster 仍 silent：村無 outpost（roster→-1）→ 三層皆空 → 不派（silent-return 保、感知鐵律不瞎派）。
	var b := _mk(false, 0)
	Probe.reset(); Probe.enabled = true
	FactionAISystem.new()._dispatch_care_scout(b[0], b[1], b[2])
	Probe.enabled = false
	_ok(int(Probe.counts.get("care.scout_dispatched", 0)) == 0,
		"村無 outpost(roster→-1)→三層皆空→silent-return 保(不瞎派、感知鐵律)")

	# ③own-faction only：村他勢力(faction 1)→roster→-1→silent（不跨勢力查）。
	var c := _mk(true, 1)
	Probe.reset(); Probe.enabled = true
	FactionAISystem.new()._dispatch_care_scout(c[0], c[1], c[2])
	Probe.enabled = false
	_ok(int(Probe.counts.get("care.scout_dispatched", 0)) == 0,
		"村他勢力(faction≠lord)→_faction_roster_pos→-1→silent(own-faction only、跨勢力不上名冊)")

	if _fail == 0: print("=== DONE === ALL PASS")
	else: print("=== DONE === %d FAIL" % _fail)
	quit()
