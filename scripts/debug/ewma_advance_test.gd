extends SceneTree
# EWMA advance/gather 解耦 TDD。
# ①預設 gather(state,team) 不推進 need_urgency/plan_phase（純讀）②advance=true 才推進
# ③重複純讀多次 → 狀態不變（冪等）④tap：advance 記 need.ewma_advance、純讀記 need.gather_readonly

var _fail := 0
func _ok(c: bool, m: String) -> void:
	if c: print("  PASS ", m)
	else: _fail += 1; print("  FAIL ", m)

func _init() -> void:
	print("=== EWMA advance decouple test ===")
	_t1_readonly_default(); _t2_advance_writes(); _t3_idempotent(); _t4_taps()
	if _fail == 0: print("ALL PASS")
	else: print("FAILS=%d" % _fail)
	quit()

func _mk() -> Array:
	var s := WorldState.new(); s.world = WorldData.new(); s.player_id = -1
	s.world.current_tick = 3000
	var t := HexTileData.new(); t.tile_id = 0; t.tile_pos = Vector2i(0,0); t.terrain = "plains"
	t.resources = {"food": 40.0}; t.resource_cap = {"food": 100.0}
	s.world.tiles[0] = t
	var ldr := PersonData.new(); ldr.id = 77; ldr.values = {"求生欲": 0.6}; ldr.skills = {"統領": 0.5}
	s.persons[77] = ldr
	var team := TeamData.new(); team.team_id = 3; team.leader_id = 77; ldr.team_id = 3
	team.tile_pos = Vector2i(0,0); team.faction_id = -1
	AnonCohort.add(team.anon_cohorts, "平民", "healthy", 5)
	team.resources = {"food": 6.0}
	s.teams[3] = team
	return [s, team]

func _t1_readonly_default() -> void:
	print("--- ① 預設純讀不推進 ---")
	var w := _mk(); var s: WorldState = w[0]; var team: TeamData = w[1]
	DecisionContext.gather(s, team, true)   # 先建立基線（推進一次）
	var base: PackedFloat32Array = team.need_urgency.duplicate()
	var phase: String = team.plan_phase
	var c := DecisionContext.gather(s, team)   # 預設 false
	_ok(team.need_urgency == base, "need_urgency 未被純讀路徑推進")
	_ok(team.plan_phase == phase, "plan_phase 未被純讀路徑改寫")
	_ok(c.need_urgency == base, "ctx 仍拿到現值拷貝（讀得到、只是不推進）")

func _t2_advance_writes() -> void:
	print("--- ② advance=true 推進 ---")
	var w := _mk(); var s: WorldState = w[0]; var team: TeamData = w[1]
	DecisionContext.gather(s, team, true)
	var first: PackedFloat32Array = team.need_urgency.duplicate()
	DecisionContext.gather(s, team, true)
	var second: PackedFloat32Array = team.need_urgency
	var changed: bool = false
	for i in range(mini(first.size(), second.size())):
		if absf(first[i] - second[i]) > 1e-9: changed = true; break
	_ok(first.size() > 0, "need_urgency 有值（EWMA 有跑）")
	_ok(changed, "連兩次 advance → 值再推進（非冪等＝原語意保留）")

func _t3_idempotent() -> void:
	print("--- ③ 純讀多次冪等 ---")
	var w := _mk(); var s: WorldState = w[0]; var team: TeamData = w[1]
	DecisionContext.gather(s, team, true)
	var base: PackedFloat32Array = team.need_urgency.duplicate()
	for _i in range(5):
		DecisionContext.gather(s, team)
	_ok(team.need_urgency == base, "★純讀 5 次 → 狀態零變化（tracer re-query 不再改世界）")

func _t4_taps() -> void:
	print("--- ④ tap ---")
	var w := _mk(); var s: WorldState = w[0]; var team: TeamData = w[1]
	Probe.enabled = true; Probe.reset()
	DecisionContext.gather(s, team, true)
	DecisionContext.gather(s, team)
	DecisionContext.gather(s, team)
	_ok(int(Probe.counts.get("need.ewma_advance", 0)) == 1, "need.ewma_advance=1（實推進處）")
	_ok(int(Probe.counts.get("need.gather_readonly", 0)) == 2, "need.gather_readonly=2（唯讀路）")
	Probe.enabled = false
