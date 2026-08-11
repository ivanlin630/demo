extends SceneTree

# 統一派遣模型 TDD（spec 2026-08-11 §1-§4）：3 drain 點(scout/care/rescue)改 named-led dispatch()。
# 核：①named-led 非 leaderless(succession 784 不誤觸)②次要記名 pick③named-scarcity 少做④歸隊 zero-drain。

var _fail: int = 0
func _ok(c: bool, m: String) -> void:
	if c: print("  [PASS] %s" % m)
	else: _fail += 1; print("  [FAIL] %s" % m)

# 建母隊：leader P11 + named advisors(統領 給定) + k anon。
func _mk_team(advisors: Array, anon: int) -> Array:
	var state := WorldState.new(); state.world = WorldData.new(); state.world.current_tick = 100000
	var t := TeamData.new(); t.team_id = 1; t.faction_id = 0; t.tile_pos = Vector2i(5,5)
	AnonCohort.add(t.anon_cohorts, "平民", "healthy", anon)
	var lp := PersonData.new(); lp.id = 11; lp.values = {}; lp.skills = {"統領": 0.9}; state.persons[11] = lp; t.leader_id = 11
	var nm: Array = []
	for a in advisors:   # a = [id, 統領]
		var p := PersonData.new(); p.id = int(a[0]); p.skills = {"統領": float(a[1])}; state.persons[p.id] = p
		nm.append(p.id)
	t.named_members = nm
	state.teams[1] = t
	return [state, t]

func _initialize() -> void:
	var fai := FactionAISystem.new()

	print("=== ①次要記名 pick（統領最低）===")
	var a := _mk_team([[12, 0.7], [13, 0.3], [14, 0.5]], 6)
	_ok(fai._pick_dispatch_runner(a[0], a[1]) == 13, "_pick_dispatch_runner → P13(統領 0.3 最低=次要、留親信辦要事)")
	# 無 named advisor → -1（named-scarcity）。
	var b := _mk_team([], 6)
	_ok(fai._pick_dispatch_runner(b[0], b[1]) == -1, "無 spare 記名 → -1（少做 genuine 約束）")

	print("=== ②named-led dispatch（非 leaderless、單獨=記名、零 anon 跟班）===")
	var c := _mk_team([[12, 0.7], [13, 0.3]], 6)
	var cstate: WorldState = c[0]; var cteam: TeamData = c[1]
	var anon_before: int = AnonTierSystem.total_pop(cteam)
	var sid: int = fai._dispatch_named_runner(cstate, cteam, TeamData.TASK_SCOUT, "info_scout", Vector2i(9,9), 99, 5)
	_ok(sid != -1, "_dispatch_named_runner 派出子隊 sid=%d" % sid)
	var sub: TeamData = cstate.teams.get(sid)
	_ok(sub != null and sub.leader_id == 13, "子隊 leader=P13 次要記名（named-led、非 leaderless -1）")
	_ok(sub != null and sub.leader_id != -1, "★子隊 leader_id != -1 → loop3:784 succession 從不誤觸（機械升格 0 前提）")
	_ok(sub != null and AnonTierSystem.total_pop(sub) == 0, "子隊零 anon 跟班（單人記名跑腿=§1 匿名不落單）")
	_ok(sub != null and sub.task_reason == "info_scout", "task_reason=info_scout 補設（subteam dispatcher 路由依此）")
	_ok(sub != null and sub.task_start_tick == cstate.world.current_tick, "task_start_tick 補設（_tick_info_scout timeout budget 依此、非 0 即刻逾時）")
	_ok(sub != null and int(sub.task_extra_data.get("timeout", 0)) > 0, "task_extra_data.timeout 補設")
	_ok(not cteam.named_members.has(13), "母隊 named_members 移出 P13（出任務、可動用記名 -1=genuine 稀缺）")
	_ok(AnonTierSystem.total_pop(cteam) == anon_before, "★母隊 anon 池不變（named-led 不掏 anon=zero drain 源、非孤匿名 messenger）")

	print("=== ③named-scarcity 少做（無 spare 記名→不派）===")
	var d := _mk_team([], 6)
	var dsid: int = fai._dispatch_named_runner(d[0], d[1], TeamData.TASK_SCOUT, "info_scout", Vector2i(9,9), 99, 5)
	_ok(dsid == -1 and (d[0] as WorldState).teams.size() == 1, "無 spare 記名 → 不派子隊（少做、無孤匿名頂替）")

	print("=== ④歸隊 zero-drain（記名回母 roster、anon 池守恆）===")
	var e := _mk_team([[12, 0.7], [13, 0.3]], 6)
	var estate: WorldState = e[0]; var eteam: TeamData = e[1]
	var pop_before: int = eteam.population
	var anon0: int = AnonTierSystem.total_pop(eteam)
	var esid: int = fai._dispatch_named_runner(estate, eteam, TeamData.TASK_SCOUT, "info_scout", Vector2i(9,9), 99, 5)
	var esub: TeamData = estate.teams.get(esid)
	# 任務完歸隊：recall→子隊 IDLE 朝母格（dispatch 已設 sub.tile_pos=母格→co-located）→try_merge_back。
	SubteamSystem.recall_envoy(estate, esub)
	var merged: bool = SubteamSystem.new().try_merge_back(estate, esid)
	_ok(merged, "任務完 recall→try_merge_back 成功（§3 歸隊 return-cycle）")
	_ok(eteam.named_members.has(13), "★記名 P13 回母 roster（歸隊、無 monotonic drain）")
	_ok(AnonTierSystem.total_pop(eteam) == anon0, "★anon 池守恆（全程零 drain）")
	_ok(eteam.population == pop_before, "母隊 population 復原（記名回歸、零淨流失）")
	_ok(not estate.teams.has(esid), "子隊 merge 後 erase（無幽靈團殘留=不餵 O(N²)）")

	if _fail == 0: print("=== DONE === ALL PASS")
	else: print("=== DONE === %d FAIL" % _fail)
	quit()
