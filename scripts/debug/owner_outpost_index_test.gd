extends SceneTree
# owner→outpost 索引 TDD（效能 arc B、HOW spec §4.3 失效路徑五條 + 語意等價）。
# 每條 assert 都同時比對「索引結果」與「舊全圖掃基準」，任一不符即 FAIL。
# ①set_owner 換手 ②完工 0→>0（★owner 不變的 discriminating case：set_owner 會 early-return，
#   只有 level chokepoint 能救）③拆除 >0→0 ④erase_teams 移除 ⑤同 owner 多據點回「tiles 迭代序最前者」
#   ⑥迭代序 ≠ 座標序（反向插入仍回插入序最前者）⑦roster 隱匿旗行為不變

var _fail := 0
func _ok(c: bool, m: String) -> void:
	if c: print("  PASS ", m)
	else: _fail += 1; print("  FAIL ", m)

func _initialize() -> void:
	_run(); quit()

func _mk_state() -> WorldState:
	var s := WorldState.new(); s.world = WorldData.new(); s.player_id = -1
	s.world.current_tick = 1000
	return s

func _add_tile(s: WorldState, tid: int, pos: Vector2i, level: int, owner: int) -> HexTileData:
	var t := HexTileData.new(); t.tile_id = tid; t.tile_pos = pos; t.terrain = "plains"
	t.resources = {"food": 50.0}; t.resource_cap = {"food": 200.0}
	t.outpost_level = level; t.outpost_owner = owner
	if level > 0: t.outpost_type = "civilian"
	s.world.tiles[tid] = t
	OwnerOutpostIndex.invalidate()   # 測試 fixture 直接寫欄位 → 手動失效（production 走 chokepoint）
	return t

func _add_team(s: WorldState, tid: int, pos: Vector2i) -> TeamData:
	var p := PersonData.new(); p.id = 1000 + tid; p.team_id = tid
	p.values = {"野心": 0.5, "求生欲": 0.5}; p.skills = {"統領": 0.5}
	s.persons[p.id] = p
	var t := TeamData.new(); t.team_id = tid; t.leader_id = p.id; t.tile_pos = pos
	AnonCohort.add(t.anon_cohorts, "平民", "healthy", 8)
	t.resources = {"food": 60.0}
	s.teams[tid] = t
	return t

# 索引 vs 舊掃 雙驗
func _chk(s: WorldState, fai: FactionAISystem, team: TeamData, expect: Vector2i, msg: String) -> void:
	var got: Vector2i = fai._find_own_outpost(s, team)
	var legacy: Vector2i = FactionAISystem._scan_own_outpost_legacy(s, team.team_id)
	_ok(got == expect and legacy == expect,
		"%s（index=(%d,%d) legacy=(%d,%d) expect=(%d,%d)）" % [
			msg, got.x, got.y, legacy.x, legacy.y, expect.x, expect.y])

func _run() -> void:
	print("=== owner→outpost index test ===")
	var fai := FactionAISystem.new()
	var NONE := Vector2i(-1, -1)

	# ① set_owner 換手
	var s1 := _mk_state()
	_add_tile(s1, 0, Vector2i(0, 0), 1, 1)
	var t1 := _add_team(s1, 1, Vector2i(0, 0))
	var t2 := _add_team(s1, 2, Vector2i(3, 3))
	_chk(s1, fai, t1, Vector2i(0, 0), "①前：owner=1 查到自家據點")
	_chk(s1, fai, t2, NONE, "①前：team2 無據點")
	OutpostOwnerBank.set_owner(s1.world.tiles[0], 2, "test_capture")
	_chk(s1, fai, t1, NONE, "★①後：換手後舊主查無")
	_chk(s1, fai, t2, Vector2i(0, 0), "★①後：新主查到")

	# ② 完工 0→>0（owner 不變 → set_owner early-return，只靠 level chokepoint）
	var s2 := _mk_state()
	var bt := _add_tile(s2, 0, Vector2i(2, 2), 0, 5)   # level=0 但 owner 已是 5
	var t5 := _add_team(s2, 5, Vector2i(2, 2))
	_chk(s2, fai, t5, NONE, "②前：level=0 不算據點")
	bt.construction_target = {"action": "build", "type": "civilian", "level": 1}
	bt.construction_team_id = 5
	bt.construction_ticks_left = 0
	OutpostSystem.new()._complete_construction(s2, bt, t5)
	_ok(bt.outpost_level == 1, "②完工後 level=1")
	_chk(s2, fai, t5, Vector2i(2, 2), "★②後：完工 0→>0 立即進表（set_owner 未觸發仍正確）")

	# ③ 拆除 >0→0
	var s3 := _mk_state()
	var dt := _add_tile(s3, 0, Vector2i(4, 1), 2, 3)
	var t3 := _add_team(s3, 3, Vector2i(4, 1))
	_chk(s3, fai, t3, Vector2i(4, 1), "③前：有據點")
	dt.construction_target = {"action": "demolish"}
	dt.construction_ticks_left = 0
	OutpostSystem.new()._complete_construction(s3, dt, t3)
	_ok(dt.outpost_level == 0, "③拆除後 level=0")
	_chk(s3, fai, t3, NONE, "★③後：拆除 >0→0 立即出表")

	# ④ erase_teams 移除
	var s4 := _mk_state()
	_add_tile(s4, 0, Vector2i(7, 7), 1, 4)
	var t4 := _add_team(s4, 4, Vector2i(7, 7))
	_chk(s4, fai, t4, Vector2i(7, 7), "④前：有據點")
	s4.erase_teams([4])
	_ok(s4.world.tiles[0].outpost_owner == -1, "④死亡釋放：tile owner=-1")
	_chk(s4, fai, t4, NONE, "★④後：erase_teams 後查無（索引已失效重建）")

	# ⑤ 同 owner 多據點 → 回 tiles 迭代序最前者
	var s5 := _mk_state()
	_add_tile(s5, 10, Vector2i(5, 0), 1, 6)   # 先插入
	_add_tile(s5, 11, Vector2i(6, 0), 3, 6)   # 後插入、等級更高、座標更大
	var t6 := _add_team(s5, 6, Vector2i(0, 0))
	_chk(s5, fai, t6, Vector2i(5, 0), "★⑤多據點回迭代序最前者（非最高級/非最近）")
	OutpostOwnerBank.set_owner(s5.world.tiles[10], -1, "test_abandon")
	_chk(s5, fai, t6, Vector2i(6, 0), "★⑤第一個失去後遞補第二個")

	# ⑥ 迭代序 ≠ 座標序（反向插入）
	var s6 := _mk_state()
	_add_tile(s6, 11, Vector2i(6, 0), 1, 6)   # 先插入大座標
	_add_tile(s6, 10, Vector2i(5, 0), 1, 6)
	var t6b := _add_team(s6, 6, Vector2i(0, 0))
	_chk(s6, fai, t6b, Vector2i(6, 0), "★⑥反向插入仍回插入序最前者（證明非座標排序）")

	# ⑦ roster：隱匿旗行為不變 + 同表查詢
	var s7 := _mk_state()
	var ht := _add_tile(s7, 0, Vector2i(8, 8), 1, 9)
	var mem := _add_team(s7, 8, Vector2i(0, 0))
	var tgt := _add_team(s7, 9, Vector2i(8, 8))
	s7.create_faction(9)
	s7.set_team_faction(mem, tgt.faction_id)
	var r1: Vector2i = FactionAISystem._faction_roster_pos(s7, mem, 9)
	_ok(r1 == Vector2i(8, 8) and r1 == FactionAISystem._scan_roster_pos_legacy(s7, 9),
		"⑦roster 同勢力查到據點 (%d,%d)" % [r1.x, r1.y])
	ht.outpost_hidden = true
	var r2: Vector2i = FactionAISystem._faction_roster_pos(s7, mem, 9)
	_ok(r2 == NONE and r2 == FactionAISystem._scan_roster_pos_legacy(s7, 9),
		"★⑦隱匿據點仍回 -1（行為不變）")

	print("=== %s（fail=%d）===" % ["ALL PASS" if _fail == 0 else "HAS FAILURE", _fail])
