extends SceneTree

# 勢力凝聚力 TDD（spec 2026-08-05-faction-cohesion-HOW）。
# P4 真好處接留走秤：_faction_stay_benefit(relief memory + heard reputation、人格 mod)；defect 死 cliff→連續 defect_util;
# benefactor write@distribute settle;整併三決策點;uprising 後果秤。守零 god-view/§1 防crank 雙向/人格非死常數。

var _fail: int = 0

func _initialize() -> void:
	_test_defect_differentiation()   # ①★命門:同 distress+honor,被救過→留 / 沒被救→走
	_test_stay_benefit_good_vs_bad() # ②好領主(relief+好rep) stay_benefit > 爛領主
	_test_benefactor_write()         # ③distribute relief settle→resident 得 benefactor memory
	_test_zero_godview()             # ④★stay_benefit 讀 self memory+belief、非全知(改他隊不影響)
	_test_tyrant_still_defects()     # ⑥該散的散:暴君 member(無 relief+爛rep)真餓→仍 defect(genuine exit 保留)
	_test_uprising_consequence()     # ⑤uprising 後果秤:高義氣+被救→留勢力 vs 野心→脫
	if _fail == 0: print("=== DONE === ALL PASS")
	else: print("=== DONE === %d FAIL" % _fail)
	quit()

func _ok(c: bool, m: String) -> void:
	if c: print("  [PASS] %s" % m)
	else: _fail += 1; print("  [FAIL] %s" % m)

# faction 0(lord=team1)+member team2；member 人格/被救/rep 依參。
func _mk(honor: float, trust: float, benefactor_n: int, lord_rep: float, unrest: int) -> Array:
	var state := WorldState.new(); state.world = WorldData.new(); state.world.current_tick = 100000
	var fac := FactionData.new(); fac.faction_id = 0; fac.leader_team_id = 1; state.factions[0] = fac
	var lord := TeamData.new(); lord.team_id = 1; lord.faction_id = 0; lord.tile_pos = Vector2i(0,0)
	AnonCohort.add(lord.anon_cohorts, "平民", "healthy", 10); state.teams[1] = lord
	var m := TeamData.new(); m.team_id = 2; m.faction_id = 0; m.tile_pos = Vector2i(3,3); m.unrest_turns = unrest
	AnonCohort.add(m.anon_cohorts, "平民", "healthy", 6)
	var ml := PersonData.new(); ml.id = 22; ml.values = {"義氣": honor, "信義": trust, "野心": 0.5, "慎重": 0.5, "求生欲": 0.5}
	for i in range(benefactor_n):
		ml.memory.append({"type": "benefactor", "subject_id": 1, "tick": 100000, "intensity": 1.0})
	state.persons[22] = ml; m.leader_id = 22
	m.known_reputations[1] = lord_rep
	state.teams[2] = m
	return [state, m]

# ① ★命門：同 distress(unrest25)+低 honor(0.2)，被救過(benefactor×3+好rep)→不 defect / 沒被救(rep 0.5)→defect。
func _test_defect_differentiation() -> void:
	print("--- ①★分化命門 ---")
	var defect_evt = load("res://scripts/simulation/events/event_faction_defect.gd").new()
	var saved := _mk(0.2, 0.2, 3, 0.8, 25)      # 被救過+好rep
	var neglected := _mk(0.2, 0.2, 0, 0.5, 25)  # 沒被救
	var d_saved: bool = defect_evt.check(saved[0], saved[1])
	var d_neg: bool = defect_evt.check(neglected[0], neglected[1])
	_ok(not d_saved and d_neg, "同餓+同低honor：被救過→不 defect(%s) / 沒被救→defect(%s)＝stay_benefit 真分化(非退回死 cliff)" % [str(d_saved), str(d_neg)])

# ② 好領主 stay_benefit > 爛領主。
func _test_stay_benefit_good_vs_bad() -> void:
	print("--- ②好vs爛領主 stay_benefit ---")
	var fai := FactionAISystem.new()
	var good := _mk(0.5, 0.5, 3, 0.9, 0)   # 被救+好rep
	var bad := _mk(0.5, 0.5, 0, 0.2, 0)    # 沒被救+爛rep
	var sb_good: float = fai._faction_stay_benefit(good[0], good[1])
	var sb_bad: float = fai._faction_stay_benefit(bad[0], bad[1])
	_ok(sb_good > sb_bad + 1e-6, "好領主(relief+好rep) stay_benefit %.3f > 爛領主 %.3f（同機制人格產不同壽命地基）" % [sb_good, sb_bad])

# ③ distribute relief settle → resident leader 得 benefactor memory（P4 地基）。
func _test_benefactor_write() -> void:
	print("--- ③relief→benefactor write ---")
	var state := WorldState.new(); state.world = WorldData.new(); state.world.current_tick = 5000
	# porter(convoy 子隊、parent=領主 team1)帶 food cargo；resident team2(owner、有 buy 單)。
	var porter := TeamData.new(); porter.team_id = 9; porter.parent_team_id = 1
	ResourceBank.set_amt(porter, "food", 100.0, "t"); porter.task_extra_data = {"terminus_team_id": 2}
	state.teams[9] = porter
	var resident := TeamData.new(); resident.team_id = 2; resident.tile_pos = Vector2i(5,5)
	ResourceBank.set_amt(resident, "coin", 100.0, "t")
	resident.active_orders = [{"order_id": 77, "res": "food", "kind": "buy", "qty_remaining": 100}]
	var rl := PersonData.new(); rl.id = 21; state.persons[21] = rl; resident.leader_id = 21
	state.teams[2] = resident
	var tile := HexTileData.new(); tile.tile_pos = Vector2i(5,5); tile.outpost_owner = 2; tile.outpost_level = 1
	tile.resource_cap["food"] = 10000.0; tile.market_orders = [{"order_id": 77, "res": "food", "kind": "buy", "qty_remaining": 100}]
	state.world.tiles[5005] = tile
	# override_ask=0 免費直注（distribute relief）
	InteractionSystem.new()._market_visitor_sell(state, porter, resident, tile, 77, "food", 100, {}, 40.0, 0.0)
	var got: bool = false
	for mm in rl.memory:
		if mm.get("type") == "benefactor" and int(mm.get("subject_id", -1)) == 1: got = true
	_ok(got, "distribute relief 送達→resident leader 得 benefactor(領主=team1) memory（P4 地基、stay_benefit 讀得到 relief 史）")

# ④ ★零 god-view：stay_benefit 讀 self memory + 自身 known_reputations、非全知（改別隊/faction 全域不影響）。
func _test_zero_godview() -> void:
	print("--- ④★零 god-view ---")
	var fai := FactionAISystem.new()
	var a := _mk(0.5, 0.5, 2, 0.7, 0); var state: WorldState = a[0]; var m: TeamData = a[1]
	var sb0: float = fai._faction_stay_benefit(state, m)
	# 竄改領主 live state + 別隊 memory（god-view 源）→ stay_benefit 不該變（只讀 self memory+own belief）
	AnonCohort.add(state.teams[1].anon_cohorts, "平民", "healthy", 999)
	var other := PersonData.new(); other.memory.append({"type": "benefactor", "subject_id": 1, "tick": 0, "intensity": 5.0}); state.persons[99] = other
	var sb1: float = fai._faction_stay_benefit(state, m)
	_ok(absf(sb1 - sb0) < 1e-9, "領主 live pop / 他人 memory 竄改後 stay_benefit 不變(%.4f==%.4f)=只讀 self memory+自身 belief" % [sb0, sb1])

# ⑥ 該散的散：暴君 member(無 relief+爛rep+低honor)真餓→仍 defect（stay_benefit 低、genuine exit 保留、非 boost 焊死）。
func _test_tyrant_still_defects() -> void:
	print("--- ⑥該散的散 ---")
	var defect_evt = load("res://scripts/simulation/events/event_faction_defect.gd").new()
	var tyrant := _mk(0.15, 0.15, 0, 0.15, 30)   # 無 relief、爛 rep、低 honor、久餓
	_ok(defect_evt.check(tyrant[0], tyrant[1]), "暴君 member 無 relief+爛rep+久餓→仍 defect（genuine exit 保留、非焊死）")

# ⑤ uprising 後果秤：高義氣+被救→留勢力(stay_u>secede_u) / 野心→脫。純算術驗決策式(不觸完整 _evaluate_uprising)。
func _test_uprising_consequence() -> void:
	print("--- ⑤uprising 後果秤 ---")
	var fai := FactionAISystem.new()
	# 高義氣(0.9)+被救(benefactor×3+好rep) → stay_u = 0.9×0.5 + stay_benefit(高) 應 > secede_u = 0.5×0.6+(1-0.9)×0.4
	var loyal := _mk(0.9, 0.7, 3, 0.9, 0)
	var sb_loyal: float = fai._faction_stay_benefit(loyal[0], loyal[1])
	var stay_u: float = 0.9 * 0.5 + sb_loyal
	var secede_u: float = 0.5 * 0.6 + (1.0 - 0.9) * 0.4   # ambition 0.5(mk 固定)
	_ok(stay_u > secede_u, "高義氣+被救：uprising stay_u %.3f > secede_u %.3f（守城後可留勢力換新、非無條件脫）" % [stay_u, secede_u])
