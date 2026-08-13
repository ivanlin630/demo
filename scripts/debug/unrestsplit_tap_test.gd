extends SceneTree

# unrest-split tap-gap TDD：event_unrest_split._split_team create_team 後 spawn.unrest_split tap 真 fire。純觀測零行為變。
const EUS = preload("res://scripts/simulation/events/event_unrest_split.gd")

var _fail: int = 0
func _ok(c: bool, m: String) -> void:
	if c: print("  [PASS] %s" % m)
	else: _fail += 1; print("  [FAIL] %s" % m)

func _initialize() -> void:
	seed(42)
	var state := WorldState.new(); state.world = WorldData.new(); state.world.current_tick = 1000
	var parent := TeamData.new(); parent.team_id = 1; parent.faction_id = 0; parent.tile_pos = Vector2i(5,5)
	AnonCohort.add(parent.anon_cohorts, "平民", "healthy", 9)
	var lp := PersonData.new(); lp.id = 11; state.persons[11] = lp; parent.leader_id = 11
	var diss := PersonData.new(); diss.id = 12; diss.loyalty = 0.1; diss.team_id = 1; state.persons[12] = diss
	parent.named_members = [12]
	state.teams[1] = parent
	var before: int = state.teams.size()
	Probe.reset(); Probe.enabled = true
	var eus = EUS.new()
	var new_team = eus._split_team(state, parent, [diss])
	Probe.enabled = false
	_ok(new_team != null and state.teams.size() == before + 1, "高 unrest 分裂 → 生新隊（%d→%d）" % [before, state.teams.size()])
	_ok(int(Probe.counts.get("spawn.unrest_split", 0)) == 1, "★spawn.unrest_split tap fire（碎裂源可測、counter=1）")
	if _fail == 0: print("=== DONE === ALL PASS")
	else: print("=== DONE === %d FAIL" % _fail)
	quit()
