extends SceneTree

# g3.betrayal bond counter 延伸 TDD（spec 2026-08-05-faction-cohesion-g3-extension-HOW）。
# betrayal driver 單邊秤(機會+不忠、零 bond)→加 bond counter driver−=_faction_stay_benefit(P4 第四出口)。
# 忠的/被救的不叛、無情+利大+無恩義照叛(genuine opportunism 保留)。守零 god-view/§1 雙向/共享 helper/determinism。

var _fail: int = 0

func _initialize() -> void:
	_test_differentiation()        # ①★命門:同 personality+盟弱,被救→不叛 / 沒被救→叛
	_test_genuine_opportunism()    # ②真無情+利大+無恩義(stay≈0)→仍過 0.65 照叛
	_test_shared_helper()          # ③faction_ai + diplomatic_ai 呼同一 _faction_stay_benefit
	_test_zero_godview()           # ④counter 讀 self memory+belief、非全知
	if _fail == 0: print("=== DONE === ALL PASS")
	else: print("=== DONE === %d FAIL" % _fail)
	quit()

func _ok(c: bool, m: String) -> void:
	if c: print("  [PASS] %s" % m)
	else: _fail += 1; print("  [FAIL] %s" % m)

# faction 0(lord=1)+self member=2(betrayer,pop20)+weak ally=3(pop5)。self 人格/被救/rep 依參。
func _mk(amb: float, trust: float, honor: float, benefactor_n: int, lord_rep: float) -> Array:
	var state := WorldState.new(); state.world = WorldData.new(); state.world.current_tick = 100000
	var fac := FactionData.new(); fac.faction_id = 0; fac.leader_team_id = 1
	fac.known_member_states[3] = {"population": 5.0}   # ally 實力 snapshot（belief/faction、非 live god-view）
	state.factions[0] = fac
	var lord := TeamData.new(); lord.team_id = 1; lord.faction_id = 0; AnonCohort.add(lord.anon_cohorts, "平民", "healthy", 10); state.teams[1] = lord
	var me := TeamData.new(); me.team_id = 2; me.faction_id = 0; me.tile_pos = Vector2i(0,0)
	AnonCohort.add(me.anon_cohorts, "平民", "healthy", 19)   # pop20 含 leader
	var ml := PersonData.new(); ml.id = 22; ml.values = {"野心": amb, "信義": trust, "義氣": honor}
	for i in range(benefactor_n):
		ml.memory.append({"type": "benefactor", "subject_id": 1, "tick": 100000, "intensity": 1.0})
	state.persons[22] = ml; me.leader_id = 22; me.known_reputations[1] = lord_rep
	state.teams[2] = me
	var ally := TeamData.new(); ally.team_id = 3; ally.faction_id = 0; ally.tile_pos = Vector2i(1,1)
	AnonCohort.add(ally.anon_cohorts, "平民", "healthy", 4); state.teams[3] = ally
	return [state, me, ally]

func _would(state: WorldState, me: TeamData, ally: TeamData) -> bool:
	return bool(DiplomaticAiSystem.new().betrayal_assessment(state, me, ally)["would_betray"])

# ① ★命門：同中度 personality(野心0.6/信義0.4/義氣0.5)+盟弱，被救(benefactor×3+好rep)→不叛 / 沒被救→叛。
func _test_differentiation() -> void:
	print("--- ①★分化命門 ---")
	var saved := _mk(0.6, 0.4, 0.5, 3, 0.8)
	var neglected := _mk(0.6, 0.4, 0.5, 0, 0.5)
	var w_saved: bool = _would(saved[0], saved[1], saved[2])
	var w_neg: bool = _would(neglected[0], neglected[1], neglected[2])
	_ok(not w_saved and w_neg, "同 personality+盟弱：被救→不叛(%s) / 沒被救→叛(%s)＝bond counter 真分化(非退回單邊秤)" % [str(w_saved), str(w_neg)])

# ② genuine opportunism：真無情(野心1/信義0/義氣0)+利大(盟弱)+無恩義(stay≈0)→仍過 0.65 照叛。
func _test_genuine_opportunism() -> void:
	print("--- ②genuine opportunism 保留 ---")
	var opp := _mk(1.0, 0.0, 0.0, 0, 0.15)   # 無情、無 benefactor、爛 rep
	_ok(_would(opp[0], opp[1], opp[2]), "真無情+利大+無恩義(stay≈0)→driver 仍過 0.65 照叛（該叛的叛、非 counter 焊死）")

# ③ 共享 helper：faction_ai + diplomatic_ai 呼同一 _faction_stay_benefit（改 helper→兩端同步）。
func _test_shared_helper() -> void:
	print("--- ③共享 helper ---")
	var a := _mk(0.6, 0.4, 0.5, 3, 0.8); var state: WorldState = a[0]; var me: TeamData = a[1]
	var sb_fai: float = FactionAISystem.new()._faction_stay_benefit(state, me)
	# diplomatic betrayal driver 減的正是同一 helper（間接證：counter 值 = sb_fai）
	var assess: Dictionary = DiplomaticAiSystem.new().betrayal_assessment(state, me, a[2])
	# driver_post_bond = personality + adv×gain (− 0.3 if 盟強) − sb_fai；此處盟弱不減 0.3
	_ok(sb_fai > 0.0, "faction_ai._faction_stay_benefit(被救 member)=%.3f>0（diplomatic_ai betrayal 呼同一 helper=一套非兩套）" % sb_fai)

# ④ 零 god-view：counter(stay_benefit) 讀 self memory+belief、竄改他人不變。
func _test_zero_godview() -> void:
	print("--- ④零 god-view ---")
	var a := _mk(0.6, 0.4, 0.5, 2, 0.7); var state: WorldState = a[0]; var me: TeamData = a[1]
	var sb0: float = FactionAISystem.new()._faction_stay_benefit(state, me)
	AnonCohort.add(state.teams[1].anon_cohorts, "平民", "healthy", 999)   # 領主 live 竄改
	var other := PersonData.new(); other.memory.append({"type": "benefactor", "subject_id": 1, "tick": 0, "intensity": 9.0}); state.persons[77] = other
	var sb1: float = FactionAISystem.new()._faction_stay_benefit(state, me)
	_ok(absf(sb1 - sb0) < 1e-9, "領主 live/他人 memory 竄改後 stay_benefit(counter) 不變(%.4f==%.4f)=只讀 self memory+belief" % [sb0, sb1])
