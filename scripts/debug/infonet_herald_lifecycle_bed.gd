extends SceneTree

# 資訊網 herald-lifecycle 診斷（spec 2026-08-04-herald-lifecycle-diagnostic 缺口B）。measure-first、別下結論、只交真值。
# RE-measure#3:herald dispatch 8 但 distribute/delivered=0=lifecycle 黑洞。逐站 tap 一個 anon herald 全生命定卡哪站。
# 疑:leader_id=-1 撞 loop3:786 on_leader_death→promote anon 當 leader→結構被改→不再遞送。
# 純觀測（手動編排 loop3 leader-death + loop2 _tick_help_herald + movement 逐 tick）零行為變。

func _initialize() -> void:
	seed(1337)
	print("=== herald-lifecycle 診斷（缺口B 逐站）===")
	_trace_herald()
	print("=== DONE ===")
	quit()

func _trace_herald() -> void:
	var state := WorldState.new(); state.world = WorldData.new(); state.world.current_tick = 1000
	var fac := FactionData.new(); fac.faction_id = 0; fac.leader_team_id = 1; state.factions[0] = fac
	# ★全 tile 格網（(5,5)→(8,5) 有 path；避 bed 缺中間 tile 假 no-path confound）
	for x in range(4, 10):
		for y in range(4, 7):
			var gt := HexTileData.new(); gt.tile_pos = Vector2i(x, y); gt.terrain = "plains"
			state.world.tiles[x*1000+y] = gt
	# 領主固定 outpost @(8,5)（roster target；resident 無 belief→名冊解析）
	var lt := HexTileData.new(); lt.tile_pos = Vector2i(8,5); lt.outpost_type = "civilian"; lt.outpost_level = 1; lt.outpost_owner = 1
	state.world.tiles[8*1000+5] = lt
	var lord := TeamData.new(); lord.team_id = 1; lord.faction_id = 0; lord.tile_pos = Vector2i(8,5)
	AnonCohort.add(lord.anon_cohorts, "平民", "healthy", 20); lord.resources = {"food": 3000.0}
	var ll := PersonData.new(); ll.id = 11; ll.values = {"義氣": 0.6, "貪婪": 0.5}; state.persons[11] = ll; lord.leader_id = 11
	state.teams[1] = lord
	# 深餓 resident @(5,5)（pop5 全 anon、名冊可達領主）
	var rt := HexTileData.new(); rt.tile_pos = Vector2i(5,5); rt.outpost_type = "civilian"; rt.outpost_level = 1; rt.outpost_owner = 2
	state.world.tiles[5*1000+5] = rt
	var r := TeamData.new(); r.team_id = 2; r.faction_id = 0; r.tile_pos = Vector2i(5,5); r.tags = [TeamData.TAG_PRODUCE]
	AnonCohort.add(r.anon_cohorts, "平民", "healthy", 5); r.resources = {"food": 0.2}
	r.active_orders = [{"order_id": 700, "kind": "buy", "res": "food", "qty_remaining": 50, "expire_tick": 99999}]
	var lr := PersonData.new(); lr.id = 12; lr.values = {"求生欲": 1.0, "野心": 0.0, "義氣": 0.6}; state.persons[12] = lr; r.leader_id = 12
	state.teams[2] = r

	# 站①：spawn herald（side-dispatch）
	var fa := FactionAISystem.new()
	fa._try_herald_side(state, r)
	var hid: int = -1
	for tid in state.teams:
		if state.teams[tid].task_reason == "help_call": hid = tid; break
	if hid == -1:
		print("  ✗ 站①:herald 未 spawn（_try_herald_side 沒派）"); return
	var h: TeamData = state.teams[hid]
	print("  站①spawn:hid=%d leader_id=%d pop=%d task=%s reason=%s parent=%d tile=%s move_target=%s" % [
		hid, h.leader_id, h.population, h.current_task, h.task_reason, h.parent_team_id, str(h.tile_pos), str(h.move_target)])

	var mv := MovementSystem.new()
	var deposited_before: int = _count_food_buy(state, 1)
	# 逐 tick 手動編排（loop3 leader-death → loop2 _tick_help_herald → movement），trace 到達/黑洞。
	for t in range(60):
		state.world.current_tick += WorldState.TICKS_PER_HOUR
		if not state.teams.has(hid):
			print("  ✗ 站③cull:herald tick=%d 已滅團/移除（population/husk）" % t); return
		h = state.teams[hid]
		# 站②：leader_id==-1 撞 on_leader_death?
		var pre_leader: int = h.leader_id; var pre_reason: String = h.task_reason; var pre_parent: int = h.parent_team_id
		if h.leader_id == -1:
			EventSystem.new().on_leader_death(state, h)
			if h.leader_id != pre_leader or h.task_reason != pre_reason or h.parent_team_id != pre_parent:
				print("  ★站②on_leader_death 改結構 @tick=%d:leader %d→%d reason '%s'→'%s' parent %d→%d" % [
					t, pre_leader, h.leader_id, pre_reason, h.task_reason, pre_parent, h.parent_team_id])
		# 站④：_tick_help_herald 真跑到它?（task_reason==help_call）
		var ticked: bool = false
		if h.current_task == TeamData.TASK_HERALD and h.task_reason == "help_call":
			fa._tick_help_herald(state, h, [])
			ticked = true
		# 站⑤：movement 朝 target
		if state.teams.has(hid):
			mv.process(state, [hid], 1.0, WorldState.TICKS_PER_HOUR)
		# 站⑥：deposit 成功?（每 tick 檢；到達後 next-tick _tick_help_herald 才 deposit+recall，不早退）
		var dep_now: int = _count_food_buy(state, 1)
		if dep_now > deposited_before:
			print("  ★站⑥✓DEPOSIT 成功 tick=%d（領主 food_buy %d→%d、herald %s）=交付鏈通" % [
				t, deposited_before, dep_now, "已消失/recall" if not state.teams.has(hid) else "在(%s)" % str(state.teams[hid].tile_pos)])
			return
		if not state.teams.has(hid):
			print("  ✗站⑥ tick=%d:herald 消失(recall/merge/cull)但領主 food_buy 仍 %d=✗黑洞(消失前沒 deposit)" % [t, dep_now]); return
		h = state.teams[hid]
		if h.tile_pos == Vector2i(8,5) and t % 10 != 0:
			print("  …tick=%d ARRIVED(8,5) 但尚未 deposit（next tick _tick_help_herald 應 deposit）ticked=%s reason='%s' leader_id=%d" % [t, str(ticked), h.task_reason, h.leader_id])
		if t % 10 == 0:
			print("  …tick=%d leader_id=%d reason='%s' task=%s tile=%s move_target=%s ticked=%s" % [
				t, h.leader_id, h.task_reason, h.current_task, str(h.tile_pos), str(h.move_target), str(ticked)])
	print("  ✗ 站⑤/⑥ 60 tick 未到達(卡途中/沒 move；末態 tile=%s move_target=%s task=%s reason='%s' leader_id=%d)" % [
		str(state.teams[hid].tile_pos) if state.teams.has(hid) else "gone",
		str(state.teams[hid].move_target) if state.teams.has(hid) else "-",
		state.teams[hid].current_task if state.teams.has(hid) else "-",
		state.teams[hid].task_reason if state.teams.has(hid) else "-",
		state.teams[hid].leader_id if state.teams.has(hid) else -99])

func _count_food_buy(state: WorldState, tid: int) -> int:
	var n: int = 0
	for m in state.team_known.get(tid, []):
		if m.type == "order_buy" and String(m.params.get("res","")) == "food": n += 1
	return n
