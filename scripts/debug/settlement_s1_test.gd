extends SceneTree
# settlement S1 TDD — 死亡釋放(S1a) + 目標池擴充撿现成(S1b)。
# ①S1a erase 後死團 owned tile owner=-1  ②目標池含 -1 outpost 候選(belief-gate)
# ③端到端：團站 -1 outpost 3 天 → 既有 timer set_owner 認領  ④regression：有主/settle-convert 不動。

var _fail := 0

func _ok(cond: bool, msg: String) -> void:
	if cond:
		print("  PASS ", msg)
	else:
		_fail += 1
		print("  FAIL ", msg)

func _mk_tile(state: WorldState, p: Vector2i, terrain: String, owner: int, level: int) -> HexTileData:
	var t := HexTileData.new()
	t.tile_id = p.x*1000 + p.y; t.tile_pos = p
	t.terrain = terrain; t.outpost_owner = owner; t.outpost_level = level
	state.world.tiles[t.tile_id] = t
	return t

func _init() -> void:
	print("=== settlement S1 test ===")
	_t1_erase_release()
	_t2_target_pool_reclaim()
	_t3_end_to_end_takeover()
	_t4_regression()
	if _fail == 0:
		print("ALL PASS")
	else:
		print("FAILS=%d" % _fail)
	quit()

# ① S1a：erase 死團 → 該團 owned tile outpost_owner=-1（其他隊/無主 tile 不動）
func _t1_erase_release() -> void:
	print("--- ① S1a 死亡釋放 ---")
	var state := WorldState.new(); state.world = WorldData.new()
	var dead_tid := 7
	var t_dead := _mk_tile(state, Vector2i(3,3), "plains", dead_tid, 2)   # 死團鬼城
	var t_other := _mk_tile(state, Vector2i(4,3), "plains", 9, 2)         # 他隊 outpost
	var t_free := _mk_tile(state, Vector2i(5,3), "plains", -1, 0)         # 本就無主
	var team := TeamData.new(); team.team_id = dead_tid; team.tile_pos = Vector2i(3,3)
	state.teams[dead_tid] = team
	state.erase_teams([dead_tid])
	_ok(t_dead.outpost_owner == -1, "死團 owned tile owner→-1 (鬼城解鎖)")
	_ok(t_other.outpost_owner == 9, "他隊 outpost 不動")
	_ok(t_free.outpost_owner == -1, "本無主 tile 不動")
	_ok(not state.teams.has(dead_tid), "死團已 erase")

# ② S1b：belief-known(-1) 既有 outpost 進 home-seeking 目標池（撿现成優先）
func _t2_target_pool_reclaim() -> void:
	print("--- ② S1b 目標池含 -1 outpost 候選 ---")
	var fai := FactionAISystem.new()
	var state := WorldState.new(); state.world = WorldData.new()
	# 团腳下(4,4) plains 空地(可新建)；远处(8,8) 為 belief-known 無主鬼城 outpost
	_mk_tile(state, Vector2i(4,4), "plains", -1, 0)
	var ghost := _mk_tile(state, Vector2i(8,8), "plains", -1, 1)   # 無主既有 outpost
	var team := TeamData.new(); team.team_id = 0; team.tile_pos = Vector2i(4,4)
	state.teams[0] = team
	# 未知鬼城 → 撿现成不觸(感知鐵律)，回 fallback 腳下空地
	_ok(fai._find_unowned_farmable_tile(state, team) == Vector2i(4,4), \
		"未 belief-known 鬼城 → 不撿(感知鐵律)、fallback 空地")
	# belief-known(discovered)後 → 撿现成優先，回鬼城位
	state.team_market_known[0] = {ghost.tile_id: true}
	_ok(fai._find_unowned_farmable_tile(state, team) == Vector2i(8,8), \
		"belief-known -1 outpost → 撿现成優先(目標池納)")
	# 鬼城被他隊認領(owner!=-1) → 退出候選、回 fallback
	ghost.outpost_owner = 3
	_ok(fai._find_unowned_farmable_tile(state, team) == Vector2i(4,4), \
		"鬼城有主 → 退候選、fallback 空地")

# ③ 端到端：團站 -1 outpost 滿 OUTPOST_TAKEOVER_DAYS → 既有 timer set_owner（不新增動詞）
func _t3_end_to_end_takeover() -> void:
	print("--- ③ 撿现成端到端(既有 timer 認領) ---")
	var fai := FactionAISystem.new()
	var state := WorldState.new(); state.world = WorldData.new()
	var ghost := _mk_tile(state, Vector2i(8,8), "plains", -1, 1)
	var team := TeamData.new(); team.team_id = 5; team.tile_pos = Vector2i(8,8)
	team.occupying_outpost_since = -1
	state.teams[5] = team
	state.world.current_tick = 1000
	fai._evaluate_outpost_takeover(state, team)   # 站上 → 起 timer
	_ok(team.occupying_outpost_since == 1000, "站上 -1 outpost → timer 起算")
	_ok(ghost.outpost_owner == -1, "未滿 3 天 → 尚未認領")
	# 進 3 天
	state.world.current_tick = 1000 + FactionAISystem.OUTPOST_TAKEOVER_DAYS * WorldState.TICKS_PER_DAY
	fai._evaluate_outpost_takeover(state, team)
	_ok(ghost.outpost_owner == 5, "站滿 3 天 → 既有 timer set_owner 認領")

# ④ regression：有主 outpost 不撿、establish_crude_camp 對 level>0 不覆蓋（settle-convert/占村不動）
func _t4_regression() -> void:
	print("--- ④ regression ---")
	var fai := FactionAISystem.new()
	var state := WorldState.new(); state.world = WorldData.new()
	# 自家 outpost(owner==team) 已知 → 不撿(非鬼城)
	var mine := _mk_tile(state, Vector2i(8,8), "plains", 0, 1)
	_mk_tile(state, Vector2i(4,4), "plains", -1, 0)   # 腳下空地 fallback
	var team := TeamData.new(); team.team_id = 0; team.tile_pos = Vector2i(4,4)
	state.teams[0] = team
	state.team_market_known[0] = {mine.tile_id: true}
	_ok(fai._find_unowned_farmable_tile(state, team) == Vector2i(4,4), \
		"自家 outpost 非鬼城 → 不撿、fallback 空地")
	# 有主既有 outpost 腳下 → establish_crude_camp 拒(不覆蓋既有村，避平行造)
	var occupied := _mk_tile(state, Vector2i(6,6), "plains", 3, 1)
	var t2 := TeamData.new(); t2.team_id = 1; t2.leader_id = 100; t2.tile_pos = Vector2i(6,6)
	var ldr := PersonData.new(); ldr.id = 100; ldr.values = {"好戰": 0.2, "野心": 0.5}
	state.persons[100] = ldr; state.teams[1] = t2
	_ok(not fai.establish_crude_camp(state, t2), "level>0 既有 outpost → crude_camp 拒(不覆蓋)")
	_ok(occupied.outpost_owner == 3, "既有 outpost owner 不被 crude_camp 改")
