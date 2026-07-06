extends SceneTree

# ★ 序7 reaction 融合驗（核心交付）。reframe：唯一行為選擇=bridge panic-flee → 溶入引擎 survival option。
# 融合非刪雙關：
#   ①行為溶入：高 team_panic（兵卒潰散）→ 引擎主 rank 出 survival(FLEE)（集體恐慌=決策輸入，非旁路 try_set）。
#   ②★FLEE 三源序：真絕境(food≈0)→survival-class(PRIO 80) 壓過 panic-only(FLEE PRIO 70)；panic 不喧賓奪主。
#   ③反向守：兵卒穩(低 stress 高 loyalty)+無威脅 → team_panic 低 → 不逃。
#   ④★個體反應後果保：comply/riot/defect/breed/extort/shirk 各 apply 仍執行（consequence scaffolding 不動）。
# 任一破 = 融合失敗。全走 real gather（team_panic 由 named 成員 stress/loyalty 聚合，繞世界軌跡但真 gather 路）。

var _fails: int = 0

func _initialize() -> void:
	_check_behavior_dissolution()   # ① 行為溶入
	_check_flee_source_order()      # ② 三源序
	_check_reverse_guard()          # ③ 反向守
	_check_individual_consequences()# ④ 個體後果保
	if _fails == 0:
		print("[reaction-dissolution] ALL PASS")
	else:
		print("[reaction-dissolution] FAIL count=%d" % _fails)
	quit()

# ── 世界 setup helper ──
func _place_plains(state: WorldState, pos: Vector2i) -> void:
	var tile := HexTileData.new()
	tile.tile_id = pos.x * 1000 + pos.y; tile.tile_pos = pos; tile.terrain = "plains"
	state.world.tiles[tile.tile_id] = tile

# 建隊：leader（人格中性，calm）+ n_member named 成員（panicked 決定 stress/loyalty）+ food。
# panicked 成員 stress=0.9/loyalty=0.05（過 PANIC gate）；calm 成員 stress=0.0/loyalty=0.95。
# 無 anon → pop = 1(leader) + n_member → team_panic = panicked成員數 / pop。
func _mk_team(state: WorldState, tid: int, n_member: int, panicked: bool, food: float) -> TeamData:
	var t := TeamData.new(); t.team_id = tid; t.tile_pos = Vector2i(5, 5)
	t.leader_id = tid * 10
	t.resources = {"food": food}
	t.current_task = TeamData.TASK_IDLE; t.combat_target = -1
	state.teams[tid] = t
	state.team_discovered[tid] = []
	state.team_intel[tid] = {}
	_place_plains(state, Vector2i(5, 5))
	# leader：中性人格、calm（不入 named_members → 不計 team_panic，只供 leader_values）
	var ldr := PersonData.new(); ldr.id = tid * 10; ldr.team_id = tid; ldr.role = "leader"
	ldr.stress = 0.0; ldr.loyalty = 0.9
	ldr.values = {"求生欲": 0.5, "好戰": 0.5, "慎重": 0.5, "貪婪": 0.5, "信義": 0.5, "義氣": 0.5, "野心": 0.5}
	state.persons[ldr.id] = ldr
	for i in range(n_member):
		var m := PersonData.new(); m.id = tid * 10 + 1 + i; m.team_id = tid; m.role = "civilian"
		m.stress = 0.9 if panicked else 0.0
		m.loyalty = 0.05 if panicked else 0.95
		state.persons[m.id] = m
		t.named_members.append(m.id)
	return t

func _util_of(scored: Array, opt: String) -> float:
	for e in scored:
		if e["opt"] == opt: return float(e["u"])
	return -999.0

func _top_opt(scored: Array) -> String:
	return String(scored[0]["opt"]) if not scored.is_empty() else "<空>"

# ── ① 行為溶入：高 team_panic 隊 → survival(FLEE) 勝主 rank ──
func _check_behavior_dissolution() -> void:
	print("--- ① 行為溶入（潰散→引擎 FLEE）---")
	var state := WorldState.new(); state.world = WorldData.new()
	# 5 pop（leader + 4 panicked 成員）→ team_panic = 4/5 = 0.8；food 足（絕境不干擾）。
	var t := _mk_team(state, 700, 4, true, 300.0)
	var scored: Array = DecisionEngine.rank_scored(state, t)
	var top: String = _top_opt(scored)
	var su: float = _util_of(scored, "survival")
	print("[behavior] pop=%d team_panic(隱)→survival util=%.3f top=%s" % [t.population, su, top])
	if top != "survival":
		_fails += 1
		print("[FAIL] ① 潰散隊未出 FLEE（top=%s，survival util=%.3f）— team_panic 未接入決策" % [top, su])
	else:
		print("[behavior] 潰散→survival(FLEE) 勝主 rank OK")

# ── ② ★FLEE 三源序：真絕境 survival-class 壓過 panic-only FLEE（panic 不喧賓奪主）──
func _check_flee_source_order() -> void:
	print("--- ② FLEE 三源序（真絕境 > panic-only）---")
	# 真絕境隊：food=0 → survival_pressure 巨（覓食/survival-class util 高）；calm 成員（team_panic=0）。
	var s1 := WorldState.new(); s1.world = WorldData.new()
	var td := _mk_team(s1, 710, 2, false, 0.0)
	var sc_desp: Array = DecisionEngine.rank_scored(s1, td)
	var desp_top_u: float = float(sc_desp[0]["u"]) if not sc_desp.is_empty() else 0.0
	# panic-only 隊：food 足（無絕境、無威脅）+ panicked 成員 → survival(FLEE) 由 team_panic 驅。
	var s2 := WorldState.new(); s2.world = WorldData.new()
	var tp := _mk_team(s2, 720, 4, true, 300.0)
	var sc_panic: Array = DecisionEngine.rank_scored(s2, tp)
	var panic_flee_u: float = _util_of(sc_panic, "survival")
	print("[order] 真絕境 top util=%.3f（%s） vs panic-only FLEE util=%.3f" % [
		desp_top_u, _top_opt(sc_desp), panic_flee_u])
	if not (panic_flee_u < desp_top_u):
		_fails += 1
		print("[FAIL] ② panic-only FLEE util(%.3f) ≥ 真絕境 survival util(%.3f) — panic 喧賓奪主，PANIC_WEIGHT 過大" % [
			panic_flee_u, desp_top_u])
	else:
		print("[order] 真絕境 survival-class 壓過 panic-only FLEE OK（panic 不喧賓奪主）")

# ── ③ 反向守：兵卒穩 + 無威脅 → 不逃 ──
func _check_reverse_guard() -> void:
	print("--- ③ 反向守（穩隊不逃）---")
	var state := WorldState.new(); state.world = WorldData.new()
	var t := _mk_team(state, 730, 4, false, 300.0)   # calm 成員、food 足、無威脅
	var scored: Array = DecisionEngine.rank_scored(state, t)
	var top: String = _top_opt(scored)
	var su: float = _util_of(scored, "survival")
	print("[reverse] 穩隊 survival util=%.3f top=%s" % [su, top])
	if top == "survival":
		_fails += 1
		print("[FAIL] ③ 穩隊竟逃（top=survival，util=%.3f）— team_panic 誤觸" % su)
	else:
		print("[reverse] 穩隊不逃 OK（top=%s）" % top)

# ── ④ ★個體反應後果保：各 apply 仍執行（consequence scaffolding 不動）──
func _check_individual_consequences() -> void:
	print("--- ④ 個體反應後果保（consequence scaffolding）---")
	var rs := ReactionSystem.new()
	var state := WorldState.new(); state.world = WorldData.new()
	# comply → loyalty ↑
	var t := _mk_team(state, 740, 2, false, 100.0)
	var m: PersonData = state.persons[7401]
	m.loyalty = 0.5
	rs._apply_reaction(state, m, t, "P1_comply")
	if m.loyalty > 0.5: print("[cons] comply→loyalty+ OK (%.3f)" % m.loyalty)
	else: _fails += 1; print("[FAIL] comply→loyalty 未升 (%.3f)" % m.loyalty)
	# riot → unrest ↑
	var u0: int = t.unrest_turns
	rs._apply_reaction(state, m, t, "N2_riot")
	if t.unrest_turns > u0: print("[cons] riot→unrest+ OK (%d→%d)" % [u0, t.unrest_turns])
	else: _fails += 1; print("[FAIL] riot→unrest 未升 (%d→%d)" % [u0, t.unrest_turns])
	# shirk → food ↓
	var f0: float = float(t.resources.get("food", 0))
	rs._apply_reaction(state, m, t, "N4_shirk")
	var f1: float = float(t.resources.get("food", 0))
	if f1 < f0: print("[cons] shirk→food- OK (%.1f→%.1f)" % [f0, f1])
	else: _fails += 1; print("[FAIL] shirk→food 未降 (%.1f→%.1f)" % [f0, f1])
	# extort → team coin ↓ + person coin ↑
	t.resources["coin"] = 20.0; m.coin = 0.0
	rs._apply_reaction(state, m, t, "N5_extort")
	if float(t.resources.get("coin", 0)) < 20.0 and m.coin > 0.0:
		print("[cons] extort→coin轉 OK (team=%.1f person=%.1f)" % [float(t.resources.get("coin",0)), m.coin])
	else:
		_fails += 1; print("[FAIL] extort→coin 未轉 (team=%.1f person=%.1f)" % [float(t.resources.get("coin",0)), m.coin])
	# breed → minor_population ↑（life event apply）
	var mp0: int = t.minor_population
	rs._apply_life_event(state, m, t, "P5_breed")
	if t.minor_population > mp0: print("[cons] breed→minor+ OK (%d→%d)" % [mp0, t.minor_population])
	else: _fails += 1; print("[FAIL] breed→minor 未升 (%d→%d)" % [mp0, t.minor_population])
	# defect → named 成員離隊（roster 縮）+ 流亡隊 spawn
	var t2 := _mk_team(state, 750, 3, false, 100.0)
	var victim: PersonData = state.persons[7501]
	var roster0: int = t2.named_members.size()
	var teams0: int = state.teams.size()
	rs._apply_reaction(state, victim, t2, "N3_defect")
	if not t2.named_members.has(victim.id) and t2.named_members.size() < roster0 and state.teams.size() > teams0:
		print("[cons] defect→離隊 spawn OK (roster %d→%d, teams %d→%d)" % [
			roster0, t2.named_members.size(), teams0, state.teams.size()])
	else:
		_fails += 1
		print("[FAIL] defect→離隊/spawn 未執行 (roster %d→%d, teams %d→%d)" % [
			roster0, t2.named_members.size(), teams0, state.teams.size()])
