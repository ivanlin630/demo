extends SceneTree

# de-patch 軌2 值閘 Tier1（feat/constitution-gate-strengthen）
# 閘1 _threat_recent→militancy(軍閥備戰/農夫不備)；閘5 tribute FLEE override→膽識/絕望秤(邊逃邊拒)。

var _fail: int = 0

func _initialize() -> void:
	_test_gate1_militancy()
	_test_gate5_tribute_flee_not_forced()
	if _fail == 0: print("=== DONE === ALL PASS")
	else: print("=== DONE === %d FAIL" % _fail)
	quit()

func _ok(c: bool, m: String) -> void:
	if c: print("  [PASS] %s" % m)
	else: _fail += 1; print("  [FAIL] %s" % m)

# ── 閘1：militancy——軍閥(好戰/FORCE)備戰 > 和平農夫，非「近期被打才備」──
func _test_gate1_militancy() -> void:
	print("--- 閘1：軍備 militancy 人格秤 ---")
	var fai := FactionAISystem.new()
	# 和平農夫（好戰低、非 FORCE、無戰）→ militancy 低
	var farmer := TeamData.new(); farmer.ambition_archetype = "生產"
	var m_farmer: float = fai._militancy(farmer, {"好戰": 0.1})
	# 軍閥（好戰高 + FORCE archetype）→ militancy 高
	var warlord := TeamData.new(); warlord.ambition_archetype = AmbitionLadder.ARCHETYPE_FORCE
	var m_warlord: float = fai._militancy(warlord, {"好戰": 0.9})
	_ok(m_warlord > m_farmer, "★軍閥 militancy(%.2f) > 和平農夫(%.2f)（主動備戰非反應式）" % [m_warlord, m_farmer])
	_ok(m_farmer < 0.3, "和平農夫 militancy(%.2f) 低（不備戰）" % m_farmer)
	_ok(m_warlord > 0.7, "軍閥 militancy(%.2f) 高（主動備戰）" % m_warlord)

# ── 閘5：tribute FLEE override 拆——逃跑不再必屈服，義氣/膽識高可邊逃邊拒 ──
func _test_gate5_tribute_flee_not_forced() -> void:
	print("--- 閘5：逃跑不必屈服（膽識/義氣可拒）---")
	var s := WorldState.new(); s.world = WorldData.new(); s.world.current_tick = 0
	# 逃跑中 + 義氣極高 leader → 應可拒屈服（非硬 override 必 true）
	var brave := PersonData.new(); brave.id = 1
	brave.values = {"義氣": 1.0, "慎重": 0.0, "求生欲": 0.0}; brave.fear = 0.0
	s.persons[1] = brave
	var defender := TeamData.new(); defender.team_id = 1; defender.leader_id = 1
	for i in range(9): defender.named_members.append(100 + i)
	defender.current_task = TeamData.TASK_FLEE
	s.teams[1] = defender
	var agg := TeamData.new(); agg.team_id = 2; agg.leader_id = -1
	for i in range(9): agg.named_members.append(200 + i)   # 同等戰力(非碾壓)
	s.teams[2] = agg
	var accept: bool = DiplomaticAiSystem.tribute_accept(s, defender, agg, 0.0)
	_ok(not accept, "★逃跑中義氣極高 leader→拒屈服（邊逃邊拒=絕境戲，非硬 override 必屈服）")
	# 對比：逃跑中膽識低(高求生欲/高恐懼)→傾向屈服
	var coward := PersonData.new(); coward.id = 3
	coward.values = {"義氣": 0.0, "慎重": 1.0, "求生欲": 1.0}; coward.fear = 1.0
	s.persons[3] = coward
	var d2 := TeamData.new(); d2.team_id = 3; d2.leader_id = 3
	for i in range(4): d2.named_members.append(300 + i)   # 弱
	d2.current_task = TeamData.TASK_FLEE
	s.teams[3] = d2
	var accept2: bool = DiplomaticAiSystem.tribute_accept(s, d2, agg, 0.5)
	_ok(accept2, "逃跑中膽識低/絕望 leader→屈服（絕境傾向，人格秤）")
