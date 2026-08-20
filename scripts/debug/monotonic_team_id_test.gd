extends SceneTree
# team_id 永不重用 TDD（slice: monotonic-team-id）。
# ①建隊→滅團→再建隊：新 id 必 > 所有歷史 id（★核心宣稱）
# ②最高 id 的隊死掉也不回頭（修前正是這條讓號碼被撿回）
# ③★floor 防禦：state 裡已有 >= 計數器的 id（未來存檔載入忘了同步）→ 自我抬高且留 tap，不靜默撞號
# ④負區段（beast）不相撞
# ⑤真實出生口走同一分配器：SubteamSystem.dispatch 連派兩支，id 不重複且遞增

var _fail := 0
func _ok(c: bool, m: String) -> void:
	if c: print("  PASS ", m)
	else: _fail += 1; print("  FAIL ", m)

func _initialize() -> void:
	_run(); quit()

func _mk_state() -> WorldState:
	var s := WorldState.new(); s.world = WorldData.new()
	var t := HexTileData.new(); t.tile_id = 0; t.tile_pos = Vector2i(0, 0); t.terrain = "plains"
	t.resources = {"food": 50.0}; t.resource_cap = {"food": 200.0}
	s.world.tiles[0] = t
	return s

func _add(s: WorldState, tid: int) -> TeamData:
	var t := TeamData.new(); t.team_id = tid; t.tile_pos = Vector2i(0, 0)
	AnonCohort.add(t.anon_cohorts, "平民", "healthy", 4)
	s.teams[tid] = t
	return t

func _run() -> void:
	print("=== monotonic team_id test ===")
	var s := _mk_state()

	# ① / ② 建→滅→再建
	var ids: Array = []
	for i in range(3):
		var id: int = s.consume_next_team_id()
		ids.append(id)
		_add(s, id)
	_ok(ids == [0, 1, 2], "①連續配發 %s" % str(ids))
	var top: int = int(ids[2])
	s.teams.erase(top)                      # 最高 id 的隊死掉
	var after: int = s.consume_next_team_id()
	_ok(after > top, "★②最高 id 死掉後不回頭（%d > %d）＝號碼永不重用" % [after, top])
	var all_hist: Array = ids.duplicate(); all_hist.append(after)
	_ok(after == 3 and all_hist.max() == after, "②新 id 大於所有歷史 id")

	# 全滅也不回頭
	s.teams.clear()
	var after_wipe: int = s.consume_next_team_id()
	_ok(after_wipe > after, "★②全滅後仍不回頭（%d > %d）" % [after_wipe, after])

	# ③ floor 防禦（模擬「存檔載入沒同步計數器」）
	var s3 := _mk_state()
	_add(s3, 50)
	Probe.enabled = true; Probe.reset()
	var id3: int = s3.consume_next_team_id()
	_ok(id3 == 51, "★③已存在 id 50 而計數器=0 → 抬到 51（不撞號），實得 %d" % id3)
	_ok(int(Probe.counts.get("teamid.floor_bump", 0)) >= 1, "★③自我修復留下 tap（不靜默）")
	Probe.enabled = false

	# ④ 負區段不相撞
	var s4 := _mk_state()
	var beast_id: int = s4.next_beast_id
	var team_id: int = s4.consume_next_team_id()
	_ok(beast_id < 0 and team_id >= 0, "④beast 負區段（%d）與 team 正區段（%d）不相撞" % [beast_id, team_id])

	# ⑤ 真實出生口：SubteamSystem.dispatch 兩支
	var s5 := _mk_state()
	var lp := PersonData.new(); lp.id = 900; lp.team_id = 0; lp.skills = {"統領": 0.6}
	s5.persons[900] = lp
	var lead := TeamData.new(); lead.team_id = s5.consume_next_team_id(); lead.leader_id = 900
	lead.tile_pos = Vector2i(0, 0)
	AnonCohort.add(lead.anon_cohorts, "平民", "healthy", 20)
	s5.teams[lead.team_id] = lead
	for i in range(3):
		var adv := PersonData.new(); adv.id = 901 + i; adv.team_id = lead.team_id; adv.skills = {"統領": 0.4}
		s5.persons[adv.id] = adv
		s5.add_member(lead, adv.id)
	var sub_sys := SubteamSystem.new()
	var a: int = sub_sys.dispatch(s5, lead.team_id, 901, 2, TeamData.TASK_SCOUT, Vector2i(1, 0))
	var b: int = sub_sys.dispatch(s5, lead.team_id, 902, 2, TeamData.TASK_SCOUT, Vector2i(1, 0))
	_ok(a != -1 and b != -1 and b > a, "★⑤真實 dispatch 走同一分配器（%d → %d 遞增不重複）" % [a, b])
	s5.teams.erase(b)
	# ★用第三位 advisor：902 已隨上一支子隊離開母隊 named_members（dispatch 硬要求 sub_leader 在母隊名冊）
	var c: int = sub_sys.dispatch(s5, lead.team_id, 903, 2, TeamData.TASK_SCOUT, Vector2i(1, 0))
	_ok(c > b, "★⑤子隊死後再派，id 不撿回（%d > %d）" % [c, b])

	print("=== %s（fail=%d）===" % ["ALL PASS" if _fail == 0 else "HAS FAILURE", _fail])
