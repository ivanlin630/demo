extends SceneTree

# ★★★成員位置回報 控制床（spec 2026-09-05-member-report-envoy §4 #1）——
#   ★問的是:孤立成員觸發位置級大事 ⇒ envoy 派出 ⇒ 抵達後【領袖手上有它的位置】嗎?
#   ★★★而 R² 點名的時序坑:【不要在 dispatch 同一 tick 查 belief】——
#     那時 envoy 才剛被創建、還趕不上該 tick 的 vision ⇒ claim 還沒產生 ⇒ 會讀成「沒回報」
#     ⇒ ★必須在 dispatch【+1 tick 之後】查。本床把【同 tick】與【+1 tick】兩個都印出來，
#       ★★因為「偽陰性長什麼樣」本身就是這張床要保存的證據。

var _next_id: int = 1
var _fails: int = 0

func _initialize() -> void:
	_run(); quit()

func _run() -> void:
	print("=== 成員位置回報 控制床 ===")
	seed(1337)
	_scenario()
	print("")
	print("★★★總計 FAIL = %d" % _fails)
	print("[TEST-SUITE-COMPLETE]")

func _mk_team(s: WorldState, pop: int, pos: Vector2i, food: float) -> TeamData:
	var p := PersonData.new(); p.id = _next_id; _next_id += 1
	p.values = {"求生欲": 0.6}; p.skills = {"統領": 0.6}
	s.persons[p.id] = p
	var t := TeamData.new(); t.team_id = _next_id; _next_id += 1
	t.leader_id = p.id; p.team_id = t.team_id
	# ★named member 要有 —— `_dispatch_envoy` 需要 spare named 當信使，否則它會【正當地】回 false
	for _i in range(2):
		var q := PersonData.new(); q.id = _next_id; _next_id += 1
		q.values = {"求生欲": 0.5}; q.skills = {"統領": 0.3}
		q.team_id = t.team_id
		s.persons[q.id] = q
		t.named_members.append(q.id)
	AnonCohort.add(t.anon_cohorts, "平民", "healthy", maxi(pop - 3, 0))
	t.tile_pos = pos; t.faction_id = -1; t.parent_team_id = -1
	t.resources = {"food": food}
	t.current_task = TeamData.TASK_IDLE
	s.teams[t.team_id] = t
	return t

func _scenario() -> void:
	var s := MeasureBedHelper.arm_and_new(); s.player_id = -1
	for x in range(0, 24):
		for y in range(0, 3):
			var tl := HexTileData.new()
			tl.tile_pos = Vector2i(x, y); tl.terrain = "plains"
			tl.resources = {"food": 50.0}; tl.resource_cap = {"food": 200.0}
			s.world.tiles[x * 1000 + y] = tl
	s.world.current_tick = 100
	var leader := _mk_team(s, 20, Vector2i(0, 1), 300.0)
	var member := _mk_team(s, 10, Vector2i(8, 1), 100.0)
	# 同一勢力（★領袖 team 就是 faction leader）
	var f := FactionData.new()
	f.faction_id = 1
	f.leader_team_id = leader.team_id
	f.member_team_ids = [leader.team_id, member.team_id]
	s.factions[f.faction_id] = f
	leader.faction_id = 1
	member.faction_id = 1
	s.rebuild_team_tile_index()
	# ★成員要【知道領袖在哪】才派得出信使（`_dispatch_envoy` 讀 best_estimate）——
	#   ★★這是【前提】不是【被測物】：測的是「回報有沒有送到」，不是「它知不知道要送去哪」
	BeliefSystem.record_claim(s, member.team_id, leader.team_id, member.team_id, "親見",
		{"tile_pos": leader.tile_pos, "population_est": float(leader.population)}, 1.0, false)
	print("  設定：領袖 team=%d @%s ｜ 成員 team=%d @%s ｜ 距離=%d" % [
		leader.team_id, str(leader.tile_pos), member.team_id, str(member.tile_pos),
		FactionAISystem._hex_dist(leader.tile_pos, member.tile_pos)])
	var before: Vector2i = BeliefSystem.belief_pos(s, leader.team_id, member.team_id)
	print("  ★事前：領袖對成員的 belief_pos = %s（★★應為 (-1,-1)＝還不知道）" % str(before))
	if before != Vector2i(-1, -1):
		push_error("[FAIL] 事前領袖就已經知道成員位置 ⇒ 這張床測不到東西（陰性前提不成立）")
		_fails += 1

	var fai := FactionAISystem.new()
	var mv := MovementSystem.new()
	var it := InteractionSystem.new()
	var vs := VisionSystem.new()
	var msg := SimMessageSystem.new()
	# ★★★觸發事件：成員落腳建營（真事件點，不是直接呼 `_report_to_leader`）
	var built: bool = fai.establish_crude_camp(s, member)
	print("  觸發 `establish_crude_camp` = %s｜`mreport.call.落腳建營`=%d｜`attempt`=%d｜`sent`=%d" % [
		str(built), int(Probe.counts.get("mreport.call.落腳建營", 0)),
		int(Probe.counts.get("mreport.attempt", 0)), int(Probe.counts.get("mreport.sent", 0))])
	if int(Probe.counts.get("mreport.sent", 0)) == 0:
		push_error("[FAIL] 事件觸發了但信使沒派出（sent=0）")
		_fails += 1
		return
	# ★找出 envoy（HERALD 子隊）
	var envoy_id: int = -1
	for tid in s.teams.keys():
		var t: TeamData = s.teams[tid]
		if t.current_task == TeamData.TASK_HERALD and t.parent_team_id == member.team_id:
			envoy_id = int(tid); break
	print("  envoy team=%s" % str(envoy_id))

	# ★★★R² 的時序坑：同 tick vs +1 tick 兩個都印
	var ids: Array = []
	for tid in s.teams.keys(): ids.append(int(tid))
	vs.tick_discovery(s, ids)
	var same_tick: Vector2i = Vector2i(-1, -1)
	if envoy_id != -1:
		same_tick = BeliefSystem.belief_pos(s, envoy_id, member.team_id)
	print("  ★同 tick：envoy 對母隊的 belief_pos = %s" % str(same_tick))
	s.world.current_tick += WorldState.TICKS_PER_HOUR
	s.rebuild_team_tile_index()
	vs.tick_discovery(s, ids)
	var plus1: Vector2i = Vector2i(-1, -1)
	if envoy_id != -1:
		plus1 = BeliefSystem.belief_pos(s, envoy_id, member.team_id)
	print("  ★★+1 tick：envoy 對母隊的 belief_pos = %s（★★★這一格才是 R² 說要看的）" % str(plus1))
	# ★★★而 `belief_pos` 回 (-1,-1) 有兩個完全不同的成因，★它們長得一模一樣：
	#   ①【沒有 claim】—— vision 真的沒寫
	#   ②★★【有 claim 但讀不到】—— `belief_pos` 同 faction 走 `known_member_states`，
	#     ★★★而那是【領袖的 belief】導出的，**不讀觀察者自己的眼睛**
	#   ⇒ 所以這裡把【原始 claim】也印出來，否則我會把②報成①
	if envoy_id != -1:
		var _cs: Array = BeliefSystem.claims(s, envoy_id, member.team_id)
		var _has_pos: bool = false
		for _c in _cs:
			if (_c["value"] as Dictionary).has("tile_pos"): _has_pos = true; break
		print("     ★原始 claim：envoy 對母隊有 %d 筆，其中帶 tile_pos = %s" % [_cs.size(), str(_has_pos)])
		print("     ★★envoy.faction_id=%s ｜ 母隊.faction_id=%s（★★★同 faction ⇒ `belief_pos` 走 known_member_states）" % [
			str((s.teams[envoy_id] as TeamData).faction_id), str(member.faction_id)])
	# ★★★斷言的對象訂正（★這一版之前我斷言錯了東西）：
	#   ★「零 payload 的前提」是【envoy 身上有一筆帶位置的 claim】，
	#     ★★而【不是】`belief_pos` 回得出位置 —— 後者對【同 faction】讀的是
	#     `known_member_states`（領袖的 belief），★★★拿它問「envoy 自己看到了嗎」是【問錯函式】。
	#   ⇒ 而 `belief_pos` 的 (-1,-1) 仍然照印：**那正是這張床要保存的偽陰性樣本**。
	if envoy_id != -1:
		var _cs2: Array = BeliefSystem.claims(s, envoy_id, member.team_id)
		var _hp2: bool = false
		for _c2 in _cs2:
			if (_c2["value"] as Dictionary).has("tile_pos"): _hp2 = true; break
		if not _hp2:
			push_error("[FAIL] +1 tick 後 envoy 身上沒有帶位置的 claim ⇒ 零 payload 的前提不成立")
			_fails += 1
		else:
			print("     ✅零 payload 前提成立：envoy 身上有帶 tile_pos 的 claim")
			print("        ★而 `belief_pos` 仍回 (-1,-1) —— ★★這【不是】前提不成立，")
			print("          是【同 faction 分支不讀觀察者自己的眼睛】（今天第三次量到同一條）")

	# ★跑到 envoy 抵達領袖
	var arrived: bool = false
	for _i in range(240):
		s.world.current_tick += WorldState.TICKS_PER_HOUR
		var ids2: Array = []
		for tid in s.teams.keys(): ids2.append(int(tid))
		vs.tick_discovery(s, ids2)
		var r: Dictionary = mv.process(s, ids2, 1.0, WorldState.TICKS_PER_HOUR)
		s.rebuild_team_tile_index()
		it.process_on_move(s, r["moved"], ids2)
		it.process_colocated_residency(s, ids2)
		# ★★★用 `arrived` 不是 `moved`：★production 的 `sim_runner:433` 傳的就是 `arrived_ids`
		#   ⇒ ★★傳錯的話這張床驗的不是 production 的那條路（而它【不會報錯】，只會少發生一件事）
		msg.exchange_intel_on_arrival(s, r["arrived"], ids2)
		var lp: Vector2i = BeliefSystem.belief_pos(s, leader.team_id, member.team_id)
		if lp != Vector2i(-1, -1):
			arrived = true
			print("  ★★★抵達後：領袖對成員的 belief_pos = %s ｜ 真位置 = %s ｜ tick=%d" % [
				str(lp), str(member.tile_pos), s.world.current_tick])
			# ★★★而【它是走哪一條回來的】要分開印 —— 否則「成功」講不出是誰讓它成功的
			var _be: Dictionary = BeliefSystem.best_estimate(s, leader.team_id, member.team_id)
			var _kms: Dictionary = f.known_member_states.get(member.team_id, {})
			print("     ★team_intel 路（best_estimate）：tile_pos=%s" % str(_be.get("tile_pos", "（無）")))
			print("     ★★known_member_states 路：%s" % ("（空）" if _kms.is_empty() else str(_kms.get("tile_pos", "（無 tile_pos）"))))
			break
	if not arrived:
		push_error("[FAIL] 240 輪內領袖始終不知道成員位置（驗收 #1 未達成）")
		_fails += 1
