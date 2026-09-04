extends SceneTree

# ★★★共位必見 控制床（systems 備案 2026-09-05：不要第五次重跑 90 日窗）。
#   ★90 日窗等的是【JOIN 情境自己長出來】—— 而 12 日窗母體 0 已經證明它有多稀有
#     ⇒ 每次被砍付的是【90 日的等待】不是【90 日的資訊】。
#   ★★本床【直接把情境做出來】：把 host 放在 joiner 腳下，然後跑真的 VisionSystem。
#   ★★★誠實限（systems 先寫的，我照抄不改）：本床證的是【機制通不通】，
#     不是【世界裡多常發生】⇒ 它【不能取代】90 日窗的那個「多常發生」。
#
# ★床的鑑別力自證（★否則「全綠」跟「床根本沒鑑別力」長得一樣）：
#   ★★兩個場景【刻意做成一紅一綠】——
#     G1 森林小 host ⇒ 機率閘分數 0.16 < 0.3 ⇒ **修前必看不見**（這一格修前是紅的）
#     G2 平原大 host ⇒ 分數 0.45 > 0.3 ⇒ **修前也看得見**（這一格修前修後都綠）
#   ★★★所以「G1 綠而 G2 也綠」才是通過；若 G1 在修前也綠 ⇒ 床沒鑑別力，不是修有效。

var _next_id: int = 1
var _fails: int = 0

func _initialize() -> void:
	_run(); quit()

func _run() -> void:
	print("=== 共位必見 控制床 ===")
	seed(1337)
	Probe.enabled = true
	_scenario("G1 森林·小 host（★修前應看不見：分數約 0.16 < 0.3）", "forest", 3, 3, 0, true)
	_scenario("G2 平原·大 host（★修前也看得見：分數約 0.9 > 0.3）", "plains", 3, 30, 0, false)
	_scenario("G3 森林·小 host·相鄰 dist=1（★拿 dist_f 上限，但仍走機率閘）", "forest", 3, 3, 1, true)
	_scenario("G4 森林·小 host·dist=4（★遠場對照：這一格【不該】被這一刀改動）", "forest", 3, 3, 4, true)
	Probe.enabled = false
	print("")
	print("★★★總計 FAIL = %d" % _fails)
	print("[TEST-SUITE-COMPLETE]")

func _mk_world(terrain: String) -> WorldState:
	var s := WorldState.new(); s.world = WorldData.new(); s.player_id = -1
	for x in range(0, 20):
		for y in range(0, 3):
			var t := HexTileData.new()
			t.tile_pos = Vector2i(x, y); t.terrain = terrain
			t.resources = {"food": 50.0}; t.resource_cap = {"food": 200.0}
			s.world.tiles[x * 1000 + y] = t
	s.world.current_tick = 100
	return s

func _mk_team(s: WorldState, pop: int, pos: Vector2i, food: float) -> TeamData:
	var p := PersonData.new(); p.id = _next_id; _next_id += 1
	# ★偵查刻意留 0：`_can_detect` 是 `eff_exp + scout*0.3 > 0.3`
	#   ⇒ ★★scout 一旦不是 0，這張床就【不再是】機率閘的邊界測試。
	p.values = {"求生欲": 0.8}; p.skills = {"統領": 0.5}
	s.persons[p.id] = p
	var t := TeamData.new(); t.team_id = _next_id; _next_id += 1
	t.leader_id = p.id; p.team_id = t.team_id
	AnonCohort.add(t.anon_cohorts, "平民", "healthy", maxi(pop - 1, 0))
	t.tile_pos = pos; t.faction_id = -1; t.parent_team_id = -1
	t.resources = {"food": food}
	t.current_task = TeamData.TASK_IDLE
	s.teams[t.team_id] = t
	return t

func _scenario(label: String, terrain: String, joiner_pop: int, host_pop: int,
		start_dist: int, expect_prefix_blind: bool) -> void:
	print("")
	print("--- %s ---" % label)
	var s := _mk_world(terrain)
	var joiner := _mk_team(s, joiner_pop, Vector2i(5, 1), 1.0)
	var host := _mk_team(s, host_pop, Vector2i(5 + start_dist, 1), 300.0)
	s.rebuild_team_tile_index()
	var vs := VisionSystem.new()
	var ids: Array = [joiner.team_id, host.team_id]

	# ★★★不手動 `record_claim` —— 這一床的重點正是【讓真的 VisionSystem 去寫】。
	#   ★舊的 mergein 控制床用 `_see()` 手動餵 belief（那是「上界測」），
	#     ★★而手動餵會【繞過】這一刀改的那一段 ⇒ 用它驗這一刀等於什麼都沒驗。
	vs.tick_discovery(s, ids)

	var bp: Vector2i = BeliefSystem.belief_pos(s, joiner.team_id, host.team_id)
	var truth: Vector2i = host.tile_pos
	var seen: bool = bp != Vector2i(-1, -1)
	var dist: int = FactionAISystem._hex_dist(joiner.tile_pos, host.tile_pos)
	print("  dist=%d｜belief_pos=%s｜真 pos=%s｜看見=%s" % [dist, str(bp), str(truth), str(seen)])
	print("  ★修前預期：%s" % ("看不見（機率閘擋掉）" if expect_prefix_blind else "看得見"))

	if dist == 0:
		# ★★★驗收 #1／#2 的控制床形式：★只有 `dist == 0` 是【確定看見】。
		#   ★★`dist == 1` 拿到的是【機率閘的最好情況】（`dist_f` 上限 1.0），不是「確定」——
		#     ★★★spec §3 定案原文就是這樣分的，我第一版把 `dist <= 1` 一起斷言【必見】是【斷言寫錯】，
		#       不是 code 錯（G3 紅過一次，而那一紅指的是我的斷言）。
		if not seen:
			push_error("[FAIL] %s：dist=0 卻沒看見 —— 共位必見沒生效" % label)
			_fails += 1
		elif bp != truth:
			push_error("[FAIL] %s：看見了但 belief_pos=%s ≠ 真 pos=%s" % [label, str(bp), str(truth)])
			_fails += 1
		else:
			print("  ✅ dist=0 必見且位置正確")
	elif dist == 1:
		print("  （dist=1：拿到 `dist_f` 上限 1.0 的【機率】，★不是「確定」⇒ 不斷言必見）")
		if seen and bp != truth:
			push_error("[FAIL] %s：dist=1 看見了但 belief_pos=%s ≠ 真 pos=%s" % [label, str(bp), str(truth)])
			_fails += 1
	else:
		# ★遠場【不斷言看見與否】—— 這一刀不該改動它；★★這裡只把數字印出來當對照。
		print("  （遠場對照，不斷言；★這一格若因這一刀而改變，才是問題）")

	# ★★JOIN 端：委派後看它會不會在【同一格】上 resolve（★驗收 #4 的控制床形式）。
	var fai := FactionAISystem.new()
	var mv := MovementSystem.new()
	var it := InteractionSystem.new()
	var committed: bool = fai._try_join_target(s, joiner, host.team_id)
	print("  commit JOIN=%s（task=%s move_target=%s social_target=%d）" % [
		str(committed), joiner.current_task, str(joiner.move_target), joiner.social_target])
	if committed:
		for _i in range(48):
			s.world.current_tick += WorldState.TICKS_PER_HOUR
			vs.tick_discovery(s, ids)
			var r: Dictionary = mv.process(s, ids, 1.0, WorldState.TICKS_PER_HOUR)
			s.rebuild_team_tile_index()
			# ★★★`join.dispatch = 0` 有兩個成因，而它們長得一樣：
			#   ①相遇了但 resolver 沒認出來   ②【根本沒有相遇事件】——因為 joiner 已經在目的地上，
			#     ★沒有「移動」⇒ 進不了 `moved` 名單 ⇒ `process_on_move` 這一站看不到它。
			#   ⇒ ★★所以把 moved 名單本身量出來，否則我會把②讀成①。
			var _mv: Array = r["moved"]
			Probe.bump("ctrl.moved.size.%d" % _mv.size())
			Probe.bump("ctrl.joiner_in_moved." + ("yes" if _mv.has(joiner.team_id) else "no"))
			it.process_on_move(s, _mv, ids)
			if not s.teams.has(joiner.team_id) or joiner.current_task != TeamData.TASK_JOIN:
				break
		print("  join.dispatch=%d meet_target=%d meet_other=%d resolve=%d timeout=%d abort_ghost=%d" % [
			int(Probe.counts.get("join.dispatch", 0)), int(Probe.counts.get("join.meet_target", 0)),
			int(Probe.counts.get("join.meet_other", 0)), int(Probe.counts.get("join.resolve", 0)),
			int(Probe.counts.get("join.timeout", 0)), int(Probe.counts.get("join.abort_ghost", 0))])
		print("  joiner 還在名冊=%s（★不在＝已併入）" % str(s.teams.has(joiner.team_id)))
		print("  ★★★moved 名單：joiner 有進去=%d ｜ 沒進去=%d（★沒進去 ⇒ 相遇事件根本沒發生）" % [
			int(Probe.counts.get("ctrl.joiner_in_moved.yes", 0)),
			int(Probe.counts.get("ctrl.joiner_in_moved.no", 0))])
		var _ms: Array = []
		for _mk in Probe.counts.keys():
			var _mks: String = String(_mk)
			if _mks.begins_with("ctrl.moved.size."):
				_ms.append("%s筆=%d" % [_mks.substr(16), int(Probe.counts[_mk])])
		_ms.sort()
		print("  ★每 tick moved 名單長度分布：%s" % ("｜".join(PackedStringArray(_ms)) if not _ms.is_empty() else "（空）"))
	print("  vis.colo：pairs=%d detect=%d nodetect=%d saved_by_branch=%d" % [
		int(Probe.counts.get("vis.colo.pairs", 0)), int(Probe.counts.get("vis.colo.detect", 0)),
		int(Probe.counts.get("vis.colo.nodetect", 0)), int(Probe.counts.get("vis.colo.saved_by_branch", 0))])
	Probe.reset()
