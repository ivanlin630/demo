extends SceneTree
# convoy dispatch chokepoint tap TDD（小觀測 slice）。
# ①Probe 關 → 兩個 tap 都不計（零成本、不影響行為）
# ②Probe 開 → 每次進 _dispatch_convoy 都記 attempt；被 ④throttle 擋 → 記 inflight_convoy
# ③attempt 是真分母：成功派出那次也算 attempt（分子/分母同一入口）

var _fail := 0
func _ok(c: bool, m: String) -> void:
	if c: print("  PASS ", m)
	else: _fail += 1; print("  FAIL ", m)

func _initialize() -> void:
	_run(); quit()

func _mk() -> Array:
	var s := WorldState.new(); s.world = WorldData.new(); s.player_id = -1
	s.world.current_tick = 3000
	for i in range(3):
		var t := HexTileData.new(); t.tile_id = i; t.tile_pos = Vector2i(i, 0); t.terrain = "plains"
		t.resources = {"food": 80.0, "material": 80.0}; t.resource_cap = {"food": 200.0, "material": 200.0}
		s.world.tiles[i] = t
	var ldr := PersonData.new(); ldr.id = 900; ldr.team_id = 9
	ldr.values = {"野心": 0.5, "求生欲": 0.5}; ldr.skills = {"統領": 0.6}
	s.persons[900] = ldr
	var lord := TeamData.new(); lord.team_id = 9; lord.leader_id = 900; lord.tile_pos = Vector2i(0, 0)
	AnonCohort.add(lord.anon_cohorts, "平民", "healthy", 12)
	lord.resources = {"food": 120.0, "material": 120.0}
	s.teams[9] = lord
	# ★advisor：dispatch 要求 sub_leader 是母隊 named_member（否則 SubteamSystem.dispatch 回 -1）
	var adv := PersonData.new(); adv.id = 901; adv.team_id = 9
	adv.values = {"野心": 0.4, "求生欲": 0.5}; adv.skills = {"統領": 0.4}
	s.persons[901] = adv
	s.add_member(lord, 901)
	return [s, lord]

func _td() -> Dictionary:
	return {"kind": "deliver", "target": Vector2i(2, 0), "cargo": {"material": 30.0}}

func _run() -> void:
	print("=== convoy dispatch tap test ===")
	var fai := FactionAISystem.new()
	var NONE := 0

	# ① Probe 關 → 零計數（且此呼真的派出一支 convoy，供 ② 的 throttle 情境用）
	var w := _mk(); var s: WorldState = w[0]; var lord: TeamData = w[1]
	Probe.enabled = false
	Probe.reset()
	var ok0: bool = fai._dispatch_convoy(s, lord, _td())
	_ok(ok0, "①（前置）無 in-flight 時真的派出 convoy")
	_ok(int(Probe.counts.get("convoy.dispatch_attempt", 0)) == NONE, "①Probe 關 → attempt 不計（零成本）")

	# ② Probe 開 + 已有 in-flight convoy → attempt 記 1、④ 記 1、回 false
	Probe.enabled = true
	Probe.reset()
	var ok1: bool = fai._dispatch_convoy(s, lord, _td())
	_ok(not ok1, "②已有 convoy 子隊 → 被 throttle 擋（回 false）")
	_ok(int(Probe.counts.get("convoy.dispatch_attempt", 0)) == 1, "②attempt=1")
	_ok(int(Probe.counts.get("convoy.drop.inflight_convoy", 0)) == 1, "★②inflight_convoy=1（唯一會燒那關具名）")
	var ok2: bool = fai._dispatch_convoy(s, lord, _td())
	_ok(not ok2 and int(Probe.counts.get("convoy.drop.inflight_convoy", 0)) == 2
		and int(Probe.counts.get("convoy.dispatch_attempt", 0)) == 2, "②再擋一次 → attempt=2 / inflight=2（連續可累計）")

	# ③ 全新世界、Probe 開、無 in-flight → 成功那次也算在分母（attempt 是真分母，非只計失敗）
	var w2 := _mk(); var s2: WorldState = w2[0]; var lord2: TeamData = w2[1]
	Probe.reset()
	var ok3: bool = fai._dispatch_convoy(s2, lord2, _td())
	_ok(ok3, "③新世界無 in-flight → 真派出")
	_ok(int(Probe.counts.get("convoy.dispatch_attempt", 0)) == 1, "★③成功那次也記 attempt=1（分子/分母同一入口）")
	_ok(int(Probe.counts.get("convoy.drop.inflight_convoy", 0)) == 0, "③成功時不記 ④")
	Probe.enabled = false

	print("=== %s（fail=%d）===" % ["ALL PASS" if _fail == 0 else "HAS FAILURE", _fail])
