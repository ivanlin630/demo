extends SceneTree
# 繼承-lite TDD：勢力領袖團死→最強成員接位、沒人接才解散。
# ①有成員→繼承 fire+faction 續存 ②無成員→仍 disband ③tie-break 全序 determinism
# ④★同波死亡（領袖+隊友、領袖先處理）→繼任者不得是同批死者 ⑤繼承後 faction 運作不炸。

var _fail := 0
func _ok(c: bool, m: String) -> void:
	if c: print("  PASS ", m)
	else: _fail += 1; print("  FAIL ", m)

func _init() -> void:
	print("=== faction succession-lite test ===")
	_t1_succeeds(); _t2_disband_no_heir(); _t3_tiebreak(); _t4_same_wave_dead(); _t5_runs_after()
	if _fail == 0: print("ALL PASS")
	else: print("FAILS=%d" % _fail)
	quit()

func _mk_team(s: WorldState, tid: int, cmd: float, pop: int, fid: int) -> TeamData:
	var ldr := PersonData.new(); ldr.id = 1000 + tid; ldr.skills = {"統領": cmd}
	s.persons[ldr.id] = ldr
	var t := TeamData.new(); t.team_id = tid; t.leader_id = ldr.id; ldr.team_id = tid
	t.tile_pos = Vector2i(tid, 0)
	AnonCohort.add(t.anon_cohorts, "平民", "healthy", maxi(pop - 1, 0))
	s.teams[tid] = t
	s.set_team_faction(t, fid)
	return t

func _mk_faction(s: WorldState, fid: int, leader_tid: int) -> void:
	s.create_faction(leader_tid)
	# create_faction 用 leader team_id 當 fid（既有慣例）

func _world() -> WorldState:
	var s := WorldState.new(); s.world = WorldData.new(); s.player_id = -1
	s.world.current_tick = 1000
	return s

func _t1_succeeds() -> void:
	print("--- ① 有成員→繼承 ---")
	var s := _world()
	var lead := _mk_team(s, 1, 0.5, 10, -1)
	s.create_faction(1)
	var fid: int = lead.faction_id
	var m2 := _mk_team(s, 2, 0.8, 8, fid)
	var m3 := _mk_team(s, 3, 0.3, 20, fid)
	s.erase_teams([1])
	_ok(s.factions.has(fid), "faction 續存（未解散）")
	if s.factions.has(fid):
		_ok(s.factions[fid].leader_team_id == 2, "最強統領(0.8=Team2)接位、實際=%d" % s.factions[fid].leader_team_id)
		_ok(not s.factions[fid].known_member_states.has(1), "known_member_states 已清死者（由 erase_teams 既有清理負責、非繼承函式）")

func _t2_disband_no_heir() -> void:
	print("--- ② 無成員→仍 disband ---")
	var s := _world()
	var lead := _mk_team(s, 1, 0.5, 10, -1)
	s.create_faction(1)
	var fid: int = lead.faction_id
	s.erase_teams([1])
	_ok(not s.factions.has(fid), "無候選→解散（原行為保留）")

func _t3_tiebreak() -> void:
	print("--- ③ tie-break 全序 ---")
	var s := _world()
	var lead := _mk_team(s, 1, 0.5, 10, -1)
	s.create_faction(1)
	var fid: int = lead.faction_id
	_mk_team(s, 5, 0.6, 12, fid)   # 同統領、pop 大
	_mk_team(s, 4, 0.6, 9, fid)
	_mk_team(s, 6, 0.6, 12, fid)   # 同統領同 pop、team_id 大
	s.erase_teams([1])
	_ok(s.factions.has(fid) and s.factions[fid].leader_team_id == 5,
		"統領平手→pop 大者(Team5)；再平手→team_id 小者。實際=%d" % (s.factions[fid].leader_team_id if s.factions.has(fid) else -1))

func _t4_same_wave_dead() -> void:
	print("--- ④ ★同波死亡不得選死人 ---")
	var s := _world()
	var lead := _mk_team(s, 1, 0.5, 10, -1)
	s.create_faction(1)
	var fid: int = lead.faction_id
	_mk_team(s, 2, 0.9, 30, fid)   # 最強、但同波死
	_mk_team(s, 3, 0.2, 5, fid)    # 真存活
	s.erase_teams([1, 2])          # 領袖先處理、Team2 此刻 teams.has 仍 true
	_ok(s.factions.has(fid), "faction 續存")
	if s.factions.has(fid):
		_ok(s.factions[fid].leader_team_id == 3,
			"★繼任者=真存活的 Team3（非同批死者 Team2）、實際=%d" % s.factions[fid].leader_team_id)
	# 全滅波：領袖+唯一成員同死 → disband
	var s2 := _world()
	var l2 := _mk_team(s2, 1, 0.5, 10, -1)
	s2.create_faction(1)
	var fid2: int = l2.faction_id
	_mk_team(s2, 2, 0.9, 30, fid2)
	s2.erase_teams([1, 2])
	_ok(not s2.factions.has(fid2), "同波全死→無候選→disband")

func _t5_runs_after() -> void:
	print("--- ⑤ 繼承後運作不炸 ---")
	var s := _world()
	var lead := _mk_team(s, 1, 0.5, 10, -1)
	s.create_faction(1)
	var fid: int = lead.faction_id
	_mk_team(s, 2, 0.8, 8, fid)
	s.erase_teams([1])
	var fai := FactionAISystem.new()
	fai._update_goals(s, s.factions[fid])
	fai._assign_tasks(s, s.factions[fid])
	_ok(true, "繼承後 _update_goals/_assign_tasks 無崩潰（leader_team_id=%d）" % s.factions[fid].leader_team_id)
