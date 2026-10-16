extends SceneTree
# @bed-kind: diagnostic
# slice: 玩家勢力目標改用引擎詞（spec 2026-10-16-player-faction-goal-engine-vocabulary §驗收 G4d）——立國閘抽成 establish_block_reason 前後逐格比
# ★只用抽前就有的 API（_rebuild_goals、f.goals）⇒ 抽前樹與抽後樹都載得進；兩棵樹各跑一次，比輸出逐行相同。不判綠紅、只印。
# ★NPC 路（沒有玩家）：每格只動一個連言，印「立國 in goals」。

const SEED: int = 20261016

static func _team(id: int, pos: Vector2i, fid: int, leader: bool, vals: Dictionary, skills: Dictionary) -> Dictionary:
	return {"id": id, "name": "T%d" % id, "tile_pos": [pos.x, pos.y], "population": 8, "tags": ["統領"] if leader else [],
		"faction_id": fid, "is_faction_leader": leader, "anon_tiers": {"平民": 7},
		"resources": {"food": 20000.0, "coin": 100.0, "material": 400.0},
		"leader": {"name": "L%d" % id, "skills": skills, "values": vals}}

func _case(name: String, amb: float, cmd: float, ready: float, members: int, established: bool, no_leader: bool) -> void:
	seed(SEED)
	var teams: Array = [_team(0, Vector2i(8, 8), 1, true, {"野心": amb}, {"統領": cmd})]
	for i in range(1, members):
		teams.append(_team(i, Vector2i(8, 8 + i), 1, false, {}, {}))
	var st: WorldState = MeasureBedHelper.arm_and_setup({"seed": SEED, "mode": "explicit", "max_ticks": 1000,
		"map": {"radius": 12, "resource_richness": 5}, "teams": teams}, false)
	var lt: TeamData = st.teams[0]
	var f = st.factions[lt.faction_id]
	lt.readiness = ready
	f.is_established = established
	if no_leader:
		st.persons.erase(lt.leader_id)
	FactionAISystem.new()._rebuild_goals(st, f)
	print("G4D|%s|amb=%.2f cmd=%.2f ready=%.2f members=%d est=%s noleader=%s|立國=%s|goals=%s" % [
		name, amb, cmd, ready, f.member_team_ids.size(), str(established), str(no_leader), str(f.goals.has("立國")), str(f.goals)])

func _initialize() -> void:
	print("=== establish_gate_probe ===")
	_case("全過", 0.6, 0.8, 0.9, 2, false, false)
	_case("已立國", 0.6, 0.8, 0.9, 2, true, false)
	_case("成員<2", 0.6, 0.8, 0.9, 1, false, false)
	_case("隊長不存在", 0.6, 0.8, 0.9, 2, false, true)
	_case("統領0.37（門檻0.38）", 0.6, 0.37, 0.9, 2, false, false)
	_case("統領0.38（門檻0.38）", 0.6, 0.38, 0.9, 2, false, false)
	_case("野心0.59", 0.59, 0.8, 0.9, 2, false, false)
	_case("野心0.60", 0.60, 0.8, 0.9, 2, false, false)
	_case("準備度0.69", 0.6, 0.8, 0.69, 2, false, false)
	_case("準備度0.70", 0.6, 0.8, 0.70, 2, false, false)
	print("=== establish_gate_probe DONE ===")
	quit()
